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
| Tier 1 detection (spec S2.5) | a `dispatched` record has no `returned`/`presumed-lost` successor. The fold renders the liveness gradient (spec S3.3): `dispatched` within budget, `overdue` WITH elapsed and budget past it - the derived `unaccounted-for` truth (S3.1: unaccounted-for is DERIVED) a board reads off these states, and per Probe 1 the only surface for a killed dispatch (which fires no stop hook) | never - a truth surface (spec S3.1: this is a fold requirement, not a rendering suppression) | a `returned` or `presumed-lost` record supersedes the `dispatched` record (latest-`at` wins; the fold exposes every superseded record) | GATED - a fold requirement; the artifacts alone are sufficient, any conforming shop gets tier 1 (spec S2.5) | LANDED Car 2: `scripts/Detect-Dispatches.ps1` + `scripts/tests/Detector.Tests.ps1` - precedence `returned`>`presumed-lost`>`dispatched`; two `returned` resolve latest-`at` with the older exposed in `superseded`; a `dispatched` past budget renders `overdue` with elapsed+budget; a record `budget` overrides the shop default; a later `intent` supersedes the earlier hold |
| Tier 2 detection (spec S2.5) | the Entire checkpoint branch, as the enumerable second source, disagrees with or extends tier 1's fold | tier 2 is not CI-reachable as configured today - `.github/workflows/ci.yml:32` is a bare `actions/checkout@v4` with no ref fetch (spec S2.5 [m5]) - so tier 2 is suppressed in CI until Car 3's fetch lands | Car 3 lands the checkpoint-branch fetch in `ci.yml` (spec S4 row 5, S9) | GATED, producer-dependent - deferred | DEFERRED (R6v2): tier-2 ENUMERATION needs a dispatch-enumerable second source proven by probe - the checkpoint branch enumerates CHECKPOINTS keyed to commits, not dispatches, with no checkpoint-to-subject map, so enumerating it today would raise a false gap per commit (a wolf-crier, worse than none). Trigger recorded in `docs/setup.md`. Tier EXPOSURE shipped in Car 2 (the fold reports `tier: tier-1-only` truthfully); CI checkpoint fetch is Car 3 |
| Artifact-index staleness | the committed index (once one exists) differs from a fresh regeneration of the same store via `scripts/New-ArtifactIndex.ps1` | no index is committed yet - today's state; A.4 landed the generator with no instance committed (see `docs/contracts/state-ledger.md`) | committing a freshly regenerated index (Car 3's store migration) | DELIBERATE, no gate today - the posture itself is the ledgered row, not a gap; gate lands Car 3 as a CI regenerate-and-diff step | pending - lands Car 3 as the ArtifactIndex-staleness CI step. Enabler already landed: `ArtifactIndex.Tests.ps1`'s byte-identical determinism test (Task A.4) - without determinism, a diff gate would flag every run |

Severity philosophy for anything that judges data: expected/placeholder patterns are
NOTES, defects are FLAGS. An instrument that cries wolf is worse than no instrument. The
tier-1 FOLD LOGIC landed in Car 2 (`Detect-Dispatches.ps1` + `Detector.Tests.ps1`), but
none of the three rows is armed as a CI GATE yet: the CI wiring and the checkpoint-branch
fetch are Car 3's, rendering is #1's job, tier-2 enumeration is deferred (R6v2, trigger in
`docs/setup.md`), and the index-staleness diff step lands in Car 3. That mix - one fold
landed, its CI arming and tier-2 still ahead - is the DELIBERATE state this table records,
not an omission.
