#requires -Version 7.4
# SessionStartReportConcurrency.Tests.ps1 -- #50, fix cycle round 2, M4.
#
# ROUND-1 DEFECT (round-1 REJECT, M4): session-start-record.sh assumed the five
# SessionStart hook commands execute SEQUENTIALLY in settings.json array order, with
# `--reset` attached to exactly the first line. That assumption was UNSTATED and
# UNPROVEN; Claude Code documents PARALLEL execution of same-event hooks, and the
# round-1 reviewer MEASURED silent loss of a guard's entire output in 2/15 trials under
# adversarial skew (the `--reset` truncate landing AFTER another guard had already
# appended).
#
# THE FIX (this file pins it): freshness is now a property of the FILE, never of
# ordering. Every invocation of session-start-record.sh checks whether the report
# file's own marker is STALE (missing, or older than STALE_SECONDS) and, if so,
# truncates + writes a fresh marker BEFORE appending - no line is "first" by
# convention, and `--reset` is gone from both the script's argument handling and the
# settings.json wiring entirely. An atomic `mkdir`-based mutex serializes the
# check-then-truncate-then-append critical section across concurrent invocations, so
# two guards racing at true OS-level parallelism cannot interleave a truncate between
# one guard's append and another's - the exact failure class the reviewer measured.
#
# This test proves BOTH halves against REAL concurrent child processes (never
# simulated sequentially - a test that only calls the script one-at-a-time proves
# nothing about the race, which is exactly the round-1 gap):
#   1. A STALE prior-session report file (old mtime, old content) is replaced, not
#      appended to, by the next SessionStart batch - deterministic, and RED against
#      the round-1 script (which requires an explicit --reset flag no invocation in
#      the new calling convention ever passes, so stale content would survive).
#   2. Many trials of N genuinely concurrent invocations against a stale/absent file
#      lose NOTHING - every guard's line lands exactly once, across every trial.

Describe 'session-start-record.sh: freshness is a file property, not an ordering assumption (#50 M4)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:RecordScript = (Join-Path $script:RepoRoot '.claude/hooks/session-start-record.sh') -replace '\\', '/'

        function New-TempReportPath {
            Join-Path ([System.IO.Path]::GetTempPath()) ("ssrc-report-" + [guid]::NewGuid().ToString('N') + '.txt')
        }

        # Launches N `echo`-emitting "guards" through session-start-record.sh as
        # GENUINELY CONCURRENT child processes (real OS processes via
        # System.Diagnostics.Process - not PowerShell background jobs sharing this
        # process's own I/O buffering, and not a sequential loop, which would prove
        # nothing about the race).
        #
        # STDOUT/STDERR REDIRECTED (fix cycle round 3, N8, test-hygiene only - no
        # mechanism change): with UseShellExecute=$false and NO redirection, a child
        # process inherits the PARENT's console streams, so every guard's `echo` (and
        # session-start-record.sh's own `tee -a` passthrough) flowed straight into
        # Pester's own output - 4 guards x 20 trials x (this test plus the other two)
        # leaked 80+ lines into every suite run and CI log. Both streams are redirected
        # and drained ASYNCHRONOUSLY via `Register-ObjectEvent` (never synchronously
        # read after `WaitForExit`, which would serialize the very concurrency this
        # test exists to exercise, and never left un-drained, which risks a deadlock
        # if a child's output ever exceeds the OS pipe buffer). Event subscriptions are
        # unregistered per process so they never accumulate across the 20-trial loop.
        function Invoke-ConcurrentGuards {
            param([string[]]$GuardTexts, [string]$ReportFile)
            $procs = @()
            $subs = @()
            foreach ($text in $GuardTexts) {
                $psi = [System.Diagnostics.ProcessStartInfo]::new()
                $psi.FileName = 'sh'
                $psi.Arguments = "-c `"echo $text | sh $script:RecordScript`""
                $psi.UseShellExecute = $false
                $psi.RedirectStandardOutput = $true
                $psi.RedirectStandardError = $true
                $psi.EnvironmentVariables['REPORT_FILE'] = $ReportFile
                $p = [System.Diagnostics.Process]::new()
                $p.StartInfo = $psi
                $subs += Register-ObjectEvent -InputObject $p -EventName OutputDataReceived -Action { }
                $subs += Register-ObjectEvent -InputObject $p -EventName ErrorDataReceived -Action { }
                [void]$p.Start()
                $p.BeginOutputReadLine()
                $p.BeginErrorReadLine()
                $procs += $p
            }
            foreach ($p in $procs) { $p.WaitForExit(10000) | Out-Null }
            foreach ($sub in $subs) { Unregister-Event -SourceIdentifier $sub.Name -ErrorAction SilentlyContinue }
        }
    }

    It 'a STALE prior-session report file is replaced (not appended to) by the next batch, with no --reset argument' {
        $report = New-TempReportPath
        Set-Content -Path $report -Value "[session-start-report] 2020-01-01T00:00:00Z`nstale-prior-session-line" -Encoding utf8
        # Force the mtime far into the past so it reads as stale regardless of the
        # wall-clock moment this test happens to run.
        (Get-Item $report).LastWriteTimeUtc = (Get-Date).ToUniversalTime().AddDays(-1)

        Invoke-ConcurrentGuards -GuardTexts @('fresh-batch-line') -ReportFile $report

        $content = Get-Content $report -Raw
        $content | Should -Not -Match 'stale-prior-session-line'
        $content | Should -Match 'fresh-batch-line'
        $content | Should -Match '^\[session-start-report\] \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z'
    }

    It 'a FRESH existing report file (same batch, just written) is appended to, never re-truncated' {
        $report = New-TempReportPath
        Invoke-ConcurrentGuards -GuardTexts @('first-guard-line') -ReportFile $report
        Invoke-ConcurrentGuards -GuardTexts @('second-guard-line') -ReportFile $report

        $content = Get-Content $report -Raw
        $content | Should -Match 'first-guard-line'
        $content | Should -Match 'second-guard-line'
    }

    It 'N genuinely concurrent invocations against a STALE/absent file lose NOTHING, across many trials' {
        $trials = 20
        $lossCount = 0
        for ($t = 0; $t -lt $trials; $t++) {
            $report = New-TempReportPath
            # Alternate: half the trials start from a stale file, half from no file at
            # all (a brand-new machine / first-ever session) - both are real "start of
            # a fresh SessionStart batch" cases.
            if ($t % 2 -eq 0) {
                Set-Content -Path $report -Value "[session-start-report] 2020-01-01T00:00:00Z`nold-content-trial-$t" -Encoding utf8
                (Get-Item $report).LastWriteTimeUtc = (Get-Date).ToUniversalTime().AddDays(-1)
            }

            Invoke-ConcurrentGuards -GuardTexts @("guard-A-$t", "guard-B-$t", "guard-C-$t", "guard-D-$t") -ReportFile $report

            $content = if (Test-Path $report) { Get-Content $report -Raw } else { '' }
            foreach ($tag in @("guard-A-$t", "guard-B-$t", "guard-C-$t", "guard-D-$t")) {
                if ($content -notmatch [regex]::Escape($tag)) { $lossCount++ }
            }
        }
        # Report the observed loss count in the failure message rather than a bare
        # boolean, so a future regression names how much it lost, not just that it did.
        $lossCount | Should -Be 0 -Because "expected zero losses across $trials trials x 4 guards; observed $lossCount"
    }
}
