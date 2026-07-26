// githublinks.go (#28: clickable provenance) computes the two config
// primitives the view needs to build GitHub links itself - a repo base URL
// and the store's path relative to the REPO ROOT - without the server ever
// re-deriving "which directory is this subject's record in" a second time
// (board/assemble's recordDirBySubject, single-sourced from
// store.Record.Path, owns that half - Law 6).
package main

import (
	"path/filepath"
	"strings"
)

// githubRepoURL returns the base GitHub repo URL for repo ("owner/repo"
// format), or "" when unconfigured - a non-GitHub yard (or one that has not
// set STARCAR_GITHUB_REPO) degrades to no links, never a broken one (issue
// #28's own escape hatch). No hardcoded repo identity (Law 7): the value is
// entirely a function of the configured string.
func githubRepoURL(repo string) string {
	if repo == "" {
		return ""
	}
	return "https://github.com/" + repo
}

// githubArtifactsPrefix computes the configured store's path RELATIVE TO
// THE REPO ROOT - never cwd-relative, unlike storePathDisplay (which IS
// deliberately cwd-relative for a human reading the footer). The
// distinction matters: reporoot.go's own documented quickstart invocation
// ("cd board && go run ./server") puts the process's cwd one level BELOW
// the repo root, so a cwd-relative computation here would silently produce
// "../artifacts" - a GitHub tree path one level off, pointing outside the
// repo entirely. repoRoot is main.go's resolveDefaultRepoRoot result
// (Config.RepoRoot), threaded through once at startup. Returns "" (never a
// link) when either input is empty or storePath does not live under
// repoRoot at all - honest degrade, the same posture storePathDisplay's own
// fallback tier uses for a path outside both cwd and home.
func githubArtifactsPrefix(repoRoot, storePath string) string {
	if repoRoot == "" || storePath == "" {
		return ""
	}
	rel, err := filepath.Rel(repoRoot, storePath)
	if err != nil {
		return ""
	}
	if rel == ".." || strings.HasPrefix(rel, ".."+string(filepath.Separator)) {
		return ""
	}
	return filepath.ToSlash(rel)
}
