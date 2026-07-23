package main

import (
	"encoding/json"
	"path/filepath"
	"testing"
	"time"

	"github.com/santhosh-tekuri/jsonschema/v6"
)

// TestAssembledSnapshotValidatesAgainstWireSchema is plan task 4.3's last
// obligation: the Go server's marshalled output MUST validate against
// schema/yard-snapshot.schema.json under the PINNED validator
// (github.com/santhosh-tekuri/jsonschema/v6 v6.0.2) - a real assembled
// snapshot, not a hand-invented shape, exercising trains/gates/dispatches
// payloads together (a manifest, an assigned car, an unassigned yard-
// inventory dispatch, a returned gate).
func TestAssembledSnapshotValidatesAgainstWireSchema(t *testing.T) {
	root := t.TempDir()
	writeRecord(t, root, "manifest/intent-1.json", `{
		"schema": "starcar-artifact/1",
		"kind": "intent",
		"subject": "train:board-v0",
		"session_id": "s1",
		"at": "2026-07-23T09:00:00Z",
		"normalisation": [],
		"integrity": "sha256:0000000000000000000000000000000000000000000000000000000000000000",
		"manifest": {
			"title": "The yard board train",
			"members": [
				{ "subject": "carA", "role": "car" },
				{ "subject": "gate-1", "role": "gate", "gate": "design review round 1" }
			]
		}
	}`)
	writeRecord(t, root, "carA/dispatched-1.json", validDispatchedJSON("carA", "2026-07-23T09:05:00Z"))
	writeRecord(t, root, "gate-1/returned-1.json", `{
		"schema": "starcar-artifact/1",
		"kind": "returned",
		"subject": "gate-1",
		"session_id": "s1",
		"at": "2026-07-23T09:10:00Z",
		"outcome": "REJECT",
		"findings": "f",
		"abstract": "a",
		"normalisation": [],
		"integrity": "sha256:0000000000000000000000000000000000000000000000000000000000000000"
	}`)
	writeRecord(t, root, "orphan-1/dispatched-1.json", validDispatchedJSON("orphan-1", "2026-07-23T09:06:00Z"))

	srv := newTestServer(t, root)
	now := time.Date(2026, 7, 23, 9, 20, 0, 0, time.UTC)
	snap, _, err := srv.PollOnce(now)
	if err != nil {
		t.Fatalf("PollOnce: %v", err)
	}

	data, err := marshalSnapshot(snap)
	if err != nil {
		t.Fatalf("marshalSnapshot: %v", err)
	}

	var doc any
	if err := json.Unmarshal(data, &doc); err != nil {
		t.Fatalf("re-decoding the marshalled snapshot: %v", err)
	}

	schemaPath := filepath.Join(repoRoot(t), "schema", "yard-snapshot.schema.json")
	c := jsonschema.NewCompiler()
	sch, err := c.Compile(schemaPath)
	if err != nil {
		t.Fatalf("compiling %s: %v", schemaPath, err)
	}
	if err := sch.Validate(doc); err != nil {
		t.Fatalf("assembled snapshot failed wire-schema validation: %v\nsnapshot: %s", err, data)
	}
}
