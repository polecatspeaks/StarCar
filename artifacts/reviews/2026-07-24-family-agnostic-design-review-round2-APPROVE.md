<!-- starcar-integrity: sha256=f2128c00a9530341b278e8f03a882f0509ac87c2276c4588b1700da22ee180b3 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Family-agnostic harness design review, round 2 (delta)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: design-review
Round: 2
Target: `docs/design/2026-07-24-family-agnostic-harness-design.md`
Base reviewed: `3c48787d318571dc03245a262b38d1daa6ae8419`
Reviewer: design-review-47b
**Verdict: APPROVE**

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
| Base commit the reviewer read (**the lookup key**) | `3c48787d318571dc03245a262b38d1daa6ae8419` |
| Entire checkpoint | `53754d5ac56c` |
| Dispatch, the locator within the session | `design-review-47b` |
| Entire session (context, NOT a lookup key) | `dr47b-r2-transcript` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 3c48787d318571dc03245a262b38d1daa6ae8419
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Base verified (`3c48787`, `dev`), diff read in full, and every code citation rev 2 now leans on is confirmed at this SHA:
- `Produce-Artifact.ps1:7-10` — the "TWO PAYLOADS, ONE SUBJECT (Probe 5, measured) … IDENTICAL" fact that mode (b) rests on. Verified.
- `Detect-Dispatches.ps1:210-214` — the `$superseded` exposure array DR-10 now correctly points to. Verified.
- `schema/vectors/fold/precedence-dispatched-then-returned.json` — exists. Verified.
- Round-1 verdict present at `artifacts/reviews/2026-07-24-family-agnostic-design-review-round1-REJECT.md`; §9c's summary of my DR-8/9/10 matches my round-1 report verbatim (no laundering of my own findings).

I did not re-run the 261/22 suites: no disposition claim depends on a suite count — the three code behaviours the fixes lean on I checked by direct inspection above.

---

# Adversarial design review — Family-agnostic harness design, round 2 (delta) — APPROVE

**Base:** HEAD `3c48787d318571dc03245a262b38d1daa6ae8419` on `dev` (rev 2, "DR-8/9/10 folded"). Diff reviewed: `ea5d608..3c48787 -- docs/design/` (47 insertions, 25 deletions, one file).

**Verdict: APPROVE.** All three round-1 findings are substantively folded (not laundered). One new Minor (DR-11) and a boundary note; neither blocks. Swirl trajectory is healthy (Major 1→0); I flag one fix-induced Minor and set a watch below, but no cap triggers.

---

## Disposition walk (Present / Absent / DRIFTED)

### DR-8 (Major, round 1) — **PRESENT (substantively resolved)**

My round-1 Major had three prongs; I trace each across the fix hop-for-hop:

1. **Launch-side pairing regression / unproven carrier.** Rev 2 splits D2 into per-family adapter modes. Mode (b) (Claude, until §2c row 2 probes) sets `subject` = the runtime's own stable pairing id at *both* launch and stop — the `agentId`/`agent_id` pair the producer header at `Produce-Artifact.ps1:7-10` documents as *identical* (Probe 5, measured). This is exactly my round-1 prescription's second option: keep the working UUID pairing, minted id as a declared alias. Claude's pairing is **kept, not demoted**. One dispatch = one subject. Prong resolved.
2. **The mispaired `envelope-pending` fallback + §7 contradiction.** §6 row 2 is rewritten: mode (b) pairs by the runtime id at both ends, `subject_basis: runtime-id` disclosed — the orphaning `envelope-pending` construct is deleted. §7 is reconciled: post-read enrichment is now annotated "no longer load-bearing … no record waits on a later join." I confirmed this is internally true: in mode (b) both records carry the UUID subject and pair at the fold immediately; the minted id (`task_id`) is a non-key field, so nothing waits. The contradiction I flagged is gone. Prong resolved.
3. **The false "envelope proven today."** Corrected in three places — a new §2 correction note ("FALSE, and the round-1 reviewer caught it … the RUNTIME's `<task-id>` task-notification tag, which `Land-Verdict.ps1:125` greps … not the envelope"), §2c row 2, and §5.7 ("the envelope carries no task-id today (`car.md:28`)"). All three now state the echo is new work. Prong resolved.

