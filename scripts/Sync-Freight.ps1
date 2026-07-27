#requires -Version 7.4
# Sync-Freight.ps1 -- #84, the freight lane's ONE writer. Reads project 6's Backlog/Todo
# items via `gh project item-list` (owner ruling: the inbound queue is work accepted but
# not started - excludes In Progress, already visible on the trains lane, and Done) and
# writes/updates kind=ticket records into the store, plus a kind=ticket-sync heartbeat
# marking a completed run. board/server never calls GitHub itself (#84 architecture: "the
# board stays a PURE STORE READER" - auth, rate limits, and API failures never enter the
# render path).
#
# RUN SHAPE (deliberately different from Produce-Artifact.ps1's one-hook-one-record
# model): this is a periodic BATCH sync, not a per-event hook. One invocation:
#   1. reads the WHOLE current queue
#   2. writes/overwrites one file per queued issue (ticket-<n>/ticket.json, a FIXED
#      filename - see "NO SUPERSESSION" below)
#   3. removes ticket-<n>/ directories for issues that LEFT the queue since the last run
#   4. writes the ticket-sync heartbeat LAST, only once every write/removal above has
#      succeeded - see "FAILURE SURFACES AS STALENESS" below
#   5. commits every touched path in ONE pathspec-scoped commit
#      (`git commit --only -- <paths...>`), the batch-run analog of Produce-Artifact.ps1's
#      per-record `--only` commit (never `-a`, never a bare `git add`, so a co-staged
#      conductor file is never swept into this commit - C2R1-M2's rule, applied here)
#
# NO SUPERSESSION (#84 owner ruling item 3, "the fold is not involved" - board/fold has
# no case for kind=ticket at all, algorithm.go's bySubject switch only groups
# dispatched/returned/presumed-lost/intent). There is therefore no "latest wins" authority
# for freight the way there is for dispatched/returned/intent records. This script keeps
# EXACTLY ONE file per ticket subject, overwritten in place every run, rather than
# appending a new timestamped file per poll (Produce-Artifact.ps1's
# `<kind>-<compact-at>.json` convention) - a ticket is a CURRENT-STATE CACHE of one
# GitHub issue, not an event log, and giving it an event-log shape would force
# board/assemble to re-implement "pick the latest" itself: exactly the Law 6 second-copy
# trap the #84 owner ruling and the conductor's probe both warned against.
#
# FAILURE SURFACES AS STALENESS, NEVER A SEPARATE MARKER (#84 brief's own open design
# question, answered and disclosed here): a failed run (the gh call throws, a write
# fails) writes NOTHING - not even a "we tried and failed" record - and exits nonzero.
# The ticket-sync heartbeat's own `at` therefore only ever advances on a fully successful
# run, so board/server's own computeFreightFreshness (board/server/poll.go) naturally
# reads an increasingly stale age across repeated failures - never a fresh-looking
# failure marker that could itself go silently stale. This mirrors the shape #29 already
# established for the whole-store scan (poll.go's computeLiveFreshness): "old" already
# means "something is not updating", so a second failure vocabulary would duplicate a
# signal the freshness axis already carries. Faults are still raised, never dropped
# silently (Law 4) - via _faults.log, the same convention Produce-Artifact.ps1 uses.
#
# TESTABILITY: -ItemsJsonPath lets a caller inject a `gh project item-list` fixture
# instead of calling gh live (mirrors -DefaultsPath's override-point convention
# elsewhere in this repo) - the real `gh` call is exercised only in production, never in
# this repo's own test suite (no live network dependency, no token requirement, no
# nondeterminism from a real project board's contents changing under a landed
# regression test). -NoCommit skips the git commit step entirely, for scratch-store
# fault-injection (#40 non-vacuity) where the store is not inside a git repository at
# all.
param(
    [string]$StoreRoot = 'artifacts',
    [string]$Owner = 'polecatspeaks',
    [int]$ProjectNumber = 6,
    [string]$Now = '',
    [string]$ItemsJsonPath = '',
    [switch]$NoCommit
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'Board.psm1') -Force
Import-Module (Join-Path $PSScriptRoot 'Artifact.psm1') -Force

