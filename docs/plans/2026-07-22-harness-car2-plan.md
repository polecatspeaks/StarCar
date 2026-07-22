Status: Current

# Dispatch harness - Car 2 implementation plan, rev 1 (envelope, producer, detector, retirements)

REQUIRED SUB-SKILL: one car per task group, adversarial reviewer per car.

Source of truth: `docs/specs/2026-07-22-dispatch-harness-spec.md` APPROVED + S1. Design
rev 6 + A1. Substrate header: `docs/probes/2026-07-22-spec7-probe-results.md` - **all
four §7 probes ANSWERED**; two are binding on this plan (probe 1: kills are invisible to
hooks, so the detector is the only accounting for them; probe 2: a slow SubagentStop
hook blocks the stop path for its FULL runtime - 11,609ms observed with a 10s sleep vs
2,816/1,648ms baselines).

**Scope: Car 2 only, on OPUS** (owner-ratified hybrid topology: this is the generative
car - envelope parsing, producer, detector - the competency class the Car 1 probe showed
Sonnet weak on). Car 3 (store migration, CI gates, on Sonnet) is planned after Car 2
lands, because its migration targets the store THIS car creates.

Compliance: `worked-plan.md` Amendment 1 INCLUDING the conditions rule - every stated
red below was RUN by the plan-writer at base with its conditions quoted; structural
claims opened at base. Car 1's three disclosed findings all traced to condition-free
quotes; every quote here carries shell and layer.

> # BINDING AMENDMENT BLOCK (conductor-applied)
> *Empty at rev 1. The car reads this block FIRST; entries supersede contradicting task
> text.*

## Base, baselines, and the STOP rule

Base: **the commit that lands this plan approved** (`git log -1 --format=%H -- <this
file>` reachable from worktree HEAD; the file text matches the committed version).
Baselines, re-derived by the car under pwsh 7, STOP on mismatch:

- `Invoke-Pester -Path ./scripts/tests`: **43 passing, 0 failed**
- `Invoke-Pester -Path ./scripts/probes`: **8 passing, 0 failed** (substrate floor)
- `./scripts/Verify-Verdict.ps1` bare: **exit 0, every file verified** - the COUNT
  FLOATS by design (16 at plan-writing; the store grows by the verdicts that approve
  this plan - the self-referential-baseline class, named at Car 1). The car pins
  "all verified, exit 0", never a number.

## Global constraints

Red-first per step; ledger both questions per task; docs same-commit; honest-stop is a
SUCCESS; car commits locally per task, never pushes. Runtime floor unchanged: new files
`#requires -Version 7.4`, suites under pwsh (state the shell in every count).

**Probe-2 latency constraint (BINDING):** the producer hook's synchronous work is ONE
record write plus ONE `git add <own path> && git commit` with a capped retry (3
attempts, no pull, no push). Anything slower rides the stop path of every dispatch
(measured: the full hook runtime lands on the return). A failed write or exhausted
retry is RAISED (nonzero exit + a line appended to `artifacts/_faults.log`), never
dropped (spec §2.4, Law 4). **Residual, stated:** whether a FAILING hook harms the
dispatch itself is unmeasured (probe 2 measured slow, not failing); the design leans
only on "raised loudly", not on any assumption about dispatch survival.

### Conductor rulings (recorded, reviewable)

**R4 - the store's location and layout.** The spec references "the new store" and
`schema/index-format.md:47-48` fixes only that `file` is relative to "the store root"
with `<subject>/...` shaped paths. Unnamed remainder ruled: **store root is
`artifacts/` at the repo root**; each record is
`artifacts/<subject>/<kind>-<compact-at>.json` where `<compact-at>` is
`yyyyMMddTHHmmssZ`. Filenames are EVENT-unique, not kind-unique, because repeat
`returned` events per subject are REAL and common - measured this session: one
reviewer's task-id stopped three times (initial + two delta-re-review resumes), each a
distinct `returned` event under §5.1's one-record-per-EVENT grain. The index records
actual paths, so `index-format.md`'s illustrative `dispatched.json` filenames stay
non-normative (its normative content is columns, sort, and root-relativity).

