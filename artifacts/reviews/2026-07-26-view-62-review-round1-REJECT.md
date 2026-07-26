<!-- starcar-integrity: sha256=c266123ad0c094d518fb728ebb7c3a4493f3e3e04a89e0e2cdb1eb98d462ff62 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car view-62 review - round 1 (REJECT)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial review with computed-style + HAVAGLANCE fault-injection gate
Round: 1
Target: `commit 45b0e12 on car/view-62 (#62 shared visual language)`
Base reviewed: `45b0e12455979ca8b51555cdb2a19e352aa9be84`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `ae6398614a373c807`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `45b0e12455979ca8b51555cdb2a19e352aa9be84` |

| Dispatch, the locator within the session | `ae6398614a373c807` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 45b0e12455979ca8b51555cdb2a19e352aa9be84
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Cleanup verified, worktree clean. I have everything I need.

---

# ADVERSARIAL REVIEW — view-62-review-r1

# VERDICT: **REJECT** (3 Major, 1 Minor, 4 Notes)

**Base verified FIRST:** worktree `<repo>-wt\review-view-62` at `45b0e12455979ca8b51555cdb2a19e352aa9be84`, parent `878619a`. Matches the brief. Worktree clean at start and at end.

**#13 BASE-DELTA:** Round 1. Base for all deltas is `878619a` ("harness: land server-27-29 r4 verdict + index"). No prior rounds.

---

## Suite counts — observed by me, at `45b0e12`

| Suite | Car claimed | **I observed** | |
|---|---|---|---|
| `board/web` `node --test` | 80/80 (71 base + 9) | **80 pass / 0 fail** | ✅ |
| `board/web` base at `878619a` | 71 (derive yourself) | **71 pass / 0 fail** — derived independently | ✅ |
| Go `board/...` | 73/73 | **73 top-level PASS / 0 FAIL** | ✅ |
| `scripts/tests` | "194/0/1 detached" | **193 pass / 1 FAIL / 1 skip / 195 total** | ❌ **MAJOR-1** |
| `scripts/store-checks` | store-sized | **204/0/0** | ✅ |
| `scripts/probes` | 24 | **24/0/0** | ✅ |

Base derivation method (disclosed fault injection): `git checkout 878619a -- board/web/{css,js,test}` + `rm verify-registers.mjs`, ran, then `git checkout HEAD -- board/web`. Revert verified byte-identical — `git status --short` empty, `git diff HEAD --stat` empty, HEAD unchanged.

**Diff scope:** `git show --stat` — 9 files, all under `board/web/` or `docs/`. Zero server/schema/compose-semantics files. `compose.js`, `lanes.js`, `board/**/*.go`, `schema/**` all untouched. ✅ No automatic Major on scope.

---

## MAJOR-1 — This commit turns a CI gate RED, and the report claims it green

`scripts/tests/CodeCitationPolicy.Tests.ps1:293` **fails at `45b0e12`**:

```
Expected 0, because extension(s) [.png] appeared in the post-boundary corpus with no
citation check and no declared exemption - decide: extend $CodeExtensions or
$DeclaredExemptExtensions, do not leave it silent, but got 1.
```

**Attribution is unambiguous and 100% this commit's:**

```
git diff --name-only --diff-filter=A d4db6f5..878619a | grep -c '\.png$'  -&gt; 0   (base GREEN)
git diff --name-only --diff-filter=A d4db6f5..45b0e12 | grep '\.png$'     -&gt; 2
    docs/screenshots/2026-07-26-register-check-candidates/calm-yard.png
    docs/screenshots/2026-07-26-register-check-candidates/hot-yard.png
```

These are the **first post-boundary `.png` files in the repo**. `$CodeExtensions` (line 214) and `$DeclaredExemptExtensions` (lines 217-220: `.json`, `.md` only) cover neither.

The brief anticipated `CodeCitationPolicy` gating the new `.mjs` — that test **passes** (the `#62` citation is present, `verify-registers.mjs:1`). The break is `.png`, which the car did not anticipate and, per its own claim of `0` failures, did not run.

Two defects in one: a CI-blocking red, and a verification claim (`194/0/1`) that contradicts observation (`193/1/1`). The gate fired exactly as `#42` round 3 designed it to — that is the instrument working, and it is a success outcome for the gate.

