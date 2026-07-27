<!-- starcar-integrity: sha256=90f4c16bd5446ba84a7c8d3a804f64eeb5f35908bf84b786a41b1c08f685ef21 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Design #87 manifest member identity, adversarial design review round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: adversarial design review (ladder rung 2)
Round: 1
Target: `design/member-identity-87 HEAD 9e18799`
Base reviewed: `51fb403b635a90b8e3d5b38092641b058dfd1a5f`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `afe18ef8acbb02719`. The conductor did not retype a word of what follows. Verbatim by
> construction rather than by discipline, because the author being reviewed is the
> one landing the review, and a hand-copied verdict is a hand-maintained mirror at a
> process boundary.
>
> Integrity: the `starcar-integrity` line at the top of this file hashes EVERY byte
> below it - this header's claims as well as the verbatim body. Recompute with
> `scripts/Verify-Verdict.ps1 -Path <this file>`. An independently-written copy of the
> same body exists on the Entire checkpoint branch; that copy, not the hash, is the
> defence against whoever controls this script.
>
> Path normalisation: the repository root was rewritten to ``<repo>`` and the operator home directory to ``~``, BEFORE hashing. Mechanical and narrow: only those two roots, longest-first, no other substitution. This is portability, not curation - findings, verdicts and counts are untouched, and the un-normalised original is on the Entire checkpoint branch.

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `51fb403b635a90b8e3d5b38092641b058dfd1a5f` |
| Entire checkpoint | `2aeffe52d4c4` |
| Dispatch, the locator within the session | `afe18ef8acbb02719` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 51fb403b635a90b8e3d5b38092641b058dfd1a5f
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: **REJECT** — 3 Major, 5 Minor, 7 Notes

The design's **central argument is correct and I confirmed it independently, end to end** — PR-1 through PR-6 all reproduce except one, and the one that does not is the one everything about D8 rests on. The REJECT rests on that false measurement, on a Law-1 requirement traced to the wire and never to the pixel, and on the author's own §0 test firing against §5.3.

## BASE-DELTA (#13)

Worktree `<repo>-wt\design-87`, HEAD `9e18799ace9332d6d4b472bb2d46a77f1666bf5c`, branch `design/member-identity-87`, **0 dirty** — verified before any command. Base `51fb403b635a90b8e3d5b38092641b058dfd1a5f`.

```
 .../2026-07-27-manifest-member-identity-design.md  | 564 +++++++++++++++++++++
 1 file changed, 564 insertions(+)
```

Shared checkout `<repo>` verified untouched: HEAD `97486ec`, **0 dirty** (the disclosed stray file is gone). All my writes went to the scratchpad; all fault injection ran on an out-of-repo clone.

## Suites — observed by me at `9e18799`

| Suite | Claimed | I observed | Reconciles |
|---|---|---|---|
| `scripts/tests` | 223 P / 0 F / 4 S | **223 P / 0 F / 4 S** (227 total) | exact |
| citation gates (CitationResolver + DocPolicy + CodeCitation) | 43 P / 0 F / 4 S | **43 P / 0 F / 4 S** (47 total) | exact |
| `scripts/probes` | — | **29 P / 0 F / 0 S** | baseline |
| `scripts/store-checks` | — | **271 P / 0 F / 0 S** | grown from r1's 267 (store grew) |

**Skip delta: NONE, and that is itself a coordinate.** I ran **attached** to `design/member-identity-87`, so `SessionStartGuardRunner.Tests.ps1`'s branch-conditional test executed. The round-1 reviewer's detached-HEAD 5th skip does not apply here. The 4 skips are all `CitationResolverPolicy`'s report-only diagnostics (ellipsis-elided, historical-marker, ambiguous-basename, content-anchor), named by the gate itself.

**Guard non-vacuity — I watched it fire.** The friction log's own second lesson (`docs/friction-log.md`, commit `ac751e7`) is that the citation gate scans `git ls-files` and is blind to untracked files. So a green run proves nothing until someone injects. On an out-of-repo clone at `9e18799` I replaced `` `docs/constitution.md:14-18` `` with `` `docs/constitution.md:999999` ``:

```
FAILED: every resolved citation's line (or range end) is within the target file's line count (Class B floor)
Expected $null or empty, but got 'docs/design/2026-07-27-manifest-member-identity-design.md:55 cites
'docs/constitution.md:999999' - target file has fewer lines'.
```

27 P / **1 F** / 4 S. Restored: sha256 `77AD7EE2AF6DAECF2D888248BE8FB224A37861D415E4C55D09AD2F2B19838F42` **byte-identical before and after**, clone 0 dirty, baseline back to 28 P / 0 F / 4 S. The gate genuinely sees this document.

---

# ADJUDICATION 1 — the §0 split. **The ruling binds, the citation is true, §5.5 is legitimate — and §5.3 violates the author's own test.**

**The cited verdict is real and it binds.** `artifacts/reviews/2026-07-24-dual-runtime-design-review-round3-REJECT.md:77` is the convergence ruling, and it reads verbatim *"identity, join keys, dedup and ambiguity are format/protocol — prose cannot hold them."* (The design renders the em dash as a hyphen — house style per `CLAUDE.md`, not a misquote.) It binds squarely: it was issued about a dispatched↔returned identity/join model, which is this document's subject. `docs/design/2026-07-24-family-agnostic-harness-design.md:10-20` is indeed the document that obeyed it, and this §0 copies its shape faithfully.

**Applying the author's invited test** (design lines 42-45: *"If the reviewer finds a join, precedence, ordering or dedup rule stated as prose outside §5.6, that is a §0 violation"*), I walked every §5 sentence:

| §5 sentence | Class | Vector pins it? | Ruling |
|---|---|---|---|
| §5.5 the one-sentence join + `task_id`-then-`subject` precedence | join + precedence | **V5, V6, V7** | **LEGITIMATE.** Disclosed as a pointer, pinned three ways. This is what the behavioural half pointing at the executable half is supposed to look like. **Q6 ruled in the author's favour on §5.5 — do not delete it.** |
| §5.5 legacy-clause framing | join | V6 | fine — restatement |
| §6 "the precedence clause would prefer `task_id`" | precedence | V7 | fine — applying a pinned rule, not stating a new one |
| D9 "never picks a winner by recency, order, or precedence" | ambiguity | V8 | fine — a §4 decision, pinned |
| **§5.3 "Every declared member renders, in declared order"** | **ORDERING** | **NOTHING** | **VIOLATION → DR1-M3** |

