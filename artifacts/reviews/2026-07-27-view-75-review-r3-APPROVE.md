<!-- starcar-integrity: sha256=ef6ce70c781f292b7d1bfe931f2e81fb20e685f644fbfc8151f596b6828272cc covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# View train #75 dispatch-row task-id titles, review round 3 (delta, capped round)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review (delta re-review, round-2 cap live)
Round: 3
Target: `car/view-75 fix-cycle r3 HEAD 854aff4`
Base reviewed: `5d4baaec05b0aaafe6375536452747b2f23d40b0`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

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
| Base commit the reviewer read (**the lookup key**) | `5d4baaec05b0aaafe6375536452747b2f23d40b0` |

| Dispatch, the locator within the session | `a353ad2db7e6ad627` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 5d4baaec05b0aaafe6375536452747b2f23d40b0
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: **APPROVE** — 0 Major, 1 minor, 2 nits. **The cap does NOT fire; the series converged.**

Every assertion this round makes about what an artifact shows is **true**, and I verified each mechanically rather than by reading the car's report or squinting at pixels. The two prior Majors were both false assertions about artifact content; this round contains none. Findings shrank *and* moved — the opposite of the swirl signature.

---

## BASE-DELTA (#13)

Round-2 reviewed HEAD `5d4baaec05b0aaafe6375536452747b2f23d40b0` → round-3 HEAD `854aff41eb9b50f5e4d73f2cd8e10aa585b0a067`. Verified FIRST: detached, `git status --porcelain` empty. `git diff 5d4baae..854aff4 --stat` = **4 files, +88/−31** — matches the car's report exactly. One commit: `854aff4`. **No Go in the delta** (`git diff --name-only … -- '*.go'` empty).

**Scratch debris: none.** `git diff --name-only` contains no `scratch`/`measure` path; `git ls-files board/web` has none; `git log --all --diff-filter=A -- 'board/web/_scratch-measure-taskid.mjs'` returns **empty on every branch** — it was never committed anywhere. Tree clean, `-uall` shows nothing outside `node_modules`.

## Suites — RUN BY ME at 854aff4

| Suite | Observed |
|---|---|
| `node --test` board/web | **225/225, 0 fail** — three consecutive full runs, **0 bind errors in all three** |
| `browser-dispatch-row-taskid.test.js` alone | **5/5** |
| `browser-dispatch-row-geometry.test.js` alone | **3/3** |
| `go test ./...` / `go vet ./...` | **98 PASS / 0 FAIL**, vet exit 0 (untouched, as claimed) |
| Pester `scripts/tests` | **227 total / 222 passed / 0 failed / 5 skipped** |
| `CodeCitationPolicy.Tests.ps1` | **13/13** |
| `DocPolicy.Tests.ps1` | **2/2** |
| `probe-yard-snapshot.mjs` | **PASS**, exit 0 |

**Detached-HEAD delta, named:** `run-session-start-guards.sh: agent-pull runner (#50).running the REAL guards prints [ci-baseline]'s marker ONLY when attached to a branch` — the same conditional test as rounds 1 and 2 (car sees 4 skips attached, I see 5 detached).

**#81 flake:** not encountered. 0 bind errors in 3 runs here, on top of 0-in-4 at `5d4baae` — **0 in 7 full-suite runs** across two rounds. The car's 1-in-3 is consistent with an intermittent PID-modulo collision at `real-board-server.js`'s `resolvedPort`, still pre-existing and still out of scope.

---

## THE FOUR-ID WALK

| ID | Round-2 finding | Status | How verified |
|---|---|---|---|
| **R2-M1** | README claimed the image shows record-dir anchors | **Present** | real-browser anchor enumeration under the exact capture conditions |
| **R2-m1** | R1-m2 DRIFTED: assertion not length-discriminating | **Present** | rename matches my measurement; numbers reproduced exactly; still non-vacuous |
| **R2-m2** | false "33-char" comparison | **Present** | all replacement figures measured; 17-char claim uniformly true |
| **R2-m3** | "both lanes carrying that dispatch render red" | **Present** | mechanism traced hop-by-hop against real code |

### R2-M1 — verified mechanically, and it neither over- nor under-states

I did not take the car's word or trust my own pixel-reading. I reproduced `health-trend-and-provenance.png`'s **exact** capture conditions (`verify-registers.mjs:117-120`: `buildScratchStoreWithHealthTrendFamilies()` + `STARCAR_GITHUB_REPO`/`STARCAR_GITHUB_REF`) against the real Go server in real Chromium and enumerated every `&lt;a&gt;` on the page:

```
ALL &lt;a&gt; elements on the page: 1
   class="ticket-link provenance-link" text="#12" href=https://github.com/polecatspeaks/StarCar/issues/12
dispatch-row subjects: SPAN "conv-review-r1"  SPAN "conv-review-r2"  SPAN "stall-review-r2"  SPAN "stall-review-r3"   (no href)
car chips:  SPAN "conv-review-r1" … "stall-review-r3"                                        (no href)
```

**Exactly one anchor — the `#12` ticket link. Every `.solari-subject` and `.car-subject` is a plain `SPAN`.** The corrected bullet's every clause holds: the ticket link renders as a real anchor; the badges render (`▼ converged (3→0)`, `● stalled (3→4→4)` in red — confirmed by opening the image); record-dir anchors render nowhere.

**Under-statement check (the failure mode that followed the last correction) — clean.** I also reproduced `calm-yard`'s conditions (ambient store, no env): **zero `&lt;a&gt;` elements on the entire page.** So no image in that directory shows record-dir anchors, and the tightened second sentence's "never its record-dir-anchor half" is true across all three — it denies nothing that is actually there.

**Citations verified:** `TestBuildSnapshotGitHubConfigConfigured` exists (`board/server/githubconfig_test.go:28`) and the README cites it **by symbol, not line** ✔. `verify-registers.mjs:112-114` does name **both** that test and `dom-writer.test.js` ✔, and the comment sits at 106-116, **immediately above** the call at 117 ✔. The car also silently improved the source comment's own slip ("this file's own dom-writer.test.js suite" → "this repo's own"), which is correct — `verify-registers.mjs` is not that file.

**Live corroboration, unplanned but worth recording:** running calm-yard's conditions *today* rendered dispatch rows as `view-69-71-review-r1`, `friction-mine-0726-evening`, `view-69-71-review-r3`, `view-69-71-car-r3` — task-ids where the committed image shows hashes. Direct proof that the DISCLOSED STALENESS block describes something real.

### R2-m1 — the rename matches the measurement, not merely the sound of it

The car reproduced my numbers **exactly**: 14-char → `scrollWidth 131 / clientWidth 123`; 79-char → `741 / 123`. Identical to my round-2 out-of-repo measurement.

My finding was that the assertion is **box-width-dependent, not length-discriminating**. The new name — *"a task-id wider than `.solari-subject`'s own (narrow) box truncates via ellipsis rather than wrapping"* — states the box-width framing directly, and the header comment now says so explicitly, including that round-1's 14-char id "ALSO overflows it … and would ALSO pass this assertion." That is my finding written into the artifact, not paraphrased away. The comment correction "length-dependent" → "BOX-width-dependent" is right.

**Still non-vacuous:** injected removal of `text-overflow: ellipsis` from `board.css` (sha256 `B4860579…0E6B` before and after, restored byte-identical) reds exactly this test. Assertion logic unchanged, as claimed.

### R2-m2 — every replacement figure measured, and the 17-char claim is stronger than stated

`'view-75-with-task-id'.Length = 20` ✔, `'a076bf6c0a94e302f'.Length = 17` ✔, task_id `= 79` ✔. The claim "any real record-dir hash (measured: 17 chars)" is not merely an example — I grouped every hash-shaped directory in the real store: **all 66 are exactly 17 characters.** Uniformly true.

**No surviving unmeasured size claim in that comment.** I swept every number in it: 79 ✔, 33 (correctly quoted as the *wrong old* value) ✔, 20 ✔, 17 ✔, "~123px" ✔ (measured both rounds), "13rem `auto-fill` grid column" ✔ (`board.css:619` `repeat(auto-fill, minmax(13rem, 1fr))`).

### R2-m3 — mechanism trace verified line by line

Every hop the caption asserts, opened:
- `poll.go:334` — `liveFreshnessVal = computeLiveFreshness(scanResult.Records, out.Dispatches, …)`, called **once**, over every record and every dispatch ✔
- `poll.go:341-345` — the `laneRegistry` loop, `case "live": lane.Freshness = liveFreshnessVal`, one result to every live lane alike ✔
- `laneregistry.go:20-24` — dispatches/gates/trains `"live"` (**three**), freight `"dark"`, fuel `"bagged"` ✔
- `poll.go:367-368` — `default: lane.Freshness = Freshness{Kind: "not-applicable"}` — a constant literal ✔

