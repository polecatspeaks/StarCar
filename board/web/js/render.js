// render.js - the pure view-model builder (task 5.3). Turns a validated
// wire snapshot into plain-object view state; app.js's DOM writer (the only
// impure consumer) walks this shape. No DOM here on purpose: this keeps
// the composition-and-vocabulary logic testable in Node against real
// captured payloads (board/web/test/fixtures/real-snapshot.json).
import { composeRegister, composeLines, mostSevereRegister } from './compose.js';
import { hasRendererFor } from './lanes.js';
import { describeVocab } from './vocab.js';
import { computeHealthTrends } from './findings.js';
import { capTerminalHistory } from './history-filter.js';

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
 * @param {Array<{code:string, detail:string, register:string, recordDir?:string}>} boardConditions
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
    // #69/#71: recordDir carried through, never re-derived (Law 6) - the
    // wire's own store.BoardCondition.RecordDir when present, null when the
    // condition names no single subject/record (a config fault, an
    // aggregate count) or is a client-raised condition that never had one.
    group.instances.push({ detail: bc.detail, register: bc.register, recordDir: bc.recordDir ?? null });
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

// #67 (owner fast-follow after #62 live-board feedback): a train has no
// top-level liveness state of its own (schema/yard-snapshot.schema.json's
// $defs.trainsPayload - only each CAR carries `state`); terminality is
// derived, never wire-native. A train is TERMINAL (fully returned, history-
// eligible) iff every declared manifest member has a record
// (declaredNotObserved is empty - an undelivered member is the owner's
// "queued", never terminal) AND every one of its cars already carries BOTH
// the one liveness state AND the one outcome whose register is nominal
// (car.stateRegister / car.outcomeRegister, already computed above by
// describeVocab against the wire's OWN liveness/outcomes defs - this reads
// those registers, it never recomputes or hardcodes a state/outcome word).
//
// #67 FIX CYCLE ROUND 2 (view-67-car-r2 MAJOR-R1-1): the round-1 version of
// this function checked stateRegister ONLY. A train whose cars all
// RETURNED (stateRegister nominal) but whose OUTCOME is hot - 'error'
// (needs-attention per board-defs.json), an unrecognised word like
// 'BLOCKED' (needs-attention, vocab.js's Law-1 fallback), even
// 'done-with-findings' (in-progress) - was wrongly treated as terminal and
// could be capped out with ZERO residual signal (the lane's own register
// stays nominal per composeRegister, and the honesty summary only ever
// says "N of M returned"). dom-writer.js's renderTrains DOES render a
// separately register-colored outcome chip per car (`car-outcome
// ${registerClass(car.outcomeRegister)}`) - so outcome severity is real,
// rendered signal this predicate must not blind itself to. Fixed: BOTH
// axes must be nominal. REJECT still ages out correctly - board-defs.json
// pins REJECT to nominal register by doctrine (a REJECT is a SUCCESS
// outcome in this shop, same posture as the gates lane) - no special case
// needed. A car with NO outcome at all (outcomeRegister null - the schema
// makes TrainCar.Outcome optional) is conservatively NOT nominal either:
// schema/starcar-artifact.schema.json requires outcome/findings/abstract
// for every kind=returned record, so a genuinely-returned car with no
// outcome would itself be a discovery, and "when in doubt, show the row"
// applies the same way it does to an unrecognised word.
//
// Anything else (rolling, stalled for adjudication, an unrecognised car
// state or outcome) is conservatively non-terminal - always visible, per
// this ticket's "when in doubt, show the row" instruction.
//
// #67 FIX CYCLE ROUND 3 (view-67-car-r3 SAME-PASS isolation sweep): the
// `c.stateRegister === 'nominal'` conjunct is DEFENCE-IN-DEPTH, not dead
// code, even though no WIRE-REALISTIC fixture can fault-inject it in
// isolation from the outcome conjunct - assemble.go sets Outcome exactly
// when a dispatch's liveness state is 'returned', and
// schema/starcar-artifact.schema.json requires outcome for every
// kind=returned record, so on the real wire outcomeRegister nominal
// already implies stateRegister nominal (a car can never carry a nominal
// outcome while its state is anything else). A future round finding this
// conjunct's own isolated fault injection green must not read that as
// "this half of the predicate does nothing" - it is protecting against a
// wire shape the schema forbids today, and removing it would be removing
// the ONLY thing stopping a future schema relaxation (or a malformed feed)
// from silently reintroducing MAJOR-R1-1's exact defect for a car whose
// state was never actually 'returned'.
function isTrainTerminal(train) {
  if (train.declaredNotObserved.length > 0) return false;
  return (
    train.cars.length > 0 &&
    train.cars.every((c) => c.stateRegister === 'nominal' && c.outcomeRegister === 'nominal')
  );
}

