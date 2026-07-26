package main

import (
	"os"
	"path/filepath"
	"reflect"
	"sync"
	"sync/atomic"
	"testing"
	"time"
)

func testConfig(t *testing.T, storeRoot string) Config {
	t.Helper()
	cfg := DefaultConfig()
	cfg.StorePath = storeRoot
	cfg.SchemaDir = filepath.Join(repoRoot(t), "schema")
	cfg.BoardDefsPath = filepath.Join(cfg.SchemaDir, "vocab", "board-defs.json")
	cfg.WebDir = filepath.Join(repoRoot(t), "board", "web")
	return cfg
}

func writeRecord(t *testing.T, root, name, content string) {
	t.Helper()
	path := filepath.Join(root, name)
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatalf("mkdir: %v", err)
	}
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatalf("write: %v", err)
	}
}

func newTestServer(t *testing.T, storeRoot string) *Server {
	t.Helper()
	srv, err := NewServer(testConfig(t, storeRoot))
	if err != nil {
		t.Fatalf("NewServer: %v", err)
	}
	return srv
}

// TestNewServerPreFirstPollIsNeverPolled: spec S6 lifecycle - before ANY
// poll completes, live lanes read "never-polled" and dark/bagged lanes read
// "not-applicable"; ALL five registered lanes are present (the completeness
// guard, design S5.2).
func TestNewServerPreFirstPollIsNeverPolled(t *testing.T) {
	srv := newTestServer(t, t.TempDir())
	snap := srv.CurrentSnapshot()

	if len(snap.Lanes) != len(laneRegistry) {
		t.Fatalf("expected all %d registered lanes pre-first-poll, got %d", len(laneRegistry), len(snap.Lanes))
	}
	byID := map[string]Lane{}
	for _, l := range snap.Lanes {
		byID[l.ID] = l
	}
	for _, spec := range laneRegistry {
		lane, ok := byID[spec.ID]
		if !ok {
			t.Fatalf("lane %q missing pre-first-poll", spec.ID)
		}
		if spec.Position == "live" {
			if lane.Freshness.Kind != "never-polled" {
				t.Errorf("live lane %q pre-first-poll freshness = %q, want never-polled", spec.ID, lane.Freshness.Kind)
			}
		} else {
			if lane.Freshness.Kind != "not-applicable" {
				t.Errorf("dark/bagged lane %q freshness = %q, want not-applicable", spec.ID, lane.Freshness.Kind)
			}
		}
	}
	if snap.AsOf != nil {
		t.Errorf("asOf pre-first-poll must be null, got %v", *snap.AsOf)
	}
	if snap.Seq != 0 {
		t.Errorf("seq pre-first-poll = %d, want 0", snap.Seq)
	}
}

// TestPollOnceEmptyStoreIsFresh: a directory that exists with zero records
// is honest-empty and always fresh (design DR3-5a) - never stale, since
// there is no data to be stale about.
func TestPollOnceEmptyStoreIsFresh(t *testing.T) {
	srv := newTestServer(t, t.TempDir())
	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC)
	snap, changed, err := srv.PollOnce(now)
	if err != nil {
		t.Fatalf("PollOnce: %v", err)
	}
	if !changed {
		t.Fatalf("the first poll must always be a change (never-polled -> fresh)")
	}
	if snap.Seq != 1 {
		t.Fatalf("first real poll's seq = %d, want 1 (seq 0 is the pre-poll placeholder)", snap.Seq)
	}
	for _, l := range snap.Lanes {
		if l.Position != "live" {
			continue
		}
		if l.Freshness.Kind != "fresh" {
			t.Errorf("lane %q on an honest-empty store = %q, want fresh", l.ID, l.Freshness.Kind)
		}
	}
}

