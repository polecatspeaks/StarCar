<!-- starcar-integrity: sha256=f82011d1f448ef1cb06c2ad6a54881b20c89b96022f364cc9adb81d79c149638 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# View train #69+#71 car review, round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review
Round: 1
Target: `car/view-69-71 HEAD 256d8d5`
Base reviewed: `b865cba91cf4ee192a3ab7c742c48424c508268e`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a103c4067cf9267a3`. The conductor did not retype a word of what follows. Verbatim by
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
> Path normalisation: none applied (the body contained no operator-environment paths).

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `b865cba91cf4ee192a3ab7c742c48424c508268e` |

| Dispatch, the locator within the session | `a103c4067cf9267a3` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain b865cba91cf4ee192a3ab7c742c48424c508268e
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: REJECT — 4 Major, 3 Minor

**Base verified.** `git log --oneline -2` → `256d8d5` / parent `b865cba`, detached HEAD. Matches the brief.

## Suites — re-derived by me, not read from the report

| Suite | HEAD 256d8d5 | Base b865cba | Car claimed | Verdict |
|---|---|---|---|---|
| Node `board/web` (`node --test --test-reporter=tap`) | **200 tests / 200 pass / 0 fail** | **169 / 169 / 0** | 200, base 169 | matches |
| Go `board/...` (`go test ./...`, `--- PASS` count) | **93** | **85** | 93, base 85 | matches |
| `go vet ./...` | exit 0, no output | — | clean | matches |
| Pester `scripts/tests` | **222 passed / 0 failed / 5 skipped / 227 total** | — | 223/0/4 | matches modulo my detached-HEAD skip, confirmed by name: *"run-session-start-guards.sh … prints [ci-baseline]'s marker ONLY when attached to a branch"* |
| Pester `scripts/probes` | **24 / 0 failed** | — | 24/24 | matches |
| `probe-yard-snapshot.mjs` | `PROBE RESULT: PASS` (schema compiles, draft 2020-12, sample validates, non-vacuity rejection fires) | — | PASS | matches |

Base re-derived from `git archive b865cba` into scratch, never by touching the shared checkout.

---

# MAJOR FINDINGS

## MAJOR-R1-1 — Superseded rendering orphans provenance lines onto the WRONG subject, and blows out the lane the #67 cap was protecting

`renderSupersededList`'s output is appended as a **SIBLING** of the row, not a child:
- `board/web/js/dom-writer.js:477-478` → `rows.appendChild(supersededList)` where `rows` is `.solari-rows`, which is `display: grid; grid-template-columns: repeat(auto-fill, minmax(13rem, 1fr))` (`board/web/css/board.css:577-583`).
- `board/web/js/dom-writer.js:398-399` → `cars.appendChild(supersededList)` where `cars` is `.track-cars`, `display: flex; flex-wrap: wrap` (`board/web/css/board.css:339-343`).

So each superseded block occupies its **own grid cell / own flex item**, positionally independent of its row. Whenever the preceding cell count makes a pair straddle the wrap boundary, the provenance line lands on a **different visual line, adjacent to a different subject.**

**Measured, real browser, `getBoundingClientRect` (trains lane, 5 cars each with one superseded):**
```
car-chip  rev-car-3 …   top=363 left=1380   &lt;- end of flex line 1
car-superseded 09:03:00Z top=393 left=452   &lt;- START of line 2, far left
car-chip  rev-car-4 …   top=393 left=677    &lt;- immediately to its RIGHT
```
A reader scanning line 2 left-to-right reads `dispatched 09:03:00Z` then `rev-car-4`. That timestamp belongs to **rev-car-3**. Same shape reproduced in the dispatches lane (`subject-7`'s row at `top=117 left=1491`, its superseded at `top=142 left=452`).

**Against the REAL `artifacts/` store** (strongest evidence — screenshot captured, then removed): the dispatches lane renders `a0ea6918ba39a… returned` in column 1 with a 3-line stack beside it, and a **5-line unlabelled stack** (`returned 01:28:30Z / returned 01:01:07Z / returned 00:31:48Z / returned 23:35:12Z / dispatched 23:01:41Z`) wrapped to the leftmost cell of the second grid line — it belongs to `ab2bd332be0ee…`, which sits at the far right of the line above. The two nearest subject labels both own something else. `solariSupersededBlocks: 4`, `carSupersededBlocks: 10` on the real store; `.solari-rows`' `max-height: 11rem` is visibly overrun.

**Adjudication against the direction the brief asked for:** #67 landed `capTerminalHistory` (`board/web/js/render.js:405-408`) precisely to bound history in this space for readability. This commit reintroduces unbounded per-row history *inside* that cap — the same 4 capped dispatches now sprawl over ~2.5x the vertical space, and the trains consist reads as alternating chip / unlabelled-timestamp-stack. HAVAGLANCE fails; worse, Law 1 fails, because a fact is rendered adjacent to a subject that does not own it.

**Why the car's own verification could not see it:** `buildScratchStoreUnderRepoRootWithConditionsAndSuperseded` (`board/web/test/support/real-board-server.js:284+`) seeds exactly **one** dispatch subject. The committed screenshot `docs/screenshots/2026-07-26-view-69-71-candidates/expanded-after-click.png` shows a single row. A one-item grid structurally cannot exhibit a wrap defect. Under the #40 floor, the real-browser evidence was constructed on a fixture that could not falsify the claim it was offered for.

## MAJOR-R1-2 — #69's headline mechanism has ZERO regression pin: deleting the only wiring line leaves 200/200 green

`board/web/js/app.js:148` is the single line that makes open-state persistence work:
```js
root.addEventListener('toggle', handleConditionToggle, true);
```

**Fault injection (mine).** Removed that one line (`sha256` before `9bbcb03a2fc5008ee259e00a057841555ff44c3815091f8ac9d48735a32ab843`; verified only a comment mention of `addEventListener` remained), ran the full suite:
```
# tests 200
# pass 200
# fail 0
```
**Nothing red.** The persisted state is never written, every toggle is lost, the exact owner-reported defect ("it closes back up every page refresh") is live — and CI says green. Restored; `sha256` identical.

What exists instead: `condition-open-state.test.js` tests the pure shape only; `dom-writer.test.js`'s `#69` block tests that a *passed-in* `openState` is reflected. Neither touches the writer. The car's cited proof, `board/web/verify-conditions-persistence.mjs`, is by its own header (lines 2-6, 20-21) an *"EXPLICIT, SEPARATELY INVOKED dev tool … never runs as a side effect of the test suite"* that *"Takes NO assertion … this is evidence for a human/reviewer to read."* It prints JSON; it cannot fail.

