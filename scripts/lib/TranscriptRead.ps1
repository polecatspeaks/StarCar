# scripts/lib/TranscriptRead.ps1 - the ONE transcript-read home (#47, design D5).
#
# WHY THIS FILE: the UTF8 jsonl transcript read lived in TWO homes at base - Envelope.psm1
# (Get-LastAssistantText, the producer's Claude reader) and Land-Verdict.ps1
# (Get-TranscriptLines) - each repeating the SAME load-bearing `-Encoding UTF8` idiom and its
# ANSI-mangling scar note (a section sign silently becoming two characters, exposed only by the
# SHA-256). That verbatim duplication is a Law 6 smell; this file is the one home both consume.
#
# NEVER-THROW-ON-FILE-STATE: an absent or unreadable file is reported through Ok/Error, not an
# exception, so each caller keeps its OWN missing-file policy without this reader dictating it -
# the producer degrades to a named fault, Land-Verdict throws its own operator-facing message.
#
# TORN-LINE DISCIPLINE (design DR-7, D3 runner contract): a jsonl transcript can be read
# mid-write, so its LAST line may be torn. Read-JsonlObjects parses line-by-line and SKIPS an
# unparseable line rather than throwing. The same read primitive serves a Copilot events.jsonl
# (a jsonl is a jsonl); interpreting an events.jsonl's per-runtime record SHAPE is deliberately
# out of scope here - that OBSERVED shape is absent from the worktree (see the adapter README's
# honest-boundary note), so only the READ discipline, not the events parse, is unified today.

function Read-TranscriptLines {
    <#
      Reads a transcript file as UTF8 lines. Returns a pscustomobject:
        Lines : [string[]] the raw lines (empty on any read failure)
        Ok    : [bool]     $true only when the file was present and read
        Error : [string]   $null on success, else one fault message (one per read)
      -Encoding UTF8 is load-bearing (see the ANSI-mangling note above), not decoration.
    #>
    param([Parameter(Mandatory)] [AllowEmptyString()] [string]$Path)

    if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) {
        return [pscustomobject]@{ Lines = @(); Ok = $false; Error = "transcript not found: $Path" }
    }
    try {
        $lines = Get-Content -LiteralPath $Path -Encoding UTF8 -ErrorAction Stop
        return [pscustomobject]@{ Lines = @($lines); Ok = $true; Error = $null }
    } catch {
        return [pscustomobject]@{ Lines = @(); Ok = $false; Error = "transcript unreadable: $Path ($($_.Exception.Message))" }
    }
}

function Read-JsonlObjects {
    <#
      Reads a jsonl transcript and returns its lines parsed to objects, one per WELL-FORMED
      line. A line that will not ConvertFrom-Json (the torn trailing line of a mid-write
      transcript) is skipped - never a throw. Returns a pscustomobject:
        Objects : [object[]] the parsed objects, in file order (empty on any read failure)
        Ok      : [bool]     mirrors the underlying read (present+readable)
        Error   : [string]   the read error, if any
    #>
    param([Parameter(Mandatory)] [AllowEmptyString()] [string]$Path)

    $read = Read-TranscriptLines -Path $Path
    if (-not $read.Ok) {
        return [pscustomobject]@{ Objects = @(); Ok = $false; Error = $read.Error }
    }
    $objects = New-Object System.Collections.Generic.List[object]
    foreach ($line in $read.Lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        $obj = $null
        try { $obj = $line | ConvertFrom-Json } catch { continue }  # torn line: skip, never throw
        $objects.Add($obj)
    }
    [pscustomobject]@{ Objects = $objects.ToArray(); Ok = $true; Error = $null }
}
