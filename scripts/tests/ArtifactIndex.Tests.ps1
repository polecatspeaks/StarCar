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
