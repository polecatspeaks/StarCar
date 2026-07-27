<!-- starcar-integrity: sha256=4abc7628222b1a85373df3e4245ad6f959cf7eaf10b245690a2ab0f257238a3a covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car process-docs delta re-review - round 2 (REJECT, cap set)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial delta re-review
Round: 2
Target: `commits 7cf2e48, 3e267e2, c7e263e, 000111b on car/process-docs`
Base reviewed: `000111b767108d241ed62eb58db36303512c55ec`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a7fbcee7ccaec45d8`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `000111b767108d241ed62eb58db36303512c55ec` |

| Dispatch, the locator within the session | `a7fbcee7ccaec45d8` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 000111b767108d241ed62eb58db36303512c55ec
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

---

# DELTA RE-REVIEW, ROUND 2 — VERDICT: **REJECT** (1 Major, 3 Minor, 2 Notes)

Base verified: HEAD = `000111b767108d241ed62eb58db36303512c55ec`, clean tree before and after. Read-only: edited, committed, pushed nothing.

**BASE-DELTA (#13)** — dogfooding the field this train installs:
- This round's reviewed base: `000111b767108d241ed62eb58db36303512c55ec`
- Round 1's reviewed base: `71d0c25d3d34a811b358d798a0c0661df1ce11bb`
- `git diff 71d0c25..000111b --stat` → 5 files, **112 insertions, 29 deletions**: `car-brief.md` (37), `worked-adversary-and-gate-briefs.md` (45), `design-briefs.md` (33), `worked-spec.md` (21), `.claude/agents/car.md` (5).

**UNREPRODUCIBLE-EVIDENCE CALLOUT (#13):** one item, unchanged from round 1 — #9's residual 2 (the `Project-Bootstrapping` mirror) is structurally unverifiable from this worktree. **No round-2 finding rests on it.** Every finding below is re-derivable from files in this repo.

---

## SUITES — run myself at `000111b`, pwsh 7

| Suite | Observed | vs round 1 |
|---|---|---|
| `scripts/tests` | **181 passed / 0 failed / 1 skipped / 182 total** | unchanged |
| `scripts/store-checks` | **178 passed / 0 failed / 178 total** | unchanged |
| `scripts/tests/DocPolicy.Tests.ps1` | **2 passed / 0 failed** | unchanged, **green** |

Same single detached-HEAD skip (`run-session-start-guards.sh` agent-pull runner). Car's `182/182` attached claim reconciles exactly. Docs-only delta, no suite movement — as expected.

---

## ROUND-1 FINDINGS WALK — 11 of 11 **CLOSED**

| ID | Status | Evidence I checked |
|---|---|---|
| **M-1** (#13 carriers) | **CLOSED** | Both fields landed in all five named carriers: `design-briefs.md:114-125,132-140,147-148`; `worked-adversary-and-gate-briefs.md:37-42,74-79` (design/spec), `:100-108` (plan), `:152-156,158-160` (gate). Each VERDICT line amended. Shapes are genuinely native, not pastes — see ruling below. Commit `3e267e2` opens with a **RECORD CORRECTION** paragraph stating e511c5e's claim was false and why, which is the right instrument since history cannot be amended. **But a sixth carrier exists — M-4.** |
| **M-2** (false ledger row) | **CLOSED** | `worked-spec.md:93` now reads "records that this feature adds NO mutable process state (section 5 says `Snapshot.verdict` is 'NOT STATE - recomputed per snapshot'), so the ledger's arithmetic is 0 -&gt; 0". Quote matches `:60` verbatim; consistent with `:63` "none in this feature". Contradiction gone. **And it still teaches the discipline** — the row explicitly says "A `none` row is still a mandatory row, per this section's own opening line", which `:87-88` does say. |
| **M-3** (false fidelity rows) | **CLOSED, and extended beyond the finding** | Re-derived with my own grep at this HEAD: threshold tokens hit only `:23` (header), `:41` (§2 bullet 2, read-once), `:60` (§5), `:70` (§6) — §2's opening line and all of §3 silent. "never the browser clock alone" hits only `:22` (header). **Both NOT CARRIED rows are factually correct.** The car also re-read row 5 against the same standard on its own initiative and marked it too — the class remedy, not just the instance. |
| **m-1** (report values) | **CLOSED** | `car-brief.md:132-136` now "REPORT THE OBSERVED VALUES (the exact `rgb()`/px returned)… never a bare pass/fail with no printed value". #40's carrier item 1 does end "Report observed values." — quoted correctly. |
| **m-2** (conditional) | **CLOSED** | `:176-177` "BASE-DELTA (#13) WHEN THIS IS A RE-REVIEW, and any UNREPRODUCIBLE-EVIDENCE callouts (#13), stated explicitly". Now agrees with `:94-95`. Cold-read: the comma placement makes "stated explicitly, not folded into a table" govern both. Reads cleanly. |
| **m-3** (paired carrier) | **CLOSED** | `.claude/agents/car.md:70-73` carries the visual-guard clause, wording identical to `car-brief.md:154-157`. Deliberate doctrine-mandated pairing, not drift. |
| **m-4** (uncheckable parenthetical) | **CLOSED** | `worked-spec.md:98-100` now cites `docs/design/2026-07-22-dispatch-harness-design.md` section 8 with **eight** rows. I counted `:252-259` = 8 data rows. Checkable and correct. (See N-5.) |
| **m-5** (heading) | **CLOSED** | `:168` now "(folded 2026-07-26, #9)". Consistent with the residuals beneath it; no longer asserts a closed ticket. |
| **m-6** (permuted quote) | **CLOSED — better than ordered** | `car-brief.md:170-173` is now a **contiguous verbatim substring** of `drill:110` in source order, with no ellipses at all. Walked it word for word against the source. Only changes are the nested single-quotes and a soft wrap at the pre-existing hyphen. |
| **m-7** (overstated drill) | **CLOSED** | `:99-106` now "named TWO template gaps, not one — this is the first of them", with the second named and cross-referenced. Matches `drill:109-110`. The "every prior finding" overstatement is gone. |
| **N-1** (attribution) | **CLOSED** | `:141-144` now credits the human eye at first light for the #31 catch, per #33's own account, and the reviewer's model for why a mechanical floor is needed. |

---

## MAJOR — the one blocker

### M-4 (NEW, revealed by `3e267e2`'s own fix) — the plan rung's delegated verdict-shape carrier still has neither field

`docs/templates/worked-adversary-and-gate-briefs.md:88` — the plan adversary's own heading:

&gt; `## 3. The plan adversary (rule 5 - **see worked-plan.md's review record for the verdict shape**)`

