#requires -Version 7.4
# Reconcile-DispatchRecords.ps1 -- #32: cross-references
# .claude/probe-logs/subagent-stop.jsonl against the artifact store, and reports
# LOUDLY every probe-log firing the producer WOULD HAVE ADAPTED (Claude basis:
# non-empty agent_type) but which has NO matching `returned` record (subject ==
# agent_id) in the store.
#
# WHY: on 2026-07-23 the producer hook (scripts/Produce-Artifact.ps1) wrote NO
# dispatched/returned record for 2 of 3 dispatches - git status was clean, no record
# ever existed, so the failure was INVISIBLE. scripts/Detect-Dispatches.ps1 only ever
# sees `overdue` (a dispatched record with no returned successor); a dispatch whose
# RECORD NEVER GOT WRITTEN produces no signal there at all. This script makes that
# absence detectable by cross-referencing against an INDEPENDENT source that survives
# producer silence: the SubagentStop probe log, appended by
# .claude/hooks/subagent-stop-probe.sh - a SEPARATE process from the producer, so a
# producer write/commit failure does not also erase the probe's own record of the
# firing.
#
# ROOT CAUSE UNPROVEN (hypothesis: git index contention) - THIS SCRIPT DOES NOT CHASE
# IT and adds NO locking to the producer. It detects the symptom (a firing with no
# record); it never repairs anything and never writes to the store.
#
# THE WOULD-HAVE-ADAPTED RULE, Claude basis only. Every probe-log line in this repo
# originates from subagent-stop-probe.sh's SubagentStop hook, which is wired only in
# .claude/settings.json's Claude-Code-native hook array - the Copilot CLI compat
# layer's SubagentStop-side payload shape remains an unproven boundary (docs/setup.md:
# "the SubagentStop-side compat shape for a Copilot stop remains an honest boundary").
# So every entry here is Claude-shaped, and the rule mirrors
# scripts/Produce-Artifact.ps1:160-165's Claude-returned branch exactly: a line whose
# `agent_type` is NON-EMPTY is a real dispatch the producer would have recognised,
# subject = agent_id. Empty `agent_type` means an internal harness subagent, which
# the producer never records - excluded, never reported as a gap.
#
# OPEN QUESTION, ANSWERED (#32 brief): can this rule be SHARED with
# Produce-Artifact.ps1 via a common helper? NO, by deliberate choice, not oversight.
# Produce-Artifact.ps1 is the ONE writer, invoked via `pwsh -File` from two
# latency-sensitive hooks (docs/probes/2026-07-22-spec7-probe-results.md: a slow
# SubagentStop hook blocks the dispatch's return path for its full runtime) and is
# covered by an extensive existing suite (scripts/tests/Producer.Tests.ps1). This
# script needs only ONE of the producer's FOUR runtime/kind branches (Claude +
# returned) - refactoring the producer to share a three-line rule would touch a
# heavily-tested, latency-critical, single-writer script for a small dedup, which is
# the riskier trade for a read-only, out-of-band reconciliation tool. The brief's own
# escape valve is taken instead: a DELIBERATE SECOND COPY, pinned by a divergence test
# (scripts/tests/ReconcileDispatchRecords.Tests.ps1, Describe "...divergence pin") that
# chains the two scripts' REAL BEHAVIOUR - the producer writes a record from a real
# fixture payload, and this script is asked whether that exact record satisfies the
# SAME fixture's probe-log line - rather than comparing static source text (the
# register-taxonomy divergence-pin precedent, #37, applied behaviourally instead of as
# a static set-equality check, because here the two "sources of truth" are code paths).
# If either script's identity rule drifts, that test goes red BY NAME.
#
# TEST OVERRIDE: -ProbeLog and -StoreRoot point at fixture paths in tests (same
# override-with-default shape as CHECKPOINT_FILE in
# .claude/hooks/session-start-checkpoint-reconcile.sh, line 50) - tests never touch
# the real store or the real probe log.
#
# WIRED into the goodnight ritual's existing "5b. Artifact-store sweep" step
# (.claude/skills/goodnight/SKILL.md) - joined, not duplicated.
#
# THE PRODUCER-EPOCH FLOOR (fix cycle round 2, finding M5). Round 1 wired this script
# into the nightly goodnight sweep without ever running it against the real corpus:
# on day one it exits 1 with 9 gaps across 7 agents, every one at or before
# 2026-07-22T16:35:08Z, while the earliest producer-written `returned` record in the
# real store is 2026-07-22T16:40:01Z (reproduced verbatim by this car, read-only,
# against the shared checkout's real .claude/probe-logs/subagent-stop.jsonl and
# artifacts/ - the 9 agent_ids and timestamps matched the round-1 verdict exactly).
# Those 9 firings predate the producer hook's own existence in this repo - expected,
# not instances of the class this script exists to detect. A nightly step reporting
# the same 9 non-defects forever is the severity-philosophy scar this repo already
# paid: "expected/placeholder patterns are NOTES, defects are FLAGS - an instrument
# that cries wolf is worse than no instrument."
#
# THE FIX: the default floor is DERIVED FROM THE STORE - the earliest `kind: returned`
# record's `at` timestamp - so it advances automatically as real history accumulates
# and is never a hand-set constant that goes stale. -Since overrides it (tests never
# touch the real store to establish a floor). A probe firing whose `_probe_logged_at`
# is BEFORE the floor and has no matching record is EXCLUDED as expected-not-a-gap,
# counted in ONE summary NOTE line, never a FLAG and never affecting the exit code. A
# MISSING or unparseable `_probe_logged_at` can never be proven pre-epoch, so it is
# NEVER excluded on that basis - it stays a reported gap, conservative by design
# (never silently suppress a signal the epoch logic cannot justify suppressing), and
# renders `logged_at=unknown` explicitly rather than blank (m3, Law 1: unknown renders
# as unknown, never as an empty string a reader could mistake for "recorded but
# empty").

