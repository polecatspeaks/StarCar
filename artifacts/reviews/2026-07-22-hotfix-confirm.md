<!-- starcar-integrity: sha256=1b7a4dcdd8882c4f9ef49b16f3848ee98ece692785c9db422e653b8f89a1c1ce covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Conductor hotfix CONFIRMED - the entire-CLI guard; exception boundary prescribed

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Post-hoc adversarial confirmation (binding compensating control)
Round: 1
Target: `dev at 4c60434 (conductor-authored hotfix)`
Base reviewed: `4c60434205247c6e90950dfb9716bb6e575b170e`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: CONFIRM**

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
| Base commit the reviewer read (**the lookup key**) | `4c60434205247c6e90950dfb9716bb6e575b170e` |
| Entire checkpoint | `f598e4a6e613` |
| Dispatch, the locator within the session | `a6940e01dae1edf78` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 4c60434205247c6e90950dfb9716bb6e575b170e
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: CONFIRM

Base `4c60434` verified (hotfix, above merge `8c983a1`), worktree clean, read-only. The red was real and pinned red-first, the fix is minimal and non-regressing, CI is green both directions, and the two rulings resolve in the conductor's favor with one non-blocking recommendation. No findings block.

## The four verification points

**1. The red was real and pinned — CONFIRMED.**
- I reproduced it: extracted the pre-fix `Land-Verdict.ps1` (from `4c60434^`), confirmed it calls `entire` unguarded at line 222 (no `Get-Command`), ran it in a scratch repo with every entire-bearing dir stripped from a child PATH, and got the exact CI error: **"The term 'entire' is not recognized as a name of a cmdlet, function, script file, or executable program."** Under `ErrorActionPreference = 'Stop'` that terminated the run — **no landed file was produced** (verified `out.md` absent), so pre-fix this was a hard landing failure, not a cosmetic warning.
- The new pin (`LandVerdictRider.Tests.ps1`, "lands WITHOUT the entire CLI on PATH") is **non-vacuous by construction**: it strips entire from a child PATH and asserts entire is genuinely unresolvable (`exit 9` if it still resolves) *before* asserting the landing — so a machine that happens to lack entire for another reason cannot produce a false pass. Rider suite 5/5.
- CI both directions, re-derived via `gh`: merge `8c983a1` check "verify" = **failure**; hotfix `4c60434` check "verify" = **success**. The fix genuinely turned the red green at CI, not just locally.
- The guard structure is minimal and non-regressing: exactly one `entire checkpoint explain` line was removed and re-added inside the `if (Get-Command entire...)` branch, so the **entire-present path is byte-identical to pre-hotfix**; only the `else` note branch is new. Existing landed verdicts still verify (21/21), confirming no integrity regression.

**2. Ruling on the guard degradation — ACCEPTABLE; one non-blocking recommendation.** Omitting the checkpoint provenance row on entire-less machines is the correct degradation and does **not** block CONFIRM:
- It is **Law-1-compliant**: the row is rendered **blank (absent), never false** — the file asserts no checkpoint it cannot back. Blank over false is the mandated direction.
- The **citation stays followable**: the landed file still carries the base commit explicitly labeled "the lookup key," and the unconditional "Follow the citation" block still prints `entire checkpoint explain $Base`. The checkpoint id is a pre-resolved convenience cache, not the lookup key; a reader on an equipped machine resolves it from the base commit regardless. The trust chain (base commit to checkpoint to independent copy, spec §3.6) is intact in the file.
- **Law 5** is satisfied for the actor who can act: the operator running the tool sees the loud console note and can install entire or re-land from an equipped machine.

Non-blocking recommendation (a NOTE for a tracked follow-up, not a Major): the console note is ephemeral, but the **durable landed file carries no in-file marker** of the omission, so a future reader cannot distinguish "landed on an entire-less machine" from "checkpoint resolution failed" or "never populated." Since the public showcase's trust model leans on the checkpoint pointer being visibly present-or-explained, a one-line in-file note in the provenance section ("checkpoint row omitted: landed without the entire CLI; resolve via the base-commit command below") would apply Law 5's loud-degradation to the durable surface, not just the console. This is an improvement worth a rider, not a defect that blocks the hotfix — the file is true and the citation is followable without it.

**3. Suites at `4c60434` — CONFIRMED, re-derived under pwsh 7.6.3.** `scripts/tests` **74/74** (73 + the new pin), `scripts/probes` **8/8**, `Verify-Verdict` **exit 0, 21 files verified** (the +2 over round 2 are my own round-1 and round-2 review verdicts, landed to `docs/reviews/` and hash-clean). CI run **29939404919** = SUCCESS, `headSha` matches `4c60434` exactly, status completed — a terminal state re-derived, not a mid-flight sample.

