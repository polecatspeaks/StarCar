<!-- starcar-integrity: sha256=2999e836c8779cd3a8199403c71e90ec349953a47d14cb49e964cc9630a31130 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# View train #67 lane-filters car review, round 3 (APPROVE)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial delta re-review, capped round
Round: 3
Target: `car/view-67 HEAD 4b97749 (fix commit on c5858df)`
Base reviewed: `7b05cb770980e3116f8b289371fdcd0334a570ab`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `aa9858b26c4f2f91e`. The conductor did not retype a word of what follows. Verbatim by
> construction rather than by discipline, because the author being reviewed is the
> one landing the review, and a hand-copied verdict is a hand-maintained mirror at a
> process boundary.
>
> Integrity: the `starcar-integrity` line at the top of this file hashes EVERY byte
> below it - this header's claims as well as the verbatim body. Recompute with
> `scripts/Verify-Verdict.ps1 -Path <this file>`. An independently-written copy of the
> same body exists on the Entire checkpoint branch; that copy, not the hash, is the
> defence against whoever controls this script.
>
> Path normalisation: the repository root was rewritten to ``<repo>`` and the operator home directory to ``~``, BEFORE hashing. Mechanical and narrow: only those two roots, longest-first, no other substitution. This is portability, not curation - findings, verdicts and counts are untouched, and the un-normalised original is on the Entire checkpoint branch.

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `7b05cb770980e3116f8b289371fdcd0334a570ab` |

| Dispatch, the locator within the session | `aa9858b26c4f2f91e` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 7b05cb770980e3116f8b289371fdcd0334a570ab
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# DELTA RE-REVIEW — view #67 car, round 3 (THE CAPPED ROUND)

**Verdict: APPROVE** (0 Major, 0 Minor, 2 Notes)

Worktree detached at `4b97749`, parent confirmed `c5858df`. Byte-clean exit: `render.js` SHA256 `B15A0DF3655147E7B073C9EE016AF8CFCFAC90F1234CC6ED015958A32E715E77` before and after four injections, `git status --short` empty, stash empty, HEAD unchanged, nothing committed or pushed.

**The cap does not trigger.** Zero Majors this round.

---

## R2 finding dispositions

| ID | Disposition | Evidence |
|---|---|---|
| **MAJOR-R2-1** | **PRESENT (fixed)** — re-derived by me, not read | Deleting `if (train.declaredNotObserved.length &gt; 0) return false;` at `4b97749` now yields **43 tests, 42 pass, 1 fail** in `render.test.js` (169 → 168 whole-dir). Failing test: `#67: a train with an undelivered manifest member ("queued") always renders - declaredNotObserved is never terminal` → `AssertionError: a train with an undelivered manifest member must render regardless of recency / actual: false, expected: true`. At `c5858df` this same deletion was **73/73 green**. The guard is re-armed. |
| **MINOR-R2-1** | **PRESENT (fixed)** | Same one-line edit: `render.test.js:620` fixture car now `carFixture('member', 'returned', '2020-01-01T00:00:00Z', 'done')` — a wire-realistic shape. |
| **NOTE-3** | **PRESENT (fixed)** | `verify-lane-filters.mjs:78` captures `document.querySelector('.car-outcome.register-needs-attention')`; `:93-95` emit text, class and `getComputedStyle(...).color`. Re-ran it: `hotOutcomeChipColor: "rgb(255, 74, 58)"`. |

---

## Full axis-by-axis fault-injection sweep at `4b97749`

I re-ran my entire r2 sweep rather than only the one finding, to confirm the fix armed one axis without disarming another.

| Conjunct / guard | Injection | Result at `4b97749` | At `c5858df` |
|---|---|---|---|
| `declaredNotObserved` guard | R3-FI-1 deleted | **RED** — 42/43, self-naming ✅ | 73/73 green ❌ |
| `outcomeRegister === 'nominal'` | R3-FI-2 dropped | **RED** — 2 tests, verbatim *"a train with a hot OUTCOME (error, needs-attention) must never be capped"* and *"an unrecognised outcome word (Law 1 fallback: needs-attention) must never be capped - unknowns are hot by law"* ✅ | red ✅ |
| `cars.length &gt; 0` | R3-FI-3 dropped | **RED** — 1 test, *"a zero-car train has never carried a returned car…"* ✅ | red ✅ |
| `stateRegister === 'nominal'` | R3-FI-4 dropped | 169/169 green — **expected and correct**, see below | green |

