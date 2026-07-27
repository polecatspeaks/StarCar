<!-- starcar-integrity: sha256=7cf68b5f91600a5a4da8e1fe7f87f978828642af8208bf9b29e60ea1994c72a8 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# View train #28+#12 car review, round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review
Round: 1
Target: `car/view-28-12 HEAD 3076a40 (commits 35eb832 + 3076a40)`
Base reviewed: `ab00e9c1b8eb7d45454cd82e01c24d347392582d`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a678b799208107386`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `ab00e9c1b8eb7d45454cd82e01c24d347392582d` |
| Entire checkpoint | `d25ee3c8e755` |
| Dispatch, the locator within the session | `a678b799208107386` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain ab00e9c1b8eb7d45454cd82e01c24d347392582d
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

I have completed the review. Verdict follows.

# ADVERSARIAL SENTENCE-CHECK REVIEW — view train #28 + #12, car round 1

**Verdict: REJECT — 4 Major, 6 Minor.**

Base verified before any work: worktree `<repo>-wt\review-view-28-12`, `git log --oneline -3` → HEAD `3076a40` ("board/web: clickable provenance links (#28) + car health bar (#12), docs"), parent `35eb832`, base `ab00e9c`. `git status --porcelain` empty at entry and at exit. Nothing committed, nothing pushed, shared checkout never touched.

The mechanism is largely sound and the real-browser work is genuine. The REJECT rests on three citation-truth defects the car's own commits created — the exact class this train has now paid for four times — plus one live wire defect I reproduced through the real Go server.

---

## Suite counts, re-derived by me at `3076a40`

| Suite | Observed at HEAD | Base `ab00e9c` (re-derived myself) | Car claimed |
|---|---|---|---|
| Go `board/` (`go test ./... -v`, top-level `--- PASS`) | **83 / 83**, 0 FAIL (103 incl. subtests) | **73** (scratch clone at `ab00e9c`) | 83 (+10) ✓ |
| `go vet ./...` | exit **0** | — | clean ✓ |
| Node `board/web` (CI's whole-directory `node --test --test-reporter=tap`) | **129 / 129**, 0 fail | **81** (same scratch clone, own `npm ci`) | 129 (+48) ✓ |
| `scripts/tests` (full) | **194 passed, 0 failed, 1 skipped** (195 total) | — | — |
| `scripts/tests/BoardDefs + WirePayload` | **18 / 18** | — | 18 ✓ |
| `scripts/probes` | **24 / 24** | — | 24 ✓ |
| `scripts/tests/DocPolicy.Tests.ps1` | **2 / 2** | — | 2 ✓ |
| `scripts/tests/CodeCitationPolicy.Tests.ps1` | **13 / 13** | — | — |
| `scripts/store-checks` | **212 / 212** (independently derived: 207 `*.json` records in `artifacts/`) | — | — |
| `board/web/probe-yard-snapshot.mjs` | **PASS** (`PROBE RESULT: PASS`, exit 0) | — | PASS ✓ |

Every claimed count reproduces. Base deltas +10 Go / +48 Node reproduce exactly.

---

## MAJOR-1 — Self-invalidated citation: `dom-writer.js:150` → `schema/yard-snapshot.schema.json:191`

`<repo>-wt\review-view-28-12\board\web\js\dom-writer.js:150`:
```
// already publication-safe per schema/yard-snapshot.schema.json:191), and
```

- At base `ab00e9c`, schema line 191 **was** `"storePathDisplay": { "type": "string", "description": "CWD-relative or home-collapsed - NEVER a raw absolute path..." }` — the citation was TRUE.
- At HEAD `3076a40`, schema line 191 is `            },` inside `dispatchesPayload`. `storePathDisplay` is now at line **214**.
- The shift was caused by **the car's own commit `35eb832`** (schema insertions at `@@ -111` , `@@ -120`, `@@ -140`, `@@ -166`, `@@ -190`).
- Aggravating: the comment pre-existed at base (`git show ab00e9c:board/web/js/dom-writer.js` line 87), and the car edited `dom-writer.js` in the very next commit (`3076a40`, 19 hunks) without trueing it.

Precedent is direct and in this repo: `artifacts/reviews/2026-07-23-board-car2-review-round1.md:99-102` (finding **C2R-1, MAJOR**, same class, same schema file). The repo also states the rule against itself at `board/server/poll.go:46-48`: *"cited by symbol/description, not line, since a line coordinate into a file the SAME commit edits is exactly the trap this convention exists to avoid."*

## MAJOR-2 — Same class, second site: design doc `:611` → `board/server/config.go:42`

`docs/design/2026-07-21-v0-yard-skeleton-design.md:611`:
```
measured: `StalenessMs` ships at `15000` (`board/server/config.go:42`) against a shop
```
- Base `config.go:42` = `		StalenessMs: 15000,` — TRUE at base.
- HEAD `config.go:42` = `	// RepoRoot is main()'s resolveDefaultRepoRoot result, threaded through`. The real line is **63**.
- Broken by the car's own commit `35eb832` (Config gained ~21 lines above it).
- Aggravating beyond MAJOR-1: commit `3076a40` appended the §12b amendment **to this same file starting at line 621** — ten lines below the citation it had just falsified.