Ordering is one of the four words §0 itself names as format. §5.6's V1-V11 contain no ordering vector and no vector pinning consist membership at all. So the requirement `#85` becomes is prose-only and unfalsifiable by the executable half.

**The converse, ruled explicitly: NOTHING behavioural has escaped into the format half.** V8/V9/V10 look behavioural (they assert what the board *does*), but each is also stated as a §4 decision in the prose half (D9/D7/D6) and reviewable there. That is the correct arrangement — decision in prose, pin executable — not an escape. One gap in the other direction: §0 defers six items and §5.6 pins five (DR1-m4).

---

# ADJUDICATION 2 — PR-1, the load-bearing probe. **CONFIRMED, independently, and the design if anything UNDERSTATES it.**

I did not take this on report. I built `board/server` from source (`go build`, exit 0, go1.26.5), constructed my own store from scratch (16 sealed records, `Get-Sha256Hex` over the compact body via `scripts/Artifact.psm1` — one hashing owner, no second rule), and read real HTTP `/api/snapshot`.

**Observed, verbatim from the trains lane:**

```json
{"id":"train:shapeb","title":"Shape B vs a real runtime-id dispatch","cars":[],
 "declaredNotObserved":["d87-car-r1","d87-review-r1"],"tickets":["#87"]}
```

**Simultaneously, same snapshot, dispatches lane:**

```json
{"assigned":false,"at":"2026-07-27T16:21:31Z","outcome":"done","state":"returned",
 "subject":"aaaaaaaaaaaaaaaaa","taskId":"d87-car-r1"}
{"assigned":false,"at":"2026-07-27T16:27:31Z","state":"dispatched","subject":"bbbbbbbbbbbbbbbbb"}
```

**`board: []` — ZERO board conditions.** Confirmed by direct inspection of the snapshot's `board` key.

**The design understates it.** It says the board "asserts a member has not departed." What a human actually reads is stronger. `board/web/js/dom-writer.js:481` renders that array as the literal sentence **`declared, not yet observed: d87-car-r1, d87-review-r1`** — while the same wire carries `d87-car-r1`'s *returned* record. Not-yet-observed is a claim the board cannot make about a handle whose return it is holding. `schema/yard-snapshot.schema.json:143` describes the field as "Manifest members with no matching store records" — also false here. `constitution.md:14-18` is exact: *"a confident falsehood on a status surface is the worst defect this project can ship."*

**The design's central argument stands, and it inverts the owner's understanding of the two rejected shapes.** The round-1 verdict's R1-M1 measured shape B against a store whose only records were the manifest itself — `artifacts/reviews/2026-07-27-tooling-76-review-r1-REJECT.md:134-142`, where the alternative-shape probe output is `"cars":[]` with no runtime-id records present at all. That is the epoch where shape B cannot be wrong. Put in front of a real `runtime-id` dispatch it produces a Law-1 falsehood, which is a **worse class** than shape A's Law-4 silent drop: a silent drop says nothing; shape B says something false. **The owner nearly adopted shape B. It should not be adopted.** State that plainly.

**Non-vacuity of my own reproduction:** PR-1 and PR-2 ran in ONE store, ONE server process, ONE snapshot. The minted-id train rendered perfectly in the same breath the shape-B train rendered falsely — so "the probe store was broken" is ruled out. The author's non-vacuity argument is sound and I reproduced its structure independently.

**PR-2, PR-3, PR-4a — all confirmed in the same snapshot:**

```json
{"id":"train:minted","title":"Minted-id family",
 "cars":[{"subject":"d87-minted-car-r1","role":"car","state":"dispatched",...},
         {"subject":"d87-minted-gate-r1","role":"gate","gate":"car-review r1","state":"returned",
          "outcome":"APPROVE",...,"taskId":"d87-minted-gate-r1"}],
 "declaredNotObserved":[],"tickets":["#87"]}
```

gates lane filled (`{"name":"car-review r1","outcome":"APPROVE"}`), both minted rows `"assigned":true`, zero conditions, zero changes to anything. **P8 holds: the identity crisis is one family's property, not the manifest's.**

PR-3: `ccccccccccccccccc` and `ddddddddddddddddd` both returned with `"taskId":"dup-handle-r1"`, **both render, zero conditions.** No ambiguity guard exists today; D9/V8 is required, not optional.

PR-4a: `train:legacy` — both runtime-id members bound and rendered with liveness, `declaredNotObserved:[]`, zero conditions. **The fallback clause protects RENDERING, not merely validation.** Confirmed.

---

# ADJUDICATION 3 — PR-5 and the reopened path. **The path IS reopened. The evidence published for it is FALSE.**

I read the same file the author read: `<repo>\.claude\probe-logs\post-task.jsonl`, now 98 lines. Line 97 is the author's own dispatch (`Design #87 member identity`, `_probe_logged_at` 2026-07-27 11:58:10); line 98 is mine (12:25:12). So the author saw lines 1-97.

**Measured `tool_input` key sets — TWO, not one:**

```
[description,model,prompt,subagent_type]              x78
[agent_type,description,mode,model,name,prompt]       x20
```

The 20 are the Copilot compat family, `_probe_logged_at` **2026-07-24 07:18:40 through 2026-07-25 19:08:35** — every one of them logged before the author's own dispatch line. **The design's "every one's `tool_input` key set is exactly `description, model, prompt, subagent_type`" is false against the file it cites, by 20 of 97.** → DR1-M1.

**What survives, and it matters:** `description` populated on **98/98**, min length 17, max 43, **98/98 distinct**, present on *both* families. So D8's actual premise — a dedicated, always-present, conductor-authored key — is TRUE and **stronger than the author claimed**.

**Ruling on the reasoning: the design is RIGHT, and the conductor's statement to the owner was wrong.** `scripts/Produce-Artifact.ps1:278-282` (verified verbatim) forbids *"inventing one (e.g. parsing the free-text prompt)"* — the target is invention-by-parsing where no field exists. Reading a whole dedicated field is a different mechanism. Issue #76's comment told the owner *"the launch payload carries no structured field to read it from"*; measured, it carries `description` on 98/98 and, on the Copilot family, `name` as well. **That claim was false and the design is correct to reopen it.** The design also routes the contract question to the owner as Q2 *without pre-answering it* — the exact discipline the #33 scar exists to enforce, done right this time.

