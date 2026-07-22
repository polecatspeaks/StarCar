#requires -Version 7.4
# Artifact.psm1 -- this shop's PowerShell implementation of the language-neutral
# starcar-artifact/1 JSON Schema (conductor ruling R1v2, docs/plans/2026-07-22-
# harness-car1-plan.md).
#
# WHY A SCHEMA VALIDATOR AND A RECOGNITION-VOCABULARY CHECKER ARE ONE FUNCTION, NOT TWO:
# spec S3.2 requires an unrecognised `kind` or `outcome` value to be a DISCOVERY, not a
# validation failure -- so `kind`/`outcome` are typed `string` in the schema (never
# `enum`), and recognition against the vocabulary files in schema/vocab/ is REPORTING
# layered on top of schema validation, never a second gate that can fail an artifact the
# schema already accepted.
#
# `Test-Json -Schema` (draft 2020-12) is the validation engine (ruling R1v2; measured
# present on pwsh 7.6.3, absent on Windows PowerShell 5.1.26100 -- this module is the new
# module family the runtime floor applies to). No hand-rolled second copy of the schema's
# validation logic (Law 6).

Set-StrictMode -Version Latest

function Test-StarcarArtifact {
    <#
      Validates one artifact object against the starcar-artifact/1 schema and reports
      recognition-vocabulary discoveries. Returns [pscustomobject]@{ Valid; Errors;
      Discoveries } -- pscustomobject, matching Board.psm1:188-191's pattern (structural,
      opened at base), never a hashtable.
    #>
    param(
        [Parameter(Mandatory)] [object]$InputObject,
        [Parameter(Mandatory)] [string]$SchemaPath,
        [string]$VocabDir
    )

    if (-not $VocabDir) {
        $VocabDir = Join-Path (Split-Path $SchemaPath -Parent) 'vocab'
    }

    $errors = New-Object System.Collections.Generic.List[string]
    $discoveries = New-Object System.Collections.Generic.List[string]

    # --- schema validation ------------------------------------------------------
    $schemaJson = Get-Content $SchemaPath -Raw -Encoding UTF8
    $json = $InputObject | ConvertTo-Json -Depth 20
    $schemaErrors = $null
    $valid = Test-Json -Json $json -Schema $schemaJson -ErrorVariable schemaErrors -ErrorAction SilentlyContinue
    if (-not $valid) {
        foreach ($e in $schemaErrors) { $errors.Add($e.Exception.Message) }
        if ($errors.Count -eq 0) { $errors.Add('schema validation failed (no detail available)') }
    }

    # --- vocabulary recognition (reporting, never a validation gate) ------------
    # An unreadable vocab directory/file is ONE board-level fault (spec S3.2: one
    # fault, never N per-lane faults), not one per vocabulary file that happens to be
    # missing.
    $vocabReadFailed = $false
    $kindsPath = Join-Path $VocabDir 'kinds.json'
    $outcomesPath = Join-Path $VocabDir 'outcomes.json'

    $kindValues = @()
    $outcomeValues = @()
    try {
        $kindValues = (Get-Content $kindsPath -Raw -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json).values
        $outcomeValues = (Get-Content $outcomesPath -Raw -Encoding UTF8 -ErrorAction Stop | ConvertFrom-Json).values
    } catch {
        $vocabReadFailed = $true
    }

    if ($vocabReadFailed) {
        $errors.Add("vocab: could not read recognition vocabulary files from '$VocabDir'")
    } else {
        $kindProp = $InputObject.PSObject.Properties['kind']
        if ($kindProp -and $kindValues -notcontains $kindProp.Value) {
            $discoveries.Add("kind: $($kindProp.Value)")
        }
        $outcomeProp = $InputObject.PSObject.Properties['outcome']
        if ($outcomeProp -and $outcomeValues -notcontains $outcomeProp.Value) {
            $discoveries.Add("outcome: $($outcomeProp.Value)")
        }
    }

    [pscustomobject]@{
        Valid       = [bool]$valid
        Errors      = @($errors)
        Discoveries = @($discoveries)
    }
}

Export-ModuleMember -Function Test-StarcarArtifact
