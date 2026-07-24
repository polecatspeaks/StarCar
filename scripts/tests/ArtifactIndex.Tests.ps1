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

Describe 'New-ArtifactIndex - offset-aware chronological sort (F1)' {
    <#
      docs/plans/2026-07-22-pr18-correctness-fixes-plan.md F1: the store carries mixed
      offsets (25 migrated verdicts carry a '-04:00' at from git authorship in local
      time, alongside Z-normalized producer output). A lexical sort of 'at' is
      chronological ONLY for same-offset timestamps:
      '2026-07-22T14:18:03-04:00' (== 2026-07-22T18:18:03Z) sorts BEFORE
      '2026-07-22T16:39:57Z' lexically ('14' < '16'), but is LATER in time. This fixture
      pins the fix: chronological order by parsed instant, never lexical string order.
    #>
    BeforeAll {
        $script:Root  = (git rev-parse --show-toplevel)
        $script:Gen   = Join-Path $script:Root 'scripts/New-ArtifactIndex.ps1'
        $script:Store = Join-Path $TestDrive 'offset-store'
        New-Item -ItemType Directory -Path $script:Store | Out-Null

        # subjX at 2026-07-22T14:18:03-04:00 == 2026-07-22T18:18:03Z (chronologically LATER)
        # subjY at 2026-07-22T16:39:57Z                              (chronologically EARLIER)
        $recX = @{
            schema = 'starcar-artifact/1'; kind = 'dispatched'; subject = 'subjX'
            session_id = 's'; at = '2026-07-22T14:18:03-04:00'
            normalisation = @(); integrity = 'sha256:0000000000000000000000000000000000000000000000000000000000000000'
        } | ConvertTo-Json
        $recY = @{
            schema = 'starcar-artifact/1'; kind = 'dispatched'; subject = 'subjY'
            session_id = 's'; at = '2026-07-22T16:39:57Z'
            normalisation = @(); integrity = 'sha256:0000000000000000000000000000000000000000000000000000000000000000'
        } | ConvertTo-Json
        [System.IO.File]::WriteAllText((Join-Path $script:Store 'subjX.json'), $recX)
        [System.IO.File]::WriteAllText((Join-Path $script:Store 'subjY.json'), $recY)
    }

    It 'orders chronologically across mixed offsets: the earlier Z instant sorts first, even though its string sorts lexically after the offset string' {
        $out = Join-Path $TestDrive 'offset-index.md'
        & pwsh -NoProfile -File $script:Gen -StoreRoot $script:Store -OutFile $out
        $rows = @(Get-Content $out | Where-Object { $_ -match '^\|' } | Select-Object -Skip 2)
        $subjectOrder = $rows | ForEach-Object { ($_ -split '\|')[1].Trim() }
        $subjectOrder | Should -Be @('subjY', 'subjX')
    }
}

