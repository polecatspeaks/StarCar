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
        $script:CreatedFixtureDirs = New-Object 'System.Collections.Generic.List[string]'

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
        # override precedent (session-start-checkpoint-reconcile.sh:54 - the
        # ASSIGNMENT line; :50-52 is that file's TEST OVERRIDE comment block, m-a) via
        # a GUARD_DIR override. Every directory this function creates is tracked and
        # removed in the Describe's AfterAll (m-b, round-4 REJECT minor: unbounded
        # +2-per-run temp-dir accumulation, measured).
        function New-FixtureGuardDir {
            $dir = Join-Path ([System.IO.Path]::GetTempPath()) ("guard-runner-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $script:CreatedFixtureDirs.Add($dir)
            Set-Content -Path (Join-Path $dir 'goodnight-resume-check.sh') -Value "#!/bin/sh`necho FIXTURE-GOODNIGHT-RAN`nexit 1`n" -Encoding utf8
            Set-Content -Path (Join-Path $dir 'session-start-checkpoint-reconcile.sh') -Value "#!/bin/sh`necho FIXTURE-CHECKPOINT-RAN`n" -Encoding utf8
            Set-Content -Path (Join-Path $dir 'session-start-ci-baseline.sh') -Value "#!/bin/sh`necho FIXTURE-CI-BASELINE-RAN`n" -Encoding utf8
            Set-Content -Path (Join-Path $dir 'session-start-retro.sh') -Value "#!/bin/sh`necho FIXTURE-RETRO-RAN`n" -Encoding utf8
            $dir
        }
    }

    AfterAll {
        foreach ($d in $script:CreatedFixtureDirs) {
            Remove-Item -Recurse -Force -Path $d -ErrorAction SilentlyContinue
        }
    }

    It 'the runner exists at .claude/hooks/run-session-start-guards.sh' {
        Test-Path $script:Runner | Should -BeTrue
    }

    It 'running the REAL guards prints the ONE unconditionally-emitting guard''s marker ([retro])' {
        # FIX CYCLE ROUND 5, finding R4-1: the ORIGINAL version of this test asserted
        # [ci-baseline] was "always-emitting" alongside [retro]. It is not:
        # session-start-ci-baseline.sh:25-26 exits SILENTLY when `git branch
        # --show-current` is empty - the state of every DETACHED checkout, including
        # this repo's own PR-CI checkout on both matrix legs (observed,
        # .github/workflows/ci.yml + actions/checkout@v4 on pull_request) and every
        # reviewer worktree in this shop. The false assertion made this suite GREEN on
        # dev pushes and RED on the merge PR - reproduced verbatim in THIS worktree via
        # `git checkout --detach` before this fix (see this car's report). [retro] is
        # the only one of the four guards whose BOTH branches unconditionally echo
        # (session-start-retro.sh:13-23) - it is asserted alone, unconditionally, here.
        $r = Invoke-Runner
        $r.Output | Should -Match '\[retro\]'
    }

    It 'running the REAL guards prints [ci-baseline]''s marker ONLY when attached to a branch - conditional, never asserted as always-emitting' {
        # session-start-ci-baseline.sh:24-26 exits silently unless BOTH `gh` is on
        # PATH and `git branch --show-current` is non-empty. This test states the
        # precondition honestly and skips the positive assertion when the precondition
        # does not hold, rather than repeating R4-1's mistake of asserting a
        # conditional guard unconditionally. A detached worktree (this repo's own PR-CI
        # checkout state) legitimately sees this guard silent - that is not a defect.
        $branch = (git branch --show-current 2>$null)
        if ([string]::IsNullOrWhiteSpace($branch)) {
            Set-ItResult -Skipped -Because 'detached HEAD (no branch) - session-start-ci-baseline.sh is silent by design here, the same state as this repo''s own PR-CI checkout'
            return
        }
        $r = Invoke-Runner
        $r.Output | Should -Match '\[ci-baseline\]'
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

    It 'CLAUDE_PROJECT_DIR unset: the retro guard reports the real friction-log entry count, never the false "create it" line (#50, R4-2)' {
        # FIX CYCLE ROUND 5, finding R4-2: run-session-start-guards.sh established
        # GUARD_DIR but not CLAUDE_PROJECT_DIR, on which session-start-retro.sh:10
        # depends (`LOG="$CLAUDE_PROJECT_DIR/docs/friction-log.md"`). Unset, LOG
        # resolved to "/docs/friction-log.md", and the guard's `else` branch printed
        # "No docs/friction-log.md yet - create it" against a real file holding dozens
        # of entries - a confident falsehood, reproduced verbatim in this worktree
        # with `env -u CLAUDE_PROJECT_DIR` before this fix (see this car's report).
        $origProjectDir = $env:CLAUDE_PROJECT_DIR
        Remove-Item Env:\CLAUDE_PROJECT_DIR -ErrorAction SilentlyContinue
        try {
            $r = Invoke-Runner
            $r.Output | Should -Not -Match 'No docs/friction-log\.md yet - create it'
            $r.Output | Should -Match 'docs/friction-log\.md holds \d+ logged entries\.'
        } finally {
            if ($null -ne $origProjectDir) { $env:CLAUDE_PROJECT_DIR = $origProjectDir }
        }
    }
}
