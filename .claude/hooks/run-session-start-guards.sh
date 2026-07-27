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
# be true - deliberately no `set -e`, no `||` chaining, no early return. Round-4
# adversarial review independently fault-injected a MIDDLE guard exiting nonzero and a
# MISSING guard (not just a first-position failure, the only case this script's own
# test exercised) and confirmed later guards still ran both times.
#
# CLAUDE_PROJECT_DIR (fix cycle round 5, finding R4-2): established and EXPORTED here,
# override-with-default, because session-start-retro.sh:10 reads it directly
# (`LOG="$CLAUDE_PROJECT_DIR/docs/friction-log.md"`) and this runner is precisely the
# vehicle for invoking that guard from a shell where Claude Code has not already set
# it - a plain shell, or a Copilot session, the entire target audience of this script.
# Round-4 review observed the confident-falsehood failure mode directly: unset, LOG
# resolves to "/docs/friction-log.md", the guard's `else` branch fires, and an
# arriving agent is told to CREATE a file that already holds dozens of entries -
# exactly the unanchored-path class round 1's m2 fixed in the now-deleted delivery
# script (session-start-record.sh:76 - historical coordinate, the file no longer
# exists; #65's CitationResolverPolicy gate exempts it by this marker rather than
# flagging a dead path for a deletion the text already discloses) and this
# replacement re-introduced one file over. `git rev-parse --show-toplevel` gives
# the real repo root when run from
# anywhere inside it; the `|| echo .` fallback degrades to the historical bare-relative
# behavior (never fatal) if git itself is ever unavailable.
#
# GUARD_DIR may be overridden for tests (same override-with-default shape as
# CHECKPOINT_FILE in session-start-checkpoint-reconcile.sh:54 - the ASSIGNMENT line;
# :50-52 is that file's TEST OVERRIDE comment block, the citation this header
# previously pointed at imprecisely, m-a). Fix cycle round 5 also anchors GUARD_DIR's
# own default on the now-exported CLAUDE_PROJECT_DIR rather than a bare relative path,
# closing the same class of cwd-dependence for this variable too (m-a) - the
# precedent's ABSOLUTE default is now actually matched, not just cited.

CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || echo .)}"
export CLAUDE_PROJECT_DIR
GUARD_DIR="${GUARD_DIR:-$CLAUDE_PROJECT_DIR/.claude/hooks}"

for guard in goodnight-resume-check.sh session-start-checkpoint-reconcile.sh session-start-ci-baseline.sh session-start-retro.sh; do
  sh "$GUARD_DIR/$guard"
done

exit 0
