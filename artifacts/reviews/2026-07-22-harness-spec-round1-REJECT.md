<!-- starcar-integrity: sha256=c979ea4fc12956dbb6afb2f4c5ada3929fdd44a6266dc9d884ed98491171e0e8 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Adversarial spec review - dispatch harness, round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: spec review (ladder rung 2)
Round: 1
Target: `docs/specs/2026-07-22-dispatch-harness-spec.md`
Base reviewed: `7e49d43dcc923d923260302dd64d8f89166380d7`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT - 8 Major, 7 Minor, 6 rulings; bounded rev 2 recommended, not a rewrite**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a543c37ea68e622d8`. The conductor did not retype a word of what follows. Verbatim by
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
> Path normalisation: none applied (the body contained no operator-environment paths).

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `7e49d43dcc923d923260302dd64d8f89166380d7` |
| Entire checkpoint | `016d094d11c0` |
| Dispatch, the locator within the session | `a543c37ea68e622d8` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 7e49d43dcc923d923260302dd64d8f89166380d7
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

VERDICT: **REJECT** — eight Majors, of which the sharpest are a retirement row citing a string that does not exist in either cited file, a retirement list that misses the two live mirrors of the thing being retired, and a §6 fault-injection whose stated expected value cannot be produced by the producer §2 endorses.

Base verified: worktree `…/scratchpad/review-spec-1` at `7e49d43dcc923d923260302dd64d8f89166380d7`, detached, `git status --porcelain` empty before and after. **No fault injection was performed** — every check below is a read or a read-only script run (`./scripts/Verify-Verdict.ps1`, exit 0). Tree byte-identical.

---

## WORKFLOW VERDICT — `docs/templates/worked-spec.md` as an exemplar

**Overall: it earned its keep, and it has one structural hole that directly caused the largest finding in this review.**

**§4 retirement list — the highest-yield section in the template.** It alone generated M1, M2 and M3. Without it this spec would have said nothing about `Land-Verdict.ps1` / `Verify-Verdict.ps1` at all, and the `docs/setup.md` drift would have surfaced at car time. Keep it, and **amend it**: the template is internally inconsistent about *when* callers get enumerated. §3 says "every constructor site enumerated: [list, file:line each]" — enumeration at spec time. §4 says "'zero remaining callers' is grep-proven in the car's report" — enumeration at car time. The author took the §4 reading and enumerated nothing, and the missed mirror (`docs/setup.md:23-24`) is exactly what a spec-time grep would have caught. Amendment: §4 gains a mandatory **"callers and mirrors found at spec time"** column; the car *re-*proves, never first-proves.

**§5 lifecycle — did real work, but the template makes the null answer too cheap.** "say so explicitly when true" invites precisely the three-row `none / none / none` table this spec produced, and that table is *wrong* about its third row (M7: `INDEX.md` is derived state committed to git with no regeneration gate). The template's own worked rows only contemplate *process* state. Amendment: the section must enumerate **derived and committed artifacts** alongside process state, each with a staleness/regeneration gate named. A "no state" claim that never had to consider generated files is a claim that cannot fail — the round-4 scar ("a demonstration that cannot fail") applies to documentation sections too.

**§7 probe list — the best-performing novel section, and not ceremony.** It produced five honest unknowns, and item 5 is what falsified §2's own second filter (M5). A section that catches a defect in a *sibling section* is the strongest possible evidence it is load-bearing. One amendment: add the rule **"a probe may not restate something an upstream document already ruled; cite the upstream section and confirm it is silent there."** Probe 3 (git-index contention) is a settled design ruling (`design:230`) reopened as an unknown — the exact "silently dropped ruling" failure that design §9b exists to prevent, reintroduced through the probe list.

**The two structural holes, and they are the template's fault, not only the author's:**

1. **There is no "contracts touched / documents this invalidates" section.** `design-doc.md` has one (design §8, nine rows, with owners). The spec template has *no equivalent*, so the design's nine documentation obligations — gating matrix, `setup.md`, `README.md:46-47`, `CLAUDE.md`, `car-brief.md`, `car.md`, `/goodnight` — simply evaporate between the two rungs. That is M2, and it is a hole in the exemplar. In a repo whose CLAUDE.md says documentation ranks equal to code and lands same-commit, a spec template with no doc-obligation section is a contradiction. **This is the single highest-value amendment.**
2. **There is no fidelity ledger.** Design §9b's one-row-per-finding-and-ruling table demonstrably worked — it is why rev 6 could prove nothing was dropped. The spec template has no disposition table, and M6 is five adopted design requirements silently dropped. Amendment: a §11 "design fidelity" table, one row per design premise/decision/§9b ruling, each pointing at the spec section that carries it. A blank is a defect, exactly as §9b says.

**Ceremony found:** the "Laws served" header line. Here it claims "**Seventh** (the schema is the product; producers are adapters)" while the body drops Law 7's actual mechanism (kinds-and-outcomes-as-data, `design:147-150`). That is a hand-maintained mirror with no gate — the same shape as the ruling that demoted design §1's column 3. Amendment: each named law cites the section that delivers it, and the reviewer opens that section.

**Numbering:** the template jumps §8 → §12 with no §9-11 and no explanation. The spec faithfully reproduced the hole. Either explain the gap as an intentional ancestor artifact or renumber; an unexplained gap teaches every future author to leave one.

**Not ceremony, keep as-is:** §1's "the problem" (one paragraph, forced a real vigilance framing), §7, §12's open "pending" slot (the author correctly left it unfilled), and the 150-300 line calibration (this spec: 163).

---

## FINDINGS

### MAJOR

**M1 — Citation truth: §4 row 6 retires a string that exists in neither cited file.**
Spec `:90`: `| Both scripts' self-description as "the harness" | Land-Verdict.ps1:1, Verify-Verdict.ps1:1-8 |`.
`grep -c -i harness scripts/Land-Verdict.ps1 scripts/Verify-Verdict.ps1` → **`0`** and **`0`**. `grep -rn -i harness scripts/` matches only `scripts/canonicalise-demo.py:20`.
`Land-Verdict.ps1:1` reads `# Land-Verdict.ps1 -- extract a dispatched agent's verdict VERBATIM from the session`. `Verify-Verdict.ps1:1-8` describes itself as *"the checker"* (`:6`).
Inherited uncorrected from `design:257` ("headers call themselves 'the harness'"). This is the assignment's stated Major class: a car sent to delete text that is not there either invents a rename with no anchor or burns a dispatch on an honest stop. Aggravating: the framing the row wants to fix *does* exist — at `docs/setup.md:24` ("The harness design proposes retiring this directory…") — and that location is uncited.

