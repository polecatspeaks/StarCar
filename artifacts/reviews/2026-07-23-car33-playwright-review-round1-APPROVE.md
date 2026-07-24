<!-- starcar-integrity: sha256=32a3216e43ee8357bffb4cd799ff9d31653f0130ffe8d9f76f6250a09ce1e1c8 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car 33 (#33 real-browser cascade guard) adversarial sentence-check review, round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-review
Round: 1
Target: `car/33-playwright @ 7fabf8a9abe958e6e516b1e1683ccbcce7185dda`
Base reviewed: `b675062815fc1399edd3714588f5ed81f57a38d`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a21a8117ae140fa72`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `b675062815fc1399edd3714588f5ed81f57a38d` |
| Entire checkpoint | `7763bd440609` |
| Dispatch, the locator within the session | `a21a8117ae140fa72` |
| Entire session (context, NOT a lookup key) | `e92f5a0b-1b9e-4913-98b3-c319b4d5e90b` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain b675062815fc1399edd3714588f5ed81f57a38d
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All verification complete. Worktree byte-identical, HEAD unchanged.

---

# ADVERSARIAL REVIEW — Car 33 (issue #33, real-browser cascade guard)

# VERDICT: **APPROVE**

**0 Major. 3 Minor. 5 Notes.** The central empirical claim reproduces exactly. All three owner amendments are honored in the artifact, not just in the prose. Every guard this diff adds was watched to fire by me, not read about.

Reviewed at HEAD `7fabf8a9abe958e6e516b1e1683ccbcce7185dda`, base `b675062815fc1399edd3714588f5ed81f57a38d`, in the assigned worktree. Diff is exactly the 8 files stated, +499/-7.

---

## 1. Base and scope integrity — the stylesheet was NOT left mutated

The car fault-injected twice into `board/web/css/board.css`. The claim of byte-identical restoration is **proven at the object level**, which is stronger than a diff:

```
git rev-parse b675062:board/web/css/board.css  -&gt;  02bbfdcb6925d4dde104a35200e844e44fdf4231
git rev-parse 7fabf8a:board/web/css/board.css  -&gt;  02bbfdcb6925d4dde104a35200e844e44fdf4231
git rev-parse b675062:board/web/js             -&gt;  eeee59f47a4167a3bc402e7b881b576f3b385e66
git rev-parse 7fabf8a:board/web/js             -&gt;  eeee59f47a4167a3bc402e7b881b576f3b385e66
```

`git diff b675062 7fabf8a -- board/web/css board/web/js` is **empty**. Identical blob and tree SHAs mean no silent leftover mutation is possible. Clean.

---

## 2. THE CENTRAL CLAIM — re-derived by me, both directions

This is the ticket's whole justification, so I ran it rather than trusting the report.

### INJECTION 2 (the `color: inherit` case — issue #35's argument)

`board/web/css/board.css:130` changed from `color: var(--nominal);` to `color: inherit;`:

| Suite | Result | Exit |
|---|---|---|
| `test/register-css.test.js` (the regex-over-text guard) | **`# tests 6 / # pass 6 / # fail 0` — GREEN, blind** | **0** |
| `test/browser-register-cascade.test.js` (the new guard) | **`# tests 2 / # pass 1 / # fail 1` — RED** | **1** |

Verbatim failure text from the new guard:

```
issue #31: the nominal dispatch row (classes 'solari-row register-nominal unassigned')
computed color rgb(255, 74, 58), but board.css's own .register-nominal rule renders as
rgb(217, 213, 201) when nothing overrides it. The row is inheriting color from its
needs-attention lane ancestor (which renders rgb(255, 74, 58)) instead of declaring its own.
```

**The ticket's premise is empirically established.** A text-level guard passes 6/6 while the #31 defect is live; the browser sees it and names it. Note the failure message does the naming work itself — it reports the observed value, the expected value, and the mechanism.

### INJECTION 1 (the primary red — declaration removed entirely)

`color: var(--nominal);` deleted from `.register-nominal`:

| Suite | Result | Exit |
|---|---|---|
| `test/browser-register-cascade.test.js` | `# tests 2 / # pass 1 / # fail 1` — RED, same verbatim message | 1 |
| `test/register-css.test.js` | `# tests 6 / # pass 5 / # fail 1` — also red (a deletion *is* visible to a regex) | 1 |

### Restoration, proven

```
board.css sha256 AFTER restore: DC8F2B68B04874573F97165000D8308B007AB8C56B174E76BAB297C433E15FBA
expected (pristine)           : DC8F2B68B04874573F97165000D8308B007AB8C56B174E76BAB297C433E15FBA
git status --porcelain        : (empty)
git diff HEAD                 : (empty)
HEAD                          : 7fabf8a9abe958e6e516b1e1683ccbcce7185dda
```

**Self-disclosure:** during the wire probe I mis-wrote a `Copy-Item` and briefly left `probe-wire-tmp.mjs` in the worktree root. I removed it in the same turn and re-proved cleanliness (output above). No commit, no push, nothing tracked was altered.

---

## 3. Non-vacuity — I attacked the test; it holds

**It asserts on the real #31 shape, not an accidental one.** The observed row classes under injection were `solari-row register-nominal unassigned` inside `.lane-dispatches` carrying `register-needs-attention`. That is a nominal row inside a needs-attention lane — precisely #31. Not a nominal row in a nominal lane.

**No silent-skip path exists.** Four separate escapes are all closed, and I watched three of them fire:

| Failure mode | Behavior | Observed by me |
|---|---|---|
| No matching element | `waitForSelector` (`:50`) times out in `before` → `hookFailed` | — (covered by same hook path below) |
| Go toolchain absent | `hookFailed`, both tests `not ok`, **exit 1** | **YES** — `could not invoke 'go' to build board/server ... spawnSync go ENOENT` |
| Browser binary absent | `hookFailed`, both tests `not ok`, **exit 1** | **YES** — `browserType.launch: Executable doesn't exist at ...chrome-headless-shell.exe` |
| Dependencies not installed | `not ok 1 - test\browser-register-cascade.test.js`, **exit 1**, other 57 still pass | **YES** — `Cannot find package 'playwright'` |

**The precondition is asserted, not assumed.** `:98-104` fails loudly with a message that classifies itself as an infrastructure problem rather than a fix regression. A test that finds nothing cannot pass here.

**Two assertions, and the second is the backstop.** `:112` (row must equal the nominal probe) and `:120` (row must *not* equal the needs-attention probe). I checked the degenerate case where the probe itself is corrupted by an `inherit`-shaped defect: `:120` still catches it. The pair is robust in both directions.

---

## 4. THE SENTENCE CHECK — full path, every hop, closed empirically

The value is a computed colour. Traced end to end:

| # | Hop | Evidence |
|---|---|---|
| 1 | Disk record `state` | `artifacts/dispatches/*.json` |
| 2 | Go assemble → wire | `board/assemble/assemble.go:103` — `State: d.State` |
| 3 | Freshness → `stale` | `board/server/poll.go:311-332`; `stalenessMs` default 15000 (`board/server/config.go:35`) |
| 4 | Register data | `schema/vocab/board-defs.json:25` — `{"id":"returned","label":"Returned","register":"nominal"}` |
| 5 | Lane register | `board/web/js/render.js:48` — `composeRegister({position, positionDefs, freshness, hasRenderer})` |
| 6 | Row register | `board/web/js/render.js:114` — `stateRegister: describeVocab(d.state, vocab.liveness).register` |
| 7 | Class emission | `board/web/js/dom-writer.js:28-29` `registerClass()`; `:79` lane; `:164` row |
| 8 | CSS declaration | `board/web/css/board.css:128-131` `.register-nominal`; `:23` `--nominal: #d9d5c9`; `:136-139` / `:25` `--needs-attention: #ff4a3a` |
| 9 | Observation | `browser-register-cascade.test.js:92` `getComputedStyle(row).color`, compared at `:112-119` |

**I closed hops 2-4 against the live wire**, not by reading. Fetching `/api/snapshot` from the real spawned binary:

```
LANE dispatches: position=live freshness.kind=stale
  dispatch subject=2026-07-21-design-v0-round1-REJECT state=returned
VOCAB liveness def for 'returned': register=nominal
```

Colour arithmetic confirmed: `#d9d5c9` = `rgb(217, 213, 201)`; `#ff4a3a` = `rgb(255, 74, 58)`. The test asserts on the **end** of the chain (hop 9), which is the point of the ticket.

### Law 6 ruling on the rgb triples — the brief's premise was incorrect, and in the car's favour

&gt; `grep -n "rgb(\|#d9d5c9\|#ff4a3a\|217, 213\|255, 74" board/web/test/browser-register-cascade.test.js` → **NONE**

**There are no hardcoded colour values in the test.** Both ground truths are derived at runtime from the live stylesheet by appending free-floating probe elements to `&lt;body&gt;` (`:77-95`) and reading their computed colour. The `rgb()` triples in the brief come from the car's *report* (observations), not from code. This is the Law 6-correct construction and should be commended, not flagged: no second copy of a value the stylesheet owns, and it self-updates if the palette changes.

---

## 5. Owner's binding amendments — all three honored in the artifact

**(1) Playwright LIBRARY, one runner.** `package.json` `devDependencies: {"playwright":"1.61.1"}`. **No `scripts` block at all** — nothing can shadow bare `node --test`. No `playwright.config`, `vitest`, `jest`, `mocha`, or `karma` file tracked at HEAD. `@playwright/test` appears in exactly three places, all comments stating it is *not* used (`ci.yml:76`, `ci.yml:321`, `browser-register-cascade.test.js:9`). **Honored.**

**(2) Regeneration only, never pixel diffing.** `git grep -niE "pixelmatch|resemble|looks-same|toMatchSnapshot|toHaveScreenshot|pngjs|image.*diff"` → **NONE**. `regenerate-screenshot.mjs` contains zero assertions; it writes a dated candidate and refuses to default-overwrite. **Honored.**

**(3) Real board, real store.** `real-board-server.js:54` builds `./server` and `:111` spawns it with `cwd: REPO_ROOT`. Empirically confirmed — my wire probe returned real committed subjects (`2026-07-21-design-v0-round1-REJECT`). Never a mock, never a fixture page. **Honored.**

---

## 6. Suites — RUN BY ME, observed counts

At `7fabf8a`, observer: this reviewer.

| Suite | Observed | Exit |
|---|---|---|
| `node --test` (from `board/web`, after `npm ci`) | **`# tests 59 / # pass 59 / # fail 0 / # skipped 0`** | 0 |
| `go vet ./...` (from `board/`) | clean | 0 |
| `go test ./... -count=1` (from `board/`) | **5/5 packages `ok`**, 78 distinct test functions | 0 |
| `Invoke-Pester ./scripts/tests` | **Passed=250 Failed=0 Skipped=0 Total=250** | — |

**Pester baseline reconciliation, like with like.** 115 records in `artifacts/`. The diff touches nothing under `artifacts/`, so the base-commit baseline equals the HEAD count: **250 at `b675062` = 250 at `7fabf8a`, delta 0.** No mismatch to report.

### Node count breakdown — the car's +3 explanation is verified exactly

TAP top-level entries, enumerated: 57 named tests + 2 file-level entries for assertion-free files (`ok 6 - test\minidom.js`, `ok 11 - test\support\real-board-server.js`) = **59**. Baseline 56 = 55 named + 1 (`minidom.js`). Car 33 adds **2 genuine assertions + 1 auto-discovered helper file = +3**. Confirmed: `node --test` discovers any `.js` under a `test/` directory, and `real-board-server.js` is counted as a trivially-passing test. **Ruling in Minor 2 below.**

---

## 7. CI correctness

- **`npm ci` before the node test step on both legs:** YES. Single `steps:` list under `strategy.matrix.os: [windows-latest, ubuntu-latest]`. Order is `Set up Go` (`:232`) → Go tests (`:237`) → `npm ci` (`:271`) → cache (`:285`) → playwright install (`:291`) → `node --test` (`:306`). `go` is on PATH before the helper's `go build`. Correct.
- **Cache key:** `playwright-browsers-${{ runner.os }}-${{ hashFiles('board/web/package-lock.json') }}`. Invalidates on lockfile change; **no `restore-keys`**, so a version bump cannot hit a stale partial. The comment's reasoning (browser revision pinned 1:1 to `playwright-core` version, itself pinned in the lock) is sound.
- **Does `--only-shell` install what `chromium.launch()` uses?** **YES — independently confirmed twice.** My missing-browser injection showed Playwright looking for `chromium_headless_shell-1228\chrome-headless-shell-win64\chrome-headless-shell.exe`. And `playwright install --dry-run chromium` (default) lists `chromium-1228` **plus** `chromium_headless_shell-1228` + ffmpeg + winldd, while `--dry-run --only-shell chromium` lists only the latter three. The `~690 MiB → ~274 MiB` reasoning is directionally verified (I measured 273.1 MiB on disk for the `--only-shell` set).
- **Cache path:** the dry-run confirms the real install location is `~\AppData\Local\ms-playwright`, matching `~\AppData\Local\ms-playwright`. Correct.
- **Any path where CI passes while the browser test did not run?** The three realistic ones (install step fails, browser absent, deps absent) all produce a non-zero exit that the existing guard converts to a build failure — **watched, all three**. The one residual path is the guard's floor (Minor 2).

---

## 8. Process hygiene — one real leak, and it is not the one the brief feared

**Processes and ports are clean.** After ~10 suite runs: `Get-Process board-server` → nothing; `Get-NetTCPConnection -State Listen` on ports 4600-4900 → nothing. The `go run` → build-and-spawn switch genuinely fixed the orphaned-grandchild problem. No listener leaks, no cross-run port collision.

**Disk does leak.** See Minor 1.

---

## FINDINGS

### Minor 1 — the temp build directory is never removed; ~10 MiB leaked per run
`board/web/test/support/real-board-server.js:52` creates `mkdtempSync(join(tmpdir(), 'starcar-board-server-'))` per `startRealBoardServer()` call. `stop()` (`:142-152`) kills the child but never removes that directory. **Measured on my box: 21 directories, 181.9 MiB, 10.1 MiB each**, accumulated in one review session. No correctness impact, no cross-run collision (each dir is unique), CI unaffected (ephemeral runners). But the file's own header (`:9-29`) presents process hygiene as PROBED and is silent on the binary. One-line fix (`rmSync(dirname(binPath), {recursive:true, force:true})` in `stop()`), or cache one binary across runs. Non-blocking.

### Minor 2 — the zero-test refusal guard's floor rises from 1 to 2
`test/support/real-board-server.js` is auto-discovered and counted as a passing test with zero assertions (`ok 11 - test\support\real-board-server.js`). `.github/workflows/ci.yml:358` refuses only on `# tests -eq 0`, so a total loss of every real test file would now report `# tests 2` and **pass**. The class is **pre-existing** (`minidom.js` already put the floor at 1 at base) and the car **disclosed** it — credit for both. But this diff measurably deepens a named guard's blind spot, and this repo treats guard degradation as consequential. Cheap fixes: move helpers to `board/web/testsupport/`, or add `--test-exclude`. Non-blocking; worth a ticket.

### Minor 3 — no document states the two commands a stranger now needs
`docs/doc-map.md:70` designates `docs/setup.md` + `CLAUDE.md` as the contributor how-to carrier until a real one exists. The amended `docs/setup.md:31` names `npx playwright install --with-deps --only-shell chromium` and states the lockfile is committed for reproducibility, but never says a stranger must run **`npm ci` in `board/web/`** before `node --test`. `README.md:70-73` lists Go only under Prerequisites. **Why this is Minor and not Major:** no document makes a *false* claim, and I verified the failure is loud and self-diagnosing (`Cannot find package 'playwright' imported from ...browser-register-cascade.test.js`, exit 1, other 57 tests still pass). README's Quickstart describes *running the board*, not the suites, and remains fully true. This is incompleteness on a designated surface, not a lying canary.

### Note 1 — a diagnostic string that is right today by coincidence
`board/web/css/board.css:20` (`--text: #d9d5c9`) and `:23` (`--nominal: #d9d5c9`) are the same value. Under an `inherit`-shaped defect the probe at `:93` returns the *inherited body* colour, which the message at `:116` labels "board.css's own `.register-nominal` rule renders as...". Today those coincide, so the message reads correctly. **The assertions are sound regardless** — I worked both directions — so this is wording, not correctness. Worth knowing if `--text` ever diverges from `--nominal`.

### Note 2 — the old guard gained no back-reference
`browser-register-cascade.test.js:17-26` cites `register-css.test.js` and issue #35. The reverse link does not exist: `register-css.test.js:1-10` still reads as the pin for #31's class with no pointer to the stronger guard. Issue **#35 is OPEN** and correctly tracks the regex weakness, so never-drop is satisfied. Nothing became false; a reader is just less well served.

### Note 3 — the reproduction depends on ambient store age, bounded to 15 seconds
The precondition needs `artifacts/` older than `stalenessMs` (default **15000 ms**, `board/server/config.go:35`). A dispatch record landed within 15 s of a run would flip the lane fresh. When that happens the test fails **loudly with a message that names itself a precondition problem** (`:101-104`), never passes vacuously. A 15-second window is negligible and the handling is exactly right. Recording it so it is not misdiagnosed as a cascade regression if it ever fires.

### Note 4 — the CI changes are asserted, not observed
Cars cannot run GitHub Actions, so no leg of `ci.yml` has executed. Specifically unproven-in-CI: `~` expansion of the Windows cache path under `actions/cache@v4`, and `--with-deps` behaviour on `windows-latest`. Worst case for both is a cache **miss** (cost, not correctness) — neither can make CI falsely pass. **Conductor action required:** watch both legs to a terminal conclusion via `scripts/Watch-CI.ps1` before any merge, per the verification-honesty rule.

### Note 5 — the doc-sweep count is one short; the substance is correct
The car reported three surviving "no build step" hits. I found four: `docs/design/2026-07-21-v0-yard-skeleton-design.md:81` (P4), `:133` (D19), `README.md:84`, and `docs/plans/2026-07-23-yard-board-plan.md:199`. **All four are about the shipped browser runtime and all four remain true** — the car's conclusion is right, only its arithmetic is one low. I swept `docs/`, `.github/`, `README.md`, `board/`, `schema/` independently for `bundler`, `build step`, `npm install`, `no dependencies`, `vendor`, `node_modules`, `package.json`: **no stale claim found. No doc-staleness Major.**

---

## The setup.md amendment — judged against all four owner requirements

Measured mechanically: the new row is **purely additive**. Old row 1260 chars, new 3324; the new row starts with the entire old row minus its trailing ` |` (verified `True`), appending 2064 bytes. Nothing was rewritten.

| Requirement | Verdict | Evidence |
|---|---|---|
| Existing principle applied to a new case, NOT a retraction | **MET** | "apply this row's OWN distinction (\"D19 binds the browser, never Node\") to a new case: Playwright is TEST TOOLCHAIN, on the same side of that line as Node itself" |
| Preserve the still-true shipped-runtime claim | **MET** | "the SHIPPED runtime (`js/`, `css/`, `index.html`) still has no build step, no bundler, and no npm dependency - this row's OWN ... claim (second column) stays true of the runtime". Independently verified true. |
| Name the trigger | **MET** | "gate-triggered by issue #33 (closing the #31 defect class...)" |
| Visible, not a silent rewording | **MET** | Bolded `**Landed (Car 33, issue #33, 2026-07-23):**`, matching the row's existing `**Landed (Car 5...)**` convention; prior text byte-preserved (measured above). |

**Same treatment applied to `ci.yml`:** yes — `:275-282` and `:310-317` both draw the shipped-versus-test line explicitly rather than deleting the old "no build step" comment. `:312` was edited to "no build step **for the SHIPPED view**", which is the honest narrowing.

**Claim audit:** "the FIRST such files in this repo" — verified. `git ls-tree -r b675062 | grep package` is empty; at `7fabf8a` only the two new files exist. True.

---

## Adjudication of the car's disclosed findings

**F1 — WRONG, and I state it plainly.** The car claimed the brief's citation was false and that the `sh`-not-on-PATH probe gap is not logged. **It is logged**, at `docs/friction-log.md:104`, verbatim: *"the PowerShell tool's pwsh has no `sh` on PATH ... `HookLatency.Probes.Tests.ps1:129` (`&amp; sh $hook`) reds locally with CommandNotFoundException while CI is green on identical code at `58fbe23`"*. There is even a second, related row at `:116` for `go.exe`. The brief was accurate; the car raised a false finding against it. Recorded rather than softened — the car appears not to have opened the file, which is the reading-versus-verifying failure this shop names explicitly. No harm done (it changed nothing in the diff), but it is a defect in the report.

**F2 — CORRECT, and correctly reasoned.** The brief stated a 247 Pester baseline; the car observed 250. I observe **250** at both base and HEAD with 115 store records. The car reported an unexplained discrepancy instead of assuming its own run was wrong or quietly reconciling it — that is the right behavior. Not identifying the store-record-dependent mechanism is not a defect; surfacing a number that contradicts the brief is the success outcome here.

**F3 — right call, and the substituted argument is sound.** GitNexus tools were absent from the car's toolset while `CLAUDE.md` mandates `impact` before editing symbols. Disclosing beats silently skipping. The blast-radius substitute is **verifiably correct**: this diff edits **no existing symbol** — `board/web/js` and `board/web/css` are byte-identical by tree SHA, five files are new, and the three modified files (`.gitignore`, `docs/setup.md`, `ci.yml`) contain no symbols. Impact analysis would have had nothing to analyze.

**F4 — defensible, correctly disclosed.** Task 3's `regenerate-screenshot.mjs` landed with Tasks 1/2/4. It *imports* `test/support/real-board-server.js`, so a separate commit would either not stand alone or would duplicate the helper (a Law 6 problem to fix a granularity preference). The chosen coupling is the better trade. Minor process note at most; the disclosure was the right move.

**Screenshot preservation — CORRECT, and doctrinally right.** `git diff --name-only b675062 7fabf8a -- docs/screenshots/` is empty; `2026-07-23-first-light.png` is untouched. That image is the fossil evidence of #31's discovery at first light. **"The showcase never edits the record"** governs directly, and overwriting it would have deleted the artifact that proves the defect was found by a human eye. The script instead writes `{today}-regenerated-candidate.png` and requires an explicit `--out` to target anything else (`:28-38`), with a console line telling the operator to compare by eye and say so in the commit. This is the correct judgment and the correct mechanism for it.

---

## GUARD CHECK — every guard watched to fire

| Guard | Watched? | Evidence |
|---|---|---|
| Browser cascade test catches the `inherit` defect | **YES** | Injection 2: RED, exit 1, verbatim message quoted above |
| Browser cascade test catches a removed declaration | **YES** | Injection 1: RED, exit 1 |
| Text guard is genuinely blind to `inherit` | **YES** | Injection 2: 6/6 GREEN, exit 0 |
| Missing browser fails loudly, never skips | **YES** | `PLAYWRIGHT_BROWSERS_PATH` redirect: `hookFailed`, both `not ok`, exit 1 |
| Missing Go toolchain fails loudly | **YES** | `spawnSync go ENOENT`, `hookFailed`, exit 1 |
| Missing dependencies fail loudly | **YES** | `Cannot find package 'playwright'`, exit 1 |
| `--only-shell` installs what `launch()` uses | **YES** | Two independent observations (error path + `--dry-run` comparison) |

No configuration read-back was accepted in place of an observation.

---

## COST NOTE (measured, as the owner asked)

| Item | Measured |
|---|---|
| `npm ci` packages | **2** (`playwright`, `playwright-core`); npm reports "added 2 packages, and audited 3 packages" |
| `node_modules` on disk | **16.8 MiB**, 175 files |
| `npm ci` wall time | **1.06 s** (warm npm cache; npm's own figure 804 ms) |
| Browser download, `--only-shell` | **273.1 MiB** total — `chromium_headless_shell` 269.5, `ffmpeg` 3.4, `winldd` 0.2 |
| Browser download, default | additionally pulls full `chromium-1228` (`chrome-win64.zip`) — confirmed by `--dry-run`; the ~690 MiB figure is consistent |
| Full `node --test` suite wall time | **4.5 s** for all 59 tests, including `go build` + browser launch |
| CI steady-state added | `npm ci` (seconds) + cache restore; the 273 MiB download is once per OS per lockfile change |

**Judgment: proportionate.** Two packages is close to the minimum viable real-browser dependency, `--only-shell` removes roughly 60% of the download, and the cache key is correct so the steady state is a restore rather than a fetch. 4.5 s of suite time to close a defect class that a human eye had to catch is a good trade. My one cost reservation is Minor 1 (10 MiB of temp binary per local run), which is a one-line fix.

---

## CONSTITUTION CHECK

| Law | Honored? | Evidence |
|---|---|---|
| **1. Truth** | **YES — this diff is Law 1 machinery.** It converts a previously-invisible falsehood into a loud red: 6/6 green under `color: inherit` becomes exit 1 with the observed value named. Watched by me, both injections. |
| **2. The Dispatcher Commands** | YES. All three binding owner amendments honored in the artifact (§5); the mid-dispatch ruling on setup.md was applied as an amendment, not a retraction, meeting all four stated requirements. |
| **3. Actionability** | YES. Failure messages carry the observed colour, the expected colour, the element's class list, and the mechanism — `browser-register-cascade.test.js:115-118`. A reader knows what to fix without re-running. |
| **4. Nothing Silently Lost** | YES, and this is the strongest result. Four absence conditions (no element, no Go, no browser, no deps) all produce loud non-zero exits; three watched directly. No silent-skip path found. |
| **5. Self-Knowledge** | YES. The car disclosed four findings including one against its own brief, and disclosed the +1 count inflation rather than reporting a clean +2. |
| **6. One Truth** | **YES, and better than the brief assumed.** Zero hardcoded colour values in the test; both ground truths are derived from the live stylesheet at runtime (`:77-95`). One `startRealBoardServer` implementation, shared by the test and the screenshot script rather than duplicated. |
| **7. The Stranger** | MOSTLY. `package-lock.json` is committed and pins exact versions with integrity hashes; the browser install command is documented; a missing dependency fails with an actionable message. **Gap at Minor 3** — no document states the `npm ci` step itself. |
| **8. Growth** | YES. The guard is registered in CI on both matrix legs and will run on every push, not left as a local-only capability. |
| **TDD (red-first, non-vacuous, watched)** | **YES.** I re-derived both reds myself rather than accepting the report. The guard was proven non-vacuous by fault injection in two distinct shapes, restored byte-identical, restoration proven by hash and by empty `git status` / `git diff HEAD`. |

**Law-first diagnostic:** the author hit the constraints while writing — the Law 6 probe design, the amendment structure, and the screenshot-preservation judgment were all authored correctly without a reviewer finding them. That is the healthy signal.

---

## Files referenced

- `~/AppData/Local/Temp/claude/C--Users-Chris-git-starcar/e92f5a0b-1b9e-4913-98b3-c319b4d5e90b/scratchpad/review-car33/board/web/test/browser-register-cascade.test.js`
- `~/AppData/Local/Temp/claude/C--Users-Chris-git-starcar/e92f5a0b-1b9e-4913-98b3-c319b4d5e90b/scratchpad/review-car33/board/web/test/support/real-board-server.js`
- `~/AppData/Local/Temp/claude/C--Users-Chris-git-starcar/e92f5a0b-1b9e-4913-98b3-c319b4d5e90b/scratchpad/review-car33/board/web/regenerate-screenshot.mjs`
- `~/AppData/Local/Temp/claude/C--Users-Chris-git-starcar/e92f5a0b-1b9e-4913-98b3-c319b4d5e90b/scratchpad/review-car33/board/web/package.json`
- `~/AppData/Local/Temp/claude/C--Users-Chris-git-starcar/e92f5a0b-1b9e-4913-98b3-c319b4d5e90b/scratchpad/review-car33/.github/workflows/ci.yml`
- `~/AppData/Local/Temp/claude/C--Users-Chris-git-starcar/e92f5a0b-1b9e-4913-98b3-c319b4d5e90b/scratchpad/review-car33/docs/setup.md`
- `~/AppData/Local/Temp/claude/C--Users-Chris-git-starcar/e92f5a0b-1b9e-4913-98b3-c319b4d5e90b/scratchpad/review-car33/board/web/css/board.css`
- `~/AppData/Local/Temp/claude/C--Users-Chris-git-starcar/e92f5a0b-1b9e-4913-98b3-c319b4d5e90b/scratchpad/review-car33/docs/friction-log.md` (line 104, F1)

**Reviewer state:** nothing edited, nothing committed, nothing pushed. Worktree byte-identical at `7fabf8a`, `git status --porcelain` empty, `git diff HEAD` empty. The 21 leaked temp build directories were removed from my OS temp after measurement (they are outside the repo). The shared checkout at `<repo>` was read only once, for `gh issue view`.

```starcar-artifact
outcome: APPROVE

findings: 0 Major, 3 Minor, 5 Notes. MINOR-1 real-board-server.js:52 mkdtempSync build directory is never removed; stop() at :142-152 kills the process but not the directory. Measured 21 dirs and 181.9 MiB, 10.1 MiB per run. No correctness impact, no port or process leak (verified zero board-server processes and zero listeners on 4600-4900 after ten runs), CI unaffected on ephemeral runners. MINOR-2 test/support/real-board-server.js is auto-discovered by node --test and counted as a zero-assertion passing test (observed ok 11), raising the ci.yml:358 zero-test refusal floor from 1 to 2, so total loss of every real test file would report 2 and pass; class pre-exists via minidom.js and the car disclosed it, so non-blocking. MINOR-3 no document states that a stranger must run npm ci in board/web before node --test; docs/setup.md:31 names the browser install command and doc-map.md:70 designates setup.md as the contributor how-to carrier; mitigated because the failure is loud and actionable, verified as Cannot find package playwright with exit 1 and the other 57 tests still passing. NOTE-1 board.css:20 --text and :23 --nominal are the same value so the probe diagnostic string at :116 is correct today only by coincidence; assertions sound in both directions regardless. NOTE-2 register-css.test.js gains no back-reference to the stronger guard; issue 35 remains OPEN and correctly tracks it. NOTE-3 the reproduction depends on ambient store age bounded by stalenessMs default 15000 ms at board/server/config.go:35, and fails loud with a self-naming precondition message rather than passing vacuously. NOTE-4 the ci.yml changes are asserted not observed since cars cannot run Actions; conductor must watch both legs to terminal green before merge; worst case for the unverified Windows cache path expansion is a cache miss, never a false pass. NOTE-5 the car reported three surviving no-build-step doc hits where I found four, all four still true, arithmetic one low and substance correct. ADJUDICATIONS. F1 is WRONG, stated plainly: the sh-not-on-PATH gap IS logged at docs/friction-log.md:104 verbatim with a related go.exe row at :116, so the brief citation was accurate and the car raised a false finding, apparently without opening the file. F2 is CORRECT and correctly reasoned: Pester observed 250 at both base and HEAD with 115 store records, and reporting an unexplained discrepancy rather than reconciling it quietly was the right behavior. F3 was the right call and the substituted blast-radius argument is verifiably sound because the diff edits no existing symbol, proven by identical tree SHAs for board/web/js and board/web/css. F4 commit granularity is defensible since regenerate-screenshot.mjs imports the shared helper and splitting would have duplicated it. The refusal to overwrite docs/screenshots/2026-07-23-first-light.png is CORRECT and doctrinally right under the showcase never edits the record; the file is untouched and the script writes a dated candidate requiring an explicit --out.

abstract: Adversarial sentence-check review of Car 33, commit 7fabf8a9abe958e6e516b1e1683ccbcce7185dda against base b675062815fc1399edd3714588f5ed81f57a38d, 8 files plus 499 minus 7. Verdict APPROVE with zero Major. The ticket central claim was re-derived by me, not read: injecting color inherit at board/web/css/board.css:130 leaves register-css.test.js GREEN at tests 6 pass 6 fail 0 exit 0 while browser-register-cascade.test.js goes RED exit 1 quoting observed rgb 255 74 58 against expected rgb 217 213 201; the primary red, deleting the declaration entirely, also goes RED with the same message. Both injections restored byte-identical, proven by sha256 DC8F2B68B04874573F97165000D8308B007AB8C56B174E76BAB297C433E15FBA matching pristine plus empty git status --porcelain and empty git diff HEAD. The car claim that it left the stylesheet unmutated is proven at object level: board/web/css/board.css blob SHA and the whole board/web/js tree SHA are identical at base and HEAD. Suites run by me at HEAD: node --test 59 tests 59 pass 0 fail exit 0; go vet clean and go test ./... -count=1 5 of 5 packages ok with 78 distinct test functions; Pester 250 passed 0 failed 250 total with 115 store records, equal to the base baseline since the diff touches nothing under artifacts, so delta zero. The plus 3 node count is verified exactly as 57 named tests plus 2 assertion-free helper file entries. Non-vacuity attacked and held: the test asserts on the real issue 31 shape, observed classes solari-row register-nominal unassigned inside a needs-attention dispatches lane, and four absence conditions all fail loudly with three watched directly by me, namely missing browser via a PLAYWRIGHT_BROWSERS_PATH redirect producing hookFailed and exit 1, missing Go producing spawnSync go ENOENT and exit 1, and missing dependencies producing Cannot find package playwright and exit 1. All three owner amendments honored in the artifact: devDependency is the playwright library with no scripts block and no second runner config anywhere, at-playwright-slash-test appearing only in comments saying it is not used; zero image comparison dependencies and zero assertions on image bytes; the real Go binary spawned against the real store, confirmed by fetching the live wire and seeing real committed dispatch subjects. Full sentence check traced across nine hops with file:line from disk record through assemble.go:103, poll.go:311-332 freshness, board-defs.json:25 register nominal for returned, render.js:48 and :114, dom-writer.js:79 and :164, board.css:128-131 and :23 and :136-139 and :25, ending at getComputedStyle in the test at :92 and :112-119, with hops 2 through 4 closed empirically against a live snapshot showing freshness stale and register nominal. The brief premise that the test hardcodes rgb triples is incorrect and in the car favour: grep finds no color literals, both ground truths are derived at runtime from the live stylesheet by free-floating probe elements, which is the Law 6 correct construction. The docs/setup.md amendment meets all four owner requirements, verified mechanically as purely additive with the old 1260 char row preserved and 2064 bytes appended, and the same treatment was applied to the ci.yml step comments. Independent sweep of docs, .github, README, board and schema found no stale or now-false claim about dependencies, bundlers, build steps or vendoring, so no doc-staleness Major. Cost measured for the owner: 2 packages, 175 files, 16.8 MiB node_modules, npm ci 1.06 s, browser 273.1 MiB under --only-shell versus a default that additionally pulls full chromium as confirmed by a dry-run comparison, and a 4.5 s full suite; judged proportionate. Reviewer edited nothing, committed nothing, pushed nothing; one self-disclosed slip where a scratch probe file was briefly copied into the worktree root was removed in the same turn with cleanliness re-proven.
```