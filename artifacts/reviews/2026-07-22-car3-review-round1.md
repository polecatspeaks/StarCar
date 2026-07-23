<!-- starcar-integrity: sha256=f3cc6fc52b948cec033a00008c75ff0941d3094eb8a013557ad47ed43deae63a covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car 3 review, round 1: REJECT - two cross-boundary Majors; migration byte-perfect

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (adversarial, Opus, forensic + 5 fault injections)
Round: 1
Target: `car/harness-car3 at ec51e8b (4 commits)`
Base reviewed: `ec51e8babc75d90dacc0827ccb78cd5f4146c7b5`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a3f05aecaa3d550e2`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `ec51e8babc75d90dacc0827ccb78cd5f4146c7b5` |

| Dispatch, the locator within the session | `a3f05aecaa3d550e2` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain ec51e8babc75d90dacc0827ccb78cd5f4146c7b5
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All fault injections reverted byte-identical, tree clean at ec51e8b. I have completed all eight dimensions. Here is my verdict.

---

# VERDICT: REJECT

Two Majors (M-A, M-B). Any Major = REJECT. This is a SUCCESS outcome for the gate: both are cross-boundary sentence-check failures the car's local proofs could not reach, and both are cheaply fixable. The migration mechanics themselves are byte-perfect and independently verified.

## Suites re-run myself at ec51e8b (HEAD verified, 4 commits above base f850c63)
- `Pester scripts/tests`: **81/81 passed**, 0 failed.
- `Pester scripts/probes`: **12/12 passed**, 0 failed.
- `Verify-Verdict.ps1` bare: **24/24 verified, exit 0.**
- All three car claims reproduced exactly.

---

## (a) The migration, forensically — CLEAN
- `docs/reviews/` is gone (`git ls-files` empty, dir absent); 24 `.md` + 24 `.json` at `artifacts/reviews/`; `index.md` lives at `artifacts/index.md` (store root, outside the globbed `reviews/` dir).
- All 24 `.md` are **R100 renames** from `docs/reviews/` (git detected 100% identity). Independent blob-SHA check across the rename for 3 files (car1-review-round1, harness-spec-round4-APPROVE, hotfix-confirm): OLD==NEW, byte-identical.
- **24/24 JSON schema-valid** via `Test-StarcarArtifact`. One discovery (`outcome: CONFIRM`) — correct spec-S3.2 behavior (unrecognized outcome is a DISCOVERY, not a failure), not a validation error.
- **24/24 integrity hashes round-trip** — I re-derived independently (strip `integrity`, rebuild ordered record, `ConvertTo-Json -Compress`, sha256), did not trust the field. All match.
- **19 fence / 5 fallback split independently reproduced**: I re-ran HEAD's `Migrate-Verdicts.ps1` against the base-commit `docs/reviews/` content in a scratch clone → "24 migrated (19 fence-parsed, 5 fallback-parsed)". Content of the regenerated records matches the landed records (identical after EOL-normalize; committed blobs are pure LF per `.gitattributes`, integrity is computed over in-memory compact JSON so file EOL is irrelevant).

## (b) Execution discovery — SOUND, scope call CORRECT
- Red test at `Migration.Tests.ps1:146-169` genuinely reproduces. **Fault injection**: reverted the fix `Migrate-Verdicts.ps1:111` from `$env.Found -and ($env.Outcome -notmatch "\`n")` to `$env.Found` → the EXECUTION-DISCOVERY test FAILED with `outcome` = `'REJECT\nsection_4_disposition: NOT CLOSED - ESCALATE TO OWNER'` (the exact multi-line corruption). Restored byte-identical; tree clean.
- `Envelope.psm1` untouched by all 4 commits (`git log` empty) — confirmed the fix landed in the migration tool, not the shared module.
- **Ruling on scope**: fixing in `Migrate-Verdicts.ps1` rather than `Envelope.psm1` was CORRECT. The shared module is Car 2's live producer path; the pre-schema grammar is a historical artifact whose only consumer is the migration. The catch was real-wreckage-based (it actually corrupted `artifacts/index.md`'s table when first observed, per the plan) and red-first. **Recommendation (non-blocking)**: the shared-module live-path gap should be a tracked issue — `Produce-Artifact.ps1:158` uses `env.Outcome` with NO newline guard, so a live agent emitting an off-grammar envelope (an extra key line right after `outcome:`) would produce the same multi-line-outcome corruption on the live path. Low probability (briefs mandate the 3-field grammar) but untracked.

## (c) Verifier repoint — CLEAN, teeth confirmed
- Default `artifacts/reviews` (`Verify-Verdict.ps1:36`), no recursion (`:106`, `Get-ChildItem` without `-Recurse`). Anti-trap test (`Migration.Tests.ps1:171-184`) passes. Bare run 24/24 exit 0.
- **Fault injection**: dropped a headerless `zzz-faultinject.md` into `artifacts/reviews/` → verifier printed `NO INTEGRITY` and **exited 1**. The gate has teeth inside its coverage. Removed; tree clean.

## (d) CI wiring — ONE MAJOR (M-A), rest sound
- Probes-first with zero-test refusal (`ci.yml:104-118`): `FailedCount&gt;0`→exit1, `PassedCount==0`→exit1. Runs before board tests. Sound.
- **Staleness gate (`:133-147`) re-derived myself**: injected an unindexed record → regen produced 33 rows vs 32 committed → `git diff --exit-code` **exit 1**. Clean store → exit 0. Fires correctly. Removed; tree clean.
- Ubuntu matrix leg: all steps are `shell: pwsh` with forward-slash paths — no Windows-only steps to guard. Sound.
- Car claimed nothing live for CI (commit messages report local counts; gating-matrix explicitly defers "live CI-side firing" to conductor handback). Correct.

**M-A (MAJOR, EXECUTION): the checkpoint-fetch step is FATAL on an absent branch, contradicting its own "non-fatal" contract.** `ci.yml:51-64` runs `git fetch origin entire/checkpoints/v1`, then an if/else that only `Write-Host`s. It never resets `$LASTEXITCODE` or `exit 0`. GitHub's `shell: pwsh` wrapper prepends `$ErrorActionPreference='stop'` and appends `if ((Test-Path -LiteralPath variable:\LASTEXITCODE)) { exit $LASTEXITCODE }`. I simulated the faithful wrapper: an absent-ref `git fetch` returns 128, `$LASTEXITCODE` stays 128 through the `Write-Host` branch, and **STEP-EXIT=128** — the step FAILS. This directly falsifies:
- `ci.yml:28` "non-fatal if the branch is absent, which it is on any fork (Law 7)"
- `ci.yml:56-58` "so absence is a LOUD note, never a build failure"
- `gating-matrix.md` tier-2 row (8571591): "non-fatal (loud `::notice::`) if the ref is absent - a fork has no Entire checkpoint branch (Law 7)"

The step's own notice message (`:61`) names the exact scenario under which it fails ("expected on a fork or a clone with no Entire mirror"). The canonical repo's CI passes (I confirmed `entire/checkpoints/v1` exists on origin), so this train's PR goes green — but a stranger forking the repo (the Law-7 case the step was written for) gets a red CI. The car's local proof ran the snippet without GitHub's `exit $LASTEXITCODE` suffix, so it "passed" locally while the CI step fails — the exact "verified means the pipeline went green, not your local run" scar. Fix is one line (`exit 0` or `$LASTEXITCODE=0`).

## (e) C.3 latency measurement — CLEAN, no guessing
- Re-ran the probe: pwsh-start median 209.6ms, python 23.4ms, producer-fixture 97.2ms, hook-append 92.4ms — matches the documented figures within load variance (probe asserts non-vacuity only, no threshold, so a loaded box does not cry wolf).
- The `#15 addendum` (`spec7-probe-results.md:160-168`) records the honest gap: components sum ~350-400ms vs the ~11-12s measured, and states verbatim "the dominant contributor is not identified by this split and remains open." An instrument that guessed would be the finding; it did not guess. Correct.

