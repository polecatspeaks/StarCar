# Pester tests for Board.psm1 (#349 item 3): pure parsing/lookup logic for
# scripts/board.ps1, runnable with no rig, no gh token, no live board.

BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..\Board.psm1') -Force
}

Describe 'Get-BoardStatusField' {
    It 'extracts the Status field id and option name to id map' {
        $fields = [pscustomobject]@{
            fields = @(
                [pscustomobject]@{ id = 'F1'; name = 'Title'; type = 'ProjectV2Field' }
                [pscustomobject]@{
                    id      = 'F2'
                    name    = 'Status'
                    type    = 'ProjectV2SingleSelectField'
                    options = @(
                        [pscustomobject]@{ id = 'o1'; name = 'Backlog' }
                        [pscustomobject]@{ id = 'o2'; name = 'Todo' }
                        [pscustomobject]@{ id = 'o3'; name = 'Done' }
                    )
                }
            )
        }

        $statusField = Get-BoardStatusField -FieldsResult $fields

        $statusField.FieldId | Should -Be 'F2'
        $statusField.Options['Todo'] | Should -Be 'o2'
        $statusField.Options['Done'] | Should -Be 'o3'
    }

    It 'throws a clear error naming the fields present when no Status field exists' {
        $fields = [pscustomobject]@{ fields = @([pscustomobject]@{ id = 'F1'; name = 'Title'; type = 'ProjectV2Field' }) }
        { Get-BoardStatusField -FieldsResult $fields } | Should -Throw '*Status*'
    }
}

Describe 'Resolve-BoardStatusOptionId' {
    BeforeEach {
        $script:statusField = [pscustomobject]@{
            FieldId = 'F2'
            Options = @{ Backlog = 'o1'; Todo = 'o2'; 'In Progress' = 'o3'; 'In Review' = 'o4'; Done = 'o5' }
        }
    }

    It 'resolves a known status name to its option id' {
        Resolve-BoardStatusOptionId -StatusField $statusField -StatusName 'In Progress' | Should -Be 'o3'
    }

    It 'throws listing valid values for an unknown status' {
        { Resolve-BoardStatusOptionId -StatusField $statusField -StatusName 'Blocked' } | Should -Throw '*Backlog*'
    }
}

Describe 'Find-BoardItemForIssue' {
    BeforeEach {
        $script:items = [pscustomobject]@{
            items = @(
                [pscustomobject]@{ id = 'I1'; status = 'Todo'; title = 'First issue'; content = [pscustomobject]@{ number = 27; title = 'First issue'; url = 'https://x/27' } }
                [pscustomobject]@{ id = 'I2'; status = 'Done'; title = 'Second issue'; content = [pscustomobject]@{ number = 349; title = 'Second issue'; url = 'https://x/349' } }
            )
        }
    }

    It 'finds the item id, title, and status for a known issue number' {
        $found = Find-BoardItemForIssue -ItemsResult $items -IssueNumber 349
        $found.ItemId | Should -Be 'I2'
        $found.Status | Should -Be 'Done'
        $found.Title | Should -Be 'Second issue'
    }

    It 'returns null for an issue not on the board' {
        Find-BoardItemForIssue -ItemsResult $items -IssueNumber 999 | Should -BeNullOrEmpty
    }
}

Describe 'Format-BoardListLine' {
    It 'formats issue number, status, and title on one line' {
        $item = [pscustomobject]@{ status = 'In Progress'; title = 'Fix the thing'; content = [pscustomobject]@{ number = 42 } }
        Format-BoardListLine -Item $item | Should -Be '#42 [In Progress] Fix the thing'
    }

    It 'shows a placeholder when status is absent' {
        $item = [pscustomobject]@{ status = $null; title = 'Draft item'; content = [pscustomobject]@{ number = 7 } }
        Format-BoardListLine -Item $item | Should -Match '\(no status\)'
    }
}

