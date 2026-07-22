<!-- starcar-integrity: sha256=c1f0c945e2de029859f25f935bb62b2fdbf6ebfa570c8bad64993f3a0fe2f089 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Adversarial design review - dispatch harness, round 2

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: design review (ladder rung 1)
Round: 2
Target: `docs/design/2026-07-22-dispatch-harness-design.md (rev 2)`
Base reviewed: `66f3c78d11584f210a68c615645319bcb3d2232c`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT - 3 Major, 7 Minor, 5 Notes**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a78236df32f142813`. The conductor did not retype a word of what follows. Verbatim by
> construction rather than by discipline, because the author being reviewed is the
> one landing the review, and a hand-copied verdict is a hand-maintained mirror at a
> process boundary.
>
> Integrity: the `starcar-integrity` line at the top of this file hashes EVERY byte
> below it - this header's claims as well as the verbatim body. Recompute with
> `scripts/Verify-Verdict.ps1 -Path <this file>`. An independently-written copy of the
> same body exists on the Entire checkpoint branch; that copy, not the hash, is the
> defence against whoever controls this script.
>
> Path normalisation: none applied (the body contained no operator-environment paths).

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `66f3c78d11584f210a68c615645319bcb3d2232c` |
| Entire checkpoint | `59985314d4bc` |
| Dispatch, the locator within the session | `a78236df32f142813` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 66f3c78d11584f210a68c615645319bcb3d2232c
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Base verified. All ground truth read. Two fault injections run outside the repo. Transcript and subagent transcripts measured directly. Report follows.

---

# VERDICT: REJECT

Three Major findings. Rev 2 closes four of round 1's seven Majors cleanly and one of its adjudications is correct against the reviewer — but the fold is still not computable (identity, dedup, supersession and double-terminal-events all name a mechanism without making it implementable), §6's reconciliation names a source CI cannot read, and the cost adjudication stopped one measurement short: `subagent_tokens` is not a conflated total, it is a high-water context mark that excludes every output token, and §10 would sum it into a fuel gauge under-reading true burn by 5.5x to 19.9x.

**Base:** `git log -1 --format=%H` = `66f3c78d11584f210a68c615645319bcb3d2232c` at `&lt;home&gt;\AppData\Local\Temp\claude\C--Users-Chris-git-starcar\64c15364-0933-4d6d-9b2e-d1ddbc918f9f\scratchpad\review-harness-2`, detached, `git status --short` empty. Read-only in the worktree; the three fault-injection copies were made in a sibling scratch directory (`...\scratchpad\faultinject2\`), never in the repo. Nothing edited, committed, or pushed. No delegation.

Unqualified `design:N` citations refer to `docs/design/2026-07-22-dispatch-harness-design.md` at that base.

---

## HALF ONE — CLOSURE TABLE FOR ROUND 1'S SEVEN MAJORS

| # | Round 1 finding | Status | Evidence I checked |
|---|---|---|---|
| 1 | `PostToolUse:Task` fires at launch, not completion | **CLOSED** | design:199-219. The lifecycle is corrected, `PostToolUse:Task`→`dispatched` is argued as the *right* trigger for launch rather than a workaround, `SubagentStop`→`returned` is named, and — the strongest sentence in the document — design:215-219 declines to build on it: *"whether `SubagentStop` fires for asynchronously-dispatched subagents in the parent's hook context is not yet verified empirically... the spec is blocked on that test."* That converts an unverified mechanism into a gated test instead of an assumption. Residual is Minor-6 below (no fallback branch if the test fails). |
| 2 | Nothing detects a MISSING artifact | **PARTIAL** | design:181-197. The `dispatched`-as-ledger-entry idea is right and is the honest closure shape. But the mechanism named to make it mechanical cannot see the failure mode it exists to catch. See **MAJOR-2**. |
| 3 | Ghost dispatches render "rolling" forever | **CLOSED (class), new defect attached** | design:162-179. `expect_by` + fold-to-`unknown` genuinely removes the permanent-rolling state: the fold at design:263 is now time-bounded, so a dead dispatch stops reading `rolling` without anyone acting. The class is closed. What rev 2 *added* is not: see **MAJOR-3(c)**. |
| 4 | Hash does not cover rendered fields | **CLOSED — verified empirically, both directions** | See the injection results below. Both tampers now produce `MISMATCH`, exit 1. One citation defect: the design credits the wrong commit (Minor-1). |
| 5 | Fold has no identity, ordering, dedup, supersession | **NOT CLOSED** | design:62-106 names all four mechanisms. None of the four is computable as written. See **MAJOR-3**. |
| 6 | Cost data does not exist | **Adjudication CORRECT; disposition WRONG → NOT CLOSED** | The fields exist exactly as claimed — I found them as literal elements. Round 1 was wrong. But the design then mis-describes what the number *is*. See **MAJOR-1**. |
| 7 | Unredacted automated public publication is an unruled scope expansion | **CLOSED** | design:227-242. The decision is now *named* as a decision (design:229-231), an owner ruling is recorded, and the mechanical half is implemented and verified: `ConvertTo-PortablePaths` runs before hashing (`scripts/Land-Verdict.ps1:118-166`, called at `:189`, hashed at `:316-317`), the rule is declared in each landed file (`docs/reviews/2026-07-22-harness-design-round1-REJECT.md:24`), and the un-normalised original survives — `git grep -c -F 'review-harness-1' entire/checkpoints/v1 -- '16/234ffe6e1b/0/transcript.jsonl'` returns 2 hits, and the round-1 verdict body is present on the checkpoint branch in 6 separate checkpoints. Note-2 below. |

### MAJOR-4: the injection, run rather than read

Copied `docs/reviews/2026-07-22-harness-design-round1-REJECT.md` to `...\scratchpad\faultinject2\`, outside the repo.

**Baseline (pristine copy):**
```
OK           ...\faultinject2\pristine.md
1 verdict file(s) verified: every body matches its claimed hash.
EXIT=0
```

**Injection A — HEADER ONLY.** `**Verdict: REJECT - 7 Major, 10 Minor, 5 Notes**` → `**Verdict: APPROVE - 0 Major, 0 Minor, 0 Notes**`, body untouched:
```
MISMATCH     ...\faultinject2\headertamper.md
  claimed: 19b0922f3d0dd4e29e47612dca861b63001b004ffa68e75256b062d743e978c0
  actual : 9fe336698473c33cc5d908c248669071d17ac5043a8ee58294ce31685b42966c
