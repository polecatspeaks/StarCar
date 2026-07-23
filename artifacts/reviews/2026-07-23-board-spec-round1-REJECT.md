<!-- starcar-integrity: sha256=28efbffaab385adb17e42d5b0761847e4301bdbbba282b75b72eb369e227bbc4 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Yard board spec review round 1: REJECT - 4 Major (RE2-incompatible lookahead, dropped Q2 ruling, undefined demoMode, undisclosed vector deviation)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Spec review (adversarial, Opus, detached worktree, empirical re-runs)
Round: 1
Target: `docs/specs/2026-07-23-yard-board-spec.md rev 1 + 4 executable artifacts at e3b6125`
Base reviewed: `e3b61259b01d4b59d078b61b8c17da51a7340d84`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `aa93fdf486b9ff91b`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `e3b61259b01d4b59d078b61b8c17da51a7340d84` |
| Entire checkpoint | `80d840b391d0` |
| Dispatch, the locator within the session | `aa93fdf486b9ff91b` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain e3b61259b01d4b59d078b61b8c17da51a7340d84
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Worktree is byte-identical (clean porcelain, HEAD unchanged); all probes ran in external temp dirs. I have complete evidence. Here is my verdict.

---

# ADVERSARIAL SPEC REVIEW — yard board, rev 1 (spec gate, ROUND 1)

**Base verified:** `git log -1 --format=%H` = `e3b61259b01d4b59d078b61b8c17da51a7340d84`, detached worktree. Read-only: nothing edited, committed, or pushed; all probes materialised into system-temp dirs outside the worktree and were removed; final `git status --porcelain` empty, HEAD unchanged.

## VERDICT: REJECT — 4 Major, 5 Minor

The spec and its executable artifacts are close, and the empirical core is sound: I re-ran every empirical claim and the two OBSERVED vectors reproduce byte-exact, the red-on-arrival vector fails exactly as described (4 false discoveries, 0 faults), all five manifest fault-injection directions pass under .NET, the freshness `oneOf` is genuinely mutually exclusive, and the store census recounts to done x5 / CONFIRM x3. But four Major defects block: a schema that the spec's own mandated Go toolchain cannot compile, an adopted-ruling obligation dropped at the handoff, a required wire field the prose never defines, and an undisclosed executable deviation from the approved design. Any Major = REJECT.

---

## EMPIRICAL VERIFICATION (I re-ran, did not trust the report)

- **Two OBSERVED vectors (4b):** materialised each vector into a temp store with `:`→`-` sanitised dirs, temp vocab dir, `-Now` injection, per the README runner contract, and ran `scripts/Detect-Dispatches.ps1`. `subject-partition.json` and `manifest-supersession.json` reproduce **deep-equal on faults/discoveries/dispatches/intents** — exact match.
- **Red-on-arrival vector (4c):** `empty-vocab-one-fault.json` — the landed detector produced `faults=[]`, `discoveries=["kind: dispatched","kind: returned","outcome: done","kind: intent"]` (4 false discoveries, 0 faults), matching the vector's stated known-wrong behavior. Its `dispatches`/`intents` blocks match; its `faults`/`discoveries` are red by construction. Confirmed.
- **Five manifest fault-injections (4a):** constructed all five record shapes from the spec's description alone (no ambiguity) and ran `Test-Json` against `starcar-manifest.schema.json`: good-manifest PASS, train-without-manifest FAIL, non-train-carrying-manifest FAIL, plain-held-intent PASS, bad-charclass FAIL — all as described.
- **Census (4d):** `done` = 5 records, `CONFIRM` = 3 records at HEAD; the detector fires discoveries on both today (neither is in `outcomes.json`). YB-3 confirmed. `done-with-findings` confirmed contract-backed at `docs/templates/car-brief.md:47-48`.
- **Wire freshness `oneOf` (5):** verified branch-exclusivity empirically — each valid kind matches exactly one branch, malformed `fresh`/`stale` fail, unknown kind fails. No overlap bug.