# Get-Sha256Hex is imported from Artifact.psm1 (Law 6 - the ONE owner of the hashing
# rule, the same function Produce-Artifact.ps1 calls; never re-implemented here).

$storeAbs = [System.IO.Path]::GetFullPath($StoreRoot)
$faultsLog = Join-Path $storeAbs '_faults.log'

function Add-Fault {
    # Same convention as Produce-Artifact.ps1's own Add-Fault: a failure is RAISED,
    # never dropped (Law 4), even though this script's PRIMARY failure signal is the
    # ticket-sync heartbeat simply not advancing (the freshness-based design above).
    param([string]$Message)
    try {
        if (-not (Test-Path $storeAbs)) { New-Item -ItemType Directory -Path $storeAbs -Force | Out-Null }
        $stamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        Add-Content -Path $faultsLog -Value "$stamp`tfreight-sync`t$Message" -Encoding utf8
    } catch {
        # The store is unwritable; there is nowhere left to raise but the exit code.
    }
}

function Write-TicketRecord {
    param([string]$Subject, [string]$At, [pscustomobject]$Item)
    $record = [ordered]@{}
    $record['schema']     = 'starcar-artifact/1'
    $record['kind']       = 'ticket'
    $record['subject']    = $Subject
    $record['session_id'] = 'freight-adapter'
    $record['at']         = $At
    $record['ticket']     = [ordered]@{
        number = $Item.Number
        title  = $Item.Title
        status = $Item.Status
        url    = $Item.Url
    }
    $record['normalisation'] = @()
    $bodyJson = $record | ConvertTo-Json -Depth 20 -Compress
    $record['integrity'] = 'sha256:' + (Get-Sha256Hex $bodyJson)

    $subjectDir = Join-Path $storeAbs $Subject
    if (-not (Test-Path $subjectDir)) { New-Item -ItemType Directory -Path $subjectDir -Force | Out-Null }
    $recordPath = Join-Path $subjectDir 'ticket.json'
    $fileJson = ($record | ConvertTo-Json -Depth 20) + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($recordPath, $fileJson, $utf8NoBom)
    return $recordPath
}

function Write-TicketSyncHeartbeat {
    param([string]$At)
    $record = [ordered]@{}
    $record['schema']        = 'starcar-artifact/1'
    $record['kind']          = 'ticket-sync'
    $record['subject']       = 'ticket-sync'
    $record['session_id']    = 'freight-adapter'
    $record['at']            = $At
    $record['normalisation'] = @()
    $bodyJson = $record | ConvertTo-Json -Depth 20 -Compress
    $record['integrity'] = 'sha256:' + (Get-Sha256Hex $bodyJson)

    $syncDir = Join-Path $storeAbs 'ticket-sync'
    if (-not (Test-Path $syncDir)) { New-Item -ItemType Directory -Path $syncDir -Force | Out-Null }
    $syncPath = Join-Path $syncDir 'ticket-sync.json'
    $fileJson = ($record | ConvertTo-Json -Depth 20) + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($syncPath, $fileJson, $utf8NoBom)
    return $syncPath
}

