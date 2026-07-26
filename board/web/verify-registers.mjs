// verify-registers.mjs - #62. EXPLICIT, SEPARATELY INVOKED dev tool
// (`node board/web/verify-registers.mjs [--out-dir=path]` from a repo
// checkout with `npm ci` already run in board/web/), same convention as
// its sibling regenerate-screenshot.mjs: lives outside test/ so node's
// test-file discovery never picks it up, and never runs as a side effect
// of the test suite.
//
// WHY THIS EXISTS, and why it is landed rather than thrown away (CLAUDE.md's
// "NEVER DROP A TOOLING REQUEST" - reusable, not fire-and-forget): the #62
// visual pass needed BOTH a calm-yard and a hot-yard screenshot plus
// getComputedStyle evidence for the three register tokens, and that need
// will recur for every future car that touches board.css. Reuses the SAME
// real-server launcher board/web/test/support/real-board-server.js already
// provides (Law 6: one hand-rolled "start the real server" implementation),
// including buildScratchStoreWithInFlightDispatch (#29) for a reliably-hot
// yard that does not depend on this repo's own dispatch history staying
// empty.
//
// Takes NO assertion on the image or the computed styles (same posture as
// regenerate-screenshot.mjs: this is evidence for a human/reviewer to read,
// never a pass/fail gate - a computed-style REGRESSION guard already exists
// at board/web/test/browser-register-cascade.test.js and runs in `node
// --test`).
import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import {
  startRealBoardServer,
  buildScratchStoreWithInFlightDispatch,
  buildScratchStoreWithHealthTrendFamilies
} from './test/support/real-board-server.js';

const REPO_ROOT = fileURLToPath(new URL('../../', import.meta.url));
const today = new Date().toISOString().slice(0, 10);

const outArg = process.argv.find((a) => a.startsWith('--out-dir='));
const outDir = outArg
  ? join(REPO_ROOT, outArg.slice('--out-dir='.length))
  : join(REPO_ROOT, 'docs', 'screenshots', `${today}-register-check-candidates`);

mkdirSync(outDir, { recursive: true });

async function probeComputedStyles(page) {
  return page.evaluate(() => {
    function probe(className) {
      const el = document.createElement('span');
      el.className = className;
      document.body.appendChild(el);
      const color = getComputedStyle(el).color;
      el.remove();
      return color;
    }
    const body = getComputedStyle(document.body);
    const brand = document.querySelector('.brand-name');
    const laneTitle = document.querySelector('.lane-title');
    // #28/#12: the new colored/interactive elements this car's train adds -
    // reported the SAME way (real getComputedStyle, never a hex read off
    // the stylesheet text) as every register above.
    const provenanceLink = document.querySelector('.provenance-link');
    const healthTrends = [...document.querySelectorAll('.health-trend')].map((el) => ({
      text: el.textContent,
      className: el.className,
      color: getComputedStyle(el).color
    }));
    return {
      bodyBackgroundColor: body.backgroundColor,
      bodyFontFamily: body.fontFamily,
      registerNominal: probe('register-nominal'),
      registerInProgress: probe('register-in-progress'),
      registerNeedsAttention: probe('register-needs-attention'),
      brandFontFamily: brand ? getComputedStyle(brand).fontFamily : null,
      laneTitleFontFamily: laneTitle ? getComputedStyle(laneTitle).fontFamily : null,
      laneTitleFontSize: laneTitle ? getComputedStyle(laneTitle).fontSize : null,
      laneRegisterClasses: [...document.querySelectorAll('.lane')].map((l) => l.className),
      provenanceLinkTag: provenanceLink ? provenanceLink.tagName : null,
      provenanceLinkHref: provenanceLink ? provenanceLink.getAttribute('href') : null,
      provenanceLinkColor: provenanceLink ? getComputedStyle(provenanceLink).color : null,
      provenanceLinkTextDecoration: provenanceLink ? getComputedStyle(provenanceLink).textDecorationLine : null,
      healthTrends
    };
  });
}

async function captureState(browser, label, serverOpts) {
  const server = await startRealBoardServer(serverOpts);
  try {
    const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
    await page.goto(`${server.baseUrl}/`);
    await page.waitForSelector('.lanes .lane', { timeout: 15000 });
    await page.waitForTimeout(150); // let CSS settle before the screenshot
    const outPath = join(outDir, `${label}.png`);
    await page.screenshot({ path: outPath, fullPage: false });
    const styles = await probeComputedStyles(page);
    console.log(`\n=== ${label} -> ${outPath} ===`);
    console.log(JSON.stringify(styles, null, 2));
  } finally {
    await server.stop();
  }
}

const browser = await chromium.launch();
try {
  await captureState(browser, 'calm-yard', {});
  await captureState(browser, 'hot-yard', { storePath: buildScratchStoreWithInFlightDispatch() });
  // #28/#12: a controlled scratch store with a converged AND a stalled
  // review-round family, PLUS a configured GitHub repo (STARCAR_GITHUB_REPO)
  // so the train's ticket link (#28) actually renders as a real anchor.
  // DISCLOSED: this scratch store lives under os.tmpdir(), outside the repo
  // root, so config.githubArtifactsPrefix resolves empty here (the honest-
  // degrade path, githublinks.go) - car/gate/dispatch RECORD-DIRECTORY links
  // do NOT render in this particular screenshot for that reason (proven
  // separately, in-repo, by board/server's TestBuildSnapshotGitHubConfigConfigured
  // and this file's own dom-writer.test.js suite); the ticket link and the
  // health-trend badges DO render here, since buildIssueLink only needs
  // githubRepoUrl.
  await captureState(browser, 'health-trend-and-provenance', {
    storePath: buildScratchStoreWithHealthTrendFamilies(),
    env: { STARCAR_GITHUB_REPO: 'polecatspeaks/StarCar', STARCAR_GITHUB_REF: 'dev' }
  });
  console.log(`\nScreenshots + computed-style evidence written to ${outDir}`);
  console.log('These are evidence for a human/reviewer to read, never a pass/fail gate - ' +
    'see board/web/test/browser-register-cascade.test.js for the landed computed-style regression guard.');
} finally {
  await browser.close();
}
