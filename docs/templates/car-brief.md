# Car brief template

Status: Current

Every dispatch uses this shape. The framing rules are load-bearing: agents gradient
toward success shapes, so truth-telling must BE a success shape.

**Briefs state the QUESTION, never the ANSWER (#46).** Agreeableness points DOWNWARD as
well as upward - a brief that names a suspected defect and asks the reviewer to "rule on"
it hands the gate a conclusion to confirm, and reviewers gradient toward the dispatcher's
framing exactly as they do toward an author's. When a brief raises a possible concern,
phrase it as an open question grounded in file:line ("does any stylesheet-owned value
appear duplicated in this test?"), never as an asserted defect ("this test hardcodes a
second copy of a value owned by the stylesheet - rule on whether that's a Law 6
problem"). *Scar (docs/friction-log.md, 2026-07-23 evening, last row): a conductor's
reviewer brief for Car 33 did exactly the second thing - it called the new test's
runtime `rgb()` values "a second copy of a value owned by the stylesheet" and instructed
the reviewer to rule on a Law 6 violation. It was false: `grep` finds no colour literal
in the test at all - both ground truths are derived at runtime from the live stylesheet,
which is the Law 6-CORRECT construction. The `rgb()` values the conductor saw came from
the car's REPORT (what it printed as observations), not from its code, and the conductor
never opened the file before writing the brief. The reviewer disproved the premise and
said so plainly; a weaker reviewer would have confirmed it.*

```
You are Car <ID> on the <train> (repo: <repo>, <one-line project context>). You implement
<exact task list> from <the plan doc>. Work ONLY in the worktree at <path> on branch
<branch>. NEVER touch the shared checkout at <path>. Commit locally per task; NEVER push.
NO NESTED DELEGATION. <Platform notes: which suites run here, how.>

FIRST verify base: `git log -1 --format='%H'` must show <sha> and the branch must be
<branch>. If not, STOP and report - do not proceed on a stale base.

YOUR ORDERS: <plan doc path> - read <sections> IN FULL and execute in order, red-first
(write the failing test, RUN it, confirm it fails FOR THE STATED REASON - a red failing
for a different reason is a finding to report, not paper over). Ground truth on
ambiguity: <spec doc path>. Execute ONLY your tasks - <other cars' scopes> belong to
later cars; do not touch their files.

<CROSS-CAR CONTEXT: what is already merged in the base, amendments that supersede stale
plan text, warnings from earlier cars' reviewers - verbatim, with file:line.>

STANDING RULES binding every commit:
- CITE YOUR TICKET IN THE CODE: every new file, and every new unit of consequence inside
  an existing file, carries a comment naming the ticket that caused it, as bare `#N`. The
  ticket is the deepest WHY available (incident, argument, rejected alternatives, verdict)
  and this file already forbids comments that explain WHAT. EXCEPTION, and do not violate
  it: a file that cannot carry a comment - a bare data fixture, an `.expect`, a `.json`
  that is itself the artifact UNDER TEST - is NEVER edited to satisfy this; mutating a
  fixture changes what it proves. Cite in the sibling README or the consuming test instead.
- DOCUMENTATION RANKS EQUAL TO CODE: every document your change invalidates - <name the
  ones this task plausibly touches: spec, ledger, gating matrix, setup doc, README,
  comments> - is updated in the SAME commit. A stale doc left behind is a Major finding
  at review, not a follow-up. Meat first, polish later.
- <state ledger / contracts rule with current baseline numbers and the STOP-if-different
  instruction>
- <lifecycle-test rule for new mutable state>
- The plan was verified against real code at <sha>, but if ANY snippet fails to compile
  or names a missing API, that is a plan defect: HONEST-STOP on that task with the exact
  error and file:line, continue with independent tasks. Honest stops are SUCCESS
  outcomes; improvising past a contradiction is the failure mode that costs trains.
- After your last task run <the full suite list with expected baselines> and build clean.

FINAL REPORT: per task - commit SHA, red evidence (test name + observed failure reason),
green evidence (counts), deviations with justification; then total suite results, ledger
arithmetic as committed, findings/disclosures/honest stops. Your report feeds your
adversarial reviewer - make every claim verifiable.

END YOUR REPORT WITH THE ARTIFACT ENVELOPE (mandatory - this is how your dispatch's
`returned` record gets its outcome; the producer hook extracts it from your transcript):
a fenced block, info string starcar-artifact, with three fields - outcome (done /
done-with-findings / honest-stop), findings, abstract. NO ANGLE BRACKETS anywhere inside
the envelope (they get HTML-escaped or filtered; the angle-bracket-free form lands clean).
The envelope ALSO carries `task-id` echoing exactly the minted dispatch id this brief
delivered to you - that is what pairs your `returned` record to its launch (#47).
```

## Reviewer brief addendum

Reviewer half of the same rule (#46): treat anything this brief NAMES as a suspected
defect - not just disclosed deviations - as a question to TEST against the real diff,
never as a conclusion to confirm. Open the file before ruling on what it contains; a
review that confirms the dispatcher's framing without checking has been steered, not
convinced. The scar above is the reviewer-side proof it works: the Car 33 reviewer did
exactly this and disproved the conductor's own premise.

```
You are the adversarial sentence-check reviewer for Car <ID>. Binding REJECT authority:
any Major = REJECT; disclosed-but-wrong does not clear review. READ-ONLY: edit nothing,
commit nothing, push nothing. Work ONLY in the detached worktree at <path> (HEAD must be
<sha> - verify first, STOP if not).

SCOPE: <commits> against <plan/spec sections>.
VERIFY: <the specific claims from the car's report, each with how to check it>.
THE SENTENCE CHECK: <any cross-boundary value in this diff> - trace producer to final
consumer, every hop file:line, every hand-maintained mirror checked.
ADJUDICATIONS: <each disclosed deviation, to be ruled on against real code>.
PREMISE CHECK: any defect or concern this brief NAMES is a question to TEST against the
real diff, never a conclusion to confirm - open the file before ruling on what it
contains (#46; the brief's premise may itself be wrong).
RUN YOURSELF: <suites + expected counts>. Report observed.
CITATION CHECK: does every new file, and every new unit of consequence, carry a comment
naming its ticket as bare `#N`? Verify the cited number is the RIGHT one - a citation to
the wrong ticket is worse than none, because it sends the next reader somewhere confidently
false. Data fixtures that cannot hold a comment are exempt IN THE FILE and must be cited in
a sibling README or the consuming test; a fixture edited to carry a citation is a finding,
not compliance.
DOC CHECK: <the documents this diff plausibly invalidates> - is each updated in the same
commit? Open every file:line the diff's docs cite and confirm the citation is true. A
stale document or a dead citation is a MAJOR finding; documents rank equal to code here.
DOC SENTENCE CHECK (if user-facing docs, or code they describe, are touched): <the claims
at issue> - trace each from prose to the command it names to the code that runs to what a
stranger observes, file:line at every hop, and state the trace. This is the PR-stage gate
for user-facing documentation; an untraceable claim is a finding.
GUARD CHECK: <any gate, guard, or protection this diff installs> - has anyone WATCHED it
fire? A config read-back or a passing-on-arrival test is an assertion, not an
observation; demand the fault-injection evidence or raise its absence as a finding.
CONVERGENCE CHECK (re-reviews only): <prior rounds' Major counts and the sections they
clustered in - the conductor MUST supply these; a fresh reviewer cannot know them>. Rule on
whether this series is converging, not only on whether this document is correct. If any two
of - Majors not declining, findings clustering in one section, or findings that are defects
the previous round's fixes created - then SET A CAP: name what the next revision must
demonstrate, and state that failing it escalates to the owner rather than to another round.
CONSTITUTION CHECK: name each law the diff implicates, one line of evidence each.

VERDICT: APPROVE or REJECT up top; findings by severity with file:line.

END YOUR REPORT WITH THE ARTIFACT ENVELOPE (mandatory - your verdict is a `returned`
dispatch too): a fenced block, info string starcar-artifact, fields outcome (APPROVE /
REJECT / honest-stop), findings, abstract. NO ANGLE BRACKETS inside the envelope. The
envelope ALSO carries `task-id` echoing exactly the minted dispatch id this brief
delivered to you - that is what pairs your `returned` record to its launch (#47).
```
