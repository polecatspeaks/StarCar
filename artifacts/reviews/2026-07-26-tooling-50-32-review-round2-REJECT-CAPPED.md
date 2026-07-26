<!-- starcar-integrity: sha256=009838491592a851546886a5b609ae6a0243c49d0d489b330593c2719a5fc2da covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car tooling-50-32 delta re-review - round 2 (CAP SET, ESCALATED)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial delta re-review
Round: 2
Target: `fix commits 4e9cfa2, 94888d3, cb59867, db1d3da on car/tooling-50-32 (r1 findings M1-M5, m1-m6)`
Base reviewed: `db1d3dabd1c3250ef1be48e208d9910cbf08b901`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `ad18f715d2df17fe5`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `db1d3dabd1c3250ef1be48e208d9910cbf08b901` |

| Dispatch, the locator within the session | `ad18f715d2df17fe5` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain db1d3dabd1c3250ef1be48e208d9910cbf08b901
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All injections reverted byte-identical; tree clean, HEAD unchanged, suite still 182/182.

---

# DELTA RE-REVIEW ROUND 2 — VERDICT: **REJECT** — 4 Major, 4 Minor

Series: base `5ea6c0c` → r1 REJECT (5M/6m) at `2555266` → r2 at `db1d3da`.
Worktree HEAD verified `db1d3dabd1c3250ef1be48e208d9910cbf08b901` before any work.

**Every one of my eleven round-1 findings is genuinely fixed — 11/11 Present, several of them exemplary.** The REJECT is not about them. It is about what the fixes *built*: the M4 replacement mechanism has three new defects I reproduced, and the M5 fix silently disabled the divergence pin I called the strongest artifact in round 1. All four new Majors are fix-created, which is the sharpest swirl indicator the doctrine names. **I am setting a cap** — see the convergence ruling.

## SUITE COUNTS — OBSERVED BY ME

| Suite | Observed at `db1d3da` | Car claimed |
|---|---|---|
| `scripts/tests` | **182 passed / 0 failed / 0 skipped** (run twice) | 182 ✓ |
| `scripts/store-checks` | **159 passed / 0 failed** | 159 ✓ |
| `scripts/probes` | **24 passed / 0 failed** | 24 ✓ |

Per file: Wiring 8, Report 8, Concurrency 3, Reconcile 14 = 33; 149 unchanged + 33 = 182. Arithmetic `173 − 2 + 3 + 3 + 5` reconstructs exactly.

---

## FINDINGS TABLE — ROUND-1 DISPOSITION

| ID | Round-1 finding | Ruling | Evidence |
|---|---|---|---|
| **M1** | Narrowed guard missed the documented failure signature | **PRESENT (fixed)** | My injection D re-run: **Wiring 7/1 FAILED by name**, `every REAL SessionStart hook command matches the whitelist`. Whitelist rejects **9/9** adversarial shapes I threw at it (inline `if…fi`, `sh -c`, `;`-chain, `&amp;&amp;` tail, `--reset`, `bash`, extra pipe, `../` traversal, `$(…)`) and accepts **5/5** real lines. `SessionStartWiring.Tests.ps1:44` |
| **M2** | Dead citation; `docs/setup.md` stale | **PRESENT (fixed)** | `docs/setup.md:113-131` now names the report file, the pipe wiring, the M4 mechanism and the restart-gated trigger. The design's citation is now true as written. |
| **M3** | D5 / §5.6 stale prescription; risk unnamed | **PRESENT (fixed), exemplary** | Design `:71` supersedes D5's clause **without rewriting it**, and names the risk in the design: *"a change on the strength of an argument … never an OBSERVATION that Copilot's compat layer evaluates pipes at all."* §5 item 6 (`:117-122`) cross-references it. No Copilot-leg verification claimed. |
| **M4** | Truncation race not closed | **DRIFTED** | The named race IS closed — my round-1 adversarial test re-run: **0 losses / 30 trials** (was 2/15). But the replacement mechanism carries three new reproduced defects (N1–N3). Fixed the instance, relocated the class. |
| **M5** | Detector never run on the real corpus | **PRESENT (fixed)** | Real-corpus run, read-only: **9 gaps → 1 gap + 1 NOTE excluding 8**, floor `2026-07-22T16:40:01+00:00`. Second bug found by the car and verified by me (below). |
| m1 | `.gitignore` citation | PRESENT | `.gitignore:2-3` |
| m2 | `CLAUDE_PROJECT_DIR` anchor | PRESENT | `session-start-record.sh:76` |
| m3 | unknown renders as unknown | PRESENT | `Reconcile-DispatchRecords.ps1:226`; real run prints `logged_at=unknown` |
| m4 | exit-code masking comment | PRESENT | `session-start-record.sh:58-64` |
| m5 | `sh` probe not landed | PRESENT | `SubstrateFloor.Probes.Tests.ps1`, 2 tests, names its consumers; probes 24/24 |
| m6 | stale CheckpointReconcile comment | PRESENT | corrected `:43-53`, citing the friction-log entry's own text as the evidence it was stale |

