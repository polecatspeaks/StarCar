<!-- starcar-integrity: sha256=874789f52179f70fd1bfef2dfb9c5c58fef1f6a2d678a274c9e7ed4d2b169d0f covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Issue #52 hygiene Minors C51R-1..5 - adversarial review round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-review

Target: `car/52-hygiene 5207778`
Base reviewed: `d09dd2d`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `52-hygiene-review-r1`. The conductor did not retype a word of what follows. Verbatim by
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
> Path normalisation: the repository root was rewritten to ``<repo>`` and the operator home directory to ``~``, BEFORE hashing. Mechanical and narrow: only those two roots, longest-first, no other substitution. This is portability, not curation - findings, verdicts and counts are untouched, and the un-normalised original is on the Entire checkpoint branch.

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `d09dd2d` |
| Entire checkpoint | `e625da768a9e` |
| Dispatch, the locator within the session | `52-hygiene-review-r1` |
| Entire session (context, NOT a lookup key) | `rev52-r1-transcript` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain d09dd2d
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Agent is idle (waiting for messages). agent_id: 52-hygiene-review-r1, agent_type: car, status: idle, description: Review: car 52 hygiene, elapsed: 411s, total_turns: 1, model: claude-opus-4.8

[Turn 0]
# Adversarial Review — task 52-hygiene-review-r1 (car 52-hygiene-car-r1, issue #52, PR-51 Minors C51R-1..5)

## VERDICT: REJECT — 1 Major

Base verified: worktree `<repo>-car52`, branch `car/52-hygiene`, three commits on base `d09dd2d` (`3d2c8b1`, `8f557d6`, `5207778`). History matches the brief. Worktree clean before and after all fault injections (`git status --porcelain` empty).

---

## Findings

### MAJOR-1 — New unit's doc comment carries two wrong file:line citations at commit time (`poll_test.go:383` and `:385`)

`board/server/poll_test.go`, the doc comment on the **new** `TestSkipNotQueueGuardConcurrentClaimIsExclusive` (added by `5207778`), cites:

- **`RunPollLoop (poll.go:158-162)`** — WRONG. `RunPollLoop` is defined at **poll.go:168**. Lines 158–162 are `TryBeginPoll`'s CAS body (158) and `EndPoll` (162).
- **`TryBeginPoll's CAS (poll.go:139-140)`** — WRONG. The CAS (`atomic.CompareAndSwapInt32`) is at **poll.go:158**. Lines 139–140 are `CurrentSnapshot()`'s `s.mu.Lock()` — i.e. the citation for "the lock-free CAS" lands a reader on the *exact `s.mu` mutex the comment says these maps do NOT use*.

Verified by direct line lookup at `5207778`:
```
157 func (s *Server) TryBeginPoll() bool {
158     return atomic.CompareAndSwapInt32(&s.pollInFlight, 0, 1)
162 func (s *Server) EndPoll() {
168 func (s *Server) RunPollLoop(ctx context.Context) {
139 func (s *Server) CurrentSnapshot() Snapshot {
140     s.mu.Lock()
```

