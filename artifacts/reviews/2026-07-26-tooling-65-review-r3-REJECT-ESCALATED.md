<!-- starcar-integrity: sha256=ec20f72cc60fceb8ddf3176568cd573694cacd242d6fb76e66eb659579c9cec8 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Tooling train #65 citation-resolver gate review, round 3 (capped - ESCALATED)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial delta re-review, capped round, swirl escalation
Round: 3
Target: `car/tooling-65 HEAD 63a5c55 (fix commit on 4aea118)`
Base reviewed: `4f2ae978d4628c67ee049a5c874961837cbf564f`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT-ESCALATED**

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

Confirmed. That single sentence contains three separate defects. I have everything I need.

---

# DELTA RE-REVIEW VERDICT — tooling train #65, round 3 (THE CAPPED ROUND)

## VERDICT: **REJECT — AND ESCALATE TO OWNER.** My r2 cap fires. 2 Major, 2 Minor.

**Base verified.** HEAD `63a5c55adb7e4bca7e59fc5d0819148f88ef27b1`, parent `4aea118a…`, clean. `git diff --stat 4aea118..63a5c55` = **1 file changed**, `scripts/tests/CitationResolverPolicy.Tests.ps1` only — the car's scope claim holds. Nothing committed or pushed. Worktree byte-clean at exit; all three fault injections reverted with sha256 confirmed identical.

---

## THE CAP FIRES

My r2 verdict set a binding cap: *"If round 3 again produces a false measurement claim in this file's prose, escalate to the owner and treat the self-excluded header's untested measurement narrative as the instrument defect."*

It did. **And it did so inside the very sentence written to fix round 2's false claim.** One sentence, header lines 60-64, contains three separate defects:

```
THE WIN THIS RECORDS: post-`-cmatch`,
this content anchor would have flagged ALL THREE of the view train's named findings as
misses, not zero - a 3-for-3 true-positive record on real defects, pinned as a
fixture below (`Test-ContentAnchorHit`'s "reproduces the historical config.go:42
false-hit/true-miss pair" case) rather than left as prose.
```

Measured with the **shipped** helpers (`Get-ContentAnchorTokens`, `Test-ContentAnchorWindow`) against the real historical commits:

| View-train finding | Tokens on citing line | `-match` (r1) | `-cmatch` (production) | Would the anchor flag it? |
|---|---|---|---|---|
| MAJOR-1 `dom-writer.js:150` → `schema:191` @3076a40 | **0** | — | — | **NO — never evaluated** (`if ($tokens.Count -eq 0) { continue }`) |
| MAJOR-2 `design.md:611` → `config.go:42` @3076a40 | 1 (`StalenessMs`) | HIT | **MISS** | **YES** |
| MAJOR-R2-2 `elapsedbucket_test.go:27` → `dom-writer.js:201` @6346d7d | **0** | — | — | **NO — never evaluated** |

**One of three, not all three.**

---

## MAJOR FINDINGS

### MAJOR-R3-1 — "would have flagged ALL THREE" is false, and contradicts its own paragraph two sentences earlier

Header lines 60-62. The same paragraph states, at lines 49-51, that `dom-writer.js:150` "carries no backtick token" and `elapsedbucket_test.go:26-27` "carries none either" — both verified true. A zero-token citation is neither hit nor miss; the production loop `continue`s past it. It cannot be "flagged as a miss."

The paragraph therefore asserts and denies the same fact within twelve lines. The closing sentence compounds it: *"it was RIGHT … about what the content anchor … already could"* — rehabilitating the #28+#12 round-2 verdict's three-finding claim on a reach the anchor does not have.

**What is actually true, and is a real win worth stating:** the anchor's *miss set* — `sse.go:77`, `REJECT.md:66`, `config.go:42` — is 3 misses, all 3 confirmed real defects, a **3-for-3 precision record**. CHECK (c)'s own wording (lines ~262-270, *"3-FOR-3 true positives across every citation this gate's own header ever named"*) is defensible and I verified it. The CORRECTION section's wording is not: it converts a precision claim into a coverage claim.

### MAJOR-R3-2 — A dead symbol citation, in the citation gate's own header, invisible to it by self-exclusion

The same sentence cites `` `Test-ContentAnchorHit` `` and an It named `"reproduces the historical config.go:42 false-hit/true-miss pair"`.

```
$ grep -rn "Test-ContentAnchorHit" --include=*.ps1 .
./scripts/tests/CitationResolverPolicy.Tests.ps1:63:# fixture below (`Test-ContentAnchorHit`'s "reproduces the historical config.go:42
```

