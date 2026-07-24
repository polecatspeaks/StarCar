<!-- starcar-integrity: sha256=4a3f65f5231c78674e54b039bda9a4236725360aa4e7154577326eb6bccce965 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# UI mockup brief review round 1: REJECT - the brief presented an unbuilt train manifest as live-store data (Law 1 on a provenance doc)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Document review (adversarial, Opus, fidelity + audience, detached worktree)
Round: 1
Target: `docs/design/2026-07-23-ui-mockup-brief.md v1 at 3b04d45`
Base reviewed: `3b04d45b07cefe26b9fce628fcc8e4268a1ea6d9`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `acc25b07aa67ecf2c`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `3b04d45b07cefe26b9fce628fcc8e4268a1ea6d9` |
| Entire checkpoint | `c3e2293b9739` |
| Dispatch, the locator within the session | `acc25b07aa67ecf2c` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 3b04d45b07cefe26b9fce628fcc8e4268a1ea6d9
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Verification complete. I have all evidence needed.

Key store facts (at HEAD 3b04d45):
- `acc761f0add2b0af2` returned exists, outcome `done` (not "coupled/merged"); its car/20 work IS merged into `dev` (commit 565714d present on dev).
- `ac7d81bda8f23f2a6` returned exists, outcome `APPROVE`. Both genuinely real records.
- Design-v0 REJECT records in the store as JSON: only `round1` and `round2`. Rounds 3 and 4 exist as markdown only (`2026-07-23-design-v0-round3-REJECT.md`, `...round4-APPROVE.md`) with NO JSON artifact record.
- No `train:index-gate-scope` manifest record exists in the store (find returned only the two car dirs + index.md + a review .md).
- Distinct dispatch (agent-id) subjects: 17. Total index rows: 65. No absolute paths / user dirs / secrets in the brief.

---

# REVIEW VERDICT: REJECT

**Document:** `docs/design/2026-07-23-ui-mockup-brief.md` at HEAD `3b04d45b07cefe26b9fce628fcc8e4268a1ea6d9`
**Source of truth:** `docs/design/2026-07-21-v0-yard-skeleton-design.md` (rev 5, APPROVED)
**Base verified:** HEAD matches the mandated SHA; worktree clean.

One Major forces REJECT. The brief's rule-fidelity is genuinely strong (see below); the failure is isolated to the "sample real data" paragraph making a provenance claim the store and the approved design both contradict. The fixes are cheap and the document is otherwise close.

## What is right (verified, not skimmed)

Every core rule traces to the approved design without drift:
- **Three-register closed set + most-severe-wins** (brief 22-26) = design §5.2 Registers + Rule 1. Verbatim register names. ✓
- **Position-primary / freshness-secondary + no-freshness-line-for-no-adapter** (brief 45-48) = design §5.2 Rule 2, including the "not yet read would be a lie" phrasing. ✓
- **Five lanes + v0 positions** (brief 28-43): trains/gates/dispatches live, freight dark, fuel bagged = design §5.2 registry paragraph. ✓ Fuel "data exists but not surfaced" and freight "no adapter yet" both faithful.
- **Honesty chrome** (brief 50-60): asOf, disconnect-keeps-last-good-marked, board-conditions strip, lane count ("registry declares 5 lanes"), discovery-state-by-name-verbatim all trace to §5.2/§6/§5.6 Rule 4. ✓
- **Yard inventory visible** (brief 36-37) = design §5.3 / §6 "loudly, never hidden." ✓
- **Verdict words verbatim** (brief 32-33) = design §5.3 Gates row + scar #557. ✓
- **Leakage:** none. No absolute paths, no operator-machine details, no secrets. ✓
- **Stranger test:** rail jargon is glossed inline (bagged, dark, shopped, coupled); paste section carries no repo-file dependency a stranger must resolve; the one "(#20)" sits inside a title string and needs no resolution. Reads cold. ✓ (length caveat in Notes)

## Findings

