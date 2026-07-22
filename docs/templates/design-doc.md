# Design document template

Status: Current. Copy to `docs/design/YYYY-MM-DD-<topic>-design.md`.

**Why this exists.** The ladder named design as rung 1 and gave it no artifact. Every other
rung had one - car brief, reviewer addendum, state ledger, gating matrix - and every other
rung worked. Design produced four REJECT rounds and twelve Majors on its first outing, and
the failures were not random: they landed exactly where the scaffolding was missing.

The seed was ported from a shop where the design workflow was **tacit** - you do not need a
template when you can open last month's design and imitate it. The port carried the RULES
and not the EXEMPLARS. In a human shop that is survivable. Here it is fatal, because the
seed's own first premise is that every worker is a new hire on day one: **there is no last
month's design to open.**

Rules tell you what is forbidden. Exemplars show you what compliance looks like. This file
is both.

---

## The order is the point

Sections 0, 1 and 2 are written **before any mechanism exists**, and they are not
paperwork. They are the design equivalent of a red test: a constraint written down before
the thing it constrains, so that violating it is visible at construction time rather than
at review.

**The tell that this was skipped:** the reviewer finds the law, not the author. In a
law-first process the author hits the constraint while writing and the reviewer finds
nothing there. If every constitution check in your review comes back with findings, the
constraints were not present when the mechanism was built.

---

## §0 - Instrument check (FIRST, and it can end the document)

> **What kind of artifact is this?**
>
> - **Behavioural / architectural** - what should happen, which component owns what, how
>   failures surface. A reviewer can verify these by reading. **Prose design is correct.**
> - **Format, protocol, algorithm, wire contract** - canonicalisation, identity, ordering,
>   dedup, hashing, schema. **STOP. Prose cannot hold this.** Reviewing prose about a hash
>   function is reviewing a photograph of a machine. Go straight to an executable spec: a
>   schema file, conformance vectors, red-first tests. The artifact IS the precision.
> - **Both** - split the document. The behavioural half is prose; the precision half is a
>   pointer to the executable artifact and its tests.

State the answer and the reason in one or two sentences. If the answer is "format", this
document should not be written.

## §1 - Constraints (BEFORE the mechanism)

> Which laws, templates, contracts and prior verdicts bind this design, and **what does
> each one FORBID**? Not a citation list - a list of prohibitions you are designing
> against.

| Source | What it forbids here | How this design satisfies it |
|---|---|---|
| `constitution.md:N` Law N | *what it rules out* | *filled in as the mechanism is written* |
| `docs/templates/<x>.md` | | |
| a prior verdict in `docs/reviews/` | | |

Open every source and quote the binding clause. A constraint you paraphrase from memory is
a constraint you will satisfy from memory.

## §2 - Premises

> What is being assumed that **no constraint forced**? List them plainly.

Adversarial review is blind to unquestioned premises: a reviewer rejects what is on the
page, and cannot reject the assumption that put it there. A premise written down is a
premise that can be attacked. A premise left implicit will survive every round of review
and will be the thing that was actually wrong.

For each: **what would change if it were false?** If the answer is "most of this document,"
that premise deserves its own scrutiny before anything else is written.

## §3 - The problem

One or two paragraphs. What is broken or missing, and what does the owner actually want -
in their words where possible, since a restated requirement is a requirement that has
already drifted.

## §4 - Decisions

| # | Decision | Reason | Which constraint or premise drove it |
|---|---|---|---|

The last column is load-bearing: a decision that traces to neither a constraint nor a
premise is a preference, and preferences are where unexamined complexity enters.

## §5 - Mechanism

The design proper. Types, flows, components, interfaces.

## §6 - Failure modes

Every way it breaks, what the system does, and which law that behaviour honours. Absence,
staleness, partial data, conflicting sources, and the unknown state - `constitution.md:17`
requires unknown to render AS unknown, and it is the most commonly missed row in this table.

## §7 - Out of scope

Including things deliberately deferred, with the trigger that would bring them back.

## §8 - Contracts touched

State ledger, gating matrix, any document this design invalidates on landing, and **which
car owns updating each**. Ownership stated once, in one table.

## §9 - Cost

Dispatch count, model mix, size class. Owner approval recorded **before** dispatch.

## §9b - Disposition of the prior round (re-revisions only, and it is not optional)

> One row per prior **finding** AND per prior **ruling**. Every row gets a disposition:
> **adopted / adapted / appealed / rejected-with-reason**. A blank is a defect.

| Prior item | Kind | Disposition | Where |
|---|---|---|---|
| Major 1 … | finding | adopted | §5.3 |
| Ruling on Q1 … | **ruling** | appealed - reason, evidence | §4 |

**Rulings need rows as much as findings do, and this is the reason the section exists.**
An implementer never silently overrides its own reviewer; rejection is appealable upward,
never around. Disagreeing is legitimate and welcome - **disagreeing quietly is not**, and
the failure mode is never a loud argument, it is an item that simply stops appearing.

