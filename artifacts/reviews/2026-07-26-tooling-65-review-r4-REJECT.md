<!-- starcar-integrity: sha256=589c4ddad16c608253dcadc3cb9d31e5286148c8596851e5b3d347407efedae5 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Tooling train #65 citation-resolver gate review, round 4 (fresh reviewer, rotation)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial delta re-review, reviewer rotation at round 4
Round: 4
Target: `car/tooling-65 HEAD de9cda2 (owner-ruled amputation commit on 63a5c55)`
Base reviewed: `4f2ae978d4628c67ee049a5c874961837cbf564f`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `acf9a7451ccf63594`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `4f2ae978d4628c67ee049a5c874961837cbf564f` |

| Dispatch, the locator within the session | `acf9a7451ccf63594` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 4f2ae978d4628c67ee049a5c874961837cbf564f
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Review complete. Worktree byte-clean, nothing committed, nothing pushed.

---

# DELTA RE-REVIEW VERDICT — tooling train #65, round 4 (FRESH REVIEWER, rotation)

## VERDICT: **REJECT** — 2 Major, 2 Minor. **No new escalation; a narrow, mechanical fix list.**

**Base verified.** `git checkout --detach de9cda2` → HEAD `de9cda2b9b70c454cb433186cce42aa03eac4d0c`, on top of `63a5c55`, `4aea118`, `3d76e65`, base `4f2ae97 merge: view train #28+#12...`. Exactly as briefed. `git status --porcelain` empty at entry and exit; `git diff` = 0 lines. Shared checkout untouched.

---

## WHAT THE OWNER'S REMEDY ACHIEVED (recorded first, because it is real)

The amputation worked on its central target. The self-excluded, ungated prose surface went from ~360 header lines dense with measurement claims to **32 lines**, and I enumerated every coordinate-shaped string left in the file: **exactly one is a real citation** — `CodeCitationPolicy.Tests.ps1:288-308` at `scripts/tests/CitationResolverPolicy.Tests.ps1:346` — and I opened it: line 288 is the completeness `It`, line 308 is its closing brace. **True.** Every other coordinate string in the file is scratch-fixture content (`target.go:5`, `dup.md:999`, …).

Every r3 finding is genuinely closed, not relocated:

| r3 ID | Status | Evidence |
|---|---|---|
| **MAJOR-R3-1** ("would have flagged ALL THREE") | **ABSENT** | `grep -n "ALL THREE\|all three\|would have flagged\|3-for-3"` → zero hits. |
| **MAJOR-R3-2** (dead `Test-ContentAnchorHit` citation) | **ABSENT** | `grep -n "Test-ContentAnchorHit"` → zero hits. |
| **MINOR-R3-1** (`StalenessMs` occurrence miscount) | **ABSENT** | `grep -n "nowhere near"` → zero hits. |
| **MINOR-R3-2** (Describe overclaiming "3-for-3") | **ABSENT** | Renamed `'Content-anchor case-sensitivity fixture (#65)'` at :456. It asserts exactly three structural things (:478, :482, :486) about one synthetic fixture. **The name now matches what the fixture asserts.** |

Header digit audit, as the brief required: `#65` (:2), `2+ candidates` (:7), `20` (:16), and the r1/r2/r3 verdict filenames (:30-31). **The car's claim holds — no surviving measurement claims.** The three cited verdicts do not exist at `de9cda2` (car branch predates them) but **do exist on `dev`** (`git ls-tree dev artifacts/reviews/` → all three), so the pointer resolves at the merge target. Not a finding.

**No test logic changed.** I stripped comments and blank lines from both revisions and diffed: 570 → 567 lines, and **every difference is a string literal** — exemption reason texts, `Describe`/`It` names, and one `Set-ItResult -Because` message that collapsed 5 source lines to 2 (the −3). Zero assertions, zero control flow, zero helper bodies changed. Diff stat `63a5c55..de9cda2` = **1 file, 108 insertions / 556 deletions**, exactly as claimed.

---

## MAJOR FINDINGS