**But `description` is not a clean identity carrier, and the author's own log proves the hazard.** Lines 46 and 47:

```
line 46  name='probe-dup-name'  desc='Probe: duplicate dispatch name A'
line 47  name='probe-dup-name'  desc='Probe: duplicate dispatch name B'
```

That is the round-3 verdict's DR-6 defect measured live in this shop: an operator-chosen launch label reused across two dispatches. `description` is exactly as operator-chosen as `name` was; its 98/98 uniqueness is an accident of prose variety, not a property. There is no schema, no pattern, no validation on it anywhere. §5.7's checkable-mirror argument covers conductor-vs-agent *disagreement on one dispatch*; it does not cover *two dispatches carrying one conductor-written handle*, which lands in D9/V8 — and the design never connects D8 to D9. → DR1-m5.

**One compounding fact the design does not reconcile:** `schema/vectors/adapter/copilot-launch-minted-from-name.json:14` declares `"tool_input": { "name": "47-car-r1", "agent_type": "car", "prompt": "x" }` — **no `description`** — while the live Copilot payloads all carry it. The landed vector and the live capture disagree, and D8 built against that vector would find no `description` on the Copilot path.

---

# ADJUDICATION 4 — the derived binding. **The mechanism is sound; the lifecycle enumeration is incomplete.**

D5 is the strongest thing in this document. Because the binding is *derived at assemble time* rather than *written at some moment*, it is order-free: a returned record landing before its manifest is minted still binds. That dissolves a class of race the two rejected shapes both carried. Credit where it is due.

Lifecycle events I enumerated and checked against the document:

