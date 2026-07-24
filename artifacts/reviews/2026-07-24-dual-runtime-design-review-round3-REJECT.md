<!-- starcar-integrity: sha256=2eddc56651b8b64244e0a1377faffb0160cd6a24bb2aacbf786862fe24677eb6 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Dual-runtime harness design review - round 3 - REJECT

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: adversarial design review
Round: 3
Target: `docs/design/2026-07-24-dual-runtime-harness-design.md rev 3 (60b7ca4)`
Base reviewed: `35570e1`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `design-review-47-r3`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `35570e1` |
| Entire checkpoint | `fb0be7a25df8` |
| Dispatch, the locator within the session | `design-review-47-r3` |
| Entire session (context, NOT a lookup key) | `dr47-r3-transcript` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 35570e1
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Decisive evidence for §10 Q2 and for severity: the **detector** (`Detect-Dispatches.ps1:163-169`) groups records **by `subject`** and applies precedence `returned > presumed-lost > dispatched` per subject — so it, not just the yard board, pairs dispatched↔returned by subject. A non-unique subject collapses two dispatches into one rendered state. I have everything I need.

## Verdict

**Base:** HEAD `35570e1`, rev-3 design `60b7ca4`, round-2 verdict `6f605ce`, `da02ed7` beneath — matched. Reviewed the design at `60b7ca4`; diff `3bcb751..60b7ca4` is the delta.

**Prior-finding walkthrough (re-derived, not trusted):**

| Prior | Rev-3 status | Evidence I verified |
|---|---|---|
| DR-4 (Major) | **ABSENT — folded substantively** | §9c "adopted"; D7 rewritten to two changes (filter + subject rewire at `:148` accepting `tool_response.agentId` OR `tool_input.name`); §5.2 adds the rewire + a red proving `:151` throws today; §3b-8 quotes the real keyset. I re-confirmed the compat launch keyset has no `tool_response`/`agentId`/`toolCallId`, and `tool_input.name` exists. The specific round-2 defect (filter-alone-false, `:148` throws, nonexistent toolCallId fallback) is genuinely addressed. |
| DR-5 (Minor) | **ABSENT — fixed** | §3b-4 restated: "3 are from this Copilot session... all 3 carry `tool_name: Agent`... other 41 are Claude Code... evidence for nothing Copilot-side." I re-counted: 3 Copilot / 41 Claude. Correct. |

Both prior findings resolved. **But the DR-4 fix established a join key (`tool_input.name`) whose non-uniqueness is a new Major.**

**§3b-8 re-derivation (my own, from `events.jsonl`):**
- `tool.execution_start` carries `arguments.name` and `toolCallId` — ✓. The 3 **real** dispatches (`subagent.started` toolCallIds `toolu_018vax`/`017cP`/`01QWk`) map to names `car46-fix-cycle`/`car46-review-r2`/`design-review-47` — distinct, join works 3/3 as claimed.
- Timing: subagentStop @11:31:08.110 fired 2.87s before `subagent.completed` @11:31:10.976; in-flight (started−completed) = {toolu_018vax} at stop 1, {toolu_017cP} at stop 2 — ✓ the "~2s before, in-flight = started minus completed" claim holds for both observed stops.
- **The hole:** `arguments.name` "car46-fix-cycle" appears on **5 distinct toolCallIds** in this one session (multi-turn reuse). The launch payload's ONLY per-dispatch id is `tool_input.name` (verified: the only other id key is the shared parent `session_id`). The name is operator-chosen and demonstrably reusable.

