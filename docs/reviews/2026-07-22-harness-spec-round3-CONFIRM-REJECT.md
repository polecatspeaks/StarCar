<!-- starcar-integrity: sha256=467327a23b78cde3d4f606228a4ec4bea0eba6a9de3ebc8cc4f4dd44f1556e5f covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Adversarial spec review - dispatch harness, round 3 (fix-and-confirm)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: spec review (ladder rung 2)
Round: 3 (fix-and-confirm)
Target: `docs/specs/2026-07-22-dispatch-harness-spec.md (rev 3)`
Base reviewed: `719f46cb71c9a4a9abeb525feefe573b3b07a7e9`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT - 1 Major, 1 Minor, both mechanical; N1 CLOSED on substance; spec substance ruled PLAN-READY**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a543c37ea68e622d8`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `719f46cb71c9a4a9abeb525feefe573b3b07a7e9` |
| Entire checkpoint | `00d1146416f9` |
| Dispatch, the locator within the session | `a543c37ea68e622d8` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 719f46cb71c9a4a9abeb525feefe573b3b07a7e9
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

VERDICT: **REJECT** — N1's substance is genuinely CLOSED and every other item confirmed, but six of the spec's eight numeric `design:NNN` citations are now off by one (including the anchor under a verbatim quote and both anchors of the N1 fix itself), because the design file gained a line in this same commit range.

Base `719f46cb71c9a4a9abeb525feefe573b3b07a7e9`, clean tree before and after, no fault injection. Suites run by me at this SHA: **Pester 21/21 passed, 0 failed, 0 skipped**; **`Verify-Verdict.ps1`: 9/9 hashes match, exit 0**.

---

## N1: **CLOSED** — the substance was added, not just the row corrected

Checked by mechanism, not by the ledger:

- **New §3.6 "Publication and trust"** carries all three obligations explicitly:
  - *"The normalisation rule is DECLARED IN EACH LANDED ARTIFACT"* — matches design §5.7 (`design:215-216` at this SHA), *"with the rule declared in each artifact"*.
  - *"The un-normalised original is PRESERVED on the checkpoint branch"* — matches *"the original preserved on the checkpoint branch"*.
  - *"Each artifact carries an integrity hash, and its independent counterpart is the checkpoint copy"* — matches the design's failure-mode row *"Integrity check fails; the checkpoint branch holds an independent copy"* (at `design:234`).
- It also correctly preserves the legitimate deferral: *"Only the substitution rule itself is deferred to the schema artifact"* — consistent with design §0.
- **The `design §9` miscitation is gone.** The row now reads *"Publication + trust (`design:5.7`, `design:233`) … | **§3.6**"*. I opened §3.6: it genuinely mentions all three. This is a substance fix, not a pointer fix.
- The §3.6 header openly states the prior defect (*"Rev 2's fidelity ledger asserted they landed in §8; §8 is silent on them… The substance was genuinely absent"*), which is the correct disposition.

The finding is closed on its merits.

---

## §10 THIRTEEN-ROW RE-WALK

| # | Row | Verdict |
|---|---|---|
| 1 | P1 one writer / read-only detector → §2 | Lands; untouched by this diff |
| 2 | P2 dispatch-event grain → title, §3 | Lands; title and §3 deferral list unchanged |
| 3 | P4 hook fires on stop → §2.1 | Lands; untouched |
| 4 | P6 context producer-optional → §3.4 | Lands; untouched |
| 5 | Kind precedence + three supersession cases → §3.1 | Lands; the m6 insertion added text above the precedence lines without displacing any of the three cases |
| 6 | Liveness gradient + budget + shop default → §3.3 | Lands; untouched |
| 7 | Envelope, absent vs malformed → §2.3 | Lands; untouched |
| 8 | Concurrency write rule → §2.4 | Lands; untouched (but see N2 — its `design:230` anchor no longer resolves) |
| 9 | Vocabularies as data → §3.2 | Lands; untouched |
| 10 | Two-tier detection, tier rendered → §2.5 | Lands; §2.5 reworded to *"the fold exposes which tier is in force"*. Left column keeps the design's own phrasing ("tier rendered"), which is correct — that column names design items, not spec requirements |
| 11 | Cost/context split, dark lane → §3.4 | Lands; untouched |
| 12 | Ruling Q2 un-backfilled gap → §3.5 | Lands; untouched |
| 13 | **Publication + trust → §3.6** | **Now lands.** Was the false row; target section exists and contains all three obligations |

**Correcting row 13 did not break another row.** All thirteen resolve.

---

## THE FOUR CHEAP ONES

- **n2 (rendering residue):** CLOSED — §2.5 now reads *"**The fold exposes which tier is in force**; what the board draws with it is #1's job (§3.1)"*, exactly as ruled.
- **n3 (migration commit owner):** CLOSED, and better than filed — new §9 row assigns it to Car 3 *and* sequences it (*"car 1 lands the index generator first so car 3 has something to invoke. Sequenced, not guessed"*).
- **n5 (false §12 claims):** CLOSED — §12 now states *"**m4 and m6 were claimed closed in rev 2 and were NOT**"* and folds both properly.
- **m4:** CLOSED — §3's preamble now rules the boundary: a behavioural rule may name a field *"to be stated at all… that is the rule identifying its subject, not this document specifying a schema."* Clean.
- **m6:** CLOSED on substance, and it answers more than I asked: *"'Subject' and 'dispatch' are the same key for the three dispatch kinds… `intent` and `ruling` have non-dispatch subjects."* (Its citation is wrong — n6 below.)

---

## NEW FINDINGS INTRODUCED BY THE FIX

### MAJOR — N2: six of eight numeric `design:NNN` citations are off by one, root-caused to one hunk in this same commit range

`git diff 7e49d43 3fba437 -- docs/design/2026-07-22-dispatch-harness-design.md` shows the design's `Status:` line was split from **one line into two** by the repo-policy commit. Everything from line 3 onward shifted **+1**. I verified several of these citations as *exact* in round 1 at `7e49d43`; they have drifted since, and rev 3 added two more by carrying forward locators from my own round-2 verdict, which was written against the pre-shift base.

| Citation | Where | Line now shows | Correct |
|---|---|---|---|
| `design:26` | §3.6 — *"assigns publication and trust to the behavioural half"* | the **Format / algorithm** row — the *opposite* half of the §0 split | `:27` |
| `design:230` (used twice) | §2.4 — anchors the **verbatim** concurrency quote | `\| Spend unavailable \| Fuel lane dark…` | `:231` |
| `design:233` | §3.6 **and** §10 row 13 — integrity + independent copy | `\| A gap detected and never backfilled…` | `:234` |
| `design:137` | header note — *"one record per dispatch event"* | a blank line | `:138` |
| `design:228` | §3.2 — *"one board-level fault, never N per-lane faults"* | the unrecognised-value row | `:229` |
| `design:257` | §4 row 6 — where the M1 claim was inherited from | off by one | `:258` |
| `design:37` | §3.6 | lands **by accident** (the shift moved a better line into place) | — |
| `design:147-150` | §3.2 | lands, range clipped at the tail | — |
| `design:5.7` | §10 row 13 | **immune** — section anchor, not a line number | — |

**Why Major and not Minor.** Round 1 I filed M1 as Major on the stated rule that a wrong citation is Major *because it sends a car to the wrong code*, and I must apply that consistently. The `design:230` instance is the sharpest: it anchors a quote reproduced **verbatim** in §2.4 (*"the producer writes its own path only and never `git commit -a`…"*). A car or the plan adversary re-deriving that quote opens `:230`, finds an unrelated spend row, and gets a false "the spec is fabricating its source." The next rung's adversary is now *mandated* by `CLAUDE.md` to walk citations row by row — six systematically false locators turn that mandated walk into a lying instrument, which this repo holds is worse than none.

**The class, not the instance.** Line-number citations into living documents drift silently on any edit anywhere above them. Note that §10 row 13 contains both forms side by side: `design:5.7` survived the shift, `design:233` did not. The cheap guard is to cite section anchors into documents still under edit, and/or a Pester check that every `file:NNN` citation under `docs/` resolves to a line containing an expected token — a natural sibling to `DocPolicy.Tests.ps1`, which already exists and cannot see this.

**The irony is worth recording:** the commit that installed a *documentation-policy gate* is the commit that invalidated six citations in the document under review, and the gate it installed checks only that a `Status:` line exists.

### MINOR — n6: `design §4.3` does not exist

§3.1's new m6 fold ends *"Identity is the schema artifact's (design §4.3)."* The design has no §4.3 — §4 is a flat decision table (D1–D8) with no subsections; I enumerated every heading in the file. Identity is assigned at **design §5.1** (`:141-142`): *"Field lists, types, ordering and identity are the schema artifact's job."* The claim is true; the locator is invented. Closes in the same pass as N2.

---

## RULINGS ON THE TWO DISPOSITIONS YOU ASKED ME TO BE SCEPTICAL OF

**n5 — recording the false claims rather than quietly correcting them: CORRECT, and it should stay.** Quietly rewriting would make rev 3 indistinguishable from a rev 2 that had been right all along, which is precisely the drift the design's own §9b exists to prevent (*"three rulings were silently dropped across rounds 2-5, and none was visible"*). More concretely: the "fold that LOOKS folded" class is only *detectable* if the prior claim stays on the page — erase the false closure and you erase the evidence that the closure-claiming mechanism can fail. Readability cost is one sentence; §12 is ~20 lines covering three rounds, which is proportionate. **Stated threshold for later:** if §12 ever outgrows the spec's own substantive sections, roll the narrative into the landed verdict files (hash-verified, permanent) and keep §12 as a table of IDs and outcomes. Not yet.

**n4 — deleting the count rather than correcting it: LEGITIMATE, not evasion.** The row's job is to tell a stranger where verdicts live and that they are hash-verified; the number served no navigational purpose and had a demonstrated defect rate of one per verdict landing (7 → 8 → 9 within a morning). Writing "Nine" would have re-armed the identical trap for the next landing. Removing a mutable claim that no reader needs and no gate can check is the Healing Loop's "cheapest layer that could have caught it" applied honestly, and the replacement text states its own reasoning. **Your related point is correct and I confirm it:** `scripts/tests/DocPolicy.Tests.ps1:42-55` reads only the first five lines and matches `^Status: (Current|Done|Superseded|Open)$` — it verifies that a document *declares* a standard, never that the body meets it. `Status: Current` is therefore an attention-tier guard with a mechanical wrapper, and N2 above is the second finding in two rounds that it structurally cannot see.

*(Out of scope but worth one line: the `worked-spec.md` KNOWN GAP disclosure is the right call — *"amending an exemplar with an unreviewed invention is inventing prior art"* is exactly correct, and disclosing the hole while refusing to fold an ungated fix is better than either silence or premature amendment.)*

---

## MAY THE SPEC PROCEED TO THE PLAN RUNG?

**Not as it stands — but the gap is six numbers and one section reference, and it needs no review round, only a mechanical re-confirm.**

To be plain about the decision you need: **the spec's substance is plan-ready.** Every requirement is present and correct, every finding from two rounds is closed, all six rulings adopted as ruled, all thirteen fidelity rows resolve, and both carrier sections do real work. Nothing about the architecture, the contracts, the retirement list, the lifecycle section, or the test cells is in question. I am not asking for another document attack.

**What must close first (one commit, mechanical):**
1. Re-anchor `design:26 → :27`, `design:230 → :231` (both uses), `design:233 → :234` (both uses), `design:137 → :138`, `design:228 → :229`, `design:257 → :258`.
2. Fix `design §4.3 → design §5.1` in §3.1.
3. Strongly recommended in the same commit: convert numeric locators into the design to section anchors (`design §5.7`-style), since the design is still a living document and will drift again. Ticket the citation-resolution CI check separately — that is the guard, and it belongs with issue #9's template work, not in this train.

Re-confirm by running the six lookups; if they resolve, this is an APPROVE and the spec goes to plan. I would not spend another full round on it.

---

```starcar-artifact
outcome: REJECT
findings: 1 Major, 1 Minor (both mechanical); N1 CLOSED on substance; all 13 fidelity rows resolve; n2, n3, n5, m4, m6 all CLOSED; both disputed dispositions ruled legitimate
abstract: |
  Fix-and-confirm review at base 719f46cb71c9a4a9abeb525feefe573b3b07a7e9. Read-only, no
  fault injection, tree clean before and after. Suites run by the reviewer at this SHA:
  Pester 21 passed, 0 failed, 0 skipped; Verify-Verdict 9 of 9 hashes match, exit 0.

  N1 is CLOSED on substance, not merely on the pointer. The new section 3.6 carries all
  three previously-absent behavioural obligations: the normalisation rule declared in each
  landed artifact, the un-normalised original preserved on the checkpoint branch, and an
  integrity hash whose independent counterpart is the checkpoint copy. The design-section-9
  miscitation is gone and the ledger row now points at a section that genuinely contains
  them. All thirteen fidelity rows were re-walked and all thirteen resolve; correcting row
  13 broke none of the other twelve. n2, n3, n5, m4 and m6 are all closed, with n3 and m6
  answering more than the findings asked.

  One new Major, introduced across this commit range rather than by the author's reasoning.
  The design document's Status line was split from one line into two by the repo-policy
  commit, shifting every line from three onward by plus one. Six of the spec's eight
  numeric design line citations no longer resolve: design 26 now shows the Format row
  rather than the Behavioural row it is cited for, design 230 anchors a verbatim
  concurrency quote but now shows an unrelated spend row, design 233 anchors the integrity
  obligation but now shows the gap-never-backfilled row, and design 137, 228 and 257 are
  each off by one. Two land, one by accident. The section-anchor form in the same ledger
  row survived the shift while the line-number form beside it did not. Rated Major for
  consistency with the round-one standard that a wrong citation is Major because it sends a
  car to the wrong place, and because the next rung's adversary is now mandated to walk
  citations row by row, which six false locators would turn into a lying instrument. One
  Minor: section 3.1 cites design section 4.3, which does not exist; identity is assigned
  at design section 5.1.

  Both disputed dispositions ruled legitimate. Recording the false rev-2 closure claims
  rather than quietly correcting them is correct, because the fold-that-looks-folded class
  is only detectable if the prior claim stays on the page; a threshold is stated for when
  the narrative should move into the landed verdict files. Deleting the hardcoded verdict
  count from setup.md rather than correcting it is a legitimate fix, not evasion: the
  number had a demonstrated defect rate of one per verdict landing and served no
  navigational purpose. The related limitation is confirmed: the DocPolicy Pester gate
  reads only the first five lines and checks that a Status line exists, never that the body
  beneath it is true, so it could not have caught either this or the citation drift.

  Disposition: the spec's substance is plan-ready and no further document attack is needed.
  Six line numbers and one section reference must be re-anchored in one mechanical commit,
  ideally converting numeric locators into the still-living design document to section
  anchors. Re-confirm by running the six lookups; if they resolve, this is an APPROVE and
  the spec proceeds to the plan rung. The citation-resolution CI check belongs with the
  template ticket, not with this train.
```