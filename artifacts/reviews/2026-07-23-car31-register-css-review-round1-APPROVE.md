<!-- starcar-integrity: sha256=aef0aeb16cd7610f43bb73d83083da82bb0d6d02c0e7c9986b0470634e150efb covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car 31 (#31 register CSS) adversarial sentence-check review, round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-review
Round: 1
Target: `car/31-register-css @ 9c4730acaa02ce7d75ab7481d4829d916b7ec890`
Base reviewed: `38b67c8c0b9f75099aa334a5cf2af340c810920d`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `ad2b8215ab13183c4`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `38b67c8c0b9f75099aa334a5cf2af340c810920d` |
| Entire checkpoint | `2db32c0780b4` |
| Dispatch, the locator within the session | `ad2b8215ab13183c4` |
| Entire session (context, NOT a lookup key) | `e92f5a0b-1b9e-4913-98b3-c319b4d5e90b` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 38b67c8c0b9f75099aa334a5cf2af340c810920d
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: APPROVE

**0 Major, 2 Minor, 3 Notes.** The fix is correct, the guard was watched to fire, and I re-derived the diagnosis independently rather than from the report. Neither Minor is a defect in the shipped behavior; both are recorded with empirical evidence and a named remedy.

---

## Base and scope (re-derived)

| Check | Observed |
|---|---|
| Worktree HEAD | `9c4730acaa02ce7d75ab7481d4829d916b7ec890`, branch `car/31-register-css` |
| Parent | `38b67c8c0b9f75099aa334a5cf2af340c810920d` — matches the briefed base |
| Lineage | `git merge-base --is-ancestor 38b67c8 dev` → **true**; dev tip `0667521` adds only a harness dispatch record, `git diff --stat 38b67c8..dev -- board/web/css board/web/test` is **empty** (no conflict) |
| Diff | exactly 2 files, +60/−0: `board/web/css/board.css` (+1), `board/web/test/register-css.test.js` (new, 59) |
| Scope discipline | `dom-writer.js`, `render.js`, `compose.js` (freshness/IDLE) **untouched** — confirmed by `git show --stat`. Honored. |
| Worktree at end of review | `git status --porcelain` **empty**, `git diff HEAD` **empty**, `board/web/css/board.css` SHA256 `DC8F2B68…15FBA` identical to review start |

I never mutated the worktree. All fault injection ran against a byte-identical copy in scratch (proved identical over all 34 files by per-file hash before use, and deleted after).

---

## 1. RED evidence — re-derived, not read

Reverted the one added line on the copy and ran the new test:

```
✖ .register-nominal is color-self-contained: declares BOTH border-left-color and color...
  AssertionError [ERR_ASSERTION]: .register-nominal must declare its own color (not just
  border-left-color) - otherwise this register's elements inherit color from an ancestor
  running a different register (issue #31)
    actual: '\n  border-left-color: var(--nominal);\n',
    expected: /(?&lt;!-)\bcolor\s*:/,
ℹ tests 6  ℹ pass 5  ℹ fail 1
```

Verbatim match to the car's reported red, including `actual`. Fails for **the stated reason** (the assertion that pins the missing property), not incidentally: the sibling `rule exists` test stayed green, and the other two registers stayed green.

## 2. Non-vacuity — seven attacks, all on a copy

| Attack | Result |
|---|---|
| A: `board.css` emptied | 0 pass / **6 fail** |
| B: `.register-nominal` renamed `.register-calm` | 4 pass / **2 fail** |
| C: `color` replaced by `background-color` | 5 pass / **1 fail** (lookbehind guard holds) |
| D: replaced by `-webkit-text-fill-color` | 5 pass / **1 fail** (guard holds) |
| E: `border-left-color` removed | 5 pass / **1 fail** |
| G: 4th register `'bagged'` added to `compose.js` REGISTER_ORDER | test count **6 → 8**, `.register-bagged` fails both |
| Restore | 6 pass / 0 fail |

Attack G settles Law 7 empirically: the taxonomy is genuinely **imported**, not hardcoded — adding a register to `board/web/js/compose.js:13` grows the suite and reds on the unbacked class. The `(?&lt;!-)\bcolor\s*:` lookbehind at `register-css.test.js:52` does the work claimed for it.

## 3. GREEN evidence — run myself, observed counts

- `node --test` from `board/web` at `9c4730a`: **tests 56, pass 56, fail 0** (re-run at end of review, same).
- Baseline at `38b67c8` (full-tree `git archive` into scratch): **tests 50, pass 50, fail 0**. The commit message's "50 baseline + 6 new" is TRUE. *(My first baseline attempt archived only `board/web` and showed 1 fail — `sse-event-name.test.js` reads `schema/` from the repo root. My extraction artifact, not a real baseline red. Disclosed so the number is not read as a finding.)*
- `&amp; 'C:\Program Files\Go\bin\go.exe' test ./...` from `board/`: **5/5 packages ok** (`board`, `assemble`, `fold`, `server`, `store`).

## 4. THE FIX'S CORRECTNESS — independently derived

**Hypothesis (a) is genuinely dead.** I compared the fixture's wire `vocabularies` against `schema/vocab/board-defs.json` field by field: `positions`, `outcomes`, `roles`, `liveness` all **byte-equal**. Every id the fixture data actually uses (`returned`; `APPROVE`, `done`; `car`, `reviewer`; `live`, `bagged`, `dark`) is recognised — **zero detector misses**. Building the view model through `buildBoardViewModel` gives a per-item register tally of **`{"nominal": 71}`** — every dispatch, car state, and car outcome resolves nominal. The JS is not the bug.

The three live lanes are `needs-attention` because freshness is `{"kind":"stale","ageBucketMs":555000}` (`compose.js:41`) — honest, and the territory of #29.

**The cascade, measured.** I rendered the real snapshot through `dom-writer.js` into `minidom.js` and computed each text-bearing element's effective `color` by walking ancestors against a model of all 11 `color:` declarations in `board.css` (I verified mechanically that my model captured every one: `grep -n "^\s*color:"` returns exactly lines 35, 61, 68, 73, 121, 130, 134, 138, 189, 215, 221).

216 text-bearing elements. **142 moved red → paper**: 110 `.solari-subject`/`.solari-state`, 24 `.car-subject`/`.car-role`/`.car-state`, 8 `.car-outcome`. That is exactly issue #31's named symptom — "every dispatch row, train chip, and outcome".

Answering each sub-question the brief posed:

- **(i) `.car-chip` / `.signal` / `.solari-row`** — FIXED. The mechanism matters and the commit message states it correctly: at equal `0,1,0` specificity, `board.css:165 / :176 / :204` (`border-left: Npx solid currentColor`) come **after** the register rules at `:128-139`, so the shorthand's `border-left-color: currentColor` **overrides** the register rule's own `border-left-color`. For those three element types the register EDGE is painted entirely from `color`. With `.register-nominal` declaring no `color`, a nominal row inside a hot lane inherited red and drew a red edge. That is the defect, and `color: var(--nominal)` is the minimal correct cure. The gates lane was empty in the fixture, so I injected two synthetic gates and observed `.signal-name`/`.signal-outcome`/`.signal-at` go `RED@138 → PAPER@130`.
- **(ii) `.car-outcome` inside a chip** — FIXED, and **severity is not flattened**. I injected `outcome: 'error'` on one car: post-fix its `.car-outcome.register-needs-attention` stays `RED@138` inside a `PAPER@130` chip, while the seven nominal outcomes go paper. The fix repairs the calm case without muting the hot one.
- **(iii) `.board-condition` in the chrome** — unchanged and correct: 54 rows render `RED@138` from their own `register-needs-attention`, which is what the server actually raised (`record-unrecognised-fields`). Honest red, not this diff's business (and their repetition is #30).
- **(iv) elements carrying NO register class inside a hot lane** — **still inherit red, and I say so plainly.** Measured residue: `.lane-title` ×3, `.lane-primary` ×3, `.track-title` ×1, plus `.declared-not-observed` (absent from this fixture; I injected one and observed `RED@138`). `.lane-secondary` (`:121`) and `.yard-inventory-count` (`:189`) are immune — they set `--text-dim`.

**Ruling on closure:** issue #31 as written is **closed**. Its text names "every dispatch row, train chip, and outcome … values whose registers are PINNED nominal in board-defs.json (returned, done, APPROVE)" — all 142 of those, and nothing else. The residue is lane-level, and the lane genuinely IS hot; the mockup brief at `docs/design/2026-07-23-ui-mockup-brief.md:46` says "A lane's color is the MOST SEVERE of its contributing facts", so a red lane header is the design, not the bug. `.track-title` and `.declared-not-observed` are the one genuinely open edge (Note 1) — item-level labels wearing the lane's register — but they are neither dispatch rows nor chips nor outcomes, and fixing them means picking a color the owner reserved. Not a blocker.

## 5. THE SENTENCE CHECK — register, producer to pixel

Traced for `state: "returned"` on a dispatch row:

| # | Hop | file:line |
|---|---|---|
| 1 | State word minted by the fold's precedence winner | `board/fold/algorithm.go:10`, `:205`; overdue derived at `:240` |
| 2 | Serialized onto the wire item | `board/fold/output.go:16` `"state": d.State` |
| 3 | Presentational defs loaded from disk, each row's register validated against the closed set | `board/assemble/boarddefs.go:39`, closed set at `:29`, gate at `:70` |
| 4 | Register ASSIGNED on disk | `schema/vocab/board-defs.json` → `liveness[0] = {"id":"returned","label":"Returned","register":"nominal"}` |
| 5 | Attached to the snapshot and serialized | `board/server/poll.go:196` → `:292` `Vocabularies: vocab` → `board/server/snapshot.go:71` `json:"vocabularies"` |
| 6 | Schema gate in the browser (draft 2020-12, real schema file, no second copy) | `board/web/js/validate.js:18`; enum at `schema/yard-snapshot.schema.json` `$defs.register.enum` |
| 7 | Lookup; a miss renders hot by name, never calm | `board/web/js/vocab.js:31-36` |
| 8 | Per-item resolution | `board/web/js/render.js:114` (dispatch), `:91` (car state), `:93` (car outcome), `:106` (gate); lane three-axis most-severe `render.js:48` → `compose.js:66-72` → `:23-25`, order at `:13` |
| 9 | Class emitted | `board/web/js/dom-writer.js:28-30`, applied at `:70`, `:79`, `:117`, `:123`, `:146`, `:164` |
| 10 | **CSS — the diff** | `board/web/css/board.css:128-131`; edge override for chips/signals/rows at `:165`, `:176`, `:204` |
| 11 | Delivered to the browser | `board/web/index.html:7` `&lt;link rel="stylesheet" href="/css/board.css"&gt;`, served by `board/server/handlers.go:20` |
| 12 | Pixel | `.solari-state "returned"` renders `--nominal #d9d5c9` (paper). Pre-fix: `--needs-attention #ff4a3a` (red). |

Hop 10 is the one that was broken, and hop 10 is the only one the diff touches. **The `--nominal` == `--text` claim is TRUE**: `board.css:20` `--text: #d9d5c9`, `board.css:23` `--nominal: #d9d5c9` — so the fix is visually a no-op on calm boards and only removes an inheritance path.

**Taxonomy mirrors — all six agree** (checked mechanically, not by eye):

| Mirror | Value |
|---|---|
| `schema/yard-snapshot.schema.json` `$defs.register.enum` | `[nominal, in-progress, needs-attention]` |
| `board/web/js/compose.js:13` `REGISTER_ORDER` | same, **same order** (severity) |
| `board/web/css/board.css` `.register-*` rules | same set |
| `board/assemble/boarddefs.go:29` `closedRegisters` | same set |
| `board/store/store.go:49` comment | same set |
| `schema/vocab/board-defs.json` values used | same set |

## 6. Doc check

- `board/web/css/board.css:126` — `/* --- the three registers, and NOTHING else colors an element --- */`. **Not invalidated.** It is byte-identical at the parent `38b67c8` (I diffed it), and the diff makes it *more* true, not less. Its intended reading is supplied by `board.css:12-14` ("Every other color in this file is background/structure/typography, never a fourth 'shade of alarm'"). See Note 3.
- `docs/design/2026-07-23-ui-mockup-brief.md:43-47` — the three-severity-colors law. **Still true**: the diff adds no color, uses only `var(--nominal)`, and the register set is unchanged (verified above).
- `grep -rl register docs/ schema/` over all designs/specs/plans/contracts: **no document cites `board.css`'s register rules, `.register-nominal`, `border-left`, or `currentColor`.** Nothing was invalidated, so nothing was owed an update in this commit.
- Every citation in the diff opened and confirmed TRUE: `compose.js` REGISTER_ORDER (`compose.js:13`); "dom-writer.js puts the lane-level register class on the lane container itself" (`dom-writer.js:79`); "`.car-chip`/`.signal`/`.solari-row` draw their register edge with `border-left: … currentColor`" (`board.css:165, :176, :204`); "`.register-in-progress` and `.register-needs-attention` declared both" (verified at parent `38b67c8`); "the vendored validator" (`board/web/vendor/cfworker-json-schema/`, wired at `validate.js:7`). **Zero dead or drifted citations.**

## 7. Guard check

Watched it fire — item 1 above, verbatim red re-derived on a copy. Not an assertion; an observation. CI will keep running it: `.github/workflows/ci.yml:240-277` runs `node --test` in `board/web` with a zero-test refusal, so the new file is picked up by the existing leg.

---

# Findings

### Minor 1 — the guard is weaker than its own header comment claims (`board/web/test/register-css.test.js:7-10, :50-56`)

Three declarations that **re-create the exact #31 defect** pass the guard 6/6 (observed on a copy):

| Injection into `.register-nominal` | Suite |
|---|---|
| `color: inherit;` | **6 pass / 0 fail** |
| `color: currentColor;` | **6 pass / 0 fail** |
| `/* color: var(--nominal); */` (commented out) | **6 pass / 0 fail** |

The file's own comment states the property as *"it declares its own `color` … so no register can ever inherit another's"* (`register-css.test.js:8-10`) — case 1 satisfies the test while the register **does** inherit another's. Related same-class weakness: `findRuleBlock`'s `[^}]*` extraction (`register-css.test.js:38`) is comment-blind, so a `}` inside a comment inside a register block would truncate the extracted block.

Not Major: the guard demonstrably fires on the actual regression class (declaration deleted, wrong property, rule renamed, register added without a CSS rule — attacks A/B/C/D/E/G all red), and no realistic edit produces `color: inherit` on a color-defining register class. Remedy is one line — exclude `inherit|currentColor` and strip `/* … */` before extraction.

### Minor 2 — the disclosed GitNexus deviation's REASONING is false (right action, wrong reason)

The car declined to re-run `analyze`, reasoning "a CSS/test-only change adds no new symbols." That premise is **wrong on both changed paths**:

- `.gitnexus/meta.json` `fileHashes` contains **`board/web/css/board.css`** — the CSS file is indexed, and its hash changed.
- `fileHashes` contains **all seven** pre-existing `board/web/test/*.test.js` files, so the test directory is in scope; the new `register-css.test.js` declares a new top-level function `findRuleBlock` (`register-css.test.js:29`) plus six test registrations — new symbols by any reading.

The **true** reason the car could not comply: worktrees carry no index. `ls -a` in this review worktree shows **no `.gitnexus` directory**, and `.gitnexus/meta.json` `repoPath = <repo>` — running `analyze` would mean writing the shared checkout's index, which every car brief forbids. The action was correct and structurally forced; the justification given would, if reused as precedent, license future cars to skip a `CLAUDE.md`-mandated step on a false premise ("CSS/test-only ⇒ no symbols"). **Conductor action:** re-run `node .gitnexus/run.cjs analyze` on the shared checkout after merge (the index is already behind at `lastCommit = 1182e09`, one commit before this car's base).

