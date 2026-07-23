<!-- starcar-integrity: sha256=586dd625ce7439ab039812f0dd782700862e57b8a45584a15232c69669c5a701 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Yard board spec delta round 2: APPROVE - all nine findings folded in substance, RE2 wall gone (4/4 patterns compile), convergence 4-0 terminal

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Spec review (adversarial delta, Opus, same reviewer fix-cycle, empirical re-runs)
Round: 2
Target: `docs/specs/2026-07-23-yard-board-spec.md rev 2 at 9e8e146`
Base reviewed: `9e8e146e59f69107e5d19be038c824faa63aa21f`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

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
| Base commit the reviewer read (**the lookup key**) | `9e8e146e59f69107e5d19be038c824faa63aa21f` |
| Entire checkpoint | `c2bd9dcba04e` |
| Dispatch, the locator within the session | `aa93fdf486b9ff91b` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 9e8e146e59f69107e5d19be038c824faa63aa21f
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Complete. `scripts/probes/go/` holds the existing FACT probes (json-facts, sse-facts); there is no pattern-check probe there yet — YB-11's `scripts/probes/go/ pattern check` is a forward reference to a plan-rung deliverable (I proved the check itself works via my own RE2 walk). Worktree clean, HEAD unchanged. Here is my delta re-review.

---

# ADVERSARIAL SPEC REVIEW — yard board, rev 2 (spec gate, ROUND 2, delta / verify-the-fix)

**Base verified:** `git log -1 --format=%H` = `9e8e146e59f69107e5d19be038c824faa63aa21f`, detached worktree at the coordinator-named commit. Read-only: nothing edited, committed, or pushed; probes ran in system-temp and scratchpad, outside the worktree; final `git status --porcelain` empty. Same-agent delta reuse (round count 2, no rotation trigger). Round history carried: round 1 = 4 Major, 5 Minor, REJECT.

## VERDICT: APPROVE — 0 Major, 0 Minor, 0 new findings; convergence 4→0, terminal

All nine round-1 findings are folded in SUBSTANCE, verified against the substrate and by re-running every empirical claim — not merely by marker. The two Major schema defects are proven closed by re-execution (five fault-injections pass under .NET on the lookahead-free form; all four schema patterns RE2-compile under the repo Go toolchain with zero failures). The two Major carrier/definition gaps are restored as YB-14 and YB-15 with no drift from the design. The five Minors are each closed at the artifact. A fresh-eyes sweep of `git diff e3b6125..9e8e146` surfaces no new defect. This spec proceeds to the plan rung.

**The landed round-1 verdict checks out:** `artifacts/reviews/2026-07-23-board-spec-round1-REJECT.md` exists, its `starcar-artifact` envelope is byte-identical to the verdict I produced, and its header title names the four Majors correctly. No verdict-template finding.

---

## EMPIRICAL RE-RUNS AT REV 2

