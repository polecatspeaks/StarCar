<!-- starcar-integrity: sha256=9213837f269737aeeb84a0390bc2bfe0ed5ea4260fd4dddcb74f1ad668983dc0 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Tooling train #65 citation-resolver gate review, round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial review
Round: 1
Target: `car/tooling-65 HEAD 3d76e65`
Base reviewed: `4f2ae978d1e5a1a06e5d02cc07d747e70da2b2ee`
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
| Base commit the reviewer read (**the lookup key**) | `4f2ae978d1e5a1a06e5d02cc07d747e70da2b2ee` |

| Dispatch, the locator within the session | `a965df3347dae4a72` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 4f2ae978d1e5a1a06e5d02cc07d747e70da2b2ee
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

---

# ADVERSARIAL REVIEW VERDICT — tooling train #65, round 1

## VERDICT: **REJECT** — 5 Major, 5 Minor

**Base verified.** `<repo>-wt\review-tooling-65`, detached at `3d76e6506cefa56f5082ddcccf438fb14b1e6317`, parent `4f2ae97`, `git status --porcelain` empty at entry and at exit. Nothing edited, committed, or pushed; both fault injections reverted byte-identical (sha256 below).

---

## SUITES — run myself at `3d76e65`

| Suite | Observed | Car claimed | Reconciliation |
|---|---|---|---|
| `scripts/tests` (full Pester) | **205 passed / 0 failed / 5 skipped / 210 total** | 206/0/4/210 attached | ✅ Extra skip is `run-session-start-guards.sh: agent-pull runner (#50)` — the branch-attached test. 205+5 = 206+4 = 210 |
| `scripts/probes` | **24 passed / 0 failed / 24 total** | 24/24 | ✅ |
| Go `board/...` | **85 PASS / 0 FAIL / 0 SKIP**; `go vet ./...` clean | 85/85 | ✅ |
| Node `board/web` | **129 tests / 129 pass / 0 fail** (3 consecutive runs) | 129/129 | ✅ First run showed 2 browser failures; CI's `npx playwright install --with-deps --only-shell chromium` (`.github/workflows/ci.yml:335`) was skipped locally. Transient — flake, per CLAUDE.md calibration |
| `probe-yard-snapshot.mjs` | **PROBE RESULT: PASS**, exit 0 | PASS | ✅ |
| `CodeCitationPolicy.Tests.ps1` | **13 passed / 0 failed / 13** | 13/13 | ✅ New file cited `#65` at lines 2, 15, 197 |
| `DocPolicy.Tests.ps1` | **2 passed / 0 failed / 2** | — | ✅ |
| The gate itself | **11 passed / 0 failed / 4 skipped / 15** | green | ✅ (see environment note below) |

**Environment note worth recording:** my first gate run reported RED with 3 Class A flags. Cause: the gate derives `RepoRoot` from `git rev-parse --show-toplevel` against the *ambient process CWD*, which was the shared checkout, not the worktree. **Not a car defect** — it is the house idiom (`CodeCitationPolicy.Tests.ps1:203`, `DocPolicy.Tests.ps1:24`), and CI runs from the repo root. Recorded because it produced a genuine bonus observation: pointed at the pre-`#65` corpus, the gate flagged exactly the 3 real Class A dead paths by name, independent corroboration that Class A detection is real.

---

## CALIBRATION — every number re-derived independently

| Claim | Re-derived | |
|---|---|---|
| 258 source files scanned | **258** | ✅ exact |
| 192 coordinates | **192** | ✅ exact |
| Wrapped: 2, both named | **2**, exactly `board/web/test/sse-protocol.test.js:8-9` and `docs/design/2026-07-21-v0-yard-skeleton-design.md:585-586` | ✅ exact |
| Elided: 3 | **3** | ✅ |
| Historical: 1 | **1** | ✅ |
| Ambiguous: 13 | **13** | ✅ |
| Anchor n=9 (7 hit / 2 miss) | **hit=7, miss=2** | ✅ exact |
| `algorithm.go` 266 by `.Count`, 239 by `Measure-Object -Line` | **266 / 239** | ✅ exact — genuinely good probe work |
| `board/server/storepath.go:28` implements `.../` truncation | line 28 = `return ".../" + filepath.ToSlash(filepath.Base(absPath))` | ✅ (header paraphrases, substance true) |
| `repo-policy-check-patterns.md` §3 quote | verbatim at L70-72 | ✅ |

