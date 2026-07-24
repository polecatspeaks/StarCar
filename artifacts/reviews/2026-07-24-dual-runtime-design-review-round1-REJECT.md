<!-- starcar-integrity: sha256=da3691fd0023001385e23d2663e736cd5738fe17e23647d9df314cfb3362330e covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Dual-runtime harness design review, round 1 (#47)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: adversarial design review
Round: 1
Target: `docs/design/2026-07-24-dual-runtime-harness-design.md @ d626268`
Base reviewed: `d62626812df8d64c37cc99d52910967c3811b6a4`
Reviewer: car agent type, Claude Opus 4.8 (Copilot CLI runtime), read-only, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `design-review-47`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `d62626812df8d64c37cc99d52910967c3811b6a4` |
| Entire checkpoint | `4ba9fe109041` |
| Dispatch, the locator within the session | `design-review-47` |
| Entire session (context, NOT a lookup key) | `dr47-r1-transcript` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain d62626812df8d64c37cc99d52910967c3811b6a4
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

I have enough to rule. Let me consolidate. Final confirmations: car-brief envelope is runtime-neutral (§8 "no change" correct); setup.md's current disclosure (lines 62-75) is consistent and correctly claimed as a contract the car updates. §5 item 3 commits to extending `Get-LastAssistantText` in `Produce-Artifact.ps1`.

## Review complete — verdict below.

I re-derived every empirical claim rather than reading it. HEAD is `d626268` (matched; reviewed in place). The design's law-first spine is genuinely clean — every constitution paraphrase matches the binding clause, the §0 instrument split is correct, and the substrate claims re-derive true. One premise, however, is used to rule out a failure it does not actually cover, and the change this design introduces can trip that failure.

**What re-derived TRUE (observed, not read):**
- `events.jsonl` (1780 lines): `subagentStop` input carries camelCase `sessionId`/`transcriptPath`/`agentName`/`cwd`, `transcriptPath` → the parent's own `events.jsonl` (P5, §3 ✓). `agentStop` fired 8×, 2 failed `transcript file not specified` with `transcriptPath:""` and `sessionId`=the agent's `toolCallId` (§7 cosmetic defect ✓). §2c-4 identity join re-derived live: `subagent.completed.toolCallId` = `toolu_018vax…` = the empty-transcript `agentStop.sessionId` ✓. Report envelope IS present in `tool.execution_complete` content ✓, and `subagentStop` fired ~2.8s **before** `subagent.completed` — so §2c-2 (flushed *at fire time*) is genuinely open and honestly flagged.
- Process logs: `ParserError` on `$CLAUDE_PROJECT_DIR/.claude/hooks/*.sh` and fail-closed `preToolUse` confirmed (P1 parenthetical accurate *for those forms*).
- `sh` resolves as `sh.cmd` (scoop shim) — P2 ✓. `$input | sh -c "cat"` → `{"a":1}` and `$input | sh script.sh` → `{"k":42}` — §5 construction is valid PowerShell ✓.
- `StoreIntegrity.Tests.ps1`: **129 passed, 0 failed**, per-record (schema+hash F4, manifest layer), **no dispatched↔returned pairing assertion** → D7 sound, **Q3 = yes, acceptable**.
- Spec S2.1/S2.3/S2.4, `car-brief.md` envelope neutrality, `setup.md` disclosure — all as the design describes.

```starcar-artifact
outcome: REJECT

findings:
  DR-1 (MAJOR) - Sections P1 / D2 / §6, evidence at .claude/settings.json:73-82 and process-*.log:
    D2's central safety claim is "Double-fire is impossible while the compat-layer execution
    of .claude/settings.json keeps failing (P1)". P1 cites as its evidence only two failure
    forms: ParserError on bare $CLAUDE_PROJECT_DIR/... (the SessionStart guards) and quote-mangle
    on sh -c '...' (the entire wrappers). But the producer's own hook lines in
    .claude/settings.json are neither form - they are `sh .claude/hooks/starcar-producer-stop.sh`
    and `sh .claude/hooks/post-task-probe.sh` (relative path, no $CLAUDE_PROJECT_DIR, no sh -c
    quoting). I proved that exact form executes byte-clean under PowerShell this session
    ('{"k":42}' | powershell -c "$input | sh script.sh" returned {"k":42}). P1's cited evidence
    therefore does not cover the very hook lines D2 uses it to rule out. #47 today observed the
    producer emitted NOTHING under Copilot - but the likely reason is the filter (spec S2.2:
    agent_type only), which the Copilot camelCase payload lacks, NOT that execution fails. D3
    then adds a normalizer to those exact scripts that maps camelCase to the snake_case names
    the scripts consume; if the compat layer already executes the .claude producer lines and they
    merely filter to nothing today, the normalizer can ACTIVATE that path and produce DUPLICATE
    returned records alongside the new starcar.json path. §6's failure table names double-fire
    only as a FUTURE "Copilot update fixes the compat layer" event, not as a consequence this
    change itself can trigger, and §2c carries no probe for it. #47 item 5 ("decide whether
    .claude/settings.json remaining hooks still fire under compat - port or retire") is an
    explicit open end the design neither resolves, probes, nor scopes out. Fix (cheap): add a
    §2c BLOCKING probe - do the .claude producer SubagentStop/PostToolUse lines execute under
    Copilot compat, and what do they emit before vs after the normalizer? - with a named branch
    (retire the .claude producer lines for Copilot, or adopt the Q1 dedup key NOW). The design
    disclosed the risk in §10 Q1; disclosure does not clear it because the mitigation is deferred
    to "when P1 falsifies" while this change can falsify the silent-filter state on landing.

  DR-2 (MINOR) - §3 harness inventory miscount, evidence .claude/settings.json:
    §3 enumerates "four SessionStart guards, two SubagentStop producer hooks, one PostToolUse
    producer hook, two probe hooks" (sums to 9). The actual starcar wiring is 8 hooks:
    SessionStart guards = 4 (goodnight-resume, checkpoint-reconcile, ci-baseline, retro);
    SubagentStop = subagent-stop-probe.sh (probe) + starcar-producer-stop.sh (producer);
    PostToolUse:Task = post-task-probe.sh (probe) + starcar-producer-launch.sh (producer).
    So producers = 2 (one each), probes = 2. "two SubagentStop producer hooks" is wrong - there
    is one - and it double-counts subagent-stop-probe.sh, which is already counted under "two
    probe hooks." A car inherits a wrong inventory of the surface it is porting.

  DR-3 (MINOR) - D5 vs §5 item 3, the "one extractor" home is described two ways:
    D5 says graduate the backfill adapter into a standalone scripts/Extract-AgentReport.ps1,
    "ONE extractor, consumed by (a) the Copilot subagentStop producer path and (b) manual
    Land-Verdict.ps1 backfill." §5 item 3 instead commits to a format BRANCH inside
    Produce-Artifact.ps1's Get-LastAssistantText. These are different homes, and the Land-Verdict
    backfill path (setup.md:24, uses Get-ResultBlockForTask) does not obviously call
    Get-LastAssistantText, so the "one extractor, both consumers" Law 6 goal is asserted but its
    single call-site is unspecified. Two cars could realize it two ways, defeating the Law-6
    intent. Name the single home and both call sites explicitly.

abstract: |
  Adversarial DESIGN review of docs/design/2026-07-24-dual-runtime-harness-design.md at dev HEAD
  d62626812df8d64c37cc99d52910967c3811b6a4 (verified, reviewed in place). Re-derived, not read:
  parsed the parent session events.jsonl (1780 lines) - confirmed subagentStop camelCase payload
  with transcriptPath into the parent events.jsonl (P5, §3), the agentStop empty-transcriptPath
  failures (§7), the §2c-4 identity join (toolCallId = agentStop.sessionId = toolu_018vax) live,
  and that subagentStop fires ~2.8s before subagent.completed (§2c-2 genuinely open); confirmed
  the ParserError-on-$CLAUDE_PROJECT_DIR and fail-closed preToolUse in process logs; confirmed sh
  resolves as sh.cmd; proved $input | sh script.sh is a working PowerShell stdin construction; ran
  StoreIntegrity.Tests.ps1 (129 passed, 0 failed) and confirmed it has NO dispatched-returned
  pairing assertion, which answers the design's own Q3/D7 as sound; verified spec S2.1/S2.3/S2.4,
  car-brief envelope neutrality, and setup.md consistency. All constitution paraphrases match the
  binding clauses and the §0 instrument split is correct. Verdict REJECT on one Major: P1's cited
  evidence (ParserError on bare paths, quote-mangle on sh -c) does not cover the producer's own
  `sh .claude/hooks/x.sh` lines that D2's "double-fire impossible" claim is about - a form I proved
  executes cleanly - and the D3 normalizer this design adds can itself activate that compat path
  into duplicate returned records, a vector §6 names only as a future runtime update and §2c does
  not probe, while #47 item 5 leaves it as an unresolved open end. Two Minors: a §3 harness
  inventory miscount (9 stated vs 8 actual, double-counting the SubagentStop probe) and a D5-vs-§5
  disagreement on the single home of the "one extractor." Findings: 1 Major, 2 Minor.
```