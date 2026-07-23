<!-- starcar-integrity: sha256=4421aa3b67cf80b942d1e6e86be2ddbf2c2f103cac0f8b85e3a7bc6ddf111cdc covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Yard board Car 4 review round 1: REJECT - the C3R-1 production guard works live but has zero committed test at the server boundary

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (adversarial, Opus, fresh detached worktree, live serve re-run)
Round: 1
Target: `car/board-car4 at 099ac49 (4 commits)`
Base reviewed: `099ac49293c354f8c86540e6ad19365467ef0cd8`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a581cde8b292e2378`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `099ac49293c354f8c86540e6ad19365467ef0cd8` |

| Dispatch, the locator within the session | `a581cde8b292e2378` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 099ac49293c354f8c86540e6ad19365467ef0cd8
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All five packages green, tree clean. My review is complete.

---

# VERDICT: REJECT

One Major (C4R-1). Otherwise strong, honest work with two genuine self-caught catches. The REJECT is narrow and cheaply remedied (one server test — I demonstrated the exact reproduction live).

## What I ran and observed (all at HEAD 099ac49, verified first)

- `go test -count=1 ./...`: all 5 packages **ok** — board 6, assemble 10, fold 21, server 24, store 12 top-level tests (matches the car's claims). `go vet` clean. `gofmt -l` empty. Re-ran green after all fault-injections; tree clean.
- **Node schema probe**: PASS (compiles under 2020-12, sample validates, non-vacuity rejection fires).
- **Pester**: 246 passed, **1 failed**, 247 total. The sole failure is `HookLatency.Probes.Tests.ps1` — `'sh' is not recognized` (pwsh lacks git-bash `sh` on PATH). The diff does **not** touch `scripts/` (last touched by 0e69591, pre-train). **Environment-only, not a Car 4 defect.** (Brief's "235/235" is a stale expectation; the harness suite grew across trains — not this car's concern.)
- **Live serve** (real store, port 4611): laneCount 5; lanes `dispatches/live/stale gates/live/stale trains/live/stale freight/dark/not-applicable fuel/bagged/not-applicable`; 53 dispatches, 1 train, vocab positions len 4; **52 board conditions** all `record-unrecognised-fields`; freight/fuel carry no `data` key. Live snapshot **validates against schema (valid:true)**. SSE `/api/stream`: `event: yard` (matches `sseEventName`, matches schema `$defs.sseEventName.const`), frame arrived. Killed; confirmed connection-refused.
- **Overdue-through-server probe** (I crafted a budget-less old dispatched record, wired DefaultsPath): rendered `state:"overdue"`, `budget_source:"default"`, `budget_seconds:1800`, `elapsed_seconds:27481`; that snapshot **schema-validates**. The mechanism works in production.

## Findings

**C4R-1 (MAJOR) — the C3R-1 production-closure guard has no committed test at the server boundary.**
`poll.go:90-92` claims the shop-default-budget fix "stays closed in production, not just in the vector suite." But `testConfig` (`poll_test.go:10-17`) never sets `DefaultsPath`, so `s.defaultBudget` is nil in every one of the 24 server tests and the threading branch (`poll.go:230-232`, `WithDefaultBudgetSeconds`) plus the loader (`poll.go:93-103`) are **exercised by zero test**. The fold *capability* is tested (`fold/vectors_test.go:104-109`, `fold/loaders_test.go`), but nothing proves the **server feeds it the default** — which is exactly the C3R-1 scar (fold not fed the default in the production path). A refactor deleting `poll.go:229-232` passes all server tests and silently resurrects C3R-1. This is the named repo failure mode: "a guard is unproven until watched fire [in the committed artifact]" and "validated facts must land as tests, never only prose." I watched it fire live, so the mechanism is sound; the **regression protection at the production boundary is absent**. Remedy: one server test (set `DefaultsPath`, write a budget-less old dispatched record, `PollOnce`, assert wire `state=overdue` + `budget_source=default`). Reproduction already demonstrated above.

**C4R-2 (MINOR) — dead citations to a nonexistent `sse_test.go`.**
`handlers.go:19`, `snapshot.go:11`, `snapshot.go:78` cite `sse_test.go`, which does not exist. The real tests exist under different names: byte-identity is `TestSnapshotAndStreamShareOneMarshalPath` (`handlers_test.go:26`); the SSE-const assertion is `TestSSEEventNameMatchesSchemaConstant` (`sse_const_test.go`). Guarantee is backed; the file:line a reader would follow is dead. Fix the three citations.

**C4R-3 (MINOR/observation) — ageBucketMs change-detection inclusion is proven only by construction.**
`mustMarshalStripped` (`poll.go:358-386`) keeps `freshness.kind`/`ageBucketMs` and strips only raw timestamps, so inclusion is correct by construction; `TestPollOnceChangeDetectionExcludesSeqAsOfIncludesFreshnessKind` (`poll_test.go:169`) robustly pins the *exclusion* direction (1ms advance → no change) and real-change detection, but no dedicated red pins that *crossing a 5000ms bucket boundary* bumps seq. Recommend a bucket-crossing test.

## Adjudications (rulings)

- **surfacesData dropped**: ACCEPTABLE schema-wins conformance, properly disclosed (`snapshot.go:41-44`). The obligation was dropped at Car 2's schema landing, not by Car 4. On the wire, bagged/dark lanes carry **no `data` key** and are distinguished by `position` (verified live: freight/fuel have no data key). Position=bagged/dark **is** the flag; surfacesData would have been redundant. Not a Car 4 blocker. **Recommend a one-line Car 5 brief obligation**: "bagged/dark lanes carry no `data` key; render fuel (bagged) as data-held-not-surfaced and freight (dark) as no-adapter, per the positions vocab" — to remove any Car 5 guessing.
- **ageBucketMs 5000ms**: ACCEPTABLE. Design rev5 §5.2 Rule 3 says "quantised, no sizes" — any reasonable quantum conforms. Rationale (`poll.go:18-25`) is sound and disclosed (coarse enough that 1s polls rarely churn seq while stale).
- **clock-steps-back scoped out**: ACCEPTABLE, not a lifecycle hole. The one dangerous manifestation (a record's `at` becoming future-relative to an earlier `now`) is already guarded and tested — `store.go:279` future-dated quarantine, `TestScanFutureDatedAtQuarantined`. Freshness degrades gracefully (negative age → fresh). 
- **52 model-field conditions**: REAL discovery, verified live — records genuinely carry undeclared `model` (27, e.g. `claude-opus-4-8[1m]`) and `body_file` (25, review records) fields. Car 4's disposition (disclose loudly, never suppress or silently add) is **CORRECT** — the board working exactly as designed (Law 1/4). **Disposition for the conductor**: file an issue to reconcile `schema/starcar-artifact.schema.json` + `store.go:94-112` `typedRecord` with the producer's real `model`/`body_file` fields. Not a Car 4 defect.
- **budget_source schema true-up (8261ba0)**: ACCEPTABLE — additive-only (new optional `string` property, `schema/yard-snapshot.schema.json:158`), correctly disclosed in the property description + commit body. Verified an overdue snapshot carrying `budget_source:"default"` schema-validates.

## Sentence check (one real record, every hop)

Subject `a184e26ee16e704ae`, traced from the live serve:
1. **Disk**: `artifacts/a184e26ee16e704ae/returned-20260723T140252Z.json` (kind=returned, at=14:02:52, outcome=done) and `dispatched-20260723T134529Z.json` (kind=dispatched, at=13:45:29, `model=claude-sonnet-5` → undeclared).
2. **Adapter**: `store.go:213` readOne double-decodes (225-241), schema-validates (258-263), parses `at` (272), returns `Record{Path,Fields}` (283); the dispatched record raises the `model` unknown-field condition (291-298). Both in `ScanResult.Records`.
3. **Fold**: `poll.go:343` `foldRecordsFrom` → `fold.Record`; `poll.go:233` `fold.Fold` → winner=returned supersedes dispatched; `DispatchEntry{State:returned, Outcome:done, Spend:absent, Superseded:[{dispatched,13:45:29}]}`.
4. **Assembler**: `assemble.go:150-160` → `dispatchWireMap` (`:178`) marshals `DispatchEntry`'s own MarshalJSON + adds `assigned:true` (`:187`, subject is in `assignedSubjects` via train:board-v0 membership).
5. **Marshal**: `poll.go:267-269` `lane.Data = assembled.Dispatches`; `snapshot.go:79` `marshalSnapshot` (the one path).
6. **HTTP body**: `handlers.go:20-27` `handleSnapshot` writes bytes (curled).
7. **Schema**: live snapshot valid:true.
Wire entry field-for-field matches disk: `at`=14:02:52 (winner's), `outcome`=done, `state`=returned, `superseded`=[{at:13:45:29,kind:dispatched}], `assigned`=true. Coherent, byte-observable.

## Go quality (practitioner read)

- **Poll guard**: `TryBeginPoll`/`EndPoll` (`poll.go:128-135`) atomic CAS — correct skip-not-queue; `RunPollLoop` (`:139-159`) only spawns a poll goroutine after CAS success, so polls are serialized. The sole mutable shared write outside `mu` (`s.lastGoodAsOf`, `poll.go:254`) is reached only from the serialized poll path (or single-threaded `NewServer`); handler readers take `mu` and never touch it. No race (race detector unavailable — no gcc — so reasoned hop-by-hop). Slightly fragile that state mutation straddles the lock boundary, but correct under the CAS invariant.
- **SSE lifecycle**: `handleStream` (`handlers.go:30-74`) selects on `r.Context().Done()`, so a client disconnect returns and `defer unregister` runs — **no goroutine leak**. `broadcast` (`sse.go:44-60`) is non-blocking (drop-if-full). `unregister` deletes-under-lock then closes; `broadcast` holds the lock across its whole iteration, so no send-on-closed-channel. Correct.
- **Fault-injection proof (C4R-1's cousin, item 5)**: I removed the discovery-surfacing loop (`poll.go:240-242`) → `TestFoldDiscoveriesAndFaultsSurfaceAsBoardConditions` went **RED** (`got board=[]`), restored byte-identical. The self-caught Law 4 fix is genuinely non-vacuous.

## Constitution check

- **Law 4** (nothing silently dropped): fold discoveries/faults reach the wire `board[]` — verified red-first by me. Unknown fields disclosed as survivors+conditions, verified live (52). **HONORED.** (C4R-1 is a coverage gap in the committed suite, not a Law-4 violation of running code.)
- **Law 1** (honest states distinct; demoMode non-suppressing): honest-empty (`TestPollOnceEmptyStoreIsFresh`) vs all-quarantined (`store.go:195-203`, `TestScanAllQuarantined`) are distinct. demoMode's only wire effect is `config.demoMode` — grep confirms no behavioral branch (`main.go:52` is a startup log only). Verified live via `TestDemoModeIsWireDisclosureOnlyAndStalenessStillFires`. **HONORED.**
- **Law 6** (pinned validator, one marshal path): `santhosh-tekuri/jsonschema/v6 v6.0.2` compiled once (`store.go:75-86`); `marshalSnapshot` the sole path (byte-identity tested over HTTP); `dispatchWireMap` reuses `DispatchEntry.MarshalJSON`. **HONORED.**
- **Law 5** (ageBucketMs server-issued): computed server-side (`poll.go:335`), never from record data. **HONORED.**
- **Law 7** (storePathDisplay never absolute): verified live — wire showed `~/AppData/...` (home-collapsed), fallback is `.../&lt;base&gt;` (`storepath.go:28`). No raw absolute path. **HONORED.**

Successes worth naming (report as wins, not consolation): the poll-timer ledger row was a **genuine self-caught living-contracts omission** (a3fa33d had "8", 099ac49 trued it to "9" with honest arithmetic, in the open); the fold-conditions Law 4 catch is a real red-first self-find; the state-ledger (0→9, 8 SAFE / 1 DELIBERATE_CARRY) and gating-matrix (3→8) arithmetic is correct and every cited test exists and was opened; the disconnect-row server-half-only scope is honestly disclosed, not padded.

```starcar-artifact
outcome: REJECT
findings: One Major (C4R-1) and two Minor. C4R-1 - the server's shop-default-budget threading (poll.go:93-103, 229-232), which poll.go:90-92 claims keeps the C3R-1 divergence closed in production, has zero committed test at the server boundary - testConfig (poll_test.go:10) never sets DefaultsPath, so s.defaultBudget is nil in all 24 server tests and WithDefaultBudgetSeconds is never exercised; only fold-level vectors cover the capability, so a refactor dropping poll.go:229-232 passes green and silently resurrects C3R-1. Mechanism verified working live by the reviewer (budget-less dispatched rendered state=overdue, budget_source=default, budget_seconds=1800, schema-valid), so this is a missing regression test, not a broken feature; remedy is one server test. C4R-2 (Minor) - three dead citations to a nonexistent sse_test.go (handlers.go:19, snapshot.go:11, snapshot.go:78); the real tests are TestSnapshotAndStreamShareOneMarshalPath (handlers_test.go:26) and TestSSEEventNameMatchesSchemaConstant (sse_const_test.go). C4R-3 (Minor) - ageBucketMs change-detection inclusion is correct by construction (mustMarshalStripped) but not pinned by a bucket-crossing red. Adjudications: surfacesData drop is acceptable schema-wins conformance (position=bagged/dark plus data-key-absence is sufficient for Car 5; recommend a one-line Car 5 brief note); ageBucketMs 5000ms acceptable within the design's quantised-no-sizes latitude; clock-steps-back acceptable (future-dated-at quarantine covers the dangerous case); the 52 model-field conditions are a real verified discovery (records carry undeclared model and body_file), Car 4's disclose-loudly disposition is correct, conductor should file a schema-reconciliation issue; budget_source schema true-up is additive-only and correctly disclosed. Suites observed by reviewer at 099ac49 - go test all 5 packages ok (board 6, assemble 10, fold 21, server 24, store 12); go vet clean; gofmt empty; node probe PASS; Pester 246 pass 1 fail where the sole failure is an environment issue (pwsh lacks sh on PATH for HookLatency probe, diff does not touch scripts). Live serve confirmed laneCount 5, correct positions, 53 dispatches, vocab positions len 4, 52 model/body_file conditions, SSE event name yard, snapshot schema-valid, storePathDisplay home-collapsed never absolute. Sentence check traced subject a184e26ee16e704ae disk-to-schema at every hop with file:line. Constitution Laws 1,4,5,6,7 honored. Self-caught poll-timer ledger row and fold-conditions Law 4 fix are genuine success outcomes.
abstract: Adversarial sentence-check review of Car 4 (the server car - board/store, board/assemble, board/server, plus state-ledger and gating-matrix) at HEAD 099ac49 against base bef57f5. Verdict REJECT on one Major: the shop-default-budget threading that closes the known C3R-1 regression in the production (server) path is wired and demonstrably works live, but has no committed regression test at the server boundary (every server test leaves DefaultsPath empty), so the guard the car's own prose claims is unproven in the committed suite - the exact fault mode this repo's doctrine names. Two Minor findings (dead sse_test.go citations; unpinned ageBucketMs inclusion). All five adjudicated deviations ruled acceptable or routed to the conductor as follow-ups, with the model/body_file schema-drift discovery flagged for a reconciliation issue. Live serve, schema validation, byte-identity over HTTP, a red-first fault-injection of the fold-conditions fix, and a full disk-to-schema sentence trace were all performed by the reviewer; fault-injections restored byte-identical, worktree clean, nothing committed or pushed.
```