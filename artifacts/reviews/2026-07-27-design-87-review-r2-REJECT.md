<!-- starcar-integrity: sha256=57a116e8204e4ef9d8863762335d278bc56bfa632a5ff407a6f9176f42e5db02 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Design #87 manifest member identity, adversarial design review round 2 (delta)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: adversarial design review (ladder rung 2, delta; cap set on round 3)
Round: 2
Target: `design/member-identity-87 rev 2 HEAD 3c31ed0`
Base reviewed: `9e18799ace9332d6d4b472bb2d46a77f1666bf5c`
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
| Base commit the reviewer read (**the lookup key**) | `9e18799ace9332d6d4b472bb2d46a77f1666bf5c` |

| Dispatch, the locator within the session | `afe18ef8acbb02719` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 9e18799ace9332d6d4b472bb2d46a77f1666bf5c
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: **REJECT** — 2 Major, 3 Minor

**All eight round-1 findings are folded, none appealed, several exceeded.** This is a genuinely strong revision: the author re-derived my measurements instead of copying them, took the harder remedy on DR1-M3, found a defect I missed (`memberClaims`), and **caught a false coordinate in my own round-1 verdict.** The REJECT rests on two defects the round-2 fixes themselves created — a characterization the new §5.7 falsified in three places, and a new vector that cannot be satisfied as specified.

## BASE-DELTA (#13)

Review worktree `<repo>-wt\review-design-87`, **detached** at `3c31ed02330936458842d954666d7c3b88561567`, **0 dirty** — verified before any command. Prior reviewed HEAD `9e18799ace9332d6d4b472bb2d46a77f1666bf5c`.

```
 .../2026-07-27-manifest-member-identity-design.md  | 407 ++++++++++++++++++---
 1 file changed, 347 insertions(+), 60 deletions(-)
```

Matches the author's reported +347/-60 exactly. Detachment confirmed empirically, not just by `git branch`: the `SessionStartGuardRunner` branch-conditional test skipped, which it does only on a detached HEAD.

**Worktree hygiene, the correction that prompted the move:** `<repo>-wt\design-87` was **not touched by me this round** — verified at HEAD `3c31ed0`, 0 dirty, by read-only status only. Shared checkout `<repo>` at `f7fca23`, 0 dirty. All my writes went to the scratchpad; all injection ran on an out-of-repo clone.

---

# REVIEWER SELF-CORRECTION — the timestamp divergence. **The author is right. I was wrong.**

The brief asked me to check which of us was misreading `_probe_logged_at`. I read the raw bytes with no JSON parser:

```
line 42: "_probe_logged_at": "2026-07-24T11:18:40.178633+00:00"
line 61: "_probe_logged_at": "2026-07-25T23:08:35.962940+00:00"
```

The design's rendering is the correct one. **My round-1 verdict published `07:18:40` and `19:08:35` as if they were the field's values; they are local-time renderings.** Root cause, measured:

```
ConvertFrom-Json gives type: System.DateTime      &lt;- not String
ConvertFrom-Json renders as : 07/24/2026 07:18:40
raw substring from the line : "2026-07-24T11:18:40.178633+00:00"
local TZ: Eastern Standard Time (-05:00 base, -04:00 in July)
```

`ConvertFrom-Json` silently coerces an ISO-8601 string to a local `System.DateTime`. I never looked at the raw bytes. Same 20 records, same span — but I stated a coordinate I had not actually observed, in a verdict whose whole standard is that behavioural claims are quoted from observation. **This is the fourth member of the family the hazard list already names: a tool's implicit conversion, invisible until you read raw bytes.** It belongs in `docs/friction-log.md` beside the other three, and I recommend it lands there — it is not the design author's defect and I do not charge it against the document.

The author disclosing a divergence from its reviewer's verdict, rather than quietly adopting my numbers, is the behaviour this shop wants. Recording it as a win for the author and a miss for me.

---

## Suites — observed by me at `3c31ed0`, detached

| Suite | Author claimed | I observed | Reconciles |
|---|---|---|---|
| `scripts/tests` | 223 P / 0 F / 4 S | **222 P / 0 F / 5 S** (227 total) | yes — detached-HEAD delta |
| citation gates | 43 P / 0 F / 4 S | **43 P / 0 F / 4 S** (47 total) | exact |

**Skip delta, named as the brief predicted:** the 5th skip is `run-session-start-guards.sh: agent-pull runner (#50) — "running the REAL guards prints [ci-baseline]'s marker ONLY when attached to a branch"`. 222+1 = 223, 5−1 = 4, total 227 both ways. I ran **attached** at round 1 (223/0/4) and **detached** now; the author ran attached on its branch. The citation-gate suite carries no branch-conditional test, hence no delta there.

**Fault injection on a NEW coordinate — I watched it fire.** The author used `dom-writer.js:481`; I used the round-2 load-bearing producer citation. On a fresh out-of-repo clone at `3c31ed0`, `scripts/Produce-Artifact.ps1:187-190` → `:999888`:

