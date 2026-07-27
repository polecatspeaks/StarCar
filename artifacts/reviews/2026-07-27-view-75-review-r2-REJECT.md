<!-- starcar-integrity: sha256=c0c8e664b4864a2fc462a88739d389a0e53be146aa6f726cd17f4250cc845fd1 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# View train #75 dispatch-row task-id titles, review round 2 (delta)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review (delta re-review, cap set on round 3)
Round: 2
Target: `car/view-75 fix-cycle r2 HEAD 5d4baae`
Base reviewed: `82f64b5f145885cee56d1337370dfe121d3e4d2b`
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
| Base commit the reviewer read (**the lookup key**) | `82f64b5f145885cee56d1337370dfe121d3e4d2b` |

| Dispatch, the locator within the session | `a353ad2db7e6ad627` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 82f64b5f145885cee56d1337370dfe121d3e4d2b
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: **REJECT** (1 Major, 3 minor) — with a swirl cap set

The code half has converged and is clean. The Major is in the new documentation the round-1 fix produced: a caption that claims an image proves something the image does not show, contradicted by the very source file the same README cites two lines earlier.

**One thing to say plainly first, without hedging:** on R1-M1 the car went *beyond* my citation and was right to. I cited two images; it found four, correctly reasoned that `hot-yard.png` inherits the ambient store via `cpSync`, and volunteered an explicit "unaffected" ruling on the fifth. I verified all three parts independently. That is the behaviour this shop wants.

---

## BASE-DELTA (#13)

Round-1 reviewed HEAD `82f64b5f145885cee56d1337370dfe121d3e4d2b` → round-2 HEAD `5d4baaec05b0aaafe6375536452747b2f23d40b0`. Verified FIRST: `git log -1 --format='%H'` → `5d4baaec05b0aaafe6375536452747b2f23d40b0`, detached, `git status --porcelain` empty. `git diff 82f64b5..5d4baae --stat` = **7 files, +174/−9**. Two commits: `a2e0068` (R1-M1), `5d4baae` (R1-m1/m2/m3). **No Go files in the delta** — `git diff --name-only 82f64b5..5d4baae -- '*.go'` returns empty, as claimed.

## Suites — RUN BY ME at 5d4baae

| Suite | Observed | Car claimed |
|---|---|---|
| `node --test` board/web | **225 tests / 225 pass / 0 fail / 0 skipped** | 225/225 ✔ (223 baseline + 2 new ✔) |
| `browser-dispatch-row-taskid.test.js` alone | **5/5** | 5/5 ✔ |
| `browser-dispatch-row-geometry.test.js` | **3/3** | 3/3 ✔ |
| `go test ./...` / `go vet ./...` | **98 PASS / 0 FAIL / 0 SKIP**, vet exit 0 | 98, clean ✔ |
| Pester `scripts/tests` | **227 total / 222 passed / 0 failed / 5 skipped** | 223/0/4 attached |
| `CodeCitationPolicy.Tests.ps1` | **13/13** | 13/13 ✔ |
| `DocPolicy.Tests.ps1` | **2/2** | — |
| `CitationResolverPolicy` (in the 227) | pass — scans all `git ls-files` minus `artifacts/**`, so both new READMEs' `file:line` citations were mechanically resolved | — |
| `probe-yard-snapshot.mjs` | **PASS**, exit 0 | PASS ✔ |

**The extra skip, named:** `run-session-start-guards.sh: agent-pull runner (#50).running the REAL guards prints [ci-baseline]'s marker ONLY when attached to a branch` — the same detached-HEAD-conditional test as round 1.

---

## THE FOUR-ID WALK

| ID | Round-1 finding | Status | Evidence |
|---|---|---|---|
| **R1-M1** | doc-clearance claim omitted `docs/screenshots/` | **Present** (fix correct + correctly broadened) — **but the fix introduced R2-M1** | see below |
| **R1-m1** | schema-valid `taskId: ""` renders a blank label | **Present** — fixed, provably | both new pins red on revert; falsy sweep clean |
| **R1-m2** | test named for a scenario its fixture does not construct | **DRIFTED** → R2-m1 | direction-B measurement below |
| **R1-m3** | stale `renderDispatches` comment | **Present** | `dom-writer.js:528-532` now reads "identity (task-id when the wire has one, else the record-dir hash subject…)" — accurate |

