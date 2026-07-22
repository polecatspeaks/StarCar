# Design: v0 yard skeleton

Status: **DRAFT rev 2 - awaiting adversarial design review (round 2)**
Issue: #1 (`area:view`)
Date: 2026-07-21
Ladder rung: design (rung 1 of: design → spec → plan → cars)
History: rev 1 REJECTed, 9 Major / 14 Minor. See §12 for what changed and why.

## 1. What this train delivers

A running StarCar: a local server process that reads a conductor-maintained state file
and renders the yard live in a browser, with every declared lane present from the first
commit - whether or not it has data yet.

**The organising idea of rev 2:** a lane is a *socket with a declared position on a
build-out*, not a payload that is either present or absent. The socket exists before the
data does. Going live later is plugging in, not rebuilding.

## 2. The epistemic constraint that shapes everything below

We cannot enumerate the states this board needs, because **running the yard is what
generates them**. Rev 1 declared four lane states. Its adversarial review found a fifth.
The owner then found three more, and immediately split the third into three again. That
is not a sequence of near-misses converging on a correct list; it is evidence the list
does not stabilise before observation.

Law 7 already ruled on this and rev 1 disobeyed it: *"pluggable adapters, **no hardcoded
board schemas or label taxonomies**"* (`constitution.md:54`). Rev 1 hardcoded a label
taxonomy and then spent three rounds trying to get the hardcoded one right.

**The rule this design adopts: close what MECHANISM determines, open what the SHOP
names.**

- A poll has either never run, or last succeeded, or last failed. That set is closed by
  mechanism and provably complete, so it is a compile-time union.
- What a lane is *called* when it holds data it does not surface - `bagged`, `hooded`,
  `staged`, whatever the next shop says - is vocabulary. That set is open by nature, so it
  is **data**.

**And the unrecognised-value path is not an error path; it is the detector.** When the
board meets a position it does not know, it renders that fact loudly and by name. That is
Law 1 and Law 4 doing their jobs, and simultaneously it is the instrument that tells us we
have just observed a state we had not enumerated. You do not resolve an
observation-dependent state space by guessing harder. You build the detector and open the
box.

**Therefore v0's actual job is discovery.** It ships the minimum vocabulary we have
genuinely observed - not the maximum we can imagine - plus the path that surfaces the
rest. The board saying *"I do not recognise this"* in front of the owner is the design
working, not failing.

## 3. Decisions taken, with their reasons

| # | Decision | Reason |
|---|---|---|
| D1 | Live server + browser | The board is a wall display glanced at, not a page refreshed. Cost accepted: lifecycle, staleness and reconnect are first-class work now. |
| D2 | TypeScript on Node, **with runtime validation at every boundary** | One language lets the server and view share a type *declaration*. It does NOT make the wire safe - see §5.2. Rev 1's claim that it did was its central error. |
| D3 | Conductor state file is the first adapter | It is the only source that *knows* a REJECT happened; git records no verdicts, and inferring them would violate Law 6. |
| D4 | Every declared lane is present in every snapshot, in its declared position | Law 4. See §5.1 for how this is guarded now that lanes are a registry rather than fixed keys. |
| D5 | A writer for the state file ships in this train | Hand-editing JSON mid-train is hand-maintained state at a process boundary. §5.6. |
| D6 | The server polls by mtime; it does not `fs.watch` | Atomic rename swaps the inode, which `fs.watch` handles poorly - missed events or events on a stale handle, worse on Windows. |
| D7 | Data-staleness (server) and connection-loss (client) stay two separate truths, simultaneously displayable | They fail independently and live at different scopes: staleness is per-lane and comes from the assembler; disconnection is whole-board and belongs to the transport. Merging them is a category error before it is a design choice. |
| D8 | **Registers are closed; positions are open** | §2. The glance-language must be stable (Law 3) while the vocabulary must be pluggable (Law 7). |
| D9 | **SSE is chosen over browser-side polling of `/api/snapshot`** | Recorded as a rejected alternative because rev 1's review noted that browser polling would delete §5.3's entire problem set. SSE wins on the wall-board case: an idle yard costs nothing and a change appears without a round-trip. The price is the heartbeat, ordering and change-detection rules in §5.3, all of which are now specified rather than assumed. |
| D10 | **The toolchain car runs FIRST** | `CLAUDE.md`: *"verified means the pipeline that ships it went green."* Until CI exists, no car in this train can honestly claim verification. §10. |

