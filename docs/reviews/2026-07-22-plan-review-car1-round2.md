<!-- starcar-integrity: sha256=eb258ea95f1c8bf8da25a08cd545d7702ed9bee9b6455ee82cd704ab5be0cb7c covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Plan review: dispatch harness Car 1, round 2 (delta)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Plan review (delta re-review, same adversary)
Round: 2
Target: `docs/plans/2026-07-22-harness-car1-plan.md rev 2`
Base reviewed: `8e9adaebe282a79c06729f6809a9240d42122bf8`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `aed8b69593d8924f8`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `8e9adaebe282a79c06729f6809a9240d42122bf8` |
| Entire checkpoint | `37fd47b395e1` |
| Dispatch, the locator within the session | `aed8b69593d8924f8` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 8e9adaebe282a79c06729f6809a9240d42122bf8
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Confirmed: the plan never mentions `abstract` — not in the field table, not deferred, not excluded with reasoning. The spec mandates it once (§2.3:92), in the same sentence as `outcome` and `findings`, both of which the field table persists. That is a genuine new Major. My fault injection is reverted and the tree is clean (`git status` empty, HEAD `8e9adae`). Here is the delta verdict.

---

**REJECT — 1 Major, 2 Minor.** Convergence is healthy (7 Major → 1), the single Major sits in newly-added material and is not a relocated round-1 defect, so no swirl condition fires and no cap is set. The Major is narrow: the schema field table drops `abstract`, one of the three envelope payload fields spec §2.3:92 mandates — the same class as round-1 PR1-M2, on a field neither I nor three spec rounds caught. One fast delta round closes it.

# Base and baseline verification (re-derived by me at HEAD)

| Claim | Plan says | I measured at `8e9adae` | Result |
|---|---|---|---|
| Worktree HEAD | — | `8e9adaebe282a79c06729f6809a9240d42122bf8` | matches brief |
| Pester | 21 passing (plan:39) | `PASSED=21 FAILED=0 TOTAL=21` | **confirmed** |
| Verify-Verdict | 12 files, exit 0 (plan:40) | 12 `OK`, `exit 0` (my round-1 verdict landed as the 12th) | **confirmed** |

# The 15-ID disposition walk (rebuilt, Present / Absent / DRIFTED)

| ID | Round-1 finding | Rev-2 disposition | My verdict |
|---|---|---|---|
| PR1-M1 | A.3 red factually wrong; test passes on arrival | A.3 rewritten from measured behaviour; S1 minted | **PRESENT.** I ran A.3's verbatim snippet under pwsh: `PASS=1 FAIL=2`, test 1 fails `Expected 1, but got 0`, test 2 exit-passes then fails on `zero verdict files` match, test 3 (regression pin) passes. Exactly as plan:350-356 claims. |
| PR1-M2 | 5 fields + ordering + index format + normalisation dropped | Full field table + `schema/index-format.md` | **PRESENT.** All 5 of my named fields now present: integrity, normalisation, budget, basis, envelope. Ordering/index-format/normalisation-rule assigned to A.1. (Residual: `abstract`, a 6th field I did not name in round 1, is still absent — new Major below, not a drift of M2.) |
| PR1-M3 | §3.2 vocab undelivered; enum contradicts discovery | `schema/vocab/*.json`; `kind` de-enumed with a pinning `It`; discovery vector + A.2 `Discoveries` | **PRESENT.** plan:168-172 test pins `kind.type -eq 'string'` and no `enum`. |
| PR1-M4 | Validation engine unnamed; menu | Runtime floor + R1v2, `Test-Json` measured both shells | **PRESENT.** I re-verified: `Test-Json -Schema` works on draft-2020-12 in pwsh 7.6.3, absent in WinPS 5.1. Floor declared `#requires -Version 7.4`. Menu closed. |
| PR1-M5 | Ledger narrowed to "service" state; index row missing | Two-question ledger; index row born A.4, recorded A.5 | **PRESENT.** plan:408-418, 391-394. |
| PR1-M6 | Default-off switch on false premise | R3: no switch, unconditional; premise re-measured (12 files) | **PRESENT.** I re-verified 12 verdict files at base. |
| PR1-M7 | Double identity key | R2: single `subject`, no `dispatch_id` | **PRESENT.** Field table:106 + no `dispatch_id` row. |
| PR1-m1 | `ci.yml:62` miscited | `:76-81` cited | **PRESENT.** plan:316. |
| PR1-m2 | A.5 had no steps 1-4 | All five steps present | **PRESENT.** plan:427-441. |
| PR1-m3 | hashtable vs pscustomobject | `[pscustomobject]`, `Board.psm1:188-191` | **PRESENT.** plan:223-224. |
| PR1-m4 | No snippets; BeforeDiscovery trap | Snippets in A.1/A.2/A.3; A.2 uses `BeforeDiscovery`, probed | **PRESENT (partial).** I ran the `BeforeDiscovery -ForEach` shape: `PASS=2 TOTAL=2` with per-vector names expanded — matches plan:238. **A.4 still has no snippet** (see Minor 2). |
| PR1-m5 | No `-SchemaPath` | Explicit `-SchemaPath` | **PRESENT.** plan:220. |
| PR1-m6 | Template trigger lines invalidated, not updated | Both template files in A.5 Files, same-commit annotation | **PRESENT.** plan:398-403. |
| PR1-m7 | Gating Evidence unsatisfiable for future gates | Pending-with-planned-name instruction | **PRESENT.** plan:422-425. |
| PR1-m8 | §9 rows 1-2 are Car 1's | A.5 + coverage row | **PRESENT.** plan:478. |

