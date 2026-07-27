// verify-lane-filters.mjs - #67. EXPLICIT, SEPARATELY INVOKED dev tool
// (`node board/web/verify-lane-filters.mjs [--out-dir=path]` from a repo
// checkout with `npm ci` already run in board/web/), same convention as its
// siblings verify-registers.mjs / regenerate-screenshot.mjs: lives outside
// test/ so node's test-file discovery never picks it up.
//
// THE #40 RENDERING-CHECK FLOOR this script exists to satisfy: computed-
// style/DOM evidence from a REAL browser against the REAL Go server and a
// real scratch store (never a hand-rolled DOM shim, never a text-level
// assertion) for #67's three claims:
//   (a) a hot row beyond the cap boundary still renders (dispatches AND
//       trains lanes);
//   (b) the honesty summary line renders with true counts;
//   (c) a duration renders in the new compact-clock format.
//
// Reuses the SAME real-server launcher + fixture builder
// board/web/test/support/real-board-server.js already provides (Law 6: one
// hand-rolled "start the real server" implementation, one lane-filter
// fixture builder, shared by this script and any future regression test
// that wants the same scratch store).
import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import { startRealBoardServer, buildScratchStoreWithLaneFilterFixtures } from './test/support/real-board-server.js';

const REPO_ROOT = fileURLToPath(new URL('../../', import.meta.url));
const today = new Date().toISOString().slice(0, 10);

const outArg = process.argv.find((a) => a.startsWith('--out-dir='));
const outDir = outArg
  ? join(REPO_ROOT, outArg.slice('--out-dir='.length))
  : join(REPO_ROOT, 'docs', 'screenshots', `${today}-view-67-candidates`);

mkdirSync(outDir, { recursive: true });

async function probeLaneFilterEvidence(page) {
  return page.evaluate(() => {
    function textOf(selector) {
      const el = document.querySelector(selector);
      return el ? el.textContent : null;
    }
    const dispatchesLane = document.querySelector('.lane-dispatches');
    const trainsLane = document.querySelector('.lane-trains');

    const solariRows = [...document.querySelectorAll('.solari-row')].map((row) => ({
      text: row.textContent,
      className: row.className
    }));
    const tracks = [...document.querySelectorAll('.track')].map((track) => track.querySelector('.track-title')?.textContent ?? null);

    const dispatchesSummary = dispatchesLane?.querySelector('.history-summary') ?? null;
    const trainsSummary = trainsLane?.querySelector('.history-summary') ?? null;

    const elapsedEls = [...document.querySelectorAll('.solari-elapsed')];

    return {
      solariRowCount: solariRows.length,
      solariRows,
      trackCount: tracks.length,
      tracks,
      dispatchesHistorySummaryText: dispatchesSummary ? dispatchesSummary.textContent : null,
      dispatchesHistorySummaryClass: dispatchesSummary ? dispatchesSummary.className : null,
      dispatchesHistorySummaryColor: dispatchesSummary ? getComputedStyle(dispatchesSummary).color : null,
      trainsHistorySummaryText: trainsSummary ? trainsSummary.textContent : null,
      trainsHistorySummaryClass: trainsSummary ? trainsSummary.className : null,
      elapsedTexts: elapsedEls.map((el) => el.textContent),
      dispatchesLaneText: textOf('.lane-dispatches'),
      trainsLaneText: textOf('.lane-trains')
    };
  });
}

const browser = await chromium.launch();
try {
  const server = await startRealBoardServer({ storePath: buildScratchStoreWithLaneFilterFixtures() });
  try {
    const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
    await page.goto(`${server.baseUrl}/`);
    await page.waitForSelector('.lanes .lane', { timeout: 15000 });
    await page.waitForTimeout(150); // let CSS settle before the screenshot
    const outPath = join(outDir, 'lane-filters.png');
    await page.screenshot({ path: outPath, fullPage: true });
    const evidence = await probeLaneFilterEvidence(page);
    console.log(`\n=== lane-filters -> ${outPath} ===`);
    console.log(JSON.stringify(evidence, null, 2));
  } finally {
    await server.stop();
  }
  console.log(`\nScreenshot + evidence written to ${outDir}`);
  console.log('This is evidence for a human/reviewer to read, never a pass/fail gate - see ' +
    'board/web/test/render.test.js and board/web/test/dom-writer.test.js for the landed regression guards.');
} finally {
  await browser.close();
}
