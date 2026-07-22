#!/bin/sh
# starcar-producer-stop.sh -- the SubagentStop producer hook (spec S2.1). Claude Code
# feeds the stop payload on stdin; this forwards it to the ONE writer, which emits a
# `returned` record and commits ONLY that record's path.
#
# NON-FATAL BY DESIGN: pwsh missing means no record this run (exit 0), never a broken
# dispatch. When pwsh is present the producer's own exit code flows: a real write/commit
# failure RAISES (nonzero + one line in artifacts/_faults.log), never drops silently
# (Law 4, spec S2.4). Latency stays cheap - one write, one pathspec-scoped commit with a
# capped retry (Probe 2 is binding: a slow stop hook blocks the return path in full).
DIR="${CLAUDE_PROJECT_DIR:-.}"
if ! command -v pwsh >/dev/null 2>&1; then exit 0; fi
exec pwsh -NoProfile -File "$DIR/scripts/Produce-Artifact.ps1" -Kind returned
