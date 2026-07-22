# Repo policy: every document declares which truth-standard it accepts being held to.
#
# Ported from the ancestor shop's "repo policy" CI job
# (docs/templates/repo-policy-check-patterns.md §1). This is the graduation path the
# Healing Loop prefers: a check that fires at CI beats a reviewer who must remember.
#
# WHY IT MATTERS HERE SPECIFICALLY: this repo's north star ranks documentation equal to
# code, and "documents are living" needs a mechanical floor. The Status line is each
# document declaring its own standard - Current means a stale claim in it is a defect.
#
# THE PORTED SCAR, and it is the reason the regex is deliberately plain and anchored:
# a decorated `**Status:**` header once passed human eyes and failed this gate, and the
# fix was fixing the DOCUMENT to the machine-checkable form, NEVER loosening the checker.
# On first run here, 16 of 28 documents failed - including seven landed verdicts whose
# headers had to be corrected at the PRODUCER and re-landed, because their Status line
# sits inside a SHA-256-covered region and hand-editing would have broken integrity.
#
# Keep the marker simple enough that a machine can hold it, and never soften the checker
# to accommodate drift.

Describe 'Repo policy: docs carry a machine-checkable Status line' {

    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:DocsRoot = Join-Path $script:RepoRoot 'docs'
        # The closed set. Growing it is a deliberate decision, not a convenience.
        #   Current    - true now; a stale claim in it is a defect
        #   Done       - a completed record (a landed verdict, a closed audit)
        #   Superseded - kept for provenance; points at its successor
        #   Open       - a draft; claims not yet gated
        $script:Pattern = '^Status: (Current|Done|Superseded|Open)$'
        $script:HeaderLines = 5
    }

    It 'finds documents to check (a check that examines nothing is not a pass)' {
        $docs = Get-ChildItem -Path $script:DocsRoot -Filter *.md -Recurse -File
        # The same discipline ci.yml applies to Pester itself: a green run that asserted
        # nothing is not a pass. If docs/ is empty or moved, this fails loudly.
        $docs.Count | Should -BeGreaterThan 0
    }

    It 'every document under docs/ declares a Status from the closed set' {
        $violators = @()
        foreach ($doc in (Get-ChildItem -Path $script:DocsRoot -Filter *.md -Recurse -File)) {
            $head = Get-Content $doc.FullName -TotalCount $script:HeaderLines -Encoding UTF8
            if (-not ($head -match $script:Pattern)) {
                $rel = $doc.FullName.Substring($script:RepoRoot.Length + 1) -replace '\\', '/'
                $claimed = ($head | Where-Object { $_ -match '^Status' } | Select-Object -First 1)
                if (-not $claimed) { $claimed = '(no Status line at all)' }
                $violators += "$rel  ->  $claimed"
            }
        }
        # Listing every violator beats failing on the first: a fix pass wants the whole set.
        $violators -join "`n" | Should -BeNullOrEmpty
    }
}
