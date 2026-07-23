package fold

import "encoding/json"

// MarshalJSON builds the conditional key set a DispatchEntry's winnerKind
// dictates (see fold.go's DispatchEntry doc): subject/state/at/superseded
// always; outcome+spend only for a "returned" winner; elapsed_seconds+
// budget_seconds only for a "dispatched" winner (never for "presumed-lost").
func (d DispatchEntry) MarshalJSON() ([]byte, error) {
	superseded := d.Superseded
	if superseded == nil {
		superseded = []DispatchSupersededItem{}
	}
	m := map[string]any{
		"subject":    d.Subject,
		"state":      d.State,
		"at":         d.At,
		"superseded": superseded,
	}
	switch d.winnerKind {
	case "returned":
		m["outcome"] = d.Outcome
		m["spend"] = d.Spend
	case "dispatched":
		m["elapsed_seconds"] = d.ElapsedSeconds
		m["budget_seconds"] = d.BudgetSeconds // nil marshals to JSON null, matching pwsh's explicit null
		// budget_source (C3R-1d, spec Amendment 2 item (b)): present ONLY
		// alongside a non-null budget_seconds - never a phantom source for a
		// null budget, kept minimal per the owner's ruling.
		if d.BudgetSeconds != nil {
			m["budget_source"] = d.BudgetSource
		}
	}
	return json.Marshal(m)
}

// IntentEntry is one intent subject's fold (S3.1, Law 2): latest-at wins, the
// rest are exposed in Superseded. No conditional shape - always three keys.
type IntentEntry struct {
	Subject    string                 `json:"subject"`
	At         string                 `json:"at"`
	Superseded []IntentSupersededItem `json:"superseded"`
}

// Output is the fold's full result - the shape schema/vectors/README.md's
// runner contract deep-equals faults/discoveries/dispatches/intents against
// (tier and generated_at are excluded from that comparison, being
// environmental, but are still part of the real artifact Car 4 consumes -
// they always carry a value here, matching the pwsh detector's own output).
type Output struct {
	Tier        string          `json:"tier"`
	GeneratedAt string          `json:"generated_at"`
	Faults      []string        `json:"faults"`
	Discoveries []string        `json:"discoveries"`
	Dispatches  []DispatchEntry `json:"dispatches"`
	Intents     []IntentEntry   `json:"intents"`
}
