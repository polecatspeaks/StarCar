Status: Current

# Dispatch harness - Car 3 implementation plan, rev 1 (migration, CI gates, portability leg)

REQUIRED SUB-SKILL: one car per task group, adversarial reviewer per car.

Source of truth: spec (+S1), design (+A1), `docs/probes/2026-07-22-spec7-probe-results.md`
(probes 1-5 + the live-latency addendum). Prior cars landed: schema substrate (Car 1),
the recorder (Car 2, live and self-recording since `8c983a1`). Scope accumulated for
this car by trigger: #10 (probes in CI), #14 (ubuntu matrix leg), #15 (latency split
measurement), spec [m5] (checkpoint-branch fetch), spec §4 rows 4-5 + §9 rows (the
migration commit and its mirrors).

**Scope: Car 3 on SONNET** (owner topology: mechanical car - migration, CI wiring,
measurement; the probe data says Sonnet is reliable under precise briefs, and this brief
is precise). Reviewer on Opus.

Compliance: `worked-plan.md` Amendment 1 + conditions rule. Baselines pin invariants;
counts float.

> # BINDING AMENDMENT BLOCK (conductor-applied)
> *Empty at rev 1. The car reads this block FIRST; entries supersede contradicting text.*

## Base, baselines, STOP rule

Base: the commit that lands this plan approved. Car re-derives under pwsh 7, STOP on
failure (never on a floated count): `Invoke-Pester -Path ./scripts/tests` **74 passing,
0 failed**; `Invoke-Pester -Path ./scripts/probes` **8 passing, 0 failed**;
`./scripts/Verify-Verdict.ps1` bare **exit 0, every file verified** (22 at plan-writing;
the store grows by the verdicts that approve this plan). NOTE: the producer is LIVE -
the car's own reviewer stops will write records into `artifacts/` on the CONDUCTOR'S
checkout, not the car's worktree; the car must not be surprised by store growth between
its base and merge (the conductor reconciles at merge - stated here so an honest car
does not stop on it).

## Global constraints

Red-first per step; ledger both questions per task; docs same-commit (the migration
commit especially IS this rule); honest-stop is SUCCESS; car commits locally, never
pushes; runtime floor pwsh 7.4 for new files; `#requires` headers; suites under pwsh
with the shell stated.

### Conductor rulings (recorded, reviewable)

**R7 - the migration form: verdict BODIES stay markdown and MOVE; each gains a sibling
JSON record.** The 22 landed verdicts are hash-verified `.md` bodies - their integrity
lines cover every byte, so converting them would be editing the record (forbidden).
Ruled: `git mv docs/reviews/<name>.md artifacts/reviews/<name>.md` (history preserved -
`git mv` keeps follow/blame); each migrated verdict gains a sibling record
`artifacts/reviews/<name>.json` with `kind: returned`, **`subject` = the verdict's
filename slug** (stable, unique, human-meaningful; historical verdicts predate machine
subjects and their task ids are not reliably in-file), `at` = the file's FIRST git
authorship timestamp (deterministic: `git log --follow --format=%aI -- <file> | tail
-1`), `outcome` = the header's `**Verdict: X**` value, `abstract` = the Title line,
`normalisation: []`, `integrity` over the record's own canonical body, plus extra field
`body_file` (open posture) pointing at the sibling `.md` relative to the store root.
The index then carries one row per verdict (it globs `*.json`), and `Verify-Verdict`
keeps verifying the `.md` bodies unchanged.

**R8 - "the eight landed verdicts" reads as the CLASS.** Spec §8 scoped migration to
"the eight landed verdicts" - the count at spec time. Eight has floated to 22 by the
train's own reviews: the self-referential-baseline class, already named at Car 1.
Ruled: migrate ALL verdicts landed in `docs/reviews/` at migration time; the number is
whatever `ls | wc -l` says that day.