That pointer leads to `docs/templates/worked-plan.md:169`, titled **"The plan-review record (rule 5) - what the adversary hunts, and the verdict shape."** It was not touched by this delta, and it carries:

- **`:171-181` — the same dimension list, now diverged.** `worked-plan.md` states Dimensions **(a)-(e)**; `3e267e2` changed the same rung's brief to **(a)-(g)**. Two copies of one rung's dimension list, in disagreement, with no cross-reference marking either authoritative. The carrier rule sanctions restatement *across* rungs ("four restatements of one fact, and the redundancy IS the point") — this is duplication *within* one rung, which it does not.
- **`:183-189` — the verdict shape itself**, the thing `:88` sends readers to, with no BASE-DELTA and no unreproducible-evidence line.
- **`:191-192`** — "the re-review verifies the delta; the verdict history stays in the plan" — literally the delta-re-review path, at the plan rung, which is the rung where the drill that produced #13 ran.

**The traceable path to a non-compliant artifact:** a conductor writes a plan re-review brief from `worked-adversary-and-gate-briefs.md` §3, follows `:88` to `worked-plan.md` for the verdict shape, writes the verdict in the shape found there, and produces a verdict with no BASE-DELTA — having followed both templates correctly. That is the same shape as M-1, one pointer further out.

