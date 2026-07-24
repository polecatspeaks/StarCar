# ONBOARDING.md - the neutral front door

Status: Current

StarCar is a self-healing, multi-agent software shop that runs as a fleet of short-lived
worker agents ("cars") coordinated by a conductor, over a git-native record store. Every
dispatch leaves an auditable artifact record; correctness and documentation are held to the
same standard, and the whole system is built so a shop that did NOT build it can operate it
from the documentation alone (constitution, Law 7). This file is the runtime-neutral entry
point: whatever agent family you are, arrival starts here.

This document is conductor/session-tier. Cars do NOT read the corpus on arrival - a car is
**brief-bound**: it reads its brief and the contracts the brief names, nothing more. The
tiered reading path below is for the conductor and for a session being (re)established.

## Tier 1 - mandatory (read in this order)

1. [`docs/constitution.md`](docs/constitution.md) - the laws (Law 1-7) the whole shop obeys.
2. [`docs/the-healing-loop.md`](docs/the-healing-loop.md) - why the shop exists and how it heals.
3. [`CLAUDE.md`](CLAUDE.md) - the statute index (see "The statute index" heading): the
   working rules and the scars behind them. Runtime-neutral doctrine despite the filename.
4. [`docs/glossary.md`](docs/glossary.md) - the shared vocabulary (dispatch, subject, mint,
   adapter, fold, rung...). Read before the process docs so the terms land.
5. [`docs/setup.md`](docs/setup.md) - how to stand the harness up and which runtimes it runs under.
6. [`docs/doc-map.md`](docs/doc-map.md) - the map of every document and the reading paths through them.

## Tier 2 - role-triggered (read when your role calls for it)

- The rung templates in [`docs/templates/`](docs/templates/) - the brief shapes for each rung
  (car brief, design, spec, plan...). Read the one your work is at.
- The specific contracts your task touches (the spec, schema, or vector files the brief names).

## Tier 3 - archaeology on demand (read when you need the history)

- [`artifacts/reviews/`](artifacts/reviews/) - the landed verdicts: how prior work was judged.
- [`docs/retros/`](docs/retros/) - the retrospectives: what the shop learned and changed.

## The compliance floor (non-negotiable, every agent, every rung)

- **Envelope mandate + task-id echo.** End every report with the artifact envelope (a fenced
  block, info string `starcar-artifact`, carrying `outcome`, `findings`, `abstract`), and echo
  the minted dispatch id your brief delivered as `task-id`. That envelope is how your `returned`
  record obtains its outcome and pairs to its launch record. No angle brackets inside the block.
- **Carrier rule.** A finding is carried with its identifier so the next reviewer can trace it;
  reviewer work product is evidence, never discarded silently.
- **Never push (cars).** Cars commit LOCALLY on their branch and never push and never merge -
  the conductor merges.
- **Honest stop.** If your brief contradicts the real code, STOP on that item with file:line
  evidence and continue with independent work. An honest stop is a SUCCESS outcome; improvising
  past a contradiction is the failure mode that costs trains.
- **TDD red-first.** For every behaviour change: write the failing test, RUN it, confirm it
  fails for the stated reason, then implement to green.
- **Verification honesty.** Claims are verifiable: exact pass counts, observed failures verbatim,
  commit SHAs, file:line citations. Never claim a thing verified that you have not watched pass.

## Per-family arrival notes (one line each)

- **Claude Code:** auto-loads [`CLAUDE.md`](CLAUDE.md) at session start - doctrine is reachable automatically.
- **Copilot CLI:** auto-loads [`.github/copilot-instructions.md`](.github/copilot-instructions.md),
  which points back here.
- **Any other family:** start HERE, human-pointed. Auto-load is enrichment; the front door works
  for any agent a human points at it (that is the floor, per the design's P2).

## Onboarding triggers (conductor/session-tier only)

Run this onboarding path when, and only when, one of these holds:

- a **new agent family** is being brought online (no pointer file for it yet);
- a **new agent identity** is being established (a role that has not run in this line);
- a session is **resuming after compaction** (context was summarised; re-establish the floor).

The trigger list is closed - onboarding is not an every-session ritual. Cars stay brief-bound
and do not run this path; the conductor owns it.
