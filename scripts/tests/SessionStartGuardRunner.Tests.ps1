#requires -Version 7.4
# SessionStartGuardRunner.Tests.ps1 -- #50: .claude/hooks/run-session-start-guards.sh,
# the agent-pull replacement for the deleted push-delivery mechanism (owner ruling,
# 2026-07-26, option d - see docs/design/2026-07-24-family-agnostic-harness-design.md's
# amendment history and artifacts/reviews/ for the full narrative of what was tried and
# retired).
#
# WHY: Claude Code injects SessionStart hook stdout into agent context automatically;
# Copilot CLI does not (probed #50). Two push-based delivery mechanisms (round 1:
# --reset ordering; round 2: mtime + mutex) were both proxies for session-batch
# identity, a fact the record script structurally could not observe (its stdin was
# occupied by guard output, so it could never read the SessionStart payload carrying
# session_id). The owner ruling removes the premise entirely: no shared file, no
# truncation, no race, no mutex. Instead, any agent whose runtime does not inject
# SessionStart stdout runs this ONE script as its first action per the arrival docs
# (.github/copilot-instructions.md, ONBOARDING.md) and reads its own output directly -
# agent-pull, not push. The reliance on the agent actually doing this is UNCHANGED from
# the file-based design (which also relied on the agent reading a file per the arrival
# doc) minus all the mechanism; verifying that reliance holds is issue #55, triggered on
# the next Copilot session, not buildable from this desk.

Describe 'run-session-start-guards.sh: agent-pull runner (#50)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:Runner = (Join-Path $script:RepoRoot '.claude/hooks/run-session-start-guards.sh') -replace '\\', '/'

        function Invoke-Runner {
            param([string]$GuardDir)
            $origGuardDir = $env:GUARD_DIR
            if ($GuardDir) { $env:GUARD_DIR = $GuardDir } else { Remove-Item Env:\GUARD_DIR -ErrorAction SilentlyContinue }
            try {
                $out = & sh $script:Runner 2>&1
                [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($out -join "`n") }
            } finally {
                if ($null -ne $origGuardDir) { $env:GUARD_DIR = $origGuardDir } else { Remove-Item Env:\GUARD_DIR -ErrorAction SilentlyContinue }
            }
        }

        # A fixture guard directory carrying the SAME four filenames the runner
        # invokes by name, one of which (the FIRST, matching goodnight-resume-check.sh's
        # slot) exits nonzero - proves a failing guard does not stop the rest, the
        # runner's own non-fatal-shape requirement. Follows the CHECKPOINT_FILE
        # override precedent (session-start-checkpoint-reconcile.sh:50) via a
        # GUARD_DIR override.
        function New-FixtureGuardDir {
            $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("guard-runner-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Set-Content -Path (Join-Path $dir 'goodnight-resume-check.sh') -Value "#!/bin/sh`necho FIXTURE-GOODNIGHT-RAN`nexit 1`n" -Encoding utf8
            Set-Content -Path (Join-Path $dir 'session-start-checkpoint-reconcile.sh') -Value "#!/bin/sh`necho FIXTURE-CHECKPOINT-RAN`n" -Encoding utf8
            Set-Content -Path (Join-Path $dir 'session-start-ci-baseline.sh') -Value "#!/bin/sh`necho FIXTURE-CI-BASELINE-RAN`n" -Encoding utf8
            Set-Content -Path (Join-Path $dir 'session-start-retro.sh') -Value "#!/bin/sh`necho FIXTURE-RETRO-RAN`n" -Encoding utf8
            $dir
        }
    }

    It 'the runner exists at .claude/hooks/run-session-start-guards.sh' {
        Test-Path $script:Runner | Should -BeTrue
    }

    It 'running the REAL guards prints both always-emitting guards'' markers ([ci-baseline], [retro])' {
        $r = Invoke-Runner
        $r.Output | Should -Match '\[ci-baseline\]'
        $r.Output | Should -Match '\[retro\]'
    }

    It 'the runner itself exits 0 regardless of any individual guard''s exit code (non-fatal shape)' {
        $r = Invoke-Runner
        $r.ExitCode | Should -Be 0
    }

    It 'a FAILING first guard does not stop the remaining three - all four fixture markers appear' {
        $dir = New-FixtureGuardDir
        $r = Invoke-Runner -GuardDir $dir
        $r.Output | Should -Match 'FIXTURE-GOODNIGHT-RAN'
        $r.Output | Should -Match 'FIXTURE-CHECKPOINT-RAN'
        $r.Output | Should -Match 'FIXTURE-CI-BASELINE-RAN'
        $r.Output | Should -Match 'FIXTURE-RETRO-RAN'
        $r.ExitCode | Should -Be 0
    }

    It 'the four guards run in the documented order: goodnight, checkpoint, ci-baseline, retro' {
        $dir = New-FixtureGuardDir
        $r = Invoke-Runner -GuardDir $dir
        $order = @('FIXTURE-GOODNIGHT-RAN', 'FIXTURE-CHECKPOINT-RAN', 'FIXTURE-CI-BASELINE-RAN', 'FIXTURE-RETRO-RAN')
        $positions = $order | ForEach-Object { $r.Output.IndexOf($_) }
        # Every marker must be found (no -1), and in strictly increasing position.
        $positions | ForEach-Object { $_ | Should -BeGreaterThan -1 }
        for ($i = 1; $i -lt $positions.Count; $i++) {
            $positions[$i] | Should -BeGreaterThan $positions[$i - 1]
        }
    }
}
