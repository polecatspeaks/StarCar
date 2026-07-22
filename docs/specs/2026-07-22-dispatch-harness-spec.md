Status: Current

# The Dispatch Harness: One Artifact Per Dispatch EVENT (#7)

Cargo: #7. Successor tickets: #1 (the yard board consumes this store), #6 (quickstart
runner), #8 (board columns). Laws served, each naming the section that delivers it:
**First** §6 + §7 · **Second** §3 (intent supersession) · **Third** §5.1 · **Fourth** §2.4 +
§6 · **Fifth** §2.5 · **Sixth** §5.2 · **Seventh** §3.2 (vocabularies as data).

Source of truth: `docs/design/2026-07-22-dispatch-harness-design.md` rev 6 **plus BINDING
AMENDMENT A1**. Design review: 5 rounds, closed by recorded conductor ruling (design §9b).

> ## BINDING AMENDMENT S1 (conductor-applied, 2026-07-22, post-approval)
>
> **The §4 row-4 claim that `Verify-Verdict.ps1:94-96` "exits 0" on a zero-file store is
> FALSE, and the lines are unreachable.** Found empirically at the plan rung (round-1
> verdict, `docs/reviews/2026-07-22-plan-review-car1-round1.md`, Major 1): pointed at an
> existing directory with zero `.md` files, the script **throws** `PropertyNotFoundStrict`
> at `:94` and exits **1** - `Set-StrictMode -Version Latest` (`:27`) meets a `$null`
> pipeline result at `:91`, so `$files.Count` explodes before the guard is reached.
> `:95-96` is dead code on every path. Only the dir-ABSENT vacuous exit (`:87-90`, exit 0)
> is real.
>
> Supersedes: §4 row 4's defect description, and §6's non-vacuity item *"Empty the store
> and confirm the extended verifier fails where today it exits 0"* - unsatisfiable as
> written, since the empty store already exits 1 (by crash, which is a truthful exit code
> delivered as an unactionable stack trace, its own Law-5 defect). The item is replaced by:
> **(a)** absent store fails loudly where today `:87-90` exits 0; **(b)** empty store fails
> with an ACTIONABLE named-directory error where today it crashes with a strict-mode
> throw; **(c)** the dead vacuous-exit code at `:94-96` is removed, not preserved.
>
> Why this survived three spec-review rounds: every round - including the round-3 review
> that returned zero findings - verified the claim by READING the code, and reading
> `:94-96` produces exactly the false claim. The behavioural truth took one command. The
> corrected discipline is recorded as `worked-plan.md` Amendment 1: behavioural claims
> are verified by RUNNING, structural claims by reading.

Owner decisions locked: the harness is **core product, not tooling**; **path normalisation is
portability, not curation**; nothing reaches `main` except from a good known working state.

**[M8, folded] Retitled to "per dispatch EVENT".** Design P2 fixes the grain as a
behavioural premise - *"a dispatch is the unit of record"* - and `design §5.1` says *"one record
per dispatch event"*. Rev 1 dropped "event" from the title while §6 required two records for
one dispatch, and simultaneously handed grain to the schema artifact. **Grain is behavioural
and is fixed here** (ruling 1); the schema owns field names, types, ordering and identity.

## 1. The problem

A dispatch's output is ephemeral. `scripts/Land-Verdict.ps1:39-51` requires seven mandatory
parameters typed by hand - **vigilance**, the weakest tier. Entire.io gives durability but not
addressability. `README.md:20-21` promises verdicts *"committed in-repo as they happen"*; that
promise is currently kept by someone remembering.

Eight verdicts have landed this way. Zero dispatch *starts*, honest stops, or costs have been
recorded at all.

## 2. Architecture

**One writer, one read-only detector** (design P1). The producer hook writes; reconciliation
only ever *raises*. A human backfilling is that same single writer acting deliberately.

### 2.1 The producer

| Record | Hook | Verified |
|---|---|---|
| `dispatched` | `PostToolUse` matcher `Task` | Fires at launch, `status: async_launched`, no body - `docs/reviews/2026-07-22-harness-design-round1-REJECT.md:66` |
| `returned` | `SubagentStop` | Fires **exactly once per subagent** - 74 firings / 74 distinct `agent_id`s (amendment A1) |

### 2.2 Filtering — `agent_type` ONLY [M5, folded; ruling 2]

