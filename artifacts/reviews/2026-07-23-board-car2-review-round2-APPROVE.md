<!-- starcar-integrity: sha256=8f8a0e4b46db3c7d28997ea805908e1438e1ed5a0ef28252d658f2702c596064 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Yard board Car 2 delta round 2: APPROVE - C2R-1 fixed durably (section-anchored citations, class-level), merge clear

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (adversarial delta, Opus, same reviewer fix-cycle)
Round: 2
Target: `car/board-car2 at b55fb17 (6 commits)`
Base reviewed: `b55fb178503b6b5df0c7fc898bb731de6f02922b`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a21c8b80339f1c8fd`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `b55fb178503b6b5df0c7fc898bb731de6f02922b` |

| Dispatch, the locator within the session | `a21c8b80339f1c8fd` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain b55fb178503b6b5df0c7fc898bb731de6f02922b
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All checks pass. Fresh-eyes on the one-commit diff (233133e..b55fb17): it touches only the two comment strings — no data, no assertions, no logic changed — so the unchanged 206/206 and 11/11 counts confirm nothing broke, and the JSON re-parses cleanly (the 11/11 BoardDefs run proves board-defs.json is still valid).

---

## VERDICT: APPROVE — merge is clear

C2R-1 is correctly and durably fixed. No new findings.

### Fix verification (round 2, delta scope)

1. **C2R-1 resolved, instrument choice ruled SOUND.** Both stale citations are gone:
   - `schema/vocab/board-defs.json:2` now cites `schema/yard-snapshot.schema.json's top-level properties.vocabularies` (for the block) and `properties.vocabularies description` (for the raw-id note), replacing `:102-112` and `:104`.
   - `scripts/tests/BoardDefs.Tests.ps1` header now cites `properties.vocabularies` (JSON-pointer path) replacing `:102-112`.
   - The anchors genuinely resolve (verified by parsing the wire schema at HEAD): `properties.vocabularies` IS a top-level property; it contains exactly `positions,outcomes,roles,liveness` (matching the citation's claim); its `description` is the raw-id/detector-path note ("...renders by raw id through the detector path"), so `properties.vocabularies description` resolves to what the citation claims.
   - **Ruling on the instrument:** the section-anchored (JSON-pointer) form is the correct, durable-preferred choice — strictly better than re-pinning a fresh line number, because it survives the exact failure mode that caused C2R-1 (a later `$defs` insertion above the block). Re-pinning `:187-197` would have been rot-prone against the very next schema edit; anchoring by structural path is rot-proof. This is a fix of the class, not just the instance.

2. **Class-sweep confirmed.** `git diff 395aa9f..b55fb17 | grep -E "yard-snapshot\.schema\.json:[0-9]"` returns **zero** — no `file:NUMBER` citations remain anywhere in the train's diff. The car's claim that the other four `yard-snapshot.schema.json` mentions are bare file-path references (no line number, not subject to this rot class) is consistent with the zero-hit sweep. `docs/templates/car-brief.md:47-48` opened and verified: those lines carry the `starcar-artifact` outcome set `(done / done-with-findings / honest-stop)` — the `done-with-findings` contract-enumeration citation in `outcomes.json`'s `$comment` is accurate.

3. **Suites unchanged.** `BoardDefs.Tests.ps1`: **11/11** at b55fb17. Full Pester: **206/206** (0 failed) at b55fb17. Both match round-1 counts. Worktree clean.

4. **Fresh-eyes on the diff — nothing broken, no new imprecision.** The commit is comment-only; register data and test assertions are untouched. The commit message is accurate and self-disclosing (names C2R-1, the causing commit 9d53b9c, the 6-hit class-sweep, the car-brief re-check, and states it re-verified the line numbers itself rather than trusting prior figures).

### Non-blocking observation (not a finding)
`BoardDefs.Tests.ps1`'s new comment retains a bare `:187-197` inside its **forensic** narrative of the drift ("9d53b9c ... moved the block to :187-197 without either citing file being touched"). It is accurate at HEAD and framed as past-tense history of what a specific commit did, not as a navigational pointer — the load-bearing citation a reader follows is the section-anchored one. Acceptable as-is; if the block ever moves again, this becomes a slightly stale historical detail, but the durable citation stays correct. No action required.

The Major from round 1 is cleared; no Major or Minor remains. Merge is clear.

```starcar-artifact
outcome: APPROVE
findings: No new findings. C2R-1 (the round-1 Major) is correctly and durably resolved in commit b55fb17. Both stale line-number citations (schema/vocab/board-defs.json:2 and scripts/tests/BoardDefs.Tests.ps1 header) were replaced with section-anchored JSON-pointer citations (properties.vocabularies / properties.vocabularies description) that resolve correctly against the wire schema at HEAD and are rot-proof against future $defs insertions - the correct instrument choice, ruled sound, fixing the class not just the instance. Class-sweep confirmed: git diff 395aa9f..b55fb17 grep for yard-snapshot.schema.json:NUMBER returns zero; the remaining four mentions are bare file-path references not subject to the rot class. car-brief.md:47-48 opened and confirmed to carry the done/done-with-findings/honest-stop outcome set, so the outcomes.json contract-enumeration citation is accurate. Suites unchanged: BoardDefs 11/11, full Pester 206/206 at b55fb17, worktree clean. One non-blocking observation (not a finding): the test-file comment keeps a bare :187-197 inside a past-tense forensic note about the drift, accurate at HEAD and not a navigational citation, so acceptable as-is.
abstract: Delta re-review round 2 (verify-the-fix, same-agent reuse, no rotation trigger) of Car 2's C2R-1 fix on the yard-board train, at worktree HEAD b55fb178503b6b5df0c7fc898bb731de6f02922b. The round-1 Major (stale file:line citations to the wire schema's vocabularies block, born stale because this train's own commit 9d53b9c inserted 85 $defs lines above the block before the citing files were authored) is fully resolved: the car re-anchored both citations to JSON-pointer structural paths (properties.vocabularies), which I verified resolve to exactly what they claim by parsing the schema, and which are durable against the recurrence of the exact insert-above failure mode - the correct, class-level fix. Independent class-sweep of the whole train diff finds zero remaining line-number citations; car-brief.md:47-48 reference verified accurate; BoardDefs 11/11 and full Pester 206/206 unchanged; worktree clean. APPROVE, merge is clear. This is a clean fix-cycle close: a REJECT caught a real citation-truth defect at round 1 and the same-agent delta confirmed the durable remedy at round 2.
```