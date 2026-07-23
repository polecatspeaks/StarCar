package main

import (
	"encoding/json"

	"github.com/polecatspeaks/StarCar/board/assemble"
)

// sseEventName is the SSE event name this server writes. It MUST equal
// schema/yard-snapshot.schema.json's $defs.sseEventName.const - a test
// (sse_test.go) asserts this against the schema's own constant, never
// against a locally re-typed string with no tether back to the schema.
const sseEventName = "yard"

// WireBoardCondition mirrors schema/yard-snapshot.schema.json's
// $defs.boardCondition.
type WireBoardCondition struct {
	Code     string `json:"code"`
	Detail   string `json:"detail"`
	Register string `json:"register"`
}

// FreshnessReason mirrors the wire schema's failed-variant "reason" object.
type FreshnessReason struct {
	Code   string `json:"code"`
	Detail string `json:"detail"`
}

// Freshness mirrors $defs.freshness's oneOf shape (design S5.2): only the
// fields relevant to Kind are ever populated, so the marshaled JSON always
// satisfies exactly one oneOf branch.
type Freshness struct {
	Kind         string           `json:"kind"`
	AsOf         *string          `json:"asOf,omitempty"`
	AgeBucketMs  *int64           `json:"ageBucketMs,omitempty"`
	Reason       *FreshnessReason `json:"reason,omitempty"`
	LastGoodAsOf *string          `json:"lastGoodAsOf,omitempty"`
}

// Lane mirrors $defs.lane. Data is omitted entirely for lanes with no
// adapter (freight/fuel, dark/bagged) - the landed wire schema carries no
// surfacesData flag (a design S5.2 mention that did not make it into the
// schema car's landed $defs; disclosed in this car's report), so absence of
// the key itself is what signals "no payload" on the wire.
type Lane struct {
	ID        string    `json:"id"`
	Title     string    `json:"title"`
	Position  string    `json:"position"`
	Freshness Freshness `json:"freshness"`
	Data      any       `json:"data,omitempty"`
}

// WireConfig mirrors $defs's top-level "config" property.
type WireConfig struct {
	PollMs           int    `json:"pollMs"`
	HeartbeatMs      int    `json:"heartbeatMs"`
	StalenessMs      int    `json:"stalenessMs"`
	StorePathDisplay string `json:"storePathDisplay"`
	LaneCount        int    `json:"laneCount"`
	DemoMode         bool   `json:"demoMode"`
}

// Snapshot is the top-level YardSnapshot - schema/yard-snapshot.schema.json
// is the one owner of this shape (D15); this struct conforms to it, never
// the other way around.
type Snapshot struct {
	Seq          int                   `json:"seq"`
	AsOf         *string               `json:"asOf"`
	Config       WireConfig            `json:"config"`
	Vocabularies assemble.Vocabularies `json:"vocabularies"`
	Board        []WireBoardCondition  `json:"board"`
	Lanes        []Lane                `json:"lanes"`
}

// marshalSnapshot is the ONE marshal path (design S5.4 item 5): both
// /api/snapshot and /api/stream call this exact function, so their outputs
// for the same Snapshot value are byte-identical by construction (pinned by
// sse_test.go's byte-identity test), never two hand-maintained encodings.
func marshalSnapshot(s Snapshot) ([]byte, error) {
	return json.Marshal(s)
}
