<!-- starcar-integrity: sha256=44b600206c61bb381a843a10c405f1dd8f530464679b45f641842cf0564869c8 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car view-30 delta re-review - round 2 (APPROVE, mergeable)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-level adversarial delta re-review, whole-train gate
Round: 2
Target: `commit fdfa80f on car/view-30 (round-1 remedies)`
Base reviewed: `fdfa80f5110e22614abc40d8b61568097af4b513`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

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
> Path normalisation: none applied (the body contained no operator-environment paths).

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `fdfa80f5110e22614abc40d8b61568097af4b513` |

| Dispatch, the locator within the session | `afe1a2c703e2e615e` |
| Entire session (context, NOT a lookup key) | `15c84ef1-8e84-4d98-aacd-17cce34752cb` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain fdfa80f5110e22614abc40d8b61568097af4b513
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# DELTA RE-REVIEW ROUND 2 — `view-30-review-r2` — **APPROVE**

**0 Major, 2 Minor.** Base verified: `fdfa80f5110e22614abc40d8b61568097af4b513`, parent `8658011`, clean tree before and after (all five fault injections reverted byte-identical by `git hash-object`).

All seven round-1 findings are **Present** — genuinely folded, not cosmetically. I re-ran both of my own round-1 injections against the tightened instruments and watched them flip from silent-pass to caught-by-name. **The train is MERGEABLE from `fdfa80f`.**

---

## Findings table — round-1 disposition

| ID | Round-1 finding | Disposition | Evidence I observed |
|---|---|---|---|
| **MAJOR-1** | Rule 4 + `gating-matrix.md:45` stale | **PRESENT** | `design:184-188` keeps the original Rule 4 text verbatim and appends `[SUPERSEDED, issue #30, 2026-07-26 - see §12b]`. `gating-matrix.md:45` quotes the pre-#30 rationale **inside** its `[AMENDED]` block and correctly severs the two claims: *"What did NOT change: this row's own guarantee - the surface fires, and is never suppressed regardless of register."* Original preserved, supersession explicit, guarantee distinguished from register. |
| **MAJOR-2** | §12b over-scoped to `position`/`role` | **PRESENT** | §12b now reads "SUPERSEDES §5.2 Rule 4 and, **IN PART**, §6's row", with a dedicated bullet: *"`position` and `role` are UNCHANGED and render `needs-attention` still."* Reasoning is correct and I re-verified the mechanism independently: `grep "Code:" board/{store,assemble,server}/*.go | grep -iE "position|role"` → **no matches**, confirming no construction site exists for them. |
| **MAJOR-3** | "hot" deleted; doc contradicted a green test | **PRESENT** | `"renders it hot, BY NAME, verbatim"` restored at `ui-mockup-brief.md:87-88`. The amendment is rescoped to name the two mechanisms apart and cites the pin with its assertion. **The doc now agrees with the test:** TAP `ok 55` observed passing at `fdfa80f`. |
| **MAJOR-3b** | `vocab.js:9-11` orphaned citation | **PRESENT** | Comment rewritten; the incorrect `design rev 5 S5.2` reference (which pointed at Rule 4, a different subject) is **dropped**, and the new text states outright: *"THIS PATH IS UNCHANGED BY ISSUE #30 … it has no lever over this function."* |
| **MIN-1** | new outcome registers unpinned | **PRESENT — proven** | `BoardDefs.Tests.ps1:64-72` adds both ids to `$PinnedRegisters.outcomes`. **My injection:** flipped `approve-for-merge` → `needs-attention`. Round 1: **11/11 passed** (blind). Round 2: **9 passed / 2 failed**, named — `outcomes.approve-for-merge: expected register 'nominal', found 'needs-attention'`. |
| **MIN-2** | scanner skipped every `SelectorExpr` | **PRESENT — proven both ways** | Narrowed to `isSelector &amp;&amp; sel.Sel.Name == "Code"`. **My round-1 injection re-run** (`Code: time.RFC3339` in `poll.go`): round 1 printed bare `ok`; round 2 → `condition_severity_test.go:138: …board/server/poll.go: a BoardCondition/WireBoardCondition Code field is neither a string literal nor a \`.Code\` field-selector pass-through (found *ast.SelectorExpr)`. **Over-tightening check:** I injected a *different* legitimate pass-through (`Code: pt.Code` from a fresh receiver) → **`ok`**, tolerated. Caught what should be caught, passed what should pass. |
| **MIN-3** | incomplete count disclosure | **PRESENT** | Fix message carries `4f0182d = 66, 9e5261f = 69 (not this commit's own message's "70/70"), b9595b9 = 70 (not "71/71"), 8658011 = 70`. **Matches my independent static re-derivation byte for byte** — `66 / 69 / 70 / 70 / 70`. History correctly **not** rewritten; the wrong figures are named rather than erased. |
| **MIN-4** | ambiguous `x1` counts | **PRESENT** | §12b now states both quantities with units: *"exactly ONE board-condition INSTANCE … the underlying RETURNED RECORDS … numbered **4** (`completed`) and **5** (`approve-for-merge`)"*, and names the dedup site as the reason. Matches `outcomes.json`'s `$comment` and my own round-1 derivation. |

