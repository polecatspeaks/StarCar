Status: Current

# Dispatch harness - Car 1 implementation plan, rev 2 (schema, validator, verifier, index, contracts)

REQUIRED SUB-SKILL: one car per task group, adversarial reviewer per car.

Source of truth: `docs/specs/2026-07-22-dispatch-harness-spec.md` **APPROVED plus BINDING
AMENDMENT S1** (the §4-row-4 "exits 0" claim was falsified empirically at this rung; S1
supersedes it and rewrites §6's non-vacuity item). Design: rev 6 + A1.

Review record: **round 1 REJECT - 7 Major, 8 Minor**
(`docs/reviews/2026-07-22-plan-review-car1-round1.md`). Every finding is folded inline
below, tagged `[PR1-Mn]` / `[PR1-mn]`; the disposition table at the end is the carrier the
delta re-review walks. Rev 2 also complies with `worked-plan.md` **Amendment 1**, minted
from that round: **every behavioural claim below was RUN by the plan-writer and quotes the
observed result**; structural claims were opened at base. Which part each claim got is
stated where it appears.

**Scope: Car 1 only.** Cars 2 and 3 are planned after Car 1 lands - Car 1 is the
owner-approved **model probe** (car on Sonnet, reviewer on Opus; the reviewer reports
execution-class defects separately, because that is the signal that moves cars 2-3 back to
Opus). Round 1's probe report attributed three execution defects to this measurement; the
conductor corrected the record: the plan was written by the conductor, so those defects
carry **zero signal about the car model**. The probe is unfired and still valid.

> # BINDING AMENDMENT BLOCK (conductor-applied)
> *Empty at rev 2. Round-1 rework landed as plan edits (this whole revision), per
> `worked-plan.md:134` - the amendment block is for invalidations found AFTER the plan is
> approved and cars are in flight. The car reads this block FIRST.*

## Base, baselines, and the STOP rule

Base commit for the car: **the commit that lands this rev 2** - verify by
`git log -1 --format=%H -- docs/plans/2026-07-22-harness-car1-plan.md` matching your
worktree HEAD's history and this file's text matching the committed version. [Round-1
NOTE folded: rev 1 pinned a base that predated the plan file itself; harmless there,
avoided here.] Baselines at dispatch, re-derived by the car, STOP on mismatch:

- `Invoke-Pester -Path ./scripts/tests` (under **pwsh 7**, see runtime floor): **21 passing, 0 failed**
- `./scripts/Verify-Verdict.ps1` (bare): **12 verdict files verified, exit 0**

## Global constraints

Red-first TDD per step; ledger same-commit for state (BOTH kinds - see A.5); docs updated
in the invalidating commit; **honest-stop on any plan-vs-code contradiction is a SUCCESS
outcome**; the car never pushes; the car commits locally per task.

**RUNTIME FLOOR [PR1-M4, folded]:** all NEW modules, scripts, and tests in this train
target **PowerShell 7.4+** (`pwsh`), declared with `#requires -Version 7.4` in each new
file. Named load-bearing API: `Test-Json -Schema` (draft 2020-12). Measured by the
plan-writer: **present in pwsh 7.6.3** (`Get-Command Test-Json` returned True; an
`if`/`then` conditional-required schema validated good=True / bad=False), **absent in
Windows PowerShell 5.1.26100** (returned False). CI already runs `pwsh`
(`ci.yml:42/50/71` - structural, opened at base). EXISTING scripts
(`Verify-Verdict.ps1:20`'s 5.1 convention) keep their declared compatibility; the floor
applies to the new module family only, so there is no menu: the car uses `Test-Json`,
never a hand-rolled second copy of the schema (Law 6). The suites are run under `pwsh` -
state the shell in every count you report.

### Conductor rulings (recorded, reviewable)

**R1v2 [PR1-M4, supersedes R1]:** the schema artifact is a language-neutral **JSON Schema
(draft 2020-12) plus conformance vectors**; the vectors are the portable conformance
suite (Law 7 - a stranger implements a validator in their stack against the same
vectors); this shop's implementation is `scripts/Artifact.psm1` on the pwsh 7.4 floor
using `Test-Json`. R1's form survives; its undeclared toolchain dependency is now
declared and measured, and the menu is closed.

**R2 [PR1-M7]:** identity is **one key: `subject`**. For the three dispatch kinds its
value IS the dispatch id (spec §3.1 [m6]: *"the subject of a dispatch-lifecycle record IS
its dispatch"*); `intent` and `ruling` carry non-dispatch subjects in the same field.
There is **no `dispatch_id` field**. One join key, Law 6.

**R3 [PR1-M1, PR1-M6, per spec amendment S1]:** the verifier's vacuous and crashing exits
are retired **unconditionally - no switch**. Round 1 falsified both premises: the
empty-store "exits 0" claim (it crashes, exit 1, `:95-96` dead) and the default-off
justification (`docs/reviews/` holds 12 files, so an armed check leaves `ci.yml:47` green
untouched either way). A switch whose arming depends on Car 3 remembering is the
vigilance tier; unconditional behaviour needs no memory. Absent dir: exit 1 naming it;
zero verdict files: exit 1 with an actionable named-directory message replacing the
strict-mode crash; the dead code is removed. `ci.yml` is untouched at Car 1 (spec ruling
4 puts the repoint in Car 3's migration commit).

---

## Car 1 - Tasks A.1-A.5

### Task A.1 - the artifact schema, its vocabularies, and its conformance vectors

**Files:** Create `schema/starcar-artifact.schema.json`; Create `schema/vocab/kinds.json`
and `schema/vocab/outcomes.json` [PR1-M3]; Create `schema/index-format.md` [PR1-M2];
Create `schema/vectors/` (each case a `.json` with a sibling `.expect` of `valid` or
`invalid`); Create `scripts/tests/Schema.Tests.ps1`.

**Interfaces - Produces.** Spec §3 assigns the schema artifact six contracts: *"field
names, types, ordering, identity, the index format, and the path-normalisation
substitution rule."* All six are enumerated here [PR1-M2 - rev 1 delivered two]. Car 2
and the yard train consume this block blind.

*Fields (names and types):*

| Field | Type | Required | Authority |
|---|---|---|---|
| `schema` | const `starcar-artifact/1` | always | design §0 |
| `kind` | **string - NOT an enum** [PR1-M3] | always | spec §3.1, §3.2 |
| `subject` | string - **THE identity key**; for dispatch kinds its value is the dispatch id [R2] | always | spec §3.1 [m6] |
| `session_id` | string | always | design §5.1 |
| `at` | string, ISO-8601 UTC | always | spec §3.1 (latest-`at` wins) |
| `outcome` | string, vocabulary `outcomes.json` | when `kind` = `returned` | spec §2.3 |
| `findings` | string | when `kind` = `returned` | spec §2.3 |
| `envelope` | string, `absent` or `malformed` - records the envelope fault class | optional, only meaningful on `returned` | spec §2.3 [PR1-M2]: *"Absent and malformed are different faults"*, both land with the body intact |
| `budget` | number (seconds) | optional - shop default applies at FOLD time, never infinite (the default is the detector's, not the schema's) | spec §3.3 [PR1-M2] |
| `basis` | object: `observed`, `by`, `against_budget` | when `kind` = `presumed-lost` | spec §3.3 [PR1-M2] |
| `cost` | object | optional - **producer-optional by Law 7** | spec §3.4 |
| `context_peak_tokens` | number | optional | spec §3.4 |
| `producer` | string | optional | spec §3.4 |
| `normalisation` | array of `{from_class, to}` substitution declarations - **declared in each landed artifact** | always (empty array = nothing substituted) | spec §3.6 [PR1-M2] |
| `integrity` | string, `sha256:<hex>` over the canonical body | always | spec §3.6 [PR1-M2] |

*Vocabularies as DATA [PR1-M3]:* `kind` and `outcome` are `type: string` in the schema -
**never `enum`** - because spec §3.2 requires an unrecognised value to be *"a discovery,
not a bug"*, and a schema enum makes it a validation failure; the two cannot both hold.
The vocabularies ship as `schema/vocab/kinds.json` (initial: `dispatched`, `returned`,
`presumed-lost`, `intent`, `ruling`) and `schema/vocab/outcomes.json` (initial: `APPROVE`,
`APPROVE-WITH-REBASE-LIST`, `REJECT`, `error`, `honest-stop`). Recognition against them is
A.2's job and is REPORTING, not validation. Two vectors pin the behaviour: an
unrecognised `kind` is schema-**valid** (`.expect` = `valid`) with a discovery reported.

*Ordering [PR1-M2]:* canonical serialisation order is the field order of the table above,
stated as a `field-order` array inside `schema/index-format.md`. A.4's byte-identical
determinism consumes this; it is the schema artifact's to own, not the generator's to
invent.

*Index format [PR1-M2]:* `schema/index-format.md` defines the committed index - one row
per artifact, columns `subject | kind | at | outcome | file`, rows sorted by `at` then
`subject` then `file` (a total order - determinism requires no ties). A worked example
index is part of the file.

*Path-normalisation substitution rule [PR1-M2]:* defined in `schema/index-format.md`
alongside the ordering: the mechanical classes from `Land-Verdict.ps1`'s
`ConvertTo-PortablePaths` precedent (structural - opened at base: `:118-166`) - absolute
repo paths to `<repo>`, home directories to `~`, each substitution declared in the
artifact's `normalisation` field.

*Vectors (minimum eight):* valid `dispatched`; valid `returned` (with `outcome`,
`findings`, `integrity`, `normalisation`); valid `presumed-lost` with `basis`; valid
record with unrecognised `kind` vocabulary value [the discovery vector]; invalid:
missing `kind`; invalid: `returned` missing `outcome`; invalid: `presumed-lost` missing
`basis`; invalid: missing `integrity`.

- [ ] **Step 1 - write the failing tests**

```powershell
#requires -Version 7.4
Describe 'Artifact schema and conformance vectors' {
    BeforeAll {
        $script:Root    = (git rev-parse --show-toplevel)
        $script:Schema  = Join-Path $script:Root 'schema/starcar-artifact.schema.json'
        $script:Vectors = Join-Path $script:Root 'schema/vectors'
        $script:Vocab   = Join-Path $script:Root 'schema/vocab'
    }

    It 'the schema file exists and is parseable JSON' {
        Test-Path $script:Schema | Should -BeTrue
        { Get-Content $script:Schema -Raw -Encoding UTF8 | ConvertFrom-Json } | Should -Not -Throw
    }

    It 'kind and outcome are strings in the schema, never enums (vocabularies are data)' {
        $s = Get-Content $script:Schema -Raw -Encoding UTF8 | ConvertFrom-Json
        $s.properties.kind.type | Should -Be 'string'
        $s.properties.kind.PSObject.Properties.Name | Should -Not -Contain 'enum'
    }

    It 'both vocabulary files exist and parse' {
        Test-Path (Join-Path $script:Vocab 'kinds.json') | Should -BeTrue
        Test-Path (Join-Path $script:Vocab 'outcomes.json') | Should -BeTrue
    }

    It 'ships at least eight vectors, each with an .expect sibling' {
        $cases = Get-ChildItem $script:Vectors -Filter *.json -ErrorAction SilentlyContinue
        $cases.Count | Should -BeGreaterOrEqual 8
        foreach ($c in $cases) {
            $expect = [System.IO.Path]::ChangeExtension($c.FullName, '.expect')
            Test-Path $expect | Should -BeTrue -Because "$($c.Name) needs an .expect sibling"
            (Get-Content $expect -Raw).Trim() | Should -BeIn @('valid','invalid')
        }
    }
}
```

- [ ] **Step 2 - run, confirm the red REASON**

`Invoke-Pester -Path ./scripts/tests/Schema.Tests.ps1` under pwsh. **RUN by the
plan-writer at base (Amendment 1), a reduced two-`It` form of this file, observed:**
`FAIL=2` - *"Expected $true, but got $false."* (schema file absent) and *"Expected the
actual value to be greater than 1, but got 0."* (no vectors). The round-1 reviewer ran
the rev-1 block verbatim and observed the same two messages. All four `It`s red at base
for the file-absent reason; a red for any other reason is a finding to report.

- [ ] **Step 3 - minimal implementation:** the schema (with `if`/`then` for the
  conditional requirements - the plan-writer measured `Test-Json` honouring `if`/`then`
  on 2020-12: good=True, bad=False), both vocab files, `schema/index-format.md`, the
  eight vectors.
- [ ] **Step 4 - green + suite:** `Invoke-Pester -Path ./scripts/tests` under pwsh:
  **21 + 4 = 25** passing, 0 failed expected. State the observed count.
- [ ] **Step 5 - commit:** `feat(schema): artifact schema, vocabularies as data, conformance vectors (#7)`

**Ledger (both parts [PR1-M5]):** no mutable process state; no derived committed
artifacts in this task (schema, vocab, and vectors are AUTHORED sources, not generated) -
state both halves explicitly.

### Task A.2 - the PowerShell validator (this shop's implementation of A.1)

**Files:** Create `scripts/Artifact.psm1`; Create `scripts/tests/Artifact.Tests.ps1`.

**Interfaces - Consumes:** A.1's schema, vocab files, vectors. **Produces (Car 2 consumes
blind):**

```
Test-StarcarArtifact -InputObject <psobject> -SchemaPath <path> [-VocabDir <path>]
```

returning `[pscustomobject]@{ Valid = [bool]; Errors = [string[]]; Discoveries = [string[]] }`
- `[pscustomobject]`, matching `Board.psm1:188-191`'s pattern (structural - opened at
base), **not a hashtable** [PR1-m3]. `-SchemaPath` is explicit [PR1-m5]; `-VocabDir`
defaults to the schema's sibling `vocab/`. `Valid` is schema validation via `Test-Json`.
`Discoveries` lists unrecognised vocabulary values **by name** (spec §3.2) - a discovery
never sets `Valid` false. An **unreadable vocabulary file is ONE entry in `Errors`**
(spec §3.2: one board-level fault, never N per-lane faults). Module header:
`#requires -Version 7.4`. Pattern per `Board.psm1`: pure functions,
`Export-ModuleMember -Function` at end (`Board.psm1:194`, structural - opened at base).

- [ ] **Step 1 - write the failing tests** - table-driven over the vector directory at
  **discovery time** [PR1-m4: the Pester 5 trap is enumerating in `BeforeAll`;
  enumeration must happen in `BeforeDiscovery`]. **RUN by the plan-writer (Amendment 1):
  a two-vector probe of exactly this shape observed `PASS=2 TOTAL=2` with per-vector
  names expanded (`vector v1.json expects valid`), confirming discovery-time enumeration
  binds in installed Pester 5.8.0:**

```powershell
#requires -Version 7.4
BeforeDiscovery {
    $repoRoot = (git rev-parse --show-toplevel)
    $vectorCases = Get-ChildItem (Join-Path $repoRoot 'schema/vectors') -Filter *.json |
        ForEach-Object {
            @{ Name   = $_.Name
               Path   = $_.FullName
               Expect = (Get-Content ([System.IO.Path]::ChangeExtension($_.FullName, '.expect')) -Raw).Trim() }
        }
}

Describe 'Test-StarcarArtifact conformance' {
    BeforeAll {
        $repoRoot = (git rev-parse --show-toplevel)
        Import-Module (Join-Path $repoRoot 'scripts/Artifact.psm1') -Force
        $script:SchemaPath = Join-Path $repoRoot 'schema/starcar-artifact.schema.json'
        $script:RepoRoot = $repoRoot
    }

    It 'vector <Name> validates as <Expect>' -ForEach $vectorCases {
        $obj = Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json
        $r = Test-StarcarArtifact -InputObject $obj -SchemaPath $script:SchemaPath
        $r.Valid | Should -Be ($Expect -eq 'valid')
    }

    It 'an unrecognised kind is a DISCOVERY by name, never invalid' {
        $obj = [pscustomobject]@{ schema='starcar-artifact/1'; kind='migrated';
            subject='x'; session_id='s'; at='2026-07-22T00:00:00Z';
            normalisation=@(); integrity='sha256:0' }
        $r = Test-StarcarArtifact -InputObject $obj -SchemaPath $script:SchemaPath
        $r.Valid | Should -BeTrue
        $r.Discoveries | Should -Contain 'kind: migrated'
    }

    It 'an unreadable vocabulary file is ONE error, not N' {
        $r = Test-StarcarArtifact -InputObject ([pscustomobject]@{}) `
            -SchemaPath $script:SchemaPath -VocabDir (Join-Path $script:RepoRoot 'no-such-dir')
        ($r.Errors | Where-Object { $_ -match 'vocab' }).Count | Should -Be 1
    }
}
```

- [ ] **Step 2 - run, confirm the red REASON.** **RUN by the plan-writer at base,
  observed verbatim:** *"The specified module './scripts/Artifact.psm1' was not loaded
  because no valid module file was found in any module directory."* Module-not-found is
  the correct red for a genuinely new module. (The `-ForEach` cases enumerate at
  discovery from A.1's landed vectors - the car runs A.2 after A.1, so the vectors
  exist and the red is the Import-Module failure alone.)
- [ ] **Step 3 - implement** `Test-StarcarArtifact`: `Test-Json` for `Valid`/`Errors`,
  vocab recognition for `Discoveries`, `try/catch` around vocab reads collapsing to one
  error.
- [ ] **Step 4 - green + suite:** **25 + 8 (vectors) + 2 = 35** passing expected; the
  exact observed count is the car's to report.
- [ ] **Step 5 - commit:** `feat(schema): pwsh validator - Test-Json shape, vocab discoveries (#7)`

**Ledger (both parts):** no mutable process state; no derived committed artifacts (pure
functions) - state both.

### Task A.3 - retire the verifier's vacuous and crashing exits [R3; spec amendment S1]

**Files:** Modify `scripts/Verify-Verdict.ps1`; Create `scripts/tests/VerifyVerdict.Tests.ps1`.

**The defect, MEASURED at base (Amendment 1 - rev 1 claimed this from reading and was
wrong [PR1-M1]):** absent directory: `:87-90` prints *"No [dir] directory. Nothing to
verify."* and **exits 0** (observed) - the real vacuity. Zero-`.md` directory:
**crash** - `PropertyNotFoundStrict` thrown at `:94` (`Set-StrictMode -Version Latest`
at `:27` meets the `$null` that `:91`'s empty pipeline returns), **exit 1** (observed;
the round-1 reviewer and the conductor re-derived it independently). `:95-96` is
unreachable dead code; the *"No verdict files found"* message cannot be emitted on any
path. A truthful exit code delivered as a stack trace is a Law 5 defect: it degrades
loudly but unactionably.

**The fix is unconditional - no switch [R3, PR1-M6].** `ci.yml:47`'s bare invocation
stays green because `docs/reviews/` holds 12 verdict files at base (measured); `ci.yml`
is not touched in this task (the repoint is Car 3's migration commit, spec ruling 4; the
vacuity-refusal precedent for Pester is `ci.yml:76-81` [PR1-m1 - rev 1 miscited `:62`]).

- [ ] **Step 1 - write the failing tests**

```powershell
#requires -Version 7.4
Describe 'Verify-Verdict refuses vacuous passes and crashes' {
    BeforeAll {
        $script:Root   = (git rev-parse --show-toplevel)
        $script:Script = Join-Path $script:Root 'scripts/Verify-Verdict.ps1'
        $script:Empty  = Join-Path $TestDrive 'empty-store'
        New-Item -ItemType Directory -Path $script:Empty | Out-Null
    }

    It 'an ABSENT directory exits non-zero and names it' {
        $out = & pwsh -NoProfile -File $script:Script -ReviewsDir (Join-Path $TestDrive 'no-such-dir') 2>&1
        $LASTEXITCODE | Should -Be 1
        ($out -join ' ') | Should -Match 'no-such-dir'
    }

    It 'a directory with ZERO verdict files exits non-zero with an actionable message, not a crash' {
        $out = & pwsh -NoProfile -File $script:Script -ReviewsDir $script:Empty 2>&1
        $LASTEXITCODE | Should -Be 1
        ($out -join ' ') | Should -Match 'zero verdict files'
        ($out -join ' ') | Should -Not -Match 'PropertyNotFoundStrict'
    }

    It 'the populated default store still verifies clean (no regression)' {
        & pwsh -NoProfile -File $script:Script *> $null
        $LASTEXITCODE | Should -Be 0
    }
}
```

- [ ] **Step 2 - run, confirm the red REASONS (both measured at base by the
  plan-writer):** test 1 fails *"Expected 1, but got 0."* (absent dir exits 0 today).
  Test 2's exit-code assertion PASSES (the crash already exits 1) and the test fails on
  the NEXT assertion - *"Expected regular expression 'zero verdict files' to match..."* -
  because today's output is the strict-mode stack trace. **That partial-pass is expected
  and stated here so the car does not mistake it for a wrong red.** Test 3 passes at
  base (12/12 clean, measured) - it is the regression pin, not a red.
- [ ] **Step 3 - implement:** `:87-90` absent: error naming the directory, exit 1;
  `:91`'s result coerced with `@(...)`; `:94-96` replaced by an actionable zero-files
  error naming the directory, exit 1. Keep 5.1 compatibility for THIS script (`:20`'s
  existing convention - the floor applies to new files).
- [ ] **Step 4 - green + suite:** **35 + 3 = 38** expected; bare
  `./scripts/Verify-Verdict.ps1` re-run: **12 verified, exit 0** - the regression pin.
- [ ] **Step 5 - commit:** `fix(verify): absent store fails loudly, empty store fails actionably, dead path removed (#7)`

**Ledger (both parts):** none / none - state both.

### Task A.4 - the deterministic artifact index generator

**Files:** Create `scripts/New-ArtifactIndex.ps1`; Create `scripts/tests/ArtifactIndex.Tests.ps1`.

**Interfaces - Consumes:** `schema/index-format.md` (A.1's columns, sort order,
field-order - the generator IMPLEMENTS that contract, it does not define one [PR1-M2]).
**Produces:** `New-ArtifactIndex -StoreRoot <path> -OutFile <path>` - deterministic:
same store, byte-identical output (LF, UTF-8 no BOM, per the repo's landed
`WriteAllText` precedent in `Land-Verdict.ps1`). Spec §5.2: the committed index is
derived state; CI regenerate-and-diff is Car 3's gate; the generator itself is
stateless. `#requires -Version 7.4`.

- [ ] **Step 1 - write the failing tests:** fixture store with three artifacts (two
  subjects, one superseded pair) - one row per artifact, sorted per
  `schema/index-format.md`; **and two runs produce byte-identical files**
  (`Get-FileHash` equality) - the property Car 3's diff gate stands on.
- [ ] **Step 2 - run, confirm the red REASON.** **RUN by the plan-writer at base,
  observed verbatim:** *"CommandNotFoundException: The term
  './scripts/New-ArtifactIndex.ps1' is not recognized as a name of a cmdlet, function,
  script file, or executable program."*
- [ ] **Step 3 - implement.**
- [ ] **Step 4 - green + suite:** **38 + 2 = 40** expected.
- [ ] **Step 5 - commit:** `feat(index): deterministic index generator per schema/index-format.md (#7)`

**Ledger (both parts [PR1-M5]):** no mutable process state. **Derived committed
artifacts: the index file class is BORN here** - the generator exists but no index is
committed until Car 3 migrates the store, so the ledger row lands in A.5 with status
"generator landed, no instance yet; CI diff gate lands Car 3" - see A.5.

### Task A.5 - instantiate both contract files (all five steps [PR1-m2])

**Files:** Create `docs/contracts/state-ledger.md`; Create `docs/contracts/gating-matrix.md`;
Modify `docs/templates/state-ledger.md:4` and `docs/templates/gating-matrix.md:4`
[PR1-m6 - both trigger lines say "copy me when the first X lands"; this task IS that
trigger firing, and the same-commit documentation law binds the template lines this
commit invalidates: each gets a "first copied: 2026-07-22, dispatch harness Car 1"
annotation in THIS commit].

Templates: `docs/templates/state-ledger.md`, `docs/templates/gating-matrix.md`; filled
anatomy: `docs/templates/worked-ledger-and-gating.md`.

**The state ledger asks BOTH questions [PR1-M5 - rev 1 asked only the first and
re-armed the narrowing spec ruling 6 struck]:**

1. *Mutable process state:* **none** - with the reasoning (the one-writer premise
   removed remembered identity, dedup, and clock state), so a later reviewer sees a
   deliberate claim, not an omission. Also recorded per spec §9 rows 1-2 [PR1-m8]: the
   store is **append-only under git**, and process state is nil - both claims, not one.
2. *Derived committed artifacts:* **one row** - the artifact index (class born in A.4):
   generated file, committed, staleness owner CI regenerate-and-diff, **gate lands Car
   3; until then the posture is DELIBERATE no-gate, and that posture is itself the row**
   (`worked-ledger-and-gating.md`: a deliberate no-gate posture is still a row).

**The gating matrix gets three rows** - tier 1 detection, tier 2 detection, index
staleness - each with fires-when / suppressed-when / resets-on / classification /
evidence. **Evidence for gates whose tests land in later cars is written as the planned
test name marked pending** [PR1-m7 - e.g. *"pending - lands Car 3 as the
ArtifactIndex-staleness CI step"*], never left blank and never faked as an existing
test name.

- [ ] **Step 1 - the red is the existing gate:** no new test file - the red is
  `DocPolicy.Tests.ps1` firing on the two new files before their `Status:` headers
  exist.
- [ ] **Step 2 - run, confirm the red REASON.** **RUN by the plan-writer at base,
  fault-injected and reverted (tree clean, 0 untracked after):** a Status-less
  `docs/contracts/probe.md` produced `PASS=1 FAIL=1`, observed message *"Expected $null
  or empty, but got 'docs/contracts/probe.md -> (no Status line at all)'."* - confirming
  `DocPolicy.Tests.ps1` walks `docs/` recursively and catches new files under
  `docs/contracts/`. The car repeats this red with its real files (write the bodies
  first, run, observe the two flags, then add the headers).
- [ ] **Step 3 - write both files** with `Status: Current` headers, per the templates,
  and annotate the two template trigger lines.
- [ ] **Step 4 - green + suite:** **40** passing expected (DocPolicy's walk is a loop
  inside one `It` - the count does not move [round-1 NOTE folded]); 0 failed.
- [ ] **Step 5 - commit:** `docs(contracts): state ledger (both questions) + gating matrix; template triggers fired (#7)`

**Ledger:** this task CREATES it - content per above; the arithmetic is
"process 0 -> 0; derived-artifact classes 0 -> 1 (index, no instance yet)".

---

## Spec-coverage table - SUBSECTION-granular [PR1-M2/M3/m8; Amendment 1]

| Spec subsection | Disposition |
|---|---|
| §1 problem | narrative - no task |
| §2.1 producer hooks | **Car 2** (deferred) |
| §2.2 `agent_type` filter | **Car 2** |
| §2.3 envelope + absent/malformed faults | fault VALUES: A.1 (`envelope` field); producer/detector behaviour: **Car 2** |
| §2.4 concurrent writes | **Car 2** |
| §2.5 detector tiers; [m5] CI fetch | **Car 2 / Car 3** |
| §3 preamble: six schema-owned contracts | A.1 - all six enumerated (fields, types, ordering, identity [R2], index format, normalisation rule) |
| §3.1 kinds, precedence, supersession | kind vocabulary: A.1; precedence/supersession FOLD behaviour: **Car 2** |
| §3.2 vocabularies as data | A.1 (data files) + A.2 (discovery reporting, one-fault vocab read) |
| §3.3 budget, gradient, `basis` | fields: A.1; fold gradient and shop default: **Car 2** |
| §3.4 cost/context producer-optional | A.1 (optional fields) |
| §3.5 un-backfilled gap first-class | **Car 2** (fold state) |
| §3.6 normalisation declared, original preserved, integrity hash | declared + hash: A.1 fields and rule; checkpoint-preservation claim: standing (Entire), restated in A.5's ledger |
| §4 row 1 (hardcoded path) | **Car 2** (producer replaces Land-Verdict's derivation) |
| §4 row 2 (parent scraping) | **Car 2** |
| §4 row 3 (seven-param CLI) | **Car 2** |
| §4 row 4 (vacuous exits) **as amended by S1** | A.3 |
| §4 row 5 (store migration) | **Car 3** |
| §5.1 process state none | A.5 ledger question 1; honest-stop tripwire restated in every task's ledger line |
| §5.2 derived index, CI diff | generator: A.4; ledger row: A.5; CI gate: **Car 3** |
| §6 cells (fold behaviours) | **Car 2** |
| §6 non-vacuity: `agent_type` flood | **Car 2** |
| §6 non-vacuity: store empty **(S1 three-part form)** | A.3 (parts a, b, c) |
| §6 non-vacuity: stale index | **Car 3** (enabler: A.4's determinism test) |
| §7 probes 1-4 | blocking tests **before Car 2** (unchanged) |
| §8 non-goals | binds all cars - no board rendering in this train |
| §9 rows 1-2 (ledger + gating contracts) | **A.5** [PR1-m8 - rev 1 wrongly deferred these] |
| §9 rows 3-9 | **Cars 2 and 3** |

## Task count and totals

5 tasks, one car. Suite trajectory (expected; the car reports observed, under pwsh):
21 -> A.1 25 -> A.2 35 -> A.3 38 -> A.4 40 -> A.5 40. Verify-Verdict bare: 12/12 exit 0
at every commit.

## Round-1 finding disposition [the carrier the delta re-review walks]

| ID | Finding (compressed) | Disposition in rev 2 |
|---|---|---|
| PR1-M1 | A.3's red factually wrong; specified test passes on arrival | Folded: A.3 rewritten from MEASURED behaviour; spec amended (S1); both reds observed and quoted |
| PR1-M2 | Five fields + ordering + index format + normalisation rule dropped | Folded: A.1's Produces enumerates all six contracts and all fields, each with spec authority |
| PR1-M3 | §3.2 claimed, not delivered; enum contradicts discovery | Folded: vocab data files in A.1; `kind` de-enumed with a test pinning it; discovery vector + A.2 `Discoveries` |
| PR1-M4 | R1 left the validation engine unnamed; menu | Folded: R1v2 + runtime floor, `Test-Json` measured on both shells |
| PR1-M5 | Ledger narrowed to "service" state; index row missing | Folded: two-question ledger in A.5; index row born in A.4, recorded in A.5 |
| PR1-M6 | Default-off switch on a false premise | Folded: R3 - no switch, unconditional, premise re-measured (12 files) |
| PR1-M7 | Double identity key | Folded: R2 - single `subject` key, no `dispatch_id` |
| PR1-m1 | `ci.yml:62` miscited | Folded: `:76-81` cited in A.3 |
| PR1-m2 | A.5 had no steps 1-4 | Folded: all five steps present |
| PR1-m3 | hashtable vs pscustomobject | Folded: `[pscustomobject]`, `Board.psm1:188-191` cited |
| PR1-m4 | No snippets; BeforeDiscovery trap | Folded: full snippets in A.1/A.2/A.3; A.2 uses `BeforeDiscovery`, probed (`PASS=2 TOTAL=2` observed) |
| PR1-m5 | No `-SchemaPath` | Folded: explicit parameter |
| PR1-m6 | Template trigger lines invalidated, not updated | Folded: both template files in A.5's Files, same commit |
| PR1-m7 | Gating Evidence unsatisfiable for future gates | Folded: pending-with-planned-name instruction |
| PR1-m8 | §9 rows 1-2 are Car 1's | Folded: A.5 + coverage table row |

---

## The plan-review record (rule 5)

Round 1: **REJECT - 7 Major, 8 Minor** (`docs/reviews/2026-07-22-plan-review-car1-round1.md`).
Convergence context for the delta re-review: this is round 2; the findings above are
folded per the disposition table; the reviewer walks the IDs Present / Absent / DRIFTED
and rules on convergence as well as correctness. Amendment 1 evidence in this revision:
seven behavioural probes run by the plan-writer at base (`Test-Json` presence on both
shells; `Test-Json` if/then; A.1's red; A.2's red; A.3's absent-dir and empty-dir
behaviour; A.5's fault-injection; `BeforeDiscovery` expansion), each quoted where used;
the adversary re-verifies rather than trusting the notes.
