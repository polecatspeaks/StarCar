# #28/#12 screenshots - staleness disclosure

Status: Current

Captured by `board/web/verify-registers.mjs` (commit `3076a40`, clickable
provenance links + car health bar) against the AMBIENT real `artifacts/`
store (`calm-yard.png`: no `storePath` override, `verify-registers.mjs:104`)
and against that same store plus one extra in-flight record
(`hot-yard.png`: `buildScratchStoreWithInFlightDispatch()`, which `cpSync`s
the real store before adding its own record - `real-board-server.js:61`).
`health-trend-and-provenance.png` is captured separately, against
`buildScratchStoreWithHealthTrendFamilies()` - a minimal, self-contained
fixture with no path through the real store, so it carries none of this
staleness (its subjects never carry `task_id` and are unaffected by #75).
Evidence for a human/reviewer to read, never a pass/fail gate - the landed
computed-style regression guard is
`board/web/test/browser-register-cascade.test.js`.

- `calm-yard.png` / `hot-yard.png` - the nominal/stale register pair, same
  posture as the #62 register-check directory's own pair.
- `health-trend-and-provenance.png` - the #28 ticket-link/record-dir
  provenance anchors and the #12 car health-trend badge, both rendering
  against a controlled review-round fixture.

These remain accurate evidence for what they were captured to show (#28's
clickable provenance, #12's health-trend badge) - none of that is touched
by the note below.

**DISCLOSED STALENESS (#75 fix cycle round 2, R1-M1, 2026-07-27):**
`calm-yard.png` and `hot-yard.png` both incidentally show dispatch subject
`a076bf6c0a94e302f`'s row rendered as the record-dir hash
`a076bf6c0a94e...` - the bottom-right cell of the dispatches lane grid in
each. That subject's winning record (the latest `returned`) carries
`task_id: process-42-car-r3`. As of `#75` (`board/assemble/assemble.go`'s
`taskIDsBySubject`, landed `d43dac8` onward), the identical capture renders
that row's visible identity as `process-42-car-r3`, with the hash still
reachable via the row's native title tooltip. This is exactly the
hash-as-identity rendering issue #75 was filed to remove - the rendering
RULE changed, not the underlying data, so recapturing would still be dated
per-train evidence rather than live documentation. Left in place rather
than deleted or recaptured (out of this fix's scope, and would drag the
ambient store's ever-changing content into an unrelated diff) and
captioned here per NORTH STAR ("the commit that invalidates a document
updates that document, in the same commit") rather than left to mislead a
reader silently. `health-trend-and-provenance.png` is unaffected (see
above) and carries no such note.
