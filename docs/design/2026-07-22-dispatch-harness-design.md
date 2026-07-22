# Design: the dispatch harness

Status: **DRAFT rev 2 - awaiting adversarial design review (round 2)**
Issue: #7 (`area:adapters`)
Date: 2026-07-22
Ladder rung: design (rung 1 of: design → spec → plan → cars)
History: rev 1 REJECT (7 Major, 10 Minor). Verdict landed verbatim at
`docs/reviews/2026-07-22-harness-design-round1-REJECT.md`. See §13.

## 1. What this is

Every dispatch emits a **structured artifact**. The artifacts are the process's record of
itself and the yard board's data source. Keystone: it sits in the integrity path of every
gate, and after it lands the board renders facts the work produced rather than facts a
human remembered to type.

## 2. The class, and the citation frame

A dispatch's output is ephemeral by default; the only thing between an artifact and
oblivion was the conductor remembering to copy it out. That is **vigilance**, the weakest
tier in the Healing Loop's hierarchy.

Entire.io already provides **durability**. What it does not provide is **addressability**:
an artifact buried in a multi-megabyte JSONL is safe and unusable. And the obvious manual
fix was worse than the gap - the conductor began hand-transcribing a verdict about its own
design, which is a hand-maintained mirror with the reviewed party doing the copying.
**Verbatim-by-construction beats verbatim-by-discipline.**

