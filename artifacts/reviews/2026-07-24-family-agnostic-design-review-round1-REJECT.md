<!-- starcar-integrity: sha256=e2ba73611924c0f9d0313b97a0ba2db4dc508406a634a0ead3fe14767567f75f covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Family-agnostic harness design review, round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: design-review
Round: 1
Target: `docs/design/2026-07-24-family-agnostic-harness-design.md`
Base reviewed: `b3032b47d9e7bfaa2ba5a556fc19b713125b303f`
Reviewer: design-review-47b
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `design-review-47b`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `b3032b47d9e7bfaa2ba5a556fc19b713125b303f` |
| Entire checkpoint | `9c98643bce19` |
| Dispatch, the locator within the session | `design-review-47b` |
| Entire session (context, NOT a lookup key) | `dr47b-r1-transcript` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain b3032b47d9e7bfaa2ba5a556fc19b713125b303f
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Agent is idle (waiting for messages). agent_id: design-review-47b, agent_type: car, status: idle, description: Round-1 review: family-agnostic design, elapsed: 698s, total_turns: 1, model: claude-opus-4.8

[Turn 0]
I have everything I need. Base verified (b3032b47d, `dev`), suites run green by me (261/0 and 22/0), citations traced. Here is my verdict.

---

# Adversarial design review — Family-agnostic harness design, round 1 — REJECT

**Base:** HEAD `b3032b47d9e7bfaa2ba5a556fc19b713125b303f` on `dev` (short `b3032b4`), clean tree — matches the brief. Reviewed `docs/design/2026-07-24-family-agnostic-harness-design.md` (Status: Open, rev 1).

**Suites run by me at b3032b4 (counts derived, not trusted):**
- `Invoke-Pester -Path scripts/tests` → discovery 261 tests across 15 files; **261 passed, 0 failed, 0 skipped** (Pester 5.8.0).
- `Invoke-Pester -Path scripts/probes` → 22 tests across 3 files; **22 passed, 0 failed, 0 skipped**. (The checkpoint-reconcile probe fault-injection actually fires — I watched `FIRES and lists commit subjects when the pinned base is behind HEAD` pass, with its control-silent and control-reverted companions.)

**Verdict: REJECT** on one Major (DR-8).

---

## What is sound (verified, not assumed)

- **Problem fidelity (obligation 2):** §3 quotes the ratified statement; work items (a)-(d) from issue #47 map one-to-one to D1-D4. No over-scope (§7 excludes a third adapter, big-bang migration, mirroring — NIRTS honored: two adapters, one contract). Confirmed against `gh issue view 47` RATIFIED comment.
- **Citation truth on doctrine (obligation 6, mostly):** Law 6 quote is verbatim (`constitution.md` §6); Law 7 paraphrase is faithful; adapter-doctrine quote is verbatim (`glossary.md:105-107`); carrier-rule quote is verbatim (`CLAUDE.md:76`); rewrite-vs-extend (`CLAUDE.md:78,890`), NIRTS (`CLAUDE.md:28`), AGENTS.md "tool-maintained, not hand-herded" (`doc-map.md`) all check out.
- **The name-space axis of DR-6 IS genuinely dissolved:** under D2 the store `subject` is the minted id, so `arguments.name` no longer participates in identity; the 5-toolCallIds/one-name collision the round-3 reviewer constructed cannot reach the store. `Detect-Dispatches.ps1:167-215` groups by subject and exposes non-winners in `superseded` — I read it; runtime UUIDs were never its identity, so demoting them to provenance harms nothing *at the fold*.
- **Detector citation is accurate:** `Detect-Dispatches.ps1:163-169` is where precedence (`returned>presumed-lost>dispatched`, line 164) and subject-grouping (167+) live — the design cites it correctly.
- **The executable-spec instrument (obligation 4) is right at the design level:** D3 enumerates a concrete, testable contract (event → record, four cases) and defers fixture authoring to the car per `schema/vectors/README.md`. That is not protocol-in-prose; the identity SEMANTICS move out of design prose into a named executable artifact. Round-3's core prescription is honored *for the cases D3 enumerates* (see DR-10 for the case it does not).