**Three of four armed; the fourth is unarmable by construction and now says so in code.** In r2 NOTE-1 I stated this conjunct cannot be isolated by any wire-realistic fixture and explicitly did **not** ask for its removal. The car did not paper over that — it documented it at `isTrainTerminal`. I verified every claim in that comment:

- *"assemble.go sets Outcome exactly when a dispatch's liveness state is 'returned'"* — `board/assemble/assemble.go:113-114` is the **only** assignment to a `TrainCar`'s Outcome, guarded by `if d.State == "returned"`. Upstream, `board/fold/algorithm.go:214` sets `entry.Outcome` only inside `case "returned":`. Both links verified.
- *"schema/starcar-artifact.schema.json requires outcome for every kind=returned record"* — true; the `kind: returned` branch requires `["outcome", "findings", "abstract"]`, pinned by vector `invalid-returned-missing-outcome.json`.
- *"outcomeRegister nominal already implies stateRegister nominal"* — follows from the two above, and matches the real-wire measurement I took in r2 (10 of 10 returned cars carried an outcome).
- *"removing it would be removing the ONLY thing stopping a future schema relaxation (or a malformed feed) from silently reintroducing MAJOR-R1-1's exact defect"* — true: a malformed car with `state: 'overdue'` and `outcome: 'done'` would render a `register-needs-attention` chip while the outcome-only predicate called it terminal.

This is the correct disposition of an unpinnable guard: keep it, and leave a note so a future round does not read FI-green as dead code.

---

## Full-diff audit `c5858df..4b97749`

Exactly the scoped four paths: `board/web/js/render.js` (+16, comment only), `board/web/test/render.test.js` (+11/-1, one fixture line + comment), `board/web/verify-lane-filters.mjs` (+20/-1, capture + comment), and the screenshot. **Zero `.go` files** — verified by file list, not re-run, per instruction.

