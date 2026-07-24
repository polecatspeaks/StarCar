<!-- starcar-integrity: sha256=80403cafff29ffcc22ab495baf6580a8ea6c9c93e35012ad662945faa70f74a5 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Yard board Car 5 review round 1: APPROVE - the view clears first pass; clean-clone quickstart replayed; one word traced verbatim disk to DOM

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Car review (adversarial, Opus, fresh detached worktree, clean-clone replay)
Round: 1
Target: `car/board-car5 at 4e5fb8a (5 commits)`
Base reviewed: `4e5fb8a9ad9fe283406989629965b9a082e73833`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a9da976d441bd2a50`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `4e5fb8a9ad9fe283406989629965b9a082e73833` |

| Dispatch, the locator within the session | `a9da976d441bd2a50` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 4e5fb8a9ad9fe283406989629965b9a082e73833
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Worktree byte-identical clean, HEAD at 4e5fb8a, compose.js restored to original hash. Fault injection left no trace. Here is my verdict.

---

# VERDICT: APPROVE

Car 5 (THE VIEW CAR) is sound. All eight claim-classes verified by independent re-run, one clean-clone quickstart replay, one fault injection with byte-identical restore, and an end-to-end sentence-check trace. One MINOR (non-blocking) finding. No Majors.

## Suites (all observed by me, at 4e5fb8a)
- `node --test board/web`: **50/50 pass** (`# tests 50`, fail 0)
- `go test -count=1 ./...`: **59/59 pass** across 5 packages (board, assemble, fold, server, store); **go vet clean**; **gofmt -l empty**
- `Invoke-Pester scripts/tests`: **242/242 pass**, 0 failed
- `scripts/probes`: **12/12 pass** — the one apparent failure (`post-task-probe.sh` probe) is purely `sh`-not-on-the-pwsh-PATH; with Git's `/usr/bin` on PATH it passes, and no probe file is in Car 5's diff. Environmental, not a code defect.

## The eight claim-classes

**2. YB-6 matrix (compose.test.js) — independent, non-vacuous, fault-proven.** The oracle `expectedOf` (compose.test.js:98-105) uses a locally-defined `SEVERITY` table; `FRESHNESS_CASES` restates the freshness→register mapping independently (never imported from the SUT). Load-bearing cases (live+failed, live+fresh+no-renderer) are first (lines 28, 38). `caseCount === 30` asserted. Fault injection: I replaced `composeRegister` with `return positionRegister(...)` — both load-bearing tests and the matrix went **red naming the exact case** (`position=live freshness=not-applicable hasRenderer=false: expected needs-attention, got nominal`). Restored to hash `d755200b`.

**3. Binding contracts on the rendered surface — all honored.**
- Exactly **three severity colors** (board.css:23-25): `--nominal #d9d5c9`, `--in-progress #ffb454`, `--needs-attention #ff4a3a`. Everything else is bg/border/text-dim. No fourth alarm shade. No-renderer maps to `--needs-attention` (board.css:219-221).
- State/outcome words **verbatim** — `render.js:90 state: c.state`, `:105 outcome: g.outcome`, `:113 d.state`; `describeVocab` used ONLY for the register/color, never the displayed text. Confirmed at the DOM (below).
- **STALE → needs-attention** (compose.js:41, `FRESHNESS_REGISTER.stale`). The owner's stale-renders-needs-attention ruling honored.
- Honesty chrome all present (dom-writer.js renderChrome): DEMO banner conditional (`:53`), as-of with `(no successful scan yet)` fallback (`:57`), connection state (`:59-62`), lane count `N of M lanes` (`:64`), board-conditions strip (`:67-73`), discovery-by-name-hot (vocab.js:36).
- Bagged vs dark **distinct** (render.js:131-139: freight `no equipment on this lane` vs fuel `data held, not surfaced`).
- No freshness line for not-applicable (compose.js:79-81 returns null; dom-writer.js:82 skips falsy secondary).
- **No client clock in age**: grep for `Date.now|new Date|performance.now|Date(` across `board/web/js` → **zero matches**. Age derives only from wire `ageBucketMs` (compose.js:94). The watchdog uses `setTimeout` (legitimate).

**4. EventSource deviation — premise verified, resolution faithful, amendment correctly flagged.** I confirmed sse.go:75-77 writes `": heartbeat\n\n"` (a bare SSE comment). Native `EventSource` fires no listener for comment lines (SSE spec), so the gating-matrix "resets on any frame, data OR heartbeat" rule is unimplementable on that API. The car's `fetch`+`ReadableStream` reader (sse-protocol.js) is **the faithful resolution**: it honors D19's rationale (vanilla, browser-native, no bundler/build step) while deviating only from the literal `EventSource` API name, and it is self-contained in Car 5's scope — the alternative (server sends heartbeats as real events) would touch Car 4's already-reviewed sse.go and change an intentional design (comment heartbeats never perturb client state). The D19 amendment candidacy is disclosed in code (sse-protocol.js:6-25), test (sse-protocol.test.js:6-13), and the gating-matrix Disconnect row, flagged as the conductor's call. Correct disposition. The watchdog test uses genuine `t.mock.timers`: fires at exactly 2×heartbeatMs (10000ms), not before (9999ms → 0), resets on any frame incl. heartbeat-only, `stop()` cancels.

