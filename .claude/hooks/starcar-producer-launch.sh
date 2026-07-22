#!/bin/sh
# starcar-producer-launch.sh -- the PostToolUse:Task producer hook (spec S2.1). Claude Code
# feeds the launch payload on stdin; this forwards it to the ONE writer, which emits a
# `dispatched` record. The record's `subject` is tool_response.agentId, which equals the
# stop payload's agent_id for the same dispatch (Probe 5, measured), so subject identity
# holds end to end across the two hooks with no remembered state.
#
# NON-FATAL BY DESIGN: pwsh missing means no record this run (exit 0), never a broken
# dispatch. When pwsh is present the producer's own exit code flows (raise, never drop).
DIR="${CLAUDE_PROJECT_DIR:-.}"
if ! command -v pwsh >/dev/null 2>&1; then exit 0; fi
exec pwsh -NoProfile -File "$DIR/scripts/Produce-Artifact.ps1" -Kind dispatched
