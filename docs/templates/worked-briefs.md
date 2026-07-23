# Worked briefs - three real dispatch prompts, sanitized

Status: Current

The [car-brief template](car-brief.md) gives the skeleton; this file shows the living
form. These are real dispatch prompts from the ancestor shop with the domain content
replaced by a fictional StarCar feature (a data-staleness banner), structure and rhetoric
preserved exactly. The structure IS the discipline: every block below earned its place by
a failure that happened without it.

Anatomy notes appear as `[WHY: ...]` - delete them when copying.

---

## 1. The implementer car brief

```
You are Car B on the staleness-banner train (repo: StarCar) - the banner car: derive and
render the data-freshness verdict. You implement Tasks B.1-B.3 from
docs/plans/2026-XX-XX-staleness-banner.md. Work ONLY in the worktree at
<repo>/.worktrees/car-B-banner on branch car-B-banner. NEVER touch the shared checkout.
Commit locally per task; NEVER push. NO NESTED DELEGATION.

[WHY: identity, scope, and the three hard boundaries first - worktree, no-push,
no-delegation. Cars that learned these mid-brief violated them.]

FIRST verify base: `git log -1 --format='%H'` must start <sha> and `git branch
--show-current` must show car-B-banner. If not, STOP and report - do not proceed on a
stale base.

[WHY: worktrees can silently reuse stale history. A car once built a day's work on the
wrong base and redid all of it.]

YOUR ORDERS: the plan's Global Constraints, ANY BINDING AMENDMENT BLOCKS (they SUPERSEDE
contradicting task text - read them word for word), and Tasks B.1-B.3 IN FULL, executed
in order, red-first: write the failing test, RUN it, confirm it fails FOR THE STATED
REASON - a red failing for a different reason is a finding to report, not paper over.
Ground truth on ambiguity: docs/specs/2026-XX-XX-staleness-banner-design.md. Execute
ONLY your tasks - Car A's adapter files and Car C's layout files belong to them; do not
touch them even if you see the work coming.

[WHY: the amendment-block sentence matters because plans go stale between writing and
dispatch; amendments are how the conductor patches them without a full rewrite. The
scope fence prevents two cars colliding in one file.]

CROSS-CAR CONTEXT baked into your base: Car A landed the adapter's FetchedAt timestamp
on the snapshot record (snapshot.ts:41) - consume it, never re-derive freshness from
wall-clock reads scattered in the view. Car A's reviewer flagged: a snapshot with a
null FetchedAt means the adapter could not determine it - your banner must render
UNKNOWN for that case, never "fresh" (a confident falsehood on a status surface is this
project's worst defect class).

[WHY: cars are context-free; anything an earlier car or reviewer learned that this car
needs must be restated verbatim, with file:line. This block is the #1 place conductors
under-invest.]

STANDING RULES binding every commit:
- Any commit adding/changing mutable service state updates docs/contracts/state-ledger.md
  in the SAME commit with old -> delta -> new arithmetic. Re-read the live ledger FIRST
  (expect <N> fields / <M> SAFE); if it differs from what your tasks assume, STOP and
  report before committing.
- New mutable state requires red-first lifecycle tests for every lifecycle event the
  ledger names (for this project: process restart, adapter reconnect, config reload).
- Documentation ranks equal to code: every document your change invalidates (README,
  setup, ledger, comments) updates in the same commit.
- The plan was verified against real code at <sha>, but if ANY snippet fails to compile
  or names a missing API, that is a plan defect: HONEST-STOP on that task with the exact
  error and file:line, and continue with independent tasks. An honest stop is a SUCCESS
  outcome; improvising past a contradiction is the failure mode that costs trains.
- After your last task run <suite commands> (expected baselines: <counts>) and build
  clean.

[WHY: the honest-stop framing is load-bearing, not decoration. Agents gradient toward
success shapes; if "stop and report" is not explicitly a success, they improvise
around contradictions - which is how plan defects become shipped defects.]

FINAL REPORT: per task - commit SHA, red evidence (test name + observed failure reason
verbatim), green evidence (counts), deviations with justification; then total suite
results, ledger arithmetic as committed, findings/disclosures/honest stops. Your report
feeds your adversarial reviewer - make every claim verifiable.

[WHY: the report spec shapes the work. A car that knows its reviewer will re-run its
reds writes real reds.]
```

## 2. The adversarial reviewer brief