```
PRE-INJECTION  sha256: F7BD34D842D55770DCAE2297F868A7FBF2DFF02D0A04337FD9ED9C2BE97F4436
POST-INJECTION sha256: FDC2635C8C1322C9E6CAA1C78D0BD18F234F817261985C77C2CE378546D81575
INJECTION IS REAL: True

FAILED BY NAME: every resolved citation's line (or range end) is within the target file's line count
Expected $null or empty, but got 'docs/design/2026-07-27-manifest-member-identity-design.md:594 cites
'scripts/Produce-Artifact.ps1:999888' - target file has fewer lines'.
```

27 P / **1 F** / 4 S. **Hazard 2 honoured deliberately:** the Pester call exits non-zero, so I put the restore in a *separate* tool call rather than trusting a combined block to complete, then verified by hash rather than by assumption — restored `F7BD34D8…F4436`, byte-identical, clone 0 dirty.

**The author's own restore verified:** the committed document hashes to `F7BD34D842D55770DCAE2297F868A7FBF2DFF02D0A04337FD9ED9C2BE97F4436` — exactly the value reported. The restore genuinely ran.

---

# THE EIGHT-ID WALK

| ID | Status | Evidence |
|---|---|---|
| **DR1-M1** | **PRESENT — folded, and EXCEEDED** | Corrected at all four locations (§1:81, §2b PR-5:255, §2c:313, §5.7:574-598). Re-derived by the author with the command published at :267, not copied. Adds detail I did not report: Copilot `name` 20/20 populated, **19 distinct** (`probe-dup-name` twice). Root cause named without smoothing ("I sampled the tail of the file and generalised - a reading dressed as a measurement"). §2c's Copilot row flipped from unverifiable to measured. §8:713 gains the adapter-vector reconciliation with an owner. |
| **DR1-M2** | **PRESENT — folded** | New §5.3a:447-476 owns the last hop, quoting the literal string at `dom-writer.js:481`. §8:711-712 gains `dom-writer.js`, `render.js:243-250`, and `board/web/test/**`'s 209 tests, all bound to the SAME car and SAME commit as the wire change, with the reason stated. §5.3:425-445 names the `:137` required-set collision and proposes a shape. §7:692 struck-not-deleted. §6:676 gains the row. Q7 opened. |
| **DR1-M3** | **PRESENT — folded, HARDER remedy taken** | V12 `consist-ordered-membership` at :557, specified RED ON ARRIVAL. The author declined my offer to delete the rule, reasoning that a consist without order is not a consist and §7's unit-rule FLAG is unstatable without adjacency. **That is the right call and better than the remedy I offered.** |
| **DR1-m1** | **PRESENT — folded** | §1:77 now cites `docs/doc-map.md:53` with the axis text quoted. Verified: `:53` IS the `docs/specs/*` row (*"LIVING while binding; amendment blocks, never rewrites"*). It also records in-line that `CitationResolverPolicy.Tests.ps1:12-18` declares this class outside its binding checks, so no future reader mistakes a green gate for a cleared citation. |
| **DR1-m2** | **PRESENT — folded, re-derived** | PR-7 at :257. **I re-measured every number at `3c31ed0` and all six match exactly:** 96 records carry `task_id`, 96 distinct, 0 shared by two subjects, 0 uppercase, 0 whitespace, 0 case-collisions. Store kinds also exact: 83 dispatched / 177 returned / 6 intent / **`presumed-lost` absent entirely = 0**. §2c shrank 6 rows → 4 with the discipline stated at :302-308. |
| **DR1-m3** | **PRESENT — folded, and EXCEEDED** | §5.4:485-501 states the `assignedSubjects` rekey with the false→true flip and the "92 unassigned" symptom. **It also catches `memberClaims` at `assemble.go:107`, which I did not report** — keyed by member identity it would stop detecting two trains claiming one *record*, changing what `manifest-membership-collision` means. Verified against the code; the author is right. |
| **DR1-m4** | **PRESENT — folded, but the fold is defective** | V13:558, V14:559, mapping table :533-540, `presumed-lost` traced through §5.2:388-407 / §6:677 / §5.7:605-609, consist-SHRINKAGE row §6:678. **V13 is unsatisfiable as specified (DR2-M2) and the "all six" claim overstates its own table (DR2-m1).** |
| **DR1-m5** | **PRESENT — folded** | §5.7a:618-659. Real argument, ruled below. |

**Zero ABSENT. Zero DRIFTED.** Every fold is substantive — I checked each against the code and the store rather than against the author's description of it.

**The two self-assessments: both ACCURATE, neither performative.**

- **m3 "actively hid the change" (vs my "imprecise").** Accurate, and framed as effect rather than intent ("rev 1's wording hid the change"). The sentence "Unchanged for bound records" opened §5.4 and asserted the opposite of the truth about the exact field #76 was filed over. The author then went past my finding to `memberClaims`. Self-assessment that arrives with new evidence is not performance.
- **M1's §2c row "worse than a false measurement".** Accurate, and sharper than my finding, which listed it as a consequence. A wrong number invites re-derivation; a false "unverifiable" label **forecloses inquiry** — a downstream car reads it and does not look. The author's ranking is correct and I under-weighted it.

---

# RULINGS ON THE FIVE CLAIMS

### 1. DR1-M1 — the per-family rewrite. **The producer claim is TRUE and materially shrinks D8.**

Verified against the code, not the report. `scripts/Produce-Artifact.ps1:186-190`:

