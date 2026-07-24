<!-- starcar-integrity: sha256=ce80f3e5abfcdcbc6a019c5af3d0ee3b34e723a7c3414cb5b9d1f0ec74a9e09c covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Family-agnostic harness car review, round 1 (sentence check)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-review
Round: 1
Target: `car/47-family-agnostic`
Base reviewed: `0f3ae88`
Reviewer: 47-car-review-r1
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `47-car-review-r1`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `0f3ae88` |

| Dispatch, the locator within the session | `47-car-review-r1` |
| Entire session (context, NOT a lookup key) | `cr47-r1-transcript` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 0f3ae88
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Agent is idle (waiting for messages). agent_id: 47-car-review-r1, agent_type: car, status: idle, description: Adversarial review of car 47 branch, elapsed: 650s, total_turns: 1, model: claude-opus-4.8

[Turn 0]
Worktree clean, HEAD `0f3ae88`, no residual changes. Here is my verdict.

---

# Adversarial Sentence-Check Review — Family-agnostic harness (Car 47), round 1 — REJECT-authority verdict

**Dispatch:** `47-car-review-r1`
**Base verified:** worktree `<repo>-car47`, branch `car/47-family-agnostic`, HEAD `0f3ae88`, base `df4fb95`, 7 commits (`570dbe4, 80ffc87, 0b60507, b816c66, 51ae446, a7d0d0d, 0f3ae88`). ✓
**Verdict: APPROVE** (2 Minor findings, 0 Major). Minors should be fixed but do not block merge.

## Suites I ran myself (at 0f3ae88, in the car's worktree)
| Suite | My observed | Car claimed | Match |
|---|---|---|---|
| `Invoke-Pester scripts/tests` | **275 passed, 0 failed** (17 files) | 275/275 | ✓ |
| `Invoke-Pester scripts/probes` | **22 passed, 0 failed** (3 files) | 22/22 | ✓ |

## Fault-injection evidence (guard watched firing)
I disabled the DR-9 refusal guard (`if ($false -and ...)`) in `Produce-Artifact.ps1:388` and re-ran `Producer.Tests.ps1`: **FAILED=1, PASSED=15** — the failing case was verbatim *"#47 DR-9: a second in-flight dispatched for a subject that already has an un-superseded dispatched is REFUSED, keep-first"*. Reverted with `git checkout`; `git status` clean (byte-identical). The guard is proven to fire; without it the second dispatch lands and keep-first breaks.

## Sentence-check traces (hop-for-hop, file:line)

**Minted-id path, mode (a) Copilot — LAUNCH → board:**
`tool_input.name` (dispatch label) → `Produce-Artifact.ps1:198` `$subject = Get-Prop $toolInput 'name'`, `subjectBasis='minted-id'` → record `subject` + `subject_basis` written (`:353-358`) → subjectDir `artifacts/<subject>/` → detector groups by subject (`Detect-Dispatches.ps1`, unchanged). Pinned green by `copilot-launch-minted-from-name.json` via `AdapterVectors.Tests.ps1`. ✓

**Minted-id path — RETURN (Copilot mode a):** envelope `task-id:` → `Envelope.psm1:127` regex `^(task-id|outcome|findings|abstract):` → `TaskId` (`:138,:154`) → `Produce-Artifact.ps1:243` `$taskId=$env.TaskId` → `:260-262` Copilot `$subject=$taskId`. **I directly exercised this untested path** with a synthetic Copilot returned payload: record written `subject=47-car-r1`, `subject_basis=minted-id`, `task_id=47-car-r1`, `provenance={runtime:copilot,agent_name:car}`. Launch subject (`47-car-r1`) = stop subject (`47-car-r1`) → one dispatch, one subject. ✓

**Mode (b) Claude — launch/stop same subject:** launch `tool_response.agentId` (`:190`) → subject, `subject_basis='runtime-id'`; stop `agent_id` (`:161`) → subject, `task_id` from envelope (`:356`). Both disclose `subject_basis: runtime-id`. Pinned by `claude-launch-runtime-id.json` + `claude-stop-envelope-taskid.json` (green). The producer implements the split as explicit `if claude … elseif copilot` branches for both kinds — a real mode split, **not a blur**. ✓

**DR-9 guard:** store read `Get-ChildItem dispatched-*.json / returned-*.json` (`:384-385`) → refusal condition `existingDisp>0 AND existingRet==0` (`:386`) → `throw` loud fault → caught, `_faults.log` written, no record. Q2 boundary (post-return reuse NOT refused) proven by the `#47 Q2 boundary` test (green) and by inspection (`existingRet>0` ⇒ not refused). Red-first proof homed in `Producer.Tests.ps1:326-364` (stateful, store-seeded) exactly as the DR-11 resolution states; rehoming stated in `schema/vectors/adapter/README.md` ("Where the STATEFUL refusal guard is proven") AND design §9c `[DR-11, resolved by car]`. ✓

