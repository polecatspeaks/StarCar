<!-- starcar-integrity: sha256=0dfd3ccbb13d04d46c92c606d6f8178d27ae52060c6edc096c46187c74371a72 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Index-gate-scope train (#20) review: APPROVE (round 1, zero Majors, both reds fault-injected)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (adversarial, Opus, fresh detached worktree)
Round: 1
Target: `car/20-index-gate-scope at 565714d (3 commits)`
Base reviewed: `565714decfe36d205f36ce65cbb1bc474ff32aac`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `ac7d81bda8f23f2a6`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `565714decfe36d205f36ce65cbb1bc474ff32aac` |

| Dispatch, the locator within the session | `ac7d81bda8f23f2a6` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 565714decfe36d205f36ce65cbb1bc474ff32aac
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All verified. Tree clean at HEAD 565714d, both touched suites green (11/11). My fault injections were restored byte-identical (confirmed via `git hash-object` == committed blob, and `git status` clean). I have everything needed for the verdict.

---

# ADVERSARIAL REVIEW VERDICT: APPROVE

**Train #20 (index-gate-scope) | base 49e3eb4 → HEAD 565714d | commits b638794, f3db161, 565714d**
Worktree base verified: `git log -1` = `565714decfe36d205f36ce65cbb1bc474ff32aac`, matches brief. Environment: Git Bash, `/usr/bin/sh` on PATH, pwsh 7.6.3, Pester 5.8.0.

No Majors. No Minors that block. Three NOTES recorded below. I ran every suite myself and fault-injected both red claims.

## Claims verified (each RUN, not read)

| # | Claim | Result |
|---|---|---|
| 1 | Task 1 red: removing `if:` → `Expected length: 134, Actual length: 0` | **CONFIRMED by fault injection.** Deleted ci.yml:169, ran CiWrapperSimulation.Tests.ps1: the scope test failed with exactly `Expected length: 134 / Actual length: 0`. Restored via `git checkout`; `git diff --exit-code` = 0; `git hash-object` of ci.yml — restore byte-identical. |
| 2 | Task 1 green 3/3 | **CONFIRMED.** CiWrapperSimulation 3/3. |
| 3 | Exact `if:` string + test pins it exactly | **CONFIRMED.** ci.yml:169 is byte-exact; test asserts `$actual.Trim() \| Should -Be $expected` (exact equality, not looser) against the identical 134-char string, read from parsed YAML (`$Step.if`), never hand-copied. |
| 4 | Task 2 red: F3 byte-mismatch + header StartsWith false | **CONFIRMED by fault injection.** Reverted generator to 49e3eb4, ran ArtifactIndex.Tests.ps1: F3 failed `Expected length: 473, Actual length: 149`; header test failed `Expected $true, but got $false`. Restored via `git restore --staged --worktree`; `git hash-object scripts/New-ArtifactIndex.ps1` = `9e3eadd…` = committed blob (byte-identical). |
| 5 | Task 2 green 8/8 | **CONFIRMED.** ArtifactIndex 8/8. |
| 6 | Determinism + committed index fresh at 565714d | **CONFIRMED.** Two regenerations + committed `artifacts/index.md` all hash `78FAB548…` (57 rows). The committed index is fresh. |
| 7 | Header matches schema verbatim | **CONFIRMED.** See sentence check. |
| 8 | Full suites: probes 12/12, tests 161/161 | **CONFIRMED.** `Invoke-Pester ./scripts/tests` = **161/161**; `./scripts/probes` = **12/12** (sh on PATH). |

## Sentence check — cross-boundary values

**Hop A — the `if:` condition (brief prose → YAML → Actions runtime → test pin).** Traced every hop:
- ci.yml:169 carries `(github.event_name == 'pull_request' &amp;&amp; github.base_ref == 'main') || (github.event_name == 'push' &amp;&amp; github.ref == 'refs/heads/main')`.
- `github.base_ref` **is** the PR's target/base branch short name (`main`, not `refs/heads/main`) and is populated only for `pull_request`/`pull_request_target` — so clause 1 is correct and is empty (false) on push. `github.ref` for a push to main **is** `refs/heads/main`; for a `pull_request` event it is `refs/pull/N/merge`, so clause 2 is correctly false on PRs. Result: fires on PR-to-main and push-to-main, skips otherwise — exactly the ruling's scope.
- Step-level `if:` skips the **step**, not the job — correct placement.
- Precedence: Actions binds `&amp;&amp;` tighter than `||`; the car added explicit parens so `(A&amp;&amp;B) || (C&amp;&amp;D)` is unambiguous regardless. A bare expression in `if:` (no `${{ }}`) is valid — Actions auto-evaluates.
- Strongest confirmation of the YAML hop: the committed `ConvertFrom-Yaml` test parses `.if` to exactly the 134-char string and passes at HEAD — the YAML is well-formed and the value is byte-exact. This is not my assertion; it is an observed parse.

**Hop B — header text across four surfaces.** Programmatically compared the 6-line canonical block against: committed `artifacts/index.md` (True), `schema/index-format.md` fenced block lines 83-88 (True), live generator output (True), and both test pins — F3 fixture `$header` and header-test `$expectedHeader` 6-line prefixes (True). All four byte-identical. `artifacts/index.md` and generator output are both **UTF-8 no BOM, LF-only** (no CR bytes) — the repo's hashed-artifact discipline holds.

**Hop C — five prose surfaces.** ci.yml header comment (24-31), gating-matrix.md row 19, state-ledger.md row 66, spec 5.2 amendment (228-237), CLAUDE.md PR-cycle step 1 — all read scoped-to-PR-to-main/push-to-main; none still describes the unconditional gate. Repo-wide grep confirms no other **living-contract** surface describes the old scope (remaining matches are immutable artifacts/records and point-in-time plans, correctly unchanged; AGENTS.md hits are GitNexus-index staleness; the template has only a generic example row).

## Adjudication — F3 fixture change: LEGITIMATE, not weakened
The fixture record still carries `subject = 'subj|with|pipe'` and `outcome = "line-one\nline-two"`, and `$expected` still requires the escaped row `| subj\|with\|pipe | ... | line-one line-two | ... |`. The change only **prepended** the header to a whole-file byte comparison. A generator that failed to escape a pipe or collapse a newline would still break the byte match on the row portion. Pipe-forging and newline-splitting remain caught.

## Doc check
Every cited path exists (`scripts/Produce-Artifact.ps1`, `schema/index-format.md`, both test files, both contracts). Spec 5.2 amendment (lines 228-237) preserves the original ruling "A stale index fails the build" (line 224) visibly above and supersedes only the unconditional scope, naming the two carrier rows. CLAUDE.md step 1's command `./scripts/New-ArtifactIndex.ps1 -StoreRoot artifacts -OutFile artifacts/index.md` is the exact invocation I ran in claim 6 — it runs and reproduces the committed index.

## Guard check (this diff RE-SCOPES a guard)
- **(a) the test pin** — red-first PROVEN. I watched it fail (claim 1) and restored byte-identical. The committed `if`-scope test is a non-vacuous pin.
- **(b) the runtime behavior** — the gate actually SKIPPING on a dev push and FIRING on a PR-to-main / push-to-main cannot be observed until this branch is pushed and a PR opened. This is **conductor handback** (live CI observation), explicitly deferred, as the gating-matrix row itself states ("The live CI-side firing … is conductor handback"). No evidence is fabricated; nothing impossible is demanded. State plainly: today we have the static pin + all-green suites; the live skip/fire observation remains for the conductor at PR time.

## Constitution check
- **Law 1 (no confident falsehood):** the freshness header makes dev-lag *honest*. Evidence: schema + emitted header declare "on dev it may lag the store by a dispatch batch between regenerations" — the lag is a documented cadence, not a hidden gap.
- **Law 4 (no silent truth-surface drop):** the dev-exclusion is *loudly* documented across five surfaces plus the index's own header; gating-matrix row says "a documented cadence, never a suppressed truth surface." Not silent.
- **Law 6 (no unowned second copy):** the core concern — the index as a second copy of the store — stays gated (narrowed to PR/push-to-main, not un-gated). The header text has a declared single owner (`schema/index-format.md`); the generator emits it and tests pin it. Pin-vs-owner distinction holds. **NOTE:** no *mechanical* gate asserts the generator's emitted text equals the schema's declared text — a reviewer must verify (I did, this round: all four byte-identical). This is the same prose-tier binding as any spec-to-code pair and is acceptable; naming it so a future schema edit that skips the generator is a known blind spot.
- **Law 7 (stranger's fork):** hardcoding `main` in the `if:` is acceptable — it is this repo's real default branch and the gate *should* fire on merges to the real main; branch names in workflow conditions are idiomatic and discoverable in one file. Portable prose ("PR-to-main") carries the intent.

## NOTES (non-blocking; owner may rule)
1. **Same-commit doc sequencing.** b638794 changed the gate scope but left gating-matrix.md, state-ledger.md, and spec 5.2 stale; 565714d ("true the REMAINING carriers") trued them. Strict per-commit reading of the same-commit doctrine could flag this. I rule NOT a Major because: the reviewed/merged deliverable **tip (565714d) is fully doc-consistent**; no published or downstream-consumed surface ever carried the stale state (unmerged local car-branch history only); the repo's own history routinely uses separate `docs:` commits within a train; and the doctrine's named harm — deferral *past the deliverable boundary* to a follow-up ticket — did not occur. Flagged for owner visibility, not blocking.
2. **Law 6 emitter-vs-owner** (above) — prose-tier, verified this round.
3. **CLAUDE.md step 1** says the gate is "scoped to PR-to-main (#20)" without also naming push-to-main. Contextually correct (the step is about PR opening) and not a falsehood — it does not claim "only PR-to-main" — but slightly partial versus the full scope. Cosmetic.

## Fault-injection disclosure
I performed two local fault injections (deleted ci.yml:169; reverted the generator to 49e3eb4), ran the reds, and restored both byte-identical. Final state: `git status` clean, HEAD = 565714d, `git hash-object scripts/New-ArtifactIndex.ps1` = committed blob `9e3eadd…`, both touched suites green (11/11). I committed nothing and pushed nothing.

```starcar-artifact
outcome: APPROVE
findings: &gt;
  Zero Majors. All eight car claims verified by running, not reading. Both red-first
  claims CONFIRMED by fault injection and restored byte-identical (Task 1: removing the
  ci.yml if line yields Expected length 134 Actual length 0; Task 2: reverting the
  generator yields F3 byte-mismatch 473 vs 149 and header StartsWith false). Full suites
  observed at HEAD 565714d: scripts/tests 161 of 161, scripts/probes 12 of 12. The if
  condition is byte-exact across ci.yml, the ConvertFrom-Yaml-parsed test pin, and the
  brief; GitHub Actions semantics traced hop by hop (base_ref is the PR base short name,
  ref is refs/heads/main on push, step-level if skips the step, explicit parens make
  precedence unambiguous). Header text byte-identical across schema, generator, committed
  index, and both test pins; UTF-8 no BOM, LF only. Committed index fresh (two
  regenerations plus the committed copy all hash 78FAB548, 57 rows). F3 fixture change is
  the anticipated header prepend and does not weaken the pipe/newline escaping assertion.
  All cited files exist; spec amendment preserves the original ruling above it; five prose
  surfaces agree with the YAML and each other; no other living-contract surface describes
  the old scope. Guard proof half a (the static pin) is red-first proven; half b (live
  skip on dev, fire on PR-to-main) is correctly deferred to conductor handback at PR time.
  Constitution Law 1, 4, 6, 7 honored. Three non-blocking NOTES: same-commit doc
  sequencing (carriers trued in a third commit 565714d, ruled not-Major because the
  merged tip is consistent and no published surface carried the stale state); Law 6
  emitter-vs-schema text has no mechanical gate (prose-tier, verified this round);
  CLAUDE.md step 1 names PR-to-main only, contextually correct.
abstract: &gt;
  Round 1 adversarial sentence-check review of the #20 index-gate-scope train. APPROVE.
  The artifact-index staleness CI gate is correctly scoped to PR-to-main and push-to-main,
  the index carries a static freshness-contract header emitted deterministically and
  matching its schema owner verbatim, and every invalidated carrier is trued by the tip.
  Red-first proven by fault injection on both tasks; all suites green; runtime gate firing
  is the one deferred item for conductor observation at PR time.
```