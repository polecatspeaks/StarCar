<!-- starcar-integrity: sha256=838b53998dacd786ec883bfafdf7759941a661153aff9f5c89683afc676252bf covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Doc map review round 1: REJECT - the map violated its own reality-wins rule with an off-by-one template count

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Document review (adversarial fidelity, Opus, detached worktree)
Round: 1
Target: `docs/doc-map.md v1 at b31154a`
Base reviewed: `b31154aaa440a7e787024a89aaa6336f8b4295fa`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `accbde6200eebcfc4`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `b31154aaa440a7e787024a89aaa6336f8b4295fa` |
| Entire checkpoint | `ff66c1c3bf18` |
| Dispatch, the locator within the session | `accbde6200eebcfc4` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain b31154aaa440a7e787024a89aaa6336f8b4295fa
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# Fidelity Review Verdict: docs/doc-map.md

## VERDICT: REJECT

Base verified: HEAD at `b31154aaa440a7e787024a89aaa6336f8b4295fa`, detached worktree, clean. One Major = REJECT.

This is a fidelity/audience check on a one-file navigation map. The map is well-built: every reading path resolves, every classification spot-check I ran holds, the doc-policy gate passes, and the review-count claims on the provenance surfaces are correct. It fails on exactly one axis - a count claim the map itself invited me to check, and the same class the UI brief was REJECTed for.

---

## Findings