| Event | Covered? | Evidence |
|---|---|---|
| Two members share a handle in one manifest | **Yes**, deferred + Q5 | §6 row + §10 Q5; correctly notes JSON Schema cannot express uniqueness over a computed key |
| Dispatch returns with a handle no manifest declares | **Yes** | D7, §6 row, V9 |
| One handle → two records (crash re-dispatch) | **Yes** | D9, V8, PR-3 measured |
| One record → two members / two manifests | **Yes, and partly already built** | `assemble.go:169-187` already raises `manifest-membership-collision`; D9 generalizes it |
| Handle reused across trains | **Yes** — same as above | |
| Fix-cycle rounds | **Yes** — D1 mints a new task-id per round (`-r1`, `-r2`) | |
| Manifest superseded, consist GROWS | **Yes** | P4, the six landed records (1→2→4→6→8→10, verified) |
| Manifest superseded, consist SHRINKS (member removed mid-flight) | **NOT ENUMERATED** | P4 names only growth; §6 has no row. Behaviour is inherited-unchanged (removed member's record flips to unattributed → D7 discloses it), so honest — but undesigned |
| **`presumed-lost`** | **NOT ENUMERATED ANYWHERE** | see below |

**`presumed-lost` is the gap worth naming.** It is a first-class kind (`schema/vectors/valid-presumed-lost.json`, `Detect-Dispatches.ps1:163-164` precedence `returned &gt; presumed-lost &gt; dispatched`), it is the record for the #32 killed-session class the owner's ruling says the manifest exists to make detectable, and **it carries no `task_id`** — `Produce-Artifact.ps1:358` writes `task_id` only when `$Kind -eq 'returned'`, and the canonical vector has none. Under D5 a presumed-lost record therefore falls back to `subject` (a runtime id) and binds to no member. §5.1's table lists it in the dispatch stream and §5.2's three epochs, §6's failure table, and §5.6's V-set never mention it again. Under D6/D7 the board would still render two true statements, so it is not a Law-1 hole — but the design's own headline use case (the killed session) routes through a record kind the document never traces. It belongs in §5.2 and §6 explicitly, and D8's stamping question ("does a presumed-lost record inherit its dispatched sibling's `task_id`?") is unasked.

Corpus check, read-only over the real store: **0 presumed-lost records exist today**, so nothing is broken now — this is a design-completeness finding, not a live defect. Folded into DR1-m4's class as a note rather than its own Major, because the rendering stays honest.

---

# ADJUDICATION 5 — the legacy clause and NO-BACKFILL. **Every number verified. The clause is necessary and it protects rendering.**

Measured over the real `artifacts/` store, read-only:

| PR-4 claim | Observed |
|---|---|
| 6 manifests | **6** (`intent-20260723T134605Z` … `T190156Z`) |
| member counts 1, 2, 4, 6, 8, 10 | **exact** |
| 10 distinct member subjects, all runtime ids | **10**, every one keyed `[subject\|role]`, all `aXXXXXXXXXXXXXXXX` form |
| those subjects own 16 returned records | **16** |
| **0 carry `task_id`** | **0** |

Corpus-wide for context: 177 returned records, 96 carry `task_id`; 83 dispatched records, **0** carry `task_id`.

**Does the fallback protect RENDERING and not merely validation? YES — measured (my PR-4a above).** A legacy-shaped manifest through the real board renders both members bound with liveness, `declaredNotObserved:[]`, zero conditions. Without the fallback clause those two rows would vanish from the consist while their records still sat in the store — Law 4 silent loss on a rendered surface.

**Does anything in this design retroactively invalidate a landed record? NO.** D4 keeps `subject` a legal identity key (`anyOf`), D3 never rewrites a landed member, §7 forbids retro-adding `task_id` outright. The one theoretical unbind path — §6's "a legacy manifest meets a modern record for the same subject carrying a `task_id`" — is **measured unreachable** (0 of 16) and structurally unreachable (runtime ids are not reissued). The author recorded it rather than dismissing it, and V7 pins the precedence so a future change reds. That is the right handling.

**Ruling on Q4 (is the fallback worth its price?): YES, and the author's reading of NO-BACKFILL is correct, not a stretch.** Law 4 is explicit — *"a missing lane reading as 'no trains' is a lie of omission"* (`constitution.md:33-37`). A rendered train silently losing its consist is the same class one level down. The author flagged this reading as "mine, not the doctrine's literal text, and it deserves attack"; attacked, it holds.

---

# FINDINGS

## Major (any Major = REJECT)

### **DR1-M1 — PR-5's key-set measurement is false, and §2c's Copilot row is falsified by the very file PR-5 read.**

Design lines **239** (§2b PR-5), **402-406** (§5.7), **65** (§1 C3R-1e row), **260** (§2c row 2).

Claim: *"97 payloads captured; every one's `tool_input` key set is exactly `description, model, prompt, subagent_type`."* Measured over the same file (98 lines; the author saw 1-97): **two** key sets, `description,model,prompt,subagent_type` ×78 and `agent_type,description,mode,model,name,prompt` ×20, the latter logged 2026-07-24 07:18:40 → 2026-07-25 19:08:35, all before the author's own dispatch at 11:58:10 on 07-27.

Three consequences, in ascending order of cost:

1. **A confident falsehood published three times** in a document whose §2b explicitly promises *"every behavioural claim in this document is traceable to an observation rather than a reading."* Law 1; documentation ranks equal to code.
2. **§2c states "No Copilot dispatch is available to me"** and that the tree holds *"only the fossil quotation"* — while 20 Copilot launch payloads with `tool_input.name` populated (`car46-fix-cycle`, `47-car-r1`, `probe-dup-name`, …) sat in the file PR-5 was reading. A probe row declares unprovable a fact the author's own data proves, and P8's minted-id half is told to rest on a fossil when live evidence exists. A downstream car will spend a dispatch re-deriving this.
3. **The design hazard.** An implementer taking §5.7's "key set is exactly" literally writes a Claude-only adapter in a repo whose #47 design exists to be family-agnostic. Compounding: `schema/vectors/adapter/copilot-launch-minted-from-name.json:14` carries no `description` while the live Copilot payloads all do — the landed vector and the capture disagree and the design reconciles neither.

**What survives:** `description` populated 98/98 across BOTH families. D8's premise is intact and stronger than claimed. **Fix is a correction, not a redesign** — but the correction must reach all four locations and must flip §2c's Copilot row from "unverifiable" to "measured".

### **DR1-M2 — the design's Law-1 requirement is traced to the wire and never to the surface a human reads; §8 names no view file.**

The sentence check, every hop with file:line:

| Hop | Location | What crosses |
|---|---|---|
| 1 | `board/assemble/assemble.go:110-113` | unbound member → `train.DeclaredNotObserved` |
| 2 | `board/assemble/types.go:45` | `DeclaredNotObserved []string \`json:"declaredNotObserved"\`` |
| 3 | `schema/yard-snapshot.schema.json:140-144` | *"Manifest members with no matching store records"* |
| 4 | **`board/web/js/dom-writer.js:479-482`** | **renders the literal sentence `declared, not yet observed: &lt;names&gt;`** |
| 5 | `board/web/js/render.js:248` | `isTrainTerminal` → false while the list is non-empty |

**D6 (line 298) requires the rendered state be *"declared; no departure bound"* and forbids anything the board cannot know.** "not yet observed" is precisely such a claim — my PR-1 run has hop 4 rendering it about a handle whose returned record is on hop 2 of the same snapshot. §7 (line 453) scopes out renaming the **wire field** and says "Named so it is not assumed done"; the **view string at dom-writer.js:481 is a different artifact** and appears nowhere in the document. §8 (lines 464-474) lists `board/assemble/assemble.go` and `schema/yard-snapshot.schema.json` but **no `board/web/**` file and no `board/web/test/**`** — 209 node tests with no named owner.

Second, structural half: §5.3 requires every member render **"in the consist"**. `yard-snapshot.schema.json:137` requires `["subject","role","state","at"]` on every `cars` item — an unbound member has neither `state` nor `at`. So D6 cannot be implemented without either relaxing that required set or keeping the two-array split it argues against, and §8's wire row ("Wire shape for the member identity title and the new conditions") names neither.

This is the sentence-check scar's own shape: sixteen correct files and a third hop nobody's review reached. The design's *entire case against shape B* is an argument about a rendered sentence; it must own the last hop.

### **DR1-M3 — §0's own test fires: an ORDERING rule is stated as prose outside §5.6, pinned by no vector.**

Design line **337**: *"Every declared member renders, **in declared order**, titled by its identity."* The author's invited test (lines 42-45) names ordering as one of four triggers, and §0 line 23 lists ordering among what prose cannot hold. §5.6's V1-V11 contain **no ordering vector and no vector pinning consist membership at all** — V10 pins only that an unbound member "renders under its identity", which the current two-array wire already satisfies while destroying declared order (a member goes into `cars` *or* `declaredNotObserved`; the interleaving is unrecoverable).

So the requirement `#85` becomes — the single deliverable this design exists to define — lives only in prose, in the behavioural half, with no executable landing, no §8 owner, and no wire shape that can express it. That is the founding scar's exact mechanism, caught by the author's own instrument, which is the one gate that could catch it.

**Ruled the other way, deliberately:** §5.5's one-sentence join+precedence statement is legitimate and should NOT be deleted. It is disclosed as a pointer and pinned three ways by V5/V6/V7. **Q6 answered: the split is honest everywhere except §5.3.**

## Minor

**DR1-m1 — mis-citation, off by one row.** Line 61 cites *"LIVING per `docs/doc-map.md:52`"* for the SPEC. Line 52 is the `docs/design/*` row (*"LIVING while its train runs; FOSSIL revisions in git history"*); the `docs/specs/*` row is **line 53** (*"LIVING while binding; amendment blocks, never rewrites"*). The design depends on the *spec* axis to make §8's amendment obligation binding, and the round-1 verdict it inherits cited `:53` correctly (`…-tooling-76-review-r1-REJECT.md:232`). Note for the record: `CitationResolverPolicy.Tests.ps1:12-18` declares this class explicitly outside its binding checks — *"an in-range shifted citation … is not detected by any BINDING check here"* — so 43/0/4 green does not clear it, and the gate says so itself.

**DR1-m2 — §2c parks two desk-provable facts in the probe list.** Row *"Handle collisions … Requires a corpus that does not exist yet"*: measured by me in one command over `artifacts/` — **96 records carry `task_id`, 96 distinct values, ZERO shared by two subjects.** The corpus exists and is 96 handles deep; nothing about counting it required §5.7 to land. Row *"No two handles differ only by case or whitespace — I did not enumerate"* (and §10 Q3): measured — **0 uppercase, 0 whitespace, 0 case-collisions across all 96.** **Q3 is settled: exact string equality is sufficient today; no canonicalisation vector is needed.** The template's rule is that *unverifiable* claims go in §2c; parking verifiable ones there inflates the probe list and buys downstream dispatches. (This does not weaken D9/V8 — the design correctly declines to assume rarity, and that stance is right.)

**DR1-m3 — §5.4's "Unchanged for bound records" is imprecise about `assigned`, the symptom that started this train.** `assemble.go:108` sets `assignedSubjects[m.Subject]` from the MEMBER's identity. Under D5 it must key off the BOUND record's subject instead, so `assigned` flips false→true for every runtime-id member that binds. Measured in my PR-1 snapshot: the shape-B runtime-id records render `"assigned":false` while the minted-id records render `"assigned":true`. §8's assemble.go row lists "the join, the no-drop rule, the two conditions" and not the assignment rewire — and #76's own probe comment names "92 unassigned" as one of the three symptoms this work exists to fix.

**DR1-m4 — §0 defers six items; §5.6 pins five.** §0 lines 22-24 defer the identity key, the `required` set, the join rule and precedence, ambiguity, duplicates, **and "what 'amendment' may and may not touch."** §5.6's "must pin, at minimum" list has no amendment vector. One deferred obligation lands nowhere — the carrier rule's own failure shape, inside a single document. **Related, and worth folding into the same fix:** `presumed-lost` appears in §5.1's table and then in no epoch (§5.2), no failure row (§6), and no vector (§5.6), despite being the record kind for the killed-session class the owner's ruling names as the manifest's purpose, and despite carrying no `task_id` by construction (`Produce-Artifact.ps1:358`, `schema/vectors/valid-presumed-lost.json`). 0 exist in the store today, so nothing is live-broken.

**DR1-m5 — D8 re-imports P7's vigilance dependency and the design never says so.** P7 (lines 179-186) kills both rejected shapes because *"a mechanism whose correctness depends on a human remembering a step per dispatch is vigilance-tier."* D8 (line 300) is a convention requiring the conductor to write the handle into `description` on every dispatch. D5 genuinely kills vigilance for the returned epoch — verified, the data is already there. D8 restores it for the in-flight epoch, and the document never acknowledges the symmetry. The defence is available and probably right (vigilance-with-honest-degrade under D7 ≠ vigilance-with-silent-falsehood), but it must be *made*, against the author's own premise. Aggravating, from the author's own log: `tool_input.name = 'probe-dup-name'` on two distinct dispatches (lines 46-47) — the round-3 verdict's DR-6 defect, measured live in this shop. `description` is exactly as operator-chosen as `name` was; the design never wires D8's collision risk to D9/V8.

## Notes (no action required)

- **N1 — every probe except PR-5 independently confirmed.** PR-1 (shape B falsehood, zero conditions), PR-2 (minted-id family clean), PR-3 (duplicate handle, both render, zero conditions), PR-4a (legacy renders), PR-4b (6/10/16/0), PR-6 (dispatched field set exact; **83 dispatched records corpus-wide, 0 with `task_id`** — P6 is stronger than the single record cited).
- **N2 — §9b is COMPLETE against the template, with no blanks.** All 3 Majors + all 5 Minors = 8 finding rows; all 5 owner rulings = 5 ruling rows; N3 and N5 included voluntarily. N1/N2/N4 are notes, which the template does not require. Every row carries a disposition and a "Where". The R1-M1 appeal is loud, evidenced, and concedes the core charge (*"the car widened without examining the alternative"*) — the non-agreeable form. The partial appeal of an **owner ruling** is routed to §10 Q1 for the owner rather than resolved, which is the doctrine done right.
- **N3 — §2b is a LEGITIMATE template extension, not scope creep.** `CLAUDE.md`'s probe doctrine mandates that probes land "with coordinates … cited in the consuming document"; the template has §2c for what *cannot* be proved and no home for what *was*. §2b adds a section, reorders nothing, removes nothing, and is disclosed. `docs/templates/design-doc.md` makes no closure claim about its section list, so nothing is made stale and no same-commit doc obligation is triggered. **Recommendation, not a finding:** the template should absorb §2b.
- **N4 — §10's questions are REAL, not soft spots dressed up.** Q1 states costs both ways and names itself most-likely-wrong. Q3 is real but I settled it (DR1-m2). Q4 invites attack on the author's own doctrinal reading and survives it. Q5 correctly identifies that JSON Schema cannot express uniqueness over a computed key. Q6 is the author asking for the finding I gave it. Q2 is an owner question, correctly routed and correctly *not* pre-answered.
- **N5 — §8's `schema/vocab/` "untouched" claim is TRUE, verified.** `board/store/condition_severity.go:98-103`: `RegisterForCode` returns `"needs-attention"` for any code not explicitly listed as `TierNote`. A new condition code defaults to loud. No vocabulary change is needed for D7/D9.
- **N6 — the self-disclosure is exemplary and I found nothing resting on the vacuous window.** `docs/friction-log.md` (commit `ac751e7`) names the actor, the exact move, the second-order cost, and the fact that this is the SECOND instance of a logged class — blameless-and-precise, not blameless-and-vague. It also lands a genuinely new finding nobody asked for: repo-policy gates keyed to `git ls-files` are blind to untracked files. I re-ran the injection myself (above) and the gate reds by name on this document, so the redone injection is genuinely non-vacuous. And every substantive claim in the document is now re-derived by a second party — PR-1/2/3/4a in my own store from scratch, PR-4b/PR-6 against the real corpus — so nothing survives on the strength of evidence gathered during the vacuous window. Shared checkout verified clean (0 dirty).
- **N7 — train terminality, checked and cleared.** `render.js:243-250` makes a train non-terminal while `declaredNotObserved` is non-empty, so D6's no-drop rule means a train with a permanently-unbound member never becomes history-eligible. `render.js:197-199` already ratifies exactly this (*"an undelivered member is the owner's 'queued', never terminal"*, #67), so behaviour is unchanged and no document goes stale. Recording it so a later round does not re-dig.
- **N8 — §7's `board/fold` claim is accurate as worded.** Manifests DO ride the fold for intent-winner selection (`assemble.go:85-90`), but not its *dispatch-lifecycle* machinery — `Detect-Dispatches.ps1:182-183` partitions intent records out of the `returned &gt; presumed-lost &gt; dispatched` precedence entirely. The narrower wording is the true one.

---

## UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

**One piece of my evidence is not re-derivable from the repo alone, and it is DR1-M1's:** `.claude/probe-logs/post-task.jsonl` is gitignored runtime output in the shared checkout, and it grows with every dispatch. My line numbers (42-61 Copilot, 97 author, 98 me) are true of the 98-line file at 2026-07-27 12:25. A later reader re-derives the *class* — two key sets, Copilot carrying `name`+`agent_type` and no `subagent_type` — from their own capture, not from mine. That is the same honest boundary the design itself records for PR-5, and it does not weaken the finding: the 20 Copilot rows are timestamped before the author's own dispatch line in the same file, which is the fact the finding turns on.

Everything else is fully re-derivable. Recipe: `go build -o &lt;scratch&gt;\board-server.exe ./server` from `board/`; build a store with `[ordered]` records sealed via `Get-Sha256Hex` over the compact body (`scripts/Artifact.psm1` — the one owner, never a second rule; idiom at `scripts/probes/ManifestBoardJoin.Probes.Tests.ps1:146-159`); run the exe with `STARCAR_STORE_PATH=&lt;dir&gt;`, `STARCAR_PORT=0`, `STARCAR_POLL_MS=150`, `WorkingDirectory` = repo root; read `/api/snapshot`. My probe script is at `~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\8a347c36-20b4-427a-ae0b-46855aa7bb72\scratchpad\d87\rev87-probe.ps1` and is session-local — the recipe, not the file, is the durable form. **Per the named hazard: every write in it uses an absolute path, and the shared checkout is verified 0 dirty.**

---

## CONSTITUTION CHECK

- **Law 1 (`constitution.md:14-18`, quote verified)** — *Honored* in D6/D7/D9's refusal to guess a pairing, in §6's unknown row (the row the template calls most commonly missed), and in §6's decision to record the theoretically-possible legacy unbind rather than dismiss it. *Violated* at **DR1-M1** (a false measurement published three times, in a document that promises every claim traces to an observation) and *left violated in effect* at **DR1-M2** (D6's requirement never reaches `dom-writer.js:481`, where the false sentence is actually rendered).
- **Law 3 (`:28-31`)** — *Honored.* D7 correctly refuses to make the dispatcher aggregate `assigned:false` rows themselves, and §6 names honest degradation as a cost rather than hiding it.
- **Law 4 (`:33-37`)** — *Honored, and this is the design's strongest leg.* D6 forbids the drop outright; §5.5's fallback clause is measured (PR-4a) to protect rendering and not merely validation; #85's silent loss is closed by construction rather than by a condition bolted on.
- **Law 6 (`:46-51`)** — *Honored.* One join rule, one owner (the assembler), symmetric on both sides. D9 shows the disagreement rather than picking a winner, which is the clause verbatim. §5.7's one unavoidable mirror is made *checkable* rather than merely tolerated, and the author says outright it would not propose it otherwise. My PR-3 confirms the guard is genuinely absent today.
- **Law 7 (`:53-57`)** — *Honored* in D3's refusal to redefine `subject` (a stranger reads it consistently) and in leaving `schema/vocab/roles.json` the vocabulary owner with no new enum. *Weakened* by **DR1-M1**: a stranger reading §5.7 builds a one-family adapter in a repo whose #47 design exists to be family-agnostic.
- **NO-BACKFILL** — **Honored, and verified rather than assumed.** 6 manifests, 10 subjects, 16 returned records, 0 with `task_id`, all counted by me. Nothing here retroactively invalidates a landed record; §7 forbids retro-stamping outright; the one theoretical unbind path is measured unreachable and pinned by V7.
- **Living contracts / same-commit** — *Not triggered.* The diff adds one document and changes no code, so nothing goes stale on landing. §8 correctly assigns the future obligations, including R1-M3's §7b amendment block as same-commit and non-negotiable — except that it omits the view layer (**DR1-M2**).
- **Honest stop / disagreeing loudly** — *Honored, conspicuously.* The R1-M1 appeal carries new measurement and concedes the core charge; the partial appeal of an owner ruling is routed to Q1 for the owner rather than resolved; §10 Q2 escalates a contract question **without pre-answering it**, which is the #33 scar's remedy applied correctly.

