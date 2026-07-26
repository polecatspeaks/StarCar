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
  mid-config-reload - the review that caught this class is recorded in section 11).

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

## 9. Contracts touched (#9 - the carrier a rev-1 spec did not have)

Every document this spec's decisions invalidate, and who owns updating each. Mandatory,
even when the row is "none" - a spec that introduces no new documentation obligation says
so explicitly, the same non-vacuity discipline section 5 already applies to state.

| Document | What changes | Owner |
|---|---|---|
| `docs/contracts/state-ledger.md` | Instantiates the new mutable field `Snapshot.verdict` with the old -> delta -> new arithmetic from section 5 | Car B |
| `docs/contracts/gating-matrix.md` | The UNKNOWN verdict is a gated truth surface, never suppressed - the example row this project's own gating-matrix template already carries (`gating-matrix.md:23`) becomes real | Car B |
| `docs/glossary.md` | Defines `fresh` / `aging` / `stale` / `unknown` as the verdict's closed string union, replacing the three components' informal, disagreeing prose | Car A |
| The three retired self-computing comparisons' call sites [file:line each, section 4] | Doc comments describing the old per-component computation are removed same-commit as the code | Car A / Car C |

[WHY this section exists: the design-rung template has one (design section 8, nine rows,
with owners). Without its spec-rung equivalent, a design's documentation obligations
evaporate at the design-to-spec handoff - the first real use of this template without this
section lost nine of them, and a zero-context plan-writer working from the spec alone would
have written no documentation tasks at all. See `worked-rung-carriers.md`: obligations cross
rungs by carrier, never by memory.]

## 10. Fidelity to the design (#9 - the disposition table a rev-1 spec did not have)

One row per adopted design premise, decision, or review ruling; each points at the spec
section that carries it. A blank is a defect, not an omission - the same rule the design
rung's own one-row-per-finding table already enforces (design section 9b).

| Design item (premise / decision / ruling) | Where it lands here |
|---|---|
| DR-1 (lane badge added to the retirement list) | Section 4 |
| DR-2 (config-reload double-read race - thresholds read once per derivation) | Section 2, bullet 2 |
| DR-3 (observability reality - the error-path FetchedAt question) | Section 7, probe item 1 |
| DR-4 (YAGNI - per-adapter detail deferred) | Section 8 |
| Owner decision: verdict derives ONLY from adapter-reported FetchedAt, never the browser clock alone | Section 2 (opening line) |
| Owner decision: UNKNOWN is a first-class rendered state | Section 2, bullet 1 |
| Owner decision: thresholds configurable per deployment, defaulted 30s/120s | Section 2 (opening line), section 3 |

[WHY this section exists: the design rung's one-row-per-finding-and-ruling disposition
table demonstrably worked - it is why a design revision could prove nothing had been
dropped. With no spec-rung equivalent, the first real use of this template silently
dropped five adopted design requirements, including the feature's central mechanism. A
row here that cites nowhere real, or a real requirement with no row, is the fold that
LOOKS folded - the failure this table exists to make impossible to hide.]

**Known fallibility, kept rather than smoothed over:** the real spec that produced this
shape had its own fidelity ledger produce a FALSE row in its first round - a row claiming
a section carried something that section did not actually say, caught only when a human
reviewer opened the cited section and it was silent. The table is real work, not a
rubber stamp; it is checked by OPENING the cited section, never by trusting the row. A
CI check that walks every row and confirms the cited section actually mentions the
claimed item is tracked separately (still open; see the closing note below) - until it
lands, this table is reviewer-verified, attention-tier, same as any other citation.

## 11. Review record

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

## Sections 9-10 provenance and residual open items (#9, closed 2026-07-26)

Sections 9 and 10 above were carried, not invented. They are the shape and rhetoric
of `docs/specs/2026-07-22-dispatch-harness-spec.md` sections 9 and 10 - the real spec
whose first draft, written from THIS template before it had these sections, lost nine
documentation obligations and five adopted design requirements (including the feature's
central mechanism) at the design-to-spec handoff. That candidate was deliberately left
out of this template while still under adversarial review, per this repo's own rule that
amending an exemplar with an unreviewed invention is inventing prior art. It has since
survived four rounds - REJECT (8 Major), DELTA-REJECT (1 Major: a false ledger row, N1),
CONFIRM-REJECT (1 Major, mechanical - a repo-policy commit's line-number shift, not a
substance defect), APPROVE - with N1 confirmed closed on substance in round 3 and no
further false row in round 4
(`artifacts/reviews/2026-07-22-harness-spec-round{1-REJECT,2-DELTA-REJECT,3-CONFIRM-REJECT,4-APPROVE}.md`).
The shape has survived a round without a false row, which is the trigger this template's
prior note set for folding it in.

Two items from #9 remain open, disclosed rather than silently dropped:

1. **Make CI walk the ledger.** `worked-rung-carriers.md:57-58` predicted the false-row
   failure before it happened ("if you build the central form anyway, make CI walk it");
   nothing does yet. A ledger row asserting a section carries something, checked
   mechanically against whether that section actually mentions it, is the natural next
   gate and is NOT built by this commit.
2. **Mirror both sections into `Project-Bootstrapping`**, the public repo that ships this
   template externally. Out of scope for this worktree (different repository, not present
   here) - tracked on #9, not resolved by this commit.

Also closed, in the same fold: the numbering gap the first spec review flagged in this
template - verbatim, "the template jumps §8 → §12 with no §9-11 and no explanation... an
unexplained gap teaches every future author to leave one"
(`artifacts/reviews/2026-07-22-harness-spec-round1-REJECT.md:72`). Sections 9 and 10 now
fill two of the three missing numbers; Review record renumbers to section 11 immediately
below, closing the rest of the gap rather than leaving it explained-but-open.
