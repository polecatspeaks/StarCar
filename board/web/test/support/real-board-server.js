// real-board-server.js - test-side helper (issue #33) that builds and
// spawns the REAL board/server/ Go binary against the REAL repo store
// (artifacts/, schema/, config/, board/web/), never a mock and never a
// static fixture page (the owner's binding amendment on #33). Shared by
// every browser test AND the screenshot-regeneration script (Task 3) so
// there is exactly one hand-rolled "start the real server" implementation
// in this repo (Law 6).
//
// PROBED (Car 33, Task 1b), not assumed:
//   - `go run ./server` was tried first and rejected: killing the node-
//     tracked child left an ORPHANED grandchild process (the compiled temp
//     binary `go run` execs) still holding the listening port - observed
//     directly (EADDRINUSE on an immediate re-bind attempt after killing
//     the `go run` parent). Building the binary once and spawning it
//     directly gives one real OS process to kill, and killing it was
//     observed to release the port immediately (re-bind succeeded).
//   - Readiness is polled via GET / rather than assumed after a fixed
//     delay - the server's HTTP listener is up before RunPollLoop's first
//     tick, but "ready to accept connections" and "has completed one
//     poll of the store" are different moments (see waitForNominalRow
//     below, which is what actually waits for polled data).
//   - Shutdown is `child.kill()` (default SIGTERM). On this box (Windows)
//     this was OBSERVED to terminate the process and release the port
//     within 2s. On POSIX, board/server/main.go's signal.NotifyContext
//     only subscribes os.Interrupt (SIGINT) - SIGTERM is never intercepted,
//     so the Go runtime's un-overridden default action (terminate) applies;
//     this is Go's documented default rather than something re-provable on
//     a Windows sandbox, and the ubuntu-latest CI leg is the actual
//     cross-platform measurement of it.
import { spawn, spawnSync } from 'node:child_process';
import { mkdtempSync, existsSync, cpSync, mkdirSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import http from 'node:http';

// board/web/test/support/real-board-server.js -> repo root is 4 levels up.
const REPO_ROOT = fileURLToPath(new URL('../../../../', import.meta.url));
const BOARD_DIR = join(REPO_ROOT, 'board');

// buildScratchStoreWithInFlightDispatch (#29) copies the REAL repo
// artifacts/ store into a scratch temp directory - every committed record,
// byte-identical, never a synthetic replacement - and adds exactly ONE
// additional, genuinely IN-FLIGHT "dispatched" record (no returned or
// presumed-lost successor), dated far enough in the past to be stale under
// any reasonable stalenessMs.
//
// WHY THIS EXISTS (disclosed, #29): board/server/poll.go's computeLiveFreshness
// used to render "stale" for ANY old data, so the ambient repo store (whose
// records only ever get OLDER relative to "now") reliably reproduced issue
// #31's needs-attention-lane-with-a-nominal-row shape forever, with zero
// fixture maintenance. #29's fix makes "stale" require something IN FLIGHT
// (never just old data) - a yard where every dispatch has already returned
// is now correctly "idle" (calm), and a repo-wide scan of this repo's own
// artifacts/ store (this car's report) found ZERO subjects still in flight.
// The #31 regression guard therefore needs its OWN reliably-stale fixture
// rather than depending on the ambient repo's history, which #29 makes
// permanently idle by design (every merged dispatch has returned).
export function buildScratchStoreWithInFlightDispatch() {
  const storeDir = mkdtempSync(join(tmpdir(), 'starcar-board-scratch-store-'));
  cpSync(join(REPO_ROOT, 'artifacts'), storeDir, { recursive: true });
  const subjectDir = join(storeDir, 'browser-cascade-in-flight-probe');
  mkdirSync(subjectDir, { recursive: true });
  writeFileSync(
    join(subjectDir, 'dispatched-1.json'),
    JSON.stringify(
      {
        schema: 'starcar-artifact/1',
        kind: 'dispatched',
        subject: 'browser-cascade-in-flight-probe',
        session_id: 'browser-cascade-probe-session',
        at: '2020-01-01T00:00:00Z',
        normalisation: [],
        integrity: 'sha256:0000000000000000000000000000000000000000000000000000000000000000'
      },
      null,
      2
    ),
    'utf8'
  );
  return storeDir;
}

// buildScratchStoreWithHealthTrendFamilies (#12: car health bar browser
// cascade guard) builds a MINIMAL, self-contained scratch store (never the
// ambient repo store, which has no controlled review-round family to prove
// a specific trend from) with one train manifest declaring TWO gate
// families: a CONVERGED one (3 Major, then 0 Major - healthy regardless of
// the starting number) and a STALLED one (3 -> 4 -> 4, the swirl
// signature) - real JSON records, the real schema's required fields, so
// the real Go server folds/assembles/serves them exactly as it would any
// other review round.
export function buildScratchStoreWithHealthTrendFamilies() {
  const storeDir = mkdtempSync(join(tmpdir(), 'starcar-board-health-trend-store-'));

  // dirName sanitises a subject into a filesystem-safe directory name
  // (":" is illegal in a Windows path) - matching this repo's OWN real
  // convention: artifacts/train-board-v0/ holds subject "train:board-v0"'s
  // record, dash for colon, exactly the producer-side sanitisation issue
  // #28's own design note names ("the subject-sanitisation rule"). The
  // manifest intent record's OWN directory name is otherwise irrelevant to
  // assemble.go (it matches raw records by subject+kind+at content, never
  // by path) - this mirrors real practice rather than being load-bearing
  // for this fixture to work.
  function dirName(subject) {
    return subject.replace(/:/g, '-');
  }

  function write(subject, kind, at, extra = {}) {
    const dir = join(storeDir, dirName(subject));
    mkdirSync(dir, { recursive: true });
    writeFileSync(
      join(dir, `${kind}-${at.replace(/[:.]/g, '')}.json`),
      JSON.stringify(
        {
          schema: 'starcar-artifact/1',
          kind,
          subject,
          session_id: 'health-trend-probe-session',
          at,
          normalisation: [],
          integrity: 'sha256:0000000000000000000000000000000000000000000000000000000000000000',
          ...extra
        },
        null,
        2
      ),
      'utf8'
    );
  }

  write('train:health-trend-demo', 'intent', '2026-07-23T09:00:00Z', {
    manifest: {
      title: 'Health trend cascade probe',
      tickets: ['#12'],
      members: [
        { subject: 'conv-review-r1', role: 'gate', gate: 'round 1' },
        { subject: 'conv-review-r2', role: 'gate', gate: 'round 2' },
        { subject: 'stall-review-r1', role: 'gate', gate: 'round 1' },
        { subject: 'stall-review-r2', role: 'gate', gate: 'round 2' },
        { subject: 'stall-review-r3', role: 'gate', gate: 'round 3' }
      ]
    }
  });

  write('conv-review-r1', 'returned', '2026-07-23T10:00:00Z', {
    outcome: 'REJECT',
    findings: '3 Major, 1 Minor',
    abstract: 'round 1'
  });
  write('conv-review-r2', 'returned', '2026-07-23T11:00:00Z', {
    outcome: 'APPROVE',
    findings: '0 Major, 0 Minor',
    abstract: 'round 2 - converged'
  });

  write('stall-review-r1', 'returned', '2026-07-23T10:00:00Z', {
    outcome: 'REJECT',
    findings: '3 Major, 2 Minor',
    abstract: 'round 1'
  });
  write('stall-review-r2', 'returned', '2026-07-23T11:00:00Z', {
    outcome: 'REJECT',
    findings: '4 Major, 1 Minor',
    abstract: 'round 2'
  });
  write('stall-review-r3', 'returned', '2026-07-23T12:00:00Z', {
    outcome: 'REJECT',
    findings: '4 Major, 0 Minor',
    abstract: 'round 3 - stalled, the swirl signature'
  });

  return storeDir;
}

// buildScratchStoreWithLaneFilterFixtures (#67: dispatches + trains lane
// filters, compact-clock time) - a MINIMAL, self-contained scratch store
// (same posture as buildScratchStoreWithHealthTrendFamilies above: never the
// ambient repo store, which has no controlled recency spread to cap
// against) proving all three #67 rendering-check claims against the REAL
// Go server in one fixture:
//   (a) 5 solo (non-train) subjects returned on 5 distinct days - the
//       dispatches lane must cap to the 4 most recent and hide exactly 1;
//   (b) 1 solo subject still DISPATCHED (never returned), dated far in the
//       past - proves a needs-attention row survives capping regardless of
//       recency (and its live elapsed_seconds exercises the real compact-
//       clock formatter against a server-computed value, never a literal
//       this fixture invents);
//   (c) 5 one-car trains, each fully returned on 5 distinct days - same cap/
//       hide-1 proof at the trains lane;
//   (d) 1 train whose sole car is still DISPATCHED - proves a train with an
//       in-flight car survives capping regardless of recency;
//   (e) 1 train whose sole car is RETURNED (stateRegister nominal) but
//       whose OUTCOME is 'error' (needs-attention per board-defs.json),
//       dated far in the past - the #67 fix cycle round 2 MAJOR-R1-1
//       regression proof: a train can be fully returned by STATE and still
//       be hot by OUTCOME, and must never be capped either way.
export function buildScratchStoreWithLaneFilterFixtures() {
  const storeDir = mkdtempSync(join(tmpdir(), 'starcar-board-lane-filter-store-'));

  function dirName(subject) {
    return subject.replace(/:/g, '-');
  }

  function write(subject, kind, at, extra = {}) {
    const dir = join(storeDir, dirName(subject));
    mkdirSync(dir, { recursive: true });
    writeFileSync(
      join(dir, `${kind}-${at.replace(/[:.]/g, '')}.json`),
      JSON.stringify(
        {
          schema: 'starcar-artifact/1',
          kind,
          subject,
          session_id: 'lane-filter-probe-session',
          at,
          normalisation: [],
          integrity: 'sha256:0000000000000000000000000000000000000000000000000000000000000000',
          ...extra
        },
        null,
        2
      ),
      'utf8'
    );
  }

  // (a) 5 solo returned dispatches, one per day 2026-07-01..05.
  for (let day = 1; day <= 5; day += 1) {
    const subject = `lane-filter-solo-r${day}`;
    const dispatchedAt = `2026-07-0${day}T09:00:00Z`;
    const returnedAt = `2026-07-0${day}T10:00:00Z`;
    write(subject, 'dispatched', dispatchedAt);
    write(subject, 'returned', returnedAt, {
      outcome: 'done',
      findings: 'none',
      abstract: `solo dispatch ${day}, returned`
    });
  }

  // (b) 1 solo dispatch still in flight, dated far in the past - never
  // returned, so the fold's own liveness derivation calls it dispatched (or
  // overdue/presumed-lost, depending on board/fold's own budget/timeout
  // arithmetic - any of those three renders needs-attention-or-hotter and is
  // equally valid proof for this fixture's purpose).
  write('lane-filter-solo-hot-ancient', 'dispatched', '2020-01-01T00:00:00Z');

  // (c) 5 one-car trains, each fully returned one per day.
  for (let day = 1; day <= 5; day += 1) {
    const trainSubject = `train:lane-filter-t${day}`;
    const carSubject = `lane-filter-car-t${day}`;
    write(trainSubject, 'intent', `2026-07-0${day}T08:00:00Z`, {
      manifest: { title: `Lane filter train ${day}`, members: [{ subject: carSubject, role: 'car' }] }
    });
    write(carSubject, 'dispatched', `2026-07-0${day}T09:00:00Z`);
    write(carSubject, 'returned', `2026-07-0${day}T10:00:00Z`, {
      outcome: 'done',
      findings: 'none',
      abstract: `train ${day} car, returned`
    });
  }

  // (d) 1 train with an in-flight (never-returned) car, dated far in the
  // past - proves NEVER FILTER A HOT ROW at the trains lane.
  write('train:lane-filter-rolling', 'intent', '2020-01-01T00:00:00Z', {
    manifest: { title: 'Lane filter rolling train', members: [{ subject: 'lane-filter-rolling-car', role: 'car' }] }
  });
  write('lane-filter-rolling-car', 'dispatched', '2020-01-01T00:00:00Z');

  // (e) #67 fix cycle round 2 MAJOR-R1-1: 1 train whose sole car RETURNED
  // (stateRegister nominal) but with a hot OUTCOME ('error', needs-
  // attention) - dated far in the past, same as (d), so a recency-only cap
  // would have wrongly buried it.
  write('train:lane-filter-hot-outcome', 'intent', '2020-01-01T00:00:00Z', {
    manifest: { title: 'Lane filter hot-outcome train', members: [{ subject: 'lane-filter-hot-outcome-car', role: 'car' }] }
  });
  write('lane-filter-hot-outcome-car', 'dispatched', '2020-01-01T00:00:00Z');
  write('lane-filter-hot-outcome-car', 'returned', '2020-01-01T01:00:00Z', {
    outcome: 'error',
    findings: 'none',
    abstract: 'returned, but outcome is hot - must never be capped (MAJOR-R1-1)'
  });

  return storeDir;
}

// buildScratchStoreUnderRepoRootWithConditionsAndSuperseded (#69/#71, view
// train, 2026-07-27) - DELIBERATELY DIFFERENT from every builder above: it
// creates its scratch directory UNDER REPO_ROOT (a sibling of `artifacts/`,
// never inside it - the real store is never touched) rather than under
// `os.tmpdir()`. board/server/reporoot.go's resolveDefaultRepoRoot resolves
// from `cwd` (always REPO_ROOT, real-board-server.js's own spawn option)
// alone, so a tmpdir-based scratch store ALWAYS makes config.
// githubArtifactsPrefix resolve empty (verify-registers.mjs's own disclosed
// limitation, "health-trend-and-provenance" capture) - which would make
// EVERY recordDir-based link (#28's own car/gate/dispatch links, and this
// ticket's board-condition/superseded links) render as plain text, proving
// nothing about whether the link CHOICE logic actually fires. Living under
// REPO_ROOT (still never committed - the caller removes it, see cleanup())
// makes `githubArtifactsPrefix` resolve to this directory's own basename,
// non-empty, so recordDir links render as REAL anchors for this one
// verification pass.
//
// Seeds exactly two real, minimal fixtures:
//   (a) a solo dispatch subject with TWO records (an older `dispatched`,
//       then a newer `returned` winner) - the winner's `superseded` array
//       names the older record, and both share this subject's own
//       recordDir (#71's superseded-link claim, proven against the REAL
//       fold/assemble pipeline, never a hand-built fold.Output).
//   (b) one record carrying an unrecognised `kind` value - board/fold's
//       real discovery-detection path mints a "discovery" board condition
//       with detail `"kind: <value>"`, proving #69's board-condition
//       click-through chooses the VOCAB-FILE link (never a record link)
//       for exactly this class.
//
// Returns { storeDir, cleanup } - the caller MUST call cleanup() (a
// try/finally, same posture as startRealBoardServer.stop()) so this never
// leaves debris in a repo checkout.
export function buildScratchStoreUnderRepoRootWithConditionsAndSuperseded() {
  const storeDir = mkdtempSync(join(REPO_ROOT, '.scratch-store-69-71-'));

  function write(subject, kind, at, extra = {}) {
    const dir = join(storeDir, subject);
    mkdirSync(dir, { recursive: true });
    writeFileSync(
      join(dir, `${kind}-${at.replace(/[:.]/g, '')}.json`),
      JSON.stringify(
        {
          schema: 'starcar-artifact/1',
          kind,
          subject,
          session_id: 'view-69-71-probe-session',
          at,
          normalisation: [],
          integrity: 'sha256:0000000000000000000000000000000000000000000000000000000000000000',
          ...extra
        },
        null,
        2
      ),
      'utf8'
    );
  }

  // (a) superseded pair - dispatched, then returned (the winner).
  write('view-69-71-superseded-demo', 'dispatched', '2026-07-20T09:00:00Z');
  write('view-69-71-superseded-demo', 'returned', '2026-07-20T10:00:00Z', {
    outcome: 'done',
    findings: 'none',
    abstract: 'the winner - the dispatched record above becomes its superseded entry'
  });

  // (b) a discovery: an unrecognised `kind` value.
  write('view-69-71-discovery-demo', 'view-69-71-unrecognised-kind', '2026-07-20T09:00:00Z');

  return {
    storeDir,
    cleanup() {
      rmSync(storeDir, { recursive: true, force: true });
    }
  };
}

// buildScratchStoreForDispatchRowGeometry (#69/#71 fix cycle round 3,
// MAJOR-R2-1) - a tmpdir-based scratch store (no recordDir links needed for
// this test, unlike buildScratchStoreUnderRepoRootWithConditionsAndSuperseded)
// seeding enough dispatch subjects to both (a) overflow .solari-rows' own
// 11rem max-height, so a mid-row crop regression has somewhere to happen,
// and (b) isolate the row-height regression from the disclosure itself -
// MOST rows here carry NO superseded entry at all, so a regression that
// makes every row taller (not just rows with a disclosure) is caught.
// 7 plain subjects (no superseded, sorted alphabetically BEFORE the
// with-sup ones and small enough in number that they alone never straddle
// .solari-rows' own boundary at the correct single-line row height - the
// deliberately CHOSEN row count that keeps "does a PLAIN row ever cross
// the boundary" a meaningful, decidable question rather than a coincidence
// of divisibility) + 2 with exactly one superseded entry each (sorted
// after, and relied on to push the container past its max-height so the
// overflow precondition holds). Mirrors the round-2 reviewer's own
// falsifying recipe (their probe3.mjs used 14 plain + a car-chip train;
// this omits the chip half, which the round-2 review already measured
// clean).
export function buildScratchStoreForDispatchRowGeometry() {
  const storeDir = mkdtempSync(join(tmpdir(), 'starcar-board-scratch-store-'));

  function write(subject, kind, at, extra = {}) {
    const dir = join(storeDir, subject);
    mkdirSync(dir, { recursive: true });
    writeFileSync(
      join(dir, `${kind}-${at.replace(/[:.]/g, '')}.json`),
      JSON.stringify(
        {
          schema: 'starcar-artifact/1',
          kind,
          subject,
          session_id: 'view-69-71-r3-geometry-probe',
          at,
          normalisation: [],
          integrity: 'sha256:0000000000000000000000000000000000000000000000000000000000000000',
          ...extra
        },
        null,
        2
      ),
      'utf8'
    );
  }

  for (let i = 0; i < 7; i += 1) {
    write(`plain-subject-${String(i).padStart(2, '0')}`, 'dispatched', `2026-07-20T09:${String(i).padStart(2, '0')}:00Z`);
  }
  for (let i = 0; i < 2; i += 1) {
    write(`with-sup-${i}`, 'dispatched', `2026-07-20T08:0${i}:00Z`); // becomes the sole superseded entry
    write(`with-sup-${i}`, 'returned', `2026-07-20T09:3${i}:00Z`, { outcome: 'done', findings: 'none', abstract: 'winner' });
  }

  return storeDir;
}

// buildScratchStoreForTaskIdTitles (#75) - a MINIMAL, self-contained scratch
// store (never the ambient repo store, whose real records predate #47's
// task_id field entirely and would exercise only the absent-handle branch)
// proving BOTH #75 rendering branches against the REAL Go server in one
// fixture:
//   (a) a solo returned dispatch carrying task_id - the dispatches lane row
//       must show the task-id as its visible text, with the record-dir hash
//       subject reachable via the native title tooltip;
//   (b) a solo returned dispatch with NO task_id (the honest steady state
//       for every real record predating #47, and for every still-in-flight
//       dispatched record until #76 lands) - the row must fall back to the
//       hash subject exactly as before this ticket;
//   (c) a one-car train whose sole car carries task_id - the SAME treatment
//       must reach the trains lane's car-chip (brief step 5's own
//       enumeration), proven against the real fold/assemble pipeline rather
//       than a hand-built view model.
export function buildScratchStoreForTaskIdTitles() {
  const storeDir = mkdtempSync(join(tmpdir(), 'starcar-board-scratch-store-'));

  // dirName sanitises a subject into a filesystem-safe directory name
  // (":" is illegal in a Windows path) - same convention every other
  // colon-bearing-subject builder above uses. The fold reads `subject` from
  // record CONTENT, never from the directory name, so this is cosmetic to
  // the store's own layout, not load-bearing for this fixture to work.
  function dirName(subject) {
    return subject.replace(/:/g, '-');
  }

  function write(subject, kind, at, extra = {}) {
    const dir = join(storeDir, dirName(subject));
    mkdirSync(dir, { recursive: true });
    writeFileSync(
      join(dir, `${kind}-${at.replace(/[:.]/g, '')}.json`),
      JSON.stringify(
        {
          schema: 'starcar-artifact/1',
          kind,
          subject,
          session_id: 'view-75-probe-session',
          at,
          normalisation: [],
          integrity: 'sha256:0000000000000000000000000000000000000000000000000000000000000000',
          ...extra
        },
        null,
        2
      ),
      'utf8'
    );
  }

  // (a) with task_id - 79 characters, fix cycle r2 (R1-m2), CORRECTED fix
  // cycle r3 (R2-m2, an unmeasured size claim): this comment used to compare
  // the 79-char task_id against "the 33-char subject hash it replaces" -
  // this fixture's own subject, `view-75-with-task-id`, measures 20 chars,
  // and 33 matched nothing here or in any real record-dir hash (measured:
  // 17 chars, e.g. store subject `a076bf6c0a94e302f`). Dropped the
  // comparison rather than re-estimate it. What actually matters, measured
  // (fix cycle r3, R2-m1): `.solari-subject`'s own box is only ~123px wide
  // in this fixture's viewport - a 13rem `auto-fill` grid column - so
  // virtually ANY plausible task-id overflows it, not only an exceptionally
  // long one; this 79-char value is simply a comfortable, unambiguous
  // example of that, never proof that LENGTH itself is what causes
  // overflow.
  write('view-75-with-task-id', 'dispatched', '2026-07-27T09:00:00Z');
  write('view-75-with-task-id', 'returned', '2026-07-27T09:05:00Z', {
    outcome: 'done',
    findings: 'none',
    abstract: 'the human handle should render, not this record-dir hash',
    task_id: 'view-75-extremely-long-human-task-id-handle-for-the-fix-cycle-r2-ellipsis-check'
  });

  // (b) no task_id - the honest fallback floor.
  write('view-75-without-task-id', 'dispatched', '2026-07-27T09:10:00Z');
  write('view-75-without-task-id', 'returned', '2026-07-27T09:15:00Z', {
    outcome: 'done',
    findings: 'none',
    abstract: 'no task_id on this record - the row must fall back to its subject hash'
  });

  // (c) the trains lane / car-chip surface.
  write('train:view-75-chip-demo', 'intent', '2026-07-27T08:55:00Z', {
    manifest: { title: 'Task-id chip demo', members: [{ subject: 'view-75-chip-car', role: 'car' }] }
  });
  write('view-75-chip-car', 'dispatched', '2026-07-27T09:20:00Z');
  write('view-75-chip-car', 'returned', '2026-07-27T09:25:00Z', {
    outcome: 'done',
    findings: 'none',
    abstract: 'the chip should show the task-id too',
    task_id: 'view-75-chip-r1'
  });

  return storeDir;
}

// addRecordToStore (#69/#71) writes ONE additional real record into an
// already-running scratch store, mid-test - used to force a genuine SECOND
// poll-detected CHANGE (a new board condition appears) so a real DOM
// rebuild fires over the live SSE connection, without a page reload. This
// is the "survives a DOM rebuild" half of the #69 rendering-check; a
// SEPARATE `page.reload()` proves the "survives a page refresh" half.
export function addRecordToStore(storeDir, subject, kind, at, extra = {}) {
  const dir = join(storeDir, subject);
  mkdirSync(dir, { recursive: true });
  writeFileSync(
    join(dir, `${kind}-${at.replace(/[:.]/g, '')}.json`),
    JSON.stringify(
      {
        schema: 'starcar-artifact/1',
        kind,
        subject,
        session_id: 'view-69-71-probe-session',
        at,
        normalisation: [],
        integrity: 'sha256:0000000000000000000000000000000000000000000000000000000000000000',
        ...extra
      },
      null,
      2
    ),
    'utf8'
  );
}

function goBinary() {
  // CI (docs/setup.md's Go toolchain row): actions/setup-go puts `go` on
  // PATH for the whole job, same as the existing "Run board Go vet +
  // tests" step already relies on. A stranger's box may not have `go` on
  // PATH at all (this box's own platform note) - that is a real,
  // loud-failure gap, never silently skipped (CLAUDE.md's zero-test/
  // missing-toolchain guards never turn a gap into a quiet pass).
  return process.env.STARCAR_GO_BIN || 'go';
}

function buildServerBinary() {
  const buildDir = mkdtempSync(join(tmpdir(), 'starcar-board-server-'));
  const outPath = join(buildDir, process.platform === 'win32' ? 'board-server.exe' : 'board-server');
  const result = spawnSync(goBinary(), ['build', '-o', outPath, './server'], {
    cwd: BOARD_DIR,
    encoding: 'utf8'
  });
  if (result.error) {
    throw new Error(
      `real-board-server.js: could not invoke '${goBinary()}' to build board/server - is Go on PATH? ` +
        `(docs/setup.md's Go toolchain row: not on every shell's PATH by default). Underlying error: ${result.error.message}`
    );
  }
  if (result.status !== 0) {
    throw new Error(`real-board-server.js: 'go build ./server' failed (exit ${result.status}):\n${result.stderr}`);
  }
  if (!existsSync(outPath)) {
    throw new Error(`real-board-server.js: go build reported success but ${outPath} does not exist.`);
  }
  return outPath;
}

function get(port, path) {
  return new Promise((resolve, reject) => {
    const req = http.get({ host: '127.0.0.1', port, path, timeout: 2000 }, (res) => {
      let body = '';
      res.on('data', (c) => (body += c));
      res.on('end', () => resolve({ status: res.statusCode, body, headers: res.headers }));
    });
    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error(`GET ${path} timed out`));
    });
  });
}

