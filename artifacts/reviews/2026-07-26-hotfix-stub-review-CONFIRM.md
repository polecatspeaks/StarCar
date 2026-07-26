<!-- starcar-integrity: sha256=f5a625a20d4e2f1239243c45be02d6e2876c221fcf997ed5d7d54a00f8b3bd01 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Conductor hotfix 81df6cc post-hoc review - CONFIRM

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: binding post-hoc adversarial review (conductor-hotfix leg e)

Target: `commit 81df6cc (per-OS PATH separator + exec bit in the entire-stub helper)`
Base reviewed: `81df6ccebfea0016edab124664f658d216303c39`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: CONFIRM**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `ae17d6a1ac77dc264`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `81df6ccebfea0016edab124664f658d216303c39` |
| Entire checkpoint | `911706eb5037` |
| Dispatch, the locator within the session | `ae17d6a1ac77dc264` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 81df6ccebfea0016edab124664f658d216303c39
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All checks complete. Both checkouts verified clean.

---

# VERDICT: **CONFIRM** — the hotfix stands

**0 Major, 4 Minor.** The fix is correct, the causal chain is real (I re-derived it independently on Linux rather than accepting the commit message), and all five legs of the conductor-hotfix boundary are genuinely exhibited. The Minors are accuracy defects in the *disclosure and the friction-log framing*, plus two surviving siblings of the class — none of which is grounds to force rework-forward on this diff.

---

## Leg-by-leg boundary ruling

**(a) CI-blocking — CONFIRMED.** `gh run view 30205842313`: `headSha 42e3eae6b4e29e813acbac5d09dde9c1be454442`, conclusion `failure`, `verify (windows-latest) success` / `verify (ubuntu-latest) failure`. The failure is exactly the one described, verbatim from the log:

```
##[error][-] present branch: execs "entire hooks claude-code session-start" verbatim 41ms
Expected: 'STUB_ENTIRE_CALLED_WITH: hooks claude-code session-start'
But was:  '{"systemMessage":"\n\nEntire CLI is enabled but not installe...'
Tests Passed: 181, Failed: 1
```

**(b) Mechanical, coverage-class — CONFIRMED.** 2 files, +26/−2. `scripts/tests/SessionStartWiring.Tests.ps1` (helper bodies inside `BeforeAll` only) and `docs/friction-log.md`. **Zero product code; zero assertions changed; the hook under test is untouched.** That last point is the important one: the fix corrects the test's *ability to observe*, not the behavior being observed.

**(c) Red for the stated reason — CONFIRMED, and independently re-derived.** I did not take the commit message's word for the causal chain. This box has WSL Ubuntu-24.04, so I isolated each defect on real Linux (script at `~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\15c84ef1-8e84-4d98-aacd-17cce34752cb\scratchpad\probe.sh`):

| Case | PATH sep | exec bit | `command -v entire` |
|---|---|---|---|
| 1 | `:` | **no** | **NOTFOUND** |
| 2 | `:` | yes | FOUND |
| 3 | **`;`** | yes | **NOTFOUND** |
| 4 (= the 42e3eae state) | `;` | no | NOTFOUND |

Observed file mode as written: `-rw-r--r--`. **Both defects are independently sufficient**, so both fixes were necessary. End-to-end against the real hook, case 4b reproduced the CI failure byte-for-byte:

```
exit=0 out={"systemMessage":"\n\nEntire CLI is enabled but not installed or not on PATH.\nInstallation guide: https://docs.entire.io/cli/installation#installation-methods"}
```

and case 2b produced `STUB_ENTIRE_CALLED_WITH: hooks claude-code session-start`. **Ruling: leg (c)'s spirit is satisfied** — the red is a genuine observed failure, for the stated reason, now confirmed by a second party who ran it. One inferred hop I could not close: no `pwsh` or `dotnet` in WSL, so I did not directly observe `Set-Content`'s mode on Linux (I observed a `printf`-created file at 0644). This does not move the verdict — case 3 alone proves the separator defect sufficient, and `chmod +x` is idempotent, so the second fix is at worst harmless.

**(d) In-commit disclosure — CONFIRMED complete in structure**, all five legs named, run ID cited, deviation declared. Two accuracy defects: F3 and F4 below.

**(e) This review.**

---

## The fix itself

- `[System.IO.Path]::PathSeparator` — correct. Observed `';'` on this box (pwsh 7.6.3); `':'` on Linux is proven by the green ubuntu leg of run 30206223085. **On Windows the fixed line is byte-equivalent in effect to the old one** (`PathSeparator == ';'`), so Git-bash's Windows-PATH translation is unchanged — confirmed by injection A passing 9/9.
- `if (-not $IsWindows) { &amp; chmod +x $stubScript }` (`SessionStartWiring.Tests.ps1:150`) — correct. `$IsWindows` is a pwsh-6+ automatic `Boolean` (observed `True`, type `Boolean`). Unchecked `chmod` exit is not a silent-loss risk: a failed chmod surfaces as the absent-branch assertion failure.
- `[regex]::Escape($sep)` — observed identity for both `';'` and `':'`. Harmless and defensive, not a defect.