```powershell
} elseif (-not [string]::IsNullOrWhiteSpace($launchAgentType)) {
    # Copilot mode (a): subject = the shop-minted id carried verbatim in
    # tool_input.name (superseded design 3b-8), never scraped from a runtime internal.
    $runtime = 'copilot'; $subjectBasis = 'minted-id'
    $subject = Get-Prop $toolInput 'name'
```

Exactly as claimed. And my own round-1 PR-2 already measured the consequence end to end: a train whose members are shop handles and whose dispatch records' `subject` IS that handle rendered a full consist with `assigned:true` and a live `state:dispatched` member row, zero conditions, no change to anything. **The in-flight epoch is genuinely already closed for the Copilot family.** D8 narrows from "the runtime-id problem" to "the Claude family only". That is a real reduction in scope, correctly derived from the corrected measurement — the finding strengthened the design, as the author says.

**But the narrowing broke three statements elsewhere → DR2-M1.**

### 2. DR1-M2 — **§5.3a genuinely OWNS the rendered string; it does not describe and stop.**

Ownership test, six ways: it names the exact file:line (`dom-writer.js:481`); quotes the literal false string; states the requirement (say only what the board can back); **names the replacement wording** (*"no departure bound"*); assigns an owner; and binds it to the SAME commit as the wire change with the reason stated at §8:711 — *"a wire change without the view leaves the false sentence rendering off a renamed field."* That last clause is the one that proves it is ownership rather than description: it anticipates the failure mode of splitting the work.

**Is the proposed consist shape implementable against the wire it names?** Yes. `yard-snapshot.schema.json:137` requires `["subject","role","state","at"]`; the proposal relaxes `at` to optional and gives `state` an unbound value. The cited precedent is real and I verified it: `recordDir` (`:128-131`, *"Absent when no surviving record names this subject"*) and `taskId` (`:132-135`, *"Absent when this car has not yet returned with one"*) are both optional-when-unknowable and outside the required set. The pattern exists on this exact object.

**Does routing the alternative to Q7 hide a decision? No — the design MAKES the choice** (§5.3:437-441) and routes only the *alternative* for attack, stating "I am genuinely unsure, this is the round-2 decision most likely to be wrong." That is deciding and inviting rejection, which is the opposite of hiding.

**MY Q7 RULING: take the single ordered consist.** The decisive argument is Law 6, which the design gestures at but does not lean on: two arrays that every consumer must re-merge is one structure maintained in two places, and the merge rule gets reimplemented by the view, the node tests, and every future adapter. The `declaredIndex` alternative also leaves the unbound member outside the array a human reads — which is most of what §5.3a exists to fix. The cost (relaxing a required set) is bounded and precedented. **One carry for the implementing car:** `render.js:247-248`'s `isTrainTerminal` reads `declaredNotObserved.length` and must be rewritten against the new shape rather than deleted — §8:711 already flags this, correctly.

### 3. DR1-M3 — **V12 is writable by a stranger, and "red on arrival" is honestly achievable, not aspirational.**

V12 (:557) supplies the fixture concretely — a 4-member manifest declared car/gate/car/gate with members 1 and 3 bound, 2 and 4 unbound — and the assertion: every declared member, exactly once, in declared order, interleaved.

**Red on arrival is achievable.** Today `cars` = [m1, m3] and `declaredNotObserved` = [m2, m4]. Any accessor a vector author picks — the natural one being concatenate-and-compare — yields [m1, m3, m2, m4] ≠ [m1, m2, m3, m4]. The declared interleaving is unrecoverable from the two-array wire, so the vector cannot accidentally pass. That is exactly what the author means by "a V12 that passes before the wire changes has been written to the wire instead of to the requirement."

**Critically, V12 is written to the REQUIREMENT, not to the shape** — which is why it survives Q7 being open. Under either Q7 answer the assertion "declared order recoverable, every member exactly once" is expressible. That is the right level for a design rung. The one thing left to the vector author is how to *read* "the consist" from a given wire; acceptable, and unavoidable while Q7 is unruled.

### 4. The minors.

**m2 — genuinely settled, not declared settled.** All six PR-7 numbers re-derived by me at `3c31ed0` and exact. Q3's closure at :804-814 is the honest form: it states the ruling (exact string equality sufficient), then **bounds it** — *"the corpus is 96 handles deep and days old, and nothing structurally prevents an uppercase handle"* — and names what reopens it. A settled question that carries its own expiry condition is settled properly.

**m4 — the mapping table does NOT prove all six land → DR2-m1.** Five rows are clean. Row 5 ("ambiguity and duplicates") lands the record-side duplicate in V8 but routes the **intra-manifest member duplicate to §10 Q5, an open question, not a vector.** The table discloses this in parentheses; the bolded sentence above it claims all six land in vectors. Overstated by its own table. Also: V12 is filed under "the record-to-member join rule", which it is not — it pins consist order, a rendering concern; the row is carried by V5/V6 alone. Harmless padding, but it inflates the appearance of coverage on the one claim that failed last round.

