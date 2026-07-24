package main

import (
	"bufio"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"
)

func newTestHTTPServer(t *testing.T, storeRoot string) (*Server, *httptest.Server) {
	t.Helper()
	srv := newTestServer(t, storeRoot)
	mux := http.NewServeMux()
	registerHandlers(mux, srv)
	ts := httptest.NewServer(mux)
	t.Cleanup(ts.Close)
	return srv, ts
}

// TestSnapshotAndStreamShareOneMarshalPath (design S5.4 item 5): /api/snapshot
// and the first frame of /api/stream must be byte-identical for the same
// underlying Snapshot - proof there is ONE marshal path, never two.
func TestSnapshotAndStreamShareOneMarshalPath(t *testing.T) {
	root := t.TempDir()
	writeRecord(t, root, "s1/dispatched-1.json", validDispatchedJSON("s1", "2026-07-23T10:00:00Z"))
	srv, ts := newTestHTTPServer(t, root)
	if _, _, err := srv.PollOnce(time.Date(2026, 7, 23, 10, 0, 5, 0, time.UTC)); err != nil {
		t.Fatalf("PollOnce: %v", err)
	}

	resp, err := http.Get(ts.URL + "/api/snapshot")
	if err != nil {
		t.Fatalf("GET /api/snapshot: %v", err)
	}
	defer resp.Body.Close()
	snapshotBody, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("reading snapshot body: %v", err)
	}

	streamResp, err := http.Get(ts.URL + "/api/stream")
	if err != nil {
		t.Fatalf("GET /api/stream: %v", err)
	}
	defer streamResp.Body.Close()
	reader := bufio.NewReader(streamResp.Body)
	var eventLine, dataLine string
	for {
		line, err := reader.ReadString('\n')
		if err != nil {
			t.Fatalf("reading SSE stream: %v", err)
		}
		line = strings.TrimRight(line, "\n")
		if strings.HasPrefix(line, "event: ") {
			eventLine = strings.TrimPrefix(line, "event: ")
		}
		if strings.HasPrefix(line, "data: ") {
			dataLine = strings.TrimPrefix(line, "data: ")
			break
		}
	}

	if eventLine != sseEventName {
		t.Fatalf("SSE event name = %q, want %q", eventLine, sseEventName)
	}
	if dataLine != string(snapshotBody) {
		t.Fatalf("snapshot and stream bytes differ:\nsnapshot: %s\nstream:   %s", snapshotBody, dataLine)
	}
}

// TestHandleStreamRegistersBeforeInitialSend pins #51 C3: handleStream must
// register this client's subscriber channel BEFORE marshalling/sending the
// initial snapshot frame, so a poll's broadcast that lands in the gap
// cannot land on a subscriber set that does not yet contain this client (a
// missed broadcast the client would otherwise sit on, stale, until some
// LATER unrelated change happened to bump seq again). This is a
// deterministic, non-flaky structural pin via testStreamOrderHook
// (board/server/poll.go) rather than a real network race, which would be
// inherently timing-dependent and could pass or fail depending on
// scheduling - not a genuine red/green signal.
func TestHandleStreamRegistersBeforeInitialSend(t *testing.T) {
	srv, ts := newTestHTTPServer(t, t.TempDir())

	var mu sync.Mutex
	var order []string
	srv.testStreamOrderHook = func(stage string) {
		mu.Lock()
		defer mu.Unlock()
		order = append(order, stage)
	}

	req, _ := http.NewRequest(http.MethodGet, ts.URL+"/api/stream", nil)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("connecting: %v", err)
	}
	defer resp.Body.Close()
	reader := bufio.NewReader(resp.Body)
	// Read past the initial frame so both checkpoints have definitely fired.
	for i := 0; i < 3; i++ {
		if _, err := reader.ReadString('\n'); err != nil {
			break
		}
	}

	deadline := time.Now().Add(2 * time.Second)
	for {
		mu.Lock()
		got := len(order)
		mu.Unlock()
		if got >= 2 || time.Now().After(deadline) {
			break
		}
		time.Sleep(10 * time.Millisecond)
	}

	mu.Lock()
	defer mu.Unlock()
	if len(order) < 2 {
		t.Fatalf("expected both ordering checkpoints to fire, got %v", order)
	}
	if order[0] != "register-done" {
		t.Fatalf("handleStream ordering = %v, want [\"register-done\", \"initial-send-done\"] - registration must happen BEFORE the initial snapshot is marshalled/sent, so a broadcast landing in the gap is never lost", order)
	}
}

// TestConnectedClientsLedger: state-ledger row connectedClients - it
// increments on connect and decrements on disconnect.
func TestConnectedClientsLedger(t *testing.T) {
	srv, ts := newTestHTTPServer(t, t.TempDir())
	if srv.subs.count() != 0 {
		t.Fatalf("connectedClients before any client = %d, want 0", srv.subs.count())
	}

	req, _ := http.NewRequest(http.MethodGet, ts.URL+"/api/stream", nil)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("connecting: %v", err)
	}
	reader := bufio.NewReader(resp.Body)
	// Read past the initial frame so registration has definitely happened.
	for i := 0; i < 3; i++ {
		if _, err := reader.ReadString('\n'); err != nil {
			break
		}
	}

	deadline := time.Now().Add(2 * time.Second)
	for srv.subs.count() == 0 && time.Now().Before(deadline) {
		time.Sleep(10 * time.Millisecond)
	}
	if srv.subs.count() != 1 {
		t.Fatalf("connectedClients after one connect = %d, want 1", srv.subs.count())
	}

	resp.Body.Close()
	deadline = time.Now().Add(2 * time.Second)
	for srv.subs.count() != 0 && time.Now().Before(deadline) {
		time.Sleep(10 * time.Millisecond)
	}
	if srv.subs.count() != 0 {
		t.Fatalf("connectedClients after disconnect = %d, want 0", srv.subs.count())
	}
}