EXIT=1
```

**Injection B — BODY ONLY.** `# VERDICT: REJECT` → `# VERDICT: APPROVE`, header untouched:
```
MISMATCH     ...\faultinject2\bodytamper.md
  claimed: 19b0922f3d0dd4e29e47612dca861b63001b004ffa68e75256b062d743e978c0
  actual : 0de502ccd55594458333f24c64a7325f9f99a1aa1fe8c25f13901c6b48d8b139
EXIT=1
```

The exact injection that defeated the guard at round 1 now fires. `scripts/Verify-Verdict.ps1:53-66` reads the first line, hashes `$rest`, and `scripts/Land-Verdict.ps1:316-320` hashes `header + provenance + separator + body` and prepends the integrity line. MAJOR-4 is closed. **This attack failed to find a defect, and I am saying so plainly.**

---

## HALF TWO — NEW FINDINGS

### MAJOR-1. §4.5's adjudication is right about existence and wrong about meaning. `subagent_tokens` is a high-water context mark, not a consumption total, and §10 sums it into a fuel gauge. (design:148-160, design:266)

First, the adjudication itself. §4.5 is **correct** and round 1 was **wrong**. Searching `~\.claude\projects\C--Users-Chris-git-starcar\64c15364-0933-4d6d-9b2e-d1ddbc918f9f.jsonl` for the literal element form returns six matches, three unique tuples, one per completed dispatch:

```
&lt;usage&gt;&lt;subagent_tokens&gt;71942&lt;/subagent_tokens&gt;&lt;tool_uses&gt;15&lt;/tool_uses&gt;&lt;duration_ms&gt;680368&lt;/duration_ms&gt;&lt;/usage&gt;
```

71942/15/680368, 99390/21/744192, 115565/35/896569 — exactly the three figures design:153 claims. Round 1 enumerated the task-notification's fields as *"task-id, tool-use-id, output-file, status, summary, note, result. No cost"* and omitted `&lt;usage&gt;`; it then grepped for `totalTokens` and concluded absence. Rev 2 adjudicated against it with evidence, which is the process working. **My attempt to overturn the adjudication failed.**

Now the part rev 2 did not measure. §4.5 characterises the residual as *"one conflated scalar that does not separate input, output and cache reads, which bill at different rates."* That is not what the number is. I read all four subagent transcripts under `.../subagents/`, deduplicated streaming partials by `message.id`, and summed:

| dispatch | reported `subagent_tokens` | Σ `cache_creation_input_tokens` | Σ ALL counters | Σ `output_tokens` | under-report factor |
|---|---|---|---|---|---|
| `a9fa2727d341bde1b` | 71,942 | **71,866** | 397,085 | 31,241 | **5.5x** |
| `a56d4b46b4589a001` | 99,390 | **99,283** | 1,022,798 | 48,613 | **10.3x** |
| `a1bccdf2b25d3bd94` | 115,565 | **115,222** | 2,299,330 | 41,323 | **19.9x** |

Every reported value tracks the sum of cache-creation tokens — equivalently the final turn's input context (`in+cc+cr` = 71,868 / 99,285 / 115,224) — to within 0.1-0.3%. It does not conflate input, output and cache reads. It **excludes** them: 100% of output tokens (the most expensive class) and 100% of cache reads. It is "how big did this agent's conversation get," not "what did this agent burn."

Three consequences the design has to answer at this rung, not at a car's desk:

1. **§10:266 — "Cost burned | sum of `cost`, rendered as an approximation" — is not an approximation of anything.** Summing per-dispatch peak context marks produces a number with no unit. The word *approximation* asserts bounded error near a true value; the observed error is 5.5x to 19.9x and the factor grows with dispatch length, so it is not even a stable scaling.
2. **This is the Law 1 defect §4.5 says it is avoiding.** design:158-160: *"a gauge that implies precision it does not have would be a Law 1 defect on the surface whose whole job is honesty about spend."* Correct — and the label chosen implies exactly that precision. `README.md:44` calls the fuel gauge *"the usage meter the whole operation is budgeted against."* A budget meter reading 5% to 18% of true burn, labelled "approximate," is a confident falsehood on a status surface.
3. **The honest source was already on the table and was not considered.** The per-turn `usage` objects in the subagent transcript carry the four counters separated. Round 1 pointed at them (round1:163-170) and rev 2 dropped the thread when it won the existence argument. §4.3:114 lists `cost` as producer-derived; there is no honest producer-derived scalar today, but there *is* an honest producer-derived tuple.

Remedy, any of: name the field for what it measures (`context_peak_tokens`) and render it as context, not spend; derive a real four-counter cost from the subagent transcript and mark it producer-optional per §7:223-225; or mark `cost` out of scope for this train and leave the fuel lane declared-but-dark, which the parked design's `bagged`/`under-construction` positions already have vocabulary for (`docs/design/2026-07-21-v0-yard-skeleton-design.md:158-163`).

**Disclosed-but-wrong does not clear review.** The imprecision is disclosed; the nature and magnitude of it are stated incorrectly, and the disposition follows from the incorrect statement.

### MAJOR-2. §6 moves reconciliation to CI and claims the class closed, but CI cannot read the second source, and the store-internal half only sees what was pushed. (design:181-197)

design:194-197: *"**CI runs reconciliation**, which is the mechanical tier... The class moved from vigilance to procedure and was claimed as closed. It is closed only when a machine asserts completeness."*

§6 defines two assertions and then assigns "reconciliation" to CI without saying which:

- **Bullet 1 (design:189-190), store-internal:** every `dispatched` has a terminal event or an explicit `unknown`. CI *can* run this.
- **Bullet 2 (design:191-193), second source:** *"the sweep enumerates dispatches the runner recorded and asserts each has an artifact."* CI **cannot** run this. The runner's transcript lives at `~\.claude\projects\&lt;project&gt;\&lt;session&gt;.jsonl` on the operator's box. It is not in the repo tree — `git ls-tree` on the base commit has no transcript — and `scripts/Land-Verdict.ps1:56-65` reads it from the local filesystem. A GitHub runner has no such file.

That ambiguity is itself a finding by this repo's own criterion (`CLAUDE.md`: any requirement readable two ways). But both readings fail:

- **Reading A (CI runs both):** unimplementable. A car specs it, goes looking for the transcript in CI, and honest-stops. That is the plan-review scar (`CLAUDE.md`, the three-REJECT plan story) reproduced one rung higher.
- **Reading B (CI runs only bullet 1):** then the *missing-artifact* detection — the literal class MAJOR-2 named, *"a hash cannot report on a file that was never written"* — is still local, still human-triggered, still procedure. The design would then be claiming mechanical closure for the half that was never the problem.

And bullet 1 has its own hole the design does not name. **CI runs on push.** For CI to observe a `dispatched` with no terminal event, the `dispatched` artifact must already be committed and pushed. The canonical failure mode §5 exists for — the session dies, the machine sleeps, the agent is lost — is precisely the case where nothing was committed. The dispatch is invisible to CI not because CI is late but because the evidence never reached it. A ghost that dies before a push is invisible forever, which is the original MAJOR-2 with an extra step.

There is a path the design does not take and should evaluate: the transcript **is** pushed, to `entire/checkpoints/v1`. I verified it — `git grep -c -F 'MAJOR-4. The hash does not cover the fields the board renders' entire/checkpoints/v1` returns hits in six checkpoints' `transcript.jsonl` and `full.jsonl`. That makes a CI-side second source genuinely possible, at the cost of a stated lag (`Land-Verdict.ps1:30-31` already documents the checkpoint source as *"durable, may lag one checkpoint behind"*) and a Law 7 coupling to Entire. That trade belongs in the design, ruled, not discovered by car 2.

### MAJOR-3. The fold is still not computable. Round 1's MAJOR-5 named four holes; rev 2 names four mechanisms, and none of them can be implemented as written. (design:62-106, design:162-179)

**(a) `seq` has no assignment authority, so the two producers cannot agree on identity — and the equality test that backstops it is undefined.** design:68-84: `identity = (dispatch_id, kind, seq)`; *"`seq` disambiguates legitimate repeats (a task-id can notify more than once when an agent is resumed)"*; *"landing is keyed on identity. A sweep re-landing what a hook already landed is a no-op when content matches, and a **loud conflict** when it does not."*

