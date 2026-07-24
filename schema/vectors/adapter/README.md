# Adapter conformance vectors - the family-agnostic intake contract

Status: Current

**What this directory is** (#47 design D3, `docs/design/2026-07-24-family-agnostic-harness-design.md`):
the language-neutral authority on what each runtime family's dispatch-lifecycle EVENTS
must yield as store RECORDS. Sibling to `schema/vectors/fold/` (whose README,
`schema/vectors/README.md`, this one follows in shape): declarative input -> expected
output, OBSERVED vs DESIGN-MANDATED provenance stated per fixture, one runner per language.
Where the fold vectors pin how records COLLAPSE, these pin how payloads BECOME records -
the producer's intake seam (`scripts/Produce-Artifact.ps1`, D4).

The adapter contract exists because the repo defines the contract and runtimes adapt to
the repo (Law 7), not the reverse. Identity, subject derivation, and the visible-skip
discipline are FORMAT, not prose (design §0's split); they live HERE as executable data.

## Vector shape (`adapter/*.json`)

```json
{
  "name": "kebab-case-id",
  "description": "what this vector pins + the design/spec obligation + PROVENANCE line",
  "runtime": "claude | copilot | unknown",
  "mode": "a | b | none",
  "kind": "dispatched | returned",
  "input": {
    "payload": { "the hook payload object, exactly as the runtime delivers it on stdin" },
    "transcript": ["OPTIONAL array of JSONL lines; the runner writes them to a temp file",
                   "and substitutes the <transcript> placeholder in the payload's",
                   "agent_transcript_path (Claude) / transcript_path (Copilot) key"]
  },
  "expected": {
    "record": { "field": "value", "...": "each named field must deep-equal the emitted record" }
    // OR, mutually exclusive:
    "skip": { "stderr_contains": ["key", "..."] }  // NO record; stderr names each present key
  }
}
```

`subject_basis` is the disclosed axis (design D2): `runtime-id` (mode b - the runtime's
own stable pairing id) or `minted-id` (mode a - the shop id carried in the launch label
or the return envelope's `task-id`). A record vector pins it explicitly.

## Runner contract (implemented per-language, NOT here)

Implemented for pwsh in `scripts/tests/AdapterVectors.Tests.ps1`:

1. If `input.transcript` is present, materialise it into a temp `.jsonl` and substitute
   the `<transcript>` placeholder in whichever payload key holds it.
2. Feed `input.payload` on stdin to `scripts/Produce-Artifact.ps1 -Kind <vector.kind>`,
   against a throwaway git repo/store, invoked as a REAL child pwsh process (so a
   visible-skip stderr line is captured exactly as the SubagentStop/PostToolUse hook sees it).
3. For `expected.record`: exactly one record was written and each named field deep-equals.
   For `expected.skip`: NO record was written AND stderr names each `stderr_contains` key.
   `at`, `integrity`, `normalisation`, `producer` are environmental/derived and are not
   asserted by a vector unless the vector names them.

## Provenance rule (per fixture, OBSERVED or DESIGN-MANDATED)

Same discipline as the fold README. OBSERVED = the landed producer already emits this and
the vector locks it; DESIGN-MANDATED = the landed producer is known-wrong/absent for this
case and the vector lands red-first with the D4 fix.

| Vector | Runtime / mode | Provenance | Pins |
|---|---|---|---|
| `claude-launch-runtime-id.json` | claude / b | DESIGN-MANDATED (subject=agentId is OBSERVED; the `subject_basis` disclosure is new #47 work) | A Claude launch yields `dispatched` with subject = the runtime pairing UUID + `subject_basis: runtime-id`. Claude launch shape OBSERVED from `scripts/tests/fixtures/payloads/launch-car.json`. |
| `copilot-launch-minted-from-name.json` | copilot / a | DESIGN-MANDATED (the landed producer reads `tool_response.agentId`, absent from the compat launch payload, and throws) | A Copilot compat launch (Task->Agent, snake_case) yields `dispatched` with subject = the shop-minted id in `tool_input.name` + `subject_basis: minted-id`. Copilot launch keyset OBSERVED and quoted in `docs/design/2026-07-24-dual-runtime-harness-design.md` §3b-8 (the landed fossil of the measurement; the raw capture `.claude/probe-logs/post-task.jsonl` is gitignored runtime output, not in the tree). |
| `claude-stop-envelope-taskid.json` | claude / b | DESIGN-MANDATED (the landed producer parses no `task-id` and writes no `task_id`/`subject_basis`) | A Claude stop whose report envelope carries `task-id: X` yields `returned` pairing by subject=agent_id AND recording X as `task_id` (the #47 §5.7 echo). |
| `claude-stop-no-envelope-absent.json` | claude / b | OBSERVED (the landed producer already mints `envelope: absent` on a fenceless report) | A stop with no envelope yields `returned` with `envelope: absent`, `outcome: error`, raw report retained in findings (Law 4). |
| `unrecognisable-payload-skip.json` | unknown / none | DESIGN-MANDATED (the landed producer exits 0 SILENTLY on a shape it does not recognise) | A payload with neither `agent_type` nor `agent_name` writes NO record and emits a VISIBLE skip on stderr naming the present keys. |

## Where the STATEFUL refusal guard is proven (DR-11, resolved by the car)

The duplicate-`dispatched` refusal guard (design D2/DR-9, Q2 keep-first) is NOT an adapter
vector. Round-2 reviewer finding DR-11 is correct: the guard must READ THE STORE to know a
subject "already has an un-superseded `dispatched` record", so it is STATEFUL, and these
adapter vectors are stateless payload->record fixtures with no `input.records` store-state
field. Its red-first proof is therefore rehomed to **`scripts/tests/Producer.Tests.ps1`**
(the two `#47 DR-9` / `#47 Q2 boundary` cases), which builds a real store, dispatches the
same subject twice, and asserts the second is refused loud-and-keep-first, plus that a
re-dispatch after the first has RETURNED (superseded) is NOT refused (the Q2 boundary). The
post-return duplicate-subject EXPOSURE is a fold-tier concern, pinned by
`schema/vectors/fold/duplicate-subject-two-dispatched.json` (DR-10). This resolution is
recorded in the design at §9c `[DR-11, resolved by car]`.

## Scope note - Copilot returned/stop (honest boundary)

The Copilot LAUNCH path (mode a) is pinned and green. The Copilot STOP path's subject comes
from the envelope `task-id` (the compat stop payload's `agent_name` is the agent TYPE, not a
pairing key - §3b-5), and the producer resolves it that way. A Copilot returned record whose
report carries NO envelope task-id at stop time cannot be paired from the stop payload alone;
the superseded design's events.jsonl join (`toolCallId -> arguments.name`, §3b-8) is the
enrichment path for that corner. That events.jsonl extraction branch is NOT pinned by a
vector here: the OBSERVED Copilot events.jsonl shape lives only in the gitignored, absent
`.claude/probe-logs/` capture, and inventing it would violate "use OBSERVED shapes, never
invented ones". It is deferred as named work, not silently skipped.
