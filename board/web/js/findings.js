// findings.js (#12: car health bar). PURE, no DOM - parses the wire's raw
// `gate.findings` free text into a Major/Minor count, groups a car's review
// rounds into a family, and derives a convergence trend across that family's
// series. This is the ONE place this parsing happens (Law 6): the Go side
// (board/assemble.Gate.Findings) carries the raw text verbatim and never
// re-implements this regex.
//
// CONSERVATIVE PARSING (Law 1 - unknown renders as unknown, never a guessed
// count): only the UNAMBIGUOUS "N Major(s), M Minor(s)" shape AT THE HEAD of
// the string is recognised. This repo's own real store carries every shape
// from the exact canonical form ("2 Major, 2 Minor") through prose that
// merely MENTIONS a count mid-sentence ("none outstanding — all 2 Major, 4
// Minor...") to free-form narrative with no count at all - the conservative
// pattern below was calibrated directly against this repo's own artifacts/
// store, method and count both reproducible (CORRECTED #28/#12 fix cycle
// round 2 MINOR-4: this comment used to cite "this car's final report", not
// a durable artifact): walk artifacts/**/*.json, read each record's
// `findings` field, count matches against this exact pattern. Observed at
// this fix cycle's HEAD: 207 store records, 136 carry a `findings` field,
// this pattern PARSES 38 of them and renders the remaining 98 UNKNOWN
// (never a guessed count) - re-run any time the store grows to reconfirm.
const FINDINGS_HEAD_PATTERN = /^\s*(\d+)\s+majors?\s*,\s*(\d+)\s+minors?\b/i;

/**
 * @param {unknown} text
 * @returns {{majors: number, minors: number} | null} null is the honest
 *   UNKNOWN state - never a guessed {majors: 0, minors: 0}.
 */
export function parseFindingsCounts(text) {
  if (typeof text !== 'string') return null;
  const m = FINDINGS_HEAD_PATTERN.exec(text);
  if (!m) return null;
  return { majors: Number(m[1]), minors: Number(m[2]) };
}

// A review-round family shares every subject segment up to a trailing round
// number ("51-fix-review-r1", "-r2", "-r3" -> family "51-fix-review",
// issue #12's own worked example: "tooling-50-32-review-r1/-r2/-r3" -
// CORRECTED #28/#12 fix cycle round 2 MAJOR-3: this used to misattribute
// the example to "docs/CLAUDE.md", a file that does not exist; the string
// lives in issue #12's body, not in the root CLAUDE.md (whose own,
// DIFFERENT swirl-scar series is "3 -> 4 -> 5" - never conflate the two).
// A subject with no such suffix is its own singleton family (round 1 of 1).
const ROUND_SUFFIX_PATTERN = /-r\d+$/i;

/**
 * @param {unknown} subject
 * @returns {string}
 */
export function familyKey(subject) {
  if (typeof subject !== 'string') return '';
  return subject.replace(ROUND_SUFFIX_PATTERN, '');
}

/**
 * computeHealthTrends groups gates (wire gate entries: {subject, at,
 * findings}) into review-round families, sorts each family CHRONOLOGICALLY
 * (by `at` - subject lexical order would sort "r10" before "r2", a real
 * trap), and derives ONE trend value per family, attached ONLY to the
 * family's LATEST round (the other rounds already rendered their own
 * verdict as their own row; repeating the same trend on every round would
 * clutter the gates lane without adding information - HAVAGLANCE).
 *
 * Trend values (owner's own two worked examples, issue #12):
 *   - 'converged': the latest round's majors count is 0 - healthy
 *     REGARDLESS of the starting number (7 -> 1 -> 0 renders healthy).
 *   - 'declining': more than one round observed, still nonzero, but the
 *     latest round's majors is LOWER than the round before it - calm, the
 *     gate is winning, just not finished yet.
 *   - 'stalled': more than one round observed, latest majors is nonzero and
 *     NOT lower than the round before it (flat or climbing) - the swirl
 *     signature (3 -> 4 -> 4, clustered) - needs-attention, the one case
 *     this surface actually alarms on.
 *   - 'first-round': exactly one round observed so far - no trend exists
 *     yet. Never alarming on its own - root CLAUDE.md's GUIDE STAR section
 *     names a REJECT itself as "a success outcome for the process," and a
 *     single round of Majors carries no trend information at all yet -
 *     rendered neutral, not calm-green and not hot-red.
 *   - 'unknown': ANY round in the family has unparseable findings text -
 *     Law 1, the whole family's trend is withheld rather than computed
 *     from a partial, guessed series.
 *
 * @param {Array<{subject: string, at: string, findings?: string}>} gates
 * @returns {Map<number, {trend: string, majorsSeries: number[] | null}>}
 *   keyed by the gate's own INDEX in the input array (the caller's stable
 *   handle back to which rendered row gets the badge).
 */
export function computeHealthTrends(gates) {
  const families = new Map();
  gates.forEach((g, index) => {
    const key = familyKey(g.subject);
    if (!families.has(key)) families.set(key, []);
    families.get(key).push({ index, at: g.at, counts: parseFindingsCounts(g.findings) });
  });

  const result = new Map();
  for (const entries of families.values()) {
    entries.sort((a, b) => (a.at < b.at ? -1 : a.at > b.at ? 1 : 0));
    const latest = entries[entries.length - 1];
    const anyUnknown = entries.some((e) => e.counts === null);

    if (anyUnknown) {
      result.set(latest.index, { trend: 'unknown', majorsSeries: null });
      continue;
    }

    const majorsSeries = entries.map((e) => e.counts.majors);
    const final = majorsSeries[majorsSeries.length - 1];
    let trend;
    if (final === 0) {
      trend = 'converged';
    } else if (majorsSeries.length === 1) {
      trend = 'first-round';
    } else {
      const previous = majorsSeries[majorsSeries.length - 2];
      trend = final < previous ? 'declining' : 'stalled';
    }
    result.set(latest.index, { trend, majorsSeries });
  }
  return result;
}
