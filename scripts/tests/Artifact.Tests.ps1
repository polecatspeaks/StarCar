#requires -Version 7.4
BeforeDiscovery {
    $repoRoot = (git rev-parse --show-toplevel)
    $vectorCases = Get-ChildItem (Join-Path $repoRoot 'schema/vectors') -Filter *.json |
        ForEach-Object {
            @{ Name   = $_.Name
               Path   = $_.FullName
               Expect = (Get-Content ([System.IO.Path]::ChangeExtension($_.FullName, '.expect')) -Raw).Trim() }
        }
}

Describe 'Test-StarcarArtifact conformance' {
    BeforeAll {
        $repoRoot = (git rev-parse --show-toplevel)
        Import-Module (Join-Path $repoRoot 'scripts/Artifact.psm1') -Force
        $script:SchemaPath = Join-Path $repoRoot 'schema/starcar-artifact.schema.json'
        $script:RepoRoot = $repoRoot
    }

    It 'vector <Name> validates as <Expect>' -ForEach $vectorCases {
        $obj = Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json
        $r = Test-StarcarArtifact -InputObject $obj -SchemaPath $script:SchemaPath
        $r.Valid | Should -Be ($Expect -eq 'valid')
    }

    It 'an unrecognised kind is a DISCOVERY by name, never invalid' {
        $obj = [pscustomobject]@{ schema='starcar-artifact/1'; kind='migrated';
            subject='x'; session_id='s'; at='2026-07-22T00:00:00Z';
            normalisation=@(); integrity='sha256:0000000000000000000000000000000000000000000000000000000000000000' }
        $r = Test-StarcarArtifact -InputObject $obj -SchemaPath $script:SchemaPath
        $r.Valid | Should -BeTrue
        $r.Discoveries | Should -Contain 'kind: migrated'
    }

    It 'an unreadable vocabulary file is ONE error, not N' {
        $r = Test-StarcarArtifact -InputObject ([pscustomobject]@{}) `
            -SchemaPath $script:SchemaPath -VocabDir (Join-Path $script:RepoRoot 'no-such-dir')
        ($r.Errors | Where-Object { $_ -match 'vocab' }).Count | Should -Be 1
    }
}

Describe 'Get-AtInstant (F1 - offset-aware chronological instant)' {
    <#
      docs/plans/2026-07-22-pr18-correctness-fixes-plan.md F1: Test-Json does not assert
      the date-time format (a malformed or zoneless 'at' is schema-VALID), so this helper
      must fail LOUD on both: throw a NAMED error on a parse failure, and explicitly
      REJECT a zoneless 'at' rather than parse it TZ-dependently (which would silently
      break New-ArtifactIndex.ps1's determinism guarantee).
    #>
    BeforeAll {
        $repoRoot = (git rev-parse --show-toplevel)
        Import-Module (Join-Path $repoRoot 'scripts/Artifact.psm1') -Force
    }

    It 'parses a Z-suffixed at to its UTC instant' {
        # Compared via UTC-kind components, not raw DateTime equality: `[datetime]` cast
        # in PowerShell yields a Local-kind value on this host, and DateTime.Equals
        # compares raw ticks without TZ conversion -- two Kind-mismatched values holding
        # the SAME instant are unequal by ticks alone.
        $result = Get-AtInstant '2026-07-22T16:39:57Z'
        $result.Kind | Should -Be ([System.DateTimeKind]::Utc)
        $result.ToString('yyyy-MM-ddTHH:mm:ss') | Should -Be '2026-07-22T16:39:57'
    }

    It 'parses an offset-suffixed at to the SAME UTC instant as its Z equivalent' {
        (Get-AtInstant '2026-07-22T14:18:03-04:00') | Should -Be (Get-AtInstant '2026-07-22T18:18:03Z')
    }

    It 'throws a NAMED error on a zoneless at (no Z/offset)' {
        { Get-AtInstant '2026-07-22T16:39:57' } | Should -Throw '*2026-07-22T16:39:57*'
    }

    It 'throws a NAMED error on an unparseable at' {
        { Get-AtInstant 'not-a-date' } | Should -Throw '*not-a-date*'
    }
}
