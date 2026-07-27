package main

import (
	"encoding/json"
	"path/filepath"
	"testing"
	"time"

	"github.com/polecatspeaks/StarCar/board/assemble"
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
			"tickets": ["#28", "#12"],
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
		"findings": "1 Major, 0 Minor",
		"abstract": "a",
		"normalisation": [],
		"integrity": "sha256:0000000000000000000000000000000000000000000000000000000000000000"
	}`)
	writeRecord(t, root, "orphan-1/dispatched-1.json", validDispatchedJSON("orphan-1", "2026-07-23T09:06:00Z"))
	// #84: freight - a ticket-sync heartbeat plus one queued ticket - proves
	// the newly-live fourth lane's payload validates against the same wire
	// schema alongside trains/gates/dispatches in one real assembled snapshot.
	writeRecord(t, root, "ticket-sync/ticket-sync.json", validTicketSyncJSON("2026-07-23T09:19:50Z"))
	writeRecord(t, root, "ticket-84/ticket.json", validTicketJSON("ticket-84", "2026-07-23T09:19:50Z", 84, "Light up the FREIGHT lane", "Backlog", "https://github.com/polecatspeaks/StarCar/issues/84"))

	cfg := testConfig(t, root)
	cfg.RepoRoot = filepath.Dir(root) // root itself is NOT "artifacts", but any parent proves the prefix computes
	cfg.GitHubRepo = "polecatspeaks/StarCar"
	srv, err := NewServer(cfg)
	if err != nil {
		t.Fatalf("NewServer: %v", err)
	}
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

	// #28/#12: the new fields must actually be PRESENT and correctly shaped
	// on the real, schema-validated wire output - not merely schema-legal
	// (an absent optional field also validates, which would let a silent
	// wiring bug through undetected).
	if snap.Config.GitHubRepoURL != "https://github.com/polecatspeaks/StarCar" {
		t.Errorf("Config.GitHubRepoURL = %q", snap.Config.GitHubRepoURL)
	}
	if snap.Config.GitHubArtifactsPrefix == "" {
		t.Errorf("Config.GitHubArtifactsPrefix must be non-empty when RepoRoot is a real ancestor of StorePath")
	}
	var trainsLane, gatesLane, dispatchesLane, freightLane Lane
	for _, l := range snap.Lanes {
		switch l.ID {
		case "trains":
			trainsLane = l
		case "gates":
			gatesLane = l
		case "dispatches":
			dispatchesLane = l
		case "freight":
			freightLane = l
		}
	}
	trainsPayload, ok := trainsLane.Data.(assemble.TrainsPayload)
	if !ok {
		t.Fatalf("trains lane Data is %T, want assemble.TrainsPayload", trainsLane.Data)
	}
	if len(trainsPayload.Trains) != 1 || len(trainsPayload.Trains[0].Tickets) != 2 {
		t.Fatalf("expected 1 train with 2 tickets, got %+v", trainsPayload.Trains)
	}
	var carA assemble.TrainCar
	for _, c := range trainsPayload.Trains[0].Cars {
		if c.Subject == "carA" {
			carA = c
		}
	}
	if carA.RecordDir != "carA" {
		t.Errorf("carA.RecordDir = %q, want carA", carA.RecordDir)
	}

	gatesPayload, ok := gatesLane.Data.(assemble.GatesPayload)
	if !ok {
		t.Fatalf("gates lane Data is %T, want assemble.GatesPayload", gatesLane.Data)
	}
	if len(gatesPayload.Gates) != 1 {
		t.Fatalf("expected 1 gate, got %d", len(gatesPayload.Gates))
	}
	if gatesPayload.Gates[0].RecordDir != "gate-1" {
		t.Errorf("gate.RecordDir = %q, want gate-1", gatesPayload.Gates[0].RecordDir)
	}
	if gatesPayload.Gates[0].Findings != "1 Major, 0 Minor" {
		t.Errorf("gate.Findings = %q", gatesPayload.Gates[0].Findings)
	}

	dispatchesPayload, ok := dispatchesLane.Data.(assemble.DispatchesPayload)
	if !ok {
		t.Fatalf("dispatches lane Data is %T, want assemble.DispatchesPayload", dispatchesLane.Data)
	}
	var orphanDir string
	for _, d := range dispatchesPayload.Dispatches {
		if d["subject"] == "orphan-1" {
			orphanDir, _ = d["recordDir"].(string)
		}
	}
	if orphanDir != "orphan-1" {
		t.Errorf("orphan-1 recordDir = %q, want orphan-1", orphanDir)
	}

	// #84: freight - the newly-live fourth lane, on the SAME real
	// schema-validated wire output as trains/gates/dispatches above.
	if freightLane.Freshness.Kind != "fresh" {
		t.Errorf("freight freshness = %q, want fresh (ticket-sync is 10s old, stalenessMs default 15000)", freightLane.Freshness.Kind)
	}
	freightPayload, ok := freightLane.Data.(assemble.FreightPayload)
	if !ok {
		t.Fatalf("freight lane Data is %T, want assemble.FreightPayload", freightLane.Data)
	}
	if len(freightPayload.Tickets) != 1 {
		t.Fatalf("expected 1 ticket, got %d", len(freightPayload.Tickets))
	}
	if freightPayload.Tickets[0].Number != 84 || freightPayload.Tickets[0].RecordDir != "ticket-84" {
		t.Errorf("unexpected ticket shape: %+v", freightPayload.Tickets[0])
	}
}