**The producer filters on `agent_type`, unconditionally and alone.** Rev 1 offered
transcript-existence as an equal alternative and called the pair "belt-and-braces". That was
wrong three ways:

- It depended on **this spec's own open probe** (§7.4): if `agent_transcript_path` is only
  populated *after* the runner finishes writing, a `Test-Path` filter rejects **every** real
  dispatch and the store stays empty. The 7-files observation was a post-hoc directory
  listing taken at a different moment than the one the producer runs in.
- "Either is correct" is a **menu, not a requirement**, and an implementer seeing only its own
  task picks one.
- Under the endorsed pair the `agent_type` fault-injection could not fail (§6).

The transcript-existence test may be **added** once §7.4 returns positive, and **never as the
sole filter**.

### 2.3 Obtaining the outcome [M6, folded]

The `SubagentStop` payload carries `agent_transcript_path`, so the producer never scrapes the
parent session transcript.

**The agent ends its report with an envelope** - a fenced block, info string
`starcar-artifact`, carrying `outcome`, `findings` and `abstract`. **Angle brackets are
forbidden inside it** (measured: a sentinel form was neutralised by a safety filter; a later
form landed with `>` HTML-escaped; the angle-bracket-free form landed byte-clean).

That is **how a `returned` record obtains its outcome**, which rev 1 never stated - the
feature's central mechanism, unspecified. `docs/templates/car-brief.md` does not mandate an
envelope today, so that work is real and outstanding (§9).

**Absent and malformed are different faults:** no envelope is `outcome: error`,
`envelope: absent` - **a brief failure**; present-but-unparseable is `envelope: malformed` -
**a producer failure**. Both land with the body intact.

### 2.4 Concurrent writes [M6, folded; ruling 5]

Carried from `design §6` (concurrent-write row), not reopened as an unknown: **the producer writes its own path
only and never `git commit -a`; a contended commit retries; a failed write is RAISED, never
dropped silently** (Law 4).

### 2.5 The detector

Tier 1 (every `dispatched` has a successor or renders unaccounted-for) needs only the
artifacts, so any conforming shop gets it. Tier 2 (an enumerable second source) is
producer-dependent; ours is the Entire checkpoint branch. **The fold exposes which tier is in
force**; what the board draws with it is #1's job (§3.1).

**[m5, folded] Tier 2 is not CI-reachable as configured:** `.github/workflows/ci.yml:32` is a
bare `actions/checkout@v4` with no ref fetch. Car 3 owns the fetch.

## 3. Contracts

**Owned by the schema artifact** (design §0 - the format half is executable or it does not
exist): field names, types, ordering, identity, the index format, and the path-normalisation
substitution rule. **[m4] Where a behavioural rule below must name a field to be stated at
all - `cost`, `agent_type` - it names it; that is the rule identifying its subject, not this
document specifying a schema.**

**Owned here, because behavioural:**

### 3.1 Kinds, precedence, supersession

Kinds: `dispatched`, `returned`, `presumed-lost`, `intent`, `ruling`.
**[m6] "Subject" and "dispatch" are the same key** for the three dispatch kinds - the subject
of a dispatch-lifecycle record IS its dispatch. `intent` and `ruling` have non-dispatch
subjects. Identity is the schema artifact's (design §5.1).
Precedence for one dispatch: `returned` > `presumed-lost` > `dispatched`.
Within a kind: **latest-`at` wins, and the fold exposes a supersession marker**
(`Land-Verdict.ps1:112-115` already implements this rule for repeat notifications).
`unaccounted-for` is **derived**; `presumed-lost` is the record that closes it.
A later `intent` for a subject supersedes the earlier one - how a hold is withdrawn (Law 2).

**[M4, folded; ruling 3] These are FOLD requirements, not rendering requirements.** The fold
*exposes* a supersession marker and *reports* spend as absent; what the board draws is #1's
job, and §8 keeps rendering out of scope. Rev 1's wording ("the board renders…") put board
code inside this train's scope, against its own non-goals.

### 3.2 Vocabularies are DATA [M6, folded]

Kind and outcome vocabularies **ship as data, not as prose in this document**. An unrecognised
value is rendered loudly by name and treated as **a discovery, not a bug**. An unreadable
vocabulary file is **one board-level fault, never N per-lane faults**. Carried from
`design §5.2` and `design §6` (vocabulary-unreadable row); rev 1 claimed Law 7 in its header while dropping Law 7's
mechanism.

