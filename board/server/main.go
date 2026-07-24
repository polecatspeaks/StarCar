// Command server is the yard board's Go server (design rev 5, plan task
// 4.3): the one reader of the artifact store, exposing GET /, GET
// /api/snapshot, and GET /api/stream (SSE) - nothing else. One process,
// stateless-restartable by construction (design S5.1): everything it serves
// is derived from the store on poll.
package main

import (
	"context"
	"log"
	"net"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"strconv"
	"time"
)

// shutdownGraceMs bounds how long run() waits for in-flight requests to
// drain once ctx is cancelled, before forcing http.Server.Shutdown to give
// up and return (a short, fixed timeout - this is not a tunable server
// config value, just a bound on how long a graceful shutdown may take).
const shutdownGraceMs = 5000

// run is #51 C4's extracted seam: main() used to inline this body directly,
// wiring signal.NotifyContext into RunPollLoop but never into the HTTP
// server, so http.ListenAndServe(addr, mux) never returned on interrupt -
// the process became a zombie, still serving an ever-staler snapshot after
// Ctrl+C. run(ctx, cfg, ready) is now the ONE place that wiring lives, and
// it is the seam TestRunShutsDownOnContextCancel (main_test.go) exercises
// directly: cancel ctx and assert (a) run returns and (b) the listener
// stops accepting connections - not merely that Shutdown was CALLED (a
// config read-back is an assertion, not an observation), but that a REAL
// subsequent connection attempt is refused.
//
// ready, if non-nil, receives the bound listener's address once serving
// has started - tests use this to learn the real (often ephemeral, cfg.Port
// == 0) address without a race against "is it listening yet".
func run(ctx context.Context, cfg Config, ready chan<- string) error {
	srv, err := NewServer(cfg)
	if err != nil {
		return err
	}
	go srv.RunPollLoop(ctx)

	mux := http.NewServeMux()
	registerHandlers(mux, srv)

	addr := cfg.Host + ":" + strconv.Itoa(cfg.Port)
	ln, err := net.Listen("tcp", addr)
	if err != nil {
		return err
	}
	if ready != nil {
		ready <- ln.Addr().String()
	}

	httpServer := &http.Server{Handler: mux}

	go func() {
		<-ctx.Done()
		shutdownCtx, cancel := context.WithTimeout(context.Background(), time.Duration(shutdownGraceMs)*time.Millisecond)
		defer cancel()
		if err := httpServer.Shutdown(shutdownCtx); err != nil {
			log.Printf("board server: shutdown: %v", err)
		}
	}()

	log.Printf("board server: listening on http://%s (store=%s, demoMode=%v)", ln.Addr().String(), srv.storePathDisplayValue(), cfg.DemoMode)
	if err := httpServer.Serve(ln); err != nil && err != http.ErrServerClosed {
		return err
	}
	// http.ErrServerClosed is the clean shutdown path (Shutdown was called
	// from the ctx.Done() watcher above) - never surfaced as a failure.
	return nil
}

func main() {
	cfg := applyEnvOverrides(DefaultConfig(), os.LookupEnv)

	cwd, err := os.Getwd()
	if err != nil {
		log.Fatalf("board server: could not resolve the working directory: %v", err)
	}
	repoRootDir := resolveDefaultRepoRoot(cwd)
	if cfg.StorePath == "" {
		cfg.StorePath = filepath.Join(repoRootDir, "artifacts")
	}
	if cfg.SchemaDir == "" {
		cfg.SchemaDir = filepath.Join(repoRootDir, "schema")
	}
	if cfg.BoardDefsPath == "" {
		cfg.BoardDefsPath = filepath.Join(cfg.SchemaDir, "vocab", "board-defs.json")
	}
	if cfg.DefaultsPath == "" {
		cfg.DefaultsPath = filepath.Join(repoRootDir, "config", "harness-defaults.json")
	}
	if cfg.WebDir == "" {
		cfg.WebDir = filepath.Join(repoRootDir, "board", "web")
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	defer stop()

	if err := run(ctx, cfg, nil); err != nil {
		log.Fatalf("board server: %v", err)
	}
}

