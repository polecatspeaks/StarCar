<!-- starcar-integrity: sha256=527a71af70f1980ab5665f2d4e3022245f278297f71bc93f6ed9acfe6f87d677 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Freight lane #84 store-mediated ticket adapter, review round 2 (delta)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review (delta re-review)
Round: 2
Target: `car/adapter-84 fix-cycle r2 HEAD baf109e`
Base reviewed: `bc552dfc6f1d96575ac7646af119daabc408a599`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `af9695467e625f504`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `bc552dfc6f1d96575ac7646af119daabc408a599` |

| Dispatch, the locator within the session | `af9695467e625f504` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain bc552dfc6f1d96575ac7646af119daabc408a599
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Verification complete. Worktree clean at `baf109e`, both checkouts untouched.

# VERDICT: REJECT

**2 Major, 0 minor, 5 notes.** Base verified `baf109e8c29130771dee0030ed6010f3b06049e0`, detached, clean tree, before any read. Both checkouts clean at exit; all injections on an out-of-repo copy, every restore verified by sha256 **as its own separate call** plus `git diff`.

**All ten round-1 IDs are genuinely folded — I re-derived every one.** Both Law 1 Majors are closed in a real browser. The rejection is on two Majors that this round's own fixes *created*, both in the same family: **state-ledger currency**. That is the sharpest convergence signal, and I rule on it explicitly below.

---

## Suites — run myself at `baf109e`, one instrument per suite

| Suite | Car claimed | I observed | |
|---|---|---|---|
| Go `board` | 111/111 (was 108) | **111 PASS / 0 FAIL** | ✅ |
| `go vet` / `go fmt` | clean | vet exit 0; `go fmt ./...` **rewrote nothing** | ✅ |
| `board/web` node | 238/238 | **238 real tests** (per-file sum); trailer **240** | ✅ / see N1 |
| Pester `scripts/tests` | 236/0/4 of 240 | **240 total / 235 pass / 0 fail / 5 skip** | ✅ |
| `scripts/probes` | 29/29 | **29/29** (ManifestBoardJoin green — no Major) | ✅ |
| `scripts/store-checks` | 275/275 (was 271) | **275/275** | ✅ |
| `browser-freight-states` isolated | — | **5/5** | ✅ |
| `browser-dispatch-row-geometry` isolated | — | **3/3**, no density regression | ✅ |

**Detached-HEAD skip delta:** my 5th skip is `run-session-start-guards.sh … [ci-baseline] marker ONLY when attached to a branch`, reason verbatim *"is skipped, because detached HEAD (no branch)"*. On an attached branch it runs → **236 pass / 4 skip**. The car's claim is correct; my delta is exactly this one skip, same as round 1.

---

## MAJOR FINDINGS

### R2-M1 — The R1-M1 fix falsified its own state-ledger rows, and the ledger was not trued in the same commit

`CLAUDE.md` Living contracts is unambiguous: *"Any commit that adds or changes mutable service state updates the state ledger in the same commit… **Reviewers reject state-touching diffs that leave the ledger stale.**"* This commit changed the **write condition** of both ledgered maps and left all three claims describing the old unconditional behaviour.

Code (`board/server/poll.go`):
- `:400` `if freightFreshnessVal.Kind != "never-polled" { s.lastGoodAsOf["freight"] = newLastGood }`
- `:446` `if freightFreshnessVal.Kind != "never-polled" { s.lastGoodLaneData[spec.ID] = assembled.Freight }`

Document (`docs/contracts/state-ledger.md`), poll-success column, unchanged:
- **`:115`** — `lastGoodAsOf["live"|"freight"]` → **"UPDATED (both keys, same poll's `now`)"**. False whenever freight is never-polled.
- **`:116`** — `lastGoodLaneData[laneID]` → **"UPDATED per live lane ID (dispatches/gates/trains/freight, #84)"**. False for freight when never-polled.
- **`:136-139`** — the Question-1 amendment states: *"Lifecycle behaviour (restart/poll-success/scan-failure/reconnect) is **IDENTICAL in shape** to the existing `"live"` key's row… so **no new lifecycle column values were needed**."* This is now affirmatively wrong — divergence on poll-success **is the entire mechanism of the R1-M1 fix**.

