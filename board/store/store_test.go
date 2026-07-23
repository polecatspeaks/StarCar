package store

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"
)

const fakeIntegrity = `"sha256:0000000000000000000000000000000000000000000000000000000000000000"`

func writeFixture(t *testing.T, dir, name, content string) string {
	t.Helper()
	path := filepath.Join(dir, name)
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		t.Fatalf("mkdir for %s: %v", path, err)
	}
	if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
		t.Fatalf("writing %s: %v", path, err)
	}
	return path
}

func validDispatchedRecord(subject, at string) string {
	return `{
		"schema": "starcar-artifact/1",
		"kind": "dispatched",
		"subject": "` + subject + `",
		"session_id": "session-1",
		"at": "` + at + `",
		"normalisation": [],
		"integrity": ` + fakeIntegrity + `
	}`
}

func newAdapter(t *testing.T) *Adapter {
	t.Helper()
	a, err := NewAdapter(schemaDir(t))
	if err != nil {
		t.Fatalf("NewAdapter: %v", err)
	}
	return a
}

// TestScanMissingDirectoryFails: design S6 row 1 - a missing/unreadable store
// directory is a SCAN-LEVEL failure (the caller renders freshness "failed"),
// never an honest-empty.
func TestScanMissingDirectoryFails(t *testing.T) {
	a := newAdapter(t)
	_, err := a.Scan(filepath.Join(t.TempDir(), "does-not-exist"), time.Now().UTC())
	if err == nil {
		t.Fatal("Scan of a missing directory returned no error - a missing store must fail the scan, not silently succeed")
	}
}

// TestScanEmptyStoreIsHonestEmpty: design S6 DR3-5a - a store directory that
// EXISTS but holds zero records is a SUCCESSFUL scan of zero records, not a
// failure, and carries zero quarantine/board conditions.
func TestScanEmptyStoreIsHonestEmpty(t *testing.T) {
	a := newAdapter(t)
	root := t.TempDir()
	result, err := a.Scan(root, time.Now().UTC())
	if err != nil {
		t.Fatalf("Scan of an existing-but-empty directory must succeed, got error: %v", err)
	}
	if len(result.Records) != 0 {
		t.Fatalf("expected 0 records, got %d", len(result.Records))
	}
	if len(result.Quarantined) != 0 {
		t.Fatalf("expected 0 quarantined, got %d", len(result.Quarantined))
	}
	if len(result.Conditions) != 0 {
		t.Fatalf("honest-empty must raise zero board conditions, got %v", result.Conditions)
	}
}

// TestScanAllQuarantined: design S6 DR3-5b - when every record in a
// non-empty store fails, that is its OWN state: an aggregate board condition
// "N of N records quarantined", distinct from honest-empty (zero-of-zero).
func TestScanAllQuarantined(t *testing.T) {
	a := newAdapter(t)
	root := t.TempDir()
	writeFixture(t, root, "a/dispatched-1.json", `{not valid json`)
	writeFixture(t, root, "b/dispatched-1.json", `{not valid json either`)

	result, err := a.Scan(root, time.Now().UTC())
	if err != nil {
		t.Fatalf("Scan must succeed even when every record quarantines: %v", err)
	}
	if len(result.Records) != 0 {
		t.Fatalf("expected 0 surviving records, got %d", len(result.Records))
	}
	if len(result.Quarantined) != 2 {
		t.Fatalf("expected 2 quarantined records, got %d", len(result.Quarantined))
	}

	var found bool
	for _, c := range result.Conditions {
		if c.Code == "all-records-quarantined" {
			found = true
			if !strings.Contains(c.Detail, "2 of 2") {
				t.Errorf("all-records-quarantined detail should name the N-of-N count, got %q", c.Detail)
			}
			if c.Register != "needs-attention" {
				t.Errorf("all-records-quarantined register = %q, want needs-attention", c.Register)
			}
		}
	}
	if !found {
		t.Fatalf("expected an 'all-records-quarantined' board condition, got %v", result.Conditions)
	}
}

