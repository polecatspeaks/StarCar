# #67 screenshot - lane history filters and hot-row exemptions

Status: Current

`lane-filters.png` is a bare file with no README until now (#84 fix cycle
round 2, R1-M3 - the same class named for `2026-07-23-first-light.png` and
the `2026-07-26-*` directories, found while auditing every screenshot
directory rather than only the ones a review verdict happened to cite).

Captured against a lane-filter scratch store (subject prefix
`lane-filter-*`, `board/web/test/support/real-board-server.js`'s
`buildScratchStoreWithLaneFilterFixtures`) proving #67's "when in doubt,
show the row" history-capping rule: the dispatches lane shows
"showing last 4 of 11 returned - full record in the store" while every
non-terminal row (`overdue`, in the image, rendered red) stays visible
regardless of recency; the trains lane shows the equivalent "showing last
4 of 5" summary with the same never-hide-a-hot-row exemption for its own
rolling/hot-outcome trains. The falsifiable, re-runnable form of this same
claim is `board/web/test/render.test.js`'s `#67` test group, which this
image only illustrates.

**DISCLOSED DIVERGENCE (#84 fix cycle round 2, R1-M3, 2026-07-27):**
opened and reconfirmed before writing this sentence. The image shows
`FREIGHT / the inbound ticket queue / Dark / no equipment on this lane`
(lane 4). That rendering is no longer current: issue #84 landed a
store-mediated GitHub ticket adapter (`scripts/Sync-Freight.ps1`) and
flipped freight's registry position to `live`
(`board/server/laneregistry.go`), with three distinct freshness states of
its own. This is unrelated to what this image was captured to evidence
(#67's history-capping/hot-row-exemption rule on the dispatches and trains
lanes, still accurate) and it is not recaptured - the remedy is this
caption, per the car-brief template's own instruction, never a fresh
screenshot chasing a UI that will keep changing.
