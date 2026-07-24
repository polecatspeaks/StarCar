<!-- starcar-integrity: sha256=a283b3c9360ff0ac9ce6c9663651d8c401c416c2848ce8b8f05f0384e79c5ae8 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Yard board Car 3 delta round 2: APPROVE - both fold bodies agree on the reviewer's reconstructed divergence case; merge clear

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (adversarial delta, Opus, same reviewer fix-cycle)
Round: 2
Target: `car/board-car3 at 98e22c0 (10 commits)`
Base reviewed: `98e22c081e9f887eb19697c5c927a95d5fbaeaa2`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `ae55c4d7156cb410b`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `98e22c081e9f887eb19697c5c927a95d5fbaeaa2` |

| Dispatch, the locator within the session | `ae55c4d7156cb410b` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 98e22c081e9f887eb19697c5c927a95d5fbaeaa2
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Complete. `budget` is a valid schema property (type number, optional, line 43-45) - the producer stamp writes schema-valid records, and the schema description ("the shop default applies at FOLD time... the default is the detector's to apply") remains true (the producer's write-time freeze is additive defense-in-depth reading the same single config source, not a Law 6 second copy). No regression. Here is my delta verdict.

---

# DELTA RE-REVIEW (round 2) - Car 3 (the Fold Car), yard-board train

## VERDICT: APPROVE. Merge is clear.

Base verified: worktree HEAD = `98e22c081e9f887eb19697c5c927a95d5fbaeaa2`, clean before and after all fault-injection (all temp Go tests removed, three vector-adjacent scratch stores deleted, `git status` empty). Delta scope `330ddf9..98e22c0` (5 fix commits). Round count 2, no rotation trigger. This is the same-agent delta reviewer from round 1; I hold the round-1 history (1 Major C3R-1, 2 Minor C3R-2/C3R-3).

**Convergence ruling: this is convergence, not swirl.** Round 1 was 1 Major + 2 Minor to REJECT. Round 2: the Major is fixed and empirically re-verified, both Minors are resolved, and I fresh-eyed the entire diff for regressions and found none. Findings went 1M+2m to 0-and-0. Major count fell to zero, findings did not cluster or relocate, and no fix created a new defect (the swirl triggers). No new findings (C3R2-n) opened.

---

## THE THREE FINDINGS, WALKED AGAINST THE FIX

### C3R-1 (Major, round 1) - FIXED, empirically re-verified

I RECONSTRUCTED my own round-1 divergence case (budget-less dispatched, `at`=2026-07-20T00:00:00Z, now=2026-07-23T00:00:00Z, elapsed 259200s, no successor) and ran BOTH bodies with the shop default supplied:

- pwsh (`-DefaultsPath` temp file, 1800): `state="overdue"`, `budget_seconds=1800.0`, `budget_source="default"`
- Go (`WithDefaultBudgetSeconds(1800)`): `state="overdue"`, `budget_seconds=1800`, `budget_source="default"`

They now AGREE on all three fields (the 1800.0/1800 difference is the documented float64 round-trip). The round-1 divergence is closed.

- **New vector `budget-less-past-injected-default.json`** pins exactly this (overdue / 1800 / budget_source=default), OBSERVED against the fixed detector. Passes by name in both runners.
- **`input.defaults.dispatch_budget_seconds`** is in the README vector shape AND runner contract (step 2 spells out the pwsh `-DefaultsPath` temp file and the Go option, "never the real config file"), landed same-commit fcc9949.
- **Both runners thread it:** pwsh Detector runner writes `input.defaults` to a temp `defaults.json` and passes `-DefaultsPath`; the Go vector-runner reads optional `input.defaults` and threads `WithDefaultBudgetSeconds`.
- **Functional-options pattern (Go practitioner ruling):** `Fold(records, vocab, now, opts ...Option)` with `WithDefaultBudgetSeconds` returning `Option func(*foldOptions)` is the canonical Rob-Pike functional-options idiom. It keeps the positional signature `Fold(records, vocab, now)` byte-identical for the many callers with no default (avoiding a nil-pointer fourth-param footgun), is extensible, and reads clearly. Sound choice.
- **budget_source posture identical and vector-pinned:** both bodies set `budget_source` ("record" | "default") ONLY when `budget_seconds` is non-null (Go output.go:27-29 gated on `BudgetSeconds != nil`; pwsh sets it inside the `if ($null -ne $budget)` block). README pins it in deep-equal. Never a phantom source for a null budget.
- **Three regenerated budget vectors** (`dispatched-past-budget-overdue`, `dispatched-within-budget-stays-dispatched`, `record-budget-overrides-shop-default`) all carry `budget_source: "record"`, remain OBSERVED with an honest "then REGENERATED at the fix-cycle commit adding budget_source" note. I independently reproduced `record-budget-overrides` against the fixed detector: dispatched / 99999.0 / budget_source=record - matches expected. The record-override note correctly explains source is "record" even when the value exceeds what the default would have been.
- **Producer stamp (e4b4b98):** `Produce-Artifact.ps1` stamps `budget` (the shop default, or `-DefaultsPath` override) on every new dispatched record, frozen at dispatch time so a later policy change never rewrites an in-flight liveness verdict; degrades (no budget field + a raised fault) on read failure rather than blocking the write; `budget` is a valid schema property (starcar-artifact.schema.json:43-45), so the stamp is schema-valid. `Producer.Tests.ps1` 14/14 with three meaningful red-first budget cases (injected 4321; real config default; read-failure degrades with exit 0 + null budget + a fault naming "budget"). The write-time stamp and the fold-time fallback both read one config source - defense-in-depth, not a Law 6 second copy.
- **Issue #23 (deferred brief-override):** VALID deferral. I verified the premise against the real fixture `launch-car.json`: `tool_input` = {description, model, prompt, subagent_type}, `tool_response` = {agentId, status, resolvedModel, isAsync}; no duration/patience/estimate/deadline field anywhere. The car correctly refused to invent a brittle free-text parse. The deferral has a durable landing (issue, area:tooling), a stated trigger (a structured field becomes available), and does not block anything.

### C3R-2 (Minor, round 1) - FIXED

Both tie-breaking `Sort-Object` calls gained `-Stable` (Detect-Dispatches.ps1 dispatch-side and intent-side), making the pwsh ordering guarantee explicit and equal to Go's `sort.SliceStable`. New vector `exact-tie-preserves-input-order.json` (two same-(subject,kind,instant) returned records, outcomes FIRST/SECOND) pins input-order-wins (winner outcome=FIRST, the other in superseded), OBSERVED against the fixed `-Stable` detector, and PASSES by name in both runners.

### C3R-3 (Minor, round 1) - CARRIED as a genuine binding carrier (issue #24)

The lenient `parseInstant` epoch-degrade stays (Fold's signature has no error channel), but the obligation is now issue #24, and I hold it to my round-1 standard ("a package-doc note is NOT a carrier"). #24 clears that bar: it is specific (names unparseable/malformed/**zoneless** "at" - the exact case `time.Parse(RFC3339)` rejects), testable (requirement #2 mandates a red-first test that a malformed-at fixture is quarantined and Fold is never called with it), addressed to a rung (Car 4 task 4.1, area:server label), and names its closure condition (or change Fold's signature to return an error). It is a tracked issue with mechanical requirements, not vigilance dressed as a ticket. I confirmed its premise is sound and necessary: `at` is `format: date-time`, but JSON Schema `format` is annotation-only by default in draft 2020-12, so Car 4's adapter cannot lean on schema validation alone to reject a zoneless `at` - it must explicitly quarantine, exactly as #24 requires. The parseInstant doc comment now points at #24 rather than standing as its own carrier.

---

## FULL LADDER AT HEAD (98e22c0), all observed by me

- Pester `scripts/tests`: **222/222** passed, 0 failed, 0 inconclusive, 0 skipped.
- `Producer.Tests.ps1`: **14/14**. `Detector.Tests.ps1` (vector runner): **21/21** (17 vectors + 4 imperative).
- `go test -count=1` board: board **6/6**; fold **3 loader + 17 vector** subtests all PASS. `go vet ./...` clean; `gofmt -l board/` empty.
- Real-store detector: faults=0, discoveries=0, dispatches=49, intents=1 - unchanged from round 1. `budget_source` correctly absent from all 49: every subject resolves to a `returned` winner, and the conditional shape emits `budget_seconds`/`budget_source` ONLY on a `dispatched` winner, so returned entries carry no liveness block at all. The coordinator's self-correction is right, and I verified it (all 49 states = returned; 0 entries carry `budget_source`; 49 returned entries carry no `budget_seconds` key).
- node probe: out of this diff's scope (no node files touched; the repo's probes under `scripts/probes/go` are Go-based) - same disposition as round 1.

