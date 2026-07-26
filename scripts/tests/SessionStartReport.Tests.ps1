# SessionStartReport.Tests.ps1 -- #50: deliver the four SessionStart guards' combined
# output to a Copilot session, which does not inject SessionStart hook stdout into
# agent context (probed #50, docs/design/2026-07-24-family-agnostic-harness-design.md
# §2c row: "the guards' stdout never reaches the agent context ... announce-to-nobody
# on this runtime"). Claude Code's stdout-injection path must stay byte-identical.
#
# MECHANISM (car's choice, per brief): a small recording script,
# .claude/hooks/session-start-record.sh, wired as the RIGHT side of a two-stage pipe in
# .claude/settings.json - `sh .claude/hooks/GUARD.sh | sh .claude/hooks/session-start-
# record.sh [--reset]`. It `tee -a`s the guard's stdout through to real stdout
# unchanged and appends the same bytes to a gitignored .claude/session-start-report.txt.
# `--reset` is attached to exactly ONE settings.json line (the first,
# goodnight-resume-check.sh) so the file is truncated once per SessionStart batch,
# never once per guard - a per-guard truncate (`>` instead of `>>`, or --reset on every
# line) would silently drop every earlier guard's contribution, which is the race this
# suite's "truncation race" tests exist to catch.
#
# This does NOT invoke session-start-ci-baseline.sh (network-dependent: `gh run list`
# against GitHub) in the acceptance-level tests below, deliberately - a Pester suite
# should not depend on network reachability or CI history existing for the current
# branch. The mechanism is proven against synthetic fixture "guards" (unit tier) and
# against the two REAL guards that need no network (retro, goodnight - both env-var
# overridable), which is sufficient to prove the recording mechanism handles both an
# emitting guard and a legitimately-silent one without needing ci-baseline specifically.

