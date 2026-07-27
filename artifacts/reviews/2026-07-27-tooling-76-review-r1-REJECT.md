<!-- starcar-integrity: sha256=e8e0a4440497ff21a40c6f011f36b431e62a21608d8a04130f3bb17535519a61 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Tooling train #76 train-manifest minting, review round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review
Round: 1
Target: `car/tooling-76 HEAD 8f9916c`
Base reviewed: `3458499716f1ec933e2ede539198216b2ee0b09d`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a60fcb87fea862f02`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `3458499716f1ec933e2ede539198216b2ee0b09d` |

| Dispatch, the locator within the session | `a60fcb87fea862f02` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 3458499716f1ec933e2ede539198216b2ee0b09d
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

---

# VERDICT: **REJECT** — 3 Major, 5 Minor

The car's empirical work is genuinely excellent and I confirm its headline claim independently. The REJECT rests on documentation staleness, an unnecessary contract widening that a measured alternative defeats, and an incomplete disclosure that leaves the train's headline goal undelivered and untracked.

## BASE-DELTA (#13)

Worktree `<repo>-wt\review-tooling-76`, HEAD `8f9916c3e8911e2421565405bb3d6d8fa16907d3`, **detached, 0 dirty** — verified before any command. Base `3458499716f1ec933e2ede539198216b2ee0b09d`.

```
 schema/starcar-manifest.schema.json       |  14 +-
 scripts/New-TrainManifest.ps1             | 342 +++++++++++++++++++++++++++
 scripts/tests/New-TrainManifest.Tests.ps1 | 316 ++++++++++++++++++++++++
 3 files changed, 669 insertions(+), 3 deletions(-)
```

Shared checkout `<repo>` verified untouched (0 dirty, HEAD `afadc84`).

## Suites — observed by me at 8f9916c

| Suite | Car claimed | I observed | Reconciles |
|---|---|---|---|
| `scripts/tests` | 244 P / 0 F / 4 S | **243 P / 0 F / 5 S** (248 total) | yes — detached-HEAD delta, below |
| baseline (minus new file) | 223 | **222 P / 5 S** (227 total) | yes — 223 P / 4 S on a branch |
| `scripts/store-checks` | 267/267 | **267 P / 0 F** | exact |
| `scripts/probes` | 29/29 | **29 P / 0 F** | exact — #79 `ManifestBoardJoin` **not** reded |
| Go board | 98 PASS | **98 top-level PASS**, 118 incl. subtests, `go vet` clean, exit 0 | exact on the top-level convention |
| `board/web` node | 209 pass / 5 fail | **209 pass / 5 failing files** | exact |

**Detached-HEAD skip delta (mine, not a defect):** the one-test difference is `SessionStartGuardRunner.Tests.ps1`'s *"running the REAL guards prints [ci-baseline]'s marker ONLY when attached to a branch"*, which skips on my detached HEAD and passed on the car's branch. 243+1 = 244, 5−1 = 4. Total 248 both ways.

**Go count note (not a finding):** the car's "98" is top-level test functions; CI's own counter (`ci.yml:287-290`, distinct `run` actions) counts **118**. Both defensible; flagging so nobody reconciles against the wrong number later.

---

# ADJUDICATION 1 — the car disproved the conductor's premise. **The car is right. Say it plainly.**

I did not take this on report. I built `board/server` from source (`go build -o … ./server`, exit 0), constructed a scratch store with a **four-shape member matrix** in one manifest, and read real HTTP `/api/snapshot`.

Observed, verbatim:

```json
{"id":"train:rev76-matrix","title":"Reviewer matrix probe",
 "cars":[{"subject":"bbbbbbbbbbbbbbbbb","role":"car","state":"returned",...,"taskId":"rev76-B-both"}],
 "declaredNotObserved":["ccccccccccccccccc","ddddddddddddddddd"],
 "tickets":["#76"]}
