// browser-dispatch-row-taskid.test.js (#75) - RENDERED-SURFACE proof that
// the task-id fallback treatment is real in a browser, not just a passing
// minidom.js unit test (minidom.js has no CSS engine, so it cannot prove a
// task-id wider than its own box still gets .solari-subject's ellipsis
// truncation, and it cannot prove board.css's `title` attribute actually
// renders as a native hover tooltip). Follows browser-dispatch-row-
// geometry.test.js's pattern (#71 fix cycle r3): playwright the LIBRARY
// inside plain `node --test`, a real board/server/ Go binary, a real
// scratch store.
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { chromium } from 'playwright';
import { startRealBoardServer, buildScratchStoreForTaskIdTitles } from './support/real-board-server.js';

let server;
let browser;
let page;

before(async () => {
  server = await startRealBoardServer({ storePath: buildScratchStoreForTaskIdTitles() });
  browser = await chromium.launch();
  page = await browser.newPage({ viewport: { width: 1024, height: 900 } });
  await page.goto(`${server.baseUrl}/`);
  await page.waitForSelector('.solari-row', { timeout: 15000 });
  await page.waitForSelector('.car-chip', { timeout: 15000 });
});

after(async () => {
  if (browser) await browser.close();
  if (server) await server.stop();
});

async function dispatchRowBySubjectHash(subjectHash) {
  return page.evaluate((hash) => {
    const el = [...document.querySelectorAll('.solari-subject')].find((n) => n.getAttribute('title') === hash);
    if (!el) return null;
    const style = getComputedStyle(el);
    return {
      textContent: el.textContent,
      title: el.getAttribute('title'),
      overflow: style.overflow,
      textOverflow: style.textOverflow,
      // fix cycle r2 (R1-m2), corrected fix cycle r3 (R2-m1: this used to
      // say "length-dependent" - measurement showed it is BOX-width-
      // dependent, not length-dependent, since even a 14-char id overflows
      // this fixture's narrow box): scrollWidth > clientWidth is the
      // GENUINE overflow signal - overflow/text-overflow being computed
      // correctly is necessary but not sufficient (an id short enough to
      // fit never actually truncates even with both properties set).
      scrollWidth: el.scrollWidth,
      clientWidth: el.clientWidth
    };
  }, subjectHash);
}

async function carChipBySubjectHash(subjectHash) {
  return page.evaluate((hash) => {
    const el = [...document.querySelectorAll('.car-subject')].find((n) => n.getAttribute('title') === hash);
    if (!el) return null;
    return { textContent: el.textContent, title: el.getAttribute('title') };
  }, subjectHash);
}

test('#75: a dispatch row whose winning record carries task_id shows the task-id as its VISIBLE text in a real browser, subject hash reachable only via the title tooltip', async () => {
  const row = await dispatchRowBySubjectHash('view-75-with-task-id');
  assert.ok(row, 'expected a .solari-subject element whose title attribute is the record-dir hash subject "view-75-with-task-id"');
  assert.equal(
    row.textContent,
    'view-75-extremely-long-human-task-id-handle-for-the-fix-cycle-r2-ellipsis-check',
    'REGRESSION (#75): the visible dispatch row title must be the task-id, not the hash'
  );
  assert.equal(row.title, 'view-75-with-task-id', 'the full subject hash must stay reachable via the native title tooltip');
});

test('#75: a dispatch row whose winning record carries NO task_id falls back honestly to the subject hash as its visible text, real browser', async () => {
  const row = await dispatchRowBySubjectHash('view-75-without-task-id');
  assert.ok(row, 'expected a .solari-subject element whose title attribute is the record-dir hash subject "view-75-without-task-id"');
  assert.equal(row.textContent, 'view-75-without-task-id', 'REGRESSION (#75, Law 1): no wire taskId must render as the honest hash fallback, never an invented label');
  assert.equal(row.title, 'view-75-without-task-id');
});

