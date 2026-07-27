<!-- starcar-integrity: sha256=cf861d9e2778e6a4ecda9a8d641a4f5d35950136a9769dcafc0a82e3e5d0c0a1 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Tooling train #65 citation-resolver gate review, round 5 (APPROVE)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial delta re-review, final round
Round: 5
Target: `car/tooling-65 HEAD ee2a626 (closed-list fix on de9cda2)`
Base reviewed: `4f2ae978d4628c67ee049a5c874961837cbf564f`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

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

# DELTA RE-REVIEW VERDICT — tooling train #65, round 5

## VERDICT: **APPROVE** — 0 Major, 0 Minor. **My round-4 cap is satisfied and does not fire. The train merges.**

**Base verified.** `git checkout --detach ee2a626` → HEAD `ee2a6269f6f225b702ee989a42196162d3096ad7`, parent `de9cda2b9b70c454cb433186cce42aa03eac4d0c`, on the chain `63a5c55` → `4aea118` → `3d76e65` → base `4f2ae97`. `git status --porcelain` empty at entry and exit; `git diff` 0 lines. Shared checkout untouched, nothing committed, nothing pushed.

---

## MY FOUR IDs — Present / Absent / DRIFTED

| ID | Status | How I verified it |
|---|---|---|
| **MAJOR-R4-1** | **ABSENT (fixed)** | Clause-by-clause against code, then **watched** — table below |
| **MAJOR-R4-2** | **ABSENT (fixed)** | `git diff --word-diff` over the three files yields **exactly** `3 × [-round-2-] {+round-1+}` and nothing else. Not one other word moved on those lines. Correct against the landed r1 verdict, which carries all three as round-1 findings (MAJOR-2 for `setup.md`, MAJOR-3 items 1 and 2 for `gating-matrix.md` and `design.md`). |
| **MINOR-R4-1** | **ABSENT (fixed)** | `"its bind trigger is stated where it runs:"` → `"its bind trigger:"`. The locative is deleted, the trigger's substance retained. **No replacement claim crept in:** `grep -n "stated where\|is stated"` across all 748 lines returns zero hits, and every surviving `below` pointer (`:7`, `:23`, `:38`, plus three body comments) resolves. |
| **MINOR-R4-2** | **ABSENT (fixed)** | `~9` gone, replaced by `"only a small fraction … (the gate's own report-only check states the live count on every run)"`. **No new number.** I measured the fraction rather than accepting it: of 174 resolved coordinates, 54 are literal-path, **6 carry a backtick token — 11.1%.** "A small fraction" is true, and being unnumbered it cannot go stale. |

### MAJOR-R4-1, clause by clause — every one true of the shipped code

| Header claim (`scripts/tests/CitationResolverPolicy.Tests.ps1:30-34`) | Code | |
|---|---|---|
| "the literal, case-insensitive phrase `historical coordinate`" | `:260` `return [bool]($text -match '(?i)historical coordinate')` — `(?i)`, literal, no metacharacters | ✅ |
| "on the citing line (or any line spanned by a wrapped match)" | `:257-259` `$lo = StartLine-1`, `$hi = EndLine-1`, `$lines[$lo..$hi] -join ' '` — the full span, so a wrapped match is covered | ✅ |
| "exempts that one citation from BOTH the existence and range checks above" | `:329-331` `continue` fires **before** either resolver is called, so neither `$DeadPath` (Class A, asserted `:396`) nor `$OutOfRange` (Class B, asserted `:403`) can ever receive it | ✅ |
| "an author-invoked opt-out for a deliberate reference to a file that no longer exists" | matches the one live instance and the hook's own wording | ✅ |
| "Exempted citations are still reported by name every run, never silent" | `:414-419` unconditional `It`, emits `CitingFile:StartLine -&gt; 'Target:TargetLine'` per exemption | ✅ |
| BINDING `:6-7` "EXCEPT those carrying the historical-coordinate marker **(below)**" | the paragraph is at `:30-34`, below `:7` | ✅ resolves |

