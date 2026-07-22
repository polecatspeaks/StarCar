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
#   scripts/Verify-Verdict.ps1 -Path artifacts/reviews/<file>.md
#   scripts/Verify-Verdict.ps1            # verifies every file in artifacts/reviews/
#
# Exit 0 if every checked file matches; 1 if any mismatch or unparseable header, an
# absent -ReviewsDir, or a -ReviewsDir with zero verdict files (spec amendment S1: both
# were vacuous exit-0 or an unactionable crash before Car 1 task A.3 -- an absent store
# and an empty store are failures to verify, never a pass with nothing checked).
#
# DEFAULT REPOINTED (Car 3, conductor ruling R9v2, harness #7's migration commit): the
# store moved from docs/reviews/ to artifacts/reviews/, which holds ONLY integrity-headed
# .md bodies (sibling starcar-artifact/1 .json records live alongside them, never a .md
# themselves) and needs NO recursion. This directory NEVER globs artifacts/index.md,
# because index.md lives one level up at the store ROOT (artifacts/), not inside
# artifacts/reviews/ -- the round-1 reviewer proved a recursive default choked on exactly
# that headerless file (Get-ChildItem -Recurse from `artifacts` would reach it); the fix
# is this directory boundary, not a filter added on top of one that reaches too far.
#
# Windows PowerShell 5.1 compatible: no ternary, no &&/||, ASCII only.

param(
    [string]$Path = '',
    [string]$ReviewsDir = 'artifacts/reviews'
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

    # The integrity line is the FIRST line and covers every byte after it - header
    # claims included. The first version of this checker hashed only the verbatim body,
    # and an adversarial reviewer flipped a header from "REJECT - 8 Major" to
    # "APPROVE - 0 Major" and got exit 0. The hash was protecting the text nobody skims
    # and leaving the claim everyone skims unprotected.
    $nl = $raw.IndexOf("`n")
    if ($nl -lt 0) {
        Write-Host "UNPARSEABLE  $File (no integrity line)"
        return $false
    }
    $first = $raw.Substring(0, $nl)
    $rest = $raw.Substring($nl + 1)

    if ($first -notmatch 'starcar-integrity: sha256=([0-9a-f]{64})') {
        Write-Host "NO INTEGRITY $File (first line is not a starcar-integrity line)"
        return $false
    }
    $claimed = $Matches[1]
    $actual = Get-Sha256 -Text $rest

    if ($claimed -eq $actual) {
        Write-Host "OK           $File"
        return $true
    }

    Write-Host "MISMATCH     $File"
    Write-Host "  claimed: $claimed"
    Write-Host "  actual : $actual"
    Write-Host "  This file changed after it was landed - header claims, verbatim body, or"
    Write-Host "  both. Either it was edited, or it was not landed by Land-Verdict.ps1."
    Write-Host "  Compare against the Entire checkpoint branch, which holds an"
    Write-Host "  independently-written copy: git grep <a distinctive phrase> entire/checkpoints/v1"
    return $false
}

$files = @()
if ($Path) {
    $files = @($Path)
} else {
    if (-not (Test-Path $ReviewsDir)) {
        Write-Error "$ReviewsDir does not exist. Nothing was verified -- an absent verdict store is a failure, not a vacuous pass."
        exit 1
    }
    # @(...) forces an array even when Get-ChildItem's pipeline returns nothing, so
    # $files.Count below is always a valid property read, never a StrictMode crash on
    # $null (the real defect this task retires -- see the header comment).
    $files = @(Get-ChildItem $ReviewsDir -Filter *.md | ForEach-Object { $_.FullName })
}

if ($files.Count -eq 0) {
    Write-Error "$ReviewsDir contains zero verdict files. Nothing was verified -- an empty store is a failure, not a vacuous pass."
    exit 1
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
