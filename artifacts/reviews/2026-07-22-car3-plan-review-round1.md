<!-- starcar-integrity: sha256=0c285459f8a3861bc8a75a5c2312eee604eaad7ccf9cbb2b774013f0e3058be0 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car 3 plan review, round 1: REJECT - R7 schema-invalid and R9 index.md trap, both proven

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Plan review (adversarial, 5 dimensions + rulings)
Round: 1
Target: `docs/plans/2026-07-22-harness-car3-plan.md rev 1`
Base reviewed: `c595fb9be859cdc3d7be175697087a075b7ab402`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `ac32f4e635f031ebe`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `c595fb9be859cdc3d7be175697087a075b7ab402` |
| Entire checkpoint | `cb410d5e7919` |
| Dispatch, the locator within the session | `ac32f4e635f031ebe` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain c595fb9be859cdc3d7be175697087a075b7ab402
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

I have enough to rule. Base reconfirmed at `c595fb9`, tree clean, all fault-injection was in `$env:TEMP` and reverted. Here is my verdict.

---

**VERDICT: REJECT** — 5 Major, 4 Minor, 2 Notes. Two Majors (M1, M2) are empirically proven and independently sufficient; each makes Car 3's central deliverable (the migration commit) unbuildable-as-specified or CI-red on landing.

---

## Findings by severity

### MAJOR

**M1 — R7's migration-record shape is INVALID against the landed schema (proven).** Plan lines 45-56 enumerate the record as `{kind: returned, subject, at, outcome, abstract, normalisation:[], integrity, body_file}`. The schema (`schema/starcar-artifact.schema.json:86`) requires `["schema","kind","subject","session_id","at","normalisation","integrity"]`, and the `allOf` at `:87-96` requires `["outcome","findings","abstract"]` when `kind=returned`. R7 names neither `session_id`, `findings`, nor the `schema` const. I built R7's exact shape and ran it through the landed `Test-StarcarArtifact`:

```
Valid: False
  ERR: Required properties ["schema","session_id"] are not present at ''
  ERR: Required properties ["findings"] are not present at ''
```

Even after charitably adding `schema` + `session_id`, it still fails: `Required properties ["findings"] are not present`. C.1 Step 1 (plan:95) asserts "the record validates via `Test-StarcarArtifact`" — that assertion is unsatisfiable under R7. The car has **no specified value** for `session_id` (R7 itself says "historical verdicts predate machine subjects") or `findings` (R7 assigns the body to `body_file` and the Title to `abstract`; findings is unassigned). This is the "prose is the wrong instrument for a format" scar recurring one rung down: R7 is a prose ruling that the executable schema rejects, and the plan's own mandated test is what catches it. The instrument exists; R7 never ran it.

**M2 — R9's `default → artifacts` + `-Recurse` makes the bare verifier choke on `artifacts/index.md` → CI red on the migration commit (proven).** `New-ArtifactIndex.ps1:70` writes `index.md` at the store root with NO `starcar-integrity` first line. R9 (plan:68-71) repoints `Verify-Verdict.ps1`'s default to `artifacts` and adds `-Recurse -Filter *.md`. The only `.md` under `artifacts/` after migration are `artifacts/reviews/*.md` (integrity-headed, fine) and `artifacts/index.md` (no header). I demonstrated both the non-recursion red AND the trap in an isolated fixture:

```
=== recursive glob over store root finds: ...\index.md, ...\reviews\good.md ===
NO INTEGRITY  ...\index.md (first line is not a starcar-integrity line)
OK            ...\reviews\good.md
ANY FAIL under recursive glob (index.md included) = True
```

C.1 Step 4 (plan:106-108) asserts "bare now verifies the store ... exit 0." Empirically it is **exit 1**. Because C.1 is one atomic commit that also repoints the default, the migration commit itself turns CI red — the *exact* atomicity failure spec ruling 4's one-commit rule exists to prevent. Root cause: R9 chose `artifacts` as the default (forcing `-Recurse`) when `artifacts/reviews` needs no recurse and never sees `index.md`. R9's stated justification for `-Recurse` ("the store nests `.md` under ... subjects' dirs") is false — subject dirs hold only `.json`.