**The symbol exists nowhere but in the sentence citing it.** The real helpers are `Get-ContentAnchorTokens` (line 615) and `Test-ContentAnchorWindow` (line 624); the real Describe is `'Content-anchor 3-for-3 historical record (#65 round 3, MAJOR-R2-1)'` (line 881), and no It carries the quoted name.

This is a **Class A dead citation inside the Class A gate**, and the gate cannot see it because `Get-CheckedSourceFiles` excludes its own path. It is the exact shape of round 1's MAJOR-2 — a commit breaking a citation while the gate passes green over it — reproduced one level in.

---

## MINOR FINDINGS

**MINOR-R3-1 — "nowhere near *either* `StalenessMs` occurrence"** (line 58) names two (`:14`, `:63`); there are **three** at `3076a40` — `:14`, `:63`, and `:97` (`cfg.StalenessMs = n`). All three are outside the `:42` ±15 window (27..57), so the conclusion holds and the `-cmatch` miss is correct. The enumeration is incomplete, not the reasoning.

**MINOR-R3-2 — "moves the header's 3-for-3 claim from prose to a pinned assertion" overstates what is pinned.** The fixture is a synthetic in-memory reproduction of the MAJOR-2 case's *structural shape* (honestly disclosed as such). It pins one of the three legs. The `sse.go:77` and `REJECT.md:66` legs remain prose-only.

---

## R2 FINDING DISPOSITION

| ID | Status | Evidence |
|---|---|---|
| **MAJOR-R2-1** | **DRIFTED** | The named defect is genuinely fixed — all three sub-claims now measured and true (0 tokens / 0 tokens / 1 token `StalenessMs`, `-match` HIT, `-cmatch` MISS, all re-derived by me), the record is pinned in a new Describe, and the helpers are **shared not duplicated** (Law 6 honored: the production It now calls `Get-ContentAnchorTokens`/`Test-ContentAnchorWindow`; the local `$backtickRe` was removed). **But the replacement text acquired a new false claim of the same class** — MAJOR-R3-1/R3-2. The words moved; the substance recurred. |
| **MINOR-R2-1** | **ABSENT (fixed)** | Re-derived: `Get-Content .Count` = **137**, LF count = **136**, `ends with newline = False`. The header's new text — including the `wc -l` undercount explanation — is exactly right. |
| **MINOR-R2-2** | **ABSENT (fixed)** | Standing re-verification It + `$DeclaredExemptExtensionlessFiles = @('LICENSE')` allowlist. **Both fault-injected red by name** (below). The `NOT Mandatory` design note is a correct behavioural claim — I probed it: `[Parameter(Mandatory)][string[]]` throws *"Cannot bind argument to parameter 'Vals' because it is an empty string"* on `@('.go','')`; the non-Mandatory form accepts it. |
| **MINOR-R2-3** | **ABSENT (fixed)** | Ambiguous-elided now routes through `Resolve-ElidedCitationTarget`; scratch fixture 11 asserts both real candidates (`subA/report-thing.md`, `subB/summary-thing.md`) print rather than `matches []`. |

---

## SUITES at `63a5c55` — run myself

| Suite | Observed | Car claimed | |
|---|---|---|---|
| The gate | **28 passed / 0 failed / 4 skipped / 32** | green | ✅ all 6 new round-3 tests present and passing |
| `scripts/tests` | **222 / 0 / 5 skipped / 227** | 223/0/4/227 attached | ✅ 222+5 = 223+4 = 227 |
| `scripts/probes` | **24 / 0 / 24** | — | ✅ |
| `CodeCitationPolicy` | **13 / 0 / 13** | 13/13 | ✅ |
| Go + `go vet`, Node, `probe-yard-snapshot.mjs` | **not re-run — skip is SOUND** | car's rationale | ✅ Verified: `git diff --name-only` = one `.ps1` test file. No Go, JS, CSS, schema or workflow touched. I personally observed Go **85/85 + vet clean**, Node **129/129**, probe **PASS** at `4aea118`; nothing in this diff can reach them. |

**Carried-forward totals re-derived at HEAD: 258 source files, 188 coordinates** — exactly as the header states. I could not replay the car's temporary-diagnostic revert, but the numbers are correct at HEAD and the diff shows no diagnostic residue.

---

## FAULT INJECTIONS — 3, all red BY NAME, all byte-identical reverts

**1. New 3-for-3 pin** (`-cmatch` → `-match` in the shared helper):
```
FAIL: the case-SENSITIVE match (round 2's -cmatch, the production choice) correctly MISSES - the real defect this diagnostic would have caught
MESSAGE: Expected $false, but got $true.
```
Gate sha256 `93A95EAE…1742` before and after — **identical**.

