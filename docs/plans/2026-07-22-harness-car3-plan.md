Status: Current

# Dispatch harness - Car 3 implementation plan, rev 2 (migration, CI gates, portability leg)

Review record: **round 1 REJECT - 5 Major, 4 Minor, 2 Notes**
(`docs/reviews/2026-07-22-car3-plan-review-round1.md`), M1 and M2 empirically proven by
the reviewer (R7's shape run through the landed validator: Valid=False; R9's recursive
glob run against a fixture: the headerless `index.md` fails verification). All eleven
findings folded inline, tagged `[C3R1-*]`; disposition table at the end. The one-commit
reading was BLESSED in principle; R8 ruled SOUND; both stand unchanged.

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

**R7v2 [C3R1-M1 folded - R7 was schema-invalid, PROVEN by the reviewer running the
landed validator; this version was built against that same validator's requirements].**
Verdict BODIES stay hash-verified markdown and MOVE (`git mv` - history preserved);
each gains a sibling record `artifacts/reviews/<name>.json` with the COMPLETE required
field set:
- `schema`: `starcar-artifact/1` (the const - M1's first missing field);
- `kind`: `returned`;
- `subject`: the filename slug (stable, unique; **MARKED deviation from the schema's
  identity semantic** - these records have no dispatch, and the deviation is stated
  here rather than implied);
- `session_id`: `pre-harness-migration` (a sentinel, deterministic and honest - M1's
  second missing field; historical verdicts predate machine session ids);
- `at`: the file's FIRST git authorship timestamp (`git log --follow --format=%aI --
  <file> | tail -1`);
- `outcome`/`findings`/`abstract` **[C3R1-m2 folded]**: parsed from the verdict's OWN
  landed envelope fence where present - **measured at base: 20 of 23 verdicts carry a
  ```` ```starcar-artifact ```` fence** whose fields were written by the reviewer that
  authored the verdict (the truest possible source). For the 3 fence-less early
  verdicts, deterministic fallback: `outcome` = the LEADING TOKEN of the
  `**Verdict: X**` header line (matches the vocabulary; the rich remainder is prose),
  `findings` = `migrated: see body_file`, `abstract` = the Title line;
- `normalisation: []`; `integrity` computed **by the same canonicalisation
  `Produce-Artifact.ps1` uses** (compact JSON of ordered fields, integrity excluded -
  named by function, [C3R1-n2 folded]) - and C.1's tests VERIFY the hash round-trips,
  not merely that a field exists;
- extra `body_file` (open posture) pointing at the sibling `.md`.
The index carries one row per record; `Verify-Verdict` keeps verifying the `.md`
bodies unchanged.

**R8 - "the eight landed verdicts" reads as the CLASS.** Spec §8 scoped migration to
"the eight landed verdicts" - the count at spec time. Eight has floated to 22 by the
train's own reviews: the self-referential-baseline class, already named at Car 1.
Ruled: migrate ALL verdicts landed in `docs/reviews/` at migration time; the number is
whatever `ls | wc -l` says that day.

**R9v2 [C3R1-M2 folded - R9's `artifacts` default + `-Recurse` was PROVEN to choke on
the headerless `index.md`, turning the migration commit CI-red].** The verifier's
default (`Verify-Verdict.ps1:27` [C3R1-m1 - rev 1 miscited `:24`, a comment]) becomes
**`artifacts/reviews`** - the directory that holds ONLY integrity-headed `.md` bodies,
needs NO recursion (the `-Recurse` rider is DROPPED entirely; rev 1's nesting rationale
was factually false - subject dirs hold only `.json`), and never sees `index.md`.
`ci.yml:47`'s bare invocation stays textually bare and semantically repointed in the
migration commit - the one-commit reading the round-1 reviewer BLESSED, now actually
met because the repointed bare verifier exits 0.

**R10 [C3R1-M5 folded - the future-verdict flow, ruled rather than left two-readable].**
From the migration commit forward, the landing convention for rich verdict `.md` bodies
is **`artifacts/reviews/`** - the conductor's `-Out` argument points there, and
`docs/setup.md`'s convention row says so in the same commit. Future verdicts therefore
land INSIDE the verifier's default coverage; nothing can land silently unverified in a
resurrected `docs/reviews/` because the convention, the verifier default, and the docs
all point at one place (Law 6: one location, one owner). The producer's auto-written
JSON `returned` records remain the machine layer; the rich `.md` is the body companion
for gate verdicts, landed by the conductor via the backfill CLI, verified by the same
gate as ever.

## Car 3 - Tasks C.1-C.4

### Task C.1 - THE MIGRATION COMMIT (one commit, by spec ruling 4)

**Files:** Create `scripts/Migrate-Verdicts.ps1` (the tested, idempotent migration
tool - reusability rule: versioned, one command, its failure tells you what went
stale); Create `scripts/tests/Migration.Tests.ps1`; the migration EXECUTION then
touches: all `docs/reviews/*.md` (git mv), created `artifacts/reviews/*.json`,
regenerated `artifacts/index.md` (via `scripts/New-ArtifactIndex.ps1` - Car 1 landed
it first precisely so this car has something to invoke, spec §9), Modify
`scripts/Verify-Verdict.ps1` (default to `artifacts/reviews`, NO recursion, R9v2);
Modify `docs/setup.md:23-24` (including R10's landing-convention row); Modify
`README.md` **[C3R1-m3 folded - the EXACT replacement text, so no premature
board-consumption claim ships]:** the adapter parenthetical becomes `(a git repo, an
issue tracker's project board, an artifact store - the dispatch harness's store lands
in this repo; the board's consumption of it is #1's train)`; Modify
`docs/friction-log.md` (the Verify-Verdict "running only on memory" row - LOCATE BY
CONTENT, the cited line has already drifted); **and [C3R1-M3 folded - living
contracts binds THIS commit]: Modify `docs/contracts/state-ledger.md` IN THIS
COMMIT** - the index-instance row flips "no instance yet" to "instance live at
artifacts/index.md", because C.1 is the commit that invalidates it, so C.1 trues it.

- [ ] **Step 1 - failing tests** (fixture: a temp dir with fake verdict `.md` files
  carrying real integrity headers - at least one WITH an envelope fence and one
  WITHOUT, covering both R7v2 parse paths): Migrate-Verdicts produces a `.json` per
  `.md` with outcome/findings/abstract from the fence where present and the fallback
  where not; idempotent (second run changes nothing); the record **validates via
  `Test-StarcarArtifact` AND its `integrity` round-trips under the producer's
  canonicalisation** [C3R1-M1/n2 - the round-1 reviewer proved a shape can pass a
  field-presence check while carrying a bogus hash; assert the hash, not the field];
  the index regenerated over the fixture store includes the new rows;
  `Verify-Verdict -ReviewsDir <fixture>/reviews` (flat, R9v2) verifies every body and
  **exits 0 with `index.md` present at the fixture ROOT** - the anti-trap assertion,
  pinning that the default never globs the index [C3R1-M2].
- [ ] **Step 2 - red REASONS (plan-writer evidence, conditions stated):** the script
  red is the established `CommandNotFoundException` class (pwsh 7.6.3, observed
  verbatim four times this train); the anti-trap red: point the CURRENT verifier
  (default `docs/reviews`) at a fixture root CONTAINING `index.md` - the round-1
  reviewer observed `NO INTEGRITY ...index.md ... ANY FAIL = True` (their fixture,
  quoted in the landed verdict); the car re-derives before fixing.
- [ ] **Step 3 - implement + EXECUTE the migration** (tool first, then the one
  commit: mv + records + index + verifier default + all mirrors + the ledger flip).
- [ ] **Step 4 - green + suites:** all suites; `./scripts/Verify-Verdict.ps1` bare
  (new default `artifacts/reviews`) verifies every migrated body, exit 0; the index
  diff gate dry-run: regenerate and `git diff --exit-code artifacts/index.md` clean.
- [ ] **Step 5 - commit** (ONE commit): `feat(harness): the migration - verdicts into the store, index live, verifier repointed (#7)`

**Ledger both parts:** process none. Derived committed artifacts: **the index instance
is BORN here and the ledger row flips IN THIS COMMIT** [C3R1-M3 folded - the
same-commit law; rev 1's deferral to C.4 was the violation].

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
   green is the measured fact #14's README badge waits on. **[C3R1-m4 folded - scope
   guard]:** whether the EXISTING suite passes on ubuntu is unproven; if the ubuntu
   leg surfaces a failing test, that is CODE work outside this task's ci.yml-only
   file list - the car HONEST-STOPS on it with the failure quoted, and does NOT
   expand C.2's scope to fix it. The stop is the success outcome; the fix is a
   rider decision.

- [ ] **Step 1-2 - red:** ci.yml is not locally executable; the red is the
  REVIEWER-side sentence check plus the conductor's CI handback (stated, not faked -
  the B.5 precedent). The car's local evidence: `yamllint`-class parse (pwsh
  `ConvertFrom-Yaml` if present, else python `yaml.safe_load` - probe which exists,
  quote it) and the local stale-index fault proof from C.1's fixture.
- [ ] **Steps 3-5**; commit: `ci: probes floor, index staleness gate, checkpoint fetch, ubuntu matrix leg (#7, #10, #14)`

**Ledger:** process none / derived none NEW - but **[C3R1-M3 folded]: the
gating-matrix flip (index-staleness row DEFERRED to ARMED, with the CI step named as
evidence) lands IN THIS COMMIT** - C.2 is the commit that arms the gate, so C.2 trues
the matrix; `docs/contracts/gating-matrix.md` joins this task's Files. [Rev 1's
internal contradiction - "flips at C.2" vs "C.4's docs pass" - is resolved: C.2.]

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

