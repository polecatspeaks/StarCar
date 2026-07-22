# Design: the dispatch harness

Status: **DRAFT rev 3 - awaiting adversarial design review (round 3)**
Issue: #7 (`area:adapters`)
Date: 2026-07-22
Ladder rung: design (rung 1 of: design → spec → plan → cars)
History: rev 1 REJECT (7 Major), rev 2 REJECT (3 Major). Verdicts landed verbatim in
`docs/reviews/`. See §13.

## 1. What this is

Every dispatch emits a **structured artifact**. The artifacts are the process's record of
itself and the yard board's data source. Keystone: it sits in the integrity path of every
gate, and after it lands the board renders facts the work produced rather than facts a
human remembered to type.

## 2. The class, and the citation frame

A dispatch's output is ephemeral by default; the only thing between an artifact and
oblivion was the conductor remembering to copy it out - **vigilance**, the weakest tier.

Entire.io provides **durability**. It does not provide **addressability**: an artifact
buried in a multi-megabyte JSONL is safe and unusable. And the obvious manual fix was worse
than the gap - the conductor began hand-transcribing a verdict about its own design.
**Verbatim-by-construction beats verbatim-by-discipline.**

**Provenance is cited, not linked.** A reference names the work, the exact locator and the
edition, and **every citation is followed before landing**. Rev 2 broke this rule in its own
text: it credited the integrity fix to `cd56035` when the fix was **`75f6a4f`** - and
`cd56035` is the commit that *institutionalised* citation-following. Corrected here, and
recorded because a citation rule whose author does not follow it is worse than none.

## 3. Trust model

| Threat | Actual defence |
|---|---|
| The artifact changed after extraction - encoding drift, merge mangling, an edit in passing | **The integrity hash.** Three such defects have already occurred |
| A determined conductor rewrites a verdict | **Publication, not cryptography.** Entire's checkpoint branch holds an independently-written copy. Verified: `entire checkpoint explain 1c47c1d` resolves to checkpoint `16234ffe6e1b`, matching the Provenance row in the landed round-1 verdict |
| An agent writes an untrue verdict | **Nothing mechanical.** Verdicts are public and the next reviewer reads them |
| The runner's transcript is forged | **Nothing.** Not an adversarial environment |

The hash now covers **every byte** of a landed artifact, header claims included, fixed in
**`75f6a4f`**. Round 2 re-ran the original injection from outside the repo: header-only and
body-only tampering both produce `MISMATCH`, exit 1.

## 4. The artifact contract

**The schema is the product; producers are adapters.**

### 4.1 Events, and content-addressed identity

Append-only, never mutated.

```
event_id = sha256(canonical_content)          # content-addressed, universal
```

Rev 2 used `identity = (dispatch_id, kind, seq)` and it failed twice. `seq` had **no
assignment authority** - a `SubagentStop` hook fires in the moment and cannot know it is the
Nth notification, while a sweep computes `seq` from transcript position, so the two
producers disagree in exactly the resumed-agent case `seq` existed for. And `intent` and
`ruling` are **not dispatches**, so they had no `dispatch_id` and therefore no address -
which meant the only events carrying `supersedes` were the only events identity could not
name. The pointer existed; the pointee did not.

Content addressing fixes both: every event has an address, computed identically by every
producer, with no authority to assign.

**Equality, stated explicitly** because rev 2's "a no-op when content matches" was
unimplementable. The canonical content covers **judgement and subject fields only**:
`kind`, `dispatch_id`, `session_id`, `subject`, `outcome`, `findings`, `abstract`,
`body_sha256`, `supersedes`. It **excludes** producer-stamped provenance: `at`, `clock`,
`producer`, `seq`. Rev 2's clock rule guaranteed a hook-landed and a sweep-landed copy of
one event would differ in `at` and `clock`, so under its equality rule the **healthy case
was a permanent loud conflict** - an instrument crying wolf by construction, which §4.3
deletes the counts cross-check for on identical grounds.

Two events with the same `event_id` are the same observation: the second landing is a
no-op, and the provenance of both is recorded in one file's `observed_by` list. Different
`event_id` for the same dispatch and kind means the observations genuinely disagree, which
is a real finding and surfaces as one.

### 4.2 Event kinds

| Kind | Emitted when | Terminal? |
|---|---|---|
| `dispatched` | a subagent is launched | no |
| `returned` | it completes (`delivered` / `honest-stop` / `error`) | **yes** |
| `presumed-lost` | liveness budget exceeded with no terminal event (§5) | **no** |
| `intent` | the conductor declares what no dispatch can know | n/a |
| `ruling` | the conductor decides an appeal or override | n/a |