**m5 — §5.7a is a REAL argument, not a hedge.** Four tests, all passed: (a) it states the symmetry *first* and defends *second*, rather than leading with the defence; (b) the distinction it draws — P7 condemns vigilance whose failure mode is a *falsehood*, not vigilance as such — is substantive, and I verified the D8 row of its table is factually right (prose stamped as `task_id` binds to no member → unattributed → D7 condition → epoch 2; loud and true); (c) it names its own load-bearing dependency out loud (*"it holds only because D7 exists, which is why D7 is not optional garnish"*), which makes it falsifiable; (d) **it quotes evidence against itself** — `probe-dup-name` on two dispatches, from its own capture — and wires D8's collision risk explicitly to D9/V8 while routing prevention-vs-disclosure to Q2. A hedge does not go looking for its own counter-evidence.

### 5. The two self-disclosures.

**(a) The unresolvable verdict path — the disclosure is SUFFICIENT, and it is the correct form.** Verified: `artifacts/reviews/2026-07-27-design-87-review-r1-REJECT.md` is **absent** at `3c31ed0`, **present** at `8c90dbe` (*"harness: land design-87 review r1 verdict (REJECT 3M 5m; law-first diagnostic CLEAN) + index"*) and on `dev` tip. The author verified presence rather than assuming it, and supplied a working `git show dev:...` retrieval.

Ruling: not a defect. The carrier rule *requires* the verdict be named; the alternative — omitting it — is strictly worse. The condition is transient and self-heals at merge, and the disclosure converts an invisible dangling reference into a visible actionable one, which is precisely what Law 1 asks. **No gate catches it because the citation carries no line number and the resolver only checks `file:line` coordinates** — which I confirmed. **One durable observation, not a finding:** this class recurs on *every* delta-reviewed design, since the round-N verdict always lands on `dev` after the branch was cut. The lasting fix is a convention in the design template, not a per-document disclosure. Worth a template note.

**(b) The restore that did not run — verified genuinely restored.** `F7BD34D842D55770DCAE2297F868A7FBF2DFF02D0A04337FD9ED9C2BE97F4436`, matching the author's report, and the working file equals the committed blob (0 dirty). The author caught this by checking the hash rather than trusting the block — which is the whole lesson, and I adopted the same discipline for my own injection above.

---

# FINDINGS

## Major (any Major = REJECT)

### **DR2-M1 — the round-2 §5.7 rewrite makes the fallback clause load-bearing for a LIVE runtime family, and three other places still call it legacy-only. Q4 now asks the reviewer to rule on a false cost basis.**

The chain, verified end to end:

1. **§5.7:593-596** establishes that Copilot dispatched records carry the shop handle in `subject`, via `Produce-Artifact.ps1:186-190` (`$subject = Get-Prop $toolInput 'name'`, `subject_basis = minted-id`) — verified.
2. **No dispatched record of any family carries `task_id`** — `Produce-Artifact.ps1:358` writes it only when `$Kind -eq 'returned'`; corpus confirms 83 dispatched, 0 with `task_id`.
3. Therefore under **§5.5:505-507**, a Copilot dispatched record resolves `task_id` (absent) → **falls back to `subject`** = the handle, and binds to the member whose `task_id` is that handle. **Every Copilot in-flight binding runs through the fallback clause, permanently.**

Three statements are now false or unreachable:

- **§5.5:507-508** — *"The fallback is what keeps the legacy corpus rendering; it is a legacy clause, not a general escape hatch."* It is now the permanent binding mechanism for a live family.
- **§10 Q4:816-817** — *"It exists **solely** for six landed manifests and 10 dispatch subjects."* False. And Q4 asks me to rule on dropping it, offering the cost as *"the `train:board-v0` records stop rendering their consist"*. **The true cost of dropping it is that the entire minted-id family stops binding in flight.** A reviewer or owner ruling on the stated basis would delete a clause a live family depends on — decision-corrupting, in the section whose job is to surface soft spots accurately.
- **§7:691** — stamping `task_id` on minted-id records is *"hygiene, not correctness"*, triggered by *"the D8 wire landing"*. But §5.7 now says Copilot needs no D8 work at all, so if D8 lands Claude-only the trigger never fires and the fallback is permanent by construction rather than by decision.