// TestPollOnceStaleAfterThreshold: freshness "stale" fires once the newest
// observed record's "at" is older than stalenessMs AND something is
// IN FLIGHT (this fixture's sole record is "dispatched", never returned) -
// regardless of scan success (spec YB-15's staleness-still-fires case,
// pinned generically here; the demoMode-specific version lives in
// demomode_test.go). The #29 "idle" discriminator (freshnessidle_test.go)
// pins the OTHER half: the same age, with NOTHING in flight, renders idle
// instead.
func TestPollOnceStaleAfterThreshold(t *testing.T) {
	root := t.TempDir()
	writeRecord(t, root, "s1/dispatched-1.json", validDispatchedJSON("s1", "2026-07-23T11:59:00Z"))
	srv := newTestServer(t, root)

	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC) // 60s after the record's at, stalenessMs default 15000
	snap, _, err := srv.PollOnce(now)
	if err != nil {
		t.Fatalf("PollOnce: %v", err)
	}
	var dispatchesLane Lane
	for _, l := range snap.Lanes {
		if l.ID == "dispatches" {
			dispatchesLane = l
		}
	}
	if dispatchesLane.Freshness.Kind != "stale" {
		t.Fatalf("dispatches freshness = %q, want stale (record is 60s old, stalenessMs=15000)", dispatchesLane.Freshness.Kind)
	}
	if dispatchesLane.Freshness.AgeBucketMs == nil || *dispatchesLane.Freshness.AgeBucketMs < 15000 {
		t.Fatalf("ageBucketMs = %v, want quantised age >= 15000ms", dispatchesLane.Freshness.AgeBucketMs)
	}
}

// TestPollOnceScanFailureIsFailedWithLastGood: a store directory that
// disappears between polls surfaces as freshness "failed" with lastGood
// carried, never an empty yard rendered as truth (design S6 row 1).
func TestPollOnceScanFailureIsFailedWithLastGood(t *testing.T) {
	root := t.TempDir()
	writeRecord(t, root, "s1/dispatched-1.json", validDispatchedJSON("s1", "2026-07-23T11:59:59Z"))
	srv := newTestServer(t, root)

	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC)
	snap1, _, err := srv.PollOnce(now)
	if err != nil {
		t.Fatalf("first PollOnce: %v", err)
	}
	// #51 C2: capture poll 1's good lane payloads BEFORE deleting the store,
	// so the assertion below can confirm poll 2 retains the SAME payload
	// (docs/contracts/state-ledger.md:102 already claims "the previous good
	// lane DATA stays current" for lastGoodSnapshot - this test is the pin
	// that claim never had).
	goodData := map[string]any{}
	for _, l := range snap1.Lanes {
		if l.Position == "live" {
			goodData[l.ID] = l.Data
		}
	}

	if err := os.RemoveAll(root); err != nil {
		t.Fatalf("removing store dir: %v", err)
	}
	snap2, _, err := srv.PollOnce(now.Add(1 * time.Second))
	if err != nil {
		t.Fatalf("second PollOnce must succeed at the SERVER level even though the scan itself failed: %v", err)
	}
	for _, l := range snap2.Lanes {
		if l.Position != "live" {
			continue
		}
		if l.Freshness.Kind != "failed" {
			t.Fatalf("lane %q freshness = %q, want failed once the store directory vanishes", l.ID, l.Freshness.Kind)
		}
		if l.Freshness.LastGoodAsOf == nil {
			t.Errorf("lane %q failed freshness must carry lastGoodAsOf, got nil", l.ID)
		}
		wantData := goodData[l.ID]
		if wantData == nil {
			continue // this lane had no data in poll 1 either; nothing to retain
		}
		if !reflect.DeepEqual(l.Data, wantData) {
			t.Errorf("lane %q Data on scan failure = %#v, want the RETAINED poll-1 payload %#v (design S6 row 1 / state-ledger.md:102: failed lane carries lastGood VISIBLY MARKED, never an empty payload)", l.ID, l.Data, wantData)
		}
	}
}

// TestPollOnceFirstEverPollFailsKeepsDataNil pins the OTHER branch of #51
// C2: when the very first poll ever run scans a missing directory, there is
// no prior good payload to retain - lane.Data must stay nil (honest-empty,
// never a fabricated payload).
func TestPollOnceFirstEverPollFailsKeepsDataNil(t *testing.T) {
	root := filepath.Join(t.TempDir(), "does-not-exist")
	srv := newTestServer(t, root)

	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC)
	snap, _, err := srv.PollOnce(now)
	if err != nil {
		t.Fatalf("PollOnce must succeed at the server level even though the scan itself failed: %v", err)
	}
	for _, l := range snap.Lanes {
		if l.Position != "live" {
			continue
		}
		if l.Freshness.Kind != "failed" {
			t.Fatalf("lane %q freshness = %q, want failed", l.ID, l.Freshness.Kind)
		}
		if l.Data != nil {
			t.Errorf("lane %q Data = %#v, want nil on the FIRST-EVER poll failure (no prior good data exists to show)", l.ID, l.Data)
		}
	}
}

