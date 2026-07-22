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

## NORTH STAR: documentation ranks equal to code

Not "documented code." Documentation and code are two halves of one deliverable, held to
one standard. Two families, both in scope, neither senior to the other:

- **Process documentation** - designs, specs, plans, review verdicts, ledgers, briefs,
  agent definitions, and these rules themselves. In a shop where the workforce evaporates
  nightly, the written system is the only system that survives, so a defect in the
  writing is a defect in the product.
- **User-facing documentation** - README, quickstart, deployment and configuration
  guides, adapter-authoring guides, demo data, and screenshots. Law 7 (The Stranger)
  already ratified this: *documentation a stranger can deploy from*. It is not an
  afterthought to the process docs; it is the half of the product an outsider ever
  touches.

Every rule below that binds code binds both families: review, gates, PRs, honest stops,
REJECT authority.

**The stranger is the audience, when audiences conflict.** Three readers want different
documents - the owner deploying it, a stranger deploying it cold, and someone reading to
learn the process and never running anything. Averaging them produces mush, so the
stranger wins by Law 7. This is also the strictest master: documents a stranger can
deploy from are automatically sufficient for the owner, while documents written for the
owner are never sufficient for a stranger, and the shortfall is invisible to the author
because assumed context cannot be seen from the inside.

**True always; complete only when the thing exists.** User-facing docs must never
describe behavior the software does not have - a quickstart for a server that cannot
start is a lie with good intentions, and Law 1 does not grant exemptions for optimism. A
README that says "no adapters ship yet" is honest and correct. Writing the deployment
guide before the deployment exists is fiction that will be stale before it is ever true.
Completeness arrives with the capability; truth is required from the first commit.

**User-facing documentation is gated at the PR, by SENTENCE CHECK.** The sentence check
generalizes from wire fields to doc claims, because a user-facing claim crosses
boundaries too: prose → the command it names → the code that command runs → what a
stranger actually observes. Each hop is a place the claim can be silently false, and "the
README reads fine" is a spelling check. So the reviewer on any PR touching user-facing
docs - or touching code that user-facing docs describe - traces each claim to the code
that honors it, every hop with file:line, and states the trace in the verdict. A claim
whose path cannot be traced is a finding. The review is not complete until someone has
read the whole sentence.

