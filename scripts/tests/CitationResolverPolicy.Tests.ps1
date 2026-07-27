# Repo policy: every file:line citation outside artifacts/ resolves to a real
# coordinate (#65).
#
# BINDING: every citation this gate finds - single-line, or line-wrapped across a
# mid-compound hyphen or a directory slash - must (a) resolve to a file that exists
# at HEAD and (b) cite a line within that file's line count. This applies inside the
# elided (".../file.ext:N") and ambiguous (bare-basename, 2+ candidates) buckets too:
# an elided reference resolves by suffix match; an ambiguous one binds as a defect
# when EVERY candidate is out of range.
#
# NOT CAUGHT: an in-range shifted citation (a line number that was true when written
# and now points at different, still-existing content) is not detected by any
# BINDING check here - that class stays review-attention-tier. The content-anchor
# diagnostic (a backtick-quoted token from the citing line found near the cited
# target line) is REPORT-ONLY, never binding; its bind trigger is stated where it
# runs: the tokened-citation population growing past 20, or the first report-only
# miss confirmed NOT to be a defect.
#
# SCOPE: scans tracked files via `git ls-files`, excluding artifacts/** (machine-
# generated records) and this file's own path (self-exclusion - its worked-example
# prose and scratch-repo fixtures necessarily contain coordinate-shaped strings that
# are not real citations). Checked extensions are `$script:CheckedExtensions` below;
# every other extension observed in the corpus must be declared in
# `$script:DeclaredExemptExtensions` with a one-line reason, or the completeness
# test reds by name - that is how to add an exemption. Target files (the cited
# side) resolve against the full tracked-file set, including artifacts/**, since a
# doc may legitimately cite a landed review verdict there.
#
# History, calibration measurements, and the round-by-round record live in the
# landed verdicts: artifacts/reviews/2026-07-26-tooling-65-review-r1-REJECT.md,
# -r2-REJECT.md, -r3-REJECT-ESCALATED.md. The tests below are the authority; this
# header carries no measurement claims.

