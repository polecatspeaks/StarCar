# Worked tickets and board conventions, sanitized

Status: Current

Provenance: the ancestor's tracker discipline, fictionalized. The rules that matter:
every piece of work gets an issue (no untracked work); one area label per issue; a train
is composed from ONE label's tickets; the board never claims more certainty than
reality has.

## Filing - a worked issue body

Title: `Freshness banner shows "fresh" for a snapshot whose adapter never reported FetchedAt`

```
Found by Car B's reviewer (banner train, 2026-XX-XX, disclosed non-blocking): when
adapter X's error path returns a snapshot without FetchedAt, deriveVerdict receives
null and <what actually happens, file:line>. IMPACT: a confident falsehood on the
status surface (Law 1) - the banner's whole purpose inverted. REPRO: <exact steps or
the test that proves it>. FIX SHAPE: <the known direction, if any, with file:line -
or "needs its own design pass" honestly>. Related: #12 (the banner train), #15
(per-adapter detail - do NOT fold this fix there, different failure class).
```

What to expect: symptom + evidence + impact-with-law + repro + fix shape + relations.
An issue a stranger can triage without the filer in the room. Before filing, ALWAYS
search for an existing/duplicate issue - link or fold rather than re-file.

## Closing - evidence-bearing, never bare

```
Landed by the banner train (2026-XX-XX): verdict derivation single-sourced (Car A,
<merge-sha>), banner renders the authored verdict incl. honest UNKNOWN (Car B,
<merge-sha>, 2 review rounds - the REJECT caught <one line>), the three self-computing
comparisons retired (Car C, <merge-sha>, zero-caller grep-proven). Suites <counts>
green; whole-branch gate Ready-to-ship. Board: In Review pending deployment evidence.
```

What to expect: WHICH commits, WHICH cars, what the reviews caught (REJECTs are cited
in closes - they are credentials, not embarrassments), current verification level, and
where the ticket sits on the board and why.

## Board column semantics (the honesty gradient)

- **Backlog** - real but unscheduled.
- **Todo** - scheduled/staged (has a train or a slot).
- **In Progress** - a car is actively on it.
- **In Review** - LANDED but awaiting the evidence that makes it TRUE in the world
  (deployed and observed working, verified by the owner, etc.). Closed-but-In-Review is
  a normal state: the code merged; reality hasn't voted yet.
- **Done** - VERIFIED. The strictest column. Desk-verified tooling may go straight
  here; anything with a runtime behavior claim waits for observation.

The scar: "Done" drifting to mean "merged" makes the board a lying canary - the owner
reads Done as "I can rely on this" and reality disagrees on race day. The column
semantics ARE a truth surface; hold them like one.

## Follow-ups and riders

A review finding that is real-but-out-of-scope becomes a TICKET IN THE SAME BREATH as
the verdict that found it (the ancestor filed them within minutes, cross-referencing
the review). Small fixes ride the next train touching that area as "riders" - a rider
still gets a car + reviewer, just shares the train. The tripwire both directions:
folding a genuinely separate failure class into an existing ticket buries it; filing a
duplicate fragments the record. Search first, then decide fold-vs-file explicitly.

## Batch discipline

Board syncs happen in batches at natural boundaries (car merged, train landed, session
close), one metadata resolution + N edits (the ancestor burned a whole API rate window
on one-at-a-time edits before batching). The goodnight ritual's board pass is the
nightly backstop.