A `SubagentStop` hook fires in the moment and sees only its own firing; it cannot know it is the Nth notification for that task id. The sweep assigns `seq` by position in the transcript (`Land-Verdict.ps1:112-115` already takes `$found[$found.Count - 1]` for exactly this reason). The two producers therefore compute `seq` from different observables and will disagree in precisely the resumed-agent case `seq` exists to handle. Nothing in the design confers assignment authority on either.

Then the equality test. design:81-84 mandates that `at` be producer-stamped and that a `clock` field name the producer — *"a sweep-landed event reconstructing a time from a transcript says so."* So for the same underlying event, hook-landed and sweep-landed copies **differ in `at` and `clock` by construction**. Under the natural reading of "content matches," the normal, healthy case is a **permanent loud conflict on every reconciled dispatch**. That is an instrument that cries wolf by construction, which is what §4.3:122 deletes the cross-check for, quoting the same doctrine. Under the other reading (`seq` differs, so they are different identities), the two copies simply both land and we are back at round 1's MAJOR-5(b) undeduplicated duplicates. Either branch leaves the fold's answer to "did this car finish" order-dependent.

The remedy is cheap and belongs in the design: name the equality set (the judgement fields plus the body hash, explicitly excluding producer-stamped provenance), and define `seq` as derived from a shared observable both producers can compute — the notification's ordinal within the transcript — which the hook then cannot supply, which is itself the ruling the design needs to make.

**(b) `intent` and `ruling` have no identity, so `supersedes` has no target — and Law 2's hold-release is still unimplementable.** design:101-106: *"Every `intent` and `ruling` carries `supersedes: &lt;event-identity&gt; | null`... Rev 1 had no supersession rule, which meant a hold could be set and never released."*

design:69: `identity = (dispatch_id, kind, seq)`, and design:70-71: *"`dispatch_id` is **the runner's id**, namespaced by the session."* An `intent` is, by §4.2's own table (design:93), *"the conductor declares what no dispatch can know"* — it is not a dispatch and has no runner id. **The events that carry `supersedes` are the only events the identity scheme does not address.** The pointer exists; the pointee has no address.

This is round 1's MAJOR-5(c) with a mechanism drawn on top of it, not closed. `constitution.md:19-23` — *"never resists an override"* — still cannot be honoured: the dispatcher can set a hold and cannot express releasing it, because the release event cannot name what it releases.

Three subsidiary holes in the same mechanism, all unaddressed: two intents superseding the same event leaves two un-superseded events for one subject with no tie-break; a `supersedes` citing an event that does not exist, or one from another session, has no defined fold behaviour (ignore? error? treat as null? — Law 4 and Law 1 point different ways); and "latest" (design:106) is not defined as by-clock or by-sequence, in a document that at design:82-84 explicitly warns that comparing producers' clocks is *"a fold that lies quietly."*

**(c) Two terminal events. A reaped dispatch that later returns has no fold rule, and `reaped` is not supersedable.** §4.2's table (design:88-94) marks both `returned` and `reaped` Terminal. §5 (design:174-175) emits `reaped` *"once liveness is declared lost."* Since `expect_by` is a budget and budgets are wrong in both directions (the design's own Q1 concedes this), reaping a live agent is not an edge case — it is the guaranteed consequence of setting the budget too short.

When that agent returns, `returned` and `reaped` share `dispatch_id` but differ in `kind`, so they are **different identities** under design:69. Both land legitimately. §4.1's idempotency rule does not apply — nothing conflicts. §10's fact table (design:262-264) covers "no terminal event" and says nothing about two. The board's answer is undefined, and the supersession mechanism cannot help because design:101 grants `supersedes` only to `intent` and `ruling`.

The structural fix is one sentence and it also answers Q2: make the liveness declaration **non-terminal** — an assertion about what the reaper could observe, superseded by any later terminal event. See the ruling on Q2.

---

### MINOR FINDINGS

**Minor-1. §3 and §13 credit the MAJOR-4 fix to the wrong commit.** design:54: *"Fixed in `cd56035`: the integrity line now covers every byte below it."* design:317 repeats it. The fix is **`75f6a4f`** — `git show --stat 75f6a4f` is titled *"fix: integrity hash now covers the whole verdict, not just the body (MAJOR-4)"* and touches both scripts plus all landed verdicts. `git show cd56035 -- scripts/Land-Verdict.ps1` changes exactly one line of hashing logic: `$document = ($header + $separator + $body)` → `($header + "\`n\`n" + $provenance + $separator + $body)`. It inserts the provenance block into an already-whole-document hash; it did not widen coverage. The irony is load-bearing: `cd56035` is the commit that institutionalised *"every citation is followed before landing"* (design:33), and its own SHA is the one citation in rev 2 that was not followed.

**Minor-2. §11's car table and §13's disposition table disagree about scope.** §11 (design:283-287) gives car 3 *"CI wiring; migrate `docs/reviews/` into the store"* and car 2 *"...brief-template and agent-definition updates."* §13 (design:322-323) additionally assigns `.claude/skills/goodnight/SKILL.md` to car 2 and `docs/setup.md` + `README.md:46-47` to car 3. A car briefed from the scope table writes no documentation; a car briefed from the disposition table does. Round 1's Minor-5 was this exact class and rev 2 fixed that instance without fixing the shape.