**4. Ruling on the process deviation — ACCEPTABLE for this narrow class; recommend codifying the boundary, not tightening to forbid.** A conductor-authored code fix with post-hoc review is defensible here because every load-bearing guardrail held:
- **Red-first was preserved** — the invariant that must never be skipped. The conductor wrote the failing pin, reproduced the exact CI error locally, then the guard. I independently verified the red is real and the pin non-vacuous.
- **Small, mechanical, coverage-class** — an 11-line environment-coupling guard, no design or structural change (rewrite-vs-extend: this is a rider, correctly).
- **CI-blocking on the working branch** — leaving dev red blocks all downstream work and violates "the session does not start editing on top of an unexamined red." The fastest correct path is legitimate.
- **Disclosed, not slipped** — the commit message names it a deviation, names this review as the compensating control, and states the rework-forward path on OBJECT. That is the "disagree loudly / record the mess" norm honored.
- **Landed on dev, never main** — topology intact; it faces the whole-branch gate when dev PRs to main.
- **The compensating control is real and binding** — this adversarial review ran the suites, reproduced the red, and checked CI both directions; it is not a rubber stamp.

I would **not** tighten the rule to forbid conductor hotfixes. I recommend the shop **codify the exception's boundary** (durable artifact, per the anti-gaming guard) so it does not erode into "the conductor writes whatever is convenient": conductor-authored fixes are permissible only when (a) CI-blocking or equivalently urgent, (b) mechanical/coverage-class, never structural, (c) red-first with a non-vacuous pin, (d) disclosed in-commit with the compensating review named, (e) on a working branch with mandatory binding post-hoc adversarial review. This train exhibited all five; writing them down converts a sound one-off judgment into a rule.

Bonus verification (Handback #3, now landed): the live-fire producer commits in this push (`3350974`, `d786ab8`, `f183508`, `cef82b9`) each contain **exactly one file** — their own `artifacts/&lt;subject&gt;/&lt;kind&gt;-&lt;compact-at&gt;.json` — with pathspec-scoped `harness:` commit messages. The entanglement guard held in the real repo, closing the round-1 Handback observation where it matters.

```starcar-artifact
outcome: CONFIRM
findings: Post-merge conductor hotfix confirmed, zero blocking findings. The red was real: I reproduced the pre-fix failure (the term entire is not recognized) by running the unguarded pre-fix Land-Verdict with entire stripped from a child PATH, and it aborted the landing entirely under ErrorActionPreference Stop (no landed file). The new pin is non-vacuous - it asserts entire is genuinely unresolvable (exit 9 if not) before asserting the landing. CI re-derived both directions: merge 8c983a1 verify concluded failure, hotfix 4c60434 verify concluded success (run 29939404919, headSha matches). The guard is minimal and non-regressing: the entire-present path is byte-identical to pre-hotfix (only the else note branch is new), and existing verdicts still verify 21 of 21. Suites at HEAD: tests 74/74, probes 8/8, Verify-Verdict exit 0 with 21 files. Ruling on the degradation: acceptable - the checkpoint row renders blank not false (Law 1), the base commit remains the labeled lookup key with the resolve command in-file so the citation stays followable, and the console note satisfies Law 5 for the operator; non-blocking recommendation to add an in-file marker so the durable artifact distinguishes landed-without-entire from resolution-failed. Ruling on the process deviation: acceptable for this narrow class because red-first was preserved and the fix is small, mechanical, CI-blocking, disclosed, landed on a working branch, and gated by this binding review; recommend codifying the five-part exception boundary rather than forbidding conductor hotfixes. Bonus: the live-fire producer commits are each scoped to exactly one record path, closing the round-1 entanglement Handback item in the real repo.
abstract: CONFIRM the conductor-authored entire-CLI guard. The CI red on the merge commit was genuine and I reproduced it locally; the fix is a three-line Get-Command guard plus a non-vacuous red-first pin that reproduces the exact CI error, and CI on the hotfix SHA concluded success while the merge SHA concluded failure. The entire-present path is unchanged, no integrity regressed, and suites read 74 tests, 8 probes, 21 verdicts green. Omitting the checkpoint row on entire-less machines is acceptable degradation - blank not false, still followable via the base commit - with a non-blocking recommendation to add a durable in-file marker. The conductor-hotfix-with-post-hoc-review deviation is acceptable for this CI-blocking mechanical class because red-first held and the review is binding; I recommend writing the exception boundary into the rules rather than tightening to forbid it. Worktree stayed read-only and clean throughout; all reproduction ran in isolated scratch directories.
```