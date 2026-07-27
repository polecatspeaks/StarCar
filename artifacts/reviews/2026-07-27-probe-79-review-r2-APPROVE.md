<!-- starcar-integrity: sha256=77ae6b717e96df0f2595ef53d26761da04fa408a1eaf7eca0410af55ee7bc998 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Probe #79 manifest-to-board join pinning, review round 2 (delta)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review (delta re-review)
Round: 2
Target: `car/probe-79 fix-cycle r2 HEAD a3579c4`
Base reviewed: `c1c4d2dcee4023f721f2d5d433fe3bc2f3583dc1`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

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
| Base commit the reviewer read (**the lookup key**) | `c1c4d2dcee4023f721f2d5d433fe3bc2f3583dc1` |

| Dispatch, the locator within the session | `af1b76cf7eab52dc7` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain c1c4d2dcee4023f721f2d5d433fe3bc2f3583dc1
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: **APPROVE** — 0 Major, 1 minor, 3 nits

Round 1's Major is properly closed, and closed *by evidence the car gathered itself* rather than by paraphrasing my verdict. The one minor is a residual precision gap created by the fix — recorded, not blocking.

## BASE-DELTA (#13)

- Worktree `<repo>-wt\review-probe-79`, HEAD **`a3579c4bd93839c40490dffbf28590fbcf81361c`** (detached, `car/probe-79`), `git status --porcelain` **empty** before and after. Round-1 reviewed HEAD: **`c1c4d2dcee4023f721f2d5d433fe3bc2f3583dc1`**.
- `git diff c1c4d2d..a3579c4 --stat`:
  ```
  scripts/probes/ManifestBoardJoin.Probes.Tests.ps1 | 66 +++++++++++++++++++----
  1 file changed, 55 insertions(+), 11 deletions(-)
  ```

## THE GOVERNING CHECK: is it really comments-only? **YES — proven at the parser level.**

Two independent derivations, because "every line I changed is a comment" is exactly the kind of claim that fails on a here-string or a trailing-comment edit:

1. **Line-level:** all 66 changed lines (`git diff -U0`, `+`/`-` only, headers stripped) match `^[+-]\s*#`. Zero exceptions.
2. **AST-level (decisive):** `[System.Management.Automation.Language.Parser]::ParseInput` on both blobs, filtering out `Comment`/`NewLine`/`EndOfInput` tokens — **1718 executable tokens each, and the token streams hash identically: `d7cf49bd720a278f9e7682b36d6931abe51a97eefe654566122a61a968e38cf4` for both.**

So the executable content of `c1c4d2d` and `a3579c4` is *provably* the same program, and my round-1 non-vacuity proof carries forward intact. I still spent one empirical touch on it rather than inferring (below).

## Suites, run by me at `a3579c4`

