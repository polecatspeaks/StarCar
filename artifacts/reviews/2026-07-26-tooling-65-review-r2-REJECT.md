<!-- starcar-integrity: sha256=8624a0ba09bb031994acd9b16ca0dab3b09e0f0ae1d447827d4077132f7c0735 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Tooling train #65 citation-resolver gate review, round 2 (delta)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial delta re-review
Round: 2
Target: `car/tooling-65 HEAD 4aea118 (fix commit on 3d76e65)`
Base reviewed: `4f2ae978d4628c67ee049a5c874961837cbf564f`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a965df3347dae4a72`. The conductor did not retype a word of what follows. Verbatim by
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

| Dispatch, the locator within the session | `a965df3347dae4a72` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 4f2ae978d4628c67ee049a5c874961837cbf564f
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

---

# DELTA RE-REVIEW VERDICT — tooling train #65, round 2

## VERDICT: **REJECT** — 1 Major, 3 Minor (r1: 5M/5m). Converging strongly; cap set at one more round.

**Base verified.** `git checkout --detach 4aea118` → HEAD `4aea118a6504ee02a55df0daa4100b3f396e62d8`, parent `3d76e6506cefa56f5082ddcccf438fb14b1e6317`, `git status --porcelain` empty at entry and exit. Shared checkout untouched. Nothing committed or pushed. All fault injections reverted byte-identical (sha256 stated per injection below).

---

## R1 FINDING DISPOSITION TABLE

| ID | r1 finding | Status | Evidence I re-derived |
|---|---|---|---|
| **MAJOR-1** | Gate doesn't catch the class; header overclaims | **ABSENT (fixed)** | Header lines 14-36 now state BINDING = Class A + out-of-range; "NOT CAUGHT … an IN-RANGE shifted citation". The inherited "would have caught MAJOR-1/2/R2-2" quote is **removed** and replaced by a CORRECTION section. No residual overclaim found anywhere in the file (I swept all 343 header lines). |
| **MAJOR-2** | Commit broke `docs/setup.md:42`, left stale | **ABSENT (fixed)** | Now cites the section BY NAME. `## Running them` exists at line 76. Provenance claim verified across 4 commits (below). |
| **MAJOR-3** | "Neither confirmed a real defect" false; 2 live Class B defects | **ABSENT (fixed)** | Both defects fixed by symbol/heading conversion. `writeSSEHeartbeat` exists at `board/server/sse.go:100`, body `fmt.Fprint(w, ": heartbeat\n\n")` — the citing text's "bare SSE comment" claim is TRUE at the symbol. Header now records the 2-for-2 true-positive record. |
| **MAJOR-4** | Half-fix; false "matches exactly" claim | **ABSENT (fixed)** | Header lines 148-152 now say precisely: "the PATH and the git-mv history were true … The LINE was never independently checked and was WRONG - line 66 is blank". Verified: `:66`=`[]`, `:67`=`### MAJOR-1. …`. |
| **MAJOR-5** | No closed-set self-calibration | **ABSENT (fixed)** | Completeness `It` at line 662, asserts on `.Count`, 10 declared exemptions each with a reason. **Fault-injected — see below.** |
| **MINOR-1** | Slash-wraps missed | **ABSENT (fixed)** | `Test-CitationWrapBoundary` now `-or $TrimmedLine.EndsWith('/')`; scratch fixture 10 pins it. |
| **MINOR-2** | Case-insensitive anchor | **ABSENT (fixed)** | Line 746 now `-cmatch`. Near-collision disclosed at header lines 230-232. |
| **MINOR-3** | Ellipsis valve ran no checks | **ABSENT (fixed)** | `Resolve-ElidedCitationTarget` (suffix match + existence + range). **Fault-injected on the real corpus — red by name.** |
| **MINOR-4** | Ambiguous valve ran no range check | **ABSENT (fixed)** | Lines 588-604 bind all-candidates-out-of-range. **Fault-injected on the real corpus — red by name.** |
| **MINOR-5** | Spaced-dash false-join surface | **ABSENT (fixed)** | Regex `[A-Za-z0-9_]-$`; pinned as unit tests. **Pin proven non-vacuous.** |

**All 10 r1 findings genuinely resolved. Zero DRIFTED.**

---

## SUITES at `4aea118` — run myself

