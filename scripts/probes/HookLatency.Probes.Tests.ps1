#requires -Version 7.4
# HookLatency.Probes.Tests.ps1 -- the #15 latency-split measurement probe.
#
# WHY THIS EXISTS (doctrine: "NO HEADERS HERE", CLAUDE.md): Probe 2's addendum
# (docs/probes/2026-07-22-spec7-probe-results.md) measured the COMBINED per-dispatch
# hook overhead (~11-12s) but never split it into components - the split is #15's job,
# tracked as a Car-3-adjacent optimization since Probe 2 landed. This probe times each
# candidate contributor IN ISOLATION on this box, so a future remedy decision (a
# compiled binary instead of pwsh child processes, batching the git commits, etc.) has
# a measured breakdown to aim at instead of a guess.
#
# NON-VACUITY ONLY, deliberately: this probe asserts that each timed component actually
# RAN 10 times and actually SUCCEEDED (an exit code, a written file, an appended line) -
# never a time threshold. A box under CI load runs slower than a quiet laptop, and a
# threshold-based probe would cry wolf on the load, not on a regression (severity
# philosophy: an instrument that cries wolf is worse than no instrument).
#
# CONSUMER: docs/probes/2026-07-22-spec7-probe-results.md's #15 split addendum, landed
# in the same commit as this file - the measurement IS the deliverable; remedy
# decisions come after (#15's own discipline, stated in the harness Car 3 plan).

Describe 'Hook latency split (#15) - each contributor timed in isolation, 10 iterations, min/median' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:Iterations = 10

        function Get-MinMedianMs {
            param([double[]]$Samples)
            $sorted = $Samples | Sort-Object
            $min = $sorted[0]
            $mid = [Math]::Floor($sorted.Count / 2)
            $median = if ($sorted.Count % 2 -eq 0) {
                ($sorted[$mid - 1] + $sorted[$mid]) / 2
            } else {
                $sorted[$mid]
            }
            [pscustomobject]@{ Min = [Math]::Round($min, 1); Median = [Math]::Round($median, 1) }
        }

        # A throwaway git repo, real history, for the producer's write+commit measurement -
        # the Producer.Tests.ps1 fixture-repo pattern (structural, opened at base).
        function New-FixtureRepo {
            $repo = Join-Path ([System.IO.Path]::GetTempPath()) ("latencyprobe-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $repo -Force | Out-Null
            git -C $repo init -q | Out-Null
            git -C $repo config user.email 'latency-probe@starcar.local' | Out-Null
            git -C $repo config user.name 'Latency Probe' | Out-Null
            Set-Content -Path (Join-Path $repo 'README') -Value 'seed' -Encoding utf8
            git -C $repo add README | Out-Null
            git -C $repo commit -q -m 'seed' | Out-Null
            $repo
        }
    }

    It 'bare pwsh start (pwsh -NoProfile -Command exit)' {
        $samples = New-Object System.Collections.Generic.List[double]
        for ($i = 0; $i -lt $script:Iterations; $i++) {
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            & pwsh -NoProfile -Command 'exit' | Out-Null
            $exitCode = $LASTEXITCODE
            $sw.Stop()
            $exitCode | Should -Be 0
            $samples.Add($sw.Elapsed.TotalMilliseconds)
        }
        $samples.Count | Should -Be $script:Iterations
        $stats = Get-MinMedianMs -Samples $samples
        Write-Host "PWSH START: min=$($stats.Min)ms median=$($stats.Median)ms (n=$($samples.Count))"
        Set-Variable -Name PwshStats -Value $stats -Scope Global
    }

    It 'python start (python -c pass)' {
        $samples = New-Object System.Collections.Generic.List[double]
        for ($i = 0; $i -lt $script:Iterations; $i++) {
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            & python -c 'pass' | Out-Null
            $exitCode = $LASTEXITCODE
            $sw.Stop()
            $exitCode | Should -Be 0
            $samples.Add($sw.Elapsed.TotalMilliseconds)
        }
        $samples.Count | Should -Be $script:Iterations
        $stats = Get-MinMedianMs -Samples $samples
        Write-Host "PYTHON START: min=$($stats.Min)ms median=$($stats.Median)ms (n=$($samples.Count))"
        Set-Variable -Name PythonStats -Value $stats -Scope Global
    }

    It 'one Produce-Artifact.ps1 fixture run end-to-end (write + commit in a temp repo)' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        $script:Script = Join-Path $script:RepoRoot 'scripts/Produce-Artifact.ps1'
        $payload = @{
            session_id = 'latency-probe-sess'
            agent_type = 'car'
            agent_id = 'latency-probe-agent'
            agent_transcript_path = ''
        } | ConvertTo-Json -Compress

        $samples = New-Object System.Collections.Generic.List[double]
        for ($i = 0; $i -lt $script:Iterations; $i++) {
            $now = "2026-07-22T10:00:$('{0:D2}' -f $i)Z"
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $out = $payload | & $script:Script -Kind 'returned' -StoreRoot $store -Now $now 2>&1
            $exitCode = $LASTEXITCODE
            $sw.Stop()
            $exitCode | Should -Be 0
            $samples.Add($sw.Elapsed.TotalMilliseconds)
        }
        $samples.Count | Should -Be $script:Iterations
        # Non-vacuity: the fixture repo really did gain 10 committed records, not 0.
        $commitCount = (git -C $repo log --oneline | Measure-Object).Count
        $commitCount | Should -Be ($script:Iterations + 1)  # +1 for the seed commit
        $stats = Get-MinMedianMs -Samples $samples
        Write-Host "PRODUCER FIXTURE RUN (write+commit): min=$($stats.Min)ms median=$($stats.Median)ms (n=$($samples.Count))"
        Set-Variable -Name ProducerStats -Value $stats -Scope Global
    }

    It 'one probe-hook append (.claude/hooks/post-task-probe.sh, the committed launch-payload observer)' {
        $hook = Join-Path $script:RepoRoot '.claude/hooks/post-task-probe.sh'
        Test-Path $hook | Should -BeTrue
        $cwd = Join-Path ([System.IO.Path]::GetTempPath()) ("hookprobe-" + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $cwd -Force | Out-Null
        $payload = '{"tool_name":"Task","tool_input":{"subagent_type":"car"}}'

        $samples = New-Object System.Collections.Generic.List[double]
        for ($i = 0; $i -lt $script:Iterations; $i++) {
            Push-Location $cwd
            try {
                $sw = [System.Diagnostics.Stopwatch]::StartNew()
                $payload | & sh $hook | Out-Null
                $exitCode = $LASTEXITCODE
                $sw.Stop()
            } finally {
                Pop-Location
            }
            $exitCode | Should -Be 0
            $samples.Add($sw.Elapsed.TotalMilliseconds)
        }
        $samples.Count | Should -Be $script:Iterations
        # Non-vacuity: the log really gained 10 lines, not 0.
        $logPath = Join-Path $cwd '.claude/probe-logs/post-task.jsonl'
        Test-Path $logPath | Should -BeTrue
        (Get-Content $logPath | Measure-Object -Line).Lines | Should -Be $script:Iterations
        $stats = Get-MinMedianMs -Samples $samples
        Write-Host "PROBE-HOOK APPEND: min=$($stats.Min)ms median=$($stats.Median)ms (n=$($samples.Count))"
        Set-Variable -Name HookAppendStats -Value $stats -Scope Global
    }
}
