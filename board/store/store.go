// Package store is the yard board's ONE reader of the artifact store (design
// rev 5 D13, S5.3 - "the store is the SOLE adapter"; plan task 4.1).
// StoreAdapter scans artifacts/**/*.json under a configured root each poll,
// double-decodes each record (D17: typed struct + map[string]json.RawMessage
// key-diff - FACT1/3, docs/probes/2026-07-23-go-substrate-probe-results.md),
// quarantines-with-disclosure whatever cannot be trusted, and yields raw
// records. Everything else (liveness, membership, composition) is derivation
// downstream (board/fold, board/assemble) - this package does no folding.
package store

import (
	"encoding/json"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"reflect"
	"sort"
	"strings"
	"time"

	"github.com/santhosh-tekuri/jsonschema/v6"
)

// Record is one surviving record: its full decoded content (safe for
// board/fold.Record(rec.Fields) and for the Assembler's raw-payload joins),
// plus the store-root-relative path it was read from (used only for
// disclosure text - never rendered as a raw absolute path, per this repo's
// path-normalisation posture).
type Record struct {
	Path   string
	Fields map[string]any
}

// QuarantinedRecord is one record EXCLUDED from Records, with the reason a
// human (or the board's chrome) can read.
type QuarantinedRecord struct {
	Path   string
	Reason string
}

// BoardCondition mirrors the wire schema's $defs.boardCondition shape
// (schema/yard-snapshot.schema.json) closely enough that board/server can
// marshal it directly: a fault about the BOARD, not the yard, always
// disclosed, never suppressed.
type BoardCondition struct {
	Code     string
	Detail   string
	Register string // "nominal" | "in-progress" | "needs-attention"
}

// ScanResult is everything one Scan call produced: survivors, quarantine,
// and board-level disclosures. It carries no verdict about freshness (that
// is board/server's job, informed by whether Scan returned an error).
type ScanResult struct {
	Records     []Record
	Quarantined []QuarantinedRecord
	Conditions  []BoardCondition
}

// Adapter holds the compiled schemas (compiled ONCE, reused across every
// poll's Scan - recompiling per poll would be wasted work and, per Law 6, a
// second place these schemas could silently drift apart).
type Adapter struct {
	artifactSchema *jsonschema.Schema
	manifestSchema *jsonschema.Schema
}

// NewAdapter compiles the store record schema and the layered manifest
// schema (YB-1: "Store validators run this schema IN ADDITION to the base
// record schema; neither restates the other") from schemaDir (the repo's
// schema/ directory). Compiling once here, rather than re-implementing the
// schemas' required-field/conditional logic by hand in Go, is the
// Law-6-compliant path Car 1 proved works (board/board_test.go).
func NewAdapter(schemaDir string) (*Adapter, error) {
	c := jsonschema.NewCompiler()
	artifactSchema, err := c.Compile(filepath.Join(schemaDir, "starcar-artifact.schema.json"))
	if err != nil {
		return nil, fmt.Errorf("store: compiling starcar-artifact.schema.json: %w", err)
	}
	manifestSchema, err := c.Compile(filepath.Join(schemaDir, "starcar-manifest.schema.json"))
	if err != nil {
		return nil, fmt.Errorf("store: compiling starcar-manifest.schema.json: %w", err)
	}
	return &Adapter{artifactSchema: artifactSchema, manifestSchema: manifestSchema}, nil
}

// typedRecord is the KNOWN field set (D17): every field name here is a JSON
// tag, and typedKeys() below reflects them into the known-key set the
// per-record unknown-field diff compares against. "manifest" is included per
// DR3-1 item 4 - the manifest payload key joins the known key-set in the
// same change that lands the manifest contract, so D17's disclosure never
// fires on a well-formed manifest record. "model" and "body_file" are
// included per issue #26: both are OBSERVED PRODUCER FIELDS WITH CLEAR
// PROVENANCE (model: Produce-Artifact.ps1:285, dispatched-only, sourced from
// the Task tool_response's resolvedModel; body_file: Migrate-Verdicts.ps1:152,
// migrated returned verdicts), and the same epistemic rule that added
// "manifest" applies here - an observed, provenanced producer field gets
// DECLARED, not left to fire the unknown-field disclosure forever.
//
// #51: SubjectBasis, TaskID, and Provenance are the #47-era producer fields
// (Produce-Artifact.ps1:356-358) - which family rule produced the subject
// (runtime-id | minted-id), the shop-minted id the envelope echoes back
// (returned-kind only), and runtime-internal ids kept as enrichment. Same
// epistemic rule as #26/#22: an observed, provenanced producer field gets
// DECLARED here, not left to fire record-unrecognised-fields forever.
type typedRecord struct {
	Schema            string          `json:"schema"`
	Kind              string          `json:"kind"`
	Subject           string          `json:"subject"`
	SessionID         string          `json:"session_id"`
	At                string          `json:"at"`
	Outcome           string          `json:"outcome"`
	Findings          string          `json:"findings"`
	Abstract          string          `json:"abstract"`
	Envelope          string          `json:"envelope"`
	Budget            *float64        `json:"budget"`
	Basis             json.RawMessage `json:"basis"`
	Cost              json.RawMessage `json:"cost"`
	ContextPeakTokens *float64        `json:"context_peak_tokens"`
	Producer          string          `json:"producer"`
	Model             string          `json:"model"`
	BodyFile          string          `json:"body_file"`
	Normalisation     json.RawMessage `json:"normalisation"`
	Integrity         string          `json:"integrity"`
	Manifest          json.RawMessage `json:"manifest"`
	SubjectBasis      string          `json:"subject_basis"`
	TaskID            string          `json:"task_id"`
	Provenance        json.RawMessage `json:"provenance"`
}

