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

function ConvertTo-PortablePaths {
    # Rewrite operator-environment paths to portable placeholders BEFORE hashing.
    #
    # This is normalisation, not curation. The record is what happened - findings,
    # verdicts, wrong calls, rejected work. An operator's home directory is not a
    # finding; it is an accident of where a file happened to sit, and it is the one
    # thing in these artifacts a stranger cannot use. Law 7 wants "<repo>/docs/..."
    # because that is reproducible on their machine; the absolute path is noise that
    # also happens to publish a username to a public repo.
    #
    # Portability and honesty point the same way here, so nothing is traded. What
    # would be curation - softening a finding, dropping a Major, flattering a verdict -
    # is exactly what the north star forbids and is untouched by this.
    #
    # Three properties keep it honest:
    #   1. It runs BEFORE hashing, so it is part of writing the record, not editing a
    #      record already written. Applied afterwards it would be tampering, and the
    #      integrity line would (correctly) refuse it.
    #   2. The rules are mechanical, narrow, and declared in the landed file, so a
    #      reader knows exactly what was substituted and can reason about it.
    #   3. Entire's checkpoint branch keeps the UN-normalised original. Nothing is
    #      destroyed; the raw text is one git grep away.
    #
    # Deliberately narrow: only known environment roots, longest-first. Aggressive
    # substitution would mangle a finding that is legitimately ABOUT a path.
    param([string]$Text)

    $repoRoot = (git rev-parse --show-toplevel 2>$null)
    if ($LASTEXITCODE -ne 0) { $repoRoot = '' }
    if ($repoRoot) { $repoRoot = $repoRoot.Replace('/', '\') }

    $rules = @()
    if ($repoRoot) { $rules += @{ From = $repoRoot; To = '<repo>' } }
    if ($env:USERPROFILE) { $rules += @{ From = $env:USERPROFILE; To = '~' } }

    # Longest first, so the repo root inside a home directory wins over the home rule.
    $rules = $rules | Sort-Object { $_.From.Length } -Descending

    foreach ($rule in $rules) {
        $from = $rule.From
        $to = $rule.To
        # Plain form, and the doubled-backslash form that appears wherever the text
        # quotes JSON or a shell string.
        $Text = $Text.Replace($from, $to)
        $Text = $Text.Replace($from.Replace('\', '\\'), $to)
        $Text = $Text.Replace($from.Replace('\', '/'), $to)
    }
    return $Text
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
$bodyRaw = $body
$body = ConvertTo-PortablePaths -Text $body
$normalised = ($body -ne $bodyRaw)

# --- refuse to clobber silently ----------------------------------------------
if ((Test-Path $Out) -and (-not $Force)) {
    Write-Error "$Out already exists. A landed verdict is a record, not a draft -- pass -Force only when replacing a hand-written stand-in with the extracted original."
    exit 1
}

$roundLine = ''
if ($Round) { $roundLine = "Round: $Round" }

# PROVENANCE AS CITATION.
#
# The owner's frame: treat Entire provenance the way an academic paper treats its
# sources. That standard is higher than "add a link" - "see Smith 2019" is bad
# practice, "Smith 2019, p. 47" is a citation. A reference must land a reader ON the
# passage, or we have rebuilt persisted-but-unfindable with better manners.
#
# So the citation identifies the work (the Entire session), the exact locator within
# it (the dispatch id), and the edition (the base commit the reviewer read), and it
# gives the literal commands to follow the reference. Anyone can check that this
# artifact says what its source said - which is the point of a citation, and the only
# defence that actually constrains whoever controls this script.
$sessionId = [System.IO.Path]::GetFileNameWithoutExtension($path)

# Resolve the Entire checkpoint that covers the base commit, so the citation names a
# precise location rather than gesturing at a session.
#
# The first version cited the session UUID. It was DEAD ON ARRIVAL - `entire checkpoint
# explain <session-uuid>` answers "no checkpoint or commit found". Caught only because
# the citation was actually followed before landing, which is the whole standard this
# frame imposes: a reference nobody tried is a reference nobody can trust, and this
# repo calls a dead citation a finding.
#
# Note: `entire` exits non-zero even on success here, so success is judged on output.
$checkpointId = ''
$explain = (entire checkpoint explain $Base 2>&1 | Out-String)
if ($explain -match 'Checkpoint\s+([0-9a-f]{8,})') { $checkpointId = $Matches[1] }

$checkpointRow = ''
if ($checkpointId) { $checkpointRow = "| Entire checkpoint | ``$checkpointId`` |" }

$provenance = @"
## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | ``$Base`` |
$checkpointRow
| Dispatch, the locator within the session | ``$TaskId`` |
| Entire session (context, NOT a lookup key) | ``$sessionId`` |
| Landed by | ``scripts/Land-Verdict.ps1`` - verbatim extraction, never retyped |

Follow the citation:

``````
entire checkpoint explain $Base
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
``````
"@

$normalisedNote = 'none applied (the body contained no operator-environment paths).'
if ($normalised) {
    $normalisedNote = 'the repository root was rewritten to ``<repo>`` and the operator home directory to ``~``, BEFORE hashing. Mechanical and narrow: only those two roots, longest-first, no other substitution. This is portability, not curation - findings, verdicts and counts are untouched, and the un-normalised original is on the Entire checkpoint branch.'
}

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
>
> Path normalisation: $normalisedNote
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
$document = ($header + "`n`n" + $provenance + $separator + $body).Replace("`r`n", "`n")
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
