package fold

import (
	"math"
	"sort"
	"strings"
	"time"
)

var precedence = map[string]int{"returned": 3, "presumed-lost": 2, "dispatched": 1}

type subjectGroup struct {
	dispatch []Record
	intent   []Record
}

// parseInstant parses a record's "at" field as the UTC instant it represents,
// honoring its offset (mirrors Get-AtInstant, scripts/Artifact.psm1:87 - "a
// lexical sort is chronological only when every record shares the same
// offset"). Unlike the pwsh detector, this fold has no error channel in its
// signature (plan 3.3's literal Fold(records, vocab, now) contract); a record
// whose "at" fails to parse degrades to the Unix epoch rather than panicking
// (the "must not crash" mandate) - undesirable but silent, and disclosed here
// because no vector exercises a malformed "at" (a malformed-at behaviour is,
// like the four carved-out imperative cases, not expressible as a pure fold
// vector - the pwsh detector's own handling is to throw loud, attributed to
// the subject, which has no equivalent without an error return here).
//
// CARRIED OBLIGATION, not merely disclosed here (C3R-3, Minor, Car 3 review
// round 1 - a package-doc-only note was ruled an insufficient carrier at
// C3R-1's Major, so this one lands as tracked issue #24, not just this
// comment): Car 4's StoreAdapter (plan task 4.1) MUST quarantine a record
// whose "at" is malformed/unparseable/zoneless BEFORE it ever reaches Fold,
// with its own red-first test - see
// https://github.com/polecatspeaks/StarCar/issues/24. This function's silent
// epoch-degrade is safe ONLY if that upstream quarantine actually exists;
// today it is Car 4's task, not yet built.
func parseInstant(r Record) time.Time {
	at, ok := r.str("at")
	if !ok {
		return time.Unix(0, 0).UTC()
	}
	t, err := time.Parse(time.RFC3339, at)
	if err != nil {
		return time.Unix(0, 0).UTC()
	}
	return t
}

// Option configures optional Fold behaviour via the functional-options idiom
// (C3R-1d, spec Amendment 2, issue #22): Fold's positional signature stays
// exactly Fold(records, vocab, now) - the literal interface plan task 3.3
// named - with the shop-default budget threaded as a variadic option rather
// than a fourth positional parameter, so a caller with no default (most
// vectors) reads identically to before this fix cycle.
type Option func(*foldOptions)

type foldOptions struct {
	defaultBudgetSeconds *float64
}

// WithDefaultBudgetSeconds supplies the shop-default budget
// (config/harness-defaults.json's dispatch_budget_seconds) Fold applies to a
// dispatched record that carries no budget of its own. Reversing the plan
// 3.1 carve-out that misclassified this as environmental IO (spec Amendment
// 2): the round-1 reviewer constructed a byte-identical budget-less
// dispatched record on which the pwsh detector rendered overdue/1800 and this
// package's Fold, with no way to receive a default, rendered dispatched/null
// - a real divergence on the only killed-dispatch surface (design S3.3,
// Probe 1). This option is how a caller (the vector-runner, and eventually
// Car 4's assembler) supplies that same default so both fold bodies agree.
func WithDefaultBudgetSeconds(seconds float64) Option {
	return func(o *foldOptions) { o.defaultBudgetSeconds = &seconds }
}

