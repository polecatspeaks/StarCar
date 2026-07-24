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
#
# BUDGET STAMP (issue #22 item 1, owner's best-of-both ruling; C3R-1e, Car 3 fix cycle
# round 2): every NEW dispatched record is stamped with `budget` - the shop default
# (`config/harness-defaults.json`'s `dispatch_budget_seconds`, or `-DefaultsPath` when
# overridden) as it stands AT DISPATCH TIME. The promise freezes into history at
# departure: a later policy change to the shop default never rewrites an in-flight
# dispatch's liveness verdict retroactively (the value is copied into the record, not
# referenced). A brief-level ESTIMATED-patience override is deferred, disclosed rather
# than invented brittle: the real PostToolUse:Task launch payload carries no
# estimated-duration field in tool_input/tool_response to override from. A shop-default
# read failure degrades the record (no `budget` field, a fault raised) rather than
# blocking the write - the fold (`scripts/Detect-Dispatches.ps1`) applies its OWN default
# at FOLD time regardless, the same fallback the 49 existing budget-less fossil records
# already rely on (the legacy/foreign tail, untouched by this stamp).

# NOTE: this is a SIMPLE script, deliberately NOT advanced - no [Parameter()],
# [CmdletBinding()] or [ValidateSet()] attributes. Any of those turns the script into an
# advanced/cmdlet-bound script, and then the top-level $input pipeline enumerator is empty
# (pipeline input on an advanced script is only reachable inside a process{} block). The
# hook feeds the payload on stdin, which reaches a simple script through $input, so $Kind
# is validated by hand below instead.
param(
    [string]$Kind,
    [string]$StoreRoot = 'artifacts',
    [string]$Now = '',
    [string]$DefaultsPath = ''
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
Import-Module (Join-Path $PSScriptRoot 'Artifact.psm1') -Force

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

function Write-VisibleSkip {
    # #47 D3/D4 (Law 4, Law 1): an intake payload no adapter recognises is SKIPPED VISIBLY,
    # never silently. The three-hour "fully silent producer" misdiagnosis (superseded design
    # D2) happened because a filter miss exited 0 saying nothing. Naming the present keys on
    # stderr turns an invisible skip into an observable one, and names NO guessed subject.
    param([object]$Payload, [string]$Kind)
    $keys = @($Payload.PSObject.Properties.Name) -join ', '
    [Console]::Error.WriteLine("Produce-Artifact: $Kind payload not recognised by any adapter (no Claude agent_type/subagent_type, no Copilot compat agent_name/agent_type); NO record written. Keys present: $keys")
}

# Get-Sha256Hex is imported from Artifact.psm1 (F4, Law 6 - the one owner; was
# script-local here, duplicated in scripts/tests/Producer.Tests.ps1 and
# scripts/tests/Migration.Tests.ps1 as test-local copies of the same idiom, and now also
# consumed by scripts/tests/StoreIntegrity.Tests.ps1 from the shared module).

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

    # --- family-agnostic intake adapter (#47 D2/D4) ------------------------------------
    # ONE writer, per-runtime normalisation to one internal shape. Claude Code carries
    # agent_type (stop) / tool_input.subagent_type (launch) and a camelCase
    # tool_response.agentId; the Copilot CLI compat layer delivers snake_case with the
    # Task matcher mapped to its Agent tool - agent_name at stop, tool_input.agent_type +
    # tool_input.name at launch (superseded design section 3b, OBSERVED). `subject_basis`
    # DISCLOSES which family rule produced the subject: runtime-id (mode b, Claude's stable
    # pairing UUID) or minted-id (mode a, the shop id carried in the label/envelope).
    $subjectBasis = $null
    $runtime = $null
    $provenance = $null
    if ($Kind -eq 'returned') {
        $agentType = Get-Prop $payload 'agent_type'   # Claude stop
        $agentName = Get-Prop $payload 'agent_name'   # Copilot compat stop
        if (-not [string]::IsNullOrWhiteSpace($agentType)) {
            $runtime = 'claude'; $subjectBasis = 'runtime-id'
            $subject = Get-Prop $payload 'agent_id'   # mode (b): the runtime's stable pairing id
        } elseif (-not [string]::IsNullOrWhiteSpace($agentName)) {
            # Copilot mode (a): the compat stop payload carries no unique agent id (agent_name
            # is the agent TYPE, not a pairing key - superseded design 3b-5). The subject is
            # the shop-minted id, which arrives via the envelope task-id echo (#47 section
            # 5.7), resolved after the transcript read below. agent_name is kept as provenance.
            $runtime = 'copilot'; $subjectBasis = 'minted-id'
            $provenance = [ordered]@{ runtime = 'copilot'; agent_name = [string]$agentName }
            $subject = $null
        } else {
            Write-VisibleSkip -Payload $payload -Kind $Kind
            exit 0
        }
    } else {
        $toolInput = Get-Prop $payload 'tool_input'
        $subagentType    = Get-Prop $toolInput 'subagent_type'   # Claude launch
        $launchAgentType = Get-Prop $toolInput 'agent_type'      # Copilot compat launch
        if (-not [string]::IsNullOrWhiteSpace($subagentType)) {
            $runtime = 'claude'; $subjectBasis = 'runtime-id'
            $toolResponse = Get-Prop $payload 'tool_response'
            $subject = Get-Prop $toolResponse 'agentId'          # mode (b): runtime pairing id
        } elseif (-not [string]::IsNullOrWhiteSpace($launchAgentType)) {
            # Copilot mode (a): subject = the shop-minted id carried verbatim in
            # tool_input.name (superseded design 3b-8), never scraped from a runtime internal.
            $runtime = 'copilot'; $subjectBasis = 'minted-id'
            $subject = Get-Prop $toolInput 'name'
        } else {
            Write-VisibleSkip -Payload $payload -Kind $Kind
            exit 0
        }
    }

    # subject is validated now for every path EXCEPT Copilot returned, whose subject is
    # resolved from the envelope task-id after the transcript read (validated there).
    if (-not ($runtime -eq 'copilot' -and $Kind -eq 'returned')) {
        if ([string]::IsNullOrWhiteSpace($subject)) { throw "no subject id in the $Kind payload" }
    }
    $sessionId = Get-Prop $payload 'session_id'
    if ([string]::IsNullOrWhiteSpace($sessionId)) { throw "no session_id in the $Kind payload" }

    $at = if ($Now) { $Now } else { (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') }

    # --- returned: obtain the outcome from the transcript envelope (spec S2.3) -----------
    $outcome = $null; $findings = $null; $abstract = $null; $envFault = $null; $model = $null; $taskId = $null
    if ($Kind -eq 'returned') {
        # Claude carries agent_transcript_path; the Copilot compat stop payload carries
        # transcript_path (superseded design 3b-2/3b-7). One writer, both keys tolerated.
        $transcriptPath = Get-Prop $payload 'agent_transcript_path'
        if ([string]::IsNullOrWhiteSpace($transcriptPath)) { $transcriptPath = Get-Prop $payload 'transcript_path' }
        $rawText = $null
        $readErrors = @()
        if (-not [string]::IsNullOrWhiteSpace($transcriptPath)) {
            $readResult = Get-LastAssistantText -TranscriptPath $transcriptPath
            $rawText = $readResult.Text
            $readErrors = @($readResult.Errors)
        }

        if ($null -eq $rawText -and $readErrors.Count -gt 0) {
            # F5 (docs/plans/2026-07-22-pr18-correctness-fixes-plan.md): a transcript READ
            # FAILURE (not found / unreadable / unparseable - Get-LastAssistantText's own
            # three cases) is a PRODUCER fault, not a BRIEF failure - it never reached the
            # point of checking for a fence. Distinct from `envelope: absent` (brief
            # emitted no envelope): OMIT the `envelope` field entirely (absent-the-field
            # != the value 'absent'), classify outcome:error, and put the read error in
            # findings so it is never dropped (Law 4) - raised to _faults.log too. The
            # fault branch still sets `abstract` (schema requires it on `returned`
            # records; the producer does not self-validate before writing).
            $outcome  = 'error'
            $findings = ($readErrors -join '; ')
            $abstract = 'transcript read failure - see findings'
            foreach ($e in $readErrors) { Add-Fault -Message "transcript read failure: $e" }
        } else {
            $env = if ($rawText) { Get-StarcarEnvelope -Text $rawText } else {
                [pscustomobject]@{ Found = $false; Outcome = $null; Findings = $null; Abstract = $null; TaskId = $null; Fault = 'absent' }
            }
            # #47 section 5.7: the envelope may echo the shop-minted dispatch id as task-id.
            # OPTIONAL: its absence never faults the record (a car predating the echo mandate
            # still lands cleanly; the minted id simply does not round-trip).
            if ($env.PSObject.Properties['TaskId']) { $taskId = $env.TaskId }
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
        }

        # Copilot mode (a): the subject IS the minted id, which only the envelope task-id
        # carries (the compat stop payload has no pairing key). Resolve it now, then validate.
        if ($runtime -eq 'copilot' -and [string]::IsNullOrWhiteSpace($subject)) {
            if ([string]::IsNullOrWhiteSpace($taskId)) {
                throw "Copilot returned payload carries no envelope task-id to pair on (agent_name is a type, not a pairing key); no record written"
            }
            $subject = $taskId
        }
    } else {
        # dispatched: producer-optional metadata under the schema's open posture (same
        # Law-7 class as `producer`). The board's model-mix rendering consumes it.
        $toolResponse = Get-Prop $payload 'tool_response'
        $model = Get-Prop $toolResponse 'resolvedModel'

        # --- budget stamping (issue #22 item 1, owner's best-of-both ruling; C3R-1e) -------
        # "WRITE TIME: Produce-Artifact.ps1 stamps budget on every NEW dispatched record -
        # the ESTIMATED patience, brief-overridable, else config/harness-defaults.json's
        # dispatch_budget_seconds as it stands at dispatch. The promise freezes into
        # history at departure; a later policy change never rewrites in-flight liveness
        # verdicts." A brief-level override is EXPLICITLY DEFERRED here (car's report,
        # C3R-1e): the real PostToolUse:Task launch payload carries no estimated-duration
        # field anywhere in tool_input/tool_response to override FROM, and inventing one
        # (e.g. parsing the free-text prompt) would be exactly the brittle mechanism this
        # fix cycle's brief warns against. A read failure degrades the record (no `budget`
        # field written) rather than blocking the write - the fold applies its OWN default
        # at fold time regardless (the legacy/foreign tail 49 existing budget-less fossil
        # records already rely on), so a producer-side read failure never loses liveness
        # information, only the WRITE-TIME freeze this stamp exists to add.
        $budgetSeconds = $null
        $defaultsPathForBudget = if ($DefaultsPath) { $DefaultsPath } else { Join-Path (Split-Path $PSScriptRoot -Parent) 'config/harness-defaults.json' }
        try {
            $parsedDefaults = Get-Content $defaultsPathForBudget -Raw -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json
            if ($null -ne $parsedDefaults.dispatch_budget_seconds) {
                $budgetSeconds = [double]$parsedDefaults.dispatch_budget_seconds
            }
        } catch {
            Add-Fault -Message "could not read the shop default budget from '$defaultsPathForBudget' to stamp on the new dispatched record for $subject"
        }
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
    # budget (canonical order, schema/index-format.md:17-20: right after envelope, before
    # basis/cost/context_peak_tokens/producer) - issue #22 item 1, C3R-1e. Absent when the
    # shop-default read failed; the fold applies its own default at fold time regardless.
    if ($Kind -eq 'dispatched' -and $null -ne $budgetSeconds) { $record['budget'] = $budgetSeconds }
    if ($Kind -eq 'dispatched' -and $model) { $record['model'] = $model }
    # #47 D2/D4 open-posture extras, same disclosed-deviation class as `model` (not in
    # index-format.md's canonical order; placed with the producer-metadata cluster):
    #   subject_basis - which family rule produced the subject (runtime-id | minted-id)
    #   task_id       - the shop-minted id echoed back by the envelope (returned only, #47 5.7)
    #   provenance    - runtime-internal ids kept as enrichment, never identity
    if ($subjectBasis) { $record['subject_basis'] = $subjectBasis }
    if ($Kind -eq 'returned' -and $taskId) { $record['task_id'] = $taskId }
    if ($provenance) { $record['provenance'] = $provenance }
    $record['producer']      = 'starcar-hook/1'
    $record['normalisation'] = @($normalisation)

    # integrity is sha256 over the canonical body (every field above, in order, compact).
    $bodyJson = $record | ConvertTo-Json -Depth 20 -Compress
    $record['integrity'] = 'sha256:' + (Get-Sha256Hex $bodyJson)

    # --- write to the R4 path: <store>/<subject>/<kind>-<compact-at>.json ----------------
    # Q3 (path traversal, Copilot/Qodo round 2): $subject is payload-derived and MUST be
    # sanitized before ANY path use. An allowlist alone is not enough - '..' alone passes
    # '^[A-Za-z0-9._-]+$' (only dots), so both checks are required. A rejection raises
    # (Law 4: never dropped) via the same catch-block Add-Fault path as every other
    # validation failure below, then exits nonzero with NO write and NO commit.
    if ($subject -notmatch '^[A-Za-z0-9._-]+$' -or $subject.Contains('..')) {
        throw "rejected subject (path traversal risk): $subject"
    }
    $compactAt = $at -replace '[-:]', ''
    $subjectDir = Join-Path $storeAbs $subject

    # --- duplicate-dispatch refusal guard (#47 D2/DR-9, Q2 keep-first) -------------------
    # Uniqueness at the mint boundary is MECHANICAL, not dispatcher vigilance: the producer
    # REFUSES a second `dispatched` record whose subject already has an UN-SUPERSEDED
    # dispatched record (one on disk with no `returned` record yet). Keep-first (Q2 ruling):
    # the already-in-flight dispatch's identity stays stable so its dispatched<->returned
    # pair resolves; the refused second never enters the store. Boundary (round-2 reviewer):
    # "un-superseded" means a same-id re-dispatch AFTER the first returned is NOT refused
    # here - that post-return reuse is caught downstream by the fold's superseded-exposure
    # (schema/vectors/fold/duplicate-subject-two-dispatched.json). Loud fault, no write.
    if ($Kind -eq 'dispatched') {
        $existingDisp = @(Get-ChildItem -Path $subjectDir -Filter 'dispatched-*.json' -File -ErrorAction SilentlyContinue)
        $existingRet  = @(Get-ChildItem -Path $subjectDir -Filter 'returned-*.json'   -File -ErrorAction SilentlyContinue)
        if ($existingDisp.Count -gt 0 -and $existingRet.Count -eq 0) {
            throw "duplicate dispatch refused (#47 DR-9 guard, keep-first): subject '$subject' already has an un-superseded dispatched record; no second dispatched record written"
        }
    }

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
