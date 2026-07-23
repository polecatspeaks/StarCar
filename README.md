# StarCar

**A visualizer for multi-agent / subagent processing.** Trains, cars, gates, and freight:
watch an agentic development pipeline the way a dispatcher watches a rail yard.

## Status

**The dispatch-harness substrate runs; the yard board does not exist yet.** The producer
hook (`scripts/Produce-Artifact.ps1`) writes one artifact record per dispatch event, the
read-only detector (`scripts/Detect-Dispatches.ps1`) folds the store into dispatch and
intent state, the schema validator (`scripts/Artifact.psm1`'s `Test-StarcarArtifact`)
checks every record, and the deterministic index generator
(`scripts/New-ArtifactIndex.ps1`) writes `artifacts/index.md` — all exercised by a Pester
suite under CI. None of that is the *visualizer*: there is still no server, no board that
renders a fold on screen, and no quickstart, and this README will not describe one until
there is. That sentence is the north star working: user-facing documentation must be true
from the first commit, and complete only once the thing it documents exists.

This repository opens **process-first**: before any code lands, it carries the
governing documents that will build it — a constitution, a self-healing process loop, and a
seed of hard-won operating rules ported from months of running a heavily-gated multi-agent
development process on a production project.

That ordering is deliberate, and it is the point. Plenty of dashboards exist. What this
repo demonstrates is the *discipline* the dashboard visualizes: every feature here will be
designed, adversarially reviewed, test-driven, and gated by the same process the visualizer
renders — with the review verdicts and REJECT records committed in-repo as they happen.

Documentation ranks equal to code here, as a north star rather than a nicety — and that
covers both families: the process documents (designs, specs, plans, verdicts, ledgers)
and the user-facing ones (this README, the quickstart, deployment and adapter guides,
demo data, screenshots). Both pass the gates code passes, and the commit that invalidates
a document updates it in that same commit. When audiences conflict, the stranger
deploying it cold wins, per the constitution's seventh law.

Nothing reaches `main` except by pull request — a rule enforced on the remote and
fault-injected to prove it fires, not merely asserted. The record is never curated: the
first thing merged to `main` was the revert of a commit that should not have reached it,
and the failure that let it through is written up in the PR rather than tidied away.

## The idea

An agentic dev shop starts to look like a freight operation:

- **Tracks = trains**: units of work composed from a single manifest, run as a sequence of
  implementation "cars," each with its own adversarial reviewer.
- **Signals = gates**: design review, spec review, plan review, per-car review, the
  whole-branch gate, CI — each with binding authority to stop the line.
- **Inbound freight = the ticket queue**, grouped by area into future manifests.
- **The fuel gauge = the usage meter** the whole operation is budgeted against.

StarCar renders that live, from pluggable data adapters (a git repo, an issue tracker's
project board, an artifact store - the dispatch harness's store lands in this repo; the
board's consumption of it is #1's train) — never hardcoded to any one shop.

## Reading order

1. [`docs/constitution.md`](docs/constitution.md) — what this project must be (RATIFIED
   2026-07-21, before any code).
2. [`docs/the-healing-loop.md`](docs/the-healing-loop.md) — how the process that builds it
   repairs and hardens itself.
3. [`CLAUDE.md`](CLAUDE.md) — the operating rules, each carrying the scar that earned it.
4. [`docs/templates/design-doc.md`](docs/templates/design-doc.md) — the design workflow: constraints before mechanism, with a worked exemplar built from a real four-round failure.
5. `docs/templates/` — the other working artifacts (car briefs, state ledger, gating matrix).

## License

MIT.
