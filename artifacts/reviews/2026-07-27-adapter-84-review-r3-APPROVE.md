<!-- starcar-integrity: sha256=f63e134046654b97300a9964a3674f321c8e45f3b4f1b15af14d3f8ca342f911 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Freight lane #84 store-mediated ticket adapter, review round 3 (delta)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review (delta re-review)
Round: 3
Target: `car/adapter-84 fix-cycle r3 HEAD ee8aa9c`
Base reviewed: `baf109e8c29130771dee0030ed6010f3b06049e0`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `af9695467e625f504`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `baf109e8c29130771dee0030ed6010f3b06049e0` |

| Dispatch, the locator within the session | `af9695467e625f504` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain baf109e8c29130771dee0030ed6010f3b06049e0
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

# VERDICT: APPROVE

**0 Major, 1 minor (non-blocking, pre-existing), 3 notes.** Base verified `ee8aa9c5403175d38015259acdc2cd0eaf4f546a`, detached, clean tree, before any read. Both checkouts clean at exit. No fault injections were needed this round — see the governing check.

**The train is ready to land.** The one minor I raise is demonstrably pre-existing debt from #51, outside this train's scope, and it blocks nothing.

---

## GOVERNING CHECK: is it genuinely documentation-only? — YES, proven at the parser level

I checked rather than inferred. I extracted both versions of `board/server/poll.go`, parsed each with `go/parser` **without** `parser.ParseComments` (so comments are never attached to the AST), re-printed each with `go/printer`, and compared:

```
comment-stripped AST bytes: old=12139 new=12139
RESULT: IDENTICAL - no executable line changed (comments only)
```

The single changed line is the trailing `//` comment on the `lastGoodLaneData` field declaration; the declaration itself is byte-identical. The other two files are `.md`. **This commit is comments-and-docs only, so my round-2 verification carries forward in full** — the R1-M1 gate, the R1-M2 condition, the screenshot audit, the freight links, and the R1-M4 test non-vacuity all remain proven at `baf109e` and are untouched here. This review is correspondingly narrow.

---

## THE TWO ROUND-2 IDs

| ID | Status | Evidence |
|---|---|---|
| **R2-M1** | **PRESENT (fixed)** — all three spots trued, each checked **against the code**, not against my finding text | See below |
| **R2-M2** | **PRESENT (fixed)** — converted to symbol form; anchor verified unique and stable | See below |

### R2-M1 — the ledger now tells the truth, verified against `poll.go` in the direction that matters

The brief was right to insist I verify forward (a ledger describing a gate the code does not have is the same defect one layer over). I extracted the actual write conditions and checked all six claims:

| Ledger claim | Code | ✓ |
|---|---|---|
| `"live"` UPDATED unconditionally on successful scan | `newLastGood = &amp;nowStr` (success branch only) → `poll.go:386-387` `if newLastGood != nil { s.lastGoodAsOf["live"] = newLastGood }` | ✓ |
| `"freight"` UPDATED only when `Kind != "never-polled"` | `poll.go:400-401`, exact expression | ✓ |
| dispatches/gates/trains `lastGoodLaneData` unconditional | `poll.go:414-422`, no extra gate inside `polled &amp;&amp; scanErr == nil` | ✓ |
| freight `lastGoodLaneData` uses **the SAME gate**, "so the two never advance out of step" | `poll.go:446-447`, character-identical expression; both sit under equivalent success conditions | ✓ |
| **"this gate is on the RETENTION MAP only: `lane.Data` itself is still assigned on every successful scan"** | `poll.go:445` `lane.Data = assembled.Freight` sits **before** the gate at `:446` | ✓ |
| restart/scan-failure/reconnect "remain identical in shape between the two keys" | failure branch reads `s.lastGoodAsOf["freight"]` (`:333`) and `lane.Data = s.lastGoodLaneData[spec.ID]` (`:450`) — structurally identical to live's | ✓ |

That fifth row is the one I most wanted to see, and it is the sharpest thing in this diff: it is precisely the distinction that makes R1-M2's condition *necessary* rather than redundant, and it matches what I measured behaviourally in round 2 (probe E — a never-polled lane with tickets still rendered the real ticket row). `grep -c never-polled` on the ledger: **4**, was **1** at `baf109e`. Confirmed.

