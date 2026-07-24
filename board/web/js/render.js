// render.js - the pure view-model builder (task 5.3). Turns a validated
// wire snapshot into plain-object view state; app.js's DOM writer (the only
// impure consumer) walks this shape. No DOM here on purpose: this keeps
// the composition-and-vocabulary logic testable in Node against real
// captured payloads (board/web/test/fixtures/real-snapshot.json).
import { composeRegister, composeLines } from './compose.js';
import { hasRendererFor } from './lanes.js';
import { describeVocab } from './vocab.js';

/**
 * Completeness guard (design rev 5 S5.2), restated at the view: the
 * mockup's "a lane count ... so a silently missing lane is detectable" is
 * only true if the view actually COMPARES the declared count
 * (config.laneCount) against what it observed, rather than only echoing
 * one of the two numbers.
 */
export function checkLaneCompleteness(snapshot) {
  const declared = snapshot.config.laneCount;
  const observed = snapshot.lanes.length;
  return { declared, observed, mismatch: declared !== observed };
}

/**
 * @param {object} snapshot - a snapshot already validated against
 *   schema/yard-snapshot.schema.json (task 5.2's ingest.js gate).
 * @param {Array<{code:string, detail:string, register:string}>} clientConditions
 *   - board conditions raised BY THE VIEW itself (e.g. a discarded
 *   payload, a disconnect) - merged alongside the server's own `board`
 *   array, never replacing it.
 */
export function buildBoardViewModel(snapshot, clientConditions = []) {
  const vocab = snapshot.vocabularies;
  const completeness = checkLaneCompleteness(snapshot);

  // Rule 4 (design S5.2): a board condition's register is authoritative
  // from the server - the view NEVER recomputes it, only renders it.
  const boardConditions = [...snapshot.board, ...clientConditions];
  if (completeness.mismatch) {
    boardConditions.push({
      code: 'view-lane-count-mismatch',
      detail: `chrome declares ${completeness.declared} lane(s) but the snapshot carried ${completeness.observed}`,
      register: 'needs-attention'
    });
  }

  const lanes = snapshot.lanes.map((lane) => {
    const hasRenderer = hasRendererFor(lane);
    const register = composeRegister({ position: lane.position, positionDefs: vocab.positions, freshness: lane.freshness, hasRenderer });
    const lines = composeLines({ position: lane.position, positionDefs: vocab.positions, freshness: lane.freshness, hasRenderer });
    return {
      id: lane.id,
      title: lane.title,
      register,
      primary: lines.primary,
      secondary: lines.secondary,
      body: buildLaneBody(lane, vocab, hasRenderer)
    };
  });

  return {
    asOf: snapshot.asOf,
    demoMode: Boolean(snapshot.config.demoMode),
    laneCompleteness: completeness,
    boardConditions,
    lanes
  };
}

function buildLaneBody(lane, vocab, hasRenderer) {
  if (!hasRenderer) {
    return { kind: 'no-renderer' };
  }

  switch (lane.id) {
    case 'trains':
      return {
        kind: 'trains',
        trains: lane.data.trains.map((t) => ({
          id: t.id,
          title: t.title,
          declaredNotObserved: t.declaredNotObserved || [],
          cars: t.cars.map((c) => ({
            subject: c.subject,
            role: describeVocab(c.role, vocab.roles), // presentational label OK - a structural descriptor, not a data value
            gate: c.gate ?? null,
            // VERBATIM, never translated (mockup brief: "the real board
            // renders whatever state word its data source provides,
            // VERBATIM, never a translation of it") - describeVocab is
            // used ONLY for the register (color), never the displayed text.
            state: c.state,
            stateRegister: describeVocab(c.state, vocab.liveness).register,
            outcome: c.outcome ?? null,
            outcomeRegister: c.outcome ? describeVocab(c.outcome, vocab.outcomes).register : null,
            at: c.at,
            superseded: c.superseded || []
          }))
        }))
      };
    case 'gates':
      return {
        kind: 'gates',
        gates: lane.data.gates.map((g) => ({
          name: g.name,
          subject: g.subject,
          outcome: g.outcome, // VERBATIM - "REJECT" stays "REJECT" (spec YB-5: rendered VERBATIM, never re-derived)
          outcomeRegister: describeVocab(g.outcome, vocab.outcomes).register,
          at: g.at
        }))
      };
    case 'dispatches': {
      const dispatches = lane.data.dispatches.map((d) => ({
        subject: d.subject,
        state: d.state, // VERBATIM
        stateRegister: describeVocab(d.state, vocab.liveness).register,
        at: d.at,
        outcome: d.outcome ?? null,
        elapsedSeconds: typeof d.elapsed_seconds === 'number' ? d.elapsed_seconds : null,
        budgetSeconds: typeof d.budget_seconds === 'number' ? d.budget_seconds : null,
        budgetSource: d.budget_source ?? null,
        assigned: Boolean(d.assigned)
      }));
      return {
        kind: 'dispatches',
        dispatches,
        // Yard inventory (mockup: "visible, never hidden") - the count is
        // ALWAYS surfaced, even at zero, so its absence is never mistaken
        // for "nothing to disclose".
        yardInventoryCount: dispatches.filter((d) => !d.assigned).length
      };
    }
    case 'freight':
      // Dark: no adapter exists (Car 4's adjudication: "no-equipment",
      // distinguished from fuel's "bagged" below).
      return { kind: 'dark', text: 'no equipment on this lane' };
    case 'fuel':
      // Bagged: data exists (cost fields on some records) but is
      // deliberately not surfaced yet (#11) - the hooded-signal treatment,
      // distinct text from freight's dark absence.
      return { kind: 'bagged', text: 'data held, not surfaced' };
    default:
      // hasRendererFor already gates this branch to only the five known
      // ids when it returns true, so this default is defensive dead code
      // for a future lane id added to EXPECTED_LANE_IDS without a body
      // case here yet - never silently blank.
      return { kind: 'unknown-lane', raw: lane.data ?? null };
  }
}