async function waitForHttpReady(port, timeoutMs) {
  const start = Date.now();
  let lastErr;
  while (Date.now() - start < timeoutMs) {
    try {
      const res = await get(port, '/');
      if (res.status === 200) return;
    } catch (err) {
      lastErr = err;
    }
    await new Promise((r) => setTimeout(r, 50));
  }
  throw new Error(`board server never became ready on port ${port} within ${timeoutMs}ms: ${lastErr}`);
}

// pollMs is set small (default 50ms) so the test does not wait the
// production default (1000ms) for the FIRST real poll of the store to
// land - composeRegister's "stale" freshness (and therefore the #31
// reproduction) only appears after at least one successful poll.
//
// storePath (#29) is an OPTIONAL override, via the server's own
// STARCAR_STORE_PATH env var (board/server/config.go's applyEnvOverrides) -
// never a second store-selection mechanism. Every caller before #29 left
// this unset and got the real repo artifacts/ store (REPO_ROOT's cwd,
// board/server's own default StorePath resolution); that behavior is
// UNCHANGED when storePath is omitted. buildScratchStoreWithInFlightDispatch
// below is the one reason a caller would ever set it.
// env (#28) is an OPTIONAL passthrough of additional STARCAR_* overrides
// (e.g. STARCAR_GITHUB_REPO/STARCAR_GITHUB_REF) - added on top of, never
// replacing, the port/host/pollMs/storePath overrides every existing caller
// already relies on (backward compatible: omitted, this is a no-op `{}`).
export async function startRealBoardServer({ port, pollMs = 50, storePath, env = {} } = {}) {
  const binPath = buildServerBinary();
  const resolvedPort = port ?? 4700 + (process.pid % 200);

  const child = spawn(binPath, [], {
    cwd: REPO_ROOT,
    env: {
      ...process.env,
      STARCAR_PORT: String(resolvedPort),
      STARCAR_HOST: '127.0.0.1',
      STARCAR_POLL_MS: String(pollMs),
      ...(storePath ? { STARCAR_STORE_PATH: storePath } : {}),
      ...env
    },
    stdio: ['ignore', 'pipe', 'pipe']
  });

  let stderr = '';
  child.stderr.on('data', (d) => (stderr += d.toString()));
  let exited = false;
  child.once('exit', () => {
    exited = true;
  });

  try {
    await waitForHttpReady(resolvedPort, 15000);
  } catch (err) {
    throw new Error(`${err.message}\nchild stderr so far:\n${stderr}`);
  }
  if (exited) {
    throw new Error(`board server process exited before becoming ready. stderr:\n${stderr}`);
  }

  return {
    port: resolvedPort,
    baseUrl: `http://127.0.0.1:${resolvedPort}`,
    getStderr: () => stderr,
    async stop() {
      if (exited) return;
      child.kill();
      await new Promise((resolve) => {
        const t = setTimeout(resolve, 3000); // do not hang the suite forever on a stuck process
        child.once('exit', () => {
          clearTimeout(t);
          resolve();
        });
      });
    }
  };
}