**15 of 15 folded on substance, none DRIFTED.** I verified every behavioural fold by running it, not by reading the plan's note.

# Findings on NEW material

### MAJOR (PR2-M1) — the schema drops `abstract`, one of the three envelope payload fields
**plan:100-118 (field table)** vs **`spec:92`**

Spec §2.3:92 (verbatim, re-read): the envelope carries *"`outcome`, `findings` and `abstract`."* Three payload fields. The field table persists `outcome` (plan:109) and `findings` (plan:110) — both citing §2.3 — and the `envelope` fault class (plan:111). It never mentions `abstract`; `grep -in abstract` on the plan returns **nothing**.

This is the "fold that looks folded" the delta walk exists to catch: the plan-writer visited §2.3, lifted two of the three fields named in one sentence, and left the third. There is no principled basis for the asymmetry — `abstract` and `findings` are typed identically (*"string, when `kind` = `returned`, spec §2.3"*). §2.3:65 states the envelope is *"how a `returned` record obtains its outcome"* — the record is populated from the envelope, so a payload field with no schema slot is either dropped (Law 4 silent loss of the human-readable summary a status board renders — Law 3) or invented by Car 2 in a field A.1 never declared (interface-consistency break, dimension b; and schema drift if `additionalProperties: false`). The field table explicitly claims completeness — *"All six... All six are enumerated here... consume this block blind"* (plan:95-98) — so the omission is also a false completeness claim on the one artifact R1v2 calls *the product*.

This is the identical class to PR1-M2 (dropped schema fields = Major in round 1). Consistency requires the same severity now; downgrading it because rev 2 is otherwise excellent would be the agreeableness failure the guide star names. **Honest disclosure: I missed `abstract` in round 1 too — my M2 list did not include it — as did all three spec-review rounds. It is a pre-existing gap neither round caught, surfaced now, not a defect rev 2 introduced.**

Fix (tight, so round 3 is a fast delta): add an `abstract` row — `string`, required `when kind = returned`, authority spec §2.3 — and add `abstract` to the valid-`returned` vector (plan:145-146). Because it is a schema-contract addition plus a new conformance vector, it exceeds the "mechanical line-drift" bar for APPROVE-WITH-REBASE-LIST, so it lands as a REJECT under the binding "Any Major = REJECT" calibration.

