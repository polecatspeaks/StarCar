# Glossary

Status: Current

The human-readable vocabulary sheet: every house term, rail-metaphor term, and process
term a reader meets in this repo, each in one or two plain sentences. HAVAGLANCE applies
to this file about itself: find your word, understand it, leave. Deeper law lives in
`CLAUDE.md` and `docs/constitution.md`; classifications live in `docs/doc-map.md`.
A term used in a ratified document and missing here is a defect - add it in the commit
that notices.

## House phrases (owner coinage or adoption)

- **GEOLOGICAL DEVELOPMENT** - how this shop builds: substrates laid in readable order,
  probes as core samples, scars as the fossil record, change only by evidence-gated
  metamorphism - never by rewriting a stratum in place.
- **NIRTS** - *Need It Right This Second.* The demand-side twin of YAGNI: build nothing
  YAGNI forbids, build everything NIRTS demands; the gap between them is zero.
- **HAVAGLANCE** - *can I have a glance at it and understand everything it is trying to
  tell me in that glance.* The acceptance test for every information surface here.
- **FULL SENTENCE FLOW** - the owner's name for the sentence check: one reviewer traces
  one value from generation through every hop to presentation. Per-file correctness is
  a spelling check; someone must read the whole sentence.

## The rail metaphor

- **Yard** - the whole operation as rendered by the board: everything in motion and at
  rest, at a glance.
- **Train** - one unit of work moving through the gates; named by its EXPECTED RESULT,
  numbered by its headline GitHub ticket.
- **Car** - one worker dispatch inside a train: an implementer or a reviewer, executing
  one brief in an isolated worktree.
- **Consist** - a train's declared membership: which cars, in what roles.
- **Gate / signal** - an adversarial review point. A gate's verdict renders VERBATIM;
  a REJECT is normal traffic, not an emergency.
- **Conductor** - the orchestrating session: cuts briefs, dispatches cars, merges,
  never implements (outside a narrow hotfix boundary).
- **Yard inventory** - dispatches not assigned to any train: visible, never hidden.
- **Lane** - one horizontal band of the board (trains, gates, dispatches, freight,
  fuel), always present whether or not it has data.
- **Position** (of a lane) - what the lane IS on the build-out: `live` (rendering
  data), `bagged` (data held, deliberately not surfaced - the hooded signal), `dark`
  (no data source exists yet), `under-construction`.
- **Register** - the ONLY closed severity vocabulary, three values total: `nominal`
  (calm), `in-progress` (active), `needs-attention` (hot). Every color on the board is
  one of these; a lane renders the most severe of its contributing registers.
- **Solari board** - the split-flap terminal departure board; the visual genre of the
  dispatches lane, chosen because those boards are history's most trusted honest
  status surface.
- **Shopped** - a car sent back for rework after a REJECT (as in: in the repair shop),
  usually rendered with its round count.
- **Coupled** - a car whose work is merged.
- **Held** - work deliberately paused by the dispatcher, via an intent record.

## The store and the fold

- **Store** - the append-only record of everything that happened: one JSON file per
  dispatch event under `artifacts/`, hash-sealed, never edited.
- **Record** - one store file: `dispatched`, `returned`, `presumed-lost`, `intent`, or
  `ruling`, keyed by its **subject** (the identity - a dispatch id, or a `train:` name).
- **Fold** - the operation that turns the store's pile of records into one truthful
  statement per subject: precedence (`returned` beats `presumed-lost` beats
  `dispatched`), latest-at supersession with the losers exposed, and the liveness
  gradient. One sentence: the store remembers everything; the fold says what is true
  now.
- **Liveness** - a dispatch's folded state: `dispatched` (in flight, within patience),
  `overdue` (silent past its budget), `returned` (came back), `presumed-lost`
  (a watchdog gave up; a late return still wins).
- **Patience / budget** - the time a dispatch is granted before its silence becomes an
  alarm. Governs ALARM, never abort: blowing the budget makes work visible, not
  failed. Declared as a class at the ticket (small/medium/large patience), frozen to
  seconds at dispatch by the producer's stamp, enforced at the fold, disclosed on the
  board via **budget_source** (`record` = the dispatch carried its own promise;
  `default` = the shop's fallback patience was assumed).
- **Manifest** - a train's declaration: title, tickets, members with roles. Declares
  IDENTITY and membership only - status always comes from the fold, never the
  manifest. Direction of travel: derived from the kanban board and dispatch-time
  linkage rather than hand-written.
- **Supersession** - a newer record for the same subject winning over an older one,
  with the older one still exposed. Nothing is edited; truth is appended.
- **Detector / discovery** - the fold's instrument for vocabulary it does not
  recognise: an unknown state renders loudly BY NAME as a discovery (a state nobody
  enumerated yet), never coerced and never hidden.
- **Envelope** - the fenced `starcar-artifact` block ending every dispatch report:
  outcome, findings, abstract. How a `returned` record gets its outcome.
- **Vector** - a conformance fixture: this pile of records in, exactly this fold truth
  out. The language-neutral single authority every fold implementation must match.

## The process

- **The ladder** - design → spec → plan → cars-with-reviewers → whole-branch gate →
  CI; each rung catches a failure class at the cheapest point it is catchable.
- **Rung** - one step of the ladder.
- **Carrier** - the document that moves an obligation between rungs. Anything not
  written into the next rung's input does not exist there.
- **Brief** - a car's complete orders: base, tasks, rules, expected counts, envelope
  mandate. Self-sufficient by design.
- **Honest stop** - a car halting on a contradiction with evidence instead of
  improvising past it. A success outcome.
- **REJECT** - a gate refusing work. Counted as a SUCCESS for the process (a defect
  died cheaply); any Major finding forces one.
- **Swirl** - review rounds that relocate defects instead of resolving them (counts
  flat, findings clustering). Detected by mechanical triggers, never self-diagnosis;
  escalates to the owner.
- **Probe** - running the real thing and quoting the observation, because this shop
  has no vendor-maintained headers; truth is constructed, then LANDED as a durable
  artifact.
- **Scar** - the recorded cost that justifies a rule. A rule without its scar is a
  fence nobody remembers building.
- **Living vs FOSSIL** - the two document duties: living docs must always be current;
  fossils (verdicts, probes, retros, friction entries) are never edited after landing.
- **Mocks are direction** - a mockup routes the work like a track signal; the rails
  are the reviewed contracts. Direction steers, contracts bind.
