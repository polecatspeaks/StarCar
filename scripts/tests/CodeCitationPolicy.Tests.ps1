# Repo policy: every code file added after the citation standard cites its ticket (#42).
#
# CLAUDE.md's Tracking section (CODE STANDARD: every new addition cites its ticket)
# ratified 2026-07-23: every new file, and every new unit of consequence inside an
# existing one, carries a comment citing the causing ticket as bare `#N`. That standard
# was attention-tier (reviewers carry it) until this gate landed. Ported from
# DocPolicy.Tests.ps1's shape (docs/templates/repo-policy-check-patterns.md SS1): walk a
# set of files, apply a plain check, list every violator, fail if any remain. This is
# that same pattern aimed at newly-added code files instead of docs/ Status lines (#42).
#
# FORWARD-ONLY BOUNDARY, RULED (#42, CLAUDE.md "NO BACKFILL. THE BOUNDARY IS THE POINT"):
# the standard was ratified at commit d4db6f5baf2bd31bf41f9dc5804684334797cb35
# (2026-07-23, "standard: every new code addition cites its ticket as bare #N"). This
# gate checks only files ADDED strictly after that commit, never the whole tree. CLAUDE.md
# says so verbatim: "a gate built for this checks files ADDED after the line; a gate that
# reds on older files is mis-specified, not thorough." The scratch-repo Describe block
# below proves the boundary holds; the production Describe block proves it on the real
# corpus at HEAD.
#
# SCOPE, derived from the real post-boundary corpus (git diff --name-only
# --diff-filter=A d4db6f5..HEAD at this gate's landing: 117 added paths, probed before
# writing this file):
#   - CODE extensions checked: .ps1 .psm1 .go .js .mjs .sh. The actual post-boundary
#     corpus contains .ps1 (8), .go (6), .js (3), .mjs (1), .sh (3); .psm1 has no
#     instance yet but is added proactively as the same PowerShell-script family as
#     .ps1 (same language, same comment syntax) - not overreach, just the obvious sibling.
#   - .json is NOT checked. JSON has no native comment syntax, and the standard's own
#     fixture exemption (schema/vectors/**/*.json and *.expect - "adding a $comment
#     would mutate the artifact under test") generalizes to config/manifest JSON too:
#     board/web/package.json, board/web/package-lock.json (npm-generated, not
#     hand-written), and .github/hooks/entire.json are configuration/data, not code in
#     the sense this standard targets, and forcing a citation key into any of them risks
#     the same artifact-mutation problem the standard names for vectors. (Observed at
#     landing: entire.json and package.json in fact already carry #47/#33 references in
#     ordinary string values, unprompted - further evidence this class does not need a
#     mechanical floor today.)
#   - .md is NOT checked. Documentation has its own mechanical floor - DocPolicy.Tests.ps1's
#     Status-line gate - and CLAUDE.md's citation standard is scoped by this gate to code;
#     docs are not double-gated here.
#   - artifacts/** is NOT checked at all (any extension). CLAUDE.md states the exemption
#     verbatim: "Exempt: machine-generated records... is data rather than code."
#
# ASSERTION: presence of a bare `#[0-9]+` marker anywhere in the file is the mechanical
# floor, per the standard's own text. This gate does NOT verify the cited ticket number
# is correct, open, or the right one - CLAUDE.md names that as reviewer judgment
# explicitly, and issue #42's body flags wrong-number verification as separate future work.
#
# KNOWN LIMITATION, disclosed rather than solved (YAGNI, matching the severity
# philosophy - an instrument that cries wolf is worse than none, but so is an
# instrument over-built for a case that does not exist): the regex is not restricted to
# a language-specific comment marker, so an all-digit hex literal (e.g. a CSS
# `#123456`) would false-positive as a citation. Probed at this gate's landing: no file
# in the checked extension set contains a match of `#[0-9]{3,}` outside a real ticket
# reference (real ticket numbers here are 2 digits). If that ever changes, calibrate
# then - building comment-aware parsing for a risk that has not materialized is the
# autoimmune failure this repo's session-start retro rule warns against.

