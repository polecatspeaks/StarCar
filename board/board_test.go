package board

import (
	"testing"

	"github.com/santhosh-tekuri/jsonschema/v6"
)

// TestPlaceholder is the "one trivial real test" plan task 1.1 asks for: proof
// the module compiles and go test finds and runs something, before any product
// package exists under board/.
func TestPlaceholder(t *testing.T) {
	got := Placeholder()
	want := "board"
	if got != want {
		t.Fatalf("Placeholder() = %q, want %q", got, want)
	}
}

// TestPinnedJSONSchemaDependencyCompilesStoreSchema is the "minimal use" plan
// task 1.1 asks for: it proves the pinned github.com/santhosh-tekuri/jsonschema/v6
// v6.0.2 dependency is REAL (not just an unused require line) by compiling the
// landed store record schema through it. This also doubles as the first half of
// spec YB-11(a)'s blocking validator test, observed at the plan rung against the
// same library and now re-observed here from board/'s own module.
func TestPinnedJSONSchemaDependencyCompilesStoreSchema(t *testing.T) {
	schemaPath := repoRootSchemaPath(t, "starcar-artifact.schema.json")

	c := jsonschema.NewCompiler()
	sch, err := c.Compile(schemaPath)
	if err != nil {
		t.Fatalf("compiling %s via jsonschema/v6: %v", schemaPath, err)
	}
	if sch == nil {
		t.Fatal("Compile returned a nil schema with no error")
	}

	// Exercise validation too, not just compilation - a schema that loads but
	// never runs a rule would still be a hollow "use" of the dependency. Shape
	// matches schema/vectors/valid-returned.json (a landed, already-vetted
	// vector for kind=returned), so this is not a hand-invented fixture.
	var doc any = map[string]any{
		"schema":     "starcar-artifact/1",
		"kind":       "returned",
		"subject":    "abc123",
		"session_id": "session-abc",
		"at":         "2026-07-22T03:44:34-04:00",
		"outcome":    "REJECT",
		"findings":   "none",
		"abstract":   "a hand-built sample record for the pinned-dependency use test",
		"normalisation": []any{
			map[string]any{"from_class": "repo-root", "to": "<repo>"},
		},
		"integrity": "sha256:0000000000000000000000000000000000000000000000000000000000000000",
	}
	if err := sch.Validate(doc); err != nil {
		t.Fatalf("a well-formed sample record failed validation: %v", err)
	}
}
