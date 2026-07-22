#requires -Version 7.4
<#
Watch-CI.ps1 -- watch a pushed SHA's CI to a TERMINAL conclusion and RECORD it, so no
one ever again claims "CI green" from a sample or an assumption.

WHY THIS EXISTS (the scar, owner's, ported from the sibling shop and paid AGAIN here on
2026-07-22): PR #18 was merged to dev and called done while the index-staleness gate was
RED on both CI legs - the conductor never watched the run to completion. An unwatched red
is indistinguishable from no red (absence-blindness, CLAUDE.md verification honesty), and
"local suites pass" proves only the local box.

THE SHAPE (ops-script-patterns.md section 3, the watch-ci half):
  1. REFUSE unless the SHA is actually on origin (fetch, compare) - you cannot watch a
     run for a commit the remote has never seen.
  2. WAIT for the run to APPEAR for this exact SHA - dispatch is async; "no run yet" is
     not "no run ever". A ref that never produces a run is its own honest outcome
     (paths-ignored? not pushed to a watched branch?), reported, never called success.
  3. WATCH to a terminal conclusion, polling at a calm interval.
  4. RECORD the observation (sha, run id, per-leg conclusion, observer, time) so the
     claim is auditable later, not re-derived from memory.

EXIT CODES (red is a SUCCESS outcome for the process - it caught something - so it is
DISTINCT from a script failure, never conflated):
  0  = observed GREEN (all legs success). Safe to proceed.
  10 = observed RED (>=1 leg failed). A CAUGHT PROBLEM - act on it; this is the tool
       working, not the tool failing.
  1  = FAILED TO OBSERVE (no run appeared within the wait, or push-parity mismatch, or
       timeout before terminal). THIS is the real failure - the scar was here.

USAGE:
  scripts/Watch-CI.ps1 [-Sha <sha>] [-Branch dev] [-IntervalSeconds 120] [-TimeoutMinutes 30]
  (defaults: Sha = current HEAD, Branch = current branch)

OS-neutral: pwsh 7.4 + gh, forward slashes, no Windows-only calls (portability #14).
#>
param(
    [string]$Sha = '',
    [string]$Branch = '',
    [int]$IntervalSeconds = 120,
    [int]$TimeoutMinutes = 30,
    [string]$RecordDir = 'artifacts/ci-checks',
    [string]$WorkflowName = 'CI'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Say([string]$m) { Write-Host "[watch-ci] $m" }

if (-not $Sha) { $Sha = 'HEAD' }
# Resolve to a FULL 40-char SHA - gh's headSha is always full, and comparing a short
# input against it silently matches nothing (observed: a 9-char input reported
# NO-RUN-APPEARED against a SHA that had three runs).
$Sha = (git rev-parse $Sha).Trim()
if (-not $Branch) { $Branch = (git rev-parse --abbrev-ref HEAD).Trim() }
$shortSha = $Sha.Substring(0, 9)

# 1. Push-parity: the remote must actually have this SHA, or there is nothing to watch.
git fetch -q origin $Branch 2>$null
$onRemote = (git branch -r --contains $Sha 2>$null) -match "origin/$Branch"
if (-not $onRemote) {
    Say "PUSH-PARITY FAIL: $shortSha is not on origin/$Branch. Push first - you cannot watch a run for a commit the remote has never seen."
    exit 1
}

# 2. Wait for a run to APPEAR for this exact SHA.
$deadline = (Get-Date).AddMinutes($TimeoutMinutes)
$runId = $null
Say "waiting for a CI run to appear for $shortSha on $Branch (timeout ${TimeoutMinutes}m)..."
while ((Get-Date) -lt $deadline) {
    $runs = gh run list --branch $Branch --limit 30 --json databaseId,headSha,status,conclusion,createdAt,workflowName 2>$null | ConvertFrom-Json
    # A SHA can carry several runs (re-runs, AND unrelated status checks - e.g. a PR-review
    # bot posts its own 'dynamic' run that is NOT our CI). Filter to OUR workflow by name,
    # then watch the MOST RECENT - an old failed attempt superseded by a passing re-run
    # must not be reported as the state, and a bot's green must never masquerade as CI.
    # [SCAR, 2026-07-22: the live test of this very script grabbed Copilot's review run
    #  (event=dynamic, success) at the same SHA where both real CI legs had failed. Without
    #  the workflow filter, the watcher would have reported GREEN over a red CI.]
    $mine = @($runs | Where-Object { $_.headSha -eq $Sha -and $_.workflowName -eq $WorkflowName } | Sort-Object { [datetime]$_.createdAt } -Descending)
    if ($mine.Count -gt 0) {
        $runId = $mine[0].databaseId
        if ($mine.Count -gt 1) { Say "note: $($mine.Count) runs for $shortSha; watching the most recent ($runId)." }
        break
    }
    Start-Sleep -Seconds $IntervalSeconds
}
if (-not $runId) {
    Say "NO RUN APPEARED for $shortSha within ${TimeoutMinutes}m. Honest outcome: paths-ignored, wrong branch, or a workflow that never triggered - NOT success."
    exit 1
}

# 3. Watch to a terminal conclusion.
Say "watching run $runId..."
while ((Get-Date) -lt $deadline) {
    $run = gh run view $runId --json status,conclusion,headSha,jobs 2>$null | ConvertFrom-Json
    if ($run.status -eq 'completed') { break }
    Start-Sleep -Seconds $IntervalSeconds
}
$run = gh run view $runId --json status,conclusion,headSha,jobs 2>$null | ConvertFrom-Json
if ($run.status -ne 'completed') {
    Say "TIMEOUT: run $runId still '$($run.status)' after ${TimeoutMinutes}m. Not terminal - not a conclusion."
    exit 1
}

# 4. Record the observation durably.
$legs = @($run.jobs | ForEach-Object { "$($_.name)=$($_.conclusion)" }) -join ', '
$observer = (git config user.name).Trim()
$stampProc = git show -s --format=%cI $Sha   # commit time; script clock is unavailable in some sandboxes
if (-not (Test-Path $RecordDir)) { New-Item -ItemType Directory -Path $RecordDir -Force | Out-Null }
$record = [ordered]@{
    sha = $Sha; branch = $Branch; run_id = $runId
    conclusion = $run.conclusion; legs = $legs
    observer = $observer; commit_time = $stampProc
}
$recPath = Join-Path $RecordDir "$shortSha.json"
[System.IO.File]::WriteAllText(
    (Resolve-Path $RecordDir).Path + "/$shortSha.json",
    (($record | ConvertTo-Json -Compress) + "`n").Replace("`r`n", "`n"),
    [System.Text.UTF8Encoding]::new($false))

Say "run $runId conclusion=$($run.conclusion) | legs: $legs"
Say "recorded -> $recPath"

if ($run.conclusion -eq 'success') {
    Say "GREEN. Safe to proceed."
    exit 0
} else {
    Say "RED ($($run.conclusion)). A CAUGHT PROBLEM - a SUCCESS outcome for the process. Act on it; do not merge on top."
    exit 10
}