### MAJOR-R4-1 — The amputation cut a load-bearing RULE, not narrative: an undisclosed, author-invocable bypass makes the header's BINDING statement false

`scripts/tests/CitationResolverPolicy.Tests.ps1:4-6` states, unqualified:

```
# BINDING: every citation this gate finds - single-line, or line-wrapped across a
# mid-compound hyphen or a directory slash - must (a) resolve to a file that exists
# at HEAD and (b) cite a line within that file's line count.
```

It must not. Any citation whose citing line contains the case-insensitive substring **`historical coordinate`** is exempted from **both** binding checks. `grep -i "historical"` across header lines 1-32 returns **zero hits** — the marker appears nowhere in BINDING, nowhere in NOT CAUGHT, nowhere in SCOPE.

**This is a regression introduced by `de9cda2`.** At `63a5c55` the header documented it in full (r3 file, lines 219-227): *"HISTORICAL COORDINATE marker: a citing line (or any line spanned by a wrapped match) containing the literal, case-insensitive substring "historical coordinate" is exempt from the existence/range checks."* The amputation deleted it along with the narrative. The owner ruled the header keep *rules + pointers*; this is the single most consequential rule in the file — the only mechanism by which an author can silence the gate at will — and it was cut.

**FAULT INJECTION (mine), and the control proves it is not a quirk of my probe.** Appended two lines to `docs/friction-log.md`, identical dead-path shape, differing only in the marker phrase:

```
[-] every literal-path or uniquely-resolved-basename citation points at a file that exists at HEAD (Class A)
 Expected $null or empty, but got 'docs/friction-log.md:259 cites 'reviewer-probe-nonexistent.go:12' - NO SUCH FILE'.
 at ($violators -join "`n") | Should -BeNullOrEmpty, ...CitationResolverPolicy.Tests.ps1:389
```
```
[!] reports historical-coordinate-marked citations as exempt, by name, never silently is skipped, because
    informational, not a failure: 2 historical-coordinate citation(s) exempted -
    .claude/hooks/run-session-start-guards.sh:51 -&gt; 'session-start-record.sh:76';
    docs/friction-log.md:260 -&gt; 'reviewer-probe-alsogone.go:34'
