<!-- starcar-integrity: sha256=ddad28a02bce220b245f028be6227f8638a8531f1d435a5a604887be934e0278 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Plan review: dispatch harness Car 1, round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Plan review (adversarial, 5 dimensions)
Round: 1
Target: `docs/plans/2026-07-22-harness-car1-plan.md`
Base reviewed: `4267371992cb9d1d3f3d239f4d2829f470b7f014`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `aed8b69593d8924f8`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `4267371992cb9d1d3f3d239f4d2829f470b7f014` |
| Entire checkpoint | `131ef9833083` |
| Dispatch, the locator within the session | `aed8b69593d8924f8` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 4267371992cb9d1d3f3d239f4d2829f470b7f014
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

**REJECT.** Seven Major, eight Minor. Two Majors are execution-class: a stated red that is factually wrong about the code's behavior (A.3), and a schema Produces block that drops five spec-mandated fields Car 2 consumes blind.

---

# Base and baseline verification

| Claim | Plan says | I measured | Result |
|---|---|---|---|
| Worktree HEAD | — | `4267371992cb9d1d3f3d239f4d2829f470b7f014` | matches brief |
| Car base `d70069e` | plan:11 | `d70069e9b405b769d916ccc0f2f16d162940b2f6`, parent of `4267371` | exists |
| Pester baseline | 21 passing (plan:42) | `PASSED=21 FAILED=0 TOTAL=21` at `4267371` | **confirmed** |
| Verify-Verdict baseline | 11/11, exit 0 (plan:42-43) | 11 files `OK`, `LASTEXITCODE=0` | **confirmed** |

Both baselines hold at `d70069e` *and* `4267371` — `DocPolicy.Tests.ps1` is 2 tests regardless of doc count (the per-file walk is a loop *inside* one `It` at `DocPolicy.Tests.ps1:44`), so the plan commit itself did not move the count. No STOP condition. Fault injection reverted; tree byte-identical clean, verified above.

---

# (c) The sentence check, snippet by snippet

I ran the A.1 block **verbatim** as `scripts/tests/Schema.Tests.ps1`, red and green, then reverted.

| API called | File:line in plan | Exists at base? | Evidence |
|---|---|---|---|
| `git rev-parse --show-toplevel` in `BeforeAll` | plan:80 | **YES** | identical pattern at `DocPolicy.Tests.ps1:24`; resolved and both `It`s ran |
| `$script:` vars from `BeforeAll` into `It` | plan:80-82 | **YES** | `DocPolicy.Tests.ps1:24-25` + my green run |
| `Should -BeTrue` | plan:86 | **YES** | red fired: `Expected $true, but got $false.` |
| `Should -Not -Throw` on scriptblock | plan:87 | **YES** | passed in green run |
| `Should -BeGreaterThan` | plan:92 | **YES** | red fired: `Expected the actual value to be greater than 1, but got 0.` |
| `[System.IO.Path]::ChangeExtension(full, '.expect')` | plan:94 | **YES** | green run resolved `v1.json`→`v1.expect` |
| `Should -BeTrue -Because "..."` | plan:95 | **YES** | parameter bound; green |
| `Should -BeIn @('valid','invalid')` | plan:96 | **YES** | green |
| `Get-ChildItem -ErrorAction SilentlyContinue` → `$null.Count` | plan:91-92 | **safe** | no StrictMode in Pester default; returned 0, clean assertion |
| `Import-Module` nonexistent `.psm1` (A.2 red) | plan:137-138 | **YES, message accurate** | verbatim: `The specified module '&lt;fullpath&gt;\Artifact.psm1' was not loaded because no valid module file was found in any module directory.` |
| `Board.psm1:194` = `Export-ModuleMember -Function` | plan:130 | **YES** | file is 194 lines; :194 is the export |
| `Verify-Verdict.ps1:24` `$ReviewsDir='docs/reviews'` | plan:149 | **YES** | verbatim |
| `Verify-Verdict.ps1:87-90` exit 0 on absent dir | plan:150 | **YES** | measured `EXITCODE(absent)=0` |
| `Verify-Verdict.ps1:94-96` exit 0 on zero `.md` | plan:150-151 | **NO — see Major 1** | measured: **throws, exit 1** |
| `ci.yml:47` bare invocation | plan:151 | **YES** | verbatim |
| `ci.yml:62` "refuses for Pester" | plan:153 | **NO — see Minor 1** | :62 is the Pester *install-retry warning* |

**No snippet calls a nonexistent API.** The A.1 block is clean — genuinely better than the ancestor plan. The REJECT does not rest on dimension (c) for snippets; it rests on (c) applied to *asserted runtime behavior*, which is where this plan broke.

---

# Major findings

