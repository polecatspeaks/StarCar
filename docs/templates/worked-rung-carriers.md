# Rung carriers - how findings and contract obligations survive rung transitions

Status: Current

Provenance: ported on a specific ask ("spec-rung fidelity ledger" and "contracts-touched
carrier"). The honest shape first: the ancestor has NO standalone ledger for either.
Both are CARRIER CHAINS embedded in the rung documents themselves - each rung's document
contains a machine-walkable list, and the NEXT rung's adversary is briefed to walk it
row by row. Nothing crosses a rung by memory; anything not written into the next rung's
input document does not exist there. That is the design principle, and it is why the
chain survives worker amnesia: the documents carry the obligations, the adversaries
enforce the handoff.

## Carrier 1: the finding-ID fidelity chain (design -> spec -> plan -> cars)

**Step 1 - findings get IDs at birth.** Every review verdict numbers its findings:
design review findings are `DR-1..n` (or `DR-C1`/`DR-M2` for critical/major), spec
review Majors are `M1..n`, plan-review items likewise. The ID is minted in the verdict
and never reused.

**Step 2 - the next document folds each finding INLINE, marked with its ID.** The spec
does not summarize "review feedback was incorporated" - it marks the exact spot:

```
- **[DR-2, folded] Thresholds are read once per snapshot derivation**, not per render -
  the design review proved two reads can disagree mid-config-reload.
```

**Step 3 - the document's own review-record section carries the roll-up:**

```
## Review record
Design review: NEEDS-REWORK, 4 findings, ALL FOLDED above, marked [DR-1]-[DR-4].
```

**Step 4 - the next rung's adversary walks the IDs as a TABLE.** The spec adversary's
brief lists the design findings verbatim as the source of truth and demands dimension
(a): a fidelity table, one row per finding:

```
| ID | Finding (one line) | Status in the spec |
|---|---|---|
| DR-1 | third self-computing comparison missed by retirement list | Present (section 4, verified against real callers) |
| DR-2 | config-reload double-read race | Present (section 2) |
| DR-3 | error path never populates FetchedAt | DRIFTED - spec says "populated on all paths"; the probe item vanished. Finding. |
```

`Present / Absent / Drifted` - drifted meaning the words are there but the substance
moved. A drifted fold is the subtle failure this chain exists to catch: the fold that
LOOKS folded. The same table repeats at the plan rung (plan adversary checks the spec's
requirements landed as tasks) and at the car rung (the car's brief quotes the specific
findings that bind it; its reviewer adjudicates each disclosed deviation against them).

**Why a chain and not a central ledger:** each rung's adversary only ever needs the
PREVIOUS document's list - keeping the obligation local to the handoff makes the check
small, mandatory, and unskippable, where a central ledger would be one more document to
drift. (If you build the central form anyway, make CI walk it - attention-tier chains
are exactly what your repo wants to graduate to mechanism.)

## Carrier 2: the contracts-touched chain (state and interface obligations)

The obligation "this work touches contract X" is re-stated at EVERY rung in that rung's
native form, so no rung inherits it implicitly:

**Rung 1 - the spec's mandatory Lifecycle section.** Every piece of state the design
implies gets a per-field row (see worked-spec.md section 5): field x lifecycle events x
verdict. A spec introducing state without this section is a spec-review Major. This is
where "touches the state contract" is BORN as a written obligation.

**Rung 2 - the plan carries it as arithmetic and file lists.** Every task that touches
state: (a) lists `docs/contracts/state-ledger.md` in its **Files: Modify** block - the
contract file is a named deliverable of the task, not an ambient duty; (b) states the
ledger arithmetic INLINE in the step ("Ledger: <X> -> <X+1>, SAFE <Y> -> <Y+1>, stated
old -> delta -> new"); (c) the plan's running-totals section sums the whole train, with
the standing caveat that cars re-read the LIVE ledger at dispatch and STOP on mismatch
(other trains move it). Interface contracts ride the same rung as Consumes/Produces
blocks - exact names and types, because the consuming car sees only its own task.

**Rung 3 - the car's same-commit rule.** The commit that adds/changes state updates the
contract file IN THAT COMMIT (reviewers reject a state-touching diff that leaves the
contract stale). The brief restates the expected live baseline and the STOP-if-different
instruction.

**Rung 4 - the reviewer replays; the gate replays again.** The car reviewer verifies
the arithmetic and the four-event tests against the diff; the whole-branch gate replays
the ENTIRE train's arithmetic commit by commit against the actual diffs ("any unledgered
mutable field anywhere in the train = Major"). The ancestor's gate has caught real
undercounts exactly here - including one where a retirement orphaned live fields from
the count, found because the gate's brief demanded the replay table rather than trusting
three prior approvals.

**The transition discipline in one line:** a rung transition is complete only when the
receiving document restates the obligation in its own native form - lifecycle table ->
task file-list + arithmetic -> same-commit diff -> replay table. Four restatements of
one fact, and that redundancy is the point: any single rung dropping it is caught by
the neighbor that didn't.

## Porting note for your missing-workflow class

Your diagnosis ("both exist at the design rung and neither survived the transition") is
the class this file kills: an obligation that lives in ONE document dies at the first
handoff. The fix is never "remember harder" - it is making the next rung's TEMPLATE
demand the carrier section (a spec template with a mandatory Lifecycle section and a
review-record section; a plan template whose task skeleton includes the Files/Interfaces
/arithmetic slots) and the next rung's ADVERSARY brief demand the table. Template +
adversary, at every rung: the obligation travels because the receiving side is built to
refuse delivery without it.
