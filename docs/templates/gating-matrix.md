# Gating matrix (template)

Status: Current
Use: template - copy to `docs/contracts/gating-matrix.md` when the first gated surface lands. First copied: 2026-07-22, dispatch harness Car 1 (`docs/contracts/gating-matrix.md`) - three rows: tier 1 detection, tier 2 detection, index staleness.

The living inventory of every surface that DECIDES something (fires an alert, suppresses
an output, flips a status, blocks an action): what gates it, what resets the gate, and
the evidence. Any commit touching gating updates this file in the same commit.

Why: gates drift from the code they guard, and a stale gate description is a lying
canary - the reader trusts the documented mechanism while the code does something else.
The ancestor project's reviews caught mechanism-prose drift within hours of a mechanism
change; that is the standard.

## Header (keep count current)

N surfaces audited.

## Table shape

| Surface | Fires when | Suppressed when | Resets on | Classification | Evidence (test name) |
|---|---|---|---|---|---|
| Example: staleness banner | data age > threshold | never (truth surface) | fresh fetch | DELIBERATE, no override | `Banner_Stale_...` |

Severity philosophy for anything that judges data: expected/placeholder patterns are
NOTES, defects are FLAGS. An instrument that cries wolf is worse than no instrument.
