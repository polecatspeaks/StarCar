<!-- starcar-integrity: sha256=3548f7d3f51c31946a38f2897eae2d6d0941623ab303698efb1325b1e7a74508 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# PR-18 external-review fixes: final review APPROVE (fresh worktree)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: PR-fix car review (adversarial, Opus, fresh detached worktree)
Round: 1
Target: `car/pr18-copilot-fixes at a403193 (3 commits)`
Base reviewed: `a4031937e6c12ad6a22f3933d89a51112b80ac93`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a12fbbe2b1592101a`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `a4031937e6c12ad6a22f3933d89a51112b80ac93` |

| Dispatch, the locator within the session | `a12fbbe2b1592101a` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain a4031937e6c12ad6a22f3933d89a51112b80ac93
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All verification complete. Worktree clean (only gitignored `testResults.xml` byproduct), HEAD unchanged at `a403193`. Here is my verdict.

---

## VERDICT: APPROVE

All three commits (0478afa, b10c152, a403193) verified. Zero Major, zero Minor findings. The conductor may merge all three to dev.

### Base and scope
- HEAD = `a4031937e6c12ad6a22f3933d89a51112b80ac93`, three commits above `091efe6`, clean tree confirmed at start and end. Only byproduct after review: gitignored `testResults.xml`.
- Diff scope `091efe6..HEAD` is entirely within the fixes' surfaces: `.claude/hooks/{post-task,subagent-stop}-probe.sh`, `.gitignore`, `schema/starcar-artifact.schema.json`, `schema/vectors/*`, `scripts/Produce-Artifact.ps1`, `scripts/canonicalise-demo.py`, `scripts/tests/*`, and the deleted tracked `.pyc`. Nothing outside surfaces; the `artifacts/` store is untouched by these three commits.

### Suites at HEAD (I ran each myself, pwsh 7.6.3)
- Pester `scripts/tests`: **90/90 passed**, 0 failed, at `a403193`.
- Pester `scripts/probes`: **12/12 passed**, 0 failed, at `a403193`.
- `./scripts/Verify-Verdict.ps1`: **25/25 verdict files verified** (every body matches its claimed hash), **exit 0**.

### b10c152 (Qodo) — full scrutiny
**Q3 path traversal** — `Produce-Artifact.ps1:238-240` sanitizes `$subject` (`-notmatch '^[A-Za-z0-9._-]+$' -or .Contains('..')`) BEFORE the first `Join-Path $storeAbs $subject` at line 242. Record assembly/hashing (212-230) writes nothing to disk, so a rejection at 238 means no file anywhere. Sentence-check on `subject`: payload JSON (131/137) → `Get-Prop` → `Portable` normalize (192) → sanitize (238) → path (242-244) → write (248). Same normalized value is checked and used (no TOCTOU); `&lt;repo&gt;`/`~` outputs of normalization contain chars outside the allowlist, so normalization fails closed.

Fault injection as a real `pwsh -File` subprocess (how the hook runs it), in an isolated scratch repo:
- `agent_id='../evil'` → exit 1, zero new files (inside or outside store), `_faults.log` line `rejected subject (path traversal risk): ../evil`.
- `agent_id='a/b'` → exit 1, zero new files, `_faults.log` line naming `a/b`.
- `agent_id='clean123abc'` → exit 0, record written at `clean123abc/returned-...json`, committed as a single-path `harness:` commit, no fault.

Disclosed test-harness change (Invoke-Producer try/catch): purely additive around the `&amp;`-invocation; success-path tests still assert `ExitCode -Be 0` plus `Test-Path`, so a terminating error still fails them. Does not weaken the other Producer assertions.

**Q4** — `git ls-files | grep pycache` empty; the tracked `.pyc` deleted in b10c152; `__pycache__/` added to `.gitignore`.

**Q5** — both hooks guard `command -v python`, emit a loud stderr note, `exit 0`. Fault-injected under `env -i PATH=/usr/bin` (verified `command -v python` genuinely exits 1 first): both hooks emit the note, exit 0, create no `probe-logs` dir (skip precedes `mkdir`). Run normally: both append the stamped payload to their jsonl logs.

### a403193 (the fix) — full scrutiny
**MAJOR-1** — four negative vectors bumped from 61-hex (double-invalidated under `{64}`) to 64-hex zeros. `Test-StarcarArtifact` validates against the schema via `Test-Json` only (it does not recompute the hash), so 64 zeros passes the `^sha256:[0-9a-f]{64}$` pattern and each vector's invalidity is isolated to its one missing field. I re-derived the isolation proof at HEAD — each flips False → True on restoring its single intended-missing field (zero residual errors after restore):

| vector | restored field | as-is Valid | after-restore Valid | flip |
|---|---|---|---|---|
| invalid-missing-kind | kind | False | True | isolated |
| invalid-presumed-lost-missing-basis | basis | False | True | isolated |
| invalid-returned-missing-abstract | abstract | False | True | isolated |
| invalid-returned-missing-outcome | outcome | False | True | isolated |

(The secondary "Expected ... at /kind" messages in the as-is errors are `Test-Json` conditional-branch reporting artifacts; they clear entirely once the one field is restored, confirming isolation.)

**MINOR-1** — `canonicalise-demo.py` header no longer cites a line number; it now reads "The `sweep = dict(hook)` line below" (the actual line drifted to 46). Grep found no `Line N` citation (the 36/62/74 hits are `subject` data fields). Header still marks the file `PRESERVED FAKE DEMONSTRATION` / `wreckage exhibit` / `forgery` / `round 3`. Ran it: `hook` and `sweep` event_ids identical, `EQUAL: True` by shallow-copy construction — the header's claim is truthful.

### Regression on already-passed fixes
- FIX 1: `Schema.Tests.ps1` now asserts both vocab files `ConvertFrom-Json | Should -Not -Throw` (parse, not just exist).
- FIX 2: asserts `outcome.type='string'` and no `enum`, mirroring `kind` (de-enum pinned).
- FIX 3: schema pattern locked to `{64}`; pinning vector `invalid-integrity-wrong-length.json` is 63-hex/expect invalid, validates Valid=False at HEAD (regex mismatch at `/integrity`). Collateral fixture bumps (Artifact/ArtifactIndex/Detector/valid vectors) are short-placeholder → 64-hex zeros so they survive `{64}`; nothing under test weakened.
- FIX 4: wreckage header survived as pure insertion; the a403193 edit only de-numbered the citation.

### Whole-branch integrity
- `Verify-Verdict.ps1`: 25 verified, exit 0. Spot-validated two migrated store artifacts (`car1-review-round1.json`, `design-v0-round1-REJECT.json`): both 64-hex integrity, Valid=True under the tightened pattern.

### Constitution check
- Law 1 (no confident falsehood): wreckage header claim verified by execution; de-numbered a citation that had already drifted (a lying canary fixed). Honored.
- Law 4 (never silently dropped): Q3 rejections raise + write `_faults.log` naming the subject; watched fire. Honored.
- Law 6 (no second copy): `Artifact.psm1` validates via `Test-Json` against the one schema; no hand-rolled validator. Honored.
- Law 7 (stranger/portability, no hardcoded taxonomy): kind/outcome de-enumerated to `schema/vocab/` data (FIX 2 pins it); path normalization rewrites operator roots. Honored.
- TDD red-first / non-vacuity: Q3 tests assert real store/exit/fault behavior; I fault-injected independently through the real subprocess; the `{64}` pinning vector proves the guard non-vacuous. Honored.
- Documentation-equal-to-code: comment blocks in the producer and hooks explain WHY; MINOR-1 trued a drifted citation in the same commit class. Honored.

One non-finding note (fails safe, documented so it is not assumed otherwise): `subject='.'` would pass the allowlist and resolve to the store root rather than a subdir — it stays INSIDE the store, so it is not a traversal escape and not in scope for Q3; agent/dispatch ids are hash-like in practice. Not a defect.

```starcar-artifact
outcome: APPROVE
findings: Zero Major, zero Minor across all three commits (0478afa, b10c152, a403193). Base verified a4031937e6c12ad6a22f3933d89a51112b80ac93, clean tree, scope entirely within fix surfaces. Suites re-run at HEAD by reviewer under pwsh 7.6.3 - tests 90 of 90, probes 12 of 12, Verify-Verdict 25 of 25 exit 0. Q3 path traversal fault-injected as real subprocess in isolated scratch repo - dotdot-evil and a-slash-b both exit 1 with zero files written and a faults.log line naming the rejected subject, clean id writes and commits normally, disclosed harness try-catch does not weaken other Producer assertions. Q4 no bytecode tracked, pycache gitignored. Q5 both probe hooks guard command-v-python - fault-injected with python stripped from PATH gives loud note plus exit 0 and no log dir, normal run logs the stamped payload. MAJOR-1 isolation proof re-derived for all four negative vectors - each flips invalid to valid on restoring its single missing field, integrity now 64-hex so the length no longer double-invalidates. MINOR-1 line citation removed with no numeric citation remaining and wreckage marker intact, header claim confirmed by running the demo (EQUAL true by shallow-copy construction). FIX 1 through 4 survived later commits, collateral fixture hashes bumped to 64-hex so nothing under test weakened. Whole-branch integrity green, migrated store artifacts validate under the tightened 64-hex pattern. Constitution laws 1, 4, 6, 7 and TDD honored.
abstract: Final adversarial review of StarCar PR-18 fix branch. APPROVE - conductor may merge all three commits to dev, resolve Copilot and Qodo threads with fix SHAs, and re-request Copilot.
```