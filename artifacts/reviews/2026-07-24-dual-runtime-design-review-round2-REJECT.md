<!-- starcar-integrity: sha256=33e4f9a73793cc2e044eae1d1d07391fe375cc8f79aab4e0c4a62c7611be0aa7 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Dual-runtime harness design review - round 2 - REJECT

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: adversarial design review
Round: 2
Target: `docs/design/2026-07-24-dual-runtime-harness-design.md rev 2 (3bcb751)`
Base reviewed: `da02ed7`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `design-review-47-r2`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `da02ed7` |
| Entire checkpoint | `613fb50016e2` |
| Dispatch, the locator within the session | `design-review-47-r2` |
| Entire session (context, NOT a lookup key) | `dr47-r2-transcript` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain da02ed7
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All checks complete. Suites at `da02ed7`: **StoreIntegrity + Producer = 143 passed, 0 failed** (my own observed baseline; StoreIntegrity alone is the 129 the design cites). Line 148 confirmed: launch subject reads `tool_response.agentId`, which throws under the Copilot payload.

## Verdict

**Base:** dev HEAD `da02ed7` (my round-1 verdict), `3bcb751` beneath (rev-2 design), `d626268` below (rev-1) — matched. Design file is byte-identical at `3bcb751` and `da02ed7`.

**Prior-finding walkthrough (all re-derived, not trusted):**

| Prior | Rev-2 status | Evidence I verified |
|---|---|---|
| DR-1 (Major) | **ABSENT — resolved substantively** | The probe DR-1 demanded was run: `.claude/probe-logs/subagent-stop.jsonl` holds 3 entries from Copilot session `e07fc822` (11:31:08Z, 11:39:42Z, +1), delivered in **snake_case** (`session_id`/`transcript_path`/`agent_name`/`hook_event_name`). D1 deletes the second manifest + normalizer → double-fire vector structurally gone. Root cause correctly re-identified as the filter (`Produce-Artifact.ps1:141-142` requires `agent_type`; `:146-147` requires `subagent_type`) — I confirmed those exact lines and that the Copilot payload carries `agent_name`/`tool_input.agent_type` instead. Not cosmetic. |
| DR-2 (Minor) | **ABSENT — fixed** | §3/§9b now read "4 guards + 2 producer forwarders + 2 probe hooks = 8", matching `.claude/settings.json`. |
| DR-3 (Minor) | **ABSENT — fixed** | D5/§5.3 name one home (`scripts/lib/TranscriptRead.ps1` via `Get-LastAssistantText`) with both call sites. |

