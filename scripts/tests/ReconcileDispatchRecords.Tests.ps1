#requires -Version 7.4
# ReconcileDispatchRecords.Tests.ps1 -- #32: scripts/Reconcile-DispatchRecords.ps1
# cross-references .claude/probe-logs/subagent-stop.jsonl (survives producer silence -
# a SEPARATE process from the producer, per .claude/hooks/subagent-stop-probe.sh)
# against the artifact store, and reports LOUDLY every probe-log firing the producer
# would have adapted (Claude basis: non-empty agent_type) but which has no matching
# `returned` record (subject == agent_id).
#
# WHY: #32 - on 2026-07-23 the producer wrote NO record for 2 of 3 dispatches, git
# status clean, the failure INVISIBLE (Detect-Dispatches.ps1 only ever sees
# overdue = dispatched-without-returned; a dispatch whose record never got WRITTEN
# produces no signal there at all). This suite pins the detector's own fixture
# behaviour (never touches the real store or the real probe log) and separately pins
# a DIVERGENCE test against the real Produce-Artifact.ps1, using the real fixtures at
# scripts/tests/fixtures/payloads/ (never hand-copied).

Describe 'Reconcile-DispatchRecords.ps1 - fixture behaviour (#32)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:Script = Join-Path $script:RepoRoot 'scripts/Reconcile-DispatchRecords.ps1'

        function New-FixtureDir {
            $d = Join-Path ([System.IO.Path]::GetTempPath()) ("reconcile-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $d -Force | Out-Null
            $d
        }

        # Writes ONE probe-log-shaped JSON line - the real hook payload shape
        # (subagent-stop-probe.sh appends _probe_transcript_exists_at_fire and
        # _probe_logged_at to the raw SubagentStop payload).
        function Add-ProbeLine {
            param([string]$ProbeLogPath, [string]$AgentId, [string]$AgentType, [string]$LoggedAt)
            $line = [ordered]@{
                agent_id = $AgentId
                agent_type = $AgentType
                agent_transcript_path = ''
                session_id = 'sess-fixture'
                hook_event_name = 'SubagentStop'
                '_probe_transcript_exists_at_fire' = $false
                '_probe_logged_at' = $LoggedAt
            } | ConvertTo-Json -Compress
            Add-Content -Path $ProbeLogPath -Value $line -Encoding utf8
        }

        function New-ReturnedRecord {
            param([string]$StoreRoot, [string]$Subject)
            $dir = Join-Path $StoreRoot $Subject
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $record = [ordered]@{
                schema = 'starcar-artifact/1'
                kind = 'returned'
                subject = $Subject
                session_id = 'sess-fixture'
                at = '2026-07-23T10:00:00Z'
                outcome = 'completed'
                findings = '0'
                abstract = 'fixture record'
            } | ConvertTo-Json -Compress
            Set-Content -Path (Join-Path $dir 'returned-20260723T100000Z.json') -Value $record -Encoding utf8
        }

        function Invoke-Reconcile {
            param([string]$ProbeLog, [string]$StoreRoot)
            $out = & $script:Script -ProbeLog $ProbeLog -StoreRoot $StoreRoot 2>&1
            [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($out -join "`n") }
        }
    }

    It 'the script exists at scripts/Reconcile-DispatchRecords.ps1' {
        Test-Path $script:Script | Should -BeTrue
    }

    It 'exits nonzero and names the gap when a would-have-adapted firing has no matching returned record' {
        $dir = New-FixtureDir
        $probeLog = Join-Path $dir 'subagent-stop.jsonl'
        $store = Join-Path $dir 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'gap-agent-123' -AgentType 'car' -LoggedAt '2026-07-23T09:00:00Z'
        # Store deliberately has NO matching returned record for gap-agent-123.

        $r = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store
        $r.ExitCode | Should -Not -Be 0
        $r.Output | Should -Match 'gap-agent-123'
        $r.Output | Should -Match '2026-07-23T09:00:00Z'
        $r.Output | Should -Match 'returned'
    }

    It 'exits 0 when every would-have-adapted firing has a matching returned record' {
        $dir = New-FixtureDir
        $probeLog = Join-Path $dir 'subagent-stop.jsonl'
        $store = Join-Path $dir 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'complete-agent-456' -AgentType 'car' -LoggedAt '2026-07-23T09:05:00Z'
        New-ReturnedRecord -StoreRoot $store -Subject 'complete-agent-456'

        $r = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store
        $r.ExitCode | Should -Be 0
    }

    It 'excludes probe lines with empty agent_type (internal harness subagents) - never a false gap' {
        $dir = New-FixtureDir
        $probeLog = Join-Path $dir 'subagent-stop.jsonl'
        $store = Join-Path $dir 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'internal-agent-789' -AgentType '' -LoggedAt '2026-07-23T09:10:00Z'
        # Store stays empty - an internal subagent is NEVER expected to have a record.

        $r = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store
        $r.ExitCode | Should -Be 0
        $r.Output | Should -Not -Match 'internal-agent-789'
    }

    It 'a mixed probe log reports ONLY the real gap, not the excluded internal entry or the satisfied one' {
        $dir = New-FixtureDir
        $probeLog = Join-Path $dir 'subagent-stop.jsonl'
        $store = Join-Path $dir 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'internal-agent-789' -AgentType '' -LoggedAt '2026-07-23T09:10:00Z'
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'complete-agent-456' -AgentType 'car' -LoggedAt '2026-07-23T09:05:00Z'
        # gap-agent-123's LoggedAt is deliberately AFTER the store's one returned
        # record (at 2026-07-23T10:00:00Z, New-ReturnedRecord's fixed fixture time) -
        # fix cycle round 2, M5: the default epoch floor derives from the store's
        # earliest returned record, and a gap logged BEFORE that floor is excluded as
        # pre-epoch (see the dedicated M5 Describe block below). This entry must stay
        # POST-floor so this test keeps exercising "a real gap is reported", not the
        # epoch-exclusion path.
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'gap-agent-123' -AgentType 'car' -LoggedAt '2026-07-23T11:00:00Z'
        New-ReturnedRecord -StoreRoot $store -Subject 'complete-agent-456'

        $r = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store
        $r.ExitCode | Should -Not -Be 0
        $r.Output | Should -Match 'gap-agent-123'
        $r.Output | Should -Not -Match 'internal-agent-789'
        $r.Output | Should -Not -Match 'complete-agent-456'
    }

    It 'an absent probe log (no firings yet) is a clean exit 0, never a fault' {
        $dir = New-FixtureDir
        $probeLog = Join-Path $dir 'does-not-exist.jsonl'
        $store = Join-Path $dir 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null

        $r = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store
        $r.ExitCode | Should -Be 0
    }
}

