# Tooling setup - what is installed, what installs later, and what triggers it

Status: Current

An agent opening this repo on the founding box starts with everything below in the
"ready now" state. Items in "installs later" have explicit triggers - install them WHEN
the trigger fires, not before (right-sizing: tooling earns its place like everything
else).

## Ready now (committed in-repo)

| Thing | Where | Notes |
|---|---|---|
| Process seed | `CLAUDE.md` | The operating rules, scars attached |
| Constitution | `docs/constitution.md` | RATIFIED 2026-07-21, before any code |
| Healing Loop | `docs/the-healing-loop.md` | The process metabolism |
| `car` agent type | `.claude/agents/car.md` | No-delegation implementer/reviewer (toolset-enforced) |
| `/goodnight` skill | `.claude/skills/goodnight/` | Session-end ritual + resume packets |
| Resume-packet hook | `.claude/hooks/goodnight-resume-check.sh` | SessionStart announce, wired in `.claude/settings.json` |
| Board tooling | `scripts/board.ps1` + `Board.psm1` (+ Pester tests) | Defaults: user project 6, repo polecatspeaks/StarCar; pure logic Pester-tested |
| Templates | `docs/templates/` | Car brief, state ledger, gating matrix, **design doc** |
| **Ported prior art** | `docs/templates/worked-*.md`, `design-briefs.md`, `ops-script-patterns.md` | **Worked exemplars from the ancestor shop, sanitized.** Briefs (implementer, reviewer, fix cycle); design-rung briefs (reviewer, DELTA re-review, design car); a worked spec; a worked plan with its five-dimension review record; filled ledger and gating rows; and ops-script PATTERNS. The rules travelled with the seed; these are the exemplars, and **rules without exemplars do not bind**. Read the worked file before writing any document at that rung. |
| Verdict landing | `scripts/Land-Verdict.ps1` + `Verify-Verdict.ps1` | Extracts a dispatched agent's verdict VERBATIM from a transcript by task id and stamps a body SHA-256; the verifier recomputes it. Never retype a verdict by hand - the author being reviewed is the one landing the review. **Now backfill-only (harness #7 landed, Car 2):** the producer hook (`scripts/Produce-Artifact.ps1`) is the primary path that records dispatches automatically; `Land-Verdict.ps1` survives as the manual BACKFILL path, used precisely when no hook fired, and `-TranscriptPath` is now MANDATORY - the live-transcript auto-derivation is retired (spec #7 S4 row 1; MARKED deviation C2R2-m1: the deriver was DELETED rather than repointed to the git root, because the hook now supplies the path). Migrating `docs/reviews/` into the single artifact store remains Car 3's. *(This row is spec #7 S9 Car 3's; Car 2 updates it early as MARKED deviation C2R1-m2, because Car 2's `Land-Verdict` change already invalidated the old "in adversarial review" note and the living-documents rule forbids leaving it stale.)* |
| Landed verdicts | `docs/reviews/` | Every gate verdict, verbatim and hash-verified (count deliberately not stated - a hardcoded number in a `Status: Current` document is a defect generator, and this one went stale twice in one morning) (`Verify-Verdict.ps1`, also run by CI). The harness design proposes retiring this directory in favour of a single artifact store; until that lands, this is where verdicts live. |
| MCP: context7 | `.mcp.json` | Library docs lookup, stack-agnostic |
| MCP: gitnexus | `.mcp.json` | Server registered; serves nothing until first index (below) |
| pr-review-toolkit plugin | `.claude/settings.json` | Enabled |
| Branch protection on `main` | GitHub repo settings (remote) | Require PR, 0 approvals, no force-push, no deletion, **`enforce_admins: true`**. The mechanical half of the STANDING ORDER in `CLAUDE.md`. Admins are NOT exempt, deliberately: agents authenticate with the owner's credential, so an admin exemption exempts every agent - proven by fault injection on founding day (see the STANDING ORDER corollary in `CLAUDE.md` and PR #5). The owner's override is the settings page, which no configuration takes away; Law 2 protects the owner's authority, not the token's privileges. |
| `dev` integration branch | remote + local | Work integrates here; car branches cut from and merge back to `dev`; `dev` reaches `main` by PR only |

Also available from the box/user level (nothing to install per-repo): the superpowers
plugin (brainstorming, writing-plans, TDD skills), the Claude-in-Chrome browser tools.

## Installs later - trigger-gated

| Thing | Trigger | How |
|---|---|---|
| GitNexus index | FIRST CODE lands (nothing to index before that) | `npx gitnexus analyze` (or `npm i -g gitnexus` then `gitnexus analyze`); rerun with `--pdg` once the codebase is worth statement-level analysis. The MCP server in `.mcp.json` starts serving as soon as the index exists. |
| CI workflows | First workflow need (likely: first code PR) | Port the docs `Status:` line checker + a build/test workflow; keep the "verified means CI went green" rule from CLAUDE.md in force from day one. Three guards are parked here and should land with it: an area-label presence check (#3), a check that PRs touching `docs/` were reviewed (#4), and **the quickstart runner** - CI executes the README's documented commands on a clean runner so a broken documented path turns the build red (#6). The quickstart runner is deliberately backed up *further* than the rest of this row (owner decision, founding day): while the project moves fast and breaks things there is no stable quickstart to assert, and an instrument re-asserting yesterday's README cries wolf. Until it lands, user-facing documentation is gated at the PR by SENTENCE CHECK - the reviewer traces each claim from prose to command to code to observed behavior, file:line at every hop (see the NORTH STAR in `CLAUDE.md`, the reviewer duties in `.claude/agents/car.md`, and the DOC SENTENCE CHECK line in the car-brief template). That is attention-tier where CI would be mechanical, which is a real downgrade and is recorded as one. All three guards are prose-only today. The repo-policy half of this row shipped early (see branch protection above); its trigger fired on founding day when the STANDING ORDER was issued. |
| ~~Spec-rung artifact~~ | ~~first spec~~ | **SUPERSEDED - the prior art was ported.** `docs/templates/worked-spec.md` is the exemplar: section inventory, the mandatory lifecycle table, the RETIREMENT LIST, the PROBE LIST for what the desk cannot prove, and a review record that stays in the spec forever. Use it directly; a separate form-template is only worth writing if the worked file proves insufficient. This row previously said "build from wreckage" - written under the wrong diagnosis, before anyone asked whether prior art existed. |
| ~~Plan-rung artifact~~ | ~~first plan~~ | **SUPERSEDED - same.** `docs/templates/worked-plan.md` carries the stitches for the scar this repo inherited: the binding amendment block, per-task Consumes/Produces with real file:line verified at base, the five-step task shape with full code rather than "implement the function", the spec-coverage table, and the five-dimension plan review whose sentence-check-every-snippet dimension is exactly what caught the ancestor's three-round plan. Also carries `APPROVE-WITH-REBASE-LIST` - a verdict shape we lacked, for when every defect is mechanical. |
| Session-start env hook | The repo is opened in a web/container environment | **Pattern now ported** - `docs/templates/ops-script-patterns.md` §1: exits immediately unless the remote env is detected, idempotent installs, wrapper-on-PATH rather than profile edits, strictly non-fatal for optional tooling. Build the TypeScript-native equivalent from that shape, not from scratch. |
| Suite runner | First multi-suite need | **Pattern now ported** - `ops-script-patterns.md` §2: one suite table as the single source of truth (a suite missing from the table is invisible to every aggregate run - the ancestor shipped a 162-test suite the runner did not know existed), per-suite timeout and filter, PASS/WARN/FAIL with exact counts because "green" without counts hides a suite that ran zero tests. Not needed yet: CI globs `scripts/tests` and already fails a zero-test run. |
| CI watcher / publish | First release channel, or the first time CI is triggered rather than pushed | **Pattern now ported** - `ops-script-patterns.md` §3: REFUSE to trigger unless local HEAD equals origin, wait for the dispatched run to appear rather than assuming, watch to completion, and confirm the BUILT sha equals the intended sha. Directly relevant already: CI has been checked by hand all session. |
| Probe suite in CI | Car 3's `ci.yml` touch (the migration commit) | Wire `Invoke-Pester -Path ./scripts/probes` as a substrate-floor step BEFORE the test suite, with the zero-test refusal pattern. Tracked as #10; suite already landed and proven both directions. |
| Tier-2 dispatch enumeration | A dispatch-enumerable second source proven by probe (candidate: Task dispatch records parsed from checkpoint-branch transcripts - real but heavy) | Its own rider AFTER Car 3, where the CI checkpoint-branch fetch (spec #7 [m5]) also lands. Car 2 shipped tier-1 + tier EXPOSURE only (conductor ruling R6v2): the Entire checkpoint branch enumerates CHECKPOINTS keyed to commits, not dispatches, and with no checkpoint-to-subject map, enumerating it today would raise a false gap per commit outside the store - a wolf-crier worse than none (severity philosophy). Until this lands, `scripts/Detect-Dispatches.ps1` reports `tier: tier-1-only` truthfully. |
| ~~Spec §7 probe 2~~ | ~~fired 2026-07-22 at cars 2-3 planning~~ | **ANSWERED: a slow SubagentStop hook BLOCKS the stop path for its full runtime (11.6s vs 2.8s baseline with a 10s sleep). Binding on Car 2's producer. All four §7 probes now answered - `docs/probes/2026-07-22-spec7-probe-results.md`.** |
| CLAUDE.md restructure | A worker misses a rule AND the miss traces to LENGTH (not any miss, not preemptively) | The statute index and the retro's doctrine-dedup check are the growth guards until then. Scars stay attached to their rules (founding principle) - any restructure preserves that. |
| Reviewer-rotation drill | Next multi-round review gate (cars 2-3 train) | Deliberately rotate to a FRESH reviewer mid-series with only the landed verdicts as carriers; agreement proves the verdict template carries everything, divergence is a template finding. See Review calibration in CLAUDE.md. |

## Entire.io session mirroring: ENABLED (owner decision, 2026-07-21)

Every agent-session transcript in this repo publishes to the public checkpoint branch -
by design ("the full monty"): the development process is the showcase, radically
transparent and verifiably real, half-thoughts included. The price of that is the HARD
INVARIANT at the top of CLAUDE.md: StarCar sessions are StarCar-only; nothing from any
other project is ever typed here. `entire enable` + `entire agent add claude-code` are
done (hooks in `.claude/settings.json`, config in `.entire/`); `entire search` is the
entry point for decision archaeology.
