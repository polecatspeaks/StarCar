Status: Current

# PR-18 correctness fixes - the Copilot second-pass train (offset sort + 8 more)

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

**The fix:** sort by the parsed INSTANT. A helper (put it in `Artifact.psm1` or a small
shared spot the car chooses, exported, tested):
`Get-AtInstant([string]$at)` returns `[System.DateTimeOffset]::Parse($at,
[System.Globalization.CultureInfo]::Invariantculture,
[System.Globalization.DateTimeStyles]::RoundtripKind).UtcDateTime`. Sort by that instant,
then `subject`, then `file` (total order preserved). Apply at all three sites.

**F1 also updates the contract [Law: living docs, and match-the-instrument]:**
`schema/index-format.md:46` currently reads "sorted by `at`, then `subject`, then `file`".
Change to state the sort key is `at` **normalized to a UTC instant** (offsets honored),
then subject, then file - and add one line naming why (mixed offsets in the store).

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
Pester step - no ci.yml change needed (the glob already covers scripts/tests). [Note: the
migrated records used a PLACEHOLDER integrity (`sha256:` + zeros or the migration's
computed value) - the car must check what the migration actually wrote and, if placeholders,
scope the recompute assertion to producer-written records and validate-only the migrated
ones, disclosing the split. RUN and find out before asserting.]

- [ ] **Red-first:** corrupt one record's integrity in a fixture copy → the test fails;
  restore. Commit `test(harness): CI validates every store record schema + integrity (#7)`.

## F5 - envelope read-failure is not a brief-failure [Copilot: Produce-Artifact.ps1:153]

`Get-LastAssistantText` reports missing/unreadable/unparseable transcripts via `Errors`,
but `:153` discards `.Text`'s companion errors and classifies EVERY read failure as
`envelope: absent` (a BRIEF failure - the agent emitted no envelope). A producer-side read
failure (transcript missing/unreadable) is a PRODUCER fault, not the brief's. **Fix:**
capture `Get-LastAssistantText`'s full result; when it errors, classify
`outcome: error, envelope: <a producer-fault value>` distinct from `absent`, raising the
error to `_faults.log` (Law 4). Confirm the schema's `envelope` field permits the value
(spec §2.3 names `absent`/`malformed`; a producer-read fault may need a third value -
check the schema/vocab and either use an existing value with the fault in findings, or
propose the addition in the commit; do NOT silently widen the schema).

- [ ] **Red-first:** a returned payload pointing at a NONEXISTENT transcript today lands
  `envelope: absent` (brief blamed for a producer failure); after the fix it lands the
  producer-fault classification with the read error in findings/_faults.log. Commit
  `fix(harness): distinguish producer read-failure from an absent envelope (#7)`.

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

## The plan-review record (rule 5)

*Pending - plan adversary (Opus). Plan-writer evidence at base (conditions stated): the
three Sort-Object sites read at base; 25 offset timestamps counted in the store; the
state-ledger:66 and README surfaces read; the envelope :148-158 and index :64-66
interpolation read. The adversary re-verifies and especially challenges F1's
`DateTimeOffset.Parse` shape (does it round-trip every `at` the schema accepts? does the
detector's OTHER sort at :128 use the same key?) and F4's placeholder-integrity caveat.*
