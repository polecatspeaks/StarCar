<!-- starcar-integrity: sha256=8ff74612f5d17cc6ec22417ffb40bfaa7f24812b4338ea39361ea71692d55a7e covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# View train #67 lane-filters car review, round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review
Round: 1
Target: `car/view-67 HEAD ae1bd02`
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

# ADVERSARIAL REVIEW — view #67 car, round 1

**Verdict: REJECT** (1 Major, 3 Minor, 3 Notes)

Worktree `<repo>-wt\review-view-67`, detached at `ae1bd02` (parent `7b05cb7`) — verified by `git log --oneline -2` before any action. Exited byte-clean: `git status --short` empty, HEAD unchanged.

---

## Suites — re-derived, not read

| Suite | Observed | SHA | Car claimed |
|---|---|---|---|
| Node `board/web` whole-dir (`node --test`) | **162 tests, 162 pass, 0 fail** | `ae1bd02` | 162/162 ✅ |
| Node `board/web` **base** (extracted via `git archive 7b05cb7`, full tree) | **129 tests, 129 pass, 0 fail** | `7b05cb7` | 129/129 ✅ (delta +33) |
| `go test ./...` in `board/` | **85 `--- PASS`, 0 `--- FAIL`** | `ae1bd02` | 85/85 ✅ |
| `go vet ./...` | exit **0** | `ae1bd02` | clean ✅ |
| Pester `scripts/tests` | **222 passed, 0 failed, 5 skipped / 227** | `ae1bd02` | 223/227 attached; the 5th skip is `SessionStartGuardRunner`'s *"detached HEAD (no branch)"* — exactly the predicted extra ✅ |
| Pester `scripts/probes` | **24 passed, 0 failed** | `ae1bd02` | 24/24 ✅ |
| `verify-lane-filters.mjs` (real Chromium + real Go server) | ran clean, evidence below | `ae1bd02` | PASS ✅ |

