package main

import (
	"strings"
	"testing"
	"time"
)

// TestFoldDiscoveriesAndFaultsSurfaceAsBoardConditions: design S6 - "an
// unrecognised kind/outcome ... rendered loudly BY NAME, register
// needs-attention - a discovery, not a bug" and "a vocabulary fault -> ONE
// board condition". The fold's own Discoveries/Faults must reach the wire's
// board conditions list; otherwise the detector's whole reason for existing
// (Law 1 - never render an unknown as if it were known) is computed and
// then silently thrown away by this server.
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
		if c.Register == "needs-attention" && strings.Contains(c.Detail, "some-unrecognised-kind") {
			found = true
		}
	}
	if !found {
		t.Fatalf("an unrecognised kind must render loudly by name as a board condition; got board=%v", snap.Board)
	}
}
