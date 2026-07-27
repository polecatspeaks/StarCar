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

// TestAssembleManifestMembershipCollisionCarriesRecordDir (#69/#71:
// clickable provenance) - the collision condition names the claimed
// dispatch's own record directory (recAt gives it a real store path, unlike
// TestAssembleManifestMembershipCollision above's simplified dispatched()
// helper).
func TestAssembleManifestMembershipCollisionCarriesRecordDir(t *testing.T) {
	records := []store.Record{
		manifestIntent("train:alpha", "2026-07-23T09:00:00Z", "Alpha", []map[string]any{
			{"subject": "shared-dispatch", "role": "car"},
		}),
		manifestIntent("train:bravo", "2026-07-23T09:00:00Z", "Bravo", []map[string]any{
			{"subject": "shared-dispatch", "role": "car"},
		}),
		recAt("shared-dispatch/dispatched-1.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "dispatched", "subject": "shared-dispatch",
			"session_id": "s1", "at": "2026-07-23T09:05:00Z", "normalisation": []any{}, "integrity": "sha256:0",
		}),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)
	result := Assemble(Input{Records: records, Fold: out})

	var found bool
	for _, cond := range result.Conditions {
		if cond.Code == "manifest-membership-collision" {
			found = true
			if cond.RecordDir != "shared-dispatch" {
				t.Errorf("RecordDir = %q, want %q", cond.RecordDir, "shared-dispatch")
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

// TestAssembleSubjectNamespaceCollisionCarriesRecordDir (#69/#71: clickable
// provenance) - the collision condition names the colliding subject's own
// record directory, derived (single-sourced, Law 6) from a REAL store path,
// unlike TestAssembleSubjectNamespaceCollision above which uses the
// simplified rec() helper (Path=subject, no directory component, so
// recordDirBySubject correctly resolves nothing there - this test uses
// recAt to prove the POSITIVE case).
func TestAssembleSubjectNamespaceCollisionCarriesRecordDir(t *testing.T) {
	records := []store.Record{
		recAt("collide-1/dispatched-1.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "dispatched", "subject": "collide-1",
			"session_id": "s1", "at": "2026-07-23T09:00:00Z", "normalisation": []any{}, "integrity": "sha256:0",
		}),
		recAt("collide-1/intent-1.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "intent", "subject": "collide-1",
			"session_id": "s1", "at": "2026-07-23T09:05:00Z", "normalisation": []any{}, "integrity": "sha256:0",
		}),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)
	result := Assemble(Input{Records: records, Fold: out})

	var found bool
	for _, cond := range result.Conditions {
		if cond.Code == "subject-namespace-collision" {
			found = true
			if cond.RecordDir != "collide-1" {
				t.Errorf("RecordDir = %q, want %q", cond.RecordDir, "collide-1")
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

// --- #28: clickable provenance ---------------------------------------------

// manifestIntentWithTickets is manifestIntent plus the manifest.tickets array
// (schema/starcar-manifest.schema.json already declares this key; only
// manifestPayload was never reading it - design DR3-1's own quote: "the
// manifest PAYLOAD - members, roles, title, ticket refs - is NOT in fold
// output and never will be; it lives in the raw intent records").
func manifestIntentWithTickets(subject, at, title string, tickets []string, members []map[string]any) store.Record {
	membersAny := make([]any, len(members))
	for i, m := range members {
		membersAny[i] = m
	}
	ticketsAny := make([]any, len(tickets))
	for i, tk := range tickets {
		ticketsAny[i] = tk
	}
	return rec(map[string]any{
		"schema": "starcar-artifact/1", "kind": "intent", "subject": subject,
		"session_id": "s1", "at": at, "normalisation": []any{}, "integrity": "sha256:0",
		"manifest": map[string]any{"title": title, "tickets": ticketsAny, "members": membersAny},
	})
}

// recAt is store.Record{Path, Fields} with an explicit, REALISTIC repo-store
// path (subject/kind-timestamp.json), unlike the shared rec() helper (which
// sets Path=subject as a simplification the other tests never depend on) -
// needed here because recordDirBySubject derives a value FROM Path, so a
// test proving that derivation needs Path shaped like the real store's.
func recAt(path string, fields map[string]any) store.Record {
	return store.Record{Path: path, Fields: fields}
}

// TestAssembleTrainCarriesTicketsFromManifest: issue #28's "#N tokens ...
// link to issues" surface - the manifest's own declared tickets array
// (already schema-declared, schema/starcar-manifest.schema.json) flows
// through onto the wire train, structured, never re-parsed from title prose.
func TestAssembleTrainCarriesTicketsFromManifest(t *testing.T) {
	records := []store.Record{
		manifestIntentWithTickets("train:view-28-12", "2026-07-26T09:00:00Z", "Provenance + health bar", []string{"#28", "#12"},
			[]map[string]any{{"subject": "carA", "role": "car"}}),
		dispatched("carA", "2026-07-26T09:05:00Z"),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)
	result := Assemble(Input{Records: records, Fold: out})
	if len(result.Trains.Trains) != 1 {
		t.Fatalf("expected 1 train, got %d", len(result.Trains.Trains))
	}
	got := result.Trains.Trains[0].Tickets
	if len(got) != 2 || got[0] != "#28" || got[1] != "#12" {
		t.Fatalf("Tickets = %v, want [#28 #12]", got)
	}
}

// TestAssembleTrainNoTicketsIsEmptyNeverGuessed: a manifest that declares no
// tickets array carries an empty (never nil-vs-guessed) Tickets slice - Law
// 1, honest-empty rather than inventing a ticket reference.
func TestAssembleTrainNoTicketsIsEmptyNeverGuessed(t *testing.T) {
	records := []store.Record{
		manifestIntent("train:no-tickets", "2026-07-26T09:00:00Z", "No tickets declared",
			[]map[string]any{{"subject": "carA", "role": "car"}}),
		dispatched("carA", "2026-07-26T09:05:00Z"),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)
	result := Assemble(Input{Records: records, Fold: out})
	if len(result.Trains.Trains[0].Tickets) != 0 {
		t.Fatalf("Tickets = %v, want empty", result.Trains.Trains[0].Tickets)
	}
}

// TestAssembleRecordDirSingleSourcedFromStorePath proves car/gate/dispatch
// entries all carry a recordDir derived from store.Record.Path (design
// note 1 on issue #28: "the wire exposes each entry's record path - the
// adapter already knows it; emitting it is single-source, while view-side
// re-derivation would duplicate the subject-sanitisation rule (Law 6)") -
// never re-derived from the subject string client-side.
func TestAssembleRecordDirSingleSourcedFromStorePath(t *testing.T) {
	records := []store.Record{
		manifestIntent("train:board-v0", "2026-07-26T09:00:00Z", "T", []map[string]any{
			{"subject": "carA", "role": "car"},
			{"subject": "gate-1", "role": "gate", "gate": "design review round 1"},
		}),
		recAt("carA/dispatched-1.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "dispatched", "subject": "carA",
			"session_id": "s1", "at": "2026-07-26T09:05:00Z", "normalisation": []any{}, "integrity": "sha256:0",
		}),
		recAt("gate-1/returned-1.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "returned", "subject": "gate-1",
			"session_id": "s1", "at": "2026-07-26T09:10:00Z", "outcome": "REJECT",
			"findings": "1 Major, 0 Minor", "abstract": "a",
			"normalisation": []any{}, "integrity": "sha256:0",
		}),
		recAt("orphan-1/dispatched-1.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "dispatched", "subject": "orphan-1",
			"session_id": "s1", "at": "2026-07-26T09:06:00Z", "normalisation": []any{}, "integrity": "sha256:0",
		}),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)
	result := Assemble(Input{Records: records, Fold: out})

	train := result.Trains.Trains[0]
	byCar := map[string]TrainCar{}
	for _, c := range train.Cars {
		byCar[c.Subject] = c
	}
	if byCar["carA"].RecordDir != "carA" {
		t.Errorf("carA.RecordDir = %q, want carA", byCar["carA"].RecordDir)
	}

	if len(result.Gates.Gates) != 1 {
		t.Fatalf("expected 1 gate, got %d", len(result.Gates.Gates))
	}
	gate := result.Gates.Gates[0]
	if gate.RecordDir != "gate-1" {
		t.Errorf("gate.RecordDir = %q, want gate-1", gate.RecordDir)
	}
	if gate.Findings != "1 Major, 0 Minor" {
		t.Errorf("gate.Findings = %q, want the returned record's findings text verbatim", gate.Findings)
	}

	var orphanDir string
	var orphanFound bool
	for _, d := range result.Dispatches.Dispatches {
		if d["subject"] == "orphan-1" {
			orphanFound = true
			orphanDir, _ = d["recordDir"].(string)
		}
	}
	if !orphanFound {
		t.Fatalf("expected orphan-1 in the dispatches lane")
	}
	if orphanDir != "orphan-1" {
		t.Errorf("orphan-1 recordDir = %q, want orphan-1", orphanDir)
	}
}

// TestAssembleManifestRecordNotFoundCarriesRecordDir (#69/#71: clickable
// provenance) - the fold names a winning manifest at an "at" no raw intent
// record matches, but ANOTHER record for the SAME subject IS in the store
// (a stray dispatched record, standing in for "some record proves this
// subject's own directory"), so the condition still resolves a RecordDir
// even though the SPECIFIC manifest record it complains about was never
// found - honest best-effort, never a guess about a directory that does not
// exist.
func TestAssembleManifestRecordNotFoundCarriesRecordDir(t *testing.T) {
	records := []store.Record{
		recAt("train:missing-intent/dispatched-1.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "dispatched", "subject": "train:missing-intent",
			"session_id": "s1", "at": "2026-07-27T09:00:00Z", "normalisation": []any{}, "integrity": "sha256:0",
		}),
	}
	handBuiltOut := fold.Output{
		Intents: []fold.IntentEntry{{Subject: "train:missing-intent", At: "2026-07-27T08:00:00Z"}},
	}
	result := Assemble(Input{Records: records, Fold: handBuiltOut})

	var found bool
	for _, cond := range result.Conditions {
		if cond.Code == "manifest-record-not-found" {
			found = true
			if cond.RecordDir != "train:missing-intent" {
				t.Errorf("RecordDir = %q, want %q", cond.RecordDir, "train:missing-intent")
			}
		}
	}
	if !found {
		t.Fatalf("expected a manifest-record-not-found board condition, got %v", result.Conditions)
	}
}

// TestAssembleManifestPayloadUnreadableCarriesRecordDir (#69/#71: clickable
// provenance) - the intent record itself IS found, but its "manifest" key is
// absent (manifestPayload returns ok=false); the condition still names that
// same record's own directory.
func TestAssembleManifestPayloadUnreadableCarriesRecordDir(t *testing.T) {
	records := []store.Record{
		recAt("train:bad-payload/intent-1.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "intent", "subject": "train:bad-payload",
			"session_id": "s1", "at": "2026-07-27T09:00:00Z", "normalisation": []any{}, "integrity": "sha256:0",
			// no "manifest" key - manifestPayload must return ok=false
		}),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)
	result := Assemble(Input{Records: records, Fold: out})

	var found bool
	for _, cond := range result.Conditions {
		if cond.Code == "manifest-payload-unreadable" {
			found = true
			if cond.RecordDir != "train:bad-payload" {
				t.Errorf("RecordDir = %q, want %q", cond.RecordDir, "train:bad-payload")
			}
		}
	}
	if !found {
		t.Fatalf("expected a manifest-payload-unreadable board condition, got %v", result.Conditions)
	}
}