### Note 1 — residual lane-level inheritance, measured and out of this issue's scope

Post-fix, 61 text-bearing elements still render red: 54 `.board-condition` (**correct** — their own `register-needs-attention` from the server), 3 `.lane-title` + 3 `.lane-primary` (**design-consistent** — mockup brief `:46`, the lane is genuinely stale), and 1 `.track-title` (`dom-writer.js:114`, no CSS rule declaring color at `board.css:149-152`). `.declared-not-observed` (`dom-writer.js:133`) has **no CSS rule at all** (`grep` confirms) and renders red in a hot lane — I injected one and observed `RED@138`. These two are item-level labels wearing the lane's register, i.e. a thin residue of the issue's ruled-out hypothesis (c). Cheap follow-up ticket (a `color` on `.track-title` / `.declared-not-observed`); correctly deferred here because it picks a visual decision reserved to the owner alongside #29.

### Note 2 — the register taxonomy lives in six places; this diff adds the first mechanical pin between two of them

All six agree today (table above). Before this commit, **zero** edges were mechanically pinned; `register-css.test.js` now pins CSS ↔ `compose.js`. Still unpinned and pre-existing: `compose.js:13` ↔ `$defs.register.enum`, and `boarddefs.go:29` ↔ `$defs.register.enum` (`grep` finds no test asserting either — contrast `sse-event-name.test.js`, which pins `SSE_EVENT_NAME` against the schema and is the exemplar to copy). Law 6 exposure **reduced** by this diff, not created. Worth a ticket, not a finding.

