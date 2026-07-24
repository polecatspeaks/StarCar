# Family-agnostic harness design: the repo defines the contract, runtimes adapt to the repo

Status: Open
Stage: rev 1 - awaiting adversarial design review round 1
Issue: #47
Date: 2026-07-24
Supersedes: `docs/design/2026-07-24-dual-runtime-harness-design.md` (retired by owner
arbitration after 3 REJECT rounds; verdicts in `artifacts/reviews/` are the fossil record)

## §0 - Instrument check

**Split document, and the split is the lesson of the superseded design.** The
behavioural half - who owns onboarding, where identity is minted, how adapters degrade -
is prose, here. The precision half - the adapter contract (what events must yield what
records) and dispatch identity - is FORMAT, and the round-3 reviewer's convergence ruling
said so explicitly ("identity, join keys, dedup and ambiguity are format/protocol - prose
cannot hold them"). That half lands as an executable artifact: conformance vectors in the
proven `schema/vectors/` pattern (D3 names it), and this document only POINTS at it. The
superseded design iterated an identity model in prose for three rounds; this one does not
repeat the instrument error.

## §1 - Constraints

| Source | What it forbids here | How this design satisfies it |
|---|---|---|
| Law 7 (`constitution.md`): "built for the shop that did not build it ... no hardcoded schemas ... documentation a stranger can deploy from" | A harness only one agent family can operate; doctrine discoverable only through one family's config convention | The RATIFIED problem statement (owner, #47) is this law applied to agent families; D1 (neutral front door), D2 (shop-minted identity), D4 (adapters) each remove one family coupling |
| Law 6 (`constitution.md`): "never maintains a second copy of anything that can drift" | A per-family copy of the doctrine; a per-family producer; a parallel onboarding surface beside doc-map's reading paths | ONE doctrine body with per-family POINTER files (D1); ONE producer with per-runtime intake adapters (D4); the onboarding path EXTENDS `docs/doc-map.md`'s contributor path rather than duplicating it (D1) |
| Law 1 (`constitution.md`): truth on every surface | Claiming a family "works" unprobed; an adapter guessing identity when it cannot derive one | §2c gates every per-family "works" claim on a probe; D2 makes identity carried, never derived, so there is nothing to guess |
| Law 4 (`constitution.md`): nothing silently lost | A dispatch from an unrecognised runtime dropping no record | D4: the intake path mints a degraded-but-honest record (`subject_basis` disclosed, `envelope: absent`) before it ever skips; every skip is a stderr line |
| Carrier rule (`CLAUDE.md`): "obligations cross rungs in documents with IDs, never by memory" | Dispatch identity reconstructed from runtime internals after the fact | D2 is this rule applied to a NEW boundary: identity crosses the runtime in the carriers the shop already controls (brief out, envelope back), never scraped from payloads |
| Adapter doctrine (glossary, design rev 5 / #1): "health travels inside an adapter's return value, never beside it"; adapters own facts, one seam | A runtime integration whose failure mode is silence; N bespoke integrations with no shared contract | D4: each runtime intake is an adapter behind the producer's one seam, returning records-or-named-degradation; the contract (D3) is what makes a third family cheap |
| `schema/vectors/README.md` (the proven executable-spec pattern) | Inventing a new conformance mechanism; pinning contract semantics in prose | D3 reuses the pattern verbatim: declarative fixtures, per-language runner contract, OBSERVED vs DESIGN-MANDATED provenance |
| Healing Loop: "a structural impossibility beats them all" | Guarding identity collisions with review vigilance | D2: identity minted once by the dispatcher CANNOT collide with runtime internals because no runtime internal participates in it; uniqueness is enforced where the mint happens (one namespace, one owner) |
| Rewrite-vs-extend (`CLAUDE.md`) | Rewriting `Produce-Artifact.ps1` or `Land-Verdict.ps1` because the POV changed | Both are EXTENDED: the producer's intake grows an adapter seam; the extractor stays the one home (`scripts/lib/TranscriptRead.ps1` per the superseded design's D5, which survives) |
| Right-sizing + NIRTS (`CLAUDE.md`) | A runtime-abstraction framework; adapters for families not in use | Two adapters (the families in actual use); the CONTRACT is family-agnostic, the adapter count is demand-driven |
| Fail-closed preToolUse (probed, `docs/setup.md`) | Wiring anything StarCar to preToolUse on any runtime | Nothing here touches preToolUse |
| Onboarding fold (owner-approved counter-proposal, 2026-07-24, friction log 5b21bfd) | Onboarding as a parallel ritual; corpus-reading cars; an every-session re-read | D1: onboarding is the front door's CONTENT, conductor/session-tier, trigger-gated (new family / new identity / post-compaction); cars stay brief-bound |

## §2 - Premises

| # | Premise | If false |
|---|---|---|
| P1 | Every runtime in scope lets the conductor pass an operator-chosen label with each dispatch and returns it (or lets the brief carry it) - so shop-minted identity can round-trip without scraping runtime internals | D2 falls back to the brief/envelope carrier alone (the envelope's task-id already round-trips today - proven by three verdict landings this session); the hook-side record then joins on the envelope, later, instead of at stop |
| P2 | Each runtime family exposes SOME session-start surface (custom instruction, settings, config convention) that can carry one pointer line to the front door | The front door still works for any agent a human points at it (the stranger test's floor); per-family auto-load is enrichment, not foundation |
| P3 | The families in actual use remain two (Claude Code, Copilot CLI); a third arrives eventually | D4 ships two adapters; D3's contract is what a third conforms to - the design survives P3 either way by construction (NIRTS) |
| P4 | The compat-layer facts probed under the superseded design hold (compat executes `sh script.sh` hooks, translates to snake_case, `Task` maps to `Agent`) - inherited evidence, `.claude/probe-logs/` | The Copilot adapter's intake changes shape; D3's vectors red BY NAME and the adapter is re-derived; the contract and every other decision stand |
| P5 | The doctrine can be pointed to from a neutral home without breaking the runtimes that auto-load `CLAUDE.md` today | If a runtime demands its family file carry full content, that family's pointer file carries a generated copy WITH a generation marker (the Law-6 cost is paid visibly, machine-maintained, like AGENTS.md's gitnexus blocks) - a disclosed fallback, not the plan |

## §2c - Probe list (what the desk cannot prove)

| Claim | Why unverifiable from the desk | What would settle it | Blocking? |
|---|---|---|---|
| P1 for Copilot: the dispatch tool's `name` argument is operator-controlled and lands verbatim in hook payload + events (`tool_input.name`, `execution_start.arguments.name`) | Observed 3/3 this session, but only with conductor-chosen unique names; never probed with a deliberate duplicate | One dispatch pair with an intentionally reused name; observe both payloads - settles whether the mint's uniqueness discipline is the ONLY guard (expected) or the runtime dedups | Yes - for D2's Copilot adapter |
| P1 for Claude Code: the Task tool's dispatch carries an operator label the stop payload or transcript returns | No Claude Code session available from this desk | First Claude session after landing: dispatch one car with a shop-minted id; observe `agent_id`/payload | Yes - for closing #47; not for build (the envelope carrier works today on both, proven) |
| P2 per family: Copilot auto-loads `.github/copilot-instructions.md`; Claude auto-loads `CLAUDE.md`; each can carry the pointer | Copilot's load set observed indirectly (this session runs under it); never deliberately minimised | One session with the pointer-only file; confirm doctrine reachable | No - D1 works with a human-pointed front door as the floor |
| The intersection-dialect SessionStart lines execute under both runtimes (inherited §2c row, still open) | Session-cached config; no Claude session | Next restart of each | Yes - for the guards' port, unchanged from the superseded design (the finding survives; the POV around it changed) |

## §3 - The problem (ratified statement, owner 2026-07-24, #47)

**Outcome:** the repo bounces between agent families with zero friction - any agent finds
the doctrine, operates the process, and its work lands in the store, regardless of family.

**Problem:** today both the front door (doctrine discovery) and the harness (identity,
records, hooks) are defined in one family's vocabulary, so every other family arrives as
a stranger. Law 7 violation. The superseded design attacked the wrong form of this: it
took one family's wiring as the substrate and asked how to adapt the OTHER family to it,
which put the design in the business of reconstructing one runtime's identity notions
from another runtime's internals - three REJECT rounds of sinking join-key defects
(DR-4, DR-6) that no revision could fix because the premise manufactured them.

**Acceptance:** the stranger test - a cold agent from an unseen family can read one doc,
know what to read next and why, comply with the contract, and have its work land in the
store.

## §4 - Decisions

| # | Decision | Reason | Constraint/premise |
|---|---|---|---|
| D1 | **Neutral front door = the onboarding protocol.** One runtime-neutral entry document owns arrival: what StarCar is, the tiered reading path (Tier 1 mandatory: constitution → healing loop → CLAUDE.md statute index → glossary → setup → doc-map; Tier 2 role-triggered: rung templates + contracts touched; Tier 3 archaeology on demand: verdicts, retros), and the compliance floor (envelope mandate, carrier rule, never-push, honest stop). Per-family files (`CLAUDE.md`, `.github/copilot-instructions.md`, a future family's equivalent) become one-pointer-line surfaces over time - EXISTING content migrates only when touched, never big-bang. Onboarding is conductor/session-tier, trigger-gated (new family / new agent identity / resume-after-compaction); cars stay brief-bound. HOME: a new `ONBOARDING.md` at repo root - NOT `AGENTS.md`, which is GitNexus-owned (doc-map: "tool-maintained, not hand-herded"; writing there hand-herds a machine surface) | The onboarding fold (owner-approved); Law 7 (the front door IS the stranger's first surface); Law 6 (one doctrine body, pointers not copies); doc-map's contributor path is the prior art this extends | Law 6, Law 7, P2, P5 |
| D2 | **Dispatch identity is minted by the shop, carried by carriers, never scraped.** The conductor mints a unique dispatch id at dispatch time (convention: `<ticket>-<role>-r<round>`, e.g. `47-design-review-r3`; uniqueness is the dispatcher's discipline, enforced at the ONE place minting happens). The id travels OUT in the carriers the shop already owns - the runtime's dispatch label where P1 holds, and ALWAYS the brief (which mandates the envelope echo it back as `task-id`). It travels BACK in the envelope. The store record's `subject` IS the minted id. Runtime-internal ids (toolCallIds, agent session ids) may be RECORDED as provenance enrichment when an adapter can see them cheaply; they are never identity | This is the carrier rule pointed at a new boundary, and it structurally dissolves the superseded design's entire defect family: DR-4 (no subject in the payload - irrelevant, the subject is in the brief), DR-6 (name collisions - the mint owns uniqueness; no runtime internal participates). The store contract already keys by `subject` and never demanded runtime provenance (round-1 reviewer: StoreIntegrity has no pairing assertion; the schema is open) | Carrier rule, Healing Loop (structural beats vigilance), Law 1, P1 |
| D3 | **The adapter contract is executable: `schema/vectors/adapter/` conformance fixtures** in the proven vector pattern (declarative input → expected records; OBSERVED vs DESIGN-MANDATED provenance; per-language runner contract). The contract pins: given a dispatch-start event carrying minted id X, a conforming adapter yields a `dispatched` record with `subject: X`; given a stop event whose report envelope carries `task-id: X`, a `returned` record with `subject: X`, outcome from the envelope; given a stop with NO envelope, a `returned` record with `envelope: absent` + fault line; given an unrecognisable payload, a visible skip (stderr naming present keys) and NO record. Identity semantics live HERE, not in this prose | §0's split: identity/join/dedup are format; the round-3 reviewer prescribed exactly this instrument; `schema/vectors/README.md` is the worked in-repo pattern (cross-verifier discipline proven at C3R-1) | §0, Law 6 (one authority), the vectors prior art |
| D4 | **Two thin runtime intake adapters behind the producer's one seam.** `Produce-Artifact.ps1` stays the ONE writer; its payload intake becomes a small per-runtime normalisation step (Claude shape; Copilot compat shape) conforming to D3's vectors. Health inside the return value: an adapter that cannot produce a record returns a named degradation (visible skip, fault line), never silence. The superseded design's surviving findings ride here as the Copilot adapter's content: filter tolerance (`agent_type` OR `agent_name`), visible skips, absent-envelope minting at stop, the one extractor home (`scripts/lib/TranscriptRead.ps1`), the probe key fix (`subagent-stop-probe.sh` reading `transcript_path`), the intersection-dialect SessionStart lines | Adapter doctrine (the board's own, applied to the harness); rewrite-vs-extend (the producer is extended at its seam); NIRTS (two adapters, contract makes the third cheap); every probed fact from the superseded design's §3b remains true and lands here | Adapter doctrine, Law 4, Law 6, P3, P4 |
| D5 | **The superseded design's uncontested decisions survive, re-homed, with their finding history.** Carried verbatim into D4's scope: intersection dialect for the four SessionStart guards (one manifest), D6's probe key fix, D5's one-extractor home, the `sh -c` entire wrappers as pinned noise (round-2 reviewer ruling). Dropped: the events.jsonl three-hop identity join (DR-6's subject dies with the scraping premise - runtime ids are optional provenance now, and DR-7's live-file read hazard shrinks to an enrichment-path concern, disclosed in D3's absent-envelope vector) | Three rounds of reviewer work product is evidence, not waste; what died was the POV, not the probes. Findings that survive the reframe are carried with their IDs so the round-4 reviewer can verify nothing was laundered | Carrier rule, GUIDE STAR (the record stays) |

## §5 - Mechanism

1. **`ONBOARDING.md`** (D1): the front door. Tiered reading path, compliance floor,
   per-family arrival notes (one line each: where this family's pointer file lives).
   `docs/doc-map.md` gains its row (USER/SYSTEM boundary surface, LIVING);
   `README.md`'s reading-order section points at it.
2. **Per-family pointer lines** (D1): `.github/copilot-instructions.md` created carrying
   the pointer; `CLAUDE.md` gains a pointer line at its top (content otherwise
   untouched - migration is trigger-gated, never big-bang).
3. **`schema/vectors/adapter/`** (D3): the conformance fixtures + a README in the
   vectors-README shape (runner contract, provenance rule). Red-first: the Copilot
   no-envelope-at-stop vector and the unrecognisable-payload vector land RED against
   today's producer and drive D4.
4. **`Produce-Artifact.ps1`** (D2+D4): intake adapter seam (per-runtime normalisation to
   ONE internal payload shape), subject from the minted id (dispatch label where
   present, envelope `task-id` at return), filter tolerance + visible skips,
   absent-envelope minting, runtime ids recorded as optional `provenance` enrichment.
5. **`scripts/lib/TranscriptRead.ps1`** (D5): the one extractor, events.jsonl branch,
   consumed by producer and `Land-Verdict.ps1`.
6. **`.claude/settings.json`** (D5): four SessionStart lines to intersection dialect;
   `subagent-stop-probe.sh` key fix.
7. **Templates** (D2): `docs/templates/car-brief.md` + `.claude/agents/car.md` envelope
   mandate gains the `task-id` echo line (the id the brief carries comes back in the
   envelope - one sentence each).
8. **`docs/setup.md`**: runtime-status rows corrected (the superseded design's §5.6
   obligation survives verbatim); onboarding trigger rows added.

## §6 - Failure modes

| Failure | Behaviour | Law |
|---|---|---|
| Conductor mints a duplicate id | The store shows two records sharing a subject with conflicting lifecycles; the fold's supersession exposes both (never merges silently); the mint convention (`ticket-role-round`) makes duplicates a discipline failure VISIBLE at the store, and D3's vectors pin the exposure behaviour | Law 4, Law 1 |
| A runtime never returns the dispatch label (P1 false for that family) | The envelope carrier alone joins (task-id in the brief, echoed back); the `dispatched` record still mints at launch with the minted id from the label if present, else the adapter discloses `subject_basis: envelope-pending` | Law 1 |
| A report arrives with no envelope | `returned` mints with `envelope: absent` + fault line naming the backfill command (`Land-Verdict.ps1`) - inherited from the superseded design, unchanged | Law 4 |
| An unknown family's payload arrives | Visible skip: stderr names the keys present, no record, no guess | Law 1 |
| A family's pointer surface is not auto-loaded (P2 false) | The front door still works human-pointed; the stranger test never depended on auto-load | Law 7 |
| The doctrine and a family pointer file drift (P5 fallback in use) | The generated copy carries its generation marker; the generator is the one writer; staleness is the doc-policy gate's existing class | Law 6 |
| Onboarding ritual goes autoimmune (every-session re-reads) | The trigger list is closed (new family / new identity / post-compaction); the session-start retro's dedup check owns watching it | Right-sizing |

## §7 - Out of scope

- Entire mirroring (working, dual-wired already).
- Automatic post-read envelope enrichment (triggers unchanged from the superseded design).
- A third adapter (D3's contract is the preparation; NIRTS gates the build).
- Big-bang migration of `CLAUDE.md` content into the neutral home (trigger: each section
  moves when next touched, or an owner ruling orders a batch).
- The board/product side (already family-agnostic by construction).

## §8 - Contracts touched

| Contract | Change | Owner |
|---|---|---|
| `docs/doc-map.md` | ONBOARDING.md row; reading-path cross-reference | the car |
| `docs/setup.md` | runtime rows corrected; onboarding triggers | the car |
| `docs/templates/car-brief.md` + `.claude/agents/car.md` | task-id echo line in the envelope mandate | the car |
| Spec #7 (producer) | amendment block: adapter seam, subject-from-mint, provenance enrichment | the car |
| `README.md` | reading order points at the front door | the car |
| State ledger | no mutable service state touched - reviewer verifies | reviewer |
| `docs/glossary.md` | "Adapter" gains the harness sense; "mint"/"subject" clarified | the car |

## §9 - Cost

1 design review (round 1 of THIS design; the round counter resets with the restart, and
per rotation doctrine the reviewer is FRESH - the prior reviewer's transcript is at
rotation-trigger size and this is a new document) + 1 spec-tier executable artifact
(D3's vectors, part of the car's work, red-first) + 1 car + 1 adversarial review =
**3 dispatches**, Opus-class, medium. Blocking probes: §2c rows 1 (conductor-run, one
dispatch pair) and 4 (owner restart). Owner approval recorded before car dispatch.

## §9b - Disposition of the superseded design's carried findings

| Prior item | Kind | Disposition | Where |
|---|---|---|---|
| DR-1..5 folds (verified ABSENT by rounds 2-3) | findings | inherited as settled evidence; the probed substrate facts (§3b of the superseded design) remain true and D4 consumes them | D4, P4 |
| DR-6 (MAJOR, round 3): name-space join key non-unique; detector + board collapse by subject | finding | **dissolved structurally, not patched**: identity is no longer derived from any runtime name-space - the mint owns uniqueness, the store's subject IS the minted id, and runtime ids are optional provenance. The collision the reviewer constructed (5 toolCallIds, one name) cannot reach the store because `arguments.name` no longer participates in identity. The detector/board pairing concern is now pinned by D3's vectors instead of prose | D2, D3 |
| DR-7 (MINOR, round 3): live events.jsonl read discipline unstated | finding | shrunk by the reframe (the stop path no longer REQUIRES an events.jsonl read for identity) but not dismissed: the extractor's enrichment path still reads a live file, and D3's absent-envelope vector plus the runner contract state the torn-line discipline (skip unparseable trailing line, never throw) | D3, D4 |
| Round-3 convergence ruling: pull the identity model into an executable spec before round 4 | ruling | adopted as §0's split and D3 | §0, D3 |
| Round-3 §10 rulings (Q1: join blocking for D7 landing; Q2: the detector pairs by subject) | rulings | Q1 mooted (no join to block on); Q2 adopted - the detector is named as a pairing consumer and D3's vectors are its guard | D2, D3 |

## §10 - Open questions for the reviewer

1. **D1's home** (`ONBOARDING.md` at root): right call versus `docs/onboarding.md`?
   Root maximises stranger visibility; docs/ keeps root minimal. The design says root
   (front doors belong at the front).
2. **D2's mint convention** (`ticket-role-round`): sufficient as a discipline, or does
   the round-1 reviewer see a case for a mechanical uniqueness guard at mint time
   (e.g., the producer refusing a `dispatched` subject that already has an
   un-superseded `dispatched` record)?
3. **D5 drops the three-hop events.jsonl identity join.** Is any surviving consumer
   harmed by runtime ids becoming optional provenance rather than identity?