**M2 — The retirement list misses the live mirrors, and the spec has no carrier for doc obligations.**
§4 row 5 retires `docs/reviews/` as a location and names exactly one dependent, `README.md:20-21`. Actually dependent:
- `docs/setup.md:24` — *"Landed verdicts | `docs/reviews/` | **Seven** design-review verdicts… until that lands, this is where verdicts live."*
- `docs/setup.md:23` — describes both scripts and their current behaviour.
- `.github/workflows/ci.yml:47` — `./scripts/Verify-Verdict.ps1` invoked bare, i.e. against `Verify-Verdict.ps1:24`'s default `[string]$ReviewsDir = 'docs/reviews'`.
- `README.md:46-47` — *"a conductor-maintained state file"*, which #7 removes (named at `design:254`, dropped here).
- `docs/friction-log.md:46` — cites `Verify-Verdict` running only on memory.
The design carried these as §8 rows with owners (Car 3, Car 2). The spec has no contracts-touched section at all, so a zero-context plan-writer working from the spec alone writes no documentation tasks. Under CLAUDE.md's same-commit doc law this is a defect in the deliverable.

**M3 — §4 rows 4 and 5 contradict each other, and the literal reading turns CI red permanently.**
Row 4: make the verifier *"fail when the expected store is empty"*. Row 5: empty `docs/reviews/` by migration. `Verify-Verdict.ps1:24` defaults to `docs/reviews`; `ci.yml:47` passes no argument.
Reading A: the verifier is repointed at the new store in the same commit — but "the expected store" is never named, and §3 hands the store's shape to an unnamed schema artifact.
Reading B: the default stands — the first commit after migration hits `Verify-Verdict.ps1:87-90` (directory present, zero files → `:94-96` `exit 0` today, `exit 1` after the fix) and CI is red forever.
The spec picks neither. A car implementing row 4 and a car implementing row 5 are the same car and it will ship one of these.