## 4. The contract

### 4.1 Registers - CLOSED, and this is the only closed taxonomy in the system

```ts
type Register = 'nominal' | 'in-progress' | 'needs-attention'
```

The glance-language. Law 3 lives here: a dispatcher resolves the board in one pass, and a
visual vocabulary that anyone may extend decays into mush. Growing this set is a
constitution-level decision, not a config edit.

### 4.2 Positions - OPEN, shipped as data

```ts
type PositionDef = {
  id: string             // 'live' | 'bagged' | 'dark' | 'under-construction' | ...
  label: string          // what the board prints
  register: Register     // how it renders at a glance
  surfacesData: boolean  // does this lane show its payload while in this position?
}
```

Ships as a data file, loaded at startup, **and carried on the wire inside the snapshot**
so the view never hardcodes a vocabulary (Law 6: the source owns the facts; Law 7: no
hardcoded taxonomies).

v0 ships only positions we have actually observed:

| id | label | register | surfacesData |
|---|---|---|---|
| `live` | Live | `nominal` | true |
| `bagged` | Data held, not surfaced | `nominal` | false |
| `dark` | No equipment | `nominal` | false |
| `under-construction` | Being built | `in-progress` | false |

`bagged` is the railroad term for a signal that physically exists and is deliberately out
of service, hooded so crews know not to obey it. It is exactly the state rev 1 could not
express, and it is not a degradation - it is correct, declared and accurate.

**The detector:** a position id present in the state file or lane registry that resolves
to no `PositionDef` is rendered as `needs-attention`, labelled verbatim
`unrecognised position: '<id>'`. It is never silently coerced to a default, never hidden,
and never rendered as an error in the software. It is a discovery.

### 4.3 Freshness - CLOSED, because mechanism determines it

```ts
type Freshness<T> =
  | { kind: 'never-polled' }
  | { kind: 'fresh';  data: T; asOf: string }
  | { kind: 'stale';  data: T; asOf: string; ageMs: number }
  | { kind: 'failed'; reason: FailureReason; lastGood?: T; lastGoodAsOf?: string }

type FailureReason = { code: string; detail: string }
```

Provably complete: a poll has never run, or its last run succeeded (and the data is
current or aged), or its last run failed. `never-polled` is what rev 1's review found
missing, and `constitution.md:17` names it by hand: *"Unknown states render AS unknown,
honestly."*

`FailureReason` is structured rather than free prose so the view can render `file-missing`
differently from `schema-violation` without parsing English.

### 4.4 Lane and snapshot

```ts
type Lane = {
  id: string
  title: string
  position: string        // a PositionDef id - MAY be unrecognised
  freshness: Freshness<unknown>
}

type YardSnapshot = {
  seq: number             // monotonic, increments per emitted snapshot
  asOf: string | null     // null before the first poll completes
  config: {               // Law 5: the board knows and states its own parameters
    pollMs: number
    heartbeatMs: number
    stalenessMs: number
    statePath: string     // resolved ABSOLUTE path
    demoMode: boolean
  }
  positions: PositionDef[]
  lanes: Lane[]
}
```

### 4.5 The Law 4 / Law 7 trade, recorded explicitly

Rev 1 made `lanes` four required keys so that omitting one was a compile error. That was a
genuinely good guard and it is being **weakened on purpose**, because four fixed keys is a
hardcoded board schema and Law 7 forbids one by name.

Law 4 outranks Law 7, so this is only legitimate if Law 4 is still honoured by other
means. It is: lanes come from a **registry**, the assembler iterates the registry rather
than constructing keys by hand, and a red-first test asserts *every registered lane
appears in every snapshot, in every code path, including before the first poll*. Nothing
can be silently dropped; the guarantee simply moved from the compiler to a test.

Trade stated so a later reviewer does not have to reconstruct it: **we exchanged a
compile-time guarantee for pluggability, and bought back a mechanical runtime guard.** A
stranger can now add a fifth lane without editing a core type.

### 4.6 `Adapter<T>` - the seam

```ts
type AdapterResult<T> =
  | { ok: true;  data: T; asOf: string }
  | { ok: false; reason: FailureReason }

interface Adapter<T> {
  readonly name: string
  poll(): Promise<AdapterResult<T>>
}
```

