<!-- starcar-integrity: sha256=12989f4d50016420a88fa7824ed51530ded702ed88e8c65876bf5a6b3c1b52e6 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car adapters-49 review - round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial doc sentence-check review
Round: 1
Target: `commit ffd1a27 on car/adapters-49 (#49, carried finding CR-3)`
Base reviewed: `ffd1a2785f37f9251a2d4c3342919f72b1cd649b`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `ae2db65a15d4b58a2`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `ffd1a2785f37f9251a2d4c3342919f72b1cd649b` |

| Dispatch, the locator within the session | `ae2db65a15d4b58a2` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain ffd1a2785f37f9251a2d4c3342919f72b1cd649b
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Base verified, all traces run, both suites run. Verdict below.

---

# REVIEW VERDICT: **APPROVE**

**Task:** adapters-49-car-r1 (#49, carried finding CR-3) | **Commit reviewed:** `ffd1a2785f37f9251a2d4c3342919f72b1cd649b` | **Worktree:** `<repo>-wt\review-adapters-49` (detached HEAD, clean, verified FIRST)

**Findings: 0 Major, 1 Minor, 2 Nits, 1 out-of-scope observation, 1 disproved suspicion.** No Major, so no REJECT.

**Diff verified exactly as claimed:** `git diff --name-status ffd1a27^ ffd1a27` = one file, `M schema/vectors/adapter/README.md`; `--stat` = 7 insertions, 1 deletion. Hunk header `@@ -94 +94,7 @@` confirms the `Status: Current` line (README.md:3) is untouched. Added lines carry no em dashes; the only non-ASCII byte added is `§` (U+00A7), correctly UTF-8 encoded (`file` reports UTF-8, renders intact at README.md:99).

---

## Suites, run by me at `ffd1a27` (not read from the report)

| Suite | Observed | Car's claim (per brief) |
|---|---|---|
| `scripts/tests` (Pester 5.8.0) | **182 discovered, 181 passed, 1 skipped, 0 failed**, 33.36s | "182/182" |
| `scripts/store-checks` | **166 passed, 0 failed, 0 skipped**, 2.57s | 166/166 - **matches** |
| `DocPolicy.Tests.ps1` (inside scripts/tests) | **2/2 passed** | passes |

**Store-check expectation derived independently, not taken from the brief:** `find artifacts -name '*.json' | wc -l` = **161** record files; `StoreIntegrity.Tests.ps1:81` is one data-driven `It` per record, plus 5 fixed `It`s (`:87` fault injection, `:121`/`:139`/`:154` manifest layer, `:175` offset-form guard). 161 + 5 = **166**. Exact match to observation.

**The 1 skip is environmental and by design, not a defect:** `SessionStartGuardRunner.Tests.ps1` skips "prints `[ci-baseline]`'s marker ONLY when attached to a branch" with reason *"detached HEAD (no branch) - session-start-ci-baseline.sh is silent by design here."* `git branch --show-current` returns empty and `git rev-parse --abbrev-ref HEAD` returns `HEAD`: the worktree is detached, so the skip is correct.

**Base run not repeated, and here is why that is sound rather than lazy:** the only changed file is `schema/vectors/adapter/README.md`, and `git grep -ln` across `scripts/` and `.github/` shows it is referenced by exactly two files, both in **comments only** (`scripts/tests/AdapterVectors.Tests.ps1:7,19`; `scripts/tests/Producer.Tests.ps1:319`) - no test reads or asserts its content. The base counts are necessarily identical to HEAD's.

**Count reconciliation, flagged for the conductor:** if the car's report states "182/182 **passed**," that is imprecise against the verification-honesty coordinates rule - the honest form is 182 discovered / 181 passed / 1 skipped (environmental). I cannot see the car's report text from the commit, so I state my observed figure rather than confirming or accusing.

---

## The doc sentence check: every claim traced, hop by hop

The new sentence (`schema/vectors/adapter/README.md:94-100`) makes four technical claims plus one carrier tag. All five resolve.

### Trace A - "the producer's envelope-resolution code (`Get-LastAssistantText`/`Get-StarcarEnvelope` deriving `subject`/`task_id` from a fenced `task-id`)" - **TRUE**

1. Prose: `schema/vectors/adapter/README.md:94-96`.
2. `Get-LastAssistantText` exists: `scripts/Envelope.psm1:29`, exported `:159`.
3. `Get-StarcarEnvelope` exists: `scripts/Envelope.psm1:86`, exported `:159`.
4. Fenced-`task-id` derivation is real: fence regex `scripts/Envelope.psm1:112` (`^[ \t]*```starcar-artifact`), field parse `:127` (`^(task-id|outcome|findings|abstract):`), `$taskId` assigned `:138`, surfaced as `TaskId` `:154` - and non-required by design `:143-147`.
5. The producer's **returned** path calls both: `scripts/Produce-Artifact.ps1:217` (`Get-LastAssistantText`), `:237` (`Get-StarcarEnvelope`).
6. `task_id` derived: `Produce-Artifact.ps1:243` (`$taskId = $env.TaskId`) then written `:358`.
7. `subject` derived from that same task-id, for this exact runtime/kind pair: `Produce-Artifact.ps1:259-263` (`if ($runtime -eq 'copilot' -and [string]::IsNullOrWhiteSpace($subject)) { ... $subject = $taskId }`), written `:337`.
8. Behavior observed, not inferred: `AdapterVectors.Tests.ps1` case `conforms: copilot-stop-envelope-taskid` **passed** in my run, and the vector asserts `subject: "51-car-r1"` equal to `task_id: "51-car-r1"`.

### Trace B - "exercised against a Claude-format transcript fixture wrapped in a Copilot-shaped payload" - **TRUE**

1. Payload wrapper is Copilot-shaped: `schema/vectors/adapter/copilot-stop-envelope-taskid.json:9-12` carries `agent_name` + snake_case `transcript_path`, with **no** `agent_type` and **no** `agent_id`.
2. That is precisely the shape the producer's Copilot branch recognises: `Produce-Artifact.ps1:162` (`agent_name` reads as the Copilot compat stop key) leading to `:166-172` (`runtime = 'copilot'`, `subject = $null`), and `:213` (the `transcript_path` fallback after `agent_transcript_path` misses).
3. Transcript lines are Claude-jsonl-shaped: same vector `:15-16`, `{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":...}]}}`.
4. That is exactly the shape `Get-LastAssistantText` consumes: `scripts/Envelope.psm1:57-58` (`message.role -eq 'assistant'`) and `:69-72` (`content[].type -eq 'text'`).
5. It is shape-identical to the in-repo OBSERVED Claude fixture `scripts/tests/fixtures/payloads/transcript-car.jsonl:2,4` and to the Claude vector `schema/vectors/adapter/claude-stop-envelope-taskid.json:11-12`. So "Claude-format... wrapped in a Copilot-shaped payload" is literally accurate on both halves.

### Trace C - "a real Copilot background stop's `transcript_path` points at the parent's `events.jsonl`, not a per-agent Claude-format transcript (§3b-6/3b-7)" - **TRUE** (see MINOR-1 on completeness)

1. Prose: README.md:97-99.
2. **§3b-7 resolves and says exactly this**, verbatim at `docs/design/2026-07-24-dual-runtime-harness-design.md:97-100`: *"**`transcript_path` at stop points at the PARENT's events.jsonl**, not a per-agent file (probe-log entries; ...)"*. It is item 7 of the §3b numbered list, so the `§3b-7` reference resolves correctly.
3. **§3b-6 resolves** at the same doc `:91-96`: *"For background dispatches, the report is NOT in the parent transcript at stop time... An extraction-at-stop returns nothing by construction for background agents."*
4. Doc status checked as the brief required: `:3` `Status: Superseded`, `:4` RETIRED by owner arbitration. Both cited items are OBSERVED probe facts (probe-log evidence named inline), so they remain valid evidence despite the doc's retirement, and the section numbering still resolves.
5. **Not contradicted by the live design**: `docs/design/2026-07-24-family-agnostic-harness-design.md:122` (D5) explicitly carries the superseded design's uncontested decisions forward and drops only the events.jsonl **identity join**, not these payload observations; `:218` (DR-7) keeps the enrichment path's live-file read as a live concern. No live-design line contradicts §3b-6 or §3b-7.

### Trace D - "the real Copilot envelope round-trip always flows through the events.jsonl branch this note already defers below" - **TRUE**

1. **The cross-reference is true**: the note below does defer that branch - `README.md:103-106`, *"That events.jsonl extraction branch is NOT pinned by a vector here... It is deferred as named work, not silently skipped."* The sentence's own pointer resolves.
2. **No events.jsonl format branch exists in the one-home reader today**, re-derived independently of the car: I read all 64 lines of `scripts/lib/TranscriptRead.ps1`. It contains exactly two functions, `Read-TranscriptLines:20` and `Read-JsonlObjects:41`, neither of which detects or interprets a record shape; `:15-18` states outright that *"interpreting an events.jsonl's per-runtime record SHAPE is deliberately out of scope here."* The car's claim reproduces.
3. **And none exists anywhere else**: `git grep -n "execution_start|execution_complete|subagent.started|TranscriptFormat|copilot-events" -- scripts/` returns **zero hits**. The deferral is real repo-wide, not just in one file.
4. **Why "always" holds**: the branch's design definition names both call sites - superseded design `:126` (D5), *"`Get-LastAssistantText` grows an events.jsonl format branch... Call sites: (a) the D4 stop-path, (b) `Land-Verdict.ps1`, which gains a `-TranscriptFormat copilot-events` path calling the SAME function."* Stop-time extraction and later backfill both read events.jsonl through that one branch, so the universal quantifier is supported rather than rhetorical.
5. **What a real Copilot stop does today, traced end to end** (confirming the branch is genuinely required and the README is not describing something that exists): `Envelope.psm1:79-81` finds no assistant message and returns one error, `Produce-Artifact.ps1:222-235` classifies that as a transcript read failure (outcome `error`), then `:259-262` throws *"Copilot returned payload carries no envelope task-id to pair on"* - exit 1, fault logged, **no record**. The sentence claims no working real path, and none exists.

### Trace E - the `[CR-3]` tag - **REAL and faithfully applied**

`artifacts/reviews/2026-07-24-family-agnostic-car-review-round2-APPROVE.md:76` carries the heading *"CR-3 (NEW - MINOR, carried, non-blocking) - README overstates real-runtime coverage of the Copilot stop-with-envelope path"*; `:77` states the evidence and quotes §3b-6 and §3b-7; `:84` prescribes the fix: *"clarify that the vector pins the producer's envelope-resolution code given a readable Claude-format transcript, and that for a real Copilot background stop the envelope arrives via events.jsonl (§3b-6/7)."* The landed sentence covers **both** clauses. The tag is folded INLINE at the exact spot with its ID, which is the carrier rule's required form rather than a "feedback incorporated" gesture.

---

## Cross-document staleness sweep (the "did this diff leave a lying canary" test)

`git grep -n "now pinned|with-envelope|stop path" -- . ':!artifacts/'` returns the overstatement in exactly one place: `README.md:91-92`, the sentence this diff qualifies. The one other document making a claim about this surface is **`docs/setup.md:86-88`**, which already reads *"The stop-path/`events.jsonl` INTAKE for Copilot is proven for `post-task` only; the SubagentStop-side compat shape for a Copilot stop remains an honest boundary (its OBSERVED payload is not in-repo - see `schema/vectors/adapter/README.md`)."* The new sentence brings the README **into** alignment with setup.md, which was already the more honest of the two, and setup.md's pointer at this README now lands on a page that agrees with it. **No document is invalidated or left stale by `ffd1a27`.**

---

## Findings

### MINOR-1 (non-blocking) - §3b-6 is cited but not rendered; a plan-writer can under-read the timing problem
`schema/vectors/adapter/README.md:97-100` cites `§3b-6/3b-7` and then renders only §3b-7's fact (the path points at events.jsonl). §3b-6's fact - `docs/design/2026-07-24-dual-runtime-harness-design.md:91-96`, *"an extraction-at-stop returns nothing by construction for background agents"* - is the stronger half of CR-3's own evidence (quoted at `artifacts/reviews/2026-07-24-family-agnostic-car-review-round2-APPROVE.md:77`) and does not appear. Consequence: "flows through the events.jsonl branch" is readable as *build the format branch and the real stop path works*, when §3b-6 says stop-time extraction returns nothing by construction and the envelope can only arrive through the second call site (superseded design `:126`, Land-Verdict backfill). Nothing on the page is false - both call sites do read events.jsonl - so this is completeness, not truth. **Not Major**: no claim is wrong, no document is left stale, and the diff strictly increases honesty over its base. Suggested one-clause addition at a future revisit: note that the report is not in events.jsonl at stop time at all, so the envelope arrives via the backfill call site.

### NIT-1 - `§3b-6/3b-7` names no document inside the sentence
`README.md:99`. The referent is established two lines later at `:102` ("the superseded design's ... §3b-8") and in the provenance table at `:67`/`:70`, so a careful reader resolves it; a cold stranger reading only the scope note does not. The commit message does name the document in full.

### NIT-2 - the parenthetical slightly over-attributes `subject` derivation
`README.md:95-96` reads as if `Get-LastAssistantText`/`Get-StarcarEnvelope` derive `subject`. `Get-StarcarEnvelope` yields only `TaskId` (`scripts/Envelope.psm1:154`); the `subject` assignment happens in the producer at `Produce-Artifact.ps1:263`. The head noun "the producer's envelope-resolution code" fairly covers both, which is why this is a nit and not a finding.

### OBSERVATION (out of scope for this commit; for the conductor, likely a ticket)
`docs/design/2026-07-24-family-agnostic-harness-design.md:147` lists *"`scripts/lib/TranscriptRead.ps1` (D5): the one extractor, **events.jsonl branch**, consumed by producer and `Land-Verdict.ps1`"* - reading as if the branch exists. It does not: `scripts/lib/TranscriptRead.ps1:15-18` disclaims the events parse and my repo-wide grep found zero implementation. This staleness predates `ffd1a27` (present at `42e3eae`) and is **not** introduced by this car, so it is not a finding against this diff - but the live design and this README now say opposite things about the same file, which is exactly the lying-canary class.

### DISPROVED SUSPICION (stated because a premise check that comes back negative is worth the record)
I suspected the pre-existing `README.md:100-103` (the events.jsonl `toolCallId -&gt; arguments.name` join as "the enrichment path") was stale against the live design's D5, which at `:122` **drops** "the events.jsonl three-hop identity join." Opening both: the README attributes it to *"the superseded design's"* join and calls it the **enrichment** path, while D5 drops it only as an **identity** mechanism and DR-7 (`:218`) explicitly keeps *"the extractor's enrichment path still reads a live file."* Consistent. **Not a finding.** The brief's framing was likewise tested rather than assumed: CR-3 exists and says what the brief reported (`:76-84`), the diff is what the brief described, and the car's TranscriptRead claim reproduced under my own re-derivation.

---

## Constitution check

- **Law 1 (truth on every surface):** honored. The diff's entire purpose is removing an overstatement, and every claim it substitutes traces to code or to an OBSERVED probe fact - traces A through E, each hop with file:line.
- **Law 4 (nothing silently lost):** honored. CR-3 crosses the rung by carrier, folded inline with its ID at `README.md:94`, not summarised as "feedback incorporated."
- **Law 6 (no second copies):** honored. The clarification cross-references the deferral at `README.md:103-106` rather than restating it, and names the one-home reader path instead of duplicating the vector description's provenance prose.
- **Law 7 (the stranger):** honored with NIT-1 outstanding. A stranger following the sentence reaches real code and a real design section; only the unnamed document in `§3b-6/3b-7` costs them a lookup.
- **Documentation ranks equal to code / living contracts:** honored. I swept every repo document making a claim on this surface; `docs/setup.md:86-88` already agreed and now agrees more closely. Nothing was invalidated and left behind.
- **Code standard, `#N` citation:** satisfied in the proportionate form. The commit body carries `#49`; the doc line carries its carrier ID `[CR-3]`. No code file was added, so the rule's code branch is not engaged.
- **TDD:** not engaged, correctly. No behavior change, and no test reads this file (verified: comment-only references at `AdapterVectors.Tests.ps1:7,19` and `Producer.Tests.ps1:319`). That leaves the claim attention-tier, which is the downgrade the North Star already records and accepts for user-facing docs pending CI.
- **Cars commit locally, never push:** honored. One local commit, `git status` clean, detached HEAD at `ffd1a27`, nothing pushed.

**Reviewer discipline:** I edited nothing, committed nothing, pushed nothing. All suite runs used the worktree in place; the store-checks suite builds its own temp repos.

**Relevant absolute paths:** `<repo>-wt\review-adapters-49\schema\vectors\adapter\README.md`, `...\schema\vectors\adapter\copilot-stop-envelope-taskid.json`, `...\scripts\Envelope.psm1`, `...\scripts\Produce-Artifact.ps1`, `...\scripts\lib\TranscriptRead.ps1`, `...\docs\design\2026-07-24-dual-runtime-harness-design.md`, `...\docs\design\2026-07-24-family-agnostic-harness-design.md`, `...\docs\setup.md`, `...\artifacts\reviews\2026-07-24-family-agnostic-car-review-round2-APPROVE.md`.

```starcar-artifact
task-id: adapters-49-review-r1
outcome: APPROVE
findings: 0 Major, 1 Minor, 2 Nits, 1 out-of-scope observation, 1 disproved suspicion. MINOR-1 (non-blocking): schema/vectors/adapter/README.md:97-100 cites 3b-6/3b-7 but renders only 3b-7's fact; 3b-6's "an extraction-at-stop returns nothing by construction for background agents" (docs/design/2026-07-24-dual-runtime-harness-design.md:91-96) is CR-3's stronger evidence and is absent, so a plan-writer can under-read the timing problem. Nothing false, nothing stale, so not Major. NIT-1: the section reference names no document inside the sentence (referent established at README:102 and the table at :67/:70). NIT-2: the parenthetical reads as if Get-StarcarEnvelope derives subject; it yields only TaskId (Envelope.psm1:154), the subject assignment is Produce-Artifact.ps1:263. OBSERVATION (pre-existing, not this diff, likely a ticket): docs/design/2026-07-24-family-agnostic-harness-design.md:147 lists TranscriptRead.ps1 as having an events.jsonl branch, which scripts/lib/TranscriptRead.ps1:15-18 disclaims and a repo-wide grep shows does not exist. DISPROVED: I suspected README:100-103's events.jsonl join was stale against live design D5 at :122; opening both showed the README attributes it to the superseded design and calls it the ENRICHMENT path, which D5 :122 and DR-7 :218 preserve. Not a finding.
abstract: Adversarial doc sentence-check of commit ffd1a27 (one file, schema/vectors/adapter/README.md, +7/-1, hunk at line 94, Status line untouched) against task #49 and carried finding CR-3. Base verified FIRST: worktree detached and clean at ffd1a2785f37f9251a2d4c3342919f72b1cd649b. All five of the new sentence's claims traced hop by hop to code or OBSERVED probe facts and all resolve. Get-LastAssistantText (Envelope.psm1:29) and Get-StarcarEnvelope (Envelope.psm1:86) exist, parse a fenced task-id (:112, :127, :138, :154), and the producer derives task_id at Produce-Artifact.ps1:243/:358 and subject at :259-263/:337. The vector's payload is Copilot-shaped (copilot-stop-envelope-taskid.json:9-12, matching the producer's agent_name branch at :162 and transcript_path fallback at :213) while its transcript lines are Claude-jsonl-shaped (:15-16, identical in shape to the OBSERVED in-repo fixture scripts/tests/fixtures/payloads/transcript-car.jsonl). Design sections 3b-6 and 3b-7 resolve verbatim at docs/design/2026-07-24-dual-runtime-harness-design.md:91-96 and :97-100, are OBSERVED probe facts on a Superseded doc, and are not contradicted by the live family-agnostic design (:122, :218). The deferral cross-reference is true (README:103-106) and the events.jsonl format branch genuinely does not exist: I read all 64 lines of scripts/lib/TranscriptRead.ps1 (two functions, no shape detection, :15-18 disclaims it) and a repo-wide grep for execution_start, execution_complete, subagent.started, TranscriptFormat, copilot-events across scripts/ returned zero hits. Today a real Copilot stop dies at Produce-Artifact.ps1:259-262 with no record, so the note describes no working path it does not have. CR-3 is real at artifacts/reviews/2026-07-24-family-agnostic-car-review-round2-APPROVE.md:76-84 and the landed sentence covers both clauses of its prescribed fix. Cross-document staleness sweep found nothing left stale: docs/setup.md:86-88 already called this an honest boundary and the diff moves the README toward it. Suites run by me at ffd1a27: scripts/tests 182 discovered, 181 passed, 1 skipped, 0 failed (the skip is the detached-HEAD ci-baseline conditional, by design; git rev-parse --abbrev-ref HEAD returns HEAD), DocPolicy 2/2; scripts/store-checks 166 passed, 0 failed, with the expectation independently derived as 161 store records times one data-driven It at StoreIntegrity.Tests.ps1:81 plus 5 fixed Its equals 166. Base run not repeated because no test reads the changed file, only two comment references. Flagged for the conductor: if the car reported 182/182 passed, the honest form is 181 passed plus 1 skipped. Constitution check run against Laws 1, 4, 6, 7, the documentation-equals-code rule, the code-standard citation rule, TDD applicability, and the cars-never-push rule; each honored with evidence. Reviewer edited nothing, committed nothing, pushed nothing.
```