**Hop 2 now resolves.** `.claude/hooks/run-session-start-guards.sh:51-53` — *"#65's CitationResolverPolicy gate exempts it by this marker"* — a reader following that pointer now lands on a header that names the marker, its exact trigger phrase, its scope, its purpose, and its reporting guarantee. The sentence that broke at hop 2 in round 4 completes.

**AND I WATCHED IT, including a claim no round has watched before.** The restored paragraph asserts exemption from **BOTH** checks; round 4 only ever observed the existence half. So I injected a three-probe set into `docs/friction-log.md` — a control and both halves:

```
[-] every literal-path or uniquely-resolved-basename citation points at a file that exists at HEAD (Class A)
 Expected $null or empty, but got 'docs/friction-log.md:259 cites 'reviewer-probe-nonexistent.go:12' - NO SUCH FILE'.
```
```
[+] every resolved citation's line (or range end) is within the target file's line count (Class B floor)
```
```
[!] reports historical-coordinate-marked citations as exempt, by name, never silently is skipped, because
    informational, not a failure: 3 historical-coordinate citation(s) exempted -
    .claude/hooks/run-session-start-guards.sh:51 -&gt; 'session-start-record.sh:76';
    docs/friction-log.md:260 -&gt; 'reviewer-probe-alsogone.go:34';
    docs/friction-log.md:261 -&gt; 'docs/setup.md:99999'
```

**A** (unmarked dead path) reds by name — the gate still bites. **B** (marked dead path) is exempted from the existence check. **C** (marked, real file, line 99999) is exempted from the **range** check — the Class B floor stayed green — and **all three exemptions are named in the report.** Every clause of the restored paragraph is now an observation, not a reading. Run 27/1/4/32. `docs/friction-log.md` sha256 `7FC915C92C0218B3199B02EC8462A5B2BC23948CAEF7293297415CD177BD32A4` **before and after — identical**; `git status --porcelain` empty; `git diff` 0 lines.

---

## THE DECISIVE CHECK — full-diff audit for any NEW false or unmeasured claim

I walked **every changed line** of `de9cda2..ee2a626` (5 files, 21 insertions / 13 deletions). Seven distinct changes:

| # | Change | Adjudication |
|---|---|---|
| 1-3 | `round-2` → `round-1` ×3 | TRUE against the landed r1 verdict; word-diff confirms nothing else moved |
| 4 | §3 de-numeralised | "small fraction" **measured 11.1%** by me; "the gate's own report-only check states the live count on every run" — observed, the check emits `hit=6 miss=0 at this HEAD` on every run |
| 5 | BINDING gains "EXCEPT … (below)" | TRUE; pointer resolves |
| 6 | Locative deleted from NOT CAUGHT | pure deletion, no replacement claim |
| 7 | New HISTORICAL-COORDINATE MARKER paragraph | five clauses, all verified against code **and** watched behaviourally |

**Zero new claims, false or unmeasured. The cap does not fire.**

**Header digit audit, re-run:** `#65` (:2), `2+ candidates` (:8), `20` (:17), and the r1/r2/r3 verdict filenames (:37-38). Identical set to round 4 — nothing added. Line 39's `"this header carries no measurement claims"` remains true: `20` is a threshold rule and `2+` a definition, neither a measurement.

**One observation, explicitly NOT a finding**, recorded so a future reader has it rather than rediscovers it: `:32`'s "that one citation" describes the exemption as per-citation rather than per-file, which is correct in the sense that matters. Strictly, `Test-HistoricalCoordinateMarker` examines the coordinate's own `StartLine..EndLine` span, so two coordinates sharing one marked span would both be exempted. The sentence does not claim otherwise, there are zero such instances in the corpus (one marked citation total), and I am not manufacturing a finding out of it.

---

## NO TEST LOGIC CHANGED — proven, not asserted

I stripped comment and blank lines from both revisions and diffed:

```
diff r4-code.txt r5-code.txt   →   (no output)
```

**The comment-stripped code is byte-identical between `de9cda2` and `ee2a626`.** Not "only string literals changed" as in round 4 — *nothing* changed. The file grew 741 → 748 lines, and every one of those 7 net lines is a comment. That is the strongest available form of this check.

---

