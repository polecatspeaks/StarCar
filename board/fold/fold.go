// Package fold is the Go port of the pwsh detector's fold (plan task 3.3, spec
// YB-7). Fold(records, vocab, now) is a PURE function conforming to the
// language-neutral contract in schema/vectors/README.md: given a fully
// materialised set of records, a recognition vocabulary, and an injected
// clock, it returns the same faults/discoveries/dispatches/intents shape the
// pwsh detector (scripts/Detect-Dispatches.ps1) emits. The vector-runner in
// vectors_test.go conforms this package to every fixture under
// schema/vectors/fold/ - the fold -> assembler interface block (plan §8)
// names this package's API as the contract Car 4 consumes.
//
// Scope note (disclosed, plan 3.1's carve-out): the pwsh detector also applies
// a SHOP-DEFAULT budget fallback (config/harness-defaults.json's
// dispatch_budget_seconds) when a dispatched record carries no budget of its
// own. No vector exercises this path - plan task 3.1 carved it out as an
// environmental/pwsh-IO case with no in-vector-contract way to express it (the
// runner contract never injects a defaults path) - and per the plan's literal
// interface note ("Fold(records, vocab, now) -> the vector contract's output
// shape"), this package's Fold takes no default-budget parameter. A record
// with no budget and no default renders exactly as the pwsh detector does in
// its own "no default available" branch: elapsed_seconds computed truthfully,
// budget_seconds null, state never promoted to overdue. Threading a real shop
// default through Fold (or pre-populating one before calling it) is a decision
// for whichever caller needs it - out of scope here, since no vector pins it.
package fold

// Record is one decoded artifact-store record. It is a generic string-keyed
// map, not a fixed struct, deliberately: this fold reads a small, named set
// of fields (schema, kind, subject, at, outcome, budget, cost) and must never
// crash on a record carrying fields it does not know about (the double-decode
// discipline's FACT1 - "Go silently drops unknown fields" - is a concern for
// whichever caller re-serialises a record; this fold only ever READS the
// fields it needs, and a map read of an absent or unexpected-shaped key is a
// safe zero-value miss, never a panic).
type Record map[string]any

func (r Record) str(key string) (string, bool) {
	v, ok := r[key]
	if !ok || v == nil {
		return "", false
	}
	s, ok := v.(string)
	return s, ok
}

// number reads a JSON-numeric field. Records decoded via encoding/json's
// generic `any` target always represent JSON numbers as float64, regardless
// of whether the literal had a decimal point.
func (r Record) number(key string) (float64, bool) {
	v, ok := r[key]
	if !ok || v == nil {
		return 0, false
	}
	f, ok := v.(float64)
	return f, ok
}

// Vocab is the recognition vocabulary (spec S3.2): data, never a schema enum.
// An unrecognised kind or outcome is a discovery, never a validation failure.
type Vocab struct {
	Kinds    []string
	Outcomes []string
}

func (v Vocab) hasKind(k string) bool    { return contains(v.Kinds, k) }
func (v Vocab) hasOutcome(o string) bool { return contains(v.Outcomes, o) }

func contains(values []string, target string) bool {
	for _, v := range values {
		if v == target {
			return true
		}
	}
	return false
}

// DispatchSupersededItem is one entry in a DispatchEntry's Superseded list -
// the kind and at of a record that lost to the winner (precedence, then
// latest-at within precedence).
type DispatchSupersededItem struct {
	Kind string `json:"kind"`
	At   string `json:"at"`
}

// IntentSupersededItem is one entry in an IntentEntry's Superseded list - the
// at of an intent record that lost to the latest-at winner.
type IntentSupersededItem struct {
	At string `json:"at"`
}

// DispatchEntry is one dispatch subject's fold. Its JSON shape is conditional
// on which kind won (S3.1): a "returned" winner carries outcome+spend; a
// "dispatched" (possibly promoted to "overdue") winner carries
// elapsed_seconds+budget_seconds; a "presumed-lost" winner carries neither -
// exactly mirroring Detect-Dispatches.ps1's conditional hash construction
// (:167-194), so MarshalJSON below builds the same conditional key set rather
// than a single fixed struct shape.
type DispatchEntry struct {
	Subject    string
	State      string
	At         string
	Superseded []DispatchSupersededItem

	winnerKind string // "dispatched" | "returned" | "presumed-lost" - unexported: only Fold constructs a DispatchEntry, so external callers (Car 4) read this shape, never build one.

	Outcome string
	Spend   any

	ElapsedSeconds int64
	// BudgetSeconds is nil exactly when no budget is known (no record budget
	// and, per this package's scope note above, no default threaded in) -
	// the pwsh detector emits an explicit JSON null in that case, never an
	// omitted key, so MarshalJSON below always includes the key on a
	// "dispatched" winner regardless of whether BudgetSeconds is nil.
	BudgetSeconds *float64
}