```

Member A (`task_id: rev76-A-taskid-only`, **no subject**) appears in **neither `cars` nor `declaredNotObserved`**, and **zero board conditions** were raised. Members C and D (subject present, no record) *do* reach `declaredNotObserved`. The task_id-only member is silently gone.

**(a) Root-cause analysis: correct AND complete.** `board/assemble/assemble.go:304` `subject, _ := mm["subject"].(string)` type-asserts an absent key to `""`; `:307` `if subject == "" { continue }` drops the member from the returned slice; `Assemble`'s per-member loop at `:106` iterates only survivors, so the `DeclaredNotObserved` append at `:112` is unreachable for that member. Every hop the car named is exactly right, including that the drop precedes the `dispatchBySubject` lookup at `:110`.

**(b) The pin is HONEST.** `New-TrainManifest.Tests.ps1:308-314` asserts `cars.Count = 0` **and** `declaredNotObserved.Count = 0` — today's real behaviour, not the hoped-for behaviour. That is Law 1 done properly: it gives a future board fix a red to turn green rather than asserting a fiction. I fault-injected it (F1) and it reds correctly when the producer stops emitting subject-less members.

**(c) Staying out of `board/` was the RIGHT call.** `board/` was excluded by the dispatch comment; #79's probe guards that surface; and the fix is a design question about what a subject-less member should render as. Filing #85 (verified: OPEN, `area:view`, on the project board, technically accurate) rather than improvising is the honest-stop doctrine working.

**This is the second time in two days a car has disproved a conductor premise by running the thing. That is the process working, and it is the best part of this diff.** The conductor's binding amendment asserted the behaviour "needs no board change"; the car checked instead of trusting, and the conductor's sentence was wrong.

---

# ADJUDICATION 2 — the schema contract change. **This is where the diff fails.**

**(b) The `anyOf` DOES enforce what it claims — measured, all seven directions:**

| Member shape | Result |
|---|---|
| `task_id` + `role` | **VALID** |
| `subject` + `role` (legacy) | **VALID** |
| both + `role` | **VALID** |
| **neither**, `role` only | **REJECTED** — `Required properties ["task_id"] are not present` \| `… ["subject"] …` |
| `task_id`, no `role` | REJECTED |
| `subject`, no `role` | REJECTED |
| `{}` | REJECTED |

`role` stays unconditionally required in every combination. The gate is real, not decorative.

**(c) NO-BACKFILL doctrine HONORED — verified, and the car's evidence is stronger than I first credited.** All six `artifacts/train-board-v0/intent-*.json` records validate against **both** schemas at HEAD; every one of their 31 members is `subject+role` with no `task_id`. Crucially, `StoreIntegrity.Tests.ps1:121-136` **does** layer `starcar-manifest.schema.json` over every `^train:` record — so the car's "267/267 unaffected" is genuine NO-BACKFILL evidence, not a base-schema-only result. No landed record was retrofitted or retroactively invalidated. **This part is right.**

### **(a) The relaxation is NOT demonstrably necessary — R1-M1 (Major).**

The brief forbade quietly relaxing `required` to make an implementation pass. The car did not do it *quietly* — it reasoned on the page in three places. But it never examined the alternative that removes the need entirely, so the widening is unjustified rather than merely undocumented.

**The unexamined alternative:** declare a plan member with `task_id` **and** `subject` both set to the shop-minted handle; amendment then overwrites `subject` with the runtime id while `task_id` survives untouched. I built and ran it:

```json
{"id":"train:alt-shape","title":"Alternative shape","cars":[],
 "declaredNotObserved":["tooling-76-car-r1","tooling-76-review-r1"],"tickets":["#76"]}