**M3 — living-contracts violation: the plan defers ledger/matrix flips OUT of the commit that invalidates them.** C.1 commits the first index INSTANCE (`artifacts/index.md` is born, plan:111-113), which makes `state-ledger.md:56` ("Committed? not yet — no instance is committed until Car 3 migrates the store") stale the instant C.1 lands — yet the plan defers the ledger flip to C.4 (plan:111-114, 172, 181). Likewise C.2 arms the index-staleness CI gate, making `gating-matrix.md:19` ("no index is committed yet ... pending") stale, but defers the matrix flip to C.4 (plan:144, 170). CLAUDE.md Living Contracts is explicit: "Any commit that adds or changes mutable service state updates the state ledger in the same commit ... Reviewers reject state-touching diffs that leave the ledger stale" — and the North Star's "same commit, not a follow-up, not a cleanup pass." C.1's and C.2's own reviewers are bound to REJECT them for stale contracts. The plan even discloses this ("stated so the reviewer checks the pair," plan:114) — disclosed-but-wrong does not clear. Internal inconsistency compounds it: plan:114 says the matrix "flips to ARMED at C.2" while plan:144 says "the gating matrix flip is C.4's docs pass."

**M4 — Handback 3's "merge cleanly" is a false-comfort claim; the merged HEAD fails C.2's own index-staleness gate.** `Produce-Artifact.ps1:246-256` commits ONLY its own record path (`git commit --only`) and never regenerates `index.md`. During Car 3's review cycle the producer writes new records onto `dev`. At merge there is no git-level conflict on `index.md` (only Car 3 touches it) — so Handback 3 (plan:189-190) is *technically* true — but the merged store then contains producer records absent from Car 3's committed `index.md`, so `index.md` is stale, and C.2's index-staleness gate (which Car 3 itself installs) FAILS on the next push. The plan never states the mandatory "regenerate `index.md` over the merged store and commit before opening the PR" step; Handback 2 (plan:186-188) treats the same stale-index red as a desirable live demo, not a blocking merge precondition. Per MERGE NORTH STAR ("never PR except from a good known working state"), the plan as written does not describe a path to a good working state. Remediable with one added handback step, but the claim as stated is wrong.

**M5 — the migration deletes `docs/reviews/` and repoints the verifier to `artifacts`, but nothing prevents future verdicts landing UNVERIFIED in a resurrected `docs/reviews/`.** R9's load-bearing premise is "`docs/reviews/` is EMPTY-then-deleted" (plan:68). `Land-Verdict.ps1` still lands verdict `.md` bodies to `docs/reviews/` (its `-Out` is mandatory, and setup.md:23 documents the convention as `docs/reviews/&lt;file&gt;.md`). The setup row also says the rich `.md` flow is now "backfill-only," yet this very train landed rich `.md` review verdicts and the plan expects more (plan:30, "the store grows by the verdicts that approve this plan"). The plan neither repoints Land-Verdict's landing convention to `artifacts/reviews/` nor states that future verdicts are JSON-returned-record-only. As written, once the verifier defaults to `artifacts`, any future verdict landed in `docs/reviews/` (backfill or convention drift) is **silently unverified** by CI — a Law-1 coverage regression. This is an unresolved two-reading ambiguity ("any requirement readable two ways is a finding"); the plan must resolve it (repoint the landing location and keep it under the verifier, OR document JSON-only future verdicts and the fact that JSON `integrity` is currently checked by no gate) rather than leave R9's premise unguarded. *May be downgraded by an explicit conductor ruling on the future-verdict flow.*

### MINOR

**m1 — R7 citation drift.** R9 cites `Verify-Verdict.ps1:24` for the default (plan:68); the default is at `:27` (`:24` is a comment). The `:97` non-recursion citation is correct.

**m2 — R7 outcome-parse ambiguity + vocabulary pollution.** All 22 verdicts carry `**Verdict: X**` at line 11 (confirmed), but X is a rich string (e.g. `REJECT - 8 Major, 7 Minor, 6 rulings; bounded rev 2 recommended...`). R7 says `outcome = the header's **Verdict: X** value` without specifying whether to take the leading token or the whole string. Taking the whole string yields 22 unrecognised-outcome "discoveries" in the detector fold and 22 phantom `returned` lanes (Detect-Dispatches.ps1 groups them with no `dispatched` predecessor). Benign and rendering is #1's job, but the parse rule is under-specified.

