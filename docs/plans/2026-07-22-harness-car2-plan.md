Status: Current

# Dispatch harness - Car 2 implementation plan, rev 3 (envelope, producer, detector, retirements)

REQUIRED SUB-SKILL: one car per task group, adversarial reviewer per car.

Source of truth: `docs/specs/2026-07-22-dispatch-harness-spec.md` APPROVED + S1. Design
rev 6 + A1. Substrate header: `docs/probes/2026-07-22-spec7-probe-results.md` plus the
two NEW probes this revision forced (launch-payload shape; transcript extraction - both
below, both landed in the probe log AND quoted here with conditions).

Review record: **round 1 REJECT - 7 Major, 4 Minor**
(`docs/reviews/2026-07-22-car2-plan-review-round1.md`); **round 2 (ROTATION DRILL,
fresh reviewer, carriers only) REJECT - 1 Major, 1 Minor**
(`docs/reviews/2026-07-22-car2-plan-review-round2-drill.md`) - 10 of 11 round-1 folds
ruled PRESENT and re-verified (the `--only` fix PROVEN in a scratch repo), one DRIFTED
(M4's landing), convergence ruled healthy (7 to 1, shrank and moved, no swirl), and
**the drill SUCCEEDED**: the fresh reviewer re-derived the round-1 findings from
carriers alone, surfacing two verdict-template gaps as success findings (tracked in
the template-gaps issue). All round-2 findings folded in this rev 3; disposition table
below is the carrier. R4 SOUND; R5v2, R6v2 both ruled sound at round 2.

**Scope: Car 2 only, on OPUS.** Car 3 after this car lands.

> # BINDING AMENDMENT BLOCK (conductor-applied)
> *Empty at rev 2. The car reads this block FIRST; entries supersede contradicting text.*

## Base, baselines, and the STOP rule

Base: the commit that lands this rev approved. Baselines re-derived by the car under
pwsh 7, STOP on mismatch: `Invoke-Pester -Path ./scripts/tests` **43 passing, 0
failed**; `Invoke-Pester -Path ./scripts/probes` **8 passing, 0 failed**;
`./scripts/Verify-Verdict.ps1` bare **exit 0, every file verified** (count floats by
design; 17 at rev-2 writing).

## Global constraints

Red-first per step; ledger both questions per task; docs same-commit; honest-stop is a
SUCCESS; car commits locally, never pushes; runtime floor pwsh 7.4, shell stated in
every count.

**Probe-2 latency constraint (BINDING):** producer hook synchronous work = one record
write + one pathspec-scoped commit with capped retry (3), nothing slower (measured: a
slow stop-hook rides the return path in full - 11,609ms with a 10s sleep vs
2,816/1,648ms baselines). Failures RAISED: nonzero exit + one line appended to
`artifacts/_faults.log` (`.log`, outside the index glob - round-1 verified), never
dropped. **[C2R1-m4 folded]** Two hooks ride the stop event (the standing probe hook +
the producer); latencies ADD on the stop path. Accepted and stated: the probe hook is
one python append (the measured 1.6-2.8s baselines already INCLUDE it); the producer
adds pwsh startup + write + commit, expected sub-second beyond that. The Handback
latency check measures the combined reality.

**Residual, stated:** whether a FAILING hook harms the dispatch is unmeasured (probe 2
measured slow, not failing); nothing below leans on dispatch survival after hook
failure.

### Conductor rulings (recorded, reviewable)

**R4 - store root `artifacts/`, records `artifacts/<subject>/<kind>-<compact-at>.json`
(`yyyyMMddTHHmmssZ`), event-unique.** Round 1: SOUND, independently corroborated
(repeat-`returned` real; `New-ArtifactIndex.ps1:25` derives columns from content, not
filenames; `_faults.log` outside the glob). Unchanged.

**R5v2 [C2R1-M5 folded - R5 REJECTED and superseded].** The shop budget default lives
in **`config/harness-defaults.json`** (new shop-local `config/` directory), NOT in
`schema/`. Round 1 was right twice over: the schema's own text
(`starcar-artifact.schema.json:45-46`) says the default *"is the detector's to apply,
never the schema's"*, and `schema/` is the stranger-deployable contract - a stranger
cloning the contract must not inherit this shop's 1800 seconds. Contract and config now
have different owners (Law 6) in different directories (Law 7). Content:
`{"dispatch_budget_seconds": 1800}`. The detector takes `-DefaultsPath` with this as
default; unreadable = ONE board-level fault (§3.2's rule generalises).

**R6v2 [C2R1-M6 folded - enumeration superseded, exposure unchanged].** Round 1
measured the mismatch: `entire checkpoints list` enumerates CHECKPOINTS keyed to
commits (65 at review time), and spec §2.5's tier 2 requires an enumerable source of
DISPATCHES - with no checkpoint-to-subject mapping, every commit outside the store
raises a false gap: a wolf-crying detector, worse than none. Ruled: **Car 2 ships
tier 1 plus the tier-EXPOSURE mechanism only.** The fold's `tier` field reports
`"tier-1-only"` truthfully (spec §2.5: the fold exposes which tier is in force - that
half was always faithful). Tier-2 ENUMERATION is deferred with its trigger recorded in
`docs/setup.md`: a dispatch-enumerable second source proven by probe (candidate: Task
dispatch records parsed from checkpoint-branch transcripts - real but heavy, its own
rider after Car 3, where [m5]'s CI fetch also lives). Deferral is sequencing, not spec
contradiction: §2.5 names the checkpoint branch as ours; the MAPPING it presumes is
what measurement showed missing, and shipping a wolf-crier to satisfy a row would
violate the severity philosophy the spec itself cites.

## The measured payload contracts (NEW - the probes round 1 forced)

**Launch (`PostToolUse`, matcher `Task`) [C2R1-M4 folded; C2R2-M1 folded - the
measurement now lands DURABLY as Probe 5 in
`docs/probes/2026-07-22-spec7-probe-results.md`, alongside probes 1-4; the gitignored
log is the raw capture, the probe doc is the citable record, and the committed hook
regenerates the evidence in one dispatch]:** top-level keys observed:
`cwd, duration_ms, effort, hook_event_name, permission_mode, prompt_id, session_id,
tool_input, tool_name, tool_response, tool_use_id, transcript_path`. `tool_input` carries
`description, model, prompt, subagent_type`; **`tool_response` carries `agentId`** (plus
`resolvedModel, status, isAsync, outputFile, description, prompt, canReadOutputFile`).
**Identity correlation MEASURED: `tool_response.agentId` at launch == `agent_id` at stop
for the same dispatch** (probe agent, both logs). Subject identity (R2: one key) holds
end to end. The design-round-1 "no body" observation was about the RESULT body -
`status: async_launched` - not the identity, which was present and unprobed until now.

**Stop (`SubagentStop`):** keys as recorded in the probe results doc: `agent_id,
agent_type, agent_transcript_path` (exists at fire: measured True for real dispatches),
`session_id`, and others. `agent_type` is `''` for internal subagents (the filter's
signature).

**Fixture payloads for the car [C2R1-m3 folded - the plan is the carrier; the probe log
is gitignored and worktree-absent, so the fixtures travel INLINE, sanitized from real
logged payloads].** The car creates `scripts/tests/fixtures/payloads/` from these:

`stop-car.json` (real dispatch, envelope in transcript):
```json
{"agent_id": "a88e7dadda60940ac", "agent_type": "car",
 "agent_transcript_path": "<repo>/scripts/tests/fixtures/payloads/transcript-car.jsonl",
 "session_id": "sess-fixture-1", "hook_event_name": "SubagentStop"}
```
`stop-internal.json` (internal subagent - filtered):
```json
{"agent_id": "ad3814d978427e657", "agent_type": "",
 "agent_transcript_path": "", "session_id": "sess-fixture-1",
 "hook_event_name": "SubagentStop"}
```
`launch-car.json`:
```json
{"session_id": "sess-fixture-1", "hook_event_name": "PostToolUse", "tool_name": "Task",
 "tool_input": {"description": "fixture car", "model": "sonnet", "prompt": "x",
                "subagent_type": "car"},
 "tool_response": {"agentId": "a88e7dadda60940ac", "status": "async_launched",
                   "resolvedModel": "claude-sonnet-5", "isAsync": true}}
```
`transcript-car.jsonl`: a minimal agent transcript whose LAST assistant message contains
a real envelope block - built from the fence in
`docs/reviews/2026-07-22-car1-review-round2.md` (verified: exactly one
`starcar-artifact` fence). The fixture transcript's shape follows the measured real one:
JSONL lines with `message.role`/`message.content[].type=='text'`.

---

## Car 2 - Tasks B.1-B.6

### Task B.1 - envelope extraction, FROM THE TRANSCRIPT [C2R1-M3 folded]

**Files:** Create `scripts/Envelope.psm1`; Create `scripts/tests/Envelope.Tests.ps1`;
Create `scripts/tests/fixtures/payloads/` (the four fixtures above).

**The round-1 Major and its fold:** rev 1 extracted from `last_assistant_message`, a
payload field the spec never blessed and the reviewer could not verify. Rev 2 uses the
SPEC'S mechanism (§2.3, design A1): **`agent_transcript_path`**. The extraction was
probed at base (conditions: python parse of a real logged agent transcript, live
session): last assistant text from the TRANSCRIPT == the payload field's value -
`'ok' == 'ok'`, `True`. The transcript is authoritative; the payload field is unused.

**Produces (B.2 consumes blind):**
- `Get-LastAssistantText -TranscriptPath <path>` - last `message.role == 'assistant'`
  line's joined `content[].text` parts; `$null` + one Errors entry if the file is
  absent/unparseable.
- `Get-StarcarEnvelope -Text <string>` returning `[pscustomobject]@{ Found; Outcome;
  Findings; Abstract; Fault }`, `Fault` in `$null | 'absent' | 'malformed'` (spec §2.3:
  different faults, both land with body intact). LAST fenced `starcar-artifact` block
  wins (repeat-envelope precedent, `Land-Verdict.ps1:112-115`, structural at base).
  Fields: `outcome`, `findings`, `abstract` - all three.

- [ ] **Step 1 - failing tests:** present-and-valid (multi-line abstract verbatim);
  absent; malformed; last-fence-wins; transcript extraction (fixture transcript →
  envelope found end-to-end); absent transcript file → `$null` + one error.
- [ ] **Step 2 - red REASON (RUN at base; pwsh 7.6.3, rendered message):** *"The
  specified module './scripts/Envelope.psm1' was not loaded because no valid module
  file was found in any module directory."*
- [ ] **Step 3 - implement** (`Board.psm1` pattern).
- [ ] **Step 4 - green + suites** (expected 43+~6; observed is the car's).
- [ ] **Step 5 - commit:** `feat(harness): envelope from transcript - outcome, findings, abstract; absent vs malformed (#7)`

**Ledger both parts:** none / none.

### Task B.2 - the producer [C2R1-M2, M4, m1 folded]

**Files:** Create `scripts/Produce-Artifact.ps1`; Create
`scripts/tests/Producer.Tests.ps1`; Create `.claude/hooks/starcar-producer-stop.sh`
and `.claude/hooks/starcar-producer-launch.sh`; Modify `.claude/settings.json` (append
to the existing arrays - two hooks per event is the landed pattern, round-1 verified).

**Produces:** `Produce-Artifact.ps1 -Kind <dispatched|returned>` reading the hook
payload from stdin.

1. Filter: `agent_type` non-empty for STOP payloads; for LAUNCH payloads
   `tool_input.subagent_type` non-empty (same rule, the launch payload's name for it -
   measured above). Filtered = exit 0, no write.
2. Record per the schema in canonical order (`index-format.md:17-20`):
   `subject` = `tool_response.agentId` (launch) / `agent_id` (stop) - **the same value,
   measured** [C2R1-M4]; **`session_id` = the payload's `session_id`** (present in both
   payloads, measured) [C2R1-m1]; `at` = UTC now; `returned` only: outcome/findings/
   abstract/envelope via B.1 against the TRANSCRIPT at `agent_transcript_path` (absent
   envelope = `outcome: error`, `envelope: absent`); optional producer extras under the
   schema's OPEN posture: `model` = `tool_response.resolvedModel` on `dispatched`
   (producer-optional metadata, same Law-7 class as `producer`; the board's model-mix
   rendering wants it and the open `additionalProperties` posture permits it without a
   schema bump); `producer` = `starcar-hook/1`; `cost` omitted at v1 (#11's decision);
   `normalisation` per `index-format.md:60-72` before hashing; `integrity` = sha256
   over the canonical body.
3. Write `artifacts/<subject>/<kind>-<compact-at>.json` (R4); then `git add <path>` +
   **`git commit --only -- <path>`** [C2R1-M2 - round 1 REPRODUCED the entanglement:
   `git add` + BARE `git commit` serializes the whole index, sweeping the conductor's
   co-staged files into harness commits; `--only` scopes the commit to the pathspec
   regardless of index state]. Retry x3 on contention; never `-a`, never push.
4. Failure: nonzero exit + one `_faults.log` line (Law 4).

- [ ] **Step 1 - failing tests** (fixture payloads piped to the script, store rooted in
  `$TestDrive`, git fixture repo initialised in `$TestDrive` for commit tests):
  filtered payloads write nothing; real stop payload → record at R4 path validating
  via `Test-StarcarArtifact` with envelope fields populated from the fixture
  transcript; launch payload → `dispatched` record, `subject` == the stop record's,
  `model` present; envelope-absent transcript → `outcome: error`/`envelope: absent`;
  integrity round-trips; normalisation declared; **the entanglement red [C2R1-M2]: a
  FOREIGN file staged in the fixture repo before the producer runs is NOT in the
  producer's commit** (assert the commit's file list == exactly the record path).
- [ ] **Step 2 - red REASON (RUN at base; pwsh 7.6.3, exception type):**
  `CommandNotFoundException` - the script does not exist.
- [ ] **Steps 3-5**; commit:
  `feat(harness): producer - filtered, pathspec-scoped commits, measured identity (#7)`

**Ledger both parts:** process none; derived none (records are primary).

### Task B.3 - the detector and the fold [C2R1-M5/M6 folds applied]

**Files:** Create `scripts/Detect-Dispatches.ps1`; Create
`scripts/tests/Detector.Tests.ps1`; Create `config/harness-defaults.json` (R5v2).

**Produces:** `Detect-Dispatches.ps1 -StoreRoot <path> [-Now <iso>] [-DefaultsPath
<path>]` emitting the fold as JSON to stdout. Rules (citations unchanged from rev 1):
precedence `returned` > `presumed-lost` > `dispatched` (§3.1); within-kind latest-`at`
with `superseded` EXPOSED (§3.1); later `intent` supersedes (§3.1, Law 2); budget
gradient - record's `budget` else R5v2 default - `overdue` with elapsed AND budget
before `unaccounted-for` (§3.3; per probe 1 the only kill-surfacing path); spend from
`cost` only, absent = `spend: absent` (§3.4); gaps stay visible statelessly (§3.5);
unrecognised vocab by NAME via A.2's `Discoveries`, unreadable vocab or defaults file
= ONE fault (§3.2, R5v2); **`tier: "tier-1-only"` reported truthfully - no tier-2
enumeration in this car (R6v2)**.

- [ ] **Step 1 - failing tests** (fixture stores, `-Now` injected): the §6
  cell-per-sentence set from rev 1, minus tier-2 cells, plus: fold reports
  `tier-1-only`; defaults file unreadable = one fault; record-level `budget` overrides
  the default.
- [ ] **Step 2 - red REASON (RUN at base; pwsh 7.6.3, exception type):**
  `CommandNotFoundException`.
- [ ] **Steps 3-5**; commit:
  `feat(harness): detector - precedence, supersession, gradient, tier exposure (#7)`

**Ledger both parts:** none / none (stateless; §5.1's tripwire stands).

### Task B.4 - non-vacuity + retirements, COHERENT [C2R1-M7 folded]

**Files:** Modify `scripts/Land-Verdict.ps1`; rider tests.

**The round-1 Major and its fold:** rev 1 deleted BOTH `Get-LiveTranscriptPath` (`:59`,
path derivation) and `Get-ResultBlockForTask` (`:78-115`, extraction) while demanding
byte-identical backfill - impossible with the extractor gone. Rev 2 splits them by
what they ARE: the retirement targets the SCRAPING (deriving the parent transcript's
path from a hardcoded project dir - `:59` and the derivation call-path), which the
producer replaces via the hook payload. **The EXTRACTION function stays** - backfill
(spec [m3]) happens precisely when no hook fired, the operator hands the CLI an
explicit `-TranscriptPath`, and `Get-ResultBlockForTask` consumes those lines
unchanged. Spec §4 row 2's "replaced by `agent_transcript_path` from the hook payload"
is the PRODUCER path; row 3's [m3] is this CLI path - two rows, two mechanisms, now
mapped to code that can satisfy both.

1. `-TranscriptPath` becomes mandatory; `Get-LiveTranscriptPath` and the `:59`
   hardcoded path are DELETED; `Get-ResultBlockForTask` retained.
   **[C2R2-m1 folded - MARKED deviation from spec §4 row 1:** the row prescribes
   "derivation from the git root" as the replacement; this plan DELETES the deriver
   instead, because the live path now arrives via the producer's hook payload and an
   auto-deriver would be dead code the moment B.2 lands. The retirement target (the
   hardcoded path) is retired either way; the replacement mechanism supersedes the
   row's rev-1-era prescription, named here the same way B.6 marks the setup.md:23
   deviation.]
   Red-first: CLI without `-TranscriptPath` fails with the named mandatory-parameter
   error; with a fixture transcript, output byte-identical to current behaviour
   (achievable now - the extractor exists); `Verify-Verdict.ps1` bare stays exit 0
   all verified.
2. `agent_type` flood fault-injection (spec §6 M5): filter removed → replay ALL
   fixture payloads (and any probe-log payloads available in the conductor-supplied
   environment - counts disclosed, smallness stated) → every payload writes; restored
   byte-identical → only non-empty types write. Both counts over the same window.
- [ ] **Steps 2-5** standard; commit:
  `refactor(harness): Land-Verdict backfill-only - derivation retired, extractor retained (#7)`

**Ledger both parts:** none / none.

### Task B.5 - the envelope mandate lands in the WORKER-FACING documents [C2R1-M1 folded]

**Files:** Modify `CLAUDE.md` (Dispatch rules: every brief mandates the report
envelope - fenced `starcar-artifact`, fields outcome/findings/abstract, no angle
brackets); Modify `docs/templates/car-brief.md` (the envelope block becomes part of
the template's mandatory ending); Modify `.claude/agents/car.md` (envelope duty in the
agent definition); Modify `.claude/skills/goodnight/SKILL.md` (session-end sweep: check
`artifacts/_faults.log` and un-landed dispatch records before closing).

**Why this is its own task:** round 1 found these four spec-§9-assigned files dropped
into a blanket phrase in every rev-1 file list - and they are load-bearing: the
envelope is how a `returned` record GETS an outcome (§2.3 names the car-brief work as
*"real and outstanding"*). Without the mandate, real dispatches emit no envelope and
every record lands `envelope: absent`. Documentation ranks equal to code; these are
the CARRIERS that make B.1 parse something.

- [ ] **Step 1-2 - red:** `DocPolicy.Tests.ps1` covers `docs/`; `CLAUDE.md` and
  `.claude/` files are OUTSIDE the gate's walk (structural: the test walks `docs/`
  recursively) - so the red here is the REVIEWER's sentence check, not a suite, and
  that boundary is stated rather than faked [honest per round 1's dimension-(d)
  standard: no escape hatch, a named attention-tier gap].
- [ ] **Steps 3-5**; commit:
  `docs(harness): envelope mandate - CLAUDE.md, car-brief, car agent, goodnight sweep (#7)`

**Ledger both parts:** none / none (doc-only).

### Task B.6 - contracts, gating evidence, setup truth [rev 1's B.5, rescoped]

**Files:** Modify `docs/contracts/state-ledger.md` (append-only writer: none →
producer hook; process state 0 → 0, both questions); Modify
`docs/contracts/gating-matrix.md` (tier-1 row gets its REAL test names from B.3;
tier-2 row's evidence becomes "deferred - R6v2, trigger in setup.md" - truthful, not
pending-forever); Modify `docs/setup.md:23` **[C2R1-m2 folded: this line is spec-§9
Car 3's, taken here as an EXPLICIT deviation]** - the same-commit living-documents
rule forces it: B.4's commit invalidates line 23's "expected to change / currently in
adversarial review" note, so the truth-up cannot wait for Car 3; row 5's OTHER mirrors
(README, friction-log) remain Car 3's migration commit, undisturbed. Also
`docs/setup.md`: the R6v2 tier-2 trigger row.

- [ ] **Steps 1-5** standard (DocPolicy is the gate for the `docs/` files; state n/a
  for fault-injection if no new doc file is created - the two contract files exist);
  commit: `docs(harness): contracts to producer reality; tier-2 deferral recorded (#7)`

**Ledger:** IS this task; arithmetic inline.

---

## §Handback - conductor-only verification after merge

1. **Live fire:** one trivial dispatch → `dispatched` + `returned` records in
   `artifacts/`, both passing `Test-StarcarArtifact`, subjects EQUAL (the measured
   identity, confirmed live), envelope-extracted outcome present.
2. **Latency:** live dispatch duration vs 2,816/1,648ms baselines (combined-hook
   reality, m4).
3. **Entanglement in the real repo:** stage a scratch file, trigger a dispatch,
   confirm the harness commit contains ONLY the record (M2's fix proven where it
   matters).
4. **Gating-matrix flips** for any evidence gone live.

## Spec-coverage table (subsection-granular)

| Spec subsection | Disposition |
|---|---|
| §2.1 producer hooks | B.2 (launch identity MEASURED - payload contract section) |
| §2.2 `agent_type` only | B.2 filter + B.4 non-vacuity |
| §2.3 envelope, faults, outcome source | B.1 (transcript mechanism - spec's own) + B.2; **mandate docs: B.5 [C2R1-M1]** |
| §2.4 concurrent writes, raise-never-drop | B.2 (`--only` pathspec commit [C2R1-M2]; `_faults.log`) |
| §2.5 tiers | B.3 tier-1 + exposure; tier-2 enumeration DEFERRED (R6v2, trigger in setup.md); CI fetch [m5] = Car 3 |
| §3.1 precedence, supersession, intent | B.3 |
| §3.2 vocabularies, one-fault reads | B.3 (consumes A.1/A.2; defaults file same rule) |
| §3.3 budget, gradient, basis, default | B.3 + R5v2 (`config/`, not `schema/`); `basis` human-authored per design §2b (round-1 ruled faithful; the no-authoring-tool gap is the spec's, noted for the owner) |
| §3.4 spend from cost only | B.3; producer omits cost v1 (#11) |
| §3.5 un-backfilled gap | B.3 |
| §3.6 normalisation, integrity | B.2 writes; format A.1's |
| §4 rows 1-3 | B.4 (derivation retired, extractor retained [C2R1-M7]) |
| §4 rows 4-5 | Car 3 |
| §5.1 no process state | every ledger line |
| §5.2 index CI gate | Car 3 |
| §6 cells / flood | B.3 / B.4 |
| §9: CLAUDE.md + car-brief + car.md + goodnight (envelope mandate) | **B.5** [C2R1-M1] |
| §9: producer/detector/config docs | B.6 |
| §9: migration-commit docs | Car 3 (setup.md:23 taken early as a MARKED deviation [C2R1-m2]) |

## Totals

6 tasks, one car (Opus). Trajectory: 43 → ~49 → ~57 → ~65 → ~68 → ~68 → ~68 (expected;
car reports observed). Probes 8/8. Verify-Verdict: exit 0, all verified, count floats.

## Round-1 finding disposition [the carrier the DRILL reviewer walks]

| ID | Finding (compressed) | Disposition in rev 2 |
|---|---|---|
| C2R1-M1 | Envelope-mandate docs dropped from every file list | Folded: new Task B.5 - all four files named, edits described, load-bearing rationale stated |
| C2R1-M2 | Bare `git commit` sweeps conductor-staged files (reproduced) | Folded: `git commit --only -- <path>` in B.2 step 3 + the entanglement red (foreign staged file excluded, commit file-list asserted) + Handback check 3 |
| C2R1-M3 | `last_assistant_message` un-blessed and unverifiable | Folded: extraction from `agent_transcript_path` (the spec's mechanism); transcript-parse probed at base (`'ok'=='ok'`, True); payload field unused; fixtures travel inline in this plan |
| C2R1-M4 | `dispatched` identity unverified | Folded: PROBED - launch payload measured, `tool_response.agentId` == stop `agent_id` for the same dispatch; payload contract section quotes the observed keys |
| C2R1-M5 | R5 put shop config in the portable contract | Folded: R5v2 - `config/harness-defaults.json`; R5 recorded as REJECTED |
| C2R1-M6 | R6 tier-2 enumerated checkpoints, not dispatches | Folded: R6v2 - tier-1 + exposure ships; enumeration deferred with measured rationale and a setup.md trigger |
| C2R1-M7 | B.4 deleted the extractor its own pin needs | Folded: derivation retired, `Get-ResultBlockForTask` RETAINED; spec rows 2/3 mapped to producer path vs CLI path |
| C2R1-m1 | `session_id` source unstated | Folded: payload `session_id`, measured present in both payloads |
| C2R1-m2 | setup.md:23 taken from Car 3 silently | Folded: explicit MARKED deviation in B.6 with the same-commit rule as the reason |
| C2R1-m3 | Fixtures depend on a gitignored log | Folded: sanitized fixtures inline in this plan; car builds files from them |
| C2R1-m4 | Combined two-hook latency unmodelled | Folded: stated in Global constraints; baselines already include the probe hook; Handback measures combined reality |
| C2R2-M1 | Load-bearing launch measurement gitignored-log-only | Folded: Probe 5 landed in the probe-results doc (keys, the identity equality, conditions, the spec-cell revision named); the committed hook regenerates the evidence in one dispatch |
| C2R2-m1 | Spec §4 row 1 superseded silently | Folded: MARKED deviation in B.4 with the reason (deriver is dead code once the payload path exists) |

## The plan-review record (rule 5)

Round 1: **REJECT - 7 Major, 4 Minor**
(`docs/reviews/2026-07-22-car2-plan-review-round1.md`); R4 SOUND, R5 REJECTED, R6
split. Round 2 is the delta - **and the ROTATION DRILL: a FRESH reviewer, receiving
ONLY the landed round-1 verdict and this revision as carriers.** Agreement with what
same-agent continuation would find proves the verdict template carries everything;
divergence is a template finding (CLAUDE.md Review calibration; trigger row in
setup.md fires here).

Plan-writer probe evidence for rev 2 (all at base, conditions stated): launch-payload
probe (live session, PostToolUse:Task hook, logged - keys quoted in the payload
contract section); identity correlation (launch `agentId` == stop `agent_id`, same
dispatch, both logs); transcript extraction (python parse of a real agent transcript ==
payload field, `True`); reds B.1/B.2/B.3 re-stated from the round-1-verified runs
(pwsh 7.6.3, layers named - the reviewer re-verified all three MATCH). The drill
reviewer re-verifies rather than trusting this note.
