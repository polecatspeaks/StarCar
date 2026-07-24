package assemble

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func writeBoardDefs(t *testing.T, content string) string {
	t.Helper()
	dir := t.TempDir()
	path := filepath.Join(dir, "board-defs.json")
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatalf("writing fixture: %v", err)
	}
	return path
}

// TestLoadVocabulariesRealFile proves the loader reads the ACTUAL landed
// schema/vocab/board-defs.json (task 2.4) without error, with every closed
// register value and non-empty arrays - the file Car 4 actually loads in
// production.
func TestLoadVocabulariesRealFile(t *testing.T) {
	path := filepath.Join(repoRoot(t), "schema", "vocab", "board-defs.json")
	vocab, conditions := LoadVocabularies(path)
	if len(conditions) != 0 {
		t.Fatalf("the real, well-formed board-defs.json must load with zero conditions, got %v", conditions)
	}
	if len(vocab.Positions) == 0 || len(vocab.Outcomes) == 0 || len(vocab.Roles) == 0 || len(vocab.Liveness) == 0 {
		t.Fatalf("expected all four vocabularies non-empty, got %+v", vocab)
	}
}

// TestLoadVocabulariesMissingFileYieldsOneCondition: a missing board-defs.json
// is non-fatal (a value with no def still renders by raw id through the
// detector path, per the wire schema's own comment) - it must yield exactly
// ONE board condition and empty vocabularies, never a crash.
func TestLoadVocabulariesMissingFileYieldsOneCondition(t *testing.T) {
	vocab, conditions := LoadVocabularies(filepath.Join(t.TempDir(), "does-not-exist.json"))
	if len(conditions) != 1 {
		t.Fatalf("expected exactly 1 board condition for a missing file, got %d: %v", len(conditions), conditions)
	}
	if conditions[0].Code != "board-defs-unreadable" {
		t.Errorf("condition code = %q, want board-defs-unreadable", conditions[0].Code)
	}
	if len(vocab.Positions) != 0 {
		t.Errorf("expected empty vocabularies on a missing file, got %+v", vocab)
	}
}

// TestLoadVocabulariesBadRowQuarantinedAndConditioned: one malformed row
// (missing a required field, or a register outside the closed set) is
// skipped, named in its own condition, while the REST of the file's rows
// still load - one bad row must not blank the whole vocabularies block.
func TestLoadVocabulariesBadRowQuarantinedAndConditioned(t *testing.T) {
	path := writeBoardDefs(t, `{
		"positions": [
			{ "id": "live", "label": "Live", "register": "nominal" },
			{ "id": "bogus", "label": "Bogus", "register": "not-a-real-register" }
		],
		"outcomes": [],
		"roles": [],
		"liveness": []
	}`)
	vocab, conditions := LoadVocabularies(path)
	if len(vocab.Positions) != 1 || vocab.Positions[0].ID != "live" {
		t.Fatalf("expected the good row to still load, got %+v", vocab.Positions)
	}
	var found bool
	for _, c := range conditions {
		if c.Code == "board-def-invalid-row" {
			found = true
			if !strings.Contains(c.Detail, "bogus") {
				t.Errorf("condition must name the bad row, got %q", c.Detail)
			}
		}
	}
	if !found {
		t.Fatalf("expected a board-def-invalid-row condition, got %v", conditions)
	}
}
