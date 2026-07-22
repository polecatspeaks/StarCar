# Worked contracts - filled ledger rows and gating-matrix rows, sanitized

Status: Current

Provenance: the ancestor's real state ledger runs 500+ fields; the 99-latent-instance
audit that the ledger template mentions was run against exactly this row shape. Content
here is fictionalized (staleness-banner universe); the row anatomy, header arithmetic,
and changelog conventions are exact.

---

## The header + running changelog (the arithmetic discipline)

The header's first content line is a RUNNING PREPEND-ONLY changelog: every
state-touching commit prepends its entry with explicit old -> delta -> new arithmetic,
and the newest totals lead. What to expect: this line grows long and that is fine - it
is the audit trail that lets a reviewer replay the arithmetic commit by commit.

```
Verdict totals across 14 fields: SAFE 11, LATENT_BUG 2, DELIBERATE_CARRY 1.
(2026-XX-XX banner train, Car A Task A.2: +1 field - AdapterPoller._lastGoodSnapshot
(src/adapters/poller.ts), SAFE - held for the banner's "last good as-of" tooltip,
replaced on every successful poll, LOST on restart (honest, disclosed). See the new
AdapterPoller section below for the fault-injection-verified lifecycle breakdown.
Arithmetic: 13 + 1 = 14; SAFE 10 + 1 = 11. Prior: 13 fields: SAFE 10, LATENT_BUG 2,
DELIBERATE_CARRY 1. (2026-XX-XX <the previous entry stays forever>...))
```

## A SAFE row (the normal case - what a real row carries)

| Field (owner class) | Restart | Adapter reconnect | Config reload | Verdict | Evidence |
|---|---|---|---|---|---|
| `_lastGoodSnapshot` (AdapterPoller) | LOST (in-memory; tooltip shows "no data yet" - honest) | CARRY (a reconnect does not invalidate the last true reading) | CARRY (thresholds do not change what WAS fetched) | SAFE | `Lifecycle_Restart_TooltipHonestlyEmpty`, `Lifecycle_Reconnect_KeepsLastGood` (non-vacuity: reset line commented out -> test failed `Expected: null, Actual: <snapshot>` -> reverted) |

What to expect in a real row: every lifecycle cell has a VERDICT WORD (RESET / CARRY /
FROZEN / LOST) plus one clause of reasoning; the evidence cell cites real test names;
at least one cell's test carries a recorded fault-injection proof. A row without tests
is LATENT_BUG until proven otherwise - that is the posture that found the 99.

## A LATENT_BUG row (how a known-bad field is held honestly)

| Field (owner class) | Restart | Adapter reconnect | Config reload | Verdict | Evidence |
|---|---|---|---|---|---|
| `_retryCount` (AdapterPoller) | RESET | **CARRIES across reconnect - Issue #14: a healthy reconnect inherits the dead connection's backoff, first poll delayed up to 60s** | n/a | LATENT_BUG (#14) | none - the row IS the finding; the fix train's red will pin it |

What to expect: the bug is described in the CELL where it lives, with the issue number.
The ledger never silently fixes prose - the row flips to SAFE only in the commit that
fixes the code, same-commit, with the new test cited.

## A RETIRED row (consolidation without losing the scar)

```
RETIRED (2026-XX-XX, banner train Car C): the five rows for the OLD self-computing
freshness comparisons (Issue #9's rotation-carry class) - the owning code is deleted;
detection now single-sourced at deriveVerdict (see its SAFE rows above). Provenance
preserved: #9's scar is why the one-author rule exists. Arithmetic: -5 fields,
LATENT_BUG -5. Never silently delete rows: collapse to this shape so the institution
keeps the scar after the bug is structurally dead.
```

---

## Gating matrix - filled rows

Header carries a COUNT restated every touching commit: `6 surfaces audited.`

| Surface | Fires when | Suppressed when | Resets on | Classification | Evidence |
|---|---|---|---|---|---|
| Staleness banner (render) | verdict != fresh | never - truth surface, no operator override | next snapshot | DELIBERATE, no gate | `Banner_Stale_Renders`, `Banner_Unknown_NeverShowsFresh` |
| Reconnect toast (notify) | adapter down > 10s | during initial startup grace (30s) - a cold boot is not an outage | successful poll | GATED (grace window), fault-injected: grace removed -> toast fired on boot -> reverted | `Toast_BootGrace_NoFire` |

What to expect: every surface that DECIDES something (fires, suppresses, blocks) gets a
row in the same commit that adds it; a DELIBERATE no-gate posture is still a row (the
absence of a gate is a decision worth auditing); severity philosophy applies to any
surface that judges data - expected patterns are NOTES, defects are FLAGS, and a
crying-wolf instrument is worse than none.