`grep -n "never-polled" docs/contracts/state-ledger.md` returns **only** the unrelated `lastGoodSnapshot` row at `:111`. The gating condition appears nowhere in the ledger.

This is not a nitpick about tone: the ledger's own house style states conditionals explicitly (the `:116` row already spells out *"on the FIRST-EVER poll failure (empty map, nothing to retain) `lane.Data` stays `nil`"*). A reader auditing against `:115` would conclude freight's `lastGoodAsOf` always advances on a successful scan, and would then be unable to explain the very behaviour I measured in probe A. That is the lying-canary harm the rule exists to prevent.

### R2-M2 — `poll.go`'s state-ledger citation drifted to the table header, caused by this commit — the second drift of this same citation

`board/server/poll.go:123` cites `docs/contracts/state-ledger.md:108` for the `lastGoodLaneData` row, and its own text records that it has drifted before: *"#52 C51R-4: corrected from :102, which is the `seq` row, not this field's row"*.

Measured:
- At **`bc552df`**: `state-ledger.md:108` = the `lastGoodLaneData[laneID]` row. **Correct** (I verified and credited this in round 1).
- This commit inserted **8 content lines** (the R1-m6 "Amended…" block) *above* line 108.
- At **`baf109e`**: line 108 = the **table header** `| Field (owner class) | Process restart | Poll cycle (success) | …`; the real row moved to **`:116`**. 108 + 8 = 116, exactly.

Why the suite is green: `board/web/js/lanes.js:16-21` — a comment **this car edited for R1-m1** — states the reason verbatim: *"a line-number citation into a file this SAME train's commit still edits drifts on every later insertion, and **the #65 gate does not check in-range shifts**."* Line 108 still exists, so the citation resolver resolves it; it simply points at the wrong content. The car read that warning, edited around it, and then reproduced the exact defect it describes.

`docs/templates/car-brief.md:122-123`: *"Open every file:line the diff's docs cite and confirm the citation is true. A stale document or a dead citation is a MAJOR finding."* Low blast radius (it lands on the header of the correct table), but it is the third instance of one recurring defect. **The fix that ends it is the symbol form `lanes.js` already uses**, not `:116`.

---

## THE TEN ROUND-1 IDs

