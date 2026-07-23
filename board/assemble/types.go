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
}

// Train is one train: subject's consist. id is the WHOLE train: subject,
// never stripped of its prefix for meaning (design DR3-3).
type Train struct {
	ID                  string     `json:"id"`
	Title               string     `json:"title"`
	Cars                []TrainCar `json:"cars"`
	DeclaredNotObserved []string   `json:"declaredNotObserved"`
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
}

// GatesPayload is the gates lane's wire data shape (spec YB-5).
type GatesPayload struct {
	Gates []Gate `json:"gates"`
}

// DispatchesPayload is the dispatches lane's wire data shape: fold.Output's
// own dispatch entries (their conditional JSON shape stays owned by
// fold.DispatchEntry.MarshalJSON, never re-implemented here - Law 6), each
// augmented with "assigned" (yard inventory = unassigned, rendered loudly).
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
