<!-- starcar-integrity: sha256=1f2a5982636186b1dee98fbb1ee9e4200027bc3a568464884aeb3971136f3605 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car process-42 delta re-review - round 3 (APPROVE, converged)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial delta re-review, whole-train gate
Round: 3
Target: `commit 45588a2 on car/process-42; series base 5ba0602, rounds 1-3`
Base reviewed: `45588a2afb270ee43bb28407161a639e7eeb1362`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a67cb0075007e7753`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `45588a2afb270ee43bb28407161a639e7eeb1362` |

| Dispatch, the locator within the session | `a67cb0075007e7753` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 45588a2afb270ee43bb28407161a639e7eeb1362
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Shared checkout on `dev`, clean, untouched.

---

# DELTA RE-REVIEW ROUND 3 (FINAL) — VERDICT: **APPROVE**

**0 Major, 0 Minor.** Subject `45588a2afb270ee43bb28407161a639e7eeb1362` (delta on r2 HEAD `83cd377`, issue #42) · **Base verified FIRST:** worktree at `45588a2`, tree clean, delta touches **exactly the two claimed files**; `ci.yml` and `docs/setup.md` confirmed **untouched since r2** (`git diff --name-only` returns 0 for both). No injection residue anywhere in tree or diff.

MAJOR-3 is fixed, and I watched **both layers of the remedy fire**. Every claim the car made about PowerShell semantics is true — I probed each one rather than accepting it.

## Observed counts (mine, at `45588a2`, detached worktree)

| Suite | Observed | Expectation |
|---|---|---|
| `scripts/tests` | **194 passed / 0 failed / 1 skipped, total 195** | Matches derived detached expectation. 192 → 195 = +3. Skip is the pre-existing `#50` detached guard-runner skip. |
| gate alone | **13 / 13** | 10 + 3 synthetic |
| `scripts/probes` | **24 / 24, 0 failed** | unchanged |
| `scripts/store-checks` | **178 / 178, 0 failed** | unchanged |

Car's "195/195 attached" is consistent with my 194/0/1 detached — the delta is exactly the detached-only skip.

## MAJOR-3 — CLOSED, proven in three directions

| Injection | r2 result | r3 result (mine) |
|---|---|---|
| Uncited extensionless `Dockerfile` | **10/10 silent green** | **12/13 — `Expected $null or empty, but got 'Dockerfile'`** |
| Cited extensionless `Dockerfile` | — | **13/13 green** (no false positive) |
| **Sentinel path** (`''` removed from checked set) | — | **12/13 — `extension(s) [(no extension)] appeared in the post-boundary corpus ... do not leave it silent, but got 1`** |

The third is the one that matters most: it is the *exact* r2 defect scenario, and the `(no extension)` sentinel renders readably instead of joining away to nothing. **Both layers of defence are now watched firing** — the direct citation check (because `''` joined `$CodeExtensions`) and the closed-set guard behind it. Reverted byte-identical (`cmp` YES, `Dockerfile` removed, porcelain empty).

*The brief's "car observed 9/10" reconciles cleanly: the commit message shows that was a mid-fix reading at 10 tests, before the synthetic Describe existed. My 12/13 is the final commit. No discrepancy.*

## The policy decision — ADJUDICATED: correct rule, accurately described

**Extensionless files belong in the CHECKED set, and the car's reasoning is right.** The distinction it draws is the load-bearing one: `.json`/`.md` are exempt for *format* reasons (JSON cannot hold a comment without mutating the artifact under test) or *ownership* reasons (DocPolicy owns docs). Extensionless files share neither property — the class is defined by naming convention, not format, and its real members (`Dockerfile`, `Makefile`, `CODEOWNERS`, shebang scripts) are `#`-comment-capable, exactly as much as a `.sh`.

**The failure-direction argument is the decisive one and the car got it right.** Checking by default means a genuinely comment-incapable extensionless file produces a *loud named violator*. Exempting `''` would produce a *silent pass for every Dockerfile forever* — reproducing this very defect one layer up. So **path-level, never extension-level** is correct: a path exemption is bounded to one artifact; an extension exemption is unbounded over all future files.

