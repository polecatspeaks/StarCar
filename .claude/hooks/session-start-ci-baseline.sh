#!/bin/sh
# SessionStart hook: reconcile the "known-good" assumption against live CI, every boot.
#
# Ported from docs/templates/worked-verification-reconciliation.md Layer 3, on a specific
# ask, after a real incident here: CI run 29913822738 failed (PowerShell Gallery flaked,
# Install Pester errored, every test SKIPPED) and sat unseen for an hour while the
# conductor repeatedly said "CI green". The conductor had been sampling with
# `gh run list --limit 1`, catching an in_progress, reporting THAT as a state, and never
# returning for the terminal outcome.
#
# The ancestor names the two classes:
#   1. SAMPLE-AS-CONCLUSION - treating a sample of an async process as its terminal state.
#   2. UNRECONCILED VERIFICATION CLAIMS - assertions nothing ever audits against reality.
# And the meta-class beneath both: ABSENCE-BLINDNESS. A red never looked at is
# indistinguishable from no red; an absence is invisible unless something asserts
# completeness.
#
# This hook does not prevent the miss. It BOUNDS it: an unexamined red surfaces at the
# next session at the latest. The policy half lives in CLAUDE.md - the session does not
# start editing on top of an unexamined red.
#
# Strictly non-fatal: a hook that can break a session start is worse than no hook.

command -v gh >/dev/null 2>&1 || exit 0
branch=$(git branch --show-current 2>/dev/null) || exit 0
[ -z "$branch" ] && exit 0

echo "[ci-baseline] Branch '$branch' - latest CI conclusions (standing known-good check):"
gh run list --branch "$branch" --limit 4 \
  --json conclusion,status,headSha,workflowName \
  --jq '.[] | (.conclusion // .status) + " | " + .headSha[0:9] + " | " + .workflowName' \
  2>/dev/null | sed 's/^/[ci-baseline]   /' || echo "[ci-baseline]   (could not query - non-fatal)"

echo "[ci-baseline] TRIAGE ANY RED BEFORE THE FIRST EDIT."
echo "[ci-baseline]   deterministic red on current code = BLOCKER."
echo "[ci-baseline]   one-off that passes on re-run of identical code = flake: note it, move on."
echo "[ci-baseline] Flake calibration matters: treating flakes as blockers teaches everyone"
echo "[ci-baseline] to ignore this check, and a crying-wolf instrument is worse than none."
exit 0