```

Probe A reds by name. **Probe B — a citation to a file that has never existed — passes, exempted by a phrase in prose.** Result 27/1/4/32; without probe A the run would have been green. `docs/friction-log.md` sha256 `7FC915C92C0218B3199B02EC8462A5B2BC23948CAEF7293297415CD177BD32A4` **before and after — identical**; `git status --porcelain` empty.

**THE SENTENCE CHECK, and it breaks at hop 2 — a break this commit created:**

| Hop | Location | What it says |
|---|---|---|
| 1 | `.claude/hooks/run-session-start-guards.sh:51-53` | "historical coordinate, the file no longer exists; **#65's CitationResolverPolicy gate exempts it by this marker** rather than flagging a dead path" |
| 2 | `scripts/tests/CitationResolverPolicy.Tests.ps1:1-32` | **NOTHING.** The header the hook points at no longer says what "this marker" is, what phrase triggers it, or that it exists. |
| 3 | same file :243-254 | `Test-HistoricalCoordinateMarker`; regex `'(?i)historical coordinate'` at :253 |
| 4 | same file :322-324 | `if (Test-HistoricalCoordinateMarker ...) { $script:Historical += $c; continue }` — `continue` skips both binding checks (:385, :392) |
| 5 | observed | probe B above |

This train's own diff **uses** the bypass — the gate at HEAD reports exactly one exempted citation, and it is the one `de9cda2`'s parent added. The header now claims a guarantee the train itself does not honor. **Law 1.**

**Fix:** restore one paragraph to SCOPE naming the marker, its exact trigger phrase, that it exempts both binding checks, and that it is reported by name. Roughly five lines. It is a rule, so it belongs in a rules-only header.

### MAJOR-R4-2 — Three landed documents credit round 2 with round 1's catches; false on the review record itself, in the cumulative diff being merged

| Document | Claim |
|---|---|
| `docs/contracts/gating-matrix.md:49` | "caught by **#65's round-2 reviewer**, not by the gate itself" |
| `docs/design/2026-07-22-dispatch-harness-design.md:97` | "caught by **#65's round-2 reviewer**, not by the gate" |
| `docs/setup.md:42` | "caught **only by #65's round-2 reviewer** opening the file" |

All three defects are **round-1 findings**, verbatim in the landed r1 verdict:

- r1 **MAJOR-2**: *"`docs/setup.md:42` … cites `repo-policy-check-patterns.md:57` for the "Running them" section; that was TRUE at base `4f2ae97` and the commit's own section-3 rewrite pushed the heading to line 76."* Remedy list item 1: *"MAJOR-2 first — fix `docs/setup.md:42` `:57` → `:76`. (Ironic and mandatory.)"*
- r1 **MAJOR-3** item 1: *"`docs/contracts/gating-matrix.md:49` → `board/server/sse.go:75-77`. … Lines 75-77 are a drop-path `select`… The real heartbeat is `writeSSEHeartbeat`, `sse.go:96-101`."*
- r1 **MAJOR-3** item 2: *"`docs/design/...design.md:97` → `artifacts/reviews/...REJECT.md:66`. Line 66 is **blank**."*

**Provenance measured, not inferred:** occurrences of "round-2 reviewer" per file — `3d76e65`: 0 / 0 / 0. `4aea118`: 1 / 1 / 1. The phrase entered in the round-2 **fix** commit; the car labelled the reviewer by the round it was writing in, not the round the finding came from. It then survived r2 and r3 review unexamined.

**The substance of all three retargets is TRUE — I checked every hop:** `writeSSEHeartbeat` at `board/server/sse.go:100`, body `fmt.Fprint(w, ": heartbeat\n\n")` — a bare SSE comment, exactly as the citing text claims. `artifacts/reviews/2026-07-22-harness-design-round1-REJECT.md` exists; line 66 is empty, line 67 is `### MAJOR-1. \`PostToolUse:Task\` does not fire…`. `## Running them` is at `docs/templates/repo-policy-check-patterns.md:76`; line 57 is unrelated prose. **Only the attribution is false** — and it is false three times, in three documents, on the exact three lines r1 named.

Why this is Major and not cosmetic: this repo's product is a visible, honest process record, and "which gate caught what, at which round" is precisely the data the convergence/swirl doctrine consumes. Crediting round 2 for round 1's catches understates the round-1 gate and overstates the round-2 one. One of the three (`docs/setup.md`) is stranger-facing setup documentation. `s/round-2 reviewer/round-1 reviewer/` in three places closes it.

---

## MINOR FINDINGS

**MINOR-R4-1 — Dead locative pointer in the amputated header.** `:15-16` reads *"its bind trigger **is stated where it runs**: the tokened-citation population growing past 20, or the first report-only miss confirmed NOT to be a defect."* It is not stated where it runs. `grep -n "trigger"` across the entire 741-line file returns **exactly one hit — line 15, the sentence making the claim.** The content-anchor `It` at :431 and its runtime message at :450-452 say only `"REPORT-ONLY, never binding: hit=$hit miss=$miss at this HEAD."`; the `It` name was in fact *shortened* this round, dropping r3's `"per landing calibration (n too small to bind)"`. Not Major: the trigger's substance is delivered in the same sentence, so no reader is deprived of it. But it is a false statement about the file's own contents in the ungated region — the recurring class — and the fix is to delete four words or to put the trigger at the `It`.

