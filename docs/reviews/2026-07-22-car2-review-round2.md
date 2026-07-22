<!-- starcar-integrity: sha256=b1f4266781efc7bdd2f03f5e4bc30dd19d5403767efcfc5457f1ee93a5c1c7cd covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car 2 review, round 2 (delta): APPROVE - M1 closed by mechanism, fourth orphan self-swept

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (delta re-review, same adversary)
Round: 2
Target: `car/harness-car2 at 8826566 (fix cycle)`
Base reviewed: `8826566f1133336f78f604e53f56fd8e4e66693c`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a6940e01dae1edf78`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `8826566f1133336f78f604e53f56fd8e4e66693c` |

| Dispatch, the locator within the session | `a6940e01dae1edf78` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 8826566f1133336f78f604e53f56fd8e4e66693c
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: APPROVE

Base verified `8826566` (one above `e6128ef`), clean tree, read-only throughout. The round-1 Major (M1 citation drift) is closed by mechanism. All five checks pass; the fix is comment-only, moves no count, introduces no new finding, and the car self-swept a fourth orphan my round-1 review missed.

## The five checks

**1. Diff scope — PASS.** `git diff e6128ef..HEAD` touches exactly four files: `scripts/Envelope.psm1`, `scripts/Produce-Artifact.ps1`, `schema/index-format.md`, `scripts/New-ArtifactIndex.ps1`. Every changed line is inside a comment or prose block (an Envelope doc-comment, three `#` comments, one markdown line). Zero executable lines changed — I read the full diff hunk-by-hunk. No code change.

**2. The three re-anchors by function name — PASS, names verified correct at HEAD.**
- `Envelope.psm1:96` now reads "Land-Verdict.ps1's Get-ResultBlockForTask last-wins return." `Get-ResultBlockForTask` is at `Land-Verdict.ps1:74-112` and its last-wins `return $found[$found.Count - 1]` is at line 111 under the "LAST result is the current one" comment. Name and behavior match.
- `Produce-Artifact.ps1:75` now reads "Land-Verdict.ps1's ConvertTo-PortablePaths." Function exists at `Land-Verdict.ps1:114` and performs the path-normalisation rewrite. Match. (It correctly retained the separate `schema/index-format.md:60-72` citation, which B.4 never shifted — different file.)
- `schema/index-format.md:62-64` now reads "the ConvertTo-PortablePaths function in scripts/Land-Verdict.ps1." Same function, same behavior. Match.

**3. The fourth orphan (New-ArtifactIndex.ps1:8) — PASS, claim verified.** The base citation was `Land-Verdict.ps1:317-321`. At base `8bb6db4`, lines 317-321 covered `$document`/`$hash`/`$integrityLine`/`UTF8Encoding($false)`/`WriteAllText` — so the BOM-free write WAS in range at base. After B.4's -4 shift, `UTF8Encoding($false)` moved to `Land-Verdict.ps1:316` — one line above 317-321, so the stale range no longer covered it. The car's claim is exactly right. Re-anchored to "the WriteAllText with a BOM-free UTF8Encoding($false)," which lives at `Land-Verdict.ps1:316-317`, and `New-ArtifactIndex` uses the identical pattern at its own lines 69-70, so the precedent is apt. This was a genuine fourth orphan the car found on its own — my round-1 finding named only the other three; the car exceeded the prescription and swept the one I missed.

**4. Sweep completeness — PASS, re-derived.** My own `git grep -n 'Land-Verdict\.ps1:[0-9]' HEAD` restricted to live dirs (`scripts/`, `schema/`, `config/`, `.claude/`, `CLAUDE.md`) returns **NONE**. Every remaining `Land-Verdict.ps1:NNN` line citation lives in `docs/design/`, `docs/plans/`, `docs/specs/`, `docs/reviews/`. Frozen-record exclusion ruling: **correct and mandatory.** Landed verdicts carry `Record: verdict of record - historical by nature, never edited after landing` and are hash-verified by `Verify-Verdict` — editing one to chase a line shift would break its integrity hash and rewrite the record, which the showcase-never-edits-the-record rule forbids. The spec, plan, and design are closed prior rungs whose citations were true at their own commit. Leaving all of them untouched is not an omission; touching them would be the violation. (An earlier Grep-tool read returned stale cached content for two of the four files; I resolved it against `git grep HEAD` and a direct working-tree read — the fix is genuinely in place.)

**5. Suites at HEAD `8826566` — PASS, no count moved.** `scripts/tests` **73/73**, `scripts/probes` **8/8**, `Verify-Verdict` **exit 0, 19 files verified**. Identical to round 1, as a comment-only change requires.

## Convergence ruling
Round 1: 1 Major. Round 2: **0 findings.** The Major closed by the correct mechanism — function-name anchors replacing fragile line numbers, the same remedy the spec process itself adopted at its round 4. No swirl: no finding re-opened in the same section, no defect created by the fix. The opposite of churn — the fix's blast radius is comment-only, no test count moved, and the car found and closed one additional latent orphan beyond the three prescribed. Convergent and clean. The branch is clear for the whole-branch gate.

```starcar-artifact
outcome: APPROVE
findings: Round 2 delta re-review, zero findings. The round-1 Major (citation drift from B.4's minus-four line shift) is closed by mechanism. All five checks pass at HEAD 8826566. Check 1: diff is exactly four files, every changed line inside a comment or markdown block, no executable code touched. Check 2: the three re-anchors now reference targets by function name (Get-ResultBlockForTask last-wins return at Land-Verdict.ps1 line 111; ConvertTo-PortablePaths at line 114, cited from Produce-Artifact.ps1 and index-format.md) and each named function verifiably contains the claimed behavior at HEAD. Check 3: the fourth orphan the car self-swept is real - base citation lines 317 to 321 covered the BOM-free UTF8Encoding write at base, and the minus-four shift moved UTF8Encoding to line 316, outside the range; re-anchored to the WriteAllText with a BOM-free UTF8Encoding by name, which exists at Land-Verdict.ps1 lines 316 to 317. Check 4: my own git grep for Land-Verdict.ps1 colon-digit citations in live dirs returns none; all remaining hits are in frozen records (design, plans, specs, reviews), and the frozen-record exclusion is mandatory because landed verdicts are hash-verified historical records that must not be edited. Check 5: scripts tests 73 of 73, probes 8 of 8, Verify-Verdict exit 0 with 19 files - no count moved. The car exceeded my prescribed three re-anchors and closed a fourth orphan my round-1 review missed.
abstract: APPROVE. The single mechanical citation-drift Major from round 1 is fully resolved by re-anchoring four code and prose citations to function names instead of fragile line numbers - the same remedy the spec process adopted at its round 4. The fix is comment-only across exactly four files, changes no executable line, moves no test count (73 tests, 8 probes, 19 verdicts all steady), and introduces no new finding. Convergence is clean: one Major to zero, no swirl, and the car self-swept an additional orphan the round-1 review had missed. Read-only worktree stayed clean throughout at base 8826566. The branch is clear for the whole-branch gate.
```