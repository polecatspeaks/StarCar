# Design: v0 yard skeleton

Status: Open
State: **rev 5 APPROVED at design review round 4 (2026-07-23, 0 Major, 2 Minor) -
proceeds to the SPEC rung.** DR4-1 (empty-vocab vector homes
with the FOLD vectors, on the D18 cross-verifier's path) and DR4-2 (the pwsh detector's
empty-vocab edit is a named scoped task) fold into the spec revision. Q6-Q8 ruled
binding (coarse backfill default; `train:` prefix KEPT with guardrails; vectors rehome
to a language-neutral `schema/vectors/`). The round-4 reviewer was FRESH under the
mechanical rotation trigger and reviewed cold from the landed verdicts alone - the
record sufficed; rotation is proven outside the drill. Verdict:
`artifacts/reviews/2026-07-23-design-v0-round4-APPROVE.md`. Convergence: 9 → 8 → 3 → 0.
Issue: #1 (`area:view`)
Date: 2026-07-21 (rev 3: 2026-07-22; rev 4: 2026-07-23; rev 5: 2026-07-23)
Ladder rung: design (rung 1 of: design → spec → plan → cars)
History: rev 1 REJECT (9 Major), rev 2 REJECT (8 Major), rev 3 PARKED UNREVIEWED
(superseded by the harness ruling before its round dispatched), rev 4 REJECT (3 Major,
5 Minor, 3 Notes - convergence ruled HEALTHY, zero swirl triggers; verdict:
`artifacts/reviews/2026-07-23-design-v0-round3-REJECT.md`). See §13 and §9b.

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
| Train manifest (the intent-record payload) | schema addition + vectors, spec rung. Round-3 obligations the vectors MUST pin: the `train:` subject partition (DR3-3), the fold-winner-to-raw-payload join incl. a superseded-manifest case (DR3-1), and the D17 key-set addition (DR3-1 item 4) | TO PRODUCE |
| Wire snapshot (`YardSnapshot` + vocabularies) | a JSON Schema file + vectors, spec rung. Round-3 obligation: the empty-vocabulary-yields-one-fault vector (DR3-2) | TO PRODUCE |

