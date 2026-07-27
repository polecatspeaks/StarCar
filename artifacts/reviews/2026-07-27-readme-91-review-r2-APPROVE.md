<!-- starcar-integrity: sha256=7f391389a6a51660fb22a90f3d1c5cb1b1f008a84f025956840b513c1b3600e4 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# README #91 accuracy sweep + rebalance, review round 2 (delta, PR gate)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review - PR gate for user-facing documentation
Round: 2
Target: `car/readme-91 fix-cycle r2 HEAD b985424`
Base reviewed: `20c3970`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a06d658c5485bd454`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `20c3970` |
| Entire checkpoint | `bc2128224ca2` |
| Dispatch, the locator within the session | `a06d658c5485bd454` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 20c3970
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Cleanup confirmed: server stopped, port 4600 free, worktree `b985424` porcelain empty, shared checkout untouched. I edited, committed, and pushed nothing.

---

# ROUND 2 VERDICT: **APPROVE** — 0 Major, 1 minor (non-blocking)

All three Majors and all five minors from round 1 are genuinely resolved — verified against code and live observation, not against the car's report. One new minor appeared inside a round-1 fix; it is a dependency-count imprecision that blocks nothing.

**The README is fit to be the front door of a public PR.**

## BASE-DELTA

| | |
|---|---|
| Head | `b985424b3971d524d9cd611ff3cabe2630ba770b`, detached (`%d` = `(HEAD, car/readme-91)`, no `-&gt;`) |
| Porcelain | empty |
| Base | `20c3970` — confirmed ancestor of `b985424` |
| `ae22071` | **Confirmed absent from history** (`git merge-base --is-ancestor ae22071 HEAD` → not an ancestor). `git log` shows `b985424` sitting directly on `20c3970`. Amended in place, as you stated — I verified rather than assumed. |

```
 README.md                                          | 185 ++++++++++++---------
 docs/screenshots/2026-07-27-readme-board/README.md |  71 ++++++++
 .../yard-board-2026-07-27.png                      | Bin 0 -&gt; 262829 bytes
 3 files changed, 177 insertions(+), 79 deletions(-)
