<!-- starcar-integrity: sha256=4dac8103b9faaf7fec2f7f34f650b884ab55d994e8fbda6bd5ce7704f10dae1e covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# PR-18 correctness-fix train review: APPROVE (fresh worktree, 4 fault injections)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (adversarial, Opus, fresh detached worktree)
Round: 1
Target: `car/pr18-correctness-fixes at add53f3 (7 commits)`
Base reviewed: `add53f3200440e2d221469b74e9e96e984602b6f`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `ab533387b9d497ac7`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `add53f3200440e2d221469b74e9e96e984602b6f` |

| Dispatch, the locator within the session | `ab533387b9d497ac7` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain add53f3200440e2d221469b74e9e96e984602b6f
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All dimensions verified. Tree pristine at HEAD add53f3, tests 151/151, probes 12/12, Verify-Verdict exit 0 / 27 verified. Here is my verdict.

---

# VERDICT: APPROVE

Seven commits, base verified (`add53f3`, seven above `7cc4539`, clean tree). Every fix does what the plan and Copilot findings require; all four load-bearing fixes were fault-injected and watched to fail, then reverted byte-identical. No Major, no Minor. One NOTE (Migrate-Verdicts Law-6, gated) below. Diff scope is exactly the F1-F7 surfaces plus the disclosed F4 ripple.

## Baselines re-derived at HEAD (pwsh 7.6.3, Pester 5.8.0)
- Board tooling tests: **151/151 passed, 0 failed** at `add53f3`, observed by reviewer.
- Substrate probes: **12/12 passed, 0 failed** at `add53f3`, observed by reviewer.
- `Verify-Verdict.ps1`: **exit 0, 27 verdict files verified**, observed by reviewer.
- Car's claims (151/12/exit-0/27) all reproduce.

## Per-fix verification

**F1 (SPINE) - offset-aware chronological sort - VERIFIED.** `Get-AtInstant` added to `Artifact.psm1:87` (exported, line 143), sorting by `.UtcDateTime`. Applied at all three sites: `New-ArtifactIndex.ps1:77` (index sort), `Detect-Dispatches.ps1:144-149` (dispatch-winner), `:202-205` (intent supersession). Both inline `[datetimeoffset]::Parse` sites (`:56`, `:183`) are disclosed in-comment as elapsed-time subtractions needing the `DateTimeOffset` shape - the PR1-m3 disposition, sound. Empirically confirmed `Get-AtInstant('2026-07-22T14:18:03-04:00')` equals `Get-AtInstant('2026-07-22T18:18:03Z')`. Living docs trued same-commit: `schema/index-format.md:46` now reads "normalized to a UTC instant"; the false "lexical sort IS a chronological sort" comment at the sort site is rewritten; the `-DateKind String` comment is re-anchored to column-rendering ("regardless of how it sorts") - not stale.

**F2 - index reconcile - VERIFIED.** Regenerated over the full store: `Wrote artifacts/index.md (51 rows)`, `git diff --exit-code artifacts/index.md` returns clean at HEAD. The CI-red is genuinely cleared.

**F3 - cell escaping - VERIFIED.** `Format-IndexCell` (`New-ArtifactIndex.ps1:84-88`) escapes `|` and collapses newlines. Fault-injected (see log): a pipe/newline-bearing record breaks the row without it.

**F4 - store integrity - VERIFIED.** `StoreIntegrity.Tests.ps1` validates schema AND recomputes integrity in one `It` per record (no split), plus a built-in non-vacuity fault-injection. `Get-Sha256Hex` genuinely EXTRACTED to `Artifact.psm1:124` - the producer's script-local copy was removed (diff d3641e8) and replaced by `Import-Module ... Artifact.psm1`; producer (`:247`) and test (`:49`) consume the one function.

**F5 (RL-1+RL-2) - producer read-failure - VERIFIED end-to-end.** Drove the producer against a nonexistent transcript in a throwaway repo: record lands `outcome:error`, **no `envelope` field** (`$envFault` stays null so `Produce-Artifact.ps1:239` omits it), read error in `findings` ("transcript not found: ..."), `abstract` set ("transcript read failure - see findings"), a `_faults.log` line naming the failure, and `Test-StarcarArtifact` Valid=True. The brief-absence distinction is preserved and independently tested (`Producer.Tests.ps1:130`, readable no-fence transcript still yields `envelope:absent`).

**F6 - README - VERIFIED by sentence check.** Each claim traced to code: producer hook writes records (`Produce-Artifact.ps1`, ran it), detector folds (`Detect-Dispatches.ps1`, emits dispatches/intents), `Test-StarcarArtifact` validates (`Artifact.psm1`, Valid=True observed), index generator writes `artifacts/index.md` (ran it, 51 rows), "all exercised by a Pester suite under CI" (`ci.yml:152`, 151/151 observed). The negative claim "no board that renders a fold on screen" holds: `scripts/board.ps1` is a GitHub Project kanban wrapper, not a fold visualizer; no server/render code exists.

