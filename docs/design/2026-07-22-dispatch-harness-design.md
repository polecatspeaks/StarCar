# Design: the dispatch harness

Status: **DRAFT rev 1 - awaiting adversarial design review**
Issue: #7 (`area:adapters`)
Date: 2026-07-22
Ladder rung: design (rung 1 of: design → spec → plan → cars)

## 1. What this is

Every dispatch in this shop emits a **structured artifact**. The artifacts are the
process's own record of itself, and they are the yard board's data source.

This is a keystone: it sits in the integrity path of every gate, and after this lands the
board renders facts the work itself produced rather than facts a human remembered to type.

## 2. Why - the class

A dispatch's output is ephemeral by default. The only thing standing between an artifact
and oblivion was the conductor remembering to copy it out, which is **vigilance** - the
weakest tier in the Healing Loop's hierarchy, below even a written procedure.

The owner's correction sharpened the diagnosis: Entire.io already provides **durability**
(every session checkpoints to a public branch, verified). What it does not provide is
**addressability**. An artifact buried in a multi-megabyte JSONL is safe and unusable,
while `README.md` promises review verdicts "committed in-repo as they happen" - a promise
a reader cannot navigate to. Persisted-but-unfindable does not satisfy a promise to
publish.

And the obvious manual fix was worse than the gap. The conductor began hand-transcribing a
verdict about its own design: a hand-maintained mirror at a process boundary, with the
author being reviewed doing the copying. **Verbatim-by-construction beats
verbatim-by-discipline.**

## 3. Trust model - stated plainly, because a hash that seems to prove more than it does is a lying instrument

| Threat | Defended by | Not defended |
|---|---|---|
| The conductor alters a verdict about its own work | Body SHA-256 stamped at extraction, recomputable by anyone | - |
| An artifact is silently never recorded | Producer runs on a dispatch hook, not on conductor memory (§7) | - |
| An artifact rots or is edited after landing | `Verify-Verdict` equivalent, run in CI | - |
| A reviewing agent writes an untrue verdict | **NOTHING.** The hash proves the conductor did not alter what the agent said; it says nothing about whether the agent was right or honest. | ✗ |
| The transcript source itself is forged | **NOTHING.** We trust the runner's transcript. | ✗ |

The two ✗ rows are deliberate and must stay written down. The defence against a wrong
verdict is not cryptographic, it is that verdicts are public and the next reviewer reads
them. The defence against a forged transcript is that we are not in an adversarial
environment, and if we ever are, this design does not help.

## 4. The artifact contract - the product

**The schema is the product. Producers are adapters.** Law 7: a stranger's shop runs a
different agent runner, so what ships is a documented format anyone can emit. The Claude
Code producer is one implementation, exactly as `StateFileAdapter` is one implementation
of `Adapter<T>`.

### 4.1 The store is append-only events

Artifacts are **events, never mutated**. A dispatch that starts and later finishes emits
two events; nothing rewrites the first. State is derived by folding events (§8).

Append-only is chosen over a mutable per-dispatch record for three reasons: history is the
product here (a REJECT that was later fixed must remain visible); a mutable file invites
the conductor to tidy the record, which the north star forbids; and in-flight state
becomes derivable rather than declared - a dispatch with a `dispatched` event and no
terminal event **is** in flight, with no separate status field to go stale.

### 4.2 Event kinds

| Kind | Emitted when | Carries |
|---|---|---|
| `dispatched` | A subagent is launched | dispatch id, role, train, gate, model, base sha, worktree, brief digest, timestamp |
| `returned` | It completes | dispatch id, outcome (`delivered` / `honest-stop` / `error`), verbatim body, cost, timestamp |
| `verdict` | A reviewer returns | dispatch id, gate, target, base, `APPROVE`/`REJECT`, severity counts, verbatim body |
| `ruling` | The conductor decides an appeal or overrides | what was ruled, why, what it supersedes |
| `intent` | The conductor declares something no dispatch can know | train composition, holds (Law 2) |

`verdict` is a specialisation of `returned`, not a separate lifecycle: a reviewer emits
both facets in one artifact. Splitting them would create two records of one event that can
disagree, which Law 6 forbids.

### 4.3 The envelope the agent emits

