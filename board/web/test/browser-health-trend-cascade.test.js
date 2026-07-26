// browser-health-trend-cascade.test.js (#12: car health bar). Same
// discipline as browser-register-cascade.test.js (#31/#33): a color-
// authority claim is settled by a REAL browser's getComputedStyle, never
// by reading board.css's text or a hand-rolled DOM shim with no CSS engine.
//
// The health-trend badge is a NEW independent color claim - unlike every
// other span inside .car-chip/.signal/.solari-row (which all inherit their
// color from the register-classed ANCESTOR), .health-trend sets its OWN
// color per TREND, decoupled from the gate's own outcome register. That
// is exactly the shape of claim #31 proved a hand-rolled DOM shim cannot
// see, so it gets the same real-browser treatment.
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { chromium } from 'playwright';
import { startRealBoardServer, buildScratchStoreWithHealthTrendFamilies } from './support/real-board-server.js';

const CSS_PATH = fileURLToPath(new URL('../css/board.css', import.meta.url));

let server;
let browser;
let page;

before(async () => {
  server = await startRealBoardServer({ storePath: buildScratchStoreWithHealthTrendFamilies() });
  browser = await chromium.launch();
  page = await browser.newPage();
  await page.goto(`${server.baseUrl}/`);
  await page.waitForSelector('.health-trend', { timeout: 15000 });
});

after(async () => {
  if (browser) await browser.close();
  if (server) await server.stop();
});

async function probeColors(p) {
  return p.evaluate(() => {
    function probeColor(className) {
      const el = document.createElement('span');
      el.className = className;
      document.body.appendChild(el);
      const color = getComputedStyle(el).color;
      el.remove();
      return color;
    }
    const badges = [...document.querySelectorAll('.health-trend')];
    const converged = badges.find((b) => b.textContent.includes('converged'));
    const stalled = badges.find((b) => b.textContent.includes('stalled'));
    return {
      badgeCount: badges.length,
      convergedText: converged ? converged.textContent : null,
      convergedColor: converged ? getComputedStyle(converged).color : null,
      stalledText: stalled ? stalled.textContent : null,
      stalledColor: stalled ? getComputedStyle(stalled).color : null,
      nominalProbeColor: probeColor('register-nominal'),
      needsAttentionProbeColor: probeColor('register-needs-attention')
    };
  });
}

test('#12: the real board renders exactly two health-trend badges (one per family\'s LATEST round), with the series in the text', async () => {
  const observed = await probeColors(page);
  assert.equal(observed.badgeCount, 2, `expected exactly 2 badges (one per family), got ${observed.badgeCount}`);
  assert.ok(observed.convergedText && observed.convergedText.includes('3') && observed.convergedText.includes('0'));
  assert.ok(observed.stalledText && observed.stalledText.includes('3') && observed.stalledText.includes('4'));
});

test('#12: a CONVERGED trend badge renders the real .register-nominal computed color, a STALLED trend badge renders the real .register-needs-attention computed color - two DIFFERENT colors, measured, never a hardcoded hex', async () => {
  const observed = await probeColors(page);
  assert.equal(
    observed.convergedColor,
    observed.nominalProbeColor,
    `converged badge color ${observed.convergedColor} did not match the live .register-nominal color ${observed.nominalProbeColor}`
  );
  assert.equal(
    observed.stalledColor,
    observed.needsAttentionProbeColor,
    `stalled badge color ${observed.stalledColor} did not match the live .register-needs-attention color ${observed.needsAttentionProbeColor}`
  );
  assert.notEqual(
    observed.convergedColor,
    observed.stalledColor,
    'a converged (healthy) badge and a stalled (swirl) badge must never render the same color'
  );
});

// --- NON-VACUITY: fault-inject the naive cascade-order bug this rule
// exists to prevent, observe it break, revert byte-identical -----------

test('#12 NON-VACUITY: injecting a plain, LATER-in-cascade .health-trend color rule (the naive version this guard replaces) breaks the stalled badge\'s color - proving this guard is not vacuous', async () => {
  // Precondition, read-only (never written): the ACTUAL guarded rule this
  // fault injection targets must be present, verbatim, in the real shipped
  // board.css - so this test stays tethered to what is actually live
  // rather than to an invented string.
  const liveCss = readFileSync(CSS_PATH, 'utf8');
  const guardedRule =
    '.health-trend:not(.register-nominal):not(.register-needs-attention) {\n  color: var(--text-dim);\n}';
  assert.ok(liveCss.includes(guardedRule), 'test precondition: expected the :not()-guarded rule to be present verbatim in board.css');

  // The fault: an INJECTED stylesheet, appended to <head> AFTER the real
  // linked board.css (so it is LATER IN CASCADE ORDER, same as editing
  // board.css itself and moving the naive rule to the same position the
  // real guarded rule occupies) - a bare `.health-trend { color:
  // var(--text-dim); }` has the SAME specificity as `.register-nominal`/
  // `.register-needs-attention` but wins the tie by appearing later,
  // silently repainting EVERY badge muted gray regardless of trend. This
  // avoids editing the real file on disk (Go's http.FileServer 304s on an
  // unchanged mtime granularity within the same test run - PROBED: an
  // earlier version of this test wrote+reloaded and observed the STALE,
  // still-correct color, a false negative from HTTP caching, not from the
  // rule being sound) - the injected <style> tag is unaffected by that.
  let styleHandle;
  try {
    styleHandle = await page.addStyleTag({ content: '.health-trend { color: var(--text-dim); }' });
    const observed = await probeColors(page);

    // THE FAULT: the stalled badge (which SHOULD read needs-attention,
    // exactly like the passing test above) instead reads the SAME muted
    // color a genuinely neutral/unknown badge would - the cascade-order
    // bug this rule exists to prevent, reproduced live.
    assert.notEqual(
      observed.stalledColor,
      observed.needsAttentionProbeColor,
      `expected the injected fault to BREAK the stalled badge's color (make it != needs-attention), but it still read ` +
        `${observed.stalledColor} - the fault did not reproduce, so this guard's non-vacuity is unproven this run`
    );
    assert.equal(
      observed.stalledColor,
      observed.convergedColor,
      'the fault applies uniformly to every .health-trend element regardless of trend - stalled and converged must now (wrongly) read the SAME muted color'
    );
  } finally {
    // Revert: remove the injected <style> element - the real board.css on
    // disk was never touched, so there is nothing to restore there.
    if (styleHandle) await styleHandle.evaluate((node) => node.remove());
  }
});

test('#12: with the fault injection removed, the stalled badge is HOT again (needs-attention) - the guard is real, not a permanent break', async () => {
  const observed = await probeColors(page);
  assert.equal(observed.stalledColor, observed.needsAttentionProbeColor);
  assert.equal(observed.convergedColor, observed.nominalProbeColor);
});
