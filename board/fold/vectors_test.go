package fold

import (
	"encoding/json"
	"os"
	"path/filepath"
	"reflect"
	"testing"
	"time"
)

// vectorFile mirrors schema/vectors/README.md's vector shape exactly (plan
// task 3.3, spec YB-7). Expected fields are decoded as `any` (generic
// map/slice) rather than into DispatchEntry/IntentEntry structs: comparing
// against the ACTUAL fold output is done by marshalling Output's own fields to
// JSON and re-decoding them into `any` too (see runVector below), so both
// sides go through the identical JSON round-trip and reflect.DeepEqual becomes
// a pure structural comparison - map key order is a non-issue (Go map
// equality is order-independent) and every JSON number on both sides is a
// float64 (encoding/json's universal numeric representation for `any`
// targets), so "60" and "60.0" can never mismatch on type.
type vectorFile struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Input       struct {
		Records  []map[string]any    `json:"records"`
		Vocab    map[string][]string `json:"vocab"`
		Defaults *struct {
			DispatchBudgetSeconds *float64 `json:"dispatch_budget_seconds"`
		} `json:"defaults"`
		Now string `json:"now"`
	} `json:"input"`
	Expected struct {
		Faults      any `json:"faults"`
		Discoveries any `json:"discoveries"`
		Dispatches  any `json:"dispatches"`
		Intents     any `json:"intents"`
	} `json:"expected"`
}

// toAny marshals v to JSON and decodes it back into `any`, the same
// canonicalisation both the expected (already decoded from the vector file)
// and actual (this fold's typed Output fields) sides go through.
func toAny(t *testing.T, v any) any {
	t.Helper()
	data, err := json.Marshal(v)
	if err != nil {
		t.Fatalf("marshalling %#v: %v", v, err)
	}
	var out any
	if err := json.Unmarshal(data, &out); err != nil {
		t.Fatalf("unmarshalling %s: %v", data, err)
	}
	return out
}

// TestFoldConformsToVectors is the Go half of the D18 cross-verifier's
// conformance obligation (YB-7): every vector under schema/vectors/fold/ must
// deep-equal against this package's Fold, per the runner contract. Zero-vector
// refusal: an empty directory fails the test rather than passing vacuously
// (mirrors Detector.Tests.ps1's own zero-vector guard).
func TestFoldConformsToVectors(t *testing.T) {
	vectorsDir := filepath.Join(repoRoot(t), "schema", "vectors", "fold")
	entries, err := os.ReadDir(vectorsDir)
	if err != nil {
		t.Fatalf("reading %s: %v", vectorsDir, err)
	}

	var files []string
	for _, e := range entries {
		if !e.IsDir() && filepath.Ext(e.Name()) == ".json" {
			files = append(files, filepath.Join(vectorsDir, e.Name()))
		}
	}
	if len(files) == 0 {
		t.Fatalf("zero vectors found under %s - a zero-vector run is a refusal, not a pass", vectorsDir)
	}

	for _, path := range files {
		path := path
		t.Run(filepath.Base(path), func(t *testing.T) {
			data, err := os.ReadFile(path)
			if err != nil {
				t.Fatalf("reading %s: %v", path, err)
			}
			var v vectorFile
			if err := json.Unmarshal(data, &v); err != nil {
				t.Fatalf("parsing %s: %v", path, err)
			}

			now, err := time.Parse(time.RFC3339, v.Input.Now)
			if err != nil {
				t.Fatalf("vector %q: parsing input.now %q: %v", v.Name, v.Input.Now, err)
			}

			records := make([]Record, len(v.Input.Records))
			for i, r := range v.Input.Records {
				records[i] = Record(r)
			}
			vocab := Vocab{Kinds: v.Input.Vocab["kinds"], Outcomes: v.Input.Vocab["outcomes"]}

			// input.defaults (C3R-1a/1d, spec Amendment 2): OPTIONAL. When
			// present, thread its dispatch_budget_seconds into Fold via
			// WithDefaultBudgetSeconds - the runner contract's own
			// language-neutral way to pin the shop-default fold semantic
			// without depending on the real config/harness-defaults.json.
			var opts []Option
			if v.Input.Defaults != nil && v.Input.Defaults.DispatchBudgetSeconds != nil {
				opts = append(opts, WithDefaultBudgetSeconds(*v.Input.Defaults.DispatchBudgetSeconds))
			}

			out := Fold(records, vocab, now, opts...)

			assertVectorFieldEqual(t, v.Name, "faults", v.Expected.Faults, toAny(t, out.Faults))
			assertVectorFieldEqual(t, v.Name, "discoveries", v.Expected.Discoveries, toAny(t, out.Discoveries))
			assertVectorFieldEqual(t, v.Name, "dispatches", v.Expected.Dispatches, toAny(t, out.Dispatches))
			assertVectorFieldEqual(t, v.Name, "intents", v.Expected.Intents, toAny(t, out.Intents))
		})
	}
}

func assertVectorFieldEqual(t *testing.T, vectorName, field string, expected, actual any) {
	t.Helper()
	if !reflect.DeepEqual(expected, actual) {
		expJSON, _ := json.Marshal(expected)
		actJSON, _ := json.Marshal(actual)
		t.Errorf("vector %q: field %q does not deep-equal expected (schema/vectors/README.md's runner contract)\n  expected: %s\n  actual:   %s", vectorName, field, expJSON, actJSON)
	}
}