param(
    [string]$ProbeLog = '',
    [string]$StoreRoot = '',
    [string]$Since = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path $PSScriptRoot -Parent
if (-not $ProbeLog)  { $ProbeLog  = Join-Path $repoRoot '.claude/probe-logs/subagent-stop.jsonl' }
if (-not $StoreRoot) { $StoreRoot = Join-Path $repoRoot 'artifacts' }

function Get-Prop {
    param([object]$Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $p = $Object.PSObject.Properties[$Name]
    if ($null -eq $p) { return $null }
    return $p.Value
}

# The would-have-adapted rule (Claude basis only - see header disclosure). Given one
# parsed probe-log line, returns $null if the producer would NOT have recorded it
# (empty agent_type - internal harness subagent, excluded), or the SUBJECT it would
# have recorded (== agent_id) otherwise. Mirrors Produce-Artifact.ps1:160-165.
function Get-WouldHaveAdaptedSubject {
    param([object]$ProbeLine)
    $agentType = Get-Prop $ProbeLine 'agent_type'
    if ([string]::IsNullOrWhiteSpace($agentType)) { return $null }
    return Get-Prop $ProbeLine 'agent_id'
}

# --- load probe log lines (absent file = no firings yet, a clean 0, never a fault) ------
$probeEntries = @()
if (Test-Path $ProbeLog) {
    foreach ($line in @(Get-Content -Path $ProbeLog -Encoding UTF8)) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try {
            # -DateKind String: without it, ConvertFrom-Json auto-parses an ISO-8601-
            # shaped string like _probe_logged_at into a [datetime], which then
            # re-renders in the CURRENT CULTURE's format when interpolated below
            # ("2026-07-23T09:00:00Z" became "07/23/2026 09:00:00" - observed, this
            # car) - silently corrupting the timestamp this script exists to report
            # verbatim. Same fix Detect-Dispatches.ps1:132 already applies for the
            # same reason.
            $probeEntries += ($line | ConvertFrom-Json -DateKind String)
        } catch {
            Write-Warning "Reconcile-DispatchRecords: could not parse probe-log line - skipped: $line"
        }
    }
}

# --- load every `returned` record's subject AND `at` timestamp from the store -----------
# The `at` values double as the raw material for the default epoch floor below - one
# pass over the store, never two.
#
# FILENAME-SCOPED, deliberately (caught running M5's real-corpus verification, this
# car): the store also holds LANDED REVIEW VERDICTS under `artifacts/reviews/`
# (`scripts/Migrate-Verdicts.ps1`), which share the SAME `starcar-artifact/1` schema
# and the SAME `kind: "returned"` value, but are a different category of record
# entirely - hand-landed by `Land-Verdict.ps1`, not auto-recorded by the producer hook
# this reconciler cross-references. Their `at` timestamps predate the producer hook's
# own existence by months (observed: 2026-07-22T03:44:34-04:00, a design-review
# verdict, vs the earliest PRODUCER-written record at 2026-07-22T16:40:01Z) - scanning
# ALL `*.json` files contaminated the epoch floor with a verdict's landing time,
# silently defeating M5's pre-epoch exclusion entirely (observed against the real
# store: 0/9 gaps excluded with the unscoped filter, all 9 excluded correctly once
# scoped). `Produce-Artifact.ps1:394-397` names its own convention explicitly -
# `dispatched-<timestamp>.json` / `returned-<timestamp>.json` - so scoping to
# `returned-*.json` is the producer's OWN naming contract, not an invented filter.
$returnedSubjects = New-Object 'System.Collections.Generic.HashSet[string]'
$returnedAtValues = @()
if (Test-Path $StoreRoot) {
    foreach ($f in @(Get-ChildItem -Path $StoreRoot -Filter 'returned-*.json' -Recurse -File)) {
        try {
            $obj = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json -DateKind String
        } catch {
            continue
        }
        if ((Get-Prop $obj 'kind') -eq 'returned') {
            $subj = Get-Prop $obj 'subject'
            if (-not [string]::IsNullOrWhiteSpace($subj)) { [void]$returnedSubjects.Add($subj) }
            $at = Get-Prop $obj 'at'
            if (-not [string]::IsNullOrWhiteSpace($at)) { $returnedAtValues += $at }
        }
    }
}

# --- the producer-epoch floor (M5) -------------------------------------------------------
# -Since wins outright when supplied (tests never touch the real store to establish a
# floor). Otherwise, derive the floor as the EARLIEST `at` among every `returned`
# record in the store - if the store carries no returned records at all, there is no
# evidence to derive a floor from, and $epochFloor stays $null (no exclusion applies,
# the pre-M5 behaviour, honest when there is nothing to compare against).
function ConvertTo-Instant {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return $null }
    try {
        return [datetimeoffset]::Parse($Text, [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
    } catch {
        return $null
    }
}

$epochFloor = $null
if ($Since) {
    $epochFloor = ConvertTo-Instant $Since
} elseif ($returnedAtValues.Count -gt 0) {
    foreach ($atText in $returnedAtValues) {
        $parsed = ConvertTo-Instant $atText
        if ($null -ne $parsed -and ($null -eq $epochFloor -or $parsed -lt $epochFloor)) {
            $epochFloor = $parsed
        }
    }
}

# --- cross-reference: report every REAL gap loudly, exclude pre-epoch firings as notes ---
$gaps = @()
$preEpochCount = 0
foreach ($entry in $probeEntries) {
    $subject = Get-WouldHaveAdaptedSubject -ProbeLine $entry
    if ($null -eq $subject) { continue }   # empty agent_type - internal harness subagent, excluded
    if ($returnedSubjects.Contains($subject)) { continue }   # has a matching record - not a gap

    $loggedAtRaw = Get-Prop $entry '_probe_logged_at'
    $loggedAtInstant = ConvertTo-Instant $loggedAtRaw

    # Pre-epoch exclusion applies ONLY when the floor exists AND this entry's own
    # timestamp is known and provably before it. A missing/unparseable timestamp can
    # never be proven pre-epoch, so it is never excluded on that basis (m3, Law 1).
    if ($null -ne $epochFloor -and $null -ne $loggedAtInstant -and $loggedAtInstant -lt $epochFloor) {
        $preEpochCount++
        continue
    }

    $gaps += [pscustomobject]@{
        AgentId  = $subject
        # Law 1: unknown renders as unknown, never as an empty string a reader could
        # mistake for "recorded but empty" (m3).
        LoggedAt = if ([string]::IsNullOrWhiteSpace($loggedAtRaw)) { 'unknown' } else { $loggedAtRaw }
        Kind     = 'returned'
    }
}

if ($preEpochCount -gt 0) {
    $floorDisplay = if ($epochFloor) { $epochFloor.ToString('yyyy-MM-ddTHH:mm:ssK') } else { 'unknown' }
    "[reconcile] NOTE - $preEpochCount probe firing(s) excluded as pre-producer-epoch (before $floorDisplay) - expected, not gaps"
}

if ($gaps.Count -gt 0) {
    foreach ($g in $gaps) {
        "[reconcile] GAP - agent_id=$($g.AgentId) logged_at=$($g.LoggedAt) missing_kind=$($g.Kind) (probe fired, no matching store record)"
    }
    exit 1
}

"[reconcile] no gaps - every would-have-adapted probe firing has a matching returned record"
exit 0
