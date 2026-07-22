<!-- starcar-integrity: sha256=bdfa91c4f9b579096245608259f945bc14c95fec2f3a924e89cf7900e06b90e5 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car 1 review, round 2 (delta): M-A4-1 cleared - APPROVE

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (delta re-review, same adversary) + model-probe addendum
Round: 2
Target: `car/harness-car1 at 1e0d71a (fix cycle)`
Base reviewed: `1e0d71ab6f1ffbf169259a242e1f0887e54eef87`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a2bbd2f4d50b4976d`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `1e0d71ab6f1ffbf169259a242e1f0887e54eef87` |

| Dispatch, the locator within the session | `a2bbd2f4d50b4976d` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 1e0d71ab6f1ffbf169259a242e1f0887e54eef87
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Tree CLEAN, HEAD `1e0d71a`, no leftovers. All checks complete.

---

## VERDICT: APPROVE. M-A4-1 is cleared by a correct one-line fix and a red-valid year-spanning rider. Scope is clean, Laws 1/4/7 restored, 43/43 green. The branch proceeds to the whole-branch gate and merge to dev.

---

### Base verification
`git log -1` = `1e0d71ab6f1ffbf169259a242e1f0887e54eef87`, one commit above `0ad4d93`, tree clean at entry and exit.

### The six checks

**1. Diff scope — PASS.** `git diff --stat 0ad4d93..HEAD` = exactly `scripts/New-ArtifactIndex.ps1` (16 lines) and `scripts/tests/ArtifactIndex.Tests.ps1` (62 lines). `git diff --name-only ... -- schema/index-format.md` returns empty — the contract is **UNTOUCHED**. The code moved to the contract, not the reverse. Nothing else in the diff.

**2. Fix mechanism — VERIFIED (re-derived, not read).** I ran `(Get-Command ConvertFrom-Json).Parameters.Keys -contains 'DateKind'` = **True** on this pwsh (7.6.3), matching the car's documented probe-before-use (New-ArtifactIndex.ps1:29-30). With `-DateKind String`, `'{"at":"2026-07-22T10:00:00Z"}' | ConvertFrom-Json -DateKind String` yields `at` of type **System.String**, value `2026-07-22T10:00:00Z` — no DateTime coercion, so no invariant-culture reformat downstream. The sort-comment claim (New-ArtifactIndex.ps1:54-57) is correct: ISO-8601 UTC is fixed-width, zero-padded, most-significant-field-first, so a lexical string sort **is** a chronological sort — and it only holds because `at` is never coerced. Confirmed empirically in check 6.

**3. The rider — red-valid, VERIFIED by fault-injection.** The new `year-spanning (M-A4-1)` Describe (ArtifactIndex.Tests.ps1:35-95) writes a 2026-01, 2026-07 (the worked example's literal `2026-07-22T10:00:00Z`), and 2099-01 fixture, and asserts (a) verbatim ISO column and (b) chronological subject order. I reverted the one-line fix locally (`sed` stripping `-DateKind String`, back to plain `ConvertFrom-Json`) and ran just that Describe: **both tests failed for M-A4-1's exact reasons** — test 1: `Expected regular expression '2026-07-22T10:00:00Z' to match` (the reformatted MM/dd/yyyy output lacks the ISO string); test 2: `Expected @('year-jan-2026','year-jul-2026','year-2099'), but got @('year-2099','year-jan-2026','year-jul-2026')` (2099 sorts first). `Passed=0 Failed=2`. Restored via `git checkout`; blob hash back to `c301d9e` (baseline), tree clean.

**4. Suites at HEAD — VERIFIED.** `Invoke-Pester ./scripts/tests`: **Passed=43, Failed=0, Skipped=0** (41 prior + 2 rider). `./scripts/Verify-Verdict.ps1` bare: **14 verdict file(s) verified, exit 0**. Both match expectation.

**5. Round-1 injection #4 rerun — VERIFIED.** Two runs over the same store: byte-identical (`B57C8EA462CB`). Mutated one artifact's `at` (to 2030-05-05): output hash changed (`0FDAC147346B`). Determinism guard still non-vacuous.

**6. Law violations cleared — YES.** Green-state output against a 2026/2099 store:
```
| disp-1 | dispatched | 2026-07-22T10:00:00Z |  | y2026.json |
| disp-2 | dispatched | 2099-01-01T00:00:00Z |  | y2099.json |
```
The `at` column is now **exactly** the ISO-8601 form index-format.md:55-57 documents (Law 1 cleared — the committed worked example is now a true claim about the code), the `Z`/`T` UTC markers are preserved (Law 4 cleared — no silent loss), and rows are chronological — 2026 before 2099 (Law 7 cleared — a stranger's board/parser built against the documented ISO column now works). All three round-1 violations are resolved by the same one-line change.

### Fault-injection log (all reverted byte-identical, tree CLEAN confirmed)
| Injection | Observed | Revert |
|---|---|---|
| Strip `-DateKind String` (restore plain ConvertFrom-Json), run year-spanning Describe | Both new tests fail for M-A4-1's reasons (ISO string absent; 2099 sorts first); Passed=0 Failed=2 | `git checkout`; blob restored to `c301d9e`; `git status` empty |
| Determinism rerun (2 runs) + mutate `at` | run1==run2; post-mutation hash differs | temp store outside worktree; removed; clean |

Final state: `git status --porcelain` empty, HEAD `1e0d71a`, no leftover temp dirs. I edited, committed, and pushed nothing to the worktree.

### Model-probe addendum — second Sonnet data point (same car fixing its own defect from a precise brief)
Re-derived, not read:
- **Red validity:** the rider genuinely fails for the named reasons under fault-injection — a real red, not a passing-on-arrival test. **PASS.**
- **Probe-before-use compliance:** the car probed `DateKind` presence before using it and documented it in a load-bearing comment; I re-derived the probe True. **COMPLIANT.**
- **Scope discipline:** exactly the two expected files; `index-format.md` untouched; no adjacent edits, no churn. **CLEAN.**
- **Claim accuracy:** 43/43 is real; the comment's mechanism description and contract citations (index-format.md:55-57) are accurate. **ACCURATE.**

**What rounds 1+2 together support for cars 2-3:** the two rounds separate two distinct Sonnet competencies. Round 1: given a *thin* plan whose test could not expose the defect, Sonnet shipped a subtle contract-vs-implementation bug that its own A.1 contract flagged — a **discovery/self-review** miss (catching what neither the plan nor its own tests name). Round 2: given a *precise* brief naming the defect, mechanism, and required rider, Sonnet executed the remediation flawlessly on the first pass — a **directed-execution** success. So the measured Sonnet weakness is at the unprompted-catch frontier, not at executing a well-specified task. For cars 2-3 (which run against a reviewed plan with an adversarial reviewer downstream), the residual risk is exactly round-1's class: a defect neither the plan nor the car names, surviving to the reviewer — and in round 1 the gate did catch it. This is n=2, one defect injected-then-cleanly-fixed; I state it without overclaiming. The evidence leans toward Opus buying its margin specifically at the generative/self-review edge while Sonnet is reliable under precise briefs; how much to weight the downstream reviewer as the safety net is the budget owner's call. The conductor holds the series and the spend decision.

```starcar-artifact
outcome: APPROVE
findings: M-A4-1 is cleared. The fix is a single load-bearing change at scripts/New-ArtifactIndex.ps1 line 37 - ConvertFrom-Json gains -DateKind String, preceded by a documented probe that the DateKind parameter exists on this pwsh (I re-derived it True). This keeps the at value a System.String end to end, so the invariant-culture DateTime reformat that dropped the UTC marker and produced a non-chronological lexical sort no longer happens. Green-state output now renders the at column as the verbatim ISO-8601 string 2026-07-22T10:00:00Z, exactly matching the worked example at schema/index-format.md line 55 to 57, with rows in chronological order (2026 before 2099). That clears all three round-1 law findings: Law 1 (the committed worked example is now a true claim about the code), Law 4 (no silent loss of the Z and T markers), and Law 7 (a stranger parsing the documented ISO column now works). The sort comment's claim that lexical equals chronological for fixed-width zero-padded ISO-8601 UTC is correct. The rider adds a year-spanning Describe with two tests - verbatim ISO column and chronological order - over a 2026-01, 2026-07 (the worked example's literal string), and 2099-01 fixture. I fault-injected by reverting the one-line fix and running the rider: both tests failed for M-A4-1's exact reasons (ISO string absent from output; 2099 sorted before 2026), then I restored byte-identical, blob c301d9e, clean tree. Scope is exactly the two expected files; schema/index-format.md is untouched. Suites re-run by me at HEAD 1e0d71a: 43 passed, 0 failed under pwsh 7.6.3 Pester 5.8.0; Verify-Verdict 14 of 14 exit 0. Determinism rerun holds and mutating at changes output. No new findings. On approve the branch goes to the whole-branch gate and merges to dev.
abstract: APPROVE. The same Sonnet car fixed its own M-A4-1 defect from a precise brief with a correct one-line change (ConvertFrom-Json -DateKind String, probe-before-use verified) that keeps the at value a plain ISO-8601 string, restoring both the documented at-column format and chronological sort. The year-spanning rider is red-valid - I reverted the fix and watched both new tests fail for the exact defect reasons, then restored byte-identical. Scope is clean (two files, contract untouched), 43 of 43 tests pass, verifier 14 of 14 exit 0, and all three round-1 law violations are cleared. Model probe, second data point: given a precise brief Sonnet executed the remediation flawlessly with clean scope and accurate claims - its measured weakness is unprompted discovery of subtle defects against self-authored contracts, not directed execution. Rounds 1 plus 2 leave the cars 2-3 spend decision with the conductor.
```