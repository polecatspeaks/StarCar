<!-- starcar-integrity: sha256=fbd52ae690b98699d21cd6005b7222a39d4ae7b60202ae9be61c5ccf72f9a403 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car server-27-29 review - round 1 (REJECT, prose-only Majors)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial sentence-check review with computed-style gate
Round: 1
Target: `commits 3fd4fa6, 4f06a4c on car/server-27-29 (#27, #29)`
Base reviewed: `4f06a4c6a09d504d0a2fe61e56120ef20bd98cbd`
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
| Base commit the reviewer read (**the lookup key**) | `4f06a4c6a09d504d0a2fe61e56120ef20bd98cbd` |

| Dispatch, the locator within the session | `a13a5df25c7c6bf77` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 4f06a4c6a09d504d0a2fe61e56120ef20bd98cbd
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All work complete. Probes and injections reverted byte-identical; worktree clean at `4f06a4c`.

---

# VERDICT: **REJECT** — 3 Major, 3 Minor

Car `server-27-29-car-r1` | Review `server-27-29-review-r1` | Round 1
Worktree `<repo>-wt\review-server-27-29`, HEAD `4f06a4c6a09d504d0a2fe61e56120ef20bd98cbd` (verified before any action; detached, clean).

**The mechanism is sound and every empirical claim the car made verified TRUE.** Both fixes do what they say, the wire sentence traces end-to-end to a real pixel, the #31 guard survives its rewire with its non-vacuity re-proven, and the retro's design-rung concern is CLEARED (ruling in §6). The REJECT is entirely about documents the diff falsified and left standing — the exact class this repo already ruled MAJOR at `artifacts/reviews/2026-07-23-board-car2-review-round1.md:97` ("severity tracks consequence to the doc-equal-to-code standard, not fix cost"). All three fixes are prose-only; no code and no test needs to change.

---

## BASE-DELTA (#13)

Round 1. **Base reviewed: `8b9df53`** ("harness: land process-docs r3 verdict + index"), the stated base, confirmed as `4f06a4c~2` and as the parent of `3fd4fa6`. No prior review rounds exist for this car; no delta, full review. Diff under review: `8b9df53..4f06a4c`, 2 commits, 14 files, +577/−81.

## UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