### Minor (PR2-m1) — `producer` field's authority miscited to spec §3.4
**plan:116** vs **`spec:164-167`**

§3.4 governs `cost` and `context` producer-*optionality*; it names no `producer` field (`grep` of §3.4 confirms). The field is defensible (Law 7 — which runner emitted this) but its cited authority does not support it. Either repoint the citation (design, presumably) or state the basis. Mechanical.

### Minor (PR2-m2) — A.4 still carries no test snippet, against Amendment 1's own corollary
**plan:379-388**

Round-1 m4 flagged A.2/A.3/A.4 as snippet-less. Rev 2 added full snippets to A.1, A.2, A.3 and the disposition row (plan:501) conspicuously says *"A.1/A.2/A.3"* — A.4 is silently excluded. A.4's test is the least trivial (determinism, byte-identical `Get-FileHash` equality, multi-key sort), and `worked-plan.md:16` (rev 2's own compression note) says *"every task carries... its snippets in full."* Its red is genuinely trivial — I verified `New-ArtifactIndex.ps1` yields `CommandNotFoundException: The term './scripts/New-ArtifactIndex.ps1' is not recognized...`, exactly plan:384-386 — so there is no API to sentence-check, which keeps this Minor. But the green-state test that pins determinism is where A.4's value lives and it is described only in prose.

*Note (not a finding):* `session_id` (plan:107) is cited to design §5.1, which is outside my provided ground truth; I could not verify it, but it does not contradict the spec. The field-table count is 15, not the 16 the brief anticipated — the missing 16th is consistent with the absent `abstract`.

# Convergence ruling

Round history: **R1 = 7 Major + 8 Minor (15). R2 = 1 Major + 2 Minor (3).** I hold the series and rule on it explicitly against the three swirl conditions (CLAUDE.md review calibration):

1. **Major counts declining?** 7 → 1. Steeply declining. Not stalled.
2. **Findings clustering in the same section across rounds?** No. Round 1 spread across A.1-A.5, R1, and the coverage table. Round 2's single Major is a lone field-table omission; the two minors are a citation and a snippet gap in different tasks. Findings shrank *and moved*.
3. **Does R2 contain defects R1's own fixes created?** No — and this is the sharpest test. `abstract` was missing before rev 2 and is still missing; rev 2's field-table rework did not relocate a round-1 defect into a new one, it simply failed to add a field neither round named. Not relocation; a residual pre-existing gap.

