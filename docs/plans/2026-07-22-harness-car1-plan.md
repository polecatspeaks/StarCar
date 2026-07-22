Status: Current

# Dispatch harness - Car 1 implementation plan (schema, validator, index, contracts)

REQUIRED SUB-SKILL: one car per task group, adversarial reviewer per car.

Source of truth: `docs/specs/2026-07-22-dispatch-harness-spec.md` (**APPROVED** at spec review
round 4 - 3 rounds, 16 findings, 6 rulings, all closed by mechanism; verdicts in
`docs/reviews/`). Design: `docs/design/2026-07-22-dispatch-harness-design.md` rev 6 + A1.

Base commit for every car: **`d70069e`**. Ledger arithmetic below is base-`d70069e`
arithmetic; the car RE-READS the live ledger at dispatch and STOPS on mismatch.

**Scope: Car 1 only.** Cars 2 and 3 are planned after Car 1 lands, deliberately - Car 1 is
also the **model probe** (see Global constraints), and planning cars 2-3 before its data
exists would be planning on an assumption.

> # BINDING AMENDMENT BLOCK (conductor-applied)
> *Empty at plan-writing. When the plan review or a mid-train event invalidates task text,
> the conductor patches HERE - numbered items, each SUPERSEDING contradicting task text -
> instead of rewriting tasks. The car reads this block FIRST.*

## CONDUCTOR RULING R1 - the schema artifact's form (recorded, not assumed)

The spec and design both require the format half to be **executable** and neither names a
language. The repo has no Node toolchain (the yard train that would establish it is parked),
its existing tooling is PowerShell + Pester, and Law 7 requires a stranger with a different
stack to be able to conform.

**Ruling:** the schema artifact is **a language-neutral JSON Schema plus conformance
vectors**, with a PowerShell validator as *this shop's implementation of it*. The vectors are
the portable conformance suite - a stranger writes a validator in their language and runs it
against the same vectors. This satisfies "the schema is the product; producers are adapters"
without inventing a toolchain, and it is why A.1 (schema + vectors) is a separate task from
A.2 (validator): the first is the product, the second is one implementation.

## Global constraints

Red-first TDD per step; the ledger is updated in the same commit as any mutable state; docs
updated in the invalidating commit; **honest-stop on any plan-vs-code contradiction is a
SUCCESS outcome**; the car never pushes. Suites at car end: `Invoke-Pester -Path ./scripts/tests`
(baseline **21 passing** at `d70069e`) and `./scripts/Verify-Verdict.ps1` (baseline **11/11
hashes match, exit 0**).

**MODEL PROBE (owner-approved):** Car 1 runs on **Sonnet**; its reviewer runs on **Opus**.
The reviewer is asked to report separately whether any finding is an *execution* defect -
wrong test, skipped red, improvised past a contradiction - because that is the signal that
moves cars 2-3 back to Opus. This is a measurement, not a cost cut taken on faith.

---

## Car 1 - schema, validator, index, contracts (Tasks A.1-A.5)

### Task A.1 - the artifact schema and its conformance vectors

**Files:** Create `schema/starcar-artifact.schema.json`; Create `schema/vectors/` (valid and
invalid cases, each a `.json` with a sibling `.expect` of `valid` or `invalid`); Create
`scripts/tests/Schema.Tests.ps1`.

**Interfaces — Produces (Car 2 and the yard train consume these blind):**
- `schema/starcar-artifact.schema.json` - JSON Schema (draft 2020-12) for one artifact's
  front-matter.
- Required properties: `schema` (const `starcar-artifact/1`), `kind` (enum:
  `dispatched`, `returned`, `presumed-lost`, `intent`, `ruling`), `subject`, `session_id`,
  `at`.
- Conditionally required: `dispatch_id` when `kind` is a dispatch kind; `outcome` and
  `findings` when `kind` is `returned`.
- Optional and **producer-optional by Law 7**: `cost`, `context_peak_tokens`, `producer`.

**Spec authority:** kinds and their precedence are spec §3.1; producer-optional cost/context
is spec §3.4; vocabularies-as-data is spec §3.2 - **the schema constrains the SHAPE, and the
kind vocabulary itself ships as data, so the enum lives in the vector set rather than being
the only source.**

- [ ] **Step 1 — write the failing test**