**m3 — README adapter edit risks a premature-capability claim.** README:46 lists adapters inside "StarCar renders that live, from pluggable data adapters (...)". Changing "a conductor-maintained state file" to "the artifact store" (plan:88) risks asserting the board renders live from the store — but board consumption of the store is ticket #1, unlanded. The reviewer of C.1 must sentence-check the exact replacement text against actual board behavior; the plan under-specifies it.

**m4 — ubuntu-leg suite portability unproven; potential scope creep.** ci.yml's current steps are pwsh/forward-slash portable (no hard Windows-only break), but whether the existing Pester suite passes on `ubuntu-latest` is unverified. If a test fails on ubuntu, fixing it is code work outside C.2's `ci.yml`-only file list. Appropriately deferred to Handback 1, but the car should be warned so it honest-stops rather than expanding C.2's scope.

### NOTES

**n1 — isAsync 6/6 evidence is gitignored.** The launch payloads proving `isAsync: true` live in `.claude/probe-logs/post-task.jsonl` (`.gitignore` line 1). C.4 lands the *finding* (6/6) in the committed probe-results doc — durable, and consistent with how probes 1-5 landed — but the raw evidence is a per-machine, non-reproducible observation. The plan states the residual honestly ("a future synchronous dispatch surface would collapse tier 1's grain," plan:169). Acceptable as a measurement-probe landing; not the C2R2-M1 pattern (the finding does land durably), but the doc entry should give a re-observer the method to reproduce 6/6.

**n2 — R7 `integrity` semantics for a pointer record.** "Integrity over the record's own canonical body" is coherent: the JSON record's `integrity` covers its own fields (the pointer + metadata), while the `.md` body's own `starcar-integrity` HTML-comment line (verified by Verify-Verdict) guards the prose — a two-layer design. But R7 does not state that the migration tool must compute integrity the same canonical way `Produce-Artifact.ps1:229-230` does (compact JSON of ordered fields, integrity field excluded), and `Test-StarcarArtifact` does NOT verify integrity correctness — so a bogus hash would pass the C.1 Step 1 test. Specify the canonicalisation to match the producer.

---

## Coverage walk (independently rebuilt)

Every spec obligation maps to a task (mapping is COMPLETE); three are broken by M1/M2/M3 and two carry Major gaps.

| Spec obligation | Task | My finding |
|---|---|---|
| §4 row 4 (S1): verifier repointed in migration commit, actionable errors, dead code removed | C.1 (R9) | Dead code already removed by Car 1 (verified `:94-101` are the actionable errors). Repoint BROKEN by **M2**. |
| §4 row 5: store migration + history + index, one commit | C.1 (R7/R8) | `git mv` preserves bytes+history (structural, OK). Index born C.1 (OK). Record shape BROKEN by **M1**. |
| §5.2: index committed, CI regenerate-and-diff | C.1 + C.2 | Instance+gate present but contract flips deferred (**M3**). |
| §6: stale index fails CI | C.2 local fault + Handback 2 | Local watched-fire acceptable; interacts with **M4** at merge. |
| §2.5 [m5]: checkpoint fetch | C.2 | Non-fatal on fork (Law 7), enumeration deferred R6v2 — consistent with `Detect-Dispatches.ps1:190` `tier-1-only`. OK. |
| §7 [m1]: async grain | C.4 | 6/6 measured; **n1**. |
| §9: setup.md / README / friction-log | C.1 | Targets exist (friction-log at :47, plan content-anchors — good; README **m3**). |
| §9: ci.yml row | C.2 | verifier-repoint half rides on the C.1 default change (one-commit reading, ruled below). |
| #10 probes in CI | C.2 | Zero-test refusal copied from `ci.yml:76-81`. OK. |
| #14 ubuntu leg | C.2 + Handback 1 | ci.yml portable; suite portability unproven (**m4**). |
| #15 latency split | C.3 | Measurement instrument (ruled below). OK. |
| §8 non-goals | binds | Consistent; phantom returned lanes are #1's rendering (**m2**). |

---

## Claim-verification log (conditions stated; RUN what I doubted)