Describe 'Statusless items (StrictMode regression, 2026-07-12 live failure)' {
    # gh project item-list omits the status property entirely on items with no
    # status set (e.g. freshly auto-added issues). Under Set-StrictMode that
    # made Find-BoardItemForIssue and Format-BoardListLine throw
    # PropertyNotFoundException instead of handling the item.
    It 'Find-BoardItemForIssue returns the item with a null Status instead of throwing' {
        $items = [pscustomobject]@{
            items = @(
                [pscustomobject]@{
                    id      = 'ITEM1'
                    content = [pscustomobject]@{ number = 352; title = 'Statusless'; url = 'u' }
                }
            )
        }

        $found = Find-BoardItemForIssue -ItemsResult $items -IssueNumber 352

        $found.ItemId | Should -Be 'ITEM1'
        $found.Status | Should -BeNullOrEmpty
    }

    It 'Format-BoardListLine renders (no status) instead of throwing' {
        $item = [pscustomobject]@{
            id      = 'ITEM1'
            content = [pscustomobject]@{ number = 352; title = 'Statusless'; url = 'u' }
        }

        Format-BoardListLine -Item $item | Should -Match '\(no status\)'
    }
}

Describe 'ConvertFrom-BoardIssueNumberList' {
    # #555: status-batch's comma list, e.g. "27,349,352". Pure parsing, no gh
    # call involved, so it is fully unit-testable here.
    It 'parses a simple comma-separated list into an int array' {
        ConvertFrom-BoardIssueNumberList -IssueNumbersText '27,349,352' | Should -Be @(27, 349, 352)
    }

    It 'trims whitespace around each entry' {
        ConvertFrom-BoardIssueNumberList -IssueNumbersText ' 27, 349 ,352 ' | Should -Be @(27, 349, 352)
    }

    It 'parses a single issue number with no commas' {
        ConvertFrom-BoardIssueNumberList -IssueNumbersText '42' | Should -Be @(42)
    }

    It 'throws a clear error naming the bad entry when a token is not a number' {
        { ConvertFrom-BoardIssueNumberList -IssueNumbersText '27,abc,352' } | Should -Throw '*abc*'
    }

    It 'throws a clear error on an empty or blank string' {
        { ConvertFrom-BoardIssueNumberList -IssueNumbersText '' } | Should -Throw '*issue number*'
        { ConvertFrom-BoardIssueNumberList -IssueNumbersText '   ' } | Should -Throw '*issue number*'
    }

    It 'throws a clear error on a dangling comma (empty token between separators)' {
        { ConvertFrom-BoardIssueNumberList -IssueNumbersText '27,,352' } | Should -Throw '*empty*'
    }
}

Describe 'Resolve-BoardBatchItems' {
    # #555: status-batch resolves the item list ONCE, then looks up N issue
    # numbers against it. A miss (issue not on the board) is reported per item,
    # not fatal to the batch -- the caller still gets every item it CAN edit.
    BeforeEach {
        $script:items = [pscustomobject]@{
            items = @(
                [pscustomobject]@{ id = 'I1'; status = 'Todo'; title = 'First'; content = [pscustomobject]@{ number = 27; title = 'First'; url = 'https://x/27' } }
                [pscustomobject]@{ id = 'I2'; status = 'Done'; title = 'Second'; content = [pscustomobject]@{ number = 349; title = 'Second'; url = 'https://x/349' } }
            )
        }
    }

    It 'resolves every found issue and reports none missing when all are on the board' {
        $result = Resolve-BoardBatchItems -ItemsResult $items -IssueNumbers @(27, 349)
        $result.Found.Count | Should -Be 2
        $result.Found[0].IssueNumber | Should -Be 27
        $result.Found[0].ItemId | Should -Be 'I1'
        $result.Found[1].IssueNumber | Should -Be 349
        $result.Missing | Should -BeNullOrEmpty
    }

    It 'reports a missing issue without throwing, and still resolves the rest of the batch' {
        $result = Resolve-BoardBatchItems -ItemsResult $items -IssueNumbers @(27, 999, 349)
        $result.Found.Count | Should -Be 2
        $result.Found.IssueNumber | Should -Be @(27, 349)
        $result.Missing | Should -Be @(999)
    }

    It 'reports every issue missing when none are on the board, without throwing' {
        $result = Resolve-BoardBatchItems -ItemsResult $items -IssueNumbers @(1, 2)
        $result.Found | Should -BeNullOrEmpty
        $result.Missing | Should -Be @(1, 2)
    }
}
