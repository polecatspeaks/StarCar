Status: Current

# The Dispatch Harness: One Artifact Per Dispatch (#7)

Cargo: #7. Successor tickets: #1 (the yard board consumes this store), #6 (quickstart
runner), #8 (board columns). Laws served: **First** (never render a dispatch state the
artifacts cannot back), **Fourth** (a dispatch the store never heard of is not silently
lost), **Fifth** (the board says which detection tier is in force), **Sixth** (one writer,
so there is no second copy to reconcile), **Seventh** (the schema is the product; producers
are adapters).

Source of truth: `docs/design/2026-07-22-dispatch-harness-design.md` rev 6 **plus BINDING
AMENDMENT A1**, which supersedes contradicting design text. Design review: 5 rounds, REJECT
each, closed by recorded conductor ruling rather than a sixth round (design §9b).

Owner decisions locked in: the harness is **core product, not tooling** - the artifacts are
the board's data source, not merely a record; **path normalisation is portability, not
curation**; nothing reaches `main` except from a good known working state.

## 1. The problem

A dispatch's output is ephemeral. Today the conductor runs `scripts/Land-Verdict.ps1` by
hand with seven mandatory parameters (`Land-Verdict.ps1:39-51`), which is **vigilance** -
the weakest tier in the Healing Loop's hierarchy. Entire.io gives durability but not
addressability. `README.md:20-21` promises review verdicts "committed in-repo as they
happen"; that promise is currently kept by someone remembering.

Seven verdicts have landed this way. Zero dispatch *starts*, honest stops, or costs have
been recorded at all, so the board has no source for anything except completed reviews.

## 2. Architecture

**One writer, one read-only detector** (design P1). The producer hook writes; reconciliation
only ever *raises*. A human backfilling is that same single writer acting deliberately.

**The producer** binds two hooks:

| Record | Hook | Verified |
|---|---|---|
| `dispatched` | `PostToolUse` matcher `Task` | Fires at launch with `status: async_launched`, no body - `docs/reviews/2026-07-22-harness-design-round1-REJECT.md:66` |
| `returned` | `SubagentStop` | Fires **exactly once per subagent** - 74 firings across 74 distinct `agent_id`s, 4 of 4 dispatches completing after the probe existed (design amendment A1) |

**Two independent filters, and the second is free.** The `SubagentStop` payload carries
`agent_type`; only dispatched cars carry a real type (4 of 74 observed). Independently,
**only real dispatches leave a persistent transcript**: the subagents directory holds
exactly 7 `.jsonl` files against 74 firings, one per car dispatch, 347KB-676KB each. A
producer that filters on either is correct; filtering on both is belt-and-braces and costs
one `Test-Path`.

**The payload hands over `agent_transcript_path` directly**, so the producer never scrapes
the parent session transcript. This is the whole of the vendor coupling: one documented
field, not a format. `Land-Verdict.ps1:78-115`'s parent-transcript scraping is retired
(§4).

**The detector** reads the store and raises findings. It never writes. Tier 1 (every
`dispatched` has a successor or renders unaccounted-for) needs only the artifacts, so any
conforming shop gets it. Tier 2 (an enumerable second source finds dispatches the store
never heard of) is producer-dependent; ours is the Entire checkpoint branch.

## 3. Contracts

**Owned by the schema artifact, NOT by this spec** (design §0 - the format half is
executable or it does not exist): field names and types, the record grain, the index
format, and the path-normalisation substitution rule.

**Owned here, because they are behavioural:**