**Provenance is cited, not linked** (owner's frame). A paper's reference names the work,
the exact locator, and the edition; *"see Smith 2019"* is bad practice. So every artifact
carries a Provenance block with the base commit (the lookup key), the resolved Entire
checkpoint id, and the dispatch id, plus the literal commands to follow it. **Every
citation is followed before landing** - rev 1's first citation implementation cited the
session UUID and was dead on arrival, caught only by trying it.

This also resolves rev 1's condensed-vs-verbatim question: a paper carries its argument
*and* deposits its supplementary material. The artifact keeps the verbatim body; the header
carries the readable summary and the citation. The harness lift is identical either way,
because the producer writes all of it and the conductor reads none of it.

## 3. Trust model - corrected per round 1's ruling on Q5

| Threat | Actual defence |
|---|---|
| The artifact changed after extraction - encoding drift, merge mangling, an edit in passing | **The integrity hash.** Not hypothetical: this repo has hit three such defects (ANSI decoding, BOM/CRLF, separator collision) |
| A determined conductor rewrites a verdict | **Publication, not cryptography.** The conductor owns the producer, the hash function, the verifier and CI. What constrains them is that Entire's checkpoint branch holds an independently-written copy anyone can diff |
| An agent writes an untrue verdict | **Nothing mechanical.** The defence is that verdicts are public and the next reviewer reads them |
| The runner's transcript is forged | **Nothing.** We are not in an adversarial environment; if we ever are, this design does not help |

Rev 1 claimed the hash defended against a dishonest conductor with an empty
"not defended" cell. **A reviewer fault-injected it and the claim collapsed**: flipping a
header from `REJECT - 8 Major` to `APPROVE - 0 Major` left the body untouched and the
verifier reported OK, exit 0. The hash covered the text nobody skims and left the claim
everyone skims unprotected. Fixed in `cd56035`: the integrity line now covers every byte
below it. The framing above is the honest version of what remains.

## 4. The artifact contract

**The schema is the product; producers are adapters.** Law 7: a stranger's shop runs a
different runner, so what ships is a documented format anyone can emit.

### 4.1 Events, with identity

Artifacts are append-only events, never mutated. Round 1 upheld this and named its price:
*"append-only plus no reaping is strictly worse for in-flight truth than a mutable record."*
§5 pays that price.

```
identity = (dispatch_id, kind, seq)
```

- `dispatch_id` is the runner's id, **namespaced by the session** so it is unique across
  sessions, machines and clones. Rev 1 left identity to "an opaque runner id" and the
  fold's central operation is a join on that key.
- `seq` disambiguates legitimate repeats (a task-id can notify more than once when an
  agent is resumed).
- **Idempotency:** landing is keyed on identity. A sweep re-landing what a hook already
  landed is a no-op when content matches, and a **loud conflict** when it does not - never
  a silent second copy. Rev 1 had a hook and a sweep both able to land the same event with
  no dedup rule, so the fold's answer depended on iteration order.
- **Clock:** `at` is stamped by the producer, and a `clock` field names which producer
  stamped it. A sweep-landed event reconstructing a time from a transcript says so, because
  a fold that compares two producers' clocks without knowing they differ is a fold that
  lies quietly.

### 4.2 Event kinds and supersession

| Kind | Emitted when | Terminal? |
|---|---|---|
| `dispatched` | a subagent is launched | no |
| `returned` | it completes (`delivered` / `honest-stop` / `error`) | yes |
| `reaped` | liveness declares it lost (§5) | yes |
| `intent` | the conductor declares what no dispatch can know | n/a |
| `ruling` | the conductor decides an appeal or override | n/a |

`verdict` is **not** a separate kind (round 1 ruling Q3): `kind` is set at `dispatched`
from the brief, `outcome` at completion. A reviewer that returns garbage folds as a
review dispatch with `outcome: error` - a verdict-shaped hole the board renders as
*"reviewer failed to produce a verdict"* - with one record that cannot disagree with itself.

**Supersession, and Law 2.** Every `intent` and `ruling` carries `supersedes:
<event-identity> | null`. Rev 1 had no supersession rule, which meant **a hold could be set
and never released** - the channel that exists to serve the dispatcher's override could not
express withdrawing one. `constitution.md:21-23` requires the board never to resist an
override. Current intent = the latest un-superseded event for that subject.

### 4.3 Who supplies each field

Round 1 ruling Q2, adopted: **the producer supplies everything it can observe; the agent
supplies only judgement.**

| Producer-derived (observable) | Agent-supplied (judgement) |
|---|---|
| `dispatch_id`, `seq`, `at`, `clock`, `model`, `base`, `gate`, `target`, `role`, `cost`, `producer` | `outcome`, `findings`, `abstract` |

Rev 1 asked the agent for facts the producer already held, which is asking a stranger for
your own address and creates an agent-drift surface for no gain.

**The cross-check is deleted.** Rev 1 claimed finding counts would be "cross-checked
against the body where the body is structured enough to count." There is no defined finding
grammar, the word *Major* appears in headings, quotations and prose, and the escape clause
makes the check unfalsifiable. An instrument that cries wolf is worse than no instrument.
**Counts are the reviewer's assertion, hashed together with the body that justifies them,
and rendered as an assertion.**

### 4.4 The envelope, and a problem rev 1 did not anticipate

The agent ends its report with a delimited block carrying `outcome`, `findings`, and a
short `abstract` in its own words.

Two things learned from the first agent ever asked to comply:

1. **The sentinel collided in the first document that used it.** The reviewer quoted the
   opening sentinel while discussing it, and had to *reason about the parser* - deliberately
   avoiding a matching close-tag - in order to comply. A separator that can appear in the
   payload is not a separator, and "implausible in prose" is not a property a review of the
   format can have.
2. **The platform's own safety layer neutralised the tags**, flagging the output as
   instruction-shaped. The metadata channel was mangled in transit by a layer neither the
   conductor nor the agent controls.

**Therefore the envelope must not be a novel sentinel.** It is a fenced code block with a
declared info string (```` ```starcar-artifact ````), parsed as the LAST such block in the
report, with nesting handled by the fence rules markdown already defines. If the block is
absent or malformed, the artifact lands as `outcome: error` **with its body intact** and the
board says so - never a guess, never a silent drop.

### 4.5 Cost - adjudicated against round 1

Rev 1 claimed the runner reports per-dispatch cost. Round 1 called that false. **The
reviewer was wrong and the finding is downgraded with evidence**: the task notification
carries `subagent_tokens`, `tool_uses` and `duration_ms`, verified present for all three
dispatches (71942 / 99390 / 115565 tokens). It searched for `totalTokens` and concluded
absence.

Its deeper point stands and is adopted: `subagent_tokens` is **one conflated scalar** that
does not separate input, output and cache reads, which bill at different rates. So `cost`
is carried, labelled an **approximation**, and the fuel lane renders it as one - a gauge
that implies precision it does not have would be a Law 1 defect on the surface whose whole
job is honesty about spend.

## 5. Liveness - the ghost problem

Rev 1 derived "a car is rolling" from *a `dispatched` with no terminal event*. Kill the
session, sleep the machine, or lose an agent without a completion signal, and that state is
**permanent**: the board shows a car rolling that died days ago. `constitution.md:13-17`
names the inverse (idle while burning) as the worst defect this project can ship; this is
the same defect facing the other way.

- Every `dispatched` carries `expect_by` = its dispatch time plus a **stated liveness
  budget**.
- A dispatch past `expect_by` with no terminal event folds as **`unknown`**, not `rolling` -
  `constitution.md:17`: *"Unknown states render AS unknown, honestly."*
- A reaper emits a `reaped` event once liveness is declared lost, so the store records the
  judgement rather than the board re-deriving it every render.
- **The board shows both** the elapsed time and that the dispatch is unaccounted for. A
  reaped dispatch is not a failed one; we know we do not know.

This is the price §4.1 owes for choosing append-only, paid explicitly.

## 6. Detecting what is missing

Round 1's sharpest structural point: **a hash verifies what exists; an absence is invisible
to every mechanism in rev 1.** Verification, the index, and the "loud failure" on a bad
envelope all operate on artifacts that arrived.

So reconciliation is a first-class operation, not a backstop:

- The `dispatched` event **is the ledger entry**. Reconciliation asserts every `dispatched`
  has a terminal event or an explicit `unknown`.
- The transcript is the second source: the sweep enumerates dispatches the runner recorded
  and asserts each has an artifact. A dispatch in the transcript with no artifact is a
  **missing-artifact finding**, surfaced, not silently absent.
- **CI runs reconciliation**, which is the mechanical tier. Rev 1 assigned the sweep to
  `/goodnight` - a human-invoked skill that, as round 1 found, *contains no sweep step*.
  The class moved from vigilance to procedure and was claimed as closed. It is closed only
  when a machine asserts completeness.

## 7. Producers - the corrected hook lifecycle

Rev 1's central claim was wrong in mechanism. `PostToolUse:Task` **fires at launch**, with
`status: async_launched` and no body - proven from the transcript, and implied by our own
`Land-Verdict.ps1`, which scrapes the transcript precisely because there is no result to
read. The design asserted the opposite while the counter-evidence sat in its own tree.

Corrected, and verified against the runner's documented hook events before being written
here:

| Event | Hook | What it carries |
|---|---|---|
| `dispatched` | `PostToolUse:Task` | Fires at launch. This is not a workaround - launch is exactly when a dispatch begins, so the "wrong" timing is the right trigger for this event |
| `returned` | `SubagentStop` | *"Execute when subagent considers stopping."* Payload is `reason`, **not the body**, so extraction machinery stays; only the trigger changes |
| `reaped` | reconciliation (§6) | not hook-driven |

**Open and honest:** whether `SubagentStop` fires for asynchronously-dispatched subagents
in the parent's hook context is **not yet verified empirically**. The event exists and is
documented; its behaviour under async dispatch must be tested before the spec, and the
spec is blocked on that test. Designing on an unverified mechanism is the exact error rev 1
made.

**Law 7 obligations on the producer:** no hardcoded project path (rev 1's implementation
violates this - `Land-Verdict.ps1` hardcodes the project directory); the vendor transcript
format confined to the producer and documented as a known coupling; every runner-shaped
field (`cost`, `producer`) marked **optional**, so a shop whose runner reports differently
can still emit a conforming artifact.

## 8. Publication, normalisation, and what stays out

The store is public by construction, and the artifacts are committed automatically. That is
a real decision, and round 1 was right that rev 1 had not named it.

**Owner ruling, adopted:** *"There is a difference between the full monty and being silly.
Redacting full paths isn't hiding anything."* Operator-environment paths are normalised to
`<repo>` and `~` **before hashing**, mechanically, narrowly, with the rule declared in each
artifact and the un-normalised original preserved on the checkpoint branch. Normalisation
is not curation: findings, verdicts and counts are untouched, and Law 7 actively wants a
path a stranger can use. Already implemented (`3e247dc`); the `CLAUDE.md` NORTH STAR
carries the principle and its scar.

Rev 1 also contradicted an existing in-repo ruling: the parked yard design forbids the
board from rendering absolute paths for exactly this reason, while the artifact store
published them verbatim. The repo held the principle and had not applied it to itself.

## 9. The store

- `docs/artifacts/YYYY-MM-DD/HHMMSS-<dispatch>-<kind>.md`, sortable and identity-bearing.
- A **generated** `INDEX.md` from front-matter; hand-maintaining an index of a growing
  store is the mirror class again and would rot within one train.
- The index is regenerated on landing and **checked in CI** - a store whose index is stale
  is a lying instrument.
- `docs/reviews/` retires into the store, history preserved, in the same commit that
  creates the index, so `README.md:20-21` is never momentarily false.

## 10. Derivation - intent versus facts

**The conductor declares INTENT; the process emits FACTS.** They own different things, so
no field has two writers and there is no precedence rule to get wrong. Round 1 called this
"the best idea in the document" and it survives unchanged.

| Fact | Source |
|---|---|
| A car is rolling | `dispatched`, no terminal event, **within `expect_by`** |
| A car is unaccounted for | `dispatched`, past `expect_by`, no terminal event → `unknown` |
| A car is at inspection | its reviewer's `dispatched`, same rules |
| REJECT rounds | count of terminal events with `outcome: REJECT` |
| Cost burned | sum of `cost`, **rendered as an approximation** (§4.5) |
| A car is coupled at SHA | git |
| Inbound freight | the issue tracker |
| Train composition | conductor `intent` |
| A train is held / released | conductor `intent`, latest un-superseded (§4.2) |

Correction owed on rev 1's own account: it claimed to fix a two-fact-domain seam "where
both the registry and the state file could supply a lane's position." **That was rev 2 of
the yard design; rev 3 had already closed it.** A false claim about a sibling document, in
a repo whose north star is documentation honesty. The parked design's status block
overstates the damage too, naming §5.4 as rewritten when it is untouched; both are
corrected when that document returns as rev 4.

## 11. Cars and cost

Round 1's right-sizing ruling adopted: **three cars, not four.**

| Car | Scope |
|---|---|
| 1 | Schema, identity, validator, store layout, generated index, **verification** (the inverse of the hashing this car defines, so it belongs beside it) |
| 2 | Producer: hooks, extraction, envelope parsing, sweep, reconciliation; brief-template and agent-definition updates (the north star puts them in the commit that makes them necessary) |
| 3 | CI wiring; migrate `docs/reviews/` into the store |

Three cars, three reviewers, plus design, spec and plan with reviews: **roughly 11
dispatches**, model mix Opus throughout, size class **medium**. Down from rev 1's 14.
**Approved by the owner on 2026-07-22, before dispatch** - the cost discipline rule is
that exceeding a window is a decision made beforehand, never a discovery on the bill.
REJECT rounds add to this figure and are expected outcomes, not overruns.

Car 3 wires this repo's first CI and is **not done when CI is green - done when someone has
WATCHED it go red** (fault-inject, observe, revert, put the run URL in the report). A green
light wired to nothing is worse than no light.

One risk, stated: the schema's only consumer does not exist yet, so it is designed against
an imagined reader. **Rev 4 of the yard design should be treated as this schema's first
real review**, not as a downstream inheritor.

## 12. Out of scope

Signing or non-repudiation beyond the integrity hash (§3). Retention and pruning. Producers
for other runners, though the format must not prevent them. Rendering - the yard design's
job. Migrating dispatches from before this train, **except** the three landed verdicts,
which car 3 migrates (rev 1 contradicted itself on this).

## 13. What changed from rev 1

| Round 1 finding | Disposition |
|---|---|
| MAJOR-1 `PostToolUse:Task` fires at launch, not completion | §7 - corrected lifecycle, `SubagentStop` verified as a documented event, async behaviour flagged as blocking the spec |
| MAJOR-2 nothing detects a missing artifact | §6 - reconciliation as a first-class CI operation, not a `/goodnight` step |
| MAJOR-3 ghost dispatches | §5 - `expect_by`, `unknown` folding, `reaped` events |
| MAJOR-4 hash does not cover rendered fields | §3 - already fixed in `cd56035`; trust model reframed around publication |
| MAJOR-5 fold has no identity, ordering, dedup, supersession | §4.1, §4.2 - session-namespaced identity, idempotent landing, producer-stamped clocks, supersession so holds can be released |
| MAJOR-6 cost source does not exist | §4.5 - **adjudicated against**: it does exist; downgraded to "conflated scalar, label it an approximation" |
| MAJOR-7 unredacted public publication | §8 - owner ruling adopted and already implemented |
| Minor-1 misdescribes the parked design | §10 - corrected, with the parked design's own overstatement noted |
| Minor-2 `/goodnight` has no sweep step | §6 - reconciliation moves to CI; car 2 owns the skill update |
| Minor-3/4 `setup.md`, `README.md:46-47` stale | Car 3; `README.md`'s adapter list is named explicitly |
| Minor-5 §9 vs §10 on migration | §12 - resolved |
| Minor-6 two version strings | §4.4 - one fenced info string, no second version namespace |
| Minor-9 runner-shaped fields not optional | §7 - `cost` and `producer` marked optional |
| Minor-10 four cars is one too many | §11 - three |
| Ruling Q1 keep append-only | Kept, with §5 paying its price |
| Ruling Q2 split by who can know | §4.3; cross-check deleted |
| Ruling Q3 one record, `kind` at dispatch | §4.2 |
| Ruling Q4 retire is safe if same commit | §9 |
| Ruling Q5 hash reframed, not cut | §3 |
| Ruling Q6 land with current scripts, migrate later | Done - all three verdicts landed; car 3 migrates |

## 14. Open questions for the design reviewer

1. **`expect_by` needs a number.** A liveness budget too short reaps live agents; too long
   and the board lies for hours. Round 2's review ran ~15 minutes. Is a fixed budget right,
   or does it belong with the dispatch (the conductor knows if it briefed a big job)?
2. **Is `reaped` honest, or does it launder a guess into a fact?** The reaper does not know
   the dispatch died - only that it stopped reporting. Should the event be `presumed-lost`?
3. **Reconciliation needs a second source, and the transcript is the runner's.** For a shop
   whose runner keeps no transcript, is reconciliation impossible - and does that make §6's
   closure runner-dependent, contradicting §4's Law 7 claim?
4. **Does the fenced-block envelope survive the same safety filter** that neutralised the
   sentinel? Untested, and the whole metadata channel rests on it.
5. **Is a per-artifact file the right grain**, or does one train's ~11 dispatches produce a
   directory nobody navigates even with an index?
6. **§11 says rev 4 of the yard design is this schema's first real review.** Should the
   harness spec therefore wait for rev 4, inverting the ladder for one rung?
