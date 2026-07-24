// lanes.js - the view's own knowledge of v0's five lanes (design rev 5
// S5.2 completeness guard, restated at the view layer; mirrors the
// server's board/server/laneregistry.go, but this file is NOT a mirror of
// server DATA - it is the view's independent statement of which lane ids
// it knows how to RENDER, and how). Shrinking EXPECTED_LANE_IDS is a red
// (fixture pin), same as the server's TestLaneRegistryPin.
//
// The wire schema's own lane.data comment (schema/yard-snapshot.schema.json)
// is explicit: "an unrecognised lane's payload is a free object the view
// meets with the no-renderer path, never a validation failure (Law 7)" -
// hasRendererFor is that path.

export const EXPECTED_LANE_IDS = Object.freeze(['dispatches', 'gates', 'trains', 'freight', 'fuel']);

// Lane ids whose position (dark/bagged) means the wire carries NO "data"
// key at all by design (board/server/snapshot.go:41-45's "absence of the
// key itself is what signals no payload") - the view's renderer for these
// is the honest-absence chrome (Car 4's adjudication: distinguished from
// each other, never rendered identically).
const NO_DATA_BY_DESIGN = new Set(['freight', 'fuel']);

// For a live lane expecting data, the wire array key its payload must
// carry (spec YB-5's $defs: trainsPayload.trains, gatesPayload.gates,
// dispatchesPayload.dispatches).
const EXPECTED_DATA_KEY = { dispatches: 'dispatches', gates: 'gates', trains: 'trains' };

/**
 * design Rule 1's capability axis: does this view know how to render this
 * lane's CURRENT payload? An unrecognised lane id, or a known live lane
 * whose data key is missing or malformed, has NO renderer - which
 * composeRegister (compose.js) then resolves to needs-attention (the
 * load-bearing case: a live lane whose data source dies renders hot even
 * if freshness itself still reads fine).
 *
 * @param {{id: string, data?: unknown}} lane
 */
export function hasRendererFor(lane) {
  if (!lane || typeof lane.id !== 'string') return false;

  if (NO_DATA_BY_DESIGN.has(lane.id)) {
    // The honest-absence renderer never fails - "no equipment" / "data
    // held, not surfaced" is always renderable, regardless of freshness.
    return true;
  }

  const expectedKey = EXPECTED_DATA_KEY[lane.id];
  if (!expectedKey) {
    // An id outside the known five - Law 7's "free object" path.
    return false;
  }

  return Boolean(lane.data) && Array.isArray(lane.data[expectedKey]);
}