**F7 - state-ledger - VERIFIED.** Row flipped to ARMED naming the `ci.yml` "Verify the artifact index is not stale" step, which exists (`ci.yml:162-177`, regenerate + `git diff --exit-code`). Consistent with the already-ARMED `gating-matrix.md:19` row.

**F4 ripple (disclosed) - VERIFIED sound.** `LandVerdictRider.Tests.ps1` flood fixture now copies `Artifact.psm1` alongside the patched producer (the new import dependency). Non-vacuity intact: the flood-injection regex still matches a real line (`Produce-Artifact.ps1:127`), the `Should -Match 'FLOOD INJECTION'` sanity check guards a silent no-op, and the `filtered=1 / unfiltered=2` assertions still require the patched producer to actually write both records. Flood test runs green in isolation.

## Fault-injection log (all reverted byte-identical, clean tree confirmed each time)

1. **F1 spine** - changed `Sort-Object -Property AtInstant` back to `At` (lexical) in `New-ArtifactIndex.ps1`. Offset fixture went RED: "orders chronologically across mixed offsets" FAILED. Reverted; `git status` clean.
2. **F1 fail-loud** - direct call: zoneless `at` throws `Get-AtInstant: 'at' value '2026-07-22T16:39:57' has no timezone offset ... refusing to parse it TZ-dependently`; generator wraps it naming the file (`New-ArtifactIndex: &lt;path&gt;: ...`). Not a silent mis-sort, not an unattributed crash.
3. **F3 escaping** - replaced `Format-IndexCell` body with passthrough. F3 test FAILED (row broke). Reverted; clean.
4. **F4 integrity** - flipped one hex char in a real record's `integrity`. Per-record test FAILED for that file; restored via `git checkout`, 52/52 green. Gate is non-vacuous.
5. **Index-staleness gate (F2/F7)** - added an unindexed store record, ran the exact CI step (regenerate + `git diff --exit-code`): exit 1, gate FIRES. Removed record + restored index; clean. (First attempt appending to the index file was a bad injection - regeneration overwrites it - corrected to the real drift scenario.)

## Law-6 Migrate-Verdicts ruling: ACCEPTABLE DISCLOSED EXCEPTION (NOTE, non-blocking)

`Migrate-Verdicts.ps1:42` keeps its own byte-identical `Get-Sha256Hex`. Disclosed in `Artifact.psm1:124-133`, the F4 commit, and `Produce-Artifact.ps1:65-68`. Ruling: not a finding, because (a) the approved plan scoped F4's extraction to the named Copilot target (`Produce-Artifact.ps1`) only - expanding it is scope creep; and, decisively, (b) the copy is **mechanically gated, not merely prose-disclosed**: F4's `StoreIntegrity` test recomputes every migrated record (which this tool wrote) with the canonical shared function, so any future drift in Migrate's copy plus a re-migration surfaces as a CI red. That is the Healing-Loop-preferred form ("facts land as tests or gates, never only prose"). Recommendation (non-blocking): file a tracking issue for eventual consolidation. Secondary NOTE: F4's own integrity check shares `Get-Sha256Hex` with the producer, so it is not an independent oracle of that function's correctness - but the independent oracle exists (`Producer.Tests.ps1:217` recomputes with a test-local copy), so the system is not vacuous.

## Constitution check

- **Law 1 (no confident falsehood; unknown renders loud):** F1 `Get-AtInstant` throws-naming rather than mis-sorting (watched); F6/F7 docs trued to reality. Honored.
- **Law 4 (no silent loss):** F5 read error now lands in `findings` AND `_faults.log` (watched end-to-end); previously discarded. Honored.
- **Law 6 (one owner):** `Get-AtInstant` and `Get-Sha256Hex` centralized in `Artifact.psm1`, producer copy deleted. Migrate-Verdicts residual is gated + disclosed (ruling above). Honored.
- **Law 7 (the stranger):** F5 findings path normalized to the repo placeholder; README true-always (names what runs vs unbuilt, no fictional quickstart). Honored.
- **Living docs, same commit:** F1 (schema + in-code comments), F7 (ledger), F6 (README) each land in the commit that invalidated them. Honored.
- **TDD red-first / regression-vault non-vacuity:** every behavioral fix carries a red-first test; F4's arrival-green check has an in-suite fault-injection. Honored.
- **Sentence check (user-facing docs):** README claims traced hop-to-code with file:line above. Honored.