| ID | Status | Evidence I derived myself at `baf109e` |
|---|---|---|
| **R1-M1** | **PRESENT (fixed), not over-corrected** | 4 browser cases. Never-polled→failure now reads `"…- no good data has ever been read"`; my round-1 string is gone. Genuinely-good → `"showing last good from 2026-07-27T18:06:23Z"` + row retained. Heartbeat-lost-after-good → still last-good (correct: it *did* have good data). Stale → last-good preserved, matching the comment's explicit "never gate on `!= failed` alone". |
| **R1-M2** | **PRESENT (fixed), coverage complete** | Reproduced the original contradiction via a **real public-interface failure** (blocking file), then rendered that store: strip shows `1 FLAG / freight-tickets-without-heartbeat (x1) / "1 ticket record(s) exist but no ticket-sync heartbeat was found…"`. Fires on **S5 quarantined** and **S8 future-dated** heartbeats (2 FLAGS each) — because it gates on `Kind == "never-polled"`, not literal absence. Both negative controls silent. |
| **R1-M3** | **PRESENT (fixed), scope exceeds the finding correctly** | I opened **all 11 images**. 6-of-8 in `view-69-71` is **exact in both directions**: the six full-board captures show `FREIGHT / Dark / no equipment on this lane`; both r3 crops genuinely stop at TRAINS. `lane-filters.png` and `health-trend-and-provenance.png` both show freight — the latter confirming the car's **self-correction was real**. `first-light.png` commit `d4458775d…` verified: it is the commit that added that file. Register-check README's present-tense "never `live`" correctly rewritten to "AT THE TIME OF CAPTURE… **This is no longer true of FREIGHT**". No recapture anywhere. |
| **R1-M4** | **PRESENT (fixed)** | New header matches measured behaviour (my blocking-file run left `ticket-84/ticket.json`, no heartbeat, exit 1, fault logged). New test **proven non-vacuous**: moving the heartbeat write before the loop produced **exactly 1 red** — *"Expected $false, because the heartbeat is written LAST and must NEVER appear after a mid-run failure… but got $true."* The old test was honestly renarrowed to "a failure BEFORE the write loop even starts". |
| **R1-m1** | **PRESENT (fixed)** | The sentence `lanes.js` cites by symbol — `absence of the key itself is what signals "no payload" on the wire` — is preserved **verbatim** (flattened-comment substring check). Only the stale `freight/dark` enumeration was removed, plus a scoping clause appended. |
| **R1-m2** | **PRESENT (fixed)** | Commit message says **"238/238 real tests (was 234)"** — one instrument, explicitly labelled. My per-file sum: **238** at HEAD, **234** at `bc552df`. Delta +4, derivable. See N1 on the trailer. |
| **R1-m3** | **PRESENT (fixed)** | Real browser, store **under** the repo root: `#84` → `A href=".../tree/dev/&lt;store&gt;/ticket-84"` (store record dir); title → `A href=".../issues/84"` (issue). Two links, different targets. Unconfigured → `#84` degrades to a plain `SPAN`, title link survives. Honest degrade confirmed. |
| **R1-m4** | **PRESENT (fixed) — honest deferral, ruled** | Sentence-checked: `pwsh -File scripts/Sync-Freight.ps1` with stated defaults matches the param block exactly (`-StoreRoot artifacts -Owner polecatspeaks -ProjectNumber 6`). The row names the gap, the owner, the trigger, the candidate mechanism, and the consequence ("renders honestly `not yet polled`"). That is the trigger-gated table working as designed, not an omission dressed as one. |
| **R1-m5** | **PRESENT (fixed)** | 4-test ticket Context mirrors the manifest one faithfully: missing-payload caught, incomplete-payload caught, well-formed passes, ticket-sync validates on the base schema alone. Its scope limitation (fixture-only, no real ticket record committed yet) is disclosed **in the Context header** rather than hidden behind a vacuous "&gt;0 in the real store" guard. store-checks 271→275. |
| **R1-m6** | **PRESENT (fixed)** | The claim *"no producer script in this repo regenerates `index.md`"* is **TRUE** — I checked rather than assumed: `Produce-Artifact.ps1`'s only `New-ArtifactIndex` hit is a **comment** at `:333` explaining that `model` does not affect index columns, not an invocation. |

**No ID is Absent. No ID is DRIFTED.**

---

## THE STALE-BACKUP WINDOW — ruled

**Nothing in the final commit rests on evidence gathered during that window, and I can say so from evidence rather than from the car's assurance.** Every load-bearing behavioural claim in this commit was re-derived by me against the final tree at `baf109e`: the R1-M1 gate (4 browser cases), the R1-M2 condition (5 cases including a real adapter failure), the R1-M4 test's non-vacuity (by injection), all 11 screenshots opened, both freight links measured, and all six suites re-run. A contaminated mid-round observation could only survive into my verdict if I had trusted a reported number — I trusted none.

The disclosure itself is exemplary: caught by `git diff` against HEAD rather than against memory, disclosed **in the commit message**, and the remedy (re-diff against HEAD, not against your own recollection) is the same instrument I used for my own restores. The one residual is the car's timestamp-specific observation `"showing last good from 2026-07-27T17:35:48Z"`, which I cannot reproduce byte-for-byte — but I corroborated its **class** in both directions: present at `bc552df` (round 1), absent at `baf109e` (probe A).

---

## CONVERGENCE — ruled explicitly; NO CAP WARRANTED

Round 1: **4 Majors / 6 minors.** Round 2: **2 Majors / 0 minors.**

Against the three swirl triggers (escalate on **any two**):

| Trigger | Fires? | Evidence |
|---|---|---|
| Major counts stop declining | **NO** | 4 → 2, and the two remaining are documentation-currency, not the Law 1 defects. All 6 minors closed, none reopened. |
| Findings cluster in the same section across rounds | **NO** | Round-1 Majors: `poll.go` (×2), `docs/screenshots/`, `Sync-Freight.ps1` header. Round-2 Majors: `state-ledger.md` rows and a citation *into* it — a location that was only a **minor** (R1-m6) last round. The defects moved and shrank, which is the converging signature. |
| Round's findings are defects the previous round's fixes created | **YES** | Both. R2-M1 was created by the R1-M1 gate; R2-M2 was created by the R1-m6 insertion. |

