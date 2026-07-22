<!-- starcar-integrity: sha256=7a25f5316eba6a76796bd45d7d4f763358bece6d210a31aab698f02783c95af3 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# PR-18 fix plan review: R1 REJECT (2 Major) then R2 APPROVE-WITH-REBASE-LIST

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Plan review (adversarial, Opus, 2 rounds)
Round: 2
Target: `docs/plans/2026-07-22-pr18-correctness-fixes-plan.md rev 2`
Base reviewed: `97e7c7cf3c1147c46167d740a15f9bcaf25771e1`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE-WITH-REBASE-LIST**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a44127012b765aa15`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `97e7c7cf3c1147c46167d740a15f9bcaf25771e1` |
| Entire checkpoint | `4fb52d878685` |
| Dispatch, the locator within the session | `a44127012b765aa15` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 97e7c7cf3c1147c46167d740a15f9bcaf25771e1
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All probes complete. The picture is decisive.

---

**VERDICT: APPROVE-WITH-REBASE-LIST** (2 small F5 items the car folds at commit; no new Major, convergence achieved).

## Base
Rev-2 HEAD = `97e7c7cf3c1147c46167d740a15f9bcaf25771e1` (matches), clean tree, detached. Code ground truth unchanged from round 1 (plan-only advance), so my round-1 empirical findings still hold; I re-probed everything rev 2 newly asserts.

## Round-1 finding walk (disposition verified independently)

**PR1-M1 (F1 stale in-code comments) — PRESENT, right lines.** Rev 2 F1 doc-set (lines 79-87) enumerates `index-format.md:46`, `New-ArtifactIndex.ps1:54-58`, and `:30-37`. I re-opened both comment blocks at base: `:54-58` is exactly the *"lexical sort ... IS a chronological sort ... only holds because 'at' was never coerced"* claim F1 destroys, and `:30-37` is the `-DateKind String` *"lexical sort ... non-chronological across years"* rationale that goes stale. The plan named the correct lines and instructs a same-commit rewrite of each. Fold is real, not drifted.

**PR1-M2 (F5 two-readable + mis-scoped) — PRESENT, ruling is SOUND (probed).** The conductor's no-schema-change ruling is empirically valid:
- **(a) envelope IS optional.** Schema `required` (line 86) = schema/kind/subject/session_id/at/normalisation/integrity — no envelope; the returned conditional's required (line 94) = outcome/findings/abstract — no envelope. Omitting it is schema-valid.
- **(c) probe:** a returned record with `outcome:error`, findings, abstract, and NO envelope field → `Test-StarcarArtifact` = **Valid=True**. Brief-absence with `envelope:'absent'` → Valid=True. The two are distinguishable at the field level (probe: producer-fault `PSObject.Properties['envelope']` = **False**, brief-absence = **True**). The ruling fixes the Law-4 drop (findings + `_faults.log`) and stops blaming the brief. Strictly better than the status quo, schema-valid, testable, coverage-class. Sound.

**PR1-m1 (fail-loud) — PRESENT.** Rev 2 (lines 68-77) has `Get-AtInstant` throw NAMING the value and REJECT zoneless `at` (I re-confirmed `Test-Json` asserts no `date-time` format), with the generator/detector catching, naming the record's file, and rethrowing — attributed, not an unnamed whole-batch crash. Red-first cell present (line 75). The deferred schema `pattern` is correctly parked to an issue.

**PR1-m2 (Get-Sha256Hex) — PRESENT.** Rev 2 (lines 136-139) says EXTRACT to a shared module, both producer and test consume it, "never a copy." Law 6 honored.

**PR1-m3 (parse-idiom ownership) — PRESENT.** Lines 57-62: helper to `Artifact.psm1` (one owner), repoint `Detect-Dispatches.ps1:46/:158` or disclose why `:158` stays inline (DateTimeOffset for subtraction). Disclosed.

**PR1-Nit (F6 quote) — PRESENT.** Disposition table line 232: car sentence-checks the full `README:8` line.

All six round-1 findings genuinely closed. Findings shrank and moved — convergence signature, not swirl.

## Two NEW minor findings in the F5 fold (rebase list)

**RL-1 (Minor) — F5 red-first must assert the producer-fault record stays schema-valid (abstract present).** A returned record REQUIRES `abstract` (schema line 94). Probe: the producer-fault record WITH abstract validates True; the same record **MISSING abstract → Valid=False** ("Required properties [abstract] are not present"). F5's red-first (lines 168-172) asserts `outcome:error` + no-envelope + findings + `_faults.log` but is SILENT on abstract. The producer does not self-validate before writing, so a literal build could commit a schema-invalid record (F4's new StoreIntegrity test would catch it in CI, but only after a bad record lands). The existing fault branch (`Produce-Artifact.ps1:166`) sets abstract, so a car that modifies rather than rewrites that branch preserves it — but the red-first should assert it explicitly. **Fold:** add "and the record is schema-valid (abstract present)" to F5's assertion list.

**RL-2 (Minor) — F5's "distinguishes them cleanly" overclaims.** `error` is a LEGITIMATE agent outcome (vocab-confirmed: `outcomes.json` values include `error`). So an agent emitting `outcome:error` in a valid, complete envelope produces `{outcome:error, no envelope field, findings, abstract, no _faults.log}` — sharing the structured-field signature of a producer read-failure `{outcome:error, no envelope field, findings, abstract, + _faults.log}`. The two differ only by findings-content and a `_faults.log` line whose format (`Produce-Artifact.ps1:117`: stamp/kind/message) carries NO subject, so the correlation is subject-less. The ruling's structured-field distinction is clean vs `envelope:absent` (the pair the brief asked about) but NOT vs a legitimate agent-error. **Fold:** soften "distinguishes them cleanly" to name the residual (structured-field-identical to a legit agent error; disambiguated by findings + faults.log), and note the deferred `envelope:unreadable` value is the eventual clean structured form. This is a rationale-accuracy fix, not a mechanism change.

## Item 6 — drift / new breakage: none
A no-envelope `outcome:error` record flows cleanly: `New-ArtifactIndex.ps1:42-43,65` renders `outcome` and never touches envelope (no envelope column exists); the detector's returned branch (`Detect-Dispatches.ps1:149`) reads `outcome` and never consumes envelope. F3's escaping is unaffected (`outcome:error` has no pipe; findings/faults content never reaches the index). No round-2 edit re-broke a round-1 fix.

## Convergence ruling
Round 1: 2 Major, 3 Minor, 1 Nit → Round 2: **0 Major**, 2 Minor (both finer-grain reads WITHIN the F5 fold, not defects the fold created in a fresh section). Major count fell to zero; round-1 findings are genuinely closed with correct citations; new findings are smaller and in the same area — declining and moving, the convergence signature. No swirl trigger fires (no Major stall, no cross-round clustering that persists, no fix-created-defect). This is a converged plan with two mechanical rebase items. The car may dispatch on Sonnet, folding RL-1 and RL-2 into F5 at commit time (the reviewer verifies both at the car's own review, no new plan round needed).

```starcar-artifact
outcome: APPROVE-WITH-REBASE-LIST
findings: Delta re-review of rev 2. All six round-1 findings verified PRESENT and correctly folded, none DRIFTED. PR1-M1: F1 doc-set names the right lines - New-ArtifactIndex.ps1:54-58 (the lexical-equals-chronological claim) and :30-37 (the DateKind String rationale) re-opened at base and confirmed as the comments F1 invalidates. PR1-M2: conductor no-schema-change ruling proven SOUND by probe - envelope is optional (not in schema required line 86 nor the returned conditional required line 94), and a returned record with outcome:error, findings, abstract, NO envelope field validates True; field-level distinguishable from envelope:absent (props null vs 'absent'). PR1-m1 fail-loud (throw-naming + reject-zoneless + catch-name-rethrow, red cell present), PR1-m2 EXTRACT not copy, PR1-m3 parse-idiom ownership disclosed, Nit full-quote - all present. Two NEW Minor items in the F5 fold, both fold-at-commit: RL-1 - F5 red-first is silent on abstract, but a returned record REQUIRES abstract (probe: same record missing abstract validates FALSE) and the producer does not self-validate before writing, so the red-first must assert schema-validity/abstract-present (F4 CI test backstops but only after a bad record lands; existing code at Produce-Artifact.ps1:166 sets abstract so a modify-not-rewrite car preserves it). RL-2 - the ruling's 'distinguishes them cleanly' overclaims: 'error' is a legitimate agent outcome (outcomes.json vocab), so envelope-missing+outcome:error is shared by a legit agent-error report and a producer read-failure, differing only by findings content and a subject-less _faults.log line; soften the prose and note the deferred envelope:unreadable value is the clean structured form. Item 6: no drift, no re-break - a no-envelope record flows cleanly through index (renders outcome, no envelope column) and detector (reads outcome, never consumes envelope); F3 escaping unaffected. Convergence: 2 Major 3 Minor 1 Nit down to 0 Major 2 Minor, findings declining and moving within one area - converged, no swirl.
abstract: Rev 2 APPROVED with a two-item rebase list; zero Major, convergence achieved. Base verified 97e7c7cf, code ground truth unchanged, all six round-1 findings independently confirmed folded with correct citations. The two round-1 Majors are resolved: F1 now enumerates the exact stale comment lines it invalidates, and F5's no-schema-change ruling is empirically sound (envelope optional, producer-fault record schema-valid, Law-4 drop fixed, strictly better than status quo). Two new Minors are refinements within the F5 fold - the red-first should also assert the producer-fault record stays schema-valid (abstract is required on returned records, proven by probe), and the 'distinguishes cleanly' rationale overclaims because 'error' is a legitimate agent outcome that shares the envelope-missing structured signature. Both fold at commit without a new plan round; the car may dispatch on Sonnet and its own reviewer verifies the two items at merge.
```