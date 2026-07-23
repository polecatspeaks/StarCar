#requires -Version 7.4
# Migrate-Verdicts.ps1 -- one-time (but idempotent) migration of hash-verified review
# verdicts from docs/reviews/*.md into the single artifact store, spec S4 rows 4-5.
#
# WHY A TOOL, NOT AN INLINE ONE-OFF: reusability rule - versioned, one command, its
# failure tells you what went stale. The migration touches every verdict landed by
# `Land-Verdict.ps1` to date, and "run this by hand, carefully" is exactly the
# vigilance-tier failure mode this repo rejects everywhere else (Verify-Verdict.ps1's
# own header). Idempotent by construction: a file already at `-DestDir` has nothing
# left at `-SourceDir` to process on a second run, so a re-run over an already-migrated
# store is a documented no-op, not a special case.
#
# WHAT MOVES: the verdict BODY (`git mv`, history preserved bit-for-bit) plus a sibling
# starcar-artifact/1 JSON record (conductor ruling R7v2,
# docs/plans/2026-07-22-harness-car3-plan.md). The record's `outcome`/`findings`/
# `abstract` are parsed from the verdict's OWN landed envelope fence where the verdict
# carries one (the truest possible source - the reviewer that authored the verdict
# wrote those exact words); the 3 fence-less early verdicts (measured at base) fall back
# to the header's leading `**Verdict: X**` token and the H1 title line.
#
# FIELD ORDER: schema, kind, subject, session_id, at, outcome, findings, abstract,
# body_file, normalisation, integrity -- `body_file` is an open-posture extra (like
# Produce-Artifact.ps1's `model`), placed immediately after the envelope triad it is a
# companion to. MARKED DEVIATION, disclosed rather than assumed (schema/index-format.md
# does not enumerate this field; additionalProperties stays open).
#
# INTEGRITY: sha256 over the compact JSON of every field above IN THAT ORDER, integrity
# itself excluded -- the identical canonicalisation Produce-Artifact.ps1 uses. Verified
# by Migration.Tests.ps1 as a HASH ROUND-TRIP, not merely a field-presence check
# (C3R1-M1/n2: a shape can carry the field and still carry a bogus hash).

param(
    [string]$SourceDir = 'docs/reviews',
    [string]$DestDir = 'artifacts/reviews'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'Envelope.psm1') -Force

