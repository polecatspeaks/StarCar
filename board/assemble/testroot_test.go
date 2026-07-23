package assemble

import (
	"path/filepath"
	"runtime"
	"testing"
)

// repoRoot resolves the repo root from inside board/assemble's tests via
// runtime.Caller(0), the same robustness argument every sibling package's
// testroot helper makes.
func repoRoot(t *testing.T) string {
	t.Helper()
	_, thisFile, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("runtime.Caller(0) could not resolve this test file's own path")
	}
	assembleDir := filepath.Dir(thisFile)
	boardDir := filepath.Dir(assembleDir)
	return filepath.Dir(boardDir)
}
