# The documentation map

Status: Current

The navigation layer over this repo's ~42 documentation surfaces. This file MOVES
nothing and renames nothing - it is a map, not a reorganisation (restructuring stays
trigger-gated per `docs/setup.md`; a map that reveals the structure is wrong is evidence
for that trigger, not a licence to fire it early). One classification claim per file;
if a row and reality disagree, reality wins and the row is a defect - fix it in the
commit that finds it.

## The axes

Documents here sort along three axes, not one:

- **Family** - who reads it: SYSTEM (the institution's own operating law), DEV
  (someone building or reviewing this code), USER (a stranger deploying or evaluating
  the product). When audiences conflict, the stranger wins (NORTH STAR, `CLAUDE.md`).
- **Diátaxis quadrant** - tutorial / how-to / reference / explanation, plus this
  shop's house genre Diátaxis does not name: the **WORKED EXEMPLAR** ("rules say what
  is forbidden; exemplars show what compliance looks like" - `CLAUDE.md`, the
  build-from-wreckage section). Exemplars are load-bearing here because every worker
  is a new hire on day one.
- **Living vs FOSSIL** - the axis that matters most in this repo. LIVING documents
  must always be current (the commit that invalidates one updates it, same commit; a
  stale living doc is a lying canary). FOSSILS are records - verdicts, probes, retros,
  friction entries, superseded design revisions - never edited after landing, because
  the rock IS the history. Editing a fossil is falsifying the record; letting a living
  doc rot is publishing a falsehood. Same law, opposite duties.

## SYSTEM family - the institution

