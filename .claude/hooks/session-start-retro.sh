#!/bin/sh
# SessionStart hook: announce the standing tooling retro.
#
# A prose rule binds whoever reads it; a hook fires regardless. The STANDING ITEM in
# CLAUDE.md says every session opens with a tooling/harness friction retro, and this
# is the mechanical half - the announcement arrives before any work is chosen, so the
# retro is not something to remember.
#
# Strictly non-fatal: a hook that can break a session start is worse than no hook.
LOG="$CLAUDE_PROJECT_DIR/docs/friction-log.md"

echo "[retro] STANDING ITEM: open this session with the tooling/harness friction retro."
if [ -f "$LOG" ]; then
  # Count table rows (lines starting with '| ' that are not the header or separator).
  entries=$(grep -c '^| 0\|^| [0-9]' "$LOG" 2>/dev/null || echo "?")
  echo "[retro] docs/friction-log.md holds $entries logged entries."
  echo "[retro] Classify to the CLASS, recommend FREE OFF-THE-SHELF tools before building,"
  echo "[retro] and right-size: 'live with it' is a valid outcome. Installing something"
  echo "[retro] every session is the autoimmune failure the Healing Loop warns about."
else
  echo "[retro] No docs/friction-log.md yet - create it and log friction AS IT HAPPENS."
  echo "[retro] A retro that runs on memory is a memory test."
fi
exit 0