## SUITES at `ee2a626` — run myself, detached

| Suite | Observed | Car claimed | |
|---|---|---|---|
| The gate | **28 passed / 0 failed / 4 skipped / 32** | 28/0/4/32 | ✅ identical to r3, r4 |
| `scripts/tests` full Pester | **222 / 0 / 5 skipped / 227** | 223/0/4/227 attached | ✅ 222+5 = 223+4 = 227 |
| `scripts/probes` | **24 / 0 / 24** | 24/24 | ✅ |
| `CodeCitationPolicy` | **13 / 0 / 13** | 13/13 | ✅ |
| Go + `go vet`, Node, `probe-yard-snapshot.mjs` | **not re-run — skip is SOUND** | — | ✅ see below |

**Corpus re-derived at HEAD with the gate's own shipped helpers: 258 checked source files, 188 coordinates.** Exact.

**Skip justification:** `git diff --name-only 4f2ae97..ee2a626` = 7 files — one `.sh` (comment-only), five `.md`, one `.ps1` test. No `.go`, `.js`, `.mjs`, `.css`, `.html`, `.json`, no schema, no CI workflow, nothing under `board/`. r2 personally observed Go **85/85** + `go vet` clean, Node **129/129**, `probe-yard-snapshot.mjs` **PASS** at `4aea118`, which already contained every doc change in this train; the three later commits are prose-only. Attributed, not claimed.

---

## CONVERGENCE RULING — the swirl is broken

| Condition | r1 → r2 → r3 → r4 → r5 | |
|---|---|---|
| Major counts stop declining | 5 → 1 → 2 → 2 → **0** | **NOT MET** — declining |
| Findings cluster in the same section | header: 5 → 1 → 2 → 1 → **0** | **NOT MET** — nothing to cluster |
| A round's findings are defects the previous round's fixes created | **none** | **NOT MET** |

**Zero of three.** The owner's Option-A ruling is vindicated on the evidence rather than on deference: the header went from ~360 lines of measurement narrative to **39 lines** containing four digit-claims (all rules or pointers), exactly one real citation (`CodeCitationPolicy.Tests.ps1:288-308`, which I opened), and one restored rule that I verified clause-by-clause and then watched fire. Round 5 is the first round of this train in which the header produced no false claim.

---

## DELIVERABLES

### (a) Final merge-message numbers

&gt; **#65 citation-resolver gate — MERGE.** Suites at `ee2a626`: the gate **28 passed / 0 failed / 4 skipped / 32**; `scripts/tests` **222 / 0 / 5 skipped / 227** detached (**223 / 0 / 4 / 227** attached — the one extra skip is a branch-attached test); `scripts/probes` **24 / 24**; `CodeCitationPolicy` **13 / 13**. Go **85/85** + `go vet` clean, Node **129/129**, `probe-yard-snapshot.mjs` **PASS** at `4aea118`, untouched by the three prose-only commits after it. Corpus at HEAD: **258 tracked non-artifacts source files, 188 coordinates.** All counts observed by the round-5 reviewer at `ee2a6269f6f225b702ee989a42196162d3096ad7`, detached worktree.
&gt;
&gt; **Cumulative BASE-DELTA vs `4f2ae978d4628c67ee049a5c874961837cbf564f`** — 7 files, 778 insertions / 7 deletions: one new Pester gate (`scripts/tests/CitationResolverPolicy.Tests.ps1`, +748), one template note (`docs/templates/repo-policy-check-patterns.md`, +22/−2), one hook comment marker (`.claude/hooks/run-session-start-guards.sh`, +7/−4, **comment-only**), and four one-line citation corrections (`docs/contracts/gating-matrix.md`, `docs/design/2026-07-22-dispatch-harness-design.md`, `docs/specs/2026-07-22-dispatch-harness-spec.md`, `docs/setup.md`). **No behavior change outside `scripts/tests`** — no `.go`, `.js`, `.mjs`, `.css`, `.json`, no `scripts/*.ps1` outside `scripts/tests/`, no schema, no workflow.
&gt;
&gt; **Gate history: r1 REJECT 5M/5m → r2 REJECT 1M/3m (cap set) → r3 REJECT 2M/2m ESCALATED (all three swirl conditions; owner ruled Option A, amputate the narrative) → r4 REJECT 2M/2m (fresh reviewer under mechanical rotation, cap set on a closed four-item list) → r5 APPROVE 0M/0m (cap satisfied, zero of three swirl conditions).**

