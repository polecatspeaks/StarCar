# SessionStartWiring.Tests.ps1 -- #50: every SessionStart hook command stays in the
# bare intersection dialect (`sh .claude/hooks/NAME.sh`, no inline `-c`, no quoting
# layers, no pipes), and the entire-CLI wrapper script preserves its exact behavior
# once moved out of the inline `sh -c` form (Task 1, still in force).
#
# WHY BARE FORM: docs/friction-log.md (2026-07-24 entries) - under Copilot CLI's
# Claude-compat layer, an inline `sh -c '...'` wrapper with an escaped-JSON printf
# fallback broke the WHOLE SessionStart invocation with `syntax error: unexpected end
# of file from 'if' command`, while bare `sh .claude/hooks/NAME.sh` lines executed
# fine. This is the shape observed working under BOTH runtimes.
#
# THE WHITELIST, not a blacklist: a round-2 adversarial fault injection (an inline
# `if...fi` compound plus escaped-JSON `printf`, installed on a SessionStart line)
# passed a blacklist-shaped check (no `sh -c`, no single quote) 15/15 green - a
# blacklist can only reject shapes someone thought to name. The whitelist below
# rejects everything that is not the one known-good shape, including shapes nobody
# has thought of yet.
#
# HISTORY (kept OUT of this live file per this repo's own house rule - a live surface
# should not carry a stale mechanism's name once that mechanism is deleted): a
# push-based delivery mechanism was built, reviewed, and DELETED across three fix-cycle
# rounds and an owner ruling (2026-07-26, option d - agent-pull replaces push). The
# full narrative, including the whitelist widening this file went through and back, is
# in docs/design/2026-07-24-family-agnostic-harness-design.md's amendment history and
# the landed review verdicts under artifacts/reviews/ - both exempt from the "no stale
# mechanism name on a live surface" rule because they are records, never edited after
# landing. This file's own comment history (git log on this path) carries the same
# story for anyone who needs it.
#
# This test reads the REAL .claude/settings.json for the "all five lines pass" half
# (never a hand-copied duplicate, which would drift silently the moment someone edits
# the file - same discipline as CiWrapperSimulation.Tests.ps1's ci.yml extraction), and
# a FIXTURE COPY of it (real hooks array, one line replaced) for the "the documented
# failure signature is rejected" half - never mutates the real file on disk.

Describe 'SessionStart wiring: bare-form whitelist covers all five lines, rejects any fancier shape (#50)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:SettingsPath = Join-Path $script:RepoRoot '.claude/settings.json'
        $script:Settings = Get-Content $script:SettingsPath -Raw | ConvertFrom-Json
        $script:SessionStartHooks = $script:Settings.hooks.SessionStart[0].hooks

        # The ONE legitimate shape: bare `sh .claude/hooks/NAME.sh`. No `-c`, no
        # quoting, no pipe - the agent-pull replacement (#50, owner ruling 2026-07-26)
        # removed the only reason a pipe ever appeared here.
        $script:WhitelistPattern = '^sh \.claude/hooks/[A-Za-z0-9_-]+\.sh$'

        # A documented failure signature this whitelist must reject regardless of
        # mechanism - an inline `if...fi` compound plus escaped-JSON `printf`, the
        # shape a round-2 adversarial fault injection proved a blacklist misses.
        # Reproduced structurally (not tied to any specific downstream command, since
        # that command no longer exists) rather than verbatim to the old injection.
        $script:DocumentedFailureSignature = 'if true; then sh .claude/hooks/session-start-checkpoint-reconcile.sh; printf "%s\n" "{\"x\":1}"; fi'

        # A fixture COPY of the real settings.json with one real SessionStart line
        # replaced by the injection - never mutates the file on disk, never a
        # hand-copied duplicate of the surrounding structure (cloned from the real
        # parsed object).
        function New-InjectedFixtureHooks {
            $clone = $script:Settings.hooks.SessionStart[0].hooks | ForEach-Object {
                [pscustomobject]@{ type = $_.type; command = $_.command }
            }
            $clone[1].command = $script:DocumentedFailureSignature
            $clone
        }
    }

    It 'finds SessionStart hooks to check (a check that examines nothing is not a pass)' {
        $script:SessionStartHooks.Count | Should -BeGreaterThan 0
    }

    It 'every REAL SessionStart hook command matches the bare-form whitelist' {
        $violators = @()
        foreach ($hook in $script:SessionStartHooks) {
            if ($hook.command -notmatch $script:WhitelistPattern) { $violators += $hook.command }
        }
        $violators -join "`n---`n" | Should -BeNullOrEmpty
    }

    It 'the fifth SessionStart hook command (entire-CLI wrapper) is bare simple-form: sh .claude/hooks/NAME.sh' {
        $fifth = $script:SessionStartHooks[4].command
        $fifth | Should -Match $script:WhitelistPattern
        $fifth | Should -Be 'sh .claude/hooks/session-start-entire.sh'
    }

    It 'the whitelist REJECTS the documented Copilot failure signature (inline if-compound plus escaped-JSON printf)' {
        $script:DocumentedFailureSignature | Should -Not -Match $script:WhitelistPattern
    }

    It 'the whitelist REJECTS a pipe shape - no SessionStart line ever pipes to anything now (#50, agent-pull replaces push)' {
        $pipeShape = 'sh .claude/hooks/session-start-checkpoint-reconcile.sh | sh .claude/hooks/some-other-script.sh'
        $pipeShape | Should -Not -Match $script:WhitelistPattern
    }

    It 'a fixture settings.json carrying the documented failure signature on ONE line is flagged as the sole violator' {
        $injectedHooks = New-InjectedFixtureHooks
        $violators = @()
        foreach ($hook in $injectedHooks) {
            if ($hook.command -notmatch $script:WhitelistPattern) { $violators += $hook.command }
        }
        $violators.Count | Should -Be 1
        $violators[0] | Should -Be $script:DocumentedFailureSignature
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
            # #50 hotfix (CI run 30205842313): the PATH separator is per-OS - ';' on
            # Windows, ':' on Linux. Hardcoding ';' made the ubuntu leg treat the whole
            # PATH as one garbage entry. Git-bash on Windows forgave it; Linux did not.
            $sep = [System.IO.Path]::PathSeparator
            $filtered = ($env:PATH -split [regex]::Escape($sep) | Where-Object { $_ -notlike '*scoop\shims*' }) -join $sep
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
            # #50 hotfix (CI run 30205842313): Linux `command -v` requires the exec bit,
            # which Set-Content does not grant; Git-bash on Windows does not care. Without
            # this the hook takes the ABSENT branch on ubuntu and the assertion sees the
            # fallback JSON instead of the stub echo.
            if (-not $IsWindows) { & chmod +x $stubScript }
            $sep = [System.IO.Path]::PathSeparator
            $origPath = $env:PATH
            $env:PATH = "$stubDir$sep$env:PATH"
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