These are wrong **at the moment of commit**, not drifted. They also **contradict the sibling struct comment in `poll.go` added by the SAME commit**, which correctly cites `RunPollLoop (poll.go:168-182)` and the CAS at `(poll.go:157-158)`. The car's report claims it "verified post-edit" its citations; that claim is true for the struct comment and **false for this test comment**. This round's entire mandate is citation hygiene (it fixed `unregister.go`→`sse.go:31-35` and `state-ledger.md:102`→`:108`); shipping two new misleading citations — one pointing to the opposite construct (a mutex where a lock-free CAS is claimed) — in the same commit is a material defect. Comments rank equal to code. **Major → REJECT.** (Disclosed-but-wrong does not clear: the report's post-edit-verification claim is the disclosure, and it is wrong.)

Related sturdiness note (would carry as a Minor were the numbers correct): the struct comment carries an explicit "line numbers will drift — re-verify" disclaimer and uses an anchor ("declared just above pollInFlight"); the test comment uses bare numerics with no disclaimer. Anchor-style (function names) would have been sturdier.

---

## Everything else — re-derived and CLEAN

**Suites (all run by me at `5207778`):**

| Suite | Result | Command / location |
|---|---|---|
| Go | **5/5 packages ok** | `go test ./...` from `board\` |
| gofmt | **clean** (empty output, exit 0) | `gofmt -l .` from `board\` |
| Pester scripts\tests | **278 passed, 0 failed** | `Invoke-Pester scripts\tests -CI` |
| Pester scripts\probes | **22 passed, 0 failed** | `Invoke-Pester scripts\probes -CI` |

278 confirmed as the true base number (brief's 276 was pre-existing drift).

**C51R-1 (item 4) — CORRECT.** `git show d09dd2d:board/server/handlers.go` shows the real `register-done` fire immediately after `s.subs.register()` (line ~59), plus a **duplicate** `register-done` fire *after* `initial-send-done` (temporally nonsensical). The diff removes only the duplicate; the real fire survives. Fault-injection: a genuine register-after-send swap (moving the send block **and its `initial-send-done` hook** above the register block) makes `TestHandleStreamRegistersBeforeInitialSend` FAIL — observed verbatim: `handleStream ordering = [initial-send-done register-done], want ["register-done", "initial-send-done"]`. Restored via `git checkout`, worktree clean. (Note: a naive swap that leaves the `initial-send-done` hook at the bottom does NOT trip the test — the test pins the *order of hook fires*, which holds only while each hook stays co-located with its operation. The removed duplicate was harmless precisely because `order[0]` stayed `register-done`. This is a correct, meaningful pin.)

**C51R-5 (item 5) — RED non-vacuity CONFIRMED.** Fault-injected `TryBeginPoll` to `return true` (no CAS); `TestSkipNotQueueGuardConcurrentClaimIsExclusive` FAILED verbatim: `TryBeginPoll winners under 50-way concurrent claim = 50, want exactly 1`. Restored via `git checkout` (`git diff --quiet` exit 0 — byte-identical), re-ran: `ok`. Struct-comment citations (`PollOnce 197-203`, `RunPollLoop 168-182`, `CAS 157-158`, "buildSnapshot at 200 / s.mu.Lock at 203") all verified **accurate**.

**C51R-4 (item 6) — HONEST STOP WAS CORRECT.** Re-ran the sweep myself (`Select-String` over all `docs\**\*.md` for `poll\.go:\d | poll\.go#L | poll\.go line`): **zero matches**. The conductor's brief premise — that `state-ledger.md:102` carries off-by-one citations *into* poll.go — does not match the file. The car's refusal to action a false premise, and its disclosure of the *reverse* defect, is the correct outcome. This feeds back to the issue #52 record: **the brief was wrong, the honest stop was right.** Incidental fix verified: `state-ledger.md:102` is the **`seq`** row; **`:108`** is the **`lastGoodLaneData`** row — so poll.go's corrected `:108` citation is accurate.

**C51R-3 (item 7) — CORRECT.** `sse.go:31-35` is exactly `subscriberRegistry.unregister`: `r.mu.Lock(); delete(r.subs, ch); r.mu.Unlock(); close(ch)` — byte-for-byte what the corrected broadcast comment describes.

**Code standard (item 9):** All three commits carry `Co-authored-by: Copilot ...` trailer, cite `#52`, and cite their C51R ids. New test cites `#52 C51R-5`.

**Sentence-check trace (item 8):** struct comment (poll.go) → cites poll.go:197-203/168-182/157-158 → each opened, each matches (PollOnce@197, buildSnapshot@200, s.mu.Lock@203; RunPollLoop@168; TryBeginPoll@157/CAS@158) → **holds**. Test comment (poll_test.go) → cites poll.go:158-162 (RunPollLoop) / 139-140 (CAS) → opened → RunPollLoop is @168, CAS is @158, 139-140 is CurrentSnapshot's mutex → **BREAKS at hop 2** → MAJOR-1.

**Fault-injection restoration proof:** both injections reverted with `git checkout`; final `git status --porcelain` empty; `git diff d09dd2d..5207778 --stat` unchanged (`5 files changed, 65 insertions(+), 7 deletions(-)`).

## Constitution check (diff-implicated)
- **Red-first TDD** — honored: both new pins fail for the stated reason when the guarded behavior is broken (observed above).
- **Documentation ranks equal to code** — **VIOLATED** (MAJOR-1): the new test's doc comment ships two wrong file:line citations, contradicting its sibling comment in the same commit.
- **Citation truth** — honored for C51R-3, the incidental `:102`→`:108` fix, and the struct comment; violated for the test comment (MAJOR-1).
- **Honest-stop over improvisation** — honored: C51R-4 correctly stopped on a false premise with evidence rather than manufacturing a fix.

The single Major is narrow and mechanical: correct the two numerics in the `poll_test.go` comment to `RunPollLoop (poll.go:168)` / `TryBeginPoll's CAS (poll.go:158)` (or switch to function-name anchors), re-verify post-edit, and this clears.

```starcar-artifact
task-id: 52-hygiene-review-r1
outcome: reject
findings: 1
abstract: One Major - the new poll_test.go comment ships two wrong file:line citations (RunPollLoop cited poll.go:158-162 vs actual 168; CAS cited poll.go:139-140 which is CurrentSnapshot's mutex vs actual 158), contradicting the correct sibling struct comment in the same commit; all suites green (go 5/5, gofmt clean, Pester 278/278 + 22/22), C51R-1/3/5 correct, C51R-4 honest stop confirmed CORRECT (zero poll.go line citations in docs), both fault injections fired and restored byte-identical.
```