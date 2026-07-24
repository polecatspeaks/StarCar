package assemble

import (
	"strings"
	"testing"
	"time"

	"github.com/polecatspeaks/StarCar/board/fold"
	"github.com/polecatspeaks/StarCar/board/store"
)

var testVocab = fold.Vocab{
	Kinds:    []string{"dispatched", "returned", "presumed-lost", "intent", "ruling"},
	Outcomes: []string{"APPROVE", "REJECT", "done"},
}

func rec(fields map[string]any) store.Record {
	return store.Record{Path: fields["subject"].(string), Fields: fields}
}

func manifestIntent(subject, at, title string, members []map[string]any) store.Record {
	membersAny := make([]any, len(members))
	for i, m := range members {
		membersAny[i] = m
	}
	return rec(map[string]any{
		"schema":        "starcar-artifact/1",
		"kind":          "intent",
		"subject":       subject,
		"session_id":    "s1",
		"at":            at,
		"normalisation": []any{},
		"integrity":     "sha256:0",
		"manifest": map[string]any{
			"title":   title,
			"members": membersAny,
		},
	})
}

func dispatched(subject, at string) store.Record {
	return rec(map[string]any{
		"schema": "starcar-artifact/1", "kind": "dispatched", "subject": subject,
		"session_id": "s1", "at": at, "normalisation": []any{}, "integrity": "sha256:0",
	})
}

func returned(subject, at, outcome string) store.Record {
	return rec(map[string]any{
		"schema": "starcar-artifact/1", "kind": "returned", "subject": subject,
		"session_id": "s1", "at": at, "outcome": outcome, "findings": "f", "abstract": "a",
		"normalisation": []any{}, "integrity": "sha256:0",
	})
}

func foldRecords(recs []store.Record) []fold.Record {
	out := make([]fold.Record, len(recs))
	for i, r := range recs {
		out[i] = fold.Record(r.Fields)
	}
	return out
}

var now = time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC)

// TestAssembleTrainJoinsWinningManifestAndDeclaredNotObserved covers the 5.3
// two-step join: the fold names the winning manifest per train subject, the
// Assembler fetches THAT record's payload (never re-selecting "latest"
// itself) and joins each declared member to its dispatch liveness, or lists
// it declaredNotObserved when no record exists for it.
func TestAssembleTrainJoinsWinningManifestAndDeclaredNotObserved(t *testing.T) {
	records := []store.Record{
		manifestIntent("train:board-v0", "2026-07-23T09:00:00Z", "The yard board train",
			[]map[string]any{
				{"subject": "carA", "role": "car"},
				{"subject": "reviewerA", "role": "reviewer"},
				{"subject": "ghost-car", "role": "car"}, // no record anywhere - declaredNotObserved
			}),
		dispatched("carA", "2026-07-23T09:05:00Z"),
		returned("reviewerA", "2026-07-23T10:00:00Z", "APPROVE"),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)

	result := Assemble(Input{Records: records, Fold: out})
	if len(result.Trains.Trains) != 1 {
		t.Fatalf("expected 1 train, got %d: %+v", len(result.Trains.Trains), result.Trains)
	}
	train := result.Trains.Trains[0]
	if train.ID != "train:board-v0" {
		t.Errorf("train.ID = %q, want the whole train: subject, never stripped", train.ID)
	}
	if train.Title != "The yard board train" {
		t.Errorf("train.Title = %q", train.Title)
	}
	if len(train.Cars) != 2 {
		t.Fatalf("expected 2 observed cars, got %d: %+v", len(train.Cars), train.Cars)
	}
	byCar := map[string]TrainCar{}
	for _, c := range train.Cars {
		byCar[c.Subject] = c
	}
	if byCar["carA"].State != "dispatched" {
		t.Errorf("carA.State = %q, want dispatched", byCar["carA"].State)
	}
	if byCar["reviewerA"].State != "returned" || byCar["reviewerA"].Outcome != "APPROVE" {
		t.Errorf("reviewerA = %+v, want state=returned outcome=APPROVE (verbatim)", byCar["reviewerA"])
	}
	if len(train.DeclaredNotObserved) != 1 || train.DeclaredNotObserved[0] != "ghost-car" {
		t.Errorf("DeclaredNotObserved = %v, want [ghost-car]", train.DeclaredNotObserved)
	}
}

