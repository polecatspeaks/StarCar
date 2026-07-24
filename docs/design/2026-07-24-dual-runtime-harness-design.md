# Dual-runtime harness design: one harness, two runtimes (Claude Code + Copilot CLI)

Status: Open
Stage: awaiting adversarial design review
Issue: #47
Date: 2026-07-24

## §0 - Instrument check

**Behavioural/architectural, with one precision edge.** This design is about which
component owns hook execution under each runtime and how failures surface - prose holds
that. The precision edge is the two runtimes' hook payload shapes (key names, field
presence): that is a wire contract and lands as **executable probe tests pinning both
shapes** (fixtures from real observed payloads), never as prose tables a reviewer must
trust. This document points at those tests; it does not restate the shapes.

## §1 - Constraints

| Source | What it forbids here | How this design satisfies it |
|---|---|---|
| Law 6 (`constitution.md`): "never maintains a second copy of anything that can drift" | Two copies of hook logic, one per runtime; two extractors that must agree | Manifests carry ONE thin invocation line each; all logic in shared scripts; one extractor used by both the hook path and manual backfill (D3, D5) |
| Law 4 (`constitution.md`): "never silently dropped" | A dispatch record lost because a hook failed quietly | Producer keeps raise-never-drop (`artifacts/_faults.log`); unported surfaces degrade LOUDLY (D6); the known-silent state is disclosed in `docs/setup.md` until the port lands |
| Law 1 (`constitution.md`): truth on every surface | Claiming the harness "works under both" from a read | Every "works" claim below is probed or listed in §2c; the §2c table names what is still unproven |
| Law 7 (`constitution.md`): the stranger; no hardcoded operator paths | Baking `C:\Users\Chris\...` or this box's quirks into manifests | Scripts derive paths from payload/`$CLAUDE_PROJECT_DIR`/cwd; the `sh`-on-PATH requirement is documented as a box prerequisite in `docs/setup.md`, not assumed silently |
| Healing Loop: "validated facts must land as tests or gates, never only prose" | Payload shapes and event names living only in this doc or #47 comments | Probe suite pins both runtimes' payload shapes + the events.jsonl `tool.execution_complete` shape; reds by name when a runtime moves (D4) |
| Probe doctrine (CLAUDE.md, NO HEADERS HERE) | Designing against unobserved hook behaviour | The 2026-07-24 morning probes (events.jsonl + process logs, quoted on #47) supply the observed substrate; the rest is §2c |
| Rewrite-vs-extend (CLAUDE.md) | Rewriting the producer because the runtime changed | `Produce-Artifact.ps1` is EXTENDED with a transcript-format branch; hooks/forwarders extended, not regenerated |
| Right-sizing + NIRTS (CLAUDE.md) | A runtime-abstraction framework for two runtimes | No abstraction layer; the "seam" is a payload normalizer + a per-runtime transcript reader, and nothing else |
| Producer spec S2.1/S2.3/S2.4 (#7) | Changing record semantics; a second writer | ONE writer preserved; only the payload intake and transcript-read grow a second format; spec gets an amendment block, not a rewrite |
| Fail-closed `preToolUse` (probed 2026-07-24: Copilot denies the tool call when a preToolUse hook errors) | Wiring anything StarCar to `preToolUse` on either runtime | Nothing in this design touches preToolUse |

## §2 - Premises

| # | Premise | If false |
|---|---|---|
| P1 | Copilot keeps loading `.claude/settings.json` via its Claude-compat layer and executing those commands **via PowerShell** (observed: ParserError on `$CLAUDE_PROJECT_DIR/...`, quote-mangle on `sh -c '...'`) | The double-fire analysis in D2 changes; re-probe on every Copilot version bump (probe suite reds) |
| P2 | `sh` resolves from PowerShell on every box that runs either runtime (machine-level PATH fix, this box) | Copilot-side hooks fail loudly with a known signature; documented prerequisite, not silent |
| P3 | Hook config is session-cached on Copilot; every wiring change needs a CLI restart to test | Testing loop is slower/faster than planned; correctness unaffected |
| P4 | Claude Code executes hook commands via a POSIX shell, so `sh .claude/hooks/x.sh` (relative path, cwd = project dir) behaves as today's `$CLAUDE_PROJECT_DIR`-prefixed form | Intersection dialect breaks Claude-side; cheap to verify on the next Claude Code session before relying on it |
| P5 | The runtimes are distinguishable from inside a hook by payload shape alone (Claude: `session_id`/`agent_transcript_path` snake_case; Copilot: `sessionId`/`transcriptPath` camelCase - both observed) | Normalizer needs an explicit runtime flag passed by the manifest line instead (fallback named in D3) |

## §2c - Probe list (what the desk cannot prove)

| Claim | Why unverifiable from the desk | What would settle it |
|---|---|---|
| Copilot loads arbitrary `.github/hooks/*.json` files (not just `entire.json`) | Only one instance exists; never observed a second | Drop a `starcar.json` with one echo hook, restart, observe `hook.start` in events.jsonl. **BLOCKING for D2**; negative branch: append StarCar entries into `entire.json` with clear `comment` fields (worse - shared file with a generator - so probe first) |
| At `subagentStop` fire time, the agent's final report is already flushed to the parent's events.jsonl | Timing observed only post-hoc, not at fire | Probe hook greps events.jsonl for the envelope AT fire time (same shape as the Claude-side SubagentStop probe that settled #7's Probe 5); negative branch: `returned` record lands `envelope: absent` + fault line, backfill remains the recovery path |
| Claude Code still runs everything after this change (no Claude-side regression) | No Claude Code session available from this desk | First Claude Code session after landing runs the probe suite + one live dispatch; until then `docs/setup.md` marks Claude-side as "expected-unchanged, unverified since 0c3bfcb" |
| Copilot's `postToolUse` payload for a `task` tool call carries enough to mint a `dispatched` record (agent id ↔ stop-side identity) | Payload logged but identity-join not yet traced end to end | One dispatched/returned pair examined for a shared key (candidate observed: `toolCallId` ↔ `agentStop.sessionId` for subagents); negative branch: `dispatched` record carries its own id and the join is by timestamp+agentName, disclosed in the record |

## §3 - The problem

The repo bounces between Claude Code and Copilot CLI (owner, 2026-07-24: "the minimum
amount of work to ensure functionality between the two disparate model and environment
families"). Today the entire StarCar hook harness - four SessionStart guards, two
SubagentStop producer hooks, one PostToolUse producer hook, two probe hooks - is wired
only in `.claude/settings.json` in a dialect (POSIX one-liners + `$CLAUDE_PROJECT_DIR`)
that Copilot's compat layer executes via PowerShell, where every command fails with
exit 1. Result: under Copilot, no session-start guard fires and no dispatch record
lands. The morning's probes (#47) established the full substrate: Copilot fires the whole
hook family, `subagentStop` carries `transcriptPath` → the parent's `events.jsonl`, and
the agent's verbatim report (envelope included) is present there as a
`tool.execution_complete` event.

## §4 - Decisions

| # | Decision | Reason | Constraint/premise |
|---|---|---|---|
| D1 | Keep TWO manifests (`.claude/settings.json` for Claude Code, one Copilot-native hooks file), each carrying only thin invocation lines; ALL logic lives in the shared scripts they call | Manifest formats genuinely differ (schema, hook names, variant keys); logic duplication is what Law 6 forbids, manifest lines are addresses not logic | Law 6 |
| D2 | Copilot carrier is a NEW `.github/hooks/starcar.json` (pending the §2c blocking probe), `powershell` variant lines of the form `$input \| sh .claude/hooks/x.sh` | Keeps StarCar wiring out of the generator-owned `entire.json`; keeps `.claude/settings.json` untouched for Claude Code. Double-fire is impossible while the compat-layer execution of `.claude/settings.json` keeps failing (P1) - and if a Copilot update FIXES the compat layer, the payload normalizer makes the hooks idempotent-safe to re-examine, and the probe suite reds (shape pin) so the change is seen, not suffered | Law 6, P1, §2c-1 |
| D3 | One shared payload normalizer: each hook script passes stdin through a small python shim that maps Copilot camelCase keys to the Claude snake_case names the scripts already consume, detecting runtime by shape (P5). Fallback if P5 falsifies: the manifest line passes an explicit `-runtime` arg | Scripts stay single-source; the diff to each existing script is one line at the top | Law 6, P5 |
| D4 | Probe suite `scripts/probes/RuntimePayload.Probes.Tests.ps1`: pins both runtimes' payload key sets (fixtures from observed payloads), the normalizer's mapping, and the events.jsonl `tool.execution_complete` shape the extractor depends on | The runtimes are unversioned substrate; when either moves, a probe reds BY NAME naming the consumer that just became suspect | Healing Loop, probe doctrine |
| D5 | Graduate this morning's backfill adapter into `scripts/Extract-AgentReport.ps1` (or extend `Produce-Artifact.ps1`'s `Get-LastAssistantText` with an events.jsonl branch): ONE extractor, consumed by (a) the Copilot `subagentStop` producer path and (b) manual `Land-Verdict.ps1` backfill | The extractor exists and is proven (Car 46 round-2 landing); two extractors that must agree is a Law 6 defect | Law 6, rewrite-vs-extend |
| D6 | Until each surface's port is probed green, its silent state stays DISCLOSED in `docs/setup.md` (the pattern MAJOR2 of #46 just ratified: "not yet armed on this box" rows) | An unported hook that looks wired is a lying canary; disclosure is the cheap honest interim | Law 1, Law 4 |
| D7 | `dispatched`-record minting under Copilot is IN scope only if the §2c identity-join probe lands positive cheaply; otherwise deferred with trigger "first time a returned record lands with no matching dispatched record" | NIRTS: the returned record (verdict) is the load-bearing artifact; dispatched is bookkeeping that manual dispatch discipline currently covers | NIRTS, right-sizing |

## §5 - Mechanism

Small enough to state inline:

1. `.github/hooks/starcar.json` (new): `sessionStart` → the four guard scripts;
   `subagentStop` → probe + producer-stop forwarders; (conditional on D7)
   `postToolUse` → producer-launch. Each entry: `powershell` variant
   `$input | sh .claude/hooks/<script>.sh`, plus the equivalent `bash` variant, each
   line with a `comment` citing #47.
2. `.claude/hooks/normalize-payload` (new, python, single file): reads stdin JSON,
   emits the same JSON with Copilot keys mapped to Claude names (`sessionId`→
   `session_id`, `transcriptPath`→`agent_transcript_path`, `agentName`→`agent_name`,
   `cwd` passthrough...). Existing hook scripts prepend it to their stdin read.
   The mapping table lives THERE, once; the probe suite asserts it.
3. `Produce-Artifact.ps1`: `Get-LastAssistantText` grows a format branch - if the
   transcript file's lines are Copilot events (`"type":"tool.execution_complete"`),
   extract the last matching agent report (the proven adapter logic); else the
   existing Claude JSONL path. Red-first: fixture events.jsonl (sanitized real
   capture) + failing test before the branch exists.
4. `docs/setup.md`: hooks table gains a runtime column (fires under Claude / Copilot /
   both, each cell probed-or-marked-unverified per D6).
5. Spec #7 amendment block recording the second transcript format and the second
   manifest (supersedes stale text, per worked-briefs pattern).

## §6 - Failure modes

| Failure | Behaviour | Law |
|---|---|---|
| `sh` not on PATH (fresh box) | Copilot hook fails loudly with the known ParserError-free signature ("sh not recognized"); `docs/setup.md` prerequisite row names the fix; nothing is fail-closed because nothing is preToolUse | Law 5, Law 4 |
| Report not yet flushed to events.jsonl at subagentStop | `returned` record lands `envelope: absent` + `_faults.log` line; manual backfill (proven path) recovers; §2c probe decides whether this is real | Law 4 |
| Unknown payload shape (neither runtime's) | Normalizer emits the payload unchanged + a fault line naming the unrecognized keys - unknown renders AS unknown, never guessed into a shape | Law 1 |
| Copilot compat layer starts succeeding on `.claude/settings.json` (P1 falsifies) | Probe suite reds on the next session-start retro; double-fire risk is examined then, with records' ids making duplicates visible rather than silent | Law 6, Law 5 |
| Copilot ignores `.github/hooks/starcar.json` (§2c-1 negative) | Design falls back to entries in `entire.json` with owner sign-off; probe result recorded either way | - |

## §7 - Out of scope

- Porting Entire mirroring (done, `entire.json`, working - agentStop success observed).
- `dispatched` records under Copilot beyond D7's conditional.
- Any preToolUse gating on either runtime.
- The cosmetic entire defect (subagent agentStop with empty transcriptPath → "transcript
  file not specified" noise): upstream's bug, note filed on #47, trigger = it ever
  becomes more than noise.
- A third runtime. The seam is two named formats, not an abstraction; a third format is
  the trigger to reconsider.

## §8 - Contracts touched

| Contract | Change | Owner |
|---|---|---|
| `docs/setup.md` hooks/mirroring rows | runtime column + prerequisite row + D6 disclosures | the car |
| Spec #7 (producer) | amendment block: second transcript format, second manifest | the car |
| `docs/templates/car-brief.md` | no change expected (envelope mandate is runtime-neutral) - verify, state so in the report | the car |
| State ledger | no mutable service state touched - verify at review | reviewer |

## §9 - Cost

1 adversarial design review + 1 car + 1 delta/adversarial review = **3 dispatches**,
Opus-class, medium size. Blocking §2c probes are conductor-run (cheap, this desk, no
dispatch). Owner approval recorded before car dispatch.

## §10 - Open questions for the reviewer

1. **D2 double-fire posture**: is "impossible while P1 holds, probed-red when it stops
   holding" honest enough, or does the normalizer need an explicit dedup key now?
   (Cost of now: one more moving part; cost of later: one session of duplicate records,
   visible by id.)
2. **D3 shim language**: python is already a hook dependency (`post-task-probe.sh`)
   with a `command -v` guard. Same guard here means a python-less box silently skips
   normalization and Copilot payloads go unmapped - is a skip-with-stderr-line loud
   enough (matches existing pattern), or does absence need to fail the hook?
3. **D7 deferral**: is a returned record with no dispatched sibling acceptable
   store-shape even short-term? (StoreIntegrity tests may already have an opinion -
   reviewer, run them against a fixture of that shape.)
