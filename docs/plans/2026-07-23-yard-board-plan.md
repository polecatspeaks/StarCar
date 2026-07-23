# Plan: the yard board train (v0 walking skeleton)

Status: Open
State: rev 1 - awaiting adversarial plan review round 1
Issue: #1 (`area:view`)
Ladder rung: plan (rung 3), inheriting `docs/specs/2026-07-23-yard-board-spec.md` rev 2
(APPROVED at delta round 2, `artifacts/reviews/2026-07-23-board-spec-round2-APPROVE.md`)
and its five-item plan-rung handoff, plus design rev 5 (APPROVED round 4).
Base: **`c4daeae`** on `dev` - every car verifies this base before its first edit.

## 0. Blocking tests (spec YB-11, design §2c) - status at plan time

| Test | Status | Evidence |
|---|---|---|
| (a) Go draft-2020-12 validator over the store + manifest + wire schemas | **GREEN - OBSERVED at plan authoring (2026-07-23)** | `santhosh-tekuri/jsonschema/v6 v6.0.2`: all three schemas COMPILE (patterns incl.), all five manifest fault-injection directions reproduce exactly as under .NET, a real store record validates, `if/then` conditional machinery verified (`returned` missing `outcome` fails). The library is PINNED for the train: v6.0.2 |
| (b) No-build-step browser JS validator over the wire schema | **DEFERRED TO CAR 1, honestly** - no browser exists in this plan-rung environment to observe "a bare browser context" | Car 1 task 1.5 probes the vendored-ESM candidate in Node (ESM-loads-without-build proves the no-build-step property); the TRUE browser observation lands with Car 5's first live serve. The disclosed-degradation branch (structural check, named in the gating matrix, validator-arrival retirement trigger) stays armed. A plan reviewer ruling this split dishonest should say where the browser comes from |

## 1. Consist and order

