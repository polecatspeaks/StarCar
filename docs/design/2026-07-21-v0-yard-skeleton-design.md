# Design: v0 yard skeleton

Status: **PARKED at rev 3, DELIBERATELY UNREVIEWED - superseded in part, awaiting rev 4**

> **Why this was never reviewed, stated so nobody assumes it passed a gate.** Rev 3 was
> committed and round 3 was about to be dispatched when the owner ruled that the dispatch
> harness is core product: every dispatch emits a structured artifact, and the yard
> adapter reads those artifacts rather than a hand-maintained state file. That rewrites
> D3, D5, §5.4 and the StateWriter car, so reviewing rev 3 would have spent an adversarial
> dispatch on a moving target and produced findings against contracts already changing.
>
> Parked on purpose, not forgotten. The harness design goes through the ladder first
> (issue #7); this document returns as rev 4 written against the harness contract, and is
> reviewed once, properly. Rev 3's unreviewed defects are a known, accepted risk: some
> will be inherited into rev 4 and must be caught there.
>
> Rounds 1 and 2 verdicts are landed verbatim in `docs/reviews/`.
Issue: #1 (`area:view`)
Date: 2026-07-21 (rev 3: 2026-07-22)
Ladder rung: design (rung 1 of: design → spec → plan → cars)
History: rev 1 REJECT (9 Major), rev 2 REJECT (8 Major). See §13.

## 1. What this train delivers

A running StarCar: a local server process that reads a conductor-maintained state file
and renders the yard live in a browser, with every declared lane present from the first
commit - whether or not it has data yet.

A lane is a **socket with a declared position on a build-out**, not a payload that is
either present or absent. The socket exists before the data does; going live later is
plugging in, not rebuilding.

## 2. The epistemic constraint

We cannot enumerate the states this board needs, because **running the yard is what
generates them**. Rev 1 declared four lane states; its review found a fifth; the owner
found three more and split one of those into three again.

Law 7 (`constitution.md:54-55`) already ruled: *"pluggable adapters, no hardcoded board
schemas or label taxonomies."*

**The rule: close what MECHANISM determines, open what the SHOP names.**

- A poll either has no adapter, or has never run, or last succeeded, or last failed. That
  set is closed by mechanism and provably complete, so it is a compile-time union.
- What a lane is *called*, what a car's state is *called*, what a gate's aspect is
  *called* - these are shop vocabulary. Open sets, therefore **data**.

**The unrecognised-value path is the detector, not an error path.** When the board meets a
vocabulary value it does not know, it renders that fact loudly and by name: Law 1 and Law 4
doing their jobs, and simultaneously the instrument that tells us we observed a state
nobody enumerated. You do not resolve an observation-dependent state space by guessing
harder. You build the detector and open the box.

**Therefore v0's job is discovery.** Ship the minimum vocabulary we have genuinely
observed, plus the path that surfaces the rest.

## 3. Decisions

| # | Decision | Reason |
|---|---|---|
| D1 | Live server + browser | A wall display glanced at, not a page refreshed. |
| D2 | TypeScript on Node, **with runtime validation at every boundary** | Sharing a type declaration does NOT make a wire safe. §6. |
| D3 | Conductor state file is the first adapter | Only source that *knows* a REJECT happened; git records no verdicts. |
| D4 | Every declared lane present in every snapshot | Law 4. Guarded per §5.5. |
| D5 | A writer ships in this train | Hand-editing JSON mid-train is hand-maintained state at a process boundary. |
| D6 | Poll by mtime; do not `fs.watch` | Atomic rename swaps the inode; `fs.watch` handles that poorly, worse on Windows. |
| D7 | Data-staleness (server, per-lane) and connection-loss (client, whole-board) are separate truths, simultaneously displayable | They fail independently, live at different scopes, and imply different actions. |
| D8 | Registers closed; all other taxonomies open | §2. |
| D9 | SSE over browser-side polling | Recorded rejected alternative: browser polling would delete §7's problem set. SSE wins the wall-board case; the price is the rules in §7, now specified. |
| D10 | Toolchain + CI car runs FIRST | *"Verified means the pipeline that ships it went green."* Until CI exists no car can claim verification. |
| D11 | **The lane registry is the SOLE owner of a lane's position** | Rev 2 implied two owners with no precedence rule. §5.4. |

## 4. The domain payload

Rev 2 specified the envelope exhaustively and never said what a lane carries. Rev 1 was
more specific here; that was a regression and this section repairs it.

```ts
type Yard = {
  writtenAt: string          // ISO-8601, stamped by the writer. THE provenance of asOf.
  trains: Train[]
  gates:  Gate[]
}

type Train = { id: string; title: string; cars: Car[] }

type Car = {
  id: string
  title: string
  state: string              // OPEN vocabulary - a CarStateDef id
  sha?: string
  rejectRounds: number
  reviewer?: string
}

type Gate = {
  id: string
  name: string
  aspect: string             // OPEN vocabulary - a GateAspectDef id
  at?: string
}
```

`Car.state` and `Gate.aspect` get the same treatment as lane positions: open vocabularies
shipped as data, carried on the wire, with the detector on unrecognised values.

```ts
type CarStateDef   = { id: string; label: string; register: Register }
type GateAspectDef = { id: string; label: string; register: Register }
```

v0 ships only what we have observed, inherited from issue #1's founding enumeration:

| Car state | Label | Register |
|---|---|---|
| `staged` | Staged | `nominal` |
| `rolling` | Rolling | `in-progress` |
| `at-inspection` | At inspection | `in-progress` |
| `shopped` | Shopped (REJECT x N) | `needs-attention` |
| `coupled` | Coupled | `nominal` |
| `held` | HELD by dispatcher | `in-progress` |

`held` exists because Law 2's own worked example is *"if a dispatcher marks a train held,
the board renders held."* Rev 2 named the StateWriter as v0's embodiment of Law 2 while no
`held` value existed anywhere, so the mechanism could not express the law's example.

| Gate aspect | Label | Register |
|---|---|---|
| `pending` | Pending | `in-progress` |
| `green` | Green | `nominal` |
| `red` | RED | `needs-attention` |

## 5. The lane contract

### 5.1 Registers - the ONLY closed taxonomy

```ts
type Register = 'nominal' | 'in-progress' | 'needs-attention'
// severity order, used by §5.6: nominal < in-progress < needs-attention
```

The glance-language. Law 3 lives here: a dispatcher resolves the board in one pass, and a
visual vocabulary anyone may extend decays into mush. Growing this set is a
constitution-level decision.

### 5.2 Positions - OPEN, shipped as data

```ts
type PositionDef = {
  id: string
  label: string
  register: Register
  surfacesData: boolean
}
```

| id | label | register | surfacesData |
|---|---|---|---|
| `live` | Live | `nominal` | true |
| `bagged` | Data held, not surfaced | `nominal` | false |
| `dark` | No equipment | `nominal` | false |
| `under-construction` | Being built | `in-progress` | false |

`bagged` is the railroad term for a signal that physically exists and is deliberately out
of service, hooded so crews know not to obey it.

### 5.3 Freshness - CLOSED, because mechanism determines it

```ts
type Freshness<T> =
  | { kind: 'not-applicable' }                                    // no adapter attached
  | { kind: 'never-polled' }                                      // adapter attached, not yet run
  | { kind: 'fresh';  data: T; asOf: string }
  | { kind: 'stale';  data: T; asOf: string; ageBucketMs: number }
  | { kind: 'failed'; reason: FailureReason; lastGood?: T; lastGoodAsOf?: string }

type FailureReason = { code: string; detail: string }
```

`not-applicable` is restored. Rev 1 had it as `no-adapter`; rev 2 dropped it while still
carrying a "lane has no adapter" error row, which made the union unable to express a
`dark` lane and made rev 2's own `never-polled` test unwritable.

The union is closed by mechanism and provably complete: an adapter is attached or not; if
attached it has run or not; if run it succeeded or failed.

`ageBucketMs` rather than `ageMs` - see §7's change-detection rule.

### 5.4 Lane, registry, and the single owner of position

```ts
type LaneDef = {                 // the REGISTRY entry - product build-out truth
  id: string
  title: string
  position: string               // a PositionDef id
  adapter: string | null         // null => Freshness is 'not-applicable'
}

type Lane = {                    // what ships on the wire
  id: string
  title: string
  position: string
  freshness: Freshness<unknown>
}
```

**D11: the lane registry is the sole owner of `position`.** The state file has no position
field and the schema forbids one. Rev 2 said the registry owned it in one section and that
the state file could supply one in another; one of those was wrong and the design did not
say which.

Positions change on deploy, not at runtime, and that is honest: a lane going `bagged` →
`live` genuinely IS a deploy, because it means a renderer shipped.

Recorded for the future: when a second source of positions is introduced, Law 6 requires a
precedence rule *and* a disagreement rendering. Not creating the second source is how v0
avoids owing both.

### 5.5 The Law 4 / Law 7 trade, and the completeness guard rev 2 lacked

Rev 1 made lanes four required keys, so omission was a compile error. Rev 2 weakened this
to a registry plus a test and claimed equivalence. **That claim was wrong**, and the
review was right: the compiler guaranteed both that every snapshot contains every lane
*and* that the lane set cannot shrink silently. The registry test covered only the first.
Delete a line from the registry and the build passes, the test passes vacuously, and a
lane vanishes with no trace - a lie of omission reintroduced by the fix.

Three guards, together equivalent:

1. **Every registered lane appears in every snapshot**, every code path, including before
   the first poll. Red-first against a hand-constructed lanes object.
2. **The expected lane-id set is pinned by a fixture-backed test.** Shrinking the registry
   fails it. Growing it is a deliberate edit to both files, which is the point.
3. **The board renders "registry declares N lanes" in chrome**, and the lane-id set is
   ledgered with old → delta → new arithmetic. A shrink is visible on the surface it
   damages.

Rev 2 applied exactly the right suspicion to the state file ("a human, a bad merge or a
rebase can produce garbage the writer never saw") and none of it to the registry, which is
the same kind of hand-edited file with a larger blast radius.

### 5.6 COMPOSITION - how three axes resolve into one glance

*This section is rev 3's centre of gravity. Rev 2 specified the axes and never specified
their composition, which produced six of its eight Major findings - including a `live`
lane whose state file was deleted rendering calm.*

Three independent facts describe a lane:

| Axis | Owner | Question it answers |
|---|---|---|
| `position` | lane registry | What this lane IS on the build-out |
| `freshness` | adapter | What its DATA is doing |
| `capability` | the view, locally | Whether a renderer exists for this payload |

`capability` is deliberately view-local and never on the wire: the server has no business
asserting what a browser can render, and putting it on the wire would be a second copy of
something that can drift.

**Rule 1 - rendered register is the MOST SEVERE of the contributing registers.**

```
renderedRegister(lane) = max_severity(
    positionRegister,        // from PositionDef, or needs-attention if unrecognised
    freshnessRegister,       // per the table below
    capabilityRegister )     // nominal, or needs-attention if a renderer is missing
```

| Freshness | Register | Why |
|---|---|---|
| `not-applicable` | `nominal` | No adapter is correct, not wrong. |
| `never-polled` | `in-progress` | Something is happening and will resolve. |
| `fresh` | `nominal` | |
| `stale` | `needs-attention` | Law 5: a stale board that looks live is the disease. |
| `failed` | `needs-attention` | |

This is the fix for rev 2's worst finding. A `live` lane (`nominal`) whose state file is
deleted (`failed` → `needs-attention`) now resolves to `needs-attention`. **The board goes
hot when the data dies, in the one scenario this project exists to render.**

**Rule 2 - rendered words: position speaks first, freshness speaks second.**

- **Primary line** is always the position label. It says what the lane IS.
- **Secondary line** is the freshness statement, **omitted entirely when
  `not-applicable`** - a lane with no adapter must never say "not yet read", because it
  will never be read, and `constitution.md:17` requires unknown to render as unknown
  rather than as a plausible-sounding falsehood.
- **When `position.surfacesData` is false**, the payload is not rendered even if freshness
  is `fresh`, and the secondary line says so explicitly ("holding 3 gates, not surfaced").
  Data held and not shown is disclosed, never silently dropped (Law 4).
- **When capability is missing**, the board says "no renderer for this payload" rather
  than rendering nothing.

**Rule 3 - rendered age always comes from the server.** See §7's change-detection rule.
The client never computes age from its own clock, because that is the UI computing its own
state (Law 6) and it reintroduces browser-to-server skew that §8 works to control.

**Rule 4 - the detector's register is `needs-attention`, deliberately**, against the
general principle that nothing alarms unless something is wrong. Stated so a car does not
resolve the tension the other way: an unrecognised vocabulary value genuinely requires
human action (add the entry), and Law 1 requires unknown to render as unknown. It is the
one alarm that is about the board rather than the yard.

### 5.7 Snapshot

```ts
type YardSnapshot = {
  seq: number                  // assigned AFTER change detection - see §7
  asOf: string | null          // most recent SUCCESSFUL poll of any adapter; null if none ever
  config: {
    pollMs: number; heartbeatMs: number; stalenessMs: number
    statePathDisplay: string   // CWD-relative or home-collapsed - NOT the raw absolute path
    laneCount: number          // §5.5 guard 3
    demoMode: boolean
  }
  vocabularies: {
    positions: PositionDef[]
    carStates: CarStateDef[]
    gateAspects: GateAspectDef[]
  }
  board: BoardCondition[]      // board-level faults - see §9
  lanes: Lane[]
}
```

Vocabularies travel on every snapshot so the view never hardcodes one and no separately
fetched copy can drift (Law 6, and adopted ruling Q2).

### 5.8 `Adapter<T>` - the seam

```ts
type AdapterResult<T> =
  | { ok: true;  data: T; asOf: string }
  | { ok: false; reason: FailureReason }

interface Adapter<T> { readonly name: string; poll(): Promise<AdapterResult<T>> }
```

Health is part of the return value, not a side channel: a lane cannot be rendered without
carrying its own health, because the type will not let you separate them.

## 6. Wire safety

Rev 1 claimed sharing a TypeScript type reduced the sentence check to "confirm the type is
shared." That was wrong three ways; the repairs are binding.

1. **A duplicate type declaration is NOT a build failure.** TypeScript is structurally
   typed; a second, divergent `YardSnapshot` compiles clean, especially where the value
   arrives from `JSON.parse` and is cast. **Repair:** an ESLint `no-restricted-syntax` rule
   banning declaration of these names outside `src/schema.ts`. Red against a two-definition
   codebase. *Rev 2 also specified a source scan; it is pruned as redundant with the lint
   rule, which runs in the editor and in CI.*
2. **`JSON.parse` is an unchecked cast.** `ageBucketMs` becomes `null` if ever `Infinity`
   or `NaN`; `JSON.stringify` drops `undefined` keys, losing the distinction between
   explicitly-cleared and absent. **Repair:** the view runs the shared runtime validator on
   every parsed payload.
3. **The SSE event name is a hand-written string on both sides.** One character apart and
   the listener never fires, the socket stays **open**, and the client reports itself
   connected while displaying the first paint forever. **Repair:** an exported constant in
   `schema`, with a test asserting the server writes what the client subscribes to.

`/api/snapshot` and `/api/stream` are two producers of one payload - a hand-maintained
mirror by another name. **Both serialise through one exported function, with a test
asserting byte-identical output.**

**The sentence, declared in full**, starting one process earlier than rev 2 declared it:
CLI argv → writer validation → temp file → rename → file read → state-file validator →
assembler → serialise → HTTP body / SSE frame → `JSON.parse` → wire validator → compose
(§5.6) → DOM. Per-car reviewers trace every hop. The scar this repo carries is
specifically about a process hop outside every review's declared scope.

**The six validators**, enumerated because rev 2 said "both validators" while loading four
more inputs: state-file, wire-snapshot, lane-registry, position-vocabulary,
car-state-vocabulary, gate-aspect-vocabulary.

**State-file validator strictness:** unknown keys are **preserved and disclosed**, never
silently ignored and never fatal. The board raises a `BoardCondition` reading "state file
carries N unrecognised fields". Ignoring them silently drops data (Law 4); rejecting the
file blanks the board over a conductor's harmless addition (Law 1, harshly). Disclosure is
the only option that loses nothing and lies about nothing.

## 7. `Server`

- `GET /`, static assets; `GET /api/snapshot` (first paint); `GET /api/stream` (SSE).
- Poll loop at `pollMs`.

**Change detection.** Emit when the canonical serialisation differs from the last emitted,
**excluding `seq` and `asOf`**, and **including `freshness.kind` and `ageBucketMs`**.

- `seq` is excluded and **assigned after** the comparison. Rev 2 left this ambiguous, and
  under one reading every snapshot differed from the last, which would have falsified D9's
  own justification that an idle yard costs nothing.
- `ageBucketMs` is *quantised* age (1s buckets under a minute, 10s above). Including it
  means **the age on screen is always a number the server issued**, updating about once a
  second while anything is stale, and an all-fresh yard stays silent. This is the fix for
  rev 2's frozen-age defect, where the board would have displayed "stale, 15s" for forty
  minutes, or the client would have computed age locally in breach of Law 6.

**Heartbeat.** An SSE comment every `heartbeatMs`; the client flips to disconnected after
two missed. `heartbeatMs` travels in `config` so the client does not hardcode it. Without
this, a half-open connection leaves `EventSource` in `readyState === OPEN` indefinitely
with no error event.

**Ordering.** `seq` is monotonic; the client applies a snapshot only if `seq` exceeds the
last applied. Without it a first-paint fetch resolving after an early stream event
overwrites newer state with older.

**Poll concurrency.** `pollInFlight` guards; an overlapping tick is **skipped, not
queued**. Two concurrent reads completing out of order would let an older read overwrite a
newer snapshot.

## 8. `SnapshotAssembler`, `StateWriter`, provenance

```ts
interface SnapshotAssembler {
  assemble(input: {
    registry: LaneDef[]
    results: Map<string, AdapterResult<unknown>>   // keyed by adapter name
    previous: YardSnapshot | null
    now: () => number
    stalenessMs: number
  }): YardSnapshot
}
```

Pure. Owns staleness classification; nothing else derives it (Law 6). `lastGood` is read
from `previous`, so per-lane last-good and the server's last-good snapshot are **one copy**.
Lanes are built by iterating `registry`, never by constructing keys by hand.

**`StateWriter`** - a typed module plus a thin CLI (`starcar car set c2 rolling --sha
abc1234`, `starcar car set c2 held`, `starcar gate set plan-review red`). The module holds
the logic and is unit-tested; the CLI shell is **smoke-tested, meaning an automated
end-to-end run against a temp directory** (this writer has no external service, so
`board.ps1`'s policy - do not unit-test a wrapper whose only untested part is a live API -
transfers only partly, and the automatable half is automated). The writer never commits; a
human does.

Three binding properties: one shared schema module; **atomic write (temp, then rename)**;
and validation on write does not retire validation on read.

**Contingency, stated before dispatch so a car does not honest-stop into a wall:** if
`rename` over an open destination fails on Windows with `EPERM`/`EBUSY`, plan B is
bounded retry-with-backoff on the *read* side, not abandoning atomic writes. Rev 2 made
this a pass/fail test with nowhere to go.

**`asOf` provenance** is the `writtenAt` field inside the state file, stamped by the
writer - never filesystem mtime, because `git checkout` and `git clone` rewrite mtime to
now, making a three-day-old fixture read as perfectly fresh. `snapshot.asOf` is the most
recent successful poll across adapters, `null` only if none has ever succeeded.

Guards, red-first: a **future-dated `writtenAt` is `failed`** with code
`timestamp-in-future`, never `fresh` (hand-editing is anticipated, and a future timestamp
yields a negative age that never crosses the threshold, pinning a lane to `fresh`
forever); and a **clock step backwards** must not produce a negative or wild age -
negative resolves to `failed`, never silently to zero.

**Fixtures.** `fixtures/demo-state.json` is curated, git-tracked, owned by car 2, and used
by tests and demo mode. The live state file is separate and also tracked (showcase
thesis), stated as a decision rather than left to accident.

**`demoMode` no longer suppresses anything.** Rev 2 had it suppress the staleness alarm so
a checked-in fixture would not read as broken. That was an override of a truth surface,
and `gating-matrix.md:23` - the template's single worked example, landed by this very
train - already ruled on it: *staleness banner, suppressed when: never (truth surface),
DELIBERATE, no override.* The rule was written before the question was asked. **Repair:**
demo mode stamps `writtenAt` at fixture-load time, so the demo data is genuinely fresh and
exercises the real freshness path instead of bypassing it. The persistent DEMO banner
stays - it is an additional honest disclosure, not an override. A deliberately-stale demo,
if ever wanted, is a second fixture.

## 9. Error handling

`BoardCondition` carries board-level faults in chrome, distinct from lane state:

```ts
type BoardCondition = { code: string; detail: string; register: Register }
```

| Failure | Behavior | Law |
|---|---|---|
| Adapter throws | Caught at the boundary → `failed`, coded reason → lane resolves `needs-attention` per §5.6. | 4 |
| Malformed state file | `schema-violation` with detail. **No partial render.** | 1 |
| File missing/unreadable | `file-missing` / `file-unreadable`, OS reason in detail. | 1, 4 |
| `writtenAt` in the future | `timestamp-in-future`. Not `fresh`. | 1 |
| Data aged past threshold | `stale`, shown, marked, `ageBucketMs` rendered. Register `needs-attention`. | 5 |
| State file has unknown keys | Preserved; `BoardCondition` "N unrecognised fields". | 4 |
| **Lane registry missing/malformed** | `BoardCondition` `registry-unreadable`, `needs-attention`, **and NO lanes are rendered as though they were the whole truth.** An empty yard is `constitution.md:36` verbatim: a missing lane reading as "no trains" is a lie of omission. | 4 |
| **Vocabulary file missing/malformed** | `BoardCondition` `vocabulary-unreadable`, `needs-attention`. Lanes render their raw position id with a board-level notice. **The detector does NOT fire per-lane** - one config fault must not be misreported as N discoveries of new shop vocabulary. | 1, 4, 5 |
| **One bad row inside a vocabulary** (e.g. `register: "critical"`) | That row is quarantined and reported as a `BoardCondition`; the remaining rows load. Not fatal to the snapshot. | 4 |
| Unrecognised vocabulary value, vocabulary loaded OK | Detector fires: `needs-attention`, labelled `unrecognised position: '<id>'` (or car state / gate aspect) verbatim. **A discovery, not a bug.** | 1, 4 |
| SSE heartbeat missed twice | Chrome shows disconnected; last-good stays on screen **visibly marked**. | 1, 5 |
| Wire payload fails validation | Payload discarded; **the previous render stays, visibly marked**, plus a `BoardCondition`. Never a blank board. | 1 |
| Lane has no adapter | `not-applicable`; position speaks, freshness is silent. `nominal`. Not an alarm. | 3, 4 |

The distinction between the last two vocabulary rows is the fix for rev 2's cascade: **"the
vocabulary is broken" and "this value is unknown" are different faults and must not be
reported as each other.**

## 10. Test strategy

Red-first throughout.

- **Fixture corpus**: valid, malformed, missing, truncated, future-dated, unknown-position,
  unknown-car-state, unknown-keys, malformed-registry, malformed-vocabulary, bad-register-row.
- **Law 4 / completeness:** every registered lane appears in every snapshot, in every code
  path including pre-first-poll; plus the pinned lane-id set (§5.5 guard 2).
- **Composition matrix (§5.6):** the register resolution table is exhaustively tested -
  every position register x every freshness kind. The load-bearing case: **`live` +
  `failed` resolves `needs-attention`**, red against a position-only implementation.
- **`not-applicable` rendering:** a `dark` lane shows its position label and **no freshness
  line at all** - never "not yet read". Red against a naive always-render.
- **`never-polled`:** before the first poll, adapter-backed lanes report `never-polled` and
  `asOf` is null; adapter-less lanes report `not-applicable`.
- **Detector:** an unknown value renders `unrecognised <axis>: 'x'` verbatim, never coerced.
- **Cascade guard:** a malformed vocabulary produces ONE `BoardCondition`, not N detector
  firings.
- **Registry-unreadable:** produces a board fault, never an empty yard.
- **Staleness:** injected clock crosses `stalenessMs`; `fresh` → `stale`.
- **Age liveness:** while a lane is stale, `ageBucketMs` changes on the wire at least once
  per bucket; the client never computes age.
- **Atomicity:** spy the fs module; the destination is never passed to any write or
  truncate, and exactly one `rename(tmp, dest)` occurs. An in-place implementation calls
  `writeFile(dest)` and never `rename`, so it fails for its stated reason. Plus: `rename`
  over a destination **with an open read handle**, on Windows, because `EPERM`/`EBUSY` is
  the realistic failure of this strategy on this platform. Interleaving loops are
  non-gating soaks, never the red.
- **Single definition:** the ESLint rule, red against a second declaration.
- **Serialisation parity:** both endpoints emit byte-identical payloads.
- **Event name:** server writes what the client subscribes to.
- **Ordering:** a late first-paint fetch does not overwrite a newer streamed snapshot.
- **Heartbeat:** two missed heartbeats flip to disconnected while last-good stays marked.
- **Poll overlap:** a slow poll does not stack; an older result never overwrites a newer.

## 11. Contracts, documentation, and cars

**`docs/contracts/state-ledger.md`** - lifecycle events: server restart; adapter failure
window; client reconnect; state file replaced or truncated; poll overlap; pre-first-poll
window. Fields: `lastGoodSnapshot`, `lastPollAt`, `pollInFlight`, `seq`, timer handle,
`connectedClients`, lane-id set.

`connectedClients` **is** ledgered - "an implementation detail of the SSE layer" is
verbatim the argument that produced ninety-nine latent bugs in this template's ancestor.
A ledger's first entry sets its threshold forever; this one is set low.

Browser state is **in scope, bounded** (adopted ruling Q3): rendered snapshot, connection
status, last-applied `seq`. The bound is *state whose survival across a lifecycle event
changes what the user sees* - not every variable in the view. Transient render caches and
DOM handles are out.

**`docs/contracts/gating-matrix.md`** - five gated surfaces: staleness banner, disconnect
indicator, `failed` panel, unrecognised-value detector, board-condition chrome.

**Documentation.** Every car updates every document its change invalidates, in the same
commit; its reviewer treats a stale document as Major. Car 5 owns `README.md` and the
quickstart (`README.md:8-11` currently promises no code, no server, no quickstart - this
train falsifies that) and states "local-only, unauthenticated" there. Car 1 owns
`docs/setup.md`'s firing trigger rows and either lands or explicitly re-parks the two other
CI guards (#3 area-label check, #4 docs-review check). **The conductor lands each review
verdict in `docs/reviews/` as it happens**, which `README.md:20-21` promises and rev 2 did
not assign to anyone.

| Car | Scope | Notes |
|---|---|---|
| 1 | Toolchain, CI, scaffolding; `docs/setup.md` triggers | **First.** Not done when CI is green - done when someone has WATCHED it go red (fault-inject, observe, revert, put the run URL in the report). A green light wired to nothing is worse than no light. |
| 2 | `schema`, domain types, registries, vocabularies, `StateFileAdapter`, `SnapshotAssembler`, `fixtures/demo-state.json`, the ESLint single-definition rule | The lint rule lives here, not in car 1: its red requires a second declaration, which does not exist until this car. |
| 3 | `StateWriter` + CLI | After car 2. |
| 4 | `Server`, poll, SSE, heartbeat, ordering; **the state ledger**; gating matrix | The ledger lives here because all six ledgered fields are this car's state. Rev 2 assigned it to a car that owns a pure assembler and no state. |
| 5 | `View`, composition, detector, chrome; README + quickstart | After 2 and 4. |

Order: 1 → 2 → {3, 4} → 5. Cars 3 and 4 run in parallel; **car 4 owns the ledger file
outright** and car 3 appends nothing (it holds no long-lived state), which removes rev 2's
unowned shared-file hazard.

**Toolchain:** Node 22 LTS; TypeScript compiled by `tsc` to native ES modules served
directly, no bundler, so the browser imports the same emitted module the server does and
the type is physically shared rather than re-declared; one `tsconfig.json`; vitest with
jsdom; ESLint.

**Configuration:** host `127.0.0.1`, port `4600`, `pollMs` 1000, `heartbeatMs` 5000,
`stalenessMs` 15000, state path resolved from CWD. Flag and `STARCAR_*` env overrides read
once at startup. `statePathDisplay` is CWD-relative or home-collapsed rather than a raw
absolute path, because this repo publishes screenshots and an absolute path discloses the
operator's directory layout for no Law 5 benefit a relative one does not also deliver.

**Cost:** 5 cars + 5 reviewers + design/spec/plan with reviews ≈ **18-19 dispatches**,
model mix Opus throughout (adversarial gates and cross-boundary contracts; no cheap tier
on a founding contract), size class: **large**. Two REJECT rounds already spent are
included. The owner approved this figure before dispatch.

**Tracking:** cars 1, 3 and 4 are not `area:view` work. They need issues under
`area:tooling`, `area:adapters` and `area:server`, or a recorded conductor ruling. **This
must resolve before the plan**, not before the spec.

## 12. Out of scope

Git adapter. GitHub board adapter. Fuel adapter. Auth. Persistence beyond the state file.
Frontend framework. Theming. History or event log - `Yard` is a current-state snapshot and
a REJECT round is a counter. Multi-repo. Adapter-failure backoff (a local file poll does
not need it; recorded so a later reviewer knows it was considered).

**Law 2.** In v0 the dispatcher's override **is the StateWriter**: the human edits the
source of truth and the board renders what it says. The `held` car state (§4) makes the
law's own worked example expressible. A view-level override - marking a train held from
the browser, against the data - is deliberately deferred and is the natural second use of
the writer.

**Lane-to-train linking.** A lane under construction is a lane with a *train on it*, so
the board could render its own build-out with the machinery it renders everything else
with. Deferred: it couples the registry to yard state and there is no real train to link
to yet. `under-construction` ships as vocabulary now; the link comes when there is
something to point at.

## 13. Revision history

**Rev 1 → rev 2** closed 6 of 9 Majors (verified by round 2's closure table); 3 partial.
Rev 2's re-cut (§2's closed/open ruling) was assessed by its reviewer as "a real
correction I would not want reverted."

**Rev 2 → rev 3.** Round 2 returned 8 Majors and a root-cause note: six shared one class -
*the axes were specified and their composition was not.* §5.6 is that composition.

| Rev 2 finding | Disposition |
|---|---|
| MAJOR-1 position/freshness composition undefined; `never-polled` test unwritable | §5.6 Rules 1-2; `not-applicable` restored (§5.3); tests rewritten (§10). |
| MAJOR-2 register from position only, so a failed `live` lane renders calm | §5.6 Rule 1 - most-severe-wins, with the exhaustive matrix test. |
| MAJOR-3 registry/vocabulary load failure unhandled; detector cascades | §9, three new rows; "vocabulary broken" and "value unknown" separated. |
| MAJOR-4 substitute Law 4 guard not equivalent, and asserted to be | §5.5, three guards; the overstated claim removed. |
| MAJOR-5 domain payload undefined | §4 - `Yard`, `Train`, `Car`, `Gate`, plus car-state and gate-aspect vocabularies. |
| MAJOR-6 two owners for position, no precedence | D11 and §5.4 - registry is sole owner; the state file has no position field. |
| MAJOR-7 rendered age has no update path | §7 - quantised `ageBucketMs` included in change detection; server always issues the number. |
| MAJOR-8 `demoMode` suppresses a truth surface | §8 - suppression removed; fixture `writtenAt` stamped at load. |
| Minor-1 `asOf` aggregation | §5.7. |
| Minor-2 `seq` in change detection | §7 - excluded, assigned after. |
| Minor-3/4 ledger assigned to the wrong car; shared-file hazard | §11 - ledger is car 4's, owned outright. |
| Minor-5 lint rule cannot be red in car 1 | §11 - moved to car 2. |
| Minor-6 validator strictness | §6 - unknown keys preserved and disclosed. |
| Minor-7 wire-validation failure rendering | §9 - previous render stays, marked. |
| Minor-8 absolute path on the wire | §5.7, §11 - `statePathDisplay`. |
| Minor-9 sentence stops a hop short | §6 - declared from CLI argv. |
| Minor-10 cost line incomplete | §11 - count, model mix, size class. |
| Minor-11 fixture unowned | §11 - car 2. |
| Minor-12 no rename contingency | §8 - bounded read-side retry. |
| Minor-13 verdicts not in-repo | §11 - conductor lands each verdict in `docs/reviews/`. |
| Minor-14 other CI guards unaddressed | §11 - car 1 lands or re-parks #3 and #4. |
| Minor-15 "both validators" unenumerated | §6 - six, named. |
| Note-1 citation off by a line | Fixed - `constitution.md:54-55`. |
| Note-3 doubled single-definition guard | §6 - source scan pruned; ESLint kept. |
| Note-5 detector register tension unstated | §5.6 Rule 4. |
| Rulings Q1-Q5 | All adopted: three registers kept; vocabularies on every snapshot; browser state ledgered but bounded; `demoMode` ruled a breach and removed; car 1 first, with the watched-it-go-red condition. |

**A correction rev 3 owes on its own account.** Rev 2's §12 claimed rev 1's Minor-10 was
fixed - "now vocabulary, not enum" - when no such vocabulary existed anywhere in the
document. That was a false claim in a summary table, in a repo whose north star is
documentation honesty, written by the author being reviewed. It is fixed in substance by
§4, and recorded here rather than quietly corrected, because a closure table that can lie
is worse than no closure table.

## 14. Open questions for the design reviewer

1. `ageBucketMs` on the wire means the server emits roughly once a second while anything is
   stale. Is that the right trade against a client-computed age (Law 6 breach) or a coarser
   bucket that makes the number visibly laggy?
2. §5.6 Rule 1 takes the maximum severity across three axes. Is max the right operator, or
   does it hide a nominal-position lane's identity behind a transient data fault - e.g.
   should `under-construction` + `failed` read as construction or as failure?
3. `BoardCondition` is a new board-level channel. Is it earning its place, or should board
   faults be a synthetic lane so there is exactly one rendering path?
4. The state file forbids a `position` field (D11). Should the schema *reject* a state file
   carrying one, or preserve-and-disclose it like any other unknown key (§6)?
5. Five cars with an explicit order and one parallel pair. Is car 4 (server, SSE, ledger,
   gating matrix) too large now that it owns both contract documents?