- Kind vocabulary: `dispatched`, `returned`, `presumed-lost`, `intent`, `ruling`.
- Kind precedence for one dispatch: `returned` > `presumed-lost` > `dispatched`.
- Within a kind: **latest-`at` wins, and the board renders that a supersession occurred**
  (design §5.8.1, adopting round 4's ruling grounded in `Land-Verdict.ps1:112-115`).
- `unaccounted-for` is **derived**; `presumed-lost` is the record that closes it.
- A later `intent` for a subject supersedes the earlier one - that is how a hold is
  withdrawn without mutation.
- **Spend renders only from `cost`; the lane is dark when absent, never back-filled from
  context.** The two never share a scale, an axis, or a summary row.

## 4. Retirement list

Deleted in this train, callers enumerated, "zero remaining callers" grep-proven by the car
and re-proven by its reviewer.

| Retired | Where | Replaced by |
|---|---|---|
| Hardcoded project path | `Land-Verdict.ps1:59` | git-root derivation (Law 7 - a stranger cannot run it today) |
| Parent-transcript scraping | `Land-Verdict.ps1:78-115` | `agent_transcript_path` from the hook payload |
| Seven-parameter manual invocation | `Land-Verdict.ps1:39-51` | hook-driven; the CLI survives only for backfill |
| Vacuous-pass exits | `Verify-Verdict.ps1:87-96` - exits 0 when the directory is absent **or holds no files**, invoked bare at `ci.yml:47` | fail when the expected store is empty; the same workflow already refuses this shape for tests at `ci.yml:62` |
| `docs/reviews/` as a location | 7 landed verdicts | migrated into the artifact store, history preserved, **in the same commit** that creates the index so `README.md:20-21` is never momentarily false |
| Both scripts' self-description as "the harness" | `Land-Verdict.ps1:1`, `Verify-Verdict.ps1:1-8` | "the Claude Code producer" - one adapter among possible others (#7) |

## 5. Lifecycle events (mandatory section)

**This feature introduces NO mutable service state, and that is a consequence of the design
rather than an accident.** Stating it explicitly because a spec that introduces state
without this section was the ancestor's most expensive documentation failure.

| Component | State | Why none |
|---|---|---|
| Producer hook | none | Fires, writes one file, exits. No process outlives the write. |
| Detector | none | Reads the store, emits findings, exits. |
| Index generator | none | Reads artifacts, writes `INDEX.md`, exits. |

The one-writer premise is what buys this: two producers would have required remembered
identity, dedup and clock state, which is exactly the machinery the design deleted. **If any
car finds itself adding a field that outlives a process, that is a plan-vs-design
contradiction and an honest stop**, not a ledger row to be filled in quietly.

The store itself is durable state, but it is append-only files under git - its lifecycle is
git's, and `docs/contracts/state-ledger.md` is instantiated by car 1 to say exactly that.

## 6. Testing

Cells: a `dispatched` written at launch and its `returned` at stop produce two records for
one subject; kind precedence resolves to `returned`; two `returned` records resolve to
latest-`at` **with the supersession rendered**; a `dispatched` past budget with no successor
derives unaccounted-for; a later `intent` supersedes an earlier hold; an internal subagent
(no `agent_type`, no persistent transcript) produces **no artifact at all**; spend absent
renders a dark lane and never borrows the context figure.

**Non-vacuity, mandatory:** fault-inject each guard once, watch it fail, revert, document.
Specifically - remove the `agent_type` filter and confirm the store floods (74 artifacts, not
7); empty the store and confirm the extended verifier **fails** where today it exits 0.

## 7. Probe list (what the desk cannot prove)

1. **Does the hook fire when a session is killed mid-dispatch?** Every one of the 74
   observations was a clean completion. Settled by: kill a session with a dispatch in
   flight and inspect the store. **This is the case tier 1 exists for**, so it is
   load-bearing and gets a blocking test before car 2 ships.
2. **Does a slow or failing hook command block or delay the dispatch?** Unknown; the probe
   hook was trivial. Settled by: a deliberately slow hook, timed.
3. **Do two hooks firing simultaneously contend on the git index?** Three cars are planned.
   Settled by: two concurrent dispatches, observed.
4. **Are the four cost counters present for every model tier?** Verified only on Opus
   dispatches. Settled by: one dispatch on another tier, counters inspected.
5. **Does `agent_transcript_path` exist at the moment the hook fires**, or only after the
   runner finishes writing it? Settled by: stat the path inside the hook.

Items 1 and 5 are load-bearing and become blocking tests. Items 2-4 may be answered during
car 2 provided the answers are recorded.

## 8. Non-goals

Signing beyond the integrity hash. Retention and pruning. Producers for other runners
(the format must not prevent them; building them is not this train). Rendering - that is
the yard design's job (#1). Migrating dispatches from before this train, except the seven
landed verdicts. A `background_tasks`-based liveness source: the payload carries one, but in
4 of 74 payloads the stopping agent still listed **itself** as running, so it is
corroboration at best and is deferred.

## 12. Review record

Design review, 5 rounds, all REJECT, all landed verbatim and hash-verified in
`docs/reviews/`: 7, 3, 4, 5, 2 Majors. Round 4 escalated to the owner under a
reviewer-set cap; round 5 recorded that **the failure class moved** - rounds 1-4 found only
protocol defects, round 5 found none - which was the falsifiable evidence that the design
workflow artifact did work. Closed by recorded conductor ruling (design §9b), not by a
sixth round.

Spec review: *pending - this section is filled by the reviewer's verdict and stays in this
document forever.*
