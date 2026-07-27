<!-- starcar-integrity: sha256=64ae96702f4269e167e539df10ec0783a9035347d77b78d325636027b86c31e4 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Design #87 owner-amendment (Q1 ruling fold), scoped adversarial review

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: adversarial design review, scoped to the owner-amendment delta
Round: amendment
Target: `design/member-identity-87 rev 4 HEAD e40677d`
Base reviewed: `2ade67fb7747b55cecc51ad18d0d78f1b530018a`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `afe18ef8acbb02719`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `2ade67fb7747b55cecc51ad18d0d78f1b530018a` |

| Dispatch, the locator within the session | `afe18ef8acbb02719` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 2ade67fb7747b55cecc51ad18d0d78f1b530018a
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All checks complete. Writing the verdict.

# VERDICT: **REJECT** — 2 Major, 1 Minor. Scoped to the amendment.

The ruling is folded thoughtfully and **D10 is correct** — I confirmed its mechanism empirically and it is the amendment's best line. The REJECT rests on the new measurement: its headline figure answers a different question than its own sentence asks, and the same measurement has a second implication for D5 that the amendment never draws.

## BASE-DELTA (#13)

Worktree `<repo>-wt\review-design-87`, **detached** at `e40677d22ee4cd4a20d9c4b3a034c1283405ec05`, **0 dirty** — verified before any command. Prior approved HEAD `2ade67fb7747b55cecc51ad18d0d78f1b530018a`.

```
 .../2026-07-27-manifest-member-identity-design.md  | 377 ++++++++++++++++++---
 1 file changed, 330 insertions(+), 47 deletions(-)
```

Matches the reported +330/-47. Rev 3 not re-opened; only the delta reviewed.

## Suites at `e40677d`, detached

| Suite | Claimed | Observed | Reconciles |
|---|---|---|---|
| `scripts/tests` | 223 P / 0 F / 4 S | **222 P / 0 F / 5 S** (227) | yes — same detached delta as rounds 2-3 |
| citation gates | 43 P / 0 F / 4 S | **43 P / 0 F / 4 S** (47) | exact |

**Sixth injection coordinate** (`docs/constitution.md:46-51` → `:460051`), unused by any prior round: 27 P / **1 F** / 4 S, reding by name — *"…:114 cites 'docs/constitution.md:460051' - target file has fewer lines"*. Restore in a **separate call** via `git checkout --`, verified **both ways** per the new hazard: sha256 `DE12386D…D0DC` identical, and `git diff HEAD` = **0 lines**, dirty 0.

---

# FINDINGS

## **A1-M1 (Major) — PR-8's headline figure is false by the design's own stated metric, in seven places.**

§2b PR-8 (line 327) states the metric precisely: *"for every runtime `subject`, **how many distinct shop handles (`task_id`s on its `returned` records)** does it serve?"* — then answers *"**43 of 109** subjects serve MORE THAN ONE member."*

**Measured by me over the same store, by that exact definition: 26, not 43.**

```
A) distinct task_id count GT 1        : 26      &lt;- the stated metric
B) returned-record count GT 1         : 43      &lt;- what 43 actually counts
```

**The 17-subject gap is the opposite of the claim.** Those subjects hold **35 returned records between them, 0 carrying `task_id`** — pre-#47 fossils predating the envelope echo. They serve **zero identified members**, not "more than one". Six of the 17 are `train:board-v0` members from the legacy corpus I measured in round 1.

