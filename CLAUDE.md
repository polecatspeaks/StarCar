# The StarCar Process Seed

## HARD INVARIANT: this repo is public, and so are its session transcripts

Entire.io session mirroring is ENABLED (owner decision, 2026-07-21: "the full monty").
Every agent-session transcript in this repo publishes to the public checkpoint branch.
Therefore: **StarCar sessions are StarCar-only.** Never paste, quote, or discuss any
other project's content, credentials, private paths, or unreleased material in a session
here - everything typed becomes world-readable. Cross-project work happens in the other
project's own session, never this one. This invariant outranks convenience, always.

This file is the institution. In agentic development every worker is a new hire on day
one: agents accumulate no experience across dispatches, and only what is WRITTEN persists.
These rules were not designed in the abstract — each was paid for, some several times, in
a production multi-agent shop. Every rule carries its scar. A rule without its scar is a
Chesterton's fence awaiting pruning, so the stories stay attached.

**Right-sizing rule (read first):** the full ladder below is calibrated for consequential,
multi-car work. Scale ceremony to stakes: a small, coverage-class change takes a car and
one adversarial reviewer; only structural work (new subsystems, rewrites, cross-boundary
contracts) pays the full design → spec → plan ladder. Porting maximum ceremony onto every
change is itself a process failure (the autoimmune mode - see the Healing Loop's edges).

## Test-Driven Development (non-negotiable)

Every behavior change is developed red-first: write the failing test, RUN it, confirm it
fails for the stated reason, then write the minimum code to green, then refactor.

- A test that passes the moment you write it proves nothing.
- Bugs start with a reproducing test; the fix is done when it goes green.
- Regression-vault tests that pass on arrival prove non-vacuity instead: fault-inject the
  guarded behavior once, observe the failure, revert, document.
- State the pass counts before every commit. Never commit unbuilt or untested work.

*Scar: every clean landing this seed descends from was red-first; every incident retro
found a missing red at the bottom.*

## The ladder (for structural work)

Design → adversarial design review → spec → adversarial spec review → implementation plan
→ adversarial plan review → cars (implementers) each followed by an adversarial
sentence-check reviewer → whole-branch gate → CI. Each gate catches a different failure
class at the cheapest point that class is catchable.

- **Designs are attacked before specs are written** (race conditions, lifecycle holes,
  retirement enumeration, observability reality: does the code actually expose what the
  design consumes?). *Scar: a design finding costs one dispatch; the same flaw found in
  production costs a session plus forensics plus a re-test. Learned by paying the second
  price repeatedly.*
- **Specs get their own document attack**: fidelity to the reviewed design, ambiguity
  (any requirement readable two ways is a finding), implementability by a zero-context
  plan-writer, citation truth (open every file:line the spec claims), lifecycle
  completeness. *Scar: a flawed spec is the most expensive document in the pipeline -
  plans, cars, and reviewers all inherit its errors as ground truth.*
- **Plans are reviewed before dispatch**: every requirement maps to a task; inter-task
  interface blocks agree (each car sees only its own task); every code snippet's APIs
  exist with those signatures at the base commit; each red would fail for its stated
  reason. *Scar: one plan shipped snippets calling constructor parameters that did not
  exist, then (after rework) invented a type that existed nowhere, then (after that)
  wired a logger of the wrong generic type. Three REJECT rounds, each caught at
  one-dispatch cost instead of as a car's compile wall. The gate paid for itself the
  first day it ran.*

## Review calibration (binding, uniform)

- Every adversarial reviewer holds REJECT authority over its gate. **Any Major = REJECT.**
- **Disclosed-but-wrong does not clear review.** Honesty about a defect is necessary, not
  sufficient.
- Rejection is appealable UPWARD (author fixes and re-reviews, or the conductor issues a
  recorded ruling committed to the plan doc), never AROUND. An implementer never silently
  overrides its own reviewer.
- Reviewers run the suites themselves and re-verify claims empirically - a review that
  only reads the report is a spelling check.
- A REJECT is a success outcome for the process. Scorecards count catches, not friction.

*Scar: the day this calibration was ratified, reviewers rejected their own train's plan
twice and a merged-that-day instrument was found crying wolf on 50 of 54 flags. All three
catches were cheaper than any of the incidents they prevented.*

## The sentence check (cross-boundary tracing)

When a diff produces, threads, or consumes a value that crosses a process or serialization
boundary, the reviewer MUST trace the full production path - every hop named with
file:line, every hand-maintained mirror (DTO, wire sample, snapshot) checked for the field
- and state the trace in the verdict. "Each file is correct" is a spelling check; the
review is not complete until someone has read the whole sentence.

*Scar: nine wire fields once crossed sixteen correct, reviewed files - and a third process
hop outside every review's scope silently dropped all nine. Every test passed because each
read one page of a three-page sentence. The first end-to-end reader was production. Paid
twice (a max-laps field died the same way earlier) before becoming law.*

## Branch topology and landing (STANDING ORDER)

**Never commit to `main`.** Nothing reaches `main` except by pull request. `main` is the
published face of a repo whose whole thesis is that the process is visible and real, so
its history is a claim about how the work was done, and a direct commit is that claim
being made falsely.

**Documentation lands the same way code does, through the same gates.** In this project
the documents ARE the product as much as the code is: designs, specs, plans, review
verdicts, ledgers, and the operating rules themselves. A doc that skips review because
"it is only prose" is the highest-leverage unreviewed artifact in the pipeline - plans,
cars, and reviewers all consume it as ground truth. Prose gets no discount.

- Work integrates on `dev`. Car branches cut from `dev`, merge back to `dev`.
- `dev` reaches `main` by PR, reviewed, never by fast-forward push.
- The rule is enforced by branch protection on the remote, not by memory. A prose rule
  binds whoever reads it; a protected branch binds every actor, including a future agent
  that never read this file.

*Scar: on founding day the repo's first five commits went straight to `main` because no
one had said not to yet, and the session was one approval away from committing the
founding design document the same way - the document every later contract would have
inherited as ground truth. Caught by the owner, not by a gate. The order was issued
before the design landed, which is the only reason it cost nothing.*

## Dispatch rules (multi-agent hygiene)

- **Name the model explicitly on every dispatch.** Never let a subagent default. *Scar: an
  unnamed model once stalled a whole evening's pipeline.*
- **No nested delegation - structurally.** Subagents never spawn subagents; the conductor
  is the only fan-out level. Enforce it by TOOLSET (the implementer agent type simply has
  no dispatch tool), not by prose. *Scar: a reviewer once forked itself mid-review; the
  owner had to stop the train by hand. A prose rule binds an agent that reads it; a
  toolset binds every agent regardless.*
- **Verify the worktree base before any edit.** Isolated worktrees can reuse stale
  history; every brief mandates checking the base commit and branch first, and STOPPING
  if wrong. *Scar: one car built a day's work on a stale worktree and had to redo it all.*
- Cars commit locally and NEVER push; the conductor merges. Cars never touch the shared
  checkout.
- Honest stops are success outcomes: a car that hits a plan-vs-code contradiction stops
  on that item with file:line evidence and continues with independent work. Improvising
  past a contradiction is the failure mode that costs trains. Put truth on the SUCCESS
  branch of every brief - agents gradient toward success shapes, so give truth a success
  shape.

## Verification honesty

- "Verified" means the pipeline that ships it went green - not that your local run passed.
  Push before triggering any build that consumes the remote; wait for CI before declaring
  victory on cross-environment work. *Scar: a release channel once built from the remote
  while the fix sat local-only; a "verified" change also once crashed on boot in the one
  environment the local box could not reproduce.*
- Instruments are audited on a cadence against the code they judge (the harness retro:
  do the checks cover what changed this week? do calibrations still match reality?).
  Severity philosophy: expected/placeholder patterns are NOTES, defects are FLAGS - an
  instrument that cries wolf is worse than no instrument, because everything downstream
  of a lying instrument is poisoned. *Scar: a data-sanity checker once raised 54 flags of
  which 50 were false; recalibrated against the real corpus it raised exactly one - the
  genuine defect.*

## Living contracts

- Any commit that adds or changes mutable service state updates the state ledger in the
  same commit, with old → delta → new arithmetic. Reviewers reject state-touching diffs
  that leave the ledger stale.
- Every new mutable field lands with red-first lifecycle tests across the domain's
  lifecycle events (enumerate yours: restart, reset boundaries, degraded windows,
  re-entry). *Scar: an audit once found 99 latent instances of the same
  state-survives-a-lifecycle-event bug pattern - each one individually "too small to
  ledger."*

## Rewrite vs extend

Optimize for the least NEW code reviewed per unit of capability - review, not generation,
is the binding constraint. Coverage defect → EXTEND with a small rider. Structural defect
(the SHAPE of the code is the bug) → REWRITE through the full ladder. Never rewrite
because generation feels cheap: a module's value is its encoded incident knowledge, much
of which lives only in code, comments, and fixtures - a rewriting agent regenerates from
what is written down, and the rewrite comes out cleaner and KNOWS LESS. Tripwire: a car
told to extend that finds the structure FIGHTING the fix honest-stops with "structure is
the defect" plus evidence; that escalates to a rewrite decision, never a forced patch.

## Cost discipline

Every train proposal carries a cost line: expected dispatch count, model mix, size class.
The budget owner approves spend along with scope; exceeding a usage window is a decision
made before dispatch, never a discovery on the bill. Split work at clean boundaries only -
a car and its review are one unit; never start a car whose review will not also fit.

## Tracking

Every piece of work gets an issue - no untracked work. One area label per issue; a train
is composed from ONE label's tickets (single coherent manifest). Check for duplicates
before filing.

## Session ends

Ending a session is a decision point, not an event: background agents die with the
session. Triage in-flight work first (wait for the car-and-review unit, or write a resume
packet that is a re-dispatch spec, not a bookmark), sweep pushes, checkpoint state in
writing, sync the board, state CI's disposition, and close with three sentences: what
landed, what is parked, what happens first tomorrow.