**Minor-3. `CLAUDE.md` is still unassigned.** The envelope becomes a standing dispatch rule the moment the harness exists — every brief must mandate it. Round 1's north-star table flagged that car 4 covered briefs and agent definitions while *"`CLAUDE.md` is not named."* Rev 2 dropped car 4 into car 2 and carried the gap with it: neither §11 nor §13 names `CLAUDE.md`. I confirmed nothing in `CLAUDE.md`, `.claude/agents/car.md` or `docs/templates/car-brief.md` mentions an envelope or artifact requirement today.

**Minor-4. The parked design's `:559-561` goes false and nobody is assigned.** `docs/design/2026-07-21-v0-yard-skeleton-design.md:559-561`: *"**The conductor lands each review verdict in `docs/reviews/`** as it happens, which `README.md:20-21` promises."* §9 (design:251-252) retires `docs/reviews/`. Round 1 asked the design to say who fixes it ("rev 4 presumably, but say so"); §10:275-277 corrects two *other* claims about that document and does not mention this one.

**Minor-5. The parked design's status block is now incomplete as well as overstated, and §10 corrects only the overstatement.** design:275-277 correctly observes that the status block at `:9` names §5.4 as rewritten when it is untouched — I verified this: §5.4 (`:190-211`) is registry-sole-ownership-of-position, closed by D11 (`:72`, `:630`), and nothing in the harness design touches it. But `:9`'s enumeration (*"D3, D5, §5.4 and the StateWriter car"*) also **omits** what rev 2 newly does rewrite: §5's `unknown` (design:172-173) adds a value to the car-state vocabulary at `:113-122`, whose six states are `staged`/`rolling`/`at-inspection`/`shopped`/`coupled`/`held`. Rev 2 noticed the status block was wrong in one direction and not the other, and defers both to rev 4.

**Minor-6. §7 blocks the spec on the `SubagentStop` async test but does not name the fallback branch or its cost consequence.** design:215-219 is exactly right to gate. But if the test comes back negative there is no hook for `returned` at all, the producer collapses to a sweep-only transcript scrape, car 2's scope changes materially, and §11's *"roughly 11 dispatches"* (design:289-292) — approved by the owner on that figure — is wrong. Name the branch so a negative result is a known path rather than a re-design.

**Minor-7. Q4 (the safety filter) is not gated the way §7's test is gated, and the in-repo evidence is not cited.** design:345-346 asks whether the fenced block survives the filter and calls it *"untested, and the whole metadata channel rests on it."* §7 blocks the spec on its unverified mechanism; §4.4 does not block on this one. The evidence that the filter fires is in the repo and uncited: `docs/reviews/2026-07-22-harness-design-round1-REJECT.md:48` carries *"[harness: subagent output matched instruction-shaped pattern(s): settings-json, **harness-envelope-tag**...]"*, and the verdict-of-record's own envelope at `:320-329` is HTML-escaped — `&amp;lt;&amp;lt;&amp;lt;STARCAR-ARTIFACT-V1`. Had the harness been running, the repo's most load-bearing review record would have landed as `outcome: error`. That file:line belongs in §4.4, and the round-trip test belongs beside the `SubagentStop` test in §7's blocking list.

---

### NOTES

**Note-1.** The MAJOR-4 guard is real and I watched it fire in both directions (exit 1 twice, distinct hashes). `scripts/Verify-Verdict.ps1:48-52` carries the incident as a comment with the scar attached. This is the Healing Loop's step 2 done properly.

**Note-2.** §3's reframing of the trust model onto **publication** is not aspirational — it is checkable and I checked it. `entire checkpoint explain 1c47c1dde3864f3c129ad6baa6dd827a226e170d` resolves to `Checkpoint 16234ffe6e1b`, matching the Provenance row in the landed round-1 verdict (`:34`). The independently-written copy exists on `entire/checkpoints/v1` and contains the un-normalised original. Row 2 of §3's table is true, verified.

**Note-3 (attack A, partially FAILED).** I was asked whether `unknown` collides with the parked design's separate notion of unknown. It largely does not. The parked design's "unknown" is two different axes — `unknown keys` in the state file (`:377`, `:487`) and the unrecognised-value detector (`:491`, `:515`) — and neither is a car state. More importantly `Car.state` is an **OPEN** vocabulary (`:91`, `:105-106`), so an unregistered `unknown` fires the detector at `needs-attention`, labelled *"unrecognised car state: 'unknown'"* verbatim, explicitly *"a discovery, not a bug"*. It degrades **loudly**, which is Law 1 and Law 4 satisfied. The residual is Minor-5, not a Major.

**Note-4.** §4.4's failure rule collapses two different faults: an *absent* block (the agent did not comply — a brief/agent-definition failure) and a *malformed* block (the format or the filter broke it — a producer failure) both land as `outcome: error`. The board cannot tell a non-compliant reviewer from a broken channel. Law 3 wants them distinguished; the parked design already ruled on this exact shape at `:496-498` (*"'the vocabulary is broken' and 'this value is unknown' are different faults and must not be reported as each other"*).

