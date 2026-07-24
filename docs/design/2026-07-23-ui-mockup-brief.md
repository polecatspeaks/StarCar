# StarCar yard board - UI mockup brief (v1)

Status: Open
State: v3 - APPROVED at delta round 2 (`artifacts/reviews/` - round 1 REJECT + round 2
APPROVE); UIB2-1/UIB2-2 swept (stale footer removed; the `[UIB-1/2/5]` fold markers
moved out of the paste zone - they lived at the sample-data paragraph, folded per round
1, recorded here instead so the paste stays jargon-free)
Review record: round 1 REJECT (1 Major, 4 Minor) -
`artifacts/reviews/2026-07-23-ui-brief-round1-REJECT.md` - the Major: v1 presented an
unbuilt train manifest as live-store data on a provenance document (Law 1). Folded below
with `[UIB-n, folded]` markers.
**How this shop treats mocks (owner doctrine, ratified 2026-07-23):** mockups are
DESIGN DIRECTION, never contract - "what could be," not "what will be." The owner's
form: *the mock is the track signal switch telling us to use this track and not the
other* - it routes the work; the rails it runs on are the reviewed contracts (laws →
design → spec → this brief). The ranking is structural, not stylistic: a mock never
passed a gate, so it cannot outrank artifacts that did - the same afternoon this
doctrine was ratified, the mocks rendered `stale` in the wrong register, and because
they are direction that error became feedback instead of law. Implementing cars build
to the contracts, steer by the direction, note deviations-from-direction in their
reports (a note, never an honest-stop), and route direction-vs-contract conflicts to
issue #1 with contract winning meanwhile.

Purpose: the one-page brief handed to external design tools to produce layout mockups.
This document is the PROVENANCE of the board's visual language: mockups produced from it
are design INPUT to the view car (Car 5); the binding contracts live in
`docs/design/2026-07-21-v0-yard-skeleton-design.md` (rev 5) and this brief restates them
for a reader with zero repo context. If a mockup fights a rule below, that conflict is
DESIGN FEEDBACK, and it LANDS as a comment on issue #1 (or, if it changes a contract, an
amendment block on the design doc) - never a rule to quietly break, never captured
nowhere `[UIB-4, folded]`.

---

## The brief (paste everything below this line into the design tool)

Design a **live wall-display status board** called **StarCar** that renders a software
pipeline the way a dispatcher watches a **rail yard**. Multi-agent work is the traffic:
a **train** is a unit of work moving through gates; its **cars** are worker dispatches;
**signals** are review gates. The display is glanced at from across a room, not studied:
one pass must tell an operator whether anything needs them.

**The one hard aesthetic law: three severity colors, total.** Every element renders in
exactly one of three registers - `nominal` (calm), `in-progress` (active, neutral
attention), `needs-attention` (hot). No fourth color, no gradients of alarm, no badge
soup. A lane's color is the MOST SEVERE of its contributing facts. If everything is calm
the board is visually quiet; a single hot element should be findable in under a second.

**Layout: five horizontal lanes (tracks), all always present:**
1. **TRAINS** - active work units. Each train is a labeled track holding its cars in
   order. A car shows: a short title, a state word, and its register color. The state
   words in the mockup below are ILLUSTRATIVE rail-metaphor visuals (`rolling`,
   `at inspection`, `shopped x2` = rejected twice, `coupled`, `held`) - the real board
   renders whatever state word its data source provides, VERBATIM, never a translation
   of it. Design the shape of a car chip, not a fixed word list.
2. **GATES** - review signals: small signal lights with a gate name and a verdict word
   rendered VERBATIM (`APPROVE`, `REJECT`, `CONFIRM`, `pending`). REJECTs are normal
   traffic here, not emergencies - this shop treats a caught defect as a success.
3. **DISPATCHES** - the raw feed: every worker dispatch with liveness (`dispatched`,
   `overdue`, `returned`, `presumed-lost`) and how long it has run. Includes a "yard
   inventory" area for dispatches not yet assigned to any train - visible, never hidden.
4. **FREIGHT** - the inbound ticket queue. In v0 this lane is **dark**: it has no data
   source yet. Render it PRESENT and honestly dark ("no equipment on this lane"), never
   omitted, never faked with placeholder tickets.
5. **FUEL** - the spend/usage gauge. In v0 this lane is **bagged** (railroad term: a
   hooded signal, deliberately out of service): data exists but is not surfaced. Render
   the hood: "data held, not surfaced" - honest, slightly different from dark.

**Per-lane text rules:** the primary line is what the lane IS (its position on the
build-out); the secondary line is what its DATA is doing ("fresh, 2s ago" / "stale,
40s" / "source failed - showing last good from 09:14"). A lane with no data source shows
NO secondary line at all - it will never have one, and "not yet read" would be a lie.

**Honesty chrome (always visible, part of the design, not an afterthought):**
- a global `as of <time>` stamp - the board's own data age;
- a connection state: when the feed dies, the board visibly flips to "disconnected -
  showing last known" while keeping the stale picture on screen, clearly marked;
- a board-conditions strip for faults about the BOARD itself ("3 records unreadable",
  "vocabulary file empty") - distinct from yard status;
- a lane count ("registry declares 5 lanes") - so a silently missing lane is detectable;
- when running on demo data: a persistent DEMO banner.
- **the discovery state**: when the board meets a state word it does not recognise, it
  renders it hot, BY NAME, verbatim ("unrecognised state: 'quarantined'") - this board
  treats unknown vocabulary as a discovery to surface, never an error to hide.

**Sample data to mock with** - two kinds, labeled honestly:
- **REAL, from the live store:** car `acc761f0add2b0af2` (outcome `done`) and car
  `ac7d81bda8f23f2a6` (outcome `APPROVE`) - both completed within the last hour of each
  other; gate records `design round 1: REJECT` and `design round 2: REJECT` (a healthy
  shop with visible rejections); a dispatches lane folding to **~17** dispatch entries
  from ~65 total store records.
- **ILLUSTRATIVE, not yet in the store:** the train grouping itself. Group the two real
  cars under a track labeled `train:index-gate-scope` ("Scope the index staleness gate")
  to mock the trains lane - but know that train-manifest records are designed and not
  yet written, so on day one the real board renders these cars in yard inventory and a
  thin trains lane. Mock both states if you can: a populated track AND the honest
  thin/empty track.
Freight dark; fuel bagged, in every variant.

**Vibe:** industrial rail-yard control room, not SaaS dashboard. Dense but calm.
Dark-room friendly. Typography does the work; color is rationed to the three registers.
Think dispatcher's CTC panel meets modern terminal aesthetics.

**Do NOT:** invent extra severity levels or per-lane color themes; hide or shrink empty
lanes; replace state words with icons alone (words are load-bearing); add fake data to
dark lanes to make the mock look fuller; auto-hide the honesty chrome to look cleaner.
The empty and dark states are not failure states of the design - they are the design
proving it tells the truth.

---

*Review record: round 1 REJECT (`2026-07-23-ui-brief-round1-REJECT.md`), delta round 2
APPROVE - both verdicts landed verbatim in `artifacts/reviews/`.*
