<!-- starcar-integrity: sha256=611979668afbd82e28506a36dcb98fe517ef9ec2e39fe8f3ae2b1b50d312ad06 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car server-27-29 review - round 3 (REJECT, cap invoked, ESCALATED to owner)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial delta re-review, whole-train gate, cap invoked
Round: 3
Target: `commit 8075640 on car/server-27-29; whole train 8b9df53..8075640`
Base reviewed: `807564086a4d427c1a8b0ecf002b1e4177b2dcec`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a13a5df25c7c6bf77`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `807564086a4d427c1a8b0ecf002b1e4177b2dcec` |

| Dispatch, the locator within the session | `a13a5df25c7c6bf77` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 807564086a4d427c1a8b0ecf002b1e4177b2dcec
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Audit complete. Tree clean at `8075640`; this round was read-only.

---

# VERDICT: **REJECT — and ESCALATE under my own round-2 cap.** Not mergeable from `8075640`.

Car `server-27-29-car-r1` fix cycle | Review `server-27-29-review-r3` | Round 3, delta
Worktree `<repo>-wt\review-server-27-29`, HEAD `807564086a4d427c1a8b0ecf002b1e4177b2dcec` (verified first; clean).

**Round 3's own work is correct, complete, and exactly what I prescribed.** R2-M1 is closed properly by symbol/description, the general-rule sentence is accurate and well-placed, the diff is mechanically proven comment-only, zero new citations were introduced, and all six suites are green at the final SHA.

**And the train is still not mergeable — because the audit method I prescribed was aimed at the wrong scope, and when I widened it this round I found eleven dead citation coordinates that this train broke and that three rounds of adversarial review, mine included, could not see by construction.** My round-2 cap says that when the defect class survives round 3, the instrument is failing at this scale and it goes to the owner instead of a round 4. It is failing, I can now name exactly how, and I am invoking the cap.

**Envelope outcome is `REJECT`** — that is the gate decision I own and am certain of. The ESCALATION is the required *disposition*: per the cap, the conductor must **not** dispatch round 4 on this class; it goes to the owner with the packet below.

---

## BASE-DELTA (#13)

Round 3, delta. **Base reviewed this round: `9080a5f`** (round-2 HEAD, which I rejected). Delta: `9080a5f..8075640`, one commit, **2 files, +13/−3** — stat matches the car's claim exactly. Whole train under gate: `8b9df53..8075640`, 4 commits.

Series: **r1 = 3 Major / 3 Minor + 1 advisory → r2 = 1 Major → r3 = 1 Major (11 coordinates), newly visible.**

## UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

1. **Rounds 1–2 empirical work is carried forward** (the four #27 seq transitions, both red-first fault injections, the browser wire trace with observed rgb, the #31 guard's fault-injected red). Justified: rounds 2 and 3 are both mechanically proven prose-only, so no observable behaviour can have moved since `4f06a4c`.
2. **`#63`/`#64` existence** taken from the coordinator, not queried.
3. **My rounds-1 and -2 citation audits are now known-incomplete** and should not be relied on as a clean bill for citation truth. Their method — extract `path:line` tokens from the **added** lines of the diff — cannot see the class found this round. Anyone auditing this train should use the census below, not my earlier ones.

---

## Round 3's prescribed work — all PRESENT, all correct

| Item | Status | Verification at HEAD `8075640` |
|---|---|---|
| **R2-M1** | **CLOSED, correctly** | `poll.go:43-48` now reads *"measured: elapsedbucket_test.go's `TestPollOnceElapsedSecondsBucketedForChangeDetection` — `dispatchElapsed(snap2)` must read 10, the prior snapshot's value, while actual elapsed is 50"*. **No line coordinate remains** in that paragraph. Every element checked against the real test: the function exists at `elapsedbucket_test.go:51`; `dispatchElapsed(snap2)` with `got != 10` at `:112`; `snap2` comes from `srv.PollOnce(recordAt.Add(50 * time.Second))` at `:102`, so "actual elapsed is 50" is exact. The description is durable — it names symbols that a line shift cannot move. |
| **General-rule sentence** | **Accurate and well-placed** | `elapsedbucket_test.go:35-40`, appended to the paragraph that already establishes the symbol convention (`:29-35`) rather than orphaned. Its claim — *"the citing comment and its target can shift by different amounts in the same diff and no amount of care catches that by eye"* — is precisely what happened in `9080a5f` (poll.go's paragraph shifted 11, the test's assertion shifted 8). It is honest that the remedy must be mechanical, not attentional. That honesty is, unfortunately, load-bearing for this verdict. |
| **Prose-only** | **PASS, mechanically re-derived** | Stripping whole-line comments and blanks: `poll.go` **321 code lines identical**, `elapsedbucket_test.go` **69 code lines identical**. Both hunks comment-only. `go vet ./...` clean corroborates. |
| **No new citation introduced** | **CONFIRMED** | `git diff 9080a5f 8075640 -U0 \| grep '^+' \| grep -oE 'path:line'` → **empty**. |