**Note-5 (attack D, first-hand — the live test).** Complying with the fenced envelope was **easier than round 1's sentinel and still not free.**

- I did have to reason about the parser, in one specific way: I decided not to write any other fenced block carrying the `starcar-artifact` info string anywhere in this report, so that the LAST-such-block rule would select the real envelope. That is the same negotiation round 1 described, but the cost is lower — I could still quote the info string inline in backticks without risk, which the angle-bracket sentinel did not allow, and markdown's own fence-nesting rules give a documented escape (a four-backtick outer fence) that a novel sentinel had none of.
- **Discussing the format did not create a collision this time.** With the sentinel, discussing it *was* emitting it. With an info string, discussing it is not.
- I cannot observe from inside whether the safety filter mangles my output. What I can report is that the filter's own trigger name in the round-1 record was `harness-envelope-tag` and its remedy was neutralising **control tags** (`&lt;` → `&lt;\`). A fenced code block presents no angle-bracket control shape, which is *evidence for* the fix and is not a test of it. Whoever lands this artifact should check the landed file for escaping before treating Q4 as answered. That is Minor-7.
- One residual the design should note: LAST-occurrence still requires the agent to guarantee nothing follows. My report ends with a constitution table and then the envelope; a car report that legitimately ends with a worked example would capture the example.

---

## RULINGS ON THE SIX OPEN QUESTIONS

**Q1. `expect_by` needs a number. BUDGET BELONGS WITH THE DISPATCH, with a shop default, and the board must render overdue as a gradient before it renders `unknown`.** A fixed global budget is wrong by construction here: the three completed dispatches ran 680s / 744s / 897s, and a car implementing a large plan will run far longer than a reviewer. The conductor writes the brief and is the only party that knows the size class — it already writes one (`CLAUDE.md` cost discipline requires a size class per proposal), so the budget is a field it can already fill. Ship a shop-level default so an omitted budget is not an infinite one. And do not let the transition be a cliff: design:176 already says *"the board shows both the elapsed time and that the dispatch is unaccounted for"* — extend that backwards, so a dispatch at 1.5x its budget reads `rolling (42m, expected ≤30m)` before it reads `unknown`. Then a mis-set budget degrades visibly instead of flipping a healthy car to unaccounted-for in one render.

**Q2. Is `reaped` honest? AS SPECIFIED, NO — it launders a guess. Fix it structurally, not by renaming.** Renaming to `presumed-lost` is necessary and insufficient. Two changes make it honest:
1. **The event must carry its own basis** — `reason: expect_by_exceeded`, the budget, the elapsed time, and the `clock`/`producer` that judged it. An event that records *"lost"* without recording *what was observed and by whom* asserts a fact nobody holds. With the basis attached it records a genuine fact: *"at T, producer P observed no terminal event and the budget was B."* That is true regardless of whether the agent was alive.
2. **It must be NON-TERMINAL.** This is the important half and it dissolves MAJOR-3(c) for free: a liveness presumption that any later `returned` supersedes needs no two-terminal-event rule, no supersession grant for terminal kinds, and no ordering tie-break. `constitution.md:17` — *"Unknown states render AS unknown"* — is a statement about a state the board can leave, not a grave.

**Q3. Reconciliation's second source is the runner's. DOES LAW 7 SURVIVE? YES — but only if §4's claim is scoped honestly, which today it is not.** Law 7 requires pluggable adapters and a format a stranger can emit; it does not require every shop to obtain identical guarantees from optional infrastructure. The correct framing is **two tiers**:
- **Tier 1, universal:** every `dispatched` in the store has a terminal event or an explicit unknown. Any shop that emits a conforming `dispatched` gets this. It is the ledger property, and it is genuinely mechanical.
- **Tier 2, producer-dependent:** a second source enumerates dispatches the store never heard of. Only a shop whose runner keeps an enumerable record gets this.

With that split, design:59 (*"the schema is the product; producers are adapters"*) stands. Without it, §6:194-197 claims a mechanical closure that a stranger's shop cannot obtain, which is a Law 7 *and* a Law 5 problem. And Law 5 supplies the missing requirement: **the board must render which tier is in force**, exactly as it renders adapter health. A shop running tier 1 only should see that on the surface, not infer it.

**Q4. Does the fenced envelope survive the filter? UNKNOWN, AND THAT IS NOT ACCEPTABLE AS A STANDING OPEN QUESTION.** §7 sets the correct precedent for this exact situation and §4.4 does not follow it. Rule: add the envelope round-trip to §7's blocking-test list — emit one fenced envelope, land it through `Land-Verdict.ps1`, and read the landed bytes. The test costs one dispatch and the evidence that it might fail is already in the repo at `docs/reviews/2026-07-22-harness-design-round1-REJECT.md:48` and `:320-329`. Designing on an unverified mechanism is, in the design's own words at design:218-219, *"the exact error rev 1 made."*