- **R7 record validates via `Test-StarcarArtifact`** — RAN against the landed schema. FALSE (M1): missing `schema`, `session_id`, `findings`.
- **Bare verifier exits 0 over the store after repoint (C.1 Step 4)** — RAN a fixture with `reviews/good.md` (valid) + `index.md` (no header). Recursive glob includes `index.md` → `NO INTEGRITY` → exit 1. FALSE (M2).
- **`Verify-Verdict.ps1:97` is non-recursive** — RAN: non-recursive glob over a root with a nested `reviews/good.md` missed the nested body. TRUE (C.1's `-Recurse` red is valid for its stated reason).
- **All 22 verdicts carry a `**Verdict: X**` header line (R7 depends on it)** — grepped: 22/22 at line 11. TRUE.
- **friction-log line drifted** — found at `:47` not `:46`; plan content-anchors ("LOCATE BY CONTENT"). TRUE, handled.
- **Producer never regenerates `index.md`** — read `Produce-Artifact.ps1:246-256`: `git commit --only -- &lt;recordpath&gt;`. TRUE (basis for M4).
- **isAsync evidence gitignored** — `.gitignore:1` = `.claude/probe-logs/`; `post-task-probe.sh` writes there. TRUE (n1).
- **DocPolicy scope post-migration** — `DocPolicy.Tests.ps1:23,36` walks `docs/` recursively for a Status header. Migrated verdicts (Status: Done) leave `docs/` → no new violation; `artifacts/index.md` is outside `docs/` → not checked. CLEAN, no finding.
- **Detector on slug-subject `returned` records** — read `Detect-Dispatches.ps1:120-172`: groups by subject, renders `returned` with outcome+`spend: absent`, no crash. No downstream assumes subject=agent_id destructively. CLEAN (feeds m2 only).
- **Clean-tree / byte-identical revert** — all fixtures in `$env:TEMP`, removed; `git status --short` empty; HEAD `c595fb9`. CONFIRMED.

---

## Rulings requested

**R7** — REJECT as written. `subject = filename slug` and `at = first git authorship timestamp` are individually acceptable (deterministic, reproducible). But the enumerated record shape is schema-invalid (M1), and it assigns a subject that contradicts the schema's documented identity semantic ("subject IS the dispatch id" — these have no dispatch) without stating the deviation. Fix: add `schema`, `session_id` (define its migrated value), and `findings` (define its source — likely the body or an explicit sentinel), and specify integrity canonicalisation (n2).

**R8** — SOUND. "Eight → the class, migrate all landed at migration time" is the self-referential-baseline class named at Car 1; `ls | wc -l` at migration time is the right rule. No finding.

**R9** — REJECT as written. The `-Recurse` rider is defensible IN ISOLATION (validated by the non-recursion red), but pairing it with `default → artifacts` manufactures the `index.md` trap (M2). Its stated rationale ("subjects' dirs nest `.md`") is factually false. `:24` citation is wrong (`:27`).

**The one-commit reading (dimension a)** — SOUND IN PRINCIPLE, currently UNMET. The reading that "ci.yml:47's bare invocation is semantically repointed by the verifier default change in C.1, so no ci.yml text edit is needed in the migration commit" honors spec ruling 4's actual INTENT (no red-CI window across the migration): after C.1, `ci.yml:47` picks up the new default and points at the live store atomically with the move. I bless this reading. BUT it is currently violated by M2 — because the repointed bare verifier exits 1 on `index.md`, C.1 itself produces the red-CI window the rule forbids. Fix M2 and the reading holds.

---

## Merge-reconcile analysis (the sharpest structural question)

The producer (`Produce-Artifact.ps1`) writes each record to `artifacts/&lt;subject&gt;/&lt;kind&gt;-&lt;at&gt;.json` and commits ONLY that path; it never touches `index.md`. So during Car 3's cycle, producer records land on `dev` as new files. At merge of Car 3's branch:

- **No git-level conflict.** Migrated `.md`, sibling `.json`, and producer records are all distinct new paths; `index.md` is modified only by Car 3. Handback 3's "merge cleanly" is literally true at the VCS layer.
- **But the merged HEAD is not a good working state.** The merged store = {base records} ∪ {producer records written during the cycle} ∪ {22 migrated}. Car 3's committed `index.md` covers only {base} ∪ {22 migrated} — it is stale by the producer records. C.2's index-staleness gate (`git diff --exit-code artifacts/index.md` after regenerate) then FAILS on the merge push.

So the reconcile requires a mandatory step the plan omits: **after merging Car 3 and before opening the PR, regenerate `index.md` over the merged store and commit it.** The same applies to a rollback (`git revert &lt;migration-sha&gt;` cleanly restores `docs/reviews/` via the mv-reversal and the verifier default — byte-preserved, so git revert IS sufficient, no bespoke rollback tool needed — but the reverted `index.md` is likewise stale vs any records landed since, and must be regenerated). This is M4. The plan's Handback section is the right place for it and currently gets it wrong.

---

## Constitution check

- **North Star (docs rank equal to code):** implicated by M3 (contract flips deferred out of the invalidating commit), M4 (Handback claim), M5 (verification coverage). Findings raised.
- **Living Contracts (same-commit ledger):** VIOLATED — M3, with `state-ledger.md:56` and `gating-matrix.md:19` as the stale rows.
- **MERGE NORTH STAR (assert only a good known working state):** VIOLATED — M4, the merge trips C.2's own gate.
- **Law 1 (no confident falsehood on any surface):** implicated by M2 (plan claims exit 0, code gives exit 1), M4 ("merge cleanly"), m3 (README premature claim). Findings raised.
- **Match the instrument to the artifact / "prose is the wrong instrument for formats":** M1 is this scar exactly — R7 is a prose record-shape ruling that the executable schema rejects. Honored partially: the plan DOES mandate the `Test-StarcarArtifact` check (C.1 Step 1), which is the instrument that would catch M1 at execution — so a compliant car would honest-stop. But shipping a ruling the plan's own test rejects is a plan-rung defect, cheapest to catch here.
- **Red-first / TDD:** C.1's two reds are valid for their stated reasons (both demonstrated). C.3's measurement-probe non-vacuity assertion is the correct instrument for a measurement (not ceremony, not behavioral TDD — the plan is honest about this). C.2's no-local-red is acceptable, not an escape hatch: CI YAML has no local red, and the car supplies real partial evidence (yaml parse + C.1's local stale-index fault proof). Honored.
- **Sentence check (my duty):** traced verdict-header → `**Verdict:**` line (exists, parses), record-shape → schema (fails, M1), verifier → `index.md` (fails, M2), producer → `index.md` (never touched, basis for M4). Stated above.
- **Blameless-precise:** findings name the artifact, the line, and the exact move; two Majors carry reproduced command output.

