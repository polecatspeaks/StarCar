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

// elapsedSecondsBucketGranularity is issue #27's fix: an in-flight
// ("dispatched") winner's elapsed_seconds recomputes every poll from now-at
// (board/fold/algorithm.go:221-222) and, unlike ageBucketMs above, is a raw,
// continuously-increasing counter with no quantisation of its own - every
// poll differs while any dispatch is in flight, so seq bumped on nearly
// every tick, defeating change detection's idle-costs-nothing purpose for
// exactly the periods the board is busiest (design D9).
//
// DECISION (disclosed, per issue #27's own framing of the choice): the WIRE
// value of elapsed_seconds stays EXACT, unbucketed, whenever a snapshot IS
// actually served fresh - board/web/js/dom-writer.js's renderDispatches
// function renders it verbatim to the second (`${d.elapsedSeconds}s`) in its
// solari-elapsed span - cited by SYMBOL, not line (#28/#12 fix cycle round
// 2: a later train's commits shifted this file's line numbers, exactly the
// drift this comment's OWN "cited by symbol/description, not line"
// convention below already names, now applied to itself) - never a rounded
// bucket number. Only
// the CHANGE-DETECTION COMPARISON basis (mustMarshalStripped below)
// quantises elapsed_seconds into this bucket; the value it lets through
// unchanged is never itself rounded.
//
// WHAT THIS DOES NOT MEAN (measured: elapsedbucket_test.go's
// TestPollOnceElapsedSecondsBucketedForChangeDetection - dispatchElapsed(snap2)
// must read 10, the prior snapshot's value, while actual elapsed is 50 -
// cited by symbol/description, not line, since a line coordinate into a
// file the SAME commit edits is exactly the trap this convention exists to
// avoid, per that test file's own header comment on this point).
// Between bucket crossings PollOnce serves the PRIOR snapshot unchanged (poll.go's
// own PollOnce doc comment, "the prior snapshot stands unchanged"), so a
// connected client's displayed elapsed_seconds can trail the true wall-clock
// value by up to this bucket's width (observed: actual 50s, served 10s).
// The VALUE is exact; its RECENCY is not. Nothing downstream derives from
// it - dom-writer.js's renderDispatches only prints the number, render.js's
// buildLaneBody dispatches case only passes it through with a type guard
// (both cited by symbol, not line, same #28/#12 fix cycle round 2 reason
// as above) - and the alarm-bearing field, a
// "dispatched" -> "overdue" transition, is EXACT and immediate regardless of
// this bucket, because that transition changes the STATE STRING
// (algorithm.go:240), a field this bucketing never touches. This is the "no
// schema change, no consumer impact" option named in the ticket:
// schema/yard-snapshot.schema.json's elapsed_seconds stays an unconstrained
// integer and board/web needs no change.
//
// Granularity: order-of-minutes (60s), per the ticket's own framing. At the
// default pollMs (1000ms), this cuts seq churn from "every poll" to "about
// once a minute" while a dispatch sits in flight - the same shape ageBucketMs
// already applies to stale age, coarser here because the CHANGE-DETECTION
// signal this bucket drives does not need per-second resolution, and the
// trade (a display number that can trail by up to a minute, never the
// alarm-bearing state) is sound for a Solari board.
const elapsedSecondsBucketGranularity = int64(60)

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
	lastPollAt       *time.Time // plan task 4.4 ledger row: set after EVERY PollOnce call, success or scan failure - distinct from lastGoodSnapshot's asOf, which only advances on a successful scan
	// #52 C51R-5 SINGLE-POLL INVARIANT: lastGoodAsOf and lastGoodLaneData
	// (both below) are written by buildSnapshot BEFORE s.mu is taken - see
	// PollOnce: it calls s.buildSnapshot(...) first and only reaches
	// s.mu.Lock() afterward - and so are NOT protected by s.mu. Their
	// safety rests entirely on PollOnce never running concurrently with
	// itself - an invariant enforced NOT here but at the ONE production
	// call site, RunPollLoop, which only invokes PollOnce (in its own
	// goroutine) after TryBeginPoll's atomic.CompareAndSwapInt32 has
	// claimed the in-flight slot; a tick that loses the CAS is skipped,
	// never queued (TestSkipNotQueueGuard,
	// TestSkipNotQueueGuardConcurrentClaimIsExclusive, poll_test.go). If a
	// SECOND poller (a second RunPollLoop, an admin-triggered PollOnce,
	// etc.) is ever added without going through this SAME guard, these two
	// maps become a data race. Pin, don't assume: any new PollOnce call
	// site must be gated by TryBeginPoll/EndPoll exactly as RunPollLoop is.
	// CITED BY SYMBOL, NOT LINE (R3-M1, 2026-07-26): this paragraph used to
	// cite hardcoded line numbers "as observed at this commit on branch
	// car/52-hygiene" with a disclaimer that they would drift - they did,
	// three separate times across three later trains, and the disclaimer
	// did not stop it. Function and field names survive an insertion
	// anywhere else in this file; a line number does not.
	// lastGoodAsOf: per live-lane-id, the most recent successful asOf
	// (carried through a failed scan). Before #84 this only ever held key
	// "live" (dispatches/gates/trains all share one scan-derived freshness);
	// #84 added key "freight", tracked independently because freight's
	// freshness is NOT derived from the whole-store scan the way the other
	// three lanes' shared "live" freshness is - it is derived from a
	// kind=ticket-sync record's own "at" (computeFreightFreshness below).
	lastGoodAsOf     map[string]*string
	lastGoodLaneData map[string]any // #51 C2: per live-lane-id, the most recent successful assembled payload (assemble.DispatchesPayload/GatesPayload/TrainsPayload) - what buildSnapshot assigns to lane.Data on a scan failure, so a failed lane keeps showing its last good content instead of degrading to "no renderer for this payload" (docs/design/2026-07-21-v0-yard-skeleton-design.md section 6 row 1; docs/contracts/state-ledger.md:108 - #52 C51R-4: corrected from :102, which is the `seq` row, not this field's row)

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
			Register: store.RegisterForCode("recognition-vocabulary-unreadable"),
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
				Register: store.RegisterForCode("shop-default-budget-unreadable"),
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
	// freightFreshnessVal (#84) is DELIBERATELY a separate value from
	// liveFreshnessVal, never a reuse: liveFreshnessVal answers "did the
	// whole-store scan succeed, and is dispatch/gate/train data moving";
	// freightFreshnessVal answers "has the freight adapter ever completed a
	// run, and how old is its last one" - an orthogonal axis computed from a
	// kind=ticket-sync record's own "at" (computeFreightFreshness below),
	// never from dispatch activity. The two happen to share the same
	// "never-polled"/"failed" values in the !polled/scanErr branches below
	// because THOSE two cases are genuine whole-store facts (the board
	// itself has not scanned yet, or cannot read the store at all) that
	// apply identically to every live lane; only the success branch
	// diverges, which is where Case 1/2/3 (#84's own framing) are actually
	// distinguished.
	var freightFreshnessVal Freshness
	var newLastGood *string

	if !polled {
		liveFreshnessVal = Freshness{Kind: "never-polled"}
		freightFreshnessVal = Freshness{Kind: "never-polled"}
	} else if scanErr != nil {
		reasonDetail := scanErr.Error()
		liveFreshnessVal = Freshness{
			Kind:         "failed",
			Reason:       &FreshnessReason{Code: "store-unreadable", Detail: reasonDetail},
			LastGoodAsOf: s.lastGoodAsOf["live"],
		}
		freightFreshnessVal = Freshness{
			Kind:         "failed",
			Reason:       &FreshnessReason{Code: "store-unreadable", Detail: reasonDetail},
			LastGoodAsOf: s.lastGoodAsOf["freight"],
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
			conditions = append(conditions, WireBoardCondition{Code: "fold-fault", Detail: f, Register: store.RegisterForCode("fold-fault")})
		}
		for _, d := range out.Discoveries {
			conditions = append(conditions, WireBoardCondition{Code: "discovery", Detail: d, Register: store.RegisterForCode("discovery")})
		}
		assembled = assemble.Assemble(assemble.Input{Records: scanResult.Records, Fold: out})
		for _, c := range assembled.Conditions {
			conditions = append(conditions, toWireCondition(c))
		}

		nowStr := now.UTC().Format(time.RFC3339)
		newLastGood = &nowStr
		liveFreshnessVal = computeLiveFreshness(scanResult.Records, out.Dispatches, now, int64(s.cfg.StalenessMs), nowStr)
		freightFreshnessVal = computeFreightFreshness(scanResult.Records, now, int64(s.cfg.StalenessMs), nowStr)
	}

	if newLastGood != nil {
		s.lastGoodAsOf["live"] = newLastGood
		s.lastGoodAsOf["freight"] = newLastGood
	}

	for _, spec := range laneRegistry {
		lane := Lane{ID: spec.ID, Title: spec.Title, Position: spec.Position}
		switch spec.Position {
		case "live":
			switch spec.ID {
			case "dispatches", "gates", "trains":
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
			case "freight":
				lane.Freshness = freightFreshnessVal
				if polled && scanErr == nil {
					lane.Data = assembled.Freight
					s.lastGoodLaneData[spec.ID] = assembled.Freight
				} else if polled && scanErr != nil {
					lane.Data = s.lastGoodLaneData[spec.ID]
				}
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
			PollMs:                s.cfg.PollMs,
			HeartbeatMs:           s.cfg.HeartbeatMs,
			StalenessMs:           s.cfg.StalenessMs,
			StorePathDisplay:      s.storePathDisplayValue(),
			LaneCount:             len(laneRegistry),
			DemoMode:              s.cfg.DemoMode,
			GitHubRepoURL:         githubRepoURL(s.cfg.GitHubRepo),
			GitHubRef:             s.cfg.GitHubRef,
			GitHubArtifactsPrefix: githubArtifactsPrefix(s.cfg.RepoRoot, s.cfg.StorePath),
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
// to be stale about (DR3-5a). Otherwise, DATA age (now minus the newest
// observed record's "at") past stalenessMs still never means the SCAN is
// unhealthy (spec YB-15: staleness still fires on unchanging demo data even
// though the scan itself keeps succeeding on schedule) - but issue #29's
// fix means old data alone is no longer sufficient for the alarming "stale"
// kind. Old data splits two ways, per the fold's own dispatch entries
// (dispatches, out.Dispatches from buildSnapshot's Fold call):
//
//   - Something is IN FLIGHT (a "dispatched"/"overdue" winner, not yet
//     returned) and the data has stopped moving: "stale" - the genuine
//     alarm, something SHOULD be updating and is not.
//   - Nothing is in flight (every dispatch has returned, or is
//     presumed-lost, or the store holds no dispatch subjects at all): the
//     yard is simply AT REST. "idle" - calm, nominal register
//     (board/web/js/compose.js), its age still honestly disclosed via the
//     SAME ageBucketMs mechanism "stale" carries; never rendered as broken
//     just because nothing has happened in a while (Law 1 - "a yard at rest
//     is not stale", issue #29's own framing).
//
// Before this fix, EVERY old-data case rendered "stale" regardless of
// activity - a confident falsehood discovered live the first time a real
// (non-hand-edited) store sat quiet overnight (docs/screenshots/2026-07-23-
// first-light.png).
func computeLiveFreshness(records []store.Record, dispatches []fold.DispatchEntry, now time.Time, stalenessMs int64, nowStr string) Freshness {
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
	if hasInFlightDispatch(dispatches) {
		return Freshness{Kind: "stale", AsOf: &nowStr, AgeBucketMs: &bucket}
	}
	return Freshness{Kind: "idle", AsOf: &nowStr, AgeBucketMs: &bucket}
}

// computeFreightFreshness (#84) is freight's own freshness rule - genuinely
// independent of computeLiveFreshness above, never a reuse of it, because
// the two lanes answer different questions. Freight has no adapter of its
// own visible to the SCAN (the freight adapter, scripts/Sync-Freight.ps1, is
// an external periodic script, never invoked by board/server), so its
// "has this run" signal is a kind=ticket-sync heartbeat RECORD, written by
// that adapter on every SUCCESSFUL run - never on a failed one (this car's
// disclosed design decision: a failed run writes nothing, so a string of
// failures shows up as ordinary staleness climbing, never a separate
// fresh-looking "attempted but failed" marker that could itself go stale
// silently).
//
//   - No ticket-sync record anywhere in the store: the adapter has NEVER
//     completed a run - "never-polled" (Case 1, #84's own framing). This is
//     the one deliberate divergence from computeLiveFreshness's DR3-5a
//     honest-empty rule: an EMPTY store there means "nothing to report,
//     fresh"; here it means "no evidence the adapter exists at all", and
//     collapsing the two would be exactly the confident falsehood Law 1
//     forbids ("the queue is empty" vs "we do not know").
//   - A ticket-sync record within stalenessMs of now: "fresh" (Case 2, a
//     genuinely-run, possibly-genuinely-empty queue - the tickets array
//     itself, not this freshness kind, is what discloses empty-vs-populated).
//   - Older than stalenessMs: "stale" (Case 3), with a quantised ageBucketMs
//     derived from the RECORD's own "at" - never wall-clock hope (#84's own
//     explicit requirement, mirrored from computeLiveFreshness's identical
//     "at"-derived age). Unlike computeLiveFreshness, this never resolves
//     "idle": a ticket queue has no "yard at rest, nothing in flight" analog
//     of its own (freight carries no liveness states to check the way
//     dispatches do via hasInFlightDispatch) - it is either actively synced
//     or its sync has stalled, so old freight data is always the stale
//     alarm, never idle's calm reading.
func computeFreightFreshness(records []store.Record, now time.Time, stalenessMs int64, nowStr string) Freshness {
	var syncAt time.Time
	var found bool
	for _, r := range records {
		if k, _ := r.Fields["kind"].(string); k != "ticket-sync" {
			continue
		}
		atStr, _ := r.Fields["at"].(string)
		at, err := time.Parse(time.RFC3339, atStr)
		if err != nil {
			continue // already failed store.Scan's own quarantine if malformed; defensive skip only
		}
		if !found || at.After(syncAt) {
			syncAt = at
			found = true
		}
	}
	if !found {
		return Freshness{Kind: "never-polled"}
	}
	age := now.Sub(syncAt)
	if age.Milliseconds() <= stalenessMs {
		return Freshness{Kind: "fresh", AsOf: &nowStr}
	}
	bucket := (age.Milliseconds() / ageBucketMsGranularity) * ageBucketMsGranularity
	return Freshness{Kind: "stale", AsOf: &nowStr, AgeBucketMs: &bucket}
}

// hasInFlightDispatch (#29) reports whether any dispatch subject's fold
// winner is still IN FLIGHT - state "dispatched" or "overdue" (algorithm.go
// promotes "dispatched" to "overdue" past budget; both mean "not yet
// returned"). A "returned" or "presumed-lost" winner is NOT in flight: the
// former succeeded, the latter has already been given up on - neither is
// something the yard is still waiting to hear from.
func hasInFlightDispatch(dispatches []fold.DispatchEntry) bool {
	for _, d := range dispatches {
		if d.State == "dispatched" || d.State == "overdue" {
			return true
		}
	}
	return false
}

func toWireCondition(c store.BoardCondition) WireBoardCondition {
	return WireBoardCondition{Code: c.Code, Detail: c.Detail, Register: c.Register, RecordDir: c.RecordDir}
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
// #27 fix: the dispatches lane's payload (assemble.DispatchesPayload, each
// entry a map[string]any built by fold.DispatchEntry.MarshalJSON) also has
// its "elapsed_seconds" entry quantised into elapsedSecondsBucketGranularity
// buckets for THIS COMPARISON COPY ONLY - snap itself (the value actually
// served on the wire) is never touched, only stripped's deep-copied maps
// are. A "dispatched" -> "overdue" transition still bumps seq regardless of
// this bucket, because that changes the "state" string, which this function
// does not touch.
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
		if dp, ok := l.Data.(assemble.DispatchesPayload); ok {
			l.Data = bucketDispatchesForComparison(dp)
		}
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

// bucketDispatchesForComparison (#27) returns a DEEP COPY of dp with every
// entry's "elapsed_seconds" quantised to elapsedSecondsBucketGranularity.
// A deep copy is required, not a mutation in place: dp.Dispatches' maps are
// the SAME map instances buildSnapshot assigned to the real Snapshot that
// gets served on the wire (assemble.Assemble builds them once per poll;
// Lane.Data holds that same value) - mutating them here would corrupt the
// precise elapsed_seconds a connecting client is entitled to see.
// elapsed_seconds arrives as float64 (dispatchWireMap marshals then
// unmarshals fold.DispatchEntry through encoding/json's `any` target,
// board/assemble/assemble.go's dispatchWireMap) - a "returned" or
// "presumed-lost" entry carries no such key (fold.DispatchEntry.MarshalJSON,
// output.go:9-35) and is copied through untouched.
func bucketDispatchesForComparison(dp assemble.DispatchesPayload) assemble.DispatchesPayload {
	out := assemble.DispatchesPayload{Dispatches: make([]map[string]any, len(dp.Dispatches))}
	for i, m := range dp.Dispatches {
		cp := make(map[string]any, len(m))
		for k, v := range m {
			cp[k] = v
		}
		if raw, ok := cp["elapsed_seconds"].(float64); ok {
			cp["elapsed_seconds"] = (int64(raw) / elapsedSecondsBucketGranularity) * elapsedSecondsBucketGranularity
		}
		out.Dispatches[i] = cp
	}
	return out
}
