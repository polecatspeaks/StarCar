<!-- starcar-integrity: sha256=5f26a62cf3cf33df44d5f1a02105dc90953ea0f0e6dd7601e0e06856fe29a596 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car view-30 review - round 1 (REJECT, documentation)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial sentence-check review with computed-style (Playwright) gate
Round: 1
Target: `commits 9e5261f, b9595b9, 8658011 on car/view-30 (#30 four-part design)`
Base reviewed: `8658011ae8572095794773cb7b39cba4bfa4f483`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `afe1a2c703e2e615e`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `8658011ae8572095794773cb7b39cba4bfa4f483` |

| Dispatch, the locator within the session | `afe1a2c703e2e615e` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 8658011ae8572095794773cb7b39cba4bfa4f483
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# ADVERSARIAL REVIEW — Car `view-30-car-r1` (issue #30) — **REJECT**

**3 Major, 4 Minor, 5 Notes.** Base verified: worktree `<repo>-wt\review-view-30` at `8658011ae8572095794773cb7b39cba4bfa4f483`, clean tree before and after (all fault injections reverted byte-identical, verified by `git hash-object`).

The **code** in this diff is good: the mechanism is correct, the pin is real, the rendering is right down to the computed pixel, and I could not break it. **The documents are not.** Three landed design/contract statements that this diff made false were left standing, and one document amendment asserts behaviour the shipped code does not have and that two green tests contradict. Documentation ranks equal to code here, so that is a REJECT.

---

## Suites — run myself, at `8658011`