**MINOR-R4-2 — `docs/templates/repo-policy-check-patterns.md` §3 carries a stale measurement the same train invalidated.** It states *"measured at landing, only ~9 of the resolvable literal-path citations in this repo carry a backtick-quoted symbol token on the citing line at all."* True at `3d76e65` (that revision's own header: *"Of those 9: 7 hit, 2 miss"*). At the landing state `de9cda2` the gate reports **`hit=6 miss=0`** — n=6. `4aea118` removed the coordinates that changed it and did not update this line (same-commit living-document obligation). The conclusion — too sparse to bind — is unaffected and remains true.

---

## SUITES at `de9cda2` — run myself, detached

| Suite | Observed | Expected / claimed | |
|---|---|---|---|
| The gate | **28 passed / 0 failed / 4 skipped / 32** | r3 recorded 28/0/4/32 | ✅ identical |
| `scripts/tests` full Pester | **222 / 0 / 5 skipped / 227** | car 223/0/4/227 attached | ✅ 222+5 = 223+4 = 227; the one extra skip is the branch-attached test, as prior verdicts state |
| `scripts/probes` | **24 / 0 / 24** | 24/24 | ✅ |
| `CodeCitationPolicy` | **13 / 0 / 13** | 13/13 | ✅ |
| Go + `go vet`, Node, `probe-yard-snapshot.mjs` | **not re-run — skip is SOUND** | — | ✅ verified below |

**Skip justification, verified independently:** `git diff --name-only 4f2ae97..de9cda2` = 7 files — one `.sh` (comment-only: every changed line in that hunk begins with `#`), five `.md`, one `.ps1` test. **No `.go`, `.js`, `.mjs`, `.css`, `.html`, `.json`, no schema, no CI workflow, nothing under `board/`.** Nothing in this diff can reach those suites. r3 personally observed Go **85/85** + `go vet` clean, Node **129/129** and probe **PASS** at `4aea118`, which already contained all five doc changes; I accept those with attribution rather than claiming them.

**Carried-forward totals re-derived at HEAD using the gate's own shipped helpers: 258 checked source files, 188 coordinates.** Exact.

---

## CONVERGENCE RULING

| Condition | r1 → r2 → r3 → r4 | |
|---|---|---|
| Major counts stop declining | 5 → 1 → 2 → **2** | **MET** (flat) |
| Findings cluster in the same section | header: 5 → 1 → 2 → **1** (MAJOR-R4-2 is elsewhere and pre-dates this round) | **partially** |
| A round's findings are defects the previous round's own fixes created | MAJOR-R4-1 and MINOR-R4-1 are both created by `de9cda2` | **MET** |

**I am NOT escalating, and I am naming why rather than leaving it to inference.** The owner's remedy demonstrably changed the instrument: the ungated prose surface shrank roughly ten-fold, its remaining claims are four digits and one citation, and **I verified every one of them.** The header defect count went 5 → 1, and that one is a *deletion* (a cut rule), not a fabrication. MAJOR-R4-2 is not a swirl signal at all — it is a pre-existing `4aea118` defect that three rounds of review missed, i.e. a review-coverage finding surfaced by rotation working as designed.

**Cap I do set, and it is narrow:** round 5 is a fix round against this closed list — restore the historical-marker paragraph, correct three `round-2` → `round-1`, delete four words at `:15`, correct or de-numeralise `~9`. **If round 5's header produces any NEW false claim, the instrument question is not settled and it returns to the owner rather than to a round 6.**

---

## VERDICT FIELDS (#13)

**BASE-DELTA vs `4f2ae978d4628c67ee049a5c874961837cbf564f`** — matches the brief exactly: one new Pester gate (`scripts/tests/CitationResolverPolicy.Tests.ps1`, +741), two doc citation retargets (`docs/design/…design.md`, `docs/specs/…spec.md`, 1 line each — and the spec's retarget correctly defers to the design's fuller note, no second copy), one hook comment marker (`.claude/hooks/run-session-start-guards.sh`, +7/−4, **comment-only, verified line by line**), one template note (`docs/templates/repo-policy-check-patterns.md`, +21/−2), plus `docs/contracts/gating-matrix.md` and `docs/setup.md` citation fixes (1 line each). **No behavior change outside `scripts/tests`: confirmed** — no `.go`, `.js`, `.mjs`, `.css`, `.json`, no `scripts/*.ps1` outside `scripts/tests/`, no schema, no workflow.

**#40 floor: N/A, with reason.** The cumulative diff contains no rendered surface — no `.html`, `.css`, `.js`, nothing under `board/web/`. There is no computed-style claim to fault-inject through a browser. Verified by `git diff --name-only 4f2ae97..de9cda2` (7 files, enumerated above).

**UNREPRODUCIBLE-EVIDENCE:**
- Go 85/85 + `go vet`, Node 129/129, `probe-yard-snapshot.mjs` PASS — not run by me; attributed to r2/r3 at `4aea118`, and the file-list argument for the skip is verified above.
- The car's attached-branch `223/0/4/227` — I ran detached and observed `222/0/5/227`; the two reconcile.
- No CI run exists for this commit (car branch, never pushed), so no terminal CI state is claimed.
- I did not replay r2's dual-tree 192→188 scanner-equivalence archive; I re-derived only the end-state totals (258/188), which are exact.

**ROTATION NOTE — were the landed verdicts sufficient to review cold? Substantially yes, with two gaps worth recording as drill output:**

1. **The verdicts the brief cited do not exist at the review base.** They are landed on `dev`; the car branch `de9cda2` branched from `4f2ae97`, which predates them. `ls artifacts/reviews/ | grep tooling-65` at HEAD returns nothing. I recovered them with `git show 28c1c01:artifacts/reviews/…`. A fresh reviewer following the brief's paths literally hits a dead end at step one. Cheap fix: delta briefs should give verdicts as `git show &lt;landing-sha&gt;:&lt;path&gt;`, not bare repo paths.
2. **Finding-ID schemes are not uniform across rounds, and that asymmetry has now caused a Major.** r1 uses `MAJOR-1..5` / `MINOR-1..5` with no round prefix; r2 and r3 use `MAJOR-R2-n` / `MAJOR-R3-n`. The car writing `4aea118` was fixing unprefixed r1 IDs while sitting in round 2 and wrote "round-2 reviewer" three times. **A round-prefixed ID at birth in round 1 would have made that error visible in the sentence itself.** This is a finding about the verdict template, not about any car.

Everything else — base SHA, prior counts, which sections the findings clustered in, the exact fault injections and their reverts, the suite baselines — carried perfectly. I needed nothing from the prior reviewer's memory.

---

## DELIVERABLES (contingent on the fixes landing; my numbers are fresh)

**Merge-message numbers, verified by me at `de9cda2`:**

&gt; Suites at final HEAD: `scripts/tests` **222 passed / 0 failed / 5 skipped / 227** (detached; 223/0/4/227 attached), the gate **28/0/4/32**, `scripts/probes` **24/24**, `CodeCitationPolicy` **13/13**; Go **85/85** + `go vet` clean, Node **129/129**, `probe-yard-snapshot.mjs` **PASS** at `4aea118` (untouched by the later diffs). Corpus at HEAD: **258 tracked non-artifacts source files, 188 coordinates.** Gate history: **r1 REJECT 5M/5m → r2 REJECT 1M/3m → r3 REJECT 2M/2m ESCALATED (swirl cap fired, all three conditions) → owner ruled Option A, amputate the narrative → r4 REJECT 2M/2m (fresh reviewer, rotation) → r5.**

**AMENDED final #65 scope sentence.** The r3 draft is sound on the binding classes and I re-derived its two numbers exactly, but the amputation and my findings change three things: it **omits the historical-marker exemption entirely** (the same omission as MAJOR-R4-1 — a scope sentence that inherits the header's gap), its known-gap clause needs the round-4 count, and the anchor's "n=6, 6/6 hit" figure should be quoted from the gate's own live report rather than restated:

&gt; **#65 lands a mechanical citation-resolver gate (`scripts/tests/CitationResolverPolicy.Tests.ps1`, CI-auto-discovered, ~3s) that BINDS two defect classes across all 188 `file:line` coordinates in the 258 tracked non-artifacts source files: Class A dead paths — single-line and line-wrapped, unwrapping across mid-compound hyphens and directory slashes — and out-of-range line numbers, including inside the ellipsis-elided and ambiguous-basename buckets. It does NOT catch in-range shifted citations, the class behind view-train MAJOR-1, MAJOR-2 and MAJOR-R2-2, which remain review-attention-tier. THREE EXEMPTIONS ARE REPORTED BY NAME, NEVER SILENT: ellipsis-elided coordinates (path precision only — existence and range still checked by suffix match), genuinely ambiguous bare basenames (bound as defects when EVERY candidate is out of range), and citations whose citing line carries the literal case-insensitive marker `historical coordinate`, an author-invoked opt-out for deliberate references to deleted files — one such citation exists at landing. A content-anchor diagnostic ships REPORT-ONLY (the gate reports its own live population; `hit=6 miss=0` at landing) with a 3-for-3 precision record on its historical misses and a numeric trigger to bind at n&gt;20 or at the first confirmed-benign miss. Closed-set self-calibration reds by name when a new citing file type appears, a standing check re-verifies every declared-exempt extension still carries zero coordinates, and the extensionless exemption is allowlisted to LICENSE by path. KNOWN GAP: the gate excludes its own file, so its header's claims are ungated — four rounds of review found seven false claims there, and the round-4 remedy cut that header from ~360 lines to 32 with exactly one real citation remaining.**

---

## CONSTITUTION CHECK

| Law / doctrine | Status |
|---|---|
| **Law 1 (no confident falsehood)** | **VIOLATED** — MAJOR-R4-1 (the BINDING statement is false; disproved by injection), MAJOR-R4-2 (three false attributions), MINOR-R4-1 (false locative), MINOR-R4-2 (stale ~9). |
| **Law 6 (no second copies)** | **HONORED in code** — `Get-ContentAnchorTokens`/`Test-ContentAnchorWindow` remain shared between the production check and the fixture; no duplication introduced. **VIOLATED once in prose** — MINOR-R4-2's hand-maintained `~9` beside a live measurement. |
| **Law 7 (the stranger)** | **VIOLATED** — `docs/setup.md:42` is stranger-facing and carries a false attribution; and a stranger reading the amputated header cannot learn that the gate has an opt-out. |
| **Match the instrument to the artifact** | **HONORED, materially** — this is the owner's remedy working: the measurement record now lives in fixtures and in the gate's own live report, not in prose. Header claim density fell ~10x and every remaining claim verifies. |
| **Living documents (same-commit truth)** | **VIOLATED** — `de9cda2` deleted the marker rule while leaving `.claude/hooks/run-session-start-guards.sh:51`'s pointer to it standing (MAJOR-R4-1's hop 2); `4aea118` invalidated `~9` without updating it. |
| **Healing Loop (mechanism over attention)** | **HONORED, strongly** — 32 tests, and my own injection confirms the Class A check is non-vacuous and reds by name. |
| **Probe doctrine (run, do not read)** | **HONORED by this review** — every behavioural claim here was executed, not read; the bypass was measured, not inferred. |
| **Reviewer rotation / carrier-not-memory** | **HONORED with two named template gaps** — see the rotation note; the verdicts carried the round history, but the paths did not resolve at base and the ID scheme is non-uniform. |
| **Cars never push, never touch the shared checkout** | **HONORED** — `git status` clean, `git diff` 0 lines, both fault-injected files sha256-identical before and after. |
| **Blameless is not polite** | **HONORED** — the code is excellent and I said so first; the findings are stated at full strength anyway. |

