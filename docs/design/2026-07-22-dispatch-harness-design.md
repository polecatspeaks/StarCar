# Design: the dispatch harness

Status: **DRAFT rev 4 - awaiting adversarial design review (round 4)**
Issue: #7 (`area:adapters`)
Date: 2026-07-22
Ladder rung: design (rung 1 of: design → spec → plan → cars)
History: rev 1 REJECT (7 Major), rev 2 REJECT (3 Major), rev 3 REJECT (4 Major). Verdicts
landed verbatim in `docs/reviews/`. See §14.

> **Round 3 ruled on METHOD, and this revision obeys it.** *"The class here is not 'the fold
> is hard', it is that prose iteration on the fold has now failed three times."* So §4 is a
> **demonstration**, not an argument: literal canonical bytes, real computed ids, and the
> hook/sweep agreement shown rather than asserted. Every hash below was computed, not
> composed.
>
> **The cap, accepted:** if this revision does not close §4 by demonstration, the conductor
> escalates to the owner for a ruling rather than dispatching round 5. Appeals go upward,
> never around - including appeals about the gate's own convergence.

## 1. What this is

Every dispatch emits a **structured artifact**. The artifacts are the process's record of
itself and the yard board's data source.

## 2. The class, and the citation frame

A dispatch's output is ephemeral by default; the only thing between an artifact and
oblivion was the conductor remembering to copy it out - **vigilance**, the weakest tier.
Entire.io provides **durability**; it does not provide **addressability**. And the manual
fix was worse than the gap - the conductor began hand-transcribing a verdict about its own
design. **Verbatim-by-construction beats verbatim-by-discipline.**

**Provenance is cited, not linked**, and every citation is followed before landing. The
integrity fix is `75f6a4f` (rev 2 miscited it as `cd56035`, which is the commit that
*institutionalised* citation-following).

## 3. Trust model

| Threat | Actual defence |
|---|---|
| The artifact changed after extraction | **The integrity hash.** Four such defects have occurred |
| A determined conductor rewrites a verdict | **Publication.** Entire's checkpoint branch holds an independently-written copy |
| An agent writes an untrue verdict | **Nothing mechanical.** Verdicts are public and the next reviewer reads them |
| The runner's transcript is forged | **Nothing.** Not an adversarial environment |

The hash covers **every byte** of a landed artifact, header included (`75f6a4f`). Round 2
and round 3 both re-ran the original injection from outside the repo: header-only and
body-only tampering each produce `MISMATCH`, exit 1.

## 4. Identity, by demonstration

### 4.1 Canonicalisation - normative, and previously absent

Round 3's finding was exact: rev 3 used the word *canonical* three times and never once
specified a procedure, so two conforming producers would compute different ids for one
event and the schema-is-the-product claim delivered nothing interoperable.

**The procedure, normative:**

1. Build a JSON object of the **canonical fields** (§4.3), and only those.
2. **Omit absent fields entirely.** Never emit `null`. (An `intent` has no `dispatch_id`;
   omitted-versus-null was an unspecified id-changing choice in rev 3.)
3. Serialise as UTF-8 JSON: **keys sorted by Unicode codepoint**, **no whitespace**
   (separators `,` and `:`), integers with no leading zeros and no exponent, strings with
   minimal JSON escaping, no BOM.
4. `event_id = sha256(those UTF-8 bytes)`, lowercase hex.

Canonicalisation is versioned by the `schema` field, which is itself canonical: an id is
computed under the version the artifact declares, and a verifier re-derives using that
version. No version prefix on the id - that would be a second copy of the schema version
inside the address, free to drift from the artifact's own declaration (Law 6).

### 4.2 The demonstration: two producers, one id

A `dispatched` event as the **hook** observes it at launch, canonicalised per §4.1:

```
{"base":"783e39e371c7e96a8d53ac17feadcdfea57b2608","dispatch_id":"a06da84aa8cc7d5b7","expect_by_ms":1800000,"gate":"design-review","kind":"dispatched","model":"opus","role":"reviewer","schema":"starcar-artifact/1","session_id":"64c15364-0933-4d6d-9b2e-d1ddbc918f9f","subject":"dispatch:64c15364-0933-4d6d-9b2e-d1ddbc918f9f:a06da84aa8cc7d5b7","target":"docs/design/2026-07-22-dispatch-harness-design.md"}
```

