# Worked resume packet + working-state memory, sanitized

Status: Current

Provenance: the goodnight skill names the resume packet; this is what a real one looks
like, plus the running working-state memory it pairs with. Background agents die with
the session - the packet is a RE-DISPATCH SPEC, not a bookmark. The ancestor's morning
sessions open on these two artifacts and lose nothing overnight.

## The resume packet (written at goodnight when work is in flight; DELETED after resume)

```markdown
# RESUME PACKET - written 2026-XX-XX 22:10, session ending with cars in flight

READ FIRST, fold into the working-state memory, re-dispatch what this names, then
DELETE this file (the SessionStart hook announces it until you do).

## In-flight item 1: Car B (banner render) - implementer was RUNNING, died with session
- Branch: car-B-banner, tip <sha> (3 of 5 tasks committed; B.4 was IN PROGRESS -
  uncommitted work MAY exist in the worktree: check `git -C <worktree> status` first;
  if dirty, read the diff before deciding keep-or-discard)
- Worktree: <repo>/.worktrees/car-B-banner (base <sha>, verified at dispatch)
- What it was doing: Task B.4 (threshold config read-once) - B.1-B.3 committed+green
- RE-DISPATCH BRIEF MUST SAY: everything the original brief said (it is at <where the
  conductor keeps briefs / the transcript>), PLUS: B.1-B.3 are already committed at
  <sha> - verify them green, do NOT redo them; resume at B.4 step 1; the reviewer
  finding from Car A (null FetchedAt renders UNKNOWN) still binds.
- Next gate it was headed for: its car review, then Car C.

## Board/CI state at close
- CI: green at <sha> both workflows. Board: #12 In Progress. Nothing unpushed on main.
```

What to expect: per item - branch, tip, worktree, DONE vs IN-FLIGHT boundary at task
granularity, the uncommitted-work warning, what the re-dispatch brief must ADD to the
original, and the next gate. The test of a good packet: a session with zero
conversation memory re-dispatches correctly from it alone.

## The working-state memory (the running train log - survives every session)

One file, newest entries PREPENDED, literal "RESUME HERE" shape at the top:

```markdown
---
name: banner-train-state
description: "RESUME HERE (XX-XX evening): Cars A+B merged; Car C staged off <sha>;
  next step = dispatch Car C, then whole-branch gate"
---

- **XX-XX EVENING:** Car B MERGED <sha> (2 rounds; REJECT caught <one line>; suites
  <counts>). Car C staged off <sha> with brief amendments: <the two lines C's brief
  must carry>. Meter at close: <reading>. NEXT: dispatch Car C.
- **XX-XX MORNING:** Car A merged <sha> (clean, 1 round). Ledger <arithmetic>. [older
  entries stay - the history IS the context]
```

What to expect: every entry carries merge SHAs, review outcomes in one line, the exact
next step, and any cross-car context the next dispatch needs. The description line is
the index hook - it alone should orient a cold session. Update at every milestone
(merge, verdict, ruling, hold), not just at goodnight; the goodnight checkpoint is the
backstop, not the only write.

## The division of labor

- **Working-state memory**: continuous, append-at-milestones, never deleted - the log.
- **Resume packet**: exists ONLY when a session ends with agents in flight - the
  re-dispatch spec. Deleted on resume so the boot announcement stays meaningful.
- The SessionStart hook announces a leftover packet loudly; silence means clean start.
