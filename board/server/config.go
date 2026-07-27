package main

import "strconv"

// Config is the server's own runtime configuration (design rev 5 S5.6,
// carrying rev 3 S11's numbers). StorePath/SchemaDir/BoardDefsPath are
// resolved to absolute paths by main() before NewServer is called;
// storePathDisplay (storepath.go) is the WIRE-safe rendering of StorePath.
type Config struct {
	Host          string
	Port          int
	PollMs        int
	HeartbeatMs   int
	StalenessMs   int
	StorePath     string
	SchemaDir     string
	BoardDefsPath string
	// WebDir is board/web/ - the view's static assets (index.html, js/,
	// css/, vendor/). Served at "/" (plan section 6, task 5.3: "the view
	// (board/web/) lands with Car 5", replacing task 4.3's placeholder).
	WebDir string
	// DefaultsPath is config/harness-defaults.json - the shop-default
	// dispatch budget (C3R-1d, spec Amendment 2, issue #22), threaded into
	// every Fold call via WithDefaultBudgetSeconds so a budget-less legacy
	// dispatched record can still render overdue.
	DefaultsPath string
	// DemoMode is true exactly when StorePath points at a demo fixture store
	// rather than a live checkout's artifacts/ (spec YB-15). Its SOLE
	// consumer is the wire config.demoMode field (the view's banner) - no
	// other behaviour in this package may branch on it.
	DemoMode bool
	// GitHubRepo is "owner/repo" (issue #28, STARCAR_GITHUB_REPO) - the ONE
	// place this repo's GitHub identity may be configured. Empty by default:
	// no hardcoded repo identity (Law 7), and an unconfigured or non-GitHub
	// yard degrades to zero provenance links rather than a wrong one.
	GitHubRepo string
	// GitHubRef (issue #28, STARCAR_GITHUB_REF) is the branch a record/tree
	// link resolves against. Defaults to "dev" (DefaultConfig) - this repo's
	// own working-integration branch (CLAUDE.md's branch topology section),
	// and issue #28's own worked example.
	GitHubRef string
	// RepoRoot is main()'s resolveDefaultRepoRoot result, threaded through
	// so githubArtifactsPrefix (githublinks.go) can compute StorePath's
	// position relative to the REPO ROOT rather than the process's cwd -
	// the documented "cd board && go run ./server" quickstart invocation
	// (reporoot.go) puts cwd one level below the repo root, and a
	// cwd-relative computation here (unlike storePathDisplay's own,
	// deliberately cwd-relative display value) would silently point a
	// GitHub tree link outside the repo. Never rendered on the wire itself
	// (an absolute local path) - only ever used to derive the relative
	// prefix that IS rendered.
	RepoRoot string
}

// DefaultConfig is design rev 5 S5.6's carried numbers: host 127.0.0.1,
// port 4600, pollMs 1000, heartbeatMs 5000, stalenessMs 15000.
func DefaultConfig() Config {
	return Config{
		Host:        "127.0.0.1",
		Port:        4600,
		PollMs:      1000,
		HeartbeatMs: 5000,
		StalenessMs: 15000,
		GitHubRef:   "dev",
	}
}

// lookupEnvFunc abstracts os.LookupEnv so applyEnvOverrides is testable
// without mutating real process environment variables.
type lookupEnvFunc func(key string) (string, bool)

// applyEnvOverrides applies STARCAR_* env overrides (design S5.6) onto base,
// returning a NEW Config - an unset env var never overwrites a field with a
// zero value (only a present, parseable value overrides).
func applyEnvOverrides(base Config, lookup lookupEnvFunc) Config {
	cfg := base
	if v, ok := lookup("STARCAR_HOST"); ok && v != "" {
		cfg.Host = v
	}
	if v, ok := lookup("STARCAR_PORT"); ok {
		if n, err := strconv.Atoi(v); err == nil {
			cfg.Port = n
		}
	}
	if v, ok := lookup("STARCAR_POLL_MS"); ok {
		if n, err := strconv.Atoi(v); err == nil {
			cfg.PollMs = n
		}
	}
	if v, ok := lookup("STARCAR_HEARTBEAT_MS"); ok {
		if n, err := strconv.Atoi(v); err == nil {
			cfg.HeartbeatMs = n
		}
	}
	if v, ok := lookup("STARCAR_STALENESS_MS"); ok {
		if n, err := strconv.Atoi(v); err == nil {
			cfg.StalenessMs = n
		}
	}
	if v, ok := lookup("STARCAR_STORE_PATH"); ok && v != "" {
		cfg.StorePath = v
	}
	if v, ok := lookup("STARCAR_DEMO_MODE"); ok {
		if b, err := strconv.ParseBool(v); err == nil {
			cfg.DemoMode = b
		}
	}
	if v, ok := lookup("STARCAR_GITHUB_REPO"); ok && v != "" {
		cfg.GitHubRepo = v
	}
	if v, ok := lookup("STARCAR_GITHUB_REF"); ok && v != "" {
		cfg.GitHubRef = v
	}
	return cfg
}
