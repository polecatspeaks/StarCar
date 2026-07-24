package main

import (
	"os"
	"path/filepath"
)

// resolveDefaultRepoRoot finds the repo checkout root main() defaults
// artifacts/schema/config paths against. The plan's own documented
// quickstart invocation is `cd board && go run ./server` (plan section 6),
// which puts the process's working directory AT `board/`, one level BELOW
// the repo root where `artifacts/` and `schema/` actually live - so
// defaulting to cwd itself would look for a nonexistent `board/artifacts`.
// This checks cwd first (a future packaged binary invoked FROM the repo
// root), then cwd's parent (the documented `cd board && go run ./server`
// case) for a directory containing BOTH `artifacts` and `schema`, falling
// back to cwd itself (the prior, honest default) if neither candidate has
// both - callers can always override via STARCAR_STORE_PATH regardless.
func resolveDefaultRepoRoot(cwd string) string {
	candidates := []string{cwd, filepath.Dir(cwd)}
	for _, c := range candidates {
		if hasDir(filepath.Join(c, "artifacts")) && hasDir(filepath.Join(c, "schema")) {
			return c
		}
	}
	return cwd
}

func hasDir(path string) bool {
	info, err := os.Stat(path)
	return err == nil && info.IsDir()
}
