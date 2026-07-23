# Worked design briefs - dispatching the design rung

Status: Current

Companion to [`worked-briefs.md`](worked-briefs.md), which covers implementer cars and code
reviewers. This file covers the **design rung**: dispatching an agent to review a design,
to re-review a fix, or to write one.

Same principle, same debt. The design rung had no dispatch artifact either, so five design
reviews were hand-written from scratch, each differently - and it took until round 3 for one
of them to set a convergence cap, because nothing told the earlier ones to look. Every block
below is drawn from those five rounds and the twelve Majors they produced.

Anatomy notes appear as `[WHY: ...]` - delete them when copying.

---

## 1. The design reviewer brief

```
You are the adversarial DESIGN REVIEWER, ROUND <N>, for <the design> (repo: <repo>,
<one-line context>). Binding REJECT authority: any Major = REJECT; disclosed-but-wrong
does not clear review.

**An APPROVE is genuinely available and you should give it if the document earns it.** Do
not manufacture Majors to look thorough - an instrument crying wolf is worse than none.
Equally do not approve to end a long sequence. Call it as you find it.

[WHY: without this, round-N reviewers ratchet. Round 5 was told an approve was live and
still rejected - but it also retired four prior Majors as "dissolved, not fixed", which a
ratcheting reviewer would have re-litigated.]

READ-ONLY, with one permission: you may fault-inject locally to verify a claim, but you
MUST revert byte-identical and confirm a clean tree in your report. NO NESTED DELEGATION.

[WHY: absolute read-only made four reviewers copy files outside the repo to test guards.
The fault injection is the highest-yield technique they have - it found a live forgery
and a checker that could not detect a flipped verdict. Permit it; require the revert.]

FIRST verify base: work ONLY in the detached worktree at <path>. `git log -1 --format=%H`
MUST be <sha>. If not, STOP and report.

TARGET: <design doc path> (rev <N>)

GROUND TRUTH, read IN FULL: <constitution>, <operating rules>, <process doctrine>, and
<the PRIOR VERDICT this revision claims to answer>. Skim earlier verdicts for what was
already ruled.

[WHY: "read the prior verdict" is what lets a reviewer catch a dropped ruling. Three
rulings were silently dropped across five rounds; each was invisible to a reviewer who
had not read its predecessor.]

CONVERGENCE HISTORY (the conductor MUST supply this; a fresh reviewer cannot know it):
rounds so far <N1, N2, ...> Majors, clustered in <sections>. Rule on whether this series
is CONVERGING, not only on whether this document is correct. If any two of - Majors not
declining, findings clustering in one section, or findings that are defects the previous
round's fixes created - then SET A CAP: name what the next revision must DEMONSTRATE, and
state that failing it escalates to the owner rather than to another round.

[WHY: the swirl is undetectable from inside it. A design ran 7-3-4-5 Majors while its
author believed each round would close it. Only a reviewer holding the series could see
it, and only because the conductor handed over the history.]

ATTACK THESE, in this order: <named failure classes specific to this design>.

[WHY: "review this design" produces a spelling check. "Hunt THIS class in THIS seam"
produces catches. Every round that found something was told what to hunt.]

VERIFY BY RUNNING, NOT READING: <any executable artifact the design cites - scripts,
tests, workflows, remote refs>. A design whose worked example does not reproduce is worse
than one with no example.

[WHY: a demonstration was once written as `sweep = dict(hook)`, so its printed proof was
sha256(x) == sha256(x). It was caught by a reviewer who RAN it. Nobody reading it caught
it, including the author.]

CLAIM AND CITATION TRUTH: open every file:line, SHA and quoted clause the design cites.

RULINGS: rule on every open question the design asks. That is your job, not the author's.

CONSTITUTION CHECK: all <N> laws, one line of evidence each, or a finding.

OUTPUT:
- VERDICT: APPROVE or REJECT, first line, one sentence.
- FINDINGS by severity, each anchored to a location you opened.
- RULINGS on the open questions.
- CONSTITUTION CHECK.
- WHAT IS GOOD, briefly - and say plainly where an attack I assigned FAILED and why.
- If you REJECT: split findings into MUST-CLOSE-IN-DESIGN versus SAFE-AT-SPEC-OR-CAR, and
  say whether another round is warranted or whether the design should proceed with
  findings carried forward.

[WHY: the must-close/safe-at-spec split is what makes a REJECT actionable instead of
merely correct. It is also what lets a conductor close a gate by ruling rather than by
spending another dispatch.]

FINALLY: end with <the artifact envelope, per the design's own spec>. Report honestly
whether complying was awkward.

[WHY: making the reviewer USE the mechanism it is reviewing is the cheapest possible
integration test. It caught a sentinel that collided with prose, then a fenced block whose
payload was silently HTML-escaped - neither findable by reading.]
```