BeforeAll {
    $script:CheckedExtensions = @('.go', '.js', '.mjs', '.css', '.md', '.json', '.ps1', '.psm1', '.sh', '.yml', '.yaml')
    # Every extension observed in the non-artifacts corpus that is NOT in
    # $CheckedExtensions must be declared here with a one-line reason, or the
    # completeness It below reds BY NAME.
    $script:DeclaredExemptExtensions = [ordered]@{
        '.expect'        = 'schema/vectors fixture files - comment-incapable without mutating the artifact under test'
        '.png'           = 'binary image, no comment syntax'
        '.jsonl'         = 'test-fixture transcript data - same mutation-risk reasoning as .expect'
        '.gitignore'     = 'git configuration data, no citations'
        '.gitattributes' = 'git configuration data, no citations'
        '.sum'           = 'go.sum - auto-generated Go module checksum lockfile'
        '.mod'           = 'go.mod - Go module manifest'
        '.py'            = 'the sole tracked .py file is disclosed preserved wreckage whose own header forbids editing it'
        '.html'          = 'no current citations; revisit (move to $CheckedExtensions) when one appears'
        ''               = 'extensionless files are covered individually by $DeclaredExemptExtensionlessFiles, not by this blanket reason'
    }
    # The '' key above only satisfies the EXTENSION-level completeness check; WHICH
    # extensionless files are allowed is a separate, by-path allowlist (its own It
    # below), so a new extensionless file cannot silently ride LICENSE's reason.
    $script:DeclaredExemptExtensionlessFiles = @('LICENSE')
    $script:ExtRe   = ($script:CheckedExtensions -replace '^\.', '') -join '|'
    $script:CoordRe = "(\.?[A-Za-z0-9_][A-Za-z0-9_./-]*\.(?:$($script:ExtRe))):(\d+)(?:-(\d+))?"
    $script:CommentLeaderRe = '^\s*(//|#)\s?'

    function Get-AllNonArtifactFiles {
        param([Parameter(Mandatory)][string] $RepoRoot)
        $all = git -C $RepoRoot ls-files
        if (-not $all) { return @() }
        return @($all | Where-Object { $_ -notmatch '^artifacts/' })
    }

    function Get-UnaccountedExtensions {
        # Returns extensions observed but not covered. Callers must assert on .Count,
        # never a -joined string: an unaccounted extensionless entry is '', and
        # joining a single '' with anything is still ''.
        param([string[]] $ObservedExtensions, [string[]] $CoveredExtensions)
        return @($ObservedExtensions | Where-Object { $CoveredExtensions -notcontains $_ })
    }

    function Get-DeclaredExemptFiles {
        # Returns every non-artifacts tracked file whose extension is declared exempt,
        # for standing re-verification that none has acquired a real citation.
        param(
            [Parameter(Mandatory)][string] $RepoRoot,
            # Not Mandatory: PowerShell's Mandatory attribute rejects an empty-string
            # element inside a [string[]] argument, and '' is a real value here.
            [string[]]                      $DeclaredExemptExtensions
        )
        $all = @(Get-AllNonArtifactFiles -RepoRoot $RepoRoot)
        return @($all | Where-Object { $DeclaredExemptExtensions -contains [System.IO.Path]::GetExtension($_) })
    }

    function Get-CheckedSourceFiles {
        # Self-exclusion: this file's own worked examples and scratch-repo fixtures
        # necessarily contain coordinate-shaped strings that are not real citations.
        param([Parameter(Mandatory)][string] $RepoRoot)
        $all = git -C $RepoRoot ls-files
        if (-not $all) { return @() }
        return @($all |
            Where-Object { $_ -notmatch '^artifacts/' } |
            Where-Object { $_ -ne 'scripts/tests/CitationResolverPolicy.Tests.ps1' } |
            Where-Object { $script:CheckedExtensions -contains [System.IO.Path]::GetExtension($_) })
    }

    function Get-BasenameMap {
        # TARGET resolution deliberately covers the FULL tracked set, artifacts/
        # included - a doc outside artifacts/ legitimately cites a landed verdict
        # inside it (see header SCOPE note).
        param([Parameter(Mandatory)][string] $RepoRoot)
        $map = @{}
        foreach ($f in (git -C $RepoRoot ls-files)) {
            $bn = [System.IO.Path]::GetFileName($f)
            if (-not $map.ContainsKey($bn)) { $map[$bn] = New-Object System.Collections.Generic.List[string] }
            $map[$bn].Add($f)
        }
        return $map
    }

    function Resolve-ElidedCitationTarget {
        # The ".../file.ext:N" ellipsis form truncates to whatever suffix the author
        # chose, not necessarily a real file's exact basename, so resolution is by
        # SUFFIX match (basename or full relative path) rather than exact equality.
        # Exempts only path precision - existence and range are still checked on
        # whatever it uniquely matches.
        param(
            [Parameter(Mandatory)][string] $RepoRoot,
            [Parameter(Mandatory)]         $Coordinate,
            [Parameter(Mandatory)][string[]] $AllTrackedFiles
        )
        $checkLine = if ($Coordinate.TargetLine2) { $Coordinate.TargetLine2 } else { $Coordinate.TargetLine }
        $suffix = $Coordinate.Target
        $candidates = @($AllTrackedFiles | Where-Object {
            [System.IO.Path]::GetFileName($_).EndsWith($suffix) -or $_.EndsWith($suffix)
        })
        if ($candidates.Count -eq 0) {
            return [pscustomobject]@{ Status = 'dead'; ResolvedPath = $null }
        }
        if ($candidates.Count -gt 1) {
            $anyInRange = $false
            foreach ($cand in $candidates) {
                $candLines = @(Get-Content -Path (Join-Path $RepoRoot $cand) -Encoding UTF8).Count
                if ($checkLine -le $candLines) { $anyInRange = $true; break }
            }
            if (-not $anyInRange) {
                return [pscustomobject]@{ Status = 'out-of-range'; ResolvedPath = ($candidates -join ', ') }
            }
            return [pscustomobject]@{ Status = 'ambiguous'; ResolvedPath = ($candidates -join ', ') }
        }
        $full = Join-Path $RepoRoot $candidates[0]
        $tlines = @(Get-Content -Path $full -Encoding UTF8).Count
        if ($checkLine -gt $tlines) {
            return [pscustomobject]@{ Status = 'out-of-range'; ResolvedPath = $candidates[0] }
        }
        return [pscustomobject]@{ Status = 'ok'; ResolvedPath = $candidates[0] }
    }

    function Strip-CitationCommentLeader {
        param([string] $Line)
        return [regex]::Replace($Line, $script:CommentLeaderRe, '')
    }

    function Test-CitationWrapBoundary {
        # True at a genuine wrap boundary: a word character immediately before a
        # trailing hyphen (a mid-compound wrap, e.g. "dom-" -> "writer.js" - never a
        # spaced prose dash, "word - word"), or a bare trailing slash.
        param([string] $TrimmedLine)
        return ($TrimmedLine -match '[A-Za-z0-9_]-$') -or $TrimmedLine.EndsWith('/')
    }

    function Find-CitationCoordinates {
        # Scans $SourceFiles for file:line coordinates, unwrapping a line onto the
        # next ONLY at a genuine wrap boundary (Test-CitationWrapBoundary). Returns one
        # object per distinct coordinate: CitingFile, StartLine, EndLine, Target,
        # TargetLine, TargetLine2, Elided.
        param(
            [Parameter(Mandatory)][string]   $RepoRoot,
            [Parameter(Mandatory)][string[]] $SourceFiles,
            [int]                             $MaxWindow = 3
        )
        $found = @()
        $seen  = @{}
        foreach ($rel in $SourceFiles) {
            $full = Join-Path $RepoRoot $rel
            if (-not (Test-Path $full -PathType Leaf)) { continue }
            $lines = @(Get-Content -Path $full -Encoding UTF8)
            for ($i = 0; $i -lt $lines.Count; $i++) {
                $isContinuation = ($i -gt 0) -and (Test-CitationWrapBoundary ((Strip-CitationCommentLeader $lines[$i - 1]).TrimEnd()))
                $joined = ''
                for ($w = 0; $w -lt $MaxWindow -and ($i + $w) -lt $lines.Count; $w++) {
                    if ($w -gt 0) {
                        $prevStripped = (Strip-CitationCommentLeader $lines[$i + $w - 1]).TrimEnd()
                        if (-not (Test-CitationWrapBoundary $prevStripped)) { break }
                    }
                    $joined  += (Strip-CitationCommentLeader $lines[$i + $w])
                    $endLine  = $i + $w + 1
                    foreach ($m in [regex]::Matches($joined, $script:CoordRe)) {
                        if ($w -eq 0 -and $isContinuation -and $m.Index -eq 0) { continue }
                        $target = $m.Groups[1].Value
                        $tline  = [int]$m.Groups[2].Value
                        $tline2 = if ($m.Groups[3].Success) { [int]$m.Groups[3].Value } else { $null }
                        $key = "$rel|$($i+1)|$target|$tline|$tline2"
                        if ($seen.ContainsKey($key)) { continue }
                        $isElided = $false
                        $startIdx = $m.Index
                        if ($startIdx -ge 4 -and $joined.Substring($startIdx - 4, 4) -eq '.../') { $isElided = $true }
                        $seen[$key] = $true
                        $found += [pscustomobject]@{
                            CitingFile  = $rel
                            StartLine   = $i + 1
                            EndLine     = $endLine
                            Target      = $target
                            TargetLine  = $tline
                            TargetLine2 = $tline2
                            Elided      = $isElided
                        }
                    }
                }
            }
        }
        return @($found)
    }

    function Get-ContentAnchorTokens {
        # Extracts backtick-quoted identifier tokens from a citing line.
        param([Parameter(Mandatory)][string] $Line)
        $backtickRe = '`([A-Za-z_][A-Za-z0-9_]{2,})`'
        return @([regex]::Matches($Line, $backtickRe) | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    }

    function Test-ContentAnchorWindow {
        # Returns $true if ANY token appears (verbatim) in $WindowText. -CaseSensitive
        # selects the production, case-sensitive match; plain match is case-insensitive
        # and is kept only to reproduce a comparison case, never used in resolution.
        param(
            [Parameter(Mandatory)][string[]] $Tokens,
            [Parameter(Mandatory)][string]   $WindowText,
            [switch]                          $CaseSensitive
        )
        foreach ($tok in $Tokens) {
            if ($CaseSensitive) {
                if ($WindowText -cmatch [regex]::Escape($tok)) { return $true }
            } else {
                if ($WindowText -match [regex]::Escape($tok)) { return $true }
            }
        }
        return $false
    }

    function Test-HistoricalCoordinateMarker {
        param(
            [Parameter(Mandatory)][string] $RepoRoot,
            [Parameter(Mandatory)]         $Coordinate
        )
        $full  = Join-Path $RepoRoot $Coordinate.CitingFile
        $lines = @(Get-Content -Path $full -Encoding UTF8)
        $lo = [Math]::Max(0, $Coordinate.StartLine - 1)
        $hi = [Math]::Min($lines.Count - 1, $Coordinate.EndLine - 1)
        $text = ($lines[$lo..$hi] -join ' ')
        return [bool]($text -match '(?i)historical coordinate')
    }

    function Resolve-CitationTarget {
        # Returns [pscustomobject]@{ Status; ResolvedPath } where Status is one of:
        # 'ok', 'dead', 'out-of-range', 'ambiguous'.
        param(
            [Parameter(Mandatory)][string] $RepoRoot,
            [Parameter(Mandatory)]         $Coordinate,
            [Parameter(Mandatory)]         $BasenameMap
        )
        $checkLine = if ($Coordinate.TargetLine2) { $Coordinate.TargetLine2 } else { $Coordinate.TargetLine }
        if ($Coordinate.Target.Contains('/')) {
            $full = Join-Path $RepoRoot $Coordinate.Target
            if (-not (Test-Path $full -PathType Leaf)) {
                return [pscustomobject]@{ Status = 'dead'; ResolvedPath = $null }
            }
            $tlines = @(Get-Content -Path $full -Encoding UTF8).Count
            if ($checkLine -gt $tlines) {
                return [pscustomobject]@{ Status = 'out-of-range'; ResolvedPath = $Coordinate.Target }
            }
            return [pscustomobject]@{ Status = 'ok'; ResolvedPath = $Coordinate.Target }
        }
        $bn = $Coordinate.Target
        if (-not $BasenameMap.ContainsKey($bn)) {
            return [pscustomobject]@{ Status = 'dead'; ResolvedPath = $null }
        }
        $candidates = $BasenameMap[$bn]
        if ($candidates.Count -gt 1) {
            # A line exceeding EVERY candidate's length is a real defect regardless of
            # which file was meant; only genuinely-plausible ambiguity stays report-only.
            $anyInRange = $false
            foreach ($cand in $candidates) {
                $candFull  = Join-Path $RepoRoot $cand
                $candLines = @(Get-Content -Path $candFull -Encoding UTF8).Count
                if ($checkLine -le $candLines) { $anyInRange = $true; break }
            }
            if (-not $anyInRange) {
                return [pscustomobject]@{ Status = 'out-of-range'; ResolvedPath = ($candidates -join ', ') }
            }
            return [pscustomobject]@{ Status = 'ambiguous'; ResolvedPath = ($candidates -join ', ') }
        }
        $full = Join-Path $RepoRoot $candidates[0]
        $tlines = @(Get-Content -Path $full -Encoding UTF8).Count
        if ($checkLine -gt $tlines) {
            return [pscustomobject]@{ Status = 'out-of-range'; ResolvedPath = $candidates[0] }
        }
        return [pscustomobject]@{ Status = 'ok'; ResolvedPath = $candidates[0] }
    }
}

Describe 'Citation resolver: every file:line coordinate outside artifacts/ resolves (#65)' {

    BeforeAll {
        $script:RepoRoot         = (git rev-parse --show-toplevel)
        $script:SourceFiles      = @(Get-CheckedSourceFiles -RepoRoot $script:RepoRoot)
        $script:AllNonArtifact   = @(Get-AllNonArtifactFiles -RepoRoot $script:RepoRoot)
        $script:AllTrackedFiles  = @(git -C $script:RepoRoot ls-files)
        $script:BasenameMap      = Get-BasenameMap -RepoRoot $script:RepoRoot
        $script:Coordinates      = @(Find-CitationCoordinates -RepoRoot $script:RepoRoot -SourceFiles $script:SourceFiles)

        $script:DeadPath   = @()
        $script:OutOfRange = @()
        $script:Ambiguous  = @()
        $script:Elided     = @()
        $script:Historical = @()
        $script:Ok         = @()

        foreach ($c in $script:Coordinates) {
            if (Test-HistoricalCoordinateMarker -RepoRoot $script:RepoRoot -Coordinate $c) {
                $script:Historical += $c; continue
            }
            # Elided coordinates resolve via the suffix-match resolver, never silently
            # skipped - the ellipsis exempts path precision only, not existence/range.
            if ($c.Elided) {
                $script:Elided += $c
                $r = Resolve-ElidedCitationTarget -RepoRoot $script:RepoRoot -Coordinate $c -AllTrackedFiles $script:AllTrackedFiles
            } else {
                $r = Resolve-CitationTarget -RepoRoot $script:RepoRoot -Coordinate $c -BasenameMap $script:BasenameMap
            }
            switch ($r.Status) {
                'dead'         { $script:DeadPath   += $c }
                'out-of-range' { $script:OutOfRange += $c }
                'ambiguous'    { $script:Ambiguous   += $c }
                'ok'           { $script:Ok          += $c }
            }
        }
    }

    It 'finds coordinates to check (a check that examines nothing is not a pass)' {
        $script:Coordinates.Count | Should -BeGreaterThan 0
    }

    It 'every extension in the non-artifacts corpus, INCLUDING extensionless, is checked or a declared exemption (see CodeCitationPolicy.Tests.ps1:288-308 for the same closed-set pattern)' {
        $observedExtensions = @($script:AllNonArtifact |
            ForEach-Object { [System.IO.Path]::GetExtension($_) } |
            Sort-Object -Unique)
        $covered = @($script:CheckedExtensions) + @($script:DeclaredExemptExtensions.Keys)
        $unaccounted = @(Get-UnaccountedExtensions -ObservedExtensions $observedExtensions -CoveredExtensions $covered)
        # Assert on .Count, never a -joined string: an unaccounted extensionless
        # entry is '', and joining a single '' with anything is still ''.
        $rendered = @($unaccounted | ForEach-Object { if ($_ -eq '') { '(no extension)' } else { $_ } })
        $unaccounted.Count | Should -Be 0 -Because (
            "extension(s) [$($rendered -join ', ')] appeared in the non-artifacts corpus " +
            "with no citation check and no declared exemption - decide: extend " +
            "`$CheckedExtensions or `$DeclaredExemptExtensions, do not leave it silent")
    }

    It 'every declared-exempt extension is re-verified, standing, to still carry zero coordinate-shaped matches' {
        $exemptFiles = @(Get-DeclaredExemptFiles -RepoRoot $script:RepoRoot -DeclaredExemptExtensions @($script:DeclaredExemptExtensions.Keys))
        $violators = @()
        foreach ($f in $exemptFiles) {
            $full = Join-Path $script:RepoRoot $f
            if (-not (Test-Path $full -PathType Leaf)) { continue }
            $text = Get-Content -Path $full -Raw -Encoding UTF8
            if ([regex]::IsMatch($text, $script:CoordRe)) {
                $violators += "$f (extension $([System.IO.Path]::GetExtension($f))) now carries a coordinate-shaped match - re-evaluate its exemption"
            }
        }
        ($violators -join "`n") | Should -BeNullOrEmpty
    }

    It 'the extensionless exemption is scoped to its declared allowlist (LICENSE), not to "any extensionless file"' {
        $observedExtensionless = @($script:AllNonArtifact | Where-Object { [System.IO.Path]::GetExtension($_) -eq '' })
        $unaccounted = @($observedExtensionless | Where-Object { $script:DeclaredExemptExtensionlessFiles -notcontains $_ })
        $unaccounted.Count | Should -Be 0 -Because (
            "extensionless file(s) [$($unaccounted -join ', ')] are not in the declared " +
            "allowlist (`$script:DeclaredExemptExtensionlessFiles = LICENSE only) - a new " +
            "extensionless file shares the '' extension but not LICENSE's exemption reason; " +
            "decide and add it explicitly, do not let it ride LICENSE's coattails")
    }

    It 'every literal-path or uniquely-resolved-basename citation points at a file that exists at HEAD (Class A)' {
        $violators = @($script:DeadPath | ForEach-Object {
            "$($_.CitingFile):$($_.StartLine)$(if ($_.EndLine -ne $_.StartLine) { "-$($_.EndLine)" }) cites '$($_.Target):$($_.TargetLine)$(if ($_.TargetLine2) { "-$($_.TargetLine2)" })' - NO SUCH FILE"
        })
        ($violators -join "`n") | Should -BeNullOrEmpty
    }

    It 'every resolved citation''s line (or range end) is within the target file''s line count (Class B floor)' {
        $violators = @($script:OutOfRange | ForEach-Object {
            $checkLine = if ($_.TargetLine2) { $_.TargetLine2 } else { $_.TargetLine }
            "$($_.CitingFile):$($_.StartLine) cites '$($_.Target):$checkLine' - target file has fewer lines"
        })
        ($violators -join "`n") | Should -BeNullOrEmpty
    }

    It 'reports ellipsis-elided ("...") citations as exempt, by name, never silently (the repo''s own truncation convention)' {
        $names = @($script:Elided | ForEach-Object { "$($_.CitingFile):$($_.StartLine) -> '$($_.Target):$($_.TargetLine)'" })
        Set-ItResult -Skipped -Because (
            "informational, not a failure: $($names.Count) ellipsis-elided citation(s) exempted - " +
            ($(if ($names.Count -gt 0) { $names -join '; ' } else { '(none)' })))
    }

    It 'reports historical-coordinate-marked citations as exempt, by name, never silently' {
        $names = @($script:Historical | ForEach-Object { "$($_.CitingFile):$($_.StartLine) -> '$($_.Target):$($_.TargetLine)'" })
        Set-ItResult -Skipped -Because (
            "informational, not a failure: $($names.Count) historical-coordinate citation(s) exempted - " +
            ($(if ($names.Count -gt 0) { $names -join '; ' } else { '(none)' })))
    }

    It 'reports ambiguous bare-basename citations by name, never silently resolved either way' {
        # An ambiguous ELIDED coordinate re-resolves via the suffix-match resolver,
        # never the plain exact-basename one, which would print a misleading empty
        # candidate list for a truncated ellipsis token.
        $display = @($script:Ambiguous | ForEach-Object {
            if ($_.Elided) {
                $r = Resolve-ElidedCitationTarget -RepoRoot $script:RepoRoot -Coordinate $_ -AllTrackedFiles $script:AllTrackedFiles
            } else {
                $r = Resolve-CitationTarget -RepoRoot $script:RepoRoot -Coordinate $_ -BasenameMap $script:BasenameMap
            }
            "$($_.CitingFile):$($_.StartLine) -> '$($_.Target):$($_.TargetLine)' matches [$($r.ResolvedPath)]"
        })
        Set-ItResult -Skipped -Because (
            "informational, not a failure: $($display.Count) bare-basename citation(s) match 2+ tracked files, " +
            "cannot be mechanically disambiguated - $(($display -join '; '))")
    }

    It 'reports the content-anchor heuristic (backtick-token-in-window), REPORT-ONLY' {
        $hit = 0; $miss = 0; $missNames = @()
        foreach ($c in $script:Ok) {
            if (-not $c.Target.Contains('/')) { continue }
            $citingFull = Join-Path $script:RepoRoot $c.CitingFile
            $citingLines = @(Get-Content -Path $citingFull -Encoding UTF8)
            $lineIdx = [Math]::Min($c.EndLine, $citingLines.Count) - 1
            if ($lineIdx -lt 0) { continue }
            $tokens = @(Get-ContentAnchorTokens -Line $citingLines[$lineIdx])
            if ($tokens.Count -eq 0) { continue }
            $targetFull = Join-Path $script:RepoRoot $c.Target
            $targetLines = @(Get-Content -Path $targetFull -Encoding UTF8)
            $checkLine = if ($c.TargetLine2) { $c.TargetLine2 } else { $c.TargetLine }
            $lo = [Math]::Max(0, $checkLine - 1 - 15)
            $hi = [Math]::Min($targetLines.Count - 1, $checkLine - 1 + 15)
            $windowText = ($targetLines[$lo..$hi] -join "`n")
            $found = Test-ContentAnchorWindow -Tokens $tokens -WindowText $windowText -CaseSensitive
            if ($found) { $hit++ } else { $miss++; $missNames += "$($c.CitingFile):$($c.StartLine) -> $($c.Target):$checkLine" }
        }
        Set-ItResult -Skipped -Because (
            "REPORT-ONLY, never binding: hit=$hit miss=$miss at this HEAD. Misses: " +
            "$(if ($missNames.Count -gt 0) { $missNames -join '; ' } else { '(none)' })")
    }
}

Describe 'Content-anchor case-sensitivity fixture (#65)' {
    # Reproduces one structural shape directly, without touching git: an exact-case
    # token declared far above the cited line, a lowercase collision inside the anchor
    # window, and the exact-case reoccurrence outside the window.
    BeforeAll {
        $script:FixtureTargetLines = @(
            'StalenessMs int  // field declaration, exact case, line 1 - OUTSIDE the window'
        ) + (2..16 | ForEach-Object { "filler line $_" }) + @(
            'RepoRoot string  // line 17 - the WRONG cited line, mimics config.go:42'
        ) + (18..31 | ForEach-Object { "filler line $_" }) + @(
            '// port 4600, pollMs 1000, heartbeatMs 5000, stalenessMs 15000.  // line 32, lowercase collision, INSIDE the window'
        ) + (33..39 | ForEach-Object { "filler line $_" }) + @(
            'StalenessMs: 15000,  // line 40 - exact-case reoccurrence, OUTSIDE the window'
        ) + (41..45 | ForEach-Object { "filler line $_" })
        $script:FixtureCitingLine = 'measured: `StalenessMs` ships at `15000` (`config-like.go:17`) against a shop default'
        $script:FixtureCheckLine  = 17
        $script:FixtureTokens     = Get-ContentAnchorTokens -Line $script:FixtureCitingLine
        $lo = [Math]::Max(0, $script:FixtureCheckLine - 1 - 15)
        $hi = [Math]::Min($script:FixtureTargetLines.Count - 1, $script:FixtureCheckLine - 1 + 15)
        $script:FixtureWindowText = ($script:FixtureTargetLines[$lo..$hi] -join "`n")
    }

    It 'the fixture carries exactly one qualifying backtick token, StalenessMs' {
        $script:FixtureTokens | Should -Be @('StalenessMs')
    }

    It 'a case-insensitive match false-hits against the lowercase collision' {
        (Test-ContentAnchorWindow -Tokens $script:FixtureTokens -WindowText $script:FixtureWindowText) | Should -BeTrue
    }

    It 'the case-sensitive match (the production choice) correctly misses' {
        (Test-ContentAnchorWindow -Tokens $script:FixtureTokens -WindowText $script:FixtureWindowText -CaseSensitive) | Should -BeFalse
    }
}

Describe 'Citation coordinate scan performance sanity (#65)' {
    It 'completes the real-corpus scan within a bounded time (CI runs this on every push)' {
        $repoRoot = git rev-parse --show-toplevel
        $sourceFiles = @(Get-CheckedSourceFiles -RepoRoot $repoRoot)
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $coords = @(Find-CitationCoordinates -RepoRoot $repoRoot -SourceFiles $sourceFiles)
        $sw.Stop()
        # Sanity ceiling against accidental quadratic blowup, not a tight SLA.
        $sw.Elapsed.TotalSeconds | Should -BeLessThan 60 -Because (
            "scanned $($sourceFiles.Count) files / $($coords.Count) coordinates in $($sw.Elapsed.TotalSeconds) seconds")
    }
}

Describe 'Line-wrap unwrapping and false-join suppression (scratch repo, #65)' {
    # Proves the mechanism in isolation, independent of whether any given real-repo
    # instance of each class stays present after future edits.

    BeforeAll {
        $script:Scratch = Join-Path ([System.IO.Path]::GetTempPath()) "citation-resolver-test-$(Get-Random)"
        New-Item -ItemType Directory -Path $script:Scratch -Force | Out-Null
        git -C $script:Scratch init -q | Out-Null
        git -C $script:Scratch config user.email 'test@starcar.local' | Out-Null
        git -C $script:Scratch config user.name  'Citation Resolver Test' | Out-Null

        # The TARGET of every fixture citation below - a real file with a known length.
        1..20 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'target.go') -Encoding UTF8
        # A SECOND target with an intra-name hyphen, matching the real scar shape (kebab-
        # case filenames like "dom-writer.js" wrapped exactly at an EXISTING hyphen that
        # is part of the name itself, not an inserted one).
        1..20 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'tar-get.go') -Encoding UTF8

        # Fixture 1: a clean, resolvable single-line citation.
        Set-Content -Path (Join-Path $script:Scratch 'clean.md') -Value @(
            '# clean'
            'See target.go:5 for the real thing.'
        ) -Encoding UTF8

        # Fixture 2: CLASS A - dead path (file does not exist).
        Set-Content -Path (Join-Path $script:Scratch 'dead-path.md') -Value @(
            '# dead path'
            'See nonexistent-file.go:12 which was never real.'
        ) -Encoding UTF8

        # Fixture 3: CLASS B - out-of-range line (target.go only has 20 lines).
        Set-Content -Path (Join-Path $script:Scratch 'out-of-range.md') -Value @(
            '# out of range'
            'See target.go:999 which does not exist in the target.'
        ) -Encoding UTF8

        # Fixture 4: CLASS C - line-wrapped citation, split exactly at the target's own
        # intra-name hyphen (a kebab-case filename wrapped at its own hyphen).
        Set-Content -Path (Join-Path $script:Scratch 'wrapped.js') -Value @(
            '// this comment cites tar-'
            '// get.go:7 across a wrap, exactly like the real scar.'
        ) -Encoding UTF8

        # Fixture 5: a false-join risk - two unrelated adjacent lines where the FIRST
        # does NOT end in a hyphen. Must NOT be glued into a spurious coordinate.
        Set-Content -Path (Join-Path $script:Scratch 'no-false-join.go') -Value @(
            '// this line ends with the word disclosed at'
            '// target.go:9 is unrelated content on the next line'
        ) -Encoding UTF8

        # Fixture 6: ellipsis elision, resolving via the truncated form.
        Set-Content -Path (Join-Path $script:Scratch 'elided.md') -Value @(
            '# elided'
            'See the earlier full citation, abbreviated here as (`.../target.go:3`).'
        ) -Encoding UTF8

        # Fixture 7: historical-marker exemption over a genuinely dead path.
        Set-Content -Path (Join-Path $script:Scratch 'historical.md') -Value @(
            '# historical'
            'The old gone-file.go:1 reference is a historical coordinate, kept for the scar.'
        ) -Encoding UTF8

        # Fixture 8: a fabricated ellipsis reference to a file that never existed -
        # must resolve dead.
        Set-Content -Path (Join-Path $script:Scratch 'elided-dead.md') -Value @(
            '# elided dead'
            'A fabricated shorthand (`.../never-existed.md:3`) that must not pass.'
        ) -Encoding UTF8

        # Fixture 9: two files sharing a basename, both too short for the cited line -
        # must bind as out-of-range, not wave through as merely ambiguous.
        New-Item -ItemType Directory -Path (Join-Path $script:Scratch 'subA') -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $script:Scratch 'subB') -Force | Out-Null
        1..5 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'subA/dup.md') -Encoding UTF8
        1..5 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'subB/dup.md') -Encoding UTF8
        Set-Content -Path (Join-Path $script:Scratch 'ambiguous-oor.md') -Value @(
            '# ambiguous out of range'
            'See dup.md:999 - both candidates are 5 lines long.'
        ) -Encoding UTF8

        # Fixture 10: a slash-boundary wrap - the citing line ends in a bare `/`, and
        # the coordinate is only correct once the directory prefix joins the next
        # line's bare filename.
        New-Item -ItemType Directory -Path (Join-Path $script:Scratch 'board/web/js') -Force | Out-Null
        1..20 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'board/web/js/dom-writer.js') -Encoding UTF8
        Set-Content -Path (Join-Path $script:Scratch 'slash-wrap.md') -Value @(
            '// see board/web/js/'
            '// dom-writer.js:5 for details.'
        ) -Encoding UTF8

        # Fixture 11: an ambiguous elided citation - two files whose basename shares
        # the elided suffix. The ambiguous report must show real candidates, never
        # the "[]" a plain exact-basename lookup would print for a truncated token.
        New-Item -ItemType Directory -Path (Join-Path $script:Scratch 'subA') -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $script:Scratch 'subB') -Force | Out-Null
        1..10 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'subA/report-thing.md') -Encoding UTF8
        1..10 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'subB/summary-thing.md') -Encoding UTF8
        Set-Content -Path (Join-Path $script:Scratch 'elided-ambiguous.md') -Value @(
            '# elided ambiguous'
            'See the earlier citation, abbreviated as (`.../thing.md:3`).'
        ) -Encoding UTF8

        git -C $script:Scratch add -A | Out-Null
        git -C $script:Scratch commit -q -m 'fixtures' | Out-Null

        $script:AllFiles    = @('target.go', 'clean.md', 'dead-path.md', 'out-of-range.md', 'wrapped.js', 'no-false-join.go', 'elided.md', 'historical.md', 'elided-dead.md', 'ambiguous-oor.md', 'slash-wrap.md', 'elided-ambiguous.md')
        $script:BasenameMap = Get-BasenameMap -RepoRoot $script:Scratch
        $script:AllTracked  = @(git -C $script:Scratch ls-files)
        $script:Coords      = @(Find-CitationCoordinates -RepoRoot $script:Scratch -SourceFiles $script:AllFiles)
    }

    AfterAll {
        Remove-Item -Path $script:Scratch -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'resolves the clean single-line citation as OK' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'clean.md' }
        $c.Count | Should -Be 1
        (Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap).Status | Should -Be 'ok'
    }

    It 'flags the dead-path fixture BY NAME (Class A, red-first proof)' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'dead-path.md' }
        $c.Count | Should -Be 1
        $c.Target | Should -Be 'nonexistent-file.go'
        (Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap).Status | Should -Be 'dead'
    }

    It 'flags the out-of-range fixture BY NAME (Class B, red-first proof)' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'out-of-range.md' }
        $c.Count | Should -Be 1
        $c.TargetLine | Should -Be 999
        (Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap).Status | Should -Be 'out-of-range'
    }

    It 'resolves the line-wrapped fixture correctly by unwrapping (Class C, red-first proof it is NOT missed)' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'wrapped.js' }
        $c.Count | Should -Be 1
        $c.Target | Should -Be 'tar-get.go'
        $c.TargetLine | Should -Be 7
        $c.StartLine | Should -Be 1
        $c.EndLine | Should -Be 2
        (Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap).Status | Should -Be 'ok'
    }

    It 'does NOT create a spurious joined match when the prior line does not end in a hyphen' {
        $bogus = $script:Coords | Where-Object { $_.CitingFile -eq 'no-false-join.go' -and $_.Target -like '*disclosed*' }
        $bogus.Count | Should -Be 0
        # The real, single-line "target.go:9" on line 2 must still be found and OK.
        $real = $script:Coords | Where-Object { $_.CitingFile -eq 'no-false-join.go' }
        $real.Count | Should -Be 1
        $real.Target | Should -Be 'target.go'
        $real.TargetLine | Should -Be 9
    }

    It 'marks the ellipsis-elided fixture Elided rather than dead' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'elided.md' }
        $c.Count | Should -Be 1
        $c.Elided | Should -BeTrue
    }

    It 'the historical-coordinate marker is detected on the fixture citing a dead path' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'historical.md' }
        $c.Count | Should -Be 1
        (Test-HistoricalCoordinateMarker -RepoRoot $script:Scratch -Coordinate $c) | Should -BeTrue
        # And confirm it WOULD have been flagged dead without the marker - the marker is
        # doing real work, not decorating an already-passing case.
        (Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap).Status | Should -Be 'dead'
    }

    It 'flags a fabricated ellipsis reference BY NAME - a fabricated ".../never-existed.md:3" must not pass' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'elided-dead.md' }
        $c.Count | Should -Be 1
        $c.Elided | Should -BeTrue
        (Resolve-ElidedCitationTarget -RepoRoot $script:Scratch -Coordinate $c -AllTrackedFiles $script:AllTracked).Status | Should -Be 'dead'
    }

    It 'binds the all-candidates-out-of-range ambiguous case' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'ambiguous-oor.md' }
        $c.Count | Should -Be 1
        $c.Target | Should -Be 'dup.md'
        $r = Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap
        # Both subA/dup.md and subB/dup.md are 5 lines; the cited line is 999 - out of
        # range for EVERY candidate, so this binds as a real defect, not mere ambiguity.
        $r.Status | Should -Be 'out-of-range'
    }

    It 'joins across a bare trailing slash - the directory prefix must join the next line''s bare filename' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'slash-wrap.md' }
        $c.Count | Should -Be 1
        $c.Target | Should -Be 'board/web/js/dom-writer.js'
        $c.TargetLine | Should -Be 5
        (Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap).Status | Should -Be 'ok'
    }

    It 'an ambiguous elided citation resolves via suffix match with real candidates, never "matches []"' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'elided-ambiguous.md' }
        $c.Count | Should -Be 1
        $c.Elided | Should -BeTrue
        $r = Resolve-ElidedCitationTarget -RepoRoot $script:Scratch -Coordinate $c -AllTrackedFiles $script:AllTracked
        $r.Status | Should -Be 'ambiguous'
        $r.ResolvedPath | Should -Not -BeNullOrEmpty
        $r.ResolvedPath | Should -Match 'subA[/\\]report-thing\.md'
        $r.ResolvedPath | Should -Match 'subB[/\\]summary-thing\.md'
    }
}

