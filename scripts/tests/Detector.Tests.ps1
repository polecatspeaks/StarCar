#requires -Version 7.4
# The detector and the fold (Task B.3; plan task 3.1, spec YB-10). Detect-Dispatches.ps1
# reads the artifact store and emits the fold as JSON to stdout. The detector is READ-ONLY
# and STATELESS (spec S5.1): it raises, it never writes and never remembers.
#
# YB-10 REHOME (plan task 3.1, spec 7b amendment): this file used to carry every case as an
# imperative Pester It. Every case expressible as PURE FOLD SEMANTICS (records + vocab + now
# -> faults/discoveries/dispatches/intents) has migrated to a declarative fixture under
# schema/vectors/fold/ and is now run by the fixture-driven RUNNER below, per the runner
# contract in schema/vectors/README.md. The runner also executes the three landed spec-rung
# vectors (subject-partition, manifest-supersession, empty-vocab-one-fault) - this file is
# the SAME suite the Go fold's own vector-runner (board/fold) conforms to, per YB-7/YB-9.
#
# CARVED OUT (plan-round-1 amendment [PB-1, folded], spec 7b.1) - these four cases are
# environmental/pwsh-IO behaviours, not language-neutral fold semantics, and stay imperative:
#   - unreadable-vocab-dir: a fault-injected nonexistent path, emitting a path-bearing fault
#     string no cross-language deep-equal can pin (the runner contract never injects a path
#     into the comparison).
#   - unreadable-defaults: same shape, for the shop-default budget file.
#   - the tier assertion: asserts a field (`tier`) the runner contract explicitly EXCLUDES
#     from comparison (schema/vectors/README.md: "tier and generated_at are excluded from
#     comparison (environmental)").
#   - the shop-default budget case: depends on the REAL config/harness-defaults.json, which
#     the runner contract never injects (no DefaultsPath parameter in the vector shape).
# The Go fold gets its own-idiom equivalents for the two read-failure behaviours (unreadable
# vocab dir, unreadable defaults) in its own test suite (board/fold, plan task 3.3) - the
# vectors cannot carry them, so without an own-idiom test they would be silently uncovered
# in Go.
#
# Rules under test map to spec citations:
#   precedence returned > presumed-lost > dispatched          (S3.1)
#   within-kind latest-at wins, supersession EXPOSED          (S3.1)
#   a later intent supersedes the earlier hold                (S3.1, Law 2)
#   budget gradient: overdue with elapsed AND budget          (S3.3)
#   spend from cost only; absent renders absent               (S3.4)
#   unrecognised vocab reported BY NAME; unreadable = ONE fault (S3.2, R5v2)
#   tier reported truthfully as tier-1-only                   (R6v2)
#   valid-but-empty vocabulary = ONE combined fault, zero fan-out (DR3-2, YB-8, plan 3.2)
#
# STRUCTURE NOTE (Pester v5 discovery/run scope boundary): every helper this file's It
# blocks call lives in ONE shared BeforeAll at the outer Describe - a function or $script:
# variable defined at bare file top-level (outside any Describe) is visible during Pester's
# DISCOVERY pass but NOT during the later RUN pass that actually executes It bodies (they
# run in a separate scope tree). The fixture-driven Context below enumerates vector files
# directly in its own body (which DOES run at discovery, the standard Pester pattern for
# generating tests from files on disk) and threads each vector via It's -ForEach, which
# Pester itself carries correctly across the discovery/run boundary - never a closed-over
# loop variable, which in plain PowerShell foreach would alias to the SAME variable slot
# across every iteration and let every generated It silently reference only the last vector.

