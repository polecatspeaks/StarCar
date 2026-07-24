<!-- starcar-integrity: sha256=69db1841cd053c76bf0bfdfbb1f33a1f49209527a59b908589aeea3fe68ddd11 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Yard board Car 3 review round 1: REJECT - the two fold bodies diverge on budget-less dispatches (constructed and reproduced); carve-out premise ruled false; remedy escalated to owner

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (adversarial, Opus, fresh detached worktree)
Round: 1
Target: `car/board-car3 at 330ddf9 (5 commits)`
Base reviewed: `330ddf9f3381b5d4e87d0b03ee7e694a2bb7c1df`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `ae55c4d7156cb410b`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `330ddf9f3381b5d4e87d0b03ee7e694a2bb7c1df` |

| Dispatch, the locator within the session | `ae55c4d7156cb410b` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 330ddf9f3381b5d4e87d0b03ee7e694a2bb7c1df
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Tree clean, HEAD intact at 330ddf9. All fault-injection restored byte-identical. Here is my verdict.

---

# ADVERSARIAL REVIEW - Car 3 (the Fold Car), yard-board train

## VERDICT: REJECT

Base verified: worktree HEAD = `330ddf9f3381b5d4e87d0b03ee7e694a2bb7c1df`, detached, clean before and after all fault-injection. Diff scope `896e10e..330ddf9` (5 commits: 153eec3, 1290275, a64e45f, 5b4cd96, 330ddf9).

One Major (C3R-1, the centerpiece). Any Major = REJECT. This is a REJECT of a well-crafted, honestly-disclosed body of work: every suite is green, the Go fold is correct and idiomatic for what it covers, the rehome loses no semantic, and the divergence at issue was disclosed by the car in precise detail. The REJECT is because the disclosure stopped one step short of the durable carrier the constitution requires, and the consequence is a fold divergence that WILL ship into Car 4's server invisibly. The root-cause premise is inherited from the spec/plan carve-out, and surfacing that false premise is a success outcome for the process.

---

## THE CENTERPIECE RULING (C3R-1, MAJOR): (b) - two fold bodies disagree on real-store-shaped data, invisibly to the cross-verifier, with no carrier to resolve it

I constructed the divergent case and ran BOTH implementations on byte-identical input. Input: one dispatched record, no `budget` field (schema-valid - `budget` is optional), `at`=2026-07-20T00:00:00Z, now=2026-07-23T00:00:00Z (elapsed 259200s, far past the 1800s shop default), no successor. Complete vocab.

- pwsh detector (`scripts/Detect-Dispatches.ps1`, applies shop default at :215): `state="overdue"`, `budget_seconds=1800.0`, `elapsed_seconds=259200`
- Go `Fold` (`board/fold/algorithm.go`, no default threading): `state="dispatched"`, `budget_seconds=null`, `elapsed_seconds=259200`

The two "conforming" implementations disagree on BOTH the rendered `state` (overdue vs dispatched) and `budget_seconds` (1800 vs null) for a normal, schema-valid record shape.

**Why this is a Major, evidenced hop by hop:**

1. **It is real, not hypothetical.** A budget-less dispatched record is the NORMAL record shape - the shop default exists precisely because records do not carry their own budget (`config/harness-defaults.json`: "The detector applies dispatch_budget_seconds at FOLD time when a record carries no budget of its own; absent never means infinite"). The record I built is byte-shaped like a real dispatch.

2. **It defeats the one killed-dispatch surface.** Design S3.3 + Probe 1 (quoted in `Detect-Dispatches.ps1:28-29`) establish the budget/overdue path as "the ONLY way a killed dispatch (which fires no stop hook) is ever surfaced." The Go fold is the SERVER's fold (plan §5 "Car 4 ... Consumes: car 3's fold package"; §8 interface block "fold to assembler ... car 3's package API returns exactly it"). So a real dispatch that dies budget-less renders "dispatched" (alive, in-flight) on the board forever, while the pwsh detector - which remains the CI cross-check and what a conductor runs by hand - calls it "overdue." That is a Law 1 confident-falsehood on the board's most safety-relevant surface.