`verdict` is not a kind: `kind` is set at `dispatched` from the brief, `outcome` at
completion. A reviewer returning garbage folds as a review dispatch with `outcome: error` -
a verdict-shaped hole the board renders as *"reviewer failed to produce a verdict"* - in
one record that cannot disagree with itself.

**`presumed-lost` is deliberately NON-TERMINAL**, which is the structural fix round 2
identified and it dissolves three problems at once. Rev 2 marked its equivalent terminal,
so a reaped dispatch that later returned produced **two terminal events with no fold rule** -
and since supersession was granted only to `intent` and `ruling`, nothing could reconcile
them. Non-terminal means any later `returned` simply supersedes the presumption. No
two-terminal rule, no supersession grant for terminal kinds, no ordering tie-break.

**Supersession** is available to every kind. `supersedes: <event_id> | null`. Current state
for a subject = the latest un-superseded event. "Latest" is by **causal order** - an event
superseding another is by definition after it - never by comparing producers' clocks, which
§4.1's own clock rule warns is a fold that lies quietly. Two events superseding the same
target is a genuine disagreement and surfaces as one rather than being tie-broken silently
(Law 6: show the disagreement).

A `supersedes` naming an unknown `event_id` lands and is **rendered as a dangling
reference** - never ignored (Law 4: nothing silently lost), never fatal (Law 1: a whole
board must not blank over one bad pointer).

### 4.3 Who supplies each field

| Producer-derived (observable) | Agent-supplied (judgement) |
|---|---|
| `event_id`, `dispatch_id`, `session_id`, `at`, `clock`, `producer`, `model`, `base`, `gate`, `target`, `role`, `context_peak_tokens`, `cost` | `outcome`, `findings`, `abstract` |

Rev 1 asked the agent for facts the producer already held. **The counts cross-check is
deleted**: there is no defined finding grammar, "Major" appears in headings and prose, and
the escape clause made the check unfalsifiable. Counts are the reviewer's assertion, hashed
with the body that justifies them, and rendered as an assertion.

### 4.4 The envelope - now with measured constraints

The agent ends its report with a fenced block, info string `starcar-artifact`, parsed as
the **last** such block.

Round 2 was the live test, and the result changes the format:

- **The fence survives the platform's safety filter; the sentinel did not.** Rev 1 used
  `<<<STARCAR-ARTIFACT-V1`, which the filter flagged as instruction-shaped and neutralised
  outright (`docs/reviews/2026-07-22-harness-design-round1-REJECT.md:48`, and that verdict's
  own envelope landed HTML-escaped at `:320-329`).
- **But angle brackets INSIDE the payload are still escaped.** Round 2's envelope emitted
  `abstract: >` and landed as `abstract: &gt;`
  (`docs/reviews/2026-07-22-harness-design-round2-REJECT.md`). **Therefore the envelope
  grammar forbids `<` and `>` entirely**: no YAML block scalars, no `<placeholder>` syntax.
  Values are plain scalars or quoted strings on one line.
- Selective mangling is more dangerous than total neutralisation because it looks like it
  worked, so **the producer validates the landed bytes**, not just the extracted text, and
  an escaped envelope is a loud failure.

**Absent and malformed are different faults** and must not be reported as each other
(the parked yard design already ruled this shape at `:496-498`):

| Fault | Meaning | Rendered as |
|---|---|---|
| No envelope | the agent did not comply - a brief or agent-definition failure | `outcome: error`, `envelope: absent` |
| Envelope present, unparseable | the format or the channel broke - a producer failure | `outcome: error`, `envelope: malformed` |

Both land **with the body intact**. Neither is a guess.

### 4.5 Cost - what the number actually is

Rev 2 adjudicated correctly that the runner reports per-dispatch figures, and round 2 could
not overturn that. But it mis-described what one of them **means**, and round 2 measured it:

`subagent_tokens` tracks the sum of `cache_creation_input_tokens` - equivalently the final
turn's input context - to within 0.3%. It **excludes 100% of output tokens and 100% of
cache reads**. Independently re-verified before acceptance:

| dispatch | reported | Σ cache-creation | Σ all counters | under-report |
|---|---|---|---|---|
| `a9fa2727...` | 71,942 | 71,866 | 365,867 | **5.1x** |
| `a56d4b46...` | 99,390 | 99,283 | 1,022,798 | 10.3x |
| `a1bccdf2...` | 115,565 | 115,222 | 2,299,330 | 19.9x |