**R5 - the shop budget default lives in `schema/defaults.json`.** Spec §3.3 requires a
shop-level default so absent never means infinite, and names no home. Ruled:
`schema/defaults.json` with `dispatch_budget_seconds` (initial: 1800 - generous; the
gradient makes a mis-set budget degrade visibly, spec §3.3). Data file, same Law-7
posture as the vocabularies; an unreadable defaults file is ONE fault (§3.2's rule
generalises).

**R6 - tier 2 enumerates `entire checkpoints list`.** Verified at base (conditions:
Git Bash, entire CLI present): `entire checkpoints list` exists and emits checkpoint
id + prompt + commit lines. The detector treats tier 2 as OPTIONAL AT RUNTIME: entire
absent or the command failing = the fold reports "tier 1 only" loudly (the fold exposes
which tier is in force, spec §2.5) - never a crash, never silence. CI reachability of
the checkpoint branch is Car 3's fetch ([m5]).

---

## Car 2 - Tasks B.1-B.5 (one car, sequential)

### Task B.1 - envelope extraction

**Files:** Create `scripts/Envelope.psm1`; Create `scripts/tests/Envelope.Tests.ps1`;
Create `scripts/tests/fixtures/envelope/` (fixture texts).

**Produces (B.2 consumes blind):**
`Get-StarcarEnvelope -Text <string>` returning
`[pscustomobject]@{ Found=[bool]; Outcome; Findings; Abstract; Fault }` where `Fault`
is `$null`, `'absent'`, or `'malformed'` (spec §2.3: *"Absent and malformed are
different faults"* - no fenced `starcar-artifact` block = `absent`; block present but
fields unparseable = `malformed`; both leave the body intact for landing). Parses the
LAST fenced block with info string `starcar-artifact` (an agent may quote an earlier
envelope; last wins, same rule as `Land-Verdict.ps1:112-115`'s repeat-notification
precedent - structural, opened at base). Fields: `outcome`, `findings`, `abstract`
(spec §2.3 - all three, the field Car 1's round 2 taught us not to drop).

**Fixtures are REAL, not invented:** the fenced envelope blocks in
`docs/reviews/2026-07-22-car1-review-round2.md` (verified at base: exactly 1
`starcar-artifact` fence) and siblings - plus synthetic absent/malformed cases. The
payload field this consumes is `last_assistant_message`, verified at base to carry the
agent's final text (probe log, real `SubagentStop` payload: the control agent's field
held exactly its final output).

- [ ] **Step 1 - failing tests:** present-and-valid (fields extracted verbatim incl.
  multi-line `abstract`), absent (`Fault='absent'`, `Found=$false`), malformed
  (`Fault='malformed'`), last-fence-wins (fixture with two fences).
- [ ] **Step 2 - red REASON (RUN at base; conditions: pwsh 7.6.3, rendered exception
  message):** *"The specified module './scripts/Envelope.psm1' was not loaded because
  no valid module file was found in any module directory."*
- [ ] **Step 3 - implement.** Pattern per `Board.psm1`: pure functions,
  `Export-ModuleMember` at end.
- [ ] **Step 4 - green + suites:** expected 43 + ~4; car reports observed. Verify-Verdict
  bare: exit 0, all verified.
- [ ] **Step 5 - commit:** `feat(harness): envelope extraction - outcome, findings, abstract; absent vs malformed (#7)`

**Ledger both parts:** none / none - state both.

### Task B.2 - the producer

**Files:** Create `scripts/Produce-Artifact.ps1`; Create
`scripts/tests/Producer.Tests.ps1`; Create `scripts/tests/fixtures/payloads/` (real
payload JSON from `.claude/probe-logs/subagent-stop.jsonl`, ids truncated); Create
`.claude/hooks/starcar-producer-stop.sh` (SubagentStop) and
`.claude/hooks/starcar-producer-launch.sh` (PostToolUse matcher Task); Modify
`.claude/settings.json` (wire both, KEEPING the existing probe-log hook - two commands
on one event is supported, verified structurally: settings already carries arrays).

**Produces:** `Produce-Artifact.ps1 -Kind <dispatched|returned>` reading the hook
payload from stdin. Behaviour:

1. **Filter: `agent_type` non-empty, unconditionally and alone** (spec §2.2 ruling 2).
   Empty = exit 0, no write. (Verified against real payloads: internal subagents carry
   `agent_type: ''` - probe results doc, probe 4's second observation.)
2. Build the record per `schema/starcar-artifact.schema.json` in
   `index-format.md:17-20`'s canonical field order: `subject` = `agent_id` (R2: one
   identity key), `at` = UTC now from the payload receipt, `outcome`/`findings`/
   `abstract`/`envelope` from B.1 against `last_assistant_message` (returned only;
   absent envelope = `outcome: error`, `envelope: absent` - a BRIEF failure, spec
   §2.3), `cost`/`context_peak_tokens` omitted at v1 (producer-optional by Law 7;
   the transcript-parse for counters is #11's trigger decision, not smuggled in here),
   `producer` = `starcar-hook/1`, `normalisation` = applied substitutions per
   `index-format.md:60-72` (repo root, home dir, longest-first, BEFORE hashing),
   `integrity` = sha256 over the canonical body.
3. Write `artifacts/<subject>/<kind>-<compact-at>.json` (R4) - own path ONLY; then
   `git add <path>` + `git commit` (message `harness: <kind> <subject>`), retry x3 on
   contention, NEVER `-a`, never push (spec §2.4).
4. Any failure: nonzero exit + one line to `artifacts/_faults.log` (Law 4: raised,
   never dropped).

The hooks are two-line sh wrappers invoking `pwsh -NoProfile -File
scripts/Produce-Artifact.ps1 -Kind <kind>` - all logic lives in the testable ps1, the
wrapper stays under probe-2's latency constraint (pwsh startup + one write + one
commit).

- [ ] **Step 1 - failing tests** (fixture payloads piped to the script under test, store
  rooted at `$TestDrive`): empty-`agent_type` payload → no file written, exit 0; real
  car payload → record written at the R4 path, **validates via
  `Test-StarcarArtifact`** (A.2 consumed - the conformance loop closes), envelope
  fields populated; envelope-absent payload → `outcome: error`, `envelope: absent`;
  written file round-trips its own `integrity` hash; `normalisation` declared (repo
  root substituted in the transcript path).
- [ ] **Step 2 - red REASON (RUN at base; conditions: pwsh 7.6.3, exception type
  name):** `CommandNotFoundException` - the script does not exist.
