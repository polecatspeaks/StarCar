# Dual-runtime harness design: one harness, two runtimes (Claude Code + Copilot CLI)

Status: Superseded
Stage: RETIRED by owner arbitration 2026-07-24 after 3 REJECT rounds (swirl trigger met). Ruling: the problem was defined from the wrong POV - Claude-as-substrate with Copilot adapted to it. Successor design starts from a fresh, family-agnostic problem statement (Law 7 applied to agent families). Verdicts: rounds 1-3 in artifacts/reviews/.
Issue: #47
Date: 2026-07-24

## §0 - Instrument check

**Behavioural/architectural, with one precision edge.** This design is about which
component owns hook execution under each runtime and how failures surface - prose holds
that. The precision edge is the compat layer's delivered payload shape (key names, field
presence, per hook type): that is a wire contract and lands as **executable probe tests
pinning the shape** (fixtures from real captured payloads in `.claude/probe-logs/`),
never as prose tables a reviewer must trust. This document points at those tests; it
does not restate the shapes.

## §1 - Constraints

| Source | What it forbids here | How this design satisfies it |
|---|---|---|
| Law 6 (`constitution.md`): "never maintains a second copy of anything that can drift" | Two copies of hook logic, one per runtime; two extractors that must agree; two manifests carrying the same wiring | ONE manifest (`.claude/settings.json`) serves both runtimes in the intersection dialect (D1); ONE writer (`Produce-Artifact.ps1`) grows payload tolerance, no parallel producer (D2); ONE extractor home named with both call sites (D5, DR-3 fold) |
| Law 4 (`constitution.md`): "never silently dropped" | A dispatch record lost because a hook failed quietly; an envelope silently absent | Producer keeps raise-never-drop (`artifacts/_faults.log`); the Copilot envelope-timing gap mints `envelope: absent` + a fault line, never nothing (D4); silent-exit filter paths gain a stderr line naming the skip reason (D2) |
| Law 1 (`constitution.md`): truth on every surface | Claiming the harness "works under both" from a read | Every "works" claim below carries its probe evidence (probe-logs line, events.jsonl line, or process-log quote); §2c names what is still unproven |
| Law 7 (`constitution.md`): the stranger; no hardcoded operator paths | Baking `C:\Users\Chris\...` or this box's quirks into manifests or scripts | Scripts derive paths from payload/cwd; the `sh`-on-PATH requirement is a documented box prerequisite in `docs/setup.md`, not a silent assumption |
| Healing Loop: "validated facts must land as tests or gates, never only prose" | Payload shapes and compat behaviour living only in this doc or #47 comments | Probe suite pins the compat-delivered payload shape per hook type + the events.jsonl `tool.execution_complete` shape (D3); reds by name when either runtime moves |
| Probe doctrine (CLAUDE.md, NO HEADERS HERE) | Designing against unobserved hook behaviour | Round 1's DR-1 was exactly this defect; rev 2's substrate section (§3b) quotes only OBSERVED behaviour, each fact with its source artifact |
| Rewrite-vs-extend (CLAUDE.md) | Rewriting the producer because the runtime changed | `Produce-Artifact.ps1` is EXTENDED: filter tolerance + transcript-format branch; manifest lines edited in place; nothing regenerated |
| Right-sizing + NIRTS (CLAUDE.md) | A runtime-abstraction framework for two runtimes | No abstraction layer, no new manifest, no normalizer (rev 1's D2/D3 are DELETED as unnecessary - the compat layer already does both jobs) |
| Producer spec S2.1/S2.3/S2.4 (#7) | Changing record semantics; a second writer | ONE writer preserved; payload intake and transcript-read grow tolerance; spec gets an amendment block, not a rewrite |
| Fail-closed `preToolUse` (probed: Copilot denies the tool call when a preToolUse hook errors) | Wiring anything StarCar to `preToolUse` on either runtime | Nothing in this design touches preToolUse |

## §2 - Premises

| # | Premise | If false |
|---|---|---|
| P1 | Copilot's compat layer keeps loading `.claude/settings.json`, executing commands via PowerShell, translating payloads to Claude snake_case, and mapping the `Task` matcher to its `Agent` tool (all OBSERVED, §3b) | The probe suite reds on the pinned shape; wiring re-examined then. This premise is now load-bearing FOR the design rather than against it - the compat layer IS the port |
| P2 | `sh` resolves from PowerShell on every box that runs either runtime (machine-level PATH fix on this box) | Hooks fail loudly with a known signature ("sh not recognized"); documented prerequisite |
| P3 | Hook config is session-cached on Copilot; every wiring change needs a CLI restart to test | Testing loop speed changes; correctness unaffected |
| P4 | Claude Code executes hook commands via a POSIX shell, so `sh .claude/hooks/x.sh` (relative path, cwd = project dir) behaves as today's `$CLAUDE_PROJECT_DIR`-prefixed form | Intersection dialect breaks Claude-side; BLOCKING VERIFY on the next Claude Code session before the change is trusted (§2c-3) |
| P5 | Background dispatch is the shop's standard mode, so the report-not-flushed-at-stop gap (§3b-6) is the COMMON case under Copilot, not an edge | If sync dispatch returns as standard, the gap shrinks and D4's absent-envelope path becomes rare; design unchanged either way |

## §2c - Probe list (what the desk cannot prove)

| Claim | Why unverifiable from the desk | What would settle it | Blocking? |
|---|---|---|---|
| The intersection-dialect SessionStart lines execute under Copilot compat (the ParserError was the `$CLAUDE_PROJECT_DIR/` prefix, not the scripts) | Hook config is session-cached (P3); needs a restart | Next Copilot restart: `hook.end success=true` for the four guards in events.jsonl, and the guards' stdout visible | Yes - for landing, not for build |
| The intersection-dialect lines still execute under Claude Code (P4) | No Claude Code session available from this desk | First Claude Code session after landing: guards fire, producer records land; until then `docs/setup.md` marks Claude-side "expected-unchanged, unverified" | Yes - for closing #47, not for landing |
| A `postToolUse` matcher exists that catches `read_agent`-class completions (whose `tool_result` would carry the full report + envelope at exactly the moment it exists) | Only the `Task`→`Agent` matcher mapping is observed (44/44 entries are tool_name `Agent`); other Copilot tool names' matcher behaviour unobserved | One session with a wildcard-matcher diagnostic hook appended to the probe logger; read the captured tool_name set | No - settles D4's enrichment trigger (see negative branch there) |
| The stop-side name join (§3b-8: in-flight `toolCallId` → `tool.execution_start.arguments.name`) is unambiguous when two background agents overlap | The join chain is observed on serial dispatches only (3 pairs, this session); overlap never probed | Probe test over a captured events.jsonl fixture with two overlapping background agents; negative branch: subject = `agent_name + at`-derived id, DISCLOSED in the record as `subject_basis: name-time` | Yes - for D4/D7's record identity |

## §3 - The problem

The repo bounces between Claude Code and Copilot CLI (owner, 2026-07-24: "the minimum
amount of work to ensure functionality between the two disparate model and environment
families"). Under Copilot today: the four SessionStart guards never execute (PowerShell
ParserError on the `$CLAUDE_PROJECT_DIR/` prefix), and the producer emits no records -
not because its hooks fail, but because they RUN and then filter themselves out on a
payload-shape mismatch (§3b). Under Claude Code everything works. The fix must not trade
one runtime for the other.

## §3b - The observed substrate (all probed 2026-07-24, sources named)

Rev 1 modeled the compat layer as broken; probes after round 1's DR-1 show it is mostly
working, which deletes half of rev 1's mechanism. Each fact, with its source:

1. **Compat executes `sh script.sh`-form hooks.** `.claude/probe-logs/subagent-stop.jsonl`
   and `post-task.jsonl` carry entries stamped 11:31Z, 11:39Z, 12:11Z on 2026-07-24 -
   all from Copilot session `e07fc822...` while the producer was believed "fully silent".
   Only two command forms fail: bare `$CLAUDE_PROJECT_DIR/...` (ParserError, process
   logs) and `sh -c '...'` one-liners (quote-mangle, events.jsonl hook.end stderr).
2. **Compat translates payloads to Claude snake_case.** The same probe-log entries carry
   `session_id`, `transcript_path`, `agent_name`, `hook_event_name` - Claude shape, from
   a Copilot session. No normalizer is needed; rev 1's D3 is deleted.
3. **The producer's silence is its own filter.** `Produce-Artifact.ps1:141-142` requires
   `agent_type` in the stop payload; the compat stop payload carries `agent_name` instead
   → silent `exit 0` ("internal subagent"). Launch side (`:146-147`) requires
   `tool_input.subagent_type`; the compat launch payload carries `tool_input.agent_type`
   (probe-log, tool_name `Agent`).
4. **The `Task` matcher maps to Copilot's `Agent` tool.** Of 44 post-task probe entries,
   **3 are from this Copilot session** (`session_id e07fc822...`) and all 3 carry
   `tool_name: "Agent"` - the matcher translated, launches captured. The other 41 are
   Claude Code sessions (transcript_path under `.claude\projects\`) and are evidence for
   nothing Copilot-side. [DR-5, folded: rev 2 claimed 44/44 "under Copilot"; the
   population was miscounted, the decision stands on the 3 real observations.]
5. **The stop payload carries no agent id.** Claude's stop payload joined launch→stop by
   agent id (spec Probe 5). The compat stop payload has `agent_name`/`transcript_path`
   only; the id lives in events.jsonl (`subagent.started.agentId` = launch
   `toolCallId` = the empty-transcript `agentStop.sessionId`, re-derived live by the
   round-1 reviewer).
6. **For background dispatches, the report is NOT in the parent transcript at stop
   time.** `subagentStop` fires when the agent idles; the report body (envelope included)
   enters the parent's events.jsonl only when the conductor READS the agent
   (`tool.execution_complete`, observed ~2.8s-to-minutes later). An extraction-at-stop
   returns nothing by construction for background agents. This is the one genuinely new
   mechanism problem, and D4 owns it.
7. **`transcript_path` at stop points at the PARENT's events.jsonl**, not a per-agent
   file (probe-log entries; also the `_probe_transcript_exists_at_fire: false` in every
   Copilot entry is a probe-script key-name miss - it reads `agent_transcript_path` -
   not a missing file; D6 fixes the probe).
8. **The compat launch payload carries NO `tool_response`, NO `agentId`, NO
   `toolCallId`.** [DR-4, folded - probed 2026-07-24 after the round-2 verdict.]
   Verified keyset of a real Copilot post-task entry: `cwd, hook_event_name, session_id,
   timestamp, tool_input, tool_name, tool_result, _probe_logged_at`; `tool_result` holds
   only `result_type` + `text_result_for_llm` prose. So `Produce-Artifact.ps1:148`
   (`tool_response.agentId`) throws "no subject id" (`:151`) even after D2's filter fix -
   the filter fix ALONE does not mint launch records. What IS present: the launch subject
   at **`tool_input.name`** (e.g. `car46-fix-cycle` - the same id `read_agent` uses, and
   the id the `text_result_for_llm` prose confirms: "Agent started in background with
   agent_id: car46-fix-cycle"). And the stop side CAN reach the same name-space:
   events.jsonl `tool.execution_start` maps `toolCallId` ↔ `arguments.name` (probed: 3/3
   dispatches this session), and the in-flight agent at stop time = `subagent.started`
   toolCallIds minus `subagent.completed` toolCallIds (stop fires ~2s before its own
   `completed` event lands). So launch and stop records SHARE a join key -
   `tool_input.name` = `execution_start.arguments.name` - and dispatched↔returned pairing
   survives under Copilot. Overlapping-agents ambiguity is §2c-4's probe.

## §4 - Decisions

| # | Decision | Reason | Constraint/premise |
|---|---|---|---|
| D1 | ONE manifest. Fix the four SessionStart guard lines in `.claude/settings.json` to the intersection dialect (`sh .claude/hooks/x.sh`); add NO Copilot-side manifest for StarCar hooks. Rev 1's `starcar.json` is deleted from the design | §3b-1: the compat layer already runs this form; a second manifest would be the Law 6 second copy AND the double-fire source DR-1 warned about. Double-fire is now structurally impossible: one wiring, one execution path per runtime | Law 6, DR-1, P1 |
| D2 | Extend `Produce-Artifact.ps1`'s filter to accept the compat shape: stop accepts `agent_type` OR `agent_name`; launch accepts `tool_input.subagent_type` OR `tool_input.agent_type`. Every filter `exit 0` gains one stderr line naming what was absent (silent-skip becomes visible-skip) | §3b-3 is the root cause of "producer silence"; the fix is tolerance in ONE writer, not a second path. The stderr line is Law 4 applied to the filter itself - today's three-hour "fully silent" misdiagnosis happened because exit-0 said nothing | Law 4, Law 6, rewrite-vs-extend |
| D3 | Probe suite `scripts/probes/RuntimePayload.Probes.Tests.ps1`: pins the compat-delivered payload key sets per hook type (fixtures = sanitized real captures from `.claude/probe-logs/`), the two failing command forms (so a compat fix is SEEN), and the events.jsonl `tool.execution_complete`/`subagent.started` shapes D4-D5 consume | The runtimes are unversioned substrate; when either moves, a probe reds BY NAME naming the consumer that just became suspect | Healing Loop, probe doctrine |
| D4 | Copilot `returned` records: mint at `subagentStop` with what the payload + events.jsonl hold AT THAT MOMENT. Subject = the events.jsonl id join (§2c-4); envelope = extracted if present, else `envelope: absent` + fault line + stderr notice naming the backfill command. The PROVEN backfill (`Land-Verdict.ps1` + the events.jsonl extractor) is the designed enrichment path for verdict-class dispatches, not a workaround | §3b-6: at stop time the report does not exist in the parent transcript for background dispatches. Minting an honest absent-envelope record preserves Law 4 (the dispatch happened, the record exists); the envelope arrives via the same one extractor when the conductor lands the verdict. NIRTS: verdict-class dispatches already get individually landed; an automatic post-read enrichment hook is NOT needed now - trigger to revisit: §2c-3's wildcard-matcher probe landing positive, or the first envelope-absent record that never got backfilled | Law 4, Law 1, NIRTS |
| D5 | ONE extractor, one home: `Produce-Artifact.ps1`'s transcript reader (`Get-LastAssistantText`) grows an events.jsonl format branch (detect: first line parses as JSON with a `type` field vs Claude JSONL). Call sites: (a) the D4 stop-path, (b) `Land-Verdict.ps1`, which gains a `-TranscriptFormat copilot-events` path calling the SAME function (dot-sourced from a shared module file, `scripts/lib/TranscriptRead.ps1`, extracted by `git mv`-style refactor so history survives). The session-files adapter script is retired on landing | DR-3 fold: rev 1 named two different homes in D5 and §5.3. One function, two named call sites, zero copies | Law 6, DR-3 |
| D6 | Fix `subagent-stop-probe.sh` to read `transcript_path` (falling back to `agent_transcript_path`), so `_probe_transcript_exists_at_fire` measures reality on both runtimes | §3b-7: the probe currently reports false on every Copilot firing because of a key-name miss - a lying instrument on exactly the surface this design depends on | Law 1, instrument-audit |
| D7 | `dispatched` records under Copilot: IN scope, via TWO changes, not one. (a) D2's filter tolerance admits the payload; (b) the launch SUBJECT extraction is rewired: accept `tool_response.agentId` (Claude shape) OR `tool_input.name` (compat shape, §3b-8) - never throw on the compat payload. Stop-side subject: the §3b-8 join chain (in-flight `toolCallId` → `execution_start.arguments.name`), landing both record halves in the SAME name-space so dispatched↔returned pair under Copilot; when the join fails, the record discloses `subject_basis: name-time` [DR-4, folded] | Rev 2 claimed "D2's filter fix alone makes launch records mint" - false: `Produce-Artifact.ps1:148` reads `tool_response.agentId`, absent from the compat payload, and throws at `:151`. The rewire is small because the subject material exists (§3b-8, probed); pairing MATTERS even though StoreIntegrity doesn't assert it - the yard board (#1) joins these, so "partial coverage breaks nothing" was conflating two different consumers | Law 1, DR-4, NIRTS |

## §5 - Mechanism

1. `.claude/settings.json`: four SessionStart lines change from
   `$CLAUDE_PROJECT_DIR/.claude/hooks/x.sh` to `sh .claude/hooks/x.sh`. The
   `sh -c '...'` entire-CLI wrappers are left untouched: Claude-side they work,
   Copilot-side entire is natively covered by `.github/hooks/entire.json`, and their
   compat failure is fail-open noise pinned by a D3 probe (visible, harmless, known).
2. `Produce-Artifact.ps1`: filter tolerance (D2), stderr skip-lines (D2), launch
   subject-extraction rewire at `:148` - `tool_response.agentId` OR `tool_input.name`
   (D7), stop-side subject join + absent-envelope minting (D4), transcript-format
   branch (D5). Red-first: fixture payloads (real captures) + failing tests before
   each change - including one red proving the compat launch payload currently throws
   at `:151` [DR-4].
3. `scripts/lib/TranscriptRead.ps1`: extracted shared reader (D5), consumed by
   `Produce-Artifact.ps1` and `Land-Verdict.ps1`.
4. `subagent-stop-probe.sh`: key-name fix (D6).
5. `scripts/probes/RuntimePayload.Probes.Tests.ps1`: shape pins (D3).
6. `docs/setup.md`: hooks table gains per-runtime fired/probed status columns per this
   design's probes; `sh`-on-PATH prerequisite row; the rev-1 "producer silent under
   Copilot" claim is CORRECTED (it was a filter, not silence - Law 1 fix, cites §3b).
7. Spec #7 amendment block: compat payload tolerance, second transcript format, the
   D4 absent-envelope semantics, D7 subject-basis disclosure.

## §6 - Failure modes

| Failure | Behaviour | Law |
|---|---|---|
| `sh` not on PATH (fresh box) | Hooks fail loudly, known signature; `docs/setup.md` prerequisite row names the fix; nothing preToolUse so nothing fail-closed | Law 5, Law 4 |
| Report not in events.jsonl at stop (the P5 common case) | `returned` record mints with `envelope: absent` + fault line + stderr naming the backfill command; verdict lands via the one extractor at land-time | Law 4 |
| Neither `agent_type` nor `agent_name` in a stop payload | Filter exit 0 WITH stderr line quoting the keys that were present - unknown shape renders as a visible skip, never a guessed record | Law 1 |
| Subject join fails (no `execution_start` match for the in-flight `toolCallId`) | Record mints with `subject_basis: name-time` disclosed in the record body, never a fabricated id; dispatched↔returned pairing degrades visibly for that pair, not silently | Law 1, Law 4 |
| Compat layer changes on a Copilot update (P1 moves) | D3 probes red BY NAME (payload shape, command-form behaviour); the session-start retro sees it | Law 5, Healing Loop |
| Claude Code regression from the intersection dialect (P4 false) | §2c-2 blocking verify on next Claude session; until verified, `docs/setup.md` carries the "expected-unchanged, unverified" row | Law 1 |
| Duplicate records if a future compat fix runs a path twice | One manifest (D1) makes this structurally impossible today; if wiring ever grows a second path, record ids make duplicates visible in StoreIntegrity's per-record checks | Law 6 |

## §7 - Out of scope

- Entire mirroring (done, working - `entire.json`, agentStop success observed).
- Automatic post-read envelope enrichment (D4 names its two revisit triggers).
- The upstream entire defect (subagent agentStop with empty transcriptPath → noise):
  filed on #47, trigger = it ever becomes more than noise.
- A third runtime (the seam is two named formats; a third is the trigger to reconsider).
- Rewriting the `sh -c` entire wrappers in `.claude/settings.json` (working where they
  matter, pinned where they fail).

## §8 - Contracts touched

| Contract | Change | Owner |
|---|---|---|
| `docs/setup.md` | runtime status columns, prerequisite row, rev-1 claim correction (§5.6) | the car |
| Spec #7 (producer) | amendment block (§5.7) | the car |
| `docs/templates/car-brief.md` | verified no change needed (envelope mandate is runtime-neutral) - car re-verifies and states so | the car |
| State ledger | no mutable service state touched - reviewer verifies | reviewer |
| `#47` open ends | items 2 (producer port) and 5 (compat-layer disposition) are RESOLVED by this design; conductor updates the issue on landing | conductor |

## §9 - Cost

1 design re-review (delta, round 2) + 1 car + 1 adversarial review = **3 dispatches**,
Opus-class, medium. The §2c restart-gated probe is conductor-run with one owner restart.
Owner approval recorded before car dispatch.

## §9b - Disposition of round 1 (verdict: `artifacts/reviews/2026-07-24-dual-runtime-design-review-round1-REJECT.md`)

| Prior item | Kind | Disposition | Where |
|---|---|---|---|
| DR-1 (MAJOR): P1's evidence did not cover the producer's own `sh script.sh` lines; the normalizer could activate a duplicate compat path; no §2c probe | finding | **adopted, and the probe it demanded was run before this revision**: probe-logs prove the compat path executes and self-filters (§3b-1/3). Rev 2 deletes the second manifest and the normalizer entirely - the duplicate-path vector no longer exists (D1); the filter's silent exit becomes a visible skip (D2) | §3b, D1, D2 |
| DR-2 (MINOR): §3 inventory miscount (9 vs 8, double-counted the SubagentStop probe) | finding | adopted - inventory restated correctly: 4 SessionStart guards + 2 producer forwarders (one stop, one launch) + 2 probe hooks = 8 | §3, §3b |
| DR-3 (MINOR): D5 vs §5.3 named two homes for the "one extractor" | finding | adopted - one home (`scripts/lib/TranscriptRead.ps1` via `Get-LastAssistantText`), both call sites named, adapter retired | D5, §5.3 |
| Round-1 answer to Q3 (StoreIntegrity has no pairing assertion; D7 deferral sound) | ruling | adopted, and it unlocked the OPPOSITE choice: with pairing unconstrained and the filter fix already paying for launch records, D7 flips from deferred to in-scope | D7 |

## §9c - Disposition of round 2 (verdict: `artifacts/reviews/2026-07-24-dual-runtime-design-review-round2-REJECT.md`)

| Prior item | Kind | Disposition | Where |
|---|---|---|---|
| DR-4 (MAJOR): "filter fix alone makes launch records mint" is false - `Produce-Artifact.ps1:148` reads `tool_response.agentId`, absent from the compat launch payload (no `toolCallId` either); D7's named fallback did not exist in the payload; launch and stop identities shared no join key, pairing unacknowledged | finding | **adopted, and the probe it demanded was run before this revision**: the compat launch keyset is now §3b-8 (verified, quoted); the subject that IS present is `tool_input.name`, and the stop side reaches the same name-space via `execution_start.arguments.name` (probed 3/3) - so D7 is rewritten as filter fix + subject rewire, pairing preserved in one name-space, `subject_basis` disclosed on join failure. The "partial coverage breaks nothing" conflation is retracted: the yard board (#1) is the consumer that pairs | §3b-8, D7, §5.2 |
| DR-5 (MINOR): "44/44 post-task entries under Copilot" - only 3/44 are Copilot; false population count in the observed-substrate section | finding | adopted - §3b-4 restated: 3/3 Copilot entries carry `tool_name: Agent`; the 41 Claude Code entries are named as evidence for nothing Copilot-side | §3b-4 |
| Round-2 rulings on Q1/Q2/Q3 (absent-envelope minting correct; format detection sufficient; `sh -c` wrappers stay pinned noise) | ruling | adopted as-is; Q1-Q3 are closed and removed from §10's asks | D4, D5, §5.1 |

## §10 - Open questions for the reviewer

Rounds 1-2 answered the prior Q1-Q3 (dispositions in §9b/§9c). Remaining:

1. **D7's stop-side join** runs three hops (in-flight set → `toolCallId` →
   `execution_start.arguments.name`). Is the `subject_basis: name-time` negative branch
   an acceptable floor while §2c-4's overlapping-agents probe is outstanding, or should
   the join be considered blocking for D7's landing?
2. **The retracted pairing conflation** (§9c): does any OTHER consumer beyond the yard
   board (#1) join dispatched↔returned that this design should name?
