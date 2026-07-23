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
			// a slow reader's stale pending frame is replaced by the
			// non-blocking send failing; the reader still gets the
			// connection's next successful broadcast, never a pile-up.
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