I am classifying this as a **new finding rather than M-1 DRIFTED**, because M-1's named remedy was delivered completely and correctly in all five carriers I named. This is a sixth carrier reachable only through a delegation pointer.

**And I must disclose my own round-1 miss:** my round-1 search was `VERDICT:|verdict template|reviewer brief|Reviewer brief`. `worked-plan.md` says *"the verdict shape"* and *"The plan-review record"* and matched none of them. I faulted the car for a glob that structurally could not see a file, using a pattern that structurally could not see a file — same class, one directory over. The car's fix was correct against the finding it was given; the finding was incomplete.

**Remedy (small):** add both fields to `worked-plan.md:169-195` in that section's own narrative voice, extend its dimension list to (f)/(g) to match, and add a one-line cross-reference in one direction so the plan rung's dimension list has a single owner.

---

## MINOR

- **m-8 — `design-briefs.md:137-139` misstates the drill, and inverts its verdict on a prior reviewer.** The WHY reads: *"a finding built on a gitignored probe log **was recorded as closed with no flag that the closure itself was unverifiable by anyone else**."* Both halves are false against the cited source. `drill:66` records C2R1-M4 as **"DRIFTED → C2R2-M1"** — not closed; promoted to that round's own Major. `drill:105` says the blind spot *"**was recorded honestly as UNVERIFIABLE, not papered over** — a fresh reviewer inherits the correct blindness."* The drill's actual complaint (`:110`) was **placement** — "it lives buried in a table cell" — never absence of disclosure. This turns a landed verdict's explicit praise of a prior reviewer's honesty into an accusation that they papered something over, in a public repo. **The parallel WHY the same commit wrote at `worked-adversary-and-gate-briefs.md:119-120` gets it exactly right** ("no *standing flag* that it was unreproducible") — two adjacent adaptations, one accurate, one not. Graded Minor for consistency with how I graded round-1's m-7 (same class: inaccurate provenance gloss, correct instruction above it) — but it is the sharpest Minor in the set.
- **m-9 — `3e267e2`'s message mis-describes its own diff.** It claims "**lettered** ATTACK SURFACE items for the design adversary". They are unlettered standalone blocks placed after `(h)` (`:37-42`). The plan adversary's `(f)`/`(g)` and the gate's `9`/`10` claims are both true. **The shape choice is correct** — BASE-DELTA is a reporting obligation, not an attack surface, so keeping it outside the lettered list is right; only the description is wrong. Remedy is a record-correction line in a later commit message, not a code change.
- **m-10 — the plan adversary's `(f)`/`(g)` fit the structure but not the voice.** `(a)`-`(e)` are one terse clause each; `(f)` runs six lines (`:100-105`) and `(g)` four (`:105-109`), and `(f)` carries justification prose ("this field is what lets a rotation reviewer confirm the delta from the verdict alone…") that the `[WHY]` block added immediately below at `:115-121` already states. Both files' convention is explicit that reasoning lives in bracketed WHY blocks and gets deleted when copying. A conductor copying §3 into a real brief gets a ten-line `(f)` reading unlike its neighbours. **This is my ruling on the question the brief asked:** structure correct, voice not. Remedy: compress `(f)`/`(g)` to one clause each, let the existing WHY carry the reasoning.

## NOTES

- **N-5** — `worked-spec.md:99-100`'s "eight rows, **one per document**, each with an owner": the count is right, but `:257` bundles three documents, `:258` bundles two, and `:259` ("The parked yard design", owner "Not this train") is not a document. It is one row per *obligation*. One word.
- **N-6** — the fiction now has a small internal tension: `worked-spec.md:152` says the fictional spec review reached "Round 2: **APPROVED**", while §10 carries two **NOT CARRIED** rows describing what `:129-132` calls "a real, if small, defect in the fictional spec." One clause in §11 noting the reviewer accepted them would close it.

