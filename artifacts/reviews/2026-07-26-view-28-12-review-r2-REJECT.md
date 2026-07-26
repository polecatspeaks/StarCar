<!-- starcar-integrity: sha256=3b304d5feaef69e0460c6f25ea1644246505c57741eecc125852db720ecd47c5 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# View train #28+#12 car review, round 2 (delta)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial delta re-review
Round: 2
Target: `car/view-28-12 HEAD 6346d7d (fix commit on 3076a40)`
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

# DELTA RE-REVIEW — view train #28 + #12, round 2

**Verdict: REJECT — 2 Major, 1 Minor (down from 4 Major, 6 Minor).**

Base verified before any work: `git checkout --detach 6346d7d670a7460a6173c3584f88af22bf288f4a` in `<repo>-wt\review-view-28-12`; HEAD `6346d7d`, parent `3076a40`, grandparent `35eb832`, base `ab00e9c`. `git status --porcelain` empty at entry and exit. Nothing committed, nothing pushed, shared checkout untouched.

The load-bearing fix (MAJOR-4) is excellent and I proved it non-vacuous myself. The new mechanism you told me to scrutinise is correctly integrated. The REJECT is narrow: the fix for MAJOR-3 **relocated** the defect rather than resolving it, and the sweep is claimed complete when it is not.

---

## Suite counts, re-derived by me at `6346d7d`

| Suite | Observed at `6346d7d` | Car claimed | Reconciliation |
|---|---|---|---|
| Go `board/` top-level `--- PASS` | **85 / 85**, 0 FAIL (105 incl. subtests) | 85 (+2) | ✓ exact; +2 over my round-1 83 |
| `go vet ./...` | exit **0** | clean | ✓ |
| Node `board/web` whole-directory (CI form) | **129 / 129**, 0 fail | 129 unchanged | ✓ |
| `scripts/tests` (full) | **194 passed, 0 failed, 1 skipped, 195 total** | "195/195" | **Reconciled, not a defect** — the one skip is `SessionStartGuardRunner.Tests.ps1:87`, which calls `Set-ItResult -Skipped` when `git branch --show-current` is empty. My worktree is **detached** (as my brief mandates); the car worked on attached branch `car/view-28-12`, where it runs. Identical to my round-1 observation. The commit message should say "194 passed / 1 skipped (detached)" or "195 on a branch checkout"; stating a bare 195/195 is imprecise, not false. |
| `scripts/probes` | **24 / 24** | 24/24 | ✓ |
| `scripts/tests/CodeCitationPolicy.Tests.ps1` | **13 / 13** | 13/13 | ✓ |
| `scripts/store-checks` | **212 / 212** | — | ✓ (207 `*.json` records) |
| `board/web/probe-yard-snapshot.mjs` | **PASS**, exit 0 | PASS | ✓ |
| `browser-health-trend-cascade.test.js` | **4 / 4** | — | ✓ |

---

## Round-1 finding disposition — Present / Absent / DRIFTED