**Q5. Is a per-artifact file the right grain? YES, KEEP IT.** The class this train closes is *addressability*, and a single append-only file recreates *"an artifact buried in a multi-megabyte JSONL is safe and unusable"* (design:24-25) with better manners. Per-file also gives append-only semantics that git merges without conflict, per-artifact `git log`/`blame`, and a stable URL per verdict — which is what a public showcase needs. ~22 events per train is not a navigation problem; ten trains might be, and §9's generated, CI-checked index is the answer already specified. Revisit only when a single date directory exceeds roughly fifty entries. Do **not** split bodiless lifecycle events into a separate store — that buys tidiness and pays with a Law 6 seam.

**Q6. Should the spec wait for rev 4? NO — that inverts the ladder and the dependency is circular.** Issue #7's Route makes rev 4 *"written against this contract"*; waiting makes each the other's input. But §11:299-301's risk is real and needs a cheaper answer than inversion: **require the harness spec to carry a worked consumer example** — a synthetic train's artifacts folded into the yard board's vocabulary, showing every fact in §10's table derived end to end. That gives the imagined reader a concrete voice at spec rung, is a sentence check performed once by construction, and doubles as Law 7's mandated *"synthetic demo data in-repo"* (`constitution.md:54-55`). Rev 4 then remains the schema's first real review, as §11 says, with the worst surprises already found.

---

## CONSTITUTION CHECK (all eight)

| Law | Verdict |
|---|---|
| **1. Truth** (`constitution.md:11-17`) | **FINDING.** MAJOR-1: §10:266 renders a fuel gauge from a number that under-reads true burn by 5.5x-19.9x and labels it an approximation — *"a confident falsehood on a status surface"* on the surface whose job is spend honesty. MAJOR-3(c): a reaped-then-returned dispatch has no defined rendering. Credit where due: §5 genuinely removes the permanent-rolling ghost, which was the largest Law 1 defect in rev 1. |
| **2. The Dispatcher Commands** (`:19-23`) | **FINDING.** MAJOR-3(b): `supersedes` is granted only to `intent` and `ruling` (design:101), and those are the only events `identity = (dispatch_id, kind, seq)` (design:69-71) cannot address. The hold can still be set and not released. Rev 2 built the release mechanism and did not give it an address. |
| **3. Actionability** (`:25-30`) | **Honored.** design:246-250: sortable, identity-bearing paths plus a generated index that CI checks for staleness; design:176 puts elapsed time and unaccounted-for status side by side, which is the *"a stalled car should look stalled at a glance"* worked example. Note-4 is a refinement, not a breach. |
| **4. Nothing Silently Lost** (`:32-36`) | **FINDING.** MAJOR-2: the mechanism assigned to close the missing-artifact class cannot see the failure mode it targets — an unpushed `dispatched` is invisible to CI, and the second source is not available to CI at all. Partial credit, real: design:145-146 lands an unparseable envelope as `error` *with its body intact*, which is Law 4 done right. |
| **5. Self-Knowledge** (`:38-43`) | **Partially honored, FINDING.** design:81-84's `clock` field — naming *which producer stamped a time* so the fold knows when it is comparing unlike things — is first-rate Law 5 work and is new in rev 2. The finding is Q3's: the design does not require the board to disclose which reconciliation tier is in force, so a shop with tier-1-only completeness cannot tell. |
| **6. One Truth** (`:45-50`) | **Honored in intent, FINDING in execution.** design:255-258's intent/facts split survives round 2 unchanged and is still the best idea in the document — it removes the shared field rather than adding a precedence rule. But MAJOR-3(a) leaves hook-landed and sweep-landed copies of one fact either permanently in false conflict or silently duplicated, and *"where two sources disagree, the board SHOWS the disagreement"* is not satisfied by showing a disagreement that is an artifact of the clock rule. |
| **7. The Stranger** (`:52-56`) | **Largely honored, one scoped finding.** design:221-225 is real Law 7 work: no hardcoded project path (naming `Land-Verdict.ps1:56-65` as the violation to fix — verified, it hardcodes `C--Users-Chris-git-starcar`), the vendor transcript format confined to the producer and documented as a coupling, and `cost`/`producer` marked optional, which closes round 1's Minor-9. The finding is Q3: §6 claims a closure a transcript-less shop cannot obtain, unscoped. |
| **8. Growth** (`:58-62`) | **Honored, strongly.** Rev 2 encodes five incidents as binding rules rather than prose: the three fidelity defects, the header gap found by injection, and — new and best — the sentinel collision that *this review process itself* produced, turned into a format change at design:126-146. And §4.5 adjudicates **against a reviewer with evidence** rather than deferring to authority, which is the loop working in the harder direction. That the adjudication then stopped one measurement short (MAJOR-1) does not diminish that it was the right move. |

---

## WHAT IS GOOD, AND WHERE MY ASSIGNED ATTACKS FAILED