**Fix is one line** in `$DeclaredExemptExtensions` with its reason inline, per the gate's own instruction. Car's call, not mine.

---

## MAJOR-2 — The HAVAGLANCE failure survives, in the very mechanism the commit claims fixes it, undisclosed

This is the centerpiece. I constructed it rather than reasoned about it.

**Construction:** scratch store = every real `artifacts/` record + one subject `zzzz-lost-probe-sorts-last` holding a `presumed-lost` record. Sorts last by `board/fold/algorithm.go:150` (`sort.Strings(subjects)`), so it lands at the bottom of the grid. `presumed-lost` is `needs-attention` in the liveness vocab (`schema/vocab/board-defs.json`). Real Go server, real Chromium, 1920x1080.

**Measured (computed style, real browser):**

```
totalRows: 90        rowsGeometricallyVisible: 35
gridBox: top 97, bottom 273, height 176      gridScrollHeight: 440
hotRowCount: 1
  text:  "zzzz-lost-probe-sorts-lastpresumed-lost"
  color: rgb(255, 74, 58)          &lt;- needs-attention red
  rect:  top 515, bottom 537       &lt;- 242px BELOW the grid's clip edge
  insideGrid: false     VISIBLE_WITHOUT_SCROLLING: false

ALL_LANES:
  lane-dispatches  register-nominal  borderLeft rgb(217,213,201)  title rgb(217,213,201)  "Live"
  lane-gates       register-nominal  borderLeft rgb(217,213,201)  title rgb(217,213,201)  "Live"
  lane-trains      register-nominal  borderLeft rgb(217,213,201)  title rgb(217,213,201)  "Live"
  lane-freight     register-nominal  ...  "Dark"
  lane-fuel        register-nominal  ...  "Bagged"
footerConditions: null
```

**A yard holding a `presumed-lost` dispatch renders a board with not one hot pixel.** I have the screenshot: every lane plate paper-white, every left border paper, all three live lanes reading `idle, quiet 1870s`. The board says *quiet*. From across a room an operator sees a calm yard.

**Answering the brief's sub-question directly:** the lane register does **not** go hot. `render.js:137` composes the lane register from position × freshness × capability only (`compose.js:73-79`); row-level `stateRegister` (`render.js:214`) never enters `mostSevereRegister`. So most-severe-wins does not save the glance here — nothing saves it.

**Counterfactual (runtime style override, no file edited) — the clip is the cause:**

```
.solari-rows { max-height: none !important; overflow-y: visible !important; }
-&gt; hotRow top 515, bottom 537, color rgb(255,74,58), hotRowInViewport: TRUE
-&gt; footerBottom 1068, WHOLE_BOARD_FITS_1080: TRUE
```

At the store size the car itself measured, `max-height: 11rem` is what converts a visible alarm into an invisible one — **and removing it costs nothing**, the whole board still fits in 1080px with 12px to spare.

**Why this is Major and not a NOTE.** Three reasons, and I weighed the counterweight first:

- *The counterweight, stated honestly:* the lane-register semantics are **pre-existing** (`compose.js` untouched — verified, not in diff), and fixing them would be a register-semantics change that #62's scope explicitly forbids. Pre-#62 the row was also off-screen. The car was right not to fix it.
- But the commit **asserts it fixed the HAVAGLANCE failure** ("the exact 'doesn't help much' HAVAGLANCE failure this ticket exists to fix"), and `docs/design/2026-07-23-ui-mockup-brief.md:40-41` sets the acceptance test: *"glanced at from across a room, not studied: one pass must tell an operator whether anything needs them."* Measured, it does not.
- The justification written into the repo is **materially inverted**. `board/web/css/board.css:400-404`:

&gt; `EVERY row is still in the DOM and still reachable (Law 1: "visible, never hidden", same posture as the #30 collapsed-but-present conditions strip)`

  The #30 collapse is Law-1-safe **precisely because severity escapes it**: `dom-writer.js:121` renders `&lt;summary class="board-conditions-summary register-needs-attention"&gt;` carrying `"1 FLAG + 2 notes"` (`render.js:104-108`). The `.solari-rows` scroll clip has **no roll-up whatsoever** — measured `footerConditions: null`. The one property that licenses #30's pattern is the one property the new bound lacks. Left standing, the next car reads this as settled doctrine: *"bounding a lane with `overflow` is Law-1-safe because #30 does it."* That is a Chesterton's fence planted backwards.