// #67: a train carries no top-level `at` either - its own recency signal is
// the MOST RECENT `at` among its cars (the latest thing that happened on
// this train), so capTerminalHistory's default `item.at` accessor cannot be
// reused verbatim and this custom getAt is threaded in instead.
function trainRecencyAt(train) {
  return train.cars.reduce((latest, c) => {
    if (!latest) return c.at;
    return Date.parse(c.at) > Date.parse(latest) ? c.at : latest;
  }, null);
}

// #67 (HONESTY CONSTRAINT, Law 4 + absence-blindness): hidden history is
// ASSERTED, never silent - null (never rendered) when nothing is hidden, so
// an unfiltered lane carries no noise line at all (the same honest-absence
// posture this file already uses elsewhere, e.g. lanePurpose above).
//
// #67 FIX CYCLE ROUND 2 (view-67-car-r2 NOTE-1): a DISPATCH really is
// wire-verbatim "returned" (liveness is a real state word on the wire), but
// a TRAIN never carries that word at all - "returned" here would describe
// a derived, client-side judgment as if it were the data's own vocabulary,
// which also under-describes what a hot OUTCOME (this round's own fix)
// could be hiding. `noun` is optional (dispatches keep "returned", literally
// true there); trains use the owner's exact ticket wording with no noun.
function historySummaryLine(hiddenCount, terminalTotal, noun = '') {
  if (hiddenCount <= 0) return null;
  const shown = terminalTotal - hiddenCount;
  const nounPart = noun ? ` ${noun}` : '';
  return `showing last ${shown} of ${terminalTotal}${nounPart} - full record in the store`;
}