```
hook  event_id : 22a21b362b2fd84ae1330fee267ca7364c3ef9c6d1b1f842cdcc53fdc6b898f8
sweep event_id : 22a21b362b2fd84ae1330fee267ca7364c3ef9c6d1b1f842cdcc53fdc6b898f8
EQUAL          : true
```

The sweep, reconstructing the same event from the transcript hours later, stamps a
different `at`, a different `clock`, a different `producer` - and computes **the same id**,
because those fields describe the *observation*, not the *event* (§4.3).

Two further real ids from the same run, used in §4.5's worked fold:

```
returned      event_id : ac9bcea6123891359150df36c929adb5a05bef64d6e5af3a885045b502699e5b
presumed-lost event_id : 71ddc9fe7fbbc60fec498ece90b9e06f3a3e31fe39a458b8d42bd1fb7695faa3
```

### 4.3 ONE field enumeration

Rev 3 carried two tables - a canonical/excluded set and a "who supplies each field" table -
which disagreed on **seven** fields. Two hand-maintained mirrors of one schema, inside the
schema, which is this repo's signature scar class. There is now one table.

**The membership rule, stated so it can be applied to fields not yet invented:**
*the canonical content describes the EVENT; everything excluded describes the OBSERVATION
of it.*

| Field | Canonical? | Supplied by | Applies to |
|---|---|---|---|
| `schema` | **yes** | producer | all |
| `kind` | **yes** | producer | all |
| `subject` | **yes** | producer | all |
| `session_id` | **yes** | producer | all |
| `dispatch_id` | **yes** | producer | dispatch kinds |
| `role`, `gate`, `target`, `base`, `model` | **yes** | producer | `dispatched` |
| `expect_by_ms` | **yes** | producer (from the brief) | `dispatched` |
| `outcome` | **yes** | **agent** | `returned` |
| `findings` | **yes** | **agent** | `returned` |
| `abstract` | **yes** | **agent** | `returned` |
| `body_sha256` | **yes** | producer | `returned` |
| `reason`, `budget_ms`, `elapsed_ms` | **yes** | producer | `presumed-lost` |
| `supersedes` | **yes** | conductor | `intent`, `ruling` only (§4.4) |
| `at` | no | producer | all |
| `clock` | no | producer | all |
| `producer` | no | producer | all |
| `context_peak_tokens` | no | producer | `returned` |
| `cost` | no | producer, optional | `returned` |

`role`, `gate`, `target`, `base` and `model` are **inside** the canonical set. Rev 3 left
them out, which meant two observations disagreeing about the base SHA or the model computed
**the same id** and the second landing was silently discarded - a Law 4 loss on exactly the
fields the board renders. Both producers can observe all five identically, so they belong
to the event.

`context_peak_tokens` and `cost` are **outside**: they are measurements a producer takes,
and a producer that cannot measure them must still be able to compute a matching id.

**`subject`, defined for every kind** (undefined anywhere in rev 3, while load-bearing for
both identity and the fold):

| Kind | `subject` |
|---|---|
| `dispatched`, `returned`, `presumed-lost` | `dispatch:<session_id>:<dispatch_id>` |
| `intent` | the thing declared about - `train:<id>`, `lane:<id>` |
| `ruling` | the thing ruled on - `gate:<id>`, `appeal:<id>` |

**`session_id`** is always the session the **dispatch ran in**, never the session doing the
observing. A sweep run later over the checkpoint branch reconciles across sessions
(§7), and stamping its own session would false-conflict every reconciled event.

### 4.4 Supersession: precedence for facts, pointers for declarations

Rev 3 gave every kind a `supersedes` pointer inside the hash, and round 3 showed that
breaks both ways: a hook emitting `returned` **cannot know** a `presumed-lost` exists (the
same argument that killed `seq`), so nobody had authority to write the pointer - and if the
sweep wrote one, the hook-landed and sweep-landed copies of one return computed different
ids, making the healthy path a permanent false conflict.

