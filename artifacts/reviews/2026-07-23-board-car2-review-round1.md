<!-- starcar-integrity: sha256=73f8c45c5b8949052127e10bb9b1099e176edcfbd23cce5f10f7823e8eafb80d covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Yard board Car 2 review round 1: REJECT - stale self-invalidated line citations (born one commit after their own invalidation); all empirical claims verified true

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (adversarial, Opus, fresh detached worktree)
Round: 1
Target: `car/board-car2 at 233133e (5 commits)`
Base reviewed: `233133e1e2256490aa1901c028cc00fb600c25e2`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a21c8b80339f1c8fd`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `233133e1e2256490aa1901c028cc00fb600c25e2` |

| Dispatch, the locator within the session | `a21c8b80339f1c8fd` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 233133e1e2256490aa1901c028cc00fb600c25e2
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

I have completed all verifications. The worktree is clean (all fault-injections restored byte-identical; my probe scripts wrote only to scratchpad, outside the worktree). Here is my verdict.

---

## VERDICT: REJECT

One Major finding (C2R-1): stale file:line citations in two committed artifacts, invalidated by the car's own earlier commit and not updated when the citing files were authored. Under "any Major = REJECT," this gates the merge. The finding is cheap to fix; severity tracks consequence to the doc-equal-to-code standard, not fix cost.

Every empirical claim the car made was independently RUN and verified true. The defect is a citation-truth violation, exactly the class the sentence/citation check exists to catch.

---

### Claims verified (all RUN at HEAD 233133e)

1. **Suites** — all four pass as claimed:
   - Full Pester: **206/206** (0 failed) observed at 233133e.
   - Go board: **4/4** (`TestPlaceholder`, `TestPinnedJSONSchemaDependencyCompilesStoreSchema`, `TestRE2CompatiblePatterns_CatchesInjectedLookahead`, `TestRE2CompatiblePatterns_RealSchemasAllCompile`).
   - `node board/web/probe-yard-snapshot.mjs`: **PASS** (schema-compiles OK, draft 2020-12, sample-validates PASS, non-vacuity PASS).
   - `Detect-Dispatches.ps1 -StoreRoot artifacts`: **faults: 0, discoveries: 0**, exit 0.

2. **Task 2.1 red (fault-injected).** `git checkout 395aa9f -- schema/vocab/outcomes.json`, ran `Detector.Tests.ps1`: **14 passed / 1 failed**, verbatim `Expected 'outcome: done' to not be found in collection @('outcome: CONFIRM', 'outcome: done', 'outcome: done-with-findings'), but it was found.` (line 143) — the exact stated reason. Restored via `git checkout 233133e -- ...`; sha256 `368129bd...` matches, `git status` clean.

3. **Task 2.2 schema $defs vs spec YB-5** (docs/specs/2026-07-23-yard-board-spec.md:75-83), walked field-by-field:
   - `trainsPayload`: `trains[]{id,title,cars[],declaredNotObserved}` required; `cars[]` required `{subject,role,state,at}` with `gate/outcome/superseded` optional — matches spec's `gate?/outcome?/superseded?` exactly (schema :78-140).
   - `gatesPayload`: `gates[]{name,subject,outcome,at}` all required — matches spec.
   - `dispatchesPayload`: required `{subject,state,at,assigned}` + optional fold-shape fields (`outcome,superseded,elapsed_seconds,budget_seconds,spend`). Confirmed against the fold vector shape (`schema/vectors/fold/subject-partition.json`) and the detector's elapsed/budget emission (`Detect-Dispatches.ps1:185-192`). Faithful mirror + `assigned`.
   - No REQUIRED field missing or extra vs spec.
   - Fault-injected the $defs directly with Test-Json: a `cars[]` entry with `assigned` instead of `state` → **rejected** (missing required `state`); wrong-type `cars` object → rejected; non-string `declaredNotObserved` → rejected. Extra properties are ALLOWED (open `additionalProperties`) — consistent with the schema's declared Law-7 open posture; spec does not mandate closure. WirePayload nonconforming cases fail for their stated reasons.

4. **Task 2.4 register assignments vs plan's pinned table** (plan §3 task 2.4). Compared every id — **byte-exact match** across positions (4), outcomes (8), roles (3), liveness (4). Ran `BoardDefs.Tests.ps1`: 11/11. The flipped-REJECT non-vacuity case writes an actual `$TestDrive` file, re-reads it, and asserts the mismatch string matches `outcomes\.REJECT` (line 173). Coverage: forward direction only (every value/closed-set id has a def, lines 106-132) — the reverse direction (every def maps back) is NOT asserted, but the plan's RED-FIRST spec required only (a) forward, (b) closed register set, (c) pinned assignments, and current counts are exact 1:1 (outcomes.json 8 = defs 8; roles.json 3 = defs 3), so no live drift. Position/liveness def sets exactly equal the design-enumerated sets (design :165, :222). Non-blocking observation only, not a finding against the car.

5. **Task 2.5 layered manifest validation.** Ran `StoreIntegrity.Tests.ps1`: **85/85**. Confirmed the layering is real — the pre-existing per-record test validates every record against `starcar-artifact.schema.json` (:27,:68); the new context adds `starcar-manifest.schema.json` for `^train:` records. Regex matches the **subject property value** (`$subjectProp.Value -match '^train:'`, line ~104), not the filename. Both real records (`artifacts/train-board-v0/intent-20260723T134605Z.json`, `intent-20260723T141614Z.json`) pass. Ran the mandated non-vacuity proof myself: the no-manifest fixture is **rejected by the manifest schema (False)** but **accepted by the base schema (True)** — so the manifest schema is load-bearing. Regex anchoring attacked: `xtrain:foo` carrying a manifest is correctly **caught** (not matched by `^train:`); a non-train subject with a manifest is caught by `allOf[1]`.

6. **Task 2.3 Go-side.** Car touched **zero** Go files (empty `board/` diff) — "no new Go" confirmed. `yard-snapshot.schema.json` has **0 pattern keys**; no Go source references it. The Go suite never compiles the wire schema under jsonschema/v6 — but the commit message 9d53b9c does **not** claim it does. It states precisely: the RE2 test re-walks all schemas including the wire schema, no pattern keys were added so RE2 compatibility is unaffected, and "the JS validator compiles the extended schema." The claim does **not** outrun the evidence — the car split it correctly between the Go (pattern-safety) and JS (full compilation) validators. No finding.

### Sentence check
- Register values, hop 1 (plan table prose → board-defs.json data): **byte-exact**, verified. Downstream hops (Car 4 loads → wire `vocabularies` block → Car 5 renders) are correctly deferred to future cars.
- Payload $defs (spec YB-5 prose → schema $defs → WirePayload fixtures): traced field-by-field, all present with correct required/optional posture.

### Constitution check
- **Law 6** — HONORED. board-defs.json is a legitimately distinct presentational layer (label+register), not a second recognition gate; recognition values stay in outcomes.json/roles.json. The schema's own vocabularies description (:189) states defs travel on every snapshot "so no separately fetched copy can drift" — the anti-Law-6 rationale is explicit. The manifest schema layers over the base without restating it.
- **Law 7** — HONORED. A stranger's fork gets sensible defs for every recognized value; unrecognized values render by raw id via the detector path.
- **Law 1 / Law 4** — HONORED at the mechanism level: the detector runs clean (0 discoveries) after the vocab additions; done/CONFIRM no longer false-fire. Counterpoint: the C2R-1 stale citation is itself a small Law-1 confident-falsehood on an information surface.

---

### FINDINGS

**C2R-1 (MAJOR) — stale file:line citations, invalidated by the car's own commit, not updated when the citing artifacts were authored.**

- `schema/vocab/board-defs.json:2` ($comment) cites `schema/yard-snapshot.schema.json:102-112` for the vocabularies block and `schema/yard-snapshot.schema.json:104` for the raw-id/detector-path note.
- `scripts/tests/BoardDefs.Tests.ps1:4` cites `schema/yard-snapshot.schema.json:102-112`.
- Evidence: at base 395aa9f the vocabularies block WAS at :102-112 and :104 WAS the raw-id description (verified via `git show 395aa9f:...`). The car's commit 9d53b9c (task 2.2) inserted 85 lines of `$defs` above the block, moving it to **:187-196** (`"vocabularies"` at :187, `positions` at :191) and the raw-id note to **:189**. Current line :104 is `"outcome": { "type": "string" }` inside `trainsPayload.cars` — deceptively field-shaped, unrelated content. The citing artifacts were authored one commit later (ae83af3), so the citations were born stale.
- The claim the code no longer honors: "the vocabularies block is at yard-snapshot.schema.json:102-112" and ":104 is the raw-id/detector-path note." Neither is true at HEAD. This is the exact class the "documents are living — the commit that invalidates a document updates it in the same commit" law exists to catch, and a same-commit doc-check would have caught it. Car 4 is contracted to read board-defs.json to build the vocabularies emitter.
- Fix: update `:102-112` → `:187-196` and `:104` → `:189` in both files (the commit message ae83af3 carries the same stale citation as an immutable-record note). The $comment's semantic content is otherwise correct.

**Observations (non-blocking, NOT findings):**
- BoardDefs coverage is forward-only; a def for a nonexistent value would not be caught. Plan task 2.4 required only forward coverage (a) and current counts are exact 1:1, so no live drift. Recording for the reverse-coverage rider a future car may want.
- Wire $defs use open `additionalProperties` (extra properties pass validation). Consistent with the schema's deliberate Law-7 open posture; spec YB-5 does not mandate closed objects.

REJECT is a success outcome for this gate: the citation-truth check caught a real stale citation the same-commit doc discipline should have prevented. Fix-and-delta-re-review to the same car; the empirical work (all suites, all $defs, all vocab data) is sound and need not be re-derived — only the two citation coordinates.

```starcar-artifact
outcome: REJECT
findings: C2R-1 (MAJOR) stale file:line citations in schema/vocab/board-defs.json:2 and scripts/tests/BoardDefs.Tests.ps1:4 - both cite schema/yard-snapshot.schema.json:102-112 for the vocabularies block and :104 for the raw-id note; those coordinates were valid at base 395aa9f but the car's own commit 9d53b9c inserted 85 lines of $defs above the block, moving it to :187-196 and the raw-id note to :189, and the citing artifacts were authored one commit later (ae83af3) with the stale numbers, so following :102-112/:104 lands in trainsPayload.cars (unrelated, deceptively field-shaped content). Fix: update both coordinates in both files. Two non-blocking observations: BoardDefs coverage is forward-only (plan required only forward, counts exact 1:1, no live drift); wire $defs use open additionalProperties (consistent with declared Law-7 posture, spec does not mandate closure). All empirical claims verified true - Pester 206/206, Go 4/4, node probe PASS, Detect-Dispatches 0 faults 0 discoveries; task 2.1 red reproduced and restored byte-identical; schema $defs match spec YB-5 field-by-field; register assignments byte-exact against the plan pinned table; StoreIntegrity 85/85 with the manifest-schema non-vacuity proven (no-manifest rejected by manifest schema, accepted by base schema) and regex correctly anchored on the subject property; task 2.3 Go-side claim does NOT overclaim - commit 9d53b9c correctly attributes full compilation to the JS validator and Go-side only to RE2 pattern re-walking with zero new patterns.
abstract: Adversarial sentence-check review of Car 2 (yard-board train, commits 6863480..233133e vs base 395aa9f) at worktree HEAD 233133e. All four claimed suites and every substantive claim (detector vocab red, wire $defs vs spec YB-5, pinned register table, layered manifest validation, Go-side re-validation) were independently RUN and verified true, with two fault-injections restored byte-identical and the worktree left clean. REJECT on one Major: board-defs.json and BoardDefs.Tests.ps1 carry file:line citations to the wire schema's vocabularies block that were valid at base but invalidated by the car's own $defs insertion (block moved from :102-112 to :187-196, raw-id note from :104 to :189) and not updated when the citing files were authored one commit later - a living-document / citation-truth defect the same-commit doc discipline should have prevented. Fix is two coordinate updates in two files; the empirical work is sound and need not be re-derived. Law 6, Law 7, Law 1/4 all honored at the mechanism level. REJECT is a success outcome - the citation check did its job.
```