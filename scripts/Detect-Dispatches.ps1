#requires -Version 7.4
# Detect-Dispatches.ps1 -- the READ-ONLY, STATELESS detector (spec S2, S5.1). It reads the
# artifact store and emits ONE fold as JSON to stdout. It never writes a record and never
# remembers anything between runs: gaps stay visible statelessly (S3.5), so there is no
# state that could go stale and no lifecycle to test (S5.1's tripwire: an implementer that
# finds itself adding a field that outlives the process has hit a design contradiction).
#
# THE FOLD (stdout JSON):
#   tier         : "tier-1-only" -- reported TRUTHFULLY (R6v2). Tier-2 enumeration (an
#                  enumerable second dispatch source) is deferred with its trigger in
#                  docs/setup.md; shipping a wolf-crier to fill a row would violate the
#                  severity philosophy the spec itself cites.
#   generated_at : the Now used (injected or wall clock)
#   faults       : board-level faults, ONE per unreadable read (S3.2), never N per record.
#                  A vocabulary file that reads and parses but carries zero values is a
#                  FAULT too (valid-but-empty, design S6 DR3-2/spec YB-8), identical in
#                  shape to the malformed-vocabulary fault: ONE combined string naming
#                  every empty file, never a per-record fan-out.
#   discoveries  : unrecognised kind/outcome values, reported BY NAME (S3.2), never a bug
#   dispatches   : one entry per dispatch subject (dispatched|returned|presumed-lost)
#   intents      : one entry per intent subject, latest-at winning (S3.1, Law 2)
#
# Precedence for one dispatch subject: returned > presumed-lost > dispatched (S3.1). Within
# the winning kind, latest-at wins and every earlier/lower record is EXPOSED in `superseded`
# (S3.1 -- the fold that looks folded is the failure this exposure prevents). A dispatched
# with no successor renders the liveness gradient (S3.3): within budget -> dispatched;
# past budget -> overdue WITH elapsed and budget (a gradient, not a cliff, so a mis-set
# budget degrades visibly) -- and per Probe 1 this budget path is the ONLY way a killed
# dispatch (which fires no stop hook) is ever surfaced. Spend renders from `cost` only;
# absent is reported absent and never borrowed from context (S3.4).
#
# BUDGET PROVENANCE (spec Amendment 2, issue #22, C3R-1): applying the shop default to a
# budget-less dispatched record is a FOLD SEMANTIC (it changes the rendered state), never
# environmental IO - the earlier carve-out that called it IO was a false premise, reversed
# after a reviewer constructed a real pwsh-vs-Go divergence on this exact path. Every
# dispatched entry that renders a `budget_seconds` value also carries `budget_source`:
# 'record' (the record supplied its own budget) or 'default' (the shop default was
# applied) - present ONLY alongside a non-null `budget_seconds`, never a phantom source for
# a null budget. Both the pwsh detector and the Go port (board/fold) emit this field
# identically; schema/vectors/fold/ pins the cross-language contract.