---

## Findings

### DR-8 — MAJOR — The dispatched↔returned pairing guarantee is asserted as achieved while its launch-side carrier is unproven, its fallback is out-of-scope, and it would demote a currently-working mechanism

The redesign's whole thesis (§9b: DR-6 *"dissolved structurally, not patched"*; D2, line 80: *"dispatched↔returned pair"*) requires **both** record halves to carry the minted id as `subject`. Tracing the two halves hop-for-hop:

- **Return half — robust.** brief → car → envelope echo (§5.7) → producer reads transcript. The producer already extracts the envelope for outcome (`Produce-Artifact.ps1:158+`; `car.md:29-30`). Sound.
- **Launch half — not established.** The `dispatched` record is written at launch, before any envelope exists. For **Claude**, the launch payload (`PostToolUse:Task`) today yields `subject = tool_response.agentId`, a runtime UUID (`Produce-Artifact.ps1:149`), and the header at `:7-10` documents that launch/stop UUIDs are *identical* — i.e. **Claude pairing works TODAY via the runtime UUID.** D2 demotes that UUID to "optional provenance" and needs the *minted id* at launch instead. Whether the Claude launch payload can carry the operator label is **UNPROVEN** — the design itself marks §2c row 2 (line 54) "Blocking … observe `agent_id`/payload." So D2 replaces a working pairing mechanism with an unproven one at the launch boundary.
- **The disclosed fallback does not pair, and its remedy is out of scope.** §6 row 2 (line 117): when the label is absent the `dispatched` record discloses `subject_basis: envelope-pending` — i.e. it does *not* carry the minted id, so it cannot share a subject with the minted-id `returned` record. P1's "If false" cell (line 43) says "the hook-side record then joins on the envelope, **later**" — but §7 (line 127) declares "Automatic post-read envelope enrichment … **out of scope**." So under P1-false the design yields an orphaned `dispatched` (perpetual → presumed-lost) and a separate `returned`: **one dispatch rendered as two subjects** — the Law-1/Law-4 mispairing class DR-6 named, reappearing from the opposite direction, with no in-scope remedy.
- **The reassurance used to wave this away is factually wrong.** P1 If-false (line 43) and §2c row 2 (line 54) both assert "the envelope's task-id already round-trips today … proven by three verdict landings this session" / "the envelope carrier works today on both, proven." It does not. `Land-Verdict.ps1:125` greps the transcript for the **runtime's** `<task-id>` task-notification tag (line 100: "a task-notification carrying `<task-id>`") — that is P1's *runtime-label* carrier, not the starcar-artifact envelope. The envelope mandate carries only "outcome, findings, and abstract" (`car.md:28`) — **no task-id** — which is precisely why §5.7 has to ADD the echo. A field §5.7 adds cannot already round-trip; the "proven today" claim is internally contradictory and is doing false-reassurance on the load-bearing carrier.

**Why Major:** this propagates into the spec/plan as "pairing solved / DR-6 dissolved," when in fact (i) the Claude launch-side minted-id source is unspecified and unproven, (ii) the disclosed fallback mispairs, (iii) the fix is §7-excluded, and (iv) the design would regress Claude's currently-working UUID pairing. Disclosure of §2c row 2 does not clear it, because the defect is not the unknown probe — it is that even the *disclosed* fallback yields a mispairing render the design refuses to remedy while calling the matter dissolved.

**Fix requires:** specify, per family in use, exactly how the `dispatched` record obtains the minted id at launch (for Copilot this is available — `subagent.started.arguments.name`; for Claude it is not established), OR keep the runtime UUID as the launch-side subject with the minted id as a declared alias and specify the reconciliation, AND reconcile the P1-false path with §7 (either bring the later-join into scope or provide a launch-side carrier that needs none). Correct the "envelope carrier proven today" statements to name the runtime `<task-id>` tag as the thing actually proven and the envelope echo as new work.

