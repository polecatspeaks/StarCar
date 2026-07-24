<!-- starcar-integrity: sha256=1291689f0e650d6e00d9ee9ec91ae72c94d8407de0c429823e77f7f6d6050ab7 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# UI mockup brief delta round 2: APPROVE - Major re-verified resolved against the store; two sweep Minors raised

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Document review (adversarial delta, Opus, same reviewer fix-cycle)
Round: 2
Target: `docs/design/2026-07-23-ui-mockup-brief.md v2 at 0327a92`
Base reviewed: `0327a922b06833ef9ed0e74fb3bc5e7cc07859ad`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

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
| Base commit the reviewer read (**the lookup key**) | `0327a922b06833ef9ed0e74fb3bc5e7cc07859ad` |
| Entire checkpoint | `6796f162cfb1` |
| Dispatch, the locator within the session | `acc25b07aa67ecf2c` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 0327a922b06833ef9ed0e74fb3bc5e7cc07859ad
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All five findings resolved and store re-verified. I found two minor regressions the v2 edit introduced. Let me state the delta verdict.

# DELTA RE-REVIEW round 2: APPROVE

**Document:** `docs/design/2026-07-23-ui-mockup-brief.md` (v2) at `0327a922b06833ef9ed0e74fb3bc5e7cc07859ad`
**Base verified:** fetched `origin/dev`, checked out `0327a92`; `git log -1` confirms HEAD = `0327a92…`. Worktree was correctly moved off the stale `3b04d45`.
**Store re-verified at 0327a92:** 67 total JSON records, 18 distinct dispatch subjects (grew +2/+1 since round 1). `acc761f0` outcome `done` ✓, `ac7d81bd` outcome `APPROVE` ✓, design-v0 JSON records still only rounds 1-2 ✓.

The Major is cleared and all four Minors are resolved. No Major remains, so this is an APPROVE. Two small regressions the v2 edit introduced are raised as Minors for a sweep; neither blocks.

## Round-1 findings walked against v2

- **UIB-1 (Major) — RESOLVED.** The sample data is now split into two honestly-labeled kinds (v2 lines 71-84). **REAL, from the live store:** car `acc761f0` (outcome `done`, no longer the misleading "coupled"), car `ac7d81bd` (outcome `APPROVE`), gate rounds 1 and 2 only, and the dispatches lane "folding to ~17 dispatch entries from ~65 total store records." **ILLUSTRATIVE, not yet in the store:** the train grouping, explicitly marked "train-manifest records are designed and not yet written," with the honest day-one rendering stated ("the real board renders these cars in yard inventory and a thin trains lane"). Every REAL claim re-verified true at 0327a92 (outcomes match; rounds 1-2 are JSON records; ~17 folded ≈ actual 18; the two cars returned 11:05:42Z and 11:15:41Z, "within the last hour of each other" ✓). This directly satisfies the design §5.5/Q3 truth that these manifests are unbuilt. The Law 1 provenance falsehood is gone.

- **UIB-2 (Minor) — RESOLVED.** Round 3 is dropped; only "design round 1: REJECT and design round 2: REJECT" are claimed as live-store gate records — matching the two JSON records that exist.

- **UIB-3 (Minor) — RESOLVED.** v2 lines 36-40 mark the car words ILLUSTRATIVE and state the verbatim rule in the same breath: "the real board renders whatever state word its data source provides, VERBATIM, never a translation of it. Design the shape of a car chip, not a fixed word list." The misleading "coupled = merged" gloss (which implied a merge signal the store lacks) was also removed.

- **UIB-4 (Minor) — RESOLVED.** v2 lines 13-16 name the landing site: "it LANDS as a comment on issue #1 (or, if it changes a contract, an amendment block on the design doc) - never captured nowhere."

- **UIB-5 (Minor) — RESOLVED.** v2 line 76-77 corrects the count to "~17 dispatch entries from ~65 total store records" (actual now 18/67; the `~` approximations hold).

## Additional checks

- **Status/State header:** `Status: Open` (line 3) conforms to the repo convention (the source design doc uses `Status: Open`; verdicts use `Status: Done`). `State:` is the descriptive field, same pattern as the design doc. PASS.
- **Review-record citation:** the brief cites `artifacts/reviews/2026-07-23-ui-brief-round1-REJECT.md` (lines 6, 12). I opened it: it exists, its header reads "review round 1: REJECT - the brief presented an unbuilt train manifest as live-store data (Law 1 on a provenance doc)," base `3b04d45`, Verdict REJECT — matching my round-1 verdict, and the brief's "round 1 REJECT (1 Major, 4 Minor)" matches (UIB-1 Major + UIB-2/3/4/5 Minor). PASS.
- **Leakage:** none. No absolute paths, user dirs, or secrets. PASS.

