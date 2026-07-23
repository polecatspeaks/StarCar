package main

import (
	"net/http"
	"time"
)

// registerHandlers wires the three routes plan task 4.3 names: GET /,
// GET /api/snapshot, GET /api/stream - nothing else.
func registerHandlers(mux *http.ServeMux, srv *Server) {
	mux.HandleFunc("/api/snapshot", srv.handleSnapshot)
	mux.HandleFunc("/api/stream", srv.handleStream)
	mux.HandleFunc("/", srv.handleIndex)
}

// handleSnapshot and handleStream both call marshalSnapshot (snapshot.go) -
// the ONE marshal path (design S5.4 item 5) - so their bytes for the same
// Snapshot value are identical by construction, pinned by
// sse_test.go's byte-identity test.
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

	initial, err := marshalSnapshot(s.CurrentSnapshot())
	if err == nil {
		writeSSEFrame(w, initial)
		flusher.Flush()
	}

	ch := s.subs.register()
	defer s.subs.unregister(ch)

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

// handleIndex is a placeholder "/" response - Car 5 (plan section 6) builds
// the real board/web/ view; this server's job (task 4.3) is GET /, GET
// /api/snapshot, GET /api/stream, nothing else.
func (s *Server) handleIndex(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.Write([]byte(`<!doctype html><html><head><title>StarCar yard board</title></head>` +
		`<body><p>The yard board server is running. The view (board/web/) lands with Car 5.` +
		` See <a href="/api/snapshot">/api/snapshot</a>.</p></body></html>`))
}
