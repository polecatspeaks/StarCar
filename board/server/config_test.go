package main

import "testing"

func TestDefaultConfig(t *testing.T) {
	cfg := DefaultConfig()
	if cfg.Host != "127.0.0.1" {
		t.Errorf("Host = %q, want 127.0.0.1", cfg.Host)
	}
	if cfg.Port != 4600 {
		t.Errorf("Port = %d, want 4600", cfg.Port)
	}
	if cfg.PollMs != 1000 {
		t.Errorf("PollMs = %d, want 1000", cfg.PollMs)
	}
	if cfg.HeartbeatMs != 5000 {
		t.Errorf("HeartbeatMs = %d, want 5000", cfg.HeartbeatMs)
	}
	if cfg.StalenessMs != 15000 {
		t.Errorf("StalenessMs = %d, want 15000", cfg.StalenessMs)
	}
	if cfg.DemoMode {
		t.Errorf("DemoMode default must be false")
	}
	// #28: an unconfigured yard must degrade to NO github links, never a
	// guessed or hardcoded repo identity (Law 7).
	if cfg.GitHubRepo != "" {
		t.Errorf("GitHubRepo default = %q, want empty (unconfigured yards render no links)", cfg.GitHubRepo)
	}
	if cfg.GitHubRef != "dev" {
		t.Errorf("GitHubRef default = %q, want %q (issue #28's own example ref)", cfg.GitHubRef, "dev")
	}
	if cfg.RepoRoot != "" {
		t.Errorf("RepoRoot default must be empty until main() resolves it")
	}
}

// TestApplyEnvOverrides: design 5.6 - "STARCAR_* env overrides".
func TestApplyEnvOverrides(t *testing.T) {
	env := map[string]string{
		"STARCAR_HOST":         "0.0.0.0",
		"STARCAR_PORT":         "9999",
		"STARCAR_POLL_MS":      "2000",
		"STARCAR_HEARTBEAT_MS": "6000",
		"STARCAR_STALENESS_MS": "30000",
		"STARCAR_STORE_PATH":   "/tmp/demo-store",
		"STARCAR_DEMO_MODE":    "true",
		"STARCAR_GITHUB_REPO":  "polecatspeaks/StarCar",
		"STARCAR_GITHUB_REF":   "main",
	}
	cfg := applyEnvOverrides(DefaultConfig(), func(k string) (string, bool) {
		v, ok := env[k]
		return v, ok
	})
	if cfg.Host != "0.0.0.0" || cfg.Port != 9999 || cfg.PollMs != 2000 || cfg.HeartbeatMs != 6000 || cfg.StalenessMs != 30000 {
		t.Fatalf("env overrides did not apply: %+v", cfg)
	}
	if cfg.StorePath != "/tmp/demo-store" {
		t.Fatalf("StorePath = %q", cfg.StorePath)
	}
	if !cfg.DemoMode {
		t.Fatalf("DemoMode must be true when STARCAR_DEMO_MODE=true")
	}
	if cfg.GitHubRepo != "polecatspeaks/StarCar" {
		t.Fatalf("GitHubRepo = %q, want polecatspeaks/StarCar", cfg.GitHubRepo)
	}
	if cfg.GitHubRef != "main" {
		t.Fatalf("GitHubRef = %q, want main (env override of the 'dev' default)", cfg.GitHubRef)
	}
}

// TestApplyEnvOverridesLeavesDefaultsWhenUnset proves an absent env var never
// overwrites the base config with a zero value.
func TestApplyEnvOverridesLeavesDefaultsWhenUnset(t *testing.T) {
	base := DefaultConfig()
	cfg := applyEnvOverrides(base, func(string) (string, bool) { return "", false })
	if cfg != base {
		t.Fatalf("no env vars set must leave the config unchanged: got %+v, want %+v", cfg, base)
	}
}
