# State ledger

Status: Current

Copied from `docs/templates/state-ledger.md` (2026-07-22, dispatch harness Car 1, task
A.5). Answers BOTH questions the template asks - mutable process state, and derived
committed artifacts - per spec `docs/specs/2026-07-22-dispatch-harness-spec.md` S9 rows
1-2, which are Car 1's to instantiate.

## Header (keep arithmetic current)

Process state fields: 9 (0 dispatch-harness + 9 yard-board `board/server`, added
2026-07-23 by Car 4, plan task 4.4 - verdict totals: SAFE 8, DELIBERATE_CARRY 1,
LATENT_BUG 0). Derived committed artifact rows: 1 (instance live at
`artifacts/index.md`).

(2026-07-22, dispatch harness Car 1, task A.5): ledger created. Process 0 -> 0 (none to
begin with). Derived-artifact classes 0 -> 1 (the artifact index, generator landed in
A.4, no instance committed until Car 3's store migration).

(2026-07-22, dispatch harness Car 2, task B.6): the producer
(`scripts/Produce-Artifact.ps1`) and detector (`scripts/Detect-Dispatches.ps1`) landed,
so the artifact store now has a real writer. Process state 0 -> 0: both are stateless
(the producer fires, writes one file, commits that one path, exits; the detector reads,
folds to stdout, exits - spec S5.1, and its own S5.1 tripwire held). Derived-artifact
classes 1 -> 1: dispatch records are PRIMARY artifacts, not derived - they are the source
the index derives FROM, so they add no derived row. The artifact index remains the only
derived class, still uncommitted until Car 3's store migration.

(2026-07-22, dispatch harness Car 3, task C.1 - THE MIGRATION COMMIT): the index
instance is BORN here - `artifacts/index.md` is generated (`New-ArtifactIndex.ps1 -StoreRoot
artifacts`) and committed for the first time, over the 24 migrated review records plus
the producer's already-live dispatch records. Process state 0 -> 0 (no change - the
generator remains stateless). Derived-artifact classes 1 -> 1 (same one class; it moves
from "no instance yet" to "instance live", which is why this row flips IN THIS COMMIT -
C.1 is the commit that invalidates the old "not yet" claim, so C.1 trues it, per the
living-documents same-commit rule [C3R1-M3 folded]).

## Question 1 - mutable process state