**M4 — §3 and §6 impose rendering requirements; §8 declares rendering out of scope.**
§8 `:147`: *"Rendering - that is the yard design's job (#1)."*
§3 `:70`: *"latest-`at` wins, **and the board renders that a supersession occurred**"*.
§6 `:116-119`: *"two `returned` records resolve to latest-`at` **with the supersession rendered**"*; *"spend absent **renders a dark lane**"*.
Reading A: these are board tests, so car scope includes board code that #1 owns and that does not exist at this base. Reading B: they test only that the fold *exposes* a supersession marker and a null spend, and #1 renders it. §6 is the section a car turns directly into test cells; it must not be readable both ways.

**M5 — §2's second filter is asserted as verified but depends on the spec's own open probe, and §6's fault-injection cannot produce its stated expected value.**
§2 `:43-48`: *"only real dispatches leave a persistent transcript: the subagents directory holds exactly 7 `.jsonl` files against 74 firings… A producer that filters on either is correct; filtering on both is belt-and-braces and costs one `Test-Path`."*
Three defects in one passage:
- **The "either" claim is falsified by §7 item 5** (`:137-138`, *"Does `agent_transcript_path` exist at the moment the hook fires, or only after the runner finishes writing it?"*). If the answer is "only after", a `Test-Path` filter rejects **every** real dispatch and the store stays empty. The spec asserts as verified architecture a claim its own probe list marks unresolved — the 7-files observation is a post-hoc directory listing, made at a different moment than the one the producer runs in.
- **The choice is left to the car.** "Either is correct… both is belt-and-braces" is not a requirement; it is a menu. A car sees only its own task and will pick one.
- **The fault-injection is arithmetically unachievable, and vacuous under the endorsed reading.** §6 `:122-123`: *"remove the `agent_type` filter and confirm the store floods (74 artifacts, not 7)."* Under belt-and-braces the `Test-Path` filter still holds and the store does **not** flood — the guard passes, which is `ci.yml:17-18`'s "green light wired to nothing". And the denominators are mixed: amendment A1 (`design:329-331`) records **4** car-typed firings inside the 74-firing probe window; **7** is the lifetime transcript count. "74, not 7" compares a windowed count to a lifetime count. Honest expectation for that window is 74 vs 4.

