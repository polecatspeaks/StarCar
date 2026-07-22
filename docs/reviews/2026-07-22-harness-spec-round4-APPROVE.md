<!-- starcar-integrity: sha256=83c0e411c80e9d1be30fab85c0e295d7a84fe96c6ca7058473d22c8e2aaa9d24 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Adversarial spec review - dispatch harness, round 4 (final confirm) - APPROVE

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: spec review (ladder rung 2)
Round: 4 (final confirm)
Target: `docs/specs/2026-07-22-dispatch-harness-spec.md (rev 4)`
Base reviewed: `e4d037d03aff928391a0619fddab5f085ad90573`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE - 0 new findings; all prior closed and re-verified by mechanism; spec proceeds to the plan rung**

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
| Base commit the reviewer read (**the lookup key**) | `e4d037d03aff928391a0619fddab5f085ad90573` |
| Entire checkpoint | `68bb669cee9a` |
| Dispatch, the locator within the session | `a543c37ea68e622d8` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain e4d037d03aff928391a0619fddab5f085ad90573
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

VERDICT: **APPROVE** — every anchor resolves to the section that actually carries its claim, zero numeric citations remain, n6 is closed, and the diff is citations only.

Base `e4d037d03aff928391a0619fddab5f085ad90573`, clean tree before and after, no fault injection. Re-derived independently, not taken from your message: **Pester 21/21 passed, 0 failed, 0 skipped**; **`Verify-Verdict.ps1`: 10/10 hashes match, exit 0**.

**You were right not to do what I asked.** I listed six numbers; you removed the failure mode. The evidence was in the document, as you say — row 13 carried both forms side by side and only the anchor survived. Correcting six numbers would have re-armed the trap on the next edit above them.

## THE LOOKUPS

1. **Zero numeric citations remain.** `grep -c "design:[0-9]"` → **0**. Full inventory now: `design §0` ×3, `design §5.1` ×2, `design §5.2`, `design §5.7`, `design §6` ×4, `design §8`, `design §9b`, `design P1`, `design P6` — all label- or heading-based, all drift-immune.
2. **`design §0` under §3.6 "publication and trust to the behavioural half"** — resolves to `:27`, the **Behavioural** row, which contains the literal words *"publication; trust"*. The old `design:26` landed on the Format row, the opposite half; the anchor lands on the right one. §0's table has exactly two rows, so there is no ambiguity to annotate. **Correct.**
3. **`design §6` (concurrent-write row) under §2.4's verbatim quote** — resolves to `:231`, *"Two writes land concurrently … the producer writes its own path only and never `git commit -a`; a contended commit retries, and a failed write is **raised, never dropped silently**"*. The quote in §2.4 is verbatim from that row. **Correct.**
4. **`design §5.1`** — two uses, both correct: *"One record per dispatch event"* at `:138`, and *"Field lists, types, ordering and identity are the schema artifact's job"* at `:141`. **n6 CLOSED** — `§4.3` is gone and `§5.1` is the section that genuinely assigns identity.
5. **Remaining anchors, all opened:** `design §5.2` (Kinds and outcomes are data, heading `:146`) ✓ · `design §6` (vocabulary-unreadable row) → `:229`, *"One board-level fault, **not N per-lane faults**"* ✓ · `design §6` (artifact-altered row) → `:234`, *"Integrity check fails; the checkpoint branch holds an independent copy"* ✓ · `design §5.7` (Publication, `:212`) ✓ · `design §8` (Contracts touched) → `:258`, the row that says *"headers call themselves 'the harness'"*, which is exactly where M1's false claim was inherited from ✓ · `design §0` for the substitution-rule deferral → `:37`, *"no other substitution) belongs to the **schema artifact**"* ✓ · `design §9b` (`:270`) ✓.
6. **Nothing else changed.** All eight spec hunks are single-token citation substitutions; I read each. No requirement, ruling, table row, test cell, owner or non-goal was altered. §3.6's sentence *"the citation pointed at the design's Cost section"* correctly survives as the historical record of the rev-2 defect.

## RULING: ANCHORS VS LINE NUMBERS

**Correct trade, and the annotations are sufficient — they are not merely adequate, they are stronger than the line numbers they replaced.**

Precision is only worth having if it is true. A line number into a living document is precise and *becomes false silently*; that is the worst shape a locator can have, and this train proved it twice — once when a documentation-policy commit shifted six citations, and once when I myself propagated two of the stale ones into a verdict.