### DR-9 — MINOR — §1 invokes "structural impossibility beats vigilance" for a uniqueness property that is dispatcher discipline

§1's Healing-Loop row claims D2 satisfies "a structural impossibility beats them all … uniqueness is enforced where the mint happens." But D2 (line 80) states uniqueness "is the dispatcher's discipline," and §10 Q2 asks the reviewer whether a *mechanical* guard is needed — an open question that is incoherent if the property were already structural. Two-minted-ids-colliding is prevented by owner discipline, i.e. vigilance — the very thing the cited law claims to transcend. The runtime-internal-collision *is* structurally impossible (true, substantive); the mint-vs-mint collision is not. **Fix:** either add the mechanical guard (see Q2 ruling) and then the "structural" claim earns its place, or downgrade the §1 row to "single-owner discipline at one mint point" and drop the structural-impossibility framing. Ties to DR-8's §6 "duplicate id" row.

### DR-10 — MINOR — §9b/§6 attribute the detector/board collapse-exposure to "D3's [adapter] vectors," which do not cover it

§9b (line 159) closes DR-6 with "The detector/board pairing concern is now pinned by D3's vectors instead of prose," and §6's duplicate-id row says "D3's vectors pin the exposure behaviour." But D3's vectors are **adapter-tier** (`schema/vectors/adapter/`, event→record); §5.3 enumerates only the no-envelope-at-stop and unrecognisable-payload vectors — **none exercises the detector's collapse-by-subject.** The same-subject exposure is a **fold-tier** behaviour, already pinned by existing `schema/vectors/fold/` fixtures (`precedence-dispatched-then-returned.json`, the `superseded` array at `Detect-Dispatches.ps1:210-214`). So the behaviour is covered — but by the wrong suite than the disposition names, and D3 specifies no collision vector. **Fix:** attribute the exposure to the existing fold vectors, or add a duplicate-subject fold vector explicitly; do not credit D3's adapter suite with a fold-tier guarantee it does not carry.

**NOTE (not a finding):** §1/D4/§5.5 call `scripts/lib/TranscriptRead.ps1` the extractor that "survives." That file does not exist at b3032b4 (the reader is inline in `Produce-Artifact.ps1:158+`); the superseded design's D5 *proposed creating it* via extraction. "Survives" reads as the decision surviving the reframe, and §5 lists it as work to do — acceptable, but tighten the wording so a plan-writer does not read it as an existing home.

---

## §9b disposition-table walk (Present / Absent / DRIFTED)

| Prior item | Ruling | Basis |
|---|---|---|
| DR-1..5 folds + §3b substrate facts | **Present** | Carried as inherited settled evidence via P4; superseded design confirmed `Status: Superseded`. No re-litigation needed. |
| **DR-6** (Major) | **DRIFTED** | Name-space axis genuinely dissolved (subject = minted id; `arguments.name` out of identity — substantive, verified). But the pairing guarantee the dissolution asserts now rests on an unproven launch-side carrier + a §7-excluded fallback (DR-8). "Dissolved structurally, not patched" overstates: dissolved on one axis, unresolved on the pairing axis. |
| DR-7 (Minor) | **Present** | Shrunk honestly — stop path no longer requires an events.jsonl read for identity; the live-file torn-line discipline is re-homed to D3's absent-envelope vector + runner contract (matches `schema/vectors/README.md`'s existing "skip unparseable / never throw" pattern). Adequate. |
| Round-3 convergence ruling (executable identity spec) | **Present** | §0 split + D3's enumerated contract move identity semantics out of prose into a named vector artifact. Substantive at design tier. |
| Round-3 §10 Q1/Q2 | **Present** | Q1 mooted defensibly (no cross-record join to block once identity is shop-minted). Q2 (detector pairs by subject) adopted and the detector is named. |

---

## §10 rulings

