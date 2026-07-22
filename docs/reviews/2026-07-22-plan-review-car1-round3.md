<!-- starcar-integrity: sha256=cd4d4928727d469598122894890525cdc9decef3ab76318d5a3337cf5ac2a522 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Plan review: dispatch harness Car 1, round 3 (delta) - GATE CLOSED

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Plan review (delta re-review, same adversary)
Round: 3
Target: `docs/plans/2026-07-22-harness-car1-plan.md rev 3`
Base reviewed: `782ceca94b417a31e9ce05277f3b1c3995ce62c4`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE-WITH-REBASE-LIST**

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
> Path normalisation: none applied (the body contained no operator-environment paths).

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `782ceca94b417a31e9ce05277f3b1c3995ce62c4` |
| Entire checkpoint | `5839a083fb00` |
| Dispatch, the locator within the session | `aed8b69593d8924f8` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 782ceca94b417a31e9ce05277f3b1c3995ce62c4
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Clean tree, HEAD unchanged at `782ceca`. Here is the round-3 delta verdict.

---

**APPROVE-WITH-REBASE-LIST.** All three PR2 findings are PRESENT and correctly folded, none DRIFTED. Every operative count rebase (verdict store 12→13, vectors 8→9, and the cascading suite totals) was applied consistently. The only residual defects are three mechanical stale "rev 2" version labels on a rev-3 document — no Major, no structural or API break. Enumerated below for the conductor to apply as a binding addendum; the car dispatches without another round.

# Baselines (re-derived by me at HEAD `782ceca`)

| Suite | Expected | Observed | Result |
|---|---|---|---|
| `Invoke-Pester -Path ./scripts/tests` | 21 passing (plan:42) | `PASSED=21 FAILED=0 TOTAL=21` | **confirmed** |
| `./scripts/Verify-Verdict.ps1` | 13 files, exit 0 (plan:43) | 13 `OK`, exit 0; `docs/reviews` holds 13 `.md` | **confirmed** (round-2 verdict landed as the 13th) |

# Three-ID walk

### PR2-M1 (`abstract`) — PRESENT, fold complete, no drift
I walked every sub-claim independently:

| Sub-claim | Location | Verified |
|---|---|---|
| Field-table row present, correct type/requiredness/authority | plan:115 | `abstract | string | when kind = returned | spec §2.3` — type, requiredness, and authority all match `outcome`/`findings` (its sentence-mates at spec:92). ✓ |
| `abstract` in the valid-`returned` vector | plan:150-151 | *"valid `returned` (with `outcome`, `findings`, **`abstract`**, `integrity`, `normalisation`)"* ✓ |
| NEW invalid vector `returned` missing `abstract` (anti-vacuity) | plan:153-155 | Present, tagged *"pins the conditional requirement so the new field's schema clause cannot be vacuous"* ✓ |
| Vector minimum 8 → 9 | plan:150 | *"Vectors (minimum nine)"* ✓ |
| A.1 test asserts 9 | plan:186-188 | `It 'ships at least nine vectors'` + `Should -BeGreaterOrEqual 9` ✓ |

I re-counted the enumerated vector list at plan:150-156: (1) valid dispatched, (2) valid returned+abstract, (3) valid presumed-lost, (4) discovery vector, (5) invalid missing kind, (6) invalid returned-missing-outcome, (7) invalid returned-missing-abstract [NEW], (8) invalid presumed-lost-missing-basis, (9) invalid missing-integrity = **exactly 9**, consistent with the `≥9` assertion. The new invalid vector makes the `abstract` conditional non-vacuous exactly as required, and it is exercised by A.2's `-ForEach` conformance suite (the right place to pin a field — not an A.1 structural test). Coherence check on the pre-existing discovery test (plan:273-280): its object carries `kind='migrated'` (≠`returned`), so the abstract conditional does not fire and `Valid=True` still holds — the abstract addition does not break it.

### PR2-m1 (`producer` citation) — PRESENT; the fix is honest and sufficient, no conductor ruling required
plan:121 now reads: `producer | string | optional | not spec-mandated [PR2-m1 - rev 2 miscited §3.4...]. Basis stated: Law 7 metadata naming the emitting adapter, optional exactly as cost is`. The false §3.4 citation is gone (I re-confirmed §3.4 names no `producer` field in round 2).

**My ruling (the coordinator asked for one):** the basis is **honest and sufficient; no conductor ruling is required.** Reasoning: the field is (a) explicitly labeled non-mandated rather than dressed in a false authority, (b) optional, so it imposes nothing on a conforming stranger and can never turn a valid artifact invalid, and (c) backed by a real Law-7 rationale (which adapter emitted the record is exactly the kind of portability metadata Law 7 favors). The rulings R1v2/R2/R3 each resolved a genuine tension or menu; an additive optional metadata field with honest disclosure is a lower-stakes decision that the reviewer can and does adjudicate in-band — which is this gate functioning, not a gap in it. Were the field *required*, my ruling would flip (a non-mandated required field is scope the spec did not authorize). It is not.

