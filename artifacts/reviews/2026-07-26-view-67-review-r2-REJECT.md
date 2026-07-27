<!-- starcar-integrity: sha256=0d3a6ab6a7228ed83d27444fa3f740386a87d6e6d56d1146bc532ecb6ff400e7 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# View train #67 lane-filters car review, round 2 (delta)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial delta re-review
Round: 2
Target: `car/view-67 HEAD c5858df (fix commit on ae1bd02)`
Base reviewed: `7b05cb770980e3116f8b289371fdcd0334a570ab`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

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

# DELTA RE-REVIEW — view #67 car, round 2

**Verdict: REJECT** (1 Major, 1 Minor, 3 Notes)

Worktree `<repo>-wt\review-view-67`, detached at `c5858df`, parent confirmed `ae1bd02`. Byte-clean exit: `render.js` SHA256 `058780BEF5921841510DFA54368ED79CD8DBD551A3024B26B4BC2F239B05D966` before and after all injections, `git status --short` empty, HEAD unchanged, nothing committed or pushed.

**The round-1 Major is genuinely and verifiably FIXED.** The REJECT is for a *new* defect this round's own fix created — measured, not inferred.

---

## Suites at `c5858df` — re-derived

| Suite | Observed | Car claimed |
|---|---|---|
| Node `board/web` whole-dir | **169 tests, 169 pass, 0 fail** (+7 vs 162 at `ae1bd02`) | 169/169 ✅ |
| `go test ./...` in `board/` | **85 `--- PASS`, 0 `--- FAIL`** | 85/85 ✅ |
| `go vet ./...` | exit **0** | clean ✅ |
| Pester `scripts/tests` | **227 total, 222 passed, 0 failed, 5 skipped** | 223/227 attached; my 5th skip is the detached-HEAD one, exactly as predicted ✅ |
| Citation gates (both files) | **41 passed, 4 skipped (informational), 0 failed** | green ✅ |
| Pester `scripts/probes` | **24 total, 24 passed, 0 failed** | 24/24 ✅ |
| `probe-yard-snapshot.mjs` | `PROBE RESULT: PASS`, exit 0 | PASS ✅ |
| Go files in `ae1bd02..c5858df` | **none** | untouched ✅ |

---

## R1 finding dispositions

| ID | Disposition | Evidence |
|---|---|---|
| **MAJOR-R1-1** | **PRESENT (fixed)** | `render.js:231` now `c.stateRegister === 'nominal' &amp;&amp; c.outcomeRegister === 'nominal'`. FI-1 (revert to state-only) → **2 red**, verbatim: *"a train with a hot OUTCOME (error, needs-attention) must never be capped, regardless of every car's state being returned"* and *"an unrecognised outcome word (Law 1 fallback: needs-attention) must never be capped - unknowns are hot by law"*. Comment at `render.js:196-226` now states **both** axes explicitly. REJECT control asserts the train *is* capped and 4-of-6 render — no special case. |
| **MINOR-R1-1** | **PRESENT (fixed)** | Comment now reads: the closed-set claim *"belongs to board/fold alone, never to the schema"*, and names `$defs.dispatchesPayload` as declaring `state` an open string per Law 7. Re-verified true: the schema property is `{"type": "string"}`, no enum; `board/fold` closes it (`algorithm.go:139` + `:240`). |
| **MINOR-R1-2** | **PRESENT (fixed)** | `render.js:299` now `17:09`, matching the comment's own body text and `format.js:1`'s `17:16` convention. Consistent. |
| **MINOR-R1-3** | **DRIFTED** | Two pins landed and read correctly. The **zero-car** pin is non-vacuous (FI-4 → red, self-naming). The **unrecognised-car-state** pin is **over-determined**: FI-3 (delete the entire `stateRegister` axis) leaves it green. See MAJOR-R2-1. |
| **NOTE-1** | **PRESENT (fixed)** | `historySummaryLine(hidden, total, noun = '')`; trains pass no noun, dispatches pass `'returned'`. Both pinned by dedicated tests, and both observed live (below). |

---