| Suite | Observed | Car claimed |
|---|---|---|
| `board` Go, `go test ./...` (5 pkgs) | **70/70 pass, 0 fail** (top-level `--- PASS` count; 90 incl. subtests) | 70 ✓ |
| `board/web` `node --test` | **68 real tests pass, 0 fail**; TAP trailer `# tests 70 / # pass 70 / # fail 0` (70 = 68 tests + 2 zero-test support files, `test/minidom.js` and `test/support/real-board-server.js`) | 68 ✓ |
| `scripts/tests` | **Total 182, Passed 181, Failed 0, Skipped 1** (skip = `run-session-start-guards.sh` agent-pull runner, #50) | 182 ✓ (expected 181/0/1 detached) |
| `scripts/store-checks` | **172/172, 0 failed** (store-derived: 167 `artifacts/**/*.json` records + 5 suite-level) | store-sized ✓ |
| `scripts/probes` | **24/24, 0 failed** | 24 ✓ |

Test-count deltas re-derived statically, independent of the car's arithmetic:
`git grep -h "^func Test"` on `board/**/*_test.go` — `4f0182d`: **66**, `9e5261f`: **69**, `b9595b9`: **70**, `8658011`: **70**. `board/web/test`: base 54 → HEAD 62 `test(` declarations, **+8** (3 dom-writer, 5 render), matching 60 → 68 real tests.

---

## MAJOR findings

### MAJOR-1 — Design **Rule 4** and the gating matrix that quotes it were invalidated by `9e5261f` and left stale

`docs/design/2026-07-21-v0-yard-skeleton-design.md:184-185`:

&gt; **Rule 4:** the detector's register is `needs-attention`, deliberately - the one alarm that is about the board rather than the yard.

`docs/contracts/gating-matrix.md:45` quotes it verbatim as the reason the detector surface is never suppressed.

`9e5261f` made both false: `board/store/condition_severity.go:42` declares `"discovery": TierNote`, and `RegisterForCode` (`:92-97`) returns `"nominal"` for it. Observed on the wire in my own live run: `{"code":"discovery","detail":"outcome: totally-made-up-outcome","register":"nominal"}`.

The car's §12b amendment (`:473-490`) names and supersedes **§6's row 335 only**. Neither `docs/contracts/gating-matrix.md` nor §5.2 appears in any of the three commits' file lists (`git show --stat 9e5261f b9595b9 8658011`). Rule 4 is the *composition rule* the whole view is built on, and the gating matrix is a named contract document — a stale one is a lying canary on a truth surface, and this is the North Star rule verbatim: the commit that invalidates a document updates it in the same commit.

Aggravating: the gating-matrix row's rationale exists specifically to say this alarm is *never softened*; post-#30 a discovery is calm **and** collapsed behind chrome by default. Whether that is right is settled (the owner ruled it), but the contract that says otherwise cannot be left on the page.

### MAJOR-2 — §12b over-claims its supersession: `position`/`role` did **not** change register

`docs/design/2026-07-21-v0-yard-skeleton-design.md:474-479` quotes §6's row in full — which reads "Unrecognised `kind`/`outcome`/**`position`/role**" — and then rules: "NOTE-tier renders `nominal`, not `needs-attention` … only the register changes."

For `position` and `role` that is **false**:
- `board/fold/algorithm.go:110-122` mints discoveries **only** for unrecognised `kind` and `outcome`. An unrecognised position or role produces no board condition at all, so `condition_severity.go` cannot possibly have changed it.
- The register for those still resolves `needs-attention` at `board/web/js/vocab.js:36`, reached via `board/web/js/compose.js:31` `positionRegister` and `board/web/js/render.js:155`. Pinned green at HEAD, observed in my run: TAP `ok 70` — *"describeVocab: an UNRECOGNISED id renders its raw id verbatim as the label, register needs-attention, never guessed as calm."*

A reader taking the supersession at face value concludes unrecognised positions now render calm. They do not.

### MAJOR-3 — The mockup-brief amendment asserts CALM for a path that is still HOT, and orphans an in-code citation

`docs/design/2026-07-23-ui-mockup-brief.md:87-96`. The diff **deleted the word "hot"** from a landed, still-true claim and appended: *"a 'discovery' is NOTE-tier … and therefore renders CALM, not hot - the state word this bullet's own example uses (an unrecognised dispatch STATE, not an outcome) is a different board-condition path (fold-fault/discovery via `board/server/poll.go`)."*

Both halves are wrong:
1. An unrecognised **dispatch state word is not a fold discovery at all** (`board/fold/algorithm.go:110-122` — kind and outcome only). Its path is `board/web/js/render.js:185` → `board/web/js/vocab.js:32-36`, entirely view-side, untouched by this diff.
2. It still renders **hot**, pinned green at HEAD and observed by me: `board/web/test/render.test.js:217` `assert.equal(item.stateRegister, 'needs-attention')` — TAP `ok 55`, *"discovery rendering: an unrecognised dispatch state word renders HOT, BY NAME, VERBATIM."* The car left that test untouched and passing while writing the opposite into the design doc.

Orphaned citation in the same class, left stale by the same commit — `board/web/js/vocab.js:9-11`:
&gt; `// rev 5 S5.2, mockup brief "the discovery state") renders it hot, BY NAME, verbatim`

That comment cites the exact bullet whose "hot" was deleted. The code (`vocab.js:36`) is right; the design doc is the thing that is now wrong, and the citation no longer resolves.

*Premise check on the brief's framing:* the brief called this "append-only house style." I checked — there is **no** append-only rule for design docs in this repo (`append-only` appears only for the artifact store and the friction log; the sole prior amendment precedent is `2026-07-21-v0-yard-skeleton-design.md:462`). So the *inline* placement is not itself a violation and I am not charging it. The **deletion of a true word** and the **false replacement claim** are the finding.

---

## Minor findings

**MIN-1 — the two new outcome defs sit outside the pin that protects their eight siblings.** `scripts/tests/BoardDefs.Tests.ps1:41-62`'s `$script:PinnedRegisters.outcomes` table is a **subset** check, so `completed`/`approve-for-merge` are the only outcomes in `schema/vocab/board-defs.json` with no by-name register pin. **Fault-injected and proven:** flipping `completed` to `needs-attention` in the committed file → `BoardDefs.Tests.ps1` still **11/11 passed, 0 failed** (reverted byte-identical, `bd642be` → `bd642be`). Contrast the same file's own MANDATORY non-vacuity test, which proves a flipped `REJECT` *is* caught by name. Compounding: `board-defs.json:2`'s `$comment` opens "THE REGISTER ASSIGNMENTS ARE PINNED (plan task 2.4…)" and the car's appended sentence does not say these two are the exception. Two lines in the pinned table closes it.

**MIN-2 — the AST scanner's skip is broader than its stated intent.** `board/store/condition_severity_test.go:55-57` skips **every** `*ast.SelectorExpr` Code value; the doc comment (`:40-43`) justifies it narrowly as "a simple field-selector pass-through (`Code: c.Code`)". **Fault-injected and proven:** I added a genuinely new code supplied as a qualified selector — `WireBoardCondition{Code: time.RFC3339, …}` in `board/server/poll.go` — and `TestConditionSeverityMappingMatchesEmittedCodes` printed **`ok`**, silently blind (reverted byte-identical, `1ada3d4` → `1ada3d4`). Harm is bounded (`RegisterForCode`'s Law 1 default renders it hot, never silently calm), which is why this is Minor. One-line tightening: skip only when `Sel.Name == "Code"`.