**Fault injection (check 3).** Restored the hardcoded `';'` at `SessionStartWiring.Tests.ps1:153`, confirmed the injection landed via `git diff`, ran on Windows: **9 passed / 0 failed**. Reverted byte-identically (SHA-256 back to `C2B4CCEE032207D9A5F5A9108120E46673AE0DF7CB68E1E7484C630F1147D58D`, `git status` empty). Combined with WSL case 3, this **validates the friction-log's class claim**: the defect is Windows-invisible and Linux-fatal. Corroborated by CI itself — at 42e3eae with both defects present, `verify (windows-latest)` was **success**.

**Suite counts observed by me**, worktree `81df6cc`, Windows, pwsh 7.6.3:
- `scripts/tests` detached-worktree cwd: **181 passed / 0 failed / 1 skipped / 182 total** (twice)
- `scripts/tests` attached cwd: **182 passed / 0 failed / 0 skipped / 182 total**
- The skip is `run-session-start-guards.sh: agent-pull runner (#50).running the REAL guards prints [ci-baseline]'s marker ONLY when attached to a branch` — pre-existing conditional design, not this hotfix's concern, exactly as the brief stated.

---

## Findings

**F1 — Minor (ticket required): two surviving instances of the class this commit names.**

- `<repo>-wt\review-hotfix-stub\scripts\probes\SubstrateFloor.Probes.Tests.ps1:98` — `($env:PATH -split ';' | ...) -join ';'`. **Vacuous green on ubuntu, proven not asserted**: fed a colon-separated PATH, the split yields **1 element**, the filter keeps it, the join reconstitutes the input — `IDENTITY: True`. And it reports green on the leg: run 30206223085, `verify (ubuntu-latest)`, `[+] `sh` still resolves with scoop\shims stripped from PATH`. Nothing was stripped. This **falsifies issue #14's own thesis** ("The substrate-floor probe suite either passes on Linux or names exactly what breaks") — it passes on Linux having tested nothing, which is the lying-instrument shape `ci.yml`'s zero-test refusals exist to reject.
- `<repo>-wt\review-hotfix-stub\scripts\tests\LandVerdictRider.Tests.ps1:78` — same shape, **less severe**: its self-validating guard at `:83` (`probe invalid: entire still resolvable`, exit 9) converts the latent defect into a loud failure rather than a false green. A correct no-op on CI today.