This document DESCRIBES those contracts and DEFINES none of them. A reviewer who finds a
canonicalisation rule, a field list, or an ordering rule specified only in this prose has
found a defect (the harness design's four-round scar, `docs/templates/design-doc.md` §0).

## §1 - Constraints (before the mechanism)

| Source | What it forbids here | How this design satisfies it |
|---|---|---|
| Law 1 (`constitution.md:18`) - "Unknown states render AS unknown, honestly" | A board that guesses: an unrecognised vocabulary value coerced to a known one; a lane with no adapter claiming "not yet read"; dev-lag presented as live | §5.6 Rule 2/4 carried; the detector renders unknowns by name; the snapshot carries `asOf` provenance |
| Law 2 (`constitution.md:21-23`) - "never resists an override"; worked example: "if a dispatcher marks a train held, the board renders held" | A board the dispatcher cannot override without editing code | §5.5: the override IS a store write - an `intent` record (`held`), rendered because the store is the source of truth. No view-side override in v0 (§7) |
| Law 3 - the board resolves in one glance | An open-ended visual vocabulary | §5.2 carried: `Register` is the ONLY closed taxonomy, three members, growth is constitution-level |
| Law 4 (`constitution.md:32-36`) - "never silently dropped"; an empty yard where lanes should be is a lie of omission | Losing store data the view does not understand; hiding dispatches that belong to no train; `encoding/json`'s default silent field drop (**observed**: FACT1, `docs/probes/2026-07-23-go-substrate-probe-results.md`) | §5.4 double-decode preserve-and-disclose (FACT3); §5.3 the yard-inventory lane for unassigned dispatches; §5.6 completeness guards carried |
| Law 5 - freshness always visible; "a stale board that looks live is the disease" | Rendering store data without its age; client-computed age | §5.6 Rule 3 carried: age is server-issued (`ageBucketMs`); staleness and disconnect are separate truths (D7) |
| Law 6 (`constitution.md:48-50`) - "never maintains a second copy of anything that can drift" | A second fold implementation with its own semantics; a wire type declared twice; contract text in two owners | §4 D18: the conformance VECTORS own fold semantics, implementations conform (the pwsh detector becomes the cross-verifier, not a second authority - CI-gated per the Q1 ruling); §5.4 the wire contract is schema-owned, both sides validate |
| Law 7 (`constitution.md:56`) - "pluggable adapters, no hardcoded board schemas or label taxonomies" | Hardcoding this shop's kinds/outcomes/positions into the view; a board only this repo can use | §5.2 carried: open vocabularies as data on the wire; the store adapter is one adapter behind a seam (§5.3) |
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
| P7. **The board does NOT re-verify record `integrity` hashes on read** `[DR3-6, folded]`. Hash verification is CI's job (`StoreIntegrity.Tests.ps1`, gated); the server reads the working tree, and an attacker who owns the checkout owns the hashes too, so read-side recomputation adds cost without adding trust. | If read-side verification is ever required (e.g. the board reads a store it does not trust CI to have gated), the adapter recomputes per record at poll cost and a failed hash becomes a quarantine row in §6 - the seam exists; the work is bounded |

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
| A dependency-free, no-build-step JS draft-2020-12 validator exists for the browser side (P4's constraint) `[DR3-7, folded; Q4 ruling]` | Library existence + conformance are empirical claims, symmetric with the Go row above | BLOCKING TEST at the plan rung: candidate validates the wire schema + vectors in a bare browser context, observed. Negative branch (per the Q4 ruling): a hand-rolled structural check ships as a DISCLOSED degradation - a second copy of the schema's knowledge, named as such in the gating matrix, with the validator's arrival as its retirement trigger |
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
| **D12** | **Go server; browser JS view** | Owner ruling: strongest test of institution-over-fluency; single static binary (asserted by the #14 ruling, PROVEN only at Car 1's cross-compile probe, §2c `[Note-2, folded]`); SRE fit. Contradictions recorded on #14 | Ruling #14; P5 |
| **D13** | **The artifact store is the SOLE adapter** (supersedes D3: conductor state file) | The store is the pipeline's own instrument - the only #552-compliant source. It records what rev 3's state file existed to hand-record | #552; the harness ruling that parked rev 3 |
| **D14** | **No StateWriter** (supersedes D5). Dispatcher overrides are `intent` records written to the store | Law 2's override renders because the source of truth says so - one write path, one store, provenance for free | Law 2; Law 6; #552 |
| **D15** | **The wire contract is owned by a JSON Schema file**; Go structs and the browser validator both conform to it (supersedes D2's shared-TS-module repair) | Cross-language seam: no module can be physically shared. The schema-as-constructed-header pattern is already landed practice in this repo | Law 6; NO HEADERS HERE |
| **D16** | **Train identity = conductor-declared manifest, as `intent` records in the store.** Membership from the manifest; status ONLY from the fold | The ban is on hand-maintained COPIES, not hand-declared ORIGINALS: train composition is born in the conductor's ruling on tickets and exists nowhere upstream to copy. A stale manifest SHOWS (orphan cars on the board); a stale status file LIED | Owner ruling 2026-07-23; #552; Law 4 |
| **D17** | **Record reads are double-decoded**: typed struct + `map[string]json.RawMessage`; key-set diff → unknown fields preserved and disclosed as a board condition | Go's default silently drops unknown fields (FACT1, observed); `DisallowUnknownFields` blanks the board over harmless additions (FACT2) - reject-not-disclose, the Law 1 harm | Law 4; Law 1; FACT1/2/3 |
| **D18** | **The fold is ported to Go; the existing conformance vectors REMAIN the contract; the pwsh detector remains as CI cross-verifier - and the cross-verification is a REAL CI JOB, not an assertion** `[Q1, ruling adopted]`: a CI step runs BOTH implementations against the shared vectors and fails on divergence. Until that job exists and has been watched to fire on an injected divergence, the Law 6 escape is unproven | Two implementations, ONE authority: the vectors. Divergence = a red naming the divergent case. Retiring the pwsh detector stays deferred (§7): losing the only toolchain-free fold mid-transition is the larger cost | Law 6; Healing Loop; Q1 ruling |
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

### 5.2 The lane contract - CARRIED from rev 3, SELF-CONTAINED here `[DR3-8, folded]`

Carried in substance from rev 3 and stated in full below (a load-bearing contract carried
only by reference to a superseded revision is unreadable at review time); the wire schema
pins these shapes executably at the spec rung, which then becomes the single owner:

- **Registers** (`nominal | in-progress | needs-attention`, severity-ordered) - the ONLY
  closed taxonomy; the glance language. Growing it is a constitution-level decision.
- **Positions** (`live | bagged | dark | under-construction`) - open, data, registry-owned
  (D11), each with a `register` and a `surfacesData` flag.
- **Freshness** - closed by mechanism, provably complete: `not-applicable` (no adapter) |
  `never-polled` | `fresh` | `stale` (with server-issued `ageBucketMs`) | `failed` (with
  coded reason and `lastGood`/`lastGoodAsOf` carried).
- **Composition rules** (rev 2's REJECT root cause, closed in rev 3, restated in full):
  - **Rule 1:** rendered register = MOST SEVERE of the three axes' registers - position's
    (from its def; `needs-attention` if unrecognised), freshness's (per this mapping:
    `not-applicable`→`nominal`, `never-polled`→`in-progress`, `fresh`→`nominal`,
    `stale`→`needs-attention`, `failed`→`needs-attention`), and capability's (`nominal`,
    or `needs-attention` when no renderer exists for the payload). The load-bearing case:
    a `live` lane whose data source dies resolves `needs-attention` - the board goes hot
    when the data dies.
  - **Rule 2:** position speaks first (primary line), freshness second; `not-applicable`
    renders NO freshness line (a lane that will never be read must never say "not yet
    read"); `surfacesData: false` renders no payload and says so; missing capability says
    "no renderer for this payload", never nothing.
  - **Rule 3:** rendered age always comes from the server (`ageBucketMs`, quantised,
    included in change detection); the client never computes age from its own clock.
  - **Rule 4:** the detector's register is `needs-attention`, deliberately - the one
    alarm that is about the board rather than the yard.
- **Completeness guards** - every registered lane in every snapshot on every code path
  including pre-first-poll; the lane-id set pinned by a fixture-backed test (shrink =
  red); lane count rendered in chrome and ledgered.

v0's lane registry: `dispatches` (live), `gates` (live), `trains` (live), `freight`
(dark - the ticket queue has no adapter yet), `fuel` (bagged - `cost` fields exist on
some records, held but not surfaced until #11's cost ledger work). Positions per D11 are
deploy-time registry truth.

### 5.3 The store adapter and the four derived surfaces

`StoreAdapter` scans `artifacts/**/*.json` under the configured repo checkout (P3) each
poll. Per record: double-decode (D17), schema-shape check, quarantine-with-disclosure on
failure (§6). It yields raw records; everything else is derivation.

**What the fold does and does not carry** `[DR3-1, folded]` - stated against the landed
substrate, not assumed: the fold's `intents` output carries ONLY `subject`, `at`, and
`superseded` (`Detect-Dispatches.ps1:211-215`; pinned by `Detector.Tests.ps1:116-120`).
**The manifest PAYLOAD - members, roles, title, ticket refs - is NOT in fold output and
never will be**; it lives in the raw intent records the adapter yields. Any surface
needing manifest content therefore consumes TWO inputs by construction:

1. `fold.intents` - the SOLE supersession authority: it names the current (winning)
   manifest record per train subject and exposes superseded ones.
2. The raw record store - the Assembler fetches the WINNING record's payload by the
   subject+`at` the fold named. **The Assembler never selects "latest manifest" over raw
   records itself** - that would re-implement the fold's supersession logic, a Law 6
   second copy that drifts silently. The fold picks; the Assembler fetches what was
   picked. This join is pinned by a conformance vector at the spec rung (a store with a
   superseded manifest must render the winner's members and expose the loser).

Derivation ownership, corrected from rev 4's over-claim ("exactly one owner" hid a
two-source Gates row - the same class rev 2 rejected):

| Surface | Owner | Inputs (all of them, named) |
|---|---|---|
| Dispatch liveness (`dispatched`/`overdue`/`returned`/`presumed-lost`, supersession, elapsed-vs-budget) | the Fold (D18) | dispatch-kind records ONLY |
| Trains (consists) | the Assembler | `fold.dispatches` (liveness) + `fold.intents` (winning manifest per train) + raw manifest payloads (membership, roles, title) |
| Gates | the Assembler | `returned` records' `outcome` rendered VERBATIM (#557) + gate identity/role from the winning manifest's declaration. Two inputs, one owner - the Assembler composes; nothing else derives gate identity |
| Yard inventory | the Assembler | `fold.dispatches` MINUS the union of winning manifests' members - every unassigned dispatch, rendered loudly (Law 4) |

**One owner means one COMPOSER per surface, with every input named** - not one input.
Rev 4 conflated the two; this table is the corrected claim.

**D17 interaction** `[DR3-1 item 4, folded]`: the manifest payload fields join the wire
schema AND the Go typed struct's known key-set in the same spec-rung change - otherwise
D17's unknown-field disclosure would flag every well-formed manifest as "N unrecognised
fields", a wolf-cry on the exact surface the manifest legitimizes.

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
   a hand-maintained mirror of it anywhere is a finding. **Browser-side depth** `[Q4,
   ruling adopted]`: a single vetted, no-build-step JS draft-2020-12 validator consuming
   THE schema file - a validator is data-driven, so it is not a second copy of the
   schema's knowledge, where a hand-rolled structural check IS one. Its existence is a
   §2c probe with a plan-rung blocking test; the negative branch ships the structural
   check as a DISCLOSED degradation with a named retirement trigger.
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

**Subject-namespace partition** `[DR3-3, folded]`: `subject` is ONE identity namespace
(`starcar-artifact.schema.json:15-17`), and rev 4 silently assumed train subjects and
dispatch subjects were disjoint. The rule, now on the page: **manifest subjects carry a
mandatory `train:` prefix** (`train:index-gate-scope`), which no dispatch subject can
collide with (dispatch subjects are producer-minted agent ids; the prefix character
class is outside their alphabet - the exact format is the manifest executable spec's to
pin, with a vector asserting the partition). Defense in depth: an OBSERVED collision -
any subject appearing in both `fold.dispatches` and `fold.intents` - still renders a
board condition naming it (§6), because a rule and a detector are cheaper together than
either alone.

**The 29 pre-harness verdicts** `[Q3, ruling adopted]`: the migrated records carry no
manifests and render honestly in yard inventory with their outcomes until **backfill
manifests** are written - the ruling REJECTED the subject-slug convention as #557
inference ("free and smells"). Backfill is a v0-adjacent content task, cheap and honest,
scheduled at the plan rung; granularity (per historical train vs one historical-era
manifest) is §10 Q6.

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
| **Store directory present but EMPTY - a successful scan of zero records** `[DR3-5a, folded]` | Honest-empty: the scan SUCCEEDED, freshness is `fresh` with zero-record content, lanes render their empty truth ("0 dispatches observed"), distinguished loudly from `failed`. Law 7's stranger on day one sees a working board with nothing in the yard yet - true, not broken | 1, 7 |
| A record fails schema-shape validation | That RECORD quarantined + board condition naming the file; remaining records load. One bad record must not blank the board | 1, 4 |
| **ALL records quarantined** `[DR3-5b, folded]` | The degenerate case of the row above is its own state: a board condition "N of N records quarantined" at `needs-attention`, and lanes render as empty-with-cause, never as honest-empty - zero-of-N and zero-of-zero are different truths | 1, 4 |
| A record carries unknown fields | Preserved and disclosed (D17): board condition "record X carries N unrecognised fields" | 4; FACT1/3 |
| A record file is caught mid-write (partial JSON) `[Note-1, folded]` | Transient one-poll quarantine that self-heals on the next scan - honest both polls. If it proves noisy, atomic producer writes are the HARNESS's concern, not the board's | 1, 4 |
| Unrecognised `kind`/`outcome`/`position`/role, vocabularies loaded | Detector fires: rendered loudly BY NAME, register `needs-attention` - a discovery, not a bug | 1, 7 |
| Vocabulary file missing/malformed | ONE board condition; detector does NOT fire per-record (rev 3's cascade fix, carried) | 1, 4, 5 |
| **Vocabulary file VALID but empty (or below the floor of one value)** `[DR3-2, folded - Major]` | Treated as a VOCABULARY FAULT, identical to malformed: ONE board condition, detector does NOT fan out. A well-formed `{"values":[]}` is neither missing nor malformed, and without this row every record's kind becomes a false "discovery" - the N-wolf-cries cascade rev 2 MAJOR-3 rejected, reproduced against the landed detector (`Detect-Dispatches.ps1:71-72,101-108`). Pinned by a spec-rung vector: empty vocabulary yields one fault, zero per-record discoveries | 1, 4, 5 |
| Manifest names a subject with no records | Member rendered `declared, not yet observed` - intent without observation is rendered as exactly that | 1 |
| Dispatch belongs to no manifest | Yard-inventory lane, loudly. The self-measure of P2 | 4 |
| Two manifests claim one dispatch `[Q2, ruling adopted]` | Both render, with a board condition naming the collision - disclosed, never resolved by silent precedence. The ruling CONFIRMED: latest-`at` is same-subject store law and does NOT extend across different manifest subjects; two sources disagreeing is shown, never silently won | 4, 6 |
| A subject appears in BOTH `fold.dispatches` and `fold.intents` `[DR3-3, folded]` | Should be impossible under the `train:` partition rule (§5.5); if OBSERVED anyway, a board condition names it and neither rendering is suppressed - the detector-behind-the-rule posture | 1, 6 |
| The checkout is detached-HEAD or historically old `[Note-3, folded]` | Scans succeed; the board renders STALE by data age (newest record `at` is old), honestly - the data-age signal converts an apparent lifecycle hole into a demonstrated strength | 5 |
| Record `at` in the future / clock steps back | `failed`-class handling at fold time, never silently fresh (rev 3 §8 guards carried) | 1 |
| SSE heartbeat missed twice | Chrome flips disconnected; last-good stays, visibly marked | 1, 5 |
| Wire payload fails browser-side schema validation | Payload discarded; previous render stays, marked; board condition | 1 |
| Envelope fault classes (`absent`/`malformed`) on a `returned` record | Rendered as the record states them - the store already distinguishes these; the board does not re-diagnose | 1; #557 |
| Producer latency window (~11-12s) | `asOf` and per-lane age make the window visible; nothing pretends to be more live than the store | 5; P6 |

## §7 - Out of scope (with triggers)

Git adapter; GitHub board adapter (freight lane) - trigger: first train after v0 ships
`[Q5, ruling adopted: honest-but-thin first paint is CORRECT for the showcase - a first
screenshot with loudly-honest dark/bagged lanes demonstrates the Law 4 mechanism working;
freight stays out]`.
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
| Rounds 1-2: all other dispositions | findings | **carried** via rev 3 §13 (git history); the load-bearing composition contract itself now restated IN FULL in §5.2 rather than by reference | §5.2 |

**Round 3 (rev 4 REJECT, verdict `artifacts/reviews/2026-07-23-design-v0-round3-REJECT.md`):**

| Prior item | Kind | Disposition | Where |
|---|---|---|---|
| DR3-1 (Major) - fold exposes no manifest payload; "exactly one owner" over-claim; Law 6 re-implementation trap; D17 key-set constraint | finding | **adopted** - fold-winner-to-raw join specified, ownership table corrected to one-COMPOSER-with-all-inputs-named, D17/schema constraint stated | §5.3 |
| DR3-2 (Major) - valid-but-empty vocabulary reopens the cascade | finding | **adopted** - new §6 row, vocabulary-fault treatment, spec-rung vector named | §6 |
| DR3-3 (Major) - subject namespace collision unpartitioned | finding | **adopted** - `train:` prefix partition rule + observed-collision detector row (both, deliberately: rule plus detector) | §5.5, §6 |
| DR3-4 (Minor) - three citation ranges off by one | finding | **adopted** - Law 1 `:18`, Law 6 `:48-50`, Law 7 `:56` | §1 |
| DR3-5 (Minor) - missing empty-store and all-quarantined rows | finding | **adopted** - two new §6 rows, zero-of-N vs zero-of-zero distinguished | §6 |
| DR3-6 (Minor) - unstated no-read-side-integrity premise | finding | **adopted** - P7 with if-false | §2 |
| DR3-7 (Minor) - browser-validator probe unlisted | finding | **adopted** - §2c row, symmetric with the Go row, negative branch stated | §2c |
| DR3-8 (Minor) - composition carried by git-history reference | finding | **adopted** - §5.2 self-contained | §5.2 |
| Note-1 partial writes; Note-2 single-binary certainty; Note-3 detached-HEAD strength | notes | **adopted** - §6 row; D12 caveat; §6 row | §6, §4 |
| Q1 - dual fold | **ruling** | **adopted** - kept, with the binding CI cross-verifier condition folded into D18 | §4 D18 |
| Q2 - manifest collision | **ruling** | **adopted** - disclosed-collision confirmed; latest-`at` does not extend cross-subject | §6 |
| Q3 - the 29 migrated verdicts | **ruling** | **adopted** - yard inventory + backfill manifests; slug convention rejected | §5.5 |
| Q4 - browser validation depth | **ruling** | **adopted** - schema-driven JS validator; structural check only as disclosed degradation | §5.4, §2c |
| Q5 - first paint | **ruling** | **adopted** - honest-but-thin stands; freight stays out | §7 |

## §10 - Open questions for the reviewer (round 4)

Q1-Q5 were RULED in round 3 (all adopted - dispositions in §9b); they are closed unless
the fresh reviewer finds a ruling unsound against evidence. New questions, real ones:

1. **Q6 - backfill granularity.** The 29 migrated verdicts get backfill manifests (Q3
   ruling). One manifest per historical train (faithful, ~6-8 manifests, requires
   reconstructing consist membership from session history), or one historical-era
   manifest ("pre-harness era" train, cheap, honest about its own coarseness)? Cost of
   the faithful option: conductor archaeology against the Entire checkpoint branch;
   cost of the coarse one: the gates lane's history renders flat.
2. **Q7 - the `train:` prefix partition (§5.5).** Prefix-in-subject partitions the
   namespace inside the existing schema with zero schema changes. The alternative -
   manifests keyed by a dedicated payload field with subjects staying free-form - is
   cleaner typing but adds a second identity mechanism to a store whose ruling R2 made
   `subject` THE identity key. Is prefix-in-subject the right cut, or does it smuggle
   structure into an opaque key that some future consumer will parse (the inference
   smell, one level down)?
3. **Q8 - fold-port test topology.** D18's Go fold must pass the shared vectors. Do the
   vectors stay physically in `scripts/tests/Detector.Tests.ps1` with the Go side
   consuming an extracted JSON form (extraction = a derived copy, Law 6 tension), or do
   they move to a language-neutral `schema/vectors/` home both implementations consume
   (a migration touching the landed harness suite)? Neither is free; rule on which debt
   is cheaper to hold.

## §13 - Revision history

- **Rev 1** (2026-07-21): REJECT, 9 Major. **Rev 2** (2026-07-22): REJECT, 8 Major -
  root cause: axes specified, composition unspecified. **Rev 3** (2026-07-22): composition
  specified (§5.6); PARKED UNREVIEWED same day when the harness was ruled core product.
  Full rev 3 text and its finding-disposition tables: git history of this file.
- **Rev 4** (2026-07-23): rewritten against the landed harness contract (store as sole
  adapter), owner rulings #14 (Go), train-identity-by-intent, and the ancestor prior art
  ported at this rung's opening (#552/#557/#559/honest-unreachable). Instrument check,
  constraints, premises, and probe list added per `docs/templates/design-doc.md` (the
  template postdates rev 3). **REJECT at round 3** - 3 Major (all at the new
  manifest/fold seam: fold payload observability, empty-vocab cascade, subject-namespace
  partition), 5 Minor, 3 Notes; convergence ruled HEALTHY (9→8→3, zero swirl triggers);
  Q1-Q5 ruled. Verdict verbatim: `artifacts/reviews/2026-07-23-design-v0-round3-REJECT.md`.
- **Rev 5** (2026-07-23, this document): round 3 folded - every DR3 finding and Q ruling
  dispositioned inline (`[DR3-n, folded]` / `[Qn, ruling adopted]` markers; roll-up in
  §9b). **APPROVED at round 4** under REVIEWER ROTATION: the fresh reviewer
  reconstructed the series from the landed verdicts alone (record ruled sufficient - the
  rotation doctrine proven outside the drill), walked every disposition PRESENT with
  zero DRIFTED, re-verified the substrate citations and probes independently, found 2
  Minor (DR4-1 vector homing, DR4-2 detector-edit scoping - both spec-revision items),
  and ruled convergence HEALTHY AND TERMINAL: 9 → 8 → 3 → 0 Major. Q6-Q8 ruled binding.
  The spec rung inherits the verdict's seven-item executable-obligations handoff.
  Verdict: `artifacts/reviews/2026-07-23-design-v0-round4-APPROVE.md`.
