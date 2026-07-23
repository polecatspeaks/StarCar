# Gating matrix

Status: Current

Copied from `docs/templates/gating-matrix.md` (2026-07-22, dispatch harness Car 1, task
A.5). Per spec `docs/specs/2026-07-22-dispatch-harness-spec.md` S9 rows 1-2, this file is
Car 1's to instantiate with the three surfaces below.

## Header (keep count current)

8 surfaces audited (3 dispatch-harness + 5 yard-board, added 2026-07-23 by the yard-board
train's Car 4, plan task 4.4).

## Table shape

| Surface | Fires when | Suppressed when | Resets on | Classification | Evidence (test name) |
|---|---|---|---|---|---|
| Tier 1 detection (spec S2.5) | a `dispatched` record has no `returned`/`presumed-lost` successor. The fold renders the liveness gradient (spec S3.3): `dispatched` within budget, `overdue` WITH elapsed and budget past it - the derived `unaccounted-for` truth (S3.1: unaccounted-for is DERIVED) a board reads off these states, and per Probe 1 the only surface for a killed dispatch (which fires no stop hook) | never - a truth surface (spec S3.1: this is a fold requirement, not a rendering suppression) | a `returned` or `presumed-lost` record supersedes the `dispatched` record (latest-`at` wins; the fold exposes every superseded record) | GATED - a fold requirement; the artifacts alone are sufficient, any conforming shop gets tier 1 (spec S2.5) | LANDED Car 2: `scripts/Detect-Dispatches.ps1` + `scripts/tests/Detector.Tests.ps1` - precedence `returned`>`presumed-lost`>`dispatched`; two `returned` resolve latest-`at` with the older exposed in `superseded`; a `dispatched` past budget renders `overdue` with elapsed+budget; a record `budget` overrides the shop default; a later `intent` supersedes the earlier hold |
| Tier 2 detection (spec S2.5) | the Entire checkpoint branch, as the enumerable second source, disagrees with or extends tier 1's fold | **ARMED (Car 3, task C.2, fixed fix-cycle round 1 - M-A):** `.github/workflows/ci.yml` now fetches `entire/checkpoints/v1` after checkout, non-fatal (loud `::notice::`) if the ref is absent - a fork has no Entire checkpoint branch (Law 7). **This claim was FALSE from C.2's original landing until fix-cycle round 1**: GitHub Actions' `shell: pwsh` wrapper appends an exit-on-`$LASTEXITCODE` suffix, and an absent-ref `git fetch` (exit 128) failed the step even though the script's own logic never called `exit` - reproduced (`STEP-EXIT=128`) and fixed by resetting `$LASTEXITCODE` to 0 on the absence branch, then re-verified (`STEP-EXIT=0`) both by manual wrapper simulation and by a committed regression test (`scripts/tests/CiWrapperSimulation.Tests.ps1`, which extracts the REAL `run:` text from `ci.yml` and exercises both the absent-ref and present-ref cases against real fixture git remotes). Tier 2 is now CI-REACHABLE; tier-2 ENUMERATION itself remains deferred (see next column) | landed | GATED, producer-dependent - fetch armed, enumeration deferred | Fetch landed (Car 3, `ci.yml`'s "Fetch the Entire checkpoint branch" step) and its non-fatal claim PROVEN by fault injection (`CiWrapperSimulation.Tests.ps1`, fix-cycle round 1). **DEFERRED still (R6v2): tier-2 ENUMERATION** needs a dispatch-enumerable second source proven by probe - the checkpoint branch enumerates CHECKPOINTS keyed to commits, not dispatches, with no checkpoint-to-subject map, so enumerating it today would raise a false gap per commit (a wolf-crier, worse than none). Trigger recorded in `docs/setup.md`. Tier EXPOSURE shipped in Car 2 (the fold reports `tier: tier-1-only` truthfully) |
| Artifact-index staleness | **on a PR targeting main, or a push to main** (#20, owner-ratified 2026-07-23): the workflow regenerates `artifacts/index.md` via `scripts/New-ArtifactIndex.ps1` and diffs it against the committed copy; any difference fails the build | **on dev pushes, DELIBERATELY (#20):** the producer hook (`scripts/Produce-Artifact.ps1`) writes a record on every dispatch, so gating every dev push turned ordinary conductor activity into mechanical CI red, not a real staleness defect. The index's own freshness-contract header (`schema/index-format.md`) documents dev's between-regeneration lag as a refresh cadence - this is a documented cadence, never a suppressed truth surface (Law 1) | the index instance was committed in Car 3's migration commit (task C.1); the CI gate now checks it on PR-to-main and push-to-main runs (scoped from every run, #20) | **GATED as of this commit** - the deliberate no-gate posture through C.1 flips here, same-commit with the state that made a gate possible; the scope narrowed again in #20 without un-gating it | `ArtifactIndex.Tests.ps1`'s byte-identical determinism test (Task A.4, the enabler) + the CI step itself. **Local fault-injection proof (this task):** a scratch copy of the committed store, staled by one appended row, produces a 1-line `Compare-Object` diff against a fresh regeneration - the exact mechanism the CI step runs; a clean copy diffs clean. The live CI-side firing (a real dispatch landing without a regenerate) is conductor handback, per spec §6's testing discipline. **#20 scope evidence:** `scripts/tests/CiWrapperSimulation.Tests.ps1`'s "carries an if condition scoping it to exactly PR-to-main OR push-to-main" test (parses the real `ci.yml` step) + `scripts/tests/ArtifactIndex.Tests.ps1`'s freshness-contract header tests. **Live skip-on-dev OBSERVED:** run 30002661752 (dev push `437c959`, the very push that landed the merged scoping), step "Verify the artifact index is not stale" `conclusion: skipped` on BOTH matrix legs, queried via `gh run view --json jobs`. The live FIRE half (gate running and passing/failing on a real PR-to-main) remains conductor handback at the next PR |

Severity philosophy for anything that judges data: expected/placeholder patterns are
NOTES, defects are FLAGS. An instrument that cries wolf is worse than no instrument. The
tier-1 FOLD LOGIC landed in Car 2 (`Detect-Dispatches.ps1` + `Detector.Tests.ps1`) and was
already GATED as an inherent fold requirement - no CI wiring needed for it, any conforming
shop gets tier 1 for free. **The other two rows are now armed as CI gates (Car 3, task
C.2)** - the checkpoint-branch fetch and the index-staleness diff step both live in
`.github/workflows/ci.yml`. Tier-2 ENUMERATION remains the one deliberately deferred item
in this table (R6v2, trigger in `docs/setup.md`); rendering is #1's job. That mix - every
fold landed, both CI-dependent gates armed, one enumeration decision still ahead by
design - is the DELIBERATE state this table records, not an omission.

## The yard board's five truth surfaces (2026-07-23, yard-board train Car 4, plan task 4.4)

Design rev 5's S1 constraints table names the board's own gating-matrix obligation
(`docs/contracts/gating-matrix.md (staleness row)` - "never suppressed, DELIBERATE, no
override"); this section instantiates it plus the four other truth surfaces plan task 4.3
built.

| Surface | Fires when | Suppressed when | Resets on | Classification | Evidence (test name) |
|---|---|---|---|---|---|
| Staleness (per live lane: dispatches/gates/trains) | the newest OBSERVED record's `at` is older than `stalenessMs` (default 15000ms), given a scan that itself succeeded (design S5.6: staleness is DATA age, never scan-cadence health) | **never - proven, not merely asserted:** an identical frozen fixture polled twice, once with `config.demoMode=false` and once with `config.demoMode=true`, renders `stale` IDENTICALLY both times (spec YB-15's binding rule: "the design retired demo-mode suppression; this field exists to DISCLOSE demo data, never to mute anything") | a NEW record observed within `stalenessMs` of `now` | GATED, DELIBERATE, no override | `TestPollOnceStaleAfterThreshold`, `TestDemoModeIsWireDisclosureOnlyAndStalenessStillFires` (the fault-injection proof: identical input, only `config.demoMode` differs, staleness kind is identical on both runs) |
| Disconnect (SSE, **server half only** - the client-side 2-missed-heartbeat flip is Car 5's, plan section 6) | (client-side, not this car's to gate) two consecutive `heartbeatMs` intervals pass with no frame | never (a truth surface) | (client-side) any frame arriving, data or heartbeat | GATED (server contribution), DEFERRED (client flip) - named here so the split is a decision, not a silent gap | `TestSSEEventNameMatchesSchemaConstant`, `TestSnapshotAndStreamShareOneMarshalPath` (the server's heartbeat writer, `writeSSEHeartbeat`/`sse.go`, is exercised by the stream handler these tests hit; the CLIENT-side flip has no Go test because no client exists yet in this car) |
| Failed-panel (per live lane) | `board/store.Adapter.Scan` returns an error (the store directory is missing/unreadable) | never (design S6 row 1: "NEVER an empty yard rendered as truth") | the next scan that succeeds | GATED, DELIBERATE, no override | `TestPollOnceScanFailureIsFailedWithLastGood` (the store directory is removed mid-run; freshness flips to `failed` with `lastGoodAsOf` carried, never silently `fresh`) |
| Detector/discovery rendering | `board/fold.Fold`'s own `Discoveries` (an unrecognised `kind`/`outcome`) or `Faults` (an unreadable/malformed/empty recognition vocabulary) are non-empty for this poll | never - Rule 4 (design S5.2): "the detector's register is needs-attention, deliberately - the one alarm that is about the board rather than the yard" | the next poll where the fold reports neither (the record is gone, or the vocabulary now recognises it) | GATED, DELIBERATE, no override | `TestFoldDiscoveriesAndFaultsSurfaceAsBoardConditions` - **fault-injection proof, not just a positive case:** this test was RED on arrival (`board=[]` - the fold's discoveries were computed and then silently discarded, never reaching the wire) until `poll.go`'s `buildSnapshot` was fixed to fold `out.Faults`/`out.Discoveries` into the wire `board` array; the red-to-green transition is the proof this gate actually fires |
| Board conditions (general disclosure: quarantine, unknown-fields, manifest/subject-namespace collisions, vocab-defs load failures) | `board/store.Adapter.Scan` quarantines a record or discloses unknown fields; `board/assemble.Assemble` detects a collision; `board/assemble.LoadVocabularies` hits a missing file or a malformed row | never (Law 1/4: a board that guesses or silently drops is the harm these exist to prevent) | the next poll where the underlying condition no longer holds | GATED, DELIBERATE, no override | `board/store`'s `TestScanAllQuarantined`/`TestScanUnknownFieldRecordDisclosed`/`TestScanMalformedAtQuarantined`/`TestScanFutureDatedAtQuarantined`; `board/assemble`'s `TestAssembleManifestMembershipCollision`/`TestAssembleSubjectNamespaceCollision`/`TestLoadVocabulariesMissingFileYieldsOneCondition`/`TestLoadVocabulariesBadRowQuarantinedAndConditioned` |

**Disclosed scope boundary, not a gap:** the Disconnect row's client-side half (the
2-missed-heartbeat flip a human actually sees) has no evidence in THIS car because no
client exists yet - `board/web/` is Car 5's task (plan section 6). Naming the split here,
rather than marking the whole row GATED on the strength of only the server's half, is the
point of a living gating matrix: a reader must never infer client behaviour from a
server-only test.

**Disclosed finding, out of this fix cycle's scope (2026-07-23, found writing the C4R-3
regression test, Car 4 review round 1 fix cycle):** the Staleness row's change-detection
comparison (`mustMarshalStripped`, `poll.go`) strips `freshness.asOf`/`lastGoodAsOf` but
does NOT strip a dispatched-winner entry's `elapsed_seconds` (`board/fold.DispatchEntry`,
recomputed every poll from `now - at`) - unlike `ageBucketMs`, this field is not quantised,
so a live train with an actively dispatched (not yet returned) car will bump `seq` on
essentially every poll that crosses a whole second, not only on a real state change. Found,
not fixed: the ordering review scoped this cycle's C4R-3 ask to `ageBucketMs`'s inclusion
direction specifically, and whether `elapsed_seconds` should be quantised the same way (and
at what granularity) is a genuinely separate design question, not a silent side-fix riding
on an unrelated commit. Recorded here so it is a decision awaiting the conductor's triage,
never a silently-dropped observation.