**M6 — Adopted design requirements are silently dropped (class: no fidelity ledger, per the workflow verdict).** Instances, each opened:
- **The liveness gradient.** `design:156-159` requires a per-dispatch **budget**, a **shop default** so *"absent never means infinite"*, and **overdue rendered with elapsed and budget shown BEFORE unaccounted-for — "a gradient, not a cliff, so a mis-set budget degrades visibly."* The spec mentions none of the three; §6 `:117` jumps straight from "past budget" to "derives unaccounted-for". A car building from the spec alone builds the cliff the design rejected and has no source for the budget value.
- **The envelope, and with it the core mechanism.** `design:223-224` distinguishes `envelope: absent` (**a brief failure**) from `envelope: malformed` (**a producer failure** — *"a different fault"*); `design:255-256` assigns envelope duties to `CLAUDE.md`, `docs/templates/car-brief.md`, `.claude/agents/car.md`, `/goodnight` (Car 2). `grep -rl envelope --include=*.md` outside `docs/reviews/` returns only the two design docs, `friction-log.md` and `design-briefs.md` — `car-brief.md` does **not** mandate one today, so the work is real and outstanding. The spec never mentions the envelope, and consequently **never says how the producer turns `agent_transcript_path` into an outcome** — the exact job `Land-Verdict.ps1:78-115` performs today and which §4 row 2 retires. That is the feature's central mechanism, and no document specifies it.
- **The concurrency rule, demoted to an unknown.** `design:230`: *"the producer writes its own path only and never `git commit -a`; a contended commit retries, and a failed write is **raised, never dropped silently**"* (Law 4). The spec carries neither the rule nor the raise-never-drop obligation, and §7 item 3 reopens it as *"Unknown"*.
- **Law 7's actual mechanism.** `design:147-150`: kind and outcome vocabularies **ship as data**; an unrecognised value *"renders loudly by name and is treated as a discovery, not a bug"*; `design:228` requires an unreadable vocabulary to be **one** board-level fault, not N per-lane faults. §3 `:68` lists the kind vocabulary as prose owned by the spec, with no data-shipping requirement and no unknown-value behaviour — while the header `:9-10` claims Law Seven is served.
- **P6.** `design:84-86` makes context **producer-optional** (round 5 Minor 7, adopted). §3 `:75-76` gives the dark-lane treatment to spend only.
- **Ruling Q2.** `design:232`, `design:290`: an un-backfilled gap is *"rendered as a first-class board state - visible debt, permanently, until filled."* Not carried.

**M7 — §5's lifecycle table is wrong about the index; a wrong lifecycle section is worse than a missing one.**
§5 `:102`: `| Index generator | none | Reads artifacts, writes INDEX.md, exits. |`. §4 row 5 `:89` makes `INDEX.md` a **committed file created in the migration commit**. A generated file committed to git that no gate regenerates-and-diffs is a second copy that can drift — Law 6 (`constitution.md:45-50`, *"never maintains a second copy of anything that can drift"*) and precisely the hand-maintained-mirror class CLAUDE.md's sentence-check scar names. The *generator* is stateless; the *artifact* is derived state whose freshness nothing owns. The spec never says when the index regenerates, who regenerates it, or what fails when it is stale. The store-is-git's-lifecycle paragraph (`:109-110`) is honest and correct about the append-only records; it does not cover a derived file.

**M8 — §3 hands the record grain to the schema artifact, against design P2 and against the spec's own title.**
§3 `:63`: *"Owned by the schema artifact, NOT by this spec: field names and types, **the record grain**, the index format…"*. But `design:70-72` **P2**: *"A dispatch is the unit of record. Not a turn, not a train. If false: the schema's grain is wrong and the board's derivation changes shape."* And `design:141-142` enumerates what the schema owns — *"Field lists, types, ordering and identity"* — grain is not among them; it is a behavioural premise the design fixed.
Compounding: the title `:3` says *"One Artifact Per Dispatch"* while §6 `:114-115` requires **two** records for one dispatch. `design:137` says *"One record per dispatch **event**"* — the spec's title drops "event". Reading A (one artifact per dispatch) requires mutation, which D3 (`design:126`) forbids. Reading B is per-event. The document supports both and then delegates the choice downstream.

### MINOR

