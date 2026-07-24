<!-- starcar-integrity: sha256=6d8f95589136d637d98a3feb7f8d00cf555eed59e02c6ea15200b4d0c2f374bb covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Yard board plan delta round 2: APPROVE - all seven findings folded, both rulings issued (REJECT-nominal faithful, same-commit D10 satisfied), CARS MAY ROLL

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Plan review (adversarial delta, Opus, same reviewer fix-cycle)
Round: 2
Target: `docs/plans/2026-07-23-yard-board-plan.md rev 2 at 57b7534`
Base reviewed: `57b75349cb82f9eb8dea4b252a81fa03a6570a17`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

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
| Base commit the reviewer read (**the lookup key**) | `57b75349cb82f9eb8dea4b252a81fa03a6570a17` |
| Entire checkpoint | `b58f3d209215` |
| Dispatch, the locator within the session | `a01ab6d06808d2ab4` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 57b75349cb82f9eb8dea4b252a81fa03a6570a17
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Pester **177/177** at `57b7534` (175 baseline + 2 new StoreIntegrity cases for the two bookkeeping records, both validating and integrity-matching), worktree clean, HEAD unchanged. All checks done. Here is the delta verdict.

---

# ADVERSARIAL PLAN REVIEW — yard board, plan rev 2 (PLAN GATE, ROUND 2, delta / verify-the-fix)

**Base verified:** `git log -1 --format='%H'` = `57b75349cb82f9eb8dea4b252a81fa03a6570a17`, detached at the coordinator-named commit. Read-only: nothing edited/committed/pushed in the worktree; `git status --porcelain` empty after all probes; Go re-derivation lives in `scratchpad/goval`, outside the worktree. Same-agent delta reuse (round count 2, no rotation trigger). Round history carried: round 1 = 4 Major, 3 Minor, REJECT.

## VERDICT: APPROVE — 0 Major, 0 Minor, 0 new findings; convergence 4→0 Major, 3→0 Minor, terminal. **Cars may roll.**

All seven round-1 findings are folded in SUBSTANCE, verified against the substrate and by re-running the empirical claims — not by marker. The two spec-level blind spots (PB-1, PB-3) are resolved in BOTH documents, so no carrier contradiction survives: the plan fixes them and the spec §7b amendment refines YB-10 and restores the StoreIntegrity carrier row to match. Suite green at HEAD: **Pester 177/177** (the 175 baseline plus 2 new StoreIntegrity cases from the two bookkeeping records, both validating and integrity-matching). A fresh-eyes sweep of `git diff 8a15f22..57b7534` surfaces no new defect.

---

## THE SEVEN-FINDING DELTA WALK

| ID | Sev | Disposition | Evidence at rev 2 (verified) |
|---|---|---|---|
| **PB-1** | Major | **PRESENT (fixed), no drift** | Plan 3.1 scopes the rehome to pure-fold-semantics cases and CARVES OUT the four non-rehomable cases BY NAME with line citations — unreadable-vocab-dir (`:140-146`), unreadable-defaults (`:148-153`), tier (`:155-160`), shop-default (`:102-109`) — kept imperative; Go own-idiom equivalents assigned to 3.3; coverage arithmetic in the proof ("rehomable-case counts before and after (identical), plus the four carved-out cases still green imperatively — total coverage unchanged"). Spec §7b item 1 refines YB-10 with the identical carve-out list. **Both documents agree** — the carrier contradiction is closed. |
| **PB-2** | Major | **PRESENT (fixed)** | New task 2.4 authors `schema/vocab/board-defs.json` (positions/outcomes/roles/liveness `{id,label,register}`) with the register table PINNED in the task text, red-first on (a) every recognition value has a def, (b) register ∈ closed set, (c) load-bearing assignments including **the flipped-REJECT guard** ("a REJECT def flipped to needs-attention must fail the test by name"). Assignments checked faithful (below). |
| **PB-3** | Major | **PRESENT (fixed), no drift** | New task 2.5 wires `starcar-manifest.schema.json` into `StoreIntegrity.Tests.ps1` for `^train:` records, red-first with a TestDrive fixture (a `train:` intent WITHOUT `manifest` must be CAUGHT; well-formed passes; real store unaffected). Spec §7b item 2 adds the carrier row (owner: schema car = Car 2). I re-confirmed the red is honest: a `train:` intent with no `manifest` fails the manifest schema's first `allOf` branch (matches my round-1 Go injection direction 2, got=false). |
| **PB-4** | Major | **PRESENT (fixed)** | Plan 5.1 lands the `node --test` CI step SAME COMMIT as the first web test, both matrix legs, with a zero-test refusal guard; 1.6 adds the `docs/setup.md` Node row. **D10 ruling below.** |
| **PB-5** | Minor | **PRESENT (fixed)** | 3.1 registers `empty-vocab-one-fault` with `Set-ItResult -Inconclusive -Because 'red-on-arrival pin for 3.2 (YB-8)'`; 3.2 "removes the marker, observes the RED, then fixes to green." Exactly the mechanism prescribed. |
| **PB-6** | Minor | **PRESENT (fixed)** | 1.3 discloses the relocation with the rationale (`scripts/probes/go/` holds standalone `package main` files with no `go.mod` and no CI invocation → would inherit non-execution; `board/` is CI-run via 1.2) and states the cross-module file read (`../schema/`, "module boundaries constrain imports, not file IO" — technically accurate: Go module boundaries restrict package imports, not `os.ReadFile`). |
| **PB-7** | Minor | **PRESENT (fixed)** | 5.3 tasks the client-side test: the subscriber reads `$defs.sseEventName.const` and a `node --test` case asserts the subscription uses exactly that constant — completing YB-4's "both sides" (Car 4 owns the server half at 4.3). |

