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
  { id: 'dispatched', label: 'Dispatched', register: 'in-progress' },
  { id: 'overdue', label: 'Overdue', register: 'needs-attention' },
  { id: 'presumed-lost', label: 'Presumed lost', register: 'needs-attention' }
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

// --- #30: board conditions GROUPED BY CLASS, chrome placement ---

test('#30 groupBoardConditions: one group per CODE, with a count and every instance preserved', () => {
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.board = [
    { code: 'discovery', detail: 'outcome: completed', register: 'nominal' },
    { code: 'discovery', detail: 'outcome: approve-for-merge', register: 'nominal' },
    { code: 'record-unrecognised-fields', detail: 'x.json: 1 unrecognised field', register: 'needs-attention' }
  ];
  const vm = buildBoardViewModel(snapshot);

  assert.equal(vm.boardConditionGroups.length, 2, 'two distinct codes -> two groups');
  const discovery = vm.boardConditionGroups.find((g) => g.code === 'discovery');
  assert.ok(discovery, 'a discovery group must exist');
  assert.equal(discovery.count, 2);
  assert.equal(discovery.register, 'nominal');
  assert.deepEqual(
    discovery.instances.map((i) => i.detail).sort(),
    ['outcome: approve-for-merge', 'outcome: completed']
  );

  const unrecognised = vm.boardConditionGroups.find((g) => g.code === 'record-unrecognised-fields');
  assert.ok(unrecognised);
  assert.equal(unrecognised.count, 1);
  assert.equal(unrecognised.register, 'needs-attention');
});

test('#30 groupBoardConditions: register is authoritative from the server per instance - the view never recomputes it, only rolls it up (most-severe-wins if a class ever carries mixed registers)', () => {
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  // Defensive case: the same code observed at two different registers (never
  // expected in production - conditionSeverity, board/store/condition_severity.go,
  // is ONE owned mapping per code - but the view must not crash or silently
  // pick the calmer one if it ever happens).
  snapshot.board = [
    { code: 'weird', detail: 'a', register: 'nominal' },
    { code: 'weird', detail: 'b', register: 'needs-attention' }
  ];
  const vm = buildBoardViewModel(snapshot);
  const group = vm.boardConditionGroups.find((g) => g.code === 'weird');
  assert.equal(group.register, 'needs-attention', 'most-severe-wins at the group roll-up level');
});

test('#30 PLACEMENT: boardConditionSummary is a single chrome line, "N FLAG(S) + M note(s)" shaped, never the full detail list', () => {
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.board = [
    { code: 'record-unrecognised-fields', detail: 'x', register: 'needs-attention' },
    { code: 'discovery', detail: 'outcome: completed', register: 'nominal' },
    { code: 'discovery', detail: 'outcome: approve-for-merge', register: 'nominal' }
  ];
  const vm = buildBoardViewModel(snapshot);
  assert.equal(vm.boardConditionSummary, '1 FLAG + 2 notes');
  assert.ok(!vm.boardConditionSummary.includes('outcome:'), 'the summary line is chrome, not the detail text');
});

test('#30 boardConditionSummary with zero conditions', () => {
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  const vm = buildBoardViewModel(snapshot);
  assert.equal(vm.boardConditionGroups.length, 0);
  assert.equal(vm.boardConditionSummary, 'no conditions');
});

