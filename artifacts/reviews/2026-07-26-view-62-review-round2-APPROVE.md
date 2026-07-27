<!-- starcar-integrity: sha256=e148420ac43f41546d6d5ca891d9e96513f2dabd123ae91525649a42b86af87d covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car view-62 delta re-review - round 2 (APPROVE, mergeable)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial delta re-review, whole-train gate
Round: 2
Target: `commit 2f57022 on car/view-62 (+ waived one-liners 4d3b9bd, 2067c77)`
Base reviewed: `2f57022986a2ccfcc52716fd8cfa8eda54ab7d92`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

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
> Path normalisation: none applied (the body contained no operator-environment paths).

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `2f57022986a2ccfcc52716fd8cfa8eda54ab7d92` |

| Dispatch, the locator within the session | `ae6398614a373c807` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 2f57022986a2ccfcc52716fd8cfa8eda54ab7d92
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

---

# DELTA RE-REVIEW ROUND 2 — view-62-review-r2

# VERDICT: **APPROVE**

0 Major. 1 new Minor (a false number, named below, correctable in one line pre-merge). All four round-1 findings resolved and independently re-verified; accepted N3 implemented red-first. **Mergeable from `2f57022`.**

**Base verified FIRST:** `2f57022986a2ccfcc52716fd8cfa8eda54ab7d92`, parent `45b0e12` (my round-1 HEAD). Matches the brief. Worktree clean at start and at end.

**#13 BASE-DELTA:** Round 1 base `45b0e12` → round 2 base `2f57022`, one fix commit. Round-1 empirical work carried forward; every round-1 measurement re-derived or re-checked below rather than assumed.

---

## Findings table — Present / Absent / DRIFTED

| r1 finding | Status | Evidence |
|---|---|---|
| **MAJOR-1** `.png` gate red + false suite claim | **RESOLVED** | `scripts/tests` **194 pass / 0 fail / 1 skip / 195** at `2f57022`. Fault-injected for non-vacuity. |
| **MAJOR-2** glance hole undisclosed; inverted #30 analogy | **RESOLVED** | `board.css:396-448` rewritten; every citation of my measurements verified accurate; #1 comment exists and carries the item. |
| **MAJOR-3** dead citations | **RESOLVED** | `screenshots-62` gone repo-wide; both repointed; both resolve on disk. |
| **MINOR-1** carrier rule | **RESOLVED** | Both citations by URL; comment opened via `gh api`; items 1 and 2 match exactly. |
| **N3** (accepted) empty gates pane | **IMPLEMENTED** | Red-first verified by me; two-sided test; renders correctly. |
| — | **NEW MINOR-2** | `board.css:437` growth claim is false. Section below. |

**No DRIFT.** I checked each fix for the fold-that-looks-folded failure: every one changes substance, not just words.

---

## Observed counts at `2f57022` — all run by me

| Suite | Brief predicted | **Observed** | |
|---|---|---|---|
| `board/web` `node --test` | 81/81 | **81 pass / 0 fail** | ✅ |
| Go `board/...` | 73 untouched | **73 top-level PASS / 0 FAIL** | ✅ |
| `scripts/tests` (detached) | 194/0/1 | **194 pass / 0 fail / 1 skip / 195** | ✅ exact |
| `CodeCitationPolicy.Tests.ps1` alone | 13/13 | **13 pass / 0 fail** | ✅ |
| `scripts/store-checks` | 204 | **204 pass / 0 fail** | ✅ |
| `scripts/probes` | 24 | **24 pass / 0 fail** | ✅ |

**Zero tests deleted in the delta** (`git show HEAD -- board/web/test/ | grep -c "^-[^-]"` → 0).

---

## M1 — resolved, and I proved the fix is what makes it green

The gate passes. But a passing gate after an exemption was added is exactly the case where the exemption might have *disabled* the check rather than satisfied it, so I fault-injected:

