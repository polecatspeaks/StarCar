package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
)

// TestSSEEventNameMatchesSchemaConstant is the server half of YB-4's "SSE
// event name" obligation: the server writes exactly the schema's
// $defs.sseEventName.const, never a locally re-typed string with no tether
// back to the schema (design S5.4 item 4 - "the one-character-apart failure
// mode is cross-language now").
func TestSSEEventNameMatchesSchemaConstant(t *testing.T) {
	path := filepath.Join(repoRoot(t), "schema", "yard-snapshot.schema.json")
	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("reading %s: %v", path, err)
	}
	var doc struct {
		Defs struct {
			SSEEventName struct {
				Const string `json:"const"`
			} `json:"sseEventName"`
		} `json:"$defs"`
	}
	if err := json.Unmarshal(data, &doc); err != nil {
		t.Fatalf("parsing %s: %v", path, err)
	}
	if doc.Defs.SSEEventName.Const == "" {
		t.Fatal("schema's $defs.sseEventName.const is empty - the schema itself has no constant to tether against")
	}
	if sseEventName != doc.Defs.SSEEventName.Const {
		t.Fatalf("server's sseEventName = %q, schema's $defs.sseEventName.const = %q - these MUST match", sseEventName, doc.Defs.SSEEventName.Const)
	}
}