It is *"how big did this conversation get"*, not *"what did this burn"*, and the error grows
with dispatch length so it is not even a stable scale factor. Rev 2 called it an
approximation and summed it into a fuel gauge - **the exact Law 1 defect §4.5 claimed to be
avoiding, on the surface `README.md:44` calls the usage meter the operation is budgeted
against.**

Therefore, two distinct fields, neither pretending to be the other:

- **`context_peak_tokens`** - always available, named for what it measures, rendered as
  *context*, never as spend.
- **`cost`** - the four counters separated (`input`, `output`, `cache_read`,
  `cache_creation`), derived by producers that can read a per-turn usage record.
  **Producer-optional** (Law 7: a shop whose runner reports differently must still emit a
  conforming artifact).

**The fuel lane renders spend ONLY from `cost`.** Where `cost` is absent the lane is
`dark` - the parked design's own vocabulary for declared-but-unequipped - and never
back-fills from `context_peak_tokens`. A lane honestly dark beats a lane confidently wrong.

## 5. Liveness

A `dispatched` with no terminal event is otherwise permanent: the board shows a car rolling
that died days ago, the inverse of `constitution.md:13-17`'s worst defect.

- Every `dispatched` carries **`expect_by`**, set **per dispatch** by the conductor, which
  already writes a size class into every proposal under cost discipline. A shop-level
  default applies when omitted, so an absent budget is never an infinite one. Round 2's
  measured runs were 680s / 744s / 897s; a car implementing a plan will run far longer than
  a reviewer, so a single global budget is wrong by construction.
- **The transition is a gradient, not a cliff.** Past `expect_by` the board renders
  `rolling (42m, expected <= 30m)` before it renders `unknown`, so a mis-set budget degrades
  visibly instead of flipping a healthy car to unaccounted-for in one render.
- A `presumed-lost` event carries **its own basis**: `reason`, the budget, the elapsed time,
  and the `clock`/`producer` that judged it. An event recording "lost" without recording
  *what was observed and by whom* asserts a fact nobody holds; with the basis it records a
  true one - *"at T, producer P observed no terminal event and the budget was B"* - which
  stays true whether or not the agent was alive.
- Non-terminal (§4.2), so a later return supersedes it. `constitution.md:17`'s *"unknown
  renders AS unknown"* describes a state the board can leave, not a grave.

## 6. Detecting what is missing - two tiers, honestly scoped

A hash verifies what exists; **an absence is invisible to it**. Rev 2 assigned
reconciliation to CI and claimed closure. Round 2 found that CI cannot read the second
source, and that the store-internal half only sees what was pushed.

**Tier 1 - universal, mechanical, CI-runnable.** Every `dispatched` in the store has a
terminal event or a `presumed-lost`. Any shop emitting conforming artifacts gets this. It is
the ledger property: `dispatched` **is** the ledger entry.

**Tier 2 - producer-dependent.** A second source enumerates dispatches the store never heard
of, catching artifacts that were never written at all. Requires a runner that keeps an
enumerable record. Two producers can supply it here: the local session transcript (complete,
local-only, invisible to CI) and the **Entire checkpoint branch, which IS pushed** and does
contain the transcripts - at the cost of a stated lag and a Law 7 coupling to Entire.

**Law 5 requirement: the board renders which tier is in force**, exactly as it renders
adapter health. A shop running tier 1 only must see that on the surface, not infer it.
Without this split, §4's *"the schema is the product"* claims a closure a stranger's shop
cannot obtain.

**Stated gap, not papered over:** a dispatch that starts and dies before anything is
committed is invisible to CI, because the evidence never reached it. Tier 1 run locally
(pre-commit, or on demand) sees it; CI does not. The design does not claim otherwise.

## 7. Producers - the hook lifecycle

