# Ops script patterns - session-start, run-suites, watch-ci/publish, sanitized

Status: Current

Provenance: the ancestor's literal scripts are stack-specific (.NET/PowerShell) and not
portable; these are the PATTERNS they encode, each earned by a named failure. Build the
TypeScript-native equivalents when setup.md's triggers fire - from these shapes, not
from scratch.

## 1. session-start (environment bootstrap hook)

Only needed for ephemeral environments (web containers/CI); local boxes manage
themselves - the ancestor's script exits immediately unless it detects the remote env.
The three disciplines:

```sh
#!/bin/bash
set -euo pipefail
[ "${REMOTE_ENV:-}" != "true" ] && exit 0   # local boxes: no-op

# 1. IDEMPOTENT: every install checks before acting - the hook runs every session.
if [ ! -x "$HOME/.tool/bin/tool" ]; then curl ... ; fi

# 2. WRAPPER-ON-PATH, not profile edits: env vars baked into a wrapper script so
#    every later process gets them without shell-profile mutation.
printf '#!/bin/sh\nexport TOOL_ROOT="%s"\nexec "%s/tool" "$@"\n' ... > /usr/local/bin/tool

# 3. STRICTLY NON-FATAL for optional tooling: guard so an optional-tool hiccup can
#    never abort the rest of setup under set -e. Say what degraded, keep going.
if install_index_tool; then echo "[start] index ready"; else echo "[start] index failed (non-fatal) - tools limited"; fi
```

Scar behind #3: a cold-start race in an optional indexer aborted whole container
setups until it was guarded; the retry-once-with-force line exists because the first
interrupted attempt leaves a flag the retry must clear.

## 2. run-suites (the aggregate test runner)

One table of suite definitions is the single source of truth; the runner iterates it.

```
SUITES = [
  { name, projectPath, filter?, timeoutSec, expectedFloor? },
  ...
]
```

Disciplines, each with its scar:
- **A suite missing from the table is invisible to every aggregate run** - the ancestor
  shipped a 162-test suite the runner did not know existed; a harness-retro question
  now standing-checks "does the runner execute every test project that exists?"
- **Per-suite timeout + a filter slot**: one hanging dev-rig-only test once wedged bare
  runs for 40+ minutes; the fix was BOTH a filter in the table AND an env-gated skip at
  the test itself (belt and suspenders - the table protects runner users, the gate
  protects everyone else).
- **PASS/WARN/FAIL summary line per suite, exact counts** - "green" without counts hides
  a suite that silently ran 0 tests.
- Unit-test the runner's pure logic (table parsing, filter/timeout selection) with the
  test framework; the process-spawning shell is smoke-tested + documented, not mocked.

## 3. watch-ci / publish (the dispatch-watch-confirm shape)

The publish scar, verbatim shape: the release workflow builds from the REMOTE, so
triggering before pushing silently builds a stale commit. The script therefore:

1. **REFUSES to trigger unless local HEAD == origin/<branch>** (fetch first, compare).
2. Dispatches the workflow, then WAITS for the dispatched run to appear (dispatch is
   async; grab the run id, don't assume).
3. **Watches to completion** - never "triggered, probably fine."
4. **Confirms the built SHA equals the intended SHA** in the run's own output - the
   end-to-end proof, not an inference.

watch-ci is the same shape minus the trigger: poll named workflows for a specific SHA,
report conclusion transitions, and treat "no run appeared for this ref" as its own
honest outcome (paths-ignore? not pushed?) rather than success. Companion rule: after
autonomous pushes, WAIT for CI before declaring anything "verified" - a local green
proves the local environment only.

Keep decision logic (push-parity check, run selection, SHA match) in a pure module with
unit tests; the CLI wrapper stays thin.
