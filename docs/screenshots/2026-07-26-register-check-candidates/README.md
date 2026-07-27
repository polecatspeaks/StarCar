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
- `hot-yard.png` - the same board with one genuinely in-flight dispatch,
  freshness flipped to stale (both lanes carrying that dispatch render red).

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