Rev 1's central claim was wrong: `PostToolUse:Task` **fires at launch**, `status:
async_launched`, no body - proven from the transcript, and implied by `Land-Verdict.ps1`,
which scrapes the transcript precisely because there is no result to read.

| Event | Hook | Notes |
|---|---|---|
| `dispatched` | `PostToolUse:Task` | Fires at launch. Launch is when a dispatch begins, so this is the right trigger, not a workaround |
| `returned` | `SubagentStop` | *"Execute when subagent considers stopping."* Payload is `reason`, **not the body**, so extraction stays; only the trigger changes |
| `presumed-lost` | reconciliation (§6) | not hook-driven |

**BLOCKING TESTS - the spec does not start until both are run.** Designing on an unverified
mechanism is the error rev 1 made.

1. **Does `SubagentStop` fire for asynchronously-dispatched subagents in the parent's hook
   context?** Documented event, unverified behaviour. **If it does not fire**, there is no
   hook for `returned` at all: the producer collapses to sweep-only transcript scraping, car
   2's scope changes materially, and §11's approved dispatch figure is wrong. That is the
   fallback branch, named so a negative result is a known path rather than a re-design.
2. **Envelope round-trip.** Emit one fenced envelope, land it, read the landed bytes.
   *Partially answered already by round 2* (§4.4): the fence survives, angle brackets do
   not. The remaining test is whether the `<`/`>`-free grammar lands byte-clean.

**Law 7 obligations:** no hardcoded project path (`Land-Verdict.ps1:56-65` currently
violates this and must derive from the git root); the vendor transcript format confined to
the producer and documented as a known coupling; `cost`, `context_peak_tokens` and
`producer` marked **optional**.

## 8. Publication and normalisation

The store is public by construction and committed automatically - a real decision, named as
one. **Owner ruling:** *"There is a difference between the full monty and being silly.
Redacting full paths isn't hiding anything."*

Operator-environment paths are normalised to `<repo>` and `~` **before hashing**,
mechanically, narrowly, with the rule declared in each artifact and the un-normalised
original preserved on the checkpoint branch. Normalisation is not curation: findings,
verdicts and counts are untouched, and Law 7 wants a path a stranger can use. Implemented in
`3e247dc`; `CLAUDE.md`'s NORTH STAR carries the principle and its scar.

## 9. The store

- `docs/artifacts/YYYY-MM-DD/HHMMSS-<dispatch>-<kind>.md`. Per-artifact files, kept: a
  single append-only file recreates the unnavigable-JSONL problem with better manners, while
  per-file gives conflict-free git merges, per-artifact `git log`, and a stable URL per
  verdict, which is what a public showcase needs.
- A **generated** `INDEX.md`; hand-maintaining an index of a growing store is the mirror
  class and would rot within one train.
- Regenerated on landing and **checked in CI** - a store whose index is stale is a lying
  instrument.
- `docs/reviews/` retires into the store, history preserved, **in the same commit** that
  creates the index, so `README.md:20-21` is never momentarily false.

## 10. Derivation - intent versus facts

**The conductor declares INTENT; the process emits FACTS.** No field has two writers, so
there is no precedence rule to get wrong. Round 1 and round 2 both called this the best idea
in the document.

| Fact | Source |
|---|---|
| A car is rolling | `dispatched`, no terminal event, **within `expect_by`** |
| A car is overdue | `dispatched`, past `expect_by`, no terminal event - rendered with elapsed and budget |
| A car is unaccounted for | `presumed-lost` un-superseded |
| A car is at inspection | its reviewer's `dispatched`, same rules |
| REJECT rounds | count of terminal events with `outcome: REJECT` |
| Context burned | sum of `context_peak_tokens` - **rendered as context, never as spend** |
| Spend | sum of `cost`; **lane is `dark` where `cost` is absent** (§4.5) |
| Which reconciliation tier is in force | §6, rendered (Law 5) |
| A car is coupled at SHA | git |
| Inbound freight | the issue tracker |
| Train composition | conductor `intent` |
| A train is held / released | conductor `intent`, latest un-superseded |

## 11. Cars and cost

| Car | Scope |
|---|---|
| 1 | Schema, content-addressed identity, equality rule, validator, store layout, generated index, **verification** |
| 2 | Producer: hooks, extraction, envelope parsing and landed-byte validation, sweep, tier-1 and tier-2 reconciliation; **`CLAUDE.md` envelope rule**, `docs/templates/car-brief.md`, `.claude/agents/car.md`, `.claude/skills/goodnight/SKILL.md` |
| 3 | CI wiring; migrate `docs/reviews/` into the store; **`docs/setup.md` rows and `README.md:46-47`**; the parked yard design's `:559-561` |

Documentation ownership is now stated **once**, in this table. Rev 2 split it between a car
table and a disposition table that disagreed, so a car briefed from one wrote no
documentation - the same defect round 1 raised as Minor-5, fixed as an instance and not as a
shape.

Three cars, three reviewers, plus design, spec and plan with reviews: **roughly 11
dispatches**, Opus throughout, size class **medium**. **Approved by the owner on
2026-07-22, before dispatch** (`66f3c78`). REJECT rounds add to this and are expected
outcomes, not overruns. If blocking test 1 (§7) fails, this figure is void and must be
re-approved.

**The spec carries a worked consumer example**: a synthetic train's artifacts folded into
the yard board's vocabulary, showing every row of §10 derived end to end. That gives the
imagined consumer a concrete voice at spec rung rather than waiting for rev 4, performs the
sentence check once by construction, and doubles as Law 7's mandated in-repo synthetic demo
data. The ladder is not inverted; rev 4 of the yard design remains this schema's first real
review, with the worst surprises already found.

## 12. Out of scope

Signing beyond the integrity hash. Retention and pruning. Producers for other runners,
though the format must not prevent them. Rendering - the yard design's job. Migrating
dispatches from before this train, **except** the four landed verdicts, which car 3
migrates.

## 13. What changed from rev 2

| Round 2 finding | Disposition |
|---|---|
| MAJOR-1 `subagent_tokens` is a context high-water mark, not a conflated total; summing it into a fuel gauge under-reports 5.1-19.9x | §4.5 - split into `context_peak_tokens` (context, always) and optional `cost` (four counters); the fuel lane renders spend only from `cost` and is `dark` otherwise |
| MAJOR-2 CI cannot read the second source; store-internal half sees only pushed events | §6 - two tiers, the board renders which is in force, the Entire checkpoint branch named as a CI-readable tier-2 producer, and the unpushed gap stated rather than papered over |
| MAJOR-3(a) `seq` has no assignment authority; equality rule makes the healthy case a permanent conflict | §4.1 - content-addressed `event_id`, and an explicit equality set excluding producer-stamped provenance |
| MAJOR-3(b) `intent`/`ruling` carry `supersedes` and are the only events identity cannot address | §4.1 - content addressing gives every event an address; supersession available to every kind |
| MAJOR-3(c) reaped-then-returned produces two terminal events with no rule | §4.2 - `presumed-lost` is **non-terminal**; a later return supersedes it |
| Minor-1 wrong commit credited for the integrity fix | §2, §3 - corrected to `75f6a4f`, with the irony recorded |
| Minor-2 car scope and disposition tables disagree | §11 - one table |
| Minor-3 `CLAUDE.md` unassigned | §11 - car 2 |
| Minor-4 parked design's `:559-561` unassigned | §11 - car 3 |
| Minor-5 parked status block also omits what rev 2 newly rewrites | Noted; corrected when that document returns as rev 4 |
| Minor-6 no fallback branch if `SubagentStop` fails | §7 - branch named, with its cost consequence |
| Minor-7 envelope test not gated like §7's twin | §4.4, §7 - now a blocking test, partially answered by round 2's live result |
| Note-4 absent vs malformed envelope collapsed | §4.4 - separate faults, separate renderings |
| Ruling Q1 budget per dispatch + default + gradient | §5 |
| Ruling Q2 non-terminal, carries basis, renamed | §4.2, §5 |
| Ruling Q3 two tiers, board renders which | §6 |
| Ruling Q4 gate the envelope test | §7; answered in part by round 2 |
| Ruling Q5 per-artifact grain kept | §9 |
| Ruling Q6 no inversion; spec carries a worked consumer example | §11 |

## 14. Open questions for the design reviewer

1. **Content addressing makes `event_id` depend on the canonical field set.** Adding a field
   in a later schema version changes every future id. Is that acceptable, or does the id
   need a version prefix - and does a version prefix reintroduce the drift it avoids?
2. **`observed_by` (§4.1) accumulates on a file that §4.1 also says is never mutated.**
   Those are in tension. Is a second observation an append to the file, a second file, or
   simply dropped once the first has landed?
3. **§6's tier-2 via the Entire checkpoint branch couples reconciliation completeness to a
   third-party tool.** Is that acceptable under Law 7, given tier 1 is universal - or does
   naming a specific vendor in the design leak the producer into the schema?
4. **The fuel lane goes `dark` when `cost` is absent (§4.5), but `context_peak_tokens` is
   always present.** Is showing context while hiding spend actually clearer than showing
   nothing, or does a populated context figure beside a dark spend lane invite exactly the
   misreading the split exists to prevent?
5. **§5's gradient needs a threshold** - at what multiple of `expect_by` does `rolling
   (overdue)` become `presumed-lost`? An unspecified number is a car inventing one.
6. **Every artifact is committed automatically by a hook (§7, §8).** Nothing in this design
   says what happens when that commit conflicts, or when a hook fires while the working tree
   is mid-rebase. Is artifact landing safe to make automatic at all, or does it need a queue?
