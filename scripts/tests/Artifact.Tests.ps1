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
            normalisation=@(); integrity='sha256:0' }
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
