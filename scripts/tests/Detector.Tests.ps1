#requires -Version 7.4
# The detector and the fold (Task B.3). Detect-Dispatches.ps1 reads the artifact store and
# emits the fold as JSON to stdout. The detector is READ-ONLY and STATELESS (spec S5.1): it
# raises, it never writes and never remembers. Rules under test map to spec citations:
#   precedence returned > presumed-lost > dispatched          (S3.1)
#   within-kind latest-at wins, supersession EXPOSED          (S3.1)
#   a later intent supersedes the earlier hold                (S3.1, Law 2)
#   budget gradient: overdue with elapsed AND budget          (S3.3)
#   spend from cost only; absent renders absent               (S3.4)
#   unrecognised vocab reported BY NAME; unreadable = ONE fault (S3.2, R5v2)
#   tier reported truthfully as tier-1-only                   (R6v2)

Describe 'Detect-Dispatches' {
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
    }

    It 'precedence resolves a subject with dispatched + returned to returned' {
        $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Record -Store $store -Subject 'disp-1' -Kind 'dispatched' -At '2026-07-22T10:00:00Z'
        New-Record -Store $store -Subject 'disp-1' -Kind 'returned' -At '2026-07-22T10:05:00Z' -Outcome 'APPROVE'
        $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T11:00:00Z'
        $e = @($fold.dispatches) | Where-Object { $_.subject -eq 'disp-1' }
        $e.state | Should -Be 'returned'
        $e.outcome | Should -Be 'APPROVE'
    }

    It 'two returned records resolve to latest-at AND expose the superseded one' {
        $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Record -Store $store -Subject 'disp-2' -Kind 'returned' -At '2026-07-22T10:05:00Z' -Outcome 'APPROVE'
        New-Record -Store $store -Subject 'disp-2' -Kind 'returned' -At '2026-07-22T10:10:00Z' -Outcome 'REJECT'
        $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T11:00:00Z'
        $e = @($fold.dispatches) | Where-Object { $_.subject -eq 'disp-2' }
        $e.state | Should -Be 'returned'
        $e.outcome | Should -Be 'REJECT'
        @($e.superseded).Count | Should -Be 1
        $e.superseded[0].at | Should -Be '2026-07-22T10:05:00Z'
    }

    It 'a dispatched past budget renders overdue with elapsed AND budget' {
        $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Record -Store $store -Subject 'disp-3' -Kind 'dispatched' -At '2026-07-22T10:00:00Z' -Budget 60
        $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T12:00:00Z'
        $e = @($fold.dispatches) | Where-Object { $_.subject -eq 'disp-3' }
        $e.state | Should -Be 'overdue'
        $e.elapsed_seconds | Should -Be 7200
        $e.budget_seconds | Should -Be 60
    }

    It 'a dispatched within budget stays dispatched (the gradient, not a cliff)' {
        $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Record -Store $store -Subject 'disp-4' -Kind 'dispatched' -At '2026-07-22T10:00:00Z' -Budget 86400
        $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T10:30:00Z'
        $e = @($fold.dispatches) | Where-Object { $_.subject -eq 'disp-4' }
        $e.state | Should -Be 'dispatched'
    }

    It 'a record-level budget overrides the shop default' {
        $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        # elapsed is 7200s; the shop default 1800 would be overdue, the record's 99999 is not
        New-Record -Store $store -Subject 'disp-5' -Kind 'dispatched' -At '2026-07-22T10:00:00Z' -Budget 99999
        $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T12:00:00Z'
        $e = @($fold.dispatches) | Where-Object { $_.subject -eq 'disp-5' }
        $e.state | Should -Be 'dispatched'
        $e.budget_seconds | Should -Be 99999
    }

    It 'a dispatched with no record budget falls back to the shop default' {
        $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Record -Store $store -Subject 'disp-6' -Kind 'dispatched' -At '2026-07-22T10:00:00Z'
        $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T12:00:00Z'
        $e = @($fold.dispatches) | Where-Object { $_.subject -eq 'disp-6' }
        $e.budget_seconds | Should -Be 1800
        $e.state | Should -Be 'overdue'
    }

    It 'a later intent supersedes the earlier hold (Law 2)' {
        $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Record -Store $store -Subject 'hold-x' -Kind 'intent' -At '2026-07-22T10:00:00Z'
        New-Record -Store $store -Subject 'hold-x' -Kind 'intent' -At '2026-07-22T11:00:00Z'
        $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T12:00:00Z'
        $e = @($fold.intents) | Where-Object { $_.subject -eq 'hold-x' }
        $e.at | Should -Be '2026-07-22T11:00:00Z'
        @($e.superseded).Count | Should -Be 1
        $e.superseded[0].at | Should -Be '2026-07-22T10:00:00Z'
    }

    It 'spend renders from cost only: absent when there is no cost, present when there is' {
        $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Record -Store $store -Subject 'disp-7' -Kind 'returned' -At '2026-07-22T10:05:00Z' -Outcome 'APPROVE'
        New-Record -Store $store -Subject 'disp-8' -Kind 'returned' -At '2026-07-22T10:05:00Z' -Outcome 'APPROVE' -Cost @{ output_tokens = 23 }
        $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T11:00:00Z'
        $dark = @($fold.dispatches) | Where-Object { $_.subject -eq 'disp-7' }
        $lit  = @($fold.dispatches) | Where-Object { $_.subject -eq 'disp-8' }
        $dark.spend | Should -Be 'absent'
        $lit.spend.output_tokens | Should -Be 23
    }

    It 'recognises done, CONFIRM, and done-with-findings as outcome vocabulary (YB-3) - no discovery raised' {
        # YB-3 (spec 2026-07-23-yard-board S2): done/CONFIRM were OBSERVED in the live
        # store (5 and 3 records respectively) firing discoveries; done-with-findings is
        # enumerated by the envelope contract (docs/templates/car-brief.md:47-48). All
        # three must be recognised outcome vocabulary, not discoveries.
        $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Record -Store $store -Subject 'disp-done'      -Kind 'returned' -At '2026-07-22T10:00:00Z' -Outcome 'done'
        New-Record -Store $store -Subject 'disp-confirm'   -Kind 'returned' -At '2026-07-22T10:00:01Z' -Outcome 'CONFIRM'
        New-Record -Store $store -Subject 'disp-dwf'       -Kind 'returned' -At '2026-07-22T10:00:02Z' -Outcome 'done-with-findings'
        $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T11:00:00Z'
        $fold.discoveries | Should -Not -Contain 'outcome: done'
        $fold.discoveries | Should -Not -Contain 'outcome: CONFIRM'
        $fold.discoveries | Should -Not -Contain 'outcome: done-with-findings'
    }

    It 'an unrecognised vocabulary value is reported BY NAME as a discovery' {
        $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Record -Store $store -Subject 'mig-1' -Kind 'migrated' -At '2026-07-22T10:00:00Z'
        $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T11:00:00Z'
        $fold.discoveries | Should -Contain 'kind: migrated'
    }

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

    It 'F1: within-kind latest-at winner resolves by chronological instant, not lexical string, across mixed offsets' {
        # recA at 2026-07-22T14:18:03-04:00 == 18:18:03Z (chronologically LATER)
        # recB at 2026-07-22T16:39:57Z                   (chronologically EARLIER, but its
        # string sorts lexically AFTER recA's -- '16' > '14' -- so a lexical-descending
        # sort picks recB as the (wrong) winner)
        $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Record -Store $store -Subject 'disp-offset' -Kind 'returned' -At '2026-07-22T14:18:03-04:00' -Outcome 'CHRONO-LATEST'
        New-Record -Store $store -Subject 'disp-offset' -Kind 'returned' -At '2026-07-22T16:39:57Z' -Outcome 'LEXICAL-LATEST-BUT-CHRONO-EARLIER'
        $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T20:00:00Z'
        $e = @($fold.dispatches) | Where-Object { $_.subject -eq 'disp-offset' }
        $e.outcome | Should -Be 'CHRONO-LATEST'
    }

    It 'F1: intent supersession resolves by chronological instant, not lexical string, across mixed offsets' {
        # recA (2026-07-22T14:18:03-04:00 == 18:18:03Z) is the chronologically later hold
        # and must WIN, superseding recB (2026-07-22T16:39:57Z, chronologically earlier).
        # A lexical-descending sort picks recB, letting a withdrawn hold win.
        $store = Join-Path $TestDrive ([guid]::NewGuid().ToString('N'))
        New-Record -Store $store -Subject 'hold-offset' -Kind 'intent' -At '2026-07-22T14:18:03-04:00'
        New-Record -Store $store -Subject 'hold-offset' -Kind 'intent' -At '2026-07-22T16:39:57Z'
        $fold = Invoke-Detector -StoreRoot $store -Now '2026-07-22T20:00:00Z'
        $e = @($fold.intents) | Where-Object { $_.subject -eq 'hold-offset' }
        $e.at | Should -Be '2026-07-22T14:18:03-04:00'
        @($e.superseded).Count | Should -Be 1
        $e.superseded[0].at | Should -Be '2026-07-22T16:39:57Z'
    }
}
