<!-- starcar-integrity: sha256=bb0d29d5dea75087f420dac80df27a78995154f9e73901d4e39899928e33283c covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Car 2 plan review, round 1: REJECT - 7 Major at the consumed-blind boundaries

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Plan review (adversarial, 5 dimensions + rulings)
Round: 1
Target: `docs/plans/2026-07-22-harness-car2-plan.md rev 1`
Base reviewed: `efb7e67e37a187db9eaf593afc68d38ebba9d54d`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `aa0ec57449490af3f`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `efb7e67e37a187db9eaf593afc68d38ebba9d54d` |
| Entire checkpoint | `fa2e9f238648` |
| Dispatch, the locator within the session | `aa0ec57449490af3f` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain efb7e67e37a187db9eaf593afc68d38ebba9d54d
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

VERIFICATION COMPLETE. Base `efb7e67`, worktree clean (my git-interference test ran in an isolated `mktemp` dir). All findings below were re-derived by running, not read from the plan's self-report.

---

# VERDICT: REJECT

Seven Major findings. Any one is REJECT; the two decisive, highest-confidence ones are M1 (the envelope-mandate documentation obligations — the feature's load-bearing dependency — are dropped from every task file-list) and M2 (the producer's commit sequence demonstrably entangles the conductor's staged files, a repo-corruption class defect I reproduced). This is a fresh gate series; a REJECT here is the gate working.

The plan is strong on the mechanical spine — reds run and valid at pwsh 7.6.3, baselines exact (43/8/16), R4 sound, the self-referential baseline correctly floated. The defects cluster at the boundaries the plan consumes blind: what the payload actually carries, what the spec assigned Car 2 in documents, and what `git commit` actually does.

---

## MAJOR FINDINGS

### M1 — The envelope-mandate documentation obligations (spec §9, Car 2) are dropped into a blanket phrase and appear in no task file-list.
Spec §9 assigns to **Car 2**, by name:
- `CLAUDE.md` — "Every brief must mandate the envelope (§2.3)"
- `docs/templates/car-brief.md`, `.claude/agents/car.md`, `/goodnight skill` — "Envelope and sweep duties"

Design §8 agrees (rows for `CLAUDE.md` and the templates, owner Car 2). The plan's B.5 **Files** list (plan:255-261) enumerates only `state-ledger.md`, `gating-matrix.md`, `setup.md:23-24`, then hand-waves "spec §9 rows owned by Car 2." None of the four envelope-mandate documents appears in any task's file list, and the plan's own coverage table (plan:310) folds them into "config docs" — the exact blanket-row concealment the brief warned of.

This is not a peripheral doc. The envelope is the mechanism by which a `returned` record obtains its outcome (spec §2.3, which itself notes *"docs/templates/car-brief.md does not mandate an envelope today, so that work is real and outstanding"*). Without the car-brief/CLAUDE.md mandate, dispatched agents emit no envelope, B.1's parser parses nothing, and B.2 writes `outcome: error, envelope: absent` for every real dispatch. Documentation ranks equal to code; a dropped, load-bearing Car-2 doc obligation is a Major.

### M2 — The producer's commit sequence entangles the conductor's staged files (repo-corruption class). REPRODUCED.
B.2 step 3 (plan:152-153): *"`git add &lt;path&gt;` + `git commit` ... own path ONLY ... NEVER `-a`, never push."* I tested this in a scratch repo:

```
conductor stages conductor.txt   -&gt; index: A conductor.txt
producer: git add producer.txt
producer: git commit  (bare, no -a, no pathspec)
RESULT commit contains: conductor.txt + producer.txt   (2 files)
```

`git add &lt;path&gt;` adds the producer's file to the index; a **bare `git commit` then commits the entire index**, sweeping in whatever the conductor already staged. "Never `-a`" is a red herring — `-a` auto-stages *tracked modifications*; the entanglement here is from *already-staged* files, which bare `git commit` includes regardless of `-a`. The SubagentStop hook fires in the **main (conductor) session's shared checkout**, not the car's isolated worktree, so a conductor mid-stage when any subagent stops has its work committed under `harness: returned &lt;subject&gt;`. The plan's stated guarantee "own path ONLY" is false as written; the correct primitive is `git commit -- &lt;path&gt;` or `git commit --only -- &lt;path&gt;`. B.2's tests (plan:162-168) contain no staged-file-isolation red, so the guard is both wrong and unwatched.

### M3 — `last_assistant_message` is an unverified payload field that deviates from the spec's outcome-extraction mechanism.
B.1/B.2 obtain the outcome by running the envelope parser against a payload field `last_assistant_message` (plan:108-109, 146-149). Two problems:
- **Fidelity:** Spec §2.3 and design A1 build the mechanism on `agent_transcript_path` — *"the payload carries `agent_transcript_path`, so the producer never scrapes..."* `last_assistant_message` appears **nowhere** in the spec, design, or the probe-results substrate the plan cites as authority. The probe doc enumerates only `agent_id`, `agent_type`, `agent_transcript_path` (existence-stamped), `background_tasks` — I grepped it (only `agent_id` on the returned path). The plan substitutes an un-blessed field for an approved-spec mechanism ("faithful, not improve").
- **Verifiability:** the plan's "verified at base" claim (plan:108-109) is unverifiable — `.claude/probe-logs/subagent-stop.jsonl` is gitignored (`.gitignore:1`) and absent from the worktree. I cannot confirm the field exists or carries the envelope. If it does not, B.1/B.2 hit a hard wall.

### M4 — The `dispatched` record's identity (`subject = agent_id`) is unverified and, per the cited evidence, likely unavailable.
B.2 sets `subject = agent_id` for **both** kinds (R2, plan:146). For `returned` (SubagentStop) `agent_id` is proven present. For `dispatched` (PostToolUse:Task at launch) it is not: the design-round1 REJECT MAJOR-1 — the very citation the spec §2.1 "Verified" column leans on — states *"`PostToolUse:Task` ... fires at launch, with no body."* The probe hook only ever observed SubagentStop; the launch payload was **never probed**. There is no dispatched-hook fixture, no evidence PostToolUse:Task carries `agent_id`, and no residual note. If it does not, `dispatched` and `returned` never share a subject, tier-1 correlation collapses, and tier 1 is *"the ONLY path that surfaces kills"* (probe 1). This identity gap is also **not in the Handback list** (plan:274-284) — it falls between car-fixturable and conductor-handback, unowned.

### M5 — R5 places this shop's operational config inside the portable schema contract, contradicting the schema's own words.
R5 (plan:70-76) puts `dispatch_budget_seconds: 1800` in `schema/defaults.json`. But `schema/starcar-artifact.schema.json:45-46` states the default *"is the detector's to apply, **never the schema's**."* Putting it in `schema/` — the language-neutral, stranger-deployable contract directory (holding the schema, index-format, recognition vocabularies, conformance vectors) — makes a stranger cloning the contract inherit this shop's 1800s budget. The plan's justification ("same Law-7 posture as the vocabularies") is a false equivalence: recognition vocabularies are shared contract *data*; a budget value is local *config*. Law 6 (one owner per contract) and Law 7 (portability). Re-home to the detector/config side. **Ruling R5 is rejected.**

### M6 — R6's tier-2 enumerates checkpoints, not dispatches; implemented as written, B.3 becomes a wolf-crying detector.
R6 (plan:77-82, 208-210) has B.3 implement *"tier 2 = `entire checkpoints list` enumeration ... enumerated-but-storeless checkpoints raise a tier-2 gap line."* I ran `entire checkpoints list`: it enumerates **checkpoints keyed to commits** (65 of them, each `checkpoint-id / prompt / commit`), not dispatches/agent_ids. But spec §2.5 and design §5.5/§6 define tier 2 as *"an enumerable second source [that] finds **dispatches** the store never heard of."* A checkpoint is not a dispatch, and the plan supplies no checkpoint→subject mapping — so "storeless checkpoints raise a gap line" raises a gap for **every commit not in the dispatch store**, which is nearly all of them. That is an instrument that cries wolf (worse than none, by this shop's own severity philosophy). The tier-*exposure* half ("tier 1 only" when entire is absent) is faithful; the enumeration *target* is a semantic mismatch. **Ruling R6: exposure faithful, enumeration unresolved — must be settled before B.3 implements tier 2.**

### M7 — B.4 deletes the verdict-extraction function yet requires byte-identical re-landing; the regression pin is unachievable as written.
B.4 (plan:239-247) deletes both `Get-LiveTranscriptPath` (`:59`) **and** "parent-transcript scraping (`:78-115`)" — which is `Get-ResultBlockForTask`, the function that extracts the `&lt;result&gt;` block for a task id (Land-Verdict.ps1:78-116, called unconditionally at `:182`). It then requires "*with `-TranscriptPath`, a fixture transcript lands a verdict **byte-identically to the current behaviour**.*" These are incompatible: with the only extraction function deleted, the CLI has no way to produce the body, so byte-identity is impossible, and the plan names no replacement extractor. If the intent is to extract via the envelope parser instead, the output is envelope fields, not the full `&lt;result&gt;` block the 16 landed verdicts contain — still not byte-identical. The red-first shape of B.4 is therefore incoherent (directly answering the brief's dimension-(d) question). The spec §4 row 2 replaced `:78-115` with *"`agent_transcript_path` from the hook payload"* — but m3 says backfill has **no** hook payload, so nothing fills the hole.

---

## MINOR FINDINGS

- **m1 — `session_id` sourcing unstated.** The schema requires `session_id` (schema:86); B.2's field-mapping prose (plan:146-150) omits it while enumerating the others. "Build per schema / canonical order" implicitly includes it, and the `Test-StarcarArtifact` assertion would catch omission, but the *source* field is unnamed. State it.
- **m2 — `setup.md:23-24` reassigned Car 3 → Car 2 without an explicit deviation marker.** Spec §9 and design §8 both assign `setup.md:23-24` to Car 3; B.5 takes line 23 for Car 2. This is *correct* under the same-commit living-documents rule (B.4 invalidates the "expected to change / currently in adversarial review" note at line 23), but carrier discipline wants it marked as a justified deviation from spec §9, not silently split.
- **m3 — probe-log availability for the car.** B.1/B.2/B.4 source fixtures and the fault-injection replay from the gitignored, worktree-absent `.claude/probe-logs/subagent-stop.jsonl`. The plan is the carrier to the car and does not state how the car obtains the payloads; a car in a detached worktree cannot build the fixtures or run the flood without them. Can escalate to blocking if the conductor does not supply them in the brief.
- **m4 — combined hook latency on SubagentStop.** The plan keeps the probe hook *and* adds the producer hook on one event (correct that arrays support it — verified). Probe 2 measured a *single* blocking hook; two blocking hooks' latencies add on the stop path. Not modelled. Low stakes (probe hook is cheap), noted for completeness.

---

## COVERAGE WALK (rebuilt independently, spec subsection by subsection)

| Spec subsection | Plan disposition | My check |
|---|---|---|
| §2.1 producer hooks | B.2 | OK (but dispatched identity unproven — M4) |
| §2.2 `agent_type` only | B.2 filter + B.4 non-vacuity | OK; filter matches ruling 2 |
| §2.3 envelope, absent/malformed, outcome source | B.1 + B.2 | outcome SOURCE deviates (M3); absent/malformed correct |
| §2.4 concurrent writes, raise-never-drop | B.2 | raise-never-drop OK (`_faults.log`); "own path only" FALSE as written (M2) |
| §2.5 tiers, fold exposes tier | B.3 (R6); CI fetch Car 3 | exposure OK; enumeration target wrong (M6) |
| §3.1 precedence, supersession, intent | B.3 | OK, cell-per-sentence |
| §3.2 vocabularies, one-fault reads | B.3 (consumes A.1/A.2) | OK; matches Artifact.psm1 one-fault posture |
| §3.3 budget, gradient, **basis**, shop default | B.3 + R5 | gradient OK; **basis: faithful** (no task writes presumed-lost; human does per design §2b roll-call — a spec-approved scoping, not a plan drop). Latent gap noted below. R5 rejected (M5) |
| §3.4 spend from cost only | B.3; producer omits cost v1 | OK; #11 deferral honest |
| §3.5 un-backfilled gap | B.3 stateless "stays" | OK |
| §3.6 normalisation declared, integrity | B.2 writes; format A.1 | matches index-format.md:60-72, schema `normalisation`/`integrity` |
| §4 rows 1-3 | B.4 | incoherent (M7) |
| §4 rows 4-5 | Car 3 | OK |
| §5.1 no process state | each ledger line | OK |
| §5.2 index CI gate | Car 3 | OK |
| §6 cells / non-vacuity flood | B.3 / B.4 | flood depends on absent probe log (m3) |
| §9 producer/detector/config docs | B.5; migration = Car 3 | **DROPS the CLAUDE.md + car-brief + car.md + goodnight envelope-mandate rows (M1)** |

**On §3.3 basis (brief's explicit question):** *faithful, not a dropped obligation.* Design §2b's roll-call and spec §5.1 both say `presumed-lost` (and its `basis`) is written by a human deliberately; no automated task owns it, and the spec never mandated an authoring tool. **Latent gap worth the conductor's eye (not charged against the plan):** a human cannot practically hand-author a canonical, hash-correct, normalised `presumed-lost` artifact by hand — the "human writes it" story has no tool anywhere in Car 1/2/3, so the detector's `presumed-lost` precedence is only ever exercised by fixtures. That is a spec-rung scoping the plan inherits honestly.

---

## SNIPPET / CLAIM VERIFICATION LOG (with conditions)

| Claim | Condition | Observed | Verdict |
|---|---|---|---|
| B.1 red: module not found | pwsh 7.6.3, rendered message | *"The specified module './scripts/Envelope.psm1' was not loaded because no valid module file was found..."* | MATCH |
| B.2 red: `CommandNotFoundException` | pwsh 7.6.3, exception type | `System.Management.Automation.CommandNotFoundException` | MATCH |
| B.3 red: `CommandNotFoundException` | pwsh 7.6.3 | same type, script absent | MATCH |
| round-2 verdict has exactly 1 `starcar-artifact` fence | `grep -c` | `1` | MATCH |
| `entire checkpoints list` emits id+prompt+commit (R6) | Git Bash, entire present (`scoop/shims/entire`) | id `fa2e9f23...`, prompt, commit `efb7e67` | MATCH (but enumerates checkpoints, not dispatches — M6) |
| baseline: tests 43/0 | pwsh 7.6.3, `Invoke-Pester ./scripts/tests` | Passed 43, Failed 0, Skipped 0 | MATCH |
| baseline: probes 8/0 | `Invoke-Pester ./scripts/probes` | Passed 8, Failed 0 | MATCH |
| Verify-Verdict bare: exit 0, all verified, 16 files | pwsh 7.6.3 | "16 verdict file(s) verified", exit 0 | MATCH |
| Land-Verdict anchors `:59` / `:78-115` / `:39-51` / `:112-115` | read at base | `:59` USERPROFILE path; `:78-115` `Get-ResultBlockForTask`; `:39-51` param block; `:112-115` repeat-notification comment | MATCH |
| index-format.md `:17-20` / `:47-48` / `:60-72` | read at base | canonical order / "file relative to store root" / normalisation rule | MATCH |
| ci.yml `:47` = `./scripts/Verify-Verdict.ps1` | read at base | confirmed | MATCH |
| settings arrays support 2 hooks/event | read at base | PostToolUse has 2 matcher objects; SessionStart has 4-hook array | MATCH |
| `last_assistant_message` carries final text | probe log | **log absent (gitignored); UNVERIFIABLE** | FAIL (M3) |
| PostToolUse:Task carries `agent_id` | probe log / design | **never probed; design round1 says "no body"** | FAIL (M4) |

---

## RULINGS

- **R4 (store root `artifacts/`, event-unique `&lt;subject&gt;/&lt;kind&gt;-&lt;compact-at&gt;.json`): SOUND.** The repeat-`returned` evidence is real (independently corroborated — the entire checkpoint list shows resume-driven repeats; Land-Verdict.ps1:113-114 documents the same class). Event-unique filenames are consistent with `New-ArtifactIndex.ps1:25` (globs `*.json -Recurse`, derives every index column from file *content*, not the filename) and with `index-format.md:47-48` ("`file` relative to store root"; illustrative `dispatched.json` names correctly declared non-normative). Faults land in `artifacts/_faults.log` (`.log`, not `.json`) so the index glob will not ingest them — safe. APPROVED.
- **R5: REJECTED.** See M5 — shop config in the portable schema contract, against the schema's own "never the schema's."
- **R6: exposure faithful, enumeration unresolved.** See M6 — `entire checkpoints list` enumerates checkpoints, not the dispatches spec §2.5 requires.

---

## GIT-COMMIT-INTERFERENCE ANALYSIS

Reproduced in an isolated scratch repo (verdict M2). The chain the plan specifies — `git add &lt;path&gt;` then bare `git commit` — does **not** honor "own path only." A bare commit serializes the whole index; any file the conductor staged before the SubagentStop hook fired is committed under the harness message. Because the hook runs in the conductor's shared checkout (not the car's worktree), and the conductor routinely stages work, the exposure is live, not hypothetical. The retry-on-contention logic (index.lock) is orthogonal and does not address entanglement. Fix is mechanical: `git commit --only -- &lt;path&gt;` (or `git commit -- &lt;path&gt;`), plus a red asserting a co-staged foreign file is excluded. The plan's own latency residual (probe 2, failing-hook unmeasured) is disclosed honestly and correctly — that part is a model.

---

## CONSTITUTION CHECK

- **Law 1 (no confident falsehood; unknown renders unknown):** IMPLICATED. M3/M4 assert unverified payload fields as established; M6 renders non-gaps as gaps. B.2's "own path only" (M2) is a confident falsehood about behavior.
- **Law 4 (nothing silently dropped):** Honored at runtime (`_faults.log`, raise-never-drop). Violated at the process layer by M1 (dropped doc obligations).
- **Law 6 (one owner per contract; no second copy):** M5 puts config under the schema's ownership against the schema's text. Index regenerate-and-diff correctly assigned to Car 3 — honored.
- **Law 7 (stranger-deployable; no hardcoded taxonomy):** M5 leaks shop config into the portable contract; vocabularies-as-data honored (Artifact.psm1 + vocab/).
- **Documentation ranks equal to code / same-commit living docs:** M1 is the sharp violation (Car-2 envelope docs dropped). m2 is the rule being applied *correctly* (setup.md:23 trued in B.4's commit) but under-marked.
- **Match instrument to artifact:** Honored — format stays in Car 1's schema/vectors; behavior in the plan; reds are executable. Good.
- **Red-first:** B.1/B.2/B.3 reds valid and run. B.4's red (M7) is incoherent given the deletion.
- **Verification honesty:** the plan's baseline coordinates are accurate (I re-derived 43/8/16 exactly) and the self-referential float is handled correctly — the one thing the plan gets unambiguously right about counts.

Fix cycle should return to the **same plan-writer** with a DELTA re-review (worked-briefs precedent). The swirl trigger does not yet apply (round 1 of a fresh series).

Relevant absolute paths:
- Plan under review: `~\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\64c15364-0933-4d6d-9b2e-d1ddbc918f9f\scratchpad\review-plan-2\docs\plans\2026-07-22-harness-car2-plan.md`
- Spec: `...\review-plan-2\docs\specs\2026-07-22-dispatch-harness-spec.md`
- Schema: `...\review-plan-2\schema\starcar-artifact.schema.json`, `...\schema\index-format.md`
- Scripts: `...\review-plan-2\scripts\Land-Verdict.ps1`, `New-ArtifactIndex.ps1`, `Artifact.psm1`
- Design-round1 evidence: `...\review-plan-2\docs\reviews\2026-07-22-harness-design-round1-REJECT.md`

```starcar-artifact
outcome: REJECT
findings: 7 Major, 4 Minor. Majors: M1 envelope-mandate docs (CLAUDE.md, car-brief, car.md, goodnight; spec section 9, Car 2) dropped from every task file-list; M2 producer bare git commit entangles conductor-staged files, reproduced in scratch repo; M3 last_assistant_message is an unverified payload field deviating from the spec agent_transcript_path mechanism; M4 dispatched subject=agent_id unverified and evidence says launch payload has no body; M5 ruling R5 puts shop config in the portable schema contract against the schema's own text; M6 ruling R6 tier-2 enumerates checkpoints not dispatches (wolf-crying detector); M7 B.4 deletes the verdict-extraction function yet demands byte-identical re-landing. Reds valid at pwsh 7.6.3, baselines exact 43/8/16, ruling R4 sound.
abstract: Car 2 plan rev 1 REJECTED at the plan gate. The mechanical spine is sound (reds run and fail for their stated reasons, baselines re-derived exactly, R4 store layout consistent with the landed index generator, self-referential baseline correctly floated), but the plan fails at the boundaries it consumes blind: it drops the load-bearing envelope-mandate documentation Car 2 owns, specifies a commit sequence that provably sweeps the conductor's staged files into harness commits, rests the producer outcome and identity paths on payload fields the ground-truth probes never recorded, and mis-homes a shop default into the stranger-deployable schema. Recommend DELTA re-review by the same plan-writer.
```