Metadata comes **from the agent**, not from the conductor typing it. Today's
`-Verdict "REJECT - 8 Major"` parameter is the author-being-reviewed asserting the summary
of their own review - the same mirror class one layer up.

Every brief requires the agent to end its report with:

```
<<<STARCAR-ARTIFACT-V1
kind: verdict
gate: design-review
round: 2
target: docs/design/2026-07-21-v0-yard-skeleton-design.md
base: 444e0314f1ecbfe3a132b2f71c2be8963d1c1ad3
outcome: REJECT
findings: {major: 8, minor: 15, note: 5}
>>>STARCAR-ARTIFACT-V1
```

Rules, each earned:

- **The sentinel appears at line start, is version-stamped, and is matched as a
  LAST-occurrence pair.** The first harness used a markdown horizontal rule as its
  separator; verdicts are full of horizontal rules, so the split landed inside the body and
  the hash covered a fragment that did not contain the verdict line. A tampered copy hashed
  identically to the original. **A separator that can appear in the payload is not a
  separator**, and this one is chosen to be implausible in prose and validated as a pair.
- **A missing or malformed envelope is a LOUD failure, never a guess.** The producer does
  not infer `outcome` from the prose. An artifact that cannot be parsed is recorded as
  `error` with the raw body preserved, and the board shows it.
- **Counts are cross-checked against the body** where the body is structured enough to
  count. A disagreement is surfaced, not silently resolved. This is the sentence check
  applied to the harness's own output.

### 4.4 The stored artifact

One file per event, front-matter plus verbatim body:

```
---
schema: starcar-artifact/1
kind: verdict
dispatch: <opaque runner id>
gate: design-review
round: 2
target: docs/design/2026-07-21-v0-yard-skeleton-design.md
base: 444e0314f1ecbfe3a132b2f71c2be8963d1c1ad3
outcome: REJECT
findings: {major: 8, minor: 15, note: 5}
model: opus
cost: {tokens: 99390, tool_uses: 21, duration_ms: 744192}
at: 2026-07-22T00:26:56Z
body_sha256: 32473a92...
producer: claude-code/1
---
<!-- verbatim-body-below: do not edit past this line -->

<agent's report, byte-for-byte>
```

`cost` is not decoration: it is the **fuel gauge's data**. Issue #1 names the usage meter
as one of four surfaces, and until now it had no source. The runner reports tokens, tool
calls and duration per dispatch; capturing them here makes the fuel lane real rather than
hypothetical, from artifacts we already produce.

## 5. Addressability - closing the class properly

Durability without addressability is what we already had. So:

- **Deterministic, sortable paths:** `docs/artifacts/YYYY-MM-DD/HHMMSS-<kind>-<slug>.md`.
- **A GENERATED index**, `docs/artifacts/INDEX.md`, derived from front-matter - never
  hand-maintained. A hand-written index of a growing store is the mirror class again, and
  it would rot within one train.
- **`docs/reviews/` is retired**; its two landed verdicts move into the store. One
  location, one naming rule. Two stores would drift.
- The index is regenerated on every landing and **checked in CI**: a store whose index is
  stale is a lying instrument.

## 6. Verification

- Every artifact carries `body_sha256` over its verbatim body.
- `Verify-Artifacts` recomputes all of them and fails on any mismatch.
- **CI runs it.** This is the mechanical tier the current scripts do not reach.
- Line endings are normalised to LF before hashing at both ends. The first implementation
  hashed an in-memory string and wrote a different one (BOM plus CRLF), so every landed
  file failed its own verifier - a checker crying wolf on its own good output.
- **Non-ASCII fidelity is a test, not an assumption.** The first extractor read the
  transcript with the platform's ANSI default and silently mangled every non-ASCII
  character, making the word VERBATIM false while everything appeared to work.

## 7. Producers - and removing the vigilance

The Claude Code reference producer runs on **dispatch hooks**, not on conductor memory:

- `PreToolUse:Task` → emit `dispatched`.
- `PostToolUse:Task` → emit `returned` / `verdict`.

This is the part the current scripts do not do, and it is the part that closes the class.
Today the conductor must remember to run a command with seven hand-typed parameters: the
remembering moved, it did not go away. A hook is mechanism; a remembered command is
vigilance.

