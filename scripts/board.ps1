# board.ps1 -- kanban ops by ISSUE NUMBER against GitHub Project 5 (#349 item 3).
#
# Wraps the manual `gh project` + GraphQL dance done by hand during the
# 2026-07-12 board passes (status moves, adds, top-of-column and after-item
# reordering). The project id, the Status field id, and its option ids are
# resolved at runtime every call via `gh project view` / `gh project
# field-list` -- never hardcoded, because they drifted once already.
#
# Pure parsing/lookup logic lives in Board.psm1 (Pester-tested with fixture
# JSON, no rig/token needed). This file is the thin gh wrapper: per the repo's
# TDD policy for CLI wrappers it is smoke-tested + documented rather than
# unit-tested (list + one reversible status round-trip on a closed Done issue;
# add/top/after are documented but not exercised against the live board -- see
# task-c2-report.md).
#
# Usage:
#   scripts/board.ps1 list [StatusName]
#   scripts/board.ps1 status <IssueNumber> <StatusName>
#   scripts/board.ps1 add <IssueNumber> [StatusName]
#   scripts/board.ps1 top <IssueNumber>
#   scripts/board.ps1 after <IssueNumber> <OtherIssueNumber>
#   scripts/board.ps1 status-batch <n1,n2,...> <StatusName>
#
# StatusName is validated against the LIVE field options (Backlog, Todo,
# In Progress, In Review, Done today, but never assumed).
#
# status-batch (#555): resolves project id + Status field + the item list
# ONCE, then applies N item-edits, instead of the per-call `status` command's
# full re-resolution each time (that pattern drained a whole GraphQL hour on
# ~20 operations on 2026-07-21). A single issue number missing from the board
# is reported and skipped, not fatal to the rest of the batch -- see
# Board.psm1's Resolve-BoardBatchItems (Pester-tested). An INDIVIDUAL gh
# item-edit failure mid-batch is likewise warned and skipped (the remaining
# edits still run; exit code 1 if anything missed or failed, 0 only on a
# fully clean batch) -- review 2026-07-21 asked for this to live here, not
# only in the commit message. Like the other write
# commands, this gh-wrapper loop is documented here rather than unit-tested
# (see task-c2-report.md precedent); only the parsing/lookup it calls into is
# unit-tested.
#
# Windows PowerShell 5.1 compatible: no ternary, no &&/||, ASCII only.

param(
    [Parameter(Mandatory, Position = 0)]
    [ValidateSet('list', 'status', 'add', 'top', 'after', 'status-batch')]
    [string]$Command,

    [Parameter(Position = 1)] [string]$Arg1,
    [Parameter(Position = 2)] [string]$Arg2,

    [string]$Owner = 'polecatspeaks',
    [int]$ProjectNumber = 6,
    [string]$Repo = 'polecatspeaks/StarCar'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'Board.psm1') -Force

function Get-ProjectIdLive {
    $raw = gh project view $ProjectNumber --owner $Owner --format json
    if ($LASTEXITCODE -ne 0) { throw "gh project view $ProjectNumber --owner $Owner failed (exit $LASTEXITCODE)." }
    ($raw | ConvertFrom-Json).id
}

function Get-StatusFieldLive {
    # --limit: gh defaults to 30 fields; same drift rationale as item-list's --limit 500 (review 2026-07-12)
    $raw = gh project field-list $ProjectNumber --owner $Owner --format json --limit 100
    if ($LASTEXITCODE -ne 0) { throw "gh project field-list $ProjectNumber --owner $Owner failed (exit $LASTEXITCODE)." }
    Get-BoardStatusField -FieldsResult ($raw | ConvertFrom-Json)
}

function Get-ItemsLive {
    # --limit 500: the project already has 200+ items (#349 ask: item-id
    # lookup must handle >200, well past gh's 30-item default).
    $raw = gh project item-list $ProjectNumber --owner $Owner --format json --limit 500
    if ($LASTEXITCODE -ne 0) { throw "gh project item-list $ProjectNumber --owner $Owner failed (exit $LASTEXITCODE)." }
    $raw | ConvertFrom-Json
}

function Get-RequiredItem {
    param([Parameter(Mandatory)] [object]$Items, [Parameter(Mandatory)] [int]$IssueNumber)

    $item = Find-BoardItemForIssue -ItemsResult $Items -IssueNumber $IssueNumber
    if (-not $item) {
        Write-Error "Issue #$IssueNumber is not on project $ProjectNumber. Use 'add' first."
        exit 1
    }
    return $item
}