**The self-caught overclaim was caught correctly.** The draft "carry no freshness computation at all" would have been false — those lanes *do* receive a freshness value, just a constant one. The committed wording, "a constant, never computed from record age", is precise. Disclosing that mid-writing correction is exactly the behaviour this shop codes as a success outcome, and it is worth saying so.

Against the image: `hot-yard.png` shows DISPATCHES/GATES/TRAINS all red at "Live / stale, 3060s", FREIGHT "Dark" and FUEL "Bagged" unchanged. All citations here are **symbol/shape form, zero line numbers** — the symbol-form rule this family paid two Majors for is honored.

---

## FINDINGS

### R3-m1 (minor) — a citation points at prose that does not contain the claim

`docs/screenshots/2026-07-26-register-check-candidates/README.md:20-24`:
&gt; not because each "carries" the in-flight probe (**it is unassigned yard inventory, present only in the dispatches lane's own data**, `board/web/test/support/real-board-server.js`'s `buildScratchStoreWithInFlightDispatch` **doc comment**)

I opened that doc comment (`real-board-server.js:41-58`). It says the builder `cpSync`s the real store and "adds exactly ONE additional, genuinely IN-FLIGHT `dispatched` record (no returned or presumed-lost successor)". It says **nothing** about the record being unassigned, nothing about yard inventory, and nothing about which lane it appears in. A reader following the pointer finds none of the two facts attributed to it.

**Both facts are true** — I verified them independently, and the *image itself* is the better citation: `hot-yard.png`'s own header reads **"80 in yard inventory (unassigned)"** against `calm-yard.png`'s **"79"**, and hot-yard's TRAINS lane carries the same ten chips as calm-yard with no probe among them. So this is a citation defect, not a false statement — which is why it is minor and not Major. Cheapest fix: cite the image's own "80 in yard inventory (unassigned)" line, or drop the pointer.

### R3-n1 (nit) — a 4-of-5 illustrative list without "etc."

`docs/screenshots/2026-07-26-view-28-12-candidates/README.md:25-27`: "every dispatch-row subject (`conv-review-r1`, `stall-review-r1/r2/r3`)". The image shows **five** dispatch rows — `conv-review-r2` is omitted. The sibling parenthetical in the same sentence does carry "etc."; this one does not, so it reads as an enumeration. The load-bearing claim ("record-dir anchors do NOT render anywhere in this image") is true and complete, so nothing is misrepresented.

### R3-n2 (nit / observation) — a test name asserting a property its sibling proves

`browser-dispatch-row-taskid.test.js:93` — "…truncates via ellipsis **rather than wrapping**". This test asserts computed `overflow`/`text-overflow` plus real overflow; the *non-wrapping* half is asserted by test 5 in the same file (`distinctTopCount === 1`) and by `.solari-row-main`'s `white-space: nowrap`. The property is genuinely guarded, just not by this test alone. Recording it rather than charging it.

---

## DOC CHECK — both READMEs satisfy the dev screenshot doctrine

Read against `dev`'s CLAUDE.md NORTH STAR (screenshots are a **validation device**, not a living document; the obligation is **labelling — what was validated, at which commit, known divergence — never recapture**):

| Requirement | register-check | view-28-12 |
|---|---|---|
| What the images validated | ✔ per-image bullets | ✔ per-image bullets |
| Capture commit | ✔ `45b0e12` (verified: added exactly those two PNGs, subject "#62: board visual pass") | ✔ `3076a40` (verified: added all three PNGs, subject "clickable provenance links (#28) + car health bar (#12)") |
| Known divergence since | ✔ DISCLOSED STALENESS block | ✔ same |
| DocPolicy `Status:` floor | ✔ line 3 | ✔ line 3 |
| Recapture avoided | ✔ explicitly reasoned | ✔ |