// Fold is the pure fold (package doc, fold.go): given materialised records, a
// recognition vocabulary, and an injected clock, it returns the same
// faults/discoveries/dispatches/intents shape the pwsh detector emits.
func Fold(records []Record, vocab Vocab, now time.Time, opts ...Option) Output {
	var o foldOptions
	for _, opt := range opts {
		opt(&o)
	}

	faults := []string{}
	discoveries := []string{}

	// DR3-2/YB-8 (design rev 5 S6, spec YB-8): a vocabulary that is valid but
	// carries zero values is a FAULT identical in shape to a malformed
	// vocabulary - ONE combined fault naming every empty source, and discovery
	// fan-out suppressed entirely (never partial, per-field suppression). The
	// pinned fault string names the vocab FILES ("kinds.json", "outcomes.json")
	// because that string is a cross-language contract surface
	// (schema/vectors/fold/empty-vocab-one-fault.json) - the same names the
	// runner contract's vocab materialisation step uses.
	var emptyVocabFiles []string
	if len(vocab.Kinds) == 0 {
		emptyVocabFiles = append(emptyVocabFiles, "kinds.json")
	}
	if len(vocab.Outcomes) == 0 {
		emptyVocabFiles = append(emptyVocabFiles, "outcomes.json")
	}
	vocabOk := len(emptyVocabFiles) == 0
	if !vocabOk {
		sort.Strings(emptyVocabFiles)
		faults = append(faults, "vocabulary: valid but empty: "+strings.Join(emptyVocabFiles, ", "))
	}

	if vocabOk {
		for _, r := range records {
			if k, ok := r.str("kind"); ok && k != "" && !vocab.hasKind(k) {
				d := "kind: " + k
				if !contains(discoveries, d) {
					discoveries = append(discoveries, d)
				}
			}
			if o, ok := r.str("outcome"); ok && o != "" && !vocab.hasOutcome(o) {
				d := "outcome: " + o
				if !contains(discoveries, d) {
					discoveries = append(discoveries, d)
				}
			}
		}
	}

	bySubject := map[string]*subjectGroup{}
	for _, r := range records {
		subject, sok := r.str("subject")
		kind, kok := r.str("kind")
		if !sok || subject == "" || !kok || kind == "" {
			continue
		}
		g, ok := bySubject[subject]
		if !ok {
			g = &subjectGroup{}
			bySubject[subject] = g
		}
		switch kind {
		case "dispatched", "returned", "presumed-lost":
			g.dispatch = append(g.dispatch, r)
		case "intent":
			g.intent = append(g.intent, r)
		}
	}

	subjects := make([]string, 0, len(bySubject))
	for s := range bySubject {
		subjects = append(subjects, s)
	}
	sort.Strings(subjects)

	dispatches := []DispatchEntry{}
	intents := []IntentEntry{}

	for _, subject := range subjects {
		g := bySubject[subject]

		if len(g.dispatch) > 0 {
			dispatches = append(dispatches, foldDispatchSubject(subject, g.dispatch, now, o.defaultBudgetSeconds))
		}
		if len(g.intent) > 0 {
			intents = append(intents, foldIntentSubject(subject, g.intent))
		}
	}

	return Output{
		Tier:        "tier-1-only",
		GeneratedAt: now.UTC().Format("2006-01-02T15:04:05Z"),
		Faults:      faults,
		Discoveries: discoveries,
		Dispatches:  dispatches,
		Intents:     intents,
	}
}

// foldDispatchSubject resolves one dispatch subject's winner (precedence,
// then latest-at within precedence) and renders its conditional shape
// (S3.1, S3.3, S3.4 - see output.go's DispatchEntry doc). defaultBudget is
// the shop-default budget threaded via WithDefaultBudgetSeconds, nil if the
// caller supplied none (C3R-1d, spec Amendment 2).
func foldDispatchSubject(subject string, records []Record, now time.Time, defaultBudget *float64) DispatchEntry {
	ranked := append([]Record(nil), records...)
	sort.SliceStable(ranked, func(i, j int) bool {
		ki, _ := ranked[i].str("kind")
		kj, _ := ranked[j].str("kind")
		if precedence[ki] != precedence[kj] {
			return precedence[ki] > precedence[kj]
		}
		return parseInstant(ranked[i]).After(parseInstant(ranked[j]))
	})

	winner := ranked[0]
	winnerKind, _ := winner.str("kind")
	winnerAt, _ := winner.str("at")

	superseded := []DispatchSupersededItem{}
	for _, rec := range ranked[1:] {
		k, _ := rec.str("kind")
		at, _ := rec.str("at")
		superseded = append(superseded, DispatchSupersededItem{Kind: k, At: at})
	}

	entry := DispatchEntry{
		Subject:    subject,
		State:      winnerKind,
		At:         winnerAt,
		Superseded: superseded,
		winnerKind: winnerKind,
	}

	switch winnerKind {
	case "returned":
		outcome, _ := winner.str("outcome")
		entry.Outcome = outcome
		if cost, ok := winner["cost"]; ok && cost != nil {
			entry.Spend = cost
		} else {
			entry.Spend = "absent"
		}
	case "dispatched":
		elapsed := int64(math.Floor(now.Sub(parseInstant(winner)).Seconds()))
		entry.ElapsedSeconds = elapsed
		// Budget: the record's own, else the threaded shop default (C3R-1d,
		// spec Amendment 2) - budget_source discloses WHICH patience produced
		// the rendered state, present only when a budget was actually applied.
		var budget *float64
		var budgetSource string
		if b, ok := winner.number("budget"); ok {
			budget = &b
			budgetSource = "record"
		} else if defaultBudget != nil {
			b := *defaultBudget
			budget = &b
			budgetSource = "default"
		}
		if budget != nil {
			entry.BudgetSeconds = budget
			entry.BudgetSource = budgetSource
			if float64(elapsed) > *budget {
				entry.State = "overdue"
			}
		}
	}

	return entry
}

// foldIntentSubject resolves one intent subject: latest-at wins, everything
// else is exposed in Superseded (S3.1, Law 2).
func foldIntentSubject(subject string, records []Record) IntentEntry {
	ranked := append([]Record(nil), records...)
	sort.SliceStable(ranked, func(i, j int) bool {
		return parseInstant(ranked[i]).After(parseInstant(ranked[j]))
	})

	winner := ranked[0]
	winnerAt, _ := winner.str("at")

	superseded := []IntentSupersededItem{}
	for _, rec := range ranked[1:] {
		at, _ := rec.str("at")
		superseded = append(superseded, IntentSupersededItem{At: at})
	}

	return IntentEntry{Subject: subject, At: winnerAt, Superseded: superseded}
}