| Document | Quadrant | Axis | What it is |
|---|---|---|---|
| `ONBOARDING.md` (repo root) | explanation (front door) | LIVING | The neutral, runtime-neutral entry point - the **USER/SYSTEM boundary**: a stranger's first surface AND the institution's arrival protocol. Owns the tiered reading path (Tier 1 mandatory / Tier 2 role-triggered / Tier 3 archaeology) and the compliance floor. Conductor/session-tier, trigger-gated (new family / new identity / post-compaction); cars stay brief-bound. EXTENDS the reading paths below rather than duplicating them (Law 6); per-family files (`CLAUDE.md`, `.github/copilot-instructions.md`) point here (#47, design D1) |
| `.github/copilot-instructions.md` | reference (pointer) | LIVING | Copilot CLI's auto-load surface: a one-screen POINTER to `ONBOARDING.md` plus the one-line compliance floor, never a second copy of the doctrine (Law 6). The Claude-side equivalent is `CLAUDE.md`'s pointer line at its top (#47, design D1) |
| `CLAUDE.md` | reference + explanation | LIVING | The statutes: every operating rule with its scar attached. Session-loaded; the institution's working memory |
| `docs/constitution.md` | explanation | LIVING (amendment-only) | The seven-plus-one laws; bedrock; the evolution engine's immutable floor |
| `docs/the-healing-loop.md` | explanation | LIVING | How the process improves itself: catches counted, instruments audited, prose demoted below mechanism |
| `docs/setup.md` | reference (trigger ledger) | LIVING | What is installed, what is deliberately deferred, and the trigger that un-defers each |
| `docs/friction-log.md` | record | FOSSIL (append-only) | Raw material for session-start retros; instances logged as they happen |
| `docs/retros/` | record | FOSSIL | Train retros - what a completed train taught, at the time it taught it |
| `docs/templates/` (16 files) | reference + WORKED EXEMPLAR | LIVING | The rung artifacts: brief/design/spec/plan/ledger/matrix templates plus the two `*-patterns` docs, paired where possible with a worked-\* exemplar drawn from real wreckage (nine of those). **This directory is the FIRST stop for the prior-art question** - `CLAUDE.md`'s ASK FOR THE PRIOR ART now checks here before escalating to the owner (owner ruling, 2026-07-24), and points back at THIS row as the owner of the enumeration and the count. The template dedup question belongs to the session-start retro's bounded check `[DM-1, fixed: the map's first committed count was 15, from memory; ls says 16 - the map's own reality-wins rule applied to itself one review later]` |
| `.claude/agents/car.md` | reference | LIVING | The car agent definition - the toolset that structurally enforces no-nested-delegation |
| `docs/doc-map.md` (this file) | reference (navigation) | LIVING | The map itself - a documentation surface like any other, subject to its own reality-wins rule |
| `docs/glossary.md` | reference (vocabulary) | LIVING | The human-readable vocab sheet: house phrases, rail metaphor, store/fold terms, process terms - one or two sentences each, HAVAGLANCE-honored |

## DEV family - building and reviewing this code

| Document | Quadrant | Axis | What it is |
|---|---|---|---|
| `docs/design/*` | explanation | LIVING while its train runs; FOSSIL revisions in git history | Rung-1 artifacts. The current board design (`2026-07-21-v0-yard-skeleton-design.md` rev 5, APPROVED) is live contract; superseded revs stay readable in history |
| `docs/specs/*` | reference (requirements) | LIVING while binding; amendment blocks, never rewrites | Rung-2. The board spec (rev 2, APPROVED) binds Cars 1-5 now |
| `docs/plans/*` | reference (task contracts) | LIVING while its train runs | Rung-3. State lines carry per-car progress; briefs are cut from these |
| `docs/contracts/gating-matrix.md` | reference | LIVING | Every gated truth surface: fires-when / suppressed-when / evidence. Reviewers reject diffs that leave it stale |
| `docs/contracts/state-ledger.md` | reference | LIVING | Every piece of mutable service state, old → delta → new |
| `docs/probes/*` | record (measurements) | FOSSIL | Landed observations with coordinates; each layer's landed probes are the next layer's headers |
| `artifacts/reviews/*` | record (verdicts) | FOSSIL (hash-sealed) | Every adversarial verdict, verbatim, integrity-hashed; the process's primary source |
| `artifacts/index.md` | reference (derived) | LIVING (regenerated; gated at PR-to-main and push-to-main per #20) | The browsable store ledger; the JSON records are the source of truth |
| `schema/index-format.md` | reference | LIVING | The index contract: columns, sort, normalisation, the verbatim-`at` integrity rule |
| `schema/vectors/README.md` | reference | LIVING | The fold conformance-vector contract: shape, runner rules, provenance discipline |
| `board/web/vendor/*/VENDOR.md` | reference | LIVING | Vendored-dependency provenance: version, shasum, licence |
| `AGENTS.md` | reference (generated) | tool-maintained | GitNexus surface; not hand-herded |

## USER family - the stranger

| Document | Quadrant | Axis | What it is |
|---|---|---|---|
| `README.md` | explanation + how-to | LIVING | Honest by construction: describes only what exists. **Landed 2026-07-23 (Car 5, plan section 6, task 5.4):** the Quickstart section replaces the "no quickstart" line in the same commit that made it false - `git clone` + `cd board && go run ./server`, verified from a clean clone (root/`/api/snapshot`/`/js/app.js` all 200, snapshot validates against the wire schema) |
| `README.md#quickstart` | tutorial | LIVING | The stranger's runnable path - now inline in `README.md` rather than a separate scheduled document; folded here rather than as its own row since it lives in the same file and the same LIVING contract governs it |
| *(trigger-gated)* adapter-authoring guide | how-to | trigger: the second adapter | Deferred until there are two adapters to generalise from |
| *(trigger-gated)* contributor how-to | how-to | trigger: first external contributor | Until then, `docs/setup.md` + `CLAUDE.md` carry it for the workforce that actually exists |

## Three reading paths

The neutral front door, `ONBOARDING.md` (repo root), sits UPSTREAM of all three paths: it
carries the tiered reading path and the compliance floor for any agent family, then hands off
to the path that fits the reader's role. The three paths below are those hand-offs, unchanged;
the front door names them rather than replacing them (#47, design D1).

**The stranger's path** (evaluate or deploy, zero context):
`README.md` → `docs/constitution.md` → one landed REJECT verdict in `artifacts/reviews/`
(pick any - the point is that the gates are real) → the board itself once it serves.

**The contributor's path** (do a piece of work here):
`docs/setup.md` → `CLAUDE.md` (the statute index first, then the sections your work
touches) → the current train's design/spec/plan → `docs/templates/car-brief.md` and the
worked exemplars for your rung → the contracts your diff must keep true
(`docs/contracts/`).

**The process student's path** (learn the method, run nothing):
`docs/constitution.md` → `docs/the-healing-loop.md` → the dispatch-harness saga IN
ORDER: `docs/design/2026-07-22-dispatch-harness-design.md`, its five REJECT verdicts in
`artifacts/reviews/` (rounds 1-5), the spec's four rounds, then
`docs/retros/2026-07-22-harness-train-retro.md` - the REJECTs are the curriculum, not
the blemishes → `docs/friction-log.md` for the texture of what it costs day to day.

## What this map deliberately does not do

No files moved, no renames, no per-file family headers added (the classification lives
here, in one place, rather than as ceremony in forty). The template-set dedup question
stays with the session-start retro. Restructuring stays behind its trigger. If this map
itself rots, the doc-policy gate will not catch it - only a reader following a dead row
will - so every row edit belongs in the commit that invalidates it, same as any living
document.