**Ruling on correct-in-place rather than delete: CORRECT, and it is the showcase rule working as written.** The wrong sentence is quoted **verbatim** inside its own correction, with when it was true ("through fix cycle round 1"), what falsified it (round 2's R1-M1 fix), and why it is retained ("only so a reader who lands on this paragraph's history sees the mistake and its fix rather than a silently vanished sentence"). That is *"wrong calls stay attributed"* rather than curated away, and it preserves the old → delta → new legibility the living-contracts rule wants. I also confirmed the closing clause is itself true: only poll-success diverges; the other three columns do not.

I additionally checked markdown table integrity, since the new cells carry heavy inline formatting — every row is **7 columns** at both commits (row 115's ninth pipe is the escaped `\|` inside its own code span). No silent column corruption.

### R2-M2 — the symbol anchor is genuinely stable

- **Unique?** `lastGoodLaneData[laneID]` occurs **exactly once** in `state-ledger.md` (line 116). The three other `lastGoodLaneData` mentions (`:99`, `:127`, `:135`) are prose without the `[laneID]` form, so the disambiguator does real work.
- **Immune to insertion?** Yes — that is the whole point, and it is the failure mode that broke this citation **twice** (`:102`→`:108`, then `:108`→table header).
- **Would a plausible future edit break it silently?** Table reordering: no effect on a name anchor. Field rename: would change both the row's first cell and the Go field — and the citation lives in the comment *on that very field declaration*, so the author is looking straight at it. Low risk and self-revealing.
- The comment's own quotation of `lanes.js`'s `NO_DATA_BY_DESIGN` warning resolves **verbatim** (checked against the flattened comment).

**On the "no gate binds it now" residual — this is a net improvement, not a regression.** Before, `CitationResolverPolicy` *did* resolve `:108` and reported green while it pointed at the wrong content: a false assurance. After, it does not bind at all: no assurance, but no lie. This repo's own severity philosophy — *"an instrument that cries wolf is worse than no instrument, because everything downstream of a lying instrument is poisoned"* — cuts the same way for a green-over-wrong gate. Trading a false-green for an honest-unchecked, on the landed `lanes.js` precedent already ratified under #69/#71 MAJOR-R1-4, is the right call. Confirmed empirically: `poll.go` no longer appears anywhere in the resolver's output.

### N4 — applied

`docs/screenshots/2026-07-26-view-28-12-candidates/README.md:62` now reads *"carries no such **#75** note."* Trip hazard removed.

---

## MINOR

### R3-m1 — `poll_test.go:445` cites `state-ledger.md:102`, which is wrong (pre-existing; does NOT block)

```
board/server/poll_test.go:445
  "(design S6 row 1 / state-ledger.md:102: failed lane carries lastGood
   VISIBLY MARKED, never an empty payload)"
```

`state-ledger.md:102` is currently *"artifact rows: 1 -&gt; 1 (unchanged - the board server never writes to or commits into the…"* — unrelated prose. This train's ledger insertions displaced it further, so it is the same class as R2-M2, one file over.

**But it is not this train's defect, and I proved that rather than assuming it:** at the original base `51fb403`, before any #84 work, `poll_test.go` already carried this citation (at `:154` and `:186`) and `state-ledger.md:102` was already the `seq` row — not the row the citation describes. `git log -S` attributes the line to `5fb8e49`, the **#51** fix. It is precisely the error `poll.go`'s own comment records having corrected under **#52 C51R-4** — a correction applied to `poll.go` and never swept to its twin.

**Why minor and non-blocking:** it predates the train; my round-2 finding named `poll.go:123` with file:line precision and the car fixed exactly that, correctly; no behaviour depends on it; and the ledger itself now tells the truth. Rejecting a documentation-only round for pre-existing debt one file over would be moving the goalposts. **Recommended follow-up ticket:** sweep `state-ledger.md:NNN` citations repo-wide to the symbol form R2-M2 just landed — which would also make them structurally immune.

---

## SUITES — run myself at `ee8aa9c`, one instrument named per line

| Instrument | Claimed | Observed | |
|---|---|---|---|
| `go test ./...` (board module) | 111/111 | **111 PASS / 0 FAIL** | ✓ |
| `go vet ./...` | clean | **exit 0** | ✓ |
| `gofmt -l .` (non-mutating) | clean | **empty output, exit 0** | ✓ |
| `node --test test/*.test.js` | 238/238 | **238 tests / 238 pass / 0 fail** | ✓ |
| `node --test` (bare — CI's exact invocation, `ci.yml:374`) | 240/240 | **240 tests / 240 pass / 0 fail** | ✓ |
| `Invoke-Pester ./scripts/tests` | 236/0/4 of 240 | **240 total / 235 pass / 0 fail / 5 skip** | ✓ (delta below) |
| `Invoke-Pester ./scripts/probes` | 29/29 | **29/29** — #79's ManifestBoardJoin green | ✓ |
| `Invoke-Pester ./scripts/store-checks` | 275/275 | **275/275** | ✓ |
| `browser-freight-states.test.js` isolated | 5/5 | **5/5** | ✓ |

**Detached-HEAD skip delta:** my 5th skip is `run-session-start-guards.sh … [ci-baseline] marker ONLY when attached to a branch`, reason verbatim *"is skipped, because detached HEAD (no branch)"*. On an attached branch it runs → **236 pass / 4 skip**. The car's claim is correct; my delta is exactly that one skip — identical to rounds 1 and 2.

**Both node instruments now stated and both confirmed**, closing my round-2 N1 properly: the +2 is exactly `test/minidom.js` and `test/support/real-board-server.js`, which node counts as files. **No #81 bind error occurred this round** in any run.

---

## CONVERGENCE — ruled

**4M/6m → 2M/0m → 0M/1m.**

| Swirl trigger (escalate on any two) | Fires? | |
|---|---|---|
| Major counts stop declining | **NO** | 4 → 2 → **0** |
| Findings cluster in the same section across rounds | **NO** | poll.go/screenshots/adapter-header → state-ledger.md → (none new) |
| Round's findings are defects the previous round's fixes created | **NO** | R3-m1 proven pre-existing at `51fb403`, authored `5fb8e49` (#51) |

**Zero of three fire.** The coordinator asked specifically whether a third instance of "the round-N fix created the round-N+1 defect" had appeared, since that was the shape twice running. **It has not** — and I established that from git history rather than from the car's framing. That pattern is broken, which is the signal that this fix cycle has actually converged rather than relocated its defects.

---

## CONSTITUTION CHECK

- **Law 1 at the document tier — the question round 2 was about: the ledger now TELLS THE TRUTH.** All six of its claims verified against the actual conditions at `poll.go:386-401` and `:414-450`, including the subtle retention-map-vs-`lane.Data` distinction. No claim over-reaches the code, and none under-describes it.
- **Law 4** — the wrong sentence is corrected in place with its history legible, not deleted. Nothing lost silently.
- **Law 6** — the citation now has one stable owner (the row's own name), replacing a coordinate that had drifted twice.
- **Law 7** — untouched this round; no vocabulary or taxonomy change.

**CITATION CHECK (#42)** — all three touched files carry `#84` (11 / 6 / 2 refs); the new `poll.go` comment cites `#84 fix cycle round 3, R2-M2` and its quotation of `lanes.js` resolves verbatim; no new files, so `CodeCitationPolicy` is unaffected and green. `CitationResolverPolicy`: 32 total, **28 pass, 0 fail**, 4 informational skips. One wrong citation remains (R3-m1, pre-existing).

**DOC CHECK** — `state-ledger.md` ✓ (verified forward against code; table integrity intact); `poll.go` comment ✓ (quote verbatim, anchor unique); screenshot README ✓ (N4 applied).

---

## BASE-DELTA (#13)

- **Round-2 reviewed HEAD:** `baf109e8c29130771dee0030ed6010f3b06049e0`
- **This commit:** `ee8aa9c5403175d38015259acdc2cd0eaf4f546a`
- `git diff baf109e..ee8aa9c --stat` → **3 files, +22 / −8** (`board/server/poll.go`, `docs/contracts/state-ledger.md`, `docs/screenshots/2026-07-26-view-28-12-candidates/README.md`)
- No `board/fold` path. No new files. No executable line changed (parser-proven).

**Unreproducible-evidence callout (#13):** none. Every claim is re-derivable: the comments-only proof by `go/parser` without `ParseComments` plus `go/printer` (program preserved in the scratchpad, recipe fully stated); the ledger-vs-code verification by reading the named `poll.go` line ranges; anchor uniqueness by `grep -c`; table integrity by counting structural pipes at both commits; R3-m1's provenance by `git show 51fb403:` and `git log -S`. All suites run by direct invocation at `ee8aa9c`. No fault injections were required this round, so no restores were needed; the worktree and shared checkout were clean at entry and exit.

**Nothing blocks. Both round-2 Majors are closed, the ledger is truthful, and the train is ready to land.**

```starcar-artifact
task-id: adapter-84-review-r3
outcome: APPROVE
findings: 0 Major, 1 minor (non-blocking, pre-existing), 3 notes. GOVERNING CHECK PASSED AND PROVEN AT THE PARSER LEVEL: both versions of board/server/poll.go parsed with go/parser WITHOUT ParseComments and re-printed via go/printer are byte-identical at 12139 bytes each, so no executable line changed and the commit is genuinely comments-and-docs only - my round-2 verification therefore carries forward untouched. R2-M1 PRESENT (fixed): all three stale spots trued, and I verified each FORWARD against the actual code rather than against my own finding text - live unconditional at poll.go:386-387, freight gated at poll.go:400-401, dispatches/gates/trains unconditional at poll.go:414-422, freight retention gated by the character-identical expression at poll.go:446-447, and critically the new clause that the gate is on the RETENTION MAP only is exactly right because lane.Data = assembled.Freight at poll.go:445 sits BEFORE the gate at :446, which matches what I measured behaviourally in round 2; the restart/scan-failure/reconnect columns are confirmed identical in shape; grep -c never-polled on the ledger returns 4, was 1. Markdown table integrity also checked: every row is 7 columns at both commits, row 115's ninth pipe being the escaped pipe inside its own code span. The correct-in-place choice is RULED CORRECT: the wrong sentence is quoted verbatim inside its own correction with when it was true, what falsified it, and why it is retained - the showcase rule working as written, and it preserves old-to-delta-to-new legibility. R2-M2 PRESENT (fixed): the symbol anchor lastGoodLaneData[laneID] occurs EXACTLY ONCE in the document (the three other lastGoodLaneData mentions lack the bracket form), is immune to insertion which is the only way this citation has ever broken (twice), and a field rename would touch the very declaration the comment sits on; the comment's quotation of lanes.js resolves verbatim; poll.go no longer appears anywhere in the citation resolver's output. The no-gate-binds-it residual is a NET IMPROVEMENT not a regression - before, the gate resolved :108 and reported green while it pointed at the wrong content, a false assurance, and this repo's own severity philosophy treats a lying instrument as worse than none. N4 confirmed applied at README:62. NEW MINOR R3-m1, NON-BLOCKING: board/server/poll_test.go:445 cites state-ledger.md:102 which is unrelated prose - same class as R2-M2 one file over - but I PROVED it pre-existing rather than assuming: at the original base 51fb403, before any #84 work, poll_test.go already carried this citation at :154 and :186 and state-ledger.md:102 was already the seq row, and git log -S attributes the line to 5fb8e49 under #51; it is the identical error poll.go's own comment records correcting under #52 C51R-4, applied to poll.go and never swept to its twin. Recommended as a follow-up ticket to sweep those citations to the symbol form, not a fourth round. Suites at ee8aa9c: Go 111/111 PASS 0 FAIL, go vet exit 0, gofmt -l empty (non-mutating this round); node --test test/*.test.js 238/238 AND bare node --test 240/240, both instruments stated and both confirmed with the +2 explained as minidom.js and support/real-board-server.js, closing my round-2 N1; Pester scripts/tests 240 total 235 pass 0 fail 5 skip with the 5th being exactly the detached-HEAD skip so the car's 236/4 is correct; probes 29/29 with ManifestBoardJoin green; store-checks 275/275; browser-freight-states isolated 5/5. No #81 bind error occurred in any run this round. CONVERGENCE RULED: 4M/6m to 2M/0m to 0M/1m, and ZERO of the three swirl triggers fire - counts declining sharply, no section clustering, and critically NO third instance of the round-N-fix-creates-round-N+1-defect shape, which I established from git history rather than the car's framing; that pattern is broken, which is the signal the cycle genuinely converged rather than relocating its defects. CONSTITUTION: Law 1 at the document tier is satisfied - the ledger now tells the truth, verified forward against code in the direction that matters. Nothing blocks; the train is ready to land.
abstract: Delta review round 3 of ee8aa9c over baf109e for issue #84, the store-mediated freight ticket adapter. APPROVE - the train is ready to land. The governing question was whether the round is genuinely documentation-only, and I proved it at the parser level rather than inferring it: poll.go parsed with comments discarded and re-printed is byte-identical across both commits, so my round-2 verification of the code carries forward and this review is narrow. Both round-2 Majors are closed. The state ledger's three stale spots are trued and, checked forward against the actual poll.go conditions, now describe the code accurately - including the subtle and correct new clause that the never-polled gate binds the retention map only, never the payload served on the current poll. The drifted line-number citation is converted to a symbol anchor that I confirmed unique and insertion-immune, and the resulting loss of gate coverage is a net gain over a gate that previously reported green while pointing at the wrong content. One minor remains and does not block: a sibling wrong citation in poll_test.go, which I proved from git history to predate this train by two tickets rather than being another defect its own fixes created - and that absence is the convergence signal, since the fix-creates-next-defect shape had appeared in both prior rounds and did not appear here.
```