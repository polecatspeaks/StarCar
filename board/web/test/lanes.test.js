// lanes.js: the view's own lane registry (task 5.3's completeness guard -
// "five lanes always rendered", "the lane-id set fixture-pinned in a test"
// - the design S5.2 completeness guard restated at the view layer, a
// shrink-is-red guard mirroring the server's own TestLaneRegistryPin) and
// the capability axis (design Rule 1: "no renderer for this payload" for
// an unrecognised lane id, or a KNOWN live lane whose data key died).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { EXPECTED_LANE_IDS, hasRendererFor } from '../js/lanes.js';

test('EXPECTED_LANE_IDS pins the v0 registry - shrinking this array is a red (fixture pin)', () => {
  assert.deepEqual(EXPECTED_LANE_IDS, ['dispatches', 'gates', 'trains', 'freight', 'fuel']);
});

test('hasRendererFor: an UNRECOGNISED lane id has no renderer (Law 7 - a free object, never a validation failure)', () => {
  assert.equal(hasRendererFor({ id: 'ticket-queue-v2', position: 'live', data: { anything: true } }), false);
});

test('hasRendererFor: freight (dark, no data key) has a renderer - the honest-absence renderer', () => {
  assert.equal(hasRendererFor({ id: 'freight', position: 'dark' }), true);
});

test('hasRendererFor: fuel (bagged, no data key) has a renderer - the honest-absence renderer', () => {
  assert.equal(hasRendererFor({ id: 'fuel', position: 'bagged' }), true);
});

test('hasRendererFor: dispatches with a well-shaped dispatches[] array has a renderer', () => {
  assert.equal(hasRendererFor({ id: 'dispatches', position: 'live', data: { dispatches: [] } }), true);
});

test('hasRendererFor: LOAD-BEARING - a live lane whose data key is entirely absent has NO renderer', () => {
  assert.equal(hasRendererFor({ id: 'dispatches', position: 'live' }), false);
});

test('hasRendererFor: trains with a well-shaped trains[] array has a renderer', () => {
  assert.equal(hasRendererFor({ id: 'trains', position: 'live', data: { trains: [] } }), true);
});

test('hasRendererFor: gates with a MALFORMED (non-array) gates key has NO renderer', () => {
  assert.equal(hasRendererFor({ id: 'gates', position: 'live', data: { gates: 'not-an-array' } }), false);
});