| Suite | Observed | Car claimed | |
|---|---|---|---|
| `scripts/tests` full Pester | **216 passed / 0 failed / 5 skipped / 221** | 217/0/4/221 attached | ✅ Extra skip = branch-attached `#50` test. 216+5 = 217+4 = 221 |
| `scripts/probes` | **24 / 0 / 24** | — | ✅ |
| Go `board/...` + `go vet` | **85 PASS / 0 FAIL / 0 SKIP**, vet clean | — | ✅ |
| Node `board/web` | **129 / 129 pass / 0 fail** (2 runs) | — | ✅ |
| `probe-yard-snapshot.mjs` | **PROBE RESULT: PASS**, exit 0 | — | ✅ |
| `CodeCitationPolicy` | **13 / 0 / 13** | 13/13 | ✅ |
| `DocPolicy` | **2 / 0 / 2** | — | ✅ |
| The gate itself | **22 passed / 0 failed / 4 skipped / 26**; anchor **hit=6 miss=0** | green, n=6 | ✅ |

Scan runtime 3.15s / 258 files. Acceptable.

---

## FAULT INJECTIONS — all red BY NAME, all reverted byte-identical

**MAJOR-5 (`.ts` unaccounted extension), verbatim:**
```
Expected 0, because extension(s) [.ts] appeared in the non-artifacts corpus with no
citation check and no declared exemption - decide: extend $CheckedExtensions or
$DeclaredExemptExtensions, do not leave it silent, but got 1.
```
Reverted via `git rm --cached` + delete + `git reset HEAD` → `git status` empty.

**MINOR-5 (precondition removed, `[A-Za-z0-9_]-$` → `-$`), verbatim:**
```
FAILED: a SPACE immediately before a trailing hyphen is NOT a wrap boundary (the prose-dash case, MINOR-5)
  MESSAGE: Expected $false, but got $true.
```
**The pin is non-vacuous.** Gate file sha256 `68C87BEB…B4BE` before and after — **identical**.

**Class A + MINOR-3 + MINOR-4 on the REAL corpus, verbatim:**
```
Class A: docs/friction-log.md:259 cites 'board/nonexistent-reviewer-probe.go:12' - NO SUCH FILE
         docs/friction-log.md:260 cites 'never-existed-probe.md:3' - NO SUCH FILE
Class B: docs/friction-log.md:261 cites 'README.md:99999' - target file has fewer lines
```
Line 260 is the fabricated elided citation (r1 silently exempted it); line 261 is an ambiguous basename out of range for all 4 `README.md` candidates (r1 waved it through). `docs/friction-log.md` sha256 `7FC915C9…32A4` before and after — **identical**.

---

## CALIBRATION DELTA — 192 → 188, arithmetic fully verified

I materialised the r1 tree via `git archive 3d76e65` into scratch and ran **both** scanner versions against **both** trees (597 tracked files each):

| | r1 scanner | r2 scanner |
|---|---|---|
| **r1 tree (3d76e65)** | A = **192** | D = **192** |
| **r2 tree (4aea118)** | C = **188** | B = **188** |

- **Scanner change is provably free:** `Compare-Object A D` = **0 differences**; `Compare-Object C B` = **0 differences**. Identical coordinate *sets*, not just counts, on both trees. The car's "measured free, identical set" claim is confirmed — and I verified it more strictly than the car did.
- **Content change removed exactly 4 coordinates, added zero:**

| # | Removed coordinate | Ruled fix |
|---|---|---|
| 1 | `docs/contracts/gating-matrix.md:49` → `board/server/sse.go:75-77` | MAJOR-3a |
| 2 | `docs/design/…design.md:97` → `…REJECT.md:66` | MAJOR-3b/MAJOR-4 |
| 3 | `docs/setup.md:42` → `repo-policy-check-patterns.md:57` | MAJOR-2 |
| 4 | `docs/specs/…spec.md:109` → `…REJECT.md:66` | MAJOR-3b/MAJOR-4 |

1+1+2 = 4, exactly as the header states. **No silent deletion of any checked citation; no silent addition.**

---

## OTHER MEASUREMENTS RE-DERIVED

