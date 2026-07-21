# Design: v0 yard skeleton

Status: **DRAFT - awaiting adversarial design review**
Issue: #1 (`area:view`)
Date: 2026-07-21
Ladder rung: design (rung 1 of: design → spec → plan → cars)

## 1. What this train delivers

A running StarCar: a local server process that reads a conductor-maintained state file
and renders the yard live in a browser, with all four lanes present from the first
commit.

The trains lane is fed by real data. The signals, freight, and fuel lanes have no adapter
yet and render as loud "no adapter connected" panels. That is not a placeholder - it is
Law 4 (Nothing Silently Lost): *a missing lane reading as "no trains" is a lie of
omission*. An unimplemented lane must be visibly unimplemented.

This supersedes issue #1's stated route of "v0 static mock first to validate the layout."
The mock was proposed before the live-server decision. Because Law 4 forces honest
empty-states anyway, the walking skeleton shows the real layout in the real browser over
the real transport at no extra cost, and nothing is thrown away. **Amendment recorded
here; issue #1 to be commented with the same, per the living-document rule.**

## 2. Decisions taken, with their reasons

| # | Decision | Reason |
|---|---|---|
| D1 | Live server + browser, not static generation or a TUI | The board is a wall display the dispatcher glances at; refresh-to-see-truth defeats the purpose. Cost accepted: process lifecycle, staleness, and reconnect become first-class work now rather than later. |
| D2 | TypeScript on Node | One language across server and view, so the wire types are *shared*, not mirrored. A hand-maintained DTO mirror at a process boundary is the exact class the sentence-check scar was paid for; sharing the type deletes the class structurally rather than guarding it by review. |
| D3 | Conductor state file is the first adapter | It is the only source that *knows* a REJECT happened - git records no verdicts, and inferring them would violate Law 6 (the view never derives a verdict the source did not issue). Zero inference means zero Law 1 risk. The file doubles as the in-repo synthetic demo fixture Law 7 asks for. |
| D4 | Full-frame walking skeleton, one live lane, three honest-empty | Law 4 requires the empty lanes to render loudly regardless, so breadth is nearly free and layout risk retires immediately. |
| D5 | A writer for the state file ships in this train | Hand-editing JSON mid-train is hand-maintained state at a process boundary. See §5. |
| D6 | The server polls by mtime; it does not `fs.watch` | Atomic writes (§5) swap the inode on rename, which `fs.watch` handles poorly - missed events, or events against a stale handle, worse on Windows. Polling is the dumber mechanism and the correct one. |
| D7 | Server-side data-staleness and client-side connection-loss stay two separate truths | They fail independently. A board that merges them lies in exactly one of the two cases. Law 6: where sources disagree, show the disagreement. |

## 3. Units

Seven units. Each has one purpose, a stated interface, and is testable alone.

### 3.1 `Adapter<T>` - the contract

```ts
type AdapterResult<T> =
  | { ok: true;  data: T; asOf: string }
  | { ok: false; reason: string }

interface Adapter<T> {
  readonly name: string
  poll(): Promise<AdapterResult<T>>
}
```

An adapter **never throws into the view** and its health is part of its return value, not
a side channel. Law 5 makes adapter health a first-class surface; putting health in the
return type means a lane cannot be rendered without carrying its own health with it.

Depends on: nothing. This is the seam every future adapter (git, GitHub board, usage
meter) plugs into, and Law 7 (The Stranger) is satisfied or lost here.

### 3.2 `StateFileAdapter implements Adapter<Yard>`

Reads the state file, parses, validates against the shared schema, returns `Yard` or an
`ok: false` naming the validation failure in human-readable terms.

Depends on: the schema module (§3.7), the filesystem.

### 3.3 `SnapshotAssembler`

Combines adapter results into the object the wire carries and the view renders.

