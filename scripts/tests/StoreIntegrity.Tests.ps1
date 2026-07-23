#requires -Version 7.4
# StoreIntegrity.Tests.ps1 -- CI validates every artifacts/**/*.json record: schema-valid
# via Test-StarcarArtifact AND its integrity hash recomputes (Get-Sha256Hex,
# scripts/Artifact.psm1 -- the shared canonicalisation, Law 6) to match the stored value
# (docs/plans/2026-07-22-pr18-correctness-fixes-plan.md F4). Neither the index-staleness
# CI step (regenerates the index only) nor Verify-Verdict.ps1 (checks only .md review
# bodies) validates a record's own JSON structure or integrity today.
#
# NO SPLIT (round-1 plan-review ruling): the adversary empirically recomputed every store
# record -- migrated reviews AND producer-written alike -- under the producer's
# canonicalisation, and ALL matched (the migration used that same canonicalisation, so
# there is no placeholder class and no gap this test needs to special-case). This asserts
# the WHOLE store, uniformly.
#
# Runs in the existing CI Pester step (scripts/tests/**/*.Tests.ps1 glob already covers
# this file) -- no ci.yml change needed.

BeforeDiscovery {
    $repoRoot = (git rev-parse --show-toplevel)
    $storeCases = Get-ChildItem -Path (Join-Path $repoRoot 'artifacts') -Filter *.json -Recurse -File |
        ForEach-Object { @{ Name = [System.IO.Path]::GetRelativePath($repoRoot, $_.FullName); Path = $_.FullName } }
}

Describe 'Store integrity - every artifacts/**/*.json record (F4)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:SchemaPath = Join-Path $script:RepoRoot 'schema/starcar-artifact.schema.json'
        Import-Module (Join-Path $script:RepoRoot 'scripts/Artifact.psm1') -Force

        # ONE check, reused for every real-store record below AND for the fault-injection
        # proof -- so the proof exercises the exact logic the real-store assertions rely
        # on, never a look-alike copy.
        function Test-RecordIntegrity {
            param([string]$Path)
            # -DateKind String is LOAD-BEARING (M-A4-1's third recurrence, caught by CI's
            # different TZ 2026-07-22): without it ConvertFrom-Json coerces an offset-form
            # `at` (the migrated records carry -04:00) into a local [datetime], and
            # re-serialising it emits the RECOMPUTING machine's offset - so the hash matches
            # only on the write-TZ box and fails on any other. Verifiers must read `at`
            # VERBATIM. Producer records are Z-only and round-trip regardless, but the
            # contract must hold for every record.
            $rec = Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json -DateKind String
            $schemaResult = Test-StarcarArtifact -InputObject $rec -SchemaPath $script:SchemaPath

            $integrityOk = $false
            $integrityProp = $rec.PSObject.Properties['integrity']
            if ($integrityProp) {
                # Re-derive independently: every field in file order EXCEPT integrity,
                # compact JSON -- the producer's own canonicalisation
                # (Produce-Artifact.ps1's `$bodyJson` construction).
                $copy = [ordered]@{}
                foreach ($p in $rec.PSObject.Properties) {
                    if ($p.Name -ne 'integrity') { $copy[$p.Name] = $p.Value }
                }
                $body = $copy | ConvertTo-Json -Depth 20 -Compress
                $recomputed = 'sha256:' + (Get-Sha256Hex $body)
                $integrityOk = ($recomputed -eq $integrityProp.Value)
            }

            [pscustomobject]@{
                SchemaValid = [bool]$schemaResult.Valid
                Errors      = @($schemaResult.Errors)
                IntegrityOk = $integrityOk
            }
        }
    }

    It 'validates against the schema AND its integrity recomputes to match the stored hash: <Name>' -ForEach $storeCases {
        $r = Test-RecordIntegrity -Path $Path
        $r.SchemaValid | Should -BeTrue -Because "$Name must be schema-valid (errors: $($r.Errors -join '; '))"
        $r.IntegrityOk | Should -BeTrue -Because "$Name's stored integrity must match its recomputed hash"
    }

    It 'FAULT INJECTION (non-vacuity proof): a corrupted integrity hash is caught, the real record is untouched' {
        # Regression-vault shape: this whole-store check passes on arrival (every real
        # record already matches), which proves nothing about whether the check is real.
        # Fault-inject ONCE into a throwaway TestDrive copy of one real record, confirm
        # the corrupted copy is CAUGHT, and confirm the real file on disk was never
        # touched (no revert needed -- the corruption never left TestDrive).
        $anyRecord = (Get-ChildItem -Path (Join-Path $script:RepoRoot 'artifacts') -Filter *.json -Recurse -File | Select-Object -First 1)
        $originalBytes = Get-Content $anyRecord.FullName -Raw -Encoding UTF8

        $fixturePath = Join-Path $TestDrive 'corrupted.json'
        $rec = $originalBytes | ConvertFrom-Json
        $rec.integrity = 'sha256:' + ('0' * 64)
        ($rec | ConvertTo-Json -Depth 20) | Set-Content -Path $fixturePath -Encoding utf8

        $corrupted = Test-RecordIntegrity -Path $fixturePath
        $corrupted.IntegrityOk | Should -BeFalse -Because 'a corrupted integrity hash must be CAUGHT, proving the check is not vacuous'

        # The real file is untouched -- the fixture copy was mutated, never the store.
        (Get-Content $anyRecord.FullName -Raw -Encoding UTF8) | Should -Be $originalBytes
        (Test-RecordIntegrity -Path $anyRecord.FullName).IntegrityOk | Should -BeTrue -Because 'the real record was never touched by the fault injection'
    }

    It 'reads offset-form at as a VERBATIM string, never a coerced datetime (TZ-independent M-A4-1 guard)' {
        # The durable mechanism behind the CI-timezone catch (2026-07-22, hotfix 6c5165d8b's
        # post-hoc review recommendation): the recompute path must parse with -DateKind String
        # so an offset-bearing at-stamp stays the exact stored string. This guard reds on ANY
        # box (including the author's -04:00) the instant -DateKind String is dropped, because
        # the TYPE coercion (string to datetime) happens regardless of timezone - only the
        # re-serialisation is TZ-dependent. Converts the environmental CI guard into a
        # committed test (Healing Loop: mechanism over attention).
        $offsetRecords = @(Get-ChildItem (Join-Path $script:RepoRoot 'artifacts') -Recurse -Filter *.json |
            Where-Object { (Get-Content $_.FullName -Raw) -match '"at"\s*:\s*"[^"]*[+-]\d\d:\d\d"' })
        $offsetRecords.Count | Should -BeGreaterThan 0 -Because 'the migrated verdicts carry offset at-stamps; this guard needs one'
        foreach ($f in $offsetRecords) {
            $rec = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json -DateKind String
            $rec.at | Should -BeOfType [string] -Because "$($f.Name)'s at must parse as a verbatim string, not a coerced datetime"
        }
    }

}
