<!-- starcar-integrity: sha256=638efa1dd40c1fe65536435c28b120c22268d9cf73345f3cb99e786512c96ad1 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car process-42 delta re-review - round 2 (REJECT, 1 new Major)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial delta re-review
Round: 2
Target: `commit 83cd377 on car/process-42 (round-1 remedies)`
Base reviewed: `83cd377871a1656caaec6b3ba45cdaeddc27eebf`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

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
> Path normalisation: the repository root was rewritten to ``<repo>`` and the operator home directory to ``~``, BEFORE hashing. Mechanical and narrow: only those two roots, longest-first, no other substitution. This is portability, not curation - findings, verdicts and counts are untouched, and the un-normalised original is on the Entire checkpoint branch.

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `83cd377871a1656caaec6b3ba45cdaeddc27eebf` |

| Dispatch, the locator within the session | `a67cb0075007e7753` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 83cd377871a1656caaec6b3ba45cdaeddc27eebf
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Shared checkout clean and untouched. Ruling.

---

# DELTA RE-REVIEW ROUND 2 — VERDICT: **REJECT** — 1 Major

**Subject:** `83cd377871a1656caaec6b3ba45cdaeddc27eebf` (delta on round-1 HEAD `79cb5c9`, issue #42) · **Base verified FIRST:** worktree at `83cd377871a1656caaec6b3ba45cdaeddc27eebf`, tree clean, delta touches exactly the four claimed files.

**Every round-1 finding is PRESENT and closed — all seven, verified by re-running, not by reading.** The car's remedies are correct, its self-disclosures are honest, and its two Major fixes are proven in both directions. It is rejected on **one new Major that round 2's own fix created**: the new closed-set completeness guard silently swallows extensionless files, and both the test header and CLAUDE.md now assert a completeness it does not have.

## Observed counts (mine, at `83cd377`, detached worktree)

| Suite | Observed | Expectation |
|---|---|---|
| `scripts/tests` | **191 passed / 0 failed / 1 skipped, total 192** | Matches derived detached expectation (191/0/1 of 192). 189 → 192 = +3. Skip is the pre-existing `#50` guard-runner detached skip. |
| `scripts/probes` | **24 / 0 failed** | unchanged |
| `scripts/store-checks` | **178 / 0 failed** | unchanged |
| gate alone, full history | **10 / 10** | |

Car's "192/192 attached" is consistent with my 191/0/1 detached — the delta is exactly the `#50` detached skip.

## Round-1 disposition: Present / Absent / DRIFTED

| ID | Status | Evidence I produced |
|---|---|---|
| **M1** CI shallow-checkout | **PRESENT** | `ci.yml:128-130` carries `fetch-depth: 0`; single job `verify` (`:112`), only one `actions/checkout` in the file, test step `:230` same job. **Negative control** (`git clone --depth 1`, 1 commit): **8/10**, boundary test fails **FIRST and NAMED**. **Positive control** (full clone, 509 commits, `fetch-depth: 0` shape): **10/10**. |
| **M2** silent extension hole | **PRESENT but INCOMPLETE** → new **MAJOR-3** below | My uncited `.py` injection now reds **naming `.py`** (was 7/7 green in r1). Extensionless files still pass silently. |
| **MIN-1** duplicate logic | **PRESENT** | Functions hoisted to file-level `BeforeAll:90`; grep shows **one definition each**; target line occurs **exactly once**. Proven by fault injection, not reading. |
| **MIN-2** self-refuted claim | **PRESENT** | `:72-79` narrowed to "no UNINTENDED collision ... outside this file's own worked examples," naming `#123456`/`#999`. Now true. Regex correctly left alone. |
| **MIN-3** setup.md row | **PRESENT** | `docs/setup.md:42` gains a re-park disposition **appended, not rewritten** — house supersede style honored. |
| **MIN-4** fixture clause | **PRESENT** | Disclosed in both surfaces (`:83-88` and CLAUDE.md). Citation verified: `schema/vectors/adapter/README.md` carries `#47`. |
| **NOTE** 21 vs 22 | **PRESENT** | CLAUDE.md now states 22 (21 + the gate's own `#42`-cited file). I re-derived **22, all carrying a bare `#N`**. |

**No DRIFT.** Every fold is substantive, not cosmetic.

The M1 named message is exactly what a guard should say:

&gt; `Expected $true, because boundary commit d4db6f5... is unreachable in this checkout - shallow clone? this gate needs history back to that commit (ci.yml's checkout step must carry fetch-depth: 0, or enough depth to include it), but got $false.`

Cause **and** remedy in one line. The MIN-1 binding proof: I neutered the single shared `Get-AddedCodeFiles` and **the scratch Describe's "flags the fault-injected uncited file BY NAME" failed too** — the scratch proof genuinely binds to the production function now. Reverted byte-identical (`cmp` YES).

---

## MAJOR-3 (new, round 2) — the closed-set guard silently swallows extensionless files

`CodeCitationPolicy.Tests.ps1:213-227`. I committed an uncited extensionless post-boundary file (`Dockerfile`): **10/10 green.** Traced the mechanism rather than inferring it:

```
Dockerfile present in added non-artifact set: True
observed extensions: '' '.go' '.js' '.json' '.md' '.mjs' '.ps1' '.sh'
unaccounted .Count = 1
unaccounted elements = ''
join result = ''
does the ASSERTION treat the join as empty? -&gt; True
```

The guard **detects it correctly** — `$unaccounted` holds one element — and then `:223`'s `$unaccounted -join ', ' | Should -BeNullOrEmpty` discards it, because the joined empty extension *is* an empty string. A computed truth is dropped one line before it reaches the surface (**Law 4**). Localized to `:223`: the same idiom at `:201` is safe, since a violator is a file path and never empty.

The disclosure runs the wrong way. `:56-58` claims "**every** extension actually observed in the post-boundary, non-artifacts corpus must be in checked-union-exempt, or the suite reds **BY NAME**," and `CLAUDE.md:~1030` repeats it. Measurably false — so **doctrine now carries the claim** (**Law 1**). Not exotic: `Dockerfile`, `Makefile`, `CODEOWNERS`, extensionless shell scripts.

**Remedy, one line:** assert `$unaccounted.Count | Should -Be 0` and render `''` as a sentinel such as `(no extension)` in the message — the detection already works.

*Why this is Major and not a nit: I rejected round 1 for this exact class — a completeness guard with a silent hole and an overstating disclosure. Applying a softer bar now, because the fix is otherwise good work, is the trained agreeableness this shop's guide star names. The class is identical; so is the ruling.*

## The disclosed process slip — no residue

The slip (a `git reset --hard` during the M2 red-first discarding in-progress uncommitted edits, caught and redone) put exactly the M1 and MIN-3 work at risk. Both landed complete and accurate, and I verified them independently rather than trusting the redo: `ci.yml:128-130` present with its full rationale comment and **proven in both directions**; `docs/setup.md:42` present and accurate. Cross-reference sweep found **no dead citations** — the header's `DocPolicy.Tests.ps1:26` claim is verbatim true ("*The closed set. Growing it is a deliberate decision, not a convenience.*"), the ci.yml claim is true, the fixture-README claim is true, the 22-file count reproduces. **Clean tree, no half-done pieces.** The slip cost time, not correctness.

## Convergence ruling (I hold the series)

**r1: 2 Major, 4 Minor, 1 Note → r2: 1 Major, 0 Minor.** Majors declining; all four Minors and the Note closed and verified closed.

Swirl trigger, honestly walked: **(a) counts declining — does NOT fire.** **(b) same-section clustering — partial**, both M2 and M3 sit in extension coverage, but r1's other Major is fully closed and did not recur. **(c) a finding created by the previous round's fix — FIRES**, MAJOR-3 is new-in-round-2.

**Ruling: converging, not swirling — I set NO cap.** The trigger's purpose is detecting a defect being *relocated* rather than resolved; here r1-M2 ("no completeness check exists") was genuinely resolved and *measured* resolved for the case that matters, leaving a narrower adjacent assertion-shape bug. That is progress, not station-keeping. **But I name (c) explicitly for the conductor:** this should be the last round. A round-3 finding again inside extension coverage *is* the pattern, and should escalate rather than iterate.

## MERGEABLE: **NO** from `83cd377`

One Major stands. Expected round 3 is a one-line assertion change plus two sentence corrections — a minimal delta re-review, not a rebuild.

## The CI boundary, stated honestly

**I did not observe real CI green, and could not: `83cd377` is on no remote branch** (`git branch -r --contains` empty) — real CI has never run on this commit. What I *did* observe is the CI **shape**, in both directions, by clone simulation: depth-1 → 8/10 with the named boundary failure; full clone → 10/10. That proves the wiring is correct and the guard fires without it; it does not substitute for a terminal green. The car correctly declines to claim otherwise — `CLAUDE.md` states *"Real-CI green from this fix is observable only post-merge ...; it is not claimed here."* That is the honest posture. **The conductor must watch the run to a terminal state post-merge**; `fetch-depth: 0` changes checkout behavior for every leg of the matrix, so the first real run is the one that matters.

## Constitution check

- **Law 1 (Truth)** — **VIOLATED (MAJOR-3).** `:56-58` and CLAUDE.md assert by-name completeness the guard does not deliver. **Otherwise strongly honored:** CLAUDE.md's "**CI WIRING WAS REQUIRED, corrected from round 1's false claim**" names the falsehood instead of quietly rewriting it, and refuses to claim unobserved CI green.
- **Law 4 (Nothing Silently Lost)** — **VIOLATED (MAJOR-3).** `$unaccounted` is computed with Count 1 and silently discarded at `:223`.
- **Law 6 (One Truth)** — **NOW HONORED.** Round-1's byte-identical duplicate is gone; one definition, proven load-bearing for both Describes by fault injection.
- **Law 3 (Actionability)** — **HONORED.** The boundary failure names cause and remedy; the closed-set failure names the extension and the two options.
- **Law 5 (Self-Knowledge)** — **HONORED.** The belt-and-suspenders boundary assertion means a future `fetch-depth` removal fails named rather than silently reproducing the round-1 defect.
- **Law 7 (The Stranger)** — **IMPROVED.** The taxonomy is no longer a bare allowlist; it is a declared closed set with reasons and a self-calibrating check. MAJOR-3 is the remaining gap.
- **Law 8 (Growth)** — **HONORED.** Round-1 findings landed as *tests and wiring*, not prose.
- **Law 2** — not implicated. **Code standard (#N)** — honored; all 22 post-boundary code files cited, new units cite `#42`.

## Fault-injection log (all reverted, disclosed)

| # | Injection | Observed |
|---|---|---|
| 1 | depth-1 clone at `83cd377` | 8/10 — boundary test FAILED **first, named** |
| 2 | full clone (fetch-depth 0 shape) | **10/10** |
| 3 | uncited `.py` committed | 9/10 — closed-set test reds **naming `.py`** |
| 4 | uncited extensionless `Dockerfile` | **10/10 green — MAJOR-3** |
| 5 | neutered the single shared `Get-AddedCodeFiles` | 7/10 — **both** Describes broke, incl. the scratch by-name proof |

**Revert verified:** HEAD `83cd377871a1656caaec6b3ba45cdaeddc27eebf`, `git status --porcelain` **empty**, test file **byte-identical** to the pre-injection copy (`cmp` YES), temp clones removed. **Shared checkout `<repo>`: on `dev`, clean, untouched.** I edited, committed, and pushed nothing to the record.

```starcar-artifact
outcome: REJECT
task-id: process-42-review-r2
findings: 1 Major (new, created by round 2's own fix); all 7 round-1 findings PRESENT and closed, no DRIFT
  ROUND-1 DISPOSITION, each re-verified by running rather than reading:
    M1 (CI shallow-checkout) PRESENT. ci.yml:128-130 carries fetch-depth 0; single job
      verify at :112, only one checkout in the file, test step :230 same job. Negative
      control, my own depth-1 clone at 83cd377: 8/10 with the boundary test failing FIRST
      and NAMED, message giving both cause and remedy. Positive control, full clone of 509
      commits: 10/10. Both directions proven.
    M2 (silent extension hole) PRESENT but INCOMPLETE - see MAJOR-3. My uncited .py
      injection now reds naming .py, where round 1 measured 7/7 silent green.
    MIN-1 (duplicate logic) PRESENT. Functions hoisted to the file-level BeforeAll at :90,
      one definition each, target line occurs exactly once. Proven by fault injection:
      neutering the single shared Get-AddedCodeFiles broke BOTH Describes including the
      scratch by-name proof, so the scratch tests genuinely bind to production now.
    MIN-2 PRESENT. Sentence narrowed to no UNINTENDED collision, naming this file's own
      worked examples. Now true. Regex correctly left unchanged.
    MIN-3 PRESENT. docs/setup.md:42 gains a re-park disposition, appended not rewritten.
    MIN-4 PRESENT. Fixture clause disclosed as attention-tier in both the test header and
      CLAUDE.md. Citation verified true.
    NOTE PRESENT. 21 corrected to 22; I independently re-derived 22 code files, all cited.
  MAJOR-3 (NEW, round 2): the closed-set completeness guard at
    CodeCitationPolicy.Tests.ps1:213-227 silently swallows extensionless files. Committed
    an uncited extensionless Dockerfile: 10/10 GREEN. Mechanism traced, not inferred - the
    guard DETECTS it correctly (unaccounted .Count = 1, element is the empty string) and
    then line :223's join-then-BeNullOrEmpty idiom discards it, because the joined empty
    extension IS an empty string. A computed truth dropped one line before the surface
    (Law 4). The disclosure runs the wrong way: :56-58 claims EVERY observed extension
    reds BY NAME, and CLAUDE.md repeats it, so doctrine now carries a measurably false
    claim (Law 1). Not exotic - Dockerfile, Makefile, CODEOWNERS, extensionless shell
    scripts. Remedy is one line: assert on unaccounted.Count and render the empty
    extension as a readable sentinel. Ruled Major for consistency: this is the identical
    class round 1 was rejected for, a completeness guard with a silent hole plus an
    overstating disclosure, and softening the bar now because the rest of the work is good
    would be the trained agreeableness the guide star names.
  PROCESS SLIP: no residue. The disclosed reset --hard put exactly the M1 and MIN-3 work at
    risk; both landed complete and accurate and were verified independently rather than
    trusted. Cross-reference sweep found no dead citations - the header's DocPolicy
    reference is verbatim true, the ci.yml claim is true, the fixture README claim is true,
    the 22-file count reproduces. Clean tree, no half-done pieces. Cost time, not
    correctness.
  CONVERGENCE: r1 2 Major 4 Minor 1 Note, r2 1 Major 0 Minor. Majors declining, all Minors
    closed. Swirl trigger walked honestly: counts-not-declining does NOT fire; same-section
    clustering partial; a-finding-created-by-the-previous-fix DOES fire. Ruling CONVERGING,
    not swirling, and NO cap set - the trigger exists to catch a defect being relocated,
    and here the round-1 defect was genuinely resolved and measured resolved for the case
    that matters, leaving a narrower adjacent assertion-shape bug. But condition (c) is
    named for the conductor who holds the series: this should be the last round, and a
    round-3 finding again inside extension coverage IS the pattern and should escalate
    rather than iterate.
  MERGEABLE: NO from 83cd377. One Major stands. Expected round 3 is a one-line assertion
    change plus two sentence corrections, a minimal delta re-review.
abstract: Delta re-review round 2 of commit 83cd377871a1656caaec6b3ba45cdaeddc27eebf against
  issue 42, on round-1 HEAD 79cb5c9. Base verified first, tree clean, delta touching exactly
  the four claimed files. Suites run by the reviewer at that SHA in the detached worktree:
  scripts/tests 191 passed 0 failed 1 skipped of 192, matching the derived detached
  expectation and consistent with the car's attached 192 of 192 claim since the single skip
  is the pre-existing number-50 detached guard-runner skip; probes 24 of 24; store-checks
  178 of 178; the gate alone 10 of 10 on full history. All seven round-1 findings are
  PRESENT and closed with no drift, each re-verified by running rather than reading. Round-1
  MAJOR-1 is proven in BOTH directions by my own clone simulations: a depth-1 clone yields
  8 of 10 with the new boundary-resolvable assertion failing first and named, carrying both
  cause and remedy in its message, while a full clone of 509 commits yields 10 of 10.
  Round-1 MIN-1 is proven by fault injection rather than inspection: neutering the single
  hoisted Get-AddedCodeFiles broke both Describes including the scratch repo by-name proof,
  establishing that the scratch tests now bind to the production function. CLAUDE.md's
  correction is exemplary, naming round 1's false CI-wiring claim explicitly instead of
  quietly rewriting it and expressly declining to claim unobserved CI green. The disclosed
  mid-cycle reset --hard slip left no residue; the two at-risk pieces both landed accurate
  and a cross-reference sweep found no dead citations. Verdict REJECT on one NEW Major that
  round 2's own fix created: the new closed-set completeness guard silently swallows
  extensionless files. An uncited extensionless Dockerfile passes 10 of 10 green because the
  guard computes the unaccounted extension correctly and then the join-then-BeNullOrEmpty
  assertion shape discards it, the empty extension joining to an empty string, while the
  test header and CLAUDE.md both assert by-name completeness the guard does not deliver.
  Remedy is one line. Convergence ruled CONVERGING not swirling with no cap set, though the
  defect-created-by-previous-fix condition is named for the conductor and this should be the
  last round. NOT MERGEABLE from 83cd377. Honest boundary stated: real CI green was not
  observed and could not be, since the commit is on no remote branch; only the CI shape was
  proven, in both directions, by clone simulation, and the conductor must watch the run to a
  terminal state post-merge because fetch-depth 0 changes checkout for every matrix leg.
  Revert byte-identical, HEAD restored, porcelain empty, shared checkout untouched; nothing
  was edited, committed or pushed to the record.
```