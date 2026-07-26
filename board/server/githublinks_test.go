package main

import (
	"path/filepath"
	"testing"
)

// TestGitHubRepoURL: issue #28 - config.githubRepoUrl is empty (no link,
// never a broken one) when STARCAR_GITHUB_REPO is unconfigured, and the
// full https://github.com/OWNER/REPO base otherwise. No hardcoded repo
// identity (Law 7) - the value is entirely a function of the configured
// "owner/repo" string.
func TestGitHubRepoURL(t *testing.T) {
	if got := githubRepoURL(""); got != "" {
		t.Fatalf("githubRepoURL(\"\") = %q, want empty (unconfigured yard degrades honestly)", got)
	}
	if got := githubRepoURL("polecatspeaks/StarCar"); got != "https://github.com/polecatspeaks/StarCar" {
		t.Fatalf("githubRepoURL = %q, want https://github.com/polecatspeaks/StarCar", got)
	}
}

// TestGitHubArtifactsPrefix_RepoRootRelative proves the prefix is computed
// against the REPO ROOT, never cwd - the documented quickstart invocation
// (reporoot.go: "cd board && go run ./server") puts cwd one level BELOW the
// repo root, so a cwd-relative computation would silently produce
// "../artifacts", a broken GitHub tree path one level off.
func TestGitHubArtifactsPrefix_RepoRootRelative(t *testing.T) {
	repoRoot := filepath.Join(string(filepath.Separator), "home", "someone", "starcar")
	storePath := filepath.Join(repoRoot, "artifacts")
	got := githubArtifactsPrefix(repoRoot, storePath)
	if got != "artifacts" {
		t.Fatalf("githubArtifactsPrefix = %q, want %q", got, "artifacts")
	}
}

// TestGitHubArtifactsPrefix_NestedStore proves a store nested more than one
// level under the repo root (e.g. a demo fixture directory) still resolves
// to a correct multi-segment, forward-slashed prefix.
func TestGitHubArtifactsPrefix_NestedStore(t *testing.T) {
	repoRoot := filepath.Join(string(filepath.Separator), "home", "someone", "starcar")
	storePath := filepath.Join(repoRoot, "board", "web", "test", "fixtures", "demo-artifacts")
	got := githubArtifactsPrefix(repoRoot, storePath)
	if got != "board/web/test/fixtures/demo-artifacts" {
		t.Fatalf("githubArtifactsPrefix = %q, want %q", got, "board/web/test/fixtures/demo-artifacts")
	}
}

// TestGitHubArtifactsPrefix_UnconfiguredRepoRoot: an empty repoRoot (a test
// Config, or a server that never resolved one) yields "" - no link, never a
// wrong one - rather than a cwd-relative guess.
func TestGitHubArtifactsPrefix_UnconfiguredRepoRoot(t *testing.T) {
	if got := githubArtifactsPrefix("", filepath.Join("some", "artifacts")); got != "" {
		t.Fatalf("githubArtifactsPrefix with empty repoRoot = %q, want empty", got)
	}
}

// TestGitHubArtifactsPrefix_StoreOutsideRepoRoot: a store path that does not
// live under repoRoot at all (a different drive, or deliberately pointed
// elsewhere) must never render a ".."-escaping path - same honest-degrade
// posture as storePathDisplay's own fallback tier (storepath.go).
func TestGitHubArtifactsPrefix_StoreOutsideRepoRoot(t *testing.T) {
	repoRoot := filepath.Join(string(filepath.Separator), "home", "someone", "starcar")
	storePath := filepath.Join(string(filepath.Separator), "mnt", "other-drive", "artifacts")
	got := githubArtifactsPrefix(repoRoot, storePath)
	if got != "" {
		t.Fatalf("githubArtifactsPrefix for an out-of-tree store = %q, want empty (never a '..'-escaping path)", got)
	}
}
