# Board UI mockups - Claude Design import (2026-07-26)

Status: Current

**Provenance (#62, and the reason this directory exists).** The owner generated these
board-UI variants in Claude Design (claude.ai/design), project
`77eb9e00-078b-438e-9c33-90ff2644abb2` ("StarCar UI board variants"), and ordered the
import with provenance on 2026-07-26. The Claude Design project remains the canonical,
editable original; this directory is the landed record so the direction survives outside
one tool's account. Files:

| File | What it is | Fidelity note |
|---|---|---|
| `starcar-board.dc.html` | The mockup document: five 1920x1080 variants across two design turns (turn 1: `1a` CTC panel, `1b` terminal-brutalist, `1c` softer ops-room; turn 2 - the schematic pivot: `2a` track schematic, `2b` dense interlocking), plus a demo-data component script with `disconnected` / `showDiscovery` state toggles | Transcribed from the design MCP fetch; the project URL holds the canonical bytes |
| `support.js` | The design tool's GENERATED viewer runtime (dc-runtime, React-based) - required to RENDER the `.dc.html`, never part of the shipped board | Extracted mechanically from the MCP response, byte-for-byte; only the provenance header was prepended |

**Doctrine: these are DESIGN DIRECTION, never contract** (mock doctrine, owner-ratified
2026-07-23, stated in full in `docs/design/2026-07-23-ui-mockup-brief.md` - "the track
signal, not the track"). The binding contracts remain the yard-skeleton design (rev 5),
the three-register law, and the pinned taxonomies. The #62 car steers by these mocks,
notes deviations-from-direction in its report, and routes direction-vs-contract
conflicts to issue #1 with contract winning meanwhile.

**What the direction already gets right** (verified against the live contracts at
import): the three severity colors are the board's REAL register tokens (`#d9d5c9`
nominal, `#ffb454` in-progress/amber, `#ff4a3a` needs-attention); the five lanes match
the live registry (trains, gates, dispatches, freight, fuel); the honesty chrome is
everywhere (DEMO banners, "REAL, from the live store" vs demo-data labeling, "lane dark -
no equipment", "bagged - data held, not surfaced", "manifests designed, not yet written",
REJECT framed as caught-defect-normal-traffic); and a `disconnected - showing last known`
state exists as a toggle.

**Known deviations-from-contract to adjudicate at implementation (not defects in the
mock - direction is allowed to dream):**
- Google-Fonts `<link>` (Barlow Condensed, IBM Plex Mono): the shipped board is
  no-build-step AND offline-capable today; a webfont dependency is a real posture
  question for the #62 car to surface, not silently adopt (options: vendor the fonts,
  system-font fallback stack, or accept the network dependency - owner taste).
- The demo component invents dispatch states (`quarantined` as a discovery example) and
  a `presumed-lost` row - fine in a self-labeled demo, but the #62 car renders REAL
  store vocabulary only.
- 1920x1080 fixed-canvas layouts: the shipped board is responsive-ish; the wall-display
  framing is the design target, the implementation keeps working at other sizes.

**Rendering these mocks:** open the Claude Design project URL (canonical), or serve this
directory and open `starcar-board.dc.html` in a browser with `window.React` available
(the design tool's viewer normally supplies it) - `support.js` throws without it. The
mock is fully readable as markup + component data without rendering.