Describe 'Repo policy: code files added after the citation standard cite their ticket' {

    BeforeAll {
        # Defined inside BeforeAll deliberately: Pester v5 runs script-level code
        # (outside Describe/It) only during the DISCOVERY phase, in a scope that does
        # not carry into RUN phase where BeforeAll/It execute - a function defined at
        # file scope is invisible here (probed: CommandNotFoundException at run time
        # even though ParseFile reports no syntax errors and dot-sourcing the file
        # directly resolves the function fine). Defining it inside BeforeAll keeps it
        # in the block's own run-time scope, which It blocks in this Describe share.
        function Get-AddedCodeFiles {
            param(
                [Parameter(Mandatory)] [string]   $RepoRoot,
                [Parameter(Mandatory)] [string]   $BoundarySha,
                [Parameter(Mandatory)] [string[]] $CodeExtensions,
                [string]                          $HeadRef = 'HEAD'
            )
            $added = git -C $RepoRoot diff --name-only --diff-filter=A $BoundarySha $HeadRef
            if (-not $added) { return @() }
            return @($added |
                Where-Object { $_ -notmatch '^artifacts/' } |
                Where-Object { $CodeExtensions -contains [System.IO.Path]::GetExtension($_) })
        }

        function Test-HasCitation {
            param(
                [Parameter(Mandatory)] [string] $FullPath,
                [string]                        $Pattern = '#[0-9]+'
            )
            if (-not (Test-Path $FullPath)) { return $true }  # deleted since; nothing left to cite
            $text = Get-Content -Path $FullPath -Raw -Encoding UTF8
            return [bool]($text -match $Pattern)
        }

        $script:RepoRoot       = (git rev-parse --show-toplevel)
        $script:BoundarySha    = 'd4db6f5baf2bd31bf41f9dc5804684334797cb35'
        $script:CodeExtensions = @('.ps1', '.psm1', '.go', '.js', '.mjs', '.sh')
        $script:AddedCodeFiles = Get-AddedCodeFiles -RepoRoot $script:RepoRoot `
            -BoundarySha $script:BoundarySha -CodeExtensions $script:CodeExtensions
    }

    It 'finds added post-boundary code files to check (a check that examines nothing is not a pass)' {
        $script:AddedCodeFiles.Count | Should -BeGreaterThan 0
    }

    It 'every code file added after the boundary carries a bare #N ticket citation' {
        $violators = @()
        foreach ($rel in $script:AddedCodeFiles) {
            $full = Join-Path $script:RepoRoot $rel
            if (-not (Test-HasCitation -FullPath $full)) {
                $violators += $rel
            }
        }
        # Listing every violator beats failing on the first: a fix pass wants the whole set.
        $violators -join "`n" | Should -BeNullOrEmpty
    }

    It 'does not check a file that predates the boundary (board/board.go, uncited by design)' {
        # board/board.go predates d4db6f5baf2bd31bf41f9dc5804684334797cb35 and carries no
        # #N citation. It must be ABSENT from the added-files set - proof this gate is
        # scoped to added files, never a whole-tree sweep. If this ever fails, either the
        # file was genuinely re-added (rare) or the boundary logic broke; either way it is
        # a real finding, not noise.
        $script:AddedCodeFiles | Should -Not -Contain 'board/board.go'
    }
}

