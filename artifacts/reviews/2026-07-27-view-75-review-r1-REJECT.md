<!-- starcar-integrity: sha256=10ebc7ffeaf48673791fe27f6523ca8913a2e9daf89b7e9298fdaf011d204af1 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# View train #75 dispatch-row task-id titles, review round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review
Round: 1
Target: `car/view-75 HEAD 82f64b5`
Base reviewed: `bc4c28fc9e0c7fe14fbe6f78633664ebf1774d21`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a353ad2db7e6ad627`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `bc4c28fc9e0c7fe14fbe6f78633664ebf1774d21` |
| Entire checkpoint | `4425a2b8f584` |
| Dispatch, the locator within the session | `a353ad2db7e6ad627` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain bc4c28fc9e0c7fe14fbe6f78633664ebf1774d21
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: **REJECT** (1 Major, 3 minor)

The engineering is good and the car's three contested judgments are all **correct** — I ruled for the car on every one, and proved two of them by fault injection rather than by reading. The REJECT rests on a single Major: an affirmative "documentation surface is clear" claim that covers a surface the car never opened, and which this diff does stale.

---

## BASE-DELTA (#13)

Base `bc4c28fc9e0c7fe14fbe6f78633664ebf1774d21` → HEAD `82f64b5f145885cee56d1337370dfe121d3e4d2b`. Verified FIRST: `git log -1 --format='%H'` → `82f64b5f145885cee56d1337370dfe121d3e4d2b`, detached (`git rev-parse --abbrev-ref HEAD` → `HEAD`), `git status --porcelain` empty. Worktree `<repo>-wt\review-view-75`. `git diff bc4c28f..82f64b5 --stat` = 10 files, **+593/−13**, exactly as briefed. 4 commits: `d43dac8`, `c5a036d`, `b08bfff`, `82f64b5`.

---

## Suites — RUN BY ME at 82f64b5

| Suite | Observed | Car claimed |
|---|---|---|
| `go test ./...` (board) | **98 PASS / 0 FAIL / 0 SKIP** | 98/0 ✔ |
| `go vet ./...` | exit 0 | clean ✔ |
| Go fold conformance vectors | `TestFoldConformsToVectors` **18/18 subtests PASS** | — |
| Pester `scripts/tests/Detector.Tests.ps1` (pwsh vector runner) | **22/22** | — |
| `node --test` in `board/web` | **223 tests / 223 pass / 0 fail / 0 skipped** | 223/223 ✔ |
| `browser-dispatch-row-geometry.test.js` | **3/3 pass** | — |
| `browser-dispatch-row-taskid.test.js` | **5/5 pass** | — |
| Pester `scripts/tests` | **227 total / 222 passed / 0 failed / 5 skipped** | 227/223/0/4 |
| Pester `scripts/probes` | **24/24** | 24/24 ✔ |
| `CodeCitationPolicy.Tests.ps1` | **13/13** | 13/13 ✔ |
| `WirePayload.Tests.ps1` | **7/7** | — |
| `board/web/probe-yard-snapshot.mjs` | **PASS**, exit 0 | PASS ✔ |

**The extra skip, identified BY NAME as the brief required:** `run-session-start-guards.sh: agent-pull runner (#50).running the REAL guards prints [ci-baseline]'s marker ONLY when attached to a branch - conditional, never asserted as always-emitting`. Detached-HEAD-conditional, exactly as predicted. Every other car number re-derived exactly.

---

## ADJUDICATION 1 — the car was RIGHT to deviate. The conductor's premise was FALSE.

**Ruling: the car's honest stop was correct, and the brief's stated precedent does not exist.**

- `board/fold/fold.go:103-125` — `DispatchEntry` is `Subject, State, At, Superseded, winnerKind, Outcome, Spend, ElapsedSeconds, BudgetSeconds, BudgetSource`. **There is no `RecordDir` field.** A grep of `board/fold/*.go` for `recordDir|RecordDir` returns **zero** hits. The conductor's "recordDir is the precedent for that location" is disproved by opening the file.
- recordDir actually lives in `board/assemble`: `recordDirBySubject` at `assemble.go:346`, augmenting the wire map at `assemble.go:247-249`. The car put `taskId` in exactly the same place (`assemble.go:426`, `:250-252`).
- **The car's stated reason is also true.** `schema/vectors/README.md:4-9` — "the landed pwsh detector (`scripts/Detect-Dispatches.ps1`) and the Go port ... conform to THESE fixtures, and the D18 cross-verifier CI job runs BOTH against them, failing on any divergence"; step 3 of the runner contract compares `dispatches` **DEEP-EQUAL**. A Go-only field on `fold.DispatchEntry.MarshalJSON` would have broken every vector's `dispatches` comparison on one side of a two-implementation contract.
- **No leakage.** `git diff --name-only bc4c28f..82f64b5 -- board/fold scripts/` returns **empty**. Vectors still pass in both languages (Go 18/18 subtests; Pester Detector 22/22).

Had the car obeyed the brief, it would have shipped a cross-language contract break. Honest stop = success outcome, and it earned it.

## ADJUDICATION 2 — first-write-wins IS wrong here, and the car's matcher DOES pick the fold winner. Proven by injection.

**Ruling: correct, and stronger than the car argued.**

- `board/store/store.go:193` — `sort.Strings(paths)`. For one subject, `dispatched-*.json` sorts before `returned-*.json` (`d` &lt; `r`), so `recordDirBySubject`'s first-write-wins (`assemble.go:353-355`) would land on the task_id-less dispatched record.
- **I constructed the multi-record case and observed it** (reviewer-owned browser probe, real Go server, scratch store): subject `c0ffee1234567890abcdef0123456789` with `dispatched@09:10`, `returned@09:20 task_id=LOSER-earlier-task-id`, `returned@09:30 task_id=WINNER-later-task-id`. Observed wire: `"taskId":"WINNER-later-task-id"`. The **fold winner**, not first-or-last-scanned.
- **Fault injection at the Go layer**, disclosed below: removing only the `at == d.At` winner pin from `taskIDForReturnedSubject` produced
  `d["taskId"] = solo-1-earlier-task-id, want the WINNING (newer, 11:00) record's task_id "solo-1-winning-task-id"` — the guard fires with the exact wrong value, so it is not vacuous.
- **The one hole I looked for and did not find:** two returned records at the EXACT same `at`. Measured (scratch store, `returned-a.json` REJECT/`A-first-in-path-order`, `returned-b.json` APPROVE/`B-second-in-path-order`): wire renders `"outcome":"REJECT"` **and** `"taskId":"A-first-in-path-order"` — outcome and task-id come from the SAME record the fold chose. Coherent. No finding.

## ADJUDICATION 3 — the enumeration is COMPLETE.

**Ruling: correct.** I walked every identity-label render site in `board/web/js/`:

- `.solari-subject` (`dom-writer.js:552`) — treated ✔
- `.car-subject` (`dom-writer.js:459`) — treated, role-agnostic ✔
- `.signal-name` (`dom-writer.js:507`) renders `gate.name`, which is `render.js:352` ← `assemble.go:157` `Name: name` ← `assemble.go:131-134` `name := m.Gate; if name == "" { name = m.Role }` — a **declared** manifest gate name or role word, **never a subject hash**. Correct exclusion.
- Three further candidates I checked that the car did not enumerate, all correctly out of scope: `.declared-not-observed` (`dom-writer.js:481`) renders manifest members with **no dispatch entry at all**, so no `taskIDs` map entry can exist by construction (`assemble.go:426-430` iterates `in.Fold.Dispatches`); `.solari-superseded-entry`/`.car-superseded-entry` (`dom-writer.js:181`) render `kind at`, never a subject; `healthTrendBadgeText` (`dom-writer.js:85-99`) renders arrows/counts only. Nothing missed.

---

## THE WIRE SENTENCE — `task_id`, producer to pixel, every hop

1. **Producer, RETURNED only — CONFIRMED.** `scripts/Produce-Artifact.ps1:358` — `if ($Kind -eq 'returned' -and $taskId) { $record['task_id'] = $taskId }`. The `-and $taskId` guard also means an empty/whitespace value is never stamped. Sourced at `:243` from the envelope (`if ($env.PSObject.Properties['TaskId']) { $taskId = $env.TaskId }`), declared optional at `:240-242`. The `else` branch at `:265` is the dispatched path — it stamps `subject_basis`/`model`/`provenance`, **never `task_id`**. Issue #75's probe comment holds.
2. **Store parse.** `board/store/store.go:134` — `TaskID string \`json:"task_id"\`` (landed by #51), so the field is a *declared* key and does not fire `record-unrecognised-fields` (`store.go:310-324`). Content access is the generic decode at `store.go:263`, surfaced as `Record.Fields` (`store.go:308`).
3. **Resolution.** `assemble.go:61` `taskIDs := taskIDsBySubject(in.Records, in.Fold.Dispatches)` → `assemble.go:426` (skip any `d.State != "returned"`) → `assemble.go:450` `taskIDForReturnedSubject` matches `subject` + `kind=="returned"` + `at == the fold's own winning At`. **Single owner** — no second derivation anywhere (Law 6).
4. **Assemble/wire hop, two consumers of that one map.** Trains: `assemble.go:123` `TaskID: taskIDs[m.Subject]` → `types.go:36` `TaskID string \`json:"taskId,omitempty"\``. Dispatches: `assemble.go:193` passes `taskIDs[d.Subject]` into `dispatchWireMap`, which at `assemble.go:250-252` sets `m["taskId"]` **only when non-empty** — key omitted, never `""`.
5. **Schema constraint.** `schema/yard-snapshot.schema.json:131-134` (trains car) and `:207-210` (dispatch entry), both `{"type":"string"}`, both **outside** the unchanged `required` arrays (`["subject","role","state","at"]`, `["subject","state","at","assigned"]`). Absent-form validates unchanged — evidenced by `WirePayload.Tests.ps1` 7/7 and `probe-yard-snapshot.mjs` PASS (`sample-validates: PASS`, non-vacuity `rejected as expected`) against samples that carry no `taskId`.
6. **Client view model, null-not-undefined.** `render.js:320` `taskId: c.taskId ?? null`; `render.js:374` `taskId: d.taskId ?? null`.
7. **DOM render + fallback.** `dom-writer.js:459` `car.taskId ?? car.subject` then `carSubject.setAttribute('title', car.subject)`; `dom-writer.js:552` `d.taskId ?? d.subject` then `:559` `subject.setAttribute('title', d.subject)`.
8. **Provenance link is untouched by the label.** `links.js:16-19` `buildRecordLink(cfg, recordDir)` takes **only** `recordDir`; both call sites still pass `*.recordDir`. Observed, real browser, `STARCAR_GITHUB_REPO=polecatspeaks/StarCar STARCAR_GITHUB_REF=dev`: visible text `reviewer-75-handle-r1`, `title="reviewer75hashwithtaskid"`, `href="https://github.com/polecatspeaks/StarCar/tree/dev/&lt;prefix&gt;/reviewer75hashwithtaskid"`, `tag=A`, `class="solari-subject provenance-link"`. Unset → `tag=SPAN`, `href=null`. Both branches honest.
9. **Hand-maintained mirrors.** `WirePayload.Tests.ps1` carries no `taskId` sample — **I rule this NOT a finding**, and better-supported than the car argued: (a) `#28`'s `recordDir` set the identical precedent and carries no sample either; (b) `schema/yard-snapshot.schema.json` has **no `additionalProperties` anywhere** (grep: zero hits), so an added optional key cannot break any existing sample; (c) `dom-writer.js:150-162`'s own *measured* comment records that `$defs.lane.data` does not `$ref` these payload defs, so the browser's real validator applies **no** constraint to lane data either way. The new field's type constraint is therefore structurally inert at both runtimes; a pwsh sample would exercise nothing the Go `string` type does not already guarantee. NIRTS call: correct.

---

## RENDERING CHECK (#40) — real browser, real served board, OBSERVED values

Reviewer-owned Playwright probe against a real `board/server` Go binary and a real scratch store, viewport 1024×900.

**Wire, fetched by the browser itself:**
```
{"subject":"a103c...cafef00d","state":"returned","taskId":"view-75-extremely-long-human-task-id-handle-that-should-truncate-not-wrap-r1","taskIdPresent":true,"recordDir":"a103c...cafef00d"}
{"subject":"b7f19...facefeed","state":"returned","taskIdPresent":false,"recordDir":"b7f19...facefeed"}
```

**Branch A (task_id present, 76-char id):** `textContent` = `view-75-extremely-long-human-task-id-handle-that-should-truncate-not-wrap-r1`; `title` = `a103c4067cf9267a3deadbeefcafef00d` — **the hash, verbatim, character-for-character**. Computed `overflow: hidden`, `text-overflow: ellipsis`, parent `.solari-row-main` `white-space: nowrap`. Geometry: `clientWidth 123px`, `scrollWidth 713px` → **truncating = true**; `distinctTopCount = 1`; row height **38px**.

**Branch B (no task_id):** `textContent` = `b7f19e2c44aa1188ffeed00dfacefeed` = the subject exactly; `title` identical; `clientWidth 123 / scrollWidth 300`; `distinctTopCount = 1`; row height **38px** — **byte-identical treatment to pre-#75**.

**GEOMETRY REGRESSION — clear.** The 76-char task-id row and the hash-fallback row have the **same 38px height** and the same single-line cluster. **The long id truncates via ellipsis, it does not wrap — measured, not read.** `browser-dispatch-row-geometry.test.js` run by me: **3/3 pass**.

**Car chip:** `textContent` = `WINNER-later-task-id`, `title` = `c0ffee1234567890abcdef0123456789`. The chip carried no title attribute before #75; it does now. Hash reachable.

---

## NON-VACUITY (#40) — re-derived, plus four further injections

**Every injection is disclosed; every file restored and verified byte-identical by sha256; final `git status --porcelain` empty and HEAD unmoved.**

| # | Injection | Pre-sha256 | Observed | Restored |
|---|---|---|---|---|
| 1 | `git checkout bc4c28f -- board/web/js/dom-writer.js` (car's own) | `92258D44…C1BE` | taskid file **3 pass / 2 fail**; `dom-writer.test.js` **48 pass / 3 fail** | ✔ `92258D44…C1BE` |
| 2 | `d.taskId ?? d.subject` → `d.taskId` | `92258D44…C1BE` | taskid file **4 pass / 1 fail** — **test 2 reds** | ✔ `92258D44…C1BE` |
| 3 | strip `text-overflow: ellipsis` from `board.css` `.solari-subject` | `B4860579…0E6B` | **test 3 reds** | ✔ `B4860579…0E6B` |
| 4 | drop `m["taskId"] = taskID` from `dispatchWireMap` | `F53C0CAF…4EE0` | `d["taskId"] = &lt;nil&gt;, want … "solo-1-winning-task-id"` | ✔ `F53C0CAF…4EE0` |
| 5 | blank `taskIDForReturnedSubject` → `return ""` | `F53C0CAF…4EE0` | 2 FAIL: `d["taskId"] = &lt;nil&gt;` and `car.TaskID = "", want "carA-task-id"` | ✔ `F53C0CAF…4EE0` |
| 6 | drop the `at == at` winner pin (first-match-wins) | `F53C0CAF…4EE0` | `d["taskId"] = solo-1-earlier-task-id` | ✔ `F53C0CAF…4EE0` |

**Ruling on the 3 vacuous passes: honestly scoped, none decorative.** Test 2 guards the fallback and reds under injection 2. Test 3 guards board.css and reds under injection 3. Test 5 guards geometry (and I independently exercised it with a 76-char id). Each is non-vacuous against *its own* defect class; none of them *should* red on a dom-writer revert, and the car said so.

**Go injections red for their stated reasons** (injections 4–6). Note the correct scoping: injection 4 reds only the wire test (the trains-lane test reads `car.TaskID`, a different path), and the three absence-asserting tests correctly stay green — they assert an absent key, which the injection satisfies.

**Honest correction to my own evidence (#13):** in the *full-suite* run under injection 1 I saw 9 failures, four of which were `browser-health-trend-cascade.test.js`. Re-running that file **alone** under the identical injection gave **4/4 pass** — those four were a **flake** from concurrent Chromium+Go-server load, not an injection consequence. Reported rather than quietly dropped.

---

## CITATION CHECK (#42) — clear

`CodeCitationPolicy.Tests.ps1` **13/13 pass**. The one new file, `board/web/test/browser-dispatch-row-taskid.test.js:1`, opens with `// browser-dispatch-row-taskid.test.js (#75) …`. All 10 changed files carry `#75` (counts 2–13 each). **No `file:line` citation was added anywhere in the diff** (grep of added lines for `\.(go|js|ps1|json|md|css):\d+` → zero hits), so the symbol-form rule this family paid two Majors for is not implicated.

---

## FINDINGS

### R1-M1 (MAJOR) — the "documentation surface is clear" claim omits `docs/screenshots/`, which this diff does stale

The car reports it searched design, spec, contracts, glossary, README and setup docs and found nothing stale. That enumeration never includes `docs/screenshots/`, and CLAUDE.md's NORTH STAR lists screenshots **by name** as user-facing documentation in scope, then names screenshot drift as "both the likeliest and the most embarrassing rot this repo can ship."

Evidence, all re-derivable:
- `board/web/verify-registers.mjs:104` — `await captureState(browser, 'calm-yard', {})`, **no `storePath` override**, so `calm-yard.png` is captured against the **ambient real `artifacts/` store**. `:105` `hot-yard` uses `buildScratchStoreWithInFlightDispatch()`, which `cpSync`s that same real store (`real-board-server.js:61`).
- Measured against the real store in this worktree: **84 of 248 records carry `task_id`**, including `a076bf6c0a94e302f → process-42-car-r1 / -r2 / -r3`.
- I opened both images. `docs/screenshots/2026-07-26-register-check-candidates/calm-yard.png` and `docs/screenshots/2026-07-26-view-28-12-candidates/calm-yard.png` **both** show a dispatches row rendered `a076bf6c0a94e…`. After this train the identical capture renders `process-42-car-r3`. The images no longer depict what the code draws for the exact surface this train redefines — and it is the exact hash-as-identity complaint issue #75 was filed to remove.
- **The house has a landed, same-class remedy from this same train family, one day old:** `docs/screenshots/2026-07-26-view-69-71-candidates/README.md` carries a `**DISCLOSED STALENESS (fix cycle round 2, MAJOR-R1-1, 2026-07-27):**` block for a rendering its images "also incidentally show." That precedent was created under a Major. `2026-07-26-register-check-candidates/` has **no README at all** in which such a note could live, and the four preceding view trains (#62, #28/#12, #67, #69/#71) each captured their own evidence directory; #75 captured none.

**The counter-argument, stated so the owner can rule cheaply rather than re-derive it:** these are dated per-train evidence captures; the only prose that cites one (`docs/design/mockups/2026-07-26-claude-design-board/README.md:65`, a 1920×1080 responsive-layout claim) remains **true**; and an ambient-store capture is data-stale on every commit that lands a record, which no rule requires recapturing. I still rule Major, because what changed here is the **rendering rule**, not the data — precisely the class the #69/#71 README disclosed rather than dismissed — and because the report's clearance is an affirmative claim over a surface that was never opened. Remedy is cheap: the #69/#71-shaped disclosure note, same commit.

### R1-m1 (minor) — a schema-valid `taskId: ""` renders a BLANK identity label

Measured, real browser, real served modules (`/js/render.js`, `/js/dom-writer.js`):

```
EMPTY-STRING   viewModelTaskId=""              renderedText=""                    title="a103c4067cf9267a3"
ABSENT         viewModelTaskId=null            renderedText="a103c4067cf9267a3"   title="a103c4067cf9267a3"
REAL           viewModelTaskId="view-75-car-r1" renderedText="view-75-car-r1"     title="a103c4067cf9267a3"
```

`schema/yard-snapshot.schema.json:132,208` declare `{"type":"string"}` with no `minLength`, and the schema has no `additionalProperties` gate anywhere, so `""` is wire-valid; `??` at `render.js:374` and `dom-writer.js:552` does not treat `""` as absent. The row loses its visible identity entirely. **Not Major:** unreachable through the only shipped producer (`assemble.go:250` guards `taskID != ""`; `types.go:36` is `omitempty`). Worth fixing because the sibling field's guard at `links.js:17` (`!recordDir`) *is* truthiness-based, so #75 introduced an inconsistency with its own nearest precedent; the fix is one character.

### R1-m2 (minor) — `browser-dispatch-row-taskid.test.js:57` is named for a scenario its fixture does not construct

The test is titled *"a **long** task-id still gets `.solari-subject`'s ellipsis truncation"*, but `buildScratchStoreForTaskIdTitles` (`real-board-server.js:472`) seeds `task_id: 'view-75-car-r1'` — **14 characters**, shorter than the 20-char hash it replaces. Measured in that fixture: `clientWidth 123 / scrollWidth 131` — it overflows by **8px**, by accident of the 13rem grid column, not because the id is long. The assertion itself is length-**independent** (computed `overflow`/`text-overflow` only), so it cannot fail for a length reason. No Major, because I independently measured the genuinely long case clean (76 chars: `scrollWidth 713 / clientWidth 123`, `distinctTopCount 1`, row height unchanged at 38px) — but the name promises coverage the assertion does not deliver, which is the instrument-honesty class this shop guards.

### R1-m3 (nit) — a comment left stale by the commit that invalidated it, 24 lines above the change

`board/web/js/dom-writer.js:528-529` still reads *"DISPATCHES: … dense monospace rows: **subject**, state word, elapsed"*. As of `:552` the first cell is task-id-or-subject. Same-file, same-function, same commit.

---

## CONSTITUTION CHECK

- **Law 1 (never a confident falsehood; unknown renders as unknown)** — HONORED on the shipped path, with one latent gap. Absent `task_id` renders the hash: observed `textContent == "b7f19e2c44aa1188ffeed00dfacefeed"` for a returned record carrying none, and the key is omitted entirely at `assemble.go:250-252` rather than emitted as `""`; `render.js:374`'s `?? null` keeps null distinct from undefined (`render.test.js` pins `null, 'absent wire taskId must render as null, never undefined'`). **Gap: R1-m1** — a schema-valid `""` renders an empty label.
- **Law 6 (no second copy)** — HONORED. `taskIDsBySubject` (`assemble.go:426`) is the single resolution owner; both consumers (`assemble.go:123`, `:193`) read the same map; the client never re-derives from `subject`. `dispatchWireMap` still delegates the conditional key set to `fold.DispatchEntry.MarshalJSON` (`assemble.go:236`).
- **Law 7 (no hardcoded taxonomy)** — HONORED. `taskId` is an opaque pass-through string with no enumeration. The `State != "returned"` / `kind != "returned"` literals at `assemble.go:429,443` are the fold's closed-by-mechanism liveness gradient, identical to the pre-existing `findingsForReturnedSubject` at `assemble.go:365+`, not a new open taxonomy.
- **Law 4 (never silently dropped)** — HONORED. The subject hash survives verbatim in the `title` attribute on **both** surfaces (`dom-writer.js:460`, `:559`), observed in a real browser; the provenance link still resolves by `recordDir`, observed.
- **NORTH STAR, documents rank equal to code** — **VIOLATED**, see R1-M1.
- **#42 code citation** — HONORED, gate green 13/13.
- **TDD red-first** — HONORED and re-derived: six independent injections, all red for their stated reasons.
- **Dispatch hygiene (no push, no shared checkout)** — HONORED by me: nothing committed, nothing pushed, all six injections restored byte-identical by sha256, `git status --porcelain` empty at `82f64b5`, shared checkout never written.

**Unreproducible-evidence callout (#13):** none. Every finding above rests on a command or measurement in this report. The one thing I could *not* fully re-derive — the four `#12` failures inside my injected full-suite run — I chased down and reported as a flake rather than leaving it as evidence.

**To clear:** land the screenshot-staleness disclosure (R1-M1) in the fix commit; R1-m1/m2/m3 are cheap and I would take them in the same pass, but only R1-M1 is binding.

Files: `<repo>-wt\review-view-75\board\assemble\assemble.go`, `...\board\web\js\dom-writer.js`, `...\board\web\js\render.js`, `...\board\web\test\browser-dispatch-row-taskid.test.js`, `...\board\web\test\support\real-board-server.js`, `...\board\web\verify-registers.mjs`, `...\schema\yard-snapshot.schema.json`, `...\docs\screenshots\2026-07-26-register-check-candidates\calm-yard.png`, `...\docs\screenshots\2026-07-26-view-28-12-candidates\calm-yard.png`, `...\docs\screenshots\2026-07-26-view-69-71-candidates\README.md`

```starcar-artifact
outcome: REJECT
findings: 1 Major, 3 minor. R1-M1 (MAJOR): the car's "documentation surface checked and clear" claim omits docs/screenshots/, which this diff does stale - board/web/verify-registers.mjs:104 captures calm-yard against the AMBIENT real artifacts store; that store holds 84 of 248 records carrying task_id including a076bf6c0a94e302f mapping to process-42-car-r3, whose row is visibly rendered as the hash "a076bf6c0a94e..." in both docs/screenshots/2026-07-26-register-check-candidates/calm-yard.png and docs/screenshots/2026-07-26-view-28-12-candidates/calm-yard.png (images opened and read, not inferred); the house has a landed same-class remedy one day old in docs/screenshots/2026-07-26-view-69-71-candidates/README.md's DISCLOSED STALENESS block, created under MAJOR-R1-1, and the register-check directory has no README at all; counter-argument stated in full in the verdict for cheap owner adjudication. R1-m1 (minor): a schema-valid taskId of empty string renders a BLANK identity label - measured in a real browser against the real served modules, EMPTY-STRING gives renderedText of empty string while ABSENT correctly gives the hash; schema/yard-snapshot.schema.json lines 132 and 208 declare type string with no minLength and the schema has no additionalProperties gate anywhere, and the nullish-coalescing operator does not treat empty string as absent, whereas the sibling recordDir path at links.js:17 uses a truthiness guard that does; unreachable through the only shipped producer (assemble.go:250 guards non-empty, types.go:36 is omitempty) so not Major. R1-m2 (minor): browser-dispatch-row-taskid.test.js:57 is titled "a LONG task-id still gets ellipsis truncation" but its fixture seeds a 14-character task_id (real-board-server.js:472) that overflows by only 8px by accident of the 13rem grid column, and the assertion is length-independent (computed style only); no Major because the reviewer independently measured a 76-character task-id truncating cleanly (scrollWidth 713 vs clientWidth 123, one visual line, row height 38px identical to the fallback row). R1-m3 (nit): board/web/js/dom-writer.js:528-529's section comment still says rows show "subject, state word, elapsed", stale as of line 552 in the same commit. ALL THREE ADJUDICATIONS RULED FOR THE CAR. Adjudication 1: the conductor's premise was FALSE - board/fold/fold.go:103-125's DispatchEntry has no RecordDir field and grep of board/fold for recordDir returns zero hits; the car's chosen layer (board/assemble) is correct and its stated reason true - schema/vectors/README.md:4-9 confirms both the pwsh detector and the Go port conform to the vectors under a D18 cross-verifier with DEEP-EQUAL comparison of dispatches, so a Go-only field would have broken a two-implementation contract; board/fold and scripts/ are untouched in the diff and vectors pass in both languages. Adjudication 2: first-write-wins IS wrong (store.go:193 sorts by path, dispatched sorts before returned) and the car's matcher DOES select the fold winner - constructed a three-record case and observed WINNER-later-task-id on the wire, then fault-injected removal of the at-winner pin and observed the guard fire with the exact wrong value solo-1-earlier-task-id; also probed the exact-at-tie hole and found outcome and task-id come from the same record. Adjudication 3: enumeration COMPLETE - signal-name renders gate.name which traces to the manifest's declared gate or role word (assemble.go:131-134,157), never a hash; three further candidates checked (declared-not-observed, superseded entries, health-trend badge) all correctly out of scope. Suites re-derived at 82f64b5 - Go 98 PASS 0 FAIL vet clean, fold vectors 18 of 18 Go subtests plus Detector 22 of 22 pwsh, node board/web 223 of 223, geometry test 3 of 3, taskid test 5 of 5, Pester scripts/tests 227 total 222 passed 0 failed 5 skipped with the extra skip named as the detached-HEAD-conditional session-start-guards ci-baseline marker test, probes 24 of 24, CodeCitationPolicy 13 of 13, WirePayload 7 of 7, probe-yard-snapshot PASS. Six fault injections all restored byte-identical by sha256 with the tree clean at 82f64b5.
abstract: Adversarial sentence-check review of view train #75 (task-id handle threaded to the dispatch-row and car-chip titles with an honest hash fallback), base bc4c28f to head 82f64b5, 10 files +593/-13. REJECT on one Major. The engineering is sound and all three contested car judgments were ruled correct, two of them proven by fault injection rather than reading - notably the car's honest stop against a defective brief, whose stated precedent (recordDir on fold.DispatchEntry) does not exist in the code and whose instruction would have put a Go-only field into a deep-equal cross-language conformance contract. The full wire sentence was traced hop by hop with file:line from the pwsh producer's returned-only stamping through store parse, resolution, wire map, schema, view model null-vs-undefined, DOM render and provenance link, and both rendering branches plus a 76-character task-id were measured in a real browser against a real Go server (truncation not wrap, identical 38px row geometry, subject hash verbatim in the tooltip, link still keyed by recordDir). The Major is a documentation-surface defect: an affirmative "checked and clear" claim that never opened docs/screenshots/, where two committed board images captured against the ambient real store depict the exact hash-as-identity rendering this train replaces, with a landed same-class disclosure precedent from this train family one day old.
task-id: view-75-review-r1
```