### MAJOR 1 — A.3's red is factually wrong, and the test it specifies passes on arrival
**plan:150-151, plan:161-163** vs **`scripts/Verify-Verdict.ps1:83-97`**

The plan asserts, as *"The defect, **verified at `d70069e`**"*, that `:94-96` exits **0** when the directory contains no `.md`, and specifies the red as *"the current code exits 0 with 'No verdict files found. Nothing to verify.' — 'Expected exit code not 0, but got 0'"*.

I ran it. Pointed at an existing empty directory:

```
The property 'Count' cannot be found on this object. Verify that the property exists.
At ...\scripts\Verify-Verdict.ps1:94 char:5
+ if ($files.Count -eq 0) {
EXITCODE(empty)=1
```

Cause: `Set-StrictMode -Version Latest` (`:27`) + `$ErrorActionPreference='Stop'` (`:28`). At `:91`, `Get-ChildItem $ReviewsDir -Filter *.md | ForEach-Object {...}` yields **`$null`** (not `@()`) when nothing matches, and `$null.Count` throws `PropertyNotFoundStrict`. Same result for a directory holding only non-`.md` files (`EXITCODE(nonmd)=1`).

Trace the reachability of `:94-96`: `:83` sets `@()`; if `-Path` is given, `:85` sets a 1-element array (Count 1); otherwise `:91` sets `$null` (0 files) or a populated result (Count ≥ 1). **`:95-96` is unreachable dead code.** The message the plan quotes cannot be emitted on any path.

Consequences, all load-bearing:
1. The stated red **does not fail for its stated reason**.
2. The plan's Step 1 test — *"pointed at an empty directory, the verifier must **exit non-zero**"* (plan:161-162) — **already passes at base**. A test that passes the moment you write it proves nothing (CLAUDE.md, TDD law). The car would write it, run it, see green, and per the plan's own instruction at plan:107 must honest-stop.
3. Step 3's `-RequireNonEmpty` ("Empty + switch = exit 1", plan:166) is a **no-op**: empty already exits 1. The car cannot demonstrate the switch does anything without first fixing the StrictMode crash, which the plan never mentions.
4. Spec §6's mandatory non-vacuity item (`spec:220`, *"Empty the store and confirm the extended verifier fails where today it exits 0"*) is **unsatisfiable as written**.

The spec carries the same error at `spec:175`, so the plan inherited it — but the plan **claimed to have verified it empirically** and did not. That claim is what makes this the plan's Major.

### MAJOR 2 — A.1's Produces block drops five spec-mandated schema fields; Car 2 consumes it blind
**plan:60-68** vs **`spec:96-97`, `spec:139`, `spec:156-163`**

`spec:96-97` names six things the schema artifact owns: *"field names, types, ordering, identity, **the index format**, and the **path-normalisation substitution rule**."* A.1's Produces covers field names and types. It is silent on **ordering**, **index format**, and the **normalisation substitution rule** — three of six, with no deferral.

Fields required by the approved spec and absent from plan:62-68:

| Missing field | Spec authority |
|---|---|
| integrity hash | `spec:161-163` — *"Each artifact carries an integrity hash"* |
| normalisation declaration | `spec:156-157` — *"DECLARED IN EACH LANDED ARTIFACT. A reader must be able to see what was substituted without leaving the file."* |
| `budget` | `spec:139` — *"Each dispatch carries a budget; a shop-level default applies when omitted"* |
| `presumed-lost` basis | `spec:142-143` — *"carries its own basis: what was observed, by whom, against which budget"* |
| `envelope: absent` / `envelope: malformed` | `spec:75-77` — *"Absent and malformed are different faults"* |

The plan's coverage table sweeps all of §3.1-§3.6 into one row (`plan:226`, *"§3 contracts owned by the schema artifact | A.1, A.2"*), which is precisely how these vanished. Per R1 the schema **is the product**; a product missing its integrity and provenance fields is not a partial delivery, it is the wrong artifact. Car 2 receives this Produces block as its blind contract and would have to invent five fields in a file Car 1 owns.

**Inter-task link:** A.4 requires byte-identical output (`plan:182-183`), which depends on the field **ordering** contract `spec:96` assigns to A.1 and A.1 never specifies. A.4's car invents the index format that `spec:96` says A.1 owns.

### MAJOR 3 — §3.2 is claimed as covered and is not delivered; the enum contradicts the requirement
**plan:71-73, plan:227** vs **`spec:124-128`**

The coverage table claims *"§3.2 vocabularies as data | A.1 (enum lives in the vector set)."* Independently walked, this fails twice:

1. **No vocabulary file is produced by any Car 1 task.** A.1's Files (plan:56-58) are the schema, the vectors, and a test. `spec:127` presumes a file exists — *"An **unreadable vocabulary file** is one board-level fault, never N per-lane faults."* Vectors are conformance test cases, not a runtime vocabulary source; "the enum lives in the vector set" does not give any consumer a vocabulary to read.
2. **The schema enum actively contradicts the spec.** plan:62-64 makes `kind` a hard `enum`. `spec:125-126` requires *"An unrecognised value is rendered loudly by name and treated as **a discovery, not a bug**."* A schema enum makes an unrecognised kind a **validation failure** — a bug. These cannot both hold.

§3.2 is not in the "Not Car 1's" deferral list (plan:233-234), so it is claimed-but-undelivered. This is also a Law 7 defect: `spec:127-128` records that rev 1 *"claimed Law 7 in its header while dropping Law 7's mechanism"* — the plan repeats that exact move.

### MAJOR 4 — R1 leaves A.2's validation engine unnamed, and every available fork is defective
**plan:30-35, plan:140** — my ruling on R1 is below; this is its implementation consequence.

R1 fixes draft 2020-12. A.2 Step 3 is one sentence: *"implement `Test-StarcarArtifact` against the schema."* I probed the actual toolchain:

- **Windows PowerShell 5.1** (this box's default, `5.1.26100.8875`): `Test-Json` **NOT AVAILABLE** — measured.
- **pwsh 7.6.3** (installed, and what CI uses — `ci.yml:42/50/71` all `shell: pwsh`): `Test-Json -Schema` present and correct on draft 2020-12. I validated four vectors including an `if`/`then` conditional-required rule and an enum; all four resolved correctly.

So the car faces a menu:
- **Use `Test-Json`** → the module works in CI and **fails on the local box**, and silently breaks the repo's declared convention at `Verify-Verdict.ps1:20`: *"Windows PowerShell 5.1 compatible: no ternary, no &amp;&amp;/||, ASCII only."* The plan's own Step 4 instructs a **local** `Invoke-Pester -Path ./scripts/tests` (plan:113) whose result would then depend on which shell the car happened to use. The plan declares no runtime floor anywhere.
- **Hand-roll the checks** → 5.1-safe, but produces a second encoding of the schema in PowerShell that can drift from the JSON — *"a second copy that can drift,"* which `constitution.md:50` (Law 6) forbids by name and `spec:196-197` invokes by name.

`spec:57-58` settled this class already: *"'Either is correct' is a **menu, not a requirement**, and an implementer seeing only its own task picks one."* The plan reintroduces the menu at the one place R1 was supposed to close it. R1 asserts it acts *"without inventing a toolchain"* (plan:34) while leaving an undischarged runtime dependency.

### MAJOR 5 — A.5's ledger re-arms the exact defect spec ruling 6 disarmed
**plan:217-218, plan:203-206** vs **`spec:193-201`, `spec:249`**

`spec:195` records ruling 6's finding: *"Rev 1's table considered only ***process*** state and therefore could not fail."* The remedy was `spec:196-200`: the index is *"a generated file **committed to git** - a second copy of the store that can drift... The generator is stateless; the ***artifact* is derived state**, and its freshness now has an owner."*

A.5 writes a ledger whose header is *"**0 → 0 fields** (no mutable **service** state)"* (plan:217-218). The qualifier "service" restores precisely the narrowing ruling 6 struck. The plan even states the correct fact at plan:179 — *"only the artifact is derived state"* — and then files it under A.4 with **no ledger row**.

It also drops half of the spec's own ledger content. `spec:249` requires the ledger to record *"that the store is **append-only under git** and process state is nil"* — two claims; A.5 carries only the second.

Answering the brief's question directly: **as specified, the zero-row ledger is ceremony, not a contract.** The claim does not survive A.4 — A.4 lands a committed derived artifact with a real staleness lifecycle and a CI owner, which is a ledger row (`worked-ledger-and-gating.md:73`: *"a DELIBERATE no-gate posture is still a row"*). An honest null is a fine thing; this one is null because it asked the narrower question.

### MAJOR 6 — `-RequireNonEmpty` default-off ships a disarmed guard on a premise I falsified
**plan:164-166**

The stated justification: default off *"so `ci.yml:47`'s bare invocation is unchanged at this commit and Car 3 turns it on with the repoint."*

The premise is unnecessary. `docs/reviews/` holds **11 `.md` files** at this base (measured). With the switch defaulted **ON**, `ci.yml:47`'s bare invocation encounters a non-empty directory and stays green — `ci.yml` is untouched at Car 1 either way. The constraint the plan invokes does not select default-off.

What default-off does select: after Car 1 lands, the default behavior is **still the vacuous pass**, and arming it depends on Car 3 remembering. There is no test asserting `ci.yml` carries the flag, and no gate that fails if it does not. That is the weakest tier in the Healing Loop — the shape `DocPolicy.Tests.ps1:5` was written to reject: *"a check that fires at CI beats a reviewer who must remember."*

Ruling-4 compliance is preserved under default-ON: `spec:175` requires the **repoint** and the `ci.yml:47` update in the migration commit; it does not require the guard to ship disarmed. Default-ON hands Car 3 an armed guard, and the migration commit moves the pointer with the guard already live.

### MAJOR 7 — `subject` + `dispatch_id` is a double identity key, against folded minor m6
**plan:62-66** vs **`spec:108-110`**

`spec:108-109`: *"**[m6] 'Subject' and 'dispatch' are the same key** for the three dispatch kinds - the subject of a dispatch-lifecycle record IS its dispatch... Identity is the schema artifact's."*

A.1 requires `subject` **always** and additionally requires `dispatch_id` **when kind is a dispatch kind** — two identifiers for the same thing on exactly the three kinds where m6 says there is one. Two keys that can disagree on the same record is Law 6 (`constitution.md:50`), and identity is the contract Car 2 joins records on, consumed blind.

*Alternative reading, stated for fairness:* `subject` could be intended as human-readable prose with `dispatch_id` as the machine key. If so, m6 is satisfied in spirit and the defect is that A.1's Produces block never says which field is identity — leaving the join key Car 2 depends on unstated. Either reading is a defect; a one-line conductor ruling closes it.

---

# Minor findings

1. **`ci.yml:62` miscited** (plan:153). Line 62 is `Write-Host "::warning::Pester install attempt $attempt failed..."`. The vacuous-pass refusal the plan is invoking is **`ci.yml:76-81`** (`if ($result.PassedCount -eq 0)` at :76, `Write-Error` at :79). Mechanical.
2. **A.5 has no Steps 1-4** (plan:195-218) — only *"Step 5 — commit."* The red is described in prose at plan:211-213 but never numbered, so the five-step red-first shape the exemplar mandates (`worked-plan.md:55-83`) is absent for this task.
3. **A.2's return shape contradicts its own pattern instruction.** plan:127 specifies `@{ Valid; Errors }` (hashtable); plan:129-130 says follow `Board.psm1`'s pattern, and `Board.psm1:188-191` returns `[pscustomobject]@{...}`. Differs under `ConvertTo-Json`, `.Keys`, and member enumeration. Car 2 consumes blind.
4. **A.2, A.3, A.4 carry no snippets**, against `worked-plan.md:79-80` (*"full code in a real plan - never 'implement the function'"*). A.2 additionally needs a Pester 5 snippet because table-driven `-ForEach` over a directory must enumerate at **discovery** time (`BeforeDiscovery`), not in `BeforeAll` — a well-known Pester 5 trap the plan's "table-driven" instruction (plan:133-136) walks the car straight into.
5. **A.2's `Test-StarcarArtifact` has no schema parameter** (plan:127) — no `-SchemaPath`. How it locates `schema/starcar-artifact.schema.json` is unstated.
6. **Template trigger lines invalidated, not updated in-commit.** `state-ledger.md:4` says copy it *"when the first mutable service state lands"*; `gating-matrix.md:4` says *"when the first gated surface lands."* A.5 instantiates both when neither has happened. A.5's Files (plan:197) lists only the two contract files. CLAUDE.md's same-commit documentation law binds these template lines.
7. **The gating matrix's Evidence column is unsatisfiable at Car 1.** plan:209 requires evidence per row; `gating-matrix.md:21` and `worked-ledger-and-gating.md:36` require **real test names**. Tier 1 and tier 2 detection are Car 2/Car 3 code (`spec:87-93`), and the index-staleness CI gate is Car 3 (`spec:256`). Two of three rows land with no possible evidence and no instruction for what to write.
8. **"§9 documentation rows (Cars 2 and 3)" is wrong** (plan:234). `spec:249-250` assigns §9's **first two rows to Car 1** — and A.5 delivers them. Should read "§9 rows 3-9." The coverage table also never maps §9 → A.5.

**NOTE (not a finding):** the base `d70069e` (plan:11) predates the plan file itself (`4267371`), so a car at that base will not have the plan in-tree. Both baselines are identical at both commits (verified), so this is harmless — worth one explicit line so the car does not mistake it for the stale-worktree scar.

**NOTE:** A.1's second `It` also reds, which the plan does not mention. It fails **cleanly** (`Expected the actual value to be greater than 1, but got 0.`), not as an error. This strengthens the task rather than weakening it; no finding.

---

# (a) Spec coverage — rebuilt independently

| Spec section | Plan claims | My walk | Verdict |
|---|---|---|---|
| §1 problem | — | narrative | n/a |
| §2.1-§2.4 producer/hooks/envelope/concurrency | Car 2 | Car 2 | **agree** |
| §2.5 detector, tiers; m5 checkpoint fetch | Car 2 (§2 blanket) | Car 2 / Car 3 | **agree** |
| §3 field names, types | A.1 | A.1 | **agree** |
| §3 **ordering** | A.1 (blanket) | **unmapped** — and A.4 determinism depends on it | **Major 2** |
| §3 **identity** | A.1 (blanket) | double-keyed / unstated | **Major 7** |
| §3 **index format** | A.1 (blanket) | **unmapped**; A.4 invents it | **Major 2** |
| §3 **normalisation substitution rule** | A.1 (blanket) | **unmapped** | **Major 2** |
| §3.1 kinds, precedence, supersession | A.1 | kinds→A.1 ✓; precedence/supersession are fold = Car 2 | agree, table imprecise |
| §3.2 vocabularies as data | A.1 | **claimed, not delivered; enum contradicts it** | **Major 3** |
| §3.3 budget + shop default | — | **unmapped, undeferred**; needs an A.1 field | **Major 2** |
| §3.4 cost/context optional | — | covered by A.1 Produces, absent from table | minor table gap |
| §3.5 un-backfilled gap | — | fold = Car 2; **undeferred** | minor table gap |
| §3.6 integrity hash + normalisation declared in-artifact | — | **unmapped**; both need A.1 fields | **Major 2** |
| §4 row 4 verifier vacuity | A.3 | A.3, but red invalid | **Major 1** |
| §4 rows 1-3, 5-6 | Cars 2/3 | Cars 2/3 | **agree** |
| §5.1 no process state | A.5 | A.5, narrowed | **Major 5** |
| §5.2 index derived, CI diffs | A.4 | A.4 generator ✓; CI gate = Car 3; **no ledger row** | **Major 5** |
| §6 store-empty must fail | A.3 | A.3, unsatisfiable as written | **Major 1** |
| §6 stale-index non-vacuity | — | unmapped/undeferred (enabler is A.4) | minor gap |
| §7 probes | before Car 2 | agree | **agree** |
| §9 rows 1-2 (contracts) | "Cars 2 and 3" | **Car 1 — A.5 delivers them** | **Minor 8** |
| §9 rows 3-9 | Cars 2/3 | Cars 2/3 | **agree** |

**Nothing is claimed for Car 1 that belongs to Cars 2/3.** The failure runs the other way: the deferral list is honest, but the §3 blanket row let five schema obligations and one vocabulary mechanism fall through a table row that looked complete.

# (b) Inter-task interfaces

- **A.1 → A.2:** schema + vectors. Consistent. A.2's Consumes matches A.1's Produces.
- **A.1 → A.4:** **BROKEN.** `spec:96` assigns the index format and field ordering to the schema artifact (A.1). A.1 specifies neither; A.4 must invent both, and A.4's byte-identical determinism gate rests on the ordering A.1 owed it.
- **A.2 → Car 2:** under-specified. Return shape self-contradictory (Minor 3); no schema parameter (Minor 5); identity field unnamed (Major 7); five fields missing (Major 2). Car 2 would guess on all four.
- **A.3 → Car 3:** handoff is prose only. No mechanical enforcement that Car 3 arms the switch (Major 6).
- **A.4 → Car 3:** `New-ArtifactIndex -StoreRoot -OutFile` is clean and sufficient for a CI regenerate-and-diff step.

# (d) Red validity

| Task | Stated red | Verified |
|---|---|---|
| A.1 | `Expected $true, but got $false` on `Test-Path $script:Schema` | **VALID — reproduced verbatim**, `Schema.Tests.ps1:9`. `schema/` absent at base (confirmed). |
| A.2 | module-not-found | **VALID** — message reproduced; cites the leaf, actual names the full path. Cosmetic. |
| A.3 | current code exits **0** with *"No verdict files found."* | **INVALID — Major 1.** Throws at `:94`, exit **1**; that message is unreachable; the specified assertion passes on arrival. |
| A.4 | "script not found" | **VALID** — `scripts/New-ArtifactIndex.ps1` absent at base. |
| A.5 | DocPolicy fails on a new contract file with no Status line | **VALID.** `DocPolicy.Tests.ps1:44` walks `docs/` with `-Recurse`, so `docs/contracts/*.md` is caught; pattern `^Status: (Current\|Done\|Superseded\|Open)$` at `:31` over the first 5 lines at `:32`. Adds 0 tests (the check is a loop inside one `It`), so A.5 does not move the count — the plan never says so. |

# Ruling on CONDUCTOR RULING R1

**Legitimate in principle, defective as issued. Does not survive review.**

*What is sound:* choosing a language-neutral wire format with a portable conformance suite is the correct expression of Law 7 (`constitution.md:53-57`) and of the spec's *"the schema is the product; producers are adapters."* Separating A.1 (the product) from A.2 (one implementation) is genuinely good decomposition and is the plan's best idea. A conductor ruling on a question the spec left open is exactly the right instrument — the spec named no language and something had to decide.

*Where it fails:*

1. **It rules on form and skips feasibility.** R1 asserts it proceeds *"without inventing a toolchain"* (plan:34). Draft 2020-12 validation in PowerShell requires `Test-Json`, which **does not exist in Windows PowerShell 5.1** (measured) and does exist in pwsh 7.6.3 (measured). The repo runs both: CI is pwsh (`ci.yml:42`), the box is 5.1, and `Verify-Verdict.ps1:20` declares 5.1 compatibility as a standing convention. R1 silently requires a runtime floor the repo has not adopted, and names it nowhere. That is inventing a toolchain dependency while claiming not to.
2. **It leaves a menu where the spec forbade one** (Major 4). `spec:57-58` is explicit that a menu is not a requirement.
3. **It does not discharge what it claims authority over.** R1 declares the schema is the product; `spec:96-97` says that product owns six contracts; A.1 specifies two (Major 2). A ruling that establishes an artifact as the product must enumerate the product.
4. **It contradicts §3.2** (Major 3): a hard `enum` in the ruled artifact makes an unrecognised kind a validation failure, where `spec:125-126` requires a discovery.

*What would make it sound:* keep the JSON-Schema-plus-vectors decision; add (i) a declared runtime floor with the named validation API, or an explicit ruling that the validator is hand-rolled against the vectors with the vectors as the anti-drift gate; (ii) `kind` as `type: string` with the vocabulary in a data file and vectors pinning the "unrecognised is a discovery" behavior; (iii) the full field enumeration from `spec:96-97`, `spec:139`, `spec:156-163`.

# Constitution check

| Law | Implicated by | Honored? |
|---|---|---|
| **1 Truth** (`:14-18`) | A.3's guard; the plan's own verified-claim | **NO.** plan:149-151 states as *"verified at `d70069e`"* a behavior the code does not have (Major 1). A confident falsehood on the artifact the cars treat as ground truth. |
| **2 Dispatcher commands** (`:20-24`) | R1; the amendment block | **YES.** R1 is recorded, attributed, and reviewable; the binding-amendment block (plan:18-21) preserves the conductor's override path. |
| **3 Actionability** (`:26-31`) | five-step task shape | **PARTIAL.** A.1 is directly actionable; A.5 has no steps 1-4 (Minor 2) and A.2/A.3/A.4 have no snippets (Minor 4). |
| **4 Nothing silently lost** (`:33-37`) | coverage table | **NO.** Five schema fields, the index format, ordering, and the §3.2 vocabulary mechanism are lost inside one blanket "§3" table row (Majors 2, 3). |
| **5 Self-knowledge** (`:39-44`) | guard posture | **NO.** Major 6 ships a guard off by default whose arming depends on memory — *"degrades loudly, never silently"* inverted. |
| **6 One Truth** (`:46-51`) | validator; identity; ledger | **NO, three ways.** A hand-rolled validator is a second copy of the schema (Major 4); `subject` + `dispatch_id` are two identity keys that can disagree (Major 7); the derived index is real second-copy state with no ledger row (Major 5). |
| **7 The Stranger** (`:53-57`) | R1's portability rationale | **PARTIAL.** The vectors-as-conformance-suite idea is a genuine Law 7 win. But `spec:127-128` records rev 1 *"claimed Law 7 in its header while dropping Law 7's mechanism"* — with no vocabulary data file, the plan repeats it (Major 3). |
| **8 Growth** (`:59-63`) | the review record | **YES.** plan:244-255 states the plan-writer's self-sentence-check openly, which is what let me test it and find where reading-without-running was insufficient. That disclosure is the reason Major 1 is a plan-rung catch and not a car's wasted dispatch. |

---

# WORKFLOW VERDICT on `docs/templates/worked-plan.md`

This is the first plan written from the exemplar, and the exemplar's holes cost more than the plan's did. Six, ordered by what they cost here:

1. **The self-check is "open the real file." It must be "open the real file, and RUN the stated red where the red is behavioural."** `worked-plan.md:8-9` and `:59-60` define the plan-writer's sentence-check as *opening* files. Opening `Verify-Verdict.ps1` and reading `:94-96` produces **exactly** the plan's false claim — the StrictMode crash at `:94` is invisible to reading and took one command to expose. This is a new scar, paid this round: **a behavioural claim verified by reading is not verified.** The ancestor's scar was *nonexistent APIs*, catchable by reading. This one is *existent APIs that behave differently than they read*, and the exemplar has no instrument for it.
2. **No runtime/toolchain floor field.** Global constraints (`worked-plan.md:39-41`) name suites and baselines but never the runtime the suites must pass under. A mandatory "runtime floor + named validation API" line would have caught Major 4 at plan-writing.
3. **The Produces block models a function signature only** (`worked-plan.md:51-53`). It gives no shape for a plan whose product is a **data contract**. There is no rule that a schema's Produces block enumerates every spec-mandated field, which is how A.1 dropped five.
4. **The exemplar's own compression is being read as a licence to under-specify.** `worked-plan.md:88-95` collapses A.2 and all of Car B into bracketed prose, and `:79-80` reduces implementation to a bracket. The plan mirrored that compression precisely: full snippet in the first task, prose thereafter, and A.5 with no steps at all. Add one line: *"the compression below is an exemplar artifact; in a real plan every task carries all five steps and its snippet."*
5. **The coverage-table rule under-specifies its own granularity.** `worked-plan.md:105-106` says *"Every spec section maps to a task or names its deliberate deferral,"* and the sample table (`:99-104`) models four top-level rows. It must say **every numbered subsection**. The §3 blanket row is where Majors 2 and 3 hid, and a subsection-granular rule makes them unmissable.
6. **The ledger guidance models the wrong category.** `worked-plan.md:85-86` — *"no mutable state (pure function) - SAY SO explicitly"* — teaches the process-state-only frame that `spec:195` (ruling 6) exists to forbid. It should require the ledger question be asked in two parts: process state **and** derived/committed artifacts.

The three stitches the exemplar claims (`worked-plan.md:8-10`) **worked exactly as designed** for the failure class they encode: the A.1 snippet is clean, every API resolves, the base is honest, the amendment block is present and empty, and the plan-writer disclosed its own self-check so it could be audited. The plan is materially better than the ancestor's three-REJECT plan. It failed on the class the exemplar does not yet cover — and hole 1 above is the amendment that closes it.

---

**Read-only compliance:** I edited nothing tracked, committed nothing, pushed nothing. Fault injection was one untracked test file plus a temporary `schema/` tree, both removed; `git status --porcelain` returns empty and HEAD is unchanged at `4267371992cb9d1d3f3d239f4d2829f470b7f014`.

**Model-probe report (requested at plan:45-48):** three findings are **execution defects**, not judgment calls — Major 1 (a claim asserted as empirically verified that was not), Major 6 (a design justified by a premise falsifiable in one command), and Minor 1 (a citation pointing at an unrelated line). All three share one root: **claims verified by reading where running was required.** Majors 2/3/5/7 are fidelity-to-spec misses, a different and more forgivable class. My read: the execution-defect cluster is real and points at the model, but it is at least equally attributable to hole 1 in the exemplar, which never told the plan-writer to run anything. I would not move cars 2-3 back to Opus on this evidence alone; I would first close exemplar hole 1 and re-measure.

**Key paths:**
- `~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\64c15364-0933-4d6d-9b2e-d1ddbc918f9f\scratchpad\review-plan-1\docs\plans\2026-07-22-harness-car1-plan.md`
- `...\review-plan-1\scripts\Verify-Verdict.ps1` (lines 27-28, 83-97 — the Major 1 evidence)
- `...\review-plan-1\docs\specs\2026-07-22-dispatch-harness-spec.md` (lines 96-97, 124-128, 139, 156-163, 193-201, 249)
- `...\review-plan-1\docs\templates\worked-plan.md`
- `...\review-plan-1\.github\workflows\ci.yml` (lines 47, 76-81)

```starcar-artifact
outcome: REJECT
findings: 7 Major, 8 Minor
abstract: |
  Plan adversary verdict on docs/plans/2026-07-22-harness-car1-plan.md at base
  4267371992cb9d1d3f3d239f4d2829f470b7f014 (car base d70069e, its parent). Baselines
  independently re-derived and CONFIRMED: Pester 21 passing, Verify-Verdict 11/11 exit 0.

  Dimension (c) is CLEAN for snippets: I ran the A.1 Pester block verbatim, red and green.
  Should -BeTrue, -BeIn, -BeGreaterThan, -Because, Should -Not -Throw,
  System.IO.Path ChangeExtension, and git rev-parse --show-toplevel inside BeforeAll all
  exist and bind in Pester 5.8.0. NO snippet calls a nonexistent API. Board.psm1:194,
  Verify-Verdict.ps1:24 and :87-90, and ci.yml:47 all resolve as cited.

  MAJOR 1 (execution defect): plan:150-151 asserts as "verified at d70069e" that
  Verify-Verdict.ps1:94-96 exits 0 on a directory with zero .md files. Measured: it THROWS
  PropertyNotFoundStrict at :94 and exits 1, because Set-StrictMode Latest at :27 meets a
  null pipeline result at :91. Lines 95-96 are unreachable dead code. A.3's stated red is
  therefore wrong, and the test A.3 specifies (empty dir must exit non-zero) PASSES ON
  ARRIVAL. Spec section 6's mandatory non-vacuity item is unsatisfiable as written.

  MAJOR 2: A.1's Produces block drops 3 of the 6 schema-owned contracts named at spec:96-97
  (ordering, index format, normalisation substitution rule) plus 5 spec-mandated fields
  (integrity hash spec:161-163, normalisation declaration spec:156-157, budget spec:139,
  presumed-lost basis spec:142-143, envelope absent/malformed spec:75-77). Car 2 consumes
  this blind; A.4's byte-identical determinism gate depends on the ordering A.1 never
  specifies.

  MAJOR 3: section 3.2 vocabularies-as-data is claimed covered and is not delivered. No
  vocabulary data file exists in any Car 1 task, and the hard kind enum contradicts
  spec:125-126, which requires an unrecognised value to be a discovery, not a bug.

  MAJOR 4: R1 fixes draft 2020-12 but names no validation engine. Measured: Test-Json does
  NOT exist in Windows PowerShell 5.1 (this box) and DOES work correctly on draft 2020-12
  in pwsh 7.6.3 (what CI uses, ci.yml:42). Verify-Verdict.ps1:20 declares standing 5.1
  compatibility. The car must choose between a CI-only module and a hand-rolled second copy
  of the schema (Law 6) - a menu, which spec:57-58 already ruled is not a requirement.

  MAJOR 5: A.5's ledger says "0 fields, no mutable SERVICE state", restoring the
  process-state-only narrowing that spec ruling 6 (spec:195) exists to forbid, and dropping
  spec:249's append-only-under-git claim. The zero-row ledger does NOT survive A.4, which
  lands a committed derived artifact with a real staleness lifecycle and no ledger row.

  MAJOR 6: RequireNonEmpty default-off rests on a false premise. docs/reviews holds 11 md
  files at base, so default-ON also leaves ci.yml:47 green and untouched. Default-off ships
  a disarmed guard whose arming depends on Car 3 remembering, with no test enforcing it.

  MAJOR 7: subject required always plus dispatch_id required on dispatch kinds is a double
  identity key, against folded minor m6 at spec:108-109 and Law 6.

  Minors: ci.yml:62 miscited (the vacuity refusal is :76-81); A.5 has only Step 5, no steps
  1-4; A.2 return shape hashtable vs Board.psm1:188-191 pscustomobject; A.2/A.3/A.4 carry no
  snippets against worked-plan.md:79-80, and A.2's table-driven instruction walks into the
  Pester 5 discovery-time ForEach trap; Test-StarcarArtifact has no schema parameter; the
  state-ledger.md:4 and gating-matrix.md:4 trigger lines are invalidated but absent from
  A.5's Files list; the gating matrix Evidence column is unsatisfiable at Car 1 for 2 of 3
  rows; "section 9 documentation rows (Cars 2 and 3)" is wrong, rows 1-2 are Car 1's.

  Ruling on R1: legitimate instrument, defective as issued. The JSON-Schema-plus-portable-
  vectors decision and the A.1/A.2 product-vs-implementation split are sound and are the
  plan's best idea. It fails because it rules on form while skipping feasibility, claims to
  avoid inventing a toolchain while requiring an undeclared runtime floor, leaves a menu the
  spec forbade, does not enumerate the product it declares, and contradicts section 3.2.

  Constitution check: Laws 1, 4, 5 and 6 are each violated with named evidence; Laws 2 and 8
  are honored; Laws 3 and 7 partial.

  WORKFLOW VERDICT on worked-plan.md: six holes, the first newly paid for this round. Its
  self-check says "open the real file"; reading Verify-Verdict.ps1 produces exactly the
  plan's false claim, because the StrictMode crash is invisible to reading and took one
  command to expose. The exemplar must require the plan-writer to RUN every behavioural red.
  Also missing: a runtime/toolchain floor field; a Produces shape for data contracts as
  opposed to function signatures; a statement that its own compression is an exemplar
  artifact and not a licence to under-specify; subsection-granular coverage tables; and
  ledger guidance that asks about derived committed artifacts, not just process state.

  Model probe: 3 findings are execution defects (Majors 1 and 6, Minor 1), all sharing one
  root - claims verified by reading where running was required. I judge this at least as
  attributable to exemplar hole 1, which never instructed the plan-writer to run anything,
  as to the model. Recommend closing hole 1 and re-measuring before moving cars 2-3.

  Read-only compliance: nothing edited, committed, or pushed. Fault injection was one
  untracked test file and a temporary schema tree, both removed; git status porcelain empty
  and HEAD unchanged at 4267371992cb9d1d3f3d239f4d2829f470b7f014.
```