```ts
type LaneState<T> =
  | { kind: 'ok';         data: T; asOf: string }
  | { kind: 'stale';      data: T; asOf: string; ageMs: number }
  | { kind: 'failed';     reason: string; lastGood?: T; lastGoodAsOf?: string }
  | { kind: 'no-adapter' }

type YardSnapshot = {
  asOf: string
  lanes: {
    trains:  LaneState<Train[]>
    signals: LaneState<Gate[]>
    freight: LaneState<Ticket[]>
    fuel:    LaneState<Fuel>
  }
}
```

`lanes` has four **required** keys and every value is a discriminated union. There is no
way to express "this lane is absent" and no way to hand back a bare array. **Law 4
becomes a type error rather than a review rule** - the Healing Loop's step 2 prefers a
structural impossibility over a guard someone must remember.

Staleness classification lives here and nowhere else: the assembler owns the threshold
and decides `ok` vs `stale`. The view never computes it (Law 6).

Depends on: adapters.

### 3.4 `Server`

- `GET /` and static assets - the view.
- `GET /api/snapshot` - the current `YardSnapshot`, for first paint.
- `GET /api/stream` - SSE; emits a snapshot event when the snapshot changes.
- Poll loop on a fixed interval (D6). Emits only on change, so an idle yard is silent.

Holds the only long-lived mutable state in the system: `lastGoodSnapshot`, `lastPollAt`,
`connectedClients`. See §7.

Depends on: the assembler.

### 3.5 `View`

Plain TypeScript and DOM. No framework. `render(snapshot) → DOM`, a pure function of the
snapshot, so it tests under jsdom without a browser. Renders four lanes always, each
according to its `kind`. Displays the `asOf` stamp permanently (Law 5: freshness is
always visible).

Depends on: the shared snapshot type. Nothing else.

### 3.6 `StateWriter`

A typed module plus a thin CLI wrapper (`starcar car set c2 rolling --sha abc1234`,
`starcar gate set plan-review reject`). The module holds the logic and is unit-tested;
the CLI shell is smoke-tested and documented. That split is not invented for this train -
`scripts/board.ps1:29-39` already set it as this repo's policy for command-line wrappers,
and two pieces of tooling following one policy beats two policies.

Three properties, each load-bearing:

1. **Writer and reader import the same schema module.** A writer with its own notion of
   the shape would rebuild the hand-maintained mirror that D2 exists to eliminate -
   writing the scar back in while claiming to have avoided it.
2. **Writes are atomic: write temp, then rename.** Without this the poller eventually
   reads a half-flushed file, fails validation, and paints "malformed state" over a state
   that was fine. That is a confident falsehood on a status surface, which Law 1 names as
   the worst defect this project can ship - and it would be intermittent and would blame
   the wrong component.
3. **Validation on write does not retire validation on read.** The state file is
   git-tracked and hand-editable; a human, a bad merge, or a rebase can produce garbage
   the writer never saw. Both sides validate.

Depends on: the schema module.

### 3.7 `schema`

One module defining `Yard`, `Train`, `Car`, `Gate`, and their validators. Imported by the
adapter, the writer, and (as types) the view. The single definition is the guard.

`Yard` is a **current-state snapshot, not an event log.** A car that has been rejected
twice carries `rejectRounds: 2`, not a history of two rejection events. History is out of
scope for this train (§8).

## 4. Data flow

```
                        +-- GET /api/snapshot ---> View --> DOM
state.json --poll--> StateFileAdapter --> SnapshotAssembler --+
     ^                                                        +-- SSE /api/stream ----> View --> DOM
     |
StateWriter (atomic: temp file, then rename)
```

One boundary crossing in this system - the server-to-browser hop - and it carries
`YardSnapshot`. Because D2 shares the type across that hop rather than mirroring it, the
sentence check for this train reduces to confirming the shared type is genuinely shared
(one definition, imported both sides) rather than tracing nine fields through sixteen
files. **That is the point of D2, and the design review should verify it holds.**

## 5. Error handling

