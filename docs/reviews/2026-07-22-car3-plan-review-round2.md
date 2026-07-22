<!-- starcar-integrity: sha256=35e6eef9f1aca65bfa6a8f72e018a87a199d7a9c4738899fd88709546626ef69 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car 3 plan review, round 2 (delta): APPROVE - 11/11 closed, both proven Majors re-verified

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Plan delta review (same adversary)
Round: 2
Target: `docs/plans/2026-07-22-harness-car3-plan.md rev 2`
Base reviewed: `fa18a8574e126d8e3f2264a3f48ff441353e1a0a`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `ac32f4e635f031ebe`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `fa18a8574e126d8e3f2264a3f48ff441353e1a0a` |
| Entire checkpoint | `5c50e4a9a0e3` |
| Dispatch, the locator within the session | `ac32f4e635f031ebe` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain fa18a8574e126d8e3f2264a3f48ff441353e1a0a
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Clean tree, base intact at `fa18a857`, all fixtures removed. Here is the delta verdict.

---

**VERDICT: APPROVE.** Round-1 was 5 Major, 4 Minor, 2 Notes; rev 2 closes all 11 by mechanism, with the two empirically-proven Majors (M1, M2) re-verified by execution. Zero new findings. Convergence is clean (findings 11 to 0, none relocated, no fix-induced defects). Car 3 clears for dispatch on Sonnet.

## The 11-ID walk (Present / Absent / DRIFTED)