### Task C.4 - docs truth pass: probe 6 and the spec §9 closeout

**Files [C3R1-M3 slimmed this task - the contract flips moved into C.1 and C.2, the
commits that invalidate them]:** Modify `docs/probes/2026-07-22-spec7-probe-results.md`
(Probe 6: spec §7 [m1] "is every dispatch asynchronous?" - ANSWERED for this shop: 6
of 6 recorded launch payloads carry `isAsync: true`, probe log, 2026-07-22;
**[C3R1-n1 folded] the entry states the REPRODUCTION METHOD** - the committed
`post-task-probe.sh` hook logs every launch, so any dispatch regenerates the
observation; the residual - a future synchronous dispatch surface would collapse tier
1's grain - stated); tier-2 gating-matrix row wording (fetch landed, enumeration
deferred) if C.2 did not already carry it; spec §9 rows 3-9 closeout stated in the
plan-review record, never by editing the frozen spec.

- [ ] **Steps 1-5**; the red is DocPolicy on any new doc (none expected - state n/a)
  plus the reviewer's sentence check; commit:
  `docs(harness): probe 6 landed with its method - spec section-9 closeout (#7)`

**Ledger:** none / none (the flips already landed with their invalidating commits).

## §Handback - conductor-only after merge

1. Push and watch BOTH matrix legs to terminal conclusion (the portability fact).
2. **[C3R1-M4 folded - MANDATORY, before the ping]: regenerate `artifacts/index.md`
   over the MERGED store and commit it.** The producer wrote records on the
   conductor's checkout during Car 3's cycle; those are absent from the car's
   committed index, so the merged HEAD fails C.2's own staleness gate until the
   regenerate-and-commit lands. The same applies after any rollback (`git revert` of
   the migration commit is sufficient - the round-1 reviewer verified the mv-reversal
   restores everything byte-preserved - but the reverted index needs the same
   regenerate). MERGE NORTH STAR: no PR until this is done and CI is green.