```

**Bonus for delta precision:** the pre-amend object `ae22071` survives as a dangling commit, so I diffed **round 1 → round 2 exactly** (`git diff ae22071..b985424`: README.md 52 lines, screenshot README 11 lines) rather than inferring the delta from the base. Every changed sentence below was identified from that diff.

## Suites run myself at `b985424`

| Suite | Passed | Failed | Skipped | Total |
|---|---|---|---|---|
| `DocPolicy.Tests.ps1` | **2** | 0 | 0 | 2 |
| `CodeCitationPolicy.Tests.ps1` | **13** | 0 | 0 | 13 |

**No skip delta** — zero skipped in both, and the citation gate's `the boundary commit resolves in this checkout` test passed, so nothing degraded to the shallow-clone path.

## Quickstart, run end to end at `b985424`

`0` listeners on 4600 before I started (no stray server), and the server bound **my** worktree: `store=~/git/starcar-wt/review-readme-91/artifacts`, with `storePathDisplay: ~/git/starcar-wt/review-readme-91/artifacts` in the snapshot. No false green.

`GET /` **200** · `GET /api/snapshot` **200** · `GET /js/app.js` **200** · `GET /api/stream` **200** with a real `event: yard` frame · schema validation via the browser's own vendored validator: **`valid: true`** · `laneCount: 5` · **41** freight tickets · `dispatches=idle, gates=idle, trains=idle, freight=stale, fuel=not-applicable`.

The README's "Verified 2026-07-27" block (byte-identical to round 1) reproduces exactly, for the second time.

---

# THE EIGHT IDs

| ID | Status | Evidence |
|---|---|---|
| **R1-M1** "at request time" | **ABSENT (fixed)** | `README.md:110` now reads *"at poll time, once a second"*. Matches `poll.go:345` (`fold.Fold` call site) inside `PollOnce`, reached only from `RunPollLoop`'s ticker (`poll.go:244`, `poll.go:232`) at `PollMs: 1000` (`config.go:61`). Now **agrees** with `README.md:8` instead of contradicting it. |
| **R1-M2** "periodically reads" | **ABSENT (fixed)** | `README.md:16-17` now reads *"is run manually, on demand (`docs/setup.md`)"* — matching `docs/setup.md:51`'s own wording *"Run it manually, on demand, from the repo root"* verbatim, and its *"nothing in this repo invokes this script automatically today"*. No longer contradicts the sibling doc (*"manually-run batch sync"*) or `README.md:38` (*"between manual syncs"*). Closing clause improved to *"as fresh as the last person who ran the sync"* — the human action is now explicit. |
| **R1-M3** false #90/#91 accusation | **ABSENT (fixed), disclosure exemplary** | See ruling below. |
| **R1-m1** wrong row ordinal | **ABSENT (fixed)** | Screenshot README now reads *"third chip (of five, left to right)"* — matches my round-1 crop measurement exactly. |
| **R1-m2** #86 mis-attribution | **ABSENT (fixed), verified hardest** | See verification below. |
| **R1-m3** undisclosed network need | **ABSENT (fixed)**, one new minor inside it | `README.md:52-54` now *"no account, no config file required, and once built, no external service either"*; new prerequisite at `:60-63`. See **R2-m1**. |
| **R1-m4** Reading Order | **ABSENT (fixed), substantive not token** | See ruling below. |
| **R1-m5** "one" hash vs ten | **ABSENT (fixed), verified exactly** | `README.md:44-46` now distinguishes them. **10 distinct manifest members** across `artifacts/train-board-v0/intent-*.json`, and every one carries keys exactly `['role','subject']` — no `task_id`. "Ten" and "only `subject` and `role`, no `task_id` at all" are both exact. |

**Zero DRIFTED.** Every fold is substantive, not cosmetic.

## R1-m2 — the hardest check, verified directly

You were right to flag this as the one to press: a corrected attribution that is itself wrong is the same defect one layer over, and this document had already mis-stated #86 once.

The car's new text: *"`board/assemble/assemble.go`'s `manifestPayload` reads only `subject`, `role` and `gate` off a manifest member and never `task_id`, even though a member can already carry one."*

I opened the cited range. `manifestPayload` begins at **`board/assemble/assemble.go:335`** and ends at `:361`. Its member loop reads exactly three keys:

```go
subject, _ := mm["subject"].(string)
role, _    := mm["role"].(string)
gate, _    := mm["gate"].(string)
...
members = append(members, manifestMember{Subject: subject, Role: role, Gate: gate})
```

No `task_id`, anywhere in the function. The cited range `335-360` is accurate. Corroborated from the other side: the wire's `taskId` comes from `TaskID: taskIDs[m.Subject]` (`assemble.go:123`), fed by `taskIDForReturnedSubject`, which reads `task_id` off **returned** records only (`assemble.go:488-510`). That is precisely #86's stated defect — consumer-side, not producer-side.

I also tested the one sub-claim that could have been overreach, *"even though a member can already carry one"*: `schema/starcar-manifest.schema.json`'s member declares `properties: [subject, role, gate]`, `required: [subject, role]`, and **`additionalProperties` unset** — so a `task_id` on a member is permitted, and #86 records a reviewer having actually built one (*"an amended member carrying `task_id: tooling-76-car-r1`"*) and measured the board dropping it. The claim holds. *(Precision note, not a finding: `task_id` is permitted-but-undeclared on a member rather than a declared property.)*

**Correctly attributed this time.**

## R1-M3 — ruling on the fix AND the disclosure

**The fix is clean.** The phrase *"issue #91's own body mischaracterized #90"* is gone with no residue. The amended message keeps only true observations:

- *"Freight carries three fields today (number/title/status, no area concept)"* — true of the rendered row (`dom-writer.js:619-621`); the parenthetical names the three, so there is no ambiguity with the five-field payload.
- *"the area/phase column #91 itself said is unimplemented is #90's own unbuilt work, ruled in by the owner on that open ticket"* — true in every clause.
- The quoted fragments *"PHASE IS NEW DATA"* and *"this is no longer a CSS-only ticket"* are both **verbatim** from #90's owner-ruling comment, joined by a marked ellipsis.

**No overcorrection:** it claims nothing #90 does not say, and it now credits #91 with having been right.

**Ruling on the disclosure: exemplary, and it is the most valuable line in the commit.** The car names the exact command it ran (`gh issue view 90 --json body`), the exact omission (never `--comments`), where the ruling lived, and then generalizes to the class: *"That is the actual mistake: reading an issue without its comments."* That is blameless-but-not-vague done properly — precise attribution, actor and move named, no hedging, and it converts a wrong call into a reusable rule. Under the GUIDE STAR this is a success outcome with a durable artifact (the amended message plus this verdict). The class it names is worth carrying: an issue's body is not the issue.

## R1-m4 — substantive, not a token gesture

`README.md:134-139` adds a new paragraph *ahead of* the governing list:

&gt; For the board itself rather than the process that built it: `docs/design/2026-07-21-v0-yard-skeleton-design.md` (what v0 is and why) and `schema/yard-snapshot.schema.json` (the wire contract `board/server` and `board/web` both honor - the actual source of truth for what a lane can carry).

and reframes the old list at `:141`: *"The list below is the governing-process path, not the only path in."*

I graded this against "token gesture" and it passes on three counts: **both targets exist** (verified on disk); **the claim about them is true** — `board/server` serves the schema byte-for-byte (`handlers.go:19`, `:103`, `:110`) and mirrors it in its wire types (`snapshot.go:16`, `:94`), while `board/web` fetches and validates against that same route (`app.js:150`, `app.js:9`), with a hand-maintained mirror explicitly forbidden (`handlers.go:14-15`); and it **changes what a stranger does** — someone wanting the board rather than the process now has a route on the first line of the section instead of five process documents. The original ONBOARDING paragraph is retained intact, so nothing was traded for it.

---

# NEW FINDING

## R2-m1 (minor, non-blocking) — `README.md:60-63`: "one dependency", but a cold build downloads two

&gt; **Network access for the first build only.** `board` has one dependency (`github.com/santhosh-tekuri/jsonschema/v6`, per `board/go.mod`) and there is no `board/vendor/`, so `go run` downloads **it** from the module proxy the first time; every run after that is offline.

Measured, empty `GOMODCACHE` + live proxy:
```
go: downloading github.com/santhosh-tekuri/jsonschema/v6 v6.0.2
go: downloading golang.org/x/text v0.14.0
exit=0
```

`board/go.mod` declares **two** requires — the direct one plus `golang.org/x/text v0.14.0 // indirect` — and a stranger's first build fetches both. The cited file shows two; the prose says one and "downloads **it**".

