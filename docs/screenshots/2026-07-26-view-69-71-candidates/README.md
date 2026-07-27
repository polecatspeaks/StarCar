# #69/#71 screenshots - captions and staleness disclosure

Status: Current

Captured against `buildScratchStoreUnderRepoRootWithConditionsAndSuperseded`
(`board/web/test/support/real-board-server.js`), real Chromium (Playwright
library), real `board/server/` Go binary. Cited from
`docs/design/2026-07-21-v0-yard-skeleton-design.md`'s §12b amendment.

## Round 1 (2026-07-26) - the conditions-strip open-state mechanism (#69 half 2)

- `collapsed-before-click.png` - initial paint, conditions strip collapsed.
- `expanded-after-click.png` - strip and its one condition group opened via a
  real click.
- `survives-dom-rebuild.png` - open state survives a real poll-driven DOM
  rebuild (no reload).
- `survives-page-reload.png` - open state survives a real `page.reload()`.

These four remain accurate evidence for what they were captured to show
(#69's `sessionStorage`-backed strip/group persistence, MAJOR-R1-2's subject)
- that mechanism is unchanged by fix cycle round 2.

**DISCLOSED STALENESS (fix cycle round 2, MAJOR-R1-1, 2026-07-27):** all four
also incidentally show the round-1 SUPERSEDED-ENTRY rendering (the
`dispatched 2026-07-20T09:00:00Z` line beside `view-69-71-superseded-de...`),
because the shared fixture seeds a superseded pair. That rendering was
appended as a SIBLING of the row into the shared `.solari-rows` grid -
round 1 review measured this to orphan a wrapped block onto a different
subject's line in real use. It no longer matches the code: the block now
nests INSIDE its owner row behind a collapsed disclosure. Left in place
rather than deleted (the four still document the strip mechanism correctly)
and captioned here per NORTH STAR ("the commit that invalidates a document
updates that document, in the same commit") rather than left to mislead a
reader silently.

## Round 2 (2026-07-27) - the corrected superseded disclosure (MAJOR-R1-1)

- `superseded-collapsed-r2.png` - the same fixture's dispatch row, default
  state: a quiet "1 superseded" summary line nested INSIDE the row (never a
  sibling cell).
- `superseded-expanded-r2.png` - the same row after a real click on that
  summary: the superseded entry (`dispatched 2026-07-20T09:00:00Z`) renders
  indented beneath it, still inside the row's own box.

Structural containment (`disclosure.closest('.solari-row').contains(disclosure)`)
was observed `true` live in the browser at capture time, not merely read off
the DOM shim; see the fix cycle round 2 car report for the fault-injection
evidence and the dom-writer.test.js structural regression tests
(`#71 fix-cycle r2 (MAJOR-R1-1)`).