// TestAssembleSupersedingManifestWins proves the Assembler NEVER re-selects
// "latest manifest" itself (design 5.3's Law 6 trap): it consumes exactly the
// subject+at the fold already named as the winning intent, and the
// superseded manifest's stale membership never leaks into the rendered train.
func TestAssembleSupersedingManifestWins(t *testing.T) {
	records := []store.Record{
		manifestIntent("train:board-v0", "2026-07-23T09:00:00Z", "Old title", []map[string]any{
			{"subject": "staleCar", "role": "car"},
		}),
		manifestIntent("train:board-v0", "2026-07-23T09:30:00Z", "New title", []map[string]any{
			{"subject": "freshCar", "role": "car"},
		}),
		dispatched("freshCar", "2026-07-23T09:31:00Z"),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)

	result := Assemble(Input{Records: records, Fold: out})
	if len(result.Trains.Trains) != 1 {
		t.Fatalf("expected 1 train (supersession collapses to one winner), got %d", len(result.Trains.Trains))
	}
	train := result.Trains.Trains[0]
	if train.Title != "New title" {
		t.Fatalf("train.Title = %q, want the WINNING manifest's title 'New title'", train.Title)
	}
	for _, c := range train.Cars {
		if c.Subject == "staleCar" {
			t.Fatalf("the superseded manifest's member 'staleCar' leaked into the rendered train")
		}
	}
}

// TestAssembleManifestMembershipCollision is YB-14's red-first pin: two
// different manifests both claiming one dispatch subject render the dispatch
// in BOTH trains, and raise a named board condition - never silently
// resolved by precedence.
func TestAssembleManifestMembershipCollision(t *testing.T) {
	records := []store.Record{
		manifestIntent("train:alpha", "2026-07-23T09:00:00Z", "Alpha", []map[string]any{
			{"subject": "shared-dispatch", "role": "car"},
		}),
		manifestIntent("train:bravo", "2026-07-23T09:00:00Z", "Bravo", []map[string]any{
			{"subject": "shared-dispatch", "role": "car"},
		}),
		dispatched("shared-dispatch", "2026-07-23T09:05:00Z"),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)

	result := Assemble(Input{Records: records, Fold: out})
	if len(result.Trains.Trains) != 2 {
		t.Fatalf("expected 2 trains, got %d", len(result.Trains.Trains))
	}
	claims := 0
	for _, tr := range result.Trains.Trains {
		for _, c := range tr.Cars {
			if c.Subject == "shared-dispatch" {
				claims++
			}
		}
	}
	if claims != 2 {
		t.Fatalf("expected the collided dispatch to render in BOTH trains, saw it %d time(s)", claims)
	}

	var found bool
	for _, cond := range result.Conditions {
		if cond.Code == "manifest-membership-collision" {
			found = true
			if !strings.Contains(cond.Detail, "shared-dispatch") {
				t.Errorf("collision detail must name the dispatch, got %q", cond.Detail)
			}
			if !strings.Contains(cond.Detail, "train:alpha") || !strings.Contains(cond.Detail, "train:bravo") {
				t.Errorf("collision detail must name BOTH train subjects, got %q", cond.Detail)
			}
			if cond.Register != "needs-attention" {
				t.Errorf("collision register = %q, want needs-attention", cond.Register)
			}
		}
	}
	if !found {
		t.Fatalf("expected a manifest-membership-collision board condition, got %v", result.Conditions)
	}
}

// TestAssembleSubjectNamespaceCollision is DR3-3's defensive detector: a
// subject appearing in BOTH fold.dispatches and fold.intents (a producer bug
// reusing one subject across kinds, defeating the train: partition
// convention) still raises a named board condition - the rule and the
// detector, both, deliberately.
func TestAssembleSubjectNamespaceCollision(t *testing.T) {
	records := []store.Record{
		dispatched("collide-1", "2026-07-23T09:00:00Z"),
		rec(map[string]any{
			"schema": "starcar-artifact/1", "kind": "intent", "subject": "collide-1",
			"session_id": "s1", "at": "2026-07-23T09:05:00Z",
			"normalisation": []any{}, "integrity": "sha256:0",
		}),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)
	if len(out.Dispatches) != 1 || len(out.Intents) != 1 {
		t.Fatalf("test setup: expected the fold itself to carry the collision in both outputs, got dispatches=%d intents=%d", len(out.Dispatches), len(out.Intents))
	}

	result := Assemble(Input{Records: records, Fold: out})
	var found bool
	for _, cond := range result.Conditions {
		if cond.Code == "subject-namespace-collision" {
			found = true
			if !strings.Contains(cond.Detail, "collide-1") {
				t.Errorf("detail must name the colliding subject, got %q", cond.Detail)
			}
		}
	}
	if !found {
		t.Fatalf("expected a subject-namespace-collision board condition, got %v", result.Conditions)
	}
}