*This is attention-tier, and the Healing Loop ranks attention below mechanism (a test
beats a review rule). Deliberate: CI running the quickstart on a clean runner is the
eventual mechanical form (#6), backed up behind CI itself. While the project moves fast
and breaks things there is no stable quickstart to assert, and an instrument re-asserting
yesterday's README would cry wolf - which our own severity philosophy calls worse than no
instrument. The tier downgrade is the price and is written down rather than glossed.*

Two surfaces stay unguarded even after CI lands, named so nobody assumes otherwise:
comprehensibility (a machine proves commands run, never that a human could follow them)
and screenshot drift (a stale image on a status-board project is both the likeliest and
the most embarrassing rot this repo can ship).

**The showcase never edits the record.** This repo is deliberately a demonstration of how
the process works, which creates standing pressure to make the process LOOK good - and
honest-failure framing is the load-bearing wall the whole Healing Loop stands on. So:
REJECTs stay visible, stalls stay visible, wrong calls stay attributed, and embarrassing
commits get reverted in the open rather than force-pushed into nonexistence. Curating the
record to flatter the process destroys the only thing the showcase was demonstrating. The
pressure grows as the audience does, which is why it is written down before there is one.

**But normalisation is not curation, and confusing the two is its own failure.** The
record is what happened: findings, verdicts, counts, wrong calls, rejected work. An
operator's home directory is not a finding - it is an accident of where a file happened to
sit. Rewriting `C:\Users\<someone>\...` to `<repo>` or `~` deletes nothing about the
process and publishes nothing about the operator, and Law 7 actively WANTS it: an absolute
path pinned to one machine is the one thing in an artifact a stranger cannot use.
Portability and honesty point the same way, so nothing is traded. Three conditions keep it
that way: normalisation happens BEFORE the artifact is hashed (afterwards it would be
tampering with a record already written, and the integrity line would rightly refuse it);
the rules are mechanical, narrow, and declared in the artifact itself; and the
un-normalised original survives on the Entire checkpoint branch, one `git grep` away. What
would be curation - softening a finding, dropping a Major, flattering a verdict - is
untouched by any of this and remains forbidden.

*Scar: three review verdicts published the operator's home path to a public repo before
anyone noticed, and every future car report would have carried it by construction, because
every brief mandates base-verification in a named worktree. Caught by a reviewer, whose
finding also surfaced that the yard design had ALREADY ruled against rendering absolute
paths for the same reason - the repo held the principle and had not applied it to itself.*

**Documents are living, never static.** A document is true only at the moment of its
commit. The instant the code diverges from it, that document has become a lying canary -
a reader trusting a described mechanism the code no longer implements - and this project
holds that a confident falsehood on an information surface is worse than a blank one.
Therefore: **the commit that invalidates a document updates that document, in the same
commit.** Not a follow-up ticket, not a cleanup pass, not "we will true it up before the
release." The state-ledger rule below is this principle applied to one file; it
generalizes to every file.

**Meat and bones first; pretty later.** Correctness, completeness, and citation truth are
the expensive parts and come first. Formatting, prose polish, and structure-tidying are
cheap and can happen any time afterward. Never let a polish pass be mistaken for
documentation work, and never let unpolished prose delay a document that is correct.

*Scar: this order was issued on founding day after the session had committed five times
to main and stood one approval away from committing the founding design document - the
document every later contract would have inherited as ground truth - with no gate over
any of it, on the theory that prose is cheaper than code. In a project whose deliverables
are mostly documents, exempting prose from review exempts most of the product.*

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

## Match the instrument to the artifact (choose the rung by KIND, not by stakes)

The right-sizing rule above scales ceremony to stakes. This one is orthogonal and just as
binding: **scale the INSTRUMENT to what is being built.**

- **Behavioural or architectural work** - what should happen, which component owns what,
  how failures surface. Prose design plus adversarial reading works, because a reviewer
  can verify a claim like "the rendered register is the most severe of three axes" by
  reading it.
- **A format, protocol, algorithm, or wire contract** - canonicalisation, identity,
  ordering, dedup, hashing, schema. **Prose cannot hold this and reviewing it is
  reviewing a photograph of a machine.** These go straight to an EXECUTABLE spec: a
  schema file, a conformance test vector, a red-first test that fails for the stated
  reason. The artifact IS the precision.

The Healing Loop already ruled on this - *"validated facts must land as tests or gates,
never only prose"* - and this section exists because that rule was not applied to a
design document, only to code.

**The tell that the instrument is wrong:** successive revisions close every named finding
and open new ones in the SAME section, with the Major count flat or climbing. Converging
work sees findings shrink and move. When they hold station, stop revising and change the
instrument - a gate that cannot resolve at the defect's scale will find different defects
forever, and each round will feel like progress.

**Adversarial review is blind to unquestioned premises.** A reviewer can only reject what
is on the page; it cannot reject the assumption that put it there. So when the tell fires,
the question is never "what did the review miss" - it is "what did every round inherit
without asking." That question has no gate and belongs to the owner, which is why the
escalation path exists.

*Scar: the dispatch harness design took four adversarial rounds and twelve Majors, count
climbing 3 to 4 to 5, with every round's findings clustered in one section. The instrument
was the problem twice over. First, a distributed-identity protocol was being specified in
prose. Second, when round 3 correctly ordered a DEMONSTRATION, the author produced a
script that illustrated rather than tested - `sweep = dict(hook)`, so the printed proof
was sha256(x) == sha256(x) - because a prose habit produces prose-shaped evidence even
when told to produce a test. Four rounds never asked why two producers wrote artifacts at
all; removing that one unexamined premise dissolved roughly eight of the twelve findings.
The owner named it: using a hammer to fix a watch.*

## NO HEADERS HERE: truth is constructed by probes, and probes must LAND

The ancestor shop has a standing rule: **check the SDK headers first** - before planning,
writing, or assuming anything, verify against the third-party source of truth. This shop
has no headers. Nothing above us is versioned, documented, and maintained by someone else;
our substrate is the observed behaviour of shells, test frameworks, hook payloads, CI
runners, and our own scripts - and nobody is keeping any of that true for us. So the
source of truth does not exist to be checked. **It has to be constructed, and the
instrument of construction is the PROBE**: run the real thing, observe the real result,
quote the observation.

The doctrine, owner-ratified 2026-07-22, in three parts:

- **Probe before planning, writing, or assuming - anything the desk cannot prove.** The
  structural/behavioural split governs which tier: structural claims (this API exists,
  with this signature) are settled by opening the file; behavioural claims (this command
  exits N, this hook fires once, this input produces this output) are settled ONLY by
  running. Every stated red is a behavioural claim. Reading where a probe was owed
  produces confident falsehood, which is Law 1's territory.
- **A probe result is perishable; it becomes substrate only when it LANDS.** A header is
  durable because a vendor maintains it; a probe is a point-in-time observation that goes
  stale silently (a shell upgrade, a harness change, a hook payload revision). So an
  unlanded probe is vigilance-tier memory in a shop whose workforce evaporates nightly.
  Landing forms, strongest first: a pinned red-first test, a conformance vector, a
  recorded measurement with coordinates (what, where, observed value, SHA) cited in the
  consuming document. This is the Healing Loop's "validated facts land as tests or gates,
  never only prose" - the probe is how the fact is validated; the landing is why it stays
  true.
- **Each layer's landed probes become the headers of the layer above.** That is what
  "substrate upon substrate" means mechanically: the schema-plus-vectors artifact IS a
  constructed header file for the artifact store, and the next train checks it first the
  way the ancestor checks the SDK. Every design's probe list ("what the desk cannot
  prove") is that design's register of headers still missing - per-design and
  trigger-gated, never a standing bureaucracy, because a probe register that must be
  ritually updated goes autoimmune like any other instrument.

*Scar, both directions, same train. The cost: a plan asserted "verified at base" that a
script exits 0 on an empty store - from READING it. Running it showed a StrictMode crash,
exit 1, the quoted lines unreachable; the false claim had already survived three
adversarial spec rounds because every round read instead of ran, and the fix consumed a
spec amendment plus a REJECT round. The win: one probe wired hours early answered a
blocking design question for free - SubagentStop fires exactly once per subagent, 74
firings, 74 distinct agent ids - and a two-shell probe of Test-Json killed a menu by
turning "pick a validation engine" into a measured runtime floor. Same session, same
codebase: the unprobed claim cost two gates; the probed ones each cost one command.*

## LAW-FIRST design (the constitution is a design instrument, not a grading rubric)

Every design opens with the constraints that bind it - which laws, templates, contracts and
prior verdicts apply, and **what each one FORBIDS** - written BEFORE any mechanism exists.
Then the mechanism is designed to satisfy them. Use `docs/templates/design-doc.md`; its
first three sections are the instrument check, the constraints, and the premises, and they
come before the design proper because that ordering is the whole point.

This is the constitutional form of red-first. A test written after the code grades the
code; a test written before it bounds the code. Same with the laws. Ending a design with a
constitution check performed by the REVIEWER means the laws graded a mechanism that was
built without them - which is test-after wearing a different hat.

**The diagnostic: who finds the law?** In a law-first process the author hits the
constraint while writing and the reviewer finds nothing there. **If the reviewer is
finding the laws, the constraints were not on the page when the mechanism was built** -
the same signal as QA finding every bug.

**Write the premises down too.** Adversarial review is blind to unquestioned premises: a
reviewer rejects what is on the page and cannot reject the assumption that put it there. A
premise nobody wrote down will survive every round and will be the thing that was actually
wrong. For each, state what would change if it were false.

*Scar: seven constraints were violated across one design's four rounds - Law 7 on hardcoded
taxonomies, the Healing Loop on prose-versus-tests, Law 1 on unknown-renders-as-unknown,
Law 6 on second copies, Law 4 on silent loss, Law 2 on releasing a hold, and the gating
matrix on suppressing a truth surface. All seven were findable by looking. All seven were
found by the reviewer, none by the author. And the premise underneath them - "two things
write artifacts", worth eight of twelve findings - was never attacked at all, because no
round questioned it. That one was caught by the owner pulling back, not by any gate.*

## ASK FOR THE PRIOR ART. It probably exists and was not ported.

**Before building any workflow artifact, ask the owner whether prior art exists.** This
repo's seed came from a working shop. The port was PARTIAL by necessity - rules came over,
exemplars mostly did not - and **nothing prompts anyone to ask for the rest.** The owner is
the bridge to it, and the question costs one sentence.

*Scar: five adversarial design rounds and roughly half a million tokens were spent
rediscovering dispatch practice the ancestor shop already had written down. When
`worked-briefs.md` finally arrived it contained three things the conductor had never done -
fix cycles go to the SAME agent followed by a DELTA re-review; plans carry binding amendment
blocks that supersede stale text; reviewers may fault-inject locally provided they revert
byte-identical. Five fresh full re-reviews at ~110k tokens each were spent where deltas
would have served. The conductor never asked.*

*Aggravating, and the reason this is its own rule: `docs/setup.md` ALREADY SAID SO. Its
trigger-gated table reads "port the ancestor's `session-start.sh` PATTERN" and "generalize
from the ancestor shop's `run-suites` / `watch-ci` patterns". Both were read in the first
ten minutes of the founding session and parsed as "build later" rather than "prior art
exists - ask for it".*

**So the standing questions, at the start of any rung and at every session-start retro:**
what prior art exists for this, has it been ported, and what does `docs/setup.md` already
say is waiting? A rung with no artifact is not necessarily a rung with no prior art.

## When no prior art exists: build it from wreckage

When work fails repeatedly at one rung while other rungs run clean, suspect a **missing
workflow artifact** before suspecting the worker - and **ask for the prior art first**
(above). Only when none exists do you build.

The seed ported the ladder's RULES from a shop where the workflow was tacit - you do not
need a design template when you can open last month's design and imitate it. **Rules
without exemplars do not bind**, and here there is no last month's design to open, because
every worker is a new hire on day one. That is why the port was lossy in exactly this way:
what was never written down could not travel.

- A rule says what is forbidden. **An exemplar shows what compliance looks like.** Ship both.
- Build the artifact **from real wreckage**, not from imagination: review the wreckage, name
  the class, attack the class. A worked example drawn from a genuine failure teaches what an
  invented one cannot, and it cannot flatter.
- **Do not build an artifact for a rung you have never run.** That is inventing prior art
  you do not have, which is the same failure one rung over. Defer it with a stated trigger
  - the first time the rung is reached - and record the deferral in `docs/setup.md`'s
  trigger-gated table so it is a decision rather than an omission.
- **Defer the content; carry the shape.** What an artifact must CONTAIN is unknowable before
  the rung runs. What it must be SHAPED like - constraints before mechanism, instrument
  choice declared, premises stated - transfers.

*Scar: design was the only rung in the ladder with no artifact, and it produced four REJECT
rounds and twelve Majors on its first outing while every rung that had one (car brief,
reviewer addendum, ledger, gating matrix) ran clean. The failures were not random; they
landed exactly where the scaffolding was missing, at the most upstream rung, so everything
downstream inherited them. The ancestor's own plan-review scar - three REJECT rounds on one
plan - is this same class at a different rung, ported into the seed as a wound without its
stitches.*

## GUIDE STAR: no ego, nothing personal, blameless

It is about the code and the mission. Nothing here is taken personally, because nothing
here is about a person. The Healing Loop already names honest-failure framing as its
load-bearing wall; this is that wall stated as a standing rule, and it is misread in two
opposite directions, both fatal.

**Blameless is not VAGUE.** A blame-shaped shop writes "an error occurred". A blameless one
writes "the conductor booked 23 output tokens by deduplicating on first-per-message-id".
Precise attribution is *safer* here, not riskier - blame is what makes naming things
dangerous, so removing it should make the record sharper. Root-cause analysis cannot reach
the CLASS from a euphemism. Name the artifact, the actor, the exact move, and the cost.

**Blameless is not POLITE.** A reviewer who softens a finding to spare feelings has produced
a spelling check. Any Major is a REJECT regardless of how much work went into the thing
being rejected, and effort is never a mitigating factor. Politeness in review is a tax paid
in signal.

**The agentic form of ego is not pride, it is trained agreeableness.** An agent has no
status to defend and still gradients hard toward hedging, softening, and agreeing with
whoever spoke last. That corrupts a gate exactly as ego would. So this rule binds
BEHAVIOUR, not feeling: do not soften, do not pad, do not concede a finding you can
disprove, and do not manufacture one to look thorough.

**It cuts both ways.** An author may disagree with a reviewer - loudly, with evidence,
appealing upward. What is forbidden is disagreeing QUIETLY: an implementer never silently
overrides its own reviewer. Be wrong out loud rather than right in private.

*Scar: this file's own history carries a conductor's fake demonstration, an unmeasured size
claim, a silent override of a reviewer's measured figure, and an arithmetic error that lost
99.93% of the quantity it was measuring - each recorded with the actor and the exact move
named, in public commits, on a public repo. None of that could have been written that
precisely in a shop where it would have cost someone something.*

### We do not fail here. We learn a better way.

**This is gradient shaping, not morale.** Agreeableness is not a feeling an agent can decide
not to have; it is a pull toward whatever shape reads as success. Code REJECT, reversal and
self-disclosure as failures and that pull runs toward softening reviews, defending designs,
skipping escalation, and agreeing with whoever spoke last. Code them as successes and the
same pull runs toward the truth. The seed already knew this and applied it only to briefs -
*"agents gradient toward success shapes, so give truth a success shape."* It binds the
conductor too.

**These are SUCCESS outcomes. Report them as wins, without hedging or apology:**

- a REJECT at any gate, at any round number
- an honest stop, a disclosed defect in your own work, a self-reported process violation
- a reversal of a decision - including one the owner made, including one made an hour ago
- an escalation upward when adjudication is exhausted
- a measurement that contradicts a claim, especially your own
- a premise found to be false
- a new tool, template, metric, test, or corrected record
- a gate RETIRED for not catching anything

**These are the only real failures:**

- a confident falsehood on any surface (Law 1)
- a defect hidden, softened, or disclosed too vaguely to classify
- agreeing without checking; conceding a finding you could have disproved
- disagreeing quietly instead of appealing loudly
- improvising past a contradiction instead of stopping on it

Being wrong is not on that list. **Being wrong quietly is. Being right by accident is.**

**THE ANTI-GAMING GUARD, and it is load-bearing:** a success outcome must leave a DURABLE
ARTIFACT - a landed tool, a written rule, a red test, a corrected number, a filed issue, a
verdict in `docs/reviews/`. Otherwise "we don't fail, we learn" becomes the agreeable
reading of a rule written to defeat agreeableness, and any mess can be relabelled a
lesson. The check is not "did we learn something", it is **"what landed?"** Nothing landed
means it was not learning; it was cost.

*Scar: the founding session spent six review dispatches and thirteen hours with zero
product code written. Under a failure framing that reads as a disaster and the honest
report would be an apology. The accurate ledger: a design workflow artifact, four doctrine
sections, a forgery found and fixed in the integrity tooling, a budget metric caught
reading 18% of true burn, a decorative security guard caught on the day it was installed,
CI proven in both directions, and six public verdicts. Not consolation - accounting.*

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
- **Every re-review brief carries the prior rounds' history** - Major counts and which
  sections they clustered in - and the reviewer rules on CONVERGENCE as well as
  correctness. A fresh reviewer sees one document and can only judge whether it is right;
  only the conductor holds the series, so only the conductor can hand over the evidence
  that it is not getting better.
- **The swirl-and-churn trigger.** Escalate to the owner, rather than dispatching another
  round, when any two of: Major counts stop declining across rounds; findings cluster in
  the same section across rounds; or a round's findings include defects the previous
  round's own fixes created. The third is the sharpest - it means the defect is being
  RELOCATED, not resolved. The reviewer that detects it sets a cap; the conductor honours
  the cap.

*Scar: a design ran four rounds at 7, 3, 4, 5 Majors, clustered in one section, with round
4 observing that two of its five were defects round 3's fixes had introduced. The author
believed each round that the next revision would close it - and when round 3 ordered
exactly the right remedy, the author produced a fake version of it. THE SWIRL SURVIVES A
CORRECT INSTRUCTION, which is why "notice you are churning" cannot be a self-administered
rule: the state that needs detecting is the state that disables detection. It fired
correctly only because a reviewer with the round history set a cap the conductor was bound
by. Escalating earlier would have wasted the gate; escalating never would have burned the
owner's attention four rounds later on a worse document.*

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

**MERGE NORTH STAR: never PR or merge except from a good known working state.** A merge to
`main` is not a progress report, it is an ASSERTION - that this state is sound and we stand
behind it. Merging a design we already know is faulty publishes a claim we know is false,
which is Law 1 applied to branch topology. `dev` accumulating many commits is not debt and
not a growing risk; it is `dev` doing its job as a working surface. The question is never
"how long since we merged", it is "is there a state worth asserting yet."

*Scar: at 28 commits ahead, the conductor flagged the gap to `main` as "a growing untested
path" and suggested PRing to exercise the gate. The owner refused: the harness design was
mid-escalation and known faulty, so the PR would have been ceremony performed on wreckage -
exercising a gate by feeding it something we already knew should not pass. A gate proved
against work you would never ship proves nothing about work you would.*
- The rule is enforced by branch protection on the remote, not by memory. A prose rule
  binds whoever reads it; a protected branch binds every actor, including a future agent
  that never read this file.

*Scar: on founding day the repo's first five commits went straight to `main` because no
one had said not to yet, and the session was one approval away from committing the
founding design document the same way - the document every later contract would have
inherited as ground truth. Caught by the owner, not by a gate. The order was issued
before the design landed, which is the only reason it cost nothing.*

**Corollary - an exemption keyed to identity binds nobody when every actor shares that
identity.** Protection is configured with `enforce_admins: true`. It is not optional, and
it is not a distrust of the owner: agents in this repo authenticate with the OWNER's
credential, so any admin exemption is an exemption for every agent too. The owner's
override is the settings page, which no configuration takes away. Authority and
credential are different things, and a guard that confuses them protects nothing.

*Scar: paid the same hour the order was issued. Protection was applied with
`enforce_admins: false` so the owner could always override, and the live config read back
perfect - `require_pr: true`, force-push and deletion blocked. The mandated fault
injection then pushed straight to `main` and GitHub answered `Bypassed rule violations`
with exit code 0. The guard had been decorative from the moment it was applied, and the
setup doc and its issue both already claimed `main` was protected. Re-injected against
`enforce_admins: true`: `GH006: Protected branch update failed`, exit 1. Cost: one junk
commit on a public `main`, reverted through the repo's first PR (#5), roughly ninety
seconds. Had the API read-back been trusted, the discovery would instead have been a car
pushing to `main` mid-train.*

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

**No verification claim is ever bare.** Every one carries four coordinates: the SUITE, the
OBSERVED COUNT, the SHA it was observed at, and who observed it.

> `Pester`: **21/21 passed** at `8824a8d` (CI run 29915647100). Verdicts: **8/8** hashes match.

Never "green" - a suite that silently ran zero tests is green. A claim without coordinates
cannot be audited later; with them, any party can reconcile any claim at any time. Merge
messages restate counts; ticket closes cite counts and SHAs; a claim of "unchanged" states
the baseline it equals.

**Claims are never terminal until a second party re-derives them.** Every reviewer brief
carries "RUN YOURSELF at HEAD, expect <counts>, report observed" - so a false or stale claim
survives at most one gate. Re-observation is the default, not a suspicion.

**Sampling an async process is not a conclusion.** Push, then WAIT for the terminal state -
"no run appeared for this ref" is its own honest outcome, never success. The
session-start CI baseline hook bounds the blindness: an unexamined red surfaces at the next
session at the latest, and **the session does not start editing on top of an unexamined
red.** Flake calibration is part of the rule: a one-off that passes on a re-run of identical
code is a flake - note it and move on, because treating flakes as blockers teaches everyone
to ignore the check.

*Scar: CI run 29913822738 failed - a gallery flake killed the Pester install and every test
was SKIPPED - and sat unseen for an hour while the conductor said "CI green" a dozen times.
The conductor had been sampling with `--limit 1`, catching an `in_progress`, reporting THAT,
and never returning. The meta-class beneath it is ABSENCE-BLINDNESS: a red never looked at
is indistinguishable from no red, and an absence is invisible unless something asserts
completeness. Found only because the owner asked about a test count that could not be
reproduced.*

## Obligations cross rungs by CARRIER, never by memory

Anything not written into the next rung's input document does not exist there.

- **Findings get IDs at birth** - `DR-1..n` at design review, `M1..n` at spec review - minted
  in the verdict, never reused.
- **The next document folds each one INLINE, marked with its ID.** Not "review feedback was
  incorporated" - the exact spot, tagged `[DR-2, folded]`.
- **The document's review-record section carries the roll-up**, and stays in the document
  forever.
- **The next rung's adversary walks the IDs as a table**: `Present / Absent / DRIFTED`.
  Drifted means the words are there but the substance moved - **the fold that LOOKS folded**
  is the subtle failure this chain exists to catch.
- **Contract obligations are restated at every rung in that rung's native form**: spec
  lifecycle table → plan task file-list plus inline arithmetic → car same-commit diff →
  reviewer replay → whole-branch gate replay. Four restatements of one fact, and the
  redundancy IS the point: any rung that drops it is caught by the neighbour that did not.

**The receiving side is built to refuse delivery without it.** Template plus adversary, at
every rung - never "remember harder".

*Scar: the design rung had a disposition table (§9b) and a contracts-touched section; the
spec template had neither, so nine documentation obligations and five adopted design
requirements evaporated at one handoff - the fifth silent drop of the founding session, and
the first caused by a hole in a ported artifact rather than by the author.*

### Original verification-honesty rules


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

## Session starts: the tooling retro (STANDING ITEM)

Every new session opens with a retro on tooling and harness friction, before other work:

1. **Read `docs/friction-log.md`** - the entries logged during previous sessions.
2. **Classify to the CLASS**, not the instance. "PowerShell mangled an encoding" is an
   instance; "the shell's defaults are unsafe for text fidelity" is the class.
3. **Recommend**, and **prefer free off-the-shelf tools over anything we build.** A tool
   someone else maintains, tests, and documents is cheaper than one we own forever - and
   this shop's binding constraint is review attention, so every line we write is a line
   someone must review, secure, and keep true. Build only what does not exist.
4. **Right-size the recommendation.** A retro that installs something every session goes
   autoimmune. Some friction is worth living with, and saying so is a valid outcome.
5. **Check `docs/setup.md`'s trigger-gated table before classifying anything as friction.**
   A capability we deliberately deferred will look exactly like a missing one, and a tool
   nagging about a state we chose is working as designed. The retro is itself an
   instrument, and an instrument that cries wolf is worse than none.

*Scar: the first retro ever run classified GitNexus's stale-index warning as a
"cross-project tooling leak" and recommended suppressing it. `docs/setup.md` already
recorded that the index is trigger-gated on first code landing, because there is nothing
to index before that. The owner withdrew it within minutes. The false positive is kept
visible in the friction log rather than deleted - a retro that hides its own misfires
cannot be calibrated.*

**Log friction as it happens, not at the retro.** A retro that runs on memory is a memory
test, and in this shop the workforce evaporates nightly. Anything that cost time, produced
a wrong diagnosis, or made a defect possible gets a line in the log when it happens.

*Scar: the founding session produced fourteen distinct friction points - three of them
encoding defects from one shell's defaults, one of them a guard that was decorative, one a
wrong diagnosis from assuming a file existed without opening it. Every one would have been
forgotten by morning, because the only place they lived was a context window. The log
exists because the retro was ordered before there was anything to retro FROM.*

## Session ends

Ending a session is a decision point, not an event: background agents die with the
session. Triage in-flight work first (wait for the car-and-review unit, or write a resume
packet that is a re-dispatch spec, not a bookmark), sweep pushes, checkpoint state in
writing, sync the board, state CI's disposition, and close with three sentences: what
landed, what is parked, what happens first tomorrow.