### **THE LAW-FIRST DIAGNOSTIC: who found the laws?**

**The author did, and this is the cleanest §1 I have reviewed here.** I opened all five constitution ranges plus `the-healing-loop.md:62-63`, `docs/templates/design-doc.md:24-32`, `schema/vectors/adapter/README.md:12-14`, `docs/design/2026-07-24-family-agnostic-harness-design.md:10-20`, `docs/specs/2026-07-23-yard-board-spec.md:46` and `:192`, `scripts/store-checks/StoreIntegrity.Tests.ps1:109`, `scripts/Produce-Artifact.ps1:278-282` and `:358` — **every quote is verbatim-accurate and every coordinate resolves to what is claimed**, with the single off-by-one at `doc-map.md:52` (DR1-m1). The template's own diagnostic asks whether the reviewer is finding the laws. **I found none the author had missed.** Every Major I am raising is a *fidelity* failure — a measurement that does not match its source, a requirement that does not reach its surface, a rule that escaped the instrument the author itself chose — not a law that was absent from the page. That is the diagnostic reading the right way, and the author corrected a dead citation of its own before I got here (`StoreIntegrity.Tests.ps1` under the wrong directory, line 61), which is the condition under which more usually exist. I looked; there was one.

**Contrast with the founding wreckage that this rung's template was built from: seven constraints, seven found by the reviewer, none by the author. Here: zero.**