// CORRECTED, fix cycle r3 (R2-m1: R1-m2 was ruled DRIFTED, not closed - the
// substance never moved). This test used to be named for a "GENUINELY long
// (79 chars)" task-id, on the theory that LENGTH is what makes it overflow
// and truncate. Measured, out of repo, by the round-2 reviewer and
// reproduced here: `.solari-subject`'s own box in this fixture's viewport is
// only ~123px wide (a 13rem `auto-fill` grid column) - round-1's ORIGINAL
// 14-char id (`view-75-car-r1`) ALSO overflows it (scrollWidth 131 vs
// clientWidth 123) and would ALSO pass this assertion. The box is narrow
// enough that virtually any plausible task-id overflows it; length is not
// the discriminating variable, and the old name promised a distinction this
// fixture cannot construct (a short id that fits). Renamed to what the test
// actually proves: a task-id wider than its own box truncates via ellipsis
// rather than wrapping.
test('#75: a task-id wider than .solari-subject\'s own (narrow) box truncates via ellipsis rather than wrapping - real overflow, not just computed style', async () => {
  const row = await dispatchRowBySubjectHash('view-75-with-task-id');
  assert.ok(row, 'test precondition not met');
  assert.equal(row.overflow, 'hidden', 'REGRESSION (#75): .solari-subject must still compute overflow:hidden for a task-id-titled row');
  assert.equal(row.textOverflow, 'ellipsis', 'REGRESSION (#75): .solari-subject must still compute text-overflow:ellipsis for a task-id-titled row');
  // overflow/text-overflow being computed correctly is necessary but not
  // sufficient - an id short enough to fit inside .solari-subject's own
  // width would compute the identical style while never actually
  // truncating anything. Assert the GENUINE overflow signal too: the
  // element's own content is wider than its box. (This does not prove the
  // fixture's id is exceptionally LONG - see the comment above - only that
  // this specific box's content overflows it, which is the property the
  // ellipsis CSS actually needs to have something to do.)
  assert.ok(
    row.scrollWidth > row.clientWidth,
    `REGRESSION: the fixture's task-id must genuinely overflow .solari-subject's box (scrollWidth ${row.scrollWidth} vs clientWidth ${row.clientWidth}) - otherwise this test cannot tell a truncating id from a merely-computed-style one`
  );
});

test('#75: the trains lane car-chip gets the SAME task-id/fallback treatment as the dispatches lane, real browser', async () => {
  const withTaskId = await carChipBySubjectHash('view-75-chip-car');
  assert.ok(withTaskId, 'expected a .car-subject element whose title attribute is the record-dir hash subject "view-75-chip-car"');
  assert.equal(withTaskId.textContent, 'view-75-chip-r1', 'REGRESSION (#75): the car-chip visible identity must be the task-id when the wire supplies one');
  assert.equal(withTaskId.title, 'view-75-chip-car', 'the full subject hash must stay reachable via the chip\'s title tooltip (new with this ticket - the chip carried no title attribute before #75)');
});

test('#75: a dispatch row\'s one-line-per-row geometry is unaffected by which text (task-id or hash) is visible', async () => {
  // The row's content class (.solari-subject/.solari-state/.solari-elapsed)
  // still shares exactly one visual line even though the VISIBLE text now
  // differs in length/content from the hash it replaces - the same
  // regression browser-dispatch-row-geometry.test.js guards generically,
  // scoped here to the two rows this ticket's fixture actually changes text
  // on.
  const heights = await page.evaluate(() => {
    const rows = [...document.querySelectorAll('.solari-row')].filter((r) => {
      const subj = r.querySelector('.solari-subject');
      return subj && (subj.getAttribute('title') === 'view-75-with-task-id' || subj.getAttribute('title') === 'view-75-without-task-id');
    });
    return rows.map((r) => {
      const contentEls = [...r.querySelectorAll('.solari-subject, .solari-state, .solari-elapsed')];
      const tops = new Set(contentEls.map((el) => Math.round(el.getBoundingClientRect().top)));
      return { title: r.querySelector('.solari-subject').getAttribute('title'), distinctTopCount: tops.size };
    });
  });
  assert.equal(heights.length, 2, `test precondition not met: expected both #75 fixture rows found, got ${JSON.stringify(heights)}`);
  for (const h of heights) {
    assert.equal(h.distinctTopCount, 1, `REGRESSION: row '${h.title}' spans ${h.distinctTopCount} visual lines, expected exactly 1`);
  }
});