## MAJOR-R2-1 — this round's fix silently vacuated a landed round-1 guard

**Measured, both directions.** With `if (train.declaredNotObserved.length &gt; 0) return false;` deleted from `isTrainTerminal`:

- at **`ae1bd02`** (round 1): **1 test RED**, naming itself — `#67: a train with an undelivered manifest member ("queued") always renders - declaredNotObserved is never terminal` → `AssertionError: a train with an undelivered manifest member must render regardless of recency`
- at **`c5858df`** (round 2): **73/73 GREEN**

The guard can now be deleted with zero red. Its test passes for the wrong reason: the fixture at `render.test.js:611` is `carFixture('member', 'returned', '2020-01-01T00:00:00Z')` — **no outcome** — so `outcomeRegister` is `null`, and the new outcome conjunct makes the train non-terminal regardless of `declaredNotObserved`. This is the "fold that LOOKS folded" class the carrier rule exists to catch, and it is the swirl signature the calibration rule names most sharply: *a defect the previous round's own fix created*.

**Full axis-by-axis fault-injection scorecard of the trains predicate at `c5858df`:**

| Conjunct | Injection | Result |
|---|---|---|
| `cars.length &gt; 0` | FI-4 removed | **RED** (1 test) — pinned ✅ |
| `outcomeRegister === 'nominal'` | FI-1 removed | **RED** (2 tests) — pinned ✅ |
| `stateRegister === 'nominal'` | FI-3 removed | **73/73 GREEN** — unpinned ❌ |
| `declaredNotObserved` guard | FI-2 removed | **73/73 GREEN** — unpinned ❌ |

Cause: three fixtures whose non-terminality is the thing under test now carry no outcome — `render.test.js:587` (`rolling-car`, `dispatched`), `:611` (`member`, `returned`), `:747` (`c-hot`, `quarantined`) — plus `dom-writer.test.js:678`. Each is non-terminal via the outcome-null path, so none isolates the cause in its own title.

**Why Major.** The production code is correct and I say so plainly. But a landed guard that cannot fail is, by this repo's own severity philosophy, worse than none: a future car deleting that one line ships green, and the owner's explicitly-named "queued" category — *"a train with an undelivered manifest member is the owner's 'queued', never terminal"* — silently starts being capped. That is a live, reachable severity escape inside the very feature under review, and the commit message claims the opposite (*"pinned two conservative-path tests ... so they stay true"*).

**Remedy is one word:** give the `queued-ancient` fixture car `outcome: 'done'`. That also makes it *wire-realistic* — see NOTE-2, which shows the current fixture models a state the real wire cannot produce.

---

## MINOR-R2-1 — the `train:queued-ancient` fixture models an unreachable wire state

`render.test.js:611` has a car with `state: 'returned'` and **no** `outcome`. That combination cannot occur on the real wire: `board/assemble/assemble.go:113-115` sets `car.Outcome = d.Outcome` **only** when `d.State == "returned"`, and `schema/starcar-artifact.schema.json` requires `["outcome", "findings", "abstract"]` when `kind == "returned"` (pinned by conformance vector `schema/vectors/invalid-returned-missing-outcome.json`). A returned car always carries an outcome. Fixing MAJOR-R2-1 fixes this in the same edit.

---

## THE CAR'S SELF-CAUGHT DISCLOSURE — adjudicated: **handled correctly, disclosure accurate**

The coordinator's concern was that outcome-less cars could make the trains filter a silent no-op (the opposite failure direction). I probed the **real** repo `artifacts/` store through the **real** Go server:

```
REAL STORE: trains on the wire = 1
cars total=10  returned+outcome=10  returned+NO outcome=0  non-returned=0
outcome words observed on the real wire: [["done",5],["APPROVE",5]]
declaredNotObserved non-empty trains: []
```

**Zero outcome-less returned cars.** The no-op risk does not materialize. Structurally it *cannot*, for valid records: `outcomeRegister === 'nominal'` ⟹ outcome present and recognised ⟹ (via `assemble.go:113`) `state == "returned"` ⟹ `stateRegister === 'nominal'`. The car's comment claim — that the artifact schema requires `outcome` for every `kind=returned` record, so an outcome-less returned car would itself be a discovery — is **verified true**, and the conservative show-the-row treatment is the right direction for that malformed case.

