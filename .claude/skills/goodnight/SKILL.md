---
name: goodnight
description: Session-end ritual - triage in-flight work (wait or write a resume packet), push sweep, state checkpoint, board pass, CI disposition, and the yard-status close. Invoke when the owner signs off for the day or asks to close the session cleanly.
---

# /goodnight - closing the yard

A session ending is a DECISION POINT, not an event: background agents die with the
session, unpushed commits produce stale builds tomorrow, and unrecorded state costs the
morning session an archaeology dig. Run the steps in order.

## 1. In-flight triage (FIRST)

For every background agent still running: **wait** (if its car-and-review unit is close -
never strand one without the other) or **write a resume packet** to the project's memory
location, per item: branch, tip commit, worktree path, what it was doing, and what its
re-dispatch brief must say. Background agents DO NOT survive the session - the packet is
a re-dispatch spec, not a bookmark. Wire a SessionStart hook that announces a leftover
packet at the next boot; the resuming session reads it FIRST, re-dispatches, then deletes
it.

## 2. Push sweep

Shared checkout clean; default branch pushed (release pipelines build from the REMOTE).
Car worktree branches are exempt - they are recorded in the packet instead.

## 3. State checkpoint (never skipped)

Update the working-state memory to a literal RESUME HERE shape: what landed (merge SHAs),
what is parked and why, the exact next step. The written system is the only system that
survives the night.

**Pin the base commit as a machine-readable marker, every time (#46).** In the checkpoint
file `RESUME-HERE.md` (the exact file `.claude/hooks/session-start-checkpoint-reconcile.sh`
reads at session start - NOT the sibling `resume-packet.md` that
`.claude/hooks/goodnight-resume-check.sh` reads), immediately after the frontmatter's
closing `---`, write or update a line of the exact form:

```
<!-- checkpoint-base: <full 40-char sha of dev tip at write time> -->
```

Use the FULL 40-character SHA, not a short form - the checkpoint's own prose already
carries many other SHA-shaped tokens (32 tokens, 17 distinct, when measured during #46 -
a perishable count, since the file is rewritten every session: CI run ids, session UUID
fragments, dispatch task ids, a blob hash prefix), so only a uniquely-tagged,
fixed-string-matchable line is safe to grep. **Never put this marker in the YAML
frontmatter** - probed live during #46: `RESUME-HERE.md`'s `modified` and `originSessionId`
frontmatter fields change on their own between sessions with no edit performed, proving that
checkpoint's frontmatter block is machine-managed and
not a safe place to pin anything durable. An HTML comment in the body survives markdown
rendering (passed through untouched, simply not displayed) and is invisible to a human
reader while still readable by `.claude/hooks/session-start-checkpoint-reconcile.sh`,
which reconciles this marker against live git history at the next session's start -
silently, unless the checkpoint's claimed base has fallen behind current HEAD (the
Retro #4 scar: reading a checkpoint against a contradicting friction-log entry and
proceeding on the stale half anyway).

## 4. Board pass

Issue tracker synced to reality; new tickets have a status.

## 5. CI disposition

Green, or pending-with-note. Red-and-deterministic is NOT a goodnight - it is a blocker
to surface before closing.

## 5b. Artifact-store sweep

Check the dispatch-harness store before closing (spec #7): read `artifacts/_faults.log`
and surface any entry (a producer write or commit that RAISED rather than dropped - Law 4),
and run `scripts/Detect-Dispatches.ps1 -StoreRoot artifacts` to see un-landed dispatches -
anything `overdue` or `unaccounted-for` is visible debt that must be named in the
checkpoint (a killed dispatch fires no stop hook, so the budget gradient is the only thing
that surfaces it). An un-backfilled gap is a first-class state, not an omission: close it
with a `presumed-lost` record or carry it forward explicitly, never silently.

**Also run `scripts/Reconcile-DispatchRecords.ps1` (#32) in the same sweep.** It
cross-references `.claude/probe-logs/subagent-stop.jsonl` (a SEPARATE process from the
producer, so it survives a producer write/commit failure) against the store, and catches
a class `Detect-Dispatches.ps1` structurally cannot: a dispatch whose record was NEVER
WRITTEN at all (git status clean, no signal, root cause unproven - hypothesis: git index
contention). A nonzero exit names each gap's `agent_id`, `logged_at`, and missing kind -
treat it exactly like an `_faults.log` entry above: not an omission, a first-class state
to close with a `presumed-lost` record or carry forward explicitly in the checkpoint.

**Epoch floor (fix cycle round 2, #32, finding M5 - measured, not assumed).** Wired into
this sweep without ever being run against the real corpus, this script exited 1 with 9
gaps on day one - every one at or before 2026-07-22T16:35:08Z, while the earliest
producer-written record is 2026-07-22T16:40:01Z: all 9 were pre-producer-epoch firings,
not defects. Fixed: the default floor derives from the store's earliest
`returned-*.json`-named record (never a hand-set constant), and a probe firing logged
before it is excluded as a NOTE, never a FLAG. Re-measured against the real corpus
(read-only) after the fix: **8 of the 9 are now correctly excluded** (one summary NOTE
line); **1 remains flagged** - `agent_id=adba6552daddbe6db`, the very first line of the
real probe log, which predates the `_probe_logged_at` field's own introduction and
carries no timestamp at all. It is almost certainly ALSO pre-epoch by file position, but
the epoch-floor logic will not exclude it on that basis (Law 1: unknown renders as
unknown, never a guessed exclusion) - a human reading this sweep may close it with a
`presumed-lost` record if the position-based inference is trusted, exactly like any
other un-backfilled gap above.

## 6. The yard-status close

Three sentences, written to memory AND said to the owner: what landed, what is parked,
what happens first tomorrow.

## 7. Weekly only: worktree prune

Remove worktrees whose branches are fully merged; never prune anything named in the
resume packet or holding uncommitted work.

Rules: steps 1-3 never skipped; an honest "step N not done because X" beats a silent
skip; for a surprise ending ("gotta go NOW"): packet + checkpoint only, say what was
skipped.
