#requires -Version 7.4
Describe 'New-ArtifactIndex - one row per artifact, deterministic' {
    BeforeAll {
        $script:Root = (git rev-parse --show-toplevel)
        $script:Gen  = Join-Path $script:Root 'scripts/New-ArtifactIndex.ps1'
        $script:Store = Join-Path $TestDrive 'store'
        New-Item -ItemType Directory -Path $script:Store | Out-Null
        # Fixture: three artifacts, two subjects, one superseded pair (same subject,
        # two 'at' values) - written here from A.1's vector shapes.
        $dispatched = Get-Content (Join-Path $script:Root 'schema/vectors/valid-dispatched.json') -Raw -Encoding UTF8
        $returned   = Get-Content (Join-Path $script:Root 'schema/vectors/valid-returned.json') -Raw -Encoding UTF8
        $presumed   = Get-Content (Join-Path $script:Root 'schema/vectors/valid-presumed-lost.json') -Raw -Encoding UTF8
        # dispatched and returned share subject 'disp-1' at A.1's vector 'at' values -
        # dispatched at 10:00:00Z, returned (the superseding record) at 10:05:00Z.
        [System.IO.File]::WriteAllText((Join-Path $script:Store 'disp-1-dispatched.json'), $dispatched)
        [System.IO.File]::WriteAllText((Join-Path $script:Store 'disp-1-returned.json'), $returned)
        [System.IO.File]::WriteAllText((Join-Path $script:Store 'disp-2-presumed-lost.json'), $presumed)
    }

    It 'produces one row per artifact, sorted per schema/index-format.md' {
        $out = Join-Path $TestDrive 'index.md'
        & pwsh -NoProfile -File $script:Gen -StoreRoot $script:Store -OutFile $out
        $rows = @(Get-Content $out | Where-Object { $_ -match '^\|' } | Select-Object -Skip 2)
        $rows.Count | Should -Be 3
    }

    It 'two runs over the same store produce byte-identical output' {
        $a = Join-Path $TestDrive 'a.md'; $b = Join-Path $TestDrive 'b.md'
        & pwsh -NoProfile -File $script:Gen -StoreRoot $script:Store -OutFile $a
        & pwsh -NoProfile -File $script:Gen -StoreRoot $script:Store -OutFile $b
        (Get-FileHash $a -Algorithm SHA256).Hash | Should -Be (Get-FileHash $b -Algorithm SHA256).Hash
    }
}

Describe 'New-ArtifactIndex - the at column, year-spanning (M-A4-1)' {
    <#
      Reviewer finding M-A4-1: ConvertFrom-Json coerces the ISO-8601 'at' string into a
      [System.DateTime], the generator then casts it to the invariant MM/dd/yyyy form,
      and a lexical sort of THAT string is non-chronological across years (a 2099
      artifact sorts before a 2026 one). The plan's original fixture used three
      same-day timestamps, which cannot expose either fault -- MM/dd/yyyy and
      yyyy-MM-dd sort identically within one day. This fixture spans years and months
      specifically so both faults are reachable.
    #>
    BeforeAll {
        $script:Root  = (git rev-parse --show-toplevel)
        $script:Gen   = Join-Path $script:Root 'scripts/New-ArtifactIndex.ps1'
        $script:Store = Join-Path $TestDrive 'year-store'
        New-Item -ItemType Directory -Path $script:Store | Out-Null

        # Same-year, different-month pair (2026-01 and 2026-07), plus a 2099 artifact.
        # The 2026-07 'at' value is the literal string from schema/index-format.md's
        # worked example, so a passing verbatim-string assertion is not a coincidence.
        $yearJan2026 = @{
            schema = 'starcar-artifact/1'; kind = 'dispatched'; subject = 'year-jan-2026'
            session_id = 's'; at = '2026-01-15T00:00:00Z'
            normalisation = @(); integrity = 'sha256:0000000000000000000000000000000000000000000000000000000000000000'
        } | ConvertTo-Json
        $yearJul2026 = @{
            schema = 'starcar-artifact/1'; kind = 'dispatched'; subject = 'year-jul-2026'
            session_id = 's'; at = '2026-07-22T10:00:00Z'
            normalisation = @(); integrity = 'sha256:0000000000000000000000000000000000000000000000000000000000000000'
        } | ConvertTo-Json
        $year2099 = @{
            schema = 'starcar-artifact/1'; kind = 'dispatched'; subject = 'year-2099'
            session_id = 's'; at = '2099-01-01T00:00:00Z'
            normalisation = @(); integrity = 'sha256:0000000000000000000000000000000000000000000000000000000000000000'
        } | ConvertTo-Json

        [System.IO.File]::WriteAllText((Join-Path $script:Store 'year-jan-2026.json'), $yearJan2026)
        [System.IO.File]::WriteAllText((Join-Path $script:Store 'year-jul-2026.json'), $yearJul2026)
        [System.IO.File]::WriteAllText((Join-Path $script:Store 'year-2099.json'), $year2099)
    }

    It 'the at column is the artifact''s verbatim ISO-8601 string, never reformatted' {
        $out = Join-Path $TestDrive 'year-index.md'
        & pwsh -NoProfile -File $script:Gen -StoreRoot $script:Store -OutFile $out
        $text = Get-Content $out -Raw
        # Literal match against index-format.md's worked-example form -- a reformatted
        # (e.g. MM/dd/yyyy HH:mm:ss, UTC marker dropped) value cannot match this.
        $text | Should -Match ([regex]::Escape('2026-07-22T10:00:00Z'))
    }

    It 'rows are sorted chronologically by at, not lexically by a reformatted string' {
        $out = Join-Path $TestDrive 'year-index-2.md'
        & pwsh -NoProfile -File $script:Gen -StoreRoot $script:Store -OutFile $out
        $rows = @(Get-Content $out | Where-Object { $_ -match '^\|' } | Select-Object -Skip 2)
        $rows.Count | Should -Be 3
        $subjectOrder = $rows | ForEach-Object { ($_ -split '\|')[1].Trim() }
        # Chronological: 2026-01 before 2026-07 before 2099-01. A lexical sort of the
        # MM/dd/yyyy form the reviewer reproduced would put 2099 (01/01/2099) before
        # 2026 (01/15/2026 < 07/22/2026), which is the exact defect this pins.
        $subjectOrder | Should -Be @('year-jan-2026', 'year-jul-2026', 'year-2099')
    }
}
