# Repo policy: every file:line citation outside artifacts/ resolves to a real
# coordinate (#65).
#
# WHY THIS EXISTS. The citation-truth defect class hit NINE-PLUS instances across two
# trains in two days (view train #28+#12, rounds 1-3: artifacts/reviews/2026-07-26-
# view-28-12-review-r1-REJECT.md, -r2-REJECT.md, -r3-APPROVE.md), all caught only by
# expensive adversarial review attention, never mechanically. Round 2's own verdict
# named the fix: "A test that greps `\S+\.(go|js|css|md|json):\d+` outside `artifacts/`
# and asserts each coordinate resolves would have caught MAJOR-1, MAJOR-2 and
# MAJOR-R2-2 mechanically - including the line-wrapped one that defeated both the
# car's sweep and my first pass." Round 3 independently proved the unwrapping
# technique this file ports: "an unwrapping scanner: it strips comment leaders and
# joins all lines with no separator before matching the coordinate shape, so a
# citation split across a line wrap cannot hide." This gate is that mechanism,
# ratified by the owner (issue #65 comments) to land immediately after that train,
# ahead of #67/#69/#68.
#
# THE THREE PAID-FOR CLASSES this gate targets:
#   CLASS A, dead path - prose cites a file that does not exist (e.g. a "docs/CLAUDE.md"
#     that was never there; a stale "docs/reviews/..." path after harness #7's
#     migration commit moved review docs to artifacts/reviews/, git mv, history
#     preserved - two live instances of exactly this were found and fixed at this
#     gate's own landing, see CALIBRATION below).
#   CLASS B, shifted line - a citation was true when written; a later commit inserted
#     lines above it and the coordinate now points at unrelated code.
#   CLASS C, line-wrapped escape - a citation split across a markdown/comment line wrap
#     (e.g. "board/web/js/dom-" newline "writer.js:201") that defeats a naive
#     single-line or basename-anchored search. This file's scanner unwraps before
#     matching, per the round-3 reviewer's own proven technique.
#
# PRECEDENT SHAPE PORTED: scripts/tests/CodeCitationPolicy.Tests.ps1 (corpus-scan,
# closed-set, self-calibrating, reds BY NAME) and board/store/condition_severity_test.go
# (AST/corpus-scan against real sources, set-equality both directions). This file is
# that same shape aimed at file:line coordinates instead of ticket citations or
# severity codes.
#
# NO SHALLOW-CLONE HAZARD (unlike CodeCitationPolicy.Tests.ps1, #42 round 2 MAJOR-1):
# this gate has no boundary commit and does no history diff. It walks `git ls-files` at
# HEAD only, so a depth-1 CI checkout is sufficient; there is nothing here for
# `fetch-depth: 0` to fix.
#
# SCOPE, derived from the real corpus at this gate's landing (stated as fact, not
# claimed exhaustive over the future):
#   - SOURCE files scanned (the citing side): tracked files via `git ls-files`,
#     EXCLUDING `artifacts/**` (machine-generated records, historical by design per
#     CLAUDE.md's Tracking section - "Exempt: machine-generated records... is data
#     rather than code" - the same exemption CodeCitationPolicy.Tests.ps1 already
#     applies), `.git/` (not a tracked path, moot), `node_modules/` (gitignored, never
#     tracked, moot), AND EXCLUDING THIS FILE'S OWN PATH (self-exclusion, see the
#     Get-CheckedSourceFiles doc comment below for why - the worked-example prose and
#     scratch-repo test fixtures in this very file necessarily contain coordinate-
#     shaped strings that are not real citations). Extensions checked: .go .js .mjs
#     .css .md .json .ps1 .psm1 .sh .yml .yaml - the brief's floor set exactly.
#     .html was probed at landing
#     (`git grep -nE '[A-Za-z0-9_./-]+\.(go|js|md|json|ps1|sh):[0-9]+' -- '*.html'`)
#     and returned zero matches across both tracked .html files, so it is left out of
#     the checked set rather than added prospectively with no corpus evidence (YAGNI -
#     add it the day a .html file actually carries one, the same posture
#     CodeCitationPolicy.Tests.ps1 takes with .psm1 before its first instance).
#   - TARGET files (the cited side) are resolved against the FULL tracked-file set,
#     INCLUDING artifacts/**: a doc legitimately cites a landed review verdict under
#     `artifacts/reviews/**` (e.g. this file's own header cites three such verdicts),
#     and that target must be checkable even though it is never a citing SOURCE.
#
# DETECTION - the coordinate shape, after unwrapping:
#   Regex: `(\.?[A-Za-z0-9_][A-Za-z0-9_./-]*\.(?:go|js|mjs|css|md|json|ps1|psm1|sh|yml|yaml)):(\d+)(?:-(\d+))?`
#   The optional leading dot exists for dotdirs (`.claude/agents/car.md`,
#   `.github/workflows/ci.yml`) - probed at landing: two real citations in this corpus
#   ("claude/agents/car.md", "github/workflows/ci.yml") were silently missing their
#   leading dot in the FIRST cut of this regex, which is not a real defect in the docs -
#   it is the regex failing to capture a valid path. Fixed before landing.
#
# UNWRAPPING (Class C), the exact technique measured against this corpus:
#   Comment leaders (`//` or `#` at line start) are stripped per line. A line is joined
#   to the NEXT line - forming a 2-or-3-line sliding window, no separator - ONLY WHEN
#   the current (stripped, right-trimmed) line ends in a bare hyphen `-`. This
#   precondition is not a guess: EVERY genuine Class-C instance found in this corpus at
#   landing ends its wrapped line in a hyphen (`board/web/js/dom-` / `docs/design/2026-
#   07-21-v0-` / `docs/retros/2026-07-23-`, all kebab-case filenames wrapped exactly at
#   an existing hyphen), and naive no-precondition joining measured 8 FALSE dead-path
#   flags on this corpus ("disclosed at" + "poll.go" -> "atpoll.go"; "and" +
#   "schema/index-format.md" -> "andschema/index-format.md"; "mirrors" +
#   "scripts/Produce-Artifact.ps1" -> "mirrorsscripts/Produce-Artifact.ps1") - all
#   eliminated by the hyphen-boundary precondition, 0 false flags remaining. A line
#   whose PREDECESSOR ends in a hyphen is also suppressed as a fresh single-line start
#   (a "continuation" line), because scanning it alone re-finds the tail fragment as if
#   it were its own complete citation (e.g. "yard-skeleton-design.md:133" out of
#   "docs/design/2026-07-21-v0-yard-skeleton-design.md:133") - measured 2 further false
#   dead-path flags eliminated by this second guard.
#
# RESOLUTION POLICY (the reason a bare basename is not automatically resolved the same
# way as a full path - probed and decided with evidence, not assumed):
#   - Target CONTAINS a `/`: require an EXACT literal-path match relative to repo root.
#     No basename fallback. This is deliberate: the brief's own CLASS A example -
#     "board/assemble.go" for the real "board/assemble/assemble.go" - is exactly a
#     wrong-directory citation whose BASENAME would still resolve uniquely elsewhere;
#     silently accepting that via basename fallback would make this gate blind to the
#     named defect class it exists to catch. Probed live instance of the same shape at
#     landing: `docs/design/2026-07-22-dispatch-harness-design.md:97` and
#     `docs/specs/2026-07-22-dispatch-harness-spec.md:109` both cited
#     `docs/reviews/2026-07-22-harness-design-round1-REJECT.md:66` - a path that
#     predates harness #7's migration commit (`git mv docs/reviews -> artifacts/reviews`,
#     history preserved). The literal path no longer exists; the content at line 66 of
#     `artifacts/reviews/2026-07-22-harness-design-round1-REJECT.md` (git-mv history
#     confirms it is the same file) matches the citing text exactly. FIXED in this same
#     commit (both sites retargeted to the `artifacts/reviews/` path) rather than
#     silently basename-resolved.
#   - Target has NO `/` (a bare filename): fall back to a basename search across every
#     tracked file (including artifacts/). Exactly one candidate resolves silently
#     (this corpus's dominant style - `constitution.md`, `ci.yml`, `Board.psm1` etc. are
#     all cited bare and unambiguously). Zero candidates is CLASS A dead, by name. TWO
#     OR MORE candidates is genuinely ambiguous and NOT mechanically resolvable either
#     way (measured at landing: `README.md` x4, `state-ledger.md` x2, `gating-matrix.md`
#     x2 tracked files share a basename) - reported by name, never silently dropped and
#     never a hard fail, per the severity philosophy (a wrong guess in either direction
#     is worse than an honest "cannot decide mechanically here").
#
# EXEMPTIONS, both visible and greppable, neither silent:
#   - ELLIPSIS ELISION (`.../file.ext:N`): this repo's own established convention for an
#     abbreviated repeat-citation (`board/server/storepath.go:28` IMPLEMENTS this exact
#     truncation in production code: `return ".../" + filepath.Base(absPath)`; docs use
#     it identically, e.g. `.../drill.md:105`). A match whose four preceding characters
#     are literally `.../` is not a dead citation to a file named "drill.md" - it is a
#     deliberately truncated reference to a fuller citation stated nearby. Exempted,
#     counted, reported by name - never silently invisible.
#   - HISTORICAL COORDINATE marker: a citing line (or any line spanned by a wrapped
#     match) containing the literal, case-insensitive substring "historical
#     coordinate" is exempt from the existence/range checks. Real instance fixed at
#     this gate's landing: `.claude/hooks/run-session-start-guards.sh` cites
#     "session-start-record.sh:76", a script the SAME COMMENT already discloses as
#     "the now-deleted delivery script" - a genuinely historical citation to a file
#     that no longer exists, by design, not by drift. Marked explicitly with this
#     opt-out phrase in the same commit that adds this gate, rather than silently
#     re-flagged forever or silently allowlisted with no visible marker.
#
# CHECKS, escalating value, per the brief:
#   (a) BINDING - cited file exists at HEAD (Class A).
#   (b) BINDING - cited line (or the larger end of a range) is within the target
#       file's line count (Class B floor - catches a shifted-below-EOF citation).
#       NOTE: line counting is `@(Get-Content -Path $p -Encoding UTF8).Count`, never
#       `Get-Content | Measure-Object -Line` - probed at landing:
#       `board/fold/algorithm.go` has 266 lines by `.Count` and by `wc -l`, but
#       `Measure-Object -Line` on the same piped array reported 239 (it counts newline
#       characters within each already-split string element, not the number of
#       elements - unreliable for an array Get-Content already split by line). Using
#       the wrong method would have produced 1 false Class-B flag at landing
#       (`algorithm.go:240`, genuinely in range) and silently corrupted every other
#       range check in this file. Caught by probing before trusting the API, not by
#       reading its name.
#   (c) REPORT-ONLY, NOT BINDING - content anchor: does a backtick-quoted identifier
#       token from the citing line appear within +/-15 lines of the cited target line?
#       Measured at this gate's final landing HEAD, literal-path citations only: of the
#       resolvable literal-path citations, only 9 carry a backtick-quoted token on the
#       citing line at all (the rest have none - pure prose/row citations with nothing
#       to anchor on). Of those 9: 7 hit, 2 miss (`board/server/sse.go:77` cited from
#       `docs/contracts/gating-matrix.md:49`; `artifacts/reviews/2026-07-22-harness-
#       design-round1-REJECT.md:66` cited from this gate's own path-migration fix at
#       `docs/design/2026-07-22-dispatch-harness-design.md:97` - neither confirmed a
#       real defect, both are plain path citations with no repeated symbol token nearby
#       to anchor on). n=9 is too small and the token-presence rate too low to bind
#       without real false-flag risk - matching this repo's own prior-art guidance
#       verbatim (`docs/templates/repo-policy-check-patterns.md` SS3: "line numbers
#       drift on every edit above them - the cheap tier (file exists + symbol named
#       exists in file) avoids crying wolf; the expensive tier needs content-
#       anchoring... before it can be strict without being noisy"). Landed as a
#       measured, clearly-labeled diagnostic (Skipped-with-Because, never a hard fail),
#       decision recorded here rather than silently dropped.
#
# RED BY NAME: every failing check lists the citing file, the citing line (or line
# range for a wrapped citation), the dead/out-of-range coordinate, and which check
# failed - never an aggregate boolean.
#
# CALIBRATION AT LANDING (measured at this gate's own HEAD, numbers are fact, not a
# claim of future exhaustiveness):
#   Source files scanned (checked extensions, excluding artifacts/): 258
#   Coordinate matches found (deduped, post-unwrap, post-continuation-suppression): 192
#   Wrapped (required a >1-line window to resolve): 2 - both genuine Class-C instances
#     already present in this repo's real history, both TRUE once unwrapped:
#     `board/web/test/sse-protocol.test.js:8-9` -> `docs/design/2026-07-21-v0-yard-
#     skeleton-design.md:133`; `docs/design/2026-07-21-v0-yard-skeleton-design.md:585-
#     586` -> `docs/retros/2026-07-23-board-train-retro.md:120-121`.
#   Elided (ellipsis convention): 3, all `.../drill.md:1xx` in
#     docs/templates/design-briefs.md and docs/templates/worked-adversary-and-gate-
#     briefs.md, all resolving to `artifacts/reviews/2026-07-22-car2-plan-review-
#     round2-drill.md` (136 lines - both cited lines in range).
#   Historical-marker exempt: 1 (the session-start-record.sh:76 fix landed in this
#     same commit).
#   Ambiguous bare-basename (ratio, never silently resolved): 13.
#   TRUE DEFECTS FOUND AND FIXED in this same commit (both CLASS A, both the
#     docs/reviews/ -> artifacts/reviews/ migration-shadow described above):
#     `docs/design/2026-07-22-dispatch-harness-design.md:97`,
#     `docs/specs/2026-07-22-dispatch-harness-spec.md:109`.
#   Zero-false-flag bar: after the two fixes above and the one historical-marker
#     addition, this gate is GREEN against the real corpus (0 Class A, 0 Class B
#     remaining, both ambiguous and elided buckets reported non-failing).
#
# The three-item CALIBRATION INPUT from issue #65's own comment thread
# (docs/design/2026-07-22-dispatch-harness-design.md:53, docs/templates/design-doc.md:204,
# docs/templates/worked-spec.md:94, all citing "gating-matrix.md:23") was RE-VERIFIED,
# not blindly fixed: all three are bare basenames resolving (ambiguously, per the
# closed-set above - `docs/templates/gating-matrix.md` AND `docs/contracts/gating-
# matrix.md` both exist) to the TEMPLATE file, whose real line 23 IS the "Example:
# staleness banner" row quoting "never (truth surface)" / "DELIBERATE, no override"
# verbatim - confirmed true, not dead. `docs/templates/worked-spec.md:94` itself says
# so explicitly ("this project's own gating-matrix TEMPLATE already carries"). The
# owner's comment's premise (the row "now sits elsewhere") does not hold for the
# template file it is actually citing; it holds only for `docs/contracts/gating-
# matrix.md`, a DIFFERENT file sharing the same basename, which none of the three
# citations name explicitly. This is disclosed here rather than "fixed": there is
# nothing wrong to fix, and the real, useful finding is that "gating-matrix.md" is a
# genuinely ambiguous bare citation this gate now surfaces every run (the ambiguous
# bucket above), which is the honest, mechanical version of the owner's manual catch.

