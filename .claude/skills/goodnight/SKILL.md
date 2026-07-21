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

## 4. Board pass

Issue tracker synced to reality; new tickets have a status.

## 5. CI disposition

Green, or pending-with-note. Red-and-deterministic is NOT a goodnight - it is a blocker
to surface before closing.

## 6. The yard-status close

Three sentences, written to memory AND said to the owner: what landed, what is parked,
what happens first tomorrow.

## 7. Weekly only: worktree prune

Remove worktrees whose branches are fully merged; never prune anything named in the
resume packet or holding uncommitted work.

Rules: steps 1-3 never skipped; an honest "step N not done because X" beats a silent
skip; for a surprise ending ("gotta go NOW"): packet + checkpoint only, say what was
skipped.
