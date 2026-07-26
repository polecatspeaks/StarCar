package store

// ConditionTier is the ONE owned severity classification for a board
// condition CLASS (issue #30, "SEVERITY PER CLASS"): NOTE-tier is an
// expected pattern - it renders calm/collapsed, register "nominal"; FLAG-
// tier is a defect - it renders needs-attention. Every board-condition
// construction site in board/{store,assemble,server} resolves its Register
// through RegisterForCode below instead of hardcoding a register literal,
// so this map is the SINGLE place severity is decided (Law 6 - no second
// copy to drift). condition_severity_test.go pins this map against every
// Code literal actually emitted by production Go source under board/ - the
// #37 register-taxonomy precedent (an owned mapping, checked by a test that
// reads real source and fails BY NAME on drift), applied one boundary over.
type ConditionTier string

const (
	// TierNote: an expected pattern - design #30's own example is
	// "vocabulary discoveries" (design rev 5 S6 row: "Unrecognised
	// kind/outcome/position/role, vocabularies loaded ... a discovery, not
	// a bug"). Quiet-by-declaration (#30 item 4) is how a NOTE disappears:
	// declaring the new vocabulary value makes the condition stop being
	// true, never an ack-list.
	TierNote ConditionTier = "note"
	// TierFlag: a defect - design #30's own examples are "integrity
	// failures, unparseable records".
	TierFlag ConditionTier = "flag"
)

// conditionSeverity is the ONE owned mapping (#30). Each entry cites the
// file where the code is constructed (as observed at this car's base,
// 4f0182d) and the reasoning for its tier.
var conditionSeverity = map[string]ConditionTier{
	// NOTE-tier -----------------------------------------------------------
	//
	// "discovery" (board/server/poll.go): an unrecognised kind/outcome
	// value. Design #30's named NOTE-tier example, verbatim. This is the
	// tier this car's own first application (task 4, quiet-by-declaration)
	// depends on: declaring "completed"/"approve-for-merge" in
	// schema/vocab/outcomes.json makes the condition disappear because it
	// stopped being true, but even an UNDECLARED discovery renders calm,
	// never hot - that is what "expected pattern" means.
	"discovery": TierNote,

	// FLAG-tier ------------------------------------------------------------
	//
	// board/store/store.go: a record that could not be trusted, or a
	// record the reader partially understands. Design #30's named FLAG
	// example ("integrity failures, unparseable records") is these three,
	// verbatim.
	"record-quarantined":      TierFlag,
	"all-records-quarantined": TierFlag,
	// record-unrecognised-fields is a SURVIVOR record (it still loads), so
	// it is not "unparseable" in the narrowest reading - but unlike
	// "discovery" it names a reader/producer contract drift nobody has
	// declared a fix for yet (D17's typed decode silently drops the
	// field), and design row 333 (§6) carries no "not a bug" framing the
	// way the discovery row (335) explicitly does. Judgment call, disclosed
	// in this car's report: FLAG, conservatively.
	"record-unrecognised-fields": TierFlag,

	// board/assemble/assemble.go: every one of these is a data-integrity
	// or invariant violation the design names as "should be impossible"
	// or a hard render failure - never an expected pattern.
	"subject-namespace-collision":   TierFlag,
	"manifest-record-not-found":     TierFlag,
	"manifest-payload-unreadable":   TierFlag,
	"manifest-membership-collision": TierFlag,
	"dispatch-render-failed":        TierFlag,
	// gate-findings-record-not-found (#28/#12 fix cycle round 2 MAJOR-4):
	// the fold named a "returned" gate winner but no raw record actually
	// matches subject+kind="returned"+at - a data-integrity contradiction
	// (the fold is built FROM these same records), same FLAG-tier family as
	// manifest-record-not-found above.
	"gate-findings-record-not-found": TierFlag,

	// board/assemble/boarddefs.go: presentational-config load/parse
	// failures - a misconfiguration, not a data discovery.
	"board-defs-unreadable": TierFlag,
	"board-def-invalid-row": TierFlag,

	// board/server/poll.go: recognition-vocabulary / shop-default-budget
	// config load failures, and a vocabulary fault (design §6 row
	// "[DR3-2, folded - Major]": a valid-but-empty vocabulary file is a
	// FAULT identical in shape to malformed - explicitly named a Major in
	// the design's own review history).
	"recognition-vocabulary-unreadable": TierFlag,
	"shop-default-budget-unreadable":    TierFlag,
	"fold-fault":                        TierFlag,
}

// RegisterForCode resolves a board condition's CODE to its rendered
// register via the owned severity mapping. An undeclared code is a defect
// in this mapping itself - condition_severity_test.go should never let one
// reach production - but Law 1 forbids a silent guess even on this
// defensive path: it renders needs-attention, the same fail-loud default
// every other undeclared-anything path in this repo uses (vocab.js
// describeVocab, compose.js's unrecognised-register rank).
func RegisterForCode(code string) string {
	if conditionSeverity[code] == TierNote {
		return "nominal"
	}
	return "needs-attention"
}
