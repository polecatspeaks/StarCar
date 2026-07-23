package main

import (
	"path/filepath"
	"strings"
)

// storePathDisplay normalises an absolute store path for the wire
// (config.storePathDisplay) - CWD-relative preferred, home-collapsed second,
// and a basename-only fallback so the NEVER-a-raw-absolute-path invariant
// holds unconditionally (design S5.6/spec YB-12; this repo publishes
// screenshots - NORTH STAR path-normalisation law). cwd and home are passed
// in explicitly (real callers supply os.Getwd()/os.UserHomeDir()) so this
// stays testable without depending on the actual process environment.
func storePathDisplay(absPath, cwd, home string) string {
	if cwd != "" {
		if rel, err := filepath.Rel(cwd, absPath); err == nil && !strings.HasPrefix(rel, "..") {
			return filepath.ToSlash(rel)
		}
	}
	if home != "" && strings.HasPrefix(absPath, home) {
		rest := strings.TrimPrefix(absPath, home)
		return "~" + filepath.ToSlash(rest)
	}
	// Neither cwd-relative nor home-collapsed applies (a path on another
	// drive/outside both) - the NEVER-raw-absolute invariant still holds:
	// disclose only the base directory name, never the full path.
	return ".../" + filepath.ToSlash(filepath.Base(absPath))
}