**The §2c row 2 Blocking flip Yes→No — I was asked to verify this is sound. It is.** Mode (b)'s build needs only (i) the Probe-5-proven identical UUID as subject and (ii) the car's own envelope `task_id` echo, which is observable in the car's *own* transcript and needs no Claude-label probe. The Claude-label probe gates only the *upgrade* to mode (a) (minted id as subject at launch). And #47's acceptance — "work lands in the store" with correct pairing — is met by mode (b). So the probe is genuinely non-blocking for the build and for closing #47; it is a nice-to-have upgrade gate. The flip is honest.

§9b's DR-6 row is reworded from the overclaiming "dissolved structurally, not patched" to "name-space axis dissolved structurally; pairing axis specified per adapter mode, **not overclaimed**," and D2 states plainly "The pairing guarantee is not asserted beyond its evidence: mode (a) where probed, mode (b) where not." That is the honest form. **Not laundered.**

**Internal-consistency sweep (the DRIFTED class):** the two-mode model appears and agrees in D2, D3, §5.4, §6 row 2, §9b, §2c row 2, and the P1 If-false cell. No section carries the old single-mode story. Consistent.

### DR-9 (Minor, round 1) — **PRESENT (resolved)**

The §1 Healing-Loop row no longer claims structural impossibility for a discipline property; it now reads "Mint-vs-mint collisions are NOT made structural by a naming convention alone — so D2 adds a mechanical guard: the producer REFUSES a `dispatched` record whose subject already has an un-superseded `dispatched` record … Uniqueness is mechanical at the mint boundary, not dispatcher vigilance." My Q2 ruling adopted verbatim; guard threaded into D2, D3, §5.4, §6 row 1. Resolved. (One residual shape gap → DR-11.)

### DR-10 (Minor, round 1) — **PRESENT (resolved)**

The detector/board collapse-exposure is re-attributed to the correct (fold) tier: D3 now says "The detector/board duplicate-subject EXPOSURE behaviour is fold-tier and stays pinned where it already is — the existing `schema/vectors/fold/` fixtures (`precedence-dispatched-then-returned.json`; `superseded` array, `Detect-Dispatches.ps1:210-214`) — plus one NEW duplicate-subject fold vector." Both citations verified accurate at this SHA. Adapter-tier vs fold-tier is now clean for the exposure behaviour. Resolved.

### R1 NOTE (`TranscriptRead.ps1`) — **PRESENT**

§1 rewrite-vs-extend row now states explicitly the file "does not exist at base" and is new work extracted from `Produce-Artifact.ps1:158+`, with "survives" scoped to the *decision*. Honest.

---

## New finding

### DR-11 — MINOR — The DR-9 refusal guard is stateful, but D3 folds it into the stateless adapter-vector contract without giving it a store-state input shape or a tier home

D3 lists the guard as an adapter conformance case: "given a `dispatched` whose subject already has an un-superseded `dispatched` record, a REFUSAL with a loud fault." But to know a subject "already has an un-superseded `dispatched` record," the producer must **read the store** — the guard is stateful. D3's other four cases are pure stateless event→record ("given a dispatch-start event … a conforming adapter yields a record"), and D3 describes the adapter vectors as "declarative input → expected records." A refusal that depends on pre-existing store state does not fit that shape: the fold vectors carry store state (`input.records`, per `schema/vectors/README.md`), the adapter vectors as described do not. D3 does not say whether the refusal is proven by (a) an adapter vector extended with a store-state precondition field, (b) a fold vector, or (c) a `Producer.Tests.ps1` integration test.