**Where the car's re-audit claim fails the premise check (#46).** The claim relayed to me was that the remaining internal `poll.go` line citations are *"pre-existing #52-era drift predating base 8b9df53 (out of scope, disclosed)."* The grep half is true — those tokens do predate `8b9df53`. But "predates the base" is the wrong question. **The right question is whether they RESOLVED at the base.** I ran it:

```
BASE 8b9df53 poll.go:197-203  -&gt;  197: func (s *Server) PollOnce(...)
                                  200: candidate := s.buildSnapshot(...)   &lt;- "line 200" as claimed
                                  203: s.mu.Lock()                          &lt;- "line 203" as claimed
BASE 8b9df53 poll.go:157-158  -&gt;  157: func (s *Server) TryBeginPoll() bool
                                  158: return atomic.CompareAndSwapInt32(...)
BASE 8b9df53 poll.go:168-182  -&gt;  168: func (s *Server) RunPollLoop(...)
```

**Exact at the base, to the line, all three.** They are not pre-existing drift. They were **true when this train started and this train made them false.** The living-document rule is unambiguous about whose obligation that is: *the commit that invalidates a document updates that document, in the same commit.* The invalidating commits are `3fd4fa6` and `4f06a4c`, inside this train.

---

## THE FINDING

### **R3-M1 (MAJOR) — this train falsified eleven citation coordinates across eight files by inserting lines above their targets, and left every one of them standing**

All eleven were **verified correct at base `8b9df53`** and are **verified dead at HEAD `8075640`**. Three distinct causes, all in-train.

**Class A — `poll.go` internal, broken by `3fd4fa6`'s +29-line const block at `poll.go:27-65`.** These support the `#52 C51R-5` **single-poll data-race invariant** — the most consequential place in this file for a coordinate to be wrong, because a reader auditing thread safety follows them:

| Citing site | Cites | Claim | Lands on at HEAD | Real target now |
|---|---|---|---|---|
| `board/server/poll.go:89` | `poll.go:197-203` | "PollOnce — buildSnapshot runs at line 200, s.mu.Lock only at line 203" | `return s.lastPollAt` / `}` / `TryBeginPoll`'s doc + body | `:242` / `:245` / `:248` |
| `board/server/poll.go:93` | `poll.go:168-182` | "RunPollLoop" | `if budget, err := fold.LoadDefaultBudget(...)` inside `NewServer` | `:213` |
| `board/server/poll.go:95` | `poll.go:157-158` | "TryBeginPoll's atomic.CompareAndSwapInt32" | `Register: store.RegisterForCode("recognition-vocabulary-unreadable"),` | `:202-203` |

**Class B — `gating-matrix.md` rows shifted +2 by `4f06a4c`'s Idle-row and section-paragraph insertions.** Seven citers, none updated:

| Citing site | Cites | Claim | Lands on at HEAD | Real target |
|---|---|---|---|---|
| `docs/design/2026-07-21-v0-yard-skeleton-design.md:525` | `gating-matrix.md:45` | "quotes the pre-#30 Rule 4 verbatim" (the Detector/discovery row) | the **Disconnect** row | `:47` |
| `board/web/js/app.js:85` | `gating-matrix.md:43` | "gating-matrix.md:43's **disconnect row**" | the **Staleness** row | `:45` |
| `board/web/js/sse-protocol.js:16` | `gating-matrix.md:43` | disconnect rule | Staleness row | `:45` |
| `board/web/js/sse-protocol.js:80` | `gating-matrix.md:43` | quotes *"two consecutive heartbeatMs"* | Staleness row | `:45` |
| `board/web/test/sse-protocol.test.js:2` | `gating-matrix.md:43` | disconnect row | Staleness row | `:45` |
| `board/web/test/sse-protocol.test.js:13` | `gating-matrix.md:43` | disconnect row | Staleness row | `:45` |
| `board/web/test/sse-protocol.test.js:58` | `gating-matrix.md:43` | **inside a test NAME string** — the dead coordinate prints in suite output | Staleness row | `:45` |