- [ ] **Step 3 - implement.**
- [ ] **Step 4 - green + suites** (expected 43+~4+~6; observed is the car's), and a LIVE
  smoke: the car may NOT dispatch agents (toolset), so the live-fire test of the wired
  hook is the CONDUCTOR's post-merge step, stated in §Handback below - the car's
  evidence is fixture-driven, and that boundary is stated here so the car does not
  claim live verification it cannot perform (Law 1).
- [ ] **Step 5 - commit:** `feat(harness): producer - agent_type filter, R4 store writes, capped-retry commit (#7)`

**Ledger both parts:** process state none (script is stateless; the store is the
record). Derived committed artifacts: none new (records are AUTHORED-by-hook primary
records, not derived; the derived index still has its A.5 row, gate lands Car 3).

### Task B.3 - the detector and the fold

**Files:** Create `scripts/Detect-Dispatches.ps1`; Create
`scripts/tests/Detector.Tests.ps1`; Create `schema/defaults.json` (R5).

**Produces:** `Detect-Dispatches.ps1 -StoreRoot <path> [-Now <iso>]` emitting the fold
as JSON to stdout (one object per subject + a board-level faults array). `-Now`
injectable for tests (no wall-clock in assertions). Fold rules, each a spec citation:

- Precedence per subject: `returned` > `presumed-lost` > `dispatched` (§3.1).
- Within a kind: latest-`at` wins; superseded events listed under a
  `superseded` marker - EXPOSED, not rendered (§3.1, ruling 3).
- A later `intent` supersedes an earlier one for its subject (§3.1, Law 2).
- `dispatched` with no successor: if elapsed vs `budget` (record's own, else R5
  default) exceeds budget → `overdue` with **elapsed and budget** stated; only beyond
  that does it fold as `unaccounted-for` (§3.3 gradient - and per probe 1 this is the
  ONLY path that surfaces kills).
- Spend: reported from `cost` only; absent = `spend: absent` (never borrowed from
  context) (§3.4).
- Un-backfilled gaps: a subject once `unaccounted-for` stays visible until a record
  closes it (§3.5) - the fold is stateless, so "stays" means derived-anew-each-run
  from the same store facts, not remembered.
- Vocabulary: unrecognised `kind`/`outcome` reported by NAME as a discovery (A.2's
  `Discoveries` consumed); unreadable vocab or defaults file = ONE board-level fault
  (§3.2, R5).
- Tier: tier 1 always (store-only); tier 2 = `entire checkpoints list` enumeration
  when available (R6), fold exposes `tier` in force; enumerated-but-storeless
  checkpoints raise a tier-2 gap line. Never a crash when entire is absent.

- [ ] **Step 1 - failing tests** (fixture stores in `$TestDrive`, `-Now` injected):
  one cell per spec §6 sentence - two records one subject folds `returned`; two
  `returned` fold latest with supersession marker exposed; `dispatched` past budget =
  overdue with elapsed+budget before unaccounted-for; later `intent` supersedes; no
  `agent_type` filtering here (producer's job - detector reads what exists); spend
  absent reported absent; unrecognised kind by name; unreadable vocab ONE fault.
- [ ] **Step 2 - red REASON (RUN at base; conditions: pwsh 7.6.3, exception type
  name):** `CommandNotFoundException` - script absent (same class as B.2's, observed
  in the same probe batch).
- [ ] **Step 3 - implement.**
- [ ] **Step 4 - green + suites** (expected +~8).
- [ ] **Step 5 - commit:** `feat(harness): detector - precedence, supersession, budget gradient, tiers (#7)`

**Ledger both parts:** none / none (stateless by §5.1 - if the car finds itself adding
a field that outlives a process, that is the spec's own honest-stop tripwire).

### Task B.4 - non-vacuity + retirements (rows 1-3)

**Files:** Modify `scripts/Land-Verdict.ps1`; Modify `scripts/tests/` (rider tests);
fault-injection evidence in the car report.

1. **Fault-inject the `agent_type` filter** (spec §6, M5): with the filter removed
   locally, replay ALL payloads in the probe log through the producer → every payload
   writes (store floods); restore byte-identical, replay again → only non-empty
   `agent_type` payloads write. Both counts stated over the same window. (The probe
   log at plan-writing holds 5 firings, 1 internal - small but real; the car states
   observed counts, and smallness is disclosed, not padded.)
2. **Retire rows 1-3** (§4, anchors re-verified at base 2026-07-22): the hardcoded
   project path (`Land-Verdict.ps1:59`, sole caller `Get-LiveTranscriptPath`) and
   parent-transcript scraping (`:78-115`, called once) are DELETED; the CLI survives
   BACKFILL-ONLY with a new mandatory `-TranscriptPath` argument ([m3] - backfill
   happens precisely when no hook fired, so there is no payload path to derive from).
   Red-first: a test invoking the modified CLI without `-TranscriptPath` fails with a
   named mandatory-parameter error; with it, a fixture transcript lands a verdict
   byte-identically to the current behaviour (regression pin on the 16 landed
   verdicts: `Verify-Verdict.ps1` bare stays exit 0, all verified).
- [ ] **Steps 2-5** per the standard shape; commit:
  `refactor(harness): Land-Verdict to backfill-only CLI - scraping and hardcoded path retired (#7)`

**Ledger both parts:** none / none.

### Task B.5 - contracts, gating evidence, docs rows

**Files:** Modify `docs/contracts/state-ledger.md` (the store's append-only row gains
the producer as its writer; process state still nil - both questions re-answered);
Modify `docs/contracts/gating-matrix.md` (tier-1 and tier-2 rows get their REAL test
names from B.3, replacing "pending - lands Car 2"); Modify `docs/setup.md:23-24` (the
Land-Verdict row's "expected to change" note resolves to the backfill-only reality -
§4 row 5's OTHER mirrors, README and friction-log, are Car 3's migration commit, not
this one); spec §9 rows owned by Car 2.

- [ ] **Step 1-2 - the red is `DocPolicy.Tests.ps1`** if any new doc lacks `Status:`
  (existing gate; Car 1 proved the mechanism - fault-inject only if a NEW doc file is
  created, else state n/a).
- [ ] **Steps 3-5**; commit:
  `docs(harness): contracts updated to producer reality; gating evidence named (#7)`

**Ledger:** the ledger IS this task's file; arithmetic inline (append-only writer:
none → producer hook; process state 0 → 0).

---

## §Handback - what the CAR cannot verify, named for the conductor

The car cannot dispatch agents (toolset) and cannot restart the session, so THREE
things return to the conductor with the merge (Law 1 - the car must not claim them):

1. **Live fire:** after merge + settings reload, one trivial dispatch → a `dispatched`
   and `returned` record appear in `artifacts/` with a valid envelope-extracted
   outcome; `Test-StarcarArtifact` passes on both.
2. **Latency:** the live dispatch's duration vs the 2,816/1,648ms baselines (probe-2
   constraint honoured in practice, not just design).
3. **The A.5 gating row flip** for any gate whose evidence went live.

## Spec-coverage table (subsection-granular; Car 2's share)

| Spec subsection | Disposition |
|---|---|
| §2.1 producer hooks | B.2 |
| §2.2 `agent_type` only | B.2 (filter) + B.4 (non-vacuity) |
| §2.3 envelope, absent/malformed, outcome source | B.1 + B.2 |
| §2.4 concurrent writes, raise-never-drop | B.2 |
| §2.5 detector tiers, fold exposes tier | B.3 (R6); CI fetch [m5] = **Car 3** |
| §3.1 precedence, supersession, intent | B.3 |
| §3.2 vocabularies at fold time, one-fault reads | B.3 (consumes A.1/A.2) |
| §3.3 budget, gradient, basis, shop default | B.3 + R5 (`basis` is written by a HUMAN closing a gap with `presumed-lost` - no task writes one; the schema field landed in A.1) |
| §3.4 spend from cost only, absent reported | B.3; producer omits cost at v1 (stated in B.2, #11's decision point) |
| §3.5 un-backfilled gap first-class | B.3 |
| §3.6 normalisation declared, integrity | B.2 (writes) - format owned by A.1 |
| §4 rows 1-3 retirements | B.4 |
| §4 rows 4-5 | **Car 3** (S1-amended row 4 landed at Car 1/A.3; the repoint remains Car 3's) |
| §5.1 no process state | every task's ledger line; B.3's stateless "stays visible" note |
| §5.2 index CI gate | **Car 3** |
| §6 cells | B.3 tests (cell-per-sentence) |
| §6 non-vacuity: flood | B.4 |
| §6 non-vacuity: empty store / stale index | landed at A.3 / **Car 3** |
| §7 probes | ALL ANSWERED - substrate header cited throughout |
| §8 non-goals | fold emits JSON; NOTHING here renders (board is #1) |
| §9 rows: producer/detector/config docs | B.5; migration-commit docs = **Car 3** |

## Totals

5 tasks, one car (Opus). Suite trajectory: 43 → ~47 → ~53 → ~61 → ~65 → ~65 (expected;
the car reports observed per commit). Probes 8/8 unchanged. Verify-Verdict: exit 0, all
verified, count floats.

## The plan-review record (rule 5)

*Pending - plan adversary on the five dimensions (coverage walked independently;
inter-task interfaces; sentence-check with Amendment 1 conditions; red validity BY
RUNNING; ruling review of R4/R5/R6). This is a FRESH gate series: the reviewer-rotation
drill (CLAUDE.md Review calibration) applies from round 2 of this series onward if
rounds occur.*

Plan-writer probe evidence (all at base, conditions stated where quoted): B.1/B.2/B.3
reds run under pwsh 7.6.3; `last_assistant_message` content verified from a real logged
payload; envelope fixture presence verified (`grep -c` = 1 in the round-2 verdict);
`entire checkpoints list` run (Git Bash, CLI present); retirement anchors re-read at
HEAD (`Land-Verdict.ps1:59`, `:39-51`; `ci.yml:47`); probe 2 measured live
(11,609ms/2,816ms/1,648ms, task-notification `duration_ms`). The adversary re-verifies
rather than trusting this note.