**Why it matters (and the swirl watch):** this is the DR-10 *class* recurring — a guard attributed to a vector tier whose shape does not hold it — and it was **introduced by the DR-9 fix**. Per the round-2 brief I flag it explicitly: it is a fix-induced defect in the same family as a prior finding. It is a single **Minor**, not a Major, and Majors did not cluster (1→0), so no cap or escalation triggers — but I set the watch: **if round 3 produces another vector-tier/shape mismatch, that is the swirl pattern and the next reviewer should treat it as a convergence signal, not a fresh point defect.**

**Fix requires:** D3 states where the refusal guard's red-first proof lives and with what input shape — either define a producer/harness vector that admits pre-existing store records as input (naming it distinctly from the stateless adapter vectors), or rehome the guard's proof to `Producer.Tests.ps1` / a fold vector — and say which. The guard's *semantics* are clear; only its provable home is underspecified. A guard is unproven until something has watched it fire, so its vector home must be coherent enough for the car to land it red-first.

---

## §10 rulings

**Q1 — Is the disclosed mixed-semantics store (mode-(b) UUID subjects beside mode-(a) minted-id subjects) acceptable, or is there a cheaper uniform alternative? — RULE: ACCEPTABLE; no cheaper uniform alternative exists.**

Pairing correctness (the Law-1/Law-4 property — one dispatch renders as one subject) holds in *both* modes, and the heterogeneity is disclosed record-by-record via `subject_basis`. Every consumer that pairs — the detector (`Detect-Dispatches.ps1` groups by subject), the board, `Land-Verdict.ps1` — is indifferent to whether a subject is a UUID or a minted id, as long as launch and stop share it (they do in both modes). A uniform-minted-id store would require, for Claude, one of: (i) mode (a) at launch — the *unproven* label carrier, i.e. the exact regression risk we are avoiding; (ii) rewriting the launch record's subject at return from the envelope — post-read enrichment, which §7 excludes and which mutates a landed record; or (iii) abandoning pairing until return. All three are worse than disclosed heterogeneity. **One cost the reviewer accepts explicitly:** in mode (b) the *in-flight* `dispatched` record carries only the UUID (the minted id arrives on the `returned` record via the envelope `task_id`), so a running Claude dispatch shows on the board keyed by UUID, not by `47-review-r2`, until it returns. This is less glanceable but honest (`subject_basis: runtime-id` discloses it) and is precisely what the mode-(a) upgrade (§2c row 2 probe) removes. #47's acceptance does not require minted-id-on-dispatched, and the design does not overclaim, so this is an acceptable disclosed interim, not a finding.

**Q2 — Refusal-guard precedence: loud-refuse-and-keep-first, or mint-a-disambiguated-subject-and-disclose? — RULE: LOUD-REFUSE-AND-KEEP-FIRST.**

Three reasons: (1) A duplicate mint is an operator error or a bug, not a legitimate second dispatch. Auto-disambiguating to `-dup2` would silently absorb the error into a plausible-looking record — the "confident falsehood / paper-over" failure (Law 1) the whole design fights; refusing loudly surfaces it at the cheapest point, the mint, where it is fixable (Law 4). (2) Keep-first leaves the already-in-flight dispatch's identity stable so its `dispatched`↔`returned` pair resolves correctly; the refused second never enters the store, so nothing collapses downstream. (3) Minting a disambiguated subject fabricates an id the conductor never minted — inventing identity the shop did not issue, directly against D2's "minted by the shop, carried, never scraped." **One boundary the design must state explicitly:** the guard's "un-superseded" scope means a same-minted-id re-dispatch *after* the first has already returned (its `dispatched` now superseded by the `returned`) is NOT refused. That residual is caught downstream by the fold's superseded-exposure plus the new duplicate-subject fold vector (DR-10), and the `ticket-role-round` convention makes exact-id reuse an operator error rather than normal workflow — so it is acceptable, but the design should say so, so the guard is not read as catching *all* same-subject reuse. Fold this sentence into D2/§6 row 1 when DR-11 is addressed.