```

Measured properties of the alternative:
- **Validates against the PRE-#76 `required: ["subject","role"]` schema — `True`.** Zero contract widening; `task_id` lands as a purely additive optional property.
- Renders **readable human names** in `declaredNotObserved` — precisely the surface the corrected design demanded ("*renders in declaredNotObserved with a READABLE name … that IS the plan-vs-actual surface*").
- Zero board conditions, zero board changes.
- Satisfies the mid-flight amendment's actual *requirement* — "a member carries BOTH identities … the human name is stable before launch, in flight, and after return" — because `task_id` is never destroyed.

The shipped shape widens the contract to enable a member that is **invisible**; the un-widened alternative delivers the design's stated goal. The car's own rule "*Never a placeholder: a member's subject is either the genuine dispatch id or not present at all*" (`schema/starcar-manifest.schema.json`, `members.subject` description) is self-authored in this commit and is what forecloses the alternative — it is not inherited doctrine. The conductor's amendment did invite "*a defensible alternative*" and an honest stop. Having discovered that its chosen shape defeats the brief's own purpose, the car had the evidence in hand to escalate; it shipped and ticketed instead.

**(d) Description texts — mostly TRUE, one overclaim (R1-m3).** The `subject` description's board-side disclosure is verbatim accurate against `assemble.go:304-307`; I confirmed every clause. But the `task_id` description asserts "*present on every member declared by New-TrainManifest.ps1 going forward*", and `-Members`' param doc (`:83-85`) calls `task_id` "mandatory". **Measured: a subject-only member mints successfully** (`train:subjonly` written, valid, sealed). Two documents claim an invariant the code does not enforce.

---

# ADJUDICATION 3 — the TDD deviation. **Compensation was weaker than claimed; the tests are nonetheless non-vacuous.**

The car's `CommandNotFoundException` demonstration proves only that the tests *invoke* the script. It does **not** prove behaviour-sensitivity. So I injected six **behavioural** faults on an out-of-repo clone and ran the suite each time (baseline in clone: **21/21 green**).

| Fault (behaviour, not existence) | Result | Red for its own stated reason? |
|---|---|---|
| **F1** mint emits a placeholder `subject` | 18 P / **3 F** | Yes — "*Expected $null or empty, but got string subject=PLACEHOLDER-tooling-76-car-r1*"; also reds the board-gap pin |
| **F2** seal over NON-compact JSON (2nd hashing rule) | 20 P / **1 F** | Yes — integrity mismatch, `sha256:38b38a…` vs `sha256:ac31bb…` |
| **F3** amend replaces `task_id` instead of adding `subject` | 20 P / **1 F** | Yes — the task_id-keyed lookup finds nothing |
| **F4** amend writes in place (no supersession) | 13 P / **8 F** | Yes — byte-identical, new-record, fold-winner and non-vacuity tests all red |
| **F5** schema validation skipped | 18 P / **3 F** | Yes — both `anyOf`/`role` rejection tests red |
| **F6** amend silently no-ops on unmatched task_id | 20 P / **1 F** | Yes — the named-error test reds |

**Ruling: every test I probed is behaviour-sensitive; none passes regardless of behaviour.** The suite is genuinely non-vacuous, so the deviation caused no coverage harm — but the car's own compensation did not establish this, and the report presents it as if it did. Disclosed-and-weaker, not disclosed-and-wrong. I record it as a Note, not a finding, because the substance holds.

**Restore verified byte-identical:** clone `git status` = **0 dirty**; restored `scripts/New-TrainManifest.ps1` sha256 = `9BFC4097E2363D8B3796B7C3B1471CA806F840579893EE607DD2C1D9E21D5417`. All injection ran on the out-of-repo clone; the review worktree was never mutated.

---

# ADJUDICATION 4 — the two self-found bugs. **Both fixes are sound; the placeholder leaves no real gap.**

**(i) `Join-Path` rooted-second-argument.** Fix at `:303-307` uses `[System.IO.Path]::IsPathRooted` before combining. Correct, and load-bearing — every absolute `-StoreRoot` in my probes worked.

**(ii) The placeholder-sealed validation copy (`:212-215`).** I tested the gap directly rather than reasoning about it.

- **Definitive test:** minted two records into the clone's **real** `artifacts/` store, then ran the real suite — **store-checks 269/269, 0 failed**. The minted records pass the base schema, the layered manifest schema, **and** the independent integrity recompute in `StoreIntegrity.Tests.ps1:64-70`.
- **Malformed is structurally unreachable:** `Get-Sha256Hex` (`scripts/Artifact.psm1:140`) returns `BitConverter.ToString(...) -replace '-','' | ToLower()` — always 64 lowercase hex, always matching `^sha256:[0-9a-f]{64}$`.
- **Wrong-value hunt:** five hostile titles (non-ASCII `ñ`/`é`, `&lt;b&gt;&amp;&lt;/b&gt;`, embedded quotes + backslashes, an embedded newline, forward slashes) — **all five: `integrityVerifies=True, baseSchemaValid=True, integrityFormat=True`.** No serialization round-trip divergence found.

**Ruling: no practical validation gap.** The placeholder is honest engineering — it validates shape when shape is all that can be validated, and the value it stands in for is generated by a function that cannot produce a non-conforming result.

---

# THE SENTENCE CHECK — producer → store → scan → fold → assemble → wire → client

| Hop | Location | What crosses |
|---|---|---|
| 1. Member normalise | `scripts/New-TrainManifest.ps1:137-146` | ordered dict, only present keys, fixed order `task_id, subject, role, gate` |
| 2. Payload assembly | `:184`, `:195-199` | `manifest{title,tickets,members}` |
| 3. Pre-write validation | `:212-215` | throwaway copy + placeholder integrity, **both** schemas (`:156-159`) |
| 4. **Seal** | `:217-218` → `scripts/Artifact.psm1:124-141` | `sha256:` + `Get-Sha256Hex(compact body)` |
| 5. Write | `:266-269`, `:271-273` | `&lt;store&gt;/&lt;subject ':'→'-'&gt;/intent-&lt;compactAt&gt;.json`, UTF-8 no BOM |
| 6. Scan | `board/store` recursive `*.json` (per `assemble.go:326-328`) | raw record |
| 7. Fold | `board/fold/algorithm.go:130` | requires record-level `subject`/`kind`; latest-`at` intent wins |
| 8. **Assemble** | `board/assemble/assemble.go:94` → `:286-313` | `manifestPayload` reads **only** `subject`(`:304`), `role`(`:305`), `gate`(`:306`) |
| 9. Wire | `board/assemble/types.go:45` | `DeclaredNotObserved []string \`json:"declaredNotObserved"\`` |
| 10. Client | `/api/snapshot` → `lanes[trains].data.trains[]` | observed live |

