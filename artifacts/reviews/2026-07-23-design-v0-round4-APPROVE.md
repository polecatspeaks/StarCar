<!-- starcar-integrity: sha256=7b22b30545d02579bc65757cfb6e4e8c82471f103c2adabdd36112b0a21317d3 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# v0 yard skeleton design review round 4 (rev 5): APPROVE - 0 Major, disposition walk clean, convergence 9-8-3-0, rotation proven

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Design review (adversarial, Opus, FRESH reviewer under mechanical rotation, detached worktree)
Round: 4
Target: `docs/design/2026-07-21-v0-yard-skeleton-design.md rev 5 at 4db5ed4`
Base reviewed: `4db5ed47b7a7b0858fef3650ea96c961e8041e88`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a4374d0904d8f8534`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `4db5ed47b7a7b0858fef3650ea96c961e8041e88` |
| Entire checkpoint | `cfdc61ceb2e6` |
| Dispatch, the locator within the session | `a4374d0904d8f8534` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 4db5ed47b7a7b0858fef3650ea96c961e8041e88
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

I now have complete evidence. Let me record my verification summary before writing the verdict.

Verification completed:
- Base: `4db5ed47...` confirmed; rev 5 is HEAD of the design doc (commit `4db5ed4`, parent `98af4a6` = rev 4).
- Round history verified from landed record: round 1 = 9 Major, round 2 = 8 Major, round 3 (rev 4) = 3 Major. Series `9→8→3` confirmed independently.
- Go probe re-ran: FACT1/2/3/5/6/7 all reproduce byte-exact.
- Constitution citations DR3-4 changed: Law 1 `:18`, Law 6 `:48-50`, Law 7 `:56` all verified correct against `docs/constitution.md`.
- Detector code verified: `intents` output = subject/at/superseded only (`Detect-Dispatches.ps1:211-215`); empty-vocab cascade real (line 104 `@() -notcontains $k` fires); subject-collision real (kind-partition at :133-134). Schema `subject` = one identity key (:15-17). Test pins verified (`Detector.Tests.ps1:116-120`, `:140-146`).

Here is my verdict.

---

# ADVERSARIAL DESIGN REVIEW — v0 yard skeleton, rev 5 (design gate, ROUND 4, reviewer rotation)

Base verified: `git log -1 --format=%H` = `4db5ed47b7a7b0858fef3650ea96c961e8041e88`, detached worktree. Read-only; nothing edited, committed, or pushed. I am a FRESH reviewer under the mechanical rotation trigger (round count 4); I reconstructed the full series from the landed verdicts alone.

## VERDICT: APPROVE — 0 Major, 2 Minor

Rev 5 folds all three round-3 Majors in SUBSTANCE, not merely in marker. Each fold was tested against the failure mode this round exists to catch — "the fold that looks folded" — by opening the landed substrate the fold claims to satisfy, and each holds. The two Minors I raise are downstream-bookkeeping gaps around one fold's executable home; neither is a substrate mismatch, a constitution violation, or a contract a car gets silently wrong, so neither blocks. This design proceeds to the spec rung.

**The record sufficed to review cold.** The round-3 verdict carries base SHA, finding IDs, code citations, convergence series, and Q-rulings verbatim; the round-1/2 verdicts carry their counts. I reconstructed the entire trajectory and re-verified every load-bearing citation without the prior reviewers' context. No finding about the verdict template.

---

## THE DISPOSITION WALK (carrier-rule check)

Every DR3 finding, Note, and Q-ruling, marked against rev 5's actual text and the landed substrate.

| Item | Kind | Disposition | Evidence (verified, not taken on the doc's word) |
|---|---|---|---|
| **DR3-1** fold carries no manifest payload; "exactly one owner" over-claim; Law 6 trap; D17 key-set | Major | **PRESENT** | §5.3 states fold.intents = subject/at/superseded only (I confirmed `Detect-Dispatches.ps1:211-216`; pin `Detector.Tests.ps1:116-120`). Payload sourced from RAW records; the fold-winner→raw join specified ("fetch the WINNING record's payload by the subject+at the fold named"); Law 6 re-implementation trap named ("Assembler never selects latest manifest itself"); superseded-manifest vector committed; ownership table corrected to "one COMPOSER per surface, every input named"; Gates row shows its two inputs; D17 key-set constraint stated (§5.3 last para). All four sub-items landed. |
| **DR3-2** valid-but-empty vocab reopens cascade | Major | **PRESENT** | §6 row treats empty-vocab as a VOCABULARY FAULT (one condition, no fan-out), cites `Detect-Dispatches.ps1:71-72,101-108`, names the vector "empty vocabulary yields one fault, zero per-record discoveries". I reproduced the cascade against the landed detector: `{"values":[]}` → `$vocabOk=$true` → line 104 `@() -notcontains $k` fires per distinct kind. Real, correctly diagnosed. |
| **DR3-3** subject namespace collision | Major | **PRESENT** | §5.5 mandatory `train:` prefix partition (cites `schema:15-17`, verified) PLUS §6 observed-collision board condition — both, as round 3 permitted picking one. I confirmed the fold partitions each subject-bucket by KIND (`:133-134`), so a shared subject lands in both fold.dispatches and fold.intents; the prefix closes it by construction. |
| **DR3-4** three off-by-one citations | Minor | **PRESENT** | §1 now cites Law 1 `:18`, Law 6 `:48-50`, Law 7 `:56`. I opened `constitution.md`: line 18 = "Unknown states render AS unknown"; "second copy…that can drift" spans 49-50 (48-50 contains it); "board schemas or label taxonomies" = line 56. All three corrected. |
| **DR3-5** missing empty-store + all-quarantined rows | Minor | **PRESENT** | §6 rows `[DR3-5a]` honest-empty (successful zero-record scan, `fresh`) and `[DR3-5b]` all-quarantined ("N of N", `needs-attention`), zero-of-N vs zero-of-zero distinguished. |
| **DR3-6** unstated no-read-integrity premise | Minor | **PRESENT** | §2 P7 with if-false branch (adapter recomputes at poll cost, quarantine row). |
| **DR3-7** browser-validator probe unlisted | Minor | **PRESENT** | §2c row, symmetric with the Go row, plan-rung blocking test + disclosed-degradation negative branch. |
| **DR3-8** composition carried by git-history reference | Minor | **PRESENT** | §5.2 now states Registers/Positions/Freshness/Composition Rules 1-4/Completeness in full, self-contained. |
| **Note-1** partial writes | Note | **PRESENT** | §6 mid-write row (transient one-poll quarantine, self-heals; atomic writes = harness's concern). |
| **Note-2** single-binary certainty | Note | **PRESENT** | D12 caveat: "PROVEN only at Car 1's cross-compile probe". |
| **Note-3** detached-HEAD strength | Note | **PRESENT** | §6 row (old checkout scans fresh, renders stale by data age). |
| **Q1** dual fold + CI cross-verifier | ruling | **PRESENT, faithful** | D18: "a REAL CI JOB, not an assertion… until watched to fire on an injected divergence, the Law 6 escape is unproven" — folds round-3's binding "guard unproven until watched to fire". |
| **Q2** manifest collision | ruling | **PRESENT, faithful** | §6 row: latest-`at` does not extend cross-subject; disagreement shown, never silently won. |
| **Q3** 29 migrated verdicts | ruling | **PRESENT, faithful** | §5.5: yard-inventory + backfill manifests; slug convention rejected as #557 inference. |
| **Q4** browser validation depth | ruling | **PRESENT, faithful** | §5.4 pt 2 + §2c: single schema-driven validator; structural check only as disclosed degradation. |
| **Q5** first paint | ruling | **PRESENT, faithful** | §7: honest-but-thin stands; freight stays out. |

**Zero ABSENT, zero DRIFTED.** No fold is words-without-substance.

---

## FRESH-READ FINDINGS (independent of the prior rounds)

### DR4-1 (Minor). The DR3-2 empty-vocab vector is filed under the wrong executable owner in §0, decoupling it from the D18 cross-verifier that must gate it

**Location:** §0 table row 4; cross-referenced §6 DR3-2 row, D18.

§0 row 4 ("Wire snapshot — YardSnapshot + vocabularies") lists "the empty-vocabulary-yields-one-fault vector (DR3-2)" as its obligation. But the empty-vocab→one-fault behavior is **fold-layer**: the DETECTOR reads `kinds.json`/`outcomes.json` and emits `faults`/`discoveries` (verified `Detect-Dispatches.ps1:66-76, 101-112`), and §6's own DR3-2 row cites the detector and says "detector does NOT fan out." The vector's natural home is §0 **row 2** ("Fold semantics… the detector conformance vectors, `Detector.Tests.ps1` cases"), sitting beside the existing "unreadable vocabulary directory is ONE fault" test (`Detector.Tests.ps1:140-146`). This matters because **D18's cross-verifier runs both implementations against the shared FOLD vectors**; a vector filed with the wire-snapshot contract is not on the cross-verifier's path, so the empty-vocab fix would not be gated across the two fold implementations. **Why Minor not Major:** the obligation is named and carried (not dropped), §6 unambiguously locates the behavior in the detector with code citations, and the spec-rung review re-homes it; the design's substance is correct. **Fix at spec rung:** pin the empty-vocab vector with the fold conformance vectors (row 2), on the D18 cross-verifier's path.

### DR4-2 (Minor). DR3-2's fix entails editing the landed pwsh detector, but §8 (contracts touched) names no `Detect-Dispatches.ps1` change

**Location:** §8; interaction of DR3-2 with D18.

The landed pwsh detector FANS OUT on empty vocab (that is the bug DR3-2 fixes). D18 makes both implementations conform to the shared vectors. Therefore adding the empty-vocab vector forces the **pwsh detector to change** (currently it would diverge from a corrected Go fold and the cross-verifier would go red). §8 lists "`schema/vocab/kinds.json` etc. — vocabulary additions" (vocab DATA) but no row for the detector CODE edit. **Why Minor not Major:** this is a guard that FIRES — the D18 cross-verifier would catch the divergence loudly, so it is an unnamed-but-caught scope item, not a silent hole; and the plan rung maps requirements to tasks and would surface it. **Fix at spec/plan rung:** name the `Detect-Dispatches.ps1` empty-vocab edit as a scoped task, so it is a decision rather than a cross-verifier surprise.

*(Shared root: both Minors flow from DR3-2 being a fold-layer BEHAVIOR CHANGE — not merely a port — whose executable homes §0 and §8 under-account for. The mechanism is sound; the bookkeeping around it is one revision short.)*

**No other defect found.** I specifically checked: the "exactly one owner" language is fully retired (§5.3 "one COMPOSER… not one input") with no contradicting remnant; §5.2/§5.6 config values are restated inline (host 127.0.0.1, port 4600, pollMs 1000, etc.), so "rev 3 §11" is provenance not a DR3-8 violation; the composition Rule 1 mapping is behavioral design (which the prior rounds demanded ON the page), pinned to spec vectors, not a canonicalisation rule smuggled into prose; the `train:` prefix defers exact format to a spec vector rather than over-specifying; the Q4 no-build-step draft-2020-12 JS validator is honestly listed as an unproven §2c probe (the schema does use `if/then/allOf`, verified `:87-105`).

---

## RULINGS ON Q6–Q8 (these bind unless appealed upward)

**Q6 — backfill granularity. Default to the COARSE single "pre-harness era" manifest; permit faithful per-train manifests ONLY where the conductor's consist knowledge is DECLARED, never reconstructed-by-inference.** Reconstructing "who was in which train" from session behavior is the #557 inference smell one level over — the exact class Q3 rejected the slug convention for. A flat historical gates-lane is a TRUE rendering of a past the board did not witness live, which the showcase's honesty thesis prefers over a confidently-reconstructed-but-possibly-wrong consist. Where a durable at-the-time artifact (a plan doc, a manifest-shaped ruling) already declares the composition, transcribing it into a faithful manifest is fine — that is declaration, not inference. Backfill is content, plan-rung scheduling; it does not gate this design.

**Q7 — the `train:` prefix is the RIGHT cut and does NOT smuggle parseable structure in the harmful sense.** The harmful smell is a consumer that must PARSE a key to DECODE meaning it cannot get otherwise (#557). The prefix instead supplies a DISJOINTNESS GUARANTEE the fold structurally requires: the fold groups by subject THEN splits by kind (`Detect-Dispatches.ps1:118-134`), so a train-intent and a dispatch sharing a subject collide in one bucket **regardless of any payload field**. A dedicated payload field would leave that fold-level collision open and STILL need the DR3-3 detector, while adding a second identity mechanism R2 warned against. The prefix closes it by construction. Guardrails (the design already commits the first and third): (1) the train id is the WHOLE subject string including `train:`, never `split(':')[1]` — no consumer strips it for meaning; (2) the prefix is a reserved character-class partition pinned by a manifest spec vector; (3) the observed-collision detector stays as defense in depth. With those, it is a partition, not inference. KEEP the prefix.

**Q8 — MOVE the vectors to a language-neutral home** (declarative fixtures: input-store JSON + expected-fold JSON) that BOTH the pwsh detector suite and the Go fold suite load. D18's cross-verifier is only genuinely single-source if the vectors are language-neutral DATA. The extracted-JSON-copy alternative is a second copy that CAN drift: the vectors' semantics currently live inside PowerShell `It`/`Should` blocks (`Detector.Tests.ps1` — imperative `New-Record` + assertions), so "extracting" them is a re-authoring, the exact Law 6 harm. The neutral home is the same schema-as-constructed-header pattern the design endorses in D15. The migration cost (rewriting the Pester suite to load fixtures) is one-time and bounded, and is work D18 forces anyway — cheaper than paying drift risk forever. Guard: the migration lands red-first, PROVEN by the existing Pester assertions still passing green against the SAME cases rehomed as fixtures, as its own reviewed plan-rung task (never smuggled into the Go-port car).

---

## CONVERGENCE RULING (explicit)

**HEALTHY. NO CAP, NO ESCALATION** — and the series terminates here on APPROVE. Series (verified from the landed record): **9 → 8 → 3 → 0 Major**. Walking the three swirl triggers:

- **Majors declining:** 9→8→3→0, strictly. The strongest counter-signal to swirl. No trigger.
- **Clustering across rounds:** rev-2 Majors in composition (§5.5-5.6, closed); round-3 Majors at the manifest/fold seam (§5.3/§5.5/§6, now closed); round-4 findings are 2 Minors at §0/§8 bookkeeping. Each round's findings move to a NEW section as the prior class closes. No trigger.
- **Fixes creating defects:** DR4-1/DR4-2 are NOT defects the DR3-2 fix introduced into the mechanism — the fix is substantively correct; they are incomplete bookkeeping around its executable home. At most a weak single signal, and one trigger cannot escalate (two-of-three required). No trigger.

Zero of three fire. The instrument (prose design + adversarial read) resolved correctly across four rounds; the residual items are Minor and closeable in the spec revision.

---

## GATE DECISION: APPROVE → proceeds to the spec rung

All DR3 dispositions PRESENT, fresh read finds no Major. The two Minors (DR4-1, DR4-2) fold into the spec revision. **What the spec rung MUST pin so the handoff carries by document, not memory:**

1. **Store record contract** — EXISTS (`schema/starcar-artifact.schema.json` + conformance vectors); reuse, do not re-specify.
2. **Fold semantics vectors** (§0 row 2) — the Go port conforms to the existing `Detector.Tests.ps1` cases, PLUS three NEW vectors, **all homed with the fold vectors on the D18 cross-verifier's path**:
   - DR3-1 join: a store with a superseded manifest renders the winner's members and exposes the loser (fold.intents winner → raw-record payload fetch).
   - DR3-2 empty-vocab: a valid-but-empty vocabulary file yields ONE fault, ZERO per-record discoveries **(DR4-1: file it here, not with the wire snapshot)**, and the pwsh detector is edited to pass it **(DR4-2: name it a scoped task in §8)**.
   - DR3-3 partition: a train-subject and a dispatch-subject cannot collide, plus the observed-collision board condition.
3. **Train manifest contract** (§0 row 3, TO PRODUCE) — schema addition for the intent-record payload (train id, title, ticket refs, members-with-roles); the `train:` prefix character-class format (Q7 guardrails); the D17 known-key-set addition so manifest payload fields do not trip unknown-field disclosure.
4. **Wire snapshot contract** (§0 row 4, TO PRODUCE) — JSON Schema for `YardSnapshot` + vocabularies; composition Rules 1-4 (register = most-severe-of-three-axes, the freshness→register mapping, `ageBucketMs` quantisation, the SSE event-name constant); the browser-validator blocking test with disclosed-degradation negative branch.
5. **D18 cross-verifier** — a REAL CI job running the pwsh detector and Go fold against the shared vectors, WATCHED to fire on an injected divergence (Q1 binding condition; a guard is unproven until watched).
6. **Q8 (my ruling)** — vectors rehomed to a language-neutral `schema/vectors/` both implementations consume; migration landed red-first, preserving existing semantics, as its own reviewed task.
7. **Plan-rung blocking tests** — Go draft-2020-12 validator conformance; browser JS draft-2020-12 validator existence/conformance; each with a disclosed-degradation negative branch (§2c).

The five round-3 rulings Q1-Q5 remain binding on the spec. Q6-Q8 rulings above bind unless appealed.

---

## CONSTITUTION CHECK (reviewer duty)

| Law | Verdict at rev 5 |
|---|---|
| **1. Truth** (`:14-18`) | **HONORED.** The round-3 findings (empty-vocab wolf-cry DR3-2, colliding-subject misrender DR3-3) are both closed; unknown renders by name; `failed`/`lastGood` visible. Citation `:18` now correct. |
| **2. Dispatcher Commands** (`:21-23`) | **HONORED.** D14: override IS a `held` intent store write, rendered because the store says so; backed by the landed later-intent-supersedes test (`Detector.Tests.ps1:111-120`). |
| **3. Actionability** (`:26-31`) | **HONORED.** The DR3-1 manifest→role join is now specified, so gate identity (which rides the manifest) resolves; register drives the glance. |
| **4. Nothing Silently Lost** (`:35-37`) | **HONORED.** DR3-1 risk (manifest members the fold cannot carry) closed by sourcing payload from raw records; D17 preserve-and-disclose; yard-inventory for orphans; empty-store/all-quarantined rows added. |
| **5. Self-Knowledge** (`:41-44`) | **HONORED.** DR3-2 config-fault-as-N-discoveries closed; `asOf`/data-age split sound. |
| **6. One Truth** (`:48-51`) | **HONORED, contingent.** Vectors are sole fold authority (D18); the "exactly one owner" over-claim retired; the fold-supersession re-implementation trap named and forbidden. Q8 ruling further protects it (single-source vectors, not an extracted copy). Citation `:48-50` now correct. |
| **7. The Stranger** (`:55-57`) | **HONORED.** Empty-store day-one row present (DR3-5a); browser-validator probe listed (DR3-7); open vocab as data (D8); adapter seam preserved. Citation `:56` now correct. |
| **8. Growth** (`:60-63`) | **HONORED.** §9b/§13 and the inherited-risk disclosure record the full history in public; the detector is a genuine Healing-Loop instrument, and DR3-2's fix stops it crying wolf. |

No law is violated by the diff; DR4-1/DR4-2 are bookkeeping-tier, not constitutional.

I edited nothing, committed nothing, pushed nothing. Worktree is as I found it at `4db5ed47b7a7b0858fef3650ea96c961e8041e88`.

```starcar-artifact
outcome: APPROVE
findings: 0 Major, 2 Minor. Disposition walk clean - all three round-3 Majors (DR3-1 fold-payload observability, DR3-2 empty-vocab cascade, DR3-3 subject-namespace collision), all five Minors (DR3-4 through DR3-8), all three Notes, and all five Q-rulings (Q1-Q5) landed PRESENT with substance intact, zero ABSENT, zero DRIFTED, verified against the landed substrate (Detect-Dispatches.ps1 lines 211-216 for the intents shape, lines 71-72 and 101-112 for the reproduced empty-vocab cascade, lines 118-134 for the kind-partition that makes a shared subject collide; schema lines 15-17 for the single identity namespace; constitution lines 18, 48-50, 56 for the corrected citations; all Go FACTs re-ran and reproduced). Two new Minors: DR4-1, the DR3-2 empty-vocab vector is filed in section 0 under the wire-snapshot contract but the behavior is fold-layer, so it must be homed with the fold conformance vectors on the D18 cross-verifier's path; DR4-2, DR3-2's fix entails editing the landed pwsh detector (which currently fans out on empty vocab) yet section 8 names no Detect-Dispatches.ps1 change - a guard that the D18 cross-verifier would catch loudly, so caught-not-silent. Both fold into the spec revision; neither is Major. Q6 ruled: default to a coarse pre-harness-era backfill manifest, faithful per-train only where consist knowledge is declared not inferred. Q7 ruled: keep the train prefix - it is a disjointness partition the fold's subject-bucketing structurally requires, not harmful structure-smuggling, since a payload field would leave the fold-level collision open. Q8 ruled: move the vectors to a language-neutral home both implementations consume, because the extracted-JSON-copy alternative is a Law 6 second copy that can drift.
abstract: APPROVE at design gate round 4 under reviewer rotation. This fresh reviewer reconstructed the full 9-8-3 series from the landed verdicts alone (record sufficed to review cold, no verdict-template finding) and confirmed rev 5 folds all three round-3 Majors in substance not just marker, tested against the fold-that-looks-folded failure mode by opening the substrate each fold claims to satisfy. Convergence HEALTHY and terminating: Majors decline 9 to 8 to 3 to 0, findings move section to section as each class closes rather than clustering, and the two residual Minors are incomplete bookkeeping around the DR3-2 fold's executable home, not defects its fix created - zero of three swirl triggers fire, no cap, no escalation. Q6-Q8 ruled with evidence and binding force. The design proceeds to the spec rung with a seven-item executable-obligations handoff carried by document.
```