// typedKeys is computed ONCE (package init), by reflecting typedRecord's own
// json tags - one source of truth (the struct), never a hand-maintained
// parallel list that could drift from it (Law 6).
var typedKeys = buildTypedKeys()

func buildTypedKeys() map[string]bool {
	keys := map[string]bool{}
	t := reflect.TypeOf(typedRecord{})
	for i := 0; i < t.NumField(); i++ {
		tag := t.Field(i).Tag.Get("json")
		name := strings.Split(tag, ",")[0]
		if name != "" {
			keys[name] = true
		}
	}
	return keys
}

// Scan walks storeRoot recursively for *.json files (artifacts/**/*.json),
// double-decodes each one, and returns every record that survives, every one
// quarantined, and the board conditions the scan itself raised. now is the
// injected clock (never wall-clock read directly here - board/server's poll
// loop is the one place "now" is sampled), used only to detect a
// future-dated "at".
//
// The returned error is reserved for a SCAN-LEVEL failure (the directory
// itself missing or unreadable, design S6 row 1: "Lane failed, coded reason,
// lastGood visibly marked"). A directory that EXISTS but holds zero records
// is a SUCCESSFUL scan (DR3-5a, honest-empty) - it returns a nil error and
// an empty ScanResult, never conflated with the failure row above it.
func (a *Adapter) Scan(storeRoot string, now time.Time) (ScanResult, error) {
	info, err := os.Stat(storeRoot)
	if err != nil {
		return ScanResult{}, fmt.Errorf("store: %s is missing or unreadable: %w", storeRoot, err)
	}
	if !info.IsDir() {
		return ScanResult{}, fmt.Errorf("store: %s is not a directory", storeRoot)
	}

	var paths []string
	walkErr := filepath.WalkDir(storeRoot, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}
		if filepath.Ext(d.Name()) == ".json" {
			paths = append(paths, path)
		}
		return nil
	})
	if walkErr != nil {
		return ScanResult{}, fmt.Errorf("store: walking %s: %w", storeRoot, walkErr)
	}
	sort.Strings(paths) // deterministic order - conditions and Records both read stably poll to poll

	var result ScanResult
	for _, path := range paths {
		rel, relErr := filepath.Rel(storeRoot, path)
		if relErr != nil {
			rel = filepath.Base(path) // defensive fallback; never surface the raw absolute path
		}
		rel = filepath.ToSlash(rel)

		rec, cond, quarantineReason := a.readOne(path, rel, now)
		if quarantineReason != "" {
			result.Quarantined = append(result.Quarantined, QuarantinedRecord{Path: rel, Reason: quarantineReason})
			result.Conditions = append(result.Conditions, BoardCondition{
				Code:     "record-quarantined",
				Detail:   fmt.Sprintf("%s: %s", rel, quarantineReason),
				Register: "needs-attention",
			})
			continue
		}
		result.Records = append(result.Records, rec)
		if cond != nil {
			result.Conditions = append(result.Conditions, *cond)
		}
	}

	if len(paths) > 0 && len(result.Records) == 0 {
		// DR3-5b: the degenerate case of "a record fails" is its OWN state -
		// zero-of-N is different from zero-of-zero (honest-empty above).
		result.Conditions = append(result.Conditions, BoardCondition{
			Code:     "all-records-quarantined",
			Detail:   fmt.Sprintf("%d of %d records quarantined", len(result.Quarantined), len(paths)),
			Register: "needs-attention",
		})
	}

	return result, nil
}

