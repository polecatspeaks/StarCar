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
| Templates | `docs/templates/` | Car brief, state ledger, gating matrix |
| MCP: context7 | `.mcp.json` | Library docs lookup, stack-agnostic |
| MCP: gitnexus | `.mcp.json` | Server registered; serves nothing until first index (below) |
| pr-review-toolkit plugin | `.claude/settings.json` | Enabled |
| Branch protection on `main` | GitHub repo settings (remote) | Require PR, 0 approvals, no force-push, no deletion, admins exempt. The mechanical half of the STANDING ORDER in `CLAUDE.md`; admins stay exempt so the owner can always override (Law 2). |
| `dev` integration branch | remote + local | Work integrates here; car branches cut from and merge back to `dev`; `dev` reaches `main` by PR only |

Also available from the box/user level (nothing to install per-repo): the superpowers
plugin (brainstorming, writing-plans, TDD skills), the Claude-in-Chrome browser tools.

## Installs later - trigger-gated

| Thing | Trigger | How |
|---|---|---|
| GitNexus index | FIRST CODE lands (nothing to index before that) | `npx gitnexus analyze` (or `npm i -g gitnexus` then `gitnexus analyze`); rerun with `--pdg` once the codebase is worth statement-level analysis. The MCP server in `.mcp.json` starts serving as soon as the index exists. |
| CI workflows | First workflow need (likely: first code PR) | Port the docs `Status:` line checker + a build/test workflow; keep the "verified means CI went green" rule from CLAUDE.md in force from day one. Three guards are parked here and should land with it: an area-label presence check (#3), a check that PRs touching `docs/` were reviewed (#4), and **the quickstart runner** - CI executes the README's documented commands on a clean runner so a broken documented path turns the build red (#6). All three are prose-only today. The repo-policy half of this row shipped early (see branch protection above); its trigger fired on founding day when the STANDING ORDER was issued. |
| Session-start env hook | The repo is opened in a web/container environment | Port the ancestor's `session-start.sh` PATTERN (idempotent installs, strictly non-fatal guards, wrapper-on-PATH) with THIS stack's tools - the ancestor's dotnet/pwsh specifics do not apply |
| Suite runner / CI watcher scripts | First test suite / first CI | Generalize from the ancestor shop's `run-suites` / `watch-ci` patterns when there is something to run |

## Entire.io session mirroring: ENABLED (owner decision, 2026-07-21)

Every agent-session transcript in this repo publishes to the public checkpoint branch -
by design ("the full monty"): the development process is the showcase, radically
transparent and verifiably real, half-thoughts included. The price of that is the HARD
INVARIANT at the top of CLAUDE.md: StarCar sessions are StarCar-only; nothing from any
other project is ever typed here. `entire enable` + `entire agent add claude-code` are
done (hooks in `.claude/settings.json`, config in `.entire/`); `entire search` is the
entry point for decision archaeology.
