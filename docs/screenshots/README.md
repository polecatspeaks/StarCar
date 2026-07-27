# docs/screenshots - freight-lane divergence disclosure (#84)

Status: Current

This top-level README exists for exactly one bare file that has none of its
own: `2026-07-23-first-light.png`. Every other capture lives in its own
dated `*-candidates/` subdirectory with its own README - see those
directories for their own captions.

## `2026-07-23-first-light.png`

Captured at commit `d4458775d13cc42a48b5ae9f00e428d799bbcf30` (2026-07-23,
"FIRST LIGHT - the board's first human look" - the yard board's original
v0 walking-skeleton capture, issue #1). **Opened and reconfirmed before
writing this caption** (#84 fix cycle round 2, R1-M3): the FREIGHT lane
plate reads `FREIGHT / Dark / no equipment on this lane`.

This remains accurate evidence for what it was captured to show: v0's
honest-but-thin first paint (design rev 5's Q5 ruling), demonstrating that
a lane with no adapter renders loudly and honestly as dark, never silently
blank - the discovery mechanism this whole board exists to prove. None of
that is touched by the note below.

**DISCLOSED DIVERGENCE (#84, 2026-07-27):** freight is no longer dark.
Issue #84 landed a store-mediated ticket adapter (`scripts/Sync-Freight.ps1`)
and flipped freight's registry position to `live`
(`board/server/laneregistry.go`); the lane now renders the real GitHub
Project 6 Backlog/Todo queue, with three distinct freshness states of its
own (never-polled / fresh / stale - see `docs/design/2026-07-21-v0-yard-
skeleton-design.md` section 7's own struck-through entry for the trigger
that fired). This image is NOT recaptured - per the car-brief template's own
instruction, the remedy is a caption stating the divergence, never a fresh
screenshot chasing a UI that will keep changing. The image remains correct
evidence of v0's dark-lane honesty mechanism; it is simply no longer a
picture of freight's CURRENT rendering, and this paragraph is what keeps
that distinction legible to a reader who only looks at the picture.
