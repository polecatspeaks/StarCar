#!/bin/sh
# #50: SessionStart delivery helper - reads a guard's stdout from stdin, `tee -a`s it
# through to real stdout UNCHANGED (so Claude Code's context-injection path stays
# exactly as today), and additionally appends the SAME bytes to a gitignored
# per-session report file so a Copilot session can read them.
#
# WHY: probed #50 (docs/design/2026-07-24-family-agnostic-harness-design.md §2c row,
# restart-gated on 2026-07-24) - even when the four SessionStart guards execute
# successfully under Copilot CLI's Claude-compat layer, their stdout never reaches the
# agent context: Copilot surfaces hook failures in events.jsonl only, it does not
# inject SessionStart hook stdout into the conversation. All four guards are otherwise
# "announce to nobody" on that runtime (decorative-guard class, docs/friction-log.md
# 2026-07-24). This closes the delivery gap at the FILE layer instead of the stdout
# layer, without touching what Claude Code already sees.
#
# WIRING (.claude/settings.json, one manifest, D1): the RIGHT side of a two-stage pipe
# per guard line -
#   sh .claude/hooks/GUARD.sh | sh .claude/hooks/session-start-record.sh [--reset]
#
# --reset truncates REPORT_FILE and writes a fresh timestamp marker BEFORE this
# guard's output is appended. Attached to exactly ONE of the four SessionStart lines
# (the first, goodnight-resume-check.sh) so the file resets ONCE per SessionStart
# batch, never once per guard - a per-guard truncate (`>` instead of `>>`, or --reset
# on every line) would silently drop every earlier guard's contribution. Silent guards
# (no stdout - e.g. no resume packet, checkpoint already in sync) legitimately record
# nothing; `tee` on empty stdin writes nothing, which is correct, not a bug.
#
# REPORT_FILE may be overridden for tests (same override-with-default shape as
# CHECKPOINT_FILE in session-start-checkpoint-reconcile.sh).
#
# Strictly non-fatal, matching every SessionStart guard: this script must never break
# a session start.

REPORT_FILE="${REPORT_FILE:-.claude/session-start-report.txt}"

report_dir=$(dirname "$REPORT_FILE")
[ -n "$report_dir" ] && mkdir -p "$report_dir" 2>/dev/null

if [ "$1" = "--reset" ]; then
  printf '[session-start-report] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$REPORT_FILE"
fi

tee -a "$REPORT_FILE"
exit 0
