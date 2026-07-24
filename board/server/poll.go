package main

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"sort"
	"sync"
	"sync/atomic"
	"time"

	"github.com/polecatspeaks/StarCar/board/assemble"
	"github.com/polecatspeaks/StarCar/board/fold"
	"github.com/polecatspeaks/StarCar/board/store"
)

// ageBucketMsGranularity is the quantisation bucket for a stale lane's
// server-issued age (design S5.2 Rule 3: "rendered age always comes from
// the server ... quantised, included in change detection"). A DISCLOSED
// choice, not schema-pinned: 5 seconds is coarse enough that most polls
// (pollMs default 1000) do not cross a bucket boundary, so seq does not
// churn on the bare passage of time while a lane sits stale, yet still
// updates periodically as the age climbs.
const ageBucketMsGranularity = int64(5000)

// Server holds the compiled adapter and every mutable field this train's
// living-contract obligation (plan task 4.4) ledgers: lastGoodSnapshot,
// pollInFlight, seq, connectedClients (sse.go), lane-id set (laneRegistry).
// One process, stateless-restartable by construction (design S5.1) -
// everything here is DERIVED from the store on poll; nothing survives a
// restart because nothing needs to.
type Server struct {
	cfg     Config
	adapter *store.Adapter

	mu               sync.Mutex
	seq              int
	lastSnapshot     Snapshot
	lastCompareBytes []byte
	lastPollAt       *time.Time         // plan task 4.4 ledger row: set after EVERY PollOnce call, success or scan failure - distinct from lastGoodSnapshot's asOf, which only advances on a successful scan
	lastGoodAsOf     map[string]*string // per live-lane-id, the most recent successful asOf (carried through a failed scan)
	lastGoodLaneData map[string]any     // #51 C2: per live-lane-id, the most recent successful assembled payload (assemble.DispatchesPayload/GatesPayload/TrainsPayload) - what buildSnapshot assigns to lane.Data on a scan failure, so a failed lane keeps showing its last good content instead of degrading to "no renderer for this payload" (docs/design/2026-07-21-v0-yard-skeleton-design.md section 6 row 1; docs/contracts/state-ledger.md:102)

	pollInFlight int32 // atomic; skip-not-queue guard (TryBeginPoll/EndPoll)

	subs *subscriberRegistry // sse.go

	// vocab/defaultBudget are loaded ONCE at construction (board/fold's own
	// loaders - LoadVocab/LoadDefaultBudget - never a second hand-rolled
	// reader, Law 6) and threaded into every Fold call.
	vocab              fold.Vocab
	vocabLoadCondition *store.BoardCondition
	defaultBudget      *float64
	defaultBudgetCond  *store.BoardCondition

	// testStreamOrderHook, if non-nil, is called (test-only; production
	// never sets it) with a stage label at each ordering checkpoint inside
	// handleStream (#51 C3): "register-done" and "initial-send-done". This
	// is the structural seam TestHandleStreamRegistersBeforeInitialSend
	// (handlers_test.go) uses to pin that registration happens BEFORE the
	// initial snapshot is marshalled and sent - deterministically, without
	// relying on a real, inherently flaky network race.
	testStreamOrderHook func(stage string)
}

// NewServer compiles the schemas (via board/store.NewAdapter) and builds the
// pre-first-poll snapshot: every registered lane present, live lanes
// "never-polled", dark/bagged lanes "not-applicable" - the completeness
// guard (design S5.2) holds from the very first byte this process ever
// serves, before any poll has run.
func NewServer(cfg Config) (*Server, error) {
	adapter, err := store.NewAdapter(cfg.SchemaDir)
	if err != nil {
		return nil, err
	}
	s := &Server{
		cfg:              cfg,
		adapter:          adapter,
		lastGoodAsOf:     map[string]*string{},
		lastGoodLaneData: map[string]any{},
		subs:             newSubscriberRegistry(),
	}

	vocabDir := cfg.SchemaDir
	if vocabDir != "" {
		vocabDir = filepath.Join(vocabDir, "vocab")
	}
	vocab, err := fold.LoadVocab(vocabDir)
	if err != nil {
		s.vocabLoadCondition = &store.BoardCondition{
			Code:     "recognition-vocabulary-unreadable",
			Detail:   "could not load the kind/outcome recognition vocabulary: " + err.Error(),
			Register: "needs-attention",
		}
	}
	s.vocab = vocab

	// The shop-default budget (C3R-1d, spec Amendment 2, issue #22): read
	// once via board/fold.LoadDefaultBudget and threaded into every Fold
	// call via WithDefaultBudgetSeconds, so a budget-less legacy dispatched
	// record can still render overdue - the fix that closed the C3R-1
	// divergence stays closed in production, not just in the vector suite.
	if cfg.DefaultsPath != "" {
		if budget, err := fold.LoadDefaultBudget(cfg.DefaultsPath); err == nil {
			s.defaultBudget = budget
		} else {
			s.defaultBudgetCond = &store.BoardCondition{
				Code:     "shop-default-budget-unreadable",
				Detail:   "could not load the shop-default dispatch budget: " + err.Error(),
				Register: "needs-attention",
			}
		}
	}

	s.lastSnapshot = s.buildSnapshot(nil, nil, false, time.Time{})
	s.lastCompareBytes = mustMarshalStripped(s.lastSnapshot)
	return s, nil
}

