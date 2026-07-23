// Command server is the yard board's Go server (design rev 5, plan task
// 4.3): the one reader of the artifact store, exposing GET /, GET
// /api/snapshot, and GET /api/stream (SSE) - nothing else. One process,
// stateless-restartable by construction (design S5.1): everything it serves
// is derived from the store on poll.
package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"strconv"
)

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

	srv, err := NewServer(cfg)
	if err != nil {
		log.Fatalf("board server: %v", err)
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	defer stop()
	go srv.RunPollLoop(ctx)

	mux := http.NewServeMux()
	registerHandlers(mux, srv)

	addr := cfg.Host + ":" + strconv.Itoa(cfg.Port)
	log.Printf("board server: listening on http://%s (store=%s, demoMode=%v)", addr, storePathDisplay(cfg.StorePath, repoRootDir, os.Getenv("HOME")), cfg.DemoMode)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatalf("board server: %v", err)
	}
}
