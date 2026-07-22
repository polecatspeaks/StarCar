#requires -Version 7.4
# CiWrapperSimulation.Tests.ps1 -- reproduces GitHub Actions' `shell: pwsh` wrapper
# behavior against ci.yml's OWN "Fetch the Entire checkpoint branch" step body, so a
# future edit to that step cannot silently reintroduce the M-A defect (fix-cycle round
# 1, reviewer catch): GitHub Actions appends
# `if ((Test-Path -LiteralPath variable:\LASTEXITCODE)) { exit $LASTEXITCODE }` after
# every `shell: pwsh` run: block. A step whose own script never calls `exit` can still
# fail the build on a leftover nonzero $LASTEXITCODE from an INTERNAL command - here,
# `git fetch` on an absent ref (exit 128) - even though the script's own if/else only
# Write-Hosts. "Non-fatal if absent" was false by construction until the absence branch
# explicitly reset $LASTEXITCODE to 0.
#
# This test extracts the REAL run: text from .github/workflows/ci.yml via YAML parsing
# (never a hand-copied duplicate, which would drift silently the moment someone edits
# the step) and executes it, plus the wrapper's own appended suffix, as a real child
# pwsh process against two REAL fixture git remotes: one missing
# entire/checkpoints/v1 (the fork case) and one carrying it. Both must exit 0.

Describe 'CI checkpoint-fetch step - GitHub Actions shell:pwsh wrapper simulation (M-A regression)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:CiYamlPath = Join-Path $script:RepoRoot '.github/workflows/ci.yml'
        if (-not (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue)) {
            throw ('ConvertFrom-Yaml unavailable: install the powershell-yaml module ' +
                   '(ci.yml installs it with retry; on a local box: Install-Module powershell-yaml). ' +
                   'This test parses the REAL ci.yml step text and cannot run without it.')
        }
        $parsed = Get-Content $script:CiYamlPath -Raw | ConvertFrom-Yaml
        $step = $parsed.jobs.verify.steps | Where-Object { $_.name -like 'Fetch the Entire checkpoint branch*' }
        if (-not $step) { throw "ci.yml: the 'Fetch the Entire checkpoint branch' step was not found - renamed or removed?" }
        $script:StepRun = [string]$step.run

        # GitHub Actions' own documented appended suffix for shell: pwsh - the substrate
        # fact this whole test pins. Backtick-escaped so $LASTEXITCODE is written
        # LITERALLY to the generated script file, for the CHILD pwsh process to expand,
        # never interpolated here.
        $script:WrapperSuffix = "`nif ((Test-Path -LiteralPath variable:\LASTEXITCODE)) { exit `$LASTEXITCODE }`n"

        function New-BareFixtureRemote {
            param([switch]$WithCheckpointBranch)
            $bare = Join-Path ([System.IO.Path]::GetTempPath()) ("ciwrap-remote-" + [guid]::NewGuid().ToString('N'))
            git init -q --bare $bare | Out-Null
            if ($WithCheckpointBranch) {
                $seed = Join-Path ([System.IO.Path]::GetTempPath()) ("ciwrap-seed-" + [guid]::NewGuid().ToString('N'))
                New-Item -ItemType Directory -Path $seed -Force | Out-Null
                git -C $seed init -q | Out-Null
                git -C $seed config user.email 'ciwrap@starcar.local' | Out-Null
                git -C $seed config user.name 'CI Wrapper Test' | Out-Null
                Set-Content -Path (Join-Path $seed 'x') -Value 'x' -Encoding utf8
                git -C $seed add x | Out-Null
                git -C $seed commit -q -m seed | Out-Null
                git -C $seed branch entire/checkpoints/v1 | Out-Null
                git -C $seed push -q $bare --all | Out-Null
            }
            $bare
        }

        function New-ScratchClone {
            param([string]$RemotePath)
            $clone = Join-Path ([System.IO.Path]::GetTempPath()) ("ciwrap-clone-" + [guid]::NewGuid().ToString('N'))
            git clone -q $RemotePath $clone 2>&1 | Out-Null
            $clone
        }

        function Invoke-WrapperSimulation {
            param([string]$WorkingDir)
            $scriptPath = Join-Path ([System.IO.Path]::GetTempPath()) ("ciwrap-step-" + [guid]::NewGuid().ToString('N') + '.ps1')
            [System.IO.File]::WriteAllText($scriptPath, $script:StepRun + $script:WrapperSuffix)
            Push-Location $WorkingDir
            try {
                & pwsh -NoProfile -File $scriptPath | Out-Null
                $exitCode = $LASTEXITCODE
            } finally {
                Pop-Location
            }
            $exitCode
        }
    }

    It 'exits 0 when entire/checkpoints/v1 is ABSENT on the remote (the fork case, M-A)' {
        $remote = New-BareFixtureRemote
        $clone = New-ScratchClone -RemotePath $remote
        $exit = Invoke-WrapperSimulation -WorkingDir $clone
        $exit | Should -Be 0
    }

    It 'exits 0 when entire/checkpoints/v1 IS PRESENT on the remote' {
        $remote = New-BareFixtureRemote -WithCheckpointBranch
        $clone = New-ScratchClone -RemotePath $remote
        $exit = Invoke-WrapperSimulation -WorkingDir $clone
        $exit | Should -Be 0
    }
}
