<!-- starcar-integrity: sha256=62a49d6b23fa9ef13edeb6a3cb821ab6fc46063150735f8d8aa6c04ba6ae88f6 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# PR 51 fix car review - round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: adversarial sentence-check (car unit)
Round: 1
Target: `branch car/51-pr-fixes (5 commits above 797818d)`
Base reviewed: `797818da38367e91e5b037f498ab60834f5e2d2e`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE-FOR-MERGE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `51-fix-review-r1`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `797818da38367e91e5b037f498ab60834f5e2d2e` |
| Entire checkpoint | `7ee1bf3b5b23` |
| Dispatch, the locator within the session | `51-fix-review-r1` |
| Entire session (context, NOT a lookup key) | `rev51-r1-transcript` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 797818da38367e91e5b037f498ab60834f5e2d2e
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Agent is idle (waiting for messages). agent_id: 51-fix-review-r1, agent_type: car, status: idle, description: Review: car 51 fixes round 1, elapsed: 679s, total_turns: 1, model: claude-opus-4.8

[Turn 0]
All verification complete. Every fix's guard was watched firing via fault injection (all reverted byte-identical), all suites pass, and the concurrency ruling holds: in production `PollOnce` is called only from `RunPollLoop` (poll.go:163) under the skip-not-queue guard, and `buildSnapshot`'s only callers are `NewServer` (pre-share) and `PollOnce`, so the two lock-free maps have no concurrent accessor.

## Review: Car 51-fix-car-r1 / branch car/51-pr-fixes

**Base & commits (observer: reviewer 51-fix-review-r1; worktree <repo>-car51):** base 797818d confirmed; exactly 5 commits sit above it — 3b6dd01 (C1), 5fb8e49 (C2), 14ccfc3 (C3), 2fc7b18 (C4), d8001e0 (C5); working tree clean, no untracked/`.bak`/scratch files; diff touches only 11 expected files (no fixture in `schema/vectors` edited).

