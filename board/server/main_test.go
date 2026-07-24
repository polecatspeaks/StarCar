package main

import (
	"context"
	"net/http"
	"testing"
	"time"
)

// TestRunShutsDownOnContextCancel pins #51 C4: signal.NotifyContext feeds
// ctx into RunPollLoop, but before this fix ctx was never wired to the HTTP
// server, so http.ListenAndServe never returned on interrupt - the process
// became a zombie serving an ever-staler snapshot. run() (main.go) is the
// extracted seam this test exercises directly: cancelling ctx must (a)
// cause run() to RETURN within a bounded time and (b) leave the listener
// refusing new connections - a real subsequent dial, not merely a
// Shutdown-was-called assertion.
func TestRunShutsDownOnContextCancel(t *testing.T) {
	cfg := testConfig(t, t.TempDir())
	cfg.Host = "127.0.0.1"
	cfg.Port = 0 // ephemeral - avoids colliding with a real running board server

	ctx, cancel := context.WithCancel(context.Background())
	ready := make(chan string, 1)
	errCh := make(chan error, 1)
	go func() {
		errCh <- run(ctx, cfg, ready)
	}()

	var addr string
	select {
	case addr = <-ready:
	case <-time.After(5 * time.Second):
		t.Fatal("run() never signalled ready - did not start listening")
	}

	// Confirm the server actually serves before we cancel anything.
	resp, err := http.Get("http://" + addr + "/api/snapshot")
	if err != nil {
		t.Fatalf("GET /api/snapshot before cancel: %v", err)
	}
	resp.Body.Close()

	cancel()

	select {
	case err := <-errCh:
		if err != nil {
			t.Fatalf("run() returned a non-nil error after context cancel: %v", err)
		}
	case <-time.After(2 * time.Second):
		t.Fatal("run() did not return within 2s of context cancellation - the process would be a zombie on a real Ctrl+C")
	}

	// The listener must actually stop accepting - not merely have Shutdown
	// called on it (a config read-back is an assertion, not an observation).
	deadline := time.Now().Add(2 * time.Second)
	var lastErr error
	for time.Now().Before(deadline) {
		_, dialErr := http.Get("http://" + addr + "/api/snapshot")
		if dialErr != nil {
			return // observed: connection refused/closed - the server truly stopped
		}
		lastErr = dialErr
		time.Sleep(20 * time.Millisecond)
	}
	t.Fatalf("server at %s still accepted connections 2s after run() returned (lastErr=%v) - it is a zombie", addr, lastErr)
}