### (b) FINAL #65 scope sentence for the ticket close

Updated from my round-4 draft in two places: the exemption clause is now consistent with the restored header paragraph, and **the count of past false claims is removed rather than restated.** I could not derive that number cleanly — round 3's own verdict says "five" in its scope draft and "fifth and sixth instances" in its constitution check — and restating an unverifiable figure in the closing artifact of a train about citation truth would be the defect wearing the victory lap.

&gt; **#65 lands a mechanical citation-resolver gate (`scripts/tests/CitationResolverPolicy.Tests.ps1`, CI-auto-discovered, ~3s) that BINDS two defect classes across all 188 `file:line` coordinates in the 258 tracked non-artifacts source files: Class A dead paths — single-line and line-wrapped, unwrapping across mid-compound hyphens and directory slashes — and out-of-range line numbers, including inside the ellipsis-elided and ambiguous-basename buckets. It does NOT catch in-range shifted citations, the class behind view-train MAJOR-1, MAJOR-2 and MAJOR-R2-2, which remain review-attention-tier. THREE EXEMPTIONS EXIST AND ALL THREE ARE REPORTED BY NAME EVERY RUN, NEVER SILENT: ellipsis-elided coordinates (path precision only — existence and range are still checked by suffix match), genuinely ambiguous bare basenames (which BIND as defects when every candidate is out of range), and the author-invoked historical-coordinate marker — the literal case-insensitive phrase "historical coordinate" on the citing line or any line of a wrapped match, which exempts that citation from BOTH the existence and range checks for a deliberate reference to a file that no longer exists; one such citation exists at landing, and the marker's full rule is stated in the gate's own header. A content-anchor diagnostic ships REPORT-ONLY, stating its live hit/miss counts on every run, with a numeric trigger to bind at a tokened population over 20 or at the first report-only miss confirmed not to be a defect. Closed-set self-calibration reds by name when a new citing file type appears, a standing check re-verifies every declared-exempt extension still carries zero coordinates, and the extensionless exemption is allowlisted to LICENSE by path. KNOWN GAP: the gate excludes its own file, so its header's claims are ungated — rounds 1 through 4 each found at least one false claim there and round 5 found none, which is why the round-4 owner ruling cut that header from roughly 360 lines to 39 and why every claim it now carries is a rule or a pointer rather than a measurement.**

---

## VERDICT FIELDS (#13)

**BASE-DELTA vs `4f2ae978d4628c67ee049a5c874961837cbf564f`:** as enumerated above; verified by `git diff --name-only` and `--stat`, and the hook's comment-only status verified line by line. No behavior change outside `scripts/tests`.

**#40 floor: N/A, with reason.** The cumulative diff contains no rendered surface — no `.html`, `.css`, `.js`, nothing under `board/web/`. There is no computed-style claim for a browser-driven injection to target. Verified by the 7-file diff list (1 `.sh`, 5 `.md`, 1 `.ps1`).

**UNREPRODUCIBLE-EVIDENCE:**
- Go 85/85 + `go vet`, Node 129/129, `probe-yard-snapshot.mjs` PASS — not run by me; attributed to r2 at `4aea118`, with the file-list argument for the skip independently verified above.
- The car's attached-branch `223/0/4/227` — I ran detached and observed `222/0/5/227`; the two reconcile.
- No CI run exists for this commit (car branch, never pushed), so no terminal CI state is claimed. **The conductor must watch CI to a terminal green after merge; this verdict asserts local suites only.**
- I did not re-derive r2's dual-tree 192→188 scanner-equivalence archive; I re-derived the end-state totals (258/188), which are exact.

---

## CONSTITUTION CHECK

