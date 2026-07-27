# #62 register-check screenshots - staleness disclosure

Status: Current

Captured by `board/web/verify-registers.mjs` (commit `45b0e12`, #62's visual
pass) against the AMBIENT real `artifacts/` store (`calm-yard.png`: no
`storePath` override, `verify-registers.mjs:104`) and against that same
store plus one extra in-flight record (`hot-yard.png`:
`buildScratchStoreWithInFlightDispatch()`, which `cpSync`s the real store
before adding its own record - `real-board-server.js:61`). Evidence for a
human/reviewer to read (the script's own closing line), never a pass/fail
gate - the landed computed-style regression guard is
`board/web/test/browser-register-cascade.test.js`.

- `calm-yard.png` - the nominal register across all five lanes, idle
  freshness.
- `hot-yard.png` - the same board with one genuinely in-flight dispatch;
  opened and reconfirmed (fix cycle round 3, R2-m3): all THREE live lanes
  (DISPATCHES, GATES, TRAINS) render red, each labelled "Live / stale,
  3060s" - not two. They render red together not because each "carries"
  the in-flight probe (it is unassigned yard inventory, present only in
  the dispatches lane's own data,
  `board/web/test/support/real-board-server.js`'s
  `buildScratchStoreWithInFlightDispatch` doc comment) - it is because
  `board/server/poll.go`'s `computeLiveFreshness` is a SINGLE board-global
  computation over every record and every dispatch, and its one result is
  assigned to every `position: "live"` lane alike (`poll.go`'s poll loop,
  the `case "live": lane.Freshness = liveFreshnessVal` assignment). AT THE
  TIME OF CAPTURE, FREIGHT ("Dark") and FUEL ("Bagged") were declared
  `position: "dark"`/`"bagged"` in `board/server`'s lane registry, neither
  `"live"`, so the SAME poll loop's `default:` branch assigned them a fixed
  `Freshness{Kind: "not-applicable"}` instead of `computeLiveFreshness`'s
  result - a constant, never computed from record age - which is why they
  rendered unchanged in both images. **This is no longer true of FREIGHT -
  see the DISCLOSED DIVERGENCE note below.**

These remain accurate evidence for what they were captured to show (#62's
shared visual language: lane plates, register colors, the Solari-board
dispatches lane, freshness chrome) - none of that is touched by the note
below.

**DISCLOSED STALENESS (#75 fix cycle round 2, R1-M1, 2026-07-27):** both
images incidentally show dispatch subject `a076bf6c0a94e302f`'s row
rendered as the record-dir hash `a076bf6c0a94e...` - the bottom-right cell
of the dispatches lane grid in each. That subject's winning record (the
latest `returned`) carries `task_id: process-42-car-r3`. As of `#75`
(`board/assemble/assemble.go`'s `taskIDsBySubject`, landed `d43dac8`
onward), the identical capture renders that row's visible identity as
`process-42-car-r3`, with the hash still reachable via the row's native
title tooltip. This is exactly the hash-as-identity rendering issue #75
was filed to remove - the rendering RULE changed, not the underlying data,
so recapturing would still be dated per-train evidence rather than live
documentation. Left in place rather than deleted or recaptured (out of
this fix's scope, and would drag the ambient store's ever-changing content
into an unrelated diff) and captioned here per NORTH STAR ("the commit
that invalidates a document updates that document, in the same commit")
rather than left to mislead a reader silently.

**DISCLOSED DIVERGENCE (#84 fix cycle round 2, R1-M3, 2026-07-27):** both
images show `FREIGHT / Dark / no equipment on this lane` - opened and
reconfirmed before writing this sentence. That rendering is no longer
current: issue #84 landed a store-mediated GitHub ticket adapter
(`scripts/Sync-Freight.ps1`) and flipped freight's registry position to
`live` (`board/server/laneregistry.go`), with three distinct freshness
states of its own (never-polled / fresh / stale). This is unrelated to
what these images were captured to evidence (#62's register/staleness
mechanism, still accurate for the other four lanes) and they are not
recaptured - the remedy is this caption, per the car-brief template's own
instruction, never a fresh screenshot chasing a UI that will keep changing.