`1 → 2 → 3 → 4 → 5`, strictly sequential (each car's base includes the prior car's
merged work; no parallel pair this train - car 4 consumes car 3's fold package and car
5 consumes car 4's wire, so the rev 3 {3,4} parallelism no longer applies).

Cars are **Sonnet**, reviewers **Opus** (ratified topology). Every car works in an
isolated worktree cut from the then-current `dev` tip, verifies its base, commits
locally, never pushes. Every car's brief mandates the report envelope. Every reviewer
gets a fresh detached worktree at the car's final SHA.

## 2. Car 1 - Go toolchain, CI leg, RE2 probe, JS-validator probe

Scope: the board's Go module skeleton + CI, NOTHING product-behavioral. D10: this car
is not done when CI is green - it is done when the new leg has been WATCHED to go red.

- **1.1** `board/go.mod` (module `github.com/polecatspeaks/StarCar/board`, Go 1.26)
  with a placeholder package + one trivial test, so the CI leg has something real to
  run. Dependency pinned: `github.com/santhosh-tekuri/jsonschema/v6 v6.0.2` (§0a).
- **1.2** CI: a `board` step in `.github/workflows/ci.yml` (both matrix legs):
  `actions/setup-go` (go.mod-driven version), `go vet ./...` + `go test ./...` inside
  `board/`. Zero-test refusal: the step fails if `go test` reports no tests (mirror of
  the Pester zero-test guard - a green leg that asserted nothing is a lying
  instrument).
- **1.3** The RE2 standing-rule probe (spec YB-11 + round-2 handoff item 2): a Go test
  in `board/` that walks every `"pattern"` value in every `schema/*.schema.json` and
  `regexp.Compile`s it. RED-FIRST: fault-inject a lookahead pattern into a scratch
  copy consumed by the test fixture path, observe the red, revert. This makes the
  spec's "RE2-compatible patterns" rule mechanical.
- **1.4** WATCHED-RED for the whole leg: fault-inject a failing Go test, push to the
  CAR BRANCH is forbidden (cars never push) - so the red is observed LOCALLY
  (`go test` exit code + the CI-step logic run via the committed step's commands), and
  the LIVE CI red is a conductor handback at merge (inject, watch, revert, record run
  URL - same shape as YB-9's).
- **1.5** JS-validator probe (§0b): vendor the candidate ESM validator (no build
  step - a file, committed under `board/web/vendor/` with license noted), load it in
  Node as bare ESM, validate the wire schema + one sample snapshot. Record observed
  result in the car report. If NO candidate loads bare: the degradation branch is
  taken and DISCLOSED (gating-matrix row lands with Car 5, not silently).
- **1.6** `docs/setup.md`: Go toolchain row added; the #3/#4 parked CI guards get a
  land-or-re-park DECISION recorded (re-park expected; the decision is the
  deliverable).

Suites after: existing Pester 175/175 + probes 12/12 untouched; `go test ./board/...`
green with its new tests counted in the report.

## 3. Car 2 - vocabulary truth + wire payload $defs

- **2.1** `schema/vocab/outcomes.json` += `done`, `CONFIRM` (observed in the store:
  5 and 3 records), `done-with-findings` (contract-enumerated,
  `docs/templates/car-brief.md:47-48`) - YB-3. SAME COMMIT: the detector vocabulary
  test in `scripts/tests/Detector.Tests.ps1` updates, and the live-store detector run
  stops firing discoveries on `done`/`CONFIRM` (observed before/after in the report).
- **2.2** `schema/yard-snapshot.schema.json` gains `$defs.trainsPayload`,
  `$defs.gatesPayload`, `$defs.dispatchesPayload` per spec YB-5's field lists, and
  `$defs.lane.data` gains a `$comment` pointing at them. RED-FIRST via new Pester
  cases in `scripts/tests/` (`Test-Json`): a conforming sample of each payload
  passes; a nonconforming sample of each (missing required member field; a car entry
  without `subject`; a gates entry without verbatim `outcome`) fails for its stated
  reason. RE2 rule binds any new pattern (Car 1's probe now enforces).
- **2.3** Go-side re-validation: run Car 1's board test suite (which loads the
  schemas) - the extended wire schema must still COMPILE under the pinned validator.

## 4. Car 3 - vector rehome, detector fix, Go fold port, cross-verifier

Four tasks, four commits, strictly in order (each is the next one's substrate):

- **3.1 (YB-10, its own task by ruling)** Rehome the existing `Detector.Tests.ps1`
  imperative cases as declarative fixtures in `schema/vectors/fold/*.json` and convert
  the Pester suite to a fixture-driven RUNNER (materialise records, temp vocab,
  `-Now`, deep-equal per the README contract). PROOF: the same cases green before and
  after, counts stated; the runner also executes the three spec-rung vectors -
  `subject-partition` and `manifest-supersession` go green, `empty-vocab-one-fault`
  goes RED (expected - it pins 3.2's fix; the runner marks it an EXPECTED failure
  until 3.2, explicitly, so the suite is honest about why it is not green).
- **3.2 (YB-8/DR4-2)** The detector empty-vocab fix: `scripts/Detect-Dispatches.ps1`
  emits ONE combined fault (`vocabulary: valid but empty: <files, alphabetical>`) and
  zero per-record discoveries for valid-but-empty vocabulary files. RED-FIRST: the
  vector red from 3.1 flips green; the report quotes both observations.
- **3.3 (YB-7/D18)** The Go fold port: `board/fold` package + a Go vector-runner
  (`go test`) consuming `schema/vectors/fold/` per the README contract. ALL vectors
  green, including empty-vocab (the Go fold is born with the fix). The fold package's
  public API is the interface car 4 consumes: fold(records, vocab, now) → the vector
  contract's output shape.
- **3.4 (YB-9/Q1)** The D18 cross-verifier CI step: runs the pwsh runner AND the Go
  runner over every fold vector; ANY divergence (either side red, or outputs
  disagreeing with expected) fails the build. Watched-to-fire is a CONDUCTOR HANDBACK
  at merge: inject a one-character divergence into a scratch vector copy, watch the
  live red, revert, record the run URL - recorded in the train's closing report, not
  claimed by this car.

## 5. Car 4 - the server (Go)

Consumes: car 3's fold package, the schemas. Exposes: `GET /`, `GET /api/snapshot`,
`GET /api/stream` per the wire schema - nothing else.

- **4.1** `board/store`: StoreAdapter - directory scan, per-record double-decode
  (typed + `map[string]json.RawMessage` key-diff, D17/FACT3), quarantine-with-
  disclosure, unknown-field board conditions. Red-first against fixture stores:
  empty-store (honest-empty), all-quarantined, mid-write partial JSON, unknown-field
  record, future-dated `at`.
- **4.2** `board/assemble`: Assembler - fold-winner→raw-manifest join (§5.3's
  two-step, never re-selecting latest), trains/gates/dispatches/yard-inventory
  surfaces, `declaredNotObserved`, YB-14 `manifest-membership-collision` (red-first:
  two-manifests fixture), DR3-3 `subject-namespace-collision` condition, vocabulary
  defs loading (one bad row quarantined, empty = ONE fault via the fold).
- **4.3** `board/server`: poll loop (skip-not-queue), change detection (seq/asOf
  excluded, `ageBucketMs` included, seq assigned after), SSE (event name from the
  schema constant, heartbeat comments), YB-15 demoMode (fixture store flag → banner
  field only; red-first: staleness fires on stale demo data), `storePathDisplay`
  normalisation. Serialisation parity: snapshot and stream share ONE marshal path,
  byte-identity test.
- **4.4** SAME-COMMIT living contracts: `docs/contracts/state-ledger.md` rows
  (old→delta→new arithmetic) and the five gating-matrix truth surfaces + any
  degradation row from §0b's branch.

## 6. Car 5 - the view + README (the walking skeleton closes)

Consumes: the wire schema and `/api/*` only - never the store, never the fold.

- **5.1** `board/web/`: vanilla ESM JS, no build step (D19). Composition engine as a
  PURE module (`compose.js`): the YB-6 THREE-AXIS matrix test (position register x
  freshness kind x capability present/absent) runs in Node (`node --test`, stdlib
  runner - no framework), red-first with the two load-bearing cases first.
- **5.2** Wire validation per §0b's outcome: the vendored ESM validator against THE
  schema file, or the DISCLOSED structural-check degradation. Payload-discard-keeps-
  last-render-marked behavior red-first.
- **5.3** The board itself: five lanes always rendered (completeness guards: registry
  pin test, lane count in chrome), detector rendering (verbatim, hot), disconnect
  chrome (two missed heartbeats), seq ordering, server-issued age only. **Visual
  authority, ranked (owner doctrine, 2026-07-23: mocks are DIRECTION, not contract):**
  the reviewed brief (`docs/design/2026-07-23-ui-mockup-brief.md`) and the composition
  rules BIND - three registers, verbatim words, honesty chrome, dark/bagged dignity;
  the mockup project (2b track schematic + 1b Solari-board dispatches, the owner's
  chosen merge) STEERS - the car builds to the contracts and steers by the direction,
  notes any deviation-for-cause from direction in its report (a note, never an
  honest-stop), and any direction-vs-contract conflict lands on issue #1 as design
  feedback with contract winning meanwhile (worked example: the mocks' stale-in-amber
  vs the design's stale=needs-attention).
- **5.4** README + quickstart: the "no adapters ship yet" line dies; local-only,
  unauthenticated stated; a stranger-runnable quickstart (`cd board && go run
  ./server` or equivalent - exact command truth-checked by the reviewer per the doc
  sentence check). SAME COMMIT as the capability landing.
- **5.5** The first live serve IS the §0b browser observation and the walking
  skeleton's acceptance: board up, real store, all five lanes, honest day-one state.
  Screenshot lands in the report (path-normalised).

## 7. Conductor handbacks (inside existing dispatches, not extra cars)

- The `train:board-v0` manifest intent record - written when THIS train's cars start
  rolling (the board's first real train data is the train building the board).
- The `train:pre-harness-era` coarse backfill manifest (spec §8, Q6 ruling).
- Car 1's live CI watched-red + car 3's YB-9 divergence injection at merge (run URLs
  recorded in the train's closing report).
- Index reconciles + Watch-CI after every merge (standing practice).
- The stale-color register ruling (issue #1 comment, pending owner) folds into Car
  5's brief before it rolls - `stale` renders in the needs-attention color unless the
  owner rules otherwise.

## 8. Interface blocks (each car sees only its own)

| Boundary | Contract | Pinned by |
|---|---|---|
| store → fold | record schemas + fold vectors | `schema/vectors/fold/` (both runners) |
| fold → assembler | the fold output shape | the same vectors (car 3's package API returns exactly it) |
| assembler/server → view | `schema/yard-snapshot.schema.json` (+ payload $defs, SSE const) | schema validation both sides + parity test |
| view → human | the brief + composition rules | YB-6 matrix + the mockup direction |

## 9. Cost line (owner approval required BEFORE Car 1 rolls)

| Item | Count | Model |
|---|---|---|
| Plan review (this document) | 1 round + re-rounds as earned | Opus |
| Cars | 5 | Sonnet |
| Car reviews | 5 (+ delta rounds as earned) | Opus |
| Conductor handbacks | in-line | - |

Size class: **large** (the largest train yet - it builds the product). Sequential
consist means wall-clock is the sum of car+review units; with today's observed unit
time (~25-40 min per car+review), first pixels tonight remains plausible if rounds
stay low. Every car and its review are one unit - no car starts whose review will not
also fit.

## 10. Suite baselines at base `c4daeae`

`Invoke-Pester ./scripts/tests`: **175/175**. `./scripts/probes`: **12/12** (env with
`sh` on PATH; the PowerShell-tool env gap is logged friction, not a defect). Go: no
module exists yet - Car 1 creates it; after Car 1 every car states its `go test`
counts alongside Pester.