| Law / doctrine | Status |
|---|---|
| **Law 1 (no confident falsehood)** | **HONORED** — every changed line audited; four previously-false claims corrected; the restored paragraph's five clauses verified against code and then observed firing. |
| **Law 6 (no second copies)** | **HONORED** — the last hand-maintained number in the prose (`~9`) is gone, replaced by a pointer to the live check. Helpers remain shared, not duplicated. |
| **Law 7 (the stranger)** | **HONORED** — `docs/setup.md`'s attribution is now true, and a stranger reading the gate header learns the opt-out exists, what phrase invokes it, and that it is always reported. |
| **Match the instrument to the artifact** | **HONORED** — the measurement record lives in fixtures and the gate's live report; prose carries rules and pointers only. |
| **Living documents (same-commit truth)** | **HONORED** — the header rule and the hook comment that points at it are consistent in the same commit; §3 no longer carries a figure the code can invalidate. |
| **Healing Loop (mechanism over attention)** | **HONORED** — 32 tests, and the guard proven non-vacuous under my own injection in both directions. |
| **Probe doctrine (run, do not read)** | **HONORED** — I watched the range-exemption half of the restored claim rather than reading it; it had never been observed by any round. |
| **A guard is unproven until someone has WATCHED it fire** | **HONORED** — control plus both exemption halves, verbatim output quoted. |
| **Reviewer rotation / carrier-not-memory** | **HONORED** — round 5 was reviewed cold off the round-4 verdict's four IDs; the two carrier gaps I raised in round 4 (verdict paths not resolving at base; unprefixed r1 finding IDs) remain open as template findings and are **not** blockers for this merge. |
| **Cars never push, never touch the shared checkout** | **HONORED** — `git status` clean, `git diff` 0 lines, the injected file sha256-identical before and after. |
| **Blameless is not polite** | **HONORED** — I approved on measurement, not on round count or fatigue; I would have rejected on one unverified clause and I checked all five. |

**APPROVE. The train is mergeable.** Five rounds, and what merges is a gate whose every binding claim I injected against, whose every exemption I watched report itself by name, and whose header a stranger can read without being told a single thing that is not true.

**Files:** `<repo>-wt\review-tooling-65\scripts\tests\CitationResolverPolicy.Tests.ps1` (`:6-7` BINDING exception, `:16` the delocativised trigger, `:30-34` the restored marker rule, `:250-261` `Test-HistoricalCoordinateMarker`, `:329-331` the routing, `:414-419` the by-name report, `:396`/`:403` the two binding assertions), `<repo>-wt\review-tooling-65\docs\contracts\gating-matrix.md` (`:49`), `<repo>-wt\review-tooling-65\docs\design\2026-07-22-dispatch-harness-design.md` (`:97`), `<repo>-wt\review-tooling-65\docs\setup.md` (`:42`), `<repo>-wt\review-tooling-65\docs\templates\repo-policy-check-patterns.md` (§3, `:44-63`), `<repo>-wt\review-tooling-65\.claude\hooks\run-session-start-guards.sh` (`:49-53`)

