package main

import (
	"path/filepath"
	"runtime"
	"testing"
)

// repoRoot resolves the repo root from inside board/server's tests via
// runtime.Caller(0), the same robustness argument every sibling package's
// testroot helper makes.
func repoRoot(t *testing.T) string {
	t.Helper()
	_, thisFile, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("runtime.Caller(0) could not resolve this test file's own path")
	}
	serverDir := filepath.Dir(thisFile)
	boardDir := filepath.Dir(serverDir)
	return filepath.Dir(boardDir)
}