**Sweep as backstop, not primary.** `Land-Artifacts -Sweep` reconciles the store against
the session transcript and lands anything missing - for hook failure, for dispatches made
before the hook existed, and for runners with no hook mechanism at all. The `/goodnight`
ritual runs it. A backstop that is also the primary path is not a backstop.

**Law 7 obligations on the producer**, both currently violated by the scripts in tree:

- No hardcoded project path. Derive from the git root.
- The vendor transcript format (`content[].text`, `<task-id>`, `<result>`) is confined to
  the producer and documented as a known coupling. A format change breaks one file, loudly,
  and the artifact store is untouched.

## 8. Derivation - how the board gets its state

**The conductor declares INTENT; the process emits FACTS.** They own genuinely different
things, so there is no field both can write and no precedence rule to get wrong. This
replaces the two-fact-domain seam in the parked yard design, where both the registry and
the state file could supply a lane's position.

| Fact | Source |
|---|---|
| A car is rolling | `dispatched` with no terminal event |
| A car is at inspection | its reviewer's `dispatched` with no terminal event |
| A car is shopped, N REJECT rounds | count of `verdict` events with `outcome: REJECT` |
| A gate's aspect | latest `verdict` for that gate |
| Cost burned | sum of `cost` across events |
| A car is coupled at SHA | git |
| Inbound freight | the issue tracker |
| **Which tickets compose a train** | **conductor `intent`** - no dispatch can know this |
| **A train is held** | **conductor `intent`** - Law 2, the dispatcher's override |

The yard adapter folds the event stream into current state. The view still never computes:
folding is the adapter owning its facts.

**What this deletes from the parked yard design:** the hand-maintained `state.json` as the
primary source, and with it the `StateWriter` car in its current form. What survives is a
much smaller intent file, and the writer becomes the tool that emits `intent` events -
which is also, unchanged, the v0 embodiment of Law 2.

## 9. Out of scope

Signing or non-repudiation beyond a body hash (see §3 - we are not in an adversarial
environment). Artifact retention or pruning policy. Producers for runners other than Claude
Code, though the format must not prevent them. Rendering - that is the yard design's job.
Migrating historical dispatches from before this train.

## 10. Cars and cost

| Car | Scope |
|---|---|
| 1 | Artifact schema, validator, store layout, generated index |
| 2 | Claude Code producer: hooks, extraction, envelope parsing, sweep |
| 3 | Verification + CI wiring; retire `docs/reviews/`, migrate the two landed verdicts |
| 4 | Brief-template changes so every dispatch emits an envelope; agent definition updates |

Four cars, four reviewers, plus design, spec and plan with their reviews: **roughly 14
dispatches**, model mix Opus throughout, size class **medium-large**. This is spend on top
of the yard train, which is parked at rev 3 and returns as rev 4 afterward.

## 11. Open questions for the design reviewer

1. **Append-only events versus a mutable per-dispatch record.** §4.1 argues for events. The
   cost is that "what is happening now" requires a fold rather than a read, and folds have
   bugs. Is the honesty worth it at this scale?
2. **Should the agent emit the envelope, or should the producer derive metadata?** §4.3
   moves metadata to the agent to remove the conductor's hand-typed summary - but it also
   makes every artifact depend on an agent following a formatting instruction, and agents
   drift. Which failure is worse, and does the cross-check in §4.3 actually catch drift?
3. **Is `verdict` genuinely a facet of `returned` (§4.2), or two events?** One record
   cannot disagree with itself, but it also means a reviewer that returns garbage produces
   no verdict at all rather than an explicit "reviewer failed to produce a verdict".
4. **Does retiring `docs/reviews/` (§5) break `README.md:20-21`'s promise** during the
   window between this train landing and the index existing?
5. **Is a body hash worth anything given §3's two ✗ rows?** Argue the case that it is
   security theatre. If it survives that argument, keep it; if not, cut it and say why the
   file is trustworthy without one.
6. **The bootstrap paradox:** this harness's own dispatches produce artifacts for a store
   that does not exist until car 1 lands. Should its own review verdicts be landed by the
   current scripts and migrated, or held until the store exists?
