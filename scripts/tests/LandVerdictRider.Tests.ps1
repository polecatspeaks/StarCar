#requires -Version 7.4
# Land-Verdict retirement rider (Task B.4, C2R1-M7). The retirement targets the SCRAPING
# (Get-LiveTranscriptPath deriving the parent transcript's path from a hardcoded project
# dir at :59) - the producer replaces that via the hook payload. The EXTRACTION function
# (Get-ResultBlockForTask) STAYS: backfill (spec [m3]) happens precisely when no hook
# fired, the operator hands the CLI an explicit -TranscriptPath, and the extractor consumes
# those lines unchanged. So -TranscriptPath becomes MANDATORY and the deriver is deleted,
# while the extractor is proven still to work.
#
# MARKED DEVIATION (C2R2-m1) from spec S4 row 1: the row prescribes "derivation from the
# git root" as the replacement; this deletes the deriver instead, because the live path now
# arrives via the producer's hook payload and an auto-deriver would be dead code the moment
# B.2 landed.

Describe 'Land-Verdict requires an explicit transcript (deriver retired)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:LandVerdict = Join-Path $script:RepoRoot 'scripts/Land-Verdict.ps1'
    }

    It 'refuses to run without -TranscriptPath, naming the missing mandatory parameter' {
        # Child process, non-interactive: a missing mandatory parameter errors immediately
        # (it cannot prompt) rather than hanging.
        $out = & pwsh -NoProfile -NonInteractive -File $script:LandVerdict `
            -TaskId 't' -Out (Join-Path $TestDrive 'x.md') -Title 'T' -Gate 'G' `
            -Target 'X' -Base 'abc123' -Verdict 'REJECT' 2>&1
        $LASTEXITCODE | Should -Not -Be 0
        ($out -join "`n") | Should -Match 'missing mandatory parameter'
    }
}

Describe 'Land-Verdict retains the extractor (Get-ResultBlockForTask)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:LandVerdict = Join-Path $script:RepoRoot 'scripts/Land-Verdict.ps1'
        $script:VerifyVerdict = Join-Path $script:RepoRoot 'scripts/Verify-Verdict.ps1'

        function New-TempRepo {
            $repo = Join-Path ([System.IO.Path]::GetTempPath()) ("lvtest-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $repo -Force | Out-Null
            git -C $repo init -q | Out-Null
            git -C $repo config user.email 'test@starcar.local' | Out-Null
            git -C $repo config user.name 'LV Test' | Out-Null
            $repo
        }

        function New-Transcript {
            param([string]$Repo, [string]$TaskId, [string]$Body)
            $text = "Notification. <task-id>$TaskId</task-id> here is the <result>$Body</result> end."
            $line = @{ content = @(@{ type = 'text'; text = $text }) } | ConvertTo-Json -Depth 10 -Compress
            $tp = Join-Path $Repo 'transcript.jsonl'
            Set-Content -Path $tp -Value $line -Encoding utf8
            $tp
        }
    }

    It 'lands a verdict body extracted from an explicit transcript, and it verifies' {
        $repo = New-TempRepo
        $tp = New-Transcript -Repo $repo -TaskId 'TASK1' -Body 'the extracted verdict body for TASK1'
        Push-Location $repo
        try {
            & $script:LandVerdict -TaskId 'TASK1' -Out 'landed.md' -Title 'T' -Gate 'G' `
                -Target 'X' -Base 'abc123' -Verdict 'REJECT' -TranscriptPath $tp -Force | Out-Null
        } finally { Pop-Location }
        $landed = Join-Path $repo 'landed.md'
        Test-Path $landed | Should -BeTrue
        (Get-Content $landed -Raw) | Should -Match 'the extracted verdict body for TASK1'
        & $script:VerifyVerdict -Path $landed | Out-Null
        $LASTEXITCODE | Should -Be 0
    }

    It 'NON-VACUITY: a task id with no result block fails - the extractor really matches' {
        $repo = New-TempRepo
        $tp = New-Transcript -Repo $repo -TaskId 'TASK1' -Body 'present'
        # A missing result block is a terminating error (ErrorActionPreference=Stop in the
        # script); catch it and inspect the message rather than letting it fail the test.
        $msg = ''
        Push-Location $repo
        try {
            & $script:LandVerdict -TaskId 'NO-SUCH-TASK' -Out 'landed.md' -Title 'T' -Gate 'G' `
                -Target 'X' -Base 'abc123' -Verdict 'REJECT' -TranscriptPath $tp -Force 2>&1 | Out-Null
        } catch { $msg = $_.Exception.Message } finally { Pop-Location }
        $msg | Should -Match 'No <result> block found'
    }
}

