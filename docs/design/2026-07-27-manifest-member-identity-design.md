# Manifest member identity: the plan names the plan, and the binding is an observation

Status: Open
Stage: rev 1 - awaiting adversarial design review (round 1)
Issue: #87 (blocks #76, #85, #86; does not block #84)
Date: 2026-07-27
Rung: design (rung 1). Inherits the owner ruling on #76 (2026-07-27) and the round-1
verdict `artifacts/reviews/2026-07-27-tooling-76-review-r1-REJECT.md`.

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
| `docs/specs/2026-07-23-yard-board-spec.md:46` **YB-1, the manifest contract** - *"`members[]{subject, role, gate?}`, per `schema/starcar-manifest.schema.json`"*, LIVING per `docs/doc-map.md:52` | Changing the member contract while leaving this text standing. This is exactly R1-M3 and it is not to be repeated. | §8 assigns the §7b amendment block to the same commit as the schema change, with the amendment mechanism at `docs/specs/2026-07-23-yard-board-spec.md:192` as the vehicle (already carrying two amendments, one cited by name at `scripts/store-checks/StoreIntegrity.Tests.ps1:109` - **path corrected: the round-1 verdict cites this file bare, and it does not live under `scripts/tests/`**). |
| `docs/the-healing-loop.md:62-63` **Executable knowledge** - *"Validated facts must land as tests or gates, never only prose."* | Landing this design's join rule as prose and calling it done. | §0's split plus §5.6's named vector list; §9b records that the prose form is the failure this rung is avoiding. |
| `artifacts/reviews/2026-07-24-dual-runtime-design-review-round3-REJECT.md:77` | Specifying identity, join keys, dedup or ambiguity in prose. | §0. |
| `artifacts/reviews/2026-07-27-tooling-76-review-r1-REJECT.md` R1-M1/M2/M3 | Widening a contract without examining the alternative; leaving a wire undelivered and untracked; leaving the owning spec stale. | §9b, one row each, with dispositions - one of them an appeal carrying new measurement. |
| `scripts/Produce-Artifact.ps1:278-282` (issue #22 item 1, C3R-1e) - *"inventing one (e.g. parsing the free-text prompt) would be exactly the brittle mechanism this fix cycle's brief warns against"* | Sourcing anything at launch by parsing `tool_input.prompt`. | §5.7 sources from `tool_input.description`, a dedicated structured key measured present on **97/97** captured live launch payloads (PR-5). The ruling forbids parsing free text; it does not forbid reading a field that exists. §10 Q2 puts the boundary to the owner anyway, because it is a contract question and the agent does not own it. |
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
| **PR-5** | Key-set extraction over the live launch-payload capture `.claude/probe-logs/post-task.jsonl` (written by `.claude/hooks/post-task-probe.sh`, the `PostToolUse:Task` probe). Key sets and `description` values only - no prompt bodies read out. | **97 payloads captured; every one's `tool_input` key set is exactly `description, model, prompt, subagent_type`, and `description` is populated on all 97.** Sample values: `Design #87 member identity`, `Car #76 train manifest minting`, `Review #79 probe pinning`. A dedicated conductor-authored key exists; it carries prose today, not the handle. |
| **PR-6** | Field-set check of a real modern dispatched record, `artifacts/a103c4067cf9267a3/dispatched-20260727T043547Z.json`, and its returned sibling. | Dispatched carries `kind/subject/at/model/subject_basis` and **no `task_id`**; the returned sibling carries `task_id: view-69-71-review-r1`. Confirms P6's split: the handle exists on return and nowhere at launch. |

**Non-vacuity of PR-1 and PR-2:** they ran in ONE store, against ONE server process, in one
snapshot. The `minted-id` train rendering correctly in the same breath as the shape-B train
rendering falsely is what rules out "the probe store was simply broken" as an explanation.

**One caveat on PR-5, stated rather than glossed:** the capture lives in the SHARED
checkout's gitignored `.claude/probe-logs/`, so the raw evidence is not in the tree and a
reviewer re-derives it from their own capture, not from mine. That is the same honest
boundary `schema/vectors/adapter/copilot-launch-minted-from-name.json`'s provenance line
already records for the Copilot shape.

## §2c - Probe list (what the desk CANNOT prove)

Everything this design assumes and could not settle from here. Nothing in this table is
stated as fact anywhere else in the document.

| Claim | Why unverifiable from the desk | What would settle it |
|---|---|---|
| The producer, running under the real hook, would read `tool_input.description` unchanged. | I observed the field in `.claude/probe-logs/post-task.jsonl` (the PostToolUse capture), and `scripts/Produce-Artifact.ps1` reads the same payload object - but no code reads `description` today, so the end-to-end read is unbuilt. | A red-first producer test over the captured payload shape, then one live dispatch. Blocking test in §7. |
| The Copilot compat launch payload still carries `tool_input.name`. | Its capture (`.claude/probe-logs/post-task.jsonl` for that family) is gitignored and the tree holds only the fossil quotation (`schema/vectors/adapter/copilot-launch-minted-from-name.json` provenance line, citing the superseded design §3b-8). No Copilot dispatch is available to me. | One Copilot-family dispatch with the probe hook armed. Until then P8's `minted-id` half rests on a fossil, and §5.5's legacy clause does NOT depend on it. |
| The board renders §5.3/§5.4 as specified. | No code exists; #85 and #86 are unbuilt. Every rendering claim about the FIXED board is a requirement, never an observation. | The car that closes #85/#86, with the §5.6 vectors as its reds. |
| Handle collisions (two records resolving to one handle) are rare in practice. | Requires a corpus that does not exist yet - `task_id` on records is days old. | Counting over the store once §5.7 lands. **This design does not assume rarity**: §5.6 requires the ambiguity condition regardless. |
| No two handles in the corpus differ only by case or whitespace. | I did not enumerate. | A one-line scan; drives §10 Q3's canonicalisation answer. |
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

### 5.3 What the trains lane renders

Every declared member renders, in declared order, titled by its identity - which is the
shop handle for new manifests and the legacy dispatch subject for the six landed ones.
A member is never omitted from the consist for lack of a record; "no record" is a *state*
of a rendered row, not a reason to stop rendering it.

This is the requirement #85 becomes under this design, and it is strictly wider than #85's
current text: #85 asks that a `task_id`-only member reach `declaredNotObserved`; D6 asks
that no member ever fail to reach a surface, whatever keys it carries.

### 5.4 What the dispatches lane renders

Unchanged for bound records. For a record that resolves to no member: the row keeps its
existing `assigned:false`, **and** the board raises a condition naming the count and the
subjects. #86 becomes: a member's identity is its row title wherever the row appears, so a
bound in-flight row is titled by its plan rather than by a runtime hash.

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
`schema/vectors/` pattern plus red-first tests. The vector set must pin, at minimum:

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

Every one of V5-V10 is a behavioural claim about code that does not exist, so each lands
**red first** and fails for its own stated reason before any board change.

**Non-vacuity note the implementing car must honour (#40):** V6 and V10 would pass today
for the wrong reason (V6 because the current join already matches subject-to-subject; V10
vacuously if the member happens to carry `subject`). Each must be fault-injected once and
observed red, or it is a guard nobody watched fire.

### 5.7 The in-flight wire (D8) - specified, not built, and separable

The launch payload's `tool_input.description` is a dedicated, conductor-authored,
always-present key. **Measured (PR-5), over 97 captured live `PostToolUse:Task` payloads:**
every payload's `tool_input` key set is exactly `description, model, prompt,
subagent_type`, and `description` is populated on all 97 - observed values include
`Design #87 member identity`, `Car #76 train manifest minting`, `Review #79 probe pinning`.
It is prose today, not the handle.

The change is a convention plus a read: the conductor puts the task-id in `description`,
and the producer stamps it as `task_id` on the `dispatched` record. This is not the
mechanism C3R-1e ruled against - that ruling forbids inventing a value by parsing
`tool_input.prompt` for a field that does not exist; this reads a field that does.

**The mirror is made checkable rather than tolerated (Law 6).** The dispatched record's
`task_id` would come from the CONDUCTOR's label; the returned record's already comes from
the AGENT's envelope echo. Two independent observations of one handle. A mismatch means the
two disagree about which dispatch this is, and D9's disclosure covers it. That checkability
is the reason the second copy is acceptable; without the check it would be an ordinary
drifting mirror and I would not propose it.

**Deliberately separable:** if the owner refuses the convention (§10 Q2), D1-D7 and D9 all
stand and the board remains honest - epoch 2 simply persists for the `runtime-id` family
until some other wire is found.

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
| Renaming the wire's `declaredNotObserved` field to match D6's wording | Wire-shape change; belongs to the car closing #85 with its own schema review. Named so it is not assumed done. |

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
| `board/assemble/assemble.go` | The join (D5), the no-drop rule (D6), the two conditions (D7/D9) | the #85/#86 car - **coordinate with #84, which may be editing board files** |
| `schema/yard-snapshot.schema.json` | Wire shape for the member identity title and the new conditions | same car |
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

Every finding and every ruling from `artifacts/reviews/2026-07-27-tooling-76-review-r1-REJECT.md`
and the owner's #76 ruling.

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

**Q2. Does the owner accept the task-id on `tool_input.description`?** (Owner ruling, not a
review call - flagged here so the reviewer does not adjudicate it.) It is a dedicated key,
present on 97/97 measured launches, and not the free-text prompt C3R-1e ruled against. But
it IS a human-facing label being given a machine meaning, and the conductor currently writes
prose there. **Cost of yes:** epoch 2 closes; one more hand-written copy of the handle,
made checkable by §5.7. **Cost of no:** epoch 2 is permanent for the `runtime-id` family;
in-flight rows stay hash-titled; D7's disclosure carries the honesty. The design stands
either way, which is why D8 was made separable.

**Q3. Does the join need canonicalisation?** §5.5 assumes exact string equality. R1-m2
proved this repo has already been bitten once by an unexamined case-sensitivity assumption.
I did not enumerate the corpus for handles differing by case or whitespace. **Cost of
assuming exact and being wrong:** a member silently fails to bind and renders as declared -
epoch 2's failure mode, honest but wrong. **Cost of adding canonicalisation:** the join
becomes a canonicalisation rule and §5.6 grows a vector; more surface, more to get wrong.

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

**Q6. Is §0's split honest?** The instrument check is the finding I most want attacked.
§5.5 states the join in one sentence in order to make §5.6 checkable against it - which is
one sentence of format in the prose half. If the reviewer judges that sentence to be the
thin end of the founding scar, the remedy is to delete it and let the vectors speak alone;
say so. **Cost of leaving prose that should be executable:** the four-round swirl this
repo has already paid for twice.
