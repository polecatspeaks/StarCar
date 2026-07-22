# Friction log

Status: Current, append-only within a session

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
| GitHub Actions CI | "Verified" was unachievable by our own definition; Pester tests nobody ran; `Verify-Verdict` running only on memory | Green run 29905304676 (19 tests, 3 verdicts); **RED run 29905432689** for the stated reason; green again after revert |

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