---

## What a fix cycle needs (same author, delta re-review)

1. **DR1-M1** — re-run the key-set extraction, correct all four locations, and flip §2c's Copilot row from "unverifiable" to a measurement. State plainly that `description` is present on BOTH families (the finding *strengthens* D8). Reconcile `schema/vectors/adapter/copilot-launch-minted-from-name.json:14`'s missing `description` against the live capture — as a §2c row at minimum, better as a §8 obligation.
2. **DR1-M2** — add `board/web/js/dom-writer.js` (and its tests) to §8 with a named owner; state D6's requirement as a *rendered string* change, not only a wire change; and name the `yard-snapshot.schema.json:137` required-set consequence.
3. **DR1-M3** — either add an ordering/consist vector to §5.6, or drop "in declared order" from §5.3 and say so. Do not leave an ordering rule in prose.
4. **DR1-m1..m5** — m1 and m3 mechanical; m2 is one command whose answer I have supplied (use it, and close Q3 as settled); m4 needs an amendment vector and a `presumed-lost` pass through §5.2/§6/§5.6; m5 needs the P7-symmetry paragraph and a D8→D9 link.

**Do NOT re-litigate (verified sound this round):** PR-1/2/3/4a/4b/6 as measurements; the §0 split at §5.5 (**Q6 ruled: keep the sentence**); the legacy clause and the NO-BACKFILL reading (**Q4 ruled: the fallback earns its price**); D5's order-free derived binding; §9b's completeness; §2b as a template extension; §8's `RegisterForCode` and `schema/vocab/`-untouched claims; §7's `board/fold` scoping. **Q3 is answered and needs no further probe.** Q1 and Q5 are the owner's and the format car's respectively, correctly routed.

