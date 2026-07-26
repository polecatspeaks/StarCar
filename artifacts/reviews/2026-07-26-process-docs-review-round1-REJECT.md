<!-- starcar-integrity: sha256=c639fd943da8ea606a08989ba5eea494c7d04e5ba3f3fd98df49df7dd7e3ab5c covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car process-docs review - round 1 (REJECT)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial documentation review (citation walk + cold-reader)
Round: 1
Target: `commits 509229a, e511c5e, 71d0c25 on car/process-docs (#40, #13, #9)`
Base reviewed: `71d0c25d3d34a811b358d798a0c0661df1ce11bb`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

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
| Base commit the reviewer read (**the lookup key**) | `71d0c25d3d34a811b358d798a0c0661df1ce11bb` |

| Dispatch, the locator within the session | `a7fbcee7ccaec45d8` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 71d0c25d3d34a811b358d798a0c0661df1ce11bb
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

---

# VERDICT: **REJECT** — 3 Major, 7 Minor, 4 Notes

Base verified: worktree `<repo>-wt\review-process-docs`, HEAD `71d0c25d3d34a811b358d798a0c0661df1ce11bb`, clean tree before and after review. Read-only: I edited, committed, and pushed nothing.

**BASE-DELTA (#13):** not applicable — this is round 1; no prior round reviewed any base in this series. (That the new field's own applicability had to be reasoned out is Minor m-2 below.)

**UNREPRODUCIBLE-EVIDENCE CALLOUT (#13):** exactly one item in this review rests on evidence I structurally cannot re-derive — residual item 2 in `docs/templates/worked-spec.md:183-185` (the `Project-Bootstrapping` mirror). That repository is not present in this worktree. I did **not** rule on it; I state below only what follows from this repo's own files.

---

## SUITES — run myself at `71d0c25`, pwsh 7, `Invoke-Pester`

| Suite | Observed |
|---|---|
| `scripts/tests` | **181 passed / 0 failed / 1 skipped / 182 total** |
| `scripts/store-checks` | **178 passed / 0 failed / 178 total** |
| `scripts/tests/DocPolicy.Tests.ps1` | **2 passed / 0 failed** |

The single skip is verbatim: `run-session-start-guards.sh: agent-pull runner (#50).running the REAL guards prints [ci-baseline]'s marker ONLY when attached to a branch - conditional, never asserted as always-emitting`. That is the expected detached-HEAD profile and reconciles with the car's `182/182` attached claim: same total, one test that only asserts on a branch. **Car's claim CONFIRMED.** No suite regression; all three commits are docs-only.

---

## MAJOR FINDINGS

### M-1 (#13, `e511c5e`) — the placement premise is false, and the rung where the finding was born was left stale

`docs/templates/car-brief.md:94-98` declares BASE-DELTA **"mandatory whenever this round reviews a base a PRIOR round already reviewed - rotation and delta re-reviews."** The commit message justifies landing it in exactly one file:

&gt; "no separate verdict/reviewer template file exists (confirmed by listing `docs/templates/` and grepping `worked-*.md` for verdict shapes)"

I re-derived that claim and it does not hold.

- `docs/templates/design-briefs.md` (**`Status: Current`**, `:3`) — `:105-124` is a section titled literally **"## 2. The DELTA re-review (after a fix, to the SAME reviewer)"**, the single most on-point home in the repo for a base-delta field. Its `VERDICT:` line at `:123` now omits a field the standing template calls mandatory. `:18-103` is "The design reviewer brief" with its own `VERDICT:` at `:84`.
- `docs/templates/worked-adversary-and-gate-briefs.md` — four reviewer briefs with four verdict shapes: design adversary (`:37`), spec adversary (`:64`), **plan adversary (`:74-91`)**, whole-branch gate (`:122`).
- `docs/templates/worked-briefs.md:86-132` — "## 2. The adversarial reviewer brief", `VERDICT:` at `:129`.

Two things make this Major rather than a tidy-up:

1. **The stated search could not have found the counter-example.** The glob `worked-*.md` structurally cannot match `design-briefs.md`. The one file carrying a dedicated DELTA re-review template is the one file the search excluded by construction.
2. **The obligation did not reach the rung that produced it.** The drill this ticket is built on was a **plan review** (`artifacts/reviews/2026-07-22-car2-plan-review-round2-drill.md`, Car 2's *plan*, round 2). The plan adversary brief is `worked-adversary-and-gate-briefs.md:74-91` and received nothing. This is the carrier rule's own failure mode — *obligations cross rungs by carrier, never by memory* — committed in the diff whose purpose is to install a carrier.

Per `.claude/agents/car.md:53-54`: "A diff that invalidates a document and leaves it stale is a MAJOR finding."

**Remedy:** either land the two fields in `design-briefs.md:105-124` and `worked-adversary-and-gate-briefs.md` §§1-4 in the same commit, or state in `car-brief.md` that the addendum is the **car-rung** brief and add an explicit cross-reference obliging the other rungs. Correct the commit-message claim on the way through.

### M-2 (#9, `71d0c25`) — `worked-spec.md:93` is a false contracts-touched row that contradicts its own document

New §9 row 1:

&gt; `` `docs/contracts/state-ledger.md` `` | Instantiates the **new mutable field** `Snapshot.verdict` with the old -&gt; delta -&gt; new arithmetic **from section 5** | Car B

Opening section 5 (which the row cites):

- `worked-spec.md:60` — `| Snapshot.verdict | **NOT STATE** - recomputed per snapshot | ... |`
- `worked-spec.md:63` — "Every new MUTABLE field (**none in this feature** - say so explicitly when true)"
- Section 5 contains **no arithmetic of any kind**.

So the row asserts a new mutable field where the cited section declares there is none, and cites arithmetic that section does not contain. `docs/contracts/state-ledger.md:11-14` confirms the ledger's subject is mutable process state with old→delta→new arithmetic, so the two readings cannot both stand.

The provenance makes it sharper: the real spec's corresponding row says the **opposite**, and correctly — `docs/specs/2026-07-22-dispatch-harness-spec.md:328`: *"Instantiated - records that the store is append-only under git and **process state is nil**."* The adaptation inverted the row's meaning while carrying its shape.

This is the exact failure the new §10 warns about three paragraphs later (`worked-spec.md:128-135`: *"a row claiming a section carried something that section did not actually say"*), shipped inside the exemplar that teaches the warning. A stranger copying §9 (Law 7 — and `docs/setup.md:43` names this file as *the* spec-rung exemplar) copies a contracts row that contradicts its own lifecycle section.

**Remedy:** make the row say what the fiction supports — e.g. "Instantiated - records that this feature adds no mutable process state (section 5), so the ledger's arithmetic is 0 -&gt; 0" — which also demonstrates the non-vacuity discipline `:87-89` claims for the section.

### M-3 (#9, `71d0c25`) — `worked-spec.md:119` is a false fidelity-ledger row; the cited sections are silent

New §10 row 7:

&gt; Owner decision: thresholds configurable per deployment, defaulted 30s/120s | **Section 2 (opening line), section 3**

I opened both, and grepped the whole file for every threshold token (`hreshold|configurab|30s|120s|deployment`). Hits: `:23`, `:41`, `:60`, `:70`, `:114`, `:119`. Therefore:

- **Section 2's opening line** (`:34-36`) — "derived in the adapter layer at snapshot arrival… carried ON the snapshot record". No configurability, no defaults. The only §2 threshold text is bullet 2 (`:41`), which is about *read-once* and says nothing about configurability or 30s/120s.
- **Section 3** (`:46-48`) — "closed string union; `Snapshot.verdict` required…; the banner consumes ONLY `verdict` + `fetchedAt`". **Zero** threshold references. The cited section is silent.

The claim's only actual home is `:23`, the document **header**, which is not a numbered section — which is itself the honest finding this table exists to surface (the owner decision was never carried into any section). Row 5 (`:117`) is soft in the same way: §2's opening line says "derived in the adapter layer", never "never the browser clock alone".

§10's own rule, one line above the table's failure (`:131-132`): *"it is checked by OPENING the cited section, never by trusting the row."* The exemplar demonstrates the false row rather than the discipline, and `:125-126` names the consequence itself: *"the fold that LOOKS folded."*

**Remedy:** either point row 7 at section 5's config-reload cell (`:60`, the only section text that acknowledges changing thresholds) plus a blank-is-a-defect note, or — better teaching — leave the row and mark it `NOT CARRIED - header only`, demonstrating what a fidelity ledger is *for*.

---

## MINOR FINDINGS

- **m-1 (#40, `car-brief.md:126-134`)** — the floor names *which* things to measure but never requires **reporting the observed values**. Issue #40's own carrier item 1 ends *"Report observed values."*, and the sibling line at `:112` ends *"Report observed."* A reviewer could name registers and states and assert correctness without printing a single `rgb()`. One clause fixes it.
- **m-2 (#13, `car-brief.md:168-169` vs `:94-95`)** — the VERDICT line requires "BASE-DELTA (#13) and **any** UNREPRODUCIBLE-EVIDENCE callouts… stated explicitly"; "any" qualifies the callouts, not BASE-DELTA, so the VERDICT line reads unconditional while `:94-95` reads conditional. Readable two ways, and I demonstrated it: as a round-1 reviewer I had to adjudicate my own template. Remedy: "BASE-DELTA (#13) **when this is a re-review**".
- **m-3 (#40, `.claude/agents/car.md:68-70`)** — the same commit amended GUARD CHECK in `car-brief.md:147-150` with the visual-guard clause and left the standing statement of that same rule in the reviewer agent definition unamended. `CLAUDE.md` explicitly names these two files as the paired carriers for brief mandates ("`docs/templates/car-brief.md`, `.claude/agents/car.md`, so it binds by template, not by memory").
- **m-4 (#9, `worked-spec.md:98`)** — "(design section 8, nine rows, with owners)". The named referent, the design-rung **template** `docs/templates/design-doc.md:123-126`, contains no table and **no rows**; the real design's §8 (`docs/design/2026-07-22-dispatch-harness-design.md:250-259`) has **eight** rows. Inherited verbatim from the round-1 verdict at `:67`, so the number's origin is the verdict — but a template is read cold and the parenthetical is uncheckable at either referent.
- **m-5 (#9, `worked-spec.md:159`)** — the heading reads "**(#9, closed 2026-07-26)**" while #9 is OPEN with two of its three closing requirements unmet, as the same block states at `:176-185`. The prior heading's parallel form ("KNOWN GAP - disclosed, not yet fixed (2026-07-22)") pushes the reader toward the wrong reading on the most-glanced line.
- **m-6 (#13, `car-brief.md:163-166`)** — the quotation **reorders** its source. Rendered as one quote with ellipses: *"a 'findings on unreproducible evidence' flag would have pointed me straight at C2R2-M1... M3/M4 were unverifiable-by-construction (gitignored probe)... it lives buried in a table cell"*. The source (`drill:110`) runs in the opposite order: M3/M4 clause → "yet it lives buried in a table cell" → "A 'findings on unreproducible evidence' flag would have pointed me straight at C2R2-M1." Every substring is verbatim; the sequence is not, and ellipses elide rather than permute. In a repo whose verdicts are sha256-covered and land verbatim, a permuted quote in a standing template is a real defect. (Quote 1, `car-brief.md:100-104` against `drill:103`, is **verbatim and correctly cited** — I checked it word for word.)
- **m-7 (#13, `car-brief.md:99-100`)** — "could reconstruct **every prior finding** from the landed verdict except one thing" overstates the drill. `drill:105`: *"The only inheritable blind spot (M3/M4's gitignored probe) was recorded honestly as UNVERIFIABLE"* — M3/M4 were **not** reconstructable. That is the second thing, and it is the entire basis for the second addition in the same commit.

---

## NOTES

- **N-1 (#40)** — "50 passing DOM tests" is #33's figure for the **#31** defect, which #33 says *"was caught by a human eye at first light"*, not by the Car 31 reviewer. The sentence survives on substance: the hand-built model did independently measure a live rendering fact DOM tests missed (`2026-07-23-car31-register-css-review-round1-APPROVE.md:256` — 61 text elements still red post-fix, which became #36). The compression just invites the wrong attribution. Numbers themselves check out: 11 `color:` declarations and 216 text-bearing elements are verbatim at `:112` and `:114` of that verdict.
- **N-2 (#9)** — §10's DR-1 row ("lane badge → Section 4") would **fail** the substring check that #9's own item 2 proposes and that spec round 4 specified ("the annotation must be a substring of the target"): section 4 (`:52-54`) says "the three self-computing comparisons" and never the words "lane badge". True on substance via §11, uncheckable by machine. Worth knowing before that gate is built.
- **N-3 (#9)** — the DR-1→§4 / DR-2→§2 / DR-3→probe mapping now exists in two templates (`worked-rung-carriers.md:43-45` and `worked-spec.md:113-115`) with no cross-reference. They agree today. Note that the two tables are different artifacts by design — the carrier doc's is the **adversary's** Present/Absent/Drifted walk, §10 is the **author's** self-report — so this is drift exposure, not duplication of authority.
- **N-4 (#9)** — the real spec still carries the numbering gap (`docs/specs/2026-07-22-dispatch-harness-spec.md:338` §10 → `:356` §12, no §11), so the template now diverges from the source it transposes. Out of this diff's scope; worth one line on a ticket.

---

## CITATION WALK — every citation the diff makes, opened

| Citation | Verdict |
|---|---|
| `2026-07-26-view-30-review-round1-REJECT.md` "THE COMPUTED-STYLE GATE" §, `:137-176` | **TRUE** — heading at `:137`, section ends `:176` before the `---` at `:177` |
| `…:173` quote | **VERBATIM** — "The finding a DOM test could never have produced… the #31 cascade-inheritance defect does **not** recur" |
| `rgb(217, 213, 201)` for a NOTE group in a `register-needs-attention` strip | **TRUE** — `:166` (spaced form, as quoted) and `:173` |
| #33's simulation-not-measurement story / 50 tests | **TRUE**, see N-1 for the attribution nuance |
| 11 `color:` decls, 216 elements | **TRUE** — car31 verdict `:112`, `:114` |
| #31 proves a text-level guard passes while the defect is live | **TRUE** — #33 body item 2; car31 verdict `:178` (`color: inherit` → 6 pass / 0 fail) |
| `drill:103` (BASE-DELTA) | **VERBATIM, correct line** |
| `drill:110` (unreproducible evidence) | substrings verbatim, **sequence permuted** → m-6 |
| `harness-spec-round1-REJECT.md:67` (M2, nine obligations) | **TRUE** |
| `…:68` (M6, five dropped requirements) | **TRUE** |
| `…:72` numbering quote | **VERBATIM** — "the template jumps §8 → §12 with no §9-11 and no explanation… an unexplained gap teaches every future author to leave one" |
| Round history 8 → 1 (N1) → 1 (mechanical) → APPROVE | **TRUE** — verdict lines `:11` of all four files; #9's body confirms N1 was the false §10 row |
| `docs/contracts/state-ledger.md`, `docs/contracts/gating-matrix.md`, `docs/glossary.md` | **ALL EXIST** |
| `gating-matrix.md:23` = the staleness-banner example row | **TRUE** — `docs/templates/gating-matrix.md:23`, and "this project's own gating-matrix **template**" disambiguates from the contracts copy |
| `worked-rung-carriers.md:57-58` "make CI walk it" | **TRUE, verbatim**; "predicted the false-row failure" is a fair-but-generous reading of a passage about central-ledger drift |
| "design section 9b" one-row-per-finding rule | **TRUE** — `design-doc.md:132-135` |
| "design section 8, nine rows, with owners" | **FALSE on the row count** → m-4 |
| §9 row 1's "arithmetic from section 5" | **FALSE** → M-2 |
| §10 row 7's "Section 2 (opening line), section 3" | **FALSE** → M-3 |
| §10 rows DR-2, DR-3, DR-4, UNKNOWN-first-class | **TRUE** — `:41`, `:76`, `:82`, `:39` |

**Renumbering (#9c):** internally consistent. The only live cross-reference, `:42`, moved 12 → 11 correctly; `:188`'s "§8 → §12" is inside a verbatim quote about the prior state and is correct to leave. No dangling section numbers anywhere in the file; no repo-wide reference to the deleted "KNOWN GAP" heading survives.

**Template-consumer check (#9e) — re-derived, car's claim CONFIRMED:** `docs/doc-map.md:43` says `docs/templates/` (16 files) — `ls` returns 16, no file added; "nine of those" worked-* exemplars — nine exist. **Not stale.** `docs/setup.md:43` enumerates worked-spec.md's contents without section numbers or counts, and asserts nothing the fold contradicts. **Not stale.** `worked-rung-carriers.md:66` cites "worked-spec.md section 5" — unchanged. `docs/specs/…:398-401` records round 4 parking two items on #9; one is now landed, but that is a historical review record ("The review records stay IN the spec forever"), not a live claim.

**Citation check (tickets tagged inline):** PASS. `#40` at `car-brief.md:126`, `:148`; `#13` at `:94`, `:158`, `:168-169`; `#9` at `worked-spec.md:85`, `:105`, `:159`. Bare `#N` form throughout; all three numbers verified correct against `gh issue view`.

---

## THE SENTENCE CHECK (documentation form)

**#9's sentence:** verdict `2026-07-22-harness-spec-round1-REJECT.md:67-68` → ticket #9 body ("What closing this requires", 3 items) → `worked-spec.md:85-135` (the fold) → `docs/setup.md:43` ("Use it directly", naming this file as *the* spec-rung exemplar) → a future spec author with zero context. **The sentence breaks at the last hop:** that author copies §9 row 1 and §10 row 7, and inherits two rows that are false against the very sections they cite. The exemplar transmits the shape correctly and the discipline incorrectly.

**#13's sentence:** `drill:109-110` (two template GAPs) → ticket #13 → `car-brief.md:94-104`, `:158-166`, `:168-169` → a dispatched reviewer brief → the landed verdict record. **The branch that runs through the design, spec, plan and gate rungs never receives the field** (M-1) — including the plan rung, where the drill that wrote the finding actually ran.

**#40's sentence:** #31 (live defect, 50 tests green) → #33 (adopt a real browser) → the Car 31 reviewer's hand-built cascade model → #40's carrier proposal (3 items) → `car-brief.md:126-150` → the view-30 round-1 verdict `:137-176` as the worked proof. **This one traces end to end.** All three of #40's proposed items landed; item 2's judgment half is preserved verbatim from the ticket ("a spelling check with better instrumentation"), which was the ticket's central worry.

**Cold-reader test (#40c):** the trigger is workable — the CHECK fires on touching a rendered surface, and the EVIDENCE BAR binds claims about rendering, so a comment-only JS diff carries the line and finds no rendering claim to settle. "anything a user SEES" is a broad catch-all but errs toward inclusion, which is the right direction for a floor. Two soft edges: no explicit demand to report values (m-1), and "collapsed/expanded states" is specific to the board-conditions strip and reads oddly for a non-collapsible surface. Neither is disqualifying.

---

## PREMISE CHECK (#46)

- The brief handed me the car's ruling that **"there is no separate verdict template - the reviewer addendum IS the home."** I tested it rather than confirming it, and it is **false** — that is M-1. Five reviewer-brief shapes exist across three files, and the car's stated search glob could not have seen the most relevant one.
- The brief's second premise — that doc-map and the template consumers were checked and are clean — I re-derived independently and it **holds**. Counts at `doc-map.md:43` are still true.
- The brief's framing of the `:173` quote as verifiable-verbatim **holds**.

---

## CONSTITUTION CHECK

| Law / rule | Evidence |
|---|---|
| **1. Truth** | **NOT HONORED.** The commit message's "no separate verdict/reviewer template file exists" is false (M-1); `worked-spec.md:93` and `:119` are confident falsehoods on a template a stranger deploys from (M-2, M-3). |
| **2. The Dispatcher Commands** | **HONORED.** The car put #9's close/keep-open question to the conductor rather than self-adjudicating it — correct escalation, not a resolution it does not own. |
| **4. Nothing Silently Lost** | **HONORED.** `worked-spec.md:176-185` discloses both residuals; I checked them against #9's three-item closing list and the mapping is exact and complete. Nothing was quietly dropped. |
| **6. One Truth** | **HONORED.** §9/§10 are a transposition into the staleness-banner fiction, not a second copy of the real spec: rows differ, content is fictional, and `:161-174` declares the source. See N-3 for a drift-exposure note, not a violation. |
| **7. The Stranger** | **NOT HONORED for #9.** The cold reader is exactly who M-2 and M-3 injure — `docs/setup.md:43` sends them here and tells them to use it directly. Honored for #40 (the trigger and bar are applicable without insider context). |
| **Carrier rule** | **VIOLATED** by M-1: the obligation crossed into one carrier and not into the rung that produced it. |
| **Documentation ranks equal to code** | **VIOLATED** by M-1: `design-briefs.md:105-124`, a `Status: Current` delta-re-review template, was invalidated and left stale in the same commit that invalidated it. |
| **The instrument matches the artifact** | **HONORED** in intent — #9's fold correctly carries a shape that survived four adversarial rounds instead of inventing one, and correctly waited for the trigger its own prior note set. |

---

## #9 DISPOSITION — my recommendation

**Do not close #9 now** — M-2 and M-3 are defects in the very sections item 1 delivers, so item 1 is not yet done. After they are fixed:

**Close #9, having first split items 2 and 3 into their own issues, cross-linked.** Reasoning:

1. **The ticket's own deadline is the fold.** #9 states the debt "must close **before the next spec is written from `docs/templates/worked-spec.md`**". That urgency attaches entirely to item 1. Once §9/§10 are correct, the reason #9 was time-boxed is discharged, and leaving it open makes the board show a docs gap that no longer exists — Law 1 pointed at this project's own status surface, which is its whole thesis.
2. **Item 2 is a different KIND of work under a different label.** "Make CI walk the ledger" is a mechanism-tier gate: code, a CI step, red-first proof. Its assertion is already specified (spec round 4: *the annotation must be a substring of the target*) and its pattern already exists in-repo (`docs/templates/repo-policy-check-patterns.md` §1, landed as `scripts/tests/DocPolicy.Tests.ps1`). It belongs in a tooling/repo-policy train where it can be sized and dispatched, not carried as a tail on a docs ticket — and N-2 above is free evidence for whoever picks it up that the exemplar's own DR-1 row will fail that check.
3. **Item 3 can never be verified from here, and that is precisely why it needs its own ticket.** A closure condition unverifiable in the repo the issue lives in makes for a permanently-open umbrella. It is also newly urgent in one direction I can name without leaving this repo: as of `71d0c25` the upstream note that item 3's disclosure describes no longer exists here, so whatever `Project-Bootstrapping` ships now describes a hole this repo has filled. **I cannot confirm that** — different repository, not present in this worktree — and I flag it as unreproducible rather than assert it.

Closing a ticket whose named scope ("worked-spec.md is missing the two carrier sections") is complete, with two differently-shaped residuals tracked in their own right, is the honest bookkeeping. Keeping it open as a two-tailed umbrella is how a ticket becomes furniture.

---

## WHAT IS GOOD (and where an assigned attack failed)

The #40 commit is the strongest of the three: all three of the ticket's proposed carrier items landed, the judgment half is preserved in the ticket's own words, and the worked proof it points at is real and quotes correctly. The #9 round-history claim (8 → 1 → 1 → APPROVE, N1 closed on substance, no further false row) is **exactly right** against all four verdict files — the trigger the prior note set was genuinely met, not asserted. The renumbering is clean with no dangling references, the "Known fallibility" paragraph keeps a failure visible rather than smoothing it, and the residual disclosure maps one-to-one onto #9's closing list. Two attacks I was assigned **failed to find anything**: the template-consumer staleness check (doc-map, setup.md, rung-carriers all survive) and the Law 6 second-copy question (the adaptation is a transposition, correctly declared).

Files: `<repo>-wt\review-process-docs\docs\templates\car-brief.md`, `<repo>-wt\review-process-docs\docs\templates\worked-spec.md`, `<repo>-wt\review-process-docs\docs\templates\design-briefs.md`, `<repo>-wt\review-process-docs\docs\templates\worked-adversary-and-gate-briefs.md`, `<repo>-wt\review-process-docs\.claude\agents\car.md`.

```starcar-artifact
outcome: REJECT
task-id: process-docs-review-r1
findings: 3 Major, 7 Minor, 4 Notes. MAJOR M-1 (#13, e511c5e): the placement premise is false and the originating rung was left stale - the commit asserts "no separate verdict/reviewer template file exists (confirmed by listing docs/templates/ and grepping worked-*.md)", but docs/templates/design-briefs.md:105-124 is a dedicated "The DELTA re-review" template (Status: Current) whose VERDICT line at :123 now omits a field car-brief.md:94-95 calls mandatory, and worked-adversary-and-gate-briefs.md carries four more reviewer briefs (:37, :64, :74-91, :122) including THE PLAN ADVERSARY - the rung where the drill that produced #13 actually ran (Car 2's plan review). The stated glob worked-*.md structurally cannot match design-briefs.md. MAJOR M-2 (#9, 71d0c25): worked-spec.md:93 says the state ledger "Instantiates the new mutable field Snapshot.verdict with the old to delta to new arithmetic from section 5", but section 5 declares that field "NOT STATE - recomputed per snapshot" (:60), says "Every new MUTABLE field (none in this feature)" (:63), and contains no arithmetic; the real spec's corresponding row (spec:328) says the opposite and correctly ("process state is nil"). MAJOR M-3 (#9, 71d0c25): worked-spec.md:119 cites "Section 2 (opening line), section 3" for "thresholds configurable per deployment, defaulted 30s/120s"; section 2's opening line (:34-36) and all of section 3 (:46-48) are silent on it - a whole-file grep puts the claim only at :23, the document header, which is not a numbered section. M-2 and M-3 are both the false-row failure that the same commit's own :128-135 paragraph warns about, shipped inside the exemplar that teaches the warning. MINORS: m-1 the rendering floor never requires reporting observed values though #40 item 1 ends "Report observed values"; m-2 the VERDICT line makes BASE-DELTA unconditional while :94-95 makes it conditional (self-demonstrated by this round-1 review); m-3 .claude/agents/car.md:68-70 kept the unamended GUARD CHECK while car-brief.md:147-150 gained the visual-guard clause, though CLAUDE.md names those two files as paired carriers; m-4 "design section 8, nine rows, with owners" is uncheckable - design-doc.md:123-126 has no rows and the real design's section 8 has eight; m-5 the heading "(#9, closed 2026-07-26)" contradicts the open ticket and the two residuals named two lines below; m-6 the drill:110 quotation permutes its source's clause order under ellipses; m-7 "could reconstruct every prior finding" contradicts drill:105, where M3/M4 were unverifiable-by-construction. NOTES on the "50 passing DOM tests" attribution, the DR-1 row that would fail the substring check #9 item 2 proposes, a DR mapping now duplicated across two templates, and the real spec's still-open numbering gap. SUITES run myself at 71d0c25 under pwsh 7: scripts/tests 181 passed / 0 failed / 1 skipped / 182 total (the skip is the detached-HEAD agent-pull runner, reconciling with the car's 182/182 attached claim); scripts/store-checks 178/178; DocPolicy.Tests.ps1 2/2. Tree clean, nothing edited or committed. CITATION WALK: 21 citations opened; three false (M-2, M-3, m-4), one permuted (m-6), the rest true including both #40 provenance quotes verbatim, the drill:103 quote verbatim, the round-1 spec-review M2/M6/numbering quotes verbatim, and the four-round history exactly. PREMISE CHECK: the brief's premise that no separate verdict template exists was tested and DISPROVEN (that is M-1); its premise that doc-map and template consumers are unstale was re-derived and HOLDS. #9 DISPOSITION: do not close now (M-2 and M-3 are defects in the sections item 1 delivers); after the fixes, close #9 and split item 2 (CI walks the ledger - mechanism-tier work with its assertion already specified and its pattern already in-repo) and item 3 (the Project-Bootstrapping mirror - a different repository, unverifiable from here, and newly stale in that repo as of this commit) into their own cross-linked issues, because the ticket's own deadline attaches entirely to the fold and a permanently-unverifiable tail turns an issue into furniture.
abstract: Adversarial review of three docs-only commits (509229a #40 rendering-evidence floor, e511c5e #13 base-delta and unreproducible-evidence fields, 71d0c25 #9 folding contracts-touched and fidelity sections into worked-spec.md) at base 5ba0602. REJECT on three Majors. The #40 commit is sound and traces end to end. The #13 commit rests on a false search premise and leaves the rung that produced the finding without the carrier. The #9 commit lands two rows whose cited sections do not say what the rows claim, which is the exact failure the folded sections exist to prevent, in the exemplar that teaches the lesson. All three suites green and re-derived independently; disposition recommendation given for #9 with reasoning on both residuals.
```