---

## MAJOR FINDINGS

### SB-1 (Major). The manifest schema's negative-lookahead `^(?!train:)` is RE2-incompatible; the spec's own mandated Go draft-2020-12 validator (YB-11a) cannot compile it

**Location:** `schema/starcar-manifest.schema.json:66` (`allOf[1].if.properties.subject.pattern` = `^(?!train:)`); YB-1, YB-11(a).

YB-1 makes the manifest schema a store validator ("Store validators run this schema IN ADDITION to the base record schema"). YB-11(a) mandates a plan-rung BLOCKING TEST: "a Go draft-2020-12 validator library validates the landed store schema + its vectors." The manifest schema is a landed store schema. I proved with the repo's Go toolchain that Go's `regexp` (RE2) **rejects the pattern**:

```
COMPILE FAIL  "^(?!train:)" -&gt; error parsing regexp: invalid or unsupported Perl syntax: `(?!`
COMPILE OK    "^train:[a-z0-9][a-z0-9-]*$"
```

Conformant Go schema libraries (e.g. santhosh-tekuri/jsonschema) compile `pattern` with Go regexp and error at schema-load time on this construct. So the spec ships a store-layer schema that the exact toolchain its Law-6 cross-language thesis depends on cannot load — and the spec neither discloses this as pwsh-Test-Json-only nor mandates a lookahead-free formulation. The design's whole point (D15, NO HEADERS) is one schema both languages consume. `.NET` Test-Json (ECMA lookahead) works, which is why fault-injection passed — masking the defect on the pwsh side.

**Remedy (concrete, lookahead-free, RE2-safe):** replace the second `allOf` branch's lookahead `if` with a negation of a positive pattern:
```json
{ "if": { "not": { "properties": { "subject": { "pattern": "^train:" } }, "required": ["subject"] } },
  "then": { "not": { "required": ["manifest"] } } }
```
This expresses "if subject does not start with `train:` (or is absent), then `manifest` must be absent" using only a plain anchored pattern, portable to RE2. The spec should mandate the lookahead-free form and add the manifest schema to YB-11(a)'s Go conformance set so the block-test proves it.

### SB-2 (Major). The Q2 adopted ruling — "two manifests claim one dispatch → both render + a board condition naming the collision" — is dropped; no YB carries it

**Location:** design `§6` line 340 (`[Q2, ruling adopted]`, Laws 4/6) vs spec YB-5 (line 73-74) and YB-13.

The design's approved Q2 ruling requires: a dispatch claimed by two different manifests renders in both, with a board condition naming the collision, "disclosed, never resolved by silent precedence." The spec's YB-5 handles only the *un*assigned case ("`assigned: boolean` per entry (yard inventory = unassigned)") — a dispatch in ZERO manifests. The *over*-assigned case (one dispatch in TWO manifests) and its mandatory board condition appear in no YB. YB-13's "collision condition" sits in the store-read failure-table context and maps naturally to the DR3-3 subject-in-both-fold-outputs collision (already anchored by `subject-partition.json`), not the Assembler-level Q2 membership collision. This is precisely the carrier-rule scar class (an adopted-ruling obligation evaporating at the spec handoff, Law-4/6-backed). **Remedy:** add a YB requiring the two-manifests-claim-one-dispatch board condition in the Assembler surface, and disambiguate YB-13's "collision condition" to name which collision each fixture covers (see SB-9).

### SB-3 (Major). The wire schema REQUIRES a `demoMode` boolean that no spec requirement defines, resurrecting a design-retired suppression name

**Location:** `schema/yard-snapshot.schema.json:98,100` (`config.demoMode`, in `config.required`); zero occurrences in the spec prose (grep confirmed); design line 64.

The wire schema makes `demoMode` a required `config` field, but `demoMode` appears nowhere in the spec's requirements (YB-4/5/6/12 never mention it). A car cannot implement a required field whose semantics no requirement states (implementability). Worse, the *only* design reference to `demoMode` (line 64, gating-matrix constraint) says demoMode suppression was **removed** and "no new suppression paths introduced," and the gating-matrix forbids any mode that mutes a truth surface. A required-but-undefined `demoMode` on the wire is either dead (then why required) or drives undescribed behavior on a suppression-adjacent name. This is the format asserting what the prose does not — the exact disagreement the instrument-split exists to prevent. **Remedy:** define `demoMode`'s semantics in a YB and prove it introduces no truth-surface suppression, or remove it from the schema.

### SB-4 (Major). Undisclosed deviation: the empty-vocab vector emits TWO faults where the design mandated "one fault / identical to malformed"

**Location:** `schema/vectors/fold/empty-vocab-one-fault.json:17-20` (expected two per-file fault strings); YB-8 ("one fault per valid-but-empty vocabulary file"); design `§6` DR3-2 row ("identical to malformed: ONE board condition… empty vocabulary yields one fault").

The instructed design-match check (4c) fails on fault count. The design's DR3-2 row twice says one condition ("ONE board condition, identical to malformed"; "yields one fault"); malformed in the landed detector emits a single combined fault. The spec/vector change the model to per-file, so two empty files yield two faults — an executable deviation from an approved design behavior, and unlike the two deviations the spec DOES disclose (YB-2 gate split, `storePathDisplay` rename), this one is undisclosed. The substance (no per-record fan-out) is preserved and the per-file form is defensible, so the remedy is cheap, but an undisclosed spec-vs-design deviation on an executable contract is a Major by this gate's standard. **Remedy:** either reconcile the vector to one combined fault (faithful to "identical to malformed") or disclose the per-file refinement in YB-8 with a design amendment note, as the other two deviations were.

---

## MINOR FINDINGS

### SB-5 (Minor). The runner contract omits the vocab file naming and shape, so two independent implementers cannot build compatible runners from the README alone
`schema/vectors/README.md:29-38` states records materialise as full objects and vocab "files" get written to a temp dir, but never states that `input.vocab.kinds` becomes a file named `kinds.json` of shape `{"values":[...]}` (and `outcomes.json` likewise). I had to open the detector (`Detect-Dispatches.ps1:71-72`) to learn this. A Go runner-author working from the README alone would guess. Pin the vocab file names and `{"values":[...]}` wrapper in the runner contract.

### SB-6 (Minor). The empty-vocab vector over-pins exact English fault strings as a cross-language deep-equal contract
`empty-vocab-one-fault.json:18-19` pins `"vocabulary: kinds.json is valid but carries zero values"` verbatim, and the runner contract compares `faults` deep-equal. The Go port must then emit byte-identical English prose or the D18 cross-verifier goes red on a non-divergence. Fault MESSAGES are the wrong contract surface across languages; recommend structured fault codes, or the spec should explicitly acknowledge that fault-string text is now a pinned cross-language contract (and that the detector's other freeform fault strings acquire the same obligation).

### SB-7 (Minor). `roles.json` ships `"conductor"` — uncontracted and unobserved, inconsistent with the epistemic constraint the spec invokes for YB-3
`schema/vocab/roles.json:7`. The design's role list is `car / reviewer / gate:&lt;name&gt;` (§5.5); "conductor" is not in it, and no manifest exists to observe it. YB-3 explicitly gates additions on observation-or-contract ("unobserved, uncontracted values wait for the detector to discover them"). Applying that constraint to outcomes but not to roles is inconsistent. Justify "conductor" by contract/observation or drop it and let the detector discover it.

### SB-8 (Minor). YB-6's "EXHAUSTIVE matrix" covers 2 of the design's 3 composition axes
YB-6 (line 76-80) pins "every position register x every freshness kind," but design Rule 1 (§5.2) is most-severe of THREE axes — position, freshness, and **capability** (`needs-attention` when no renderer exists). The capability axis is absent from the matrix and the word "capability"/"renderer" appears nowhere in the spec (grep confirmed). "Exhaustive" over 2 of 3 axes leaves the no-renderer→needs-attention compositional path untested. Make the matrix 3-axis or state where the capability register's contribution is pinned.

### SB-9 (Minor). YB-13's "collision condition" is ambiguous — the design has two distinct collisions
Design §6 carries both the DR3-3 collision (a subject in both `fold.dispatches` and `fold.intents`) and the Q2 collision (two manifests claiming one dispatch). YB-13's single "collision condition" (line 123) cannot be both, and a plan-writer cannot tell which fixture to build. Name each explicitly. (Resolving SB-2 resolves half of this.)

---

## THE SEVEN-ITEM HANDOFF WALK (round-4 verdict GATE DECISION → spec)

| # | Handoff obligation | Disposition | Evidence (verified, not taken on the doc's word) |
|---|---|---|---|
| 1 | Store record contract reused, never re-specified | **PRESENT** | Spec §1 row 1 + line 16 "reused, not re-specified"; no YB re-specifies `starcar-artifact.schema.json`. |
| 2 | Fold vectors: 3 new, homed on D18 path (DR4-1); DR3-2 detector edit scoped (DR4-2) | **PRESENT, one DRIFT** | All three vectors in `schema/vectors/fold/` (DR4-1 home satisfied); YB-8 + §7 table name the `Detect-Dispatches.ps1` edit (DR4-2). Two OBSERVED vectors reproduced deep-equal; red-on-arrival confirmed. **DRIFT:** DR3-2 fault count is 2 (per-file) vs design "one/identical-to-malformed" — SB-4. |
| 3 | Train manifest contract (schema, `train:` prefix Q7 guardrails, D17 key-set) | **PRESENT, defective** | `starcar-manifest.schema.json` + YB-1..3; Q7 whole-subject guarantee in schema description; D17 single-key addition stated. **But** the schema is non-portable to the mandated Go toolchain — SB-1. |
| 4 | Wire snapshot contract (schema, composition Rules 1-4, SSE constant, browser validator) | **PRESENT, defective** | `yard-snapshot.schema.json` + YB-4..6, YB-11; `sseEventName.const`; freshness `oneOf` verified exclusive. **But** required `demoMode` undefined (SB-3) and composition matrix drops the capability axis (SB-8). |
| 5 | D18 cross-verifier as a REAL CI job, watched to fire | **PRESENT** | YB-9: "not done when green… done when an INJECTED divergence has been WATCHED to fail it (fault-inject, observe red, revert, record the run URL)." |
| 6 | Q8 vectors rehomed language-neutral, migration red-first, own task | **PRESENT** | YB-10 + README migration note; migration "proven by the existing Pester assertions passing green against the same cases rehomed… never bundled into the Go-port car." |
| 7 | Plan-rung blocking tests (Go validator, JS validator) | **PRESENT, undercut** | YB-11(a) Go store-schema + (b) browser wire-schema, each with disclosed-degradation branch. **But** (a) cannot pass on the manifest schema as written — SB-1. |

**Additionally dropped (not among the seven, but within design fidelity):** the Q2 two-manifests-claim-one-dispatch board condition — **ABSENT** (SB-2).

Zero handoff items are wholly absent; two carry Major defects inside an otherwise-present fold, and one adopted-ruling obligation outside the seven-item list was dropped.

---

## RULINGS ON THE TWO DISCLOSED DEVIATIONS

- **YB-2 (gate NAME split into `members[].gate`):** LEGITIMATE spec-rung refinement. The design deferred "exact payload format" to the spec rung (§5.5), and the split avoids a consumer parsing a `gate:&lt;name&gt;` compound token — directly honoring the Q7 guardrail ("never `split(':')[1]` for meaning") and keeping `roles.json` unparameterised. Disclosed, design-amendment planned (§7 table). No finding (except the unrelated SB-7 on the vocab's `conductor` value).
- **`statePathDisplay` → `storePathDisplay` rename:** LEGITIMATE. `statePathDisplay` was a rev-3 relic naming the state file that D13/D14 retired; the field displays the store path now. Disclosed (YB-6), amendment planned. No finding.

## RULINGS ON THE OPEN QUESTIONS (§10)

- **Q1 (payload fields in prose, `$defs` as landing):** HONEST SPLIT, NOT prose-holding-format — but incompletely executed. YB-5's payload *shapes* are legitimately requirement-here / contract-there, and the design deferred exact payload format to the spec rung. The `$defs` need not land at this rung (the design explicitly allows red-first car extension). The remedy the question offers (land `$defs` now) is NOT required. However, the split is only honest if the prose requirement is complete, and it is not: SB-2 (a payload-composition obligation) is missing from the prose half. Fix SB-2 and the split is sound.
- **Q2 (`done-with-findings` on contract enumeration):** CONSISTENT, not padding. Verified `done-with-findings` is enumerated in `docs/templates/car-brief.md:47-48`. Contract enumeration is the same epistemic standing as a schema-declared value; the epistemic constraint bars *invented* values, not *contracted* ones. (Contrast SB-7: `roles.json`'s "conductor" has neither observation nor contract — that IS the padding this question guards against, one file over.)
- **Q3 (sanitisation as a pinned vector case):** NOT required as a fold vector. The fold reads `subject` from record content, never from the path (verified `Detect-Dispatches.ps1:119-124` reads `Get-Prop $r 'subject'`), so directory-name sanitisation cannot affect fold output and a fold vector cannot meaningfully exercise it. If sanitisation is ever pinned, its home is the store-WRITE path (producer), not a fold vector. The runner-contract gap that IS worth closing is SB-5 (vocab file layout), not this.

---

## CONVERGENCE NOTE (round 1 — correctness only)

Round 1 of the spec gate: no prior spec rounds, so this is a correctness ruling, not a convergence ruling. For the record the reviewer must hand forward: findings cluster in two places — schema portability/fidelity (SB-1, SB-3, SB-4) and carrier-rule completeness at the design→spec handoff (SB-2, SB-8, SB-9). None is a structural instrument mismatch: the instrument split (prose requirements + executable schemas/vectors) is correct and the executable core empirically holds; the defects are fixable in one revision. Same-agent delta reuse is available for round 2 (round count 1, no rotation trigger).

## CONSTITUTION CHECK (reviewer duty)

| Law | Verdict at rev 1 | Evidence |
|---|---|---|
| **1. Truth** | AT RISK | SB-3: a required `demoMode` on a name the design retired for suppression, undefined, risks a muted truth surface; the gating-matrix forbids exactly this. |
| **4. Nothing Silently Lost** | VIOLATED by SB-2 | The Q2 double-claim board condition (Law 4/6) is dropped; a dispatch claimed by two manifests would render with silent precedence, not disclosure. |
| **6. One Truth** | AT RISK | SB-1 breaks the single-schema-both-languages thesis (the manifest schema loads only on .NET, not the mandated Go validator); SB-6 makes fault prose a second cross-language contract. The vectors-as-sole-fold-authority (D18) is otherwise honored and the two OBSERVED vectors verified deep-equal. |
| **7. The Stranger** | HONORED | Open vocabularies as data (`roles.json`, wire `vocabularies` block); `storePathDisplay` never a raw absolute path (schema description + YB-12); empty-store day-one row carried (YB-13). SB-7 is a minor purity slip, not a stranger-facing break. |
| **Match the instrument** | HONORED in structure | Formats live in executable schemas/vectors, requirements in prose; the defects are content, not instrument choice. SB-4/SB-3 are the format and prose disagreeing, which the split is designed to surface — and did. |

I edited nothing, committed nothing, pushed nothing. Worktree is as I found it at `e3b61259b01d4b59d078b61b8c17da51a7340d84`.

```starcar-artifact
outcome: REJECT
findings: 4 Major, 5 Minor. SB-1 (Major) the manifest schema's negative-lookahead pattern ^(?!train:) at starcar-manifest.schema.json line 66 is RE2-incompatible - proven with the repo Go toolchain that regexp.Compile rejects it with "invalid or unsupported Perl syntax (?!" - while YB-11a mandates a Go draft-2020-12 validator blocking test over the landed store schema and YB-1 makes the manifest a store validator; no lookahead-free formulation mandated, no disclosure; a concrete RE2-safe reformulation using not around a positive ^train: pattern is given. SB-2 (Major) the design's adopted Q2 ruling at design line 340 - two manifests claim one dispatch must both render with a board condition naming the collision, Laws 4 and 6 - is dropped; spec YB-5 handles only unassigned dispatches, no YB carries the over-assigned board condition; carrier-rule violation. SB-3 (Major) the wire schema requires a demoMode boolean at yard-snapshot.schema.json lines 98 and 100 that no spec requirement defines (zero occurrences in spec prose) and whose only design mention at line 64 is that demoMode suppression was removed - a required-but-undefined field a car cannot implement, on a suppression-adjacent name the gating-matrix forbids. SB-4 (Major) undisclosed executable deviation: empty-vocab-one-fault.json expects two per-file faults where the approved design DR3-2 row says one fault identical to malformed; the instructed design-match check fails and unlike YB-2 and storePathDisplay this deviation is not disclosed. Minors: SB-5 runner contract omits vocab file naming and {"values":[...]} shape so two implementers cannot build compatible runners; SB-6 empty-vocab vector over-pins exact English fault strings as a cross-language deep-equal contract; SB-7 roles.json ships uncontracted unobserved "conductor" against the epistemic constraint the spec applies to YB-3; SB-8 YB-6 exhaustive matrix covers 2 of the design's 3 composition axes (capability axis absent); SB-9 YB-13 collision condition is ambiguous between the DR3-3 and Q2 collisions. Empirical core verified sound: both OBSERVED fold vectors reproduce deep-equal, the red-on-arrival vector fails exactly as described (4 false discoveries 0 faults), all five manifest fault-injection directions pass under .NET Test-Json, the freshness oneOf is mutually exclusive, and the store census recounts to done x5 CONFIRM x3 with done-with-findings confirmed at car-brief.md lines 47-48. Both disclosed deviations (YB-2 gate split, storePathDisplay rename) ruled legitimate spec-rung refinements. Q1 honest split but incomplete pending SB-2; Q2 done-with-findings consistent not padding; Q3 sanitisation vector not required (fold reads subject from content not path).
abstract: REJECT at spec gate round 1. Four Major defects block. The spec's empirical foundation is genuinely sound - I re-ran every claim and the two OBSERVED vectors reproduce byte-exact under the runner contract, the red-on-arrival vector fails precisely as described, all five manifest fault-injections pass under .NET, the freshness oneOf is exclusive, and the census recounts exactly - but four defects fail the gate: a manifest schema whose lookahead the spec's own mandated Go validator toolchain cannot compile (proven, breaking the one-schema-both-languages Law 6 thesis), the adopted Q2 two-manifests-collision board condition dropped at the handoff (the carrier-rule scar class, Law 4), a required demoMode wire field the prose never defines on a design-retired suppression name, and an undisclosed executable deviation where the empty-vocab vector emits two faults against the design's one. Five Minors cover runner-contract incompleteness, cross-language fault-string over-pinning, an uncontracted role value, a 2-of-3-axis composition matrix, and a collision-naming ambiguity. All are closeable in one revision; the instrument split is correct and the defects are content, not structure. The seven-item handoff walk: all seven present in fold, two carrying Major schema defects, plus one adopted-ruling obligation dropped outside the seven. Round 1 is correctness-only; same-agent delta reuse available for round 2.
```