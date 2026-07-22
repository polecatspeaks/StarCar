#requires -Version 7.4
# The producer (Task B.2). Produce-Artifact.ps1 reads a hook payload on stdin and writes
# ONE artifact record, then commits ONLY that record's path (git commit --only, C2R1-M2 -
# a bare commit would sweep the conductor's co-staged files into a harness commit).
#
# Every test invokes the producer as a CHILD pwsh process with the payload on stdin, which
# is exactly how the hook runs it - so the stdin read, the filter, the write, and the
# commit are all exercised on the real path, not a dot-sourced shortcut.

Describe 'Produce-Artifact' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:Script   = Join-Path $script:RepoRoot 'scripts/Produce-Artifact.ps1'
        $script:SchemaPath = Join-Path $script:RepoRoot 'schema/starcar-artifact.schema.json'
        $script:Fixtures = Join-Path $script:RepoRoot 'scripts/tests/fixtures/payloads'
        Import-Module (Join-Path $script:RepoRoot 'scripts/Artifact.psm1') -Force

        function Get-Sha256Hex([string]$Text) {
            $sha = [System.Security.Cryptography.SHA256]::Create()
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
            $hash = $sha.ComputeHash($bytes)
            $sha.Dispose()
            ([System.BitConverter]::ToString($hash) -replace '-', '').ToLower()
        }

        # A throwaway git repo per invocation, so commit behaviour is real.
        function New-FixtureRepo {
            $repo = Join-Path ([System.IO.Path]::GetTempPath()) ("prodtest-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $repo -Force | Out-Null
            git -C $repo init -q | Out-Null
            git -C $repo config user.email 'test@starcar.local' | Out-Null
            git -C $repo config user.name  'Producer Test' | Out-Null
            # a first commit so HEAD exists (git commit --only needs a HEAD to base on)
            Set-Content -Path (Join-Path $repo 'README') -Value 'seed' -Encoding utf8
            git -C $repo add README | Out-Null
            git -C $repo commit -q -m 'seed' | Out-Null
            $repo
        }

        # Read a fixture, substitute the <repo> placeholder in agent_transcript_path with
        # the real repo root so the producer can read the fixture transcript.
        function Get-Payload([string]$Name) {
            (Get-Content (Join-Path $script:Fixtures $Name) -Raw) -replace '<repo>', ($script:RepoRoot -replace '\\', '/')
        }

        # Invoke the producer IN-PROCESS via the call operator, payload on the PowerShell
        # pipeline (the producer reads $input, which is populated identically whether the
        # hook pipes OS stdin to `pwsh -File` or a caller pipes an object in-process -
        # both verified). `exit` inside an &-invoked script file is isolated: it sets
        # $LASTEXITCODE without terminating this runner.
        #
        # Q3 fix-cycle finding: the producer's catch block sets $ErrorActionPreference =
        # 'Stop' in ITS OWN script scope (line 43), which makes its own Write-Error calls
        # terminating. Invoked via `&` (not a separate process), an unhandled terminating
        # error propagates OUT of the script and INTO this runner - `exit 1` is never
        # reached, and `2>&1` does not catch it (that redirects the non-terminating error
        # stream; a terminating error is a different mechanism). Measured directly: the
        # SAME failure invoked as a genuinely separate `pwsh -File` process (how the real
        # hook runs it) correctly exits 1, because the process boundary confines the
        # terminating error. The try/catch below makes this harness match that real
        # subprocess exit-code semantics without paying a per-test subprocess-spawn cost.
        function Invoke-Producer {
            param([string]$Payload, [string]$Kind, [string]$StoreRoot, [string]$Now)
            $exitCode = 0
            try {
                if ($Now) {
                    $out = $Payload | & $script:Script -Kind $Kind -StoreRoot $StoreRoot -Now $Now 2>&1
                } else {
                    $out = $Payload | & $script:Script -Kind $Kind -StoreRoot $StoreRoot 2>&1
                }
                $exitCode = $LASTEXITCODE
            } catch {
                $out = $_.Exception.Message
                $exitCode = 1
            }
            [pscustomobject]@{ ExitCode = $exitCode; Output = ($out -join "`n") }
        }
    }

    It 'writes NOTHING for a filtered internal-subagent stop payload (empty agent_type)' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        $r = Invoke-Producer -Payload (Get-Payload 'stop-internal.json') -Kind 'returned' -StoreRoot $store -Now '2026-07-22T10:00:00Z'
        $r.ExitCode | Should -Be 0
        (Get-ChildItem -Path $store -Recurse -Filter *.json -ErrorAction SilentlyContinue).Count | Should -Be 0
    }

    It 'writes NOTHING for a filtered launch payload (empty subagent_type)' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        $payload = (Get-Payload 'launch-car.json' | ConvertFrom-Json)
        $payload.tool_input.subagent_type = ''
        $json = $payload | ConvertTo-Json -Depth 20
        $r = Invoke-Producer -Payload $json -Kind 'dispatched' -StoreRoot $store -Now '2026-07-22T10:00:00Z'
        $r.ExitCode | Should -Be 0
        (Get-ChildItem -Path $store -Recurse -Filter *.json -ErrorAction SilentlyContinue).Count | Should -Be 0
    }

    It 'a real stop payload writes a schema-valid returned record at the R4 path with envelope fields populated' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        $r = Invoke-Producer -Payload (Get-Payload 'stop-car.json') -Kind 'returned' -StoreRoot $store -Now '2026-07-22T10:05:00Z'
        $r.ExitCode | Should -Be 0
        $expected = Join-Path $store 'a88e7dadda60940ac/returned-20260722T100500Z.json'
        Test-Path $expected | Should -BeTrue
        $rec = Get-Content $expected -Raw | ConvertFrom-Json
        $rec.kind | Should -Be 'returned'
        $rec.subject | Should -Be 'a88e7dadda60940ac'
        $rec.session_id | Should -Be 'sess-fixture-1'
        $rec.outcome | Should -Be 'APPROVE'
        $rec.abstract | Should -Be "Line one of the fixture abstract.`nLine two continues the summary.`nLine three closes it."
        $rec.PSObject.Properties['envelope'] | Should -Be $null
        $v = Test-StarcarArtifact -InputObject $rec -SchemaPath $script:SchemaPath
        $v.Valid | Should -BeTrue
    }

    It 'a launch payload writes a dispatched record whose subject EQUALS the stop record and carries model' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        Invoke-Producer -Payload (Get-Payload 'stop-car.json')   -Kind 'returned'   -StoreRoot $store -Now '2026-07-22T10:05:00Z' | Out-Null
        Invoke-Producer -Payload (Get-Payload 'launch-car.json') -Kind 'dispatched' -StoreRoot $store -Now '2026-07-22T10:00:00Z' | Out-Null
        $disp = Get-Content (Join-Path $store 'a88e7dadda60940ac/dispatched-20260722T100000Z.json') -Raw | ConvertFrom-Json
        $ret  = Get-Content (Join-Path $store 'a88e7dadda60940ac/returned-20260722T100500Z.json') -Raw | ConvertFrom-Json -DateKind String  # verbatim 'at' (M-A4-1 class)
        # THE MEASURED IDENTITY (Probe 5): tool_response.agentId == agent_id
        $disp.subject | Should -Be $ret.subject
        $disp.model | Should -Be 'claude-sonnet-5'
        (Test-StarcarArtifact -InputObject $disp -SchemaPath $script:SchemaPath).Valid | Should -BeTrue
    }

    It 'an envelope-absent transcript yields outcome error and envelope absent' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        # a transcript whose last assistant message has NO envelope fence
        $tpath = Join-Path $repo 'no-envelope.jsonl'
        Set-Content -Path $tpath -Encoding utf8 -Value '{"message":{"role":"assistant","content":[{"type":"text","text":"I finished but forgot the envelope."}]}}'
        $payload = (Get-Payload 'stop-car.json' | ConvertFrom-Json)
        $payload.agent_transcript_path = ($tpath -replace '\\', '/')
        $json = $payload | ConvertTo-Json -Depth 20
        $r = Invoke-Producer -Payload $json -Kind 'returned' -StoreRoot $store -Now '2026-07-22T11:00:00Z'
        $r.ExitCode | Should -Be 0
        $rec = Get-Content (Join-Path $store 'a88e7dadda60940ac/returned-20260722T110000Z.json') -Raw | ConvertFrom-Json
        $rec.outcome | Should -Be 'error'
        $rec.envelope | Should -Be 'absent'
        (Test-StarcarArtifact -InputObject $rec -SchemaPath $script:SchemaPath).Valid | Should -BeTrue
    }

    It 'F5: a returned payload pointing at a NONEXISTENT transcript is a producer read failure, not an absent envelope' {
        <#
          docs/plans/2026-07-22-pr18-correctness-fixes-plan.md F5: Get-LastAssistantText
          reports missing/unreadable/unparseable transcripts via Errors, but a bare read
          failure was classified identically to "no fence" (envelope: absent, a BRIEF
          failure) and the actual error text was dropped (Law 4). A transcript READ
          FAILURE must land outcome:error, NO envelope field, the read error IN findings,
          a _faults.log line, AND the record must stay schema-valid (abstract required).
        #>
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        $payload = (Get-Payload 'stop-car.json' | ConvertFrom-Json)
        $missingPath = (Join-Path $repo 'no-such-transcript.jsonl') -replace '\\', '/'
        $payload.agent_transcript_path = $missingPath
        $json = $payload | ConvertTo-Json -Depth 20
        $r = Invoke-Producer -Payload $json -Kind 'returned' -StoreRoot $store -Now '2026-07-22T13:00:00Z'
        $r.ExitCode | Should -Be 0
        $rec = Get-Content (Join-Path $store 'a88e7dadda60940ac/returned-20260722T130000Z.json') -Raw | ConvertFrom-Json

        $rec.outcome | Should -Be 'error'
        $rec.PSObject.Properties['envelope'] | Should -Be $null -Because 'a producer read failure is not the brief-failure value absent'
        $rec.findings | Should -Match 'transcript not found' -Because 'Law 4: the read error must not be dropped'
        $rec.PSObject.Properties['abstract'] | Should -Not -Be $null -Because 'abstract is REQUIRED on returned records; the fault branch must still set it'

        $faultsLog = Join-Path $store '_faults.log'
        Test-Path $faultsLog | Should -BeTrue -Because 'Law 4: the read error is raised, never dropped'
        (Get-Content $faultsLog -Raw) | Should -Match 'transcript' -Because 'the fault names the transcript read failure'

        (Test-StarcarArtifact -InputObject $rec -SchemaPath $script:SchemaPath).Valid | Should -BeTrue -Because 'the record must stay schema-valid'
    }

    It 'declares normalisation and substitutes a repo-root path in an agent-authored field' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        # an envelope whose abstract quotes a path under the fixture repo root
        $abstractPath = ($repo -replace '\\', '/') + '/scripts/thing.ps1'
        $tpath = Join-Path $repo 'with-path.jsonl'
        $textLines = @(
            'Body.',
            '',
            '```starcar-artifact',
            'outcome: honest-stop',
            'findings: none',
            "abstract: I stopped at $abstractPath here.",
            '```'
        )
        $text = ($textLines -join "`n") + "`n"
        $line = @{ message = @{ role = 'assistant'; content = @(@{ type = 'text'; text = $text }) } } | ConvertTo-Json -Depth 20 -Compress
        Set-Content -Path $tpath -Encoding utf8 -Value $line
        $payload = (Get-Payload 'stop-car.json' | ConvertFrom-Json)
        $payload.agent_transcript_path = ($tpath -replace '\\', '/')
        $json = $payload | ConvertTo-Json -Depth 20
        Invoke-Producer -Payload $json -Kind 'returned' -StoreRoot $store -Now '2026-07-22T12:00:00Z' | Out-Null
        $rec = Get-Content (Join-Path $store 'a88e7dadda60940ac/returned-20260722T120000Z.json') -Raw | ConvertFrom-Json
        $rec.abstract | Should -Match '<repo>/scripts/thing.ps1'
        $rec.abstract | Should -Not -Match ([regex]::Escape($repo))
        @($rec.normalisation).Count | Should -BeGreaterThan 0
        ($rec.normalisation | Where-Object { $_.from_class -eq 'repo-root' }).Count | Should -Be 1
    }

    It 'the integrity hash round-trips over the canonical body' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        Invoke-Producer -Payload (Get-Payload 'stop-car.json') -Kind 'returned' -StoreRoot $store -Now '2026-07-22T10:05:00Z' | Out-Null
        $rec = Get-Content (Join-Path $store 'a88e7dadda60940ac/returned-20260722T100500Z.json') -Raw | ConvertFrom-Json
        $rec.integrity | Should -Match '^sha256:[0-9a-f]+$'
        # Re-derive independently: every field in file order EXCEPT integrity, compact JSON.
        $copy = [ordered]@{}
        foreach ($p in $rec.PSObject.Properties) { if ($p.Name -ne 'integrity') { $copy[$p.Name] = $p.Value } }
        $body = $copy | ConvertTo-Json -Depth 20 -Compress
        ('sha256:' + (Get-Sha256Hex $body)) | Should -Be $rec.integrity
    }

    It 'Q3: a payload with a path-traversal agent_id (../evil) writes NOTHING, faults, and exits nonzero' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        $before = @(Get-ChildItem -Path $repo -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
        $payload = (Get-Payload 'stop-car.json' | ConvertFrom-Json)
        $payload.agent_id = '../evil'
        $json = $payload | ConvertTo-Json -Depth 20
        $r = Invoke-Producer -Payload $json -Kind 'returned' -StoreRoot $store -Now '2026-07-22T10:05:00Z'
        $r.ExitCode | Should -Not -Be 0
        $after = @(Get-ChildItem -Path $repo -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
        $faultsLog = Join-Path $store '_faults.log'
        $newFiles = @($after | Where-Object { ($before -notcontains $_) -and ($_ -ne $faultsLog) })
        $newFiles.Count | Should -Be 0 -Because 'no file may land inside or outside the store for a rejected subject'
        Test-Path $faultsLog | Should -BeTrue
        (Get-Content $faultsLog -Raw) | Should -Match ([regex]::Escape('../evil')) -Because 'Law 4: the rejected subject is named, never dropped'
    }

    It 'Q3: a payload with a path-separator agent_id (a/b) writes NOTHING, faults, and exits nonzero' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        $before = @(Get-ChildItem -Path $repo -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
        $payload = (Get-Payload 'stop-car.json' | ConvertFrom-Json)
        $payload.agent_id = 'a/b'
        $json = $payload | ConvertTo-Json -Depth 20
        $r = Invoke-Producer -Payload $json -Kind 'returned' -StoreRoot $store -Now '2026-07-22T10:05:00Z'
        $r.ExitCode | Should -Not -Be 0
        $after = @(Get-ChildItem -Path $repo -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName })
        $faultsLog = Join-Path $store '_faults.log'
        $newFiles = @($after | Where-Object { ($before -notcontains $_) -and ($_ -ne $faultsLog) })
        $newFiles.Count | Should -Be 0 -Because 'no file may land inside or outside the store for a rejected subject'
        Test-Path $faultsLog | Should -BeTrue
        (Get-Content $faultsLog -Raw) | Should -Match ([regex]::Escape('a/b')) -Because 'Law 4: the rejected subject is named, never dropped'
    }

    It 'ENTANGLEMENT (C2R1-M2): a foreign co-staged file stays OUT of the producer commit' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        # the conductor stages an unrelated file BEFORE the producer runs
        Set-Content -Path (Join-Path $repo 'conductor-work.txt') -Value 'do not sweep me' -Encoding utf8
        git -C $repo add conductor-work.txt | Out-Null
        Invoke-Producer -Payload (Get-Payload 'stop-car.json') -Kind 'returned' -StoreRoot $store -Now '2026-07-22T10:05:00Z' | Out-Null
        # the producer's commit must contain EXACTLY the record path, nothing else
        $committed = @(git -C $repo show --name-only --pretty=format: HEAD | Where-Object { $_ })
        $committed.Count | Should -Be 1
        $committed[0] | Should -Be 'artifacts/a88e7dadda60940ac/returned-20260722T100500Z.json'
        # and the foreign file is still staged, uncommitted
        (git -C $repo diff --cached --name-only) | Should -Contain 'conductor-work.txt'
    }
}