**Convergence:** round 1 of this document, first rung after the owner stopped the #76 fix cycle. The instrument choice is right and the premise attack is real work — P1, P5, P6, P7 and P8 are five premises nobody in this train had written down, and four of them I confirmed by measurement. No swirl signal. **This is a REJECT that should take one short round, not a redesign.**

---

## Files (absolute paths)

- Reviewed: `<repo>-wt\design-87\docs\design\2026-07-27-manifest-member-identity-design.md`
- Round-1 verdict read: `<repo>\artifacts\reviews\2026-07-27-tooling-76-review-r1-REJECT.md`
- Cited ruling verified: `<repo>-wt\design-87\artifacts\reviews\2026-07-24-dual-runtime-design-review-round3-REJECT.md:77`
- Probe log measured (gitignored, shared checkout, read-only): `<repo>\.claude\probe-logs\post-task.jsonl`
- My probe + snapshot (session-local): `~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\8a347c36-20b4-427a-ae0b-46855aa7bb72\scratchpad\d87\`

```starcar-artifact
task-id: design-87-review-r1
outcome: REJECT
findings: 3 Major, 5 Minor, 8 Notes at round 1. DR1-M1 (Major) PR-5's key-set measurement is FALSE against the file it cites - I read the same .claude/probe-logs/post-task.jsonl (98 lines; the author saw 1-97, line 97 is its own dispatch at 11:58:10) and measured TWO tool_input key sets, not one - description/model/prompt/subagent_type x78 and agent_type/description/mode/model/name/prompt x20 - the 20 being Copilot compat payloads logged 2026-07-24 07:18:40 through 2026-07-25 19:08:35, every one before the author's own dispatch line; the claim is published three times (design line 239 PR-5 row, lines 402-406 in 5.7, line 65 in the C3R-1e constraint row) and the same file falsifies 2c's row at line 260 declaring No Copilot dispatch is available to me, since 20 Copilot launches carrying populated tool_input.name were in it; downstream hazard is a Claude-only adapter in a repo whose 47 design exists to be family-agnostic, compounded because schema/vectors/adapter/copilot-launch-minted-from-name.json:14 carries no description while the live Copilot payloads all do. What SURVIVES and is stronger than claimed - description populated 98/98 across BOTH families, so D8's premise is intact and the fix is a correction not a redesign. DR1-M2 (Major) the design's own Law 1 requirement is traced to the wire and never to the surface a human reads - sentence check hop by hop, assemble.go:110-113 appends the unbound member, types.go:45 carries declaredNotObserved, yard-snapshot.schema.json:140-144 describes it as members with no matching store records, and dom-writer.js:479-482 renders the literal human sentence declared, not yet observed, which is exactly the claim D6 at line 298 forbids and which my own PR-1 run produced about a handle whose returned record sat on the same wire; section 7 line 453 scopes out renaming the WIRE FIELD but the view string is a different artifact named nowhere, and section 8 lines 464-474 lists no board/web file and no board/web test owner for 209 node tests; structurally, 5.3 requires the member render in the consist while yard-snapshot.schema.json:137 requires subject/role/state/at on every cars item, which an unbound member cannot supply, and neither the required-set relaxation nor the ordering carrier appears in section 8 or in 5.6's vectors. DR1-M3 (Major) section 0's OWN invited test fires - design line 337 states Every declared member renders, in declared order, which is an ORDERING rule, one of the four words section 0 line 23 names as format, stated as prose outside 5.6 and pinned by NO vector in V1 through V11; V10 pins only that an unbound member renders under its identity, which today's two-array wire already satisfies while destroying declared order, so the single requirement issue 85 becomes lives only in prose with no executable landing, no section 8 owner, and no wire shape that can express it. Minors - DR1-m1 mis-citation at line 61, docs/doc-map.md:52 is the docs/design row, the docs/specs row is :53 and the axis text differs, the round-1 verdict it inherits cited :53 correctly, and CitationResolverPolicy.Tests.ps1:12-18 declares in-range shifted citations outside its binding checks so 43/0/4 green does not clear it; DR1-m2 section 2c parks two desk-provable facts in the probe list - I measured 96 records carrying task_id, 96 DISTINCT values, ZERO shared by two subjects, so the collision corpus the row says does not exist yet is 96 handles deep, and I measured 0 uppercase, 0 whitespace, 0 case-collisions, which SETTLES Q3 as exact string equality sufficient, no canonicalisation vector needed; DR1-m3 5.4's Unchanged for bound records is imprecise about assigned, the symptom that started this train - assemble.go:108 keys assignedSubjects off the MEMBER identity so under D5 assigned flips false to true for every runtime-id member that binds, measured in my snapshot as assigned:false on the shape-B records beside assigned:true on the minted ones, and section 8's assemble row omits the rewire while issue 76's own probe named 92 unassigned as a headline symptom; DR1-m4 section 0 defers six items and 5.6 pins five, with what amendment may and may not touch landing nowhere, and presumed-lost appears in 5.1's table then in no epoch, no failure row and no vector despite being the killed-session record kind the owner's ruling names as the manifest's purpose and despite carrying no task_id by construction per Produce-Artifact.ps1:358; DR1-m5 D8 re-imports P7's vigilance dependency and the design never says so - P7 lines 179-186 kills both rejected shapes for depending on a human remembering a step per dispatch, and D8 line 300 is exactly such a convention, with the author's OWN log showing tool_input.name equal to probe-dup-name on two distinct dispatches at lines 46-47, the round-3 verdict's DR-6 defect measured live, and no link drawn from D8's collision risk to D9/V8. VERIFIED AND CONFIRMED INDEPENDENTLY - ADJUDICATION 2, PR-1 is RIGHT and the design UNDERSTATES it - I built board/server from source, constructed my own 16-record store sealed with the single Get-Sha256Hex owner, and read real HTTP /api/snapshot, observing train:shapeb with cars empty and declaredNotObserved d87-car-r1 plus d87-review-r1 while the dispatches lane of the SAME snapshot carried subject aaaaaaaaaaaaaaaaa state returned taskId d87-car-r1, with board conditions EMPTY, and the human-facing render at dom-writer.js:481 says declared, NOT YET OBSERVED, a stronger falsehood than the design claims; the round-1 reviewer measured shape B against a store with no runtime-id records at all, the epoch where it cannot be wrong, so the design's inversion of the owner's understanding is correct and shape B should NOT be adopted. PR-2 confirmed - minted-id train full consist, gates lane filled with car-review r1 APPROVE, assigned true, zero conditions, zero changes to anything, in the same store and same run, which is what rules out a broken probe store. PR-3 confirmed - two runtime subjects both returning taskId dup-handle-r1, both render, zero conditions, no ambiguity guard exists. PR-4a confirmed - a legacy-shaped manifest binds and renders with liveness and declaredNotObserved empty, so the fallback clause protects RENDERING and not merely validation. PR-4b confirmed exactly - 6 manifests, member counts 1/2/4/6/8/10, 10 distinct member subjects all runtime ids all keyed subject plus role, owning 16 returned records of which 0 carry task_id. PR-6 confirmed and STRONGER - the cited dispatched record's key set is exact and 83 dispatched records corpus-wide carry ZERO task_id. ADJUDICATION 3 ruled - the path IS reopened and the conductor's statement to the owner that the launch payload carries no structured field was FALSE, since description is present 98/98 and Copilot also carries name; reading a whole dedicated field is not the parsing C3R-1e forbids at Produce-Artifact.ps1:278-282, and Q2 is correctly escalated WITHOUT pre-answering, the 33 scar's remedy done right - but description is operator-chosen free text with no schema or pattern, its 98/98 uniqueness is an accident of prose variety, and the author's own log proves operator-chosen launch labels collide. ADJUDICATION 5 ruled - every legacy number verified, the fallback clause is necessary, nothing retroactively invalidates a landed record, the one theoretical unbind path is measured unreachable at 0 of 16 and pinned by V7, and Q4 is ruled in the author's favour. Section 9b is COMPLETE with no blanks - 8 finding rows, 5 ruling rows, 2 voluntary note rows, the R1-M1 appeal loud and evidenced and conceding its core charge, the owner-ruling appeal routed to Q1 rather than resolved. Section 2b is a LEGITIMATE template extension mandated by the probe doctrine, reordering and removing nothing, staling no document. Section 10's questions are real, not soft spots. The self-disclosure is exemplary, the redone injection is genuinely non-vacuous - I fault-injected a bad citation on an out-of-repo clone and watched the gate red BY NAME on this document, restoring byte-identical at sha256 77AD7EE2AF6DAECF2D888248BE8FB224A37861D415E4C55D09AD2F2B19838F42 with 0 dirty - and nothing in the document rests on the vacuous window since every substantive claim is now re-derived by a second party. Suites observed by me at 9e18799 attached to the branch - scripts/tests 223 passed 0 failed 4 skipped, citation gates 43 passed 0 failed 4 skipped, probes 29/0/0, store-checks 271/0/0, NO detached-HEAD skip delta because I ran attached. LAW-FIRST DIAGNOSTIC - the AUTHOR found the laws, not me; I opened every constitution range and every cited coordinate and found all quotes verbatim-accurate with one off-by-one row, and ZERO absent constraints, against the founding wreckage's seven-for-seven found by the reviewer.
abstract: Adversarial design review of the manifest member identity design for issue 87 at 9e18799 over base 51fb403, one commit adding 564 lines. REJECT on 3 Major. The design's central argument is CORRECT and I confirmed it independently by building board/server from source and running my own 16-record store through real HTTP - shape B renders a member as declared-not-yet-observed while the same wire carries that member's returned record under taskId, with ZERO board conditions, and the human-facing string is stronger than the design claims; the round-1 reviewer had measured shape B only against an empty store, so the design's inversion of the owner's understanding is right and shape B must not be adopted. Five of six probes reproduce exactly, including the legacy corpus at 6 manifests, 10 subjects, 16 returned records and 0 task_ids, and the whole-corpus fact that 83 dispatched records carry no task_id. The REJECT rests elsewhere. First, the probe underpinning the reopened dispatch-time path is FALSE as published - the launch-payload log carries TWO tool_input key sets, not one, and 20 Copilot-family payloads logged days earlier sat in the very file the author read while a probe row declared no Copilot dispatch available; the conclusion survives and is stronger than claimed, since description is present on both families, but the evidence must be corrected and a landed adapter vector reconciled against it. Second, the design traces its own Law 1 requirement to the wire and stops one hop short of the rendered sentence a human reads, naming no view file and no view tests in contracts-touched, and its consist requirement collides with a wire required-set it never mentions. Third, the author's own section 0 test fires - an ordering rule sits in prose outside the deferred format half with no conformance vector, which is the founding scar's exact mechanism caught by the one instrument that could catch it. Five Minors cover an off-by-one doc-map citation the citation gate explicitly cannot catch, two desk-provable facts parked in the probe list which I settled in one command, an imprecise unchanged claim about yard assignment, a deferred obligation that lands in no vector alongside an unenumerated presumed-lost lifecycle, and a vigilance dependency the design re-imports against its own premise with live collision evidence in its own log. The law-first diagnostic reads clean - every constraint was on the page before the mechanism, every quote verbatim, and I found no law the author missed.
```