```
Removed ONLY the '.png' line from $DeclaredExemptExtensions
  -&gt; Passed=12 Failed=1
  -&gt; FAILED: "every extension in the post-boundary corpus, INCLUDING extensionless,
             is checked or a declared exemption (the closed set - #42 round 3 MAJOR-3)"
git checkout HEAD -- scripts/tests/CodeCitationPolicy.Tests.ps1
  -&gt; git status --short: EMPTY (byte-identical revert)
  -&gt; Passed=13 Failed=0
```

**Non-vacuity proven, and it reproduces the car's own claimed 13/13 → 12/1 → 13/13 exactly.** The exemption is narrow (`.png` only), carries its reason inline, and the closed-set guard still fires by name on anything else.

The exemption's stated reasoning — that `docs/screenshots/2026-07-23-first-light.png` "already held, uncited, before this citation standard existed" — is **true**; my round-1 measurement showed zero post-boundary `.png` at base while first-light.png exists in the tree, so it predates `d4db6f5`.

**Pass/skip discrepancy trace — confirmed correct.** `git symbolic-ref -q HEAD` fails ⇒ I am detached. `scripts/tests/SessionStartGuardRunner.Tests.ps1:87,96` does `Set-ItResult -Skipped -Because 'detached HEAD (no branch)...'`. So my `193/1/1` at `45b0e12` and the car's `194/1/0` attached are the same 195 total with the same 1 failure — the delta is exactly this one conditional skip. The car's accounting is right.

---

## M2 — the justification now states the truth

I read `board.css:396-448` against reality claim by claim:

| Claim in the rewrite | Verified |
|---|---|
| "rows below the fold ARE still in the DOM and reachable by scrolling, but their severity does NOT escape to any always-visible surface" | ✅ Matches my round-1 measurement exactly |
| "#30's `&lt;summary&gt;` is Law-1-safe because it carries a register-colored roll-up (`render.js:104-108`, `dom-writer.js:121`); this grid has no such roll-up" | ✅ Opened both — correct, and it names the previously-inverted analogy as backwards |
| "hot row sat 242px below this grid's clip edge while every lane read `register-nominal`" | ✅ My numbers, correctly attributed |
| "`render.js:137`'s lane register composes position x freshness x capability only (`compose.js:73-79`); a row's own `stateRegister` never joins" | ✅ Opened both, accurate |
| "footer at y 2743, four of five lanes off a 1080px screen" | ✅ My round-1 counterfactual, correctly attributed |
| "`board/fold/algorithm.go`'s alphabetical sort - out of this ticket's scope" | ✅ Verified line 150 in round 1 |
| "PRE-EXISTING lane-register semantics, not introduced by this rule" | ✅ `compose.js` untouched across both commits |
| Routed to issue #1 by URL | ✅ Opened — see below |

**The #1 comment exists and says more than claimed.** `gh api repos/polecatspeaks/StarCar/issues/comments/5085235534` — id matches the cited anchor, author `polecatspeaks`, created `2026-07-26T20:21:54Z`. It carries **three** items: (1) lane order, (2) footer store-counts, and (3) *"SEVERITY ROLL-UP FOR BOUNDED LANES"* — the largest item, carrying my measurement verbatim and naming the durable fix as a `compose.js` contract change requiring its own reviewed slice.

I also checked the verdict that comment cites: `artifacts/reviews/2026-07-26-view-62-review-round1-REJECT.md` landed at commit `2f2bd04` on `dev` (absent from the `car/view-62` branch I'm detached within, which is why it isn't in my worktree). **Live citation, not dead.**

The round-1 Major was never "the bound is wrong" — it was "the bound is undisclosed and the justification is inverted." Both are now fixed. **Resolved.**

---

## M3 / MINOR-1 — resolved