Describe 'New-ArtifactIndex - cell escaping (F3)' {
    <#
      docs/plans/2026-07-22-pr18-correctness-fixes-plan.md F3: `subject`/`outcome` are
      open-vocabulary schema strings (no `enum`, no character restriction -
      schema/starcar-artifact.schema.json), so a schema-VALID record can carry a `|` or a
      raw newline, which today splits the markdown row (newline) or forges extra columns
      (unescaped `|`) when interpolated raw into the table.
    #>
    BeforeAll {
        $script:Root  = (git rev-parse --show-toplevel)
        $script:Gen   = Join-Path $script:Root 'scripts/New-ArtifactIndex.ps1'
        $script:Store = Join-Path $TestDrive 'escape-store'
        New-Item -ItemType Directory -Path $script:Store | Out-Null

        $rec = @{
            schema = 'starcar-artifact/1'; kind = 'returned'; subject = 'subj|with|pipe'
            session_id = 's'; at = '2026-07-22T10:00:00Z'
            outcome = "line-one`nline-two"; findings = 'f'; abstract = 'a'
            normalisation = @(); integrity = 'sha256:0000000000000000000000000000000000000000000000000000000000000000'
        } | ConvertTo-Json
        [System.IO.File]::WriteAllText((Join-Path $script:Store 'rec.json'), $rec)
    }

    It 'escapes | to \| and a raw newline to a space, keeping one intact five-column row' {
        $out = Join-Path $TestDrive 'escape-index.md'
        & pwsh -NoProfile -File $script:Gen -StoreRoot $script:Store -OutFile $out
        $content = Get-Content $out -Raw
        # #20: the generator now emits the static freshness-contract header block
        # (schema/index-format.md) before the table - see the dedicated header Describe
        # below for the header's own assertion. This fixture's expectation includes it
        # because a byte-identical comparison covers the WHOLE file, header included.
        $header = "# Artifact index`n`nDerived from the store (artifacts/**/*.json) by scripts/New-ArtifactIndex.ps1 - regenerate,`nnever hand-edit; the JSON records are the source of truth. Freshness contract (#20): this`nfile is gated fresh at PR-to-main and push-to-main; on dev it may lag the store by a`ndispatch batch between regenerations.`n`n"
        $expected = $header + "| subject | kind | at | outcome | file |`n|---|---|---|---|---|`n| subj\|with\|pipe | returned | 2026-07-22T10:00:00Z | line-one line-two | rec.json |`n"
        $content | Should -Be $expected
    }
}

Describe 'New-ArtifactIndex - freshness-contract header (#20)' {
    <#
      Owner ruling on #20 (2026-07-23): the committed index is a product surface a
      stranger reads, and it may lag the store on dev between regenerations (the
      staleness gate is scoped to PR-to-main/push-to-main - see ci.yml, #20). Without a
      declared freshness contract, that lag would read as a lying surface (Law 1). The
      header text is STATIC (no timestamp, no generated-at stamp) - schema/index-format.md
      mandates this exact text so the byte-identical determinism test above stays valid;
      a generated-at stamp would make every regeneration produce different bytes.
    #>
    BeforeAll {
        $script:Root  = (git rev-parse --show-toplevel)
        $script:Gen   = Join-Path $script:Root 'scripts/New-ArtifactIndex.ps1'
        $script:Store = Join-Path $TestDrive 'header-store'
        New-Item -ItemType Directory -Path $script:Store | Out-Null
        $rec = @{
            schema = 'starcar-artifact/1'; kind = 'dispatched'; subject = 'header-subj'
            session_id = 's'; at = '2026-07-22T10:00:00Z'
            normalisation = @(); integrity = 'sha256:0000000000000000000000000000000000000000000000000000000000000000'
        } | ConvertTo-Json
        [System.IO.File]::WriteAllText((Join-Path $script:Store 'header-subj.json'), $rec)
    }

    It 'begins with the exact static freshness-contract header block, then a blank line, then the table header' {
        $out = Join-Path $TestDrive 'header-index.md'
        & pwsh -NoProfile -File $script:Gen -StoreRoot $script:Store -OutFile $out
        $content = Get-Content $out -Raw
        $expectedHeader = "# Artifact index`n`nDerived from the store (artifacts/**/*.json) by scripts/New-ArtifactIndex.ps1 - regenerate,`nnever hand-edit; the JSON records are the source of truth. Freshness contract (#20): this`nfile is gated fresh at PR-to-main and push-to-main; on dev it may lag the store by a`ndispatch batch between regenerations.`n`n| subject | kind | at | outcome | file |`n"
        $content.StartsWith($expectedHeader) | Should -BeTrue
    }

    It 'produces byte-identical output across two runs with the header present (determinism holds with the header)' {
        $a = Join-Path $TestDrive 'header-a.md'; $b = Join-Path $TestDrive 'header-b.md'
        & pwsh -NoProfile -File $script:Gen -StoreRoot $script:Store -OutFile $a
        & pwsh -NoProfile -File $script:Gen -StoreRoot $script:Store -OutFile $b
        (Get-FileHash $a -Algorithm SHA256).Hash | Should -Be (Get-FileHash $b -Algorithm SHA256).Hash
    }
}
