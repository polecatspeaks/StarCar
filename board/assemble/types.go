package assemble

import (
	"github.com/polecatspeaks/StarCar/board/fold"
	"github.com/polecatspeaks/StarCar/board/store"
)

// TrainCar is one manifest member joined to its dispatch liveness (design
// S5.3's two-step join). JSON tags match schema/yard-snapshot.schema.json's
// $defs.trainsPayload.properties.trains.items.properties.cars.items exactly.
type TrainCar struct {
	Subject    string                        `json:"subject"`
	Role       string                        `json:"role"`
	Gate       string                        `json:"gate,omitempty"`
	State      string                        `json:"state"`
	At         string                        `json:"at"`
	Outcome    string                        `json:"outcome,omitempty"`
	Superseded []fold.DispatchSupersededItem `json:"superseded,omitempty"`
	// RecordDir (#28: clickable provenance) is this subject's record
	// directory, RELATIVE TO THE STORE ROOT (e.g. "51-fix-car-r1") -
	// single-sourced from store.Record.Path (recordDirBySubject,
	// assemble.go), never re-derived from Subject client-side (Law 6: the
	// view would otherwise duplicate the store's own subject-to-directory
	// convention). Empty when no surviving record names this subject (never
	// observed in practice, but Law 1 - no link is rendered rather than a
	// guessed one).
	RecordDir string `json:"recordDir,omitempty"`
	// TaskID (#75: the human task-id handle, replacing the record-dir hash
	// as a row's visible identity) is this subject's shop-minted task-id
	// (the #47 envelope echo) - single-sourced from the winning RETURNED
	// record's own task_id field (assemble.go's taskIDsBySubject), never
	// re-derived from Subject client-side. Empty when no returned record
	// for this subject carries one - a dispatched-only car (the #76
	// producer-side half, not yet landed) or a returned record predating
	// #47 (Law 1: absent renders absent, never a guessed handle).
	TaskID string `json:"taskId,omitempty"`
}

// Train is one train: subject's consist. id is the WHOLE train: subject,
// never stripped of its prefix for meaning (design DR3-3).
type Train struct {
	ID                  string     `json:"id"`
	Title               string     `json:"title"`
	Cars                []TrainCar `json:"cars"`
	DeclaredNotObserved []string   `json:"declaredNotObserved"`
	// Tickets (#28: "#N tokens in rendered text link to issues") is the
	// manifest's own declared ticket refs (manifest.tickets,
	// schema/starcar-manifest.schema.json - already schema-declared; this
	// is the first consumer that reads it). Never re-parsed from Title
	// prose - the manifest already carries this as a structured field, so
	// re-parsing it would be a second, fuzzier derivation of the same fact
	// (Law 6). Empty, never nil-vs-omitted-confusion, when the manifest
	// declares none.
	Tickets []string `json:"tickets,omitempty"`
}

// TrainsPayload is the trains lane's wire data shape (spec YB-5).
type TrainsPayload struct {
	Trains []Train `json:"trains"`
}

// Gate is one gate verdict, rendered only once its dispatch has RETURNED
// (design: "returned records' outcome rendered VERBATIM").
type Gate struct {
	Name    string `json:"name"`
	Subject string `json:"subject"`
	Outcome string `json:"outcome"`
	At      string `json:"at"`
	// RecordDir (#28): same convention as TrainCar.RecordDir above - this
	// gate's returned record's directory, relative to the store root.
	RecordDir string `json:"recordDir,omitempty"`
	// Findings (#12: car health bar) is the returned record's own findings
	// field, VERBATIM free text (never re-derived, same posture as Outcome
	// above) - the view's findings.js module parses a conservative Major/
	// Minor count out of it CLIENT-SIDE; this field carries the raw source
	// text so that parsing has exactly one place to happen, not a second
	// Go-side reimplementation of the same regex (Law 6).
	Findings string `json:"findings,omitempty"`
}

// GatesPayload is the gates lane's wire data shape (spec YB-5).
type GatesPayload struct {
	Gates []Gate `json:"gates"`
}

// DispatchesPayload is the dispatches lane's wire data shape: fold.Output's
// own dispatch entries (their conditional JSON shape stays owned by
// fold.DispatchEntry.MarshalJSON, never re-implemented here - Law 6), each
// augmented with "assigned" (yard inventory = unassigned, rendered loudly),
// "recordDir" (#28), and "taskId" (#75, present only for a returned winner
// whose own record carries one).
type DispatchesPayload struct {
	Dispatches []map[string]any `json:"dispatches"`
}

// Input is everything Assemble consumes: the raw store records (for
// manifest-payload joins) and the fold's own output (the SOLE supersession
// and liveness authority - Assemble never re-selects "latest" itself,
// design 5.3's Law 6 trap).
type Input struct {
	Records []store.Record
	Fold    fold.Output
}

// Result is the four derived surfaces plus whatever board conditions
// assembly itself raised (manifest-membership-collision, subject-namespace-
// collision, and any defensive fallback conditions).
type Result struct {
	Trains     TrainsPayload
	Gates      GatesPayload
	Dispatches DispatchesPayload
	Conditions []store.BoardCondition
}
