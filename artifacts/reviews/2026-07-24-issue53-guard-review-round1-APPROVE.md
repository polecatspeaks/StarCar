<!-- starcar-integrity: sha256=679a63caae74f3daef3d19a3a16d85867e4bf8b7be4af7ab97eb141166d6dde5 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Issue #53 duplicate-dispatch guard fix - adversarial review round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-review

Target: `car/53-dispatch-guard a6226ea (merged 230f56f)`
Base reviewed: `d09dd2d`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE-FOR-MERGE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `53-guard-review-r1`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `d09dd2d` |
| Entire checkpoint | `e625da768a9e` |
| Dispatch, the locator within the session | `53-guard-review-r1` |
| Entire session (context, NOT a lookup key) | `rev53-r1-transcript` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain d09dd2d
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Agent is idle (waiting for messages). agent_id: 53-guard-review-r1, agent_type: car, status: idle, description: Review: car 53 guard fix, elapsed: 257s, total_turns: 1, model: claude-opus-4.8

[Turn 0]
All verification complete. Tree byte-clean, HEAD unchanged — fault injection fully reverted.

## Verdict: APPROVE-FOR-MERGE

**Base verified:** worktree `<repo>-car53`, branch `car/53-dispatch-guard`, HEAD `a6226ea` with parent `d09dd2d` — one substantive commit, 2 files, +56/−6. Correct base history.

### Findings: 0 Major, 0 Minor

The fix replaces the permanently-latching predicate (`$existingDisp.Count -gt 0 -and $existingRet.Count -eq 0`) with a newest-dispatched-vs-newest-returned lexical comparison. Logic re-derived and sound:
- Inductively maintains the "at most one un-superseded dispatched" invariant (a second in-flight dispatch cannot land, so two unreturned dispatched records never coexist).
- Same-second tie ruling (`>=`, return supersedes dispatch) is **documented in-code** (lines ~398–402) and defensible — the producer never mints two records per call, so a genuine same-second collision is an external clock/replay artifact, not the concurrent-duplicate case DR-9 targets. Not a defect.
- Orphan `returned`-with-no-`dispatched` correctly unchanged (guard only runs for `Kind -eq 'dispatched'`).

### Suites I ran myself (at a6226ea)
| Suite | Observed | SHA |
|---|---|---|
| scripts/tests (`Invoke-Pester -Path scripts\tests -CI`) | **279 passed, 0 failed** | a6226ea |
| scripts/probes | **22 passed, 0 failed** | a6226ea |
| #53 test only (green, post-restore) | 1 passed | a6226ea |
| #53 test only (RED, base injected) | **1 failed** | d09dd2d code |

Base Producer.Tests has 23 `It` blocks, head has 24 (+1 new) → base full suite = 278, head = 279. Consistent with the car's disclosed 278/278 baseline observation; the brief's "276" predates two tests added before d09dd2d. **Car's number is honest.**

### Fault-injection disclosed
Reverted `scripts/Produce-Artifact.ps1` to `d09dd2d` (`git checkout d09dd2d -- scripts/Produce-Artifact.ps1`), ran the #53 test. **Observed failure** (verbatim): `Expected 0 to be different from the actual value, because newest dispatched (11:00) is NOT superseded by any returned record; unbounded in-flight duplicates must be refused (#53), but got the same value.` at `Producer.Tests.ps1:367` — third dispatch wrongly admitted (exit 0), exactly the stated defect. **Restored** via `git checkout a6226ea -- ...`; `git status --porcelain` empty, `git diff a6226ea` = 0 lines, test green again. RED is non-vacuous. Final tree byte-clean, HEAD still `a6226ea`.

### Sentence-check trace (guard inputs, hop-by-hop)
1. **Producer writes** `$recordPath = Join-Path $subjectDir "$Kind-$compactAt.json"` (line 424) where `$compactAt = $at -replace '[-:]',''` (line 375) → e.g. `dispatched-20260722T100000Z.json` — fixed-width `yyyyMMddTHHmmssZ`, zero-padded, no separators.
2. **Guard reads** same store via `Get-ChildItem -Filter 'dispatched-*.json' / 'returned-*.json' | Sort-Object Name`, takes `[-1]` (newest). Fixed-width names ⇒ lexical sort = chronological.
3. **Strips** `^dispatched-` / `^returned-` → stamp `20260722T100000Z.json` (identical `.json` suffix on both sides, so it does not perturb the compare).
4. **Compares** `$retStamp -ge $dispStamp` (string, digits/`T`/`Z` only — no culture hazard). Consumer format = producer format exactly. Trace holds at every hop.

### Doc-staleness check
Grep for the old predicate literal (`existingRet.Count -eq 0`) finds it ONLY in the new fix's own historical-reference comments (Produce-Artifact.ps1:388) and test (Producer.Tests.ps1:354) — no stale mirror. The spec (`docs/specs/2026-07-22-dispatch-harness-spec.md:67-72`), family-agnostic design (`docs/design/2026-07-24-family-agnostic-harness-design.md:33,89,90,128,183`), and glossary all describe the guard in the CORRECT "un-superseded dispatched record / in-flight duplicates only" semantics. **The docs were never stale — they encoded the intended behavior in prose; the buggy code was the divergence, and this fix realigns code to documented intent.** Car's "no docs needed changing" claim VERIFIED.

### Constitution check
- **Law 4 (never drop a fault):** refusal still throws → `Add-Fault` → `_faults.log` (catch block, lines 452-456); new test asserts `_faults.log` matches `duplicate dispatch refused`. Honored.
- **Law 6 (one authority):** identity/dedup at the mint boundary remains the sole producer authority; fold superseded-exposure stays the downstream backstop, untouched. Honored.
- **Red-first TDD:** demonstrated above — test fails at base for the stated reason, green after fix.
- **Docs rank equal to code:** verified no doc invalidated; intent-docs already matched. Honored.
- **Code-standard citation:** new comment, throw message, commit subject/body all cite #53; `Co-authored-by: Copilot` trailer present. Honored.

No Major. No Minor requiring tracking. Approved for merge.

```starcar-artifact
task-id: 53-guard-review-r1
outcome: approve-for-merge
findings: 0
abstract: Fix re-derived and correct; ran scripts/tests 279/279 and probes 22/22 myself; RED confirmed non-vacuous via disclosed base injection (reverted byte-clean); newest-dispatched-vs-newest-returned compare consumes the exact producer filename format; docs already encoded the correct un-superseded semantics so none are stale; commit cites #53 with Co-authored-by trailer.
```