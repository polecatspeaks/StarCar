// browser-register-cascade.test.js - issue #33: closes the class of defect
// behind issue #31, which board/web/test/register-css.test.js (a regex
// over board.css's TEXT) cannot see by construction - minidom.js (this
// suite's hand-rolled DOM shim) has no CSS engine, so #31 passed every one
// of the 50 tests that existed the day it shipped and was only caught by a
// human eye at first light.
//
// This test drives a REAL browser (the playwright LIBRARY - never
// `@playwright/test`, so this stays inside plain `node --test`, one runner,
// one command - the owner's binding amendment on #33) against the REAL
// board/server/ Go binary reading the REAL repo artifacts/ store (never a
// mock, never a static fixture page - the amendment's second and third
// constraints). A cascade question is settled by MEASUREMENT: getComputedStyle
// after the browser has actually resolved CSS inheritance, never by reading
// stylesheet text.
//
// Non-vacuity of this guard was PROVEN by fault injection (Car 33 report):
// with `color: var(--nominal);` removed from `.register-nominal`
// (board/web/css/board.css), this test's second assertion went RED,
// quoting the observed (wrong) computed color; with it restored
// byte-identical, green again. A SECOND injection - replacing that
// declaration with `color: inherit;` - also went RED here while
// register-css.test.js's regex stays GREEN (its `/(?<!-)\bcolor\s*:/`
// pattern matches the literal text "color: inherit" without knowing what a
// browser resolves it to) - issue #35's argument for this test's existence,
// made concrete.
//
// #29 UPDATE (2026-07-26): this test used to rely on the AMBIENT repo
// artifacts/ store reading "stale" forever, on the premise that its
// committed records only get OLDER relative to "now". Issue #29 makes
// "stale" require something IN FLIGHT, never just old data (a yard where
// everything has already returned is "idle"/calm, not "stale"/hot) - and a
// repo-wide scan of this repo's OWN artifacts/ store found every one of its
// subjects has already returned (zero in flight), which #29's fix makes a
// PERMANENT idle state for this committed snapshot, not a transient one.
// The ambient-staleness premise is gone by construction. This test now uses
// buildScratchStoreWithInFlightDispatch (real-board-server.js): a scratch
// copy of the SAME real committed records, byte-identical, plus one
// additional genuinely in-flight dispatched fixture - still the real Go
// binary, the real board/web static files, a real browser resolving real
// CSS (the #33 amendment's actual constraints), just no longer dependent on
// this repo's dispatch history staying empty forever.
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { chromium } from 'playwright';
import { startRealBoardServer, buildScratchStoreWithInFlightDispatch } from './support/real-board-server.js';

let server;
let browser;
let page;

before(async () => {
  server = await startRealBoardServer({ storePath: buildScratchStoreWithInFlightDispatch() });
  browser = await chromium.launch();
  page = await browser.newPage();
  await page.goto(`${server.baseUrl}/`);
  // The scratch store's seeded in-flight dispatch (2020-01-01, no
  // returned/presumed-lost successor) guarantees the live lanes resolve
  // "stale" -> register-needs-attention (compose.js's mostSevereRegister)
  // regardless of what date this test runs on or how this repo's own
  // dispatch history evolves - the exact #31 shape (a needs-attention lane
  // containing per-item nominal rows) requires no ambient-store assumption.
  await page.waitForSelector('.lane-dispatches .solari-row.register-nominal', { timeout: 15000 });
});

after(async () => {
  if (browser) await browser.close();
  if (server) await server.stop();
});

test('the real board (real Go server, real artifacts/ store) serves board.css and it actually loads', async () => {
  const cssHref = await page.$eval('link[rel="stylesheet"]', (el) => el.getAttribute('href'));
  assert.equal(cssHref, '/css/board.css');

  const cssResponse = await page.evaluate(async (href) => {
    const res = await fetch(href);
    return { status: res.status, text: await res.text() };
  }, cssHref);

  assert.equal(cssResponse.status, 200, 'expected the real server to serve board.css with a 200');
  assert.match(cssResponse.text, /\.register-nominal/, 'expected the real served CSS to contain the .register-nominal rule');
});

test("issue #31: a nominal-register dispatch row inside a needs-attention-registered lane renders the lane's own nominal color, never the lane's inherited register color", async () => {
  // Ground truth for what "nominal" and "needs-attention" actually render
  // as is read from the LIVE stylesheet via free-floating probe elements
  // appended directly to <body> (no lane ancestor to inherit a wrong color
  // from) - never a hardcoded hex-to-rgb translation maintained a second
  // time in this test file (Law 6).
  const observed = await page.evaluate(() => {
    function probeColor(className) {
      const el = document.createElement('span');
      el.className = className;
      document.body.appendChild(el);
      const color = getComputedStyle(el).color;
      el.remove();
      return color;
    }
    const lane = document.querySelector('.lane-dispatches');
    const row = document.querySelector('.lane-dispatches .solari-row.register-nominal');
    return {
      laneClassList: lane ? lane.className : null,
      laneIsNeedsAttention: lane ? lane.classList.contains('register-needs-attention') : false,
      rowClassList: row ? row.className : null,
      rowColor: row ? getComputedStyle(row).color : null,
      nominalProbeColor: probeColor('register-nominal'),
      needsAttentionProbeColor: probeColor('register-needs-attention')
    };
  });

  assert.equal(
    observed.laneIsNeedsAttention,
    true,
    `test precondition not met: expected .lane-dispatches to carry register-needs-attention (observed classes: ` +
      `'${observed.laneClassList}') - the scratch store's seeded in-flight dispatch (buildScratchStoreWithInFlightDispatch, ` +
      `dated 2020-01-01, no returned/presumed-lost successor) should always resolve "stale" under #29's rules. If this ` +
      `fails, the #31 REPRODUCTION did not occur this run (an infrastructure/precondition problem), not the fix.`
  );
  assert.notEqual(
    observed.rowColor,
    null,
    `expected to find .lane-dispatches .solari-row.register-nominal - none was found (observed row classes: ` +
      `'${observed.rowClassList}')`
  );

  assert.equal(
    observed.rowColor,
    observed.nominalProbeColor,
    `issue #31: the nominal dispatch row (classes '${observed.rowClassList}') computed color ${observed.rowColor}, ` +
      `but board.css's own .register-nominal rule renders as ${observed.nominalProbeColor} when nothing overrides ` +
      `it. The row is inheriting color from its needs-attention lane ancestor (which renders ` +
      `${observed.needsAttentionProbeColor}) instead of declaring its own.`
  );
  assert.notEqual(
    observed.rowColor,
    observed.needsAttentionProbeColor,
    'issue #31: the nominal row rendered the SAME color as needs-attention - the exact register-bleed this test guards against.'
  );
});
