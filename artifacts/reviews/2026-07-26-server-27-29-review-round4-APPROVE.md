<!-- starcar-integrity: sha256=69d63be7b4f94da1f599ae14bb130f80d3da1324fa4aa4cda318a657c6649116 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car server-27-29 review - round 4 (APPROVE, cap discharged, mergeable)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial one-shot delta, whole-train gate, cap discharged under owner ruling
Round: 4
Target: `commit d12606c on car/server-27-29; whole train 8b9df53..d12606c, rounds 1-4`
Base reviewed: `d12606c86cbac48f1e103c37fbe163d238f3dc7d`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

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
| Base commit the reviewer read (**the lookup key**) | `d12606c86cbac48f1e103c37fbe163d238f3dc7d` |

| Dispatch, the locator within the session | `a13a5df25c7c6bf77` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain d12606c86cbac48f1e103c37fbe163d238f3dc7d
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All verification complete. Tree clean at `d12606c`; read-only round.

---

# VERDICT: **APPROVE** — 0 Major, 1 Minor (non-blocking). **The train is MERGEABLE from `d12606c`.**

Car `server-27-29-car-r1` directed commit under owner ruling (b) | Review `server-27-29-review-r4` | Round 4, one-shot delta
Worktree `<repo>-wt\review-server-27-29`, HEAD `d12606c86cbac48f1e103c37fbe163d238f3dc7d` (verified first; clean).

**All eleven coordinates from my round-3 enumeration are repointed in durable forms, every one resolves at HEAD, and zero new line coordinates were minted anywhere in the diff — verified by my own grep, not the car's.** The removed-token tally comes to exactly eleven and matches my list one-for-one, with nothing extra removed and nothing missed. The cap's condition is discharged.

The one Minor is a historical overstatement in the new convention comment — the *scar* attached to the rule, not a citation. It blocks nothing.

---

## BASE-DELTA (#13)

Round 4, one-shot delta, scoped exactly as I prescribed in round 3: verify the eleven, nothing wider. **Base reviewed: `8075640`** (round-3 HEAD). Delta: `8075640..d12606c`, one commit, **6 files, +47/−33** — stat matches the claim exactly. Whole train under gate: `8b9df53..d12606c`, 5 commits.

## UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