// TestPollOnceChangeDetectionExcludesSeqAsOfIncludesFreshnessKind: design
// S5.6 - a poll whose only difference from the prior comparable state is the
// bare passage of time (asOf ticking forward, ageBucketMs unchanged) is NOT
// a change; seq must not bump on every tick.
func TestPollOnceChangeDetectionExcludesSeqAsOfIncludesFreshnessKind(t *testing.T) {
	root := t.TempDir()
	writeRecord(t, root, "s1/dispatched-1.json", validDispatchedJSON("s1", "2026-07-23T10:00:00Z"))
	srv := newTestServer(t, root)

	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC)
	snap1, changed1, err := srv.PollOnce(now)
	if err != nil || !changed1 {
		t.Fatalf("first poll: snap=%+v changed=%v err=%v", snap1, changed1, err)
	}

	// A tiny clock advance that does NOT cross an age-bucket boundary and
	// changes nothing else must NOT be treated as a change.
	snap2, changed2, err := srv.PollOnce(now.Add(1 * time.Millisecond))
	if err != nil {
		t.Fatalf("second poll: %v", err)
	}
	if changed2 {
		t.Fatalf("a poll differing only in raw timestamps (asOf) must not be a change; seq stayed %d then jumped to %d", snap1.Seq, snap2.Seq)
	}
	if snap2.Seq != snap1.Seq {
		t.Fatalf("seq must not bump on a no-op poll: got %d then %d", snap1.Seq, snap2.Seq)
	}

	// Now add a NEW record - a real change, must bump seq.
	writeRecord(t, root, "s2/dispatched-1.json", validDispatchedJSON("s2", "2026-07-23T10:01:00Z"))
	snap3, changed3, err := srv.PollOnce(now.Add(2 * time.Millisecond))
	if err != nil {
		t.Fatalf("third poll: %v", err)
	}
	if !changed3 {
		t.Fatalf("adding a new record must be detected as a change")
	}
	if snap3.Seq != snap1.Seq+1 {
		t.Fatalf("seq after a real change = %d, want %d", snap3.Seq, snap1.Seq+1)
	}
}

// TestChangeDetectionFiresOnAgeBucketBoundaryCrossing (C4R-3, Car 4 review
// round 1, Minor): mustMarshalStripped keeps freshness.kind/ageBucketMs and
// strips only raw timestamps, so INCLUSION of ageBucketMs in change
// detection is correct by construction - but nothing pinned the direction
// that matters: a lane whose age crosses a 5000ms bucket boundary between
// two polls (poll.go's ageBucketMsGranularity) must be seen as a real
// change and bump seq, even though nothing else about the store changed at
// all.
//
// The fixture is deliberately a RETURNED record, not a dispatched one: a
// "dispatched" winner's elapsed_seconds recomputes every poll (fold.go),
// which is NOT stripped by mustMarshalStripped and would confound this test
// with a second, unrelated churn source (elapsed_seconds itself changes
// every second, independent of ageBucketMs's 5-second quantisation) -
// caught while writing this exact test (observed live: a dispatched fixture
// bumped seq on a same-bucket 1-second gap purely from elapsed_seconds
// ticking). Disclosed as its own finding in this car's report, out of this
// fix cycle's stated scope (which asked only for the ageBucketMs-crossing
// pin, not a redesign of elapsed_seconds churn) - a "returned" record has no
// elapsed_seconds field at all (fold.go's DispatchEntry.MarshalJSON), so
// this fixture isolates EXACTLY the ageBucketMs variable the review named.
//
// #29 UPDATE (2026-07-26): this fixture's sole record is RETURNED - nothing
// is in flight - so under the #29 fix an aged-out freshness now reads
// "idle", not "stale" (a returned-only yard at rest is calm, never hot).
// The kind name changed; the ageBucketMs-crossing MECHANISM this test pins
// did not - "idle" carries ageBucketMs exactly like "stale" does
// (computeLiveFreshness, poll.go), so the bucket-crossing assertions below
// are unchanged in shape, only in the expected kind string.
func TestChangeDetectionFiresOnAgeBucketBoundaryCrossing(t *testing.T) {
	root := t.TempDir()
	writeRecord(t, root, "s1/returned-1.json", `{
		"schema": "starcar-artifact/1",
		"kind": "returned",
		"subject": "s1",
		"session_id": "session-1",
		"at": "2026-07-23T10:00:00Z",
		"outcome": "done",
		"findings": "f",
		"abstract": "a",
		"normalisation": [],
		"integrity": "sha256:0000000000000000000000000000000000000000000000000000000000000000"
	}`)
	srv := newTestServer(t, root)

	recordAt := time.Date(2026, 7, 23, 10, 0, 0, 0, time.UTC)

	// age = 16s -> idle (stalenessMs default 15000; nothing in flight - the
	// sole record is RETURNED), ageBucketMs = 15000.
	now1 := recordAt.Add(16 * time.Second)
	snap1, changed1, err := srv.PollOnce(now1)
	if err != nil || !changed1 {
		t.Fatalf("first poll: snap=%+v changed=%v err=%v", snap1, changed1, err)
	}
	lane1 := laneByID(snap1, "dispatches")
	if lane1.Freshness.Kind != "idle" || lane1.Freshness.AgeBucketMs == nil || *lane1.Freshness.AgeBucketMs != 15000 {
		t.Fatalf("test setup: expected idle/ageBucketMs=15000, got %+v", lane1.Freshness)
	}

	// age = 21s -> STILL idle, but ageBucketMs = 20000 - a bucket crossing
	// with NOTHING ELSE in the store having changed (a "returned" record's
	// wire shape carries no elapsed_seconds, so it is byte-identical here
	// apart from the bucket). This must still bump seq: ageBucketMs is
	// included in change detection, by name, per design S5.6 and this
	// package's own mustMarshalStripped doc comment.
	now2 := recordAt.Add(21 * time.Second)
	snap2, changed2, err := srv.PollOnce(now2)
	if err != nil {
		t.Fatalf("second poll: %v", err)
	}
	lane2 := laneByID(snap2, "dispatches")
	if lane2.Freshness.AgeBucketMs == nil || *lane2.Freshness.AgeBucketMs != 20000 {
		t.Fatalf("test setup: expected the second poll's ageBucketMs=20000 (a real bucket crossing), got %v", lane2.Freshness.AgeBucketMs)
	}
	if !changed2 {
		t.Fatalf("a bucket-boundary crossing (ageBucketMs 15000 -> 20000) must be detected as a change, even with no other difference in the store")
	}
	if snap2.Seq != snap1.Seq+1 {
		t.Fatalf("seq after a bucket crossing = %d, want %d", snap2.Seq, snap1.Seq+1)
	}

	// Control: a further advance that stays WITHIN the current bucket (age
	// 22s -> still bucket 20000, same as snap2's) must NOT be a change -
	// proving the crossing above is really about the bucket boundary, not
	// merely "any later poll at all".
	now3 := recordAt.Add(22 * time.Second)
	snap3, changed3, err := srv.PollOnce(now3)
	if err != nil {
		t.Fatalf("third poll: %v", err)
	}
	if changed3 {
		t.Fatalf("a same-bucket advance (22s, still bucket 20000) must NOT be a change; seq stayed %d then moved to %d", snap2.Seq, snap3.Seq)
	}
}