**2. Declared-exempt file acquires a citation** (appended to `board/web/index.html`):
```
FAIL: every DECLARED-EXEMPT extension is re-verified, standing, …
MESSAGE: Expected $null or empty, but got 'board/web/index.html (extension .html) now carries a coordinate-shaped match - re-evaluate its exemption'.
```
`index.html` sha256 `FA19400A…FF6E` before and after — **identical**.

**3. New extensionless file** (`Dockerfile`, staged) — **two** tests red:
```
MESSAGE: 'Dockerfile (extension ) now carries a coordinate-shaped match - re-evaluate its exemption'
MESSAGE: extensionless file(s) [Dockerfile] are not in the declared allowlist ($script:DeclaredExemptExtensionlessFiles = LICENSE only) - a new extensionless file shares the '' extension but not LICENSE's exemption reason; decide and add it explicitly, do not let it ride LICENSE's coattails
```
Index reset, file removed, `git status --porcelain` empty.

**Round 3's code is excellent.** Six new tests, every one non-vacuous under my own injection, Law 6 honored, a correctly-probed PowerShell edge case. I want that on the record separately from the verdict.

---

## CONVERGENCE RULING — ALL THREE SWIRL CONDITIONS NOW HOLD

| Condition | r1 → r2 → r3 | |
|---|---|---|
| Major counts stop declining | 5 → 1 → **2** | **MET** (no longer declining; now risen) |
| Findings cluster in the same section | header narrative, all three rounds | **MET** |
| A round's findings are defects the previous round's own fixes created | r2's M1 was r1's new prose; r3's M1/M2 are r2's fix's new prose | **MET** |

CLAUDE.md: *"The third is the sharpest - it means the defect is being RELOCATED, not resolved."* That is precisely what the record shows. Across three rounds the **code** has converged beautifully — every one of ten r1 findings and three of four r2 findings closed with pinned, fault-injected mechanisms — while the **prose** has produced a false claim in every single round: r1 three (`"this gate is that mechanism"`, `"neither confirmed a real defect"`, `"matches the citing text exactly"`), r2 one (`"never even evaluates on any of the three"`), r3 two.

---

## THE INSTRUMENT DEFECT, NAMED (for the owner)

**A ~360-line hand-written measurement narrative sits in the one file in this repo that is exempt from every mechanical check in the repo.**

The self-exclusion is *correct and necessary* — the gate's fixtures must contain coordinate-shaped strings, so scanning itself would flag them. But the consequence is that the densest concentration of file:line citations and measurement claims in the codebase has no gate over it, and MAJOR-R3-2 is the proof: a dead symbol citation now lives in the citation gate's own header, and the citation gate cannot see it.

This is the repo's own doctrine going unapplied to itself, in three places at once:
- **"Match the instrument to the artifact"** — prose is the wrong instrument for a measurement record. The car has been *applying* this correctly to the code (moving the record into a fixture is exactly right) while simultaneously maintaining a narrative summary of the same record.
- **Law 6 (second copies)** — the header narrative is a hand-maintained second copy of what the fixtures now assert, and it drifted from them *within the same commit*.
- **"Validated facts must land as tests or gates, never only prose."**

**Three options for the owner; I do not own this call:**
- **(a) Amputate.** Cut the header to binding rules + a pointer to the tests. The fixtures already carry the load. Highest confidence, loses narrative provenance.
- **(b) Assert the numbers.** Keep the narrative but make the load-bearing figures (258/188/13/3/1, n=6) assertions that red on drift, and drop the historical narrative entirely.
- **(c) Reclassify the header as non-normative.** Cheapest, but the NORTH STAR forbids it — documentation ranks equal to code.

I recommend (a) or (b). Round 4 as another prose-correction round would be the fourth attempt to fix prose with prose.

---

## DELIVERABLES (verified, usable whichever way the owner rules)

**If the owner rules to land after a prose remedy, the verified numbers are:**

&gt; Suites at final HEAD: `scripts/tests` **222 passed / 0 failed / 5 skipped / 227** (detached; 223/0/4/227 attached), `scripts/probes` **24/24**, `CodeCitationPolicy` **13/13**, the gate **28/0/4/32**, Go **85/85** + `go vet` clean and Node **129/129** and `probe-yard-snapshot.mjs` **PASS** at `4aea118` (untouched by this diff). Gate history: **r1 REJECT 5M/5m → r2 REJECT 1M/3m → r3 REJECT 2M/2m, escalated on the reviewer's standing cap.**

