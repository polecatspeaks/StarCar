// browser-dispatch-row-geometry.test.js (#69/#71 fix cycle round 3,
// MAJOR-R2-1) - the ONLY test in this repo that asserts RENDERED GEOMETRY
// for the dispatches lane. Round 2's MAJOR-R1-1 fix added `flex-wrap: wrap`
// to `.solari-row` on the (measured false) theory that only the nested
// disclosure - never the subject/state/elapsed cluster - would drop to a
// second line. Real Chromium measurement (round 2 review) showed EVERY
// dispatch row going from one visual line to two, including rows with no
// disclosure at all, re-introducing the #62 "crop rows mid-line" hazard
// board.css's own pre-existing comment names. Nothing else under
// board/web/test/ can catch this class: createMiniDocument() (dom-writer.
// test.js) has no layout engine, and browser-conditions-persistence.test.js
// never touches the dispatches lane. This file follows browser-register-
// cascade.test.js's pattern (#33): playwright the LIBRARY inside plain
// `node --test`, a real board/server/ Go binary, a real scratch store.
//
// A NARROW viewport (500px) forces .solari-rows' auto-fill grid to a
// single column, so every row stacks in strict vertical order with no
// shared grid-row-band height stretching between unrelated rows - a row's
// own top/height changes are attributable ONLY to that row's own content,
// never to a neighbour expanding in the same grid line.
//
// NON-VACUITY: this car ran this file's first test at HEAD 2861bfd (before
// the CSS fix) and observed it RED for the reviewer's own stated reason;
// see the fix cycle round 3 report for the quoted failure. Restored to
// green by removing `flex-wrap: wrap` from `.solari-row` and moving the
// subject/state/elapsed cluster into its own `.solari-row-main` wrapper
// (a column-direction `.solari-row` stacks that wrapper above the
// disclosure without ever placing flex-wrap on the single-line cluster).
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { chromium } from 'playwright';
import { startRealBoardServer, buildScratchStoreForDispatchRowGeometry } from './support/real-board-server.js';

let server;
let browser;
let page;

before(async () => {
  server = await startRealBoardServer({ storePath: buildScratchStoreForDispatchRowGeometry() });
  browser = await chromium.launch();
  page = await browser.newPage({ viewport: { width: 340, height: 1000 } });
  await page.goto(`${server.baseUrl}/`);
  await page.waitForSelector('.solari-row', { timeout: 15000 });
  await page.waitForSelector('.solari-superseded-disclosure', { timeout: 15000 });
});

after(async () => {
  if (browser) await browser.close();
  if (server) await server.stop();
});

async function measureRows() {
  return page.evaluate(() => {
    const container = document.querySelector('.solari-rows');
    const containerRect = container.getBoundingClientRect();
    const rows = [...container.querySelectorAll('.solari-row')].map((row) => {
      const rect = row.getBoundingClientRect();
      // The content cluster a reader scans left-to-right on one line
      // (mockup convention): subject, state word, elapsed - queried by
      // CONTENT class, never by DOM depth, so this measurement stays valid
      // regardless of which wrapper element currently holds them.
      const contentEls = [...row.querySelectorAll('.solari-subject, .solari-state, .solari-elapsed')];
      const contentTops = [...new Set(contentEls.map((el) => Math.round(el.getBoundingClientRect().top)))];
      return {
        subject: row.querySelector('.solari-subject')?.textContent.trim(),
        // Position WITHIN the container's own content flow, not the raw
        // viewport top - .solari-rows scrolls internally (overflow-y:auto)
        // and Playwright's click() auto-scrolls that container to bring a
        // target into view, which would otherwise translate every row's
        // viewport rect by the scroll delta and falsely look like every
        // row "moved". Adding scrollTop back out cancels that translation.
        top: Math.round(rect.top - containerRect.top + container.scrollTop),
        height: Math.round(rect.height),
        hasDisclosure: !!row.querySelector('.solari-superseded-disclosure'),
        distinctContentTopCount: contentTops.length,
        croppedMidRow: rect.top < containerRect.bottom && rect.bottom > containerRect.bottom
      };
    });
    return {
      containerClientHeight: container.clientHeight,
      containerScrollHeight: container.scrollHeight,
      rows
    };
  });
}

