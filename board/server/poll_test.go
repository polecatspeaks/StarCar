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
