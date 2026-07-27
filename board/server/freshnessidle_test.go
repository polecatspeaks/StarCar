package main

import (
	"testing"
	"time"
)

// TestPollOnceIdleWhenNothingInFlight is issue #29's red-first pin: a store
// whose newest record is old (older than stalenessMs) previously always
// rendered freshness.kind "stale" (computeLiveFreshness, poll.go, pre-fix),
// regardless of whether anything was actually IN FLIGHT. That conflates two
// different truths - "the pipeline stopped moving while a dispatch was
// live and needed to" (an alarm) versus "every dispatch has already
// returned and nothing is expected to change" (a yard at rest) - and
// renders the second one exactly as hot as the first, a confident falsehood
// (Law 1) discovered live (docs/screenshots/2026-07-23-first-light.png).
//
// The fix: computeLiveFreshness now takes the fold's own dispatch entries
// and only renders "stale" when something is IN FLIGHT (State "dispatched"
// or "overdue" - not yet returned, not presumed-lost) AND the data has
// stopped moving; otherwise an old-but-quiet yard renders "idle" - calm,
// nominal register (board/web/js/compose.js), its age still honestly shown
// via the same ageBucketMs field "stale" already carries (no fourth
// register; three-register law unaffected).
func TestPollOnceIdleWhenNothingInFlight(t *testing.T) {
	root := t.TempDir()
	// A single RETURNED record: nothing in flight at all. 60s old at "now",
	// well past the default stalenessMs (15000ms).
	writeRecord(t, root, "s1/returned-1.json", `{
		"schema": "starcar-artifact/1",
		"kind": "returned",
		"subject": "s1",
		"session_id": "session-1",
		"at": "2026-07-23T11:59:00Z",
		"outcome": "done",
		"findings": "f",
		"abstract": "a",
		"normalisation": [],
		"integrity": "sha256:0000000000000000000000000000000000000000000000000000000000000000"
	}`)
	srv := newTestServer(t, root)

	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC) // 60s after the record's at
	snap, _, err := srv.PollOnce(now)
	if err != nil {
		t.Fatalf("PollOnce: %v", err)
	}
	lane := laneByID(snap, "dispatches")
	if lane.Freshness.Kind != "idle" {
		t.Fatalf("freshness.kind = %q, want idle - nothing is in flight (the sole record already returned), so an old, quiet yard must render calm, never stale-hot", lane.Freshness.Kind)
	}
	if lane.Freshness.AgeBucketMs == nil || *lane.Freshness.AgeBucketMs < 15000 {
		t.Fatalf("idle must still honestly carry the server-issued age (ageBucketMs), got %v", lane.Freshness.AgeBucketMs)
	}
	if lane.Freshness.AsOf == nil {
		t.Fatalf("idle must carry asOf like stale does")
	}
}

// TestPollOnceStaleWhenInFlightAndDataStopsMoving is the discriminator
// case: an IN-FLIGHT dispatch (state "dispatched", not yet returned) whose
// data is exactly as old as the idle case above must still render "stale" -
// something IS expected to move and has not, which is the genuine alarm
// case the ticket names ("going stale-hot only when something IS in flight
// and the data stops moving"). Proves the fix discriminates on activity, not
// merely on age.
func TestPollOnceStaleWhenInFlightAndDataStopsMoving(t *testing.T) {
	root := t.TempDir()
	writeRecord(t, root, "s1/dispatched-1.json", validDispatchedJSON("s1", "2026-07-23T11:59:00Z"))
	srv := newTestServer(t, root)

	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC) // 60s after the record's at, same age as the idle case above
	snap, _, err := srv.PollOnce(now)
	if err != nil {
		t.Fatalf("PollOnce: %v", err)
	}
	lane := laneByID(snap, "dispatches")
	if lane.Freshness.Kind != "stale" {
		t.Fatalf("freshness.kind = %q, want stale - a dispatch is IN FLIGHT (not yet returned) and the data has not moved in 60s", lane.Freshness.Kind)
	}
}