**The fixture edits are legitimate, not test-weakening.** `carFixture` gained an *optional* outcome, preserving the outcome-less form for genuinely-outcome-less `dispatched` cars. Adding `done` to `dom-writer.test.js`'s `outcomeDefs` makes the test vocab a subset of the real `board-defs.json` (`{"id":"done","register":"nominal"}`); I grepped and **no** test depended on `done` being unrecognised — the unrecognised-word pins use `quarantined` as a *state*, untouched.

---

## #40 rendering floor — computed style, real browser, real Go server

The car's harness captures no computed style for the outcome chip, so I wrote my own Playwright probe. Observed at `c5858df`:

```
trackTitles[0]: "Lane filter hot-outcome train (train:lane-filter-hot-outcome)"   &lt;- survives, renders first
hotOutcomeChip: text "error", cls "car-outcome register-needs-attention", color rgb(255, 74, 58)
hotStateChip:   cls "car-chip register-nominal",                          color rgb(217, 213, 201)
calmOutcomeChip:text "done",  cls "car-outcome register-nominal",         color rgb(217, 213, 201)
TOKEN_needs_attention: rgb(255, 74, 58)   TOKEN_nominal: rgb(217, 213, 201)
trainsSummary:     "showing last 4 of 5 - full record in the store"
dispatchesSummary: "showing last 4 of 11 returned - full record in the store"
```

`rgb(255, 74, 58)` = `--needs-attention: #ff4a3a` (`board.css:41`), **distinct** from nominal — and it sits on a `register-nominal` car chip, which is precisely the r1 defect shape now surviving the cap. Re-ran the car's own `verify-lane-filters.mjs` too (out-dir outside the worktree, deleted after): 6 tracks with `t1` capped, `solariRowCount: 6`, elapsed `57579:18:15`, dispatches summary color `rgb(217, 213, 201)`.

---

## Full-diff citation audit

**Car's claim verified: zero numeric `file:line` citations introduced or shifted.** Every added reference is by filename or symbol — `board-defs.json`, `dom-writer.js`, `real-board-server.js`, `render.js`, `vocab.js`, `yard-snapshot.schema.json`, `starcar-artifact.schema.json`, `verify-lane-filters.mjs`. I opened each claim: `board-defs.json` pins REJECT nominal / error needs-attention ✅; `renderTrains` renders `car-outcome ${registerClass(car.outcomeRegister)}` ✅ (observed live); `vocab.js`'s Law-1 fallback returns needs-attention ✅; the artifact schema's `kind=returned` branch requires `["outcome","findings","abstract"]` ✅; `$defs.trainsPayload` makes car `outcome` optional (`required: ["subject","role","state","at"]`) ✅. No dead or shifted citation found. Only `render.js` changed in `js/`, so no other file's line-numbered comments could drift.

---

## #13 mandatory fields

**BASE-DELTA vs `7b05cb7` (updated for r2)** — an unconfigured user sees:
1. Dispatches lane capped to 4 returned + every non-terminal row, with a `.history-summary` line reading **"showing last N of M returned - full record in the store"**.
2. Trains lane capped the same way, with the summary reading **"showing last N of M - full record in the store"** — **no noun** (this is the r2 wording change; r1 rendered "returned" here).
3. Trains capping now also spares any train whose car carries a hot or unrecognised **outcome**, not just a hot state — strictly *more* rows visible than at `ae1bd02`.
4. Every rendered duration is compact clock time (`4:32`, `1:02:03`), dispatch elapsed and lane freshness alike.
5. New `div.history-summary` element in two lanes.
6. `yardInventoryCount` can exceed the visible unassigned row count (full-set count, deliberate).
Go, wire, schema, registers and lane order remain identical to `7b05cb7`.