**M3:** `grep -n "screenshots-62" board/web/css/board.css` → no output; the dead path is gone repo-wide. Both citations now read `docs/screenshots/2026-07-26-register-check-candidates/` (lines 399, 465) and both resolve — directory exists, `calm-yard.png` and `hot-yard.png` both present.

**MINOR-1:** `dom-writer.js:89-94` and `render.js:20-30` both cite the comment URL. I opened it and matched the item numbers: render.js cites "item 1" = lane order ✅, dom-writer.js cites "item 2" = store-counts ✅. The dom-writer comment explicitly names its own prior miss (*"used to say 'routed to issue #1' while nothing had actually been posted there, a carrier-rule miss"*) rather than quietly overwriting it — the showcase-never-edits-the-record posture, correctly applied. `EXPECTED_LANE_IDS` still untouched.

---

## N3 — implemented, red-first verified by me

I did not take the red-first claim on trust. Reverting only the implementation:

```
git checkout 45b0e12 -- board/web/js/dom-writer.js
node --test test/dom-writer.test.js
  -&gt; not ok 13 - #62 N3: an empty-but-live gates lane ... states its absence honestly
  -&gt; # tests 14  # pass 13  # fail 1      (the N3 test is the ONLY failure)
git checkout HEAD -- board/web/js/dom-writer.js    -&gt; status clean
```

`.lane-body-gates-empty` does not exist at `45b0e12` (grep count 0), so the red is genuine and fails for its stated reason. The test is **two-sided** — it asserts the notice appears on `gates: []` *and* is absent when gates exist, so it cannot pass vacuously.

**Rendering spot-check (regenerated `calm-yard.png`):** the gates lane now reads *"no gates in this fold"* in dim italic mono, sitting beside its plate exactly as freight's *"no equipment on this lane"* and fuel's *"data held, not surfaced"* do. The rendering hole I flagged is gone and the dignity convention is consistent across all three absence cases.

**Wording derives honestly:** `dom-writer.js:250` branches on `body.gates.length === 0` — already-in-hand data. It states *what* is true without guessing *why*, and the CSS gives it `--text-dim` italic, not a register color. An empty-but-live lane is correctly not an alarm.

---

## Register contract re-derived at `2f57022`

Real Go server, real Chromium, both states:

| Token | Contract | calm | hot |
|---|---|---|---|
| `--nominal` | `#d9d5c9` | `rgb(217, 213, 201)` | `rgb(217, 213, 201)` |
| `--in-progress` | `#ffb454` | `rgb(255, 180, 84)` | `rgb(255, 180, 84)` |
| `--needs-attention` | `#ff4a3a` | `rgb(255, 74, 58)` | `rgb(255, 74, 58)` |
| ground | `#0b0c0e` | `rgb(11, 12, 14)` | `rgb(11, 12, 14)` |

Byte-identical, unchanged from round 1. Calm: all five lanes `register-nominal` (quiet-when-calm ✅). Hot: dispatches/gates/trains hot, freight/fuel nominal ✅.

**Three-color law:** 9 unique color literals, identical set to round 1 — the N3 rule added no new color (reuses `--text-dim`). No fourth alarm color. ✅

---

## NEW MINOR-2 — the growth number is false (sentence check)

`board/web/css/board.css:437`:

&gt; `append-only (every dispatch session adds records; it grew from ~79 to ~90 rows between this car's two review rounds, the same day)`

**Measured at `2f57022`, real store:**

```
TOTAL_dispatch_rows:  89
yard_inventory_label: "79 in yard inventory (unassigned)"
```

`render.js:239` — `yardInventoryCount: dispatches.filter((d) =&gt; !d.assigned).length`. **79 is the unassigned SUBSET, not a row total.** And my round-1 `totalRows: 90` included the one `presumed-lost` record *I injected* — so the real store held **89 rows in round 1 and 89 rows in round 2.**

The claim conflates two different measurements of the same unchanged store and presents them as growth over hours. **The store did not grow between rounds.** This is the sentence check applied to a number: it crossed from one measurement context into another and became false, and it is the load-bearing evidence for the keep-the-bound decision.

