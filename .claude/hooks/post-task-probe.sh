#!/bin/sh
# PostToolUse:Task observation probe (doctrine: NO HEADERS HERE). Captures the LAUNCH
# payload shape - spec probe M4: does the launch hook carry the agent id that
# subject-identity needs? Consumer: Car 2 plan rev 2.
#
# Q5 fix-cycle: guard python's absence, mirroring starcar-producer-*.sh's `command -v
# pwsh` shape. Unlike the producer hooks (silent non-fatal exit 0 - a missing record
# there is not a broken dispatch), this note is LOUD: the probe exists to observe hook
# payload shapes for a live spec question, so a silently-skipped probe on a python-less
# box would be an invisible instrumentation gap, not a graceful degrade.
if ! command -v python >/dev/null 2>&1; then
    echo "post-task-probe: probe log omitted - python unavailable" >&2
    exit 0
fi
mkdir -p .claude/probe-logs
python -c "
import sys, json, datetime
d = json.load(sys.stdin)
d['_probe_logged_at'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
print(json.dumps(d))
" >> .claude/probe-logs/post-task.jsonl
