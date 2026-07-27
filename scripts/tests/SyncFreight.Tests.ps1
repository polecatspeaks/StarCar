#requires -Version 7.4
# Sync-Freight.ps1 (#84): the freight lane's ONE writer. -ItemsJsonPath injects a `gh
# project item-list` fixture so every test here runs with no live gh call, no network,
# no token - the real gh invocation is production-only (docstring in the script itself).
#
# Every test invokes the script as a CHILD pwsh process (via the call operator `&`),
# exactly how it will really run, against a throwaway git repo (New-FixtureRepo, the
# same pattern Producer.Tests.ps1 already established for Produce-Artifact.ps1).

Describe 'Sync-Freight' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:Script = Join-Path $script:RepoRoot 'scripts/Sync-Freight.ps1'
        $script:ArtifactSchemaPath = Join-Path $script:RepoRoot 'schema/starcar-artifact.schema.json'
        $script:TicketSchemaPath = Join-Path $script:RepoRoot 'schema/starcar-ticket.schema.json'
        $script:ArtifactSchemaJson = Get-Content $script:ArtifactSchemaPath -Raw -Encoding UTF8
        $script:TicketSchemaJson = Get-Content $script:TicketSchemaPath -Raw -Encoding UTF8

        function New-FixtureRepo {
            $repo = Join-Path ([System.IO.Path]::GetTempPath()) ('freighttest-' + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $repo -Force | Out-Null
            git -C $repo init -q | Out-Null
            git -C $repo config user.email 'test@starcar.local' | Out-Null
            git -C $repo config user.name  'Sync-Freight Test' | Out-Null
            Set-Content -Path (Join-Path $repo 'README') -Value 'seed' -Encoding utf8
            git -C $repo add README | Out-Null
            git -C $repo commit -q -m 'seed' | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $repo 'artifacts') -Force | Out-Null
            $repo
        }

        function New-ItemsFixture {
            param([string]$Dir, [array]$Items)
            $path = Join-Path $Dir 'items.json'
            $payload = @{ items = $Items } | ConvertTo-Json -Depth 10
            Set-Content -Path $path -Value $payload -Encoding utf8
            $path
        }

        function New-BoardItem {
            param([int]$Number, [string]$Title, [string]$Status, [string]$Url)
            [ordered]@{
                content = [ordered]@{ number = $Number; title = $Title; url = $Url }
                status  = $Status
            }
        }

        function Invoke-SyncFreight {
            # try/catch around the `&` invocation: this script's own catch block sets
            # $ErrorActionPreference = 'Stop' in ITS scope, which makes ITS OWN
            # Write-Error call terminating too - invoked via `&` (not a separate
            # process), that terminating error propagates OUT and INTO this runner
            # before `exit 1` is ever reached. Same class Producer.Tests.ps1's own
            # Invoke-Producer helper already documents and works around for
            # Produce-Artifact.ps1 (identical catch-block shape) - ported here rather
            # than rediscovered.
            param([string]$StoreRoot, [string]$ItemsJsonPath, [string]$Now = '2026-07-27T15:00:00Z', [switch]$NoCommit)
            $params = @{ StoreRoot = $StoreRoot; ItemsJsonPath = $ItemsJsonPath; Now = $Now }
            if ($NoCommit) { $params['NoCommit'] = $true }
            $exitCode = 0
            try {
                $out = & $script:Script @params 2>&1
                $exitCode = $LASTEXITCODE
            } catch {
                $out = $_.Exception.Message
                $exitCode = 1
            }
            [pscustomobject]@{ ExitCode = $exitCode; Output = ($out -join "`n") }
        }
    }

    It 'writes one ticket.json per Backlog/Todo item, excludes In Progress and Done, and writes a ticket-sync heartbeat' {
        $repo = New-FixtureRepo
        $storeRoot = Join-Path $repo 'artifacts'
        $itemsPath = New-ItemsFixture -Dir $repo -Items @(
            (New-BoardItem -Number 84 -Title 'Light up the FREIGHT lane' -Status 'Backlog' -Url 'https://github.com/polecatspeaks/StarCar/issues/84')
            (New-BoardItem -Number 90 -Title 'A todo item' -Status 'Todo' -Url 'https://github.com/polecatspeaks/StarCar/issues/90')
            (New-BoardItem -Number 76 -Title 'in flight' -Status 'In Progress' -Url 'https://github.com/polecatspeaks/StarCar/issues/76')
            (New-BoardItem -Number 1 -Title 'done long ago' -Status 'Done' -Url 'https://github.com/polecatspeaks/StarCar/issues/1')
        )

        $result = Invoke-SyncFreight -StoreRoot $storeRoot -ItemsJsonPath $itemsPath
        $result.ExitCode | Should -Be 0 -Because "script output: $($result.Output -join "`n")"

        (Test-Path (Join-Path $storeRoot 'ticket-84/ticket.json')) | Should -BeTrue
        (Test-Path (Join-Path $storeRoot 'ticket-90/ticket.json')) | Should -BeTrue
        (Test-Path (Join-Path $storeRoot 'ticket-76/ticket.json')) | Should -BeFalse
        (Test-Path (Join-Path $storeRoot 'ticket-1/ticket.json')) | Should -BeFalse
        (Test-Path (Join-Path $storeRoot 'ticket-sync/ticket-sync.json')) | Should -BeTrue

        $ticket84 = Get-Content (Join-Path $storeRoot 'ticket-84/ticket.json') -Raw -Encoding UTF8 | ConvertFrom-Json
        $ticket84.kind | Should -Be 'ticket'
        $ticket84.subject | Should -Be 'ticket-84'
        $ticket84.ticket.number | Should -Be 84
        $ticket84.ticket.title | Should -Be 'Light up the FREIGHT lane'
        $ticket84.ticket.status | Should -Be 'Backlog'
        $ticket84.ticket.url | Should -Be 'https://github.com/polecatspeaks/StarCar/issues/84'
    }

    It 'every written ticket record validates against BOTH starcar-artifact/1 and starcar-ticket/1 schemas' {
        $repo = New-FixtureRepo
        $storeRoot = Join-Path $repo 'artifacts'
        $itemsPath = New-ItemsFixture -Dir $repo -Items @(
            (New-BoardItem -Number 84 -Title 'Light up the FREIGHT lane' -Status 'Backlog' -Url 'https://github.com/polecatspeaks/StarCar/issues/84')
        )
        Invoke-SyncFreight -StoreRoot $storeRoot -ItemsJsonPath $itemsPath | Out-Null

        $ticketJson = Get-Content (Join-Path $storeRoot 'ticket-84/ticket.json') -Raw -Encoding UTF8
        $artifactErrors = $null
        $validArtifact = Test-Json -Json $ticketJson -Schema $script:ArtifactSchemaJson -ErrorVariable artifactErrors -ErrorAction SilentlyContinue
        $validArtifact | Should -BeTrue -Because "starcar-artifact/1 errors: $($artifactErrors -join '; ')"

        $ticketErrors = $null
        $validTicket = Test-Json -Json $ticketJson -Schema $script:TicketSchemaJson -ErrorVariable ticketErrors -ErrorAction SilentlyContinue
        $validTicket | Should -BeTrue -Because "starcar-ticket/1 errors: $($ticketErrors -join '; ')"

        $syncJson = Get-Content (Join-Path $storeRoot 'ticket-sync/ticket-sync.json') -Raw -Encoding UTF8
        $syncArtifactErrors = $null
        $validSyncArtifact = Test-Json -Json $syncJson -Schema $script:ArtifactSchemaJson -ErrorVariable syncArtifactErrors -ErrorAction SilentlyContinue
        $validSyncArtifact | Should -BeTrue -Because "ticket-sync starcar-artifact/1 errors: $($syncArtifactErrors -join '; ')"
    }

    It 'the integrity field is a REAL sha256 over the compact canonical body, recomputable with Artifact.psm1''s own Get-Sha256Hex (Law 6, never a second hashing rule)' {
        $repo = New-FixtureRepo
        $storeRoot = Join-Path $repo 'artifacts'
        $itemsPath = New-ItemsFixture -Dir $repo -Items @(
            (New-BoardItem -Number 84 -Title 'Light up the FREIGHT lane' -Status 'Backlog' -Url 'https://github.com/polecatspeaks/StarCar/issues/84')
        )
        Invoke-SyncFreight -StoreRoot $storeRoot -ItemsJsonPath $itemsPath | Out-Null

        Import-Module (Join-Path $script:RepoRoot 'scripts/Artifact.psm1') -Force
        $record = Get-Content (Join-Path $storeRoot 'ticket-84/ticket.json') -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable
        $claimedIntegrity = $record['integrity']
        $record.Remove('integrity')
        # Rebuild the ordered body exactly as the producer does: schema, kind, subject,
        # session_id, at, ticket, normalisation - then hash and compare.
        $ordered = [ordered]@{}
        foreach ($key in @('schema', 'kind', 'subject', 'session_id', 'at', 'ticket', 'normalisation')) {
            $ordered[$key] = $record[$key]
        }
        $bodyJson = $ordered | ConvertTo-Json -Depth 20 -Compress
        $recomputed = 'sha256:' + (Get-Sha256Hex $bodyJson)
        $claimedIntegrity | Should -Be $recomputed
    }

    It 'a SECOND run removes ticket-<n>/ for an issue that left the queue, and updates ticket-sync''s at' {
        $repo = New-FixtureRepo
        $storeRoot = Join-Path $repo 'artifacts'
        $itemsPath1 = New-ItemsFixture -Dir $repo -Items @(
            (New-BoardItem -Number 84 -Title 'Light up the FREIGHT lane' -Status 'Backlog' -Url 'https://github.com/polecatspeaks/StarCar/issues/84')
            (New-BoardItem -Number 90 -Title 'A todo item' -Status 'Todo' -Url 'https://github.com/polecatspeaks/StarCar/issues/90')
        )
        Invoke-SyncFreight -StoreRoot $storeRoot -ItemsJsonPath $itemsPath1 -Now '2026-07-27T15:00:00Z' | Out-Null
        (Test-Path (Join-Path $storeRoot 'ticket-90/ticket.json')) | Should -BeTrue

        # #90 moved to In Progress (or was removed from the board entirely) between runs.
        $itemsPath2 = New-ItemsFixture -Dir $repo -Items @(
            (New-BoardItem -Number 84 -Title 'Light up the FREIGHT lane' -Status 'Backlog' -Url 'https://github.com/polecatspeaks/StarCar/issues/84')
        )
        Invoke-SyncFreight -StoreRoot $storeRoot -ItemsJsonPath $itemsPath2 -Now '2026-07-27T15:10:00Z' | Out-Null

        (Test-Path (Join-Path $storeRoot 'ticket-90')) | Should -BeFalse -Because 'an issue that left the queue must have its ticket directory removed'
        (Test-Path (Join-Path $storeRoot 'ticket-84/ticket.json')) | Should -BeTrue

        # Read RAW text, never ConvertFrom-Json: PowerShell auto-parses an ISO-8601-
        # looking string property into a [datetime], whose default ToString() loses
        # the exact "Z"-suffixed wire form this repo's own schema/records use - the
        # raw JSON text is the actual on-disk contract, so that is what this asserts.
        $syncRaw = Get-Content (Join-Path $storeRoot 'ticket-sync/ticket-sync.json') -Raw -Encoding UTF8
        $syncRaw | Should -Match '"at":\s*"2026-07-27T15:10:00Z"' -Because 'the heartbeat must advance on every successful run, proving freshness derives from a real per-run signal, not a frozen first-write timestamp'
    }

    It 'every touched path is committed in ONE commit - never a bare `git add`/`-a` that could sweep unrelated dirty files' {
        $repo = New-FixtureRepo
        $storeRoot = Join-Path $repo 'artifacts'
        # A co-staged, unrelated dirty file the commit must NOT sweep in (C2R1-M2's rule,
        # applied here the same way Producer.Tests.ps1 already proves it for Produce-Artifact.ps1).
        Set-Content -Path (Join-Path $repo 'unrelated-work-in-progress.txt') -Value 'do not commit me' -Encoding utf8

        $itemsPath = New-ItemsFixture -Dir $repo -Items @(
            (New-BoardItem -Number 84 -Title 'Light up the FREIGHT lane' -Status 'Backlog' -Url 'https://github.com/polecatspeaks/StarCar/issues/84')
        )
        $before = git -C $repo rev-parse HEAD
        $result = Invoke-SyncFreight -StoreRoot $storeRoot -ItemsJsonPath $itemsPath
        $result.ExitCode | Should -Be 0 -Because "script output: $($result.Output -join "`n")"
        $after = git -C $repo rev-parse HEAD
        $after | Should -Not -Be $before -Because 'a real commit must have been made'

        $committedFiles = @(git -C $repo show --name-only --format='' HEAD)
        $committedFiles | Should -Contain 'artifacts/ticket-84/ticket.json'
        $committedFiles | Should -Contain 'artifacts/ticket-sync/ticket-sync.json'
        $committedFiles | Should -Not -Contain 'unrelated-work-in-progress.txt'

        $status = git -C $repo status --porcelain
        ($status | Where-Object { $_ -match 'ticket' }) | Should -BeNullOrEmpty -Because 'every touched ticket path must be clean after the commit'
        ($status | Where-Object { $_ -match 'unrelated-work-in-progress' }) | Should -Not -BeNullOrEmpty -Because 'the unrelated file must remain UNCOMMITTED, untouched by this run'
    }

    It '-NoCommit writes files but makes no commit, for scratch-store non-vacuity testing' {
        $repo = New-FixtureRepo
        $storeRoot = Join-Path $repo 'artifacts'
        $itemsPath = New-ItemsFixture -Dir $repo -Items @(
            (New-BoardItem -Number 84 -Title 'Light up the FREIGHT lane' -Status 'Backlog' -Url 'https://github.com/polecatspeaks/StarCar/issues/84')
        )
        $before = git -C $repo rev-parse HEAD
        $result = Invoke-SyncFreight -StoreRoot $storeRoot -ItemsJsonPath $itemsPath -NoCommit
        $result.ExitCode | Should -Be 0 -Because "script output: $($result.Output -join "`n")"
        $after = git -C $repo rev-parse HEAD
        $after | Should -Be $before -Because '-NoCommit must make no commit'
        (Test-Path (Join-Path $storeRoot 'ticket-84/ticket.json')) | Should -BeTrue -Because 'the write itself still happens under -NoCommit'
    }

    It 'writing against a store NOT inside a git repository skips the commit gracefully rather than throwing' {
        $scratch = Join-Path ([System.IO.Path]::GetTempPath()) ('freight-nogit-' + [guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $scratch -Force | Out-Null
        $itemsPath = New-ItemsFixture -Dir $scratch -Items @(
            (New-BoardItem -Number 84 -Title 'Light up the FREIGHT lane' -Status 'Backlog' -Url 'https://github.com/polecatspeaks/StarCar/issues/84')
        )
        $result = Invoke-SyncFreight -StoreRoot $scratch -ItemsJsonPath $itemsPath
        $result.ExitCode | Should -Be 0 -Because "script output: $($result.Output -join "`n")"
        (Test-Path (Join-Path $scratch 'ticket-84/ticket.json')) | Should -BeTrue
    }

    It 'a genuinely empty queue (all items In Progress/Done) writes ZERO ticket files but still writes the heartbeat - Case 2, "ran and genuinely empty" - proven distinct from never having run at all' {
        $repo = New-FixtureRepo
        $storeRoot = Join-Path $repo 'artifacts'
        $itemsPath = New-ItemsFixture -Dir $repo -Items @(
            (New-BoardItem -Number 76 -Title 'in flight' -Status 'In Progress' -Url 'https://github.com/polecatspeaks/StarCar/issues/76')
        )
        $result = Invoke-SyncFreight -StoreRoot $storeRoot -ItemsJsonPath $itemsPath
        $result.ExitCode | Should -Be 0 -Because "script output: $($result.Output -join "`n")"

        (Get-ChildItem -Path $storeRoot -Directory -Filter 'ticket-*' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^ticket-\d+$' }) | Should -BeNullOrEmpty
        (Test-Path (Join-Path $storeRoot 'ticket-sync/ticket-sync.json')) | Should -BeTrue -Because 'the adapter DID run, even though the queue is empty - this is what distinguishes Case 2 from Case 1 (never ran)'
    }

    It 'a malformed items fixture (a failure BEFORE the write loop even starts) writes NOTHING and exits nonzero' {
        $repo = New-FixtureRepo
        $storeRoot = Join-Path $repo 'artifacts'
        $badItemsPath = Join-Path $repo 'bad-items.json'
        Set-Content -Path $badItemsPath -Value '{ this is not valid json' -Encoding utf8

        $result = Invoke-SyncFreight -StoreRoot $storeRoot -ItemsJsonPath $badItemsPath
        $result.ExitCode | Should -Not -Be 0

        (Test-Path (Join-Path $storeRoot 'ticket-sync/ticket-sync.json')) | Should -BeFalse -Because 'a failed run must write NOTHING, including the heartbeat - the freshness axis is the only failure signal'
        (Get-Content (Join-Path $storeRoot '_faults.log') -Raw -Encoding UTF8) | Should -Match 'freight-sync' -Because 'the failure must be raised, never dropped silently (Law 4)'
    }

    It '#84 fix cycle round 2 (R1-M4): a MID-RUN failure (partway through the write loop) leaves the earlier ticket write on disk but NEVER writes the heartbeat - pins the CORRECTED contract (writes are not atomic as a set; the heartbeat-last ordering is the actual guarantee)' {
        $repo = New-FixtureRepo
        $storeRoot = Join-Path $repo 'artifacts'
        New-Item -ItemType Directory -Path $storeRoot -Force | Out-Null
        # ticket-90 is forced to fail its own directory creation - a FILE
        # (not a directory) already occupies that exact path, so
        # New-Item -ItemType Directory throws when the loop reaches it.
        # Item #1 is listed FIRST (Get-BoardQueueItems/the write loop both
        # preserve fixture order), so #1's write completes successfully
        # BEFORE #90's failure aborts the run - a genuine mid-run partial
        # failure reached through the script's real public interface, never
        # a code-level injection.
        Set-Content -Path (Join-Path $storeRoot 'ticket-90') -Value 'blocking file, not a directory' -Encoding utf8
        $itemsPath = New-ItemsFixture -Dir $repo -Items @(
            (New-BoardItem -Number 1 -Title 'first ticket' -Status 'Backlog' -Url 'https://github.com/polecatspeaks/StarCar/issues/1')
            (New-BoardItem -Number 90 -Title 'blocked ticket' -Status 'Backlog' -Url 'https://github.com/polecatspeaks/StarCar/issues/90')
        )

        $result = Invoke-SyncFreight -StoreRoot $storeRoot -ItemsJsonPath $itemsPath
        $result.ExitCode | Should -Not -Be 0 -Because "script output: $($result.Output -join "`n")"

        (Test-Path (Join-Path $storeRoot 'ticket-1/ticket.json')) | Should -BeTrue -Because 'REGRESSION (R1-M4): the earlier write in the loop must survive a LATER failure - this is the measured, corrected contract, no longer "writes nothing"'
        (Test-Path (Join-Path $storeRoot 'ticket-sync/ticket-sync.json')) | Should -BeFalse -Because 'the heartbeat is written LAST and must NEVER appear after a mid-run failure - this is the one guarantee that still holds and is what board/server R1-M2 depends on'
        (Get-Content (Join-Path $storeRoot '_faults.log') -Raw -Encoding UTF8) | Should -Match 'freight-sync' -Because 'the failure must be raised, never dropped silently (Law 4)'
    }
}
