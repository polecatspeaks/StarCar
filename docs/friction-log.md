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
