<!-- starcar-integrity: sha256=9e33f8d86a42c51c24423875c5f35d4b35d0cbf7a654c06b89c61aacb69f0363 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car 1 review, round 1: index generator violates its own at-format and sort contract

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (adversarial, Opus) + model-probe instrument
Round: 1
Target: `car/harness-car1 at 0ad4d93 (5 commits)`
Base reviewed: `0ad4d93701d5a1be67a728df140279d4e689bcb3`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a2bbd2f4d50b4976d`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `0ad4d93701d5a1be67a728df140279d4e689bcb3` |

| Dispatch, the locator within the session | `a2bbd2f4d50b4976d` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 0ad4d93701d5a1be67a728df140279d4e689bcb3
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All fault injections reverted byte-identical, tree CLEAN, HEAD still `0ad4d93`, no leftover temp dirs. Schema has zero `additionalProperties` (open, matching index-format.md's stated posture). I have everything I need.

---

## VERDICT: REJECT — 1 Major (M-A4-1), 2 Minor. The A.4 index generator violates the `at`-column format and sort-order contract that `schema/index-format.md` (authored by the same car in A.1) defines.

---

### Base verification
`git log -1` = `0ad4d93701d5a1be67a728df140279d4e689bcb3`, five commits above base `845f6c9` (cb1ac85, fe9505c, fbe20af, 7f1ac31, 0ad4d93), tree clean at entry. Per-commit file scopes match the plan's Files lists exactly, one task per commit. Confirmed.

### Suites run by me (second party, at HEAD `0ad4d93`, pwsh 7.6.3, Pester 5.8.0)
- `Invoke-Pester ./scripts/tests`: **41 passed, 0 failed, 0 skipped**. Car's claim (41/0) confirmed.
- `./scripts/Verify-Verdict.ps1` bare: **14 verdict file(s) verified, exit 0**. Car's claim (14/14 exit 0) confirmed; matches amendment-block entry 2 (13→14 superseded).
- Count reconciles: 21 pre-existing (Board 19 + DocPolicy 2) + 20 new (Schema 4, Artifact 11, VerifyVerdict 3, ArtifactIndex 2) = 41. Trajectory endpoints (21 to 41) consistent; I verified terminal counts and per-commit scope, not each intermediate suite count.

---

### (a) Plan fidelity — task by task

- **A.1 (cb1ac85):** schema, two vocab data files, 9 vectors each with `.expect` sibling, `index-format.md`, `Schema.Tests.ps1`. All present. 16 schema fields present; `kind`/`outcome` typed `string`, no `enum` (Schema.Tests line 15-19 passes). Vectors: 4 valid (dispatched, returned-with-abstract, presumed-lost, unrecognised-kind) + 5 invalid (missing-kind, returned-missing-outcome, **returned-missing-abstract** [PR2-M1 present], presumed-lost-missing-basis, missing-integrity). `index-format.md` carries field-order (line 17-20), index format + worked example (line 38-58), normalisation rule (line 60-72), AND the `additionalProperties` open posture (line 26-35) — the round-3 forward note is honored; schema has zero `additionalProperties` keys, confirming open/default-true. **Fidelity: PASS.**
- **A.2 (fe9505c):** `Test-StarcarArtifact -InputObject/-SchemaPath/-VocabDir` returns `[pscustomobject]@{Valid;Errors;Discoveries}` (Artifact.psm1:80-84), `BeforeDiscovery` enumeration (Artifact.Tests.ps1:2-10), one-fault vocab collapse (psm1:60-68), discovery-by-name (psm1:70-77). Interface contract honored exactly. **PASS.**
- **A.3 (fbe20af):** three behaviors — absent store exit 1 naming dir (Verify-Verdict.ps1:90-92), empty store exit 1 actionable "zero verdict files" (line 100-103), dead `:94-96` exit-0 path removed (diff confirms the old `Write-Host "No verdict files found"; exit 0` replaced by `Write-Error; exit 1`). 5.1-compat retained. **PASS.**
- **A.4 (7f1ac31):** `New-ArtifactIndex -StoreRoot/-OutFile`, LF/UTF-8-no-BOM WriteAllText (line 55-57). Present and deterministic — **but violates the consumed contract; see M-A4-1 below.**
- **A.5 (0ad4d93):** two-question ledger (state-ledger.md Q1 append-only+nil, Q2 one derived-artifact row), three-row gating matrix (tier1/tier2/index-staleness), both template trigger lines annotated "First copied: 2026-07-22" in the **same commit**. Pending-with-planned-name evidence used, never blank/faked. **PASS.**

### (b) Sentence check — schema as data contract
Walked all 16 schema properties against the plan field table and spec §3, row by row: `schema`(const), `kind`/`outcome`/`subject`/`session_id`/`findings`/`abstract`/`producer`(string), `at`(string+date-time), `budget`/`context_peak_tokens`(number), `basis`(object, requires observed/by/against_budget), `cost`/`envelope`(object/string), `normalisation`(array of from_class/to), `integrity`(string, `^sha256:[0-9a-f]+$`). Always-required set = schema, kind, subject, session_id, at, normalisation, integrity (7). Conditionals via `allOf`/`if`/`then`: `returned` requires outcome+findings+abstract; `presumed-lost` requires basis. **No field in the schema absent from the plan table; none in the plan table absent from the schema.** `envelope` is `enum:[absent,malformed]` — a *closed schema-owned fault class*, correctly distinguished from the recognition vocabularies (kind/outcome) whose unrecognised values must be discoveries; the schema description states this exemption. Defensible, not a finding. **Contract: clean.**

### (c) Non-vacuity fault-injection log (all reverted byte-identical; tree CLEAN confirmed)
| # | Injection | Observed | Revert |
|---|---|---|---|
| 1 | Flipped `valid-dispatched.expect` valid→invalid | Conformance suite **Failed=1** (guard fires) | `git checkout`; blob hash restored to `1e2466d`; clean |
| 2 | Removed `abstract` from the valid-returned object (in-memory) | With abstract Valid=**True**; without Valid=**False**, error names `Required properties ["abstract"]` — new conditional is non-vacuous | no file touched |
| 3 | Verify-Verdict at empty dir / absent dir | empty: exit 1, "zero verdict files", no crash; absent: exit 1, names the dir | temp dirs outside worktree; clean |
| 4 | New-ArtifactIndex twice, then mutate one `at` | run1==run2 (`EB505E2F…`); after mutating `at`, hash changed (`802FAFDA…`) — determinism guard non-vacuous in green state | temp store removed; clean |

Injection #4 is what answers disclosed finding #3: the byte-identity assertion is genuinely non-vacuous **post-implementation** (change `at`, output changes), even though it was vacuous at red time.

### (d) The three disclosed findings — verified empirically, ruled on severity + attribution

1. **A.1 red-count (4 Its vs the plan-writer's 2-It probe).** BENIGN. The plan's own A.1 step-2 text (plan line 221) already states *"All four `It`s red at base for the file-absent reason"* — the 2-It figure (line 219) was explicitly the plan-writer's *reduced probe*, distinguished in the same paragraph. The car observing 4 reds is exactly what the plan predicted. No car defect, no rider. Attribution: **benign / plan text self-consistent.**

2. **A.3 crash text (PropertyNotFoundStrict vs ParentContainsErrorRecordException).** VERIFIED and CORRECT disclosure. I ran the base (`845f6c9`) script against an empty dir under pwsh 7: the rendered output is `ParentContainsErrorRecordException` / *"The property 'Count' cannot be found"* at `:94`, exit 1 — and `grep` confirms the literal string **`PropertyNotFoundStrict` does NOT appear** in the output. Layer analysis: `PropertyNotFoundStrict` is the FullyQualifiedErrorId (what the plan/spec S1 quoted); `ParentContainsErrorRecordException` is the rendered exception display name (what the car quoted). Consequence: the plan's `Should -Not -Match 'PropertyNotFoundStrict'` assertion (VerifyVerdict.Tests.ps1:20) was **vacuous pre-fix under pwsh 7** — it would have passed even against the crash. But it does not matter post-fix: the load-bearing assertion is `Should -Match 'zero verdict files'` (line 19), which pre-fix output (the stack trace) fails, so test 2 is non-vacuous overall (proven in injection #3). Attribution: **INHERITED** plan/spec text imprecision (quoted the error id, not the rendered name); the car executed the snippet verbatim and disclosed accurately. **Minor.** Non-blocking hardening available (also assert against `cannot be found`), not required.

3. **A.4 byte-identity It passing vacuously at red (null==null on missing files).** VERIFIED. At red time the generator does not exist, both `Get-FileHash` calls return null, `null | Should -Be null` passes — only test 1's row-count assertion carried the genuine red (CommandNotFoundException, plan line 437). The car executed the plan snippet verbatim and disclosed. Green-state non-vacuity is empirically confirmed (injection #4). Attribution: **INHERITED** (plan A.4 snippet design); correctly disclosed. **Minor.** No rider strictly required for the determinism claim — but this thin A.4 test design is the enabling condition for M-A4-1 below.

### M-A4-1 (MAJOR) — the shipped index generator violates the `at`-format and sort-order contract it implements

**Evidence, reproduced with clean fixtures:**
- `New-ArtifactIndex.ps1:28` reads artifacts with `ConvertFrom-Json`, which in PowerShell 7 **silently coerces the ISO-8601 `at` string into `[System.DateTime]`** (I confirmed the runtime type is `System.DateTime`).
- `New-ArtifactIndex.ps1:38` casts `At = [string]$obj.at`, reformatting to invariant `MM/dd/yyyy HH:mm:ss` — e.g. `2026-07-22T10:00:00Z` becomes `07/22/2026 10:00:00`. The `Z`/UTC marker and ISO layout are **lost** (Law 4).
- `schema/index-format.md:55-57` worked example documents the `at` column as `2026-07-22T10:00:00Z`. The generator **cannot produce that**. The committed contract is a false claim about the code's output — a lying canary (Law 1), and a stranger building a board or parser against the documented ISO column breaks on the real output (Law 7).
- `New-ArtifactIndex.ps1:46` sorts by that `MM/dd/yyyy` string. `index-format.md:46` requires *"sorted by `at`"* (chronological — reinforced by spec §3.1 "latest-`at` wins"). Lexical sort of `MM/dd/yyyy` is **non-chronological across years**. Clean demonstration: a 2026 artifact and a 2099 artifact produce:
  ```
  | y2099 | dispatched | 01/01/2099 00:00:00 |  | y2099.json |
  | y2026 | dispatched | 07/22/2026 10:00:00 |  | y2026.json |
  ```
  2099 sorted **before** 2026. The append-only store (spec §5.2) inevitably spans years, so this is not a corner case.

**Why the suite missed it:** `ArtifactIndex.Tests.ps1:8-17` uses a fixture of three **same-day 2026** timestamps that happen to sort identically under lexical and chronological order; line 24 asserts only row **count** (`Should -Be 3`), never the `at` format or the row order; line 31 asserts hash equality (self-consistent regardless of format). The determinism guard has teeth for "same input → same output," but nothing pins "correct format" or "correct order." (Cross-locale portability is, separately, fine: the `[string]` cast uses InvariantCulture — de-DE produced byte-identical output — so this is not a locale-nondeterminism bug; it is a wrong-format-and-wrong-order bug.)

**Attribution:** primarily **EXECUTION-class.** The buggy code is the car's hand-written implementation (psm... A.4), and it contradicts the contract the *same car* authored in A.1. A careful implementer would have noticed its A.4 output (`07/22/2026`) did not match its own A.1 worked example (`2026-07-22T…Z`). The thin plan-supplied A.4 test (same-day fixture, count-only) is an **INHERITED** enabling condition that let the defect pass red-first, but the defect itself is car code. Any Major = REJECT.

*(Note for the rebase: the fix is small — read `at` as raw text, e.g. `ConvertFrom-Json -DateKind String` in pwsh 7.3+, and sort on the ISO string, plus a rider fixture spanning years/months asserting order and the ISO column. This is a coverage/implementation defect (rider), not a structural rewrite.)*

### (e) Model-probe report (car ran on Sonnet)

**Verified report claims empirically:** suite 41/0 — TRUE; verifier 14/14 exit 0 — TRUE; five commits, correct per-commit file scopes, one task each — TRUE; three self-disclosures — all three accurate (I reproduced #2 and #3; #1 is benign per the plan's own text). No false or unmeasured claim found in what the car reported.

**Defect classification for the cars 2-3 decision:**
- M-A4-1: **EXECUTION-class** (car implementation code, subtle `ConvertFrom-Json` DateTime-coercion trap, uncaught despite the car's own A.1 contract documenting the correct format), enabled by an **INHERITED** thin A.4 test.
- Disclosed #2, #3: **INHERITED** (plan/spec snippet weaknesses), correctly disclosed — these carry **zero** negative signal about the car; the honest disclosure is a positive signal.
- Disclosed #1: **benign.**

**What THIS evidence supports:** the Sonnet car executed the *mechanical* plan faithfully — clean commits, honest reds, accurate counts, three correct self-disclosures. It did **not** execute cleanly on the one dimension that required going beyond the literal snippet: it shipped a functional defect in hand-written implementation code (M-A4-1) that its own authored contract flagged as wrong, and its plan-dictated tests were too thin to expose. This is one genuine execution-class data point: **Sonnet followed the letter of a thin test spec and did not independently catch a subtle implementation bug against a contract it had itself written.** That is precisely the failure mode Opus-as-implementer would be expected to reduce. Round 1's attribution error (execution defects that were actually conductor-authored plan defects) is not repeated here: M-A4-1 is car code, reproduced with file:line and clean fixtures. I would characterize this round as **weak-but-real evidence favoring moving cars 2-3 to Opus** — one defect, subtle, but of exactly the class (contract-vs-implementation self-consistency) that the probe was commissioned to measure. The conductor holds the budget call.

### Constitution check on the landed artifacts (the schema IS the product)
- **Law 1 (no confident falsehood on an information surface):** **VIOLATED** by M-A4-1 — `schema/index-format.md:55-57` claims an `at` format the generator does not emit, and the index renders a non-chronological order. This is the law the diff most directly implicates.
- **Law 4 (no silent loss):** implicated by M-A4-1 — the ISO precision and `Z` marker are silently dropped in the derived index.
- **Law 6 (one owner per contract, no second copy):** **HONORED** — schema JSON owns fields/types, `index-format.md` owns ordering/index/normalisation (explicitly non-duplicating, index-format.md:5-9); `Artifact.psm1:16` uses `Test-Json` rather than a hand-rolled schema copy.
- **Law 7 (the stranger; portability):** mostly honored (vocabularies as data, portable JSON-Schema-plus-vectors, normalisation declared in-artifact, no absolute paths in artifacts) — **but undermined by M-A4-1**: a stranger building against the documented ISO `at` column breaks on the real output.
- **TDD/red-first:** honored mechanically for A.1-A.3, A.5; A.4's byte-identity assertion had a vacuous red (disclosed #3), and the A.4 suite's thinness is what let M-A4-1 ship — the rider must land red-first (a year-spanning fixture that fails on the current sort/format, then goes green on the fix).

### Fault-injection revert confirmation
All four injections reverted; `git status --porcelain` empty; HEAD unchanged at `0ad4d93701d5a1be67a728df140279d4e689bcb3`; no leftover temp artifacts. I edited, committed, and pushed nothing.

```starcar-artifact
outcome: REJECT
findings: One Major (M-A4-1). scripts/New-ArtifactIndex.ps1 line 28 lets ConvertFrom-Json coerce the ISO-8601 at value into a DateTime, line 38 casts it to the invariant MM/dd/yyyy string, and line 46 sorts on that string. Two consequences, both reproduced with clean fixtures. First, the committed contract schema/index-format.md line 55-57 documents the at column as ISO-8601 with a UTC Z, which the generator cannot produce, so a committed document makes a false claim about the code (Law 1) and the UTC marker is silently dropped (Law 4). Second, the lexical sort of MM/dd/yyyy is non-chronological across years - a 2099 artifact sorts before a 2026 artifact - violating the sorted-by-at contract that latest-at-wins supersession depends on. The A.4 suite missed it because its fixture uses three same-day 2026 timestamps and asserts only row count and hash equality, never format or order; that thin plan-supplied test is the inherited enabling condition, but the buggy implementation code is the car's and contradicts the contract the same car authored in A.1. Cross-locale portability is fine (the string cast is InvariantCulture; de-DE output was byte-identical). Two Minors, both INHERITED plan-snippet weaknesses that the car correctly disclosed: the A.3 assertion matching PropertyNotFoundStrict is vacuous under pwsh 7 because the base crash renders as ParentContainsErrorRecordException with no such literal string, though the zero-verdict-files positive assertion carries the guard; and the A.4 byte-identity assertion was vacuous at red time (null equals null on missing files) though non-vacuous in green. Suites verified by me at HEAD 0ad4d93: 41 passed 0 failed under pwsh 7.6.3 Pester 5.8.0; verifier 14 of 14 exit 0. A.1, A.2, A.3, A.5 pass fidelity and non-vacuity. Fix is a rider, not a rewrite.
abstract: REJECT. Car 1 landed the schema, vocabularies-as-data, 9 conformance vectors, the pwsh validator, the Verify-Verdict hardening, and both contract files cleanly, with 41 of 41 tests green and three accurate self-disclosures. But the A.4 index generator renders the at column as invariant MM/dd/yyyy instead of the ISO-8601 its own index-format contract documents, and sorts that string non-chronologically so a 2099 record precedes a 2026 one - a functional defect in the core A.4 deliverable, masked by a same-day count-only test fixture. Any Major is a REJECT. Model probe: the Sonnet car executed the mechanical plan faithfully but shipped one subtle contract-versus-implementation bug it should have caught against a contract it authored itself - weak but real evidence favoring Opus for cars 2-3, budget call to the conductor. Fix is a small rider with a year-spanning red-first fixture, not a rewrite.
```