```powershell
Describe 'Artifact schema and conformance vectors' {
    BeforeAll {
        $script:Root   = (git rev-parse --show-toplevel)
        $script:Schema = Join-Path $script:Root 'schema/starcar-artifact.schema.json'
        $script:Vectors = Join-Path $script:Root 'schema/vectors'
    }

    It 'the schema file exists and is parseable JSON' {
        Test-Path $script:Schema | Should -BeTrue
        { Get-Content $script:Schema -Raw -Encoding UTF8 | ConvertFrom-Json } | Should -Not -Throw
    }

    It 'ships at least one valid and one invalid vector, each with an .expect sibling' {
        $cases = Get-ChildItem $script:Vectors -Filter *.json -ErrorAction SilentlyContinue
        $cases.Count | Should -BeGreaterThan 1
        foreach ($c in $cases) {
            $expect = [System.IO.Path]::ChangeExtension($c.FullName, '.expect')
            Test-Path $expect | Should -BeTrue -Because "$($c.Name) needs an .expect sibling"
            (Get-Content $expect -Raw).Trim() | Should -BeIn @('valid','invalid')
        }
    }
}
```

- [ ] **Step 2 — run, confirm the red REASON**

Run: `Invoke-Pester -Path ./scripts/tests/Schema.Tests.ps1`.
Expected: **FAIL** on `Test-Path $script:Schema | Should -BeTrue` — *"Expected $true, but got
$false"* — because `schema/` does not exist at `d70069e`. **A red for any other reason is a
finding to report, not to paper over.**

- [ ] **Step 3 — minimal implementation:** create the schema and at least four vectors — a
  valid `dispatched`, a valid `returned` with `outcome` and `findings`, an invalid one
  missing `kind`, and an invalid `returned` missing `outcome`.

- [ ] **Step 4 — green + suite:** `Invoke-Pester -Path ./scripts/tests` → expect **21 + 2 = 23**
  passing, 0 failed.

- [ ] **Step 5 — commit:** `feat(schema): artifact schema and conformance vectors (#7)`

**Ledger:** no mutable service state — **say so explicitly in the report**; the reviewer
checks the claim either way.

### Task A.2 - the PowerShell validator (one implementation of A.1's schema)

**Files:** Create `scripts/Artifact.psm1`; Create `scripts/tests/Artifact.Tests.ps1`.

**Interfaces — Consumes:** `schema/starcar-artifact.schema.json` and `schema/vectors/` from
A.1. **Produces:** `Test-StarcarArtifact -InputObject <psobject>` returning
`@{ Valid = [bool]; Errors = [string[]] }`. Car 2 consumes this exact shape blind.

Follow `scripts/Board.psm1`'s pattern (verified at `d70069e`): pure functions in the `.psm1`,
`Export-ModuleMember -Function` at the end (`Board.psm1:194`), Pester tests against fixtures
with no live dependency.

- [ ] **Step 1 — write the failing test:** every vector in `schema/vectors/` validates
  according to its `.expect` sibling. This is a **table-driven** test over the vector
  directory, so a vector added later is automatically enrolled — the completeness property,
  not a fixed list.
- [ ] **Step 2 — run, confirm the red REASON:** *"The specified module 'Artifact.psm1' was not
  loaded because no valid module file was found"*. Module-not-found is the correct stated red
  for a genuinely new module.
- [ ] **Step 3 — implement** `Test-StarcarArtifact` against the schema.
- [ ] **Step 4 — green + suite:** expect **23 + N** passing where N is the vector count.
- [ ] **Step 5 — commit:** `feat(schema): PowerShell validator for the artifact schema (#7)`

**Ledger:** none (pure functions) — state so explicitly.

### Task A.3 - extend Verify-Verdict to the artifact store, and kill its vacuity

**Files:** Modify `scripts/Verify-Verdict.ps1`; Create `scripts/tests/VerifyVerdict.Tests.ps1`.

**The defect, verified at `d70069e`:** `Verify-Verdict.ps1:24` defaults `$ReviewsDir` to
`docs/reviews`; `:87-90` exits **0** when the directory is absent; `:94-96` exits **0** when it
contains no `.md`. `.github/workflows/ci.yml:47` invokes it bare. So after Car 3's migration
CI would go green having verified nothing — the shape `ci.yml:62` already refuses for Pester.

Spec §4 row 4 and ruling 4 require the repoint and the `ci.yml` update to land in the
**migration commit** — that is **Car 3's** commit. **A.3 delivers the capability; it does not
perform the migration.**

- [ ] **Step 1 — write the failing test:** pointed at an empty directory, the verifier must
  **exit non-zero**, and its message must name the directory.
- [ ] **Step 2 — run, confirm the red REASON:** the test fails because the current code exits
  **0** with *"No verdict files found. Nothing to verify."* — *"Expected exit code not 0, but
  got 0"*.
- [ ] **Step 3 — implement:** add a `-RequireNonEmpty` switch (default **off**, so `ci.yml:47`'s
  bare invocation is unchanged at this commit and Car 3 turns it on with the repoint). Empty +
  switch = exit 1.
