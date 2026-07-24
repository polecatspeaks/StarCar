#requires -Version 7.4
# CheckpointReconcile.Probes.Tests.ps1 -- #46, the second Layer-3 reconciliation cadence
# (docs/templates/worked-verification-reconciliation.md), aimed at the working-state
# checkpoint instead of CI. The first instance is session-start-ci-baseline.sh; this
# pins the same shape for .claude/hooks/session-start-checkpoint-reconcile.sh.
#
# WHY THIS EXISTS (doctrine: NO HEADERS HERE): docs/friction-log.md's 2026-07-23 evening
# section records the conductor reading RESUME-HERE.md claiming "THE DRILL (#21) - ARMED"
# in the SAME two tool calls as the friction log (and commit 38b67c8's own subject) saying
# the drill had ALREADY PASSED, and proceeding on the stale half anyway. This probe pins
# the hook that reconciles the checkpoint's pinned base against live git history so that
# class of contradiction surfaces mechanically instead of by luck.
#
# PROBED FACTS this suite is built against (re-run any you doubt):
#   - The real checkpoint ($HOME/.claude/projects/C--Users-Chris-git-starcar/memory/
#     RESUME-HERE.md) carried 32 SHA-shaped tokens, 17 distinct (`grep -oE
#     '\b[0-9a-f]{7,40}\b'`), at time of writing (#46) -- a PERISHABLE count: the checkpoint
#     is rewritten every session (the reviewer measured 14/11 one dispatch later). commit
#     SHAs, CI run ids, a session UUID fragment, dispatch task ids, a blob hash prefix -- so
#     a hook that greps for "a SHA" reads garbage regardless of the exact tally. A
#     uniquely-tagged marker line is required, not a bare SHA scan.
#   - `git log --oneline deadbeef..HEAD` exits 128 on an unresolvable base, but the hook
#     redirects stderr on the range call -- so an UNVALIDATED base does not "spew fatal";
#     worse, its empty stdout is silently read as "in sync", a FALSE NEGATIVE on the very
#     instrument built to prevent false confidence. The hook MUST validate with
#     `git cat-file -e` before the range so an unresolvable base degrades to could-not-observe.
#   - `git cat-file -e <valid-format-but-unknown-sha>` also fails ("Not a valid object
#     name") -- this is the honest "could not observe" case (rebase/prune), distinct from
#     both "in sync" (silent) and "stale" (prints commits), mirroring Watch-CI.ps1 keeping
#     could-not-observe distinct from red.
#
# DESIGN DECISION, disclosed: the frontmatter of RESUME-HERE.md was PROBED live this
# session and found to be machine-managed -- its `modified` and `originSessionId` fields
# changed underneath the car with no edit performed (originSessionId now reads this car's
# own session id). Frontmatter is therefore NOT a safe place to pin the marker; the line
# lives in the document BODY as an HTML comment (invisible when rendered, present in the
# raw text a fixed-string grep can find, immune to whatever rewrites the frontmatter).
#
# CONSUMER: .claude/hooks/session-start-checkpoint-reconcile.sh (landed same commit),
# .claude/skills/goodnight/SKILL.md step 3 (where the marker-pinning instruction lands),
# .claude/settings.json (SessionStart wiring).
#
# INVOCATION: pwsh -NoProfile -Command "Invoke-Pester -Path ./scripts/probes" -- run from
# the Bash-tool environment (sh is on PATH there; the PowerShell tool's pwsh lacks sh on
# PATH per docs/friction-log.md 07-23, and this suite invokes the hook via `sh`).