**Accurate to what the code does?** Verified: `$CodeExtensions` includes `''` at `:205`; my uncited-Dockerfile injection reds. The disclosed edge does **not** claim a path-exemption mechanism exists — it says one "would need" to be built "if one ever appears ... None exists today; calibrate then." That is honest and NIRTS-correct, not an overstatement.

**Probe claim verified:** no post-boundary extensionless file exists today. I derived the observed set independently: `.go .js .json .md .mjs .ps1 .sh` — all covered.

## The mechanism fix and the self-found fix — both verified

- **Assertion on `.Count` with sentinel** (`:277-282`): correct, and the sentinel is proven by fault injection above.
- **`Get-UnaccountedExtensions` extracted, and the synthetic tests call the PRODUCTION function** — my MIN-1 class is honored. Grep confirms **one definition each** of all five helpers, and all **7 call sites** wrapped with `@()`.
- **Array-collapse claim — PROBED TRUE:** `function F1 { return @('') }; $r = F1` yields **`String`, `IsArray = False`**; a zero-item return yields **`NULL`**. The `@()` wrapping is genuinely load-bearing, not decoration. The car's stated probe matches mine exactly.
- **`Mandatory` removal — PROBED TRUE:** `[Parameter(Mandatory)][string[]]` rejects an empty-string element verbatim — *"Cannot bind argument to parameter 'X' because it is an empty string."* Removing it was **necessary**, not a loosening of convenience, and it is safe: both `Get-AddedCodeFiles` call sites (`:227-228`, `:364-365`) still pass `-CodeExtensions`, and an omission would red the non-vacuity test loudly rather than pass silently.

## CLAUDE.md — Law 1 concern resolved

My r2 finding was that doctrine asserted completeness the guard did not deliver. It now states exactly what the guard does, records the round-3 correction with my own measurement quoted accurately ("an uncited extensionless Dockerfile passed 10/10 green"), and says outright that the sentence "and the test header were both corrected to state exactly what the guard now delivers rather than restating the round-2 overclaim." **I re-tested every claim in the new text against the code; no overstatement remains.**

## Forward observations (not findings, recorded so nobody is surprised)

1. **Dotfiles get their own "extension":** `[Path]::GetExtension('.gitignore')` returns `.gitignore` (probed; `.env` likewise). A post-boundary `.gitignore`/`.dockerignore`/`.editorconfig` will **red the closed-set test naming it**. That is the design working — loud, named, actionable, one line to resolve — not a wolf-cry, and the same behaviour as `.py`. None exist post-boundary today.
2. The second synthetic test pins the *old* buggy idiom's behaviour as documentation of the class. Unusual but deliberate, commented, and paired with the fixed idiom in the same `It`.
3. A pre-boundary file deleted and re-added is not flagged (two-endpoint diff sees it in both). Correct under NO BACKFILL, and consistent with the `board/board.go` test's own comment.

## Convergence — I hold the series

**r1: 2 Major, 4 Minor, 1 Note → r2: 1 Major (fix-created), 0 Minor → r3: 0 Major, 0 Minor.**

Monotonic decline to zero. No finding recurred; no r1 or r2 fix regressed (I re-verified `ci.yml` and `setup.md` untouched, and the r2-fixed items still green). My r2 boundary was: *a new Major inside extension coverage escalates, never a round 4.* **That boundary was not crossed — round 3 produced no Major at all**, so the escalation clause does not fire and I do not invoke it. **This is convergence, and the series is closed.**

The three rounds each caught a genuinely different failure class — wiring, coverage, assertion shape — which is a gate doing its job, not churn. All four of my r1 Minors and the Note remain closed.

## MERGEABLE: **YES** from `45588a2`

My APPROVE is the whole-train gate for this car. The sibling docs car is a separate gate and I make no claim about it.

## The CI boundary, restated honestly

**Real CI green is still NOT observed and could not be: `45588a2` is on no remote branch** — CI has never run on it. What is proven is the CI *shape*, by my own r2 clone simulations (depth-1 → named boundary failure; full clone → green) plus the `fetch-depth: 0` wiring I re-confirmed untouched. **`fetch-depth: 0` changes checkout for every leg of the `windows-latest`/`ubuntu-latest` matrix, so the first real run is the one that matters and the conductor must watch it to a terminal state post-merge.** CLAUDE.md and the commit message both decline to claim otherwise, which is the correct posture.

