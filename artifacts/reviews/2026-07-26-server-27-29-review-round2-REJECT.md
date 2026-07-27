<!-- starcar-integrity: sha256=38324224f0fc32ea6115abe61d355acb04fb5a0cb0a9edbad64986efa3a6c61a covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car server-27-29 delta re-review - round 2 (REJECT, 1 new Major, cap set)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial delta re-review
Round: 2
Target: `commit 9080a5f on car/server-27-29 (round-1 prose remedies)`
Base reviewed: `9080a5f0da14d35cb6a12ee4a9903cb072b8146d`
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
| Base commit the reviewer read (**the lookup key**) | `9080a5f0da14d35cb6a12ee4a9903cb072b8146d` |

| Dispatch, the locator within the session | `a13a5df25c7c6bf77` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 9080a5f0da14d35cb6a12ee4a9903cb072b8146d
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Delta re-review complete. Worktree clean at `9080a5f`; this round was read-only (no fault injection needed — round 1's empirical work stands and the prose-only claim is mechanically provable).

---

# VERDICT: **REJECT** — 1 Major (new), 0 outstanding from round 1

Car `server-27-29-car-r1` fix cycle | Review `server-27-29-review-r2` | Round 2, delta
Worktree `<repo>-wt\review-server-27-29`, HEAD `9080a5f0da14d35cb6a12ee4a9903cb072b8146d` (verified before any action; clean).

**All seven round-1 findings are genuinely closed — none DRIFTED, and the M1 remedy is better than what I asked for.** The car did not just repoint the dead line numbers; it converted them to **symbol references**, and I verified that remedy provably works: `PollOnce` moved from `poll.go:226` to `:237` inside this very commit, an 11-line shift that would have killed a hardcoded range, and the symbol citations survived it. The car also **self-caught and disclosed** a ripple its own M3 expansion caused to a citation I had marked *accurate* in round 1 (`poll.go:373-376` → `384-387`, confirmed) and fixed that by symbol too rather than re-pinning a number. That is the class being resolved structurally, not patched.

The REJECT is for **one new dead citation of that same class, minted by this fix commit, at a site the car did not apply its own remedy to.** It is one line. I am rejecting because I ruled this exact class Major one round ago and because `artifacts/reviews/2026-07-23-board-car2-review-round1.md:97,109` ruled it Major before that — approving it now would make my round-1 verdict a standard applied when convenient. The conductor's framing that my APPROVE is the gate the train rolls behind is precisely the pressure that rule exists to resist.

---

## BASE-DELTA (#13)

Round 2, delta. **Base reviewed this round: `4f06a4c`** (round-1 HEAD, the commit I rejected). Delta under review: `4f06a4c..9080a5f`, one commit, **7 files, +72/−35**. Round-1 empirical work against `8b9df53..4f06a4c` stands and was not re-derived; this round verifies sentences, re-resolves every citation, mechanically audits the prose-only claim, and re-runs all six suites.

Series held by me: **r1 = 3 Major / 3 Minor + 1 advisory (all prose-only) → r2 = 1 Major / 0 Minor.**

## UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

1. **Round-1 measurements are carried forward, not re-derived** — the four #27 seq transitions, the two red-first fault injections, the browser wire trace with observed rgb values, and the #31 guard's fault-injected red. Justified: the delta is mechanically proven prose-only (below), so no observable behaviour can have moved. Anyone re-auditing should read those from the round-1 verdict, not from this one.
2. **`#63` and `#64`** — I take their existence from the coordinator's message; I did not query the tracker. My check was the weaker but sufficient one the brief asked for: that the new §12b paragraph does not *contradict* them. It does not.
3. **The r1 browser observation `ageBucketMs: 3040000`** remains wall-clock dependent and will differ on any re-run; unchanged caveat.

---

## Disposition of round-1 findings — Present / Absent / DRIFTED

| ID | Status | Verification at HEAD `9080a5f` |
|---|---|---|
| **M1** (3 dead citations) | **PRESENT — closed**, *class recurs once* → see R2-M1 | `elapsedbucket_test.go:17-20` now scopes `poll.go:399-412` to *"as of base commit 8b9df53"* with `git show`; I ran it — base lines 399 and 412 are exactly `// DISCLOSED, OUT OF SCOPE (found writing the C4R-3...` and `// (deferred; triggers stated there).` **Immutable and exact.** The two `poll.go:190-196` sites became symbol references to `PollOnce`'s doc comment (`:237`, phrase present) and `computeLiveFreshness` (`:410`). `ageBucketMsGranularity` cited as "just above `elapsedSecondsBucketGranularity`" — true (`:25` and `:65`, nothing but their doc comments between). |
| **M2a** | **PRESENT — closed** | `compose.js:90-92` now says `"stale"` and `"idle"` "are the two kinds that do". Verified **exhaustively**: `grep ageBucketMs schema/yard-snapshot.schema.json` returns exactly two `required` arrays containing it — `:43` (stale) and `:51` (idle). The claim is true *and* complete. "below in this same switch" → `case 'idle'` at `:103`, below `case 'fresh'` at `:89`. ✓ |
| **M2b** | **PRESENT — closed** | `ingest.test.js:63-72` now frames #27 as RESOLVED with correct tense: churn "true before the fix … unchanged after it (seq now only bumps on a real change)". Matches my r1 probes. Cites `elapsedSecondsBucketGranularity` **by symbol, no line number** — the convention applied correctly. Consistent with the `ingest.js:51-60` twin I passed in r1. |
| **advisory** (cascade failure message) | **PRESENT — closed** | `browser-register-cascade.test.js:114-117` now describes the scratch fixture. Every factual claim checked: `buildScratchStoreWithInFlightDispatch` exists (`real-board-server.js:59`); `at: '2020-01-01T00:00:00Z'` (`:72`); only `dispatched-1.json` is written to that subject dir, so "no returned/presumed-lost successor" is true; "should always resolve stale under #29's rules" was proven empirically in r1 when my CSS fault injection reached the cascade assertion. |
| **M3** | **PRESENT — closed, and the strongest of the seven** | Both offending phrases are **gone tree-wide** (`grep -rn "fresh, precise elapsed time\|per-second wire precision" board/ docs/ schema/` → empty; removed, not relocated). The replacement at `poll.go:43-56` matches my r1 measurements point for point: the recency/value split, "observed: actual 50s, served 10s" (exactly my figure), the nothing-derives-from-it trace naming `dom-writer.js:200-202` and `render.js:188` (both verified — the print block and the type-guarded pass-through), and the alarm-bearing `dispatched`→`overdue` exactness that my PROBE A proved (budget 20s, elapsed 10→25, both bucket 0, `changed=true`). **No over-claim survives.** |
| **m1** | **PRESENT — closed, accurate** | New §12b paragraph (design doc `:605-616`). Citations checked: `board/server/config.go:42` = `StalenessMs: 15000,` ✓; `config/harness-defaults.json` = `dispatch_budget_seconds: 1800` ✓. The "15 seconds into every healthy 30-minute dispatch" arithmetic is mine from r1. It states "identical to base behaviour, NOT a regression this fix introduced" — correct and appropriately un-inflated. **No contradiction with #63 or #64**: it defers the retune to "its own ticket" and makes no claim about poller liveness at all. |
| **m2** | **PRESENT — closed, exact** | `poll.go:528` now cites `output.go:9-35`. Verified: `:9` = `func (d DispatchEntry) MarshalJSON(...)`, `:34` = `return json.Marshal(m)`, `:35` = `}`. Exactly the function. |
| **m3** | **PRESENT — closed, accurate** | Gating-matrix Idle row "Resets on" now carries `[CORRECTED, 2026-07-26]` and the reachable path `idle → fresh → (stalenessMs elapses again while something is still in flight) → stale`. This is my r1 analysis, correct in substance. |

**Zero DRIFTED.** Every fold is substantive; none is words-in-place-with-the-meaning-moved.

*Premise I tested and disproved rather than raising:* the corrected gating-matrix cell introduces a non-ASCII `≈`. I checked the repo's posture before calling it — `gating-matrix.md` already carries 4 non-ASCII lines and the design doc 111. Consistent with house style. **Not a finding.**

---

## NEW FINDING

### **R2-M1 (MAJOR) — this fix commit minted a fresh dead citation, of the exact class it was fixing, into the file it was fixing**

`board/server/poll.go:43` — the new M3 paragraph:

&gt; `// WHAT THIS DOES NOT MEAN (measured, elapsedbucket_test.go:99-101): …`

At HEAD `9080a5f`, `elapsedbucket_test.go:99-101` is:

```
 99:		t.Fatalf("second poll: %v", err)
100:	}
101:	if changed2 {
```

— an error-propagation guard and a loop into the *seq* assertion. The measurement it promises the reader lands at **`elapsedbucket_test.go:107-109`**:

```
107:	if got := dispatchElapsed(snap2); got != 10 {
108:		t.Fatalf("an undetected-change poll must serve the PRIOR snapshot untouched (elapsed_seconds=10, snap1's value) - got %v", got)
109:	}
```

**Cause, proven both ways.** At `4f06a4c` those exact three lines *were* at 99-101 (`git show 4f06a4c:board/server/elapsedbucket_test.go` confirms). This same commit added +6 net comment lines to that file — the header rewrite and the `now2` block — shifting the target down by 8. The coordinate was lifted verbatim from my round-1 verdict, where it was correct, and not re-derived after the commit's own edit to that very file.

**Why Major, tested against the charitable readings:**
- *"It's only off by eight; the reader will find it."* The reader is being sent to see a **measurement** and lands on `t.Fatalf("second poll: %v", err)` — plumbing that is deceptively test-shaped. That is the same "deceptively field-shaped, unrelated content" the C2R-1 verdict named at `artifacts/reviews/2026-07-23-board-car2-review-round1.md:101`.
- *"It's a comment in a Go file, low blast radius."* Round-1 M1 was citations in a test file and I ruled it Major; C2R-1 was a `$comment` and a Pester header and was ruled Major.
- *"The car disclosed a ripple, so it was diligent."* It disclosed the ripple it caused in `poll.go` and missed the identical ripple it caused in `elapsedbucket_test.go` in the same commit. Disclosed-but-wrong does not clear review, and this one is not disclosed at all.

**Fix — one line, and use your own remedy.** The durable form is the symbol/description one the car already invented and which I verified survives shifts: cite it as *this file's `snap2` assertion (`dispatchElapsed(snap2)` must read 10, not the raw 50)* with no coordinate. Repointing to `107-109` also closes it but re-arms the same trap. **The general rule worth writing into the comment convention: a citation into a file the same commit edits must be re-derived after the edit, or expressed as a symbol.**

### Full citation re-resolution (all 8 added by the delta)

| Citation | Site | Resolves? |
|---|---|---|
| `poll.go:399-412` **scoped to base `8b9df53` via `git show`** | `elapsedbucket_test.go:17-20` | ✓ exact at that revision; immutable |
| `board/web/js/dom-writer.js:201` | `poll.go:37`, test header | ✓ the elapsed span |
| `dom-writer.js:200-202` | `poll.go:49` | ✓ the print block |
| `render.js:188` | `poll.go:49` | ✓ the type-guarded pass-through |
| `algorithm.go:240` | `poll.go:53` | ✓ `entry.State = "overdue"` |
| `output.go:9-35` | `poll.go:528` | ✓ exactly `MarshalJSON` |
| `board/server/config.go:42` | design §12b | ✓ `StalenessMs: 15000,` |
| **`elapsedbucket_test.go:99-101`** | `poll.go:43` | ✗ **DEAD** → R2-M1 |

Plus 4 symbol references (`PollOnce`, `computeLiveFreshness`, `ageBucketMsGranularity`, `elapsedSecondsBucketGranularity`) — all four resolve.

---

## PROSE-ONLY AUDIT — re-derived mechanically, **PASS**

I did not eyeball the diff. I stripped every whole-line `//` comment and every blank line from both revisions of all five code/test files and compared the remaining lines:

```
IDENTICAL after stripping whole-line comments: board/server/poll.go               (321 code lines)
IDENTICAL after stripping whole-line comments: board/server/elapsedbucket_test.go  (69 code lines)
IDENTICAL after stripping whole-line comments: board/web/js/compose.js             (87 code lines)
IDENTICAL after stripping whole-line comments: board/web/test/ingest.test.js       (67 code lines)
*** DIFFERS: board/web/test/browser-register-cascade.test.js   (1 hunk)
```

The check is sound in both directions: a line carrying a *trailing* comment is retained whole, so a code change on such a line would surface. Four files are **byte-identical in code**.

The fifth differs by exactly one hunk, and I confirmed structurally that it cannot alter behaviour — it is the **third argument** to `assert.equal(actual, expected, message)`:

```js
111:  assert.equal(
112:    observed.laneIsNeedsAttention,
113:    true,
114:    `test precondition not met: … `  ←  the only changed lines, 114-117
118:  );
```

A message string is evaluated only to be *reported*; it participates in no comparison. **Zero behaviour changed. The car's claim is TRUE.** `go vet ./...` clean corroborates on the Go side.

---

## Suites — all six re-run, all my own counts at `9080a5f`

| Suite | Observed | vs round 1 |
|---|---|---|
| Pester `scripts/tests` | **Total 195, Passed 194, Failed 0, Skipped 1** | identical |
| Pester `scripts/store-checks` | **194 / 194 / 0** | identical |
| Pester `scripts/probes` | **24 / 24 / 0** | identical |
| Go `board/` (5 pkgs) | **73 `--- PASS`, 0 `--- FAIL`**; `go vet ./...` clean | identical |
| `node --test` `board/web` (CI's whole-dir form) | **`# tests 71 / # pass 71 / # fail 0`** | identical |
| Playwright guard alone | **2 / 2 pass** | identical |

I ran the full Playwright guard rather than skipping it — the diff edits a string *inside* that file, and a broken template literal would be a syntax error rather than a test failure, so only executing it proves the edit is inert. It is. **The car's "suites unchanged" claim is TRUE.**

---

## CONVERGENCE RULING and CAP

I hold the series, so this is mine to call and I am stating both halves.

**The swirl-and-churn trigger fires by the letter, and I am declining to invoke it — deliberately, with reasons.** Two of the three conditions are met: (b) findings cluster in the same section across rounds (citation truth, same two files), and (c) — the sharpest — this round's finding is a defect the previous round's fix created. Condition (a) is **not** met: Majors went **3 → 1** and total findings **7 → 1**.

Substance over letter, and the rule's purpose is to catch defects being *relocated* rather than *resolved*:

- The class was **structurally** addressed, not patched. The car replaced coordinates with symbol references and I verified that remedy holds under exactly the stress that broke the originals — an 11-line shift inside the same commit.
- The instrument is not failing. Line-number citations are checkable, and the check caught this both rounds, cheaply, at the rung it belongs to. Nothing here needs an owner ruling or a different rung.
- Six of seven findings closed with substance and zero drift. That is a converging series with one application miss, not a swirl.

**Cap set, and the conductor is bound by it: round 3 is the last round on this defect class.** If round 3 leaves, or introduces, any further citation-truth defect, that is the instrument failing at this scale and it escalates to the owner instead of a round 4.

**Whole-train mergeability from `9080a5f`: NO.** One Major stands, and any Major is a REJECT regardless of how small the fix is — severity tracks consequence to the doc-equal-to-code standard, not fix cost.

**Mergeable after a one-line round-3 fix.** Round 3 needs only a targeted delta: I would re-resolve that single citation and re-run nothing else, because prose-only is now mechanically established and all six suites are pinned at this commit. Send it to the same car.

---

## Constitution check (delta only)

| Law | Verdict |
|---|---|
| **1. Truth** | Three round-1 falsehoods removed and verified gone tree-wide; the M3 rewrite is now the most precise statement of the trade in the repo. **Violated once**, by R2-M1 — a citation that promises a measurement and delivers plumbing. |
| **4. Nothing Silently Lost** | HONORED, and notably: the car did not quietly drop the inconvenient half of #29 — §12b now records the untouched `stalenessMs` ask *and* its measured consequence, explicitly labelled not-a-regression. That is the honest-disclosure branch taken without being forced onto it. |
| **6. One Truth** | HONORED. Zero code, schema, or test behaviour changed — mechanically proven — so no derivation moved and no second copy was created. The symbol-reference convention *reduces* duplication of positional knowledge. |
| **7. The Stranger** | HONORED. Symbol references and a `git show` base pin are what a stranger can actually follow; a line number in a moving file is not. This fix makes the comments more portable, not less. |
| **Guide star (blameless, not vague)** | HONORED by the car. It named its own ripple, in its own commit message, with the exact coordinate it broke — the behaviour this shop codes as a success outcome. R2-M1 is the one it did not catch, and it is named here with the same precision, aimed at the artifact and not at anyone. |

**Worktree state on exit:** clean, `git status --porcelain` empty, HEAD `9080a5f0da14d35cb6a12ee4a9903cb072b8146d`. This round required no fault injection; nothing was edited, committed, or pushed.

**File needing the round-3 fix (absolute):**
`<repo>-wt\review-server-27-29\board\server\poll.go` — line 43, `elapsedbucket_test.go:99-101` → cite by symbol, or `107-109`.

```starcar-artifact
outcome: REJECT
task-id: server-27-29-review-r2
findings: 1 Major, 0 Minor. All seven round-1 findings (M1 three sites, M2a, M2b, the advisory, M3, m1, m2, m3) verified PRESENT and genuinely closed at 9080a5f with ZERO drifted - every fold substantive, none words-in-place-with-meaning-moved. The M1 remedy exceeded what I asked for: the car converted line citations to SYMBOL references rather than repointing numbers, and I verified that remedy works under the exact stress that broke the originals (PollOnce moved from poll.go:226 to :237 inside this same commit, an 11-line shift that would have killed a hardcoded range, and the symbol citations survived it); the car also self-caught and disclosed a ripple its own M3 expansion caused to a citation I had marked accurate in round 1 (poll.go:373-376 now 384-387, confirmed at HEAD) and fixed that by symbol too. R2-M1 (MAJOR, NEW): board/server/poll.go:43 cites elapsedbucket_test.go:99-101 as the measured evidence for the recency claim, but at HEAD those three lines are t.Fatalf("second poll: %v", err), a closing brace, and if changed2 - an error-propagation guard, deceptively test-shaped. The measurement it promises (dispatchElapsed(snap2) must read 10, with the "actual 50, served 10" Fatalf) is at elapsedbucket_test.go:107-109. Cause proven both directions: those exact lines WERE at 99-101 at 4f06a4c (git show confirms), and this same commit added +6 net comment lines to that file's header and now2 block, shifting the target by 8; the coordinate was lifted from my round-1 verdict where it was correct and not re-derived after the commit's own edit to that very file. Same class as M1 and as the binding precedent artifacts/reviews/2026-07-23-board-car2-review-round1.md:97,101,109, and the car's own symbol-reference remedy was simply not applied at this one site. Fix is one line; recommend the symbol form (cite this file's snap2 assertion by description, no coordinate) plus the general rule that a citation into a file the same commit edits must be re-derived after the edit or expressed as a symbol. PROSE-ONLY AUDIT RE-DERIVED MECHANICALLY, PASS: stripping every whole-line comment and blank line from both revisions leaves board/server/poll.go (321 code lines), elapsedbucket_test.go (69), compose.js (87) and ingest.test.js (67) BYTE-IDENTICAL; the only non-comment change is one hunk in browser-register-cascade.test.js lines 114-117, structurally confirmed as the THIRD argument to assert.equal(actual, expected, message), a message string that participates in no comparison. The check is sound both directions because a line carrying a trailing comment is retained whole. go vet clean corroborates. Zero behavior changed; the car's claim is TRUE. ALL EIGHT file:line citations added by the delta re-resolved individually: poll.go:399-412 correctly scoped to base commit 8b9df53 via git show and verified exact at that revision (immutable, immune to HEAD drift), dom-writer.js:201, dom-writer.js:200-202, render.js:188, algorithm.go:240, output.go:9-35 (exactly MarshalJSON, func at 9 and closing brace at 35 - m2 closed precisely), config.go:42 (StalenessMs 15000 - m1's citation exact), and the one dead one above; plus four symbol references (PollOnce, computeLiveFreshness, ageBucketMsGranularity, elapsedSecondsBucketGranularity) all resolving. M2a verified EXHAUSTIVELY not just plausibly: grep of the schema shows exactly two required arrays containing ageBucketMs, at :43 (stale) and :51 (idle), so the corrected "two kinds" claim is true AND complete. M3's two offending phrases confirmed removed tree-wide by grep, not relocated, and the replacement matches my round-1 measurements point for point including the observed 50s-actual/10s-served figure. m1's new section-12b paragraph is accurate, appropriately labelled not-a-regression, and contradicts neither #63 nor #64. m3's corrected gating-matrix reachable path matches my round-1 analysis. Tested and DISPROVED one of my own hunches rather than raising it: the corrected gating-matrix cell adds a non-ASCII character, but that file already carries 4 non-ASCII lines and the design doc 111, so it is house-consistent and not a finding. SUITES, all six re-run, all counts my own at 9080a5f and all identical to round 1: Pester scripts/tests 195 total 194 passed 0 failed 1 skipped; store-checks 194/194/0; probes 24/24/0; Go 73 PASS 0 FAIL across 5 packages with go vet clean; node --test board/web whole-directory CI form 71 tests 71 pass 0 fail; Playwright guard alone 2/2, run in full deliberately rather than skipped because a broken template literal in the edited string would surface as a syntax error rather than a test failure. CONVERGENCE: I hold the series, r1 3 Major 3 Minor plus 1 advisory, r2 1 Major. The swirl-and-churn trigger fires BY THE LETTER (condition b, findings clustering in the same section; condition c, a defect the previous round's fix created) but condition a is NOT met - Majors declined 3 to 1 and total findings 7 to 1 - and I am DECLINING to invoke it with reasons stated rather than skipping it silently: the class was addressed structurally via symbol references whose durability I verified under real shift stress, the instrument is not failing (the check caught this cheaply at its own rung both rounds), and six of seven findings closed with substance and zero drift, which is convergence with one application miss rather than defect relocation. CAP SET and binding on the conductor: round 3 is the last round on this defect class; any further citation-truth defect at round 3 escalates to the owner instead of a round 4. MERGEABILITY from 9080a5f: NO, one Major stands and any Major is a REJECT regardless of fix cost. Mergeable after a one-line round-3 fix to the same car, needing only a targeted delta re-review of that single citation since prose-only is now mechanically established and all six suites are pinned at this commit. Constitution: Law 1 honored by three falsehoods removed and violated once by R2-M1; Law 4 honored notably, the car disclosed the undone half of #29 rather than quietly dropping it; Law 6 honored, zero behavior changed so no derivation moved; Law 7 honored, symbol references and a git-show base pin are what a stranger can actually follow; guide star honored by the car, which named its own ripple with the exact coordinate it broke. Worktree clean, nothing edited, committed or pushed this round.
abstract: Delta re-review, round 2, of the prose-only fix commit 9080a5f on round-1 HEAD 4f06a4c, same reviewer with context intact. All seven round-1 findings walked as Present/Absent/Drifted and all seven are PRESENT and closed with zero drift, several better than asked - the car answered the dead-citation Major by converting to symbol references rather than repointing numbers, and I proved that remedy durable by observing the symbol targets survive an 11-line shift inside this very commit that would have killed a line range, the same commit in which the car self-caught and disclosed a ripple it had caused to a citation I had previously marked accurate. REJECT nonetheless on one new Major: the fix commit minted a fresh dead line citation of exactly the class it was fixing, into the very file it was editing, by pasting a coordinate from my own round-1 verdict without re-deriving it after its own six-line insertion shifted the target by eight lines; a reader following it lands on an error-propagation guard instead of the measurement it promises. One line to fix, and the car's own symbol-reference convention is the durable remedy. The prose-only claim was re-derived mechanically rather than eyeballed - four of five files are byte-identical in code once whole-line comments are stripped, and the fifth differs only inside the third argument to assert.equal, a message string that participates in no comparison - and all eight added file:line citations were re-resolved individually, seven correct including an elegantly immutable git-show pin to the base commit. All six suites re-run and identical to round 1. As holder of the series I ruled explicitly on convergence: the swirl trigger fires by the letter on two of three conditions, and I declined to invoke it with reasons on the record because findings fell 7 to 1 and the class was addressed structurally rather than relocated, while setting a binding cap that round 3 is the last round on this defect class before escalation to the owner. Not mergeable from 9080a5f; mergeable after a one-line round-3 fix needing only a targeted delta.
```