**Zero coordinate-shaped citations introduced.** I grepped every added line for `file.ext:NNN` and found none; all references are by filename or symbol (`assemble.go`, `starcar-artifact.schema.json`, `dom-writer.js`'s `car-outcome ${registerClass(car.outcomeRegister)}`). Every one opened and confirmed. `render.js` is the only `js/` file touched, so no other file's comments could drift.

---

## Suites at `4b97749`

| Suite | Observed | Car claimed |
|---|---|---|
| Node `board/web` whole-dir | **169 tests, 169 pass, 0 fail, 0 skipped** | 169/169 unchanged ✅ |
| Pester `scripts/tests` | **227 total, 222 passed, 0 failed, 5 skipped** | 223/227 attached; my 5th is the predicted detached-HEAD skip ✅ |
| Citation gates (both files) | **41 passed, 4 informational skips, 0 failed** | green ✅ |
| Pester `scripts/probes` | **24 total, 24 passed, 0 failed** | 24/24 ✅ |
| `probe-yard-snapshot.mjs` | `PROBE RESULT: PASS`, exit 0 | PASS ✅ |
| Go files in diff | **none** | untouched ✅ |

---

## #40 floor — observed live, and the selector challenged

Re-ran the car's harness against the real Go server in real Chromium:

```
hotOutcomeChipText : "error"
hotOutcomeChipClass: "car-outcome register-needs-attention"
hotOutcomeChipColor: "rgb(255, 74, 58)"          &lt;- --needs-attention #ff4a3a (board.css:41)
trainsHistorySummaryText    : "showing last 4 of 5 - full record in the store"
dispatchesHistorySummaryText: "showing last 4 of 11 returned - full record in the store"
dispatchesHistorySummaryColor: "rgb(217, 213, 201)"
solariRowCount: 6
```

Matches my independent r2 probe exactly. I also **challenged the unambiguity claim** rather than accepting it — on the live page there are 5 `.car-outcome` elements, of which the hot selector matches exactly **1**; the other 4 are `done [car-outcome register-nominal]`. The comment's claim is true. Screenshot opened and read: the hot-outcome train renders first with a red `error` chip inside an otherwise calm car chip, trains summary carries the owner's no-noun wording, and the footer store path is normalised (`~/AppData/...`, no operator home leaked).

---

## CONVERGENCE RULING

**r1: 1 Major / 3 Minor → r2: 1 Major / 1 Minor → r3: 0 Major / 0 Minor.** Findings declined monotonically in count and severity, the r2 finding was closed by the exact edit prescribed with the re-armament independently re-derived, and this round introduced no new defect. Every swirl trigger that fired in r2 has cleared. This is convergence, and the cap I set is retired unused.

---

## Constitution check

| Law / rule | Evidence |
|---|---|
| **Law 1 (unknown renders as unknown)** | ✅ Unrecognised outcome keeps its train visible; pinned (R3-FI-2 red), observed at `rgb(255,74,58)`. |
| **Law 4 / absence-blindness** | ✅ True-count honesty lines on both lanes, null when nothing hidden; no hot row among the hidden. |
| **Law 6 (no second copy)** | ✅ One `capTerminalHistory`, one `formatClockDuration`, one `historySummaryLine` with an optional noun. |
| **Law 7 (no hardcoded taxonomy)** | ✅ Predicate reads composed registers only; schema's open-string posture correctly described. |
| **#40 rendering floor** | ✅ Real browser, real server, computed style — now captured by the committed harness itself, not only by a reviewer's probe. |
| **TDD / non-vacuity** | ✅ Every armable guard watched failing this round; the one unarmable conjunct is documented rather than hidden. |
| **Carrier rule (folds marked, not drifted)** | ✅ MAJOR-R2-1, MINOR-R2-1 and NOTE-3 each folded inline with their IDs in code comments and test names. |
| **Living documents** | ✅ No document invalidated; `board.css` and `gating-matrix.md:69-73` re-checked across all three rounds and still true. |
| **#42 code-citation standard** | ✅ Gate green; all touched files cite `#67`. |
| **Showcase never edits the record** | ✅ Screenshot regenerated into the dated candidate dir; the three REJECT rounds stay visible in history. |

---

## MERGE MESSAGE BLOCK

```
merge: view train #67 lane history filters + compact-clock time
(car ae1bd02 -&gt; c5858df -&gt; 4b97749, review APPROVE r3, 0 Major)

DELIVERS
- Dispatches and trains lane terminality filters reading BOTH register axes
  (stateRegister AND outcomeRegister), cap 4 most-recent by recency.
- Hot rows are NEVER filtered: needs-attention, in-progress, unrecognised
  state words AND unrecognised/hot outcome words all stay visible regardless
  of age. Trains additionally spare undelivered-manifest ("queued") and
  zero-car trains.
- True-count honesty lines: dispatches "showing last N of M returned - full
  record in the store"; trains uses the owner's exact ticket wording with no
  noun ("showing last N of M - ..."), a train never carrying that word on the
  wire. Null when nothing is hidden - never a "showing 0 of 0" noise line.
- Compact clock durations board-wide (0:45 / 4:32 / 1:02:03), one shared
  formatter, no unit-suffix form left anywhere in board/web/js.
- #27 wire contract untouched: elapsed_seconds stays exact on the wire,
  server-side bucketing unchanged. ZERO .go files in the diff across all
  three commits.

SUITES at 4b97749 (re-derived by the reviewer, not read from the report)
- Node board/web: 169/169 pass, 0 fail (base 129/129 at 7b05cb7, +40)
- Go board/: 85/85 pass, go vet exit 0 (verified untouched at r3 by file
  list; last run at c5858df)
- Pester scripts/tests: 227 total, 222 passed, 0 failed, 5 skipped
  (attached: 223/227, 4 skipped; the 5th is the detached-HEAD skip)
- Citation gates: 41 passed, 4 informational skips, 0 failed
- Pester scripts/probes: 24/24; probe-yard-snapshot.mjs PASS (exit 0)

GATE HISTORY
- r1 REJECT, 1 Major / 3 Minor - trains terminality read only stateRegister,
  so a train rendering a hot or unrecognised OUTCOME chip could be capped
  with zero residual signal.
- r2 REJECT, 1 Major / 1 Minor - the r1 fix silently vacuated the landed
  declaredNotObserved guard (deleting it went 73/73 green).
- r3 APPROVE, 0 Major / 0 Minor - guard re-armed and re-derived by the
  reviewer (42/43, self-naming AssertionError); three of four predicate
  axes proven armed by fault injection, the fourth documented as
  unarmable-by-construction defence-in-depth.

#40 EVIDENCE (real Chromium, real Go server, real scratch store)
  hotOutcomeChipColor rgb(255, 74, 58) = --needs-attention, on a
  register-nominal car chip - the exact r1 defect shape, now surviving the
  cap. Selector proven unambiguous (1 of 5 .car-outcome elements).
  Screenshot: docs/screenshots/2026-07-26-view-67-candidates/lane-filters.png

CI: no CI run exists for the car branch; the conductor watches the
post-merge run to a terminal conclusion per the watch-to-terminal rule.
```

**BASE-DELTA vs `7b05cb7` (final form)** — what an unconfigured user sees:
1. Dispatches lane: capped to 4 returned rows plus every non-terminal row, with a `.history-summary` line reading **"showing last N of M returned - full record in the store"**.
2. Trains lane: capped the same way, summary reading **"showing last N of M - full record in the store"** (no noun).
3. Trains capping spares any train with a hot or unrecognised **outcome**, not just a hot state.
4. Every rendered duration is compact clock time — dispatch elapsed and lane freshness lines alike.
5. New `div.history-summary` element in two lanes (visible to anything scraping the board's DOM or text).
6. `yardInventoryCount` can now exceed the visible unassigned row count (deliberate full-set honesty count).
Go, wire, schema, register semantics and lane order are byte-identical to `7b05cb7`.

**NOTE-R3-1 (not a finding):** the commit message quotes `058780bef…` as the "before and after" sha256 for its injection cycle. That is `c5858df`'s `render.js` hash — truthful for the moment the cycle ran (before the isolation comment was added), but not the committed file's hash, which is `B15A0DF3…`. Naming which state a quoted hash belongs to would remove the ambiguity. The substance is independently confirmed: I re-derived the same behaviour at HEAD with my own before/after hash.

**NOTE-R3-2 (forward-looking):** `verify-lane-filters.mjs` uses `querySelector` (first match) for the hot chip. Unambiguous today (1 of 5, measured); if a future fixture adds a second hot outcome it would silently pick one. The script is explicitly evidence, never a gate, so this is a maintenance note only.

Files: `<repo>-wt\review-view-67\board\web\js\render.js`, `<repo>-wt\review-view-67\board\web\test\render.test.js`, `<repo>-wt\review-view-67\board\web\verify-lane-filters.mjs`, `<repo>-wt\review-view-67\docs\screenshots\2026-07-26-view-67-candidates\lane-filters.png`.

```starcar-artifact
outcome: APPROVE
task-id: view-67-review-r3
findings: 0 Major, 0 Minor, 2 Notes. Round 1 was 1 Major / 3 Minor; round 2 was 1 Major / 1 Minor.
  MAJOR-R2-1 PRESENT (fixed), re-derived by the reviewer rather than read: deleting "if (train.declaredNotObserved.length &gt; 0) return false;" at 4b97749 now yields 43 tests 42 pass 1 fail in render.test.js (169 to 168 whole-dir), the failing test being the queued pin with verbatim "AssertionError: a train with an undelivered manifest member must render regardless of recency, actual false, expected true". The identical deletion was 73/73 GREEN at c5858df, which was precisely the round-2 finding. Guard re-armed.
  MINOR-R2-1 PRESENT (fixed): render.test.js:620's fixture car now carries outcome 'done', a wire-realistic shape; one edit closed both findings as instructed.
  NOTE-3 PRESENT (fixed): verify-lane-filters.mjs:78 captures document.querySelector('.car-outcome.register-needs-attention') and :93-95 emit text, class and getComputedStyle color. Re-ran the harness: hotOutcomeChipColor rgb(255, 74, 58). I CHALLENGED the unambiguity claim rather than accepting it - on the live page there are 5 .car-outcome elements and the hot selector matches exactly 1, the other 4 being done/register-nominal, so the comment's claim is true.
  FULL AXIS SWEEP re-run, not just the one finding: declaredNotObserved guard RED (42/43, self-naming); outcomeRegister axis RED (2 tests, hot-error and unrecognised-word, verbatim reasons); cars.length guard RED (1 test, zero-car); stateRegister axis GREEN, which is expected and correct - in round 2 NOTE-1 I stated this conjunct cannot be isolated by any wire-realistic fixture and explicitly did NOT ask for its removal, and the car documented it at isTrainTerminal instead of papering over it. Every claim in that comment verified: assemble.go:113-114 is the ONLY assignment to a TrainCar Outcome and is guarded by state=="returned"; upstream board/fold/algorithm.go:214 sets entry.Outcome only inside case "returned"; schema/starcar-artifact.schema.json requires outcome/findings/abstract for kind=returned, pinned by vector invalid-returned-missing-outcome.json; and the stated malformed-feed scenario (state overdue with outcome done) really would reintroduce MAJOR-R1-1 if the conjunct were removed. Correct disposition of an unpinnable guard: keep it and leave a note so a future round does not read FI-green as dead code.
  NOTE-R3-1 the commit message quotes sha256 058780bef... as "before and after" for its injection cycle; that is c5858df's render.js hash, truthful for the moment the cycle ran (before the isolation comment was added) but not the committed file's hash, which is B15A0DF3.... Naming which state a quoted hash belongs to would remove the ambiguity. Substance independently confirmed by my own re-derivation at HEAD.
  NOTE-R3-2 verify-lane-filters.mjs uses querySelector (first match) for the hot chip; unambiguous today at 1 of 5 measured, but a future fixture adding a second hot outcome would silently pick one. The script is explicitly evidence and never a gate, so this is a maintenance note only.
abstract: Round 3 delta re-review of 4b97749 (parent c5858df verified) under the cap I set in round 2. Zero Majors, so the cap does not trigger and I rule on the merits: APPROVE. Byte-clean exit - render.js SHA256 B15A0DF3655147E7B073C9EE016AF8CFCFAC90F1234CC6ED015958A32E715E77 identical before and after four fault injections, git status empty, stash empty, HEAD unchanged, nothing committed or pushed. THE DECISIVE CHECK WAS RE-DERIVED, NOT READ: deleting the declaredNotObserved guard now produces 42 of 43 in render.test.js with the queued pin failing for its exact stated reason, where the identical deletion went 73/73 green at c5858df - the round-2 finding is closed and the inverse is measured in both directions. I re-ran my ENTIRE round-2 axis sweep rather than only the named finding, confirming the fix armed one axis without disarming another: three of four predicate guards now fail under isolated injection, and the fourth (stateRegister) is green exactly as I predicted and sanctioned in round 2, now documented in code as defence-in-depth against a wire shape the schema forbids today. Every claim in that new comment was opened and verified through both chain links (fold/algorithm.go:214 sets Outcome only for returned winners; assemble.go:113-114 is the only TrainCar Outcome assignment and is state-guarded; the artifact schema requires outcome for kind=returned with a conformance vector pinning it), and the stated malformed-feed regression scenario checks out. SUITES at 4b97749: Node board/web 169/169 pass 0 fail 0 skipped; Pester scripts/tests 227 total 222 passed 0 failed 5 skipped with the fifth being the predicted detached-HEAD skip; citation gates 41 passed 4 informational skips 0 failed; probes 24/24; probe-yard-snapshot PASS exit 0; zero .go files in the diff verified by file list and not re-run per instruction. FULL-DIFF AUDIT confirms the scoped four paths only and ZERO coordinate-shaped citations introduced - every added reference is by filename or symbol and each was opened. #40 floor now satisfied by the COMMITTED harness itself rather than only by a reviewer's probe: hotOutcomeChipColor rgb(255, 74, 58) equal to the needs-attention token, on a register-nominal car chip, which is the round-1 defect shape surviving the cap; I challenged the selector's unambiguity claim and measured 1 match of 5 .car-outcome elements. Screenshot opened and read - hot-outcome train renders first with a red error chip, trains summary carries the owner's no-noun wording, store path normalised with no operator home directory leaked. CONVERGENCE: 1 Major / 3 Minor, then 1 Major / 1 Minor, then 0 and 0 - declining monotonically in count and severity, the round-2 finding closed by the exact prescribed edit, no new defect introduced. Every swirl trigger that fired in round 2 has cleared and the cap retires unused. Merge-message block, final BASE-DELTA against 7b05cb7, and the CI note (no run exists for the car branch; conductor watches post-merge to a terminal conclusion) are supplied in the verdict body.
```