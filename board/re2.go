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
// json.Unmarshal(data, &any{})) and appends every string value found under a
// "pattern" key, at any depth - schema "pattern" keywords can appear nested
// under properties, $defs, if/then/allOf, and so on.
func findPatterns(v any, out *[]string) {
	switch t := v.(type) {
	case map[string]any:
		for k, val := range t {
			if k == "pattern" {
				if s, ok := val.(string); ok {
					*out = append(*out, s)
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