**Seven locations:** lines 39 (header), 327 (PR-8), 421 (D10's reason column), 995 (*"wrong on more than a third of this shop's real corpus"* — 26/109 is 24%, about a quarter), 1000 (§5.8a), 1123 (§9b), 1328 (Q9).

**Everything else in PR-8 is exact, and I want that on the record separately:** 109 subjects ✓; **76 distinct handles ✓** (unaffected, precisely because the 17 contribute none); max FIVE rounds ✓; **every multi-group has exactly one `dispatched`, 0 exceptions ✓**; and all three named exemplars exact — `ab2bd332be0eebc2c` = `tooling-65-car-r1`…`-r5` **all `SUCCESS`** ✓, `af5f0b4f753a8f9d7` = `tooling-50-32-car-r1`…`-r5` ✓, `a353ad2db7e6ad627` = `view-75-review-r1/r2/r3` ✓.

**D10 survives with a wide margin** — 26 subjects and 76 handles is ample basis, and I confirmed the mechanism directly (below). This is a correction, not a redesign.

**Class, and it is why this is Major rather than Minor:** this is DR1-M1's exact shape at the same rung — a real number answering a different question than its sentence asks — inside the section whose own opening promises *"every behavioural claim in this document is traceable to an observation rather than a reading."* The author diagnosed DR1-M1's root cause as *"a reading dressed as a measurement"*; this is one measurement dressed as another.

**Constructive: the honest statement is stronger than the false one.** *"26 subjects are MEASURED to serve more than one member; a further 17 have multiple returned records carrying no handle at all, so what they served is **unknowable**."* Unknowable provenance is an even worse thing to dereference than shared provenance — the correction reinforces D10.

## **A1-M2 (Major) — PR-8 makes an unresolved ambiguity in D5 outcome-determining, and one reading reproduces this design's own founding defect on a quarter of the store.**

§5.5 states the join over "**a record**". But a bound member's liveness, outcome and superseded history come from a **fold entry** — `board/assemble/assemble.go:110` (`dispatchBySubject[m.Subject]`, built from `fold.Output`) — and the fold keeps **exactly one entry per subject** (`board/fold/algorithm.go:154-163`, `foldDispatchSubject` returning one `DispatchEntry` per subject).

**Measured.** I wrote the real `ab2bd332be0eebc2c` shape into a scratch store — 1 `dispatched` + 5 `returned`, distinct handles, outcomes REJECT×4 then APPROVE — and ran the real board:

```
RECORDS WRITTEN: 6 under ONE subject
DISPATCH ROWS RENDERED: 1
  subject=ab2bd332be0eebc2c state=returned outcome=APPROVE taskId=tooling-65-car-r5 superseded=5
```

**Under fold-entry semantics, only `-r5` can bind.** Members `-r1`…`-r4` render *"declared, no departure bound"* **while their returned records sit in the store carrying their handles and their outcomes** — and **no condition is raised**, because the single fold entry IS assigned, to `-r5`. That is precisely PR-1's Law 1 shape — the board asserting members have not departed while holding their returned records — arriving through the fold collapse instead of through shape B, on the 26 subjects and 76 handles PR-8 just measured.

Under raw-record semantics all five bind, but then liveness and superseded history must come from somewhere the fold does not provide per member, which the design also does not specify.

**The amendment draws exactly one conclusion from PR-8 — D10, about the pointer — and never asks the same question of D5, its central mechanism.** §5.8a's own sentence applies verbatim to the binding: *"the collapse happens in the fold before any consumer sees it."* A `grep` for `fold winner` / `fold entry` / `raw record` finds the collapse addressed only for the pointer (line 1013) and for manifest supersession (line 1024).

**In scope:** PR-8 is new work introduced by this amendment, and this is its unexamined implication. The underlying fact is the one the ruling names as *"the same fact behind #89"*. **Likely a small fix:** say whether §5.5's join runs over raw records or fold entries; if fold entries, add a §6 failure row and a vector for the members a resumed agent served that the fold cannot surface.

## **A1-m1 (Minor) — a FOURTH surviving D2-strict claim, undisclosed. The sweep reports three.**

**P3, lines 177-180:** *"A structured identity … would let a member carry the binding inline. That is precisely the shape P5 kills: **it puts a runtime fact inside a plan record**, and it re-imports mutation, supersession-of-identity and ordering."*

D2′ now expressly permits a runtime fact inside a plan record, so P3's first stated ground is superseded — **the same shape as disclosed survivor (c)** (V13's *"D2 gives the manifest no runtime fact to mutate toward"*), annotated nowhere. P3's *conclusion* survives on independent grounds (D1/D3 keep identity one string; D10 keeps the pointer out of identity), so harm is bounded — but the sweep is presented as complete at three and it is four. One annotation fixes it.

*Sweep otherwise verified complete:* I grepped independently for D2-strict phrasings and the only other hits are D2 itself (correctly struck, line 419) and the two disclosed survivors.

---

# RULINGS ON THE FIVE

**1. D10 — CORRECT, not over-strict, adequately specified. Say it plainly, as asked.** I tested the reasoning against the real fold rather than accepting it, and the probe above is the confirmation: five rounds under one runtime id collapse to **one** row carrying round 5's outcome. Had five members pointed at that subject and the board dereferenced, all five would have rendered round 5 — four rows in five false, and entirely plausible-looking. The reasoning is exactly right, including *"no amount of care in the implementation removes it, because the collapse happens in the fold."* **Not over-strict:** conditional dereferencing (only when 1:1) would require scanning every manifest at render time and would silently flip unsafe the moment a member is added later. **Not under-specified:** §5.8a names the permitted use — a link to the record *directory* — which stays honest under many-to-one because the directory shows all rounds rather than one false row. *Bonus for the format car: `af5f0b4f753a8f9d7` is the better V19 exemplar than the one cited — its five rounds carry MIXED outcomes (`done-with-findings` at r2, `done` elsewhere), so dereferencing there mislabels a findings round as clean.*