// TestAssembleDispatchesAssignedFlag: yard inventory is dispatches lane
// entries with assigned=false (design: fold.dispatches MINUS the union of
// winning manifests' members).
func TestAssembleDispatchesAssignedFlag(t *testing.T) {
	records := []store.Record{
		manifestIntent("train:board-v0", "2026-07-23T09:00:00Z", "T", []map[string]any{
			{"subject": "carA", "role": "car"},
		}),
		dispatched("carA", "2026-07-23T09:05:00Z"),
		dispatched("orphan-1", "2026-07-23T09:06:00Z"),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)
	result := Assemble(Input{Records: records, Fold: out})

	if len(result.Dispatches.Dispatches) != 2 {
		t.Fatalf("expected 2 dispatch entries, got %d", len(result.Dispatches.Dispatches))
	}
	assigned := map[string]bool{}
	for _, d := range result.Dispatches.Dispatches {
		assigned[d["subject"].(string)] = d["assigned"].(bool)
	}
	if !assigned["carA"] {
		t.Errorf("carA (a declared manifest member) must be assigned=true")
	}
	if assigned["orphan-1"] {
		t.Errorf("orphan-1 (no manifest claims it) must be assigned=false - yard inventory, rendered loudly")
	}
}

// TestAssembleGatesVerbatimOutcome: gates render the returned record's
// outcome VERBATIM, with identity/role sourced from the manifest's
// declaration (never inferred from behaviour).
func TestAssembleGatesVerbatimOutcome(t *testing.T) {
	records := []store.Record{
		manifestIntent("train:board-v0", "2026-07-23T09:00:00Z", "T", []map[string]any{
			{"subject": "gate-1", "role": "gate", "gate": "design review round 1"},
			{"subject": "car-not-yet-returned", "role": "car"},
		}),
		returned("gate-1", "2026-07-23T09:10:00Z", "REJECT"),
		dispatched("car-not-yet-returned", "2026-07-23T09:11:00Z"),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)
	result := Assemble(Input{Records: records, Fold: out})

	if len(result.Gates.Gates) != 1 {
		t.Fatalf("expected exactly 1 gate (only the RETURNED member carries a verdict), got %d: %+v", len(result.Gates.Gates), result.Gates)
	}
	g := result.Gates.Gates[0]
	if g.Outcome != "REJECT" {
		t.Errorf("gate outcome must be VERBATIM 'REJECT' (a success outcome in this shop, never re-derived), got %q", g.Outcome)
	}
	if g.Name != "design review round 1" {
		t.Errorf("gate name should come from the member's gate declaration, got %q", g.Name)
	}
	if g.Subject != "gate-1" {
		t.Errorf("gate subject = %q", g.Subject)
	}
}

// TestAssembleNonTrainIntentIgnoredForTrains: a held-style intent (subject
// not train:-prefixed) never produces a Train entry - v0's four surfaces
// (design 5.3) do not include intent-override rendering.
func TestAssembleNonTrainIntentIgnoredForTrains(t *testing.T) {
	records := []store.Record{
		dispatched("some-dispatch", "2026-07-23T09:00:00Z"),
		rec(map[string]any{
			"schema": "starcar-artifact/1", "kind": "intent", "subject": "some-dispatch",
			"session_id": "s1", "at": "2026-07-23T09:01:00Z",
			"normalisation": []any{}, "integrity": "sha256:0",
		}),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)
	result := Assemble(Input{Records: records, Fold: out})
	if len(result.Trains.Trains) != 0 {
		t.Fatalf("a non-train: intent must not produce a Train entry, got %d", len(result.Trains.Trains))
	}
}
