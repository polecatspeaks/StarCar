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
import { mkdtempSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import http from 'node:http';

// board/web/test/support/real-board-server.js -> repo root is 4 levels up.
const REPO_ROOT = fileURLToPath(new URL('../../../../', import.meta.url));
const BOARD_DIR = join(REPO_ROOT, 'board');

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
export async function startRealBoardServer({ port, pollMs = 50 } = {}) {
  const binPath = buildServerBinary();
  const resolvedPort = port ?? 4700 + (process.pid % 200);

  const child = spawn(binPath, [], {
    cwd: REPO_ROOT,
    env: {
      ...process.env,
      STARCAR_PORT: String(resolvedPort),
      STARCAR_HOST: '127.0.0.1',
      STARCAR_POLL_MS: String(pollMs)
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
