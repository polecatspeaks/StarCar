# Manifest member identity: the plan names the plan, and the binding is an observation

Status: Open
Stage: **rev 2** - round-1 REJECT (3 Major, 5 Minor, 8 Notes) folded with `[DR1-n, folded]`
markers; awaiting delta re-review. Verdict:
`artifacts/reviews/2026-07-27-design-87-review-r1-REJECT.md` - **note for a reader on this
branch: that file is NOT here.** It landed on `dev` (commit `8c90dbe`) after
`design/member-identity-87` was cut, so it resolves after merge or via
`git show dev:artifacts/reviews/2026-07-27-design-87-review-r1-REJECT.md`. Verified
present on `dev` and absent here rather than assumed; the round-1 `#76` verdict cited in
§1 and the round-3 dual-runtime verdict cited in §0 ARE both present on this branch.
Issue: #87 (blocks #76, #85, #86; does not block #84)
Date: 2026-07-27
Rung: design (rung 1). Inherits the owner ruling on #76 (2026-07-27) and the round-1
verdict `artifacts/reviews/2026-07-27-tooling-76-review-r1-REJECT.md`.

**What changed in rev 2, in one glance.** Three Majors, all adopted, none appealed: a false
PR-5 measurement corrected and re-derived (§2b, §2c, §1, §5.7 - `description` turns out to
be present on **both** runtime families, so D8's premise got stronger); the Law-1 requirement
traced its last hop to the sentence a human actually reads (new §5.3a, §8 gains the view
layer and its 209 tests); and an ordering rule that had escaped into prose is now pinned by
a vector rather than deleted (§5.6 V12). Five Minors folded, three new vectors (V12-V14),
one new probe (PR-7), §2c shrunk from six rows to four, §10 Q3 closed by measurement and
Q7 opened.

---

## §0 - Instrument check (FIRST, and it can end the document)

**Answer: BOTH. The format half is the larger one and IS NOT WRITTEN HERE.**

- **Behavioural half - this document.** *Who* writes the plan-to-actual binding, *when*
  it can exist at all, which component owns deriving it, and what each surface renders in
  the epochs where it does not exist. Those are component-ownership and
  failure-surfacing questions; a reviewer can verify them by reading and by running the
  board, and this document does both.
- **Format half - specified in §5.6, built by a later rung.** The member object's identity
  key and `required` set, the record-to-member join rule and its precedence, the ambiguity
  and duplicate cases, and what "amendment" may and may not touch. Those are
  canonicalisation, identity, join keys and dedup. **This document states WHAT the
  executable artifact must contain and does not attempt to hold the rule in prose.**

**Why the split falls here, and it is a constraint rather than a preference.** A landed
verdict in this repo has already ruled on this exact class:

> *"identity, join keys, dedup and ambiguity are format/protocol - prose cannot hold
> them."*
> — `artifacts/reviews/2026-07-24-dual-runtime-design-review-round3-REJECT.md:77`

That ruling retired a whole design (`docs/design/2026-07-24-dual-runtime-harness-design.md`)
after three REJECT rounds whose single Major moved down one layer per round inside one
identity model. `docs/design/2026-07-24-family-agnostic-harness-design.md:10-20` is the
document that obeyed it, and its §0 is the shape this §0 copies. The founding wreckage
(`docs/templates/design-doc.md:166-228`) is the same class one rung earlier.

**The honest risk in my own answer, named so the reviewer can attack it:** an author who
declares "the format half is elsewhere" can smuggle format decisions into the prose half
and call them behavioural. The test I invite: **every sentence in §5 that a conformance
vector could falsify belongs in §5.6's list, not in §5.1-§5.5.** If the reviewer finds a
join, precedence, ordering or dedup rule stated as prose outside §5.6, that is a §0
violation by the author and should be a finding.

---

## §1 - Constraints (BEFORE the mechanism)

Every clause below was opened and quoted, not recalled.

| Source | What it FORBIDS here | How this design satisfies it |
|---|---|---|
| `docs/constitution.md:14-18` **Law 1 (Truth)** - *"a confident falsehood on a status surface is the worst defect this project can ship... Unknown states render AS unknown, honestly."* | Rendering a member as **not departed** when a record in the store shows it departed. Also: an identity field whose schema description claims something untrue of records in the store. | §5.2's epoch model renders exactly what is derivable and nothing more; §6 enumerates the unknown row. **This constraint is what disqualifies shape B - measured, §2 P1-evidence.** |
| `docs/constitution.md:28-31` **Law 3 (Actionability)** - *"a stalled car should look stalled at a glance."* | A surface that is technically true but forces the dispatcher to cross-reference two lanes to learn that an in-flight dispatch belongs to a train. | §5.4 requires the unattributed-dispatch count to be a rendered condition, not an inference the reader performs. Honest degradation is still degradation and is named as a cost in §6, not hidden. |
| `docs/constitution.md:33-37` **Law 4 (Nothing Silently Lost)** - *"never silently dropped... a missing lane reading as 'no trains' is a lie of omission."* | A schema-legal member the board discards with zero conditions (this is #85, measured). An in-flight dispatch that belongs to a train and appears nowhere as belonging to anything. | §5.3 forbids the drop outright: a declared member always renders. §5.4 requires the unattributed dispatch to be disclosed. |
| `docs/constitution.md:46-51` **Law 6 (One Truth)** - *"never maintains a second copy of anything that can drift. Where two sources disagree, the board SHOWS the disagreement rather than picking a winner silently."* | A second derivation of identity. A hand-maintained mirror between the plan and the actual. Silently picking a winner when one handle resolves to two records (**measured unguarded today**, §2c/PR-3). | §5.5's join is ONE rule with ONE owner (the assembler), symmetric on both sides. §5.6 requires an ambiguity condition rather than a precedence guess. The one unavoidable mirror (the handle appearing in both a plan record and a runtime record) is made *checkable* in §5.7 rather than merely tolerated. |
| `docs/constitution.md:53-57` **Law 7 (The Stranger)** - *"no hardcoded board schemas or label taxonomies... documentation a stranger can deploy from."* | Hardcoding the role/kind vocabulary (untouched here). **And: naming a member's identity field `subject` when it does not hold a record subject** - a stranger reads `subject` consistently across this schema and would be misled. | §4 D3 keeps `subject` meaning what it has always meant and never writes it on a new member. `schema/vocab/roles.json` stays the role owner; nothing in this design adds an enum. |
| `CLAUDE.md` **NO-BACKFILL** - *"Code that predates `d4db6f5` is not retrofitted... a gate that reds on older files is mis-specified"*, and #87's restatement: *"the six landed `train:board-v0` manifests are history and must keep validating."* | Any shape that retroactively invalidates the six landed manifests. **This design reads the doctrine one notch wider than #87 states it: it must not break their RENDERING either** - measured, they bind and render today (PR-4), and a board that stopped drawing them would be silent loss under Law 4 whatever the validator said. | §5.5's join carries an explicit legacy clause, and PR-4 measures the exact corpus shape it must keep serving: 10 distinct member subjects, all runtime ids, **0 of whose 16 returned records carry `task_id`**. |
| `docs/specs/2026-07-23-yard-board-spec.md:46` **YB-1, the manifest contract** - *"`members[]{subject, role, gate?}`, per `schema/starcar-manifest.schema.json`"*, LIVING per `docs/doc-map.md:53` (*"LIVING while binding; amendment blocks, never rewrites"* - the `docs/specs/*` row; **`[DR1-m1, folded]`: rev 1 cited `:52`, which is the `docs/design/*` row and a different axis. The citation gate cannot catch this class and says so itself at `scripts/tests/CitationResolverPolicy.Tests.ps1:12-18`, so the green run did not clear it**) | Changing the member contract while leaving this text standing. This is exactly R1-M3 and it is not to be repeated. | §8 assigns the §7b amendment block to the same commit as the schema change, with the amendment mechanism at `docs/specs/2026-07-23-yard-board-spec.md:192` as the vehicle (already carrying two amendments, one cited by name at `scripts/store-checks/StoreIntegrity.Tests.ps1:109` - **path corrected: the round-1 verdict cites this file bare, and it does not live under `scripts/tests/`**). |
| `docs/the-healing-loop.md:62-63` **Executable knowledge** - *"Validated facts must land as tests or gates, never only prose."* | Landing this design's join rule as prose and calling it done. | §0's split plus §5.6's named vector list; §9b records that the prose form is the failure this rung is avoiding. |
| `artifacts/reviews/2026-07-24-dual-runtime-design-review-round3-REJECT.md:77` | Specifying identity, join keys, dedup or ambiguity in prose. | §0. |
| `artifacts/reviews/2026-07-27-tooling-76-review-r1-REJECT.md` R1-M1/M2/M3 | Widening a contract without examining the alternative; leaving a wire undelivered and untracked; leaving the owning spec stale. | §9b, one row each, with dispositions - one of them an appeal carrying new measurement. |
| `scripts/Produce-Artifact.ps1:278-282` (issue #22 item 1, C3R-1e) - *"inventing one (e.g. parsing the free-text prompt) would be exactly the brittle mechanism this fix cycle's brief warns against"* | Sourcing anything at launch by parsing `tool_input.prompt`. | §5.7 sources from `tool_input.description`, a dedicated structured key measured present and populated on **98/98** captured live launch payloads **across BOTH runtime families** (PR-5, corrected `[DR1-M1, folded]`). The ruling forbids parsing free text; it does not forbid reading a field that exists. §10 Q2 puts the boundary to the owner anyway, because it is a contract question and the agent does not own it. |
| `docs/templates/design-doc.md:24-32` | Writing the mechanism before the constraints. | §0-§2c were written and probed before §5 existed; §2 P1 was measured false before any decision was taken. |

---

## §2 - Premises

Every premise below is stated with what changes if it is false. The five #87 named are
attacked first, then three nobody has written down.

### P1 - *"A member's identity lives in ONE field that must serve two masters."* **FALSE, measured.**

The manifest schema has carried two candidate keys since #76's branch, and shape B uses
two. Nothing in the format forces one field to do both jobs. **The single-field pressure
comes from the CONSUMER, not the contract:** `board/assemble/assemble.go:304-307` reads
exactly one member key and drops the member when it is empty, so whichever key the
assembler happens to read *becomes* the identity by force. The premise is a description of
a 10-line Go function, promoted to a law of the format.

**Measured (PR-1, this document's own probe, real `board/server` built from source, real
HTTP `/api/snapshot`):** shape B - both keys seeded with the shop handle, never amended -
put in front of a REAL `runtime-id`-family dispatch renders

```json
{"id":"train:shapeb","title":"Shape B vs a real runtime-id dispatch","cars":[],
 "declaredNotObserved":["d87-car-r1","d87-review-r1"],"tickets":["#87"]}
```

while the same store's dispatches lane simultaneously carries

```json
{"assigned":false,"outcome":"done","state":"returned","subject":"aaaaaaaaaaaaaaaaa","taskId":"d87-car-r1"}
{"assigned":false,"state":"dispatched","subject":"bbbbbbbbbbbbbbbbb"}
```

**Zero board conditions.** The board says `d87-car-r1` has not departed while holding, on
the same wire, a returned record that names `d87-car-r1` as its task id. That is Law 1's
named worst case, not a placeholder inconvenience.

*What changes if P1 is true after all:* nothing in this design - it never asks one field to
do two jobs. The premise's collapse is what makes §4 D1/D2 available.

### P2 - *"Plan-to-actual joining must be string equality on a single field."* **HALF SURVIVES.**

It is string equality (nothing here needs more), but not on *the identity field* and not in
one clause. §5.5's rule compares a *resolved handle* on each side. The distinction is the
whole design: the member's NAME and the record's NAME are compared, and neither side is
required to store the other side's name.

*What changes if false:* if equality is insufficient - if handles need normalisation
(case, whitespace, prefixes) - then the join becomes canonicalisation and §5.6's vector
list must grow a canonical-form vector. §10 Q3 puts this to the reviewer; I have not
probed whether any two handles in the corpus differ only by case.

### P3 - *"A member identity must be a string."* **SURVIVES, deliberately, and here is the alternative I rejected.**

A structured identity (`{"handle": "...", "observed": "..."}`) would let a member carry the
binding inline. That is precisely the shape P5 kills: it puts a runtime fact inside a plan
record, and it re-imports mutation, supersession-of-identity and ordering. A string keeps
the plan a plan.

*What changes if false:* if a member ever needs to be identified by something a string
cannot hold (a composite of train + role + round, say), §5.5's join is unaffected but
§5.6's identity vector set must express the composite, and the "one owner per rule"
argument needs re-checking.

### P4 - *"Amendment must MUTATE an identity rather than ADD a binding."* **FALSE, and stronger than #87 states.**

Not only need amendment not mutate identity - **under this design no identity amendment
exists to perform.** Manifest supersession remains, unchanged and untouched, for genuine
MEMBERSHIP changes (a train's consist really growing, exactly what the six landed
`train:board-v0` records show: 1 member, then 2, then 4, then 6, then 8, then 10).

*What changes if false:* if the owner rules that the conductor SHOULD record the runtime id
in the plan, this design's §4 D2 falls and the format half must specify mutation,
supersession ordering and the "which record won" rule - roughly the workload the founding
scar warns about.

### P5 - *"The manifest must name the runtime id at all."* **FALSE. This is the premise that dissolves the most.**

A manifest is a PLAN record (owner ruling, #76, 2026-07-27). The runtime dispatch id does
not exist at composition and is not a fact about the plan; it is a fact about an
observation. Inverting the reference - **the runtime record names its plan, never the
reverse** - removes identity mutation, identity supersession, the placeholder window, and
the "which of the two fields is the real identity" question in one move.

**And most of it is already built.** Measured (PR-1): a `returned` record already carries
`task_id`, the shop-minted handle echoed back by the envelope (`#47` §5.7;
`scripts/Produce-Artifact.ps1:358`), and the assembler already surfaces it on the wire
(`"taskId":"d87-car-r1"`). The datum needed to bind a plan member to its record *for every
returned dispatch* is in the store today and in the assembler's own scope
(`board/assemble/assemble.go:426-437`); only the direction of the lookup is missing.

*What changes if false:* if the owner wants the manifest to be the authoritative record of
which runtime id served which plan slot, then the plan must be amended per dispatch and P4
returns. §10 Q1.

### P6 (MINE, previously unstated by anyone) - *"The plan-to-actual binding is information that must be WRITTEN by someone at launch."*

Both rejected shapes rest on this without saying so. **It is false for the returned epoch**
(P5's measurement: derivable from data both sides already carry) and **true for the
in-flight epoch**: a `dispatched` record's field set is
`schema/kind/subject/session_id/at/budget/model/subject_basis/producer/normalisation/integrity`
- verified against a real record, `artifacts/a103c4067cf9267a3/dispatched-20260727T043547Z.json`
- and `session_id` is the CONDUCTOR's session, shared by every dispatch of that session, so
it discriminates nothing.

**The whole disagreement between shape A and shape B is a disagreement about how to cope
with ONE missing wire**, and neither shape said so. Naming it converts an identity argument
into a producer ticket.

*What changes if false:* if some field on a dispatched record can discriminate a member
after all, §5.7's wire is unnecessary and the in-flight epoch closes for free.

### P7 (MINE) - *"The conductor will reliably amend the manifest at each dispatch."*

Both rejected shapes are correct ONLY if this holds, and neither states it. `CLAUDE.md`'s
carrier rule is explicit that obligations do not cross by memory. Measured failure modes
under omission: **shape B degrades to a Law 1 falsehood** (PR-1 above), **shape A degrades
to Law 4 silent loss** (#85, measured by two independent parties). A mechanism whose
correctness depends on a human remembering a step per dispatch is vigilance-tier, and this
shop's own doctrine ranks that below a mechanism.

*What changes if false (i.e. if amendment IS reliable):* the shapes become viable and the
choice reduces to cost. I do not believe it, and PR-1/#85 are what a single missed
amendment already looks like.

### P8 (MINE) - *"This is one problem with one shape."*

**FALSE, measured (PR-2).** Member identity is a solved non-problem for the `minted-id`
runtime family, where the dispatch subject IS the shop handle. Same store, same board, same
run as PR-1:

```json
{"id":"train:minted","title":"Minted-id family",
 "cars":[{"subject":"d87-minted-car-r1","role":"car","state":"dispatched",...},
         {"subject":"d87-minted-gate-r1","role":"gate","gate":"car-review r1","state":"returned","outcome":"APPROVE","taskId":"d87-minted-gate-r1"}],
 "declaredNotObserved":[],"tickets":["#87"]}
```

Full consist, gates lane filled, `assigned:true`, zero conditions, **zero changes to
anything**. The identity crisis is not a property of manifests; it is a property of one
family's launch event not carrying the shop's own handle. That is adapter territory, and
`schema/vectors/adapter/README.md:12-14` already owns the principle: *"the repo defines the
contract and runtimes adapt to the repo (Law 7), not the reverse."*

*What changes if false:* if the `minted-id` family is a fossil that will never run again,
the legacy clause in §5.5 still stands on the six landed manifests alone, so the design
does not move - but §10 Q4's weighting does.

---

## §2b - Probes RUN for this design (what the desk could not prove until it ran)

*Section added to the template's order, deliberately and disclosed. `CLAUDE.md`'s probe
doctrine requires that "a probe result is perishable; it becomes substrate only when it
LANDS", with coordinates. §2c holds what could NOT be settled; this holds what WAS, so that
every `PR-n` cited above resolves and every behavioural claim in this document is traceable
to an observation rather than a reading.*

**Re-derivation recipe (the durable form - the scratch scripts are session-local):** build
the board with `go build -o <exe> ./server` from `board/`; construct a scratch store of
records sealed with `Get-Sha256Hex` over the compact canonical body via
`scripts/Artifact.psm1` (never a second hashing rule - the idiom is
`scripts/probes/ManifestBoardJoin.Probes.Tests.ps1:146-159`); run the exe with
`STARCAR_STORE_PATH=<dir>`, `STARCAR_PORT=<port>`, `STARCAR_POLL_MS=150` and
`WorkingDirectory` = the repo root; read `/api/snapshot`.

| # | What was run | Observed |
|---|---|---|
| **PR-1** | Shape B (both keys seeded with the shop handle, never amended) against a REAL `runtime-id`-family consist: one member's dispatch returned under a runtime subject carrying `task_id`, one still in flight. Real `board/server` built from source, real HTTP. | `"cars":[]`, `"declaredNotObserved":["d87-car-r1","d87-review-r1"]`, while the dispatches lane carried `{"assigned":false,"outcome":"done","state":"returned","subject":"aaaaaaaaaaaaaaaaa","taskId":"d87-car-r1"}`. **Zero conditions.** The board asserts a member has not departed while holding its returned record. |
| **PR-2** | A `minted-id`-family train in the SAME store and the same run: members named by the shop handle, records whose `subject` IS that handle. | Full consist rendered, gates lane filled (`"name":"car-review r1","outcome":"APPROVE"`), `assigned:true`, `declaredNotObserved:[]`, zero conditions - **with no change to anything.** |
| **PR-3** | Two DIFFERENT runtime subjects both returning with `task_id: dup-handle-r1` (a re-dispatch of one handle). | Both render, both carry `"taskId":"dup-handle-r1"` on the wire, **zero board conditions**. No ambiguity guard exists today; any handle-keyed join inherits the hole (drives D9 and V8). |
| **PR-4** | The landed legacy corpus, two ways. (a) A legacy-shaped manifest (members identified by runtime dispatch id, records carrying no `task_id`) through the real board. (b) A scan of `artifacts/train-board-v0/*.json` against the real store. | (a) Both members bound and rendered with liveness, `declaredNotObserved:[]`, zero conditions - so the fallback clause protects RENDERING, not just validation. (b) 6 manifests, 10 distinct member subjects, all runtime ids; those subjects own 16 `returned` records and **0 carry `task_id`** - the precedence clause cannot unbind any of them. |
| **PR-5** ***CORRECTED at round 2*** | Key-set extraction over the live launch-payload capture `.claude/probe-logs/post-task.jsonl` (written by `.claude/hooks/post-task-probe.sh`, the `PostToolUse:Task` probe). Key sets, `description` and `name` values only - no prompt bodies read out. Re-derived at round 2 with the command below, not copied from the review. | **98 payloads; TWO `tool_input` key sets, not one.** `description,model,prompt,subagent_type` **x78** (Claude family, carrying `subagent_type`, never `name`) and `agent_type,description,mode,model,name,prompt` **x20** (Copilot compat family, `_probe_logged_at` `2026-07-24T11:18:40Z` through `2026-07-25T23:08:35Z`, lines 42-61 - all logged days BEFORE this design was written). **`description` populated 98/98, 98 distinct, min length 17, max 43 - on BOTH families.** Copilot's `name` populated 20/20 but only **19 distinct**: `probe-dup-name` appears twice. |
| **PR-6** | Field-set check of a real modern dispatched record, `artifacts/a103c4067cf9267a3/dispatched-20260727T043547Z.json`, and its returned sibling; then the same question corpus-wide. | Dispatched carries `kind/subject/at/model/subject_basis` and **no `task_id`**; the returned sibling carries `task_id: view-69-71-review-r1`. Corpus-wide: **83 dispatched records, 0 carrying `task_id`** - stronger than the single record rev 1 cited. Confirms P6's split: the handle exists on return and nowhere at launch. |
| **PR-7** *(new at round 2)* | The handle corpus, over the real `artifacts/` store - the measurement rev 1 wrongly parked in §2c as unprovable `[DR1-m2, folded]`. | **96 records carry `task_id`; 96 DISTINCT values; 0 handles shared by two subjects; 0 uppercase; 0 whitespace; 0 case-insensitive collisions.** Store kinds: 83 `dispatched`, 177 `returned`, 6 `intent`, **0 `presumed-lost`**. Settles §10 Q3 (exact string equality is sufficient today) and bounds the `presumed-lost` gap (§5.2, §6) as undesigned rather than live-broken. |

**Non-vacuity of PR-1 and PR-2:** they ran in ONE store, against ONE server process, in one
snapshot. The `minted-id` train rendering correctly in the same breath as the shape-B train
rendering falsely is what rules out "the probe store was simply broken" as an explanation.

**PR-5/PR-7 extraction commands, so nobody re-derives them by hand.** PR-5 groups
`tool_input` key sets over the capture; PR-7 walks `artifacts/**/*.json`:

```
python -c "import json,collections,sys; rows=[json.loads(l) for l in open(sys.argv[1],encoding='utf-8') if l.strip()]; c=collections.Counter(','.join(sorted((d.get('tool_input') or {}).keys())) for d in rows); print(len(rows), c.most_common())" .claude/probe-logs/post-task.jsonl
```

**PR-5 WAS WRONG IN REV 1, and the correction is recorded here rather than quietly
swapped `[DR1-M1, folded]`.** Rev 1 published *"every one's `tool_input` key set is exactly
`description, model, prompt, subagent_type`"* in three places. Measured over the same file,
that is false by 20 of 98: the Copilot compat family carries a six-key set including `name`
and `agent_type` and no `subagent_type`. The error was an extraction that sampled the tail
(the six most recent payloads, all Claude) and generalised to the whole file - a reading
dressed as a measurement, in a section whose own opening promises the opposite. **What the
correction does NOT do is weaken D8: `description` is populated on 98/98 across both
families, which is a stronger premise than rev 1 claimed.**

**Two caveats, stated rather than glossed:**

1. **The capture is not in the tree.** It lives in the SHARED checkout's gitignored
   `.claude/probe-logs/` and grows with every dispatch, so my line numbers (42-61 Copilot)
   are true of the 98-line file as of 2026-07-27. A later reader re-derives the CLASS - two
   key sets, Copilot carrying `name`+`agent_type` and no `subagent_type` - from their own
   capture. That is the same honest boundary
   `schema/vectors/adapter/copilot-launch-minted-from-name.json`'s provenance line already
   records.
2. **The landed Copilot vector and the live capture DISAGREE, and this design does not get
   to leave that standing.** `schema/vectors/adapter/copilot-launch-minted-from-name.json:14`
   declares `"tool_input": { "name": "47-car-r1", "agent_type": "car", "prompt": "x" }` -
   **no `description`** - while all 20 live Copilot payloads carry one. A car building D8
   against that vector would find no `description` on the Copilot path and conclude the
   family cannot carry a handle. §8 carries the reconciliation as an obligation with an
   owner, not as a note.

## §2c - Probe list (what the desk CANNOT prove)

Everything this design assumes and could not settle from here. Nothing in this table is
stated as fact anywhere else in the document.

**Round-2 discipline `[DR1-m2, folded]`:** this table shrank from six rows to four. Two of
rev 1's rows were **desk-provable and should never have been parked here** - handle-collision
frequency and case/whitespace normalisation, both answered by one scan of `artifacts/`,
now landed as PR-7. The template's rule is that UNVERIFIABLE claims go here; parking a
verifiable one inflates the list and buys a downstream dispatch to re-derive what a single
command answers. A third row (the Copilot capture) was not merely parkable but **falsified
by the file it cited** and is now a measurement.

| Claim | Why unverifiable from the desk | What would settle it |
|---|---|---|
| The producer, running under the real hook, would read `tool_input.description` unchanged. | I observed the field in `.claude/probe-logs/post-task.jsonl` (the PostToolUse capture), and `scripts/Produce-Artifact.ps1` reads the same payload object - but no code reads `description` today, so the end-to-end read is unbuilt. | A red-first producer test over the captured payload shape, then one live dispatch. Blocking test in §7. |
| ~~The Copilot compat launch payload still carries `tool_input.name`.~~ **RETRACTED - MEASURED, not unverifiable `[DR1-M1, folded]`.** | **Rev 1 declared "no Copilot dispatch is available to me" while 20 Copilot launch payloads sat in the very file PR-5 was reading.** The row asserted unprovability about data the author already held - the same defect class as the false key-set claim, one table over. | **Settled: PR-5.** 20 Copilot-family launches, `name` populated 20/20 (19 distinct - `probe-dup-name` twice), `description` populated 20/20, lines 42-61. P8's `minted-id` half rests on live evidence, not a fossil. |
| The board renders §5.3/§5.4 as specified. | No code exists; #85 and #86 are unbuilt. Every rendering claim about the FIXED board is a requirement, never an observation. | The car that closes #85/#86, with the §5.6 vectors as its reds. |
| Whether the live Copilot payload's `description` is CONDUCTOR-authored or synthesised by the compat layer. | PR-5 proves the key is present and populated on all 20; it cannot prove who wrote it, and the Copilot launch tool's own parameter contract is not in this tree. | One Copilot dispatch where the conductor writes a known string and the capture is compared. **D8's Copilot path is gated on this**; the Claude path is not (PR-5 shows `description` echoing the conductor's own text verbatim on that family). |
| Whether a future runtime family carries any conductor-authored key at all. | Unknowable; #47's whole point is that families arrive unannounced. | The adapter vector set, when that family arrives. D8 degrades per §5.7 rather than breaking. |
| The owner accepts a task-id convention on `tool_input.description`. | Not a probe at all - a contract ruling the agent does not own (`CLAUDE.md`, reality-vs-spec). | §10 Q2. |

---

## §3 - The problem

The owner's words, from the #76 ruling of 2026-07-27:

> *"the manifest is a PLAN record, minted at train composition, amended by supersession
> (never rewritten); dispatch records are the ACTUAL stream; the board's product is the
> DELTA between them - fulfillment state per member, per role."*

The delta cannot be computed because a plan member and its dispatch record have no name in
common. At composition the conductor knows only the shop-minted task-id; at launch the
runtime mints a subject the conductor could not have predicted. Two shapes were tried and
both were rejected by the owner: one left the identity field empty and the member became
invisible (#85), one seeded the field with a placeholder handle. #87 asked whether the
premise under both - one field, two masters - survives contact. It does not.

The narrower statement of the same problem, and the one this design answers: **the shop has
a handle for every dispatch it plans, and its own runtime records carry that handle in
exactly one of the three lifecycle kinds.**

---

## §4 - Decisions

| # | Decision | Reason | Constraint or premise that drove it |
|---|---|---|---|
| **D1** | A member's identity is the **shop-minted task-id**. One master: naming. Minted at composition, never rewritten, the row title in every epoch. | It is the only name that exists at composition, and it is stable across the whole lifecycle by construction. | P1 (false), owner ruling (a plan record) |
| **D2** | **A member never carries a runtime dispatch id.** The manifest names no runtime fact. | A plan cannot contain an observation. Removes mutation, identity supersession, the placeholder window, and the two-masters conflict together. | P5 (false), P4 (false) |
| **D3** | The identity key on a new member is **`task_id`**, matching the record-side field name exactly. `members[].subject` keeps its existing meaning ("a dispatch subject") and is **never written on a new member again**. | Same concept, same name on both sides makes the join self-evident and single-owner. Renaming or redefining `subject` would either lie to a stranger or make the six landed manifests' descriptions false (their members really are dispatch subjects - PR-4). | Law 6, Law 7, NO-BACKFILL |
| **D4** | The schema keeps `role` unconditionally required and requires **at least one identity key** (`task_id` or `subject`). This is shape A's `anyOf` construct, **adopted for a different reason than shape A gave**. | NO-BACKFILL forces two identity keys to coexist: the landed corpus is identified by a key the new shape does not use and cannot be rewritten. The widening is not "to enable an invisible member"; it is the mechanical form of the no-backfill boundary. | NO-BACKFILL, R1-M1 (appealed, §9b) |
| **D5** | The plan-to-actual binding is **DERIVED by the assembler from data both sides already carry**, never declared in the plan and never written by hand. | One rule, one owner, nothing to forget and nothing to drift. Kills P7's vigilance dependency for the returned epoch outright. | Law 6, P6, P7 |
| **D6** | A member with no bound record **always renders, under its identity**. It is never dropped, and the state it renders is *"declared; no departure bound"* - never *"not dispatched"*, which the board cannot know. | The board can prove a member has no BOUND record; it cannot prove no dispatch happened. | Law 1, Law 4, #85 |
| **D7** | A dispatch record bound to no member is **disclosed as a board condition**, with a count, not left as a per-row `assigned:false` the reader must aggregate. | Measured today: two unattributed in-flight dispatches produce zero conditions (PR-1). Under D5 the unbound in-flight window becomes the NORMAL state until D8 lands, so it must be loud rather than inferable. | Law 3, Law 4 |
| **D8** | Closing the in-flight window is a **PRODUCER change, not a manifest change**: stamp `task_id` on `dispatched` records, sourced from the launch payload's dedicated `tool_input.description` key. **This design does not build it and does not depend on it** - without it the in-flight epoch renders honestly unbound per D6/D7. | P6 localises the entire in-flight gap to one missing wire. Making the design correct-without-it and better-with-it keeps the two decisions separable. | P6, P8, C3R-1e (a dedicated key, not the free-text prompt) |
| **D9** | Where a handle resolves to more than one record, or a record to more than one member, the board **discloses the ambiguity** and renders both; it never picks a winner by recency, order, or precedence. | Measured: two records sharing one `task_id` raise zero conditions today (PR-3). Any handle-keyed join inherits that hole. | Law 6 (*"SHOWS the disagreement rather than picking a winner silently"*) |

---

## §5 - Mechanism

### 5.1 The two records, and what each is allowed to know

| Record | Authority | May contain |
|---|---|---|
| Manifest (`intent`, `train:` subject) | The conductor's PLAN | Membership, roles, gate names, and each member's shop handle. **No runtime facts of any kind.** |
| Dispatch stream (`dispatched` / `returned` / `presumed-lost`) | The producer's OBSERVATION | Runtime subject, liveness, outcome, and - where the handle is knowable - the shop handle the dispatch was launched under. |

Neither writes into the other's territory. The relation between them is computed, and the
component that computes it is the assembler - the same component that already computes
every other cross-record relation on this board.

### 5.2 The epochs of a member

A member is in exactly one of three states, and the state is derived, never stored:

1. **Declared.** No record in the store resolves to this member's identity. The plan
   asserts the member; the store does not corroborate it. This is the completeness
   assertion the owner's ruling was filed for.
2. **Declared, departure unbound.** Dispatch records exist that belong to no member, and
   this member has no bound record. **The board must NOT guess a pairing** - it renders
   the member as declared and discloses the unattributed dispatches separately (D6+D7+D9).
3. **Bound.** A record resolves to this member's identity; the member row carries its
   liveness, outcome, superseded history and record path exactly as a `subject`-matched
   member does today.

Epoch 2 exists only while D8's wire is absent for a family. It is a real, honest, and
temporary steady state, and §6 gives it a row.

**`presumed-lost` traced through the epochs `[DR1-m4, folded]` - rev 1 named this kind in
§5.1 and then never again, which is the carrier failure inside one document.** It matters
more than its record count because it is the record kind for the **#32 killed-session
class the owner's ruling names as the manifest's whole purpose**. Three facts govern it,
all verified: it is a first-class kind with fold precedence `returned` over `presumed-lost`
over `dispatched` (`scripts/Detect-Dispatches.ps1:163-164`); **it carries no `task_id` by
construction** (`scripts/Produce-Artifact.ps1:358` writes `task_id` only when
`$Kind -eq 'returned'`, and `schema/vectors/valid-presumed-lost.json` has none); and
**0 exist in the store today** (PR-7), so nothing is live-broken.

The consequence, stated rather than left to a car: under §5.5 a `presumed-lost` record
resolves its handle by the FALLBACK clause to a runtime `subject`, so for a `runtime-id`
family member it **binds to nothing and lands in epoch 2** - the member renders declared
while its own loss record renders unattributed. Two true statements, no Law-1 hole, but the
board fails to say the one thing the dispatcher most needs (*this member died*), which is a
Law-3 cost and is named as such in §6. **The fix is D8's, not a new rule:** if a
`presumed-lost` record inherits the `task_id` its `dispatched` sibling was stamped with,
the epoch collapses to 3 and the loss renders on the member row. That inheritance question
is an explicit D8 obligation (§5.7) and a vector (V14), because a producer that stamps only
`dispatched` and `returned` would leave exactly this hole open.

### 5.3 What the trains lane renders

Every declared member renders, **in declared order**, titled by its identity - which is the
shop handle for new manifests and the legacy dispatch subject for the six landed ones.
A member is never omitted from the consist for lack of a record; "no record" is a *state*
of a rendered row, not a reason to stop rendering it.

**`[DR1-M3, folded]` - the ordering rule is KEPT and now PINNED, not deleted.** Rev 1 stated
"in declared order" as prose in the behavioural half while §5.6 pinned no ordering vector
and no consist-membership vector at all, which fires §0's own invited test: ordering is one
of the four words §0 names as format. The reviewer offered both remedies; **I take the
harder one, because dropping the rule would silently discard the thing that makes a consist
a consist.** A train is an ordered thing - car, its gate, the next car, its gate - and the
unit-rule FLAG deferred in §7 is unstatable without adjacency. So **V12 pins ordered consist
membership** and the rule stops living in prose. §5.6, not this paragraph, is now its owner.

**The wire cannot express this today, and that is a §8 obligation rather than a footnote
`[DR1-M2, folded]`.** Two landed facts collide with the sentence above:

- `board/assemble/assemble.go:107-113` splits members into `Cars` (bound) and
  `DeclaredNotObserved` (unbound). **A member goes into one array or the other, so the
  declared interleaving is destroyed at the wire** - unrecoverable downstream, whatever the
  view does.
- `schema/yard-snapshot.schema.json:137` requires `["subject","role","state","at"]` on every
  `cars` item. **An unbound member has neither `state` nor `at`**, so it cannot legally enter
  the array that preserves order.

Therefore D6 is **not implementable without a wire change**, and the design owes the shape
rather than leaving a car to improvise it: **one ordered `cars` array carrying every declared
member**, with `state` gaining a value for the unbound case and `at` relaxed to optional
(absent renders absent - Law 1, and `taskId`/`recordDir` already set the precedent for
optional-when-unknowable at `yard-snapshot.schema.json:128-135`). The two-array split then
collapses, which is also what retires the false sentence in §5.3a. **Naming the alternative
so the reviewer can reject my choice:** keeping two arrays and adding an explicit
`declaredIndex` to each entry would preserve order without relaxing the required set - more
wire, more to keep in sync, and it leaves the unbound member outside the consist a human
reads. I chose the single array; §10 Q7 puts the trade to the reviewer.

### 5.3a The rendered sentence - the last hop, which rev 1 never reached

**`[DR1-M2, folded]`.** Rev 1 traced D6's requirement to the wire field and stopped. The
falsehood this whole design exists to kill is not a JSON key; it is a sentence a human
reads, and it lives at **`board/web/js/dom-writer.js:481`**, which renders the array as the
literal string:

```
declared, not yet observed: <names>
```

Measured (PR-1): that sentence appears about `d87-car-r1` **while the same snapshot carries
that handle's `returned` record**. "Not yet observed" is precisely the claim D6 forbids the
board from making - it is not "no record bound", it is an assertion about the world. The
wire's own description is false in the same breath: `schema/yard-snapshot.schema.json:143`
says *"Manifest members with no matching store records"*, and there IS a matching record.

**So D6 is a RENDERED-STRING requirement, not only a wire requirement.** The board may say
what it can prove - *no departure bound* - and may not say what it cannot know. Three
artifacts must change together and §8 names an owner for each: the assembler, the wire
schema's field and description, and `board/web/js/dom-writer.js` plus its tests under
`board/web/test/`. Rev 1's §7 scoped out renaming the *wire field* and called it named-so-not-assumed-done; **the view string is a different artifact and was named nowhere.**

*Scope note carried into §8: #84 (freight) is live in another worktree and may be editing
`board/web` files. This design NAMES owners; it edits no board file.*

This is the requirement #85 becomes under this design, and it is strictly wider than #85's
current text: #85 asks that a `task_id`-only member reach `declaredNotObserved`; D6 asks
that no member ever fail to reach a surface, whatever keys it carries, **in declared order,
under a sentence the board can back.**

### 5.4 What the dispatches lane renders

For a record that resolves to no member: the row keeps its existing `assigned:false`,
**and** the board raises a condition naming the count and the subjects. #86 becomes: a
member's identity is its row title wherever the row appears, so a bound in-flight row is
titled by its plan rather than by a runtime hash.

**`assigned` is NOT "unchanged", and rev 1's wording hid the change that this whole train
started over `[DR1-m3, folded]`.** `board/assemble/assemble.go:108` sets
`assignedSubjects[m.Subject]` from **the MEMBER's identity**. Under D5 the member's identity
is a shop handle that no runtime-id record's subject will ever equal, so leaving that line
alone would mark every bound runtime-id dispatch unassigned forever. **It must be rekeyed to
the BOUND RECORD's subject**, and the visible consequence is that `assigned` flips
false-to-true for every runtime-id member that binds. Measured in PR-1: the shape-B
runtime-id records render `"assigned":false` in the same snapshot where the minted-id
records render `"assigned":true` - the whole difference being whether the member's identity
happened to equal a record subject. #76's own probe comment names **"92 unassigned"** as one
of the three headline symptoms this work exists to fix, so calling this "unchanged" was the
opposite of true. §8's assembler row now carries the rewire explicitly.

The same rekeying applies to `memberClaims` (`assemble.go:107`), which feeds the existing
`manifest-membership-collision` condition: keyed by member identity it would stop detecting
two trains claiming one *record*, which is the thing it exists to detect. D9 generalises
that condition rather than replacing it.

### 5.5 The join - stated once, owned by the executable artifact

The rule in one sentence, so the reviewer can check §5.6 against it: **a record binds to a
member when the record's resolved handle equals the member's resolved identity, where each
side resolves `task_id` first and falls back to `subject`.** The fallback is what keeps the
legacy corpus rendering; it is a legacy clause, not a general escape hatch.

**Everything else about this rule - precedence proof, ambiguity, duplicates,
normalisation, the empty case - is FORMAT and lives in §5.6.** I am deliberately not
elaborating it here, because that is the mistake this rung exists to avoid.

Two facts the rule was checked against, both measured:

- **The legacy corpus is safe.** PR-4: the six landed manifests declare 10 distinct member
  subjects, all runtime ids; those subjects own 16 `returned` records; **0 carry
  `task_id`.** So the fallback clause, not the primary clause, serves every one of them,
  and it will keep doing so - runtime ids are not reissued.
- **The rule is symmetric.** Both sides resolve by the same two-clause precedence, so there
  is one rule to test and one place it can be wrong.

### 5.6 The format half - what the executable artifact must contain

**Deliverable, not built here.** A schema delta plus conformance vectors in the landed
`schema/vectors/` pattern plus red-first tests.

**Every obligation §0 defers must land in a vector, and after round 2 all six do
`[DR1-m4, folded]`** - rev 1 deferred six and pinned five, which is the carrier rule's own
failure shape inside one document. The mapping, so a reviewer can check it rather than
trust it:

| §0 defers | Pinned by |
|---|---|
| the member's identity key | V1, V2, V11 |
| the `required` set | V3, V4 |
| the record-to-member join rule | V5, V6, V12 |
| its precedence | V7 |
| ambiguity and duplicates | V8, V9 (+ §10 Q5 for the intra-manifest case) |
| **what "amendment" may and may not touch** | **V13** *(the one rev 1 left homeless)* |

The vector set must pin, at minimum:

| # | Vector | Must pin |
|---|---|---|
| V1 | `member-identity-taskid` | a member carrying `task_id` + `role` validates; identity resolves to `task_id` |
| V2 | `member-identity-legacy-subject` | a member carrying `subject` + `role` (the landed corpus shape) validates; identity resolves to `subject` |
| V3 | `member-identity-neither` | a member carrying `role` only is REJECTED |
| V4 | `member-identity-no-role` | `role` remains unconditionally required under every identity combination |
| V5 | `join-taskid-to-returned` | a returned record whose `task_id` equals a member's `task_id` binds, though their `subject`s differ |
| V6 | `join-legacy-subject` | a legacy member binds to a record carrying no `task_id` at all |
| V7 | `join-precedence` | when a record carries BOTH keys, the resolved handle is `task_id`; the same for a member carrying both |
| V8 | `join-ambiguous-handle` | two records resolving to one handle produce a DISCLOSED condition and both render - never a silent winner (D9) |
| V9 | `join-unattributed-dispatch` | a record binding to no member is counted and disclosed (D7) |
| V10 | `join-unbound-member` | a member binding to no record renders under its identity (D6) |
| V11 | `member-identity-both-keys` | a member carrying both keys validates and resolves by V7's precedence - the shape a transitional manifest could take |
| **V12** *(new, `[DR1-M3, folded]`)* | `consist-ordered-membership` | **the consist contains EVERY declared member, exactly once, in DECLARED ORDER, with bound and unbound members interleaved as the manifest declares them.** This is the pin that takes §5.3's ordering rule out of prose. Fixture: a 4-member manifest declared car/gate/car/gate where members 1 and 3 are bound and 2 and 4 are not - a two-array wire cannot satisfy it, which is the point |
| **V13** *(new, `[DR1-m4, folded]`)* | `amendment-scope` | **what a manifest amendment may and may not touch** - the sixth obligation §0 deferred and rev 1's V-set pinned nowhere. A superseding manifest MAY add, remove or reorder members and MAY change a member's `role`/`gate`; it MUST NOT change an existing member's identity. Two directions: an amendment that grows the consist supersedes cleanly; **an amendment that rewrites a member's `task_id` is REJECTED** - that is the mutation D2 forbids, and without this vector nothing stops a future producer reintroducing shape A's amendment |
| **V14** *(new, `[DR1-m4, folded]`)* | `presumed-lost-binding` | a `presumed-lost` record's handle resolution and binding, both directions: **without** an inherited `task_id` it falls back to `subject` and lands its member in epoch 2 (today's honest behaviour, pinned so it is a known state rather than a surprise); **with** D8's inheritance it binds and the loss renders on the member row. The killed-session class the owner's ruling names as the manifest's purpose gets an executable landing rather than a sentence |

Every one of V5-V10 and V12/V14 is a behavioural claim about code that does not exist, so
each lands **red first** and fails for its own stated reason before any board change.

**Non-vacuity note the implementing car must honour (#40):** V6, V10 and V13 would pass
today for the wrong reason - V6 because the current join already matches subject-to-subject;
V10 vacuously if the member happens to carry `subject`; **V13 vacuously because no amendment
mechanism exists to violate it yet.** V12 is the reverse case and the most valuable: it
**must be red on arrival** against the current two-array wire, and a V12 that passes before
the wire changes has been written to the wire instead of to the requirement. Each must be
fault-injected once and observed red, or it is a guard nobody watched fire.

### 5.7 The in-flight wire (D8) - specified, not built, and separable

**Measured (PR-5, corrected and re-derived at round 2 `[DR1-M1, folded]`), over 98 captured
live `PostToolUse:Task` payloads: there are TWO `tool_input` key sets, not one.**

| Family | Key set | Count | Identity keys it carries |
|---|---|---|---|
| Claude | `description, model, prompt, subagent_type` | 78 | `description` only; **no `name`** |
| Copilot compat | `agent_type, description, mode, model, name, prompt` | 20 | `description` **and** `name` (the shop-minted id, verbatim) |

**`description` is populated on 98/98, 98 distinct, across BOTH families** - which is a
stronger premise than rev 1's single-family claim, and it is why DR1-M1 was a correction
rather than a redesign. Observed Claude values: `Design #87 member identity`,
`Car #76 train manifest minting`, `Review #79 probe pinning`. It is prose today, not the
handle.

**Rev 1 published the single-key-set claim in three places and it was false by 20 of 98.**
An implementer taking it literally builds a Claude-only adapter inside a repo whose #47
design exists to be family-agnostic (`schema/vectors/adapter/README.md:12-14`). The
corrected shape is per-family and D8 must be specified that way:

- **Copilot:** no convention needed at all. `tool_input.name` already carries the shop-minted
  id verbatim and the producer already reads it (`scripts/Produce-Artifact.ps1:187-190`,
  `subject_basis = minted-id`). The in-flight epoch is already closed for this family, which
  is P8 restated at the wire.
- **Claude:** `description` is the only conductor-authored key, so the convention applies
  HERE and only here.

The change is a convention plus a read: the conductor puts the task-id in `description`,
and the producer stamps it as `task_id` on the `dispatched` record. This is not the
mechanism C3R-1e ruled against - that ruling forbids inventing a value by parsing
`tool_input.prompt` for a field that does not exist; this reads a field that does.

**D8 must also rule on `presumed-lost` `[DR1-m4, folded]`:** a stamp that fires only on
`dispatched` leaves the killed-session record unbindable (§5.2). The obligation is that a
`presumed-lost` record carries the same handle its `dispatched` sibling was stamped with -
pinned by V14, because this is the one kind whose whole purpose is the case where no agent
survives to echo an envelope.

**The mirror is made checkable rather than tolerated (Law 6).** The dispatched record's
`task_id` would come from the CONDUCTOR's label; the returned record's already comes from
the AGENT's envelope echo. Two independent observations of one handle. A mismatch means the
two disagree about which dispatch this is, and D9's disclosure covers it. That checkability
is the reason the second copy is acceptable; without the check it would be an ordinary
drifting mirror and I would not propose it.

### 5.7a D8 re-imports P7's vigilance, and the design owes an argument, not a silence

**`[DR1-m5, folded]`.** P7 kills both rejected shapes because *"a mechanism whose correctness
depends on a human remembering a step per dispatch is vigilance-tier."* **D8 is exactly such
a convention** - the conductor must write the handle into `description` on every Claude
dispatch - and rev 1 never acknowledged the symmetry. Stated plainly now, and then defended:

**The defence, and it is a real distinction rather than a rescue.** What P7 condemns is not
vigilance as such; it is *vigilance whose failure mode is a falsehood*. Compare the three
failure modes when the human forgets:

| Mechanism | Human forgets | Board says |
|---|---|---|
| Shape B amendment | subject keeps the handle | **"declared, not yet observed"** about a returned member - a Law 1 falsehood (PR-1) |
| Shape A amendment | member has no subject | member vanishes, zero conditions - Law 4 silent loss |
| **D8 convention** | `description` carries prose | member stays in epoch 2; the dispatch renders unattributed **and D7 raises a condition** |

D8 fails **loud and true**; the shapes fail silent or false. That is why D8 is acceptable
where they were not - and it holds only because D7 exists, which is why D7 is not optional
garnish. **D5, the part that matters, is not vigilance at all:** the returned epoch binds
from data the agent itself echoes, with no human in the loop.

**The harder half, which the review is right that rev 1 never faced: `description` is
operator-chosen free text with no schema, no pattern, and no validation anywhere.** Its
98/98 uniqueness is an accident of prose variety, not a property. **My own capture proves
the hazard: `tool_input.name = 'probe-dup-name'` appears on two distinct dispatches
(PR-5, 19 distinct names across 20 Copilot launches)** - an operator-chosen launch label
reused, which is the round-3 verdict's DR-6 defect measured live in this shop. `description`
is exactly as operator-chosen as `name` was.

**So D8's collision risk lands in D9, and the link is drawn here rather than left implied:**
two dispatches stamped with one handle is precisely V8's ambiguous-handle case - both render,
a condition names the handle and both subjects, no winner is picked. D9 was designed for
crash re-dispatch; it covers conductor typo-collision by the same rule, and that coverage is
a REQUIREMENT of accepting D8, not a happy accident. **What D9 does NOT give is prevention.**
If the owner wants prevention, the honest form is a producer-side check that the handle
about to be stamped is not already live in the store - named here, not designed here, and
routed as part of §10 Q2 because it is the same contract decision.

**Deliberately separable:** if the owner refuses the convention (§10 Q2), D1-D7 and D9 all
stand and the board remains honest - epoch 2 simply persists for the Claude family (never
for Copilot, which needs no convention) until some other wire is found.

---

## §6 - Failure modes

| Failure | What the system does | Law honoured |
|---|---|---|
| A member has no record at all (planned, never launched, or a killed session) | Renders under its identity, state *declared, no departure bound*. The completeness assertion the owner's ruling asked for. | Law 1, Law 4 |
| **Unknown: a dispatch exists that may or may not be this member's** | The member renders as declared and the dispatch renders as unattributed, **with a disclosed condition**. The board does not pair them and does not imply the member is idle. Two true statements, no invented third. | Law 1 (*"Unknown states render AS unknown"*), Law 6 |
| Two records resolve to one handle (re-dispatch after a crash) | Both render; a condition names the handle and both subjects. No recency winner. **Measured: today this raises zero conditions** (PR-3) - the guard does not exist and must be built with V8. | Law 6 |
| A record resolves to no member | Counted and disclosed (D7). | Law 4, Law 3 |
| A member's handle and a record's handle differ by a conductor typo | The member stays unbound and the record stays unattributed - **two loud surfaces, not one silent one.** Under shape B the same typo produced an invisible pairing failure. | Law 4 |
| Conductor and agent disagree on the handle (D8's two sources) | Disclosed as ambiguity (§5.7). | Law 6 |
| A manifest declares two members with the same identity | Schema/validator rejects, or the board discloses - **decided by the format half, V-set gap flagged in §10 Q5, not resolved here.** | Law 6 |
| The manifest payload is unreadable | Unchanged: existing `manifest-payload-unreadable` condition. | Law 4 |
| A legacy manifest meets a modern record for the same subject that carries a `task_id` | The precedence clause would prefer `task_id` and the legacy member would unbind. **Measured impossible for the landed corpus** (PR-4: 0 of 16), and structurally unreachable because runtime ids are not reissued. Recorded here rather than dismissed, and V7 pins the precedence so a future change to it reds. | NO-BACKFILL, Law 1 |
| **The RENDERED SENTENCE overclaims `[DR1-M2, folded]`** - the board holds a member's returned record and the view still prints *"declared, not yet observed"* | **This is the live defect, not a hypothetical:** measured in PR-1 at `board/web/js/dom-writer.js:481`, with `schema/yard-snapshot.schema.json:143`'s description (*"members with no matching store records"*) false in the same breath. §5.3a makes D6 a rendered-string requirement and §8 gives the view file an owner. Until it lands, the falsehood is LIVE on the board today for any manifest whose members are shop handles. | Law 1 - and the row rev 1 was missing, because it traced its own requirement to the wire and stopped |
| **A `presumed-lost` record for a `runtime-id` member `[DR1-m4, folded]`** | It carries no `task_id` by construction (`scripts/Produce-Artifact.ps1:358`), so §5.5 resolves its handle to a runtime `subject` and it binds to no member: the member renders declared (epoch 2) while the loss record renders unattributed and D7 discloses it. **Two true statements and no Law-1 hole - but the board fails to say the one thing that matters most, that this member DIED.** That is a Law-3 cost, named rather than hidden, and it is the killed-session case the owner's ruling calls the manifest's purpose. Closed by D8's inheritance obligation (§5.7) and pinned both ways by V14. **Measured: 0 `presumed-lost` records exist today (PR-7), so this is undesigned rather than live-broken.** | Law 1 honoured, **Law 3 knowingly under-served** |
| A member is declared, removed by a superseding manifest, and its dispatch is already in flight | The removed member stops rendering in the consist (the current manifest is the plan of record, and the fold already picks the winning manifest); its record flips to unattributed and D7 discloses it. Behaviour is inherited unchanged from the fold's supersession, and it is honest - **but rev 1's P4 named only consist GROWTH and had no row for shrinkage.** Named now; V13 pins that an amendment may remove a member, which is what makes this state legal rather than accidental. | Law 4 |

---

## §7 - Out of scope

| Item | Trigger that brings it back |
|---|---|
| The unit-rule FLAG (a returned car whose paired gate never launched) | Needs an explicit pairing convention on the member (`for: <handle>`), never member order. Trigger: the owner asks for it once member identity is landed. **D1's stable handle is what makes it expressible at all** - a runtime id could not be named in a plan. |
| Freight (#84) | Independent; in flight in another worktree. This design touches none of its files. |
| `board/fold` | Measured (#87 substrate): manifests do not ride the fold's dispatch-lifecycle machinery. Untouched. |
| Building the D8 wire | Its own ticket. Trigger: §10 Q2's owner ruling. |
| Retroactively adding `task_id` to the six landed manifests | **NO-BACKFILL. Never.** The fallback clause exists so that history keeps rendering as history. |
| Stamping `task_id` on `minted-id`-family records so the fallback clause becomes legacy-only | Hygiene, not correctness. Trigger: the D8 wire landing, which is when one universal handle field becomes achievable. |
| ~~Renaming the wire's `declaredNotObserved` field~~ **MOVED IN SCOPE at round 2 `[DR1-M2, folded]`** | Rev 1 parked this and called it "named so it is not assumed done". That was wrong: the field, its schema description, and **the human sentence at `board/web/js/dom-writer.js:481`** are where D6's requirement actually lands. All three are now §8 obligations with a named owner. The out-of-scope row is kept struck rather than deleted, so the reversal is legible. |
| A producer-side check that a handle about to be stamped is not already live in the store (D8 collision PREVENTION, as opposed to D9's disclosure) | §5.7a names it; it is the same contract decision as D8 itself. Trigger: §10 Q2's owner ruling, if the owner wants prevention rather than disclosure. |

**Blocking test (§2c promotion):** the D8 wire does not land without a red-first producer
test over the captured launch-payload shape. If that test cannot be made to fail for its
stated reason, D8 is withdrawn and epoch 2 becomes permanent for the `runtime-id` family -
an honest outcome, disclosed by D7, not a defect.

---

## §8 - Contracts touched

| Document / artifact | What changes | Owner |
|---|---|---|
| `schema/starcar-manifest.schema.json` | `members`: `required: ["role"]` + `anyOf` over the two identity keys; `task_id` added with identity semantics; **`subject`'s description amended to say it is the LEGACY identity, never written on a new member** | schema car (same commit as the spec amendment) |
| `docs/specs/2026-07-23-yard-board-spec.md` | **§7b amendment block** restating YB-1's member contract. This is R1-M3's remedy and is non-negotiable under the same-commit rule | same car, SAME COMMIT as the schema change |
| `docs/contracts/gating-matrix.md` | A row for the unattributed-dispatch condition (D7) and one for the ambiguity condition (D9) - both new truth surfaces | the car that builds them, same commit (R1-m4's class) |
| `board/assemble/assemble.go` | The join (D5); the no-drop rule as an **ordered single consist** (D6/V12); the two conditions (D7/D9); **and the `assigned`/`memberClaims` rekey at `:107-108` from MEMBER identity to BOUND-RECORD subject `[DR1-m3, folded]`** - omitted in rev 1, and it is the "92 unassigned" symptom #76 was filed for | the #85/#86 car - **coordinate with #84, which may be editing board files** |
| `schema/yard-snapshot.schema.json` | **`:137`'s `required: ["subject","role","state","at"]` on `cars` items must relax** - an unbound member has neither `state` nor `at`, so D6 is unimplementable without it `[DR1-M2, folded]`. Plus the ordered-consist shape (V12), the `declaredNotObserved` field's retirement or redefinition, **and `:143`'s description, which is false whenever a bound record exists** | same car, same commit as the assembler |
| **`board/web/js/dom-writer.js` (`:481`) and `board/web/js/render.js` (`:243-250`)** `[DR1-M2, folded]` | **The rendered sentence `declared, not yet observed: <names>` is the surface where the falsehood actually reaches a human**, and rev 1 named no view file at all. It must say only what the board can back (*no departure bound*), and the consist must render in declared order. `board/web/js/render.js:247-248`'s train-terminality rule is checked and stays correct as written (`isTrainTerminal` returns false while `declaredNotObserved` is non-empty, so an unbound member keeps a train non-terminal - which #67 already ratified) - named here so a later round does not re-open it, and flagged because collapsing the two arrays per §5.3 forces this predicate to be rewritten against the new shape rather than deleted | **the #85/#86 car, same commit - explicitly the SAME car as the assembler and wire change, because a wire change without the view leaves the false sentence rendering off a renamed field.** Coordinate with #84 |
| **`board/web/test/**` (209 node tests, incl. `dom-writer.test.js`, `render.test.js`)** | Red-first coverage for the rendered-string change and ordered consist. **Rev 1 named no owner for 209 tests** | same car |
| **`schema/vectors/adapter/copilot-launch-minted-from-name.json:14`** `[DR1-M1, folded]` | The landed vector declares `tool_input` as `{name, agent_type, prompt}` - **no `description`** - while all 20 live Copilot payloads carry one (PR-5). A car building D8 against this vector concludes the Copilot family cannot carry a handle. **Reconcile the vector to the measured live shape, or record in its provenance line why it deliberately omits the key** | the D8 producer car, gated on §10 Q2; the vector is `#47` territory so the reconciliation is disclosed to that ticket's owner rather than done silently |
| `schema/vocab/` | **Untouched.** No new vocabulary; the conditions are codes, and `store.RegisterForCode` already owns their register | - |
| `scripts/New-TrainManifest.ps1` (on branch `car/tooling-76`, unmerged) | Its identity handling changes; its sealing, dual-schema pre-write validation, supersession-not-in-place amendment and worked commands were all verified sound by the round-1 reviewer and are reusable | the #76 car, after this design is approved |
| `docs/contracts/state-ledger.md` | **Not touched** - this design adds no mutable service state (matches N5 of the round-1 verdict) | - |
| Issues #85, #86 | Both reframed by D6/D3; each needs its text corrected to the shape it becomes | conductor, on approval |

---

## §9 - Cost

| | |
|---|---|
| This dispatch | 1 (design author, Opus) |
| Design review | 1 (adversarial, Opus) |
| Size class | **small** (2 dispatches) for the design rung |
| Downstream, if approved | executable format artifact + tests (1 car + 1 review); board join/render (1 car + 1 review); D8 wire (1 car + 1 review, gated on §10 Q2). Estimated **medium** overall |
| Owner approval | recorded on #87 before this dispatch (design plus one adversarial review, ruled 2026-07-27) |

---

## §9b - Disposition of the prior round

**Round 2 (this revision): every finding from
`artifacts/reviews/2026-07-27-design-87-review-r1-REJECT.md` (design review round 1,
REJECT, 3 Major / 5 Minor / 8 Notes).** No blanks; nothing adopted silently and nothing
dropped.

| Prior item | Kind | Disposition | Where |
|---|---|---|---|
| **DR1-M1** - PR-5's key-set measurement is false; §2c's Copilot row is falsified by the file PR-5 read | finding | **ADOPTED IN FULL, no appeal - the claim was false and I published it three times.** Re-derived myself rather than copying the review's numbers: 98 payloads, **two** key sets (78 Claude / 20 Copilot), `description` populated 98/98 across both families. Root cause named rather than smoothed: I sampled the tail of the file and generalised - a reading dressed as a measurement, in the section whose own opening promises the opposite. Corrected at all four locations (§1 constraint row, §2b PR-5, §2c, §5.7), §2c's Copilot row flipped from "unverifiable" to measured, and the finding's own observation folded - **the correction STRENGTHENS D8**, which is now specified per-family. | §1, §2b PR-5, §2c, §5.7, §8 |
| **DR1-M2** - the Law-1 requirement is traced to the wire and never to the surface a human reads; §8 names no view file | finding | **ADOPTED IN FULL.** This is the sentence check applied to my own document and I failed it. New §5.3a owns the last hop (`board/web/js/dom-writer.js:481`); D6 restated as a **rendered-string** requirement; §8 gains the view file, `render.js`, and `board/web/test/**`'s 209 tests each with a named owner; the `yard-snapshot.schema.json:137` required-set collision is named with a proposed shape and an alternative routed to §10 Q7; §7's out-of-scope row is struck rather than deleted so the reversal stays legible; §6 gains the row. | §5.3, §5.3a, §6, §7, §8, §10 Q7 |
| **DR1-M3** - §0's own test fires: an ORDERING rule sits in prose outside §5.6, pinned by no vector | finding | **ADOPTED, taking the HARDER of the two remedies offered.** The reviewer allowed dropping "in declared order"; I keep the rule and pin it, because a consist without order is not a consist and §7's deferred unit-rule FLAG is unstatable without adjacency. **V12 (`consist-ordered-membership`)** is the new owner, and it is specified to be **RED ON ARRIVAL** against the two-array wire - a V12 that passes before the wire changes was written to the wire instead of to the requirement. | §5.3, §5.6 V12 |
| **DR1-m1** - mis-citation: `doc-map.md:52` is the `docs/design/*` row; the spec axis is `:53` | finding | Adopted; corrected to `:53` with the axis text quoted. The reviewer's note that `CitationResolverPolicy.Tests.ps1:12-18` declares this class outside its binding checks is recorded in-line, so no future reader mistakes a green gate for a cleared citation. | §1 |
| **DR1-m2** - §2c parks two desk-provable facts in the probe list | finding | **ADOPTED, and re-derived rather than accepted on report.** My own scan: 96 records carry `task_id`, **96 distinct**, **0 shared by two subjects**, 0 uppercase, 0 whitespace, 0 case-collisions; 83 dispatched with 0 `task_id`; 0 `presumed-lost`. Landed as **PR-7**; §2c shrinks from six rows to four with the discipline stated. **§10 Q3 is CLOSED as settled.** D9/V8 is untouched - the design still declines to assume rarity. | §2b PR-7, §2c, §10 Q3 |
| **DR1-m3** - §5.4's "unchanged for bound records" is imprecise about `assigned` | finding | **ADOPTED, and it was worse than imprecise - it hid the change this train was filed for.** §5.4 now states the `assignedSubjects` rekey at `assemble.go:108` explicitly, with the false-to-true flip and the "92 unassigned" symptom named; `memberClaims` at `:107` needs the same rekey and would otherwise stop detecting what it exists to detect. §8's assembler row carries both. | §5.4, §8 |
| **DR1-m4** - §0 defers six items, §5.6 pins five; `presumed-lost` named once and never traced | finding | **ADOPTED, both halves.** V13 (`amendment-scope`) lands the sixth deferred obligation - what an amendment may and may not touch - and pins that rewriting a member's identity is REJECTED, which is what stops a future producer reintroducing shape A's mutation. `presumed-lost` is traced through §5.2 (it falls to epoch 2 by the fallback clause), §6 (its own row, Law 3 knowingly under-served), §5.7 (D8 must rule on inheritance) and V14. §6 also gains the consist-SHRINKAGE row the reviewer noted as unenumerated. | §5.2, §5.6 V13/V14, §5.7, §6 |
| **DR1-m5** - D8 re-imports P7's vigilance and the design never says so | finding | **ADOPTED - the argument is made, against my own premise, in new §5.3a's sibling §5.7a.** The symmetry is stated first and defended second: what P7 condemns is vigilance whose failure mode is a *falsehood*, and a three-row table compares shape B (Law 1 falsehood), shape A (Law 4 silent loss) and D8 (loud, true, D7-disclosed). The defence holds only because D7 exists, which is said out loud. **My own capture's `probe-dup-name` collision is quoted as evidence against me**, and D8's collision risk is wired explicitly to D9/V8, with prevention-versus-disclosure routed to §10 Q2. | §5.7a, §7, §10 Q2 |
| *Rulings in the review's favour, recorded so they are not re-opened:* **Q6 on §5.5** (keep the one-sentence join), **Q4** (the fallback earns its price), §9b completeness, §2b as a legitimate template extension, §8's `RegisterForCode` and vocab-untouched claims, §7's `board/fold` scoping, and PR-1/2/3/4a/4b/6 as measurements | **rulings** | **ACCEPTED; none re-litigated in this revision.** §5.5's sentence is unchanged. The reviewer's N1-N8 notes required no action and none was taken beyond N7's train-terminality check, which is now named in §8's view row so a later round does not re-dig it. | throughout |

**Round 1: every finding and every ruling from
`artifacts/reviews/2026-07-27-tooling-76-review-r1-REJECT.md` and the owner's #76 ruling.**

| Prior item | Kind | Disposition | Where |
|---|---|---|---|
| **R1-M1** - the `required` relaxation is not demonstrably necessary; a measured alternative (shape B) serves the design without it | finding | **APPEALED, with new measurement.** The reviewer's shape-B probe had no matching records in its store, so the shape was measured only in the epoch where it cannot be wrong. Placed in front of a real `runtime-id` dispatch (PR-1) it renders a returned member as `declaredNotObserved` with zero conditions - a Law 1 falsehood, a worse class than shape A's silent drop. The relaxation IS necessary, for a reason the car never gave: NO-BACKFILL forces two identity keys to coexist. **The finding's core charge stands and is adopted** - the car widened without examining the alternative. | §2 P1, §4 D4 |
| **R1-M2** - a manifest member's `task_id` is read by nothing; in-flight naming unfixed and untracked | finding | **ADOPTED, and promoted to the design's centre.** #86 tracks it. D5 makes reading the member's identity the join; D8 addresses the in-flight half the reviewer identified as the owner's actual goal. | §4 D5/D8, §5.4 |
| **R1-M3** - the owning spec left contradicting the contract | finding | **ADOPTED as a binding same-commit obligation.** §8 names the §7b amendment block and the car that owns it. | §8 |
| **R1-m1** - commit failure path reports a confidently wrong cause | finding | Adopted; producer-script hygiene, unaffected by this design, carried to the #76 car. | §8 (script row) |
| **R1-m2** - `ValidatePattern` is case-insensitive; the "mirrors" claim is misattributed in two files | finding | Adopted; carried to the #76 car. Also feeds §10 Q3 (case-sensitivity of handles). | §8, §10 Q3 |
| **R1-m3** - doc claims a `task_id`-mandatory invariant the code does not enforce | finding | Adopted. Under D3/D4 `task_id` is mandatory for NEW members only, which is a statement no schema can make; §8 requires the description to say exactly that and no more. | §8 |
| **R1-m4** - a new silent-loss path on no gated-surface document | finding | Adopted and widened: D7 and D9 each get a gating-matrix row in the same commit as the code. | §8 |
| **R1-m5** - the in-code disclosure never cites the ticket it produced | finding | Adopted; carried to the #76 car. | §8 |
| **Owner ruling: manifest is a PLAN, amended by supersession, the board's product is the DELTA** | **ruling** | **ADOPTED in full, and D2 is its strict reading.** A plan that names a runtime id is no longer purely a plan. Supersession survives for membership changes, which is what the six landed manifests demonstrate (1-2-4-6-8-10 members over six records). | §4 D1/D2/D4, §5.1 |
| **Owner ruling: shape A rejected** (widens the contract to enable a state the board silently discards) | **ruling** | **ADOPTED on the reason, PARTIALLY APPEALED on the remedy.** The defect was the invisible state, not the `anyOf`. D4 keeps the construct and D6 removes the invisibility; the construct itself was measured by the reviewer to enforce correctly across seven directions. | §4 D4/D6, §10 Q1 |
| **Owner ruling: shape B rejected** (a placeholder in an identity field) | **ruling** | **ADOPTED, and the reason strengthened.** Measured, shape B's cost is not a temporary placeholder but a confident falsehood whenever amendment is skipped. | §2 P1, §4 D3 |
| **Owner ruling: member identity goes through the design rung; the #76 fix cycle is STOPPED** | **ruling** | Adopted; this document is its output. | whole document |
| **Owner ruling: #85/#86 stay filed but unbuilt until the design rules** | **ruling** | Adopted. §5.3/§5.4 state what each becomes; §8 requires their text be corrected before either is built. | §5.3, §5.4, §8 |
| **Note N3** - #79's probe is not a guard against this class | note | Adopted. §5.6's V-set is the guard, and V6/V10 carry an explicit non-vacuity obligation because they are the two that could pass for the wrong reason. | §5.6 |
| **Note N5** - the state ledger is not made stale | note | Adopted and re-checked: this design adds no mutable service state. | §8 |

---

## §10 - Open questions for the reviewer

Real soft spots, each with the cost of the answer.

**Q1. Is D2 too strict? Should the manifest record the runtime id AT ALL, as enrichment?**
D2 forbids it entirely. A weaker form is defensible: the conductor may add an
`observed_subject` to a member as corroboration, explicitly NOT identity, never joined on.
**Cost if D2 is right and we allow it anyway:** a second copy of a derivable fact, drifting
silently, Law 6 - and the amendment step returns with all of P7's vigilance. **Cost if D2
is wrong:** the shop loses a durable conductor-authored record of which runtime served which
plan slot, recoverable only from records. I chose the strict form; I am not certain, and
this is the decision most likely to be wrong.

**Q2. Does the owner accept the task-id on `tool_input.description`, and does the owner want
collision PREVENTION or only disclosure?** (Owner ruling, not a review call - flagged here so
the reviewer does not adjudicate it.) It is a dedicated key, populated on **98/98** measured
launches **across both families**, and not the free-text prompt C3R-1e ruled against. But it
IS a human-facing label being given a machine meaning; the conductor currently writes prose
there; and **it is operator-chosen free text with no schema or pattern - my own capture shows
an operator-chosen launch label reused across two dispatches (`probe-dup-name`, PR-5).**
Note the scope narrowed at round 2: the convention is needed for the **Claude family only**,
because Copilot's `tool_input.name` already carries the shop id verbatim. **Cost of yes:**
epoch 2 closes for Claude; one more hand-written copy of the handle, made checkable by §5.7,
with collisions disclosed by D9/V8. **Cost of no:** epoch 2 persists for Claude; in-flight
rows stay hash-titled; D7's disclosure carries the honesty. **The second half is the newer
question:** D9 discloses a duplicated handle but does not prevent one, and prevention would
be a producer-side liveness check (§7). The design stands under either answer, which is why
D8 was made separable.

**~~Q3. Does the join need canonicalisation?~~ CLOSED - SETTLED BY MEASUREMENT `[DR1-m2,
folded]`.** Rev 1 left this open because *"I did not enumerate"* - which was the defect, not
the question: it was one command away the whole time. Enumerated at round 2 (PR-7, my own
scan, not the review's numbers): **96 records carry `task_id`, 96 distinct values, 0 shared
by two subjects, 0 uppercase, 0 whitespace, 0 case-insensitive collisions.** **Ruling: exact
string equality is sufficient; §5.6 needs no canonicalisation vector.** The question is kept
struck rather than deleted so the reader sees it was answered rather than abandoned.
*Bounded, not eternal:* the corpus is 96 handles deep and days old, and nothing structurally
prevents an uppercase handle. If one ever appears, V7's precedence is unaffected but a
canonicalisation vector becomes owed - and D9/V8 already disclose the collision rather than
resolving it silently, so the failure stays loud in the meantime.

**Q4. Is the fallback clause in §5.5 worth its price?** It exists solely for six landed
manifests and 10 dispatch subjects. The alternative - `task_id` only, and accept that the
`train:board-v0` records stop rendering their consist - is simpler by one clause forever.
I ruled that Law 4 forbids it (a rendered train silently losing its cars), and read
NO-BACKFILL as covering rendering and not only validation. **That reading is mine, not the
doctrine's literal text, and it deserves attack.** **Cost if I am wrong:** one unnecessary
clause carried permanently, and a precedence rule (V7) that would not otherwise be needed.

**Q5. Where should the duplicate-identity-within-one-manifest rule live?** §6 defers it to
the format half without deciding whether it is a schema rejection (JSON Schema cannot
express uniqueness over a computed key, so it would need a producer check) or a board
disclosure. **Cost of guessing wrong:** either a producer that can write an unbindable
manifest, or a board carrying a check the producer already made. I would rather the
reviewer rule than the format car improvise.

**Q6. Is §0's split honest? ANSWERED at round 1 and recorded, not re-asked.** The reviewer
walked every §5 sentence and ruled §5.5's one-sentence join+precedence **legitimate** -
disclosed as a pointer, pinned three ways by V5/V6/V7 - and found exactly one escape, the
ordering rule in §5.3, now folded as DR1-M3. The sentence is unchanged. Recorded here so a
later round does not re-open a settled question; **the standing form of the question moves
to Q7**, which is where this revision's new format-adjacent prose sits.

**Q7 (NEW at round 2). Single ordered consist, or two arrays plus an explicit index?**
DR1-M2 forced this into the open: D6 + V12 need every declared member in one ordered array,
which collides with `schema/yard-snapshot.schema.json:137`'s
`required: ["subject","role","state","at"]` because an unbound member has neither `state` nor
`at`. **My choice (§5.3): one `cars` array, `state` gains an unbound value, `at` relaxes to
optional** - following the `taskId`/`recordDir` precedent for optional-when-unknowable.
**The alternative I did not take:** keep `cars` and `declaredNotObserved` split, add a
`declaredIndex` to each entry, reassemble order client-side. **Cost of my choice:** relaxing
a required set that has held since the wire landed, and every existing consumer must tolerate
an entry without `at`. **Cost of the alternative:** the wire keeps a shape whose two halves
must be re-merged by every reader (Law 6's second-copy smell, one layer up), and the unbound
member stays outside the consist a human reads - which is most of what §5.3a is about.
**I am genuinely unsure**, this is the round-2 decision most likely to be wrong, and it is a
wire-contract question the reviewer is better placed to rule on than I am.
