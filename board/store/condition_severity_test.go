package store

import (
	"go/ast"
	"go/parser"
	"go/token"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"testing"
)

// boardConditionTypeNames are the two struct names this scanner recognises
// as "a board condition is being constructed here" - store.BoardCondition
// (board/store) and WireBoardCondition (board/server, its wire mirror).
func isBoardConditionTypeName(name string) bool {
	return name == "BoardCondition" || name == "WireBoardCondition"
}

// typeIdentName resolves a bare identifier or qualified selector
// (pkg.Name) type expression to its bare name; anything else (e.g. a map
// type, a pointer) resolves to "".
func typeIdentName(expr ast.Expr) string {
	switch te := expr.(type) {
	case *ast.Ident:
		return te.Name
	case *ast.SelectorExpr:
		return te.Sel.Name
	default:
		return ""
	}
}

// extractCode pulls the "Code" field's string literal out of one
// BoardCondition/WireBoardCondition composite literal (cl.Type may be nil -
// callers resolve the effective type before calling this, see the
// ArrayType branch below for the elided-element-type case). Fatal on a
// non-literal Code UNLESS it is a simple field-selector PASS-THROUGH shaped
// EXACTLY `Code: <expr>.Code` - observed at board/server/poll.go's
// toWireCondition, which copies an already-classified condition's OWN Code
// field onto its wire mirror and introduces no NEW code for this mapping to
// cover.
//
// TIGHTENED (review round 1 MIN-2, fix-cycle round 2): the prior version
// skipped ANY `*ast.SelectorExpr` Code value, on the theory that a
// pass-through is the only shape a real Code assignment could take that
// isn't a literal - but a SelectorExpr is also what `time.RFC3339` (a
// package-qualified CONSTANT, nothing to do with this mapping) parses as,
// so a genuinely NEW code supplied that way would be silently skipped
// instead of caught. The fix narrows the skip to selectors whose FIELD NAME
// is literally "Code" (`x.Code` for any `x`) - the actual shape of the one
// pass-through this scanner needs to tolerate - so `time.RFC3339`,
// `pkg.SomeOtherField`, or any selector not named `Code` now falls through
// to the literal check below and is treated as a genuinely new code
// (fatal, since this scanner cannot introspect it further).
//
// Fault-injection evidence (recorded in this fix-cycle's commit message):
// with the OLD (untightened) skip, adding `WireBoardCondition{Code:
// time.RFC3339, ...}` in board/server/poll.go made
// TestConditionSeverityMappingMatchesEmittedCodes print bare `ok` - silently
// blind. With this tightening, the SAME injection is now CAUGHT (see the
// commit message for the exact failure text). Reverted byte-identical
// before commit.
func extractCode(t *testing.T, path string, cl *ast.CompositeLit, codes map[string]bool) {
	t.Helper()
	for _, elt := range cl.Elts {
		kv, ok := elt.(*ast.KeyValueExpr)
		if !ok {
			continue
		}
		key, ok := kv.Key.(*ast.Ident)
		if !ok || key.Name != "Code" {
			continue
		}
		if sel, isSelector := kv.Value.(*ast.SelectorExpr); isSelector && sel.Sel.Name == "Code" {
			continue // pass-through (`x.Code`), see doc comment above
		}
		lit, ok := kv.Value.(*ast.BasicLit)
		if !ok || lit.Kind != token.STRING {
			t.Fatalf("%s: a BoardCondition/WireBoardCondition Code field is neither a string literal nor a `.Code` field-selector pass-through (found %T) - extend this scanner (#30) before adding a computed code", path, kv.Value)
			continue
		}
		val, uerr := strconv.Unquote(lit.Value)
		if uerr != nil {
			t.Fatalf("%s: could not unquote Code literal %s: %v", path, lit.Value, uerr)
		}
		codes[val] = true
	}
}

