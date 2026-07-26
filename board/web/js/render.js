// render.js - the pure view-model builder (task 5.3). Turns a validated
// wire snapshot into plain-object view state; app.js's DOM writer (the only
// impure consumer) walks this shape. No DOM here on purpose: this keeps
// the composition-and-vocabulary logic testable in Node against real
// captured payloads (board/web/test/fixtures/real-snapshot.json).
import { composeRegister, composeLines, mostSevereRegister } from './compose.js';
import { hasRendererFor } from './lanes.js';
import { describeVocab } from './vocab.js';
import { computeHealthTrends } from './findings.js';

// #62: lane-purpose subtitles (owner ruling: shared visual language, no
// single keeper - "lane plates with lane-purpose subtitles"). PRESENTATION
// ONLY, keyed by the same closed five-id registry lanes.js already pins
// (EXPECTED_LANE_IDS) - same posture as buildLaneBody's existing freight/
// fuel honesty text below, which is also client-side fixed prose keyed by
// lane id, not wire data (Car 4's precedent). Copy is lifted near-verbatim
// from docs/design/2026-07-23-ui-mockup-brief.md's own "Layout: five
// horizontal lanes" section so it is traceable to that source rather than
// invented. An id outside this set (the 6th-lane discovery path) gets no
// purpose line at all - never a guessed one.
//
// LANE ORDER NOTE (#62 fix cycle round 2, review round 1 MINOR-1): the
// keys above are listed in the ui-mockup-brief's illustrative order
// (trains, gates, dispatches, freight, fuel), but the actual rendered
// order follows lanes.js's EXPECTED_LANE_IDS (dispatches, gates, trains,
// freight, fuel) - the real, server-authoritative wire order
// (board/server/laneregistry.go), left untouched by this ticket (contract
// wins over illustrative direction, per the mock doctrine's own routing
// rule). This direction-vs-contract conflict is routed to issue #1, see
// https://github.com/polecatspeaks/StarCar/issues/1#issuecomment-5085235534
// (2026-07-26), item 1.
const LANE_PURPOSE = Object.freeze({
  trains: 'active work units - cars held in sequence',
  gates: 'review signals - verdict word rendered verbatim',
  dispatches: 'the raw worker feed',
  freight: 'the inbound ticket queue',
  fuel: 'the spend / usage gauge'
});

