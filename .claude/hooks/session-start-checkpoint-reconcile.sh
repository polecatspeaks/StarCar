#!/bin/sh
# SessionStart hook: reconcile the working-state checkpoint's PINNED BASE COMMIT
# against live git history - the second Layer-3 cadence
# (docs/templates/worked-verification-reconciliation.md), aimed at the checkpoint
# instead of CI. #46
#
# WHY THIS EXISTS: docs/friction-log.md, 2026-07-23 evening - the conductor read
# RESUME-HERE.md saying "THE DRILL (#21) - ARMED" and, in the SAME two tool calls, the
# friction log (and commit 38b67c8's own subject) saying the drill had ALREADY PASSED,
# and proceeded on the stale half anyway. CLAUDE.md lists "improvising past a
# contradiction instead of stopping on it" among the only real failures. This hook does
# the reconciling FOR the reader instead of adding a third "these may disagree" surface -
# a warning nobody acts on is what already failed; printing the actual commit subjects
# that landed after the pinned base makes the contradiction visible in one glance
# (HAVAGLANCE).
#
# PROBED (#46, this session): the real checkpoint carries 20+ SHA-shaped tokens (commit
# SHAs, CI run ids, a session UUID fragment, dispatch task ids, a blob hash prefix) -
# `grep -oE '\b[0-9a-f]{7,40}\b'` on it returns 23 distinct hits at time of writing. A
# hook that greps for "a SHA" reads garbage; a uniquely-tagged marker line is required.
# `git log --oneline deadbeef..HEAD` exits 128 on an unresolvable base, but the range call
# below redirects stderr - so an UNVALIDATED base does not "spew fatal" at all; worse, its
# empty stdout is silently read as "in sync" (a FALSE NEGATIVE on the very instrument built
# to prevent false confidence). The SHA is therefore validated with `git cat-file -e` BEFORE
# the range, so an unresolvable base degrades to the honest could-not-observe branch instead.
#
# MARKER FORMAT AND WHY: `<!-- checkpoint-base: <full 40-char sha> -->`, an HTML comment
# placed in the checkpoint's body (never its YAML frontmatter - PROBED live this session:
# RESUME-HERE.md's frontmatter `modified`/`originSessionId` fields changed underneath this
# car with no edit performed, proving the frontmatter is machine-managed and therefore
# not a safe place to pin anything). An HTML comment survives markdown rendering (passed
# through untouched, simply not displayed), is unambiguous against every other SHA-shaped
# token via a fixed-string grep on the marker text (never a fuzzy pattern), and the full
# 40-char SHA removes any residual collision risk. Pinning instruction lives in
# .claude/skills/goodnight/SKILL.md step 3.
#
# FOUR DISTINCT OUTCOMES, deliberately (mirrors Watch-CI.ps1 keeping could-not-observe
# distinct from red): SILENT when in sync or when the checkpoint FILE is absent (Law 7 - a
# stranger's clone has neither file nor marker, and a scar here reads 54 flags of which 50
# were false); a loud one-line UNARMED notice when the file is PRESENT but no marker is
# pinned (owner box only - the arming signal, added #46: an un-armed guard was otherwise
# indistinguishable from a healthy in-sync one, both silent);
# an honest COULD-NOT-OBSERVE message when the pinned SHA is valid-format but unknown to
# this repo (rebase/squash/prune - a real outcome, not a bug); and the full
# reconciliation, commit subjects listed, when the base is genuinely behind HEAD.
#
# Strictly non-fatal, matching session-start-ci-baseline.sh: a hook that can break a
# session start is worse than no hook.
#
# TEST OVERRIDE: CHECKPOINT_FILE may be set to point at a fixture checkpoint (used by
# scripts/probes/CheckpointReconcile.Probes.Tests.ps1) instead of the real memory file -
# the same override-with-default shape as starcar-producer-launch.sh's CLAUDE_PROJECT_DIR.

CHECKPOINT_FILE="${CHECKPOINT_FILE:-$HOME/.claude/projects/C--Users-Chris-git-starcar/memory/RESUME-HERE.md}"
MARKER='checkpoint-base:'
MAX_SHOW=15

[ -f "$CHECKPOINT_FILE" ] || exit 0
command -v git >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

line=$(grep -F "$MARKER" "$CHECKPOINT_FILE" 2>/dev/null | head -1)
if [ -z "$line" ]; then
  # ARMING SIGNAL (#46): the file exists (so this is the owner's box, never a stranger's
  # clone - Law 7's silence is owed the stranger, who has no file at all and exited above),
  # but no marker is pinned yet. That un-armed state is otherwise indistinguishable from a
  # healthy in-sync repo - both are silent - so say so, loudly, in one line. Still exit 0:
  # the hook informs, never blocks (Law 2).
  echo "[checkpoint] checkpoint present but UNARMED - no '$MARKER' marker pinned; run /goodnight step 3 to pin the base (guard emits nothing until then)."
  exit 0
fi

base=$(printf '%s\n' "$line" | sed -n 's/.*checkpoint-base: *\([0-9a-f]\{7,40\}\).*/\1/p')
[ -z "$base" ] && exit 0

# Validate BEFORE the range (#46) - an unresolvable base makes `git log <base>..HEAD` exit
# 128 with EMPTY stdout (stderr is redirected below), which the in-sync check would silently
# read as "no commits behind" - a false negative. Validation routes it to could-not-observe.
if ! git cat-file -e "$base" 2>/dev/null; then
  echo "[checkpoint] pinned base '$base' not found in this repo's history (rebase/squash/prune?)."
  echo "[checkpoint] Could not reconcile - treat the checkpoint's narrative as UNVERIFIED, not as in sync."
  exit 0
fi

commits=$(git log --oneline "$base"..HEAD 2>/dev/null)
[ -z "$commits" ] && exit 0   # in sync - silent, no crying wolf (severity philosophy)

count=$(printf '%s\n' "$commits" | wc -l | tr -d ' ')
echo "[checkpoint] RESUME-HERE's pinned base '$base' is $count commit(s) BEHIND current HEAD:"
printf '%s\n' "$commits" | head -"$MAX_SHOW" | sed 's/^/[checkpoint]   /'
if [ "$count" -gt "$MAX_SHOW" ]; then
  remaining=$((count - MAX_SHOW))
  echo "[checkpoint]   ...and $remaining more (showing latest $MAX_SHOW of $count - no silent caps)."
fi
echo "[checkpoint] Reconcile the checkpoint's narrative against these commits before trusting it (Retro #4 scar)."
exit 0