**None.** This is a deliberate claim, not an omission: the dispatch-harness design's
one-writer-per-artifact premise (design rev 6 + A1) removes the need for any component to
remember identity, deduplicate, or track wall-clock state across calls. Every component
in this train (the schema validator, `Verify-Verdict.ps1`, `New-ArtifactIndex.ps1`, the
producer `Produce-Artifact.ps1`, and the detector `Detect-Dispatches.ps1`) is a pure
function or a stateless script invocation - nothing survives a restart because nothing is
held in memory between invocations to begin with. The producer in particular carries the
identity end to end WITHOUT remembered state: a launch record's `subject`
(`tool_response.agentId`) equals the stop record's `subject` (`agent_id`) for the same
dispatch (measured, spec #7 Probe 5), so no component needs to correlate the two hooks
from memory.

Per spec S9 rows 1-2, both parts of this claim are recorded, not one:

| Claim | Answer |
|---|---|
| Is the artifact store append-only under git? | Yes - every artifact is a new file. The writer is now real: the producer hook (`scripts/Produce-Artifact.ps1`) writes one new file per dispatch EVENT (`<subject>/<kind>-<compact-at>.json`) and commits ONLY that path (`git commit --only`, never `-a`); nothing is edited or removed in place, and a co-staged foreign file is never swept into a harness commit (Producer.Tests.ps1 entanglement test, C2R1-M2). |
| Is there mutable process state to ledger? | No - see reasoning above. The producer and detector are both stateless script invocations. |

## Question 2 - derived committed artifacts

**One row.** The artifact index (its class is born in Task A.4 - `New-ArtifactIndex.ps1`
generates it; `schema/index-format.md` defines its columns, sort order, and field
order).

| Derived artifact (owner class) | Generator | Committed? | Staleness owner | Verdict | Evidence (test name) |
|---|---|---|---|---|---|
| Artifact index (`scripts/New-ArtifactIndex.ps1`) | `New-ArtifactIndex.ps1` | **YES - instance committed at `artifacts/index.md` (Car 3, task C.1, the migration commit)** | **ARMED, SCOPED (#20, owner-ratified 2026-07-23)** - `.github/workflows/ci.yml`'s "Verify the artifact index is not stale" step (Car 3, task C.2) regenerates `artifacts/index.md` and runs `git diff --exit-code` against the committed copy on PR-to-main and push-to-main only; any drift fails the build there. Dev pushes are DELIBERATELY excluded - the producer hook stales the index on every ordinary dispatch, so gating every dev push was mechanical CI red, not a real defect; the index's own freshness-contract header (`schema/index-format.md`) declares dev's between-regeneration lag as a documented refresh cadence, never a suppressed truth surface | **GATED** - the deliberate no-gate posture through C.1 flipped in C.2's commit; #20 narrowed the scope without un-gating it | `ArtifactIndex.Tests.ps1` (determinism, the enabler, plus the freshness-header tests) + the CI step itself + `CiWrapperSimulation.Tests.ps1`'s if-condition scope test (#20) |

A deliberate no-gate posture is still a row (`docs/templates/worked-ledger-and-gating.md`):
the absence of a gate before Car 3's C.2 lands is a decision worth auditing, not a silent
hole. This row's verdict flipped in the commit that landed Car 3's CI diff step (task
C.2) - see `docs/contracts/gating-matrix.md`'s own already-ARMED row for that step.

**[F7, docs/plans/2026-07-22-pr18-correctness-fixes-plan.md]:** this row still read
"not yet ... lands as Car 3's next task (C.2)" after C.2 had already landed the gate -
C.2's own commit invalidated this row and did not true it, a living-contracts miss its
own reviewer also missed (the same class the plan folds as F7). Trued here, in the
commit that caught it.

## Question 1, amended (2026-07-23, yard-board train Car 4, plan task 4.4)

**The dispatch-harness claim above stays true for the harness's OWN components** (the
producer, the detector, the index generator remain stateless script invocations - nothing
in this amendment touches them). What changes is that a NEW, DIFFERENT long-lived process
now exists in this repo: `board/server` (design rev 5, plan task 4.3), the Go server that
polls the artifact store and serves the yard board. Unlike the harness's scripts, this is
a persistent process with an in-memory poll loop, and it introduces this repo's FIRST real
mutable process state. Process state fields: 0 -> 10 (arithmetic: seq, lastGoodSnapshot,
lastPollAt, pollInFlight, the poll timer, per-live-lane lastGoodAsOf, per-live-lane
lastGoodLaneData, connectedClients, the lane-id set, and the once-loaded recognition-
vocabulary/shop-default-budget pair).
Derived committed
artifact rows: 1 -> 1 (unchanged - the board server never writes to or commits into the
artifact store; it is a pure reader, per design D13 "the store is the SOLE adapter").

**Lifecycle events** (design S5.1/S6, spec section 6): process restart | poll cycle,
successful scan | poll cycle, scan failure | client (SSE) connect/reconnect.

| Field (owner class) | Process restart | Poll cycle (success) | Poll cycle (scan failure) | Client reconnect | Verdict | Evidence (test name) |
|---|---|---|---|---|---|---|
| `seq` (`board/server.Server`) | RESET to 0 | INCREMENT, but ONLY if the change-detection comparison (seq/asOf excluded, freshness.kind/ageBucketMs included) finds a real difference - never on the bare passage of time | UNCHANGED unless the failure itself is the first-observed change (e.g. the first scan ever to fail) | UNCHANGED (a connecting client reads the CURRENT seq, never resets it) | SAFE | `TestPollOnceChangeDetectionExcludesSeqAsOfIncludesFreshnessKind`, `TestStatelessRestartableSameContentDifferentInstance` |
| `lastGoodSnapshot` (`Server.lastSnapshot`) | RESET (rebuilt fresh: the pre-first-poll shape, all live lanes `never-polled`) | REPLACED with the new candidate whenever seq bumps | CARRIED - the previous good lane DATA stays current; only `freshness.kind` flips to `failed` with `lastGoodAsOf` marked (honest-unreachable, never an empty yard rendered as truth) | UNCHANGED (a connecting client's first SSE frame is exactly this value) | SAFE | `TestPollOnceScanFailureIsFailedWithLastGood`, `TestStatelessRestartableSameContentDifferentInstance` |
| `lastPollAt` (`Server.lastPollAt`) | RESET to `nil` | SET to the poll's injected `now` | SET to the poll's injected `now` (an ATTEMPT is recorded regardless of the scan's outcome - distinct from `lastGoodSnapshot`'s `asOf`, which only advances on success) | UNCHANGED | SAFE | `TestLastPollAtLedgerField` |
| `pollInFlight` (`Server.pollInFlight`, atomic) | RESET to `false` | `TryBeginPoll` sets true, `EndPoll` (deferred) resets false around each poll attempt | same guard, unconditionally of outcome | UNCHANGED | SAFE | `TestSkipNotQueueGuard`, `TestRestartMidPollIsEquivalentToNeverStarted` (a hard kill mid-poll leaves nothing for the NEXT process to inherit, since nothing persists across processes) |
| poll timer (`time.Ticker`, `RunPollLoop`, `poll.go`) | RESET - `RunPollLoop` constructs a brand-new `time.Ticker` every process start; no phase/interval state survives a restart | fires every `cfg.PollMs`; a tick that finds `pollInFlight` already true is SKIPPED (never queued - the same guard row above), so the timer itself never accumulates backlog | same - a tick during a failing scan still fires and still attempts a poll | UNCHANGED (the timer is process-global, not per-client) | SAFE | `TestSkipNotQueueGuard` (the guard the timer relies on); the ticker's OWN firing is production-loop behaviour with no dedicated unit test in this car (real timers are flake-prone; `PollOnce` is what every other test calls directly) - disclosed here rather than silently assumed |
| `lastGoodAsOf["live"]` (`Server.lastGoodAsOf`) | RESET (empty map) | UPDATED to the poll's `now` | CARRIED at its last successful value - this map IS the mechanism behind the `failed` freshness variant's `lastGoodAsOf` field | UNCHANGED | SAFE | `TestPollOnceScanFailureIsFailedWithLastGood` |
| `lastGoodLaneData[laneID]` (`Server.lastGoodLaneData`) | RESET (empty map) | UPDATED per live lane ID to the poll's freshly assembled `assemble.DispatchesPayload`/`GatesPayload`/`TrainsPayload` | CARRIED at its last successful value - `buildSnapshot` assigns this retained payload to `lane.Data` on a scan failure (#51 C2 fix; before this fix `lane.Data` went to Go's zero value `nil` on every scan failure regardless of prior state, degrading the web view to "no renderer for this payload" even though `freshness.kind=failed` correctly showed `lastGoodAsOf`); on the FIRST-EVER poll failure (empty map, nothing to retain) `lane.Data` stays `nil` - honest-empty, never a fabricated payload | UNCHANGED | SAFE | `TestPollOnceScanFailureIsFailedWithLastGood` (retention branch), `TestPollOnceFirstEverPollFailsKeepsDataNil` (nil branch) |
| `connectedClients` (`sse.go`'s `subscriberRegistry`) | RESET to 0 | UNCHANGED by polling itself | UNCHANGED by polling itself | INCREMENT on `/api/stream` connect, DECREMENT on disconnect (request context done) | SAFE | `TestConnectedClientsLedger` |
| lane-id set (`laneRegistry`, `laneregistry.go`) | UNCHANGED - compiled-in Go data, not runtime state; a restart cannot alter it | UNCHANGED | UNCHANGED | UNCHANGED | SAFE (immutable by construction - v0 has no adapter-plugin system yet, design D11) | `TestLaneRegistryPin` (fault-injected: shrinking the registry by one entry was OBSERVED to fail this test, then reverted byte-identical), `TestNewServerPreFirstPollIsNeverPolled` (all five lanes present even pre-first-poll) |
| recognition vocabulary + shop-default budget (`Server.vocab`, `Server.defaultBudget`) | RE-READ from disk at construction (a restart picks up an on-disk edit) | UNCHANGED - loaded ONCE at `NewServer`, never refreshed mid-process | UNCHANGED | UNCHANGED | **DELIBERATE_CARRY** - a mid-process edit to `schema/vocab/kinds.json`/`outcomes.json` or `config/harness-defaults.json` is picked up only on the NEXT restart, never mid-run; this matches `board/fold`'s own loaders (`LoadVocab`/`LoadDefaultBudget`, one-shot by design) and is documented here so it is never mistaken for a bug | `board/fold/loaders_test.go` (existing); this car's `NewServer` construction path |

**Browser-side bounded state** (rendered snapshot, connection status, last-applied `seq`)
is named here per design S6/S8 but is explicitly Car 5's to ledger - this server never
reads or writes it; it is out of `board/server`'s process boundary entirely.

## Question 3, added (2026-07-23, yard-board train Car 5, plan task 5.3) - the browser's own state

**Landed, confirming the note above rather than trueing it away from - the note held.**
`board/web/js/app.js` owns five in-memory fields across four lifecycle rows [C5R-1, swept], all VIEW-TRANSIENT (per-tab, never
persisted, never sent anywhere): `ingestState.snapshot` (the last VALIDATED wire
snapshot), `ingestState.lastAppliedSeq` (the seq-ordering row below), `ingestState.
markedStale` + `ingestState.clientConditions` (task 5.2's discard-keeps-last-render
mark), and `connected` (the disconnect watchdog's flip). This is a NEW process (a browser
tab), not a row inside `board/server`'s own 9-field count above - the header arithmetic at
the top of this file is unchanged by this addition, and is stated here as its own
question per the template's Q1/Q2 shape rather than folded into Q1's count.

| Field (owner) | Page load | Tab reconnect (network drop then restored) | Server restart mid-connection | Verdict | Evidence |
|---|---|---|---|---|---|
| `ingestState.snapshot` (`app.js`) | starts `null`; set on the FIRST payload that both parses and validates (`firstPaint`) | UNCHANGED across a transient drop - the last validated snapshot stays rendered, marked disconnected (never blanked) | UNCHANGED until a new valid, higher-seq snapshot arrives from the restarted server | SAFE | `board/web/test/ingest.test.js` (discard-keeps-last-render, seq ordering); `dom-writer.test.js`'s disconnected-still-shows-the-lane test |
| `ingestState.lastAppliedSeq` (`app.js`) | starts `-1` (`initialIngestState`) | UNCHANGED by a drop itself; the server's OWN `seq` resets to 0 on its restart (this file's Q1 row above), so the client's stored value can be numerically ahead of a freshly restarted server's `seq` until that server's count climbs back past it - a deliberate consequence of seq being a per-process monotonic counter, not a global one; the wire's `asOf`/lane data are what a reconnecting client actually judges freshness by, never a raw seq comparison across a server restart | resets to `-1` only on a full PAGE reload, never on a mere stream reconnect | SAFE | `board/web/test/ingest.test.js`'s three seq-ordering tests (lower/equal seq is a no-op; higher seq applies) |
| `ingestState.markedStale` / `clientConditions` (`app.js`) | starts `false` / `[]` | set by a validation failure (task 5.2), cleared by the next VALID payload | same | SAFE | `board/web/test/ingest.test.js` |
| `connected` (`app.js`, driven by `sse-protocol.js`'s watchdog) | starts `false` until the stream's first frame | flips `false` after two missed heartbeat intervals (`10000ms` default), flips back `true` on the next observed frame | flips `false` when the fetch/read loop throws or stalls past the watchdog | SAFE | `board/web/test/sse-protocol.test.js`'s disconnect-watchdog tests |

No lifecycle event here can produce a stale-looking "fine" - a dropped connection always
renders `disconnected - showing last known` (never silently frozen with no chrome change),
and a restarted server's lower `seq` cannot silently roll the view backward (seq ordering
drops it as a no-op rather than un-rendering already-shown data).

**A note on what is NOT a separate ledger row:** `Server.lastCompareBytes` (the stripped-
for-comparison marshal of `lastGoodSnapshot`) is fully DERIVED from `lastGoodSnapshot`
- recomputed every time that field changes (`mustMarshalStripped`, `poll.go`) - so it
carries no independent state and is not ledgered separately (Law 6: a second copy that
cannot drift, because it is recomputed from the one owner every time, is not the second
copy the law forbids).
