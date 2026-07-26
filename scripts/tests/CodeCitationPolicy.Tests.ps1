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
# CI SHALLOW-CHECKOUT HAZARD (#42 round 2, REJECT M1): the boundary commit must be
# RESOLVABLE in whatever checkout runs this suite. A depth-1 clone (the default of
# `actions/checkout@v4` with no `fetch-depth`) does not contain `d4db6f5...` and
# `git diff --diff-filter=A <sha> HEAD` then fails with `fatal: bad object`, which the
# original round-1 gate turned into a MISLEADING result - "finds added post-boundary
# code files" failed with "Expected greater than 0, but got 0", masquerading as an empty
# corpus rather than naming its real cause. `.github/workflows/ci.yml`'s checkout step
# now carries `fetch-depth: 0` (round 2 fix) so the boundary is always reachable in CI;
# this file ALSO carries its own pinned resolvability assertion below (belt and
# suspenders - a future workflow edit that drops `fetch-depth` again fails NAMED here
# instead of silently reproducing the round-1 defect).
#
# SCOPE, derived from the real post-boundary corpus (git diff --name-only
# --diff-filter=A d4db6f5..HEAD at this gate's landing: 117 added paths, probed before
# writing this file):
#   - CODE extensions checked: .ps1 .psm1 .go .js .mjs .sh. The actual post-boundary
#     corpus contains .ps1 (8), .go (6), .js (3), .mjs (1), .sh (3); .psm1 has no
#     instance yet but is added proactively as the same PowerShell-script family as
#     .ps1 (same language, same comment syntax) - not overreach, just the obvious sibling.
#   - .json is DECLARED EXEMPT, not silently skipped. JSON has no native comment syntax,
#     and the standard's own fixture exemption (schema/vectors/**/*.json and *.expect -
#     "adding a $comment would mutate the artifact under test") generalizes to
#     config/manifest JSON too: board/web/package.json, board/web/package-lock.json
#     (npm-generated, not hand-written), and .github/hooks/entire.json are
#     configuration/data, not code in the sense this standard targets, and forcing a
#     citation key into any of them risks the same artifact-mutation problem the
#     standard names for vectors. (Observed at landing: entire.json and package.json in
#     fact already carry #47/#33 references in ordinary string values, unprompted -
#     further evidence this class does not need a mechanical floor today.)
#   - .md is DECLARED EXEMPT, not silently skipped. Documentation has its own mechanical
#     floor - DocPolicy.Tests.ps1's Status-line gate - and CLAUDE.md's citation standard
#     is scoped by this gate to code; docs are not double-gated here.
#   - artifacts/** is NOT checked at all (any extension). CLAUDE.md states the exemption
#     verbatim: "Exempt: machine-generated records... is data rather than code."
#   - THE CLOSED SET (matching DocPolicy.Tests.ps1:26's framing): "checked" and
#     "declared exempt" together are the closed set. Growing either is a deliberate
#     decision, never a convenience. A THIRD Describe block below asserts this
#     mechanically - every extension actually observed in the post-boundary,
#     non-artifacts corpus must be in checked-union-exempt, or the suite reds BY NAME
#     naming the unaccounted extension (#42 round 2, REJECT M2: a hardcoded six-extension
#     allowlist with nothing asserting completeness let .py/.css/.ts through silently -
#     fault-injected and measured 7/7 green in round 1).
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
# reference OR this file's own worked examples (this file itself now contains `#123456`
# as a documented hex-collision example and `#999` as a scratch-repo fixture number,
# neither a real ticket - round 2 MIN-2: the round-1 sentence claimed "no collision
# anywhere in the checked set," which this very file falsified the moment it was
# written; the claim is narrowed here to "no UNINTENDED collision," which stays true).
# Real ticket numbers here are 2 digits. If a genuine collision risk ever materializes,
# calibrate then - building comment-aware parsing for a risk that has not materialized
# is the autoimmune failure this repo's session-start retro rule warns against.
#
# UNGATED RESIDUAL, disclosed (#42 round 2, MIN-4): the standard's fixture clause -
# citation for a comment-incapable file goes in the sibling README.md or the consuming
# test - has NO mechanical check here or anywhere else in this repo. It is honored in
# practice today (schema/vectors/adapter/README.md carries #47) but stays attention-tier;
# reviewers carry it, same as the whole standard did before this gate. Building it is
# out of scope for #42, which targets code files that CAN carry a comment.