Describe 'Test-CitationWrapBoundary unit tests (#65)' {
    It 'a word character immediately before a trailing hyphen is a wrap boundary' {
        Test-CitationWrapBoundary -TrimmedLine 'this comment cites tar-' | Should -BeTrue
    }
    It 'a space immediately before a trailing hyphen is not a wrap boundary (the prose-dash case)' {
        Test-CitationWrapBoundary -TrimmedLine 'this comment cites tar -' | Should -BeFalse
    }
    It 'a bare trailing slash is a wrap boundary' {
        Test-CitationWrapBoundary -TrimmedLine 'see board/web/js/' | Should -BeTrue
    }
    It 'ordinary prose with neither ending is not a wrap boundary' {
        Test-CitationWrapBoundary -TrimmedLine 'this is an ordinary sentence.' | Should -BeFalse
    }
}

Describe 'Extension-completeness helper unit tests (#65)' {
    It 'detects a genuinely unaccounted extensionless entry (Count 1, element is empty string)' {
        $unaccounted = @(Get-UnaccountedExtensions -ObservedExtensions @('.go', '') -CoveredExtensions @('.go'))
        $unaccounted.Count | Should -Be 1
        $unaccounted -contains '' | Should -BeTrue
    }
    It 'reports zero unaccounted once every observed extension is covered' {
        $unaccounted = @(Get-UnaccountedExtensions -ObservedExtensions @('.go', '.md') -CoveredExtensions @('.go', '.md'))
        $unaccounted.Count | Should -Be 0
    }
    It 'names an unaccounted extension by value, not just by count' {
        $unaccounted = @(Get-UnaccountedExtensions -ObservedExtensions @('.go', '.py', '.md') -CoveredExtensions @('.go', '.md'))
        $unaccounted.Count | Should -Be 1
        $unaccounted | Should -Be @('.py')
    }
}