### R1-M1 — all three parts verified independently

**(a) Is the broadened scope CORRECT?** **Yes.** `board/web/verify-registers.mjs:105` → `captureState(browser, 'hot-yard', { storePath: buildScratchStoreWithInFlightDispatch() })`, and `real-board-server.js:61` → `cpSync(join(REPO_ROOT, 'artifacts'), storeDir, { recursive: true })`. Both cited lines say exactly what the READMEs claim. I opened **both** `hot-yard.png` files: each shows `a076bf6c0a94e…` in the **bottom-right cell of the dispatches grid**, exactly as captioned. Four images affected, not my two.

**(b) Is the "unaffected" claim TRUE?** **Yes — observed, not read.** An absence claim gets measured, so I ran `buildScratchStoreWithHealthTrendFamilies` through the real Go server and dumped the wire: all 5 dispatch rows and all 5 train cars report `taskIdPresent=false`. No `cpSync`, no `REPO_ROOT` in the builder. Claim holds.

**(c) Do the new READMEs accurately describe their images?** **Mostly — one Major and one minor.** What I verified as TRUE: capture commits `45b0e12` (`git show` confirms it added exactly `calm-yard.png` + `hot-yard.png` to register-check, subject "#62: board visual pass") and `3076a40` (added all three view-28-12 PNGs, subject "clickable provenance links (#28) + car health bar (#12)"); `verify-registers.mjs:104` and `real-board-server.js:61` both exact; `a076bf6c0a94e302f`'s **latest** returned record (17:28:56) is indeed `process-42-car-r3`; `browser-register-cascade.test.js` exists; `verify-registers.mjs:19-23` does say "evidence for a human/reviewer to read … never a pass/fail gate"; and calm-yard's "nominal register across all five lanes" measured **TRUE** (all five compose `nominal`).

**Against the doctrine that landed this morning:** I read `dev`'s CLAUDE.md (this worktree's copy predates it — the branch is based on `bc4c28f`). The ruling requires a README "stating what the images validated, the commit they were captured at, and any known divergence since", with labelling *never* recapture, mechanically floored by DocPolicy's `Status:` gate. **Both READMEs satisfy that shape**: what was validated (§ bullets), capture commit (`45b0e12`/`3076a40`), divergence (the DISCLOSED STALENESS block), `Status: Current` at line 3. I confirmed DocPolicy is non-vacuous here — stripping the Status line from the register-check README made it fail **naming that exact file**. The car's "recapturing would still be dated per-train evidence" reasoning also lands on the right side of the new ruling.

### R1-m1 — fixed, and the second half of the question answered

Fix: `render.js:325` `taskId: c.taskId || null` and `render.js:379` `taskId: d.taskId || null`. **Non-vacuity re-derived:** reverting both to `?? null` reds **exactly and only** the two new pins (`render.test.js`: 47 pass / 2 fail).

**"Did it alter behaviour for any other falsy-but-meaningful value?" — swept through the real served modules, no value lost:**
```
absent  -&gt; null -&gt; "sweepsubject"      zero  -&gt; null -&gt; "sweepsubject"
""      -&gt; null -&gt; "sweepsubject"      false -&gt; null -&gt; "sweepsubject"
null    -&gt; null -&gt; "sweepsubject"      NaN   -&gt; null -&gt; "sweepsubject"
real handle "sweep-task-r1" -&gt; "sweep-task-r1" -&gt; "sweep-task-r1"
```
There is no falsy string that is a meaningful task-id, so nothing meaningful changed — and `||` is *strictly safer* than `??` for the type-violation cases (`0`/`false`/`NaN`), which `??` would have rendered as literal `"0"`/`"false"`/`"NaN"` labels.

**Observation, deliberately NOT raised as a finding:** a whitespace-only `" "` is truthy and still renders a blank-looking label. I checked reachability before deciding: `Envelope.psm1:138` `.TrimEnd()` + `:154` `IsNullOrEmpty → $null` means an all-whitespace task-id never reaches a record. It is *less* reachable than the `""` case I raised, which was already only a minor. Raising it would be ratcheting, so I am recording it, not charging it.