Describe 'session-start-record.sh: the recording mechanism in isolation (#50)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        # Forward slashes, never backslashes: this path is embedded into a shell
        # command STRING below (unlike a normal PowerShell native-command argument,
        # which PowerShell would marshal correctly on its own). A Windows-style
        # backslash path nested inside a manually-built `sh -c "..."` string survives
        # TWO argv-quoting layers (PowerShell's own native-arg marshaling, then Git's
        # sh.exe C-runtime argv parser) - probed, this car: with backslashes the path
        # arrived at the child shell with every backslash silently stripped
        # ("C:UsersChris...", no separators at all). Forward slashes sidestep both
        # layers since Windows accepts them as path separators too, and the repo path
        # has no spaces to quote for in the first place.
        $script:RecordScript = (Join-Path $script:RepoRoot '.claude/hooks/session-start-record.sh') -replace '\\', '/'

        function New-TempReportPath {
            Join-Path ([System.IO.Path]::GetTempPath()) ("ssr-report-" + [guid]::NewGuid().ToString('N') + '.txt')
        }

        # Runs a guard-shaped command through the pipe, with REPORT_FILE overridden -
        # the same override-with-default shape as CHECKPOINT_FILE in
        # session-start-checkpoint-reconcile.sh.
        function Invoke-RecordPipeline {
            param(
                [string]$GuardCommand,   # e.g. "echo hello"
                [string]$ReportFile,
                [switch]$Reset
            )
            $resetArg = if ($Reset) { '--reset' } else { '' }
            $origReport = $env:REPORT_FILE
            $env:REPORT_FILE = $ReportFile
            try {
                $pipeline = "$GuardCommand | sh $script:RecordScript $resetArg"
                & sh -c $pipeline 2>&1
            } finally {
                $env:REPORT_FILE = $origReport
            }
        }
    }

    It 'the recording script exists at .claude/hooks/session-start-record.sh' {
        Test-Path $script:RecordScript | Should -BeTrue
    }

    It '--reset creates the report file with a fresh timestamp marker as the first line' {
        $report = New-TempReportPath
        Invoke-RecordPipeline -GuardCommand 'echo guard-one-output' -ReportFile $report -Reset | Out-Null
        $lines = Get-Content $report
        $lines[0] | Should -Match '^\[session-start-report\] \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$'
        ($lines -join "`n") | Should -Match 'guard-one-output'
    }

    It 'non-reset calls APPEND: all emitting guards survive in one file, not just the last (truncation race)' {
        $report = New-TempReportPath
        Invoke-RecordPipeline -GuardCommand 'echo from-guard-A' -ReportFile $report -Reset | Out-Null
        Invoke-RecordPipeline -GuardCommand 'echo from-guard-B' -ReportFile $report | Out-Null
        Invoke-RecordPipeline -GuardCommand 'echo from-guard-C' -ReportFile $report | Out-Null
        $content = Get-Content $report -Raw
        # A naive truncate-per-hook bug (`>` instead of `>>`, or --reset on every call)
        # would leave ONLY from-guard-C. All three must be present.
        $content | Should -Match 'from-guard-A'
        $content | Should -Match 'from-guard-B'
        $content | Should -Match 'from-guard-C'
    }

    It '--reset on a later call truncates STALE content from a prior session, not just appends' {
        $report = New-TempReportPath
        Invoke-RecordPipeline -GuardCommand 'echo stale-session-content' -ReportFile $report -Reset | Out-Null
        (Get-Content $report -Raw) | Should -Match 'stale-session-content'

        # A fresh session start: --reset again should wipe the stale content.
        Invoke-RecordPipeline -GuardCommand 'echo fresh-session-content' -ReportFile $report -Reset | Out-Null
        $content = Get-Content $report -Raw
        $content | Should -Not -Match 'stale-session-content'
        $content | Should -Match 'fresh-session-content'
    }

    It 'passes a guard''s stdout through unchanged (byte for byte) in addition to recording it' {
        $report = New-TempReportPath
        $direct = & sh -c 'printf "line-one\nline-two\n"' 2>&1
        # A single `printf` call (never `;`-joined statements): GuardCommand becomes
        # the LEFT side of a pipe inside Invoke-RecordPipeline's own `sh -c $pipeline`,
        # and a bare `;` there would split the pipeline at shell-parse time (only the
        # LAST semicolon-separated statement would actually feed the pipe), which is
        # not what this test wants to exercise.
        $piped = Invoke-RecordPipeline -GuardCommand 'printf "line-one\nline-two\n"' -ReportFile $report -Reset
        ($piped -join "`n") | Should -Be ($direct -join "`n")
    }

    It 'a silent guard (no stdout) writes nothing new to the file and prints nothing' {
        $report = New-TempReportPath
        Invoke-RecordPipeline -GuardCommand 'echo baseline' -ReportFile $report -Reset | Out-Null
        $before = Get-Content $report -Raw
        $output = Invoke-RecordPipeline -GuardCommand 'true' -ReportFile $report
        ($output -join '') | Should -BeNullOrEmpty
        (Get-Content $report -Raw) | Should -Be $before
    }
}