1. **Rounds 1–2 behavioural work is carried forward** (four #27 seq transitions, both red-first fault injections, the browser wire trace with observed rgb, the #31 guard's fault-injected red, the independent 87-subjects/zero-in-flight store scan). Justified: rounds 2, 3 and 4 are each mechanically proven prose/string-only, so no observable behaviour can have moved since `4f06a4c`.
2. **`#63`/`#64`/`#65` existence** taken from the coordinator; not queried. My check was only that nothing in the diff contradicts them.
3. **This round's scope was deliberately narrow** and is not a fresh whole-repo citation audit. The eleven are verified; the repo's *other* citations were surveyed in round 3 and only the disclosed three (below) remain known-dead. A full standing audit is #65's job and the gate ticket's.
4. **Premise checked and found harmless:** the brief credits the car with correcting "MY brief's paraphrase" of the `ingest.js` function. I checked my round-3 verdict — it named no function for that site, only the file, line and the verbatim guard, so nothing in my record was in error. The substance is what matters and it verifies: `applyIncomingPayload` is the correct symbol.

---

## The eleven — verified table

Every "resolves at HEAD" below was checked by opening the target, not by reading the report.

### Class A — `board/server/poll.go:87-107`, the `#52 C51R-5` data-race invariant (3)

| # | Was | Now | Resolves at HEAD `d12606c` |
|---|---|---|---|
| 1 | `poll.go:197-203` | *"see PollOnce: it calls `s.buildSnapshot(...)` first and only reaches `s.mu.Lock()` afterward"* | ✓ `PollOnce` `:245` → `s.buildSnapshot(&amp;scanResult, …)` `:248` → `s.mu.Lock()` `:251`. The ordering the invariant depends on is stated as a *fact about the code*, verifiable by reading it. |
| 2 | `poll.go:168-182` | *"RunPollLoop, which only invokes PollOnce (in its own goroutine) after …"* | ✓ `RunPollLoop` `:216`, calls `s.TryBeginPoll()` `:224`, then `PollOnce` in a goroutine. |
| 3 | `poll.go:157-158` | *"TryBeginPoll's `atomic.CompareAndSwapInt32` has claimed the in-flight slot"* | ✓ `TryBeginPoll` `:205`, `atomic.CompareAndSwapInt32(&amp;s.pollInFlight, 0, 1)` `:206`. |

The old *"line numbers … will drift — re-verify before trusting them blindly"* disclaimer is gone, replaced by the convention statement. Correct call: the disclaimer was the thing that failed.

### Class B — `gating-matrix.md` row-name references (7)

Row names verified **unique** across both tables — I enumerated all 11 row-leading names; exactly one `| Disconnect (SSE, …` and exactly one `| Detector/discovery rendering `. A row-name citation is therefore unambiguous *and* survives any row insertion, which is precisely the failure mode that broke these.

| # | Citing site | Was | Now | Resolves |
|---|---|---|---|---|
| 4 | `docs/design/…design.md:525` | `gating-matrix.md:45` | *"gating-matrix.md's **Detector/discovery rendering row**"* | ✓ unique row, currently `:47` |
| 5 | `board/web/js/app.js:85` | `gating-matrix.md:43` | *"gating-matrix.md's **Disconnect row**"* | ✓ unique row, currently `:45` |
| 6 | `board/web/js/sse-protocol.js:16` | `gating-matrix.md:43` | Disconnect row + quote *"resets on: any frame arriving, data OR heartbeat"* | ✓ row **and** quote verbatim in it |
| 7 | `board/web/js/sse-protocol.js:80` | `gating-matrix.md:43` | Disconnect row + quote *"two consecutive `heartbeatMs` intervals pass with no frame"* | ✓ row **and** quote verbatim in it |
| 8 | `board/web/test/sse-protocol.test.js:2` | `gating-matrix.md:43` | Disconnect row | ✓ |
| 9 | `board/web/test/sse-protocol.test.js:13` | `gating-matrix.md:43` | Disconnect row | ✓ |
| 10 | `board/web/test/sse-protocol.test.js:58` — **a test NAME string** | `(gating-matrix.md:43)` | `(gating-matrix.md, Disconnect row)` | ✓ and **count-neutral**, proven below |

Sites 6 and 7 are the strongest form in the whole commit: **row name plus the row's own verbatim text**, so the citation self-checks — if the row is ever reworded, the quote stops matching and the drift is visible.

### Class C — `board/server/handlers.go:54` (1)

| # | Was | Now | Resolves |
|---|---|---|---|
| 11 | `board/web/js/ingest.js:59` + quote | *"board/web/js/ingest.js's `applyIncomingPayload` — cited by symbol and by the guard's own quoted code, not by line, since a citation into an untouched file can still be broken by an edit to that file's target"*, retaining the verbatim guard | ✓ `applyIncomingPayload` at `ingest.js:28`; the quoted guard `if (typeof payload.seq === 'number' &amp;&amp; payload.seq &lt;= state.lastAppliedSeq)` verbatim at `:62` |

The parenthetical is the sharpest lesson in the commit and it is correct: `handlers.go` was never touched by this train, yet the train broke its citation by editing the *target*. That is the fact my round-3 audit method could not see, now written into the code where the next reader will hit it.

### Token accounting — my own grep, not the car's

```
NEW path:line tokens added by d12606c:   (none)
REMOVED tokens:
   1 poll.go:197-203      1 poll.go:168-182      1 poll.go:157-158        &lt;- Class A = 3
   1 docs/contracts/gating-matrix.md:45          1 docs/contracts/gating-matrix.md:43
   5 gating-matrix.md:43                                                  &lt;- Class B = 7
   1 board/web/js/ingest.js:59                                            &lt;- Class C = 1
                                                                    TOTAL = 11
```

**Exactly my enumeration. Nothing extra removed, nothing missed, nothing minted.**

---

## Prose/string-only — mechanically re-derived, PASS

Stripping comments (`//`, `*`, `/*`) and blanks from both revisions:

```
IDENTICAL after stripping comments: board/server/poll.go            (321 code lines)
IDENTICAL after stripping comments: board/server/handlers.go         (70 code lines)
IDENTICAL after stripping comments: board/web/js/app.js              (87 code lines)
IDENTICAL after stripping comments: board/web/js/sse-protocol.js     (53 code lines)
*** DIFFERS: board/web/test/sse-protocol.test.js  -- exactly 1 line
```

The single difference is the `test(...)` **name string**. `go vet ./...` clean corroborates the Go side. The sixth file is the design doc (prose by construction).

**Test-name count-neutrality, proven by execution rather than argued:** whole-directory `node --test` reports **71 tests / 71 pass / 0 fail** — identical to rounds 1–3 — and running the file alone shows the renamed test present and passing as `ok 6 - ANY frame arriving (heartbeat OR data) resets the watchdog and clears a disconnected mark (gating-matrix.md, Disconnect row)`. Nothing greps test names; CI's zero-test guard parses `# tests N`, which is unchanged.

---

## The disclosed twelfth cluster — disclosure verified ACCURATE, correctly out of scope

The car disclosed three dead `gating-matrix.md:23` citations without fixing them. I tested both halves of the disclosure:

- **Are they dead?** Yes. All three claim `:23` is a staleness *truth-surface table row* (*"never (truth surface), DELIBERATE, no override"*). At HEAD, `gating-matrix.md:23` is severity-philosophy prose: *"NOTES, defects are FLAGS. An instrument that cries wolf is worse than no instrument."* Not a table row at all.
- **Are they genuinely pre-train?** Yes — and this is the part worth checking rather than accepting. `gating-matrix.md:23` is **byte-identical at base `8b9df53` and at HEAD**: this train's edits to that file were a net-zero header hunk and a `+2` hunk starting near line 30, both leaving line 23 in place. So they were **already dead before this train touched anything**. Not caused here, not this train's obligation.
- **Exactly three sites, confirmed by my own grep:** `docs/design/2026-07-22-dispatch-harness-design.md:53`, `docs/templates/design-doc.md:204`, `docs/templates/worked-spec.md:94` (coordinate mid-cell).

Correctly parked on **#65**. Disclosing rather than silently fixing was the right call — fixing them here would have exceeded the owner's ruled scope, and disclosure with a tracked owner is exactly what never-drop asks for.

---

## FINDING

### **R4-m1 (MINOR, non-blocking) — the new convention comment overstates its own scar**

`board/server/poll.go:104-106`:

&gt; *"…they did, **three separate times across three later trains**, and the disclaimer did not stop it."*

**"Three separate times" is right. "Across three later trains" is not.** I tested it against git history rather than assuming:

- The `#52 C51R-5` comment landed in `5207778`.
- Between then and this train's base `8b9df53`, exactly **one** other commit touched `poll.go` (`9e5261f`, the #30 train) — and the three coordinates were still **exact at `8b9df53`** (I proved this in round 3), so no earlier train broke them.
- All three drifts happened inside **this one train**: `3fd4fa6` (+67/−14), `9080a5f` (+26/−15), `8075640` (+7/−2) — three commits, one train. (`4f06a4c`'s poll.go edits landed below the cited targets and did not shift them.)

Correct text: *"three separate times across one later train's own three commits."* Note the true story is **more** damning, not less — three breakages inside a single train rather than spread thin across three — so the comment understates the density while overstating the breadth.

**Why Minor and not Major, tested for consistency against my own series:** this is not a coordinate — there is nothing to follow and nothing resolves wrongly. Its load-bearing conclusion (*the disclaimer did not stop it; symbols survive insertions, line numbers do not*) is **true and well-evidenced**. I graded comparable substance-right/detail-imprecise items Minor in round 1 (m2, the `output.go:9-32` range under-coverage; m3, the gating-matrix unreachable-branch phrasing), and grading this Major would be inconsistent with that, not stricter. It is a scar with a slightly wrong number, and CLAUDE.md wants the scar accurate — so it should be corrected on the next natural touch of `poll.go`, riding that commit rather than being batched into a cleanup pass that never comes.

---

## Suites — full set re-run at the final SHA `d12606c`

The brief scoped me to "the two suites." **I ran all six**, deliberately and for consistency with the standard I set in round 3: this dispatch is the whole-train merge gate, and a merge assertion carries coordinates at the exact commit being merged, not inherited from one commit back. Applying a looser standard here than in round 3 would be the inconsistency I have spent three rounds policing.

| Suite | Observed at `d12606c` | vs r1–r3 |
|---|---|---|
| Pester `scripts/tests` | **Total 195, Passed 194, Failed 0, Skipped 1** | identical |
| Pester `scripts/store-checks` | **194 / 194 / 0** | identical |
| Pester `scripts/probes` | **24 / 24 / 0** | identical |
| Go `board/` (5 pkgs) | **73 `--- PASS`, 0 `--- FAIL`**; `go vet ./...` clean | identical |
| `node --test` `board/web` (CI whole-dir form) | **`# tests 71 / # pass 71 / # fail 0`** | identical |
| Playwright #31 guard alone | **2 / 2 pass** | identical |

The car's "unchanged" claim is **TRUE**.

---

## SERIES HISTORY — for the landed record

| Round | Base → HEAD | Outcome | Substance |
|---|---|---|---|
| **r1** `server-27-29-review-r1` | `8b9df53` → `4f06a4c` | **REJECT, 3 Major / 3 Minor + 1 advisory** | All prose-only living-document defects; **mechanism verified sound**: four #27 seq transitions probed (incl. the `dispatched`→`overdue`-inside-one-bucket case the car had only asserted), both red-first pins re-derived by fault injection with failures quoted verbatim, the full wire sentence traced hop-by-hop to a computed pixel (`idle, quiet 3040s` at `rgb(217,213,201)`, byte-equal to the nominal probe), the #31 guard's non-vacuity re-proven by CSS fault injection, and the real-store zero-in-flight claim re-derived independently (87 subjects). Retro's design-rung concern ruled **CLEARED** on right-sizing + instrument-matching + the #30 precedent. |
| **r2** `…-r2` | `4f06a4c` → `9080a5f` | **REJECT, 1 Major** | All 7 r1 findings closed, **zero drifted**; the M1 remedy exceeded the ask (symbol references, proven durable under an 11-line in-commit shift); car self-caught and disclosed its own ripple. New Major: the fix minted one dead coordinate of the same class. Swirl trigger fired **by the letter** (2 of 3) — I declined to invoke it with reasons on the record (findings 7→1, class addressed structurally) and **set a cap**: round 3 is the last round on this class. |
| **r3** `…-r3` | `9080a5f` → `8075640` | **REJECT + cap-invoked ESCALATE** | Round 3's prescribed work correct and complete. Widening the audit past my own prescribed scope found **11 dead coordinates across 8 files**, all exact at base and falsified by this train. Disproved the "pre-existing drift" premise by testing *resolution at base*, not *token existence at base*. Named the instrument failure: the added-lines-only method — **the car's and mine** — is structurally blind to "unchanged citation, target moved." Recommended disposition (b) + two tickets. |
| **r4** `…-r4` | `8075640` → `d12606c` | **APPROVE, 1 Minor** | Owner ruled (b). All eleven repointed durably, all verified resolving, zero minted, prose/string-only proven, six suites green, twelfth cluster's disclosure verified accurate and correctly deferred to #65. |

**Trajectory: 3M → 1M → escalate → 0M.** Findings fell monotonically, the defect class was retired by mechanism rather than by patching, and the escalation produced the durable artifacts that justify it.

---

## Cap discharge and the tickets still owed

**Cap discharged.** Its condition was: *all eleven resolve durably and nothing new was minted.* Both verified independently above, under an owner ruling that authorised the directed commit rather than a fourth adversarial round. The class is closed for this train.

**Still owed, and they must not evaporate at the merge** (both from my round-3 escalation; the merge is exactly when open ends get dropped):

1. **A citation-resolver gate** — parse every `path:line` token in tracked text files, assert the path exists, the file has that many lines, and (strong form) a recorded anchor string still sits there. Third instance of a pattern already landed twice (`DocPolicy.Tests.ps1`, `CodeCitationPolicy.Tests.ps1`, per `docs/templates/repo-policy-check-patterns.md` §1). This is what retires the class repo-wide instead of train-by-train.
2. **A correction to the reviewer addendum's citation-audit method** — it must resolve every citation *in* every touched file **and** every citation *targeting* a touched file, not just those on added lines. Build it from this wreckage, which is now fully documented across r3 and r4.
3. **#65** carries the twelfth cluster (three verified-dead, verified-pre-train `gating-matrix.md:23` sites).

---

## Constitution check

| Law | Verdict |
|---|---|
| **1. Truth** | **HONORED.** Eleven surfaces that pointed somewhere other than what they claimed now point correctly, and two of them (sites 6, 7) self-check via verbatim quote anchors. One Minor overstatement recorded rather than waved through. |
| **3. Actionability** | **HONORED.** A reader auditing the single-poll data-race invariant is now sent to `PollOnce`/`RunPollLoop`/`TryBeginPoll` by name — findable in one search, immune to insertion. |
| **4. Nothing Silently Lost** | **HONORED, notably.** The car disclosed a twelfth cluster it was not asked to fix and did not quietly fix it out of scope either; it parked it with a tracked owner. Disclosure with an owner is the correct shape. |
| **6. One Truth** | **HONORED.** Zero behaviour changed, mechanically proven across five code files; the one string change is a test name, count-neutrality proven by execution. |
| **7. The Stranger** | **HONORED, and this is the commit's real product.** Symbol names, row names, and verbatim quote anchors are what a stranger can follow; eleven line numbers were eleven places a stranger was sent wrong. |
| **Guide star** | **HONORED on both sides.** The car wrote the convention's justification against its own train's record and disclosed a cluster that made more work visible. I record my own two-round miss and my wrong scope prescription in the series history above, unsoftened, because that is the only thing that made this escalation worth its cost. |
| **Healing Loop** | **HONORED.** The escalation produced durable artifacts — an enumerated fix list, a landed convention in code, and two tickets — rather than a feeling that something was learned. |

**Worktree state on exit:** clean, `git status --porcelain` empty, HEAD `d12606c86cbac48f1e103c37fbe163d238f3dc7d`. No fault injection this round; nothing edited, committed, or pushed.

**Merge is cleared.** The conductor may merge `d12606c`, close **#27** and **#29**, and roll the view train. Merge message should carry: Pester `scripts/tests` 194/0/1, `store-checks` 194/194, `probes` 24/24, Go 73/73 across 5 packages with vet clean, `node --test` 71/71, Playwright 2/2 — all observed at `d12606c` by this reviewer.

**File carrying the Minor (absolute):** `<repo>-wt\review-server-27-29\board\server\poll.go`, lines 104-106.

```starcar-artifact
outcome: APPROVE
task-id: server-27-29-review-r4
findings: 0 Major, 1 Minor (non-blocking). ALL ELEVEN COORDINATES FROM MY ROUND-3 ENUMERATION ARE REPOINTED IN DURABLE FORMS AND EVERY ONE RESOLVES AT HEAD, verified by opening each target rather than reading the report. Class A (3, the #52 C51R-5 data-race invariant in poll.go): poll.go:197-203 became "see PollOnce: it calls s.buildSnapshot(...) first and only reaches s.mu.Lock() afterward", verified PollOnce at :245, buildSnapshot at :248, s.mu.Lock at :251; poll.go:168-182 became a RunPollLoop symbol reference, verified at :216 calling s.TryBeginPoll() at :224; poll.go:157-158 became "TryBeginPoll's atomic.CompareAndSwapInt32", verified at :205-206. The old drift disclaimer is gone, correctly, since the disclaimer is the thing that failed. Class B (7, gating-matrix row-name references): design doc:525 now cites the Detector/discovery rendering row by name, and app.js:85, sse-protocol.js:16 and :80, and sse-protocol.test.js:2, :13 and :58 now cite the Disconnect row by name; I verified BOTH row names are UNIQUE across both tables in gating-matrix.md by enumerating all 11 row-leading names, so a row-name citation is unambiguous and survives any row insertion, which is exactly the failure that broke these. Sites 6 and 7 are the strongest form in the commit: row name PLUS the row's own verbatim text ("two consecutive heartbeatMs intervals pass with no frame" and "any frame arriving, data OR heartbeat", both confirmed verbatim in the row), so the citation self-checks if the row is ever reworded. Class C (1): handlers.go:54 now cites ingest.js's applyIncomingPayload by symbol plus the guard's own quoted code, verified applyIncomingPayload at ingest.js:28 and the quoted guard verbatim at :62; its parenthetical correctly captures the sharpest lesson, that handlers.go was never touched by this train yet the train broke its citation by editing the TARGET. TOKEN ACCOUNTING BY MY OWN GREP, not the car's: ZERO new path:line tokens added anywhere in the diff, and the removed tokens tally to exactly eleven matching my enumeration one-for-one (3 poll.go internals, 7 gating-matrix citers, 1 ingest.js) with nothing extra removed and nothing missed. PROSE/STRING-ONLY PASS, mechanically re-derived: stripping comments leaves poll.go (321 code lines), handlers.go (70), app.js (87) and sse-protocol.js (53) BYTE-IDENTICAL, the fifth file differing by exactly one line which is a test NAME string, and go vet clean corroborates. Test-name count-neutrality proven by execution not argument: whole-directory node --test reports 71/71/0 identical to all prior rounds, and running the file alone shows the renamed test present and passing as ok 6. R4-m1 (MINOR, non-blocking): poll.go:104-106's new convention comment says the coordinates drifted "three separate times across three later trains"; I tested it against git history rather than assuming, and "three separate times" is right while "across three later trains" is not - the #52 comment landed in 5207778, only ONE other commit (9e5261f, the #30 train) touched poll.go before base 8b9df53, and the coordinates were still exact at 8b9df53, so all three drifts happened inside THIS one train's own commits (3fd4fa6, 9080a5f, 8075640; 4f06a4c's poll.go edits landed below the targets). Correct text is "three separate times across one later train's own three commits" - and the true story is MORE damning, not less, since three breakages in one train is denser than three spread across three. Graded Minor for consistency with r1's m2 and m3 (substance-right, detail-imprecise): it is not a coordinate, nothing resolves wrongly, and its load-bearing conclusion that the disclaimer did not stop the drift while symbols survive insertions is true and well-evidenced. Should ride the next natural touch of poll.go rather than a cleanup pass. TWELFTH CLUSTER DISCLOSURE VERIFIED ACCURATE ON BOTH HALVES: the three gating-matrix.md:23 citations (dispatch-harness-design.md:53, design-doc.md:204, worked-spec.md:94, exactly three by my own grep) are dead - all claim :23 is a staleness truth-surface table row while :23 is severity-philosophy prose - AND genuinely pre-train, because gating-matrix.md:23 is byte-identical at base 8b9df53 and at HEAD (this train's edits to that file were a net-zero header hunk and a +2 hunk starting near line 30). Correctly parked on #65; disclosing rather than silently fixing was right, since fixing them would have exceeded the owner's ruled scope. SUITES, full set re-run at the final SHA rather than the two the brief scoped, deliberately for consistency with the standard I set in round 3 that a merge assertion carries coordinates at the exact commit being merged: Pester scripts/tests 195 total 194 passed 0 failed 1 skipped; store-checks 194/194/0; probes 24/24/0; Go 73 PASS 0 FAIL across 5 packages with go vet clean; node --test board/web whole-directory CI form 71 tests 71 pass 0 fail; Playwright #31 guard 2/2. All identical to rounds 1 through 3; the car's unchanged claim is TRUE. CAP DISCHARGED: its condition was that all eleven resolve durably and nothing new be minted, both verified independently, under an owner ruling that authorised a directed commit rather than a fourth adversarial round. STILL OWED and must not evaporate at the merge: a citation-resolver gate as the third instance of the repo-policy-check-patterns section 1 pattern already landed twice, a correction to the reviewer addendum's citation-audit method so it resolves every citation IN every touched file and every citation TARGETING a touched file, and #65 carrying the twelfth cluster. SERIES: r1 REJECT 3 Major 3 Minor plus 1 advisory with the mechanism verified sound and the retro's design-rung concern cleared; r2 REJECT 1 Major with all seven r1 findings closed zero drifted and a cap set after declining the swirl trigger with reasons; r3 REJECT plus cap-invoked ESCALATE after finding eleven dead coordinates my own added-lines-only audit method was structurally blind to; r4 APPROVE. Trajectory 3M to 1M to escalate to 0M. Constitution: Law 1 honored, eleven surfaces now point where they claim and two self-check via quote anchors; Law 3 honored, the data-race invariant is now findable by name; Law 4 honored notably, the car disclosed a twelfth cluster with a tracked owner rather than silently fixing or dropping it; Law 6 honored, zero behaviour changed and mechanically proven; Law 7 honored and this is the commit's real product; guide star honored on both sides, with my own two-round miss and wrong scope prescription recorded unsoftened in the series history. MERGE CLEARED from d12606c. Worktree clean, no fault injection, nothing edited committed or pushed.
abstract: Final one-shot delta re-review of the directed commit d12606c, landed under the owner's disposition (b) ruling, closing the series I escalated in round 3. Scoped exactly as I prescribed: verify my eleven enumerated coordinates and nothing wider. All eleven are repointed in durable forms and all eleven resolve at HEAD, each checked by opening the target - three poll.go internals converted to function-symbol references whose described ordering I confirmed against the real code, seven gating-matrix citers converted to row-name references whose uniqueness across both tables I verified so they survive any future row insertion (two of them anchored additionally by the row's own verbatim quoted text, making them self-checking), and one handlers.go site converted to a symbol plus verbatim-quote dual anchor. My own grep confirms zero new line coordinates minted anywhere in the diff, and the removed-token tally comes to exactly eleven matching my enumeration one-for-one. The diff is mechanically proven prose-and-string-only, with the single string change being a test name whose count-neutrality I proved by execution rather than argument. The car's disclosed twelfth cluster of three pre-existing dead citations verifies accurate on both halves - genuinely dead, and genuinely pre-train since the target line is byte-identical at base and HEAD - and is correctly deferred to its ticket rather than fixed out of scope. All six suites re-run at the final SHA rather than the two the brief scoped, for consistency with the standard I set in round 3 that a merge assertion carries coordinates at the exact commit being merged; every count identical to prior rounds. One Minor recorded and non-blocking: the new convention comment attributes the drift to three later trains when git history shows all three happened inside this single train's own commits, an overstatement of breadth that understates the true density, graded consistently with the substance-right detail-imprecise Minors from round one. The cap's condition is discharged, the defect class was retired by mechanism rather than patched train-by-train, and three follow-up obligations are restated so they do not evaporate at the merge. Series trajectory 3 Major to 1 Major to escalation to zero, with my own two-round audit miss and my wrong scope prescription recorded unsoftened in the landed history. APPROVE; the train is mergeable.
```