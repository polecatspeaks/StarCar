<!-- starcar-integrity: sha256=cb78724e5e08d1405a593c10146c609cf67e3a3b9c43bc06a84d7bfca1c556d5 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Family-agnostic harness car review, round 2 (fix-cycle delta)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-review
Round: 2
Target: `car/47-family-agnostic`
Base reviewed: `8b17196`
Reviewer: 47-car-review-r1
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `47-car-review-r1`. The conductor did not retype a word of what follows. Verbatim by
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
> Path normalisation: the repository root was rewritten to ``<repo>`` and the operator home directory to ``~``, BEFORE hashing. Mechanical and narrow: only those two roots, longest-first, no other substitution. This is portability, not curation - findings, verdicts and counts are untouched, and the un-normalised original is on the Entire checkpoint branch.

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `8b17196` |

| Dispatch, the locator within the session | `47-car-review-r1` |
| Entire session (context, NOT a lookup key) | `cr47-r2-transcript` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 8b17196
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Worktree clean, HEAD `8b17196`. Verdict follows.

---

# Delta Re-Review (fix-cycle round 1) — Car 47 family-agnostic harness — APPROVE-FOR-MERGE

**Dispatch:** `47-car-review-r1`
**Base verified:** HEAD `8b17196`, parent `0f3ae88` (my round-1 target), branch `car/47-family-agnostic`, worktree `<repo>-car47`. Fix commit touches exactly 3 files, docs/vectors only, no code change. ✓
**Verdict: APPROVE-FOR-MERGE.** Both prior findings resolved and independently re-verified; one Minor carried for the record (non-blocking).

## Suites I ran myself at 8b17196
| Suite | My observed | Car claimed |
|---|---|---|
| `scripts/tests` | **276 passed, 0 failed** (was 275; +1 = new vector) | 276/0 ✓ |
| `scripts/probes` | **22 passed, 0 failed** | 22/0 ✓ |

## Finding dispositions

### CR-1 (round-1 MINOR) — **PRESENT / RESOLVED**
Both the vector `description` and the README provenance row were corrected to *"the landed base producer (df4fb95) exits 0 silently at the `subagent_type` launch filter (`if ([string]::IsNullOrWhiteSpace($subagentType)) { exit 0 }`)... never reaches the `tool_response.agentId` read."* I re-ran the base `df4fb95` producer on the copilot-launch payload: **0 records, no throw** — the corrected text matches base behaviour exactly (my round-1 observation, re-confirmed). The old false "reads agentId and throws 'no subject id'" clause is gone from both the fixture and the README. Truthful now.