**New finding — DR-6 (MAJOR), §3b-8 / D7 / §6 / §2c-4:** The DR-4 fix makes the dispatched↔returned join key `tool_input.name` (launch) = `execution_start.arguments.name` (stop). §3b-8 asserts as settled fact "dispatched↔returned pairing **survives** under Copilot," and §9c retracts "partial coverage breaks nothing" precisely because pairing matters. But the chosen key is **non-unique by construction**: I observed the name "car46-fix-cycle" on 5 toolCallIds in one session, and the launch payload carries no other stable per-dispatch id. In this repo's own workflow — this design is on round 3; car46 ran rounds 1 and 2 — re-dispatching a same-named agent across rounds is routine, and each produces a `dispatched` and a `returned` record with the **same `subject`**. Two consumers then collapse them: the yard board (#1, which §9c names) and — the design does NOT name it — the **detector** `Detect-Dispatches.ps1:163-169`, which groups `$bySubject` and applies precedence `returned > presumed-lost > dispatched` **per subject**. So two distinct Copilot dispatches sharing a name render as ONE dispatch state (returned wins); the second vanishes from the count — silently, with no `subject_basis` disclosure, because each individual join "succeeded." This is the Law-4 "two observations collapsed into one id" and Law-1 "confident falsehood on a status surface" class — the worst defect the constitution names — and it is a **Copilot-specific regression** the Claude path (subject = unique `agent_id`) never had. §6's failure taxonomy has a row for "join **fails** (no match)" but none for "join is **non-unique**"; §2c-4 is scoped to "two **overlapping** background agents," which does not cover serial name reuse (at each serial stop the in-flight set is size 1 and the join succeeds unambiguously — the collision surfaces later, at the store/detector, not at the hook). A sounder key was reachable — correlate the launch's `execution_start` entry to recover its unique `toolCallId` on both sides — but the design settled for the non-unique name-space and asserts pairing "survives" without the uniqueness premise that claim requires.

**New finding — DR-7 (MINOR), §5.2 / D4 / D7:** The stop-side three-hop join reads the parent `events.jsonl` (2 MB+, actively appended by the running Copilot process) at stop time to compute in-flight and look up `execution_start`. The design never names the read discipline this requires: a torn final line will throw a naive per-line `json.loads`, and a non-shared open can hit a Windows sharing violation. Solvable (the existing probe uses try/except), but it is load-bearing for D4/D7 and belongs in the design as a named hazard or §2c row rather than left implicit.

**§10 rulings:**
- **Q1 (is `subject_basis: name-time` an acceptable floor, or is the join blocking for D7 landing?):** Blocking — and the §2c-4 probe as scoped (overlap) is insufficient. `name-time` handles *join failure*, not *join success with a colliding name*, which is the mispairing that actually bites (DR-6). D7 should either recover the unique `toolCallId` via `execution_start` correlation on both sides, or add a collision detection + disclosure and a §6 row, before landing.
- **Q2 (any consumer beyond the board that pairs?):** Yes — `Detect-Dispatches.ps1:163-169` groups and applies precedence **by subject**; it is the primary pairing consumer (it mints `presumed-lost`/liveness per subject), and the design must name it. §9c's "the yard board is the consumer that pairs" is incomplete.