---

## RULINGS ON THE QUESTIONS ASKED

**Native shapes, not pastes — CONFIRMED.** `design-briefs.md` uses prose paragraphs plus that file's own `[WHY: ...]` convention and rung-specific wording ("Carry this even though you are the SAME reviewer with context intact"). The gate scopes BASE-DELTA to "when this gate has run before on an earlier state of the train." The design and spec adversaries get terse two-block additions. None is a copy of `car-brief.md`'s text. The one voice miss is m-10.

**VERDICT-line consistency — CONSISTENT where a VERDICT line exists.** §1 `:40-42`, §2 `:77-79`, §4 `:158-160`, `design-briefs.md:147-148`, `car-brief.md:176-178` all add the fields with "when applicable" / "WHEN THIS IS A RE-REVIEW" scoping that matches each field's own definition. **§3 has no VERDICT line** — it delegates, which is M-4.

**"They ARE the exemplar" framing — HONEST TEACHING, not spin.** Four reasons: it never claims the prior false rows were intentional; `c7e263e`'s message states plainly they were defects found at review; the "Known fallibility" paragraph disclosing the real spec's own false row is **kept** directly below rather than displaced by the new framing; and the substantive claim — that an honest NOT CARRIED row is what a fidelity table is *for* — is correct and is what I recommended. My own grep confirms both rows' claims are true.

**Cold-reader re-test — no new ambiguity introduced.** The m-2 conditional now reads cleanly. The NOT CARRIED rows are self-contained: each names its own grep evidence, names the header as the only home, and names the nearest near-miss. A reader needs neither my verdict nor the commit message.

---

## CONVERGENCE — cap set, not escalated

Round 1: **3 Major / 7 Minor / 4 Notes.** Round 2: **1 Major / 3 Minor / 2 Notes.** All 11 round-1 findings closed with verifiable fixes; three were fixed *beyond* the finding (row 5, the contiguous requote, the class-level re-read).

Two of the three swirl triggers technically fire: findings **cluster in the same area** (M-1 and M-4 are both "#13's fields missing from a reviewer-brief carrier"), and **M-4 was revealed by round 1's fix**. The third does not: Majors 3 → 1, declining sharply.

I am **setting a cap rather than escalating**, because the clustering is structural to the ticket — #13 *is* a placement question, so every finding about it lands in one area by construction — and the fix quality is high. But both Majors in this series came from **a search that could not see a file**, and a third recurrence would mean the class was never addressed, only its instances.

**THE CAP — what round 3 must demonstrate:** a **mechanically derived, complete inventory** of every reviewer-brief or verdict-shape carrier in the repo (not a pattern-guess — enumerate `docs/templates/*.md` and `.claude/agents/*.md` in full and open each), presented as a table with each file marked *has both fields* / *not applicable, and why*. Fixing `worked-plan.md` alone does not clear this cap. **Failing to produce that inventory escalates to the owner rather than to round 4.**

---

## MERGEABLE? **NO — not from `000111b`.**

One Major blocks. But the conductor should know the blocker is **narrowly scoped and does not touch #9 or #40**:

- **#40 (`509229a` + `7cf2e48` + `000111b`) — clean.** All findings closed, traces end to end.
- **#9 (`71d0c25` + `c7e263e`) — clean.** Both false rows corrected, the fold is now correct on its own merits.
- **#13 (`e511c5e` + `3e267e2`) — carries M-4, m-8, m-9, m-10.** One file to edit (`worked-plan.md`), plus three text corrections. A very small round 3.

## #9 DISPOSITION — restated, and now stronger

Unchanged in substance, and the fixes strengthen it: as of `c7e263e` item 1 is genuinely and verifiably delivered, so **#9's own scope is complete**.

