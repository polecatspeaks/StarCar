#requires -Version 7.4
# Produce-Artifact.ps1 -- the ONE writer (spec S2, design P1). A Claude Code hook pipes a
# payload on stdin; this script writes exactly one artifact record and commits ONLY that
# record's path. Reconciliation (the detector) only ever raises; a human backfilling is
# this same single writer acting deliberately.
#
# TWO PAYLOADS, ONE SUBJECT (Probe 5, measured): a PostToolUse:Task launch payload carries
# tool_response.agentId; a SubagentStop payload carries agent_id; for the same dispatch the
# two are IDENTICAL, so `subject` holds end to end across both hooks without any remembered
# state.
#
# LATENCY (Probe 2, BINDING): a slow SubagentStop hook blocks the dispatch's return path
# for its full runtime. The synchronous work here is one file write plus one pathspec-
# scoped commit with a capped retry - nothing slower. A failure is RAISED (nonzero exit +
# one line in the store's _faults.log), never dropped (Law 4).
#
# ENTANGLEMENT (C2R1-M2): the commit is `git commit --only -- <path>`, NOT a bare
# `git add` + `git commit`. A bare commit serializes the whole index and would sweep the
# conductor's co-staged files into a harness commit; --only scopes the commit to the
# pathspec regardless of index state. Never `-a`, never push.
#
# stdin is read via $input, which is populated identically whether the hook pipes OS stdin
# to `pwsh -File` or a caller pipes an object in-process (both measured).

# NOTE: this is a SIMPLE script, deliberately NOT advanced - no [Parameter()],
# [CmdletBinding()] or [ValidateSet()] attributes. Any of those turns the script into an
# advanced/cmdlet-bound script, and then the top-level $input pipeline enumerator is empty
# (pipeline input on an advanced script is only reachable inside a process{} block). The
# hook feeds the payload on stdin, which reaches a simple script through $input, so $Kind
# is validated by hand below instead.
param(
    [string]$Kind,
    [string]$StoreRoot = 'artifacts',
    [string]$Now = ''
)

# Capture stdin FIRST. $input is a live pipeline enumerator that any intervening command
# (Import-Module, a function definition) would consume, leaving a later read empty. Read
# it here, before anything else runs, then use the captured copy.
$StdinRaw = @($input) -join "`n"

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($Kind -ne 'dispatched' -and $Kind -ne 'returned') {
    Write-Error "Produce-Artifact: -Kind must be 'dispatched' or 'returned', got '$Kind'"
    exit 2
}

Import-Module (Join-Path $PSScriptRoot 'Envelope.psm1') -Force

# --- helpers ------------------------------------------------------------------

