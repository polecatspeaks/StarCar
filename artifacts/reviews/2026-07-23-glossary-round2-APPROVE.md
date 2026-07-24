<!-- starcar-integrity: sha256=2372fbcf9766ee6f9ffc90d5599952294b4a61853a094e430599e87f202de734 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Glossary delta round 2: APPROVE - all folds verified from disk; the conductor's spec-contradiction worry DISPROVEN by measurement

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Document review (adversarial delta, Opus, same reviewer fix-cycle)
Round: 2
Target: `docs/glossary.md v2 at 71213b4`
Base reviewed: `71213b42577a061ed9f9396bcda89c1d02e224e4`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a5b5e3024cb48da0c`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `71213b42577a061ed9f9396bcda89c1d02e224e4` |
| Entire checkpoint | `0c8c6ba32c1d` |
| Dispatch, the locator within the session | `a5b5e3024cb48da0c` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 71213b42577a061ed9f9396bcda89c1d02e224e4
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

DocPolicy 2/2 passed at 71213b4. Doc-map row survives. I have everything needed.

## VERDICT: APPROVE

All four round-1 findings are correctly folded, each verified against its source at HEAD `71213b4`. The GL-1 Major that forced the round-1 REJECT is fully resolved: landed behavior now stated in plain present and verified, the entire unbuilt chain explicitly marked in-flight. Two new findings, both Minor/Note and non-blocking. Convergence is clean (findings shrank and moved, not relocated).

Base verified: `git checkout 71213b4` → HEAD `71213b42577a061ed9f9396bcda89c1d02e224e4`. DocPolicy **2/2 passed** at `71213b4`. Doc-map row survives (`docs/doc-map.md:44`).

---

### Round-1 findings walked against v2

**GL-1 (was MAJOR) — RESOLVED.** Entry renamed "Budget / effort" (glossary:75-84).
- Landed clause re-verified against `scripts/Detect-Dispatches.ps1:174-192` and `config/harness-defaults.json` (`dispatch_budget_seconds: 1800`): "a record may carry its own `budget` in seconds; otherwise the fold applies the shop default (1800s) at fold time, and a silent dispatch past it folds to `overdue`." Exact match, plain present is correct.
- The whole in-flight chain — effort classes `lite/normal/heavy`, config-maps-class-to-seconds, producer stamp, `budget_source` — is marked `[RULED, in flight - issue #22, spec Amendment 2, Car 3's fix cycle]` and closes with "None of that in-flight chain runs yet." The unmarked-present-tense defect is gone.
- **Rename framing checked against `gh issue view 22 --comments`:** issue #22 "OWNER RENAME (2026-07-23)" states "PATIENCE becomes EFFORT; classes become lite / normal / heavy ... effort is the work-side name of the same quantity patience named from the waiter's side." The glossary's "effort class (lite/normal/heavy - the work-side estimate; formerly 'patience', renamed by owner ruling)" matches exactly.
- **Spec-contradiction check (the brief warned Amendment 2 "still says patience in one spot"):** this premise does not hold. `grep -rn -i patience docs/specs/` returns NONE — the spec uses `budget`/`budget_source`, which issue #22 explicitly declares UNCHANGED by the rename ("budget_seconds and budget_source are UNCHANGED, no code churn to the in-flight fix cycle"). So the amendment does NOT contradict the rename and **no true-up is owed at the spec.** I surface this rather than passing silently: the conductor's worry was unfounded, measured against disk. Repo-wide (non-fossil), "patience" now survives only inside `docs/glossary.md` itself.

**GL-2 (was MINOR) — RESOLVED.** Now two entries. "Detector" (glossary:91-94) = "the tiered liveness-and-accountability mechanism ... the fold script (`scripts/Detect-Dispatches.ps1`) ... tier 1 ... tier 2 ... deferred" — matches the ratified design's usage (`docs/design/2026-07-22-dispatch-harness-design.md:99,130,194`). "Discovery" (glossary:95-97) = "the fold's output for vocabulary it does not recognise ... renders loudly BY NAME" — matches `Detect-Dispatches.ps1:100-109` (builds `$discoveries` of unrecognised kind/outcome by name, deduped).

**GL-3 (was MINOR) — RESOLVED.** "Producer" (glossary:98-100) = "the hook (`scripts/Produce-Artifact.ps1`) that writes store records ... when a dispatch starts and stops, harvesting the envelope from the dispatch's own transcript." Verified: `Produce-Artifact.ps1:45-46` restricts `-Kind` to `dispatched`|`returned` (start/stop); `:143-150` obtains the outcome from `agent_transcript_path` via the envelope. Match.

**GL-4 (was NOTE) — RESOLVED.** "Adapter" (glossary:101-104) = "a pluggable data source behind the board's one seam ... the store is v0's sole adapter ... Health travels inside an adapter's return value, never beside it." Verified: `docs/design/2026-07-21-v0-yard-skeleton-design.md:127` (D13, store is the SOLE adapter) and `:236` ("the store adapter is ONE adapter behind it, health-in-return-value and all"). Match.

**Tense convention (intro 12-16) — closes the gap I named.** It codifies three tiers: plain present = runs today; `[RULED, in flight - ref]` = ratified-but-unbuilt; contracted design vocabulary (lanes/registers/positions) is legitimate because a landed contract backs it. This is the exact designed-vs-running distinction round 1 said was missing, and it adequately resolves GL-1's enabling condition.

---

### New findings (fresh-eyes on 43652d8..71213b4)

**GL2-1 (MINOR, non-blocking).** The tense convention (glossary:15-16) claims contracted design-vocab "entries say which artifact does [back the contract]." The four board-vocab entries it names as examples — Lane (45-46), Position (47-49), Register (50-52), Solari (53-55) — do NOT cite their backing artifact inline (Register never names `schema/yard-snapshot.schema.json`; Position never names design rev5 §5.2). The facts are correct (I re-confirmed those enums are landed contract), so this is not a Law 1 behavioral falsehood — it is the convention over-promising a citation discipline its own example entries don't follow. Fix (optional): add the artifact cite to those four entries, or soften the clause to drop "and its entries say which artifact does."

**GL2-2 (NOTE, non-blocking).** The Discovery entry (glossary:95) lists unknown "kind, outcome, or **state**." The fold discovers kind and outcome only (`Detect-Dispatches.ps1:15` comment "unrecognised kind/outcome values"; `:100-109`). Folded states are computed by the fold, not read from records, so there is no state-discovery axis; "or state" overstates the implemented axes by one. Reader takeaway (unknowns render by name, never hidden) is correct; precision is slightly loose.

Neither new finding is a Major. Both sit in the tense-convention/precision area, both are cheap prose fixes, neither blocks merge.

### Convergence

Round 1: 1 Major, 2 Minor, 1 Note. Round 2: 0 Major, 1 Minor, 1 Note — both NEW, both non-blocking, clustered in the newly-added tense-convention text (expected: new prose, new small surface area). Findings shrank and moved off the original sites. This is converging, not swirling.

### Constitution check

- **Law 1 (no confident falsehood):** HONORED in v2 — the unlanded chain is marked, landed behavior verified against code. The round-1 violation is gone.
- **NORTH STAR / living docs (true always, complete only when it exists):** HONORED — the tense convention operationalizes exactly this.
- **Match-the-instrument / sentence check:** HONORED by this review — `budget_source`, producer stamp, and the rename each traced to disk (issue #22, spec, fold, producer, config) with file:line.
- **Verdicts land verbatim (fossil):** the round-1 REJECT verdict landed at `artifacts/reviews/2026-07-23-glossary-round1-REJECT.md` in this diff — the showcase-never-edits-the-record law honored.
- **Same-commit doc invalidation:** doc-map row for the glossary survives and is current.

```starcar-artifact
outcome: APPROVE
findings: All four round-1 findings folded and verified at HEAD 71213b4. GL-1 (was Major) RESOLVED - entry renamed Budget/effort; landed behavior (record budget else config default 1800s at fold, silent-past-budget folds overdue) re-verified against Detect-Dispatches.ps1:174-192 and harness-defaults.json; the full unbuilt chain (effort classes lite/normal/heavy, config class-to-seconds map, producer stamp, budget_source) marked [RULED, in flight - issue #22, spec Amendment 2, Car 3 fix cycle] with "none of that runs yet"; rename framing matches issue #22 OWNER RENAME comment exactly. Spec-contradiction warning in the brief did NOT hold - grep of docs/specs for patience returns NONE, the spec uses budget/budget_source which issue #22 declares unchanged by the rename, so no true-up owed; stated rather than passed silently. GL-2 RESOLVED - Detector now = tiered liveness fold script (matches design), Discovery = fold output for unrecognised vocab (matches Detect-Dispatches.ps1:100-109). GL-3 RESOLVED - Producer entry matches Produce-Artifact.ps1:45-46,143-150 (writes on dispatched/returned start-stop, harvests envelope from transcript). GL-4 RESOLVED - Adapter entry matches design D13 and the health-in-return-value seam (design:127,236). Tense convention added to intro closes the designed-vs-running gap named in round 1. Two NEW non-blocking findings: GL2-1 (Minor) the tense convention claims board-vocab entries cite their backing artifact but Lane/Position/Register/Solari do not; GL2-2 (Note) the Discovery entry lists "state" as a discovery axis but the fold discovers only kind and outcome. DocPolicy 2/2 passed at 71213b4; doc-map row survives.
abstract: Delta re-review round 2 of docs/glossary.md v2 at HEAD 71213b4 (verified). APPROVE. The GL-1 Major that forced the round-1 REJECT is fully resolved: the renamed Budget/effort entry states verified landed behavior in plain present and marks the entire ruled-but-unmerged chain in-flight; the patience-to-effort rename matches issue #22, and the brief's worry that the spec still says patience is disproven on disk (no true-up owed). GL-2/3/4 folds all verified against Detect-Dispatches.ps1, Produce-Artifact.ps1, and the design adapter seam. A new tense convention closes the designed-vs-running gap. Two new non-blocking minors on convention over-promise and one imprecise discovery axis. Convergence clean (0 Major, findings shrank and moved). DocPolicy 2/2 green.
```