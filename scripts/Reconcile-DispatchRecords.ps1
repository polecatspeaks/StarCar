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

param(
    [string]$ProbeLog = '',
    [string]$StoreRoot = ''
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

# --- load every `returned` record's subject from the store ------------------------------
$returnedSubjects = New-Object 'System.Collections.Generic.HashSet[string]'
if (Test-Path $StoreRoot) {
    foreach ($f in @(Get-ChildItem -Path $StoreRoot -Filter *.json -Recurse -File)) {
        try {
            $obj = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json -DateKind String
        } catch {
            continue
        }
        if ((Get-Prop $obj 'kind') -eq 'returned') {
            $subj = Get-Prop $obj 'subject'
            if (-not [string]::IsNullOrWhiteSpace($subj)) { [void]$returnedSubjects.Add($subj) }
        }
    }
}

# --- cross-reference: report every gap loudly --------------------------------------------
$gaps = @()
foreach ($entry in $probeEntries) {
    $subject = Get-WouldHaveAdaptedSubject -ProbeLine $entry
    if ($null -eq $subject) { continue }   # empty agent_type - internal harness subagent, excluded
    if (-not $returnedSubjects.Contains($subject)) {
        $gaps += [pscustomobject]@{
            AgentId  = $subject
            LoggedAt = (Get-Prop $entry '_probe_logged_at')
            Kind     = 'returned'
        }
    }
}

if ($gaps.Count -gt 0) {
    foreach ($g in $gaps) {
        "[reconcile] GAP - agent_id=$($g.AgentId) logged_at=$($g.LoggedAt) missing_kind=$($g.Kind) (probe fired, no matching store record)"
    }
    exit 1
}

"[reconcile] no gaps - every would-have-adapted probe firing has a matching returned record"
exit 0