Describe 'Producer agent_type filter NON-VACUITY (spec S6 M5 flood)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:Producer = Join-Path $script:RepoRoot 'scripts/Produce-Artifact.ps1'
        $script:Fixtures = Join-Path $script:RepoRoot 'scripts/tests/fixtures/payloads'

        function New-TempRepo2 {
            $repo = Join-Path ([System.IO.Path]::GetTempPath()) ("floodtest-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $repo -Force | Out-Null
            git -C $repo init -q | Out-Null
            git -C $repo config user.email 'test@starcar.local' | Out-Null
            git -C $repo config user.name 'Flood Test' | Out-Null
            Set-Content -Path (Join-Path $repo 'README') -Value 'seed' -Encoding utf8
            git -C $repo add README | Out-Null
            git -C $repo commit -q -m seed | Out-Null
            $repo
        }
        function Payload([string]$Name) {
            (Get-Content (Join-Path $script:Fixtures $Name) -Raw) -replace '<repo>', ($script:RepoRoot -replace '\\', '/')
        }
    }

    It 'the filter is load-bearing: filtered=1 record over two stop payloads, unfiltered=2' {
        # --- filter PRESENT (the shipped producer): only the car (non-empty agent_type) writes
        $repo1 = New-TempRepo2
        $store1 = Join-Path $repo1 'artifacts'
        Payload 'stop-car.json'      | & $script:Producer -Kind returned -StoreRoot $store1 -Now '2026-07-22T10:00:00Z' | Out-Null
        Payload 'stop-internal.json' | & $script:Producer -Kind returned -StoreRoot $store1 -Now '2026-07-22T10:01:00Z' | Out-Null
        $filtered = @(Get-ChildItem -Path $store1 -Recurse -Filter *.json -ErrorAction SilentlyContinue).Count

        # --- filter REMOVED (a patched COPY; the shipped file is never touched, revert is
        #     byte-identical by construction) -> both payloads write
        $patchDir = Join-Path ([System.IO.Path]::GetTempPath()) ("floodpatch-" + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $patchDir -Force | Out-Null
        Copy-Item (Join-Path $script:RepoRoot 'scripts/Envelope.psm1') (Join-Path $patchDir 'Envelope.psm1')
        $src = Get-Content $script:Producer -Raw
        $patched = $src -replace [regex]::Escape("if ([string]::IsNullOrWhiteSpace(`$agentType)) { exit 0 }   # internal subagent: no record"), '# FLOOD INJECTION: agent_type filter removed'
        $patched | Set-Content -Path (Join-Path $patchDir 'Produce-Artifact.ps1') -Encoding utf8
        $patchedScript = Join-Path $patchDir 'Produce-Artifact.ps1'
        # sanity: the filter line really was removed (else the injection proves nothing)
        (Get-Content $patchedScript -Raw) | Should -Match 'FLOOD INJECTION'

        $repo2 = New-TempRepo2
        $store2 = Join-Path $repo2 'artifacts'
        Payload 'stop-car.json'      | & $patchedScript -Kind returned -StoreRoot $store2 -Now '2026-07-22T10:00:00Z' | Out-Null
        Payload 'stop-internal.json' | & $patchedScript -Kind returned -StoreRoot $store2 -Now '2026-07-22T10:01:00Z' | Out-Null
        $unfiltered = @(Get-ChildItem -Path $store2 -Recurse -Filter *.json -ErrorAction SilentlyContinue).Count

        $filtered   | Should -Be 1
        $unfiltered | Should -Be 2
    }
}