| Suite | Observed | Car claimed |
|---|---|---|
| `Invoke-Pester ./scripts/probes` | **29 passed / 0 failed / 0 skipped** (16.25s) | 29/29 ✓ |
| `Invoke-Pester ./scripts/tests` | **222 passed / 0 failed / 5 skipped** | 223/0/4 attached ✓ |
| `CodeCitationPolicy.Tests.ps1` (#42) | **13 passed / 0 failed** | 13/13 ✓ |

The extra skip is the same one I named last round, unchanged: **`scripts/tests/SessionStartGuardRunner.Tests.ps1 :: running the REAL guards prints [ci-baseline]'s marker ONLY when attached to a branch — conditional, never asserted as always-emitting`** (the other four skips are `CitationResolverPolicy.Tests.ps1`'s report-only cases, skipped in both rounds). 227 tests both ways.

**Product-injection re-touch at this HEAD** (rebuilt the out-of-repo copy — the copy's probe file hashes `664f20cf…e517`, identical to HEAD's): baseline 5 passed / 0 failed, then broke the real join in `board/assemble/assemble.go` (`m.Role == "gate"` → `"reviewer"`), rebuilt the real server from the altered source:

```
--- RED: the GATES lane fills from a gate-role member, carrying its gate NAME and verdict word verbatim
    Expected 1, because exactly one member (gateA) is role=gate with a returned record…, but got 0.
RESTORE: 852870A2D219AB67 -&gt; 852870A2D219AB67 :: BYTE-IDENTICAL
```

The guard still fires on a real regression at this HEAD. I also re-derived the R1-m3 measurement (all-zero digest → **5 passed / 0 failed**, seal unguarded), since the fix text asserts that number.

---

## THE SIX ROUND-1 IDs

| ID | Disposition | Evidence |
|---|---|---|
| **R1-M1** (Major) | **FOLDED — fixed, with a residual: see R2-m1** | Lines 15-41 replaced the false paragraph. Every checkable claim in the new text verified true (below). |
| **R1-m1** (four vs five) | **FOLDED — correct** | The "four quoted red messages" phrase is gone entirely; line 80 now reads "independently re-derived, all five". Grep confirms no residue — the four surviving instances of "four" are the quoted issue text, "the four assertions", "sixty-four zeros", and "four-member consist", all legitimate. |
| **R1-m2** (CI exposure) | **FOLDED as disclosure — correctly framed as a decision** | New PROBED FACTS bullet, lines 66-75. See ruling 2. |
| **R1-m3** (seal unguarded) | **FOLDED — correct, and correctly two-sided** | New SCOPE block, lines 137-145. See ruling 3. |
| **R1-n1** (`producer` missing) | **FOLDED — correct** | Line 59 now lists `producer`; verified present in the cited range at `board/store/store.go:127` (`Producer string \`json:"producer"\``, inside the cited `:113-134`). |
| **R1-n2** (citation to a non-repo report) | **FOLDED — correct, plus a self-found fix** | Lines 77-81 repoint at the `New-ScratchStore` switches and the landed verdict path. See ruling 4. |

**None DRIFTED.** No fold that merely looks folded: every one changed the substance, and I re-derived the claims rather than reading them.

---

## THE FOUR QUESTIONS, RULED

### 1. R1-M1 — is every claim in the new paragraph true, and does it over- or under-state? **True throughout; it UNDER-states in one clause (R2-m1).**

I opened every citation and tested the factual claims empirically rather than reading them:

| Claim (line) | Verification |
|---|---|
| `wireschema_test.go`'s `TestAssembledSnapshotValidatesAgainstWireSchema (:20-152)` (19) | func at :20, closes :152 ✓ |
| writes records "as REAL FILES on disk (writeRecord, `board/server/poll_test.go:23-32`, `os.WriteFile` into `t.TempDir()`)" (20-21) | `poll_test.go:23-32` is exactly `writeRecord` → `os.MkdirAll` + `os.WriteFile` ✓ |
| "runs `srv.PollOnce` (`board/server/poll.go:253`'s real store-scan-through-fold-through-assemble pipeline)" (22-23) | `poll.go:253` = `s.adapter.Scan(...)`; `poll.go:317` = `fold.Fold(...)`; `poll.go:327` = `assemble.Assemble(...)` ✓ all three hops real |
| "gates lane has exactly 1 gate with its RecordDir and Findings (`wireschema_test.go:129-137`)" (23-24) | exact ✓ |
| "trains lane has 1 train with 2 manifest tickets and carA's RecordDir (`:112-123`)" (24-25) | exact ✓ |
| "it passes today … PASS in 0.02s" (25-27) | re-ran at this HEAD: **PASS**, 0.02s / 0.03s instrumented ✓ (but see R2-n1 on the command's cwd) |
| quotes issue #79's narrower claim (27-29) | verbatim against `gh issue view 79` except one capitalisation — R2-n3 |
| "the verdict word and gate name rendered VERBATIM" is what *this* suite adds (34) | **Empirically tested.** I instrumented the copy's `wireschema_test.go` and observed the pipeline *produces* `gate[0].Name="design review round 1" Outcome="REJECT"` — and `wireschema_test.go` asserts **neither** (only RecordDir and Findings, :132-137). Claim TRUE ✓ |
| "declaredNotObserved … wireschema_test.go's fixture declares no unobserved member" (35-36) | **Empirically tested**, not inferred: `REVIEWER PROBE declaredNotObserved = []string{} (len 0)` ✓ |
| "per-member role/state/outcome on the consist" is what this suite adds (35) | observed rendered (`carA role=car state=dispatched`, `gate-1 role=gate state=returned outcome=REJECT`) and asserted nowhere in `wireschema_test.go` ✓ |
| "assigned:true flowing from manifest membership" (36-37) | `grep assigned board/server/*_test.go` → one **comment** at `wireschema_test.go:18`, zero assertions ✓ |
| "alongside (never in place of) wireschema_test.go's own coverage" (40-41) | correct, and load-bearing — it is what keeps R2-m1 from being a Major |

*(Instrumentation was applied to the out-of-repo copy only and restored byte-identical: `7F8EAD104B85DFEB` → `7F8EAD104B85DFEB`.)*

**No over-statement anywhere** — the paragraph does not oversell the probe; every "what this suite adds" item is a real gap in `wireschema_test.go` that I confirmed by observation. The one defect is the opposite direction: see R2-m1.

### 2. R1-m2 — is the CI disclosure accurate, and is the deferral a decision? **Accurate; and yes, a decision.**

Every coordinate re-checked at this HEAD: `ci.yml:214-228` is the "Run substrate-floor probes" step running `Invoke-Pester -Path ./scripts/probes`; `:113-117` is the two-leg matrix; `:263` is "Set up Go (board/)", after it. The load-bearing behavioural claim — **"a missing `go` makes this suite hard-fail, not skip - Passed=0/Failed=5"** — is exactly what I measured in round 1 by pointing both lookup candidates at nonexistent binaries. The GOTOOLCHAIN clause is hedged to "can trigger", which is *weaker* than what I measured (both runner images ship Go 1.24.13 against `board/go.mod`'s `go 1.26`, so it will); erring toward under-claim is the correct direction for an unobserved-in-CI fact.

**The deferral is framed as a decision, not an omission**: it names the finding, states it is "disclosed - not fixed here", and names the owner ("the step-ordering decision belongs to the conductor"). That is the decision shape this shop requires. It carries no ticket number — see R2-n2.

Related and already actioned upstream: `origin/dev` now carries the corrected row — *"~~Probe suite in CI~~ … **TRIGGER FIRED AND SATISFIED - item 1 LANDED, this row was a lying canary until 2026-07-27**"* — so the stale `docs/setup.md:48` I flagged in round 1 is fixed on dev (this branch predates it; not a defect here).

### 3. R1-m3 — does the scope note under-state the Law 6 correctness? **No. It is correctly two-sided.**

Lines 137-145 state both halves explicitly: the suite "pins the JOIN, never the SEAL" **and** "Calling `Get-Sha256Hex` here is still the Law-6-correct move (one owner, no second hashing rule) and matches how a real producer seals a record". Both of the available errors are avoided. Supporting citations verified: `board/store/store.go:131` is exactly `Integrity string \`json:"integrity"\`` with no recompute anywhere in the package; `schema/starcar-artifact.schema.json:100-104` pattern-checks `^sha256:[0-9a-f]{64}$` only; and I re-derived the measurement at this HEAD — all-zero digest → **5 passed / 0 failed**, exactly as the note claims.

### 4. R1-m1 / R1-n1 / R1-n2 and the self-found item — **all correct; the verdict-path citation is ACCEPTABLE; I found no further unresolved citation.**

- **The self-found `GatesRoleOverride` → `GateARole` fix is genuine and complete.** I did not take it on trust: I extracted `New-ScratchStore`'s parameter names from the **AST** (`FunctionDefinitionAst` → `ParamBlock`) — `Root, GateARole, IncludeGateBMember, IncludeCarBMember, EmptyMembers, SecondManifestClaimsCarA` — and cross-checked every name cited in the non-vacuity block `(a)`-`(e)`. **All five resolve to real parameters; `GatesRoleOverride` appears nowhere in the file.** The car's reasoning was right: having written "re-derivable straight from the switches quoted below", the switches had to be real.
- **Swept for more, since one accidental find implies others.** Mechanical audit of *every* path-shaped citation in the file (regex over the whole file, `Test-Path` each): 15 distinct paths, **14 RESOLVE**, and the one MISSING is the known forward-resolving verdict.
- **The verdict-path citation is ACCEPTABLE, verified rather than assumed.** `artifacts/reviews/2026-07-27-probe-79-review-r1-REJECT.md` does not exist on this branch, and **does exist at `3eb1bf3`** ("harness: land probe-79 review r1 verdict (REJECT 1M 3m 2n) + true a lying-canary setup row"), which `git merge-base --is-ancestor 3eb1bf3 origin/dev` confirms is an **ancestor of `origin/dev`**, and the file is present at `origin/dev`'s tip. It resolves the moment this branch merges, it is a stable repo-relative path (not a machine path), and it points at the landed durable artifact rather than an ephemeral transcript — which is the *stronger* form of the round-1 citation it replaced. Not a dangling citation.
- The claim it makes about that review — "independently re-derived, all five" — is a claim about my own work, and it is true.

---

## FINDINGS

### R2-m1 (minor) — the corrected paragraph now UNDER-states `wireschema_test.go`, in the sentence written to describe it accurately

`scripts/probes/ManifestBoardJoin.Probes.Tests.ps1:31-32`:

&gt; "What wireschema_test.go DOES assert, from a real on-disk store via PollOnce: gates-lane count and RecordDir/Findings, trains-lane count/tickets/RecordDir."

Read as the enumeration it is introduced as, it omits three things that test asserts:

- **its own headline purpose** — the marshalled snapshot validates against `schema/yard-snapshot.schema.json` under the pinned validator (`wireschema_test.go:77-85`, and its own header at `:13-19` says this is the obligation it exists for). **This probe does not do that at all** — it parses `/api/snapshot` and asserts fields, never validating against the published wire schema;
- the #28 wire-config assertions (`:91-96`, `Config.GitHubRepoURL` / `GitHubArtifactsPrefix`);
- the dispatches-lane orphan `recordDir` assertion (`:143-151`).

This is the R1-M1 class inverted, and it did not exist before the fix — an honest note under the churn rubric. Two things hold it to minor rather than Major: everything the sentence *does* state is true, and line 40-41's "this file is the fix, **alongside (never in place of)** wireschema_test.go's own coverage" explicitly closes the "delete the redundant test" risk the omission would otherwise open. One clause fixes it — scope the enumeration ("of the join properties: …") and name the schema validation as coverage this probe does not replace.

### R2-n1 (nit) — the cited reproduction command omits its working directory

Line 26 cites `go test ./server -run TestAssembledSnapshotValidatesAgainstWireSchema` as the verification. Measured both ways at this HEAD:

- from the repo root: **`go: cannot find main module, but found .git/config in ~\git`** — fails;
- from `board/`: **`ok github.com/polecatspeaks/StarCar/board/server 1.176s`**.

A stranger following the citation gets an error, not a PASS. `docs/setup.md:31` already states the convention (`board/` as working directory); adding "from `board/`" makes the claim reproducible.

### R2-n2 (nit) — the deferred CI decision names an owner but no ticket

Lines 66-67 defer the step-ordering decision to the conductor with no `#N`. The never-drop rule is satisfied in spirit (a landed PROBED FACTS bullet is a durable landing), but **#10 is open and is the natural home** — it is literally "wire scripts/probes into CI as the substrate-floor gate", and its item 1 has landed while the ordering question has not. Citing `#10` in the bullet gives the open end a tracked handle.

### R2-n3 (nit) — a quotation is emphasis-edited

Line 29 quotes issue #79 as "…asserts the four rendered properties **TOGETHER**"; the issue's text reads "together". Verbatim except capitalisation. In a shop whose standing practice is that verdicts land verbatim and are never retyped, emphasis inside quote marks is worth marking outside them.

---

## Convergence (round 1: 1M / 3m / 2n → round 2: 0M / 1m / 3n)

**Converging. No escalation.** Against the three swirl triggers:

- **Major count declining?** Yes — 1 → 0. Trigger does not fire.
- **Findings clustering in the same section?** Partly — R2-m1 is in the paragraph R1-M1 rewrote. Trigger fires.
- **Does this round include defects the previous round's fixes created?** Yes — R2-m1 exists only because the fix text exists. Trigger fires.

Two of three technically fire, which is the escalation threshold — so I am ruling on it explicitly rather than letting the arithmetic decide: **this is not swirl, and I am not setting a cap.** Swirl is a defect being *relocated* at constant severity; here severity collapsed from a false absolute claim (Major, Law 1) to an unqualified enumeration whose omissions are guarded four lines later (minor), and the round-1 fixes for m1/m2/m3/n1/n2 introduced nothing at all. Five of six IDs closed clean with zero residue. A third round is optional, not owed — the minor and three nits are one small comment edit that a reviewer can confirm by reading.

## Debris audit

Baseline before this round's work: zero `mbj-probe-*` dirs, zero probe processes. After the full probes suite, three injected runs (product + seal), the out-of-repo Go instrumentation, and the copy teardown: **zero `mbj-probe-*` directories, zero `inj-*` files, no `alt-repo-79`, zero stray `board-server-probe.exe` anywhere under `%TEMP%`, zero orphan processes.** The pre-existing developer board (PID 7180) still holds 4600, untouched. Worktree still `a3579c4`, `git status --porcelain` empty, probe file `664f20cfbf3ee7cac88542593b2ea504479632c61732be7867f44ce5bfbbe517`. **I wrote nothing to the repo this round** — all injection ran on copies in `%TEMP%`.

## Standing recommendation (a TICKET, not a change here) — YES, worth filing

The contrast the coordinator flagged is real and I grounded it rather than repeating it. `board/web/test/support/real-board-server.js:528`:

```js
const resolvedPort = port ?? 4700 + (process.pid % 200);
```

A PID-derived port in a 200-wide window, and all four browser tests (`browser-register-cascade`, `browser-conditions-persistence`, `browser-health-trend-cascade`, `browser-dispatch-row-geometry`) call `startRealBoardServer` **without** a port — so any two concurrent servers in one process, or two processes whose PIDs collide mod 200, contend. That matches the observed flakes. This probe's pattern is the fix and is now proven in-repo: `STARCAR_PORT=0` (OS-assigned, `board/server/config.go:80` → `main.go:51`) plus **learning the real address by parsing the server's own `listening on http://…` line** (`main.go:70`) — measured surviving three concurrent runs and coexisting with a board on 4600, binding `127.0.0.1:53991`. The helper already captures stderr (`child.stderr.on('data', …)`), so the readiness parse is a few lines. Recommend a ticket under `area:tooling` citing `real-board-server.js:528` and `ManifestBoardJoin.Probes.Tests.ps1`'s `Start-BoardServerAgainst` as the landed exemplar.

## Citation check (#42) and doc check

`CodeCitationPolicy.Tests.ps1` **13/13 green**; the file carries bare `#79` (7 occurrences) plus `#76`/`#75`/`#43` context. Every line-number citation into a file this commit does **not** edit was opened and confirmed (`config.go:100`, `:80`, `main.go:51`, `:70`, `store.go:113-134` incl. `producer` at `:127`, `:131`, `assemble.go:124`, `:100-158`, `:106-108`, `:183-187`, `poll.go:253`, `poll_test.go:23-32`, `wireschema_test.go:20-152`, `:112-123`, `:129-137`, `schema/starcar-artifact.schema.json:100-104`, `Produce-Artifact.ps1:363-365`, `ci.yml:113-117`, `:214-228`, `:263`). No line-number citation points into the file this commit edits — the new text refers to `New-ScratchStore` and `BeforeAll` by symbol, which is the required form. **No living document is invalidated by a comments-only change**; `docs/setup.md`'s probe row was already corrected on `origin/dev`, and `docs/doc-map.md:57` still refers to `docs/probes/*`, not `scripts/probes/`.

## Constitution check

| Law / rule | Evidence |
|---|---|
| **#40 — a guard nobody watched fire is decoration** | Governing law: I watched it fire again at this HEAD (product injection red by name) rather than inferring from "comments only". |
| **Law 1 — no confident falsehood** | Round-1 violation **remedied**; every claim in the replacement independently verified, two of them by running instrumented Go rather than reading. R2-m1 is an incompleteness, not a falsehood. |
| **Law 6 — one owner per rule** | Unchanged and now explicitly scoped: `Get-Sha256Hex` from `scripts/Artifact.psm1:124`, no second hashing rule; token stream proves no logic moved. |
| **Law 7 — the stranger** | Improved: the non-vacuity evidence now points at re-derivable in-file switches and a repo-relative landed verdict instead of an out-of-repo report. Docked one nit (R2-n1) for a command a stranger cannot run as written. |
| **Law 4 — never silently dropped** | The CI dependency is disclosed on the artifact itself rather than dropped; the R1-m3 gap is written down rather than papered over. |
| **Documentation ranks equal to code** | This entire round is a documentation fix reviewed at the code standard, with its claims tested by execution. |
| **Obligations cross rungs by carrier** | All six round-1 IDs folded **inline and tagged by ID** in the file (`R1-M1`, `R1-m2`, `R1-m3` appear verbatim at the fold sites) — not "review feedback incorporated". |
| **#43 no-debris** | Re-audited; clean. |
| **Probe doctrine** | The landed probe remains the durable form of #76's perishable result, now with an honest coverage map of what already existed beside it. |

## UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

- **No CI leg was run** (I cannot push). The CI-dependency bullet's coordinates are verified by reading `ci.yml` at this HEAD; its behavioural halves are my round-1 local measurements (no-Go → Passed=0/Failed=5; `go: downloading go1.99.0` proving GOTOOLCHAIN auto-download; 16.6s cold-cache build). Documentary + simulated, still not observed in CI.
- **The "PASS in 0.02s" timing** in the header is inherently perishable; I observed 0.02s (round 1) and 0.03s (round 2, instrumented) on this box.
- **The `board/web` flake** is the coordinator's report, not my observation; what I verified independently is the *mechanism* (`real-board-server.js:528`'s PID-derived port and four portless callers), which is why the recommendation is a ticket rather than a finding.
- **All my instrumentation ran outside the repo** (copies in `%TEMP%`, `git init`), each restored byte-identical with hashes recorded (`852870A2D219AB67`, `7F8EAD104B85DFEB`), and the copies deleted. Repo file hash unchanged at `664f20cf…e517`.

Files: `<repo>-wt\review-probe-79\scripts\probes\ManifestBoardJoin.Probes.Tests.ps1`, `<repo>-wt\review-probe-79\board\server\wireschema_test.go`, `<repo>-wt\review-probe-79\board\web\test\support\real-board-server.js`, `<repo>-wt\review-probe-79\.github\workflows\ci.yml`.

```starcar-artifact
outcome: APPROVE
findings: 0 Major, 1 minor, 3 nits. R2-m1 (minor, scripts/probes/ManifestBoardJoin.Probes.Tests.ps1:31-32): the corrected paragraph's sentence "What wireschema_test.go DOES assert ... : gates-lane count and RecordDir/Findings, trains-lane count/tickets/RecordDir" is introduced as an enumeration but omits that test's own headline purpose - validation of the marshalled snapshot against schema/yard-snapshot.schema.json under the pinned validator (wireschema_test.go:77-85, its own header at :13-19), which this probe does not do at all - plus the #28 wire-config assertions (:91-96) and the dispatches-lane orphan recordDir assertion (:143-151). This is the R1-M1 class inverted and was created by the R1-M1 fix; held to minor because everything the sentence states is true and line 40-41's "alongside (never in place of) wireschema_test.go's own coverage" closes the delete-the-redundant-test risk. R2-n1 (nit, line 26): the cited reproduction command go test ./server -run TestAssembledSnapshotValidatesAgainstWireSchema fails from the repo root (measured: go: cannot find main module) and succeeds from board/ (measured: ok, 1.176s); it needs its working directory stated. R2-n2 (nit, lines 66-67): the deferred CI step-ordering decision names the conductor as owner but no ticket, while issue #10 is open and is that exact subject. R2-n3 (nit, line 29): issue #79 is quoted with "together" capitalised to "TOGETHER" inside the quotation marks. All six round-1 IDs FOLDED, none DRIFTED: R1-M1 fixed with residual R2-m1; R1-m1 four-to-five corrected with no residue; R1-m2 disclosed as a decision with an owner and accurate measured facts; R1-m3 scoped two-sided, affirming Law 6 correctness while stating the seal is unguarded; R1-n1 producer added and verified at board/store/store.go:127; R1-n2 repointed at the AST-verified New-ScratchStore switches and the landed verdict path, plus the car's self-found GatesRoleOverride to GateARole correction which I verified against the parameter block. Convergence: 1M/3m/2n to 0M/1m/3n - two of three swirl triggers technically fire (same-section clustering, a defect created by a prior fix) but I explicitly rule NOT swirl and set no cap, because severity collapsed from a false absolute to a guarded incompleteness and five of six IDs closed with zero residue.
abstract: Delta review round 2 of a3579c4 over round-1 HEAD c1c4d2d, one file, 55 insertions 11 deletions. The governing check was the comments-only claim, and I proved it two ways rather than by eye: every one of the 66 changed lines matches a comment pattern, and the PowerShell parser's own token stream with comments and newlines excluded is byte-identical across the two blobs - 1718 tokens each, both hashing d7cf49bd720a278f9e7682b36d6931abe51a97eefe654566122a61a968e38cf4 - so the executable program is provably unchanged and round 1's non-vacuity proof carries. Suites at a3579c4: scripts/probes 29 passed 0 failed 0 skipped; scripts/tests 222 passed 0 failed 5 skipped with the extra skip again named as SessionStartGuardRunner's branch-attached ci-baseline case; CodeCitationPolicy 13/13. I still spent one empirical touch on the unchanged-code claim, rebuilding the out-of-repo checkout copy and breaking the real join in board/assemble/assemble.go, and the gates assertion red by name with the source restored byte-identical. The corrected R1-M1 paragraph was tested claim by claim rather than read: I instrumented a copy of wireschema_test.go and observed declaredNotObserved empty at length zero, and observed the pipeline producing gate name "design review round 1" and outcome REJECT that the Go test never asserts, confirming both the "fixture declares no unobserved member" claim and the "verdict word and gate name verbatim" addition; grep confirmed no board/server test asserts assigned. A mechanical sweep resolved all fifteen path citations in the file, the one miss being the round-1 verdict which I confirmed exists at 3eb1bf3, an ancestor of origin/dev and present at its tip, so it resolves post-merge - acceptable, not dangling. The car's self-found parameter-name fix was verified by extracting New-ScratchStore's parameters from the AST: all five injection names now resolve, GatesRoleOverride appears nowhere. Approved with one minor - the fix paragraph now under-states what the Go test covers, the same Law 1 class inverted, held below Major because its own "never in place of" clause closes the risk - and three nits. Debris clean across every run; I wrote nothing to the repo, all injection ran on out-of-repo copies with restore hashes recorded. Separately recommended as a ticket, not a change here: board/web/test/support/real-board-server.js:528 derives its port from the PID modulo 200 with four portless callers, which is the fixed-port collision surface, and this probe's port-zero plus parse-the-listening-line pattern is the landed exemplar to port.
task-id: probe-79-review-r2
```