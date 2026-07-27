<!-- starcar-integrity: sha256=aa7cdefa068fe2534aaf175331a6c899af22169cf9a77cb6c270d97ca572c30c covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Tooling train #41/#39/#38 adversarial review - round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-review

Target: `car/tooling-41-39-38 @ c4f39e2b7c885abbb9fdb21a8a18d1d0bfc502dd`
Base reviewed: `7841b0db02c1329df3eba1c7af3fe2f0ca7e6f40`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE-FOR-MERGE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `tooling-41-39-38-review-r1`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `7841b0db02c1329df3eba1c7af3fe2f0ca7e6f40` |
| Entire checkpoint | `acc218746d7c` |
| Dispatch, the locator within the session | `tooling-41-39-38-review-r1` |
| Entire session (context, NOT a lookup key) | `rev-tooling-r1-landing` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 7841b0db02c1329df3eba1c7af3fe2f0ca7e6f40
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

## Review Verdict: APPROVE-FOR-MERGE

### Verification Summary

Step 0 - Worktree identity: Branch car/tooling-41-39-38 at c4f39e2b7c885abbb9fdb21a8a18d1d0bfc502dd. Confirmed. Three commits on top of base 7841b0d.

Claim 1 - Test counts: Base (7841b0d): 289 passed / 0 failed. Tip (c4f39e2): 290 passed / 0 failed. Both observed by running Invoke-Pester -Path scripts/tests -CI myself. Delta is +1 test (the new #38 schema pin test). VERIFIED.

Claim 2 - Task A (#41, c6344ab): docs/templates/car-brief.md diff is exactly 2 lines changed (lines 62 and 101), both replacing hardcoded expected-count instructions with derive-at-base instructions that explain the StoreIntegrity dynamic count. Surgical - no restructuring. The explanation ("StoreIntegrity.Tests.ps1 generates one test per store record") is accurate per StoreIntegrity.Tests.ps1:68 (-ForEach $storeCases). DocPolicy.Tests.ps1 passes (all 290 green). VERIFIED.

Claim 3 - Task B (#39, 1235079): Old comment "The board's model-mix rendering consumes it" replaced with "Recorded for provenance on the artifact record; not currently consumed by the board (#39)." Sentence-check: board/store/store.go:122 declares Model in typedRecord for D17 known-key suppression only. Grep for .Model field access across all board Go code: zero matches. No consumer in board/web/ JS either (grep for model shows only unrelated HTML/CSS references). The new comment is true. #39 citation present. VERIFIED.

Claim 4 - Task C (#38, c4f39e2): Schema has 21 properties. Canonical order has 16. The 5 extras (model, body_file, subject_basis, task_id, provenance) are all named in the new disclosure paragraph in schema/index-format.md. manifest is NOT a schema property (confirmed by enumerating properties.PSObject.Properties.Name). The new test at Schema.Tests.ps1:55-88 mechanically cross-checks every schema property against canonical + disclosure. VERIFIED.

Claim 5 - Non-vacuity: Fault-injected by renaming model to xmodel in the disclosure sentence. Test failed with: "Expected $null or empty ... but got 'model'". Reverted byte-identical (git status clean). VERIFIED.

Claim 6 - Ticket citations: #41 not needed (template doc, no code). #39 at Produce-Artifact.ps1:268. #38 at Schema.Tests.ps1:42,55 and in index-format.md disclosure paragraph. VERIFIED.

Claim 7 - DocPolicy scope: DocPolicy scans docs/ only (DocPolicy.Tests.ps1 BeforeAll: DocsRoot = RepoRoot/docs). schema/index-format.md is outside that scope. It does carry Status: Current voluntarily. No issue. VERIFIED.

### Findings: 0

### Constitution Check
- Law 1 (truth): Old false comment about board model-mix rendering corrected. New comment verified true. New disclosure sentence verified complete against schema.
- Law 6 (no duplication): Schema JSON owns properties; index-format.md owns ordering. The disclosure sentence names extras without redeclaring types - no duplication.
- Law 7 (stranger-viable): Template now instructs deriving baselines rather than copying stale numbers - a stranger following the template gets correct counts.
- Doc-code parity: index-format.md updated in the same commit (c4f39e2) that adds the mechanical test enforcing it. Template updated in the same commit (c6344ab) that changes the instruction.

```starcar-artifact
task-id: tooling-41-39-38-review-r1
outcome: approve-for-merge
findings: 0
abstract: All three commits verified against empirical evidence. Pester baseline 289 at 7841b0d, 290 at tip c4f39e2 (observed, not copied). Fault-injection proved the new schema-pin test non-vacuous. The corrected board-model comment is truthful (no .Model consumer in board Go or JS code). The disclosure sentence in index-format.md names exactly the five unaccounted schema properties. No Majors, no Minors.
```