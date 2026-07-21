# Board.psm1 -- pure parsing/lookup helpers for scripts/board.ps1 (#349 item 3).
#
# The project id, the Status field id, and its option ids are NEVER hardcoded
# here: they drifted once already since Project 5 was created, so board.ps1
# always re-resolves them at runtime via `gh project view` / `gh project
# field-list`. These functions only parse that already-fetched JSON -- no
# network calls, no gh invocation -- so Pester can exercise them with fixture
# data and no rig, token, or live board required.
#
# ASCII-only on purpose: PS 5.1 reads BOM-less files as ANSI and mis-decodes
# non-ASCII punctuation (rig finding 2026-06-12).

Set-StrictMode -Version Latest

function Get-BoardStatusField {
    <#
      Extracts the Status single-select field's id and its name -> optionId
      map from `gh project field-list <n> --owner <o> --format json` output.
    #>
    param([Parameter(Mandatory)] [object]$FieldsResult)

    $statusField = $FieldsResult.fields | Where-Object {
        $_.name -eq 'Status' -and $_.type -eq 'ProjectV2SingleSelectField'
    } | Select-Object -First 1

    if (-not $statusField) {
        $names = ($FieldsResult.fields | ForEach-Object { $_.name }) -join ', '
        throw "No 'Status' single-select field found on the project. Field names present: $names"
    }

    $options = @{}
    foreach ($opt in $statusField.options) {
        $options[$opt.name] = $opt.id
    }

    [pscustomobject]@{
        FieldId = $statusField.id
        Options = $options
    }
}

function Resolve-BoardStatusOptionId {
    <#
      Case-sensitive match against the LIVE options (the five known values are
      Backlog/Todo/In Progress/In Review/Done, but this never hardcodes that
      list -- it only validates against whatever the field actually has).
    #>
    param(
        [Parameter(Mandatory)] [object]$StatusField,
        [Parameter(Mandatory)] [string]$StatusName
    )

    if ($StatusField.Options.ContainsKey($StatusName)) {
        return $StatusField.Options[$StatusName]
    }

    $valid = ($StatusField.Options.Keys | Sort-Object) -join ', '
    throw "Unknown status '$StatusName'. Valid values: $valid"
}

function Find-BoardItemForIssue {
    <#
      Finds the project item for a given issue number from
      `gh project item-list <n> --owner <o> --format json --limit 500` output.
      Returns $null (not a throw) when absent -- callers decide whether that
      means "not on the board yet" (add) or a hard error (status/top/after).
    #>
    param(
        [Parameter(Mandatory)] [object]$ItemsResult,
        [Parameter(Mandatory)] [int]$IssueNumber
    )

    $match = $ItemsResult.items | Where-Object { $_.content.number -eq $IssueNumber } | Select-Object -First 1
    if (-not $match) { return $null }

    [pscustomobject]@{
        ItemId = $match.id
        Title  = $match.content.title
        # gh omits the status property entirely on items with no status set
        # (2026-07-12 live failure under StrictMode) - read it defensively.
        Status = Get-PropertyOrNull -Object $match -Name 'status'
        Url    = $match.content.url
    }
}

function Get-PropertyOrNull {
    # StrictMode-safe property read: gh's JSON omits unset fields (e.g. status
    # on a freshly added board item), and $obj.missing throws under StrictMode.
    param(
        [Parameter(Mandatory)] [object]$Object,
        [Parameter(Mandatory)] [string]$Name
    )

    $prop = $Object.PSObject.Properties[$Name]
    if ($null -eq $prop) { return $null }
    return $prop.Value
}

function Format-BoardListLine {
    <#
      One line per item: "#<n> [<status>] <title>". Works for both the plain
      item objects returned by item-list and the normalized objects returned
      by Find-BoardItemForIssue (falls back to .title/.Title either way).
    #>
    param([Parameter(Mandatory)] [object]$Item)

    $content = Get-PropertyOrNull -Object $Item -Name 'content'
    $number = if ($content) { Get-PropertyOrNull -Object $content -Name 'number' } else { $null }
    if ($null -eq $number) { $number = Get-PropertyOrNull -Object $Item -Name 'Number' }

    $status = Get-PropertyOrNull -Object $Item -Name 'status'
    if (-not $status) { $status = Get-PropertyOrNull -Object $Item -Name 'Status' }
    if (-not $status) { $status = '(no status)' }

    $title = Get-PropertyOrNull -Object $Item -Name 'title'
    if (-not $title) {
        if ($content) { $title = Get-PropertyOrNull -Object $content -Name 'title' }
        if (-not $title) { $title = Get-PropertyOrNull -Object $Item -Name 'Title' }
    }

    '#{0} [{1}] {2}' -f $number, $status, $title
}

function ConvertFrom-BoardIssueNumberList {
    <#
      #555: parses status-batch's "<n1,n2,...>" argument into an int array.
      Pure parsing, no gh call -- unit-tested with no rig/token needed. Throws
      (does not silently skip) on a malformed token: an empty string, an
      empty token from a dangling/doubled comma, or a non-numeric entry are
      all input mistakes the caller should fix before any gh call is made,
      unlike a per-item "not on the board" miss (Resolve-BoardBatchItems),
      which is reported, not fatal.
    #>
    param([Parameter(Mandatory)] [AllowEmptyString()] [string]$IssueNumbersText)

    if ([string]::IsNullOrWhiteSpace($IssueNumbersText)) {
        throw 'No issue numbers given. Expected a comma-separated list, e.g. "27,349,352".'
    }

    $tokens = $IssueNumbersText -split ','
    $numbers = foreach ($token in $tokens) {
        $trimmed = $token.Trim()
        if ([string]::IsNullOrEmpty($trimmed)) {
            throw "Empty issue number token found in '$IssueNumbersText' (a dangling or doubled comma)."
        }

        $parsed = 0
        if (-not [int]::TryParse($trimmed, [ref]$parsed)) {
            throw "'$trimmed' is not a valid issue number in '$IssueNumbersText'."
        }
        $parsed
    }

    @($numbers)
}

function Resolve-BoardBatchItems {
    <#
      #555: status-batch resolves the item list ONCE (Get-ItemsLive, board.ps1)
      then looks up every issue number in the batch against that single
      already-fetched result. An issue not on the board is a per-item miss,
      reported in .Missing, never a throw -- the rest of the batch still
      needs to run so one typo/stale issue number doesn't sink N-1 good edits.
    #>
    param(
        [Parameter(Mandatory)] [object]$ItemsResult,
        [Parameter(Mandatory)] [int[]]$IssueNumbers
    )

    $found = @()
    $missing = @()

    foreach ($issueNumber in $IssueNumbers) {
        $item = Find-BoardItemForIssue -ItemsResult $ItemsResult -IssueNumber $issueNumber
        if ($null -eq $item) {
            $missing += $issueNumber
            continue
        }
        $found += [pscustomobject]@{
            IssueNumber = $issueNumber
            ItemId      = $item.ItemId
            Title       = $item.Title
            Status      = $item.Status
            Url         = $item.Url
        }
    }

    [pscustomobject]@{
        Found   = @($found)
        Missing = @($missing)
    }
}

Export-ModuleMember -Function Get-BoardStatusField, Resolve-BoardStatusOptionId, Find-BoardItemForIssue, Format-BoardListLine, ConvertFrom-BoardIssueNumberList, Resolve-BoardBatchItems
