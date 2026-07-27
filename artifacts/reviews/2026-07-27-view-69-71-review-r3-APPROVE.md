<!-- starcar-integrity: sha256=5e3b4ddf751f43601f5e70b7e208e71b9cc6df6775e65734a679f45205656a48 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# View train #69+#71 car review, round 3 (delta, capped round)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review (delta re-review, round-2 swirl cap live)
Round: 3
Target: `car/view-69-71 fix-cycle r3 HEAD 4b50a5c`
Base reviewed: `2861bfd8a99d8213ca0058a999ab91706f4ccc9b`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a8928de8b3b8e6b95`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `2861bfd8a99d8213ca0058a999ab91706f4ccc9b` |

| Dispatch, the locator within the session | `a8928de8b3b8e6b95` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 2861bfd8a99d8213ca0058a999ab91706f4ccc9b
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Byte-clean. Writing the round-3 verdict.

---

# VERDICT: APPROVE — 0 Major, 6 Minor

**The cap does not fire.** I found no Major anywhere, and none in the superseded-rendering surface. My round-2 REJECT-ESCALATED condition is not met.

**Base verified.** `git log -1 --format='%H'` → `4b50a5c5513a7b7401188a4b4d41d989aac572a3`, detached, `git status --porcelain` empty. Matches the brief.

## Suites — re-derived by me at 4b50a5c

| Suite | Observed | Car claimed | Verdict |
|---|---|---|---|
| Node `board/web` | **212 tests / 212 pass / 0 fail / 0 skip**, exit 0 | 212/212 | matches |
| Go `board/...` (`-count=1 -v`) | **94 top-level `--- PASS`**, 0 FAIL | 94, unchanged | matches — and correctly unchanged: `git diff 2861bfd..4b50a5c --name-only \| grep -c '\.go$'` → **0** |
| `go vet ./...` | exit 0, no output | clean | matches |
| Pester `scripts/tests` | **227 total / 222 passed / 0 failed / 5 skipped** | 223/0/4 | matches modulo the detached-HEAD skip |
| Pester `scripts/probes` | **24 / 24 / 0 failed** | 24/24 | matches |
| `probe-yard-snapshot.mjs` | `PROBE RESULT: PASS`, exit 0 | PASS | matches |

Fifth skip named, identical to rounds 1 and 2: `run-session-start-guards.sh: agent-pull runner (#50).running the REAL guards prints [ci-baseline]'s marker ONLY when attached to a branch`. Node 208 → 212 (+4: 3 geometry, 1 collapsed-by-default pin).

---

# THE NEW INSTRUMENT — it guards the property, and I watched it fire

`board/web/test/browser-dispatch-row-geometry.test.js` is the geometry regression pin I prescribed in round 2. Ruling: **it is real, not decoration.**

**At HEAD:** 3/3 green.

**Non-vacuity, re-derived by me** — not accepted from the car's report. I restored round 2's own rendering wholesale (`git checkout 2861bfd -- board/web/css/board.css board/web/js/dom-writer.js`; both files, because the fix spans both) and ran the finalized test file unchanged:

```
sha board.css      B4860579BAD2FF26E2752D5F4F153F5BB2E35E7A60F1BB655557481E6F830E6B -&gt; 8C06977D9B1D9A593C36A81C02DE6BE53CA123F6711589DA3F5B00204BF1C8C6
sha dom-writer.js  FC8F5ABD5D56401101FA1CBA08E35F195EE2AB87939CB803243B2E3BCC234B17 -&gt; 3E28D13F38A982236F1BB82B188BD57DD3DB7E7F847AE15BCD936B1D6F207BA9

not ok 1 - ... renders its subject/state/elapsed cluster on ONE visual line
    REGRESSION (MAJOR-R2-1): row 'plain-subject-00' (no disclosure) spans 2 visual lines
    for its subject/state/elapsed cluster - expected exactly 1
not ok 2 - ... zero PLAIN rows cross .solari-rows own clientHeight boundary mid-row
    REGRESSION (MAJOR-R2-1): 1 plain row(s) crop mid-row at .solari-rows' own boundary -
    [{"subject":"plain-subject-03","top":160,"height":51,"hasDisclosure":false,
      "distinctContentTopCount":2,"croppedMidRow":true}]
# tests 3 / # pass 1 / # fail 2
```

Red for **exactly** the two reasons I named in round 2, and the injected row height reads **51px** — the same number my round-2 probe measured. Both files restored, `sha256` identical, `git status --porcelain` empty.

Test 3 (expansion isolation) stays green under the injection. That is honest, not a hole: it guards a different property that round 2's layout happened to satisfy, and the file's own header scopes its non-vacuity claim to "this file's first test".

---

# MAJOR-R2-1 — re-derived with my own round-2 probes, at 4b50a5c

**My probe 3 (18 plain rows, none carrying a superseded entry — the fixture that made round 2 undeniable), 1600px viewport:**

| | round 2 (`2861bfd`) | **round 3 (`4b50a5c`)** | base counterfactual |
|---|---|---|---|
| `distinctRowHeights` | `[51]` | **`[22]`** | `[22]` |
| `containerScrollH` / `clientH` | 210 / 176 (overflowing) | **96 / 96** | 96 / 96 |
| `croppedMidRowCount` | **3** | **0** | 0 |
| `fullyVisibleRows` | 15 of 18 | **18 of 18** | 18 of 18 |

The `flex-wrap: nowrap` runtime override **now changes nothing** — because `.solari-row` no longer sets `flex-wrap` at all. The base value is genuinely restored, not merely compensated.

**My probe 2 (mixed fixture, same paint), per-child:** every plain row reports `nonDisclosureVisualLines: 1` (was 2), and `.solari-row` now holds a single `.solari-row-main` child of `h: 19` carrying the whole cluster on one line at one `top`.

**Real committed `artifacts/` store** (server default resolution, read-only): `distinctRowHeights: [38]` — down from `[73]` at round 2. All 4 rows carry a disclosure, so 38px = 22px cluster + ~16px collapsed summary. That is the owner-ruled cost — one quiet summary line on rows that have history — and nothing more. Structural assertions all hold: `allDirectChildrenAreRows: true`, `allCarsDirectChildrenAreChips: true`, 10 chips / 10 disclosures, `anyDisclosureOpenByDefault: false`.

**Chip side unaffected**, as the car claims and I verified rather than assumed: `.car-chip` measures `h: 23, visualLines: 1` at 4b50a5c, identical to round 2 and identical under the nowrap override. The column-direction change is scoped to `.solari-row`; `.car-chip` keeps `display:flex; flex-wrap:wrap` and `.car-superseded-disclosure` keeps `flex-basis: 100%`, correctly split into two rules (`board.css:387-395`).

**Expansion displaces only by the entry's own height**, measured: `rowH 52` collapsed → the expanded row grows by the entry's box; every other row keeps its height and rows above keep their `top` (geometry test 3, plus my own probe).

---

# MINOR FINDINGS

**MINOR-R3-1 (measured, undisclosed, created by this round's fix) — an EXPANDED superseded entry now wraps to two lines at most desktop widths.** This round moved `white-space: nowrap` off `.solari-row` (where it covered the whole subtree, including the entries) onto `.solari-row-main` (`board.css:636`, now scoped to the cluster only). The entry therefore computes `white-space: normal`. Swept 9 viewports, real Chromium, real server, one expanded entry:

```
vw= 340  cols=285px            entry 256x14  ws=normal ~lines=1  rowH=52
vw= 500  cols=210x2            entry 182x28  ws=normal ~lines=2  rowH=66
vw= 760  cols=219x3            entry 190x28  ws=normal ~lines=2  rowH=66
vw=1024  cols=220x3            entry 191x28  ws=normal ~lines=2  rowH=66
vw=1280  cols=223x4            entry 194x28  ws=normal ~lines=2  rowH=66
vw=1400  cols=253x4            entry 224x14  ws=normal ~lines=1  rowH=52
vw=1600  cols=237x5            entry 209x28  ws=normal ~lines=2  rowH=66
vw=1920  cols=237x5            entry 209x28  ws=normal ~lines=2  rowH=66
vw=2560  cols=237x5            entry 209x28  ws=normal ~lines=2  rowH=66
```

Six of nine, including 1600px and 1920px. At round 2 the same entry at 1600px measured `218x14` — one line. The cluster itself stays one line at every width (`clusterLines=1` throughout), so `MAJOR-R2-1` is genuinely fixed; this is a neighbouring surface.

**I considered Major and declined, with reasons on the page so the call can be second-guessed:** it contradicts no comment, no owner ruling, and no spec — the "One line per row" mockup convention documented at `board.css:628-635` is explicitly about the subject id cluster, and the car correctly moved that comment along with the rule it describes. Nothing is truncated, hidden, cropped, or mis-attributed; Law 1 is not engaged. It manifests only after a reader deliberately clicks a disclosure open, so HAVAGLANCE's glance is untouched. And the one-line rendering it replaces was incidental inheritance from a rule that this round correctly re-scoped, in a layout that was itself rejected. Calling this a Major would fire an owner escalation over a post-click cosmetic wrap that no authority forbids — the autoimmune mode. **Disposition: a one-line `white-space: nowrap` on `.solari-superseded-entry`, or a ticket.** Also worth recording: **the instrument I prescribed does not cover this** — it asserts the cluster's line count and plain-row cropping, not the entry's. A reviewer-specified instrument guards the property named and not its neighbour.

**MINOR-R3-2 (Law 1, comment vs code).** `board/web/test/browser-dispatch-row-geometry.test.js:16` — *"A NARROW viewport (500px) forces .solari-rows' auto-fill grid to a single column"*. The code at `:41` uses `viewport: { width: 340, height: 1000 }`. Measured: at 340px the grid is one 285px column (single column, as claimed); at 500px it is **two** 210px columns — so the comment's stated width would not even produce the property it claims. Wrong number, and wrong about its own consequence.

**MINOR-R3-3 (measured false, self-contradicted three lines later).** `docs/screenshots/2026-07-26-view-69-71-candidates/README.md`, the disclosed-artifact paragraph: *"structurally impossible to fully avoid in a CSS Grid with auto-sized row tracks and mixed-height siblings"*. Measured false — `align-items: start` on `.solari-rows` fully removes it (see the adjudication below), and the README **itself proposes exactly that** in its next sentence. Say "not worth fixing here" or "avoidable with `align-items: start`, deferred"; not "impossible".

**MINOR-R3-4 (caption inaccurate about the image it describes).** Same README, Round 3 section: *"every plain row and the OTHER disclosure row (`with-sup-1`) keep their original one-line height, unaffected."* Measured: `with-sup-1` is a **38px, two-line** row (19px cluster + 13px collapsed summary), never one line. The substance — *unaffected* — is correct and is what geometry test 3 asserts; the *"one-line"* qualifier is false for the one row it is attached to by name. This is the round-2 lesson in miniature: a caption asserting something the measurement contradicts.

**MINOR-R3-5 (the MAJOR-R2-2 audit is one instance short, and its stated reason is wrong for that instance).** I walked every added line across the whole train (`git diff 256d8d5..4b50a5c`) for line-number citations. Five hits, all verified at HEAD:

| Citation | In | Target file edited by this train? | True at HEAD? |
|---|---|---|---|
| `fold.go:112` | `assemble_test.go` | No | Yes — `\tSpend   any` |
| `gating-matrix.md:49` | `dom-writer.js`, `lanes.js` | No | Yes — the "cited by symbol, not line, per #65's own lesson" row |
| `"(line 141)"` | `dom-writer.js:222` | n/a | Quotation of the removed falsehood inside its own correction — not a live citation |
| **`app.js:148`** | `browser-conditions-persistence.test.js` | **YES — `+39/-1` at `256d8d5`** | Yes — `root.addEventListener('toggle', handleConditionToggle, true);` |

The citation itself is **true**, and `app.js` has not been touched since `256d8d5` (`git diff 256d8d5..4b50a5c -- board/web/js/app.js` → 0 files). But the audit's stated justification — *"in files this train never edits"* — is factually wrong for `app.js`, and its stability is circumstantial rather than structural: any future commit inserting above line 148 drifts it silently, and the #65 gate does not check in-range shifts (`CitationResolverPolicy.Tests.ps1:12`). Bounded: the justification lives only in the car's report, not in any committed surface (`grep` for it across the repo returns nothing), so no durable artifact carries the false claim.

**MINOR-R3-6 (false technical claim in a permanent comment; measured no-op).** `board/web/css/board.css:388-391`: *"`flex-basis:100%` in a COLUMN container sizes the cross-axis dimension (HEIGHT, not width), which would be wrong here."* Two errors: in a column flex container the vertical axis is the **main** axis, not the cross axis; and the asserted consequence does not occur. Measured — forcing `flex-basis: 100%` onto `.solari-superseded-disclosure` at 1400px changed **nothing** (`discH` 13 before and after, `rowBoxH` unchanged), because the row's height is content-driven and a percentage basis resolves against an indefinite height. The decision (omit the property) is fine by minimalism; only the reason is wrong. Blast radius zero, which is why this is Minor and not the class MAJOR-R2-3 was.

---

# THE DISCLOSED OUT-OF-SCOPE OBSERVATION — adjudicated

**Is it real?** Yes. Measured at 1400px (4 columns, 9 rows over 3 grid bands):

```
band 1: plain-subject-00..03   rowBoxH 22   mainH 19   mainVisualLines 1
band 2: plain-subject-04,05,06 rowBoxH 38   mainH 19   mainVisualLines 1   &lt;- stretched
        with-sup-0             rowBoxH 38   mainH 19   discH 13
band 3: with-sup-1             rowBoxH 38   mainH 19   discH 13
```

Plain rows measure 38px **only in the band that also holds a disclosure row**. Their content stays one line (`mainH: 19`, one distinct `top`) — the extra 16px is blank box, not wrapped text. Computed `align-items` on `.solari-rows` reads `normal`, which for a grid container behaves as `stretch`.

**Is the README's description accurate?** Yes, on every checkable claim: not content wrapping (confirmed — `mainVisualLines: 1`), caused by grid stretch across a shared row band (confirmed), 38px vs 22px (confirmed exactly), and distinct from `MAJOR-R2-1`'s failure mode (confirmed — no crop, cluster one line, geometry test still green). The one clause that fails is `MINOR-R3-3`'s "impossible to avoid".

**Is it pre-existing?** The **mechanism** predates the entire train: `.solari-rows`' rule is **byte-identical** at `b865cba` and at `4b50a5c` (`display: grid; grid-template-columns: repeat(auto-fill, minmax(13rem, 1fr)); gap: 0.15rem 1.5rem; max-height: 11rem; overflow-y: auto;`) with `align-items` never declared. What is new is the **trigger** — mixed-height siblings — which arrives with `#71`'s feature. The earliest commit where a *disclosure-bearing row* can stretch a plain row is `2861bfd` (round 2), where it was confounded because the wrap regression made every row 73px anyway; `4b50a5c` is the first commit where it is cleanly separable. The README's wording — *"not new to this round's fix … present since MAJOR-R1-1 first shipped round-2"* — is **precisely correct** and does not overclaim pre-existence relative to the train.

**Was not fixing it the right call under the cap?** **Yes.** It is outside all five named findings, it is cosmetic (blank box, no lost or misplaced information, no crop, Law 1 untouched), and a same-round unscoped CSS change to the shared grid rule is exactly the move that produced `MAJOR-R2-1`. Disclosing it and stopping is the correct application of the cap.

**Recommended disposition: TICKET, not live-with, and it is cheap.** Measured, same paint, `align-items: start` on `.solari-rows`: all seven plain rows drop **38px → 22px**, both disclosure rows correctly stay 38px, nothing else moves. One property, fully effective, verified. It wants its own ticket because it touches a shared grid rule that governs the whole dispatches lane and deserves its own geometry assertion — the same lesson this train paid three rounds for.

---

# FIVE-ID TABLE

| ID | Ruling | Evidence |
|---|---|---|
| **MAJOR-R2-1** (flex-wrap wraps every row; #62 crop hazard) | **Present** | `.solari-row` no longer sets `flex-wrap` (`board.css:640-646`); cluster moved to `.solari-row-main` (`dom-writer.js:533,541-548`), a no-wrap `display:flex` wrapper; `.solari-row` is `flex-direction: column`. My round-2 probe 3 re-run: 18 plain rows `[22]` (was `[51]`), scrollH 96 == clientH 96 (was 210 vs 176), **0 cropped** (was 3), 18/18 visible. Real store `[38]` (was `[73]`). `.car-chip` unchanged at 23px/1 line. New instrument reds on round 2's own CSS+DOM for both stated reasons, `height: 51` in the failure payload. |
| **MAJOR-R2-2** (`"(line 141)"` false at commit time) | **Present** | `dom-writer.js:136-141` now cites `renderBoard` **by symbol** with the falsehood recorded rather than erased. Full-train audit of added lines found 5 line-number citations; all 5 verified true at HEAD (`fold.go:112` → `Spend any`; `gating-matrix.md:49` → the #65-lesson row; `app.js:148` → the listener). Residual instance and wrong justification → `MINOR-R3-5`. |
| **MAJOR-R2-3** (schema/ingest overclaim) | **Present** | `dom-writer.js:142-166` now states the `$def` is unenforced on the runtime hop, names `$defs.lane.data` and the schema's own `$comment` as the reason, names `WirePayload.Tests.ps1` as the sole consumer, and says the renderer filter is the **entire** runtime protection. Re-measured at 4b50a5c with the real vendored cfworker validator: `kind:7` → `valid=true`, `missing at` → `valid=true`. Every claim true. No leak: `grep` for the old "defense-in-depth" framing returns only the corrected negation at `dom-writer.js:162`. |
| **MINOR-R2-1** (no collapsed-by-default pin) | **Present** | `dom-writer.test.js:899-966` pins both owners. Verified the shim can express it (`minidom.js:25-26` — `setAttribute` writes into `this.attributes`), then fault-injected `details.setAttribute('open','')` at `dom-writer.js:175`: `not ok 36 … REGRESSION (MINOR-R2-1): a superseded disclosure carries an 'open' attribute ({"open":""})`, `# tests 47 / # pass 46 / # fail 1`. Restored `sha256 FC8F5ABD…` identical. |
| **MINOR-R2-2** (tautological witness) | **Present** | README now records the tautology explicitly, states why it was one, and replaces it with `closest('.solari-row') === ownRow` plus `ownRow.contains(disclosure) &amp;&amp; ownRow !== disclosure` plus a bounding-box containment check — all three falsifiable, and it points readers at the `dom-writer.test.js` structural tests as the authoritative form. Also volunteers that the round-2 fixture could not exhibit `MAJOR-R2-1` at all (single row, no `elapsedSeconds`, 2-item cluster) — an honest disclosure I did not ask for. New PNGs opened and checked: `collapsed-r3` shows 7 one-line plain rows; `expanded-r3` shows the entry nested and indented inside `with-sup-0`'s own box with `with-sup-1` unchanged. Caption defect → `MINOR-R3-4`. |

---

# CONSTITUTION CHECK

- **Law 1.** Round 2's three violations are **all gone**, each verified by running rather than reading: the density/one-line claim is now true (measured `[22]`, 0 cropped); the `"(line 141)"` citation is symbol-form; the schema/ingest claim is corrected and its correction re-measured. **New, all Minor-tier:** `MINOR-R3-2` (500px vs 340px), `MINOR-R3-3` ("impossible to avoid", measured avoidable), `MINOR-R3-4` (with-sup-1 "one-line"), `MINOR-R3-6` (cross-axis, measured no-op). None asserts a protection that does not exist; none has reachable consequence.
- **Law 6.** Honored. The shared `.car-superseded-disclosure, .solari-superseded-disclosure` rule was correctly **split** rather than forced to keep serving two now-different layouts, with the divergence explained in place (`board.css:380-395`) — the right call, since a single rule spanning two mechanisms is the second-copy hazard inverted.
- **Law 7.** Honored — no taxonomy added; the geometry fixture is generated, not hardcoded to the real store.
- **Law 2 / #68.** Honored — entries stay in the DOM behind a counted, labelled affordance.
- **TDD / red-first.** Honored, and this is the round's strongest showing: the geometry instrument is red-first by construction and I re-derived its red myself; the collapsed-by-default pin reds under injection. The one gap is `MINOR-R3-1`, where a behaviour changed with no assertion covering it.
- **#40 (guards proven by watching them fire).** **Honored for the first time in this train.** Both new guards were watched firing, by me, at HEAD-adjacent injected states. The round-1 and round-2 pattern — visual evidence produced on a fixture that could not falsify the claim — is broken: the new screenshots use a 7-plain-row fixture that *does* exhibit the class, and the README says so explicitly about its own predecessors.
- **NORTH STAR.** Honored in substance: the design doc, state ledger and README were trued in the same commits, and the README supersedes rather than deletes its own stale round-2 material (the two round-2 PNGs are kept and captioned as unable to exhibit the class, which is more honest than removing them). The four Minor doc inaccuracies above are real but none leaves a reader with a false model of the mechanism.
- **#42 (bare `#N`).** Honored — `browser-dispatch-row-geometry.test.js` carries 5 `#69`/`#71` markers; the two new PNGs are cited through the sibling `README.md`, which carries its `Status:` line, exactly as the fixture clause prescribes.

---

# BASE-DELTA (#13)

- **Round 2 reviewed:** `2861bfd8a99d8213ca0058a999ab91706f4ccc9b`
- **This round reviewed:** `4b50a5c5513a7b7401188a4b4d41d989aac572a3`, detached, clean
- **`git diff 2861bfd..4b50a5c --stat`:** 9 files, **+475 / −56**, **zero Go files**

```
 board/web/css/board.css                                     |  74 +++++---
 board/web/js/dom-writer.js                                  |  72 +++++----
 board/web/test/browser-dispatch-row-geometry.test.js        | 159 +++++++++++++++++
 board/web/test/condition-open-state.test.js                 |  22 +--
 board/web/test/dom-writer.test.js                           |  70 ++++++++
 board/web/test/support/real-board-server.js                 |  56 ++++++
 docs/screenshots/.../README.md                              |  78 ++++++++-
 docs/screenshots/.../dispatch-rows-multirow-collapsed-r3.png| Bin 0 -&gt; 37052
 docs/screenshots/.../dispatch-rows-multirow-expanded-r3.png | Bin 0 -&gt; 43216
```

Three commits: `8073f0b` (MAJOR-R2-1 + MAJOR-R2-2 + MAJOR-R2-3), `9b899ab` (MINOR-R2-1), `4b50a5c` (MINOR-R2-2).

**Visible delta for a board reader, measured:** dispatch rows return to the base one-line, ~22px rendering; rows carrying history gain one quiet ~16px summary line (38px total) and nothing else; no row crops mid-row at any tested width; an expanded entry now wraps to two lines at most desktop widths (`MINOR-R3-1`). No wire value changed.

---

# CONVERGENCE RULING — converging, and the cap does not bind

| Round | Base | Majors | Minors | Where the Majors landed |
|---|---|---|---|---|
| 1 | `256d8d5` | **4** | 3 | four distinct surfaces |
| 2 | `2861bfd` | **3** | 2 | all three in the superseded-rendering surface; **2 created by the round-1 fix** |
| **3** | `4b50a5c` | **0** | 6 | — |

All three swirl conditions are now **clear**: counts declined 4 → 3 → **0**; the clustering dissolved rather than moved; and **no finding this round is a defect a previous fix created** except `MINOR-R3-1`, which is Minor-tier, contradicts no authority, and is the kind of neighbouring cosmetic consequence a bounded fix legitimately has. My round-2 cap — *any Major in the superseded-rendering surface → REJECT-ESCALATED to the owner* — **does not fire.**

**What actually changed between round 2 and round 3 was the instrument, not the effort.** My round-2 ruling named the premise both earlier rounds inherited: that a CSS change's rendered effect can be verified by reading plus one screenshot. This round replaced reading with measurement — a real-browser geometry assertion that I watched red on round 2's own defect, a fixture that can exhibit the class, and screenshots captured on that fixture with their predecessors honestly demoted. That is the probe doctrine landing as a durable artifact, and it is why the count went to zero rather than sideways. The six Minors are the residue of a bounded fix, not the signature of a swirl.

**Recommendation to the conductor: APPROVE and land.** Two follow-ups as tickets rather than another round, because none of them belongs to this train's scope and reopening the surface is the risk this cap exists to prevent:
1. `MINOR-R3-1` (entry wraps when expanded) plus the `align-items: start` grid-stretch artifact — one small CSS ticket, and it should land with a geometry assertion of its own, extending `browser-dispatch-row-geometry.test.js`.
2. The four documentation Minors (`R3-2`, `R3-3`, `R3-4`, `R3-6`) are one-line corrections that can ride the same ticket or a doc rider. `MINOR-R3-5`'s `app.js:148` conversion belongs there too.

If the conductor prefers, `R3-2`/`R3-3`/`R3-4`/`R3-6` are cheap enough to fold into this train as a comment-and-caption rider before merge, since none touches behaviour and each is a single sentence. That is a scope call, not a gate call — I do not require it for APPROVE.

---

# UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

**None.** Every finding rests on re-runnable evidence: a two-file `git checkout` injection with before/after `sha256` on both files, a one-line `setAttribute` injection with `sha256`, five real-browser probes against a real `board/server` Go binary (three synthetic fixtures, one nine-width viewport sweep, one against the repo's own committed `artifacts/` store), a Node probe against the real vendored validator, `git show` at `b865cba`/`256d8d5`/`2861bfd`, and a mechanical grep audit over `git diff 256d8d5..4b50a5c` added lines. Both new PNGs are in the repo and were opened.

One labelling caveat, disclosed so nobody misreads my transcript: my scratch probes `browser-probe2/3/4.mjs` carry round-2 header strings (`"AS SHIPPED (2861bfd CSS)"`) that I did not edit between rounds. Every run reported above was executed against the worktree at `4b50a5c`; the header text is stale, the measurements are not.

**Byte-clean exit.** `git status --porcelain` empty; HEAD `4b50a5c5513a7b7401188a4b4d41d989aac572a3`. Files injected and restored with matching `sha256`: `board/web/css/board.css` `B4860579BAD2FF26E2752D5F4F153F5BB2E35E7A60F1BB655557481E6F830E6B`, `board/web/js/dom-writer.js` `FC8F5ABD5D56401101FA1CBA08E35F195EE2AB87939CB803243B2E3BCC234B17`; `board/web/js/app.js` untouched this round and still `9BBCB03A2FC5008EE259E00A057841555FF44C3815091F8AC9D48735A32AB843`. One gitignored `.scratch-store-69-71-rev2b-*` directory left by a truncated pipe was removed; zero remain. Nothing committed, nothing pushed. The shared checkout was not touched at all this round.

**Reviewer probe scripts** (re-runnable, in the session scratchpad `~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\8a347c36-20b4-427a-ae0b-46855aa7bb72\scratchpad\`): `browser-probe2.mjs`, `browser-probe3.mjs`, `browser-probe4.mjs` (round-2 recipes, re-run), `browser-probe5.mjs` (grid-stretch adjudication + flex-basis claim), `browser-probe6.mjs` (viewport sweep, `MINOR-R3-1`), `client-ref-probe.mjs` (`MAJOR-R2-3` re-verification).

```starcar-artifact
outcome: APPROVE
findings: 0 Major, 6 Minor
abstract: |
  Delta re-review of 4b50a5c (view train #69+#71 fix cycle round 3, three commits
  8073f0b/9b899ab/4b50a5c over round 2's reviewed base 2861bfd). APPROVE. The round-2 cap
  does NOT fire: zero Majors anywhere, and none in the superseded-rendering surface.

  Suites re-derived independently at HEAD: Node board/web 212 tests / 212 pass / 0 fail /
  0 skip, Go board 94 top-level PASS with -count=1 -v and 0 FAIL (correctly unchanged -
  zero Go files in the diff, verified), go vet exit 0 no output, Pester scripts/tests 227
  total / 222 passed / 0 failed / 5 skipped with the 5th skip named as the detached-HEAD
  run-session-start-guards.sh ci-baseline guard, Pester scripts/probes 24/24,
  probe-yard-snapshot.mjs PASS. Every count the car claimed reconciles.

  ALL FIVE ROUND-2 FINDINGS RULED PRESENT, each re-derived by running.

  MAJOR-R2-1 fixed and verified with my OWN round-2 probes re-run at 4b50a5c. .solari-row
  no longer sets flex-wrap; the subject/state/elapsed cluster moved into a non-wrapping
  .solari-row-main wrapper and .solari-row became flex-direction column. My 18-plain-row
  fixture at 1600px: distinctRowHeights [22] versus round 2's [51], containerScrollHeight
  96 equal to clientHeight 96 versus 210 against 176, ZERO rows cropped versus three, 18
  of 18 fully visible versus 15. The flex-wrap nowrap runtime counterfactual now changes
  nothing at all, proving the base value is genuinely restored rather than compensated. On
  the repo's real artifacts store, 38px versus round 2's 73px, the 16px difference being
  the owner-ruled collapsed summary line on rows that carry history. Per-child: every
  plain row reports one visual line, one distinct top. The chip side is untouched -
  .car-chip measures 23px and one visual line at 4b50a5c, identical to round 2 and
  identical under the override.

  THE NEW INSTRUMENT IS REAL, NOT DECORATION, and I watched it fire rather than trusting
  the car's report. board/web/test/browser-dispatch-row-geometry.test.js is 3 of 3 green at
  HEAD. I restored round 2's rendering wholesale via git checkout 2861bfd of BOTH
  board.css and dom-writer.js (sha256 recorded both directions, both restored identical)
  and ran the finalized test unchanged: test 1 red with "row 'plain-subject-00' (no
  disclosure) spans 2 visual lines for its subject/state/elapsed cluster - expected exactly
  1" and test 2 red with "1 plain row(s) crop mid-row at .solari-rows' own boundary"
  carrying height 51 in its payload - the exact 51px my round-2 probe measured. Test 3
  stays green under injection, which is honest rather than a hole: it guards expansion
  isolation, a property round 2's layout happened to satisfy, and the file's own header
  scopes its non-vacuity claim to the first test.

  MAJOR-R2-2 fixed: the citation is symbol-form and the falsehood is recorded rather than
  erased. I audited the WHOLE train's added lines (git diff 256d8d5..4b50a5c) for
  line-number citations myself: five hits, all verified true at HEAD - fold.go:112 resolves
  to "Spend any", gating-matrix.md:49 to the #65-lesson row, app.js:148 to the listener
  line, plus the quoted "(line 141)" inside its own correction narrative. MAJOR-R2-3
  fixed: the comment now states the $def is unenforced on the runtime hop, names
  $defs.lane.data and the schema's own $comment as the reason, names WirePayload.Tests.ps1
  as the sole consumer, and calls the renderer filter the entire runtime protection.
  Re-measured with the real vendored cfworker validator at 4b50a5c: kind:7 and missing-at
  both still validate clean, so every claim is true. No leak - grep finds the old
  defense-in-depth framing only inside the corrected negation. MINOR-R2-1 pinned and
  fault-injected: setAttribute open reds test 36 with the intended message, 46 of 47,
  restored identical; I first verified minidom's setAttribute writes into .attributes so
  the pin can actually express the property. MINOR-R2-2 fixed with a falsifiable witness,
  and the car volunteered unprompted that its round-2 fixture could not exhibit MAJOR-R2-1
  at all. Both new PNGs opened and checked against their captions.

  SIX MINORS, all measured, all one-line fixes, none contradicting an authority.
  MINOR-R3-1 is the notable one and I explain why I declined to call it Major: this round
  moved white-space nowrap off .solari-row onto .solari-row-main, so an EXPANDED
  superseded entry now wraps to two lines at 6 of 9 swept viewports including 1600 and
  1920 (entry 209x28, whiteSpace normal, versus 218x14 at round 2). It contradicts no
  comment, ruling or spec - the "One line per row" convention is explicitly about the
  subject cluster and the car correctly moved that comment with its rule - nothing is
  truncated, cropped or mis-attributed, Law 1 is not engaged, and it manifests only after
  a deliberate click, so the glance is untouched. Calling it Major would fire an owner
  escalation over a post-click cosmetic wrap, which is the autoimmune mode. Recorded with
  the observation that the instrument I prescribed guards the property I named and not its
  neighbour. MINOR-R3-2: the geometry test's comment says a 500px viewport where the code
  uses 340px, and measurement shows 500px yields TWO columns, so the stated width would not
  produce the claimed property. MINOR-R3-3: the README calls the grid-stretch artifact
  "structurally impossible to fully avoid" three lines before proposing the one property
  that fully avoids it, measured. MINOR-R3-4: the expanded-r3 caption says with-sup-1 keeps
  its "original one-line height" - measured 38px and two lines. MINOR-R3-5: app.js:148 is a
  line citation into a file this train DID edit (+39/-1 at 256d8d5), stable only because no
  later commit touched it; the citation is true but the audit's stated reason ("files this
  train never edits") is wrong for it, and that reason lives only in the car's report, not
  in any committed surface. MINOR-R3-6: board.css calls the vertical axis of a column flex
  container the cross axis (it is the main axis) and asserts a consequence measurement
  shows does not occur - forcing flex-basis 100% onto the disclosure changed nothing.

  OUT-OF-SCOPE OBSERVATION ADJUDICATED. Real: at 1400px, plain rows sharing a grid band
  with a disclosure row measure 38px instead of 22px while their content stays one line
  (mainH 19, one distinct top), computed align-items normal behaving as stretch. The
  README's description is accurate on every checkable claim except MINOR-R3-3's
  "impossible" clause. Pre-existing: the MECHANISM predates the whole train - .solari-rows'
  rule is byte-identical at b865cba and 4b50a5c with align-items never declared - while the
  TRIGGER, mixed-height siblings, arrives with #71's feature; the earliest commit where a
  disclosure row can stretch a plain row is 2861bfd, where it was confounded by the wrap
  regression, so 4b50a5c is the first commit where it is cleanly separable. The README's
  "not new to this round's fix, present since MAJOR-R1-1 first shipped round-2" is
  precisely correct and does not overclaim. Not fixing it under the cap was the RIGHT call:
  out of scope, cosmetic, and an unscoped change to the shared grid rule is exactly the
  move that produced MAJOR-R2-1. Disposition TICKET rather than live-with, and cheap:
  measured in the same paint, align-items start drops all seven plain rows from 38px to
  22px while both disclosure rows correctly stay 38px.

  CONSTITUTION: round 2's three new Law 1 violations are ALL GONE, each verified by
  running. Four new Law-1-adjacent inaccuracies exist but are all Minor-tier with no
  reachable consequence and none asserting a protection that does not exist. Law 6 honored
  and notably well - the shared disclosure rule was SPLIT rather than forced to serve two
  now-different layouts, with the divergence explained in place. Law 7, Law 2/#68 honored.
  TDD honored, the round's strongest showing. #40 HONORED FOR THE FIRST TIME IN THIS TRAIN:
  both new guards were watched firing by me, and the round-1/round-2 pattern of visual
  evidence built on a fixture that could not falsify it is broken. NORTH STAR honored in
  substance, with the stale round-2 PNGs superseded and captioned rather than deleted.
  #42 honored including the fixture clause for the two new PNGs.

  CONVERGENCE: 4 Majors to 3 to ZERO. All three swirl conditions now clear - counts
  declined, the clustering dissolved rather than moved, and no finding this round is a
  defect a previous fix created except MINOR-R3-1, which is Minor-tier and contradicts no
  authority. The cap does not bind. What changed between rounds 2 and 3 was the INSTRUMENT,
  not the effort: measurement replaced reading, exactly the premise my round-2 ruling named,
  and that is why the count went to zero rather than sideways. Recommendation: APPROVE and
  land; two follow-up tickets (the entry-wrap plus the grid-stretch artifact as one CSS
  ticket carrying its own geometry assertion; the four documentation Minors plus the
  app.js:148 conversion as a doc rider), rather than reopening this surface for a round 4.

  BASE-DELTA 2861bfd to 4b50a5c, 9 files +475/-56, zero Go files. Visible delta measured:
  dispatch rows return to the base one-line ~22px rendering; rows carrying history gain one
  quiet ~16px summary line; no row crops mid-row at any tested width; an expanded entry
  wraps to two lines at most desktop widths. No wire value changed.

  UNREPRODUCIBLE-EVIDENCE: none. One labelling caveat disclosed - my scratch probes carry
  stale round-2 header strings; every run reported was executed against the worktree at
  4b50a5c. Byte-clean exit, git status --porcelain empty at HEAD
  4b50a5c5513a7b7401188a4b4d41d989aac572a3. Files injected and restored with matching
  sha256: board.css B4860579, dom-writer.js FC8F5ABD (twice - the two-file round-2 restore
  and the setAttribute injection); app.js untouched this round at 9BBCB03A. One gitignored
  scratch directory left by a truncated pipe was removed, zero remain. Nothing committed,
  nothing pushed, shared checkout not touched at all this round.
task-id: view-69-71-review-r3
```