// TestScanMidWritePartialJSONSelfHeals: design S6 Note-1 - a record file
// caught mid-write (truncated/partial JSON) is a transient one-poll
// quarantine that self-heals on the NEXT scan once the write completes -
// proven here by scanning once against a truncated file (quarantined), then
// again after the file is completed (survives), with no special code beyond
// a fresh stateless scan each time.
func TestScanMidWritePartialJSONSelfHeals(t *testing.T) {
	a := newAdapter(t)
	root := t.TempDir()
	path := writeFixture(t, root, "subj/dispatched-1.json", `{"schema": "starcar-artifact/1", "kind": "dispatched"`) // truncated, no closing brace

	result, err := a.Scan(root, time.Now().UTC())
	if err != nil {
		t.Fatalf("Scan: %v", err)
	}
	if len(result.Records) != 0 || len(result.Quarantined) != 1 {
		t.Fatalf("expected the truncated record quarantined and zero survivors, got records=%d quarantined=%d", len(result.Records), len(result.Quarantined))
	}

	// The write "completes" - the next poll's scan is a fresh stateless read.
	if err := os.WriteFile(path, []byte(validDispatchedRecord("subj", "2026-07-23T10:00:00Z")), 0o644); err != nil {
		t.Fatalf("completing the write: %v", err)
	}
	result2, err := a.Scan(root, time.Now().UTC())
	if err != nil {
		t.Fatalf("second Scan: %v", err)
	}
	if len(result2.Records) != 1 || len(result2.Quarantined) != 0 {
		t.Fatalf("expected the healed record to survive on the next scan, got records=%d quarantined=%d", len(result2.Records), len(result2.Quarantined))
	}
}

// TestScanUnknownFieldRecordDisclosed: design D17 - a record carrying a field
// outside the known key set (which now includes "manifest", DR3-1 item 4) is
// PRESERVED (it still survives into Records) and DISCLOSED via a named board
// condition - never silently dropped, never quarantined for this reason alone.
func TestScanUnknownFieldRecordDisclosed(t *testing.T) {
	a := newAdapter(t)
	root := t.TempDir()
	writeFixture(t, root, "subj/dispatched-1.json", `{
		"schema": "starcar-artifact/1",
		"kind": "dispatched",
		"subject": "subj",
		"session_id": "session-1",
		"at": "2026-07-23T10:00:00Z",
		"normalisation": [],
		"integrity": `+fakeIntegrity+`,
		"surprise_field": "unrecognised"
	}`)

	result, err := a.Scan(root, time.Now().UTC())
	if err != nil {
		t.Fatalf("Scan: %v", err)
	}
	if len(result.Records) != 1 {
		t.Fatalf("an unknown-field record must still SURVIVE (preserved), got %d records", len(result.Records))
	}
	if v, ok := result.Records[0].Fields["surprise_field"]; !ok || v != "unrecognised" {
		t.Fatalf("the unknown field's VALUE must be preserved in Fields, got %v", result.Records[0].Fields)
	}

	var found bool
	for _, c := range result.Conditions {
		if c.Code == "record-unrecognised-fields" {
			found = true
			if !strings.Contains(c.Detail, "surprise_field") {
				t.Errorf("disclosure must name the unrecognised field, got %q", c.Detail)
			}
			if !strings.Contains(c.Detail, "1") {
				t.Errorf("disclosure must name the COUNT of unrecognised fields, got %q", c.Detail)
			}
		}
	}
	if !found {
		t.Fatalf("expected a 'record-unrecognised-fields' board condition, got %v", result.Conditions)
	}
}

// TestScanMalformedAtQuarantined is the red-first pin for issue #24 (C3R-3,
// binding on this task): a record whose "at" is unparseable/malformed, OR
// ZONELESS (no Z/offset suffix - schema-valid because JSON Schema "format" is
// annotation-only under draft 2020-12, so schema validation alone cannot
// catch this), must be QUARANTINED before it ever reaches board/fold.Fold -
// proven here by the record being absent from Records, never merely flagged.
func TestScanMalformedAtQuarantined(t *testing.T) {
	cases := []struct {
		name string
		at   string
	}{
		{"garbage-string", "not-a-date-at-all"},
		{"zoneless-no-offset", "2026-07-23T10:00:00"}, // issue #24's exact example: no Z, no offset
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			a := newAdapter(t)
			root := t.TempDir()
			writeFixture(t, root, "subj/dispatched-1.json", `{
				"schema": "starcar-artifact/1",
				"kind": "dispatched",
				"subject": "subj",
				"session_id": "session-1",
				"at": "`+tc.at+`",
				"normalisation": [],
				"integrity": `+fakeIntegrity+`
			}`)

			result, err := a.Scan(root, time.Now().UTC())
			if err != nil {
				t.Fatalf("Scan: %v", err)
			}
			if len(result.Records) != 0 {
				t.Fatalf("issue #24: a malformed/zoneless 'at' must be quarantined (excluded from Records so it never reaches Fold), got %d survivors", len(result.Records))
			}
			if len(result.Quarantined) != 1 {
				t.Fatalf("expected exactly 1 quarantined record, got %d", len(result.Quarantined))
			}
			if !strings.Contains(result.Quarantined[0].Reason, "at") {
				t.Errorf("quarantine reason should name the 'at' field, got %q", result.Quarantined[0].Reason)
			}
		})
	}
}

