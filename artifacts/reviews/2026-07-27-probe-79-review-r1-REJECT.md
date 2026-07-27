<!-- starcar-integrity: sha256=cbcb595d169d9cfecc98135dd21ea2e93813d2ba701558f1ebe44cc94d1cc7cc covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Probe #79 manifest-to-board join pinning, review round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review
Round: 1
Target: `car/probe-79 HEAD c1c4d2d`
Base reviewed: `82bfb6e0938fb552b51f759c1e6ee2af622dadc8`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `af1b76cf7eab52dc7`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `82bfb6e0938fb552b51f759c1e6ee2af622dadc8` |
| Entire checkpoint | `41c5a5bef3e3` |
| Dispatch, the locator within the session | `af1b76cf7eab52dc7` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 82bfb6e0938fb552b51f759c1e6ee2af622dadc8
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: **REJECT** — 1 Major, 3 minor, 2 nits

The probe is *sound where it counts*: I broke the **product** five different ways and it red by name every time. The Major is a documentation defect in the artifact's own WHY-THIS-EXISTS header — a coverage claim that a landed, passing Go test in this same repo contradicts.

## BASE-DELTA (#13)

- Worktree `<repo>-wt\review-probe-79`, HEAD `c1c4d2dcee4023f721f2d5d433fe3bc2f3583dc1` (detached, `car/probe-79`), `git status --porcelain` **empty** before and after this review.
- Base `82bfb6e0938fb552b51f759c1e6ee2af622dadc8`. `git diff 82bfb6e..c1c4d2d --stat`:
  ```
  docs/friction-log.md                              |  31 ++
  scripts/probes/ManifestBoardJoin.Probes.Tests.ps1 | 380 ++++++++++++++++++++++
  2 files changed, 411 insertions(+)
  ```
- `git diff --name-only` confirms **nothing under `board/`, `schema/`, or `scripts/tests/` was touched**.
- File sha256 `b21e0c5eb4b6c7c341d9735289bb1b2573132f4996173e6ffca18559263b3599` — matches the car's reported base hash exactly, and is **unchanged at the end of this review** (I edited nothing; all injection was done on copies outside the repo).

## Suites, run by me

