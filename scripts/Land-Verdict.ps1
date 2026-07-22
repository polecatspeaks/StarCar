# Land-Verdict.ps1 -- extract a dispatched agent's verdict VERBATIM from the session
# transcript and land it in docs/reviews/.
#
# WHY THIS EXISTS (the class, not the instance):
#
# A dispatch's output is ephemeral by default. The verdict lives in a session
# transcript nobody reads, and the only thing standing between an artifact and
# oblivion is the conductor remembering to copy it out -- which is VIGILANCE, the
# weakest tier in the Healing Loop's hierarchy, below even a written procedure.
#
# Entire.io already solves DURABILITY: every session is checkpointed to a public
# branch. What it does not solve is ADDRESSABILITY. A verdict buried in a
# multi-megabyte JSONL is safe and unusable, while README.md promises "review
# verdicts and REJECT records committed in-repo as they happen" -- a promise a
# reader cannot navigate to. Persisted-but-unfindable is not kept.
#
# And the obvious manual fix is worse than the gap. On 2026-07-22 the conductor
# began hand-transcribing a review verdict about its OWN design into docs/reviews/.
# That is a hand-maintained mirror at a process boundary -- the exact scar class in
# CLAUDE.md -- with the aggravating factor that the author being reviewed was doing
# the copying. A softened phrase or a dropped finding would be undetectable.
# VERBATIM-BY-CONSTRUCTION BEATS VERBATIM-BY-DISCIPLINE.
#
# So: this script reads the transcript, the conductor never retypes, and the landed
# file carries a SHA-256 of its own body so the verbatim claim is checkable rather
# than asserted.
#
# SOURCES, in preference order:
#   1. The live Claude Code session transcript (current, includes this turn).
#   2. An Entire.io checkpoint blob on entire/checkpoints/v1 (durable, may lag one
#      checkpoint behind).
#
# Usage:
#   scripts/Land-Verdict.ps1 -TaskId <id> -Out docs/reviews/<file>.md `
#       -Title '...' -Gate '...' -Target '...' -Base <sha> -Verdict 'REJECT' [-Round 2]
#
# Windows PowerShell 5.1 compatible: no ternary, no &&/||, ASCII only.

param(
    [Parameter(Mandatory)] [string]$TaskId,
    [Parameter(Mandatory)] [string]$Out,
    [Parameter(Mandatory)] [string]$Title,
    [Parameter(Mandatory)] [string]$Gate,
    [Parameter(Mandatory)] [string]$Target,
    [Parameter(Mandatory)] [string]$Base,
    [Parameter(Mandatory)] [string]$Verdict,
    [string]$Round = '',
    [string]$Reviewer = 'car agent type, Opus, read-only, detached worktree, no delegation',
    [string]$TranscriptPath = '',
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-LiveTranscriptPath {
    # Claude Code stores one JSONL per session under the per-project directory.
    # Newest wins: a conductor lands verdicts from the session that produced them.
    $dir = Join-Path $env:USERPROFILE '.claude\projects\C--Users-Chris-git-starcar'
    if (-not (Test-Path $dir)) { return '' }
    $f = Get-ChildItem $dir -Filter *.jsonl -ErrorAction SilentlyContinue |
         Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $f) { return '' }
    return $f.FullName
}

function Get-TranscriptLines {
    param([string]$Path)
    # -Encoding UTF8 is load-bearing, not decoration. PowerShell 5.1's Get-Content
    # defaults to the system ANSI codepage, which silently mangles every non-ASCII
    # character in the transcript (a section sign becomes two characters). That makes
    # the word VERBATIM in this file's own header false, quietly, in a way only the
    # SHA-256 would ever expose. Caught on this script's first real run.
    if ($Path -and (Test-Path $Path)) { return Get-Content $Path -Encoding UTF8 }
    throw "No readable transcript. Pass -TranscriptPath, or land from an Entire checkpoint blob with: git show entire/checkpoints/v1:<path>/transcript.jsonl"
}

function Get-ResultBlockForTask {
    # A completed dispatch arrives as a task-notification carrying <task-id> and a
    # <result> block. Matching on the task id rather than on a phrase keeps this
    # deterministic -- a phrase can appear in the conductor's own commentary, a task
    # id cannot.
    param([string[]]$Lines, [string]$Id)

    $found = @()
    foreach ($line in $Lines) {
        if (-not $line) { continue }
        if ($line -notmatch [regex]::Escape($Id)) { continue }
        if ($line -notmatch '<result>') { continue }

        $obj = $null
        try { $obj = $line | ConvertFrom-Json } catch { continue }
        if (-not $obj.PSObject.Properties.Name.Contains('content')) { continue }

        $text = ''
        if ($obj.content -is [string]) {
            $text = $obj.content
        } else {
            foreach ($item in $obj.content) {
                if ($item.PSObject.Properties.Name -contains 'text') { $text = $text + $item.text }
            }
        }
        if (-not $text) { continue }
        if ($text -notmatch [regex]::Escape("<task-id>$Id</task-id>")) { continue }

        $s = $text.IndexOf('<result>')
        $e = $text.IndexOf('</result>')
        if ($s -lt 0 -or $e -lt $s) { continue }
        $found += $text.Substring($s + 8, $e - $s - 8)
    }

    if ($found.Count -eq 0) { throw "No <result> block found for task id '$Id'. A dispatch that never completed has no verdict to land." }
    # A task-id can notify more than once (an agent resumed by SendMessage). The LAST
    # result is the current one; landing an earlier one would publish a superseded verdict.
    return $found[$found.Count - 1]
}