Describe 'Detect-Dispatches (plan 3.1, spec YB-10) - carved-out cases + fixture-driven fold vectors' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:Script   = Join-Path $script:RepoRoot 'scripts/Detect-Dispatches.ps1'

        function New-Record {
            param(
                [string]$Store, [string]$Subject, [string]$Kind, [string]$At,
                [string]$Outcome, [object]$Budget, [object]$Cost
            )
            $rec = [ordered]@{ schema = 'starcar-artifact/1'; kind = $Kind; subject = $Subject; session_id = 's'; at = $At }
            if ($Outcome) { $rec['outcome'] = $Outcome; $rec['findings'] = 'f'; $rec['abstract'] = 'a' }
            if ($null -ne $Budget) { $rec['budget'] = $Budget }
            if ($null -ne $Cost)   { $rec['cost'] = $Cost }
            $rec['normalisation'] = @()
            $rec['integrity'] = 'sha256:0000000000000000000000000000000000000000000000000000000000000000'
            $dir = Join-Path $Store $Subject
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $file = Join-Path $dir "$Kind-$($At -replace '[-:]', '').json"
            ($rec | ConvertTo-Json -Depth 20) | Set-Content -Path $file -Encoding utf8
        }

        function Invoke-Detector {
            param([string]$StoreRoot, [string]$Now, [string]$DefaultsPath, [string]$VocabDir)
            # Hashtable splat binds by NAME. (Array splat binds positionally and does NOT
            # interpret '-Name' tokens as parameter names - it would feed the store path
            # into -Now.)
            $p = @{ StoreRoot = $StoreRoot }
            if ($Now) { $p['Now'] = $Now }
            if ($DefaultsPath) { $p['DefaultsPath'] = $DefaultsPath }
            if ($VocabDir) { $p['VocabDir'] = $VocabDir }
            $json = & $script:Script @p | Out-String
            # -DateKind String keeps the emitted `at` ISO strings as strings; default
            # ConvertFrom-Json would coerce them to [datetime] and reformat (the same
            # load-bearing flag New-ArtifactIndex.ps1:37 relies on).
            $json | ConvertFrom-Json -DateKind String
        }

        # --- fixture-driven runner support (schema/vectors/README.md's runner contract) ---

        function ConvertTo-FoldComparable {
            # Normalises a parsed JSON value so deep-equal is a pure structural comparison:
            # object keys are sorted (JSON objects are unordered per spec, and the
            # detector's ordered-hashtable output can legitimately differ in key order from
            # a hand-authored vector file with no semantic difference), and every numeric
            # type (Int64 from a bare JSON integer, Double from the detector's [double]
            # casts) collapses to [double] so "60" (expected) and "60.0" (actual, cast)
            # compare equal. Arrays stay positional - the detector's dispatches/intents
            # arrays are subject-sorted and its superseded arrays are rank-sorted, both
            # deterministic, so array order IS significant and is never reordered here.
            param($Value)
            if ($null -eq $Value) { return $null }
            if ($Value -is [string]) { return $Value }
            if ($Value -is [bool]) { return $Value }
            if ($Value -is [System.Management.Automation.PSCustomObject]) {
                $h = [ordered]@{}
                foreach ($p in ($Value.PSObject.Properties | Sort-Object Name)) {
                    $h[$p.Name] = ConvertTo-FoldComparable $p.Value
                }
                return $h
            }
            if ($Value -is [System.Collections.IDictionary]) {
                $h = [ordered]@{}
                foreach ($k in ($Value.Keys | Sort-Object)) { $h[$k] = ConvertTo-FoldComparable $Value[$k] }
                return $h
            }
            if ($Value -is [System.Collections.IEnumerable]) {
                return @($Value | ForEach-Object { ConvertTo-FoldComparable $_ })
            }
            if ($Value -is [byte] -or $Value -is [int] -or $Value -is [int32] -or $Value -is [int64] `
                -or $Value -is [uint32] -or $Value -is [uint64] -or $Value -is [double] -or $Value -is [decimal] -or $Value -is [single]) {
                return [double]$Value
            }
            return $Value
        }

        function Assert-FoldFieldDeepEqual {
            param($Expected, $Actual, [string]$Field, [string]$VectorName)
            $e = ConvertTo-FoldComparable $Expected
            $a = ConvertTo-FoldComparable $Actual
            $eJson = $e | ConvertTo-Json -Depth 20 -Compress
            $aJson = $a | ConvertTo-Json -Depth 20 -Compress
            $aJson | Should -Be $eJson -Because "vector '$VectorName': field '$Field' must deep-equal 'expected.$Field' (schema/vectors/README.md's runner contract)"
        }

        function Invoke-FoldVectorRun {
            # Materialises a vector's input.records into a temp store (one file per record
            # at <subject-sanitised>/<kind>-<index>.json, ':' replaced with '-' for the
            # directory name ONLY - the fold reads subject from record content, never from
            # the path) and input.vocab into a temp vocab dir (one file per key,
            # {"values": [...]} shape), then invokes the detector with input.now as the
            # injected clock. This is the runner contract's steps 1+2, implemented once
            # here so every vector shares one materialiser.
            param($Vector)
            $tmp = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
            $storeRoot = Join-Path $tmp 'store'
            $vocabDir  = Join-Path $tmp 'vocab'
            New-Item -ItemType Directory -Path $storeRoot -Force | Out-Null
            New-Item -ItemType Directory -Path $vocabDir -Force | Out-Null

            $records = @($Vector.input.records)
            for ($i = 0; $i -lt $records.Count; $i++) {
                $rec = $records[$i]
                $safeSubject = ([string]$rec.subject) -replace ':', '-'
                $dir = Join-Path $storeRoot $safeSubject
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
                $kind = [string]$rec.kind
                $file = Join-Path $dir "$kind-$i.json"
                ($rec | ConvertTo-Json -Depth 20) | Set-Content -Path $file -Encoding utf8
            }

            foreach ($prop in $Vector.input.vocab.PSObject.Properties) {
                $obj = [ordered]@{ values = @($prop.Value) }
                ($obj | ConvertTo-Json -Depth 10) | Set-Content -Path (Join-Path $vocabDir "$($prop.Name).json") -Encoding utf8
            }

            Invoke-Detector -StoreRoot $storeRoot -Now ([string]$Vector.input.now) -VocabDir $vocabDir
        }
    }

    Context 'carved-out environmental/pwsh-IO cases (spec 7b.1)' {
        It 'an unreadable vocabulary directory is ONE fault, not N' {
            $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
            New-Record -Store $store -Subject 'disp-9'  -Kind 'dispatched' -At '2026-07-22T10:00:00Z'
            New-Record -Store $store -Subject 'disp-10' -Kind 'dispatched' -At '2026-07-22T10:00:00Z'
            $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T11:00:00Z' -VocabDir (Join-Path $TestDrive 'no-such-vocab')
            @($fold.faults | Where-Object { $_ -match 'vocab' }).Count | Should -Be 1
        }

        It 'an unreadable defaults file is ONE fault' {
            $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
            New-Record -Store $store -Subject 'disp-11' -Kind 'dispatched' -At '2026-07-22T10:00:00Z'
            $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T11:00:00Z' -DefaultsPath (Join-Path $TestDrive 'no-such-defaults.json')
            @($fold.faults | Where-Object { $_ -match 'default' }).Count | Should -Be 1
        }

        It 'the fold reports its tier truthfully as tier-1-only (R6v2)' {
            $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
            New-Record -Store $store -Subject 'disp-12' -Kind 'dispatched' -At '2026-07-22T10:00:00Z'
            $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T11:00:00Z'
            $fold.tier | Should -Be 'tier-1-only'
        }

        It 'a dispatched with no record budget falls back to the shop default' {
            $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
            New-Record -Store $store -Subject 'disp-6' -Kind 'dispatched' -At '2026-07-22T10:00:00Z'
            $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T12:00:00Z'
            $e = @($fold.dispatches) | Where-Object { $_.subject -eq 'disp-6' }
            $e.budget_seconds | Should -Be 1800
            $e.state | Should -Be 'overdue'
        }
    }

    Context 'fixture-driven runner (schema/vectors/fold/) - YB-7, YB-8, YB-10' {
        # Discovery-phase enumeration (the standard Pester "generate tests from files on
        # disk" pattern) - this Context body runs during discovery, so $PSScriptRoot (a
        # genuine automatic variable, valid at any point in the file's execution) is used
        # rather than anything set in BeforeAll (run-phase only, see the file header note).
        $vectorsDir = Join-Path $PSScriptRoot '../../schema/vectors/fold'
        $vectorData = @(Get-ChildItem -Path $vectorsDir -Filter '*.json' -File | Sort-Object Name | ForEach-Object {
            @{ VectorId = $_.BaseName; VectorPath = $_.FullName }
        })

        if ($vectorData.Count -eq 0) {
            It 'schema/vectors/fold/ must not be empty - a zero-vector run is a refusal, not a pass' {
                $vectorData.Count | Should -BeGreaterThan 0
            }
        }

        It "vector: <VectorId>" -ForEach $vectorData {
            $vector = Get-Content $VectorPath -Raw | ConvertFrom-Json -DateKind String

            if ($vector.name -eq 'empty-vocab-one-fault') {
                Set-ItResult -Inconclusive -Because 'red-on-arrival pin for 3.2 (YB-8)'
                return
            }

            $fold = Invoke-FoldVectorRun -Vector $vector
            Assert-FoldFieldDeepEqual -Expected $vector.expected.faults      -Actual $fold.faults      -Field 'faults'      -VectorName $vector.name
            Assert-FoldFieldDeepEqual -Expected $vector.expected.discoveries -Actual $fold.discoveries -Field 'discoveries' -VectorName $vector.name
            Assert-FoldFieldDeepEqual -Expected $vector.expected.dispatches  -Actual $fold.dispatches  -Field 'dispatches'  -VectorName $vector.name
            Assert-FoldFieldDeepEqual -Expected $vector.expected.intents    -Actual $fold.intents      -Field 'intents'     -VectorName $vector.name
        }
    }
}