**5. Wire validation + seq.** Discard-keeps-last-render pinned (ingest.test.js:30-37, previous snapshot unchanged + markedStale + needs-attention board condition). Validator invoked with `'2020-12'` explicitly (validate.js:12,19; the vendored lib defaults to 2019-09). Seq applies only if strictly greater: `payload.seq &lt;= state.lastAppliedSeq → return state` (ingest.js:59); **equal-seq no-op explicitly tested** (ingest.test.js:81-89) — robust under the #27 churn.

**6. Clean-clone quickstart (the NORTH STAR gate) — every claim survived my replay.** From a fresh `git clone` of this exact commit into a temp dir, I ran the README's exact commands (`cd board; go run ./server`), server listened on `127.0.0.1:4600`. Traced each README claim prose→command→observation:
- `GET /` → **200 text/html** ✓
- `GET /api/snapshot` → **200 application/json** ✓
- `GET /js/app.js` → **200 text/javascript** ✓
- `GET /api/stream` → emitted a real **`event: yard`** SSE frame ✓
- `/api/snapshot` body **validated against schema/yard-snapshot.schema.json via the vendored validator** (draft 2020-12): `valid: true, errors: 0` ✓

The stale claims (`yard board does not exist`, `no quickstart`) **died in the same commit** (4e5fb8a) that made them false; residual occurrences are meta-commentary/task descriptions, not false claims. `docs/doc-map.md` user-family rows trued in 4e5fb8a (README row → "explanation + how-to LIVING" with landed note; scheduled-quickstart row → `README.md#quickstart` LIVING). `storePathDisplay` normalized to `~/...` (Law 7 portability working — no machine-pinned absolute path).

**7. CI step — both legs green, zero-test guard proven to fire.** I ran the step's logic locally: real board/web → exit 0, parsed count 50 (green). Empty dir → **node --test exits 0** (the lying-instrument shape the car disclosed) but the guard parses `# tests 0` from the TAP trailer and **refuses (exit 1)**. Both matrix legs present. No other CI steps touched — the diff is purely additive; the staleness gate `if:` (ci.yml:336) is intact.

