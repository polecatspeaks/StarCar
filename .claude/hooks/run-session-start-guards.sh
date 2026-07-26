#!/bin/sh
# #50: agent-pull SessionStart guard runner - owner ruling 2026-07-26 (option d).
#
# WHY: Claude Code injects SessionStart hook stdout into agent context automatically.
# Copilot CLI's Claude-compat layer does not (probed #50) - Copilot surfaces hook
# failures in events.jsonl only, never the guards' own stdout. Two push-based delivery
# mechanisms were built and reviewed away across three fix-cycle rounds: round 1
# (--reset ordering, an unstated sequential-execution assumption Claude Code's own
# parallel hook execution disproved) and round 2 (mtime + mutex, which itself gained
# three new reproduced defects - a second SessionStart within 60s appended to the
# stale marker, a non-GNU `date -r` fallback lost 30/40 guard outputs, and the mutex
# released a lock it never held). BOTH were proxies for one fact this script's stdin
# is the wrong place to observe: a payload's session_id. The owner ruling removes the
# premise instead of hardening the proxy again: no shared file, no truncation, no
# race, no mutex. See docs/design/2026-07-24-family-agnostic-harness-design.md's
# amendment history and artifacts/reviews/ for the full retired narrative.
#
# WHAT THIS DOES: runs the four SessionStart guards in sequence, letting their stdout
# flow through unchanged (no capture, no redirection, no second destination). ANY
# agent whose runtime does not inject SessionStart hook stdout (Copilot CLI today)
# runs this script as its FIRST action per the arrival docs
# (.github/copilot-instructions.md, ONBOARDING.md) and reads the output directly -
# agent-pull, not push. Also usable by a human operator or a probe wanting the same
# combined output on demand; nothing here is Claude-Code- or Copilot-specific.
#
# RELIANCE, UNCHANGED FROM THE DELETED DESIGN: this still depends on the agent
# actually running the command per its arrival doc - exactly the same reliance the
# file-based design carried (which depended on the agent reading a file per the same
# arrival doc), minus all the mechanism that sat between "guard runs" and "agent
# reads." Whether that reliance holds under a live Copilot session is issue #55,
# triggered on the next Copilot session - nothing on this desk can observe it.
#
# NON-FATAL SHAPE, matching every guard it runs: a guard that exits nonzero does NOT
# stop the runner - the next guard still runs, and this script's own exit code is
# always 0 regardless. All four guards are exit-0-by-design today (each has its own
# "strictly non-fatal" header), but this runner does not depend on that continuing to
# be true - deliberately no `set -e`, no `||` chaining, no early return.
#
# GUARD_DIR may be overridden for tests (same override-with-default shape as
# CHECKPOINT_FILE in session-start-checkpoint-reconcile.sh:50) - points at a fixture
# directory carrying the same four filenames instead of the real .claude/hooks/.

GUARD_DIR="${GUARD_DIR:-.claude/hooks}"

for guard in goodnight-resume-check.sh session-start-checkpoint-reconcile.sh session-start-ci-baseline.sh session-start-retro.sh; do
  sh "$GUARD_DIR/$guard"
done

exit 0