Describe 'Checkpoint reconciliation hook (#46) - fires on stale base, silent on current, honest on unresolvable' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:Hook = Join-Path $script:RepoRoot '.claude/hooks/session-start-checkpoint-reconcile.sh'

        # A throwaway git repo, real history, so `git log <base>..HEAD` and
        # `git cat-file -e` reflect genuine commits rather than the real StarCar repo
        # (the HookLatency fixture-repo pattern, scripts/probes/HookLatency.Probes.Tests.ps1).
        function New-FixtureRepo {
            param([string[]]$CommitSubjects)
            $repo = Join-Path ([System.IO.Path]::GetTempPath()) ("ckptprobe-" + [guid]::NewGuid().ToString('N'))
            New-Item -ItemType Directory -Path $repo -Force | Out-Null
            git -C $repo init -q | Out-Null
            git -C $repo config user.email 'ckpt-probe@starcar.local' | Out-Null
            git -C $repo config user.name 'Checkpoint Probe' | Out-Null
            $shas = New-Object System.Collections.Generic.List[string]
            foreach ($subject in $CommitSubjects) {
                Set-Content -Path (Join-Path $repo 'state.txt') -Value $subject -Encoding utf8NoBOM
                git -C $repo add state.txt | Out-Null
                git -C $repo commit -q -m $subject | Out-Null
                $shas.Add((git -C $repo rev-parse HEAD))
            }
            [pscustomobject]@{ Path = $repo; Shas = $shas }
        }

        function New-CheckpointFile {
            param([string]$Dir, [string]$BaseSha, [switch]$NoMarkerLine, [switch]$Absent, [string]$ExtraNoise = '')
            $file = Join-Path $Dir 'RESUME-HERE.md'
            if ($Absent) { return $file }
            $lines = @('---', 'name: resume-here', '---', '')
            if ($ExtraNoise) { $lines += $ExtraNoise }
            if (-not $NoMarkerLine) {
                $lines += "<!-- checkpoint-base: $BaseSha -->"
            }
            $lines += '# RESUME HERE'
            Set-Content -Path $file -Value ($lines -join "`n") -Encoding utf8NoBOM
            return $file
        }

        # Invokes the hook with cwd = the fixture repo (so `git log`/`git cat-file` see
        # its history) and CHECKPOINT_FILE overridden to a fixture checkpoint (so the
        # real machine-managed memory file is never touched by this suite).
        function Invoke-Hook {
            param([string]$RepoDir, [string]$CheckpointFile)
            Push-Location $RepoDir
            try {
                $env:CHECKPOINT_FILE = $CheckpointFile
                $out = & sh $script:Hook 2>&1
                $exitCode = $LASTEXITCODE
            } finally {
                Remove-Item Env:\CHECKPOINT_FILE -ErrorAction SilentlyContinue
                Pop-Location
            }
            [pscustomobject]@{ Output = ($out -join "`n"); ExitCode = $exitCode }
        }
    }

    It 'the hook file exists at .claude/hooks/session-start-checkpoint-reconcile.sh' {
        Test-Path $script:Hook | Should -BeTrue
    }

    It 'CONTROL: is SILENT when the pinned base equals current HEAD - no crying wolf (severity philosophy: 54 flags of which 50 were false)' {
        $fixture = New-FixtureRepo -CommitSubjects @('seed', 'second commit')
        $head = $fixture.Shas[-1]
        $ckpt = New-CheckpointFile -Dir $fixture.Path -BaseSha $head
        $result = Invoke-Hook -RepoDir $fixture.Path -CheckpointFile $ckpt
        $result.ExitCode | Should -Be 0
        $result.Output | Should -BeNullOrEmpty
    }

    It 'FAULT INJECTION: FIRES and lists commit subjects when the pinned base is behind HEAD' {
        $fixture = New-FixtureRepo -CommitSubjects @('seed', 'checkpoint written here', 'retro: the drill PASSES - stale-base regression')
        $baseSha = $fixture.Shas[1]   # pin at the SECOND commit; the THIRD lands after
        $ckpt = New-CheckpointFile -Dir $fixture.Path -BaseSha $baseSha
        $result = Invoke-Hook -RepoDir $fixture.Path -CheckpointFile $ckpt
        $result.ExitCode | Should -Be 0
        $result.Output | Should -Not -BeNullOrEmpty
        $result.Output | Should -Match 'retro: the drill PASSES - stale-base regression'
        $result.Output | Should -Not -Match 'checkpoint written here'   # the base itself, not "since base"
    }

    It 'CONTROL REVERTED: the same fixture is silent once the pinned base is moved to current HEAD' {
        $fixture = New-FixtureRepo -CommitSubjects @('seed', 'checkpoint written here', 'a later commit')
        $head = $fixture.Shas[-1]
        $ckpt = New-CheckpointFile -Dir $fixture.Path -BaseSha $head
        $result = Invoke-Hook -RepoDir $fixture.Path -CheckpointFile $ckpt
        $result.ExitCode | Should -Be 0
        $result.Output | Should -BeNullOrEmpty
    }

    It 'HONEST DEGRADE: a valid-format but unresolvable SHA (rebase/prune) prints a distinct could-not-observe message, never fatals, never silent' {
        $fixture = New-FixtureRepo -CommitSubjects @('seed', 'second commit')
        $unknownButValidFormat = 'deadbeefdeadbeefdeadbeefdeadbeefdeadbeef'   # 40 hex chars, not a real object
        $ckpt = New-CheckpointFile -Dir $fixture.Path -BaseSha $unknownButValidFormat
        $result = Invoke-Hook -RepoDir $fixture.Path -CheckpointFile $ckpt
        $result.ExitCode | Should -Be 0
        $result.Output | Should -Not -BeNullOrEmpty
        $result.Output | Should -Not -Match 'fatal:'   # the naive-hook crash this design avoids
        $result.Output | Should -Match 'not found|could not|unresolvable'
    }

    It 'LAW 7 (the stranger): is SILENT and non-fatal when the checkpoint file is entirely absent' {
        $fixture = New-FixtureRepo -CommitSubjects @('seed')
        $ckpt = New-CheckpointFile -Dir $fixture.Path -BaseSha $fixture.Shas[0] -Absent
        Test-Path $ckpt | Should -BeFalse
        $result = Invoke-Hook -RepoDir $fixture.Path -CheckpointFile $ckpt
        $result.ExitCode | Should -Be 0
        $result.Output | Should -BeNullOrEmpty
    }

    It 'ARMING SIGNAL (#46): checkpoint present but UNARMED (no marker line) prints a loud ONE-line notice on the owner box, still exit 0 - distinct from the stranger''s silent no-file case (Law 2 informs, never blocks; Law 7 silence is only owed the stranger)' {
        $fixture = New-FixtureRepo -CommitSubjects @('seed', 'second commit')
        $ckpt = New-CheckpointFile -Dir $fixture.Path -BaseSha $fixture.Shas[0] -NoMarkerLine
        $result = Invoke-Hook -RepoDir $fixture.Path -CheckpointFile $ckpt
        $result.ExitCode | Should -Be 0
        $result.Output | Should -Not -BeNullOrEmpty
        $result.Output | Should -Match 'UNARMED'
        # a loud one-liner, not a wall - the arming signal is cheap to read
        (($result.Output -split "`n") | Where-Object { $_ -ne '' }).Count | Should -Be 1
    }

    It 'MARKER FORMAT SINGLE SOURCE (#46, Law 6): the docs quote the hook''s OWN MARKER string, derived from the hook - no hand-maintained fifth copy to drift' {
        # Parse MARKER='...' straight out of the hook so this assertion can never become a
        # fifth hand-kept copy. If the hook's marker changes and a doc is not updated in the
        # SAME commit, this reds (fault-injection-proven both directions in the fix-cycle report).
        $hookText = Get-Content $script:Hook -Raw
        $hookText | Should -Match "MARKER='([^']+)'"
        $marker = [regex]::Match($hookText, "MARKER='([^']+)'").Groups[1].Value
        $marker | Should -Not -BeNullOrEmpty

        $skill = Join-Path $script:RepoRoot '.claude/skills/goodnight/SKILL.md'
        $setup = Join-Path $script:RepoRoot 'docs/setup.md'
        (Get-Content $skill -Raw) | Should -BeLike "*$marker*"
        (Get-Content $setup -Raw) | Should -BeLike "*$marker*"
    }

    It 'NON-VACUITY (the 20-token proof): extracts the MARKED base, not a decoy SHA-shaped token sitting elsewhere in the file' {
        $fixture = New-FixtureRepo -CommitSubjects @('seed', 'checkpoint written here', 'landed after the checkpoint')
        $baseSha = $fixture.Shas[1]
        # Decoy tokens shaped exactly like the real ones this class of bug reads: a CI
        # run id, a session UUID fragment, a dispatch task id - none of them valid refs
        # in THIS fixture repo, so if the hook ever greps "a SHA" instead of the marker,
        # it will pick one of these and either fatal or misreport.
        $noise = "CI run 30044141768, session e92f5a0b-1b9e-4913-98b3-c319b4d5e90b, dispatch a3bfb5c078bd8da96, blob aef0aeb1"
        $ckpt = New-CheckpointFile -Dir $fixture.Path -BaseSha $baseSha -ExtraNoise $noise
        $result = Invoke-Hook -RepoDir $fixture.Path -CheckpointFile $ckpt
        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match 'landed after the checkpoint'
        $result.Output | Should -Not -Match 'fatal:'
    }

    It 'NO SILENT CAPS: truncation past the show-limit is disclosed, not hidden' {
        $subjects = @('seed') + (1..20 | ForEach-Object { "commit number $_" })
        $fixture = New-FixtureRepo -CommitSubjects $subjects
        $baseSha = $fixture.Shas[0]
        $ckpt = New-CheckpointFile -Dir $fixture.Path -BaseSha $baseSha
        $result = Invoke-Hook -RepoDir $fixture.Path -CheckpointFile $ckpt
        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match '20 commit'   # 20 commits since base
        $result.Output | Should -Match 'more|showing'   # disclosed truncation, not a silent cap
    }
}