// scanBoardConditionCodes walks dir for PRODUCTION Go source (excluding
// _test.go files - the ONE owned mapping's scope is production condition
// construction, and no _test.go file in this repo constructs a
// BoardCondition/WireBoardCondition WITH a Code field as of this car's base,
// verified by `grep -rn 'BoardCondition{' board --include=*_test.go`) and
// returns every string literal assigned to a "Code" field inside a
// BoardCondition or WireBoardCondition composite literal. This is the same
// "read the real source, not a description of it" instrument as
// board/assemble/register_taxonomy_test.go (#37), aimed one boundary over:
// that pin reads the real SCHEMA file; this one reads the real Go AST.
//
// Two composite-literal shapes are handled: a directly-typed literal
// (`store.BoardCondition{Code: "x", ...}`, board/assemble/assemble.go
// throughout) and a slice literal whose ELEMENTS elide their type
// (`[]store.BoardCondition{{Code: "x", ...}}`, board/assemble/boarddefs.go's
// two error-return sites) - Go allows the inner `{...}` to omit
// `store.BoardCondition` because the enclosing `[]store.BoardCondition`
// already states it, so `cl.Type` is nil on the inner literal and the type
// must be inherited from the ArrayType's element type instead.
func scanBoardConditionCodes(t *testing.T, dir string) map[string]bool {
	t.Helper()
	codes := map[string]bool{}
	walkErr := filepath.WalkDir(dir, func(path string, d os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			return nil
		}
		if !strings.HasSuffix(path, ".go") || strings.HasSuffix(path, "_test.go") {
			return nil
		}
		fset := token.NewFileSet()
		f, perr := parser.ParseFile(fset, path, nil, 0)
		if perr != nil {
			t.Fatalf("parsing %s: %v", path, perr)
		}
		ast.Inspect(f, func(n ast.Node) bool {
			cl, ok := n.(*ast.CompositeLit)
			if !ok {
				return true
			}
			switch te := cl.Type.(type) {
			case *ast.Ident, *ast.SelectorExpr:
				if isBoardConditionTypeName(typeIdentName(cl.Type)) {
					extractCode(t, path, cl, codes)
				}
				return true
			case *ast.ArrayType:
				if isBoardConditionTypeName(typeIdentName(te.Elt)) {
					for _, elt := range cl.Elts {
						if inner, ok := elt.(*ast.CompositeLit); ok {
							extractCode(t, path, inner, codes)
						}
					}
					return false // elements handled above; do not also visit them as bare (Type==nil) literals
				}
				return true
			default:
				return true
			}
		})
		return nil
	})
	if walkErr != nil {
		t.Fatalf("walking %s: %v", dir, walkErr)
	}
	return codes
}

// TestConditionSeverityMappingMatchesEmittedCodes pins the severity mapping
// (#30 item 2) the same way #37 pins the register taxonomy: SET EQUALITY
// between two independently-derived sources, failing BY NAME on drift.
// Here the two sources are (a) every Code literal actually constructed by
// production Go source under board/, scanned from real files, and (b) the
// keys of conditionSeverity (condition_severity.go).
//
// Fault-injection evidence (recorded in this car's commit message and
// report): with "record-unrecognised-fields" temporarily removed from
// conditionSeverity, this test failed with exactly:
// `code "record-unrecognised-fields" is emitted by production source under
// board/ but has no conditionSeverity entry (#30)`. Restored byte-identical
// before the commit that lands this test green.
func TestConditionSeverityMappingMatchesEmittedCodes(t *testing.T) {
	boardDir := filepath.Join(repoRoot(t), "board")
	emitted := scanBoardConditionCodes(t, boardDir)

	if len(emitted) == 0 {
		t.Fatal("scanned zero board-condition codes from production source under board/ - fixture sanity check failed (the scanner itself is broken)")
	}
	if len(conditionSeverity) == 0 {
		t.Fatal("conditionSeverity is empty - fixture sanity check failed")
	}

	var missingFromMapping []string
	for code := range emitted {
		if _, ok := conditionSeverity[code]; !ok {
			missingFromMapping = append(missingFromMapping, code)
		}
	}
	sort.Strings(missingFromMapping)
	for _, code := range missingFromMapping {
		t.Errorf("code %q is emitted by production source under board/ but has no conditionSeverity entry (#30)", code)
	}

	var unusedInMapping []string
	for code := range conditionSeverity {
		if !emitted[code] {
			unusedInMapping = append(unusedInMapping, code)
		}
	}
	sort.Strings(unusedInMapping)
	for _, code := range unusedInMapping {
		t.Errorf("conditionSeverity declares a tier for code %q but no production source under board/ emits it - stale mapping entry (#30)", code)
	}
}

// TestDiscoveryIsNoteTier regression-pins #30's central behaviour change:
// the "discovery" code (the design's own NOTE-tier example) must resolve
// to the calm register, never needs-attention - the opposite of this
// repo's PRE-#30 posture (board/server/discovery_test.go used to assert
// needs-attention for exactly this code; that assertion is updated in the
// same commit as this one, per the NORTH STAR "documents/tests are living"
// rule).
func TestDiscoveryIsNoteTier(t *testing.T) {
	if got := RegisterForCode("discovery"); got != "nominal" {
		t.Errorf(`RegisterForCode("discovery") = %q, want "nominal" (#30 NOTE-tier)`, got)
	}
}

// TestUndeclaredCodeFailsLoudNeverCalm pins RegisterForCode's Law 1 default:
// a code with no conditionSeverity entry renders needs-attention, never
// silently calm.
func TestUndeclaredCodeFailsLoudNeverCalm(t *testing.T) {
	if got := RegisterForCode("no-such-code-declared-anywhere"); got != "needs-attention" {
		t.Errorf(`RegisterForCode("no-such-code-declared-anywhere") = %q, want "needs-attention"`, got)
	}
}
