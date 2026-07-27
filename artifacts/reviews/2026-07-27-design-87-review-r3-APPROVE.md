<!-- starcar-integrity: sha256=d72f23a96c6771f674e8e2782f4b814b4ab50f5f0bc9cc8873648a0742a981e9 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Design #87 manifest member identity, adversarial design review round 3 (delta, capped round)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: adversarial design review (ladder rung 2, delta; round-2 cap live)
Round: 3
Target: `design/member-identity-87 rev 3 HEAD 2ade67f`
Base reviewed: `3c31ed02330936458842d954666d7c3b88561567`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

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
| Base commit the reviewer read (**the lookup key**) | `3c31ed02330936458842d954666d7c3b88561567` |

| Dispatch, the locator within the session | `afe18ef8acbb02719` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 3c31ed02330936458842d954666d7c3b88561567
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: **APPROVE** — 0 Major, 4 Minor. **THE CAP DOES NOT FIRE.**

Round 3 produced **no Major**, so the cap's trigger condition — *"any Major that is again a defect created by round 2's own fixes"* — is not met. No escalation. Both round-2 Majors are genuinely closed, verified by measurement rather than by reading, and the author's own pre-ship self-catch is real and complete. The four Minors are precision and carrier items that change no decision; I carry them as binding fold-obligations into the next rung rather than holding the design for them.

## BASE-DELTA (#13)

Review worktree `<repo>-wt\review-design-87`, **detached** at `2ade67fb7747b55cecc51ad18d0d78f1b530018a`, **0 dirty** — verified before any command. Prior reviewed HEAD `3c31ed02330936458842d954666d7c3b88561567`.

```
 .../2026-07-27-manifest-member-identity-design.md  | 377 ++++++++++++++++-----
 1 file changed, 295 insertions(+), 82 deletions(-)
```

Matches the reported +295/-82 exactly. **`design-87` was not touched by me.** Committed document sha256 `4519A8312864487C978610CE95313CD6D5C7D7B1D8DEA6E7356D5D7E0A0E44B6`.

**A convergence signal worth stating first: `git diff` finds ZERO changes to any §4 decision row.** D1-D9 have been stable since rev 1. Three adversarial rounds have moved evidence, citations, vectors and carriers — never the mechanism.

## Suites — observed by me at `2ade67f`, detached

| Suite | Author claimed | I observed | Reconciles |
|---|---|---|---|
| `scripts/tests` | 223 P / 0 F / 4 S | **222 P / 0 F / 5 S** (227) | yes — detached delta |
| citation gates | 43 P / 0 F / 4 S | **43 P / 0 F / 4 S** (47) | exact |

**Skip delta:** the 5th skip is `running the REAL guards prints [ci-baseline]'s marker ONLY when attached to a branch`. 222+1 = 223, 5−1 = 4, 227 both ways — identical to round 2's reconciliation.

**Third injection coordinate, and it reds by name.** Rounds used `dom-writer.js:481` (author) and `Produce-Artifact.ps1:187-190` (me, r2); I picked `schema/yard-snapshot.schema.json:137` → `:777666` on a fresh out-of-repo clone:

```
PRE  sha256: 4519A831…44B6    POST sha256: F1C92C61…88E3    INJECTION IS REAL: True
FAILED BY NAME: every resolved citation's line (or range end) is within the target file's line count
… 'docs/design/2026-07-27-manifest-member-identity-design.md:463 cites
   'schema/yard-snapshot.schema.json:777666' - target file has fewer lines'.
```

27 P / **1 F** / 4 S. Restore issued as a **separate call** per hazard 2, verified by hash: `4519A831…44B6`, clone 0 dirty.

---

# THE CAP'S OWN TRIGGER — the self-catch is REAL, and I measured it

The author reports finding a fix-created defect itself: the DR2-M1 correction falsified rev 2's own universal `presumed-lost` statement, because a minted-id loss record carries the shop handle in `subject`. **I did not take this on report.** I built the board from source at this base and ran both families through real HTTP in one store, one snapshot:

**Minted-id shape — the loss renders ON THE MEMBER ROW:**
```json
{"id":"train:lost","cars":[{"subject":"d87-lost-minted-r1","role":"car","state":"presumed-lost",
  "superseded":[{"kind":"dispatched","at":"…"}],"recordDir":"d87-lost-minted-r1"}, …],
 "declaredNotObserved":[]}
```
`assigned:true`. **Epoch 3, today, with no D8 at all.** Exactly as §5.2's new table claims.

**Runtime-id contrast — same store, same snapshot:**
```json
{"id":"train:lost-rt","cars":[],"declaredNotObserved":["d87-lost-rt-r1"]}
{"assigned":false,"state":"presumed-lost","subject":"zzzzzzzzzzzzzzzzz"}
```
**Zero board conditions.** Epoch 2, and the Law-3 cost §6 names is real and now measured: the board shows a member as *"declared, not yet observed"* while holding its death certificate under another name.

**Ruling: the self-catch is real, complete, and correctly scoped.** V14's three-direction rewrite follows from it, §5.7's narrowing of D8's inheritance obligation to the Claude family follows from it, and both are right. Rev 2 *would* have shipped a false universal statement; the author caught it inward before a reviewer saw it. **A defect the author caught and fixed before shipping does not fire the cap, and this one is exactly that.**

---

# THE FIVE-ID WALK

| ID | Status | Evidence |
|---|---|---|
| **DR2-M1** | **PRESENT — folded, and went PAST the finding** | §5.5:556-590 calls the clause **STRUCTURAL** with a three-population table; the chain re-verified by the author against code and corpus, and independently by me. §7:835 **retires** the minted-id stamping row rather than re-triggering it, correctly reasoning that rev 2 gated it on a D8 landing §5.7 says never happens. Q4 closed with its defective basis kept visible. **Went past:** the corrected reading exposed a **cross-clause** bind (member `task_id` ↔ record `subject`) that V5 and V6 both miss — V15 added. |
| **DR2-M2** | **PRESENT — folded, option (b), and my option (a) correctly declined** | §5.6:652-697. The MUST-NOT clause is deleted with three grounds on the page, option (a) named and refused for a stated reason, and the removal routed to Q8 for attack. Ruled below. |
| **DR2-m1** | **PRESENT — folded** | §5.6:610-629. "All six" replaced by **five pinned + one SPLIT**, a `Complete?` column, the table declared authoritative over prose above it, V12 moved off the join row, V15 into it, post-§0 vectors listed separately. Arithmetic verified below. |
| **DR2-m2** | **PRESENT — folded** | §8:858 gains `schema/starcar-artifact.schema.json:80-82` naming **both** falsified halves (returned-only; envelope-echoed) with the D8 producer car as owner and a **same-commit** binding, *"because it is the record contract, so it cannot lag the code by even one commit."* |
| **DR2-m3** | **PRESENT — folded, widened** | §10:968-986 adds Q2's third half separating SHAPE from COLLISION with three owner options; V16 added at §5.6:649. The widening the author adds and I had not made explicit: *"the BOARD degrades honestly, the STORE does not"* — correct, and the sharper statement. |

**Zero ABSENT. Zero DRIFTED. Zero appeals.** Every fold checked against code, corpus, or a running board rather than against the author's description.

---

# RULINGS ON THE FIVE CLAIMS

### 1. Q8 / DR2-M2 — **the deletion is CORRECT, and declining my option (a) was the better call.**

**Ground (i) tested, not accepted.** The claim is that V7's precedence already neutralises shape A's mutation. Shape A's amendment ADDS `subject` to a member; under §5.5 a both-keys member resolves `task_id` first, so identity is unchanged. **True.** And rev 2's justification for V13 cited shape A while the clause actually forbade `task_id` rewriting — so rev 2's stated reason was indeed aimed at a threat V7 already holds. **The author is right that its own prior justification was false**, and saying so about your own work is the behaviour this shop wants.

**Is anything now unguarded?** I worked the cases:

| Operation | Detectable? | Outcome under rev 3 |
|---|---|---|
| Rewrite a member's `task_id` | **No** — byte-identical to remove-plus-add | Old handle's records unattributed + D7 disclosure; member renders unbound. Honest. |
| Shape A: add `subject` to a `task_id` member | Yes | Identity unchanged (V7 precedence). No effect. |
| Add `task_id` to a `subject`-only member | Yes | **Identity flips** — and V7 is the cause, not the guard. But outcome is honest: record unbinds, becomes unattributed, D7 discloses. |

**Nothing is unguarded.** Every path ends in disclosure, never in silence or falsehood — which is ground (ii), and ground (ii) is what actually carries the third row. That is my DR3-m3 below: a precision point, not a reversal.

**On my own option (a): I concede it, and the author's reasoning is better than mine.** Naming `New-TrainManifest.ps1` as the enforcer would put a CONTRACT rule inside ONE tool, leaving a hand-written manifest or any second producer unbound. That is Law 6 inverted, and re-homing the idea to §7 as an operator-facing *warning* with a trigger is the right disposition. **The reviewer offered the weaker of two options and the author took the stronger one with a better argument.**

**"Empty by construction" is a real answer, not an evaporation.** D1 mints identity once, D2 gives the manifest no runtime fact to mutate toward, V7 neutralises the historical attempt. An obligation whose honest answer is *"nothing is forbidden here, and here is why"* has landed.

### 2. DR2-M1 — **V15's gap is real, V15 closes it, and the three-population table is complete.**

**The gap is real.** V5 pins `task_id`↔`task_id`; V6 pins `subject`↔`subject`. The Copilot in-flight case is member-`task_id` ↔ record-`subject` — **neither vector reaches it**, and an entire runtime family runs through it every dispatch. Verified by reading both vector specs.