## Constitution check

- **Law 1 (Truth)** — **HONORED.** The r2 overclaim is corrected on both surfaces; every claim in the new text tested against the code. Unobserved CI green still explicitly not claimed.
- **Law 4 (Nothing Silently Lost)** — **HONORED.** The r2 violation (a computed unaccounted set discarded by the assertion shape) is closed; I watched the sentinel path fire.
- **Law 6 (One Truth)** — **HONORED.** One definition of each helper; synthetic tests bind to the production function.
- **Law 3 (Actionability)** — **HONORED.** Both failure messages name the offender and the remedy; `(no extension)` is legible where an empty string was not.
- **Law 5 (Self-Knowledge)** — **HONORED.** The synthetic Describe exists precisely because the real corpus cannot exercise that branch — the gate knows what it is not testing and says so.
- **Law 7 (The Stranger)** — **HONORED.** Closed set with stated reasons; no silent taxonomy hole remains.
- **Law 8 (Growth)** — **HONORED.** Three rounds of findings landed as tests and wiring; the r3 defect class is pinned as a synthetic regression test so it stays legible after the bad idiom is gone.
- **Law 2** — not implicated. **Code standard (#N)** — honored; new units cite `#42`.

**Blameless accounting:** three REJECTs and three fix cycles produced a guard whose every claim is now measured, with a defect class pinned as a test. That is the ladder working, and it is a success outcome.

```starcar-artifact
outcome: APPROVE
task-id: process-42-review-r3
findings: 0 Major, 0 Minor. MAJOR-3 CLOSED and proven in three directions. Series converged.
  MAJOR-3 (round 2's fix-created defect) CLOSED. Verified by my own fault injection, all
    reverted byte-identical:
      Uncited extensionless Dockerfile: was 10/10 SILENT GREEN in round 2, now 12/13
        failing by name with "Expected null or empty, but got 'Dockerfile'" via the direct
        citation check, since the empty extension joined the CHECKED set.
      Cited extensionless Dockerfile: 13/13 green, no false positive.
      SENTINEL PATH, the decisive one - removed the empty string from the checked set to
        recreate the exact round-2 scenario: 12/13 with the message "extension(s) [(no
        extension)] appeared in the post-boundary corpus with no citation check and no
        declared exemption - decide: extend CodeExtensions or DeclaredExemptExtensions, do
        not leave it silent, but got 1". The sentinel renders readably instead of joining
        away to nothing. Both layers of defence watched firing.
  POLICY DECISION ADJUDICATED as CORRECT and accurately described. Extensionless files
    belong in the checked set. The distinction the car draws is the load-bearing one: json
    and md are exempt for FORMAT reasons (JSON cannot hold a comment without mutating the
    artifact under test) or OWNERSHIP reasons (DocPolicy owns docs), while extensionless
    files share neither property - the class is defined by naming convention and its real
    members, Dockerfile, Makefile, CODEOWNERS and shebang scripts, are hash-comment-capable
    exactly as a .sh is. The failure-direction argument is decisive and correct: checking by
    default makes a genuinely comment-incapable extensionless file a loud named violator,
    whereas exempting the empty extension would silently swallow every future Dockerfile,
    reproducing this defect one layer up. Path-level never extension-level is right for the
    same reason - a path exemption is bounded to one artifact, an extension exemption is
    unbounded over all future files. The disclosed edge does NOT claim a path-exemption
    mechanism exists; it is honest future-conditional and NIRTS-correct.
  MECHANISM FIX verified. Assertion on Count with sentinel; Get-UnaccountedExtensions
    extracted; the 3 synthetic tests call the PRODUCTION function, honoring my round-1 MIN-1
    class. Grep confirms one definition each of all five helpers and all SEVEN call sites
    wrapped.
  SELF-FOUND FIX verified by my own probes, both claims TRUE. Array collapse is real: a
    function returning a single empty-string element yields type String with IsArray False,
    and a zero-item return yields NULL, so the call-site wrapping is genuinely load-bearing.
    The Mandatory claim is true verbatim - Mandatory on a string-array parameter rejects an
    empty-string element with "Cannot bind argument to parameter because it is an empty
    string" - so removing it was necessary, not a convenience loosening, and it is safe
    because both call sites still pass the parameter and an omission would red the
    non-vacuity test loudly.
  CLAUDE.md Law 1 concern from round 2 RESOLVED. The amendment states exactly what the guard
    delivers, records the round-3 correction with my own measurement quoted accurately, and
    every claim in the new text was re-tested against the code. No overstatement remains.
  SCOPE verified: exactly two files changed; ci.yml and docs/setup.md confirmed untouched
    since round 2; no Dockerfile or injection residue in tree or diff.
  FORWARD OBSERVATIONS, not findings: dotfiles get their own extension, so a post-boundary
    .gitignore or .dockerignore will red the closed-set test naming it - loud, named,
    actionable, the design working rather than a wolf-cry, and none exist today. The second
    synthetic test deliberately pins the old buggy idiom as documentation of the class. A
    pre-boundary file deleted and re-added is not flagged, which is correct under NO
    BACKFILL.
  CONVERGENCE: r1 2 Major 4 Minor 1 Note, r2 1 Major 0 Minor, r3 0 Major 0 Minor. Monotonic
    decline to zero, no finding recurred, no earlier fix regressed. My round-2 escalation
    boundary was that a new Major inside extension coverage escalates rather than going to a
    round 4; that boundary was NOT crossed because round 3 produced no Major at all, so the
    escalation clause does not fire and I do not invoke it. The three rounds each caught a
    genuinely different failure class - wiring, coverage, assertion shape - which is a gate
    working, not churn. Series closed.
  MERGEABLE: YES from 45588a2. This APPROVE is the whole-train gate for this car; the
    sibling docs car is a separate gate on which I make no claim.
abstract: Final delta re-review, round 3, of commit 45588a2afb270ee43bb28407161a639e7eeb1362
  against issue 42, on round-2 HEAD 83cd377. Base verified first, tree clean, delta touching
  exactly the two claimed files with ci.yml and docs/setup.md confirmed untouched since round
  2 and no injection residue anywhere. Suites run by the reviewer at that SHA in the detached
  worktree: scripts/tests 194 passed 0 failed 1 skipped of 195, matching the derived detached
  expectation and consistent with the car's attached 195 of 195 since the single skip is the
  pre-existing number-50 detached guard-runner skip; the gate alone 13 of 13; probes 24 of
  24; store-checks 178 of 178. VERDICT APPROVE with zero Major and zero Minor findings. Round
  2's fix-created Major is closed and proven in three directions by my own fault injection,
  all reverted byte-identical: an uncited extensionless Dockerfile that measured 10 of 10
  silent green in round 2 now reds 12 of 13 naming Dockerfile; cited, it greens 13 of 13; and
  the decisive sentinel-path injection, recreating the exact round-2 scenario by removing the
  empty extension from the checked set, reds with a readable no-extension sentinel instead of
  joining away to nothing. Both layers of defence were watched firing. The extensionless-file
  policy is adjudicated correct and accurately described, on the ground that its failure
  direction is loud rather than silent and that a path-level exemption is bounded where an
  extension-level one is not. Both PowerShell semantic claims the car made were probed
  independently and are true: pipeline output collapses a single empty-string element to type
  String and a zero-item return to NULL, making the call-site wrapping load-bearing, and the
  Mandatory attribute rejects an empty-string element verbatim, making its removal necessary
  rather than a convenience. All seven call sites are wrapped, all five helpers have exactly
  one definition, and the synthetic tests bind to the production function, honoring the
  round-1 duplication finding. The CLAUDE.md Law 1 overclaim from round 2 is resolved and
  every claim in the new text was re-tested against the code. Convergence across the series
  is monotonic, 2 Majors then 1 then 0, with no finding recurring and no earlier fix
  regressing; my round-2 escalation boundary was not crossed and is not invoked. MERGEABLE
  YES from 45588a2. Honest boundary restated: real CI green remains unobserved and
  unobservable here because the commit is on no remote branch, only the CI shape was proven
  by clone simulation, and since fetch-depth 0 changes checkout for every matrix leg the
  conductor must watch the first real run to a terminal state post-merge. Revert
  byte-identical, HEAD restored, porcelain empty, shared checkout on dev clean and untouched;
  nothing was edited, committed or pushed to the record.
```