- **SB-1 fault-injections (.NET):** all five reproduce against the lookahead-free schema — good-manifest PASS, train-without-manifest FAIL, non-train-with-manifest FAIL, plain-held PASS, bad-charclass FAIL. The `not`-around-positive-`^train:` form is semantically equivalent to the retired lookahead (including the subjectless-record edge: a record with no subject is forbidden a manifest, which the base schema's `required: subject` already enforces).
- **SB-1 Go RE2 walk:** wrote a recursive `"pattern"`-walker in Go and compiled every pattern across all three schemas with the repo toolchain: `starcar-manifest` 3 patterns (`^train:`, `^train:[a-z0-9][a-z0-9-]*$`, `^train:`) all OK; `yard-snapshot` 0 patterns; `starcar-artifact` 1 pattern (`^sha256:[0-9a-f]{64}$`) OK. **TOTAL patterns=4, failures=0.** The RE2 wall is gone.
- **SB-4 detector re-run:** `empty-vocab-one-fault.json` now expects ONE combined fault `"vocabulary: valid but empty: kinds.json, outcomes.json"`; against the unfixed detector it is still red-on-arrival (actual `faults=[]`, `discoveries=[kind: dispatched, kind: returned, outcome: done, kind: intent]`), and its `dispatches`/`intents` blocks are UNCHANGED and deep-equal to the observed versions. The two OBSERVED vectors still reproduce deep-equal.

---

## THE NINE-FINDING DELTA WALK

| ID | Sev | Disposition | Evidence at rev 2 (verified) |
|---|---|---|---|
| **SB-1** | Major | **PRESENT (fixed)** | `starcar-manifest.schema.json:64-75` second `allOf` branch reformulated to `if.not{subject pattern ^train:}` → `then.not{required manifest}` with an in-schema `$comment` explaining the RE2 rationale. Five .NET injections pass; Go RE2 walk 4/4 compile. YB-11(a) now reads "the landed store schema AND the manifest schema `[SB-1, folded]` + their vectors." Standing rule added (YB-11): "every `pattern` in every landed schema is RE2-compatible - no lookahead, no backreferences… a non-RE2-compatible pattern is a defect wherever it appears." |
| **SB-2** | Major | **PRESENT (fixed), no drift** | YB-14 restores the Q2 ruling: two manifests claiming one dispatch → render in BOTH trains + board condition `manifest-membership-collision` naming the dispatch and both train subjects, "disclosed, never resolved by silent precedence… latest-`at`… does NOT extend across different manifest subjects; design §6 `[Q2, ruling adopted]`, Laws 4 and 6," red-first against a two-manifests fixture. Checked hop-for-hop against design §6 line 340: both-render ✓, named board condition ✓, no silent precedence ✓, cross-subject non-extension ✓, Laws 4/6 ✓. No drift. |
| **SB-3** | Major | **PRESENT (fixed)** | YB-15 defines `config.demoMode`: true iff serving a demo fixture store; SOLE consumer the view's persistent DEMO banner; "No other behavior may branch on it… a truth surface… suppressed or altered under `demoMode` is a gating-matrix violation"; red-first banner-renders test PLUS staleness-still-fires-on-stale-demo-data test. Wire schema `demoMode` description now points at YB-15 and states the no-branch rule — contradicts nothing in YB-15. |
| **SB-4** | Major | **PRESENT (fixed), no drift** | Vector expects one combined fault "identical in shape to the malformed-vocabulary fault" naming every empty file; disclosed in BOTH YB-8 (`[SB-4, folded]`) and the vector description. Matches design DR3-2 "ONE board condition / identical to malformed / one fault." dispatches/intents unchanged (re-run), still red-on-arrival by construction. |
| **SB-5** | Minor | **PRESENT (fixed)** | README runner step 2 pins the vocab layout: "ONE FILE PER KEY, named `&lt;key&gt;.json` (`input.vocab.kinds` becomes `kinds.json`…), each with the shape `{"values": [...]}` - the exact layout `schema/vocab/` uses." A Go runner-author no longer needs the detector source. |
| **SB-6** | Minor | **PRESENT (fixed)** | Cross-language fault-string posture disclosed in YB-8 and README step 3; structured fault codes named as the trigger-gated escape hatch, "not built now." |
| **SB-7** | Minor | **PRESENT (fixed)** | `roles.json` = `[car, reviewer, gate]`; `conductor` removed; YB-2 records the epistemic rule ("YB-3's epistemic rule binds roles too - the detector discovers it if it ever appears"). |
| **SB-8** | Minor | **PRESENT (fixed)** | YB-6 is now a THREE-axis matrix (position × freshness × capability), with two load-bearing cases red against partials: `live+failed → needs-attention` AND `live+fresh+no-renderer → needs-attention` with the "no renderer for this payload" line. |
| **SB-9** | Minor | **PRESENT (fixed)** | YB-13 names both collisions distinctly: (a) DR3-3 namespace collision → `subject-namespace-collision`; (b) Q2 membership collision → deferred to YB-14. No longer ambiguous. |

**Zero ABSENT, zero DRIFTED. No fold is words-without-substance.**

## FRESH-EYES DIFF SWEEP (e3b6125..9e8e146)

New defects introduced by the folds: **none found.** Specifically checked: the manifest `not`-form for a semantic hole (none — subjectless records are covered); YB-15's new "demo fixture store" concept for scope creep (it is the minimal honest definition of a field that was already required on the wire since rev 1, and is disclosure-only with an explicit no-suppression prohibition — not new scope); the two new store records (`aa93fdf486b9ff91b/dispatched…` and `…/returned…`) are the round-1 review's own lifecycle records, non-train subjects carrying no manifest, valid against base+manifest schemas. One observation, not a finding: YB-11's `scripts/probes/go/ pattern check` is a forward reference — that directory holds the FACT probes today, not a pattern-check probe; the plan rung must actually build it (below), or the standing RE2 rule is prose without its mechanism.

## CONVERGENCE RULING (round 2, explicit)

**HEALTHY AND TERMINAL. NO CAP, NO ESCALATION.** Series: **4 → 0 Major**, **5 → 0 Minor**. Walking the three swirl triggers: Majors declining (4→0, strictly — the strongest counter-signal); no clustering (every finding closed at its own artifact, none relocated); no fix-created defects (the sweep found none — in particular the SB-1 reformulation did not open a new schema hole, proven by re-running the five injections). Zero of three fire. The instrument (prose requirements + executable schemas/vectors) resolved in exactly one revision; the fixes are substantive, not cosmetic.

## WHAT THE PLAN RUNG MUST CARRY (handoff by document)

1. **Blocking tests before any dependent car (YB-11, design §2c):** (a) a Go draft-2020-12 validator library validates `starcar-artifact.schema.json` AND `starcar-manifest.schema.json` + their vectors, observed; (b) a no-build-step browser JS draft-2020-12 validator validates `yard-snapshot.schema.json`, observed in a bare browser context. Each ships its disclosed-degradation negative branch (structural checks), named in the gating matrix, retirement-triggered on the validator's arrival.
2. **The SB-1 standing rule needs its mechanism:** build the Go pattern-compile probe under `scripts/probes/go/` (co-located with the existing FACT probes) that walks every `pattern` in every landed schema and RE2-compiles it; wire it so a non-RE2-compatible pattern is a red. (I demonstrated the check is trivially buildable and currently passes 4/4.)
3. **YB-9 watched-to-fire (Q1 binding condition):** the D18 cross-verifier is a REAL CI job running BOTH the pwsh detector and the Go fold against every `schema/vectors/fold/` vector; it is DONE only when an INJECTED divergence has been WATCHED to fail it — fault-inject, observe red, revert, record the run URL. A read-back green is not proof.
4. **Car split hints (§9, D10 ordering):** toolchain/CI car FIRST; then schema+vocab+payload-`$defs`; then fold-port + the YB-8 detector empty-vocab fix (red-first against `empty-vocab-one-fault.json`) + the YB-10 vector rehome (its own reviewed task, never bundled into the Go-port car); then server (carries YB-14 Assembler membership-collision, YB-12 server behaviours, the state-ledger rows); then view+README (carries YB-6 three-axis matrix, YB-15 demoMode banner, the "no adapters ship yet" line dies, doc sentence-check at its review). The backfill manifest (§8) and the YB-9 fault-injection are conductor handbacks inside existing dispatches, not extra cars.
5. **Living-contract obligations restated at plan rung:** the §6 state-ledger rows land with the server car in the same commit (old→delta→new); the five gating-matrix truth surfaces + any validator-degradation rows land with their mechanisms; the design amendment block (YB-2 role split, §3 `storePathDisplay` naming) is the conductor's on spec approval.

## CONSTITUTION CHECK (reviewer duty)

| Law | Verdict at rev 2 | Evidence |
|---|---|---|
| **1. Truth** | **HONORED.** | SB-3 closed: `demoMode` is now a defined disclosure field that may mute no truth surface (YB-15 + schema description); no confident-falsehood surface remains. |
| **4. Nothing Silently Lost** | **HONORED.** | SB-2 closed: the two-manifests-claim-one-dispatch case now renders in both trains with a named board condition (YB-14), never silent precedence. |
| **6. One Truth** | **HONORED.** | SB-1 closed: the manifest schema loads on BOTH languages (RE2 walk 4/4), restoring the one-schema-both-languages thesis (D15); the standing RE2 rule guards it going forward; vectors remain the sole fold authority (two OBSERVED vectors re-verified deep-equal). |
| **7. The Stranger** | **HONORED.** | SB-5 closed (runner contract now self-sufficient for an independent implementer); SB-7 closed (roles vocab honest to observation/contract); open vocabularies as data preserved. |
| **Match the instrument** | **HONORED.** | Formats live in executable schemas/vectors, requirements in prose; the round-1 defects were content and were fixed as content in one revision — the gate resolved at the defect's scale, no instrument change needed. |

I edited nothing, committed nothing, pushed nothing. Worktree is as I found it at `9e8e146e59f69107e5d19be038c824faa63aa21f`.

```starcar-artifact
outcome: APPROVE
findings: 0 Major, 0 Minor, 0 new findings at round 2. All nine round-1 findings folded in substance and verified. SB-1 (was Major) PRESENT-fixed: the manifest schema's second allOf branch is reformulated lookahead-free (not around a positive ^train: pattern); I re-ran the five fault-injection directions under .NET Test-Json (good passes, train-without-manifest fails, non-train-with-manifest fails, plain held passes, bad charclass fails) and wrote a recursive pattern-walker in Go that RE2-compiles every pattern across all three schemas - 4 patterns, 0 failures; YB-11a now names the manifest schema in the Go conformance set and a standing RE2-compatibility rule (no lookahead, no backreferences) is added with the Go-compile probe as its mechanical check. SB-2 (was Major) PRESENT-fixed no drift: YB-14 restores the Q2 adopted ruling - two manifests claiming one dispatch render in both trains plus board condition manifest-membership-collision naming the dispatch and both train subjects, never silent precedence, red-first fixture named, matches design section 6 line 340 hop for hop. SB-3 (was Major) PRESENT-fixed: YB-15 defines config.demoMode as a demo-fixture-store disclosure whose sole consumer is the view banner, with an explicit no-truth-surface-may-branch prohibition and a red-first staleness-fires-on-stale-demo-data test; the wire schema description points at YB-15 and contradicts nothing. SB-4 (was Major) PRESENT-fixed no drift: empty-vocab-one-fault.json now expects one combined fault identical in shape to malformed naming every empty file, disclosed in YB-8 and the vector description; I re-ran the detector and confirmed the dispatches and intents blocks are unchanged from the observed versions and still red-on-arrival by design. SB-5 through SB-9 (Minors) all PRESENT-fixed: README runner contract pins vocab file naming and the values-wrapper shape; cross-language fault-string posture disclosed in YB-8 and README with structured codes as the trigger-gated alternative; roles.json dropped conductor with the epistemic rule noted at YB-2; YB-6 is now a three-axis position-by-freshness-by-capability matrix with the no-renderer load-bearing case; YB-13 names the DR3-3 namespace collision and defers the Q2 membership collision to YB-14 distinctly. Fresh-eyes diff sweep e3b6125..9e8e146 found no new defect - the two new store records are the round-1 review's own lifecycle records (non-train, no manifest, valid), and YB-15's demo-fixture-store concept is the minimal honest definition of a field already required on the wire, disclosure-only. One handoff observation not a finding: YB-11 references a scripts/probes/go pattern-check probe that does not yet exist there (that dir holds the FACT probes), so the plan rung must build it to make the standing RE2 rule mechanical. The landed round-1 verdict at artifacts/reviews/2026-07-23-board-spec-round1-REJECT.md exists and its envelope is byte-identical to what I produced.
abstract: APPROVE at spec gate round 2, delta verify-the-fix, same-agent reuse. Convergence HEALTHY AND TERMINAL: 4 to 0 Major and 5 to 0 Minor, every finding closed at its own artifact with none relocated and no fix-created defects - zero of three swirl triggers fire. The two Major schema defects are proven closed by re-execution not marker: the lookahead-free manifest schema passes all five .NET fault-injections and every schema pattern now RE2-compiles under the repo Go toolchain (4 of 4, zero failures), restoring the one-schema-both-languages Law 6 thesis. The two Major carrier and definition gaps are restored as YB-14 (Q2 membership-collision board condition, no drift from design section 6) and YB-15 (demoMode defined as disclosure-only with a no-suppression prohibition and a red-first staleness test). All five Minors closed at their artifacts. The instrument split was correct and the gate resolved in one revision. The spec proceeds to the plan rung with the blocking tests (Go validator over store plus manifest schemas, browser JS validator over the wire schema, the Go pattern-compile probe the standing rule needs), YB-9's watched-to-fire cross-verifier condition, and the five-car split all carried by document.
```