test('#71 fix cycle r3 (MAJOR-R2-1): a dispatch row with NO superseded entry renders its subject/state/elapsed cluster on ONE visual line', async () => {
  const { rows } = await measureRows();
  const plainRows = rows.filter((r) => !r.hasDisclosure);
  assert.ok(plainRows.length >= 7, `test precondition not met: expected >=7 plain rows, got ${plainRows.length}`);
  for (const row of plainRows) {
    assert.equal(
      row.distinctContentTopCount,
      1,
      `REGRESSION (MAJOR-R2-1): row '${row.subject}' (no disclosure) spans ${row.distinctContentTopCount} visual lines for its ` +
        `subject/state/elapsed cluster - expected exactly 1 (one line per row, the mockup convention #62/#67 depend on)`
    );
    assert.ok(
      row.height <= 30,
      `REGRESSION (MAJOR-R2-1): row '${row.subject}' (no disclosure) height is ${row.height}px, expected <=30px ` +
        `(single-line row height) - a taller row means the cluster wrapped even though distinctContentTopCount looked like 1`
    );
  }
});

test('#71 fix cycle r3 (MAJOR-R2-1): zero PLAIN rows (no superseded entry) cross .solari-rows own clientHeight boundary mid-row', async () => {
  // Scoped to rows with NO disclosure - mirrors the round-2 reviewer's own
  // falsifying fixture (14 plain subjects, none carrying superseded, "so
  // the disclosure itself cannot be blamed"). A row WITH a disclosure is
  // legitimately taller by design (#69/#71-M1) and can overflow this box
  // on its own merits - that is the disclosed, tracked #1 scrolling
  // behaviour this file's own board.css comment names, never this ticket's
  // regression. The regression this test guards is specifically: does
  // .solari-row's OWN one-line rendering (never the disclosure) grow, and
  // does that growth shift where a PLAIN row's boundary falls.
  const { containerClientHeight, containerScrollHeight, rows } = await measureRows();
  assert.ok(
    containerScrollHeight > containerClientHeight,
    `test precondition not met: expected .solari-rows to overflow (scrollHeight ${containerScrollHeight} > clientHeight ` +
      `${containerClientHeight}) so a mid-row crop has somewhere to happen`
  );
  const cropped = rows.filter((r) => !r.hasDisclosure && r.croppedMidRow);
  assert.equal(
    cropped.length,
    0,
    `REGRESSION (MAJOR-R2-1): ${cropped.length} plain row(s) crop mid-row at .solari-rows' own boundary - ${JSON.stringify(cropped)}`
  );
});

test('#71 fix cycle r3 (MAJOR-R2-1): expanding one row\'s disclosure grows ONLY that row - every other row keeps its own height and rows above it keep their own top', async () => {
  const before_ = await measureRows();
  const targetSubject = before_.rows.find((r) => r.hasDisclosure)?.subject;
  assert.ok(targetSubject, 'test precondition not met: expected at least one row with a disclosure');
  const targetIndexBefore = before_.rows.findIndex((r) => r.subject === targetSubject);

  await page.click(`.solari-row:has(.solari-subject:text-is("${targetSubject}")) .solari-superseded-disclosure > summary`);
  await page.waitForTimeout(100);

  const after_ = await measureRows();
  assert.ok(after_.rows[targetIndexBefore].height > before_.rows[targetIndexBefore].height, 'expected the expanded row itself to grow taller');

  for (let i = 0; i < before_.rows.length; i += 1) {
    if (i === targetIndexBefore) continue;
    assert.equal(
      after_.rows[i].height,
      before_.rows[i].height,
      `REGRESSION: row '${before_.rows[i].subject}' changed height (${before_.rows[i].height} -> ${after_.rows[i].height}) ` +
        `when a DIFFERENT row's disclosure was expanded`
    );
    if (i < targetIndexBefore) {
      assert.equal(
        after_.rows[i].top,
        before_.rows[i].top,
        `REGRESSION: row '${before_.rows[i].subject}' (above the expanded row) shifted position ` +
          `(${before_.rows[i].top} -> ${after_.rows[i].top})`
      );
    }
  }
});