**Regression check on what was good in round 1:** tee semantics intact (live replay of all five lines: stdout carried every guard's output, report mirrored it, marker first, each line once). Out-of-scope inline `entire` wrappers **byte-identical to base `5ea6c0c`** on all five other hook events (PostToolUse, SessionEnd, Stop, UserPromptSubmit, SubagentStop — compared programmatically). **The divergence pin did NOT survive — see N4.**

---

## NEW MAJOR FINDINGS — all four created by the fixes

### N1 — A second SessionStart within 60s appends to the previous session's report instead of truncating. Three landed surfaces now assert the opposite; one of them was written in this delta.
`.claude/hooks/session-start-record.sh:77` (`STALE_SECONDS=60`), `:101-113`.

Observed:
```
batch 1 → [session-start-report] 2026-07-26T12:50:11Z / BATCH-1-GUARD-A / BATCH-1-GUARD-B
  (3 seconds later, a second SessionStart)
batch 2 → [session-start-report] 2026-07-26T12:50:11Z   &lt;-- previous session's marker
          BATCH-1-GUARD-A / BATCH-1-GUARD-B / BATCH-2-GUARD-A / BATCH-2-GUARD-B
```
A Copilot agent reads a file whose timestamp line belongs to the *previous* session and whose content mixes two sessions, with nothing to tell them apart. Law 1 on the exact surface this feature exists to create.

Falsified claims, all still on disk: `.github/copilot-instructions.md:17` *"freshly truncated per session"*; `ONBOARDING.md:63` *"freshly truncated per session, first line a timestamp marker"*; and `.gitignore:2` *"freshly truncated per session"* — **added by commit `db1d3da` in this very fix cycle.** Round 1's `--reset` handled this case correctly, so this is a regression, and it is nowhere disclosed (I grepped the script, both design amendments, `docs/setup.md`, and both pointer files: no mention of `STALE_SECONDS`' consequence).

Not exotic: this repo's own doctrine enumerates *"a session resumes after compaction"* as a first-class trigger (`ONBOARDING.md:74`, `docs/setup.md:55`, design `:145`). Wall-clock proximity is not session identity, and no value of `STALE_SECONDS` makes it one.

### N2 — The `date -r` fallback the script calls "the safe default" loses 75% of guard output under concurrency.
`.claude/hooks/session-start-record.sh:96-98` (*"an unreadable/missing file or an unparseable result both fall through to 'stale' (reset), the safe default"*), `:102`.

`date -u -r FILE +%s` is GNU-specific. On BSD/macOS `date -r` takes a seconds argument; on busybox it is absent. **Injection E** (simulating that, reverted byte-identical): 4 concurrent guards × 10 trials —

```
RESULT: 30 / 40 guard outputs LOST
last trial's report: [session-start-report] 2026-07-26T12:51:14Z
                     GUARD-C-10
```

Falling through to *stale* on every invocation makes every guard truncate its predecessors; the mutex converts a race into deterministic total loss of all but the last. The "safe default" claim is false — and it is the fallback the whole M4 fix rests on. Round 1's mechanism had no `date` dependency at all. One-word remedy: on an undeterminable mtime, treat as **fresh** (a duplicate append is recoverable; a truncate is not), or use `find "$F" -mmin -1` / an `-nt` comparison instead of asking `date`.

### N3 — The mutex releases a lock it never acquired; the documented bound is 2.5x optimistic.
`.claude/hooks/session-start-record.sh:87-93` — the `trap 'rmdir "$LOCK_DIR"' EXIT` at `:93` is installed unconditionally, on the `break`-out (fail-open) path as well as on the acquire path.

Observed, slow guard vs fast guard:
```
t=1s     lock dir exists? YES   (slow guard holds it, still inside its critical section)
         fast guard wall time: 5126 ms   (header :84-85 documents "bounded (~2s)")
t=~3s    lock dir exists? NO - released by a process that never held it
```
So once any invocation fails open, the mutex is destroyed while the true holder is still running, and a third invocation can enter concurrently. `session-start-record.sh:40-44` asserts *"only one invocation's body runs at a time"* and `docs/setup.md:123-124` asserts the mutex means *"no guard's output can be lost"* — both stronger than the mechanism supports.