// TestAssembleGateFindingsRecordNotFoundCarriesRecordDir (#69/#71: clickable
// provenance) - companion to TestAssembleGateFindingsRecordNotFoundDisclosed
// above, asserting the RecordDir this ticket adds to that same condition.
func TestAssembleGateFindingsRecordNotFoundCarriesRecordDir(t *testing.T) {
	records := []store.Record{
		manifestIntent("train:board-v0", "2026-07-26T09:00:00Z", "T", []map[string]any{
			{"subject": "gate-1", "role": "gate", "gate": "design review round 1"},
		}),
		recAt("gate-1/returned-1.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "returned", "subject": "gate-1",
			"session_id": "s1", "at": "2026-07-26T10:00:00Z", "outcome": "REJECT",
			"findings": "3 Major, 1 Minor", "abstract": "a",
			"normalisation": []any{}, "integrity": "sha256:0",
		}),
	}
	handBuiltOut := fold.Output{
		Intents: []fold.IntentEntry{{Subject: "train:board-v0", At: "2026-07-26T09:00:00Z"}},
		Dispatches: []fold.DispatchEntry{
			{Subject: "gate-1", State: "returned", At: "2026-07-26T11:00:00Z", Outcome: "APPROVE"},
		},
	}
	result := Assemble(Input{Records: records, Fold: handBuiltOut})

	var found bool
	for _, cond := range result.Conditions {
		if cond.Code == "gate-findings-record-not-found" {
			found = true
			if cond.RecordDir != "gate-1" {
				t.Errorf("RecordDir = %q, want %q", cond.RecordDir, "gate-1")
			}
		}
	}
	if !found {
		t.Fatalf("expected a gate-findings-record-not-found board condition, got %v", result.Conditions)
	}
}

