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
# regenerate-and-diff gate landing in Car 3. This script only generates; it never reads
# or compares against a previously committed copy.

param(
    [Parameter(Mandatory)] [string]$StoreRoot,
    [Parameter(Mandatory)] [string]$OutFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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
    # silently dropped - Law 4). -DateKind String keeps 'at' a plain string end to end.
    $obj = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json -DateKind String
    $relative = [System.IO.Path]::GetRelativePath($StoreRoot, $f.FullName).Replace('\', '/')

    $outcome = ''
    $outcomeProp = $obj.PSObject.Properties['outcome']
    if ($outcomeProp) { $outcome = [string]$outcomeProp.Value }

    [pscustomobject]@{
        Subject = [string]$obj.subject
        Kind    = [string]$obj.kind
        At      = [string]$obj.at
        Outcome = $outcome
        File    = $relative
    }
}

# Total order per schema/index-format.md: at, then subject, then file - there are never
# ties left to break arbitrarily. Sorting the plain ISO-8601 UTC string (fixed-width,
# zero-padded, most-significant field first) is a lexical sort that IS a chronological
# sort - that equivalence is why the contract chose this format (schema/index-format.md).
# It only holds because 'at' was never coerced to a culture-formatted string above.
$sorted = @($rows | Sort-Object -Property At, Subject, File)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('| subject | kind | at | outcome | file |')
$lines.Add('|---|---|---|---|---|')
foreach ($r in $sorted) {
    $lines.Add("| $($r.Subject) | $($r.Kind) | $($r.At) | $($r.Outcome) | $($r.File) |")
}

$content = ($lines -join "`n") + "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutFile, $content, $utf8NoBom)

Write-Host "Wrote $OutFile ($($sorted.Count) row(s))"
exit 0