function lanePurpose(id) {
  return Object.prototype.hasOwnProperty.call(LANE_PURPOSE, id) ? LANE_PURPOSE[id] : null;
}

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
 * #30 (GROUP BY CLASS): one row per condition CODE, with a count and every
 * per-instance detail preserved (never discarded - "expandable to
 * per-instance details" per the owner-ruled design). Register stays
 * authoritative from the server per instance (Rule 4); the roll-up to one
 * register PER GROUP uses mostSevereRegister only as a defensive combinator
 * for the (never-expected-in-production) case of one code carrying mixed
 * registers - board/store/condition_severity.go is the ONE owned mapping
 * from code to tier, so in practice every instance of a given code already
 * shares one register.
 *
 * @param {Array<{code:string, detail:string, register:string}>} boardConditions
 */
export function groupBoardConditions(boardConditions) {
  const order = [];
  const byCode = new Map();
  for (const bc of boardConditions) {
    if (!byCode.has(bc.code)) {
      byCode.set(bc.code, { code: bc.code, register: bc.register, instances: [] });
      order.push(bc.code);
    }
    const group = byCode.get(bc.code);
    group.register = mostSevereRegister(group.register, bc.register);
    group.instances.push({ detail: bc.detail, register: bc.register });
  }
  return order.map((code) => {
    const group = byCode.get(code);
    return { code: group.code, register: group.register, count: group.instances.length, instances: group.instances };
  });
}

// #30 (HAVAGLANCE): the most-severe register across every group, so the
// COLLAPSED strip's own summary line can carry a color signal - "total
// transmission in a single look" (HAVAGLANCE) fails if a FLAG-tier
// condition is invisible until the reader expands the chrome. Defaults to
// 'nominal' (calm) when there are no groups at all - honest-empty, the same
// posture the rest of this repo gives a zero-of-zero state.
export function overallBoardConditionsRegister(groups) {
  return groups.reduce((worst, group) => mostSevereRegister(worst, group.register), 'nominal');
}

// #30 (SEVERITY PER CLASS -> PLACEMENT): the two-tier vocabulary this
// summary line speaks - NOTE-tier groups (register 'nominal' or
// 'in-progress', though in practice only 'nominal' is emitted server-side)
// count as "note(s)"; FLAG-tier groups (register 'needs-attention') count
// as "FLAG(S)". Counting INSTANCES (not distinct classes) - "1 FLAG + 2
// notes" reads as "how many things need attention", the HAVAGLANCE
// question a glance at chrome is meant to answer, not "how many kinds of
// thing".
export function summariseBoardConditionGroups(groups) {
  let flagCount = 0;
  let noteCount = 0;
  for (const group of groups) {
    if (group.register === 'needs-attention') {
      flagCount += group.count;
    } else {
      noteCount += group.count;
    }
  }
  const parts = [];
  if (flagCount > 0) parts.push(`${flagCount} FLAG${flagCount === 1 ? '' : 'S'}`);
  if (noteCount > 0) parts.push(`${noteCount} note${noteCount === 1 ? '' : 's'}`);
  return parts.length > 0 ? parts.join(' + ') : 'no conditions';
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
  const boardConditionGroups = groupBoardConditions(boardConditions);
  const boardConditionSummary = summariseBoardConditionGroups(boardConditionGroups);
  const boardConditionsRegister = overallBoardConditionsRegister(boardConditionGroups);

  const lanes = snapshot.lanes.map((lane) => {
    const hasRenderer = hasRendererFor(lane);
    const register = composeRegister({ position: lane.position, positionDefs: vocab.positions, freshness: lane.freshness, hasRenderer });
    const lines = composeLines({ position: lane.position, positionDefs: vocab.positions, freshness: lane.freshness, hasRenderer });
    return {
      id: lane.id,
      title: lane.title,
      purpose: lanePurpose(lane.id),
      register,
      primary: lines.primary,
      secondary: lines.secondary,
      body: buildLaneBody(lane, vocab, hasRenderer)
    };
  });

  return {
    asOf: snapshot.asOf,
    demoMode: Boolean(snapshot.config.demoMode),
    // #62: real wire field (schema/yard-snapshot.schema.json's
    // config.storePathDisplay), already normalised server-side to be
    // publication-safe (never a raw absolute path - board/server/storepath.go)
    // and already validated by the schema on ingest - rendered for the first
    // time in the footer's honesty chrome below. No new data, no wire change.
    storePathDisplay: snapshot.config.storePathDisplay,
    // #28: the three primitives the view needs to build every provenance
    // link itself (board/web/js/links.js) - "" (never undefined) when
    // unconfigured, matching storePathDisplay's own always-a-string
    // contract above (a non-GitHub yard degrades to no links, never a
    // broken one).
    githubRepoUrl: snapshot.config.githubRepoUrl || '',
    githubRef: snapshot.config.githubRef || '',
    githubArtifactsPrefix: snapshot.config.githubArtifactsPrefix || '',
    laneCompleteness: completeness,
    boardConditions,
    boardConditionGroups,
    boardConditionSummary,
    boardConditionsRegister,
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
          // #28: the manifest's own declared ticket refs, structured, never
          // re-parsed from title prose (assemble.Train.Tickets).
          tickets: t.tickets || [],
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
            superseded: c.superseded || [],
            // #28: single-sourced from store.Record.Path server-side
            // (assemble.recordDirBySubject) - never re-derived from
            // `subject` here (Law 6).
            recordDir: c.recordDir ?? null
          }))
        }))
      };
    case 'gates': {
      // #12: ONE pass over this fold's gates computes every family's
      // convergence trend, keyed by array index - computeHealthTrends is
      // PURE and re-run every render (cheap: this lane's gate count, never
      // cached/persisted - Law 6, no second copy of the wire's own
      // findings text).
      const healthTrends = computeHealthTrends(lane.data.gates);
      return {
        kind: 'gates',
        gates: lane.data.gates.map((g, index) => ({
          name: g.name,
          subject: g.subject,
          outcome: g.outcome, // VERBATIM - "REJECT" stays "REJECT" (spec YB-5: rendered VERBATIM, never re-derived)
          outcomeRegister: describeVocab(g.outcome, vocab.outcomes).register,
          at: g.at,
          recordDir: g.recordDir ?? null, // #28
          healthTrend: healthTrends.get(index) ?? null // #12: present ONLY on a family's latest round
        }))
      };
    }
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
        assigned: Boolean(d.assigned),
        recordDir: d.recordDir ?? null // #28
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