## MAJOR-3 — Dead document path + fabricated attribution, three sites, all NEW content

| Site | Claim |
|---|---|
| `board/web/js/findings.js:32` | ``docs/CLAUDE.md's own worked example: "tooling-50-32-review-r1/-r2/-r3"`` |
| `docs/contracts/gating-matrix.md:53` (a **contract** document) | ``the swirl signature, `docs/CLAUDE.md`'s own `3 -&gt; 4 -&gt; 4` worked example`` |
| `docs/design/2026-07-21-v0-yard-skeleton-design.md:685` | ``(`docs/CLAUDE.md`'s own worked example: `tooling-50-32-review-r1/-r2/-r3`)`` |

Measured:
- **`docs/CLAUDE.md` does not exist.** `Test-Path docs/CLAUDE.md` → `False`; `Get-ChildItem -Recurse -Filter CLAUDE.md` returns only the repo-root `CLAUDE.md`.
- `git grep -n "tooling-50-32" -- . ':(exclude)artifacts'` → only the car's own new files (`findings.js:32`, `findings.test.js:70,93-95`, `dom-writer.test.js:482-484`) plus one unrelated design doc. **Not in `CLAUDE.md`.**
- `git grep -n -F "3 -&gt; 4 -&gt; 4" -- . ':(exclude)artifacts'` → only the car's own new files. `CLAUDE.md`'s actual swirl narrative reads **"climbing 3 to 4 to 5"** (`CLAUDE.md:262`), a different series entirely.
- The **true** source of both worked examples is **issue #12's body** (verified via `gh issue view 12`: ``7 -&gt; 1 -&gt; 0 renders healthy…`` and ``3 -&gt; 4 -&gt; 4, clustered renders critical…``). The car cites it correctly at `design:689` and `:691` ("the ticket's own `7 -&gt; 1 -&gt; 0` example") — so it knew the true source and mis-attributed it in three other places, one of them a landed contract document.

This is a confident falsehood on three documentation surfaces (Law 1), and a dead path a future reader cannot resolve.

## MAJOR-4 — Live wire defect: `Gate.Findings` carries a SUPERSEDED round's text next to the LATEST round's verdict

`board/assemble/assemble.go:294-300` asserts:
&gt; *fetches the RAW "findings" field off **the specific record the fold already named as this subject's returned winner** … **never a second "pick the latest" selection** (that authority stays fold.Output's alone, the same Law 6 trap `findRawIntentRecord` above already avoids…)*

The implementation (`assemble.go:301-313`) does no such thing — it returns the **first** `subject`-matching `kind=="returned"` record in `in.Records`:

- `board/store/store.go:187` — `sort.Strings(paths)` → records are lexically ascending; filenames are `returned-YYYYMMDDTHHMMSSZ.json`, so **first = OLDEST**.
- `board/fold/algorithm.go:183-192` — the winner is `parseInstant(i).After(parseInstant(j))` → **NEWEST**. `Gate.Outcome`/`Gate.At` (`assemble.go:120-131`) come from that winner.
- The sibling it cites as precedent, `findRawIntentRecord` (`assemble.go:207-221`), matches **subject + kind + `at`**. The `at` discriminator was dropped. `d.At` is in scope at the call site.

**OBSERVED, live, through the real Go server** (scratch store, one `gate` member with two `returned` records at 10:00 → `3 Major, 1 Minor` / 11:00 → `0 Major, 0 Minor`):
```json
{ "name": "the gate", "subject": "dup-review",
  "outcome": "APPROVE", "at": "2026-07-23T11:00:00Z",
  "recordDir": "dup-review", "findings": "3 Major, 1 Minor" }
```
The same wire lists the 10:00 record under `superseded`. The gate row asserts APPROVE while carrying the rejected round's findings.