**Why this does not block:** the load-bearing promise is correct and I verified it in both directions — `GOPROXY=off` fails with `module lookup disabled by GOPROXY=off` (round 1), and a warm cache builds offline (`exit=0`). `board/vendor/` genuinely does not exist (checked at `b985424`). The stranger is neither blocked nor misdirected; they see one more download line than the sentence led them to expect. "One dependency" is also defensible Go usage for *direct* requires. One-word fix if you want it before opening: *"one direct dependency (plus one indirect, `golang.org/x/text`)"*, or simply *"downloads its dependencies"*.

**Honest disclosure:** yes, this is a defect the round-1 fix created. See convergence.

---

# SENTENCE CHECK OVER CHANGED PROSE

Per your instruction I re-traced every sentence that **changed**, not just the finding sites — a fix can plant a new false claim, which is what round 1 found.

| Changed sentence | Verdict | Hop |
|---|---|---|
| Freight bullet `:16-19` | **True** | `docs/setup.md:51`; grep of `.github/`+`.claude/` → 0 automated invocations |
| #86 clause `:41-44` | **True** | `assemble.go:335-361` never reads `task_id`; `:123`/`:488-510` source it from returned records |
| Trains-hash clause `:44-46` | **True, exact** | 10 members, all keys `['role','subject']` |
| Quickstart intro `:52-54` | **True** | board makes no outbound call once built (no `http.Get`/`http.Client`/`net.Dial` in `board/**/*.go` non-test) |
| Network prerequisite `:60-63` | **Substance true, count off** | **R2-m1** |
| Status fold clause `:110` | **True** | `poll.go:232/244/345`, `config.go:61` |
| Reading Order lead-in `:134-141` | **True** | targets exist; `handlers.go:19/103/110`, `snapshot.go:16/94`, `app.js:9/150` |
| Screenshot README #86 bullet `:48-55` | **True** | as above, plus my round-1 crop for "third chip" |

**Nothing true was lost in the edits.** I checked each removal: *"not a live poll of GitHub"* is subsumed by the retained and stronger *"the board process itself makes no outbound network call"*; *"dispatched records don't carry one yet"* was the mis-framed cause being replaced, not a fact being suppressed; *"only returned ones do"* is preserved in substance by the new consumer-side framing. The ONBOARDING paragraph, the PR #5 sentence, and the Law 7 sentence are all intact.

**Relied on round-1 traces, byte-identical at `b985424`:** the tagline, `:8-10`, the Trains/Gates/Dispatches/Fuel bullets, the broader-vision paragraph, the screenshot caption's #90/#63/#76/#88 clauses, the command block and endpoint list, the optional-provenance section, the "Verified 2026-07-27" block (re-run anyway — reproduces), the entire Process section, the numbered list 1-5, and License.

---

# CONVERGENCE

**Converging, decisively. Not swirl.**

| | Round 1 | Round 2 |
|---|---|---|
| Major | **3** | **0** |
| minor | **5** | **1** |
| DRIFTED folds | — | **0** |