## 2. The DELTA re-review (after a fix, to the SAME reviewer)

```
<Reviewer>: the author has landed fixes for your round-<N> findings. This is a DELTA
re-review, not a fresh review - you have the context, do not rebuild it.

SCOPE: commits <shas> against your own findings. For EACH finding you raised, rule:
CLOSED / PARTIALLY CLOSED / NOT CLOSED, with the evidence you checked.

Verify closures by the mechanism, not by the author's summary table - a claim that a
finding is closed is exactly the claim most worth distrusting.

New material introduced BY the fixes is in scope. Everything you already approved is not.

[WHY: fresh full re-reviews cost roughly 110k tokens each and rebuild context the previous
reviewer already had. Five of them were spent on one design where deltas would have
served. The ancestor shop's fix cycle goes to the SAME agent for exactly this reason.]

VERDICT: APPROVE, or REJECT with the specific findings still open.
```

## 3. The design car brief (dispatching an agent to WRITE a design)

```
You are writing the design for <feature> (repo: <repo>). Use
`docs/templates/design-doc.md` and follow its section ORDER - sections 0, 1 and 2 are
written BEFORE any mechanism exists, and that ordering is the entire point.

§0 INSTRUMENT CHECK FIRST, and it may end your task: if this is a format, protocol,
algorithm or wire contract, prose cannot hold it. Say so and stop - the deliverable is a
schema plus conformance tests, not a document.

[WHY: four REJECT rounds were spent specifying a distributed identity protocol in prose.
Majors climbed 7-3-4-5 because the instrument could not resolve at the defect's scale.]

§1 CONSTRAINTS BEFORE MECHANISM: open every law, template and prior verdict that binds
this, and write down what each FORBIDS - not what it says. Then design to satisfy them.

[WHY: seven constraints were violated across four rounds and a reviewer found all seven,
the author none. If the reviewer is finding the laws, they were not on the page when the
mechanism was built.]

§2 PREMISES, including the roll-call: for everything recorded, rendered or detected - what
writes it, what triggers that write, when it becomes durable, and what happens if two
arrive. State what would change if each premise were false.

[WHY: one undeclared premise - "two things write artifacts" - survived four adversarial
rounds and was worth eight of twelve findings. A reviewer rejects what is on the page, not
the assumption that put it there.]

§9b DISPOSITION (re-revisions): one row per prior FINDING and per prior RULING, with a
mandatory disposition. A blank cell is a defect.

[WHY: three rulings were silently dropped across five rounds. Disagreeing is welcome;
disagreeing quietly is not, and the failure mode is never an argument - it is an item that
stops appearing.]

HONEST STOPS ARE SUCCESS OUTCOMES. If a constraint makes the requested design impossible,
say so with the citation - that is a finding, not a failure.

REPORT: the document, plus the constraints you found that you did NOT already know, and
any premise you had to invent to make the mechanism work.
```

---

## What these five rounds taught, compressed

1. **Tell the reviewer what to hunt.** Generic review produces spelling checks; named
   failure classes produce catches. Every finding that mattered came from an assigned attack
   or from running something.
2. **Make them RUN it.** The highest-yield findings - a live forgery, a tautological
   demonstration, a checker blind to a flipped verdict - were all found by execution, never
   by reading.
3. **Hand over the series, not just the document.** Convergence is invisible to a fresh
   reviewer, and the author is the last party able to see it.
4. **Say an APPROVE is available.** Otherwise round-N reviewers ratchet.
5. **Demand the must-close / safe-at-spec split.** It converts a REJECT from a verdict into
   a plan, and lets a conductor close a gate by ruling instead of by dispatching.
6. **Delta re-reviews, same reviewer.** Fresh full re-reviews rebuild context that already
   existed and cost ~110k tokens each.
7. **Make the reviewer use the mechanism it reviews.** Cheapest integration test available.