## New findings (Minor, non-blocking)

- **UIB2-1 (Minor) — stale footer.** Line 98 still reads `*Review record: pending round 1.*`, contradicting the updated header (lines 5-8, "round 1 REJECT folded"). The v2 edit trued the header but left the footer — a living-document staleness (a lying canary two lines apart from the authoritative record). Fix: delete or update the footer. Not Major: the header is authoritative and correct, and the stale line concerns review status, not the board's data or provenance.

- **UIB2-2 (Minor) — house-jargon in the paste zone.** The paste section (defined at line 20 as "paste everything below this line into the design tool") now contains internal finding-ID markers at lines 71-72: "labeled honestly `[UIB-1, UIB-2, UIB-5, folded]`:". A zero-context external tool cannot resolve `[UIB-1…]`; it is provenance noise leaked into the delivered artifact, undercutting the brief's own "zero repo context" claim. The other fold marker (`[UIB-4, folded]`, line 16) is correctly kept ABOVE the paste boundary — this one should move there too. Fix: relocate the `[UIB-…]` markers out of the paste section. Not Major: cosmetic, the mockup is unaffected.

## Notes (not findings)
- **Paste-section length** grew to 830 words (lines 22-94), from 714 in v1 — ~38% over the ~600 guide, roughly 1.5 pages. This is the cost of the honest real/illustrative split that fixed UIB-1, an acceptable trade; trim (the "Mock both states" elaboration and the UIB markers) if a strict one-page paste is wanted.
- The real/illustrative LABELS themselves read cleanly for a stranger — a zero-context designer gets actionable direction (mock a populated track and an honest thin track). The stranger test passes on the substance; only the bracket markers (UIB2-2) are noise.

## Constitution check
- **Law 1 (no confident falsehood; unknown/absent honest):** now HONORED — the provenance claim is split into verified-real and marked-illustrative; the round-1 violation is gone.
- **Scar #557 (verbatim, never re-infer):** HONORED — the verbatim rule is now stated explicitly alongside the illustrative car words.
- **Law 7 (stranger / no house jargon):** substantially HONORED; one minor blemish (UIB2-2, finding IDs in the paste zone).
- **Living documents (invalidating commit trues the doc):** one miss — the stale footer (UIB2-1).
- **Normalisation / leakage:** HONORED — clean.

The fix is sound; the Major is genuinely resolved and re-verified against the store, not just asserted. The two Minors are trivial sweeps that do not block the merge.

```starcar-artifact
outcome: APPROVE
findings: All five round-1 findings resolved and re-verified at 0327a92. UIB-1 (Major) RESOLVED - sample data split into REAL (car acc761f0 outcome done, car ac7d81bd outcome APPROVE, gate rounds 1-2, ~17 folded from ~65 records, all verified true against the store) and ILLUSTRATIVE (the train grouping, explicitly marked designed-and-not-yet-written with honest day-one yard-inventory rendering); the Law 1 provenance falsehood is gone. UIB-2 RESOLVED - round 3 dropped, only rounds 1-2 claimed as store gate records. UIB-3 RESOLVED - car state words marked illustrative with the verbatim-rendering rule stated in the same breath and the misleading coupled-equals-merged gloss removed. UIB-4 RESOLVED - feedback now lands as an issue #1 comment or a design-doc amendment block. UIB-5 RESOLVED - dispatches count corrected to ~17 folded from ~65 records. Round-1 verdict file cited correctly and its header matches. No leakage. Two new Minor regressions from the v2 edit, non-blocking: UIB2-1 the footer line still reads Review record pending round 1, stale against the updated header (living-document trueness); UIB2-2 internal finding-ID markers UIB-1 UIB-2 UIB-5 folded were left inside the paste-into-the-tool section where a zero-context tool cannot resolve them (they belong above the paste boundary like the UIB-4 marker). Note: paste section grew to 830 words, about 38 percent over the 600 guide, an acceptable cost of the honest split; trim if strict one-page is wanted.
abstract: Delta re-review round 2 scoped to verify-the-fix on the UI mockup brief v2 at commit 0327a92, base verified after moving off the stale 3b04d45. All five round-1 findings including the Major are resolved and independently re-verified against the live store, not merely asserted. Verdict APPROVE. Two trivial Minor sweep-items introduced by the edit (a stale review-status footer and internal finding-ID markers leaked into the paste zone) are raised but do not block, since any Major is the only REJECT trigger and none remains. Status header, verdict citation, and leakage all pass.
```