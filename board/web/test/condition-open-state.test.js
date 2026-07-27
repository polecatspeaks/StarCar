// condition-open-state.test.js (#69: owner fast-follow - open-state
// persistence for the conditions strip). Pure state-shape functions only;
// app.js's own sessionStorage wiring is exercised by the real browser
// (docs/screenshots/2026-07-26-view-69-71-candidates/, this car's report).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  defaultOpenState,
  loadOpenState,
  saveOpenState,
  isGroupOpen,
  withGroupOpen,
  withStripOpen
} from '../js/condition-open-state.js';

// A minimal storage-shaped fake (Map-backed) - never real sessionStorage,
// which does not exist in plain Node (the same posture minidom.js takes
// toward `document`).
function fakeStorage(initial = {}) {
  const map = new Map(Object.entries(initial));
  return {
    getItem(key) {
      return map.has(key) ? map.get(key) : null;
    },
    setItem(key, value) {
      map.set(key, value);
    },
    _map: map
  };
}

test('defaultOpenState: everything collapsed - strip false, no group entries', () => {
  const s = defaultOpenState();
  assert.equal(s.strip, false);
  assert.deepEqual(s.groups, {});
});

test('loadOpenState: no storage / no key yields the collapsed default', () => {
  assert.deepEqual(loadOpenState(null), defaultOpenState());
  assert.deepEqual(loadOpenState(fakeStorage()), defaultOpenState());
});

test('loadOpenState: corrupt JSON degrades to the collapsed default, never throws', () => {
  const storage = fakeStorage({ 'starcar-board-conditions-open': 'not json {{{' });
  assert.deepEqual(loadOpenState(storage), defaultOpenState());
});

test('loadOpenState: a malformed shape (groups not an object) degrades to the collapsed default', () => {
  const storage = fakeStorage({ 'starcar-board-conditions-open': JSON.stringify({ strip: true, groups: 'not-an-object' }) });
  assert.deepEqual(loadOpenState(storage), defaultOpenState());
});

test('saveOpenState then loadOpenState round-trips a real state', () => {
  const storage = fakeStorage();
  const state = withGroupOpen(withStripOpen(defaultOpenState(), true), 'discovery', true);
  saveOpenState(storage, state);
  assert.deepEqual(loadOpenState(storage), state);
});

test('isGroupOpen: a code with no entry reads as CLOSED - the NEW-CONDITION-DEFAULTS-COLLAPSED rule', () => {
  const state = withGroupOpen(defaultOpenState(), 'discovery', true);
  assert.equal(isGroupOpen(state, 'discovery'), true);
  assert.equal(isGroupOpen(state, 'a-brand-new-code-never-seen-before'), false);
});

test('withGroupOpen: PER-GROUP - opening one code never opens another', () => {
  let state = withGroupOpen(defaultOpenState(), 'discovery', true);
  assert.equal(isGroupOpen(state, 'discovery'), true);
  assert.equal(isGroupOpen(state, 'record-unrecognised-fields'), false);

  state = withGroupOpen(state, 'record-unrecognised-fields', true);
  assert.equal(isGroupOpen(state, 'discovery'), true, 'opening a second group must not close the first');
  assert.equal(isGroupOpen(state, 'record-unrecognised-fields'), true);
});

test('withGroupOpen: closing a group again is a distinct, explicit false - not a return to absence', () => {
  let state = withGroupOpen(defaultOpenState(), 'discovery', true);
  state = withGroupOpen(state, 'discovery', false);
  assert.equal(isGroupOpen(state, 'discovery'), false);
  assert.ok('discovery' in state.groups, 'an explicit close is a recorded false, not a deleted key');
});

test('withGroupOpen/withStripOpen never mutate the input state (pure update)', () => {
  const original = defaultOpenState();
  const frozen = JSON.parse(JSON.stringify(original));
  withGroupOpen(original, 'discovery', true);
  withStripOpen(original, true);
  assert.deepEqual(original, frozen, 'the input state object must be unchanged');
});

test('withStripOpen: the strip flag is independent of every group flag', () => {
  let state = withGroupOpen(defaultOpenState(), 'discovery', true);
  state = withStripOpen(state, true);
  assert.equal(state.strip, true);
  assert.equal(isGroupOpen(state, 'discovery'), true, 'opening the strip must not disturb group state');

  state = withStripOpen(state, false);
  assert.equal(state.strip, false);
  assert.equal(isGroupOpen(state, 'discovery'), true, 'closing the strip must not disturb group state');
});