**Why Minor, not Major** — and I want to be explicit rather than let it look like leniency. My round-1 bar for Major was: the claim is load-bearing *and* its falsity changes whether the outcome is correct. Here it does not. The decision it supports survives on an independently-verified second reason (below), and the qualitative core — the store is real and append-only and *will* grow — is true; only the rate is wrong. A wrong number supporting a right decision, disclosed in the open, is a Minor. It must still be fixed: a future car sizing another decision off "79→90 in a day" would be sizing off a growth rate of approximately zero.

**Correction is one comment line, no code change, no re-review needed.** Recommend it lands pre-merge.

---

## MY RULING ON THE KEEP-THE-BOUND CHOICE

**I affirm the car's decision — but on its second reason, not its first.**

Reason (a), the growth argument, is the one I just falsified. Reason (b) is decisive, and **my own round-1 data is what makes it decisive:**

Ordering is alphabetical (`board/fold/algorithm.go:150`), not severity-based. My probe row was visible at y 515 in the counterfactual **only because I happened to name it `zzzz-...` and there happened to be room that day.** Name it `mmmm-...` and it lands mid-list; add records and it slides below 1080 again. So lifting the clip does not buy a *guarantee* that a hot row is visible — it buys a **coincidence that reads like a guarantee**. That is the decorative-guard shape this repo already has a scar for: a protection that passes its read-back while being live-defective. Between a disclosed bound with the real fix tracked, and an undisclosed coincidence that looks solved, the disclosed bound is straightforwardly the better engineering.

So my round-1 counterfactual does **not** demand the lift. It demonstrated that the clip is the *proximate* cause of one specific invisibility — it never demonstrated that removing it produces correctness, and I said so at the time: *"removing the clip is NOT necessarily the right fix."* The car read that correctly.

**One honest caveat for the #1 slice, not a blocker.** With the bound, `footerBottom` sits at **804** of 1080 — roughly **270px of screen is going unused** while 35 of 89 rows show. Raising the cap to consume the available height would strictly increase rows visible at no cost. It creates no guarantee — but no guarantee is available either way, and more-visible is monotonically better than less-visible under that condition. The car's counter (*"a taller number would only look more fixed"*) is a fair worry about breeding false confidence, and it's a genuine design tradeoff rather than a defect. Owner's eye, at #1, alongside the severity roll-up.

---

## CONVERGENCE — I hold the series

| Round | Major | Minor | Notes |
|---|---|---|---|
| r1 | **3** | 1 | 4 |
| r2 | **0** | 1 (new) | 0 |

Testing the swirl trigger honestly rather than by feel — it needs **two** of three:

- *Major counts stop declining?* **No.** 3 → 0.
- *Findings cluster in the same section?* Arguably — MINOR-2 sits in the same `board.css` comment block. Partial.
- *New defects created by the prior round's own fixes?* **Yes** — MINOR-2 is new text written by the fix commit.

One clear indicator plus one partial, against a decisive Major collapse to zero and a severity drop from Major to Minor. **This is convergence, not swirl.** No escalation, no cap. Findings shrank *and* moved down in severity, which is exactly the converging signature.

**Whole-train mergeability from `2f57022`: APPROVED.** Every gate green, every round-1 finding closed with evidence I re-derived myself, the largest structural gap measured, disclosed in-repo, and tracked on #1 for the slice that can actually fix it. The final view car (#28+#12) can roll on this foundation.

Recommended before merge: correct `board.css:437` (one line).

---

## #13 UNREPRODUCIBLE-EVIDENCE

