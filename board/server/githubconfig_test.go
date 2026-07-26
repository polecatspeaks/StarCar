package main

import (
	"path/filepath"
	"testing"
	"time"
)

// TestBuildSnapshotGitHubConfigUnconfigured: an unconfigured yard (the
// default, untouched Config) must carry EMPTY githubRepoUrl/githubRef/
// githubArtifactsPrefix on the wire - "no link, never a broken one" (issue
// #28), never a hardcoded repo identity (Law 7).
func TestBuildSnapshotGitHubConfigUnconfigured(t *testing.T) {
	root := t.TempDir()
	srv := newTestServer(t, root)
	snap := srv.CurrentSnapshot()
	if snap.Config.GitHubRepoURL != "" {
		t.Errorf("GitHubRepoURL = %q, want empty (unconfigured)", snap.Config.GitHubRepoURL)
	}
	if snap.Config.GitHubArtifactsPrefix != "" {
		t.Errorf("GitHubArtifactsPrefix = %q, want empty (RepoRoot unset)", snap.Config.GitHubArtifactsPrefix)
	}
}

// TestBuildSnapshotGitHubConfigConfigured: with GitHubRepo/RepoRoot set (the
// production shape main.go wires), the wire carries the full repo URL, the
// configured ref, and the store's repo-root-relative prefix.
func TestBuildSnapshotGitHubConfigConfigured(t *testing.T) {
	repoRoot := t.TempDir()
	storeRoot := filepath.Join(repoRoot, "artifacts")
	writeRecord(t, storeRoot, "s1/dispatched-1.json", validDispatchedJSON("s1", "2026-07-20T00:00:00Z"))

	cfg := testConfig(t, storeRoot)
	cfg.RepoRoot = repoRoot
	cfg.GitHubRepo = "polecatspeaks/StarCar"
	cfg.GitHubRef = "dev"

	srv, err := NewServer(cfg)
	if err != nil {
		t.Fatalf("NewServer: %v", err)
	}
	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC)
	snap, _, err := srv.PollOnce(now)
	if err != nil {
		t.Fatalf("PollOnce: %v", err)
	}

	if snap.Config.GitHubRepoURL != "https://github.com/polecatspeaks/StarCar" {
		t.Errorf("GitHubRepoURL = %q", snap.Config.GitHubRepoURL)
	}
	if snap.Config.GitHubRef != "dev" {
		t.Errorf("GitHubRef = %q, want dev", snap.Config.GitHubRef)
	}
	if snap.Config.GitHubArtifactsPrefix != "artifacts" {
		t.Errorf("GitHubArtifactsPrefix = %q, want artifacts", snap.Config.GitHubArtifactsPrefix)
	}
}