- **Q1 (`ONBOARDING.md` at root vs `docs/onboarding.md`):** Root is the correct call. It maximises stranger visibility (Law 7; parallels README's USER-front-door placement in `doc-map.md`) and the design correctly refuses `AGENTS.md` (GitNexus-owned). No finding — but the §8 commitment to add its `doc-map.md` row is mandatory, not optional, since a new LIVING surface with no map row is itself a doc defect.
- **Q2 (mint convention vs mechanical guard):** A mechanical guard is warranted. Relying on "the dispatcher's discipline" for subject uniqueness is the vigilance the Healing Loop row claims to have beaten (DR-9). Cheapest structural form: the producer refuses to write a `dispatched` record whose subject already has an un-superseded `dispatched` record, emitting a visible fault (Law 4/Law 1), pinned by an adapter or fold vector. This turns duplicate-mint from a silent-ish collapse into a loud refusal at the mint boundary.
- **Q3 (any consumer harmed by runtime ids becoming optional provenance):** **Yes — and this is DR-8.** The fold is unharmed (it never used runtime ids). But the **current producer** uses the runtime UUID as the pairing subject today (`Produce-Artifact.ps1:7-10, :143, :149`); demoting it without a proven launch-side minted-id carrier for Claude is exactly the pairing regression. Not a benign demotion.

---

## Constitution check

- **Law 1 (Truth):** honored in intent (probe-gated "works" claims, visible skips) — but violated in fallback rendering (DR-8: one dispatch → two subjects under P1-false) and in the "envelope proven today" misstatement.
- **Law 4 (Nothing silently lost):** intended (absent-envelope minting, stderr skips) — but the orphaned-dispatched fallback (DR-8) loses the pairing, not the record; disclosed as `envelope-pending` yet unremediated.
- **Law 6 (One truth):** honored — one doctrine body + pointers, one producer, one extractor home (modulo the DR-10 vector-tier misattribution).
- **Law 7 (Stranger / family-agnostic):** honored — the design's spine; front door + neutral contract + demand-driven adapters trace to it.
- **Carrier rule:** honored in structure (identity crosses in brief/envelope) — but the envelope carrier is asserted as existing when it is new work (DR-8).

REJECT stands on DR-8.

```starcar-artifact
outcome: REJECT

findings:
  - DR-8 (MAJOR): dispatched-returned pairing asserted as dissolved, but the launch-side minted-id carrier is unproven for Claude (2c row 2), the P1-false fallback mispairs and its remedy is out of scope (section 7), it demotes Claude's working runtime-UUID pairing (Produce-Artifact.ps1:7-10,143,149), and the "envelope task-id round-trips today" reassurance is false (Land-Verdict reads the runtime tag, not the envelope; section 5.7 adds the envelope field).
  - DR-9 (MINOR): section 1 invokes structural-impossibility-beats-vigilance for subject uniqueness that D2 admits is dispatcher discipline; contradicted by the still-open section 10 Q2.
  - DR-10 (MINOR): section 9b/section 6 credit D3's adapter-tier vectors with the detector/board collapse-exposure, which is a fold-tier behaviour covered by existing schema/vectors/fold, not by any enumerated D3 vector.

abstract: >
  Review of the family-agnostic harness design rev 1 at base b3032b4 (dev, verified);
  scripts/tests 261/0 and scripts/probes 22/0 run green by me. The redesign's problem
  fidelity to issue #47 is clean and the name-space axis of the round-3 DR-6 defect is
  genuinely dissolved, but REJECT stands on one Major (DR-8): the dispatched-returned
  pairing the design calls structurally dissolved rests on an unproven launch-side
  minted-id carrier for Claude, a disclosed fallback that mispairs one dispatch into two
  subjects with its only remedy declared out of scope, and a false "envelope carrier
  proven today" reassurance (the proven mechanism is the runtime task-notification tag,
  not the envelope field section 5.7 has yet to add). Two Minors accompany it: a
  structural-impossibility overclaim for what is dispatcher discipline (DR-9) and a
  fold-vs-adapter vector-tier misattribution in the DR-6 disposition (DR-10). Fix the
  launch-side carrier and the section 7 contradiction, add a mechanical uniqueness guard
  (Q2), and correct the carrier-provenance statements.
```