// CurrentSnapshot returns the last snapshot this server produced (the
// pre-first-poll snapshot, until PollOnce is first called).
func (s *Server) CurrentSnapshot() Snapshot {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.lastSnapshot
}

// LastPollAt returns the injected "now" of the most recent PollOnce call
// (nil before any poll has ever run) - plan task 4.4's ledger row.
func (s *Server) LastPollAt() *time.Time {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.lastPollAt
}

// TryBeginPoll implements the skip-not-queue overlap guard (design S5.6):
// returns false, WITHOUT blocking, if a poll is already in flight.
func (s *Server) TryBeginPoll() bool {
	return atomic.CompareAndSwapInt32(&s.pollInFlight, 0, 1)
}

// EndPoll releases the in-flight guard.
func (s *Server) EndPoll() {
	atomic.StoreInt32(&s.pollInFlight, 0)
}

// RunPollLoop ticks every cfg.PollMs, skip-not-queue guarded, until ctx is
// done. Production entrypoint; tests call PollOnce directly (no timers).
func (s *Server) RunPollLoop(ctx context.Context) {
	ticker := time.NewTicker(time.Duration(s.cfg.PollMs) * time.Millisecond)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if !s.TryBeginPoll() {
				continue // a poll is already running - skip this tick, never queue
			}
			go func() {
				defer s.EndPoll()
				snap, changed, err := s.PollOnce(time.Now().UTC())
				if err == nil && changed {
					s.subs.broadcast(snap)
				}
			}()
		}
	}
}

// PollOnce scans the store, folds, assembles, and builds a candidate
// snapshot. If the candidate differs from the prior one under the change-
// detection rule (seq/asOf excluded, freshness.kind/ageBucketMs included -
// design S5.6), seq is assigned AFTER the comparison and the new snapshot
// becomes current; otherwise the prior snapshot stands unchanged. now is
// the injected clock (RunPollLoop supplies time.Now().UTC(); tests supply a
// fixed instant).
func (s *Server) PollOnce(now time.Time) (Snapshot, bool, error) {
	scanResult, scanErr := s.adapter.Scan(s.cfg.StorePath, now)

	candidate := s.buildSnapshot(&scanResult, scanErr, true, now)
	candidateCompare := mustMarshalStripped(candidate)

	s.mu.Lock()
	defer s.mu.Unlock()
	nowCopy := now
	s.lastPollAt = &nowCopy // set on EVERY poll attempt, success or scan failure
	if string(candidateCompare) == string(s.lastCompareBytes) {
		return s.lastSnapshot, false, nil
	}

	s.seq++
	nowStr := now.UTC().Format(time.RFC3339)
	candidate.Seq = s.seq
	candidate.AsOf = &nowStr
	s.lastSnapshot = candidate
	s.lastCompareBytes = mustMarshalStripped(candidate)
	return candidate, true, nil
}