**8. Living contracts — same-commit, substantive.** gating-matrix Disconnect row rewritten to describe both halves with client evidence + D19 deviation (commit 0fbc034, same commit as the client code). state-ledger adds Question 3 (browser's fields) with a full lifecycle table across page-load / reconnect / server-restart (0fbc034). doc-map + README + setup.md Node row each in the commit that made them true. Lane-registry pin exists in both JS (lanes.test.js:11) and Go (TestLaneRegistryPin).

## The sentence check (one word, end to end)
Live state word **`returned`** (dispatch `2026-07-21-design-v0-round1-REJECT`), traced VERBATIM with file:line:
1. Disk: `artifacts/reviews/2026-07-21-design-v0-round1-REJECT.json` → `kind: "returned"`
2. Fold: `board/fold/algorithm.go:204` → `State: winnerKind` (winnerKind="returned" by precedence map :10)
3. Wire marshal: `board/fold/output.go:16` → `"state": d.State` → JSON `"state":"returned"`
4. Ingest: `board/web/js/ingest.js:64` stores payload verbatim (no field touch)
5. Render VM: `board/web/js/render.js:113` → `state: d.state` (describeVocab only for `stateRegister`, :114)
6. DOM: `board/web/js/dom-writer.js:166` → `textContent = d.state`

Proven at the DOM: end-to-end smoke through the real render.js + dom-writer.js + minidom → DOM textContent contains `returned` and `REJECT` verbatim; `N of M lanes`, `as of`, `connected`, freight-dark and fuel-bagged all present and distinct. No hop translates.

## Adjudications
- **fresh-carries-no-age: CORRECT (a point in the car's favor).** The wire's `fresh` variant carries no `ageBucketMs`; binding Rule 3 forbids client-computed age. Rendering `fresh` alone honors the binding contract over the mockup's illustrative "fresh, 2s ago". Had the car shown a computed elapsed time it would have been a Major (client clock in age). Disclosed at compose.js:84-92.
- **system font stacks vs named webfonts: ACCEPTABLE.** board.css lists `'IBM Plex Mono'`/`'Barlow Condensed'` first, falling back to system stacks, with no network font fetch — self-contained, offline/CI-renderable. The named fonts are steering, not binding; swap is a pure CSS change. Disclosed (board.css:5-10).
- **GitNexus tools absent from the car's session: noted, nothing to rule** (disclosed).

## Constitution check
- **Law 1 (no confident falsehood; unknown as unknown):** vocab.js:36 renders unrecognised ids verbatim with `needs-attention`; compose.js `rank`/`freshnessRegister` sort unknown as most-severe. Honored.
- **Law 3 (TDD red-first):** matrix fault-injected red observed by me; zero-test CI guard proven to fire; per-commit red-first per messages. Honored.
- **Law 4 (no silent loss):** classifyFrame returns `unknown` never drops (sse-protocol.js:75); invalid payload discarded WITH visible condition + stale mark; dom-writer default renders `unrecognised lane body kind` never blank. Honored.
- **Law 5 (verification honesty):** I re-derived every count/claim rather than trusting the report. Honored.
- **Law 6 (no second copy):** handleWireSchema/validate.js serve THE schema file (handlers.go:88-90); vocab travels on the wire, never hardcoded. Honored.
- **Law 7 (the stranger deploys):** clean-clone replay succeeded; prerequisites disclosed (Go version + PATH gap); storePathDisplay normalized. Honored.

## HAVAGLANCE (structural; I cannot see pixels — stated honestly)
The hierarchy serves the one-glance test structurally: the most-severe register colors each lane's 6px left border (board.css:100,128-138) as a strong peripheral signal; three-color rationing means only nominal/in-progress/needs-attention ever color an element; board-about-itself alarms surface in the top chrome strip. The DOM smoke confirms the structure renders. The conductor's browser look remains the final visual-polish gate (the car disclosed this).

## Findings

**C5R-1 (MINOR, non-blocking) — state-ledger nomenclature: "four fields" names five.** `docs/contracts/state-ledger.md` (the Question-3 block added in 0fbc034) says `app.js` "owns four in-memory fields" then enumerates five (`snapshot`, `lastAppliedSeq`, `markedStale`, `clientConditions`, `connected`), bundling `markedStale + clientConditions` as one item to reach four. The table is internally consistent (four items, four rows) and every field is named and lifecycle-analyzed, so no reader is misled about state behavior; but in a living-contract document the word "field" is used for both the count (four) and the enumeration (five). Suggest "four state concerns" or "five fields across four rows". Does not block merge.

```starcar-artifact
outcome: APPROVE
findings: One MINOR, non-blocking. C5R-1 (MINOR) docs/contracts/state-ledger.md Question-3 block says app.js owns "four in-memory fields" but enumerates five (snapshot, lastAppliedSeq, markedStale, clientConditions, connected) by bundling markedStale+clientConditions; table is internally consistent and no state behavior is misrepresented. No Majors. All suites re-run green by the reviewer at 4e5fb8a: node --test 50/50, go test 59/59 across 5 packages, go vet clean, gofmt empty, Pester 242/242, probes 12/12 (the lone failure was sh-not-on-pwsh-PATH, environmental, probes outside Car 5 scope). YB-6 matrix uses an independent oracle and went red naming cases under fault injection (composeRegister stubbed to position-only), restored byte-identical to hash d755200b. Three register colors only; state/outcome words verbatim to the DOM; stale maps to needs-attention; zero client-clock reads in board/web/js; bagged vs dark distinct. EventSource-to-fetch+ReadableStream deviation premise verified at sse.go:75-77 (bare comment heartbeat, invisible to native EventSource), resolution faithful to D19 rationale and self-contained, D19 amendment candidacy correctly flagged. Clean-clone quickstart replay from a fresh git clone at this commit: GET / 200 html, /api/snapshot 200 json, /js/app.js 200 js, /api/stream emitted event: yard, snapshot validated against the wire schema via the vendored draft-2020-12 validator (valid true, 0 errors). Stale README phrases died in the same commit 4e5fb8a that made them false; doc-map user rows trued same-commit; gating-matrix and state-ledger updated in 0fbc034 alongside the code. CI node --test leg green locally and its zero-test guard proven to refuse an empty dir (exit 1) while node itself exits 0. Sentence check: the word returned traced verbatim disk kind to fold algorithm.go:204 to output.go:16 to ingest.js:64 to render.js:113 to dom-writer.js:166, confirmed byte-identical in the rendered DOM textContent.
abstract: Adversarial sentence-check review of Car 5 (the view car) of the yard-board train, commits 3dcbe56 27c2d94 374dd62 0fbc034 4e5fb8a against base bebfaef at HEAD 4e5fb8a. Verdict APPROVE with one non-blocking MINOR. Verified independently: all six suites, the YB-6 composition matrix (independent oracle plus fault injection), the three-color/verbatim/no-client-clock rendered-surface contracts, the EventSource deviation adjudication, wire validation and seq ordering, the clean-clone README quickstart (full prose-to-command-to-observation trace), the CI node --test leg and its zero-test guard, the living-contract same-commit updates, and an end-to-end verbatim trace of one state word from disk to DOM. Worktree left byte-identical clean, temp clone removed, nothing committed or pushed.
```