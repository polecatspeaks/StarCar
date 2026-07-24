# StarCar

**A visualizer for multi-agent / subagent processing.** Trains, cars, gates, and freight:
watch an agentic development pipeline the way a dispatcher watches a rail yard.

## Status

**The yard board runs.** The producer hook (`scripts/Produce-Artifact.ps1`) writes one
artifact record per dispatch event, the read-only detector (`scripts/Detect-Dispatches.ps1`)
folds the store into dispatch and intent state, the schema validator
(`scripts/Artifact.psm1`'s `Test-StarcarArtifact`) checks every record, and the
deterministic index generator (`scripts/New-ArtifactIndex.ps1`) writes `artifacts/index.md`
— all exercised by a Pester suite under CI. On top of that substrate, `board/server` (Go)
polls the artifact store and serves a live view at `board/web/`: five lanes (trains,
gates, dispatches, freight, fuel), always rendered, honestly labeled when a lane has no
data source yet. See [Quickstart](#quickstart) below to run it yourself. It is
**local-only and unauthenticated** — a status board for a repo you already have checked
out, not a service to expose on a network.

This is still v0: one Go process, one static view, no deployment story, no adapters
beyond this repo's own artifact store. That is the north star working — user-facing
documentation must be true from the first commit, and complete only once the thing it
documents exists; this quickstart replaces the line that used to say no quickstart existed,
in the same commit that made a quickstart real.

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

StarCar renders that live. v0 (this repo's own dispatch-harness artifact store, consumed
by `board/server` - see [Quickstart](#quickstart)) is the FIRST adapter; the broader
vision - pluggable data adapters (a git repo, an issue tracker's project board) never
hardcoded to any one shop - is tracked in
[#1](https://github.com/polecatspeaks/StarCar/issues/1).

## Quickstart

Runs entirely from this checkout, against this repo's own artifact store
(`artifacts/`) - no external service, no account, no config file required.

**Prerequisites** (see [`docs/setup.md`](docs/setup.md) for the full disclosure):
- **Go**, version per [`board/go.mod`](board/go.mod)'s `go` directive (`1.26`). If `go`
  is not on your shell's `PATH`, invoke it by its install path (e.g. on Windows,
  `C:\Program Files\Go\bin\go.exe`) or add that directory to `PATH` for the session.

```sh
git clone https://github.com/polecatspeaks/StarCar.git
cd StarCar/board
go run ./server
```

Then open <http://127.0.0.1:4600/> in a browser. The server polls `artifacts/` once a
second and serves:

- `GET /` — the board itself (`board/web/index.html`, vanilla ESM JS, no build step)
- `GET /api/snapshot` — the current state as JSON
- `GET /api/stream` — the same state as Server-Sent Events, for live updates

Stop it with Ctrl-C. Nothing it does writes to the artifact store, and nothing it serves
leaves your machine - it is **local-only and unauthenticated** by design; do not expose
port 4600 on a network you do not trust.

Verified 2026-07-23 from a clean `git clone` of this exact command sequence: `GET /`,
`GET /api/snapshot`, and a served JS module (`GET /js/app.js`) each answered HTTP 200;
`GET /api/stream` emitted a real `event: yard` SSE frame; and the `/api/snapshot` body
validated against `schema/yard-snapshot.schema.json` via the same vendored validator the
browser itself uses.

## Reading order

Start at the neutral front door, [`ONBOARDING.md`](ONBOARDING.md) — it carries the tiered
reading path and the compliance floor for every agent family, then hands off to the ordered
list below (#47).

1. [`docs/constitution.md`](docs/constitution.md) — what this project must be (RATIFIED
   2026-07-21, before any code).
2. [`docs/the-healing-loop.md`](docs/the-healing-loop.md) — how the process that builds it
   repairs and hardens itself.
3. [`CLAUDE.md`](CLAUDE.md) — the operating rules, each carrying the scar that earned it.
4. [`docs/templates/design-doc.md`](docs/templates/design-doc.md) — the design workflow: constraints before mechanism, with a worked exemplar built from a real four-round failure.
5. `docs/templates/` — the other working artifacts (car briefs, state ledger, gating matrix).

## License

MIT.