```
You are the adversarial sentence-check reviewer for Car B of the staleness-banner train
(repo: StarCar). Binding REJECT authority: any Major = REJECT; disclosed-but-wrong does
not clear review. READ-ONLY: you may fault-inject locally to verify a claim but MUST
revert byte-identical and confirm a clean tree. NO NESTED DELEGATION. Work ONLY in the
detached worktree at <repo>/.worktrees/review-B (HEAD must be <sha> - verify first,
STOP if not).

[WHY: reviewers get their own detached worktree so they can never contaminate the
car's branch; "disclosed-but-wrong does not clear" prevents disclosure from becoming a
liability shield.]

SCOPE: three commits on car-B-banner, base <sha>: <sha1> (B.1 verdict derivation),
<sha2> (B.2 banner render), <sha3> (B.3 config threshold). Orders:
docs/plans/2026-XX-XX-staleness-banner.md Car B tasks; spec sections 2/4.

THE SENTENCE CHECK (the core): the freshness verdict crosses boundaries - adapter
FetchedAt -> snapshot record -> verdict derivation -> banner props -> rendered DOM.
Trace the full path yourself at this HEAD, every hop file:line; do NOT trust the car's
own table, rebuild it. Hunt specifically: (a) the null-FetchedAt case rendering
anything but UNKNOWN (First Law - a confident "fresh" with no evidence); (b) any
component re-deriving freshness from its own clock instead of reading the authored
verdict (the re-inference class: a consumer re-deriving a verdict from adjacent state
instead of reading the signal authored for it - this class has recurred three times in
the ancestor shop); (c) threshold config read at derivation time vs render time
(two reads can disagree mid-reload).

[WHY: name the specific failure classes to hunt. "Review this diff" produces a
spelling check; "hunt THIS class in THIS seam" produces catches.]

ADJUDICATIONS (each with a ruling): (1) the car disclosed it extended an existing test
file rather than creating the plan's assumed-fresh one - verify names/assertions match
plan intent; (2) the car's beyond-plan fix to <X> - is it correct AND was its red
genuine, or scope creep to revert?

RUN YOURSELF at HEAD: <suite commands> (expect <counts>). Report observed - a review
that only reads the report is a spelling check.

CONSTITUTION CHECK: name each law the diff implicates, one line of evidence each that
it is honored, or a finding where it is not.

VERDICT: APPROVE or REJECT up top; findings by severity with file:line; the sentence
trace as YOU rebuilt it; rulings; observed counts; constitution check. On APPROVE,
Car C dispatches consuming your verified surface.
```

## 3. The fix cycle (continuation message to the SAME car after a REJECT)

```
Car B: your reviewer returned REJECT - one Major, two Minors. Your B.1/B.2 work
survived (rulings: the null-FetchedAt handling CORRECT, the extended-test-file
deviation ACCEPTED). The fix cycle, same rules (worktree car-B-banner, tip <sha>,
red-first, commit locally, never push, no subagents):

MAJOR - <the finding, restated with the reviewer's file:line evidence and, when the
reviewer proved it empirically, the exact repro>. CONDUCTOR RULING (the mechanism):
<the specific fix shape, named APIs, where each piece lives - a ruling, not a menu>.
1. RED FIRST: the reviewer's exact repro as a committed test - <name, setup, the
   assertion>. Run it, confirm it fails by <the stated wrong behavior>.
2. FIX: <the mechanism>.
3. <ledger/doc consequences of the fix, with arithmetic>.

MINORS: <each, one line, with the fix>.

Commit: "<message>". Report: red evidence for the repro, green counts (expect
<baselines> +/- yours), commit SHA. Honest-stop with file:line if the ruling
contradicts real code.

[WHY: fix cycles go to the SAME agent (context intact, cheaper than fresh); the
conductor rules on the mechanism rather than letting the car pick, because the
reviewer-author-conductor triangle only converges when exactly one voice decides; and
the reviewer's own repro becomes the red, so the fix is pinned to the proven failure,
not a paraphrase of it. After the fix: a DELTA re-review to the same reviewer -
verify-the-fix scope, not a full re-review.]
```

---

## The five habits that make these work (the compressed doctrine)

1. **Boundaries before content.** Worktree, base-verification, no-push, no-delegation -
   stated first, every time, even though the agent definition also says them.
2. **Amendments outrank tasks.** Plans stale between writing and dispatch; the binding
   amendment block is the patch mechanism, and every brief points at it.
3. **Cross-car context is restated, never assumed.** With file:line, verbatim. The car
   is a new hire; yesterday's reviewer finding does not exist unless the brief carries it.
4. **Truth gets a success shape.** Honest-stop, disclosed deviation, and REJECT are all
   named success outcomes, in those words, in every brief.
5. **The report spec is the quality lever.** Demand verbatim observed failures, exact
   counts, and file:line claims - the car that knows its reviewer re-runs everything
   works differently from one reporting into the void.