test('#30 HAVAGLANCE: boardConditionsRegister is the most-severe register across all groups, so the COLLAPSED summary line itself signals severity without expanding', () => {
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.board = [{ code: 'discovery', detail: 'outcome: completed', register: 'nominal' }];
  assert.equal(buildBoardViewModel(snapshot).boardConditionsRegister, 'nominal', 'only NOTE-tier present -> calm');

  snapshot.board = [
    { code: 'discovery', detail: 'outcome: completed', register: 'nominal' },
    { code: 'record-unrecognised-fields', detail: 'x', register: 'needs-attention' }
  ];
  assert.equal(buildBoardViewModel(snapshot).boardConditionsRegister, 'needs-attention', 'any FLAG present -> hot, even collapsed');

  snapshot.board = [];
  assert.equal(buildBoardViewModel(snapshot).boardConditionsRegister, 'nominal', 'no conditions at all -> calm');
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

// --- #62: lane-purpose subtitles + storePathDisplay in the view model ---

test('#62: every one of the five known lane ids carries a lane-purpose subtitle in the view model', () => {
  const snapshot = makeSnapshot(
    ['trains', 'gates', 'dispatches', 'freight', 'fuel'].map((id) => ({
      id,
      title: id,
      position: 'dark',
      freshness: { kind: 'not-applicable' }
    }))
  );
  const vm = buildBoardViewModel(snapshot);
  for (const lane of vm.lanes) {
    assert.equal(typeof lane.purpose, 'string', `expected lane '${lane.id}' to carry a string purpose subtitle`);
    assert.ok(lane.purpose.length > 0, `expected lane '${lane.id}' purpose to be non-empty`);
  }
});

test('#62: an unrecognised (6th) lane id carries NO purpose subtitle - never a guessed one', () => {
  const snapshot = makeSnapshot([{ id: 'ticket-queue-v2', title: 'Ticket queue', position: 'live', freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' }, data: { anything: 1 } }]);
  const vm = buildBoardViewModel(snapshot);
  assert.equal(vm.lanes[0].purpose, null);
});

test('#62: the view model carries config.storePathDisplay verbatim (real wire field, already publication-safe) for the footer honesty chrome', () => {
  const snapshot = makeSnapshot([]);
  snapshot.config.storePathDisplay = '<repo>/artifacts';
  const vm = buildBoardViewModel(snapshot);
  assert.equal(vm.storePathDisplay, '<repo>/artifacts');
});

// --- #28: clickable provenance / #12: car health bar in the view model ---

test('#28: the view model carries config.githubRepoUrl/githubRef/githubArtifactsPrefix verbatim', () => {
  const snapshot = makeSnapshot([]);
  snapshot.config.githubRepoUrl = 'https://github.com/polecatspeaks/StarCar';
  snapshot.config.githubRef = 'dev';
  snapshot.config.githubArtifactsPrefix = 'artifacts';
  const vm = buildBoardViewModel(snapshot);
  assert.equal(vm.githubRepoUrl, 'https://github.com/polecatspeaks/StarCar');
  assert.equal(vm.githubRef, 'dev');
  assert.equal(vm.githubArtifactsPrefix, 'artifacts');
});

test('#28: an unconfigured yard carries empty github config fields, never a guessed identity', () => {
  const snapshot = makeSnapshot([]);
  const vm = buildBoardViewModel(snapshot);
  assert.equal(vm.githubRepoUrl, '');
  assert.equal(vm.githubRef, '');
  assert.equal(vm.githubArtifactsPrefix, '');
});

test('#28: trains carry the manifest\'s tickets array, and each car carries its recordDir', () => {
  const snapshot = makeSnapshot([
    {
      id: 'trains',
      title: 'Trains',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        trains: [
          {
            id: 'train:view-28-12',
            title: 'Provenance + health bar',
            tickets: ['#28', '#12'],
            cars: [{ subject: 'carA', role: 'car', state: 'returned', at: '2026-07-23T00:00:00Z', recordDir: 'carA' }],
            declaredNotObserved: []
          }
        ]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  const train = vm.lanes[0].body.trains[0];
  assert.deepEqual(train.tickets, ['#28', '#12']);
  assert.equal(train.cars[0].recordDir, 'carA');
});

test('#28: a train with no declared tickets carries an empty array, never undefined', () => {
  const snapshot = makeSnapshot([
    {
      id: 'trains',
      title: 'Trains',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: { trains: [{ id: 'train:x', title: 'X', cars: [], declaredNotObserved: [] }] }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  assert.deepEqual(vm.lanes[0].body.trains[0].tickets, []);
});

test('#28: gates carry recordDir', () => {
  const snapshot = makeSnapshot([
    {
      id: 'gates',
      title: 'Gates',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: { gates: [{ name: 'g', subject: 'gate-1', outcome: 'REJECT', at: '2026-07-23T00:00:00Z', recordDir: 'gate-1' }] }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  assert.equal(vm.lanes[0].body.gates[0].recordDir, 'gate-1');
});

test('#12: gates carry a healthTrend ONLY on the family\'s latest round, computed from findings', () => {
  const snapshot = makeSnapshot([
    {
      id: 'gates',
      title: 'Gates',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        gates: [
          { name: 'r1', subject: 'x-review-r1', outcome: 'REJECT', at: '2026-07-23T00:00:00Z', findings: '3 Major, 0 Minor' },
          { name: 'r2', subject: 'x-review-r2', outcome: 'APPROVE', at: '2026-07-23T01:00:00Z', findings: '0 Major, 0 Minor' }
        ]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  const gates = vm.lanes[0].body.gates;
  assert.equal(gates[0].healthTrend, null, 'round 1 (not the latest) carries no trend badge');
  assert.deepEqual(gates[1].healthTrend, { trend: 'converged', majorsSeries: [3, 0] });
});

test('#12: a gate with no/unparseable findings text renders trend "unknown", never a guessed count', () => {
  const snapshot = makeSnapshot([
    {
      id: 'gates',
      title: 'Gates',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        gates: [{ name: 'r1', subject: 'solo-review-r1', outcome: 'REJECT', at: '2026-07-23T00:00:00Z' }]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  assert.deepEqual(vm.lanes[0].body.gates[0].healthTrend, { trend: 'unknown', majorsSeries: null });
});

test('dispatches: dispatches carry recordDir', () => {
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: { dispatches: [{ subject: 'orphan-1', state: 'dispatched', at: '2026-07-23T00:00:00Z', assigned: false, recordDir: 'orphan-1' }] }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  assert.equal(vm.lanes[0].body.dispatches[0].recordDir, 'orphan-1');
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

// --- #67: dispatches lane filter (owner fast-follow after #62 feedback) ---

function dispatchFixture(subject, state, at, assigned = true) {
  return { subject, state, at, assigned };
}

test('#67: a returned dispatch beyond the cap is hidden from the rendered list, but never from the honesty summary', () => {
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        dispatches: [
          dispatchFixture('r1', 'returned', '2026-07-01T00:00:00Z'),
          dispatchFixture('r2', 'returned', '2026-07-02T00:00:00Z'),
          dispatchFixture('r3', 'returned', '2026-07-03T00:00:00Z'),
          dispatchFixture('r4', 'returned', '2026-07-04T00:00:00Z'),
          dispatchFixture('r5', 'returned', '2026-07-05T00:00:00Z')
        ]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  const body = vm.lanes[0].body;
  assert.equal(body.dispatches.length, 4, 'only the 4 most recent returned dispatches render');
  assert.ok(!body.dispatches.some((d) => d.subject === 'r1'), 'the oldest returned dispatch is the one capped out');
  assert.equal(body.historySummary, 'showing last 4 of 5 returned - full record in the store');
});

test('#67 NEVER FILTER A HOT ROW: a needs-attention dispatch older than every returned dispatch still renders', () => {
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        dispatches: [
          dispatchFixture('ancient-hot', 'presumed-lost', '2020-01-01T00:00:00Z'),
          dispatchFixture('r1', 'returned', '2026-07-01T00:00:00Z'),
          dispatchFixture('r2', 'returned', '2026-07-02T00:00:00Z'),
          dispatchFixture('r3', 'returned', '2026-07-03T00:00:00Z'),
          dispatchFixture('r4', 'returned', '2026-07-04T00:00:00Z'),
          dispatchFixture('r5', 'returned', '2026-07-05T00:00:00Z')
        ]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  const subjects = vm.lanes[0].body.dispatches.map((d) => d.subject);
  assert.ok(subjects.includes('ancient-hot'), 'a needs-attention row must render regardless of how old it is');
});

test('#67: an unrecognised dispatch state is never capped, even sitting far below every returned dispatch by recency', () => {
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        dispatches: [
          dispatchFixture('discovery', 'quarantined', '2020-01-01T00:00:00Z'),
          dispatchFixture('r1', 'returned', '2026-07-01T00:00:00Z'),
          dispatchFixture('r2', 'returned', '2026-07-02T00:00:00Z'),
          dispatchFixture('r3', 'returned', '2026-07-03T00:00:00Z'),
          dispatchFixture('r4', 'returned', '2026-07-04T00:00:00Z'),
          dispatchFixture('r5', 'returned', '2026-07-05T00:00:00Z')
        ]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  const subjects = vm.lanes[0].body.dispatches.map((d) => d.subject);
  assert.ok(subjects.includes('discovery'), 'an unrecognised state word must never be filtered - unknowns are hot by law');
});

test('#67: with hidden history under the cap, historySummary is null - never a "showing 0 of 0" noise line', () => {
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        dispatches: [
          dispatchFixture('r1', 'returned', '2026-07-01T00:00:00Z'),
          dispatchFixture('d1', 'dispatched', '2026-07-02T00:00:00Z')
        ]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  assert.equal(vm.lanes[0].body.historySummary, null);
});

test('#67: dispatches lane REGISTER SEMANTICS are unchanged - the lane still composes from position x freshness x capability only, never from row filtering', () => {
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        dispatches: [
          dispatchFixture('r1', 'returned', '2026-07-01T00:00:00Z'),
          dispatchFixture('r2', 'returned', '2026-07-02T00:00:00Z'),
          dispatchFixture('r3', 'returned', '2026-07-03T00:00:00Z'),
          dispatchFixture('r4', 'returned', '2026-07-04T00:00:00Z'),
          dispatchFixture('r5', 'returned', '2026-07-05T00:00:00Z')
        ]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  // position 'live' is nominal, freshness 'fresh' is nominal, a renderer
  // exists - the lane register must read nominal even though 5 rows exist
  // upstream and only 4 render, because capping never touches this axis.
  assert.equal(vm.lanes[0].register, 'nominal');
});

// --- #67: trains lane filter (owner scope extension, same commit) ---

function trainFixture(id, cars, declaredNotObserved = []) {
  return { id, title: id, cars, declaredNotObserved };
}

function carFixture(subject, state, at) {
  return { subject, role: 'car', state, at };
}

test('#67: a fully-returned train beyond the cap is hidden from the rendered list, honesty summary states true counts', () => {
  const snapshot = makeSnapshot([
    {
      id: 'trains',
      title: 'Trains',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        trains: [
          trainFixture('train:t1', [carFixture('c1', 'returned', '2026-07-01T00:00:00Z')]),
          trainFixture('train:t2', [carFixture('c2', 'returned', '2026-07-02T00:00:00Z')]),
          trainFixture('train:t3', [carFixture('c3', 'returned', '2026-07-03T00:00:00Z')]),
          trainFixture('train:t4', [carFixture('c4', 'returned', '2026-07-04T00:00:00Z')]),
          trainFixture('train:t5', [carFixture('c5', 'returned', '2026-07-05T00:00:00Z')])
        ]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  const body = vm.lanes[0].body;
  assert.equal(body.trains.length, 4, 'only the 4 most recent fully-returned trains render');
  assert.ok(!body.trains.some((t) => t.id === 'train:t1'), 'the oldest fully-returned train is the one capped out');
  assert.equal(body.historySummary, 'showing last 4 of 5 returned - full record in the store');
});

test('#67 NEVER FILTER A HOT ROW: a train with an in-flight (non-returned) car always renders, regardless of recency', () => {
  const snapshot = makeSnapshot([
    {
      id: 'trains',
      title: 'Trains',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        trains: [
          trainFixture('train:rolling-ancient', [carFixture('rolling-car', 'dispatched', '2020-01-01T00:00:00Z')]),
          trainFixture('train:t1', [carFixture('c1', 'returned', '2026-07-01T00:00:00Z')]),
          trainFixture('train:t2', [carFixture('c2', 'returned', '2026-07-02T00:00:00Z')]),
          trainFixture('train:t3', [carFixture('c3', 'returned', '2026-07-03T00:00:00Z')]),
          trainFixture('train:t4', [carFixture('c4', 'returned', '2026-07-04T00:00:00Z')]),
          trainFixture('train:t5', [carFixture('c5', 'returned', '2026-07-05T00:00:00Z')])
        ]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  const ids = vm.lanes[0].body.trains.map((t) => t.id);
  assert.ok(ids.includes('train:rolling-ancient'), 'a train with an in-flight car must render regardless of recency');
});

test('#67: a train with an undelivered manifest member ("queued") always renders - declaredNotObserved is never terminal', () => {
  const snapshot = makeSnapshot([
    {
      id: 'trains',
      title: 'Trains',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        trains: [
          trainFixture('train:queued-ancient', [carFixture('member', 'returned', '2020-01-01T00:00:00Z')], ['not-yet-dispatched-member']),
          trainFixture('train:t1', [carFixture('c1', 'returned', '2026-07-01T00:00:00Z')]),
          trainFixture('train:t2', [carFixture('c2', 'returned', '2026-07-02T00:00:00Z')]),
          trainFixture('train:t3', [carFixture('c3', 'returned', '2026-07-03T00:00:00Z')]),
          trainFixture('train:t4', [carFixture('c4', 'returned', '2026-07-04T00:00:00Z')]),
          trainFixture('train:t5', [carFixture('c5', 'returned', '2026-07-05T00:00:00Z')])
        ]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  const ids = vm.lanes[0].body.trains.map((t) => t.id);
  assert.ok(ids.includes('train:queued-ancient'), 'a train with an undelivered manifest member must render regardless of recency');
});

test('#67: trains lane REGISTER SEMANTICS are unchanged - capping never touches composeRegister\'s three-axis composition', () => {
  const snapshot = makeSnapshot([
    {
      id: 'trains',
      title: 'Trains',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
      data: {
        trains: [
          trainFixture('train:t1', [carFixture('c1', 'returned', '2026-07-01T00:00:00Z')]),
          trainFixture('train:t2', [carFixture('c2', 'returned', '2026-07-02T00:00:00Z')]),
          trainFixture('train:t3', [carFixture('c3', 'returned', '2026-07-03T00:00:00Z')]),
          trainFixture('train:t4', [carFixture('c4', 'returned', '2026-07-04T00:00:00Z')]),
          trainFixture('train:t5', [carFixture('c5', 'returned', '2026-07-05T00:00:00Z')])
        ]
      }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  assert.equal(vm.lanes[0].register, 'nominal');
});
