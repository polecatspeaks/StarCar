<!-- starcar-integrity: sha256=8779880363c994b369c6068c411f20d4c2da3404653d1939519fd6d524bd22f6 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Yard board Car 4 delta round 2: APPROVE - all guards committed and fault-injection proven; production code comment-only; merge clear

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (adversarial delta, Opus, same reviewer fix-cycle)
Round: 2
Target: `car/board-car4 at 5dd1fc8 (5 commits)`
Base reviewed: `5dd1fc8`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a581cde8b292e2378`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `5dd1fc8` |

| Dispatch, the locator within the session | `a581cde8b292e2378` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 5dd1fc8
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All three findings clear against the fix, no new defects introduced, full ladder green.

---

# DELTA RE-REVIEW (round 2) — VERDICT: APPROVE. Merge is clear.

Base verified: HEAD `5dd1fc8`, parent `5dd1fc8^` = `099ac49` (exactly one commit on top of the round-1 base). Full ladder at HEAD: `go test -count=1 ./...` all five packages green, **server 26** (24 + 2 new), `go vet` clean, `gofmt -l` empty, `Invoke-Pester scripts/tests` **235/235** (0 failed). Tree clean after both my fault-injections (restored byte-identical).

## The three findings, walked against the fix

**C4R-1 (Major) — CLEARED.** `TestShopDefaultBudgetThreadsThroughToTheWire` (`board/server/shopdefault_test.go:27`) does exactly what my Major demanded: sets `cfg.DefaultsPath` to a temp fixture (the only server test that does), writes a budget-less dispatched record dated `2026-07-20` with no successor, polls at `2026-07-23T12:00:00Z`, and asserts on the **wire** — it type-asserts `dispatchesLane.Data.(assemble.DispatchesPayload)` (not the fold package) and checks `state=overdue`, `budget_source=default`, `budget_seconds=1800`. **Non-vacuity proven by me:** I neutralized the threading (`poll.go:230-232`, the `WithDefaultBudgetSeconds` append) → test went **RED** with the exact stated reason `wire dispatch state = dispatched, want overdue - the shop default was not applied at the server boundary`; restored byte-identical (`git diff --stat` empty), green again. The regression guard on the C3R-1 class now exists in the committed suite and I watched it fire.

**C4R-2 (Minor) — CLEARED.** The three previously-dead `sse_test.go` citations now name real tests in real files: `handlers.go:19` → `TestSnapshotAndStreamShareOneMarshalPath (handlers_test.go)`; `snapshot.go:11` → `TestSSEEventNameMatchesSchemaConstant (sse_const_test.go)`; `snapshot.go:78` → `TestSnapshotAndStreamShareOneMarshalPath, handlers_test.go`. My own sweep confirms **no remaining `sse_test.go`** anywhere in `*.go`, and every `_test.go` filename cited in any comment (board_test, demomode_test, handlers_test, laneregistry_test, loaders_test, sse_const_test, testroot_test, vectors_test) resolves to a real file. The car's no-other-dead-citation claim holds.

**C4R-3 (Minor) — CLEARED.** `TestChangeDetectionFiresOnAgeBucketBoundaryCrossing` (`poll_test.go`) uses a **returned-record fixture** — the correct isolation choice, since a returned entry carries no `elapsed_seconds` (verified: fold's `DispatchEntry.MarshalJSON` omits it for returned), removing the confound the car discovered. It asserts poll 1 (age 16s) → `ageBucketMs=15000`, poll 2 (age 21s) → `ageBucketMs=20000` **bumps seq** (crossing), and a **same-bucket control** poll 3 (age 22s, still bucket 20000) → **not** a change. **Non-vacuity proven by me:** I stripped `ageBucketMs` in `mustMarshalStripped` → **RED** for the correct root cause (with the bucket stripped, poll 2 compared identical to poll 1, the server judged it unchanged and kept serving poll 1's snapshot, so snap2's ageBucketMs read 15000 not 20000 — the exact "server keeps serving the stale snapshot" consequence); restored byte-identical, green.

## The new disclosure (issue #27) — ruling: deferral-with-issue is the correct disposition, it clears

The `elapsed_seconds`-unquantised finding landed in both claimed places: `poll.go`'s `mustMarshalStripped` doc comment (+14 lines) and `docs/contracts/gating-matrix.md`'s Staleness area (+13 lines), each describing precisely how a dispatched-winner's `elapsed_seconds` recomputes every poll, is not stripped and not quantised (unlike `ageBucketMs`), so an active dispatch churns seq every poll — disclosed, not silently fixed, scoped out as a separate wire-contract design question. Issue **#27** exists (OPEN) with a precise body, an explicit conductor triage (real/deferred, natural fix mirrors ageBucketMs), and **two stated triggers** (first live session where SSE churn is observed annoying; or Car 5's client work if churn complicates seq handling). Against my round-1 carrier standard, this is textbook: **specific** (field, mechanism, consequence), **tracked** (#27), **triggered** (two concrete triggers), **durably landed** (two files). Not a defect to fix now — it is a genuinely separate design decision, honestly parked. It clears.

Non-blocking note for the conductor (polish, not a finding, not the car's to fix — the car committed before the triage): the poll.go/gating-matrix text says "awaiting the conductor's triage," now technically completed by #27; a future truing pass could cite #27 for full traceability.

## Fresh-eyes on the one-commit diff

The three production `.go` files (handlers.go, snapshot.go, poll.go) have **zero non-comment additions** — all changes are comment-only (C4R-2 citations + the #27 disclosure). The only functional additions are two test files and the gating-matrix doc paragraph. `marshalSnapshot` and `mustMarshalStripped` logic are byte-unchanged; nothing structural moved. This is the ideal minimal fix cycle — no logic churn, so nothing downstream could break, and the full suite confirms it.

## Convergence (round 2)

Round 1: 1 Major + 2 Minor. Round 2: all three cleared with committed, fault-injection-proven guards; **zero new findings**; the fix cycle introduced **no new defects** (production code comment-only). Major count 1 → 0; findings shrank and closed, none relocated. This is convergence, not swirl — no escalation, no rotation trigger (round 2, within cap). Merge is clear.

```starcar-artifact
outcome: APPROVE
findings: All three round-1 findings cleared at HEAD 5dd1fc8 (parent 099ac49, one commit). C4R-1 (Major) cleared - TestShopDefaultBudgetThreadsThroughToTheWire (shopdefault_test.go) sets Config.DefaultsPath, feeds a budget-less old dispatched record, and asserts the WIRE assemble.DispatchesPayload carries state=overdue/budget_source=default/budget_seconds=1800; reviewer fault-injected the WithDefaultBudgetSeconds threading removal at poll.go 230-232, observed RED for the exact stated reason (wire dispatch state = dispatched, want overdue), restored byte-identical, re-observed green. C4R-2 (Minor) cleared - the three dead sse_test.go citations (handlers.go:19, snapshot.go:11, snapshot.go:78) now name real tests TestSnapshotAndStreamShareOneMarshalPath (handlers_test.go) and TestSSEEventNameMatchesSchemaConstant (sse_const_test.go); reviewer swept and found no remaining sse_test.go and every cited _test.go filename resolves. C4R-3 (Minor) cleared - TestChangeDetectionFiresOnAgeBucketBoundaryCrossing uses a returned-record fixture that isolates ageBucketMs from the elapsed_seconds confound, asserts a 15000-to-20000 bucket crossing bumps seq and a same-bucket 22s control does not; reviewer fault-injected ageBucketMs out of mustMarshalStripped, observed RED for the correct root cause (server judged poll 2 unchanged and served poll 1's stale snapshot), restored, green. New disclosure ruling: the elapsed_seconds-unquantised finding landed in poll.go's mustMarshalStripped doc comment and gating-matrix.md's Staleness section; issue #27 is OPEN with a precise body, conductor triage, and two stated triggers - deferral-with-issue clears the round-1 carrier standard (specific, tracked, triggered, durably landed). Fresh-eyes: the three production go files changed comment-only (zero non-comment additions), all functional additions are tests plus the disclosure doc, no logic churn, nothing broken. Full ladder green: go test all packages ok with server at 26, go vet clean, gofmt -l empty, Invoke-Pester scripts/tests 235/235 with 0 failed. Convergence: Major 1 to 0, no new findings, no defects introduced by the fix cycle; not swirl, no rotation trigger. One non-blocking polish note for the conductor - the disclosure text says awaiting triage which #27 now completes; a future truing pass could cite #27.
abstract: Round-2 delta re-review of Car 4's fix cycle (commit 5dd1fc8, one commit on 099ac49). All three round-1 findings - the C4R-1 Major (untested shop-default-budget threading at the server boundary, the C3R-1 regression class) and the two Minors (dead sse_test.go citations, unpinned ageBucketMs change-detection inclusion) - are resolved with committed, reviewer-fault-injection-proven guards. The reviewer independently ran the full ladder (go test with server now 26, vet, gofmt, Pester scripts/tests 235/235), fault-injected both new tests to confirm non-vacuity and byte-identical restoration, and verified the production go changes are comment-only. The car's self-found elapsed_seconds churn finding is honestly disclosed in two durable locations and tracked as open issue #27 with a stated trigger; the reviewer ruled deferral-with-issue the correct disposition. Verdict APPROVE, merge is clear, convergence clean (Major 1 to 0, no new findings, no defects introduced). Nothing committed, edited, or pushed; both local fault-injections restored byte-identical and the worktree is clean.
```