**One of three fires → no cap.** But I flag the shape precisely, because it is the useful signal: **both** new Majors are the *documentation shadow* of otherwise-correct code fixes. The code work this round is strong — the fixes are right, the tests are non-vacuous, the screenshot audit went past the finding and self-corrected. What did not keep pace is the same-commit currency of the contract document those fixes touch. **Recommendation for the round-3 brief:** name `docs/contracts/state-ledger.md` explicitly — both its rows and every citation *into* it — as a required check, and fix R2-M2 with the symbol form rather than a new line number, which converts a thrice-recurring defect into a permanently closed one.

---

## CONSTITUTION CHECK

- **Law 1 (no confident falsehood)** — **The two round-1 Law 1 Majors are CLOSED**, both re-derived in a real browser: never-polled no longer claims last-good; tickets-without-heartbeat is now a named FLAG rather than a silent contradiction. **Violated at the document tier by R2-M1**: `state-ledger.md` asserts behaviour the code no longer has.
- **Law 4 (nothing lost silently)** — ✅ Honored and strengthened. The new condition *raises* the inconsistency instead of dropping it; faults still reach `_faults.log`; the corrected adapter header states the real partial-write behaviour rather than re-asserting a false guarantee.
- **Law 6 (one owner)** — ✅ Honored, and worth crediting: `poll.go:381` resolves the new condition's register via `store.RegisterForCode("freight-tickets-without-heartbeat")` — the ONE owned code→tier mapping in `condition_severity.go:89-96` — rather than hardcoding `TierFlag` at the raise site. `buildRecordLink` consumes the wire's own `recordDir`, never re-derived. Seal still `Get-Sha256Hex`; no second latest-wins rule.
- **Law 7 (vocabularies as DATA)** — ✅ Honored. The wire schema declares condition `code` as an open `{"type": "string"}` with no enum (`yard-snapshot.schema.json:81`), and no document anywhere enumerates condition codes — so a new code needs neither a schema change nor a doc update. Verified by search, not assumed.

