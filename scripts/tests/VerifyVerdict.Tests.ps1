#requires -Version 7.4
Describe 'Verify-Verdict refuses vacuous passes and crashes' {
    BeforeAll {
        $script:Root   = (git rev-parse --show-toplevel)
        $script:Script = Join-Path $script:Root 'scripts/Verify-Verdict.ps1'
        $script:Empty  = Join-Path $TestDrive 'empty-store'
        New-Item -ItemType Directory -Path $script:Empty | Out-Null
    }

    It 'an ABSENT directory exits non-zero and names it' {
        $out = & pwsh -NoProfile -File $script:Script -ReviewsDir (Join-Path $TestDrive 'no-such-dir') 2>&1
        $LASTEXITCODE | Should -Be 1
        ($out -join ' ') | Should -Match 'no-such-dir'
    }

    It 'a directory with ZERO verdict files exits non-zero with an actionable message, not a crash' {
        $out = & pwsh -NoProfile -File $script:Script -ReviewsDir $script:Empty 2>&1
        $LASTEXITCODE | Should -Be 1
        ($out -join ' ') | Should -Match 'zero verdict files'
        ($out -join ' ') | Should -Not -Match 'PropertyNotFoundStrict'
    }

    It 'the populated default store still verifies clean (no regression)' {
        & pwsh -NoProfile -File $script:Script *> $null
        $LASTEXITCODE | Should -Be 0
    }
}
