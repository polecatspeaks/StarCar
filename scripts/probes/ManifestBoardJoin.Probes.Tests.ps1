#requires -Version 7.4
# ManifestBoardJoin.Probes.Tests.ps1 -- #79, pinning the #76 probe as a PINNED SUBSTRATE
# TEST (doctrine: "a probe result is perishable; it becomes substrate only when it
# LANDS", CLAUDE.md "NO HEADERS HERE"). CheckpointReconcile.Probes.Tests.ps1 and
# SubstrateFloor.Probes.Tests.ps1 are the exemplars this suite follows.
#
# WHY THIS EXISTS: issue #76's owner-ruled PROBE RESULT comment (2026-07-27) found the
# manifest-to-board join ALREADY WORKS end to end - the gates lane fills from a gate-role
# member carrying its gate name and verdict word verbatim, the trains lane renders the
# consist with per-member role/state/outcome, a declared member with no record renders in
# declaredNotObserved (the completeness assertion the whole design rests on), and member
# dispatch records come back assigned:true. That finding collapsed a design-rung train
# into this narrow tooling ticket. Today nothing asserts that join mechanically: the
# existing Go tests (board/assemble/assemble_test.go) cover Assemble() in isolation with
# constructed fold.Output/store.Record values, never the real server reading a real
# store over HTTP. If the join regresses, the next conductor re-derives the same probe
# from scratch, or worse trusts a stale comment - this file is the fix.
#
# PROBED FACTS this suite is built against (re-run any you doubt):
#   - board/server/config.go:100 - STARCAR_STORE_PATH is the ONE override point for the
#     store; STARCAR_PORT:80 accepts "0" for an OS-assigned ephemeral port
#     (board/server/main.go:51's net.Listen("tcp", addr)), and STARCAR_POLL_MS:85-89
#     overrides the poll cadence so this suite's readiness wait stays bounded.
#   - board/server/reporoot.go's resolveDefaultRepoRoot requires cwd (or cwd's parent) to
#     contain BOTH artifacts/ and schema/ to resolve SchemaDir/BoardDefsPath/DefaultsPath/
#     WebDir - none of which STARCAR_STORE_PATH touches. The server binary is therefore
#     launched with WorkingDirectory = the real repo root, so schema/vocab reads come from
#     the real checkout while STARCAR_STORE_PATH alone redirects the store, exactly the
#     shape #76's probe recipe used.
#   - board/server/main.go:70 logs "board server: listening on http://<addr> ..." via the
#     stdlib "log" package, whose default Logger writes to os.Stderr (observed: the line
#     arrives on this suite's redirected ErrorDataReceived stream, never stdout).
#   - board/store/store.go's typedRecord (store.go:113-134) already declares every field
#     scripts/Produce-Artifact.ps1 writes (schema, kind, subject, session_id, at, outcome,
#     findings, abstract, budget, model, subject_basis, task_id, manifest, normalisation,
#     integrity) - a sealed record using exactly those keys raises zero
#     "record-unrecognised-fields" board conditions (verified: the well-formed store below
#     raises zero conditions of any kind).
#   - board/assemble/assemble.go:124 gates a Gate lane entry on `m.Role == "gate"`
#     (manifest-declared role, not schema-recognition) AND `d.State == "returned"` -
#     both must hold or no gate entry renders (assemble.go:100-158's whole loop).
#
# NON-VACUITY, proven at landing (#79, fault-injection log below; every injection made
# directly to THIS FILE's well-formed fixture parameters, run, reverted, sha256-checked
# byte-identical before/after - see this car's dispatch report for the four quoted red
# messages and the before/after hashes):
#   (a) GatesRoleOverride 'gate' -> 'car' on gateA: the gates lane assertion reds (0 gates
#       observed, 1 expected) - assemble.go:124's role gate is load-bearing, not a no-op.
#   (b) EmptyMembers $true: the trains-consist assertion reds on a null car lookup -
#       manifest.members really drives train.Cars, never a hardcoded fixture echo.
#   (c) IncludeGateBMember $false (gateB dropped from members): declaredNotObserved loses
#       gateB - assemble.go:106-108's "member declared, no dispatch record" branch is what
#       populates it, never a static list.
#   (d) IncludeCarBMember $false (carB's dispatch record survives, membership dropped):
#       carB's "assigned" flips false - assemble.go:183-187's assignedSubjects map really
#       derives from manifest membership, never dispatch existence alone.
#   (e) SecondManifestClaimsCarA $true (a second train: manifest also declares carA):
#       board conditions go from 0 to 1 ("manifest-membership-collision") - the guard
#       that keeps (a)-(d) non-vacuous: a quarantine or collision would otherwise distort
#       the four assertions silently instead of failing loud.
#
# CONSUMER if this suite reds: issue #76's PROBE RESULT comment and issue #79 itself -
# both assert "the board half is already built and working"; a red here means that claim
# has gone stale and the manifest-minting design (issue #75's owner ruling, same day)
# is standing on a join that no longer behaves as measured.
#
# INVOCATION: pwsh -NoProfile -Command "Invoke-Pester -Path ./scripts/probes/ManifestBoardJoin.Probes.Tests.ps1 -CI"
# Builds board/server fresh into a scratch temp dir every run (no committed binary, no
# repo debris - #43's standing leak-ticket class). Requires go.exe on PATH or the Windows
# default install location C:\Program Files\Go\bin\go.exe (probed below).