```starcar-artifact
outcome: APPROVE
task-id: tooling-65-review-r5
findings: 0 Major, 0 Minor. All four round-4 IDs ABSENT (fixed), none DRIFTED. My round-4 cap is satisfied and does not fire - a full-diff audit of every changed line found no new false or unmeasured claim. Gate history r1 5M/5m, r2 1M/3m, r3 2M/2m ESCALATED with owner ruling Option A, r4 2M/2m under rotation, r5 0M/0m. Zero of three swirl conditions now hold; the swirl is broken.
abstract: |
  Round-5 delta re-review at ee2a626, parent de9cda2 verified, on the chain 63a5c55, 4aea118, 3d76e65 with base 4f2ae97. Detached worktree, byte-clean in and out, git diff zero lines, nothing committed or pushed.
  ALL FOUR OF MY ROUND-4 FINDINGS ARE ABSENT, and I checked each rather than accepting the car's account. MAJOR-R4-2 is surgical: git word-diff over the three documents yields exactly three replacements of round-2 by round-1 and not one other word moved, correct against the landed r1 verdict which carries all three as round-1 findings. MINOR-R4-1 was closed by deletion with no replacement claim - grep for "stated where" and "is stated" across all 748 lines returns zero, and every surviving "below" pointer resolves. MINOR-R4-2 is de-numeralised, and I measured the replacement rather than trusting it: of 174 resolved coordinates 54 are literal-path and 6 carry a backtick token, 11.1 percent, so "a small fraction" is true and, carrying no number, cannot go stale.
  MAJOR-R4-1 got the full treatment because it is the one that mattered. The restored HISTORICAL-COORDINATE MARKER paragraph makes five separate claims and I verified each against the shipped code - the case-insensitive literal phrase against the regex at line 260, the wrapped-span coverage against the StartLine-to-EndLine join at lines 257 to 259, exemption from BOTH checks against the continue at lines 329 to 331 which fires before either resolver is called, the author-invoked purpose, and the by-name reporting against the unconditional It at lines 414 to 419. The BINDING paragraph now carries the EXCEPT qualifier with a pointer that resolves, and hop 2 of the cross-file sentence completes: a reader following the hook comment at run-session-start-guards.sh lines 51 to 53 now lands on a header that names the marker.
  THEN I WATCHED IT, including a claim no round has ever watched. The paragraph asserts exemption from BOTH checks and round 4 only observed the existence half, so I injected a three-probe set - an unmarked dead path as control, a marked dead path, and a marked citation to a real file at line 99999. The control reds by name with NO SUCH FILE. The marked dead path is exempted. The marked out-of-range citation leaves the Class B floor test green, which is the range half proven for the first time. All three exemptions are named in the report It's output. Reverted byte-identical, sha256 7FC915C92C0218B3199B02EC8462A5B2BC23948CAEF7293297415CD177BD32A4 before and after.
  NO TEST LOGIC CHANGED, in the strongest available form: I stripped comments and blank lines from both revisions and the results are BYTE-IDENTICAL. Not merely string-literals-only as in round 4 - nothing at all. The file grew 741 to 748 lines and all 7 are comments.
  THE DECISIVE CHECK per my cap: I walked every changed line of the five-file, 21-insertion diff. Seven distinct changes, each adjudicated - three word substitutions verified true against the r1 verdict, one de-numeralisation I measured myself, one BINDING qualifier whose pointer resolves, one pure deletion, and one new paragraph verified clause-by-clause and then watched. Zero new claims, false or unmeasured. The header digit audit is unchanged from round 4: only the ticket number, a 2-plus definition, the threshold 20, and the three verdict filenames. One edge is recorded explicitly as NOT a finding - "that one citation" would also exempt a second coordinate sharing a marked line span, which the sentence does not deny and which has zero instances in the corpus.
  Suites at ee2a626, run myself detached: the gate 28 passed / 0 failed / 4 skipped / 32; scripts/tests 222 / 0 / 5 skipped / 227, reconciling with the car's attached 223/0/4/227; scripts/probes 24/24; CodeCitationPolicy 13/13. Corpus re-derived with the gate's own helpers: 258 files, 188 coordinates, exact. The Go, Node and schema-probe skip is sound and I verified the seven-file list myself.
  CONVERGENCE: zero of three swirl conditions hold. Majors declined 5, 1, 2, 2, 0; header findings went 5, 1, 2, 1, 0; no finding this round was created by last round's fix because there are none. The owner's amputation ruling is vindicated on evidence rather than deference - the header is 39 lines carrying rules and pointers only, with exactly one real citation which I opened and confirmed.
  Deliverables supplied: final merge-message numbers with the cumulative base-delta of 7 files and 778 insertions against 4f2ae97, and the FINAL #65 scope sentence. I deliberately REMOVED the count of past false claims from that sentence rather than restating it - round 3's own verdict says five in one place and sixth instances in another, so the figure is not cleanly derivable, and restating an unverifiable number in the closing artifact of a train about citation truth would be the defect taking a victory lap. The sentence now says rounds 1 through 4 each found at least one and round 5 found none, which is verifiable from the landed verdicts.
  One standing obligation for the conductor: no CI run exists for this commit, so this verdict asserts local suites only and CI must be watched to a terminal green after merge.
```