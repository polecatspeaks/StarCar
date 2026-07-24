#requires -Version 7.4
# New-ArtifactIndex.ps1 -- deterministic index generator implementing the contract
# schema/index-format.md defines (columns, sort order, field order). The generator
# IMPLEMENTS that contract; it does not define one (Law 6 - one owner per contract).
#
# Deterministic by construction: same store in, byte-identical bytes out. LF line
# endings and UTF-8 with no BOM, matching Land-Verdict.ps1's landed WriteAllText
# precedent (the WriteAllText with a BOM-free UTF8Encoding($false) in
# scripts/Land-Verdict.ps1, structural - opened at base) -- the same
# reasoning applies here: a hand-rolled Set-Content adds a BOM and rewrites LF to CRLF
# on Windows PowerShell, and a byte-identical claim has to cover exactly what a naive
# write would silently change.
#
# Stateless: spec S5.2 treats the committed index as derived state, with a CI
# regenerate-and-diff gate landing in Car 3, SCOPED to PR-to-main/push-to-main (#20,
# owner-ratified 2026-07-23) rather than every push - dev's copy may lag the store
# between regenerations, which is why the emitted header below declares that as a
# freshness contract instead of leaving it an undocumented (Law 1) gap. This script
# only generates; it never reads or compares against a previously committed copy.

param(
    [Parameter(Mandatory)] [string]$StoreRoot,
    [Parameter(Mandatory)] [string]$OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'Artifact.psm1') -Force

$files = @(Get-ChildItem -Path $StoreRoot -Filter *.json -Recurse -File)

$rows = foreach ($f in $files) {
    # -DateKind String is load-bearing, not decoration (reviewer finding M-A4-1,
    # measured present on this pwsh: (Get-Command ConvertFrom-Json).Parameters.Keys
    # -contains 'DateKind' -> True). Without it, ConvertFrom-Json auto-detects the
    # ISO-8601 'at' string and coerces it to [System.DateTime]; the invariant-culture
    # cast back to string then drops the 'Z'/'T' markers and produces a
    # MM/dd/yyyy HH:mm:ss form whose lexical sort is non-chronological across years
    # (schema/index-format.md:55-57's worked example, which this generator implements,
    # is otherwise a claim the code cannot produce - Law 1 - with the UTC marker
    # silently dropped - Law 4). -DateKind String keeps 'at' a plain string end to end;
    # the column renders the artifact's verbatim string regardless of how it sorts.
    $obj = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json -DateKind String
    $relative = [System.IO.Path]::GetRelativePath($StoreRoot, $f.FullName).Replace('\', '/')

    $outcome = ''
    $outcomeProp = $obj.PSObject.Properties['outcome']
    if ($outcomeProp) { $outcome = [string]$outcomeProp.Value }

    # F1 (docs/plans/2026-07-22-pr18-correctness-fixes-plan.md): parsed here, once per
    # record, so a bad 'at' is attributed to ITS file before the throw propagates -
    # never a silent mis-sort, never a whole-batch crash with no attribution.
    $instant = $null
    try {
        $instant = Get-AtInstant -At ([string]$obj.at)
    } catch {
        throw "New-ArtifactIndex: $($f.FullName): $($_.Exception.Message)"
    }

    [pscustomobject]@{
        Subject  = [string]$obj.subject
        Kind     = [string]$obj.kind
        At       = [string]$obj.at
        AtInstant = $instant
        Outcome  = $outcome
        File     = $relative
    }
}

# Total order per schema/index-format.md: at (normalized to a UTC INSTANT, offsets
# honored), then subject, then file - there are never ties left to break arbitrarily.
# The store carries mixed offsets (migrated verdicts' 'at' came from git authorship in
# local time, alongside Z-normalized producer output), so a LEXICAL sort of the 'at'
# string is chronological only when every record shares the same offset - which this
# store does not (F1, docs/plans/2026-07-22-pr18-correctness-fixes-plan.md). Sorting the
# parsed instant (Get-AtInstant, Artifact.psm1) is correct regardless of offset; the
# rendered 'At' column stays the artifact's verbatim string (above), only the SORT KEY
# changes.
$sorted = @($rows | Sort-Object -Property AtInstant, Subject, File)

# `subject`/`outcome` are open-vocabulary schema strings (no `enum`, no character
# restriction - schema/starcar-artifact.schema.json), so a schema-VALID value can carry a
# `|` (forges extra columns) or a raw newline (splits the row across physical lines) when
# interpolated raw into the table (F3, docs/plans/2026-07-22-pr18-correctness-fixes-plan.md).
# Escape BEFORE interpolation: `|` -> `\|`, and any newline (LF or CRLF) -> a single space.
function Format-IndexCell {
    param([string]$Value)
    if ([string]::IsNullOrEmpty($Value)) { return $Value }
    ($Value -replace '\|', '\|') -replace '\r?\n', ' '
}

$lines = New-Object System.Collections.Generic.List[string]

# Freshness-contract header (#20, schema/index-format.md): STATIC text, no
# timestamp/generated-at stamp - a run-varying header would break the byte-identical
# determinism contract (ArtifactIndex.Tests.ps1) that a CI regenerate-and-diff gate
# depends on. This is what makes dev's between-regeneration lag a documented refresh
# cadence rather than a lying surface (Law 1).
$lines.Add('# Artifact index')
$lines.Add('')
$lines.Add('Derived from the store (artifacts/**/*.json) by scripts/New-ArtifactIndex.ps1 - regenerate,')
$lines.Add('never hand-edit; the JSON records are the source of truth. Freshness contract (#20): this')
$lines.Add('file is gated fresh at PR-to-main and push-to-main; on dev it may lag the store by a')
$lines.Add('dispatch batch between regenerations.')
$lines.Add('')

$lines.Add('| subject | kind | at | outcome | file |')
$lines.Add('|---|---|---|---|---|')
foreach ($r in $sorted) {
    $subject = Format-IndexCell $r.Subject
    $kind    = Format-IndexCell $r.Kind
    $at      = Format-IndexCell $r.At
    $outcome = Format-IndexCell $r.Outcome
    $file    = Format-IndexCell $r.File
    $lines.Add("| $subject | $kind | $at | $outcome | $file |")
}

$content = ($lines -join "`n") + "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutFile, $content, $utf8NoBom)

Write-Host "Wrote $OutFile ($($sorted.Count) row(s))"
exit 0