**UNREPRODUCIBLE-EVIDENCE:**
- The causation proof for MAJOR-R2-1 used `git archive ae1bd02 | tar -x` into the scratchpad with `node_modules` copied in, then a `sed` injection — **not** a git worktree, to avoid mutating shared `.git` metadata. Directory deleted after.
- All four HEAD injections (FI-1..FI-4) were edits to the worktree `render.js`, each reverted; the SHA256 above is the proof they were byte-identical.
- Real-wire numbers (1 train, 10 cars, `done`×5/`APPROVE`×5) are a snapshot of `artifacts/` at `c5858df` and will change as the store grows; the *structural* argument (`assemble.go:113` + schema requirement) is the durable claim.
- Elapsed digits (`57579:18:15`) are `now`-relative; the format is the reproducible claim.
- Probe scripts live in the scratchpad; `reviewer-scratch-r2` out-dir deleted.

**NOTE-1:** The `stateRegister` conjunct is, on the real wire, *logically implied* by the outcome conjunct (shown above), so no wire-realistic fixture can pin it in isolation. Keeping it is sound defence-in-depth against a foreign producer emitting an outcome on a non-returned car — I am **not** asking for it to be removed, and I name this so a future round does not mistake FI-3's green for dead code.
**NOTE-2:** The trains summary now reads "showing last 4 of 5" with no noun — correct per the owner's exact ticket wording, and slightly more abstract on screen than the dispatches line. Working as ruled.
**NOTE-3:** `verify-lane-filters.mjs` captures a computed color for `.history-summary` but not for the car outcome chip that is this round's whole point. Adding one `getComputedStyle` line would make the harness self-sufficient for the #40 floor instead of relying on a reviewer's separate probe.

---

## CONVERGENCE RULING

Mechanically, the swirl trigger **fires**: Major count is flat (1 → 1); findings cluster in the same section (trains terminality and its pins); and round 2's finding is a defect round 1's own fix created — the sharpest of the three. I flag that rather than hide behind it.

**My judgment is that this is convergence, not swirl**, and I state the reasoning so it can be disagreed with: the r1 Major was a live severity escape in shipped rendering, closed definitively with fault-injected pins and real-browser computed-style proof; the r2 Major is a regression-vault vacuity whose remedy is adding one field to one fixture. Severity moved down an order of magnitude even though the count did not.

**Per the rule, I set a CAP: round 3 is the last.** If a round 3 produces another Major in the trains-terminality area, it escalates to the owner rather than a round 4.

---

## Constitution check

| Law / rule | Evidence |
|---|---|
| **Law 1 (unknown renders as unknown)** | ✅ **now honored** — unrecognised outcome word keeps its train visible; pinned (FI-1 red) and observed in Chromium at `rgb(255,74,58)`. |
| **Law 4 / absence-blindness** | ✅ Summary line asserts true counts on both lanes, null when nothing hidden; the hot-outcome train is no longer among the hidden. |
| **Law 6 (no second copy)** | ✅ One `historySummaryLine` with an optional noun rather than two near-duplicate strings; one `capTerminalHistory`; one `formatClockDuration`. |
| **Law 7 (no hardcoded taxonomy)** | ✅ Predicate reads composed registers only; MINOR-R1-1's misdescription of the schema's open posture is corrected. |
| **#40 rendering floor** | ✅ Real Chromium, real Go server, computed style, distinct from the nominal token. |
| **TDD / non-vacuity** | ❌ **VIOLATED** — MAJOR-R2-1: two conjuncts of the predicate under review have no failing test, one of them a regression from round 1. |
| **Carrier rule (folds marked, not drifted)** | ⚠️ MAJOR-R1-1 / MINOR-R1-1 / MINOR-R1-2 / NOTE-1 folded cleanly with IDs in comments and test names; MINOR-R1-3 **DRIFTED**. |
| **Living documents** | ✅ No doc invalidated by this diff; `board.css` and `gating-matrix.md:69-73` re-checked and still true. |
| **#42 code-citation standard** | ✅ Gate green; every new test cites `#67`. |

---

## If round 3 clears: merge-message numbers (do **not** merge on this verdict)