**Not hypothetical on this repo's own store:** 30 subjects in `artifacts/` carry 2–5 `returned` records (`a13a5df25c7c6bf77` has 4; `af5f0b4f753a8f9d7` has 5) — this is the *dominant* review-round shape here, because rounds pile onto one minted-id subject rather than `-rN` subjects. #12's health trend is computed directly from this field, so the badge would report a stale Major count beside a current verdict — Law 1 on a truth surface. **No test covers it**: every fixture (`real-board-server.js:146-171`, `assemble_test.go`, `wireschema_test.go`) uses exactly one `returned` record per subject.

---

## Minor findings

**MINOR-1** — `board/server/snapshot.go:65-66`: *"All three are `""` when GitHubRepo/RepoRoot are unconfigured"*. OBSERVED at HEAD with no GitHub config: `{"githubRef":"dev","githubArtifactsPrefix":"artifacts"}`. `githubRef` can never be `""` (`config.go:64` `GitHubRef: "dev"` in `DefaultConfig`); `githubArtifactsPrefix` is computed from `RepoRoot`/`StorePath` independently of `GitHubRepo`. Repeated at `design:627` ("each `""` (or absent) when unconfigured/unresolvable"). No live defect — `links.js:17,33` correctly gate on `githubRepoUrl` — but the wire-contract comment is false about the wire it documents.

**MINOR-2** — "identical className either way" is literally false at `dom-writer.js:47`, `design:665`, and in the `3076a40` commit body: linked form is `` `${className} provenance-link` ``, plain form is `className`. `dom-writer.js:47-50` contradicts itself two clauses later ("with 'provenance-link' appended only on the linked form"). The intended, true claim is that the *base* className is preserved.

**MINOR-3** — `assemble.go:271-274` justifies first-write-wins with *"store.Adapter.Scan walks artifacts/&amp;lt;subject&amp;gt;/*.json"*. It does not: `store.go:172-183` `filepath.WalkDir`s the whole store root for any `*.json` and imposes no layout. The invariant does hold today (I verified: zero subjects span two directories across all 207 records), but the cited enforcement mechanism does not exist.

**MINOR-4** — Uncheckable citation in landed documents: `findings.js:14-15` and `design:683` both say the parser was calibrated *"against a sample of this repo's OWN real `findings` text (see this car's final report for the exact records read)"*. A car report is not a durable artifact here; no future reader can check it. (I re-derived the calibration independently — see the trace — so the substance is sound; the citation form is not.)

**MINOR-5** — `design:644` cites ``board/assemble.go``'s `recordDirBySubject`. No such file; the path is `board/assemble/assemble.go`.

**MINOR-6** — #28's only activation switch, `STARCAR_GITHUB_REPO`, appears in **no user-facing document**. `README.md:65-96` (Quickstart) and `docs/setup.md` name no `STARCAR_*` variable at all. A stranger deploying from the README sees zero provenance links and has no way to learn why. Not a regression (`STARCAR_STORE_PATH`/`STARCAR_DEMO_MODE` are equally undocumented) and no document makes a false claim — hence Minor, not Major.

**Notes, not findings.** (a) `computeHealthTrends`' bullet *"'first-round': exactly one round observed so far"* is not what the code does when that round has 0 Majors — OBSERVED: single round `0 Major, 0 Minor` → `{"trend":"converged","majorsSeries":[0]}`; single round `3 Major` → `first-round`. Behavior is defensible; the bullet is loose. (b) `factOrLink` sets `rel="noopener"` with no `target="_blank"` — inert.

---

## SENTENCE TRACE A — provenance, every hop