### CR-2 (round-1 MINOR) — **PRESENT / RESOLVED**
New `schema/vectors/adapter/copilot-stop-envelope-taskid.json`, auto-discovered by `AdapterVectors.Tests.ps1` (my suite shows 276, +1). Provenance labels verified truthful:
- **No invented key.** Payload keys `agent_name`, `transcript_path`, `session_id`, `hook_event_name` are the OBSERVED compat-stop shape — I confirmed §3b explicitly documents them (design lines 73/87: *"The compat stop payload has `agent_name`/`transcript_path`"*). The transcript body uses the Claude assistant-message shape observed in-repo (`transcript-car.jsonl`); the description discloses this and labels it as shared-by-D5, not fabricated.
- **Red-first re-verified non-vacuous by me:** base `df4fb95` producer on this exact payload → **0 records** (base doesn't recognise `agent_name`); current producer → **1 record**, `subject=51-car-r1`, `subject_basis=minted-id`, `task_id=51-car-r1`, `outcome=done` — deep-equals the fixture's `expected.record`.
- **events.jsonl boundary retained** in the README scope note (the no-envelope Copilot-stop corner stays the honest, unpinned boundary; its OBSERVED events.jsonl shape is genuinely absent from the tree).

### CR-3 (NEW — MINOR, carried, non-blocking) — README overstates real-runtime coverage of the Copilot stop-with-envelope path
The README scope note now reads *"That with-envelope stop path is now pinned."* This is accurate **at the conformance-suite level** (a green vector pins the producer's envelope-from-transcript resolution). But the design's own OBSERVED evidence — §3b-6 (*"the report body (envelope included) enters the parent's events.jsonl only when the conductor READS the agent... an extraction-at-stop returns nothing by construction for background agents"*) and §3b-7 (*"`transcript_path` at stop points at the PARENT's events.jsonl, not a per-agent file"*), with §2c establishing Copilot stops are background-only — means a **real** Copilot background stop's `transcript_path` is an events.jsonl with no inline envelope. So the vector exercises the producer code with a synthetic Claude-format transcript, not a runtime-realistic Copilot stop; the real Copilot envelope round-trip always flows through the events.jsonl path (the deferred boundary).

**Why this is Minor and not a blocking Major, stated plainly for my adversarial reader:**
1. The framing "Copilot stop → subject from the envelope task-id" originates in the **APPROVED design D2** (round-2 APPROVE), not this fix — re-litigating it here is scope creep against a fix-cycle delta.
2. My **own round-1 CR-2 probe used the identical synthetic Claude transcript** and concluded "the code is correct"; the car built precisely the vector I asked for (option 1) and reproduced my scenario faithfully — I cannot fairly REJECT the car for delivering exactly my specification.
3. The provenance labels are truthful *at the level they operate* (observed keys, DESIGN-MANDATED expected, red-first real); no OBSERVED-on-invented-key defect exists.
4. The genuinely-deferred events.jsonl corner remains honestly disclosed.
**Fix (for a future design/README revisit, not a merge blocker):** clarify that the vector pins the producer's envelope-resolution *code* given a readable Claude-format transcript, and that for a real Copilot background stop the envelope arrives via events.jsonl (§3b-6/7) — i.e. the "with-envelope at stop" scenario is a code-unit pin, not a proven real-runtime Copilot path.

## No new defect introduced
The commit is fixture/README-only (no `scripts/**` change); regression is structurally impossible from these files and confirmed by both suites green (+1 test, 0 fail). Worktree clean at `8b17196`; my checks used throwaway temp repos only.

## Constitution check (fix-implicated laws)
- **Law 1 (truth):** CR-1's false base-behaviour claim corrected in both homes and re-verified against `df4fb95`; CR-2's new vector red-first re-verified. The one residual accuracy nuance (CR-3) is carried, not buried.
- **Law 4 (nothing lost):** CR-3 recorded with §-level evidence per the carrier rule rather than dropped.
- **Law 6 (one truth):** launch-vector correction applied to BOTH the fixture and its README row — no drift between the two homes.

**APPROVE-FOR-MERGE.** CR-1 and CR-2 resolved and independently re-verified; CR-3 is a Minor precision note carried for a future design revisit, not a blocker.

```starcar-artifact
task-id: 47-car-review-r1
outcome: APPROVE
findings:
  - CR-1 (round-1 MINOR): RESOLVED - launch-vector provenance corrected in both the fixture and the README row to "exits 0 silently at the subagent_type launch filter, writing no record"; re-ran base df4fb95 producer on the payload (0 records, no throw), text now matches base behaviour exactly.
  - CR-2 (round-1 MINOR): RESOLVED - new copilot-stop-envelope-taskid.json auto-discovered (tests 275 to 276); payload keys agent_name/transcript_path are OBSERVED (design 3b-5/3b-7, no invented key), expected record DESIGN-MANDATED; red-first re-verified by me (base 0 records, current 1 record subject=51-car-r1 basis=minted-id task_id=51-car-r1). events.jsonl boundary retained.
  - CR-3 (new MINOR, carried, non-blocking): the README claim "with-envelope stop path is now pinned" is accurate at the suite level but overstates real-runtime coverage - design 3b-6/3b-7 establish a real Copilot background stop's transcript_path is the parent events.jsonl with no inline envelope, so the vector pins producer code given a synthetic Claude transcript, not a realistic Copilot stop. Ruled Minor not Major because the framing originates in the APPROVED design D2 and my own round-1 probe used the same scenario; scope-creep to REJECT would be unfair. Fix is a one-sentence clarification for a future design revisit.
abstract: >
  Delta re-review at HEAD 8b17196 (parent 0f3ae88, my round-1 target), fix commit is
  fixture/README-only with no code change. Both round-1 Minors are resolved and
  independently re-verified: CR-1's corrected launch-vector text matches the base
  df4fb95 producer exactly (0 records, no throw), and CR-2's new Copilot-stop vector
  uses only observed keys, carries a truthful DESIGN-MANDATED expected record, and its
  red-first is non-vacuous (base writes 0, current writes 1 with the exact expected
  fields). I ran both suites myself: tests 276/0 (+1 vector), probes 22/0. One new Minor
  (CR-3) is carried non-blocking: the README's "with-envelope stop path is now pinned"
  overstates real-runtime coverage since the design's own 3b-6/3b-7 evidence says a real
  Copilot background stop's transcript is events.jsonl without an inline envelope - but
  that framing traces to the approved design D2 and my own round-1 probe, so it is a
  precision note for a future revisit, not a blocker. APPROVE-FOR-MERGE.
```