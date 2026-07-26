// findings.test.js (#12: car health bar). Red-first table of REAL store
// findings text (verbatim, taken from this repo's own artifacts/ store -
// see this car's final report for the exact records) plus the garbage
// cases that must render UNKNOWN, never a guessed count (Law 1).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { parseFindingsCounts, familyKey, computeHealthTrends } from '../js/findings.js';

test('parseFindingsCounts: the canonical "N Major, M Minor" shape, exact', () => {
  assert.deepEqual(parseFindingsCounts('2 Major, 2 Minor'), { majors: 2, minors: 2 });
});

test('parseFindingsCounts: trailing prose after the canonical prefix is still parsed', () => {
  assert.deepEqual(
    parseFindingsCounts('0 Major, 0 Minor, 0 new findings at round 2. All seven round-1 findings PRESENT-fixed...'),
    { majors: 0, minors: 0 }
  );
  assert.deepEqual(
    parseFindingsCounts('1 Major, 0 Minor. All seven round-1 findings (M1 three sites...'),
    { majors: 1, minors: 0 }
  );
  assert.deepEqual(
    parseFindingsCounts('2 Major, 4 Minor, 1 Note\n  MAJOR-1: The gate is broken...'),
    { majors: 2, minors: 4 }
  );
});

test('parseFindingsCounts: plural "Majors"/"Minors" still matches at the start', () => {
  assert.deepEqual(parseFindingsCounts('3 Majors, 7 Minors'), { majors: 3, minors: 7 });
});

test('parseFindingsCounts: case-insensitive', () => {
  assert.deepEqual(parseFindingsCounts('4 major, 3 minor at plan round 1.'), { majors: 4, minors: 3 });
});

test('parseFindingsCounts: UNKNOWN - the count embedded mid-sentence, never at the head, is ambiguous and never guessed', () => {
  assert.equal(
    parseFindingsCounts('none outstanding — all 2 Major, 4 Minor, 1 Note from round-1 REJECT verdict fixed'),
    null
  );
});

test('parseFindingsCounts: UNKNOWN - reversed word order ("N Majors and M Minors") does not match the unambiguous pattern', () => {
  assert.equal(parseFindingsCounts('All 3 Majors and all 7 Minors from round 1 fixed, plus the optional...'), null);
});

test('parseFindingsCounts: UNKNOWN - a bare placeholder digit carries no Major/Minor words at all', () => {
  assert.equal(parseFindingsCounts('0'), null);
});

test('parseFindingsCounts: UNKNOWN - free-form prose with no canonical count shape', () => {
  assert.equal(
    parseFindingsCounts(
      'Task1: subject-based lookup was required in the extended test because Go\'s path sort orders...'
    ),
    null
  );
});

test('parseFindingsCounts: UNKNOWN - undefined/non-string input never throws', () => {
  assert.equal(parseFindingsCounts(undefined), null);
  assert.equal(parseFindingsCounts(null), null);
  assert.equal(parseFindingsCounts(42), null);
});

// --- familyKey: strip a trailing round suffix -------------------------------

test('familyKey: strips a trailing -rN round suffix', () => {
  assert.equal(familyKey('51-fix-review-r1'), '51-fix-review');
  assert.equal(familyKey('tooling-50-32-review-r3'), 'tooling-50-32-review');
});

test('familyKey: a subject with no round suffix is its own singleton family', () => {
  assert.equal(familyKey('a184e26ee16e704ae'), 'a184e26ee16e704ae');
});

// --- computeHealthTrends: the family series + trend direction ---------------

test('computeHealthTrends: 7 -> 1 -> 0 converges - healthy regardless of the starting number, attached to the LAST round only', () => {
  const gates = [
    { subject: 'x-review-r1', at: '2026-07-23T00:00:00Z', findings: '7 Major, 0 Minor' },
    { subject: 'x-review-r2', at: '2026-07-23T01:00:00Z', findings: '1 Major, 0 Minor' },
    { subject: 'x-review-r3', at: '2026-07-23T02:00:00Z', findings: '0 Major, 0 Minor' }
  ];
  const trends = computeHealthTrends(gates);
  assert.equal(trends.get(0), undefined, 'round 1 (not the family\'s latest) carries no trend badge');
  assert.equal(trends.get(1), undefined, 'round 2 (not the family\'s latest) carries no trend badge');
  assert.deepEqual(trends.get(2), { trend: 'converged', majorsSeries: [7, 1, 0] });
});

