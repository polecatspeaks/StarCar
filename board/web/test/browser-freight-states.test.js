// browser-freight-states.test.js (#84) - the non-vacuity mandate: freight's
// three absence/staleness states (Law 1 - "never run" must not read as "ran,
// empty"), each driven through a REAL browser against the REAL board/server/
// Go binary and a REAL scratch store (never a mock, never a static fixture
// page - the #33 amendment this repo's other browser-*.test.js files already
// follow). Each test spins its OWN server+store, since the three cases are
// fundamentally different fixture content, not one shared scratch store.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { rmSync } from 'node:fs';
import { chromium } from 'playwright';
import {
  startRealBoardServer,
  buildScratchStoreFreightNeverPolled,
  buildScratchStoreFreightFreshEmpty,
  buildScratchStoreFreightStale,
  buildScratchStoreFreightTicketsWithoutHeartbeat
} from './support/real-board-server.js';

async function readFreightLane(page) {
  return page.evaluate(() => {
    const lanes = [...document.querySelectorAll('.lane')];
    const freight = lanes.find((l) => l.querySelector('.lane-title')?.textContent === 'Freight');
    if (!freight) return null;
    return {
      primary: freight.querySelector('.lane-primary')?.textContent ?? null,
      secondary: freight.querySelector('.lane-secondary')?.textContent ?? null,
      registerClass: [...freight.classList].find((c) => c.startsWith('register-')) ?? null,
      emptyText: freight.querySelector('.lane-body-freight-empty')?.textContent ?? null,
      rows: [...freight.querySelectorAll('.freight-row')].map((r) => ({
        number: r.querySelector('.freight-number')?.textContent,
        title: r.querySelector('.freight-title')?.textContent,
        status: r.querySelector('.freight-status')?.textContent
      }))
    };
  });
}

// #84 fix cycle round 2: reads the board-conditions strip's raw text (#30's
// grouped chrome, expanded via <details open> so per-instance text is
// present in the DOM without a click) - used by the R1-M2 regression below
// to prove the freight-tickets-without-heartbeat condition is genuinely
// user-visible, not just present in the wire payload.
async function readBoardConditionsText(page) {
  return page.evaluate(() => document.querySelector('.board-conditions-strip')?.textContent ?? '');
}

test('#84 Case 1 (NEVER RUN): freight reads "not yet polled", never "the queue is empty"', async () => {
  const server = await startRealBoardServer({ storePath: buildScratchStoreFreightNeverPolled() });
  const browser = await chromium.launch();
  try {
    const page = await browser.newPage();
    await page.goto(`${server.baseUrl}/`);
    await page.waitForSelector('.lane', { timeout: 15000 });
    // Wait for the freight lane specifically to reach its post-poll state
    // (never-polled becomes visible only after at least one real
    // StoreAdapter.Scan has run through PollOnce).
    await page.waitForFunction(
      () => {
        const lanes = [...document.querySelectorAll('.lane')];
        const freight = lanes.find((l) => l.querySelector('.lane-title')?.textContent === 'Freight');
        return freight && freight.querySelector('.lane-secondary')?.textContent === 'not yet polled';
      },
      { timeout: 15000 }
    );
    const freight = await readFreightLane(page);
    assert.ok(freight, 'test precondition not met: no lane titled Freight found in the rendered DOM');
    assert.equal(freight.secondary, 'not yet polled', `OBSERVED freight secondary line: ${JSON.stringify(freight)}`);
    assert.equal(freight.emptyText, 'no tickets in the queue');
    assert.equal(freight.rows.length, 0);
    assert.equal(freight.registerClass, 'register-in-progress', `OBSERVED register class: ${freight.registerClass} (never-polled must render in-progress, not calm nominal, per compose.js's FRESHNESS_REGISTER map)`);
  } finally {
    await browser.close();
    await server.stop();
  }
});

test('#84 Case 2 (RAN, GENUINELY EMPTY): freight reads "fresh", DISTINCT from Case 1\'s "not yet polled", same empty-queue body', async () => {
  const server = await startRealBoardServer({ storePath: buildScratchStoreFreightFreshEmpty() });
  const browser = await chromium.launch();
  try {
    const page = await browser.newPage();
    await page.goto(`${server.baseUrl}/`);
    await page.waitForFunction(
      () => {
        const lanes = [...document.querySelectorAll('.lane')];
        const freight = lanes.find((l) => l.querySelector('.lane-title')?.textContent === 'Freight');
        return freight && freight.querySelector('.lane-secondary')?.textContent === 'fresh';
      },
      { timeout: 15000 }
    );
    const freight = await readFreightLane(page);
    assert.equal(freight.secondary, 'fresh', `OBSERVED freight secondary line: ${JSON.stringify(freight)}`);
    assert.notEqual(freight.secondary, 'not yet polled', 'REGRESSION (#84 Law 1): a genuinely-run empty queue must never read identically to "never ran"');
    assert.equal(freight.emptyText, 'no tickets in the queue');
    assert.equal(freight.rows.length, 0);
    assert.equal(freight.registerClass, 'register-nominal', `OBSERVED register class: ${freight.registerClass} (fresh + empty must render calm, unlike Case 1's in-progress)`);
  } finally {
    await browser.close();
    await server.stop();
  }
});

