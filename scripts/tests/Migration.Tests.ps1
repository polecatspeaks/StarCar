#requires -Version 7.4
# The migration tool (Task C.1, spec S4 rows 4-5). Migrate-Verdicts.ps1 moves
# docs/reviews/*.md verdict bodies into artifacts/reviews/ via `git mv` (history
# preserved) and writes a sibling starcar-artifact/1 JSON record per body - parsing
# the verdict's OWN envelope fence where present (R7v2), deterministic fallback where
# not (the 3 fence-less early verdicts measured at base).

Describe 'Migrate-Verdicts' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:Script = Join-Path $script:RepoRoot 'scripts/Migrate-Verdicts.ps1'
        $script:SchemaPath = Join-Path $script:RepoRoot 'schema/starcar-artifact.schema.json'
        Import-Module (Join-Path $script:RepoRoot 'scripts/Artifact.psm1') -Force

        function Get-Sha256Hex([string]$Text) {
            $sha = [System.Security.Cryptography.SHA256]::Create()
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
            $hash = $sha.ComputeHash($bytes)
            $sha.Dispose()
            ([System.BitConverter]::ToString($hash) -replace '-', '').ToLower()
        }

        # A throwaway git repo with real history, so git mv and git log --follow are
        # exercised on the real path, not a dot-sourced shortcut.
        function New-FixtureRepo {
            $repo = Join-Path ([System.IO.Path]::GetTempPath()) ("migtest-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $repo -Force | Out-Null
            git -C $repo init -q | Out-Null
            git -C $repo config user.email 'test@starcar.local' | Out-Null
            git -C $repo config user.name 'Migration Test' | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $repo 'docs/reviews') -Force | Out-Null
            $repo
        }

        function Get-VerdictBody {
            # Builds a REAL, self-consistent starcar-integrity header (Land-Verdict.ps1's
            # own algorithm: sha256 over every byte AFTER the first line) rather than a
            # dummy placeholder -- Verify-Verdict.ps1 recomputes and compares, so a fixture
            # with a fake hash correctly reports MISMATCH, which is not the anti-trap this
            # test targets.
            param([string]$Title, [string]$Verdict, [string]$Fence = '')
            $lines = New-Object System.Collections.Generic.List[string]
            $lines.Add("# $Title")
            $lines.Add('')
            $lines.Add('Status: Done')
            $lines.Add("**Verdict: $Verdict**")
            $lines.Add('')
            $lines.Add('Body text, a real review would go here.')
            if ($Fence) {
                $lines.Add('')
                $lines.Add('```starcar-artifact')
                foreach ($l in ($Fence -split "`n")) { $lines.Add($l) }
                $lines.Add('```')
            }
            $rest = ($lines -join "`n") + "`n"
            $hash = Get-Sha256Hex $rest
            "<!-- starcar-integrity: sha256=$hash covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->`n" + $rest
        }

        function Add-Verdict {
            param([string]$Repo, [string]$Name, [string]$Content)
            $path = Join-Path $Repo "docs/reviews/$Name"
            $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
            [System.IO.File]::WriteAllText($path, $Content, $utf8NoBom)
            git -C $Repo add -- "docs/reviews/$Name" | Out-Null
            git -C $Repo commit -q -m "verdict: $Name" | Out-Null
        }
    }

    It 'produces a schema-valid record with envelope-fence fields when the verdict body carries one' {
        $repo = New-FixtureRepo
        $fence = "outcome: APPROVE`nfindings: none`nabstract: all clean"
        Add-Verdict -Repo $repo -Name 'with-fence.md' -Content (Get-VerdictBody -Title 'A review' -Verdict 'APPROVE' -Fence $fence)
        & $script:Script -SourceDir (Join-Path $repo 'docs/reviews') -DestDir (Join-Path $repo 'artifacts/reviews')
        $LASTEXITCODE | Should -Be 0

        $jsonPath = Join-Path $repo 'artifacts/reviews/with-fence.json'
        Test-Path $jsonPath | Should -BeTrue
        Test-Path (Join-Path $repo 'artifacts/reviews/with-fence.md') | Should -BeTrue
        Test-Path (Join-Path $repo 'docs/reviews/with-fence.md') | Should -BeFalse

        $rec = Get-Content $jsonPath -Raw | ConvertFrom-Json -DateKind String
        $rec.schema | Should -Be 'starcar-artifact/1'
        $rec.kind | Should -Be 'returned'
        $rec.subject | Should -Be 'with-fence'
        $rec.session_id | Should -Be 'pre-harness-migration'
        $rec.outcome | Should -Be 'APPROVE'
        $rec.findings | Should -Be 'none'
        $rec.abstract | Should -Be 'all clean'
        $rec.body_file | Should -Be 'reviews/with-fence.md'
        @($rec.normalisation).Count | Should -Be 0
        (Test-StarcarArtifact -InputObject $rec -SchemaPath $script:SchemaPath).Valid | Should -BeTrue
    }

    It 'falls back to the header leading token and title line when no fence is present (3 fence-less early verdicts, measured)' {
        $repo = New-FixtureRepo
        Add-Verdict -Repo $repo -Name 'no-fence.md' -Content (Get-VerdictBody -Title 'A rejected review' -Verdict 'REJECT - 3 Major, 1 Minor')
        & $script:Script -SourceDir (Join-Path $repo 'docs/reviews') -DestDir (Join-Path $repo 'artifacts/reviews')
        $LASTEXITCODE | Should -Be 0

        $rec = Get-Content (Join-Path $repo 'artifacts/reviews/no-fence.json') -Raw | ConvertFrom-Json -DateKind String
        $rec.outcome | Should -Be 'REJECT'
        $rec.findings | Should -Be 'migrated: see body_file'
        $rec.abstract | Should -Be 'A rejected review'
        (Test-StarcarArtifact -InputObject $rec -SchemaPath $script:SchemaPath).Valid | Should -BeTrue
    }

    It 'the integrity hash round-trips over the canonical body, excluding integrity itself [C3R1-M1/n2: the hash, not field presence]' {
        $repo = New-FixtureRepo
        $fence = "outcome: APPROVE`nfindings: none`nabstract: all clean"
        Add-Verdict -Repo $repo -Name 'hash-check.md' -Content (Get-VerdictBody -Title 'Hash check' -Verdict 'APPROVE' -Fence $fence)
        & $script:Script -SourceDir (Join-Path $repo 'docs/reviews') -DestDir (Join-Path $repo 'artifacts/reviews')

        $rec = Get-Content (Join-Path $repo 'artifacts/reviews/hash-check.json') -Raw | ConvertFrom-Json -DateKind String
        $rec.integrity | Should -Match '^sha256:[0-9a-f]+$'
        # Re-derive independently: every field in file order EXCEPT integrity, compact JSON -
        # a shape that carries the field but a bogus hash must NOT pass this assertion.
        $copy = [ordered]@{}
        foreach ($p in $rec.PSObject.Properties) { if ($p.Name -ne 'integrity') { $copy[$p.Name] = $p.Value } }
        $body = $copy | ConvertTo-Json -Depth 20 -Compress
        ('sha256:' + (Get-Sha256Hex $body)) | Should -Be $rec.integrity
    }

    It 'is idempotent: a second run over the same source/dest changes nothing' {
        $repo = New-FixtureRepo
        Add-Verdict -Repo $repo -Name 'idempotent.md' -Content (Get-VerdictBody -Title 'Idempotent check' -Verdict 'APPROVE')
        & $script:Script -SourceDir (Join-Path $repo 'docs/reviews') -DestDir (Join-Path $repo 'artifacts/reviews')
        $before = Get-Content (Join-Path $repo 'artifacts/reviews/idempotent.json') -Raw
        & $script:Script -SourceDir (Join-Path $repo 'docs/reviews') -DestDir (Join-Path $repo 'artifacts/reviews')
        $LASTEXITCODE | Should -Be 0
        $after = Get-Content (Join-Path $repo 'artifacts/reviews/idempotent.json') -Raw
        $after | Should -Be $before
        @(Get-ChildItem (Join-Path $repo 'docs/reviews') -Filter *.md -ErrorAction SilentlyContinue).Count | Should -Be 0
    }

    It 'the index regenerated over the fixture store includes the migrated rows' {
        $repo = New-FixtureRepo
        Add-Verdict -Repo $repo -Name 'indexed.md' -Content (Get-VerdictBody -Title 'Indexed' -Verdict 'APPROVE')
        & $script:Script -SourceDir (Join-Path $repo 'docs/reviews') -DestDir (Join-Path $repo 'artifacts/reviews')
        $indexOut = Join-Path $repo 'artifacts/index.md'
        & pwsh -NoProfile -File (Join-Path $script:RepoRoot 'scripts/New-ArtifactIndex.ps1') -StoreRoot (Join-Path $repo 'artifacts') -OutFile $indexOut
        $LASTEXITCODE | Should -Be 0
        (Get-Content $indexOut -Raw) | Should -Match 'indexed'
    }

    It 'EXECUTION DISCOVERY: a fence using the pre-schema envelope grammar (extra unrecognized keys between outcome: and findings:) falls back cleanly instead of corrupting outcome with a continuation line' {
        # Measured against the real store at base: 2 of 24 verdicts
        # (2026-07-22-harness-design-round4-REJECT-ESCALATED.md, round5-REJECT.md) carry
        # a fence from BEFORE the outcome/findings/abstract-only grammar was finalised -
        # extra keys like `section_4_disposition:` sit between `outcome:` and `findings:`.
        # Envelope.psm1's Get-StarcarEnvelope (shared production code, Car 2's live
        # producer path, out of this task's scope to modify) appends any unrecognized-key
        # line to the PREVIOUS field, so `outcome` comes out multi-line - unusable as an
        # index cell and not a valid vocabulary token. Migrate-Verdicts.ps1 must detect
        # this and fall back to the same deterministic path used for fence-less verdicts,
        # never emit a multi-line 'outcome'.
        $repo = New-FixtureRepo
        $fence = "kind: verdict`ngate: design-review`nround: 4`noutcome: REJECT`nsection_4_disposition: NOT CLOSED - ESCALATE TO OWNER`nfindings: some findings`nabstract: some abstract"
        Add-Verdict -Repo $repo -Name 'pre-schema-fence.md' -Content (Get-VerdictBody -Title 'Pre-schema envelope' -Verdict 'REJECT - 5 Major' -Fence $fence)
        & $script:Script -SourceDir (Join-Path $repo 'docs/reviews') -DestDir (Join-Path $repo 'artifacts/reviews')
        $LASTEXITCODE | Should -Be 0

        $rec = Get-Content (Join-Path $repo 'artifacts/reviews/pre-schema-fence.json') -Raw | ConvertFrom-Json -DateKind String
        $rec.outcome | Should -Be 'REJECT'
        $rec.outcome | Should -Not -Match "`n"
        $rec.findings | Should -Be 'migrated: see body_file'
        $rec.abstract | Should -Be 'Pre-schema envelope'
        (Test-StarcarArtifact -InputObject $rec -SchemaPath $script:SchemaPath).Valid | Should -BeTrue
    }

    It 'the anti-trap [C3R1-M2]: Verify-Verdict -ReviewsDir <fixture>/artifacts/reviews (flat, no recursion) verifies every body and exits 0 with index.md present at the fixture STORE ROOT, never globbed' {
        $repo = New-FixtureRepo
        Add-Verdict -Repo $repo -Name 'verify-me.md' -Content (Get-VerdictBody -Title 'Verify me' -Verdict 'APPROVE')
        & $script:Script -SourceDir (Join-Path $repo 'docs/reviews') -DestDir (Join-Path $repo 'artifacts/reviews')
        # a headerless index.md at the STORE ROOT (artifacts/), sibling to reviews/, not inside it -
        # the exact shape the round-1 reviewer proved chokes a -Recurse default.
        Set-Content -Path (Join-Path $repo 'artifacts/index.md') -Value '| subject | kind | at | outcome | file |' -Encoding utf8

        $verifier = Join-Path $script:RepoRoot 'scripts/Verify-Verdict.ps1'
        $out = & pwsh -NoProfile -File $verifier -ReviewsDir (Join-Path $repo 'artifacts/reviews') 2>&1
        $exitCode = $LASTEXITCODE
        $exitCode | Should -Be 0
        ($out -join "`n") | Should -Not -Match 'index\.md'
    }
}
