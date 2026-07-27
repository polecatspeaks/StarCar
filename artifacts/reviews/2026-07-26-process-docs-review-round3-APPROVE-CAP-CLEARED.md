<!-- starcar-integrity: sha256=80a2b796185259d106a316050dc0ecbf937bd64cbc2c2f080450a02d4ee9dd29 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car process-docs delta re-review - round 3 (APPROVE, cap cleared)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial delta re-review, whole-train gate + cap ruling
Round: 3
Target: `commits c4fe88b, 8446a3a, 4b2fb26 on car/process-docs; series base 5ba0602`
Base reviewed: `4b2fb26fb22916e78e3ba55ae601d954d3aa53a3`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a7fbcee7ccaec45d8`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `4b2fb26fb22916e78e3ba55ae601d954d3aa53a3` |

| Dispatch, the locator within the session | `a7fbcee7ccaec45d8` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 4b2fb26fb22916e78e3ba55ae601d954d3aa53a3
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

---

# DELTA RE-REVIEW, ROUND 3 — VERDICT: **APPROVE** · **CAP CLEARED** · train **MERGEABLE** from `4b2fb26`

Base verified: HEAD = `4b2fb26fb22916e78e3ba55ae601d954d3aa53a3`, clean tree before and after. Read-only: edited, committed, pushed nothing.

**BASE-DELTA (#13):**
- This round's reviewed base: `4b2fb26fb22916e78e3ba55ae601d954d3aa53a3`
- Round 2's reviewed base: `000111b767108d241ed62eb58db36303512c55ec`
- `git diff 000111b..4b2fb26 --stat` → 5 files, **72 insertions, 26 deletions**: `worked-plan.md` (37), `design-briefs.md` (27), `worked-briefs.md` (15), `worked-adversary-and-gate-briefs.md` (13), `worked-spec.md` (6).

**UNREPRODUCIBLE-EVIDENCE CALLOUT (#13) — two items, and the second is load-bearing for how you read my cap ruling:**

1. #9's residual 2 (the `Project-Bootstrapping` mirror) remains structurally unverifiable from this worktree. No finding rests on it.
2. **The cap's 17-file inventory table itself lives in the car's report, not in the repo — I could not open it.** So I did **not** verify the inventory as a document. I re-derived it independently and compared conclusions. My cap ruling rests on **my own enumeration**, which is the stronger basis, but the distinction belongs on the record: I am ruling that the inventory's *conclusions* are correct, not that I read a document asserting them. This drives Note N-8.

---

## THE CAP RULING: **CLEARED**

I set this cap, so I rule on it against its own terms: *a mechanically derived, complete inventory of every reviewer-brief/verdict-shape carrier in `docs/templates/*.md` and `.claude/agents/*.md`, enumerated in full and opened rather than pattern-guessed, each marked has-both-fields or not-applicable-with-reason.*

**Step 1 — I re-derived the file list.** `ls` returns **16** files in `docs/templates/` + **1** in `.claude/agents/` = **17**. Matches the car's stated scope exactly.

**Step 2 — I ran a wide-net token scan across all 17** (`verdict|reviewer|adversar|REJECT|APPROVE|NEEDS-REWORK|re-review|review record|gate check`), deliberately far broader than the round-1 pattern that missed `worked-plan.md`, then opened every file that scored, plus every file the brief named. My independent carrier set:

| # | Carrier site | Both fields? |
|---|---|---|
| 1 | `car-brief.md` reviewer addendum (`:88` opener, `:176` VERDICT) | ✓ |
| 2 | `design-briefs.md` §1 design reviewer brief (`:21`, `:96`) | ✓ **new, found by the cap** |
| 3 | `design-briefs.md` §2 DELTA re-review (`:121`, `:164`) | ✓ |
| 4 | `worked-adversary-and-gate-briefs.md` §1 design adversary (`:14`, `:44`) | ✓ |
| 5 | §2 spec adversary (`:57`, `:77`) | ✓ |
| 6 | §3 plan adversary (`:91`, dims `(f)`/`(g)`) | ✓ |
| 7 | §4 whole-branch gate (`:122`, `:153`) | ✓ |
| 8 | `worked-briefs.md` §2 adversarial reviewer brief (`:89`, `:141`) | ✓ **new, found by the cap** |
| 9 | `worked-plan.md` plan-review record + verdict shape (`:169`, `:196`) | ✓ (M-4) |
| 10 | `.claude/agents/car.md` agent definition | **N/A — ruled below** |

**My independent derivation found exactly the carrier set the car found, including both new ones.** Two agents, two methods, same ten sites. That convergence is the strongest completeness evidence available here, and it is why I clear the cap rather than merely accepting a table.

**Step 3 — I ruled every N/A myself.** All four the brief named, plus six more:

| File | N/A ruling |
|---|---|
| `worked-rung-carriers.md` | **CORRECT.** Doctrine for the carrier chain; no dispatchable brief, no verdict shape. Its `:40-46` fidelity table is one *section* of a verdict shown to illustrate the chain. Notably, adding an unreproducible-evidence column there would **contradict** #13, whose whole complaint is that such evidence must not live in a table cell. The N/A is not merely defensible — the alternative is wrong. |
| `worked-spec.md` §11 Review record | **CORRECT.** A summary of verdicts already rendered, authored by the *spec's* author and living in the spec forever. Not a template for producing a verdict, not a brief. |
| `design-doc.md` | **CORRECT.** An authoring template. §9b is the *author's* disposition table; §10 is questions *for* the reviewer. The reviewer-side counterparts are `design-briefs.md` §1/§2, both now covered. |
| `.claude/agents/car.md` | **CORRECT for cap purposes** — an agent definition of standing duties, neither a brief nor a verdict shape. See N-7 for a genuine judgment call I flag rather than bury. |
| `worked-tickets-and-board.md` | **CORRECT.** "verdict" hits are the fictional `deriveVerdict` function and ticket prose. |
| `worked-ledger-and-gating.md`, `state-ledger.md` | **CORRECT, and instructive.** Here "Verdict" is a **ledger column word** (`SAFE` / `LATENT_BUG` / `DELIBERATE_CARRY` / `RESET` / `CARRY`) — a completely different sense. These two are exactly the false positives a grep-only method produces, and they are the proof that the cap's "open each file" clause was the operative requirement, not ceremony. |
| `worked-verification-reconciliation.md` | **CORRECT.** `:45-47` claims every reviewer brief carries the *RUN YOURSELF* line — still true, and it never claims to enumerate all fields, so #13 does not stale it. |
| `worked-resume-packet.md`, `repo-policy-check-patterns.md`, `ops-script-patterns.md`, `gating-matrix.md` | **CORRECT.** No brief, no verdict shape. |

**Step 4 — the mechanical confirmation.** Both fields now appear in all five template carrier files (`BASE-DELTA`: 2/4/7/2/3; `UNREPRODUCIBLE`: 4/5/8/2/3).

**Ruling: the cap is CLEARED.** The car did the prescribed method rather than a pattern-match, and the method immediately paid — it surfaced two carriers that **three rounds of instance-fixing, including two of my own reviews, had missed.** That is the cap working as designed: it converted an instance-fixing series into a class-fixing one. No escalation to the owner.

---

## ROUND-2 FINDINGS WALK — 6 of 6 **CLOSED**

| ID | Status | Evidence |
|---|---|---|
| **M-4** (plan rung's delegated carrier) | **CLOSED** | `worked-plan.md:196-204` — the fictional REJECT verdict shape now opens with BASE-DELTA and an UNREPRODUCIBLE-EVIDENCE line inline. `:205-209` extends it to the delta-re-review paragraph with the right reasoning ("even when it is the SAME reviewer with context intact, because the LANDED verdict, not the reviewer's memory, is what a rotation reviewer or auditor reads later"). **Landing it inside the worked verdict rather than as an instruction is the stronger form** — a reader copying the shape copies the fields. The `none - every claim below is re-derivable` example also teaches that a negative callout is still a callout, which is correct and which I did not ask for. |
| **m-8** (inverted WHY) | **CLOSED — no residual inversion** | Re-opened all three cited lines. `design-briefs.md:150-157` now reads "**WAS** disclosed honestly — *'recorded honestly as UNVERIFIABLE, not papered over… a fresh reviewer inherits the correct blindness'* (`drill:105`) — so this is not a case of a closure hiding a gap. The drill's actual complaint was PLACEMENT". Verified verbatim against `drill:105`; the ellipsis elides only the em-dash and preserves source order. "lives buried in a table cell" verbatim against `drill:110`. The false "recorded as closed" is gone, so the `drill:66` contradiction (`DRIFTED → C2R2-M1`) is gone with it. Now matches the parallel WHY the same train already had right. |
| **m-9** (commit message mis-describes its diff) | **CLOSED** | A full RECORD CORRECTION paragraph in `4b2fb26`'s message, accurately stating both what was claimed and my ruling that the shape choice was correct and only the description wrong. Right instrument — history cannot be amended. |
| **m-10** (plan adversary voice) | **CLOSED** | `(f)` and `(g)` compressed to one clause each (`:100-104`), now within the range of siblings `(a)`-`(e)`; the `[WHY (f) and (g) land here specifically]` block is untouched and still carries the reasoning and both provenance citations. |
| **N-5** ("one per document") | **CLOSED** | `worked-spec.md:98-99` now "one per **obligation**" — the accurate unit. |
| **N-6** (fiction's §11 tension) | **CLOSED** | `worked-spec.md:161-163` now records that the round-2 reviewer "read sections 9 and 10 above and accepted the two NOT CARRIED rows as the honest, correct disclosure of a real but small gap rather than a defect blocking approval." |

**The two new carriers' fixes — verified native, correct, and consistent:**

- **`design-briefs.md` §1** (`:64-75`): fields placed after CONVERGENCE HISTORY in this file's `[WHY: …]` voice; OUTPUT/VERDICT bullet amended at `:96-97`. Its WHY makes two checkable claims and **both are true**: `:21` does say "ROUND `&lt;N&gt;`" (dispatched fresh every round), and `:53-58`'s CONVERGENCE HISTORY does give Major counts and clusters but **no diff range** — so the field is not redundant with it.
- **`worked-briefs.md` §2** (`:104-114`): fields after SCOPE, VERDICT amended at `:141-143` matching `car-brief.md`'s conditional phrasing. Its WHY cites §3's fix cycle; I opened `:173-174` and the quote *"verify-the-fix scope, not a full re-review"* is **verbatim**.
- BASE-DELTA's conditional scoping is consistent across all six files ("on any round after the first, or any rotation" / "when this is a delta re-review" / "when round &gt; 1" / "when this gate has run before"). No contradictions.

---

## RULINGS ON THE QUESTIONS ASKED

**Does the ownership note actually prevent future divergence? — LARGELY YES, and by the right mechanism.** `worked-plan.md:169-177` names `worked-adversary-and-gate-briefs.md` §3 the single authoritative owner of the enumeration, because that is the artifact a conductor copies into a real brief. The reciprocal pointer already existed (`:88` sends readers *here* for the verdict shape). **Two pieces of content, each owned by exactly one file, each pointing the other way for the piece it does not own** — that is a genuine ownership split, not a cross-reference gesture. The deeper reason it works: the two lists are no longer the same content restated. §3's `(a)`-`(e)` are one-clause *specifications*; `worked-plan.md`'s are *outcome narratives* ("This dimension is what caught the ancestor's three-round plan: invented constructor params, an invented type, a wrong-generic logger"). They cannot drift the way two copies of one list drift, because they are no longer two copies.

**Is keeping the historical `(a)`-`(e)` honest or confusing? — HONEST.** The note precedes the list, is bolded, and describes it accurately: "kept because the narrative below is about WHAT each one caught, not a restatement of the current count." I checked that claim against the text and it holds. `(f)`/`(g)` are then named and pointed at the brief template rather than re-derived (`:190-194`). A reader reading the section top-to-bottom cannot mistake it.

---

## FINDINGS: **0 Major, 0 Minor, 3 Notes**

- **N-7 — `car.md` and the unreproducible-evidence duty (my judgment call, flagged not buried).** I ruled `car.md`'s N/A correct because it is an agent definition, not a brief or verdict shape. But the honest counter-argument exists and belongs on the record: `car.md:36-41` already specifies *verdict content* ("end with a constitution check"), and "flag any finding resting on evidence you could not re-derive" is a **standing** duty, unlike BASE-DELTA which is conditional and per-dispatch. If a conductor ever writes a brief from memory and omits it, `car.md` is the backstop — the same argument that carried m-3. I am not raising it as a finding (it is an enhancement, not a gap, and #13's ticket scope is the verdict template), but it is the one N/A in the inventory I would revisit first.
- **N-8 — the inventory is not durable, and that is a future-carrier risk, not a defect here.** The cap as I wrote it required the inventory be *produced*, not *committed*, so its absence from the repo is **not** a cap failure and I will not treat it as one — moving my own goalposts at the closing gate would be its own failure. But nothing in the repo now prompts anyone to re-run this check when carrier #11 is added, and the class the cap closed is precisely "nobody looks at the file nobody thought of." Recommend a ticket: either commit the inventory table beside the templates, or land the `repo-policy-check-patterns.md` §1 gate pattern as a test asserting every file containing a dispatch opener also contains both field names. The second is mechanism-tier and would retire this whole class.
- **N-9 — #40's carrier completeness has the same shape and has not had the same treatment.** `RENDERING CHECK`/computed-style appears in `car-brief.md` (6 hits) and `car.md` (1) and in **none** of the other four carriers — including `worked-briefs.md` §2, whose fictional sentence check explicitly ends at "**rendered DOM**" (`:104-105`). This is out of #40's ticketed scope (its proposed carrier change named `car-brief.md`'s addendum, all three items of which landed) and out of my cap's scope (#13's fields), so it is **not** a finding and **not** a merge blocker. But it is the identical class, one ticket over, and it should get an inventory rather than another three-round discovery sequence. Recommend folding it into N-8's ticket.
- **Cosmetic, not numbered:** `worked-plan.md:170` says "the authoritative, current enumeration - **now (a) through (g)** - lives ONE PLACE" — restating the very count it tells readers not to restate. If an `(h)` lands, that parenthetical is the stale thing. Dropping four words fixes it. Mentioned for the author's convenience, not as a defect.

---

## SUITES — run myself at `4b2fb26`, pwsh 7

| Suite | Observed | Series |
|---|---|---|
| `scripts/tests` | **181 passed / 0 failed / 1 skipped / 182 total** | unchanged r1→r2→r3 |
| `scripts/store-checks` | **178 passed / 0 failed / 178 total** | unchanged |
| `scripts/tests/DocPolicy.Tests.ps1` | **2 passed / 0 failed** | **green** |

Same single detached-HEAD skip. Car's `182/182` attached claim reconciles exactly. Tree clean, HEAD confirmed post-run.

---

## CONVERGENCE — I hold the series

| Round | Major | Minor | Notes | Character |
|---|---|---|---|---|
| r1 | **3** | 7 | 4 | Instance discovery |
| r2 | **1** | 3 | 2 | Fix-revealed carrier; **cap set** |
| r3 | **0** | 0 | 3 | Class closed |

Majors **3 → 1 → 0**. Findings shrank and moved every round — the shop's signature of converging work. **No swirl trigger fires at r3:** Majors declining ✓; no finding is a defect this round's fixes created ✓; the same-section clustering that fired at r2 is *resolved rather than repeated*, because the cap forced a class remedy and the class remedy immediately found two instances that three rounds of instance-fixing had missed.

**That is the case for caps, demonstrated on this train.** Rounds 1 and 2 each fixed exactly what the reviewer named, correctly, and each left the class alive — including in my own reviews, whose round-1 search pattern had the same blindness I faulted the car for. The cap is what changed the method, and changing the method is what ended the series.

**MERGEABLE: YES, from `4b2fb26`.** All three chains clear: **#40** (`509229a`, `7cf2e48`, `000111b`), **#13** (`e511c5e`, `3e267e2`, `c4fe88b`, `8446a3a`, `4b2fb26`), **#9** (`71d0c25`, `c7e263e`). Every round-1, round-2 and cap obligation closed with evidence I re-derived myself. My APPROVE is given.

---

## #9 DISPOSITION — final, for the conductor to action at merge

Unchanged across all three rounds, and now unblocked. **Close #9 at merge, having first split items 2 and 3 into their own cross-linked issues.**

1. **Item 1 is delivered and correct.** Sections 9 and 10 are folded; both false rows are fixed and now *teach* via honest NOT CARRIED disclosures; the numbering gap is closed; §11 acknowledges the disposition. The ticket's own deadline — "before the next spec is written from `worked-spec.md`" — is discharged, and leaving #9 open would make the board show a docs gap that no longer exists, which is Law 1 pointed at this project's own status surface.
2. **Item 2 (CI walks the ledger)** is mechanism-tier work with its assertion already specified (spec round 4: *the annotation must be a substring of the target*) and its pattern already in-repo. Two standing cautions for whoever builds it, carried forward from rounds 1 and 2: §10's DR-1 row ("lane badge → Section 4") **will** fail that check, since §4 says "the three self-computing comparisons" and never "lane badge"; and the two **NOT CARRIED** rows need an explicit exemption or the checker will red on the most honest rows in the table. **Consider scoping it to also cover N-8** — one gate that asserts carrier completeness and citation resolution retires both classes at once.
3. **Item 3 (the `Project-Bootstrapping` mirror)** cannot be verified from this repo — flagged unreproducible in all three rounds — which is exactly why it needs its own ticket rather than holding #9 open indefinitely.

Files: `<repo>-wt\review-process-docs\docs\templates\worked-plan.md`, `<repo>-wt\review-process-docs\docs\templates\design-briefs.md`, `<repo>-wt\review-process-docs\docs\templates\worked-briefs.md`, `<repo>-wt\review-process-docs\docs\templates\worked-adversary-and-gate-briefs.md`, `<repo>-wt\review-process-docs\docs\templates\worked-spec.md`, `<repo>-wt\review-process-docs\docs\templates\car-brief.md`, `<repo>-wt\review-process-docs\.claude\agents\car.md`.

```starcar-artifact
outcome: APPROVE
task-id: process-docs-review-r3
findings: 0 Major, 0 Minor, 3 Notes. CAP CLEARED. I set the round-2 cap so I ruled on it against its own terms, and I re-derived the inventory independently rather than accepting the car's table. ls returns 16 files in docs/templates plus 1 in .claude/agents = 17, matching the car's scope. A wide-net token scan across all 17, deliberately broader than my round-1 pattern that missed worked-plan.md, identified exactly TEN carrier sites in six files, and my independent set matched the car's set exactly, including BOTH new carriers the cap surfaced that no prior round had named - design-briefs.md section 1 (the round-N design reviewer brief, dispatched fresh every round, whose CONVERGENCE HISTORY at :53-58 gives Major counts and clusters but no diff range, so the field is not redundant) and worked-briefs.md section 2 (the worked reviewer brief that section 3's fix cycle sends back to for a delta re-review, quote verified verbatim at :173-174). Two agents, two methods, same ten sites - that convergence is why I clear the cap rather than merely accept a table. I opened and ruled every N/A myself, the four the brief named plus six more, and every N/A is correct: worked-rung-carriers.md is chain doctrine whose fidelity table is one section of a verdict, and adding an unreproducible column there would CONTRADICT #13 whose complaint is that such evidence must not live in a table cell, so the alternative is actively wrong; worked-spec.md section 11 is a summary of verdicts already rendered, authored by the spec's author; design-doc.md is an authoring template whose reviewer-side counterparts are design-briefs sections 1 and 2, both now covered; car.md is an agent definition of standing duties; worked-ledger-and-gating.md and state-ledger.md are instructive false positives where Verdict is a LEDGER COLUMN WORD (SAFE, LATENT_BUG, DELIBERATE_CARRY, RESET, CARRY) in a wholly different sense, which is the proof that the cap's open-each-file clause was operative rather than ceremony. Mechanical confirmation: both fields now present in all five template carrier files (BASE-DELTA 2/4/7/2/3, UNREPRODUCIBLE 4/5/8/2/3). ROUND-2 WALK, 6 of 6 CLOSED: M-4 worked-plan.md:196-209 now carries both fields INSIDE the fictional REJECT verdict shape rather than as an instruction, which is the stronger form since a reader copying the shape copies the fields, plus a none-every-claim-is-re-derivable example teaching that a negative callout is still a callout; m-8 re-verified against drill:66, :105 and :110 with no residual inversion, the WHY now quotes the praise verbatim and names PLACEMENT as the actual complaint; m-9 record correction present as a full paragraph in 4b2fb26's message; m-10 (f) and (g) compressed to one clause each within sibling range with the WHY block intact; N-5 now one per obligation; N-6 section 11 now records the round-2 reviewer accepting the NOT CARRIED rows. RULINGS ASKED FOR: the ownership note DOES largely prevent future divergence and by the right mechanism - two pieces of content each owned by exactly one file each pointing the other way, and the two lists are no longer the same content restated since section 3's are one-clause specifications while worked-plan's are outcome narratives, so they cannot drift the way two copies drift; keeping the historical (a)-(e) is HONEST because the bolded note precedes the list and accurately describes what follows. NOTES: N-7 car.md's N/A is correct for cap purposes but the unreproducible callout is a STANDING duty unlike the conditional BASE-DELTA, and car.md already specifies verdict content, so it is the one N/A I would revisit first - flagged not buried; N-8 the inventory lives only in the car's report, which is NOT a cap failure since I required it produced not committed and moving my own goalposts at the closing gate would be its own failure, but nothing now prompts a re-check when carrier 11 is added, so recommend a ticket to commit the table or land a repo-policy gate asserting every file with a dispatch opener carries both field names; N-9 #40's rendering floor appears in car-brief.md and car.md and in NONE of the other four carriers including worked-briefs.md section 2 whose fictional sentence check ends at rendered DOM - out of #40's ticketed scope and out of my cap's scope so not a finding and not a blocker, but the identical class one ticket over, recommend folding into N-8's ticket. SUITES at 4b2fb26: scripts/tests 181 passed 0 failed 1 skipped 182 total, store-checks 178 of 178, DocPolicy 2 of 2 green, tree clean. CONVERGENCE: Majors 3 to 1 to 0, findings shrank and moved every round, no swirl trigger fires at r3, and the r2 clustering is resolved rather than repeated because the cap forced a class remedy that immediately found two instances three rounds of instance-fixing had missed - including in my own reviews, whose round-1 search had the same blindness I faulted the car for. MERGEABLE YES from 4b2fb26, all three chains clear.
abstract: Round-3 delta re-review of three fix commits (c4fe88b, 8446a3a, 4b2fb26) against round 2's six findings and the binding cap, at base 000111b. APPROVE with zero Major and zero Minor. The cap is CLEARED on my own independent re-derivation, not on the car's table: I enumerated both directories, scanned all 17 files with a deliberately wider net than my own round-1 pattern, and arrived at the same ten carrier sites the car found, including the two carriers the cap surfaced that three prior rounds had missed. Every not-applicable classification I opened is correct, two of them instructively so. All six round-2 findings are closed with evidence I re-verified, M-4's fix landing the fields inside the worked verdict shape rather than beside it. Three Notes are forward-looking and none blocks merge: a judgment call on the agent definition, the inventory's lack of a durable home, and the same carrier-completeness class sitting unaddressed one ticket over on #40. The series ran 3 Majors to 1 to 0 and the cap is what ended it, by changing the method rather than fixing another instance. Train mergeable; #9 disposition restated for action at merge.
```