| Claim | Re-derived | |
|---|---|---|
| 258 source files | 258 | ✅ |
| 209 spaced-dash lines | **209** | ✅ I initially measured 299 and **disproved my own suspicion**: 337 hyphen-terminated = 38 word-char boundaries + **209** spaced prose dashes + 90 markdown `---` rules |
| 8 naive-join false flags | **8**, and the three named examples reproduced verbatim (`atpoll.go`, `andschema/index-format.md`, `mirrorsscripts/Produce-Artifact.ps1`) | ✅ |
| 2 wrapped / 3 elided / 1 historical / 13 ambiguous | 2 / 3 / 1 / 13 | ✅ |
| anchor n=6, 6 hit 0 miss | hit=6 miss=0 | ✅ |
| `CodeCitationPolicy.Tests.ps1:288-308` | :288 = the completeness `It`; :308 = closing brace | ✅ |
| `.py` = PRESERVED WRECKAGE, header forbids editing | header reads "PRESERVED FAKE DEMONSTRATION … Do not … 'fix' the forgery - repairing it would destroy the fossil" | ✅ |
| Exemption probe counts `.expect(12) .png(6) .gitignore(3) .html(2) .sum(1) .py(1) .mod(1) .jsonl(1) .gitattributes(1)` + 1 extensionless (LICENSE) | **exact match**, and **all 10 groups measured zero coordinate-shaped matches** | ✅ |
| `setup.md`'s `:57` "was true at this row's writing" | `## Running them` at line 57 at **6152524**, **395aa9f**, **4f2ae97**; broke at **3d76e65** | ✅ honestly self-attributed |

---

## MAJOR FINDING

### MAJOR-R2-1 — The CORRECTION section asserts a measurable claim that is false, and the error runs in the direction of the author's own conclusion

Header lines 46-48:

&gt; "…and the content anchor **never even evaluates on any of the three** (zero backtick tokens on their citing lines)."

Measured with the **shipped** regex `` `([A-Za-z_][A-Za-z0-9_]{2,})` `` and the **shipped** matcher, against the real historical commits:

| Finding | Tokens on citing line | r1 `-match` | r2 `-cmatch` |
|---|---|---|---|
| MAJOR-1 `dom-writer.js:150` | **0** | not evaluated | not evaluated |
| **MAJOR-2 `design.md:611`** | **1 (`StalenessMs`)** | **HIT** (false pass) | **MISS → WOULD FLAG** |
| MAJOR-R2-2 `elapsedbucket_test.go:27` | **0** | not evaluated | not evaluated |

Citing line, verbatim: `` measured: `StalenessMs` ships at `15000` (`board/server/config.go:42`) against a shop ``

The claim is **false for one of the three**. Three aggravating factors:

1. **It contradicts the file's own MINOR-2 note** (lines 226-232), which describes exactly this token and exactly this `config.go:56` lowercase collision. The file states both that the anchor never evaluates these citations and that it false-hits on one of them.
2. **My r1 verdict told the car this**, in a table row reading `MAJOR-2 | … | false HIT (see MINOR-2)`. The information was in hand and the opposite was written.
3. **The error understates the evidence in the direction that supports the author's conclusion.** With round 2's own `-cmatch` fix, the anchor **would flag view-train MAJOR-2**. That makes the diagnostic **3-for-3 on real defects**, not 2-for-2 — and CHECK (c)'s report-only argument rests explicitly on "ZERO live miss examples anywhere in this corpus" and a revisit trigger calibrated on that record.

This is a checkable false claim written without checking, in the section whose own stated purpose is *"stated because repeating an unverified claim is exactly the defect class this gate exists to stop."* Law 1. The load-bearing conclusion (all three were in-range, so the BINDING checks miss them) is TRUE and fully verified — the defect is the supporting parenthetical, and the fix is two sentences.

**Required:** correct the parenthetical to "zero backtick tokens on two of the three citing lines; the third (`design.md:611`) carries `StalenessMs` and false-HIT under round 1's case-insensitive `-match`," and record the win — post-`-cmatch`, the anchor would flag MAJOR-2, a third true positive.

---

## MINOR FINDINGS

**MINOR-R2-1 — `drill.md` stated as "136 lines"; the gate's own authoritative method gives 137.** `@(Get-Content -Encoding UTF8).Count` = **137**; raw LF count = 136 (the file has no trailing newline). CHECK (b) at lines 214-223 declares newline-counting unreliable and mandates `.Count` — the header quotes the figure produced by the method it forbids. No functional impact (`:105`/`:110` in range either way). Carried unchanged from r1.