- **m1 — §2 generalises an async-scoped observation.** `:40` states unconditionally that `PostToolUse:Task` *"Fires at launch with `status: async_launched`, no body"*, citing round1`:66` (exact — verified). But the evidence at round1`:74` is a payload reading `'isAsync': True, 'status': 'async_launched'`. Neither document states "every dispatch this project makes is async" as a premise, nor lists synchronous dispatch as a probe. Under a synchronous `Task`, `dispatched` and `returned` would land in the same breath and tier 1 goes vacuous — the exact defect `design:106-109` exists to prevent. Minimum remedy: a stated premise or probe item 6. (Held at Minor because the spec faithfully carries a prior adversarial finding; I cannot verify vendor sync behaviour from this desk.)
- **m2 — "git-root derivation" is an under-specified replacement.** §4 row 1 retires `Land-Verdict.ps1:59` (`Join-Path $env:USERPROFILE '.claude\projects\C--Users-Chris-git-starcar'`). `git rev-parse --show-toplevel` yields a filesystem path; the target directory name is a *mangling* of that path, and the mangling rule is undeclared. It also breaks in a detached worktree, whose toplevel differs from the primary checkout — the review worktree this verdict was written in is a live example.
- **m3 — Rows 2 and 3 of §4 interact unresolved.** Row 2 deletes the extraction engine (`Land-Verdict.ps1:78-115`); row 3 keeps the CLI *"only for backfill"*. A backfill happens precisely when no hook fired, so there is no payload `agent_transcript_path`. Two readings: the CLI takes an explicit transcript path, or backfill becomes hand-authored. Neither stated.
- **m4 — §3 disclaims field names then names one.** `:63` gives field names to the schema artifact; `:75` says *"Spend renders only from `cost`"*.
- **m5 — Tier 2's CI reachability is dropped.** `design:196` calls the checkpoint branch *"pushed and CI-readable"*; round 5 Minor 3 (`design:282`) recorded that CI cannot fetch it, assigned to car 3. `ci.yml:32` is a bare `actions/checkout@v4` with no ref fetch. §2 `:57-58` names the source with no fetch obligation.
- **m6 — "subject" and "dispatch" are used interchangeably** (§3 `:69` "one dispatch", `:73` "a subject"; §6 `:115` "one subject") without saying they are the same key. Held at Minor because `design:141` explicitly assigns *identity* to the schema artifact.
- **m7 — §12 omits the design's own §9b disposition discipline**, which is the mechanism that would have caught M6.

### RULINGS (on what the spec leaves open)

1. **Grain (M8):** the grain is **one record per dispatch *event***, fixed by P2 and `design:137`. It is behavioural and belongs in §3, not the schema artifact. Retitle the spec to "One Artifact Per Dispatch Event".
2. **Filters (M5):** filter on **`agent_type` only**, unconditionally. The transcript-existence test may be added *after* probe 5 returns positive, and never as the sole filter. §6's fault-injection expectation becomes **74 vs 4** for the probe window, stated as a window.
3. **Rendering (M4):** rendering is out of scope per §8. §3 and §6 must say *"the fold exposes a supersession marker"* and *"the fold reports spend as absent"*; the visual assertions belong to #1.
4. **Verifier target (M3):** the verifier is repointed at the new store **in the migration commit**, and `ci.yml:47` is updated in the same commit. Say so in row 4.
5. **Probe 3 (M6):** delete it. `design:230` already ruled it; carry the ruling into §3 instead.
6. **Index (M7):** the index is regenerated by a gate that regenerates-and-diffs in CI, or it is not committed. Pick one in §5.

---

## CONSTITUTION CHECK

