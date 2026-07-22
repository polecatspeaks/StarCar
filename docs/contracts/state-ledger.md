# State ledger

Status: Current

Copied from `docs/templates/state-ledger.md` (2026-07-22, dispatch harness Car 1, task
A.5). Answers BOTH questions the template asks - mutable process state, and derived
committed artifacts - per spec `docs/specs/2026-07-22-dispatch-harness-spec.md` S9 rows
1-2, which are Car 1's to instantiate.

## Header (keep arithmetic current)

Process state fields: 0. Derived committed artifact rows: 1 (no instance committed yet).

(2026-07-22, dispatch harness Car 1, task A.5): ledger created. Process 0 -> 0 (none to
begin with). Derived-artifact classes 0 -> 1 (the artifact index, generator landed in
A.4, no instance committed until Car 3's store migration).

## Question 1 - mutable process state

**None.** This is a deliberate claim, not an omission: the dispatch-harness design's
one-writer-per-artifact premise (design rev 6 + A1) removes the need for any component to
remember identity, deduplicate, or track wall-clock state across calls. Every component
in this train (the schema validator, `Verify-Verdict.ps1`, `New-ArtifactIndex.ps1`) is a
pure function or a stateless script invocation - nothing survives a restart because
nothing is held in memory between invocations to begin with.

Per spec S9 rows 1-2, both parts of this claim are recorded, not one:

| Claim | Answer |
|---|---|
| Is the artifact store append-only under git? | Yes - every artifact is a new file; nothing is edited or removed in place. |
| Is there mutable process state to ledger? | No - see reasoning above. |

## Question 2 - derived committed artifacts

**One row.** The artifact index (its class is born in Task A.4 - `New-ArtifactIndex.ps1`
generates it; `schema/index-format.md` defines its columns, sort order, and field
order).

| Derived artifact (owner class) | Generator | Committed? | Staleness owner | Verdict | Evidence (test name) |
|---|---|---|---|---|---|
| Artifact index (`scripts/New-ArtifactIndex.ps1`) | `New-ArtifactIndex.ps1` | not yet - no instance is committed until Car 3 migrates the store (spec S5.2, S4 row 5) | CI regenerate-and-diff, lands as Car 3's gate | DELIBERATE no-gate (posture recorded, not a gap) | `ArtifactIndex.Tests.ps1` (determinism, the enabler for Car 3's diff gate) |

A deliberate no-gate posture is still a row (`docs/templates/worked-ledger-and-gating.md`):
the absence of a gate before Car 3 lands is a decision worth auditing, not a silent hole.
This row's verdict flips only in the commit that lands Car 3's CI diff step, same-commit
with that gate's own test.