Findings **shrank and moved** rather than holding station — the signature of convergence. Round 1's findings clustered in the README's factual claims; round 2 has one dependency-count nit in a newly added sentence.

**Is any round-2 finding a defect the round-1 fixes created? Yes — R2-m1, and I report it rather than smoothing it.** But I rule it is **not** the swirl signature. The swirl trigger's sharpest reading is *relocation* — the defect moving instead of resolving. Here the defect class R1-m3 named (an undisclosed network prerequisite) is genuinely resolved: the disclosure now exists, is prominent, is correctly scoped to the first build, and is fault-injection-verified in both directions. What remains is an off-by-one on a dependency count *inside* a working fix. Two of the three swirl conditions are absent outright: Major counts fell 3 → 0, and findings did not cluster in the same section. **No escalation warranted; no cap set.**

# CONSTITUTION CHECK

- **Law 1 (Truth) — HONORED.** The two confident falsehoods are gone, each replaced by a claim I traced to code, and the document no longer contradicts itself: `:8` and `:110` now agree on "once a second"; `:16` and `:38` now agree on "manual". The false accusation against an owner ruling is retracted from the permanent record. R2-m1 is an imprecision, not a falsehood about behaviour.
- **Law 7 (The Stranger) — HONORED. Could someone with no context deploy from this?** I walked it: `git clone` → default branch `main` (which already carries `board/`) → `cd StarCar/board` → `go run ./server` → open `127.0.0.1:4600` → HTTP 200 on every documented route with a live board. The one gap round 1 found (an unstated network prerequisite) is now disclosed at `:60-63` before the command block. The Reading Order now offers the stranger a work-facing route, not only a process one.
- **Showcase-never-edits-the-record — HONORED, and tested this round.** The amend was of an unpushed local commit that never reached a remote — permitted, and not a rewrite of published history. What matters is that the amend did not *soften* anything: PR #5's revert, the record-is-never-curated line, and the warts-and-all screenshot with its five named defects all survive unchanged, and the fix-cycle paragraph **adds** a self-incriminating disclosure rather than quietly dropping the wrong claim. The REJECT verdict is cited by path in the commit message. That is the rule working in the direction it was written for.
- **Documentation ranks equal to code — the standard applied.** Round 1 rejected on prose; round 2 approves on the same evidentiary bar.

# PR FITNESS

**The README is fit to be the front door of a public PR.** Act on that sentence.

R2-m1 does not block. If you want it closed first it is a one-word edit at `README.md:60-61`; otherwise it is a legitimate deferral and I would not hold the PR for it.

Files: `<repo>-wt\review-readme-91\README.md`, `<repo>-wt\review-readme-91\docs\screenshots\2026-07-27-readme-board\README.md`, `<repo>-wt\review-readme-91\board\assemble\assemble.go`, `<repo>-wt\review-readme-91\board\server\poll.go`, `<repo>-wt\review-readme-91\docs\setup.md`