Your specific worry — that `design §6` is a fourteen-row table and a bare section anchor cannot be falsified — is the right worry, and the annotation answers it. `(concurrent-write row)`, `(vocabulary-unreadable row)`, `(artifact-altered row)`: each names words that appear in that row's own first column, so each resolves in one command (`grep -n "Two writes land concurrently"`) and returns exactly one hit. That is a **content key, not a positional key** — it survives insertion above it *and* reordering within the table, which a line number survives neither of. I verified all three annotations against the real row text rather than assuming; none names something absent.

The one shape that would have failed this test is an annotation invented from the citing document rather than lifted from the cited row — e.g. "(the retry row)" where the row says "Two writes land concurrently". None of yours do that. Worth writing down as the rule when this graduates to a CI check: **the annotation must be a substring of the target.** That makes it mechanically checkable, which is the same property that makes it a good citation.

## MAY THE SPEC PROCEED TO THE PLAN RUNG?

**Yes. Plainly: the spec is approved and goes to plan.**

Three rounds, sixteen findings, six rulings, all closed by mechanism and re-verified by me rather than read from a summary. Nothing is carried forward into the plan rung as an open item. The two items parked elsewhere are correctly parked: the `worked-spec.md` template amendment is issue #9, and the citation-resolution CI check belongs with it — that guard is now well-specified enough to write (every `file:NNN` or `§X (row-name)` citation under `docs/` resolves, with the annotation-is-a-substring rule above as its assertion).

No new findings.

```starcar-artifact
outcome: APPROVE
findings: 0 new; all prior findings closed and re-verified by mechanism; spec approved for the plan rung
abstract: |
  Final confirm at base e4d037d03aff928391a0619fddab5f085ad90573. Read-only, no fault
  injection, tree clean before and after. Suites re-derived independently rather than taken
  from the coordinator: Pester 21 passed, 0 failed, 0 skipped; Verify-Verdict 10 of 10
  hashes match, exit 0.

  The coordinator did not perform the six line-number corrections I listed. It performed the
  option I had strongly recommended instead: every numeric design line citation in the spec
  is now a section anchor. That was the better call and I confirm it as such. Correcting six
  numbers would have left the failure mode armed for the next edit above them; the
  substitution removes the failure mode. The evidence was already inside the reviewed
  document, where fidelity row 13 carried both forms side by side and only the section-anchor
  form survived the line shift.

  All lookups pass. Zero numeric design citations remain, confirmed by grep count of zero.
  Every anchor was opened and resolves not merely to a real heading but to the passage
  carrying the claim. The two the coordinator flagged as most worth distrusting both hold:
  design section 0 under the publication-and-trust claim now lands on the Behavioural row
  containing the literal words publication and trust, where the previous line citation landed
  on the Format row, the opposite half of the split; and design section 6 with the
  concurrent-write annotation lands on the row whose text is quoted verbatim in spec section
  2.4. The remaining anchors for vocabularies, the unreadable-vocabulary fault, publication,
  the contracts-touched row that seeded the withdrawn M1 claim, the substitution-rule
  deferral, and the round-5 disposition all resolve correctly. Minor n6 is closed: the
  nonexistent design section 4.3 is replaced by design section 5.1, which is the section that
  genuinely assigns identity to the schema artifact. All eight spec hunks are single-token
  citation substitutions; no requirement, ruling, table row, test cell, owner or non-goal was
  altered under cover of a locator change.

  Ruling on the substitution itself: trading line precision for drift resistance is correct,
  because precision is only worth having if it is true, and a line number into a living
  document becomes false silently, which is the worst shape a locator can have. The concern
  that a fourteen-row failure-mode table is too coarse to be falsifiable is answered by the
  prose annotations, which are stronger than the line numbers they replace: each names words
  drawn from the target row's own first column, so each resolves in one grep and survives
  both insertion above it and reordering within the table, neither of which a line number
  survives. All three annotations were checked against the real row text. The rule to carry
  into the future CI check is that the annotation must be a substring of the target, which
  makes the citation mechanically checkable.

  Decision: the spec is APPROVED and proceeds to the plan rung. Three rounds, sixteen
  findings, six rulings, all closed by mechanism and re-verified by the reviewer rather than
  read from a summary. No open item is carried into the plan. The two parked items are
  correctly parked as issue 9: the worked-spec template amendment, and the
  citation-resolution CI check that now has a well-specified assertion.
```