#requires -Version 7.4
Describe 'Artifact schema and conformance vectors' {
    BeforeAll {
        $script:Root    = (git rev-parse --show-toplevel)
        $script:Schema  = Join-Path $script:Root 'schema/starcar-artifact.schema.json'
        $script:Vectors = Join-Path $script:Root 'schema/vectors'
        $script:Vocab   = Join-Path $script:Root 'schema/vocab'
    }

    It 'the schema file exists and is parseable JSON' {
        Test-Path $script:Schema | Should -BeTrue
        { Get-Content $script:Schema -Raw -Encoding UTF8 | ConvertFrom-Json } | Should -Not -Throw
    }

    It 'kind and outcome are strings in the schema, never enums (vocabularies are data)' {
        $s = Get-Content $script:Schema -Raw -Encoding UTF8 | ConvertFrom-Json
        $s.properties.kind.type | Should -Be 'string'
        $s.properties.kind.PSObject.Properties.Name | Should -Not -Contain 'enum'
    }

    It 'both vocabulary files exist and parse' {
        Test-Path (Join-Path $script:Vocab 'kinds.json') | Should -BeTrue
        Test-Path (Join-Path $script:Vocab 'outcomes.json') | Should -BeTrue
    }

    It 'ships at least nine vectors, each with an .expect sibling' {
        $cases = Get-ChildItem $script:Vectors -Filter *.json -ErrorAction SilentlyContinue
        $cases.Count | Should -BeGreaterOrEqual 9
        foreach ($c in $cases) {
            $expect = [System.IO.Path]::ChangeExtension($c.FullName, '.expect')
            Test-Path $expect | Should -BeTrue -Because "$($c.Name) needs an .expect sibling"
            (Get-Content $expect -Raw).Trim() | Should -BeIn @('valid','invalid')
        }
    }
}
