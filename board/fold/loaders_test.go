package fold

import (
	"os"
	"path/filepath"
	"testing"
)

// TestLoadVocab_UnreadableDirIsOneError is this package's OWN-IDIOM equivalent
// (plan task 3.3, reviewer caution folded into this car's brief) of
// Detector.Tests.ps1's carved-out "an unreadable vocabulary directory is ONE
// fault, not N" imperative case (plan 3.1's amendment: that case is
// environmental/pwsh-IO, not a pure fold semantic, and cannot be expressed as
// a schema/vectors/fold/ vector - a path-bearing error string is not something
// a cross-language deep-equal can pin). The vectors would leave this behaviour
// silently uncovered on the Go side without this test.
func TestLoadVocab_UnreadableDirIsOneError(t *testing.T) {
	dir := filepath.Join(t.TempDir(), "no-such-vocab-dir")

	_, err := LoadVocab(dir)
	if err == nil {
		t.Fatal("LoadVocab against a nonexistent directory returned no error")
	}
	// ONE error (Go's own idiom: a single returned error value, never a slice
	// of N per-file faults) - the own-idiom equivalent of "ONE fault, not N".
	// The message text is NOT vector-pinned (spec YB-8's disclosed posture
	// scopes byte-identical fault strings to vector-covered cases only).
}

// TestLoadDefaultBudget_UnreadablePathIsOneError is the own-idiom equivalent
// of Detector.Tests.ps1's carved-out "an unreadable defaults file is ONE
// fault" imperative case, for the same reason as above.
func TestLoadDefaultBudget_UnreadablePathIsOneError(t *testing.T) {
	path := filepath.Join(t.TempDir(), "no-such-defaults.json")

	_, err := LoadDefaultBudget(path)
	if err == nil {
		t.Fatal("LoadDefaultBudget against a nonexistent path returned no error")
	}
}

// TestLoadVocab_ValidValuesRoundTrip is a non-vacuity check (CLAUDE.md's TDD
// section: a green regression test must prove something, not just exist) -
// LoadVocab against a real {"values": [...]} shape (the schema/vocab/ layout,
// mirrored by the fold vector runner contract) returns exactly those values,
// not an empty Vocab that would make the error-path tests above vacuously
// meaningful.
func TestLoadVocab_ValidValuesRoundTrip(t *testing.T) {
	dir := t.TempDir()
	writeJSON(t, filepath.Join(dir, "kinds.json"), `{"values": ["dispatched", "returned"]}`)
	writeJSON(t, filepath.Join(dir, "outcomes.json"), `{"values": ["APPROVE"]}`)

	vocab, err := LoadVocab(dir)
	if err != nil {
		t.Fatalf("LoadVocab(%s) returned an unexpected error: %v", dir, err)
	}
	if len(vocab.Kinds) != 2 || vocab.Kinds[0] != "dispatched" || vocab.Kinds[1] != "returned" {
		t.Fatalf("LoadVocab kinds = %#v, want [dispatched returned]", vocab.Kinds)
	}
	if len(vocab.Outcomes) != 1 || vocab.Outcomes[0] != "APPROVE" {
		t.Fatalf("LoadVocab outcomes = %#v, want [APPROVE]", vocab.Outcomes)
	}
}

func writeJSON(t *testing.T, path, content string) {
	t.Helper()
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatalf("writing %s: %v", path, err)
	}
}