**V15's fixture is correct and its non-vacuity warning is sharp.** The author flags that V15 *"would pass today against a member carrying `subject` instead of `task_id`"* — correct: today's board joins subject↔subject, so a subject-fixture is green on arrival for the wrong reason. With a `task_id`-**only** member, `assemble.go:307` drops the member outright (the #85 bug), so V15 reds. **Red on arrival, honestly achievable.**

**The three-population enumeration is complete.** I hunted a fourth:

- Copilot **returned** records carry `subject` = handle *and* `task_id` = handle (`Produce-Artifact.ps1:199` resolves Copilot returned subjects from the envelope; `:358` writes `task_id`), so they bind by the **first** clause. Correctly excluded.
- Claude **dispatched** records traverse the second clause but bind to nothing — that is epoch 2, covered elsewhere. The table's column is *"which clause binds it"*, so a non-binding traversal is correctly out of scope, though "serves" is doing some work in the lead sentence.

**Closing Q4 with its defective basis KEPT VISIBLE is the right call**, and it is the showcase rule applied to the document's own history: *"a soft-spot question priced wrongly is worse than no question at all."* Quietly restating the basis would have erased the most instructive thing that happened in three rounds — that the section whose job is honest self-attack had itself become a route to a wrong decision.

### 3. The minors — **arithmetic verified, and declining to decide Q2's shape half is CORRECT.**

**§5.6 arithmetic checks exactly.** In-table (§0's six obligations): V1,V2,V11 / V3,V4 / V5,V6,V15 / V7 / V8,V9 / V13 = **12 distinct**. Listed separately as post-§0: V10, V12, V14, V16 = **4**. Total **16 = V1–V16**, no vector double-counted, none orphaned. **Five complete, one PARTIAL**, and the one uncovered obligation is named precisely: the intra-manifest member duplicate, routed to Q5. V12 correctly moved off the join row; V15 correctly takes that slot.

**Declining to decide Q2's shape half is correct, not a dodge.** It is a contract question about what the producer writes into the store — the reality-vs-spec doctrine's territory, and D8 is already owner-gated. Decisively: **the author states a preference (option iii) rather than hiding behind neutrality.** That is escalate-without-pre-answering done properly, which is the exact discipline the #33 scar exists to enforce. One option is ambiguously worded — DR3-m4 below.

### 4. Q7 — **the carry survived into BOTH places. Confirmed.**

- **§5.3:487-492:** *"`isTrainTerminal` reads `train.declaredNotObserved.length` … Under one array that field is gone, so the predicate must be **REWRITTEN against the new shape - never deleted.** Deleting it would make a train with a permanently-unbound member terminal, which #67 already ruled wrong."*
- **§8:856:** the view row carries it, *"flagged because collapsing the two arrays per §5.3 forces this predicate to be rewritten against the new shape rather than deleted."*

Both present, both with the #67 reasoning attached. And the ruling is folded as a **decision** (§5.3:474-485), with the `declaredIndex` alternative kept named-and-closed rather than deleted.

### 5. The author's second self-catch — **verified.**

`docs/the-healing-loop.md:60-61` resolves to *"imported ceremony that never caught anything here is a pruning candidate"* — exactly the quote used. The corrected coordinate is right, and this is the in-range-shift class `CitationResolverPolicy.Tests.ps1:12-18` explicitly declares outside its binding checks. **Two self-catches in one revision, in a class no gate covers.**

---

# FINDINGS — 0 Major, 4 Minor

**DR3-m1 — §5.2's minted-id row cites dispatched-record code for a `presumed-lost` claim, and says "works today" of a record kind nothing mints.** §5.2:421-424. The cited `Produce-Artifact.ps1:187-190` sets the **dispatched** record's subject; it says nothing about `presumed-lost`. And **no component in this repo mints `presumed-lost`** — `grep` across `scripts/` and `board/` finds only readers (`Detect-Dispatches.ps1:163-164`, `fold/algorithm.go:10,139`, `assemble.go:424`, `server/poll.go`), with 0 records in the store. *The conclusion is nonetheless correct and I measured it* (above). The real basis is that the fold groups by subject with `presumed-lost` superseding `dispatched`, which **forces** the shared subject — my probe exercised exactly that (`superseded:[{kind:"dispatched"}]`). Fix: cite the fold's subject-grouping as the basis, and soften *"works today"* to *"binds the moment such a record exists."*

**DR3-m2 — the `presumed-lost` inheritance obligation has no owner, because nothing mints `presumed-lost`.** §5.7:747-753 makes it *"an explicit D8 obligation"* that a Claude-family loss record carries its dispatched sibling's handle. But D8 is a change to `scripts/Produce-Artifact.ps1`, which writes `dispatched` and `returned` only; the loss-record minter is a different, **unbuilt** component (`schema/vectors/valid-presumed-lost.json`'s `basis.by` reads `watchdog-tier1`), and §8 has no row for it. An obligation assigned to software that does not exist and no ticket owns is the carrier rule's own shape. **Stated explicitly because it bears on the cap: this is NOT fix-created — it entered at rev 2 via DR1-m4's fold and rev 3 only narrowed it per-family.** Fix: one §2c row or one §8 row.

**DR3-m3 — the V13-deletion's ground (i) holds in one direction only; ground (ii) is what carries the other.** §5.6:666-672. V7's precedence neutralises *adding `subject`* to a `task_id` member — but the reverse addition, `task_id` added to a `subject`-only member, **flips** the resolved identity, with V7's precedence as the cause rather than the guard. D4 (§4) makes a subject-only member schema-legal; only D3, a design rule, discourages one. **The deletion remains correct** — ground (ii)'s honest-outcome argument covers that direction fully. Q8 asks *"is anything now unguarded"*, and the answer deserves to name which ground does the work in each direction rather than resting on one that holds one way.

**DR3-m4 — Q2's option (ii) is ambiguous between rejecting the FIELD and rejecting the RECORD, and the record reading is an unpriced Law 4 hazard.** §10:979-982: *"a shape rule on the record schema … so a non-handle is **rejected at write time**."* If that means the record is rejected, `Produce-Artifact.ps1`'s validation path raises and **no dispatch record is written** — a dispatch that happened and is invisible, which is the #32 killed-session class this design elsewhere treats as the manifest's whole purpose. If it means only the field, it collapses into option (iii). The author's stated preference (iii) is the safe one, so the design's instinct is right — but the owner is being asked to choose among options one of which is readable two ways. Fix: one disambiguating clause, and if record-rejection is meant, price the Law 4 cost.

---

# CONVERGENCE AND THE CAP RULING

**Majors: 3 → 2 → 0. Minors: 5 → 3 → 4.** The Major trajectory is decisive. The Minor tick is finer-grained work, not relocation: round 1's Minors were mis-citations and unprobed facts; round 3's are a citation basis, an unowned future obligation, an incomplete branch of an argument, and one ambiguous word.

**The cap, ruled explicitly:**

| Cap condition | Fires? |
|---|---|
| Round 3 produced any Major | **NO — zero Majors** |
| …that was a defect created by round 2's fixes | not reached |

**THE CAP DOES NOT FIRE. No escalation to the owner is required on this rung.**

I examined the spirit as well as the letter, since the cap exists to catch a document that keeps relocating defects. Rev 3 relocated nothing: both round-2 Majors are genuinely closed and verified by measurement; the one genuine fix-created defect was caught by the author before shipping and I confirmed the catch on a running board; §4's decision rows are untouched for a third round. Of my four Minors, m1/m3/m4 arise from rev-3 text and m2 predates it — all below the cap's Major threshold, and I say so openly rather than leaving it unexamined. **This is the shape of a converging document.**

Round 4 is not needed; the rotation trigger it would have tripped is moot.

---

# WHAT THE NEXT RUNG MUST BE

**Confirmed and revised from round 2.** The next artifact is the **EXECUTABLE FORMAT HALF**, per §0's split — not a prose spec, and not the board implementation.

**The deliverable:** a schema delta plus conformance vectors in the landed `schema/vectors/` pattern plus red-first tests, covering **V1–V16**, plus **V17** from my Q5 ruling below.

**Two gates before any board code:**
1. **V12 demonstrated RED ON ARRIVAL** against the current two-array wire, failure quoted.
2. **V15 demonstrated RED ON ARRIVAL with a `task_id`-ONLY member fixture** — the author's own non-vacuity warning, and I confirmed a `subject` fixture would pass today for the wrong reason.

**Q7 is ruled** (single ordered consist) and is a decision, not a proposal. The #85/#86 board car follows the vectors; never the reverse.

**MY Q5 RULING, which closes the one obligation §5.6 lists as PARTIAL: BOTH a producer check AND a board disclosure, and they are not redundant.** JSON Schema genuinely cannot express uniqueness over a computed key (identity is `task_id` else `subject`), so schema rejection is off the table. The producer check belongs in `New-TrainManifest.ps1`'s existing pre-write validation and fails fast for the common case. But it cannot be the contract-level guarantee — **by the author's own Law 6 argument for declining option (a) on V13**: a hand-written manifest or a second producer is not bound by one tool, and the board is the only component that sees every record regardless of who wrote it. Two members sharing one handle is an ambiguity, which is exactly D9's established posture. **Land it as V17 (`manifest-duplicate-member-identity`), disclosure-shaped, in D9's family.** With this, the format car has no unowned obligation.

**What must reach the OWNER before the format car is briefed:**

- **Q1 (must go first).** Whether a member may carry `observed_subject` as enrichment changes the **schema delta itself**, so it blocks the format car. The author calls it the decision most likely to be wrong; I agree it is the one genuinely open contract question left.
- **Q2 (all three halves) — does NOT block the format car.** It gates D8 and V16 only, and D8 is separable by construction. Brief the format car on V1–V15 + V17 now; V16 waits on the ruling. Carry DR3-m4's disambiguation into the question before it is asked.

---

## UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

Everything in this verdict is re-derivable from the repo alone. The presumed-lost probe: `go build -o &lt;scratch&gt;\board-server.exe ./server` from `board/`; seal records with `Get-Sha256Hex` over the compact body (`scripts/Artifact.psm1`, one owner, no second rule); write a manifest whose member `subject` is the handle plus a `dispatched` record and a `presumed-lost` sibling sharing that subject, and a runtime-id contrast under a UUID subject; run with `STARCAR_STORE_PATH`, `STARCAR_PORT=0`, `STARCAR_POLL_MS=150`, `WorkingDirectory` = repo root; read `/api/snapshot`. Corpus figures come from one walk of `artifacts/**/*.json`. The injection: clone out-of-repo, replace one citation coordinate, run `CitationResolverPolicy.Tests.ps1`, restore in a **separate** call, verify by hash.

The one boundary, unchanged across all three rounds and correctly disclosed by the design at §2b: `.claude/probe-logs/post-task.jsonl` is gitignored runtime output that grows with every dispatch. Nothing in *this* verdict rests on it — I re-derived nothing from it this round.

## CONSTITUTION CHECK

- **Law 1 (`constitution.md:14-18`)** — *Honored.* §5.3a keeps the falsehood traced to the pixel; §6:820 keeps it as a live-defect row; Q4's defective basis is kept visible rather than swapped; §5.2's family split corrects a statement that would have been false. **DR3-m1's "works today" is the only imprecision, and the mechanism behind it I measured true.**
- **Law 3 (`:28-31`)** — *Honored, including where unmet:* §6:821 still names the runtime-id loss case as *"Law 3 knowingly under-served"*, and my probe confirms that cost is real and not hypothetical.
- **Law 4 (`:33-37`)** — *Honored.* Every amendment path examined in the Q8 ruling terminates in D7 disclosure; nothing goes silent. *One unpriced exposure* at DR3-m4, in an owner option rather than in the mechanism.
- **Law 6 (`:46-51`)** — *Honored, and it is now the document's sharpest instrument.* It decides Q7 (§5.3:474-482, quoting the clause), it is the stated reason for declining V13 option (a), and it is the reason my Q5 ruling keeps the board disclosure alongside the producer check. Three independent uses, all correct.
- **Law 7 (`:53-57`)** — *Honored.* The per-family specification removes the one-family assumption a stranger would inherit; §8:859 still forces the Copilot adapter vector to be reconciled rather than left disagreeing with the live capture.
- **NO-BACKFILL** — *Honored*, unchanged: §7 forbids retro-stamping, the six landed manifests are untouched, and §7:835 correctly **retires** rather than defers the minted-id stamping row now that the second clause is structural.
- **Living contracts / same-commit** — *Honored*, and improved: §8:858's new row binds the record-contract schema to the **same commit** as the stamp, *"because it cannot lag the code by even one commit."*
- **Healing Loop (`:60-61`)** — *Honored*, and applied against the author's own prior work: a gate with nothing to catch was pruned rather than re-homed.
- **Carrier rule** — *Honored.* Three disposition tables, every ID marked at the point of the fold, no blanks. *One gap* at DR3-m2 (an obligation whose owner is unbuilt).
- **Disagreeing loudly, never quietly** — *Honored throughout.* Zero appeals, two self-catches in a class no gate covers, its own prior justification declared false, and the reviewer's option refused with a stated reason rather than accepted to be agreeable.

### **THE LAW-FIRST DIAGNOSTIC AT REV 3: it holds, for the third round.**

Rounds 1 and 2: zero absent laws. **Round 3: zero again.** I re-opened the constitution ranges, `the-healing-loop.md:60-61`, `doc-map.md:53`, `Produce-Artifact.ps1:186-190`/`:199`/`:358`, `starcar-artifact.schema.json:80-82`, `yard-snapshot.schema.json:137`, `Detect-Dispatches.ps1:163-164`, `valid-presumed-lost.json`, and §4's decision rows. Every quote is verbatim; every coordinate resolves; the two the author corrected itself were the only shifted ones.

**All four of my Minors are precision items, not absent constraints** — a citation basis, an unbuilt owner, an incomplete branch of a sound argument, one ambiguous word. Across three rounds and twelve findings, the reviewer has found **zero laws the author failed to bring to the page.** Against the founding wreckage's seven-for-seven, that is the diagnostic reading correctly for the third consecutive round, and it is the strongest evidence available that this document was built law-first rather than graded law-last.

**Fold obligations carried into the next rung** (binding, not optional): DR3-m1's citation basis, DR3-m2's §2c-or-§8 row for the unbuilt loss-record minter, DR3-m3's per-direction grounds, DR3-m4's disambiguation before Q2 reaches the owner, and V17 from the Q5 ruling. None blocks the format car once Q1 is answered.

## Files (absolute paths)

- Approved: `<repo>-wt\review-design-87\docs\design\2026-07-27-manifest-member-identity-design.md`
- Probe (session-local): `~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\8a347c36-20b4-427a-ae0b-46855aa7bb72\scratchpad\d87\rev87r3-probe.ps1`
- Key code verified: `scripts\Produce-Artifact.ps1` (186-190, 199, 358), `scripts\Detect-Dispatches.ps1` (163-164), `schema\vectors\valid-presumed-lost.json`

```starcar-artifact
task-id: design-87-review-r3
outcome: APPROVE
findings: 0 Major, 4 Minor at round 3, converging from 3 Major 5 Minor at round 1 and 2 Major 3 Minor at round 2. THE CAP DOES NOT FIRE - the trigger was any Major that is again a defect created by round 2's fixes, and round 3 produced ZERO Majors, so no escalation to the owner is required at this rung. All five round-2 IDs walked PRESENT and substantively folded, zero ABSENT, zero DRIFTED, zero appeals, and two folds went past the finding. THE SELF-CATCH IS REAL AND I MEASURED IT rather than taking it on report - I built board/server from source at this base and ran both families through real HTTP in one store and one snapshot: a minted-id presumed-lost record whose subject is the shop handle renders state presumed-lost ON THE MEMBER ROW with declaredNotObserved empty and assigned true, epoch 3 today with no D8 at all, while the runtime-id contrast lands the member in declaredNotObserved with its loss record assigned false and ZERO board conditions, epoch 2, confirming both the family split and the Law 3 cost the design names; rev 2 would have shipped a false universal statement and the author caught it inward before any reviewer saw it, which per the cap's own framing does not fire it. Minors - DR3-m1 section 5.2's minted-id row cites Produce-Artifact.ps1:187-190, which sets the DISPATCHED record's subject, in support of a presumed-lost claim, and says works today of a record kind NOTHING IN THE REPO MINTS (grep finds only readers at Detect-Dispatches.ps1:163-164, fold/algorithm.go:10 and :139, assemble.go:424, server/poll.go; 0 records exist), though the conclusion is correct and the real basis is the fold's subject-grouping which forces the shared subject and which my probe exercised via superseded kind dispatched; DR3-m2 the presumed-lost inheritance obligation at section 5.7:747-753 is assigned to D8, a change to Produce-Artifact.ps1 which writes only dispatched and returned, while the loss-record minter is a different UNBUILT component (valid-presumed-lost.json's basis.by reads watchdog-tier1) that section 8 gives no row, so an obligation is owned by software that does not exist - and this is NOT fix-created, it entered at rev 2 via DR1-m4 and rev 3 only narrowed it per-family, stated explicitly because it bears on the cap; DR3-m3 the V13-deletion's ground (i) holds only one direction - V7's precedence neutralises ADDING subject to a task_id member, but the reverse addition of task_id to a subject-only member FLIPS the resolved identity with V7 as the cause rather than the guard, and D4 makes a subject-only member schema-legal while only D3 discourages it, so ground (ii)'s honest-outcome argument is what carries that direction and the document should say which ground works where; DR3-m4 Q2's option (ii) is ambiguous between rejecting the FIELD and rejecting the RECORD, and the record reading means a dispatch that happened is never written, the number-32 killed-session class this design treats as the manifest's whole purpose, an unpriced Law 4 hazard in an owner-facing option. RULINGS - Q8 the V13 MUST-NOT deletion is CORRECT and I worked all three amendment paths, every one terminating in D7 disclosure with nothing silent or false, so nothing is unguarded; I CONCEDE my own option (a) and the author's refusal is better reasoned than my suggestion, since naming New-TrainManifest.ps1 as enforcer would put a CONTRACT rule in ONE tool leaving hand-written manifests unbound, Law 6 inverted. V15's gap is REAL - V5 pins task_id to task_id and V6 pins subject to subject, neither reaches the member-task_id to record-subject cross an entire family runs every dispatch - and its non-vacuity warning is sharp and correct, since a subject fixture would pass today for the wrong reason while a task_id-only member reds via assemble.go:307's drop. The three-population table is COMPLETE - I hunted a fourth and Copilot returned records bind by the FIRST clause (Produce-Artifact.ps1:199 plus :358 give them both keys) while Claude dispatched records traverse without binding, which is epoch 2 covered elsewhere. Section 5.6 arithmetic verified exactly - 12 distinct vectors in the six-obligation table plus 4 post-section-0 vectors listed separately equals V1 through V16, none double-counted, five complete plus one PARTIAL with the intra-manifest duplicate named as the sole uncovered obligation. Declining to decide Q2's shape half is CORRECT not a dodge, because the author states a preference (iii) rather than hiding behind neutrality. Q7's isTrainTerminal carry survived into BOTH section 5.3:487-492 and section 8:856 with the 67 reasoning attached. The self-caught citation the-healing-loop.md:60-61 resolves verbatim. MY Q5 RULING closes the last unpinned obligation - BOTH a producer check AND a board disclosure, not redundant, by the author's own Law 6 argument that one tool cannot bind a hand-written manifest, landing as V17 in D9's disclosure family. Suites at 2ade67f DETACHED - scripts/tests 222 passed 0 failed 5 skipped reconciling exactly with the author's attached 223/0/4 via the SessionStartGuardRunner branch-conditional skip, citation gates 43/0/4 exact. Third injection coordinate yard-snapshot.schema.json:137 to :777666 reds the gate BY NAME at document line 463, restore verified by hash 4519A8312864487C978610CE95313CD6D5C7D7B1D8DEA6E7356D5D7E0A0E44B6 as a SEPARATE call per hazard 2, clone 0 dirty, author worktree untouched. CONVERGENCE - Majors 3 to 2 to 0, and git diff finds ZERO changes to any section 4 decision row, so D1 through D9 have been stable across all three rounds while evidence, citations, vectors and carriers moved. LAW-FIRST DIAGNOSTIC HOLDS A THIRD TIME - zero absent laws across three rounds and twelve findings, against the founding wreckage's seven-for-seven.
abstract: Delta adversarial design review, round 3 and the capped round, of the manifest member identity design for issue 87 at 2ade67f over round-2 HEAD 3c31ed0, one fix commit of plus 295 minus 82 lines. APPROVE on zero Majors and four Minors, and the cap I set at round 2 does not fire: its trigger was a further Major created by round 2's own fixes, and this round produced no Major at all, so no owner escalation is owed at this rung. Both round-2 Majors are genuinely closed and I verified them by measurement rather than reading. The author's own pre-ship self-catch is real and complete: I built the board from source and observed a minted-id loss record binding to its member and rendering the death on the member row today with no producer change, against a runtime-id contrast that lands in declared-not-observed with zero conditions, which confirms the family split the correction introduced and the Law 3 cost the design honestly names as under-served. The cross-clause gap the author found past my finding is real and its new vector closes it with a correct non-vacuity warning. On the one place this revision removes a rule rather than adding one, I worked every amendment path and found nothing unguarded, every route ending in disclosure, and I concede my own suggested alternative: the author refused it for a better reason than I gave, since putting a contract rule inside one tool leaves a hand-written manifest unbound. The four Minors are precision and carrier items that change no decision - a citation whose cited code supports a neighbouring fact, an obligation assigned to an unbuilt component, an argument whose stated ground holds in only one of two directions while another ground carries the rest, and one ambiguously worded option in an owner question that hides an unpriced silent-loss reading. I carry all four as binding fold obligations into the next rung rather than holding the design for them, and I add one ruling that closes the last unpinned obligation by requiring both a producer check and a board disclosure. Majors ran three, two, zero while the decision table went untouched for three rounds, and the law-first diagnostic reads clean for the third consecutive time. The next artifact is the executable format half, schema delta plus sixteen vectors plus one more from my ruling, with two vectors demonstrated red on arrival, and only the enrichment question must reach the owner before that car is briefed.
```