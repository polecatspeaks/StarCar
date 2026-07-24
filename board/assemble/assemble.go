// Package assemble is the yard board's Assembler (plan task 4.2, design
// S5.3): it composes the trains/gates/dispatches surfaces from the fold's
// output plus the raw store records. It NEVER re-selects "latest manifest"
// itself - that would re-implement the fold's own supersession logic, the
// Law 6 second-copy trap design S5.3 names explicitly. The fold picks the
// winning manifest per train subject (fold.Output.Intents); this package
// only ever fetches the raw payload for the subject+at the fold already
// named.
package assemble

import (
	"encoding/json"
	"fmt"
	"sort"
	"strings"

	"github.com/polecatspeaks/StarCar/board/fold"
	"github.com/polecatspeaks/StarCar/board/store"
)

const trainPrefix = "train:"

// Assemble composes Result from in. It never panics on malformed manifest
// content - a manifest payload that cannot be read is disclosed as a board
// condition and that train is skipped, never a crash (Law 1: a board that
// guesses or dies is worse than one that discloses).
func Assemble(in Input) Result {
	var result Result

	dispatchBySubject := make(map[string]fold.DispatchEntry, len(in.Fold.Dispatches))
	for _, d := range in.Fold.Dispatches {
		dispatchBySubject[d.Subject] = d
	}

	// DR3-3: a subject appearing in BOTH fold.dispatches and fold.intents
	// should be impossible under the train: partition rule; if observed
	// anyway, name it - the rule and the detector, both, deliberately
	// (design S6).
	intentSubjects := make(map[string]bool, len(in.Fold.Intents))
	for _, it := range in.Fold.Intents {
		intentSubjects[it.Subject] = true
	}
	var collidedSubjects []string
	for _, d := range in.Fold.Dispatches {
		if intentSubjects[d.Subject] {
			collidedSubjects = append(collidedSubjects, d.Subject)
		}
	}
	sort.Strings(collidedSubjects)
	for _, s := range collidedSubjects {
		result.Conditions = append(result.Conditions, store.BoardCondition{
			Code:     "subject-namespace-collision",
			Detail:   fmt.Sprintf("subject %q appears in both fold.dispatches and fold.intents - the train: partition rule should make this impossible", s),
			Register: "needs-attention",
		})
	}

	// memberClaims tracks, for YB-14, which train subjects claim each
	// member dispatch subject - a dispatch claimed by more than one
	// DIFFERENT train is a manifest-membership-collision.
	memberClaims := map[string][]string{}
	assignedSubjects := map[string]bool{}

	for _, intent := range in.Fold.Intents {
		if !strings.HasPrefix(intent.Subject, trainPrefix) {
			continue // not a manifest (design S5.5); v0's four surfaces render no other intent kind
		}

		raw, found := findRawIntentRecord(in.Records, intent.Subject, intent.At)
		if !found {
			result.Conditions = append(result.Conditions, store.BoardCondition{
				Code:     "manifest-record-not-found",
				Detail:   fmt.Sprintf("the fold named %q at %q as the winning manifest, but no matching raw record was found", intent.Subject, intent.At),
				Register: "needs-attention",
			})
			continue
		}

		title, members, ok := manifestPayload(raw)
		if !ok {
			result.Conditions = append(result.Conditions, store.BoardCondition{
				Code:     "manifest-payload-unreadable",
				Detail:   fmt.Sprintf("%q's manifest payload could not be read", intent.Subject),
				Register: "needs-attention",
			})
			continue
		}

		train := Train{ID: intent.Subject, Title: title, Cars: []TrainCar{}, DeclaredNotObserved: []string{}}
		for _, m := range members {
			memberClaims[m.Subject] = append(memberClaims[m.Subject], intent.Subject)
			assignedSubjects[m.Subject] = true

			d, ok := dispatchBySubject[m.Subject]
			if !ok {
				train.DeclaredNotObserved = append(train.DeclaredNotObserved, m.Subject)
				continue
			}
			car := TrainCar{
				Subject:    m.Subject,
				Role:       m.Role,
				Gate:       m.Gate,
				State:      d.State,
				At:         d.At,
				Superseded: d.Superseded,
			}
			if d.State == "returned" {
				car.Outcome = d.Outcome
			}
			train.Cars = append(train.Cars, car)

			if m.Role == "gate" && d.State == "returned" {
				name := m.Gate
				if name == "" {
					name = m.Role
				}
				result.Gates.Gates = append(result.Gates.Gates, Gate{
					Name:    name,
					Subject: m.Subject,
					Outcome: d.Outcome,
					At:      d.At,
				})
			}
		}
		result.Trains.Trains = append(result.Trains.Trains, train)
	}

	// YB-14: two different manifests claiming one dispatch - disclosed,
	// never resolved by silent precedence (both trains keep it, above).
	var collidedMembers []string
	for subj := range memberClaims {
		if len(memberClaims[subj]) > 1 {
			collidedMembers = append(collidedMembers, subj)
		}
	}
	sort.Strings(collidedMembers)
	for _, subj := range collidedMembers {
		trains := append([]string(nil), memberClaims[subj]...)
		sort.Strings(trains)
		result.Conditions = append(result.Conditions, store.BoardCondition{
			Code:     "manifest-membership-collision",
			Detail:   fmt.Sprintf("dispatch %q is claimed by more than one manifest: %s", subj, strings.Join(trains, ", ")),
			Register: "needs-attention",
		})
	}

	// Dispatches lane: every fold dispatch, "assigned" true iff claimed by
	// at least one winning manifest's members (yard inventory = false,
	// rendered loudly per YB-5).
	for _, d := range in.Fold.Dispatches {
		m, err := dispatchWireMap(d, assignedSubjects[d.Subject])
		if err != nil {
			result.Conditions = append(result.Conditions, store.BoardCondition{
				Code:     "dispatch-render-failed",
				Detail:   fmt.Sprintf("subject %q could not be rendered to the wire shape: %v", d.Subject, err),
				Register: "needs-attention",
			})
			continue
		}
		result.Dispatches.Dispatches = append(result.Dispatches.Dispatches, m)
	}
	if result.Dispatches.Dispatches == nil {
		result.Dispatches.Dispatches = []map[string]any{}
	}
	if result.Gates.Gates == nil {
		result.Gates.Gates = []Gate{}
	}
	if result.Trains.Trains == nil {
		result.Trains.Trains = []Train{}
	}

	return result
}