test('#84 Case 3 (STALE): freight reads "stale, <duration>", and the last-known queue still renders - never blanked while stale', async () => {
  const server = await startRealBoardServer({ storePath: buildScratchStoreFreightStale() });
  const browser = await chromium.launch();
  try {
    const page = await browser.newPage();
    await page.goto(`${server.baseUrl}/`);
    await page.waitForFunction(
      () => {
        const lanes = [...document.querySelectorAll('.lane')];
        const freight = lanes.find((l) => l.querySelector('.lane-title')?.textContent === 'Freight');
        return freight && freight.querySelector('.lane-secondary')?.textContent?.startsWith('stale,');
      },
      { timeout: 15000 }
    );
    const freight = await readFreightLane(page);
    assert.ok(freight.secondary.startsWith('stale,'), `OBSERVED freight secondary line: ${JSON.stringify(freight)}`);
    assert.equal(freight.rows.length, 1, `OBSERVED freight rows: ${JSON.stringify(freight.rows)}`);
    assert.equal(freight.rows[0].number, '#84');
    assert.equal(freight.rows[0].title, 'Light up the FREIGHT lane');
    assert.equal(freight.rows[0].status, 'Backlog');
    assert.equal(freight.registerClass, 'register-needs-attention', `OBSERVED register class: ${freight.registerClass} (stale must render hot)`);
  } finally {
    await browser.close();
    await server.stop();
  }
});

// #84 fix cycle round 2, R1-M2: tickets exist but no heartbeat rendered
// "not yet polled" beside real ticket rows with ZERO board condition at
// review round 1 - reproduced here as a real browser regression guard.
test('#84 fix cycle r2 (R1-M2): tickets WITHOUT a heartbeat raise a visible board condition, never a silent "not yet polled" beside real rows', async () => {
  const server = await startRealBoardServer({ storePath: buildScratchStoreFreightTicketsWithoutHeartbeat() });
  const browser = await chromium.launch();
  try {
    const page = await browser.newPage();
    await page.goto(`${server.baseUrl}/`);
    await page.waitForFunction(
      () => {
        const lanes = [...document.querySelectorAll('.lane')];
        const freight = lanes.find((l) => l.querySelector('.lane-title')?.textContent === 'Freight');
        return freight && freight.querySelectorAll('.freight-row').length > 0;
      },
      { timeout: 15000 }
    );
    const freight = await readFreightLane(page);
    // The contradictory PAIR round 1 measured verbatim: "not yet polled"
    // secondary line, real ticket row(s) rendered beside it.
    assert.equal(freight.secondary, 'not yet polled', `OBSERVED freight secondary line: ${JSON.stringify(freight)}`);
    assert.equal(freight.rows.length, 1, `OBSERVED freight rows: ${JSON.stringify(freight.rows)}`);
    assert.equal(freight.rows[0].number, '#84');

    // REGRESSION GUARD (R1-M2): this pairing must now be VISIBLE - a real
    // board condition, rendered in the conditions strip, not silent.
    const boardConditionsText = await readBoardConditionsText(page);
    assert.ok(
      boardConditionsText.includes('freight-tickets-without-heartbeat'),
      `REGRESSION (R1-M2): expected the board-conditions strip to disclose the contradiction, got: ${JSON.stringify(boardConditionsText)}`
    );
  } finally {
    await browser.close();
    await server.stop();
  }
});

// #84 fix cycle round 2, R1-M1: a freight lane that has NEVER produced good
// data must not later claim "showing last good" once a scan fails. Unlike
// the other browser cases, this one is DYNAMIC - it starts on an empty
// store (never-polled), then removes the store directory mid-test and
// re-observes, mirroring the reviewer's own measured recipe exactly.
test('#84 fix cycle r2 (R1-M1): a NEVER-POLLED freight lane never claims "showing last good" after a scan failure', async () => {
  const storePath = buildScratchStoreFreightNeverPolled();
  const server = await startRealBoardServer({ storePath });
  const browser = await chromium.launch();
  try {
    const page = await browser.newPage();
    await page.goto(`${server.baseUrl}/`);
    await page.waitForFunction(
      () => {
        const lanes = [...document.querySelectorAll('.lane')];
        const freight = lanes.find((l) => l.querySelector('.lane-title')?.textContent === 'Freight');
        return freight && freight.querySelector('.lane-secondary')?.textContent === 'not yet polled';
      },
      { timeout: 15000 }
    );
    const before = await readFreightLane(page);
    assert.equal(before.secondary, 'not yet polled', `OBSERVED before store loss: ${JSON.stringify(before)}`);

    rmSync(storePath, { recursive: true, force: true });

    await page.waitForFunction(
      () => {
        const lanes = [...document.querySelectorAll('.lane')];
        const freight = lanes.find((l) => l.querySelector('.lane-title')?.textContent === 'Freight');
        return freight && freight.querySelector('.lane-secondary')?.textContent?.startsWith('source failed');
      },
      { timeout: 15000 }
    );
    const after = await readFreightLane(page);
    assert.ok(after.secondary.startsWith('source failed'), `OBSERVED after store loss: ${JSON.stringify(after)}`);
    assert.ok(
      after.secondary.includes('no good data has ever been read'),
      `REGRESSION (R1-M1): expected "no good data has ever been read" (never proven a run), got: ${JSON.stringify(after)}`
    );
    assert.ok(
      !after.secondary.includes('showing last good'),
      `REGRESSION (R1-M1): a lane that has NEVER produced good data must not claim "showing last good", got: ${JSON.stringify(after)}`
    );
  } finally {
    await browser.close();
    await server.stop();
  }
});