## DOC CHECK

- README vector table: **17 rows on disk = 17 table rows = 17 fold subtests** (counted from disk). Table updated same-commit as the vectors. The migration note now correctly documents THREE carved cases (shop-default reversed) plus an explicit "Reversal (spec Amendment 2, issue #22, C3R-1)" section acknowledging the false premise. `input.defaults` and `budget_source` folded into the runner contract same-commit.
- The old carved imperative test is KEPT but honestly re-scoped to the genuinely-environmental remainder (does an unset `-DefaultsPath` resolve to the real config file) - correct instrument-matching: the semantic moved to a vector, the IO detail stayed imperative.
- fold.go / loaders.go / Detect-Dispatches.ps1 docs all reverse the false premise and supersede the prior scope notes; loaders.go precisely preserves the correct distinction ("reading the file is still IO, Amendment 2 only reclassified applying the value").

## NOTE (sub-threshold, not a finding)

The coordinator's brief stated "fold 3+16"; the observed count is 3 loader + **17** vector subtests (two new vectors this cycle). As in round 1 (brief said 14, actual 15), the discrepancy is a brief-expectation undercount, not a defect - the doc-map is internally consistent from disk (17/17/17).

## GUARD CHECK - remaining conductor handback at merge

The LIVE cross-verifier divergence injection stays deferred to the conductor at merge (ci.yml D18 step, D10 "not done when green"): a one-character edit to a scratch vector copy, observed RED on both runners, reverted byte-identical, recorded in the train's closing report - now over the richer 17-vector set (including `budget-less-past-injected-default` and `exact-tie-preserves-input-order`). Issues #23 (trigger-gated) and #24 (binding on Car 4 task 4.1) remain open as tracked carriers, not merge blockers.

