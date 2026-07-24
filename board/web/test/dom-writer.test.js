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
