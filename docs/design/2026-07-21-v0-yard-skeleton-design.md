# Design: v0 yard skeleton

Status: Open
State: **rev 4 - the harness re-cut** - awaiting design review round 3
Issue: #1 (`area:view`)
Date: 2026-07-21 (rev 3: 2026-07-22; rev 4: 2026-07-23)
Ladder rung: design (rung 1 of: design → spec → plan → cars)
History: rev 1 REJECT (9 Major), rev 2 REJECT (8 Major), rev 3 PARKED UNREVIEWED
(superseded by the harness ruling before its round dispatched). See §13.

> **What rev 4 is.** Rev 3 was parked when the owner ruled the dispatch harness core
> product: every dispatch emits a structured artifact, and the yard adapter reads those
> artifacts rather than a hand-maintained state file. The harness has since shipped
> through the full ladder and is merged to `main` (PR #18, `1246f87`) - the store is
> real, self-recording, hash-verified, and CI-gated. Rev 4 rewrites this design against
> that contract, plus three owner rulings made at this rung's opening (2026-07-23):
> **Go** for the server half (#14), **train identity as conductor-declared intent
> records** in the store, and the walking-skeleton frame reaffirmed.
>
> **Inherited-risk disclosure (Law 1):** rev 3 was never reviewed. Sections carried
> forward from it - the lane contract (§5.2-5.6 shapes), wire-safety reasoning, server
> rules - get their FIRST adversarial review in this round. Carried is not cleared.

## §0 - Instrument check

**Answer: BOTH.** The behavioural half - which component owns what, how lanes compose,
how failures surface - is prose, reviewable by reading, and is this document. The
precision half is FOUR format contracts, and prose cannot hold them; each is a pointer
to an executable artifact (existing or to be produced at the spec rung, red-first):

| Format contract | Executable owner | Status |
|---|---|---|
| Store record (fields, types, identity) | `schema/starcar-artifact.schema.json` + conformance vectors | **EXISTS** - harness #7, gated in CI |
| Fold semantics (precedence, supersession, latest-`at`, overdue) | the detector conformance vectors (`scripts/tests/Detector.Tests.ps1` cases) | **EXISTS** - Car 2 of #7; rev 4 ports the implementation, the vectors stay the contract |
| Train manifest (the intent-record payload) | schema addition + vectors, spec rung | TO PRODUCE |
| Wire snapshot (`YardSnapshot` + vocabularies) | a JSON Schema file + vectors, spec rung | TO PRODUCE |

This document DESCRIBES those contracts and DEFINES none of them. A reviewer who finds a
canonicalisation rule, a field list, or an ordering rule specified only in this prose has
found a defect (the harness design's four-round scar, `docs/templates/design-doc.md` §0).

## §1 - Constraints (before the mechanism)

| Source | What it forbids here | How this design satisfies it |
|---|---|---|
| Law 1 (`constitution.md:17`) - "Unknown states render AS unknown, honestly" | A board that guesses: an unrecognised vocabulary value coerced to a known one; a lane with no adapter claiming "not yet read"; dev-lag presented as live | §5.6 Rule 2/4 carried; the detector renders unknowns by name; the snapshot carries `asOf` provenance |
| Law 2 (`constitution.md:21-23`) - "never resists an override"; worked example: "if a dispatcher marks a train held, the board renders held" | A board the dispatcher cannot override without editing code | §5.5: the override IS a store write - an `intent` record (`held`), rendered because the store is the source of truth. No view-side override in v0 (§7) |
| Law 3 - the board resolves in one glance | An open-ended visual vocabulary | §5.2 carried: `Register` is the ONLY closed taxonomy, three members, growth is constitution-level |
| Law 4 (`constitution.md:32-36`) - "never silently dropped"; an empty yard where lanes should be is a lie of omission | Losing store data the view does not understand; hiding dispatches that belong to no train; `encoding/json`'s default silent field drop (**observed**: FACT1, `docs/probes/2026-07-23-go-substrate-probe-results.md`) | §5.4 double-decode preserve-and-disclose (FACT3); §5.3 the yard-inventory lane for unassigned dispatches; §5.6 completeness guards carried |
| Law 5 - freshness always visible; "a stale board that looks live is the disease" | Rendering store data without its age; client-computed age | §5.6 Rule 3 carried: age is server-issued (`ageBucketMs`); staleness and disconnect are separate truths (D7) |
| Law 6 (`constitution.md:48-49`) - "never maintains a second copy of anything that can drift" | A second fold implementation with its own semantics; a wire type declared twice; contract text in two owners | §4 D18: the conformance VECTORS own fold semantics, implementations conform (the pwsh detector becomes the cross-verifier, not a second authority); §5.4 the wire contract is schema-owned, both sides validate |
| Law 7 (`constitution.md:54-55`) - "pluggable adapters, no hardcoded board schemas or label taxonomies" | Hardcoding this shop's kinds/outcomes/positions into the view; a board only this repo can use | §5.2 carried: open vocabularies as data on the wire; the store adapter is one adapter behind a seam (§5.3) |
| Healing Loop - "validated facts must land as tests or gates, never only prose" | Specifying the four format contracts in this document | §0's split; every probe fact cited is landed at `docs/probes/2026-07-23-go-substrate-probe-results.md` with a pin-as-tests trigger |
| `docs/contracts/gating-matrix.md` (staleness row) - a truth surface is "never suppressed, DELIBERATE, no override" | Any demo/config mode that mutes staleness, disconnect, or the detector | §5.6 carried (rev 3 §8 already removed `demoMode` suppression); no new suppression paths introduced |
| Ancestor scar **#552** (ported 2026-07-23, sibling's answer, in-session) - a status board derives status from the watched thing's OWN counters, never a proxy | Any status derived from anything but the store's records | §5.3: the store is the SOLE adapter; liveness comes only from the fold; the manifest contributes MEMBERSHIP, never status |
| Ancestor scar **#557** - render the source's own verdict, never re-infer it from a state diff | The board concluding "that was a REJECT" by diffing snapshots | §5.5: `outcome` is rendered verbatim from `returned` records; roles come from the manifest's declaration, never inferred from behaviour |
| Ancestor scar **#559** - a status channel invisible to the operator's senses is no channel | A board nobody can glance at | D1 carried (live wall display); push-notification is a named future (§7), not silently absent |
| Ancestor rule **honest-unreachable** - "unreachable - data unavailable", never a stale cached board presented as live | Last-good rendered without its provenance | §5.6/§6 carried: `failed` keeps `lastGood` VISIBLY MARKED with its age; disconnect flips chrome |
| `schema/index-format.md` - `at` is a VERBATIM string for integrity purposes (M-A4-1, three recurrences) | The board re-serialising a record's `at` | §5.4: records' `at` strings pass through untouched; sorting uses parsed instants (FACT5/6 observed Go behaviour; the discipline binds regardless) |
| Owner ruling #14 (issue comment, 2026-07-23) | Relitigating the server language | §4 D12: Go. Contradictions recorded in the ruling |
| Owner ruling #20 + merge north star | Asserting board freshness anywhere but the assertion moment | §8: the board's own derived artifacts (if any are ever committed) inherit the #20 posture; v0 commits none |
| Model topology (owner decision, 2026-07-22) | Silently changing the model mix | §9: cars Sonnet, gates Opus. Rev 3's "Opus throughout" line is SUPERSEDED by the ratified topology, stated here rather than silently |

## §2 - Premises (what no constraint forced)

| Premise | If false |
|---|---|
| P1. The store is sufficient truth for v0's live lanes (dispatch liveness + gate verdicts). No second live source is needed. | A second adapter enters, and with it Law 6's precedence-plus-disagreement obligations rev 3 §5.4 deliberately avoided. Most of §5.3 survives; the assembler grows |
| P2. The conductor writes manifests reliably enough that orphan dispatches are the exception. | The board becomes mostly yard-inventory. Still honest (Law 4 renders orphans loudly) - degraded, not lying. This premise is SELF-MEASURING: the orphan count is on the board |
| P3. One repo, one yard, the server reads the LOCAL CHECKOUT's `artifacts/` directory. | Remote/multi-repo yards need a fetch layer; the adapter seam (§5.3) is where it would land. Out of scope with trigger (§7) |
| P4. The view stays framework-free (vanilla JS + `EventSource`), no build step for the browser half. | A bundler/toolchain enters Car 5; nothing upstream changes. Chosen for reviewability: the binding constraint is review attention |
| P5. A zero-Go shop can ship sound Go through the gates (owner ruling #14's premise, restated so it can be attacked). | The showcase records where the institution failed to compensate - which is itself the product. The design mitigates: probes before claims, vectors as contracts, out-of-family review reads Go natively |
| P6. Producer latency (~11-12s, #15) is an acceptable bound on "live" for v0. | "Live" needs re-definition or the producer needs the #15 work pulled forward. The board renders `asOf` honestly either way - latency is visible, not hidden |

## §2c - Probe list (what the desk cannot prove)

Nine facts are already OBSERVED and landed: `docs/probes/2026-07-23-go-substrate-probe-results.md`
(FACT1-9: silent field drop, DisallowUnknownFields shape, RawMessage preservation, number
precision, `time.Time` verbatim round-trip, offset-instant equality, marshal determinism,
`http.Flusher`, incremental SSE). Still unprovable from the desk:

| Claim | Why unverifiable here | What settles it |
|---|---|---|
| CI runners provide/accept Go (version, `actions/setup-go`) | No CI run of Go exists in this repo | Car 1's first CI run IS the probe |
| Browser `EventSource` behaviour against the Go server (heartbeat timing, half-open detection) | No server exists to point a browser at | The walking skeleton's first live serve; rev 3 §7's heartbeat rules carry as design until observed |
| A Go JSON-Schema validator library conforms to draft-2020-12 (the store schema's dialect, incl. `if/then`) | Library conformance is an empirical claim | BLOCKING TEST at the plan rung: candidate library validates the existing store schema + vectors, observed, before any car depends on it. Negative branch: the Go side validates structurally (typed decode + required-field checks) and full schema validation stays CI-side (pwsh `Test-Json`, already gated) - degraded but honest, recorded as a deviation |
| Cross-compile single-binary claim (GOOS matrix) | Not attempted | Car 1: one build per target, recorded |
| Fold-port equivalence at scale (store of 10x records) | Store holds 61 records today | Non-gating soak at Car 3; the vectors gate correctness, this probes performance only |

## §3 - The problem

The founding epic (#1): render an agentic dev pipeline the way a dispatcher watches a
rail yard. Two days of groundwork built the instruments the board was always supposed to
read - a self-recording dispatch store with hash-verified records, landed verdicts, and
CI gates. What is missing is the window: nothing renders the store, so the yard's state
lives in the conductor's context and the owner's trust. The owner's frame (2026-07-23):
the store is the single source of truth, the Go binary is the one reader, the browser is
the window into it.

## §4 - Decisions

Carried decisions keep rev 3 numbers; new ones continue the sequence. The last column is
load-bearing (template §4).

| # | Decision | Reason | Driven by |
|---|---|---|---|
| D1 | Live server + browser wall display | Glanced at, not refreshed | #559; Law 3 |
| D4 | Every declared lane present in every snapshot | A missing lane is a lie of omission | Law 4 |
| D7 | Data-staleness (per-lane) and connection-loss (whole-board) are separate, simultaneously displayable truths | They fail independently, imply different actions | Law 5; honest-unreachable |
| D8 | Registers closed; every other taxonomy open, shipped as data | Running the yard generates states we cannot enumerate | Law 7; Law 3 (rev 3 §2's closed/open rule) |
| D9 | SSE over browser polling | Wall-board case; **now proven trivial in Go stdlib** | FACT8/9; D1 |
| D10 | Toolchain + CI car runs FIRST | "Verified means the pipeline that ships it went green" | Verification honesty |
| D11 | The lane registry is the sole owner of a lane's `position` | Two owners need precedence + disagreement rendering; one owner needs neither | Law 6 |
| **D12** | **Go server; browser JS view** | Owner ruling: strongest test of institution-over-fluency; single static binary; SRE fit. Contradictions recorded on #14 | Ruling #14; P5 |
| **D13** | **The artifact store is the SOLE adapter** (supersedes D3: conductor state file) | The store is the pipeline's own instrument - the only #552-compliant source. It records what rev 3's state file existed to hand-record | #552; the harness ruling that parked rev 3 |
| **D14** | **No StateWriter** (supersedes D5). Dispatcher overrides are `intent` records written to the store | Law 2's override renders because the source of truth says so - one write path, one store, provenance for free | Law 2; Law 6; #552 |
| **D15** | **The wire contract is owned by a JSON Schema file**; Go structs and the browser validator both conform to it (supersedes D2's shared-TS-module repair) | Cross-language seam: no module can be physically shared. The schema-as-constructed-header pattern is already landed practice in this repo | Law 6; NO HEADERS HERE |
| **D16** | **Train identity = conductor-declared manifest, as `intent` records in the store.** Membership from the manifest; status ONLY from the fold | The ban is on hand-maintained COPIES, not hand-declared ORIGINALS: train composition is born in the conductor's ruling on tickets and exists nowhere upstream to copy. A stale manifest SHOWS (orphan cars on the board); a stale status file LIED | Owner ruling 2026-07-23; #552; Law 4 |
| **D17** | **Record reads are double-decoded**: typed struct + `map[string]json.RawMessage`; key-set diff → unknown fields preserved and disclosed as a board condition | Go's default silently drops unknown fields (FACT1, observed); `DisallowUnknownFields` blanks the board over harmless additions (FACT2) - reject-not-disclose, the Law 1 harm | Law 4; Law 1; FACT1/2/3 |
| **D18** | **The fold is ported to Go; the existing conformance vectors REMAIN the contract; the pwsh detector remains as CI cross-verifier** | Two implementations, ONE authority: the vectors. Divergence = a red naming the divergent case. Retiring the pwsh detector is a separate later decision (§10 Q1) | Law 6; Healing Loop |
| **D19** | View is framework-free vanilla JS + `EventSource`, no build step | Review attention is the binding constraint; every dependency line is a reviewed line | P4; cost discipline |

## §5 - Mechanism

### 5.1 The shape

```
artifacts/**/*.json  --(poll)-->  StoreAdapter  -->  Fold (Go port, vector-governed)
                                        |                   |
                                   raw records         dispatch liveness
                                        |                   |
                                        +--> Assembler <----+---- manifests (intent records)
                                                |
                                          YardSnapshot  (schema-owned wire contract)
                                                |
                                   GET /api/snapshot   GET /api/stream (SSE)
                                                |
                                        browser view (validates, composes, renders)
```

One process (the Go binary), stateless-restartable by construction: everything it serves
is derived from the store on poll; killing and restarting it loses nothing (the owner's
frame - truth in the store, not in the binary).

### 5.2 The lane contract - CARRIED from rev 3, first review this round

Carried verbatim in substance; restated compactly. Full shapes in rev 3's text (git
history) and to be pinned by the wire schema at spec rung:

- **Registers** (`nominal | in-progress | needs-attention`) - the ONLY closed taxonomy.
- **Positions** (`live | bagged | dark | under-construction`) - open, data, registry-owned (D11).
- **Freshness** - closed by mechanism: `not-applicable | never-polled | fresh | stale | failed`,
  with `lastGood` carried on `failed`.
- **Composition (rev 3 §5.6)** - rendered register = most severe of position/freshness/
  capability; position speaks first, freshness second, `not-applicable` renders NO
  freshness line; age is always server-issued (`ageBucketMs`, quantised, in change
  detection); the detector's register is `needs-attention` deliberately.
- **Completeness guards (rev 3 §5.5)** - every registered lane in every snapshot on every
  code path; pinned lane-id set; lane count in chrome.

v0's lane registry: `dispatches` (live), `gates` (live), `trains` (live), `freight`
(dark - the ticket queue has no adapter yet), `fuel` (bagged - `cost` fields exist on
some records, held but not surfaced until #11's cost ledger work). Positions per D11 are
deploy-time registry truth.

### 5.3 The store adapter and the four derived surfaces

`StoreAdapter` scans `artifacts/**/*.json` under the configured repo checkout (P3) each
poll. Per record: double-decode (D17), schema-shape check, quarantine-with-disclosure on
failure (§6). It yields raw records; everything else is derivation, and each derivation
has exactly one owner:

| Surface | Derived by | From |
|---|---|---|
| Dispatch liveness (`dispatched`/`overdue`/`returned`/`presumed-lost`, supersession, elapsed-vs-budget) | the Fold (D18) | dispatch-kind records ONLY |
| Gates | direct render | `returned` records' `outcome` verbatim (#557); round/gate identity from the manifest's declaration (§5.5) |
| Trains (consists) | the Assembler | manifests (D16) joined to fold output by member subject |
| Yard inventory | the Assembler | fold output MINUS manifest members - every unassigned dispatch, rendered loudly (Law 4) |

The adapter seam (rev 3 §5.8's `Adapter` shape) survives: the store adapter is ONE
adapter behind it, health-in-return-value and all. Law 7's stranger gets the seam;
v0 ships one implementation of it.

### 5.4 Wire safety, re-derived for the cross-language seam

The rev 3 §6 hazard list was TS-shaped; the Go probe re-derived it (FACT rows):

1. **Unknown-field loss** is now a DEFAULT hazard, not an edge case (FACT1). D17 is the
   repair, and it applies to BOTH boundaries: store→server (records) and server→browser
   (the browser validator checks the snapshot against the wire schema).
2. **One wire contract, one owner** (D15): the JSON Schema file. Go structs conform
   (field order = declaration order, deterministic - FACT7); the browser validates every
   parsed payload against the same schema. The spec rung produces the schema + vectors;
   a hand-maintained mirror of it anywhere is a finding.
3. **`at` strings are verbatim pass-through.** Sorting/comparison uses parsed instants
   (FACT6). Go happens to round-trip offsets verbatim (FACT5) - the discipline does not
   rely on that kindness.
4. **The SSE event name** is a constant in the wire schema artifact, tested on both
   sides (rev 3 §6.3 carried - the one-character-apart failure mode is cross-language
   now, which makes the shared-constant test MORE load-bearing, not less).
5. **Serialisation parity**: `/api/snapshot` and `/api/stream` payloads are one
   marshal path with a byte-identity test (rev 3 §6 carried).

**The sentence, declared in full:** producer hook → record JSON → git checkout →
StoreAdapter double-decode → fold/assembler → one marshal path → HTTP body / SSE frame →
`JSON.parse` → wire-schema validation → compose → DOM. Per-car reviewers trace their
hops; the whole-branch gate reads the whole sentence.

### 5.5 The manifest (train identity) and the Law 2 path

The manifest is an `intent`-kind record (existing vocabulary) whose payload declares:
train id, title, ticket refs, and members - each member a dispatch subject plus a
conductor-declared **role** (`car` / `reviewer` / `gate:<name>` - open vocabulary, data).
Roles are DECLARED, never inferred from behaviour (#557: records do not carry "I am a
reviewer"; the manifest is where the conductor's knowledge becomes store truth).
Supersession: standard store semantics - a later manifest record for the same train
subject supersedes, superseded records stay visible to the fold (nothing is edited in
place; the store is append-only). Exact payload format: executable spec at the spec rung
(§0). **Status never flows from the manifest** (D16): a manifest naming a dead dispatch
changes nothing about the fold's verdict on it - the board would render a train with a
`presumed-lost` car, which is exactly the truth.

Law 2's override: `starcar` needs no writer subsystem - a `held` intent record IS the
override, written by the conductor (by hand or a two-line helper - NOT a v0 deliverable),
rendered because the store says so, superseded by a later intent when released. Rev 3's
"a hold that could be set and never released" scar is answered by supersession plus the
fold exposing the newest intent.

### 5.6 The server

Go stdlib only (FACT8/9): `GET /` static assets (embedded), `GET /api/snapshot`,
`GET /api/stream` (SSE). Poll loop at `pollMs`; change detection excluding `seq`/`asOf`,
including `freshness.kind` and `ageBucketMs`; `seq` assigned after comparison; heartbeat
comments at `heartbeatMs` with client flip-to-disconnected after two missed; monotonic
`seq` ordering client-side; `pollInFlight` skip-not-queue. All carried from rev 3 §7 -
those rules were the round-2 findings' repairs and survive unchanged in Go terms.
Configuration carried from rev 3 §11 (host 127.0.0.1, port 4600, `pollMs` 1000,
`heartbeatMs` 5000, `stalenessMs` 15000, `STARCAR_*` env overrides, `statePathDisplay`
home-collapsed - the absolute-path privacy rule is now also NORTH STAR normalisation law).

**Staleness semantics change with the store:** rev 3 read one file's `writtenAt`; the
store's freshness is per-poll success plus the NEWEST record `at` observed. `asOf` = last
successful store scan; a scan that fails (directory missing, unreadable) is `failed` with
`lastGood` - honest-unreachable, carried. The future-dated and backwards-clock guards
(rev 3 §8) carry, applied to record `at` values at fold time.

## §6 - Failure modes

| Failure | Behaviour | Law |
|---|---|---|
| Store directory missing/unreadable | Lane `failed`, coded reason, `lastGood` visibly marked; NEVER an empty yard rendered as truth | 1, 4; honest-unreachable |
| A record fails schema-shape validation | That RECORD quarantined + board condition naming the file; remaining records load. One bad record must not blank the board | 1, 4 |
| A record carries unknown fields | Preserved and disclosed (D17): board condition "record X carries N unrecognised fields" | 4; FACT1/3 |
| Unrecognised `kind`/`outcome`/`position`/role, vocabularies loaded | Detector fires: rendered loudly BY NAME, register `needs-attention` - a discovery, not a bug | 1, 7 |
| Vocabulary file missing/malformed | ONE board condition; detector does NOT fire per-record (rev 3's cascade fix, carried) | 1, 4, 5 |
| Manifest names a subject with no records | Member rendered `declared, not yet observed` - intent without observation is rendered as exactly that | 1 |
| Dispatch belongs to no manifest | Yard-inventory lane, loudly. The self-measure of P2 | 4 |
| Two manifests claim one dispatch | Both render, with a board condition naming the collision - disclosed, never resolved by silent precedence (no precedence rule exists; inventing one silently is the Law 6 trap) | 4, 6 |
| Record `at` in the future / clock steps back | `failed`-class handling at fold time, never silently fresh (rev 3 §8 guards carried) | 1 |
| SSE heartbeat missed twice | Chrome flips disconnected; last-good stays, visibly marked | 1, 5 |
| Wire payload fails browser-side schema validation | Payload discarded; previous render stays, marked; board condition | 1 |
| Envelope fault classes (`absent`/`malformed`) on a `returned` record | Rendered as the record states them - the store already distinguishes these; the board does not re-diagnose | 1; #557 |
| Producer latency window (~11-12s) | `asOf` and per-lane age make the window visible; nothing pretends to be more live than the store | 5; P6 |

## §7 - Out of scope (with triggers)

Git adapter; GitHub board adapter (freight lane) - trigger: first train after v0 ships.
Fuel gauge surfacing - trigger: #11 cost-ledger work. Auth - local-only, stated in README.
View-side override UI - trigger: the second use of intent-record overrides (Law 2 is
served by the store path in v0). History/event-log view - the snapshot is current-state;
the store HOLDS history, rendering it is its own design. Multi-repo (P3). **#12 car
health bar** (owner's spine idea - REJECT-round convergence per car): deliberately NOT in
v0's scope; trigger: its own design rung, fed by this board's gates lane once real data
flows through it. Push notification on `needs-attention` (#559's second half) - trigger:
the board's first week of live use. Retirement of the pwsh detector (Q1). A manifest
helper CLI - trigger: the third hand-written manifest, if it hurts (probe suite pattern:
build tools from lived friction, not prediction).

## §8 - Contracts touched

| Document | Change | Owner |
|---|---|---|
| `docs/contracts/state-ledger.md` | New rows: server process state (`lastGoodSnapshot`, `lastPollAt`, `pollInFlight`, `seq`, timer, `connectedClients`, lane-id set) + bounded browser state (rendered snapshot, connection status, last-applied `seq`) - rev 3 §11's enumeration carries | Server car |
| `docs/contracts/gating-matrix.md` | Five board truth surfaces: staleness, disconnect, failed-panel, detector, board conditions (rev 3 §11 carried) | Server car (matrix rows land with the mechanisms) |
| `README.md` + quickstart | The board exists; local-only, unauthenticated; "no adapters ship yet" line dies | View car (doc sentence check applies at its review) |
| `docs/setup.md` | Trigger rows: Go toolchain arrival, #3/#4 CI guards land-or-re-park (rev 3's Car 1 obligation carries) | Toolchain car |
| `schema/vocab/kinds.json` etc. | Any vocabulary additions the manifest needs | Schema car |
| This design | Any spec-rung deviation folds back with an amendment block | Conductor |

## §9 - Cost

Design rung (this document): 1 Opus adversarial review round, plus re-rounds as earned.
The full train, proposed for owner approval AT PLAN RUNG, not now: spec + spec review,
plan + plan review, ~5 cars + 5 reviews (toolchain/CI first per D10; schema+vectors;
fold port + adapter; server; view + README). **Model mix per the ratified topology: cars
Sonnet, gates Opus** (supersedes rev 3 §11's "Opus throughout", stated not silent).
Size class: large. Rev 4 adds one NEW cost class rev 3 lacked: the owner's Go-learning
time is real spend and is the point (P5).

## §9b - Disposition of prior rounds

Rounds 1-2 findings were dispositioned in rev 3's §13 table (kept in git history with
rev 3's full text); those dispositions CARRY except where superseded below. Rev 3 itself
received no verdict (parked), so this table dispositions rev 3's decisions against the
rulings that parked it:

| Prior item | Kind | Disposition | Where |
|---|---|---|---|
| D2 (TS on Node, shared type module) | rev 3 decision | **superseded** - owner ruling #14 (Go); the single-definition intent survives as schema-ownership | D12, D15 |
| D3 (conductor state file is first adapter) | rev 3 decision | **superseded** - the harness ruling; the store is the instrument #552 demands | D13 |
| D5 (a StateWriter ships) | rev 3 decision | **superseded** - intent records; Law 2 served by the store's own write path | D14 |
| D6 (poll by mtime, not fs.watch) | rev 3 decision | **adapted** - the store is many small append-only files, not one swapped file; polling survives, mtime-of-one-file does not. Scan semantics to spec rung | §5.6 |
| Rev 3 §5 lane contract, §5.6 composition, §7 server rules, §9 failure table | rev 3 sections | **carried, first review THIS round** - inherited-risk disclosure in the header | §5.2, §5.6, §6 |
| Rev 3 §11 "Opus throughout" cost line | rev 3 decision | **superseded** by the ratified model topology, loudly | §9 |
| Rounds 1-2: all other dispositions | findings | **carried** via rev 3 §13 (git history) | - |

## §10 - Open questions for the reviewer

1. **Q1 - the dual fold.** D18 keeps the pwsh detector as CI cross-verifier against the
   shared vectors. Is dual maintenance a Law 6 wound waiting to reopen, or is
   vectors-as-single-authority sufficient? Cost of "retire pwsh now": losing the only
   fold implementation that runs without the Go toolchain, mid-transition.
2. **Q2 - manifest collision row (§6).** Two manifests claiming one dispatch renders
   both plus a condition, no precedence. Is disclosed-collision correct, or does
   latest-`at` supersession (already store law for same-subject records) legitimately
   extend to cross-manifest membership?
3. **Q3 - gates as manifest-declared roles.** A review dispatch is only a "gate" because
   the manifest says so (#557 compliance). The migrated pre-harness verdicts (29 records)
   have no manifest - do they render as a historical gates lane via their subject-slug
   convention (a read-side convention, flirting with inference), or stay in yard
   inventory until backfill manifests are written? The backfill is cheap and honest;
   the convention is free and smells.
4. **Q4 - wire-schema validation depth in the browser.** Full JSON-Schema validation
   client-side needs a JS validator dependency (P4 tension); a hand-rolled structural
   check is a second copy of the schema's knowledge (Law 6 tension). Which loses less?
5. **Q5 - the walking skeleton's first paint.** With five lanes and two live adapt-less
   lanes (`freight` dark, `fuel` bagged), is the v0 board visually honest-but-thin, and
   is that acceptable for the showcase's first screenshot, or does v0 owe the freight
   lane a read-only issue-count adapter to earn the wall?

## §13 - Revision history

- **Rev 1** (2026-07-21): REJECT, 9 Major. **Rev 2** (2026-07-22): REJECT, 8 Major -
  root cause: axes specified, composition unspecified. **Rev 3** (2026-07-22): composition
  specified (§5.6); PARKED UNREVIEWED same day when the harness was ruled core product.
  Full rev 3 text and its finding-disposition tables: git history of this file.
- **Rev 4** (2026-07-23, this document): rewritten against the landed harness contract
  (store as sole adapter), owner rulings #14 (Go), train-identity-by-intent, and the
  ancestor prior art ported at this rung's opening (#552/#557/#559/honest-unreachable).
  Instrument check, constraints, premises, and probe list added per
  `docs/templates/design-doc.md` (the template postdates rev 3).