**The split that dissolves it:**

**Dispatch-lifecycle events supersede by KIND PRECEDENCE, with no pointer at all.**

```
returned  >  presumed-lost  >  dispatched          (for one subject)
```

The hook writes what it observed and nothing else. Nobody needs authority over a pointer,
because there is no pointer. A `returned` arriving after a `presumed-lost` wins by kind, so
round 2's non-terminal fix survives with strictly less machinery.

**Conductor declarations (`intent`, `ruling`) keep an explicit `supersedes`, in the hash.**
These have exactly one producer - the conductor, who reads the store before writing - so
there is no hook/sweep divergence to create, and the pointer is genuinely needed because a
release must name what it releases (Law 2). Keeping it inside the canonical content
preserves a property round 3 identified and rev 3 did not know it had: **supersession
cycles are unconstructible**, because computing A's id would require B's and B's would
require A's. A structural impossibility, the Healing Loop's top guard tier, obtained free.
Claimed here explicitly so no car writes a cycle detector that can never fire.

**The disagreement condition is widened**, per round 3's Minor-7. Rev 3 surfaced only "two
events superseding the same target," which misses a chain plus a fork (A←B←C and separately
A←D leaves `{C, D}` both current). The rule is now: **more than one un-superseded event for
one subject is a disagreement, and the board shows it** rather than picking a winner
(Law 6).

A `supersedes` naming an unknown id lands and renders as a **dangling reference** - never
ignored (Law 4), never fatal to the board (Law 1).

### 4.5 The worked fold

Store contents for subject `dispatch:64c15364-...:a06da84aa8cc7d5b7`:

| # | Kind | `event_id` | Observed by |
|---|---|---|---|
| 1 | `dispatched` | `22a21b36…` | hook at launch |
| 2 | `dispatched` | `22a21b36…` | sweep, later - **same id, same event** |
| 3 | `presumed-lost` | `71ddc9fe…` | reconciliation, budget exceeded |
| 4 | `returned` | `ac9bcea6…` | hook at `SubagentStop` |

Fold: group by `subject`; 1 and 2 are one event by id; apply kind precedence; `returned`
wins. Board renders **delivered, REJECT, 4 Major**. No pointer was written by anyone, no
producer needed store access, and the duplicate collapsed by identity rather than by rule.

Had event 4 never arrived, `presumed-lost` would be current and the board would render
**unaccounted for**, with the basis from its own fields: budget 30m, elapsed 35m.

### 4.6 Two observations are two files

Rev 3 said events are *"append-only, never mutated"* and then appended to an `observed_by`
list inside a landed file. Round 3 fault-injected it: inserting one `observed_by:` line into
a landed verdict produces `MISMATCH`, exit 1. **Honest reconciliation presented to CI as the
tamper signature** - a guard firing on correct work, which this repo ranks below no guard.

**Each observation is its own file**, named for its producer, carrying the same `event_id`
in its content. The store is one-file-per-**observation**; the *event* is the group. Every
landed file's hash stays valid forever, reconciliation is a `group-by event_id` rather than
a mutation, and two observations become evidence rather than a conflict.

This costs one thing and §10 pays it explicitly: a **stable URL per event** is delivered by
the generated index keyed on `event_id`, not by a filename.

## 5. The envelope

A fenced block, info string `starcar-artifact`, parsed as the **last** such block.
**Angle brackets are forbidden anywhere inside it**, and both halves of that rule are
measured, not guessed:

- Rev 1's `<<<SENTINEL>>>` was flagged instruction-shaped and **neutralised outright**.
- Rev 3's fenced block survived, but `abstract: >` landed as `abstract: &gt;` - **selective
  mangling, which is more dangerous than total neutralisation because it looks like it
  worked.**
- Round 3's angle-bracket-free envelope landed with **zero escaped entities inside the
  block**. Verified on the landed bytes.

Therefore the producer **validates the landed bytes**, not the extracted text.

**Two consequences round 3 measured, both recorded here:** with block scalars banned the
`abstract` must be one physical line (~1,400 characters in round 3, which diffs unreadably -
a real cost, accepted, and stated so no car assumes folding is allowed); and this document's
own example string `rolling (42m, expected <= 30m)` **cannot be quoted inside an envelope**.
Grammar and worked example were mutually incompatible in rev 3; the example is now written
`rolling (42m, over a 30m budget)`.