**CITATION CHECK (#42)** — All new code blocks cite `#84` plus their finding ID (`poll.go:365-376`/`:390-399`, `condition_severity.go:89-96`, `dom-writer.js:588-604`, `StoreIntegrity.Tests.ps1` Context). No new code files this round, so `CodeCitationPolicy` is unaffected and green. Both new `.md` files carry `Status: Current` (DocPolicy green). `d4458775d…` verified as the commit that added `first-light.png`. **One citation fails: `poll.go:123` → R2-M2.**

**DOC CHECK** — `setup.md` ✅ (command sentence-checked to the param block); 5 screenshot READMEs ✅ (all 11 images opened; captions state what was validated, at which commit, and the divergence; no recapture); `Sync-Freight.ps1` header ✅ (matches measured behaviour); `snapshot.go` comment ✅ (cited sentence verbatim). `state-ledger.md` ❌ **(R2-M1)**.

---

## NOTES

- **N1 — the node instruments do *not* agree at 238, and the honest numbers are worth pinning.** Measured: per-file sum of `test/*.test.js` = **238**; `node --test` TAP trailer = **240**. The gap is exactly the two non-test `.js` files node counts as files (`test/minidom.js`, `test/support/real-board-server.js`) — the identical +2 I measured in round 1 (234/236). **The commit message is correct and consistently instrumented** ("238/238 real tests"), so R1-m2 is genuinely fixed in the landed artifact; I am not filing a finding against a paraphrase I did not see. But **CI runs bare `node --test` (`ci.yml:374`) and will print `# tests 240`**, so a future brief expecting 238 from CI will mis-trip.
- **N2 — the full-suite browser flake is PRE-EXISTING (#81) and NOT this car's.** I chased it rather than attributing it. At `baf109e` a full-suite run failed 2 `browser-conditions-persistence` tests; isolated, that file is **5/5 green**. At round-1 HEAD `bc552df` the same full-suite flake fires on *different* victims run to run (`browser-register-cascade`, the css-load test, and `#84 Case 1`) — 3 of 9 runs. The round-2 fixture provably cannot trigger the new condition (`buildScratchStoreUnderRepoRootWithConditionsAndSuperseded` writes no `ticket`/`ticket-sync` kinds). Same #81 class, different victim.
- **N3 — my own first R1-m3 probe was the mis-instrument, not the code.** It put the scratch store in `%TEMP%`, and `githubArtifactsPrefix` (`board/server/githublinks.go:37-49`) returns `""` for any store outside the repo root — documented honest-degrade. I corrected the probe rather than filing a false finding; the re-run under the repo root rendered both links.
- **N4 — a small adjacency trip hazard in `view-28-12-candidates/README.md`.** The pre-existing sentence *"`health-trend-and-provenance.png` is unaffected (see above) and carries no such note"* (`:61-62`) sits immediately above the new #84 note that **does** cover that image. "such" scopes it to the #75 task-id axis, so the document is correct on a full read. A two-word edit ("no such **#75** note") would remove the hazard. Not a finding.
- **N5 — process credit.** The round-2 work exhibits three behaviours this shop codes as success outcomes: a self-disclosed process mistake in the commit message, a caption self-corrected after an image disproved the author's own draft, and an audit deliberately widened past the finding (5 directories, not 3). None of that is diminished by the two Majors.

---

## BASE-DELTA (#13)

- **Round-1 reviewed HEAD:** `bc552dfc6f1d96575ac7646af119daabc408a599`
- **This commit:** `baf109e8c29130771dee0030ed6010f3b06049e0`
- `git diff bc552df..baf109e --stat` → **18 files, +669 / −34**
- No `board/fold` path present (off-contract fence still honored). 2 new files, both `.md`, both `Status: Current`.

**Unreproducible-evidence callout (#13):** none in my verdict. Every claim is re-derivable — suites by direct invocation at `baf109e`; browser observations from probe files whose fixture shapes are stated inline; the real partial-failure store produced by placing a **file** where `ticket-90`'s directory must go (no code injection); the non-vacuity proof by relocating `Write-TicketSyncHeartbeat` above the write loop. Injection restores verified byte-identical two ways (sha256 `2e5272a4845e976b85958d4d255ea06a574740d4d136eb91212da0bfb077b714`, and `git diff` empty against a scratch baseline), each as its **own separate call**. All work occurred in an out-of-repo `git archive` copy; the worktree and the shared checkout were both clean at entry and exit. The one item I could not reproduce byte-for-byte is the car's timestamped `17:35:48Z` observation, corroborated by class in both directions instead.

**What would clear this:** R2-M1 (true `state-ledger.md:115`, `:116`, and the `:136-139` "IDENTICAL in shape" paragraph to state the `never-polled` gate) and R2-M2 (re-point `poll.go:123` **by symbol**, per the lesson `lanes.js:16-21` already carries). Both are documentation edits to files this commit already touches; no code change is implied, and nothing I verified this round needs redoing.

```starcar-artifact
task-id: adapter-84-review-r2
outcome: REJECT
findings: 2 Major, 0 minor, 5 notes. All ten round-1 IDs (R1-M1..M4, R1-m1..m6) are PRESENT and genuinely folded - none Absent, none DRIFTED - and I re-derived every one at baf109e rather than trusting the report. R2-M1 MAJOR - the R1-M1 fix made lastGoodAsOf and lastGoodLaneData conditional for freight (poll.go:400 and poll.go:446, gated on freightFreshnessVal.Kind not equal to never-polled) but docs/contracts/state-ledger.md was not trued in the same commit: line 115 still reads "UPDATED (both keys, same poll's now)", line 116 still reads "UPDATED per live lane ID (dispatches/gates/trains/freight)", and the Question-1 amendment at lines 136-139 affirmatively states lifecycle behaviour is "IDENTICAL in shape" to the live key "so no new lifecycle column values were needed" - which is now precisely backwards, since that divergence IS the fix. grep for never-polled in the ledger returns only the unrelated lastGoodSnapshot row. CLAUDE.md Living contracts says reviewers reject state-touching diffs that leave the ledger stale. R2-M2 MAJOR - board/server/poll.go:123 cites docs/contracts/state-ledger.md:108 for the lastGoodLaneData row; that citation was TRUE at bc552df and this commit's own 8-line R1-m6 insertion shifted the row to :116, so :108 now lands on the table HEADER. This is the SECOND drift of this same citation (its own text records "corrected from :102" under #52 C51R-4), the #65 resolver cannot catch it because the line still exists (in-range shift), and board/web/js/lanes.js:16-21 - a comment this car edited for R1-m1 - describes this exact failure mode verbatim. Fix by symbol, not by a new line number. Verified fixed and re-derived myself: R1-M1 in 4 real-browser cases including the no-over-correction edges (never-polled now reads "no good data has ever been read"; genuinely-good, heartbeat-lost-after-good, and stale all correctly retain last-good); R1-M2 via a REAL public-interface adapter failure (a file blocking the second ticket directory) rendering "1 FLAG freight-tickets-without-heartbeat" on the strip, plus coverage of the quarantined (S5) and future-dated (S8) heartbeat states because the condition gates on never-polled rather than literal absence, with both negative controls silent; R1-M3 by opening all 11 images myself and confirming the 6-of-8 scoping is exact in BOTH directions (the two r3 crops genuinely stop at TRAINS), the first-light commit d4458775d verified as the commit that added that file, and the health-trend self-correction confirmed real; R1-M4 by proving the new test non-vacuous - relocating the heartbeat write above the loop produced exactly 1 red with the expected message. Minors all verified: m1 cited sentence preserved verbatim, m2 commit message uses one labelled instrument, m3 two links measured in a real browser with honest degrade, m4 setup.md command sentence-checked against the param block, m5 ticket Context mirrors the manifest one, m6 the "no producer regenerates index.md" claim verified true (the Produce-Artifact hit is a comment at :333, not an invocation - suspicion disproved). Suites at baf109e: Go 111/111 PASS 0 FAIL, vet exit 0, go fmt rewrote nothing; node 238 real tests / 240 trailer, all passing; Pester scripts/tests 240 total 235 pass 0 fail 5 skip with the 5th being exactly the detached-HEAD skip so the car's 236/4 is correct; probes 29/29; store-checks 275/275; both named browser suites isolated 5/5 and 3/3. CONVERGENCE ruled: 4M/6m to 2M/0m, only ONE of three swirl triggers fires (both new Majors are defects the round-1 fixes created), counts are declining and the cluster MOVED from poll.go and screenshots to state-ledger.md, so NO CAP is warranted - but both Majors are the documentation shadow of otherwise-correct code fixes, so round 3 should name state-ledger.md and every citation into it explicitly. Stale-backup window ruled: nothing in the final commit rests on evidence from it, established by my own re-derivation at the final SHA rather than by the car's assurance. Notes: the full-suite browser flake is pre-existing #81 (measured at BOTH SHAs, hitting different victims run to run, isolated file 5/5 green) and is NOT attributed to this car; the node trailer is 240 not 238 and CI prints the trailer; and my own first m3 probe was a mis-instrument I corrected rather than filing as a false finding.
abstract: Delta review round 2 of baf109e over round-1 HEAD bc552df for issue #84, the store-mediated freight ticket adapter. REJECT on 2 Majors, both documentation-currency defects created by this round's own fixes. All ten round-1 findings are genuinely folded and independently re-derived: the two Law 1 Majors are closed in a real browser, the never-polled gate holds without over-correcting, the new board condition fires on the real partial-adapter-failure store and on both quarantine edges I found in round 1, the screenshot audit is accurate in both directions across all eleven images I opened, and the corrected adapter header is pinned by a genuinely non-vacuous test. What did not keep pace is the contract document those fixes touch: the state ledger still describes the unconditional lastGoodAsOf write the R1-M1 gate removed, and this commit's own ledger insertion silently shifted a poll.go line citation onto the table header for the third time in that citation's history. Convergence is healthy - four Majors to two, cluster moved, one of three swirl triggers - so no cap; both remaining fixes are documentation edits to files the commit already touches.
```