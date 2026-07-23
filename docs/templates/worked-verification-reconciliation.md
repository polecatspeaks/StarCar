# Verification-claim reconciliation - the ancestor's art for two named classes

Status: Current

Provenance: ported in answer to a specific ask after a real incident here (an
`in_progress` CI sample reported as a state, a red that sat unseen). Structure and
doctrine exact; examples fictionalized per the porting SOP. Honest scoping up front:
**the ancestor has no literal claims ledger.** Its answer to "no reconciliation between
claims and reality" is structural - three layers that make a false green hard to state,
short-lived if stated, and cheap to catch. The ledger idea is named at the end as your
invention opportunity, not a port.

## The two classes, as the ancestor names them

1. **Sample-as-conclusion**: sampling an asynchronous process and treating the sample as
   its terminal outcome. Standing rule: after autonomous pushes, WAIT for CI before
   declaring anything verified - a local green proves the local environment only, and a
   compile is necessary, never sufficient. The tooling form is ops-script-patterns §3
   (watch to completion; "no run appeared for this ref" is its own honest outcome, never
   success; confirm the built SHA in the run's own output).
2. **Unreconciled verification claims**: assertions ("CI green", "suite passes") that
   nothing ever audits against terminal reality. The meta-class beneath both:
   **absence-blindness** - a red never looked at is indistinguishable from no red; an
   absence is invisible unless something asserts COMPLETENESS.

## Layer 1: the falsifiable-claim convention (the enabler)

No verification claim is ever bare. The house form:

> `STAR-suite`: **214/214 passed** at `3f2ab91` (run locally, <date/time>).
> CI: `build-and-test` **success** at `3f2ab91`.

Every claim carries: the SUITE, the OBSERVED COUNT (never "green" - a suite that
silently ran 0 tests is green), the SHA it was observed at, and who/where observed it.
A claim without coordinates cannot be audited later; with them, any party can reconcile
any claim at any time. This convention is cheap and it is the foundation - the other
layers only work because claims arrive in checkable form.

Corollaries: merge commit messages restate the counts ("reviewer APPROVE, 214/214 +
88/88 green"); ticket closes cite counts and SHAs; a claim of "unchanged" states the
baseline it equals ("2361, matches baseline exactly").

## Layer 2: the paired-observer rule (claims are never terminal)

No claim is load-bearing until a second party has re-derived it. Every reviewer brief
carries, verbatim: *"RUN YOURSELF at HEAD: <suites> (expect <claimed counts>). Report
observed."* - and the reviewer states observed-vs-claimed explicitly. The whole-branch
gate re-runs everything again and replays the ledger arithmetic commit by commit
against the actual diffs. What this buys: a false or stale claim survives at most one
gate. The ancestor's reviews have caught claimed-green-actually-different-count exactly
this way - not because anyone suspected lying, but because re-observation is the
default, so drift and staleness surface mechanically.

## Layer 3: fixed reconciliation cadences (prove your greens on a clock)

**The session-start CI baseline hook** - the closest existing thing to "prove your
greens," and the direct antidote to the red-that-sat-unseen:

```sh
#!/bin/sh
# SessionStart hook: reconcile the "known-good" assumption against live CI, every boot.
# A red that sat unseen surfaces at the NEXT SESSION at the latest - bounded blindness.
branch=$(git branch --show-current)
echo "[ci-baseline] Branch '$branch' - latest CI (known-good check, standing policy):"
gh run list --branch "$branch" --limit 4 \
  --json conclusion,status,headSha,workflowName \
  --jq '.[] | (.conclusion // .status) + " | " + .headSha[0:9] + " | " + .workflowName' \
  | sed 's/^/[ci-baseline]   /'
echo "[ci-baseline] If any required workflow is red: triage BEFORE the first edit -"
echo "[ci-baseline] deterministic red = blocker; one-off on identical code = flake, note and move on."
```

The policy half (in CLAUDE.md): the session does not start editing on top of an
unexamined red. The hook makes the check unforgettable; the rule makes it binding. Note
the flake calibration line - a timing-heavy suite that passes the same code on re-run
is a flake, and treating flakes as blockers teaches people to ignore the check
(crying-wolf, the severity philosophy again).

**The weekend compare** (when you have releases/production): whatever the week's audits
CLAIMED gets compared against what reality surfaced - claims the world confirmed,
claims the world refuted, claims untested. Misses sharpen the lenses. Same shape,
weekly cadence, aimed at audit-claims instead of CI-claims.

## The absence-blindness counters (assert completeness, not instances)

- **Reflection-driven parity tests**: "every wire-bound field on <type> is covered by
  this round-trip test" - enumerated by reflection, so a NEW field is auto-enrolled and
  a dropped one is a build failure. The pattern kills silently-missing-artifact bugs
  because the test asserts the SET is complete, not that known members work.
- **The suite table**: the runner iterates a declared table of every suite; a suite
  missing from the table is invisible to every aggregate run, so the weekly instrument
  audit asks "does the table match the projects that exist?"
- **The board pass**: every landed thing moved to its truthful column on a cadence, so
  an unmoved ticket is a visible anomaly rather than an invisible absence.

## Your invention opportunity (named, not ported)

A literal machine-checkable claims ledger does not exist in the ancestor: e.g. a
`claims.jsonl` where every "verified" assertion lands as `{sha, suite, count, when,
observer}`, with a CI job that re-derives current terminal states and fails on any
claim newer than its reality. The ancestor's three layers made it unnecessary at its
scale - but a public showcase whose thesis is process-truth might want claims audited
by mechanism rather than by paired attention. If you build it, the severity philosophy
applies: reconcile against TERMINAL states only, or it cries wolf on every in-progress
sample - which would be the original class, rebuilt as a tool.