**MINOR-R2-2 — The closed set catches a NEW extension but never re-verifies a DECLARED-EXEMPT one.** Proven: `.ts` reds. Not covered: a `.html` or `.py` file that later acquires a citation is silently ignored forever, and the `''` reason names LICENSE specifically so a future `Dockerfile`/`Makefile` is silently covered. Every reason is TRUE today (I measured all 10 at zero matches), so this is a tightening, not a false claim. One loop asserting zero coordinate-shaped matches across declared-exempt files converts a landing-time probe into standing substrate — this repo's own probe doctrine ("a probe result is perishable; it becomes substrate only when it LANDS").

**MINOR-R2-3 — Latent wrong candidate list for an ambiguous *elided* citation.** Lines 643-654 route Elided coordinates through `Resolve-ElidedCitationTarget` and add them to both `$script:Elided` and the status bucket; the ambiguous report at lines 713-716 then re-resolves with `Resolve-CitationTarget` (exact-basename), which for `.../drill.md` returns `dead`/`$null` and would print `matches []`. Zero live instances (all 3 elided resolve `ok`), so latent — but the gate's value is accurate reporting.

---

## FULL-DIFF AUDIT

I read every changed line of the fix commit. Beyond MAJOR-R2-1, every new claim about coverage, provenance, verification, or completeness is measured and true — including all four citation conversions (each carries its own disclosure of why it was converted and who caught it), the setup.md provenance chain, the `writeSSEHeartbeat` symbol claim, the retained `design.md:133` `EventSource` citation (verified: D19 row names `EventSource`), all 10 exemption reasons, and the `1+1+2 = 4` arithmetic. **The car's self-attribution is honest throughout** — it names round 1 as the commit that broke `setup.md:42`, and names the round-2 reviewer rather than the gate as the finder of all three Class-B defects.

**Structural note (recommendation, not a finding):** the gate is self-excluded, so its ~340-line header is the one document in this repo exempt from its own discipline, carrying ~30 numeric claims nothing tests. Both r1's and r2's Majors live there. If round 3 again produces a false measurement claim in this prose, the instrument — hand-written measurement narrative — is the defect, and the remedy is to assert the load-bearing numbers **in the test** rather than narrate them in a comment.

---

## #13 FIELDS

**BASE-DELTA vs `4f2ae978d4628c67ee049a5c874961837cbf564f`:** 7 files — `.claude/hooks/run-session-start-guards.sh` (comment-only, verified 0 non-comment changed lines), 5 `.md` docs, 1 new `.ps1` gate. **No behavior change to board or harness:** no `.go`, `.js`, `.mjs`, `.css`, `.html`, `.json`, no schema, no CI workflow, no `scripts/*.ps1` outside `scripts/tests/`. Go 85/85 + vet clean and Node 129/129 confirm.

**#40 FLOOR: N/A with reason.** Verified via the file list above — no rendered surface in the cumulative diff (no CSS, JS, HTML, Go rendering path or template). No computed-style claim exists to drive through a browser. Verified-absent, not assumed-absent.

**UNREPRODUCIBLE-EVIDENCE:** none. Every measurement is re-runnable. Caveats: (a) my scanner comparisons load the shipped functions via `Invoke-Expression` on the real `BeforeAll` bodies (r1 lines 215-366, r2 lines 346-612), so all results exercise shipped code; (b) the r1 tree lives at `…/scratchpad/tree-3d76e65`, rebuildable with `git archive 3d76e65`.

---

## CONVERGENCE RULING

**CONVERGING — but the class is persistent. CAP: ONE more round.**

- Major counts: **5 → 1**, Minors **5 → 3**. Sharp decline.
- Swirl conditions: (a) counts declining — **NOT met** (strong decline); (b) findings cluster in the same section — **MET** (header claim-accuracy, as in r1); (c) the round's finding is a defect the previous round's fix created — **MET** (MAJOR-R2-1 is newly-written round-2 prose).

Two of three hold, so per calibration I set the cap rather than assume convergence continues. My judgment on the substance: this is **not relocation**. All ten r1 findings are mechanically, verifiably fixed, several with new non-vacuous pins I fault-injected myself. The single new Major is one inaccurate sentence inside an otherwise-excellent correction. But the *class* — asserting a measurable claim without measuring it — has now appeared in both rounds (r1: three instances; r2: one). **If round 3 produces another, escalate to the owner rather than dispatch round 4**, and treat the header's untested measurement prose as the instrument defect.

---