// dispatchWireMap reuses fold.DispatchEntry's OWN MarshalJSON (the single
// owner of its conditional key set - Law 6) and augments the result with
// "assigned", rather than re-implementing the conditional shape here.
func dispatchWireMap(d fold.DispatchEntry, assigned bool) (map[string]any, error) {
	data, err := json.Marshal(d)
	if err != nil {
		return nil, err
	}
	var m map[string]any
	if err := json.Unmarshal(data, &m); err != nil {
		return nil, err
	}
	m["assigned"] = assigned
	return m, nil
}

// findRawIntentRecord fetches the SPECIFIC raw record the fold named as the
// winning manifest for subject at at - never a re-selection of "latest"
// among candidates (that authority belongs to fold.Output.Intents alone).
func findRawIntentRecord(records []store.Record, subject, at string) (store.Record, bool) {
	for _, r := range records {
		if s, _ := r.Fields["subject"].(string); s != subject {
			continue
		}
		if k, _ := r.Fields["kind"].(string); k != "intent" {
			continue
		}
		if a, _ := r.Fields["at"].(string); a != at {
			continue
		}
		return r, true
	}
	return store.Record{}, false
}

type manifestMember struct {
	Subject string
	Role    string
	Gate    string
}

// manifestPayload reads the raw intent record's "manifest" key (design
// DR3-1: "the manifest PAYLOAD - members, roles, title, ticket refs - is NOT
// in fold output and never will be; it lives in the raw intent records").
func manifestPayload(r store.Record) (title string, members []manifestMember, ok bool) {
	raw, isMap := r.Fields["manifest"].(map[string]any)
	if !isMap {
		return "", nil, false
	}
	title, _ = raw["title"].(string)
	rawMembers, _ := raw["members"].([]any)
	for _, rm := range rawMembers {
		mm, isMap := rm.(map[string]any)
		if !isMap {
			continue
		}
		subject, _ := mm["subject"].(string)
		role, _ := mm["role"].(string)
		gate, _ := mm["gate"].(string)
		if subject == "" {
			continue
		}
		members = append(members, manifestMember{Subject: subject, Role: role, Gate: gate})
	}
	return title, members, true
}