**Why this is not a Major against this diff, stated so the call is auditable:** both defects pre-date `81df6cc`; the diff neither created nor worsened them; and fixing them inside the hotfix would have broken leg (a) (not CI-blocking) and leg (b) (scope). **The hotfix was right to stay narrow.** But the friction-log entry landed *in this same commit* states the rule universally, and no open issue covers it (checked all 30 open; #14 is closest and is about landing the leg, not auditing existing tests). The rule is normative ("must use"), not descriptive, so this is an open obligation rather than a stale document — hence not a Major on that axis either. **Recommend the mechanical form, whose prior art is already in-repo:** `docs/templates/repo-policy-check-patterns.md` §1, instantiated as `scripts/tests/DocPolicy.Tests.ps1` — a repo-policy gate rejecting hardcoded `';'` PATH splits under `scripts/` is a known shape, not an invention.

**F2 — Minor: the friction-log framing overstates environmental inevitability, and that forecloses the lesson that would have caught F1.**

`docs/friction-log.md:219` headline "THE UBUNTU LEG CAUGHT WHAT NO DESK REVIEW COULD" and `:224` "Five review rounds (two reviewers, both on this Windows box) could not have seen it."

Every *mechanical* claim in that entry checks out — I verified each one, including "five rounds, two reviewers" (verdicts round1–round5 exist; round4 is the rotation). This claim does not. A hardcoded `';'` is a **structural** fact, and CLAUDE.md's own probe doctrine draws exactly that line: structural claims are settled by opening the file, behavioural ones only by running. Direct counter-evidence: `artifacts/reviews/2026-07-26-tooling-50-32-review-round1-REJECT.md:180` (§A3) examined **this very PATH-stripping technique for CI portability** and concluded "NO portability regression … that test's PATH-stripping technique is sound. … No finding." A reviewer reached this code, reasoned about its cross-OS behavior, and cleared it. That is *looked at it and missed it*, not *could not have seen it*.

This is consequence, not pedantry: if desk review structurally could not catch the class, no reading check gets added and F1's two siblings stay invisible. Suggested correction — keep the class lesson verbatim, replace the counterfactual with the checkable fact: *"a Windows-only RUN could not exhibit it; desk review could have, and round 1 §A3 examined this exact helper for CI portability and cleared it."*

**F3 — Minor: the commit's leg-(c) disclosure contains a false clause.** "red observed for the stated reason in **the only environment that can exhibit it**." False as stated: WSL Ubuntu-24.04 is installed on this box and reproduces the failure end-to-end in one command, including the byte-exact fallback JSON. The leg is still satisfied — the CI red is genuine — but the probe doctrine prefers the local run, and it was one `wsl` away. Same shape as F2: both overstate that the environment made the miss unavoidable.

**F4 — Minor: verification-honesty coordinate missing.** "local Windows suite re-run green 182/182 post-fix" omits attached-vs-detached. I reconciled both numbers (above) and **the claim is true for the conductor's environment**. Raised because the precedent is explicit and two days old: `artifacts/reviews/2026-07-26-tooling-50-32-review-round4-REJECT-ROTATION.md:274` graded exactly this omission a verification-honesty **VIOLATION** ("The car claimed `scripts/tests 180/180`; a second party re-deriving observes **179/1/180**").

---

## Cleared (checked, and stated because a careless review would flag them)

- `scripts/tests/SessionStartGuardRunner.Tests.ps1:53-56` fabricates four `.sh` fixtures with no `chmod`. **Not the exec-bit class**: `.claude/hooks/run-session-start-guards.sh:69` invokes them as `sh "$GUARD_DIR/$guard"`. Probed on Linux: `sh FILE` at `-rw-r--r--` runs fine; direct execution gives `rc=126 Permission denied`. Correctly exempt.
- `docs/setup.md:108-110` ("byte-identical behavior pinned by `scripts/tests/SessionStartWiring.Tests.ps1`") — opened; still true at HEAD, in fact *more* true. Not invalidated.
- No test-count change (182 total before and after), so no count-bearing document went stale.
- `#50` cited in both added comment blocks (`:122`, `:146`). Code standard honored.

---

## My own process violation (disclosed, not softened)

**My first fault injection wrote to the SHARED CHECKOUT, not the worktree.** `[System.IO.File]::ReadAllText/WriteAllText` resolve relative paths against `[Environment]::CurrentDirectory`, which PowerShell's `Set-Location` does not change. What exposed it: the "injected" hash equalled the pre-injection hash (`C2B4CCEE...`), impossible if content had changed. Restored byte-identically from a pre-injection byte backup (`C59BAE...` → `C2B4CCEE...`); `git -C <repo> status --short` and `git diff --stat` both empty. **That round's result (9/9) was discarded as meaningless** — the worktree file was never modified, so Pester had run un-injected code. The injection was redone with absolute paths, with the worktree `git diff` shown as proof it landed.

Aggravating, and it is evidence for F1's remedy: `docs/friction-log.md:198-206` records **this exact mistake**, made by the round-4 reviewer, dated 2026-07-26 — in the very file I was reviewing. I am the second reviewer in two days to make it. The lesson landed as prose only, and prose did not bind the next new-hire-on-day-one.

---

## Constitution check

| Law / rule | Ruling | Evidence |
|---|---|---|
| Law 1 — no confident falsehood | **Honored, strained ×3 (all Minor)** | Fix removes a falsehood (a test claiming to exercise the present branch that did not on Linux). Strained at F1 (vacuous probe), F2 (friction-log counterfactual), F3 (commit clause). No mechanism falsehood. |
| Law 6 — no second copies | **Actively honored** | The fix *deletes* a hardcoded duplicate of a platform constant in favor of `[IO.Path]::PathSeparator` (`:125`, `:151`). |
| Law 7 — the stranger / portability | **Honored, advanced** | This is #14's OS-portability requirement being paid down. F1 marks where it is not yet complete. |
| TDD / red-first | **Honored in substance** | CI-observed red for the stated reason, independently re-derived on Linux by me. Not a local red; F3 records that the disclosure overstates why. |
| Documentation ranks equal to code | **Honored** | Friction-log entry landed in the SAME commit. `docs/setup.md:108-110` opened and still true; no count-bearing doc invalidated. |
| Code standard (`#N` citation) | **Honored** | `#50` at `:122` and `:146`. |
| Conductor-hotfix exception (5 legs) | **All five exhibited** | Detailed above. |
| Reviewer read-only / never push | **Honored after a disclosed violation** | Byte-identical restore proven by SHA-256 and empty `git status` on both checkouts; nothing committed, nothing pushed. |
| Blameless is not vague / not polite | **Honored** | My own violation named with actor and exact move; F2 and F3 not softened despite the author being the dispatcher. |

**Final integrity:** worktree HEAD `81df6ccebfea0016edab124664f658d216303c39`, `git status --short` empty, `git diff --stat` empty. Shared checkout at `a8985876d31c20e09df42ee2face67f7529aa17a`, `git status --short` empty.

```starcar-artifact
task-id: hotfix-stub-review-r1
outcome: CONFIRM
findings: 0 Major, 4 Minor.
  F1 (Minor, ticket required) - two surviving instances of the class this commit names, one grep away.
    scripts/probes/SubstrateFloor.Probes.Tests.ps1:98 splits PATH on a hardcoded ';' and reports GREEN on
    the ubuntu leg of run 30206223085 having stripped nothing (proven: split of a colon-PATH yields 1
    element, filter keeps it, join is identity). That falsifies issue #14's own thesis that the probe suite
    "either passes on Linux or names exactly what breaks". scripts/tests/LandVerdictRider.Tests.ps1:78 is
    the same shape but fails LOUDLY via its probe-invalid guard at :83. Not Major against this diff: both
    pre-date 81df6cc, and fixing them inside the hotfix would have broken legs (a) and (b). Recommend the
    mechanical form; prior art already in-repo at docs/templates/repo-policy-check-patterns.md section 1.
  F2 (Minor) - docs/friction-log.md:219,224 claims the ubuntu leg "caught what no desk review could" and
    that five rounds "could not have seen it". Disproved by
    artifacts/reviews/2026-07-26-tooling-50-32-review-round1-REJECT.md:180, where a reviewer examined this
    exact PATH-stripping helper for CI portability and cleared it with "No finding." A hardcoded separator
    is a STRUCTURAL fact, settled by reading. The overstatement forecloses the review-side lesson that
    would have caught F1.
  F3 (Minor) - commit 81df6cc leg (c) says the red was observed "in the only environment that can exhibit
    it". False: WSL Ubuntu-24.04 is installed on this box and reproduced the failure end-to-end, byte-exact
    fallback JSON included, in one command. Leg still satisfied; the clause is not true.
  F4 (Minor) - "182/182" omits the attached-vs-detached coordinate. Both numbers reconciled (attached
    182/0/0; detached 181/0/1 of 182, skip = the ci-baseline conditional) so the claim is TRUE for the
    conductor's environment. Raised because round 4's verdict at :274 graded this exact omission a
    verification-honesty VIOLATION two days earlier.
  Cleared: SessionStartGuardRunner.Tests.ps1:53-56's four un-chmodded fixtures are correctly exempt
    (run-session-start-guards.sh:69 invokes them as `sh FILE`; probed on Linux, works at 0644, direct exec
    gives rc=126). [regex]::Escape is identity for both separators. docs/setup.md:108-110 still true.
  Reviewer self-disclosure: my first fault injection wrote to the SHARED checkout because .NET static file
    APIs ignore Set-Location. Caught by an impossible hash match, restored byte-identically (both checkouts
    verified clean), the meaningless result discarded, injection redone with absolute paths. This exact
    mistake is already recorded at docs/friction-log.md:198-206 from two days ago - I am the second
    reviewer to make it, which is itself evidence that a prose-only lesson does not bind.
abstract: BINDING post-hoc adversarial review of conductor hotfix 81df6cc (per-OS PATH separator plus exec
  bit in the entire-stub test helper). VERDICT CONFIRM - the hotfix stands, no rework-forward. All five legs
  of the conductor-hotfix exception genuinely exhibited and verified leg by leg. Leg (a): run 30205842313 at
  42e3eae, ubuntu-latest failure / windows-latest success, failing test and symptom verbatim as described.
  Leg (b): 2 files, +26/-2, test helper internals plus friction log, zero product code, hook under test
  untouched. Leg (c): I did not accept the commit message's causal chain - I re-derived it on real Linux via
  WSL Ubuntu-24.04 and isolated each defect independently (colon sep without exec bit NOTFOUND; semicolon
  sep with exec bit NOTFOUND; both fixed FOUND), then reproduced the CI failure end-to-end with the exact
  fallback JSON. Both defects are independently sufficient, so both fixes were necessary. Leg (d) disclosure
  complete in structure, two accuracy defects raised. Leg (e) is this review. Fault injection: restored the
  hardcoded ';' and observed 9/9 PASS on Windows, reverted byte-identically by SHA-256 - the defect is
  Windows-invisible and Linux-fatal, validating the friction log's class claim; corroborated by the
  windows-latest leg being green at 42e3eae with both defects live. Suites I ran myself at HEAD: scripts/tests
  181 passed / 0 failed / 1 skipped / 182 total detached, 182/0/0 attached; SessionStartWiring 9/9. Four
  Minors, zero Majors, so no Major-equals-REJECT trigger. The substantive open item is F1: the commit's own
  friction-log entry states a universal class rule while two violations sit one grep away, one of them
  producing a vacuously green probe on the very CI leg this incident vindicated - it needs a ticket and
  preferably a repo-policy gate rather than another prose entry.
```