Describe 'Citation detection logic (scratch repo, proves the boundary and the fault-injection case)' {

    BeforeAll {
        # Same functions as the production Describe above, redefined here because each
        # Describe's BeforeAll runs in its own scope (see the comment on the first
        # Describe's BeforeAll for why file-scope functions do not survive to run time).
        function Get-AddedCodeFiles {
            param(
                [Parameter(Mandatory)] [string]   $RepoRoot,
                [Parameter(Mandatory)] [string]   $BoundarySha,
                [Parameter(Mandatory)] [string[]] $CodeExtensions,
                [string]                          $HeadRef = 'HEAD'
            )
            $added = git -C $RepoRoot diff --name-only --diff-filter=A $BoundarySha $HeadRef
            if (-not $added) { return @() }
            return @($added |
                Where-Object { $_ -notmatch '^artifacts/' } |
                Where-Object { $CodeExtensions -contains [System.IO.Path]::GetExtension($_) })
        }

        function Test-HasCitation {
            param(
                [Parameter(Mandatory)] [string] $FullPath,
                [string]                        $Pattern = '#[0-9]+'
            )
            if (-not (Test-Path $FullPath)) { return $true }  # deleted since; nothing left to cite
            $text = Get-Content -Path $FullPath -Raw -Encoding UTF8
            return [bool]($text -match $Pattern)
        }

        $script:Scratch = Join-Path ([System.IO.Path]::GetTempPath()) "citation-policy-test-$(Get-Random)"
        New-Item -ItemType Directory -Path $script:Scratch -Force | Out-Null
        git -C $script:Scratch init -q | Out-Null
        git -C $script:Scratch config user.email 'test@starcar.local' | Out-Null
        git -C $script:Scratch config user.name  'Citation Policy Test' | Out-Null

        # Pre-boundary commit: an uncited shell script, standing in for the repo's real
        # pre-d4db6f5 history (e.g. board/board.go) - the standard does not apply to it.
        Set-Content -Path (Join-Path $script:Scratch 'pre-boundary.sh') -Value @(
            '#!/bin/sh'
            'echo "no citation, and correctly so: this predates the standard"'
        ) -Encoding UTF8
        git -C $script:Scratch add 'pre-boundary.sh' | Out-Null
        git -C $script:Scratch commit -q -m 'pre-boundary: predates the citation standard' | Out-Null
        $script:BoundarySha = (git -C $script:Scratch rev-parse HEAD)

        # Post-boundary commit 1: a properly cited file.
        Set-Content -Path (Join-Path $script:Scratch 'post-boundary-cited.sh') -Value @(
            '#!/bin/sh'
            '# added for #999, the scratch-repo drill'
            'echo "cited"'
        ) -Encoding UTF8
        git -C $script:Scratch add 'post-boundary-cited.sh' | Out-Null
        git -C $script:Scratch commit -q -m 'post-boundary: cited file (#999)' | Out-Null

        # Post-boundary commit 2: the fault-injected file - a new code file with NO
        # ticket citation. This is the failure case the production gate exists to catch.
        Set-Content -Path (Join-Path $script:Scratch 'post-boundary-uncited.sh') -Value @(
            '#!/bin/sh'
            'echo "no citation - this is the defect the gate must catch"'
        ) -Encoding UTF8
        git -C $script:Scratch add 'post-boundary-uncited.sh' | Out-Null
        git -C $script:Scratch commit -q -m 'post-boundary: uncited file (the fault)' | Out-Null

        $script:CodeExtensions = @('.sh')
        $script:AddedCodeFiles = Get-AddedCodeFiles -RepoRoot $script:Scratch `
            -BoundarySha $script:BoundarySha -CodeExtensions $script:CodeExtensions
    }

    AfterAll {
        Remove-Item -Path $script:Scratch -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'the added-files set contains exactly the two post-boundary files, never the pre-boundary one' {
        ($script:AddedCodeFiles | Sort-Object) | Should -Be @('post-boundary-cited.sh', 'post-boundary-uncited.sh')
    }

    It 'flags the fault-injected uncited file BY NAME' {
        $violators = @()
        foreach ($rel in $script:AddedCodeFiles) {
            $full = Join-Path $script:Scratch $rel
            if (-not (Test-HasCitation -FullPath $full)) { $violators += $rel }
        }
        $violators | Should -Be @('post-boundary-uncited.sh')
    }

    It 'does not flag the cited post-boundary file' {
        Test-HasCitation -FullPath (Join-Path $script:Scratch 'post-boundary-cited.sh') | Should -BeTrue
    }

    It 'does not flag the pre-boundary file even though it is uncited (the boundary proof)' {
        $script:AddedCodeFiles | Should -Not -Contain 'pre-boundary.sh'
    }
}