**What would have cleared this:** an honest stop / disclosed limitation routed to #1 — exactly what the car did for two *lesser* gaps (store-counts, lane order). It had the mechanism in hand and did not apply it to the largest hole its own change creates. Undisclosed-and-load-bearing.

---

## MAJOR-3 — Dead citations in landed code, on the evidence trail for the largest change

`board/web/css/board.css:399` and `board/web/css/board.css:427` both cite:

```
board/web/test/screenshots-62/calm-real-store.png
board/web/test/screenshots-62/
```

**That directory does not exist.** `ls board/web/test/` — no `screenshots-62`. `git ls-files | grep -i screenshot` returns only `regenerate-screenshot.mjs`, `2026-07-23-first-light.png`, and the two new candidates. It is not gitignored (`.gitignore` covers `node_modules/`, `.claude/probe-logs/`, `testResults.xml`, `__pycache__/`, `.ci-checks/`). Repo-wide grep finds no other reference.

These two citations are the stated evidence for MAJOR-2's mechanism — the claim that the 79-record store blew out the frame. The evidence *was* produced and *does* live in the commit, at `docs/screenshots/2026-07-26-register-check-candidates/`. The comments point at a scratch path that never landed. A reader cannot open either. Documents rank equal to code; a dead citation in the justification for the commit's most consequential change is a defect, not a typo.

---

## MINOR-1 — "routed to issue #1" where nothing was routed

`board/web/js/dom-writer.js:83-92` states the store-counts wire-field gap is *"routed to issue #1."* `gh issue view 1 --comments`: the last comments are the owner's, dated 2026-07-23. **Nothing from this car.**

The lane-order direction-vs-contract conflict is worse: I verified the car correctly did **not** reorder (`board/web/js/lanes.js` untouched; `EXPECTED_LANE_IDS` unchanged at line 13 — ✅ correct behavior), but repo-wide grep finds **no in-repo record of the conflict at all**. `dom-writer.js:17-19`'s generic *"Further slices ... remain open on issue #1"* does not name it. The README ADJUDICATION section covers fonts, demo vocabulary, and fixed canvas only.

Carrier rule: obligations cross rungs in documents with IDs, never by memory. A routing that lives only in a car's report evaporates when the report scrolls off. Discharge by actually commenting on #1 before merge.

---

## NOTES (not blockers — shared-language scope was honored; owner's "iterate as we go" applies)

- **N1 — DEMO banner de-emphasised.** `board.css` diff: `background: var(--in-progress); color:#14181d; font-weight:700` at inherited ~16px → `background: transparent; border: 1px solid; font-size: 0.75rem`. A solid amber block became a 12px outline. Still present, still the in-progress token, still reads "DEMO DATA" — but it is a measurable reduction of a Law-1 honesty surface on a wall display. Owner's eye should rule.
- **N2 — Subject truncation is hover-gated.** In the calm screenshot five separate rows all read `2026-07-22-ca…` — truncated to mutual indistinguishability. `#62` *introduced* this (base CSS had no `nowrap`/ellipsis). The `title` tooltip is hover-only and a wall display has no cursor. **Correct priority though:** `.solari-state { flex: none }` (`board.css:441`) means the VERBATIM state word — the thing carrying severity — is never truncated. Only identity is lost, not severity.
- **N3 — The gates lane renders an empty content pane** in both screenshots (plate populated, right-hand area blank). Honest (`gates: []`) but reads as a rendering hole rather than a stated absence, unlike freight's *"no equipment on this lane"* and fuel's *"data held, not surfaced"*.
- **N4 — Lane count relocated to dim footer.** Header (inherited size) → footer at `0.8rem` / `--text-dim` (`rgba(217,213,201,0.55)`). Still chrome, still rendered, test-pinned. Not stale doc-wise (see below).

---

## Premise checks (#46) — I tested the brief's assertions rather than confirming them

