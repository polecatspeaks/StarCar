package main

import (
	"path/filepath"
	"strings"
	"testing"
)

// TestStorePathDisplayCWDRelative: design 5.6 / spec YB-12 -
// storePathDisplay is NEVER a raw absolute path (this repo publishes
// screenshots). Preferred form: CWD-relative.
func TestStorePathDisplayCWDRelative(t *testing.T) {
	cwd := filepath.Join(string(filepath.Separator), "home", "someone", "starcar")
	abs := filepath.Join(cwd, "artifacts")
	got := storePathDisplay(abs, cwd, "")
	if strings.Contains(got, cwd) {
		t.Fatalf("display value %q still contains the absolute cwd prefix", got)
	}
	if got != "artifacts" {
		t.Fatalf("storePathDisplay = %q, want CWD-relative 'artifacts'", got)
	}
}

// TestStorePathDisplayHomeCollapsed: outside the CWD, but under $HOME -
// collapse to a leading ~.
func TestStorePathDisplayHomeCollapsed(t *testing.T) {
	home := filepath.Join(string(filepath.Separator), "home", "someone")
	abs := filepath.Join(home, "other-checkout", "artifacts")
	cwd := filepath.Join(string(filepath.Separator), "somewhere", "else")
	got := storePathDisplay(abs, cwd, home)
	if strings.HasPrefix(got, string(filepath.Separator)) {
		t.Fatalf("display value %q is still a raw absolute path", got)
	}
	if !strings.HasPrefix(got, "~") {
		t.Fatalf("storePathDisplay = %q, want home-collapsed (leading ~)", got)
	}
}

// TestStorePathDisplayNeverRawAbsolute: a path outside BOTH cwd and home
// must still never render as a raw absolute path (the fallback tier).
func TestStorePathDisplayNeverRawAbsolute(t *testing.T) {
	abs := filepath.Join(string(filepath.Separator), "mnt", "other-drive", "artifacts")
	cwd := filepath.Join(string(filepath.Separator), "somewhere", "else")
	home := filepath.Join(string(filepath.Separator), "home", "someone")
	got := storePathDisplay(abs, cwd, home)
	if got == abs {
		t.Fatalf("storePathDisplay returned the RAW absolute path %q - never allowed", got)
	}
}
