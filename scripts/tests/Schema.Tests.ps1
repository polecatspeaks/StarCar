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
        $s.properties.outcome.type | Should -Be 'string'
        $s.properties.outcome.PSObject.Properties.Name | Should -Not -Contain 'enum'
    }

    It 'both vocabulary files exist and parse' {
        $kindsPath = Join-Path $script:Vocab 'kinds.json'
        $outcomesPath = Join-Path $script:Vocab 'outcomes.json'
        Test-Path $kindsPath | Should -BeTrue
        Test-Path $outcomesPath | Should -BeTrue
        { Get-Content $kindsPath -Raw -Encoding UTF8 | ConvertFrom-Json } | Should -Not -Throw
        { Get-Content $outcomesPath -Raw -Encoding UTF8 | ConvertFrom-Json } | Should -Not -Throw
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

    # #38: every property declared in the schema must be either listed in index-format.md's
    # canonical field order OR explicitly named (backtick-quoted) in the unordered-extras
    # disclosure sentence that follows the canonical code block.
    #
    # Parsing assumptions (documented so a future editor knows the contract):
    #   1. Canonical fields come from the first fenced code block under "## Canonical field order"
    #      in schema/index-format.md; the block contains a comma-separated list of field names
    #      (whitespace and newlines are ignored).
    #   2. Unordered extras are any backtick-quoted snake_case identifiers that appear in the
    #      text between that code block's closing fence and the next "## " heading.  Field names
    #      that happen to be backtick-quoted elsewhere in that gap (e.g. `kind` in the
    #      "A field absent..." sentence) satisfy the canonical-list membership check on their
    #      own, so false positives in the extras set are harmless.
    It 'every schema property appears in index-format.md canonical order or unordered-extras disclosure (#38)' {
        $indexPath    = Join-Path $script:Root 'schema/index-format.md'
        $schemaJson   = Get-Content $script:Schema -Raw -Encoding UTF8 | ConvertFrom-Json
        $schemaProps  = [string[]]($schemaJson.properties.PSObject.Properties.Name)

        $indexContent = Get-Content $indexPath -Raw -Encoding UTF8

        # Split the document on "## " section headings; find the Canonical field order section.
        # Use Select-Object -First 1 rather than [0] to avoid the PowerShell gotcha where
        # [0] on a single string returns the first CHARACTER, not the first array element.
        $sections = $indexContent -split '(?m)^## '
        $canonicalSection = $sections | Where-Object { $_ -match '^`?Canonical field order' } | Select-Object -First 1
        if (-not $canonicalSection) { throw 'Could not locate ## Canonical field order section in schema/index-format.md' }

        # Extract the code block content (first ``` ... ``` in that section).
        $codeMatch = [regex]::Match($canonicalSection, '```\r?\n([\s\S]*?)\r?\n```')
        if (-not $codeMatch.Success) { throw 'Could not locate fenced code block in the Canonical field order section' }
        $canonicalText   = $codeMatch.Groups[1].Value
        $canonicalFields = ($canonicalText -split '[,\r\n]+') |
                           ForEach-Object { $_.Trim() } |
                           Where-Object   { $_ -ne '' }

        # Extract unordered-extras names from text after the code block in the same section.
        $afterBlock  = $canonicalSection.Substring($codeMatch.Index + $codeMatch.Length)
        $extraFields = [regex]::Matches($afterBlock, '`([a-z][a-z0-9_]*)`') |
                       ForEach-Object { $_.Groups[1].Value } |
                       Select-Object -Unique

        $accountedFor = @($canonicalFields) + @($extraFields)
        $unaccounted  = $schemaProps | Where-Object { $_ -notin $accountedFor }

        $unaccounted | Should -BeNullOrEmpty -Because (
            "every schema property must appear in the canonical field order OR the " +
            "unordered-extras disclosure in schema/index-format.md; unaccounted: $($unaccounted -join ', ')"
        )
    }
}