switch ($Command) {
    'list' {
        $items = Get-ItemsLive
        $filterStatus = $Arg1
        foreach ($item in $items.items) {
            if ($filterStatus -and $item.status -ne $filterStatus) { continue }
            Write-Host (Format-BoardListLine -Item $item)
        }
        exit 0
    }

    'status' {
        if (-not $Arg1 -or -not $Arg2) {
            Write-Error 'Usage: board.ps1 status <IssueNumber> <StatusName>'
            exit 2
        }
        $issueNumber = [int]$Arg1
        $statusName = $Arg2

        $projectId = Get-ProjectIdLive
        $statusField = Get-StatusFieldLive
        $optionId = Resolve-BoardStatusOptionId -StatusField $statusField -StatusName $statusName

        $items = Get-ItemsLive
        $item = Get-RequiredItem -Items $items -IssueNumber $issueNumber

        gh project item-edit --id $item.ItemId --field-id $statusField.FieldId --project-id $projectId --single-select-option-id $optionId | Out-Null
        if ($LASTEXITCODE -ne 0) { Write-Error "gh project item-edit failed (exit $LASTEXITCODE)."; exit $LASTEXITCODE }

        Write-Host "#$issueNumber ($($item.Title)) -> $statusName"
        exit 0
    }

    'add' {
        if (-not $Arg1) {
            Write-Error 'Usage: board.ps1 add <IssueNumber> [StatusName]'
            exit 2
        }
        $issueNumber = [int]$Arg1
        $url = "https://github.com/$Repo/issues/$issueNumber"

        $raw = gh project item-add $ProjectNumber --owner $Owner --url $url --format json
        if ($LASTEXITCODE -ne 0) { Write-Error "gh project item-add failed (exit $LASTEXITCODE)."; exit $LASTEXITCODE }
        $added = $raw | ConvertFrom-Json
        Write-Host "#$issueNumber added to project $ProjectNumber (item id $($added.id))."

        if ($Arg2) {
            $projectId = Get-ProjectIdLive
            $statusField = Get-StatusFieldLive
            $optionId = Resolve-BoardStatusOptionId -StatusField $statusField -StatusName $Arg2
            gh project item-edit --id $added.id --field-id $statusField.FieldId --project-id $projectId --single-select-option-id $optionId | Out-Null
            if ($LASTEXITCODE -ne 0) { Write-Error "gh project item-edit failed (exit $LASTEXITCODE)."; exit $LASTEXITCODE }
            Write-Host "#$issueNumber -> $Arg2"
        }
        exit 0
    }

    'top' {
        if (-not $Arg1) {
            Write-Error 'Usage: board.ps1 top <IssueNumber>'
            exit 2
        }
        $issueNumber = [int]$Arg1
        $projectId = Get-ProjectIdLive
        $items = Get-ItemsLive
        $item = Get-RequiredItem -Items $items -IssueNumber $issueNumber

        # Omitting afterId (not passing null/empty) is what moves the item to
        # the very top -- UpdateProjectV2ItemPositionInput.afterId is a
        # nullable, optional ID (confirmed via GraphQL schema introspection).
        $query = 'mutation($projectId: ID!, $itemId: ID!) { updateProjectV2ItemPosition(input: {projectId: $projectId, itemId: $itemId}) { clientMutationId } }'
        gh api graphql -f query=$query -f "projectId=$projectId" -f "itemId=$($item.ItemId)" | Out-Null
        if ($LASTEXITCODE -ne 0) { Write-Error "gh api graphql (updateProjectV2ItemPosition) failed (exit $LASTEXITCODE)."; exit $LASTEXITCODE }

        Write-Host "#$issueNumber moved to top."
        exit 0
    }

    'after' {
        if (-not $Arg1 -or -not $Arg2) {
            Write-Error 'Usage: board.ps1 after <IssueNumber> <OtherIssueNumber>'
            exit 2
        }
        $issueNumber = [int]$Arg1
        $otherIssueNumber = [int]$Arg2
        $projectId = Get-ProjectIdLive
        $items = Get-ItemsLive
        $item = Get-RequiredItem -Items $items -IssueNumber $issueNumber
        $otherItem = Get-RequiredItem -Items $items -IssueNumber $otherIssueNumber

        $query = 'mutation($projectId: ID!, $itemId: ID!, $afterId: ID!) { updateProjectV2ItemPosition(input: {projectId: $projectId, itemId: $itemId, afterId: $afterId}) { clientMutationId } }'
        gh api graphql -f query=$query -f "projectId=$projectId" -f "itemId=$($item.ItemId)" -f "afterId=$($otherItem.ItemId)" | Out-Null
        if ($LASTEXITCODE -ne 0) { Write-Error "gh api graphql (updateProjectV2ItemPosition) failed (exit $LASTEXITCODE)."; exit $LASTEXITCODE }

        Write-Host "#$issueNumber moved after #$otherIssueNumber."
        exit 0
    }

    'status-batch' {
        if (-not $Arg1 -or -not $Arg2) {
            Write-Error 'Usage: board.ps1 status-batch <n1,n2,...> <StatusName>'
            exit 2
        }
        $statusName = $Arg2
        $issueNumbers = ConvertFrom-BoardIssueNumberList -IssueNumbersText $Arg1

        # Resolve metadata ONCE (#555): this is the whole point of the batch
        # command over N `status` calls, each of which re-resolves all three.
        $projectId = Get-ProjectIdLive
        $statusField = Get-StatusFieldLive
        $optionId = Resolve-BoardStatusOptionId -StatusField $statusField -StatusName $statusName
        $items = Get-ItemsLive

        $resolution = Resolve-BoardBatchItems -ItemsResult $items -IssueNumbers $issueNumbers

        foreach ($missingIssue in $resolution.Missing) {
            Write-Warning "#$missingIssue is not on project $ProjectNumber. Skipped (use 'add' first)."
        }

        $editFailures = @()
        foreach ($found in $resolution.Found) {
            gh project item-edit --id $found.ItemId --field-id $statusField.FieldId --project-id $projectId --single-select-option-id $optionId | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "#$($found.IssueNumber) ($($found.Title)): gh project item-edit failed (exit $LASTEXITCODE). Skipped, continuing batch."
                $editFailures += $found.IssueNumber
                continue
            }
            Write-Host "#$($found.IssueNumber) ($($found.Title)) -> $statusName"
        }

        $editedCount = $resolution.Found.Count - $editFailures.Count
        Write-Host "status-batch: $editedCount edited, $($resolution.Missing.Count) missing, $($editFailures.Count) edit failure(s)."

        if ($resolution.Missing.Count -gt 0 -or $editFailures.Count -gt 0) { exit 1 }
        exit 0
    }
}