**R9 - the verifier's default repoints in the migration commit.** Post-migration,
`docs/reviews/` is EMPTY-then-deleted, and S1 made an absent default dir a loud
failure - so `Verify-Verdict.ps1:24`'s default `docs/reviews` MUST become
`artifacts` in the same commit, with a `-Recurse` rider (`:97`'s `Get-ChildItem` is
non-recursive - structural, read at base - and the store nests `.md` under
`artifacts/reviews/` and subjects' dirs). `ci.yml:47`'s bare invocation then stays
textually bare and semantically repointed - spec ruling 4's "updated in the migration
commit" is satisfied by the default change plus the ci.yml edits C.2 makes anyway;
the plan states this reading so the reviewer can rule on it rather than find it.

## Car 3 - Tasks C.1-C.4

### Task C.1 - THE MIGRATION COMMIT (one commit, by spec ruling 4)

**Files:** Create `scripts/Migrate-Verdicts.ps1` (the tested, idempotent migration
tool - reusability rule: versioned, one command, its failure tells you what went
stale); Create `scripts/tests/Migration.Tests.ps1`; the migration EXECUTION then
touches: all `docs/reviews/*.md` (git mv), created `artifacts/reviews/*.json`,
regenerated `artifacts/index.md` (via `scripts/New-ArtifactIndex.ps1` - Car 1 landed
it first precisely so this car has something to invoke, spec §9), Modify
`scripts/Verify-Verdict.ps1` (default + `-Recurse`, R9), Modify `docs/setup.md:23-24`,
Modify `README.md` (the adapter sentence at ~:46-47: "a conductor-maintained state
file" becomes the artifact store), Modify `docs/friction-log.md` (the row citing
Verify-Verdict "running only on memory" - LOCATE BY CONTENT, the cited line number
has already drifted; name-anchor lesson).

- [ ] **Step 1 - failing tests** (fixture: a temp dir with two fake verdict `.md`
  files carrying real integrity headers): Migrate-Verdicts produces a `.json` per
  `.md` with outcome parsed from the header and `body_file` set; idempotent (second
  run changes nothing); the record validates via `Test-StarcarArtifact`; the index
  regenerated over the fixture store includes the new rows; `Verify-Verdict -ReviewsDir
  <fixture> ` with nested dirs finds the bodies only with the `-Recurse` rider (red:
  without the rider, nested bodies are MISSED - assert found-count).
- [ ] **Step 2 - red REASONS (plan-writer evidence, conditions stated):** the script
  red is the established `CommandNotFoundException` class (pwsh 7.6.3, observed
  verbatim on B.2/B.3's identical shape); the `-Recurse` red is structural-plus-run:
  `Verify-Verdict.ps1:97` is non-recursive (read at base), so the nested-fixture
  count assertion fails against the unmodified script - the car RUNS and quotes it.
- [ ] **Step 3 - implement + EXECUTE the migration** (tool first, then the one
  commit: mv + records + index + verifier + all four mirrors).
- [ ] **Step 4 - green + suites:** all suites; `./scripts/Verify-Verdict.ps1` bare now
  verifies the store (expect: every migrated body verified, exit 0); the index diff
  gate dry-run: regenerate and `git diff --exit-code artifacts/index.md` clean.
- [ ] **Step 5 - commit** (ONE commit): `feat(harness): the migration - verdicts into the store, index live, verifier repointed (#7)`

**Ledger both parts:** process none. Derived committed artifacts: **the index instance
is BORN here** - the A.5 ledger row's "no instance yet" flips; C.4 updates the ledger
in its docs pass (same-train, and the gating matrix's index-staleness row flips to
ARMED at C.2 - stated so the reviewer checks the pair).

### Task C.2 - CI: the gates and the portability leg

**Files:** Modify `.github/workflows/ci.yml`.

Four additions, each tracing to a landed obligation:
1. **Probes step** (#10): `Invoke-Pester -Path ./scripts/probes` BEFORE the test
   suite, zero-test refusal pattern copied from the existing Pester step
   (`ci.yml:76-81` precedent). A red floor = stop.
2. **Index staleness gate** (spec §5.2, §6): regenerate via `New-ArtifactIndex`,
   `git diff --exit-code artifacts/index.md` - stale index fails the build. Fault
   path per §6: the car proves it in a LOCAL fixture (stale the index, watch the
   diff fail) - the CI-side firing is conductor handback.
3. **Checkpoint-branch fetch** (spec [m5]): `git fetch origin
   entire/checkpoints/v1` after checkout, non-fatal if absent on a fork (a stranger
   has no checkpoint branch - Law 7; `|| echo` the omission loudly). Tier-2's
   CI-reachability precondition; enumeration itself stays deferred (R6v2).
4. **Ubuntu matrix leg** (#14): `strategy.matrix.os: [windows-latest, ubuntu-latest]`,
   `runs-on: ${{ matrix.os }}`. pwsh is preinstalled on both. Any Windows-only step
   guards on `runner.os`. THE PROOF ARTIFACT for the portability claim - both legs
   green is the measured fact #14's README badge waits on.

- [ ] **Step 1-2 - red:** ci.yml is not locally executable; the red is the
  REVIEWER-side sentence check plus the conductor's CI handback (stated, not faked -
  the B.5 precedent). The car's local evidence: `yamllint`-class parse (pwsh
  `ConvertFrom-Yaml` if present, else python `yaml.safe_load` - probe which exists,
  quote it) and the local stale-index fault proof from C.1's fixture.
- [ ] **Steps 3-5**; commit: `ci: probes floor, index staleness gate, checkpoint fetch, ubuntu matrix leg (#7, #10, #14)`

**Ledger:** none / none (CI config; the gating matrix flip is C.4's docs pass).

### Task C.3 - the latency split, measured (#15)

**Files:** Create `scripts/probes/HookLatency.Probes.Tests.ps1` (a MEASUREMENT probe:
it times, reports, and asserts only non-vacuity - that each timed component ran;
thresholds would cry wolf on a loaded box).

Time, on this box, each in isolation (10 iterations, report min/median): bare
`pwsh -NoProfile -Command exit` start; `python -c pass` start; one
`Produce-Artifact.ps1` fixture run end-to-end (write + commit in a temp repo); one
probe-hook append. Land the numbers in the probe-results doc as the #15 split
addendum (the car edits the doc in the same commit - the measurement IS the
deliverable; remedy decisions come after, per #15's discipline).

- [ ] **Steps 1-5** standard shape; red: probe file absent (established class);
  commit: `probe(harness): the latency split measured - pwsh start vs producer vs append (#15)`

**Ledger:** none / none.

### Task C.4 - docs truth pass: probe 6, gating flips, ledger, spec §9 closeout

**Files:** Modify `docs/probes/2026-07-22-spec7-probe-results.md` (Probe 6: spec §7
[m1] "is every dispatch asynchronous?" - ANSWERED for this shop: 6 of 6 recorded
launch payloads carry `isAsync: true`, probe log, 2026-07-22; the residual - a future
synchronous dispatch surface would collapse tier 1's grain - stated); Modify
`docs/contracts/gating-matrix.md` (index-staleness row: DEFERRED becomes ARMED with
the CI step named as evidence; tier-2 row cites the fetch landed + enumeration still
deferred); Modify `docs/contracts/state-ledger.md` (the index instance row flips:
"generator landed, no instance yet" becomes "instance live at artifacts/index.md,
staleness owner: CI diff gate"); spec §9 rows 3-9 all now DONE - state the closeout
in the plan-review record, not by editing the frozen spec.

- [ ] **Steps 1-5**; the red is DocPolicy on any new doc (none expected - state n/a)
  plus the reviewer's sentence check; commit:
  `docs(harness): probe 6 landed, gates armed, ledger trued - spec section-9 closeout (#7)`

**Ledger:** IS this task; arithmetic inline (derived instances 0 -> 1, armed).

## §Handback - conductor-only after merge

1. Push and watch BOTH matrix legs to terminal conclusion (the portability fact).
2. Watch the index-staleness gate live: one dispatch writes a record, the index goes
   stale, CI must fail on the next push until regenerated - the §6 fault, fired in
   anger once, then the regeneration habit (or a follow-up automation issue) decided.
3. The store-growth reconcile: records written by the producer during Car 3's
   review cycle merge cleanly with the migrated store.
4. THE PING: on gate-green, notify the owner (ready-to-spin, per standing
   instruction) and WAIT before opening the PR.

## Spec-coverage table (Car 3's share - subsection-granular)

| Obligation | Disposition |
|---|---|
| §4 row 4 (S1 form): verifier repointed in the migration commit | C.1 (R9) |
| §4 row 5: store migration + history + index, one commit | C.1 (R7, R8) |
| §5.2: index committed, CI regenerates and diffs | C.1 (instance) + C.2 (gate) |
| §6: stale index fails CI | C.2 (local fault proof) + Handback 2 (live) |
| §2.5 [m5]: checkpoint-branch fetch | C.2 |
| §7 [m1] probe 5/6: async grain | C.4 (answered, 6/6 measured) |
| §9 rows: setup.md, README adapter line, friction-log row | C.1 (same commit) |
| §9 ci.yml row | C.2 |
| #10 probes in CI | C.2 |
| #14 ubuntu leg (proof artifact) | C.2 + Handback 1 |
| #15 latency split | C.3 |
| §8 non-goals | binds: no retention/pruning, no tier-2 enumeration (R6v2), no rendering |

## Totals

4 tasks, one car (Sonnet). Suite counts float upward by the migration/measurement
tests (car reports observed per commit; the plan predicts direction, not numbers -
the self-referential class, closed). Verify-Verdict: exit 0, every body verified, at
every boundary.

## The plan-review record (rule 5)

*Pending - plan adversary (Opus, fresh series), five dimensions + rulings R7/R8/R9.
Plan-writer evidence (conditions stated): Verify-Verdict.ps1:97 non-recursion read at
base; README adapter sentence and friction-log drift verified by content-grep at base;
isAsync 6/6 from the launch probe log; verdict-header shape (Round/Base/Verdict lines)
read from a landed verdict at base; the CommandNotFoundException red class carried
from four observed runs this train under pwsh 7.6.3. The adversary re-verifies.*
