# Gating matrix

Status: Current

Copied from `docs/templates/gating-matrix.md` (2026-07-22, dispatch harness Car 1, task
A.5). Per spec `docs/specs/2026-07-22-dispatch-harness-spec.md` S9 rows 1-2, this file is
Car 1's to instantiate with the three surfaces below.

## Header (keep count current)

3 surfaces audited.

## Table shape

| Surface | Fires when | Suppressed when | Resets on | Classification | Evidence (test name) |
|---|---|---|---|---|---|
| Tier 1 detection (spec S2.5) | a `dispatched` record has no `returned`/`presumed-lost` successor - it renders `unaccounted-for` | never - a truth surface (spec S3.1: this is a fold requirement, not a rendering suppression) | a `returned` or `presumed-lost` record supersedes the `dispatched` record (latest-`at` wins) | GATED - a fold requirement; the artifacts alone are sufficient, any conforming shop gets tier 1 (spec S2.5) | pending - lands Car 2 as the fold's tier-1 test |
| Tier 2 detection (spec S2.5) | the Entire checkpoint branch, as the enumerable second source, disagrees with or extends tier 1's fold | tier 2 is not CI-reachable as configured today - `.github/workflows/ci.yml:32` is a bare `actions/checkout@v4` with no ref fetch (spec S2.5 [m5]) - so tier 2 is suppressed in CI until Car 3's fetch lands | Car 3 lands the checkpoint-branch fetch in `ci.yml` (spec S4 row 5, S9) | GATED, producer-dependent - deferred: fold logic to Car 2, CI-reachability to Car 3 | pending - lands Car 2 (fold) and Car 3 (CI fetch) |
| Artifact-index staleness | the committed index (once one exists) differs from a fresh regeneration of the same store via `scripts/New-ArtifactIndex.ps1` | no index is committed yet - today's state; A.4 landed the generator with no instance committed (see `docs/contracts/state-ledger.md`) | committing a freshly regenerated index (Car 3's store migration) | DELIBERATE, no gate today - the posture itself is the ledgered row, not a gap; gate lands Car 3 as a CI regenerate-and-diff step | pending - lands Car 3 as the ArtifactIndex-staleness CI step. Enabler already landed: `ArtifactIndex.Tests.ps1`'s byte-identical determinism test (Task A.4) - without determinism, a diff gate would flag every run |

Severity philosophy for anything that judges data: expected/placeholder patterns are
NOTES, defects are FLAGS. An instrument that cries wolf is worse than no instrument.
None of the three rows above are armed as CI gates yet (tier 1/2 fold logic and the
index-staleness diff step all land in Car 2/Car 3) - that is the DELIBERATE state this
table records, not an omission.
