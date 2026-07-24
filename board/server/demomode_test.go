package main

import (
	"testing"
	"time"
)

// TestDemoModeIsWireDisclosureOnlyAndStalenessStillFires is spec YB-15's
// red-first pair in one test: config.demoMode carries the flag verbatim (the
// view's SOLE consumer, Car 5's banner), and staleness - a truth surface -
// fires IDENTICALLY whether DemoMode is true or false, given IDENTICAL
// (frozen, old) store data. If demoMode suppressed or altered staleness,
// these two runs would diverge; they must not (design: "the design retired
// demo-mode suppression; this field exists to DISCLOSE demo data, never to
// mute anything").
func TestDemoModeIsWireDisclosureOnlyAndStalenessStillFires(t *testing.T) {
	root := t.TempDir()
	// A frozen fixture record, far older than stalenessMs - exactly the
	// "unchanging demo data" scenario spec YB-15 names.
	writeRecord(t, root, "s1/dispatched-1.json", validDispatchedJSON("s1", "2026-07-20T00:00:00Z"))
	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC)

	liveCfg := testConfig(t, root)
	liveCfg.DemoMode = false
	liveSrv, err := NewServer(liveCfg)
	if err != nil {
		t.Fatalf("NewServer (live): %v", err)
	}
	liveSnap, _, err := liveSrv.PollOnce(now)
	if err != nil {
		t.Fatalf("PollOnce (live): %v", err)
	}

	demoCfg := testConfig(t, root)
	demoCfg.DemoMode = true
	demoSrv, err := NewServer(demoCfg)
	if err != nil {
		t.Fatalf("NewServer (demo): %v", err)
	}
	demoSnap, _, err := demoSrv.PollOnce(now)
	if err != nil {
		t.Fatalf("PollOnce (demo): %v", err)
	}

	if liveSnap.Config.DemoMode {
		t.Fatalf("live config.demoMode = true, want false")
	}
	if !demoSnap.Config.DemoMode {
		t.Fatalf("demo config.demoMode = false, want true")
	}

	for _, id := range []string{"dispatches", "gates", "trains"} {
		liveKind := laneByID(liveSnap, id).Freshness.Kind
		demoKind := laneByID(demoSnap, id).Freshness.Kind
		if liveKind != "stale" {
			t.Errorf("live lane %q freshness = %q, want stale (data is 3 days old)", id, liveKind)
		}
		if demoKind != "stale" {
			t.Errorf("demo lane %q freshness = %q, want stale - demoMode must NEVER suppress a truth surface", id, demoKind)
		}
		if liveKind != demoKind {
			t.Errorf("lane %q freshness diverged between live (%q) and demo (%q) - demoMode must not alter staleness", id, liveKind, demoKind)
		}
	}
}

func laneByID(snap Snapshot, id string) Lane {
	for _, l := range snap.Lanes {
		if l.ID == id {
			return l
		}
	}
	return Lane{}
}
