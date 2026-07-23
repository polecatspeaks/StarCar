#requires -Version 7.4
# Plan task 2.4 (docs/plans/2026-07-23-yard-board-plan.md S3, [PB-2, folded]):
# schema/vocab/board-defs.json is the PRESENTATIONAL vocabulary the wire schema's
# `vocabularies` block requires (schema/yard-snapshot.schema.json:102-112) -
# positions/outcomes/roles/liveness arrays of {id, label, register}. Recognition
# VALUES stay owned by the existing vocab files (schema/vocab/outcomes.json,
# schema/vocab/roles.json) and by the mechanism-closed position/liveness sets
# (design rev 5 S5.2, S5.6 - no schema/vocab/positions.json or liveness.json exists;
# these ids are closed by mechanism, not by a recognition-vocabulary file); this file
# adds label+register presentation only.
#
# THE REGISTER ASSIGNMENTS ARE PINNED BY THE PLAN (task 2.4) - this test does not
# re-derive them, it asserts the committed file matches them exactly.

BeforeDiscovery {
    $repoRoot = (git rev-parse --show-toplevel)
}

Describe 'schema/vocab/board-defs.json - presentational vocabulary (plan 2.4)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:BoardDefsPath = Join-Path $script:RepoRoot 'schema/vocab/board-defs.json'
        $script:OutcomesValues = (Get-Content (Join-Path $script:RepoRoot 'schema/vocab/outcomes.json') -Raw -Encoding UTF8 | ConvertFrom-Json).values
        $script:RolesValues = (Get-Content (Join-Path $script:RepoRoot 'schema/vocab/roles.json') -Raw -Encoding UTF8 | ConvertFrom-Json).values

        # Positions and liveness states are CLOSED BY MECHANISM (design rev 5 S5.2's
        # position set, S5.6's liveness gradient) - no schema/vocab/positions.json or
        # liveness.json exists to enumerate them from, so the v0 closed sets are
        # named here, matching design rev 5:165 and :222 exactly.
        $script:PositionIds = @('live', 'bagged', 'dark', 'under-construction')
        $script:LivenessIds = @('dispatched', 'overdue', 'returned', 'presumed-lost')

        $script:ClosedRegisters = @('nominal', 'in-progress', 'needs-attention')

        # THE PINNED TABLE (plan task 2.4, verbatim) - the single source this test
        # checks the committed file against. A mismatch names its id, so a flip is
        # caught BY NAME, never as a generic diff.
        $script:PinnedRegisters = @{
            positions = @{
                'live'                = 'nominal'
                'bagged'              = 'nominal'
                'dark'                = 'nominal'
                'under-construction'  = 'in-progress'
            }
            liveness = @{
                'returned'      = 'nominal'
                'dispatched'    = 'in-progress'
                'overdue'       = 'needs-attention'
                'presumed-lost' = 'needs-attention'
            }
            outcomes = @{
                'APPROVE'                  = 'nominal'
                'APPROVE-WITH-REBASE-LIST' = 'nominal'
                'REJECT'                   = 'nominal'
                'CONFIRM'                  = 'nominal'
                'done'                     = 'nominal'
                'honest-stop'              = 'nominal'
                'done-with-findings'       = 'in-progress'
                'error'                    = 'needs-attention'
            }
            roles = @{
                'car'      = 'nominal'
                'reviewer' = 'nominal'
                'gate'     = 'nominal'
            }
        }

        function Get-PinnedMismatches {
            <#
              Compares a parsed board-defs object against $script:PinnedRegisters and
              returns a list of mismatch descriptions, each NAMING the category and id
              that diverged - so a flipped assignment is caught by name, never merely
              "something differs". Empty list = every pinned assignment matches.
            #>
            param([Parameter(Mandatory)] [object]$BoardDefs)

            $mismatches = New-Object System.Collections.Generic.List[string]
            foreach ($category in $script:PinnedRegisters.Keys) {
                $defsForCategory = @($BoardDefs.$category)
                foreach ($id in $script:PinnedRegisters[$category].Keys) {
                    $expected = $script:PinnedRegisters[$category][$id]
                    $def = $defsForCategory | Where-Object { $_.id -eq $id } | Select-Object -First 1
                    if (-not $def) {
                        $mismatches.Add("${category}.${id}: no def found")
                        continue
                    }
                    if ($def.register -ne $expected) {
                        $mismatches.Add("${category}.${id}: expected register '$expected', found '$($def.register)'")
                    }
                }
            }
            return $mismatches
        }
    }

    It 'the file exists and is parseable JSON' {
        Test-Path $script:BoardDefsPath | Should -BeTrue
        { Get-Content $script:BoardDefsPath -Raw -Encoding UTF8 | ConvertFrom-Json } | Should -Not -Throw
    }

    Context 'coverage (a): every recognition value / closed-set id has a def' {
        BeforeAll {
            $script:BoardDefs = Get-Content $script:BoardDefsPath -Raw -Encoding UTF8 | ConvertFrom-Json
        }

        It 'every outcomes.json value has a def in board-defs.json outcomes' {
            $defIds = @($script:BoardDefs.outcomes.id)
            foreach ($v in $script:OutcomesValues) {
                $defIds | Should -Contain $v -Because "outcomes.json's '$v' must have a presentational def"
            }
        }

        It 'every roles.json value has a def in board-defs.json roles' {
            $defIds = @($script:BoardDefs.roles.id)
            foreach ($v in $script:RolesValues) {
                $defIds | Should -Contain $v -Because "roles.json's '$v' must have a presentational def"
            }
        }

        It 'every closed-set position id has a def in board-defs.json positions' {
            $defIds = @($script:BoardDefs.positions.id)
            foreach ($v in $script:PositionIds) {
                $defIds | Should -Contain $v -Because "position '$v' must have a presentational def"
            }
        }

        It 'every closed-set liveness id has a def in board-defs.json liveness' {
            $defIds = @($script:BoardDefs.liveness.id)
            foreach ($v in $script:LivenessIds) {
                $defIds | Should -Contain $v -Because "liveness state '$v' must have a presentational def"
            }
        }
    }

    Context 'closed register set (b): every def''s register is nominal/in-progress/needs-attention' {
        BeforeAll {
            $script:BoardDefs = Get-Content $script:BoardDefsPath -Raw -Encoding UTF8 | ConvertFrom-Json
        }

        It 'every def in every category has a register from the closed set: <_>' -ForEach @('positions', 'outcomes', 'roles', 'liveness') {
            $category = $_
            foreach ($def in @($script:BoardDefs.$category)) {
                $script:ClosedRegisters | Should -Contain $def.register -Because "$category.$($def.id)'s register must be one of nominal/in-progress/needs-attention"
            }
        }
    }

    Context 'load-bearing assignments (c): the pinned table' {
        BeforeAll {
            $script:BoardDefs = Get-Content $script:BoardDefsPath -Raw -Encoding UTF8 | ConvertFrom-Json
        }

        It 'the committed file matches every pinned assignment exactly' {
            $mismatches = Get-PinnedMismatches -BoardDefs $script:BoardDefs
            $mismatches | Should -BeNullOrEmpty -Because "the pinned table (plan task 2.4) must match exactly; mismatches: $($mismatches -join '; ')"
        }

        It 'MANDATORY: a REJECT def flipped to needs-attention is caught BY NAME (non-vacuity proof)' {
            # Regression-vault shape: the check above passes on arrival, which proves
            # nothing about whether it is real. Fault-inject ONCE into a TestDrive copy
            # (never the committed file), confirm the flip is caught and NAMED, then
            # confirm the real file on disk is untouched (no revert needed - the flip
            # never left TestDrive).
            $originalBytes = Get-Content $script:BoardDefsPath -Raw -Encoding UTF8
            $flipped = $originalBytes | ConvertFrom-Json
            ($flipped.outcomes | Where-Object { $_.id -eq 'REJECT' }).register = 'needs-attention'

            $mismatches = Get-PinnedMismatches -BoardDefs $flipped
            $mismatches | Should -Not -BeNullOrEmpty -Because 'the flipped REJECT assignment must be caught'
            ($mismatches -join '; ') | Should -Match 'outcomes\.REJECT' -Because 'the failure must name REJECT specifically, not merely report a generic mismatch'

            # The real file is untouched - only the in-memory parsed copy was mutated.
            (Get-Content $script:BoardDefsPath -Raw -Encoding UTF8) | Should -Be $originalBytes
        }
    }
}
