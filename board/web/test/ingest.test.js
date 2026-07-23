// Task 5.2 (spec YB-4/YB-11(b), design rev 5 S5.4 item 2): every parsed
// wire payload is validated against THE schema before it is ever applied.
// A payload that fails validation is DISCARDED - the previous render stays
// on screen, VISIBLY MARKED, and a board condition renders (red-first).
//
// This suite is hermetic: it builds a tiny local schema object (not the
// real schema/yard-snapshot.schema.json) so it stays a pure Node unit test
// with no filesystem/network dependency - createValidator/applyIncomingPayload
// are schema-agnostic by construction.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createValidator } from '../js/validate.js';
import { initialIngestState, applyIncomingPayload, VALIDATION_FAILED_CODE } from '../js/ingest.js';

const miniSchema = {
  $schema: 'https://json-schema.org/draft/2020-12/schema',
  type: 'object',
  properties: { seq: { type: 'integer' }, lanes: { type: 'array' } },
  required: ['seq', 'lanes']
};

test('a VALID payload replaces the current snapshot and clears any stale mark', () => {
  const validator = createValidator(miniSchema);
  const state = applyIncomingPayload(initialIngestState(), { seq: 1, lanes: [] }, validator);
  assert.deepEqual(state.snapshot, { seq: 1, lanes: [] });
  assert.equal(state.markedStale, false);
  assert.deepEqual(state.clientConditions, []);
});

test('an INVALID payload is DISCARDED: the previous snapshot is UNCHANGED', () => {
  const validator = createValidator(miniSchema);
  const good = applyIncomingPayload(initialIngestState(), { seq: 1, lanes: [] }, validator);

  const afterBad = applyIncomingPayload(good, { seq: 'not-a-number' /* missing lanes too */ }, validator);

  assert.deepEqual(afterBad.snapshot, { seq: 1, lanes: [] }, 'the last GOOD render must survive a discarded payload unchanged');
});

test('an INVALID payload marks the render visibly stale and raises a client board condition', () => {
  const validator = createValidator(miniSchema);
  const good = applyIncomingPayload(initialIngestState(), { seq: 1, lanes: [] }, validator);
  const afterBad = applyIncomingPayload(good, {}, validator);

  assert.equal(afterBad.markedStale, true);
  assert.equal(afterBad.clientConditions.length, 1);
  assert.equal(afterBad.clientConditions[0].code, VALIDATION_FAILED_CODE);
  assert.equal(afterBad.clientConditions[0].register, 'needs-attention');
});

test('a VALID payload arriving after a discard clears the stale mark and the client condition', () => {
  const validator = createValidator(miniSchema);
  let state = initialIngestState();
  state = applyIncomingPayload(state, { seq: 1, lanes: [] }, validator);
  state = applyIncomingPayload(state, {}, validator); // discarded
  assert.equal(state.markedStale, true);

  state = applyIncomingPayload(state, { seq: 2, lanes: [] }, validator);
  assert.equal(state.markedStale, false);
  assert.deepEqual(state.clientConditions, []);
  assert.deepEqual(state.snapshot, { seq: 2, lanes: [] });
});
