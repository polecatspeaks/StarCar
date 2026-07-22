# Worked spec - a real spec's shape, sanitized

Status: Current

Provenance note for the reviewing agent: the ancestor shop's real specs exist but are not
portable (proprietary, domain-dense). This is one of them TRANSPOSED - structure, section
inventory, review-record conventions, and rhetoric preserved exactly; content moved to
the fictional staleness-banner feature (same universe as worked-briefs.md). The
structure is the lesson. Condensed: a real spec runs 150-300 lines.

---

Status: Current

# Staleness Banner: One Verdict for Data Freshness (#12)

Cargo: #12. Successor tickets: #15 (per-adapter freshness detail). Laws served: First
(never render a freshness the data cannot back), Fifth (the board is honest about its
own staleness), Sixth (the verdict has one author; the view renders it).

Owner decisions locked in the brainstorm: verdict derives ONLY from adapter-reported
FetchedAt (never the browser clock alone); UNKNOWN is a first-class rendered state;
thresholds configurable per deployment, defaulted 30s/120s.

## 1. The problem

Three components each compare timestamps against their own clock reads [cite the real
files:lines]. Two disagree today: the header shows "live" while the lane badge shows
"stale" for the same snapshot. Two truths on one screen is the defect class this
project exists to kill.

## 2. Architecture

**FreshnessVerdict** (new, single author): derived in the adapter layer at snapshot
arrival - `fresh | aging | stale | unknown` - carried ON the snapshot record. Every
consumer renders `snapshot.verdict`; no consumer computes its own. [Each claim the spec
makes about existing code carries file:line - the spec reviewer OPENS every one.]

- Null/absent FetchedAt => `unknown`, rendered as UNKNOWN. Never inferred, never
  defaulted to fresh (First Law).
- Thresholds read once per snapshot derivation, not per render (two reads can disagree
  mid-config-reload - the review that caught this class is recorded in section 12).

## 3. Contracts

`FreshnessVerdict` as a closed string union; `Snapshot.verdict` required (breaking
change to the snapshot record - every constructor site enumerated: [list, file:line
each]). The banner consumes ONLY `verdict` + `fetchedAt` (for the tooltip's "as of").

## 4. Retirement list

The three self-computing comparisons [file:line each] are DELETED in the same train,
their tests migrated same-commit. Enumerate every caller of each retired member -
"zero remaining callers" is grep-proven in the car's report, re-proven by its reviewer.

## 5. Lifecycle events (mandatory section - per field)

| Field | Process restart | Adapter reconnect | Config reload |
|---|---|---|---|
| Snapshot.verdict | NOT STATE - recomputed per snapshot | same | derived with the NEW thresholds from the next snapshot on; in-flight snapshots keep their verdict (honest: it was true when derived) |
| Banner's rendered state | render-only, refetched every poll, never carried | same | same |

Every new MUTABLE field (none in this feature - say so explicitly when true) gets
red-first lifecycle tests per event. A spec that introduces state without this section
was the ancestor's most expensive documentation failure (a CRITICAL the next day).

## 6. Testing

Cells: fresh/aging/stale boundary values; null-FetchedAt renders UNKNOWN;
threshold-reload mid-stream; the two-truths regression (header and badge NEVER
disagree - one assertion over both). Non-vacuity: fault-inject the derivation once,
watch the cell fail, revert, document.

## 7. Probe list (what the desk cannot prove)

Does adapter X actually populate FetchedAt on its error path, or only on success?
[When you cannot verify a claim from the desk, it goes HERE explicitly - never assumed
into the design.]

## 8. Non-goals

Per-adapter freshness detail (#15). Historical staleness charting. Anything the
brainstorm deferred, named so a plan-writer cannot scope-creep it back in.

## 12. Review record

Design review (code-grounded adversary, read-only, ran BEFORE this spec was written):
**NEEDS-REWORK, 4 findings, all folded above** marked [DR-*]: DR-1 the third
self-computing comparison (the lane badge) was missed by the design's retirement list -
found by the reviewer's own caller enumeration; DR-2 the config-reload double-read
race; DR-3 observability reality - the design consumed a FetchedAt the error path never
populates (now probe item 1); DR-4 YAGNI - the design's per-adapter detail deferred to
#15.

Spec review (document attack, a DIFFERENT failure surface than the ideas): round 1
**NEEDS-REWORK, two Majors, folded same sitting**: M1 a citation pointed at the wrong
function (the reviewer opened it; a wrong citation that sends a car to the wrong code
is a Major); M2 "the banner shows staleness" was readable two ways (age text vs
verdict color) - ambiguity is a finding because a car that sees only its own task will
pick the wrong reading. Round 2: **APPROVED**.

[The review records stay IN the spec forever. They are how the next reader knows what
was already attacked, what was ruled, and what the document's claims have survived.]

---

## KNOWN GAP - disclosed, not yet fixed (2026-07-22)

**This exemplar has two holes, and they are not hypothetical.** On its first real use, an
adversarial spec review attributed two of its eight Major findings to the template rather
than to the author:

1. **No contracts-touched section.** The design-rung template has one; this does not. So a
   design's documentation obligations - which documents this work invalidates, and which car
   owns updating each - **evaporate at the design-to-spec handoff**. In that first use, nine
   obligations were lost, and a zero-context plan-writer working from the spec alone would
   have written no documentation tasks at all.
2. **No fidelity ledger.** The design rung's one-row-per-finding-and-ruling disposition table
   demonstrably worked - it is why that revision could prove nothing had been dropped. With
   no equivalent here, **five adopted design requirements were silently dropped**, including
   the feature's central mechanism.

Both are instances of one class: *obligations cross rungs by carrier, never by memory* - see
`worked-rung-carriers.md`.

**A candidate fix exists and is UNDER ADVERSARIAL REVIEW at the time of writing**, as §9 and
§10 of the spec that discovered the gap. It is deliberately not folded into this template yet,
for the reason this repo keeps repeating: **amending an exemplar with an unreviewed invention
is inventing prior art**, which is the exact failure exemplars exist to prevent. The candidate
may turn out to be a table that lists obligations without binding anything, in which case the
correct amendment is none.

**Until that verdict lands, an adopter should add both sections by hand** and treat this note
as the reason. Disclosed while incomplete beats confidently wrong - a template is allowed to
be TRUE before it is COMPLETE, and this one is not yet complete.