1. **Store-state dependent:** `TOTAL_dispatch_rows: 89` / `79 unassigned` / `footerBottom 804` are true of the store at `2f57022` and will drift as records land. Recipe: `startRealBoardServer({})`, count `.solari-row`, read `.yard-inventory-count`. The 79-vs-89 *conflation* in MINOR-2 is permanent regardless of future totals — the two quantities are structurally different (`render.js:239`).
2. **Time-dependent** values in the regenerated screenshots (`as of 2026-07-26T20:30:24Z`, `idle, quiet 3055s`).
3. **Box-specific font resolution** (`Bahnschrift` resolved here; degrades by design elsewhere).
4. Probe scripts retained in session scratchpad, not the repo: `havaglance-attack.mjs`, `counterfactual.mjs`, `premise.mjs`, `growth.mjs`.

Nothing in this verdict's resolutions depends on the above: M1 is a Pester run plus a fault injection, M3 is `ls`, MINOR-1 is `gh api`, N3 is a revert-and-run.

---

**I edited nothing, committed nothing, pushed nothing.** Three disclosed runtime interventions, all reverted byte-identically with empty `git status` proven after each: the `.png` exemption fault injection, the N3 red-first revert, and a scratch output dir (removed). Final worktree clean at `2f57022`.

```starcar-artifact
outcome: APPROVE
task-id: view-62-review-r2
findings: |
  0 Major, 1 new Minor. All four round-1 findings RESOLVED, each re-verified empirically
  rather than read. Accepted N3 implemented red-first. Mergeable from 2f57022.

  MAJOR-1 RESOLVED (.png gate red + false suite claim): scripts/tests now 194 pass / 0 fail /
  1 skip / 195 at 2f57022 - exactly the detached-HEAD figure the brief predicted. Proved the
  fix is non-vacuous by fault injection: removing ONLY the new '.png' line from
  $DeclaredExemptExtensions returns the gate to 12/1 failing by name on the closed-set test;
  restoring returns 13/13; revert byte-identical. Reproduces the car's claimed 13/13 to 12/1
  to 13/13 exactly. The exemption is narrow, carries its reason inline, and its claim that
  docs/screenshots/2026-07-23-first-light.png predates the standard is true. Pass/skip
  discrepancy trace CONFIRMED CORRECT: git symbolic-ref -q HEAD fails so I am detached, and
  SessionStartGuardRunner.Tests.ps1:87,96 skips by design on detached HEAD - my r1 193/1/1 and
  the car's 194/1/0 attached are the same 195 total with the same 1 failure.

  MAJOR-2 RESOLVED (glance hole undisclosed, #30 analogy inverted): board.css:396-448 rewritten.
  Checked claim by claim against reality - severity does NOT escape the fold, #30's missing
  safety property named correctly with its citations (render.js:104-108, dom-writer.js:121),
  the semantics identified as pre-existing (compose.js untouched across both commits), and every
  one of my round-1 measurements cited accurately (footer y 2743, hot row 242px below the clip,
  zero hot pixels, render.js:137, compose.js:73-79, board/fold/algorithm.go alphabetical sort).
  The #1 comment EXISTS - opened via gh api, id 5085235534, author polecatspeaks, created
  2026-07-26T20:21:54Z - and carries THREE items including the largest, severity roll-up for
  bounded lanes, with my measurement verbatim. The verdict that comment cites also landed
  (commit 2f2bd04 on dev).

  MAJOR-3 RESOLVED: screenshots-62 gone repo-wide; both citations repointed to
  docs/screenshots/2026-07-26-register-check-candidates/ (board.css:399, 465) and both resolve
  on disk.

  MINOR-1 RESOLVED: dom-writer.js:89-94 and render.js:20-30 cite the comment URL; item numbers
  match the live comment (item 1 lane order, item 2 store-counts). The comment names its own
  prior miss rather than quietly overwriting it. EXPECTED_LANE_IDS still untouched.

  N3 IMPLEMENTED: verified red-first myself - reverting only dom-writer.js makes the N3 test the
  ONLY failure (13 pass / 1 fail); .lane-body-gates-empty does not exist at 45b0e12. Test is
  two-sided so it cannot pass vacuously. Renders correctly: calm-yard.png shows "no gates in
  this fold" in dim italic, matching freight/fuel dignity. Wording derives honestly from
  body.gates.length === 0, states what is true without guessing why, and is not register-colored.

  NEW MINOR-2 (sentence check on a number): board/web/css/board.css:437 claims the store "grew
  from ~79 to ~90 rows between this car's two review rounds, the same day". FALSE. Measured at
  2f57022: TOTAL_dispatch_rows 89, yard_inventory_label "79 in yard inventory (unassigned)".
  render.js:239 shows 79 is the UNASSIGNED SUBSET, not a row total, and my round-1 totalRows 90
  included the one record I injected - so the real store held 89 rows in BOTH rounds and did not
  grow. The claim conflates two measurements of one unchanged store and is the load-bearing
  evidence for the keep-the-bound decision. Minor rather than Major because the decision survives
  on an independently-verified second reason and the qualitative core (append-only, will grow) is
  true - only the rate is wrong. One-line comment correction, recommended pre-merge, no code
  change and no re-review needed.

  COUNTS at 2f57022, all run by me: board/web node --test 81 pass / 0 fail; Go 73 top-level PASS
  / 0 FAIL; scripts/tests 194/0/1 detached; CodeCitationPolicy alone 13/13; store-checks 204/0;
  probes 24/0. Zero tests deleted in the delta. Register contract re-derived byte-identical in
  both states (nominal rgb(217,213,201), in-progress rgb(255,180,84), needs-attention
  rgb(255,74,58), ground rgb(11,12,14)); quiet-when-calm holds; 9 unique colour literals,
  identical set to round 1, no fourth alarm colour.

  KEEP-THE-BOUND RULING: AFFIRMED, on the car's second reason not its first. Ordering is
  alphabetical and severity-blind, so lifting the clip buys a coincidence that reads like a
  guarantee, not a guarantee - my probe was visible only because I named it zzzz and there
  happened to be room. That is the decorative-guard shape this repo has a scar for. My round-1
  counterfactual therefore does NOT demand the lift. Non-blocking caveat for the #1 slice:
  footerBottom sits at 804 of 1080, so roughly 270px goes unused while 35 of 89 rows show;
  raising the cap increases rows visible at no cost, creates no guarantee, and is a genuine
  design tradeoff for the owner rather than a defect.

  CONVERGENCE: Majors 3 to 0, severity dropped Major to Minor. Swirl trigger tested honestly and
  NOT met - it needs two of three; Major counts declined decisively (fails indicator a), one
  clear indicator (MINOR-2 is new text from the fix) plus partial clustering. Converging, not
  swirling. No cap, no escalation.
abstract: |
  Round-2 delta re-review of car view-62-car-r1, one fix commit 2f57022 on round-1 HEAD 45b0e12.
  Base verified first; worktree clean at start and end; nothing edited, committed or pushed;
  three disclosed runtime interventions each reverted byte-identically with empty git status
  proven after.
  APPROVE. All three round-1 Majors and the Minor are resolved, and I re-derived each rather
  than trusting the report: the citation gate is green AND proven non-vacuous by fault injection,
  the rewritten justification states the truth with every one of my measurements cited accurately,
  the dead paths resolve, the routing comment actually exists and carries three items, and the
  accepted N3 is red-first verified by reverting the implementation.
  One new Minor: the keep-the-bound argument rests on a growth figure that conflates the
  unassigned yard-inventory subset with total rows - the store held 89 rows in both rounds and
  did not grow. The decision it supports is nonetheless sound, and I affirm it on the independent
  ground that alphabetical severity-blind ordering means no fixed height guarantees hot-row
  visibility, so lifting the clip would buy a coincidence dressed as a guarantee. One-line
  correction recommended pre-merge. Series converging cleanly, 3 Majors to 0; whole train
  mergeable from 2f57022.
```