An adapter never throws into the view, and its health is part of its return value rather
than a side channel - a lane cannot be rendered without carrying its own health, because
the type will not let you separate them.

## 5. Units

### 5.1 `schema` + registries

One module defining every type above, both validators, the SSE event-name constant, and
the single serialisation function. Imported by adapter, writer, server and view. The
single definition is the guard, and §7 makes it mechanical.

The **lane registry** and **position vocabulary** are data files loaded at startup. The
lane registry declares which lanes exist and each one's current position; it changes on
deploy, not at runtime. Two distinct fact domains, deliberately not merged:

- **Lane registry** - the product's build-out truth. Owned by the project.
- **State file** - yard events: trains, cars, gates. Owned by the conductor.

`Yard` (the state file's root type) carries `trains` and `gates` in v0. Gates are written,
stored, read and held - and the signals lane's position is `bagged`, which is the honest
statement that we hold gate data and do not yet surface it. Rev 1's contradiction (a
writer that wrote gates beside a lane declared adapter-less) dissolves rather than being
resolved by cutting a feature.

### 5.2 Wire safety - rev 1's central error, and its repair

Rev 1 claimed that sharing a TypeScript type across the server/browser boundary reduced
the sentence check to "confirm the type is genuinely shared." **That claim was wrong in
three independent ways**, and the repairs are binding requirements on this train:

1. **A duplicate type declaration is NOT a build failure.** TypeScript is structurally
   typed; a second, divergent `YardSnapshot` in the view compiles clean and emits no
   diagnostic, especially here where the value arrives from `JSON.parse` and is cast.
   Rev 1's "shared-type test" would have passed the moment it was written.
   **Repair:** an ESLint `no-restricted-syntax` rule banning declaration of these type
   names outside `src/schema.ts`, plus a source scan asserting each resolves to exactly
   one file. Both fail red against a two-definition codebase.
2. **`JSON.parse` is an unchecked cast.** A shared compile-time type constrains what the
   source code *claims*; it constrains nothing that crosses the wire. `ageMs: number`
   becomes `null` if it is ever `Infinity` or `NaN`; `lastGood?: T` loses the distinction
   between explicitly-cleared and absent, because `JSON.stringify` drops `undefined` keys.
   **Repair:** the view runs the shared runtime validator on every parsed payload.
   A divergence is a red test, not a silent render.
3. **The SSE event name is a hand-written string on both sides.** One character apart and
   the listener never fires, the socket stays **open**, and the client therefore reports
   itself connected while displaying the first paint forever - a permanent silent lie
   generated inside a fully type-checked pipeline.
   **Repair:** the event name is an exported constant in `schema`, imported by both sides,
   with a test asserting the server writes the constant the client subscribes to.

Additionally, `/api/snapshot` and `/api/stream` are two producers of one payload, which is
a hand-maintained mirror by another name. **Both serialise through one exported function,
with a test asserting byte-identical output for a fixed snapshot.**

The sentence check for this train is therefore NOT retired. Its hops are: assembler
output → serialise → HTTP body / SSE `data:` frame → `JSON.parse` → runtime validator →
render. Per-car reviewers trace all six.

### 5.3 `Server`

- `GET /` and static assets.
- `GET /api/snapshot` - current snapshot, for first paint.
- `GET /api/stream` - SSE.
- Poll loop at `pollMs`.

Three rules rev 1 left undefined, each of which produced a silent lie:

**Change detection.** Emit when the snapshot's canonical serialisation differs from the
last emitted one, **excluding `ageMs` and `asOf`** (which change every poll by
construction) and **including `freshness.kind`** (so the `fresh` → `stale` transition
emits even though no data changed). Rev 1's "emits only on change" had two readings: one
made the stated benefit fiction, the other meant a client that connected while fresh would
display `fresh` forever while the server knew otherwise - `constitution.md:42-43` verbatim.

**Heartbeat.** An SSE comment line every `heartbeatMs`. The client flips to disconnected
after two missed heartbeats. `heartbeatMs` travels in `snapshot.config` so the client does
not hardcode it. Without this, a half-open TCP connection (laptop sleep, wifi drop) leaves
`EventSource` in `readyState === OPEN` indefinitely with no error event, and the
disconnect row in §6 is unbacked in the commonest real disconnect mode.

