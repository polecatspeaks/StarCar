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

// Fold is the pure fold (package doc, fold.go): given materialised records, a
// recognition vocabulary, and an injected clock, it returns the same
// faults/discoveries/dispatches/intents shape the pwsh detector emits.
func Fold(records []Record, vocab Vocab, now time.Time) Output {
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
			dispatches = append(dispatches, foldDispatchSubject(subject, g.dispatch, now))
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
// (S3.1, S3.3, S3.4 - see output.go's DispatchEntry doc).
func foldDispatchSubject(subject string, records []Record, now time.Time) DispatchEntry {
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
		// No shop-default threading (package doc's scope note): budget renders
		// from the record's own field only; absent stays JSON null, never
		// promoted to overdue without a known budget.
		if budget, ok := winner.number("budget"); ok {
			b := budget
			entry.BudgetSeconds = &b
			if float64(elapsed) > budget {
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
