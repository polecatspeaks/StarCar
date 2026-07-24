// render.js: the pure view-model builder (task 5.3). Takes a validated wire
// snapshot (+ any client-side board conditions) and produces a plain-object
// view model - no DOM, so this is exhaustively testable in Node, including
// directly against a REAL captured /api/snapshot payload (fixtures/
// real-snapshot.json, captured 2026-07-23 from a live `go run ./server`
// against this repo's own artifacts/ store - see this car's final report
// for the exact capture command).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { buildBoardViewModel, checkLaneCompleteness } from '../js/render.js';
import { EXPECTED_LANE_IDS } from '../js/lanes.js';

const thisDir = dirname(fileURLToPath(import.meta.url));
const realSnapshot = JSON.parse(readFileSync(join(thisDir, 'fixtures', 'real-snapshot.json'), 'utf8'));

test('REAL DATA: the captured live snapshot builds a view model with exactly the five expected lanes, in order', () => {
  const vm = buildBoardViewModel(realSnapshot);
  assert.deepEqual(
    vm.lanes.map((l) => l.id),
    EXPECTED_LANE_IDS
  );
});

test('REAL DATA: lane completeness reads 5 declared / 5 observed, no mismatch', () => {
  const completeness = checkLaneCompleteness(realSnapshot);
  assert.equal(completeness.declared, 5);
  assert.equal(completeness.observed, 5);
  assert.equal(completeness.mismatch, false);
});

test('REAL DATA: a stale live lane (captured mid-session, past stalenessMs) renders needs-attention', () => {
  const vm = buildBoardViewModel(realSnapshot);
  const dispatches = vm.lanes.find((l) => l.id === 'dispatches');
  assert.equal(dispatches.register, 'needs-attention');
  assert.ok(dispatches.secondary.startsWith('stale,'), `expected a stale secondary line, got: ${dispatches.secondary}`);
});

test('REAL DATA: the trains lane body carries the real train:board-v0 consist, roles resolved, states verbatim', () => {
  const vm = buildBoardViewModel(realSnapshot);
  const trains = vm.lanes.find((l) => l.id === 'trains');
  assert.equal(trains.body.kind, 'trains');
  assert.equal(trains.body.trains.length, 1);
  const train = trains.body.trains[0];
  assert.equal(train.id, 'train:board-v0');
  assert.ok(train.cars.length > 0);
  // every real car in this fixture returned - state must be the VERBATIM
  // fold word, never translated (mockup brief: "renders whatever state
  // word its data source provides, VERBATIM").
  for (const car of train.cars) {
    assert.equal(car.state, 'returned');
    assert.equal(car.stateRegister, 'nominal');
  }
});

test('REAL DATA: board conditions pass through VERBATIM from the wire - register is never recomputed by the view (Rule 4)', () => {
  const vm = buildBoardViewModel(realSnapshot);
  assert.ok(realSnapshot.board.length > 0, 'fixture sanity: the real capture must actually carry board conditions');
  for (const bc of realSnapshot.board) {
    assert.ok(
      vm.boardConditions.some((v) => v.code === bc.code && v.detail === bc.detail && v.register === bc.register),
      `expected the wire's board condition to appear verbatim in the view model: ${JSON.stringify(bc)}`
    );
  }
});

// --- synthetic edge cases (bagged/dark dignity, discovery, no-renderer) ---

const positionDefs = [
  { id: 'live', label: 'Live', register: 'nominal' },
  { id: 'dark', label: 'Dark', register: 'nominal' },
  { id: 'bagged', label: 'Bagged', register: 'nominal' }
];
const outcomeDefs = [
  { id: 'REJECT', label: 'Reject', register: 'nominal' },
  { id: 'done', label: 'Done', register: 'nominal' }
];
const roleDefs = [{ id: 'car', label: 'Car', register: 'nominal' }];
const livenessDefs = [
  { id: 'returned', label: 'Returned', register: 'nominal' },
  { id: 'overdue', label: 'Overdue', register: 'needs-attention' }
];