**2. The measurement — re-derived above.** Six of seven figures exact; the headline is A1-M1.

**3. The field spec (§5.8) — precise enough for a format car, and "raw and byte-verbatim" IS testable.** Placement, type, optionality, and three explicit NOs (not identity, not a join key, not a liveness source) each map to a vector. Byte-verbatim has a testable meaning because V18 pins `observed_subject` == the record's `subject` byte-for-byte, with the withdrawn composite as the red half. The name reasoning is sound — carrying the ruling's own vocabulary rather than renaming underneath it, with `ran_as` and `runtime_subject` named and declined for stated reasons.

**4. The falsification sweep — three disclosed survivors all real and honestly handled; a fourth exists (A1-m1).** P4's treatment is exemplary: *"THE ANTECEDENT CAME TRUE AND THE CONSEQUENT DID NOT"*, recorded as a miss rather than deleted, *"because a premise table whose wrong forecasts vanish teaches nothing about how to forecast."* P5's four-claim status table correctly separates the surviving narrow form from the over-reach, and naming *"sufficiency is not exclusivity"* is the right diagnosis of its own error.

**5. The five vectors — writable, and V18's red half genuinely reds.** V18's red half is a pointer carrying `-r2`; no record subject ever carries a suffix, so a byte-verbatim comparison fails — and it usefully traps anyone re-proposing the withdrawn composite. V19 is the vector that protects the ruling and is writable (I built essentially its fixture). V20's two directions are both record-checkable. V21's NO-BACKFILL pin is right. V17 folds my Q5 ruling as ruled. **Arithmetic verified: 13 in-table (V1,V2,V11 / V3,V4 / V5,V6,V15 / V7 / V8,V9,V17 / V13) + 8 post-§0 (V10,V12,V14,V16,V18,V19,V20,V21) = 21 = V1–V21, no overlap, none orphaned.**

**Also confirmed honest:** the §9b round-1 disposition row appends a `[REV-4 NOTE]` rather than rewriting — it preserves what rev 1 recorded, names the superseding decision, and quotes the exact sentence the owner overruled with the reasoning. The header's cap paragraph now reads *"Rev 3 was APPROVED (0 Major, 4 Minor; the round-2 cap did NOT fire) and merged to `dev` at `8bcaf10`"* — accurate to my verdict. **All four DR3 Minors folded**, DR3-m2 taking *both* rows I offered plus carrying my not-fix-created note forward, and DR3-m4 splitting option (ii) into (ii-a)/(ii-b) with (ii-b) priced as manufacturing an invisible dispatch and **recommended for outright rejection** rather than quietly dropped.

---

## CONSTITUTION CHECK (scoped)

- **Law 1** — *Honored* in D10, which exists solely to prevent a plausible falsehood, and in §5.8's three explicit NOs. *Violated* at **A1-M1** (a figure that answers a different question, seven times) and *risked* at **A1-M2** (one reading of D5 reproduces PR-1's falsehood shape).
- **Law 4** — *Honored* in V21's absent-is-normal pin and in DR3-m4's pricing of (ii-b). *At risk* under A1-M2's fold-entry reading: four rounds in five losing their binding with no condition raised.
- **Law 6** — *Honored*, and the owner's own reasoning is correctly carried: drift needs a value that can change, and a sealed record's id cannot. §5.8b correctly separates *"not drift"* from *"not checkable"* — that distinction is the amendment's second-best line.
- **Law 7 / NO-BACKFILL** — *Honored*: V21 pins that no landed record acquires the field and that a validator requiring it is mis-specified.
- **Owner-ruling fidelity** — *Honored.* The ruling is folded as ruled, its reasoning preserved in §4a, the withdrawn composite kept as a test rather than a memory, and D2 struck with the author's superseded argument left legible above it.
- **Law-first diagnostic** — holds. Both Majors are evidence and specification defects, not absent constraints.

## UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