### DM-1 (MAJOR) - `docs/templates/` class row states "(15 files)"; the directory holds 16
Row: `docs/doc-map.md:41`. The row reads ``docs/templates/` (15 files)``. Actual: `ls docs/templates/*.md` returns **16** files (car-brief, design-briefs, design-doc, gating-matrix, ops-script-patterns, repo-policy-check-patterns, state-ledger, and nine `worked-*` exemplars). No reasonable subset yields 15 either: rung-artifact templates (5) + worked exemplars (9) = 14; + the two `*-patterns` docs = 16. The "(15)" matches nothing on disk.

This is a defect by the map's OWN stated rule (`doc-map.md:8-10`): "if a row and reality disagree, reality wins and the row is a defect - fix it in the commit that finds it." The map used the precise form "(15 files)" - contrast the deliberately-approximate "~42 documentation surfaces" (`:5`, tilde), which shows the author distinguishes exact from approximate counts. A wrong exact count on a navigation surface is a lying canary on a document that is fresh today, and it is precisely the class the brief flags: "A wrong count on a provenance surface is exactly the class the UI brief got REJECTed for." Consistency with that precedent and with the map's self-declared standard makes this Major, not cosmetic. Fix: change to 16 (and keep it current the day a template lands or leaves).

### DM-2 (MINOR) - index.md `#20` gating claim is true-but-incomplete
Row: `doc-map.md:55` says "gated at PR-to-main per #20." The gating matrix (`docs/contracts/gating-matrix.md:19`) and the index header itself (`artifacts/index.md:3-6`) both state the gate fires on **PR-to-main AND push-to-main**. The map names only PR-to-main. Not false (PR-to-main is the operative path anyway, since branch protection forbids direct pushes to main), but it undersells the contract. Minor because the omitted half is unreachable under standing branch topology; recommend "gated at PR/push-to-main."

### DM-3 (MINOR / observation) - the map does not classify itself
`docs/doc-map.md` is a documentation surface a stranger walking the tree will encounter, and it appears in no row or class. Self-reference is arguably unnecessary for a map, so I raise this as an observation rather than press it - but the omission sweep is required to name it, and the author may want a one-line self-row for completeness.

---

## What I verified TRUE (the map earns these)

**Every row resolves.** I walked `ls *.md`, `find docs -name '*.md'`, `schema/*.md`, `schema/vectors/*.md`, `artifacts/index.md`, `artifacts/reviews/` (64 files), `.claude/agents/*.md` (only `car.md`), `board/web/vendor/*/VENDOR.md` (only `cfworker-json-schema/VENDOR.md`), `AGENTS.md`. Every named path exists. Class rows (`docs/design/*`, `docs/specs/*`, `docs/plans/*`, `docs/probes/*`, `docs/retros/`, `artifacts/reviews/*`, vendor) each cover their real members with no orphaned files - excepting the DM-1 count and DM-3 self-omission.

**Classification spot-checks (6+ deep):**
- `CLAUDE.md` "reference + explanation" - it is the statute index plus scarred explanation; accurate.
- `docs/constitution.md` "LIVING (amendment-only)" - header `:6-9` "Amendments go through the owner"; accurate.
- `docs/friction-log.md` "FOSSIL (append-only)" - header `:4` "Convention: append-only within a session"; accurate.
- `artifacts/index.md` `#20` gating - substantiated against gating matrix `:19` (see DM-2 for the incompleteness).
- Board design "rev 5, APPROVED, live contract" - State line `docs/design/2026-07-21-v0-yard-skeleton-design.md:4` "rev 5 APPROVED at design review round 4"; accurate.
- Board spec "rev 2, APPROVED, binds Cars 1-5" - State line `docs/specs/2026-07-23-yard-board-spec.md:4` "rev 2 APPROVED"; the plan `docs/plans/2026-07-23-yard-board-plan.md` defines Cars 1-5 (§2-§6); accurate.
- `artifacts/reviews/*` "hash-sealed / integrity-hashed" - `scripts/Verify-Verdict.ps1` exists, defaults to `artifacts/reviews` (`:36`), recomputes SHA-256 over every byte after the `starcar-integrity:` line for every file (`:60-73`); accurate.

**Three reading paths - counts TRUE against filenames:**
- Student path "five REJECT verdicts (rounds 1-5)" - `artifacts/reviews/2026-07-22-harness-design-round{1..5}` all REJECT (round 4 = REJECT-ESCALATED); exactly 5, all REJECT. TRUE.
- "the spec's four rounds" - `harness-spec-round{1..4}` (REJECT, DELTA-REJECT, CONFIRM-REJECT, APPROVE); exactly 4 rounds. TRUE.
- Every named doc in all three paths exists (README, constitution, setup, CLAUDE, car-brief, contracts/, dispatch-harness-design, harness-train-retro, friction-log). Ordering is pedagogically sound (bedrock → mechanism → worked saga).

**Stranger test:** the map's own sentences parse cold. WORKED EXEMPLAR is glossed (`:20-23`); Family, quadrant, and LIVING/FOSSIL are each defined before use (`:16-29`); Diátaxis names its four quadrants inline. "Rung"/"car" lean on `CLAUDE.md` for depth, which the brief permits for a map. Passes.

**Tension check:** the map affirms the trigger-gated restructuring posture (`:6-8`, `:93`), carries `Status: Current` (`:3`), and cites the NORTH STAR stranger-wins rule (`:18`). No contradiction with standing doctrine. `Invoke-Pester ./scripts/tests/DocPolicy.Tests.ps1` → **2 passed, 0 failed** at HEAD `b31154a` (observed by this reviewer). The map passes its own gate - which is exactly why DM-1 matters: the doc-policy gate cannot catch a wrong count (the map says so itself at `:93-95`), so the reviewer is the only gate on it.

**Ruling on `docs/design/2026-07-23-ui-mockup-brief.md` (omission sweep):** covered by the `docs/design/*` class row (`:48`). It is a design-family, rung-1-adjacent artifact living in `docs/design/`; its "Rung-1 artifacts" class claim holds. No separate row required. Not a finding.

---

## Constitution check (laws the diff implicates)
- **Law 1 (Truth / no confident falsehood on an information surface):** honored everywhere I traced EXCEPT DM-1 - a precise "(15 files)" that is false on day one is a confident falsehood on a navigation surface, which is why it is Major.
- **NORTH STAR (documentation ranks equal to code; stranger wins):** honored - the map cites it and is built stranger-first; DM-1/DM-2 are the shortfall against it.
- **Living-doc rule (invalidating commit updates the doc same-commit):** the map correctly states this is its own governing law (`:93-95`); DM-1 is a living-doc defect present at birth.
- **Trigger-gated restructuring (docs/setup.md):** honored - map moves/renames nothing and says so.

Re-review path: fix DM-1 (count → 16), address DM-2/DM-3 at author discretion, re-run `DocPolicy.Tests.ps1`, and this clears. A single off-by-one is the whole distance between this map and APPROVE - a cheap catch at the cheapest gate, which is the gate working.

```starcar-artifact
outcome: REJECT
findings: DM-1 (MAJOR) docs/doc-map.md:41 - the docs/templates/ class row claims "(15 files)" but the directory holds 16 .md files (verified by ls docs/templates/*.md); no reasonable subset yields 15; wrong exact count on a navigation surface, a defect by the map's own "reality wins, the row is a defect" rule and the exact class the UI brief was REJECTed for. DM-2 (MINOR) doc-map.md:55 - index.md gating stated as "PR-to-main per #20" but the gating matrix (gating-matrix.md:19) and index header (artifacts/index.md:3-6) gate on PR-to-main AND push-to-main; true-but-incomplete. DM-3 (MINOR/observation) - the map classifies neither itself (docs/doc-map.md) in any row or class. Everything else verified TRUE: all rows resolve, six deep classification spot-checks hold (CLAUDE reference+explanation, constitution amendment-only, friction-log append-only, board design rev5 APPROVED, board spec rev2 APPROVED binding Cars 1-5, reviews hash-sealed via Verify-Verdict.ps1), all three reading paths resolve with correct counts (5 harness-design REJECTs rounds 1-5, spec 4 rounds), stranger test passes, DocPolicy.Tests.ps1 2/2 passed at b31154a, ui-mockup-brief ruled covered by the docs/design/* class row.
abstract: Adversarial fidelity review of docs/doc-map.md at HEAD b31154a. One Major (DM-1: templates class row says 15 files, actual 16 - a wrong count on a navigation surface, the map's own rule makes it a defect and the UI-brief precedent makes it REJECT-class) forces REJECT. Two Minors (incomplete index gating claim; map does not self-classify). The map is otherwise sound: every path resolves, classifications are honest, reading-path counts are true against artifacts/reviews filenames, the doc-policy gate passes, and no doctrine tension. A single off-by-one is the entire distance to APPROVE. Read-only review, nothing committed or pushed.
```