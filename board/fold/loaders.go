package fold

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// LoadVocab reads kinds.json and outcomes.json from dir - the {"values": [...]}
// shape schema/vocab/ uses, and the same shape the fold vector runner
// materialises (schema/vectors/README.md's runner contract, step 2). A read
// failure on EITHER file is ONE combined error - the environmental,
// pwsh-IO-shaped counterpart to Detect-Dispatches.ps1's "unreadable vocab dir"
// case (Detector.Tests.ps1's carved-out imperative test, plan 3.1's amendment):
// that case is not expressible as a fold vector (a path-bearing fault string
// no cross-language deep-equal can pin), so plan task 3.3 asks for this
// package's OWN-IDIOM equivalent instead, tested directly against LoadVocab
// (loaders_test.go) rather than through Fold. The error text is this
// package's own idiom, not vector-pinned (spec YB-8's disclosed posture scopes
// byte-identical fault strings to vector-covered cases only).
func LoadVocab(dir string) (Vocab, error) {
	kinds, err := readValuesFile(filepath.Join(dir, "kinds.json"))
	if err != nil {
		return Vocab{}, fmt.Errorf("fold: could not read recognition vocabulary from %q: %w", dir, err)
	}
	outcomes, err := readValuesFile(filepath.Join(dir, "outcomes.json"))
	if err != nil {
		return Vocab{}, fmt.Errorf("fold: could not read recognition vocabulary from %q: %w", dir, err)
	}
	return Vocab{Kinds: kinds, Outcomes: outcomes}, nil
}

func readValuesFile(path string) ([]string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var parsed struct {
		Values []string `json:"values"`
	}
	if err := json.Unmarshal(data, &parsed); err != nil {
		return nil, err
	}
	return parsed.Values, nil
}

// LoadDefaultBudget reads dispatch_budget_seconds from a defaults JSON file
// (config/harness-defaults.json's shape). A read failure is ONE error - the
// own-idiom counterpart to Detect-Dispatches.ps1's "unreadable defaults file"
// case (also carved out at plan 3.1 for the same path-bearing-string reason,
// and STILL correctly carved - reading the file is IO, spec Amendment 2 only
// reclassified APPLYING its value). This function reads the value from disk;
// a caller threads the result into Fold via WithDefaultBudgetSeconds
// (algorithm.go) - the fold semantic itself (C3R-1d, spec Amendment 2, issue
// #22), which supersedes this comment's prior claim that Fold never
// consumes it.
func LoadDefaultBudget(path string) (*float64, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("fold: could not read the shop default budget from %q: %w", path, err)
	}
	var parsed struct {
		DispatchBudgetSeconds float64 `json:"dispatch_budget_seconds"`
	}
	if err := json.Unmarshal(data, &parsed); err != nil {
		return nil, fmt.Errorf("fold: could not read the shop default budget from %q: %w", path, err)
	}
	return &parsed.DispatchBudgetSeconds, nil
}
