package board

import (
	"os"
	"path/filepath"
	"testing"
)

// TestRE2CompatiblePatterns_CatchesInjectedLookahead is the RED-FIRST proof
// this probe actually catches something (plan task 1.3): a fixture schema file
// carrying an RE2-incompatible negative-lookahead pattern - the exact class
// spec YB-11's SB-1 note describes ("the original negative-lookahead pattern
// was RE2-incompatible... Go regexp rejects `(?!` at schema-load") - must be
// NAMED by checkRE2CompatiblePatterns, not silently missed. This is the
// non-vacuity proof the regression-vault convention (CLAUDE.md TDD section)
// asks for: fault-inject the guarded behavior once, observe the failure.
func TestRE2CompatiblePatterns_CatchesInjectedLookahead(t *testing.T) {
	dir := t.TempDir()
	const badPattern = `^(?!bad-train:).*$`
	fixture := `{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "properties": {
    "subject": { "type": "string", "pattern": "` + badPattern + `" }
  }
}`
	if err := os.WriteFile(filepath.Join(dir, "injected.schema.json"), []byte(fixture), 0o644); err != nil {
		t.Fatalf("writing fixture: %v", err)
	}

	failures, err := checkRE2CompatiblePatterns(dir)
	if err != nil {
		t.Fatalf("checkRE2CompatiblePatterns(%s) returned an unexpected error: %v", dir, err)
	}
	if len(failures) != 1 {
		t.Fatalf("expected exactly 1 RE2-incompatible pattern to be caught, got %d: %+v", len(failures), failures)
	}
	if failures[0].Pattern != badPattern {
		t.Fatalf("the reported failure named pattern %q, want %q - a probe that catches SOMETHING but names the WRONG thing is as useless as one that catches nothing", failures[0].Pattern, badPattern)
	}
	if failures[0].SchemaFile != "injected.schema.json" {
		t.Fatalf("the reported failure named file %q, want %q", failures[0].SchemaFile, "injected.schema.json")
	}
}

// TestRE2CompatiblePatterns_CatchesInjectedLookaheadAsPatternPropertiesKey is the
// RED-FIRST proof for plan task 3.R (rider from Car 1's review, [C1R-2]): a
// "patternProperties" keyword's value is a map whose KEYS are themselves
// regexes applied against property names - not "pattern" VALUES under a
// "pattern" key, the only shape the original findPatterns walk recognised. No
// current schema/*.schema.json uses patternProperties (grep confirmed empty at
// plan authoring), so this is a latent hole: "the guard is not wrong today, it
// is incomplete tomorrow." A lookahead used as a patternProperties key must be
// named by checkRE2CompatiblePatterns exactly as a "pattern" value would be.
func TestRE2CompatiblePatterns_CatchesInjectedLookaheadAsPatternPropertiesKey(t *testing.T) {
	dir := t.TempDir()
	const badPattern = `^(?!bad-train:).*$`
	fixture := `{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "patternProperties": {
    "` + badPattern + `": { "type": "string" }
  }
}`
	if err := os.WriteFile(filepath.Join(dir, "pp-key.schema.json"), []byte(fixture), 0o644); err != nil {
		t.Fatalf("writing fixture: %v", err)
	}

	failures, err := checkRE2CompatiblePatterns(dir)
	if err != nil {
		t.Fatalf("checkRE2CompatiblePatterns(%s) returned an unexpected error: %v", dir, err)
	}
	if len(failures) != 1 {
		t.Fatalf("expected exactly 1 RE2-incompatible patternProperties KEY to be caught, got %d: %+v", len(failures), failures)
	}
	if failures[0].Pattern != badPattern {
		t.Fatalf("the reported failure named pattern %q, want %q", failures[0].Pattern, badPattern)
	}
	if failures[0].SchemaFile != "pp-key.schema.json" {
		t.Fatalf("the reported failure named file %q, want %q", failures[0].SchemaFile, "pp-key.schema.json")
	}
}

// TestRE2CompatiblePatterns_CatchesInjectedLookaheadUnderPropertyNames is the
// companion case named in the same rider: a "propertyNames" keyword's value is
// itself a (sub-)schema applied to property NAMES, most commonly carrying its
// own "pattern" keyword - e.g. {"propertyNames": {"pattern": "..."}}. This
// shape nests a "pattern" key at depth, which the original recursive walk
// already visits; this test pins that the walk still finds it once
// patternProperties-key handling is added alongside it (a regression guard for
// the extension, not a hole by itself - named in the rider as "and under
// propertyNames" so both call sites stay covered by name, not by accident).
func TestRE2CompatiblePatterns_CatchesInjectedLookaheadUnderPropertyNames(t *testing.T) {
	dir := t.TempDir()
	const badPattern = `^(?!bad-train:).*$`
	fixture := `{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "propertyNames": { "pattern": "` + badPattern + `" }
}`
	if err := os.WriteFile(filepath.Join(dir, "propnames.schema.json"), []byte(fixture), 0o644); err != nil {
		t.Fatalf("writing fixture: %v", err)
	}

	failures, err := checkRE2CompatiblePatterns(dir)
	if err != nil {
		t.Fatalf("checkRE2CompatiblePatterns(%s) returned an unexpected error: %v", dir, err)
	}
	if len(failures) != 1 {
		t.Fatalf("expected exactly 1 RE2-incompatible pattern under propertyNames to be caught, got %d: %+v", len(failures), failures)
	}
	if failures[0].Pattern != badPattern {
		t.Fatalf("the reported failure named pattern %q, want %q", failures[0].Pattern, badPattern)
	}
	if failures[0].SchemaFile != "propnames.schema.json" {
		t.Fatalf("the reported failure named file %q, want %q", failures[0].SchemaFile, "propnames.schema.json")
	}
}

// TestRE2CompatiblePatterns_RealSchemasAllCompile is the standing-rule guard
// itself (spec YB-11 SB-1: "every pattern in every landed schema is
// RE2-compatible - no lookahead, no backreferences"). It walks the REAL
// schema/*.schema.json files (via repoRootSchemaPath's runtime.Caller-based
// root resolution, so it is independent of go test's invocation directory)
// and fails, naming the offending schema file and pattern, on the first
// RE2-incompatible pattern found.
func TestRE2CompatiblePatterns_RealSchemasAllCompile(t *testing.T) {
	root := repoRootSchemaPath(t)

	failures, err := checkRE2CompatiblePatterns(root)
	if err != nil {
		t.Fatalf("checkRE2CompatiblePatterns(%s) returned an unexpected error: %v", root, err)
	}
	if len(failures) != 0 {
		t.Fatalf("RE2-incompatible pattern(s) found under %s: %+v", root, failures)
	}
}