function buildLaneBody(lane, vocab, hasRenderer) {
  if (!hasRenderer) {
    return { kind: 'no-renderer' };
  }

  switch (lane.id) {
    case 'trains': {
      const trains = lane.data.trains.map((t) => ({
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
          recordDir: c.recordDir ?? null,
          // #75: the human task-id handle, null when this car has not yet
          // returned with one - dom-writer.js falls back to `subject`
          // honestly rather than inventing a label (Law 1). `||`, not `??`
          // (fix cycle r2, R1-m1): the wire schema has no minLength, so a
          // schema-valid "" is possible even though the shipped producer
          // never stamps one (Produce-Artifact.ps1's `-and $taskId` guard) -
          // treated as absent, same as links.js:17's truthiness guard for
          // the sibling recordDir field, never a blank identity label.
          taskId: c.taskId || null
        }))
      }));
      // #67 (SCOPE EXTENSION, owner 2026-07-26 17:09): non-terminal trains
      // (rolling/queued/stalled-for-adjudication/unrecognised, per
      // isTrainTerminal above) are ALWAYS visible; fully-returned trains are
      // history, capped by recency - selection only, register computation
      // above is untouched by this call.
      const { visible, hiddenCount, terminalTotal } = capTerminalHistory(trains, {
        isTerminal: isTrainTerminal,
        getAt: trainRecencyAt
      });
      return {
        kind: 'trains',
        trains: visible,
        // #67 FIX CYCLE ROUND 2 (NOTE-1): no noun - a train is never
        // literally "returned" on the wire (only its cars carry that word),
        // so this uses the owner's exact ticket wording rather than
        // borrowing the dispatches lane's noun.
        historySummary: historySummaryLine(hiddenCount, terminalTotal)
      };
    }
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
        recordDir: d.recordDir ?? null, // #28
        // #75: human handle, null falls back to `subject` (dom-writer.js).
        // `||`, not `??` (fix cycle r2, R1-m1): a schema-valid "" (no
        // minLength on the wire) is treated as absent, matching links.js:17's
        // truthiness guard for the sibling recordDir field - never a blank
        // identity label.
        taskId: d.taskId || null,
        superseded: d.superseded || [] // #71: same subject, same directory as recordDir above
      }));
      // #67 (owner finding after #62 live-board feedback): every non-
      // terminal / needs-attention dispatch (dispatched, overdue, presumed-
      // lost, any unrecognised state word) is ALWAYS visible; RETURNED
      // history is capped by recency. Terminality reads the row's own
      // ALREADY-COMPUTED stateRegister (nominal <=> 'returned' is the one
      // liveness state the wire's own vocab maps there) - this never
      // recomputes or hardcodes the liveness taxonomy, it only selects
      // which already-registered rows render. NOT applicable to a train's
      // hot-OUTCOME concern (#67 fix cycle round 2 MAJOR-R1-1): this
      // renderer (renderDispatches, dom-writer.js) never renders `outcome`
      // as its own register-colored element the way renderTrains does for
      // a car - the predicate here already matches everything this lane
      // actually displays as severity.
      //
      // Probed: no pre-dispatch ("queued") state exists anywhere on this
      // wire. board/fold's OWN liveness set (design S5.6) is closed to
      // exactly dispatched/overdue/returned/presumed-lost - grep of
      // board/server/*.go turned up no fifth state - so there is no
      // "queued" slot for this lane to render, none invented, per this
      // ticket's own instruction. CORRECTED (#67 fix cycle round 2
      // MINOR-R1-1): the WIRE schema itself does NOT enumerate this set -
      // schema/yard-snapshot.schema.json's $defs.dispatchesPayload declares
      // `state` as an open string (Law 7: an unrecognised value is a
      // discovery, never a validation failure), so the closed-set claim
      // belongs to board/fold alone, never to the schema.
      const { visible, hiddenCount, terminalTotal } = capTerminalHistory(dispatches, {
        isTerminal: (d) => d.stateRegister === 'nominal'
      });
      return {
        kind: 'dispatches',
        dispatches: visible,
        // Yard inventory (mockup: "visible, never hidden") - the count is
        // ALWAYS surfaced, even at zero, so its absence is never mistaken
        // for "nothing to disclose". Computed over the FULL set (never the
        // capped view) - this is a distinct honesty count from history
        // capping and must not shrink when returned history is capped.
        yardInventoryCount: dispatches.filter((d) => !d.assigned).length,
        // #67 FIX CYCLE ROUND 2 (NOTE-1): "returned" is kept here - a
        // dispatch really does carry that word verbatim on the wire, unlike
        // a train.
        historySummary: historySummaryLine(hiddenCount, terminalTotal, 'returned')
      };
    }
    case 'freight': {
      // #84: freight went live - the inbound ticket queue (GitHub Project 6
      // items in Backlog or Todo status). Empty-vs-never-run-vs-stale is NOT
      // this function's job to disambiguate: that distinction lives entirely
      // in freshness (composeLines' secondary line above - "not yet polled"
      // for never-polled, "fresh" for a genuinely-run-and-empty queue,
      // "stale, <duration>" for an aged sync) - the same Rule 2 split every
      // other live lane already follows (freshness carries the "when" story,
      // the body carries the "what"). This body only ever renders the
      // CURRENT tickets array, honestly, at whatever size it is.
      const tickets = lane.data.tickets.map((t) => ({
        number: t.number,
        title: t.title,
        status: t.status,
        url: t.url,
        recordDir: t.recordDir ?? null
      }));
      return { kind: 'freight', tickets };
    }
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
