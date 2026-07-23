package main

import (
	"os"
	"path/filepath"
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
// observed record's "at" is older than stalenessMs - regardless of scan
// success (spec YB-15's staleness-still-fires case, pinned generically
// here; the demoMode-specific version lives in demomode_test.go).
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
	_, _, err := srv.PollOnce(now)
	if err != nil {
		t.Fatalf("first PollOnce: %v", err)
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
// that matters: a stale lane whose age crosses a 5000ms bucket boundary
// between two polls (poll.go's ageBucketMsGranularity) must be seen as a
// real change and bump seq, even though nothing else about the store
// changed at all.
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

	// age = 16s -> stale (stalenessMs default 15000), ageBucketMs = 15000.
	now1 := recordAt.Add(16 * time.Second)
	snap1, changed1, err := srv.PollOnce(now1)
	if err != nil || !changed1 {
		t.Fatalf("first poll: snap=%+v changed=%v err=%v", snap1, changed1, err)
	}
	lane1 := laneByID(snap1, "dispatches")
	if lane1.Freshness.Kind != "stale" || lane1.Freshness.AgeBucketMs == nil || *lane1.Freshness.AgeBucketMs != 15000 {
		t.Fatalf("test setup: expected stale/ageBucketMs=15000, got %+v", lane1.Freshness)
	}

	// age = 21s -> STILL stale, but ageBucketMs = 20000 - a bucket crossing
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
