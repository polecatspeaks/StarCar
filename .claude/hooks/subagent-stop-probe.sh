#!/bin/sh
# SubagentStop observation probe (standing instrumentation, doctrine: NO HEADERS HERE).
# Appends the hook payload to a gitignored log, stamped with whether the agent
# transcript exists AT FIRE TIME (spec probe 4's exact question - checking later
# answers a different question). Consumer: docs/specs/...-dispatch-harness-spec.md section 7.
mkdir -p .claude/probe-logs
python -c "
import sys, json, os, datetime
d = json.load(sys.stdin)
d['_probe_transcript_exists_at_fire'] = os.path.exists(d.get('agent_transcript_path',''))
d['_probe_logged_at'] = datetime.datetime.now(datetime.timezone.utc).isoformat()
print(json.dumps(d))
" >> .claude/probe-logs/subagent-stop.jsonl
