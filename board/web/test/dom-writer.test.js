// Task 5.5's DOM-level smoke: dom-writer.js is pure ESM (no `document`
// reference outside its function arguments), so it runs unmodified against
// a hand-rolled minimal shim (minidom.js) here in Node - no jsdom, no npm
// install, no network. This is DIFFERENT from render.test.js (which checks
// the pure VIEW MODEL's shape): this suite checks that the DOM WRITER
// actually turns that view model into element structure with the right
// register classes and verbatim text.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createMiniDocument } from './minidom.js';
import { renderBoard } from '../js/dom-writer.js';
import { buildBoardViewModel } from '../js/render.js';

const positionDefs = [
  { id: 'live', label: 'Live', register: 'nominal' },
  { id: 'dark', label: 'Dark', register: 'nominal' },
  { id: 'bagged', label: 'Bagged', register: 'nominal' }
];
const outcomeDefs = [{ id: 'REJECT', label: 'Reject', register: 'nominal' }];
const roleDefs = [{ id: 'car', label: 'Car', register: 'nominal' }];
const livenessDefs = [
  { id: 'returned', label: 'Returned', register: 'nominal' },
  { id: 'overdue', label: 'Overdue', register: 'needs-attention' }
];

function makeSnapshot(lanes, extra = {}) {
  return {
    seq: 1,
    asOf: '2026-07-23T18:00:00Z',
    config: { pollMs: 1000, heartbeatMs: 5000, stalenessMs: 15000, storePathDisplay: '<repo>/artifacts', laneCount: lanes.length, demoMode: false, ...extra },
    vocabularies: { positions: positionDefs, outcomes: outcomeDefs, roles: roleDefs, liveness: livenessDefs },
    board: [],
    lanes
  };
}

test('renderBoard draws one section per lane, with a register class and a verbatim state word', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: { dispatches: [{ subject: 'abc123', state: 'quarantined', at: '2026-07-23T18:00:00Z', assigned: false }] }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  renderBoard(doc, root, vm, { connected: true });

  const laneSections = root.querySelectorAll('.lane');
  assert.equal(laneSections.length, 1);

  const hot = root.querySelectorAll('.register-needs-attention');
  assert.ok(hot.length > 0, 'an unrecognised state word must produce a needs-attention-classed element');

  // The raw, unrecognised state word renders VERBATIM somewhere in the tree
  // - never translated, never hidden.
  assert.ok(root.textContent.includes('quarantined'), `expected "quarantined" verbatim in rendered output: ${root.textContent}`);
});

test('renderBoard shows the DEMO banner only when config.demoMode is true (spec YB-15)', () => {
  const doc = createMiniDocument();
  const demoSnapshot = makeSnapshot([], { demoMode: true });
  const rootDemo = doc.createElement('main');
  renderBoard(doc, rootDemo, buildBoardViewModel(demoSnapshot), { connected: true });
  assert.ok(rootDemo.querySelectorAll('.demo-banner').length === 1, 'DEMO banner must render when demoMode is true');

  const liveSnapshot = makeSnapshot([], { demoMode: false });
  const rootLive = doc.createElement('main');
  renderBoard(doc, rootLive, buildBoardViewModel(liveSnapshot), { connected: true });
  assert.equal(rootLive.querySelectorAll('.demo-banner').length, 0, 'DEMO banner must NOT render when demoMode is false');
});

test('renderBoard marks a disconnected connection state while keeping the last-known picture on screen', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'freight', title: 'Freight', position: 'dark', freshness: { kind: 'not-applicable' } }]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: false });

  assert.equal(root.querySelectorAll('.connection-disconnected').length, 1);
  // The lane itself must STILL be present and rendered - disconnected chrome
  // never blanks the last-known picture.
  assert.equal(root.querySelectorAll('.lane').length, 1);
});

// --- #30: board conditions as COLLAPSED, GROUPED chrome ---

