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

    It 'lands WITHOUT the entire CLI on PATH (the CI-environment pin - run 8c983a1 red)' {
        # CI run on merge 8c983a1 failed here: Land-Verdict called `entire` unguarded and
        # CI runners do not have it. Simulate the runner: child pwsh whose PATH excludes
        # every directory holding an entire executable, then land a verdict.
        $entireDirs = @(Get-Command entire -All -ErrorAction SilentlyContinue |
            ForEach-Object { Split-Path $_.Source })
        $cleanPath = ($env:PATH -split ';' | Where-Object { $_ -and ($entireDirs -notcontains $_) }) -join ';'

        $repo = New-TempRepo
        $tp = New-Transcript -Repo $repo -TaskId 'TASK2' -Body 'landed without entire on PATH'
        $cmd = "`$env:PATH = '$($cleanPath -replace "'", "''")'; " +
               "if (Get-Command entire -ErrorAction SilentlyContinue) { Write-Error 'probe invalid: entire still resolvable'; exit 9 }; " +
               "Set-Location '$repo'; " +
               "& '$script:LandVerdict' -TaskId 'TASK2' -Out 'landed2.md' -Title 'T' -Gate 'G' " +
               "-Target 'X' -Base 'abc123' -Verdict 'REJECT' -TranscriptPath '$tp' -Force"
        $out = & pwsh -NoProfile -NonInteractive -Command $cmd 2>&1
        $LASTEXITCODE | Should -Be 0 -Because (($out | Select-Object -Last 5) -join ' | ')
        Test-Path (Join-Path $repo 'landed2.md') | Should -BeTrue
        (Get-Content (Join-Path $repo 'landed2.md') -Raw) | Should -Match 'landed without entire on PATH'
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

Describe 'Land-Verdict refuses to land into the retired docs/reviews/ (M-B guard, fix-cycle round 1)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:LandVerdict = Join-Path $script:RepoRoot 'scripts/Land-Verdict.ps1'

        function New-TempRepo3 {
            $repo = Join-Path ([System.IO.Path]::GetTempPath()) ("lvguard-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $repo -Force | Out-Null
            git -C $repo init -q | Out-Null
            git -C $repo config user.email 'test@starcar.local' | Out-Null
            git -C $repo config user.name 'LV Guard Test' | Out-Null
            $repo
        }

        function New-Transcript3 {
            param([string]$Repo, [string]$TaskId, [string]$Body)
            $text = "Notification. <task-id>$TaskId</task-id> here is the <result>$Body</result> end."
            $line = @{ content = @(@{ type = 'text'; text = $text }) } | ConvertTo-Json -Depth 10 -Compress
            $tp = Join-Path $Repo 'transcript.jsonl'
            Set-Content -Path $tp -Value $line -Encoding utf8
            $tp
        }
    }

    It 'REFUSES -Out docs/reviews/<file>.md - R10: nothing lands silently unverified in the retired store' {
        # Child process (pwsh -File), matching the "-TranscriptPath missing" test above:
        # Land-Verdict.ps1 sets $ErrorActionPreference = 'Stop', so Write-Error is a
        # TERMINATING error - invoked in-process via a bare `&`, that exception would
        # propagate into this test's own scriptblock rather than cleanly setting
        # $LASTEXITCODE. A child process isolates it into a real process exit code.
        $repo = New-TempRepo3
        $tp = New-Transcript3 -Repo $repo -TaskId 'TASKG1' -Body 'a verdict aimed at the retired directory'
        Push-Location $repo
        try {
            $out = & pwsh -NoProfile -NonInteractive -File $script:LandVerdict -TaskId 'TASKG1' -Out 'docs/reviews/should-not-land.md' `
                -Title 'T' -Gate 'G' -Target 'X' -Base 'abc123' -Verdict 'REJECT' `
                -TranscriptPath $tp -Force 2>&1
            $exitCode = $LASTEXITCODE
        } finally { Pop-Location }
        $exitCode | Should -Not -Be 0
        ($out -join "`n") | Should -Match 'retired'
        Test-Path (Join-Path $repo 'docs/reviews/should-not-land.md') | Should -BeFalse
    }

    It 'REFUSES a backslash-separated docs\reviews\<file>.md target too' {
        $repo = New-TempRepo3
        $tp = New-Transcript3 -Repo $repo -TaskId 'TASKG2' -Body 'a verdict aimed at the retired directory, backslash form'
        Push-Location $repo
        try {
            $out = & pwsh -NoProfile -NonInteractive -File $script:LandVerdict -TaskId 'TASKG2' -Out 'docs\reviews\should-not-land.md' `
                -Title 'T' -Gate 'G' -Target 'X' -Base 'abc123' -Verdict 'REJECT' `
                -TranscriptPath $tp -Force 2>&1
            $exitCode = $LASTEXITCODE
        } finally { Pop-Location }
        $exitCode | Should -Not -Be 0
        ($out -join "`n") | Should -Match 'retired'
    }

    It 'ALLOWS -Out artifacts/reviews/<file>.md (the current R10 convention) - the guard is narrow, not a general refusal' {
        $repo = New-TempRepo3
        $tp = New-Transcript3 -Repo $repo -TaskId 'TASKG3' -Body 'a verdict aimed at the correct directory'
        Push-Location $repo
        try {
            & $script:LandVerdict -TaskId 'TASKG3' -Out 'artifacts/reviews/should-land.md' `
                -Title 'T' -Gate 'G' -Target 'X' -Base 'abc123' -Verdict 'REJECT' `
                -TranscriptPath $tp -Force | Out-Null
        } finally { Pop-Location }
        Test-Path (Join-Path $repo 'artifacts/reviews/should-land.md') | Should -BeTrue
    }

    It 'does NOT false-positive on an unrelated path that merely contains the substrings docs and reviews' {
        $repo = New-TempRepo3
        $tp = New-Transcript3 -Repo $repo -TaskId 'TASKG4' -Body 'a verdict aimed at a look-alike path'
        Push-Location $repo
        try {
            & $script:LandVerdict -TaskId 'TASKG4' -Out 'mydocs/reviews-archive/x.md' `
                -Title 'T' -Gate 'G' -Target 'X' -Base 'abc123' -Verdict 'REJECT' `
                -TranscriptPath $tp -Force | Out-Null
        } finally { Pop-Location }
        Test-Path (Join-Path $repo 'mydocs/reviews-archive/x.md') | Should -BeTrue
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
        # F4 (docs/plans/2026-07-22-pr18-correctness-fixes-plan.md) gave Produce-Artifact.ps1
        # a second module dependency (Get-Sha256Hex, extracted to Artifact.psm1) -- the
        # patched copy needs it alongside it too, same as Envelope.psm1 above.
        Copy-Item (Join-Path $script:RepoRoot 'scripts/Artifact.psm1') (Join-Path $patchDir 'Artifact.psm1')
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