**This is a defect the round-2 fix created** — the sharpest of the three swirl conditions. The remedy is cheap (three sentences: recharacterize §5.5, restate Q4's cost, re-trigger §7), which is why this is a fixable REJECT and not an escalation.

*For the record, my Q4 ruling under the corrected basis: the fallback clause is not merely worth its price, it is now structural. Keep it, and stop calling it legacy.*

### **DR2-M2 — V13 (`amendment-scope`) is unsatisfiable as specified: the operation it forbids is observationally identical to one it permits, and no enforcer is named.**

**§5.6:558** — *"A superseding manifest MAY add, remove or reorder members and MAY change a member's `role`/`gate`; it MUST NOT change an existing member's identity … an amendment that rewrites a member's `task_id` is REJECTED."*

Take manifest v1 with members `[{task_id: A, role: car}, {task_id: B, role: gate}]`. Now compare:

- **v2 (forbidden):** rewrite A's identity to C → `[{task_id: C, role: car}, {task_id: B, role: gate}]`
- **v2' (permitted):** remove member A, add member C → `[{task_id: C, role: car}, {task_id: B, role: gate}]`

**Byte-identical records.** No record-shaped conformance vector can distinguish them, because identifying "an existing member" across a supersession requires an identity — the very thing that changed. §5.6:525-526 declares the deliverable is *"conformance vectors in the landed `schema/vectors/` pattern"*, which are record fixtures. V13 cannot be written in that pattern, and V13 names no enforcer.

The author's non-vacuity note at **:566** half-spots this — *"V13 vacuously because no amendment mechanism exists to violate it yet"* — but attributes it to a temporary condition. **The cause is structural and permanent:** V13 stays vacuous after the amendment mechanism lands, because the forbidden state is indistinguishable from a permitted one in the artifact V13 inspects.

**The fix is cheap and I will name it, since two clean options exist.** Either (a) name the **producer tool** as V13's enforcer — `New-TrainManifest.ps1`'s amend path *does* know the operation because the operator requested it, and the #76 round-1 verdict's F3 injection (*"amend replaces `task_id` instead of adding `subject`"* → 1 red) proves it is testable there — and move V13 out of the schema-vector set with that stated; or (b) drop the MUST-NOT clause as structurally unnecessary, since D2 already makes a member's identity immutable by construction and there is nothing left to pin.

**Also created by the round-2 fix** — V13 is new at round 2, introduced specifically to close DR1-m4's sixth obligation, and it does not close it.

## Minor

**DR2-m1 — "all six now land" overstates its own table.** §5.6:528-529 claims in bold that every §0-deferred obligation now lands in a vector; the table's row 5 (:539) lands the intra-manifest duplicate case in *"§10 Q5"*, an open question routed to the reviewer, not a vector. Disclosed in the table, overstated in the claim — the same class as DR1-m4, one notch smaller, on the exact claim that failed last round. Secondary: V12 is filed under *"the record-to-member join rule"* (:537), which it is not; that row is carried by V5/V6 alone and V12's presence inflates apparent coverage.

**DR2-m2 — §8 omits `schema/starcar-artifact.schema.json`, whose `task_id` description D8 falsifies twice.** `:80-82` reads *"Optional, **returned-only**. … the shop-minted dispatch id **echoed back by the report's starcar-artifact envelope** (`task-id:` line)."* D8 makes `task_id` dispatched-also and **conductor**-sourced rather than envelope-echoed. §8 correctly lists the Copilot adapter vector (`:713`) for exactly this reason — a landed artifact D8 would make wrong — so omitting the schema whose description D8 contradicts head-on is an inconsistency inside the table that otherwise does this job well. Same class as R1-M3, which this train already paid a Major for.

**DR2-m3 — D8 specifies no shape check before stamping `description` into `task_id`.** §5.7:600-603. The conductor writes prose there today (PR-5's own samples: `Design #87 member identity`). If the convention is missed, the producer stamps prose into a field the schema calls *"the shop-minted dispatch id"*. The board degrades honestly — §5.7a's table is right that D7 discloses it, and I verified that path — but the **store** accumulates records whose `task_id` is not a task id, and §5.6 pins no vector for the case. §10 Q2 asks the owner about prevention-vs-disclosure for *collisions* but never about *shape*. One clause in Q2 and one vector would close it.

## Notes

- **N1 — PR-7 fully re-derived by me at `3c31ed0`:** 96 / 96 distinct / 0 shared / 0 uppercase / 0 whitespace / 0 case-collisions; 83 dispatched, 177 returned, 6 intent, 0 `presumed-lost`. Every number exact.
- **N2 — `presumed-lost` is now properly traced** through §5.2:388-407, §6:677, §5.7:605-609 and V14, with the Law-3 cost named as *knowingly under-served* rather than hidden. That is the honest form. V14's second direction depends on D8, which is gated on Q2 — so half of V14 is untestable if the owner refuses; acceptable, since the first direction pins today's real behaviour.
- **N3 — §6:678's consist-SHRINKAGE row** closes the lifecycle gap I raised as unenumerated in round 1. Correct as written: behaviour is inherited from the fold's supersession and is honest.
- **N4 — the struck-not-deleted convention** (§7:692, §10 Q3:804, §10 Q6:831) is exactly right for a showcase repo. Reversals stay legible; questions show they were *answered* rather than abandoned.
- **N5 — §9b now carries two tables** (round-2 findings and round-1's inherited set) with no blanks, plus an explicit row recording the rulings that went the review's way *"so they are not re-opened"*. That row is a carrier-rule improvement I did not ask for.
- **N6 — my round-1 N7** (train terminality) is now named in §8:711 with the reason, so a later round does not re-dig it. Correctly handled.

---

# CONVERGENCE

**Round 1: 3 Major / 5 Minor / 8 Notes. Round 2: 2 Major / 3 Minor / 6 Notes.** Declining on both axes.

I applied the swirl-and-churn trigger honestly, because two of its three conditions are close:

| Condition | Fires? |
|---|---|
| Major counts stop declining | **No** — 3 → 2 |
| Findings cluster in the same section across rounds | **Partially** — §5.6 and §5.7 appear both rounds, but at different layers and on different concerns (a measurement error → a characterization inconsistency; a *missing* vector → a *defective* vector) |
| A round's findings include defects the previous round's fixes created | **YES — both Majors** |

**Ruling: NOT swirl, but I am setting a CAP.** The countervailing evidence is decisive: the mechanism (D1-D9) is unchanged and has now survived two adversarial rounds with independent measurement behind every load-bearing claim; both new Majors are *documentation-consistency and vector-specification* defects, not mechanism defects; and both fixes are a handful of sentences. Introducing 2 defects while closing 8 across a +347-line revision is a converging ratio, not the 7→3→4→5 flat-or-climbing signature the dual-runtime scar names.

**THE CAP, which only the party holding the series can set:** round 3 is the last round at this rung. **If round 3 produces any Major that is again a defect created by round 2's own fixes, the conductor escalates to the owner rather than dispatching round 4.** That would be the third condition firing twice consecutively, which is the pattern the doctrine exists to catch. Note also that round 4 would independently trip the reviewer-rotation trigger.

**LADDER POSITION — what the next rung must be, on approval.** This is a design, so convergence does **not** mean implementation. Per §0's own split, the next artifact is the **EXECUTABLE format half**: the schema delta plus the V1-V14 conformance vectors plus red-first tests, landing in the `schema/vectors/` pattern. Not a prose spec — §0 already ruled prose cannot hold this half. Two gates before any board code is written:

1. **V12 demonstrated RED ON ARRIVAL** against the current two-array wire, with the failure quoted. It is the one vector whose whole value is failing first, and a green V12 means it was written to the wire instead of the requirement.
2. **Q7 ruled** (I have ruled: single ordered consist), because V12's expected output depends on the wire shape.

The board join/render car (#85/#86) follows the vectors, not the reverse. D8 stays gated on owner Q2 throughout and is separable by design — that separability held up under attack this round and is one of the document's better structural choices.

---

## UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

One piece of evidence is not re-derivable from the repo alone, and it is the same one as round 1: `.claude/probe-logs/post-task.jsonl` is gitignored runtime output in the shared checkout that grows with every dispatch. My line numbers (42, 61) and the 98-line total are true as of 2026-07-27. **The design discloses this at §2b:282-288 in the correct form** — a later reader re-derives the *class* (two key sets; Copilot carrying `name`+`agent_type` and no `subagent_type`) from their own capture. The timestamp correction above rests on raw bytes from that same file and inherits the same boundary; the *method* (read the raw substring, never a JSON-parsed `DateTime`) is the durable part and is stated here.

Everything else is fully re-derivable from the repo: the producer code path (`Produce-Artifact.ps1:186-190`, `:358`), the schema coordinates, PR-7's corpus scan (one walk of `artifacts/**/*.json`), the suite counts, and the fault injection (clone out-of-repo, replace one citation coordinate, run `CitationResolverPolicy.Tests.ps1`, restore, hash-verify). My scratch files live in the session scratchpad and are session-local; the recipe, not the files, is the durable form.

## CONSTITUTION CHECK

- **Law 1 (`constitution.md:14-18`)** — *Honored, and strengthened this round.* §5.3a is Law 1 traced to the pixel; §6:676 makes the live falsehood its own failure row; §2b:270-278 records the rev-1 error rather than quietly swapping the number. *Violated* at **DR2-M1** (§5.5 and Q4 assert a false scope for the fallback clause) and, in a smaller way, at **DR2-m1**.
- **Law 3 (`:28-31`)** — *Honored, including where it is not met:* §6:677 names the `presumed-lost` case as **"Law 3 knowingly under-served"** rather than claiming coverage. Naming an unmet law is the honest form and I want it on the record.
- **Law 4 (`:33-37`)** — *Honored.* D6's no-drop rule now reaches the surface a human reads; D7's disclosure is load-bearing and §5.7a says so out loud.
- **Law 6 (`:46-51`)** — *Honored* in the single-owner join and in D9's show-the-disagreement stance. It is also the argument that decides Q7, which the design under-uses. *Tension, not violation,* at DR2-M2: V13 tries to pin a rule with no owner, which is Law 6's shape inverted.
- **Law 7 (`:53-57`)** — *Honored and improved.* The per-family §5.7 rewrite removes the one-family assumption a stranger would have inherited from rev 1, and §8:713 forces the Copilot adapter vector to be reconciled rather than left disagreeing with the live capture.
- **NO-BACKFILL** — *Honored*, unchanged and re-verified: PR-4's corpus is untouched, §7 forbids retro-stamping, nothing here invalidates a landed record.
- **Living contracts / same-commit** — *Honored* in §8's new view-layer and test rows, each with an owner and an explicit same-commit binding. *Incomplete* at **DR2-m2** (`starcar-artifact.schema.json` omitted).
- **Carrier rule** — *Honored*: every round-1 ID carries a `[DR1-n, folded]` marker at the point of the fold, not a summary, and §9b tabulates all eight with dispositions and locations.
- **Disagreeing loudly, never quietly** — *Honored, conspicuously.* The author disclosed a divergence from its own reviewer's verdict on the timestamps and was right; it appealed nothing while conceding more than I charged; and it quotes its own capture as evidence against its own proposal.

### **THE LAW-FIRST DIAGNOSTIC AT REV 2: it holds.**

Round 1 I found zero absent laws. **At rev 2 I again found none.** I opened every constraint in §1, the constitution ranges, `doc-map.md:53`, `Produce-Artifact.ps1:186-190` / `:358`, `starcar-artifact.schema.json:80-82`, `yard-snapshot.schema.json:128-137`, and the round-3 dual-runtime ruling. Every quote is verbatim-accurate and every coordinate resolves to what is claimed — including the `:52`→`:53` correction, which I re-verified.

Both of my Majors are **internal-consistency** failures: a section that a *later section in the same revision* falsified, and a vector that cannot do the job it was created for. Neither is a constraint the author failed to bring to the page. That remains the diagnostic reading the right way, against the founding wreckage's seven-for-seven.

**What a fix cycle needs (same author, delta re-review, and it should be short):** DR2-M1 is three sentences (recharacterize §5.5's fallback, restate Q4's cost basis and note my ruling, re-trigger §7's minted-id row). DR2-M2 is one choice between two named options. DR2-m1 is one clause. DR2-m2 is one §8 row. DR2-m3 is one clause in Q2 plus one vector. **Do not re-litigate:** the eight round-1 folds, PR-7, the per-family D8 narrowing, §5.3a's ownership, V12's specification, §5.7a's argument, Q3's closure, Q6, the verdict-path disclosure, or my Q7 ruling.

## Files (absolute paths)

- Reviewed: `<repo>-wt\review-design-87\docs\design\2026-07-27-manifest-member-identity-design.md`
- Round-1 verdict (not on this branch; `git show dev:...`): `artifacts/reviews/2026-07-27-design-87-review-r1-REJECT.md` at `8c90dbe`
- Key code verified: `<repo>-wt\review-design-87\scripts\Produce-Artifact.ps1` lines 186-190 and 358
- Probe log measured read-only: `<repo>\.claude\probe-logs\post-task.jsonl`
- Injection clone (session-local): `~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\8a347c36-20b4-427a-ae0b-46855aa7bb72\scratchpad\d87\clone2`

```starcar-artifact
task-id: design-87-review-r2
outcome: REJECT
findings: 2 Major, 3 Minor, 6 Notes at round 2, down from 3 Major 5 Minor at round 1. ALL EIGHT round-1 IDs walked PRESENT and substantively folded - zero ABSENT, zero DRIFTED, zero appeals - and two folds EXCEED what I found. DR2-M1 (Major) the round-2 per-family rewrite of section 5.7 makes the join's FALLBACK clause load-bearing for a LIVE runtime family while three other places still call it legacy-only; verified end to end - Produce-Artifact.ps1:186-190 sets a Copilot dispatched record's subject from tool_input.name with subject_basis minted-id, and :358 writes task_id only on returned records (corpus 83 dispatched, 0 with task_id), so every Copilot in-flight binding resolves task_id absent then falls back to subject, permanently; yet section 5.5:507-508 still calls it a legacy clause not a general escape hatch, section 10 Q4:816-817 still says it exists SOLELY for six landed manifests and 10 dispatch subjects while asking the reviewer to rule on dropping it, and section 7:691 still triggers minted-id stamping on the D8 wire landing which section 5.7 now says never happens for that family - so Q4 asks for a ruling on a false cost basis and a reviewer or owner ruling on it would delete a clause a live family depends on. DR2-M2 (Major) V13 amendment-scope at section 5.6:558 is unsatisfiable as specified - it permits a superseding manifest to add or remove members but forbids rewriting an existing member's identity, and those two operations produce BYTE-IDENTICAL records (v1 members A and B, then either rewrite A to C or remove A and add C, both yield C and B), so no record-shaped conformance vector in the schema/vectors pattern section 5.6:525-526 declares can distinguish them, and V13 names no enforcer; the author's own non-vacuity note at :566 half-spots this but attributes it to no amendment mechanism existing yet when the cause is structural and permanent; cheap fix, either name New-TrainManifest.ps1's amend path as the enforcer (the 76 round-1 verdict's F3 injection proves it is testable there) and move V13 out of the vector set, or drop the clause since D2 already makes identity immutable by construction. Both Majors are defects the round-2 fixes themselves created, which is the sharpest swirl condition. Minors - DR2-m1 the bolded all-six-obligations-now-land claim at section 5.6:528-529 overstates its own table, whose row 5 at :539 routes the intra-manifest duplicate case to open question Q5 rather than a vector, the exact class that failed last round, plus V12 is misfiled under the join-rule row it does not serve; DR2-m2 section 8 omits schema/starcar-artifact.schema.json whose task_id description at :80-82 reads Optional returned-only and echoed back by the report's envelope, both of which D8 falsifies, while section 8 correctly lists the Copilot adapter vector for exactly that reason; DR2-m3 D8 specifies no shape check before stamping description into task_id, so a missed convention puts conductor prose into a field the schema calls the shop-minted dispatch id, board degrades honestly via D7 but the store accumulates non-handles and no vector pins it. REVIEWER SELF-CORRECTION, and the author was RIGHT - I checked the timestamp divergence and MY round-1 verdict was wrong: raw bytes read 2026-07-24T11:18:40.178633+00:00 and 2026-07-25T23:08:35.962940+00:00, and I published local-time renderings because ConvertFrom-Json silently coerces an ISO-8601 string to a System.DateTime (machine TZ Eastern), which I never checked against raw bytes; same 20 records, same span, but I stated a coordinate I had not observed; this is a fourth member of the hazard family and belongs in the friction log, and I do not charge it against the document. VERIFIED INDEPENDENTLY - the producer claim is TRUE and materially shrinks D8 to the Claude family only; section 5.3a genuinely OWNS the rendered string rather than describing it, naming dom-writer.js:481, quoting the false sentence, supplying replacement wording, and binding the view to the SAME commit as the wire with the reason stated; the proposed single-consist shape is implementable and its optional-when-unknowable precedent at yard-snapshot.schema.json:128-135 is real; V12 is writable by a stranger and RED ON ARRIVAL is honestly achievable because the two-array wire cannot recover declared interleaving under any accessor; PR-7 re-derived by me exactly at 3c31ed0 - 96 task_id records, 96 distinct, 0 shared, 0 uppercase, 0 whitespace, 0 case-collisions, 83 dispatched, 177 returned, 6 intent, 0 presumed-lost - and Q3 is genuinely settled because it states its ruling AND its expiry condition; section 5.7a is a real argument not a hedge, stating the symmetry first, naming D7 as its load-bearing dependency, and quoting its own probe-dup-name collision as evidence against itself; both author self-assessments are ACCURATE not performative, and the m3 one goes past my finding to memberClaims at assemble.go:107 which I MISSED; the verdict-path disclosure is SUFFICIENT (absent at 3c31ed0, present at 8c90dbe and dev tip, retrieval command works, no gate sees it because the citation carries no line number); the author's restore hash F7BD34D842D55770DCAE2297F868A7FBF2DFF02D0A04337FD9ED9C2BE97F4436 confirmed on the committed document. Suites at 3c31ed0 DETACHED - scripts/tests 222 passed 0 failed 5 skipped reconciling exactly with the author's attached 223/0/4 via the SessionStartGuardRunner branch-conditional skip (222+1, 5-1, 227 both ways), citation gates 43 passed 0 failed 4 skipped exact. Fault injection on a NEW coordinate (Produce-Artifact.ps1:187-190 to :999888, not the author's dom-writer.js:481) reds the gate BY NAME on this document at line 594, restore hash-verified byte-identical per hazard 2 with the restore issued as a SEPARATE call because the Pester exit is non-zero. Author worktree design-87 NOT TOUCHED this round; shared checkout 0 dirty. CONVERGENCE - declining 3M to 2M, mechanism D1 through D9 unchanged and twice-confirmed, both new Majors documentation-consistency rather than mechanism, so NOT swirl - but I SET A CAP: round 3 is the last round at this rung, and if round 3 again produces a Major created by round 2's own fixes the conductor escalates to the owner instead of dispatching round 4. LAW-FIRST DIAGNOSTIC HOLDS AT REV 2 - I opened every constraint and coordinate again and found ZERO absent laws; both Majors are internal-consistency failures, not constraints the author failed to bring to the page. Q7 RULED - take the single ordered consist, on Law 6 (two arrays re-merged by every consumer is one structure in two places) with the carry that render.js:247-248's isTrainTerminal must be rewritten not deleted.
abstract: Delta adversarial design review, round 2, of the manifest member identity design for issue 87 at 3c31ed0 over round-1 HEAD 9e18799, one fix commit of plus 347 minus 60 lines, reviewed from a separate detached worktree after the conductor corrected a one-actor-per-worktree violation. REJECT on 2 Major, down from 3, with all eight round-1 findings folded, none appealed, and two folds exceeding what the review charged. This is a strong revision: the author re-derived every measurement itself rather than copying the verdict, took the harder of two offered remedies on the ordering finding by pinning it as a new vector instead of deleting the rule, found a defect the reviewer missed in the assembler's membership-collision keying, and caught a false coordinate in the reviewer's own round-1 verdict, which I confirmed against raw bytes and concede in full - PowerShell had silently coerced an ISO-8601 timestamp to local time and I published the result as observed. The new load-bearing claim verifies: the producer already reads the Copilot family's shop-minted id from the launch payload, which materially shrinks the proposed in-flight wire to one runtime family. The REJECT rests on two defects the round-2 fixes themselves created. First, that same per-family narrowing makes the join's fallback clause the permanent binding mechanism for a live runtime family, while three other sections still describe it as serving only six fossil manifests - including the open question that asks the reviewer to rule on dropping it, which now offers a cost basis that would lead to deleting a clause a live family depends on. Second, the new vector introduced to close the sixth deferred obligation forbids an operation that is byte-for-byte indistinguishable from one it permits, so it can never be satisfied in the record-fixture pattern the design declares, and it names no enforcer. Three Minors cover an all-six-obligations claim that overstates its own table, a contracts-touched table that omits the one schema whose field description the proposed wire falsifies twice, and an unspecified shape check that would let conductor prose land in a machine identity field. Convergence is real and this is not swirl, but because both Majors are fixes creating defects I set a cap: round three is the last at this rung before escalation. The law-first diagnostic holds at rev 2 with zero absent constraints, and on approval the next rung is the executable format artifact, not an implementation.
```