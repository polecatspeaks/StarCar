#requires -Version 7.4
# New-ArtifactIndex.ps1 -- deterministic index generator implementing the contract
# schema/index-format.md defines (columns, sort order, field order). The generator
# IMPLEMENTS that contract; it does not define one (Law 6 - one owner per contract).
#
# Deterministic by construction: same store in, byte-identical bytes out. LF line
# endings and UTF-8 with no BOM, matching Land-Verdict.ps1's landed WriteAllText
# precedent (scripts/Land-Verdict.ps1:317-321, structural - opened at base) -- the same
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
    $obj = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
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
# ties left to break arbitrarily.
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
