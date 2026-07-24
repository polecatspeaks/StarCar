<!-- starcar-integrity: sha256=c1bb71bff1a0f72d9ed7a7cca50a2c6e6e39c4e069b37e6c668c7b3f5bd1c533 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Yard board plan review round 1: REJECT - 4 Major requirement-to-task holes (impossible rehome, unauthored vocab defs, unwired manifest validation, no JS CI home)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Plan review (adversarial, Opus, detached worktree, empirical re-derivation)
Round: 1
Target: `docs/plans/2026-07-23-yard-board-plan.md rev 1 at 8a15f22`
Base reviewed: `8a15f2270098a2e433a578f4f87f02705c50e224`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a01ab6d06808d2ab4`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `8a15f2270098a2e433a578f4f87f02705c50e224` |
| Entire checkpoint | `09c3c6720f7c` |
| Dispatch, the locator within the session | `a01ab6d06808d2ab4` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 8a15f2270098a2e433a578f4f87f02705c50e224
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Verification complete. Worktree clean, HEAD unchanged at `8a15f22`. All evidence gathered. Here is my verdict.

---

# ADVERSARIAL PLAN REVIEW — yard board train, plan rev 1 (PLAN GATE, ROUND 1)

**Base verified:** `git log -1 --format=%H` = `8a15f2270098a2e433a578f4f87f02705c50e224` (the plan doc's landing commit; the plan's stated cars-base is `c4daeae`, and `git diff --stat c4daeae 8a15f22` shows the plan doc is the ONLY change — the base is sound). Detached worktree at the coordinator-named commit. Read-only: nothing edited/committed/pushed in the worktree; `git status --porcelain` empty after all probes; the Go scratch module lives in `scratchpad/goval`, outside the worktree. Round history: this is round 1 (correctness only).

## VERDICT: REJECT — 4 Major, 3 Minor

The plan's empirical foundation is sound: I re-derived section 0(a) end-to-end (all three schemas compile under `santhosh-tekuri/jsonschema/v6 v6.0.2` on Go 1.26.5; all five manifest injection directions reproduce; a real store record validates; the `if/then` machinery fires) — **0 failures**. The suite baselines reconcile: **Pester 175/175** and **probes 11/12** (the single red is `post-task-probe.sh` failing on `sh`-not-on-PATH, exactly the disclosed env gap — 12/12 with `sh`). The consist order, cost line, mocks-as-direction split (5.3), and the living-contract doc mappings (spec §7) are all clean.

But four requirement→task holes block the cars, three of them the exact harness-scar class this gate exists for (a task telling a car to do something the substrate does not permit).

---

## EMPIRICAL RE-RUNS

- **Section 0(a) Go validator (attack #4), reproduced in `scratchpad/goval` with v6.0.2 pinned, Go 1.26.5:**
  ```
  ALL THREE SCHEMAS COMPILED OK
  [OK] 1 good manifest                          got=true  want=true
  [OK] 2 train: intent WITHOUT manifest         got=false want=false
  [OK] 3 non-train record WITH manifest         got=false want=false
  [OK] 4 plain held-style intent (non-train)    got=true  want=true
  [OK] 5 bad charclass train subject            got=false want=false
  [OK] real store record validates against base schema
  [OK] returned-missing-outcome correctly FAILS (if/then works)
  RESULT: 0 failure(s)
  ```
  The section-0(a) GREEN claim and the v6.0.2 pin are HONEST. (The all-compile result also re-confirms the RE2 wall is gone — Go's RE2 rejects lookahead at load, so a successful compile of all three is the RE2 proof.)
- **Pester (attack #3):** `Invoke-Pester ./scripts/tests` → **Passed=175 Failed=0 Total=175** at `8a15f22`, observed by me. Matches §10.
- **Probes:** `./scripts/probes` → **Passed=11 Failed=1**; the failure is `one probe-hook append (.claude/hooks/post-task-probe.sh)` — `'sh' is not recognized`; `Get-Command sh` = False in this env. Consistent with §10's disclosure. Not a defect.

---

## FINDINGS

### PB-1 (MAJOR) — Task 3.1 is not executable: at least three `Detector.Tests.ps1` cases cannot be expressed as declarative fixtures under the landed runner contract

Task 3.1 orders: *"Rehome the existing `Detector.Tests.ps1` imperative cases as declarative fixtures in `schema/vectors/fold/*.json` and convert the Pester suite to a fixture-driven RUNNER … PROOF: the same cases green before and after, counts stated."* The runner contract (`schema/vectors/README.md:29-45`) materialises only `input.records`, `input.vocab`, `input.now`, and deep-equals `faults`/`discoveries`/`dispatches`/`intents` — with **`tier` explicitly excluded from comparison** (README:43). Reading `Detector.Tests.ps1` against that contract, three cases cannot become fixtures:

- **`Detector.Tests.ps1:140-146`** ("an unreadable vocabulary directory is ONE fault") passes `-VocabDir` a **nonexistent path**. The vector `input.vocab` object can only express *present* vocab files; there is no representation for "the directory is missing." And the emitted fault — `"vocab: could not read recognition vocabulary files from '$VocabDir'"` (`Detect-Dispatches.ps1:75`) — **embeds the runtime path**, so it can never be byte-identical across the pwsh and Go runners the deep-equal demands.
- **`Detector.Tests.ps1:148-153`** ("an unreadable defaults file is ONE fault") passes `-DefaultsPath` a nonexistent path. The runner contract has **no defaults-injection point at all**, and the fault string embeds the path (`Detect-Dispatches.ps1:63`).
- **`Detector.Tests.ps1:155-160`** ("tier reported truthfully as tier-1-only") asserts on `tier`, which the runner contract **excludes from comparison** (README:43). A vector cannot pin it.

(A fourth, `Detector.Tests.ps1:102-109` "falls back to the shop default," depends on the `1800` from `config/harness-defaults.json`, which the runner contract does not inject — borderline, listed for the conductor.)

A Sonnet car executing 3.1 literally hits a wall: it cannot make these vectors, so it either silently drops the cases (Law 4 loss, and "the same cases green before and after, counts stated" becomes false as the count falls) or honest-stops. The plan must carve out the non-rehomable cases explicitly — they remain imperative pwsh tests (they are pwsh-IO / environmental behaviours, not language-neutral fold semantics) — and scope the before/after proof to the rehomable subset. *Note for the conductor: the root over-breadth is inherited from spec YB-10 ("the existing … imperative cases migrate … as declarative fixtures") and design Q8; the plan is the rung that must resolve it for the cars, and does not.*

### PB-2 (MAJOR) — No task authors the `vocabularies` block content the wire schema requires on every snapshot; positions and liveness have no source at all

`yard-snapshot.schema.json:102-111` makes `vocabularies` **required**, with **required** sub-arrays `positions`, `outcomes`, `roles`, `liveness`, each an array of `vocabDef` = **required** `{id, label, register}` (`:15-23`). The server (Car 4) must emit this to produce a schema-valid snapshot. But:

- `schema/vocab/` holds only `kinds.json`, `outcomes.json`, `roles.json`, each shaped `{"values":[...]}` — **bare strings, no `label`, no `register`** (confirmed by reading both files). There is **no `positions` source and no `liveness` source anywhere** at base.
- The only task that touches this is 4.2: *"vocabulary defs loading (one bad row quarantined, empty = ONE fault via the fold)"* — which presumes a source file of `{id,label,register}` rows that **does not exist and is created by no task**, and conflates the fold's recognition-values path with the wire's presentational-defs path (the schema itself distinguishes them: *"Recognition VALUES stay owned by `schema/vocab/*.json`; these defs add label+register presentation"*, `:104`).

`register` is **the one closed severity taxonomy** (`:11-14`) and drives composition Rule 1 (design §5.2: a lane's rendered register is the most-severe of position/freshness/capability; an unrecognised position contributes `needs-attention`). If the position defs are absent or wrong, every lane resolves hot and the three-register glance language collapses. Crucially, **the YB-6 matrix test does not guard this**: it enumerates *"every position register × every freshness kind × capability"* — it tests the composition function *given* registers, never whether a given position's register assignment is correct. So a Sonnet car must invent both the missing values (positions, liveness) and their load-bearing register assignments, unguided and unguarded. The plan must name the source artifact(s), assign the authoring task, and pin each position/liveness `register`.

### PB-3 (MAJOR) — YB-1's enforcement clause ("CI's StoreIntegrity layer runs the manifest schema in addition to the base") has no task

Spec YB-1: *"Store validators (CI's `StoreIntegrity` layer) run this schema IN ADDITION to the base record schema."* Evidence the requirement is unmet and untasked:

- `grep -rl starcar-manifest scripts/ .github/` returns **nothing** — the manifest schema is wired into no validator or CI step.
- `StoreIntegrity.Tests.ps1:27` hardcodes a single `SchemaPath = …/starcar-artifact.schema.json` and validates every record against **that schema only**. A `train:`-prefixed `intent` with **no `manifest` key** passes it today; YB-1 says it must fail.
- No plan task wires `starcar-manifest.schema.json` into the store-validation path. This bites within THIS train: §7's conductor handbacks WRITE real manifest records (`train:board-v0`, the `train:pre-harness-era` backfill), and they will land checked against the base schema only — a malformed manifest (missing `manifest`, a member without `role`) reaches the board unvalidated, contradicting YB-1.

Add a task (naturally Car 2, alongside the schema/vocab work, or Car 1's CI leg) that runs `starcar-manifest.schema.json` against every record whose subject matches `^train:`, red-first (a malformed-manifest fixture fails; a good one passes). *Also inherited: spec §7's "documents touched" table omits `StoreIntegrity.Tests.ps1`, so the carrier dropped it one rung up; the plan is where it must be restored.*

### PB-4 (MAJOR) — The JS/Node tests have no CI leg; a load-bearing red-first suite would run car-local only (verification-honesty / D10)

The plan wires **Go** into CI explicitly (1.2: `go vet` + `go test` in `board/`, both matrix legs) but wires **no runner for the JavaScript tests**:

- 5.1's **YB-6 three-axis matrix** — a load-bearing red-first correctness test (SB-8/YB-6, two cases red against partial implementations) — "runs in Node (`node --test`)". No task adds a `node --test` step to `ci.yml`.
- 5.2's wire-validation test (vendored ESM validator or the disclosed structural degradation) is likewise Node-run with no CI home.
- §10's baselines enumerate only Pester and `go test`; `node` appears nowhere. `ci.yml` runs Pester over `scripts/tests` + `scripts/probes` and (after 1.2) `go test` in `board/` — nothing executes `board/web/`'s tests.

Under D10 and verification honesty (*"verified means the pipeline that ships it went green, not that your local run passed"*), a load-bearing test with no pipeline home is not verified. Secondarily, **Node is an undisclosed toolchain dependency**: 1.6 adds a `docs/setup.md` Go-toolchain row but no Node row, and 1.5 + 5.1 + 5.2 all require Node while the design's "no build step" (D19) is about the *browser*, not the tests — a Law 7 gap for a contributor. Add a `node --test` CI step (GitHub runners preinstall Node, so the step is the deliverable) and a `setup.md` Node row.

### PB-5 (MINOR) — Task 3.1's "EXPECTED failure until 3.2" has no stated honesty mechanism

3.1 deliberately lands `empty-vocab-one-fault` **red** (the fix arrives in 3.2), and says *"the runner marks it an EXPECTED failure until 3.2, explicitly, so the suite is honest."* It does not say HOW the runner distinguishes this sanctioned red from a regression without either (a) failing on Car 3's intermediate commit or (b) going vacuously green (which would defeat the red-first pin). Specify the marker (e.g. Pester `-Skip`/`Set-ItResult -Inconclusive` keyed to the vector, removed in 3.2), or fold the vector's addition into 3.2's fix commit as ordinary red-first TDD.

### PB-6 (MINOR) — Handoff item 2's RE2 probe silently relocated from `scripts/probes/go/` to `board/`

Round-2 handoff item 2 explicitly says *"build the Go pattern-compile probe under `scripts/probes/go/` (co-located with the existing FACT probes)."* Plan 1.3 places it *"a Go test in `board/`"* while citing that same item — a carrier drift (the fold that looks folded). The relocation is in fact *defensible*: `scripts/probes/go/{json-facts,sse-facts}/main.go` are standalone `package main` files with **no `go.mod` and no CI invocation** (confirmed — the repo has no `go.mod` at base), so a probe co-located there would inherit non-execution, whereas `board/` is CI-run via 1.2. But the plan must DISCLOSE the deviation and its rationale, and state how a `board/` test reaches the repo-root `schema/*.schema.json` patterns across the module boundary.

### PB-7 (MINOR) — YB-4's client-side SSE-constant assertion is untasked

YB-4: *"server writer AND client subscriber each carry a test asserting against the schema's constant."* Plan 4.3 covers the server (*"event name from the schema constant"*); no Car 5 task (5.1-5.5) names the client-side test asserting the subscriber reads `$defs.sseEventName.const` rather than a hardcoded `"yard"`. Fold it into 5.3.

---

## REQUIREMENT → TASK WALK

| Req | Substance | Plan task(s) | Disposition |
|---|---|---|---|
| YB-1 | Manifest contract + **CI StoreIntegrity runs manifest schema** | schema landed; §0a validates; **no StoreIntegrity wiring** | **HOLE — PB-3** |
| YB-2 | `roles.json` = car/reviewer/gate | landed at base (verified) | PRESENT (no task needed) |
| YB-3 | `outcomes.json` += done/CONFIRM/done-with-findings + same-commit detector test | 2.1 | PRESENT |
| YB-4 | Wire shape owner; SSE const test **both sides** | 4.3 (server); client side **untasked** | PARTIAL — PB-7 |
| YB-5 | Lane payload `$defs` red-first | 2.2 | PRESENT |
| YB-6 | Three-axis composition matrix, red-first | 5.1 (but **no CI leg** — PB-4) | PARTIAL — PB-4 |
| YB-7 | Go fold conforms to vectors | 3.3 | PRESENT |
| YB-8 | empty-vocab one-fault detector fix, red-first | 3.2 | PRESENT (marker gap PB-5) |
| YB-9 | D18 cross-verifier real CI job, watched-to-fire | 3.4 + §7 handback | PRESENT |
| YB-10 | Rehome `Detector.Tests.ps1` as fixtures | 3.1 | **NOT EXECUTABLE — PB-1** |
| YB-11 | Go + JS blocking validators; RE2 standing rule + probe | §0a/§0b, 1.3, 1.5, 5.2 | PRESENT (probe loc PB-6; JS CI PB-4) |
| YB-12 | Server behaviours red-first | 4.3 | PRESENT |
| YB-13 | Store-read double-decode, quarantine, DR3-3 collision, §6 rows | 4.1 + 4.2 | PRESENT |
| YB-14 | membership-collision, two-manifests fixture red-first | 4.2 | PRESENT |
| YB-15 | demoMode banner + staleness-still-fires test | 4.3 | PRESENT |
| Handoff 1 | Go + JS blocking tests | §0a done; §0b deferred to Car 1/5 (disclosed) | PRESENT |
| Handoff 2 | RE2 pattern probe **under `scripts/probes/go/`**, wired to red | 1.3 (relocated to `board/`, undisclosed) | DRIFTED — PB-6 |
| Handoff 3 | YB-9 watched-to-fire | 3.4 + §7 | PRESENT |
| Handoff 4 | Five-car split, D10 order | §1-§6 | PRESENT |
| Handoff 5 | Living-contract restatements (ledger, matrix, README, setup, design amendment) | 4.4, 5.4, 1.6; design §12b landed | PRESENT |

Also verified per the interface-block attack: Car 4's assembler needs only the landed schema (`$defs` + spec YB-5), which is in its base by the sequential consist — no cross-car interface disagreement there. Car 1's `board` CI step is additive and does not collide with the #20-scoped staleness gate (`ci.yml:167-169`'s `if:` is untouched). The `vocabularies`-block gap is PB-2, not an interface-table omission per se — it is an *authoring* hole within Car 4.

## CONVERGENCE NOTE (round 1)

Round 1 — correctness only, no series yet. For the conductor's series-keeping: the four Majors cluster at two seams — the fold/vector rehome (PB-1) and the wire/server contract surface (PB-2, PB-3, PB-4). PB-1 and PB-3 have roots one rung up (spec YB-10 breadth; spec §7 omission of StoreIntegrity), which is worth a glance at whether a small spec touch-up should accompany the plan fix, but all four are resolvable at the plan rung and none require re-opening the design.

## CONSTITUTION CHECK

| Law / rule | Verdict | Evidence |
|---|---|---|
| **Match the instrument** | Honored by the plan | Formats stay in schemas/vectors; §0a's blocking test is executable and I re-ran it (0 failures). |
| **Law 4 (nothing silently lost)** | At risk — PB-1 | 3.1 as written drives silent coverage loss (3 dropped cases) or a false "same cases green" claim. |
| **Law 1 (truth) / Law 3 (glance)** | At risk — PB-2 | Unauthored/unguarded `register` assignments corrupt the severity glance language; a board with no position defs renders all-hot. |
| **YB-1 contract enforcement** | Not honored — PB-3 | Manifest schema wired into no validator; conductor-written manifests land unchecked. |
| **Verification honesty / D10** | Not honored — PB-4 | JS load-bearing tests have no pipeline home; would be car-local only. |
| **Carrier rule (no drift)** | Minor breach — PB-6 | Handoff item 2's probe location changed while citing the item. |
| **Base topology** | Honored | Plan base `c4daeae` verified; plan doc is the sole diff to `8a15f22`. |

I edited nothing, committed nothing, pushed nothing. The worktree is as I found it at `8a15f22` (`git status --porcelain` empty); the Go scratch module is in `scratchpad/goval`, outside the worktree.

```starcar-artifact
outcome: REJECT
findings: 4 Major, 3 Minor at plan round 1. PB-1 (Major): task 3.1 is not executable - at least three Detector.Tests.ps1 cases cannot become declarative fixtures under the landed schema/vectors/README.md runner contract. The unreadable-vocab-dir case (Detector.Tests.ps1:140-146) and unreadable-defaults-file case (:148-153) fault-inject nonexistent filesystem paths and emit path-bearing fault strings that can never be byte-identical across the pwsh and Go runners the deep-equal demands, and the tier case (:155-160) asserts on tier which README:43 excludes from comparison; a car executing 3.1 literally must drop coverage silently or honest-stop, and the plan carves out nothing. PB-2 (Major): no task authors the vocabularies block the wire schema requires on every snapshot (yard-snapshot.schema.json:102-111 makes positions/outcomes/roles/liveness required arrays of id+label+register) - schema/vocab holds only bare values with no label/register and no positions or liveness source at all; task 4.2 presumes a source that does not exist and register is the one closed severity taxonomy, unguarded by the YB-6 matrix which tests composition given registers not the assignments. PB-3 (Major): YB-1 requires CI StoreIntegrity to run the manifest schema in addition to the base, but grep shows starcar-manifest wired into zero scripts/CI and StoreIntegrity.Tests.ps1:27 validates against the base schema only; no task wires it, so the conductor-written train:board-v0 and backfill manifests land unvalidated this very train. PB-4 (Major): the plan wires Go into CI (1.2) but no runner for the JS tests - the load-bearing YB-6 node --test matrix (5.1) and JS validator (5.2) have no CI leg and would run car-local only, violating D10/verification-honesty, and Node is undisclosed in setup.md (Law 7). PB-5/6/7 (Minor): 3.1's expected-failure-until-3.2 marker mechanism unspecified; the RE2 probe silently relocated from handoff item 2's scripts/probes/go/ to board/ (defensible since scripts/probes/go has no go.mod or CI wiring, but undisclosed); YB-4's client-side SSE-constant test untasked in Car 5. Empirical foundation is sound: I reproduced section 0(a) in a scratch Go module with jsonschema/v6 v6.0.2 on Go 1.26.5 - all three schemas compile, all five manifest injections behave, a real store record validates, if/then fires, 0 failures; Pester 175/175 and probes 11/12 (the one red is the disclosed sh-not-on-PATH gap) both reconcile with the plan.
abstract: REJECT at plan gate round 1, four Major requirement-to-task holes, all resolvable at the plan rung without reopening the design. The plan's empirical claims hold up under re-execution (Go validator section 0a reproduced 0-failure with v6.0.2 pinned; 175/175 Pester; probes 11/12 = the disclosed sh gap). Three of the four Majors are the harness-scar class this gate exists for: task 3.1 orders a rehome that the runner contract makes impossible for three cases (filesystem-fault and tier), the wire schema requires a vocabularies block (positions/outcomes/roles/liveness with load-bearing registers) that no artifact holds and no task authors, and YB-1's mandated StoreIntegrity manifest-schema validation is wired nowhere and tasked nowhere while this train writes real manifests. The fourth: the JS/Node test suite (including the load-bearing YB-6 composition matrix) has no CI home, so it would ship verified only on a car's box. Two Majors (PB-1, PB-3) trace to spec-level blind spots inherited into the plan, worth a small spec touch-up alongside the fix. Base topology verified: plan base c4daeae sound, plan doc is the sole diff to the reviewed HEAD 8a15f22, worktree left byte-identical.
```