**FINAL #65 scope sentence for the ticket close:**

&gt; **#65 lands a mechanical citation-resolver gate (`scripts/tests/CitationResolverPolicy.Tests.ps1`, CI-auto-discovered, ~3s) that BINDS two defect classes across all 188 `file:line` coordinates in the 258 tracked non-artifacts source files: Class A dead paths — single-line and line-wrapped, unwrapping across mid-compound hyphens and directory slashes — and out-of-range line numbers, including inside the ellipsis-elided and ambiguous-basename buckets. It does NOT catch in-range shifted citations, the class behind view-train MAJOR-1, MAJOR-2 and MAJOR-R2-2, which remain review-attention-tier. A content-anchor diagnostic ships REPORT-ONLY (n=6, 6/6 hit on the current corpus) with a 3-for-3 precision record on its historical misses and a numeric trigger to bind at n&gt;20 or at the first confirmed-benign miss. Closed-set self-calibration reds by name when a new citing file type appears, a standing check re-verifies every declared-exempt extension still carries zero coordinates, and the extensionless exemption is allowlisted to LICENSE by path. KNOWN GAP: the gate excludes its own file, so its header's citations and measurement claims are ungated — three rounds of review found five false claims there.**

---

## CONSTITUTION CHECK

| Law / doctrine | Status |
|---|---|
| **Law 1 (no confident falsehood)** | **VIOLATED** — MAJOR-R3-1 (false coverage claim), MAJOR-R3-2 (dead symbol citation). Fifth and sixth instances across three rounds, all in the same artifact. |
| **Law 6 (no second copies)** | **HONORED in code** — helpers genuinely shared, `$backtickRe` duplicate removed. **VIOLATED in prose** — the header narrative is a hand-maintained second copy of the fixtures' assertions and drifted from them in the same commit. |
| **Match the instrument to the artifact** | **VIOLATED** — the core escalation finding. |
| **Healing Loop (mechanism over attention)** | **HONORED, strongly** — 6 new tests, all fault-injected non-vacuous by me. |
| **Probe doctrine** | **HONORED in code** (the `Mandatory` empty-string claim is correctly probed and true — I re-ran it). **VIOLATED in prose** — "ALL THREE" was written, not run, with the shared helper sitting in the same file. |
| **Living documents** | **HONORED** — no external document invalidated; single-file diff. |
| **Swirl escalation** | **HONORED by this verdict** — all three conditions met, cap honored, escalated rather than iterated. |
| **Cars never push** | **HONORED.** |

**The code is ready. The prose is not, and a fourth prose-correction round is the wrong instrument.** This escalation is about the artifact's shape, not the car's competence — which round 3's six pinned, non-vacuous tests demonstrate plainly.

**Files:** `<repo>-wt\review-tooling-65\scripts\tests\CitationResolverPolicy.Tests.ps1` (lines 60-62 = MAJOR-R3-1; line 63 = MAJOR-R3-2; line 58 = MINOR-R3-1; line 889 = MINOR-R3-2; lines 615/624 = the real helpers; line 881 = the real Describe)