**Absent and malformed are different faults:**

| Fault | Meaning | Rendered |
|---|---|---|
| No envelope | the agent did not comply - a brief failure | `outcome: error`, `envelope: absent` |
| Present, unparseable | the format or channel broke - a producer failure | `outcome: error`, `envelope: malformed` |

Both land **with the body intact**.

## 6. Cost - corrected arithmetic and a corrected process

`subagent_tokens` tracks the sum of `cache_creation_input_tokens` to within 0.5%, verified
on **four** dispatches. It excludes 100% of output tokens and 100% of cache reads.

| dispatch | reported | Σ all counters | under-report |
|---|---|---|---|
| `a9fa2727…` | 71,942 | **397,085** | **5.52x** |
| `a56d4b46…` | 99,390 | 1,022,798 | 10.3x |
| `a1bccdf2…` | 115,565 | 2,299,330 | 19.9x |

**Normative: deduplicate streaming usage records by taking the LAST record per
`message.id`.** Rev 3's table mixed two methods; row 1 used *first*-per-id, and the first
partial of each turn carries `output_tokens: 1-4`, so it booked **23 output tokens for a
dispatch that emitted 31,241** - a 99.93% loss of the exact quantity this section is about,
in the only worked arithmetic a car would have copied.

**And a process correction that matters more than the number.** Round 2 measured 5.5x; rev 3
"independently verified", got 5.1x, and shipped its own figure **without stating that it
disagreed with the verdict it was answering**. `CLAUDE.md`: *an implementer never silently
overrides its own reviewer.* An appeal with evidence would have been legitimate and would
also have been caught, because the evidence was wrong. Logged in `docs/friction-log.md`.

Two fields, neither pretending to be the other:

- **`context_peak_tokens`** - always available, rendered as **context**, never as spend.
- **`cost`** - four counters separated (`input`, `output`, `cache_read`, `cache_creation`),
  producer-optional (Law 7).

**The reference producer DOES emit `cost`** - car 2's scope, stated because round 3 found
rev 3 left it unassigned and the flagship board would otherwise render a dark fuel lane with
the data on the same disk. The four counters are readable from the subagent transcript.

The fuel lane renders spend **only** from `cost`; where absent it is dark. The two figures
never share a scale, an axis, or a summary row.

## 7. Reconciliation - two tiers

A hash verifies what exists; **an absence is invisible to it.**

**Tier 1 - universal.** Every `dispatched` has a superseding event or is rendered
unaccounted-for. Obtainable from the artifacts alone, so any conforming shop gets it. CI runs it.

**Tier 2 - producer-dependent.** *Any enumerable second source of dispatches*, catching
artifacts never written at all. This shop's implementation is the **Entire checkpoint
branch**, which is pushed and therefore CI-readable - verified: `origin/entire/checkpoints/v1`
resolves, and its transcripts contain `async_launched` records and dispatch ids.

Tier 2 is defined by the *capability*, not by the vendor, so a stranger does not read Entire
into the tier's definition.

**Recorded limits:** the checkpoint branch carries **no subagent transcripts**, so tier 2
can enumerate dispatches but can never supply `cost`; and a dispatch that dies before
anything is committed is invisible to CI, though tier 1 run locally sees it.

**Law 5: the board renders which tier is in force**, as it renders adapter health.

## 8. Producers

| Event | Hook |
|---|---|
| `dispatched` | `PostToolUse:Task` - fires at launch, which is when a dispatch begins |
| `returned` | `SubagentStop` - payload is `reason`, not the body, so extraction stays |
| `presumed-lost` | reconciliation (§7) |

**BLOCKING TESTS - the spec does not start until both are run.**

1. **Does `SubagentStop` fire for async subagents in the parent's hook context?** Documented
   event, unverified behaviour; no such hook exists in `.claude/settings.json` today.
   **Fallback:** the producer collapses to sweep-only transcript scraping, car 2's scope
   changes materially, and §12's approved dispatch figure is **void and must be
   re-approved**.