### **Where it BREAKS**

**Break 1 (adjudication 1, ticketed as #85):** at hop 8, `assemble.go:307` — a `task_id`-only member is dropped before hop 9 exists for it. `declaredNotObserved` is `[]`, `cars` is `[]`, conditions are `[]`. Confirmed live.

**Break 2 — NOT disclosed anywhere, and it is R1-M2 (Major).** `manifestPayload` (`:304-306`) **never reads `task_id` at all.** The board's only task-id source is `taskIDsBySubject` (`:426-437`) → `taskIDForReturnedSubject` (`:450-462`), which reads `r.Fields["task_id"]` off **returned records exclusively**. Therefore a manifest member's `task_id` — the entire field this commit adds to the contract — **is read by nothing in this repo.**

Measured, an amended member (`task_id: tooling-76-car-r1`, `subject: ad9b6aad6153127f4`) with a dispatched-only record:

```json
"cars":[{"subject":"ad9b6aad6153127f4","role":"car","state":"overdue",
         "at":"2026-07-27T10:05:00Z","recordDir":"ad9b6aad6153127f4"}]
```

**No `taskId` field at all** — in either the trains lane or the dispatches lane. That is precisely the symptom the owner reported on the live board and that triggered the mid-flight redesign. The conductor's amendment asserted "*Naming an in-flight dispatch from its MANIFEST MEMBERSHIP is the non-brittle route, and it is why the both-identities shape matters*". **That sentence is false against the code at HEAD** (`assemble.go:414` even says so: "*dispatched records carry no task_id yet, pending #76's producer work*"). The car verified one clause of that comment by running the board and left the adjacent clause — the one carrying the train's headline goal — unchecked and undisclosed. #85 covers only the `declaredNotObserved` drop.

### The seal — Law 6 CLEAN

`New-TrainManifest.ps1:217-218` is byte-for-byte the idiom at `Produce-Artifact.ps1:364-365`, both calling the single owner `Get-Sha256Hex` (`Artifact.psm1:124-141`, whose own docstring names itself "THE ONE OWNER"). **No second hashing rule introduced.** Independently verified: F2 proves the test detects a changed rule; store-checks 269/269 proves minted records verify under the repo's own independent recompute.

---

# FINDINGS

### Major (any Major = REJECT)

**R1-M1 — the `required` relaxation is not demonstrably necessary; a measured alternative serves the design without it.**
`schema/starcar-manifest.schema.json:45-49`. Evidence above: the seed-subject-with-task-id shape validates against the pre-#76 `required: ["subject","role"]` (`True`), needs no board change, and renders `declaredNotObserved:["tooling-76-car-r1","tooling-76-review-r1"]` — the readable plan-vs-actual surface the corrected design asked for — where the shipped shape renders the member invisible. The brief asked exactly this question; the answer is that the contract was widened to enable the worse of two shapes.

**R1-M2 — undisclosed: a manifest member's `task_id` is read by nothing, and in-flight naming remains unfixed and untracked.**
`board/assemble/assemble.go:304-306` (task_id absent from `manifestPayload`), `:426-462` (task-id sourced only from returned records). Measured: an in-flight member renders with no `taskId`. The mid-flight comment's manifest-membership-naming premise is unmet; #85 does not cover it; no ticket exists. The car's disclosure names one consequence of "assemble keys strictly on subject" and omits the second, which is the one the owner actually asked to see.

**R1-M3 — stale document: the spec that OWNS this contract was left contradicting it.**
`docs/specs/2026-07-23-yard-board-spec.md:46` still reads `members[]{subject, role, gate?}` — `subject` presented as unconditional (the file's own `?` convention marks optional), and `task_id` absent entirely — under the heading **"## 2. The manifest contract"**, "per `schema/starcar-manifest.schema.json`". The schema's own description simultaneously cites "*Spec 2026-07-23-yard-board S2*" as this contract's origin, so the two documents now cite each other and disagree.
Not a fossil: `docs/doc-map.md:53` classifies `docs/specs/*` as **"LIVING while binding; amendment blocks, never rewrites"**; the spec's header reads `Status: Open`, `rev 2 APPROVED`; and the amendment mechanism is already in the file at **§7b "Plan-rung amendments (binding; supersede the named text above)"** with two amendments recorded, one explicitly reversing prior text. `StoreIntegrity.Tests.ps1:109` cites "spec S7b amendment 2" by name, proving the mechanism is live and consumed. The same-commit rule (NORTH STAR: "the commit that invalidates a document updates that document, in the same commit") applies and was not honored.

### Minor

**R1-m1 — the commit failure path reports a confidently wrong cause.** `scripts/New-TrainManifest.ps1:285-291` pipes git's stdout+stderr to `Out-Null`, then throws `"could not commit … after 3 attempts (index contention?)"` for *any* failure. Observed: an author-identity failure (`fatal: unable to auto-detect email address`) surfaced as the index-contention message. Aggravating: the record is already written (`:273`) and `git add` already succeeded, so the operator is left with an uncommitted-but-staged record and a misleading diagnosis. Law 1 / "error messages must be human-readable and actionable".

**R1-m2 — the "mirrors" claim is inaccurate; PowerShell `ValidatePattern` is case-insensitive.** `:70-74` says the literal "mirrors" the schema pattern; `New-TrainManifest.Tests.ps1:102` attributes enforcement to "an early ValidatePattern gate" and `:108` names the uppercase test accordingly. **Measured: `ValidatePattern('^train:[a-z0-9][a-z0-9-]*$')` ACCEPTS `train:Tooling-76`.** The uppercase rejection comes solely from the schema (proven by F5: with schema validation removed, `train-Tooling-76/` was written to disk). The behaviour is correct; the attribution is wrong in two files.

**R1-m3 — doc claims an invariant the code does not enforce.** `schema/starcar-manifest.schema.json` `members.task_id` description ("*present on every member declared by New-TrainManifest.ps1 going forward*") and `scripts/New-TrainManifest.ps1:83-85` ("*task_id (mandatory)*"). Measured: a subject-only member mints successfully.

**R1-m4 — a new silent-loss path is created and recorded on no gated-surface document.** Before this commit the schema rejected subject-less members, making `assemble.go:307` unreachable for schema-valid records. After it, the schema *admits* a shape the board discards with **zero board conditions**. `docs/contracts/gating-matrix.md` — whose doc-map row reads "*Reviewers reject diffs that leave it stale*" — has no row naming this. Law 4 (silent loss). Partly mitigated by #85.

**R1-m5 — the in-code disclosure is stale on arrival.** `scripts/New-TrainManifest.ps1:40-42` says the gap is "*reported for the owner/conductor to judge and, if warranted, file as a follow-on board-side ticket*"; #85 **was** filed. Neither the script header, the test header (`:17-23`), nor the schema description cites #85, so a reader chasing the disclosure has no pointer to the tracked owner.

### Notes (no action required)

- **N1** — Adjudication 3's compensation was weaker than the report implies (existence-failure ≠ behaviour-sensitivity), but my six injections establish the suite is genuinely non-vacuous. Substance holds.
- **N2** — `board/web` attribution **confirmed**: the diff touches zero `board/web` files (`git diff --name-only` = 3 files, all `schema/` + `scripts/`); `board/web/node_modules` is absent in my worktree too; all 5 failures are `ERR_MODULE_NOT_FOUND: Cannot find package 'playwright'` across the five `browser-*.test.js` files. Pre-existing environment gap, unrelated to this diff.
- **N3** — #79's `ManifestBoardJoin` probe is **not** a guard against the #85 class: its fixture members all carry `subject` (`ManifestBoardJoin.Probes.Tests.ps1:194-197,225`) and none carries `task_id`. Issue #85's cross-ref stating this is accurate. Probe unaffected by the schema change (29/29).
- **N4** — Citation check (#42) **PASSES**: `CodeCitationPolicy.Tests.ps1` 13/13; both new files carry the standalone bare marker (`New-TrainManifest.ps1:64`, `New-TrainManifest.Tests.ps1:25`) plus 6 and 10 in-context `#76` citations; the schema edit carries symbol-form `#76` on the changed description and both new/changed property descriptions. Right ticket number throughout.
- **N5** — `docs/contracts/state-ledger.md` is **not** made stale: this adds no mutable service state. Design docs carry no member-contract statement, so R1-M3 is confined to the spec.

---

## THE WORKED EXAMPLE — both commands RUN AS WRITTEN

Executed against the out-of-repo clone's real `artifacts/` store, default (committing) path:

```
New-TrainManifest: wrote artifacts\train-tooling-76\intent-20260727T110000Z.json
git log -1: dc55c2d harness: train manifest intent record for train:tooling-76 (#76)
dirty files after mint: 0

New-TrainManifest: wrote artifacts\train-tooling-76\intent-20260727T110500Z.json
git log -1: 9aa1b94 harness: train manifest intent record for train:tooling-76 (#76)
dirty files after amend: 0
```

The amended record is correct: `task_id` preserved, `subject` added, canonical member order restored (`task_id, subject, role`), the untargeted gate member left with no `subject`, and the prior record untouched. **The worked example executes; the conductor can paste it.** One caveat for the conductor: the commit path requires a configured `user.email`/`user.name` — absent one, you get R1-m1's misleading "index contention?" message.

## UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

All evidence above is re-derivable from the repo alone; nothing rests on session-local state. Recipe: `go build -o &lt;exe&gt; ./server` from `board/`; mint into a scratch dir with `scripts/New-TrainManifest.ps1 -StoreRoot &lt;dir&gt; -NoCommit`; run the exe with `STARCAR_STORE_PATH=&lt;dir&gt;`, `STARCAR_PORT=0`, `STARCAR_POLL_MS=150`; read `/api/snapshot`. Hand-sealed dispatched/returned fixtures use `Get-Sha256Hex` over the compact body, never a second rule. My probe scripts live in the session scratchpad (`rev76-e2e.ps1`, `rev76-schema.ps1`, `rev76-faults.ps1`, `rev76-faults2.ps1`, `rev76-worked.ps1`, `rev76-alt.ps1`, `rev76-inflight.ps1`) and are session-local — the recipe above, not those files, is the durable form.

## CONSTITUTION CHECK

- **Law 1 (no confident falsehood)** — *Honored* in the board-gap pin (`Tests:308-314` asserts today's truth, not the hope) and in the schema's `subject` description, which I verified clause-by-clause against `assemble.go:304-307`. *Violated* at R1-M3 (spec:46 states a contract the code no longer honors), R1-m1 (wrong cause asserted), R1-m2 (wrong mechanism attributed), R1-m3 (unenforced invariant asserted).
- **Law 4 (never silently drop)** — *Violated in effect* at R1-m4: this diff converts a schema-impossible state into a schema-legal, silently-discarded one, with zero board conditions. Disclosed and ticketed (#85), but recorded on no gated-surface document.
- **Law 6 (one owner per rule)** — *Honored, and this is the diff's strongest leg.* `Get-Sha256Hex` (`Artifact.psm1:124-141`) is the sole hashing owner; `New-TrainManifest.ps1:217-218` matches `Produce-Artifact.ps1:364-365` exactly; `Get-CurrentManifest` (`:231-261`) reads latest-`at` to locate a record and explicitly does not re-implement `board/fold`'s selection. F2 proves a second rule would be caught. Minted records verify under the independent recompute at `StoreIntegrity.Tests.ps1:64-70` (269/269).
- **Law 7 (the stranger / kinds and roles as data)** — *Honored*: no role or kind taxonomy is hardcoded in the new script; `role` and `gate` pass through as opaque caller data, and `schema/vocab/roles.json` remains the vocabulary owner. *Weakened* at R1-m5: a stranger reading the disclosure has no pointer to #85.
- **NO-BACKFILL doctrine** — **Honored, and verified rather than assumed.** All six pre-#76 records validate unchanged against both schemas; no member was retrofitted; the car explicitly declined to make `task_id` unconditionally required *because* it would have invalidated them. This was the right call and the reasoning is on the page.
- **Living contracts / same-commit doc rule** — *Violated* at R1-M3.
- **Honest stop as a success outcome** — *Honored* on adjudication 1: the car ran the thing, disproved a binding premise, refused to fix out of scope, pinned the truth, and filed a board-tracked ticket. That behaviour is exemplary and I want it on the record separately from the REJECT.

## What a fix cycle needs (same car, delta re-review)

1. **R1-M1** — either adopt the seed-subject shape and revert the `required` relaxation, or escalate to the owner with both measured board outputs (I have supplied them) and let the owner rule. Do not resolve this one unilaterally in either direction.
2. **R1-M2** — file the in-flight-naming ticket and state plainly in the report and the in-code disclosure that manifest `task_id` is currently read by nothing.
3. **R1-M3** — add a §7b amendment block to the spec restating the member contract, same commit.
4. **R1-m1..m5** — mechanical.

Items 1 and 2 are the ones that matter; 3 is cheap and non-negotiable under this repo's own rules.

```starcar-artifact
task-id: tooling-76-review-r1
outcome: REJECT
findings: 3 Major, 5 Minor, 5 Notes at round 1. R1-M1 (Major) the schema `required` relaxation is not demonstrably necessary - I built board/server and measured an alternative member shape (task_id AND subject both seeded with the shop-minted handle, amendment overwrites subject while task_id survives) that validates against the PRE-76 required subject-plus-role schema (True), needs zero board changes, and renders declaredNotObserved as the readable names tooling-76-car-r1 / tooling-76-review-r1 - exactly the plan-vs-actual surface the corrected design demanded - where the shipped shape renders the member invisible; the contract was widened to enable the worse of two shapes. R1-M2 (Major) undisclosed - board/assemble/assemble.go:304-306 manifestPayload never reads task_id at all and :426-462 taskIDsBySubject sources task-id exclusively from RETURNED records, so a manifest member's task_id is read by nothing in the repo; measured, an in-flight dispatched-only member renders with no taskId field in either lane, meaning the mid-flight comment's naming-an-in-flight-dispatch-from-manifest-membership premise is false against HEAD, the owner's headline goal is undelivered, and issue 85 does not cover it. R1-M3 (Major) stale document - docs/specs/2026-07-23-yard-board-spec.md:46 under the heading The manifest contract still states members subject-role-gate-optional with task_id absent, while doc-map.md:53 classifies specs LIVING while binding, the spec header reads Status Open rev 2 APPROVED, and its own section 7b binding-amendment mechanism already carries two amendments (one cited by name at StoreIntegrity.Tests.ps1:109); the schema's description cites Spec S2 as this contract's origin, so the two documents now cite each other and disagree. Minors - R1-m1 the commit path pipes git stderr to Out-Null and throws a confidently wrong index-contention cause for any failure (observed with an author-identity failure) leaving a written-and-staged record; R1-m2 PowerShell ValidatePattern is case-insensitive and ACCEPTS train:Tooling-76, so the mirrors claim at :70-74 and the test Context at :102/:108 both attribute the uppercase catch to the wrong mechanism (it is the schema); R1-m3 the schema task_id description and the -Members param doc both assert task_id is mandatory but a subject-only member mints successfully (measured); R1-m4 the widened schema admits a shape the board discards with zero board conditions, a new silent-loss path recorded on no gated-surface document; R1-m5 the in-code disclosure says a ticket may be filed if warranted, but 85 was filed and is cited nowhere in the script, tests, or schema. VERIFIED AND CONFIRMED - adjudication 1 the car is RIGHT end to end - I built board/server from source and ran a four-shape member matrix through real HTTP /api/snapshot - a task_id-only member appears in neither cars nor declaredNotObserved with zero conditions, root cause correct and complete, the pin is an honest pin of today's behaviour not the hope, and staying out of board/ was the right call. Adjudication 2 the anyOf enforces exactly what it claims across all seven measured directions (neither task_id nor subject REJECTED, each alone VALID, role unconditionally required) and NO-BACKFILL is genuinely honored - all six landed train-board-v0 records validate against BOTH schemas, and StoreIntegrity.Tests.ps1:121-136 does layer the manifest schema so the 267/267 citation is real evidence. Adjudication 3 the car's CommandNotFoundException compensation proves only invocation not behaviour-sensitivity, so I ran six behavioural fault injections on an out-of-repo clone (baseline 21/21): placeholder-subject 3 red, non-compact seal 1 red, task_id-replacing amend 1 red, in-place write 8 red, validation-skipped 3 red, silent-no-op amend 1 red - every one red for its own stated reason, suite genuinely non-vacuous, restore byte-identical (0 dirty, sha256 9BFC4097E2363D8B3796B7C3B1471CA806F840579893EE607DD2C1D9E21D5417). Adjudication 4 both fixes sound and the placeholder leaves NO practical gap - minted records into a real artifacts store scored store-checks 269/269 including the independent integrity recompute, Get-Sha256Hex structurally cannot emit a non-conforming value, and five hostile-title round-trips all verified True. Law 6 clean - one hashing owner, New-TrainManifest.ps1:217-218 matches Produce-Artifact.ps1:364-365 exactly, no second rule. Worked example RUNS AS WRITTEN - both mint and amend committed cleanly with correct field order and preserved task_id. Suites observed at 8f9916c - scripts/tests 243 passed 0 failed 5 skipped (car's 244/0/4 reconciles exactly via my detached-HEAD skip of SessionStartGuardRunner's branch-conditional test), baseline 222+5skip confirming the 223 claim, store-checks 267/267, probes 29/29 with 79's ManifestBoardJoin NOT reded, Go board 98 top-level PASS (118 including subtests) vet clean, board/web 209 pass 5 fail all ERR_MODULE_NOT_FOUND playwright with the diff touching zero board/web files. Citation check 42 passes 13/13 with bare #76 markers in both new files.
abstract: Adversarial sentence-check review of #76 producer-side train-manifest minting tooling at 8f9916c over base 3458499. REJECT on 3 Major. The car's central empirical claim is CONFIRMED independently - I built board/server and observed a task_id-only manifest member vanish from both cars and declaredNotObserved with zero board conditions, exactly as reported; its root-cause analysis is correct and complete, its red test is an honest pin of today's behaviour, and staying out of board/ was the right call. That is the process working and it is the best part of this diff. The REJECT rests elsewhere. First, the schema required-relaxation is not demonstrably necessary - I measured an alternative member shape that satisfies the corrected design's both-identities requirement, validates against the unmodified pre-76 contract, needs no board change, and renders READABLE names in declaredNotObserved where the shipped shape renders the member invisible. Second, an undisclosed gap - the board reads manifest task_id nowhere, so in-flight rows still render the runtime hash and the train's headline goal is undelivered and untracked, the conductor's own premise about naming from manifest membership being false against HEAD. Third, the spec that owns this contract was left stating the superseded member shape despite a live in-file amendment mechanism and a LIVING classification. Five Minors cover a misleading commit-failure diagnosis, a case-insensitive ValidatePattern mis-attributed in two files, an unenforced mandatory-task_id claim, an unrecorded new silent-loss path, and a disclosure that never cites the ticket it produced. Six behavioural fault injections on an out-of-repo clone prove the new suite non-vacuous despite a weaker-than-claimed TDD compensation, the placeholder-integrity design leaves no real validation gap (269/269 store-checks on freshly minted records), Law 6 sealing is single-owner and clean, NO-BACKFILL is genuinely honored, and both worked-example commands execute as written.
```