3. **The cross-verifier is blind to it by construction - proven.** I confirmed structurally that all three vectors producing a lone-dispatched winner (`dispatched-past-budget-overdue`, `dispatched-within-budget-stays-dispatched`, `record-budget-overrides-shop-default`) carry an explicit record-level `budget` in input. NO vector exercises a budget-less lone-dispatched record. The shop-default to overdue semantic is therefore outside 100% of vector coverage, so the D18 cross-verifier stays green while the two bodies diverge. The D18 single-truth thesis ("both conforming to the same fixture transitively proves they conform to each other," ci.yml:238) is defeated on exactly this case.

4. **No binding carrier resolves it downstream - I read all three candidate carriers:**
   - Plan §5 (Car 4 tasks 4.1-4.4): the word "budget" does not appear. No threading obligation.
   - Plan §8 interface block: the fold to assembler contract IS "the same vectors" - definitionally the surface that cannot see this semantic.
   - Spec 7b.1 amendment (line 200) and plan 3.1: only carve it OUT, calling it "environmental/pwsh-IO."
   - No issue was filed. `LoadDefaultBudget` exists in `loaders.go:55` but is called by nobody and carries only the IO-read half, not the apply-and-render-overdue semantic.

   The obligation lives ONLY as prose in `fold.go:11-23` ("a decision for whichever caller needs it - out of scope here"). Per the constitution's carrier rule ("Anything not written into the next rung's input document does not exist there. The receiving side is built to refuse delivery without it"), that obligation does not exist at Car 4's rung. This is precisely the vigilance-tier memory the rule forbids. Option (a) - acceptable-with-a-mandatory-named-follow-up - has an UNMET precondition: there is no mandatory named follow-up carrier. So (a) is unavailable and the ruling is (b).

**Root cause, blameless and precise:** the spec 7b.1 amendment and plan 3.1 MISCLASSIFIED the shop-default case as "environmental/pwsh-IO, not a language-neutral fold semantic," lumping it with three genuine IO/excluded-field cases. Reading `config/harness-defaults.json` is IO; applying its value to render `overdue` is a fold SEMANTIC that changes rendered state, as my two runs prove (an IO error would be a fault string; this is a state divergence). The "own-idiom equivalent" the spec mandated was satisfied only for the IO-read half (`LoadDefaultBudget`); the semantic half has no Go equivalent, no vector, and no carrier. That premise is empirically false, and the constitution codes surfacing a false premise as a success outcome.

**Remedy (escalation to conductor/owner, because it reverses a ratified carve-out - reviewer names options, does not pick):** EITHER (i) kill the carve-out: extend the vector `input` shape to carry an optional shop default, add a vector pinning budget-less-past-default to overdue, and thread a default into the Go fold (options param, or a Car 4 pre-application step) so the cross-verifier can SEE the semantic; OR (ii) keep Fold pure and land a BINDING carrier - a Car 4 task-row REQUIRING the server to pre-apply the shop default to budget-less dispatched records before calling Fold, with its own red-first test, PLUS a tracked issue. Either way the train must not merge with the divergence uncarried.

---

## CLAIMS VERIFIED (all RUN by me at HEAD)