- **Brief implied the car's blowout claim needed verifying. It is TRUE, emphatically.** Runtime-restoring the base `.solari-rows` rule against the real store: `footerBottom: 2743`, and `gates y=2232 / trains y=2356 / freight y=2520 / fuel y=2613` — **four of five lanes off a 1080px screen**. The car's discovery is real, correctly diagnosed, and the multi-column grid is the right instinct. Credit where measured.
- **Brief asked whether the lane plate goes hot to save the glance.** I did not assume either way — I measured. It does not. Reported above with computed values.
- **Doc-staleness premise tested and REJECTED.** `docs/design/2026-07-21-v0-yard-skeleton-design.md:197` says *"lane count rendered in chrome"*. I opened it: "chrome" there means honesty chrome generally, not the header element; the footer strip is chrome (the code names it *"footer honesty-chrome strip"*). And `docs/design/2026-07-23-ui-mockup-brief.md:85` specifies the wording `"registry declares 5 lanes"` — the car's new string `registry declares 5 lane(s) - 5 rendered` is **closer** to the brief than the old `5 of 5 lanes`. **No doc-staleness finding.** I looked for one and it was not there.

---

## The register contract — computed rgb, real browser, real server, BOTH states

Ran the car's own `board/web/verify-registers.mjs` (inspected first: it drives the **real** Go server via `startRealBoardServer`, real `artifacts/` store for calm, `buildScratchStoreWithInFlightDispatch` for hot — no mock, no fixture page).

| Token | Contract hex | calm-yard | hot-yard |
|---|---|---|---|
| `--nominal` | `#d9d5c9` | `rgb(217, 213, 201)` | `rgb(217, 213, 201)` |
| `--in-progress` | `#ffb454` | `rgb(255, 180, 84)` | `rgb(255, 180, 84)` |
| `--needs-attention` | `#ff4a3a` | `rgb(255, 74, 58)` | `rgb(255, 74, 58)` |
| ground | `#0b0c0e` | `rgb(11, 12, 14)` | `rgb(11, 12, 14)` |

**Byte-identical to contract in both states.** ✅