### UIB-1 — MAJOR — "sample real data (from the live store)" asserts store content that does not exist
Brief lines 62-64: *"Sample real data to mock with (from the live store): train `train:index-gate-scope` titled 'Scope the index staleness gate (#20)' carrying car `acc761f0add2b0af2` (...) and car `ac7d81bda8f23f2a6` (...)."*

The two **cars** are real store records. The **train** — `train:index-gate-scope`, its title, and the car-into-train membership — is NOT in the store. The approved design says so in its own words: §5.5 / Q3 ruling (design lines 294-299): *"the migrated records carry no manifests and render honestly in yard inventory ... until backfill manifests are written ... scheduled at the plan rung."* D16 places manifest records as designed-but-unbuilt. `find` confirms zero manifest records at HEAD.

So the brief presents, under an explicit provenance banner "(from the live store)", a manifest-derived train the design states is not yet written. This is a Law 1 confident-falsehood on the board's OWN provenance document (brief line 6: "This document is the PROVENANCE"), committed to a public repo — the exact class of harm the board is designed to prevent (rendering absent things as present). It directly contradicts the source-of-truth design §5.5/Q3.

Severity is Major not because a mockup would render wrong (it would not — a mockup SHOULD show a train), but because the provenance CLAIM is false and unmarked, and disclosed-but-wrong would not clear it — here it is not even disclosed.

**Fix (cheap):** mark the train grouping/title/membership as illustrative ("the manifest/train record is not yet landed — designed per D16, backfill is a plan-rung task; the two cars and the gate verdicts below ARE real store records"). Keep the genuinely-landed records labeled as such.

### UIB-2 — Minor — "design round 3: REJECT" is not a landed store record
Brief line 65 lists three design-round REJECTs as live-store sample. Only `round1` and `round2` exist as JSON artifact records the board reads. Round 3 (the rev-4 REJECT) exists only as `2026-07-23-design-v0-round3-REJECT.md` — no JSON. The board (design §5.3, reads `artifacts/**/*.json`) would render rounds 1-2 as gates, never round 3. Same provenance-overclaim family as UIB-1; fold into the same marker fix (only rounds 1-2 are landed gate records).

### UIB-3 — Minor — car state-word examples invite translation/inference the source forbids (#557 tension)
Brief lines 30-31 give car state words `rolling`, `at inspection`, `shopped x2 = rejected twice`, `coupled = merged`. None of these appear in the store or the fold's liveness vocabulary (design §5.3: `dispatched`/`overdue`/`returned`/`presumed-lost`) — `acc761f0`'s actual outcome is `done`, not "coupled". `coupled = merged` in particular implies a merge signal the v0 store does not carry (there is no merge field; the "merged" fact lives only in git, off-board). The gates section correctly says "verbatim"; the cars section, by offering metaphor translations, could steer the view car (Car 5) into re-inferring/translating store values — the exact move scar #557 (design §1, §5.3) forbids. (Softener: car/20 IS merged on `dev`, so "coupled" is true-in-world; the issue is vocabulary/derivability, not truth.) **Fix:** mark these as illustrative visual metaphors for the mockup, not literal store values, or align them to the verbatim-rendering rule.