function Get-Prop {
    # StrictMode-safe property read: a payload key that is absent must read as $null, not
    # throw (Board.psm1's Get-PropertyOrNull precedent).
    param([object]$Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $p = $Object.PSObject.Properties[$Name]
    if ($null -eq $p) { return $null }
    return $p.Value
}

function Get-Sha256Hex {
    param([string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
    $hash = $sha.ComputeHash($bytes)
    $sha.Dispose()
    ([System.BitConverter]::ToString($hash) -replace '-', '').ToLower()
}

function Convert-PortablePath {
    # Rewrite operator-environment roots to portable placeholders BEFORE hashing, exactly
    # the class Land-Verdict.ps1's ConvertTo-PortablePaths established and
    # schema/index-format.md:60-72 declares (repo root -> <repo>, home -> ~,
    # longest-first). Returns the rewritten text
    # plus the list of from_class values that actually fired, so the record can DECLARE
    # each substitution it applied (schema `normalisation`; empty array means none).
    param([string]$Text, [string]$RepoRoot, [string]$HomeDir)

    $applied = New-Object System.Collections.Generic.List[string]
    if ([string]::IsNullOrEmpty($Text)) {
        return [pscustomobject]@{ Text = $Text; Applied = @($applied) }
    }

    $rules = @()
    if ($RepoRoot) { $rules += @{ Class = 'repo-root'; From = $RepoRoot; To = '<repo>' } }
    if ($HomeDir)  { $rules += @{ Class = 'home';      From = $HomeDir;  To = '~' } }
    # Longest first, so a repo root nested inside a home directory wins over the home rule.
    $rules = $rules | Sort-Object { $_.From.Length } -Descending

    foreach ($rule in $rules) {
        $from = $rule.From
        $before = $Text
        # Plain form, the doubled-backslash form (JSON/shell quoting), the forward-slash form.
        $Text = $Text.Replace($from, $rule.To)
        $Text = $Text.Replace($from.Replace('\', '\\'), $rule.To)
        $Text = $Text.Replace($from.Replace('\', '/'), $rule.To)
        if ($Text -ne $before) { $applied.Add($rule.Class) }
    }
    return [pscustomobject]@{ Text = $Text; Applied = @($applied) }
}

# --- read + parse the payload -------------------------------------------------

$raw = $StdinRaw

$storeAbs = [System.IO.Path]::GetFullPath($StoreRoot)
$faultsLog = Join-Path $storeAbs '_faults.log'

function Add-Fault {
    param([string]$Message)
    try {
        if (-not (Test-Path $storeAbs)) { New-Item -ItemType Directory -Path $storeAbs -Force | Out-Null }
        $stamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
        Add-Content -Path $faultsLog -Value "$stamp`t$Kind`t$Message" -Encoding utf8
    } catch {
        # The store is unwritable; there is nowhere left to raise but the exit code.
    }
}

try {
    if ([string]::IsNullOrWhiteSpace($raw)) { throw 'empty payload on stdin' }
    $payload = $raw | ConvertFrom-Json

    # --- filter (spec S2.2): agent_type for stop, subagent_type for launch --------------
    if ($Kind -eq 'returned') {
        $agentType = Get-Prop $payload 'agent_type'
        if ([string]::IsNullOrWhiteSpace($agentType)) { exit 0 }   # internal subagent: no record
        $subject = Get-Prop $payload 'agent_id'
    } else {
        $toolInput = Get-Prop $payload 'tool_input'
        $subagentType = Get-Prop $toolInput 'subagent_type'
        if ([string]::IsNullOrWhiteSpace($subagentType)) { exit 0 } # internal subagent: no record
        $toolResponse = Get-Prop $payload 'tool_response'
        $subject = Get-Prop $toolResponse 'agentId'
    }

    if ([string]::IsNullOrWhiteSpace($subject)) { throw "no subject id in the $Kind payload" }
    $sessionId = Get-Prop $payload 'session_id'
    if ([string]::IsNullOrWhiteSpace($sessionId)) { throw "no session_id in the $Kind payload" }

    $at = if ($Now) { $Now } else { (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') }

    # --- returned: obtain the outcome from the transcript envelope (spec S2.3) -----------
    $outcome = $null; $findings = $null; $abstract = $null; $envFault = $null; $model = $null
    if ($Kind -eq 'returned') {
        $transcriptPath = Get-Prop $payload 'agent_transcript_path'
        $rawText = $null
        if (-not [string]::IsNullOrWhiteSpace($transcriptPath)) {
            $rawText = (Get-LastAssistantText -TranscriptPath $transcriptPath).Text
        }
        $env = if ($rawText) { Get-StarcarEnvelope -Text $rawText } else {
            [pscustomobject]@{ Found = $false; Outcome = $null; Findings = $null; Abstract = $null; Fault = 'absent' }
        }
        if ($env.Found) {
            $outcome = $env.Outcome; $findings = $env.Findings; $abstract = $env.Abstract
        } else {
            # Absent (brief failure) and malformed (producer failure) are different faults;
            # both land with the body intact (spec S2.3). The raw report is retained in
            # findings so nothing is silently lost (Law 4).
            $envFault = if ($env.Fault -eq 'malformed') { 'malformed' } else { 'absent' }
            $outcome  = 'error'
            $findings = if ($rawText) { $rawText } else { '' }
            $abstract = "envelope $envFault - raw report retained in findings"
        }
    } else {
        # dispatched: producer-optional metadata under the schema's open posture (same
        # Law-7 class as `producer`). The board's model-mix rendering consumes it.
        $toolResponse = Get-Prop $payload 'tool_response'
        $model = Get-Prop $toolResponse 'resolvedModel'
    }

    # --- normalisation applied to every string field, declared per what fired -----------
    $repoRoot = ''
    if (-not (Test-Path $storeAbs)) { New-Item -ItemType Directory -Path $storeAbs -Force | Out-Null }
    $repoRoot = (git -C $storeAbs rev-parse --show-toplevel 2>$null)
    if ($LASTEXITCODE -ne 0) { $repoRoot = '' }
    if ($repoRoot) { $repoRoot = ([System.IO.Path]::GetFullPath($repoRoot.Trim())) }
    $homeDir = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }

    $appliedClasses = New-Object System.Collections.Generic.List[string]
    function Portable {
        param([string]$Value)
        if ($null -eq $Value) { return $null }
        $r = Convert-PortablePath -Text $Value -RepoRoot $repoRoot -HomeDir $homeDir
        foreach ($c in $r.Applied) { if (-not $appliedClasses.Contains($c)) { $appliedClasses.Add($c) } }
        return $r.Text
    }

    $subject   = Portable $subject
    $sessionId = Portable $sessionId
    if ($null -ne $outcome)  { $outcome  = Portable $outcome }
    if ($null -ne $findings) { $findings = Portable $findings }
    if ($null -ne $abstract) { $abstract = Portable $abstract }
    if ($null -ne $model)    { $model    = Portable $model }

    $normalisation = @()
    foreach ($c in $appliedClasses) {
        $to = if ($c -eq 'repo-root') { '<repo>' } else { '~' }
        $normalisation += [ordered]@{ from_class = $c; to = $to }
    }

    # --- assemble the record in canonical order (schema/index-format.md:17-20) -----------
    # `model` is an open-posture extra (not in the schema's closed field list); it is
    # positioned with `producer`, the adjacent Law-7 producer-metadata field. MARKED
    # DEVIATION: index-format.md's canonical order does not enumerate `model`; placing it
    # immediately before `producer` is this producer's deterministic choice, disclosed
    # rather than assumed. It does not affect the index (New-ArtifactIndex derives columns
    # from subject/kind/at/outcome/file, never model).
    $record = [ordered]@{}
    $record['schema']     = 'starcar-artifact/1'
    $record['kind']       = $Kind
    $record['subject']    = $subject
    $record['session_id'] = $sessionId
    $record['at']         = $at
    if ($Kind -eq 'returned') {
        $record['outcome']  = $outcome
        $record['findings'] = $findings
        $record['abstract'] = $abstract
        if ($envFault) { $record['envelope'] = $envFault }
    }
    if ($Kind -eq 'dispatched' -and $model) { $record['model'] = $model }
    $record['producer']      = 'starcar-hook/1'
    $record['normalisation'] = @($normalisation)

    # integrity is sha256 over the canonical body (every field above, in order, compact).
    $bodyJson = $record | ConvertTo-Json -Depth 20 -Compress
    $record['integrity'] = 'sha256:' + (Get-Sha256Hex $bodyJson)

    # --- write to the R4 path: <store>/<subject>/<kind>-<compact-at>.json ----------------
    $compactAt = $at -replace '[-:]', ''
    $subjectDir = Join-Path $storeAbs $subject
    if (-not (Test-Path $subjectDir)) { New-Item -ItemType Directory -Path $subjectDir -Force | Out-Null }
    $recordPath = Join-Path $subjectDir "$Kind-$compactAt.json"

    $fileJson = ($record | ConvertTo-Json -Depth 20) + "`n"
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($recordPath, $fileJson, $utf8NoBom)

    # --- commit ONLY this path, with a capped retry on index contention ------------------
    if (-not $repoRoot) { throw "store is not inside a git repository: $storeAbs" }
    $relPath = [System.IO.Path]::GetRelativePath($repoRoot, $recordPath).Replace('\', '/')

    $committed = $false
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        git -C $repoRoot add -- $relPath 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) { Start-Sleep -Milliseconds (50 * $attempt); continue }
        # -m must precede the `--`: everything after `--` is a pathspec, so `-m msg` there
        # would be read as two bogus pathspecs (measured).
        git -C $repoRoot commit --only -m "harness: $Kind record for $subject" -- $relPath 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $committed = $true; break }
        Start-Sleep -Milliseconds (50 * $attempt)
    }
    if (-not $committed) { throw "could not commit $relPath after 3 attempts (index contention?)" }

    exit 0
}
catch {
    Add-Fault -Message $_.Exception.Message
    Write-Error "Produce-Artifact failed: $($_.Exception.Message)"
    exit 1
}
