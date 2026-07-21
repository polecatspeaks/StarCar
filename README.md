# StarCar

**A visualizer for multi-agent / subagent processing.** Trains, cars, gates, and freight:
watch an agentic development pipeline the way a dispatcher watches a rail yard.

## Status

Pre-design. This repository opens **process-first**: before any code lands, it carries the
governing documents that will build it — a constitution, a self-healing process loop, and a
seed of hard-won operating rules ported from months of running a heavily-gated multi-agent
development process on a production project.

That ordering is deliberate, and it is the point. Plenty of dashboards exist. What this
repo demonstrates is the *discipline* the dashboard visualizes: every feature here will be
designed, adversarially reviewed, test-driven, and gated by the same process the visualizer
renders — with the review verdicts and REJECT records committed in-repo as they happen.

## The idea

An agentic dev shop starts to look like a freight operation:

- **Tracks = trains**: units of work composed from a single manifest, run as a sequence of
  implementation "cars," each with its own adversarial reviewer.
- **Signals = gates**: design review, spec review, plan review, per-car review, the
  whole-branch gate, CI — each with binding authority to stop the line.
- **Inbound freight = the ticket queue**, grouped by area into future manifests.
- **The fuel gauge = the usage meter** the whole operation is budgeted against.

StarCar renders that live, from pluggable data adapters (a git repo, an issue tracker's
project board, a conductor-maintained state file) — never hardcoded to any one shop.

## Reading order

1. [`docs/constitution.md`](docs/constitution.md) — what this project must be (DRAFT until
   ratified).
2. [`docs/the-healing-loop.md`](docs/the-healing-loop.md) — how the process that builds it
   repairs and hardens itself.
3. [`CLAUDE.md`](CLAUDE.md) — the operating rules, each carrying the scar that earned it.
4. `docs/templates/` — the working artifacts (car briefs, state ledger, gating matrix).

## License

MIT.