```starcar-artifact
task-id: readme-91-review-r2
outcome: APPROVE
findings: 0 Major, 1 minor (non-blocking)

EIGHT ROUND-1 IDs, ALL ABSENT (FIXED), ZERO DRIFTED:

R1-M1 ABSENT - README.md:110 now reads "at poll time, once a second", matching poll.go:345 (fold.Fold call site) inside PollOnce, reached only from RunPollLoop's ticker (poll.go:244, poll.go:232) at PollMs 1000 (config.go:61). Now agrees with README.md:8 instead of contradicting it.

R1-M2 ABSENT - README.md:16-17 now reads "is run manually, on demand (docs/setup.md)", matching docs/setup.md:51 verbatim. No longer contradicts the sibling screenshot doc or README.md:38.

R1-M3 ABSENT - the accusation against issue #91 is gone with no residue. Amended message keeps only true observations and quotes #90's owner ruling verbatim ("PHASE IS NEW DATA", "this is no longer a CSS-only ticket"), crediting #91 with having been right. No overcorrection. Disclosure ruled EXEMPLARY: the car names the exact command (gh issue view 90 --json body), the exact omission (never --comments), and generalizes the class - an issue's body is not the issue.

R1-m1 ABSENT - "third chip (of five, left to right)", matching my round-1 crop measurement.

R1-m2 ABSENT, VERIFIED HARDEST - board/assemble/assemble.go:335-361 manifestPayload reads exactly subject, role, gate and never task_id; manifestMember carries only those three. Corroborated from the other side: wire taskId comes from assemble.go:123 fed by taskIDForReturnedSubject reading returned records only (assemble.go:488-510). The sub-claim "a member can already carry one" holds: schema/starcar-manifest.schema.json leaves additionalProperties unset, and #86 records a reviewer having built such a member and measured the board dropping it. Correctly attributed this time.

R1-m3 ABSENT - network prerequisite disclosed at README.md:60-63; see R2-m1 for one imprecision inside the fix.

R1-m4 ABSENT, SUBSTANTIVE NOT TOKEN - README.md:134-141 adds a work-facing lead-in ahead of the governing list. Both targets exist on disk; the claim that board/server and board/web both honor the wire schema is verified (handlers.go:19/103/110, snapshot.go:16/94, app.js:9/150). The ONBOARDING paragraph is retained intact.

R1-m5 ABSENT, VERIFIED EXACTLY - 10 distinct manifest members across artifacts/train-board-v0/intent-*.json, every one with keys exactly role and subject, no task_id. "Ten" and "only subject and role, no task_id at all" are both exact.

NEW FINDING:

R2-m1 (minor, NON-BLOCKING) README.md:60-63 - "board has one dependency ... so go run downloads it" but a cold build downloads two. Measured with empty GOMODCACHE and live proxy: "go: downloading github.com/santhosh-tekuri/jsonschema/v6 v6.0.2" and "go: downloading golang.org/x/text v0.14.0", exit 0. board/go.mod declares both, the second marked indirect. The load-bearing promise (network for first build only, offline after) is correct and verified both directions: GOPROXY=off fails with module lookup disabled, warm cache builds offline. board/vendor genuinely absent. One-word fix available; does not block.

RUN AT b985424: DocPolicy 2 passed 0 failed 0 skipped of 2. CodeCitationPolicy 13 passed 0 failed 0 skipped of 13. No skip delta; the boundary-commit test passed so nothing degraded to the shallow-clone path. Quickstart end to end with zero pre-existing listeners on 4600 and storePathDisplay confirmed as the review worktree: HTTP 200 on /, /api/snapshot, /js/app.js; /api/stream 200 with a real "event: yard" frame; schema valid true via the browser's own vendored validator; laneCount 5; 41 freight tickets; freshness idle/idle/idle/stale/not-applicable. The "Verified 2026-07-27" block reproduced exactly for the second time.

BASE-DELTA: head b985424, detached, porcelain empty; 20c3970 confirmed ancestor; ae22071 confirmed NOT an ancestor (amended in place, verified not assumed). 3 files, 177 insertions, 79 deletions. The pre-amend object survives dangling, so the round-1 to round-2 delta was diffed exactly rather than inferred: README.md 52 lines, screenshot README 11 lines.

CONVERGENCE: 3 Major 5 minor to 0 Major 1 minor, zero DRIFTED folds. Findings shrank and moved rather than holding station. R2-m1 IS a defect a round-1 fix created and is reported as such, but it is not the swirl signature: the class R1-m3 named is genuinely resolved, Major counts fell to zero, and findings did not cluster in the same section. No escalation, no cap.

CONSTITUTION: Law 1 honored - both falsehoods gone, internal contradictions resolved, false accusation retracted. Law 7 honored - clone to running board walked end to end on the default branch, prerequisites now complete, and the stranger gains a work-facing reading route. Showcase-never-edits-the-record honored - the amend touched an unpushed local commit, softened nothing, and ADDED a self-incriminating disclosure while citing the REJECT verdict by path.

VERDICT: APPROVE. The README is fit to be the front door of a public PR.

abstract: Round-2 delta review of the README accuracy sweep and rebalance for ticket 91, at b985424 over base 20c3970, gating a dev-to-main pull request. Verified the base and independently confirmed the round-1 commit was amended out of history rather than assuming it, then recovered the dangling pre-amend object to diff round 1 against round 2 exactly. Walked all eight round-1 finding IDs: every one ABSENT, zero DRIFTED. Pressed hardest on the corrected issue-86 attribution, opening board/assemble/assemble.go:335-361 and confirming manifestPayload reads exactly subject, role and gate and never task_id, corroborated from the wire side, with the supporting schema sub-claim checked too. Verified the ten-bare-hash claim exactly against the store's manifest members. Re-ran the full sentence check over every changed sentence rather than the finding sites alone, and confirmed nothing true was lost in the edits. Found one new minor: a dependency count that says one where a cold build downloads two, measured by fault injection, inside an otherwise correct network-prerequisite fix. Ruled the commit-message self-disclosure exemplary for naming the exact command, the exact omission and the reusable class. Convergence is decisive at 3 Major to 0. APPROVE, and the README is stated fit to be the front door of a public PR.
```