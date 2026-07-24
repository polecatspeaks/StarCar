package store

import (
	"path/filepath"
	"runtime"
	"testing"
)

// repoRoot resolves the repo root from inside board/store's tests via
// runtime.Caller(0) - the same robustness argument board/testroot_test.go and
// board/fold/testroot_test.go make (a relative "../../" literal breaks the
// moment a test file moves; the compile-time-embedded source path does not).
func repoRoot(t *testing.T) string {
	t.Helper()
	_, thisFile, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("runtime.Caller(0) could not resolve this test file's own path")
	}
	// thisFile is .../board/store/testroot_test.go
	storeDir := filepath.Dir(thisFile)
	boardDir := filepath.Dir(storeDir)
	return filepath.Dir(boardDir)
}

func schemaDir(t *testing.T) string {
	t.Helper()
	return filepath.Join(repoRoot(t), "schema")
}
