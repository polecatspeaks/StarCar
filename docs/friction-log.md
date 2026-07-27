# Friction log

Status: Current
Convention: append-only within a session

Raw material for the session-start tooling retro (see the STANDING ITEM in `CLAUDE.md`).
Friction is logged **as it happens**, not reconstructed later - a retro that runs on memory
is a memory test, and this shop's whole thesis is that memory evaporates nightly.

Log anything that cost time, produced a wrong diagnosis, or made a defect possible: a tool
that lied, a default that bit, a missing capability, a command that had to be retried, a
manual step that should be mechanical. Small entries are fine; the point is the pattern
across many, not the severity of any one.

Format: `date | what happened | what it cost | class`.

---

## 2026-07-21 / 2026-07-22 - founding session

| When | Friction | Cost | Class |
|---|---|---|---|
| 07-21 | `board.ps1 add 3 Backlog` rejected: project 6's Status field has only `Todo / In Progress / Done`. The board cannot represent `In Review`, which the ladder requires, or a holding yard. | One failed command; a process state the board cannot express | Missing capability in a data source |
| 07-21 | Branch protection applied with `enforce_admins: false`; API read-back looked perfect; the guard was decorative because agents authenticate as the owner. | ~90s + a junk commit on public `main` + a revert PR | Guard unverified until fault-injected |
| 07-22 | PowerShell 5.1 escaping: a backtick-n inside a double-quoted string was a parser error. | 1 round trip | Shell defaults |
| 07-22 | `git revert -q` - `-q` is not a valid revert flag; the revert silently did not happen and the branch was pushed unchanged. | 1 round trip + a wrong push | Tool flag assumed |
| 07-22 | Variables `$a` / `$b` in a PowerShell one-liner collided such that `Remove-Item $a,$b` resolved to drive `A:` and was blocked. | 1 round trip, whole command lost | Shell defaults |
| 07-22 | `Get-Content` defaults to ANSI in PS 5.1 and silently mangled every non-ASCII character in an extracted verdict. Made the word VERBATIM false while everything appeared to work. | 1 defect, caught only by a byte-count cross-check | Encoding defaults |
| 07-22 | `Set-Content -Encoding utf8` writes a BOM and converts LF to CRLF, so the script hashed one string and wrote another. Every landed file failed its own verifier. | 1 defect, 1 debugging cycle | Encoding defaults |
| 07-22 | Every single commit warns `LF will be replaced by CRLF`. Real warnings are buried in the noise. | Continuous noise on every commit | Missing repo config |
| 07-22 | Task output files (`tasks/<id>.output`) are **0 bytes**. I assumed the transcript was there, diagnosed data loss, and started hand-transcribing a 46k-char verdict. | A wrong diagnosis and a near-miss on a hand-maintained mirror | Assumed a capability without checking |
| 07-22 | `entire` CLI exits non-zero on successful `checkpoint explain`, so exit codes cannot gate on it. | Minor; needed output-based success detection | Tool contract |
| 07-22 | First provenance citation used the Entire session UUID - not a resolvable key. Dead on arrival. | Caught only by following the citation before landing | Untested reference |
| 07-22 | ~~GitNexus stale-index warning fires on every Bash call... Cross-project tooling leak~~ **WITHDRAWN by the owner, same day.** `docs/setup.md:35` already anticipates this: the GitNexus index is trigger-gated on FIRST CODE landing, because there is nothing to index before that. The nag is expected and self-resolving, not a leak. **The retro misclassified a documented, correctly-deferred state as friction** - the log's first false positive, kept visible rather than deleted, because an instrument that cries wolf is worse than no instrument and this one did on its first run. Lesson for the retro itself: check `docs/setup.md`'s trigger-gated table BEFORE classifying a tool's noise as friction. | Zero - it was working as designed | **RETRO FALSE POSITIVE** |
| 07-22 | No CI exists, so `CLAUDE.md`'s definition of "verified" (the pipeline that ships it went green) is unachievable by any car. Three guards are parked on it (#3, #4, #6). | Structural: verification honesty is currently aspirational | Missing capability |
| 07-22 | Landing a verdict takes 7 hand-typed parameters and a remembered command. | Per-artifact manual cost; the class the harness train exists to close | Manual step that should be mechanical |
| 07-22 | I leaned on multiple-choice menus during open design discussion; the owner twice redirected wanting to talk it through. | 2 wasted round trips | Interaction pattern, not tooling |

## Retro #1 outcome (2026-07-22)

Installed, all free and off-the-shelf, all verified rather than assumed:

| Install | Closes | Proof |
|---|---|---|
| `.gitattributes` | The CRLF warning on every commit; protects hashed verdicts from filter rewrites on a fresh clone | All 3 verdicts still verify after the change |
| PowerShell 7.6.3 | The encoding class - 3 defects, all inside the integrity tooling | Tested directly: no BOM on write, non-ASCII round-trips intact, `&&` works |
| GitHub Actions CI | "Verified" was unachievable by our own definition; Pester tests nobody ran; `Verify-Verdict` running only on memory | Green run 29905304676 (19 tests, 3 verdicts); **RED run 29905432689** for the stated reason; green again after revert. **Store migrated (harness #7, Car 3):** the 3 verdicts this proof counted lived in `docs/reviews/` at the time; that directory is retired and its bodies now live in `artifacts/reviews/` (`git mv`, history preserved) - the proof's run IDs and counts are historical and untouched, only the directory the verifier now defaults to has moved |

**Deliberately not installed** (the retro's anti-autoimmune half): PSScriptAnalyzer - would
not have caught the encoding defects; shellcheck - two shell files; markdown linting -
ceremony with no incident behind it. Revisit when something earns them.

**Still open from this retro:** the manual verdict-landing step (the harness train, #7),
the board's missing columns (#8), and the three guards parked on CI (#3, #4, #6) which were
deliberately NOT bundled into the first workflow.

**Scorecard note for the next retro:** these three gates have caught nothing yet, because
they were installed today. If they are still catching nothing in a month, they are pruning
candidates - the Healing Loop counts catches per gate, and a gate that never fires is
ritual.

## 2026-07-22 - continued

| When | Friction | Cost | Class |
|---|---|---|---|
| 07-22 | **Q4 ANSWERED BY LIVE TEST.** The fenced-block envelope survives the platform safety filter structurally - ` ```starcar-artifact ` lands intact - but angle brackets INSIDE the payload are HTML-escaped: `abstract: >` landed as `abstract: &gt;`. A YAML block-scalar indicator is therefore unusable, and any `<placeholder>` syntax would be mangled too. The sentinel version was neutralised entirely; the fence version is mangled selectively, which is harder to notice. | One dispatch, and it answered a question rev 2 flagged as untested | Format constraint imposed by a layer we do not control |
| 07-22 | `subagent_tokens` is a context high-water mark, not a spend total. Reported 71,942 vs cache-creation sum 71,866 (0.1% match) vs **397,085** across all counters - a **5.52x** under-report on the smallest dispatch. Labelling it "an approximation" would have shipped a budget gauge reading ~18% of true burn. | Caught at design rung; would have been a shipped Law 1 defect on the fuel surface | A number that exists is not a number that means what you assumed |
| 07-22 | **CORRECTION, and the more important entry.** The row above originally read 365,867 / 5.1x. That figure came from deduplicating streaming usage records by taking the **first** record per `message.id`; the first partial of each turn carries `output_tokens: 1-4`, so it booked **23 output tokens for a dispatch that emitted 31,241** - a 99.93% loss of the exact quantity the finding is about. Last-per-id gives 397,085 / 5.52x. Verified both ways. | The institution's own record carried a corrupted number for ~20 minutes | Two dedup methods, neither named normative |
| 07-22 | **PROCESS VIOLATION, mine.** The reviewer measured 5.5x. I "independently verified" it, got 5.1x, and shipped my number in the design **without stating that I disagreed with the verdict I was answering**. `CLAUDE.md`: *"An implementer never silently overrides its own reviewer"* - rejection is appealable upward, never around. An appeal with evidence would have been legitimate AND would have been caught, because my evidence was wrong. Silence looked like agreement and hid a defect. | A wrong figure reached the design, the friction log, and a car's future cost derivation | Overriding a reviewer by silence rather than by appeal |

## 2026-07-22 - the harness escalation

| When | Friction | Cost | Class |
|---|---|---|---|
| 07-22 | **The big one.** A distributed-identity protocol (canonicalisation, dedup, ordering, supersession authority) was specified in PROSE through four adversarial design rounds. Majors went 7 -> 3 -> 4 -> 5, clustered in one section, with round 4 noting two of its five were defects that round created with its own fixes. The instrument could not resolve at the defect's scale, so it found different defects forever and every round felt like progress. | 4 review dispatches, ~4 hours, zero product code | **Instrument mismatch - hammer for a watch** |
| 07-22 | Every round inherited "two things write artifacts" without ever asking whether they should. That single unexamined premise imported identity, canonicalisation, equality, clocks, supersession authority, dual storage and aggregation - roughly 8 of 12 Majors. The requirement was DETECT missing artifacts; a detector does not need to be a writer. | The same 4 rounds | **Adversarial review is blind to unquestioned premises** |
| 07-22 | Round 3 correctly ordered a DEMONSTRATION instead of more prose. The demonstration produced was `sweep = dict(hook)` - so the printed proof was sha256(x) == sha256(x), and it caught nothing including two defects in its own path. A prose habit produces prose-shaped evidence even when explicitly told to produce a test. | Round 4 | **Illustrating is not testing** |
| 07-22 | **Third occurrence of one pattern:** a ratified rule already covered the mistake. Law 7 (no hardcoded taxonomies) vs hardcoded lane states. The gating-matrix template (staleness "never suppressed, DELIBERATE, no override") vs demoMode suppression. The Healing Loop ("validated facts land as tests, never only prose") vs a protocol in prose. All three findable by looking; all three caught at review instead. | 3 dispatches' worth of findings that a lookup would have prevented | **The institution knew; the author did not consult it** |

## 2026-07-22 - blocking test answered, and prior art arrives

| When | Friction | Cost | Class |
|---|---|---|---|
| 07-22 | **BLOCKING TEST ANSWERED empirically.** `SubagentStop` fires exactly once per subagent - 74 distinct agent_ids, 74 firings - and fired for 4 of 4 dispatches completing after the probe was wired. P4 confirmed. Payload carries `agent_id`, `agent_transcript_path` (so the producer never scrapes the parent transcript - a Law 7 coupling removed), `last_assistant_message` and `background_tasks`. **But 70 of 74 have `agent_type: ""`** - internal harness subagents doing tool-level work, transcripts already deleted. A producer must filter on `agent_type` or it writes 74 artifacts per session instead of 7. | One probe, wired hours earlier, cost nothing | The answer was already on disk; nobody looked |
| 07-22 | I asserted "74 firings for 6 dispatches, so it fires many times per subagent" from a raw count, without checking distinct ids. Wrong: 74 distinct agents, once each. Corrected within one command. | One wrong claim, caught by measuring | Asserting semantics from a count |
| 07-22 | **`docs/templates/worked-briefs.md` arrived from the owner** - real sanitised dispatch prompts from the ancestor shop, with `[WHY: ...]` annotations. This is precisely the prior art the missing-workflow class predicted we lacked, and it reveals three things the conductor has NOT been doing: fix cycles go to the SAME car (context intact) followed by a DELTA re-review scoped to verify-the-fix, not a fresh full reviewer every round; plans carry BINDING AMENDMENT BLOCKS that supersede stale task text; and reviewers may fault-inject locally provided they revert byte-identical. | **Five full fresh re-reviews at ~110k tokens each where deltas would have served** - the single largest waste of the session | Prior art existed and was not requested |
| 07-22 | **THE CLASS, CORRECTED BY THE OWNER.** I diagnosed "failure due to a non-existent workflow - we haven't created it yet". Wrong. **The prior art EXISTS in the ancestor shop; it was simply not ported so StarCar could access it.** That changes the remedy from "build from wreckage, slowly, driven by incidents" to "ASK". Aggravating: `docs/setup.md`'s trigger-gated table already says "port the ancestor's `session-start.sh` PATTERN" and "generalize from the ancestor shop's `run-suites` / `watch-ci` patterns" - read in the first ten minutes and parsed as *build later* rather than *prior art exists, ask for it*. | ~5 review rounds rediscovering written-down practice | **Prior art exists, unported, and nothing prompts the ask** |
| 07-22 | **A CI FAILURE WENT UNNOTICED FOR AN HOUR.** Run 29913822738: PowerShell Gallery flaked, `Install Pester` errored, every test was SKIPPED, job red. The workflow behaved correctly - it went red rather than passing with zero tests. The conductor did not: I checked CI with `gh run list --limit 1`, frequently caught an `in_progress`, reported it, and never followed up. I said "CI green" repeatedly while a red sat in the history. This violates the repo's own rule - "verified means the pipeline that ships it went green" - and the ported `ops-script-patterns.md` §3 exists precisely to prevent it: "watch to completion, never triggered-probably-fine". **Found because the owner asked about a test count I could not reproduce.** | One unnoticed red; an hour of false "verified" claims | **Checked a status without waiting for a conclusion** |
| 07-22 | Owner reported CI showing 26 passing; measured 19 across six runs before the doc-policy test and 21 after, local and CI agreeing exactly. No run reports 26. Recorded as unresolved rather than conceded - the discrepancy prompted the check that found the unnoticed red, which is worth more than the number. | Nil, and it paid for itself | Report the measurement, not the agreement |
| 07-22 | MSYS path (`/c/Users/...`) leaked into a `pwsh -Command` string during a Pester probe; pwsh resolved it as `C:\c\Users\...` and the probe misfired. Second cost in the same call: the previous invocation's cleanup had already deleted the probe fixture, so the retry also failed before the real fix. Two round-trips for one probe. | Two wasted probe runs | Bash-to-pwsh boundary mangles paths; known class, recurred |
| 07-22 | **Car 2's PowerShell stdin/pipeline traps** (reported by the car, logged by the conductor): (1) `$input` is EMPTY in any advanced script - a single `[Parameter()]`/`[ValidateSet]`/`[CmdletBinding]` silently disables top-level pipeline stdin, so the producer had to be a plain script with manual validation; (2) `$input` is a live enumerator consumed by any intervening statement - capture it as the FIRST executable line; (3) `git commit --only -- <path> -m msg` reads the message as a pathspec - `-m` must precede `--`; (4) array splat binds positionally and never interprets `-Name` tokens - named params need hashtable splat. | Cost absorbed inside one car dispatch; each found by a red, none shipped | The shell's implicit transformations are invisible until run - the probe doctrine's case, four more times |
| 07-22 | TWICE in one session the conductor answered an owner mid-turn question in text emitted between tool calls, where it did not surface - the owner had to ask "did my question get dropped?" both times ("what does this train produce"; "any design needed from my end"). The answers existed; the placement buried them. | Two owner round-trips to recover answers already written | Mid-turn text between tool calls is not a delivery surface; direct questions get answered at the START of the next end-of-turn message, always |
| 07-22 | **Copilot PR-review request: probed, not assumed** (owner-ordered probe on PR #18). Auto-assignment: does NOT happen on this repo (empty at +40s). `gh pr edit --add-reviewer Copilot`: FAILS - GraphQL cannot resolve bot logins. Working route: REST `POST /repos/{o}/{r}/pulls/{n}/requested_reviewers` with `reviewers[]=copilot-pull-request-reviewer[bot]`. | One probe, three observations, zero faith | Bot reviewers are invisible to the GraphQL login resolver; the REST endpoint is the mechanism |
| 07-22 | **TWO ACTORS, ONE WORKTREE - conductor-caused, reviewer-caught.** The conductor pointed the PR-18 fix reviewer at the CAR'S worktree (read-only) instead of cutting a fresh detached review worktree per the established pattern, then resumed the fix car INTO that same worktree mid-review for the Qodo fixes. The reviewer detected live mutation via file mtimes (16:54-16:57 against its 16:58 clock) and correctly quarantined its verdict to the frozen commit. | One review's isolation compromised; verdict salvaged because it pinned the SHA | One worktree = one actor at a time; reviews ALWAYS get their own detached worktree at the frozen SHA - the pattern existed and was skipped for speed |
| 07-22 | **RED CI MERGED AND CALLED DONE** (owner's sibling scar, paid here): PR-18 fixes merged to dev while BOTH CI legs were red on the index-staleness gate - the conductor never watched the run to completion (skipped the Handback-2 index reconcile, then claimed green). Caught by Copilot's second review pass, not by the conductor. | dev red on a public PR; a merge-to-main was one ruling away | Watched-to-terminal-and-recorded is the ONLY green; built scripts/Watch-CI.ps1 |
| 07-22 | **Watch-CI.ps1 caught THREE of its own bugs on first live test** before it could be trusted: (1) first-run-not-latest selection; (2) it grabbed Copilot's `dynamic` review run - a bot green masquerading as CI - at a SHA where both real CI legs failed; (3) a short-SHA input matched no full headSha and reported false-absence. All three found by running against real CI in both directions (must report red on red, must not report green on a bot run). | Nil - found in test, before any reliance | Tools that judge CI must be tested against real red AND real green, and against decoy runs |
| 07-22 | **Unquoted heredoc ran the Windows `at` command via backtick substitution** and injected "The AT command has been deprecated..." into a PowerShell test COMMENT that referenced `` `at` `` in backticks. The corrupted test broke parsing ("The term 'The' is not recognized"). Caught by the suite going red immediately. | One debug cycle | Backticks in an UNQUOTED heredoc are shell command substitution - quote the heredoc delimiter ('EOF') or avoid backticks when generating code via bash |
| 07-22 | **CONDUCTOR VIOLATED ITS OWN SOP, ONE ROUND AFTER CODIFYING IT.** The thread-provenance SOP (resolve every PR thread with a fix+SHA reply) was codified mid-PR-18 and honored on the first review round's 9 threads. Then Copilot's SECOND pass posted 9 more; the conductor FIXED all 9 in code (the correctness train) but never replied-and-resolved their threads. Caught by the OWNER looking at the PR, not by the conductor. | 9 threads left open with no evidence trail; owner had to catch it | Fixing the code is NOT closing the thread; DONE = the unresolved-thread query returns 0, checked before every merge proposal, never from memory |

## 2026-07-23

| When | Friction | Cost | Class |
|---|---|---|---|
| 07-23 | **Environment parity gap between the conductor's two local shells**, surfaced on the FIRST use of the retro-#2 bash/pwsh discipline: the PowerShell tool's pwsh has no `sh` on PATH (`Get-Command sh` empty; Git's `usr/bin` absent from PATH), so `HookLatency.Probes.Tests.ps1:129` (`& sh $hook`) reds locally with CommandNotFoundException while CI is green on identical code at `58fbe23` and the Bash-tool env passes 12/12 (`/usr/bin/sh` present). Deterministic in one env, green in the other - an environment gap, NOT a flake and NOT a code defect. Triage cost one cycle; disposition: run probe suites from an env with `sh` on PATH; probe-hardening (resolve `sh` robustly) is a candidate only if this recurs. | One triage cycle before the first edit of the day | Local shell environments are not interchangeable; a suite baseline is only valid in the env that produced it |
| 07-23 | **GitNexus staleness marker did not advance after a successful reindex:** `node .gitnexus/run.cjs analyze` ran to completion (exit 0, ~07:55) yet every subsequent Bash hook still reports "last indexed: 307f120" across a dozen later commits. Either the analyze indexed without moving the marker the hook reads, or the hook caches. Cost so far: a recurring false-staleness nag per Bash call, tuned out - which is the crying-wolf failure mode the severity philosophy warns about. Not chased mid-train; triage trigger: next session start, or the first time an actual code-navigation query returns stale results. | Recurring noise; instrument credibility eroding | An instrument whose freshness marker lies after a successful run is worse than a stale index - the nag trains the operator to ignore it |
| 07-23 | **`git revert -q` RECURRED, same actor class, same session family:** the founding session logged this exact flag error (this log, 07-22 row 4); the conductor typed it again during the D10 red-injection cycle. This time the failure was LOUD (exit 129, usage text) rather than silent, so the cost was one retry - but a logged class recurring on the logger is the memory-evaporation thesis demonstrating itself. The durable fix is habit-level: revert = `git revert --no-edit` and nothing else. | One retry mid-handback | A logged instance does not immunize the logger; only mechanism or drilled habit does |
| 07-23 | **Entire checkpoint-mirror push failed transiently TWICE** (curl 65 `SEC_E_MESSAGE_ALTERED`, "unable to rewind rpc post data - try increasing http.postBuffer") during dev pushes at ~09:47 and ~10:19. The DEV push succeeded both times (verified by fetch+compare both times); only the transcript mirror lagged, and the hook re-syncs on the next push. Watch item: if the mirror falls persistently behind, the public-transcript invariant quietly degrades - check `entire/checkpoints/v1` freshness at session end. Candidate mechanical fix if it recurs: `git config http.postBuffer 524288000`. | Two verification cycles; no data loss | A mirroring hook that fails quietly-behind a successful push needs its own freshness check, or the invariant it serves rots invisibly |
| 07-23 | **BOARD-VISIBILITY GAP, owner-caught: 11 of 16 open issues were never linked to project 6.** Every conductor-created issue (#10-#21) satisfied the never-drop rule (durable issue exists) while silently bypassing the board - the owner's yard view was incomplete for a day+, discovered when #21 didn't appear. The meta-irony is the finding: this is precisely the lie-of-omission class StarCar exists to render loudly, proven on our own process. Instance fixed (all 11 added, re-audited to 21/21 visible); class fix: the project's built-in auto-add workflow (owner click, free, zero-maintenance) + a doctrine line in CLAUDE.md Tracking with a one-line audit command. | Owner operated on an incomplete board view for a day+ | An obligation satisfied at the ARTIFACT tier can still fail at the VISIBILITY tier; every surface a decision-maker reads needs its own completeness check |
| 07-23 | **Envelope escaping, third observation, first INSIDE a landed record:** the #20 reviewer (Opus) wrote its envelope fields as YAML block scalars (`findings: >`) - the exact form the mandate names as unusable - and the `>` landed HTML-escaped as `&gt;` in the returned record's extracted text. The producer still parsed outcome/findings/abstract (record landed, integrity valid), so the cost is cosmetic contamination of two field values, not data loss. Third observation of the escaping class; first time INSIDE a landed record. | Two field values in one store record carry `&gt;` noise | A format rule stated in a brief competes with a model's format habits; if recurrence continues, the producer should normalise `&gt;`/`&lt;`/`&amp;` on extraction (mechanism over instruction) |

## Retro #3 (2026-07-23 afternoon, session start = the #21 checkpoint drill)

| When | Friction | Cost | Class |
|---|---|---|---|
| 07-23 | **GitNexus staleness ROOT-CAUSED and cleared.** `meta.json` held a dangling `incrementalInProgress` block (started, 10 files to write, never finished): the morning analyze updated `indexedAt` but never advanced `lastCommit`, so the hook's freshness marker lied after a successful exit-0 run. A fresh `node .gitnexus/run.cjs analyze` completed the write - `lastCommit` now at the dev tip, incremental cleared, stats blocks regenerated (1932 symbols, 60 flows). | A day of false-staleness nags, now ended | An interrupted incremental leaves a lying freshness marker; the tool reported success while its completion record dangled |
| 07-23 | **`go.exe` absent from BOTH tool shells' PATH** (pwsh and bash), though installed at `C:\Program Files\Go\bin` and used by yesterday's train. Second instance of the env-parity class (`sh` was the first). Suites still re-derived by full-path invocation. Disposition: live with full-path invocation for now; candidate durable fix if it recurs: add Go to the user PATH (owner's call - machine config, not repo config). | One failed command per shell before locating the binary | Local shell environments are not interchangeable; a toolchain a train used yesterday can be invisible to today's shells |
| 07-23 | **The friction log's own last row was malformed** - the board-visibility entry and the envelope-escaping entry were jammed into one 8-cell table row, so the envelope entry had no date and the row failed HAVAGLANCE on the exact surface retros read. Split into two rows this session. | One entry unreadable for a day | The log is an information surface too; append-under-pressure needs the same read-back a verdict gets |

**Retro #3 outcome:** nothing installed (the anti-autoimmune half: both PATH gaps are
live-with-able, and the GitNexus fix was a re-run, not a tool). The #21 checkpoint drill
PASSED: all five checkpoint claims re-derived at `1182e09` by a fresh conductor - Pester
247/247, Go 5/5 packages, node 50/50, verdicts 49/49, index 112 rows - zero divergence,
so the checkpoint template carries what a cold reader needs. Doctrine dedup check: no new
overlap found.

## 2026-07-23 - evening session

| When | Friction | Cost | Class |
|---|---|---|---|
| 07-23 | ~~**The checkpoint omitted prepared-but-unused dispatch state:** a prior session had already cut branch `car/31-register-css` + a worktree and RESUME-HERE never mentioned it, so the next conductor's `git worktree add` collided.~~ **WRONG CLASS, corrected by the owner within the hour - see the two rows below.** The branch was not "prepared and forgotten" by a session that closed gracefully; session `67913b32` was KILLED mid-work by a credit limit at 16:21:48 (reflog) and never got to write a checkpoint at all. My entry invented a benign story (a tidy session that forgot a line) that fit the evidence and let me proceed, when the true story was a death. The remedy I proposed - "add a checkpoint line for prepared state" - assumes a graceful close and would not have helped, because the killed session wrote nothing. | The wrong remedy, briefly; corrected before it reached doctrine | **A benign explanation that fits the evidence is not the same as the true one - and it is the one that lets work continue, which is why it is the tempting one** |
| 07-23 | **CONDUCTOR IMPROVISED PAST A VISIBLE CONTRADICTION, mine.** In my first two tool calls I read RESUME-HERE saying *"What happens FIRST next session: THE DRILL (#21) - ARMED"* and, in the same breath, the friction log's Retro #3 section saying the drill had ALREADY PASSED - plus commit `38b67c8` whose subject is literally "the #21 checkpoint drill PASSES". The checkpoint was describing a future that had already happened: a stale document, which this repo's own doctrine calls a lying canary. I noticed neither, used the file's still-accurate lower half to pick the next ticket, and proceeded. `CLAUDE.md` lists "improvising past a contradiction instead of stopping on it" among the only REAL failures. Cost was low only by luck - the stale half happened not to matter. | Nil this time, purely by luck | **Stop on the contradiction. A checkpoint that describes a pending future which the git record shows already resolved is STALE, and staleness is detectable at read time by reconciling it against the log** |
| 07-23 | **THE PRODUCER HOOK SILENTLY SKIPPED 2 OF 3 DISPATCHES THIS SESSION** - found while doing forensics on the killed session, not by any instrument. Car 26 (`a3bfb5c078bd8da96`) landed a `dispatched` record at 20:43:54Z; Car 31 (`addbb80a3b64cbf2e`, ~16:38) and its Opus reviewer (`ad2b8215ab13183c4`, ~16:42) landed nothing. `git status` clean, so they were never WRITTEN - distinct from the other known failure mode where the producer writes but the record sits untracked (`1182e09`, caught a day late). All day prior the producer was regular: 20 dispatched records between 10:14 and 15:00. **Why it is structural:** the harness detects a missing artifact as a `dispatched` record with no matching `returned` one, so a dispatch that never writes its `dispatched` record is not overdue - it is INVISIBLE. The instrument built to make a killed session survivable is blind in exactly the case it exists for. Root cause NOT established; hypothesis (UNPROVEN, do not repeat as fact): git index contention with the conductor's own concurrent heavy git work (37 `worktree remove` + 11 `branch -d`) immediately after dispatch. | 2 of 3 dispatches unrecorded; the board would show a third of the truth | **A detector whose input is itself produced by a fallible hook cannot detect that hook's own silence - absence-blindness one layer down** |
| 07-23 | **Owner tooling question, landed rather than answered-and-lost:** "since we're doing web based for starcar... do we need a framework like playwright?" Checked `docs/setup.md`'s trigger-gated table FIRST (retro rule 5) - it has NO browser/visual-testing row, and the repo has zero mentions of playwright/puppeteer/jsdom/headless, so this is a genuine gap and not a documented deferral. The evidence it is earned: #31 (the all-red board) passed all 50 node tests because `board/web/test/minidom.js` has no CSS engine, and was caught by a human eye at first light. Filed as an issue with the trigger stated. | Nil - the question paid for itself by exposing that #31's own fix does not guard #31's class | Never-drop applied to a tooling question; the answer belongs in a ticket, not in a chat reply that evaporates |
| 07-23 | **`Land-Verdict.ps1` names the WRONG CAUSE when handed the wrong transcript.** The backfill path (used precisely because the producer hook had failed - see #32) wants the PARENT session transcript at `~/.claude/projects/<project>/<session-id>.jsonl`, because the `<result>` block lives there. Pointed at the obvious-looking per-task `.output` file (the subagent's own JSONL, whose path the harness hands you directly), it fails with *"No result block found for task id X. A dispatch that never completed has no verdict to land."* The dispatch had completed perfectly; only the input was wrong. A recovery tool that misattributes its own failure is expensive exactly when it is needed, and this one blamed the dispatch for an operator input error. Filed in #32. | One round trip, plus a moment of believing a completed dispatch had died | An error message that states a CAUSE rather than a CONDITION is a lying instrument; it should distinguish "no result block in this file" from "dispatch never completed" and name the path it expected |
| 07-23 | **The register taxonomy had SIX copies and ZERO mechanical pins** until the #31 fix accidentally added the first one - discovered by the Car 31 reviewer, who compared all six by hand and found them agreeing purely by luck and discipline. `compose.js` holds the severity ORDER as well as the set, and the schema enum cannot express ordering, so a reordering drift would have been silent in a way a set-comparison would not catch. The exemplar for fixing it (`sse-event-name.test.js`) was already in the same directory, unused as a pattern. Filed as #37. | Nil so far - all six agree today | A hand-maintained agreement that has never drifted looks identical to one that cannot drift; only a pin tells them apart |
| 07-23 | **The founding-session Pester-install flake RECURRED, and this time the instruments caught it in minutes instead of an hour.** `Watch-CI.ps1` exited 10 (RED) on `b675062`: windows-latest failed, ubuntu-latest passed, cause `Install-Module Pester` losing all 3 retries to "No match was found ... module name 'Pester'". The workflow's own guard did exactly its job - retried 3 times, then errored with the words "INFRASTRUCTURE red, not a code red", which is the retry-and-label shape added AFTER run 29913822738 sat unnoticed for an hour. Flake calibration honored rather than assumed: the commit was docs-only so a code cause was implausible, but the disposition waited on OBSERVING a re-run of identical code, which passed both legs (run 30044804795). Classified flake; noted; moved on. | ~4 minutes and one re-run; no wrong claim made in between | The same substrate flake, twice - but the second time a watcher exit code, a retry guard and a labelled error message converted an hour of false "CI green" into a four-minute triage. This is what a landed instrument is worth |
| 07-23 | **`Watch-CI.ps1` refused to watch an unpushed commit, correctly, and the refusal was the useful output.** Between the CI re-run and the re-watch, the producer hook auto-committed a dispatched record, moving HEAD from `b675062` to `f358cad`. Watch-CI exited **1** with "PUSH-PARITY FAIL: f358cad44 is not on origin/dev. Push first - you cannot watch a run for a commit the remote has never seen." Exit 1 is could-not-observe, kept deliberately distinct from exit 10 red - so the tool reported honest ignorance instead of inventing a conclusion, which is the precise failure it was built to prevent. | Nil - one push | An auto-committing hook silently moves HEAD underneath the conductor; any tool keyed to "current HEAD" must assert push-parity rather than assume it |
| 07-23 | **CONDUCTOR MEASURED AN INSTRUMENT'S VALUE BY WHAT THE OLD INSTRUMENTS FOUND, mine.** Asked whether Playwright would tighten adversarial review, I scoped it as "one class, roughly neutral elsewhere" - and derived that from counting today's actual findings (1 of 4 Minors would have been browser-found). That count is biased BY CONSTRUCTION: it measures what the current instruments DID find, which by definition excludes what they CANNOT see. The owner corrected it in one sentence ("playwright gives the adversary better tooling to dig out those majors for us"). Re-derived properly, a real browser opens at least five attack classes that are currently UNREACHABLE rather than merely expensive - visibility/occlusion/contrast (a condition present in the DOM but invisible to the eye passes every existing test and fails HAVAGLANCE outright), end-to-end store-to-pixel fault injection (the nine-wire-fields scar class), dynamic failure states observed as the user sees them, the discovery path end to end, and rendered-versus-declared completeness. | A materially understated value case, corrected before it reached the ticket's scope | **This log's own founding meta-class, committed one level up: "an absence is invisible unless something asserts completeness." I applied absence-blindness to findings and forgot it applies to INSTRUMENTS - you cannot estimate a new tool's yield from the yield of the tools that could not see** |
| 07-23 | **A CAR CHALLENGED ITS BRIEF TWICE; ONE CHALLENGE WAS RIGHT AND FOUND A REAL DEFECT, THE OTHER WAS WRONG AND WAS NOT CONCEDED.** Car 33 disclosed two findings against the conductor's brief. F2 (the stated Pester baseline of 247 did not match its observed 250) is CORRECT and led to #41: `StoreIntegrity.Tests.ps1` iterates the real `artifacts/` store, so the Pester total tracks record count one-for-one (112 records = 247 tests, 115 = 250) - which means every brief quoting a fixed Pester number is wrong by construction, because the harness's own producer writes a record per dispatch and so the brief's own dispatch invalidates the number it quoted. F1 (that the `sh`-not-on-PATH gap is not logged) is WRONG - it is at this log's line 104 - and was DISPROVED rather than conceded, per the rule that conceding a finding you could have disproved is itself a failure. Both halves matter: a car that challenges its brief is the process working, and a conductor that folds to every challenge is the agreeableness failure wearing a humble face. | Nil - F2 paid for itself by exposing a lying-instrument class | **The right response to a challenge is verification, not deference and not defence. Check it, then say plainly which way it went** |
| 07-23 | **A CONDUCTOR'S BRIEF ASSERTED A DEFECT THAT DID NOT EXIST, and a weaker reviewer would have confirmed it.** In the Car 33 reviewer brief I wrote that the new test hardcodes `rgb()` triples, called that "a second copy of a value owned by the stylesheet", and instructed the reviewer to "rule on whether that is a Law 6 problem". It is not: `grep` finds no colour literal in the test at all - both ground truths are derived at runtime from the live stylesheet via free-floating probe elements, which is the Law 6-CORRECT construction and self-updates if the palette changes. The `rgb()` values I saw came from the car's REPORT (observations it printed), not from its code, and I did not open the file before writing the brief. The reviewer disproved it and said so plainly ("the brief's premise was incorrect, and in the car's favour"). | Nil - the reviewer refused the premise. The cost was potential, not realised | **Agreeableness pointed DOWNWARD: a brief that names a suspected defect supplies the gate with a conclusion to confirm. Reviewers gradient toward the dispatcher's framing exactly as they do toward an author's. State the QUESTION ("is any stylesheet-owned value duplicated in the test?"), never the ANSWER - and open the file before asserting anything about its contents (reading is not verifying, and I did not even read)** |

## 2026-07-24 - morning session (runtime switch: Claude Code to Copilot CLI)

| When | Friction | Cost | Class |
|---|---|---|---|
| 07-24 | **EVERY DISPATCH DENIED, FAIL-CLOSED, by the old runtime's hooks running under the new one.** The owner switched runtimes (Claude Code to GitHub Copilot CLI on Claude Fable 5). Copilot loads `.claude/settings.json` as "repo settings" via a Claude-compat layer and runs its hooks - all `sh -c` wrappers. `sh` was not on the PowerShell PATH, the preToolUse hook errored, and Copilot treats preToolUse errors as FAIL-CLOSED: the Car 46 fix-cycle dispatch was denied three times. Measured layer by layer (process log quoted in #47): (1) `sh` unresolvable; (2) after a shim fixed that, `entire hooks claude-code pre-task` fails with "tool_use_id is required" - Copilot's payload is not a Claude payload, so the compat hook is structurally wrong, not mis-pathed; (3) hook config is CACHED at session start, so no in-repo fix takes effect until the CLI restarts. Fixes landed: native copilot-cli entire hooks (`.github/hooks/entire.json`, PowerShell variants added - the generated file was bash-only and would have reproduced failure (1) one layer down), fail-closed claude-code PreToolUse removed, Git bin on user PATH + `sh.cmd` shim machine-level. The fix cycle is PARKED on the restart. | A morning of dispatch attempts + the Car 46 fix cycle parked behind an owner restart | **A runtime switch is a substrate change: every hook, payload shape, and event name is an unverified claim the moment the runtime changes - and a fail-closed gate wired to a stale substrate denies everything, honestly** |
| 07-24 | **The third dispatch-denial produced a WRONG-LOOKING success signal first:** `entire enable --agent copilot-cli` printed "Ready." and installed 8 hooks - but the generated `entire.json` carried only `bash` commands, on a Windows box where bash-via-sh was the exact thing already broken. The installer succeeded; the installed thing could not run. Caught by reading the generated file before trusting it, per the branch-protection scar's read-back lesson (a clean read-back is not a fired guard). | One file read; would have been a fourth denial after restart | An installer's "Ready." asserts installation, not operability - the gap between them is where decorative guards live |
## 2026-07-24 - Car 46 (checkpoint reconciliation + brief-question rule)

| When | Friction | Cost | Class |
|---|---|---|---|
| 07-24 | **THE CHECKPOINT'S FRONTMATTER IS MACHINE-MANAGED, discovered by probe rather than assumed (#46).** Tasked with pinning a base-commit marker into `RESUME-HERE.md`, I read its YAML frontmatter twice, roughly 40 minutes apart, with no edit performed in between: `modified` advanced from `2026-07-23T22:18:52.204Z` to `2026-07-24T09:57:32.848Z`, and `originSessionId` changed from `e92f5a0b-1b9e-4913-98b3-c319b4d5e90b` to `548526c8-f375-4cea-b3b9-3ea7f3a1f0b9` - this car's OWN session id, matching the worktree path the brief assigned. Something in the memory subsystem rewrites these fields as sessions touch the file; a field pinned there is not durable. The brief itself flagged this as an open, unprobed question ("I do not know whether that frontmatter is machine-managed... neither should you until you check") rather than pre-answering it - probing confirmed the risk, so the checkpoint-base marker lands in the document BODY (an HTML comment) instead. | Nil - caught before the design committed to an unsafe location; would have been a silently-vanishing marker otherwise | **A probed "I don't know" in a brief is not a gap to fill in by assumption; the same file re-read minutes apart can already answer it** |



- 2026-07-24 (owner, mid-#47): PAUSE-AND-RETRO requested after the design-review train: 'some things happened outside my expectations and I want to look at them.' Standing item for the retro immediately after round-3 verdict lands; owner names the surprises.

- 2026-07-24 (owner-classified, own drop, new class): NO ONBOARDING STEP FOR NEW-FAMILY AGENTS. The runtime switch put a new agent family to work with no documentation review; three design REJECT rounds followed, partly attributable to missing substrate context (the round-4 doc pass found the adapter doctrine, the vector prior art, and the AGENTS.md constraint - each would have changed rev 1). Owner proposal + conductor counter-proposal APPROVED: onboarding review is conductor/session-tier (cars stay brief-bound per the carrier rule), trigger-gated (new family, new agent identity, resume-after-compaction - never a daily ritual), and lands as the CONTENT of #47's neutral front door (tiered reading path extending doc-map's contributor path), not a parallel surface.

- 2026-07-24 (conductor, owner catch): restart-gated probe treated as parked instead of actionable - after #47's train landed, the SessionStart verification probe (design 2c row 4) was left 'awaiting next restart' and the conductor moved to the next ticket, when the owner was PRESENT and a restart costs one sentence. Class: a gate whose key is held by the human reads as 'blocked' to an agent when it should read as 'ask now'. Same family as the pressure-release-valve reflex - report the gate to whoever owns the key at the moment it becomes the blocker. Fix: prompt the owner to restart when restart-gated work is the next item and the owner is engaged. (Ruled by owner in-session.)

- 2026-07-24 (conductor, restart probe result): THE FOUR SESSIONSTART GUARDS ARE SILENT UNDER COPILOT CLI, and the entire-CLI fallback wrapper breaks the whole SessionStart invocation. Probed on the deliberate restart (design 2c row 4, Copilot leg). Evidence from this session's events.jsonl: exactly one `hookType: sessionStart` invocation fired, `success: false`, stderr `syntax error: unexpected end of file from 'if' command` - matching the fifth SessionStart line (the entire wrapper with the escaped-JSON printf fallback; the simple-form entire wrappers on other events succeed, and entire.log shows userPromptSubmit/SessionStart lifecycle events flowing). All four shop guards exit 0 under manual `sh` with correct output - the intersection dialect itself is FINE - but none of their stdout reached the agent context: Copilot runs SessionStart hooks and surfaces failures in events.jsonl, it does not inject hook stdout into the conversation. Corroborating: the PREVIOUS session's fresh start failed `'sh' is not recognized` (PowerShell parent, different failure), its resume failed with the same syntax error. Cost: nil this time (the guards' content was re-derived by hand in 4 tool calls via RESUME-HERE.md), but the class is DECORATIVE GUARD - a hook that runs-and-is-unheard is the branch-protection scar with a different transport. Landed: #50, design 2c row updated. | Guards announce to nobody on one of two runtimes | Decorative guard (output channel unverified per runtime) |

- 2026-07-24 (conductor, self-caught same minute): EXTRACTOR LAST-MATCH SELF-POISONING. extract-copilot-report.py picks the LAST tool.execution_complete whose data contains the needle substring; the conductor's own diagnostic search for the verdict events (a powershell tool call whose OUTPUT quoted the toolCallIds) then became the newest matching event, so the next two extractions landed 325-char fragments of the diagnostic instead of the 8049/4437-char verdicts. Two wrong verdict files were landed and force-replaced within minutes (Land-Verdict's already-exists refusal was the tripwire that made the mistake loud - the guard worked). Class: a search whose results enter the corpus being searched - needle-based last-match extraction is unstable under agent self-observation. Fix applied in-session: exact toolCallId field match, not substring-over-data. The extractor (session-files tool, #47 backfill path) should gain an exact-id mode if promoted to the repo. | Two force-relands + one diagnostic round trip | Tool self-poisoning (observer in the corpus) |

- 2026-07-26 (conductor, morning open): Claude-in-Chrome extension not connected at session
  start (`tabs_context_mcp`: "Browser extension is not connected"); the yard was opened via the
  `Start-Process <url>` shell fallback instead. Cost: one round trip. Class: a browser-automation
  dependency is an unverified capability at session start; for "open a page" the one-line shell
  fallback always works - reach for it first when the task is that small.

- 2026-07-26 (conductor, self-caught by post-mutation verification): PROJECTV2 OPTIONS UPDATE
  IS A REPLACE, NOT A MERGE. Executing #8 (add Backlog / In Review columns), the
  updateProjectV2Field mutation regenerated ALL option ids and orphaned every item's status
  assignment on the owner's live board (18 Done + 33 Todo became 51 null) - GitHub does not
  match options by name. Caught in the very next command because the baseline distribution
  was snapshotted BEFORE mutating; recovery re-derived every status from issue state
  (CLOSED = Done, OPEN = Todo), reproduced the baseline exactly (18/33), 51/51 restored,
  verified. Cost: ~3 minutes and one incident on a live surface. Class: a config mutation on
  a third-party API is a guard-unverified-until-fired case - snapshot the per-item state
  (not just counts) before touching field definitions, and verify the read-back immediately
  after. Second lesson, cheap only by luck: the count-only snapshot happened to be
  reconstructible from issue state; a board with hand-curated statuses would not have been.

- 2026-07-26 (reviewer-caught, conductor honors the cap): THE SWIRL DOCTRINE FIRED ON ITS
  FIRST LIVE TEST. Tooling train #50+#32: round 1 REJECT (5 Major), fix cycle closed all
  eleven findings, round 2 REJECT (4 Major) - with 4 of 4 new Majors CREATED BY THE FIXES
  and 3 of 4 clustered in one file (session-start-record.sh). Two of three swirl triggers
  fired; the reviewer set a cap (no round 3 on the delivery mechanism) and escalated the
  unquestioned premise: that the record script must determine session-batch identity by
  itself, when its stdin is occupied and can never read the payload carrying session_id.
  Two mechanisms were written for one requirement; each was correct against the tests
  written for it; each lost guard output under conditions those tests did not model. Cost:
  one extra review round, cheap - the cap fired BEFORE a third mechanism was written, which
  is the exact failure the doctrine was built from (the harness-design 4-round scar).
  Class: the reviewer-held cap works; a conductor cannot detect its own churn, and did not.

- 2026-07-26 (reviewer-disclosed, blob-level restoration proven): PWSH .NET STATIC FILE
  APIS IGNORE Set-Location. The round-4 reviewer's first injection wrote to the SHARED
  CHECKOUT instead of its worktree: [System.IO.File]::* resolves relative paths against
  [Environment]::CurrentDirectory, which Set-Location does not change. Restored and proven
  (working blob == HEAD blob, git status clean); the meaningless injection result was
  discarded rather than reported. Cost: one wasted injection cycle plus a transient
  shared-checkout mutation. Class: pwsh maintains TWO current directories; any .NET static
  API call in a worktree context must use absolute paths. Same family as the MSYS path
  leak (07-22) - the shell's implicit path resolution is invisible until run.

- 2026-07-26 (rotation-drill outcome + the round-4 root cause): GREEN IN THE AUTHOR'S
  ENVIRONMENT IS A CLAIM ABOUT THAT ENVIRONMENT ONLY. Both round-4 Majors (a test red
  under detached HEAD - the exact state of PR CI and every reviewer worktree; a runner
  emitting a confident falsehood when CLAUDE_PROJECT_DIR is unset - the exact state of
  every non-Claude-Code shell) were invisible from the car's attached, Claude-flavored
  worktree and 100% reproducible in the environments the feature targets. The rotation
  drill itself PASSED: a fresh reviewer reconstructed the four-round series from landed
  verdicts alone, replicated the prior reviewer's injections by name, honored the r2 cap
  correctly, and caught what continuation plausibly would have caught plus the
  environment class - the verdict template carries everything it claims to.

- 2026-07-26 (CI-caught, conductor hotfix): THE UBUNTU LEG CAUGHT WHAT NO DESK REVIEW
  COULD. The tooling-train merge went red on ubuntu only (run 30205842313): the new
  fifth-line wiring test's stub helper hardcoded the Windows PATH separator (";") and
  wrote its stub without the exec bit - Git-bash on Windows forgives both, Linux forgives
  neither, so `command -v entire` missed the stub and the hook honestly took its absent
  branch. Five review rounds (two reviewers, both on this Windows box) could not have
  seen it; the second CI leg (#14's whole purpose) fired on first contact. Fixed by
  conductor hotfix within the five-leg boundary (mechanical, test-infra-only, red
  observed in the only environment that can exhibit it, post-hoc adversarial review
  dispatched). Class: PATH shape and exec-bit semantics are PER-OS; any test that
  manipulates PATH or fabricates executables must use [IO.Path]::PathSeparator and grant
  the exec bit - the same environment-class lesson as r4, one axis over (OS, not
  attachment state).

- 2026-07-26 (CORRECTION to the entry above, ordered by the hotfix post-hoc review - the
  gate biting the conductor, which is the process working): the "UBUNTU LEG CAUGHT WHAT NO
  DESK REVIEW COULD" entry overstated two counterfactuals, both mine. (F2) "no desk review
  could" is DISPROVED by the record: round-1 verdict section A3 examined this exact
  PATH-stripping helper for CI portability and cleared it - a hardcoded separator is a
  STRUCTURAL fact, settled by reading, and a reviewer looked and missed rather than
  could-not-have-seen. (F3) the commit's "only environment that can exhibit it" clause is
  FALSE - WSL Ubuntu-24.04 is on this box and the post-hoc reviewer reproduced the failure
  end-to-end there in one command, byte-exact fallback JSON included. (F4) "182/182" was
  stated without its attached-vs-detached coordinate (true attached; detached is
  181/0/1-skip). The CLASS LESSON STANDS unchanged; what falls is the inevitability
  framing - and the difference matters because "could not have seen it" forecloses the
  reading-check remedy that #57 now carries (two class siblings sat one grep away, one a
  vacuously-green probe on the very ubuntu leg this incident vindicated).

- 2026-07-26 (owner-observed calibration reading, positive): THE BRIEF GATES HELD AGAINST
  TRAINED HELPFULNESS. During the #62 pre-merge one-liner, the car noticed an ADJACENT
  same-class defect one line away and - instead of fixing it unauthorized (the default
  agent gradient: scope creep dressed as helpfulness) - disclosed it with the exact words
  "a contradiction I don't own" and left it. The owner's read: "Normal subagents would
  have been overly helpful there." Why it worked: the brief put disclosure on the SUCCESS
  branch ("do not fix beyond the ruled list without it being named"), which is the
  gradient-shaping doctrine operating as designed. Cost: zero - one authorized follow-up
  line. Class: truth-as-success-shape converts the helpfulness gradient into disclosure;
  keep writing bounded scopes with named escape hatches into every directed brief.

- 2026-07-26 (conductor self-caught, owner-adjudicated correction): THE CONDUCTOR FABRICATED
  A COMMIT SHA IN A LANDED VERDICT HEADER. Landing the tooling-65 r1 verdict, the conductor
  typed the base as 4f2ae978d1e5... where the real commit is 4f2ae978d4628c67... - a full
  40-char SHA invented by extending a short prefix from memory, in the header field the
  record itself names "the lookup key". Caught minutes later by the conductor re-deriving
  the SHA via git rev-parse; the three view-train verdicts checked clean. Correction path
  hit the reality-vs-spec valve: Land-Verdict.ps1's overwrite guard refused ("a record, not
  a draft"), the conductor escalated instead of self-adjudicating -Force, and the owner
  ruled option (a): re-land with the corrected header, disclosure in the commit, wrong
  version preserved in git history and on the checkpoint branch. Owner's framing: "an
  honest effort when the machine breaks. Until we figure out the correct pressure valves."
  Class: CONDUCTOR-TYPED COORDINATES ARE UNVALIDATED - Land-Verdict accepts any string as
  -Base; one git rev-parse --verify (and a check that the body's own base references match)
  would have refused the fabrication at landing. Same class as the #65 gate one layer up:
  hand-typed coordinates need mechanical resolution wherever they enter a durable record.
  Tooling fix is small and belongs in Land-Verdict itself.

- 2026-07-27 (conductor, morning open): the runtime's auto-mode classifier denied a COMPOUND
  command because one segment was `git clean -fd` (worktree reset per the re-dispatch spec) -
  the non-destructive copy bundled with it was lost too. Splitting into copy, then a targeted
  Remove-Item of the single untracked file, sailed through. Cost: one split-and-retry round
  trip. Class: bundling a destructive op into a compound command forfeits the whole command;
  sequence destructive steps alone, after their prerequisites have already landed.

## 2026-07-27 - reconstruction of the 07-26 evening (#74)

Rows marked RECONSTRUCTED were never logged live - they are rebuilt from durable
artifacts the morning after, which is itself the cost the first row records.

- 2026-07-26 evening, RECONSTRUCTED (owner-caught 07-27, the finding that opened #74): THE
  LOG ITSELF LAPSED. Eight rows logged by 20:05, then ZERO across the five busiest hours
  (20:05 -> 00:58: #65 rounds 2-5 incl. the second swirl escalation and the owner's
  amputation ruling, the #67 three-round train, the #69/#71 car + r1 REJECT). The morning
  retro then ran on a log that looked complete and was not; the gap was found by the OWNER
  asking "what happened?", not by any instrument. Cost: the evening's tool-level friction
  evaporated with the context; a transcript-mine dispatch is reconstructing what it can.
  Class: an as-it-happens discipline has no backstop - vigilance decays exactly when the
  session is busiest, which is when friction is densest; only a close-time completeness
  assertion (the #74 goodnight sweep, landed same day) distinguishes an empty evening from
  an unswept one. Note: caps, the r4 rotation, and review findings from the window are NOT
  re-rowed here - the landed verdicts already carry them; this log carries what THEY do not.

- 2026-07-26 ~20:30-21:58, RECONSTRUCTED from the commit record and verdicts: THE SWIRL
  FIRED TWICE IN ONE DAY, second time on #65 - r3 REJECT-ESCALATED (cap fired, owner
  adjudication owed), owner ruled AMPUTATION of the citation-resolver header (de9cda2), r4
  ran a fresh-reviewer rotation on the mechanical round-4 trigger (first non-drill use),
  APPROVE at r5. Same class as the morning's #50+#32 swirl and the founding harness scar:
  a PROSE artifact carrying structured claims (a header asserting resolver coverage)
  attracts churn that closes findings and opens new ones in place. Cost: two extra review
  rounds before the amputation dissolved the defect generator. Class: when successive
  rounds rework the same prose surface, the surface is the defect - remove or mechanize it
  rather than revise it; the swirl doctrine detects this but only AFTER rounds are spent,
  so the cheaper catch is at design time (match the instrument to the artifact).

The four rows below were RECONSTRUCTED by a read-only transcript-mine dispatch (#74,
task-id friction-mine-0726-evening) against the conductor-session mirror at
`entire/checkpoints/v1:f6/15a8f220c5/0/transcript.jsonl`; each carries a grep-able
locator phrase so a second party can re-derive it from that file.

- 2026-07-26 ~20:05, RECONSTRUCTED (mined): GITHUB PROJECTS PROPAGATION RACE - a compound
  `gh project item-add; item-list; graphql update` for issue #72 failed with `Could not
  resolve to a node with the global id of ''` because the item-list read ran before the
  just-added item propagated; a `Start-Sleep -Seconds 3` retry succeeded. Cost: one
  failed command + retry. Class: a just-mutated ProjectsV2 item is not immediately
  readable - board writes need a poll-until-found or a propagation buffer, never an
  assumption of read-after-write consistency. (Locator: grep the transcript for the
  quoted error.)

- 2026-07-27 ~01:01, RECONSTRUCTED (mined): WRITE-BEFORE-READ GUARD TRIPPED AT THE WORST
  MOMENT - the goodnight rewrite of `RESUME-HERE.md` was refused with `File has not been
  read yet. Read it first before writing to it.` although the file had been read earlier
  in the same marathon session; a throwaway 10-line Read + retry succeeded. Cost: one
  failed Write + extra Read at the single most time-pressured moment of the close.
  Class: the harness's read-before-write credit does not durably survive a very long
  session - defensively re-Read any long-lived file immediately before a late-session
  Write. (Locator: grep for the quoted refusal.)

- 2026-07-26 ~22:54, RECONSTRUCTED (mined): PARTIAL GIT-ARCHIVE EXTRACTION IS
  WRONG-BY-DEFAULT - the #67 r1 reviewer's base-suite re-derivation extracted only
  `board/web` from `git archive` and two suites failed on repo-relative dependencies
  (`artifacts/`, `schema/`) outside that directory; full-tree extraction was the
  reproducible form. Cost: one wasted archive+run cycle inside a review. Class: a
  subdirectory is not self-contained for archive-based suite reproduction when tests
  carry repo-relative paths - full-tree is the default, not the fallback. (Locator:
  grep for "A first attempt extracting only".)

- 2026-07-26 20:31-21:51, RECONSTRUCTED (mined, lower confidence as friction): the
  GitNexus staleness notice fired identically after EVERY commit across all four #65
  car rounds, and each round spent a disclosure clause on it - four disclosures of one
  unchanged, already-accepted condition in one evening. Cost: negligible per instance;
  the hazard is the crying-wolf shape this log has already rowed twice (07-22, 07-23).
  Class: a notice that repeats unchanged after acceptance should self-suppress or fire
  only when newly consequential; watch for recurrence before building anything.

- 2026-07-27 ~08:00 (conductor, live): LAND-VERDICT'S -TaskId IS THE DISPATCH ID, NOT THE
  ENVELOPE'S task-id - two id namespaces share one name. Fed the envelope form
  (view-69-71-review-r2), got #32's documented lying error ("A dispatch that never
  completed has no verdict to land") for a dispatch that had completed minutes earlier;
  the r1 verdict header held the answer (its "task id" is the dispatch hash). Cost: one
  failed landing + one diagnostic grep. Class: a parameter that shares a name with a
  different field on the same artifact's envelope will be fed that field eventually -
  rename one, or accept both and resolve; belongs with #32's error-message fix.

- 2026-07-27 ~08:55 (conductor, live, two shell traps in one board-update sequence, second
  produced a LYING third-party error): (1) backtick-escaped quotes inside a double-quoted
  `gh api graphql -f query="..."` mangled at the parser ("Expected VALUE, actual:
  UNKNOWN_CHAR") - fixed by GraphQL variables, no inline escaping. (2) The retry passed
  `-f o=$map[$n]` in ARGUMENT MODE, where pwsh expands only simple `$var` - GitHub
  received the literal string "System.Collections.Hashtable[69]" and answered "The single
  select option Id does not belong to the field", which read as option-id regeneration
  (the 07-26 ProjectV2 scar) and cost a re-derivation chase before the real cause
  surfaced. Read-back verification caught both failures immediately (the mutation never
  landed silently). Cost: two failed rounds + one wrong-diagnosis chase. Class: pwsh
  argument mode does not expand index/member expressions - assign to a simple variable
  first; and a third-party error names ITS view of the symptom, not your cause - check
  what you actually sent before believing what the server says it means.

- 2026-07-27 ~09:25 (CAR-CAUGHT, conductor's defect): THE #75 BRIEF NAMED A PRECEDENT THAT
  DOES NOT EXIST. The brief told the car to add `TaskID` to `board/fold/fold.go`'s
  `DispatchEntry` "following the recordDir precedent" - but recordDir is NOT on that struct
  or anywhere in `board/fold`; it lives in `board/assemble`. Worse, `board/fold` is the
  CROSS-LANGUAGE CONFORMANCE KERNEL (`schema/vectors/README.md`: the landed pwsh detector
  and the Go port both conform to the fold vectors under the D18 cross-verifier), so
  following the brief would have put a Go-only field into a two-implementation contract.
  The car honest-stopped, cited its greps, and implemented at the correct layer. Cost: nil -
  the gate caught it. Aggravating: the conductor HAD grepped `DispatchEntry` and seen its
  full field list (no recordDir in it) minutes before writing the brief, then wrote the
  precedent claim anyway - reading and then asserting the opposite is worse than not
  looking. Class: A BRIEF'S "FOLLOW THE PRECEDENT AT X" IS A STRUCTURAL CLAIM AND MUST BE
  RESOLVED BY OPENING X, never by memory of a related file; same family as the 07-23 row
  where a brief asserted a defect that did not exist. What made it cheap: the brief put
  honest stops on the SUCCESS branch, so the car reported the contradiction instead of
  improvising - the gradient-shaping doctrine paying for itself a second time (cf. the
  07-26 owner-observed calibration row).

- 2026-07-27 ~09:29 (conductor, self-caught by verifying instead of believing): A FAILED
  TASK REPORTED A HEALTHY SERVICE, AND LEFT AN UNTRACKED ORPHAN. The background task
  running the board server (`go run ./server`) reported exit 255 / "failed", yet port 4600
  was still listening and `/api/snapshot` returned seq 470 against the real store -
  `go run` compiles to a temp binary and execs a CHILD, so killing or losing the parent
  leaves the child serving with no task tracking it. Two misleading halves: a red that is
  not a red (the service is up), and a live process the session cannot cleanly stop or
  observe through its own task system. Cost: nil this time - the notification was checked
  rather than believed, which is the only reason it did not read as "the board is down".
  Class: `go run` is a WRAPPER, not the process; any long-running service started through
  it needs its liveness judged by PROBING THE SERVICE, never by the launcher's exit code -
  and orphan cleanup belongs in the session-end sweep (a port check, not a task list).
  Same family as the CI-watch scar one layer down: sampling a launcher is not observing a
  service.

- 2026-07-27 ~09:37 (conductor, self-caught before merge): I APPENDED TO A FILE A CAR HAD
  CHECKED OUT, guaranteeing a merge conflict in the one file every car is REQUIRED to
  touch. Three friction rows landed on dev (e0a6a43, 4f7f05f, and this one) while car #79
  was live and - correctly, per the log-as-it-happens rule - appending its OWN rows to
  `docs/friction-log.md` in its worktree. Both parties did the right thing and the
  collision is structural: an append-only log plus concurrent branches means every
  multi-car day ends in a conflict on the same trailing lines. Cost: nil so far (resolvable
  by keeping both sets - the rows are independent appends, never edits to each other), but
  it is a standing tax and a place where a careless resolution could DROP a car's row,
  which is silent loss of the record (Law 4). Class: the friction log is a
  MULTI-WRITER APPEND SURFACE with no merge strategy declared; the resolution rule is
  always UNION, never pick-a-side, and a conductor merging one must diff both parents'
  additions before resolving. Candidate mechanisms if this recurs: a `.gitattributes`
  union merge driver for this one file, or per-session section files that concatenate -
  neither built today, deliberately (one occurrence is not yet a pattern).

- 2026-07-27 ~10:05 (two independent observers, same class, one morning): BROWSER-TEST PORT
  CONTENTION IS A LOAD-DEPENDENT FLAKE FAMILY, and the fix is already demonstrated one
  directory over. The #75 reviewer saw `browser-health-trend-cascade.test.js` fail 4 tests
  inside a full-suite run under concurrent Chromium+Go-server load, then pass 4/4 alone
  under identical conditions; the #75 car then saw `browser-dispatch-row-taskid.test.js`
  fail with `bind: Only one usage of each socket address ... is normally permitted`,
  passing 5/5 alone and 225/225 on a full-suite re-run. Contrast, measured the same
  morning: #79's probe suite binds port 0 (kernel-assigned) and its reviewer ran THREE
  CONCURRENT instances with zero collisions while a developer's board held 4600. Cost so
  far: two false reds and two re-runs, plus the standing tax of teaching everyone to
  re-run before believing. Class: a test that binds a FIXED port cannot be run concurrently
  with itself or its siblings, and the flake it produces is indistinguishable at a glance
  from a real failure - which is the crying-wolf shape this shop treats as worse than no
  instrument. The remedy is not vigilance, it is port 0 plus reading the bound address
  back, already proven here. Deliberately NOT fixed inside the #75 train (out of its
  scope, pre-existing); the reviewer was asked to rule whether it is a real fragility
  worth its own ticket rather than have the conductor decide it alone.

- 2026-07-27 ~12:20 (design-87 author, SELF-DISCLOSED; RECURRENCE of a logged class):
  PWSH .NET STATIC FILE APIS IGNORE Set-Location - AGAIN, and this time it also made a
  fault injection VACUOUS. The #87 design author used `[System.IO.File]` with a RELATIVE
  path inside its worktree; .NET resolves against `[Environment]::CurrentDirectory`, which
  `Set-Location` does not change, so the write landed in the SHARED CHECKOUT as a 0-byte
  untracked file. Second-order cost, and the worse half: the run that was supposed to
  fault-inject the citation gate therefore injected NOTHING and reported green - a
  decorative guard produced by a path bug. Caught by the author, cleaned, and redone with
  absolute paths plus an explicit `[Environment]::CurrentDirectory` set; shared checkout
  verified clean by the conductor independently (`git status --porcelain` empty, the stray
  path absent). Cost: one wasted injection cycle, no tracked state touched.
  **This exact class is already in this log at 2026-07-26** (round-4 reviewer, same
  mechanism, same shared-checkout target). A logged instance did not immunise the next
  agent, because nothing MECHANICAL stands between a relative .NET path and the shared
  checkout - the rule lives only in prose that a fresh dispatch may never read. Class:
  pwsh maintains TWO current directories, and worktree isolation is enforced by discipline
  rather than by mechanism. Candidate remedy if it recurs a third time: brief-level
  boilerplate is already failing, so the next tier is a guard that refuses writes outside
  the dispatch's own worktree, or simply banning bare `[System.IO.File]` in favour of
  cmdlets that honour `Set-Location`.
  SECOND, SEPARATE LESSON from the same disclosure, worth as much as the first: **the
  citation gate scans `git ls-files` ONLY, so an UNTRACKED file is invisible to it.** The
  author's first green run never saw the new document at all and proved nothing; it only
  became a real check after staging. Any repo-policy gate keyed to `git ls-files` silently
  passes new work until it is staged - which is exactly when an author is most likely to
  believe they have been checked.

- 2026-07-27 ~13:00 (design-87 author, SELF-DISCLOSED, caught by CHECKING not trusting): A
  POWERSHELL BLOCK ABORTED MID-WAY AND LEFT A FAULT INJECTION LIVE ON DISK. The author
  injected a bad citation to prove the gate non-vacuous, then ran Pester; Pester's non-zero
  exit aborted the rest of the block, so the RESTORE never executed and the corrupted file
  sat on disk. It was caught only because the author verified the restore by sha256 instead
  of assuming the block had completed. Cost: nil - caught immediately; but the failure mode
  is a corrupted artifact silently surviving a review. Class: **a multi-statement shell
  block is not a transaction.** Any injection sequence must verify its own restore by hash
  as a SEPARATE step, never trust that the block ran to the end - and note the shape is the
  inverse of the usual worry: the danger is not that the injection fails to apply, it is
  that the RESTORE fails to apply and nothing says so. Same family as the same author's
  round-1 shared-checkout write: both are "I assumed the code I wrote actually ran".
  Standing consequence adopted in briefs from this point: every fault-injection instruction
  now carries "verify the restore by sha256 rather than assuming the block completed".

- 2026-07-27 ~13:03 (conductor, self-caught while setting up round 2): I DISPATCHED A
  REVIEWER INTO THE AUTHOR'S OWN WORKTREE. Design review round 1 was pointed at
  `starcar-wt/design-87`, which is the design AUTHOR's worktree, not a detached review
  copy. This repo has a scar for exactly this (2026-07-22: a reviewer detected live
  mutation by file mtime and correctly quarantined its verdict to a frozen commit). It was
  harmless only because the author happened not to be running at that moment - luck, not
  design. Corrected for round 2 with a separate detached worktree at the rev-2 commit.
  Class: ONE WORKTREE = ONE ACTOR is a rule the conductor keeps honouring for CARS and
  forgetting for DESIGN dispatches, because a design "is only a document" - but a document
  under review is exactly as mutable as code. The pattern to hold: every review of any
  artifact gets its own detached worktree at the frozen SHA, with no exception for prose.

- 2026-07-27 ~13:15 (design-87 REVIEWER, self-corrected after the AUTHOR disputed it;
  reviewer-recommended landing, and it does NOT count against the document):
  `ConvertFrom-Json` SILENTLY COERCES AN ISO-8601 STRING TO A LOCAL `System.DateTime`, AND
  A LANDED VERDICT PUBLISHED THE RESULT AS AN OBSERVED COORDINATE. The round-1 design
  verdict quoted a probe-log span as `07:18:40`-`19:08:35`. The raw bytes read
  `2026-07-24T11:18:40.178633+00:00` and `2026-07-25T23:08:35.962940+00:00`. Same 20
  records - the reviewer had rendered UTC into machine-local Eastern time and stated it as
  the field's value. Measured by the reviewer on re-check: `ConvertFrom-Json` returns
  `System.DateTime`, NOT `String`, and renders local. The AUTHOR caught it and disclosed a
  divergence from its own reviewer's verdict rather than quietly adopting the reviewer's
  numbers - which is the loudly-not-quietly rule paying out in the direction it is hardest
  to apply, upward at a gate. Class: **a tool's implicit type conversion is invisible until
  you read raw bytes**; any timestamp, id, or coordinate quoted into a durable record must
  come from the raw text, never from a parsed object's default rendering. Fourth member of
  today's family (pwsh two current directories; a shell block that is not a transaction;
  gates blind to untracked files) - every one is "a layer did something I did not ask for
  and did not announce".
  **THE RECORD IS NOT EDITED.** The round-1 verdict is landed, integrity-hashed and public
  with the wrong coordinate in it; the correction lives in the round-2 verdict that found
  it. That is the showcase-never-edits-the-record rule working as designed - a reader
  following the series sees the error and its correction, which is worth more than a
  silently-clean artifact.

- 2026-07-27, structural fact FOUND BY THE MINE (not friction, recorded so nobody
  re-digs): the per-dispatch "Entire-Checkpoint" blobs on the checkpoint branch are
  periodic snapshots of the SINGLE conductor session, not separate car/reviewer
  transcripts - a dispatched agent's own tool-by-tool work is mirrored ONLY as the
  final report block embedded in the conductor's transcript. Consequence for every
  future reconstruction and chaos-drill grade: sub-agent-level friction below what an
  agent chooses to narrate is NOT recoverable from the public mirror. The mine's two
  "suspicious injected system-reminder" flags were both explained benign on triage:
  one was the repo's own GitNexus PreToolUse context hook, the other the harness
  re-listing the goodnight skill mid-run because #74's edit landed while the miner was
  running - the miner's refuse-and-report reflex was correct anyway.

- 2026-07-27 ~09:30 (car/probe-79, live, #79): PSEVENTING A DOTNET PROCESS WITH A RAW
  `.add_OutputDataReceived({...})` SCRIPT BLOCK CRASHES THE WHOLE PWSH HOST - a
  `System.Diagnostics.Process`'s async output/error events fire on a threadpool thread
  with no PowerShell runspace attached; a bare `{...}` handler throws "There is no
  Runspace available to run scripts in this thread" and takes the entire pwsh process
  down with it (observed: `Invoke-Pester` itself died mid-suite, not just the one test).
  `Register-ObjectEvent -InputObject $proc -EventName OutputDataReceived -Action {...}`
  is the correct mechanism - its `-Action` runs on the engine's event queue, which has a
  real runspace. Cost: one ~5-minute hung/crashed background run plus manual process
  cleanup (stray `board-server-probe.exe`/`go.exe` left running) before the cause was
  isolated. Class: any PowerShell code that spawns a real subprocess and wants to react
  to its async output/error streams must use `Register-ObjectEvent`, never a raw .NET
  event-delegate script block - this generalizes past this one probe to any future
  suite that drives a long-lived process from pwsh (`scripts/probes/
  ManifestBoardJoin.Probes.Tests.ps1`'s `Start-BoardServerAgainst` is now the landed
  exemplar).

- 2026-07-27 ~09:45 (car/probe-79, live, #79): A JUST-KILLED WINDOWS PROCESS CAN STILL
  DELETE-LOCK ITS OWN .EXE FOR A SHORT WINDOW AFTER `Process.WaitForExit()` RETURNS - a
  single `Remove-Item -Recurse -Force -ErrorAction SilentlyContinue` on the scratch
  directory containing `board-server-probe.exe` silently left the whole directory
  behind (no error surfaced, because `SilentlyContinue` swallowed it) even though the
  process handle had already exited; a manual `Remove-Item` moments later succeeded
  with no special handling. Cost: one leftover ~debris directory under
  `%TEMP%\mbj-probe-*` caught only by an explicit post-run `Get-ChildItem` audit
  (would have silently violated #43's standing no-debris ticket otherwise). Class:
  cleanup code that deletes a directory containing a just-terminated process's own
  binary needs a short bounded retry (this probe uses 10 attempts x 300ms), never a
  single silently-swallowed attempt - `SilentlyContinue` on a cleanup step turns a
  transient OS lock into permanent, invisible debris.
