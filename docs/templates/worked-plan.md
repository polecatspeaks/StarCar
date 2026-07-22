# Worked plan - a real plan's shape, sanitized, WITH the stitches for the ported scar

Status: Current

Provenance: transposed from the ancestor shop's real plans (structure exact, content
moved to the staleness-banner fiction). The seed's plan scar - "snippets calling
constructor parameters that did not exist... three REJECT rounds" - happened to a plan
missing the disciplines shown here. The stitches are: (1) the plan-writer SENTENCE-CHECKS
ITSELF (opens the real file for every snippet, and RUNS every behavioural red - see the
amendment below), (2) the rule-5 adversary re-verifies anyway, (3) findings fold as a
BINDING ADDENDUM the cars read. Real plans run 1000-3500 lines; this shows one car
fully worked.

**A note on this exemplar's own compression:** the bracketed prose below ("[Same
five-step shape...]", "[full code in a real plan...]") is an EXEMPLAR ARTIFACT, not a
licence. In a real plan every task carries all five steps and its snippets in full.
The first plan written from this template mirrored the compression precisely - full
snippet in the first task, prose thereafter, one task with no steps at all - and the
reviewer filed it as a finding. The compression exists so this file stays readable;
it does not transfer.

> ## AMENDMENT 1 (2026-07-22, from the first plan's round-1 REJECT - plan-review
> verdict `docs/reviews/2026-07-22-plan-review-car1-round1.md`)
>
> **A behavioural claim verified by reading is not verified. The plan-writer RUNS
> every behavioural red before writing it into a task.**
>
> The original self-check said "open the real file for every snippet." That stitch
> covers the ancestor's scar class - NONEXISTENT APIs, which reading catches - and it
> worked: the first plan's snippets were clean. It does not cover EXISTENT APIs THAT
> BEHAVE DIFFERENTLY THAN THEY READ. The first plan asserted, as "verified at base",
> that a script exited 0 on an empty directory; reading the code says exactly that.
> Running it says the opposite - StrictMode meets a null pipeline result two lines
> earlier and the script throws, exit 1, making the quoted lines unreachable dead
> code. The specified test PASSED ON ARRIVAL, which the TDD law calls proof of
> nothing. One command would have exposed it; no amount of reading could.
>
> So the self-check is now two-part, and the plan states which part each claim got:
> - **Structural claims** (this API exists, with this signature, at this line):
>   OPEN the file at base. Reading suffices.
> - **Behavioural claims** (this command exits N, this red fails with this message,
>   this input produces this output): RUN it at base and quote the OBSERVED result.
>   Every stated red in every task is a behavioural claim.
>
> Corollaries, each a finding the same round paid for:
> - **Declare the runtime floor.** Global constraints name the runtime(s) the suites
>   must pass under and the named APIs the plan depends on (the first plan's ruling
>   silently required a validation API that exists in one installed shell and not the
>   other). A plan that leaves the runtime unstated leaves every car a menu.
> - **A Produces block for a DATA CONTRACT enumerates every field the spec mandates**,
>   not just the ones the first task needs - a schema's consumers read the Produces
>   block blind, and a field missing there is a field the next car invents.
> - **The spec-coverage table is SUBSECTION-granular.** One blanket "section 3" row is
>   where five field obligations and a vocabulary mechanism hid. Every numbered
>   subsection maps to a task or names its deliberate deferral.
> - **The ledger question is asked in two parts:** mutable process state, AND derived
>   artifacts committed to git (a generated file with a staleness lifecycle is ledger
>   state even when the process holds nothing).

---

Status: Current

# Staleness Banner - implementation plan

REQUIRED SUB-SKILL: subagent-driven development (one car per task group, adversarial
reviewer per car).

