package assemble

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
)

// TestClosedRegistersMatchSchemaEnum pins EDGE 2 of the register taxonomy (#37):
// boarddefs.go's closedRegisters map vs schema/yard-snapshot.schema.json
// $defs.register.enum. Reads the real schema from disk using the repoRoot helper
// (testroot_test.go in this package), the same robustness argument as every
// other schema-reading test in this repo.
//
// ORDERING IS COMPOSE.JS-OWNED (schema/JS boundary): the schema enum cannot
// express severity order (JSON Schema enums are unordered); mostSevereRegister
// in compose.js depends on REGISTER_ORDER's array-index position. This test
// enforces SET EQUALITY only; order is not checked here. #37.
//
// Fault-injection evidence (recorded in commit message): temporarily adding
// "fault-injection-probe" to closedRegisters caused this test to FAIL with
// "closedRegisters key \"fault-injection-probe\" not in schema.$defs.register.enum".
// Reverted byte-identical before commit.
func TestClosedRegistersMatchSchemaEnum(t *testing.T) {
	schemaPath := filepath.Join(repoRoot(t), "schema", "yard-snapshot.schema.json")
	data, err := os.ReadFile(schemaPath)
	if err != nil {
		t.Fatalf("could not read %s: %v", schemaPath, err)
	}

	// Parse only the $defs.register.enum portion of the schema.
	// The `json:"$defs"` tag is valid Go (json tags are arbitrary strings).
	var sc struct {
		Defs struct {
			Register struct {
				Enum []string `json:"enum"`
			} `json:"register"`
		} `json:"$defs"`
	}
	if err := json.Unmarshal(data, &sc); err != nil {
		t.Fatalf("could not parse schema: %v", err)
	}

	schemaEnum := sc.Defs.Register.Enum

	// Non-vacuity guards: both sides must be non-empty.
	if len(schemaEnum) == 0 {
		t.Fatal("schema.$defs.register.enum is empty - fixture sanity check failed")
	}
	if len(closedRegisters) == 0 {
		t.Fatal("closedRegisters is empty - fixture sanity check failed")
	}

	// Every closedRegisters key must appear in the schema enum.
	for r := range closedRegisters {
		found := false
		for _, s := range schemaEnum {
			if s == r {
				found = true
				break
			}
		}
		if !found {
			t.Errorf("closedRegisters key %q is not in schema.$defs.register.enum - boarddefs.go and schema have drifted (#37)", r)
		}
	}

	// Every schema enum value must appear in closedRegisters.
	for _, s := range schemaEnum {
		if !closedRegisters[s] {
			t.Errorf("schema.$defs.register.enum value %q is not in closedRegisters - boarddefs.go and schema have drifted (#37)", s)
		}
	}

	// Size equality catches duplicates on either side.
	if len(closedRegisters) != len(schemaEnum) {
		t.Errorf("closedRegisters has %d entries but schema enum has %d - sets differ (#37)", len(closedRegisters), len(schemaEnum))
	}
}