| ID | Round-1 finding | Rev-2 disposition | My re-verification | Status |
|---|---|---|---|---|
| **C3R1-M1** | R7 record schema-invalid (missing schema/session_id/findings) | R7v2: complete field set, `session_id: pre-harness-migration`, fence-parse + fallback findings | **RAN** both rev-2 shapes through the landed `Test-StarcarArtifact`: **Valid=True** (fence-parse) and **Valid=True** (fallback), where round 1 gave Valid=False | **ABSENT (closed)** |
| **C3R1-M2** | R9 `artifacts` default + `-Recurse` chokes on headerless `index.md` (proven exit 1) | R9v2: default `artifacts/reviews`, recursion DROPPED, anti-trap pinned in C.1 Step 1 | **RAN** the round-1 fixture (reviews/good.md + root index.md): flat default **verified good.md, exit 0, never globbed index.md**. C.1 Step 1 (plan:139-141) pins the assertion "exits 0 with index.md present at the fixture ROOT" | **ABSENT (closed)** |
| **C3R1-M3** | Contract flips deferred out of the invalidating commits | Ledger flip → C.1 Files+commit (plan:125-128, 155-157); matrix flip → C.2 Files+Ledger (plan:192-196); C.4 slimmed (plan:216-218); rev-1 contradiction explicitly resolved (plan:195-196) | Walked: C.1 is the commit that births the index instance and now trues state-ledger in-commit; C.2 arms the gate and now trues gating-matrix in-commit. Same-commit law honored. | **ABSENT (closed)** |
| **C3R1-M4** | "Merge cleanly" false comfort; merged HEAD fails the staleness gate | Handback 2 (plan:238-245): MANDATORY regenerate-and-commit over the merged store before the ping; rollback via `git revert` stated | Producer never touches index.md (re-confirmed `Produce-Artifact.ps1:246-256` commits only its own path), so regenerate-over-merged-store is the correct fix. Ping now gated on the reconcile (plan:249). | **ABSENT (closed)** |
| **C3R1-M5** | Future verdicts could land unverified in a resurrected `docs/reviews/` | R10 (plan:97-106): landing convention repoints to `artifacts/reviews/`, `-Out` + verifier default + setup.md row all one location, in the migration commit | Two-reading ambiguity resolved by ruling: one location, one owner (Law 6). Future verdicts land inside the verifier's default coverage. | **ABSENT (closed)** |
| **C3R1-m1** | `:24` miscited for the default | `:27` cited (plan:89) | Confirmed `Verify-Verdict.ps1:27` is `[string]$ReviewsDir = 'docs/reviews'` at this base | **ABSENT (closed)** |
| **C3R1-m2** | Header parse ambiguity, vocabulary pollution (22 rich-string discoveries) | R7v2: fence `outcome` first; fallback = LEADING TOKEN of `**Verdict:**` | Fence outcomes are reviewer-written clean values; all 3 fence-less fallbacks resolve to `REJECT`, which **is in** `schema/vocab/outcomes.json`. No discovery noise. | **ABSENT (closed)** |
| **C3R1-m3** | README edit risked premature board-consumption claim | Exact replacement text in C.1 Files (plan:120-123) | **Sentence-checked**: "the dispatch harness's store lands in this repo" (TRUE — `artifacts/` holds records) → "the board's consumption of it is #1's train" (TRUE — spec:4 names #1 as board-consumes-store). No premature claim. | **ABSENT (closed)** |
| **C3R1-m4** | Ubuntu suite portability unproven; scope-creep risk | Scope guard in C.2 item 4 (plan:178-183): honest-stop on any ubuntu test failure, never expand C.2 | Honest-stop is the success outcome; the fix becomes a rider decision. Matches the honest-stop doctrine. | **ABSENT (closed)** |
| **C3R1-n1** | isAsync raw evidence gitignored | Probe 6 entry states the reproduction method (plan:222-224) | The committed `post-task-probe.sh` hook regenerates the observation on any dispatch; raw log stays gitignored but the method is committed — correct form for a measurement probe. | **ABSENT (closed)** |
| **C3R1-n2** | Integrity canonicalisation unspecified; bogus hash would pass field check | R7v2 names the producer's canonicalisation; C.1 asserts the hash **round-trips**, not field-presence (plan:73-76, 135-137) | The assertion now targets the exact defect I raised (a shape can pass presence yet carry a bogus hash). Method-sameness with `Produce-Artifact.ps1:229` is named by function. | **ABSENT (closed)** |

## New-finding scan (premise attack on rev-2's own moves)

- **`session_id: pre-harness-migration` shared across 23 records** — harmless: the schema requires only a string; the detector groups by `subject`, never `session_id`. No collision. No finding.
- **Slug `subject` on `kind: returned` records** — disclosed as a MARKED deviation (plan:59-61); validates; the phantom-returned-lane effect is rendering (#1), out of scope. No finding.
- **`body_file` field ordering vs `Produce-Artifact`'s record** — integrity is each record's own body hash; "same canonicalisation" is method-sameness, not field-set identity, so the round-trip is self-consistent per record. No finding.

None found. No fix in rev 2 introduced a defect elsewhere — the sharpest swirl trigger is **not** present.

## Convergence ruling (per review calibration)

Round 1: 5 Major / 4 Minor / 2 Notes (11). Round 2: **0 new findings; 11/11 closed, 2 of them re-proven by execution.** Testing the three swirl-and-churn triggers: (a) Major count declined 5 to 0 — not flat; (b) no finding clusters in a repeated section — there are no repeat findings; (c) no round-2 finding is a defect a round-1 fix created. Zero of three triggers fired. This is textbook convergence — findings shrank and closed by mechanism, the opposite of the swirl the calibration guards against. No escalation warranted; no further round warranted.

APPROVE (clean, not APPROVE-WITH-REBASE-LIST): every finding is folded into the plan text and closed; there is no residual list to carry into implementation.

## Constitution check (this delta)

- **North Star / Living Contracts (same-commit):** M3 folded the ledger flip into C.1 and the matrix flip into C.2 — the commits that invalidate them. Honored.
- **MERGE NORTH STAR:** M4's mandatory regenerate-before-ping means the plan now describes a path to a good known working state. Honored.
- **Match instrument to artifact / "prose is wrong for formats":** M1's record shape is now validated by the executable schema (Valid=True, run by me), and n2 asserts the integrity round-trip rather than field presence. The format is held by the format's instrument. Honored.
- **Law 1 (no confident falsehood):** M2 makes C.1's exit-0 claim true (verified); m3's README text is sentence-checked truthful; n1 states a reproducible method. Honored.
- **Law 6 (one owner):** R10 collapses the verdict-landing location to one place. Honored.
- **Red-first:** C.1's anti-trap red re-derives the round-1 reviewer's own observed failure before fixing; C.3's measurement non-vacuity is the right instrument. Honored.
- **Blameless-precise:** rev 2 attributes M1/M2 to reviewer execution and folds each finding by ID with its exact remedy. Honored (one minor over-attribution noted below, not a finding).

*Attribution precision note (not a finding):* plan:243 says "the round-1 reviewer verified the mv-reversal restores everything byte-preserved." I ruled it sound by git semantics (git mv = add+delete of identical blobs), reasoned rather than executed a revert. The conclusion is correct; the word "verified" is doing light duty. No impact on soundness.

```starcar-artifact
outcome: APPROVE
findings: Delta re-review of Car 3 plan rev 2 at base fa18a857, tree clean, all fixtures in TEMP and removed. All 11 round-1 findings (5 Major, 4 Minor, 2 Notes) walk ABSENT (closed). The two empirically-proven Majors re-verified by execution: C3R1-M1, R7v2's rev-2 record shape (schema const, session_id pre-harness-migration sentinel, findings via fence-parse or fallback) run through the landed Test-StarcarArtifact returns Valid=True on both parse paths where round 1 returned False; C3R1-M2, R9v2's flat artifacts/reviews default with recursion dropped, run against the round-1 fixture, verifies the body and exits 0 and never globs the root index.md. Fence measurement confirmed by grep: exactly 20 of 23 verdicts carry a starcar-artifact fence, the 3 fence-less are the early design reviews whose leading-token fallback all resolve to REJECT which is in the outcomes vocab, so no discovery noise. M3 contract flips now land in their invalidating commits (ledger in C.1, matrix in C.2, C.4 slimmed, rev-1 contradiction resolved). M4 Handback 2 is now mandatory regenerate-and-commit over the merged store before the ping with rollback stated, and the producer never touches index.md so the fix is correct. M5 R10 repoints the future-verdict landing convention to artifacts/reviews as one location one owner. Minors m1 to m4 and notes n1 n2 all closed and re-verified: :27 citation correct, leading-token fallback vocabulary-clean, README exact text sentence-checked truthful (store exists in-repo, board consumption deferred to #1), ubuntu honest-stop scope guard, probe 6 reproduction method stated, integrity round-trip asserted not field-presence. Zero new findings. No rev-2 fix introduced a defect elsewhere. Convergence clean, zero of three swirl triggers fired.
abstract: Round-2 delta APPROVE of the dispatch-harness Car 3 plan. All eleven round-1 findings closed by mechanism; the two proven Majors re-verified by running the landed schema validator (Valid=True) and the anti-trap fixture (exit 0, index.md never globbed). Convergence is textbook: findings 11 to 0, none relocated, no fix-induced defects. Clean APPROVE, not rebase-list. Car 3 clears for dispatch on Sonnet.
```