1. **Truth** — FINDING (M5): §2 states as verified architecture a transcript-existence property whose timing §7.5 marks unresolved; a spec that asserts what it cannot back is the document-rung form of a confident falsehood.
2. **The Dispatcher Commands** — honored: §3 `:73-74` carries the later-`intent`-supersedes mechanism, the override path `design:180-181` demanded.
3. **Actionability** — honored: 163 lines, no decorative section; every section produced at least one finding, which is the document-rung test of earning its pixels.
4. **Nothing Silently Lost** — FINDING (M6): `design:230`'s *"a failed write is raised, never dropped silently"* is dropped, and dropping the guarantee against silent loss is the Law 4 defect in miniature.
5. **Self-Knowledge** — partially honored: §7 is an honest five-item ignorance list (real work); undercut by probe 3 restating a settled ruling, which makes the list read as less certain than the corpus actually is.
6. **One Truth** — FINDING (M7): `INDEX.md` is a committed derived copy of the store with no regeneration gate — a second copy that can drift.
7. **The Stranger** — FINDING (M6/Law 7 instance): the header claims Law Seven served while `design:147-150`'s kinds-and-outcomes-as-data requirement is absent, leaving a plan-writer to hardcode the taxonomy Law 7 forbids.
8. **Growth** — honored: §12 records all five design rounds with Major counts, and I verified the claim empirically — `./scripts/Verify-Verdict.ps1` reports **7 verdict files, every body matches its claimed hash, exit 0**.

---

## WHAT IS GOOD, AND WHERE MY ASSIGNED ATTACKS FAILED

**Attack A (citation truth) largely FAILED, and I should say so plainly.** I opened every citation in the document. Nine of ten hold exactly:
- `Land-Verdict.ps1:39-51` — exactly seven `[Parameter(Mandatory)]` params (`TaskId, Out, Title, Gate, Target, Base, Verdict`), `:39` is `param(`, `:51` is `)`. Exact.
- `Land-Verdict.ps1:59` — the hardcoded project directory. Exact.
- `Land-Verdict.ps1:78-115` — `Get-ResultBlockForTask`, function head to `return`. Exact.
- `Land-Verdict.ps1:112-115` — the quoted supersession comment sits at `:113-114`, inside the range. Exact.
- `Verify-Verdict.ps1:87-96` — covers **both** vacuous exits (`:87-90` directory absent, `:94-96` zero files). Exact, and the "**or holds no files**" emphasis is the sharper half that `design:257` states only loosely.
- `ci.yml:47` — bare invocation. `ci.yml:62` — `if ($result.PassedCount -eq 0)`, the zero-test refusal. Both exact.
- `README.md:20-21` — *"the review verdicts and REJECT records committed in-repo as they happen"*. Exact quote.
- `docs/reviews/2026-07-22-harness-design-round1-REJECT.md:66` — lands on the MAJOR-1 heading **to the line**. Exact.
Only §4 row 6 failed, and it failed because it was inherited from the design rather than opened. The author's claim to have verified citations is substantially true.

**Attack E partially FAILED.** The "no mutable service state" claim is *correct* for all three processes, and the closing paragraph (`:109-110`) — the store is durable, its lifecycle is git's — is honest, well-reasoned, and better than the design's own framing at `design:251` ("the artifact store is new mutable state"). Only `INDEX.md` breaks it.

**Attack G partially FAILED.** Probes 1, 4 and 5 are genuinely desk-unanswerable; item 5 is the sharpest thing in the document and it falsified a sibling section. Only item 3 is a demoted ruling.

**Other genuine strengths:** the spec corrects the design's stale "six landed verdicts" (`design:239`) to seven, which matches the seven files I listed and verified. §5's honest-stop instruction (`:106-107`) puts truth on the success branch exactly as CLAUDE.md requires. The `§2` observation that the second filter "costs one `Test-Path`" is the right *kind* of engineering reasoning even though the conclusion is unsafe. And §12's refusal to pre-fill the spec-review slot is correct discipline.

---

## SPLIT, AND WHETHER ANOTHER ROUND IS WARRANTED

**Must close in the spec (rev 2):** M1, M2, M4, M5, M6, M8 — all are document-rung defects that a plan cannot repair without inventing content, and M2/M6 are missing-requirement classes that a plan-writer cannot know to look for.
**Safe to carry to plan or car:** M3 (a plan can rule it, though it is three words to fix now), M7 (the *gate choice* is plan work; the **wrong §5 row must be corrected in the spec**), all Minors except m1 (which needs at minimum a probe-list line before car 2).