## (f) C.4 + moved-path ruling — probe 6 / §9 closeout CLEAN; one MAJOR (M-B) in the ripple
- Probe 6 present with reproduction method (`:170-195`, C3R1-n1 folded). §9 closeout stated in the plan's review record (`plan:305-340`, rows 3-9 CLOSED). **Frozen spec untouched** — `git log f850c63..ec51e8b -- docs/specs/` empty.

**Ruling on the moved-path citations** (the brief's question): the answer is split, not uniform.
- **Acceptable as-is (frozen historical narrative, true-at-commit, showcase-never-edits)**: `docs/design/*.md`, `docs/specs/`, `docs/plans/` references to `docs/reviews/`. Those files WERE there when those documents were written; `git mv` preserved history so `git show &lt;commit&gt;:docs/reviews/...` and `git log --follow` still resolve. Rewriting them would be curation the record forbids.
- **NOT acceptable — LIVE surfaces the migration commit should have trued in-commit (living-documents rule), left stale**:

**M-B (MAJOR, EXECUTION/doc-drift): the live verdict-landing tool still directs to the retired location, contradicting setup.md's own retirement + protection claim.** `Land-Verdict.ps1` header (`:2`, `:18`) and usage example (`:41`, `-Out docs/reviews/&lt;file&gt;.md`) direct verdict landing to `docs/reviews/`, and `-Out` is `[Parameter(Mandatory)]` with NO default (`:48`). Meanwhile `setup.md:24` declares "`docs/reviews/` is retired as a location" and `setup.md:23` claims "`Land-Verdict.ps1 -Out` points there [artifacts/reviews/] ... so a future verdict cannot land silently unverified in a resurrected `docs/reviews/`." Sentence-check trace, every hop: prose (retired, protected) → the tool's own usage (`docs/reviews/`) → the verifier default (`artifacts/reviews`, no recursion, `:36`/`:106`) → what a stranger observes (a verdict body landed per the tool's example sits in `docs/reviews/`, which CI's bare verifier never checks) = a verdict of record UNVERIFIED in the retired location — the precise failure `setup.md:23` asserts is impossible. Review verdict BODIES still land through this tool (the producer hook writes only the JSON envelope record, not the verbatim body). Law 1 false claim on a user-facing doc + stale live tool; the invalidating commit (5ef0c57) updated setup.md/README/friction-log/state-ledger but missed the tool the setup.md sentence is ABOUT.

Additional stale LIVE surfaces (Minor, rebase-list): `CLAUDE.md:642` dead citation to `docs/reviews/2026-07-22-hotfix-confirm.md` (moved); `CLAUDE.md:446` generic `docs/reviews/` reference; `docs/templates/design-doc.md:62,169`, `docs/templates/worked-plan.md:23`, `schema/index-format.md:35` cite moved verdict paths; `Verify-Verdict.ps1:7` stale (self-corrected at `:24`).

## (g) Contracts same-commit — CLEAN
- state-ledger flip in **5ef0c57 (C.1)**: index instance "born here," with old→delta→new arithmetic (Process state 0→0, Derived-artifact classes 1→1, "no instance yet"→"instance live"). Same-commit as the migration.
- gating-matrix flip in **8571591 (C.2)**: tier-2 checkpoint-fetch row and index-staleness row both marked ARMED. Same-commit as the CI wiring. (Note: this row restates M-A's false "non-fatal" claim.)

## (h) Model-probe final reading (Sonnet, precise brief)
Sonnet executed every ENUMERATED obligation to high precision and produced a genuine beyond-plan, real-wreckage, red-first discovery (the pre-schema corruption, with a test that truly reproduces — I fault-injected it). Migration byte-perfect, integrity independently re-derivable, latency gap disclosed without guessing, scope call on the shared module correct, all §9 rows closed. **Both Majors are cross-boundary sentence-check failures on UN-enumerated surfaces**: M-A the local-pwsh-vs-GitHub-wrapper exit-code boundary; M-B the `docs/reviews`→`artifacts/reviews` rename ripple into a live tool + the constitution. Pattern: precise and even self-directed WITHIN the task's stated subject, but does not autonomously extend the sentence-check to surfaces the brief did not name. Data point for the cars-2-3 Sonnet topology: excellent on bounded, enumerated precision work; the brief must enumerate every doc surface and demand CI-wrapper-faithful proofs, because Sonnet will not self-discover cross-environment or cross-document ripples. The discovery weighs genuinely against the misses, but both misses land in the repo's highest-signal classes (doc-drift, verification-honesty), so the gate earned its cost.

## Constitution check (Laws 1, 4, 6, 7 — this diff moved the public record)
- **Law 1 (no confident falsehood on an information surface)**: VIOLATED by M-A (three surfaces assert "non-fatal"; the step is fatal on absence) and M-B (setup.md asserts protection that the tool defeats). HONORED by the migration mechanics (CONFIRM renders as discovery; latency gap disclosed as unidentified, not guessed).
- **Law 4 (no silent loss)**: HONORED — 24/24 bodies byte-identical, history preserved, fallback retains provenance ("migrated: see body_file"), and the corruption catch PREVENTED silent loss of outcome semantics.
- **Law 6 (no unowned second copy)**: HONORED for the index (owned by `New-ArtifactIndex.ps1` + the staleness gate I watched fire). PARTIALLY undermined by M-B — `Land-Verdict.ps1` pointing at `docs/reviews/` opens a second landing location the "one location, one owner" claim forbids.
- **Law 7 (the stranger deploys cold)**: VIOLATED by M-A — a stranger's fork gets a red CI on the very step written to protect strangers. HONORED elsewhere (portable-path normalisation `[]`, ubuntu matrix leg).

## Fault-injection log (all reverted byte-identical, tree clean at ec51e8b throughout)
1. `Migrate-Verdicts.ps1:111` fix reverted → EXECUTION-DISCOVERY test failed with multi-line `outcome` corruption → restored byte-identical, tree clean.
2. Headerless `.md` dropped into `artifacts/reviews/` → verifier `NO INTEGRITY`, exit 1 → removed, tree clean.
3. Unindexed record injected → staleness gate `git diff --exit-code` exit 1 (33 vs 32 rows) → removed + `git checkout index.md`, tree clean.
4. GitHub pwsh-wrapper simulation of the checkpoint-fetch step body → STEP-EXIT=128 on absent ref (scratch files only, removed).
5. Scratch clone at base + HEAD migration script → 19/5 split reproduced (scratch dir removed).

Relevant files: `~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\64c15364-0933-4d6d-9b2e-d1ddbc918f9f\scratchpad\review-car3\.github\workflows\ci.yml` (M-A, lines 51-64); `...\scripts\Land-Verdict.ps1` (M-B, lines 2, 18, 41, 48); `...\docs\setup.md` (M-B, lines 23-24); `...\CLAUDE.md` (lines 446, 642); `...\.gitattributes` (line 24); `...\scripts\Migrate-Verdicts.ps1` (line 111, the sound fix).

```starcar-artifact
outcome: REJECT
findings: Two Majors, any Major equals REJECT. M-A (EXECUTION, ci.yml:51-64): the checkpoint-fetch step never resets LASTEXITCODE, so under GitHub's shell pwsh wrapper (prepends ErrorActionPreference stop, appends exit LASTEXITCODE) an absent-ref git fetch returns 128 and the STEP FAILS. Empirically reproduced: STEP-EXIT=128. This falsifies its own comments (ci.yml:28,56-58 "non-fatal ... never a build failure") and the gating-matrix tier-2 row, and breaks the Law-7 stranger's fork CI. Canonical repo passes because the branch exists, so this train's PR still goes green; the fix is one line. The car's local proof ran the snippet without the CI wrapper. M-B (EXECUTION/doc-drift, Land-Verdict.ps1:2,18,41,48 vs setup.md:23-24): the live verdict-landing tool's header and usage example direct -Out to the retired docs/reviews/ (mandatory param, no default), while setup.md declares docs/reviews/ retired and claims -Out points at artifacts/reviews/ and that a verdict cannot land unverified in a resurrected docs/reviews/. Trace: tool usage points at docs/reviews/, CI verifier defaults to artifacts/reviews with no recursion, so a verdict body landed per the tool's own example is UNVERIFIED in the retired location - the exact failure setup.md says is prevented. Everything else verified clean and re-derived independently: 24 R100 byte-identical body moves (blob-SHA match), 24/24 JSON schema-valid, 24/24 integrity round-trip re-derived, 19/5 fence-fallback split reproduced, the pre-schema corruption red test genuinely reproduces on fix-revert, the verifier fails on a headerless md, the staleness gate fires on an unindexed record, latency gap disclosed without guessing, both contract flips same-commit, frozen spec untouched, Envelope.psm1 untouched (scope call correct). Suites re-run at HEAD: tests 81/81, probes 12/12, Verify-Verdict 24/24 exit 0. Rebase-list minors: CLAUDE.md:642 dead citation and :446, templates design-doc.md:62/169 and worked-plan.md:23, schema/index-format.md:35, Verify-Verdict.ps1:7, and .gitattributes:24 stale docs/reviews -text protection (functionally inert - verifier normalizes EOL and global eol=lf covers the new path); recommend a tracked issue for the Envelope.psm1 live-path multi-line-outcome gap.
abstract: REJECT. Car 3's migration mechanics are byte-perfect and independently verified end to end, including a genuine beyond-plan red-first discovery (pre-schema envelope-grammar corruption) that I confirmed by fault injection. But two Majors block merge, both cross-boundary sentence-check failures the car's local proofs could not reach. M-A: the CI checkpoint-fetch step is fatal on an absent branch (STEP-EXIT=128 reproduced under GitHub's pwsh exit-code wrapper), contradicting its own non-fatal comments and the gating-matrix and breaking the Law-7 stranger's fork CI. M-B: the live verdict-landing tool Land-Verdict.ps1 still directs -Out to the retired docs/reviews/, which the CI verifier does not cover, defeating setup.md's own retirement-and-protection claim. Both are one-line-to-few-line fixes. Model-probe reading: Sonnet executed every enumerated obligation to high precision and self-discovered a real corruption within its task, but did not extend the sentence-check to un-enumerated live surfaces (the CI exit wrapper, the rename ripple into the tool and constitution); the cars-2-3 Sonnet topology should enumerate every doc surface and demand CI-wrapper-faithful proofs. All fault injections reverted byte-identical; worktree clean at ec51e8b throughout; read-only, nothing committed or pushed.
```