// YB-6 (spec S5, design rev 5 S5.2 Rules 1-4): the THREE-AXIS composition
// matrix - position register x freshness kind x capability present/absent,
// most-severe-wins - run in Node's stdlib test runner (`node --test`), no
// framework, no DOM, no fetch: compose.js is a pure module by construction.
//
// The two load-bearing cases (plan task 5.1, spec YB-6) come FIRST,
// red-first against a partial/absent implementation:
//   1. live + failed -> needs-attention (a live lane whose data source dies
//      resolves hot even though the position itself is calm).
//   2. live + fresh + no-renderer -> needs-attention, carrying the exact
//      "no renderer for this payload" line (never silence).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { composeRegister, composeLines, mostSevereRegister, NO_RENDERER_LINE } from '../js/compose.js';

// Local fixture, deliberately NOT read from schema/vocab/board-defs.json:
// this suite pins compose.js's OWN arithmetic against hand-written inputs,
// independent of whatever the shipped vocab file happens to contain today
// (board-defs.json's four landed positions are all nominal/in-progress -
// none is needs-attention - so the "needs-attention position register" leg
// of the matrix is exercised via an UNRECOGNISED position id, which is
// itself Rule 1's explicit clause: "needs-attention if unrecognised").
const positionDefs = [
  { id: 'live', label: 'Live', register: 'nominal' },
  { id: 'under-construction', label: 'Under construction', register: 'in-progress' }
];

test('LOAD-BEARING 1: live + failed renders needs-attention', () => {
  const register = composeRegister({
    position: 'live',
    positionDefs,
    freshness: { kind: 'failed', reason: { code: 'store-unreadable', detail: 'boom' } },
    hasRenderer: true
  });
  assert.equal(register, 'needs-attention');
});

test('LOAD-BEARING 2: live + fresh + no-renderer renders needs-attention with the "no renderer for this payload" line', () => {
  const register = composeRegister({
    position: 'live',
    positionDefs,
    freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
    hasRenderer: false
  });
  assert.equal(register, 'needs-attention');

  const lines = composeLines({
    position: 'live',
    positionDefs,
    freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' },
    hasRenderer: false
  });
  assert.equal(NO_RENDERER_LINE, 'no renderer for this payload');
  assert.ok(
    lines.secondary && lines.secondary.includes('no renderer for this payload'),
    `expected the secondary line to carry the exact "no renderer for this payload" text, got: ${lines.secondary}`
  );
});

// --- the exhaustive three-axis matrix -------------------------------------
//
// Position axis: one def per NON-needs-attention register plus one
// unrecognised id for the needs-attention leg (see fixture comment above).
const POSITION_CASES = [
  { position: 'live', expectedPositionRegister: 'nominal' },
  { position: 'under-construction', expectedPositionRegister: 'in-progress' },
  { position: 'wholly-unregistered-position', expectedPositionRegister: 'needs-attention' }
];

// Freshness axis: the five mechanism-closed kinds (design S5.2) and their
// mapping to a register, restated independently here (not imported from
// compose.js) so this test can catch compose.js getting its OWN mapping
// wrong.
const FRESHNESS_CASES = [
  { freshness: { kind: 'not-applicable' }, expectedFreshnessRegister: 'nominal' },
  { freshness: { kind: 'never-polled' }, expectedFreshnessRegister: 'in-progress' },
  { freshness: { kind: 'fresh', asOf: '2026-07-23T00:00:00Z' }, expectedFreshnessRegister: 'nominal' },
  {
    freshness: { kind: 'stale', asOf: '2026-07-23T00:00:00Z', ageBucketMs: 40000 },
    expectedFreshnessRegister: 'needs-attention'
  },
  {
    freshness: { kind: 'failed', reason: { code: 'store-unreadable', detail: 'boom' } },
    expectedFreshnessRegister: 'needs-attention'
  }
];

const CAPABILITY_CASES = [
  { hasRenderer: true, expectedCapabilityRegister: 'nominal' },
  { hasRenderer: false, expectedCapabilityRegister: 'needs-attention' }
];

// Severity arithmetic, written independently of compose.js's own
// mostSevereRegister (this is the ORACLE the matrix checks the real
// function against, not a call into the thing under test - the scar this
// guards against is an "expected" derived from the SUT itself).
const SEVERITY = { nominal: 0, 'in-progress': 1, 'needs-attention': 2 };
function expectedOf(a, b, c) {
  const regs = [a, b, c];
  let worst = 'nominal';
  for (const r of regs) {
    if (SEVERITY[r] > SEVERITY[worst]) worst = r;
  }
  return worst;
}

test('YB-6 three-axis matrix: every position register x every freshness kind x capability present/absent, most-severe-wins', () => {
  let caseCount = 0;
  for (const p of POSITION_CASES) {
    for (const f of FRESHNESS_CASES) {
      for (const c of CAPABILITY_CASES) {
        caseCount += 1;
        const expected = expectedOf(p.expectedPositionRegister, f.expectedFreshnessRegister, c.expectedCapabilityRegister);
        const actual = composeRegister({
          position: p.position,
          positionDefs,
          freshness: f.freshness,
          hasRenderer: c.hasRenderer
        });
        assert.equal(
          actual,
          expected,
          `position=${p.position} freshness=${f.freshness.kind} hasRenderer=${c.hasRenderer}: expected ${expected}, got ${actual}`
        );
      }
    }
  }
  // Non-vacuity: the matrix must actually have run all 3x5x2 = 30 cases,
  // not silently iterated zero times over an empty fixture.
  assert.equal(caseCount, 30);
});

test('mostSevereRegister: unknown register strings are treated as the most severe, never as calm', () => {
  assert.equal(mostSevereRegister('nominal', 'not-a-real-register'), 'not-a-real-register');
});

// --- Rule 2: position speaks first, freshness second ----------------------

test('Rule 2: not-applicable freshness renders NO secondary line at all', () => {
  const lines = composeLines({
    position: 'dark',
    positionDefs: [...positionDefs, { id: 'dark', label: 'Dark', register: 'nominal' }],
    freshness: { kind: 'not-applicable' },
    hasRenderer: true
  });
  assert.equal(lines.primary, 'Dark');
  assert.equal(lines.secondary, null);
});

test('Rule 2: an unrecognised position renders its raw id, verbatim, in the primary line', () => {
  const lines = composeLines({
    position: 'quarantined',
    positionDefs,
    freshness: { kind: 'not-applicable' },
    hasRenderer: true
  });
  assert.ok(lines.primary.includes('quarantined'), `expected the raw id "quarantined" verbatim in: ${lines.primary}`);
});

test('Rule 3: a stale lane\'s secondary line uses ONLY the server-issued ageBucketMs, never a client-computed elapsed time', () => {
  const lines = composeLines({
    position: 'live',
    positionDefs,
    freshness: { kind: 'stale', asOf: '2020-01-01T00:00:00Z', ageBucketMs: 40000 },
    hasRenderer: true
  });
  assert.ok(lines.secondary.includes('40'), `expected the ageBucketMs-derived figure in: ${lines.secondary}`);
});