### 3.3 Liveness gradient [M6, folded]

Each dispatch carries a **budget**; a **shop-level default applies when omitted, so absent
never means infinite**. Past budget the fold reports **overdue with elapsed and budget**
*before* it reports unaccounted-for - **a gradient, not a cliff, so a mis-set budget degrades
visibly**. A `presumed-lost` record carries its own basis: what was observed, by whom, against
which budget.

### 3.4 Cost and context [M6, folded — P6]

Two fields, differently named. **Spend renders only from `cost`**; where absent the lane is
dark and is **never** back-filled from context. **Context is producer-optional exactly as
spend is** (design P6) - a stranger's runner may report no high-water mark.

### 3.5 An un-backfilled gap is a first-class state [M6, folded — ruling Q2]

A detected gap that is never filled is **visible debt, permanently, until filled**. A gap
living only in a CI log is an unknown that fails to render as unknown.

### 3.6 Publication and trust [N1, folded — the obligations the ledger CLAIMED were carried]

`design §0` assigns **publication and trust to the behavioural half** - this document's half.
Rev 2's fidelity ledger asserted they landed in §8; §8 is silent on them and the citation
pointed at the design's Cost section. The substance was genuinely absent. It is stated here:

- **The normalisation rule is DECLARED IN EACH LANDED ARTIFACT.** A reader must be able to
  see what was substituted without leaving the file. (Only the *substitution rule itself* is
  deferred to the schema artifact, per `design §0`.)
- **The un-normalised original is PRESERVED on the checkpoint branch.** Normalisation is
  portability, not curation, and this is the clause that makes that true rather than asserted.
- **Each artifact carries an integrity hash, and its independent counterpart is the checkpoint
  copy.** `scripts/Land-Verdict.ps1:281` states the reasoning: the independently-written
  checkpoint copy, *"not the hash, is the defence against whoever controls this script."* That
  is the Law 1 and Law 8 backstop for a public showcase, and rev 2 required neither half.

## 4. Retirement list

Callers and mirrors enumerated **at spec time**; the implementer *re*-proves "zero remaining
callers", never first-proves.

| Retired | Where | Callers / mirrors found at spec time | Replaced by |
|---|---|---|---|
| Hardcoded project path | `Land-Verdict.ps1:59` | sole caller `Get-LiveTranscriptPath` | derivation from the git root. **[m2] The target directory name is a MANGLING of the repo path and the rule is undeclared; it also differs in a detached worktree.** The mangling rule is the implementer's first task, not an assumption |
| Parent-transcript scraping | `Land-Verdict.ps1:78-115` | called once at `:187` | `agent_transcript_path` from the hook payload |
| Seven-parameter manual invocation | `Land-Verdict.ps1:39-51` | conductor, by hand | hook-driven. **[m3] The CLI survives for backfill and backfill happens precisely when no hook fired, so there is no payload path: the CLI takes an EXPLICIT transcript path argument** |
| Vacuous-pass exits | `Verify-Verdict.ps1:87-90` (dir absent) and `:94-96` (zero files); invoked bare at `ci.yml:47` against the `:24` default `docs/reviews` | `ci.yml:47` | fail when the expected store is empty. **[M3, folded; ruling 4] The verifier is repointed at the new store and `ci.yml:47` is updated IN THE MIGRATION COMMIT.** Rev 1's two rows contradicted: one emptied `docs/reviews`, the other made an empty store fatal, and the literal reading turned CI red permanently |
| `docs/reviews/` as a location | 8 landed verdicts | **[M2] `docs/setup.md:23-24`**, **`ci.yml:47`**, `README.md:20-21`, **`docs/friction-log.md:46`** | migrated into the store, history preserved, index created **in the same commit** |
| ~~Both scripts' self-description as "the harness"~~ | **[M1, WITHDRAWN]** | — | **The string does not exist.** `grep -c -i harness` returns **0 and 0**; `Land-Verdict.ps1:1` says *"extract a dispatched agent's verdict VERBATIM"* and `Verify-Verdict.ps1:6` says *"the checker"*. Rev 1 inherited the claim from `design §8` without opening either file. The framing that DOES need fixing is at `docs/setup.md:24`, and it is row 5's job |

## 5. Lifecycle

### 5.1 Process state: none, and that is a consequence of the design

| Component | State | Why none |
|---|---|---|
| Producer hook | none | Fires, writes one file, exits |
| Detector | none | Reads, emits findings, exits |
| Index generator | none | Reads artifacts, writes the index, exits |

