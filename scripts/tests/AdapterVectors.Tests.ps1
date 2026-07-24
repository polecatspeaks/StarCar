#requires -Version 7.4
# AdapterVectors.Tests.ps1 (#47 D3) -- the runner for the family-agnostic ADAPTER
# conformance vectors in schema/vectors/adapter/. Sibling contract to the fold vectors
# (schema/vectors/README.md): declarative payload -> expected record (or visible skip),
# OBSERVED vs DESIGN-MANDATED provenance stated per fixture.
#
# Runner contract (mirrors schema/vectors/adapter/README.md):
#   1. Materialise input.transcript (if present) into a temp .jsonl and substitute the
#      "<transcript>" placeholder in whichever payload key holds it (agent_transcript_path
#      for Claude, transcript_path for Copilot).
#   2. Feed input.payload on stdin to scripts/Produce-Artifact.ps1 with -Kind = vector.kind,
#      against a throwaway git repo/store, invoked as a REAL child pwsh process (so the
#      visible-skip stderr line is captured exactly as the hook would see it).
#   3a. expected.record: exactly one record was written; each named field deep-equals.
#   3b. expected.skip: NO record was written AND stderr names each key in stderr_contains.
#
# The DR-11 stateful refusal guard is NOT a case here: it depends on pre-existing store
# state, which these stateless payload->record vectors do not carry. Its red-first proof
# lives in scripts/tests/Producer.Tests.ps1 (adapter README + design section 9c amendment).

Describe 'Adapter conformance vectors (#47 D3)' {
    BeforeAll {
        $script:RepoRoot   = (git rev-parse --show-toplevel)
        $script:Script     = Join-Path $script:RepoRoot 'scripts/Produce-Artifact.ps1'
        $script:VectorsDir = Join-Path $script:RepoRoot 'schema/vectors/adapter'

        function New-FixtureRepo {
            $repo = Join-Path ([System.IO.Path]::GetTempPath()) ("adaptervec-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $repo -Force | Out-Null
            git -C $repo init -q | Out-Null
            git -C $repo config user.email 'test@starcar.local' | Out-Null
            git -C $repo config user.name  'Adapter Vector Test' | Out-Null
            Set-Content -Path (Join-Path $repo 'README') -Value 'seed' -Encoding utf8
            git -C $repo add README | Out-Null
            git -C $repo commit -q -m 'seed' | Out-Null
            $repo
        }

        # Walk a payload object and replace the string "<transcript>" wherever it appears
        # in a top-level value with the real temp path (returns the mutated object).
        function Set-TranscriptPath {
            param([object]$Payload, [string]$Path)
            foreach ($p in $Payload.PSObject.Properties) {
                if ($p.Value -is [string] -and $p.Value -eq '<transcript>') { $p.Value = $Path }
            }
            $Payload
        }

        function Invoke-ProducerChild {
            param([string]$PayloadJson, [string]$Kind, [string]$StoreRoot, [string]$Now)
            $combined = $PayloadJson | & pwsh -NoProfile -File $script:Script -Kind $Kind -StoreRoot $StoreRoot -Now $Now 2>&1
            [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = (($combined | ForEach-Object { [string]$_ }) -join "`n") }
        }
    }

    $script:Cases = Get-ChildItem -Path (Join-Path (git rev-parse --show-toplevel) 'schema/vectors/adapter') -Filter *.json -File |
        ForEach-Object { @{ File = $_.FullName; Name = $_.BaseName } }

    It "conforms: <Name>" -ForEach $script:Cases {
            $vec = Get-Content $File -Raw | ConvertFrom-Json
            $repo  = New-FixtureRepo
            $store = Join-Path $repo 'artifacts'

            $payload = $vec.input.payload
            if ($vec.input.PSObject.Properties['transcript']) {
                $tpath = Join-Path $repo 'transcript.jsonl'
                Set-Content -Path $tpath -Value ($vec.input.transcript -join "`n") -Encoding utf8
                $payload = Set-TranscriptPath -Payload $payload -Path ($tpath -replace '\\', '/')
            }
            $json = $payload | ConvertTo-Json -Depth 30
            $now  = '2026-07-24T12:00:00Z'

            $r = Invoke-ProducerChild -PayloadJson $json -Kind $vec.kind -StoreRoot $store -Now $now

            $records = @(Get-ChildItem -Path $store -Recurse -Filter *.json -ErrorAction SilentlyContinue)

            if ($vec.expected.PSObject.Properties['skip']) {
                $records.Count | Should -Be 0 -Because "vector $($vec.name) expects a visible skip, no record"
                foreach ($key in $vec.expected.skip.stderr_contains) {
                    $r.Output | Should -Match ([regex]::Escape($key)) -Because "the visible skip must name present key '$key'"
                }
            } else {
                $records.Count | Should -Be 1 -Because "vector $($vec.name) expects exactly one record"
                $rec = Get-Content $records[0].FullName -Raw | ConvertFrom-Json
                foreach ($p in $vec.expected.record.PSObject.Properties) {
                    $actual = if ($rec.PSObject.Properties[$p.Name]) { $rec.$($p.Name) } else { $null }
                    $actual | Should -Be $p.Value -Because "record field '$($p.Name)' must match the vector"
                }
            }
    }
}
