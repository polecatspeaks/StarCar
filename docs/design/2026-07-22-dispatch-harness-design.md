# Design: the dispatch harness

Status: **DRAFT rev 5 - awaiting adversarial design review (round 5)**
Issue: #7 (`area:adapters`)
Date: 2026-07-22
Written through `docs/templates/design-doc.md` - the first document to use it.
History: revs 1-4 REJECT (7, 3, 4, 5 Majors), escalated to the owner. See §11.

> **This document is roughly a third the size of rev 4, and that is the result, not a
> summary.** §0 amputated the protocol half into executable work; §2 killed a premise that
> was worth eight of twelve findings. Both happened before a line of mechanism was written.

## §0 - Instrument check

**Answer: BOTH, and the half that kept failing is format.**

| Half | Kind | Where it goes |
|---|---|---|
| Artifact schema; envelope grammar; the fold (events → board state) | **Format / algorithm** | **Not here.** Schema file + conformance vectors + red-first tests. Car 1's executable deliverable, reviewed as code. |
| What gets recorded and why; who writes; how absence is detected; publication; trust; liveness semantics; what the board may claim | **Behavioural** | This document. |

Revs 1-4 wrote the format half in prose for four rounds. Majors ran 7 → 3 → **4 → 5**,
climbing and clustered, because a prose instrument cannot resolve at a protocol's scale -
it finds different defects forever and each round feels like progress. The Healing Loop had
already ruled it: *"validated facts must land as tests or gates, never only prose."*

**Nothing in this document specifies a byte, a hash input, a field order, or a comparison
rule.** Where it needs one it names the executable artifact that owns it.

## §1 - Constraints, before the mechanism

| Source | What it FORBIDS here | How this design satisfies it |
|---|---|---|
| Law 1, `constitution.md:11-17` | Rendering what cannot be backed. *"Unknown states render AS unknown, honestly."* | §5's liveness has an explicit unaccounted-for state; §6 has a row for every absence |
| Law 2, `:19-23` | *"never resists an override"* | Conductor `intent` is a first-class record and can be withdrawn (§5.4) |
| Law 3, `:25-30` | *"Decoration that does not inform is cut"* | Only two rendered states per dispatch, plus a basis on demand (§5.3) |
| Law 4, `:32-36` | Anything the adapters can see being *"silently dropped"*; a missing lane reading as no trains | §5.5's detector reports gaps loudly; unparseable artifacts land with body intact |
| Law 5, `:38-43` | Degrading silently; freshness invisible | §5.5 renders which detection tier is in force; §5.3's lost-record carries its own basis |
| Law 6, `:45-50` | *"a second copy of anything that can drift"*; the view computing its own state | **§2's one-writer premise exists to satisfy this** - two writers ARE a second copy |
| Law 7, `:52-56` | *"no hardcoded board schemas or label taxonomies"*; undeployable by a stranger | Kinds and outcomes are data (§5.2); the reference producer is one adapter among possible others |
| Law 8, `:58-62` | Incidents not feeding the loop | §11 and `docs/friction-log.md` carry all four rounds |
| Healing Loop, `the-healing-loop.md:60-61` | *"validated facts must land as tests or gates, never only prose"* | §0. The format half is executable or it does not exist |
| `gating-matrix.md:23` | Suppressing a truth surface - staleness *"never (truth surface), DELIBERATE, no override"* | No suppression anywhere; a dark lane is honest absence, not a muted alarm |
| Round 2 verdict | A number labelled an approximation that under-reads by 5-20x | §5.6 - `context_peak_tokens` and `cost` are separate and differently named |
| Round 4 verdict | A demonstration that cannot fail | §0 - there is nothing here to demonstrate; the tests are the demonstration |

## §2 - Premises

**P1. ONE writer, ONE read-only detector.**
The hook writes artifacts. Reconciliation *detects* gaps and **never writes**. A human
decides whether to backfill, deliberately, as the single writer.

*If false:* two producers must agree on identity, canonicalisation, equality, ordering,
supersession authority, storage grain and aggregation - roughly **eight of the twelve
Majors** from rounds 2-4. That premise entered rev 1 unstated, to answer *"what if a hook
fails"*, and survived four adversarial rounds unexamined because **a reviewer rejects what
is on the page, not the assumption that put it there.** The requirement was *detect missing
artifacts*; **a detector does not need to be a writer.**

**P2. A dispatch is the unit of record.** Not a turn, not a train. *If false:* the schema's
grain is wrong and the board's derivation changes shape.

**P3. Artifacts live in git, not a database.** They are text, they want history, diffing and
public review, and the showcase requires them addressable. *If false:* the store gains a
lifecycle, backups and a query layer, none of which exist here.