// buildSnapshot is the pure builder both NewServer (pre-first-poll) and
// PollOnce (every real poll) call. scanResult/scanErr are nil/nil for the
// pre-first-poll case (polled=false); for a real poll, exactly one of
// scanResult/scanErr is meaningful (Scan's own contract).
func (s *Server) buildSnapshot(scanResult *store.ScanResult, scanErr error, polled bool, now time.Time) Snapshot {
	vocab, vocabConditions := assemble.LoadVocabularies(s.cfg.BoardDefsPath)

	var conditions []WireBoardCondition
	for _, c := range vocabConditions {
		conditions = append(conditions, toWireCondition(c))
	}
	if s.vocabLoadCondition != nil {
		conditions = append(conditions, toWireCondition(*s.vocabLoadCondition))
	}
	if s.defaultBudgetCond != nil {
		conditions = append(conditions, toWireCondition(*s.defaultBudgetCond))
	}

	lanes := make([]Lane, 0, len(laneRegistry))

	var assembled assemble.Result
	var liveFreshnessVal Freshness
	var newLastGood *string

	if !polled {
		liveFreshnessVal = Freshness{Kind: "never-polled"}
	} else if scanErr != nil {
		reasonDetail := scanErr.Error()
		liveFreshnessVal = Freshness{
			Kind:         "failed",
			Reason:       &FreshnessReason{Code: "store-unreadable", Detail: reasonDetail},
			LastGoodAsOf: s.lastGoodAsOf["live"],
		}
	} else {
		for _, c := range scanResult.Conditions {
			conditions = append(conditions, toWireCondition(c))
		}
		records := foldRecordsFrom(scanResult.Records)
		var opts []fold.Option
		if s.defaultBudget != nil {
			opts = append(opts, fold.WithDefaultBudgetSeconds(*s.defaultBudget))
		}
		out := fold.Fold(records, s.vocab, now, opts...)
		// design S6: a vocabulary fault is ONE board condition; an
		// unrecognised kind/outcome is a DISCOVERY, rendered loudly BY NAME
		// (Law 1 - never silently computed and then thrown away).
		for _, f := range out.Faults {
			conditions = append(conditions, WireBoardCondition{Code: "fold-fault", Detail: f, Register: "needs-attention"})
		}
		for _, d := range out.Discoveries {
			conditions = append(conditions, WireBoardCondition{Code: "discovery", Detail: d, Register: "needs-attention"})
		}
		assembled = assemble.Assemble(assemble.Input{Records: scanResult.Records, Fold: out})
		for _, c := range assembled.Conditions {
			conditions = append(conditions, toWireCondition(c))
		}

		nowStr := now.UTC().Format(time.RFC3339)
		newLastGood = &nowStr
		liveFreshnessVal = computeLiveFreshness(scanResult.Records, now, int64(s.cfg.StalenessMs), nowStr)
	}

	if newLastGood != nil {
		s.lastGoodAsOf["live"] = newLastGood
	}

	for _, spec := range laneRegistry {
		lane := Lane{ID: spec.ID, Title: spec.Title, Position: spec.Position}
		switch spec.Position {
		case "live":
			lane.Freshness = liveFreshnessVal
			if polled && scanErr == nil {
				switch spec.ID {
				case "dispatches":
					lane.Data = assembled.Dispatches
					s.lastGoodLaneData[spec.ID] = assembled.Dispatches
				case "gates":
					lane.Data = assembled.Gates
					s.lastGoodLaneData[spec.ID] = assembled.Gates
				case "trains":
					lane.Data = assembled.Trains
					s.lastGoodLaneData[spec.ID] = assembled.Trains
				}
			} else if polled && scanErr != nil {
				// #51 C2: a scan failure retains the LAST GOOD payload for
				// this lane (nil if this is the first-ever poll and there is
				// no prior good data to show - honest-empty, never
				// fabricated) while freshness.kind stays "failed" with its
				// coded reason and lastGoodAsOf (design S6 row 1: "Lane
				// failed, coded reason, lastGood visibly marked").
				lane.Data = s.lastGoodLaneData[spec.ID]
			}
		default:
			lane.Freshness = Freshness{Kind: "not-applicable"}
		}
		lanes = append(lanes, lane)
	}

	if conditions == nil {
		conditions = []WireBoardCondition{}
	}

	return Snapshot{
		Seq: 0, // placeholder - PollOnce assigns the real value AFTER comparison
		Config: WireConfig{
			PollMs:           s.cfg.PollMs,
			HeartbeatMs:      s.cfg.HeartbeatMs,
			StalenessMs:      s.cfg.StalenessMs,
			StorePathDisplay: s.storePathDisplayValue(),
			LaneCount:        len(laneRegistry),
			DemoMode:         s.cfg.DemoMode,
		},
		Vocabularies: vocab,
		Board:        conditions,
		Lanes:        lanes,
	}
}

func (s *Server) storePathDisplayValue() string {
	cwd, _ := os.Getwd()
	home, _ := os.UserHomeDir()
	return storePathDisplay(s.cfg.StorePath, cwd, home)
}

