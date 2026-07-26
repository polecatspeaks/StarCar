# SessionStartWiring.Tests.ps1 -- #50: the fifth SessionStart hook line stays in the
# bare intersection dialect (`sh .claude/hooks/NAME.sh`, no inline `-c`, no quoting
# layers), and the entire-CLI wrapper script preserves its exact behavior once moved
# out of the inline `sh -c` form.
#
# WHY: docs/friction-log.md (2026-07-24 entries) - under Copilot CLI's Claude-compat
# layer, the fifth SessionStart line (an inline `sh -c '...'` wrapper with an
# escaped-JSON printf fallback) broke the WHOLE SessionStart invocation with
# `syntax error: unexpected end of file from 'if' command`, while the four sibling
# guards (already simple-form: `sh .claude/hooks/NAME.sh`) executed fine. Local
# reproduction was ATTEMPTED and DID NOT reproduce the parse error: the extracted
# command string passed `sh -n` and `dash -n` (both exit 0) and executed correctly
# under both `sh -c` (bash-as-sh) and `dash -c` on this box (probed, this car,
# 2026-07-26 - not landed as a test because there is nothing here to pin: the failure
# is a property of Copilot's own shell invocation, not of this box's shells). The fix
# therefore stands on the design's own simple-form rule (docs/design/2026-07-24-family-
# agnostic-harness-design.md D4/D5: "intersection dialect for the four SessionStart
# guards... one manifest" - carried verbatim from the retired dual-runtime design's D1),
# extended to the fifth line so it is no longer the one structural outlier.
#
# AMENDED (#50 task 2, same car): the FIRST assertion below originally required ALL
# FIVE SessionStart lines to match the bare `sh .claude/hooks/NAME.sh` form. Task 2
# legitimately routes the four GUARD lines through a two-stage pipe
# (`sh GUARD.sh | sh session-start-record.sh [--reset]`) so their combined stdout also
# reaches a Copilot session (scripts/tests/SessionStartReport.Tests.ps1 owns that
# mechanism's own tests). The bare-form assertion is narrowed here to the ONE line it
# is still permanently true of - the fifth (entire-CLI wrapper) line, out of scope for
# task 2's delivery mechanism by the brief's own scope guard. The broader "no fancy
# quoting anywhere in SessionStart" invariant (the actual failure signature: nested
# `sh -c` / single quotes) now lives in SessionStartReport.Tests.ps1, which also
# asserts the four guard lines' pipe wiring - not duplicated here.
#
# This test reads the REAL .claude/settings.json (never a hand-copied duplicate, which
# would drift silently the moment someone edits the file) - same discipline as
# CiWrapperSimulation.Tests.ps1's ci.yml extraction.

Describe 'SessionStart wiring: the fifth line stays bare intersection dialect (#50)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:SettingsPath = Join-Path $script:RepoRoot '.claude/settings.json'
        $script:Settings = Get-Content $script:SettingsPath -Raw | ConvertFrom-Json
        $script:SessionStartHooks = $script:Settings.hooks.SessionStart[0].hooks
        # Simple form: `sh .claude/hooks/<name>.sh`, no inline `-c`, no quoting layers.
        $script:SimpleFormPattern = '^sh \.claude/hooks/[A-Za-z0-9_-]+\.sh$'
    }

    It 'finds SessionStart hooks to check (a check that examines nothing is not a pass)' {
        $script:SessionStartHooks.Count | Should -BeGreaterThan 0
    }

    It 'the fifth SessionStart hook command (entire-CLI wrapper) is bare simple-form: sh .claude/hooks/NAME.sh' {
        $fifth = $script:SessionStartHooks[4].command
        $fifth | Should -Match $script:SimpleFormPattern
        $fifth | Should -Be 'sh .claude/hooks/session-start-entire.sh'
    }
}

Describe 'session-start-entire.sh preserves the inline wrapper''s exact behavior (#50)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:HookPath = Join-Path $script:RepoRoot '.claude/hooks/session-start-entire.sh'
        # The byte-for-byte expected fallback line, taken from the ORIGINAL inline
        # command in git history at base commit 5ea6c0c (never hand-retyped from memory):
        # `git show 5ea6c0c:.claude/settings.json | jq -r '.hooks.SessionStart[0].hooks[4].command'`
        $script:ExpectedFallbackJson = '{"systemMessage":"\n\nEntire CLI is enabled but not installed or not on PATH.\nInstallation guide: https://docs.entire.io/cli/installation#installation-methods"}'

        function Invoke-HookWithoutEntire {
            param([string]$HookPath)
            # Strip scoop\shims (where `entire.exe` lives on this box) from PATH so
            # `command -v entire` fails inside the child sh process, while keeping
            # `sh` reachable via Git's own bin dir - proven reachable in isolation
            # (probed, this car): stripping scoop\shims still resolves `sh` to
            # C:\Program Files\Git\bin\sh.exe.
            $filtered = ($env:PATH -split ';' | Where-Object { $_ -notlike '*scoop\shims*' }) -join ';'
            $origPath = $env:PATH
            $env:PATH = $filtered
            try {
                & sh $HookPath 2>&1
                $script:LastExit = $LASTEXITCODE
            } finally {
                $env:PATH = $origPath
            }
        }

        function Invoke-HookWithStubEntire {
            param([string]$HookPath)
            # A stub `entire` on PATH that just echoes its argv, so we can assert the
            # present-branch execs the SAME subcommand as before, without depending on
            # the real CLI being installed on this box.
            $stubDir = Join-Path ([System.IO.Path]::GetTempPath()) ("entire-stub-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $stubDir -Force | Out-Null
            $stubScript = Join-Path $stubDir 'entire'
            Set-Content -Path $stubScript -Value "#!/bin/sh`necho STUB_ENTIRE_CALLED_WITH: `"`$@`"" -NoNewline:$false -Encoding ascii
            $origPath = $env:PATH
            $env:PATH = "$stubDir;$env:PATH"
            try {
                & sh $HookPath 2>&1
                $script:LastExit = $LASTEXITCODE
            } finally {
                $env:PATH = $origPath
                Remove-Item -Recurse -Force $stubDir -ErrorAction SilentlyContinue
            }
        }
    }

    It 'the hook file exists at .claude/hooks/session-start-entire.sh' {
        Test-Path $script:HookPath | Should -BeTrue
    }

    It 'absent branch: prints the identical systemMessage JSON and exits 0' {
        $output = Invoke-HookWithoutEntire -HookPath $script:HookPath
        ($output -join "`n").Trim() | Should -Be $script:ExpectedFallbackJson
        $script:LastExit | Should -Be 0
    }

    It 'present branch: execs "entire hooks claude-code session-start" verbatim' {
        $output = Invoke-HookWithStubEntire -HookPath $script:HookPath
        ($output -join "`n").Trim() | Should -Be 'STUB_ENTIRE_CALLED_WITH: hooks claude-code session-start'
        $script:LastExit | Should -Be 0
    }
}
