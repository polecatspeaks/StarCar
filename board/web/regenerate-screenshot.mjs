// regenerate-screenshot.mjs - issue #33, Task 3. EXPLICIT, SEPARATELY
// INVOKED action: `node board/web/regenerate-screenshot.mjs` from a repo
// checkout with `npm install` already run in board/web/. This is NOT part
// of `node --test` (it lives outside test/, so node's test-file discovery
// never picks it up) and it never runs as a side effect of the test suite -
// a suite that rewrites a committed binary on every run creates churn and
// a permanently dirty worktree (the brief's own reasoning for keeping this
// separate).
//
// Reuses test/support/real-board-server.js - the SAME real-server launcher
// the browser regression test uses (Law 6: one hand-rolled "start the real
// server" implementation, not two). Screenshots the REAL board (real Go
// server, real artifacts/ store), never a mock.
//
// Takes NO assertion on the image (the owner's binding amendment: screenshot
// REGENERATION only, never pixel diffing - windows-latest and ubuntu-latest
// rasterise fonts differently, so a pixel-diff assertion would fail across
// CI legs for reasons unrelated to correctness).
import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { startRealBoardServer } from './test/support/real-board-server.js';

const REPO_ROOT = fileURLToPath(new URL('../../', import.meta.url));
const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD, real wall-clock date

// Deliberately does NOT default to overwriting the existing
// docs/screenshots/2026-07-23-first-light.png (the brief: "do not commit a
// regenerated screenshot unless it is genuinely more current than the
// existing one"). An operator who has looked at both images and decided
// the new one belongs in the repo passes --out explicitly; otherwise this
// writes a dated scratch file that is easy to diff by eye and just as easy
// to discard.
const outArg = process.argv.find((a) => a.startsWith('--out='));
const outPath = outArg
  ? join(REPO_ROOT, outArg.slice('--out='.length))
  : join(REPO_ROOT, 'docs', 'screenshots', `${today}-regenerated-candidate.png`);

mkdirSync(dirname(outPath), { recursive: true });

const server = await startRealBoardServer();
const browser = await chromium.launch();
try {
  const page = await browser.newPage({ viewport: { width: 1400, height: 1000 } });
  await page.goto(`${server.baseUrl}/`);
  // Wait for real polled data to render (the same signal the regression
  // test waits on) so the screenshot shows the actual board, not the
  // pre-first-poll "loading" skeleton.
  await page.waitForSelector('.lanes .lane', { timeout: 15000 });
  await page.screenshot({ path: outPath, fullPage: true });
  console.log(`Screenshot written to ${outPath}`);
  console.log('This is a CANDIDATE, not committed automatically - compare it by eye against the ' +
    'existing docs/screenshots/ image before deciding to replace it, and say so in the commit that does.');
} finally {
  await browser.close();
  await server.stop();
}