Suites at the round-3 SHA, gate history **r1 REJECT 1 Major / 3 Minor → r2 REJECT 1 Major / 1 Minor → r3**, delivering: dispatches and trains lane history capped at the last 4 by recency with every non-terminal or hot row always visible, hidden history asserted with true counts, and board-wide compact-clock durations — `#27` bucketing and the Go wire untouched (zero `.go` in the diff across both rounds).

Files: `<repo>-wt\review-view-67\board\web\test\render.test.js` (line 611 — the one-word fix), `<repo>-wt\review-view-67\board\web\js\render.js`, `<repo>-wt\review-view-67\board\web\verify-lane-filters.mjs`.

```starcar-artifact
outcome: REJECT
task-id: view-67-review-r2
findings: 1 Major, 1 Minor, 3 Notes. Round 1 was 1 Major / 3 Minor / 3 Notes.
  R1 DISPOSITIONS. MAJOR-R1-1 PRESENT (fixed): render.js:231 now requires stateRegister AND outcomeRegister both nominal; FI-1 reverting to state-only produced 2 red with verbatim "a train with a hot OUTCOME (error, needs-attention) must never be capped, regardless of every car's state being returned" and "an unrecognised outcome word (Law 1 fallback: needs-attention) must never be capped - unknowns are hot by law"; the comment now states both axes; the REJECT control asserts the train IS capped and 4 of 6 render, no special case. MINOR-R1-1 PRESENT (fixed), wording re-verified true: schema $defs.dispatchesPayload declares state as an open string with no enum, closed set belongs to board/fold alone (algorithm.go:139 plus :240). MINOR-R1-2 PRESENT (fixed): render.js:299 now 17:09, consistent with format.js:1's 17:16. NOTE-1 PRESENT (fixed): historySummaryLine gained an optional noun; trains render the owner's exact ticket wording with no noun, dispatches keep "returned"; both pinned and both observed live. MINOR-R1-3 DRIFTED, see MAJOR-R2-1.
  MAJOR-R2-1 this round's fix silently vacuated a landed round-1 guard. Deleting "if (train.declaredNotObserved.length &gt; 0) return false;" from isTrainTerminal produces 73/73 GREEN at c5858df, but produced 1 RED at ae1bd02 naming itself ("a train with an undelivered manifest member must render regardless of recency"). Causation measured in both directions. Cause: render.test.js:611's fixture car is state returned with NO outcome, so outcomeRegister null makes the train non-terminal via the new conjunct regardless of declaredNotObserved. Full axis scorecard by fault injection at c5858df: cars.length &gt; 0 PINNED (FI-4 red), outcomeRegister PINNED (FI-1 red), stateRegister UNPINNED (FI-3 73/73 green), declaredNotObserved guard UNPINNED (FI-2 73/73 green). Three fixtures whose non-terminality is under test now carry no outcome (render.test.js:587, :611, :747; dom-writer.test.js:678), so none isolates the cause in its own title, including the new MINOR-R1-3 unrecognised-car-state pin. Production code is CORRECT and behavior is right; the defect is that a landed guard can no longer fail, so a future edit deleting the owner's explicit "queued" category ships green, while the commit message claims the pins "stay true". Remedy is one word: give the queued-ancient fixture car outcome 'done'.
  MINOR-R2-1 render.test.js:611 models an unreachable wire state (returned with no outcome). board/assemble/assemble.go:113-115 sets car.Outcome only when state == "returned", and schema/starcar-artifact.schema.json requires outcome/findings/abstract for kind=returned, pinned by vector invalid-returned-missing-outcome.json. Fixed by the same edit as MAJOR-R2-1.
  NOTE-1 the stateRegister conjunct is logically implied by the outcome conjunct on the real wire, so no wire-realistic fixture can pin it in isolation; it is sound defence-in-depth against a foreign producer and I am NOT asking for its removal - named so a future round does not mistake FI-3's green for dead code. NOTE-2 the trains summary now reads "showing last 4 of 5" with no noun, correct per the owner's exact ticket wording. NOTE-3 verify-lane-filters.mjs captures a computed color for .history-summary but not for the car outcome chip that is this round's whole point; one getComputedStyle line would make the harness self-sufficient for the #40 floor.
  SELF-CAUGHT DISCLOSURE ADJUDICATED AS CORRECT: the outcome-absent no-op risk does NOT materialize. Probed the REAL repo artifacts store through the REAL Go server: 1 train, 10 cars, returned-with-outcome 10, returned-with-NO-outcome 0, outcome words done x5 and APPROVE x5. Structurally it cannot occur for valid records since outcomeRegister nominal implies outcome present implies state returned implies stateRegister nominal. The fixture edits are legitimate, not test-weakening: carFixture's outcome is optional so genuinely outcome-less dispatched cars keep their shape, and adding 'done' to dom-writer.test.js outcomeDefs matches the real board-defs.json - grep confirmed no test depended on 'done' being unrecognised (the unrecognised pins use 'quarantined' as a STATE).
abstract: Round 2 delta re-review of c5858df (parent ae1bd02 verified) against round 1's REJECT. Byte-clean exit: render.js SHA256 058780BEF5921841510DFA54368ED79CD8DBD551A3024B26B4BC2F239B05D966 identical before and after four fault injections, git status empty, HEAD unchanged, nothing committed or pushed. ALL SUITES RE-DERIVED: Node board/web 169 tests 169 pass 0 fail (plus 7 vs 162 at ae1bd02, car's claim confirmed); Go 85 --- PASS 0 --- FAIL with go vet exit 0 and ZERO .go files in the ae1bd02..c5858df diff; Pester scripts/tests 227 total 222 passed 0 failed 5 skipped with the fifth being the predicted detached-HEAD skip; both citation gates 41 passed 4 informational skips 0 failed; scripts/probes 24/24; probe-yard-snapshot.mjs PROBE RESULT PASS exit 0. THE ROUND-1 MAJOR IS GENUINELY FIXED and I say so without hedging: FI-1 reverting the predicate to stateRegister-only turned both new pins red for their exact stated reasons, and the #40 floor was re-established with MY OWN computed-style probe in real Chromium against the real Go server, because the car's harness captures no color for the chip that is this round's whole point - observed the hot-outcome train surviving and rendering FIRST, its car-outcome chip computed rgb(255, 74, 58) equal to the --needs-attention token and distinct from nominal rgb(217, 213, 201), sitting on a register-nominal car chip, which is precisely the round-1 defect shape now safe. Trains summary observed live as "showing last 4 of 5 - full record in the store" and dispatches as "showing last 4 of 11 returned - full record in the store", both pinned by test. Full-diff citation audit confirms the car's claim of zero numeric file:line citations introduced or shifted; every added reference is by filename or symbol and I opened each one. THE REJECT IS FOR A NEW DEFECT THIS ROUND'S FIX CREATED, measured in both directions: deleting the declaredNotObserved guard produces 73/73 green at c5858df but produced 1 self-naming red at ae1bd02, because three test fixtures whose non-terminality is under test carry no outcome and are now non-terminal via the new outcome conjunct instead of via the guard each test names. Axis-by-axis injection shows cars.length and outcomeRegister pinned, stateRegister and declaredNotObserved unpinned. Production behavior is correct; the loss is that a landed guard can no longer fail, so a future edit deleting the owner's explicit "queued" category would ship green while the commit message claims those pins stay true. Remedy is one word in one fixture, which also fixes MINOR-R2-1's unreachable-wire-state modelling. The coordinator's flagged no-op risk was DISPROVEN by probing the real store through the real server: zero outcome-less returned cars, and the combination is structurally unreachable for valid records. CONVERGENCE: the mechanical swirl trigger fires on all three conditions and I flag it rather than hide behind it, but my judgment is convergence not swirl - the r1 defect was a live rendering severity escape closed with fault-injected and real-browser proof, while the r2 defect is a regression-vault vacuity one field from fixed, so severity moved down sharply even though the count stayed flat. Per the rule I set a CAP: round 3 is the last, and a further Major in the trains-terminality area escalates to the owner rather than a round 4.
```