**P4. The runner fires a hook when a subagent stops.** **UNVERIFIED - blocking test in §7.**
*If false:* there is no write trigger, the producer collapses to human-invoked landing, and
§9's cost line is void and must be re-approved. Named as a branch, not discovered later.

**P5. The board reads artifacts; the conductor declares only what no dispatch can know.**
*If false:* we are back to a hand-maintained state file, which is what #7 exists to remove.

## §3 - The problem

A dispatch's output is ephemeral. The only thing between an artifact and oblivion was the
conductor remembering to copy it out - **vigilance**, the weakest tier. Entire.io gives
durability but not addressability: a verdict buried in a multi-megabyte JSONL is safe and
unusable, while `README.md:20-21` promises verdicts committed in-repo as they happen.

Owner's framing: *"every dispatch emits a structured artifact, and the board reads them."*

## §4 - Decisions

| # | Decision | Reason | Driven by |
|---|---|---|---|
| D1 | One writer, one read-only detector | Removes the second copy that must be reconciled | **P1**, Law 6 |
| D2 | The format half is schema + conformance tests, not prose | The precision IS the artifact | **§0**, Healing Loop |
| D3 | Append-only records; nothing is ever mutated | History is the product; a mutable record invites tidying the north star forbids | Law 8 |
| D4 | The conductor declares INTENT; the process emits FACTS | No field has two writers, so no precedence rule can be got wrong | Law 6 |
| D5 | Liveness is a budget plus an explicit unaccounted-for state | A dead dispatch must not read as running | Law 1 |
| D6 | Detection is tiered and the tier is rendered | A stranger's shop gets tier 1; only ours gets tier 2 | Law 5, Law 7 |
| D7 | Spend and context are separate fields, separately named | One under-reads the other by 5-20x | Round 2 verdict, Law 1 |
| D8 | Operator paths normalised before hashing | Portability, not curation | Owner ruling, Law 7 |

## §5 - Mechanism (behavioural only)

### 5.1 What is recorded

One record per dispatch event: **dispatched**, **returned**, **presumed-lost**. Plus
conductor **intent** and **ruling**.

Field lists, types, ordering and identity are the **schema artifact's** job (§0). This
document constrains only *what must be recordable*: which dispatch, what it was for, what
came back, what it cost, and - for a presumption of loss - the basis on which it was
presumed.

### 5.2 Kinds and outcomes are data

Law 7 forbids hardcoded taxonomies. Kind and outcome vocabularies ship as data; an
unrecognised value renders loudly by name and is treated as **a discovery, not a bug** -
the board is its own detector for states nobody enumerated. Rev 1 hardcoded a taxonomy and
spent three rounds tuning it.

### 5.3 Liveness

A `dispatched` with no successor otherwise reads as *running* forever. So:

- Each dispatch carries a **budget**, set by the conductor who already assigns a size class.
  A shop default applies when omitted, so absent never means infinite.
- Past budget the board renders **overdue with elapsed and budget shown**, before it renders
  unaccounted-for. A gradient, not a cliff, so a mis-set budget degrades visibly.
- A **presumed-lost** record carries its own basis - what was observed, by whom, against
  which budget. It asserts a true fact about an observation rather than a guess about the
  world, and any later return supersedes it.

### 5.4 Intent and rulings

The conductor declares what no dispatch can know: train composition, and holds. A hold must
be **withdrawable** - Law 2 forbids a board that resists an override, and a mechanism that
can set a hold but never clear it resists one.

### 5.5 Detecting absence

A hash verifies what exists; **an absence is invisible to it.**

- **Tier 1, universal:** every `dispatched` has a successor or is rendered unaccounted-for.
  Obtainable from the artifacts alone, so any conforming shop gets it. CI runs it.
- **Tier 2, producer-dependent:** an enumerable second source finds dispatches the store
  never heard of. Ours is the Entire checkpoint branch, which is pushed and CI-readable.
  Defined by the *capability*, never by the vendor.
- **The detector never writes.** It raises a finding. A human backfills, deliberately (P1).
- **The board renders which tier is in force** (Law 5).
- **Stated gap:** a dispatch dying before anything is committed is invisible to CI; tier 1
  run locally sees it.

### 5.6 Cost

Two fields, differently named because they measure different things: **context** (always
available, rendered as context) and **spend** (four counters, producer-optional). The
reference producer emits spend. **The fuel lane renders spend only from spend**; absent it
is dark, and never back-filled from context. A lane honestly dark beats a lane confidently
wrong - the measured error is 5.5x to 19.9x and grows with dispatch length.