2. **Envelope round-trip under the angle-bracket-free grammar.** *Largely answered by round
   3* - zero escapes on landed bytes. **Fallback if a later grammar change reopens it:** the
   envelope becomes producer-derived-only, the agent supplies `outcome` in prose, and
   `findings`/`abstract` are dropped from the schema. Round 3's Minor-1 correctly noted rev 3
   gave a fallback to one twin and not the other.

**Automatic commits are safe under three rules** (round 3's Q6 ruling, adopted):

1. The producer commits **only enumerated artifact paths** - never `git commit -a`, never
   the operator's index.
2. If `.git/rebase-merge`, `.git/rebase-apply`, `MERGE_HEAD` or `CHERRY_PICK_HEAD` exists,
   it **does not commit**: it writes the artifact, defers, and **records the deferral as an
   event**, so the deferral is loud.
3. **A producer hook never exits 0 on failure.** Stated explicitly because the live house
   style in `.claude/settings.json` does exactly that six times over, and a producer copying
   it would manufacture the never-written-artifact case §7 exists to close.

§9's "committed automatically" and this section now agree; rev 3 asserted the decision in one
place and asked whether to make it in another.

**Law 7:** no hardcoded project path (`Land-Verdict.ps1:59` currently violates this);
vendor transcript format confined to the producer; `cost`, `context_peak_tokens` and
`producer` optional.

## 9. Publication and normalisation

Operator paths are normalised to `<repo>` and `~` **before hashing**, mechanically, with the
rule declared in each artifact and the original preserved on the checkpoint branch.
Normalisation is not curation. Implemented in `3e247dc`.

## 10. The store

- One file per **observation**: `docs/artifacts/YYYY-MM-DD/HHMMSS-<dispatch>-<kind>-<producer>.md`.
- A **generated** `INDEX.md`, keyed on `event_id`, which is what delivers a **stable URL per
  event**. Rev 3 argued per-file grain partly on stable-URL grounds; §4.6 moves that job to
  the index.
- Index regenerated on landing and **checked in CI**.
- **`Verify-Verdict` is extended to cover `docs/artifacts/`.** It currently defaults to
  `docs/reviews` (`Verify-Verdict.ps1:24`), so without this the new store would carry no
  integrity check at all and car 3's migration would move four hash-verified files into an
  unverified store. Round 3 found both branches of that fork unassigned.
- `docs/reviews/` retires into the store, history preserved, **in the same commit** that
  creates the index.

## 11. Derivation

**The conductor declares INTENT; the process emits FACTS.** Unchanged and unattacked across
three rounds.

| Fact | Source |
|---|---|
| A car is rolling | `dispatched` current, within `expect_by_ms` |
| A car is overdue | `dispatched` current, past budget - rendered `rolling (42m, over a 30m budget)` |
| A car is unaccounted for | `presumed-lost` current |
| A car finished | `returned` current |
| REJECT rounds | count of `returned` with `outcome: REJECT` |
| Context burned | sum of `context_peak_tokens` - **context, never spend** |
| Spend | sum of `cost`; lane dark where absent |
| Which reconciliation tier is in force | §7, rendered |
| Coupled at SHA | git |
| Inbound freight | the issue tracker |
| Train composition, holds | conductor `intent`, latest un-superseded |

## 12. Cars and cost

| Car | Scope |
|---|---|
| 1 | Schema, canonicalisation, identity, one field table, validator, store layout, generated index, **`Verify-Verdict` extension to `docs/artifacts/`** |
| 2 | Producer: hooks, extraction, envelope parsing and landed-byte validation, **`cost` derivation**, sweep, tier-1 and tier-2 reconciliation, the three commit-safety rules; **`CLAUDE.md` envelope rule**, `docs/templates/car-brief.md`, `.claude/agents/car.md`, `.claude/skills/goodnight/SKILL.md`; **de-hardcode `Land-Verdict.ps1:59`**; **both script headers** (they call themselves "the harness"; #7 demotes them to "the Claude Code producer") |
| 3 | CI wiring; migrate `docs/reviews/`; `docs/setup.md` (including its stale CI row, already false at this base); `README.md:46-47`; the parked yard design's `:559-561`; **`docs/friction-log.md`** |

Documentation and code ownership is stated **once**, here.

**~11 dispatches**, Opus, size class medium. Approved by the owner 2026-07-22 before
dispatch (`66f3c78`), with REJECT rounds explicitly inside the approved envelope. **Void and
re-approved if blocking test 1 fails.** Four review dispatches spent.

The spec carries a **worked consumer example**: a synthetic train's artifacts folded into
the yard board's vocabulary, showing every row of §11 derived end to end.

## 13. Out of scope

Signing beyond the integrity hash. Retention and pruning. Producers for other runners.
Rendering. Migrating pre-train dispatches, except the five landed verdicts (car 3).
The liveness gradient's exact multiple is a **shop-level configurable with a default** -
the constant is spec-rung, the shape is here (round 3's Q5 ruling).

## 14. What changed from rev 3

| Round 3 finding | Disposition |
|---|---|
| MAJOR-1 two dedup methods; row 1 wrong by 31,218 tokens; reviewer silently overridden | §6 - corrected to 397,085 / 5.52x, last-per-id declared normative, the process violation recorded here and in the friction log |
| MAJOR-2(a) no canonicalisation | §4.1 - normative four-step procedure |
| MAJOR-2(b) `subject` undefined | §4.3 - defined for all five kinds |
| MAJOR-2(c) two field tables disagreeing on seven fields | §4.3 - one table, plus a membership rule that applies to future fields |
| MAJOR-2(d) same id despite disagreeing on `base`/`model`/`gate` | §4.3 - all five moved **into** the canonical set |
| MAJOR-3 `supersedes` in the hash; no authority to write the pointer | §4.4 - kind precedence for dispatch facts (no pointer at all); explicit pointer only for conductor declarations, single-producer, cycle-impossibility claimed |
| MAJOR-4 `observed_by` mutates a hashed file; CI reds on honest work | §4.6 - one file per observation; §10 - index delivers the stable URL; `Verify-Verdict` extended to the new store |
| Minor-1 no fallback for blocking test 2 | §8 |
| Minor-2 friction log unassigned | §12 - car 3 |
| Minor-3 script ownership unassigned | §12 - car 2 |
| Minor-4 §8 vs Q6 contradiction; hooks exit 0 on failure | §8 - three commit rules, including never exit 0 on failure |
| Minor-5 `dark` borrowed without its register | §13 - rendering out of scope; flagged for yard rev 4 |
| Minor-6 `session_id` assignment rule | §4.3 |
| Minor-7 disagreement condition too narrow | §4.4 - widened to "more than one un-superseded event per subject" |
| Note-1 cycles unconstructible | §4.4 - claimed |
| Note-2 `docs/setup.md` already stale | §12 - car 3 |
| Q1 no version prefix; version the canonicalisation | §4.1 |
| Q2 second file | §4.6 |
| Q3 tier 2 by capability, not vendor; no cost from tier 2 | §7 |
| Q4 reference producer emits `cost` | §6, §12 |
| Q5 threshold is spec-rung with a design sentence | §13 |
| Q6 automatic commits safe under three rules | §8 |

## 15. Open questions for the design reviewer

1. **Kind precedence (§4.4) assumes the lattice is total.** `returned > presumed-lost >
   dispatched` works today. Does a future kind break it, and should the design forbid adding
   kinds without extending the ordering?
2. **§4.6 makes the store one-file-per-observation, so a two-producer event yields two files
   with identical content but different names.** Is that redundancy honest evidence, or
   noise a reader must learn to ignore?
3. **§4.3 puts `outcome`, `findings` and `abstract` in the canonical set.** An agent
   re-dispatched on the same base that returns a byte-identical verdict would collide with
   its earlier run - `dispatch_id` prevents it, but is relying on the runner's id uniqueness
   across sessions sound?
4. **§6 says the reference producer emits `cost`**, derived by summing per-turn records.
   That derivation is producer logic doing arithmetic on a vendor's internal format. Is that
   a Law 7 coupling worth the honest fuel gauge, or should spend stay dark until the runner
   reports it directly?
