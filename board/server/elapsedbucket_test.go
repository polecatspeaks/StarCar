package main

import (
	"testing"
	"time"

	"github.com/polecatspeaks/StarCar/board/assemble"
)

// TestPollOnceElapsedSecondsBucketedForChangeDetection is issue #27's
// red-first pin: an in-flight ("dispatched") winner's elapsed_seconds
// recomputes every poll from now-at (board/fold/algorithm.go:221-222) and,
// before this fix, mustMarshalStripped (poll.go) included that raw,
// continuously-increasing value in its comparison basis unbucketed - so seq
// bumped on nearly every poll while any dispatch sat in flight, defeating
// change detection's idle-costs-nothing purpose for exactly the periods the
// board is busiest (design D9; the pre-fix gap was disclosed at
// poll.go:399-412 as of base commit 8b9df53 - `git show
// 8b9df53:board/server/poll.go` - that comment was superseded by this fix
// and no longer exists at HEAD, so no current-file coordinate is cited).
//
// The fix quantises elapsed_seconds for the CHANGE-DETECTION COMPARISON ONLY
// (mirroring ageBucketMs's own precedent, the `ageBucketMsGranularity` const
// just above `elapsedSecondsBucketGranularity` in poll.go) - order-of-minutes
// granularity (elapsedSecondsBucketGranularity, poll.go). The WIRE value
// stays exact whenever a snapshot IS served fresh: dom-writer.js's
// renderDispatches solari-elapsed span renders elapsed_seconds verbatim to
// the second (cited by symbol, not line - a prior line-wrapped citation
// here, "dom-writer.js:201", went stale and defeated a basename grep for
// it), never a rounded bucket number - proven at the bucket crossing below (snap3, 65s
// exact, not rounded to 60). Between crossings, `PollOnce`'s own doc comment
// already governs what a "no real change" poll serves ("the prior snapshot
// stands unchanged" - cited by symbol, not line: this comment shifts every
// time an unrelated edit lands above it in the file, which a hardcoded line
// range does not survive) - the same rule ageBucketMs already relies on
// between ITS 5s crossings: this test's middle poll (snap2) asserts that
// pre-existing behavior holds for elapsed_seconds too. GENERAL RULE (R2-M1,
// 2026-07-26): this applies doubly to a citation INTO a file the SAME
// commit is editing - such a coordinate must be re-derived after the
// edit lands, or it must be expressed as a symbol/description instead,
// because the citing comment and its target can shift by different
// amounts in the same diff and no amount of care catches that by eye.
//
// cfg.StalenessMs is raised well past every elapsed value this test uses so
// the live lane's freshness.kind stays "fresh" throughout (never "stale") -
// "fresh" carries no ageBucketMs field at all (schema oneOf), which is the
// SAME isolation trick TestChangeDetectionFiresOnAgeBucketBoundaryCrossing
// used in reverse (a RETURNED fixture, there, to keep elapsed_seconds out of
// that test's way): here it keeps ageBucketMs crossings out of THIS test's
// way, so any observed seq bump is attributable ONLY to elapsed_seconds'
// own bucket, never to the freshness axis (`computeLiveFreshness`, cited by
// symbol for the same reason as `PollOnce` above).
func TestPollOnceElapsedSecondsBucketedForChangeDetection(t *testing.T) {
	root := t.TempDir()
	recordAt := time.Date(2026, 7, 24, 0, 0, 0, 0, time.UTC)
	// No "budget" field and no DefaultsPath configured below, so this record
	// never promotes to "overdue" - it stays "dispatched" for the whole test,
	// isolating the elapsed_seconds bucket from a second real state change.
	writeRecord(t, root, "s1/dispatched-1.json", validDispatchedJSON("s1", recordAt.Format(time.RFC3339)))

	cfg := testConfig(t, root)
	cfg.StalenessMs = 120000 // 120s - past every elapsed value below, so freshness.kind stays "fresh" (no ageBucketMs) the whole test
	srv, err := NewServer(cfg)
	if err != nil {
		t.Fatalf("NewServer: %v", err)
	}

	dispatchElapsed := func(snap Snapshot) float64 {
		t.Helper()
		lane := laneByID(snap, "dispatches")
		payload, ok := lane.Data.(assemble.DispatchesPayload)
		if !ok || len(payload.Dispatches) != 1 {
			t.Fatalf("expected exactly 1 dispatch entry as an assemble.DispatchesPayload, got %#v", lane.Data)
		}
		v, ok := payload.Dispatches[0]["elapsed_seconds"].(float64)
		if !ok {
			t.Fatalf("elapsed_seconds missing or not a number: %#v", payload.Dispatches[0])
		}
		return v
	}

	// now1: elapsed = 10s (bucket 0).
	snap1, changed1, err := srv.PollOnce(recordAt.Add(10 * time.Second))
	if err != nil || !changed1 {
		t.Fatalf("first poll: snap=%+v changed=%v err=%v", snap1, changed1, err)
	}
	if lane := laneByID(snap1, "dispatches"); lane.Freshness.Kind != "fresh" {
		t.Fatalf("test setup: expected freshness fresh (isolating from ageBucketMs), got %+v", lane.Freshness)
	}
	if got := dispatchElapsed(snap1); got != 10 {
		t.Fatalf("test setup: expected wire elapsed_seconds=10 at now1, got %v", got)
	}

	// now2: elapsed = 50s - still bucket 0 (50/60==0), a real, continuous
	// change to the raw value, but WITHIN the comparison bucket. Must NOT be
	// seen as a change: this is the churn issue #27 names. Per `PollOnce`'s
	// own doc comment ("otherwise the prior snapshot stands unchanged",
	// cited by symbol, not line - see this file's header comment above) -
	// the SAME rule ageBucketMs already relies on between its own 5s
	// crossings - the served snapshot when nothing changed is the
	// PRIOR one, unmodified: elapsed_seconds reads snap1's value (10), not
	// a bucketed round number and not the new raw 50 - proving the fix
	// quantises the COMPARISON only and never mutates a served value.
	snap2, changed2, err := srv.PollOnce(recordAt.Add(50 * time.Second))
	if err != nil {
		t.Fatalf("second poll: %v", err)
	}
	if changed2 {
		t.Fatalf("elapsed_seconds moving 10->50 (same 60s bucket) must NOT bump seq; seq stayed %d then moved to %d", snap1.Seq, snap2.Seq)
	}
	if snap2.Seq != snap1.Seq {
		t.Fatalf("seq must not bump on a within-bucket elapsed_seconds change: got %d then %d", snap1.Seq, snap2.Seq)
	}
	if got := dispatchElapsed(snap2); got != 10 {
		t.Fatalf("an undetected-change poll must serve the PRIOR snapshot untouched (elapsed_seconds=10, snap1's value) - got %v", got)
	}

	// now3: elapsed = 65s - crosses into bucket 60. A real change must be
	// detected and seq must bump, even though nothing else in the store
	// changed (the record is still "dispatched", never "overdue").
	snap3, changed3, err := srv.PollOnce(recordAt.Add(65 * time.Second))
	if err != nil {
		t.Fatalf("third poll: %v", err)
	}
	if got := dispatchElapsed(snap3); got != 65 {
		t.Fatalf("test setup: expected wire elapsed_seconds=65 at now3, got %v", got)
	}
	if !changed3 {
		t.Fatalf("elapsed_seconds crossing a 60s bucket boundary (50->65) must bump seq, even with nothing else changed")
	}
	if snap3.Seq != snap2.Seq+1 {
		t.Fatalf("seq after a bucket crossing = %d, want %d", snap3.Seq, snap2.Seq+1)
	}
	if lane := laneByID(snap3, "dispatches"); lane.Freshness.Kind != "fresh" {
		t.Fatalf("test setup: expected freshness STILL fresh at now3 (65s < 120s staleness), got %+v - a stale flip here would confound attribution to the elapsed bucket", lane.Freshness)
	}
}