1. **The car's authoring-time reds.** I cannot re-derive the car observing red on its own worktree mid-authoring. I re-derived the *equivalent* at HEAD by fault injection (§2, §3) and both failed verbatim as the car stated.
2. **Car 33's original non-vacuity proof** for the pre-#29 `browser-register-cascade.test.js`. Historical. Superseded in relevance — I re-proved non-vacuity of the *post-rewire* test myself (§5), which is what this diff is accountable for.
3. **`ageBucketMs: 3040000`** in my browser observation is wall-clock dependent (age of this repo's newest record at `2026-07-26T18:29:49Z`) and will differ on re-run. The `idle` KIND and the nominal rgb are not wall-clock dependent while the store stays returned-only.
4. **`node --test` count semantics** — see the observation at the end of §1; the car's "69 + 2" and my 71 reconcile exactly, but the split is a description choice I could not source to a command.

---

## 1. Suites — all counts my own, at `4f06a4c`

| Suite | Command | Observed |
|---|---|---|
| Pester `scripts/tests` | `Invoke-Pester -Path scripts/tests` | **Total 195, Passed 194, Failed 0, Skipped 1** |
| Pester `scripts/store-checks` | `Invoke-Pester -Path scripts/store-checks` | **Total 194, Passed 194, Failed 0, Skipped 0** |
| Pester `scripts/probes` | `Invoke-Pester -Path scripts/probes` | **Total 24, Passed 24, Failed 0, Skipped 0** |
| Go, `board/` 5 packages | `go test ./... -v` | **73 `--- PASS`, 0 `--- FAIL`**; `go vet ./...` clean |
| `node --test`, `board/web` | `node --test` (CI's own form, `.github/workflows/ci.yml:374`) | **`# tests 71 / # pass 71 / # fail 0`** |
| Playwright guard alone | `node --test test/browser-register-cascade.test.js` | **2/2 pass** |

Expectations **derived independently, not taken from the brief**:

- **store-checks = 194.** `find artifacts -name '*.json'` → **189** records; `StoreIntegrity.Tests.ps1` has one `-ForEach` `It` per record plus 5 fixed `It`s (fault injection `:87`, manifest layer `:121/:139/:154`, offset-form `:175`). 189 + 5 = **194**. ✓
- **Go 70 → 73.** Counted `func Test` across every `board/**/*_test.go` at base via `git ls-tree 8b9df53` + `git show` → **70**. Three added: `TestPollOnceElapsedSecondsBucketedForChangeDetection`, `TestPollOnceIdleWhenNothingInFlight`, `TestPollOnceStaleWhenInFlightAndDataStopsMoving`. 70 + 3 = **73**. ✓

**Observation (non-blocking).** The car reports "node --test 69/69" and "Playwright 2/2" as separate suites. TAP shows they are **one** run: `ok 1` and `ok 2` are the browser tests, inside the same `node --test`. My 71 = 67 unit + 2 browser + 2 files node counts as tests but which contain none (`test\minidom.js`, `test\support\real-board-server.js`). Nothing is missing or double-counted; the description just splits a run that CI does not split.

---

## 2. #27 semantics — mechanism re-derived, four transitions observed

**Mechanism, read at HEAD.** `elapsedSecondsBucketGranularity = int64(60)` (`board/server/poll.go:54`); `mustMarshalStripped` swaps the dispatches payload for a bucketed **deep copy** (`poll.go:483-485`) via `bucketDispatchesForComparison` (`poll.go:506+`), which allocates a fresh map per entry so the served value is never mutated. `PollOnce` computes `candidateCompare` at `poll.go:230` and returns `s.lastSnapshot, false, nil` at `:237` when bytes match.

I wrote a throwaway probe suite (`board/server/zzreviewerprobe_test.go`, deleted; tree clean) covering what the car's own tests do **not** pin. Observed output verbatim:

```
PROBE A poll1: seq=1 state="dispatched" elapsed=10 freshness="fresh"
PROBE A poll2: seq=2 state="overdue"    elapsed=25 changed=true
PROBE A poll3: seq=2 changed=false (want no bump)
PROBE B poll1: seq=1 changed=true
PROBE B poll2: seq=2 changed=true
```

| Transition the brief asked me to prove | Observed |
|---|---|
| Two polls, in-flight dispatch, inside one bucket → NO seq bump | ✓ car's `elapsedbucket_test.go:89-98` (10s→50s, `changed=false`); my PROBE A poll3 (25s→40s, overdue, `changed=false`) |
| Bucket crossing → bump | ✓ `elapsedbucket_test.go:106-118` (50→65, seq+1) |
| A record landing mid-bucket → bump | ✓ **PROBE B** (new subject at elapsed 30, same bucket 0, `changed=true`) |
| `dispatched`→`overdue` → bump **regardless of bucket** | ✓ **PROBE A poll2**: budget 20s, elapsed 10→25, both bucket 0, `changed=true`, `seq 1→2` |

The car's claim that the state string carries the overdue transition is **true and now proven, not asserted**. The path: `board/fold/algorithm.go:240` sets `entry.State = "overdue"` while `winnerKind` stays `"dispatched"` (`algorithm.go:204-208`), so `MarshalJSON` (`board/fold/output.go:24-26`) still emits `elapsed_seconds` for an overdue entry — bucketing keeps applying past the budget (PROBE A poll3 confirms), and `"state"` is untouched by `bucketDispatchesForComparison`.

**Red-first re-derived by fault injection.** Removed `poll.go:483-485`, ran the car's pin:

```
elapsedbucket_test.go:94: elapsed_seconds moving 10-&gt;50 (same 60s bucket) must NOT bump seq;
                          seq stayed 1 then moved to 2
--- FAIL: TestPollOnceElapsedSecondsBucketedForChangeDetection
```

Reverted; `sha256(board/server/poll.go) = 87d2f0b3d43dea4c566a2363f1d58ea66e7f86b70eb668d1be3dc696dd292cc8`, byte-identical to pre-injection.

### The mid-bucket wire corner — ruling: the trade is SOUND, the comment describing it is NOT

The brief asked me to rule on the displayed number lagging. **The lag is real and the car's own test pins it**: `elapsedbucket_test.go:99-101` asserts that at a poll where actual elapsed is **50s**, the served snapshot carries **10** — 40 seconds stale, because `PollOnce` returns the prior snapshot unchanged.

*Is the trade sound?* **Yes.** Nothing downstream computes on `elapsedSeconds`. The only consumer is `board/web/js/dom-writer.js:200-202`, which prints `` `${d.elapsedSeconds}s` ``; `render.js:188` passes it through with a type guard. There is no client countdown and no client-side overdue derivation — `overdue` is a server-side promotion at `algorithm.go:238-240`, and that transition bumps seq immediately (PROBE A). So the loss is confined to a display number refreshing in ~60s steps on a glance surface whose alarm-bearing field (`state`) is exact. For a Solari board that is the right call.

*Is the comment describing it sound?* **No — see M3.**

---

## 3. #29 semantics — taxonomy attacked, ticket fidelity checked

**Mechanism.** `computeLiveFreshness` (`poll.go:399`) gained the fold's dispatch entries, threaded from `buildSnapshot` at `poll.go:308`; `hasInFlightDispatch` (`poll.go:428-436`) returns true for `State == "dispatched" || State == "overdue"`. `poll.go:424-427`: in flight → `stale`; otherwise → `idle`, both carrying the same `ageBucketMs`.

**Red-first re-derived.** Collapsed `poll.go:424-427` to always return `stale`:

```
freshnessidle_test.go:50: freshness.kind = "stale", want idle - nothing is in flight
                          (the sole record already returned), so an old, quiet yard
                          must render calm, never stale-hot
--- FAIL: TestPollOnceIdleWhenNothingInFlight
```

Under the same injection `TestPollOnceStaleWhenInFlightAndDataStopsMoving` stays **PASS** — correctly a discriminator, not a red-first pin, which is exactly how the car describes it (`freshnessidle_test.go:53-59`). Reverted byte-identical (hash above).

### Attack 1: is overdue-in-flight rendering the lane merely "stale" the right call?

Probed it (PROBE C: `dispatched` with budget 20s, polled at elapsed 600s, default `stalenessMs`):

```
PROBE C: lane freshness kind="stale", entry state="overdue"
```

**Right call.** Both halves are hot: the lane's freshness resolves `stale` → `needs-attention` via `compose.js:39`, and the ROW resolves `overdue` → `needs-attention` from `schema/vocab/board-defs.json`'s `liveness` array. No severity is lost anywhere. There is no state in which an overdue dispatch makes any surface calmer than it was at base.

### Attack 2: does `idle` conflate OBSERVATION freshness with ACTIVITY recency?

Probed the two edges the brief named:

```
PROBE D: presumed-lost yard    -&gt; lane freshness kind="idle", entry state="presumed-lost"
PROBE E: ruling-only store (no dispatch subjects), 60min old -&gt; kind="idle", dispatch entries=0
```

- **Presumed-lost → idle lane.** Defensible, and the truth is not lost: `board-defs.json` maps `presumed-lost` → `needs-attention`, so the ROW renders hot inside a calm lane. That is Rule 1 operating as designed (lane register = most-severe of position × freshness × capability; row registers are their own axis — the same separation `#31`'s guard exists to protect). Not a finding.
- **No dispatch subjects at all → idle.** Matches the car's documented rule and the gating-matrix Idle row.

**The poller-dead question — ruling: the gap is REAL, PRE-EXISTING, and OUT OF SCOPE for this diff.** I traced it: `lastPollAt` exists (`poll.go:70`, set at `:235`, read at `:178`) but reaches **no** wire field — I grepped every non-test use. The SSE heartbeat is a **per-connection** ticker (`handlers.go:76`, fired at `:92`), independent of `RunPollLoop` (`poll.go:197-217`). So a wedged poll loop leaves a client "connected" and showing a frozen snapshot forever.

But that is not a loss #29 caused, and here is the disproof of the framing: **pre-#29 `stale` never carried poller-health information either.** Spec YB-15 exists precisely to prove staleness fires while the scan keeps succeeding on schedule (`TestDemoModeIsWireDisclosureOnlyAndStalenessStillFires`), and a wedged poller freezes whatever kind was last computed — `fresh` just as easily as `stale`. Zero information was removed. The ticket's third axis, scan-health, **is** implemented and predates this diff: `Scan` error → `failed` (`poll.go:275-281`, gating-matrix Failed-panel row). Recommend a ticket for a poll-loop-liveness surface; it is not this car's debt.

### Ticket fidelity to #29's own text

&gt; "distinguish scan-health (did the poll succeed), data-age, and YARD ACTIVITY (is anything in flight) — an idle yard should render calm/nominal with its age honestly shown, going stale-hot only when something IS in flight and the data stops moving, or the scan fails."

All three axes present and correctly wired; the calm-with-age-shown requirement is met literally (`idle, quiet 3040s`, observed in a browser). **High fidelity.** The ticket's second sentence — *"Also retune stalenessMs against measured reality"* — is untouched and undisclosed. See **m1**.

---

## 4. THE WIRE SENTENCE — every hop, file:line, ending in a computed pixel

Run: this worktree's own Go binary, built on the fly, port 4931, **real `artifacts/` store, no `STARCAR_STORE_PATH` override**, real Chromium via the Playwright library.

**Hop 0 — the real-store premise, re-derived independently.** I did not take the car's scan on trust. A PowerShell pass over all 189 records: `dispatched=61, returned=122, intent=6`; **87 dispatch-kind subjects; 0 whose latest-`at` winner is `dispatched`.** The live server agreed exactly: `dispatch entry states: {"returned":87}, total 87`. The car's claim is **TRUE**.

| # | Hop | Evidence |
|---|---|---|
| 1 | Schema owns the shape | `schema/yard-snapshot.schema.json:45-53` — `idle` oneOf branch, `required: [kind, asOf, ageBucketMs]`, mirroring `stale`'s branch at `:37-44`. `$defs.register:11-14` **byte-unchanged** (diff grep for `register|enum` in the schema diff returns nothing). |
| 2 | Go derives the kind | `poll.go:424-427` returns `Freshness{Kind:"idle", AsOf, AgeBucketMs}`; the `Freshness` struct is unchanged — `idle` reuses `stale`'s fields, as the design amendment claims. |
| 3 | Marshal → HTTP | `handlers.go:17` `/api/snapshot`; single marshal path shared with SSE. |
| 4 | **Observed on the wire** | `{"kind":"idle","asOf":"2026-07-26T18:29:49Z","ageBucketMs":3040000}` on `dispatches`, `gates`, `trains`. |
| 5 | Browser validator accepts it | `board/web/js/validate.js:7,18-20` — the vendored `@cfworker/json-schema` `Validator` compiled against **THE schema file**, no hand-rolled mirror (Law 6). Proof it accepted: the snapshot was applied and rendered; `pageerror`/`console.error` listeners captured `[]`. Had `idle` failed `oneOf`, `ingest.js:63-70` would have discarded the payload and raised a client board condition. |
| 6 | Register mapping | `board/web/js/compose.js:47` `idle: 'nominal'` inside `FRESHNESS_REGISTER`. |
| 7 | Freshness line | `compose.js:102-108` → `` `idle, quiet ${bucketSeconds}s` ``. |
| 8 | DOM writer | `dom-writer.js:115-117` writes `.lane-secondary`; register class on the lane element. |
| 9 | **COMPUTED PIXEL (real Chromium)** | see below |

```json
"laneClasses":            "lane lane-dispatches register-nominal",
"secondaryText":          "idle, quiet 3040s",
"laneComputedColor":      "rgb(217, 213, 201)",
"laneBorderLeftColor":    "rgb(217, 213, 201)",
"probeNominal":           "rgb(217, 213, 201)",
"probeInProgress":        "rgb(255, 180, 84)",
"probeNeedsAttention":    "rgb(255, 74, 58)"
```

**The dispatches lane says `idle, quiet 3040s` and renders `rgb(217, 213, 201)` — byte-equal to the free-floating `.register-nominal` probe, and distinct from `.register-needs-attention` `rgb(255, 74, 58)` and `.register-in-progress` `rgb(255, 180, 84)`.** Ground truth for "nominal" is read from the live stylesheet by an appended probe element, never a hardcoded hex (Law 6). All three live lanes identical. **The sentence closes.**

I also opened `docs/screenshots/2026-07-23-first-light.png`, cited as the finding's provenance by `poll.go:397-398` and `freshnessidle_test.go:16`. It shows every lane red, `stale, 265s`, and every dispatch row reading `returned` — **the citation is true**, and the image is referenced only as first-light provenance, never as the board's current look (no screenshot-drift finding).

---

## 5. THE #31 GUARD REWIRE — still guards, at the same strength, PROVEN

**Adjudication: the rewire is honest and the guard is undiminished.**

- **Same strength.** Still the real Go binary (`real-board-server.js:97` `go build ./server`), real static files, real Chromium, `getComputedStyle` — every one of the #33 amendment's constraints intact. What changed is only *which store path* the real binary reads, via the server's own `STARCAR_STORE_PATH` env var (`real-board-server.js:169`, consumed by `config.go`'s `applyEnvOverrides`) — **not a second store-selection mechanism**.
- **Honest fixture.** `real-board-server.js:64-80` writes a record carrying all seven schema-required fields (`schema`, `kind`, `subject`, `session_id`, `at`, `normalisation`, `integrity`). It is a real `dispatched` record shape, not a synthetic freshness stub, and it is one *addition* to a byte-identical copy of every committed record.
- **No risk to the real store.** `cpSync(join(REPO_ROOT,'artifacts'), storeDir, {recursive:true})` — source is `artifacts/`, destination is `mkdtempSync(join(tmpdir(), 'starcar-board-scratch-store-'))`. Direction correct; every write (`mkdirSync`, `writeFileSync`) targets `storeDir`. Verified after all my runs: `git status --porcelain` shows nothing under `artifacts/`.
- **NON-VACUITY RE-PROVEN BY ME, through a real browser (#40).** Deleted `color: var(--nominal);` from `.register-nominal` (`board/web/css/board.css:168`) and ran the guard:

```
✖ issue #31: a nominal-register dispatch row inside a needs-attention-registered lane ...
  AssertionError: ... computed color rgb(255, 74, 58), but board.css's own .register-nominal
  rule renders as rgb(217, 213, 201) when nothing overrides it.
  actual:   'rgb(255, 74, 58)'
  expected: 'rgb(217, 213, 201)'
```

This is computed-style evidence, not a DOM-class assertion. It also proves the **precondition** survived the rewire: execution reached line 125, so the assertion at `:111-117` (`laneIsNeedsAttention === true`) passed — the scratch store's seeded in-flight dispatch really does drive the lane to `register-needs-attention` under the #29 rules, and the `solari-row register-nominal unassigned` row really exists. Restored: `sha256(board/web/css/board.css) = 07c916278138370bdcef782c5ec0316b9972dfe6398ddd03611428aa1091a63d`, byte-identical; guard back to **2/2 pass**.

One stale sentence rides along: `browser-register-cascade.test.js:115` still says *"the real store's records should always read stale relative to 'now'"* inside the precondition message — the premise the rewire exists to remove. It is a failure-message string, factually superseded by the file's own header at `:28-42`. Folding it into **M2** as a third site is defensible; I have left it as an advisory line under M2 rather than inflating the count, since the header immediately above it states the correct premise.

---

## 6. RETRO-CONCERN RULING — the amendment path **SATISFIES** it; no retroactive design round

The concern, verified verbatim at `docs/retros/2026-07-23-board-train-retro.md:120-121`:

&gt; "the staleness/idle semantics (#29) touch the freshness union, which is CLOSED by mechanism - growing it is a design-rung decision, not a patch."

**Ruling: CLEARED for this change.** Reasoning, against the two sections the brief names:

1. **Right-sizing (structural vs coverage).** It touches a cross-boundary contract, which argues structural. But measure the actual shape: one *additive* `oneOf` branch whose field set is byte-identical to the branch beside it; one entry in a map that already existed to be keyed by kind (`compose.js:42-49`); one `case` in a `switch` that already had a hot default for unknown kinds (`compose.js:120-124`); one Go conditional. **No new register, no new field, no new mechanism, no new consumer path.** The register enum — the thing the constitution actually reserves as constitution-level — is untouched. That is coverage-class in everything but the file it lands in.
2. **Match the instrument to the artifact.** This is decisive and it cuts *against* the retro's default. CLAUDE.md: a format or wire contract *"goes straight to an EXECUTABLE spec: a schema file, a conformance test vector, a red-first test that fails for the stated reason. The artifact IS the precision."* That is precisely what landed — and I verified all three tiers myself: the schema branch, a red I re-derived by fault injection with the failure quoted verbatim, and computed-style evidence from a real browser. A prose design round would have produced *a photograph of this machine*. Ordering one here would be the ceremony-porting failure the right-sizing rule names as itself a process failure.
3. **Precedent.** #30 made a comparable closed-taxonomy change through car + §12b amendment + adversarial review; it landed and is visible in the same table (`gating-matrix.md:47`). Re-litigating the rung for an identical shape is inconsistency, not rigour.
4. **The car did not self-adjudicate.** It reproduced the concern verbatim in the durable artifact (`design ...§12b`, "Disclosed process note") and routed it upward. That is the escalation reflex working as written: *report a contradiction, never resolve one you do not own.* The car earns credit here, not a finding.

**Stated against myself, because the honest ruling has a cost line:** the lighter rung *did* miss something a design moment would likely have caught — issue #29's second explicit ask (`retune stalenessMs`) and its interaction with the shipped 15s default. That is real evidence for the retro's instinct. It is recorded as **m1** at Minor. It is a reason to sharpen the amendment, not to re-run the rung.

---

## 7. FINDINGS

### **M1 (MAJOR) — three dead file:line citations in `board/server/elapsedbucket_test.go`, self-invalidated by the very commit that wrote them**

`3fd4fa6` inserted a 29-line comment block at `poll.go:27-55`, shifting everything below it, and in the same commit authored a new test file citing the *pre-shift* coordinates.

| Site | Cites | At base `8b9df53` | At HEAD `4f06a4c` — what a reader lands on |
|---|---|---|---|
| `elapsedbucket_test.go:17` | `poll.go:399-412` | the `DISCLOSED, OUT OF SCOPE` #27 comment (verified via `git show 8b9df53:board/server/poll.go`) | `func computeLiveFreshness(...)` and its loop body — unrelated |
| `elapsedbucket_test.go:27` | `poll.go:190-196` | `PollOnce`'s doc comment, containing the exact quoted phrase *"otherwise the prior snapshot stands unchanged"* | `func (s *Server) EndPoll()` + `RunPollLoop`'s header |
| `elapsedbucket_test.go:83` | `poll.go:190-196` | same | same |

The quoted contract now lives at `poll.go:219-225` (phrase on `:223`). Worse than the precedent: those citations were born stale *one commit after* their invalidation; these were born stale *in* it.

**Precedent binding this severity:** `artifacts/reviews/2026-07-23-board-car2-review-round1.md:97,109` — identical class, ruled **MAJOR**, gated the merge, with the note that "severity tracks consequence to the doc-equal-to-code standard, not fix cost."
**Fix:** `poll.go:399-412` → cite `git show 8b9df53:board/server/poll.go` or drop the coordinate; `poll.go:190-196` → `poll.go:219-225`, both sites.

### **M2 (MAJOR) — two sibling comments falsified by these commits and left standing, one of them six lines from the change that falsified it**

**(a) `board/web/js/compose.js:91-92`** — inside the file `4f06a4c` edited:

&gt; "the wire's `fresh` variant carries no `ageBucketMs` at all - **only `stale` does** (`schema/yard-snapshot.schema.json` `$defs.freshness`'s `oneOf`)."

At HEAD that `oneOf` has **two** branches requiring `ageBucketMs`: `stale` (`schema:37-44`) and `idle` (`schema:45-53`) — added by this commit, and `case 'idle'` sits at `compose.js:102`, six lines below the false sentence.

**(b) `board/web/test/ingest.test.js:66-69`** — falsified by `3fd4fa6`:

&gt; "Issue #27: while a dispatch is actively running, `elapsed_seconds` is unquantised and can bump `seq` on nearly every poll"

False at HEAD. Disproven by the car's own `elapsedbucket_test.go:89-98` and by my PROBE A poll3 (`changed=false`). This is a lying canary teaching a future reader exactly the belief #27 was filed to correct. The car **fixed the twin** of this comment in `board/web/js/ingest.js:51-60` in that same commit and said so in the commit message — so the class was known and one instance was missed. That is the "fixed the code, skipped the record" shape the PR-cycle scar names.

*Advisory, same class, not counted separately:* `browser-register-cascade.test.js:115` still asserts "the real store's records should always read stale relative to 'now'" in a failure message, contradicting its own header at `:28-42`.

**Fix:** three sentences.

### **M3 (MAJOR) — `board/server/poll.go:38-39` (and `:51-53`) states a consequence the fix does not deliver, contradicted by the car's own test**

&gt; `:38-39` "…and a connected client's current snapshot **must keep showing fresh, precise elapsed time**."
&gt; `:51-53` "…**per-second wire precision** (dom-writer.js) is worth preserving exactly…"

Measured reality, from the car's own pin `elapsedbucket_test.go:99-101`: at a poll where actual elapsed is **50s**, the served snapshot carries **10**. The rendered counter is refreshed at most once per bucket and can trail actual elapsed by up to ~60s. The *value* is exact; its *recency* is not, and the comment conflates the two — precisely for a reader who later asks "why does the elapsed counter not tick?", who will be led away from the answer this fix created.

**I tested the charitable reading before raising this.** Split into clauses: "the WIRE value stays EXACT, unbucketed" — true; "dom-writer.js:201 renders it verbatim to the second" — true (verified at that exact line). The failing clause is the rationale, phrased as a requirement the decision honors ("must keep showing"), which it does not. The car's **commit message** gets it right — *"The wire value stays exact whenever a snapshot is actually served fresh"* — so the precise formulation existed and was lost in the durable artifact. Commit messages are immutable; the comment is the living document, and Law 1 heads this shop's list of real failures.

**Fix:** one sentence — state that between bucket crossings the prior snapshot stands, so the displayed figure can trail by up to the bucket; note that nothing derives from it (`dom-writer.js:200-202` prints, `render.js:188` passes through) and that the alarm-bearing `state` field is exact.

---

### Minors

**m1 (Minor) — the §12b amendment and the gating matrix are silent on the half of #29 that was not done, and on what the shipped default does to the word "stale."**
The amendment characterises `stale` as *"the genuine alarm; something should be moving and is not."* With `StalenessMs: 15000` (`board/server/config.go:42`) and a shop default budget of `1800` seconds (`config/harness-defaults.json`), that alarm fires **15 seconds into a healthy 30-minute dispatch** and stays lit until it returns. Behaviour is **identical to base** — not a regression, and I will not book it as one — but it means the alarm now reads "a car is running," in the needs-attention register, while the row beside it reads `dispatched` → in-progress. Issue #29's own remedy (*"Also retune stalenessMs against measured reality"*) is untouched and unrecorded as remaining. Add one line to §12b.

**m2 (Minor) — `poll.go:515` cites `output.go:9-32` for `DispatchEntry.MarshalJSON`, which spans `output.go:9-35`** (`return json.Marshal(m)` at `:34`). Range under-covers by three lines; the start is right.

**m3 (Minor) — `gating-matrix.md:44`, Idle row, "Resets on"** says a new in-flight record "flips to `stale` if old". In an append-only store a newly landed record's `at` is ≈ now, so that branch is effectively unreachable; the reachable path is idle → `fresh` → staleness elapses → `stale`. Hedged, so not false — but imprecise on a contract surface.

### Doc checks that PASSED (stated so the fix cycle does not re-open them)

- **`gating-matrix.md:11-12` header arithmetic** — claims 9 = 3 + 6, and "5 added 2026-07-23 … +1 Idle 2026-07-26". Counted the rows: 3 harness (`:18,19,20`) + 6 yard-board (`:43-48`) = **9**. ✓
- **Design doc inline markers** — `:169-172` (freshness enumeration) and `:180-182` (Rule 1 mapping) both carry `[AMENDED, issue #29, 2026-07-26 - see §12b]`; §12b spans `:457-605` and the amendment lands inside it, append-only, ahead of §13. ✓ Real-store consequence recorded (`87 subjects, zero in flight`) and **independently verified true** by me.
- **`ingest.js:51-60`** — trued up correctly; the "cheap integer compare" invariant is preserved and the #27 rationale is now accurate. ✓
- **Glossary** — no finding. `docs/glossary.md:15-17` explicitly delegates registers and freshness to `schema/yard-snapshot.schema.json`, which now carries `idle`. No enumeration to update; `stale` is not a defined term there.
- **Spec** — no amendment owed. `docs/specs/2026-07-23-yard-board-spec.md:85-92` (YB-6) quantifies over "every freshness kind" generically; `:164-168` (YB-15) is about demo-mode suppression and remains true.
- **State ledger** — no update owed. No new mutable `Server` field; `state-ledger.md:141-146`'s note that `lastCompareBytes` is fully derived from `lastGoodSnapshot` via `mustMarshalStripped` stays true (the bucketing is inside that deterministic function).
- **Citation truth, the accurate ones** — `algorithm.go:221-222` ✓, `algorithm.go:240` ✓, `dom-writer.js:201` ✓, `poll.go:18-25` ✓, `poll.go:373-376` ✓, `board-train-retro.md:120-121` ✓ (quoted verbatim above), `docs/screenshots/2026-07-23-first-light.png` ✓ (opened; shows what is claimed).
- **Ticket citations (#3/#4 code standard)** — every new unit carries a bare `#N`: `elapsedSecondsBucketGranularity` (`poll.go:27`), `bucketDispatchesForComparison` (`poll.go:506`), `hasInFlightDispatch` (`poll.go:428`), `elapsedbucket_test.go:10`, `freshnessidle_test.go` header, `compose.js:34,46,103`, `schema:49,52`, `buildScratchStoreWithInFlightDispatch` (`real-board-server.js:41`). `CodeCitationPolicy.Tests.ps1` green inside the 194.
- **Normalisation law** — zero absolute paths in the diff (`git diff … | grep '^+' | grep -E "C:\\\\|/Users/|/home/"` → empty). The scratch store uses `mkdtempSync(tmpdir())`.

---

## 8. CONSTITUTION CHECK

| Law | Verdict | Evidence |
|---|---|---|
| **1. Truth** | **HONORED at the mechanism — and pointedly so.** The constitution's own example of a falsehood is *"a train as **idle** when it is burning tokens."* `hasInFlightDispatch` (`poll.go:428-436`) makes exactly that state unreachable: any `dispatched`/`overdue` winner forces `stale`. Verified — PROBE C (overdue → `stale`) and the #31 scratch store (in-flight → `register-needs-attention`). And the old rendering *was* the falsehood: `first-light.png` shows a fully-returned yard painted red. | Counterpoint, and it is why this is a REJECT: **M2** and **M3** are Law-1 confident falsehoods on durable information surfaces, and **M1** is one on a citation surface. |
| **3. Actionability / HAVAGLANCE** | HONORED. `idle, quiet 3040s` in nominal is a complete single-glance story — state word + honest age + calm register, verbatim-distinct from `stale, Ns`. `#29`'s compose test pins the distinctness by name. | Friction, recorded as **m1**: with `stalenessMs=15000`, "a stalled car looks stalled" degrades to "a running car looks stalled." Pre-existing; #29's untouched second half is the remedy. Also: `3040s` is a poor glance unit, inherited unchanged from `stale, Ns`. |
| **4. Nothing Silently Lost** | HONORED. `idle` *requires* `ageBucketMs` in the schema (`:51`) and renders it (observed: `3040000` → "quiet 3040s") — the age is disclosed, not suppressed, which is what separates this from muting an alarm. #27 loses nothing on the wire: `bucketDispatchesForComparison` deep-copies (`poll.go:506+`) so the served value stays exact (observed 65 and 25 exact, including on an overdue entry). | The one loss — mid-bucket *recency* — is pinned by a test but mis-described by a comment: **M3**. |
| **6. One Truth** | HONORED. `computeLiveFreshness` remains the single freshness derivation (one call site, `poll.go:308`). The browser validator compiles **THE** schema file (`validate.js:7,18-20`), so `idle` has exactly one owner across the language seam — no hand-rolled mirror. `compose.test.js`'s independently-restated `FRESHNESS_CASES` is the sanctioned test-side cross-check, not a second source. The deep copy exists precisely so the comparison basis cannot corrupt the served truth. | — |
| **7. The Stranger** | HONORED. No taxonomy hardcoded into the view; `freshnessLine`'s default (`compose.js:120-124`) still renders an unknown kind hot, by name. `STARCAR_STORE_PATH` is the server's existing knob, not a test-only backdoor. Toolchain reproducible (`package-lock.json` committed); zero absolute paths added. | — |
| **Three-register law** | HONORED, **measured**. `$defs.register` byte-unchanged. `idle` → existing `nominal`. In a real browser only three register colors resolve: `rgb(217,213,201)` / `rgb(255,180,84)` / `rgb(255,74,58)`, and the idle lane computes byte-equal to the nominal probe. No fourth register. | — |
| **Severity philosophy** | HONORED, and this is the change's strongest justification. `stale` was crying wolf **permanently** on this repo's own store (87/87 returned, independently re-derived) — a lying instrument, which this shop holds is worse than none. The fix converts a permanent false alarm into a calm truth surface that still discloses its age. | — |
| **Law-first design (who finds the law?)** | HONORED. The car reached the constraints on its own — three-register law, Law 1, Law 6's single-owner schema, the retro's design-rung question — and wrote them into §12b before I looked. I found no law the author had not already named. | — |

---

## Disposition

**REJECT** on M1, M2, M3. All three are prose-only. **No code, no test, no schema, and no suite count needs to change** — the mechanism, the red-first evidence, the wire sentence, and the #31 guard all verified sound under my own execution and fault injection. Fix-and-**delta** re-review to the same car; the empirical work in §1-§5 need not be re-derived, only the corrected sentences and coordinates re-read. The retro-concern ruling in §6 **stands and clears** independent of the fix cycle.

This REJECT is a success outcome: the citation-truth and living-document checks caught three lying canaries that same-commit doc discipline should have prevented, at one dispatch's cost instead of at the cost of a future agent believing them.

**Worktree state on exit:** clean, `git status --porcelain` empty, HEAD `4f06a4c6a09d504d0a2fe61e56120ef20bd98cbd`. Fault injections disclosed and reverted byte-identical (`board/web/css/board.css` → `07c9162781…`; `board/server/poll.go` → `87d2f0b3d4…`). Temporary probes `board/server/zzreviewerprobe_test.go` and `board/web/zz-reviewer-wire-trace.mjs` deleted. Nothing committed, nothing pushed, nothing edited in the record.

**Files a follow-up needs (absolute):**
- `<repo>-wt\review-server-27-29\board\server\elapsedbucket_test.go` (M1: lines 17, 27, 83)
- `<repo>-wt\review-server-27-29\board\web\js\compose.js` (M2a: lines 91-92)
- `<repo>-wt\review-server-27-29\board\web\test\ingest.test.js` (M2b: lines 66-69)
- `<repo>-wt\review-server-27-29\board\server\poll.go` (M3: lines 38-39, 51-53; m2: line 515)
- `<repo>-wt\review-server-27-29\docs\design\2026-07-21-v0-yard-skeleton-design.md` (m1: §12b)
- `<repo>-wt\review-server-27-29\docs\contracts\gating-matrix.md` (m3: line 44)
- `<repo>-wt\review-server-27-29\board\web\test\browser-register-cascade.test.js` (M2 advisory: line 115)

```starcar-artifact
outcome: REJECT
task-id: server-27-29-review-r1
findings: 3 Major, 3 Minor. All three Majors are prose-only living-document defects; the mechanism, red-first evidence, wire sentence and #31 guard all verified sound under my own execution and fault injection. M1 (MAJOR) three dead file:line citations in board/server/elapsedbucket_test.go, self-invalidated by the same commit 3fd4fa6 that authored them: line 17 cites poll.go:399-412 (base: the DISCLOSED #27 comment; HEAD: computeLiveFreshness body) and lines 27 and 83 both cite poll.go:190-196 for PollOnce's "otherwise the prior snapshot stands unchanged" contract (base: correct; HEAD: EndPoll plus RunPollLoop header - the quoted phrase now lives at poll.go:219-225); the shift was caused by that commit's own 29-line insertion at poll.go:27-55; binding precedent artifacts/reviews/2026-07-23-board-car2-review-round1.md:97,109 ruled this exact class MAJOR. M2 (MAJOR) two sibling comments falsified by these commits and left standing: board/web/js/compose.js:91-92 says only 'stale' carries ageBucketMs when the same commit added the idle branch requiring it at schema/yard-snapshot.schema.json:45-53, six lines above compose.js:102's own new idle case; and board/web/test/ingest.test.js:66-69 still states elapsed_seconds is unquantised and bumps seq on nearly every poll, disproven by the car's own elapsedbucket_test.go:89-98 and by my probe, while the twin comment in board/web/js/ingest.js:51-60 WAS fixed in that same commit. M3 (MAJOR) board/server/poll.go:38-39 and 51-53 claim the fix keeps a connected client showing "fresh, precise elapsed time" and preserves "per-second wire precision", contradicted by the car's own pin elapsedbucket_test.go:99-101 which asserts the served value is 10 when actual elapsed is 50; the value is exact but its recency is not, and the commit message states this correctly while the durable comment does not. m1 (Minor) design doc section 12b and the gating matrix are silent on issue #29's untouched second ask (retune stalenessMs) and on the fact that with StalenessMs 15000 in board/server/config.go:42 against a 1800s shop default budget the amendment's "genuine alarm" fires 15 seconds into every healthy dispatch; behaviour is identical to base, not a regression. m2 (Minor) poll.go:515 cites output.go:9-32 for MarshalJSON which spans output.go:9-35. m3 (Minor) gating-matrix.md:44 Idle row "Resets on" describes an idle-to-stale flip on a newly landed record, effectively unreachable in an append-only store. VERIFIED TRUE, all counts my own at 4f06a4c: Pester scripts/tests 195 total 194 passed 0 failed 1 skipped; store-checks 194/194/0, expectation derived independently as 189 artifacts json records plus 5 fixed Its; probes 24/24/0; Go 73 PASS 0 FAIL across 5 packages with go vet clean, base count 70 re-derived from git ls-tree at 8b9df53; node --test in board/web 71 tests 71 pass 0 fail in CI's own whole-directory form, which includes the 2 Playwright browser tests plus 2 no-test module files, reconciling the car's 69-plus-2 split exactly. Red-first re-derived by fault injection at HEAD, both failing verbatim for their stated reasons and both reverted byte-identical, poll.go sha256 87d2f0b3d43dea4c566a2363f1d58ea66e7f86b70eb668d1be3dc696dd292cc8. Four #27 transitions observed with my own throwaway probe suite: within-bucket no bump, bucket crossing bumps, record landing mid-bucket bumps, and dispatched-to-overdue inside one bucket bumps (budget 20s, elapsed 10 to 25, both bucket 0, seq 1 to 2) - the car's state-string claim proven not merely asserted, with an overdue entry still carrying exact elapsed_seconds because fold winnerKind stays "dispatched" at board/fold/algorithm.go:204-208 and board/fold/output.go:24-26. Real-store scan re-derived independently: 87 dispatch-kind subjects, zero with a dispatched winner, confirmed again by the live server reporting 87 returned entries. WIRE SENTENCE CLOSED with computed-style evidence from a real Chromium against the real Go binary and the real artifacts store on port 4931: schema/yard-snapshot.schema.json:45-53 idle branch, poll.go:424-427 emits it, observed on the wire as kind idle asOf 2026-07-26T18:29:49Z ageBucketMs 3040000 on all three live lanes, accepted by the schema-driven validator at board/web/js/validate.js:7,18-20 with zero page errors, mapped at compose.js:47 to nominal, rendered by compose.js:102-108 as the text "idle, quiet 3040s", written by dom-writer.js:115-117, and OBSERVED computing to rgb(217, 213, 201) - byte-equal to a free-floating .register-nominal probe and distinct from needs-attention rgb(255, 74, 58) and in-progress rgb(255, 180, 84). #31 GUARD REWIRE ADJUDICATED SOUND and its non-vacuity RE-PROVEN BY ME through a real browser: deleting color var(--nominal) from board/web/css/board.css:168 turned the guard RED quoting observed rgb(255, 74, 58) against expected rgb(217, 213, 201), which also proves the rewired precondition still holds (execution reached the cascade assertion, so the lane really did resolve register-needs-attention from the scratch store's seeded in-flight fixture); restored byte-identical to sha256 07c916278138370bdcef782c5ec0316b9972dfe6398ddd03611428aa1091a63d, guard back to 2/2. The scratch copy direction is safe: cpSync reads artifacts and writes only into mkdtempSync under the OS temp dir, and the seeded record carries all seven schema-required fields. RETRO CONCERN RULED CLEARED, not a finding: docs/retros/2026-07-23-board-train-retro.md:120-121 verified verbatim, and the amendment path satisfies it for this change because the change is coverage-class in shape (one additive oneOf branch byte-identical to its neighbour, an existing register, existing extension points, register enum untouched), because the instrument-matching section positively prefers an executable schema plus a red-first test over a prose round for a wire contract, because #30 set the same precedent at the same rung, and because the car escalated rather than self-adjudicated; the one cost of the lighter rung is booked as m1. #29 TAXONOMY ATTACKED: overdue-in-flight correctly renders the lane stale with the row also needs-attention, so no severity is lost; presumed-lost renders an idle lane with a needs-attention row per schema/vocab/board-defs.json liveness, consistent with Rule 1's three-axis definition; a store with no dispatch subjects renders idle. The poller-dead blindness is REAL but PRE-EXISTING and out of scope - lastPollAt at poll.go:70 reaches no wire field and the SSE heartbeat at handlers.go:76 is a per-connection ticker independent of RunPollLoop, but pre-#29 stale carried no poller-health information either (spec YB-15 proves staleness fires while scanning succeeds), so nothing was lost; scan-health is already covered by the failed kind at poll.go:275-281; recommend a separate ticket. Constitution: Law 1 honored at the mechanism and pointedly so (the constitution's own named falsehood is "a train as idle when it is burning tokens", which hasInFlightDispatch makes unreachable) but violated by M1/M2/M3 on documentation surfaces; Law 3 honored with m1 friction; Law 4 honored, idle requires and renders ageBucketMs and the wire value stays exact via a deep copy; Law 6 honored, one freshness derivation with one call site and a schema-driven browser validator with no hand-rolled mirror; Law 7 honored, unknown kinds still render hot by name and no absolute paths were added; three-register law honored and measured in a browser; severity philosophy honored, a permanent false alarm on this repo's own store was removed. Docs that PASSED and need not be reopened: gating matrix header arithmetic 3 plus 6 equals 9 with rows counted, design doc inline markers at 169-172 and 180-182 pointing into section 12b at 457-605, ingest.js:51-60 correctly trued up, glossary correctly delegates to the schema so no entry is owed, spec YB-6 and YB-15 quantify generically so no amendment is owed, state ledger note at 141-146 stays true since no new mutable field landed, every remaining file:line citation opened and confirmed accurate including the first-light screenshot which I opened and which shows exactly the fully-returned-yard-painted-red it is cited for, and every new unit carries its bare #27 or #29.
abstract: Adversarial sentence-check review of the server car's two commits (3fd4fa6 issue #27 elapsed_seconds change-detection quantisation, 4f06a4c issue #29 freshness stale/idle split) against base 8b9df53, at detached worktree HEAD 4f06a4c, round 1. REJECT on three Majors, all prose-only living-document defects: three self-invalidated file:line citations born in the same commit that shifted the lines, two sibling comments falsified by these commits and left standing (one six lines from the change that falsified it, its twin having been fixed in that very commit), and a newly authored claim in poll.go that the fix preserves per-second elapsed precision for a connected client, contradicted by the car's own test asserting a served value of 10 when actual elapsed is 50. The mechanism is sound and every empirical claim the car made verified true under my own execution: five suites re-run with counts derived independently rather than taken from the brief, both red-first pins re-derived by fault injection with failures quoted verbatim and reverted byte-identical, four #27 seq transitions observed with a throwaway probe suite including the dispatched-to-overdue-inside-one-bucket case the car had only asserted, the real-store zero-in-flight claim re-derived two ways, the full wire sentence traced hop by hop from the schema branch to a computed pixel in a real Chromium (idle renders "idle, quiet 3040s" at rgb(217, 213, 201), byte-equal to the nominal probe and distinct from needs-attention and in-progress), and the rewired #31 browser guard proven non-vacuous by a CSS fault injection that turned it red with the observed wrong colour quoted. The retro's design-rung concern about growing the closed freshness union is ruled CLEARED for this change on right-sizing and instrument-matching grounds plus the #30 precedent, with the one thing the lighter rung missed booked honestly as a Minor rather than waved through. Constitution honored at the mechanism on every law implicated, including the pointed case that the constitution's own example of a falsehood is calling a token-burning train idle, which the fix makes structurally unreachable; the Law 1 violations are on the documentation surfaces, which here rank equal to code. Worktree left clean, nothing committed, nothing pushed, no edit to the record. REJECT is a success outcome: the citation-truth and living-document checks caught three lying canaries at one dispatch's cost.
```