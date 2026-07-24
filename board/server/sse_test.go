package main

import (
	"testing"
)

// TestBroadcastReplacesStaleQueuedFrameWithNewest pins #51 C5: on the
// full-channel path, broadcast used to drop the NEWEST frame (the `default:`
// branch's send simply failed and nothing else happened), leaving the
// STALE queued frame in place - a consistently slow consumer stayed
// perpetually one frame behind forever, never catching up. The in-code
// comment claimed the opposite ("a slow reader's stale pending frame is
// replaced by the non-blocking send failing") - a falsehood in the source
// that dies in the same commit as the fix.
//
// This test pins the correct behaviour: broadcast twice without the
// subscriber ever draining its channel; the channel must hold the SECOND
// (newest) frame, not the first.
func TestBroadcastReplacesStaleQueuedFrameWithNewest(t *testing.T) {
	reg := newSubscriberRegistry()
	ch := reg.register()
	defer reg.unregister(ch)

	snap1 := Snapshot{Seq: 1, Lanes: []Lane{}, Board: []WireBoardCondition{}}
	snap2 := Snapshot{Seq: 2, Lanes: []Lane{}, Board: []WireBoardCondition{}}

	reg.broadcast(snap1) // fills the buffer-1 channel
	reg.broadcast(snap2) // channel is now full - this is the drop/replace path

	want, err := marshalSnapshot(snap2)
	if err != nil {
		t.Fatalf("marshalSnapshot(snap2): %v", err)
	}

	select {
	case got := <-ch:
		if string(got) != string(want) {
			snap1Bytes, _ := marshalSnapshot(snap1)
			if string(got) == string(snap1Bytes) {
				t.Fatalf("channel held the STALE first frame (seq=1) after a second broadcast dropped the newest one - a consistently slow consumer would sit one-behind forever")
			}
			t.Fatalf("channel held an unexpected frame: got %s, want %s", got, want)
		}
	default:
		t.Fatal("channel was empty - expected the newest (second) broadcast frame to be queued")
	}
}
