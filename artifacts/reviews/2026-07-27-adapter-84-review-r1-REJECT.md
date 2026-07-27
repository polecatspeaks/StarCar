<!-- starcar-integrity: sha256=cb8eee024e697b6e8633de1fc28a45259d3147dcfafeb9232a3bf99bfe48cb25 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Freight lane #84 store-mediated ticket adapter, review round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review
Round: 1
Target: `car/adapter-84 HEAD bc552df`
Base reviewed: `51fb403b635a90b8e3d5b38092641b058dfd1a5f`
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
> Path normalisation: the repository root was rewritten to ``<repo>`` and the operator home directory to ``~``, BEFORE hashing. Mechanical and narrow: only those two roots, longest-first, no other substitution. This is portability, not curation - findings, verdicts and counts are untouched, and the un-normalised original is on the Entire checkpoint branch.

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `51fb403b635a90b8e3d5b38092641b058dfd1a5f` |
| Entire checkpoint | `2aeffe52d4c4` |
| Dispatch, the locator within the session | `af9695467e625f504` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 51fb403b635a90b8e3d5b38092641b058dfd1a5f
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

I have everything I need.

# VERDICT: REJECT

**4 Major, 6 minor, 5 notes.** Base verified `bc552dfc6f1d96575ac7646af119daabc408a599`, detached, clean tree, before any read. Both checkouts clean at exit; all fault injections were performed on an out-of-repo `git archive` copy and restored sha256-identical.

The car's headline claim is **true and I re-derived it**: the three named freight states render distinctly in a real browser. The rejection is not about those three. It is about the **fourth and fifth states the enumeration never reached**, both of which put a confident falsehood on the exact surface this ticket named as the review's sharpest target.

---

## Suites — run myself at `bc552df`

