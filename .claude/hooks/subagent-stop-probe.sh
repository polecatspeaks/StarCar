#!/bin/sh
# SubagentStop observation probe (standing instrumentation, doctrine: NO HEADERS HERE).
# Appends the hook payload to a gitignored log, stamped with whether the agent
# transcript exists AT FIRE TIME (spec probe 4's exact question - checking later
# answers a different question). Consumer: docs/specs/...-dispatch-harness-spec.md section 7.
#
# Q5 fix-cycle: guard python's absence, mirroring starcar-producer-*.sh's `command -v
# pwsh` shape. Unlike the producer hooks (silent non-fatal exit 0 - a missing record
# there is not a broken dispatch), this note is LOUD: the probe exists to observe hook
# payload shapes for a live spec question, so a silently-skipped probe on a python-less
# box would be an invisible instrumentation gap, not a graceful degrade.
if ! command -v python >/dev/null 2>&1; then
    echo "subagent-stop-probe: probe log omitted - python unavailable" >&2
    exit 0
fi
mkdir -p .claude/probe-logs
python -c "
import sys, json, os, datetime
d = json.load(sys.stdin)
# #47 (design D6, superseded dual-runtime design 3b-7): the transcript path key differs by
# runtime - Copilot's compat stop payload carries transcript_path (snake_case), Claude's
# carries agent_transcript_path. Reading only the Claude key made the probe report False on
# EVERY Copilot firing (a lying instrument on the surface this design depends on). Prefer the
# Copilot key, fall back to the Claude key, so the probe measures reality on both runtimes.
d['_probe_transcript_exists_at_fire'] = os.path.exists(d.get('transcript_path') or d.get('agent_transcript_path') or '')
d['_probe_logged_at'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
print(json.dumps(d))
" >> .claude/probe-logs/subagent-stop.jsonl