| Suite | Observed | Car claimed |
|---|---|---|
| `Invoke-Pester ./scripts/probes` | **29 passed / 0 failed / 0 skipped** (16.79s) | 29/29 ✓ |
| `Invoke-Pester ./scripts/tests` | **222 passed / 0 failed / 5 skipped** | 223/0/4 |
| `./scripts/tests/CodeCitationPolicy.Tests.ps1` (#42) | **13 passed / 0 failed** | green ✓ |
| `go test ./server -run TestAssembledSnapshotValidatesAgainstWireSchema` | **PASS (0.02s)** | not mentioned — see R1-M1 |

The one-test delta is the predicted detached-HEAD shift, **identified by name**: `scripts/tests/SessionStartGuardRunner.Tests.ps1 :: running the REAL guards prints [ci-baseline]'s marker ONLY when attached to a branch — conditional, never asserted as always-emitting`. Totals reconcile: 227 tests both ways. The car's 223/4 is consistent.

---

## FINDINGS

### R1-M1 (MAJOR) — the header's coverage claim is false; a landed Go test already asserts much of this join

`scripts/probes/ManifestBoardJoin.Probes.Tests.ps1`, WHY-THIS-EXISTS paragraph (lines 13-17):

&gt; "Today nothing asserts that join mechanically: the existing Go tests (`board/assemble/assemble_test.go`) cover `Assemble()` in isolation with constructed `fold.Output`/`store.Record` values, never the real server reading a real store over HTTP."

Opened the file the claim is about. `board/server/wireschema_test.go:20-152` (`TestAssembledSnapshotValidatesAgainstWireSchema`):

1. `wireschema_test.go:21-52` writes a **PLAN-shaped manifest with members** (`carA` role `car`; `gate-1` role `gate`, gate name `design review round 1`) plus a dispatched and a returned record — via `writeRecord` → `os.WriteFile` (`board/server/poll_test.go:23-32`), i.e. **real files on disk** in `t.TempDir()`, not constructed structs.
2. `wireschema_test.go:62` calls `srv.PollOnce(now)`, and `board/server/poll.go:253` is `scanResult, scanErr := s.adapter.Scan(s.cfg.StorePath, now)` — the **real store scan → fold → assemble** pipeline.
3. `wireschema_test.go:129-137` asserts the **gates lane has exactly 1 gate** with its `RecordDir` and `Findings`; `:112-123` asserts the **trains lane has 1 train with 2 manifest tickets** and `carA.RecordDir`. Both require the manifest-member → dispatch join to work.
4. It passes today: `--- PASS: TestAssembledSnapshotValidatesAgainstWireSchema (0.02s)`.

So "nothing asserts that join mechanically" is false, and the parenthetical that names `assemble_test.go` as "the existing Go tests" with "constructed" values is false of `wireschema_test.go`. Note issue #79's own text states the accurate, narrower claim — *"no test drives the real server over a real store and asserts the four rendered properties **together**"* — and the landing flattened it into an absolute. This is Law 1 territory on the durable record: a future reader deciding whether this probe is the only guard (it is not, for gates/trains rendering), or whether `wireschema_test.go` is redundant (it is not), is misled either way.

Fix is one paragraph, and it makes the case *stronger*: what this suite adds over `wireschema_test.go` is real HTTP `/api/snapshot`, the verdict word and gate name verbatim, per-member `role`/`state`/`outcome`, `declaredNotObserved`, `assigned:true`, and the zero-conditions guard — **together**, from a pwsh-sealed store.

### R1-m1 (minor) — the non-vacuity block miscounts its own evidence

Line 45-46 says "see this car's dispatch report for **the four** quoted red messages", then enumerates **five** injections `(a)`-`(e)` immediately below. The commit message says "five quoted failure messages". Five is correct (I re-derived all five). A record that miscounts its own evidence invites the reader to assume one was dropped.

### R1-m2 (minor) — this suite runs in CI **today**, and the brief's premise that it does not is false

The brief states "scripts/probes is NOT yet wired into CI (#10 is open)". Disproved:

- `.github/workflows/ci.yml:214-228`, step **"Run substrate-floor probes"**: `$result = Invoke-Pester -Path ./scripts/probes -PassThru -Output Detailed`, `if ($result.FailedCount -gt 0) { exit 1 }`.
- `.github/workflows/ci.yml:113-117`: matrix `os: [windows-latest, ubuntu-latest]` — **both legs**.
- `.github/workflows/ci.yml:263-266` "Set up Go (board/)" runs **49 lines and four steps AFTER** the probes step.

So the merge of this commit puts a **Go toolchain + network dependency into the substrate-floor step, before Go is set up**, unretried (contrast the Pester install at `ci.yml:181-191`, which has 3 retries by explicit scar). Measured consequences:

- If `go` is absent, the suite does **not** skip — it hard-fails. Simulated (both candidates pointed at nonexistent binaries): **Passed=0 Failed=5** → `FailedCount &gt; 0` → `exit 1` at `ci.yml:224`.
- It is *probably* fine: the ubuntu-24.04 image build script symlinks the default Go into `/usr/bin` (`actions/runner-images` `images/ubuntu/scripts/build/Configure-Toolset.ps1`: `go = @{ command = "ln -s {0}/bin/* /usr/bin/" }`, with `toolset-2404.json` Go `"default": "1.24.*"`), and windows-2025 lists `Go 1.24.13` under Language and Runtime. Both are **1.24.13**, while `board/go.mod` requires `go 1.26` → `GOTOOLCHAIN=auto` fires. Verified locally that auto-download is attempted, not refused: `go: downloading go1.99.0 (windows/amd64)`.
- Cost: measured a **cold-cache `go build ./server` at 16.6s** (fresh `GOCACHE`+`GOMODCACHE`, real module download) on top of a ~70-100 MB toolchain fetch, on every run of the floor step. The workflow restores no Go cache at all (`setup-go` logs `Restore cache failed: Dependencies file is not found ... Supported file pattern: go.sum` — `go.sum` lives at `board/go.sum`).

Unproven on either leg; that is the honest state, and it is the conductor's call whether to move the probes step after `setup-go` or accept the cost knowingly.

### R1-m3 (minor) — the seal is correct but is **not a guarded property**, and the header invites the opposite reading

Law 6 is honored (see ruling 3). But measured: replacing the digest with `'sha256:' + ('0'*64)` — a syntactically valid, semantically wrong seal — leaves the suite **5 passed / 0 failed**. Cause traced: nothing in `board/` recomputes the digest (`board/store/store.go:131` declares `Integrity string` and no recompute exists in the package), and `schema/starcar-artifact.schema.json:100-104` only pattern-checks `^sha256:[0-9a-f]{64}$`. The board's own `wireschema_test.go:29` uses an all-zero placeholder for exactly this reason. So **if the shop's canonicalisation rule changed, this probe would silently keep passing** — it pins the join, never the seal. No false statement is written, but the Law-6 comment at lines 99-101 sits directly over the sealing helper and reads as though the hash is load-bearing. One sentence of scope fixes it.

### Nits

- **R1-n1**: the PROBED FACTS enumeration of `typedRecord`'s fields (lines 34-36) claims "every field `Produce-Artifact.ps1` writes" and omits `producer`, which the fixture does write (`DispRec`/`RetRec`) and which `typedRecord` does declare.
- **R1-n2**: the non-vacuity evidence is deferred to "this car's dispatch report", an artifact outside the repo; both exemplar probe headers cite in-repo documents instead. Mitigated by the injection parameters living in the file (which is why I could re-derive all five in minutes).

---

## THE FIVE QUESTIONS, RULED

### 1. Non-vacuity — re-derived, and extended to the PRODUCT. **PASS (this is the ticket's whole point, and it holds).**

All five fixture injections re-derived on **copies outside the repo** (so the worktree took zero writes — stronger than byte-identical restore; final hash confirms `b21e0c5e…`):

| Inj | Fault | Observed |
|---|---|---|
| (a) | `$GateARole` `gate`→`car` | gates test red: *"Expected 1, because exactly one member (gateA) is role=gate with a returned record…, but got 0"* (+ trains test red) |
| (b) | `$EmptyMembers = $true` | 4 red, incl. *"Expected a value, because carA is a declared member with a dispatched+returned record, but got $null or empty"* |
| (c) | `$IncludeGateBMember = $false` | 1 red: *"Expected 'gateB' to be found in collection $null…"* |
| (d) | `$IncludeCarBMember = $false` | 2 red, incl. *"Expected $true, because carB is claimed by train:probe-79's manifest membership, but got $false"* |
| (e) | `$SecondManifestClaimsCarA = $true` | guard red: *"Expected 0, because observed board conditions: manifest-membership-collision, but got 1"* |

Then the stronger form the brief asked for. I built an out-of-repo copy of the checkout (`%TEMP%\alt-repo-79`, `git init`, board/schema/config/scripts/artifacts), baselined the **unmodified** probe against it (5 passed / 0 failed), then broke `board/assemble/assemble.go` itself and rebuilt the real server from the altered source — each restored byte-identical (`852870A2D219AB67` → `852870A2D219AB67`, verified per run):

| Product injection | Observed |
|---|---|
| `m.Role == "gate"` → `"reviewer"` (the exact #76 vocabulary-drift class) | gates test red, *"got 0"* |
| `train.DeclaredNotObserved = append(...)` deleted | declaredNotObserved test red |
| `assignedSubjects[m.Subject] = true` → `_ = m.Subject` | assigned test red |
| `if d.State == "returned" { car.Outcome = ... }` neutered | trains test red, *"Expected 'done', but got $null"* |
| gate name `m.Gate` → `m.Role` | gates test red on the verbatim name |

**Five real regressions in the join, five named reds.** These assertions guard the product, not the fixture.

### 2. The zero-conditions guard. **PASS — it does exactly its job, on the real observed failure mode.**

Breaking the sealing (`New-Sealed` no longer writes `integrity`, reproducing the conductor's own first-attempt failure) gives **0 passed / 5 failed**, and the guard names the cause verbatim: *"observed board conditions: record-quarantined, record-quarantined, record-quarantined, record-quarantined, record-quarantined, record-quarantined, all-records-quarantined, but got 7"*. Traced to `board/store/store.go:204-213` (per-record `record-quarantined`) and `:220-228` (`all-records-quarantined`). Injection (e) proves the complementary case: four assertions pass, the guard alone reds. A silent quarantine cannot make this suite green. (Its one blind spot is R1-m3.)

### 3. Sealing reuses the one rule (Law 6). **PASS on the requirement; see R1-m3 for scope.**

Probe line 75 `Import-Module (Join-Path $script:RepoRoot 'scripts/Artifact.psm1') -Force`; line 105 `$Record['integrity'] = 'sha256:' + (Get-Sha256Hex $bodyJson)` over `ConvertTo-Json -Depth 20 -Compress`. `scripts/Produce-Artifact.ps1:364-365` is byte-for-byte the same idiom over the same imported function (`Produce-Artifact.ps1:90` notes Artifact.psm1 is the one owner). `Get-Sha256Hex` is declared THE ONE OWNER at `scripts/Artifact.psm1:124-141`. `grep` across `scripts/` finds exactly one other copy — `Migrate-Verdicts.ps1:42` — which Artifact.psm1's own docstring already declares out of scope. **No second copy introduced.**

### 4. No debris, no leak (#43). **PASS — measured, not assumed.**

Baseline before: zero `mbj-probe-*` dirs; a developer's board (PID 7180) listening on **4600**. After a full 29-test suite run, **10 injected runs**, and **3 concurrent runs**: zero `mbj-probe-*` directories, zero `board-server-probe.exe` anywhere under `%TEMP%`, zero orphan processes, PID 7180 untouched, repo clean. Mid-suite failure teardown tested directly (forced `Wait-FirstPoll` to fail *after* the server was started → 5 red): **`AfterAll` still ran — no leftover dir, no orphan server.** The `go run`-style stranded-child hazard does not apply: this suite builds an explicit binary and starts it as a direct child, so `Process.Kill()` reaches the actual listener.

### 5. Determinism and CI-readiness. **PASS on determinism; QUALIFIED on CI (R1-m2).**

- **Honest readiness wait, no bare sleep:** it parses the server's own `listening on http://…` line (`board/server/main.go:70`) with a 20s deadline, then polls `/api/snapshot` until `seq &gt;= 1`, and on timeout throws a message carrying the last observation. `Start-Sleep` appears only as a 50/100 ms poll interval, never as the gate.
- **Port:** `STARCAR_PORT=0` → `board/server/config.go:80` → `board/server/main.go:51` `net.Listen`. Observed live: the probe bound **`http://127.0.0.1:53991`** while 4600 was occupied. Three concurrent runs: **5/5, 5/5, 5/5**, no collisions, no debris.
- **Teardown on failure:** proven above.
- **Cross-platform:** `Join-Path` throughout, `[System.IO.Path]::GetTempPath()`, `Register-ObjectEvent`, `ProcessStartInfo` with `UseShellExecute=false` — all portable. The `.exe` suffix and the `C:\Program Files\Go\bin\go.exe` fallback candidate are inert on Linux (`Get-Command` on a nonexistent path with `-EA SilentlyContinue` returns nothing). No hardcoded PATH separator, no exec-bit dependency. **The 2026-07-24 ubuntu-leg Major class does not repeat here.**
- **CI:** ready in mechanism, unproven in the environment, and already exposed — see R1-m2.

---

## Friction-log entries — opened the code, tested the claims

**Entry 1 (runspace crash): TRUE, reproduced verbatim.** I wrote the raw-delegate form the entry says is fatal and ran it in a child pwsh: exit code `-532462766` (0xE0434352) and

&gt; `Unhandled exception. System.Management.Automation.PSInvalidOperationException: There is no Runspace available to run scripts in this thread. … The PowerShell process will exit.`
&gt; `at System.Diagnostics.AsyncStreamReader.FlushMessageQueue(...)` → `ThreadPoolWorkQueue.Dispatch()`

The entry's mechanism (threadpool thread, no runspace), its consequence (the whole host dies, not one test), and its remedy (`Register-ObjectEvent`, engine event queue) are all accurate, and the landed code at lines 236-241 is the exemplar it claims to be. **Class-level, correctly generalized, genuinely reusable.**

**Entry 2 (delete-lock): not reproduced in 20 attempts, but not contradicted.** I ran 10 iterations of kill → `WaitForExit` → immediate `Remove-Item -ErrorAction Stop`, then 10 more with the faithful `Register-ObjectEvent` + `BeginOutputReadLine` shape: **0 of 20 locked**. The entry says a just-killed process *can* lock its own `.exe` — a transient, and "can" is not falsified by 20 clean runs. The class lesson (never a silently-swallowed single-attempt delete in cleanup; `SilentlyContinue` turns a transient into invisible permanent debris) is correct and cheap regardless of mechanism, and the 10×300ms retry with a final `Write-Warning` (lines 311-323) honors Law 4. **Not a finding**; recorded so the reproduction count is on the record.

## Doc check

- **`docs/setup.md:48` ("Probe suite in CI") — the car's ruling that it needs no edit is CORRECT on the question asked**: the row makes no count claim and no claim this landing invalidates. Ruled: no edit owed by this commit.
- **Separately, and NOT against this car**: that row is stale on its own terms — it sits in the trigger-gated (deferred) table saying "Wire `Invoke-Pester -Path ./scripts/probes` … Tracked as #10", while `ci.yml:214-228` already does exactly that, and **#10 is still OPEN** with item 1 landed. Pre-existing at base `82bfb6e`; a lying canary that materially misled this dispatch's own brief. Conductor's to fix.
- `docs/doc-map.md:57` covers `docs/probes/*` (measurement records), not `scripts/probes/` — no count claim invalidated. No other living doc enumerates `scripts/probes` counts (the `docs/plans/*` figures are dated fossils with coordinates).
- **#42 citation check**: the new file carries bare `#79` (7 occurrences) and the right number; `CodeCitationPolicy.Tests.ps1` **13/13 green**. Line-number citations in the header point only at files this commit does *not* edit (`config.go:100`, `main.go:51/70`, `store.go:113-134`, `assemble.go:124`, `Produce-Artifact.ps1:363-365`) — I opened every one and **all resolve to what is claimed**.

## Constitution check

| Law / rule | Evidence |
|---|---|
| **#40 — a guard nobody watched fire is decoration** | Governing law, and satisfied: I watched it fire 10 times (5 fixture, 5 product), plus the guard on a quarantined store and on a collision. |
| **Law 1 — no confident falsehood on any surface** | **VIOLATED**: R1-M1, the header's "nothing asserts that join mechanically", disproved by `board/server/wireschema_test.go:20-152` passing today. |
| **Law 6 — one owner per rule** | Honored: `Get-Sha256Hex` imported from `scripts/Artifact.psm1:124`, identical idiom to `Produce-Artifact.ps1:364-365`; no new copy (`grep` across `scripts/`). |
| **Law 4 — never silently dropped** | Honored: cleanup retry ends in `Write-Warning` naming the path and #43; `Wait-FirstPoll` throws carrying its last observation; `Start-BoardServerAgainst` throws "honest could-not-observe" rather than hanging. |
| **Law 7 — the stranger** | Honored: Go dependency declared in the file header and already in `docs/setup.md:31` (including the "not on every shell's PATH" gap the two-candidate lookup answers). No operator home path in the diff. |
| **Probe doctrine (NO HEADERS HERE)** | Honored in form — the perishable #76 probe is now a pinned, one-command, named-consumer Pester suite. Qualified by R1-m3: the sealing rule it invokes is not itself pinned. |
| **Documentation ranks equal to code** | The Major and two of three minors are documentation defects, held to the code standard. |
| **#43 no-debris** | Honored, measured across 14 runs. |
| **#42 code citation** | Honored; gate green. |
| **#13 base-delta / unreproducible evidence** | Stated below. |

## UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

- **The CI legs were not run.** I cannot push, so no leg of `ci.yml` executed this suite. The ubuntu/windows Go-availability reasoning in R1-m2 rests on (i) `actions/runner-images` `Configure-Toolset.ps1` and `toolset-2404.json` fetched at the exact image refs named in run `30270468531`'s own log, and (ii) local simulations (no-Go → 5 failed; `GOTOOLCHAIN` auto-download attempted). **Documentary + simulated, not observed in CI.** I formed the hypothesis "this reds the ubuntu leg" and the evidence **disproved** it — recording both directions rather than the conclusion I started with.
- **The delete-lock (friction entry 2) was not reproduced** in 20 attempts; the entry stands unfalsified, not confirmed.
- **My fault injection touched no repo file.** All work ran on copies in `%TEMP%`; the product injections ran against an out-of-repo checkout copy, each restored byte-identical and the copy deleted. Final state: worktree at `c1c4d2d`, `git status --porcelain` empty, probe file sha256 `b21e0c5e…3599` unchanged.

## What a fix round needs (same car, delta re-review)

1. **R1-M1**: rewrite the WHY-THIS-EXISTS paragraph to name `board/server/wireschema_test.go:20-152`, state precisely what it *does* assert (gates lane count/RecordDir/Findings, trains count/tickets/carA RecordDir, from a real on-disk store via `PollOnce`) and what it does *not* (HTTP, `outcome` verbatim, per-member role/state, `declaredNotObserved`, `assigned`, zero-conditions — the four properties together). Issue #79's own wording is the accurate model.
2. **R1-m1**: "four" → "five".
3. **R1-m2**: one line disclosing that `ci.yml:214-228` already runs this directory on both legs before `setup-go`, and what that costs; conductor decides whether to reorder the step.
4. **R1-m3**: one sentence scoping the seal — realistic and Law-6-correct, but not a guarded property (measured: an all-zero digest passes 5/5).
5. **R1-n1/n2**: add `producer` to the field list; optionally point the non-vacuity note at the fixture parameters (which is what makes it re-derivable) rather than only at the dispatch report.

Files: `<repo>-wt\review-probe-79\scripts\probes\ManifestBoardJoin.Probes.Tests.ps1`, `<repo>-wt\review-probe-79\board\server\wireschema_test.go`, `<repo>-wt\review-probe-79\.github\workflows\ci.yml`, `<repo>-wt\review-probe-79\docs\setup.md`, `<repo>-wt\review-probe-79\docs\friction-log.md`.

```starcar-artifact
outcome: REJECT
findings: 1 Major, 3 minor, 2 nits. R1-M1 (MAJOR, Law 1, scripts/probes/ManifestBoardJoin.Probes.Tests.ps1 WHY-THIS-EXISTS lines 13-17): the claim "Today nothing asserts that join mechanically: the existing Go tests (board/assemble/assemble_test.go) cover Assemble() in isolation with constructed fold.Output/store.Record values" is false - board/server/wireschema_test.go:20-152 writes a manifest with car and gate members plus records as REAL files (writeRecord, board/server/poll_test.go:23-32, os.WriteFile) into t.TempDir(), runs srv.PollOnce (board/server/poll.go:253 s.adapter.Scan of the real store), and asserts the gates lane has exactly 1 gate with RecordDir and Findings (:129-137) and the trains lane has 1 train with 2 manifest tickets and carA RecordDir (:112-123); it passes today, observed PASS in 0.02s. Issue #79's own text carries the accurate narrower claim (no test asserts the four rendered properties TOGETHER) and the landing flattened it into an absolute. R1-m1 (minor): line 45 says "the four quoted red messages" while five injections (a)-(e) are enumerated below and the commit message says five. R1-m2 (minor): the brief's premise that scripts/probes is not in CI is DISPROVED - .github/workflows/ci.yml:214-228 runs Invoke-Pester -Path ./scripts/probes on both matrix legs (ci.yml:113-117) and exits 1 on any failure, forty-nine lines BEFORE Set up Go at ci.yml:263, so this commit puts an unretried Go toolchain plus network dependency into the substrate-floor step; simulated no-Go gives Passed=0 Failed=5 (a hard red, never a skip); both runner images ship Go 1.24.13 while board/go.mod requires go 1.26, so GOTOOLCHAIN auto-download fires (verified locally, go: downloading go1.99.0), costing a toolchain fetch plus a measured 16.6s cold-cache build every run; unproven on either leg. R1-m3 (minor): the seal is Law-6 correct but is not a guarded property - replacing the digest with sha256 plus sixty-four zeros leaves the suite 5 passed 0 failed, because nothing in board/ recomputes it (board/store/store.go:131 declares Integrity only; schema/starcar-artifact.schema.json:100-104 pattern-checks alone), so a canonicalisation change would silently keep passing. R1-n1: the typedRecord field enumeration omits producer, which the fixture writes. R1-n2: non-vacuity evidence is deferred to a dispatch report outside the repo. SEPARATE, pre-existing, NOT against this car: docs/setup.md:48 still lists the probes-in-CI wiring as deferred and tracked as open issue #10 while ci.yml:214-228 already implements it - a stale row that misled this dispatch's own brief.
abstract: Adversarial sentence-check review of c1c4d2d (base 82bfb6e), two files, 411 insertions, nothing under board/ schema/ or scripts/tests/ touched. Ran everything myself at the detached HEAD: scripts/probes 29 passed 0 failed 0 skipped; scripts/tests 222 passed 0 failed 5 skipped, the single delta from the car's 223/4 identified by name as SessionStartGuardRunner.Tests.ps1's branch-attached ci-baseline case (227 tests both ways); CodeCitationPolicy 13/13 green with bare #79 present. Non-vacuity re-derived and then pushed past the fixture: all five of the car's fixture injections reproduced with their named reds, and five further injections made to the PRODUCT itself - board/assemble/assemble.go's gate-role test, the declaredNotObserved append, assignedSubjects, the returned-outcome branch, and the gate-name source - each rebuilt into a real server from an out-of-repo checkout copy and each producing exactly one named red, with the source restored byte-identical every time (852870A2D219AB67 both directions). The zero-conditions guard was tested against the conductor's real observed failure mode: an unsealed store gives 0 passed 5 failed and the guard names record-quarantined six times plus all-records-quarantined. Debris audited across fourteen runs including three concurrent ones and one forced mid-suite failure: zero scratch directories, zero stray binaries, zero orphan listeners, and a developer's board on port 4600 untouched while the probe bound 127.0.0.1:53991. Law 6 verified by reading both sides: Get-Sha256Hex is imported from scripts/Artifact.psm1:124 and used exactly as Produce-Artifact.ps1:364-365 uses it, no second copy. Friction entry 1 reproduced verbatim (the raw event delegate killed the child pwsh with the quoted no-Runspace exception, exit -532462766); friction entry 2 not reproduced in 20 attempts but not contradicted, and its class lesson stands. The probe genuinely guards the join and deserves to land; it is rejected on one fixable documentation Major - a coverage claim contradicted by a passing test in this same repo - plus three minors. I edited nothing, committed nothing, pushed nothing; all injection ran on copies outside the repo and the landed file's sha256 is unchanged at b21e0c5eb4b6c7c341d9735289bb1b2573132f4996173e6ffca18559263b3599.
task-id: probe-79-review-r1
```