#requires -Version 7.4
# Plan task 2.2 (docs/plans/2026-07-23-yard-board-plan.md S3): the wire snapshot
# schema (schema/yard-snapshot.schema.json) gains $defs.trainsPayload,
# $defs.gatesPayload, $defs.dispatchesPayload per spec YB-5's field lists
# (docs/specs/2026-07-23-yard-board-spec.md S3). Each $def is extracted standalone
# (no internal $ref - self-contained so it can be Test-Json'd on its own) and
# validated with Test-Json (draft 2020-12), the same engine Test-StarcarArtifact
# uses (Law 6 - no hand-rolled second validation path).

BeforeDiscovery {
    $repoRoot = (git rev-parse --show-toplevel)
}

Describe 'Wire snapshot payload $defs (YB-5)' {
    BeforeAll {
        $script:RepoRoot = (git rev-parse --show-toplevel)
        $script:SchemaPath = Join-Path $script:RepoRoot 'schema/yard-snapshot.schema.json'
        $script:SchemaDoc = Get-Content $script:SchemaPath -Raw -Encoding UTF8 | ConvertFrom-Json -AsHashtable

        function Test-PayloadDef {
            <#
              Extracts schema/yard-snapshot.schema.json's $defs.<DefName>, wraps it as a
              standalone draft 2020-12 schema document, and Test-Json's the sample against
              it. Returns $true/$false; throws (surfacing as a Pester failure with a clear
              reason) if the named $def does not exist, so a red test never silently passes
              on a typo'd def name.

              #69/#71 fix cycle round 2 (MINOR-R1-2): the wrapped document now also carries
              the FULL sibling `$defs` map (not just the one named def), so an inner `$ref`
              to another def (e.g. `$defs.dispatchSupersededItem`, added this round) still
              resolves once extracted standalone. Before this fix, any def containing a
              `$ref` to a sibling def would silently fail here (Test-Json -ErrorAction
              SilentlyContinue swallows the resolution error, returning $false with no
              message) - the two new failures THIS round surfaced were exactly that: a
              latent gap in this helper, not a defect in the schema's use of `$ref` (the
              same `$ref` idiom the FULL schema document already uses throughout, compiled
              whole everywhere else - probe-yard-snapshot.mjs, board/web/js/validate.js -
              which is why only this ONE fragment-extracting helper ever saw it).
            #>
            param(
                [Parameter(Mandatory)] [string]$DefName,
                [Parameter(Mandatory)] [string]$SampleJson
            )
            $defs = $script:SchemaDoc['$defs']
            if (-not $defs -or -not $defs.ContainsKey($DefName)) {
                throw "schema/yard-snapshot.schema.json has no `$defs.$DefName yet"
            }
            $subSchema = [ordered]@{ '$schema' = 'https://json-schema.org/draft/2020-12/schema'; '$defs' = $defs }
            foreach ($key in $defs[$DefName].Keys) {
                $subSchema[$key] = $defs[$DefName][$key]
            }
            $subSchemaJson = $subSchema | ConvertTo-Json -Depth 20
            Test-Json -Json $SampleJson -Schema $subSchemaJson -ErrorAction SilentlyContinue
        }
    }

    Context 'trainsPayload' {
        It 'a conforming sample validates' {
            $sample = @'
{
  "trains": [
    {
      "id": "train:board-v0",
      "title": "The yard board train",
      "cars": [
        { "subject": "car-1", "role": "car", "state": "returned", "at": "2026-07-23T10:00:00Z", "outcome": "done" }
      ],
      "declaredNotObserved": []
    }
  ]
}
'@
            Test-PayloadDef -DefName 'trainsPayload' -SampleJson $sample | Should -BeTrue
        }

        It 'a train missing a required member field (title) fails' {
            $sample = @'
{
  "trains": [
    {
      "id": "train:board-v0",
      "cars": [
        { "subject": "car-1", "role": "car", "state": "returned", "at": "2026-07-23T10:00:00Z" }
      ],
      "declaredNotObserved": []
    }
  ]
}
'@
            Test-PayloadDef -DefName 'trainsPayload' -SampleJson $sample | Should -BeFalse -Because 'a train entry without title must fail (YB-5: trains[]{ id, title, cars[] })'
        }

        It 'a car entry without subject fails' {
            $sample = @'
{
  "trains": [
    {
      "id": "train:board-v0",
      "title": "The yard board train",
      "cars": [
        { "role": "car", "state": "returned", "at": "2026-07-23T10:00:00Z" }
      ],
      "declaredNotObserved": []
    }
  ]
}
'@
            Test-PayloadDef -DefName 'trainsPayload' -SampleJson $sample | Should -BeFalse -Because 'a car entry without subject must fail (YB-5: cars[]{ subject, role, gate?, state, at, outcome?, superseded? })'
        }
    }

    Context 'gatesPayload' {
        It 'a conforming sample validates' {
            $sample = @'
{
  "gates": [
    { "name": "design-review round 4", "subject": "a184e26ee16e704ae", "outcome": "APPROVE", "at": "2026-07-23T10:00:00Z" }
  ]
}
'@
            Test-PayloadDef -DefName 'gatesPayload' -SampleJson $sample | Should -BeTrue
        }

        It 'a gates entry without verbatim outcome fails' {
            $sample = @'
{
  "gates": [
    { "name": "design-review round 4", "subject": "a184e26ee16e704ae", "at": "2026-07-23T10:00:00Z" }
  ]
}
'@
            Test-PayloadDef -DefName 'gatesPayload' -SampleJson $sample | Should -BeFalse -Because 'a gates entry without outcome must fail (YB-5: gates[]{ name, subject, outcome (VERBATIM), at })'
        }
    }

    Context 'dispatchesPayload' {
        It 'a conforming sample validates' {
            $sample = @'
{
  "dispatches": [
    { "subject": "car-1", "state": "returned", "at": "2026-07-23T10:00:00Z", "outcome": "done", "superseded": [], "assigned": true }
  ]
}
'@
            Test-PayloadDef -DefName 'dispatchesPayload' -SampleJson $sample | Should -BeTrue
        }

        It 'a dispatches entry without assigned (a required member field) fails' {
            $sample = @'
{
  "dispatches": [
    { "subject": "car-1", "state": "returned", "at": "2026-07-23T10:00:00Z", "outcome": "done" }
  ]
}
'@
            Test-PayloadDef -DefName 'dispatchesPayload' -SampleJson $sample | Should -BeFalse -Because 'a dispatches entry without assigned must fail (YB-5: dispatches[] mirrors the fold shape plus assigned: boolean per entry)'
        }
    }
}
