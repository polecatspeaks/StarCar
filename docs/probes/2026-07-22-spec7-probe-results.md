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

## Probe 2 - does a slow or failing hook block the dispatch? **DEFERRED, trigger stated.**

Requires deliberately degrading the live hook and measuring dispatch latency - a
disruption not worth taking mid-train. Trigger: before Car 2's producer hook lands, the
car's plan includes a timed probe (hook with a deliberate sleep; measure whether launch
or stop latency moves). Recorded here so the deferral is a decision, not an omission.

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

## What this unblocks

Spec §7 marks probes 1 and 4 blocking before Car 2. Both are answered. Probe 2 is
deferred INTO Car 2's plan with its trigger stated above. Probe 3 is answered on all
tiers. **The cars 2-3 planning rung is unblocked.**