BeforeAll {
    $script:CheckedExtensions = @('.go', '.js', '.mjs', '.css', '.md', '.json', '.ps1', '.psm1', '.sh', '.yml', '.yaml')
    $script:ExtRe   = ($script:CheckedExtensions -replace '^\.', '') -join '|'
    $script:CoordRe = "(\.?[A-Za-z0-9_][A-Za-z0-9_./-]*\.(?:$($script:ExtRe))):(\d+)(?:-(\d+))?"
    $script:CommentLeaderRe = '^\s*(//|#)\s?'

    function Get-CheckedSourceFiles {
        # SELF-EXCLUSION, disclosed rather than solved (same class CodeCitationPolicy.
        # Tests.ps1 already discloses for its own "#123456" hex-collision example):
        # this gate's own source file necessarily reproduces coordinate-SHAPED strings
        # that are not real citations - worked-example prose describing a fixed dead
        # citation (e.g. quoting the exact stale "docs/reviews/...:66" path this commit
        # retargeted, for the reader's benefit) and, more heavily, the scratch-repo
        # fixture Describe block below, whose fixture FILE CONTENT must literally
        # contain `target.go:5`-shaped strings for the mechanism it is testing to have
        # anything to find. Scanning this file against itself would flag both as Class A
        # dead paths (the targets - "target.go", "nonexistent-file.go" etc. - exist only
        # inside an ephemeral scratch git repo, never in this one). Measured at landing:
        # excluding this one file is the only change needed; every other tracked file's
        # citations are still fully checked, including the ones THIS file's own header
        # narrates (docs/design/.../:97, board/server/storepath.go:28, etc.) - excluding
        # this file only stops it from checking ITS OWN prose, not from being cited BY
        # other files (none currently do).
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

    function Strip-CitationCommentLeader {
        param([string] $Line)
        return [regex]::Replace($Line, $script:CommentLeaderRe, '')
    }

    function Find-CitationCoordinates {
        # Scans $SourceFiles for file:line coordinates, unwrapping a line onto the
        # next ONLY when the current (stripped, right-trimmed) line ends in a bare
        # hyphen - see header UNWRAPPING note for why this precondition exists and
        # what it measurably prevents. Returns one object per distinct coordinate:
        # CitingFile, StartLine, EndLine, Target, TargetLine, TargetLine2, Elided.
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
                $isContinuation = ($i -gt 0) -and ((Strip-CitationCommentLeader $lines[$i - 1]).TrimEnd().EndsWith('-'))
                $joined = ''
                for ($w = 0; $w -lt $MaxWindow -and ($i + $w) -lt $lines.Count; $w++) {
                    if ($w -gt 0) {
                        $prevStripped = (Strip-CitationCommentLeader $lines[$i + $w - 1]).TrimEnd()
                        if (-not $prevStripped.EndsWith('-')) { break }
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
        $script:RepoRoot     = (git rev-parse --show-toplevel)
        $script:SourceFiles  = @(Get-CheckedSourceFiles -RepoRoot $script:RepoRoot)
        $script:BasenameMap  = Get-BasenameMap -RepoRoot $script:RepoRoot
        $script:Coordinates  = @(Find-CitationCoordinates -RepoRoot $script:RepoRoot -SourceFiles $script:SourceFiles)

        $script:DeadPath   = @()
        $script:OutOfRange = @()
        $script:Ambiguous  = @()
        $script:Elided     = @()
        $script:Historical = @()
        $script:Ok         = @()

        foreach ($c in $script:Coordinates) {
            if ($c.Elided) { $script:Elided += $c; continue }
            if (Test-HistoricalCoordinateMarker -RepoRoot $script:RepoRoot -Coordinate $c) {
                $script:Historical += $c; continue
            }
            $r = Resolve-CitationTarget -RepoRoot $script:RepoRoot -Coordinate $c -BasenameMap $script:BasenameMap
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
        $names = @($script:Ambiguous | ForEach-Object { "$($_.CitingFile):$($_.StartLine) -> '$($_.Target)' matches [$($_.ResolvedPath)]" })
        # This uses the OBJECT the resolver returned (ResolvedPath carries the candidate
        # list), so recompute display strings from the raw coordinates + a fresh resolve
        # to keep the message self-contained without depending on iteration order above.
        $display = @($script:Ambiguous | ForEach-Object {
            $r = Resolve-CitationTarget -RepoRoot $script:RepoRoot -Coordinate $_ -BasenameMap $script:BasenameMap
            "$($_.CitingFile):$($_.StartLine) -> '$($_.Target):$($_.TargetLine)' matches [$($r.ResolvedPath)]"
        })
        Set-ItResult -Skipped -Because (
            "informational, not a failure: $($display.Count) bare-basename citation(s) match 2+ tracked files, " +
            "cannot be mechanically disambiguated - $(($display -join '; '))")
    }

    It 'reports the content-anchor heuristic (backtick-token-in-window), REPORT-ONLY per landing calibration (n too small to bind)' {
        $backtickRe = '`([A-Za-z_][A-Za-z0-9_]{2,})`'
        $hit = 0; $miss = 0; $missNames = @()
        foreach ($c in $script:Ok) {
            if (-not $c.Target.Contains('/')) { continue }
            $citingFull = Join-Path $script:RepoRoot $c.CitingFile
            $citingLines = @(Get-Content -Path $citingFull -Encoding UTF8)
            $lineIdx = [Math]::Min($c.EndLine, $citingLines.Count) - 1
            if ($lineIdx -lt 0) { continue }
            $tokens = @([regex]::Matches($citingLines[$lineIdx], $backtickRe) |
                ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
            if ($tokens.Count -eq 0) { continue }
            $targetFull = Join-Path $script:RepoRoot $c.Target
            $targetLines = @(Get-Content -Path $targetFull -Encoding UTF8)
            $checkLine = if ($c.TargetLine2) { $c.TargetLine2 } else { $c.TargetLine }
            $lo = [Math]::Max(0, $checkLine - 1 - 15)
            $hi = [Math]::Min($targetLines.Count - 1, $checkLine - 1 + 15)
            $windowText = ($targetLines[$lo..$hi] -join "`n")
            $found = $false
            foreach ($tok in $tokens) { if ($windowText -match [regex]::Escape($tok)) { $found = $true; break } }
            if ($found) { $hit++ } else { $miss++; $missNames += "$($c.CitingFile):$($c.StartLine) -> $($c.Target):$checkLine" }
        }
        Set-ItResult -Skipped -Because (
            "REPORT-ONLY diagnostic, never binding (see header calibration): hit=$hit miss=$miss " +
            "at this HEAD. Misses: $(if ($missNames.Count -gt 0) { $missNames -join '; ' } else { '(none)' })")
    }
}

Describe 'Citation coordinate scan performance sanity (#65)' {
    It 'completes the real-corpus scan within a bounded time (CI runs this on every push)' {
        $repoRoot = git rev-parse --show-toplevel
        $sourceFiles = @(Get-CheckedSourceFiles -RepoRoot $repoRoot)
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $coords = @(Find-CitationCoordinates -RepoRoot $repoRoot -SourceFiles $sourceFiles)
        $sw.Stop()
        # Generous bound (60s) for a scan that measured well under 10s locally at
        # landing (258 files, 192 coordinates) - this is a sanity ceiling against
        # accidental quadratic blowup, not a tight performance SLA.
        $sw.Elapsed.TotalSeconds | Should -BeLessThan 60 -Because (
            "scanned $($sourceFiles.Count) files / $($coords.Count) coordinates in $($sw.Elapsed.TotalSeconds) seconds")
    }
}

Describe 'Line-wrap unwrapping and false-join suppression (scratch repo, #65)' {
    # Proves the MECHANISM in isolation, independent of whether the real repo's Class-C
    # instances stay present after future edits (they may get symbol-cited away, same as
    # the view train's own dom-writer.js:201 fix did) - the round-2/round-3 scars this
    # gate exists to catch, reproduced as durable fixtures.

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
        # intra-name hyphen, matching the real scar shape ("board/web/js/dom-" /
        # "writer.js:201" - dom-writer.js is one kebab-case name, wrapped at its hyphen).
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

        git -C $script:Scratch add -A | Out-Null
        git -C $script:Scratch commit -q -m 'fixtures' | Out-Null

        $script:AllFiles    = @('target.go', 'clean.md', 'dead-path.md', 'out-of-range.md', 'wrapped.js', 'no-false-join.go', 'elided.md', 'historical.md')
        $script:BasenameMap = Get-BasenameMap -RepoRoot $script:Scratch
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
}