### 5.7 Publication

Artifacts are public by construction. Operator paths are normalised to `<repo>` and `~`
before hashing, mechanically, with the rule declared in each artifact and the original
preserved on the checkpoint branch. **Normalisation is not curation**: findings, verdicts
and counts are untouched.

## §6 - Failure modes

| Failure | Behaviour | Law |
|---|---|---|
| Hook does not fire | No artifact. **Tier 1 sees a dispatch with no successor; tier 2 sees a dispatch with no artifact at all.** Reported, never filled silently | 4 |
| Agent returns no envelope | Lands `error`, `envelope: absent` - **a brief failure** - body intact | 4 |
| Envelope present, unparseable | Lands `error`, `envelope: malformed` - **a producer failure**, a different fault | 3, 4 |
| Budget exceeded | Overdue with elapsed shown, then unaccounted-for with its basis | 1, 5 |
| Presumed-lost, then returns | The return supersedes; the presumption stays in history | 1, 8 |
| Vocabulary value unrecognised | Rendered loudly by name. **A discovery** | 1, 4 |
| Vocabulary or registry unreadable | One board-level fault, **not N per-lane faults** - one config error must not be reported as N discoveries | 1, 5 |
| Spend unavailable | Fuel lane dark. Never inferred from context | 1 |
| Artifact altered after landing | Integrity check fails; the checkpoint branch holds an independent copy | 1 |

## §7 - Out of scope, and the blocking test

Signing beyond an integrity hash. Retention and pruning. Producers for other runners, though
the format must not prevent them. Rendering - the yard design's job. Migrating pre-train
dispatches except the six landed verdicts.

**BLOCKING TEST (P4): does the runner fire a hook when an async subagent stops?** The event
is documented; its behaviour under async dispatch is unverified and no such hook exists in
`.claude/settings.json` today. **The spec does not start until this is run.** Negative
result is a named branch, not a re-design: landing becomes human-invoked, car 2's scope
shrinks, and §9 is void pending re-approval.

## §8 - Contracts touched

| Document | What changes | Owner |
|---|---|---|
| `docs/setup.md` | Harness rows; the already-stale CI row | Car 3 |
| `README.md:46-47` | Adapter list still says "a conductor-maintained state file" | Car 3 |
| `CLAUDE.md` | Every brief must mandate an envelope | Car 2 |
| `docs/templates/car-brief.md`, `.claude/agents/car.md`, `/goodnight` | Envelope and sweep duties | Car 2 |
| `scripts/Land-Verdict.ps1`, `Verify-Verdict.ps1` | De-hardcode the project path; headers call themselves "the harness"; extend verification to the new store | Car 2 |
| The parked yard design | Returns as rev 4 against this contract | Not this train |

## §9 - Cost

Three cars, three reviewers, plus this design's review: **~8 dispatches**, Opus, size class
medium. Within the ~11 the owner approved on 2026-07-22 (`66f3c78`); five review dispatches
already spent on revs 1-4. **Void and re-approved if the §7 blocking test fails.**

Per the **merge north star**, none of this reaches `main` until there is a good known
working state to assert.

## §10 - Open questions for the reviewer

1. **§0 splits the document and sends the format half to code.** Is the line drawn in the
   right place - is anything in §5 still secretly a protocol?
2. **P1 says a detector never writes.** Is human backfill actually workable, or does it
   reintroduce the vigilance this train exists to remove - just at a lower frequency?
3. **§5.5's tier 2 is CI-readable only because Entire pushes transcripts.** Does naming a
   vendor's branch in a design leak a producer into the contract, even scoped as a capability?
4. **This is the first document written through `design-doc.md`.** Did the template help, or
   did §1 and §2 read as paperwork? A workflow artifact that produces ceremony is worse than
   none, and this is the only round that can judge it honestly.

## §11 - History

| Rev | Verdict | What it cost, what it bought |
|---|---|---|
| 1 | REJECT, 7 Major | Wrong hook lifecycle; unredacted publication; no doc owner |
| 2 | REJECT, 3 Major | Cost gauge caught reading 18% of true burn |
| 3 | REJECT, 4 Major | A live forgery found in the integrity tooling by fault injection |
| 4 | REJECT, 5 Major, **escalated** | The demonstration was `sweep = dict(hook)` - proof by tautology |
| 5 | this | Written through the workflow those four rounds paid for |

The class was never *"the fold is hard."* It was **failure due to a non-existent workflow**,
at the one rung with no prior art, because the seed ported rules without exemplars. All four
verdicts are landed verbatim and hash-verified in `docs/reviews/`.