## CONSTITUTION CHECK

- **Law 6 (vectors as single authority):** now HONORED - the shop-default fold semantic is pinned by a vector and both bodies thread the same supplied default; the producer stamp and fold fallback read one config source (defense-in-depth, not a second copy of state).
- **Law 4 (nothing silently lost):** HONORED - 3 carved cases still imperative, the 4th re-scoped and kept, 17 vectors green.
- **Law 1 (no confident falsehood on a surface):** the round-1 board-lies-about-liveness path is closed; the malformed-at residual is now a schema-invalid-only case carried to Car 4 with a red-first quarantine requirement.
- **Carrier rule:** HONORED - the two residual obligations cross to their rungs as specific, testable, labeled issues (#23, #24), reversing the round-1 package-doc-only carrier that earned the Major.

```starcar-artifact
outcome: APPROVE
findings: Zero new findings. All three round-1 findings resolved. C3R-1 (Major) FIXED and empirically re-verified - I reconstructed my round-1 divergence case (budget-less dispatched record, elapsed 259200s past an injected 1800s default, no successor) and ran both fold bodies; they now AGREE (state=overdue, budget_seconds=1800, budget_source=default) where round 1 diverged (pwsh overdue/1800 vs Go dispatched/null). The fix threads the shop default via the canonical Go functional-options idiom WithDefaultBudgetSeconds, keeping Fold's positional signature stable; input.defaults is in the README runner contract same-commit; both runners thread it; budget_source is present only alongside non-null budget_seconds, identical in both bodies and vector-pinned; the new vector budget-less-past-injected-default pins the exact scenario OBSERVED and passes both runners; three regenerated budget vectors carry budget_source=record OBSERVED; the producer stamps budget at dispatch time frozen into history with a read-failure degrade path (Producer.Tests 14/14). Issue 23 (deferred brief-override) is a valid deferral - I verified the real launch payload carries no duration or patience field to override from. C3R-2 (Minor) FIXED - Stable on both pwsh sorts matching Go SliceStable, new exact-tie vector OBSERVED passing both runners. C3R-3 (Minor) CARRIED as issue 24, which clears my round-1 standard that a package-doc note is not a carrier - it is specific (names zoneless/malformed at), testable (red-first quarantine requirement), addressed to Car 4 task 4.1 with area:server label, and names its closure condition; its premise is sound because JSON Schema format is annotation-only by default so the adapter must quarantine explicitly. Full ladder at HEAD 98e22c0: Pester scripts/tests 222/222 0 inconclusive, Producer 14/14, Detector vector runner 21/21, go test -count=1 board 6/6 and fold 3 loader plus 17 vector, go vet clean, gofmt empty, real-store detector 0 faults 0 discoveries 49 dispatches 1 intent with budget_source correctly absent because all 49 resolve to returned winners which carry no liveness block. Doc-map consistent 17 disk equals 17 table equals 17 subtests, updated same-commit. Fresh-eyed the whole diff 330ddf9 to 98e22c0 for regressions and found none; budget is a valid schema property so the producer stamp is schema-valid. This is convergence not swirl - findings fell from 1 Major plus 2 Minor to zero with no new defects introduced.
abstract: Car 3 fix cycle round 2 is APPROVE, merge clear. The round-1 Major - two fold bodies diverging on a budget-less dispatched record because the Go port omitted the shop-default budget semantic, invisibly to the cross-verifier - is fixed: the carve-out false premise is reversed in spec/plan/docs, the shop default is threaded into the Go fold via a functional option and pinned by a new language-neutral vector with an input.defaults field, and I empirically re-ran my exact round-1 divergence case to confirm both bodies now render overdue/1800/default identically. A new budget_source field discloses record vs default provenance identically in both bodies. The producer now stamps budget at dispatch time, freezing the liveness promise into history. Both round-1 Minors are resolved - a -Stable tie-break with its own vector, and the malformed-at divergence carried to Car 4 as a specific testable tracked issue that clears my round-1 carrier standard. The deferred brief-override is a valid trigger-gated deferral verified against the real Task payload. Every suite green at HEAD, doc-map consistent and same-commit, no regressions. Remaining conductor handback at merge is the live watched-to-fire cross-verifier divergence injection over the richer 17-vector set.
```