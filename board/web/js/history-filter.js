// history-filter.js - #67 (owner fast-follow after #62 live-board feedback):
// the generic terminal-history capping shared by the dispatches and trains
// lane filters. Pure: no DOM, no clock reads, no register recomputation -
// it runs AFTER render.js has already composed every row's own register, and
// only ever SELECTS which already-composed rows render (Law 6: one
// algorithm, not two independent reimplementations of "keep the hot rows,
// cap the calm ones" - render.js's dispatches and trains cases both call
// this same function).
//
// NEVER-FILTER-A-HOT-ROW LAW: the caller's isTerminal predicate is the ONLY
// gate. Anything the predicate does not call terminal is unconditionally
// kept - dispatched/overdue/presumed-lost, any unrecognised state word, a
// train with an in-flight car, a train with an undelivered manifest member.
// Only entries the predicate itself calls terminal ever become capping
// candidates, and only the OLDEST-by-recency ones beyond the cap are
// dropped.

// Owner's own words on issue #67: "maybe the last 3-4 returned" - one
// constant, shared by both lanes, so a future retune touches this one line.
export const TERMINAL_HISTORY_CAP = 4;

/**
 * @template T
 * @param {T[]} items - in the server's own order; this function never
 *   reorders what it returns, it only removes some terminal entries.
 * @param {{isTerminal: (item: T) => boolean, getAt?: (item: T) => (string|null|undefined), cap?: number}} opts
 * @returns {{visible: T[], hiddenCount: number, terminalTotal: number}}
 */
export function capTerminalHistory(items, { isTerminal, getAt = (item) => item.at, cap = TERMINAL_HISTORY_CAP }) {
  const terminalEntries = [];
  const alwaysVisibleIndices = new Set();

  items.forEach((item, index) => {
    if (isTerminal(item)) {
      terminalEntries.push({ index, atMs: Date.parse(getAt(item)) });
    } else {
      alwaysVisibleIndices.add(index);
    }
  });

  // Most-recent-first by the caller's own recency signal. An unparseable or
  // missing `at` (Date.parse -> NaN) sorts as OLDEST: every NaN comparison
  // below is false, so a NaN entry never wins a spot ahead of a real
  // timestamp - conservative, since this view has no honest way to call an
  // undated entry "recent enough" to keep.
  const keepTerminalIndices = new Set(
    [...terminalEntries]
      .sort((a, b) => {
        if (Number.isNaN(a.atMs) && Number.isNaN(b.atMs)) return 0;
        if (Number.isNaN(a.atMs)) return 1;
        if (Number.isNaN(b.atMs)) return -1;
        return b.atMs - a.atMs;
      })
      .slice(0, cap)
      .map((entry) => entry.index)
  );

  const visible = items.filter((_, index) => alwaysVisibleIndices.has(index) || keepTerminalIndices.has(index));

  return {
    visible,
    hiddenCount: terminalEntries.length - keepTerminalIndices.size,
    terminalTotal: terminalEntries.length
  };
}