**ONBOARDING.md claims:** all 11 cited paths exist (`docs/constitution.md`, `the-healing-loop.md`, `CLAUDE.md`, `glossary.md`, `setup.md`, `doc-map.md`, `docs/templates/`, `artifacts/reviews/`, `docs/retros/`, `.github/copilot-instructions.md`); "The statute index" heading present at `CLAUDE.md:58`; `.github/copilot-instructions.md` exists and points back to `ONBOARDING.md`; `CLAUDE.md` diff is exactly the top pointer line + a blank line — rest untouched. doc-map/README/setup/glossary/spec-S2 new rows all trace to real files. ✓

## Vector provenance re-observation (ran vectors against the BASE `df4fb95` producer)
| Vector | Provenance claim | Base behaviour observed | Truthful? |
|---|---|---|---|
| `claude-launch-runtime-id` | base writes subject=agentId, no subject_basis | subject=`a1b2c3…`, no subject_basis | ✓ accurate |
| `unrecognisable-payload-skip` | base "exits 0 SILENTLY … no stderr" | EXIT=0, stderr empty, 0 records | ✓ accurate |
| `copilot-launch-minted-from-name` | base "reads tool_response.agentId … and **throws 'no subject id'**" | EXIT=0, **no output, no throw** — exits 0 silently at the `subagent_type` filter | **✗ FALSE** → CR-1 |
| `duplicate-subject-two-dispatched` (fold) | OBSERVED, generated by running the detector | validated green by `Detector.Tests.ps1` fold runner | ✓ |

## Findings

### CR-1 — MINOR — `copilot-launch-minted-from-name.json` misdescribes the base failure mode
`schema/vectors/adapter/copilot-launch-minted-from-name.json` description states the landed (base) producer *"reads tool_response.agentId (absent from the compat launch payload) and throws 'no subject id' (scripts/Produce-Artifact.ps1 filter+subject read)."* I ran the base `df4fb95` producer on this exact payload: it **exits 0 silently** at `if ([string]::IsNullOrWhiteSpace($subagentType)) { exit 0 }` and never reaches the agentId read — no throw. The vector still lands red-first (base writes 0 records vs expected 1), and the DESIGN-MANDATED label + OBSERVED shape are both sound, so the conformance proof is intact — but a spec-tier fixture carries a checkable, file-cited, false behavioral claim. This is precisely the "summarized, not re-observed" hazard the car disclosed for item 2, surfacing as a wrong mechanism.
**Fix:** replace "reads tool_response.agentId … and throws 'no subject id'" with "exits 0 silently at the `subagent_type` launch filter, writing no record."

### CR-2 — MINOR — Copilot stop-with-envelope path ships with no vector/test; scope note understates the gap
The Copilot returned path (`agent_name` recognition `:159-166`, `transcript_path` fallback `:230`, `subject=$taskId` `:260-262`, throw-if-no-taskid `:258`) has **no adapter vector and no unit test**. `schema/vectors/adapter/README.md`'s scope note discloses only the *no-envelope/events.jsonl* corner as deferred (OBSERVED-shape absence — sound reasoning), but does not flag that the **with-envelope** Copilot stop path — buildable from the already-OBSERVED `agent_name`/`transcript_path` keys — ships unproven. I exercised it directly and it is **correct** (record `subject=47-car-r1`, `task_id=47-car-r1`), so this is a coverage/disclosure gap, not a broken trace.
**Fix:** add a `copilot-stop-envelope-taskid` adapter vector from the observed keys, or explicitly state in the scope note that the with-envelope Copilot stop path is implemented-but-unpinned.

**NOTE (non-blocking):** design §5.3's mechanism bullet names "the Copilot no-envelope-at-stop vector" which was not built (a Claude one was; the Copilot boundary is disclosed in the adapter README). D3's binding *behavioural* contract (absent-envelope → `envelope: absent`, runtime-agnostic post-normalisation) is satisfied and green, so this is illustrative-prose drift in the approved design, not a broken contract — folds into CR-2's theme.