**Convergence ruling:** trajectory 3 → 2 → 2 findings, but the *Major* has moved down one layer each round **within D7's identity model** (R2: subject extraction throws → R3: subject key non-unique). That is the template's own warned pattern — a prose instrument iterating on a protocol, resolving one defect and exposing the next in a single clustered section (the harness-#7 wreckage: rounds climbing in one section). Per §0's own doctrine, *identity, join keys, dedup and ambiguity are format/protocol — prose cannot hold them.* §0 correctly carved payload **shapes** into probe tests but left the dispatched↔returned **identity/join model** in prose. The productive move for round 4 is to pull that model into an executable identity spec + conformance fixtures (colliding-name and overlapping-agent vectors), rather than iterate it in prose a fourth time.

**Carry for the round-4 (rotated) reviewer:**
- REJECT stands on DR-6 (Major): name-space subject is non-unique (`car46-fix-cycle` on 5 toolCallIds); detector (`Detect-Dispatches.ps1:163-169`) and board both collapse by subject → silent loss of a second same-named dispatch; no `execution_start`→`toolCallId` recovery attempted; no collision failure-mode row.
- Do NOT re-litigate (verified sound this round): compat executes `sh script.sh` hooks and delivers snake_case (§3b-1/2); filter root cause `Produce-Artifact.ps1:141-147`; DR-1/2/3/4/5 folds; §3b-8 timing (started−completed, ~2s) and the literal 3/3 distinct-name join; StoreIntegrity+Producer = 143/143 at `35570e1`; StoreIntegrity has no pairing assertion (so the collapse is a *rendering* defect at the detector/board, not a store-integrity failure).
- Open: DR-7 (live events.jsonl read discipline); the §0 instrument-scope question (move identity model to executable spec).

```starcar-artifact
outcome: REJECT

findings:
  count_by_severity:
    major: 1
    minor: 1
  prior_round_dispositions:
    DR-4_major: ABSENT (folded substantively - D7 rewritten with subject rewire at :148 using tool_input.name; :151 throw acknowledged with a named red; keyset quoted in 3b-8; all re-verified)
    DR-5_minor: ABSENT (3b-4 restated 3/3 Copilot; re-counted 3 Copilot / 41 Claude)
  new:
    DR-6_MAJOR: "3b-8/D7/6/2c-4. The DR-4 fix makes the dispatched-returned join key tool_input.name = execution_start.arguments.name, and 3b-8 asserts pairing 'survives' as settled fact. But the key is non-unique by construction: observed 'car46-fix-cycle' on 5 distinct toolCallIds in one session; the launch payload has no other per-dispatch id (only the shared parent session_id). Same-named re-dispatch across rounds is this repo's normal workflow. Two consumers collapse by subject - the yard board (#1) and, unnamed by the design, the detector Detect-Dispatches.ps1:163-169 which groups by subject and applies precedence returned>presumed-lost>dispatched - so two distinct dispatches sharing a name render as one, the second silently lost (Law 4) and the board shows a confident falsehood (Law 1). Copilot-specific regression; Claude path used a unique agent_id. 6 has a 'join fails' row but none for 'join non-unique'; 2c-4 covers overlap not serial reuse. A unique toolCallId was reachable via execution_start correlation but the design chose the non-unique name-space."
    DR-7_MINOR: "5.2/D4/D7. The stop-side three-hop join reads the parent events.jsonl while the runtime is appending to it; the design does not name the torn-final-line / shared-read discipline required, and a naive per-line JSON parse throws on a partial write. Solvable but load-bearing and unstated."
  section10_rulings:
    Q1: "Blocking for D7 landing; 2c-4's overlap probe is insufficient - name-time handles join failure, not join-success-with-colliding-name, which is the real mispairing. Recover a unique toolCallId on both sides, or add collision detection + disclosure + a failure-mode row."
    Q2: "Yes - Detect-Dispatches.ps1:163-169 pairs by subject and mints presumed-lost/liveness per subject; the design names only the board. 9c's retraction is incomplete."
  convergence: "3->2->2 findings, but the Major moved down one layer within D7's identity model each round (R2 subject-extraction, R3 subject-uniqueness) - the template's warned pattern of prose iterating on a protocol. Recommend pulling the dispatched-returned identity/join model out of prose into an executable spec + conformance fixtures per section-0's own doctrine before round 4."
  suites_run_by_reviewer:
    at_sha: 35570e158f982df84c344693784d7a93bd1b423a
    StoreIntegrity_plus_Producer: 143 passed, 0 failed, 0 skipped (Pester 5.8.0)

abstract: |
  Delta re-review of the dual-runtime harness design rev 3 at 60b7ca4 (dev HEAD 35570e1, verified). Both round-2 findings are resolved substantively, re-derived against the real probe-logs and events.jsonl: DR-4's launch-subject rewire now uses the extant tool_input.name and DR-5's population count is corrected to 3/3 Copilot. REJECT stands on one new Major (DR-6): the join key the DR-4 fix established - the operator-chosen agent name - is non-unique (observed on 5 toolCallIds in one session, no other per-dispatch id in the launch payload), so two same-named dispatches collapse to one subject at BOTH the yard board and the detector (Detect-Dispatches.ps1:163-169, which the design fails to name), silently losing the second dispatch - a Copilot-specific Law-1/Law-4 regression that section 3b-8 overstates as pairing that 'survives'; plus one Minor (DR-7) on unstated live-file read discipline. The Major has moved down one layer within D7 each round, the template's signature protocol-in-prose pattern; recommend an executable identity spec before round 4. Reviewer ran StoreIntegrity+Producer at 35570e1 = 143 passed, 0 failed.
```