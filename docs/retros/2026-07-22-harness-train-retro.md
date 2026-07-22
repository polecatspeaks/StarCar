Status: Current

# Session retro, 2026-07-22 - the harness train's first full ladder run

Scope: plan rung through Car 1 merge plus the spec §7 probes. Blameless and precise:
every actor named, every lesson checked against the anti-gaming guard (what LANDED?).

## What we learned, with the artifact each lesson left

| # | Lesson (the class) | What landed |
|---|---|---|
| 1 | **Reading is not verifying.** A behavioural claim verified by reading is a confident falsehood waiting to be inherited; one survived THREE spec rounds and both plan revisions because reading `Verify-Verdict.ps1:94-96` produces exactly the false claim running refutes. | `worked-plan.md` Amendment 1; spec BINDING AMENDMENT S1; conductor memory; 7 probes run for plan rev 2 |
| 2 | **Delta-to-same-agent converges where fresh-full-rounds churn.** Plan rung: 7 -> 1 -> 0 Majors, one dispatch per round, zero swirl conditions. The ancestor's pattern this replaced burned ~5 fresh rounds at ~110k tokens each. First live use of APPROVE-WITH-REBASE-LIST closed the gate without a fourth round. | 3 landed plan verdicts; 2 landed car verdicts; the round-history convergence rulings inside them |
| 3 | **The model probe returned a competency split, not a verdict.** Sonnet: weak at UNPROMPTED DISCOVERY against self-authored contracts (M-A4-1 - shipped a generator contradicting the contract the same car wrote), reliable at DIRECTED EXECUTION (fixed it flawlessly from a precise brief). | Hybrid topology (Car 2 Opus / Car 3 Sonnet), owner-ratified; both probe data points in landed verdicts |
| 4 | **Truth here is constructed by probes, and probes must land.** The kills-are-invisible measurement upgraded the design's tier-1 detector from presumption to the ONLY mechanism accounting for kills. | NO HEADERS HERE doctrine in CLAUDE.md; `scripts/probes/` suite (proven both directions); `docs/probes/2026-07-22-spec7-probe-results.md`; standing SubagentStop observation hook |
| 5 | **The self-referential baseline class.** The verdict store grows by the very verdicts that approve the plan, so any hard-pinned count is stale the moment the gate closes - the car's own STOP rule would have fired against freshly approved text. | Binding amendment entry 2 with the class named; next-plan guidance (pin invariants, let counts float) |
| 6 | **Carriers are proven by measurement, not asserted.** `abstract` - the third field in one spec sentence - was missed by five review rounds (both plan revs, all three spec rounds, and the reviewer's own round 1, which it disclosed). The delta walk's ID discipline caught it before any schema was built. | The field, its vector, and its anti-vacuity twin in the landed schema; the disposition-table walk in round-2's verdict |
| 7 | **Tooling requests must not die in conversation.** | NEVER DROP A TOOLING REQUEST standing order in CLAUDE.md; issues #10 (probes in CI) and #11 (cost ledger) |

## What the constitution held correctly (where the system worked as designed)

- **Law 1:** every verification claim this session carried coordinates (suite, count,
  SHA, observer); the one confident falsehood found was corrected by a public amendment,
  not an edit-in-place. Verdicts landed verbatim, 16/16 hashes.
- **Laws 4 and 6:** M-A4-1 (silent loss of the UTC marker; index drifting from its
  contract) was caught by the gate, and the repair moved the CODE to the contract -
  `index-format.md` untouched, verified by diff in the round-2 verdict.
- **Law 7:** the schema shipped as a portable conformance suite (vectors, open
  `additionalProperties`, producer-optional cost) - a stranger implements against the
  same vectors without our toolchain.
- **Law 8 and the success-shapes rule:** the gradient shaping demonstrably worked on
  SUBAGENTS, not just the conductor - the Sonnet car disclosed three defects in its own
  briefing material unprompted; the Opus reviewer disclosed its own round-1 miss of
  `abstract` and accepted the conductor's correction of its probe-attribution error.
  Truth-on-the-success-branch is shaping behaviour downstream of the prose that says so.
- **Blameless-but-precise:** the record names the conductor's stale baseline, the car's
  M-A4-1, and the reviewer's attribution error - each with the exact move and cost, none
  softened, all in public commits.

## What to improve (each with its landing)

1. **Quoted observations lacked their CONDITIONS.** Three car-disclosed findings traced
   to plan quotes that were true under the plan-writer's shell/layer and misleading
   under the car's (FullyQualifiedErrorId vs rendered exception name; It-count of a
   reduced probe vs the real file). LANDED: Amendment 1 sharpened this session - quote
   with conditions, assert at the layer the runtime renders.
2. **Self-moving counts churned three documents.** Suite totals and store counts were
   rebased by hand at every revision; the class fired twice. LANDED: the class is named
   in binding amendment entry 2; next plan pins invariants ("all verified, exit 0")
   and lets counts float. Watch whether that guidance sticks without a template edit.
3. **Cost accounting was counts-only.** ~1.07M subagent tokens across the 9 visible
   dispatches was discovered by summing notifications AFTERWARD - the cost-discipline
   rule wants it decided in advance. LANDED: issue #11, trigger-gated to cars 2-3
   planning (candidate: fold into the harness store's existing `cost` field).
4. **The conductor is still the harness.** Verdict landing, worktree bookkeeping, and
   baseline re-derivation are manual conductor moves per dispatch - this session was
   its own requirements document for cars 2 and 3. No new artifact needed: the harness
   train IS the landing.
5. **Same-agent delta reviews have an unmeasured context ceiling.** The plan adversary
   carried three rounds of history; at some round count its context saturates and the
   delta pattern degrades. UNGUARDED, named honestly: no mechanism yet, vigilance-tier,
   revisit if a reviewer's round count exceeds ~4.
6. **CLAUDE.md is growing.** Four doctrine sections landed this session; the
   institution's reading burden grows with it. DEFERRED with trigger, per the
   autoimmune rule: restructure only when a worker demonstrably misses a rule because
   of length, not preemptively.

## The ledger (anti-gaming guard: what landed this session)

6 gate verdicts (16/16 hashes) - 2 binding amendments (S1, worked-plan A1 + sharpening)
- the schema substrate merged to dev through 5 gate rounds, CI success at `c82b966f` -
the probes doctrine + suite + §7 results - the never-drop-tooling standing order - the
hybrid model topology with two measured data points - issues #10 and #11 - 4 conductor
memory files - this retro.
