package main

import (
	"fmt"
	"io"
	"sync"
)

// subscriberRegistry is the connectedClients state-ledger row (plan task
// 4.4): every currently-connected SSE client gets one channel; broadcast
// fans a changed snapshot out to all of them, never blocking on a slow
// reader (buffered channel, drop-if-full - a wall display that cannot keep
// up gets its NEXT frame, not a queue of stale ones).
type subscriberRegistry struct {
	mu   sync.Mutex
	subs map[chan []byte]struct{}
}

func newSubscriberRegistry() *subscriberRegistry {
	return &subscriberRegistry{subs: map[chan []byte]struct{}{}}
}

func (r *subscriberRegistry) register() chan []byte {
	ch := make(chan []byte, 1)
	r.mu.Lock()
	r.subs[ch] = struct{}{}
	r.mu.Unlock()
	return ch
}

func (r *subscriberRegistry) unregister(ch chan []byte) {
	r.mu.Lock()
	delete(r.subs, ch)
	r.mu.Unlock()
	close(ch)
}

func (r *subscriberRegistry) count() int {
	r.mu.Lock()
	defer r.mu.Unlock()
	return len(r.subs)
}

func (r *subscriberRegistry) broadcast(snap Snapshot) {
	data, err := marshalSnapshot(snap)
	if err != nil {
		return
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	for ch := range r.subs {
		select {
		case ch <- data:
		default:
			// #51 C5: the channel is full (a slow reader has not drained
			// its buffered frame). Drain the stale queued frame and
			// enqueue the new one, under r.mu - the same lock unregister
			// holds while it deletes ch from r.subs (unregister.go:
			// r.mu.Lock(); delete(r.subs, ch); r.mu.Unlock(); THEN
			// close(ch)), so a concurrent unregister cannot complete its
			// delete while this broadcast (which holds r.mu for its
			// entire loop) is running, and close(ch) itself only runs
			// AFTER that delete+unlock - by which point this channel is
			// no longer in r.subs for any broadcast to touch. This send
			// can never race a close. Before this fix, the send above
			// simply failed and nothing replaced it, leaving the STALE
			// frame in place - a consistently slow consumer stayed
			// perpetually one frame behind forever, the opposite of what
			// the old comment here claimed.
			select {
			case <-ch:
			default:
			}
			select {
			case ch <- data:
			default:
				// the buffer was drained by nothing else (only this
				// goroutine, under r.mu, ever reads/writes this slot in
				// the drop path) - unreachable in practice, but never
				// block on it if it somehow is.
			}
		}
	}
}

// writeSSEFrame writes one SSE event frame carrying data as the payload,
// under the event name pinned by the schema constant (sseEventName,
// snapshot.go - tested against schema/yard-snapshot.schema.json's
// $defs.sseEventName.const in sse_const_test.go).
func writeSSEFrame(w io.Writer, data []byte) error {
	_, err := fmt.Fprintf(w, "event: %s\ndata: %s\n\n", sseEventName, data)
	return err
}

// writeSSEHeartbeat writes an SSE comment line (design S5.6: heartbeat
// comments at heartbeatMs; the client flips to disconnected after two
// missed). A comment (":"-prefixed) carries no event/data, so it never
// perturbs a client's last-applied-snapshot state.
func writeSSEHeartbeat(w io.Writer) error {
	_, err := fmt.Fprint(w, ": heartbeat\n\n")
	return err
}