Describe '.claude/settings.json SessionStart wiring routes the four guards through the recorder (#50)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:Settings = Get-Content (Join-Path $script:RepoRoot '.claude/settings.json') -Raw | ConvertFrom-Json
        $script:SessionStartHooks = $script:Settings.hooks.SessionStart[0].hooks
    }

    It 'exactly one SessionStart line carries --reset, and it is the first (goodnight-resume-check.sh)' {
        $resetLines = $script:SessionStartHooks | Where-Object { $_.command -match '--reset' }
        $resetLines.Count | Should -Be 1
        $resetLines[0].command | Should -Match 'goodnight-resume-check\.sh'
        $script:SessionStartHooks[0].command | Should -Match '--reset'
    }

    It 'all four guard lines (not the fifth, entire wrapper) pipe through session-start-record.sh' {
        for ($i = 0; $i -lt 4; $i++) {
            $script:SessionStartHooks[$i].command | Should -Match '\| sh \.claude/hooks/session-start-record\.sh'
        }
        # The fifth line (entire-CLI wrapper, #50 task 1) is out of scope for task 2's
        # delivery mechanism - its own present/absent branches are unrelated content.
        $script:SessionStartHooks[4].command | Should -Not -Match 'session-start-record\.sh'
    }

    It 'no SessionStart command reintroduces the fancy-quoting failure signature (nested sh -c / single quotes)' {
        # The actual documented failure (docs/friction-log.md 2026-07-24): a nested
        # `sh -c '...'` wrapper with escaped-JSON quoting broke Copilot's parser. A
        # plain two-stage pipe (`sh a.sh | sh b.sh --reset`) carries neither `-c` nor
        # any quote character, so this stays a meaningful invariant across both the
        # #50 fifth-line fix and this task's pipe-based delivery mechanism.
        $violators = @()
        foreach ($hook in $script:SessionStartHooks) {
            if ($hook.command -match "sh -c" -or $hook.command -match "'") {
                $violators += $hook.command
            }
        }
        $violators -join "`n---`n" | Should -BeNullOrEmpty
    }
}

Describe 'End-to-end with real project guards, no network dependency (#50)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        # Forward slashes throughout - same reason as the isolation-tier BeforeAll
        # above (these paths are embedded into a manually-built `sh -c "..."` string).
        $script:RecordScript = (Join-Path $script:RepoRoot '.claude/hooks/session-start-record.sh') -replace '\\', '/'
        $script:RetroHook = (Join-Path $script:RepoRoot '.claude/hooks/session-start-retro.sh') -replace '\\', '/'
        $script:GoodnightHook = (Join-Path $script:RepoRoot '.claude/hooks/goodnight-resume-check.sh') -replace '\\', '/'
    }

    It 'retro (always emits, no network) lands its real output in the report file; goodnight (no packet) stays legitimately silent, and does not clobber retro''s line' {
        $report = Join-Path ([System.IO.Path]::GetTempPath()) ("ssr-e2e-" + [guid]::NewGuid().ToString('N') + '.txt')
        $emptyHome = Join-Path ([System.IO.Path]::GetTempPath()) ("ssr-home-" + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $emptyHome -Force | Out-Null

        $origReport = $env:REPORT_FILE
        $origHome = $env:HOME
        $origProjectDir = $env:CLAUDE_PROJECT_DIR
        $env:REPORT_FILE = $report
        $env:CLAUDE_PROJECT_DIR = $script:RepoRoot
        try {
            # goodnight-resume-check.sh runs FIRST in the real settings.json array and
            # carries --reset; HOME is overridden to a fresh empty dir so no resume
            # packet exists (deterministic silence), matching the "silent guards
            # legitimately write nothing" case.
            $env:HOME = $emptyHome
            & sh -c "sh $script:GoodnightHook | sh $script:RecordScript --reset" 2>&1 | Out-Null

            # retro runs next, no --reset, deterministic (no network): its STANDING
            # ITEM line is unconditional regardless of friction-log content.
            $env:HOME = $origHome
            & sh -c "sh $script:RetroHook | sh $script:RecordScript" 2>&1 | Out-Null
        } finally {
            $env:REPORT_FILE = $origReport
            $env:HOME = $origHome
            $env:CLAUDE_PROJECT_DIR = $origProjectDir
            Remove-Item -Recurse -Force $emptyHome -ErrorAction SilentlyContinue
        }

        Test-Path $report | Should -BeTrue
        $content = Get-Content $report -Raw
        $content | Should -Match '^\[session-start-report\] \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z'
        $content | Should -Match '\[retro\] STANDING ITEM'
        # goodnight legitimately printed nothing (no packet), so its ABSENCE from the
        # file is correct - and critically, its --reset did not wipe anything AFTER it
        # because nothing ran after it in this ordering; retro's own append must still
        # land alongside the marker, proving append-after-reset works end to end.
    }
}
