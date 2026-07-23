// vocab.js's discovery-rendering contract: a recognised id gets its def's
// label+register; an unrecognised id renders its RAW id (verbatim) with
// register needs-attention - never silence, never a guess (design rev 5
// S5.2, mockup brief "the discovery state").
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { findVocabDef, describeVocab } from '../js/vocab.js';

const outcomeDefs = [
  { id: 'done', label: 'Done', register: 'nominal' },
  { id: 'error', label: 'Error', register: 'needs-attention' }
];

test('findVocabDef: finds a def by id', () => {
  assert.deepEqual(findVocabDef(outcomeDefs, 'done'), { id: 'done', label: 'Done', register: 'nominal' });
});

test('findVocabDef: missing id is undefined, missing defs array is undefined (never throws)', () => {
  assert.equal(findVocabDef(outcomeDefs, 'nope'), undefined);
  assert.equal(findVocabDef(undefined, 'done'), undefined);
});

test('describeVocab: a recognised id carries its def label+register', () => {
  assert.deepEqual(describeVocab('done', outcomeDefs), { id: 'done', label: 'Done', register: 'nominal', recognised: true });
});

test('describeVocab: an UNRECOGNISED id renders its raw id verbatim as the label, register needs-attention, never guessed as calm', () => {
  const d = describeVocab('quarantined', outcomeDefs);
  assert.equal(d.label, 'quarantined');
  assert.equal(d.register, 'needs-attention');
  assert.equal(d.recognised, false);
});
