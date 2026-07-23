# SubstrateFloor.Probes.ps1 -- the substrate-floor probe suite: this shop's "check the
# SDK headers first", for a shop that has no SDK headers.
#
# WHY THIS EXISTS (doctrine: "NO HEADERS HERE", CLAUDE.md): our substrate is the observed
# behaviour of shells, test frameworks, and tools nobody maintains FOR us. Each probe
# below pins a substrate fact some landed document CONSUMES - so when the substrate moves
# (a shell upgrade, a Pester upgrade), the probe goes red and names exactly which landed
# claim just went stale, instead of the claim failing silently downstream.
#
# A probe file is a HEADER WE CONSTRUCTED. Each It names its CONSUMER - the document or
# contract that becomes suspect if the probe reds.
#
# INVOCATION (deliberately NOT under scripts/tests/ - car briefs pin that suite's counts,
# and probes assert the environment, not the product):
#   pwsh -NoProfile -Command "Invoke-Pester -Path ./scripts/probes"
#
# NON-VACUITY, proven at birth: run under Windows PowerShell 5.1 this suite REDS (floor
# version + Test-Json probes fail) - observed 2026-07-22, which is the suite catching a
# real sub-floor environment, not a formality.
#
# TRIGGER to re-run: any shell/Pester/tooling upgrade, any new machine or CI image, and
# whenever a landed document's behavioural citation is doubted.

Describe 'Substrate floor - runtime' {

    It 'runs on PowerShell 7.4 or later (CONSUMER: plan runtime floor, R1v2)' {
        $PSVersionTable.PSVersion | Should -BeGreaterOrEqual ([version]'7.4')
    }

    It 'Test-Json exists (CONSUMER: R1v2 - the named validation engine; its absence reopens a closed menu)' {
        Get-Command Test-Json -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
    }

    It 'Test-Json honours draft-2020-12 if/then conditional requirements (CONSUMER: A.1 schema conditionals)' {
        $schema = @'
{"type":"object","required":["kind"],"properties":{"kind":{"type":"string"}},
 "if":{"properties":{"kind":{"const":"returned"}}},"then":{"required":["outcome"]}}
'@
        Test-Json -Json '{"kind":"returned","outcome":"APPROVE"}' -Schema $schema -ErrorAction SilentlyContinue | Should -BeTrue
        Test-Json -Json '{"kind":"returned"}' -Schema $schema -ErrorAction SilentlyContinue | Should -BeFalse
    }

    It 'git resolves the repo root from a script context (CONSUMER: every test BeforeAll in scripts/tests)' {
        $root = (git rev-parse --show-toplevel)
        $root | Should -Not -BeNullOrEmpty
        Test-Path (Join-Path $root 'CLAUDE.md') | Should -BeTrue
    }
}

Describe 'Substrate floor - Pester' {

    It 'Pester is 5.5 or later (CONSUMER: BeforeDiscovery/-ForEach table expansion in A.2 conformance tests)' {
        (Get-Module Pester).Version | Should -BeGreaterOrEqual ([version]'5.5')
    }

    It 'Should -BeGreaterOrEqual compares [version] objects correctly (CONSUMER: this very suite)' {
        [version]'7.6' | Should -BeGreaterOrEqual ([version]'7.4')
    }
}

Describe 'Substrate floor - text fidelity' {

    It 'WriteAllText with UTF8Encoding($false) writes no BOM (CONSUMER: Land-Verdict hash-over-bytes contract)' {
        $p = Join-Path $TestDrive 'bom-probe.txt'
        [System.IO.File]::WriteAllText($p, 'x', [System.Text.UTF8Encoding]::new($false))
        $bytes = [System.IO.File]::ReadAllBytes($p)
        $bytes.Length | Should -Be 1
        $bytes[0] | Should -Be 120
    }

    It 'an empty Get-ChildItem pipeline yields $null, not @() - the StrictMode trap (CONSUMER: spec amendment S1, A.3)' {
        $r = Get-ChildItem $TestDrive -Filter 'no-such-*.xyz' | ForEach-Object { $_.Name }
        $null -eq $r | Should -BeTrue
    }
}