---

## FINDINGS

### R2-M1 (MAJOR) — the new README claims an image proves something it does not show

`docs/screenshots/2026-07-26-view-28-12-candidates/README.md:21-23`:
&gt; `health-trend-and-provenance.png` - the #28 ticket-link/**record-dir** provenance anchors and the #12 car health-trend badge, **both rendering** against a controlled review-round fixture.

**I opened the image.** The `#12` ticket link renders as a real anchor (visibly underlined under the train title). The health-trend badges render (`▼ converged (3→0)`, `● stalled (3→4→4)`). But every dispatch-row subject (`conv-review-r1`, `stall-review-…`) and every car chip (`conv-review-r1 Gate returned REJECT round 1`) renders as **plain text with no anchor affordance** — no dotted underline, in direct visual contrast to `#12` in the same frame.

`board/web/verify-registers.mjs:109-114` — the file this same README cites at line 7 — says so explicitly:
&gt; DISCLOSED: this scratch store lives under os.tmpdir(), outside the repo root, so config.githubArtifactsPrefix resolves empty here … **car/gate/dispatch RECORD-DIRECTORY links do NOT render in this particular screenshot for that reason** (proven separately, in-repo, by board/server's TestBuildSnapshotGitHubConfigConfigured and this file's own dom-writer.test.js suite)

So the README **misattributes evidence**: it tells a reader this repo holds a visual capture proving record-dir provenance anchors render, when the capture proves the opposite and the real proof lives in two named tests elsewhere. Under the ruling that landed this morning, a screenshot README's *entire* function is to state truthfully what its images validated — "an image with no record of what it validated … is not evidence at all". A wrong record is worse than none. This is the same overclaiming class as my round-1 Major, one layer over, and it is a defect the round-1 fix created. **Remedy is one clause:** name only the ticket link and the badge, and note that record-dir anchors do not render here (per `verify-registers.mjs:109-114`), with the in-repo proof pointed at instead.

### R2-m1 (minor) — R1-m2 is DRIFTED: the test still cannot fail for a length reason

The fixture and name changed; the substance my finding named did not. Measured **entirely out of repo**, replicating the car's own fixture builder against the real Go server and real Chromium at 1024×900:

```
LANDED (79 chars)    len= 79  scrollWidth= 741  clientWidth=123  -&gt;  scrollWidth&gt;clientWidth = PASS
ROUND-1 (14 chars)   len= 14  scrollWidth= 131  clientWidth=123  -&gt;  scrollWidth&gt;clientWidth = PASS
```

**Direction A holds** (removing `text-overflow: ellipsis` from `board.css` reds the test — injected and observed). **Direction B fails:** shortening the id back to round-1's 14-char `view-75-car-r1` **still passes**. `.solari-subject`'s box is 123px — a 13rem `auto-fill` grid column — so essentially any plausible id overflows it. The new assertion is length-*sensitive* in principle but not length-*discriminating* in the range that matters, which is precisely what my round-1 finding said ("it overflows by 8px, by accident of the 13rem grid column, not because the id is long"). The test name (`browser-dispatch-row-taskid.test.js:79`) still asserts that being "GENUINELY long (79 chars, longer than the hash it replaces)" is what produces the truncation; measured, it is not.

The instrument did improve and now asserts a true, non-vacuous thing — hence minor, not escalated. **Cheapest honest fix (NIRTS):** rename to what it proves — the task-id genuinely overflows its box and the box truncates — rather than engineering a width at which a short id fits.

### R2-m2 (minor) — an unmeasured size claim in a new comment

`board/web/test/support/real-board-server.js:471`: "GENUINELY LONG (79 chars, longer than the **33-char** subject hash it replaces)". Measured: the task_id is **79** chars (true), but the subject it replaces in this fixture is `view-75-with-task-id` = **20** chars. The figure 33 matches nothing in the fixture (real record-dir hashes are 17 chars). The load-bearing half is true; the cited number is not. CLAUDE.md's GUIDE STAR scar names "an unmeasured size claim" as one of the four recorded failures this shop writes down.

### R2-m3 (minor) — an inaccurate mechanism gloss in the new README