// TestAssembleGateFindingsMatchesFoldWinnerNotFirstScanOrder is MAJOR-4's
// red-first pin (review round 1, 2026-07-26, #28/#12 fix cycle round 2):
// findingsForReturnedSubject used to return the FIRST subject-matching
// returned record in whatever order in.Records happened to arrive (in
// production, store.go's sort.Strings on PATH, which puts an earlier
// timestamp-in-filename first) - while the fold's own winner
// (algorithm.go's parseInstant .After comparison) is the NEWEST at. This
// test constructs an OLDER (superseded, REJECT, "3 Major, 1 Minor") record
// BEFORE a NEWER (winning, APPROVE, "0 Major, 0 Minor") one in in.Records,
// reproducing exactly the shape the reviewer found live in the real store
// (30 subjects there carry 2-5 returned records - the dominant shape, not
// an edge case).
func TestAssembleGateFindingsMatchesFoldWinnerNotFirstScanOrder(t *testing.T) {
	records := []store.Record{
		manifestIntent("train:board-v0", "2026-07-26T09:00:00Z", "T", []map[string]any{
			{"subject": "gate-1", "role": "gate", "gate": "design review round 1"},
		}),
		recAt("gate-1/returned-1-earlier.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "returned", "subject": "gate-1",
			"session_id": "s1", "at": "2026-07-26T10:00:00Z", "outcome": "REJECT",
			"findings": "3 Major, 1 Minor", "abstract": "a",
			"normalisation": []any{}, "integrity": "sha256:0",
		}),
		recAt("gate-1/returned-2-later.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "returned", "subject": "gate-1",
			"session_id": "s1", "at": "2026-07-26T11:00:00Z", "outcome": "APPROVE",
			"findings": "0 Major, 0 Minor", "abstract": "a",
			"normalisation": []any{}, "integrity": "sha256:0",
		}),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)
	result := Assemble(Input{Records: records, Fold: out})

	if len(result.Gates.Gates) != 1 {
		t.Fatalf("expected 1 gate, got %d", len(result.Gates.Gates))
	}
	gate := result.Gates.Gates[0]
	if gate.Outcome != "APPROVE" {
		t.Fatalf("test setup: expected the fold's winner to be the NEWER (APPROVE) record, got outcome %q - fold precedence assumption broken, not the fix under test", gate.Outcome)
	}
	if gate.At != "2026-07-26T11:00:00Z" {
		t.Fatalf("test setup: expected the fold's winner At to be the NEWER 11:00 record, got %q", gate.At)
	}
	if gate.Findings != "0 Major, 0 Minor" {
		t.Errorf("gate.Findings = %q, want the WINNING (newer, APPROVE, 11:00) record's findings %q - not the superseded 10:00 REJECT record's %q",
			gate.Findings, "0 Major, 0 Minor", "3 Major, 1 Minor")
	}
}