| Suite | Car claimed | I observed | Verdict |
|---|---|---|---|
| Go `board` | 108/108 (base 98) | **108 PASS / 0 FAIL**; base **98** | ✅ exact |
| `go vet ./...` | clean | **exit 0** | ✅ |
| Pester `scripts/tests` | 235/239, 4 skip | **234 pass / 0 fail / 5 skip of 239** | ✅ (see skip delta) |
| `scripts/probes` | 29/29 | **29/29** (#79 ManifestBoardJoin green) | ✅ |
| `scripts/store-checks` | 271/271 | **271/271** | ✅ |
| `browser-dispatch-row-geometry` standalone | — | **3/3**, no density regression | ✅ |
| `board/web` node | 234/234 (base 225) | **236 tests / 236 pass** trailer; **234** real tests | ⚠️ R1-m2 |

**Detached-HEAD skip delta (named as required):** my 5th skip is `run-session-start-guards.sh … [ci-baseline] marker ONLY when attached to a branch`, reason verbatim *"is skipped, because detached HEAD (no branch)"*. On an attached branch this runs and passes → 235/4. **The car's count is correct; my delta is exactly this one skip.**

---

## MAJOR FINDINGS

### R1-M1 — A freight lane that has NEVER run claims "showing last good" after a scan failure (Law 1)

`board/server/poll.go:365-367` sets `s.lastGoodAsOf["freight"] = newLastGood` on **every** successful scan, and `:398-402` sets `s.lastGoodLaneData["freight"] = assembled.Freight` unconditionally — regardless of whether a `ticket-sync` heartbeat exists. `:330-334` then serves that as the `failed` variant's `LastGoodAsOf`.

**Measured, real browser, real Go binary** (probe: empty scratch store → poll → `renameSync` the store away):

```
BEFORE store loss: freightSecondary = "not yet polled"          register-in-progress
AFTER  store loss: freightSecondary = "source failed (...) - showing last good from 2026-07-27T17:10:36Z"
                   freightBody      = "no tickets in the queue"  register-needs-attention
```

One poll earlier the board itself said the adapter had never run. It now asserts it is showing the last good freight queue, and that it was empty. This is precisely the collapse the issue forbids: *"An empty lane that silently means 'we do not know' is the confident-falsehood class this board exists to prevent."*

The reuse is unexamined and the comment above it proves the car knew the distinction mattered — `poll.go:304-314` argues `freightFreshnessVal` is "DELIBERATELY a separate value… never a reuse", while the `lastGood` bookkeeping 50 lines below **is** a reuse of a lane whose definition of "good" the car deliberately made different. For dispatches/gates/trains a successful scan genuinely *is* good data (DR3-5a honest-empty); for freight it explicitly is not.

`TestPollOnceFreightRetainsLastGoodOnScanFailure` (`poll_test.go:203-233`) cannot catch this — its poll-1 store seeds a heartbeat at `:205`, so it only exercises the case where freight really did have good data.

### R1-M2 — Heartbeat absent + tickets present renders "not yet polled" beside the tickets, reachable by a real adapter failure

`computeFreightFreshness` returns `never-polled` at `poll.go:547-549` purely on heartbeat absence, while `assemble.go:235` populates `Freight.Tickets` from any `kind=ticket` records regardless. Nothing reconciles the two.

**I injected a mid-run failure into the real adapter** (`throw` before the 2nd of 2 ticket writes), ran the real `Sync-Freight.ps1`, and rendered the resulting store in a real browser. Verbatim lane text:

```
4 Freight  the inbound ticket queue  Live  not yet polled  #84 first ticket Backlog
```

The secondary line says the adapter has never run; the body shows a ticket only the adapter could have written. No board condition fires. This is a HAVAGLANCE failure — a single glance transmits two contradictory facts.

This is **not hypothetical**: it is the direct consequence of the car's own heartbeat-written-LAST ordering (`Sync-Freight.ps1:184-185`). It also arises whenever the heartbeat is quarantined while tickets survive — I measured that too (malformed `at` → `record-quarantined`, freight reads `"not yet polled"` with ticket #84 rendered).

My full state-space sweep (11 states, real browser, real binary):

| State | secondary | register | body |
|---|---|---|---|
| S1 never run | `not yet polled` | in-progress | no tickets ✅ |
| S2 ran, empty | `fresh` | nominal | no tickets ✅ |
| S3 stale | `stale, 57593:08:45` | needs-attention | 1 row ✅ |
| **S4 tickets, no heartbeat** | **`not yet polled`** | in-progress | **2 rows** ❌ |
| **S5 malformed heartbeat** | **`not yet polled`** | in-progress | **1 row** ❌ (condition raised) |
| S6 old beat / new tickets | `stale, …` | needs-attention | 1 row ✅ |
| S7 new beat / old tickets | `fresh` | nominal | 1 row ✅ |
| S8 future heartbeat | `not yet polled` | in-progress | empty (2 FLAGS raised) ✅ |
| S9 malformed ticket payload | `fresh` | nominal | empty (quarantined) ✅ |
| S10 store unreadable | `source failed …` | needs-attention | no-renderer ✅ |
| S11 two heartbeats | `fresh` | nominal | latest-wins ✅ |

### R1-M3 — Committed screenshots depict the rendering this diff replaces; the obligation is named, MAJOR-tier, and was not performed

`docs/templates/car-brief.md:124-131` is explicit: *"whenever the diff changes what the board RENDERS, open `docs/screenshots/` — not the enumeration the car reports, the directory itself — and rule on whether any committed image depicts the rendering this diff replaces… An affirmative 'documentation is clear' claim that never opened this directory is itself the finding."* `:122-123` sets the tier: *"A stale document or a dead citation is a MAJOR finding."*

I opened the directory and the images:

- `docs/screenshots/2026-07-23-first-light.png` renders `FREIGHT / Dark / no equipment on this lane`. It is a **bare file with no README at all** — nothing states what it validated or at which commit.
- `docs/screenshots/2026-07-26-register-check-candidates/calm-yard.png` renders `4 FREIGHT / the inbound ticket queue / Dark / no equipment on this lane`, under a README whose line 3 reads **`Status: Current`** and which describes it as *"the nominal register across all five lanes"*.
- `docs/screenshots/2026-07-26-view-28-12-candidates/` carries the same ambient-store `calm-yard.png`/`hot-yard.png` pair under its own **`Status: Current`**.

No screenshot README was touched by this commit and the commit message never mentions screenshots. The remedy the template prescribes is not recapture — it is a README stating the divergence. Note the repo has already paid for this twice (`#69/#71` round 2, `#75` round 1), which is why the clause exists.

### R1-M4 — `Sync-Freight.ps1`'s documented failure contract is measurably false (Law 1)

`scripts/Sync-Freight.ps1:35-38`:

&gt; *"a failed run (the gh call throws, a write fails) writes NOTHING - not even a 'we tried and failed' record - and exits nonzero."*

**Measured false.** Ticket files are written one at a time via `[System.IO.File]::WriteAllText` at `:112` inside the loop at `:170-173`, and departed directories are deleted at `:181` — all before the heartbeat at `:185`. My injected mid-run failure left:

```
\_faults.log
\ticket-84\ticket.json      &lt;- written by a run that "writes NOTHING"
EXIT=1
```

This matters beyond the sentence: it is the **load-bearing premise of Adjudication 1**. The failure posture was accepted on the grounds that a failed run leaves the store untouched, so failure shows up purely as staleness. It does not — it leaves partial state plus a stale-or-absent heartbeat, which is R1-M2.

---

## MINOR FINDINGS

- **R1-m1** — `board/server/snapshot.go:45-46`: *"Data is omitted entirely for lanes with no adapter (freight/fuel, dark/bagged)"*. False for freight now. This is the **exact comment `board/web/js/lanes.js:15-24` cites by symbol** as its authority; the car updated the citing comment and left the cited one stale. (CLAUDE.md's NORTH STAR names "code comment" in scope explicitly.)
- **R1-m2** — Node count claim mixes instruments. Measured: HEAD **234** real tests (per-file sum) / **236** `# tests` trailer; base **223** / **225**. The car's pair "234 (was 225)" mixes the two and implies **+9** when the true delta is **+11**. Both numbers are individually real; the delta is not derivable.
- **R1-m3** — `render.js:441` maps `recordDir` into the freight view-model; `dom-writer.js:601-615` `renderFreight` never uses it (confirmed: no `recordDir` reference in that function). The wire schema at `schema/yard-snapshot.schema.json:197-200` advertises it as "#28 clickable provenance" — aspirational for freight only.
- **R1-m4** — **Nothing invokes `Sync-Freight.ps1`.** Repo-wide grep finds only comments and its own test. "Periodic BATCH sync" is asserted at `:10` and "external periodic script" at `poll.go:502`, but no hook, CI job, scheduler, or operator instruction landed, and neither `docs/setup.md` nor `README.md` gained a row. Issue design-question 4 ("How the adapter runs") is answered in prose only. Consequence: the public board's freight lane will render amber `not yet polled` indefinitely.
- **R1-m5** — pwsh/Go store-validation asymmetry. `board/store/store.go:302` validates every record against the ticket layer, but `scripts/store-checks/StoreIntegrity.Tests.ps1` gained no ticket Context although the manifest layer has one (its `train:` manifest Context). YB-1's "validators run BOTH schemas" is honored in Go only.
- **R1-m6** — The adapter commits into `artifacts/` (`:205-215`) without regenerating `artifacts/index.md`, adding a recurring index-staleness source. Within #20's declared contract (dev may lag; gated at PR-to-main) but undocumented.

---

## THE THREE ADJUDICATIONS, RULED

### Adjudication 1 — failure posture: **the DESIGN is sound; the IMPLEMENTATION does not honor it**

"Stale" *is* an honest rendering of "failing for six hours" for this lane. It is literally true (the last success was N hours ago) and asserts nothing about health. The rejected alternative has a genuine flaw the car identified correctly: a "tried and failed" record carries its own `at` and becomes a second freshness axis that can itself go stale — two records answering one question (Law 6). Law 4 is satisfied: the fault reaches `_faults.log` (`:78-88`) and **is read** — `.claude/skills/goodnight/SKILL.md:90` reads `artifacts/_faults.log` at session close. It is not a decorative guard.

**I do not require a failure record.** But the posture was justified by "a failed run writes NOTHING", which is false (R1-M4), and its falsity produces the contradictory render (R1-M2). Fix the premise (write to a temp tree and swap, or have the board detect tickets-without-heartbeat and say so), not the posture.

### Adjudication 2 — record shape: **CORRECT, and I endorse it. Not silent loss.**

The premise in the question — that the store *loses* history — is **false at the repository level**, and I checked rather than assumed. Every overwrite and every deletion is committed (`git commit --only -- &lt;paths&gt;`, `:205-215`); `git log --follow artifacts/ticket-84/ticket.json` retains every state, and the Entire checkpoint branch mirrors it. Git is the append-only substrate; the working tree is a materialized current-state view.

- **Law 4:** the removal is a committed, message-bearing change, not a silent drop. A ticket leaving Backlog/Todo has *moved to In Progress*, where the trains lane shows it — the information relocates, it does not vanish.
- **Law 6:** the reasoning is verified, not just plausible. `assemble_test.go:960` asserts the *real* fold produces zero dispatches/intents for a ticket-only store, and fails loudly if that ever changes. An event-log shape would therefore force `board/assemble` to reimplement latest-wins. Fixed filename is the right call.
- **`StoreIntegrity`:** re-globs each run; removed files are simply not cases. Ticket records validate and their integrity recomputes — the seal reuses `Artifact.psm1`'s `Get-Sha256Hex` (`:103`) over the same `-Compress` canonical body as `Produce-Artifact.ps1:364-365`, and `StoreIntegrity`'s re-derivation is field-order-agnostic.
- **`New-ArtifactIndex`:** generic over `subject/kind/at/outcome`; ticket records index cleanly, removed ones drop out — consistent with its own "records are the source of truth" header.

Only R1-m6 (index cadence) attaches here.

### Adjudication 3 — the pre-landing probe: **CONFIRMED REAL, re-derived end to end**

Built the **base** binary (base `kinds.json` has no `ticket`; base `store.go` has 0 `json:"ticket"` keys), served a `kind:ticket` record:

```
STEP 1  [needs-attention] record-unrecognised-fields :: ticket-84/ticket.json: record carries 1 unrecognised field(s): ticket
        [nominal]         discovery                 :: kind: ticket
```

Then edited **only** `kinds.json` (sha256 `1BC354E6…` → `29E4213F…`; `store.go` still 0 ticket keys) and restarted:

```
STEP 2  [needs-attention] record-unrecognised-fields :: ticket-84/ticket.json: record carries 1 unrecognised field(s): ticket
```

The `discovery` disappeared; the unrecognised-field condition persisted. That is genuinely *"I watched the vocabulary entry do its job."* The claim holds.

---

## FAULT INJECTIONS

| # | Injection | Result |
|---|---|---|
| **INJ-A** (car's) | Remove `Ticket json.RawMessage` from `typedRecord` (`store.go:148`) | ✅ RED — `TestScanTicketRecordSurvivesAndIsNotFlaggedUnknown`: *"got {record-unrecognised-fields … 1 unrecognised field(s): ticket}"* |
| **INJ-B** (car's) | `computeFreightFreshness` never-polled → `fresh` (`poll.go:547-549`) | ✅ RED **through a real browser** — Case 1 times out waiting for `not yet polled` (2 pass / 1 fail). #40 satisfied. |
| **INJ-C** (new, brief-requested) | Break Backlog+Todo filter → not-Done blocklist (`Board.psm1:116`) | ✅ RED — *"includes ONLY Backlog and Todo… Expected 2, but got 4."* Isolated cleanly: **exactly 1 added red** over a 9-failure scratchpad-environment baseline. |
| **INJ-D** (new, brief-requested) | Couple freight to `liveFreshnessVal` (`poll.go:362`) | ✅ RED ×2 — `…NeverPolledOnEmptyStore` (*"= "fresh", want never-polled"*) and `…StaleWhenTicketSyncOld` (*"= "idle", want stale"*). **Independence is genuinely guarded.** |
| **INJ-E** (mine) | `throw` mid-write-loop in the real adapter | ✅ Produced R1-M2/M4 evidence |

All restores sha256-verified: `poll.go ea50482f…`, `store.go 6816ec93…`, `Board.psm1 32b0a75e…`, `Sync-Freight.ps1 caa14488…`.

---

## THE WIRE SENTENCE — a ticket, hop by hop

1. **GitHub → adapter.** `scripts/Sync-Freight.ps1:143` `gh project item-list $ProjectNumber --owner $Owner --format json --limit 500`, exit checked `:144`.
2. **Filter.** `:148` → `scripts/Board.psm1:99-124` `Get-BoardQueueItems`: `:113` `if ($status -ne 'Backlog' -and $status -ne 'Todo') { continue }` — allowlist, missing status excluded. Guarded (INJ-C).
3. **Subject mint + traversal guard.** `:154-160`, `$subject = "ticket-$($item.Number)"`, re-checked `^ticket-\d+$`.
4. **Write + seal.** `:89-115` `Write-TicketRecord` — `record['ticket']` at `:97`, seal `:103` via `Artifact.psm1`'s `Get-Sha256Hex` (Law 6), UTF-8 no-BOM to `ticket-&lt;n&gt;/ticket.json` `:109-113`.
5. **Heartbeat LAST.** `:185` `Write-TicketSyncHeartbeat` → `ticket-sync/ticket-sync.json`. **This is the R1-M2/M4 window.**
6. **Commit.** `:205-215` `git commit --only -- &lt;relPaths&gt;` (never `-a`).
7. **Store scan.** `board/store/store.go:148` `Ticket json.RawMessage \`json:"ticket"\`` joins `typedRecord` → `ticket` leaves the unknown-field set (proven by INJ-A). `:302` layers `ticketSchema.Validate`.
8. **Assemble.** `board/assemble/assemble.go:235` `result.Freight.Tickets = freightTickets(...)` → `:251-278`, read **raw**, sorted ascending by number, `RecordDir` from `recordDirs[subject]`. Never through fold.
9. **Wire.** `board/server/poll.go:398-402` `case "freight":` → `lane.Data = assembled.Freight`; freshness from `:362` `computeFreightFreshness`. Schema `schema/yard-snapshot.schema.json:185-208` `$defs.freightPayload`.
10. **Client capability axis.** `board/web/js/lanes.js:35` `EXPECTED_DATA_KEY = {… freight: 'tickets'}`; `:30` freight left `NO_DATA_BY_DESIGN`.
11. **View model.** `board/web/js/render.js:430-447` `case 'freight':` → `{kind:'freight', tickets}`.
12. **DOM.** `board/web/js/dom-writer.js:408` → `:601-615` `renderFreight`; `#N`, title→`t.url`, status VERBATIM.

**Boundary verdict:** the sentence is intact for a well-formed record. The break is at hop 5↔9 — freshness and body are read from **different records with no consistency check**, which is R1-M2.

**Board makes no outbound call — verified, not assumed.** `grep` across `board/server/*.go`, `board/assemble/*.go`, `board/store/*.go` (non-test) for `http.Get|http.Post|api.github|exec.Command|os/exec` returns **nothing**; `net/http` appears only at `handlers.go:4` and `main.go:12`, both for *serving*. Settled architecture honored.

**`board/fold` untouched — verified.** `git diff 51fb403..bc552df --name-only` contains no `board/fold` path. No honest-stop was owed.

---

## CONSTITUTION CHECK

- **Law 1 (no confident falsehood)** — ❌ **VIOLATED twice.** R1-M1 (`showing last good` for a lane that never ran) and R1-M2 (`not yet polled` beside rendered tickets). Also R1-M4 (a false claim in the adapter's own contract).
- **Law 4 (nothing lost silently)** — ✅ **Honored.** Delete-on-departure is committed, not silent; faults reach `_faults.log` and are read at `goodnight/SKILL.md:90`; quarantine conditions fire for malformed/future-dated heartbeats (measured, S5/S8).
- **Law 6 (one owner)** — ✅ **Honored.** Seal reuses `Get-Sha256Hex` (`Sync-Freight.ps1:70,103`), never a second hashing rule. **No second latest-wins rule**: `computeFreightFreshness`'s max-by-`at` (`poll.go:542-545`) is the identical recency idiom `computeLiveFreshness` already uses (`poll.go:473-483`) for "newest observed record" — it is not fold's supersession/winner authority, and the fold has no `ticket` case at all (`assemble_test.go:960` asserts this non-vacuously). `recordDirs` single-sourced from `store.Record.Path`.
- **Law 7 (vocabularies as DATA)** — ✅ **Honored, and the second kind is JUSTIFIED, not a dodge.** I tested the premise rather than assuming it. `ticket-sync` answers a categorically different question ("did a run complete") from `ticket` ("what is queued"), and it is *necessary*: an empty store cannot otherwise prove a run happened, which is the ticket's central Law 1 requirement. Folding it into `kind=ticket` would require a sentinel subject to exclude it from `freightTickets`' `kind=="ticket"` switch (`assemble.go:252`) — the exact overloading the owner rejected for intent-vs-ticket. Both values are DATA in `schema/vocab/kinds.json`; `kind` carries no schema enum; an unrecognised kind renders a nominal `discovery` (measured, Adjudication 3).
- **Law 2 / D11** — ✅ registry-driven position flip; `TestLaneRegistryPin` still pins all five lanes.

---

## RULINGS ON THE CAR'S DISCLOSED LIMITATIONS

- **(a) `index-format.md` field order — NOT a Major.** I disproved the framing. First, the path is wrong: `docs/index-format.md` **does not exist**; the file is `schema/index-format.md` (dead citation in the report → folded into R1-m2's class, not its own finding). Second, the underlying gap is **pre-existing and systemic, not #84's**: `manifest` is *also* absent from the canonical order and extras list, and the #38 gate (`scripts/tests/Schema.Tests.ps1:55-91`) reads only `$script:Schema = schema/starcar-artifact.schema.json` (`:5`), so **no layered-schema payload key has ever reached that document**. The car followed the manifest precedent verbatim, including its gap. Recommend a separate issue for layered-schema keys vs. canonical order.
- **(b) dead `case 'dark':` — NOT a Major.** Confirmed: `grep "kind: 'dark'"` in `render.js` returns nothing, so the branch is unreachable via any registered lane. Leaving it uncovered and disclosed (`dom-writer.test.js:1156-1160`) is the *correct* posture and matches this repo's own landed precedent for defence-in-depth branches (`render.js`'s `isTrainTerminal` round-3 note). `dark` is still a live position in `vocab.positions`; faking a test would have been the defect.
- **(c) no GitNexus — NOT a Major.** I performed the blast-radius work the tool would have: full call-path trace (the wire sentence above), four fault injections, and full-suite re-runs. Nothing was left unverified for want of the tool.

---

## NOTES (not findings — recorded so they are not re-litigated)

- **N1 — the browser flake is PRE-EXISTING and already tracked (#81).** I hit it and chased it rather than attributing it. `browser-freight-states` Case 1 failed 2 of 6 full-suite runs with `bind: Only one usage of each socket address … 127.0.0.1:4744`. Root cause is `real-board-server.js:691` `4700 + (process.pid % 200)` — **base code**, and **base flakes at the same rate (2 of 6)**. Solo runs of the new file: **6/6 green**. Issue **#81** names this exactly. Not attributable to this car. Flagged so a red on this file is triaged as #81, not #84.
- **N2** — The `store-unreadable` freshness detail leaks the raw absolute store path into the rendered secondary line (measured: `~\AppData\Local\Temp\...`). **Pre-existing** — identical code path for the live lanes at base (`poll.go:325-329`) — now widened to a 4th lane. Given this repo's own path-normalisation scar, worth a ticket.
- **N3** — `board/web/test/fixtures/real-snapshot.json` still carries `freight … "position":"dark"`. Legitimate as a historical capture, not stale-by-this-diff.
- **N4** — `docs/doc-map.md:71`'s trigger-gated *"adapter-authoring guide — trigger: the second adapter"*: I considered calling this a fired trigger and **decided against it**. "Adapter" is undefined in the glossary (already recorded as GL-4), and the harness already ships Claude/Copilot payload adapters, so the trigger's referent is genuinely ambiguous and arguably fired before #84. Raising it as a Major would be manufacturing a finding. Conductor's call.
- **N5** — Credit where due: `poll.go:123`'s `docs/contracts/state-ledger.md:108` citation **still resolves correctly** — I opened line 108 and it is the `lastGoodLaneData[laneID]` row. The car edited that row in place and kept the coordinate true. The `#42` citation check passes: all 4 new files carry `#84` (6/2/7/1 occurrences).

---

## BASE-DELTA (#13)

- **Base:** `51fb403b635a90b8e3d5b38092641b058dfd1a5f`
- **Head:** `bc552dfc6f1d96575ac7646af119daabc408a599`
- `git diff 51fb403..bc552df --stat` → **28 files, +1648 / −90**
- No `board/fold` path present. 4 files added, all `#84`-cited.

**Unreproducible-evidence callout (#13):** none. Every claim above is re-derivable — Go/Pester/node suites by direct invocation at `bc552df`; browser observations via probe files reproduced from the recipes stated inline (scratch store shapes + `startRealBoardServer({storePath})`); Adjudication 3 via `git archive 51fb403` + a single `kinds.json` edit with both sha256s printed; the adapter failure via a one-line `throw` in the write loop. All injections were out-of-repo and restored sha256-identical. The only artifacts not preserved are the temp scratch stores, whose contents are fully specified above.

**What would clear this:** R1-M1 (gate `lastGood*["freight"]` on heartbeat presence), R1-M2 (raise a board condition when `kind=ticket` records exist with no heartbeat — a red-first test in `poll_test.go` plus a browser case), R1-M3 (screenshot README stating the divergence, per `car-brief.md:128-131` — never recapture), R1-M4 (correct the header to describe actual partial-write behavior, or make the write atomic). The three-state proof, the record shape, the probe, and the architecture all stand.

```starcar-artifact
task-id: adapter-84-review-r1
outcome: REJECT
findings: 4 Major, 6 minor, 5 notes. R1-M1 Law 1 - poll.go:365-367,398-402 set lastGoodAsOf/lastGoodLaneData for freight unconditionally, so a NEVER-POLLED freight lane renders "source failed ... showing last good from 2026-07-27T17:10:36Z" after a scan failure; measured in a real browser; poll_test.go:203-233 cannot catch it because its fixture seeds a heartbeat. R1-M2 Law 1 - heartbeat absent while kind=ticket records exist renders "not yet polled" BESIDE rendered ticket rows, verbatim "Live not yet polled #84 first ticket Backlog"; reproduced by injecting a mid-run failure into the real Sync-Freight.ps1 and rendering the resulting store; no condition fires; also occurs when the heartbeat is quarantined. R1-M3 - committed screenshots depict the replaced rendering: first-light.png shows FREIGHT/Dark/no equipment on this lane with NO README at all, and register-check-candidates/calm-yard.png plus view-28-12-candidates images show the same under READMEs asserting "Status: Current"; car-brief.md:124-131 makes this a named MAJOR-tier obligation that was not performed. R1-M4 - Sync-Freight.ps1:35-38 claims "a failed run writes NOTHING"; measured false, a failed run left ticket-84/ticket.json plus _faults.log, exit 1; this false premise is what justified the accepted failure posture. Minors: snapshot.go:45-46 Lane doc comment stale and cited by symbol from lanes.js:15-24; node count claim mixes instruments (234 vs 225 implies +9, true delta +11); recordDir carried into the freight view model at render.js:441 but never rendered by dom-writer.js:601-615; nothing anywhere invokes Sync-Freight.ps1 so "periodic" is asserted with no scheduling and no operator doc; StoreIntegrity.Tests.ps1 gained no ticket-schema layer although the manifest layer has one; adapter commits into artifacts/ without regenerating index.md. Adjudication 1 - failure posture DESIGN is sound and I do not require a failure record (staleness is literally true, the rejected alternative is a real Law 6 second-axis risk, and faults reach _faults.log which goodnight/SKILL.md:90 reads), but it was justified on a premise the code does not honor. Adjudication 2 - record shape CORRECT and endorsed; the premise that the store loses history is FALSE at repository level because every overwrite and deletion is committed, git is the append-only substrate; not silent loss; no bad interaction with StoreIntegrity, New-ArtifactIndex, or the checkpoint branch. Adjudication 3 - probe CONFIRMED REAL and re-derived: base binary showed both record-unrecognised-fields and nominal discovery kind ticket, then editing ONLY kinds.json (sha256 1BC354E6 to 29E4213F, store.go still 0 ticket keys) made the discovery vanish while the unrecognised-field condition persisted. Suites re-run at bc552df: Go 108/108 PASS 0 FAIL (base 98) and go vet exit 0; Pester scripts/tests 234 pass 0 fail 5 skip of 239, the 5th skip being exactly the detached-HEAD ci-baseline skip so the car's 235/4 is correct; probes 29/29; store-checks 271/271; geometry standalone 3/3; node 236 trailer / 236 pass / 234 real tests. Four fault injections including the two the brief requested: breaking the Backlog+Todo filter reds with "Expected 2, but got 4" isolated to exactly 1 added red, and coupling freight freshness to computeLiveFreshness reds two tests, so both the filter and the freshness independence are genuinely guarded; the car's never-polled injection reds Case 1 THROUGH a real browser, satisfying #40. Verified board makes no outbound network call (only net/http for serving at handlers.go:4 and main.go:12) and board/fold is untouched. Law 7 ruled: ticket-sync is JUSTIFIED not a taxonomy dodge, because an empty store cannot otherwise prove a run happened. Law 6 ruled honored: seal reuses Get-Sha256Hex and computeFreightFreshness's max-by-at is the same recency idiom computeLiveFreshness already uses, not a second latest-wins authority. Disclosed limitations ruled: (a) NOT a Major, the cited path docs/index-format.md does not exist and the real gap is pre-existing and shared with manifest since the #38 gate reads only the base schema; (b) NOT a Major, correctly disclosed defence-in-depth; (c) NOT a Major, manual verification was sufficient. Note: the browser flake I hit is pre-existing issue #81, base flakes at the identical 2-of-6 rate and the new file is 6/6 solo, so it is NOT attributed to this car.
abstract: Adversarial review of bc552df over base 51fb403 for issue #84, the store-mediated freight ticket adapter. REJECT on 4 Majors. The car's headline claim holds and I re-derived all three named freight states in a real browser against the real Go binary, but an 11-state sweep found the enumeration incomplete: a freight lane that has never run claims "showing last good" once a scan fails, and tickets-without-heartbeat renders "not yet polled" beside the tickets themselves, a state reachable by a real partial failure of the car's own adapter whose header wrongly claims a failed run writes nothing. Separately, three committed screenshots still depict the dark freight lane this diff replaces, two under READMEs asserting Status Current, an obligation the car-brief template names as MAJOR-tier. The record shape, the store-mediated architecture, the fold-untouched constraint, the vocabulary probe, and the freshness independence all verified sound and are endorsed; the failure posture is endorsed as designed but rests on a false premise. Both checkouts clean at exit; all injections out-of-repo and restored sha256-identical.
```