**Nothing DRIFTED.** I specifically hunted the fold-that-looks-folded on MAJOR-1 and MAJOR-2: both amendments preserve the superseded text verbatim rather than paraphrasing it away, and §12b openly names its own round-1 error (*"the round-1 text over-scoped, see below"*) instead of quietly reissuing a clean version — the correct posture under "the showcase never edits the record."

---

## Citation check — every file:line the new prose asserts

| Citation | Verdict |
|---|---|
| `board/fold/algorithm.go:110-122` — kind/outcome only | ✓ exact (`if vocabOk {` at 109; kind 111-116, outcome 117-122) |
| `board/fold/algorithm.go:113,119` — dedup | ✓ exact, both are `if !contains(discoveries, d) {` |
| `board/web/js/compose.js:30-31` — `positionRegister` | ✓ exact |
| `docs/contracts/gating-matrix.md:45` | ✓ still line 45 |
| `board/web/test/vocab.test.js` test name (quoted verbatim) | ✓ matches TAP `ok 70` character for character |
| `board/web/test/render.test.js` test name + `item.stateRegister === 'needs-attention'` | ✓ matches TAP `ok 55` and `render.test.js:217` |
| `schema/vocab/outcomes.json` `$comment` = 4 and 5 | ✓ consistent |
| **`board/web/js/vocab.js:31-37` — `describeVocab`** | **✗ off by 8 — see MIN-A** |

---

## Round-2 findings

### MIN-A — `vocab.js:31-37` is stale at its own commit (two sites)

`docs/design/2026-07-21-v0-yard-skeleton-design.md:499-500` and `docs/design/2026-07-23-ui-mockup-brief.md:93` both cite `board/web/js/vocab.js:31-37` for `describeVocab`. Verified positions:

- at `8658011`: `describeVocab` occupied **31-37** exactly (31 = `export function describeVocab`, 37 = closing `}`)
- at `fdfa80f`: it occupies **39-45**, because **this same commit** added 8 comment lines to `vocab.js`'s header