// computeLiveFreshness implements design S5.2's freshness rule for the live
// lanes (dispatches/gates/trains all share one scan, hence one freshness):
// an honest-empty store (zero records) is always fresh - there is no data
// to be stale about (DR3-5a). Otherwise, staleness is DATA age (now minus
// the newest observed record's "at"), never scan-cadence health - proven
// deliberately by spec YB-15 (staleness still fires on unchanging demo
// data even though the scan itself keeps succeeding on schedule).
func computeLiveFreshness(records []store.Record, now time.Time, stalenessMs int64, nowStr string) Freshness {
	if len(records) == 0 {
		return Freshness{Kind: "fresh", AsOf: &nowStr}
	}
	var newest time.Time
	var found bool
	for _, r := range records {
		atStr, _ := r.Fields["at"].(string)
		at, err := time.Parse(time.RFC3339, atStr)
		if err != nil {
			continue // this record already failed store.Scan's own quarantine if malformed; defensive skip only
		}
		if !found || at.After(newest) {
			newest = at
			found = true
		}
	}
	if !found {
		return Freshness{Kind: "fresh", AsOf: &nowStr}
	}
	age := now.Sub(newest)
	if age.Milliseconds() <= stalenessMs {
		return Freshness{Kind: "fresh", AsOf: &nowStr}
	}
	bucket := (age.Milliseconds() / ageBucketMsGranularity) * ageBucketMsGranularity
	return Freshness{Kind: "stale", AsOf: &nowStr, AgeBucketMs: &bucket}
}

func toWireCondition(c store.BoardCondition) WireBoardCondition {
	return WireBoardCondition{Code: c.Code, Detail: c.Detail, Register: c.Register}
}

func foldRecordsFrom(records []store.Record) []fold.Record {
	out := make([]fold.Record, len(records))
	for i, r := range records {
		out[i] = fold.Record(r.Fields)
	}
	return out
}

// mustMarshalStripped is the change-detection comparison basis (design
// S5.6): a copy of snap with Seq zeroed and every raw-timestamp field
// (top-level asOf, each freshness.asOf/lastGoodAsOf) cleared, so the
// comparison is driven by freshness.kind/ageBucketMs and everything else
// that is actually observable STATE, never the bare passage of wall-clock
// time. Panics only on a json.Marshal failure of a fully static Go value,
// which cannot happen for this struct family - never reached in practice.
//
// DISCLOSED, OUT OF SCOPE (found writing the C4R-3 fix-cycle test, Car 4
// review round 1): this function does NOT strip a "dispatched"-winner
// entry's elapsed_seconds (board/fold.DispatchEntry, recomputed every poll
// from now-at), which is a raw, continuously-increasing counter exactly
// like the fields this function DOES strip - unlike ageBucketMs, it is not
// quantised. A live train with an actively dispatched (not yet returned)
// car will therefore see seq bump on every poll that ticks past a whole
// second, not just on a real state change. Not fixed here: the review that
// ordered this comment scoped the ask to ageBucketMs's inclusion direction
// only, and this is a genuinely separate design question (should
// elapsed_seconds be quantised the same way ageBucketMs is, and if so at
// what granularity) that deserves its own decision, not a silent
// side-fix riding on an unrelated commit. Triaged as issue #27
// (deferred; triggers stated there).
func mustMarshalStripped(snap Snapshot) []byte {
	stripped := snap
	stripped.Seq = 0
	stripped.AsOf = nil
	stripped.Lanes = make([]Lane, len(snap.Lanes))
	for i, l := range snap.Lanes {
		f := l.Freshness
		f.AsOf = nil
		f.LastGoodAsOf = nil
		l.Freshness = f
		stripped.Lanes[i] = l
	}
	// Board conditions carry no timestamps of their own; sort for a stable
	// comparison basis regardless of map/slice build order upstream.
	sortedBoard := append([]WireBoardCondition(nil), stripped.Board...)
	sort.Slice(sortedBoard, func(i, j int) bool {
		if sortedBoard[i].Code != sortedBoard[j].Code {
			return sortedBoard[i].Code < sortedBoard[j].Code
		}
		return sortedBoard[i].Detail < sortedBoard[j].Detail
	})
	stripped.Board = sortedBoard

	data, err := json.Marshal(stripped)
	if err != nil {
		panic("board/server: marshalling a stripped Snapshot for change detection failed: " + err.Error())
	}
	return data
}