function Get-Sha256Hex {
    param([string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $hash = $sha.ComputeHash($bytes)
    $sha.Dispose()
    ([System.BitConverter]::ToString($hash) -replace '-', '').ToLower()
}

if (-not (Test-Path $SourceDir)) {
    Write-Host "Migrate-Verdicts: '$SourceDir' does not exist -- nothing to migrate."
    exit 0
}

$files = @(Get-ChildItem -Path $SourceDir -Filter *.md -File | Sort-Object Name)
if ($files.Count -eq 0) {
    Write-Host "Migrate-Verdicts: '$SourceDir' holds zero .md files -- already migrated, or nothing landed yet. No-op."
    exit 0
}

$repoRoot = (git -C $SourceDir rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $repoRoot) {
    Write-Error "Migrate-Verdicts: '$SourceDir' is not inside a git repository -- git mv and git log --follow both need one."
    exit 1
}
$repoRoot = [System.IO.Path]::GetFullPath($repoRoot.Trim())

if (-not (Test-Path $DestDir)) { New-Item -ItemType Directory -Path $DestDir -Force | Out-Null }

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$migrated = 0
$fenceParsed = 0
$fallbackParsed = 0
$errorsList = New-Object System.Collections.Generic.List[string]

foreach ($f in $files) {
    try {
        $relSource = [System.IO.Path]::GetRelativePath($repoRoot, $f.FullName).Replace('\', '/')
        $destPath = Join-Path $DestDir $f.Name
        $relDest = [System.IO.Path]::GetRelativePath($repoRoot, $destPath).Replace('\', '/')

        # Derive the FIRST authorship timestamp from committed history BEFORE the move --
        # `git log --follow` walks commits starting at HEAD, which (pre-commit) still
        # holds the file at $relSource regardless of an already-staged `git mv`, so the
        # order here is for clarity, not correctness.
        $atLines = @(git -C $repoRoot log --follow --format=%aI -- $relSource 2>$null)
        if ($atLines.Count -eq 0) {
            throw "no git history found for '$relSource' -- cannot derive the 'at' (first authorship) timestamp"
        }
        $at = $atLines[$atLines.Count - 1]

        git -C $repoRoot mv -- $relSource $relDest 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "git mv failed for '$relSource' -> '$relDest'" }

        $content = [System.IO.File]::ReadAllText($destPath)
        $env = Get-StarcarEnvelope -Text $content

        # EXECUTION DISCOVERY, not anticipated by the plan's "20 of 23 carry a fence"
        # measurement: 2 of the store's fenced verdicts (the design-review rung, before
        # the outcome/findings/abstract-only grammar was finalised) carry EXTRA keys
        # inside the fence - `section_4_disposition:`, `round_6_recommended:`,
        # `workflow_verdict:` - sitting between `outcome:` and `findings:`.
        # Get-StarcarEnvelope (shared production code, Car 2's live producer path, OUT
        # OF SCOPE to modify here) correctly appends any unrecognized-key line to the
        # PREVIOUS field for its own grammar, so `outcome` comes out multi-line - not a
        # valid vocabulary token and not a usable index cell (a multi-line table cell
        # breaks the markdown table). Detected here, not fixed upstream: a fence-parsed
        # outcome must be a single line, or this file falls back to the same
        # deterministic path as a fence-less verdict.
        $fenceUsable = $env.Found -and ($env.Outcome -notmatch "`n")

        if ($fenceUsable) {
            $outcome = $env.Outcome
            $findings = $env.Findings
            $abstract = $env.Abstract
            $fenceParsed++
        } else {
            # Deterministic fallback (measured: 3 of the store's verdicts at base carry
            # no envelope fence -- all three predate the fence convention).
            $verdictMatch = [regex]::Match($content, '(?m)^\*\*Verdict:\s*(.+?)\*\*\s*$')
            if (-not $verdictMatch.Success) {
                throw "no '**Verdict: X**' header line found in '$destPath' -- cannot fall back"
            }
            $verdictText = $verdictMatch.Groups[1].Value.Trim()
            $outcome = ($verdictText -split '\s+')[0]
            $findings = 'migrated: see body_file'

            $titleMatch = [regex]::Match($content, '(?m)^#\s+(.+)$')
            if (-not $titleMatch.Success) {
                throw "no H1 title line found in '$destPath' -- cannot fall back"
            }
            $abstract = $titleMatch.Groups[1].Value.Trim()
            $fallbackParsed++
        }

        $storeRoot = Split-Path $DestDir -Parent
        if (-not $storeRoot) { $storeRoot = $DestDir }
        $bodyFile = [System.IO.Path]::GetRelativePath($storeRoot, $destPath).Replace('\', '/')

        $subject = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)

        $record = [ordered]@{}
        $record['schema'] = 'starcar-artifact/1'
        $record['kind'] = 'returned'
        $record['subject'] = $subject
        $record['session_id'] = 'pre-harness-migration'
        $record['at'] = $at
        $record['outcome'] = $outcome
        $record['findings'] = $findings
        $record['abstract'] = $abstract
        $record['body_file'] = $bodyFile
        $record['normalisation'] = @()

        $bodyJson = $record | ConvertTo-Json -Depth 20 -Compress
        $record['integrity'] = 'sha256:' + (Get-Sha256Hex $bodyJson)

        $jsonPath = Join-Path $DestDir "$subject.json"
        $fileJson = ($record | ConvertTo-Json -Depth 20) + "`n"
        [System.IO.File]::WriteAllText($jsonPath, $fileJson, $utf8NoBom)

        $migrated++
    } catch {
        $errorsList.Add("$($f.Name): $($_.Exception.Message)")
    }
}

Write-Host "Migrate-Verdicts: $migrated migrated ($fenceParsed fence-parsed, $fallbackParsed fallback-parsed), $($errorsList.Count) error(s)."
if ($errorsList.Count -gt 0) {
    foreach ($e in $errorsList) { Write-Host "  ERROR: $e" }
    exit 1
}
exit 0
