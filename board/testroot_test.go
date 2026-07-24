package board

import (
	"path/filepath"
	"runtime"
	"testing"
)

// repoRootSchemaPath resolves a path under the repo-root schema/ directory from
// inside board/'s tests.
//
// Root-resolution choice (reviewer caution on plan task 1.3, applies equally to
// 1.1's dependency-use test): `go test` always sets the test binary's working
// directory to the package directory of the test being compiled - that part is
// already stable regardless of where `go test ./...` is invoked FROM (repo
// root, board/, or CI). But a relative "../schema" literal is still fragile
// against the test file ever moving to a nested package (board/fold,
// board/store, ...), where the correct number of ".." segments would silently
// change. runtime.Caller(0) reports THIS SOURCE FILE's own path, embedded at
// compile time, independent of both the process's cwd and of go test's
// per-package cwd convention - so the root is derived from where board_test.go
// physically lives on disk, not from any invocation-time assumption. That is
// the robust option this helper implements; the choice is stated here per the
// plan-approval verdict's reviewer caution.
func repoRootSchemaPath(t *testing.T, parts ...string) string {
	t.Helper()

	_, thisFile, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("runtime.Caller(0) could not resolve this test file's own path")
	}
	// thisFile is .../board/testroot_test.go; its parent (board/)'s parent is
	// the repo root.
	boardDir := filepath.Dir(thisFile)
	repoRoot := filepath.Dir(boardDir)

	elems := append([]string{repoRoot, "schema"}, parts...)
	return filepath.Join(elems...)
}