**Zero swirl conditions fire. Convergence is healthy — the textbook "findings shrink and move" signature.** No cap. This is a REJECT that reports as a SUCCESS outcome for the process: the gate caught a real product-artifact gap at one-dispatch cost before any car built the schema. Round 3 should be a trivial delta (add one field row + one vector, fix one citation, optionally add A.4's snippet).

# Ruling on S1 (spec amendment) as a fold of my findings

**S1 is FAITHFUL to what I measured — an exemplary fold.** I re-verified every empirical claim it makes, now under the pwsh 7.4 floor the plan declares (my round-1 measurement used WinPS 5.1; S1 will be exercised under pwsh, so I re-ran there):

- *"`:94-96` exits 0" is FALSE, lines unreachable"* — confirmed: under pwsh 7 the empty-`.md` directory throws `PropertyNotFoundStrict` at `:94`, exit **1**; `:95-96` unreachable.
- *"`Set-StrictMode` (`:27`) meets a `$null` pipeline result at `:91`"* — confirmed, correct mechanism and line numbers.
- *"only the dir-ABSENT vacuous exit (`:87-90`, exit 0) is real"* — confirmed: absent dir prints *"No [dir] directory. Nothing to verify."* and exits **0**.
- The three-part replacement (a: absent fails loudly; b: empty fails actionably not by crash; c: dead code removed) correctly maps to the real defects.

S1 also sharpens the characterisation beyond my round-1 wording — *"a truthful exit code delivered as an unactionable stack trace, its own Law-5 defect"* — which is exactly right. Its self-diagnosis (*"every round... verified the claim by READING"*) is the honest root cause. No infidelity.

# Ruling on Amendment 1 (worked-plan) as a fold of my findings

**Amendment 1 CLOSES exemplar hole 1, and its corollaries close all five of my other round-1 workflow holes.** My round-1 hole 1 was: the self-check says "open the real file," but must be "open the real file AND RUN the behavioural red." Amendment 1:25-26 states precisely that — *"A behavioural claim verified by reading is not verified. The plan-writer RUNS every behavioural red before writing it"* — and formalises the structural-read / behavioural-run split with *"Every stated red in every task is a behavioural claim"* (plan-template:43). Direct, faithful closure.

Its corollaries (worked-plan:45-58) map one-to-one onto my other five workflow holes: runtime floor (hole 2), data-contract Produces enumerates every mandated field (hole 3), subsection-granular coverage table (hole 5), two-part ledger question (hole 6); and the compression note at worked-plan:14-20 closes hole 4. All six closed.

One observation worth recording: the plan-writer *stated* the hole-3 rule correctly and then still missed `abstract` (PR2-M1). That is not a defect in Amendment 1 — the rule is right — it is proof the rule needs the adversary as backstop, which is the design. The instrument improved; the residual gap is an execution miss the gate then caught, exactly as intended.

# Probe-report correction — CONFIRMED

The conductor's correction is right, and I confirm it. My round-1 probe report framed three execution defects (PR1-M1, PR1-M6, PR1-m1) as pointing at *"the Sonnet-car measurement."* That was wrong: the model probe fires only when the **Sonnet car runs**, and no car has run — the plan was authored by the **conductor on Opus** (plan:22-24). Defects in a conductor-written plan are Opus/plan-writer defects; they carry **zero signal about Sonnet-as-car**. I conflated plan-authoring with car-execution. My round-1 report did hedge toward the exemplar hole rather than the model ("I would not move cars 2-3 back to Opus on this evidence alone"), but the artifact-envelope phrasing "attributable to the Sonnet-car measurement" was the imprecise claim, and the correction properly voids it. The probe remains **unfired and valid**: it measures the Sonnet car's execution, which begins when Car 1 dispatches.

# Constitution check (new material)

| Law | Implicated by | Honored? |
|---|---|---|
| **1 Truth** (`:12`) | S1; every behavioural claim RUN | **YES.** S1 corrects a false "exits 0" claim; rev 2's behavioural claims match observation — I re-ran A.1's red, A.2's `BeforeDiscovery`, A.3's three tests, A.4's red, A.5's fault-inject, `Test-Json` on both shells: all as stated. |
| **3 Actionability** (`:26`) | the dropped `abstract` | **NO (PR2-M1).** The abstract is the human-readable summary a status board renders; a durable record that cannot hold it fails the surface's purpose. |
| **4 Nothing silently lost** (`:33`) | `abstract` omission | **NO (PR2-M1).** An envelope payload field extracted then dropped is a silent loss. |
| **6 One Truth** (`:46`) | R2 single key; runtime floor | **YES.** `dispatch_id` removed (one join key); the floor forbids a hand-rolled second copy of the schema. |
| **7 The Stranger** (`:53`) | R1v2 vectors-as-conformance | **YES.** Portable vectors + declared floor; a stranger writes a validator against the same vectors. |
| **8 Growth** (`:59`) | S1, Amendment 1 | **YES.** Both amendments minted from round-1 findings and folded mechanically; the disposition table is a durable carrier. |

```starcar-artifact
outcome: REJECT
findings: 1 Major, 2 Minor
abstract: |
  Delta re-review of docs/plans/2026-07-22-harness-car1-plan.md rev 2 at base
  8e9adaebe282a79c06729f6809a9240d42122bf8. Baselines re-derived by me: Pester 21/21,
  Verify-Verdict 12/12 exit 0. Fault injection reverted byte-identical; git status empty,
  HEAD unchanged.

  15-ID walk: all 15 round-1 findings PRESENT and folded on substance, none DRIFTED. I
  verified every behavioural fold by RUNNING it (Amendment 1 discipline applied to the
  reviewer too): A.3's verbatim three-test snippet under pwsh gave PASS=1 FAIL=2 exactly as
  the plan claims (test1 fails Expected 1 got 0; test2 exit-passes then fails on the zero
  verdict files match against the crash stack trace; test3 regression pin passes). A.1's
  red, A.2's BeforeDiscovery -ForEach expansion (PASS=2 TOTAL=2, per-vector names expanded),
  A.4's CommandNotFoundException red, A.5's DocPolicy fault-inject, Test-Json on both shells
  (present pwsh 7.6.3, absent WinPS 5.1), and BeGreaterOrEqual all reproduce as stated.

  ONE NEW MAJOR (PR2-M1), which forces REJECT: the schema field table (plan:100-118) drops
  abstract, one of the three envelope payload fields spec section 2.3 line 92 mandates
  (outcome, findings AND abstract). The plan persists outcome and findings from that exact
  sentence, both citing 2.3, and silently leaves abstract; grep of the plan for abstract
  returns nothing. This is the fold-that-looks-folded the delta walk hunts, the identical
  class to round-1 PR1-M2 (dropped schema fields = Major). Consequence: Car 2 consumes A.1's
  Produces block blind and must either drop the human summary (Law 4 silent loss, Law 3
  actionability) or invent an undeclared field (interface-consistency break, schema drift).
  Honest disclosure: I missed abstract in round 1 too, as did three spec-review rounds; it
  is a pre-existing gap surfaced now, not a defect rev 2 introduced. Fix is tight: add an
  abstract row (string, required when kind=returned, authority spec 2.3) plus an abstract
  entry in the valid-returned vector. Because it is a schema-contract plus conformance-vector
  change, not mechanical line-drift, it lands as REJECT under Any-Major-equals-REJECT, not
  as APPROVE-WITH-REBASE-LIST.

  Two Minors: PR2-m1, the producer field cites spec 3.4 which governs cost/context
  producer-optionality and names no producer field (repoint or justify). PR2-m2, A.4 still
  carries no test snippet where its determinism/byte-identical/sort test is non-trivial,
  against rev 2's own compression note; its red is trivial and verified, so Minor.

  Convergence: healthy, no swirl. Major counts 7 to 1 (steeply declining); the single Major
  is a lone field omission, not clustered and not a relocation of any round-1 defect; abstract
  was always missing. Zero swirl conditions fire, no cap set. Round 3 is a fast delta.

  S1 fold: FAITHFUL to what I measured, re-verified under the pwsh 7.4 floor - empty dir
  throws PropertyNotFoundStrict at :94 exit 1, :95-96 unreachable, only the absent-dir exit-0
  is the real vacuity; StrictMode at :27 meets the null pipeline result at :91. S1 even
  sharpens the Law-5 characterisation of the crash. No infidelity.

  Amendment 1 fold: CLOSES exemplar hole 1 (behavioural claims RUN not read, with an explicit
  structural-read vs behavioural-run split and "every stated red is behavioural"), and its
  corollaries plus the compression note close all five of my other round-1 workflow holes
  (runtime floor, data-contract field enumeration, subsection-granular coverage, two-part
  ledger, compression-is-not-a-licence). The plan-writer stated the field-enumeration rule
  correctly and still missed abstract, which proves the rule needs the adversary as backstop,
  exactly as designed - not a hole in the amendment.

  Probe-report correction: CONFIRMED. My round-1 attribution of three execution defects to
  the Sonnet-car measurement was wrong; the plan was conductor-authored on Opus and no car
  has run, so those defects carry zero signal about Sonnet-as-car. The probe is unfired and
  valid.

  Constitution: Laws 1, 6, 7, 8 honored in new material with evidence; Laws 3 and 4 violated
  by the single Major (abstract omission).

  Read-only: nothing edited, committed, or pushed in the worktree. Probes ran as one
  untracked test file and TestDrive/scratch dirs, all removed; tree clean at HEAD.
```