This is not a "browser tests are hard" case: `board/web/test/browser-register-cascade.test.js` is already in the suite, already drives real Chromium against a real Go binary, already asserts. The pattern (#33) exists and was not used for the one behavior this ticket is about.

## MAJOR-R1-3 — The "untestable branch" disclosure is FALSE, and the falsehood is permanent in the source

`board/assemble/assemble.go:189-197` (and the commit message) claim:
&gt; *"d.winnerKind (the only field that can make MarshalJSON emit an unencodable "spend" value) is unexported, so **no test outside board/fold can construct a fold.DispatchEntry that reaches this branch**."*

`winnerKind` selects the branch (`board/fold/fold.go:109`); **`Spend any` is what carries the unencodable value, and `Spend` is EXPORTED** (`board/fold/fold.go:112`). `fold.Output.Dispatches` is exported too. So a test in `board/assemble` calls `fold.Fold(...)` to get a `winnerKind=="returned"` entry, then mutates `Spend`.

**Disproven by running it** (probe file created in `board/assemble/`, run, then deleted; `sha256 a070e024362e567e28b1452fd2a7a5cbd06b432546897db5c6ab07f49c490800`):
```
=== RUN   TestReviewerProbeDispatchRenderFailedIsReachable
    reviewer_probe_test.go:39: REACHED: detail="subject \"probe-subj\" could not be rendered to the wire shape:
      json: error calling MarshalJSON for type fold.DispatchEntry: json: unsupported type: chan int"
      recordDir="probe-subj"
--- PASS
```
~30 lines, exported API only, from a package outside `board/fold`, asserting the exact `RecordDir` the car said was unreachable. This is the sole one of the 8 population sites with no red-first pin, and the justification for skipping it is untrue. A false claim in a permanent code comment is a lying canary that will steer every future reader away from the test that takes half an hour to write.

## MAJOR-R1-4 — This commit's own insertion broke a live citation and left it stale

`board/web/js/lanes.js:16` cites:
```js
// key at all by design (board/server/snapshot.go:41-45's "absence of the
// key itself is what signals no payload") ...
```
This commit inserted 4 lines at `board/server/snapshot.go:22-25` (hunk `@@ -19,6 +19,10 @@`).

| | base b865cba | HEAD 256d8d5 |
|---|---|---|
| quoted phrase (`"absence of"`) at | snapshot.go:**44** | snapshot.go:**48** |
| cited range `41-45` contains | the quoted sentence | the tail of the `Freshness` struct + `}` + blank |

The citation was true at base and is false at HEAD, caused by this diff. NORTH STAR: *"the commit that invalidates a document updates that document, in the same commit"* — code comments are named explicitly.

Aggravating: the repo already documented this exact class one file away. `docs/contracts/gating-matrix.md:49` reads *"cited by symbol, not line, per #65's own lesson: the line-number form of this citation drifted … caught by #65's round-1 reviewer, **not by the gate itself, which does not check in-range shifts**."* The #65 Pester gate is green here for exactly that reason (line 45 exists), and its content-anchor test is REPORT-ONLY and skipped.

Checked and **clear**: `state-ledger.md:102`/`:108` (cited from `poll.go:116`, `poll_test.go:154,186`) — insertions were at 129+/148, below those lines. `design.md:133` (cited from `sse-protocol.js:7`, `gating-matrix.md:49`) — insertion at 733+. `algorithm.go:110-122`/`:113,119` (cited from design §12b) — file untouched; I verified `:112` is `d := "kind: " + k` inside `func Fold` (`algorithm.go:79`), so `links.js`'s symbol-level citation is TRUE.

---

# MINOR FINDINGS

**MINOR-R1-1 (Law 6).** `store.recordDirFromRelPath` (`board/store/store.go:338-344`) is a second copy of the rule at `board/assemble/assemble.go:333-336`. The stated justification — construction-order — explains why the *call sites* differ, not why the *code* is copied: `board/assemble` already imports `board/store` (`assemble.go:18`), so exporting one helper removes the copy entirely.

**MINOR-R1-2 (first consumer, unconstrained wire).** `superseded` is `{"type": "array"}` with no item schema (`schema/yard-snapshot.schema.json:118, 185`). `dom-writer.js:117` newly reads `${item.kind} ${item.at}` unguarded — a malformed item renders `"undefined undefined"`. Latent only (`fold.go:85-88` always emits both), but this commit is the first consumer and the natural moment to tighten it or guard the read.

**MINOR-R1-3 (non-vacuity gap).** Neither catch in `condition-open-state.js` is exercised: `loadOpenState`'s throwing-`getItem` branch (lines 44-46) and `saveOpenState`'s swallow (lines 66-71). `fakeStorage` in `condition-open-state.test.js:18-30` never throws. Both are Law-1 degrade paths asserted only by reading.

---

# THE WIRE SENTENCE — every hop, file:line

New field `recordDir` on `boardCondition`. Traced end to end, and **observed live in a real browser**, not reasoned:

1. **Schema** — `schema/yard-snapshot.schema.json:75-78`, optional, not in `required` (line 80). No `additionalProperties: false` anywhere in the schema, so the addition constrains type-only; absent form validates unchanged.
2. **Domain type** — `board/store/store.go:55` `RecordDir string` on `BoardCondition`.
3. **Population, 8 sites** (brief's 6+2 confirmed; `assemble.go:118` and `:156` are pre-existing #28 Car/Gate fields, not condition sites):
   - `assemble.go:64` subject-namespace-collision · `:85` manifest-record-not-found · `:96` manifest-payload-unreadable · `:148` gate-findings-record-not-found · `:180` manifest-membership-collision · `:203` dispatch-render-failed
   - `store.go:210` record-quarantined · `:322` record-unrecognised-fields
   - **Colon→dash trap (#28) checked and CLEAN:** every value derives from a PATH, never re-derived from `subject`. `recordDirBySubject` uses `filepath.Dir(r.Path)` (`assemble.go:333`); `recordDirFromRelPath` uses the file's own store-root-relative `rel`, computed at `store.go:196-200`. Verified against `real-board-server.js:105-107`'s `dirName(subject)` fixture, which deliberately sanitises `train:x` → `train-x`: the value follows the directory, not the subject.
   - `recordDirs := recordDirBySubject(...)` correctly HOISTED above the first condition site (`assemble.go:57`).
4. **Wire hop** — `board/server/poll.go:475` `toWireCondition`; `board/server/snapshot.go:25` `json:"recordDir,omitempty"`. Note `poll.go:325` mints `discovery` conditions with **no** `RecordDir` — correct by design.
5. **Client validation** — `board/web/js/ingest.js:29` `validator.validate(payload)` (`validate.js:18`). **Observed:** with `recordDir` present on every condition, the live board rendered with `markedStale: false` and no client condition; absent form is the base's own green.
6. **View model** — `board/web/js/render.js:85`, `recordDir: bc.recordDir ?? null` (null, never undefined).
7. **Target choice** — `dom-writer.js:143-148` `boardConditionInstanceHref`; discovery → `links.js:47-51` `buildVocabLink` + `:60-65` `vocabFilenameForDiscoveryDetail`; all others → `buildRecordLink`.
8. **DOM** — `dom-writer.js:68-76` `factOrLink`: anchor + `.provenance-link` when href truthy, else `&lt;span&gt;`, identical class and text.
9. **Computed style** — reproduced the car's claim exactly: discovery instance `tagName "A"`, `href …/blob/dev/schema/vocab/kinds.json`, `color rgb(217,213,201)` **equal** to a live `.register-nominal` probe. Superseded `color rgba(217,213,201,0.55)` = `var(--text-dim)`, `text-decoration: none`, `border-bottom: 1px dotted currentColor` — **not** link-blue (bare `&lt;a&gt;` probe = `rgb(0,0,238)`).

**Degrade-honest branch, observed with NO GitHub env:** `{supersededBlockPresent: true, supersededChildTag: "SPAN", supersededChildHref: null, conditionInstanceTag: "SPAN", conditionInstanceHref: null, markedStale: false}` — identical text and colour, no fake link.

**Prefix coupling (attack surface 2) — PINNED ON BOTH SIDES, no gap.** Producer: `schema/vectors/fold/unrecognised-kind-discovery-by-name.json:16` pins `"discoveries": [ "kind: migrated" ]` and `unrecognised-outcome-discovery-by-name.json:16` pins `"outcome: FROBNICATE"` — conformance vectors run against BOTH the Go fold and the pwsh detector via CI's D18 cross-verifier. `poll.go:325` passes the fold's string through verbatim as `Detail`. Consumer: `links.test.js`'s three `vocabFilenameForDiscoveryDetail` tests. The brief's suspected one-sided coupling is **disproven**.

**Persistence semantics (attack surface 3) — all clear, measured.**
- New class mid-session: injected a FLAG-tier condition into a running board. `record-unrecognised-fields` appeared with `open: false` while the previously-opened `discovery` stayed `open: true`. #30's collapsed-by-default holds.
- Summary line: `"1 note" / register-nominal` → `"1 FLAG + 1 note" / register-needs-attention`. Unconditional (`dom-writer.js:236`, before any openState branch).
- Key scheme: keyed by condition CODE only (`app.js:126`). Codes are a closed classed vocabulary (`board/store/condition_severity.go`); reopening the same class is the intended semantic, not a leak.
- Listener: attached ONCE at `app.js:148` on `root`, which is never replaced (only `root.textContent` cleared, `dom-writer.js:139`). **Measured: exactly 1 `setItem` call per toggle** — no double-fire, no per-rebuild leak.

**Non-vacuity re-derived by me (4 injections, all reverted byte-identical):**

| # | Injection | Observed red |
|---|---|---|
| A | remove `app.js:148` listener | **200/200 GREEN — see MAJOR-R1-2** |
| B | `'kind: '` → `'kindX: '` in `links.js:62` | `not ok 39 - #69/#71: a discovery condition instance links to its VOCAB FILE…` + `not ok 130 - vocabFilenameForDiscoveryDetail: "kind: X"…` (198/200) |
| C | drop `RecordDir` from `store.go:210` | `--- FAIL: TestScanQuarantinedConditionCarriesRecordDir … store_test.go:372: RecordDir = "", want "bad"` |
| D | drop `RecordDir` from `poll.go:475` | `--- FAIL: TestConditionRecordDirSurvivesToWire … discovery_test.go:86: wire RecordDir = "", want "s1"` |
| E | `render.js:370` superseded → `[]` | 3 red (197/200), incl. `not ok 57 - #71: a dispatch with superseded entries…` |

**Docs (attack surface 7) — accurate.** `docs/contracts/state-ledger.md:148` is the right surface (Q3 is explicitly the browser's own state, headed at line 116) and the row's three lifecycle claims all hold under observation, including "not reset on same-tab reload" — verified via real `page.reload()`. The pre-existing "five in-memory fields … never persisted" sentence (line 118) survives because it enumerates five *named* fields and the amendment discloses the sixth as the first non-in-memory one. Design §12b's amendment (`design.md:736-793`) states the sessionStorage-vs-DOM-capture deviation accurately and cites only by symbol.

---

## Constitution check

- **Law 1 (never a confident falsehood):** VIOLATED twice — MAJOR-R1-3 (false impossibility claim in `assemble.go:189-197` and the commit message) and MAJOR-R1-1 (a provenance timestamp rendered adjacent to a subject that does not own it). Honored elsewhere: no-target conditions render plain text, `recordDir` absent → `null` not a guess.
- **Law 6 (no second copies):** MINOR-R1-1; `recordDir` itself is correctly single-sourced from `Record.Path` at all 8 sites.
- **Law 7 (the stranger):** honored — no hardcoded taxonomy; `vocabFilenameForDiscoveryDetail` returns `null` for any unknown shape.
- **TDD / red-first:** honored at 7 of 8 population sites (injections C/D/E measured); VIOLATED at the 8th on a false justification (MAJOR-R1-3) and absent entirely for #69's own mechanism (MAJOR-R1-2).
- **#40 (guards proven by watching them fire):** VIOLATED — MAJOR-R1-2 (no guard exists) and MAJOR-R1-1 (the visual evidence used a fixture that cannot exhibit the defect).
- **NORTH STAR (documents rank equal to code, updated in the same commit):** VIOLATED — MAJOR-R1-4.
- **Verification honesty:** honored by the car — every suite count I re-derived matched, and the disclosed limitation was disclosed (it was simply wrong, and disclosed-but-wrong does not clear review).

## Required fields

**BASE-DELTA:** reviewed base `b865cba` → current `256d8d5`; range `git diff b865cba..256d8d5` (27 files, +1435/−52). Visible delta for a user with **no GitHub config** (measured, not inferred): (1) superseded entries now RENDER as new plain-text blocks under/beside every car chip and dispatch row that has one — 14 such blocks on the real store; (2) conditions-strip and per-group open state survives DOM rebuild and page reload; (3) condition instances remain plain `&lt;span&gt;` exactly as at base. No other visible change.

**UNREPRODUCIBLE-EVIDENCE:** none. Every finding rests on re-runnable evidence: `git archive` base extraction, five named fault injections with before/after `sha256`, four browser probes against the real Go binary (three scratch fixtures + the committed `artifacts/` store), and `git show b865cba:board/server/snapshot.go` for the citation shift. MAJOR-R1-1's screenshots were viewed and deleted for byte-clean exit; re-derivable in ~2 minutes from the geometry recipe above (≥5 rows in `.solari-rows`, or ≥5 cars in `.track-cars`, each with one superseded entry).

**Byte-clean exit:** `git status --porcelain` empty; HEAD `256d8d5`. Files touched and restored with matching `sha256`: `app.js 9bbcb03a…`, `links.js e670113a…`, `store.go 218b7555…`, `poll.go 2c3de7a4…`, `render.js bd538a9f…`. Probe files created and deleted: `board/assemble/reviewer_probe_test.go` (`a070e024…`), `board/web/review-probe-69-71.mjs`, `review-probe2-69-71.mjs` (`4d54c529…`), `review-probe3-69-71.mjs`, `review-probe4-69-71.mjs`, and `board/web/.review-out-69-71/`. Nothing committed, nothing pushed, shared checkout untouched.

## Recommendation to the conductor

Fix cycle to the SAME car. MAJOR-R1-3 and MAJOR-R1-4 are ~30-line mechanical fixes. MAJOR-R1-2 wants a real-browser test in the suite following `browser-register-cascade.test.js`'s pattern. **MAJOR-R1-1 is the one that may need an owner ruling rather than a car fix** — options are (a) nest the superseded block inside its row/chip so it cannot orphan, (b) put it behind the same `&lt;details&gt;` chrome the conditions strip uses, or (c) cap it per row the way #67 caps history. That is a design choice about the board's readability posture, which the owner has ruled on twice already (#62, #67), and I do not think a car should pick it alone.

```starcar-artifact
outcome: REJECT
findings: 4 Major, 3 Minor
abstract: |
  Adversarial sentence-check review of 256d8d5 (view train #69+#71), round 1. REJECT.
  Suites re-derived independently at HEAD and base: Node board/web 200/200 (base 169/169),
  Go board 93 PASS (base 85), go vet clean, Pester scripts/tests 222 passed / 0 failed /
  5 skipped (the extra skip vs the car's 223/4 identified by name as the detached-HEAD
  ci-baseline branch guard), scripts/probes 24/24, probe-yard-snapshot.mjs PASS. Every
  count the car claimed reconciles.

  MAJOR-R1-1: renderSupersededList appends its block as a SIBLING of the row - into
  .solari-rows (display grid, 5 auto-fill columns, board.css 577-583) at dom-writer.js
  477-478, and into .track-cars (flex wrap, board.css 339-343) at dom-writer.js 398-399 -
  so each superseded block takes its own grid cell / flex item and can wrap onto a
  different visual line from its own row. Measured with getBoundingClientRect in real
  Chromium: rev-car-3's chip at top=363 left=1380, its superseded at top=393 left=452,
  with rev-car-4's chip immediately to its right; same shape in the dispatches lane. On
  the REAL artifacts store a 5-line unlabelled timestamp stack belonging to ab2bd332be0ee
  renders on the line below it, between two dispatches that own neither. Law 1 and
  HAVAGLANCE failure, plus a readability regression against the #62/#67 direction: 4
  capped dispatches now sprawl past .solari-rows' 11rem max-height, 14 superseded blocks
  on the live store. The car's own fixture seeds ONE dispatch subject, so its committed
  screenshots structurally could not exhibit this.

  MAJOR-R1-2: #69's central mechanism has no regression pin. Removing the single line
  app.js:148 (root.addEventListener toggle, capturing) leaves the suite at 200 tests /
  200 pass / 0 fail - the owner-reported defect goes live with CI green. The cited proof,
  verify-conditions-persistence.mjs, is by its own header a separately invoked dev tool
  that takes no assertion. The suite already contains an asserting real-browser test
  (browser-register-cascade.test.js, issue #33), so the pattern existed and was not used.

  MAJOR-R1-3: the disclosed "untestable" branch is reachable. assemble.go 189-197 and the
  commit message claim no test outside board/fold can reach dispatch-render-failed because
  winnerKind is unexported; winnerKind selects the branch but Spend (fold.go:112) carries
  the unencodable value and IS exported, as is Output.Dispatches. A 30-line test in
  board/assemble calling fold.Fold then setting Spend to a channel reached the branch and
  observed recordDir="probe-subj" - PASS, quoted verbatim in the verdict. The false claim
  lives permanently in a code comment and is the stated reason the only unpinned site of
  8 was shipped unpinned.

  MAJOR-R1-4: this commit's own 4-line insertion at snapshot.go 22-25 shifted the text
  cited by board/web/js/lanes.js:16 as "board/server/snapshot.go:41-45"; the quoted phrase
  moved from line 44 (base) to line 48 (HEAD), so the cited range now shows the Freshness
  struct tail. Stale citation created and left behind, same class gating-matrix.md:49
  already documents as invisible to the #65 gate ("does not check in-range shifts").
  Verified clear: state-ledger.md 102/108, design.md 133, algorithm.go 110-122.

  MINOR-R1-1 Law 6: recordDirFromRelPath (store.go 338-344) duplicates the rule at
  assemble.go 333-336 though assemble already imports board/store (assemble.go:18).
  MINOR-R1-2: superseded array items are unconstrained by the schema (lines 118, 185)
  while dom-writer.js:117 newly reads item.kind/item.at unguarded.
  MINOR-R1-3: both catch branches in condition-open-state.js (lines 44-46, 66-71) are
  untested - the test fake never throws.

  Traced and CLEAN: the full wire sentence for the new recordDir field, all 9 hops with
  file:line, observed live in a real browser (discovery anchor computed color
  rgb(217,213,201) equal to a live .register-nominal probe; superseded color
  rgba(217,213,201,0.55) equal to var(--text-dim), not link-blue; superseded href equal to
  its row's subject href). All 8 population sites derive from a PATH, never re-derived
  from subject - the #28 colon-to-dash trap is not reintroduced. The discovery prefix
  coupling IS pinned on both sides (fold conformance vectors pin "kind: migrated" and
  "outcome: FROBNICATE"; links.test.js pins the parse), disproving the brief's suspected
  one-sided coupling. Persistence semantics clear: new condition class appearing
  mid-session renders collapsed while a previously-opened class stays open, the chrome
  summary line updates unconditionally (observed 1 note / register-nominal to 1 FLAG +
  1 note / register-needs-attention), exactly one setItem per toggle, listener attached
  once to a root that is never replaced. Degrade-honest branch observed with no GitHub
  config: SPAN, no href, identical text and color. Non-vacuity re-derived by four further
  fault injections (prefix parse, store population, wire hop, view model) each red for its
  stated reason.

  BASE-DELTA b865cba to 256d8d5, 27 files +1435/-52. Visible delta for a no-GitHub-config
  user, measured: superseded entries now render as new plain-text blocks (14 on the live
  store), open state survives rebuild and reload, condition instances unchanged as spans.
  UNREPRODUCIBLE-EVIDENCE: none - every finding rests on re-runnable evidence.

  Byte-clean exit: git status --porcelain empty at 256d8d5. Five source files injected and
  restored with matching sha256 (app.js 9bbcb03a, links.js e670113a, store.go 218b7555,
  poll.go 2c3de7a4, render.js bd538a9f); five reviewer probe files and one output
  directory created and deleted. Nothing committed, nothing pushed, shared checkout
  untouched.

  Recommendation: fix cycle to the same car for MAJOR-R1-2/3/4 (mechanical). MAJOR-R1-1
  likely needs an owner ruling on the board's readability posture rather than a car's
  unilateral choice among nest / collapse behind chrome / cap per row.
task-id: view-69-71-review-r1
```