| ID | Disposition | Evidence I checked myself |
|---|---|---|
| **MAJOR-1** `dom-writer.js:150` → `schema:191` | **PRESENT-fixed** | Now `schema/yard-snapshot.schema.json`'s `config.storePathDisplay` property, by symbol. Property confirmed present (schema:212/228). No line coordinate remains. |
| **MAJOR-2** `design:611` → `config.go:42` | **PRESENT-fixed** | Now `board/server/config.go`'s `DefaultConfig()` function. Confirmed: `func DefaultConfig()` at `config.go:57`, `StalenessMs: 15000` at `:63`. |
| **MAJOR-3** `docs/CLAUDE.md` ×3 | **DRIFTED** | The nonexistent path is gone from all three sites. `gating-matrix.md:53` is now **correct** (attributes only `3 -&gt; 4 -&gt; 4` to issue #12 — verified: 1 occurrence in the issue). But two sites replaced it with a **new false attribution** → **MAJOR-R2-1** below. |
| **MAJOR-4** oldest-findings/newest-verdict | **PRESENT-fixed**, re-derived by fault injection | `findingsForReturnedSubject(records, subject, at)` now matches subject+kind+`at`, mirroring `findRawIntentRecord`. See fault-injection block. |
| **MINOR-1** `snapshot.go` "all three are `""`" | **PRESENT-fixed** | `snapshot.go:62-84` now states each field's independent condition; matches the live wire I re-observed (`{"githubRef":"dev","githubArtifactsPrefix":"artifacts"}` with no repo configured). Design `:631-639` trued the same way. |
| **MINOR-2** "identical className" | **PRESENT-fixed** | `dom-writer.js:51-59` and `design:675-679` now say the BASE className is preserved with `provenance-link` APPENDED. Accurate. |
| **MINOR-3** `Scan` enforces the layout | **PRESENT-fixed** | `assemble.go:291-301` now names it an OBSERVED producer convention, states `Scan` walks the whole root with no layout requirement, and names first-write-wins as defensive-not-load-bearing. Matches `store.go:172-183`. |
| **MINOR-4** "see this car's final report" | **PRESENT-fixed, all four numbers independently re-derived** | See reconciliation below. |
| **MINOR-5** `board/assemble.go` | **PRESENT-fixed** | `design:655` now `board/assemble/assemble.go`. (`board/assemble.manifestPayload` / `board/assemble.Gate.Findings` at `:667`/`:691` are Go package-qualified symbols, not paths — correct form.) |
| **MINOR-6** undocumented env vars | **PRESENT-fixed** | `README.md:92-105`. Sentence-checked below. |

**8 of 10 fully closed. MAJOR-3 drifted. Nothing regressed on the other nine.**

---

## MAJOR-R2-1 (NEW) — the MAJOR-3 fix replaced a nonexistent document with a false claim about a real one

Two sites now assert a specific, checkable provenance — and it is false:

- `<repo>-wt\review-view-28-12\board\web\js\findings.js:38` — ``// issue #12's own worked example: "tooling-50-32-review-r1/-r2/-r3" -``
- same file **`:41`** — ``// lives in issue #12's body, not in the root CLAUDE.md (whose own,``
- `docs\design\2026-07-21-v0-yard-skeleton-design.md:703` — ``(issue #12's own worked example: `tooling-50-32-review-r1/-r2/-r3` - CORRECTED ...``

**Measured.** I dumped issue #12's full body plus all three comments (`gh issue view 12 --json title,body,comments`, **5412 bytes**) and counted:

```
occurrences of 'tooling-50-32' in issue #12 : 0
occurrences of 'tooling'       in issue #12 : 0
occurrences of '-r1'           in issue #12 : 0
occurrences of '3 -&gt; 4 -&gt; 4'   in issue #12 : 1
```

So `3 -&gt; 4 -&gt; 4` really is issue #12's example — the gating-matrix correction is right. `tooling-50-32-review-r1/-r2/-r3` is **not in issue #12 at all**. It is a real dispatch-subject family that exists only in this repo's `artifacts/` store (e.g. `artifacts/a5234897d26a4e293/returned-20260726T135654Z.json`, "car tooling-50-32"), which is the durable, checkable source the citation should name.

This is the round-1 Major **relocated, not resolved**: a false provenance claim introduced by the fix for a false provenance claim, asserted more confidently than the original ("the string lives in issue #12's body"). Law 1. Two of three sites.

## MAJOR-R2-2 (NEW) — the sweep is claimed complete and is not

Commit `6346d7d` body: *"every line-number citation into a file **THIS TRAIN's** own commits edited **is now cited by SYMBOL/description instead** (poll.go's own pre-existing convention, **applied consistently**)."*

That universal claim is false. `<repo>-wt\review-view-28-12\board\server\elapsedbucket_test.go:26-27`:

```
// stays exact whenever a snapshot IS served fresh: board/web/js/dom-
// writer.js:201 renders elapsed_seconds verbatim to the second, never a
```

`dom-writer.js` is a file this train edited **twice** (`3076a40`, `6346d7d`). At HEAD, `dom-writer.js:201` is `  return strip;` inside `renderBoardConditionsStrip`; the real `solari-elapsed` render is at **`dom-writer.js:376`**.

Two things make this a Major rather than a note. First, **the underlying citation predated the train** (I verified in round 1 that base `dom-writer.js:201` was already the wrong line), so I am *not* charging the car with breaking it — I am charging the **false completeness claim** in the durable record, on the exact axis round 1 rejected. Second, the miss is aggravated by location: this same comment block demonstrates the correct discipline **twice** — `:18-20` base-pins `poll.go:399-412` to commit `8b9df53` with a `git show` recipe and notes the comment no longer exists at HEAD, and `:29-32` says outright *"cited by symbol, not line: this comment shifts every time an unrelated edit lands above it."*

**Why both the car and a naive grep miss it:** the citation is **line-wrapped** (`board/web/js/dom-` / `writer.js:201`), so no basename-anchored search finds it. My own basename sweep missed it too; I found it only by grepping the bare `\.js:[0-9]+` shape. That is the remedy note: sweep on the coordinate shape, not the filename.

## MINOR-R2-1 (NEW) — a correct attribution was changed into an incorrect one

`board/web/js/findings.js:75-77` now reads: *"root CLAUDE.md's **GUIDE STAR** section names a REJECT itself as `"a success outcome for the process,"`"*.

Measured: that verbatim string is at **`CLAUDE.md:605`**, inside `## Review calibration (binding, uniform)` (heading at `CLAUDE.md:595`) — not GUIDE STAR. The substance survives (GUIDE STAR at `CLAUDE.md:502` does list *"a REJECT at any gate, at any round number"* among success outcomes), hence Minor. But note the direction of travel: the **prior** wording was *"per CLAUDE.md's own review-calibration framing"* — which was **correct**. The fix broke a citation that was right.

---

## MAJOR-4's fix — re-derived by my own fault injection

`board/assemble/assemble.go` sha256 before **`412310150A76F13ACB461FBE479B1FB3C6F55703EF9E594CDCDE1D03F9F48D40`** → injected (removed the three-line `at` guard, restoring the subject+kind-only match) **`CBC83BC3A660CBCEC21EED0D9C02ABAED32849DECE3E3CDFDC69F06300599704`**. **Observed RED, verbatim** — and it matches the car's quoted red exactly:

```
--- FAIL: TestAssembleGateFindingsMatchesFoldWinnerNotFirstScanOrder (0.00s)
    assemble_test.go:487: gate.Findings = "3 Major, 1 Minor", want the WINNING (newer, APPROVE, 11:00)
    record's findings "0 Major, 0 Minor" - not the superseded 10:00 REJECT record's "3 Major, 1 Minor"
--- FAIL: TestAssembleGateFindingsRecordNotFoundDisclosed (0.00s)
    assemble_test.go:530: Findings = "3 Major, 1 Minor", want empty (Law 1: never a guessed value...)
    assemble_test.go:546: expected a gate-findings-record-not-found board condition, got []
```

Reverted → sha256 back to `412310150A…8D40`, `git status --porcelain` empty, both tests PASS. **Non-vacuous, both of them.**

## The new mechanism — scrutinised as instructed

You were right to flag it; it holds up on every axis I could test.

1. **Registered where the taxonomy requires.** `board/store/condition_severity.go:74` → `TierFlag`. **And the registration is mechanically guarded, watched to fire:** I removed the entry (sha256 `D1D2FA379CEE2904BE80670827720A24726E3BB29CAE1CB323E19FDE01E7195E` → `50C9FC7ACAE5277801B42FEC67FAA125C000E758EBBD80A345E9DFCBE9D2F06A`) and `TestConditionSeverityMappingMatchesEmittedCodes` failed **by name**:
   ```
   condition_severity_test.go:195: code "gate-findings-record-not-found" is emitted by production
   source under board/ but has no conditionSeverity entry (#30)
   ```
   Reverted byte-identical to `D1D2FA37…195E`. That test AST-scans real production source and does **set equality** both directions, so it also proves the mapping is not stale.
2. **No other surface enumerates condition codes.** `schema/yard-snapshot.schema.json:68-77` types `code` as a bare `string` with no enum; `schema/vocab/board-defs.json` enumerates positions/outcomes/roles/liveness only — no condition codes; `board/web/js/render.js:70` `groupBoardConditions` groups by code generically with the server's register authoritative. Nothing to update. Grep for any other enumeration returned nothing.
3. **Wire-legal.** `RegisterForCode` returns `"needs-attention"`, which is in `$defs.register`'s closed enum (`schema:12`). `toWireCondition` (`poll.go:474`) passes code/detail/register straight through; all three are `required` and satisfied.
4. **#30 severity rules followed.** FLAG-tier, correctly: a data-integrity contradiction, filed alongside `manifest-record-not-found`, not treated as an expected pattern (which would be NOTE).
5. **It cannot fire spuriously.** My first worry was that gates might be built for in-flight members — the *old* comment even said *"a dispatched/presumed-lost winner has no findings to show."* Disproved by reading: `assemble.go:118` guards `if m.Role == "gate" &amp;&amp; d.State == "returned"`. And it cannot fire in production at all: `poll.go:312-327` builds the fold from `foldRecordsFrom(scanResult.Records)` — a type conversion over the *same* `Fields` maps — and passes `assemble.Input{Records: scanResult.Records, Fold: out}`, so `d.At` is byte-identical to some record's `at`. **Confirmed empirically:** the real store at HEAD serves `BOARD CONDITIONS: []`. The guard is an unreachable Law-1 assertion, which the car discloses as such and covers with a direct-construction test — the correct pattern, not a decorative guard.

**Beyond-minimum verdict: ACCEPTABLE.** It is genuinely inside MAJOR-4's remit (round 1 explicitly asked for "a Go-side assertion"), it is small, it is guarded, and it introduced no defect.

---

## MINOR-4 numbers — re-derived and reconciled

All four of the car's numbers reproduce exactly at my HEAD:

```
TOTAL *.json records under artifacts/ : 207
CAR'S METHOD (any *.json with a string findings field):  withFindings = 136  parsed = 38  unknown = 98
MY ROUND-1 METHOD (filename starts with 'returned-'):     withFindings = 111  parsed = 28  unknown = 83
```

**The delta is method, not error and not corpus growth.** Record count is unchanged at 207. I filtered on the `returned-` filename prefix in round 1; the car walks every `artifacts/**/*.json` and tests for a string `findings` field, which picks up 25 further records (migrated verdict records under other filenames). The car's method is the broader and more accurate one for the claim it makes, and its landed wording (`findings.js:14-21`, `design:696-701`) states the method so any reader can re-run it. **MINOR-4 is properly closed** — the citation moved from an unreachable report to a reproducible measurement.

## MINOR-6 — README sentence check, every hop

| Hop | Coordinate | Observed |
|---|---|---|
| Prose | `README.md:92-105` | "if you set two environment variables before starting the server"; "Neither is required" |
| The command | `README.md:98` | `STARCAR_GITHUB_REPO=your-owner/your-repo STARCAR_GITHUB_REF=dev go run ./server` |
| **Ran it verbatim**, POSIX shell, from `StarCar/board` (the quickstart's own cwd) | — | server came up; `/api/snapshot` returned `"githubRepoUrl":"https://github.com/your-owner/your-repo"`, `"githubRef":"dev"`, `"githubArtifactsPrefix":"artifacts"` |
| Code the command runs | `config.go:108-113` env overrides → `githublinks.go:19-49` | prefix resolved to `artifacts`, **not** `../artifacts`, from the `board/` cwd |
| Wire | — | `tickets: ['#1']`, `first car recordDir: a184e26ee16e704ae`, `dispatch[0] recordDir: reviews` |
| What a stranger sees | real Chromium | **102** `a.provenance-link` anchors, e.g. `href="https://github.com/polecatspeaks/StarCar/tree/dev/artifacts/hot-car"` |
| The "neither is required" claim | real Chromium, **no** env set | **0** anchors, `span.car-subject` ×10, `span.solari-subject` ×91, ticket rendered `&lt;span class="ticket-link"&gt;#1&lt;/span&gt;` — plain text, never a broken link |
| `"STARCAR_GITHUB_REF defaults to dev"` | `config.go:64` `GitHubRef: "dev"` | wire shows `"githubRef":"dev"` with nothing set |

**Every claim traces. The README is true.** One pre-existing caveat, not introduced here: the block is `sh` syntax (`VAR=x cmd`), which a Windows PowerShell reader cannot paste — but the quickstart directly above it is already `sh` throughout, so this is consistent with the document's existing posture, not a new gap.

---

## #40 floor

The car claims this round changed no client rendering. **Verified two independent ways, not read:**

1. **Comment-stripped source comparison** `3076a40` vs `6346d7d`: `dom-writer.js`, `findings.js`, `render.js`, `links.js`, `board.css` — all five **IDENTICAL**. Every changed line lies inside a `//` or `/* */` comment.
2. **Real-browser re-measurement** of my round-1 probe at HEAD, byte-for-byte identical to round 1: converged badge **`rgb(217, 213, 201)`** = live `.register-nominal` probe; stalled badge **`rgb(255, 74, 58)`** = live `.register-needs-attention` probe; neutral `.health-trend` **`rgba(217, 213, 201, 0.55)`**; ticket link **`rgba(217, 213, 201, 0.55)`** with `href="https://github.com/polecatspeaks/StarCar/issues/12"`, dotted `currentColor` bottom border; browser-default anchor control **`rgb(0, 0, 238)`**. `browser-health-trend-cascade.test.js` **4/4** including its own injected-cascade non-vacuity leg.

**Floor satisfied:** no rendered surface changed, proven by measurement; round 1's computed-style evidence (including the link-inside-a-needs-attention-row check at `rgb(255, 74, 58)`) carries forward unchanged. Three-register law still holds — no fourth colour.

## #13 fields

**BASE-DELTA vs `ab00e9c`.** Unchanged from round 1, verified again at HEAD with no GitHub config: the only thing an unconfigured base user sees that base did not is the `.train-tickets` strip — `&lt;div class="train-tickets"&gt;&lt;span class="ticket-link"&gt;#1&lt;/span&gt;&lt;/div&gt;`. Everything else is byte-identical to base rendering (0 anchors, `span.car-subject` ×10, `span.solari-subject` ×91). **This round adds nothing further:** `BOARD CONDITIONS: []` on the real store — the new `gate-findings-record-not-found` never fires; `healthBadges: 0`; wire config identical. Go +2 tests, no behaviour change for any user whose store is internally consistent.

**UNREPRODUCIBLE EVIDENCE.**
1. The car's `scripts/tests` "195/195" — I cannot reproduce it in a **detached** worktree (my brief mandates detached), where the run is 194 passed / 1 skipped by the test's own `Set-ItResult -Skipped` design. Environment difference, reconciled above, not a finding.
2. *"the conductor's own ruling on this issue"* (`links.js:3`, `design:672`) — issue #28 still has **0 comments**; the ruling lives in the car's brief, which I do not hold. Corroborated by my own brief; not repo-checkable.
3. Round-1 items unchanged: the car's historical observation about an earlier version of its own test (I verified the *mechanism* — `http.FileServer` 304s within one mtime second — but cannot replay the past run), and the screenshot PNGs (I verified the producing code path and its honest disclosure; I did not re-rasterise).

---

## CONVERGENCE RULING — findings are shrinking, but one is relocating. **Cap: one more round.**

Counts: **round 1 → 4 Major / 6 Minor. Round 2 → 2 Major / 1 Minor.** Declining, and eight of ten round-1 findings are cleanly closed with the load-bearing one proven by fault injection. That is real progress and I will not understate it.

Against the three swirl conditions in my brief:

1. **Major counts stop declining — NO.** 4 → 2.
2. **Findings cluster in the same section across rounds — YES.** Both new Majors are citation-truth, as were three of round 1's four.
3. **A round's findings include defects the previous round's own fixes created — YES, and this is the sharp one.** MAJOR-R2-1 is MAJOR-3's defect *moved*, asserted more confidently. MINOR-R2-1 **changed a correct attribution into an incorrect one**.

Two conditions hold, so per my brief I **set a cap: ONE more round.** If round 3 produces any new citation-truth defect created by round 2's own fixes, escalate to the owner instead of dispatching round 4.

**And name the instrument problem, because that is what the pattern is telling us.** Three rounds of hand-written provenance prose being corrected by more hand-written provenance prose is the shop's own "hammer to fix a watch". Two remedies, cheapest first:

- **Stop asserting where a string lives.** `familyKey`'s doc does not need a provenance claim at all — `"51-fix-review-r1/-r2/-r3"` is already in the same sentence and is a real subject in this store. Delete the attribution; the defect class disappears with it. Where a source genuinely helps, cite the durable one (`artifacts/a5234897d26a4e293/`) or the ticket only for what the ticket actually says.
- **Mechanise the coordinate class.** These are the same shape the repo already gates elsewhere (`CodeCitationPolicy.Tests.ps1`, `condition_severity_test.go`, `register_taxonomy_test.go` all read real sources and fail by name). A test that greps `\S+\.(go|js|css|md|json):\d+` outside `artifacts/` and asserts each coordinate resolves would have caught MAJOR-1, MAJOR-2 and MAJOR-R2-2 mechanically — including the line-wrapped one that defeated both the car's sweep and my first pass. Attention-tier keeps losing here; that is the Healing Loop's own ranking.

## What round 3 must close

1. `findings.js:38,41` and `design:703` — remove or correct the `tooling-50-32-review-r1/-r2/-r3` → issue #12 attribution (0 occurrences of `tooling` in the issue's 5412 bytes). Keep the `3 -&gt; 4 -&gt; 4` → issue #12 attribution; it is correct.
2. `elapsedbucket_test.go:26-27` — cite `dom-writer.js`'s `renderDispatches` / `solari-elapsed` span by symbol; and correct the commit-message sweep claim to what the sweep actually covered.
3. `findings.js:75-77` — the quoted sentence is in `## Review calibration` (`CLAUDE.md:605`), not GUIDE STAR; the previous wording was right.

## Constitution check

| Law / rule | Evidence |
|---|---|
| **Law 1** | **VIOLATED** — MAJOR-R2-1 (a checkable, false provenance claim at two sites); MINOR-R2-1; MAJOR-R2-2's false completeness claim. **HONORED** in the mechanism: the not-found branch discloses rather than rendering `""` as if the record had none; `RegisterForCode` fails loud on an undeclared code. |
| **Law 6** | HONORED — `condition_severity.go` remains the single owned code→tier mapping, guarded by AST set-equality; parsing stays solely in `findings.js`; findings text still single-sourced. |
| **Law 7** | HONORED and improved — `README.md:92-105` now tells a stranger how to enable the feature and that it is optional; traced end to end above. |
| **Three-register law** | HONORED — measured identical to round 1; no fourth colour; new condition reuses `needs-attention`. |
| **Living documents** | Mostly honored — MAJOR-1/2 closed, MINOR-1/2/3/4/5 trued in the same commit. Undercut by MAJOR-R2-1: a document updated into a new falsehood is not trued. |
| **Red-first / non-vacuity** | HONORED, independently proven — MAJOR-4's pin and the condition-taxonomy guard both fault-injected by me, both red for their stated reason, both reverted byte-identical. |
| **Code citation standard (#N)** | HONORED — new condition entry cites `#28/#12`; `CodeCitationPolicy.Tests.ps1` 13/13. |
| **Gating matrix** | HONORED — header arithmetic still 3 + 7 = 10; the new condition correctly rides the existing "Board conditions (general disclosure)" family row, matching #30's own precedent of not adding a row per code. |
| **Merge north star** | Not satisfiable — two Majors stand. |

Worktree left byte-clean at `6346d7d`: `git status --porcelain` empty; `board/assemble/assemble.go` = `412310150A76F13ACB461FBE479B1FB3C6F55703EF9E594CDCDE1D03F9F48D40`, `board/store/condition_severity.go` = `D1D2FA379CEE2904BE80670827720A24726E3BB29CAE1CB323E19FDE01E7195E`, both back to their HEAD values.

```starcar-artifact
outcome: REJECT
findings: |
  2 Major, 1 Minor (down from round 1's 4 Major, 6 Minor). Eight of ten round-1 findings fully closed; MAJOR-3 DRIFTED.

  MAJOR-R2-1 (NEW, relocation of round-1 MAJOR-3): the fix replaced a citation to a nonexistent document with a false claim about a real one. board/web/js/findings.js:38 and :41, and docs/design/2026-07-21-v0-yard-skeleton-design.md:703, now attribute the worked example "tooling-50-32-review-r1/-r2/-r3" to "issue #12's own worked example" and assert outright that "the string lives in issue #12's body". Measured: I dumped issue 12's full body plus all three comments (gh issue view 12, 5412 bytes) and counted ZERO occurrences of "tooling-50-32", zero of "tooling", zero of "-r1". The string is a real dispatch-subject family that exists only in this repo's artifacts store (e.g. artifacts/a5234897d26a4e293/returned-20260726T135654Z.json), which is the durable source the citation should name. The gating-matrix.md:53 site IS correct, because it attributes only "3 -&gt; 4 -&gt; 4", which the issue genuinely contains (1 occurrence). Law 1: a false provenance claim introduced by the fix for a false provenance claim, asserted more confidently than the original.

  MAJOR-R2-2 (NEW): the sweep is claimed complete and is not. Commit 6346d7d's body states "every line-number citation into a file THIS TRAIN's own commits edited is now cited by SYMBOL/description instead ... applied consistently." board/server/elapsedbucket_test.go:26-27 still carries a line citation into board/web/js/dom-writer.js, a file this train edited twice; at HEAD dom-writer.js:201 is "return strip;" inside renderBoardConditionsStrip, while the real solari-elapsed render is at line 376. The underlying citation predates the train, so the finding is the FALSE COMPLETENESS CLAIM in the durable record on the exact axis round 1 rejected, plus the remaining instance. Aggravating: that same comment block demonstrates the correct convention twice (:18-20 base-pins poll.go:399-412 to commit 8b9df53; :29-32 states "cited by symbol, not line"). The citation is line-WRAPPED ("board/web/js/dom-" newline "writer.js:201"), which is why a basename-anchored grep missed it - remedy: sweep on the coordinate shape, not the filename.

  MINOR-R2-1 (NEW): board/web/js/findings.js:75-77 attributes the verbatim quote "a success outcome for the process" to root CLAUDE.md's GUIDE STAR section. Measured: that string is at CLAUDE.md:605, inside the section headed "## Review calibration (binding, uniform)" (heading at CLAUDE.md:595). Substance survives (GUIDE STAR at CLAUDE.md:502 does list a REJECT at any gate among success outcomes), hence Minor - but the PRIOR wording ("per CLAUDE.md's own review-calibration framing") was CORRECT, so the fix broke a citation that was right.

  Round-1 dispositions: MAJOR-1 PRESENT-fixed (symbol citation, storePathDisplay property confirmed at schema:212). MAJOR-2 PRESENT-fixed (DefaultConfig() at config.go:57, StalenessMs 15000 at :63). MAJOR-3 DRIFTED (see MAJOR-R2-1). MAJOR-4 PRESENT-fixed, proven by my own fault injection. MINOR-1/2/3/5/6 PRESENT-fixed and verified. MINOR-4 PRESENT-fixed with all four numbers independently re-derived.
abstract: |
  Delta re-review, round 2, of fix commit 6346d7d on top of the 3076a40 I reviewed in round 1. Base verified (HEAD 6346d7d, parent 3076a40, base ab00e9c) before any work; worktree byte-clean at entry and exit; nothing committed or pushed.
  Suites re-derived by me at 6346d7d: Go 85/85 top-level pass, 0 fail, +2 over round 1's 83, go vet exit 0. Node board/web whole-directory 129/129, 0 fail. scripts/tests 194 passed, 0 failed, 1 SKIPPED, 195 total - reconciled against the car's "195/195": the single skip is SessionStartGuardRunner.Tests.ps1:87, which calls Set-ItResult -Skipped when git branch --show-current is empty, and my brief mandates a DETACHED worktree while the car worked on an attached branch. Environment difference, not an error. scripts/probes 24/24, CodeCitationPolicy 13/13, store-checks 212/212, probe-yard-snapshot.mjs PASS, browser cascade 4/4.
  MAJOR-4's fix re-derived by my own fault injection: removing the three-line "at" guard from findingsForReturnedSubject (assemble.go sha256 412310150A76F13ACB461FBE479B1FB3C6F55703EF9E594CDCDE1D03F9F48D40 to CBC83BC3A660CBCEC21EED0D9C02ABAED32849DECE3E3CDFDC69F06300599704) reproduced the car's quoted red verbatim, including assemble_test.go:487's gate.Findings = "3 Major, 1 Minor" want "0 Major, 0 Minor"; reverted byte-identical and both tests pass.
  The beyond-minimum addition was scrutinised as instructed and holds on every axis: gate-findings-record-not-found is registered FLAG-tier in condition_severity.go, and the registration is MECHANICALLY GUARDED - I removed the entry (sha D1D2FA379CEE2904BE80670827720A24726E3BB29CAE1CB323E19FDE01E7195E to 50C9FC7ACAE5277801B42FEC67FAA125C000E758EBBD80A345E9DFCBE9D2F06A) and TestConditionSeverityMappingMatchesEmittedCodes failed BY NAME, then reverted byte-identical. No other surface enumerates condition codes (schema types code as a bare string, board-defs.json carries none, the view groups generically), the register is schema-legal, and the guard cannot fire spuriously: gates are built only under "m.Role == gate AND d.State == returned" (assemble.go:118), and poll.go:312-327 feeds fold and assemble the same records, so the branch is unreachable in production - confirmed live, the real store serves an empty board-conditions array. ACCEPTABLE, no defect introduced.
  MINOR-4's four numbers all reproduce exactly at my HEAD: 207 store records, 136 carrying a findings field, 38 parsed, 98 unknown. The delta from my round-1 figures (28 parsed among 111) is purely METHOD - I filtered on the returned- filename prefix, the car walks every artifacts json - not corpus growth and not an error; record count is unchanged at 207.
  MINOR-6 sentence-checked hop by hop by RUNNING the README's documented command verbatim from the quickstart's own cwd: a stranger gets githubRepoUrl for the repo they named, githubArtifactsPrefix "artifacts" (not "../artifacts"), and 102 real anchors in a browser; with nothing set, zero anchors and plain-text spans. The README is true.
  The #40 floor is satisfied by verification, not assertion: comment-stripped sources for all five client files are IDENTICAL between 3076a40 and 6346d7d, and a real-browser re-measurement returned values byte-for-byte identical to round 1 (converged rgb(217, 213, 201), stalled rgb(255, 74, 58), neutral rgba(217, 213, 201, 0.55), browser-default anchor control rgb(0, 0, 238)). Base-delta versus ab00e9c is unchanged from round 1 - only the train-tickets strip - and this round adds nothing an unconfigured user would see.
  CONVERGENCE: counts are declining (4 Major to 2, 6 Minor to 1) and the load-bearing mechanism fix is excellent, but two of the three swirl conditions hold - findings cluster in the same class as round 1 (citation truth), and both new findings are defects the previous round's own fixes created, one of which turned a CORRECT attribution into an incorrect one. Per my brief I set a CAP of ONE more round, escalating to the owner if round 3 again produces a citation defect created by round 2's fixes. I also name the instrument problem: hand-written provenance prose corrected by more hand-written provenance prose keeps regenerating this class. The cheap fix is to stop asserting where a string lives; the durable one is a mechanical gate that resolves every file-colon-line coordinate outside artifacts, which would have caught MAJOR-1, MAJOR-2 and MAJOR-R2-2 including the line-wrapped instance that defeated both the car's sweep and my own first pass.
task-id: view-28-12-review-r2
```