- **Suites:** pwsh `scripts/tests` = 217/217 passed, 0 inconclusive, 0 skipped; `scripts/probes` = 12/12. Board `go test .` = 6/6. `go test ./fold/` = 3 loader subtests + TestFoldConformsToVectors with **15** vector subtests all PASS (the car's report said "14"; I observed 15 - a miscount UNDER-stating coverage, not a defect). `go vet ./...` clean (exit 0); `gofmt -l` empty. Real-store detector at HEAD: faults=0, discoveries=0, dispatches=49, intents=1. (Go 1.26.5, Pester 5.8.0, pwsh 7.6.3.)
- **Rehome arithmetic (item 2):** 15 It cases at base 896e10e. 4 carved (shop-default :102, unreadable-vocab-dir :155, unreadable-defaults :163, tier :170) still present imperatively at HEAD; 11 rehomed + 4 carved = 15. The 12th new vector (`unrecognised-outcome-discovery-by-name`) is a net-new uncovered semantic, correctly labeled. Deep spot-check of 6 rehomed vectors (precedence, two-returned, dispatched-past-budget, record-budget-overrides, spend, later-intent) against their base It bodies: each vector pins the SAME behavior the imperative case pinned, generally MORE fully (superseded/spend fields the old It sometimes omitted). No semantic lost - Law 4 honored.
- **Provenance (item 3):** all 15 vectors carry OBSERVED (14) or DESIGN-MANDATED (1, empty-vocab) per the README rule. I independently reproduced `dispatched-past-budget-overdue` via the pwsh detector: state=overdue, elapsed=7200, budget=60.0 - deep-equals expected. The full 217-green pwsh runner reproduces all OBSERVED expected blocks.
- **Task 3.2 empty-vocab fix (item 4):** fault-injected empty vocab against the fixed detector - exactly one fault `vocabulary: valid but empty: kinds.json, outcomes.json`, zero discoveries. Real-store parity base(896e10e) vs fixed: identical field counts (0/0/49/1), dispatches and intents byte-identical (SHA-256 compared). Claim IDENTICAL holds.
- **Item 6 cross-verifier:** injected budget 60 to 61 in a vector; Go runner FAILED (`-count=1`, named the field mismatch) and pwsh runner Failed=1 - both catch divergence. Restored byte-identical, SHA-256 `962f853d...aabf3c` matched. `-count=1` present and documented on the D18 go test invocation (ci.yml:269, :261-268). Zero-vector refusal fires (ci.yml counting expression on an empty dir yields count=0 to build-fail; Go guard `len(files)==0` to `t.Fatalf`).
- **Item 7 substrate discoveries:** Pester v5 discovery/run scope boundary documented at `Detector.Tests.ps1:40-49`; Go test-cache staleness documented at `ci.yml:261-268`. Both landed.
- **Law 1 Inconclusive lifecycle:** `empty-vocab-one-fault` was `Set-ItResult -Inconclusive` at 153eec3 (known-wrong, red-on-arrival, 1 occurrence) and retired at HEAD after the 3.2 fix (0 inconclusive). Honest lifecycle.

## DOC CHECK

- README vector table: 15 rows, 15 files on disk (counted from disk). Table updated in the SAME commit as the vectors (153eec3: README +12 rows alongside the vector files and the runner rewrite). Same-commit doc discipline honored.
- ci.yml: the two same-named "Car 3 additions" blocks are disambiguated (ci.yml:48-50 explicitly names the harness-train Car 3 vs the yard-board Car 3). 330ddf9's ci.yml change is scoped to only the disambiguation header + the D18 step.
- Detector.Tests.ps1 header rewritten for its new runner role (`:6-49`), including the carved-4 enumeration.

## GUARD CHECK (deferred)

The LIVE watched-to-fire cross-verifier divergence injection is deferred to the conductor at merge (ci.yml:57-60, plan §7). This is a legitimate D10 handback - but note it is deferred at the LEVEL that cannot catch C3R-1: the live injection mutates a vector, and no vector exercises the budget-less case. The guard, when fired, will prove the cross-verifier catches vector divergence; it will NOT surface the semantic divergence this review found, which is the point of C3R-1.

## MINOR FINDINGS (non-blocking; recorded)

- **C3R-2 (Minor):** exact-equal-instant tie-break. Go uses `sort.SliceStable` (input order). pwsh `Sort-Object` at :183-188/:241-244 omits `-Stable`; PowerShell docs do not guarantee stability without it. I probed pwsh 7.6: on 8 equal keys it preserved input order, so they agree TODAY, but pwsh relies on undocumented behavior and no vector pins the tie. Divergence would require two same-(subject,kind,instant) records differing in outcome/cost/budget - rare, but unpinned. Recommend adding `-Stable` to the pwsh sorts or a vector pinning the tie.
- **C3R-3 (Minor):** `parseInstant` (`algorithm.go:28-38`) silently degrades a malformed `at` to the Unix epoch, whereas pwsh throws loud attributed to the subject - a second disclosed silent divergence. Lower risk than C3R-1 because Car 4's store adapter is expected to schema-quarantine a malformed `at` before Fold sees it - but that defense is assumed, not carried by any current contract row.

## CONSTITUTION CHECK

- **Law 6 (vectors as single authority):** VIOLATED at C3R-1 - the Go port re-encodes the liveness/budget semantic INCOMPLETELY (no shop-default), a semantic OUTSIDE all vector coverage, and the two implementations diverge on it (reproduced: overdue vs dispatched). This is the exact "re-encode a semantic outside vector coverage" the brief flagged.
- **Law 4 (nothing silently lost in the rehome):** HONORED - 4 carved cases still green imperatively, 11 rehomed vectors deep-match old bodies, arithmetic 11+4=15, README same-commit.
- **Law 1 (unknown/marker honesty):** the Inconclusive marker lifecycle is HONORED. BUT Law 1 is IMPLICATED by C3R-1: the server's board would render a dead budget-less dispatch as "dispatched" (alive) - a confident falsehood on the liveness surface.
- **Carrier rule:** VIOLATED at C3R-1 - the follow-up obligation lives only in a package-doc comment, not in Car 4's input document, with no ID and no issue.

```starcar-artifact
outcome: REJECT
findings: One Major (C3R-1, the centerpiece), two Minors (C3R-2, C3R-3). C3R-1 - I constructed the divergent case and ran both fold bodies on byte-identical schema-valid input (budget-less dispatched record, elapsed 259200s past the 1800s shop default, no successor). pwsh detector renders state=overdue budget_seconds=1800; Go Fold renders state=dispatched budget_seconds=null. The two implementations disagree on the liveness gradient (the only killed-dispatch surface per design S3.3 and Probe 1) for a normal record shape. The Go fold is the server's fold that Car 4 consumes, so the board would assert a dead dispatch is alive (Law 1). The divergence is invisible to the D18 cross-verifier by construction - I confirmed all three lone-dispatched vectors carry an explicit record budget, so no vector exercises the shop-default path (Law 6). No binding carrier resolves it downstream - plan section 5 has no budget obligation, section 8 defines the interface as the vectors themselves, spec 7b.1 only carves it out, and no issue was filed; the obligation lives only as prose in fold.go. Option (a) acceptable-with-mandatory-follow-up is unavailable because the mandatory follow-up carrier does not exist. Root cause is an inherited false premise - spec 7b.1 and plan 3.1 misclassified a fold semantic (apply default then render overdue, a state change) as environmental pwsh-IO (a fault string). Remedy escalates to conductor/owner - either kill the carve-out with a default-carrying vector plus threading, or land a binding Car 4 task-row plus red-first test plus issue. C3R-2 - exact-equal-instant tie-break relies on pwsh Sort-Object stability not guaranteed without -Stable while Go uses sort.SliceStable; agree empirically today, unpinned by any vector. C3R-3 - parseInstant silently degrades malformed at to Unix epoch while pwsh throws; defended only by an assumed upstream quarantine. All verified claims passed - Pester 217/217 with 0 inconclusive, board go 6/6, fold 3 loader plus 15 vector subtests (report said 14), go vet clean, gofmt empty, real-store 49 dispatches 1 intent 0 faults 0 discoveries, base-vs-fixed detector parity byte-identical on dispatches and intents, empty-vocab fix emits one combined fault and zero discoveries, injected-divergence caught by both runners with SHA-256 byte-identical restore, zero-vector refusal fires, both substrate discoveries documented, Inconclusive marker retired honestly after the 3.2 fix, README table updated same-commit, ci.yml Car 3 blocks disambiguated. Law 4 honored, Law 1 marker-lifecycle honored, Law 6 violated at C3R-1, carrier rule violated at C3R-1.
abstract: Car 3 (the fold car) is REJECT on one Major. The Go fold port omits the pwsh detector's shop-default budget fallback, producing a reproduced divergence on real-store-shaped data - a budget-less dispatched record past 1800s renders overdue in pwsh but dispatched-forever in Go, on the liveness gradient that is the only killed-dispatch surface. The Go fold is the server's fold, the divergence is invisible to the D18 cross-verifier because no vector exercises the budget-less lone-dispatched case, and no binding carrier forces the fix at Car 4 or anywhere - it lives only as a package-doc comment. Root cause is an inherited false premise from spec 7b.1 and plan 3.1 that misclassified a fold semantic as environmental IO; surfacing it is a success outcome. All other claims verified green by direct execution; the rehome loses no semantic and the empty-vocab fix is correct. Remedy escalates to the owner because it reverses a ratified carve-out.
```