| # | Hop | file:line | Observed |
|---|---|---|---|
| 1 | Env → Config | `board/server/config.go:108-113` | `STARCAR_GITHUB_REPO`/`_REF` only override when present and non-empty |
| 2 | RepoRoot resolution | `board/server/main.go:86-93`, `reporoot.go:19-27` | cwd, then cwd's parent, for a dir holding both `artifacts` and `schema` |
| 3 | Prefix computation | `board/server/githublinks.go:38-49` | `filepath.Rel(repoRoot, storePath)`, `""` on `..`-escape; **RUN from `board/` (the README's own `cd StarCar/board &amp;&amp; go run ./server`)** → `"githubArtifactsPrefix":"artifacts"`, **not** `"../artifacts"` — the claim at `githublinks.go:23-32` is TRUE, measured |
| 4 | recordDir derivation | `board/assemble/assemble.go:275-292` ← `store.Record.Path` (`store.go:191-301`, `rel` = store-root-relative) | **Never** re-derived from `subject`. Verified the sanitisation gap is real: `artifacts/train-board-v0/` holds subject `train:board-v0` (colon→dash), so a client-side derivation would be wrong |
| 5 | Wire | `snapshot.go:68-70`, `types.go:16-25,57-69`, `schema/yard-snapshot.schema.json:114-118,128-132,153-156,187-190,215-227` | Live `/api/snapshot`: `{"githubRepoUrl":"https://github.com/polecatspeaks/StarCar","githubRef":"dev","githubArtifactsPrefix":"artifacts"}`, `tickets:["#1"]`, `recordDir:"a184e26ee16e704ae"` |
| 6 | View model | `render.js:172-179, 202-204, 220-224, 234, 257` | `?? null` / `\|\| ''`, no munging |
| 7 | URL build | `links.js:16-20, 32-37` | `null` unless every ingredient present; `^#(\d+)$` only |
| 8 | DOM | `dom-writer.js:51-59, 281, 288, 329, 360` | `&lt;a&gt;` or `&lt;span&gt;`, base className preserved |
| 9 | Rendered | real Chromium | `&lt;a class="car-subject provenance-link" rel="noopener" href="https://github.com/polecatspeaks/StarCar/tree/dev/artifacts/hot-car"&gt;` — 102 anchors on the real store |

**Client never string-munges a subject into a path** — confirmed: `links.js` takes `recordDir` only; `git grep` finds no subject→path transformation anywhere in `board/web/js/`.

**Degrade-honest branch, OBSERVED with no GitHub config:** `anchorCount: 0`; `span.car-subject` ×10, `span.solari-subject` ×91 — byte-for-byte the same classNames base emitted (`git show ab00e9c:board/web/js/dom-writer.js:215,256,274` all `el(doc,'span',&lt;same class&gt;,…)`). No layout shift on those three surfaces.

## SENTENCE TRACE B — health, every hop

| # | Hop | file:line | Observed |
|---|---|---|---|
| 1 | Store record | `artifacts/**/returned-*.json`, `"findings"` is a JSON **string** (verified: `"findings": "0"`) | — |
| 2 | Selection | `assemble.go:301-313` | **DEFECTIVE — see MAJOR-4** (oldest, not the fold's winner) |
| 3 | Wire | `types.go:62-69`, schema `:153-156` | `findings` verbatim, `omitempty` |
| 4 | Parse | `findings.js:16,23-28` | Head-anchored `^\s*(\d+)\s+majors?\s*,\s*(\d+)\s+minors?\b` |
| 5 | Family key | `findings.js:34,40-43` | `-r\d+$` stripped |
| 6 | Sort + trend | `findings.js:87-107` | Sorted by `at`, latest round only |
| 7 | Register class | `dom-writer.js:84-88`, `board.css:432-441` | `register-nominal` / `register-needs-attention` / **no class** |
| 8 | Pixel | real Chromium | see #40 block below |

**Head-anchoring, run against this repo's ACTUAL store (207 records):** 28 parse, **83 render UNKNOWN**. The brief's named trap, taken verbatim from `artifacts/a076bf6c0a94e302f/` — `"none outstanding — all 2 Major, 4 Minor, 1 Note from round-1 REJECT verdict fixed and verified"` — parses **`null`**. Confirmed also `null` for `"One Major, so REJECT"`, `"Zero Major, zero Minor"`, `"Three Minor, zero Major"`, `"0"`, `"none"`. Law 1 honored: ~75% of the real corpus honestly renders unknown rather than a guess.

**`r10` vs `r2` sorts by `at`, not lexically:** `familyKey('tooling-50-32-review-r10')` → `tooling-50-32-review` (same key as `-r2`); `findings.js:87` sorts on `a.at`, and `findings.test.js` test 17 pins it. Verified by direct call.

---

## #40 RENDERING CHECK — computed rgb, real browser, real Go server

Real Chromium (playwright 1.61.1, `chromium.launch()`), real `board/server` binary built from HEAD, real/scratch stores. **All values below are `getComputedStyle(...).color` I observed, not asserted:**

| Element | Observed rgb |
|---|---|
| `● stalled (3→4→4)` badge | **`rgb(255, 74, 58)`** |
| live `.register-needs-attention` probe | **`rgb(255, 74, 58)`** — match |
| `▼ converged (3→0)` badge | **`rgb(217, 213, 201)`** |
| live `.register-nominal` probe | **`rgb(217, 213, 201)`** — match |
| neutral `.health-trend` (no register class) | **`rgba(217, 213, 201, 0.55)`** |
| `a.provenance-link` inside `.car-chip.register-needs-attention` | **`rgb(255, 74, 58)`** — the row's register color |
| same anchor inside `.solari-row.register-needs-attention` | **`rgb(255, 74, 58)`** |
| `a.provenance-link` inside a nominal row | **`rgb(217, 213, 201)`** |
| `a.ticket-link.provenance-link` in `.train-tickets` | **`rgba(217, 213, 201, 0.55)`** |
| **browser default anchor colour** (control) | **`rgb(0, 0, 238)`** |

**Three-register law: HONORED, measured.** No fourth colour anywhere. `color: inherit` is doing real work — the control proves an unstyled anchor would be `rgb(0,0,238)`; every provenance link instead computes to its container's register colour. `href` on the hot-row anchor: `https://github.com/polecatspeaks/StarCar/tree/dev/artifacts/hot-car`.

### Non-vacuity — my own fault injections, at HEAD, reverted byte-identical

**Injection 1 — CSS cascade (on disk, not a style tag).** `board/web/css/board.css`, sha256 before `EAD50B55739D6C86AD845D73E039F0441C008E78178C067FE8E7E1F83BBE20AB` → injected sha256 `D7A42D26927CC76F769EB403493EBA277B11C5C09813B905EDFE555AD15F4AFA`. Appended a naive later-in-file `.health-trend { color: var(--text-dim); }` (keeping the guarded rule verbatim so the test's own precondition still held). **Observed RED, verbatim:**
```
not ok 2 - #12: a CONVERGED trend badge renders the real .register-nominal computed color…
    converged badge color rgba(217, 213, 201, 0.55) did not match the live .register-nominal color rgb(217, 213, 201)
not ok 4 - #12: with the fault injection removed, the stalled badge is HOT again…
# tests 4 / # pass 2 / # fail 2
```
Reverted → sha256 back to `EAD50B55739D6C86AD845D73E039F0441C008E78178C067FE8E7E1F83BBE20AB`, `git status --porcelain` empty. Guard is **non-vacuous**; it fires on exactly the #31 cascade-order class.

**Injection 2 — the head anchor.** `board/web/js/findings.js`, sha256 before `0361B249BFF71E179DEA2557ED89B2E4013DC15627363B730EAEE452229C506B` → injected `73B1E259A3809E5BB9CDE0802F3A0C56328CDDD309F6732E151F3CA58B34173E` (dropped `^` from `FINDINGS_HEAD_PATTERN`). **Observed RED, verbatim:**
```
not ok 5 - parseFindingsCounts: UNKNOWN - the count embedded mid-sentence, never at the head, is ambiguous and never guessed
    AssertionError: actual: { majors: 2, minors: 4 }, expected: null, operator: 'strictEqual'
# tests 18 / # pass 17 / # fail 1
```
Reverted → sha256 back to `0361B249…C506B`, `git status --porcelain` empty.

**Baseline green re-run after both reverts:** browser cascade 4/4, Go 83/83, `go vet` exit 0, Node 129/129, `git status` clean at `3076a40`.

### The car's `http.FileServer` 304 disclosure: **TRUE**, verified

Probed directly (`http.FileServer` at `board/server/handlers.go:20`), scratch repo root, mtime pinned into one second:
```
GET#1 200  Last-Modified: Sun, 26 Jul 2026 12:00:00 GMT  len 19448
GET#2 unconditional after same-SECOND edit -&gt; 200 len 19468 has marker: true
GET#3 conditional (If-Modified-Since = that same second) -&gt; 304
```
A client that already fetched the stylesheet and reloads within the same mtime second gets **304** and keeps the stale CSS — exactly the false negative disclosed at `browser-health-trend-cascade.test.js:108-113`. The disclosure is accurate. (My own disk-edit injection escaped it only because each `node --test` run spawns a fresh browser with an empty cache.)

---

## #13 verdict fields

**BASE-DELTA.** Beyond the diff's obvious scope, a base user with **no GitHub config** does see one change, and it is **not NONE**: a new `.train-tickets` strip renders under the track title. OBSERVED, unconfigured server, real browser:
```html
&lt;div class="train-tickets"&gt;&lt;span class="ticket-link"&gt;#1&lt;/span&gt;&lt;/div&gt;   /* rgba(217, 213, 201, 0.55) */
```
`dom-writer.js:278-284` renders the strip whenever `train.tickets.length &gt; 0`, independent of GitHub config; only the anchor-vs-span choice is config-gated. This is honest data (`manifest.tickets`) and within #28's scope, and no document claims zero visual delta — but the brief's expectation of "NONE" is not met, so it is recorded here rather than assumed. All other surfaces are byte-equivalent to base: 0 anchors, `span.car-subject`/`span.solari-subject` with base classNames, wire `config` gains only additive keys. `go vet` clean, all pre-existing suites unchanged.

**UNREPRODUCIBLE EVIDENCE** (distinct from findings):
1. *"the conductor's own ruling on this issue"* (`links.js:3`, `design:661`) — `gh issue view 28` shows **0 comments**; the ruling presumably lives in the car's brief, which I do not hold. My own brief independently confirms the GitHub-URL/narrowed-surface decision, so the substance is corroborated; the citation itself is not repo-checkable.
2. *"see this car's final report for the exact records read"* (MINOR-4) — the report is not an artifact I can open. I re-derived the calibration independently against all 207 store records instead.
3. The car's specific historical observation that an *earlier version* of its test wrote+reloaded and saw a stale colour is a past-run event I cannot replay; I verified the **mechanism** it names is real (304 probe above), which is the checkable half.
4. Screenshots under `docs/screenshots/2026-07-26-view-28-12-candidates/` are Playwright captures from the car's box; I verified the code path that produces them (`verify-registers.mjs:103-120`) and its honest disclosure that record-dir links do not render there (temp-dir store → empty prefix), which I independently reproduced. I did not re-rasterise the PNGs.

---

## The four disclosures, adjudicated

1. **Two-commit granularity instead of per-ticket — ACCEPTABLE.** The shared surface is real, not a convenience: `assemble.Gate` (`types.go:53-69`) gains `RecordDir` (#28) and `Findings` (#12) together, and `wireschema_test.go` asserts both in one E2E conformance test. Splitting would have left a struct half-populated in one commit. Disclosed in the `35eb832` body.
2. **State-ledger non-update — ACCEPTABLE; both legs of the reasoning verified TRUE.** (a) Precedent: `docs/contracts/state-ledger.md`'s process-state table (rows at `:102-111`) contains **no** `StorePath`, `DemoMode`, `PollMs` or `StalenessMs` row — grep returns zero. Immutable startup config is genuinely unledgered here. (b) Immutability: `git grep "s\.cfg\.[A-Za-z]* *=" -- board/server` returns **nothing**; `Config` is built once in `main()` (`main.go:80-108`) and never written after `NewServer`. The three new fields are the same class. Not a finding.
3. **GitNexus unavailable, manual tracing substituted — ACCEPTABLE.** GitNexus is an index over the code, not a source of truth; this repo's own probe doctrine ranks reading/running the real thing above any index. Every structural claim I checked was resolvable by direct read, and every behavioural one by running. Note, without irony: manual tracing did not prevent MAJOR-1/2/3, which are precisely what a call-graph tool would not have caught either — they are citation defects, and only opening the cited line finds them.
4. **board-condition / superseded links out of scope — ACCEPTABLE, and never-drop is honored.** Issue #28's body lists five surfaces; three landed. The follow-on is really filed: **issue #71, OPEN, "Provenance links, remaining surfaces: board-condition entries + superseded entries (follow-on from #28)"**. This is the same check `#62`'s MINOR-1 failed; here it passes.

---

## Constitution check

| Law / rule | Evidence |
|---|---|
| **Law 1 (no confident falsehood)** | **VIOLATED** — MAJOR-3 (a document that does not exist, credited with examples it does not contain, on three surfaces including a contract doc); MAJOR-4 (a gate row asserting APPROVE beside a superseded round's findings, reproduced live); MINOR-1. Honored elsewhere: 83/207 findings strings render UNKNOWN rather than guess. |
| **Law 6 (no unowned second copy)** | HONORED — `recordDir` single-sourced from `store.Record.Path`, never re-derived client-side (`links.js` takes only `recordDir`); the colon→dash gap is real and sidestepped. Parsing happens in exactly one place (`findings.js`). |
| **Law 7 (the stranger)** | PARTIAL — no hardcoded repo identity anywhere; unconfigured yards degrade to zero links. But MINOR-6: the switch that turns the feature on is named in no user-facing doc. |
| **Three-register law** | HONORED, measured in a real browser: only `rgb(217,213,201)` and `rgb(255,74,58)` plus the neutral `rgba(...,0.55)`; the control proves link-blue `rgb(0,0,238)` is defeated by `color: inherit`. |
| **Living documents (same-commit truth)** | **VIOLATED** — MAJOR-1 and MAJOR-2 are exactly this: commits that invalidated a document and did not update it, in files the same car edited. |
| **Red-first / non-vacuity** | HONORED and independently proven — two fault injections at HEAD, both observed red for their stated reason, both reverted byte-identical by sha256. |
| **Code citation standard (#N)** | HONORED — every new file carries a bare `#28`/`#12`; `CodeCitationPolicy.Tests.ps1` 13/13. |
| **Gating matrix arithmetic** | HONORED — header "10 surfaces (3 dispatch-harness + 7 yard-board)"; counted rows: 3 (`:19-21`) + 7 (`:47-53`) = 10. |
| **Never-drop** | HONORED — issue #71 exists and is open. |
| **Merge north star** | Not satisfiable at this state — four Majors stand. |

## What a fix round must close

1. Retarget or de-line-number `dom-writer.js:150` (prefer symbol/description form, per `poll.go:46-48`'s own convention).
2. Retarget or de-line-number `design:611`.
3. Correct all three `docs/CLAUDE.md` attributions to **issue #12** (and `CLAUDE.md` for the swirl doctrine, whose real series is 3→4→5), in `findings.js:32`, `gating-matrix.md:53`, `design:685`.
4. Pass `d.At` into `findingsForReturnedSubject` and match on it — mirroring `findRawIntentRecord` — with a red-first test using **two `returned` records on one subject** (the shape 30 of this store's subjects actually have), plus a Go-side assertion that the returned `findings` belongs to the same record as `Outcome`/`At`.
5. Sweep MINOR-1..6.

I edited nothing, committed nothing, pushed nothing. Worktree left byte-clean at `3076a40` (`git status --porcelain` empty; both injected files back to their original sha256).

```starcar-artifact
outcome: REJECT
findings: |
  4 Major, 6 Minor.
  MAJOR-1: self-invalidated citation - board/web/js/dom-writer.js:150 cites schema/yard-snapshot.schema.json:191 for storePathDisplay. TRUE at base ab00e9c (base schema:191 IS that line); FALSE at HEAD 3076a40 (schema:191 is a brace in dispatchesPayload; the real line is 214). Broken by the car's own commit 35eb832; the car then edited dom-writer.js in commit 3076a40 and left it standing. Precedent artifacts/reviews/2026-07-23-board-car2-review-round1.md:99-102 rules this class MAJOR.
  MAJOR-2: same class - docs/design/2026-07-21-v0-yard-skeleton-design.md:611 cites board/server/config.go:42 for StalenessMs 15000. TRUE at base; at HEAD config.go:42 is a RepoRoot comment and the real line is 63. Broken by commit 35eb832; commit 3076a40 appended the section 12b amendment to this same file starting at line 621, ten lines below the citation it had just falsified.
  MAJOR-3: dead document path plus fabricated attribution, three sites, all new content - board/web/js/findings.js:32, docs/contracts/gating-matrix.md:53 (a contract document), docs/design/2026-07-21-v0-yard-skeleton-design.md:685 all cite "docs/CLAUDE.md". That file does not exist (only the repo-root CLAUDE.md). git grep outside artifacts finds "tooling-50-32" and "3 -&gt; 4 -&gt; 4" ONLY in the car's own new files; CLAUDE.md:262's real swirl series is "3 to 4 to 5". The true source of both worked examples is issue 12's body, which the SAME design doc cites correctly four lines later.
  MAJOR-4: live wire defect - board/assemble/assemble.go:301 findingsForReturnedSubject returns the FIRST subject-matching returned record in scan order, which board/store/store.go:187 sort.Strings makes the OLDEST, while the fold's winner (board/fold/algorithm.go:183-192) is the NEWEST. Observed through the real Go server: gate outcome APPROVE at 2026-07-23T11:00:00Z carrying findings "3 Major, 1 Minor" from the 10:00 record the same wire lists as superseded. 30 subjects in this repo's own artifacts store carry 2-5 returned records. The doc comment at assemble.go:294-300 asserts the exact opposite; the sibling it cites as precedent, findRawIntentRecord at assemble.go:207-221, matches on at - that discriminator was dropped, and d.At is in scope at the call site. No test covers the multi-returned case.
  MINOR-1: board/server/snapshot.go:65 claims all three GitHub config fields are "" when unconfigured; observed unconfigured wire emits githubRef "dev" and githubArtifactsPrefix "artifacts". Repeated at design:627.
  MINOR-2: "identical className either way" is literally false at dom-writer.js:47, design:665 and in the commit body; the linked form carries an extra provenance-link class.
  MINOR-3: assemble.go:271-274 attributes the one-directory-per-subject invariant to store.Adapter.Scan, which imposes no layout (store.go:172-183 walks the whole root). Invariant holds today; cited mechanism does not exist.
  MINOR-4: findings.js:14-15 and design:683 cite "this car's final report" for calibration evidence - not a durable, checkable artifact.
  MINOR-5: design:644 cites board/assemble.go; no such file (board/assemble/assemble.go).
  MINOR-6: STARCAR_GITHUB_REPO, the feature's only activation switch, is named in no user-facing document; a stranger following README.md:65-96 sees zero provenance links and no explanation.
abstract: |
  Adversarial sentence-check review of the view train's 28+12 car at HEAD 3076a40 (parent 35eb832, base ab00e9c), round 1. Base verified before any work; nothing committed or pushed; worktree left byte-clean.
  All claimed counts re-derived by me at 3076a40: Go 83/83 top-level pass, 0 fail, go vet exit 0 (base re-derived myself in a scratch clone: 73, so +10 confirmed); Node board/web whole-directory 129/129, 0 fail (base 81, +48 confirmed); scripts/tests 194 passed 0 failed 1 skipped; BoardDefs+WirePayload 18/18; probes 24/24; DocPolicy 2/2; CodeCitationPolicy 13/13; store-checks 212/212 against an independently counted 207 records; probe-yard-snapshot.mjs PASS.
  Rendering floor met with real Chromium against the real Go server. Observed computed colours: stalled badge rgb(255, 74, 58) equal to the live register-needs-attention probe; converged badge rgb(217, 213, 201) equal to the live register-nominal probe; neutral badge rgba(217, 213, 201, 0.55); a provenance anchor inside a needs-attention row rgb(255, 74, 58), against a measured browser-default anchor colour of rgb(0, 0, 238) - three-register law honoured, no fourth colour, color inherit doing real work. Two fault injections of my own at HEAD, both observed red for their stated reason and both reverted byte-identical: board.css sha EAD50B55739D6C86AD845D73E039F0441C008E78178C067FE8E7E1F83BBE20AB to D7A42D26927CC76F769EB403493EBA277B11C5C09813B905EDFE555AD15F4AFA and back, producing "converged badge color rgba(217, 213, 201, 0.55) did not match the live .register-nominal color rgb(217, 213, 201)"; findings.js sha 0361B249BFF71E179DEA2557ED89B2E4013DC15627363B730EAEE452229C506B to 73B1E259A3809E5BB9CDE0802F3A0C56328CDDD309F6732E151F3CA58B34173E and back, producing actual { majors 2, minors 4 } expected null. The car's http.FileServer 304 mtime-granularity disclosure was probed and is TRUE.
  Both wire sentences traced hop by hop with file:line. Provenance: verified the quickstart cwd case live (run from board/, githubArtifactsPrefix resolves to "artifacts", not "../artifacts"), verified recordDir is single-sourced from store.Record.Path and never re-derived client-side (the store really holds subject train:board-v0 under directory train-board-v0), and verified the degrade-honest branch emits zero anchors with base-identical classNames. Health: the head-anchored parser was run against all 207 real store records - 28 parse, 83 render UNKNOWN, and the brief's named mid-sentence trap string parses null, so Law 1 holds at that hop. The SELECTION hop does not: MAJOR-4 was reproduced live on the real server.
  Base-delta reported honestly: not NONE - an unconfigured base user now sees a new train-tickets strip rendering the manifest's ticket refs as plain spans. Unreproducible-evidence listed separately. All four car disclosures adjudicated ACCEPTABLE, including the state-ledger non-update, whose reasoning I verified on both legs (StorePath/DemoMode really are unledgered; s.cfg is never assigned after construction), and the scope deferral, whose follow-on issue 71 really exists and is open.
  Verdict REJECT on four Majors: three citation-truth defects the car's own commits created (two self-invalidated line citations in files it edited, one dead document path with fabricated attributions across a contract doc, a design doc and shipped code) and one live wire defect pairing a superseded round's findings text with the latest round's verdict. The mechanism is otherwise sound and the real-browser work is genuine.
task-id: view-28-12-review-r1
```