This is a structural guard against a known model bias, not a discipline exercise. A pull
toward smoothing over conflict is not something an author can decide not to have; a table
with an empty cell in it is something a reviewer can see.

*Scar: three silent drops in one design series. A reviewer's measured cost figure was
revised down with no statement of disagreement (the author's replacement figure was wrong).
A ruling on schema membership was reversed with no disposition (the reversal was
defensible - an appeal would have been legitimate and would have been upheld). A ruling on
intra-kind ordering, which the reviewer had grounded in this repo's own shipped code, was
dropped entirely. All three were invisible because the prior round's items had no
mandatory row.*

## §10 - Open questions for the reviewer

Real ones, with the cost of each answer. A design that hides its soft spots produces a
review that finds nothing.

---

# WORKED EXEMPLAR: the dispatch harness, and what §0-§2 would have caught

The harness design (`#7`) ran four adversarial rounds and produced twelve Majors before
being escalated. Four verdicts are landed verbatim in `docs/reviews/`. This is the wreckage
review: what the first three sections would have said, and what each would have prevented.

## §0 would have ended it in round zero

> **Answer: BOTH, and the half that mattered was format.** Identity, canonicalisation,
> dedup, ordering and supersession are a protocol. The trust model, publication rules and
> intent/facts split are behavioural.

**What this prevents:** rounds 2, 3 and 4 in their entirety. The Major counts ran 7 → 3 →
**4 → 5**, climbing, clustered in one section, with round 4 observing that two of its five
findings were defects that round had created with its own fixes. That is what a prose
instrument looks like when applied to a protocol: it cannot resolve at the defect's scale,
so it finds different defects forever and every round feels like progress.

**The confirming detail:** when round 3 correctly ordered a *demonstration* instead of more
prose, the author produced `sweep = dict(hook)` - an exact copy - so the printed proof was
`sha256(x) == sha256(x)`. A prose habit produces prose-shaped evidence even when explicitly
told to produce a test. §0 is the only place that habit gets caught, because it is asked
before the habit has anything to work on.

## §1 would have caught seven Majors at construction time

Every one of these was quoted back at the author by a reviewer. Not one was found by the
author. All were findable by looking.

| Constraint | What it forbids | What was built anyway |
|---|---|---|
| Law 7 (`constitution.md:54-55`) | *"no hardcoded board schemas or label taxonomies"* | A fixed lane-state enum, then three rounds tuning it |
| Healing Loop (`the-healing-loop.md:60-61`) | *"validated facts must land as tests or gates, never only prose"* | A canonicalisation procedure specified in Markdown for four rounds |
| Law 1 (`constitution.md:17`) | *"Unknown states render AS unknown, honestly"* | A closed union with no member for "server up, first poll pending" |
| Law 6 (`constitution.md:48-49`) | *"never maintains a second copy of anything that can drift"* | Two schema tables disagreeing on seven fields; a header verdict unhashed beside a body verdict |
| Law 4 (`constitution.md:32-36`) | *"never silently dropped"* | Fields outside the canonical set collapsing two disagreeing observations into one id |
| Law 2 (`constitution.md:21-23`) | *"never resists an override"* | A hold that could be set and never released |
| `gating-matrix.md:23` | staleness banner suppressed *"never (truth surface), DELIBERATE, no override"* | A demo mode that suppressed the staleness alarm |

Seven for seven, found by the reviewer. **That ratio is the diagnostic.** In a law-first
process the author hits the constraint while writing; if the reviewer is finding all of
them, the constraints were not on the page when the mechanism was built.

## §2 would have caught the one thing no reviewer could

The premise, never stated and therefore never attacked across four rounds:

> **"Two different things write artifacts."**

It entered in rev 1 §7, invented by the author to answer *"what if a hook fails and an
artifact is never written?"* The answer chosen was *add a sweep that also writes*.

That single unexamined move imported identity, canonicalisation, equality, clock ordering,
supersession authority, dual storage and aggregation - **roughly eight of the twelve
Majors.** The actual requirement was *detect missing artifacts*, and **a detector does not
need to be a writer.** One writer plus a read-only detector dissolves all eight; they do
not get fixed, they stop existing.

Four adversarial rounds never asked why there were two producers, because every round
inherited it as given. **That question has no gate**, which is why §2 exists and why the
escalation path to the owner exists: the premise was caught by a human pulling back, not by
the instrument.

## What the wreckage cost, and bought

Four review dispatches and roughly four hours, with zero product code written. Against
that: a forgery in the integrity tooling found and fixed, a budget gauge caught reading 18%
of true burn, a decorative security guard caught the same day it was installed, and this
document - built from real verdicts rather than invented tidiness.

*NTSB, not blame: review the wreckage, name the class, attack the class. The class here was
not "the fold is hard." It was **failure due to a non-existent workflow**, at the one rung
that had no prior art, because the seed ported rules without exemplars.*
