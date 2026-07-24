# #47 (design D5): the ONE transcript-read home. These tests pin the two guarantees the
# design names for the extractor: (1) it NEVER throws on file state - an absent/unreadable
# file is reported via Ok/Error, not an exception (each caller keeps its own missing-file
# policy: the producer degrades, Land-Verdict throws its own message); (2) torn-line
# discipline - a jsonl read mid-write can end in a torn line, and Read-JsonlObjects SKIPS an
# unparseable line rather than throwing (DR-7, D3 runner contract).

BeforeAll {
    . (Join-Path $PSScriptRoot '../lib/TranscriptRead.ps1')
}

Describe 'Read-TranscriptLines (#47 D5, the one UTF8 line reader)' {
    It 'returns Ok with the UTF8 lines for a present file' {
        $p = Join-Path $TestDrive 't1.jsonl'
        Set-Content -LiteralPath $p -Value @('{"a":1}', '{"b":2}') -Encoding UTF8
        $r = Read-TranscriptLines -Path $p
        $r.Ok | Should -BeTrue
        @($r.Lines).Count | Should -Be 2
        $r.Error | Should -BeNullOrEmpty
    }

    It 'reports an absent file via Ok=$false and NEVER throws' {
        $p = Join-Path $TestDrive 'does-not-exist.jsonl'
        { Read-TranscriptLines -Path $p } | Should -Not -Throw
        $r = Read-TranscriptLines -Path $p
        $r.Ok | Should -BeFalse
        $r.Error | Should -Match 'not found'
        @($r.Lines).Count | Should -Be 0
    }

    It 'reports an empty/whitespace path via Ok=$false and NEVER throws' {
        { Read-TranscriptLines -Path '' } | Should -Not -Throw
        (Read-TranscriptLines -Path '').Ok | Should -BeFalse
    }
}

Describe 'Read-JsonlObjects (#47 D5, torn-line discipline)' {
    It 'parses every well-formed line into an object' {
        $p = Join-Path $TestDrive 'objs.jsonl'
        Set-Content -LiteralPath $p -Value @('{"a":1}', '{"a":2}', '{"a":3}') -Encoding UTF8
        $r = Read-JsonlObjects -Path $p
        $r.Ok | Should -BeTrue
        @($r.Objects).Count | Should -Be 3
        $r.Objects[2].a | Should -Be 3
    }

    It 'SKIPS a torn/unparseable trailing line and NEVER throws' {
        $p = Join-Path $TestDrive 'torn.jsonl'
        # two good lines then a torn final line (a mid-write transcript)
        Set-Content -LiteralPath $p -Value @('{"a":1}', '{"a":2}', '{"a":') -Encoding UTF8
        { Read-JsonlObjects -Path $p } | Should -Not -Throw
        $r = Read-JsonlObjects -Path $p
        $r.Ok | Should -BeTrue
        @($r.Objects).Count | Should -Be 2
    }

    It 'reports an absent file via Ok=$false with an empty object set, NEVER throws' {
        $p = Join-Path $TestDrive 'nope.jsonl'
        { Read-JsonlObjects -Path $p } | Should -Not -Throw
        $r = Read-JsonlObjects -Path $p
        $r.Ok | Should -BeFalse
        @($r.Objects).Count | Should -Be 0
    }
}