The one-writer premise buys this: two producers would have needed remembered identity, dedup
and clock state - the machinery the design deleted. **If any implementer finds itself adding a
field that outlives a process, that is a plan-vs-design contradiction and an honest stop.**

### 5.2 Derived and committed artifacts [M7, folded; ruling 6]

Rev 1's table considered only *process* state and therefore could not fail. The **index** is a
generated file **committed to git** - a second copy of the store that can drift from it, which
Law 6 forbids by name.

**Ruling adopted: the index is regenerated-and-diffed by CI.** A stale index fails the build.
The generator is stateless; the *artifact* is derived state, and its freshness now has an
owner. The append-only records themselves remain git's lifecycle, which is honest.

## 6. Testing

Cells: a `dispatched` at launch and a `returned` at stop produce two records for one subject;
precedence resolves to `returned`; two `returned` records resolve to latest-`at` **and the
fold exposes a supersession marker**; a `dispatched` past budget reports **overdue with
elapsed and budget** before unaccounted-for; a later `intent` supersedes an earlier hold; an
internal subagent (no `agent_type`) produces **no artifact**; spend absent is **reported
absent** and never borrowed from context; an unrecognised vocabulary value is reported by
name; an unreadable vocabulary file is **one** fault.

**Non-vacuity, mandatory** - fault-inject each guard once, watch it fail, revert, document:

- **[M5, folded] Remove the `agent_type` filter and confirm the store floods: 74 artifacts
  against 4**, both counts taken over the same probe window. Rev 1 stated "74, not 7", mixing
  a windowed firing count with a lifetime transcript count - and under its own endorsed
  belt-and-braces producer the store would not have flooded at all, so the guard could not
  fail.
- Empty the store and confirm the extended verifier **fails** where today it exits 0.
- Stale the index and confirm CI **fails** (§5.2).

## 7. Probe list (what the desk cannot prove)

1. **Does the hook fire when a session is killed mid-dispatch?** All 74 observations were
   clean completions. **Load-bearing - blocking test before car 2.**
2. Does a slow or failing hook command block or delay the dispatch?
3. Are the four cost counters present for every model tier? Verified only on one tier.
4. **Does `agent_transcript_path` exist at the moment the hook fires**, or only after the
   runner finishes writing it? **Load-bearing** - §2.2 depends on it.
5. **[m1, added] Is every dispatch in this shop asynchronous?** §2.1's launch-time claim rests
   on an `isAsync: true` payload. Under a synchronous `Task`, `dispatched` and `returned` would
   land in the same breath and tier 1 goes vacuous.