param(
    [Parameter(Mandatory)] [string]$StoreRoot,
    [string]$Now = '',
    [string]$DefaultsPath = '',
    [string]$VocabDir = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path $PSScriptRoot -Parent
if (-not $DefaultsPath) { $DefaultsPath = Join-Path $repoRoot 'config/harness-defaults.json' }
if (-not $VocabDir)     { $VocabDir     = Join-Path $repoRoot 'schema/vocab' }

Import-Module (Join-Path $PSScriptRoot 'Artifact.psm1') -Force

$faults      = New-Object System.Collections.Generic.List[string]
$discoveries = New-Object System.Collections.Generic.List[string]

$nowIso = if ($Now) { $Now } else { (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') }
# F1 (docs/plans/2026-07-22-pr18-correctness-fixes-plan.md) disclosure: this inline parse
# stays inline rather than repointing to Artifact.psm1's Get-AtInstant. Get-AtInstant
# returns a DateTime (.UtcDateTime) for SORTING; this value is subtracted from the
# dispatched record's own DateTimeOffset parse (below) to compute elapsed seconds, which
# needs BOTH operands to stay DateTimeOffset (a DateTime minus DateTimeOffset does not
# compile) -- a different shape for a different purpose, not the duplication Get-AtInstant
# exists to remove. $nowIso is always Z-suffixed (this process's own clock), so the
# zoneless-rejection Get-AtInstant enforces is moot here regardless.
$nowDto = [datetimeoffset]::Parse($nowIso, [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)

# --- shop default budget (R5v2): ONE fault if unreadable, never infinite ----------------
$defaultBudget = $null
try {
    $defaultBudget = (Get-Content $DefaultsPath -Raw -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json).dispatch_budget_seconds
} catch {
    $faults.Add("defaults: could not read the shop default budget from '$DefaultsPath'")
}

# --- recognition vocabularies (S3.2): ONE fault if unreadable ---------------------------
$kindValues = @()
$outcomeValues = @()
$vocabOk = $true
try {
    $kindsParsed    = Get-Content (Join-Path $VocabDir 'kinds.json') -Raw -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json
    $outcomesParsed = Get-Content (Join-Path $VocabDir 'outcomes.json') -Raw -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json
    # The OUTER @(...) is load-bearing, not decoration: an if/else used as an expression
    # unrolls an empty-array branch onto the output stream, and capturing ZERO pipeline
    # objects into a variable yields $null, not an empty array (observed: `$v = if ($true)
    # { @() } else { @() }` leaves $v as $null under Set-StrictMode -Version Latest, and
    # $v.Count then throws PropertyNotFoundException). Wrapping the whole if/else forces
    # array semantics on the RESULT rather than the branch, so a genuinely empty
    # values:[] still yields a real zero-length array whose .Count is 0.
    $kindValues    = @(if ($null -ne $kindsParsed.values)    { $kindsParsed.values }    else { @() })
    $outcomeValues = @(if ($null -ne $outcomesParsed.values) { $outcomesParsed.values } else { @() })

    # DR4-2 (spec YB-8, design rev 5 S6 [DR3-2]): a vocabulary file that reads and parses
    # cleanly but carries ZERO values is neither missing nor malformed - it is VALID but
    # EMPTY, and design S6 rules this identical in shape to the malformed-vocabulary fault:
    # ONE combined board condition, and the detector must NOT fan out (the landed detector
    # before this fix DID fan out here: with $vocabOk left true and both value arrays
    # empty, every record's kind/outcome fails the `-notcontains` check and becomes a false
    # "discovery" per record - observed 2026-07-23 against
    # schema/vectors/fold/empty-vocab-one-fault.json: faults=[], discoveries=[kind:
    # dispatched, kind: returned, outcome: done, kind: intent] - the N-wolf-cries cascade
    # rev 2 MAJOR-3 rejected). Every empty file is named, alphabetically, in ONE fault
    # string (the vector's exact pinned text is a cross-language contract surface, spec
    # YB-8's disclosed posture).
    $emptyVocabFiles = @()
    if ($kindValues.Count -eq 0)    { $emptyVocabFiles += 'kinds.json' }
    if ($outcomeValues.Count -eq 0) { $emptyVocabFiles += 'outcomes.json' }
    if ($emptyVocabFiles.Count -gt 0) {
        # "Identical to malformed" (design S6 DR3-2): a vocabulary fault suppresses
        # discovery reporting entirely, the same way an unreadable vocab dir does below -
        # never a partial per-file suppression, because a fold that discovers kinds off an
        # empty outcomes vocabulary (or vice versa) is still discovering off vocabulary the
        # design has already declared unusable.
        $vocabOk = $false
        $sortedEmpty = ($emptyVocabFiles | Sort-Object) -join ', '
        $faults.Add("vocabulary: valid but empty: $sortedEmpty")
    }
} catch {
    $vocabOk = $false
    $faults.Add("vocab: could not read recognition vocabulary files from '$VocabDir'")
}

# --- read every record --------------------------------------------------------
$records = @()
if (Test-Path $StoreRoot) {
    foreach ($f in @(Get-ChildItem -Path $StoreRoot -Filter *.json -Recurse -File)) {
        try {
            $obj = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json -DateKind String
        } catch {
            $faults.Add("record: could not parse '$($f.FullName)'")
            continue
        }
        $records += $obj
    }
}

function Get-Prop {
    param([object]$Object, [string]$Name)
    if ($null -eq $Object) { return $null }
    $p = $Object.PSObject.Properties[$Name]
    if ($null -eq $p) { return $null }
    return $p.Value
}

# --- discoveries: unrecognised vocab BY NAME (deduped) ----------------------------------
if ($vocabOk) {
    foreach ($r in $records) {
        $k = Get-Prop $r 'kind'
        if ($k -and $kindValues -notcontains $k) {
            $d = "kind: $k"; if (-not $discoveries.Contains($d)) { $discoveries.Add($d) }
        }
        $o = Get-Prop $r 'outcome'
        if ($o -and $outcomeValues -notcontains $o) {
            $d = "outcome: $o"; if (-not $discoveries.Contains($d)) { $discoveries.Add($d) }
        }
    }
}

$dispatchKinds = @('dispatched', 'returned', 'presumed-lost')
$precedence = @{ 'returned' = 3; 'presumed-lost' = 2; 'dispatched' = 1 }

# --- group by subject, partitioned into dispatch subjects vs intent subjects ------------
$bySubject = @{}
foreach ($r in $records) {
    $subject = Get-Prop $r 'subject'
    $kind = Get-Prop $r 'kind'
    if (-not $subject -or -not $kind) { continue }
    if (-not $bySubject.ContainsKey($subject)) { $bySubject[$subject] = @() }
    $bySubject[$subject] += $r
}

$dispatches = @()
$intents = @()

foreach ($subject in ($bySubject.Keys | Sort-Object)) {
    $subRecords = $bySubject[$subject]

    $dispatchRecords = @($subRecords | Where-Object { $dispatchKinds -contains (Get-Prop $_ 'kind') })
    $intentRecords   = @($subRecords | Where-Object { (Get-Prop $_ 'kind') -eq 'intent' })

    if ($dispatchRecords.Count -gt 0) {
        # Winner: highest precedence, then latest-at within that kind. F1
        # (docs/plans/2026-07-22-pr18-correctness-fixes-plan.md): latest-at must compare
        # the parsed INSTANT (Get-AtInstant), never the lexical 'at' string - the store
        # carries mixed offsets, so a lexical sort is chronological only when every
        # record shares the same offset. A bad 'at' throws loud, attributed to this
        # subject (the detector's records carry no file path - subject is its identity),
        # never a silent mis-sort.
        # -Stable (C3R-2, Minor, Car 3 review round 1): PowerShell's Sort-Object does not
        # DOCUMENT stability without this switch, so two records with the SAME (subject,
        # kind, instant) but different outcome/cost/budget had an unpinned tie-break -
        # matching the Go port's sort.SliceStable (input order) only by observed behaviour,
        # never by contract. -Stable makes the pwsh side's ordering guarantee explicit and
        # equal to Go's, rather than relying on undocumented current behaviour.
        $ranked = $dispatchRecords | Sort-Object -Stable `
            @{ Expression = { $precedence[[string](Get-Prop $_ 'kind')] } ; Descending = $true }, `
            @{ Expression = {
                try { Get-AtInstant -At ([string](Get-Prop $_ 'at')) }
                catch { throw "Detect-Dispatches: subject '$subject': $($_.Exception.Message)" }
            } ; Descending = $true }
        $ranked = @($ranked)
        $winner = $ranked[0]
        $winnerKind = [string](Get-Prop $winner 'kind')

        # Everything except the winner is exposed as superseded (precedence + within-kind).
        $superseded = @()
        for ($i = 1; $i -lt $ranked.Count; $i++) {
            $superseded += [ordered]@{ kind = [string](Get-Prop $ranked[$i] 'kind'); at = [string](Get-Prop $ranked[$i] 'at') }
        }

        $entry = [ordered]@{
            subject    = $subject
            state      = $winnerKind
            at         = [string](Get-Prop $winner 'at')
            superseded = @($superseded)
        }

        if ($winnerKind -eq 'returned') {
            $entry['outcome'] = [string](Get-Prop $winner 'outcome')
            $cost = Get-Prop $winner 'cost'
            # Spend renders from cost ONLY; a dark lane is 'absent', never borrowed (S3.4).
            $entry['spend'] = if ($null -ne $cost) { $cost } else { 'absent' }
        }
        elseif ($winnerKind -eq 'dispatched') {
            # Liveness gradient (S3.3). Budget: the record's own, else the shop default -
            # C3R-1 / spec Amendment 2 (owner ruling, issue #22): applying the shop default
            # to render `overdue` is a FOLD SEMANTIC, not environmental IO. The spec 7b.1
            # carve-out that called this environmental was a false premise, proven when the
            # round-1 reviewer constructed a byte-identical budget-less input on which the
            # pwsh detector rendered overdue/1800 and the (un-threaded) Go fold rendered
            # dispatched/null - a real divergence on the ONLY killed-dispatch surface
            # (design S3.3, Probe 1). `budget_source` now discloses WHICH patience produced
            # the rendered state: 'record' when the record carried its own budget, 'default'
            # when the shop default was applied - present ONLY when `budget_seconds` itself
            # is non-null (Amendment 2 item (b): kept minimal, never a phantom source for a
            # null budget).
            $recBudget = Get-Prop $winner 'budget'
            $budget = $null
            $budgetSource = $null
            if ($null -ne $recBudget) {
                $budget = [double]$recBudget
                $budgetSource = 'record'
            } elseif ($null -ne $defaultBudget) {
                $budget = [double]$defaultBudget
                $budgetSource = 'default'
            }
            # F1 disclosure (docs/plans/2026-07-22-pr18-correctness-fixes-plan.md): this
            # inline parse stays inline rather than repointing to Get-AtInstant, which
            # returns a DateTime (.UtcDateTime) for SORTING - a different shape from the
            # DateTimeOffset this subtraction needs to pair with $nowDto above (a DateTime
            # minus DateTimeOffset does not compile). Not the duplication Get-AtInstant
            # exists to remove; this idiom computes elapsed time, never a sort order.
            $atDto = [datetimeoffset]::Parse([string](Get-Prop $winner 'at'), [cultureinfo]::InvariantCulture, [System.Globalization.DateTimeStyles]::RoundtripKind)
            $elapsed = [math]::Floor(($nowDto - $atDto).TotalSeconds)
            $entry['elapsed_seconds'] = [int64]$elapsed
            if ($null -ne $budget) {
                $entry['budget_seconds'] = $budget
                $entry['budget_source'] = $budgetSource
                if ($elapsed -gt $budget) { $entry['state'] = 'overdue' }
            } else {
                # No default available (defaults file unreadable): the fault is already
                # raised; render the elapsed truthfully without inventing a budget, and
                # budget_source stays absent (nothing was applied).
                $entry['budget_seconds'] = $null
            }
        }

        $dispatches += $entry
    }

    if ($intentRecords.Count -gt 0) {
        # F1: latest-at intent-hold supersession must also compare the parsed instant -
        # a lexical sort here is the bug that lets a withdrawn hold win (plan F1).
        # -Stable (C3R-2, Minor): same rationale as the dispatch-side sort above - two
        # intent records with the SAME instant had an undocumented tie-break without this.
        $ordered = @($intentRecords | Sort-Object -Stable @{ Expression = {
            try { Get-AtInstant -At ([string](Get-Prop $_ 'at')) }
            catch { throw "Detect-Dispatches: subject '$subject': $($_.Exception.Message)" }
        } ; Descending = $true })
        $winner = $ordered[0]
        $superseded = @()
        for ($i = 1; $i -lt $ordered.Count; $i++) {
            $superseded += [ordered]@{ at = [string](Get-Prop $ordered[$i] 'at') }
        }
        $intents += [ordered]@{
            subject    = $subject
            at         = [string](Get-Prop $winner 'at')
            superseded = @($superseded)
        }
    }
}

$fold = [ordered]@{
    tier         = 'tier-1-only'
    generated_at = $nowIso
    faults       = @($faults)
    discoveries  = @($discoveries)
    dispatches   = @($dispatches)
    intents      = @($intents)
}

$fold | ConvertTo-Json -Depth 20
exit 0
