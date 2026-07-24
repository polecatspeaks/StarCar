#requires -Version 7.4
# Envelope.psm1 -- extract a dispatch's outcome envelope from its report (Task B.1).
#
# WHY THE TRANSCRIPT, NOT A PAYLOAD FIELD (C2R1-M3): the SubagentStop payload carries
# agent_transcript_path (spec S2.3, design A1). The producer reads the last assistant
# message FROM that transcript and parses the fenced starcar-artifact envelope out of it.
# An earlier revision extracted from a `last_assistant_message` payload field the spec
# never blessed and a reviewer could not verify; the transcript is authoritative and the
# payload field is unused.
#
# Two functions, both returning a pscustomobject (the module family's shape, matching
# Artifact.psm1's Test-StarcarArtifact -> { Valid; Errors; Discoveries }; never a
# hashtable):
#   Get-LastAssistantText  -> { Text; Errors }
#   Get-StarcarEnvelope    -> { Found; Outcome; Findings; Abstract; Fault }
#
# The UTF8 read and torn-line discipline live in the one home, scripts/lib/TranscriptRead.ps1
# (#47, design D5). -Encoding UTF8 there is load-bearing, not decoration: pwsh's Get-Content is
# UTF-8 by default on 7.x, but stating it keeps the intent explicit and survives a floor change
# (the Land-Verdict.ps1 scar: an ANSI default silently mangled a transcript).

Set-StrictMode -Version Latest

# #47 (design D5): the UTF8 read + torn-line discipline now live in the one home,
# scripts/lib/TranscriptRead.ps1. Dot-sourced here so Get-LastAssistantText's module scope
# can call Read-JsonlObjects. $PSScriptRoot is scripts/, so lib/ is a sibling.
. (Join-Path $PSScriptRoot 'lib/TranscriptRead.ps1')

function Get-LastAssistantText {
    <#
      Returns the text of the LAST assistant message in a Claude Code JSONL transcript:
      the last line whose message.role == 'assistant', with its content[].text parts
      (type == 'text') joined. On an absent or unparseable transcript, Text is $null and
      Errors carries exactly one entry (never N) -- one fault per read, matching the
      board-level one-fault rule the rest of the harness uses.
    #>
    param([Parameter(Mandatory)] [string]$TranscriptPath)

    $errors = New-Object System.Collections.Generic.List[string]

    # #47 (D5): the one-home reader parses the jsonl with torn-line discipline and reports an
    # absent/unreadable file via Ok/Error (never a throw). This function keeps its OWN
    # one-fault-per-read contract: an absent file yields "not found", an unreadable file
    # "unreadable: ... (msg)" - the exact messages the reader emits, so no test text shifts.
    $read = Read-JsonlObjects -Path $TranscriptPath
    if (-not $read.Ok) {
        $errors.Add($read.Error)
        return [pscustomobject]@{ Text = $null; Errors = @($errors) }
    }

    $lastText = $null
    foreach ($obj in $read.Objects) {
        $msgProp = $obj.PSObject.Properties['message']
        if (-not $msgProp) { continue }
        $msg = $msgProp.Value

        $roleProp = $msg.PSObject.Properties['role']
        if (-not $roleProp -or $roleProp.Value -ne 'assistant') { continue }

        $contentProp = $msg.PSObject.Properties['content']
        if (-not $contentProp) { continue }
        $content = $contentProp.Value

        $text = ''
        if ($content -is [string]) {
            $text = $content
        } else {
            foreach ($item in $content) {
                $typeProp = $item.PSObject.Properties['type']
                $textProp = $item.PSObject.Properties['text']
                if ($typeProp -and $typeProp.Value -eq 'text' -and $textProp) {
                    $text += [string]$textProp.Value
                }
            }
        }
        $lastText = $text
    }

    if ($null -eq $lastText) {
        $errors.Add("no assistant message with text found in $TranscriptPath")
    }

    [pscustomobject]@{ Text = $lastText; Errors = @($errors) }
}

function Get-StarcarEnvelope {
    <#
      Parse the report's outcome envelope: a fenced block, info string starcar-artifact,
      carrying outcome, findings, abstract (spec S2.3) and - since #47 (design section 5.7) -
      an OPTIONAL `task-id` echoing the shop-minted dispatch id the brief carried. Faults,
      both landing with the body intact (S2.3):
        Fault = 'absent'    -> no fence at all (a brief failure)
        Fault = 'malformed' -> a fence exists but a required field is missing (a producer
                               failure)
        Fault = $null       -> Found, all three required fields present
      task-id is NON-required: its absence never makes the envelope malformed (a car that
      predates the #47 echo mandate still lands a clean returned record; the minted id just
      does not round-trip on that record). TaskId is $null when the line is absent.
      LAST fence wins when a report carries more than one block (repeat-envelope
      precedent, Land-Verdict.ps1's Get-ResultBlockForTask last-wins return -- the later
      notification is the current one).
      findings/abstract may span multiple lines: a value runs from its `key:` line until
      the next field key or the end of the block, and is preserved verbatim (LF-joined).
    #>
    param([Parameter(Mandatory)] [AllowEmptyString()] [string]$Text)

    $normalised = $Text -replace "`r`n", "`n"

    # Fenced blocks whose info string is exactly starcar-artifact. Leading whitespace on
    # the fence line is tolerated (markdown permits up to three spaces of indent); the
    # capture is the block body between the opening info line and the closing fence.
    $pattern = '(?ms)^[ \t]*```starcar-artifact[ \t]*\n(.*?)\n[ \t]*```[ \t]*$'
    $matchList = [regex]::Matches($normalised, $pattern)

    if ($matchList.Count -eq 0) {
        return [pscustomobject]@{
            Found = $false; Outcome = $null; Findings = $null; Abstract = $null; TaskId = $null; Fault = 'absent'
        }
    }

    # Last fence wins.
    $body = $matchList[$matchList.Count - 1].Groups[1].Value

    $fields = @{}
    $current = $null
    foreach ($line in ($body -split "`n")) {
        if ($line -match '^(task-id|outcome|findings|abstract):[ ]?(.*)$') {
            $current = $Matches[1]
            $fields[$current] = $Matches[2]
        } elseif ($current) {
            $fields[$current] += "`n" + $line
        }
    }

    $outcome  = if ($fields.ContainsKey('outcome'))  { $fields['outcome'].TrimEnd() }  else { $null }
    $findings = if ($fields.ContainsKey('findings')) { $fields['findings'].TrimEnd() } else { $null }
    $abstract = if ($fields.ContainsKey('abstract')) { $fields['abstract'].TrimEnd() } else { $null }
    $taskId   = if ($fields.ContainsKey('task-id'))  { $fields['task-id'].TrimEnd() }  else { $null }

    # A fence with a missing (or empty) required field is malformed, not found: the body
    # is present but does not carry the three payloads the record needs. task-id is not in
    # this completeness test (it is the #47 optional echo, not a required payload).
    $complete = -not (
        [string]::IsNullOrEmpty($outcome) -or
        [string]::IsNullOrEmpty($findings) -or
        [string]::IsNullOrEmpty($abstract)
    )

    [pscustomobject]@{
        Found    = [bool]$complete
        Outcome  = $outcome
        Findings = $findings
        Abstract = $abstract
        TaskId   = if ([string]::IsNullOrEmpty($taskId)) { $null } else { $taskId }
        Fault    = if ($complete) { $null } else { 'malformed' }
    }
}

Export-ModuleMember -Function Get-LastAssistantText, Get-StarcarEnvelope
