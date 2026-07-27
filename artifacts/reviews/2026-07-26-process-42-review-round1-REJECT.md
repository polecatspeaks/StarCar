<!-- starcar-integrity: sha256=f9e92d57c5255a17158d4b3b8b33bc2b26292b68a03c57ccfbae7627d53fe174 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car process-42 review - round 1 (REJECT)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial sentence-check review
Round: 1
Target: `commit 79cb5c9 on car/process-42 (#42 citation gate)`
Base reviewed: `79cb5c909e2dafc898266b0c04258dc00673fb81`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a67cb0075007e7753`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `79cb5c909e2dafc898266b0c04258dc00673fb81` |

| Dispatch, the locator within the session | `a67cb0075007e7753` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 79cb5c909e2dafc898266b0c04258dc00673fb81
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Evidence complete. Reverting verified, shared checkout untouched.

---

# REVIEW VERDICT: **REJECT** — 2 Majors

**Subject:** commit `79cb5c9` (issue #42) · **Base verified:** worktree `<repo>-wt\review-process-42` at HEAD `79cb5c909e2dafc898266b0c04258dc00673fb81`, tree clean.

The gate is well-shaped and its production path genuinely fires — I proved that myself. It is rejected because **it does not work where it is claimed to run (CI), and that claim is now written into CLAUDE.md as doctrine**, and because a measured, undisclosed hole lets whole languages through silently.

## Suites I ran myself (detached worktree, `79cb5c9`)

| Suite | Observed | Note |
|---|---|---|
| `scripts/tests` | **188 passed / 0 failed / 1 skipped, total 189** | Matches the derived detached expectation (188/0/1 of 189). Skip is `run-session-start-guards.sh: agent-pull runner (#50)` detached-HEAD skip, not this commit's. |
| `scripts/probes` | **24 passed / 0 failed** | |
| `scripts/store-checks` | **178 passed / 0 failed** | Derived independently: 173 `artifacts/**/*.json` records present. |
| `CodeCitationPolicy.Tests.ps1` alone | **7 passed / 0 failed** | |

**Corpus re-derived independently** (not read from the header): 118 post-boundary added paths at HEAD (117 + this commit's own test file — the header's "117 ... probed before writing this file" at `:21` is accurate). Excluding `artifacts/`: 22 files in the checked extension set. **All 22 carry a bare `#N`** — I opened every one. `git show --stat` touches only `CLAUDE.md` and the new test file, so **no code file was edited to add a citation: the zero-fixes claim is verified true.**

---

## MAJOR-1 — The gate is inert-and-red under CI's shallow checkout, and CLAUDE.md now asserts the opposite

`CLAUDE.md:1034-1036`: *"It runs wherever `scripts/tests` runs - `.github/workflows/ci.yml`'s 'Run board tooling tests' step already invokes `Invoke-Pester -Path ./scripts/tests`, so **no CI wiring change was needed**."* Same claim in the commit message.

`.github/workflows/ci.yml:119` is a bare `- uses: actions/checkout@v4` with **no `fetch-depth`** — default depth 1. I grepped the whole workflow: `fetch-depth|unshallow|--deepen` → **NONE FOUND**. The Entire-branch fetch at `:121-144` fetches one unrelated ref and does not unshallow. Checkout `:119` and the test step `:219` are in the same single job `verify` (`:112`).

The gate's derivation (`CodeCitationPolicy.Tests.ps1:75`) is `git diff --diff-filter=A &lt;BoundarySha&gt; HEAD`, and the boundary commit is not in a depth-1 clone. **Simulated it** (`git clone --depth 1`, 1 commit, HEAD `79cb5c9`):

```
fatal: bad object d4db6f5baf2bd31bf41f9dc5804684334797cb35
SHALLOW-CLONE (CI simulation) =&gt; Total=7 Passed=6 Failed=1
FAILED: ...finds added post-boundary code files to check (a check that examines nothing is not a pass)
  MESSAGE: Expected the actual value to be greater than 0, but got 0.
```

`ci.yml:227` exits 1 on `FailedCount -gt 0`. **CI goes red on the first push, for a reason unrelated to any citation violation** — the wolf-cry class CLAUDE.md names explicitly. `79cb5c9` is on **no remote branch** (`git branch -r --contains` empty), so this was never observed; the claim was derived by reading `ci.yml`, which is precisely the *reading is not verifying* scar. This is a Law 1 defect on doctrine text: CLAUDE.md is the highest-inheritance document in the repo and now carries a false mechanism claim.

**Credit where due:** the non-vacuity guard at `:99-101` is what converts this into a loud failure. Without it the empty added-set would have made the citation test pass vacuously — green, asserting nothing. Good design, and it caught its own author's untested claim.

**Remedy:** `fetch-depth: 0` (or enough to reach `d4db6f5`) on `ci.yml:119`, *plus* a pinned assertion that the boundary object is resolvable so the failure names the real cause; then correct `CLAUDE.md:1034-1036`.

## MAJOR-2 — Silent extension-allowlist hole; undisclosed, and CLAUDE.md's exclusion list reads as complete

`:94` hardcodes `@('.ps1','.psm1','.go','.js','.mjs','.sh')`. Any other extension is silently unchecked forever, and **nothing asserts completeness** — the absence-blindness class CLAUDE.md names ("an absence is invisible unless something asserts completeness"), and Law 7's hardcoded-taxonomy constraint.

**Fault-injected and measured.** Three uncited post-boundary code files committed — `scripts/fault-inject.py`, `board/web/css/fault-inject.css`, `board/web/fault-inject.ts`:

```
uncited py/css/ts present =&gt; Total=7 Passed=7 Failed=0
```

Green. Not hypothetical: `scripts/canonicalise-demo.py` already exists (pre-boundary), the probe suite measures `PYTHON START`, and `board/web/package.json` landed post-boundary — `.py`, `.ts`, `.css` in this repo are a matter of when.

Disclosure fails on both surfaces. The header's `KNOWN LIMITATION` (`:48-56`) covers only the regex; the SCOPE section (`:20-41`) justifies excluding `.json`/`.md` but never says *an extension absent from this list is unguarded*. `CLAUDE.md:1031-1032` — "skips `artifacts/**` and `.json`/`.md`" — enumerates exclusions in a way that reads as exhaustive and is not. Contrast the ported prior art, which got this right: `DocPolicy.Tests.ps1:26` names its set "**The closed set. Growing it is a deliberate decision, not a convenience.**"

**Remedy (~5 lines, and it is the self-calibrating form):** assert the post-boundary non-`artifacts/` extension set is a subset of (checked ∪ declared-exempt), reding **by name** on a new extension. That converts permanent silent under-coverage into one loud, correct, true-positive signal.

---

## Minors

- **MIN-1 — Second copy of the detection logic (Law 6).** `:68-90` and `:131-153` are **byte-for-byte identical** (diffed, 23 lines each). The stated justification (`:128-130`, "redefined here because each Describe's BeforeAll runs in its own scope") is true but not the whole truth, and the conclusion that redefinition is necessary is false. **Probed** (Pester **5.8.0**): a file-level `BeforeAll` defines a function visible to *both* Describes — 3/3 passed. Consequence: the by-name flagging proof runs against a copy that can silently diverge from the production path, so a future edit to `:68-90` leaves the scratch proof green and meaningless. The car's diagnosis of the discovery/run-phase split was correct; only the remedy is.
- **MIN-2 — The disclosed-limitation probe claim is self-refuted at HEAD.** `:52-54` asserts "no file in the checked extension set contains a match of `#[0-9]{3,}` outside a real ticket reference." Scanned the checked set: exactly one file matches — **the gate file itself**, with `#123456` (its own hex-collision example, explicitly not a ticket) and `#999` (a scratch fixture). Zero behavioural consequence (the file carries `#42`), but the limitation's whole argument is "no collision exists today," and it stopped being true in the commit that asserted it. On the substantive question the brief asks: **the limitation is acceptable as-is** — comment-aware parsing for a 2-digit-ticket corpus is the autoimmune build the severity philosophy warns against. Fix the sentence, not the regex.
- **MIN-3 — `docs/setup.md:42` under-describes its own trigger.** That row owns the `#3`/`#4` deferral and its trigger ("the next CI touch whose OWN scope includes repo-policy enforcement"), and carries Car 1's precedent of recording a re-park *in the row* ("recording it here turns a silent gap into a decision"). This commit is repo-policy enforcement; its disposition ("#3 and #4 remain open, unaffected") was recorded only at `CLAUDE.md:1039-1040`. Nothing in the row became *false*, so this is Minor, not a stale-doc Major — but the row no longer mentions that the §1 pattern has a second instance.
- **MIN-4 — The fixture clause is left attention-tier, undisclosed.** CLAUDE.md's fixture edge says the citation "goes in the sibling `README.md` or in the consuming test." The gate checks neither, and the header's `.json` reasoning (`:27-36`) never states that the residual obligation stays attention-tier. In practice honored — `schema/vectors/adapter/README.md` carries `#47` — but unguarded and unlabelled.
- **Note (not a finding):** `CLAUDE.md:1037` says "all **21** post-boundary code files" **"at landing"**; at the landing commit the checked set is **22** (the gate file included). The test header's parallel figure is correctly qualified "probed before writing this file" (`:21`); the doctrine sentence is not.

## Adjudications the brief asked for, ruled on evidence

- **(b) Does the scratch block prove the boundary or illustrate it?** It **tests**, not illustrates — real `git init`, real commits, real derivation, and it would fail if the logic broke. It is *not* the illustrating-not-testing scar. But it tests a **duplicate** (MIN-1), so its unique contribution — the by-name flagging case — never touches the production path. The production path's boundary exclusion *is* honestly proven against the real function by `:115-122` (verified: `board/board.go` added pre-boundary at `ce5c93f`, 0 citation matches).
- **`.css`/`.html` hole?** **Premise disproved.** `board/web/css/board.css` and `board/web/index.html` were both **added** at `0fbc034` (2026-07-23), **pre-boundary**, so they are correctly outside the added-set — no existing hole. The hole is prospective, and I injected it (MAJOR-2).
- **`.psm1` "no instance yet"** (`:24-25`) is accurate *as scoped to the post-boundary corpus*; three `.psm1` files exist pre-boundary. Not a finding.
- **CLAUDE.md rewrite vs supersede:** deleting the now-false "this is attention-tier" sentence is **correct**, not erasure — leaving it would be a lying canary. The transition survives at `CodeCitationPolicy.Tests.ps1:6`. **NO BACKFILL language is intact and untouched** (verified in the diff). No finding.

## Sentence check — the gate's claim chain, hop by hop

1. **Standard** — `CLAUDE.md:1008-1015` (bare `#N` on every new addition) → 2. **Boundary** — `CLAUDE.md:1042` NO BACKFILL / `d4db6f5` ("standard: every new code addition cites its ticket as bare #N", 2026-07-23) → 3. **Enumeration** — `:75` `git diff --diff-filter=A` → `:78` artifacts filter → `:79` extension filter → 4. **Assertion** — `:103-113`, violators joined, `Should -BeNullOrEmpty` → 5. **CI** — `ci.yml:225` path-glob picks the new file up with no wiring; `:227` `exit 1` → 6. **Observed behaviour** — **hop 3 breaks in CI** (MAJOR-1: `fatal: bad object`), and **hop 3 silently drops non-allowlisted languages** (MAJOR-2). Locally, hops 4-6 are sound and I watched them fire.

## Fault-injection log (all reverted; disclosed)

| # | Injection | Observed |
|---|---|---|
| A | uncited `scripts/fault-inject-uncited.ps1`, committed | 6/7 — `Expected $null or empty, but got 'scripts/fault-inject-uncited.ps1'` — **fires by name** |
| B | same file, cited `#42` | 7/7 — **no false positive** |
| C | uncited `.py` + `.css` + `.ts` | 7/7 green — **silent miss** |
| D | `git clone --depth 1` (CI shape) | 6/7 — `bad object`, `Expected ... greater than 0, but got 0` |
| E | Pester file-level `BeforeAll` probe (temp dir) | 3/3, Pester 5.8.0 |

**Revert verified:** `git reset --hard 79cb5c9` + `git clean -fd` → HEAD `79cb5c909e2dafc898266b0c04258dc00673fb81`, `git status --porcelain` **empty**, gate **7/7**. Temp artifacts removed. **Shared checkout `<repo>`: clean, on `dev`, untouched.** I edited, committed, and pushed nothing to the record.

## Constitution check

- **Law 1 (Truth)** — **VIOLATED.** `CLAUDE.md:1034-1036` states a CI mechanism that does not work, never observed (MAJOR-1).
- **Law 4 (Nothing Silently Lost)** — **VIOLATED.** Post-boundary code in a non-allowlisted language is dropped from the check with no loud note (MAJOR-2); measured green on three injected files.
- **Law 6 (One Truth)** — **VIOLATED (Minor).** Two byte-identical copies of the detection logic (`:68-90`, `:131-153`) with no drift guard; the copy is what the flagging proof asserts against.
- **Law 7 (The Stranger)** — **AT RISK.** A hardcoded extension taxonomy calibrated to this repo's corpus; a stranger's shop in another language gets a green gate that checks nothing.
- **Law 5 (Self-Knowledge)** — **HONORED in part.** The non-vacuity test at `:99-101` is the gate refusing to look live while asserting nothing, and it is what surfaced MAJOR-1 loudly rather than silently.
- **Law 3 (Actionability)** — **HONORED.** `:111-112` lists every violator rather than failing on the first; observed in injection A.
- **Law 8 (Growth)** — **HONORED.** The standard graduates from attention-tier to mechanism, ported from named prior art (`repo-policy-check-patterns.md` §1 via `DocPolicy.Tests.ps1`).
- **Law 2 (The Dispatcher Commands)** — not implicated.
- **Code standard (#N citation)** — **HONORED.** The new file cites `#42` at `:1`, `:9`, `:11`.

Fix MAJOR-1 and MAJOR-2 and this is a good gate; the shape, the prior-art port, the non-vacuity guard, and the by-name violator listing are all right, and the zero-fixes calibration claim is honest and verified.

```starcar-artifact
outcome: REJECT
task-id: process-42-review-r1
findings: 2 Major, 4 Minor, 1 Note
  MAJOR-1: The gate is broken under CI's default shallow checkout, and the commit writes
    the opposite into CLAUDE.md as doctrine. ci.yml:119 is a bare actions/checkout@v4 with
    no fetch-depth (grep for fetch-depth/unshallow/--deepen across ci.yml returns nothing);
    the gate's derivation at CodeCitationPolicy.Tests.ps1:75 needs boundary commit
    d4db6f5 present. Simulated with git clone --depth 1: "fatal: bad object
    d4db6f5baf2bd31bf41f9dc5804684334797cb35", suite 6/7, failure "finds added
    post-boundary code files to check" :: "Expected the actual value to be greater than 0,
    but got 0". ci.yml:227 exits 1 on that, so CI reds on first push for a non-violation.
    Commit 79cb5c9 is on no remote branch, so this was never observed; the claim at
    CLAUDE.md:1034-1036 ("no CI wiring change was needed") was derived by reading. Law 1.
  MAJOR-2: Silent extension-allowlist hole, undisclosed. Line 94 hardcodes six extensions;
    nothing asserts the checked set covers the post-boundary corpus. Fault-injected three
    uncited post-boundary code files (.py, .css, .ts) - suite 7/7 GREEN, silent miss. Not
    hypothetical: canonicalise-demo.py exists pre-boundary, probes measure PYTHON START,
    board/web/package.json landed post-boundary. The KNOWN LIMITATION block (:48-56) covers
    only the regex; CLAUDE.md:1031-1032 enumerates exclusions as artifacts/plus json/md,
    which reads exhaustive and is not. Contrast DocPolicy.Tests.ps1:26 which names its
    closed set deliberately. Law 4, Law 7. Remedy is ~5 lines: assert the post-boundary
    extension set is a subset of checked-union-exempt, reding by name on a new extension.
  MINOR-1: Second copy of the detection logic. Lines 68-90 and 131-153 are byte-for-byte
    identical (diffed). Justification at :128-130 is true but incomplete and its conclusion
    is false - probed Pester 5.8.0, a file-level BeforeAll shares functions across both
    Describes, 3/3 passed. The by-name flagging proof therefore asserts against a copy that
    can silently diverge from the production path. Law 6.
  MINOR-2: The disclosed-limitation probe claim at :52-54 is self-refuted at HEAD. Scanned
    the checked set for the pattern hash-digit-3-or-more: exactly one file matches, the
    gate file itself, carrying its own hex example and a scratch fixture number, neither a
    real ticket reference. Zero behavioural consequence. Ruling on the substance: the
    limitation itself is ACCEPTABLE as-is - comment-aware parsing for a 2-digit-ticket
    corpus is the autoimmune build. Fix the sentence, not the regex.
  MINOR-3: docs/setup.md:42 owns the number-3/number-4 deferral trigger and carries Car 1's
    precedent of recording a re-park in that row; this commit is repo-policy enforcement and
    its disposition was recorded only at CLAUDE.md:1039-1040. Nothing in the row became
    false, hence Minor not Major.
  MINOR-4: The standard's fixture clause (citation in the sibling README or consuming test)
    has no mechanical check and the gap is not disclosed as attention-tier. Honored in
    practice - schema/vectors/adapter/README.md carries a ticket - but unguarded.
  NOTE: CLAUDE.md:1037 says "all 21 post-boundary code files" qualified "at landing"; at
    the landing commit the checked set is 22 including the gate file. The test header's
    parallel figure at :21 is correctly qualified, the doctrine sentence is not.
abstract: Adversarial sentence-check review of commit 79cb5c9 (issue 42), which mechanizes
  the cite-your-ticket code standard as scripts/tests/CodeCitationPolicy.Tests.ps1 plus a
  same-commit CLAUDE.md amendment. Base verified at 79cb5c909e2dafc898266b0c04258dc00673fb81,
  tree clean. Suites run by the reviewer at that SHA in the detached worktree: scripts/tests
  188 passed 0 failed 1 skipped of 189 (matching the derived detached expectation, the skip
  being the pre-existing number-50 guard-runner detached skip); scripts/probes 24 of 24;
  scripts/store-checks 178 of 178 against an independently derived 173 store records; the
  citation gate alone 7 of 7. Corpus re-derived independently rather than read from the
  header: 118 post-boundary added paths, 22 in the checked extension set, and every one
  opened and confirmed to carry a bare marker. The zero-fixes calibration claim is VERIFIED
  TRUE - git show --stat touches only the test file and CLAUDE.md, so no code file was
  edited to gain a citation. Fault injection performed and fully reverted: an uncited
  post-boundary ps1 makes the PRODUCTION Describe fire by name; the same file cited produces
  no false positive; uncited py, css and ts files pass silently; a depth-1 clone breaks the
  derivation outright. Two premises in the brief were tested and DISPROVED: board.css and
  index.html were added pre-boundary at 0fbc034 so there is no existing css/html hole, and
  the scratch Describe genuinely tests rather than illustrates - it is a real git repo with
  real commits - though it tests a duplicate of the production logic. Verdict REJECT on two
  Majors: the gate does not work in CI, the one place it is claimed to enforce, and CLAUDE.md
  now carries that false claim as doctrine; and a hardcoded extension allowlist drops whole
  languages with no completeness assertion. The gate's shape, prior-art port, non-vacuity
  guard and by-name violator listing are all sound, and the non-vacuity guard is what made
  the CI defect loud rather than silent. Revert confirmed byte-identical, HEAD restored,
  porcelain empty, shared checkout untouched; nothing was edited, committed or pushed.
```