#!/bin/sh
# SessionStart hook: announce a /goodnight resume packet if one exists.
# Written by the goodnight skill (.claude/skills/goodnight/SKILL.md) when a session
# closes with agents still in flight. Background agents die with their session, so the
# packet is a re-dispatch spec the next session must read FIRST.
packet="$HOME/.claude/projects/C--Users-Chris-git-starcar/memory/resume-packet.md"
if [ -f "$packet" ]; then
  echo "[goodnight] RESUME PACKET FOUND from the previous session: $packet"
  echo "[goodnight] Unfinished work is recorded there. Read it FIRST, fold it into the"
  echo "[goodnight] working-state memory, re-dispatch what it names, then DELETE the packet."
fi
exit 0