Describe 'Manifest-to-board join (#79, pinning #76''s PROBE RESULT)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        Import-Module (Join-Path $script:RepoRoot 'scripts/Artifact.psm1') -Force

        # #79 scope boundary: read board/ freely, never edit it. Building the real
        # server binary into an OS-temp scratch dir (never inside the repo - #43).
        $goCandidates = @('go', 'C:\Program Files\Go\bin\go.exe')
        $script:GoExe = $null
        foreach ($c in $goCandidates) {
            $cmd = Get-Command $c -ErrorAction SilentlyContinue
            if ($cmd) { $script:GoExe = $cmd.Source; break }
        }
        if (-not $script:GoExe) { throw 'ManifestBoardJoin probe: no go.exe found on PATH or at the Windows default install location' }

        $script:ScratchRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('mbj-probe-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $script:ScratchRoot -Force | Out-Null
        $script:ServerExe = Join-Path $script:ScratchRoot 'board-server-probe.exe'

        Push-Location (Join-Path $script:RepoRoot 'board')
        try {
            & $script:GoExe build -o $script:ServerExe ./server 2>&1 | Out-String | Write-Verbose
            if ($LASTEXITCODE -ne 0) { throw "ManifestBoardJoin probe: go build ./server failed (exit $LASTEXITCODE)" }
        } finally {
            Pop-Location
        }

        # --- sealed-record helpers (Law 6: Get-Sha256Hex is scripts/Artifact.psm1's own
        # function, the SAME one Produce-Artifact.ps1:363-365 calls - never a second copy
        # of the hashing rule) ---------------------------------------------------------
        function New-Sealed {
            param([Parameter(Mandatory)][System.Collections.Specialized.OrderedDictionary]$Record)
            $bodyJson = $Record | ConvertTo-Json -Depth 20 -Compress
            $Record['integrity'] = 'sha256:' + (Get-Sha256Hex $bodyJson)
            return $Record
        }

        function Write-SealedRecord {
            param([string]$StoreRoot, [string]$Subject, [string]$FileName, [System.Collections.Specialized.OrderedDictionary]$Record)
            $dir = Join-Path $StoreRoot $Subject
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
            $json = (New-Sealed $Record) | ConvertTo-Json -Depth 20 -Compress
            [System.IO.File]::WriteAllText((Join-Path $dir $FileName), $json, [System.Text.UTF8Encoding]::new($false))
        }

        function Fmt([System.DateTimeOffset]$dto) { $dto.UtcDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ') }

        # New-ScratchStore builds a PLAN-shaped manifest (#76's fixture shape) plus
        # dispatch/return records, sealed with Get-Sha256Hex, under a fresh directory.
        # Every parameter defaults to the WELL-FORMED shape (#76's four-member consist);
        # flipping one parameter is this suite's fault-injection mechanism, applied
        # directly to the well-formed BeforeAll call below and reverted (see this car's
        # report for the sha256 before/after proof - the injections are NOT left in this
        # landed file).
        function New-ScratchStore {
            param(
                [Parameter(Mandatory)][string]$Root,
                [string]$GateARole = 'gate',
                [bool]$IncludeGateBMember = $true,
                [bool]$IncludeCarBMember = $true,
                [bool]$EmptyMembers = $false,
                [bool]$SecondManifestClaimsCarA = $false
            )
            $now = [System.DateTimeOffset]::UtcNow
            $tIntent    = $now.AddMinutes(-10)
            $tCarADisp  = $now.AddMinutes(-9)
            $tCarARet   = $now.AddMinutes(-8)
            $tGateADisp = $now.AddMinutes(-7)
            $tGateARet  = $now.AddMinutes(-6)
            $tCarBDisp  = $now.AddMinutes(-1)   # recent: budget 1800s means "dispatched", never "overdue"

            # A plain array via += (never List[object] wrapped in @() - PowerShell's
            # ordered-hashtable-literal binder throws "Argument types do not match" when a
            # nested key's value is @($aGenericList), observed live constructing this
            # fixture; a plain array assigns straight into ConvertTo-Json with no binder
            # involved).
            $members = @()
            if (-not $EmptyMembers) {
                $members += [ordered]@{ subject = 'carA';  role = 'car' }
                $members += [ordered]@{ subject = 'gateA'; role = $GateARole; gate = 'car-review r1' }
                if ($IncludeCarBMember) { $members += [ordered]@{ subject = 'carB'; role = 'car' } }
                if ($IncludeGateBMember) { $members += [ordered]@{ subject = 'gateB'; role = 'gate'; gate = 'car-review r2' } }
            }

            $manifest = [ordered]@{
                schema     = 'starcar-artifact/1'
                kind       = 'intent'
                subject    = 'train:probe-79'
                session_id = '00000000-0000-0000-0000-000000000079'
                at         = (Fmt $tIntent)
                manifest   = [ordered]@{
                    title   = 'Probe 79: manifest-to-board join'
                    tickets = @('#79')
                    members = $members
                }
                normalisation = @()
            }
            Write-SealedRecord $Root 'train-probe-79' 'intent-probe79.json' $manifest

            if ($SecondManifestClaimsCarA) {
                $dupManifest = [ordered]@{
                    schema     = 'starcar-artifact/1'
                    kind       = 'intent'
                    subject    = 'train:probe-79-dup'
                    session_id = '00000000-0000-0000-0000-000000000079'
                    at         = (Fmt $tIntent)
                    manifest   = [ordered]@{
                        title   = 'Probe 79 dup: collides on carA'
                        tickets = @('#79')
                        members = @([ordered]@{ subject = 'carA'; role = 'car' })
                    }
                    normalisation = @()
                }
                Write-SealedRecord $Root 'train-probe-79-dup' 'intent-probe79dup.json' $dupManifest
            }

            function DispRec($subj, $at) {
                [ordered]@{
                    schema = 'starcar-artifact/1'; kind = 'dispatched'; subject = $subj
                    session_id = '00000000-0000-0000-0000-000000000079'; at = $at
                    budget = 1800.0; model = 'claude-sonnet-5'; subject_basis = 'runtime-id'
                    producer = 'starcar-hook/1'; normalisation = @()
                }
            }
            function RetRec($subj, $at, $outcome, $taskId) {
                [ordered]@{
                    schema = 'starcar-artifact/1'; kind = 'returned'; subject = $subj
                    session_id = '00000000-0000-0000-0000-000000000079'; at = $at
                    outcome = $outcome; findings = 'probe'; abstract = 'probe record'
                    subject_basis = 'runtime-id'; task_id = $taskId; producer = 'starcar-hook/1'
                    normalisation = @()
                }
            }

            Write-SealedRecord $Root 'carA'  'dispatched-carA.json'  (DispRec 'carA'  (Fmt $tCarADisp))
            Write-SealedRecord $Root 'carA'  'returned-carA.json'    (RetRec  'carA'  (Fmt $tCarARet)   'done'    'probe-79-car-r1')
            Write-SealedRecord $Root 'gateA' 'dispatched-gateA.json' (DispRec 'gateA' (Fmt $tGateADisp))
            Write-SealedRecord $Root 'gateA' 'returned-gateA.json'   (RetRec  'gateA' (Fmt $tGateARet)  'APPROVE' 'probe-79-review-r1')
            Write-SealedRecord $Root 'carB'  'dispatched-carB.json'  (DispRec 'carB'  (Fmt $tCarBDisp))
            # gateB: deliberately no record at all - the completeness case (declaredNotObserved).
        }

        # --- process lifecycle: start the real server, wait honestly, tear down reliably ---
        function Start-BoardServerAgainst {
            param([string]$StorePath)
            $psi = [System.Diagnostics.ProcessStartInfo]::new()
            $psi.FileName = $script:ServerExe
            $psi.WorkingDirectory = $script:RepoRoot   # so SchemaDir/DefaultsPath/WebDir resolve for real (reporoot.go)
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError = $true
            $psi.UseShellExecute = $false
            $psi.EnvironmentVariables['STARCAR_STORE_PATH'] = $StorePath
            $psi.EnvironmentVariables['STARCAR_PORT'] = '0'          # OS-assigned ephemeral port: never collides
            $psi.EnvironmentVariables['STARCAR_POLL_MS'] = '150'     # fast first tick for a bounded readiness wait

            $proc = [System.Diagnostics.Process]::new()
            $proc.StartInfo = $psi
            # Register-ObjectEvent, NOT .add_OutputDataReceived({...}) - a raw .NET event
            # delegate fires on a threadpool thread with no PowerShell runspace attached
            # and crashes the WHOLE pwsh process ("There is no Runspace available to run
            # scripts in this thread"), observed live building this suite.
            # Register-ObjectEvent's -Action runs on the engine's event queue instead,
            # which has a real runspace.
            $lines = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
            $outSub = Register-ObjectEvent -InputObject $proc -EventName OutputDataReceived -MessageData $lines -Action {
                if ($EventArgs.Data) { $Event.MessageData.Enqueue($EventArgs.Data) }
            }
            $errSub = Register-ObjectEvent -InputObject $proc -EventName ErrorDataReceived -MessageData $lines -Action {
                if ($EventArgs.Data) { $Event.MessageData.Enqueue($EventArgs.Data) }
            }

            if (-not $proc.Start()) { throw 'ManifestBoardJoin probe: board server process failed to start' }
            $proc.BeginOutputReadLine()
            $proc.BeginErrorReadLine()

            $addr = $null
            $deadline = (Get-Date).AddSeconds(20)
            while (-not $addr -and (Get-Date) -lt $deadline) {
                $line = $null
                if ($lines.TryDequeue([ref]$line)) {
                    if ($line -match 'listening on http://(\S+)') { $addr = $Matches[1] }
                }
                if (-not $addr) { Start-Sleep -Milliseconds 50 }
            }
            if (-not $addr) {
                if (-not $proc.HasExited) { $proc.Kill() }
                Unregister-Event -SourceIdentifier $outSub.Name -ErrorAction SilentlyContinue
                Unregister-Event -SourceIdentifier $errSub.Name -ErrorAction SilentlyContinue
                throw 'ManifestBoardJoin probe: board server never printed its listening address within 20s (honest could-not-observe, never a bare sleep)'
            }
            [pscustomobject]@{ Process = $proc; BaseUrl = "http://$addr"; OutSub = $outSub; ErrSub = $errSub }
        }

        function Wait-FirstPoll {
            param($BaseUrl, [int]$TimeoutSeconds = 20)
            $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
            $last = $null
            do {
                try {
                    $snap = Invoke-RestMethod -Uri "$BaseUrl/api/snapshot" -TimeoutSec 3
                    $last = $snap
                    if ($snap.seq -ge 1) { return $snap }
                } catch {
                    $last = $_.Exception.Message
                }
                Start-Sleep -Milliseconds 100
            } while ((Get-Date) -lt $deadline)
            throw "ManifestBoardJoin probe: board server never completed a poll within ${TimeoutSeconds}s (seq stayed 0; last observation: $last)"
        }

        function Stop-BoardServer {
            param($Handle)
            if ($null -eq $Handle) { return }
            if (-not $Handle.Process.HasExited) {
                try { $Handle.Process.Kill() } catch {}
                $Handle.Process.WaitForExit(5000) | Out-Null
            }
            if ($Handle.OutSub) { Unregister-Event -SourceIdentifier $Handle.OutSub.Name -ErrorAction SilentlyContinue }
            if ($Handle.ErrSub) { Unregister-Event -SourceIdentifier $Handle.ErrSub.Name -ErrorAction SilentlyContinue }
            $Handle.Process.Dispose()
        }

        # --- the well-formed store: every assertion below reads THIS snapshot ----------
        $script:StorePath = Join-Path $script:ScratchRoot 'store'
        New-Item -ItemType Directory -Path $script:StorePath -Force | Out-Null
        New-ScratchStore -Root $script:StorePath

        $script:ServerHandle = Start-BoardServerAgainst -StorePath $script:StorePath
        $script:Snapshot = Wait-FirstPoll -BaseUrl $script:ServerHandle.BaseUrl
    }

    AfterAll {
        Stop-BoardServer $script:ServerHandle
        # #43 (standing repo debris ticket): a killed process's own .exe can stay
        # delete-locked for a short window after WaitForExit returns (OS handle-release
        # lag / AV scan) - observed live: a bare single-attempt Remove-Item -ErrorAction
        # SilentlyContinue left board-server-probe.exe's directory behind with no error
        # surfaced. Retrying briefly clears it without turning a transient lock into
        # permanent debris.
        if ($script:ScratchRoot -and (Test-Path $script:ScratchRoot)) {
            $removed = $false
            for ($i = 0; $i -lt 10 -and -not $removed; $i++) {
                try {
                    Remove-Item -Recurse -Force -Confirm:$false $script:ScratchRoot -ErrorAction Stop
                    $removed = $true
                } catch {
                    Start-Sleep -Milliseconds 300
                }
            }
            if (-not $removed -and (Test-Path $script:ScratchRoot)) {
                Write-Warning "ManifestBoardJoin probe: could not remove scratch dir $script:ScratchRoot after 10 retries - manual cleanup needed (#43)"
            }
        }
    }

    It 'the GATES lane fills from a gate-role member, carrying its gate NAME and verdict word verbatim (assemble.go:124-158, CONSUMER: #76''s PROBE RESULT)' {
        $gatesLane = $script:Snapshot.lanes | Where-Object { $_.id -eq 'gates' }
        $gatesLane | Should -Not -BeNullOrEmpty -Because 'the gates lane is a registered lane in every snapshot (laneregistry.go)'
        $gatesLane.data.gates.Count | Should -Be 1 -Because 'exactly one member (gateA) is role=gate with a returned record; a wrong count means role or state gating broke'
        $gate = $gatesLane.data.gates[0]
        $gate.name | Should -Be 'car-review r1' -Because 'the manifest-declared gate name (manifest.members[].gate) must render verbatim'
        $gate.subject | Should -Be 'gateA'
        $gate.outcome | Should -Be 'APPROVE' -Because 'the returned record''s outcome renders verbatim (design: never re-derived)'
    }

    It 'the TRAINS lane renders the consist with per-member role, state, and outcome (assemble.go:100-122)' {
        $trainsLane = $script:Snapshot.lanes | Where-Object { $_.id -eq 'trains' }
        $trainsLane | Should -Not -BeNullOrEmpty
        $train = $trainsLane.data.trains | Where-Object { $_.id -eq 'train:probe-79' }
        $train | Should -Not -BeNullOrEmpty -Because 'the manifest''s own subject must appear as a rendered train'

        $carA = $train.cars | Where-Object { $_.subject -eq 'carA' }
        $carA | Should -Not -BeNullOrEmpty -Because 'carA is a declared member with a dispatched+returned record'
        $carA.role | Should -Be 'car'
        $carA.state | Should -Be 'returned'
        $carA.outcome | Should -Be 'done'

        $gateA = $train.cars | Where-Object { $_.subject -eq 'gateA' }
        $gateA | Should -Not -BeNullOrEmpty
        $gateA.role | Should -Be 'gate'
        $gateA.state | Should -Be 'returned'
        $gateA.outcome | Should -Be 'APPROVE'

        $carB = $train.cars | Where-Object { $_.subject -eq 'carB' }
        $carB | Should -Not -BeNullOrEmpty -Because 'carB is a declared member, dispatched but not yet returned (in flight)'
        $carB.role | Should -Be 'car'
        $carB.state | Should -Be 'dispatched'
    }

    It 'a declared member with NO record renders in declaredNotObserved (assemble.go:106-108, the completeness assertion #76''s whole design rests on)' {
        $trainsLane = $script:Snapshot.lanes | Where-Object { $_.id -eq 'trains' }
        $train = $trainsLane.data.trains | Where-Object { $_.id -eq 'train:probe-79' }
        $train.declaredNotObserved | Should -Contain 'gateB' -Because 'gateB is declared in the manifest but has zero dispatched/returned records anywhere in the store'
    }

    It 'member dispatch records are marked assigned (assemble.go:183-187, yard inventory assignment flows from manifest membership)' {
        $dispLane = $script:Snapshot.lanes | Where-Object { $_.id -eq 'dispatches' }
        $dispLane | Should -Not -BeNullOrEmpty
        foreach ($subj in @('carA', 'gateA', 'carB')) {
            $entry = $dispLane.data.dispatches | Where-Object { $_.subject -eq $subj }
            $entry | Should -Not -BeNullOrEmpty -Because "$subj must appear on the dispatches lane"
            $entry.assigned | Should -BeTrue -Because "$subj is claimed by train:probe-79's manifest membership"
        }
    }

    It 'ZERO board conditions are raised for the well-formed store (the guard: a quarantine or collision would invalidate a-d silently)' {
        $script:Snapshot.board.Count | Should -Be 0 -Because ("observed board conditions: " + (($script:Snapshot.board | ForEach-Object { $_.code }) -join ', '))
    }
}
