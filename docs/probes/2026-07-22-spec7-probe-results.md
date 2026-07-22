Status: Current

# Spec §7 probe results - the blocking tests before Car 2 (#7)

Doctrine: NO HEADERS HERE (CLAUDE.md) - these are landed probe results, the constructed
header for the Claude Code hook substrate. CONSUMER: the cars 2-3 implementation plan
cites this document; Car 2's producer design stands on probes 1 and 4.

Method: standing observation hook `.claude/hooks/subagent-stop-probe.sh` (wired via
`.claude/settings.json` SubagentStop, appends each payload to gitignored
`.claude/probe-logs/subagent-stop.jsonl`, stamped with whether `agent_transcript_path`
exists AT FIRE TIME). Probes run 2026-07-22, conductor-observed, in the live session at
repo `dev` = `c82b966f`. Hook config proven non-broken by a same-config control before
any negative observation was accepted.

## Probe 1 - does the hook fire when a dispatch is killed mid-flight? **ANSWERED: NO.**

| Run | Method | Observed |
|---|---|---|
| Kill | 90-second looping agent, stopped ~20s in via TaskStop | **No SubagentStop firing logged** |
| Control | trivial agent, clean completion, IDENTICAL hook config | firing logged (`agent_id a88e7dad...`) |

**Consequence, load-bearing for Car 2:** a killed dispatch produces a `dispatched`
record and NEVER a `returned` - the producer cannot observe kills. The design's tier-1
detector (`dispatched` without successor renders unaccounted-for; `presumed-lost` is the
record that closes it) is therefore NOT a defensive nicety: it is the ONLY mechanism
that accounts for kills, and this measurement is why. Session death presumably behaves
the same or worse; not separately probed (the desk cannot kill its own session).

## Probe 2 - does a slow hook block the dispatch? **ANSWERED: YES - the stop path blocks for the hook's full runtime.**

Trigger fired at cars 2-3 planning (as deferred below in the original entry). Method: a
deliberate `sleep 10` injected into the SubagentStop probe hook, one trivial dispatch,
hook restored byte-identical afterward (diff empty, firing logged normally).

| Run | Hook | Observed dispatch duration |
|---|---|---|
| Baseline 1 (control) | normal | 2,816 ms |
| Baseline 2 (control) | normal | 1,648 ms |
| Slowed | + `sleep 10` | **11,609 ms** |