**The code is ready and has been for two rounds. What remains is four mechanical edits, one of which is putting back a rule the amputation cut too deep.** Restoring five lines about the marker is not a return to narrative — it is the difference between a gate that documents its own escape hatch and one that does not.

**Files:** `<repo>-wt\review-tooling-65\scripts\tests\CitationResolverPolicy.Tests.ps1` (:4-6 MAJOR-R4-1; :15-16 MINOR-R4-1; :243-254, :322-324 the bypass; :346 the one real citation, verified), `<repo>-wt\review-tooling-65\docs\contracts\gating-matrix.md` (:49), `<repo>-wt\review-tooling-65\docs\design\2026-07-22-dispatch-harness-design.md` (:97), `<repo>-wt\review-tooling-65\docs\setup.md` (:42), `<repo>-wt\review-tooling-65\docs\templates\repo-policy-check-patterns.md` (§3, :44-62), `<repo>-wt\review-tooling-65\.claude\hooks\run-session-start-guards.sh` (:49-53)

```starcar-artifact
outcome: REJECT
task-id: tooling-65-review-r4
findings: 2 Major, 2 Minor - fresh reviewer under rotation. Round history r1 5M/5m, r2 1M/3m, r3 2M/2m ESCALATED, r4 2M/2m. No new escalation; a narrow closed fix list with a cap on round 5.
  MAJOR-R4-1: The amputation cut a load-bearing RULE and left an unqualified claim it contradicts. Header lines 4 to 6 state that every citation the gate finds MUST resolve to an existing file and cite an in-range line. It must not. Any citation whose citing line contains the case-insensitive substring "historical coordinate" is exempted from BOTH binding checks by Test-HistoricalCoordinateMarker at lines 243 to 254 (regex at line 253) routed with a continue at lines 322 to 324. Grep for "historical" across header lines 1 to 32 returns zero hits. This is a regression created by de9cda2: commit 63a5c55 documented the marker in full at its header lines 219 to 227. Proven by fault injection with a control - two dead-path citations appended to docs/friction-log.md differing only in the marker phrase; the unmarked one reds by name with "cites 'reviewer-probe-nonexistent.go:12' - NO SUCH FILE" while the marked one to a file that never existed passes, reported only as an informational skip. Reverted byte-identical, sha256 7FC915C92C0218B3199B02EC8462A5B2BC23948CAEF7293297415CD177BD32A4 before and after. The sentence check breaks at hop 2: .claude/hooks/run-session-start-guards.sh lines 51 to 53 say "#65's CitationResolverPolicy gate exempts it by this marker" and the gate header the hook points at no longer says what the marker is. The train's own diff uses the bypass - the gate at HEAD reports exactly one exempted citation and it is the one this train added. Fix is roughly five lines restored to SCOPE.
  MAJOR-R4-2: Three landed documents credit round 2 with round 1's catches. docs/contracts/gating-matrix.md line 49 and docs/design/2026-07-22-dispatch-harness-design.md line 97 both say "caught by #65's round-2 reviewer"; docs/setup.md line 42 says "caught only by #65's round-2 reviewer opening the file". All three defects are round-1 findings, verbatim in the landed r1 verdict - MAJOR-2 named docs/setup.md:42's broken :57 and ordered the fix to :76, and MAJOR-3 named both gating-matrix.md:49 pointing at a drop-path select instead of writeSSEHeartbeat and design.md:97 pointing at a blank line 66. Provenance measured, not inferred: occurrences of "round-2 reviewer" are 0/0/0 at 3d76e65 and 1/1/1 at 4aea118, so the phrase entered in the round-2 FIX commit, where the car labelled the reviewer by the round it was writing in. The substance of all three retargets is TRUE and I verified every hop - writeSSEHeartbeat at board/server/sse.go:100 emits a bare SSE comment, the round1-REJECT verdict's line 66 is blank with the MAJOR-1 heading at 67, and "## Running them" is at repo-policy-check-patterns.md:76. Only the attribution is false, three times, on the exact three lines r1 named. It corrupts the review-calibration record on a public showcase repo and one instance is stranger-facing setup documentation. Fix is three word substitutions.
  MINOR-R4-1: Header lines 15 to 16 claim the content anchor's bind trigger "is stated where it runs". It is not. Grep for "trigger" across the entire 741-line file returns exactly one hit - line 15, the sentence making the claim. The content-anchor It at line 431 and its runtime message at lines 450 to 452 say only "REPORT-ONLY, never binding: hit=X miss=Y at this HEAD", and the It name was shortened this round, dropping round 3's calibration clause. Not Major because the trigger's substance is delivered in the same sentence, so no reader is deprived; but it is a false statement about the file's own contents in the ungated region.
  MINOR-R4-2: docs/templates/repo-policy-check-patterns.md section 3 states "measured at landing, only ~9 of the resolvable literal-path citations in this repo carry a backtick-quoted symbol token on the citing line at all". True at 3d76e65, whose own gate header read "Of those 9: 7 hit, 2 miss". At the landing state de9cda2 the gate reports hit=6 miss=0, so n is 6. Commit 4aea118 removed the coordinates that changed it and did not update this line. The conclusion, too sparse to bind, is unaffected.
abstract: |
  Fresh-reviewer round-4 delta re-review at de9cda2, base verified on top of 63a5c55, 4aea118, 3d76e65 with base 4f2ae97. Detached worktree, byte-clean in and out, git diff zero lines, nothing committed or pushed.
  THE OWNER'S REMEDY LARGELY WORKED, and I record that before the findings. The ungated self-excluded prose surface fell from roughly 360 header lines to 32. I enumerated every coordinate-shaped string left in the file: exactly one is a real citation, CodeCitationPolicy.Tests.ps1:288-308, and I opened it - line 288 is the completeness It and line 308 its closing brace. All four round-3 findings are genuinely ABSENT, not relocated: no Test-ContentAnchorHit, no "ALL THREE", no "3-for-3", and the overclaiming Describe is renamed Content-anchor case-sensitivity fixture, a name that now matches the three structural assertions it actually makes. Header digit audit confirms the car's claim - only #65, "2+ candidates", the bind trigger 20, and the three verdict filenames.
  NO TEST LOGIC CHANGED, verified mechanically rather than by reading: comment-stripped, blank-stripped revisions diff 570 to 567 lines and every single difference is a string literal - exemption reason texts, Describe and It names, and one Set-ItResult message collapsing five source lines to two, which is the minus three. Zero assertions, zero control flow, zero helper bodies touched. Diff stat is one file, 108 insertions and 556 deletions as claimed.
  BUT THE AMPUTATION CUT TOO DEEP IN ONE PLACE. The historical-coordinate marker is a rule, not narrative - an author-invocable text phrase that turns off both binding checks - and it was deleted along with the history while the header kept an unqualified claim that every citation must resolve. I proved the bypass live with a controlled fault injection: two dead-path citations differing only in the phrase, one reds by name, the other passes silently. The hook comment this train added still points at the gate for an explanation of "this marker" that the gate no longer contains. Separately, three landed documents credit round 2 with round 1's catches, a misattribution that entered in the round-2 fix commit and survived two review rounds; the underlying citations are all substantively correct and I traced every hop.
  Suites at de9cda2, run myself detached: the gate 28 passed / 0 failed / 4 skipped / 32, identical to round 3's record; scripts/tests 222 / 0 / 5 skipped / 227, reconciling with the car's attached 223/0/4/227; scripts/probes 24/24; CodeCitationPolicy 13/13. Corpus re-derived with the gate's own shipped helpers: 258 checked source files, 188 coordinates, exact. The Go, Node and schema-probe skip is SOUND and I verified the file list myself - seven files, one .sh comment-only, five .md, one .ps1 test, nothing under board/ and no schema or workflow.
  CONVERGENCE: Major counts flat at 2, and both header findings are defects this round's own fix created, so the third swirl condition holds again. I am NOT escalating and I name why: the instrument demonstrably changed, header findings fell from 5 to 1, that one is a deletion rather than a fabrication, and the second Major is a pre-existing 4aea118 defect that three rounds missed - a review-coverage finding surfaced by rotation working as designed. Cap set: round 5 is a fix round against a closed list of four mechanical edits; any NEW false claim in the header goes back to the owner rather than to a round 6.
  ROTATION DRILL OUTPUT, two gaps in the carrier worth landing. First, the three verdicts the brief cited do not exist at the review base - they are on dev and the car branch predates them - so a fresh reviewer following the paths literally hits a dead end; delta briefs should cite them as git show landing-sha colon path. Second, finding IDs are not round-prefixed in round 1 while rounds 2 and 3 are, and that asymmetry directly enabled MAJOR-R4-2: a car fixing unprefixed r1 IDs while sitting in round 2 wrote "round-2 reviewer" three times, and a round-prefixed ID would have made the error visible in the sentence itself. Everything else carried perfectly and I needed nothing from the prior reviewer's memory.
  Verified merge numbers and an AMENDED final #65 scope sentence are supplied, contingent on the fixes landing. The amendment matters: round 3's draft inherited the same gap as the header and omitted the historical-marker exemption entirely.
```