**Suites I ran myself:**
- `go build ./...` (board): clean. `go vet ./...`: clean.
- `go test ./... -count=1` (board): **5/5 packages pass** (board, assemble, fold, server, store).
- Targeted: TestHandleStreamRegistersBeforeInitialSend, TestRunShutsDownOnContextCancel, TestPollOnceScanFailureIsFailedWithLastGood, TestPollOnceFirstEverPollFailsKeepsDataNil, TestBroadcastReplacesStaleQueuedFrameWithNewest — **all PASS**.
- `Invoke-Pester scripts/tests`: **276/276**. `Invoke-Pester scripts/probes`: **22/22**.
- `board/web`: `npm ci` then `node --test`: **59/59** (bare `node --test`, matching disclosed finding #1).

**Fault-injection (guard watched firing; each reverted byte-identical, SHA re-verified):**
- C3: moved `register()` after the initial send → test FAILED `handleStream ordering = [initial-send-done register-done]...` (handlers.go SHA F819DCC1 restored).
- C4: removed the `ctx.Done()→Shutdown` watcher → test FAILED `run() did not return within 2s of context cancellation...zombie` (main.go SHA 4F9DC005 restored).
- C5: reverted drain-replace to old drop → test FAILED `channel held the STALE first frame (seq=1)...one-behind forever` (sse.go SHA 30A2697D restored).

**Sentence checks (each hop file:line):**
- **C1:** Produce-Artifact.ps1:355-357 emits subject_basis/task_id/provenance → schema/starcar-artifact.schema.json:76-84 already declares all three (store.go:276 `Validate` passes) → typedRecord now carries them (store.go:127-129) → typedKeys reflection → unknown-fields check store.go:305 no longer trips. No vector fixture carries these (optional), no web consumer needs them. Mirror intact.
- **C2:** buildSnapshot failed branch (poll.go:285-292) assigns retained `lastGoodLaneData` to `lane.Data` → web `hasRenderer` (lanes.js:52 `Boolean(lane.data) && Array.isArray(lane.data[key])`) now true → dom-writer renders content instead of "no renderer for this payload" (dom-writer.js:102) while `freshnessLine` shows `source failed (...) - showing last good from {lastGoodAsOf}` (compose.js:97-102). Design citations accurate (line 329 "lastGood visibly marked; NEVER an empty yard"; line 68). Ledger arithmetic 0→10 consistent (vocab/budget pair = 1).
- **C3:** register-before-send confirmed in handlers.go; duplicate-frame-harmless claim verified myself — ingest.js:59 `if (typeof payload.seq === 'number' && payload.seq <= state.lastAppliedSeq) return state;` is a genuine no-op on non-increasing seq.
- **C4:** signal.NotifyContext (main.go:103) → `run(ctx,...)` → goroutine `<-ctx.Done()` → `httpServer.Shutdown` (5s grace); `Serve` returns `ErrServerClosed` treated as clean. Nothing else blocks exit. Red was against an uncommitted scratch `run()`; the seam did not exist pre-commit, so the red is non-vacuous (independently re-proven above).
- **C5:** broadcast holds `r.mu` for its entire loop (sse.go:48-49); unregister does `Lock; delete; Unlock; close(ch)` (sse.go:30-34) — a channel is closed only after leaving `r.subs`, which requires the lock broadcast holds, so no send/drain can hit a closed channel. No close-vs-send window. `-race` unavailable (cgo) as disclosed; argued from source, which I traced.

**Ruling on disclosed finding #4 (the requested ruling):** C2 DID enlarge the pre-existing lock-free hazard (added `lastGoodLaneData` mutated at poll.go:277-283,292 outside `s.mu`, alongside pre-existing `lastGoodAsOf` at poll.go:265). **This is NOT a Major.** Grep confirms both maps are read/written ONLY inside `buildSnapshot`; `buildSnapshot`'s only callers are `NewServer` (pre-share) and `PollOnce`; production `PollOnce` runs only from `RunPollLoop` (poll.go:163) under the skip-not-queue CAS guard (poll.go:139) — one poll goroutine at a time. `CurrentSnapshot`/`LastPollAt` read only `lastSnapshot`/`lastPollAt` under `s.mu`, never these maps. No concurrent access exists; the single-poll invariant (not `s.mu`) is what makes both maps safe, and C2's addition is symmetric with the existing pattern without changing that invariant. Acceptable to carry as a tracked issue; honestly disclosed.

**Standing rules:** #51 cited on every new unit (store.go:100-106, poll.go:43/57-63, handlers.go:50-56, main.go:20-40, sse.go:55-71, plus each test) ✓; red-first non-vacuity proven for C3/C4/C5 by fault injection, C1/C2 by diff+green ✓; state-ledger.md updated in the SAME commit as C2 ✓; no committed fixture edited ✓; commits clean, nothing pushed ✓.

### Findings (all Minor — no Major)
- **C51R-1 (Minor):** C3 left a stray third `s.testStreamOrderHook("register-done")` at handlers.go:71 with no `register()` behind it — dead leftover from the block swap that emits a bogus checkpoint. Zero production impact (hook nil in prod) and zero test-correctness impact (test asserts `order[0]`, the stray is `order[2]`; regression still caught, proven by fault injection). Contradicts the commit body's "swapped the two blocks" clean-swap description. (suite: go test board/server, 5/5 pkgs pass; SHA 14ccfc3; observer: me)
- **C51R-2 (Minor):** C4 added a trailing blank line at main.go EOF → `gofmt -l` flags board/server/main.go even on the LF-clean committed blob. NOT CI-gated (ci.yml runs `go vet`+`go test`, no gofmt gate; `go vet` clean) so non-blocking, but a committed formatting defect. (suite: gofmt -l on `HEAD:board/server/main.go`; SHA 2fc7b18; observer: me)
- **C51R-3 (Minor):** C5 comment at sse.go:57 cites "(unregister.go: r.mu.Lock(); ...)" — no unregister.go file exists; `unregister()` lives in sse.go:30. Incorrect file citation in an in-code comment. (suite: Test-Path board/server/unregister.go = False; SHA d8001e0; observer: me)
- **C51R-4 (Minor):** C2 cites `docs/contracts/state-ledger.md:102` in poll.go:43, the poll_test.go failure messages, and the commit body — line 102 is the `seq` row. The "previous good lane DATA stays current" contract is line 103 (lastGoodSnapshot) and the lastGoodLaneData row is line 108. Imprecise/off-by-one dead citation; the claim exists nearby but not at the cited line. (suite: Select-String state-ledger.md; SHA 5fb8e49; observer: me)
- **C51R-5 (Minor, the ruled disclosure):** C2's enlargement of the lock-free map hazard — safe under the single-poll invariant as ruled above; carry as a tracked issue with a future task to either move these mutations under `s.mu` or add an in-code comment pinning the skip-not-queue invariant. (suite: grep lastGood* callers; SHA 5fb8e49; observer: me)

### Verdict: **APPROVE-FOR-MERGE**
No Major findings. All five fixes are functionally correct, doc-synced in-commit, and their red-first evidence is non-vacuous (three guards watched firing with their exact stated messages). The five Minor findings (C51R-1..5) are explicitly carried as tracked issues and do not block this merge; recommend a follow-up hygiene pass (remove the stray C3 hook, gofmt main.go, fix the unregister.go and state-ledger:102 citations, and pin the poll-serialization invariant).

```starcar-artifact
outcome: done-with-findings
findings: APPROVE-FOR-MERGE. No Major. 5 Minor tracked issues. C51R-1 C3 stray leftover testStreamOrderHook register-done at handlers.go:71 (dead code from block swap; zero prod/test-correctness impact; contradicts commit's clean-swap wording). C51R-2 C4 main.go trailing blank line flagged by gofmt on the LF-clean blob; not CI-gated (go vet clean, no gofmt gate). C51R-3 C5 comment cites nonexistent unregister.go (code is in sse.go). C51R-4 C2 cites state-ledger.md:102 (the seq row); the lastGood contract is line 103 and the new row is line 108 - imprecise citation in poll.go:43, test messages, commit body. C51R-5 RULING on disclosed hazard: C2 enlarged the lock-free map mutation (lastGoodLaneData outside s.mu) but this is NOT a Major - buildSnapshot runs only on the PollOnce path serialized by the skip-not-queue guard, and both maps are accessed only inside buildSnapshot with no concurrent reader; safe by the single-poll invariant, carriable as a tracked issue. Verified myself: go build clean, go vet clean, go test 5 of 5 packages pass, Pester tests 276 of 276, Pester probes 22 of 22, web node --test 59 of 59. Fault-injected C3 C4 C5 - each guard failed with its exact stated message, all reverted byte-identical with SHA re-verified. Sentence checks traced for all five fixes including ingest.js:59 duplicate-frame no-op and the C2 web hasRenderer path.
abstract: Adversarial sentence-check review of the PR-51 five-commit fix train on branch car/51-pr-fixes at base 797818d. Ran every suite independently and fault-injected the three concurrency/ordering guards to watch them fire, reverting byte-identical. All fixes correct, docs synced in-commit, reds non-vacuous. Five Minor findings carried as tracked issues; no Major. Verdict APPROVE-FOR-MERGE.
task-id: 51-fix-review-r1
```