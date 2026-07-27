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

	// #28: single pass over the raw records, single-sourced from
	// store.Record.Path (recordDirBySubject's own doc comment). Moved ABOVE
	// the collision loop (#69/#71): every board condition constructed in
	// this function now carries RecordDir when its own subject resolves one,
	// so recordDirs must already exist before the first condition is built.
	recordDirs := recordDirBySubject(in.Records)

	// #75: the human task-id handle (the #47 envelope echo), resolved from
	// the fold's own dispatch winners - see taskIDsBySubject's doc comment
	// for why this is NOT recordDirBySubject's first-write-wins shape.
	taskIDs := taskIDsBySubject(in.Records, in.Fold.Dispatches)

	for _, s := range collidedSubjects {
		result.Conditions = append(result.Conditions, store.BoardCondition{
			Code:      "subject-namespace-collision",
			Detail:    fmt.Sprintf("subject %q appears in both fold.dispatches and fold.intents - the train: partition rule should make this impossible", s),
			Register:  store.RegisterForCode("subject-namespace-collision"),
			RecordDir: recordDirs[s],
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
				Code:      "manifest-record-not-found",
				Detail:    fmt.Sprintf("the fold named %q at %q as the winning manifest, but no matching raw record was found", intent.Subject, intent.At),
				Register:  store.RegisterForCode("manifest-record-not-found"),
				RecordDir: recordDirs[intent.Subject],
			})
			continue
		}

		title, tickets, members, ok := manifestPayload(raw)
		if !ok {
			result.Conditions = append(result.Conditions, store.BoardCondition{
				Code:      "manifest-payload-unreadable",
				Detail:    fmt.Sprintf("%q's manifest payload could not be read", intent.Subject),
				Register:  store.RegisterForCode("manifest-payload-unreadable"),
				RecordDir: recordDirs[intent.Subject],
			})
			continue
		}

		train := Train{ID: intent.Subject, Title: title, Tickets: tickets, Cars: []TrainCar{}, DeclaredNotObserved: []string{}}
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
				RecordDir:  recordDirs[m.Subject],
				TaskID:     taskIDs[m.Subject],
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
				// #28/#12 fix cycle round 2 MAJOR-4: d.At (the fold's own
				// winner timestamp, already in scope here) pins the findings
				// lookup to the SAME record Outcome/At above came from -
				// never a re-selection that could diverge from them. The
				// Go-side ASSERTION the round-1 review asked for: if the
				// fold names a "returned" winner but no raw record actually
				// matches subject+kind="returned"+at (a data-integrity
				// contradiction - the fold is built FROM these same
				// records, so this should be unreachable in practice), that
				// is disclosed as its own board condition rather than
				// silently rendering an empty Findings string as if the
				// record simply had none.
				findings, findingsFound := findingsForReturnedSubject(in.Records, m.Subject, d.At)
				if !findingsFound {
					result.Conditions = append(result.Conditions, store.BoardCondition{
						Code:      "gate-findings-record-not-found",
						Detail:    fmt.Sprintf("the fold named %q at %q as a returned gate winner, but no matching raw returned record was found for its findings", m.Subject, d.At),
						Register:  store.RegisterForCode("gate-findings-record-not-found"),
						RecordDir: recordDirs[m.Subject],
					})
				}
				result.Gates.Gates = append(result.Gates.Gates, Gate{
					Name:      name,
					Subject:   m.Subject,
					Outcome:   d.Outcome,
					At:        d.At,
					RecordDir: recordDirs[m.Subject],
					Findings:  findings,
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
			Code:      "manifest-membership-collision",
			Detail:    fmt.Sprintf("dispatch %q is claimed by more than one manifest: %s", subj, strings.Join(trains, ", ")),
			Register:  store.RegisterForCode("manifest-membership-collision"),
			RecordDir: recordDirs[subj],
		})
	}

	// Dispatches lane: every fold dispatch, "assigned" true iff claimed by
	// at least one winning manifest's members (yard inventory = false,
	// rendered loudly per YB-5).
	for _, d := range in.Fold.Dispatches {
		m, err := dispatchWireMap(d, assignedSubjects[d.Subject], recordDirs[d.Subject], taskIDs[d.Subject])
		if err != nil {
			// #69/#71 fix cycle round 2 (MAJOR-R1-3): CORRECTED - the prior
			// version of this comment claimed "no test outside board/fold can
			// construct a fold.DispatchEntry that reaches this branch"
			// because d.winnerKind is unexported. That is false: winnerKind
			// only SELECTS this branch (set internally by fold.Fold, inside
			// package fold); it is Spend (board/fold/fold.go, EXPORTED) that
			// carries the value MarshalJSON cannot encode, and
			// fold.Output.Dispatches is exported too. A package outside
			// board/fold reaches this branch by running the real fold.Fold
			// to get a genuine "returned"-winner entry, then mutating that
			// entry's exported Spend field - see
			// TestAssembleDispatchRenderFailedIsReachable
			// (board/assemble/assemble_test.go), which does exactly that and
			// asserts the resulting condition's RecordDir.
			result.Conditions = append(result.Conditions, store.BoardCondition{
				Code:      "dispatch-render-failed",
				Detail:    fmt.Sprintf("subject %q could not be rendered to the wire shape: %v", d.Subject, err),
				Register:  store.RegisterForCode("dispatch-render-failed"),
				RecordDir: recordDirs[d.Subject],
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
// "assigned", (#28) "recordDir", and (#75) "taskId" - each key is omitted
// entirely (never an empty string) when its value is "", matching every
// other optional wire field's omitempty convention.
func dispatchWireMap(d fold.DispatchEntry, assigned bool, recordDir string, taskID string) (map[string]any, error) {
	data, err := json.Marshal(d)
	if err != nil {
		return nil, err
	}
	var m map[string]any
	if err := json.Unmarshal(data, &m); err != nil {
		return nil, err
	}
	m["assigned"] = assigned
	if recordDir != "" {
		m["recordDir"] = recordDir
	}
	if taskID != "" {
		m["taskId"] = taskID
	}
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
// tickets (#28) is manifest.tickets verbatim - schema/starcar-manifest.
// schema.json already declares this key; this is its first reader.
func manifestPayload(r store.Record) (title string, tickets []string, members []manifestMember, ok bool) {
	raw, isMap := r.Fields["manifest"].(map[string]any)
	if !isMap {
		return "", nil, nil, false
	}
	title, _ = raw["title"].(string)
	rawTickets, _ := raw["tickets"].([]any)
	for _, rt := range rawTickets {
		if s, isStr := rt.(string); isStr {
			tickets = append(tickets, s)
		}
	}
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
	return title, tickets, members, true
}

// recordDirBySubject (#28, design note 1: "the wire exposes each entry's
// record path - the adapter already knows it (store.Record.Path); emitting
// it is single-source, while view-side re-derivation would duplicate the
// subject-sanitisation rule") builds subject -> STORE-ROOT-RELATIVE
// directory, from records ALONE - never from Config, keeping this package's
// existing boundary (assemble derives from store.Record + fold.Output only;
// the repo-root-relative prefix that turns this into a full GitHub path is a
// server-side concern, board/server/githublinks.go, added on top of this
// value). First-write-wins per subject: in practice every record for one
// subject lives under the SAME directory, but CORRECTED (#28/#12 fix cycle
// round 2 MINOR-3: the prior wording attributed this to store.Adapter.Scan
// "enforcing" a layout - it does not; Scan (store.go) walks the ENTIRE
// storeRoot recursively for any *.json file, with no directory-structure
// requirement at all) - the one-directory-per-subject shape is an OBSERVED
// property of the producer's writing pattern (scripts/Produce-Artifact.ps1
// writes one new file per dispatch event under
// `<subject>/<kind>-<compact-at>.json`, per the state ledger's own Q1
// answer), never something this package or Scan imposes. First-write-wins
// is therefore a defensive, not a load-bearing, choice: if a future
// producer ever violated the convention, this function would silently keep
// whichever directory it saw first rather than crash - a latent
// divergence this comment now names rather than hides.
//
// #69/#71 fix cycle round 2 (MINOR-R1-1, Law 6): the dir-from-path rule
// itself (filepath.Dir + "." means no directory component) used to be
// INLINED here as a second copy of board/store.RecordDirFromRelPath
// (store.go), on the stated justification that store's two call sites fire
// at SCAN TIME, before this function's own map exists - true, but that
// explains why the CALL SITES differ, never why the RULE was copied. This
// package already imports board/store (see the import block above), so the
// exported helper is called directly; no copy remains.
func recordDirBySubject(records []store.Record) map[string]string {
	out := make(map[string]string, len(records))
	for _, r := range records {
		subject, _ := r.Fields["subject"].(string)
		if subject == "" {
			continue
		}
		if _, seen := out[subject]; seen {
			continue
		}
		dir := store.RecordDirFromRelPath(r.Path)
		if dir == "" {
			continue // Path had no directory component - no link rather than a wrong one
		}
		out[subject] = dir
	}
	return out
}

// findingsForReturnedSubject (#12: car health bar) fetches the RAW
// "findings" field off the SPECIFIC record the fold already named as this
// subject's returned winner - subject + kind=="returned" + at==at, mirroring
// findRawIntentRecord above exactly (never a second "pick the latest"
// selection; that authority stays fold.Output's alone, the same Law 6 trap
// findRawIntentRecord avoids for manifests). CORRECTED (#28/#12 fix cycle
// round 2 MAJOR-4, a LIVE wire defect, reproduced by
// TestAssembleGateFindingsMatchesFoldWinnerNotFirstScanOrder): the prior
// version matched on subject+kind ALONE and returned the FIRST match in
// whatever order `records` arrived - in production that is store.go's
// sort.Strings on PATH, which puts an EARLIER timestamp-in-filename first,
// while the fold's own winner (algorithm.go's parseInstant `.After`
// comparison) is the NEWEST `at`. A subject with 2+ returned records (the
// dominant shape for reviewed subjects - 30 of them in the real store)
// therefore rendered the SUPERSEDED record's findings next to the WINNING
// record's outcome: observed live, a gate row carrying outcome APPROVE at
// 11:00 alongside findings "3 Major, 1 Minor" from the superseded 10:00
// record. Callers now pass the winning dispatch's own `At` (already in
// scope at the one call site, Assemble's `d.At`), so this can never
// diverge from the outcome it is rendered beside. The bool return is the
// Go-side assertion the round-1 review asked for (MAJOR-4): the caller
// discloses a board condition rather than silently accepting an empty
// Findings string on the (should-be-unreachable) case where the fold's
// named winner has no matching raw record.
func findingsForReturnedSubject(records []store.Record, subject, at string) (string, bool) {
	for _, r := range records {
		if s, _ := r.Fields["subject"].(string); s != subject {
			continue
		}
		if k, _ := r.Fields["kind"].(string); k != "returned" {
			continue
		}
		if a, _ := r.Fields["at"].(string); a != at {
			continue
		}
		findings, _ := r.Fields["findings"].(string)
		return findings, true
	}
	return "", false
}

// taskIDsBySubject (#75) resolves each dispatch subject's task-id - the
// shop-minted human handle (#47's envelope echo) - from the SPECIFIC raw
// record the fold itself named as that subject's winner, never a
// first-write-wins scan. recordDirBySubject's first-write-wins convention
// (comment above) does NOT apply here: a directory is genuinely the SAME
// for every record under one subject (an observed producer-writing-pattern
// fact), but task_id is NOT the same across a subject's records - as of
// #75's landing, only a RETURNED record carries one (probed on issue #75:
// dispatched records carry no task_id yet, pending #76's producer work).
// store.go's Scan sorts by PATH (sort.Strings), which for a subject with
// both a "dispatched-*.json" and a later "returned-*.json" would put the
// task_id-less dispatched record first alphabetically - first-write-wins
// would therefore silently render NO task-id for a subject that has, in
// fact, returned with one. This mirrors findingsForReturnedSubject's exact
// subject+kind==returned+at==the fold's own winning At match instead (never
// a second "pick the latest" selection - that authority stays fold.Output's
// alone), scoped to only the subjects the fold itself resolved to a
// "returned" State; every other liveness state (dispatched/overdue/
// presumed-lost) is skipped outright rather than probed for a field it is
// known never to carry yet.
func taskIDsBySubject(records []store.Record, dispatches []fold.DispatchEntry) map[string]string {
	out := make(map[string]string, len(dispatches))
	for _, d := range dispatches {
		if d.State != "returned" {
			continue
		}
		if id := taskIDForReturnedSubject(records, d.Subject, d.At); id != "" {
			out[d.Subject] = id
		}
	}
	return out
}

// taskIDForReturnedSubject (#75) fetches the RAW "task_id" field off the
// SPECIFIC record the fold already named as this subject's returned winner
// - subject + kind=="returned" + at==at, the same exact-match convention
// findingsForReturnedSubject established just above. Returns "" (Law 1:
// absent renders absent, never invented) both when no matching raw record
// exists and when the matching record simply carries no task_id - #51
// already declared task_id an OPTIONAL producer field (board/store/
// store.go's typedRecord), so a returned record predating #47's envelope
// echo is an expected, honest steady state, not disclosed as its own board
// condition here (unlike findingsForReturnedSubject's missing-RECORD case,
// which IS a data-integrity contradiction worth disclosing).
func taskIDForReturnedSubject(records []store.Record, subject, at string) string {
	for _, r := range records {
		if s, _ := r.Fields["subject"].(string); s != subject {
			continue
		}
		if k, _ := r.Fields["kind"].(string); k != "returned" {
			continue
		}
		if a, _ := r.Fields["at"].(string); a != at {
			continue
		}
		taskID, _ := r.Fields["task_id"].(string)
		return taskID
	}
	return ""
}