DocPolicy 2/2 and proven non-vacuous against these exact files in round 2. The citation resolver (#65) — which scans all tracked files minus `artifacts/**` — passes, so every `file:line` in both READMEs mechanically resolves. **#42:** `.md` is declared exempt (`CodeCitationPolicy.Tests.ps1:49-50`, documentation's floor being DocPolicy), gate green 13/13; both READMEs carry `#75`/`#62`/`#28`/`#12` regardless.

---

## CONVERGENCE AND THE CAP RULING

| Round | Majors | minors | nits |
|---|---|---|---|
| 1 | 1 | 3 | — |
| 2 | 1 | 3 | — |
| **3** | **0** | **1** | **2** |

**The cap does NOT fire.** I set it to trigger on "another Major in the same documentation-accuracy class" — and that class was specifically *false assertions about what an artifact shows*. This round contains none: every such assertion is true and independently verified, including the ones I had to build a browser probe to settle. Findings **declined** (1M/3m → 0M/1m/2n) and **moved** (from false content to a citation pointer and two nits), which is the converging signature rather than the swirl one. No round-3 finding is a defect created by a round-2 fix.

The round's binding rule — *open the artifact, describe what is actually there, then write the sentence* — is visible in the work product: the car reproduced my measurements independently, opened both images, traced the mechanism to four exact code sites, and disclosed catching its own draft overclaim before committing. That last one is the tell that the instrument changed rather than the wording.

**Escalation to the owner is NOT warranted.** R3-m1 and the two nits are one-line corrections that can ride the merge or be dropped; none blocks.

## CONSTITUTION CHECK

- **Law 1 (never a confident falsehood)** — **honored**. Every artifact claim verified true: 1 anchor in health-trend, 0 in calm/hot-yard, three red live lanes, the `default:` constant, 79/20/17/~123px/13rem. R3-m1 is a misplaced pointer to a true fact, not a falsehood.
- **NORTH STAR / screenshots-as-validation-device** — **honored**; both READMEs carry all four required elements.
- **Law 6 (no second copy)** — honored; Go untouched, `taskIDsBySubject` still the single resolution owner.
- **Law 7 (no hardcoded taxonomy)** — honored; nothing taxonomic changed.
- **Law 4 (never silently dropped)** — honored; `title` tooltip behaviour unchanged, 225/225.
- **Symbol-form citation rule** — honored; zero line-number citations added anywhere in the diff.
- **TDD / non-vacuity** — honored; the renamed test still reds under CSS fault injection, assertion logic unchanged.
- **GUIDE STAR (blameless, not vague; success outcomes reported as wins)** — the car's self-caught overclaim disclosure is a success outcome and I have named it as one, without hedging.
- **Read-only discipline** — nothing committed, nothing pushed, shared checkout untouched. One disclosed injection (`board.css`), restored **byte-identical** by sha256 (`B4860579…0E6B`); two probes ran entirely outside the repo. Final `git status --porcelain` empty at `854aff4`.

**Unreproducible-evidence callout (#13):** none. Every claim above rests on a command, an injection, an image I opened, or a browser probe restated here. One honest calibration note: my anchor-enumeration probe returned 4 dispatch rows where the committed image shows 5 (`stall-review-r1` absent) — a poll-timing artifact of my own probe, not a repo defect; it does not affect the finding, since every row it *did* return was a plain `SPAN`.

**Recommendation:** merge. R3-m1 is worth a one-line fix if a commit is passing anyway; the two nits are optional.

Files: `<repo>-wt\review-view-75\docs\screenshots\2026-07-26-register-check-candidates\README.md`, `...\docs\screenshots\2026-07-26-view-28-12-candidates\README.md`, `...\board\web\test\browser-dispatch-row-taskid.test.js`, `...\board\web\test\support\real-board-server.js`, `...\board\server\poll.go`, `...\board\server\laneregistry.go`, `...\board\web\verify-registers.mjs`

```starcar-artifact
outcome: APPROVE
findings: 0 Major, 1 minor, 2 nits. THE CAP DOES NOT FIRE - the series converged (round 1 1M/3m, round 2 1M/3m, round 3 0M/1m/2n), findings both declined and moved, and no round-3 finding is a defect a round-2 fix created. Four-ID walk - R2-M1 PRESENT, R2-m1 PRESENT, R2-m2 PRESENT, R2-m3 PRESENT, all four verified by running or opening rather than from the car's report. R2-M1 verified mechanically rather than by pixel-reading: I reproduced health-trend-and-provenance.png's exact capture conditions (buildScratchStoreWithHealthTrendFamilies plus STARCAR_GITHUB_REPO, per verify-registers.mjs lines 117-120) against the real Go server in real Chromium and enumerated every anchor element on the page - exactly ONE exists, class ticket-link provenance-link, text #12, href to issues/12, while every solari-subject and every car-subject is a plain SPAN with no href; the corrected bullet is therefore exactly right. Under-statement checked too: reproducing calm-yard's conditions (ambient store, no env) yields ZERO anchor elements on the whole page, so no image in that directory shows record-dir anchors and the tightened second sentence denies nothing that is actually present. TestBuildSnapshotGitHubConfigConfigured confirmed at board/server/githubconfig_test.go line 28 and cited BY SYMBOL not line; verify-registers.mjs lines 112-114 confirmed to name both that test and dom-writer.test.js, and to sit immediately above the capture call. R2-m1: the car reproduced my numbers exactly (14-char gives scrollWidth 131 vs clientWidth 123, 79-char gives 741 vs 123) and the rename to "a task-id wider than solari-subject's own narrow box" states the box-width framing my measurement established rather than merely sounding better, with the header comment now recording explicitly that round-1's 14-char id would ALSO pass; still non-vacuous, since injecting removal of text-overflow ellipsis from board.css reds exactly this test. R2-m2: all replacement figures measured correct - subject 20 chars, example hash 17, task_id 79 - and the 17-char claim is stronger than stated, since ALL 66 hash-shaped record directories in the real store measure exactly 17; no unmeasured size claim survives in that comment (79, 20, 17, ~123px and the 13rem auto-fill column at board.css line 619 all verified). R2-m3: mechanism trace verified hop by hop against real code - poll.go line 334 calls computeLiveFreshness ONCE over every record and dispatch, lines 341-345 assign that one result to every position live lane, laneregistry.go lines 20-24 declare three live lanes plus freight dark and fuel bagged, and lines 367-368 are the default branch assigning a constant Freshness Kind not-applicable; the car's self-caught draft overclaim correction ("carry no freshness computation at all" to "a constant, never computed from record age") is the right correction and disclosing it mid-writing is a success outcome. R3-m1 (minor): docs/screenshots/2026-07-26-register-check-candidates/README.md lines 20-24 attributes "unassigned yard inventory, present only in the dispatches lane's own data" to buildScratchStoreWithInFlightDispatch's doc comment, but that comment (real-board-server.js lines 41-58) says only that the builder cpSyncs the real store and adds one in-flight dispatched record - it contains neither fact; both facts are independently TRUE (hot-yard.png's own header reads 80 in yard inventory unassigned against calm-yard's 79, and hot-yard's trains lane carries the same ten chips with no probe), so this is a misplaced pointer rather than a falsehood, hence minor not Major. R3-n1 (nit): the view-28-12 README names four of five visible dispatch-row subjects without an "etc." while the sibling parenthetical in the same sentence has one. R3-n2 (nit): the renamed test's "rather than wrapping" clause is proven by its sibling test 5 and by white-space nowrap, not by this test alone. Scratch debris check clean - git log --all --diff-filter=A shows board/web/_scratch-measure-taskid.mjs was never committed on any branch, nothing tracked or untracked. Suites at 854aff4 - node board/web 225 of 225 across THREE consecutive full runs with zero bind errors (0 in 7 runs across two rounds, so the #81 fixed-port flake was not encountered and remains pre-existing and out of scope), taskid file 5 of 5, geometry 3 of 3, Go 98 PASS vet clean with no Go in the delta, Pester 227 total 222 passed 0 failed 5 skipped with the detached-HEAD delta named as the session-start-guards ci-baseline test, CodeCitationPolicy 13 of 13, DocPolicy 2 of 2, probe-yard-snapshot PASS. Both READMEs satisfy the dev screenshot doctrine on all four points (what validated, capture commit verified by git show, known divergence, DocPolicy Status line) and every citation added this round is symbol-form with zero line numbers. One disclosed injection, restored byte-identical by sha256, tree clean at 854aff4.
abstract: Delta review round 3 of view train #75 - the capped round. Base 5d4baae to head 854aff4, one fix commit, 4 files +88/-31, no Go, no scratch debris. APPROVE with zero Majors, so the cap I set in round 2 does not fire and no owner escalation is warranted. All four round-2 findings are Present, each re-derived by running or opening rather than from the car's report: the R2-M1 correction was verified by driving a real browser under the screenshot's exact capture conditions and enumerating every anchor element (exactly one, the ticket link, with every subject and car chip a plain span), and the opposite failure mode was tested too by reproducing calm-yard's conditions and finding zero anchors, confirming the tightened sentence under-states nothing. The R2-m3 mechanism trace was checked against four exact code sites and the car's self-caught draft overclaim correction proved to be the right one. R2-m1's rename matches the measurement I made rather than merely sounding better, and R2-m2's replacement figures are not only correct but uniformly so across all 66 hash-shaped record directories. What remains is one minor citation pointer aimed at a comment that does not contain the fact attributed to it, plus two nits. The series went 1M/3m to 1M/3m to 0M/1m/2n, with findings both declining and moving, which is convergence rather than swirl.
task-id: view-75-review-r3
```