**Zero ABSENT, zero DRIFTED. No fold is words-without-substance.**

---

## THE TWO RULINGS THE COORDINATOR REQUESTED

**PB-2 register faithfulness — RULED FAITHFUL, no owner escalation needed.** I checked every assignment against the design and the brief:
- **Positions** live/bagged/dark→`nominal`, under-construction→`in-progress`: faithful. The brief is explicit that dark and bagged are honest states, not alarms — "The empty and dark states are not failure states of the design — they are the design proving it tells the truth" (`ui-mockup-brief.md:95-96`). A calm board when all is well is the brief's core aesthetic.
- **Liveness** returned→`nominal`, dispatched→`in-progress`, overdue/presumed-lost→`needs-attention`: faithful to the design's liveness gradient (overdue is the alarm; `design §5.3`/§5.6).
- **Outcomes, the one you flagged:** REJECT and honest-stop→`nominal` is **faithful and does NOT need the owner.** It is directly backed by two ratified sources: the brief — "REJECTs are normal traffic here, not emergencies — this shop treats a caught defect as a success" (`ui-mockup-brief.md:46`) — and the constitution's GUIDE STAR, which codes a REJECT at any gate and an honest stop as SUCCESS outcomes. Colouring them nominal is the correct rendering of the shop's philosophy; the verbatim word "REJECT" still renders (register governs colour, not visibility). `error`→`needs-attention` and `done-with-findings`→`in-progress` are likewise faithful. This is a strength of the fix, not a deviation.
  - *One cosmetic NOTE, non-blocking:* 2.4 cites "(design §5.2 table)" and "(design §5.6 gradient)", but the design enumerates NO register values per position/liveness — it delegates them to registry-owned data (`design §5.2:165-166`, D11). The plan is correctly AUTHORING these per PB-2's mandate; the "table/gradient" phrasing overstates the design's specificity. Substance faithful, pinned, and red-guarded — does not block approval.

**PB-4 D10 — RULED: same-commit-at-Car-5 SATISFIES D10.** Because the CI step and the web suite are born in one commit, there is never a window where web tests exist un-piped, so "verified means the pipeline that ships it went green" holds from the first web test onward. The alternative (an empty `node --test` step landed early in Car 1) would trip the zero-test refusal guard RED continuously until Car 5 — strictly worse. The zero-test guard also prevents the step from ever passing vacuously. The choice is correct.

---

## FRESH-EYES DIFF SWEEP (8a15f22..57b7534)

