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

**DISCLOSED, fix cycle round 3 (MINOR-R2-2): the witness recorded for these
two used to read** *"Structural containment (`disclosure.closest('.solari-
row').contains(disclosure)`) was observed `true` live in the browser"* -
**a TAUTOLOGY.** `Element.closest()` returns an ancestor-or-self and
`contains()` is true for any ancestor, so that expression can only ever
evaluate `true` (or throw on `null`) - it cannot distinguish the fixed code
from round 1's sibling layout in any way that matters. Corrected witness,
FALSIFIABLE (measured live, fix cycle round 3): `disclosure.closest('.solari
-row') === ownRow` (the specific row element the disclosure's own subject
belongs to, not merely "some ancestor exists") - observed `true` - AND
`ownRow.contains(disclosure) && ownRow !== disclosure` - observed `true` -
AND the disclosure's own bounding box fully inside its row's bounding box
(`discRect.top >= rowRect.top && discRect.bottom <= rowRect.bottom` etc.) -
observed `true`. The underlying claim was never false, only the recorded
proof of it; the properly falsifiable form is what `dom-writer.test.js`'s
`#71 fix-cycle r2 (MAJOR-R1-1)` structural tests already assert (child-count
and class-name checks that DO go red under round 1's sibling layout, verified
by this car in round 2's own report) - cite those tests, not a hand-typed
witness expression, for the falsifiable claim.

**Also disclosed, fix cycle round 3 (MAJOR-R2-1's own screenshot fidelity):**
this single-dispatch-subject fixture cannot visually exhibit MAJOR-R2-1
(round 2's `flex-wrap: wrap` regression) OR its round-3 fix at all - the one
dispatch row here has no `elapsedSeconds` (a `returned`, terminal state), so
its 2-item cluster (subject, state) never had a third item to wrap under
either version, and both screenshots above render visually near-identical
collapsed layouts for that reason, not because nothing changed. See the
Round 3 section below for screenshots that actually exercise the regression
class (multiple rows, several with no disclosure at all).

## Round 3 (2026-07-27) - MAJOR-R2-1 fix: `.solari-row` no longer wraps its
own subject/state/elapsed cluster

- `dispatch-rows-multirow-collapsed-r3.png` - 7 plain dispatch rows (no
  superseded entry at all) each render as ONE visual line at the base
  ~22px height, never the round-2 regression's 51-73px two-line height.
- `dispatch-rows-multirow-expanded-r3.png` - the same board after a real
  click on one row's "1 superseded" summary: that row alone grows to show
  the entry (`dispatched 2026-07-20T08:00:00Z`), nested and indented
  within its own box; every plain row and the OTHER disclosure row
  (`with-sup-1`) keep their original one-line height, unaffected.

Captured against `buildScratchStoreForDispatchRowGeometry`
(`board/web/test/support/real-board-server.js`, added this round), narrow
viewport (340px, forces `.solari-rows`' auto-fill grid to a single column so
row heights are never confused with a shared grid-row-band stretch effect -
see the DISCLOSED note below). Measured live at capture time: plain rows
22px, `with-sup-0`/`with-sup-1` rows 38px collapsed. The falsifiable,
re-runnable form of this same claim is `board/web/test/
browser-dispatch-row-geometry.test.js` (fix cycle round 3), which asserts it
rather than merely showing it, and which this car ran RED against the
round-2 CSS before the fix (see the fix cycle round 3 report for the quoted
failures) and GREEN after.

**DISCLOSED (out of scope for MAJOR-R2-1, found incidentally while
recapturing): at a WIDE, multi-column viewport (1400px, the board's normal
desktop width), some plain rows in the same fixture measured 38px instead of
22px** - not because their own content wrapped (the content stays one line;
`browser-dispatch-row-geometry.test.js`'s own content-top-count assertion,
run at the narrow viewport, still passes), but because `.solari-rows` is a
CSS Grid with `auto-fill` columns and default `align-items: stretch`: a
plain row sharing a grid ROW BAND with a taller disclosure row gets its own
BOX stretched to match, leaving blank space below its one line of text. This
is not MAJOR-R2-1's failure mode (content wrapping, causing a mid-row crop)
and is not new to this round's fix - it is an inherent consequence of
disclosure rows legitimately differing in height from plain rows at all (a
property of #71's feature itself, present since MAJOR-R1-1 first shipped
round-2, and structurally impossible to fully avoid in a CSS Grid with
auto-sized row tracks and mixed-height siblings). Not fixed here: it is a
new observation, not one of this round's five named findings, and the swirl
cap on this ticket weighs against an unscoped same-round fix. Flagged for
the record; a future ticket could consider `align-items: start` on
`.solari-rows` if the cosmetic box-stretch is judged worth spending on.

**DISCLOSED DIVERGENCE (#84 fix cycle round 2, R1-M3, 2026-07-27):** opened
and reconfirmed every image in this directory before writing this
sentence. Six of the eight show `FREIGHT / the inbound ticket queue / Dark
/ no equipment on this lane` (lane 4): `collapsed-before-click.png`,
`expanded-after-click.png`, `survives-dom-rebuild.png`,
`survives-page-reload.png`, `superseded-collapsed-r2.png`, and
`superseded-expanded-r2.png`. The two round-3 geometry images
(`dispatch-rows-multirow-collapsed-r3.png`,
`dispatch-rows-multirow-expanded-r3.png`) are cropped/scrolled to the
dispatches lane only and never reach freight - they carry no such note.
That rendering is no longer current: issue #84 landed a store-mediated
GitHub ticket adapter (`scripts/Sync-Freight.ps1`) and flipped freight's
registry position to `live` (`board/server/laneregistry.go`), with three
distinct freshness states of its own. This is unrelated to what these
images were captured to evidence (#69/#71's conditions-strip and
superseded-disclosure mechanisms, still accurate) and they are not
recaptured - the remedy is this caption, per the car-brief template's own
instruction, never a fresh screenshot chasing a UI that will keep
changing.
