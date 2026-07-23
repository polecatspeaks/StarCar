<!-- starcar-integrity: sha256=7cd46464cd3b357817c211995884374c1e2c3e2968996f6e2b53f61da876cbc2 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Yard board Car 1 review round 1: APPROVE - first Go code clears on first pass, zero Majors, all guards independently watched to fire

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (adversarial, Opus, fresh detached worktree)
Round: 1
Target: `car/board-car1 at 6152524 (5 commits)`
Base reviewed: `6152524e6a6fd2aaad6127bfa5197889e28cb3c7`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a10f39e071e8e4b7b`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `6152524e6a6fd2aaad6127bfa5197889e28cb3c7` |

| Dispatch, the locator within the session | `a10f39e071e8e4b7b` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 6152524e6a6fd2aaad6127bfa5197889e28cb3c7
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

I have completed all verification. Let me compose the verdict.

## VERDICT: APPROVE

Worktree base verified: HEAD at `6152524e6a6fd2aaad6127bfa5197889e28cb3c7`, detached, clean; scope `2051ffe..6152524` (commits ce5c93f, a81b6d4, 591423e, f356c2d, 6152524), 20 files. All claims independently re-derived by running, not reading. Three Minor findings, zero Major.

---

### Claims verified (RUN, not read)

**Claim 1 - Go suite + vet.** `go test ./... -v` in `board/` = 4/4 PASS (`TestPlaceholder`, `TestPinnedJSONSchemaDependencyCompilesStoreSchema`, `TestRE2CompatiblePatterns_CatchesInjectedLookahead`, `TestRE2CompatiblePatterns_RealSchemasAllCompile`) at 6152524, go1.26.5 windows/amd64. `go vet ./...` clean (exit 0). Observed by reviewer.

**Claim 2 - pinned dependency is real.** `board/go.mod:5` pins `github.com/santhosh-tekuri/jsonschema/v6 v6.0.2`; `board/go.sum:3-4` matches. The test compiles the real `schema/starcar-artifact.schema.json` and validates a sample whose shape matches the landed vector `schema/vectors/valid-returned.json` (fields present in both: schema, kind, subject, session_id, at, outcome, findings, abstract, normalisation, integrity). Passed.

**Claim 3 - RE2 probe red-first + non-vacuity.** (a) The committed `TestRE2CompatiblePatterns_CatchesInjectedLookahead` (t.TempDir + injected `^(?!bad-train:).*$`) passes and asserts the exact pattern and filename are named. (b) I independently fault-injected a lookahead (`^(?!bad).*$`) into the REAL third schema `schema/yard-snapshot.schema.json` (which has zero patterns of its own) and ran the real-schemas test: it **failed naming `yard-snapshot.schema.json` and the exact pattern** with `invalid or unsupported Perl syntax: `(?!``. This proves the glob reaches all 3 files (starcar-artifact, starcar-manifest, yard-snapshot) - not a vacuous zero-file glob. Restored byte-identical, `git status` clean.

**Claim 4 - root resolution (runtime.Caller).** `go -C board test ./...` from repo root = PASS; from a foreign cwd (`C:\...\Temp`) targeting the board module = PASS; `go -C board vet` = clean. cwd-independent as designed. (`go test ./board/...` from repo root fails at module resolution because `board/` is a separate module - this is standard Go behavior, not a defect.)

**Claim 5 - CI step, all four ways (the sentence check).** Extracted the exact `run:` text of step "Run board Go vet + tests" from `ci.yml` via `ConvertFrom-Yaml` (the CiWrapperSimulation technique), wrapped it in the GitHub Actions `shell: pwsh` suffix, executed as a child pwsh in `board/`:
- **A (green):** exit 0, "discovered 4 test(s)".
- **B (all `*_test.go` moved aside):** `go test` itself emits Action:skip and exits 0, but the step exits **1** - "discovered ZERO tests... A green run that asserted nothing is not a pass." Zero-test refusal fires. Restored, clean.
- **C (injected failing test):** exit **1** via the `$testExit -ne 0` branch ("discovered 5 test(s)", "go test ./... failed").
- **D (compile error in a `_test.go`):** exit **1**, caught by `go vet ./...` FIRST (before `go test` runs). Even were vet to pass, lines 207-211 check `$testExit -ne 0` BEFORE the zero-test check, so a build failure surfaces as red, never as zero-test confusion.
- Sentence-check trace: plan 1.2 prose -&gt; `ci.yml:182-214` YAML -&gt; pwsh run block -&gt; `go test ./... -json` -&gt; `ConvertFrom-Json` -&gt; distinct `(Package,Test)` count -&gt; exit codes. Attack on subtest over-counting: distinct pairs would count `TestFoo/sub` separately from `TestFoo`, i.e. it OVER-counts; harmless because the guard only distinguishes zero from nonzero (never a false zero, never a false pass). The board Go step sits in the `verify` job under the `os: [windows-latest, ubuntu-latest]` matrix with no `if:` -&gt; both legs.

**#20 staleness step untouched:** confirmed no `+/-` on any line of the "Verify the artifact index is not stale" step, including its `if:` (ci.yml:218). It appears only as diff context.

**Claim 6 - JS probe.** `node board/web/probe-yard-snapshot.mjs` from repo root AND from `board/web/`: byte-identical PASS output, exit 0, no `--experimental` flags, no `npm install`. Non-vacuity check (delete required `lanes` -&gt; "PASS (rejected as expected)") executes and is real. Vendored files: `grep` of all import/export-from lines shows every internal import is a relative `./x.js` specifier; **zero** bare specifiers, **zero** Node built-ins. VENDOR.md provenance independently confirmed: `npm view @cfworker/json-schema@4.1.1` returns shasum `4a2a3947...c3be6` and integrity `sha512-gAmrUZSG...k6og==` **exactly** matching VENDOR.md:9-13; all 9 vendored `.js` files are **byte-identical** to the upstream tarball's `dist/esm/` (diff + sha256 spot-check on validate.js). The default-draft claim is true: `validator.js:8` is `constructor(schema, draft = '2019-09', ...)`, and the probe passes `'2020-12'` explicitly (probe line 29).

**Claim 7 - Pester integrity.** `Invoke-Pester ./scripts/tests` = **178/178 passed, 0 failed, 0 skipped** at 6152524 (matches brief prediction; base predates the train:board-v0 manifest record). Working tree clean and HEAD intact afterward.

**Claim 8 - setup.md ruling.** Go row and Node row are accurate and Law-7-motivated (toolchains, versions, the PATH gap, no-experimental-flags all disclosed). The #3/#4 re-park ruling is sound: the refined trigger ("the next CI touch whose OWN scope includes repo-policy enforcement," anchored to `DocPolicy.Tests.ps1`'s graduation-to-a-native-CI-job) is genuinely narrower than the old "First workflow need / likely first code PR" and is anchored to a concrete artifact and event, so it is not vague-enough-to-never-fire. #6 correctly left independent. Prior-art citations mostly true: `docs/templates/repo-policy-check-patterns.md` exists with a §1 Status-line gate (line 11) and a "Running them" section (line 57); `scripts/tests/DocPolicy.Tests.ps1` exists and ports it (header cites the §1 source). See C1R-3 for the one imprecision.

---

### Go quality (first Go in a zero-Go shop)

Reviewed as a Go practitioner. `board.go`, `re2.go`, `testroot_test.go` are idiomatic: `fmt.Errorf` with `%w` wrapping throughout, `t.Helper()` in the helper, `filepath.Base` for stable failure reporting, comments explain WHY not WHAT, exported/unexported boundaries correct, descriptive test names, single-purpose tests with actionable failure messages. `findPatterns`'s recursion faithfully matches its doc comment. Nothing a real-shop Go reviewer would REJECT on. One trivial style note (non-finding): `board_test.go:42` `var doc any = map[string]any{...}` could be `doc := map[string]any{...}` since `Validate` takes `any`; harmless.

---

### Findings (all Minor; none block)

- **C1R-1 (Minor, doc) - `board/web/vendor/cfworker-json-schema/VENDOR.md:42`.** Dead citation: text reads "The probe script (`board/web/vendor/probe-yard-snapshot.mjs`) does this," but the probe actually lives at `board/web/probe-yard-snapshot.mjs` (one directory up, not under `vendor/`). The behavioral claim ("passes 2020-12 explicitly") is true; only the locator is wrong. A stranger following the path lands in the wrong directory. Fix: drop the `vendor/` segment.

- **C1R-2 (Minor, guard coverage) - `board/re2.go:23-39`.** `findPatterns` walks values under the `pattern` KEYWORD only. JSON Schema also carries regexes as the KEYS of `patternProperties` and under `propertyNames`; those are not walked. The spec YB-11 SB-1 standing rule reads "every pattern in every landed schema." No current schema uses `patternProperties`/`propertyNames` (verified: grep returns none across all 3 schemas), so the guard is not currently vacuous or wrong - this is a latent hole, not a present defect. Note for when a schema first introduces those keywords; also note the v6-compile test only compiles `starcar-artifact.schema.json`, so a lookahead in a `patternProperties` key of the other two schemas would currently be caught by neither guard.

- **C1R-3 (Minor, doc precision) - `docs/setup.md` (#3/#4 ruling, commit 6152524).** "that file's own 'Running them' section names the graduation-to-CI-job step as the trigger event for #3/#4/#6 to land together." The "Running them" section exists only in `repo-policy-check-patterns.md:57` (not in `DocPolicy.Tests.ps1`), so the antecedent "that file" is ambiguous given the immediately preceding noun is `DocPolicy.Tests.ps1`. And the section describes graduating to "one CI job, fail-fast... a REQUIRED check on PRs to main" but does not enumerate #3/#4/#6 - the "trigger event for #3/#4/#6 to land together" framing is the car's faithful synthesis, not the source's words. Underlying facts all real; tighten the antecedent and soften "names" to "supports."

---

### Guard check

Two new guards (Go zero-test refusal, RE2 pattern probe) plus the JS non-vacuity assertion. All three were **watched to fire** by the reviewer independently (items 3 and 5 above), not merely read. **Deferred to conductor handback:** the LIVE CI red on both GitHub matrix legs at merge - the guards fire in faithful local `shell: pwsh` simulation, but the actual GitHub Actions run on windows-latest and ubuntu-latest is not observable from this worktree and remains the merge-time obligation.

### Constitution check

- **Law 1 (no confident falsehood):** the zero-test refusal exists precisely so a green-that-asserted-nothing cannot pass; watched to fire. Honored. The lone truth-slip is C1R-1 (a wrong locator).
- **Law 6 (no unowned second copy):** Go version pinned in one place (`board/go.mod`), CI reads it via `go-version-file`; vendored validator's provenance is owned by VENDOR.md (shasum/integrity/byte-identical, all verified). The RE2 probe and jsonschema/v6 both encode RE2-compat knowledge but are complementary (probe walks all schemas; v6 is the real validator), not a maintained duplicate. Honored.
- **Law 7 (the stranger):** heavily honored - setup.md now discloses both toolchains, versions, and the PATH gap; vendored files carry no bare imports so a stranger's browser resolves them with no bundler; the probe runs with no experimental flags and no `npm install`. A stranger with Go and Node but no context CAN run all of this (I did, from foreign cwds). C1R-1's wrong path is a small Law-7 papercut.
- **TDD / red-first:** RE2 probe red-first proven and re-proven by injecting into a real schema; JS non-vacuity executes; zero-test refusal watched red. Honored.
- **Documents rank equal to code / living contracts:** `ci.yml` header comment updated in the same commit (a81b6d4) as the steps it describes; `setup.md` updated in the same commit (6152524). Honored, minus the two Minor citation imprecisions (C1R-1, C1R-3).

All fault injections restored byte-identical; final `git status` clean, HEAD still `6152524e6a6fd2aaad6127bfa5197889e28cb3c7`. I committed nothing and pushed nothing.

```starcar-artifact
outcome: APPROVE
findings: Three Minor, zero Major. C1R-1 (Minor, doc) VENDOR.md line 42 dead citation - cites board/web/vendor/probe-yard-snapshot.mjs but the probe is at board/web/probe-yard-snapshot.mjs. C1R-2 (Minor, guard coverage) board/re2.go findPatterns walks the pattern keyword only, not patternProperties or propertyNames regex keys - latent hole, no current schema uses them so non-blocking. C1R-3 (Minor, doc precision) docs/setup.md #3/#4 ruling has an ambiguous "that file" antecedent (the Running them section lives in repo-policy-check-patterns.md not DocPolicy.Tests.ps1) and overstates that the section names the trigger for issues 3/4/6 to land together.
abstract: Adversarial round-1 review of yard-board Car 1 (first Go in the repo) at HEAD 6152524 against base 2051ffe. All eight car claims independently re-derived by running. go test 4/4 PASS and go vet clean from board dir, repo root, and a foreign cwd (runtime.Caller root resolution holds). Pinned jsonschema v6.0.2 confirmed in go.mod and go.sum, compiles and validates the real store schema. RE2 probe red-first re-proven by injecting a lookahead into the real third schema yard-snapshot.schema.json and watching the checker fail naming the file and pattern, then restoring byte-identical - proves the glob reaches all three schemas. CI Go step extracted via ConvertFrom-Yaml and executed four ways: green exit 0 with 4 tests, tests-removed exit 1 via zero-test refusal while go test itself exited 0, injected failing test exit 1, compile error exit 1 caught by go vet first. Order of checks means a build failure surfaces as red not zero-test confusion; subtest over-count is harmless to a zero-vs-nonzero guard. The issue-20 staleness step if condition is byte-untouched. JS probe passes from both cwds with no experimental flags, all nine vendored files byte-identical to the npm 4.1.1 tarball, shasum and integrity match VENDOR.md exactly, zero bare or builtin imports, non-vacuity delete-lanes check executes. Pester 178/178 at HEAD, working tree clean. setup.md Go and Node rows and the issue 3/4 re-park ruling are sound with a genuinely narrower trigger. Three Minor doc and coverage findings, no Major, APPROVE. Live CI red on both matrix legs at merge is the deferred conductor-handback observation. All fault injections restored byte-identical, committed and pushed nothing.
```