test('#30 PLACEMENT: the board-conditions strip renders as a <details> (collapsed by default - no "open" attribute) with a <summary> carrying the roll-up line, never the full detail list at top level', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.board = [
    { code: 'record-unrecognised-fields', detail: 'x.json: 1 unrecognised field', register: 'needs-attention' },
    { code: 'discovery', detail: 'outcome: completed', register: 'nominal' },
    { code: 'discovery', detail: 'outcome: approve-for-merge', register: 'nominal' }
  ];
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const strips = root.querySelectorAll('.board-conditions-strip');
  assert.equal(strips.length, 1, 'exactly one conditions strip');
  const strip = strips[0];
  assert.equal(strip.tagName, 'details', 'the strip is a native <details> element - expand/collapse needs no JS');
  assert.equal(strip.attributes.open, undefined, 'COLLAPSED by default - the summary line is chrome, the lanes stay above the fold');

  const summaries = root.querySelectorAll('.board-conditions-summary');
  assert.equal(summaries.length, 1);
  assert.equal(summaries[0].textContent, '1 FLAG + 2 notes');

  // The full per-instance detail text must NOT appear at the top level of
  // textContent in a way indistinguishable from the summary - it lives
  // inside the (collapsed) group structure, verified by the grouping test
  // below. This assertion only pins that the outer summary line itself is
  // exactly the roll-up, not detail-laden.
  assert.ok(!summaries[0].textContent.includes('outcome:'));
});

test('#30 GROUP BY CLASS: one row per code with a count, each expandable (its own <details>) to per-instance detail text, VERBATIM', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.board = [
    { code: 'discovery', detail: 'outcome: completed', register: 'nominal' },
    { code: 'discovery', detail: 'outcome: approve-for-merge', register: 'nominal' }
  ];
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const groups = root.querySelectorAll('.board-condition-group');
  assert.equal(groups.length, 1, 'one group for the one distinct code');
  assert.ok(groups[0].className.includes('register-nominal'), 'a NOTE-tier group renders the calm register class');

  const groupSummaries = root.querySelectorAll('.board-condition-group-summary');
  assert.equal(groupSummaries.length, 1);
  assert.equal(groupSummaries[0].textContent, 'discovery (x2)');

  const instances = root.querySelectorAll('.board-condition-instance');
  assert.equal(instances.length, 2);
  assert.deepEqual(
    instances.map((i) => i.textContent).sort(),
    ['outcome: approve-for-merge', 'outcome: completed']
  );
});

test('#30 SEVERITY PER CLASS: a FLAG-tier group renders needs-attention, a NOTE-tier group renders nominal - register is never recomputed by the view (Rule 4), only grouped', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.board = [
    { code: 'record-unrecognised-fields', detail: 'x', register: 'needs-attention' },
    { code: 'discovery', detail: 'outcome: completed', register: 'nominal' }
  ];
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const groups = root.querySelectorAll('.board-condition-group');
  const flagGroup = groups.find((g) => g.textContent.includes('record-unrecognised-fields'));
  assert.ok(flagGroup, 'expected to find the record-unrecognised-fields group');
  assert.ok(flagGroup.className.includes('register-needs-attention'));

  const noteGroup = groups.find((g) => g.textContent.includes('discovery'));
  assert.ok(noteGroup);
  assert.ok(noteGroup.className.includes('register-nominal'));
});

test('renderBoard distinguishes bagged (fuel) and dark (freight) with different rendered text', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    { id: 'freight', title: 'Freight', position: 'dark', freshness: { kind: 'not-applicable' } },
    { id: 'fuel', title: 'Fuel', position: 'bagged', freshness: { kind: 'not-applicable' } }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const dark = root.querySelectorAll('.lane-body-dark');
  const bagged = root.querySelectorAll('.lane-body-bagged');
  assert.equal(dark.length, 1);
  assert.equal(bagged.length, 1);
  assert.notEqual(dark[0].textContent, bagged[0].textContent);
});
