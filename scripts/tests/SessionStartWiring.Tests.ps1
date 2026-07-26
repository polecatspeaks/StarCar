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
# AMENDED (#50 task 2): a first revision narrowed the all-five bare-form assertion to
# the fifth line only, on the theory that the broader "no fancy quoting" invariant had
# moved to SessionStartReport.Tests.ps1's blacklist check (no `sh -c`, no `'`). THAT
# WAS WRONG, not merely narrower - round-1 adversarial review (fix cycle round 2,
# finding M1) PROVED it with a fault injection: an inline `if...fi` compound plus an
# escaped-JSON `printf` - i.e. the EXACT shape the design records as breaking Copilot
# (`docs/design/2026-07-24-family-agnostic-harness-design.md`: `syntax error:
# unexpected end of file from 'if' command`) - contains no `sh -c` and no single quote,
# and passed both suites 15/15 GREEN when installed on a SessionStart line. A blacklist
# can only reject shapes someone thought to name; a whitelist rejects everything that
# is not the known-good shape, including shapes nobody has thought of yet.
#
# THE FIX (this revision): restored to a WHITELIST applied to ALL FIVE lines, widened
# from round 1's bare-only form to also permit the pipe-to-record.sh shape (#50 task 2)
# - and narrowed again in fix cycle round 2 (finding M4) to drop the now-retired
# `--reset` argument, which no longer exists in session-start-record.sh's calling
# convention (freshness is a file property now, never an ordering flag - see that
# script's own header). The whitelist is re-derived to match the FINAL wiring shape,
# not merely patched.
#
# This test reads the REAL .claude/settings.json for the "all five lines pass" half
# (never a hand-copied duplicate, which would drift silently the moment someone edits
# the file - same discipline as CiWrapperSimulation.Tests.ps1's ci.yml extraction), and
# a FIXTURE COPY of it (real hooks array, one line replaced) for the "the documented
# failure signature is rejected" half - never mutates the real file on disk.

Describe 'SessionStart wiring: whitelist covers all five lines, rejects the documented failure signature (#50 M1, fix cycle round 2)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:SettingsPath = Join-Path $script:RepoRoot '.claude/settings.json'
        $script:Settings = Get-Content $script:SettingsPath -Raw | ConvertFrom-Json
        $script:SessionStartHooks = $script:Settings.hooks.SessionStart[0].hooks

        # The two legitimate shapes, and ONLY these: bare `sh .claude/hooks/NAME.sh`
        # (the fifth, entire-CLI wrapper line), or that piped into the recorder with no
        # trailing argument (the four guard lines, post fix-cycle-round-2/M4).
        $script:WhitelistPattern = '^sh \.claude/hooks/[A-Za-z0-9_-]+\.sh( \| sh \.claude/hooks/session-start-record\.sh)?$'

        # The EXACT fault injection the round-1 reviewer installed and proved 15/15
        # GREEN under (round-1 REJECT, finding M1, "Fault injection D") - reproduced
        # verbatim here as the documented failure signature this whitelist must reject,
        # never a hand-invented stand-in for it.
        $script:DocumentedFailureSignature = 'if true; then sh .claude/hooks/session-start-checkpoint-reconcile.sh; printf "%s\n" "{\"x\":1}"; fi | sh .claude/hooks/session-start-record.sh'

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

    It 'every REAL SessionStart hook command matches the whitelist (bare form, or piped to session-start-record.sh)' {
        $violators = @()
        foreach ($hook in $script:SessionStartHooks) {
            if ($hook.command -notmatch $script:WhitelistPattern) { $violators += $hook.command }
        }
        $violators -join "`n---`n" | Should -BeNullOrEmpty
    }

    It 'the fifth SessionStart hook command (entire-CLI wrapper) is bare simple-form: sh .claude/hooks/NAME.sh' {
        $fifth = $script:SessionStartHooks[4].command
        $fifth | Should -Match '^sh \.claude/hooks/[A-Za-z0-9_-]+\.sh$'
        $fifth | Should -Be 'sh .claude/hooks/session-start-entire.sh'
    }

    It 'the whitelist REJECTS the documented Copilot failure signature (round-1 REJECT fault injection D, reproduced verbatim)' {
        $script:DocumentedFailureSignature | Should -Not -Match $script:WhitelistPattern
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