`docs/screenshots/2026-07-26-register-check-candidates/README.md:17-18`: "(both lanes carrying that dispatch render red)". I opened `hot-yard.png`: **three** live lanes render red (DISPATCHES / GATES / TRAINS, all "stale, 3060s"). And they do so not because they "carry that dispatch" — the in-flight probe is unassigned yard inventory, present in the dispatches lane's data alone — but because `board/server/poll.go:428` `computeLiveFreshness` is a **single board-global computation** over all records and all dispatches, applied to every live lane. A reader learning the freshness model from this caption would draw a false conclusion about the mechanism.

---

## THE FLAKE RULING: genuine fragility, PRE-EXISTING, out of scope — ticket it

**Not merely a flake.** `board/web/test/support/real-board-server.js:616`:
```js
const resolvedPort = port ?? 4700 + (process.pid % 200);
```
That is a **fixed, PID-derived port**, not port 0. `pid % 200` yields only ~50 distinct values for Windows' multiple-of-4 PIDs, and `node --test` runs each of the **five** `browser-*.test.js` files as a separate concurrent process, each spawning a Go server. The observed `bind: Only one usage of each socket address is normally permitted` is Windows `WSAEADDRINUSE` — the exact signature of a fixed-port collision, not random noise.

**But it is entirely pre-existing and untouched by this train.** `git log -L 616,616` attributes that line to `7fabf8a` ("test(board): drive a real browser for issue #31's cascade defect class (#33)") — the file's creation. Neither round of #75 touched it.

**Incidence, measured:** I ran the full board/web suite **four times** at `5d4baae` — 225/225 each, **zero** bind errors — plus every individual-file run in this review. Consistent with an intermittent modulo collision rather than a systematic break.

**Ruling:** real defect, correctly kept out of this train's scope (rewrite-vs-extend and right-sizing both say so), **not a finding against #75**. It should get its own ticket; the remedy is already proven in-house — bind port 0 and read the bound address back, as #79's probe suite does. `dev`'s friction log (`0964d65`) already records this accurately and honestly says it was deliberately not fixed here; that entry is correct as written.

---

## CONVERGENCE — trigger met on its face; I set a cap rather than escalate now

Round 1: **1 Major, 3 minor.** Round 2: **1 Major, 3 minor.** Against CLAUDE.md's swirl-and-churn test: Major count **flat** (not declining) ✔, findings **clustered** in the documentation/instrument-honesty area both rounds ✔, and round 2's Major **is a defect the round-1 fix created** ✔ — the sharpest of the three. On the letter of the rule that is escalation territory.

I am not escalating yet, and here is the reasoning rather than a reflex: the **code** has converged hard — R1-m1 is provably closed, R1-m3 is closed, Go is untouched at 98 PASS, 225/225 node, every gate green. All four remaining items are **single-line prose or naming corrections** with no open design question and no relocation of a mechanism. This is a documentation-accuracy tail, not a design churning in place.

**The cap, which the conductor is bound by:** ONE more fix cycle. If a round 3 produces another Major in this same documentation-accuracy class, **escalate to the owner instead of dispatching round 4** — at that point the instrument, not the author, is the problem, and the question ("what premise makes every round of doc captions come out wrong?") is not one a reviewer gate can answer.

---

## CITATION (#42) AND DOC CHECK

`.md` is **declared exempt** from #42 (`CodeCitationPolicy.Tests.ps1:49-50`: "Documentation has its own mechanical floor - DocPolicy.Tests.ps1's Status-line gate"), so the two new READMEs need no bare `#N` — they carry `#75`/`#62`/`#28`/`#12` anyway. Gate green 13/13. DocPolicy 2/2, and **proven non-vacuous against these exact files** (injection named the register-check README by path). Every `file:line` inside both READMEs opens to what it claims, and the citation resolver — which scans all tracked non-`artifacts` files — passes.

## CONSTITUTION CHECK