**Another round IS warranted, but a bounded one — rev 2 plus a round-2 review, not a rewrite.** The remedy is small and mechanical: a fidelity ledger table, a contracts-touched section, one deleted retirement row, three sentences on rendering scope, one corrected fault-injection expectation, and one corrected lifecycle row. That is the same shape as the design's round-5 disposition. The document's architecture is sound; its defects are omissions and one inherited citation, not structure. Per this repo's rewrite-vs-extend rule, this is a coverage defect: **extend with a rider, do not rewrite.**

---

```starcar-artifact
outcome: REJECT
findings: 8 Major, 7 Minor, 6 rulings issued
abstract: |
  Spec review round 1 of docs/specs/2026-07-22-dispatch-harness-spec.md at base
  7e49d43dcc923d923260302dd64d8f89166380d7. Read-only; no fault injection performed;
  worktree clean and byte-identical before and after. Verify-Verdict.ps1 run read-only:
  7 files, all hashes match, exit 0.

  Eight Majors. M1 citation truth - section 4 row 6 retires a self-description as "the
  harness" citing Land-Verdict.ps1 line 1 and Verify-Verdict.ps1 lines 1-8; the string
  appears zero times in either file (grep count 0 and 0), inherited uncorrected from
  design line 257. M2 the retirement list names one dependent of docs/reviews and misses
  four - setup.md lines 23 and 24, ci.yml line 47 against Verify-Verdict.ps1 line 24's
  default, README lines 46-47, friction-log line 46 - and the spec has no contracts
  touched section at all, so nine documentation obligations the design carried evaporate.
  M3 section 4 rows 4 and 5 contradict - the verifier must fail on an empty store while
  the same train empties docs/reviews, and the literal reading turns CI red permanently.
  M4 sections 3 and 6 impose rendering requirements that section 8 declares out of scope.
  M5 section 2's transcript-existence filter is asserted as verified but depends on the
  spec's own unresolved probe 5, the one-or-both filter choice is left to the car, and
  section 6's fault-injection expectation of 74 versus 7 mixes a lifetime count with a
  probe-window count where the design records 4, and is vacuous under the belt-and-braces
  producer the same section endorses. M6 five adopted design requirements dropped - the
  liveness gradient with budget and shop default, the envelope and with it how a returned
  record obtains its outcome, the concurrency write rule demoted to a probe, Law 7's
  kinds-as-data mechanism, premise P6, and ruling Q2. M7 the lifecycle table is wrong
  about INDEX.md, a committed derived file with no regeneration gate, which is a second
  copy that can drift. M8 section 3 hands the record grain to the schema artifact against
  premise P2, and the title says one artifact per dispatch while section 6 requires two.

  Attack A largely failed - nine of ten citations opened exact, including the round1
  review line 66 which lands on its heading to the line. Attack E partially failed - the
  no-state claim is correct for all three processes and the store-under-git paragraph is
  honest. Attack G partially failed - probes 1, 4 and 5 are genuinely desk-unanswerable
  and probe 5 falsified a sibling section.

  Workflow verdict on the worked-spec exemplar: the retirement list, lifecycle section
  and probe list all did real work and are not ceremony; the probe list caught a defect
  in a sibling section, the strongest evidence available. Two structural holes in the
  template caused two of the Majors - it has no contracts-touched section, and no
  fidelity ledger of the kind design section 9b proved out. Amend both, add spec-time
  caller enumeration to the retirement list, require derived and committed artifacts in
  the lifecycle table, forbid probes that restate settled rulings, gate the laws-served
  header against the sections that deliver each law, and explain or close the section
  8 to 12 numbering gap.

  Recommendation: bounded rev 2 plus a round 2 review, not a rewrite. The architecture is
  sound; the defects are omissions plus one inherited citation. Coverage defect, extend
  with a rider.
```