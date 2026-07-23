#requires -Version 7.4
# Envelope extraction (Task B.1). The producer's `returned` record obtains its outcome
# from the agent's report envelope, which the producer reads from the TRANSCRIPT at
# agent_transcript_path (spec S2.3 mechanism), never from an unblessed payload field
# (C2R1-M3). These tests exercise both halves of Envelope.psm1:
#   Get-StarcarEnvelope  - parse the fenced starcar-artifact block from report text
#   Get-LastAssistantText - pull the last assistant message text from a JSONL transcript

Describe 'Get-StarcarEnvelope' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        Import-Module (Join-Path $script:RepoRoot 'scripts/Envelope.psm1') -Force
    }

    It 'parses a present-and-valid envelope, multi-line abstract verbatim' {
        $text = @"
Some report body the reviewer wrote.

``````starcar-artifact
outcome: APPROVE
findings: one minor, folded.
abstract: First line of the abstract.
Second line, still the abstract.
Third and final line.
``````
"@
        $env = Get-StarcarEnvelope -Text $text
        $env.Found | Should -BeTrue
        $env.Fault | Should -Be $null
        $env.Outcome | Should -Be 'APPROVE'
        $env.Findings | Should -Be 'one minor, folded.'
        # verbatim multi-line: the exact three lines, joined by LF, nothing trimmed inside
        $env.Abstract | Should -Be "First line of the abstract.`nSecond line, still the abstract.`nThird and final line."
    }

    It 'reports an ABSENT envelope when no fence is present' {
        $env = Get-StarcarEnvelope -Text 'A report with no envelope block at all.'
        $env.Found | Should -BeFalse
        $env.Fault | Should -Be 'absent'
        $env.Outcome | Should -Be $null
    }

    It 'reports a MALFORMED envelope when the fence is present but a required field is missing' {
        $text = @"
``````starcar-artifact
findings: something
abstract: but there is no outcome line
``````
"@
        $env = Get-StarcarEnvelope -Text $text
        $env.Found | Should -BeFalse
        $env.Fault | Should -Be 'malformed'
    }

    It 'last fence wins when a report carries more than one envelope block' {
        $text = @"
``````starcar-artifact
outcome: REJECT
findings: first block
abstract: superseded block
``````

Then the agent corrected itself and re-emitted:

``````starcar-artifact
outcome: APPROVE
findings: second block
abstract: the winning block
``````
"@
        $env = Get-StarcarEnvelope -Text $text
        $env.Found | Should -BeTrue
        $env.Outcome | Should -Be 'APPROVE'
        $env.Abstract | Should -Be 'the winning block'
    }
}

Describe 'Get-LastAssistantText' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        Import-Module (Join-Path $script:RepoRoot 'scripts/Envelope.psm1') -Force
        $script:Transcript = Join-Path $script:RepoRoot 'scripts/tests/fixtures/payloads/transcript-car.jsonl'
    }

    It 'extracts an envelope end-to-end from a real-shaped JSONL transcript' {
        $r = Get-LastAssistantText -TranscriptPath $script:Transcript
        $r.Text | Should -Not -BeNullOrEmpty
        $r.Errors.Count | Should -Be 0
        $env = Get-StarcarEnvelope -Text $r.Text
        $env.Found | Should -BeTrue
        $env.Outcome | Should -Be 'APPROVE'
        $env.Abstract | Should -Be "Line one of the fixture abstract.`nLine two continues the summary.`nLine three closes it."
    }

    It 'returns $null text and exactly one error for an absent transcript file' {
        $r = Get-LastAssistantText -TranscriptPath (Join-Path $script:RepoRoot 'scripts/tests/fixtures/payloads/no-such-transcript.jsonl')
        $r.Text | Should -Be $null
        $r.Errors.Count | Should -Be 1
    }
}