// readOne double-decodes one file and returns EITHER a survivor (rec, an
// optional unknown-field disclosure condition, empty quarantineReason) OR a
// quarantine reason (empty rec/cond). Every quarantine check after JSON
// parsing runs only once earlier checks pass, so a record is excluded for
// exactly one, most-fundamental reason.
func (a *Adapter) readOne(path, rel string, now time.Time) (Record, *BoardCondition, string) {
	data, err := os.ReadFile(path)
	if err != nil {
		return Record{}, nil, fmt.Sprintf("could not read the file: %v", err)
	}

	// D17's typed decode (FACT1: silently drops any field outside
	// typedRecord's tags). Its error is folded into the generic parse-failure
	// reason below - a type mismatch on a KNOWN field (e.g. "budget": "abc")
	// is exactly the shape a JSON-parse-into-a-fixed-type failure reports,
	// and the schema-shape check right after this would catch it structurally
	// too, so no separate handling is needed here.
	var typed typedRecord
	typedErr := json.Unmarshal(data, &typed)

	// D17's raw decode (FACT3: preserves every key, including ones typedRecord
	// does not know). This is the side of the diff that discloses unknowns.
	var raw map[string]json.RawMessage
	if err := json.Unmarshal(data, &raw); err != nil {
		return Record{}, nil, fmt.Sprintf("could not parse the JSON: %v", err)
	}

	// A generic map[string]any decode of the SAME bytes for content access
	// (fold.Record(fields), the Assembler's manifest-payload reads). Since
	// `raw` above already proved this JSON parses, this decode cannot fail.
	var fields map[string]any
	if err := json.Unmarshal(data, &fields); err != nil {
		return Record{}, nil, fmt.Sprintf("could not parse the JSON: %v", err)
	}
	if typedErr != nil {
		// A known field carries a value typedRecord's type cannot hold - fold
		// this into the same parse-failure family (the schema-shape check
		// below is the structurally correct place to catch this in detail;
		// this branch exists only so a genuinely malformed known field is
		// never silently treated as a survivor).
		return Record{}, nil, fmt.Sprintf("a known field could not be decoded: %v", typedErr)
	}

	// Schema-shape validation (Law 6: the PINNED validator runs the real
	// schemas rather than a hand-rolled reimplementation of their required-
	// field/conditional logic). Both schemas run on every record (YB-1: the
	// manifest schema's own if/then clauses are no-ops for a non-train,
	// non-manifest-carrying record, so this is harmless there and catches
	// the train: cases the plan's carrier task (2.5) requires for the pwsh
	// side too).
	if err := a.artifactSchema.Validate(fields); err != nil {
		return Record{}, nil, fmt.Sprintf("fails starcar-artifact/1 schema validation: %v", err)
	}
	if err := a.manifestSchema.Validate(fields); err != nil {
		return Record{}, nil, fmt.Sprintf("fails starcar-manifest/1 schema validation: %v", err)
	}

	// Issue #24 (C3R-3, binding on this task): schema "format" is
	// annotation-only under draft 2020-12 (confirmed by the Car 3 reviewer),
	// so a malformed OR zoneless "at" passes schema validation above and
	// must be caught explicitly here, BEFORE this record could ever reach
	// board/fold.Fold (whose parseInstant silently degrades to the epoch on
	// exactly this input - safe only because this quarantine exists).
	atStr, _ := fields["at"].(string)
	atInstant, atErr := time.Parse(time.RFC3339, atStr)
	if atErr != nil {
		return Record{}, nil, fmt.Sprintf("has an unparseable or zoneless 'at' value %q: %v", atStr, atErr)
	}

	// A future-dated "at" is excluded rather than silently treated as the
	// freshest/winning record (design S6: "never silently fresh").
	if atInstant.After(now) {
		return Record{}, nil, fmt.Sprintf("has a future-dated 'at' value %q (after this scan's now %q)", atStr, now.UTC().Format(time.RFC3339))
	}

	rec := Record{Path: rel, Fields: fields}

	var unknown []string
	for k := range raw {
		if !typedKeys[k] {
			unknown = append(unknown, k)
		}
	}
	if len(unknown) > 0 {
		sort.Strings(unknown)
		cond := BoardCondition{
			Code:     "record-unrecognised-fields",
			Detail:   fmt.Sprintf("%s: record carries %d unrecognised field(s): %s", rel, len(unknown), strings.Join(unknown, ", ")),
			Register: "needs-attention",
		}
		return rec, &cond, ""
	}
	return rec, nil, ""
}