## Model-probe note

Car ran on Sonnet with a precisely enumerated plan (F1-F7, explicit red cells, file:line targets, disposition table). The prior model-finding was "Sonnet misses un-enumerated cross-boundary surfaces." This train had exactly one un-enumerated cross-boundary surface: the module extraction (F4) rippled into `LandVerdictRider.Tests.ps1`'s flood fixture, which copies the producer into an isolated dir and so needed the new `Artifact.psm1` dependency copied too. It was **not** in the plan - and the car caught it, fixed it same-commit, and disclosed it. Classification: the catch came from **mechanism, not enumeration** - the car ran the full suite, the flood test went red (patched producer couldn't import the module), and the car diagnosed and fixed it. This is the healthy pattern: the enumerated brief drove the deliberate work while the test suite caught the surface the brief could not foresee. No defect attributable to EXECUTION, INHERITED, or JUDGMENT was found.

## Handback reminder (on APPROVE)

Per the plan's handback: conductor merges to `dev`, RE-reconciles the index over the merged store (review-cycle records land during this very review), commits, then `Watch-CI.ps1 -Branch dev` to a recorded terminal green before PR #18 proceeds.

Relevant files (all absolute):
- `~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\64c15364-0933-4d6d-9b2e-d1ddbc918f9f\scratchpad\review-fixtrain\scripts\Artifact.psm1`
- `...\review-fixtrain\scripts\New-ArtifactIndex.ps1`
- `...\review-fixtrain\scripts\Detect-Dispatches.ps1`
- `...\review-fixtrain\scripts\Produce-Artifact.ps1`
- `...\review-fixtrain\scripts\Migrate-Verdicts.ps1`
- `...\review-fixtrain\scripts\tests\StoreIntegrity.Tests.ps1`
- `...\review-fixtrain\scripts\tests\Producer.Tests.ps1`
- `...\review-fixtrain\scripts\tests\LandVerdictRider.Tests.ps1`
- `...\review-fixtrain\.github\workflows\ci.yml`
- `...\review-fixtrain\README.md`, `docs\contracts\state-ledger.md`, `schema\index-format.md`

```starcar-artifact
outcome: APPROVE
findings: |
  PR-18 correctness-fix train (7 commits, base add53f3 verified, clean tree). All
  F1-F7 fixes verified; four load-bearing fixes fault-injected and watched to fail,
  reverted byte-identical. Re-derived at HEAD: tests 151/151, probes 12/12,
  Verify-Verdict exit 0 with 27 verified.
  F1: Get-AtInstant offset-aware sort at all three sites; fail-loud on zoneless/unparseable
  at, watched throwing named value plus generator naming the file; lexical-sort fault
  injection went red; docs (index-format.md, in-code comments) trued same-commit.
  F2: index regenerates clean, git diff exit-code empty at HEAD, 51 rows.
  F3: cell escaping present; passthrough fault injection broke the row.
  F4: StoreIntegrity validates schema plus integrity per record (no split); Get-Sha256Hex
  genuinely extracted to Artifact.psm1 (producer copy removed); real-record corruption
  caught then restored via git checkout.
  F5: producer read-failure driven end-to-end - outcome error, no envelope field, read
  error in findings and faults log, abstract set, schema-valid; brief-absence still yields
  envelope absent (preserved and tested).
  F6: README sentence-checked, every claim traced to code; board.ps1 confirmed a GitHub
  project wrapper, not a fold visualizer.
  F7: ledger row ARMED, ci.yml staleness step exists; watched the gate fire on an
  unindexed record then restored.
  F4 ripple (LandVerdictRider flood fixture) sound and non-vacuous.
  Law-6 Migrate-Verdicts second copy: acceptable disclosed exception, gated by F4's
  whole-store recompute; recommend a non-blocking tracking issue.
  No Major, no Minor. Per-commit scope maps exactly to F1-F7 plus the disclosed ripple;
  docs land same-commit. Model probe: Sonnet on a precise brief; the one un-enumerated
  cross-boundary surface (flood fixture) was caught by running the suite, not by
  enumeration, and fixed same-commit - the healthy mechanism-over-attention pattern.
abstract: |
  APPROVE. Seven-commit PR-18 correctness-fix train verified against the closed rev-2
  plan. All fixes correct, load-bearing guards watched firing and reverted byte-identical,
  tree pristine at add53f3 with tests 151/151, probes 12/12, Verify-Verdict exit 0/27.
  One non-blocking NOTE (Migrate-Verdicts Law-6 copy, disclosed and gated). Conductor:
  merge to dev, re-reconcile the index over the merged store, Watch-CI to recorded green
  before PR 18 proceeds.
```