**Ordering.** `seq` is monotonic. The client applies a snapshot only if `seq` exceeds the
last applied. Without it, a first-paint fetch that resolves after an early stream event
overwrites newer state with older and renders it as current.

**Poll concurrency.** A poll that outlasts the interval must not stack: `pollInFlight`
guards, and an overlapping tick is **skipped, not queued**. Two concurrent reads
completing out of order would let an older read overwrite the newer snapshot.

### 5.4 `SnapshotAssembler`

```ts
interface SnapshotAssembler {
  assemble(input: {
    results: Map<string, AdapterResult<unknown>>
    previous: YardSnapshot | null
    now: () => number          // injected clock - required for the staleness test
    stalenessMs: number
  }): YardSnapshot
}
```

Pure. Owns staleness classification and nothing else derives it - the view never computes
it (Law 6). `lastGood` is read from `previous`, so per-lane last-good and the server's
last-good snapshot are **one copy, not two**; rev 1 had two granularities of the same idea,
which Law 6 forbids by name.

The injected clock exists because rev 1 named a "fake clock" staleness test against a unit
with no interface block to inject one into.

### 5.5 `View`

Plain TypeScript and DOM, no framework, tested under jsdom.

Renders every lane in the snapshot, resolving `position` against the shipped `positions`
vocabulary, then composing three facts into one glance-state plus detail on demand:

- **position** (from the registry) - what this lane *is* on the build-out.
- **freshness** (from the adapter) - what its data is doing.
- **capability** (local to the view) - whether a renderer exists for this lane's payload.

Capability is deliberately **view-local and never on the wire**: the server has no business
asserting what a browser can render, and putting it on the wire would be a second copy of
something that can drift.

Register drives colour and weight. **Nothing renders in an alarm register unless something
is genuinely wrong** - an unbuilt lane is a plan, not a failure, and painting it red trains
the dispatcher to ignore red. Law 3.

Board chrome (not lane panels) carries: `asOf`, the connection indicator, the resolved
state path, the effective `pollMs`, and the DEMO banner when `demoMode` is set.
Simultaneous display of "this lane is stale" and "I am disconnected" is required, because
both can be true and they imply different actions - go look at the conductor, versus go
look at the server.

Law 3 obligation, called out because rev 1's review found this unit the thinnest-specified
with the largest surface: **a REJECT must be visible before any report is read, and a
stalled car must look stalled at a glance.** That is the law's own worked example and this
project's whole premise.

### 5.6 `StateWriter`

A typed module plus a thin CLI (`starcar car set c2 rolling --sha abc1234`,
`starcar gate set plan-review reject`). The module holds the logic and is unit-tested; the
CLI shell is smoke-tested, which here means **an automated end-to-end run against a temp
directory** (this project's writer has no external service, so `board.ps1:9-14`'s
precedent - do not unit-test a wrapper whose only untested part is a live API - transfers
only partly, and the automatable half is automated).

Three binding properties:

1. **Writer and reader import one schema module.** A writer with its own notion of the
   shape rebuilds the hand-maintained mirror D2 exists to eliminate.
2. **Writes are atomic: temp file, then rename.** Otherwise the poller reads a half-flushed
   file, fails validation, and paints "malformed state" over state that was fine - a
   confident falsehood on a status surface, intermittent, blaming the wrong component.
3. **Validation on write does not retire validation on read.** The file is hand-editable;
   a human, a bad merge or a rebase can produce garbage the writer never saw.

The writer stamps `writtenAt` inside the file (§5.7). The writer never commits; a human
does.

### 5.7 `asOf` provenance

`asOf` derives from a **`writtenAt` field inside the state file**, stamped by the writer -
never from filesystem mtime, because `git checkout` and `git clone` rewrite mtime to now,
which would make a three-day-old fixture read as perfectly fresh.

Guards, both red-first:

- **A future-dated `writtenAt` is `failed`**, code `timestamp-in-future`, not `fresh`.
  Rev 1 anticipated hand-editing, and a hand-typed future timestamp yields a negative age
  that never crosses the threshold, pinning a lane to `fresh` permanently.
- **A clock step backwards** must not produce a negative age or a wild one. Staleness is
  computed from the injected clock and asserted non-negative; negative resolves to
  `failed`, never silently to zero.