Everything here is re-derivable from the repo alone. PR-8: walk `artifacts/**/*.json`, group `dispatched`/`returned`/`presumed-lost` by `subject`, count **distinct `task_id` on returned records** per subject. The D10 probe: `go build ./server`; write 1 `dispatched` + 5 `returned` under one subject with distinct `task_id`s and differing outcomes, sealed via `Get-Sha256Hex`; run with `STARCAR_STORE_PATH`, `STARCAR_PORT=0`; read `/api/snapshot`. Script at `~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\8a347c36-20b4-427a-ae0b-46855aa7bb72\scratchpad\d87\d10-probe.ps1` — session-local; the recipe is the durable form.

## What a fix needs, and what the format car gets

**Both Majors are small.** A1-M1: re-run the metric, correct seven locations, and use the richer honest statement (26 measured + 17 unknowable) — it strengthens D10. A1-M2: one sentence saying whether §5.5 joins over raw records or fold entries, plus a §6 row and a vector if fold entries. A1-m1: one annotation on P3.

**On approval, the format car builds** the executable format half: schema delta plus **V1–V21** conformance vectors plus red-first tests in `schema/vectors/`, with **V12 and V15 demonstrated RED ON ARRIVAL** and V18's composite red half observed failing.

**Q9 does NOT need to reach the owner before briefing.** The owner ruled that the field exists; how the board *treats* it is design, and it was routed to me — **I rule D10 as written.** The owner should be *informed* rather than asked, and told that reversing it is available at any time, with V19 as the guard that would red if someone tried dereferencing meanwhile. **Q2 remains the only owner-blocking item**, and it gates D8/V16 only — the format car can be briefed on V1–V15 and V17–V21 without it. Q1 is closed by the ruling this amendment folds.

