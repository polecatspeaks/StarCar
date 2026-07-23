package fold

import (
	"path/filepath"
	"runtime"
	"testing"
)

// repoRoot resolves the repo root from inside board/fold's tests, via
// runtime.Caller(0) (this source file's own compile-time path) rather than a
// relative "../../" literal or the process's cwd - the same robustness
// argument board/testroot_test.go's repoRootSchemaPath makes, restated here
// because board/fold is its own package (Go test helpers do not cross
// package boundaries) and one directory deeper (fold/ -> board/ -> repo root).
func repoRoot(t *testing.T) string {
	t.Helper()
	_, thisFile, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("runtime.Caller(0) could not resolve this test file's own path")
	}
	// thisFile is .../board/fold/testroot_test.go
	foldDir := filepath.Dir(thisFile)
	boardDir := filepath.Dir(foldDir)
	return filepath.Dir(boardDir)
}