function Get-Sha256 {
    param([string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $hash = $sha.ComputeHash($bytes)
    $sha.Dispose()
    return ([System.BitConverter]::ToString($hash) -replace '-', '').ToLower()
}

# --- resolve source -----------------------------------------------------------
$path = $TranscriptPath
if (-not $path) { $path = Get-LiveTranscriptPath }
$lines = Get-TranscriptLines -Path $path

$body = Get-ResultBlockForTask -Lines $lines -Id $TaskId
# Normalise to LF BEFORE hashing, and write the same bytes we hashed. PowerShell 5.1's
# Set-Content -Encoding utf8 adds a BOM and rewrites LF to CRLF, so the first version of
# this script hashed one string and wrote a different one -- every landed file failed its
# own verifier on the first run. The hash must cover exactly what lands on disk.
$body = $body.Replace("`r`n", "`n").Trim()

# --- refuse to clobber silently ----------------------------------------------
if ((Test-Path $Out) -and (-not $Force)) {
    Write-Error "$Out already exists. A landed verdict is a record, not a draft -- pass -Force only when replacing a hand-written stand-in with the extracted original."
    exit 1
}

$roundLine = ''
if ($Round) { $roundLine = "Round: $Round" }

$header = @"
# $Title

Status: Verdict of record
Gate: $Gate
$roundLine
Target: ``$Target``
Base reviewed: ``$Base``
Reviewer: $Reviewer
**Verdict: $Verdict**

> Extracted VERBATIM from the session transcript by ``scripts/Land-Verdict.ps1`` --
> task id ``$TaskId``. The conductor did not retype a word of what follows. Verbatim by
> construction rather than by discipline, because the author being reviewed is the
> one landing the review, and a hand-copied verdict is a hand-maintained mirror at a
> process boundary.
>
> Integrity: the ``starcar-integrity`` line at the top of this file hashes EVERY byte
> below it - this header's claims as well as the verbatim body. Recompute with
> ``scripts/Verify-Verdict.ps1 -Path <this file>``. An independently-written copy of the
> same body exists on the Entire checkpoint branch; that copy, not the hash, is the
> defence against whoever controls this script.
"@

# An explicit, collision-proof separator. The first version used a markdown rule, and
# review verdicts are full of markdown rules -- so the verifier cut at the first rule
# INSIDE the body and hashed a fragment that did not even contain the verdict line. A
# tampered copy then hashed identically to the original: the checker reported failure
# on good files and could not detect a REJECT flipped to APPROVE. Separators that can
# appear in the payload are not separators.
$separator = "`n<!-- verbatim-body-below: do not edit past this line -->`n`n"

$outDir = Split-Path $Out -Parent
if ($outDir -and (-not (Test-Path $outDir))) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

# INTEGRITY COVERS THE WHOLE DOCUMENT, not just the body.
#
# The first version hashed only the verbatim body, on the theory that the body is
# what must not be altered. An adversarial reviewer fault-injected it: change the
# HEADER from "REJECT - 8 Major" to "APPROVE - 0 Major", leave the body untouched,
# and the verifier reported OK with exit 0. A file asserting APPROVE over a body
# arguing REJECT passed its own integrity check.
#
# That is the worst shape a guard can have here: the header is what a reader skims
# and what a generated index consumes, so the hash protected the text nobody reads
# and left the claim everyone reads unprotected. Law 6 - the header was a second copy
# of the body's verdict with nothing checking they agree.
#
# Now the hash covers everything after the integrity line itself, so the only edit it
# cannot detect is a deliberate re-stamp. That is not a gap this mechanism can close:
# the conductor owns the producer, the hash function and the verifier. The real
# defence against a determined conductor is PUBLICATION - Entire's checkpoint branch
# holds an independently-written copy of the same body - and the hash's honest job is
# detecting accident and drift, which this repo has already hit three times.
$document = ($header + $separator + $body).Replace("`r`n", "`n")
$hash = Get-Sha256 -Text $document
$integrityLine = "<!-- starcar-integrity: sha256=$hash covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Join-Path (Get-Location) $Out), ($integrityLine + $document), $utf8NoBom)

Write-Host "Landed $Out"
Write-Host "  task id : $TaskId"
Write-Host "  source  : $path"
Write-Host "  verdict : $Verdict"
Write-Host "  body    : $($body.Length) chars, sha256 $hash"
exit 0