The added latency (~10s) appears IN FULL on the dispatch's stop/notification path - the
hook is BLOCKING, not fire-and-forget. **Consequence, binding on Car 2's producer
design:** the producer hook's synchronous work must stay cheap (one file write); any
expensive step (git commit with contention retries, network) either moves off the hook's
critical path or its cost is knowingly accepted as per-dispatch latency the conductor
feels on every return. A hook FAILURE was not separately probed (the hook is `sh -c`
fire-and-report; a failing command's effect on the dispatch is assumed non-fatal but
unmeasured - Car 2's plan states this residual explicitly if it leans on it).

## Probe 3 - are the four cost counters present on every model tier? **ANSWERED: YES, all three tiers.**

`input_tokens`, `output_tokens`, `cache_creation_input_tokens`,
`cache_read_input_tokens` - all four present in the final usage block of a real
transcript on each tier, measured from this session's own dispatches:

| Tier | Model observed | Four counters |
|---|---|---|
| Haiku | `claude-haiku-4-5-20251001` (control probe) | present |
| Sonnet | `claude-sonnet-5` (Car 1's transcript) | present |
| Opus | `claude-opus-4-8` (Car 1 reviewer's transcript) | present |

Spec §3.4's cost-optional posture is unchanged - counters being PRESENT for our
producer does not make them mandatory for a stranger's.

## Probe 4 - does `agent_transcript_path` exist at the moment the hook fires? **ANSWERED: YES for real dispatches - and the internal-subagent case is doubly filtered.**

At-fire-time `Test-Path`, stamped by the hook itself (not checked after the fact):

| Firing | `agent_type` | transcript exists AT FIRE |
|---|---|---|
| Real dispatch (control) | `car` | **True** |
| Internal harness subagent | `''` (empty) | **False** |

The producer may read the transcript at fire time for real dispatches. The free second
observation confirms spec §2.2 exactly: internal subagents carry an EMPTY `agent_type`
and no transcript - the `agent_type` filter excludes them on the first signature alone,
and the design's refusal to use transcript-existence as a filter (rev-1's withdrawn
"belt-and-braces") is again validated: existence correlates with the thing the filter
already knows.

## Probe 5 - the LAUNCH payload, and the identity correlation the producer turns on
**[Added post-drill, C2R2-M1: this measurement was gitignored-log-only; it lands here
because the Car 2 plan revises an approved spec cell on its strength.]**

Method: a `PostToolUse` (matcher `Task`) observation hook
(`.claude/hooks/post-task-probe.sh`, committed) appending each launch payload to the
gitignored log; one trivial dispatch; conditions: live session, 2026-07-22, same box
and shells as probes 1-4.

**Observed launch payload, top-level keys:** `cwd, duration_ms, effort,
hook_event_name, permission_mode, prompt_id, session_id, tool_input, tool_name,
tool_response, tool_use_id, transcript_path`.
**`tool_input` keys:** `description, model, prompt, subagent_type`.
**`tool_response` keys:** `agentId, canReadOutputFile, description, isAsync,
outputFile, prompt, resolvedModel, status`.

**THE HINGE FACT, measured:** `tool_response.agentId` at launch **equals** `agent_id`
in the same dispatch's `SubagentStop` payload (observed: one probe agent, both logs,
values identical). Subject identity therefore holds end to end across the two hooks.

**This REVISES a spec cell, and says so:** spec §2.1's "Verified" column records the
launch hook as *"fires at launch, `status: async_launched`, no body"* (from design
round 1). That observation was about the RESULT body - `status` is indeed
`async_launched` with no outcome - but the IDENTITY is present in `tool_response`,
which was never probed until now. The producer's `dispatched` records stand on this
measurement; a re-run of the probe (hook is committed; any dispatch regenerates the
evidence) re-derives it in one dispatch.

Also measured on the same payload: `resolvedModel` is present at launch (the
`dispatched` record's optional `model` field consumes it), and `session_id` is
present in BOTH payloads (the schema's required `session_id` sources from it).

**Companion measurement (transcript extraction, corroborating the spec-blessed §2.3
mechanism):** the last assistant message's text parsed from a real
`agent_transcript_path` JSONL (last `message.role=='assistant'`, joined
`content[].type=='text'` parts) equals the payload's `last_assistant_message` field
verbatim. The transcript is authoritative; the payload field is unused by the design.

## Probe 2 addendum - LIVE combined-hook latency after Car 2's merge (handback check 2)

Measured at the first live fires of the full producer chain (launch: entire + probe +
producer-launch hooks; stop: probe + producer-stop hooks), trivial Haiku dispatches,
same box and session as all prior measurements:

| Run | Hooks live | duration_ms |
|---|---|---|
| Baseline 1 (pre-producer) | probe only | 2,816 |
| Baseline 2 (pre-producer) | probe only | 1,648 |
| Live fire 1 (cold) | full chain | **14,049** |
| Live fire 2 (warm) | full chain | **14,285** |

**The ~11-12s overhead is STRUCTURAL, not cold-start** - the warm run matched the cold
one. Attribution (unmeasured split, stated honestly): two pwsh process starts per
dispatch (launch producer + stop producer), two git commits, plus the entire hooks'
own work, all riding the blocking paths probe 2 established. The producer WORKS
(records valid, subjects equal, entanglement-proven) but the plan's "sub-second beyond
baseline" expectation is falsified by measurement. Tracked as a Car 3-adjacent
optimization (issue filed); also a measured data point for the #14 runtime decision -
a compiled binary's ~5ms start would retire most of this overhead.

## What this unblocks

All four §7 probes are now ANSWERED (probe 2's trigger fired at cars 2-3 planning; its
hook-failure sub-case is recorded above as the one unmeasured residual). **The cars 2-3
planning rung is fully unblocked, and probe 2's blocking-hook measurement is a binding
design constraint on Car 2's producer.**