Source of truth: docs/specs/2026-XX-XX-staleness-banner-design.md (design review
NEEDS-REWORK -> folded; spec review round 1 NEEDS-REWORK -> folded; round 2 APPROVED -
both recorded in the spec's section 12).

Base commit for every car: `<sha>`. Ledger arithmetic below is base-`<sha>` arithmetic;
cars RE-READ the live ledger at dispatch and STOP on mismatch (other trains move it).

> # BINDING AMENDMENT BLOCK (conductor-applied, <date>)
> [Empty at plan-writing. When the rule-5 review or a mid-train event invalidates task
> text, the conductor patches HERE - numbered items, each SUPERSEDING contradicting task
> text - instead of rewriting tasks. Cars read this block first. Example entry:]
> 1. Task A.2's snippet quotes the pre-refactor `deriveVerdict(snapshot)` - the real
>    signature at dispatch is `deriveVerdict(snapshot, thresholds)` (moved by the
>    config train). The placement instruction stands; read the real file.

## Global constraints

Red-first TDD per step; ledger same-commit for mutable state; docs updated in the
invalidating commit; honest-stop on plan-vs-code contradiction = SUCCESS; cars never
push; suites at car end: `npm test` (baseline <N> passing), `npm run build` clean.

## Car A - verdict derivation (Tasks A.1-A.2)

### Task A.1 - the FreshnessVerdict type + derivation

**Files:** Create: `src/freshness/verdict.ts`; Test: `src/freshness/verdict.test.ts`
**Interfaces:**
- Consumes: `Snapshot` (src/adapters/snapshot.ts:12 - REAL file:line, verified at base;
  fields: `fetchedAt: string | null`, ...).
- Produces: `deriveVerdict(snapshot: Snapshot, thresholds: Thresholds): FreshnessVerdict`
  and `type FreshnessVerdict = 'fresh' | 'aging' | 'stale' | 'unknown'` - EXACT names
  and types; Car B consumes these blind, this block is how it learns them.

- [ ] **Step 1: write the failing tests**

```ts
import { deriveVerdict } from './verdict';
// [Every snippet in a real plan is written AFTER opening the real consumed files.
//  The plan-writer states in its report: "sentence-check performed on every snippet."]

test('null fetchedAt derives unknown, never fresh', () => {
  const snap = makeSnapshot({ fetchedAt: null });
  expect(deriveVerdict(snap, DEFAULTS)).toBe('unknown');
});

test('age at exactly the aging threshold is aging, not fresh (boundary pinned)', () => {
  const snap = makeSnapshot({ fetchedAt: secondsAgo(30) });
  expect(deriveVerdict(snap, DEFAULTS)).toBe('aging');
});
```

- [ ] **Step 2: run, confirm the red REASON**

Run: `npm test -- verdict`. Expected: FAIL with "Cannot find module './verdict'" - a
compile/module red is the correct stated reason for genuinely-new API. [A red that
fails for a DIFFERENT reason than the plan states is a car finding, not a shrug.]

- [ ] **Step 3: minimal implementation** [full code in a real plan - never "implement
  the function"]
- [ ] **Step 4: green + suite** Run: `npm test -- verdict`. Expected: PASS; full suite
  baseline+2.
- [ ] **Step 5: commit** `feat(freshness): verdict derivation with honest unknown (#12)`

**Ledger:** no mutable state (pure function) - SAY SO explicitly; the reviewer checks
the claim either way. [Amendment 1: the claim answers BOTH ledger questions - process
state and committed derived artifacts - not just the first.]

### Task A.2 - thread the verdict onto Snapshot (breaking record change)
[Same five-step shape. Enumerates every constructor site file:line - verified at base -
and carries the spec's retirement citations forward. Ledger: if any mutable field
appears, old -> delta -> new arithmetic INLINE in the step, plus lifecycle tests.]

## Car B - banner render (Tasks B.1-B.3)
[Consumes block quotes Car A's Produces VERBATIM. Sequencing note: B dispatches after
A merges; if both touched one file, the plan says which car owns it.]

## Spec-coverage table

| Spec section | Task |
|---|---|
| 2 architecture / one author | A.1, A.2 |
| 4 retirement | B.3 |
| 5 lifecycle | A.2 step 4 |
| 6 testing cells | A.1, B.2 |
[Every spec section maps to a task or names its deliberate deferral. The plan reviewer
walks this table independently.]

## Task count + running ledger totals

N tasks. Ledger: base <X>/<Y> -> A.2 +1 -> <X+1>/<Y+1>. Cars re-read live at dispatch.

---

## The plan-review record (rule 5) - what the adversary hunts, and the verdict shape

Ran AFTER the plan was written, BEFORE any car dispatched. Dimensions: (a) spec
coverage (walk the table independently); (b) inter-task interface consistency
(Consumes/Produces agree - each car sees only its own task); (c) THE SENTENCE CHECK ON
EVERY SNIPPET - open the real file at base; every API a snippet calls must exist with
that signature. This dimension is what caught the ancestor's three-round plan: invented
constructor params, an invented type, a wrong-generic logger - each a compile wall a
car would have hit mid-train, each caught at one-dispatch cost instead; (d) red
validity - would each stated red fail for the STATED reason at its point in the
sequence, verified by RUNNING it, never by reading (Amendment 1: the first plan's
worst Major was a stated red that reading confirms and running refutes); (e)
amendment-block fidelity to the spec, not re-derived.

Verdict shape (this exemplar's fictional round):

> **REJECT.** Major: Task B.2's snippet calls `banner.setVerdict(v)` - no such member;
> the real surface at base is a props object (`Banner({verdict})`, src/ui/banner.tsx:9).
> A car would hit this as a compile wall; the plan's own A.1 Produces block already
> names the right shape, so this is internal inconsistency, dimension (b) and (c) at
> once. Fix and re-review the delta.

Rework lands as plan edits + an amendment-block entry; the re-review verifies the
delta; the verdict history stays in the plan. If every defect is mechanical
(line-number drift, count rebases) the reviewer may verdict APPROVE-WITH-REBASE-LIST:
the conductor applies the enumerated fixes as a binding addendum and cars dispatch
without another full round - but ANY snippet calling a nonexistent API stays a REJECT.