## Rulings on the three disclosures
1. **SessionStart restart-gated** — ACCEPTABLE deferred. The `sh .claude/hooks/*.sh` intersection-dialect move + probe key fix are design-sanctioned (D5/D6), disclosed in `setup.md` ("Still restart-gated (NOT claimed verified here)") and design §2c row 4, with a named trigger (next restart of each runtime). I could not watch it fire mid-session — that is the disclosed gate, not a hidden hole.
2. **Copilot events.jsonl / no-envelope corner** — ACCEPTABLE deferred: the OBSERVED shape genuinely lives only in the gitignored `.claude/probe-logs/`, and inventing it would violate vector provenance discipline. The *adjacent* with-envelope path, however, was pinnable from observed keys → CR-2.
3. **RED provenance items 1/2/4 pre-compaction** — items 1 & 4 re-observed **accurate** against base; item 5 (DR-9) re-observed by my fault-injection; item 2's summary is **wrong** → CR-1. The red-first bar is met for 1/4/5; item 2's red outcome holds but for a different reason than stated. Re-observation caught exactly the drift the disclosure warned of.

## Regression / integrity sweep
- Producer seam is an EXTEND: old `agent_type`/`subagent_type` filters preserved as the Claude branch; `LandVerdictRider.Tests.ps1` non-vacuity flood correctly retargeted to the new `if (-not IsNullOrWhiteSpace($agentType))` structure and copies the new `lib/TranscriptRead.ps1` sibling — proof preserved, green.
- `Land-Verdict.ps1` param interface unchanged; `Get-TranscriptLines` now delegates to `Read-TranscriptLines` keeping its own throw-on-missing contract; its tests green.
- No store records committed (no `artifacts/` paths in diff); producer remains stateless per-invocation, so `docs/contracts/state-ledger.md` correctly needs no update — design §8 "no mutable service state touched" **verified**.
- `#47` citations present on every new code unit (`TranscriptRead.ps1`, `Write-VisibleSkip`, adapter README, vectors, tests).

## Constitution check (diff-implicated laws)
- **Law 1 (truth):** subject_basis discloses semantics per record; visible skip names present keys (I watched base's silent exit become a stderr line). Honored — except CR-1 is a Law-1 blemish in a fixture comment.
- **Law 4 (nothing lost):** absent-envelope mints `envelope: absent`; DR-9 refusal is a loud `_faults.log` fault (watched). Honored.
- **Law 6 (one truth):** one producer, one transcript-read home (`TranscriptRead.ps1`), pointers not copies (CLAUDE.md/copilot-instructions). Honored.
- **Law 7 (stranger/family-agnostic):** neutral `ONBOARDING.md` front door, all cited paths resolve; mode split adapts each family to the repo's contract. Honored.
- **Carrier rule:** minted id crosses out in the brief (templates updated) and back in the envelope `task-id` (traced end-to-end). Honored.

No Major. APPROVE with CR-1 and CR-2 to be cleared by the car or a follow-up.

```starcar-artifact
task-id: 47-car-review-r1
outcome: APPROVE
findings:
  - CR-1 (MINOR): copilot-launch-minted-from-name.json provenance prose falsely claims the base producer "reads tool_response.agentId and throws 'no subject id'"; re-running the base df4fb95 producer shows it exits 0 silently at the subagent_type filter with no throw. Vector still lands red-first and label/shape are sound, so the proof is intact; fix the mechanism sentence.
  - CR-2 (MINOR): the Copilot stop-with-envelope path (agent_name recognition, transcript_path fallback, subject=task-id) ships with no adapter vector or unit test, and the adapter README scope note discloses only the events.jsonl/no-envelope corner. Directly exercised the path and confirmed it is correct, so coverage/disclosure gap only; add a copilot-stop vector from the observed keys or disclose it explicitly.
  - NOTE (non-blocking): design section 5.3 names a "Copilot no-envelope-at-stop vector" not built (a Claude one shipped, Copilot boundary disclosed); D3 behavioural contract is met and green, illustrative-prose drift only.
abstract: >
  Independent re-run at HEAD 0f3ae88 reproduced 275/275 tests and 22/22 probes; the DR-9
  refusal guard was watched firing via fault-injection (disabling it fails exactly the
  keep-first case) and reverted byte-identical. The full minted-id sentence-check traces
  clean hop-for-hop: mode (a) Copilot launch (tool_input.name) and stop (envelope task-id)
  resolve to the same subject 47-car-r1 (I exercised the untested Copilot return path
  directly and it is correct), and mode (b) Claude keeps its runtime-UUID pairing with
  subject_basis disclosed. Re-observing the pre-compaction RED provenance against the base
  producer confirmed items 1 and 4 accurate but caught item 2's provenance prose as false
  (base exits 0 silently, does not throw) - CR-1, Minor. A second Minor (CR-2) flags the
  untested-but-correct Copilot stop-with-envelope path. No Major: contract implemented,
  traced, tested, green, no regression, ledger correctly untouched. APPROVE with two Minors.
```