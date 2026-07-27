// verify-conditions-persistence.mjs (#69/#71 rendering check, view train,
// 2026-07-27) - EXPLICIT, SEPARATELY INVOKED dev tool, same convention as
// its sibling verify-registers.mjs: lives outside test/ so node's test-file
// discovery never picks it up, and never runs as a side effect of the test
// suite. Landed rather than thrown away (CLAUDE.md's "NEVER DROP A TOOLING
// REQUEST" - reusable, not fire-and-forget): any future car touching the
// conditions strip's open-state persistence or its provenance links can
// re-run this against its own fixture.
//
// Proves, against the REAL board/server/ Go binary and a REAL browser
// (never a DOM-class assertion, never a mock):
//   1. a board-condition entry (a "discovery") renders as an <a> whose
//      computed color inherits its register - a real getComputedStyle read;
//   2. a superseded entry links to the SAME recordDir as its row's own
//      subject link;
//   3. the conditions strip's (and one group's) open state SURVIVES a real
//      DOM rebuild (a second poll-detected change over the live SSE
//      connection, no page reload) AND a real page.reload().
//
// Takes NO assertion on the image (same posture as verify-registers.mjs):
// this is evidence for a human/reviewer to read. The pass/fail REGRESSION
// guards for the underlying logic are board/web/test/dom-writer.test.js's
// #69/#71 blocks and board/web/test/condition-open-state.test.js (pure
// logic, fault-injected non-vacuous - see this car's report).
import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join } from 'node:path';
import {
  startRealBoardServer,
  buildScratchStoreUnderRepoRootWithConditionsAndSuperseded,
  addRecordToStore
} from './test/support/real-board-server.js';

const REPO_ROOT = fileURLToPath(new URL('../../', import.meta.url));

const outArg = process.argv.find((a) => a.startsWith('--out-dir='));
const outDir = outArg
  ? join(REPO_ROOT, outArg.slice('--out-dir='.length))
  : join(REPO_ROOT, 'docs', 'screenshots', '2026-07-26-view-69-71-candidates');

mkdirSync(outDir, { recursive: true });

const { storeDir, cleanup } = buildScratchStoreUnderRepoRootWithConditionsAndSuperseded();

async function probe(page) {
  return page.evaluate(() => {
    const discoveryInstance = [...document.querySelectorAll('.board-condition-instance')].find((el) =>
      el.textContent.includes('view-69-71-unrecognised-kind')
    );
    const supersededEntry = document.querySelector('.solari-superseded-entry');
    const supersededSubjectLink = document.querySelector('.solari-subject');
    const strip = document.querySelector('.board-conditions-strip');
    return {
      discoveryTag: discoveryInstance ? discoveryInstance.tagName : null,
      discoveryHref: discoveryInstance ? discoveryInstance.getAttribute('href') : null,
      discoveryColor: discoveryInstance ? getComputedStyle(discoveryInstance).color : null,
      registerNominalColor: (() => {
        const probeEl = document.createElement('span');
        probeEl.className = 'register-nominal';
        document.body.appendChild(probeEl);
        const c = getComputedStyle(probeEl).color;
        probeEl.remove();
        return c;
      })(),
      supersededHref: supersededEntry ? supersededEntry.getAttribute('href') : null,
      supersededText: supersededEntry ? supersededEntry.textContent : null,
      subjectHref: supersededSubjectLink ? supersededSubjectLink.getAttribute('href') : null,
      stripOpenBeforeClick: strip ? strip.hasAttribute('open') : null
    };
  });
}

const browser = await chromium.launch();
try {
  const server = await startRealBoardServer({
    storePath: storeDir,
    env: { STARCAR_GITHUB_REPO: 'polecatspeaks/StarCar', STARCAR_GITHUB_REF: 'dev' }
  });
  try {
    const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
    await page.goto(`${server.baseUrl}/`);
    await page.waitForSelector('.board-conditions-strip', { timeout: 15000 });
    await page.waitForSelector('.solari-superseded-entry', { timeout: 15000 });
    await page.waitForTimeout(150);

    const before = await probe(page);
    console.log('\n=== BEFORE any interaction ===');
    console.log(JSON.stringify(before, null, 2));

    await page.screenshot({ path: join(outDir, 'collapsed-before-click.png'), fullPage: false });

    // Open the strip, then open the discovery group inside it.
    await page.click('.board-conditions-strip > summary');
    await page.click('.board-condition-group-details > summary');
    await page.waitForTimeout(50);
    const afterOpen = await page.evaluate(() => ({
      stripOpen: document.querySelector('.board-conditions-strip').hasAttribute('open'),
      groupOpen: document.querySelector('.board-condition-group-details').hasAttribute('open')
    }));
    console.log('\n=== AFTER opening strip + group (in-page click) ===');
    console.log(JSON.stringify(afterOpen, null, 2));
    await page.screenshot({ path: join(outDir, 'expanded-after-click.png'), fullPage: false });

    // Force a REAL DOM rebuild (no reload): add a new record, which the
    // live poll (50ms) will detect as a real seq-bumping change, pushing a
    // new SSE frame that triggers app.js's repaint() - a genuine
    // root.textContent = '' teardown and rebuild.
    addRecordToStore(storeDir, 'view-69-71-rebuild-probe', 'view-69-71-second-discovery', '2026-07-20T09:30:00Z');
    await page.waitForTimeout(400); // several poll intervals at 50ms
    const afterRebuild = await page.evaluate(() => ({
      stripOpen: document.querySelector('.board-conditions-strip').hasAttribute('open'),
      groupOpen: document.querySelector('.board-condition-group-details[data-condition-code="discovery"]')
        ? document.querySelector('.board-condition-group-details[data-condition-code="discovery"]').hasAttribute('open')
        : null,
      groupCount: document.querySelectorAll('.board-condition-group').length
    }));
    console.log('\n=== AFTER a real DOM rebuild (new record, no reload) ===');
    console.log(JSON.stringify(afterRebuild, null, 2));
    await page.screenshot({ path: join(outDir, 'survives-dom-rebuild.png'), fullPage: false });

    // Now a REAL page reload - the other half of #69's claim.
    await page.reload();
    await page.waitForSelector('.board-conditions-strip', { timeout: 15000 });
    await page.waitForTimeout(150);
    const afterReload = await page.evaluate(() => ({
      stripOpen: document.querySelector('.board-conditions-strip').hasAttribute('open'),
      groupOpen: document.querySelector('.board-condition-group-details[data-condition-code="discovery"]')
        ? document.querySelector('.board-condition-group-details[data-condition-code="discovery"]').hasAttribute('open')
        : null
    }));
    console.log('\n=== AFTER page.reload() ===');
    console.log(JSON.stringify(afterReload, null, 2));
    await page.screenshot({ path: join(outDir, 'survives-page-reload.png'), fullPage: false });

    console.log(`\nScreenshots + computed-style evidence written to ${outDir}`);
  } finally {
    await server.stop();
  }
} finally {
  await browser.close();
  cleanup();
}