// TestLastPollAtLedgerField: plan task 4.4's lastPollAt ledger row - nil
// before any poll, and set to the injected "now" after each PollOnce call
// (including a poll whose scan FAILS - lastPollAt records that an attempt
// was made, distinct from lastGoodSnapshot's asOf which only advances on
// success).
func TestLastPollAtLedgerField(t *testing.T) {
	srv := newTestServer(t, t.TempDir())
	if got := srv.LastPollAt(); got != nil {
		t.Fatalf("LastPollAt before any poll = %v, want nil", got)
	}

	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC)
	if _, _, err := srv.PollOnce(now); err != nil {
		t.Fatalf("PollOnce: %v", err)
	}
	got := srv.LastPollAt()
	if got == nil || !got.Equal(now) {
		t.Fatalf("LastPollAt after a poll = %v, want %v", got, now)
	}
}

// TestSkipNotQueueGuard: design S5.6's pollInFlight - a second poll attempt
// while one is already running is SKIPPED, never queued.
func TestSkipNotQueueGuard(t *testing.T) {
	srv := newTestServer(t, t.TempDir())
	if !srv.TryBeginPoll() {
		t.Fatal("the first TryBeginPoll must succeed")
	}
	if srv.TryBeginPoll() {
		t.Fatal("a second TryBeginPoll while one is in flight must be REFUSED (skip-not-queue), not accepted")
	}
	srv.EndPoll()
	if !srv.TryBeginPoll() {
		t.Fatal("after EndPoll, a new poll attempt must succeed again")
	}
	srv.EndPoll()
}

