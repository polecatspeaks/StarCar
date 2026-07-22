# The Healing Loop

Status: Current

Companion to [the constitution](constitution.md). The constitution is what this project
must be; the Healing Loop is the metabolism - how the process that builds it repairs and
hardens itself. Ported from the shop that derived it, where it ran unassisted several
times in a single morning before anyone named it.

## The observation that started it

As an agentic codebase and its process mature, the consistent failure surface migrates UP
the stack: from syntax, to logic, to integration, to coordination and epistemics - who
knows what, who checked what, what a scope includes, where knowledge lives. The workers
barely miss; the misses live between the scopes. This is the journey human organizations
took over decades ("a bad system will beat a good person every time" - Deming),
compressed into weeks, with two twists unique to agentic development:

1. **Every worker is a new hire on day one.** Agents accumulate no experience across
   dispatches. Only what is WRITTEN persists. Process here is not bureaucracy around the
   workforce; it IS the institution. The workforce evaporates nightly.
2. **The economics inverted.** A human org rations review because review labor is scarce.
   Here a skeptical expert costs one dispatch, so the constraint flips from "who can we
   afford to check this" to "have we DESIGNED a check for this failure class." The binding
   constraint is review attention, not generation - so the system optimizes for the least
   new-code-reviewed per unit of capability, and for gates that catch classes, not
   instances.

## The loop

Every failure, at every altitude (code, plan, spec, design, process, tooling,
instrument), gets the same four-step treatment:

1. **Classify to the CLASS, not the instance.** "The DTO dropped nine fields" is an
   instance. "Hand-maintained mirrors at process boundaries fail silently, and no review
   scope owned the whole path" is the class. Root-cause analysis is not done until the
   class is named.
2. **Install a mechanical guard at the cheapest layer that could have caught it.** A test
   beats a review rule; a review rule beats a standing procedure; a procedure beats
   vigilance; a structural impossibility beats them all (an agent type that cannot
   delegate because the tool is absent, not because a rule forbids it). Prefer guards
   that fire at build/test time over guards that require someone to remember.
3. **Give the guard binding authority.** Advisory checks decay into wallpaper. Every
   adversarial gate holds REJECT; any Major = REJECT; disclosed-but-wrong does not clear
   review. Rejection appeals upward (author → conductor ruling → owner), never around.
4. **Write it into the institution.** Operating rules, ledgers, procedures, agent
   definitions, scenario files, corpus fixtures. The written system is the only system
   that survives the night.

## The preconditions (why the loop works)

- **Honest-failure framing.** Immune systems only work on true signals. Because an honest
  stop, a disclosed miss, and a reviewer's REJECT are all named SUCCESS outcomes, agents
  surface their own failures - workers disclose defects in their own diffs, reviewers
  reject their own train's plans. A blame-shaped system hides exactly the signals healing
  requires. This framing is the load-bearing wall.
- **Adversaries at every altitude.** Design review, spec review, plan review, per-car
  review with the sentence check, whole-branch gate, CI, production. Each catches a
  different failure class at the cheapest point that class is catchable. Each gate should
  be installed by the loop itself, one incident at a time - imported ceremony that never
  caught anything here is a pruning candidate.
- **Executable knowledge.** Validated facts must land as tests or gates, never only
  prose. Prose knowledge defends nothing - the team that learned it is gone by morning.
- **Instruments inside the loop.** The harnesses that judge the product are audited
  against the product's own changes on a cadence, with a severity philosophy that keeps
  them honest: expected patterns are notes, defects are flags, and an instrument that
  cries wolf is worse than no instrument.
- **One doctrine, independently re-derivable.** The test that the loop is working: two
  reviewers at different gates deriving the same principle from different incidents,
  without coordination. When the system's parts converge on consistent doctrine
  unprompted, the doctrine is real.

## The honest edges

- **Nothing prunes by default.** Immune systems that only add gates go autoimmune:
  ritual, token cost, friction without catches. The counter-organ is the scorecard -
  catches per gate, reviewed on a cadence; a gate that stops catching gets retired with
  the same deliberateness it was installed. Young projects importing this seed should
  watch this edge hardest: start with the right-sized subset, let incidents install the
  rest.
- **The loop is human-supervised, and that is a design choice, not a gap.** "Stop the
  train" is a human immune response no gate is watching for; the arbiter above every gate
  is the owner. The standing design question, revisited as the loop matures: which owner
  interventions should become gates, and which are permanently, properly human.
- **Rules bind only where they are structural.** A prose rule binds an agent that reads
  it; a toolset binds every agent regardless. Over time, rules that matter should
  graduate from prose to structure. The gap between what is written and what is enforced
  is itself a failure surface the loop should keep eating.
