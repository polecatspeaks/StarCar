Status: Current

# PR-18 correctness fixes - the Copilot second-pass train (offset sort + 8 more) [rev 2]

**Review record: round 1 REJECT - 2 Major, 3 Minor, 1 Nit**
(plan adversary, Opus). M1 (F1 left stale in-code comments) and M2 (F5 two-readable +
mis-scoped contract change) folded below with `[PR1-*]` tags; the F1 spine was proven
mechanically correct by probe and F4's placeholder worry was proven empirically MOOT (all
48 records recompute-match the producer's canonicalisation - NO split, NO gap; F4
implements no split). Disposition table at the end.

REQUIRED SUB-SKILL: one car, one adversarial reviewer. Right-sized: this is
coverage-class work (bug fixes + doc truing on a working system) EXCEPT the offset-sort
finding, which touches a format contract (`schema/index-format.md`'s sort rule) and so
gets the executable-spec treatment (a red-first offset-timestamp fixture, the artifact IS
the precision).

Source of the findings: Copilot's second review pass on PR #18 (9 comments, all triaged
LEGIT), landed after the external-review fixes merged. dev is currently RED (the
index-staleness gate correctly firing on the conductor's skipped reconcile). This train
fixes the substance AND reconciles the index, so dev returns to a good known working state
before PR #18 can proceed.

Base: **`687e942d91c34f526904676362a6ea16c4291666`** (local dev HEAD; the Watch-CI tool
commit). Car branch: `car/pr18-correctness-fixes`. Baselines under pwsh 7: tests **90/90**,
probes **12/12**, Verify-Verdict **exit 0, 26 verified** (count floats).

> # BINDING AMENDMENT BLOCK (conductor-applied)
> *Empty at rev 1.*

## Global constraints

Red-first per behavioural fix (quote the observed red WITH conditions - Amendment 1); the
sort fix is a FORMAT change and lands with a conformance fixture; docs same-commit;
honest-stop is SUCCESS; car commits locally, never pushes; new files `#requires -Version 7.4`.

## The ordering constraint (why F1 precedes F2)

F1 changes how `at` sorts; F2 regenerates the committed index. F2 MUST run after F1 so the
regenerated index is both fresh AND correctly sorted - regenerating first would commit a
known-wrong order. The car does F1 then F2.

---

## F1 (SPINE) - offset-aware chronological sort [Copilot: New-ArtifactIndex.ps1:59, Detect-Dispatches.ps1:128/130, :175]

**The defect:** `at` is sorted LEXICALLY (`Sort-Object -Property At` at
`New-ArtifactIndex.ps1:59`; `Detect-Dispatches.ps1:128` latest-`at` winner; `:175` intent
supersession). Lexical order is chronological ONLY for same-offset (Z) timestamps. The
store carries **25 records with `-04:00` offsets** (migrated verdicts, `at` from git
authorship in local time), so `2026-07-22T14:18:03-04:00` (18:18Z) sorts BEFORE
`2026-07-22T16:39:57Z` but is LATER. This corrupts index order, the detector's returned-
winner selection, and intent-hold supersession (a withdrawn hold can win). This is the
unexamined premise behind Car 1's M-A4-1 fix: `-DateKind String` + lexical sort assumed
Z-normalization that the migration then violated.

**The fix:** sort by the parsed INSTANT. Add `Get-AtInstant([string]$at)` to
**`Artifact.psm1`** (module-exported, the ONE owner - Law 6; `Detect-Dispatches.ps1:46`
and `:158` already inline the same `[datetimeoffset]::Parse(...RoundtripKind)` idiom
[PR1-m3], so F1 also repoints those two to the new helper OR states in-comment why `:158`
stays inline - it returns a `DateTimeOffset` for a subtraction, a different shape; the car
picks and discloses). Body:
`[System.DateTimeOffset]::Parse($at, [System.Globalization.CultureInfo]::InvariantCulture,
[System.Globalization.DateTimeStyles]::RoundtripKind).UtcDateTime`. Sort by that instant,
then `subject`, then `file` (total order preserved - `file` is unique per record). Apply
at all three sites (`New-ArtifactIndex.ps1:59`, `Detect-Dispatches.ps1:128`, `:175`).

**[PR1-m1] FAIL LOUD, per record.** `Test-Json` does NOT assert the `date-time` format
(proven by the adversary: a malformed `"not-a-date"` and a zoneless `"2026-07-22T16:39:57"`
both validate). So `Get-AtInstant` must: on a parse failure, THROW an error NAMING the
offending value; and REJECT a zoneless `at` (no `Z`/offset) explicitly rather than parse it
TZ-dependently (which would silently break `New-ArtifactIndex.ps1`'s determinism guarantee).
The generator/detector let that throw propagate as a loud, named failure - never a silent
mis-sort, never a whole-batch crash with no attribution (catch, name the record's file, rethrow).
Red-first cell: a record with a zoneless `at` makes `Get-AtInstant` throw a message naming it.
*(A schema `pattern` constraining `at` to offset-bearing ISO-8601 is the mechanical form -
deferred to an issue, since it touches the schema contract; F1 fails loud in the meantime.)*

**F1 also updates the contract AND the code comments it invalidates [Law: living docs,
same commit; PR1-M1 - round 1 caught F1 leaving these stale, the exact class F7 cleans up]:**
- `schema/index-format.md:46`: "sorted by `at`" → sorted by `at` **normalized to a UTC
  instant** (offsets honored), then subject, then file; one line naming why (mixed offsets).
- **`New-ArtifactIndex.ps1:54-58`**: the comment asserting the *"lexical sort ... IS a
  chronological sort ... only holds because 'at' was never coerced"* is now FALSE (that
  equivalence was the bug). Rewrite it to describe the instant sort.
- **`New-ArtifactIndex.ps1:30-37`**: the `-DateKind String` rationale (*"lexical sort ...
  non-chronological across years without it"*) is stale; true it to the instant-sort reality.

- [ ] **Step 1 - red-first fixture:** add a fixture to `ArtifactIndex.Tests.ps1` (and a
  detector cell to `Detector.Tests.ps1`) with two records whose LEXICAL and CHRONOLOGICAL
  orders DIFFER: `subjX` at `2026-07-22T14:18:03-04:00` and `subjY` at
  `2026-07-22T16:39:57Z`. Assert the index/fold orders them CHRONOLOGICALLY (Y after X in
  time: X is 18:18Z, Y is 16:39Z, so Y sorts FIRST). RUN against the unfixed code, quote
  the red (lexical puts the `-04:00` string before `16:...Z` - wrong). This is the
  offset-timestamp conformance vector the format change requires.
- [ ] **Steps 2-5:** implement `Get-AtInstant`, apply at all three sort sites, update
  `index-format.md`; green; commit `fix(harness): sort at by UTC instant, not lexically - mixed-offset store (#7)`.

**Ledger:** none / none (the index CONTENT reorders but the generator and its staleness
owner are unchanged; note this in the commit).

## F2 - reconcile the committed index [Copilot: the STALE-index CI failure; the blocker]

After F1, regenerate `artifacts/index.md` over the full store so it is fresh AND correctly
sorted, and commit it. This clears the red CI (the staleness gate's `git diff --exit-code`
goes clean). **The car regenerates; the conductor RE-regenerates at merge** (records land
during the car's own cycle - the standing reconcile discipline). State the row count.

- [ ] Regenerate, `git diff --exit-code artifacts/index.md` must be clean after commit;
  commit `fix(harness): reconcile the index over the full store, correctly sorted (#7, #18)`.

## F3 - escape index cell values [Copilot: New-ArtifactIndex.ps1:65]

`$($r.Subject)` etc. are interpolated into a markdown table raw. Open vocabularies mean a
schema-VALID `subject`/`outcome` can contain `|` or a newline, which splits or forges a
table row. **Fix:** escape each cell - replace `|` with `\|` and newlines with a space (or
`&#10;`) before interpolation.

- [ ] **Red-first:** a fixture record whose `subject` contains a `|` produces a broken row
  today (assert the row count / column count is wrong); after the fix the pipe is escaped
  and the row is intact. Commit `fix(harness): escape pipe and newline in index cells (#7)`.

## F4 - CI validates record integrity, not just markdown bodies [Copilot: ci.yml:166]

The index-staleness step regenerates; `Verify-Verdict.ps1` checks only the `.md` bodies;
nothing validates that each `artifacts/**/*.json` record conforms to the schema AND that
its `integrity` hash actually matches its body. **Fix:** a new Pester test
(`scripts/tests/StoreIntegrity.Tests.ps1`) that, for every `artifacts/**/*.json`,
(a) validates via `Test-StarcarArtifact` and (b) recomputes the integrity by the producer's
canonicalisation and asserts it matches the stored `integrity`. It runs in the existing CI
Pester step - no ci.yml change needed (the glob already covers scripts/tests).

**[PR1-M2-adjacent / round-1 ruling: NO SPLIT.** The adversary empirically recomputed all
48 store records (migrated reviews AND producer) under the producer's canonicalisation and
ALL match - the migration used that same canonicalisation, so there are no placeholders and
no gap. F4 recomputes-and-asserts the WHOLE store, no producer-vs-migrated split. **[PR1-m2]
`Get-Sha256Hex` is script-LOCAL in `Produce-Artifact.ps1` (not exported); F4 EXTRACTS it to
a shared module (Law 6, one owner) and both the producer and the test consume it - never a
copy.**

- [ ] **Red-first:** corrupt one record's integrity in a fixture copy → the test fails;
  restore. Commit `test(harness): CI validates every store record schema + integrity (#7)`.

## F5 - envelope read-failure is not a brief-failure [Copilot: Produce-Artifact.ps1:153]

`Get-LastAssistantText` reports missing/unreadable/unparseable transcripts via `Errors`,
but `:153` DISCARDS those errors (`.Text` only) and classifies EVERY read failure as
`envelope: absent` (a BRIEF failure - the agent emitted no envelope). Two bugs in one: the
errors are DROPPED (Law 4 violation - the actual core of Copilot's finding), and a
PRODUCER-side read failure is blamed on the brief.

**CONDUCTOR RULING [PR1-M2] - NO SCHEMA CHANGE; the `envelope` closed enum stays
`{absent, malformed}`.** Round 1 correctly flagged that "use an existing value" defeats the
fix and "add a value" is a closed-enum contract change mis-filed as coverage-class. Ruled:
the distinction is carried WITHOUT touching the enum. A returned record whose transcript
CANNOT BE READ is not "we read it and found no envelope" (`absent`) - it is a producer
fault, so:
- **OMIT the `envelope` field entirely** (it is optional; absent-the-field ≠ the value
  `absent`), set `outcome: error`, and put the read error in `findings`;
- **RAISE the error to `_faults.log`** (Law 4 - fixes the drop);
- A brief-absence (transcript read OK, no fence) keeps `envelope: absent` as today.
A consumer distinguishes them cleanly: `envelope=absent` = brief failure; `envelope` field
missing + `outcome=error` + a `_faults.log` line = producer read failure. No closed-contract
widening, no spec §2.3/§9 edit, stays coverage-class. *(A dedicated `envelope: unreadable`
value is a possible future schema enhancement - DEFERRED to an issue with the executable-spec
track, NOT done here.)*

- [ ] **Red-first:** a returned payload pointing at a NONEXISTENT transcript today lands
  `envelope: absent` (brief blamed) AND silently drops the read error; after the fix it
  lands `outcome: error`, NO `envelope` field, the read error in `findings`, and a
  `_faults.log` line. Assert both the classification AND that the error is no longer
  dropped. Commit `fix(harness): producer read-failure is not an absent envelope; stop dropping the error (#7)`.

## F6 - README status truth [Copilot: README.md:8]

`README.md:8` reads *"First design under adversarial review. Nothing runs yet — there is
no code"*. This PR makes it false: the schema validator, detector, producer hooks, and 90
tests all RUN. **Fix:** update the status to distinguish the now-running harness substrate
from the still-unbuilt yard board (true-always: name what runs vs what is still planned; do
NOT claim the board renders anything - board consumption is #1). Sentence-check the exact
replacement against what exists.

*(NOT in scope, resolves itself: the owner noted `main`'s README still says the
constitution is "DRAFT until ratified". That is already fixed on `dev` - line 52 reads
"RATIFIED 2026-07-21" - and `main` is 138 commits behind BY DESIGN, held until PR #18
lands from a green dev. Branch topology working as intended; the merge trues main.)*

- [ ] The red is the reviewer's sentence check (prose). Commit
  `docs: README status - the harness runs now; the board is still #1 (#18)`.

## F7 - state-ledger staleness-owner is armed, not "not yet" [Copilot: state-ledger.md:66]

Row 66 still says the index staleness owner is "not yet - CI regenerate-and-diff gate lands
as Car 3's next task (C.2)" - but C.2 LANDED the gate; ci.yml regenerates and diffs the
index now. Car 3's C.2 was the commit that invalidated this and did not true it (a
living-contracts miss its own reviewer also missed). **Fix:** flip the staleness owner to
ARMED, naming the ci.yml step as the evidence.

- [ ] Same-commit doc truth. Commit `docs(contracts): index staleness gate is ARMED, not pending (#7, #18)`.

## Handback (conductor, after merge)

1. Re-regenerate the index over the MERGED store (review-cycle records land during the
   car's own run) and commit before pushing - the standing reconcile.
2. **Push, then `scripts/Watch-CI.ps1 -Branch dev` to a RECORDED terminal GREEN** - no
   "done" without it (the scar this train's sibling tool was built for).
3. Only then does PR #18 proceed to its re-review + the owner's merge ruling.

## Spec-coverage / finding map

| Copilot finding | Fix |
|---|---|
| New-ArtifactIndex sort lexical | F1 |
| Detect-Dispatches latest-at lexical | F1 |
| Detect-Dispatches intent supersession lexical | F1 |
| stale committed index (CI red) | F2 |
| index cell markdown injection | F3 |
| CI never validates JSON record integrity | F4 |
| envelope read-failure misclassified absent | F5 |
| README status stale | F6 |
| state-ledger staleness-owner stale | F7 |

## Round-1 finding disposition [the carrier the delta walks]

| ID | Finding | Disposition in rev 2 |
|---|---|---|
| PR1-M1 | F1 left stale in-code comments (New-ArtifactIndex.ps1:54-58, :30-37) | Folded: F1's same-commit doc-set now enumerates both, alongside index-format.md:46 |
| PR1-M2 | F5 two-readable + mis-scoped closed-enum contract change | Folded: conductor ruling - NO schema change; omit envelope field + outcome:error + _faults.log; dedicated value deferred to an issue |
| PR1-m1 | F1 crashes/mis-sorts on schema-valid malformed/zoneless `at` | Folded: Get-AtInstant fails LOUD per record (throws naming the value, rejects zoneless); schema pattern deferred to an issue |
| PR1-m2 | F4 Get-Sha256Hex script-local | Folded: F4 EXTRACTS it to a shared module (Law 6) |
| PR1-m3 | Law-6 parse-idiom duplication (Detect-Dispatches:46/158) | Folded: F1 repoints to Get-AtInstant or discloses why :158 stays inline |
| PR1-Nit | F6 abbreviated quote | The car sentence-checks the full README:8 line |
| — | F4 placeholder worry | Ruled MOOT by the adversary's recompute (all 48 match); F4 implements NO split |

## The plan-review record (rule 5)

Round 1: **REJECT - 2 Major, 3 Minor, 1 Nit** (Opus plan adversary). The F1 spine was
proven mechanically correct (DateTimeOffset round-trips both forms; three sort sites
correct; F1-before-F2 ordering correct) and F4's placeholder worry proven empirically moot.
Rev 2 folds all findings per the table. Round 2 is a delta to the same adversary.