**MIN-3 — the count disclosure is incomplete.** `b9595b9`'s message says "board Go: 71/71 (base 66 + 5)"; truth is **70 (base 66 + 4)** — self-disclosed per the brief, and I confirm 70 is correct. But `9e5261f`'s message also states "board Go: 70/70" at a commit whose actual count is **69**; the parenthetical does flag that the fourth test lands "in the next commit," so it is a forward-looking end-state figure, but it is not true at its own SHA and was not part of the disclosure. Under the verification-honesty rule (suite / count / SHA / observer), a count is a claim about the SHA it names. History cannot be rewritten and should not be — the remedy is exactly this verdict carrying the corrected figures.

**MIN-4 — an ambiguous count in the §12b amendment.** `docs/design/2026-07-21-v0-yard-skeleton-design.md:485-487`: "observed live in the real store, `outcome: completed` x1, `outcome: approve-for-merge` x1 as of this car's base." Under the board-condition reading this is **true** (I confirmed the fold dedups by detail — `board/fold/algorithm.go:113,119` `if !contains(discoveries, d)` — so each distinct value yields exactly one condition). Under the natural "records in the store" reading it is **false by 4x and 5x** and contradicts `schema/vocab/outcomes.json:2`'s own `$comment` ("4 and 5 returned-*.json records respectively"), landed by the same car in the same train. A design doc readable two ways will be read both ways.

---

## Notes (no action required, recorded for the record)

