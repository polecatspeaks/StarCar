// history-filter.test.js - #67: the generic terminal-history capping shared
// by the dispatches and trains lane filters. Pure, order-preserving, and
// the NEVER-FILTER-A-HOT-ROW law is the load-bearing case: only entries the
// caller's own isTerminal predicate marks terminal are ever candidates for
// capping - anything else survives unconditionally, however old.
// RED-FIRST: js/history-filter.js does not exist yet at this commit.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { capTerminalHistory, TERMINAL_HISTORY_CAP } from '../js/history-filter.js';

const isReturned = (item) => item.state === 'returned';

function items(specs) {
  // specs: [[id, state, at], ...]
  return specs.map(([id, state, at]) => ({ id, state, at }));
}

test('#67: fewer terminal items than the cap - nothing hidden, all visible, order preserved', () => {
  const list = items([
    ['a', 'returned', '2026-07-20T00:00:00Z'],
    ['b', 'dispatched', '2026-07-21T00:00:00Z'],
    ['c', 'returned', '2026-07-22T00:00:00Z']
  ]);
  const { visible, hiddenCount, terminalTotal } = capTerminalHistory(list, { isTerminal: isReturned, cap: 4 });
  assert.deepEqual(visible.map((i) => i.id), ['a', 'b', 'c']);
  assert.equal(hiddenCount, 0);
  assert.equal(terminalTotal, 2);
});

test('#67: more terminal items than the cap - only the most-recent-by-`at` N survive, hiddenCount honestly reports the rest', () => {
  const list = items([
    ['r1', 'returned', '2026-07-01T00:00:00Z'],
    ['r2', 'returned', '2026-07-02T00:00:00Z'],
    ['r3', 'returned', '2026-07-03T00:00:00Z'],
    ['r4', 'returned', '2026-07-04T00:00:00Z'],
    ['r5', 'returned', '2026-07-05T00:00:00Z']
  ]);
  const { visible, hiddenCount, terminalTotal } = capTerminalHistory(list, { isTerminal: isReturned, cap: 3 });
  assert.deepEqual(
    visible.map((i) => i.id).sort(),
    ['r3', 'r4', 'r5'],
    'the 3 MOST RECENT (by `at`) survive, not the first 3 in server order'
  );
  assert.equal(hiddenCount, 2);
  assert.equal(terminalTotal, 5);
});

test('NEVER FILTER A HOT ROW: a non-terminal item OLDER than every capped-out terminal item still survives, unconditionally', () => {
  const list = items([
    ['hot', 'overdue', '2020-01-01T00:00:00Z'], // oldest of everything, and non-terminal
    ['r1', 'returned', '2026-07-01T00:00:00Z'],
    ['r2', 'returned', '2026-07-02T00:00:00Z'],
    ['r3', 'returned', '2026-07-03T00:00:00Z'],
    ['r4', 'returned', '2026-07-04T00:00:00Z'],
    ['r5', 'returned', '2026-07-05T00:00:00Z']
  ]);
  const { visible } = capTerminalHistory(list, { isTerminal: isReturned, cap: 3 });
  assert.ok(visible.some((i) => i.id === 'hot'), 'a needs-attention row below every recency ranking must still render');
});

test('an unrecognised state word is never terminal by the caller-supplied predicate, so it is never a capping candidate', () => {
  const list = items([
    ['discovery', 'quarantined', '2020-01-01T00:00:00Z'],
    ['r1', 'returned', '2026-07-01T00:00:00Z'],
    ['r2', 'returned', '2026-07-02T00:00:00Z'],
    ['r3', 'returned', '2026-07-03T00:00:00Z'],
    ['r4', 'returned', '2026-07-04T00:00:00Z']
  ]);
  const { visible } = capTerminalHistory(list, { isTerminal: isReturned, cap: 3 });
  assert.ok(visible.some((i) => i.id === 'discovery'), 'an unrecognised state must never be filtered (Law 1/7)');
});

test('an item with an unparseable `at` never wins a "most recent" slot over a real timestamp', () => {
  const list = items([
    ['garbled', 'returned', 'not-a-date'],
    ['r1', 'returned', '2026-07-01T00:00:00Z'],
    ['r2', 'returned', '2026-07-02T00:00:00Z'],
    ['r3', 'returned', '2026-07-03T00:00:00Z']
  ]);
  const { visible } = capTerminalHistory(list, { isTerminal: isReturned, cap: 3 });
  assert.ok(!visible.some((i) => i.id === 'garbled'), 'an unparseable timestamp must sort as oldest, never assumed recent');
});

test('order is preserved for whatever survives - the filter selects, it never reorders', () => {
  const list = items([
    ['b', 'dispatched', '2026-07-21T00:00:00Z'],
    ['a', 'returned', '2026-07-20T00:00:00Z'],
    ['c', 'returned', '2026-07-22T00:00:00Z']
  ]);
  const { visible } = capTerminalHistory(list, { isTerminal: isReturned, cap: 4 });
  assert.deepEqual(visible.map((i) => i.id), ['b', 'a', 'c']);
});

test('TERMINAL_HISTORY_CAP is the shared default (owner: "maybe the last 3-4 returned")', () => {
  assert.ok(TERMINAL_HISTORY_CAP >= 3 && TERMINAL_HISTORY_CAP <= 4, `expected 3 or 4, got ${TERMINAL_HISTORY_CAP}`);
});

test('a custom getAt accessor is honoured (trains have no top-level `at` - callers derive their own recency signal)', () => {
  const list = [
    { id: 'r1', state: 'returned', recency: '2026-07-01T00:00:00Z' },
    { id: 'r2', state: 'returned', recency: '2026-07-05T00:00:00Z' },
    { id: 'r3', state: 'returned', recency: '2026-07-03T00:00:00Z' }
  ];
  const { visible } = capTerminalHistory(list, { isTerminal: isReturned, getAt: (i) => i.recency, cap: 2 });
  assert.deepEqual(
    visible.map((i) => i.id).sort(),
    ['r2', 'r3']
  );
});