// TestSkipNotQueueGuardConcurrentClaimIsExclusive pins #52 C51R-5 (fix
// cycle round 2, MAJOR-1): the single-poll invariant that
// lastGoodAsOf/lastGoodLaneData (poll.go's Server struct, declared just
// above pollInFlight) rely on instead of s.mu - PollOnce is only ever
// safe to run unsynchronized because RunPollLoop never launches a second
// one while the first is still in flight. This test races N goroutines
// at TryBeginPoll's CAS simultaneously - the same claim RunPollLoop makes
// before spawning PollOnce - and pins that EXACTLY ONE of them ever wins
// the claim, never zero, never more than one. If a future change
// weakened the CAS (e.g. a non-atomic read-then-write, or a guard that a
// second RunPollLoop could bypass), this test fails by counting winners
// != 1, which a sequential test like TestSkipNotQueueGuard above cannot
// observe. For the authoritative file:line citations of RunPollLoop and
// TryBeginPoll's CAS, see the invariant comment above pollInFlight in
// poll.go - deferring here rather than keeping a second, driftable copy
// of line numbers (a prior round of this comment cited the wrong lines
// for both and was rejected for it).
func TestSkipNotQueueGuardConcurrentClaimIsExclusive(t *testing.T) {
	srv := newTestServer(t, t.TempDir())
	const n = 50
	var wg sync.WaitGroup
	var winners int32
	start := make(chan struct{})
	for i := 0; i < n; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			<-start
			if srv.TryBeginPoll() {
				atomic.AddInt32(&winners, 1)
			}
		}()
	}
	close(start)
	wg.Wait()
	if winners != 1 {
		t.Fatalf("TryBeginPoll winners under %d-way concurrent claim = %d, want exactly 1 (the single-poll invariant lastGoodAsOf/lastGoodLaneData depend on instead of s.mu)", n, winners)
	}
	srv.EndPoll()
}

// TestStatelessRestartableSameContentDifferentInstance: design S5.1 - two
// independently constructed Server instances pointed at the SAME store
// produce identical snapshot CONTENT (seq excepted, and here even seq
// matches since both are fresh instances) - restarting the process loses
// nothing because nothing was ever held anywhere but the store.
func TestStatelessRestartableSameContentDifferentInstance(t *testing.T) {
	root := t.TempDir()
	writeRecord(t, root, "s1/dispatched-1.json", validDispatchedJSON("s1", "2026-07-23T10:00:00Z"))
	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC)

	srvA := newTestServer(t, root)
	snapA, _, err := srvA.PollOnce(now)
	if err != nil {
		t.Fatalf("server A poll: %v", err)
	}

	srvB := newTestServer(t, root) // a brand new instance - simulates a restart
	snapB, _, err := srvB.PollOnce(now)
	if err != nil {
		t.Fatalf("server B poll: %v", err)
	}

	bytesA, err := marshalSnapshot(snapA)
	if err != nil {
		t.Fatalf("marshal A: %v", err)
	}
	bytesB, err := marshalSnapshot(snapB)
	if err != nil {
		t.Fatalf("marshal B: %v", err)
	}
	if string(bytesA) != string(bytesB) {
		t.Fatalf("a restarted server against the SAME store must produce byte-identical content:\nA: %s\nB: %s", bytesA, bytesB)
	}
}

// TestRestartMidPollIsEquivalentToNeverStarted: spec S6's "restart mid-poll"
// lifecycle event - because nothing persists between processes (no on-disk
// server state), a process killed mid-poll and a process that never polled
// are indistinguishable to the NEXT process; a fresh instance's first poll
// is unaffected either way.
func TestRestartMidPollIsEquivalentToNeverStarted(t *testing.T) {
	root := t.TempDir()
	writeRecord(t, root, "s1/dispatched-1.json", validDispatchedJSON("s1", "2026-07-23T10:00:00Z"))

	killedMidPoll := newTestServer(t, root)
	killedMidPoll.TryBeginPoll() // begin a poll, then simulate a hard kill - never call PollOnce or EndPoll

	freshAfterRestart := newTestServer(t, root)
	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC)
	snap, changed, err := freshAfterRestart.PollOnce(now)
	if err != nil {
		t.Fatalf("PollOnce after a simulated mid-poll kill: %v", err)
	}
	if !changed || snap.Seq != 1 {
		t.Fatalf("a fresh process's first poll must behave exactly as if nothing ever happened: changed=%v seq=%d", changed, snap.Seq)
	}
}

func validDispatchedJSON(subject, at string) string {
	return `{
		"schema": "starcar-artifact/1",
		"kind": "dispatched",
		"subject": "` + subject + `",
		"session_id": "session-1",
		"at": "` + at + `",
		"normalisation": [],
		"integrity": "sha256:0000000000000000000000000000000000000000000000000000000000000000"
	}`
}