```starcar-artifact
outcome: REJECT-ESCALATED
task-id: tooling-65-review-r3
findings: 2 Major, 2 Minor - reviewer cap fired, escalated to owner (r1 5M/5m, r2 1M/3m, r3 2M/2m)
  MAJOR-R3-1: Header lines 60-62 claim "post-cmatch, this content anchor would have flagged ALL THREE of the view train's named findings as misses, not zero". Measured with the shipped Get-ContentAnchorTokens and Test-ContentAnchorWindow helpers against the real historical commits: dom-writer.js:150 carries ZERO backtick tokens and elapsedbucket_test.go:27 carries ZERO, so the production loop continues past both and they are neither hit nor miss; only design.md:611 (token StalenessMs) misses under -cmatch and would be flagged. One of three, not all three. The same paragraph asserts and denies this within twelve lines, since lines 49-51 correctly state that two of the three carry no backtick token. The closing sentence compounds it by declaring the view train's round-2 verdict RIGHT about the anchor's reach. The defensible claim, which CHECK (c) states correctly, is a 3-for-3 PRECISION record on the anchor's miss set (sse.go:77, REJECT.md:66, config.go:42, all three real defects); the CORRECTION section converts that precision claim into a coverage claim it does not support.
  MAJOR-R3-2: The same sentence, header line 63, cites a fixture called Test-ContentAnchorHit and an It named "reproduces the historical config.go:42 false-hit/true-miss pair". Neither exists. grep across all .ps1 files finds Test-ContentAnchorHit only in the line citing it. The real helpers are Get-ContentAnchorTokens at line 615 and Test-ContentAnchorWindow at line 624; the real Describe is "Content-anchor 3-for-3 historical record (#65 round 3, MAJOR-R2-1)" at line 881, and no It carries the quoted name. This is a Class A dead citation inside the Class A gate, invisible because Get-CheckedSourceFiles excludes the gate's own path - the same shape as round 1's MAJOR-2, one level in.
  MINOR-R3-1: Header line 58 says "nowhere near either StalenessMs occurrence" and names two, :14 and :63. There are three at 3076a40; :97 (cfg.StalenessMs = n) is omitted. All three sit outside the :42 plus-or-minus-15 window of lines 27 to 57, so the reasoning and the -cmatch miss are correct; only the enumeration is incomplete.
  MINOR-R3-2: Line 889 says the change "moves the header's 3-for-3 claim from prose to a pinned assertion". The fixture is a synthetic in-memory reproduction of the MAJOR-2 case's structural shape, honestly disclosed as such, and pins one of the three legs. The sse.go:77 and REJECT.md:66 legs remain prose-only.
abstract: |
  Capped-round delta re-review at 63a5c55, parent 4aea118, single file changed (scripts/tests/CitationResolverPolicy.Tests.ps1), detached worktree, byte-clean in and out.
  THE CAP FIRED. My round-2 verdict set a binding cap: if round 3 again produced a false measurement claim in this file's prose, escalate to the owner and name the header's untested narrative as the instrument defect. It did, in the very sentence written to fix round 2's false claim, and that one sentence carries two separate Major defects - a false coverage claim measured wrong (one of three, not all three) and a dead symbol citation to a Test-ContentAnchorHit that exists nowhere but in the sentence citing it.
  Round 3's CODE is excellent and I want that recorded separately. Three of the four round-2 findings are cleanly ABSENT: drill.md is now 137 by the mandated method with the wc -l undercount explained (re-derived exactly, LF count 136, no trailing newline); the declared-exempt standing re-verification and the LICENSE-only extensionless allowlist both exist and both red BY NAME under my fault injection; the elided-ambiguous report routes through the suffix resolver and its fixture proves real candidates print. Law 6 is honored - Get-ContentAnchorTokens and Test-ContentAnchorWindow are shared with the production check, not duplicated, and the old local regex was removed. The PowerShell Mandatory-rejects-empty-string design note is a correct behavioural claim which I re-probed and confirmed. Six new tests, every one proven non-vacuous by my own injections.
  Suites at HEAD, run myself: the gate 28 passed / 0 failed / 4 skipped / 32; scripts/tests 222 / 0 / 5 skipped / 227, reconciling with the car's attached 223/0/4/227; scripts/probes 24/24; CodeCitationPolicy 13/13. Carried-forward totals re-derived exactly at HEAD: 258 source files, 188 coordinates. The Go, Node and schema-probe skip is SOUND - the diff is one .ps1 test file, and I personally observed Go 85/85 with vet clean, Node 129/129 and probe PASS at 4aea118.
  Three fault injections, all red BY NAME, all reverted byte-identical with sha256 stated: flipping -cmatch to -match in the shared helper reds the new pin for its stated reason; a citation appended to a declared-exempt .html file reds naming the file and extension; a new extensionless Dockerfile reds TWO tests and is explicitly refused LICENSE's exemption reason.
  CONVERGENCE: all three swirl conditions now hold. Major counts 5 then 1 then 2, no longer declining. Findings cluster in the same section every round. And each round's Majors are defects the previous round's own fix created - the sharpest condition, meaning the defect is being relocated rather than resolved. Across three rounds the code converged beautifully while the prose produced a false claim every single time: three in round 1, one in round 2, two in round 3.
  THE INSTRUMENT DEFECT, NAMED: a roughly 360-line hand-written measurement narrative sits in the one file exempt from every mechanical check in the repo. The self-exclusion is correct and necessary, but its consequence is that the densest concentration of citations and measurement claims in the codebase has no gate over it, and MAJOR-R3-2 proves it - a dead citation now lives in the citation gate's own header and the gate cannot see it. Three options offered to the owner, amputate the narrative, assert the numbers as tests, or reclassify the header as non-normative; I recommend the first or second and note the third is forbidden by the NORTH STAR. A fourth round would be the fourth attempt to fix prose with prose.
  Verified merge-message numbers and a final #65 scope sentence, including the honest known-gap clause about the ungated header, are supplied in the verdict for whichever way the owner rules.
```