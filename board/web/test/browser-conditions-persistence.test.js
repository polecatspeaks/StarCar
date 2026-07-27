// browser-conditions-persistence.test.js (#69/#71 fix cycle round 2,
// MAJOR-R1-2) - closes the exact gap the reviewer named: deleting app.js's
// single wiring line (`root.addEventListener('toggle', handleConditionToggle,
// true)`) left the pre-fix suite at 200/200 GREEN, so the owner-reported
// defect ("closes back up every page refresh") could regress silently with
// CI passing. Follows board/web/test/browser-register-cascade.test.js's own
// pattern (#33's binding amendment): a REAL browser (playwright the
// LIBRARY, never `@playwright/test`, so this stays inside plain `node
// --test`) against the REAL board/server/ Go binary reading a REAL scratch
// store (never a mock, never a static fixture page) - the same reasons #33
// gives for why a DOM-shim test (dom-writer.test.js's #69 block, which
// fault-injects the PURE render logic directly and cannot see whether
// app.js actually WIRES the listener at all) cannot catch this class.
//
// buildScratchStoreUnderRepoRootWithConditionsAndSuperseded (not
// buildScratchStoreWithInFlightDispatch/tmpdir-based) is reused here purely
// for its already-seeded board-condition group - this test does not
// exercise its recordDir/link half at all (board/web/verify-conditions-
// persistence.mjs already covers that visually); it is reused rather than
// building a third near-identical scratch-store helper (Law 6).
//
// NON-VACUITY, measured by THIS car (fix cycle round 2 report quotes the
// observed failure verbatim): with app.js:148's addEventListener line
// removed, this file's first test goes RED at the "after real click"
// assertion - opening never persists because no listener ever reacts to
// the click event at all - proving the regression pin actually depends on
// the wiring this ticket was asked to guard, restored byte-identical
// afterward.
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { chromium } from 'playwright';
import {
  startRealBoardServer,
  buildScratchStoreUnderRepoRootWithConditionsAndSuperseded,
  addRecordToStore
} from './support/real-board-server.js';

let server;
let browser;
let page;
let storeDir;
let cleanup;

before(async () => {
  ({ storeDir, cleanup } = buildScratchStoreUnderRepoRootWithConditionsAndSuperseded());
  server = await startRealBoardServer({ storePath: storeDir });
  browser = await chromium.launch();
  page = await browser.newPage();
  await page.goto(`${server.baseUrl}/`);
  await page.waitForSelector('.board-conditions-strip', { timeout: 15000 });
  // ATTACHED, not the default VISIBLE state - a <details> element's own
  // children are legitimately invisible (not "hidden" in the CSS sense, but
  // Playwright treats a closed <details>'s non-summary content as not
  // visible) while collapsed, which this group's <details> starts as.
  await page.waitForSelector('.board-condition-group-details', { state: 'attached', timeout: 15000 });
});

after(async () => {
  if (browser) await browser.close();
  if (server) await server.stop();
  if (cleanup) cleanup();
});

async function readOpenState(p) {
  return p.evaluate(() => ({
    stripOpen: document.querySelector('.board-conditions-strip')?.hasAttribute('open') ?? null,
    groupOpen: document.querySelector('.board-condition-group-details')?.hasAttribute('open') ?? null
  }));
}

test("#69 MAJOR-R1-2: opening the strip+group via a REAL click (app.js's wired toggle listener) persists across a real poll-driven DOM rebuild, never a reload", async () => {
  const before_ = await readOpenState(page);
  assert.equal(before_.stripOpen, false, 'precondition: the strip must start collapsed');
  assert.equal(before_.groupOpen, false, 'precondition: the group must start collapsed');

  // A REAL click, dispatched by the browser itself (never
  // element.setAttribute('open', '') from the test - that would bypass the
  // native 'toggle' event and app.js's listener entirely, proving nothing
  // about the wiring this fix cycle guards).
  await page.click('.board-conditions-strip > summary');
  await page.click('.board-condition-group-details > summary');
  await page.waitForTimeout(50);

  const afterClick = await readOpenState(page);
  assert.equal(
    afterClick.stripOpen,
    true,
    "expected a real click on the strip summary to open it via app.js's wired toggle listener - if this is false, " +
      'either the listener was never attached or handleConditionToggle failed to persist the strip flag'
  );
  assert.equal(
    afterClick.groupOpen,
    true,
    "expected a real click on the group summary to open it via app.js's wired toggle listener"
  );

  // Force a REAL DOM rebuild with no reload: a new record is a genuine
  // poll-detected change (seq bumps), pushing a fresh SSE frame that drives
  // app.js's repaint() - a real root.textContent = '' teardown and rebuild,
  // never a synthetic re-render call from this test.
  addRecordToStore(storeDir, 'view-69-71-r2-rebuild-probe', 'view-69-71-r2-second-discovery', '2026-07-20T09:45:00Z');
  await page.waitForTimeout(400); // several poll intervals (server started with the small test pollMs)

  const afterRebuild = await readOpenState(page);
  assert.equal(
    afterRebuild.stripOpen,
    true,
    'REGRESSION (#69 MAJOR-R1-2): the strip closed across a real DOM rebuild - this is exactly what deleting ' +
      "app.js's addEventListener('toggle', ...) line produces, since repaint() would then rebuild the DOM from a " +
      'default (collapsed) openState with nothing to reopen it'
  );
  assert.equal(
    afterRebuild.groupOpen,
    true,
    'REGRESSION (#69 MAJOR-R1-2): the condition group closed across a real DOM rebuild'
  );
});

test('#69 MAJOR-R1-2: open state survives a real page.reload() too', async () => {
  // Continues from the previous test's in-page state (both already opened
  // and already survived one rebuild) - this test's OWN job is only the
  // reload half, so it does not re-open anything itself.
  await page.reload();
  await page.waitForSelector('.board-conditions-strip', { timeout: 15000 });
  await page.waitForSelector('.board-condition-group-details', { state: 'attached', timeout: 15000 });
  await page.waitForTimeout(150);

  const afterReload = await readOpenState(page);
  assert.equal(
    afterReload.stripOpen,
    true,
    "REGRESSION (#69, the owner's own live-board finding): the strip closed on page reload - sessionStorage " +
      'either was never written to, or app.js never read it back on repaint()'
  );
  assert.equal(afterReload.groupOpen, true, 'REGRESSION (#69): the condition group closed on page reload');
});