function makeSnapshot(lanes) {
  return {
    seq: 1,
    asOf: '2026-07-23T00:00:00Z',
    config: { pollMs: 1000, heartbeatMs: 5000, stalenessMs: 15000, storePathDisplay: '<repo>/artifacts', laneCount: lanes.length, demoMode: false },
    vocabularies: { positions: positionDefs, outcomes: outcomeDefs, roles: roleDefs, liveness: livenessDefs },
    board: [],
    lanes
  };
}

test('freight (dark) and fuel (bagged) render DISTINCT honesty text - Car 4 review adjudication, never identical', () => {
  const snapshot = makeSnapshot([
    { id: 'freight', title: 'Freight', position: 'dark', freshness: { kind: 'not-applicable' } },
    { id: 'fuel', title: 'Fuel', position: 'bagged', freshness: { kind: 'not-applicable' } }
  ]);
  const vm = buildBoardViewModel(snapshot);
  const freight = vm.lanes.find((l) => l.id === 'freight');
  const fuel = vm.lanes.find((l) => l.id === 'fuel');
  assert.equal(freight.body.kind, 'dark');
  assert.equal(fuel.body.kind, 'bagged');
  assert.notEqual(freight.body.text, fuel.body.text);
  assert.equal(freight.register, 'nominal');
  assert.equal(fuel.register, 'nominal');
});

test('an unrecognised (6th) lane id renders via the no-renderer path, needs-attention, never a crash', () => {
  const snapshot = makeSnapshot([{ id: 'ticket-queue-v2', title: 'Ticket queue', position: 'live', freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' }, data: { anything: 1 } }]);
  const vm = buildBoardViewModel(snapshot);
  const lane = vm.lanes[0];
  assert.equal(lane.register, 'needs-attention');
  assert.equal(lane.body.kind, 'no-renderer');
});

test('a lane count mismatch (declared vs observed) raises a client-detected board condition', () => {
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.config.laneCount = 5; // declared 5, but only 1 lane actually present
  const vm = buildBoardViewModel(snapshot);
  assert.equal(vm.laneCompleteness.mismatch, true);
  assert.ok(vm.boardConditions.some((c) => c.code === 'view-lane-count-mismatch'));
});

test('discovery rendering: an unrecognised dispatch state word renders HOT, BY NAME, VERBATIM', () => {
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: { dispatches: [{ subject: 'abc123', state: 'quarantined', at: '2026-07-23T00:00:00Z', assigned: false }] }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  const item = vm.lanes[0].body.dispatches[0];
  assert.equal(item.state, 'quarantined', 'the raw, unrecognised state word must render verbatim, never hidden or translated');
  assert.equal(item.stateRegister, 'needs-attention');
});

test('gates render outcomes VERBATIM (REJECT stays "REJECT", never translated to a friendlier word)', () => {
  const snapshot = makeSnapshot([
    {
      id: 'gates',
      title: 'Gates',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: { gates: [{ name: 'design round 1', subject: 'abc', outcome: 'REJECT', at: '2026-07-23T00:00:00Z' }] }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  const gate = vm.lanes[0].body.gates[0];
  assert.equal(gate.outcome, 'REJECT');
  assert.equal(gate.outcomeRegister, 'nominal', 'REJECT is a SUCCESS outcome in this shop - the gates lane must not run hot on normal traffic');
});

test('dispatches: yard inventory (unassigned) count is tallied, never hidden', () => {
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        dispatches: [
          { subject: 'a', state: 'returned', at: '2026-07-23T00:00:00Z', assigned: true },
          { subject: 'b', state: 'dispatched', at: '2026-07-23T00:00:00Z', assigned: false }
        ]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  assert.equal(vm.lanes[0].body.yardInventoryCount, 1);
});