*Forward note, out of this round's scope (neither a PR2 finding nor an edit site), recorded so it is not lost: the plan does not state the schema's `additionalProperties` posture. If closed, a stranger's custom metadata would fail validation (a Law-7 tension) and `producer` must be declared; if open, `producer` need not be declared at all. Worth a one-liner in `schema/index-format.md` when A.1 is built. Not a finding.*

### PR2-m2 (A.4 snippet) — PRESENT; sentence-checked clean
The full snippet is at plan:388-415. I verified:

- `Get-FileHash -Algorithm SHA256` (plan:412) — I ran `Get-Command`: exists in `Microsoft.PowerShell.Utility`, `-Algorithm` parameter present. Matches the plan's structural-check note (plan:417-418).
- `&amp; pwsh -NoProfile -File $script:Gen -StoreRoot ... -OutFile ...` — parameters match the Produces signature (plan:380). ✓
- `$TestDrive` in `BeforeAll`, `-match '^\|'`, `Select-Object -Skip 2` — all valid.

**On the coordinator's specific question — is the `Select-Object -Skip 2` (2-line header) assumption consistent with `schema/index-format.md` as A.1 specifies it, or a car trap?** It is **consistent**, and not a trap. A.1 (plan:139-140) specifies the index as a markdown table with columns `subject | kind | at | outcome | file`. The standard rendering is a header row plus a `|---|` separator row — two lines, both leading with `|`. I ran the exact filter over a simulated standard table (header + separator + 3 data rows) and got `rows.Count = 3`, correct. The residual coupling is that `index-format.md` must use a leading-pipe separator (which the `^\|` filter and `Skip 2` both assume); since the **same car** authors `index-format.md` (A.1), the generator, and this test in sequence, it controls that format and any mismatch surfaces as a self-correcting false red at A.4's green step, never a latent silent bug. Low-severity coupling, correctly resolvable, not a finding.

# Count-rebase sweep (12→13 verdict store; 8→9 vectors)

I checked every count mention. **All operative rebases applied and consistent:**

| Count | Site | Rebased? |
|---|---|---|
| Verdict store 13 | plan:43 (baseline, with explicit "rev 2 said 12" note), :81 (R3 premise), :321 (A.3 fix), :363 (A.3 step 2), :369 (A.3 step 4), :521 (trajectory) | ✓ all 6 |
| Vectors 9 | plan:150 (min nine), :186/:188 (test ≥9), :210 (impl), :299 (A.2 total), :543 (disposition) | ✓ all |
| Suite totals cascade | A.1 25 (:212), A.2 `25+9+2=36` (:299), A.3 `36+3=39` (:368), A.4 `39+2=41` (:425), A.5 41 (:476), trajectory `21→25→36→39→41→41` (:521) | ✓ arithmetic checks: each downstream total +1 vs rev 2's 25→35→38→40→40 |

**Two count mentions are correct-as-history, not stale:** plan:44 (*"rev 2 said 12 - a count rebase, not a drift"*) and plan:533 (*"premise re-measured (12 files)"*) both sit under the "Disposition in rev 2" framing and accurately record what rev 2 did. plan:203 (*"greater than 1, but got 0"*) is a faithful quote of the plan-writer's honestly-labeled *reduced two-`It` probe* (which used the rev-1 `&gt;1` form), not a stale assertion of the real test. None faulted.

# New findings (all Minor, all mechanical stale version labels)

| # | file:line | Defect | Fix |
|---|---|---|---|
| PR3-m1 | plan:36 | *"the commit that lands this **rev 2**"* — stale; this is rev 3. The verification mechanism (HEAD history + file-text match) is version-agnostic and self-correcting, so impact is low, but it is a missed rebase in the base/baselines edit site. | s/rev 2/rev 3/ |
| PR3-m2 | plan:30 | *"Empty at **rev 2**"* — the amendment block is still empty at rev 3; label not carried forward. | *"Empty at rev 2 and rev 3"* (or *"rev 3"*) |
| PR3-m3 | plan:526 | Disposition-table column header *"Disposition in **rev 2**"* — the table now also carries PR2-* rows disposed in **rev 3**. Header is stale for those three rows. | Retitle *"Disposition (rev 2 / rev 3)"* |

None is a Major; none touches a snippet, API, count arithmetic, or task logic.

# Convergence ruling

Round history: **R1 = 7 Major + 8 Minor (15). R2 = 1 Major + 2 Minor (3). R3 = 0 Major + 3 Minor (mechanical labels).** I hold the full series and rule against the three swirl conditions:

1. **Majors declining?** 7 → 1 → **0**. Monotonic to zero.
2. **Findings clustering in the same section?** No. R1 spread everywhere; R2's Major was the field table; R3's minors are version labels in the header/base sections — a different, shrinking locus each round.
3. **Does R3 contain defects R2's fixes created?** No. The three stale "rev 2" labels are not products of the `abstract`/`producer`/A.4-snippet folds; they are pre-existing revision-label lag the rebase pass didn't sweep. Not relocation.

