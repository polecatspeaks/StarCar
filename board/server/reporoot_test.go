package main

import (
	"os"
	"path/filepath"
	"testing"
)

// TestResolveDefaultRepoRootHandlesTheDocumentedQuickstartCwd: the plan's own
// quickstart command is `cd board && go run ./server` (plan section 6) -
// which puts the process cwd AT board/, one level BELOW the repo root. A
// naive "cwd is the repo root" default (this server's first draft) would look
// for a nonexistent board/artifacts and board/schema. This test pins BOTH
// invocation shapes: cwd-is-repo-root (a future packaged binary) and
// cwd-is-board (the documented quickstart).
func TestResolveDefaultRepoRootHandlesTheDocumentedQuickstartCwd(t *testing.T) {
	repo := t.TempDir()
	if err := os.MkdirAll(filepath.Join(repo, "artifacts"), 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.MkdirAll(filepath.Join(repo, "schema"), 0o755); err != nil {
		t.Fatal(err)
	}
	boardDir := filepath.Join(repo, "board")
	if err := os.MkdirAll(boardDir, 0o755); err != nil {
		t.Fatal(err)
	}

	if got := resolveDefaultRepoRoot(repo); got != repo {
		t.Errorf("cwd-is-repo-root: resolveDefaultRepoRoot(%q) = %q, want %q", repo, got, repo)
	}
	if got := resolveDefaultRepoRoot(boardDir); got != repo {
		t.Errorf("cwd-is-board (the documented quickstart): resolveDefaultRepoRoot(%q) = %q, want %q", boardDir, got, repo)
	}
}

// TestResolveDefaultRepoRootFallsBackToCwd: neither candidate has both
// artifacts/ and schema/ - fall back to cwd itself (the prior, honest
// default) rather than guessing further.
func TestResolveDefaultRepoRootFallsBackToCwd(t *testing.T) {
	empty := t.TempDir()
	if got := resolveDefaultRepoRoot(empty); got != empty {
		t.Errorf("resolveDefaultRepoRoot(%q) = %q, want the fallback %q", empty, got, empty)
	}
}