// TestAssembleGateFindingsRecordNotFoundDisclosed is the Go-side ASSERTION
// the round-1 review asked for (MAJOR-4): if the fold ever names a
// "returned" gate winner whose subject+at has no matching raw record (a
// data-integrity contradiction that should be unreachable in production,
// since the fold is built FROM the same records Assemble receives), that
// is disclosed as its own board condition rather than silently rendering
// an empty Findings string as if the record simply carried none. This
// test constructs the contradiction directly (a hand-built fold.Output
// naming a winner at an "at" no raw record actually carries) - the only
// way to reach this path, since fold.Fold itself cannot produce it from
// consistent input.
func TestAssembleGateFindingsRecordNotFoundDisclosed(t *testing.T) {
	records := []store.Record{
		manifestIntent("train:board-v0", "2026-07-26T09:00:00Z", "T", []map[string]any{
			{"subject": "gate-1", "role": "gate", "gate": "design review round 1"},
		}),
		// The only returned record for gate-1 is at 10:00 - the hand-built
		// fold output below claims a DIFFERENT (11:00) winner timestamp,
		// which no raw record matches.
		recAt("gate-1/returned-1.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "returned", "subject": "gate-1",
			"session_id": "s1", "at": "2026-07-26T10:00:00Z", "outcome": "REJECT",
			"findings": "3 Major, 1 Minor", "abstract": "a",
			"normalisation": []any{}, "integrity": "sha256:0",
		}),
	}
	handBuiltOut := fold.Output{
		Intents: []fold.IntentEntry{{Subject: "train:board-v0", At: "2026-07-26T09:00:00Z"}},
		Dispatches: []fold.DispatchEntry{
			{Subject: "gate-1", State: "returned", At: "2026-07-26T11:00:00Z", Outcome: "APPROVE"},
		},
	}
	result := Assemble(Input{Records: records, Fold: handBuiltOut})

	if len(result.Gates.Gates) != 1 {
		t.Fatalf("expected 1 gate, got %d", len(result.Gates.Gates))
	}
	if result.Gates.Gates[0].Findings != "" {
		t.Errorf("Findings = %q, want empty (Law 1: never a guessed value when no matching record was found)", result.Gates.Gates[0].Findings)
	}

	var found bool
	for _, cond := range result.Conditions {
		if cond.Code == "gate-findings-record-not-found" {
			found = true
			if cond.Register != "needs-attention" {
				t.Errorf("condition register = %q, want needs-attention", cond.Register)
			}
			if !strings.Contains(cond.Detail, "gate-1") {
				t.Errorf("condition detail must name the subject, got %q", cond.Detail)
			}
		}
	}
	if !found {
		t.Fatalf("expected a gate-findings-record-not-found board condition, got %v", result.Conditions)
	}
}