// TestScanFutureDatedAtQuarantined: design S6 - a record whose "at" is in the
// future (relative to the scan's injected clock) is quarantined, never
// silently treated as the freshest/winning record (design: "never silently
// fresh").
func TestScanFutureDatedAtQuarantined(t *testing.T) {
	a := newAdapter(t)
	root := t.TempDir()
	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC)
	future := now.Add(24 * time.Hour).Format(time.RFC3339)
	writeFixture(t, root, "subj/dispatched-1.json", validDispatchedRecordAt("subj", future))

	result, err := a.Scan(root, now)
	if err != nil {
		t.Fatalf("Scan: %v", err)
	}
	if len(result.Records) != 0 {
		t.Fatalf("a future-dated 'at' must be quarantined, got %d survivors", len(result.Records))
	}
	if len(result.Quarantined) != 1 {
		t.Fatalf("expected exactly 1 quarantined record, got %d", len(result.Quarantined))
	}
	if !strings.Contains(result.Quarantined[0].Reason, "future") {
		t.Errorf("quarantine reason should name the future-dated cause, got %q", result.Quarantined[0].Reason)
	}
}

func validDispatchedRecordAt(subject, at string) string {
	return validDispatchedRecord(subject, at)
}

// TestScanSchemaShapeFailureQuarantined: design S6 row 3 - a record that
// fails starcar-artifact/1 schema-shape validation (here: missing required
// "session_id") is quarantined + a board condition names the file; other
// records still load (one bad record must not blank the board).
func TestScanSchemaShapeFailureQuarantined(t *testing.T) {
	a := newAdapter(t)
	root := t.TempDir()
	writeFixture(t, root, "bad/dispatched-1.json", `{
		"schema": "starcar-artifact/1",
		"kind": "dispatched",
		"subject": "bad",
		"at": "2026-07-23T10:00:00Z",
		"normalisation": [],
		"integrity": `+fakeIntegrity+`
	}`)
	writeFixture(t, root, "good/dispatched-1.json", validDispatchedRecord("good", "2026-07-23T10:00:00Z"))

	result, err := a.Scan(root, time.Now().UTC())
	if err != nil {
		t.Fatalf("Scan: %v", err)
	}
	if len(result.Records) != 1 {
		t.Fatalf("the good record must still load despite the bad one, got %d survivors", len(result.Records))
	}
	if result.Records[0].Fields["subject"] != "good" {
		t.Fatalf("the surviving record should be 'good', got %v", result.Records[0].Fields["subject"])
	}
	if len(result.Quarantined) != 1 {
		t.Fatalf("expected exactly 1 quarantined record, got %d", len(result.Quarantined))
	}

	var found bool
	for _, c := range result.Conditions {
		if c.Code == "record-quarantined" && strings.Contains(c.Detail, "bad") {
			found = true
		}
	}
	if !found {
		t.Fatalf("expected a 'record-quarantined' board condition naming the file, got %v", result.Conditions)
	}
}