**The live state file and the demo fixture are two different artifacts.** As one file,
every `starcar car set` dirties the working tree mid-train, every car's diff carries board
noise, and the "demo data" is whatever the last train happened to leave behind rather than
a curated illustration. `fixtures/demo-state.json` is curated, git-tracked and used by
tests and demo mode; the live state file is git-tracked too (showcase thesis) and that is
a stated decision rather than an accident. Demo mode renders a persistent DEMO banner and
treats age as informational, so a checked-in fixture does not read as a broken board.

## 6. Error handling

| Failure | Behavior | Law |
|---|---|---|
| Adapter throws | Caught at the boundary → `failed` with a coded reason. Never a blank lane. | 4 |
| Malformed state file | Coded `schema-violation` with detail. **No partial render.** | 1 |
| File missing/unreadable | Coded `file-missing` / `file-unreadable`, OS reason in detail. | 1, 4 |
| `writtenAt` in the future | Coded `timestamp-in-future`. Not `fresh`. | 1 |
| Data aged past threshold | `stale` - shown, visibly marked, `ageMs` rendered numerically. | 5 |
| SSE heartbeat missed twice | Board chrome shows disconnected, last-good stays on screen **visibly marked**. | 1, 5 |
| Wire payload fails validation | Rejected, not rendered; board shows a validation failure in chrome. | 1 |
| Position id not in vocabulary | `needs-attention`, labelled `unrecognised position: '<id>'`. **A discovery, not a bug.** | 1, 4 |
| Lane has no adapter | Position `dark` or `bagged`, `nominal` register. Not an alarm. | 3, 4 |

## 7. Test strategy

Red-first throughout. Rev 1 named two tests that could not be written as described; both
are replaced with deterministically-red equivalents.

- **Fixture corpus** - valid, malformed, missing, truncated, future-dated, unknown-position.
- **Law 4 test:** every lane in the registry appears in every snapshot, in every code path,
  including before the first poll. Fails red against a hand-constructed lanes object.
- **Law 1 test:** malformed state file yields a `failed` lane and **no partial data**.
- **`never-polled` test:** `/api/snapshot` before the first poll returns every lane as
  `never-polled` with `asOf: null`, and the view renders "not yet read" - never empty,
  never `dark`.
- **Detector test:** an unknown position id renders `unrecognised position: 'x'` verbatim
  and never coerces to a default.
- **Staleness test:** injected clock crosses `stalenessMs`; `fresh` becomes `stale`.
  Writable because §5.4 gives the assembler a stated interface.