// TestAssembleDispatchRenderFailedIsReachable (#69/#71 fix cycle round 2,
// MAJOR-R1-3) - CORRECTS a false claim that used to sit at assemble.go's
// dispatch-render-failed branch and in this train's own commit message:
// "d.winnerKind (the only field that can make MarshalJSON emit an
// unencodable spend value) is unexported, so no test outside board/fold can
// construct a fold.DispatchEntry that reaches this branch." winnerKind
// SELECTS the branch, but it is Spend (fold.go:112, EXPORTED) that carries
// the unencodable value, and Output.Dispatches (fold/output.go) is exported
// too - so a package OUTSIDE board/fold can reach it without ever touching
// winnerKind directly: run the REAL fold.Fold on a genuine returned-wins
// record pair (which sets winnerKind == "returned" internally, inside
// package fold, the only place that can), then mutate the returned entry's
// exported Spend field to a value json.Marshal cannot encode (a channel).
// Reached through the real Assemble() entry point, never dispatchWireMap
// called directly, so this also proves the condition's RecordDir survives
// end to end exactly like every other population site's own RecordDir test.
func TestAssembleDispatchRenderFailedIsReachable(t *testing.T) {
	records := []store.Record{
		recAt("probe-subj/dispatched-1.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "dispatched", "subject": "probe-subj",
			"session_id": "s1", "at": "2026-07-27T09:00:00Z", "normalisation": []any{}, "integrity": "sha256:0",
		}),
		recAt("probe-subj/returned-1.json", map[string]any{
			"schema": "starcar-artifact/1", "kind": "returned", "subject": "probe-subj",
			"session_id": "s1", "at": "2026-07-27T10:00:00Z", "outcome": "done",
			"findings": "f", "abstract": "a", "spend": map[string]any{"tokens": 1},
			"normalisation": []any{}, "integrity": "sha256:0",
		}),
	}
	out := fold.Fold(foldRecords(records), testVocab, now)

	// Find the real "returned"-winner entry the fold itself produced
	// (winnerKind set internally, inside package fold - never by this test)
	// and mutate ONLY its exported Spend field to something json.Marshal
	// cannot encode. A channel is Go's canonical "cannot be JSON-encoded"
	// value (encoding/json's own documented limitation), the same choice
	// the round-1 reviewer's disproof probe used.
	mutated := false
	for i := range out.Dispatches {
		if out.Dispatches[i].Subject == "probe-subj" {
			out.Dispatches[i].Spend = make(chan int)
			mutated = true
		}
	}
	if !mutated {
		t.Fatalf("test precondition not met: expected a 'probe-subj' entry in fold.Fold's output, got %+v", out.Dispatches)
	}

	result := Assemble(Input{Records: records, Fold: out})

	var found bool
	for _, cond := range result.Conditions {
		if cond.Code == "dispatch-render-failed" {
			found = true
			if !strings.Contains(cond.Detail, "probe-subj") {
				t.Errorf("condition detail must name the subject, got %q", cond.Detail)
			}
			if cond.RecordDir != "probe-subj" {
				t.Errorf("RecordDir = %q, want %q", cond.RecordDir, "probe-subj")
			}
		}
	}
	if !found {
		t.Fatalf("expected a dispatch-render-failed board condition (branch was claimed unreachable outside board/fold - disproven), got %v", result.Conditions)
	}

	// The subject must NOT also appear in the ordinary dispatches list -
	// dispatchWireMap's error path `continue`s past the append (assemble.go)
	// rather than emitting a half-built entry.
	for _, d := range result.Dispatches.Dispatches {
		if d["subject"] == "probe-subj" {
			t.Errorf("probe-subj should not appear in Dispatches.Dispatches when its render failed, got %v", d)
		}
	}
}