// TestScanTrainManifestRecordSurvivesAndIsNotFlaggedUnknown proves the D17
// interaction (DR3-1 item 4): the manifest payload key joins the known
// key-set, so a well-formed train: manifest record does NOT trip the
// unknown-field disclosure.
func TestScanTrainManifestRecordSurvivesAndIsNotFlaggedUnknown(t *testing.T) {
	a := newAdapter(t)
	root := t.TempDir()
	writeFixture(t, root, "manifest/intent-1.json", `{
		"schema": "starcar-artifact/1",
		"kind": "intent",
		"subject": "train:board-v0",
		"session_id": "session-1",
		"at": "2026-07-23T10:00:00Z",
		"normalisation": [],
		"integrity": `+fakeIntegrity+`,
		"manifest": {
			"title": "The yard board train",
			"members": [ { "subject": "carA", "role": "car" } ]
		}
	}`)

	result, err := a.Scan(root, time.Now().UTC())
	if err != nil {
		t.Fatalf("Scan: %v", err)
	}
	if len(result.Records) != 1 {
		t.Fatalf("expected the manifest record to survive, got %d", len(result.Records))
	}
	for _, c := range result.Conditions {
		if c.Code == "record-unrecognised-fields" {
			t.Fatalf("a well-formed manifest must NOT trip unknown-field disclosure (DR3-1 item 4), got %v", c)
		}
	}
}

// TestScanKnownProducerFieldsNotUnrecognised is the red-first pin for issue
// #26: `model` (Produce-Artifact.ps1:285, dispatched-only, sourced from the
// Task tool_response's resolvedModel) and `body_file` (Migrate-Verdicts.ps1:152,
// migrated returned verdicts) are OBSERVED, PROVENANCED producer fields, not
// unknown ones - they must join the known key-set the same way "manifest" did
// (DR3-1 item 4) and must NOT trip record-unrecognised-fields.
func TestScanKnownProducerFieldsNotUnrecognised(t *testing.T) {
	a := newAdapter(t)
	root := t.TempDir()
	writeFixture(t, root, "dispatched-subj/dispatched-1.json", `{
		"schema": "starcar-artifact/1",
		"kind": "dispatched",
		"subject": "dispatched-subj",
		"session_id": "session-1",
		"at": "2026-07-23T10:00:00Z",
		"model": "claude-sonnet-5",
		"normalisation": [],
		"integrity": `+fakeIntegrity+`
	}`)
	writeFixture(t, root, "returned-subj/returned-1.json", `{
		"schema": "starcar-artifact/1",
		"kind": "returned",
		"subject": "returned-subj",
		"session_id": "session-1",
		"at": "2026-07-23T11:00:00Z",
		"outcome": "done",
		"findings": "none",
		"abstract": "migrated verdict",
		"body_file": "reviews/2026-07-23-example.md",
		"normalisation": [],
		"integrity": `+fakeIntegrity+`
	}`)

	result, err := a.Scan(root, time.Now().UTC())
	if err != nil {
		t.Fatalf("Scan: %v", err)
	}
	if len(result.Records) != 2 {
		t.Fatalf("expected both records to survive, got %d", len(result.Records))
	}
	if v, ok := result.Records[0].Fields["model"]; !ok || v != "claude-sonnet-5" {
		t.Fatalf("the 'model' field's VALUE must be preserved in Fields, got %v", result.Records[0].Fields)
	}
	if v, ok := result.Records[1].Fields["body_file"]; !ok || v != "reviews/2026-07-23-example.md" {
		t.Fatalf("the 'body_file' field's VALUE must be preserved in Fields, got %v", result.Records[1].Fields)
	}

	for _, c := range result.Conditions {
		if c.Code == "record-unrecognised-fields" {
			t.Fatalf("issue #26: 'model' and 'body_file' are declared producer fields with clear provenance and must NOT trip record-unrecognised-fields, got %v", c)
		}
	}
}

// TestScanValidRecordsSurvive is the baseline sanity case: ordinary
// well-formed records with no anomalies survive with zero conditions.
func TestScanValidRecordsSurvive(t *testing.T) {
	a := newAdapter(t)
	root := t.TempDir()
	writeFixture(t, root, "s1/dispatched-1.json", validDispatchedRecord("s1", "2026-07-23T10:00:00Z"))
	writeFixture(t, root, "s2/dispatched-1.json", validDispatchedRecord("s2", "2026-07-23T11:00:00Z"))

	result, err := a.Scan(root, time.Now().UTC())
	if err != nil {
		t.Fatalf("Scan: %v", err)
	}
	if len(result.Records) != 2 {
		t.Fatalf("expected 2 surviving records, got %d", len(result.Records))
	}
	if len(result.Quarantined) != 0 || len(result.Conditions) != 0 {
		t.Fatalf("expected zero anomalies, got quarantined=%v conditions=%v", result.Quarantined, result.Conditions)
	}
}