The car's arithmetic is **impeccable**. Every measurement it reported is reproducible to the unit. The Majors below are not about the numbers; they are about the **conclusions drawn from them**.

---

## NON-VACUITY — fault injection at HEAD, observed red BY NAME

Injected into `docs/friction-log.md` (tracked, so `git ls-files` picks it up).

**Class A + Class C, verbatim from the failure:**
```
Expected $null or empty, but got 'docs/friction-log.md:259 cites 'board/nonexistent-reviewer-probe.go:12' - NO SUCH FILE
docs/friction-log.md:260-261 cites 'docs/reviewer-probe-missing-file.md:404' - NO SUCH FILE'.
```
Class C correctly reports the `260-261` span. **Both classes proven non-vacuous.**

**NEGATIVE CONTROL — the decisive one.** Injected a Class B shifted-but-in-range citation (`schema/yard-snapshot.schema.json:5` claimed to define `storePathDisplay`; line 5 is the schema's top-level `description`):
```
NEGATIVE CONTROL RESULT -&gt; Passed:11 Failed:0 Skipped:4
```
**The gate is fully GREEN on the exact defect shape of view-train MAJOR-1.**

**Byte-clean revert:** sha256 `7FC915C92C0218B3199B02EC8462A5B2BC23948CAEF7293297415CD177BD32A4` before injection and after final revert — **identical**. `git status --porcelain` empty.

---

## MAJOR FINDINGS

### MAJOR-1 — The gate does not catch the class that justified the ticket, and its own header says it does

`CitationResolverPolicy.Tests.ps1:4-16` quotes round 2's verdict — *"would have caught MAJOR-1, MAJOR-2 and MAJOR-R2-2 mechanically"* — and then states **"This gate is that mechanism."**

I tested all three at their actual defect commits:

| Finding | Coordinate | Detected? | Class A | Class B range | Anchor (report-only) | **Caught?** |
|---|---|---|---|---|---|---|
| MAJOR-1 | `schema/yard-snapshot.schema.json:191` @ `3076a40` | yes | pass | pass (245 ≥ 191) | **not evaluated** — 0 backtick tokens on citing line | **NO** |
| MAJOR-2 | `board/server/config.go:42` @ `3076a40` | yes | pass | pass (115 ≥ 42) | **false HIT** (see MINOR-2) | **NO** |
| MAJOR-R2-2 | `board/web/js/dom-writer.js:201` @ `6346d7d` | yes (unwrap works) | pass | pass (382 ≥ 201) | **not evaluated** — 0 backtick tokens | **NO** |

Evidence for the anchor column, verbatim:
- `dom-writer.js:150` = `// already publication-safe per schema/yard-snapshot.schema.json:191), and` → zero backtick tokens.
- `elapsedbucket_test.go:26/27` = `// stays exact whenever a snapshot IS served fresh: board/web/js/dom-` / `// writer.js:201 renders elapsed_seconds verbatim...` → zero backtick tokens on either line.

**The gate catches ZERO of the three findings its header names as its justification.** Round 2's claim was itself wrong (a *resolves* test cannot catch an in-range shift); the car inherited it as ground truth instead of testing it, with the tooling in hand. Law 1: a confident falsehood on the artifact that will license the `#65` close.

**Required:** the header must state plainly that the gate binds **Class A (dead path)** and **out-of-range only**, and that in-range shifts — the class behind MAJOR-1/2/R2-2 — remain **uncaught**. `#65` must not close as "the citation-truth class is mechanised."

### MAJOR-2 — This commit broke a live citation and did not fix it in the same commit

`docs/setup.md:42` states: *"the TEMPLATE's own \"Running them\" section (`repo-policy-check-patterns.md:57`) describes graduating such checks to one fail-fast CI job"*.

- At base `4f2ae97`: `repo-policy-check-patterns.md:57` = `## Running them` — **TRUE**.
- At HEAD `3d76e65`: line 57 is mid-paragraph §3 prose (`a kebab-case client filename broken exactly at its own hyphen`). `## Running them` is now at **line 76**.

The commit's own §3 rewrite inserted ~19 lines above it. This is a **Living Documents violation** (NORTH STAR: *"the commit that invalidates a document updates that document, in the same commit"*), it is the *exact* pattern the view train was rejected for twice (*"Broken by the car's own commit... the car then edited the file and left it standing"*), and it recurred **one train later inside the commit built to prevent it**.

And it is proof-by-construction of MAJOR-1 — I ran the gate's own resolver on it:
```
Resolve-CitationTarget STATUS = ok  resolved=docs/templates/repo-policy-check-patterns.md
```
(82 lines, so `:57` is in range.) **The gate ships green over a citation its own commit falsified.**

### MAJOR-3 — "Neither confirmed a real defect" is false; **both** anchor misses are live Class B defects

Header lines 156-160 dismiss the two content-anchor misses as *"neither confirmed a real defect, both are plain path citations with no repeated symbol token nearby to anchor on."* The second clause is true. The first is false for **both**:

1. **`docs/contracts/gating-matrix.md:49` → `board/server/sse.go:75-77`.** The citing text claims *"the server's heartbeat is a bare SSE comment"*. Lines 75-77 are a drop-path `select { case ch &lt;- data: default:` in the broadcast buffer. The real heartbeat is `writeSSEHeartbeat`, `sse.go:96-101`, with `fmt.Fprint(w, ": heartbeat\n\n")` at **line 101**. Off by ~24 lines.
2. **`docs/design/...design.md:97` → `artifacts/reviews/...REJECT.md:66`.** Line 66 is **blank**. The `### MAJOR-1. PostToolUse:Task does not fire...` heading the citing text describes is at **line 67**.

The report-only diagnostic scored **2/2 true positives on its misses**, and the car cleared both without opening the cited lines. This inverts the load-bearing rationale: the measured evidence argues the anchor is *more* valuable than the header concludes, not less. This is the "a claim is a QUESTION to test, never a conclusion to confirm" failure, and both defects remain live in the repo.

### MAJOR-4 — The two "fixes" are half-fixes, asserted as verified

Header lines 103-106: *"the content at line 66 of `artifacts/reviews/2026-07-22-harness-design-round1-REJECT.md` (git-mv history confirms it is the same file) **matches the citing text exactly**."*

It does not. Line 66 is blank. I traced the history with `--follow`:

| Commit | Path | Line 66 |
|---|---|---|
| `cd56035` | `docs/reviews/...` | `### MAJOR-1. \`PostToolUse:Task\` does not fire...` ← **true when written** |
| `81eca9f` | `docs/reviews/...` | `''` ← **broken here** (the Status-line gate added a line above) |
| `5ef0c57` | `artifacts/reviews/...` | `''` (git mv preserved the already-broken line) |

The car correctly fixed the **path** (Class A) at both `docs/design/...:97` and `docs/specs/...:109`, and correctly verified the git-mv history — but **retargeted a citation to a blank line while asserting the content was verified exact**. The off-by-one predates the car; the false verification claim does not. Both sites still need `:66` → `:67`.

### MAJOR-5 — No closed-set self-calibration, while the header claims the ported shape has it

Header lines 31-35: *"PRECEDENT SHAPE PORTED: `scripts/tests/CodeCitationPolicy.Tests.ps1` (corpus-scan, closed-set, **self-calibrating**, reds BY NAME)... **This file is that same shape**."*

It is not. `CodeCitationPolicy.Tests.ps1:288-308` carries a completeness test that reds by name when the corpus grows an extension outside the checked set — the remedy `#42` round 3 paid a **Major** for. `CitationResolverPolicy.Tests.ps1` has **no equivalent**. If a `.py`, `.ts`, `.rb` or `.txt` file carrying citations lands, the gate ignores it **silently, forever**.

Not hypothetical: the repo already tracks `scripts/canonicalise-demo.py`, unchecked and undisclosed (the header discloses the `.html` probe but never mentions `.py`). I probed it and the other unchecked non-artifact extensions — **zero coordinate matches today**, so no live defect. But this is silent blindness in a guard, in a repo that has already paid a Major for exactly this class one directory over. The fix is ~10 lines, directly portable.

*This is the weakest of the five and I flag it as such — the SCOPE section does disclose non-exhaustiveness. It stays Major because the property is affirmatively claimed and absent, and the consequence is undetectable.*

---

## MINOR FINDINGS

**MINOR-1 — Unwrap precondition misses slash-wraps; the header's flagship Class A example escapes through it.** I ran the car's actual scanner against adversarial fixtures:

| Wrap shape | Result |
|---|---|
| At intra-name hyphen (control) | `board/web/js/dom-writer.js:201`, **ok** ✅ |
| At a path **slash** | degrades to bare basename `dom-writer.js:201` — **directory lost** |
| Before the colon | **NO COORDINATE FOUND** (silent miss) |
| After the colon | **NO COORDINATE FOUND** (silent miss) |
| Mid-token, no hyphen | flags `ter.js:201` dead — **fail-loud**, acceptable |
| Inserted hyphen | flags `domwri-ter.js` dead — **fail-loud**, acceptable |

Sharpened: a **wrong-directory** citation — the header's own flagship Class A example — is caught on one line (`board/wrong/assemble.go:12` → `dead`) but **passes silently** when slash-wrapped (`assemble.go:12` → `ok`).

**RULING on the brief's question: calibrated-narrow-with-disclosure is ACCEPTABLE, but the disclosure is incomplete and the narrowness is unjustified for the slash case.** Evidence for acceptable: the one real-world escape ended in a hyphen; both corpus Class-C instances end in a hyphen; 93 corpus lines end in `/` and **none** is a wrapped coordinate (I opened them — all directory references); naive joining costs 8 false flags. Evidence against the current line: I patched the precondition to `[-/]$` and re-scanned the real corpus — **192 coordinates, identical count, 0 new dead/out-of-range flags.** The widening is measurably free. The "false positives justify the narrow precondition" argument is true of *no* precondition, not of the slash precondition, and the header over-generalizes it. The pre/post-colon silent misses are genuinely unrealistic (whitespace wrappers cannot produce them) and should simply be **named** in the header.

**MINOR-2 — Content-anchor uses case-insensitive matching, corrupting its own calibration.** `line 465`: `if ($windowText -match [regex]::Escape($tok))`. PowerShell `-match` is case-insensitive by default. On view-train MAJOR-2 the only anchorable token is `` `StalenessMs` ``; the ±15 window (lines 27-57 of `config.go`) contains no `StalenessMs`, but **line 56** carries prose `stalenessMs 15000` — so the anchor returns **HIT** and would have passed a real defect. Case-sensitive matching would have flagged it. Use `-cmatch`, and re-take the hit/miss calibration afterward, because that calibration is what justified report-only.

**MINOR-3 — The ellipsis valve runs NO checks at all.** Demonstrated: `.../never-existed.md:3` (fabricated target) and `.../solo.md:99999` (out of range) both return `EXEMPT-ELIDED`, zero checks. The valve's own rationale is that the elided form abbreviates a real nearby citation — if so the basename is real and checkable. Run existence + range on it; keep the exemption only for the *path* precision.

**MINOR-4 — The ambiguous valve runs no range check.** `Resolve-CitationTarget:357` returns `ambiguous` **before** any line check. Demonstrated: `dup.md:99999`, out of range for *every* candidate, passes. When all candidates fail, it is a defect regardless of which was meant. **RULING on the brief's question:** yes, a defect hides here — `gating-matrix.md:23` is reported loudly with the full candidate list (good), but a citation meant for `docs/contracts/gating-matrix.md:23` (a completely different row) would pass silently. Acceptable as report-only *given* the loud enumeration, but the all-candidates-out-of-range case should bind.

**MINOR-5 — 209 corpus lines end in `" -"` (prose dash), each a live false-join surface.** Of 337 hyphen-terminated lines, 209 are dash usage, not kebab breaks. Any one followed by a citation glues into a bogus target (`"disclosed at-" + "board/poll.go:1"` → `at-board/poll.go`). Zero today; unbounded going forward. Cheap tightening: require the hyphen to be preceded by a word character.

**Escape-valve rulings summary:** ellipsis → **needs tightening** (MINOR-3); ambiguous → **needs tightening** (MINOR-4); historical marker → **ACCEPTABLE** (greppable literal, line-scoped, 1 instance, reported by name; adding it is a visible diff a reviewer sees — no justification text is required, but the real instance carries one); self-exclusion → **ACCEPTABLE** (well-reasoned, matches precedent).

---

## THE CAR'S COUNTER-MEASUREMENT (item 5) — **CONFIRMED CORRECT**

I opened all three citing sites and both `gating-matrix.md` files.

`docs/templates/gating-matrix.md:23` = `| Example: staleness banner | data age &gt; threshold | never (truth surface) | fresh fetch | DELIBERATE, no override | \`Banner_Stale_...\` |`

Both quoted fragments — *"never (truth surface)"* and *"DELIBERATE, no override"* — appear **verbatim** on that line. All three citations (`design.md:53`, `design-doc.md:204`, `worked-spec.md:94`) are **TRUE**. `docs/contracts/gating-matrix.md:23` is an unrelated artifact-index-staleness row. `worked-spec.md:94` explicitly names *"this project's own gating-matrix TEMPLATE"*, self-disambiguating.

**Ruling: the car is right and issue #65's comment is wrong as stated.** This is a success outcome — a premise disproved with evidence rather than agreeably "fixed" — and it doubles as a live pass of the ambiguous-basename valve, which surfaced all three by name. Credit where due.

---

## SENTENCE CHECK

**Hop 1 (prose):** `docs/templates/repo-policy-check-patterns.md:44` — "The citation checker (LANDED #65 — `scripts/tests/CitationResolverPolicy.Tests.ps1`)". **Hop 2 (file):** exists, 620 lines, `#65` cited at line 2. **Hop 3 (discovery):** `Invoke-Pester -Path scripts/tests` auto-discovers it — observed, 15 tests inside the 210 total. **Hop 4 (behavior a stranger observes):** green at HEAD from the repo root; reds by name on Class A/C injection. ✅

**But hop 5 fails:** §3 line 48 claims *"The cheap tier below is BINDING (file exists + line in range)"* — accurate — while the gate's own header claims to be the mechanism for MAJOR-1/2/R2-2, which the binding tier provably does not catch (MAJOR-1). A reader of the template gets the true story; a reader of the gate header gets the false one. And `docs/setup.md:42`'s citation into this very file is now **dead at the line level** (MAJOR-2) — a hop that no longer arrives.

---

## #13 FIELDS

**BASE-DELTA vs `4f2ae97`** — matches the brief exactly: one new Pester gate (`scripts/tests/CitationResolverPolicy.Tests.ps1`, +620), two doc retargets (`docs/design/...design.md`, `docs/specs/...spec.md`, 1 line each), one exemption marker (`.claude/hooks/run-session-start-guards.sh`, **verified comment-only: 0 non-comment changed lines**), one template note (`docs/templates/repo-policy-check-patterns.md`, +21/-2). **No behavior change to board or harness — verified:** no `.go`, `.js`, `.mjs`, `.css`, `.html`, `.json`, no `scripts/*.ps1` outside `scripts/tests/`, no schema, no CI workflow. Go 85/85 and Node 129/129 confirm.

**#40 FLOOR: N/A with reason.** No rendered surface changed. `git diff --name-only 4f2ae97..3d76e65` yields exactly 5 files: one `.sh` (comment-only), three `.md`, one `.ps1`. No CSS, JS, HTML, template, or Go rendering path is touched, so there is no computed-style claim to drive through a browser. Recorded as verified-absent, not assumed-absent.

**UNREPRODUCIBLE-EVIDENCE:** none. Every finding above is re-runnable from the commands in this verdict. Two caveats for the record: (a) the first Node run's 2 failures were transient, resolved on 3 subsequent runs, cause identified as the skipped `npx playwright install` step — flake, not a finding; (b) my scratch harness loads the car's real functions via `Invoke-Expression` on lines 215-366 of the gate file, so all fixture results exercise the shipped code, not a reimplementation.

**PERFORMANCE (item 7):** scan of 258 files / 192 coordinates = **2.59s, 2.64s, 2.79s** across runs; whole file **8.4-9.0s**. The 60s ceiling is generous but appropriate as a blowup sentinel. **ACCEPTABLE** for every-push CI.

**SCOPE:** the car touched only what its brief covers. The template note is in-scope; it is the same-commit doc obligation on `docs/setup.md:42` that was missed, not the scope.

---

## CONSTITUTION CHECK

| Law / doctrine | Status |
|---|---|
| **Law 1 (no confident falsehood)** | **VIOLATED** — MAJOR-1 (gate claims a class it does not close), MAJOR-3 ("neither confirmed a real defect"), MAJOR-4 ("matches the citing text exactly"), MAJOR-5 ("self-calibrating"). Four checkable false claims on the gate's own header. |
| **Living documents (same-commit truth)** | **VIOLATED** — MAJOR-2: the commit falsified `docs/setup.md:42` and did not update it. |
| **Documentation ranks equal to code** | **VIOLATED** via the above; the gate's header *is* the deliverable's documentation and carries four false claims. |
| **Probe doctrine (run, don't read)** | **VIOLATED in part, HONORED in part.** Honored magnificently for `Measure-Object -Line` (266 vs 239, re-derived exactly), the `.html` sweep, and the leading-dot regex fix. Violated for the load-bearing claim: the car never ran the gate against the three findings it says it would have caught, and never opened the two lines it cleared as non-defects. |
| **Healing Loop (facts land as tests, not prose)** | **HONORED** — the mechanism landed as a Pester gate with scratch-repo fixtures, wired into CI by auto-discovery. This is the right instrument, correctly built. |
| **Red-by-name / non-vacuity** | **HONORED** — proven by my own injection, verbatim above. |
| **Severity philosophy (no wolf-crying)** | **HONORED** — 0 false flags on the real corpus; the ambiguous/elided buckets are report-only with named enumeration. |
| **#42 no-backfill boundary** | **HONORED** — `CodeCitationPolicy` 13/13, new file cites `#65`. |
| **Guide star (blameless, not vague / not polite)** | Applied: actors and exact moves named; the car's genuine wins (counter-measurement, probe work, exact arithmetic) recorded as wins. |
| **Cars never push** | **HONORED** — single local commit, nothing pushed. |

---

## WHAT THE GATE DOES AND DOES NOT CATCH — for the `#65` close

**CATCHES (binding, proven):** Class A dead paths, single-line and hyphen-wrapped, by name. Out-of-range line numbers. This is real and valuable — it found and fixed 2 live Class A defects at landing.

**DOES NOT CATCH:** in-range shifted citations (Class B proper) — the class behind view-train MAJOR-1, MAJOR-2, and MAJOR-R2-2, all three of which I measured passing green. Wrong-directory citations that are slash-wrapped. Citing files outside the 11 checked extensions. Out-of-range lines inside the elided or ambiguous buckets.

**`#65` must stay open, or close with that scope stated verbatim.** The ticket's justification was the 9+ citation findings; the gate closes the cheap half of them.

---

## PATH TO APPROVE

1. **MAJOR-2 first** — fix `docs/setup.md:42` `:57` → `:76`. (Ironic and mandatory.)
2. **MAJOR-4** — `:66` → `:67` at `docs/design/...design.md:97` and `docs/specs/...spec.md:109`; correct the header's verification claim.
3. **MAJOR-3** — fix both real Class B defects (`gating-matrix.md:49` → `sse.go:96-101`); replace the false "neither confirmed a real defect" sentence with the measured 2/2 true-positive result; re-argue report-only on honest evidence (or bind it).
4. **MAJOR-1** — rewrite the header's WHY/justification to state the real coverage; do not claim MAJOR-1/2/R2-2 would have been caught.
5. **MAJOR-5** — port `CodeCitationPolicy.Tests.ps1:288-308`'s closed-set completeness test; declare `.py`/`.html` as exemptions with reasons.
6. **Minors** — `[-/]$` precondition (free, measured); `-cmatch`; range-check the elided and all-candidates-ambiguous cases; word-char guard on the hyphen.

**This is a well-engineered gate with excellent measurement discipline, landing the right instrument for the right class.** It is rejected for what its documentation claims about itself, and for repeating — inside itself — the exact defect it was built to stop.

**Files:** `<repo>-wt\review-tooling-65\scripts\tests\CitationResolverPolicy.Tests.ps1`, `<repo>-wt\review-tooling-65\docs\setup.md`, `<repo>-wt\review-tooling-65\docs\templates\repo-policy-check-patterns.md`, `<repo>-wt\review-tooling-65\docs\contracts\gating-matrix.md`, `<repo>-wt\review-tooling-65\docs\design\2026-07-22-dispatch-harness-design.md`, `<repo>-wt\review-tooling-65\docs\specs\2026-07-22-dispatch-harness-spec.md`, `<repo>-wt\review-tooling-65\board\server\sse.go`, `<repo>-wt\review-tooling-65\artifacts\reviews\2026-07-22-harness-design-round1-REJECT.md`

```starcar-artifact
outcome: REJECT
task-id: tooling-65-review-r1
findings: 5 Major, 5 Minor
  MAJOR-1: The gate does not catch the defect class that justified issue #65, and its header (lines 4-16) claims it does. Measured at the real defect commits, all three findings the header names pass the binding checks clean - view-train MAJOR-1 (schema/yard-snapshot.schema.json:191 at 3076a40, 245 lines, in range), MAJOR-2 (board/server/config.go:42 at 3076a40, 115 lines, in range), MAJOR-R2-2 (board/web/js/dom-writer.js:201 at 6346d7d, 382 lines, in range). Anchor could not help - dom-writer.js:150 and elapsedbucket_test.go:26-27 carry zero backtick tokens. Confirmed by negative control - an injected in-range shifted citation left the gate at 11 passed / 0 failed. Law 1.
  MAJOR-2: This commit falsified a live citation and did not fix it in the same commit. docs/setup.md:42 cites repo-policy-check-patterns.md:57 for the "Running them" section; that was TRUE at base 4f2ae97 and the commit's own section-3 rewrite pushed the heading to line 76. Resolve-CitationTarget returns ok on it - the gate ships green over a citation its own commit broke. Living-documents violation, and proof-by-construction of MAJOR-1.
  MAJOR-3: Header lines 156-160 claim the two content-anchor misses were "neither confirmed a real defect". Both are live Class B defects. docs/contracts/gating-matrix.md:49 cites board/server/sse.go:75-77 for a bare SSE comment heartbeat - those lines are a drop-path select, the heartbeat is writeSSEHeartbeat at sse.go:96-101. docs/design/2026-07-22-dispatch-harness-design.md:97 cites artifacts/reviews/2026-07-22-harness-design-round1-REJECT.md:66 - blank line, content at 67. The diagnostic scored 2 of 2 true positives on its misses and both were cleared without opening the cited lines; that false claim is the load-bearing justification for landing the anchor report-only.
  MAJOR-4: Both retargeted citations are half-fixes asserted as verified. Header lines 103-106 claim content at line 66 "matches the citing text exactly"; line 66 is blank and the MAJOR-1 heading is at 67. git log --follow shows the citation was true at cd56035, broken at 81eca9f by the Status-line gate, and carried through the git mv at 5ef0c57. The path fix is correct; the line was never checked.
  MAJOR-5: No closed-set self-calibration test, while header lines 31-35 claim the ported shape is "closed-set, self-calibrating". CodeCitationPolicy.Tests.ps1:288-308 has the completeness test that issue #42 round 3 paid a Major for; this gate has no equivalent, so a new citing file type is ignored silently forever. scripts/canonicalise-demo.py is already tracked and unchecked, undisclosed while .html is disclosed. Probed - zero coordinate matches today, so no live defect. Weakest of the five and flagged as such.
  MINOR-1: Unwrap precondition misses slash-wraps. Ran the car's own scanner - a wrong-directory citation is caught on one line (board/wrong/assemble.go:12 dead) but passes silently when slash-wrapped (degrades to assemble.go:12 ok), defeating the header's own flagship Class A example. Pre-colon and post-colon wraps are total silent misses; mid-token and inserted-hyphen wraps fail loud, which is acceptable. RULING - calibrated-narrow is acceptable on the class evidence (the one real escape and both corpus instances end in a hyphen; 93 slash-terminated lines, none a wrapped coordinate) but the slash exclusion is unjustified - patching the precondition to hyphen-or-slash and re-scanning gave 192 coordinates, identical, zero new flags. The widening is measurably free.
  MINOR-2: Content anchor at line 465 uses -match, case-insensitive. On view-train MAJOR-2 the only token is StalenessMs; the plus-or-minus-15 window holds no StalenessMs but config.go:56 carries prose stalenessMs, so the anchor returns HIT and would pass a real defect. Use -cmatch and re-take the calibration that justified report-only.
  MINOR-3: The ellipsis valve runs no checks at all. Demonstrated - a fabricated target and an out-of-range line both return EXEMPT-ELIDED. The basename is checkable; exempt only the path precision.
  MINOR-4: The ambiguous valve returns before any range check, so a line out of range for every candidate passes. A citation meant for the other file of an ambiguous pair is invisible. Bind the all-candidates-fail case.
  MINOR-5: 209 of 337 hyphen-terminated corpus lines are prose dashes, each a live false-join surface. Zero today, unbounded going forward. Require a word character before the hyphen.
abstract: |
  Adversarial review of the #65 citation-resolver gate at 3d76e65 (parent 4f2ae97), detached worktree, byte-clean in and out. Suites run myself - scripts/tests 205 passed / 0 failed / 5 skipped / 210 (reconciles with the car's attached-branch 206/0/4/210; the extra skip is the branch-attached #50 guard), scripts/probes 24/24, Go 85 PASS / 0 FAIL with go vet clean, Node 129/129 across three runs, probe-yard-snapshot PASS, CodeCitationPolicy 13/13, DocPolicy 2/2, the gate itself 11 passed / 0 failed / 4 skipped.
  Every calibration number re-derived exactly - 258 source files, 192 coordinates, 13 ambiguous, 3 elided, 1 historical, 2 wrapped (the exact two named), anchor n=9 at hit 7 miss 2, and the algorithm.go 266-versus-239 Measure-Object probe. The car's arithmetic is impeccable and its probe work is genuinely good; the Majors are about the conclusions drawn from correct measurements.
  Non-vacuity proven by my own injection - Class A and Class C both red BY NAME, quoted verbatim, reverted to sha256 7FC915C9...32A4, identical. The decisive test is the negative control - an injected in-range shifted citation left the gate at 11 passed / 0 failed, so the gate is green on the exact defect shape of view-train MAJOR-1.
  Five Majors. The gate does not close the class that justified the ticket while its header says it does; the commit falsified docs/setup.md:42 and left it standing, which the gate itself passes green; the two content-anchor misses the car dismissed as non-defects are both real live Class B defects; both retargeted citations still point at a blank line while the header asserts the content was verified exact; and the claimed self-calibration does not exist.
  The car's counter-measurement on issue #65's gating-matrix.md:23 claim is CONFIRMED CORRECT - all three citations resolve verbatim against docs/templates/gating-matrix.md:23 and the issue comment's premise is false as stated. Recorded as a success outcome.
  Verdict REJECT. The instrument is right and well built; it is rejected for what its documentation claims about itself and for repeating, inside itself, the exact defect it exists to stop. The #65 close must scope honestly - the gate binds Class A and out-of-range only; in-range shifts remain uncaught.
```