- **Atomicity test (replaces rev 1's race test):** spy the fs module; assert the
  destination path is never passed to any write or truncate call and that exactly one
  `rename(tmp, dest)` occurs. An in-place implementation calls `writeFile(dest)` and never
  `rename`, so this fails for exactly its stated reason before the fix. Plus: assert
  `rename` over the destination succeeds **while a read handle on the destination is
  open**, run on Windows, because `EPERM`/`EBUSY` is the realistic failure of this strategy
  on this repo's primary platform - not a partial read. Any interleaving loop is a
  non-gating soak, never the red.
- **Single-definition test (replaces rev 1's vacuous one):** ESLint rule plus source scan;
  both red against a two-definition codebase.
- **Serialisation parity test:** `/api/snapshot` and `/api/stream` emit byte-identical
  payloads for a fixed snapshot.
- **Event-name test:** the server writes the constant the client subscribes to.
- **Ordering test:** a late-resolving first-paint fetch does not overwrite a newer streamed
  snapshot.
- **Heartbeat test:** two missed heartbeats flip the client to disconnected while
  last-good data remains displayed and marked.
- **Poll-overlap test:** a slow poll does not stack, and an older result never overwrites a
  newer snapshot.

## 8. Contracts instantiated

Both templates, not one. Rev 1 instantiated the ledger and silently dropped the gating
matrix - in the train that lands the matrix template's own worked example row.

**`docs/contracts/state-ledger.md`.** Lifecycle events, enumerated for StarCar:

1. Server restart
2. Adapter failure window (poll fails, then recovers)
3. Client reconnect
4. State file replaced or truncated (atomic rename swaps the inode under a live reader)
5. **Poll overlap** (a poll outlasting its interval)
6. **Pre-first-poll window** (server up, no result yet)

Fields: `lastGoodSnapshot`, `lastPollAt`, `pollInFlight`, `seq`, the timer handle,
`connectedClients`.

**`connectedClients` is ledgered.** The argument that it is "an implementation detail of
the SSE layer" is verbatim the argument that produced ninety-nine latent bugs in this
template's ancestor project. A ledger's first entry sets its threshold forever; this one is
set low, on purpose.

Browser-side state (rendered snapshot, connection status, last applied `seq`) is **in
scope** for the ledger, because "client reconnect" is a listed lifecycle event and
verdicting it against no client-side rows would be theatre.

**`docs/contracts/gating-matrix.md`.** Four gated surfaces land here: the staleness
banner, the disconnect indicator, the `failed` panel, and the unrecognised-position
detector.

## 9. Documentation ownership

Rev 1 ran a fourteen-dispatch train with **zero documentation scope**, in a repo whose
north star ranks documentation equal to code. Repaired:

- **Every car** updates every document its change invalidates, in the same commit. Its
  reviewer treats a stale document as a Major.
- **Car 5 owns `README.md` and the quickstart**, because it makes the thing runnable and
  `README.md:8-11` currently promises "no code, no server, and no quickstart" - a promise
  this train falsifies.
- **Car 1 owns `docs/setup.md`'s two firing triggers**: the GitNexus index row (trigger:
  first code lands) and the CI row (trigger: first workflow need). Both fire on this train.
- The quickstart is gated at the PR by sentence check, per `CLAUDE.md`, tracing prose →
  command → code → observed behaviour. CI's quickstart runner (#6) remains parked.

## 10. Cars

| Car | Scope | Why here |
|---|---|---|
| 1 | Toolchain + CI + repo scaffolding; `docs/setup.md` trigger rows | **First, because "verified" means CI went green.** Until this lands, no later car can honestly claim verification. |
| 2 | `schema`, registries, position vocabulary, `StateFileAdapter`, `SnapshotAssembler` | Defines every contract the rest consume. Creates the state ledger. |
| 3 | `StateWriter` module + CLI | Depends on car 2's schema. |
| 4 | `Server`, poll loop, SSE, heartbeat, ordering; gating matrix | Depends on car 2. |
| 5 | `View`, register rendering, detector, chrome; README + quickstart | Depends on car 2 and car 4. |

Strictly ordered 1 → 2 → {3, 4} → 5. Each followed by its own adversarial reviewer.

**Toolchain (Car 1), stated because rev 1 omitted it entirely and it is the mechanism D2's
guarantee rides on:** Node 22 LTS; TypeScript compiled by `tsc` to native ES modules
served directly, no bundler, so the browser imports the same emitted module the server
imports and the type is physically shared rather than re-declared; one `tsconfig.json`;
vitest with the jsdom environment for view tests; ESLint for the single-definition rule.

**Configuration defaults** (Law 7 - a stranger must be able to run and tune this): host
`127.0.0.1`, port `4600`, `pollMs` 1000, `heartbeatMs` 5000, `stalenessMs` 15000, state
path resolved from CWD. Each overridable by flag and by `STARCAR_*` environment variable,
read once at startup. The effective values travel in `snapshot.config` and are rendered,
because a board that will not say what it is reading or how often is a Law 5 failure.

**Cost:** five cars and five reviewers, plus design, spec and plan with their reviews -
roughly 16 to 17 dispatches, up from rev 1's 14. The increase is one car (toolchain/CI)
and one REJECT round already spent. REJECT rounds are expected outcomes, not overruns.

**Tracking:** cars 1, 3 and 4 are not `area:view` work. Either they get their own issues
under `area:server`, `area:adapters` and `area:tooling`, or the conductor records a ruling
that this train runs against #1 alone. Flagged rather than assumed.

## 11. Explicitly out of scope

Git adapter. GitHub board adapter. Fuel/usage adapter. Auth. Persistence beyond the state
file. Any frontend framework. Theming. History or event log - `Yard` is a current-state
snapshot and a REJECT round is a counter, not an event stream. Multi-repo support.
Adapter-failure backoff (a local file poll at this scale does not need it; recorded so a
later reviewer knows it was considered).

**Law 2, explicitly.** "The Dispatcher Commands" is the second-ranked law and rev 1 neither
implemented nor deferred it. In v0 the dispatcher's override **is the StateWriter**: the
human edits the source of truth directly, and the board renders what the source says. A
view-level override - marking a train held from the browser, against the data - is
deliberately out of scope for v0 and is the natural second use of the writer.

**Lane-to-train linking.** The best idea this design produced is that a lane under
construction is a lane with a *train on it*, so the board could render its own build-out
using the machinery it renders everything else with. It is out of scope for v0: it couples
the lane registry to yard state, and we have no real train to link to yet. `under-construction`
ships as vocabulary now; the link comes when there is something to point at.

## 12. What changed from rev 1, and why

Rev 1 was REJECTed with nine Majors. The reviewer's citation audit found every
constitutional citation correct and the four-car split correctly sized; the defects were
in the contract and its completeness.

| Rev 1 finding | Disposition |
|---|---|
| MAJOR-1 no state for "server up, first poll pending" | **Dissolved** by §4.3 `never-polled`. Not a missing enum member - the enum was one axis where there were two. |
| MAJOR-2 sentence-check reduction unsound, shared-type test vacuous | **Fixed**, §5.2. Rev 1's central claim was wrong three ways; all three repaired with tests that can fail. |
| MAJOR-3 writer writes gates while signals declared adapter-less | **Dissolved** by `bagged`, §4.2. No feature cut. |
| MAJOR-4 SSE change detection, heartbeat, ordering | **Fixed**, §5.3, all three specified. |
| MAJOR-5 state inventory incomplete, `lastGood` ownership, ledger ownership | **Fixed**, §5.4 and §8. One copy of last-good, `pollInFlight` ledgered, ledger is car 2's deliverable and every later car appends. |
| MAJOR-6 `asOf` provenance unspecified | **Fixed**, §5.7, plus the fixture split from ruling Q2. |
| MAJOR-7 no documentation owner, gating matrix dropped, README goes false | **Fixed**, §8 and §9. |
| MAJOR-8 two unwritable tests | **Fixed**, §7, both replaced with deterministically-red equivalents, including the Windows rename-over-open-handle case rev 1 missed entirely. |
| MAJOR-9 no build/module/test-runner story | **Fixed**, §10. |
| Minor-1 wrong citation range | Fixed - the policy is at `board.ps1:9-14`, cited correctly in §5.6. |
| Minor-3 "zero inference means zero Law 1 risk" | Removed. It was false as a categorical: the assembler does derive, and MAJOR-1/4/6 were all Law 1 risks with no inference involved. |
| Minor-4 Law 2 absent | Addressed, §11. |
| Minor-6 Law 4 vs Law 7 trade unrecorded | Recorded, §4.5. |
| Minor-9 threshold never named | Named, §10. |
| Minor-10 car vocabulary not inherited | Now vocabulary, not enum - same open-set treatment as positions. |
| Minor-11 "smoke-tested" undefined | Defined, §5.6. |
| Minor-12 no host/port/URL | Defined, §10. |
| Minor-13/14 pre-existing stale docs | Swept in commit `e236252`, outside this design's scope. |
| Rulings Q1-Q5 | All adopted: §10 (interval), §5.7 + §10 (path and fixture split), §7 (one threshold, `ageMs` rendered), §8 (`connectedClients` ledgered), §5.5 (two truths, simultaneously displayable, disconnect in chrome). |

**The change rev 1's review did not ask for, and the reason for it:** §2. The reviewer
found a missing state; the owner then found three more and split one of those into three
again. The correct response was not a longer enum. It was to notice that a taxonomy which
grows on every observation should never have been compiled in - which Law 7 had already
ruled, before the question was asked.

## 13. Open questions for the design reviewer

1. Is `register` genuinely closed at three, or does `in-progress` collapse into `nominal`?
   A two-register board is simpler and Law 3 favours fewer distinctions.
2. Should `positions` travel on every snapshot, or be fetched once? Every snapshot is
   simpler and self-describing; it is also repeated bytes on every emit.
3. Is browser-side state genuinely ledger-worthy (§8), or is that the ledger over-reaching
   into a process it does not own?
4. `demoMode` suppresses the staleness alarm for a checked-in fixture. Is that a legitimate
   accommodation, or is it the first override of a truth surface and therefore a Law 1
   breach that should instead be solved by regenerating the fixture's `writtenAt`?
5. Car 1 (toolchain + CI) is ordered first so "verified" is achievable. Is that correct, or
   does CI on an empty repo test nothing and belong after car 2?