**Quiet-when-calm:** calm-yard — all five lanes `register-nominal`. ✅
**Most-severe-wins at lane level:** hot-yard — `dispatches`/`gates`/`trains` → `register-needs-attention` (staleness axis), `freight`/`fuel` stay nominal. ✅ *(Note: the car's "hot" evidence is hot from* staleness*, not from a hot row — which is what let MAJOR-2 hide.)*

**Three-color law — exhaustive enumeration of every color literal in `board.css` (10 total):**

```
#0b0c0e #15181d #0a0b0c #242830 rgba(255,255,255,0.03)   &lt;- structural neutrals
#d9d5c9 (x2)  rgba(217,213,201,0.55)                     &lt;- paper + alpha-dim of the SAME token
#ffb454  #ff4a3a                                          &lt;- the other two registers
```

**No fourth alarm color.** The car's claim that `--text-dim` is "alpha on the same paper token, not a second gray" is verified: `217,213,201` = `#d9d5c9`. ✅

---

## Tests

**9 new, 0 deleted, 0 modified** — `git show HEAD -- board/web/test/ | grep -c "^-[^-]"` → **0**. No test line removed anywhere. 6 in `dom-writer.test.js`, 3 in `render.test.js`.

Red-first plausibility: each new test asserts a structure that provably does not exist at `878619a` — `.brand`, `.board-footer`, `.lane-plate`/`.lane-content`, `.lane-ordinal`, `.lane-purpose`, `title` on `.solari-subject`, `vm.purpose`, `vm.storePathDisplay`. I confirmed by running the base suite: 71 tests, none of these selectors present in base `dom-writer.js`. Plausible reds. ✅

Guards still guarding, all inside the passing 80: `#30` conditions-strip tests (`dom-writer.test.js:162+`, plus the new footer-placement test), `#29` idle-calm (`compose.test.js:82, 185`), `#31` Playwright cascade guard (`browser-register-cascade.test.js:71, 84` — **unmodified**, not in diff). ✅

---

## Deviations / routing

| Item | Claimed location | Verified |
|---|---|---|
| Fonts = system stacks, no network fetch | `board.css` header + README ADJUDICATION | ✅ Both present. `grep` for `fonts.googleapis`/`gstatic`/`@import`/`http` across `board/web/{css,js,index.html}` → **zero hits**. D19 honored. |
| Demo vocabulary not adopted | README ADJUDICATION | ✅ Present; `compose.js`/`vocab.js` untouched |
| Fixed canvas not adopted | README ADJUDICATION | ✅ Present; `@media (max-width:760px)` exists at `board.css:459+` |
| Lane order → #1 | (nowhere) | ❌ **MINOR-1** — no reorder (correct), no record (missing) |
| Store counts → #1 | `dom-writer.js:83-92` | ⚠️ Comment present, **nothing on #1** — MINOR-1 |

**Citations (`#62` bare):** `board.css` 9, `dom-writer.js` 5, `render.js` 2, `dom-writer.test.js` 7, `render.test.js` 4, `verify-registers.mjs` 2. Every changed unit cites. ✅ (The gate agrees — the *citation* test passes; only the closed-set test fails.)

**Absolute paths in diff:** none. `git show HEAD -- board/web docs | grep -E "C:\\\\Users|/c/Users|/home/[a-z]+/"` → zero. ✅
**First-light screenshot:** `docs/screenshots/2026-07-23-first-light.png` present, not deleted. ✅

---

## THE JUDGMENT HALF — my HAVAGLANCE ruling, in plain words

**The looks half: genuinely better, and not templated.** The shared language landed. Wordmark reads at distance; the numbered plates with purpose subtitles are the single best thing here — a stranger now learns what "freight" *means* without asking; the near-black ground is properly dark-room; the footer strip gathers the accounting line where it belongs. Compared to the owner's *"horrible looking"*, this is a real answer.

**The help half: better for the calm case, and I cannot certify it for the alarm case — which is the only case that matters.**

The improvement is real and I measured it: five lanes on one screen instead of four pushed 1,100px below the fold. On a calm yard, one pass genuinely tells you the yard is calm. That is more than the board did yesterday.

But HAVAGLANCE is not "can I see the layout." It is *"can I have a glance and understand everything it is trying to tell me."* On a yard holding a `presumed-lost` dispatch, this board's glance says **quiet**. It is not that the alarm is hard to find in under a second — **there is nothing to find.** Zero hot pixels, five calm plates, three lanes reading *"idle, quiet."* The one-hot-element-findable test cannot be scored because no hot element renders.

And the specific mechanism is the irony: the bounded grid that fixed the crowding is what clips the alarm, on a screen with 280px of unused black below the footer, at a store size where the bound buys nothing. The car traded a board that hid four lanes for a board that hides the alarm.

**None of that makes the bound wrong** — at 300 records it will be necessary, and the real fix (severity roll-up into the lane plate, or hot-rows-first ordering) is register semantics and correctly outside this ticket. What was owed was **disclosure**: name the hole, route it to #1, and do not write a Law-1 justification into the CSS claiming the #30 precedent covers it when the #30 precedent's safety property is exactly what is missing. The car disclosed two smaller gaps and not this one.

Fix MAJOR-1 (one line), MAJOR-3 (repoint two paths), and MAJOR-2's *disclosure* (correct the `board.css` comment, route the hole to #1 with the measurement above), and this is an APPROVE. The visual work is sound and the premise was true.

---

## Constitution check

| Law / rule | Honored? |
|---|---|
| **Law 1 (no confident falsehood)** | ❌ Three ways: the `194/0/1` claim vs observed `193/1/1` (MAJOR-1); a calm-rendering board over a `presumed-lost` dispatch, justified by an inverted #30 analogy (MAJOR-2); two dead path citations (MAJOR-3). |
| **Three-register law** | ✅ Exhaustively verified — 10 color literals, no fourth alarm color, `--text-dim` is alpha on the paper token. |
| **HAVAGLANCE** | ❌ Passes for calm, fails for alarm. Ruled above. |
| **Law 6 (no second copy)** | ✅ `LANE_PURPOSE` is client-side fixed prose keyed by the closed registry (Car 4's precedent), not a copy of wire data; the car explicitly *declined* to invent store-counts client-side for this reason (`dom-writer.js:83-92`); `verify-registers.mjs` reuses the one `startRealBoardServer` rather than hand-rolling a second. |
| **Law 7 (the stranger)** | ✅ Purpose subtitles materially help a cold reader; `storePathDisplay` rendered publication-safe; no absolute paths; an unrecognised 6th lane id gets **no** guessed purpose (`render.js:26`, test-pinned). |
| **D19 (no build step / no network)** | ✅ System font stacks, zero webfont fetch, verified by grep. |
| **Honesty chrome survival** | ⚠️ All elements survive — demo banner (header), freshness lines (plate), conditions strip (footer, test-pinned, severity in `&lt;summary&gt;`), declared/rendered counts (footer). Two de-emphasised (N1, N4). |
| **Carrier rule** | ❌ MINOR-1 — routings asserted in code, absent from #1. |
| **Red-first TDD** | ✅ 9 additions, 0 deletions, 0 modifications; base 71 derived independently. |
| **Scope boundary (#62 ruling)** | ✅ CSS/layout/markup + dom-writer only. `compose.js`, `lanes.js`, Go, schema all untouched. |
| **Showcase never edits the record** | ✅ First-light screenshot retained. |

---

## UNREPRODUCIBLE-EVIDENCE callout (#13)

Three observations a later party cannot re-derive byte-identically, with recipes:

1. **My attack store was a temp dir, now deleted.** Recipe: copy `artifacts/` to a scratch dir, add `zzzz-lost-probe-sorts-last/presumed-lost-1.json` (shape per `schema/vectors/valid-presumed-lost.json`), `STARCAR_STORE_PATH` it, load at 1920x1080. Probe scripts retained at `~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\15c84ef1-8e84-4d98-aacd-17cce34752cb\scratchpad\{havaglance-attack,counterfactual,premise}.mjs` (scratchpad, not the repo — session-scoped).
2. **Time-dependent values** in my screenshots (`idle, quiet 1870s`, `80 in yard inventory`) drift with wall clock and store growth. The register hexes and the calm/hot lane-class sets do not.
3. **Font resolution is box-specific.** `Bahnschrift` resolved here (Windows). On a box without it the display face degrades to `Arial Narrow`/`sans-serif` — by design, and the car documented it, but my `brandFontFamily` reading is this box's.

Nothing in MAJOR-1, MAJOR-2, or MAJOR-3 depends on any of the above: MAJOR-1 is two `git diff --diff-filter=A` commands, MAJOR-2's核 is `insideGrid:false` + five `register-nominal` classes reproducible from the recipe, MAJOR-3 is `ls`.

---

**I edited nothing, committed nothing, pushed nothing.** Two disclosed runtime interventions, both reverted: the base-count checkout (byte-identical revert proven by empty `git status`/`git diff HEAD`) and `.review-scratch-62/` (untracked, removed). Final worktree state clean at `45b0e12`.

```starcar-artifact
outcome: REJECT
task-id: view-62-review-r1
findings: |
  3 Major, 1 Minor, 4 Notes. Any Major = REJECT.

  MAJOR-1 (CI-blocking red + false verification claim): scripts/tests/CodeCitationPolicy.Tests.ps1:293
  FAILS at 45b0e12 - "extension(s) [.png] appeared in the post-boundary corpus with no citation
  check and no declared exemption". Attribution is 100% this commit: post-boundary .png count is
  0 at base 878619a and 2 at HEAD (the two new screenshots are the repo's first post-boundary
  PNGs). Car claimed scripts/tests 194 pass / 0 fail / 1 skip; I observed 193 / 1 / 1.
  Fix: one entry in $DeclaredExemptExtensions (board/web ... scripts/tests/CodeCitationPolicy.Tests.ps1:217).

  MAJOR-2 (the HAVAGLANCE failure survives, undisclosed, inside the mechanism claimed to fix it):
  Constructed a scratch store = real artifacts/ plus one presumed-lost subject sorting last
  (board/fold/algorithm.go:150). Measured in real Chromium against the real Go server at
  1920x1080: 90 rows in DOM, 35 geometrically visible, grid clip box 176px tall vs 440px of
  content; the single hot row renders rgb(255,74,58) at y 515-537, i.e. 242px BELOW the clip
  edge, insideGrid false, VISIBLE_WITHOUT_SCROLLING false. Decisively, ALL FIVE lanes read
  register-nominal with paper borders and titles, and the conditions summary is null - a yard
  holding a presumed-lost dispatch renders with ZERO hot pixels and three lanes reading
  "idle, quiet". The lane register cannot save the glance: render.js:137 composes it from
  position x freshness x capability only (compose.js:73-79); row-level stateRegister
  (render.js:214) never enters mostSevereRegister. Counterfactual (runtime override, no file
  edited): lifting max-height makes the hot row visible at y 515 with footerBottom 1068, so the
  whole board still fits 1080 - the clip is the cause and buys nothing at this store size.
  The written justification is materially inverted: board/web/css/board.css:400-404 invokes
  Law 1 "visible, never hidden, same posture as the #30 collapsed-but-present conditions strip",
  but #30 is safe precisely because severity escapes its collapse via a register-coloured
  summary (dom-writer.js:121, render.js:104-108); the solari scroll clip has no roll-up at all.
  Underlying semantics are pre-existing and out of #62 scope - what was owed was DISCLOSURE,
  which the car supplied for two lesser gaps and not for this one. Acceptance criterion missed:
  docs/design/2026-07-23-ui-mockup-brief.md:40-41.

  MAJOR-3 (dead citations in landed code, on the evidence trail for the largest change):
  board/web/css/board.css:399 and :427 cite board/web/test/screenshots-62/calm-real-store.png
  and board/web/test/screenshots-62/. That directory does not exist, is not tracked, and is not
  gitignored. Repo-wide grep finds no other reference. The evidence does exist, at
  docs/screenshots/2026-07-26-register-check-candidates/ - the comments point at a scratch path
  that never landed, so a reader cannot verify the commit's central factual claim.

  MINOR-1 (carrier rule): board/web/js/dom-writer.js:83-92 states the store-counts gap is
  "routed to issue #1", but issue #1 carries no comment from this car (last comments are the
  owner's, 2026-07-23). The lane-order direction-vs-contract conflict has NO in-repo record at
  all, though the car correctly did not reorder (board/web/js/lanes.js untouched,
  EXPECTED_LANE_IDS unchanged at line 13).

  NOTES (non-blocking, shared-language scope honored): N1 DEMO banner de-emphasised from solid
  amber fill at inherited size to a transparent 0.75rem outline - a Law-1 honesty surface made
  quieter. N2 subject truncation renders five rows identically as "2026-07-22-ca...", and the
  title tooltip is hover-only, useless on a wall display; correct priority though, since
  .solari-state flex:none keeps the VERBATIM state word untruncated. N3 the gates lane renders
  an empty content pane rather than a stated absence, unlike freight and fuel. N4 lane count
  moved from header to 0.8rem dim footer text.

  VERIFIED CORRECT, reported as measured wins: the car's central premise HOLDS - restoring the
  pre-#62 .solari-rows rule at runtime puts footer at y 2743 with gates/trains/freight/fuel at
  y 2232/2356/2520/2613, four of five lanes off a 1080px screen. Register tokens byte-identical
  to contract in BOTH states (nominal rgb(217,213,201), in-progress rgb(255,180,84),
  needs-attention rgb(255,74,58), ground rgb(11,12,14)). Three-colour law holds under exhaustive
  enumeration of all 10 colour literals in board.css - no fourth alarm colour, and --text-dim
  is verified alpha on the same paper token. Quiet-when-calm holds. Diff scope clean: 9 files,
  board/web plus docs only, zero server/schema/compose-semantics change. Zero tests deleted or
  modified, 9 added, base independently derived at 71/71 and HEAD at 80/80. Go 73/73,
  store-checks 204/0/0, probes 24/0/0. No network font fetch anywhere (D19 honored). No absolute
  paths in the diff. First-light screenshot retained. Doc-staleness premise TESTED AND REJECTED:
  both "chrome" references mean honesty chrome generally, and the new lane-count wording is
  closer to the brief's own text than the string it replaced.
abstract: |
  Adversarial sentence-check review of car view-62-car-r1, one commit (45b0e12) against
  issue #62's owner-ruled shared-visual-language scope. Base verified first; worktree clean
  at start and end; nothing edited, committed or pushed. Two disclosed runtime interventions,
  both reverted byte-identically (a base-count checkout, and a scratch output dir).
  REJECT on 3 Majors. The visual work is sound and the car's blowout premise is true - I
  reproduced it and four of five lanes really were off-screen before this commit. But the
  commit turns CodeCitationPolicy red on its own new PNGs while reporting zero failures; it
  cites screenshot evidence at a path that does not exist; and a real-browser fault injection
  shows a presumed-lost dispatch rendering a board with zero hot pixels and every lane calm,
  clipped by the new bounded grid, justified in-repo by a #30 analogy that is inverted because
  #30's collapse carries a severity roll-up this one lacks. The underlying register semantics
  are pre-existing and correctly out of scope; what was missing was disclosure, which the car
  supplied for two smaller gaps and not for the largest. All three Majors are cheap to fix.
```