**Recommendation at merge: close #9, having first split items 2 and 3 into their own cross-linked issues.**

1. The ticket's stated deadline — "before the next spec is written from `worked-spec.md`" — attaches entirely to item 1, which is now done and correct.
2. **Item 2 (CI walks the ledger)** is mechanism-tier work: code, a CI step, red-first proof. Its assertion is already specified (spec round 4: *the annotation must be a substring of the target*) and its pattern already exists in-repo (`repo-policy-check-patterns.md` §1 → `DocPolicy.Tests.ps1`). It belongs in a tooling train. Free intelligence for whoever takes it: round 1's N-2 still stands — §10's DR-1 row ("lane badge → Section 4") will fail that substring check, since §4 says "the three self-computing comparisons" and never "lane badge". The two new **NOT CARRIED** rows will need an explicit exemption in that checker's design, or it will red on the very rows that are most honest.
3. **Item 3 (the `Project-Bootstrapping` mirror)** can never be verified from this repo, which is exactly why it needs its own ticket rather than holding #9 open forever. Flagged again as unreproducible: I cannot open that repository.

Files: `<repo>-wt\review-process-docs\docs\templates\worked-plan.md` (the fix target), `<repo>-wt\review-process-docs\docs\templates\worked-adversary-and-gate-briefs.md`, `<repo>-wt\review-process-docs\docs\templates\design-briefs.md`, `<repo>-wt\review-process-docs\docs\templates\worked-spec.md`, `<repo>-wt\review-process-docs\docs\templates\car-brief.md`, `<repo>-wt\review-process-docs\.claude\agents\car.md`.

