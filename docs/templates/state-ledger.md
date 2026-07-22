# State ledger (template)

Status: Current
Use: template - copy to `docs/contracts/state-ledger.md` when the first mutable service state lands.

The living inventory of every mutable field in long-lived services, with a verdict per
lifecycle event. Any commit adding or changing such state updates this file IN THE SAME
COMMIT, with old → delta → new arithmetic in the header. Reviewers reject state-touching
diffs that leave this file stale.

Why: state that silently survives (or silently resets across) a lifecycle event is the
highest-yield latent-bug class in long-lived agentic systems - an audit of this
template's ancestor project found 99 latent instances of the same pattern, each
individually "too small to ledger."

## Header (keep arithmetic current)

Verdict totals across N fields: SAFE n, LATENT_BUG n, DELIBERATE_CARRY n.

## Lifecycle events (enumerate YOURS - these are examples)

Define the project's lifecycle events once, then verdict every field against each:
process restart | data-source reconnect | adapter failure window | config reload

## Table shape

| Field (owner class) | Event 1 | Event 2 | Event 3 | Event 4 | Verdict | Evidence (test name) |
|---|---|---|---|---|---|---|
| `_example` (ExampleService) | RESET | CARRY | FREEZE | LOST (honest) | SAFE | `LifecycleEvent_Example_...` |

Every row cites the red-first lifecycle tests that pin it. A row without tests is
LATENT_BUG until proven otherwise.
