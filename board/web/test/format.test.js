// format.test.js - #67 (FORMAT NIT, owner 2026-07-26 17:16): every duration
// this board renders becomes compact clock time - leading empty fields
// dropped, minimum form M:SS so it always reads as a clock, no unit-suffix
// forms. RED-FIRST: js/format.js does not exist yet at this commit.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { formatClockDuration } from '../js/format.js';

test('#67: 45s renders 0:45 (owner example 1)', () => {
  assert.equal(formatClockDuration(45), '0:45');
});

test('#67: 4m32s (272s) renders 4:32 (owner example 2)', () => {
  assert.equal(formatClockDuration(272), '4:32');
});

test('#67: 1h2m3s (3723s) renders 1:02:03 (owner example 3)', () => {
  assert.equal(formatClockDuration(3723), '1:02:03');
});

test('#67: 0 seconds renders 0:00, never a blank string', () => {
  assert.equal(formatClockDuration(0), '0:00');
});

test('#67: seconds under 10 still pad to two digits (5s renders 0:05, never 0:5)', () => {
  assert.equal(formatClockDuration(5), '0:05');
});

test('#67: exactly one hour (3600s) renders 1:00:00, minutes and seconds both padded', () => {
  assert.equal(formatClockDuration(3600), '1:00:00');
});

test('#67: no unit-suffix form ever appears (no "s", "m", or "h" letters in the output)', () => {
  const rendered = formatClockDuration(3723);
  assert.ok(!/[smh]/.test(rendered), `expected no unit-suffix letters in: ${rendered}`);
});