**Zero swirl conditions fire. This is textbook convergence — findings shrank to zero Major and moved to cosmetic labels.** The gate did its job across three rounds at one-dispatch cost each: a genuine product-artifact gap (`abstract`) caught before any schema was built, then closed cleanly. The three label nits are the kind of residue APPROVE-WITH-REBASE-LIST exists for — the conductor applies them as a binding addendum and Car 1 dispatches. Reporting this as a SUCCESS outcome without hedging: the plan is sound and ready.

**Read-only compliance:** I wrote nothing into the worktree this round; my probes ran in scratchpad and via `pwsh` against temp dirs outside the tree. `git status --porcelain` is empty and HEAD is unchanged at `782ceca94b417a31e9ce05277f3b1c3995ce62c4`.

```starcar-artifact
outcome: APPROVE-WITH-REBASE-LIST
findings: 0 Major, 3 Minor (mechanical version-label rebases)
abstract: |
  Round-3 delta review of docs/plans/2026-07-22-harness-car1-plan.md rev 3 at base
  782ceca94b417a31e9ce05277f3b1c3995ce62c4. Baselines re-derived by me: Pester 21/21,
  Verify-Verdict 13/13 exit 0, 13 review files. Worktree clean, HEAD unchanged, nothing
  written into the tree this round.

  Scope was the three round-2 (PR2) findings plus a drift sweep of the edit sites.

  PR2-M1 (abstract): PRESENT, fold complete, no drift. Field-table row at plan:115 has
  correct type (string), requiredness (when kind=returned), and authority (spec 2.3),
  matching its sentence-mates outcome and findings. abstract added to the valid-returned
  vector (plan:150-151); a NEW invalid vector returned-missing-abstract added (plan:153-155)
  so the conditional clause cannot be vacuous; vector minimum moved 8 to 9 (plan:150) and
  the A.1 test asserts BeGreaterOrEqual 9 (plan:186-188). I recounted the enumerated vector
  list: exactly 9, consistent. The new field is pinned by A.2's -ForEach conformance suite,
  the correct place. Pre-existing discovery test still coherent (kind=migrated is not
  returned, so the abstract conditional does not fire).

  PR2-m1 (producer citation): PRESENT. The false 3.4 citation is removed; plan:121 now labels
  the field not-spec-mandated with a Law-7 adapter-metadata basis. My ruling: honest and
  sufficient, NO conductor ruling required, because the field is optional (imposes nothing on
  a conforming stranger, can never make a valid artifact invalid) and honestly disclosed. A
  required non-mandated field would flip this; it is not required.

  PR2-m2 (A.4 snippet): PRESENT, sentence-checked clean. Get-FileHash -Algorithm confirmed
  present (Microsoft.PowerShell.Utility) by running Get-Command. The Select-Object -Skip 2
  two-line-header assumption is consistent with A.1's standard markdown-table column spec: I
  ran the exact filter over a simulated standard table (header + separator + 3 rows) and got
  rows.Count=3. The same car authors index-format.md, the generator, and the test, so the
  format coupling is self-consistent and any mismatch is a self-correcting false red, not a
  latent bug. Not a finding.

  Count-rebase sweep: every operative rebase applied and consistent. Verdict store 13 across
  all six sites (baseline, R3 premise, A.3 fix/step2/step4, trajectory). Vectors 9 across all
  sites. Suite totals cascade correctly: 21, 25, 36, 39, 41, 41 (each downstream +1 vs rev
  2). Two 12-file mentions (plan:44, :533) are correct-as-rev-2-history under the Disposition-
  in-rev-2 framing, not stale. plan:203's greater-than-1 quote is a faithful record of the
  honestly-labeled reduced probe.

  Three new Minor findings, all mechanical stale version labels on a rev-3 doc, none touching
  any snippet/API/count/arithmetic: PR3-m1 plan:36 "the commit that lands this rev 2" should
  read rev 3 (self-correcting base-verify mechanism, low impact); PR3-m2 plan:30 "Empty at
  rev 2" not carried to rev 3; PR3-m3 plan:526 disposition-table header "Disposition in rev
  2" now also carries rev-3 PR2 rows. Enumerated for the conductor to apply as a binding
  addendum.

  Convergence: zero swirl conditions. Majors 7 to 1 to 0 (monotonic); findings shrank and
  moved to cosmetic labels; no R3 defect was created by an R2 fix. Textbook convergence. This
  is a SUCCESS outcome - a real product-artifact gap (abstract) caught at the plan rung and
  closed cleanly over three one-dispatch rounds. Verdict APPROVE-WITH-REBASE-LIST: apply the
  three label fixes as a binding addendum and Car 1 dispatches without another round.
```