Describe 'Reconcile-DispatchRecords.ps1 rule agrees with Produce-Artifact.ps1 (#32 divergence pin)' {
    # THIS IS A DELIBERATE SECOND COPY of Produce-Artifact.ps1's Claude-returned subject
    # rule (would-have-adapted iff agent_type non-empty; subject = agent_id) - disclosed
    # in scripts/Reconcile-DispatchRecords.ps1's own header. Rather than comparing static
    # source text (illustrating, not testing - CLAUDE.md's own scar: `sweep = dict(hook)`
    # sha256(x)==sha256(x)), this test chains the two scripts' REAL BEHAVIOUR: the
    # producer WRITES a record from a real fixture payload, and the reconciler is then
    # asked whether that exact record satisfies the SAME fixture's probe-log line. If
    # either script's identity rule drifts (a different subject field, a different
    # exclusion test), this goes red BY NAME - the register-taxonomy divergence-pin
    # precedent (#37, board/web/test/register-taxonomy.test.js), applied here as a
    # behavioural chain instead of a static set-equality check because the two
    # "sources of truth" are code paths, not data structures.
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:ProducerScript = Join-Path $script:RepoRoot 'scripts/Produce-Artifact.ps1'
        $script:ReconcileScript = Join-Path $script:RepoRoot 'scripts/Reconcile-DispatchRecords.ps1'
        $script:Fixtures = Join-Path $script:RepoRoot 'scripts/tests/fixtures/payloads'

        function Get-Payload([string]$Name) {
            (Get-Content (Join-Path $script:Fixtures $Name) -Raw) -replace '<repo>', ($script:RepoRoot -replace '\\', '/')
        }

        function New-FixtureRepo {
            $repo = Join-Path ([System.IO.Path]::GetTempPath()) ("reconcile-divergence-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $repo -Force | Out-Null
            git -C $repo init -q | Out-Null
            git -C $repo config user.email 'test@starcar.local' | Out-Null
            git -C $repo config user.name  'Reconcile Divergence Test' | Out-Null
            Set-Content -Path (Join-Path $repo 'README') -Value 'seed' -Encoding utf8
            git -C $repo add README | Out-Null
            git -C $repo commit -q -m 'seed' | Out-Null
            $repo
        }

        function Invoke-Producer {
            param([string]$Payload, [string]$StoreRoot)
            $out = $Payload | & $script:ProducerScript -Kind 'returned' -StoreRoot $StoreRoot -Now '2026-07-23T10:00:00Z' 2>&1
            [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($out -join "`n") }
        }

        function Invoke-Reconcile {
            param([string]$ProbeLog, [string]$StoreRoot)
            $out = & $script:ReconcileScript -ProbeLog $ProbeLog -StoreRoot $StoreRoot 2>&1
            [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($out -join "`n") }
        }

        # Builds a probe-log line straight from the real fixture payload (never
        # hand-copied) plus the two probe-specific fields subagent-stop-probe.sh adds.
        function New-ProbeLineFromFixture {
            param([string]$FixtureName, [string]$LoggedAt)
            $payload = Get-Payload $FixtureName | ConvertFrom-Json
            $payload | Add-Member -NotePropertyName '_probe_transcript_exists_at_fire' -NotePropertyValue $false
            $payload | Add-Member -NotePropertyName '_probe_logged_at' -NotePropertyValue $LoggedAt
            $payload | ConvertTo-Json -Compress
        }
    }

    It 'a REAL dispatch (stop-car.json): the producer''s written record satisfies the reconciler''s gap check for the SAME fixture' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'

        # The producer writes a real returned record from the real fixture payload.
        $prod = Invoke-Producer -Payload (Get-Payload 'stop-car.json') -StoreRoot $store
        $prod.ExitCode | Should -Be 0

        # A probe log carrying the SAME fixture's shape (agent_id a88e7dadda60940ac,
        # agent_type "car") must NOT be reported as a gap against the store the
        # producer just wrote to - if the reconciler's subject/would-have-adapted
        # rule drifted from the producer's, this would go red.
        #
        # FIX CYCLE ROUND 3, N4 (Major): LoggedAt is deliberately AFTER the producer's
        # own -Now ('2026-07-23T10:00:00Z' below, which becomes this store's derived
        # epoch floor once the record lands). Round 2 adversarial review caught this
        # test using a PRE-floor LoggedAt ('09:00:00Z') - the M5 epoch floor then
        # excluded this line as pre-epoch on EVERY run, so the "not a gap" assertion
        # passed vacuously whether or not the subject rule actually agreed with the
        # producer's, and producer-side subject drift (round-1 injection C:
        # Produce-Artifact.ps1:165 agent_id -> session_id) went uncaught (14/14 green
        # under the injection, was 8/1 failed-by-name in round 1). A post-floor
        # LoggedAt forces this test through the ACTUAL subject-matching path instead
        # of the epoch-exclusion path - this car reproduced the injection by hand
        # after this fix (see this car's report) and confirmed the pin fails by name
        # again, then reverted Produce-Artifact.ps1 byte-identical.
        $probeLogDir = Join-Path ([System.IO.Path]::GetTempPath()) ("reconcile-divergence-log-" + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $probeLogDir -Force | Out-Null
        $probeLog = Join-Path $probeLogDir 'subagent-stop.jsonl'
        Set-Content -Path $probeLog -Value (New-ProbeLineFromFixture -FixtureName 'stop-car.json' -LoggedAt '2026-07-23T11:00:00Z') -Encoding utf8

        $recon = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store
        $recon.ExitCode | Should -Be 0
        $recon.Output | Should -Not -Match 'a88e7dadda60940ac'
    }

    It 'a REAL dispatch (stop-car.json) against an EMPTY store: the reconciler flags the exact agent_id the producer would have written as subject' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null
        # Deliberately do NOT invoke the producer - the store stays empty, simulating
        # #32's silent-drop failure.

        $probeLogDir = Join-Path ([System.IO.Path]::GetTempPath()) ("reconcile-divergence-log-" + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $probeLogDir -Force | Out-Null
        $probeLog = Join-Path $probeLogDir 'subagent-stop.jsonl'
        Set-Content -Path $probeLog -Value (New-ProbeLineFromFixture -FixtureName 'stop-car.json' -LoggedAt '2026-07-23T09:00:00Z') -Encoding utf8

        $recon = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store
        $recon.ExitCode | Should -Not -Be 0
        $recon.Output | Should -Match 'a88e7dadda60940ac'
    }

    It 'an INTERNAL subagent (stop-internal.json, empty agent_type): both scripts agree it is excluded' {
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'

        # The producer, per its OWN existing pin (Producer.Tests.ps1), writes NOTHING
        # for this payload - confirmed here too so this test does not silently rely on
        # an assumption the other suite could change independently.
        $prod = Invoke-Producer -Payload (Get-Payload 'stop-internal.json') -StoreRoot $store
        $prod.ExitCode | Should -Be 0
        (Get-ChildItem -Path $store -Recurse -Filter *.json -ErrorAction SilentlyContinue).Count | Should -Be 0

        $probeLogDir = Join-Path ([System.IO.Path]::GetTempPath()) ("reconcile-divergence-log-" + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $probeLogDir -Force | Out-Null
        $probeLog = Join-Path $probeLogDir 'subagent-stop.jsonl'
        Set-Content -Path $probeLog -Value (New-ProbeLineFromFixture -FixtureName 'stop-internal.json' -LoggedAt '2026-07-23T09:10:00Z') -Encoding utf8

        # The reconciler must ALSO treat this as excluded (no gap), agreeing with the
        # producer's own filter - never reporting a false gap for an internal subagent.
        $recon = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store
        $recon.ExitCode | Should -Be 0
        $recon.Output | Should -Not -Match 'ad3814d978427e657'
    }

    It 'PRODUCER-SIDE SUBJECT DRIFT is caught: if Produce-Artifact.ps1''s Claude-returned subject field ever changes, the pin reports a gap instead of going silent (#32, fix cycle round 3, N4)' {
        # Round-2 adversarial review (artifacts/reviews/2026-07-26-tooling-50-32-review-
        # round2-REJECT-CAPPED.md, finding N4): the M5 epoch floor made the ABOVE pin
        # test vacuous - its probe line was always pre-epoch, always excluded, so the
        # "not a gap" assertion passed regardless of whether the subject rules actually
        # agreed. Round-1 injection C (Produce-Artifact.ps1:165, `agent_id` -> `session_id`)
        # went from 8 passed/1 failed-by-name to 14/14 green. The car reproduced that
        # injection BY HAND against the real, tracked file after fixing the pin's
        # fixture LoggedAt above, observed it fail by name again (13/14, the SAME test
        # above), then reverted Produce-Artifact.ps1 byte-identical (git diff empty,
        # SHA-256 a8eba4a3...db43f both before and after) - see this car's report for
        # the transcript of that one-time verification.
        #
        # THIS test is the LANDED, PERMANENT form of that same proof: it NEVER commits
        # or leaves behind a change to the real, tracked Produce-Artifact.ps1 (mutating
        # a shipped, latency-critical, heavily-tested script during automated test
        # execution - even with a revert - is the fragile pattern this design avoids: a
        # crashed test run could leave it corrupted for every run after). Instead it
        # copies the real file's TEXT, applies the SAME textual drift to a SIBLING
        # file (same directory as the real script, so its own `$PSScriptRoot`-relative
        # module imports - Envelope.psm1, Artifact.psm1 - still resolve), invokes that
        # copy as the producer, and deletes it in a `finally` block that runs even if
        # an assertion above throws. If a future edit removes the divergence pin's
        # sensitivity again (whether by another epoch-floor-shaped bug or by any other
        # means), THIS test goes red by name without anyone needing to hand-inject
        # anything.
        $repo = New-FixtureRepo
        $store = Join-Path $repo 'artifacts'

        $originalText = Get-Content $script:ProducerScript -Raw
        $needle = "`$subject = Get-Prop `$payload 'agent_id'   # mode (b): the runtime's stable pairing id"
        $originalText | Should -Match ([regex]::Escape($needle))   # sanity: the injection point still exists verbatim
        $driftedText = $originalText.Replace($needle, "`$subject = Get-Prop `$payload 'session_id'   # [TEST-ONLY INJECTED DRIFT, N4 regression guard]")
        $driftedText | Should -Not -Be $originalText   # sanity: the replace actually changed something

        $driftedProducerPath = Join-Path (Split-Path $script:ProducerScript -Parent) ("Produce-Artifact-drifted-test-copy-" + [guid]::NewGuid().ToString('N') + '.ps1')
        try {
            Set-Content -Path $driftedProducerPath -Value $driftedText -Encoding utf8

            $out = (Get-Payload 'stop-car.json') | & $driftedProducerPath -Kind 'returned' -StoreRoot $store -Now '2026-07-23T10:00:00Z' 2>&1
            $driftedProducerExit = $LASTEXITCODE
            $driftedProducerExit | Should -Be 0

            $probeLogDir = Join-Path ([System.IO.Path]::GetTempPath()) ("reconcile-divergence-log-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $probeLogDir -Force | Out-Null
            $probeLog = Join-Path $probeLogDir 'subagent-stop.jsonl'
            # Post-floor LoggedAt (N4's own fix, same reasoning as the pin test above) -
            # this line must go through the ACTUAL subject-matching path, never the
            # epoch-exclusion path.
            Set-Content -Path $probeLog -Value (New-ProbeLineFromFixture -FixtureName 'stop-car.json' -LoggedAt '2026-07-23T11:00:00Z') -Encoding utf8

            # THE PIN: under drift, the drifted producer wrote `subject` = the payload's
            # session_id (a completely different value from agent_id), so the reconciler
            # - which still derives subject = agent_id, per its OWN undrifted copy of the
            # rule - must report this as an unmatched gap. If it does not, the two rules
            # have silently diverged and gone uncaught.
            $recon = & $script:ReconcileScript -ProbeLog $probeLog -StoreRoot $store 2>&1
            $reconExit = $LASTEXITCODE
            $reconOutput = ($recon -join "`n")
            $reconExit | Should -Not -Be 0
            $reconOutput | Should -Match 'a88e7dadda60940ac'
        } finally {
            Remove-Item -Path $driftedProducerPath -Force -ErrorAction SilentlyContinue
        }
    }
}

Describe 'Reconcile-DispatchRecords.ps1 - the producer-epoch floor (#32, fix cycle round 2, M5)' {
    # ROUND-1 FINDING: wired into the nightly goodnight sweep without ever being run
    # against the real corpus. Run there (read-only, this car), it exited 1 with 9
    # gaps across 7 agents - EVERY one at or before 2026-07-22T16:35:08Z, while the
    # earliest producer-written returned record in the real store is
    # 2026-07-22T16:40:01Z. All 9 are pre-producer-epoch firings (the producer hook
    # did not exist yet, or had not yet been wired, at the time they fired) -
    # structurally expected, never instances of the #32 class this script exists to
    # detect. A nightly step reporting the same 9 non-defects forever is exactly the
    # severity-philosophy scar this repo already paid: "expected/placeholder patterns
    # are NOTES, defects are FLAGS - an instrument that cries wolf is worse than none."
    #
    # THE FIX: the default epoch floor is DERIVED FROM THE STORE - the earliest
    # `kind: returned` record's `at` timestamp - never hand-set and never stale, since
    # it moves forward automatically as the real store accumulates history. A probe
    # firing whose `_probe_logged_at` predates the floor and has no matching record is
    # EXCLUDED as expected-not-a-gap and counted in one NOTE-severity summary line,
    # never a FLAG. -Since overrides the derived floor for tests (and for a future
    # need to widen or narrow it deliberately). A missing/unparseable `_probe_logged_at`
    # can never be proven pre-epoch, so it is NEVER excluded - it stays a reported gap
    # (conservative: never silently suppress a signal the epoch logic cannot justify
    # suppressing), with `logged_at=unknown` rendered explicitly rather than blank (m3).
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:Script = Join-Path $script:RepoRoot 'scripts/Reconcile-DispatchRecords.ps1'

        function New-FixtureDir {
            $d = Join-Path ([System.IO.Path]::GetTempPath()) ("reconcile-epoch-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $d -Force | Out-Null
            $d
        }

        function Add-ProbeLine {
            param([string]$ProbeLogPath, [string]$AgentId, [string]$AgentType, [string]$LoggedAt)
            $props = [ordered]@{
                agent_id = $AgentId
                agent_type = $AgentType
                agent_transcript_path = ''
                session_id = 'sess-fixture'
                hook_event_name = 'SubagentStop'
                '_probe_transcript_exists_at_fire' = $false
            }
            if ($null -ne $LoggedAt) { $props['_probe_logged_at'] = $LoggedAt }
            $line = [pscustomobject]$props | ConvertTo-Json -Compress
            Add-Content -Path $ProbeLogPath -Value $line -Encoding utf8
        }

        function New-ReturnedRecord {
            param([string]$StoreRoot, [string]$Subject, [string]$At)
            $dir = Join-Path $StoreRoot $Subject
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            $record = [ordered]@{
                schema = 'starcar-artifact/1'
                kind = 'returned'
                subject = $Subject
                session_id = 'sess-fixture'
                at = $At
                outcome = 'completed'
                findings = '0'
                abstract = 'fixture record'
            } | ConvertTo-Json -Compress
            Set-Content -Path (Join-Path $dir "returned-epoch-fixture.json") -Value $record -Encoding utf8
        }

        function Invoke-Reconcile {
            param([string]$ProbeLog, [string]$StoreRoot, [string]$Since)
            $p = @{ ProbeLog = $ProbeLog; StoreRoot = $StoreRoot }
            if ($Since) { $p['Since'] = $Since }
            $out = & $script:Script @p 2>&1
            [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($out -join "`n") }
        }
    }

    It 'a pre-epoch line (before -Since) with no matching record is excluded, never reported as a gap' {
        $dir = New-FixtureDir
        $probeLog = Join-Path $dir 'subagent-stop.jsonl'
        $store = Join-Path $dir 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'pre-epoch-agent' -AgentType 'car' -LoggedAt '2026-07-22T14:00:00+00:00'

        $r = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store -Since '2026-07-22T16:40:01Z'
        $r.ExitCode | Should -Be 0
        $r.Output | Should -Not -Match 'pre-epoch-agent'
        $r.Output | Should -Match '1.*pre-producer-epoch'
    }

    It 'a fixture with ONE pre-epoch line and ONE post-epoch gap: exit nonzero naming ONLY the post-epoch gap' {
        $dir = New-FixtureDir
        $probeLog = Join-Path $dir 'subagent-stop.jsonl'
        $store = Join-Path $dir 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'pre-epoch-agent' -AgentType 'car' -LoggedAt '2026-07-22T14:00:00+00:00'
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'post-epoch-gap-agent' -AgentType 'car' -LoggedAt '2026-07-22T17:00:00+00:00'

        $r = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store -Since '2026-07-22T16:40:01Z'
        $r.ExitCode | Should -Not -Be 0
        $r.Output | Should -Match 'post-epoch-gap-agent'
        $r.Output | Should -Not -Match 'pre-epoch-agent'
    }

    It 'the default floor DERIVES from the store''s earliest returned record when -Since is not given' {
        $dir = New-FixtureDir
        $probeLog = Join-Path $dir 'subagent-stop.jsonl'
        $store = Join-Path $dir 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null
        New-ReturnedRecord -StoreRoot $store -Subject 'establishes-the-floor' -At '2026-07-22T16:40:01Z'
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'pre-epoch-agent' -AgentType 'car' -LoggedAt '2026-07-22T14:00:00+00:00'
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'post-epoch-gap-agent' -AgentType 'car' -LoggedAt '2026-07-22T17:00:00+00:00'

        $r = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store
        $r.ExitCode | Should -Not -Be 0
        $r.Output | Should -Match 'post-epoch-gap-agent'
        $r.Output | Should -Not -Match 'pre-epoch-agent'
    }

    It 'a missing/unparseable logged_at is NEVER excluded as pre-epoch, and renders as unknown (m3), never blank' {
        $dir = New-FixtureDir
        $probeLog = Join-Path $dir 'subagent-stop.jsonl'
        $store = Join-Path $dir 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'no-timestamp-agent' -AgentType 'car' -LoggedAt $null

        $r = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store -Since '2026-07-22T16:40:01Z'
        $r.ExitCode | Should -Not -Be 0
        $r.Output | Should -Match 'no-timestamp-agent'
        $r.Output | Should -Match 'logged_at=unknown'
    }

    It 'an all-pre-epoch fixture exits 0 and notes the exclusion count, never crying wolf' {
        $dir = New-FixtureDir
        $probeLog = Join-Path $dir 'subagent-stop.jsonl'
        $store = Join-Path $dir 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'pre-epoch-a' -AgentType 'car' -LoggedAt '2026-07-22T14:00:00+00:00'
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'pre-epoch-b' -AgentType 'car' -LoggedAt '2026-07-22T15:00:00+00:00'

        $r = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store -Since '2026-07-22T16:40:01Z'
        $r.ExitCode | Should -Be 0
        $r.Output | Should -Match '2.*pre-producer-epoch'
    }

    It 'an all-excluded run (fix cycle round 3, N5) never claims "every ... firing has a matching returned record" - neither of these two HAS a record, they were excluded' {
        # Round-2 adversarial review, minor N5: Reconcile-DispatchRecords.ps1's trailing
        # summary line was UNCONDITIONAL - "no gaps - every would-have-adapted probe
        # firing has a matching returned record" printed even when every firing was
        # EXCLUDED as pre-epoch and NONE matched a store record. That sentence is false
        # in this composition: an excluded firing has no record either, it was simply
        # never checked against one. The NOTE line above it does not repair the false
        # claim in the line below it (Law 1).
        $dir = New-FixtureDir
        $probeLog = Join-Path $dir 'subagent-stop.jsonl'
        $store = Join-Path $dir 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'pre-epoch-only-a' -AgentType 'car' -LoggedAt '2026-07-22T14:00:00+00:00'
        Add-ProbeLine -ProbeLogPath $probeLog -AgentId 'pre-epoch-only-b' -AgentType 'car' -LoggedAt '2026-07-22T15:00:00+00:00'

        $r = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store -Since '2026-07-22T16:40:01Z'
        $r.ExitCode | Should -Be 0
        $r.Output | Should -Not -Match 'no gaps - every would-have-adapted probe firing has a matching returned record'
    }

    It 'a run with ZERO firings at all (no exclusions, no gaps) keeps the unconditional "every firing has a matching record" claim - it is TRUE in this composition' {
        $dir = New-FixtureDir
        $probeLog = Join-Path $dir 'subagent-stop.jsonl'
        $store = Join-Path $dir 'artifacts'
        New-Item -ItemType Directory -Path $store -Force | Out-Null
        # No probe lines at all - vacuously, every (zero) firing has a matching record.

        $r = Invoke-Reconcile -ProbeLog $probeLog -StoreRoot $store
        $r.ExitCode | Should -Be 0
        $r.Output | Should -Match 'no gaps - every would-have-adapted probe firing has a matching returned record'
    }
}