- **Law 1 (never a confident falsehood)** — **VIOLATED** by R2-M1 (a false evidentiary claim on a documentation surface) and dented by R2-m2/R2-m3. **Honored** in the code: the falsy sweep shows every non-handle value degrading to the honest subject, never a blank or invented label.
- **NORTH STAR / screenshots-as-validation-device (dev ruling, 2026-07-27)** — **honored in shape** (both READMEs carry what-validated, capture commit, divergence, `Status:`), **failed in one claim** (R2-M1).
- **Law 6 (no second copy)** — honored; `taskIDsBySubject` remains the single resolution owner, Go untouched this round.
- **Law 7 (no hardcoded taxonomy)** — honored; `taskId` remains an opaque pass-through.
- **Law 4 (never silently dropped)** — honored; subject hash still verbatim in `title` on both surfaces, observed.
- **TDD red-first** — honored and re-derived: four injections this round, each red for its stated reason; plus one measurement (direction B) that came back **green when it should have reded**, which is R2-m1.
- **Blameless is not polite** — the car's R1-M1 work was better than my finding asked for and I said so first; the Major stands anyway, because effort is not a mitigating factor.
- **Read-only discipline** — nothing committed, nothing pushed, shared checkout never touched. Four disclosed injections (`render.js`, `board.css`, register-check `README.md`, plus the out-of-repo direction-B replication), **every one restored byte-identical by sha256**; final `git status --porcelain` empty at `5d4baae`. Two probes ran entirely outside the repo, as preferred.