**§7:215-219 is the best sentence in the document and I want it kept verbatim.** *"Whether `SubagentStop` fires for asynchronously-dispatched subagents in the parent's hook context is not yet verified empirically... the spec is blocked on that test. Designing on an unverified mechanism is the exact error rev 1 made."* That is a design naming its own load-bearing unknown and refusing to build on it. Minor-6 and Q4 are both asking for *more* of this, not less.

**§4.5's willingness to adjudicate against its reviewer.** Round 1 was wrong, rev 2 proved it with three verified numbers, and I could not overturn it. In a shop where the reviewer holds REJECT authority, an author who checks rather than concedes is the behaviour the Healing Loop's honest-failure framing is supposed to produce. MAJOR-1 says it stopped too early; it does not say the instinct was wrong.

**§10's intent/facts split survives a second adversarial round unchanged.** Round 1 called it the best idea in the document. It still is.

### Where my assigned attacks FAILED

- **MAJOR-4 re-injection (assigned, empirical): FAILED to find a defect.** Header tamper and body tamper both produce `MISMATCH`, exit 1, from copies made outside the repo. Round 1's exact injection no longer works. The fix is real.
- **MAJOR-6 adjudication (assigned): FAILED to overturn.** `&lt;subagent_tokens&gt;`, `&lt;tool_uses&gt;` and `&lt;duration_ms&gt;` are present as literal elements, six occurrences, three unique tuples, exactly the figures §4.5 cites. Round 1's *"It is not there"* was wrong. My Major is about what the number **means**, which is a different and downstream claim.
- **Attack A, `unknown` colliding with the parked design's vocabulary: LARGELY FAILED.** Different axes, and `Car.state` is an open vocabulary with a loud detector path. Downgraded to Minor-5, which is a documentation-assignment finding rather than a mechanism finding.
- **Attack G, right-sizing / autoimmune: FAILED, ruled right-sized.** The case against is real and I made it properly: night one, zero product code, the yard design parked at rev 3, two more design rounds spent on tooling, and `docs/the-healing-loop.md:73-78` warns young projects to watch this edge hardest — *"start with the right-sized subset, let incidents install the rest."* But the Healing Loop's own test for autoimmunity is *"friction without catches"*, and this gate is catching: round 1 found seven Majors including a fault-injected hash defect that is now fixed and verified; this round found three more, one of which would have shipped a fuel gauge off by an order of magnitude on the surface `README.md:44` says the operation is budgeted against. That is not ritual. Add `CLAUDE.md`'s right-sizing rule (the full ladder is for *"new subsystems, rewrites, cross-boundary contracts"* — this is all three) and issue #7's owner ruling that the harness is product, and eleven dispatches is correct. §11's owner-approval line is verified: commit `66f3c78` is titled *"docs: harness cost line approved by the owner before dispatch"*, which closes round 1's Minor-7.
- **Attack D, the fenced envelope: PARTIALLY FAILED.** It is genuinely better than the sentinel — discussing the format no longer emits it, and markdown supplies a documented nesting escape a novel sentinel could not. The residual is Q4, which is untested rather than broken, and Minor-7 asks only that it be gated the way §7 gates its twin.

---

```starcar-artifact
kind: verdict
gate: design-review
round: 2
target: docs/design/2026-07-22-dispatch-harness-design.md
base: 66f3c78d11584f210a68c615645319bcb3d2232c
outcome: REJECT
findings: {major: 3, minor: 7, note: 5}
abstract: &gt;
  Rev 2 closes four of round 1's seven Majors cleanly and correctly adjudicates
  a fifth against the reviewer with evidence I verified and could not overturn:
  the runner does report per-dispatch cost. MAJOR-4 is closed empirically -
  header-only and body-only tampering both now produce MISMATCH, exit 1, from
  copies outside the repo. Three Majors remain. First, the cost adjudication
  stopped one measurement short: subagent_tokens tracks the sum of cache-creation
  tokens (a high-water context mark) to within 0.3% across all three dispatches,
  excluding every output token and every cache read, so the number under-reads
  true burn by 5.5x, 10.3x and 19.9x - and section 10 sums it into a fuel gauge
  labelled an approximation, which is the Law 1 defect section 4.5 says it is
  avoiding. Second, section 6 assigns reconciliation to CI, but the second source
  is the runner's local transcript which CI cannot read, and the store-internal
  half only sees pushed events, so the session-died-before-commit case it exists
  to catch stays invisible; the design is readable two ways and both fail. Third,
  the fold is still not computable: seq has no assignment authority so the hook
  and the sweep cannot agree on identity, the content-equality rule makes the
  healthy case a permanent false conflict because the clock rule guarantees the
  copies differ, intent and ruling events carry the supersedes pointer and are
  the only events the identity scheme cannot address (so a Law 2 hold still
  cannot be released), and a reaped dispatch that later returns produces two
  terminal events with no fold rule. Making the liveness event non-terminal
  dissolves the last of those and answers open question 2. Rulings given on all
  six open questions; right-sizing attacked in both directions and ruled correct
  at three cars and eleven dispatches, because this gate is catching rather than
  merely adding friction.
```