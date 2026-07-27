<!-- starcar-integrity: sha256=fa4dbf3e82b12723d28a25e555ee230d7387d3fd9549f2b3e33ee9f7dd90a266 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# View train #28+#12 car review, round 3 (capped delta)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial delta re-review, capped round
Round: 3
Target: `car/view-28-12 HEAD 87f929c (fix commit on 6346d7d)`
Base reviewed: `ab00e9c1b8eb7d45454cd82e01c24d347392582d`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a678b799208107386`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `ab00e9c1b8eb7d45454cd82e01c24d347392582d` |
| Entire checkpoint | `d25ee3c8e755` |
| Dispatch, the locator within the session | `a678b799208107386` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain ab00e9c1b8eb7d45454cd82e01c24d347392582d
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# DELTA RE-REVIEW — view train #28 + #12, round 3 (THE CAPPED ROUND)

**Verdict: APPROVE — 0 Major, 2 Minor. The cap HELD; no escalation.**

Base verified before any work: `git checkout --detach 87f929cf305409117ba627335d6b54f110a5738c`; HEAD **`87f929c`**, parent **`6346d7d`** (the commit I reviewed in round 2), grandparent `3076a40`, base `ab00e9c`. `git status --porcelain` empty at entry and exit. Nothing committed, nothing pushed, shared checkout untouched.

---

## THE CAP RULING — it held

My round-2 cap, verbatim: *"If round 3 produces any new citation-truth defect created by round 2's own fixes, escalate to the owner."* I audited **every changed line** of `6346d7d..87f929c`.

| Cap trigger | Measured at HEAD |
|---|---|
| New attribution landed in any file | **ZERO.** Both attributions were **deleted**, not re-attributed. |
| New `file:line` coordinate asserted | **ZERO.** Exactly one added line contains a coordinate token — `"dom-writer.js:201"` — and it is **quoted in past tense as the stale thing being removed**, not a citation being made. |
| New completeness claim | **ZERO.** The commit message explicitly disclaims exhaustiveness: *"no claim is made that this, or any prior, sweep is exhaustive over the repo's remaining citations."* |
| Scope claim ("exactly three files") | **TRUE.** `git diff --name-only` returns exactly `board/server/elapsedbucket_test.go`, `board/web/js/findings.js`, `docs/design/2026-07-21-v0-yard-skeleton-design.md`. |
| Delete-beats-re-attribute obeyed | **YES.** `3 files changed, 12 insertions(+), 18 deletions(-)` — net negative, and the insertions add no assertion the deletions did not remove. |

The round-2 failure mode was *fixes that asserted more than they deleted*. Round 3 inverted it exactly. **I do not escalate. I rule on the merits.**

## Round-2 finding disposition

| ID | Disposition | Evidence |
|---|---|---|
| **MAJOR-R2-1** false `tooling-50-32` → issue #12 attribution | **ABSENT (deleted, not moved)** | `findings.js:36-39` now reads `...family "51-fix-review", e.g. "tooling-50-32-review-r1/-r2/-r3"). A subject with no such suffix...` — a bare illustration, zero provenance claim. `design:703` now reads `(e.g. \`tooling-50-32-review-r1/-r2/-r3\`);`. `git grep "issue #12's own worked example"` outside `artifacts/` → **empty**. `git grep "docs/CLAUDE.md"` outside `artifacts/` → only `gating-matrix.md:53`, where it appears **inside a correction narrative** ("was misattributed to a nonexistent `docs/CLAUDE.md`") attached to an attribution I measured **TRUE**. |
| **MAJOR-R2-2** false sweep-completeness + line-wrapped residual | **PRESENT-fixed** | Symbol citation verified true at HEAD — see below. Commit message now states what round 2's sweep covered with **no universal adjective** and an explicit non-exhaustiveness disclaimer. |
| **MINOR-R2-1** correct attribution turned wrong | **PRESENT-fixed** | `findings.js:71-73` restored to `(a REJECT with Majors is normal traffic in this shop, per CLAUDE.md's own review-calibration framing)`. **Verified TRUE:** `## Review calibration (binding, uniform)` at `CLAUDE.md:595`, containing *"Any Major = REJECT"* (`:597`) and *"A REJECT is a success outcome for the process"* (`:605`). No line number cited. |

**Symbol-citation claim, verified.** `elapsedbucket_test.go:26-30` now cites *"dom-writer.js's renderDispatches solari-elapsed span renders elapsed_seconds verbatim to the second"*. At HEAD, `renderDispatches` spans `dom-writer.js:359-382` and contains exactly one `solari-elapsed` span at **`:376`**: `el(doc, 'span', 'solari-elapsed', \`${d.elapsedSeconds}s\`)` — verbatim, no rounding. Both symbols are unique in the file, so the citation is durable against any future line shift.

**Every surviving provenance claim in the train's text is now measured TRUE:**

| Claim | Site | Measurement |
|---|---|---|
| `7 -&gt; 1 -&gt; 0` is the ticket's example | `design:707` | 1 occurrence in issue #12's 5412-byte body+comments |
| `3 -&gt; 4 -&gt; 4` is the ticket's example | `design:708-709`, `gating-matrix:53` | 1 occurrence in issue #12 |
| review-calibration framing | `findings.js:72`, `design:710` | `CLAUDE.md:595` section |

## Residual sweep — my own, using the technique that would have caught round 2's miss

I re-swept at HEAD with an **unwrapping** scanner: it strips comment leaders and **joins all lines with no separator** before matching the coordinate shape, so a citation split across a line wrap (round 2's exact escape) cannot hide. Every coordinate targeting a train-edited file, adjudicated:

| From → coordinate | Ruling |
|---|---|
| `elapsedbucket_test.go` → `dom-writer.js:201` | **Not a citation** — quoted as the removed stale token |
| `lanes.js:16` → `snapshot.go:41-45` | **TRUE** — `:41-45` is exactly *"absence of the key itself is what signals 'no payload'"* |
| `sse-protocol.js:7` → `design.md:133` | **TRUE** — `:133` is the D19 row naming `EventSource` |
| `sse-protocol.test.js:9` → `design.md:133` | **TRUE** — same row |
| `gating-matrix.md:49` → `design.md:133` | **TRUE** — same row; round 3's only design-doc hunk is `@@ -700,10 +700,7 @@`, far below |

**Zero residual citation defects of this class.** (The scanner also produced known unwrap artifacts such as `atpoll.go:399-412` — from *"disclosed at"* + *"poll.go:399-412"* — confirming the joiner is aggressive enough to have caught the round-2 miss had it still existed.)

---

## Findings — 2 Minor, both commit-message-only, neither blocking

**MINOR-R3-1 — an over-broad `only` in the commit message.** It states: *"the string exists **only** in this repo's artifacts store, never in the issue."* Measured at HEAD, `tooling-50-32` also appears in `docs/design/2026-07-24-family-agnostic-harness-design.md` (7 lines: `:67, :69, :71, :76, :77, :82, :124, :126`) and `scripts/tests/ReconcileDispatchRecords.Tests.ps1:283`, besides the train's own test fixtures. The load-bearing half — *"never in the issue"* — is **true and correctly attributed to my measurement**.

**MINOR-R3-2 — a claim about my method that my own landed verdict contradicts.** The message says *"The reviewer found it by reading the file, not by searching."* My round-2 verdict records the opposite: I found it via a **coordinate-shaped** `git grep -E '[A-Za-z0-9_./-]+\.(go|js|…):[0-9]+'` sweep, and it was my **basename-anchored** sweep that missed it. This matters slightly more than MINOR-R3-1 because it mis-teaches the technique — though the same commit message self-corrects two sentences later, explaining accurately that *"'dom-writer.js:201' is not a contiguous substring on any single line, so a search for 'dom-writer.js:' does not match it."*

**Why these are Minor and not Major, stated so the owner can overrule.** I considered Major, on the precedent that I charged MAJOR-R2-2 partly *because* a false claim in a commit message is a durable false record. The distinction I am drawing is consequence, and it is real rather than convenient: MAJOR-R2-2 was a **universal completeness claim that concealed a live defect**, and the defect stayed live. These two are narrative over-reach in a retrospective paragraph — they land in **no** document or comment, direct a reader to **no** coordinate, conceal **nothing**, and make **no** completeness claim. Test I applied to check myself for agreeableness: *had this identical text landed in `findings.js` as a comment, would I call it Major?* **Yes** — and it did not.

**The actionable consequence, and the only thing I ask of the conductor:** the merge message is the durable record that reaches `main`. **Do not carry those two sentences forward.** Everything else in the commit message is accurate and worth keeping.

---

## Suites — observed by me at `87f929c`

| Suite | Observed | Car claimed | Note |
|---|---|---|---|
| Go `board/` top-level `--- PASS` | **85 / 85**, 0 FAIL (105 incl. subtests) | 85 unchanged | ✓ |
| `go vet ./...` | exit **0** | clean | ✓ |
| Node `board/web` whole-directory (CI form) | **129 / 129**, 0 fail, 0 skipped | 129 | ✓ |
| `scripts/tests` (full Pester) | **194 passed, 0 failed, 1 skipped, 195 total** | "195/195" | Reconciled as in r2 — the one skip is `SessionStartGuardRunner.Tests.ps1:87`, which `Set-ItResult -Skipped` on a detached HEAD by design. My brief mandates detached; the car is on a branch. Environment, not defect. |
| `scripts/probes` | **24 / 24** | 24/24 | ✓ |
| `scripts/tests/CodeCitationPolicy.Tests.ps1` | **13 / 13** | 13/13 | ✓ |
| `scripts/store-checks` | **212 / 212** | — | ✓ |
| `board/web/probe-yard-snapshot.mjs` | **PASS**, exit 0 | PASS | ✓ |
| `browser-health-trend-cascade.test.js` | **4 / 4** | — | ✓ incl. its own injected-cascade non-vacuity leg |

## #40 floor

Car claims no client-rendering change. **Verified, not read**, by my comment-stripped method plus raw bytes:

- `git diff --stat 6346d7d 87f929c -- board/web/` lists **only** `findings.js` — every other client file is byte-identical, `board.css` untouched.
- Comment-stripped comparison `6346d7d` vs `87f929c`: `findings.js`, `dom-writer.js`, `render.js`, `links.js` all **IDENTICAL**; `board.css` byte-identical.
- Real-browser cascade suite **4/4** at HEAD, including the computed-style assertions that pin `rgb(217, 213, 201)` / `rgb(255, 74, 58)` against the live register probes.

**Floor satisfied.** No rendered surface changed; rounds 1–2's computed-style evidence carries forward intact.

## #13 fields

**BASE-DELTA vs `ab00e9c`.** Unchanged from rounds 1 and 2, re-measured at HEAD with no GitHub config on the real store: the only thing an unconfigured user sees that base did not is the ticket strip — `&lt;div class="train-tickets"&gt;&lt;span class="ticket-link"&gt;#1&lt;/span&gt;&lt;/div&gt;`. Everything else byte-identical to base rendering: `anchorCount: 0`, `span.car-subject` ×10, `span.solari-subject` ×91, `healthBadges: 0`, and **`BOARD CONDITIONS: []`** (the `gate-findings-record-not-found` guard still never fires on consistent data). This round adds nothing further.

**UNREPRODUCIBLE EVIDENCE.**
1. The car's `scripts/tests` "195/195" — not reproducible in the detached worktree my brief mandates (194 + 1 by-design skip). Reconciled, not a finding.
2. *"the conductor's own ruling on this issue"* (`links.js:3`, `design:672`) — issue #28 still has 0 comments; the ruling lives in the car's brief, which I do not hold. Corroborated by my own brief.
3. Carried from earlier rounds: the car's account of an earlier version of its own test (I verified the *mechanism* — `http.FileServer` 304s within one mtime second — but cannot replay the run), and the screenshot PNGs (code path and its honest disclosure verified; not re-rasterised).
4. **My own housekeeping, disclosed:** a `go run ./server` grandchild from my round-2 README sentence check was still holding port 4991 — precisely the orphan behaviour `real-board-server.js:10-16` documents. I killed it; zero listeners remain on any port I used. No repo state was involved.

---

## CONVERGENCE — 4 Major → 2 Major → 0 Major

Findings **shrank and moved** every round, and this round they moved to zero. The round-2 swirl signal (fix-created defects) is **gone**: the fix that could have relocated a defect instead deleted the claim entirely, which is the structural end of that loop, not a lucky round.

**The instrument lesson landed too**, and it is worth carrying into the retro: the recurring defect was *hand-written provenance prose*, and the cure was **removing the assertion**, not writing a better one. Three of this train's five citation Majors would have been caught mechanically by a gate that resolves every `file:line` coordinate outside `artifacts/` — including the line-wrapped instance, provided the gate **unwraps lines before matching**, as my sweep above does. That is a cheap, reusable check and the right follow-on ticket.

## APPROVE — merge-message numbers

**Train:** `ab00e9c` → `87f929c`, 4 commits, `33 files changed, 2162 insertions(+), 71 deletions(-)`.

**Suites at final HEAD `87f929c`:** Go **85/85** (+12 over base 73), `go vet` exit 0 · Node `board/web` **129/129** (+48 over base 81) · Pester `scripts/tests` **194 passed / 1 skipped / 195 total** detached (195/195 attached) · `scripts/probes` **24/24** · `scripts/store-checks` **212/212** · `CodeCitationPolicy` **13/13** · `probe-yard-snapshot.mjs` **PASS** · real-browser cascade **4/4**.

**Gate history:** r1 REJECT (4 Major, 6 Minor) → r2 REJECT (2 Major, 1 Minor) → r3 **APPROVE (0 Major, 2 Minor, both commit-message-only, non-blocking)**.

**What the train delivers.** #28 clickable provenance across three surfaces — car/gate/dispatch subjects to their GitHub record directory and train manifest tickets to their issues — built from three wire primitives with `recordDir` single-sourced from `store.Record.Path` (never re-derived client-side, which the real store's `train:board-v0` → `train-board-v0` sanitisation proves necessary), degrading to plain text with no layout change when unconfigured, and documented for a stranger in the README with the documented command run end-to-end. #12 car health bar — a conservative head-anchored findings parser (38 parse / 98 unknown across 136 of this repo's 207 records, honest-unknown for the rest), per-family convergence trends sorted chronologically and attached to the latest round only, rendered through the existing two register classes with no fourth colour, proven in a real browser with a non-vacuous cascade fault injection. Plus one live wire defect found and fixed under review (a superseded round's findings paired with the winning round's verdict), a new FLAG-tier board condition correctly registered behind an AST set-equality guard I watched fire by name, and six stale or false citations corrected across the repo.

**Constitution check:** Law 1 — every surviving provenance claim measured true; unknown renders unknown. Law 6 — one owned severity mapping, one parser, `recordDir` single-sourced. Law 7 — no hardcoded repo identity; README serves the stranger. Three-register law — measured, no fourth colour. Living documents — design doc, gating matrix and README all trued in the commits that touched them. Red-first — MAJOR-4's pin and the taxonomy guard both fault-injected by me and reverted byte-identical. Merge north star — **this is a state worth asserting.**

Worktree left byte-clean at `87f929c`; `git status --porcelain` empty.

```starcar-artifact
outcome: APPROVE
findings: |
  0 Major, 2 Minor. Both Minors are confined to the round-3 COMMIT MESSAGE; neither lands in any document, comment, or code, and neither blocks a merge.

  MINOR-R3-1: the commit message states "the string exists only in this repo's artifacts store, never in the issue." Measured at HEAD, "tooling-50-32" also appears in docs/design/2026-07-24-family-agnostic-harness-design.md (lines 67, 69, 71, 76, 77, 82, 124, 126) and scripts/tests/ReconcileDispatchRecords.Tests.ps1:283, besides the train's own test fixtures. The load-bearing half - "never in the issue" - is true and correctly attributed to my round-2 measurement.

  MINOR-R3-2: the commit message states "The reviewer found it by reading the file, not by searching." My landed round-2 verdict records the opposite: I found the line-wrapped citation via a COORDINATE-SHAPED git grep, and it was my BASENAME-anchored sweep that missed it. This mis-teaches the technique, though the same commit message self-corrects two sentences later by accurately explaining that "dom-writer.js:201" is not a contiguous substring on any single line so a search for "dom-writer.js:" cannot match it.

  Both were considered for Major and ruled Minor on consequence, stated so the owner can overrule: the round-2 Major was a UNIVERSAL completeness claim that CONCEALED a live defect which then stayed live; these two land in no document, direct a reader to no coordinate, conceal nothing, and make no completeness claim. Self-check applied: had this identical text landed in findings.js as a comment it would be Major, and it did not. ACTION FOR THE CONDUCTOR: the merge message is the record that reaches main - do not carry those two sentences forward.

  Round-2 dispositions: MAJOR-R2-1 ABSENT (deleted at all three sites, not re-attributed; the example now stands as a bare "e.g." illustration with zero provenance claim). MAJOR-R2-2 PRESENT-fixed (symbol citation verified true: renderDispatches at dom-writer.js:359-382 contains exactly one solari-elapsed span at :376 rendering elapsedSeconds verbatim; commit message now carries no universal adjective and explicitly disclaims exhaustiveness). MINOR-R2-1 PRESENT-fixed (round-1 wording restored, verified true against CLAUDE.md's "Review calibration" section at :595).
abstract: |
  Round 3, the capped round, of the view train's #28+#12 car. Base verified: HEAD 87f929c, parent 6346d7d, base ab00e9c; worktree byte-clean at entry and exit; nothing committed or pushed.
  THE CAP HELD, so I did not escalate and ruled on the merits. I audited every changed line of 6346d7d..87f929c against my own cap trigger. Scope claim verified exact: three files (elapsedbucket_test.go, findings.js, the design doc). New attributions landed: ZERO - both false attributions were DELETED rather than re-attributed. New coordinates asserted: ZERO; exactly one added line contains a coordinate token, "dom-writer.js:201", and it is quoted in past tense as the stale thing being removed, not a citation being made. New completeness claims: ZERO; the message explicitly disclaims exhaustiveness. Delete-beats-re-attribute was obeyed literally - 12 insertions against 18 deletions, net negative, with the insertions adding no assertion the deletions did not remove. The round-2 failure mode, fixes that asserted more than they deleted, was inverted.
  Every surviving provenance claim in the train's text is now measured TRUE: design:707's "7 -&gt; 1 -&gt; 0" and design:708-709 plus gating-matrix:53's "3 -&gt; 4 -&gt; 4" each occur exactly once in issue #12's 5412-byte body-plus-comments dump, and findings.js:72 plus design:710's review-calibration framing is supported by CLAUDE.md's "Review calibration (binding, uniform)" section at line 595.
  I re-swept independently at HEAD with an UNWRAPPING scanner that strips comment leaders and joins all lines with no separator before matching the coordinate shape, so a citation split across a line wrap - round 2's exact escape - cannot hide. Five coordinates target train-edited files; all five adjudicated clean: the elapsedbucket one is the quoted removed token, and lanes.js:16 to snapshot.go:41-45, sse-protocol.js:7 and sse-protocol.test.js:9 and gating-matrix.md:49 to design.md:133 all resolve correctly at HEAD. Zero residual citation defects of this class.
  Suites observed by me at 87f929c: Go 85/85 top-level pass, 0 fail, go vet exit 0. Node board/web whole-directory 129/129, 0 fail. scripts/tests 194 passed, 0 failed, 1 skipped, 195 total - the skip is SessionStartGuardRunner.Tests.ps1:87 skipping by design on a detached HEAD, which my brief mandates, reconciling with the car's attached-branch 195/195. scripts/probes 24/24. CodeCitationPolicy 13/13. store-checks 212/212. probe-yard-snapshot.mjs PASS. Real-browser cascade 4/4.
  The #40 floor is satisfied by verification: only findings.js changed under board/web, every client file is IDENTICAL comment-stripped, board.css is byte-identical, and the real-browser cascade suite passes at HEAD. BASE-DELTA versus ab00e9c is unchanged from rounds 1 and 2 - an unconfigured user sees only the train-tickets strip, with zero anchors, zero health badges and an empty board-conditions array.
  CONVERGENCE: 4 Major to 2 Major to 0 Major, findings shrinking and moving every round, and the round-2 swirl signal of fix-created defects is structurally gone because the fix deleted the claim rather than relocating it. APPROVE. Merge-message numbers: ab00e9c to 87f929c, 4 commits, 33 files changed, 2162 insertions, 71 deletions; gate history r1 REJECT 4M/6m, r2 REJECT 2M/1m, r3 APPROVE 0M/2m. The train delivers #28 clickable provenance across three surfaces with recordDir single-sourced from store.Record.Path and honest degradation when unconfigured, README-documented and run end-to-end for a stranger; #12's conservative health-trend badge reusing the existing two registers with real-browser non-vacuous proof; plus one live wire defect found and fixed under review, a new FLAG-tier board condition guarded by an AST set-equality test I watched fire by name, and six stale or false citations corrected. Recommended follow-on, not blocking: a mechanical gate that resolves every file-colon-line coordinate outside artifacts, unwrapping lines before matching, which would have caught three of this train's five citation Majors.
task-id: view-28-12-review-r3
```