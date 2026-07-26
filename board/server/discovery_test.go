package main

import (
	"strings"
	"testing"
	"time"
)

// TestFoldDiscoveriesAndFaultsSurfaceAsBoardConditions: design S6 - "an
// unrecognised kind/outcome ... rendered loudly BY NAME ... a discovery, not
// a bug" and "a vocabulary fault -> ONE board condition". The fold's own
// Discoveries/Faults must reach the wire's board conditions list; otherwise
// the detector's whole reason for existing (Law 1 - never render an unknown
// as if it were known) is computed and then silently thrown away by this
// server.
//
// REGISTER UPDATED (issue #30, 2026-07-26 owner ruling, SEVERITY PER
// CLASS): a "discovery" is now the design's own NAMED EXAMPLE of a NOTE-
// tier condition class (expected pattern), so it resolves to "nominal", not
// "needs-attention" - the opposite of this test's PRE-#30 assertion. This
// comment (and the assertion below) supersede design rev 5 S6's row
// ("Unrecognised kind/outcome/position/role ... register needs-attention"),
// itself updated in the same commit via docs/design/2026-07-21-v0-yard-
// skeleton-design.md §12b's amendment mechanism - a document is true only
// at the moment of its commit, and this one just stopped being true.
func TestFoldDiscoveriesAndFaultsSurfaceAsBoardConditions(t *testing.T) {
	root := t.TempDir()
	writeRecord(t, root, "s1/dispatched-1.json", `{
		"schema": "starcar-artifact/1",
		"kind": "some-unrecognised-kind",
		"subject": "s1",
		"session_id": "s1",
		"at": "2026-07-23T10:00:00Z",
		"normalisation": [],
		"integrity": "sha256:0000000000000000000000000000000000000000000000000000000000000000"
	}`)
	srv := newTestServer(t, root)
	now := time.Date(2026, 7, 23, 10, 0, 5, 0, time.UTC)
	snap, _, err := srv.PollOnce(now)
	if err != nil {
		t.Fatalf("PollOnce: %v", err)
	}

	var found bool
	for _, c := range snap.Board {
		if c.Code == "discovery" && c.Register == "nominal" && strings.Contains(c.Detail, "some-unrecognised-kind") {
			found = true
		}
	}
	if !found {
		t.Fatalf("an unrecognised kind must render loudly by name as a board condition, NOTE-tier (register nominal, #30); got board=%v", snap.Board)
	}
}