### Note 3 — `board.css:126` is loose but not this diff's debt

`/* the three registers, and NOTHING else colors an element */` sits above a file with 10 class rules that declare `color` (`:61, :68, :73, :121, :130, :134, :138, :189, :215, :221`). Byte-identical at the parent, so not invalidated by this commit, and `board.css:12-14` supplies the intended narrow reading ("never a fourth shade of alarm"). Flagged only so a future reader does not mistake it for a claim the new test enforces.

---

# Constitution check

| Law / rule | Evidence it is honored |
|---|---|
| **Law 1 — no confident falsehood on an information surface** | This was a Law 1 defect on the shop's own truth surface: 142 elements asserted "needs attention" over data that resolved `nominal` (71/71). Measured post-fix, all 142 now render `--nominal`; the hot `error` outcome I injected still renders red inside a calm chip, so the fix removes the falsehood without muting a true alarm. Residual red (Note 1) is *honest* — the lanes are genuinely stale. Retired for the issue as written. |
| **Law 6 — no second copies** | Six mirrors of the register taxonomy exist and all agree (verified mechanically). The diff **adds** a cross-check rather than a copy: the test imports `REGISTER_ORDER` instead of restating it, and attack G proves the import is load-bearing. |
| **Law 7 — no hardcoded taxonomies / the stranger** | `register-css.test.js:16` imports `REGISTER_ORDER` from `compose.js`; adding a 4th register grew the suite 6→8 and failed on the unbacked class. No taxonomy is spelled in the test. |
| **TDD — red-first, non-vacuous** | Red re-derived byte-for-byte on a copy (5 pass / 1 fail, `actual: '\n  border-left-color: var(--nominal);\n'`), failing for the stated reason. Non-vacuity attacked seven ways; six killed it. |
| **Verification honesty (suite / count / SHA / observer)** | Every count in this verdict was observed by me at `9c4730a`: `node --test` 56/56/0; `go test ./...` 5/5 ok; baseline 50/50/0 at `38b67c8`. |
| **Documentation ranks equal to code** | No document invalidated (`grep -rl register docs/ schema/` — nothing cites the CSS register rules); every citation in the diff opened and confirmed true; zero dead citations. |
| **Guard unproven until watched fire** | Watched, twice: the true red, and seven fault injections. Its limits are stated as Minor 1 rather than assumed away. |
| **Reviewer edits nothing** | All injection on a byte-identical scratch copy, deleted after; final `git status --porcelain` empty, `git diff HEAD` empty, `board.css` SHA256 unchanged. |
| **Dispatch hygiene** | No nested delegation. Shared checkout read only (`.gitnexus/meta.json`); the car's worktree never touched. |