```starcar-artifact
task-id: design-87-amendment-review
outcome: REJECT
findings: 2 Major, 1 Minor, scoped to the owner-amendment delta only; rev 3 not re-opened. A1-M1 (Major) PR-8's headline figure is FALSE by the design's own stated metric and appears in seven places. The PR-8 row states the metric precisely as how many distinct shop handles, meaning task_id values on its returned records, each runtime subject serves - and answers 43 of 109. Measured by me over the same store by that exact definition the answer is 26, not 43; the 43 is the count of subjects with more than one RETURNED RECORD, a different question. The 17-subject gap is the OPPOSITE of the claim: those subjects hold 35 returned records between them with ZERO carrying task_id, pre-issue-47 fossils predating the envelope echo, so they serve zero identified members rather than more than one, and six of the 17 are train-board-v0 members from the legacy corpus. Seven locations: header line 39, PR-8 line 327, D10's reason column line 421, line 995 where it becomes wrong on more than a third of the corpus when 26 of 109 is about a quarter, section 5.8a line 1000, section 9b line 1123, and Q9 line 1328. EVERYTHING ELSE IN PR-8 IS EXACT and I want that recorded separately - 109 subjects, 76 distinct handles (unaffected precisely because the 17 contribute none), max FIVE rounds, every multi-group holding exactly one dispatched with zero exceptions, and all three named exemplars exact including all-SUCCESS on ab2bd332be0eebc2c. D10 survives with a wide margin. The class is DR1-M1's exact shape at the same rung, a real number answering a different question than its sentence asks, inside the section whose opening promises every claim traces to an observation; and the honest restatement is STRONGER than the false one, since 26 measured plus 17 unknowable makes unknowable provenance an even worse thing to dereference. A1-M2 (Major) PR-8's measurement makes an unresolved ambiguity in D5 outcome-determining and one reading reproduces this design's own founding defect on a quarter of the store. Section 5.5 states the join over a RECORD, but a bound member's liveness, outcome and superseded history come from a FOLD ENTRY at board/assemble/assemble.go:110, and the fold keeps exactly ONE entry per subject at board/fold/algorithm.go:154-163. MEASURED: I wrote the real ab2bd332be0eebc2c shape, one dispatched plus five returned with distinct handles and outcomes REJECT four times then APPROVE, and the board rendered ONE row, state returned, outcome APPROVE, taskId tooling-65-car-r5, superseded 5. So under fold-entry semantics only r5 can bind while members r1 through r4 render declared-no-departure-bound with their returned records sitting in the store carrying their handles and outcomes, and NO condition is raised because the single fold entry is assigned to r5 - precisely PR-1's Law 1 shape arriving through the fold collapse instead of through shape B, across the 26 subjects and 76 handles PR-8 just measured. Under raw-record semantics all five bind but liveness must come from somewhere the fold does not provide per member, also unspecified. The amendment draws exactly one conclusion from PR-8, D10 about the pointer, and never asks the same question of D5 its central mechanism, though section 5.8a's own sentence that the collapse happens in the fold before any consumer sees it applies verbatim to the binding. A1-m1 (Minor) a FOURTH surviving D2-strict claim at P3 lines 177-180, undisclosed while the sweep reports three - P3 rejects a structured identity because it puts a runtime fact inside a plan record, which D2-prime now expressly permits, the same shape as disclosed survivor (c); P3's conclusion survives on independent grounds so harm is bounded. RULINGS - D10 is CORRECT, not over-strict, adequately specified, and I tested the reasoning against the real fold rather than accepting it: conditional dereferencing would need a full manifest scan at render time and would silently flip unsafe when a member is added later, and the permitted use, a link to the record DIRECTORY, stays honest under many-to-one because the directory shows all rounds. Bonus for the format car - af5f0b4f753a8f9d7 is a BETTER V19 exemplar than the one cited because its five rounds carry MIXED outcomes, so dereferencing there mislabels a findings round as clean. The section 5.8 field spec is precise enough for a format car and raw-and-byte-verbatim IS testable via V18. The falsification sweep's three disclosed survivors are all real and honestly handled, with P4's antecedent-came-true-consequent-did-not treatment exemplary. All five new vectors are writable and V18's red half genuinely reds since no record subject ever carries a suffix. Vector arithmetic verified 21 equals V1 through V21, 13 in-table plus 8 post-section-0, no overlap, none orphaned. The section 9b rev-4 note appends rather than rewrites and quotes the exact sentence the owner overruled; the header's cap paragraph correctly records rev 3 APPROVED with the cap not firing. All four DR3 Minors folded, DR3-m2 taking BOTH offered rows plus carrying my not-fix-created note, DR3-m4 splitting option (ii) with (ii-b) priced as manufacturing an invisible dispatch and recommended for outright rejection. Suites at e40677d detached - scripts/tests 222 passed 0 failed 5 skipped reconciling with the claimed attached 223/0/4 via the SessionStartGuardRunner branch-conditional skip, citation gates 43/0/4 exact. Sixth injection coordinate constitution.md:46-51 reds the gate by name at document line 114; restore issued as a separate call via git checkout and verified BOTH ways per the new hazard, sha256 DE12386D47B14B026BB2630EF49F17FF5CC349185226F9B025FCC2E3F782D0DC identical and git diff HEAD zero lines. Both Majors are small fixes; Q9 does NOT need the owner since I rule D10 as written and the owner is informed rather than asked, and Q2 remains the only owner-blocking item, gating D8 and V16 only.
abstract: Scoped adversarial review of an owner amendment to the manifest member identity design at e40677d over the approved rev-3 HEAD 2ade67f, one commit of plus 330 minus 47 lines folding the owner's Q1 ruling that overturned D2 and permits a member to carry the runtime id as a raw pointer. REJECT on two Majors, both in the amendment's own new work rather than in the ruling, which is not reviewable and is folded faithfully. The amendment's best line is correct and I confirmed it by measurement rather than argument: the author decided on its own initiative that the board must never dereference the pointer for liveness, and I built the real five-rounds-under-one-runtime-id shape and watched the board collapse six records into a single row carrying the last round's outcome, which is exactly the plausible-looking falsehood on four rows in five that the decision exists to prevent. That decision is right, not over-strict, and adequately specified. The REJECT rests elsewhere. First, the new load-bearing measurement's headline answers a different question than its own sentence asks: the stated metric is distinct shop handles per runtime subject, which yields twenty-six, while the published figure counts subjects with more than one returned record, and the seventeen-subject gap consists entirely of pre-envelope fossils carrying no handle at all, so they serve zero members rather than more than one; the figure appears in seven places and the honest restatement would strengthen the decision it supports rather than weaken it. Six of the seven other figures in that measurement are exact, including every named exemplar. Second, the same measurement has a second implication the amendment never draws: the design states its join over records while a member's rendered liveness comes from a fold entry, and the fold keeps one entry per subject, so on the quarter of the store where one agent served several rounds only the last round can bind while the earlier ones render as never-departed with their returned records sitting in the store and no condition raised - which is the precise defect this whole design exists to kill, arriving through the fold instead of through the rejected shape. One Minor records a fourth surviving strict-form claim in a self-check that reports three. Everything else verified: the field specification is testable, all five new vectors are writable with the withdrawn composite genuinely reding, the vector arithmetic reaches twenty-one with none double-counted, the prior round's four carried Minors are folded with two of them exceeded, and the amendment's appended-not-rewritten disposition note and corrected cap paragraph are both honest.
```