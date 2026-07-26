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
#   sh .claude/hooks/GUARD.sh | sh .claude/hooks/session-start-record.sh
#
# M4 FIX (fix cycle round 2, round-1 REJECT finding M4): round 1 attached `--reset` to
# exactly ONE settings.json line (the first, goodnight-resume-check.sh) and assumed the
# five SessionStart hook commands execute SEQUENTIALLY in array order. That assumption
# was UNSTATED and UNPROVEN - Claude Code documents PARALLEL execution of same-event
# hooks - and the round-1 reviewer MEASURED silent loss of a guard's entire output in
# 2/15 trials under adversarial skew (the `--reset` truncate landing AFTER another
# guard had already appended its own line).
#
# FIXED CLASS (the reviewer's own remedy, endorsed): freshness is now a property of
# the FILE, never of ordering. Every invocation - `--reset` no longer exists as an
# argument at all - checks whether REPORT_FILE's own last-write time is STALE (file
# absent, or older than STALE_SECONDS) and, if so, truncates + writes a fresh
# timestamp marker BEFORE this guard's own output is appended. No settings.json line
# is "first" by convention; any of the four guards may legitimately be the one whose
# invocation finds the file stale and resets it.
#
# CONCURRENCY (closes the actual race, not just the ordering assumption): an ATOMIC
# `mkdir`-based mutex (POSIX-guaranteed atomic even under true OS-level parallelism,
# unlike a plain existence check + separate write) serializes the
# check-staleness-then-truncate-then-append critical section across every concurrent
# invocation. Two guards racing at the same instant cannot interleave a truncate
# between one guard's append and another's, because only one invocation's body runs at
# a time; the lock is released (via `trap ... EXIT`) only after this invocation's own
# `tee -a` has completed, so the NEXT lock holder always observes a report file this
# invocation just wrote to (fresh mtime) and therefore appends rather than resets.
# FAIL-OPEN (Law 2, matching every guard's own non-fatal posture): lock acquisition is
# bounded (2 seconds) and falls through to proceed WITHOUT the lock rather than hang a
# session start forever if a lock directory is somehow stuck.
#
# Pinned by scripts/tests/SessionStartReportConcurrency.Tests.ps1 (#50 M4): a stale
# prior-session file is replaced rather than appended to with no --reset argument, and
# 20 trials of 4 genuinely concurrent child-process invocations (Start-Process, real
# OS processes) lose nothing.
#
# Silent guards (no stdout - e.g. no resume packet, checkpoint already in sync)
# legitimately record nothing; `tee` on empty stdin writes nothing, which is correct,
# not a bug.
#
# m4 (round-1 minor, disclosed): this pipeline's own exit code is this script's
# unconditional `exit 0` at the bottom, so a future guard that starts exiting nonzero
# would have that exit code SWALLOWED by the pipe (only the last command in a pipeline
# without `pipefail` determines $?, and this script always exits 0 regardless of the
# upstream guard's own status). No behavior change today - all four current guards
# exit 0 on every path - but a future guard author adding a failure exit must know the
# pipe does not propagate it.
#
# REPORT_FILE may be overridden for tests (same override-with-default shape as
# CHECKPOINT_FILE in session-start-checkpoint-reconcile.sh). m2 (round-1 minor): the
# default anchors on CLAUDE_PROJECT_DIR, the house hook pattern
# (starcar-producer-launch.sh:10), rather than a bare relative path - strictly more
# robust under an unobserved Copilot hook cwd, and degrades to the same relative path
# when CLAUDE_PROJECT_DIR is unset.
#
# Strictly non-fatal, matching every SessionStart guard: this script must never break
# a session start.

REPORT_FILE="${REPORT_FILE:-${CLAUDE_PROJECT_DIR:-.}/.claude/session-start-report.txt}"
STALE_SECONDS=60
LOCK_DIR="$REPORT_FILE.lock"

report_dir=$(dirname "$REPORT_FILE")
[ -n "$report_dir" ] && mkdir -p "$report_dir" 2>/dev/null

# Acquire the mutex: atomic `mkdir` (fails if the directory already exists), bounded
# retry (~2s), then proceed WITHOUT the lock as a last resort - fail-open per Law 2,
# matching every SessionStart guard's own non-fatal posture. A stuck lock must never
# hang a session start.
i=0
while ! mkdir "$LOCK_DIR" 2>/dev/null; do
  i=$((i + 1))
  if [ "$i" -ge 100 ]; then break; fi
  sleep 0.02
done
trap 'rmdir "$LOCK_DIR" 2>/dev/null' EXIT INT TERM

# Freshness is a property of the FILE (its own mtime), never of settings.json array
# order. `date -r FILE +%s` (GNU coreutils, bundled with Git's sh on this box) reads
# the file's last-write epoch; an unreadable/missing file or an unparseable result
# both fall through to "stale" (reset), the safe default.
now_epoch=$(date -u +%s)
stale=1
if [ -f "$REPORT_FILE" ]; then
  file_epoch=$(date -u -r "$REPORT_FILE" +%s 2>/dev/null)
  if [ -n "$file_epoch" ]; then
    age=$((now_epoch - file_epoch))
    if [ "$age" -ge 0 ] && [ "$age" -lt "$STALE_SECONDS" ]; then
      stale=0
    fi
  fi
fi

if [ "$stale" -eq 1 ]; then
  printf '[session-start-report] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$REPORT_FILE"
fi

tee -a "$REPORT_FILE"
exit 0