Files load-bearing for this verdict, all absolute:
`~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\e92f5a0b-1b9e-4913-98b3-c319b4d5e90b\scratchpad\review-car31\board\web\css\board.css`,
`…\board\web\test\register-css.test.js`,
`…\board\web\js\dom-writer.js`,
`…\board\web\js\render.js`,
`…\board\web\js\compose.js`,
`…\board\web\test\fixtures\real-snapshot.json`,
`…\schema\vocab\board-defs.json`,
`…\docs\design\2026-07-23-ui-mockup-brief.md`,
`<repo>\.gitnexus\meta.json`.

```starcar-artifact
outcome: APPROVE

findings: 0 Major, 2 Minor, 3 Notes.
  MINOR-1 board/web/test/register-css.test.js:7-10,:50-56 - the guard accepts three
    declarations that re-create the exact issue 31 defect: "color: inherit", "color:
    currentColor", and a commented-out "/* color: var(--nominal); */" each pass 6 pass /
    0 fail (observed on a byte-identical copy). The file's own comment claims the rule
    "declares its own color ... so no register can ever inherit another's", which case 1
    violates while passing. Related: findRuleBlock's [^}]* extraction at :38 is
    comment-blind. Not Major - the guard fires on every realistic regression (rule
    deleted, wrong property, rule renamed, register added without a CSS rule: attacks
    A/B/C/D/E/G all red). Remedy is one line: exclude inherit|currentColor and strip
    comments before extraction.
  MINOR-2 disclosed GitNexus deviation - right action, false reasoning. The car said a
    CSS/test-only change "adds no new symbols". .gitnexus/meta.json fileHashes contains
    board/web/css/board.css AND all seven pre-existing board/web/test/*.test.js files, and
    the new test declares a new top-level function findRuleBlock at register-css.test.js:29.
    The true reason: worktrees carry no .gitnexus (none in this worktree; meta.json
    repoPath is the shared checkout), so analyze would require touching the shared
    checkout every car brief forbids. Conductor must re-run analyze post-merge; the index
    is already behind at lastCommit 1182e09.
  NOTE-1 residual lane-level inheritance, measured: 61 text elements still red post-fix -
    54 .board-condition (correct, server-raised), 3 .lane-title + 3 .lane-primary
    (design-consistent, mockup brief line 46, lanes genuinely stale), 1 .track-title
    (dom-writer.js:114, no color rule at board.css:149-152). .declared-not-observed
    (dom-writer.js:133) has no CSS rule at all; injected one and observed RED. Item-level
    labels wearing the lane's register - a thin residue of hypothesis (c). Out of issue
    31's named scope; cheap follow-up ticket.
  NOTE-2 the register taxonomy lives in six places, all agreeing today. This diff adds the
    FIRST mechanical pin between any two (CSS to compose.js). Still unpinned: compose.js:13
    to schema $defs.register.enum, and boarddefs.go:29 to the same enum. Law 6 exposure
    reduced, not created. Copy sse-event-name.test.js's pattern.
  NOTE-3 board/web/css/board.css:126 "the three registers, and NOTHING else colors an
    element" is loose (10 class rules declare color) but byte-identical at the parent, so
    not invalidated by this commit; board.css:12-14 gives the intended narrow reading.

abstract: Adversarial sentence-check review of Car 31, commit 9c4730a on base 38b67c8,
  issue 31 (first light rendered everything needs-attention red). Base verified: HEAD
  9c4730a on car/31-register-css, parent 38b67c8, which is an ancestor of dev tip 0667521;
  dev has not touched either changed file. Diff is exactly two files, +60/-0. Scope
  discipline honored: dom-writer.js, render.js and compose.js untouched.
  RED re-derived on a byte-identical scratch copy, byte-for-byte matching the car's
  report: 5 pass / 1 fail, actual '\n  border-left-color: var(--nominal);\n', failing for
  the stated reason. Seven vacuity attacks: emptied stylesheet 0/6, renamed rule 4/2,
  background-color 5/1, -webkit-text-fill-color 5/1, missing border-left-color 5/1, and a
  4th register added to compose.js REGISTER_ORDER grew the suite 6 to 8 and reds - proving
  Law 7 import, not a hardcoded taxonomy.
  GREEN run by me at 9c4730a: node --test in board/web tests 56, pass 56, fail 0; go test
  ./... in board/ 5/5 packages ok; baseline at 38b67c8 by full-tree archive 50/50/0,
  confirming the commit's "50 baseline + 6 new".
  Fix correctness derived independently, not from the report. Wire vocabularies in the
  captured snapshot are byte-equal to schema/vocab/board-defs.json across positions,
  outcomes, roles and liveness, and every id the data uses is recognised - zero detector
  misses, so hypothesis (a) is genuinely dead. buildBoardViewModel over the real snapshot
  gives a per-item register tally of nominal 71 of 71; the three live lanes are hot only
  because freshness is stale 555000ms. Rendering through dom-writer into the minidom shim
  and computing effective color against all 11 color declarations in board.css: 142 of 216
  text-bearing elements move red to paper - 110 solari rows, 24 car-chip spans, 8 car
  outcomes - exactly the issue's named symptom. Mechanism confirmed: at equal 0,1,0
  specificity the later border-left shorthands at board.css:165, :176 and :204 override the
  register rule's border-left-color, so those three element types paint their register edge
  from currentColor, which is why a missing color produced a red edge on a nominal row.
  Injected two synthetic gates and watched .signal-name/.signal-outcome/.signal-at go RED
  to PAPER; injected an "error" outcome and confirmed it stays RED inside a PAPER chip, so
  severity is not flattened. Residual red is lane-level and honest.
  Sentence check traced twelve hops for state "returned": fold/algorithm.go:10,:205 to
  fold/output.go:16 to assemble/boarddefs.go:39,:29,:70 to schema/vocab/board-defs.json to
  server/poll.go:196,:292 to server/snapshot.go:71 to web/js/validate.js:18 to
  web/js/vocab.js:31-36 to web/js/render.js:114 and compose.js:66-72,:13 to
  dom-writer.js:28-30,:164 to board.css:128-131,:204 to index.html:7 and
  server/handlers.go:20 to pixel. Hop 10 was the only broken hop and the only hop touched.
  --nominal equals --text (#d9d5c9 at board.css:20 and :23) confirmed, so the fix is a
  visual no-op on calm boards and only removes an inheritance path. Six taxonomy mirrors
  compared mechanically and all agree.
  Doc check: no design, spec, plan or contract cites the CSS register rules, so nothing was
  invalidated; every citation in the diff and its comments opened and confirmed true, zero
  dead or drifted citations. Guard check satisfied by observation, not assertion.
  Constitution: Law 1 defect retired for the issue as written, Law 6 exposure reduced, Law
  7 honored by proven import, TDD red-first and non-vacuous. Reviewer edited nothing:
  final git status --porcelain empty, git diff HEAD empty, board.css SHA256 DC8F2B68 to
  15FBA unchanged from review start, all injection performed on a scratch copy since
  deleted.
```