# SessionStartReport.Tests.ps1 -- #50: deliver the four SessionStart guards' combined
# output to a Copilot session, which does not inject SessionStart hook stdout into
# agent context (probed #50, docs/design/2026-07-24-family-agnostic-harness-design.md
# §2c row: "the guards' stdout never reaches the agent context ... announce-to-nobody
# on this runtime"). Claude Code's stdout-injection path must stay byte-identical.
#
# MECHANISM (car's choice, per brief): a small recording script,
# .claude/hooks/session-start-record.sh, wired as the RIGHT side of a two-stage pipe in
# .claude/settings.json - `sh .claude/hooks/GUARD.sh | sh .claude/hooks/session-start-
# record.sh`. It `tee -a`s the guard's stdout through to real stdout unchanged and
# appends the same bytes to a gitignored .claude/session-start-report.txt.
#
# AMENDED (fix cycle round 2, finding M4): round 1 attached `--reset` to exactly ONE
# settings.json line and assumed the five SessionStart hooks fire sequentially in
# array order - an unstated, unproven assumption the round-1 reviewer measured 2/15
# silent losses under. `--reset` no longer exists as an argument: freshness is now a
# property of the report FILE's own mtime (stale = missing, or older than
# STALE_SECONDS), serialized by an atomic `mkdir` mutex so no two invocations can
# interleave a truncate with another's append. Basic mechanism sanity (this file) and
# the dedicated concurrency/staleness proofs (scripts/tests/
# SessionStartReportConcurrency.Tests.ps1 - genuinely concurrent child processes, many
# trials, zero losses) are split across the two files rather than duplicated.
#
# AMENDED (fix cycle round 2, finding M1): this file previously also asserted "no
# SessionStart command reintroduces the fancy-quoting failure signature (nested sh -c
# / single quotes)" as ITS OWN invariant, disjoint from SessionStartWiring.Tests.ps1's
# (then-narrowed) bare-form check. Round-1 review PROVED that split was the defect: a
# blacklist naming two known-bad shapes is blind to shapes nobody thought to name, and
# an inline `if...fi` compound plus escaped-JSON `printf` (the ACTUAL documented
# Copilot failure signature) passed both suites 15/15 green. The single authority for
# "is this SessionStart command shape legitimate" is now the WHITELIST in
# SessionStartWiring.Tests.ps1 (permits exactly the bare form and the pipe-to-recorder
# form, rejects everything else including shapes not yet imagined) - not duplicated
# here, per Law 6 and the same lesson.
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
        # session-start-checkpoint-reconcile.sh. No --reset argument (fix cycle round
        # 2, M4) - freshness is decided by the report file's own mtime.
        function Invoke-RecordPipeline {
            param([string]$GuardCommand, [string]$ReportFile)
            $origReport = $env:REPORT_FILE
            $env:REPORT_FILE = $ReportFile
            try {
                $pipeline = "$GuardCommand | sh $script:RecordScript"
                & sh -c $pipeline 2>&1
            } finally {
                $env:REPORT_FILE = $origReport
            }
        }
    }

    It 'the recording script exists at .claude/hooks/session-start-record.sh' {
        Test-Path $script:RecordScript | Should -BeTrue
    }

    It 'a fresh/absent report file gets a marker written on the first invocation of a batch' {
        $report = New-TempReportPath
        Invoke-RecordPipeline -GuardCommand 'echo guard-one-output' -ReportFile $report | Out-Null
        $lines = Get-Content $report
        $lines[0] | Should -Match '^\[session-start-report\] \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$'
        ($lines -join "`n") | Should -Match 'guard-one-output'
    }

    It 'subsequent calls in the SAME batch APPEND: all emitting guards survive in one file, not just the last' {
        $report = New-TempReportPath
        Invoke-RecordPipeline -GuardCommand 'echo from-guard-A' -ReportFile $report | Out-Null
        Invoke-RecordPipeline -GuardCommand 'echo from-guard-B' -ReportFile $report | Out-Null
        Invoke-RecordPipeline -GuardCommand 'echo from-guard-C' -ReportFile $report | Out-Null
        $content = Get-Content $report -Raw
        # A naive truncate-per-hook bug (`>` instead of `>>`) would leave ONLY
        # from-guard-C. All three must be present - the fresh mtime each call leaves
        # behind is exactly why the NEXT call sees "not stale" and appends.
        $content | Should -Match 'from-guard-A'
        $content | Should -Match 'from-guard-B'
        $content | Should -Match 'from-guard-C'
    }

    It 'passes a guard''s stdout through unchanged (byte for byte) in addition to recording it' {
        $report = New-TempReportPath
        $direct = & sh -c 'printf "line-one\nline-two\n"' 2>&1
        # A single `printf` call (never `;`-joined statements): GuardCommand becomes
        # the LEFT side of a pipe inside Invoke-RecordPipeline's own `sh -c $pipeline`,
        # and a bare `;` there would split the pipeline at shell-parse time (only the
        # LAST semicolon-separated statement would actually feed the pipe), which is
        # not what this test wants to exercise.
        $piped = Invoke-RecordPipeline -GuardCommand 'printf "line-one\nline-two\n"' -ReportFile $report
        ($piped -join "`n") | Should -Be ($direct -join "`n")
    }

    It 'a silent guard (no stdout) writes nothing new to the file and prints nothing' {
        $report = New-TempReportPath
        Invoke-RecordPipeline -GuardCommand 'echo baseline' -ReportFile $report | Out-Null
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

    It 'no SessionStart line carries --reset (fix cycle round 2, M4: the argument is retired - freshness is a file property now)' {
        $resetLines = $script:SessionStartHooks | Where-Object { $_.command -match '--reset' }
        $resetLines.Count | Should -Be 0
    }

    It 'all four guard lines (not the fifth, entire wrapper) pipe through session-start-record.sh' {
        for ($i = 0; $i -lt 4; $i++) {
            $script:SessionStartHooks[$i].command | Should -Match '\| sh \.claude/hooks/session-start-record\.sh'
        }
        # The fifth line (entire-CLI wrapper, #50 task 1) is out of scope for task 2's
        # delivery mechanism - its own present/absent branches are unrelated content.
        $script:SessionStartHooks[4].command | Should -Not -Match 'session-start-record\.sh'
    }

    # NOTE (fix cycle round 2, M1): the "is this command shape legitimate" check
    # (formerly a blacklist here: no `sh -c`, no single quote) is REMOVED from this
    # file. That blacklist was proven blind to the actual documented failure signature
    # (an inline if-compound, no `sh -c`, no quotes) by round-1 adversarial review.
    # scripts/tests/SessionStartWiring.Tests.ps1 now owns the ONE whitelist covering
    # all five SessionStart lines - not duplicated here.
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
            # goodnight-resume-check.sh runs FIRST in the real settings.json array (no
            # --reset argument any more, fix cycle round 2 M4); HOME is overridden to a
            # fresh empty dir so no resume packet exists (deterministic silence),
            # matching the "silent guards legitimately write nothing" case. The report
            # file is absent, so this call's own staleness check finds it missing and
            # writes the marker regardless of which guard happens to run first.
            $env:HOME = $emptyHome
            & sh -c "sh $script:GoodnightHook | sh $script:RecordScript" 2>&1 | Out-Null

            # retro runs next, deterministic (no network): its STANDING ITEM line is
            # unconditional regardless of friction-log content.
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
        # file is correct - and critically, its own staleness-triggered reset did not
        # wipe anything AFTER it because nothing ran after it in this ordering; retro's
        # own append must still land alongside the marker, proving append-after-reset
        # works end to end.
    }
}