try {
    $at = if ($Now) { $Now } else { (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') }

    # --- fetch the current queue ------------------------------------------------------
    if ($ItemsJsonPath) {
        $itemsResult = Get-Content $ItemsJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
    } else {
        $raw = gh project item-list $ProjectNumber --owner $Owner --format json --limit 500
        if ($LASTEXITCODE -ne 0) { throw "gh project item-list $ProjectNumber --owner $Owner failed (exit $LASTEXITCODE)" }
        $itemsResult = $raw | ConvertFrom-Json
    }
    $queue = Get-BoardQueueItems -ItemsResult $itemsResult

    # --- compute the desired subject set -------------------------------------------------
    # Path traversal guard (same posture as Produce-Artifact.ps1's subject check, Q3):
    # subject is derived from a gh-sourced integer, never used raw, but the allowlist
    # check stays cheap insurance against a malformed/negative number reaching a path join.
    $desiredSubjects = [ordered]@{}
    foreach ($item in $queue) {
        if ($null -eq $item.Number) { continue }
        $subject = "ticket-$($item.Number)"
        if ($subject -notmatch '^ticket-\d+$') { continue }
        $desiredSubjects[$subject] = $item
    }

    $existingSubjectDirs = @()
    if (Test-Path $storeAbs) {
        $existingSubjectDirs = @(Get-ChildItem -Path $storeAbs -Directory -Filter 'ticket-*' -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^ticket-\d+$' })
    }

    $touchedPaths = New-Object System.Collections.Generic.List[string]

    # --- write/overwrite one file per queued issue ----------------------------------------
    foreach ($subject in $desiredSubjects.Keys) {
        $recordPath = Write-TicketRecord -Subject $subject -At $at -Item $desiredSubjects[$subject]
        $touchedPaths.Add($recordPath)
    }

    # --- remove subjects that left the queue since the last run --------------------------
    foreach ($dir in $existingSubjectDirs) {
        if (-not $desiredSubjects.Contains($dir.Name)) {
            $recordPath = Join-Path $dir.FullName 'ticket.json'
            if (Test-Path $recordPath) { $touchedPaths.Add($recordPath) }
            Remove-Item -Path $dir.FullName -Recurse -Force
        }
    }

    # --- the heartbeat, written LAST (the failure-surfaces-as-staleness contract) --------
    $syncPath = Write-TicketSyncHeartbeat -At $at
    $touchedPaths.Add($syncPath)

    Write-Host "Sync-Freight: $($desiredSubjects.Count) ticket(s) in the queue, $($touchedPaths.Count) file(s) touched."

    # --- commit every touched path in ONE pathspec-scoped commit -------------------------
    if ($NoCommit) {
        exit 0
    }
    $repoRoot = (git -C $storeAbs rev-parse --show-toplevel 2>$null)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoRoot)) {
        # Not inside a git repository - a DISCLOSED deviation from Produce-
        # Artifact.ps1's hard "throw if not a repo": that script is a hook fired ONLY
        # in-repo in production, while this adapter is explicitly meant to be run
        # against scratch stores by tests and fault-injection (#84's own non-vacuity
        # mandate), so a missing repo is a SKIP (write-only mode), never a fault.
        Write-Host "Sync-Freight: '$storeAbs' is not inside a git repository - skipping commit (write-only mode)."
        exit 0
    }
    $repoRoot = ([System.IO.Path]::GetFullPath($repoRoot.Trim()))
    $relPaths = @($touchedPaths | ForEach-Object { [System.IO.Path]::GetRelativePath($repoRoot, $_).Replace('\', '/') })
    if ($relPaths.Count -eq 0) {
        Write-Host 'Sync-Freight: nothing touched, nothing to commit.'
        exit 0
    }

    $committed = $false
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        git -C $repoRoot add -- $relPaths 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { Start-Sleep -Milliseconds (50 * $attempt); continue }
        git -C $repoRoot commit --only -m "freight: sync $($desiredSubjects.Count) ticket(s) from project $ProjectNumber (#84)" -- $relPaths 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $committed = $true; break }
        # A nonzero commit exit can legitimately mean "nothing to commit" (every touched
        # path's content matches what is already staged/committed) - checked via git
        # status rather than assumed, so a genuine index-contention failure still retries.
        $dirty = git -C $repoRoot status --porcelain -- $relPaths 2>$null
        if ([string]::IsNullOrWhiteSpace($dirty)) { $committed = $true; break }
        Start-Sleep -Milliseconds (50 * $attempt)
    }
    if (-not $committed) { throw "could not commit $($relPaths.Count) touched path(s) after 3 attempts (index contention?)" }

    exit 0
}
catch {
    Add-Fault -Message $_.Exception.Message
    Write-Error "Sync-Freight failed: $($_.Exception.Message)"
    exit 1
}
