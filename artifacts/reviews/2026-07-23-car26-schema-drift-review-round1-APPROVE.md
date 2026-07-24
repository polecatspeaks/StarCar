<!-- starcar-integrity: sha256=298ea143a2c391ef37572c8ff614d9e271e630ea83efd8d4818366a91fd4c784 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car 26 (#26 model/body_file schema drift) adversarial sentence-check review, round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-review
Round: 1
Target: `car/26-schema-drift @ d0d9d77ef305ff6f13c28e6c48825c01d25b47b8`
Base reviewed: `38b67c8c0b9f75099aa334a5cf2af340c810920d`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a5d6678f863493256`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `38b67c8c0b9f75099aa334a5cf2af340c810920d` |
| Entire checkpoint | `2db32c0780b4` |
| Dispatch, the locator within the session | `a5d6678f863493256` |
| Entire session (context, NOT a lookup key) | `e92f5a0b-1b9e-4913-98b3-c319b4d5e90b` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 38b67c8c0b9f75099aa334a5cf2af340c810920d
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Everything verified. Cleaning state confirmed; composing the verdict.

---

# ADVERSARIAL REVIEW — Car 26 (issue #26), round 1

# VERDICT: **APPROVE**

**0 Major · 2 Minor · 3 Note.** Both commits are sound. Every empirical claim in the car's report re-derived exactly — including the one number I expected to drift. The detector was not weakened; I watched it fire.

---

## 1. Base, scope, integrity

| Check | Observed |
|---|---|
| Worktree HEAD | `d0d9d77ef305ff6f13c28e6c48825c01d25b47b8` ✓ |
| Tree at start / end | `faead79d1c9e810fa14e6291a80a2251c8d784db` (identical) ✓ |
| `git status --porcelain` / `git diff HEAD` | empty at start and end ✓ |
| Diff vs `38b67c8` | exactly 7 files, +96/-1 ✓ — nothing outside scope |
| Shared checkout `<repo>` | `f358cad`, clean — never written to (read-only scan of `artifacts/` only) |

Fault injection was done on a scratch copy at `.../scratchpad/gored` (deleted) and on `.../scratchpad/schematest` (deleted); the one in-worktree operation was `git checkout 38b67c8` → run → `git checkout d0d9d77`, proven byte-identical by the tree hash above.

---

## 2. Suites — RUN MYSELF, observed counts at `d0d9d77`

| Suite | Command | Observed |
|---|---|---|
| Go | `&amp; 'C:\Program Files\Go\bin\go.exe' test ./... -count=1` from `board/` | **5/5 packages ok** (`board`, `board/assemble`, `board/fold`, `board/server`, `board/store`) |
| Node | `node --test` from `board/web` | **tests 50, pass 50, fail 0** |
| Pester | `Invoke-Pester -Path scripts/tests` | **249 passed, 0 failed, 0 skipped** |
| Pester **baseline** at `38b67c8` | same command, own checkout | **247 passed, 0 failed** |

**The arithmetic is verified, not asserted: 247 + 2 = 249.** The +2 are the two new conformance vectors (Artifact.Tests.ps1 is `-ForEach`-driven over `schema/vectors/*.json`).

`scripts/probes` was not run — outside the brief's stated suite scope. I make no claim about it.

---

## 3. THE DETECTOR STILL FIRES — watched, not assumed

`board/store/store.go:293-307` (the unknown-field diff and the `record-unrecognised-fields` condition) is **byte-untouched** by the diff. The diff adds two struct fields at `:115-116` and comment text at `:93-99`. Nothing filtered, nothing downgraded.

Fault injection, scratch copy, a record carrying **both** newly-declared fields plus two junk fields:

```
OBSERVED CONDITION: subj/dispatched-1.json: record carries 2 unrecognised field(s):
  another_junk, totally_new_junk | register=needs-attention
```

Register still `needs-attention`; the declared fields did **not** leak into the disclosure; both junk fields named. The allowlist grew by exactly two names. The pre-existing pin `TestScanUnknownFieldRecordDisclosed` (`board/store/store_test.go:151-190`, `surprise_field`) also passes at HEAD. **Law 1 / Law 4 honored.**

---

## 4. RED EVIDENCE — both re-derived, both for the stated reason

**Go side.** Scratch copy, both struct fields removed (pre-fix state):

```
--- FAIL: TestScanKnownProducerFieldsNotUnrecognised
    store_test.go:394: ... got {record-unrecognised-fields dispatched-subj/dispatched-1.json:
    record carries 1 unrecognised field(s): model needs-attention}
```

Matches the commit message verbatim (`"record carries 1 unrecognised field(s): model"`).

**Schema side.** At `38b67c8` with only the four new vector files injected (schema unchanged, no `model`/`body_file` properties):

```
FAILED: vector invalid-body-file-wrong-type.json validates as invalid
  MSG: Expected $false, but got $true.
FAILED: vector invalid-model-wrong-type.json validates as invalid
  MSG: Expected $false, but got $true.
```

Verbatim match. Both vectors were **valid** at base, which proves the invalidity at HEAD is isolated to the type declaration and nothing else — clean vector design.

**Prior-art claim VERIFIED by opening it.** The instrument really did exist at base: `git ls-tree 38b67c8 schema/vectors/` shows 11 pre-existing `.json` + `.expect` pairs; `scripts/tests/Artifact.Tests.ps1:3-9` globs them in `BeforeDiscovery` and `:20-24` runs each through `Test-StarcarArtifact`, which is at **`scripts/Artifact.psm1:20`** exactly as claimed. The car extended an instrument; it did not invent a framework.

---

## 5. NON-VACUITY — I tried to make each guard pass with the defect present

| Attack | Result |
|---|---|
| Go test with only `model` declared | **FAIL** — `record carries 1 unrecognised field(s): body_file` |
| Go test with only `body_file` declared | **FAIL** — `record carries 1 unrecognised field(s): model` |
| Schema vectors under a `"type": "boolean"` mutant | **PASS** — the vectors survive. They pin *"not a number"*, not *"is a string"*. |
| Go test under the `"type": "boolean"` mutant | **FAIL** — `expected both records to survive, got 0` |
| `StoreIntegrity.Tests.ps1` under the `"type": "boolean"` mutant | would go **RED on 56 committed records** (measured) |

Both halves of the Go test are independently load-bearing. The positive shape (*a string is accepted*) **is** pinned — by `board/store/store.go:266`'s schema-validate-or-quarantine reached through the Go test's survival assertion, and by `scripts/tests/StoreIntegrity.Tests.ps1:44-45`, which schema-validates every real store record. See NOTE-1: that coverage is real but incidental.

---

## 6. THE EMPIRICAL CLAIM — re-derived, and the discrepancy story is TRUE

Scanning the **live** store read-only via the store adapter:

| | records | quarantined | `record-unrecognised-fields` |
|---|---|---|---|
| **AFTER** (HEAD `store.go`) | 115 | 0 | **0** |
| **BEFORE** (both struct fields removed) | 115 | 0 | **58** → `model` 33, `body_file` 25 |

**After-count is 0.** No remaining field names to report.

Now the adjudication of deviation **(a)** — and this is where the car's disclosure earns its keep. I scanned the *committed tree at `d0d9d77`* separately:

```
worktree (commit d0d9d77) store records: 112
  carrying model    : 31
  carrying body_file: 25   -&gt; 56
```

**31 + 25 = 56 — the car's number, exact, reproducible from the commit itself.**

| Measurement | total | `model` | `body_file` |
|---|---|---|---|
| Issue #26 (verified via `gh issue view 26`: "52 … model (27 records) … body_file (25 records)") | 52 | 27 | 25 |
| Car, at `d0d9d77` (I reproduce exactly) | 56 | 31 | 25 |
| Me, live store, now | 58 | 33 | 25 |

**`body_file` is CONSTANT at 25 across all three.** That is the corroborating detail that makes the explanation *true* rather than merely plausible: `body_file` is written only by `Migrate-Verdicts.ps1` (a one-time historical migration, so it cannot grow), while `model` is written on every new dispatch and grows 27 → 31 → 33. My own review dispatch is part of that growth. **(a) ADJUDICATED TRUE**, independently corroborated, not accepted on the car's word.

---

## 7. THE SENTENCE CHECK — every hop, file:line

**`model`, producer → terminus:**

1. **Source** — `scripts/Produce-Artifact.ps1:204` `$model = Get-Prop $toolResponse 'resolvedModel'`, from the `PostToolUse:Task` payload. Landed probe backing it: `docs/probes/2026-07-22-spec7-probe-results.md:110` ("`resolvedModel` is present at launch"). Fixture: `scripts/tests/fixtures/payloads/launch-car.json:1` carries `"resolvedModel": "claude-sonnet-5"`.
2. **Write** — `scripts/Produce-Artifact.ps1:285` `if ($Kind -eq 'dispatched' -and $model) { $record['model'] = $model }`, positioned between `budget` (`:284`) and `producer` (`:286`).
3. **Hashed** — `:289-290`, inside the integrity body in its written position.
4. **On disk** — 33 live records, **all String**. Values: `claude-opus-4-8[1m]`×18, `claude-sonnet-5`×11, `claude-opus-4-8`×3, `claude-haiku-4-5-20251001`×2. (A 35th grep hit is prose inside two `.md` verdicts, not a record field — reconciled.)
5. **Schema** — `schema/starcar-artifact.schema.json:68-71`, `"type": "string"`. `additionalProperties` appears **0 times** in the file, so the open posture is intact.
6. **Store typed decode** — `board/store/store.go:115` json tag → `buildTypedKeys()` `:127-138` reflects it → `typedKeys` `:125` → the diff at `:293-298` no longer flags it.
7. **Store generic decode** — `:246-249`; the **value** survives into `Record.Fields` independently of `typedRecord` (pinned at `store_test.go:385-387`).
8. **Validation gate** — `:266`; a non-string `model` would now quarantine (`:267`), disclosed as `record-quarantined`/`needs-attention` (`:190-194`) — louder, never silent.
9. **Terminus — the field STOPS AT THE STORE.** Zero consumers in `board/**/*.go`, `board/web/**/*.js`, `board/web/**/*.html` (the `board/web` "model" hits are *"view model"* prose at `render.js:1`, `dom-writer.js:2`). Not present in `schema/yard-snapshot.schema.json`. It never reaches the assembler projection, the wire, or the view.

**`body_file`:** source/write `scripts/Migrate-Verdicts.ps1:152`, between `abstract` (`:151`) and `normalisation` (`:153`); self-disclosed at `:21-25` ("an open-posture extra (like Produce-Artifact.ps1's `model`)… MARKED DEVIATION"); hashed `:155`; 25 records, all String, constant; schema `:72-75`; same store hops; **same terminus — zero consumers.**

### Mirror check — every hand-maintained copy of the record field set

| Surface | count | delta | agrees? |
|---|---|---|---|
| `board/store/store.go:101-119` typedRecord json tags | **19** | +`manifest` | — |
| `schema/starcar-artifact.schema.json:8-92` properties | **18** | no `manifest` (layered in `starcar-manifest.schema.json`, per `store.go:69-74`) | agrees modulo the documented manifest split |
| `schema/index-format.md:18-19` canonical order | **16** | no `model`/`body_file`/`manifest` | **DISAGREES** → MINOR-1 |
| `schema/yard-snapshot.schema.json` (wire) | — | neither field | correct — neither crosses to the wire |
| `schema/vectors/valid-*.json` (4) | — | neither field | NOTE-1 |
| `schema/vectors/README.md` "Current vectors" (17 rows) | — | all rows are `fold/`; top-level artifact vectors were never listed at base | consistent — **no edit owed** |

Vector-consumer collision check: every `schema/vectors/fold/` consumer is path-scoped to the subdirectory (`.github/workflows/ci.yml:299`, `board/fold/vectors_test.go:58`), so two new top-level vectors cannot leak into the D18 cross-verifier. Confirmed empirically by the green Go suite.

---

## 8. Doc check — every cited line opened

| Citation in the diff / commit messages | Verdict |
|---|---|
| `Produce-Artifact.ps1:285` = the `model` write | **TRUE**, line-exact |
| `Produce-Artifact.ps1:204` = `resolvedModel` read | **TRUE**, line-exact |
| `Migrate-Verdicts.ps1:152` = the `body_file` write | **TRUE**, line-exact |
| `Migrate-Verdicts.ps1:22` "an open-posture extra" | **TRUE**, line-exact |
| DR3-1 item 4 / D17 analogy | **TRUE** — `docs/design/...-design.md:230-233` says manifest fields "join the wire schema AND the Go typed struct's known key-set in the same spec-rung change… a wolf-cry on the exact surface the manifest legitimizes." The car adapted rather than copied it: manifest joins the *wire* because it renders; `model`/`body_file` correctly do not, because they never reach the wire. |
| D17 itself (`design:131`) | **NOT invalidated** — "unknown fields preserved and disclosed" still holds; I watched it. |
| S3.4 basis ("names no such field") | **TRUE** — `docs/specs/2026-07-22-dispatch-harness-spec.md:161-164` names only `cost` and context. The spec delegates field names to the schema (`:122-123`), so it is not invalidated. |

**Not invalidated, checked and clear:** `docs/contracts/state-ledger.md` (no record-field-set claim; the schema rows concern the index generator and vocab reload), `docs/contracts/gating-matrix.md`, `docs/glossary.md`, `docs/doc-map.md`, `docs/specs/2026-07-23-yard-board-spec.md`, `schema/vectors/README.md`, `schema/yard-snapshot.schema.json`. `DocPolicy.Tests.ps1` scope is `docs/` Status lines — unaffected, green.

---

## 9. Findings

### MINOR-1 — the ordering authority is silent; the non-owner speaks for it
**`schema/index-format.md:11-20` vs `schema/starcar-artifact.schema.json:70,74`**

`schema/starcar-artifact.schema.json:5` declares the Law 6 split: *"ordering… declared in schema/index-format.md, which this file does not duplicate (Law 6)."* `index-format.md:5-9` accepts that ownership. Before this diff the canonical order (16 fields) matched the schema `properties` list **exactly, 16 for 16, in the same sequence**. After it: 18 properties, 16 ordered.

The car handled this by writing the exclusion into **both** new descriptions — *"Not part of the canonical field order in schema/index-format.md (a disclosed producer deviation, not an omission)"* — and I confirmed that statement is **true**. But it is an *ordering* claim living in the file that says it does not own ordering, while the owning file (`Status: Current`, so "a stale claim in it is a defect") says nothing. A reader who opens `index-format.md:13-15` is told the list is *"what a producer writes"*; it is not, for 56 of 112 committed records.

**Not a Major.** The diff did not invalidate that sentence — it was already incomplete at base (`git diff 38b67c8 d0d9d77 -- schema/index-format.md` is empty), and `Migrate-Verdicts.ps1:22-25` already disclosed the deviation. Nothing depends on it: integrity recomputes from **file order**, not this list (`StoreIntegrity.Tests.ps1:52-58`, `foreach ($p in $rec.PSObject.Properties)`), and the index columns are `subject|kind|at|outcome|file`. There is also precedent — `manifest` appears **0 times** in `index-format.md` while sitting in `typedRecord:119`.

**Remedy:** one sentence under §Canonical field order naming both fields as declared-but-unordered producer extras. Deviation **(c) ADJUDICATED: defensible, precedent-backed — but the owning document should carry the sentence.**

### MINOR-2 — a false present-tense claim about `model`, three lines above a cited line
**`scripts/Produce-Artifact.ps1:202`**: *"The board's model-mix rendering consumes it."*

**FALSE against the landed board.** No consumer exists anywhere in `board/` (§7 hop 9). Traces to `docs/plans/2026-07-22-harness-car2-plan.md:198`.

**Explicitly pre-existing and NOT introduced by this diff** — I am not charging the car with authoring it. I raise it because the diff's own sentence-check trace is what exposed it, the car read that exact region twice to source its citations at `:204` and `:285`, and this diff makes `model` a first-class declared field, raising the odds a reader consults that comment. A confident falsehood on a code comment is Law 1 class. Worth a ticket.

### NOTE-1 — the vectors pin "not a number", not "is a string"
`schema/vectors/invalid-{model,body-file}-wrong-type.json` both survive a `"type": "boolean"` mutant (§5, measured). Deviation **(b) ADJUDICATED ACCEPTABLE**: the positive shape *is* pinned, and I watched both pins fire under mutation — the Go survival assertion (`store_test.go:381-383`) and 56 real-corpus `StoreIntegrity.Tests.ps1` assertions. But that coverage is **incidental**: neither the vector set nor the Go test comment says so, and a stranger reading only `schema/vectors/` sees four `valid-*` vectors, none carrying either field. One positive vector would make the contract self-evident where it is documented.

### NOTE-2 — the 0-condition result has no regression pin, correctly
No Go test scans the real `artifacts/` store. The 58 → 0 result was proven by hand (twice — the car's, then mine). This is **correct by design, not a gap**: D17's whole mechanism is that a new producer field surfaces as a *runtime* board condition, and pinning the live count in CI would make every future field addition mechanical red — the wolf-cry the #20 index-staleness scoping already ruled against. Named so it is a decision on the record rather than an omission.

### NOTE-3 — "dispatched-only" / "returned-only" are documentation, not constraints
`schema/starcar-artifact.schema.json:70,74`. Neither is enforced by an `if/then`. This matches the pre-existing house precedent at `:41` (`envelope`: *"Only meaningful on kind=returned"*), so it is consistent, not a defect. Flagged only because the wording is slightly more constraint-shaped than `envelope`'s.

### Type correctness — RULED CORRECT (brief item 7)
`string` is right on all three axes: **empirically** (58/58 live values are strings, across four distinct model ids and 25 path strings); **by construction** (`resolvedModel` is a model identifier, and `Produce-Artifact.ps1:285`'s truthiness guard omits the field entirely on a falsy value rather than writing a non-string); **by precedent** (`producer`, `:64-67`, is typed `string` on identical open-posture-extra reasoning). The residual — a hypothetical non-string `model` now quarantines (`store.go:266-268`) where it previously merely disclosed — is the uniform house posture for every typed field, and stays disclosed at `needs-attention` (`:190-194`), never silent. Not a latent defect.

---

## 10. Guard check — every guard WATCHED to fire

| Guard | Fault injected | Observed |
|---|---|---|
| `TestScanKnownProducerFieldsNotUnrecognised` | both struct fields removed | FAIL, names `model` |
| …same | only `model` declared | FAIL, names `body_file` |
| …same | only `body_file` declared | FAIL, names `model` |
| …same | schema type `string`→`boolean` | FAIL, `got 0` survivors |
| `invalid-model-wrong-type` vector | run at base schema | FAIL, `Expected $false, but got $true` |
| `invalid-body-file-wrong-type` vector | run at base schema | FAIL, same |
| The `record-unrecognised-fields` detector | junk fields alongside declared ones | **FIRES**, 2 fields named, `needs-attention` |

No guard in this diff passed on arrival unexamined.

---

## 11. Constitution check

| Law | Evidence |
|---|---|
| **Law 1 — Unknown states render AS unknown** (`docs/constitution.md:14-18`) | The truth surface was **declared, never suppressed**. Detector byte-untouched at `store.go:293-307`; watched firing on junk fields with the fix in place. The 58 conditions were honest, and the honest fix was to stop them being *false*, not to stop them being *shown*. |
| **Law 4 — Nothing Silently Lost** (`:36-40`) | `Record.Fields` preserves both values via the generic decode (`store.go:246-249`), asserted at `store_test.go:385-390`. Nothing dropped, nothing counted-out. The one new exclusion path (non-string → quarantine) is loud: `record-quarantined`, `needs-attention`, `store.go:190-194`. |
| **Law 6 — One Truth** (`:48-52`) | The record field set now lives in 3 places: `typedRecord` (19), schema `properties` (18, delta = `manifest`, documented as the layered split at `store.go:69-74`), `index-format.md` (16). The typedRecord↔known-key edge is **mechanically pinned** — `buildTypedKeys()` reflects the struct's own tags (`:127-138`), never a hand-kept parallel list. The schema↔real-store edge is pinned by 56 `StoreIntegrity` assertions. The schema↔`index-format.md` edge is **not** pinned → MINOR-1. |
| **Law 7 — The Stranger** (`:54-58`) | **No enum was added.** `kind`/`outcome` recognition vocabulary stays as DATA (`schema:13`, `:29`, untouched, still true). `additionalProperties` appears **0 times** in the file, so the open posture is intact — a stranger's adapter carrying an extra field still conforms. Declaring a *field* is orthogonal to the vocabularies-as-data rule; the open-posture $comment at `index-format.md:25-36` remains accurate. **No violation.** |
| **Law 5 — Self-Knowledge** (`:42-46`) | Both commit messages disclose the deviation set, including the 56-vs-52 discrepancy the car was not obliged to volunteer. It re-derived as exactly true. |
| **TDD (red-first)** | Both reds re-derived by me, failing for the stated reasons, verbatim. Both non-vacuous under mutation. Red preceded green in both commits (Go mechanism `969e856`, schema contract `d0d9d77`). |
| **Verification honesty** | Counts carry suite, number, SHA and observer throughout; the baseline was derived, not assumed. |

**Convergence:** not applicable — round 1.

---

## Summary

The change does exactly what #26 ruled and nothing more: it grows an allowlist by two provenanced names and closes a documented contract gap, while leaving the honest detector fully armed. The car found the existing conformance instrument instead of inventing one, cited five external lines that are all line-exact true, and disclosed a number discrepancy that turned out — on independent measurement, with `body_file`'s constancy as the corroborating tell — to be precisely the growth it claimed.

Two Minors, neither blocking, neither invalidating a document this diff wrote. **APPROVE.**

**Relevant paths:** `~/AppData/Local/Temp/claude/C--Users-Chris-git-starcar/e92f5a0b-1b9e-4913-98b3-c319b4d5e90b/scratchpad/review-car26/board/store/store.go`, `.../board/store/store_test.go`, `.../schema/starcar-artifact.schema.json`, `.../schema/index-format.md`, `.../schema/vectors/`, `.../scripts/Produce-Artifact.ps1`, `.../scripts/Migrate-Verdicts.ps1`, `.../scripts/Artifact.psm1`, `.../scripts/tests/Artifact.Tests.ps1`, `.../scripts/tests/StoreIntegrity.Tests.ps1`, `.../docs/design/2026-07-21-v0-yard-skeleton-design.md`, `.../docs/constitution.md`

```starcar-artifact
outcome: APPROVE
findings: 0 Major, 2 Minor, 3 Note. MINOR-1 schema/index-format.md:11-20 - the document that OWNS canonical ordering (per starcar-artifact.schema.json:5's Law 6 split) stays silent on the two newly-declared properties, while the exclusion is stated only in the non-owning schema file at :70 and :74; canonical order was 16-for-16 with schema properties before this diff and is now 16 vs 18. Not Major: the sentence's truth value did not change (index-format.md is byte-identical to base), integrity recomputes from FILE order at StoreIntegrity.Tests.ps1:52-58 not from this list, and manifest sets the same precedent (0 occurrences in index-format.md, present at store.go:119). MINOR-2 scripts/Produce-Artifact.ps1:202 - "The board's model-mix rendering consumes it" is FALSE against the landed board; zero consumers of model exist in board/**/*.go or board/web; explicitly PRE-EXISTING and not introduced by this diff, raised because the diff's own trace exposed it three lines above a cited line. NOTE-1 the two new wrong-type vectors survive a string-to-boolean schema mutant, so they pin not-a-number rather than is-a-string; the positive shape IS pinned but incidentally, by the Go survival assertion at store_test.go:381-383 and 56 real-corpus StoreIntegrity assertions, both watched failing under mutation. NOTE-2 no regression pin on the real-store 0-condition result, correct by design since D17 disclosure is a runtime surface and pinning it would make every future field addition mechanical CI red. NOTE-3 dispatched-only and returned-only in the descriptions are unenforced documentation, matching the pre-existing envelope precedent at schema:41.
abstract: Round 1 review of Car 26 at d0d9d77 (base 38b67c8), 7 files, +96/-1. APPROVE, zero Majors. Re-derived every claim rather than reading the report. DETECTOR INTACT - store.go:293-307 byte-untouched, and I watched it fire on a record carrying both newly-declared fields plus two junk fields, naming exactly the junk, register needs-attention, no leakage. BOTH REDS RE-DERIVED VERBATIM - Go, both struct fields reverted on a scratch copy, "record carries 1 unrecognised field(s): model"; schema, the four vector files injected at base, "Expected $false, but got $true" for both, and both vectors validated as VALID at base so the invalidity is isolated to the type declaration alone. NON-VACUITY ATTACKED FIVE WAYS - the Go test fails with only model declared and again with only body_file declared, so both halves are load-bearing; the schema vectors survive a boolean-type mutant, but the same mutant fails the Go test with "expected both records to survive, got 0" and would redden 56 StoreIntegrity records, so the positive shape is genuinely pinned. SUITES RUN MYSELF at d0d9d77 - Go 5 of 5 packages ok; node --test 50 tests 50 pass 0 fail; Pester scripts/tests 249 passed 0 failed. BASELINE DERIVED MYSELF at 38b67c8 - 247 passed 0 failed, so 247 plus 2 equals 249 is verified arithmetic. EMPIRICAL CLAIM REPRODUCED - live store read-only, AFTER is 0 conditions on 115 records with 0 quarantined; BEFORE is 58, being model 33 and body_file 25. The disclosed 56-vs-52 discrepancy ADJUDICATED TRUE and independently corroborated: the committed tree at d0d9d77 yields exactly 31 plus 25 equals 56, the car's number, and body_file is CONSTANT at 25 across all three measurements (issue 52 equals 27 plus 25, car 56, me 58) because Migrate-Verdicts runs once historically while model grows with every dispatch. SENTENCE CHECK - both fields traced hop by hop with file:line from Produce-Artifact.ps1:204 and :285 and Migrate-Verdicts.ps1:152 through the integrity body, the 58 on-disk records all String-typed, the schema at :68-75, the typedRecord tag, buildTypedKeys reflection, and the unknown diff, to a TERMINUS AT THE STORE - neither field reaches the assembler, the wire schema, or the browser view. All five hand-maintained mirrors enumerated; four agree, index-format.md is the one that does not. ALL EXTERNAL CITATIONS OPENED AND LINE-EXACT TRUE - Produce-Artifact.ps1:285 and :204, Migrate-Verdicts.ps1:152 and :22, DR3-1 item 4 at design:230-233, D17 at design:131, spec S3.4. DEVIATIONS - (a) TRUE and corroborated; (b) ACCEPTABLE, positive shape covered elsewhere and watched firing, NOTE-1; (c) DEFENSIBLE with manifest precedent but the owning document should carry one sentence, MINOR-1. CONSTITUTION - Law 1 honored (truth surface declared not suppressed, detector watched firing), Law 4 honored (values preserved in Fields, the one new exclusion path is loud quarantine), Law 6 partially (typedRecord-to-known-key edge mechanically pinned by reflection, schema-to-store pinned by 56 assertions, schema-to-index-format unpinned, MINOR-1), Law 7 honored (no enum added, additionalProperties appears zero times so the open posture is intact, vocabularies-as-data comments untouched), TDD honored. Worktree proven byte-identical, tree faead79d1c9e810fa14e6291a80a2251c8d784db at start and end, status and diff empty, shared checkout never written to.
```