**Unreproducible-evidence callout (#13):** none. Every finding rests on a command, an injection, or an image I opened, all restated above. The one claim I could not reproduce — the car's disclosed bind-error flake — I chased to its root cause (`real-board-server.js:616`) and ruled on with a measured incidence (0 in 4 full runs) rather than accepting or dismissing it.

**To clear:** R2-M1 is binding. R2-m1/m2/m3 are one-line corrections I would take in the same pass.

Files: `<repo>-wt\review-view-75\docs\screenshots\2026-07-26-view-28-12-candidates\README.md`, `...\docs\screenshots\2026-07-26-register-check-candidates\README.md`, `...\board\web\test\support\real-board-server.js`, `...\board\web\test\browser-dispatch-row-taskid.test.js`, `...\board\web\js\render.js`, `...\board\web\verify-registers.mjs`, `...\board\server\poll.go`

```starcar-artifact
outcome: REJECT
findings: 1 Major, 3 minor. Four-ID walk - R1-M1 PRESENT (fix correct and correctly broadened, but it introduced R2-M1), R1-m1 PRESENT (fixed provably), R1-m2 DRIFTED (see R2-m1), R1-m3 PRESENT. R2-M1 (MAJOR): docs/screenshots/2026-07-26-view-28-12-candidates/README.md lines 21-23 claims health-trend-and-provenance.png shows "the #28 ticket-link/record-dir provenance anchors and the #12 car health-trend badge, both rendering" - I opened the image and the record-dir anchors are NOT rendered (every dispatch-row subject and car chip is plain text with no anchor affordance, in visible contrast to the underlined #12 ticket link), and board/web/verify-registers.mjs lines 109-114, a file this same README cites at line 7, states this explicitly ("car/gate/dispatch RECORD-DIRECTORY links do NOT render in this particular screenshot") and names the two in-repo tests that do prove it; the README therefore misattributes evidence, in a document whose entire function under the owner ruling that landed this morning is to state truthfully what its images validated, and it is a defect the round-1 fix created. R2-m1 (minor, R1-m2 DRIFTED): the two-direction question comes back FALSE in one direction - measured entirely out of repo against the real Go server and real Chromium at 1024x900, the landed 79-char id gives scrollWidth 741 vs clientWidth 123 (assertion passes) but the round-1 14-char id gives scrollWidth 131 vs clientWidth 123, so the new assertion STILL PASSES for the short id my finding was about; .solari-subject's box is only 123px (a 13rem auto-fill grid column) so essentially any id overflows it, and the test name still asserts that being genuinely long is what produces the truncation when measurement says it is not; direction A does hold (removing text-overflow ellipsis reds the test, injected and observed), so the instrument improved and this stays minor. R2-m2 (minor): board/web/test/support/real-board-server.js line 471 claims "79 chars, longer than the 33-char subject hash it replaces" - the 79 is true but the subject it replaces in that fixture is view-75-with-task-id, 20 chars, and 33 matches nothing (real record-dir hashes are 17); an unmeasured size claim, the class CLAUDE.md's GUIDE STAR scar names. R2-m3 (minor): docs/screenshots/2026-07-26-register-check-candidates/README.md lines 17-18 says "both lanes carrying that dispatch render red" - I opened hot-yard.png and THREE live lanes render red, and they do so because board/server/poll.go line 428's computeLiveFreshness is a single board-global computation over all records and dispatches, not because a lane carries that dispatch (the in-flight probe is unassigned yard inventory present in the dispatches lane alone). R1-M1 three-part verification all CONFIRMED - the broadened scope is correct (verify-registers.mjs line 105 plus real-board-server.js line 61 cpSync, and I opened both hot-yard images and found a076bf6c0a94e in the bottom-right dispatches cell of each), the unaffected claim is TRUE (observed not read - ran buildScratchStoreWithHealthTrendFamilies through the real server, all 5 dispatch rows and all 5 train cars report taskIdPresent false), and both capture-commit citations are true (git show confirms 45b0e12 added exactly the two register-check PNGs and 3076a40 added the three view-28-12 PNGs). Both READMEs satisfy the new validation-device doctrine's required shape (what validated, capture commit, divergence, Status line) and DocPolicy was proven non-vacuous against them by injection. R1-m1 fully verified - reverting the two || back to ?? reds exactly and only the two new pins, and a falsy sweep through the real served modules shows absent/empty/zero/false/NaN/null all degrading to the honest subject with no meaningful value lost. FLAKE RULING - genuine fragility, pre-existing, out of scope, ticket it: real-board-server.js line 616 binds a fixed PID-derived port (4700 plus pid modulo 200, only about 50 distinct values for Windows multiple-of-4 PIDs) across five concurrent browser test files, so the observed bind error is WSAEADDRINUSE from a real collision hazard, not random noise; git log -L attributes that line to 7fabf8a (issue #33, the file's creation), untouched by either round of this train; measured incidence zero bind errors in four full-suite runs at 5d4baae; remedy already proven in-house is port 0 with read-back per #79. CONVERGENCE - round 1 was 1 Major 3 minor, round 2 is 1 Major 3 minor, so the swirl trigger is met on its face (Major count flat, findings clustered in the documentation-accuracy area, and this round's Major created by the previous round's fix); I did not escalate because the code has converged hard and all four remaining items are single-line prose or naming corrections with no open design question, but I SET A CAP the conductor is bound by - one more fix cycle, and if round 3 produces another Major in this same documentation-accuracy class, escalate to the owner rather than dispatching round 4. Suites re-derived at 5d4baae - node board/web 225 of 225 (four separate full runs), taskid file 5 of 5, geometry 3 of 3, Go 98 PASS 0 FAIL vet clean with no Go files in the delta, Pester scripts/tests 227 total 222 passed 0 failed 5 skipped with the extra skip named as the detached-HEAD session-start-guards ci-baseline test, CodeCitationPolicy 13 of 13, DocPolicy 2 of 2, probe-yard-snapshot PASS. Four disclosed fault injections plus two out-of-repo probes, every file restored byte-identical by sha256, tree clean at 5d4baae.
abstract: Delta review round 2 of view train #75, base 82f64b5 to head 5d4baae, two fix commits, 7 files +174/-9, no Go touched. REJECT on one Major. The car's four fixes were walked individually and re-derived by running rather than reading: R1-m1 and R1-m3 are properly closed (the empty-string pins red on revert and a falsy sweep through the real served modules shows no meaningful value lost), R1-M1's screenshot disclosure is correct and was correctly broadened beyond the reviewer's own citation from two images to four, with an explicit and independently verified unaffected ruling on the fifth. R1-m2 is DRIFTED: an out-of-repo replication of the car's fixture proved the new length assertion still passes for the short id the original finding was about, because the element's box is only 123px wide, so the test still cannot fail for a length reason. The Major is in the new documentation the fix produced - a caption asserting that a committed screenshot shows record-dir provenance anchors when the image does not show them and the source file cited two lines earlier says so explicitly. The swirl-and-churn trigger is met on its face with a flat Major count and a fix-created Major, so a hard cap was set at one further fix cycle before owner escalation. The disclosed browser-test bind error was traced to a fixed PID-derived port in a helper created by issue #33 and ruled a real but pre-existing out-of-scope defect deserving its own ticket.
task-id: view-75-review-r2
```