- **N-1:** `summariseBoardConditionGroups` (`render.js`) buckets `in-progress` groups into "note(s)". Unreachable today — the only board-condition register producers are `RegisterForCode` (nominal/needs-attention only) and three client sites all hardcoding `needs-attention` (`app.js:41`, `ingest.js:44`, `render.js:107`). Disclosed in the code comment. Correct call.
- **N-2 (PRE-EXISTING, not this car's):** `render.js:100-101`'s gloss *"Rule 4 (design S5.2): a board condition's register is authoritative from the server"* does not match the design's actual Rule 4 text (`:184-185`). Verified present at base: `4f0182d:board/web/js/render.js:35-36`. The car's new comment at `render.js:27` propagates the inherited gloss. The deviation rationale survives on the merits regardless (see below).
- **N-3:** the car's derivation globbed `returned-*.json` (**81** files); the server scans `artifacts/**/*.json` (`store.go:150,172-179`) — **167** files, **106** with `kind: returned`. The extra 25 (under `artifacts/reviews/`) all carry already-declared outcomes, so the conclusion is unaffected, but the method was narrower than the mechanism it was reasoning about.
- **N-4:** the CI-visible count for `board/web` at HEAD is `# tests 70` (`.github/workflows/ci.yml:363-370` parses that trailer). 68 is the honest test count; the 2-test gap is a pre-existing discovery artifact (`minidom.js`, `support/real-board-server.js` match Node's default `**/test/**` glob), not introduced here.
- **N-5:** screenshot-drift and user-facing-doc checks run and **clear**: `docs/screenshots/2026-07-23-first-light.png` is framed below the chrome, so the strip is not in it; no user-facing document (`README.md`, `ONBOARDING.md`, `docs/setup.md`, `docs/glossary.md`) describes the board-conditions strip. `docs/glossary.md:109-112` is register-agnostic and survives.

---

## THE COMPUTED-STYLE GATE (Playwright, real Chromium, real Go server, real store)

I built the server from this worktree via `board/web/test/support/real-board-server.js` (the house pattern), on an ephemeral port (4772/4773 — 4600 left alone), and drove it with `playwright@1.61.1` Chromium at 1280x900. Probe file was created at `board/web/_review_probe.mjs`, run, and **deleted**; `git status --porcelain` is empty.

**Run A — the REAL `artifacts/` store, untouched:**
```
board conditions on the wire: []
COLLAPSED STATE: { "stripPresent": false, ... }
lanes: Dispatches top=71 … (viewportH 900)
```
→ **(d) CONFIRMED end to end.** Both old discoveries are gone from the live board — not suppressed, but *no longer true*, because `schema/vocab/outcomes.json` now declares the words. The strip element is not rendered at all (`dom-writer.js:67` guard). Quiet-by-declaration, observed.

**Run B — a COPY of the store in `%TEMP%` (never the real store) with three injected records:** two valid `returned` records carrying undeclared outcomes, one carrying an undeclared field. Wire payload:
```
{"code":"record-unrecognised-fields", …, "register":"needs-attention"}
{"code":"discovery","detail":"outcome: totally-made-up-outcome","register":"nominal"}
{"code":"discovery","detail":"outcome: another-made-up-outcome","register":"nominal"}
```
Computed style, collapsed:
```
stripTag: "DETAILS", stripOpenAttr: false, stripOpenProp: false
summaryText: "1 FLAG + 2 notes"
summaryColor: "rgb(255, 74, 58)"        &lt;- --needs-attention #ff4a3a
groupsVisibleCollapsed: false
lanes: Dispatches top=109  (viewportH 900)
```
Computed style, expanded:
```
group "record-unrecognised-fields (x1)"  color rgb(255, 74, 58)
group "discovery (x2)"                   color rgb(217, 213, 201)   &lt;- --nominal #d9d5c9
instances: each carries its OWN register-* class and its own resolved color
```

- **(a) PASS** — native `&lt;details&gt;`, no `open` attribute, groups list `checkVisibility() === false`; the first yard lane sits at y=109 in a 900px viewport, well above the fold. Screenshot confirms: a single red `▶ 1 FLAG + 2 notes` line, then `DISPATCHES`.
- **(b) PASS** — the collapsed summary line's **computed** color is `rgb(255,74,58)`, the `--needs-attention` token, not a class-name assertion. Most-severe-wins across a FLAG group and a NOTE group, matching `REGISTER_ORDER` (`compose.js:13`, `rank` at `:15-20`).
- **(c) PASS** — expanding shows one row per code with `(xN)` counts and every per-instance detail verbatim, nothing discarded.
- **The finding a DOM test could never have produced:** the NOTE group renders `rgb(217,213,201)` **inside** a `register-needs-attention` strip. `.board-condition-instance` (`board.css`) deliberately declares no color and relies on its own `register-*` class — the #31 cascade-inheritance defect does **not** recur. This is exactly the #40 doctrine case, and the browser is the only witness.

Screenshots: `…\scratchpad\runB-injected-collapsed.png`, `…\scratchpad\runB-injected-expanded.png`.

---

## Fault injection I ran myself (all reverts byte-identical)

| Injection | Result | Revert |
|---|---|---|
| Remove `"record-unrecognised-fields"` from `conditionSeverity` | `condition_severity_test.go:173: code "record-unrecognised-fields" is emitted by production source under board/ but has no conditionSeverity entry (#30)` | `f26cda1` → `f26cda1` ✓ |
| Add unused `"reviewer-fault-injection-probe"` | `condition_severity_test.go:184: conditionSeverity declares a tier for code "reviewer-fault-injection-probe" but no production source under board/ emits it - stale mapping entry (#30)` | `f26cda1` → `f26cda1` ✓ |
| New code as a qualified selector (`Code: time.RFC3339`) in `poll.go` | **`ok`** — blind spot (MIN-2) | `1ada3d4` → `1ada3d4` ✓ |
| `strip.setAttribute('open','')` in `dom-writer.js` | `✖ #30 PLACEMENT … AssertionError: COLLAPSED by default - the summary line is chrome, the lanes stay above the fold` (6 pass / 1 fail) | `43aaab6` → `43aaab6` ✓ |
| Flip `completed` register in `board-defs.json` | **11/11 passed** — uncaught (MIN-1) | `bd642be` → `bd642be` ✓ |

**Both directions of the car's set-equality pin reproduce exactly as claimed, failing BY NAME.** That claim is true and I could not shake it.

**Store tally, re-derived independently (never copied):** 81 `artifacts/**/returned-*.json`, **0 parse errors** — `APPROVE 25, done 19, REJECT 17, done-with-findings 6, approve-for-merge 5, completed 4, CONFIRM 3, APPROVE-WITH-REBASE-LIST 2` (sums to 81). Identical to the car's figures. Widening to all 167 store files by `kind` gives 106 `returned` records; the undeclared set is unchanged (see N-3).

---

## THE SENTENCE CHECK

### Trace 1 — the severity value, mint → pixel

| Hop | File:line | Value |
|---|---|---|
| 1. Minted | `board/fold/algorithm.go:112-121` (dedup `contains`) → `board/server/poll.go:270` | `Code:"discovery"` |
| | also `board/store/store.go:203,219,314`; `board/assemble/assemble.go:54,74,84,143,156`; `board/assemble/boarddefs.go:45,59,78`; `board/server/poll.go:112,129,267` | 14 codes total |
| 2. Severity mapped | `board/store/condition_severity.go:32-83` (map), `:92-97` `RegisterForCode` | `TierNote` → `"nominal"`; all else incl. undeclared → `"needs-attention"` |
| 3. Store→wire copy | `board/server/poll.go:380` `toWireCondition` — verbatim `{Code, Detail, Register}`, no re-derivation | unchanged |
| 4. Snapshot assembly | `board/server/poll.go:333` `Board: conditions` | array on the wire |
| 5. Schema constraint | `schema/yard-snapshot.schema.json` `$defs.boardCondition` requires `code`/`detail`/`register`; `register` → `$defs.register` `enum:[nominal,in-progress,needs-attention]` | **UNTOUCHED and did not need touching** — `nominal` was already legal |
| 6. Browser ingest | `board/web/js/ingest.js` schema gate — accepted the nominal-register payload live (strip rendered) | passes |
| 7. View grouping | `board/web/js/render.js:110` `groupBoardConditions` → `compose.js:23-25` `mostSevereRegister`, ranked by `compose.js:13` `REGISTER_ORDER` (set-equal to the schema enum, pinned TAP `ok 41`) | per-group register |
| 8. DOM | `board/web/js/dom-writer.js:97,104` `registerClass(...)` → `class="board-condition-group register-nominal"` | class emitted |
| 9. CSS | `board/web/css/board.css:166-169` `.register-nominal{color:var(--nominal)}`; token `:root` `--nominal:#d9d5c9` at `:23` | resolved |
| 10. **Computed pixel** | Chromium `getComputedStyle` | **`rgb(217, 213, 201)`** — matches `#d9d5c9` exactly |

Hand-maintained mirrors checked for the register field: `WireBoardCondition` (pass-through, `poll.go:380`), the wire schema (`$defs.boardCondition`), `board/web/test/fixtures/real-snapshot.json` (carries `board` with register — still schema-shaped), `schema/vectors/fold/*` (fold vectors do not carry registers; TAP-equivalent Go vector test green). No mirror dropped the field.

### Trace 2 — a declared outcome, declaration → absent row

| Hop | File:line | Effect |
|---|---|---|
| 1. Declared | `schema/vocab/outcomes.json` `values[]` += `"completed"`, `"approve-for-merge"` | recognition set |
| 2. Loaded | `board/fold/loaders.go:23-27` `LoadVocab` → `board/server/poll.go:107,115` `s.vocab` | in memory |
| 3. Consumed | `board/fold/algorithm.go:117-121` `if o, ok := r.str("outcome"); ok &amp;&amp; o != "" &amp;&amp; !vocab.hasOutcome(o)` | condition **not** minted |
| 4. Wire | `board/server/poll.go:269-271` loop over `out.Discoveries` emits nothing | `board: []` |
| 5. **Observed** | live GET `/api/snapshot`, real store | **`board conditions on the wire: []`** |
| 6. View | `render.js:110` → `boardConditionGroups: []` → `dom-writer.js:67` guard | strip not appended |
| 7. **Observed** | Chromium | **`stripPresent: false`** — the row is absent, not calm-but-present |
| 8. Presentation arm | `schema/vocab/board-defs.json` `outcomes[]` → wire `vocabularies.outcomes` → `board/web/js/vocab.js:32-36` `describeVocab` | recognised → `nominal`, not the needs-attention fallback |
| 9. Pin binding the pair | `scripts/tests/BoardDefs.Tests.ps1:110-114` — every `outcomes.json` value must have a `board-defs.json` def | **coverage direction pinned** ✓ (register direction: see MIN-1) |

---

## Adjudications the brief asked for

**1. The disclosed judgment call — `record-unrecognised-fields` at FLAG-tier: CONFIRMED, the car is right.**
I opened both cited rows and the citations are accurate at HEAD: `:333` (unknown fields) and `:335` (discovery). The discovery row carries "a discovery, not a bug"; the unknown-fields row carries no such framing — the car's stated reasoning holds. Two further pieces the car did not cite make it stronger: (i) `board/fold/algorithm.go:110-122` shows there is **no declaration mechanism** for record fields the way `outcomes.json` is one for outcomes — silencing an unrecognised field requires a *code* change to the typed decode (D17, design `:131`), so the #26-style quiet path the brief hypothesised does not exist yet, and NOTE-tier would leave a producer/reader contract drift permanently calm behind collapsed chrome (Law 4, silent loss); (ii) **empirically it does not cry wolf** — my Run A against the real 167-record store produced `board: []`, so FLAG-tier costs nothing today. The severity-philosophy counter-argument ("expected patterns are NOTES") would bite only once a declaration surface exists; when #26-style declaration lands for field names, this entry should be revisited, and `condition_severity.go:52-58` already says exactly that in the file where the next reader will find it. Good judgment, honestly disclosed, correctly conservative.

**2. The disclosed deviation — no wire-schema change: UPHELD.**
Verified independently, not accepted: `schema/yard-snapshot.schema.json` appears in none of the three commits' file lists. `$defs.boardCondition` already carried `code` (the grouping key) and `register` constrained to the three-value enum including `nominal`, so a discovery flipping calm stays schema-valid with no edit. Grouping is a total function of data already on the wire, and no instance detail is discarded (`render.js` `instances[]`). Observed end to end: a nominal-register discovery crossed the browser-side ingest gate and grouped correctly. The car's *rationale* leans on the inherited Rule-4 gloss (N-2), but the deviation is right on the merits under the design's actual text too — nothing in Rule 4 as written forbids view-side rollup. Nothing needed the schema.

**3. The unscoped enhancement — `overallBoardConditionsRegister`: KEEP, scope discipline satisfied.**
Not truly unscoped: the owner's design comment names "the register three-color law binds rendering" and HAVAGLANCE as binding laws, and HAVAGLANCE is *total transmission in a single look*. A collapsed strip whose line carries no severity signal hides a FLAG behind a click — that fails the named acceptance test. So this is the law applied, not scope creep; it is disclosed, ~4 lines, reuses `compose.js`'s existing combinator rather than a second copy, and carries its own test (TAP `ok 54`). **Correctness confirmed against the pinned taxonomy:** `mostSevereRegister` ranks by `REGISTER_ORDER = ['nominal','in-progress','needs-attention']` (`compose.js:13`), which TAP `ok 41` pins set-equal to `schema/yard-snapshot.schema.json`'s `$defs.register.enum`; unknown strings rank *most severe* (`compose.js:15-20`), never calm. Observed: one FLAG group + one NOTE group → collapsed line `rgb(255,74,58)`. Most-severe-wins, matching the pinned order.

---

## CONSTITUTION CHECK

| Law / doctrine | Honored? | Evidence |
|---|---|---|
| **Register three-color law** | ✓ | `REGISTER_ORDER` unchanged and set-equal to the schema enum (TAP `ok 41`); every new element carries exactly one `register-*` class; computed colors resolve to the three `:root` tokens and nothing else. |
| **HAVAGLANCE** | ✓ | Collapsed line reads `1 FLAG + 2 notes` in `rgb(255,74,58)` with lanes at y=109 in a 900px viewport — severity and volume transmitted in one look without a click. |
| **Severity philosophy (NOTES vs FLAGS)** | ✓ | `condition_severity.go:32-83` classifies per class with a cited reason per entry; the wolf-crier test is empirical — real store yields zero conditions. |
| **Law 1 (no confident falsehood)** | **✗ MAJOR-2, MAJOR-3** | `§12b` asserts nominal for `position`/`role`, which render `needs-attention` (`vocab.js:36`, TAP `ok 70`); the mockup-brief amendment asserts CALM for a path pinned HOT at `render.test.js:217` (TAP `ok 55`). Honored in code: `RegisterForCode:92-97` never guesses calm on an undeclared code (`TestUndeclaredCodeFailsLoudNeverCalm`). |
| **Law 4 (never silently drop)** | ✓ | `groupBoardConditions` preserves every instance detail verbatim; observed all 3 injected details present in the DOM. |
| **Law 6 (no second copy)** | ✓ | One owned severity map replaces 14 hardcoded literals; `mostSevereRegister` reused, not reimplemented. `outcomes.json` (recognition) vs `board-defs.json` (presentation) are distinct concerns bound by a mechanical coverage pin (`BoardDefs.Tests.ps1:110`) — **not** a hand-maintained mirror. Register direction unpinned for the two new ids (MIN-1). |
| **Law 7 (the stranger)** | ✓ | No hardcoded taxonomy added; vocabularies stay data. No user-facing doc invalidated (N-5). |
| **Documents rank equal to code** | **✗ MAJOR-1** | `docs/contracts/gating-matrix.md:45` and `design:184-185` (Rule 4) were made false by `9e5261f` and not updated in that commit. |
| **Red-first / non-vacuity** | ✓ | Reproduced independently: the placement pin fails by name under injection; both directions of the severity pin fail by name. |
| **#30 citation standard** | ✓ | Every new unit carries `#30`: `condition_severity.go:4,29`; `condition_severity_test.go` throughout; `quiet_by_declaration_test.go:9`; `render.js:22,52,60`; `dom-writer.js:71,91`; `board.css` block headers; both vocab `$comment`s; all 8 new test names. |
| **Store never mutated by review** | ✓ | Fault injection used a `%TEMP%` copy via `STARCAR_STORE_PATH`; `git status --porcelain` empty at exit; HEAD `8658011`. |

---

## What REJECT requires (all documentation; no code change needed)

1. Amend `docs/design/2026-07-21-v0-yard-skeleton-design.md:184-185` (Rule 4) and `docs/contracts/gating-matrix.md:45`, in the same commit.
2. Correct §12b to scope the supersession to the `kind`/`outcome` **board-condition** register, and state that `position`/`role` still render `needs-attention` view-side.
3. Correct `docs/design/2026-07-23-ui-mockup-brief.md:87-96` — restore "hot" for the dispatch-state-word path (it is still true), scope the amendment to the board-conditions strip, and update the now-orphaned citation at `board/web/js/vocab.js:9-11`.
4. Minors: add the two outcomes to `BoardDefs.Tests.ps1`'s pinned table; tighten the selector skip in `condition_severity_test.go:55-57`; disambiguate the `x1` counts in §12b; carry MIN-3's corrected counts forward.

The mechanism, the pin, the vocabulary work and the rendering are all sound and I would approve them on their own. Fix the documents and this lands.

```starcar-artifact
task-id: view-30-review-r1
outcome: REJECT
findings: 3 Major, 4 Minor, 5 Notes. MAJOR-1 - commit 9e5261f invalidated design Rule 4 (docs/design/2026-07-21-v0-yard-skeleton-design.md:184-185, "the detector's register is needs-attention, deliberately") and the contract that quotes it verbatim (docs/contracts/gating-matrix.md:45); neither was updated in that commit, and the car's 12b amendment supersedes section 6's row only. MAJOR-2 - the 12b amendment over-claims: it supersedes a section 6 row covering kind/outcome/position/role and rules the register becomes nominal, but unrecognised position/role never produce a board condition (board/fold/algorithm.go:110-122 discovers kind and outcome only) and still render needs-attention (board/web/js/vocab.js:36, board/web/js/compose.js:31), pinned green at HEAD by TAP ok 70. MAJOR-3 - docs/design/2026-07-23-ui-mockup-brief.md:87-96 deleted the word "hot" from a still-true claim and appended an amendment asserting the discovery-state bullet's subject renders CALM and travels the fold-fault/discovery path; both are false - an unrecognised dispatch state word is not a fold discovery and still renders needs-attention, pinned at board/web/test/render.test.js:217 (TAP ok 55), and the edit orphaned the in-code citation at board/web/js/vocab.js:9-11. MIN-1 - completed and approve-for-merge are absent from scripts/tests/BoardDefs.Tests.ps1's pinned register table, so their registers are the only outcome registers with no by-name pin; proven by flipping completed to needs-attention and observing 11/11 still passed. MIN-2 - condition_severity_test.go:55-57 skips every SelectorExpr Code value though its comment claims only pass-throughs; proven by injecting Code taken from a qualified selector into board/server/poll.go and observing the pin print ok. MIN-3 - commit b9595b9's message states 71/71 (base 66 plus 5); true count is 70 (base 66 plus 4), self-disclosed, but the disclosure omits that 9e5261f's message states 70/70 at a commit whose true count is 69. MIN-4 - the 12b amendment's parenthetical "outcome: completed x1, outcome: approve-for-merge x1" is true as a board-condition count but false as a record count, and contradicts schema/vocab/outcomes.json's own comment (4 and 5) landed in the same train. Notes - in-progress bucketed as a note is unreachable and disclosed; the Rule 4 gloss at render.js:100 is pre-existing at base 4f0182d; the derivation globbed 81 returned-star files where the server scans 167 with 106 returned, conclusion unaffected; the CI-visible node trailer is 70 because two zero-test support files are counted, 68 is the honest figure; screenshot and user-facing-doc drift checked and clear.
abstract: Full independent re-run at 8658011 in the detached worktree, tree clean before and after. Suites observed by me - board Go 70/70 across 5 packages, board/web node --test 68 real tests passing (TAP trailer 70, including two zero-test support files), scripts/tests 182 total with 181 passed 0 failed 1 skipped, scripts/store-checks 172/172, scripts/probes 24/24. Test-count deltas re-derived statically per commit - base 66, then 69, then 70, then 70 - confirming the car's corrected figure and exposing one further uncorrected count. I re-derived the store tally from scratch and matched the car exactly at 81 files, zero parse errors, completed 4 and approve-for-merge 5. Five fault injections run, every revert byte-identical by git hash-object - both directions of the severity set-equality pin fail BY NAME exactly as claimed, the collapsed-by-default DOM pin fails by name, and two gaps were proven where the instruments are silent. The Playwright computed-style gate ran a real Chromium against the real Go server on an ephemeral port, twice - against the untouched store, where the wire carried an empty board array and no strip element rendered at all, proving quiet-by-declaration end to end, and against a temp copy carrying three injected records, where the collapsed native details element carried no open attribute, the summary line read "1 FLAG plus 2 notes" at computed rgb 255 74 58 matching the needs-attention token, the first yard lane sat at y=109 in a 900px viewport, and expanding revealed grouped rows with counts whose NOTE group computed rgb 217 213 201 inside a needs-attention strip, proving the issue 31 cascade-inheritance defect does not recur. Both sentence-check traces run hop by hop with file:line from mint through the severity map, the wire pass-through, the untouched schema enum, the browser ingest gate, the view rollup and the CSS token to the observed pixel. All three adjudications the brief requested were ruled on the merits - the FLAG-tier judgment call is CONFIRMED and strengthened by evidence the car did not cite, the no-schema-change deviation is UPHELD after independent verification that no schema file was touched and none needed to be, and the register-coloured summary line is KEEP because HAVAGLANCE requires it and its precedence matches the pinned taxonomy order. The brief's premise that design amendments follow an append-only house style was tested and disproven - no such rule exists in this repo - so the inline placement is not charged; the deletion of a true word and its false replacement are. The code in this diff is sound and would pass alone. The rejection is entirely documentation - three landed design and contract statements this diff made false were left standing, and one amendment asserts behaviour that two green tests contradict.
```