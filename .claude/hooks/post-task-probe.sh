#!/bin/sh
# PostToolUse:Task observation probe (doctrine: NO HEADERS HERE). Captures the LAUNCH
# payload shape - spec probe M4: does the launch hook carry the agent id that
# subject-identity needs? Consumer: Car 2 plan rev 2.
mkdir -p .claude/probe-logs
python -c "
import sys, json, datetime
d = json.load(sys.stdin)
d['_probe_logged_at'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
print(json.dumps(d))
" >> .claude/probe-logs/post-task.jsonl