test('computeHealthTrends: 3 -> 4 -> 4 is the swirl signature - stalled/needs-attention, never silently calm', () => {
  const gates = [
    { subject: 'tooling-50-32-review-r1', at: '2026-07-23T00:00:00Z', findings: '3 Major, 2 Minor' },
    { subject: 'tooling-50-32-review-r2', at: '2026-07-23T01:00:00Z', findings: '4 Major, 1 Minor' },
    { subject: 'tooling-50-32-review-r3', at: '2026-07-23T02:00:00Z', findings: '4 Major, 0 Minor' }
  ];
  const trends = computeHealthTrends(gates);
  assert.deepEqual(trends.get(2), { trend: 'stalled', majorsSeries: [3, 4, 4] });
});

test('computeHealthTrends: still improving but not yet zero renders declining (calm), never stalled', () => {
  const gates = [
    { subject: 'y-review-r1', at: '2026-07-23T00:00:00Z', findings: '7 Major, 0 Minor' },
    { subject: 'y-review-r2', at: '2026-07-23T01:00:00Z', findings: '1 Major, 0 Minor' }
  ];
  const trends = computeHealthTrends(gates);
  assert.deepEqual(trends.get(1), { trend: 'declining', majorsSeries: [7, 1] });
});

test('computeHealthTrends: a single round (no history yet) is "first-round" - a REJECT with Majors is normal traffic, never alarming on round 1 alone', () => {
  const gates = [{ subject: 'z-review-r1', at: '2026-07-23T00:00:00Z', findings: '3 Major, 1 Minor' }];
  const trends = computeHealthTrends(gates);
  assert.deepEqual(trends.get(0), { trend: 'first-round', majorsSeries: [3] });
});

test('computeHealthTrends: ANY unparseable round in the family renders the WHOLE family unknown - never a guessed partial trend (Law 1)', () => {
  const gates = [
    { subject: 'w-review-r1', at: '2026-07-23T00:00:00Z', findings: '3 Major, 1 Minor' },
    { subject: 'w-review-r2', at: '2026-07-23T01:00:00Z', findings: 'APPROVE-FOR-MERGE. No Major. 5 Minor tracked issues.' }
  ];
  const trends = computeHealthTrends(gates);
  assert.deepEqual(trends.get(1), { trend: 'unknown', majorsSeries: null });
});

test('computeHealthTrends: sorts by "at" chronologically, not subject lexical order (r10 would otherwise sort before r2)', () => {
  const gates = [
    { subject: 'v-review-r2', at: '2026-07-23T01:00:00Z', findings: '1 Major, 0 Minor' },
    { subject: 'v-review-r1', at: '2026-07-23T00:00:00Z', findings: '5 Major, 0 Minor' }
  ];
  const trends = computeHealthTrends(gates);
  // index 0 is r2 (chronologically LAST) - it must carry the trend badge.
  assert.deepEqual(trends.get(0), { trend: 'declining', majorsSeries: [5, 1] });
  assert.equal(trends.get(1), undefined);
});

test('computeHealthTrends: distinct families never mix series', () => {
  const gates = [
    { subject: 'a-review-r1', at: '2026-07-23T00:00:00Z', findings: '3 Major, 0 Minor' },
    { subject: 'b-review-r1', at: '2026-07-23T00:00:00Z', findings: '0 Major, 0 Minor' }
  ];
  const trends = computeHealthTrends(gates);
  assert.deepEqual(trends.get(0), { trend: 'first-round', majorsSeries: [3] });
  assert.deepEqual(trends.get(1), { trend: 'converged', majorsSeries: [0] });
});
