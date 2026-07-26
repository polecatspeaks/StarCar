#!/bin/sh
# SessionStart hook: run the entire CLI's own session-start lifecycle hook, or degrade
# honestly with a systemMessage if the CLI isn't installed/on PATH. #50
#
# Moved out of .claude/settings.json's fifth SessionStart line (was an inline `sh -c`
# wrapper with an escaped-JSON printf fallback) into its own script, in the same
# intersection dialect as its four siblings (`sh .claude/hooks/NAME.sh`).
#
# WHY: docs/friction-log.md (2026-07-24 entries) - under Copilot CLI's Claude-compat
# layer, the inline fifth line broke the WHOLE SessionStart invocation:
# `syntax error: unexpected end of file from 'if' command`, while the four sibling
# guards (already simple-form) executed fine. Local reproduction was attempted (this
# car, 2026-07-26) and did NOT reproduce the parse error - the extracted command string
# passed `sh -n`/`dash -n` (exit 0 both) and executed correctly under both `sh -c`
# (bash-as-sh) and `dash -c` on this box. The fix stands on the design's own simple-form
# rule regardless (docs/design/2026-07-24-family-agnostic-harness-design.md D4/D5:
# "intersection dialect for the four SessionStart guards... one manifest" - carried
# verbatim from the retired dual-runtime design's D1), extended to this fifth line so
# it is no longer the one structural outlier a differently-quoting shell can break.
#
# Behavior preserved EXACTLY (pinned by scripts/tests/SessionStartWiring.Tests.ps1):
# entire CLI absent -> print the same systemMessage JSON, exit 0.
# entire CLI present -> exec its session-start hook.
if ! command -v entire >/dev/null 2>&1; then
  printf "%s\n" "{\"systemMessage\":\"\\n\\nEntire CLI is enabled but not installed or not on PATH.\\nInstallation guide: https://docs.entire.io/cli/installation#installation-methods\"}"
  exit 0
fi
exec entire hooks claude-code session-start