New defects introduced by the folds: **none found.** The diff is minimal and clean: two new store records (this review's own lifecycle — conductor bookkeeping; both validate + integrity-match, confirmed by Pester 177/177), `index.md` +2 (reconcile), my landed round-1 verdict (+191, in the record), the spec §7b amendment (+18, in scope — matches the plan), and the plan folds (+103/-19). The one non-listed change — `ui-mockup-brief.md` +12 — is a mocks-as-direction doctrine clarification inserted ABOVE the paste-line (so it never pollutes the design-tool paste) that strengthens the exact binding/steering split plan 5.3 depends on; consistent, no defect.

## CONVERGENCE RULING (round 2, explicit)

**HEALTHY AND TERMINAL. NO CAP, NO ESCALATION.** Series: **4 → 0 Major**, **3 → 0 Minor**. Walking the three swirl triggers: Majors declining strictly (4→0, the strongest counter-signal); no clustering (each finding closed at its own task/artifact, none relocated); no fix-created defects (the sweep found none — the register table is faithful, the carve-out preserves coverage with stated arithmetic, the CI-step timing is the correct one). Zero of three fire. The instrument (plan tasks + a spec amendment for the inherited blind spots) resolved in exactly one revision.

## CARS MAY ROLL — BRIEF-WRITING CAUTIONS PER CAR

Owner spend approval is recorded (plan §9, granted 2026-07-23 09:26); this plan-review APPROVE is the last gate. Cautions for the conductor when cutting briefs:

- **Car 1:** The RE2 probe reads `../schema/` from within `board/`; ensure the schema-glob root resolves the repo-root `schema/` regardless of `go test`'s working directory (the package dir). 1.4's watched-red is LOCAL (cars never push); the live CI red is your handback at merge.
- **Car 2:** Four distinct red-first deliverables (2.1 vocab+detector-test same-commit; 2.2 payload `$defs`; 2.4 `board-defs.json`; 2.5 StoreIntegrity manifest wiring). The 2.4 register assignments are PINNED — the car must NOT re-derive them, and the flipped-REJECT guard case is mandatory. 2.5's red is honest (verified).
- **Car 3 (the sharpest caution):** 3.1 carves out four cases BY NAME — the car must keep them imperative and NOT attempt to rehome them. **Lift the Go env-fault own-idiom equivalents (unreadable-vocab, unreadable-defaults) explicitly into 3.3's deliverable list** — 3.1 assigns them to 3.3 but 3.3's bullet only names vectors, and no vector or the cross-verifier (vector-only) guards them, so an under-specified brief could silently drop them. The `Set-ItResult -Inconclusive` marker at 3.1 must be REMOVED at 3.2 with the RED observed before the fix.
- **Car 4:** Loads `board-defs.json` to emit the `vocabularies` block; a value with no def renders by raw id (schema `:104`). The snapshot/stream one-marshal-path byte-identity test is load-bearing.
- **Car 5:** The `node --test` CI step lands SAME COMMIT as the first web test (5.1), not deferred. Confirm the §7 stale-color handback with the owner before Car 5 rolls — plan §7 still reads "pending owner" while 5.3 states the contract default ("stale=needs-attention, contract stands"); these are consistent (contract is the default unless the owner overrides), but the ruling should be locked into Car 5's brief. README quickstart command gets the doc sentence check at Car 5's review.

I edited nothing, committed nothing, pushed nothing. Worktree is as I found it at `57b7534` (`git status --porcelain` empty).

```starcar-artifact
outcome: APPROVE
findings: 0 Major, 0 Minor, 0 new findings at round 2. All seven round-1 findings PRESENT-fixed and verified against the substrate, none absent or drifted. PB-1 (was Major): plan 3.1 scopes the rehome to pure-fold-semantics cases and carves out the four non-rehomable cases by name with line citations (unreadable-vocab-dir 140-146, unreadable-defaults 148-153, tier 155-160, shop-default 102-109), keeps them imperative, assigns Go own-idiom equivalents to 3.3, and states coverage arithmetic; spec section 7b item 1 refines YB-10 with the identical list so both documents agree and the carrier contradiction is closed. PB-2 (was Major): new task 2.4 authors schema/vocab/board-defs.json with the register table pinned in the task text and a red-first flipped-REJECT guard; I ruled the assignments faithful - positions live/bagged/dark nominal and under-construction in-progress per the brief that dark and bagged are honest not alarm states, liveness returned nominal dispatched in-progress overdue and presumed-lost needs-attention per the design gradient, and REJECT and honest-stop nominal is explicitly backed by the brief line 46 (REJECTs are normal traffic not emergencies) and the constitution GUIDE STAR coding REJECT and honest-stop as SUCCESS outcomes, so no owner escalation is needed; one cosmetic non-blocking note that the cited design 5.2 table and 5.6 gradient enumerate no register values (the design delegates them to registry data and the plan correctly authors them). PB-3 (was Major): new task 2.5 wires starcar-manifest.schema.json into StoreIntegrity for caret-train records red-first with a TestDrive malformed-manifest fixture, spec 7b item 2 restores the carrier row, and I re-confirmed the red is honest. PB-4 (was Major): plan 5.1 lands the node --test CI step same-commit as the first web test both matrix legs with a zero-test refusal guard and 1.6 adds the setup.md Node row; I ruled same-commit-at-Car-5 satisfies D10 because step and suite are born together so tests are never car-local-only and the alternative early empty step would trip the zero-test guard red until Car 5. PB-5/6/7 (Minor) fixed: the Inconclusive marker at 3.1 removed at 3.2 with the red observed; the RE2-probe relocation disclosed with the no-go.mod/no-CI rationale and an accurate module-boundaries-constrain-imports-not-file-IO note; the client-side SSE-constant node test tasked at 5.3. Fresh-eyes sweep of 8a15f22..57b7534 found no new defect; Pester 177/177 green at HEAD (175 baseline plus 2 bookkeeping StoreIntegrity cases, both validating).
abstract: APPROVE at plan gate round 2, delta verify-the-fix, same-agent reuse. Convergence HEALTHY AND TERMINAL: 4 to 0 Major and 3 to 0 Minor, every finding closed at its own task with none relocated and no fix-created defects, zero of three swirl triggers fire, resolved in one revision. The two inherited spec-level blind spots are fixed in BOTH documents (plan plus spec section 7b amendment) so no carrier contradiction survives: YB-10's rehome scope is refined and the StoreIntegrity manifest-validation carrier row is restored. The two requested rulings: REJECT and honest-stop pinned to the nominal register is faithful to the brief and the constitution GUIDE STAR and needs no owner; same-commit-at-Car-5 for the node --test CI step genuinely satisfies D10 because the step and suite are born together. All register assignments verified faithful against the design intent and the brief with a mandatory flipped-REJECT red-first guard. Suite green at HEAD 57b7534 (Pester 177/177), worktree left byte-identical. Cars may roll on this approval with owner spend already granted; per-car brief-writing cautions issued, the sharpest being that Car 3's brief must lift the Go env-fault own-idiom equivalents explicitly into task 3.3 since no vector or the vector-only cross-verifier guards them.
```