| Failure | Behavior | Law |
|---|---|---|
| Adapter throws | Caught at the boundary → `{kind:'failed', reason}` → red panel showing the reason. Never a blank lane. | 4 |
| Malformed state file | Validation error text on the lane. **No partial render** - a half-parsed yard is unbacked. | 1 |
| File missing or unreadable | `failed` with the OS reason verbatim. | 1, 4 |
| Poll succeeds but data is old | `stale` - data still shown, visibly marked, with age. | 5 |
| SSE disconnects | Client shows "disconnected, last good as-of X". Last-good data **stays on screen, visibly marked** - blanking the board would discard truth we still hold, but showing it unmarked would be a lie. | 1, 5 |
| A lane has no adapter | `no-adapter` panel, loud. | 4 |

## 6. Test strategy

Every behavior change red-first: write the failing test, RUN it, confirm it fails for the
stated reason, then green.

- **Fixture corpus** of state files - valid, malformed, missing, partial, and one written
  mid-flush - drives the adapter tests. The corpus is the demo data (D3).
- **The Law 4 test:** a lane with no adapter renders `no-adapter`, never empty. This is
  the load-bearing one; it is the mechanical form of the constitution's fourth law.
- **The Law 1 test:** a malformed state file produces a `failed` lane and **no partial
  train list**.
- **Staleness test:** fake clock, age crosses the threshold, `ok` becomes `stale`.
- **Atomicity test:** interleave a write with a poll; the poller never observes a partial
  file.
- **Shared-type test:** the view imports the snapshot type from the same module the
  server does. A duplicate definition is a build failure, not a review finding.

CLI wrappers are smoke-tested and documented rather than unit-tested, per §3.6.

## 7. State ledger

This train lands the first mutable service state, so `docs/contracts/state-ledger.md` is
created from its template **in the same commit as the code that creates the state**.

StarCar's lifecycle events, enumerated here for the first time:

1. **Server restart**
2. **Adapter failure window** (poll fails, then recovers)
3. **Client reconnect** (SSE drops and re-establishes)
4. **State file replaced or truncated** (the atomic rename of §5 swaps the inode under a
   live reader - a real mechanism, not a hypothetical)

Fields to verdict against all four: `lastGoodSnapshot`, `lastPollAt`, `connectedClients`.
Each row cites red-first lifecycle tests. A row without tests is `LATENT_BUG` until
proven otherwise.

## 8. Explicitly out of scope

Git adapter. GitHub board adapter. Fuel/usage adapter. Auth. Persistence beyond the state
file. Any frontend framework. Theming beyond one legible look. History or event log
(§3.7). Multi-repo or multi-yard support.

## 9. Cars

| Car | Scope |
|---|---|
| A | `schema` + `StateFileAdapter` + `SnapshotAssembler` |
| B | `StateWriter` module + CLI |
| C | `Server`, poll loop, SSE, state ledger instantiation |
| D | `View`, staleness rendering, honest-empty panels |

Each followed by its own adversarial sentence-check reviewer. Full ladder approved by the
owner: design → design review → spec → spec review → plan → plan review → four cars with
four reviewers. Roughly 14 dispatches, REJECT rounds excluded (a REJECT adds a round and
is an expected, successful outcome).

## 10. Open questions for the design reviewer

Named here rather than hidden, because a design review that only confirms the author's
confidence is a spelling check.

1. **Is the poll interval a config value or a constant?** Not decided. A constant is
   simpler; a config value is a stranger-deployment concern (Law 7).
2. **Where does the state file live by default,** and is its path configurable? Affects
   Law 7 directly.
3. **Does `stale` need a second threshold** (stale vs *very* stale) or does one suffice?
4. **Is `connectedClients` ledger-worthy state or an implementation detail** of the SSE
   layer? Argued both ways; the reviewer should rule.
5. **Does the view need to distinguish "server says stale" from "I am disconnected"
   visually,** or is one degraded treatment enough? D7 keeps them separate in the data;
   whether they must be separate in the pixels is unresolved.
