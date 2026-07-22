# Verify-Verdict.ps1 -- recompute a landed verdict's body hash and compare it to the
# hash its own header claims.
#
# WHY: Land-Verdict.ps1 stamps a SHA-256 of the verbatim body into the header. A hash
# nobody can check is decoration, and this repo's rule is that a guard is unproven
# until someone has watched it fire. This is the checker, and it exists so the
# "extracted verbatim, not retyped" claim on every file in docs/reviews/ is testable
# rather than asserted.
#
# It answers exactly one question: has the body been edited since it was landed?
# Editing a verdict of record is not a formatting choice -- a review verdict is the
# other party's words, and the party landing it is the party being reviewed.
#
# Usage:
#   scripts/Verify-Verdict.ps1 -Path docs/reviews/<file>.md
#   scripts/Verify-Verdict.ps1            # verifies every file in docs/reviews/
#
# Exit 0 if every checked file matches; 1 if any mismatch or unparseable header.
#
# Windows PowerShell 5.1 compatible: no ternary, no &&/||, ASCII only.

param(
    [string]$Path = '',
    [string]$ReviewsDir = 'docs/reviews'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-Sha256 {
    param([string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $hash = $sha.ComputeHash($bytes)
    $sha.Dispose()
    return ([System.BitConverter]::ToString($hash) -replace '-', '').ToLower()
}

function Test-OneVerdict {
    param([string]$File)

    # Normalise line endings before anything else. Git's autocrlf, an editor, or a
    # PowerShell write can all convert LF to CRLF in transit; hashing the raw bytes
    # would then report tampering on a file nobody touched, and a checker that cries
    # wolf poisons everything downstream of it.
    $raw = [System.IO.File]::ReadAllText($File).Replace("`r`n", "`n")

    # An explicit separator that cannot occur in a markdown payload. A horizontal rule
    # was tried first and failed: verdicts are full of rules, so the split landed inside
    # the body and the hash covered a fragment.
    $marker = "`n<!-- verbatim-body-below: do not edit past this line -->`n`n"
    $idx = $raw.IndexOf($marker)
    if ($idx -lt 0) {
        Write-Host "UNPARSEABLE  $File (no header/body separator)"
        return $false
    }

    $header = $raw.Substring(0, $idx)
    $body = $raw.Substring($idx + $marker.Length).Trim()

    if ($header -notmatch 'Body SHA-256: `([0-9a-f]{64})`') {
        Write-Host "NO HASH      $File (header claims no hash)"
        return $false
    }
    $claimed = $Matches[1]
    $actual = Get-Sha256 -Text $body

    if ($claimed -eq $actual) {
        Write-Host "OK           $File"
        return $true
    }

    Write-Host "MISMATCH     $File"
    Write-Host "  claimed: $claimed"
    Write-Host "  actual : $actual"
    Write-Host "  The landed body no longer matches what was extracted. Either it was"
    Write-Host "  edited after landing, or it was not landed by Land-Verdict.ps1."
    return $false
}

$files = @()
if ($Path) {
    $files = @($Path)
} else {
    if (-not (Test-Path $ReviewsDir)) {
        Write-Host "No $ReviewsDir directory. Nothing to verify."
        exit 0
    }
    $files = Get-ChildItem $ReviewsDir -Filter *.md | ForEach-Object { $_.FullName }
}

if ($files.Count -eq 0) {
    Write-Host "No verdict files found. Nothing to verify."
    exit 0
}

$allOk = $true
foreach ($f in $files) {
    $ok = Test-OneVerdict -File $f
    if (-not $ok) { $allOk = $false }
}

if ($allOk) {
    Write-Host ""
    Write-Host "$($files.Count) verdict file(s) verified: every body matches its claimed hash."
    exit 0
}
exit 1
