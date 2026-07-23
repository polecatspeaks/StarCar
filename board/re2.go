package board

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
)

// patternFailure names one RE2-incompatible "pattern" value found while
// walking a schema file (plan task 1.3 / spec YB-11's standing RE2 rule).
type patternFailure struct {
	SchemaFile string
	Pattern    string
	Err        error
}

// findPatterns walks a decoded JSON document (the output of
// json.Unmarshal(data, &any{})) and appends every string that JSON Schema
// compiles as a regular expression, at any depth: "pattern" keyword VALUES
// (properties, $defs, if/then/allOf, and so on), and - task 3.R, rider [C1R-2]
// from Car 1's review - "patternProperties" keyword KEYS (a patternProperties
// object's keys are themselves regexes matched against property names, not
// "pattern" values, so the k == "pattern" branch alone never sees them). A
// "propertyNames" keyword is itself a (sub-)schema and most commonly carries
// its own nested "pattern" key ({"propertyNames": {"pattern": "..."}}), which
// the plain recursive descent below already visits and needs no special case;
// it is named in the rider only so both call sites stay covered by name
// rather than by accident (board/re2_test.go pins both).
func findPatterns(v any, out *[]string) {
	switch t := v.(type) {
	case map[string]any:
		for k, val := range t {
			if k == "pattern" {
				if s, ok := val.(string); ok {
					*out = append(*out, s)
				}
			}
			if k == "patternProperties" {
				if pp, ok := val.(map[string]any); ok {
					for key := range pp {
						*out = append(*out, key)
					}
				}
			}
			findPatterns(val, out)
		}
	case []any:
		for _, item := range t {
			findPatterns(item, out)
		}
	}
}

// checkRE2CompatiblePatterns walks every *.schema.json file directly under
// root and regexp.Compile()s every "pattern" value found in it. Go's
// regexp package implements RE2 (no lookahead, no backreferences) - the same
// engine the pinned jsonschema/v6 validator uses by default, so this is the
// mechanical check spec YB-11's SB-1 note names ("the Go-compile probe
// (scripts/probes/go/ pattern check) is the mechanical check"). Returns one
// patternFailure per pattern that fails to compile, naming the schema file
// and the exact pattern string, so a violation is never a silent miss.
func checkRE2CompatiblePatterns(root string) ([]patternFailure, error) {
	matches, err := filepath.Glob(filepath.Join(root, "*.schema.json"))
	if err != nil {
		return nil, fmt.Errorf("globbing %s/*.schema.json: %w", root, err)
	}
	if len(matches) == 0 {
		return nil, fmt.Errorf("no *.schema.json files found under %s - the probe would vacuously pass with nothing to check", root)
	}

	var failures []patternFailure
	for _, path := range matches {
		data, err := os.ReadFile(path)
		if err != nil {
			return nil, fmt.Errorf("reading %s: %w", path, err)
		}
		var doc any
		if err := json.Unmarshal(data, &doc); err != nil {
			return nil, fmt.Errorf("parsing %s as JSON: %w", path, err)
		}
		var patterns []string
		findPatterns(doc, &patterns)
		for _, p := range patterns {
			if _, err := regexp.Compile(p); err != nil {
				failures = append(failures, patternFailure{
					SchemaFile: filepath.Base(path),
					Pattern:    p,
					Err:        err,
				})
			}
		}
	}
	return failures, nil
}