Both citation gates green on this diff: `CitationResolverPolicy.Tests.ps1` Class A + Class B pass; `CodeCitationPolicy.Tests.ps1` — *"every code file added after the boundary carries a bare `#N` ticket citation"* and the closed-set/extensionless tests all pass (the new `.png` did **not** re-break the closed set that #62 round 1 caught).

**Go untouched — structurally proven:** `git diff --name-only 7b05cb7 ae1bd02` returns 14 paths, **zero** `.go`. The #27 wire contract cannot have moved.

---

## MAJOR-R1-1 — the trains lane can clip a row that renders HOT, including an unrecognised outcome word

**The load-bearing law fails on the axis the car did not consider.** `isTrainTerminal` (`board/web/js/render.js:205-208`) reads **only** `car.stateRegister`. But `render.js:256` also computes `outcomeRegister`, and `board/web/js/dom-writer.js:312-314` renders it as a **separately register-colored chip**:

```js
chip.appendChild(el(doc, 'span', `car-outcome ${registerClass(car.outcomeRegister)}`, car.outcome));
```

A train whose cars are all `returned` (stateRegister `nominal`) but which carries a hot **outcome** is therefore terminal, capping-eligible, and can vanish.

**Observed, through the real code path (`describeVocab`, not my own lookup):**

```
describeVocab('error')      -&gt; needs-attention        (schema/vocab/board-defs.json:17)
describeVocab('BLOCKED')    -&gt; needs-attention        (unrecognised; vocab.js:44, Law 1)

STEP 1 (under cap, renders): car.stateRegister = nominal | car.outcomeRegister = needs-attention
  -&gt; dom-writer.js:313 renders &lt;span class="car-outcome register-needs-attention"&gt;error&lt;/span&gt;

STEP 2 (6 trains, cap 4): visible = ["train:c2","train:c3","train:c4","train:c5"]
  train:HOT present? false
  summary = "showing last 4 of 6 returned - full record in the store"
  LANE register (the only residual signal) = nominal
```

Four sub-cases measured against HEAD: `error` → **CAPPED**; unrecognised `BLOCKED` → **CAPPED**; `done-with-findings` (in-progress) → **CAPPED**; `REJECT` → capped, and that one is **correct** — `board-defs.json:14` pins REJECT to `nominal` by explicit doctrine (*"REJECT and honest-stop are SUCCESS outcomes in this shop"*), so I am **not** raising the REJECT case the brief asked me to attack. It is a non-finding and I disprove it rather than confirm it.

**Why Major, not Minor:**

1. **It contradicts the ticket's own binding words.** Issue #67 scope-extension comment: *"anything hot/unrecognised) are ALWAYS visible"*. Issue body: *"ANY unrecognised state word (unknowns are hot by law and must never be filtered)"*. An unrecognised outcome is rendered hot by `vocab.js:44` and is filtered.
2. **The code comment overclaims.** `render.js:202-204` asserts *"Anything else (rolling, **stalled for adjudication**, an unrecognised car state) is conservatively non-terminal - always visible"*. True for state; false for outcome. A stale claim about the diff's own central property.
3. **There is zero residual signal.** `composeRegister` is untouched (confirmed: `git diff` on `compose.js` shows 0 `composeRegister` hits; its call graph takes position/freshness/capability only), so the lane register stays `nominal`, and the summary line says only *"of 6 **returned**"* — the hidden train's hotness is asserted nowhere. That is the absence-blindness failure Law 4 and the honesty constraint exist to prevent, and `board.css:548-551` in this very diff concedes the lane register "will not reflect a row's severity".
4. **It is real traffic, not hypothetical.** `board-defs.json`'s own `$comment` records that #30 added `completed`/`approve-for-merge` *because a different agent runtime (Copilot) emitted sibling words* — i.e. this repo has already met unrecognised outcome words in production, and the designed response is to render them hot.
5. **Untested.** No test in `render.test.js` or `dom-writer.test.js` exercises a train whose hotness comes from `outcome`.

**Not applicable to dispatches:** `renderDispatches` (`dom-writer.js:372-399`) never renders `outcome`, so a dispatch row's only rendered register is `stateRegister` and `isTerminal: (d) =&gt; d.stateRegister === 'nominal'` (`render.js:328`) matches the rendered severity exactly. The dispatches lane is sound.

---

## Minors

**MINOR-R1-1 — false citation about the schema, at `render.js:321-324`.** The comment claims *"`schema/yard-snapshot.schema.json`'s `$defs.dispatchesPayload` and `board/fold`'s closed liveness set **both enumerate exactly** dispatched/overdue/returned/presumed-lost"*. Opened it: `$defs.dispatchesPayload.properties.dispatches.items.properties.state` is `{"type": "string"}` — **no enum at all**, deliberately, because Law 7 makes an unrecognised value a discovery rather than a validation failure. The `board/fold` half *is* true (`algorithm.go:139` + `algorithm.go:240`), and the **conclusion** ("no `queued` state exists on this wire") is correct — I re-derived it independently: zero `"queued"` literals in `board/fold`, `board/server`, `board/assemble`. So the "queued renders nothing" decision stands. The defect is that the comment asserts the schema *closes* a set the schema deliberately leaves *open* — and that is precisely the reasoning error underneath MAJOR-R1-1.

**MINOR-R1-2 — inconsistent, unmatched timestamp citation.** `render.js:265` cites *"owner 2026-07-26 **21:09**"*. The comment's own body text says `17:09`; its API `created_at` is `2026-07-26T21:10:06Z`. It matches **neither**. `format.js:1` cites `17:16`, which matches its comment's body text exactly. Two citations of the same kind on two different clocks, one of them off by a minute from any real value.

**MINOR-R1-3 — trains terminality coverage gap on two conservative paths.** No test covers a train with an **unrecognised car state**, nor a **zero-car** train, though the dispatches lane has the unrecognised-state equivalent. I probed both at HEAD: unrecognised state → **SURVIVES**; zero cars → **SURVIVES** (`cars.length &gt; 0 &amp;&amp;` guard). Untested, not broken.

---

## Fault injection — every guard watched firing, reverted byte-identical

| # | Injection | Observed red | Verbatim reason |
|---|---|---|---|
| F1 | `render.js:328` → `isTerminal: (d) =&gt; true` | 2 fail / 36 | `AssertionError: an unrecognised state word must never be filtered - unknowns are hot by law` |
| F2 | `isTrainTerminal` → `return true` | 2 fail / 36 | `AssertionError: a train with an in-flight car must render regardless of recency` |
| F3 | `historySummaryLine` null-guard removed | 2 fail / 66 | `expected: null` / `expected: 0` (the "showing 0 of 0" guard) |
| F4 | `formatClockDuration` → `${h}h${m}m${s}s` | **11 fail / 162** | all three owner examples + the no-unit-suffix + compose stale/idle + dom-writer elapsed |

Revert proof — SHA256 identical before and after:
- `render.js` `9DB78DA7201CBEC110D71F9AE347AFEF1FA3682BEE671C1DC9C3FE1EED1C8DCB`
- `format.js` `1C7E215935E53986A91B6F9DFD54E96B26A7214B366E29C47902D55783790F30`
- `history-filter.js` `73E7A23E97A36A5694E957FD096B92C451B8F4C6E5E80264C7A4D8549E06C491`

`git status --short` empty; full suite re-run post-revert **162/162**.

---

## THE SENTENCE CHECK — the summary line, hop by hop

1. **Data** — `capTerminalHistory` (`history-filter.js:41-64`) counts `terminalEntries.length` (**returned only**, never all rows) and `hiddenCount = terminalTotal - keep.size`.
2. **Derivation** — `render.js:225-229` builds `showing last ${shown} of ${terminalTotal} returned`, returning `null` when `hiddenCount &lt;= 0`.
3. **View model** — `render.js:277` (trains) / `render.js:339` (dispatches).
4. **DOM** — `dom-writer.js:281-284` emits `div.history-summary.register-nominal`, appended **outside** `.solari-rows` (`dom-writer.js:377-379`), i.e. above the `max-height: 11rem` scroll clip — so the assertion itself can never be clipped by the thing it discloses.
5. **CSS** — `board.css:464-467` declares **no `color`**; `.register-nominal` (`board.css:302-305`) supplies `var(--nominal)` = `#d9d5c9` (`board.css:39`) unshadowed. The #31 specificity claim is verified: `grep` finds `history-summary` in exactly one CSS rule.
6. **Real browser** (Chromium, real Go server, real scratch store) — observed:
   - `dispatchesHistorySummaryText`: `"showing last 4 of 10 returned - full record in the store"` against a store carrying **12 dispatch rows: 10 returned + 2 hot**. The count is of RETURNED rows, not all rows. ✅
   - `dispatchesHistorySummaryColor`: **`rgb(217, 213, 201)`** = `#d9d5c9` exactly. Car's claim confirmed.
   - `solariRowCount: 6` = 4 capped returned + **both** hot rows (`register-needs-attention`, `overdue`, dated 2020) surviving. ✅
   - trains: 5 tracks = 4 capped + `train:lane-filter-rolling`; summary `"showing last 4 of 5 returned"`. ✅
   - clock format: `"57578:46:23"` (elapsed), `"stale, 520:46:20"` (freshness). ✅
   - Screenshot `docs/screenshots/2026-07-26-view-67-candidates/lane-filters.png` opened and read — corroborates all of the above.

**Clock formatter, independently probed:** `0→0:00`, `5→0:05`, `45→0:45`, `59→0:59`, `60→1:00`, `272→4:32`, `3599→59:59`, `3600→1:00:00`, `3723→1:02:03`, `86400→24:00:00`, `-5→0:00`, `1.9→0:01`, `NaN/null/undefined→0:00`. All three owner examples honored. `grep` over `board/web/js/` for surviving unit-suffix duration renders: **zero hits**; every rendered duration routes through `formatClockDuration`. (`budgetSeconds` is carried in the view model but rendered nowhere — pre-existing, out of scope.)

---

## Living documents — adjudicated, not waved through

- **`board.css:531-556` claim is ACCURATE.** It says #67 closes the return-history-bloat mechanism *for the dispatches grid* but **not** the register-composition gap. Verified: `render.js:328`'s predicate does bound the calm-row count feeding `.solari-rows`; and `composeRegister` is genuinely untouched (0 hits in the `compose.js` diff), so the lane register still cannot reflect row severity. The #1 routing is correct and the no-double-report reasoning holds.
- **`docs/contracts/gating-matrix.md:69-73` SURVIVES.** Its #27 note claims the wire value "stays exact, never rounded", citing `renderDispatches`'s `solari-elapsed` span **by symbol**. Both symbols still exist, and `formatClockDuration` is lossless on integer seconds (`57578:46:23` is exact) — so the claim is still true. **No update owed.**
- **No other doc describes a duration render form** (`grep` across `docs/`, `README.md` for `solari-elapsed`, `stale, N`, `Ns` samples: no hits), and there is no README screenshot to go stale.
- **State ledger: correctly not owed.** No mutable service state and no derived committed artifact is added; this is view-side selection over data already on the wire.
- **Gating matrix: no new row owed** — #67 installs no gate or suppression; the existing Staleness/Idle/Discovery rows' "never suppressed" guarantees are untouched at the *lane* level. (The trains-lane hot-outcome hole of MAJOR-R1-1 is a **defect**, not a disclosed suppression; fixing it is the remedy, not a matrix row.)

---

## #13 mandatory fields

**BASE-DELTA vs `7b05cb7` — what an unconfigured user sees:**
1. Dispatches lane: all-history → at most 4 returned + every non-terminal row, plus a new `.history-summary` line.
2. Trains lane: same, at most 4 fully-returned trains.
3. Every rendered duration switches from `272s` to `4:32` — dispatch elapsed **and** the lane freshness lines (`stale, …` / `idle, quiet …`).
4. **New DOM element** `div.history-summary` in two lanes — anything scraping the board's text sees a new line.
5. **`yardInventoryCount` can now exceed the visible unassigned rows** (my run: "6 in yard inventory" with only 3 unassigned rows on screen). This is *deliberate and correct* — `render.js:338` counts the full set — but it is a genuine, newly-reachable reader-facing discrepancy. See NOTE-2.
Nothing else changed: Go, wire, schema, registers, lane order all identical.

**UNREPRODUCIBLE-EVIDENCE:**
- The base 129/129 was derived from `git archive 7b05cb7 | tar -x` into the scratchpad with `node_modules` copied in — **not** a git worktree, deliberately, to avoid mutating shared `.git` metadata. A first attempt extracting only `board/web` failed (2 suites need repo-relative `artifacts/`/`schema/`); the full-tree extraction is the reproducible form.
- `verify-lane-filters.mjs` writes into `docs/screenshots/&lt;today&gt;-view-67-candidates/` by default; I ran it with `--out-dir=../../../reviewer-scratch-out`, which resolves **outside** the worktree, and deleted the directory afterwards. The worktree screenshot was never overwritten.
- Elapsed values (`57578:46:23`) are `now`-relative and will differ on any re-run; the *format* is the reproducible claim, not the digits.
- The four probe scripts live in the scratchpad, not the worktree; none were committed.

**NOTE-1:** For trains the owner's specified text was *"showing last N of M - full record in the store"* (no "returned"); the car renders "returned" in both lanes. A train is never literally "returned" on the wire — mild wording drift from the ticket, and it is the same word that under-describes the hidden hot train in MAJOR-R1-1. Worth fixing in the same pass.
**NOTE-2:** See BASE-DELTA item 5 — both numbers are true, but a reader glancing at "6 in yard inventory" over 3 visible unassigned rows gets no hint the gap is the cap. HAVAGLANCE-adjacent, not a defect.
**NOTE-3:** Durations past a day render `57578:46:23` (no day field). The owner specified `HH:MM:SS` with leading fields dropped and named no day form, so this is compliant — but it is what a stranger will actually see on this repo's real store.

---

## Constitution check

| Law / rule | Evidence |
|---|---|
| **Law 1 (unknown renders as unknown; no confident falsehood)** | ❌ **VIOLATED** — `vocab.js:44` makes an unrecognised outcome hot by law; MAJOR-R1-1 hides it. Also MINOR-R1-1's false schema claim. |
| **Law 4 / absence-blindness** | ⚠️ **PARTIAL** — the returned-count assertion is true, non-null-guarded and fault-injected (F3); but the hidden hot train is asserted nowhere (MAJOR-R1-1). |
| **Law 6 (no second copy)** | ✅ One `capTerminalHistory` serving both lanes; one `formatClockDuration` serving three call sites; `grep` confirms no surviving duplicate duration formatting. Fixture reuses the single `startRealBoardServer`. |
| **Law 7 (no hardcoded taxonomy / the stranger)** | ✅ in code — terminality reads the composed register, no client-side state-word list (F1/F2 prove the predicate is the only gate). ⚠️ misdescribed in prose (MINOR-R1-1). |
| **#40 rendering floor** | ✅ Real Chromium + real Go server + real scratch store; `getComputedStyle` → `rgb(217, 213, 201)`, not a DOM-class or regex assertion. |
| **TDD / non-vacuity** | ✅ Four injections, 17 tests red across them, every failure message matched its stated reason, all reverted byte-identical (SHA256 stated). |
| **Living documents (same-commit)** | ✅ `board.css` reconciliation verified accurate; `gating-matrix.md:69-73` traced and still true; no stale doc found. |
| **#42 code-citation standard** | ✅ Gate green; every new file (`format.js`, `history-filter.js`, `verify-lane-filters.mjs`, all new tests) carries a bare `#67`. |
| **Showcase never edits the record** | ✅ Screenshot written to a dated candidate dir; no prior screenshot overwritten. |

---

## What must change to clear round 2

Make trains terminality read the **row's full composed severity**, not `stateRegister` alone — the honest form is *"terminal iff `declaredNotObserved` is empty AND every car's `stateRegister` **and** `outcomeRegister` is `nominal`"*, which keeps the Law 7 discipline intact (still reading registers, still hardcoding no words, and REJECT stays capable of aging out because doctrine pins it `nominal`). Pin it with a red-first test for an `error` outcome **and** an unrecognised outcome word, correct the `render.js:202-204` comment to state what the predicate actually covers, and fix MINOR-R1-1's schema claim in the same commit.

Files: `<repo>-wt\review-view-67\board\web\js\render.js`, `<repo>-wt\review-view-67\board\web\js\dom-writer.js`, `<repo>-wt\review-view-67\board\web\test\render.test.js`, `<repo>-wt\review-view-67\board\web\css\board.css`, `<repo>-wt\review-view-67\schema\vocab\board-defs.json`.

```starcar-artifact
outcome: REJECT
task-id: view-67-review-r1
findings: 1 Major, 3 Minor, 3 Notes.
  MAJOR-R1-1 render.js:205-208 isTrainTerminal reads only car.stateRegister, but render.js:256 also computes outcomeRegister and dom-writer.js:312-314 renders it as a separately register-colored chip. A train whose cars are all returned but which carries a hot OUTCOME is therefore terminal and can be capped out of the trains lane. Measured at HEAD through the real describeVocab path: outcome 'error' (schema/vocab/board-defs.json:17, register needs-attention) CAPPED; an UNRECOGNISED outcome word 'BLOCKED' (vocab.js:44 returns needs-attention by Law 1) CAPPED; 'done-with-findings' (in-progress) CAPPED. Under the cap the same train renders span class="car-outcome register-needs-attention". Past the cap it is absent, the summary reads only "showing last 4 of 6 returned - full record in the store", and the lane register stays nominal because composeRegister is untouched, so there is ZERO residual signal. This contradicts issue 67's binding words ("anything hot/unrecognised are ALWAYS visible"; "unknowns are hot by law and must never be filtered") and render.js:202-204's own claim that anything stalled-for-adjudication or unrecognised is conservatively non-terminal. Not hypothetical: board-defs.json's $comment records that issue 30 added 'completed'/'approve-for-merge' because a foreign runtime (Copilot) emitted sibling words, so unrecognised outcomes are observed traffic. Untested. NOT applicable to the dispatches lane, where renderDispatches never renders outcome so the predicate matches the rendered severity exactly.
  DISPROVEN PREMISE, stated plainly: the brief asked whether a REJECT-gate train is wrongly treated as terminal. It is treated as terminal and that is CORRECT - schema/vocab/board-defs.json:14 pins REJECT to register nominal by explicit doctrine ("REJECT and honest-stop are SUCCESS outcomes in this shop"), so capping it clips nothing hot. No finding raised.
  MINOR-R1-1 render.js:321-324 claims schema/yard-snapshot.schema.json $defs.dispatchesPayload "enumerates exactly dispatched/overdue/returned/presumed-lost". Opened it: state is {"type":"string"} with no enum, deliberately open per Law 7. The board/fold half of the citation is true (algorithm.go:139 plus algorithm.go:240) and the conclusion (no queued state on the wire) is correct, independently re-derived by grep across board/fold, board/server and board/assemble for zero "queued" literals. The defect is asserting the schema CLOSES a set it deliberately leaves open, which is the same reasoning error underneath MAJOR-R1-1.
  MINOR-R1-2 render.js:265 cites "owner 2026-07-26 21:09"; the issue comment body says 17:09 and its created_at is 2026-07-26T21:10:06Z, so it matches neither. format.js:1 cites 17:16, matching its comment body exactly. Two same-kind citations on two clocks.
  MINOR-R1-3 no test covers a train with an unrecognised car state, nor a zero-car train, though the dispatches lane has the unrecognised-state equivalent. Probed both at HEAD: both SURVIVE capping correctly. Untested, not broken.
  NOTE-1 the trains summary renders "of M returned" where the owner's specified trains text was "showing last N of M - full record in the store"; a train is never literally "returned" on the wire, and that same word under-describes the hidden hot train in MAJOR-R1-1.
  NOTE-2 yardInventoryCount is correctly computed over the full set (render.js:338) and can now exceed the visible unassigned rows (observed 6 in yard inventory over 3 visible unassigned rows). Both numbers true; no hint the gap is the cap.
  NOTE-3 durations past a day render as 57578:46:23 with no day field. Compliant with the owner's spec, which named no day form.
abstract: Round 1 adversarial sentence-check review of ae1bd02 (parent 7b05cb7), issue 67 dispatches/trains lane history filters plus compact-clock durations. Base verified before any action; exited byte-clean, git status empty, HEAD unchanged, nothing committed or pushed. ALL SUITES RE-DERIVED, NOT READ. Node board/web 162 tests 162 pass 0 fail at ae1bd02; base independently re-derived at 7b05cb7 by git archive full-tree extraction into scratchpad (NOT a git worktree, to avoid mutating shared .git metadata) at 129 tests 129 pass 0 fail, delta plus 33 - car's claim confirmed. Go board/ 85 --- PASS 0 --- FAIL, go vet exit 0; "Go untouched" proven structurally, git diff --name-only returns 14 paths and zero .go. Pester scripts/tests 222 passed 0 failed 5 skipped of 227, the fifth skip being SessionStartGuardRunner's detached-HEAD case exactly as predicted. Pester scripts/probes 24 passed 0 failed. BOTH citation gates green on this diff, including CodeCitationPolicy's closed-set test which the new .png did not re-break. FAULT INJECTION, four guards watched firing and all reverted byte-identical with SHA256 stated before and after: F1 dispatches predicate forced true, 2 red with verbatim "an unrecognised state word must never be filtered - unknowns are hot by law"; F2 isTrainTerminal forced true, 2 red; F3 summary null-guard removed, 2 red on the showing-0-of-0 guard; F4 formatter reverted to unit suffixes, 11 red across format, compose and dom-writer. Full suite re-run post-revert 162/162. RENDERING FLOOR (issue 40) satisfied in real Chromium against the real Go server and a real scratch store: dispatches capped 10 returned to 4 with BOTH 2020-dated needs-attention rows surviving, summary text "showing last 4 of 10 returned - full record in the store" over a 12-row store proving the count is of RETURNED rows not all rows, computed color rgb(217, 213, 201) matching --nominal #d9d5c9 exactly with .history-summary declaring no color of its own (issue 31 specificity discipline verified by grep), trains 5 tracks with the rolling train surviving, durations 57578:46:23 and "stale, 520:46:20". Screenshot opened and read; corroborates. Formatter independently probed across 20 inputs including all three owner examples, zero-pad, hour boundary, negative, fractional, NaN, null and string; grep confirms zero surviving unit-suffix duration renders anywhere in board/web/js. FULL SENTENCE CHECK traced hop by hop for the summary line: history-filter.js:41-64 counts terminal-only, render.js:225-229 derives text and returns null when nothing hidden, render.js:277/339 view model, dom-writer.js:281-284 DOM emission appended OUTSIDE the max-height 11rem scroll clip so the assertion can never be clipped by the thing it discloses, board.css:464-467 plus :302-305 cascade, real-browser computed style. LIVING DOCS adjudicated rather than waved through: board.css:531-556's reconciliation claim verified accurate against the code including that composeRegister is genuinely untouched; gating-matrix.md:69-73's issue 27 "exact, never rounded" claim traced and SURVIVES because it cites by symbol and formatClockDuration is lossless on integer seconds; grep found no doc anywhere describing the old duration form and no README screenshot to go stale; state ledger and gating matrix correctly not owed. One Major blocks: the trains lane's terminality predicate ignores the outcome axis it also renders, so a needs-attention or unrecognised outcome chip can be clipped with no residual signal on any surface. Remedy named: read stateRegister AND outcomeRegister, pin with red-first tests for 'error' and an unrecognised word, and correct the two overclaiming comments in the same commit.
```