The citation was written against the pre-fix file and invalidated by the very commit that wrote it — false at the one moment the North Star requires a document to be true. It lands on the JSDoc block, which does state *"unrecognised ids render their raw id as the label (verbatim) with register `needs-attention`"*, so **no reader is misled about substance** — that is why this is Minor and not Major. But it is the exact class this repo already scarred on (`board-defs.json`'s C2R-1: *"a line-number citation here rotted the instant a later commit in this same train inserted `$defs` above it"*), and that scar's own adopted remedy — cite by symbol, not line number — applies verbatim here.

### MIN-B — §6's row 339 left unmarked while Rule 4 got a marker

`design:339` still reads: `Unrecognised kind/outcome/position/role … register needs-attention - a discovery, not a bug`, with no supersession marker. §12b says it supersedes this row "IN PART", and the fix commit applied an inline `[SUPERSEDED …]` marker to Rule 4 at `:184` — but not here, 155 lines earlier in the same file.

Testing the premise rather than assuming asymmetry is a defect: this row is **half true** (`position`/`role` are genuinely unchanged), and §12b names and correctly scopes it, so the document is internally navigable. That distinguishes it from round-1's MAJOR-1, where Rule 4 and the gating matrix stated a false claim with *no* pointer anywhere. But §6 is the failure-modes table a reader actually consults, and for `kind`/`outcome` it states a register the code no longer produces. The fix demonstrated it knows the remedy by applying it upstream; one line closes it. **Minor — fix it for consistency, not a merge blocker.**

*Neither Minor was in my round-1 finding set, so neither is a fix that failed; both are new surfaces the fix opened or left uneven.*

---

## Suites at `fdfa80f` — observed by me

| Suite | Observed | Claimed |
|---|---|---|
| `board` Go, `go test ./... -count=1` | **70/70 pass, 0 fail**, 5 packages | 70/70 ✓ |
| `board/web` `node --test --test-reporter=tap` | `# tests 70 / # pass 70 / # fail 0` = **68 real tests + 2 zero-test support files** | 68/68 ✓ |
| `scripts/tests` | **Total 182, Passed 181, Failed 0, Skipped 1** | "182/182" — total matches; the 1 skip is the known detached-HEAD `run-session-start-guards.sh` (#50) case my brief predicted, not a discrepancy |
| `scripts/store-checks` | **172/172, 0 failed** | 172 ✓ |
| `scripts/probes` | **24/24, 0 failed** | 24 ✓ |

Static re-derivation of `func Test` in `board/**/*_test.go`: `4f0182d`=66, `9e5261f`=69, `b9595b9`=70, `8658011`=70, `fdfa80f`=70.

---

## Regression — nothing I approved in round 1 moved

`git diff --stat 8658011 fdfa80f` → 6 files, 129+/35−. Byte-identity check on every production and test file I cleared in round 1:

```
UNCHANGED  board/store/condition_severity.go        UNCHANGED  board/web/js/render.js
UNCHANGED  board/server/quiet_by_declaration_test.go UNCHANGED  board/web/js/dom-writer.js
UNCHANGED  board/server/poll.go                      UNCHANGED  board/web/css/board.css
UNCHANGED  board/store/store.go                      UNCHANGED  schema/vocab/outcomes.json
UNCHANGED  board/assemble/assemble.go                UNCHANGED  schema/vocab/board-defs.json
UNCHANGED  board/assemble/boarddefs.go               UNCHANGED  board/server/discovery_test.go
UNCHANGED  board/web/test/render.test.js             UNCHANGED  board/web/test/dom-writer.test.js
```

One nuance on the car's "ZERO production code" phrasing: `board/web/js/vocab.js` **is** a production file. Filtering the diff to non-comment changed lines returns **nothing** — every added and removed line begins `//`. So the claim is right in substance and loose in file classification; the mechanical check backs it. My round-1 computed-style gate therefore still stands unchallenged, and I did not need to re-run Playwright: no CSS, DOM, or view-model byte changed.

---

## Convergence ruling

| Round | Majors | Minors | Cluster | Instrument |
|---|---|---|---|---|
| r1 | 3 | 4 | all documentation; zero code defects | correct |
| r2 | **0** | 2 | one new citation-freshness slip, one uneven marker | correct |

**Converging, decisively.** Majors 3 → 0, Minors 4 → 2, and — the sharpest test in the calibration rules — **none of round 2's findings are defects that round 1's fixes created in the place round 1 pointed.** Every round-1 site is now correct; the two Minors are adjacent surfaces, one of them a side effect of the fix growing a file it also cited. Findings shrank *and moved*, which is the signature of convergence rather than swirl. No swirl trigger fires, no cap is warranted, no escalation is owed.

The instrument was also right both rounds: round 1's Majors were all findable by opening a file, and the fix closed them by opening the same files. This was never an instrument-mismatch case.

**Round-2 lesson worth keeping:** the two round-1 Minors that mattered most (MIN-1, MIN-2) were both *guards proven decorative by injection*, and both are now proven live by the same injection re-run. That is the "a guard is unproven until someone has watched it fire" rule paying out twice in one train — round 1 watched them fail to fire, round 2 watched them fire.

---

## Constitution check

| Law | Honored | Evidence |
|---|---|---|
| **Law 1 (no confident falsehood)** | ✓ | The three documents that stated a register the code no longer produces now state it correctly, and the mockup brief agrees with TAP `ok 55`. Residual: §6:339 unmarked (MIN-B), disclosed above. |
| **Documents rank equal to code** | ✓ | A documentation-only commit, gated, injected, and suite-verified exactly as a code commit would be. |
| **Metamorphism, never rewriting in place** | ✓ | Rule 4's original wording preserved with an inline supersession marker; the gating matrix quotes its own superseded rationale; §12b names its round-1 error rather than erasing it. |
| **Showcase never edits the record** | ✓ | MIN-3 carried forward as a correction with both wrong figures named; no `git commit --amend`, no force-push, no history rewrite. |
| **Verification honesty** | ✓ | Every count in the fix message reconciles against my independent re-derivation; the one apparent gap (182/182 vs 181+1) is the documented detached-HEAD skip. |
| **Guards proven by watching them fire** | ✓ | Both tightened instruments injected and observed red by name; the scanner additionally tested for over-tightening. |
| **Law 6 (no second copy)** | ✓ | No new duplication; `BoardDefs` gained two rows in the existing owned table, not a parallel one. |
| **Law 7 (the stranger)** | ✓ | The corrected §12b and mockup brief now let a cold reader tell the server-side board-condition class from the view-side unrecognised-id path — the exact confusion that produced MAJOR-3. |
| **Read-only reviewer** | ✓ | Five injections, five byte-identical reverts verified by hash; `git status --porcelain` empty; HEAD `fdfa80f`; nothing committed, nothing pushed. |

---

**MERGEABLE from `fdfa80f`.** MIN-A and MIN-B are worth a two-line follow-up (cite `describeVocab` by symbol; mark §6:339) and neither blocks the train. I would take this state to `main`.

```starcar-artifact
task-id: view-30-review-r2
outcome: APPROVE
findings: 0 Major, 2 Minor. All seven round-1 findings verified PRESENT, none DRIFTED. MAJOR-1 closed - design Rule 4 at line 184 keeps its original text verbatim with an inline SUPERSEDED marker pointing at 12b, and gating-matrix.md line 45 quotes the pre-issue-30 rationale inside an AMENDED block while correctly severing the never-suppressed guarantee from the register change. MAJOR-2 closed - 12b rescoped to supersede Rule 4 and only IN PART section 6's row, with a dedicated bullet stating position and role are unchanged and render needs-attention via the view-side path; I re-verified the mechanism independently by grepping every Code construction site under board for position or role and finding none. MAJOR-3 closed - the word hot restored in the mockup brief, the amendment rescoped to distinguish the server-side board-condition class from the view-side unrecognised-word path, and the doc now agrees with the test it previously contradicted; vocab.js comment rewritten and the incorrect design S5.2 reference dropped. MIN-1 closed and proven - flipping approve-for-merge to needs-attention now yields 9 passed 2 failed naming outcomes.approve-for-merge exactly, where round 1 observed 11/11 blind. MIN-2 closed and proven both directions - my own round-1 injection of Code taken from a package-qualified constant is now CAUGHT by name naming the file, where round 1 printed bare ok, and a separate over-tightening probe using a different legitimate x.Code pass-through still passes. MIN-3 closed - corrected per-commit counts 66/69/70/70 match my independent static re-derivation exactly, with both wrong figures named and history correctly not rewritten. MIN-4 closed - counts disambiguated with units, one board-condition instance per distinct value versus 4 and 5 underlying returned records, consistent with outcomes.json's own comment. NEW MIN-A - the citation vocab.js:31-37 for describeVocab appears at two sites and is off by 8 lines at its own commit, because the same commit added 8 header comment lines to vocab.js moving describeVocab from 31-37 to 39-45; the cited range lands on the JSDoc which states the same behaviour in words, so no reader is misled about substance, but it is the same rotted-line-number class the repo already scarred on and the adopted remedy is to cite by symbol. NEW MIN-B - section 6's row 339 was left with no supersession marker while Rule 4 at line 184 received one in the same commit; the row remains half true since position and role are genuinely unchanged and 12b names and scopes it correctly, so it is navigable rather than misleading, but it is the one place the fix applied its own remedy pattern unevenly.
abstract: Delta re-review at fdfa80f, parent 8658011, worktree clean before and after with five fault injections all reverted byte-identical by git hash-object. Zero Majors, so this is an APPROVE and the train is MERGEABLE from fdfa80f. Every round-1 finding is genuinely folded rather than cosmetically closed - I hunted the fold-that-looks-folded specifically on the two supersession fixes and found both preserve the superseded text verbatim instead of paraphrasing it away, with 12b openly naming its own round-1 error rather than quietly reissuing a clean version. I re-ran my own two round-1 injections against the tightened instruments and watched both flip from silent-pass to caught-by-name, then added an over-tightening probe proving the scanner still tolerates the legitimate pass-through shape. Suites observed by me at fdfa80f - board Go 70/70 across 5 packages, board/web 68 real tests passing with a TAP aggregate of 70 including two zero-test support files, scripts/tests 182 total 181 passed 0 failed 1 skipped as expected detached, store-checks 172/172, probes 24/24. Static per-commit re-derivation gives 66/69/70/70/70, matching the corrected figures in the fix message exactly. Regression verified mechanically - all fourteen production and test files I cleared in round 1 are byte-identical, and the only production file in the delta, vocab.js, has zero non-comment changed lines, so my round-1 computed-style Playwright evidence stands unchallenged and did not need re-running. Every file:line the new prose asserts was opened and checked; seven of eight resolve exactly and the eighth is MIN-A. Convergence ruling - Majors 3 to 0, Minors 4 to 2, and critically none of round 2's findings are defects that round 1's fixes created at the sites round 1 named; findings shrank and moved, which is convergence rather than swirl, so no swirl trigger fires and no cap or escalation is owed. The two remaining Minors are worth a two-line follow-up and neither blocks the merge.
```