## RECOMMENDED #65 SCOPE SENTENCE (for the eventual close, once MAJOR-R2-1 is fixed)

&gt; **#65 lands a mechanical citation-resolver gate (`scripts/tests/CitationResolverPolicy.Tests.ps1`, CI-auto-discovered) that BINDS two classes across all 188 `file:line` coordinates in the 258 tracked non-artifacts source files: Class A dead paths (single-line and line-wrapped, unwrapping across mid-compound hyphens and directory slashes) and out-of-range line numbers, including inside the ellipsis and ambiguous-basename buckets. It does NOT catch in-range shifted citations — a line that drifted but still points inside the file — which is the class behind view-train MAJOR-1, MAJOR-2 and MAJOR-R2-2; those remain review-attention-tier, with a content-anchor diagnostic landed REPORT-ONLY (n=6, 6/6 hit) carrying a numeric trigger to bind at n&gt;20 or at the first confirmed-benign miss. Closed-set self-calibration reds by name when a new citing file type appears.**

---

## CONSTITUTION CHECK

| Law / doctrine | Status |
|---|---|
| **Law 1 (no confident falsehood)** | **VIOLATED, once** — MAJOR-R2-1. Down from four instances in r1. |
| **Living documents (same-commit truth)** | **HONORED** — r1's MAJOR-2 breakage repaired; no document left stale by this diff (I re-swept the gate file's own citations; the only two "dead" hits are the deliberately-quoted stale paths the self-exclusion comment names). |
| **Probe doctrine (run, don't read)** | **HONORED** — the four citation conversions, the exemption probes, the naive-join and set-equality measurements are all reproducible and all reproduced exactly. One lapse: MAJOR-R2-1's parenthetical was written rather than run. |
| **Healing Loop (mechanism over attention)** | **HONORED and advanced** — MINOR-1/3/4/5 and MAJOR-5 all landed as *pinned tests*, not prose. I fault-injected four of them. |
| **Red-by-name / non-vacuity** | **HONORED** — proven by four independent injections, quoted verbatim. |
| **Severity philosophy** | **HONORED** — 0 false flags on the real corpus; naive joining measured at 8 false flags, confirming the precondition earns its keep. |
| **Blameless / not vague** | Applied — the car's self-attribution of r1's breakage is exemplary and recorded as a win. |
| **Cars never push** | **HONORED** — one local commit. |

---

**This is a strong, honest round.** Every one of ten r1 findings is genuinely fixed, four with pins I broke myself to confirm they bite, and the calibration arithmetic survived the most rigorous check I could construct. It is rejected for a single false sentence in the section written to stop false sentences — a two-sentence fix that also lets the car record a win it currently argues against.

**Files:** `<repo>-wt\review-tooling-65\scripts\tests\CitationResolverPolicy.Tests.ps1` (lines 46-48 = MAJOR-R2-1; line 300 = MINOR-R2-1; lines 354-365 = MINOR-R2-2; lines 713-716 = MINOR-R2-3), `<repo>-wt\review-tooling-65\docs\setup.md`, `<repo>-wt\review-tooling-65\docs\contracts\gating-matrix.md`, `<repo>-wt\review-tooling-65\docs\design\2026-07-22-dispatch-harness-design.md`, `<repo>-wt\review-tooling-65\docs\specs\2026-07-22-dispatch-harness-spec.md`, `<repo>-wt\review-tooling-65\board\server\sse.go`

```starcar-artifact
outcome: REJECT
task-id: tooling-65-review-r2
findings: 1 Major, 3 Minor (round 1 was 5 Major, 5 Minor)
  MAJOR-R2-1: The ROUND-1/ROUND-2 CORRECTION section, gate file lines 46-48, asserts "the content anchor never even evaluates on any of the three (zero backtick tokens on their citing lines)". Measured with the shipped backtick regex and the shipped matcher against the real historical commits, this is FALSE for one of the three. View-train MAJOR-2's citing line, docs/design/2026-07-21-v0-yard-skeleton-design.md:611 at 3076a40, reads "measured: StalenessMs ships at 15000 (board/server/config.go:42) against a shop" and carries exactly one backtick token, StalenessMs. Under round 1's -match it HIT and false-passed; under round 2's own -cmatch fix it MISSES and WOULD FLAG. Three aggravating factors. It contradicts the same file's MINOR-2 note at lines 226-232, which describes this exact token and the config.go:56 lowercase collision. Round 1's verdict told the car this in a table row reading "MAJOR-2 - false HIT (see MINOR-2)". And the error runs in the direction of the author's own conclusion: post-fix the anchor would flag MAJOR-2, making the diagnostic 3-for-3 on real defects rather than 2-for-2, while CHECK (c)'s report-only argument rests explicitly on "ZERO live miss examples anywhere in this corpus". A checkable claim written without checking, inside the section whose stated purpose is to stop exactly that. The load-bearing conclusion (all three were in-range so the binding checks miss them) is TRUE and fully verified; the defect is the supporting parenthetical, and the fix is two sentences.
  MINOR-R2-1: drill.md stated as "136 lines" in the calibration section. The gate's own authoritative method, Get-Content .Count, gives 137; the raw LF count is 136 because the file has no trailing newline. CHECK (b) at lines 214-223 declares newline-counting unreliable and mandates .Count, so the header quotes the figure produced by the method it forbids. No functional impact, both cited lines in range either way. Carried unchanged from round 1.
  MINOR-R2-2: The closed set catches a NEW extension, proven by my .ts fault injection, but never re-verifies a DECLARED-EXEMPT one. A .html or .py file that later acquires a citation is silently ignored forever, and the empty-string reason names LICENSE specifically so a future Dockerfile or Makefile is silently covered. All ten exemption reasons are TRUE today, measured at zero coordinate-shaped matches, so this is a tightening rather than a false claim. One loop asserting zero matches across declared-exempt files converts a landing-time probe into standing substrate.
  MINOR-R2-3: Latent wrong candidate list for an ambiguous elided citation. Lines 643-654 resolve Elided coordinates via Resolve-ElidedCitationTarget and add them to both the Elided and the status bucket; the ambiguous report at lines 713-716 re-resolves with Resolve-CitationTarget's exact-basename lookup, which for a suffix token like drill.md returns dead with a null path and would print "matches []". Zero live instances today.
abstract: |
  Delta re-review at 4aea118, parent 3d76e65, detached worktree, byte-clean in and out. All ten round-1 findings walked as a table: five Majors and five Minors, every one ABSENT and genuinely fixed, zero DRIFTED.
  Suites run myself. scripts/tests 216 passed / 0 failed / 5 skipped / 221, reconciling with the car's attached-branch 217/0/4/221 by the branch-attached #50 skip. scripts/probes 24/24, Go 85 PASS 0 FAIL with go vet clean, Node 129/129 twice, probe-yard-snapshot PASS, CodeCitationPolicy 13/13, DocPolicy 2/2, the gate itself 22 passed / 0 failed / 4 skipped / 26 with the anchor at hit 6 miss 0.
  Four fault injections, all red BY NAME and all reverted byte-identical with sha256 stated. The .ts unaccounted-extension injection reds naming .ts. Removing the word-char precondition reds the MINOR-5 unit test, proving the pin non-vacuous. On the real corpus, a dead path, a fabricated elided citation and an ambiguous basename out of range for all four README.md candidates all red by name, the last two being cases round 1 silently waved through.
  The calibration delta was verified by materialising the round-1 tree via git archive and running BOTH scanner versions against BOTH trees. The scanner change is provably free: zero set differences on either tree, not merely equal counts. The content change removed exactly four coordinates and added none, and the four are exactly the four ruled fixes, 1+1+2 as the header states. Independently re-derived: 258 files, 209 spaced-dash lines, 8 naive-join false flags with the three named examples reproduced verbatim, all ten exemption groups at zero matches with counts matching the header's probe exactly, and the setup.md provenance chain true at 6152524, 395aa9f and 4f2ae97 and broken at 3d76e65, honestly self-attributed by the car. I also disproved one of my own suspicions: an initial 299 for the spaced-dash count was my conflation, and the car's 209 is exact.
  One Major. The correction section written to stop unverified claims contains one, and it understates the car's own instrument in the direction of the car's own conclusion.
  CONVERGENCE: converging strongly, 5 Majors to 1, all prior findings closed with mechanisms rather than prose. Two of three swirl conditions hold, clustering in the same section and a defect created by the previous round's own fix, so I set a CAP of ONE more round: if round 3 again produces a false measurement claim in this file's prose, escalate to the owner and treat the self-excluded header's untested measurement narrative as the instrument defect. A recommended honest scope sentence for the #65 close is stated in the verdict.
```