---

## Constitution check (diff-implicated laws)

- **Law 1 (Truth):** now honored where round 1 found it broken — the "envelope proven today" falsehood is corrected in three places; mode (b) renders one dispatch as one subject with `subject_basis` disclosed; the duplicate-mint guard refuses loudly rather than papering over.
- **Law 4 (Nothing silently lost):** the mispairing-into-two-subjects path is deleted; the refusal guard emits a loud fault; the fold still exposes superseded records. No silent loss remains in the diff.
- **Law 6 (One truth):** one producer, one extractor home (now honestly labelled new work), exposure pinned at its single correct (fold) tier. DR-11 is the one residual one-authority ambiguity (which tier proves the guard).
- **Law 7 (Stranger / family-agnostic):** the mode split *is* Law 7 applied honestly — Copilot and Claude each adapt to the repo's contract at the evidence each family actually affords, neither forced onto the other's substrate.
- **Carrier rule:** identity crosses in the brief (out) and envelope (back); the envelope echo is correctly scoped as new work, not asserted as pre-existing.

APPROVE. DR-11 is a Minor to resolve at spec/plan time (or by the car while building D3's vectors); the two §10 rulings above are binding inputs to that work.

```starcar-artifact
outcome: APPROVE

findings:
  - DR-8 (round-1 MAJOR): PRESENT/RESOLVED - per-family adapter modes; mode (b) keeps Claude's Probe-5-proven identical-UUID pairing (never demoted), envelope-pending mispairing deleted, section 7 reconciled, false "envelope proven today" corrected in three places, section 2c row-2 Blocking flip Yes-to-No verified sound. Not laundered.
  - DR-9 (round-1 MINOR): PRESENT/RESOLVED - mechanical duplicate-dispatched refusal guard replaces the structural-impossibility overclaim; Q2 ruling adopted.
  - DR-10 (round-1 MINOR): PRESENT/RESOLVED - collapse-exposure re-attributed to existing fold vectors + one new duplicate-subject fold vector; both code citations (Detect-Dispatches.ps1:210-214, precedence-dispatched-then-returned.json) verified.
  - DR-11 (new MINOR): the DR-9 refusal guard is stateful (must read the store) but D3 folds it into the stateless adapter-vector contract without a store-state input shape or a named tier home - same class as DR-10, fix-induced; swirl-watch set (not a cap, single Minor, Majors did not cluster).

abstract: >
  Round-2 delta re-review of the family-agnostic harness design at base 3c48787 (dev,
  verified), diffing ea5d608..3c48787. All three round-1 findings are substantively
  folded, not laundered: DR-8's Major is resolved by a per-family adapter-mode split
  that keeps Claude's Probe-5-proven identical-UUID pairing (mode b) instead of demoting
  it to an unproven minted-id carrier, deletes the mispairing envelope-pending fallback,
  reconciles the section-7 enrichment exclusion, and corrects the false "envelope proven
  today" claim in three places; the section-2c row-2 Blocking flip is independently
  verified sound because mode (b) needs no Claude-label probe. DR-9 (mechanical
  duplicate-dispatched refusal guard) and DR-10 (fold-tier exposure re-attribution) are
  cleanly folded with citations verified. One new Minor (DR-11): the DR-9 guard is
  stateful but D3 attributes it to the stateless adapter-vector contract without a
  store-state input shape or tier home - same class as DR-10 and fix-induced, so a
  swirl-watch is set though no cap triggers. Both new section-10 questions answered:
  mixed-semantics store ACCEPTABLE (no cheaper uniform alternative that does not regress
  pairing or lean on unproven carriers), and refusal precedence LOUD-REFUSE-KEEP-FIRST
  with the un-superseded boundary to be stated explicitly. APPROVE.
```