```starcar-artifact
outcome: REJECT
task-id: process-docs-review-r2
findings: 1 Major, 3 Minor, 2 Notes; all 11 round-1 findings CLOSED. MAJOR M-4 (NEW, revealed by 3e267e2's own fix): worked-adversary-and-gate-briefs.md:88, the plan adversary's heading, delegates its verdict shape to worked-plan.md's review record - "see worked-plan.md's review record for the verdict shape" - and worked-plan.md was not touched by this delta. worked-plan.md:169 is titled "The plan-review record (rule 5) - what the adversary hunts, and the verdict shape" and carries at :171-181 the SAME rung's dimension list as (a) through (e) while 3e267e2 changed the brief's copy to (a) through (g), and at :183-189 the verdict shape itself with neither BASE-DELTA nor an unreproducible-evidence line, and at :191-192 the words "the re-review verifies the delta; the verdict history stays in the plan" - the delta-re-review path, at the plan rung, the rung where the drill that produced ticket 13 actually ran. A conductor who writes a plan re-review brief from section 3, follows the pointer at :88, and writes the verdict in the shape found there produces a verdict with no BASE-DELTA while having followed both templates correctly. Classified NEW rather than M-1 DRIFTED because M-1's named remedy landed completely in all five carriers I named. I disclose my own round-1 miss: my search pattern was "VERDICT:|verdict template|reviewer brief|Reviewer brief" and worked-plan.md says "the verdict shape" and "The plan-review record" and matched none of them - I faulted the car for a glob that could not see a file, using a pattern that could not see a file, same class one directory over. MINOR m-8: design-briefs.md:137-139 says a finding built on a gitignored probe log "was recorded as closed with no flag that the closure itself was unverifiable by anyone else" - drill:66 records that finding as DRIFTED into C2R2-M1, not closed, and drill:105 says it "was recorded honestly as UNVERIFIABLE, not papered over"; the drill's complaint at :110 was placement, "it lives buried in a table cell", never absence of disclosure, so the WHY inverts a landed verdict's praise of a prior reviewer into an accusation; the same commit's parallel WHY at worked-adversary-and-gate-briefs.md:119-120 states it correctly. MINOR m-9: 3e267e2's message claims "lettered ATTACK SURFACE items for the design adversary" but they are unlettered standalone blocks after (h) at :37-42; the shape choice is correct since a reporting obligation is not an attack surface, only the description is wrong, so the remedy is a record correction not a code change. MINOR m-10: the plan adversary's (f) and (g) at :100-109 run six and four lines against one terse clause for each of (a) through (e), and (f) duplicates justification the [WHY] block at :115-121 already carries, against both files' stated convention that reasoning lives in bracketed WHY blocks deleted when copying - structure correct, voice not. NOTES: "eight rows, one per document" is loose since two rows bundle several documents and one is not a document; the fiction's section 11 says round 2 APPROVED while section 10 now carries two NOT CARRIED rows describing what the new paragraph calls a real if small defect. ROUND-1 WALK, all CLOSED and each re-verified at 000111b: M-1 both fields in all five named carriers in genuinely native shapes with every VERDICT line amended and a RECORD CORRECTION paragraph in the commit; M-2 the ledger row now says no mutable process state with 0 to 0 arithmetic quoting section 5 verbatim and still teaching the mandatory-none-row discipline; M-3 both rows NOT CARRIED and re-derived by my own grep - threshold tokens only at :23 header, :41, :60, :70 with section 3 silent, and "never the browser clock alone" only at :22 - plus the car extended the fix to row 5 unasked; m-1 REPORT THE OBSERVED VALUES landed; m-2 the conditional now agrees with the field definition; m-3 the paired agent definition carries the visual-guard clause; m-4 now cites the real design's section 8 with eight rows, which I counted at :252-259; m-5 the heading reads folded not closed; m-6 the drill quote is now a contiguous verbatim substring in source order with no ellipses, walked word for word; m-7 names both gaps; N-1 credits the human eye per #33's own account. RULINGS ASKED FOR: native shapes CONFIRMED not pastes; VERDICT lines internally consistent wherever one exists, section 3 having none is M-4; the "they ARE the exemplar" framing is HONEST TEACHING not spin on four grounds including that the Known fallibility disclosure is kept rather than displaced; cold-reader re-test finds no new ambiguity and the NOT CARRIED rows are readable without the verdict in hand. SUITES at 000111b: scripts/tests 181 passed 0 failed 1 skipped 182 total, store-checks 178 of 178, DocPolicy 2 of 2 green, tree clean. CONVERGENCE: 3 Majors to 1, all 11 prior findings closed, three fixed beyond the finding; two swirl triggers technically fire (same-area clustering, a fix-revealed defect) but Majors are declining sharply and the clustering is structural to a placement ticket, so I SET A CAP rather than escalate - round 3 must produce a mechanically derived complete inventory of every reviewer-brief and verdict-shape carrier in the repo, enumerating docs/templates and .claude/agents in full and opening each, marked has-both-fields or not-applicable-and-why; fixing worked-plan.md alone does not clear the cap; failing to produce the inventory escalates to the owner rather than to round 4. NOT MERGEABLE from 000111b, but the blocker is isolated: #40 and #9 are both clean, and all four round-2 findings sit on the #13 commit chain, one file plus three text corrections.
abstract: Round-2 delta re-review of four fix commits (7cf2e48, 3e267e2, c7e263e, 000111b) against round 1's eleven findings at base 71d0c25. All eleven are closed with verifiable evidence, three of them fixed beyond what the finding asked. REJECT on one new Major: the plan adversary brief delegates its verdict shape to worked-plan.md, which this delta did not touch, so the plan rung - the rung where the drill that produced ticket 13 actually ran - still has a verdict shape with neither new field, and its dimension list now diverges from the brief's. Round 1 missed this file for the same reason the car's original search did, which I disclose. Three Minors: a WHY block that inverts a landed verdict's account of a prior reviewer, a commit message that mis-describes its own diff, and a voice mismatch in the plan adversary's new dimensions. All suites green and re-derived independently. Cap set on the search-completeness class rather than escalating. #9 disposition restated and strengthened: its own scope is now complete and correct.
```