### UIB-4 — Minor — the design-feedback loop names no landing site (vigilance-tier)
Brief lines 9-10: *"If a mockup fights a rule below, that conflict is DESIGN FEEDBACK to capture, not a rule to quietly break."* It says "capture" but names no destination. Per the never-drop rule, an instruction to capture with nowhere to put it is vigilance-tier. **Fix:** one sentence naming where it lands (issue #1 / an amendment block on the design doc).

### UIB-5 — Minor — "dispatches lane holding ~60 entries" conflates total records with folded dispatches
Brief line 67. The DISPATCHES lane per design §5.3 is the fold's output — dispatch-kind records folded to one liveness state per subject: **17** distinct dispatch subjects in the store, not ~60. The ~60/65 figure is the total index row count, which sweeps in the ~21 review-verdict records that belong to the GATES lane, not dispatches. Harmless for a mockup ("busy lane") but numerically off against the design's own lane semantics by ~3.5x. **Fix:** "~17 folded dispatches" (or describe the raw feed as ~65 records across dispatches+gates, and reserve ~60 for the record total, not the dispatches lane).

## Notes (not blocking)
- **DEMO banner** (brief line 57): the approved design does not establish a DEMO banner as a chrome element — the only "demo" reference (design line 64) is the gating-matrix row forbidding demo mode from *muting* truth surfaces. A DEMO banner is consistent with that honesty ethos (disclose demo data, do not hide it), so this is a faithful extension rather than a contradiction. Acceptable; flagging only because it is not literally in §5.2/§6.
- **Paste-section length:** 714 words (measured, lines 16-78) — ~19% over the ~600 guide, still within one dense page. Not substantially over; trim if a strict one-page paste is required.
- **"two live within the last hour"** (line 68): defensible — the two most recent records (`a4374d…` 12:23Z, `a663c067…` 11:52Z on 2026-07-23) fall within an hour of each other. "Live" reads loosely (both are `returned`), acceptable for a mockup seed.

## Constitution check (laws the document implicates)
- **Law 1 (unknown/absent render honestly; no confident falsehood):** VIOLATED by UIB-1/UIB-2 — sample claims store content that is not there. This is the REJECT.
- **Law 7 (stranger; no hardcoded/house jargon):** HONORED — rail jargon glossed, paste section self-contained, no unresolved repo references. Length is a soft note.
- **Scar #557 (render verbatim, never re-infer):** HONORED for gates; TENSIONED for cars (UIB-3).
- **North Star (docs true always; provenance):** the Major is the provenance surface asserting unbuilt data.
- **Normalisation / no-absolute-paths:** HONORED — clean.

Fast re-turn: all fixes are markers plus one count correction; no structural change to the excellent rule-fidelity core.

```starcar-artifact
outcome: REJECT
findings: UIB-1 (Major) the "sample real data (from the live store)" paragraph (brief lines 62-64) presents train:index-gate-scope, its title, and car-into-train membership as live-store content, but no manifest record exists at HEAD and the approved design section 5.5 / Q3 ruling (design lines 294-299, D16) states these manifests are not yet written (plan-rung backfill) - a Law 1 confident-falsehood on the board's own public provenance document; needs an illustrative marker separating the two real car records and the real gate verdicts from the not-yet-landed train scaffolding. UIB-2 (Minor) "design round 3: REJECT" is listed as live-store sample but only rounds 1-2 exist as JSON store records; round 3 is markdown-only, unreadable by the board. UIB-3 (Minor) car state-word examples (rolling, at inspection, shopped, coupled=merged) are rail-metaphor translations absent from the store/fold vocabulary and coupled=merged implies a merge signal v0 does not carry, inviting the #557 re-inference the gates section correctly forbids. UIB-4 (Minor) the design-feedback instruction (lines 9-10) names no landing site - vigilance-tier per never-drop. UIB-5 (Minor) "dispatches lane holding ~60 entries" conflates total records (65) with folded dispatch subjects (17 measured) per design section 5.3. Notes: DEMO banner not literally in the design but a faithful honesty extension; paste section 714 words, ~19 percent over the ~600 guide, still one dense page; no leakage (no absolute paths, user dirs, or secrets). Fidelity on the hard aesthetic law, five lanes, honesty chrome, yard inventory, and verbatim verdicts is verified correct.
abstract: Adversarial fidelity-and-audience review of the one-page UI mockup brief against the approved rev-5 yard skeleton design, at base 3b04d45. Rule fidelity is strong and verified; leakage clean; stranger test passes. REJECT on one Major: the "sample real data (from the live store)" paragraph asserts a train manifest as store content that the design itself says is not yet written, verified against the store (no manifest record exists; only design rounds 1-2 and the two cited cars are real landed records). Four Minors and three Notes accompany. All fixes are markers plus one count correction; the core is otherwise sound and a fast re-turn.
```