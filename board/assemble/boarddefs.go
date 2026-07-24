package assemble

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/polecatspeaks/StarCar/board/store"
)

// VocabDef mirrors schema/yard-snapshot.schema.json's $defs.vocabDef.
type VocabDef struct {
	ID       string `json:"id"`
	Label    string `json:"label"`
	Register string `json:"register"`
}

// Vocabularies mirrors the wire schema's top-level "vocabularies" property:
// presentational defs (label + register) for the recognition values that
// live as DATA in schema/vocab/*.json (Law 7 - this file adds presentation
// only, never a second recognition gate).
type Vocabularies struct {
	Positions []VocabDef `json:"positions"`
	Outcomes  []VocabDef `json:"outcomes"`
	Roles     []VocabDef `json:"roles"`
	Liveness  []VocabDef `json:"liveness"`
}

var closedRegisters = map[string]bool{"nominal": true, "in-progress": true, "needs-attention": true}

// LoadVocabularies reads schema/vocab/board-defs.json (task 2.4's pinned
// presentational defs). A missing/unreadable file is ONE board condition and
// empty vocabularies (non-fatal: the wire schema's own comment already
// legislates "a value with no def renders by raw id through the detector
// path"). A malformed INDIVIDUAL row - missing id/label/register, or a
// register outside the closed {nominal, in-progress, needs-attention} set -
// is skipped and named in its own condition; the rest of the file still
// loads (one bad row must not blank the whole vocabularies block).
func LoadVocabularies(path string) (Vocabularies, []store.BoardCondition) {
	data, err := os.ReadFile(path)
	if err != nil {
		return Vocabularies{}, []store.BoardCondition{{
			Code:     "board-defs-unreadable",
			Detail:   fmt.Sprintf("could not read %s: %v", path, err),
			Register: "needs-attention",
		}}
	}

	var raw struct {
		Positions []map[string]any `json:"positions"`
		Outcomes  []map[string]any `json:"outcomes"`
		Roles     []map[string]any `json:"roles"`
		Liveness  []map[string]any `json:"liveness"`
	}
	if err := json.Unmarshal(data, &raw); err != nil {
		return Vocabularies{}, []store.BoardCondition{{
			Code:     "board-defs-unreadable",
			Detail:   fmt.Sprintf("could not parse %s: %v", path, err),
			Register: "needs-attention",
		}}
	}

	var conditions []store.BoardCondition
	load := func(rows []map[string]any) []VocabDef {
		defs := make([]VocabDef, 0, len(rows))
		for _, row := range rows {
			id, _ := row["id"].(string)
			label, _ := row["label"].(string)
			register, _ := row["register"].(string)
			if id == "" || label == "" || !closedRegisters[register] {
				name := id
				if name == "" {
					name = fmt.Sprintf("%v", row)
				}
				conditions = append(conditions, store.BoardCondition{
					Code:     "board-def-invalid-row",
					Detail:   fmt.Sprintf("%s: row %q is invalid (missing id/label, or register outside the closed set)", path, name),
					Register: "needs-attention",
				})
				continue
			}
			defs = append(defs, VocabDef{ID: id, Label: label, Register: register})
		}
		return defs
	}

	return Vocabularies{
		Positions: load(raw.Positions),
		Outcomes:  load(raw.Outcomes),
		Roles:     load(raw.Roles),
		Liveness:  load(raw.Liveness),
	}, conditions
}