BeforeAll {
    # Shared functions, file scope: Pester v5 runs script-level code outside any
    # Describe/It only during DISCOVERY, in a scope that a naive top-level `function`
    # statement does not carry into RUN phase (probed in round 1: CommandNotFoundException
    # at run time despite clean parse and working dot-source). A file-level `BeforeAll`
    # block (this one, outside every Describe) DOES survive into RUN phase and IS shared
    # across every Describe in the file - probed directly for round 2 (a 2-Describe file
    # with one file-level BeforeAll defining a function: both Describes saw it, 2/2
    # passed). Round 1 wrongly concluded each Describe needed its OWN copy (the two
    # Describes' BeforeAll blocks run in separate scopes, which is true) and duplicated
    # ~25 lines byte-for-byte (round 2 MIN-1) instead of hoisting to this shared block,
    # so the scratch-repo proof exercised a copy that could silently diverge from the
    # production path. One definition now; both Describes below use it directly.
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

    function Get-AddedNonArtifactFiles {
        param(
            [Parameter(Mandatory)] [string] $RepoRoot,
            [Parameter(Mandatory)] [string] $BoundarySha,
            [string]                        $HeadRef = 'HEAD'
        )
        $added = git -C $RepoRoot diff --name-only --diff-filter=A $BoundarySha $HeadRef
        if (-not $added) { return @() }
        return @($added | Where-Object { $_ -notmatch '^artifacts/' })
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

    function Test-BoundaryResolvable {
        # #42 round 2 MAJOR-1: a shallow clone (CI's default) does not contain the
        # boundary commit, and the raw `git diff` failure ("fatal: bad object") was
        # previously swallowed - the suite just saw an empty added-set and reported the
        # wrong root cause. This makes the check explicit and nameable.
        param(
            [Parameter(Mandatory)] [string] $RepoRoot,
            [Parameter(Mandatory)] [string] $BoundarySha
        )
        git -C $RepoRoot cat-file -e "$BoundarySha^{commit}" 2>$null
        return ($LASTEXITCODE -eq 0)
    }
}

Describe 'Repo policy: code files added after the citation standard cite their ticket' {

    BeforeAll {
        $script:RepoRoot       = (git rev-parse --show-toplevel)
        $script:BoundarySha    = 'd4db6f5baf2bd31bf41f9dc5804684334797cb35'
        $script:CodeExtensions = @('.ps1', '.psm1', '.go', '.js', '.mjs', '.sh')
        # The closed set's other half (#42 round 2 MAJOR-2): every declared exemption
        # carries its reason inline, same discipline as the header's SCOPE section.
        $script:DeclaredExemptExtensions = [ordered]@{
            '.json' = 'no native comment syntax; the fixture-mutation reasoning for schema/vectors/**/*.json generalizes to config/manifest JSON'
            '.md'   = 'documentation; owned by DocPolicy.Tests.ps1''s Status-line gate, not this one'
        }

        $script:BoundaryResolvable = Test-BoundaryResolvable -RepoRoot $script:RepoRoot -BoundarySha $script:BoundarySha
        if ($script:BoundaryResolvable) {
            $script:AddedCodeFiles        = Get-AddedCodeFiles -RepoRoot $script:RepoRoot `
                -BoundarySha $script:BoundarySha -CodeExtensions $script:CodeExtensions
            $script:AllAddedNonArtifact   = Get-AddedNonArtifactFiles -RepoRoot $script:RepoRoot `
                -BoundarySha $script:BoundarySha
        }
        else {
            # Do not attempt the diff against an unresolvable boundary: that is exactly
            # how round 1 produced the misleading "0 files found" symptom instead of a
            # named cause. Leave both empty; the dedicated It below is what must fail.
            $script:AddedCodeFiles      = @()
            $script:AllAddedNonArtifact = @()
        }
    }

    It 'the boundary commit resolves in this checkout (a shallow clone without fetch-depth cannot reach it)' {
        $script:BoundaryResolvable | Should -BeTrue -Because (
            "boundary commit $script:BoundarySha is unreachable in this checkout - " +
            "shallow clone? this gate needs history back to that commit (ci.yml's " +
            "checkout step must carry fetch-depth: 0, or enough depth to include it)")
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

    It 'every extension in the post-boundary corpus is checked or a declared exemption (the closed set - #42 round 2 MAJOR-2)' {
        $observedExtensions = @($script:AllAddedNonArtifact |
            ForEach-Object { [System.IO.Path]::GetExtension($_) } |
            Sort-Object -Unique)
        $covered = @($script:CodeExtensions) + @($script:DeclaredExemptExtensions.Keys)
        $unaccounted = @($observedExtensions | Where-Object { $covered -notcontains $_ })
        # A NEW extension arriving post-boundary (e.g. .py, .css, .ts - all fault-injected
        # and measured silently-green in round 1) must force a deliberate decision: add it
        # to $CodeExtensions (checked) or to $DeclaredExemptExtensions (exempt, with a
        # reason). Silence is never an acceptable third option.
        $unaccounted -join ', ' | Should -BeNullOrEmpty -Because (
            "extension(s) [$($unaccounted -join ', ')] appeared in the post-boundary " +
            "corpus with no citation check and no declared exemption - decide: extend " +
            "`$CodeExtensions or `$DeclaredExemptExtensions, do not leave it silent")
    }
}

Describe 'Citation detection logic (scratch repo, proves the boundary and the fault-injection case)' {

    BeforeAll {
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

    It 'names an unresolvable boundary rather than masquerading as an empty corpus (#42 round 2 MAJOR-1)' {
        # A garbage sha stands in for "boundary commit absent from a shallow clone" -
        # Test-BoundaryResolvable must report false, not throw, not silently pass.
        Test-BoundaryResolvable -RepoRoot $script:Scratch -BoundarySha ('0' * 40) | Should -BeFalse
        Test-BoundaryResolvable -RepoRoot $script:Scratch -BoundarySha $script:BoundarySha | Should -BeTrue
    }
}
