# #91 screenshot - the live board for the README, warts and all

Status: Current

`yard-board-2026-07-27.png` was supplied by the owner (2026-07-27) for use in the
top-level README's rebalance (#91) - a real render, not a mockup, and deliberately not
cropped to hide anything (owner ruling: "the repo is showing the process and this is
part of the process. The full monty is warts and all"). The car did not capture this
image; it verified the claims below by opening the file and, separately, by running this
worktree's own board server (base commit `20c3970`) against the same artifact store.

**Freight lane cross-check.** The image's freight lane lists 41 tickets by number. The
car independently queried `/api/snapshot` from a server started fresh in this worktree
and got the identical sorted set of 41 ticket numbers
(`1,2,3,6,10,11,14,15,16,17,19,22,23,25,43,44,45,55,56,57,58,59,60,61,63,64,66,68,70,72,73,76,77,78,80,81,82,83,85,86,87`).
That is strong evidence the image reflects this repo's artifact store as committed at
`20c3970` (`git log -1 -- artifacts/ticket-1` resolves to that same commit), though the
car cannot independently confirm the exact board code revision the owner's server process
was running at capture time.

**What is visible, verified against the image directly (not inherited from a prior
description) before this sentence was written:**

- **Freight rows have no CSS (#90).** `board/web/css/board.css` has zero style rules for
  any of `.freight-rows`/`.freight-row`/`.freight-number`/`.freight-title`/`.freight-status`
  (confirmed by grep against the base commit: the only two `freight` hits in that file are
  unrelated comments, board/web/css/board.css:34 and :538) and `board/web/js/dom-writer.js:611-621`
  builds the row DOM with those five classes and nothing else. The image shows the
  predicted result: 41 rows of unspaced number/title/status text reading as one run-on
  block.
- **Freight renders alarm-red because it reads `stale` (#63).** The freight lane header in
  the image reads "stale, 13:35". `board/server/config.go:63` sets `StalenessMs: 15000`
  (15 seconds); `scripts/Sync-Freight.ps1` is a manually-run batch sync, so freight is
  stale by this rule between essentially every two syncs. This is a genuine, currently
  persistent defect in freight specifically - `board/server/poll.go`'s
  `computeFreightFreshness` (line 576) has no "idle/at rest" case the way the three live
  lanes below do, by the design's own comment at line 571 ("a ticket queue has no 'yard at
  rest, nothing in flight' analog").
- **Trains lane shows only the 2026-07-23 walking-skeleton train (#76).** The image's
  Trains lane lists exactly one train, `train:board-v0`, with hash-named cars/reviewers.
  Confirmed: nothing in this repo has minted a second train manifest since; issue #76
  ("Train manifests as PLAN records...") is the open ticket for composition-time minting,
  and until it lands every later train is invisible on this lane.
- **Gates lane renders empty (#88).** The image's Gates lane shows the italic placeholder
  string `no gates in this fold` (`board/web/js/dom-writer.js:504`, verbatim match). Issue
  #88 records that the lane fills only from train-manifest membership, not from the
  dozens of real verdicts already sitting in the store as `returned` records.
- **One dispatched row renders as a bare runtime hash (#86).** The Dispatches lane's
  third chip (of five, left to right) reads `aa29fe4... dispatched 2:40` - a hash, unlike
  the four `returned` chips beside it which carry human task-ids (`adapter-84-car...`,
  `design-87-r4-a...`, etc.). Issue #86 records the cause as consumer-side, not
  producer-side: `board/assemble/assemble.go`'s `manifestPayload` reads only `subject`,
  `role` and `gate` off a manifest member and never `task_id`, even though a member can
  already carry one - so an in-flight row cannot be named from its plan even when the
  plan names it.
- **Three of the four live lanes also read `stale` in this specific capture** (dispatches,
  gates and trains each show "stale, 2:40"). **This is a property of the moment captured,
  not the board's resting state**: `computeLiveFreshness` (`board/server/poll.go:514`)
  returns `idle` - a calm, nominal register - when a lane's newest data is old AND nothing
  is in flight, and returns `stale` only while something IS in flight and hasn't reported
  in over `stalenessMs`. The image was captured while a real dispatch (`aa29fe4...`) was
  running, which is why those three lanes read `stale` at that moment. Re-querying this
  worktree's own server moments after opening this image, with no dispatch in flight,
  returned `dispatches: idle`, `gates: idle`, `trains: idle`, `freight: stale` - confirming
  the distinction holds and that only freight's staleness is structural (#63).
- **Fuel lane reads "data held, not surfaced."** Verbatim match to
  `board/web/js/render.js:453`. Honest: cost fields exist on some records (#11) but are
  not wired to this lane yet.

No divergence is disclosed beyond what is stated above, because nothing else in the image
was found to differ from the code at `20c3970` when checked.
