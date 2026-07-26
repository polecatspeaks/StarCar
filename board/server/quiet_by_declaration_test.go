package main

import (
	"path/filepath"
	"testing"
	"time"
)

// TestRealStoreOutcomeDiscoveriesQuietedByDeclaration pins issue #30 item 4
// ("quiet by declaration", never an ack-list) against the REAL artifacts/
// store, per the design's own directive: derive the fix from observed data,
// never a synthetic fixture standing in for it.
//
// Before this car's vocabulary declaration, PollOnce against the real store
// surfaced exactly two "discovery" board conditions - "outcome: completed"
// and "outcome: approve-for-merge" - both sibling-family outcome words a
// different agent runtime (Copilot, provenance.runtime in the returned
// records) produces, which schema/vocab/outcomes.json predates. Verified
// live at this car's base (4f0182d) by building ./server and reading
// GET /api/snapshot against this repo's own artifacts/ store - see this
// car's report for the exact command and observed output.
//
// This test pins that BOTH have stopped being true: the condition
// disappeared because schema/vocab/outcomes.json (recognition) and
// schema/vocab/board-defs.json (presentation) now declare them, never
// because the discovery mechanism itself was suppressed - an unrelated
// third, still-undeclared value would still surface loudly (the
// TestFoldDiscoveriesAndFaultsSurfaceAsBoardConditions synthetic test,
// discovery_test.go, pins that direction).
func TestRealStoreOutcomeDiscoveriesQuietedByDeclaration(t *testing.T) {
	root := repoRoot(t)
	cfg := testConfig(t, filepath.Join(root, "artifacts"))
	srv, err := NewServer(cfg)
	if err != nil {
		t.Fatalf("NewServer against the real store: %v", err)
	}
	snap, _, err := srv.PollOnce(time.Now().UTC())
	if err != nil {
		t.Fatalf("PollOnce against the real store: %v", err)
	}

	for _, c := range snap.Board {
		if c.Code != "discovery" {
			continue
		}
		if c.Detail == "outcome: completed" || c.Detail == "outcome: approve-for-merge" {
			t.Errorf("the real store still surfaces %q as an undeclared discovery - #30's quiet-by-declaration fix did not land: %+v", c.Detail, c)
		}
	}
}