3. Watch the index-staleness gate live: one dispatch writes a record, the index goes
   stale, CI must fail on the next push until regenerated - the §6 fault fired in
   anger once; then decide the regeneration habit (or file the automation issue).
4. THE PING: on gate-green (which now includes the reconcile in step 2), notify the
   owner (ready-to-spin, per standing instruction) and WAIT before opening the PR.

## Spec-coverage table (Car 3's share - subsection-granular)

| Obligation | Disposition |
|---|---|
| §4 row 4 (S1 form): verifier repointed in the migration commit | C.1 (R9v2) |
| §4 row 5: store migration + history + index, one commit | C.1 (R7v2, R8) |
| Future-verdict landing convention | R10 + C.1's setup.md row [C3R1-M5] |
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

## Round-1 finding disposition [the carrier the delta walks]

| ID | Finding (compressed) | Disposition in rev 2 |
|---|---|---|
| C3R1-M1 | R7 record shape schema-invalid (proven: missing schema/session_id/findings) | R7v2: complete field set; envelope-fence parse (20/23 measured) with deterministic fallback; integrity round-trip asserted, not field-presence |
| C3R1-M2 | R9's artifacts default + -Recurse chokes on headerless index.md (proven) | R9v2: default `artifacts/reviews`, NO recursion, anti-trap assertion pinned in C.1's tests |
| C3R1-M3 | Contract flips deferred out of the invalidating commits | Ledger flip into C.1; matrix flip into C.2; C.4 slimmed; rev-1's internal contradiction resolved |
| C3R1-M4 | "Merge cleanly" false comfort; merged HEAD fails the staleness gate | Handback 2: MANDATORY regenerate-and-commit over the merged store before the ping; rollback story stated |
| C3R1-M5 | Future verdicts could land unverified in a resurrected docs/reviews | R10: landing convention repoints to artifacts/reviews, one location one owner, setup.md row in the migration commit |
| C3R1-m1 | :24 miscited for the default | :27 cited (R9v2) |
| C3R1-m2 | Verdict-header parse ambiguity, vocabulary pollution | R7v2: envelope-fence first; fallback = LEADING TOKEN of the header |
| C3R1-m3 | README edit risked premature board-consumption claim | Exact replacement text specified in C.1's Files |
| C3R1-m4 | Ubuntu suite portability unproven; scope-creep risk | Scope guard in C.2: honest-stop on any ubuntu test failure, never expand |
| C3R1-n1 | isAsync raw evidence gitignored | Probe 6 entry states the reproduction method (committed hook regenerates on any dispatch) |
| C3R1-n2 | Integrity canonicalisation unspecified; bogus hash would pass | R7v2 names the producer's canonicalisation; C.1 asserts round-trip |

## The plan-review record (rule 5)

Round 1: **REJECT - 5 Major, 4 Minor, 2 Notes**
(`docs/reviews/2026-07-22-car3-plan-review-round1.md`); M1/M2 proven by execution; the
one-commit reading BLESSED; R8 SOUND. Round 2 is a delta to the same reviewer walking
the disposition table.

*Plan adversary dimensions + rulings R7v2/R9v2/R10 on re-review.
Plan-writer evidence (conditions stated): Verify-Verdict.ps1:97 non-recursion read at
base; README adapter sentence and friction-log drift verified by content-grep at base;
isAsync 6/6 from the launch probe log; verdict-header shape (Round/Base/Verdict lines)
read from a landed verdict at base; the CommandNotFoundException red class carried
from four observed runs this train under pwsh 7.6.3. The adversary re-verifies.*
