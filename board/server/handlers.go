package main

import (
	"net/http"
	"path/filepath"
	"time"
)

// registerHandlers wires the routes task 4.3 named (GET /api/snapshot,
// GET /api/stream) plus what Car 5 (plan section 6) adds to close the
// walking skeleton: GET / and every board/web/ static asset (index.html,
// js/*.js, vendor/**, css/*.css), and GET /schema/yard-snapshot.schema.json
// so the browser's validator consumes THE schema file itself, never a
// hand-maintained copy under board/web/ (design rev 5 S5.4 item 2, D15 -
// "a hand-maintained mirror anywhere is a finding").
func registerHandlers(mux *http.ServeMux, srv *Server) {
	mux.HandleFunc("/api/snapshot", srv.handleSnapshot)
	mux.HandleFunc("/api/stream", srv.handleStream)
	mux.HandleFunc("/schema/yard-snapshot.schema.json", srv.handleWireSchema)
	mux.Handle("/", http.FileServer(http.Dir(srv.cfg.WebDir)))
}

// handleSnapshot and handleStream both call marshalSnapshot (snapshot.go) -
// the ONE marshal path (design S5.4 item 5) - so their bytes for the same
// Snapshot value are identical by construction, pinned by
// TestSnapshotAndStreamShareOneMarshalPath (handlers_test.go)'s byte-identity
// test.
func (s *Server) handleSnapshot(w http.ResponseWriter, r *http.Request) {
	data, err := marshalSnapshot(s.CurrentSnapshot())
	if err != nil {
		http.Error(w, "could not marshal the snapshot", http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(data)
}

func (s *Server) handleStream(w http.ResponseWriter, r *http.Request) {
	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "streaming unsupported", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")
	w.WriteHeader(http.StatusOK)

	// #51 C3: register BEFORE marshalling/sending the initial snapshot, so
	// a poll's broadcast that lands in the gap between this client's
	// snapshot read and its subscription cannot be missed. A duplicate
	// current frame arriving via ch after the initial send is harmless -
	// the client rejects any non-increasing seq (board/web/js/ingest.js:59:
	// "if (typeof payload.seq === 'number' && payload.seq <= state.
	// lastAppliedSeq)" is a no-op).
	ch := s.subs.register()
	defer s.subs.unregister(ch)
	if s.testStreamOrderHook != nil {
		s.testStreamOrderHook("register-done")
	}

	initial, err := marshalSnapshot(s.CurrentSnapshot())
	if err == nil {
		writeSSEFrame(w, initial)
		flusher.Flush()
	}
	if s.testStreamOrderHook != nil {
		s.testStreamOrderHook("initial-send-done")
	}
	if s.testStreamOrderHook != nil {
		s.testStreamOrderHook("register-done")
	}

	heartbeat := time.NewTicker(time.Duration(s.cfg.HeartbeatMs) * time.Millisecond)
	defer heartbeat.Stop()

	ctx := r.Context()
	for {
		select {
		case <-ctx.Done():
			return
		case data, ok := <-ch:
			if !ok {
				return
			}
			if err := writeSSEFrame(w, data); err != nil {
				return
			}
			flusher.Flush()
		case <-heartbeat.C:
			if err := writeSSEHeartbeat(w); err != nil {
				return
			}
			flusher.Flush()
		}
	}
}

// handleWireSchema serves schema/yard-snapshot.schema.json byte-for-byte
// from disk - the SAME file board/store's Go-side adapter compiles
// (cfg.SchemaDir), never a second copy vendored under board/web/. The
// browser's validator (board/web/js/validate.js) fetches this route at
// startup (design rev 5 S5.4 item 2: "a hand-maintained mirror anywhere is
// a finding").
func (s *Server) handleWireSchema(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, filepath.Join(s.cfg.SchemaDir, "yard-snapshot.schema.json"))
}