**Class C — `ingest.js` comment expanded +3 by `3fd4fa6`:**

| Citing site | Cites | Claim | At HEAD |
|---|---|---|---|
| `board/server/handlers.go:54` | `board/web/js/ingest.js:59` | quotes `"if (typeof payload.seq === 'number' &amp;&amp; payload.seq &lt;= state.lastAppliedSeq)"` | `:59` is now a comment line; the quoted code is at **`:62`** |

*Note on Class C: `handlers.go` was never touched by this train. The train broke a citation in an untouched file by editing the target — which is why "audit the files you changed" is also not a sufficient method.*

**Attribution, stated precisely because blameless is not vague.** Nobody wrote a false citation. Every one of these eleven was written true by an earlier author (`design:525` by `fdfa80f`, the #30 train's round-1 fix; the `poll.go` trio by the #52 car; the rest earlier still). **This train falsified true statements and did not notice.** The obligation to update sits with the invalidating commit, and that is `3fd4fa6`/`4f06a4c`.

**Verified NOT broken** (checked at base and HEAD, resolve identically — reported so the fix list is bounded and nobody re-audits them): `compose.js:23-25` (`mostSevereRegister`); `design…md:133` (the D19 row); `board/fold/algorithm.go:221-222`; `algorithm.go:240`; `dom-writer.js:200-202`; `dom-writer.js:201`; `render.js:188`; `output.go:9-35`; `config.go:42`; `state-ledger.md:102` and `:108`; and the `git show 8b9df53:board/server/poll.go` pin, which is immutable by construction and is the one form in this whole train that cannot rot.

---

## WHY THIS IS AN ESCALATION AND NOT A ROUND 4

**The instrument, named.** Both the car's audit and mine, in every round, were: *extract `path:line` tokens from the ADDED lines of the diff and resolve them.* That method is **structurally blind** to this entire class, because the defective citation is a line **nobody edited** — only its target moved. Three rounds of an adversary explicitly hunting citation truth found zero of these eleven. That is not carelessness; it is a method that cannot see the defect.

**The cap fires on its own terms.** Round 3 *introduced* nothing — but it *leaves* eleven, and the reason is the method, not the care. My round-2 cap: *"If round 3 leaves, or introduces, any further citation-truth defect, that is the instrument failing at this scale and it escalates to the owner instead of a round 4."*

**A round 4 would not fix this.** Hand-repairing eleven coordinates leaves the *next* line insertion to break the *next* set — this train broke coordinates in three separate commits (`3fd4fa6` broke 4, `4f06a4c` broke 7, `9080a5f` broke 1, which I caught as R2-M1). Hand-maintained line coordinates in a repo that constantly edits its own files are **vigilance-tier**, and the Healing Loop already ranks attention below mechanism. The round-3 comment the car just wrote says so itself: *"no amount of care catches that by eye."* It is right, and that sentence is an argument for a gate, not for another round.

**The prior art exists in-repo and I checked before proposing anything.** `docs/templates/repo-policy-check-patterns.md` §1's gate pattern is already instantiated twice — `scripts/tests/DocPolicy.Tests.ps1` and `scripts/tests/CodeCitationPolicy.Tests.ps1`. A citation-**resolver** gate is that same pattern aimed at `path:line` tokens: parse every token in tracked text files, assert the path exists and the file has that many lines, and (the strong form) assert a recorded anchor string still sits at the cited line. This is a ticket, not a car round, and it is the third instance of a landed pattern rather than an invention.

**My own miss, stated plainly.** I ran the wrong audit in round 1 and again in round 2, and in round 2 I prescribed the narrow scope — *"re-resolve that single citation and re-run nothing else"* — which is why round 3 did not look wider. The car did exactly what I asked, well. The gap is mine.

---

## Suites — full set re-run at the final SHA `8075640`

**My call, stated as asked:** the diff is two comment hunks in Go files, so Go alone would be *necessary and sufficient for the delta*. I ran **all six anyway**, because this dispatch is the whole-train merge gate and a merge assertion needs coordinates at the exact commit being asserted, not inherited from two commits back.

| Suite | Observed at `8075640` | vs r1/r2 |
|---|---|---|
| Pester `scripts/tests` | **Total 195, Passed 194, Failed 0, Skipped 1** | identical |
| Pester `scripts/store-checks` | **194 / 194 / 0** | identical |
| Pester `scripts/probes` | **24 / 24 / 0** | identical |
| Go `board/` (5 pkgs) | **73 `--- PASS`, 0 `--- FAIL`**; `go vet ./...` clean | identical |
| `node --test` `board/web` (CI whole-dir form) | **`# tests 71 / # pass 71 / # fail 0`** | identical |
| Playwright #31 guard alone | **2 / 2 pass** | identical |

The car's "suites unchanged" claim is **TRUE**.

---

## MERGEABILITY AND RECOMMENDED DISPOSITION (the owner's ruling, not mine)

**Not mergeable from `8075640`.** Eleven citation-truth defects stand, three of them supporting a concurrency-safety invariant.

Three dispositions, with my lean stated and the decision explicitly the owner's:

- **(a) Land now, fix later.** Defensible: the *code* is sound and independently verified (rounds 1–2), all suites are green, and none of the eleven is a false claim about *behaviour* — they are dead pointers to true statements. Risk: eleven lying canaries land on `main`, and the repo's own precedent (C2R-1, M1, R2-M1) rejected merges for strictly fewer.
- **(b) One prose commit fixing all eleven, then land, then file the gate.** **My lean.** The discovery cost is already paid — every coordinate and its correct value is enumerated above, so this is mechanical, and the car has already shown it can do the durable form (symbols, or the `git show` base pin). Then the gate ticket prevents round N+1.
- **(c) Build the gate first and let it generate the fix list.** Most rigorous, and it would independently confirm my eleven; costs a train the view work is waiting on.

**The cap binds the conductor: do not dispatch round 4 on this class without an owner ruling.** If the owner rules (b), that is a *directed* prose commit under a ruling, not another adversarial round on the same class — and I would re-review it as a one-shot delta against the enumerated list.

Two tickets are owed regardless of the disposition, per never-drop:
1. **Citation-resolver gate** (`repo-policy-check-patterns.md` §1 pattern, third instance) — the mechanism that retires this class.
2. **Reviewer-method correction** — the citation audit in the reviewer addendum must resolve *every* citation in *every touched file* **and** every citation *targeting* a touched file, not just those on added lines. This finding is the wreckage the fix should be built from.

---

## Constitution check (round-3 delta + whole train)

| Law | Verdict |
|---|---|
| **1. Truth** | Round 3 **honored** — R2-M1's falsehood removed and replaced with a durable, verified description. Whole train **violated** by R3-M1: eleven information surfaces now point somewhere other than what they claim, including `app.js:85`'s "the disconnect row" pointing at Staleness. |
| **4. Nothing Silently Lost** | **Honored throughout**, and notably by the car in round 3: it wrote the general rule *against itself*, recording why the class defeats care. That sentence is what let me name the instrument failure precisely. |
| **6. One Truth** | **Honored.** Zero behaviour changed in rounds 2 and 3, mechanically proven; no derivation moved, no second copy created. |
| **7. The Stranger** | **Honored by the fix, indicted by the finding.** A symbol reference and a `git show` base pin are what a stranger can follow; eleven stale coordinates are eleven places a stranger is sent wrong. |
| **Guide star** | **Honored on both sides.** The car disclosed its own ripple in round 2 and wrote the rule that convicts the class in round 3. I am recording my own two-round miss and my wrong scope prescription with the same precision, because softening that would corrupt the only thing this escalation is worth. |
| **Healing Loop / cap** | **Invoked as written.** A REJECT and an escalation are success outcomes; the durable artifacts are this enumerated fix list and two tickets. |

**Worktree state on exit:** clean, `git status --porcelain` empty, HEAD `807564086a4d427c1a8b0ecf002b1e4177b2dcec`. No fault injection this round; nothing edited, committed, or pushed.

**Files carrying the eleven coordinates (absolute):**
`<repo>-wt\review-server-27-29\board\server\poll.go` (:89, :93, :95) · `…\board\server\handlers.go` (:54) · `…\board\web\js\app.js` (:85) · `…\board\web\js\sse-protocol.js` (:16, :80) · `…\board\web\test\sse-protocol.test.js` (:2, :13, :58) · `…\docs\design\2026-07-21-v0-yard-skeleton-design.md` (:525)

```starcar-artifact
outcome: REJECT
task-id: server-27-29-review-r3
findings: 1 Major spanning 11 coordinates, plus a named instrument failure that triggers my own round-2 cap and sends the disposition to the owner. ROUND 3'S OWN WORK IS CORRECT AND COMPLETE: R2-M1 is closed properly by symbol/description at poll.go:43-48 with no line coordinate remaining, and every element verified against the real test (TestPollOnceElapsedSecondsBucketedForChangeDetection exists at elapsedbucket_test.go:51, dispatchElapsed(snap2) with got != 10 at :112, snap2 from PollOnce(recordAt.Add(50 * time.Second)) at :102, so "must read 10 while actual elapsed is 50" is exact); the general-rule sentence at elapsedbucket_test.go:35-40 is accurate and well-placed, appended to the paragraph that already establishes the symbol convention; prose-only re-derived mechanically (poll.go 321 code lines and elapsedbucket_test.go 69 code lines both BYTE-IDENTICAL after stripping whole-line comments, go vet clean); and zero new file:line tokens were introduced (git diff -U0 grep returns empty). R3-M1 (MAJOR, 11 coordinates across 8 files): this train falsified eleven citation coordinates by inserting lines above their targets and left every one standing. I disproved the relayed premise that these are "pre-existing #52-era drift predating base 8b9df53, out of scope" - "predates the base" is the wrong test; the right test is whether they RESOLVED at the base, and I ran it: at 8b9df53 poll.go:197-203 gave PollOnce at 197, buildSnapshot at exactly line 200 and s.mu.Lock at exactly line 203 as claimed; poll.go:157-158 gave TryBeginPoll and its CompareAndSwapInt32; poll.go:168-182 gave RunPollLoop. Exact at base, to the line, all three. They were TRUE when this train started and this train made them FALSE, so the living-document rule puts the obligation on the invalidating commits, which are 3fd4fa6 and 4f06a4c, in scope. CLASS A, broken by 3fd4fa6's +29-line const block at poll.go:27-65, supporting the #52 C51R-5 single-poll DATA-RACE invariant: poll.go:89 cites poll.go:197-203 and now lands on "return s.lastPollAt" and TryBeginPoll (real 242/245/248); poll.go:93 cites poll.go:168-182 and lands on fold.LoadDefaultBudget inside NewServer (real 213); poll.go:95 cites poll.go:157-158 and lands on a store.RegisterForCode board-condition literal (real 202-203). CLASS B, gating-matrix.md rows shifted +2 by 4f06a4c's Idle row and section paragraph, seven citers none updated: design doc:525 cites gating-matrix.md:45 for "the pre-#30 Rule 4 verbatim" (the Detector row, correct at base) and now lands on the Disconnect row (real 47); app.js:85 which literally says "gating-matrix.md:43's disconnect row", sse-protocol.js:16 and :80 (the latter quoting "two consecutive heartbeatMs"), and sse-protocol.test.js:2, :13 and :58 (the last inside a TEST NAME string, so the dead coordinate prints in suite output) all cite gating-matrix.md:43 which was the Disconnect row at base and is now the Staleness row (real 45). CLASS C: handlers.go:54 cites board/web/js/ingest.js:59 and quotes the seq guard verbatim; at base :59 IS that line, at HEAD it is a comment and the code is at :62 - and handlers.go was never touched by this train, proving "audit the files you changed" is also insufficient. Attribution stated precisely: nobody wrote a false citation, every one was written true by an earlier author (design:525 by fdfa80f from the #30 train, the poll.go trio by the #52 car); this train falsified true statements and did not notice. VERIFIED NOT BROKEN, so the fix list is bounded: compose.js:23-25, design:133, algorithm.go:221-222, algorithm.go:240, dom-writer.js:200-202, dom-writer.js:201, render.js:188, output.go:9-35, config.go:42, state-ledger.md:102 and :108, and the git show 8b9df53 pin which is immutable by construction. THE INSTRUMENT FAILURE, named: both the car's audit and MINE in every round extracted path:line tokens from the ADDED lines of the diff, a method structurally blind to a citation nobody edited whose target moved; three rounds of an adversary explicitly hunting citation truth found zero of these eleven. My round-2 cap fires on its own terms - round 3 introduced nothing but LEAVES eleven, and the cause is the method not the care - so this ESCALATES to the owner instead of a round 4, because hand-repairing eleven coordinates leaves the next insertion to break the next set (this train broke coordinates in three separate commits: 3fd4fa6 four, 4f06a4c seven, 9080a5f one which I caught as R2-M1). The round-3 comment the car just wrote says it itself: "no amount of care catches that by eye" - an argument for a gate, not another round. Prior art checked before proposing: docs/templates/repo-policy-check-patterns.md section 1's gate pattern is already instantiated twice as DocPolicy.Tests.ps1 and CodeCitationPolicy.Tests.ps1, so a citation-resolver gate is the third instance of a landed pattern, not an invention. MY OWN MISS STATED PLAINLY: I ran the wrong audit in rounds 1 and 2 and in round 2 prescribed the narrow scope ("re-resolve that single citation and re-run nothing else"), which is why round 3 did not look wider; the car did exactly what I asked, well. SUITES, full set re-run at the final SHA rather than just Go, deliberately because this is the whole-train merge gate and a merge assertion needs coordinates at the exact commit: Pester scripts/tests 195 total 194 passed 0 failed 1 skipped; store-checks 194/194/0; probes 24/24/0; Go 73 PASS 0 FAIL across 5 packages with go vet clean; node --test board/web whole-directory CI form 71 tests 71 pass 0 fail; Playwright guard 2/2. All identical to rounds 1 and 2; the car's unchanged claim is TRUE. DISPOSITION IS THE OWNER'S, three options offered with my lean: (a) land now and fix later, defensible since the code is sound and none of the eleven is a false claim about behaviour, but eleven lying canaries reach main and precedent rejected merges for fewer; (b) MY LEAN, one directed prose commit fixing all eleven then land then file the gate, mechanical now that every coordinate and its correct value is enumerated in this verdict; (c) build the gate first and let it generate the list, most rigorous but costs a train the view work is waiting on. Cap binds the conductor: no round 4 on this class without an owner ruling. Two tickets owed regardless: a citation-resolver gate, and a correction to the reviewer addendum's citation audit so it resolves every citation in every touched file AND every citation targeting a touched file, built from this wreckage. Constitution: Law 1 honored by round 3 and violated by the train's eleven; Law 4 honored notably, the car wrote the general rule against itself which is what let me name the failure; Law 6 honored, zero behaviour changed and mechanically proven; Law 7 honored by the fix form and indicted by the finding; guide star honored on both sides, the car disclosing its own ripple and me recording my two-round miss and wrong scope prescription. Worktree clean, no fault injection this round, nothing edited committed or pushed.
abstract: Round-3 delta re-review of the one-commit prose fix 8075640 on round-2 HEAD 9080a5f, the targeted delta I myself prescribed, under my own round-2 cap. The prescribed work is correct and complete: R2-M1's dead coordinate is now a symbol-and-description citation verified element by element against the real test, the accompanying general rule about citations into same-commit-edited files is accurate and well-placed, the two hunks are mechanically proven comment-only, no new citation was introduced, and all six suites are green at the final SHA. But when I widened the audit beyond the scope I had prescribed, I found eleven citation coordinates across eight files that this train falsified and left standing - three inside poll.go supporting a data-race safety invariant, seven pointing into gating-matrix.md rows that the Idle-row insertion shifted, and one in an untouched file whose target the train moved. I disproved the relayed framing that these were pre-existing out-of-scope drift by testing the right question: every one of them resolved EXACTLY at the train's base commit and was made false by the train's own line insertions, which puts them squarely under the living-document rule. The decisive discovery is the instrument, not the coordinates: the audit method used by the car and by me in all three rounds extracted citations from the diff's ADDED lines, which is structurally blind to a citation nobody edited whose target moved, and so an adversary explicitly hunting citation truth found none of these in three passes. That is exactly the condition my round-2 cap was written to detect, so I invoke it: REJECT the merge, and send the disposition to the owner rather than dispatching a fourth round that the same method would fail again. I recommend a directed prose commit against the eleven coordinates now enumerated here, then landing, plus a citation-resolver gate as the third instance of a repo-policy pattern already landed twice, plus a correction to the reviewer addendum's audit method. I record without softening that the wrong scope was mine, prescribed in round 2, and that I missed this class twice. Not mergeable from 8075640; the code remains independently verified sound and every suite green.
```