- [ ] **Step 4 — green + suite**, and confirm `./scripts/Verify-Verdict.ps1` bare still reports
  **11/11 hashes match, exit 0** — the existing behaviour must not regress.
- [ ] **Step 5 — commit:** `fix(verify): a verifier that checks nothing must not pass (#7)`

**Ledger:** none.

### Task A.4 - the generated artifact index

**Files:** Create `scripts/New-ArtifactIndex.ps1`; Create `scripts/tests/ArtifactIndex.Tests.ps1`.

**Spec authority §5.2:** the index is a committed derived file, so **CI regenerates and diffs
it**; a stale index fails the build (Law 6 — a second copy that can drift). The **generator**
is stateless; only the artifact is derived state.

**Produces:** `New-ArtifactIndex -StoreRoot <path> -OutFile <path>`, deterministic — same
inputs produce byte-identical output, which is what makes the regenerate-and-diff gate
possible.

- [ ] **Step 1 — write the failing test:** given a fixture store, the generator produces an
  index containing one row per artifact; **and running it twice produces byte-identical
  output** (the determinism property the CI gate depends on).
- [ ] **Step 2 — run, confirm the red REASON:** script not found.
- [ ] **Step 3 — implement.**
- [ ] **Step 4 — green + suite.**
- [ ] **Step 5 — commit:** `feat(index): deterministic artifact index generator (#7)`

**Ledger:** none.

### Task A.5 - instantiate both contract files

**Files:** Create `docs/contracts/state-ledger.md` and `docs/contracts/gating-matrix.md`.

Templates: `docs/templates/state-ledger.md`, `docs/templates/gating-matrix.md`. Filled
exemplars showing real row anatomy: `docs/templates/worked-ledger-and-gating.md`.

**The state ledger's content is the honest null, and that is the point.** Spec §5.1: this
feature introduces **no mutable service state** — the ledger records that, with the reasoning
(the one-writer premise removed the need for remembered identity, dedup and clock state), so a
later reviewer can see the claim was made deliberately rather than omitted.

**The gating matrix gets real rows** — tier 1 detection, tier 2 detection, and the
index-staleness gate — each with fires-when / suppressed-when / resets-on / classification /
evidence. Per `worked-ledger-and-gating.md`, a **DELIBERATE no-gate posture is still a row**.

Both files carry `Status: Current` in the machine-checkable form — `scripts/tests/DocPolicy.Tests.ps1`
enforces it and **will fail if they do not** (that is the red for this task; run the suite and
watch it fail before writing the headers).

- [ ] **Step 5 — commit:** `docs(contracts): instantiate state ledger and gating matrix (#7)`

**Ledger:** this task CREATES the ledger. Header arithmetic: **0 → 0 fields** (no mutable
service state), stated with the reasoning rather than left blank.

---

## Spec-coverage table (Car 1's share)

| Spec section | Task |
|---|---|
| §3 contracts owned by the schema artifact | A.1, A.2 |
| §3.2 vocabularies as data | A.1 (enum lives in the vector set) |
| §4 row 4 verifier vacuity | A.3 |
| §5.1 lifecycle - no process state | A.5 (recorded), asserted in every task's report |
| §5.2 index is derived, CI regenerates and diffs | A.4 |
| §6 test cells - store empty must fail | A.3 |

**Not Car 1's** and deliberately absent: §2 producer and hooks (Car 2), §4 rows 1-3 and 5-6
(Cars 2 and 3), §7 probes (blocking tests before Car 2), §9 documentation rows (Cars 2 and 3).

## Task count and running totals

5 tasks. Suite baseline **21 → ~29** passing (exact count is the car's to report, not the
plan's to predict). Ledger: created at A.5 with **0 fields**, and the car re-reads live at
dispatch.

---

## The plan-review record (rule 5)

*Pending. The plan adversary runs BEFORE any car dispatches, on five dimensions: (a) spec
coverage walked independently; (b) inter-task interface consistency — Consumes/Produces agree,
since each car sees only its own task; (c) **the sentence check on every snippet** — open the
real file at base; every API a snippet calls must exist with that signature; (d) red validity —
would each stated red fail for its STATED reason at its point in the sequence; (e) amendment-block
fidelity to the spec rather than re-derived.*

*The plan-writer performed (c) on itself before writing: `Verify-Verdict.ps1:24`, `:87-90`,
`:94-96`, `ci.yml:47`, `ci.yml:62`, `Board.psm1:194` and the Pester 5 `Describe`/`It`/`Should`
forms were each opened at `d70069e`. The adversary re-verifies rather than trusting this note.*