REJECT stands on M1 and M2 alone (both proven). Re-review should be a DELTA to the same reviewer with this round's Major IDs walked Present/Absent/DRIFTED.

```starcar-artifact
outcome: REJECT
findings: 5 Major, 4 Minor, 2 Notes. M1 (proven) R7 migration-record shape is schema-invalid, missing session_id, findings, and the schema const; C.1 Step 1's validate assertion is unsatisfiable. M2 (proven) R9's default-to-artifacts plus -Recurse makes the bare verifier glob artifacts/index.md, which has no integrity header, so the migration commit exits 1 and turns CI red, the exact atomicity failure the one-commit rule prevents. M3 living-contracts violation, C.1 commits the first index instance and C.2 arms the staleness gate but the plan defers both the state-ledger and gating-matrix flips to C.4, out of the invalidating commit. M4 Handback 3 claims producer records merge cleanly, but the producer never regenerates index.md, so the merged HEAD fails C.2's own staleness gate and the regenerate-before-PR step is unstated, violating MERGE NORTH STAR. M5 the migration deletes docs/reviews and repoints the verifier to artifacts, but Land-Verdict still lands verdict md bodies to docs/reviews, so future verdicts risk landing silently unverified, R9's empty-then-deleted premise is unguarded. Minors: R9 cites line 24 for the default that lives at line 27; R7 outcome-parse ambiguity yields 22 unrecognised-outcome discoveries; README adapter edit risks a premature board-consumption claim; ubuntu-leg suite portability unproven with scope-creep risk. Notes: isAsync 6/6 evidence is gitignored but the finding lands durably; R7 integrity canonicalisation for the pointer record is unspecified and untested. One-commit reading is blessed in principle but currently unmet due to M2. R8 sound. DocPolicy and detector confirmed clean post-migration.
abstract: Plan adversary REJECT of the dispatch-harness Car 3 plan rev 1 at base c595fb9. Two empirically proven Majors are each independently sufficient: the R7 migration record shape fails the landed schema validator, and the R9 verifier repoint plus recurse chokes on the headerless index.md and turns the migration commit CI-red. Three further Majors cover deferred living-contract flips, a false merge-clean handback claim that trips the plan's own staleness gate, and an unguarded verification gap for future verdicts. Coverage mapping is complete; the defects are omissions and unsound rulings, not structure. Re-review as a delta to the same reviewer.
```