This is realistic, not theoretical: the lock is held across `tee`, i.e. for the **upstream guard's entire runtime**, and `session-start-ci-baseline.sh:24-39` makes a network `gh run list` call. Latency measured: leaked-lock batch **6563 ms** vs **515 ms** baseline — against a brief constraint of "trivial latency". *(I did not reproduce data loss through this path and do not claim it; the finding is that the guard's stated mutual-exclusion property is demonstrably false.)*

### N4 — The M5 epoch floor silently defeated the #32 divergence pin. Producer-side drift is no longer caught.
`scripts/tests/ReconcileDispatchRecords.Tests.ps1:199-219` (pin test 1) vs `Reconcile-DispatchRecords.ps1:191-220`.

Round 1, injection C (`Produce-Artifact.ps1:165`, `agent_id` → `session_id`): **8 passed / 1 failed**, the pin red by name. Round 2, same injection: **14 passed / 0 failed.**

Root cause, reproduced by hand under the injection:
```
[reconcile] NOTE - 1 probe firing(s) excluded as pre-producer-epoch (before 2026-07-23T10:00:00+00:00) - expected, not gaps
[reconcile] no gaps - every would-have-adapted probe firing has a matching returned record
EXIT=0
```
The pin's producer runs with `-Now '2026-07-23T10:00:00Z'`, so the derived floor is `10:00`; the pin's probe line is `_probe_logged_at = 2026-07-23T09:00:00Z`, so it is **always** pre-epoch and **always** excluded. The test's two assertions still hold — for entirely the wrong reason. Test 1 is the only test that chains the producer's subject rule to the reconciler's copy; with it vacuous, the deliberate second copy (`Reconcile-DispatchRecords.ps1:112-117`) is unpinned against its source.

