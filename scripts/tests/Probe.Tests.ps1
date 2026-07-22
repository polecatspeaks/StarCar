# TEMPORARY FAULT INJECTION - deleted immediately after CI is observed going red.
#
# CLAUDE.md: a guard is unproven until someone has WATCHED it fire, and this repo has
# already been bitten once by trusting a guard that read back perfectly and turned out to
# be decorative (branch protection with enforce_admins false, founding day). CI going
# green on its first run proves the happy path and nothing else - a workflow that cannot
# fail is a green light wired to nothing.
#
# This test fails on purpose. Expected: the CI run goes RED at the "Run board tooling
# tests" step, with FailedCount 1.

Describe 'CI fault injection' {
    It 'fails deliberately so the pipeline can be observed going red' {
        # If you are reading this in a green CI run, the pipeline is not wired correctly.
        $true | Should -Be $false
    }
}