**Convergence:** healthy — the three prior findings are all genuinely resolved (verified against artifacts, not the author's word), and the new finding sits in fresh territory (launch identity) that rev 2 opened by promoting D7 to in-scope. Findings are shrinking (3→2) and moving, not holding station. But a new **Major** forces REJECT.

**New finding — DR-4 (MAJOR), D7 / §5.2 / §3b-4:** Rev 2 brings `dispatched` records under Copilot in-scope on the claim (D7) that "D2's filter fix **alone** makes launch records mint." That is false. After the filter accepts `agent_type`, the launch path immediately reads the subject at `Produce-Artifact.ps1:148` — `$subject = Get-Prop (Get-Prop $payload 'tool_response') 'agentId'` — and the Copilot launch payload has **no `tool_response` and no `agentId`**: I captured its `tool_result` = `{result_type, text_result_for_llm}`, with the agent id only in free-text prose ("Agent started in background with agent_id: car46-fix-cycle") and in `tool_input.name`. So the path throws `"no subject id in the launch payload"` (`:151`). D7's stated fallback — "Subject = launch `toolCallId` when derivable" — names a key that **is not in the compat launch payload at all** (verified keyset: `_probe_logged_at, cwd, hook_event_name, session_id, timestamp, tool_input, tool_name, tool_result` — no `tool_use_id`/`toolCallId`). Neither D2's scope nor §5.2 enumerates the subject-extraction rewire launch actually needs. Deeper: the launch subject that IS available (`tool_input.name` = "car46-fix-cycle") and the stop subject (events.jsonl `toolCallId` = "toolu_018vax…", per §2c-4) live in **different identity spaces** — the stop payload's `agent_name` is the generic "car", so a Copilot dispatched/returned pair shares no join key. The design waves this away with "StoreIntegrity has no pairing assertion so partial coverage breaks nothing," conflating "the integrity suite doesn't check pairing" with "pairing doesn't matter" — the yard board (#1) joins these. This is the round-1 DR-1 class recurring: a decision resting on a payload shape not actually observed for that path.

**New finding — DR-5 (MINOR), §3b-4:** "44/44 post-task probe entries **under Copilot** have `tool_name: Agent`." Of 44 total `post-task.jsonl` entries, only **3 are Copilot** (session `e07fc822` / `session-state` transcript); the other **41 are Claude Code** (transcript_path in `.claude\projects\`, Claude keyset with `tool_use_id`). All 44 are indeed `tool_name Agent`, but "under Copilot" is the wrong qualifier — the real Copilot evidence is 3/3. The decision survives on the 3 real observations, but a false population count in the rigorous "observed substrate, sources named" section is exactly the Law-1 overclaim the design elsewhere avoids.

**§10 rulings (where evidence permits):**
- **Q3 (the `sh -c` entire wrappers):** Leave them as pinned noise — the design's disposition is correct. They work Claude-side, Copilot is natively covered by `.github/hooks/entire.json`, their guard is `command -v entire … exit 0` (fail-open, non-preToolUse → no dispatch blocked), and they are generator-adjacent, so rewriting them is the Law-6 second-copy risk. Probe-pin + setup.md disclosure is the honest Law-1/Law-5 move.
- **Q1:** Agree — minting `envelope: absent` at stop is correct (Law 4: the return is a fact even before the body is readable).
- **Q2:** First-line JSON `type`-field detection is sufficient given D3 pins it with fixtures; an explicit `-Format` knob is defensible but not required.
- **§8 state-ledger:** verified benign — the diff touches hook wiring, the producer, and docs; no ledger-tracked mutable service state.

```starcar-artifact
outcome: REJECT

findings:
  count_by_severity:
    major: 1
    minor: 1
  prior_round_dispositions:
    DR-1_major: ABSENT (resolved substantively - probe run, root cause corrected at Produce-Artifact.ps1:141-147, second manifest+normalizer deleted, double-fire structurally impossible; verified against 3 real Copilot probe-log entries)
    DR-2_minor: ABSENT (inventory now 8, matches .claude/settings.json)
    DR-3_minor: ABSENT (one extractor home scripts/lib/TranscriptRead.ps1, both call sites named)
  new:
    DR-4_MAJOR: "D7/section5.2/section3b-4. 'D2 filter fix alone makes launch records mint' is false. Launch subject at Produce-Artifact.ps1:148 reads tool_response.agentId; the captured Copilot launch payload has no tool_response and no agentId (tool_result = result_type + text_result_for_llm prose; id only in tool_input.name). Path throws 'no subject id' at :151 after the filter fix. D7's named fallback 'launch toolCallId' is absent from the compat launch keyset entirely. Launch identity (tool_input.name) and stop identity (events.jsonl toolCallId, agent_name is generic 'car') do not share a join key, so dispatched/returned cannot pair under Copilot - unacknowledged. Same class as round-1 DR-1: decision on a payload shape not observed for that path."
    DR-5_MINOR: "section3b-4 '44/44 post-task entries under Copilot have tool_name Agent' - only 3 of 44 are Copilot (session e07fc822); 41 are Claude Code (transcript_path in .claude/projects). False population count in the observed-substrate section; decision survives on the 3 real Copilot entries."
  suites_run_by_reviewer:
    at_sha: da02ed7744a8fab70f97ff68813266761506c55f
    StoreIntegrity_plus_Producer: 143 passed, 0 failed, 0 skipped (Pester 5.8.0)

abstract: |
  Delta re-review of the dual-runtime harness design rev 2 at 3bcb751 (dev HEAD da02ed7, verified). All three round-1 findings (DR-1 Major, DR-2/DR-3 Minor) are resolved substantively, re-derived against the actual .claude/probe-logs artifacts: the compat layer provably executes the sh script.sh hooks and delivers snake_case payloads, so the producer's silence was its own filter (Produce-Artifact.ps1:141-147, verified exact), and rev 2 correctly deletes the second manifest and normalizer. REJECT stands on one new Major (DR-4): rev 2 promotes dispatched-record minting under Copilot to in-scope on the false claim that the filter fix alone suffices, but the captured Copilot launch payload carries no tool_response/agentId/toolCallId - the subject line at :148 throws, D7's named subject basis does not exist in the payload, and launch vs stop identities cannot be joined; plus one Minor (DR-5) overcounting Copilot post-task entries as 44/44 when only 3/44 are Copilot. Findings are shrinking and moving into new territory (healthy convergence); reviewer ran StoreIntegrity+Producer at da02ed7 = 143 passed, 0 failed.
```