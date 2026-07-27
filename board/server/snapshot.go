package main

import (
	"encoding/json"

	"github.com/polecatspeaks/StarCar/board/assemble"
)

// sseEventName is the SSE event name this server writes. It MUST equal
// schema/yard-snapshot.schema.json's $defs.sseEventName.const -
// TestSSEEventNameMatchesSchemaConstant (sse_const_test.go) asserts this
// against the schema's own constant, never against a locally re-typed
// string with no tether back to the schema.
const sseEventName = "yard"

// WireBoardCondition mirrors schema/yard-snapshot.schema.json's
// $defs.boardCondition.
type WireBoardCondition struct {
	Code     string `json:"code"`
	Detail   string `json:"detail"`
	Register string `json:"register"`
	// RecordDir (#69/#71: clickable provenance) mirrors store.BoardCondition.
	// RecordDir - omitted (never an empty string on the wire) when this
	// condition names no single subject/record.
	RecordDir string `json:"recordDir,omitempty"`
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

// Lane mirrors $defs.lane. Data is omitted entirely for a lane with NO
// adapter at all (fuel, bagged - #84 fix cycle round 2, R1-m1: CORRECTED,
// this comment used to also name freight/dark here, stale since #84 flipped
// freight's registry position to live and gave it a real adapter) - the
// landed wire schema carries no surfacesData flag (a design S5.2 mention
// that did not make it into the schema car's landed $defs; disclosed in
// that car's report), so absence of the key itself is what signals "no
// payload" on the wire for the lane(s) it still applies to.
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
	// GitHubRepoURL/GitHubRef/GitHubArtifactsPrefix (#28) are the ONLY three
	// primitives the view needs to build every provenance link itself -
	// never a per-link URL computed server-side (that would duplicate the
	// same string-building logic on every entry). CORRECTED (#28/#12 fix
	// cycle round 2 MINOR-1: the prior wording claimed all three are ""
	// under one shared condition, which the live wire disproves): each
	// field degrades independently -
	//   - GitHubRepoURL is "" exactly when Config.GitHubRepo is unset
	//     (STARCAR_GITHUB_REPO never configured).
	//   - GitHubRef defaults to "dev" (DefaultConfig) regardless of whether
	//     GitHubRepo is set, and is observed non-empty on every real wire
	//     snapshot unless STARCAR_GITHUB_REF is explicitly cleared.
	//   - GitHubArtifactsPrefix is "" only when Config.RepoRoot is unset or
	//     StorePath does not resolve under it (githubArtifactsPrefix,
	//     githublinks.go) - independent of whether GitHubRepo is configured
	//     at all, and observed non-empty ("artifacts") on this repo's own
	//     default production layout.
	// The view (links.js) still requires GitHubRepoURL non-empty before
	// rendering ANY link - a non-empty prefix or ref alone never produces
	// one, so "no link, never a broken one" still holds in every case.
	GitHubRepoURL         string `json:"githubRepoUrl,omitempty"`
	GitHubRef             string `json:"githubRef,omitempty"`
	GitHubArtifactsPrefix string `json:"githubArtifactsPrefix,omitempty"`
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
// TestSnapshotAndStreamShareOneMarshalPath, handlers_test.go), never two
// hand-maintained encodings.
func marshalSnapshot(s Snapshot) ([]byte, error) {
	return json.Marshal(s)
}