The car *did* notice this interaction for the fixture-behaviour tests and moved `gap-agent-123` to `11:00` with a comment explaining why — but a test that breaks announces itself, and a test that goes vacuous stays green. Injections A and B still fire (reconciler-side subject drift: 6 failures; exclusion-rule removal: 2 failures, including the pin's internal-subagent test), so the *exclusion* half survives; the *producer-agreement* half is gone.

Remedy is small: give pin test 1 a post-floor `_probe_logged_at` (or pass `-Since`), plus a red-first test asserting the pin fails under producer drift.

---

## MINOR FINDINGS

- **N5** — `Reconcile-DispatchRecords.ps1:243` prints *"no gaps - every would-have-adapted probe firing has a matching returned record"* even when firings were excluded and none matched. Observed verbatim in the N4 reproduction: one firing excluded, zero matched, and the line still claims every firing has a record. Law 1; the NOTE line above it does not repair the sentence below it.
- **N6 — the M5 residual: ADJUDICATED, refusal upheld, posture improvable.** The car refused to exclude `adba6552daddbe6db` (the probe log's first line, no `_probe_logged_at`) because it cannot be *proven* pre-epoch. **That refusal is correct** — inventing an exclusion on an assumption is precisely what Law 1 and the severity philosophy forbid, and it is the harder, more honest call. But the car weighed two options where three exist: an undatable entry is not a proven gap *either*, and rendering it as a FLAG (permanent nightly exit 1, unresolvable — no record can ever be written for a firing that predates the producer) asserts "defect" with the same confidence as a real gap. A third disposition — NOTE-severity, *"undatable, first line in the log, presumed pre-epoch, not counted"* — satisfies both laws and leaves the exit code clean. Substantially mitigated by `.claude/skills/goodnight/SKILL.md`, which names the agent_id, explains why it survives, and gives the closure path; a conductor is not misled. Minor, not Major.
- **N7** — Overstated guard claims: `session-start-record.sh:40-44` and `docs/setup.md:123-124`, given N3.
- **N8 (nit)** — `SessionStartReportConcurrency.Tests.ps1` leaks 80+ lines of child-process stdout into the suite and CI logs (observed in every run above); redirect the children's stdout.

**Verified correct, worth stating:** the `returned-*.json` filename scoping (`Reconcile-DispatchRecords.ps1:160`) drops **25 records, all under `artifacts/reviews/`** (hand-landed verdicts) and **zero producer-written records** — 96 `kind:returned` total, 71 producer-named. It matches the producer's own contract: `Produce-Artifact.ps1:425` builds `"$Kind-$compactAt.json"` and `:408` already filters `returned-*.json`. The header's citation to `:394-397` is substantively true but `:425`/`:408` is the sharper coordinate. The second bug the car found is real and correctly fixed.

---

## CONVERGENCE RULING — CAP SET, ESCALATE

**Direction: the named findings converged; the mechanism did not.** 11/11 round-1 findings Present. Majors 5 → 4 — a nominal decline that means nothing, because the composition inverted: **0 of round 2's Majors are unresolved round-1 findings, and 4 of 4 are defects the round-1 fixes created.**

Swirl triggers (`CLAUDE.md`, Review calibration) — **two of three fire:**
- *Majors not declining* — 5 → 4. Borderline; I do not claim it.
- *Findings cluster in the same section across rounds* — **FIRES.** Round 1: M1 + M4 in the SessionStart delivery mechanism. Round 2: **N1 + N2 + N3 all in `session-start-record.sh`**, one file, one mechanism.
- *A round's findings include defects the previous round's own fixes created* — **FIRES decisively, 4/4.** The doctrine calls this the sharpest signal: *"the defect is being RELOCATED, not resolved."*

This is also the verbatim instrument tell: *"successive revisions close every named finding and open new ones in the SAME section."* Two mechanisms have now been written for one requirement; each was correct against the tests written for it, and each lost guard output under conditions those tests did not model.

**THE CAP: no round 3 on the M4 delivery mechanism.** A third revision of a shell-level mutex in `session-start-record.sh` is predicted to produce a fourth defect in the same file. N4 is *not* under the cap — it is an ordinary regression with a small, clear fix, and should be fixed.

**ESCALATE TO THE OWNER — the premise no round has questioned:** *that `session-start-record.sh` must determine session-batch identity by itself.* Round 1 used array ordering; round 2 used wall-clock mtime. Both are proxies for a fact neither can observe, because the script's stdin is occupied by the guard's output, so it can never read the SessionStart payload that actually carries `session_id` and `source`. Remove that premise and the problem dissolves — a runtime-supplied batch key, or one dedicated hook line owning truncation with guards only ever appending, or per-guard files a reader concatenates (no shared mutable file: no truncation, no race, no mutex, no `date -r`). Every one of those is smaller than what is already written.

**Second escalation, scope:** whether #50 Task 2 should ship before the Copilot leg is OBSERVED at all. The car's own M3 amendment now honestly records that the pipe form is *"an argument … never an OBSERVATION."* Hardening an unobservable mechanism through review rounds spends gate attention on a question no test on this desk can settle.

---

## CONSTITUTION CHECK

| Law / rule | Verdict | Evidence |
|---|---|---|
| **Law 1** | **VIOLATED, 4x** | N1 (report asserts a stale session's marker), N2 ("the safe default" — 30/40 lost), N3 ("only one invocation's body runs at a time" — disproved), N5 ("no gaps … every firing has a matching record" when one was excluded and none matched) |
| **Law 4 — nothing silently lost** | **AT RISK** | N1 (cross-session mixing), N2 (75% loss off GNU coreutils) |
| **Law 6** | HONORED | Blacklist removed so one whitelist has one owner; `returned-*.json` scoping follows the producer's contract rather than inventing a second one |
| **Law 7 — the stranger** | **PARTIAL** | `docs/setup.md` cured (M2); but N2 makes the mechanism silently lossy on any non-GNU box |
| **Documentation ranks equal to code** | **MIXED** | M2/M3 fixed exemplarily — original D5 text preserved and superseded rather than rewritten. But N1 falsified three surfaces, one added in this delta |
| **Carrier rule (obligations cross rungs by ID)** | **HONORED, exemplary** | Every commit message names the round-1 finding ID and cites the landed verdict path; every fixed site carries its `M`/`m` tag inline |
| **TDD red-first** | HONORED for what was modelled | Reds stated per fix; the concurrency suite uses genuine `System.Diagnostics.Process` children (`SessionStartReportConcurrency.Tests.ps1:49-57`), not sequential simulation — I confirmed that directly |
| **Guard proven by watching it fire** | **MIXED** | M1's whitelist: watched, fires. The concurrency guard: the car's own non-vacuity injection (5/80 with the mutex neutered) is real work — but the guard's stated property is false (N3) and two failure modes were never modelled (N1, N2) |
| **Instrument severity (crying wolf)** | **SUBSTANTIALLY CURED** | 9 flags → 1 flag + 1 NOTE, measured on the real corpus, disclosed at the point of use in `goodnight/SKILL.md` |
| **Probe doctrine (land the probe)** | HONORED | `SubstrateFloor.Probes.Tests.ps1` names its consumers by file |
| **Never push / read-only reviewer** | HONORED | 4 fault injections (D, E, A, B, C), all reverted byte-identical by SHA-256; `git status` and `git diff` empty; HEAD unchanged; suite re-run 182/182 |

## WHAT REMAINS UNOBSERVED

Unchanged from round 1 and correctly disclosed by the car: the live Claude Code firing of the pipe, the entire Copilot leg (including whether its compat layer evaluates a pipe at all), and whether Claude Code executes the five SessionStart commands in parallel or in array order. My concurrency measurements model parallel execution; they do not prove the runtime does it. This verdict claims none of it.

```starcar-artifact
outcome: REJECT
findings: 4 Major, 4 Minor
task-id: tooling-50-32-review-r2
abstract: |
  Delta re-review round 2 of car tooling-50-32 (fix commits 4e9cfa2, 94888d3, cb59867,
  db1d3da on round-1 HEAD 2555266; series base 5ea6c0c). Base verified before any work;
  nothing committed or pushed; five fault injections performed and all reverted
  byte-identical (SHA-256 verified for settings.json, session-start-record.sh,
  Reconcile-DispatchRecords.ps1 and Produce-Artifact.ps1; git status and git diff empty;
  HEAD unchanged; suite re-run 182 of 182).

  Suites observed by the reviewer: scripts/tests 182 passed 0 failed; scripts/store-checks
  159 passed 0 failed; scripts/probes 24 passed 0 failed. All three match the car's claims
  and the arithmetic reconstructs exactly.

  ROUND-1 DISPOSITION: all eleven findings PRESENT (fixed), 5 Major and 6 Minor. M1 cured -
  my own injection D now fails by name and the restored whitelist rejects nine of nine
  adversarial shapes while accepting all five real lines. M2 cured - docs/setup.md now
  carries the delivery disclosure the design cited. M3 cured exemplarily - D5's original
  clause is superseded rather than rewritten and the pipe-under-Copilot risk is now named
  in the design as an argument rather than an observation. M4 DRIFTED - the named race is
  closed (my round-1 adversarial test re-run: zero losses in thirty trials, versus two in
  fifteen) but the replacement mechanism carries three new reproduced defects. M5 cured -
  nine gaps became one gap plus one NOTE on the real corpus, and the car found and fixed a
  second bug I independently confirmed (the returned-star-json filename scoping drops
  twenty-five records, all hand-landed review verdicts, and zero producer records).

  FOUR NEW MAJORS, ALL CREATED BY THE FIXES. N1: a second SessionStart within sixty
  seconds appends to the previous session's report instead of truncating - reproduced, the
  file carries the prior session's timestamp marker and both sessions' content - falsifying
  three landed claims of "freshly truncated per session", one of them added by this very
  fix cycle in .gitignore. N2: the date-minus-r fallback the script calls "the safe
  default" loses thirty of forty guard outputs under concurrency on any non-GNU coreutils
  box - proven by injection. N3: the mutex's EXIT trap is installed unconditionally, so a
  fail-open invocation removes a lock it never acquired - observed destroying the lock
  while the true holder was still inside its critical section - and the documented
  two-second bound was measured at 5126 ms, with a leaked lock costing 6563 ms versus a
  515 ms baseline. N4: the M5 epoch floor silently defeated the number-32 divergence pin -
  producer-side subject drift that failed by name in round 1 now passes fourteen of
  fourteen, because the pin's fixture probe line is always before the derived floor and is
  always excluded.

  MINORS: a false trailing "no gaps, every firing has a matching record" line when firings
  were excluded and none matched; the M5 residual permanent flag (adjudicated - the car's
  refusal to exclude an undatable entry is CORRECT and upheld, but a NOTE-severity
  disposition would satisfy both Law 1 and the severity philosophy, and the goodnight skill
  discloses the residual well); two overstated mutex claims in the script header and
  docs/setup.md; and child-process stdout leaking into the suite output.

  CONVERGENCE RULING - CAP SET. Named findings converged completely; the mechanism did not.
  Majors went five to four, but zero of round 2's Majors are unresolved round-1 findings
  and four of four are defects the fixes created. Two of three swirl triggers fire:
  findings cluster in one file (session-start-record.sh carries three of the four), and a
  round's findings include defects the previous round's fixes created. CAP: no round 3 on
  the delivery mechanism - two mechanisms have now been written for one requirement and
  each lost guard output under conditions its own tests did not model. N4 is exempt from
  the cap and should be fixed. ESCALATED TO THE OWNER: the premise no round has questioned,
  that session-start-record.sh must determine session-batch identity by itself, when its
  stdin is occupied by the guard's output and so it can never read the payload that carries
  session_id - remove that premise and the problem dissolves. Second escalation: whether
  task 2 should ship at all before the Copilot leg is observed, since the design now
  honestly records the pipe form as an argument rather than an observation.
```