*[M6/ruling 5: rev 1's probe on git-index contention is DELETED. `design §6` (concurrent-write row) already ruled
it; it is carried in §2.4. A probe may not restate a settled ruling.*

## 8. Non-goals

Signing beyond the integrity hash. Retention and pruning. Producers for other runners.
**Rendering - #1's job** (§3.1 states fold requirements only). Migrating pre-train dispatches
except the eight landed verdicts. A `background_tasks` liveness source: in 4 of 74 payloads the
stopping agent listed *itself* as running, so it is corroboration at best.

## 9. Contracts touched [M2, folded — the section rev 1 had no carrier for]

| Document | What changes | Owner |
|---|---|---|
| `docs/contracts/state-ledger.md` | Instantiated - records that the store is append-only under git and process state is nil | Car 1 |
| `docs/contracts/gating-matrix.md` | Instantiated - tier 1, tier 2, the index-staleness gate | Car 1 |
| `CLAUDE.md` | Every brief must mandate the envelope (§2.3) | Car 2 |
| `docs/templates/car-brief.md`, `.claude/agents/car.md`, `/goodnight` skill | Envelope and sweep duties | Car 2 |
| `docs/setup.md:23-24` | Both rows describe the retired scripts and `docs/reviews/` | Car 3 |
| `README.md:46-47` | Adapter list still says "a conductor-maintained state file" | Car 3 |
| `docs/friction-log.md:46` | Cites `Verify-Verdict` running only on memory | Car 3 |
| `.github/workflows/ci.yml` | Verifier repoint (§4 row 4), index-staleness gate (§5.2), checkpoint-branch fetch (§2.5) | Car 3 |
| **The migration commit itself** | §4 rows 4-5 constrain the store migration, the index creation and the `ci.yml:47` repoint into ONE commit, spanning two cars' deliverables. **Car 3 authors it; car 1 lands the index generator first so car 3 has something to invoke.** Sequenced, not guessed | Car 3 |

## 10. Fidelity to the design

| Design item | Where it lands here |
|---|---|
| P1 one writer / read-only detector | §2 |
| P2 dispatch-event grain | title, §3 (ruling 1) |
| P4 hook fires on stop | §2.1, closed by A1 |
| P6 context producer-optional | §3.4 |
| Kind precedence + three supersession cases | §3.1 |
| Liveness gradient + budget + shop default | §3.3 |
| Envelope, absent vs malformed | §2.3 |
| Concurrency write rule | §2.4 |
| Vocabularies as data | §3.2 |
| Two-tier detection, tier rendered | §2.5 |
| Cost/context split, dark lane | §3.4 |
| Ruling Q2 un-backfilled gap rendered | §3.5 |
| Publication + trust (`design §5.7`, `design §6` (artifact-altered row)) - normalisation declared in-artifact, original preserved, integrity hash with its independent copy | **§3.6** |

## 12. Review record

Design review: 5 rounds, 7/3/4/5/2 Majors, all landed verbatim in `docs/reviews/`. Round 5
recorded that **the failure class moved** - rounds 1-4 found only protocol defects, round 5
found none. Closed by recorded conductor ruling.

Spec review round 1: **REJECT, 8 Major, 7 Minor, 6 rulings** -
`docs/reviews/2026-07-22-harness-spec-round1-REJECT.md`. All eight Majors folded above and
marked `[M#, folded]`; all six rulings adopted; minors m1, m2, m3, m5 folded; **m4 and m6 were
claimed closed in rev 2 and were NOT** - both are folded here instead (§3 preamble, §3.1),
and the false claims are recorded rather than quietly corrected, because a review record that
can assert an unsupported closure is the same class as N1 at lower stakes. m7 is closed by
§10 plus this section. The reviewer ruled the defects
**omissions, not structure** - a coverage defect, extended with a rider rather than rewritten.

Spec review round 2 (**DELTA re-review, same reviewer, resumed with context intact**):
**REJECT, 1 Major, 4 Minor** - `docs/reviews/2026-07-22-harness-spec-round2-DELTA-REJECT.md`.
12 of 15 prior findings CLOSED by mechanism, 6 of 6 rulings adopted as ruled with none in
name only. The single Major was **inside the fidelity ledger built to prevent dropped
requirements**: a false row claiming §8 carried publication when §8 was silent and the
citation named the design's Cost section - *the fold that LOOKS folded*, which
`worked-rung-carriers.md:48` names and `:57` predicted by warning that a central ledger needs
CI to walk it. Folded as §3.6.

Spec review round 3 (fix-and-confirm): **REJECT, 1 Major, 1 Minor, both mechanical** -
`docs/reviews/2026-07-22-harness-spec-round3-CONFIRM-REJECT.md`. N1 confirmed CLOSED **on
substance**, all thirteen fidelity rows re-walked and resolving, and the spec's substance
ruled **plan-ready**. The Major was self-inflicted and mechanical: the repo-policy commit
split this design's `Status:` line in two, shifting every line from 3 onward by +1, and six
of eight numeric `design:NNN` citations silently stopped resolving - including the anchor
under a verbatim quote. *The commit that installed a documentation-policy gate invalidated
six citations in the document under review, and the gate it installed checks only that a
Status line exists.*

Spec review round 4 (final confirm): **APPROVE** -
`docs/reviews/2026-07-22-harness-spec-round4-APPROVE.md`. Every citation converted to a
**section anchor** rather than the six line numbers the reviewer listed - a deviation stated
openly and ruled *"the better call… correcting six numbers would have left the failure mode
armed."* Every anchor opened and confirmed to resolve to the passage carrying its claim, not
merely to a real heading. Suites re-derived by the reviewer rather than read from the report.

**THE SPEC IS APPROVED AND PROCEEDS TO THE PLAN RUNG.** Three rounds, sixteen findings, six
rulings, all closed by mechanism. Nothing carried forward. Two items parked as issue #9: the
`worked-spec.md` template amendment, and the citation-resolution CI check - whose assertion
the round-4 reviewer specified: **the annotation must be a substring of the target**, which
is what makes a citation mechanically checkable.
