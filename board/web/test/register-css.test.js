// register-css.test.js - pins the class of defect behind issue #31: a
// register class that declares border-left-color but not color lets its
// element's `color` cascade in from an ancestor (dom-writer.js puts the
// lane-level register class on the lane container itself), and the
// `.car-chip` / `.signal` / `.solari-row` rules draw their register edge
// with `border-left: ... currentColor`, so an inherited color repaints a
// nominal item's border in whatever register its ancestor is running hot
// in. Every register rule must be COLOR-SELF-CONTAINED: it declares its
// own `color` as well as its own `border-left-color`, so no register can
// ever inherit another's.
//
// REGISTER_ORDER is imported, never hardcoded here (Law 7): compose.js is
// the single source of the register taxonomy in this view.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { REGISTER_ORDER } from '../js/compose.js';

const cssPath = fileURLToPath(new URL('../css/board.css', import.meta.url));
const css = readFileSync(cssPath, 'utf8');

// Extracts the `{ ... }` block belonging to a single top-level rule whose
// selector is exactly `.register-REGISTERID` (e.g. `.register-nominal`).
// Plain string/regex extraction, no CSS-parser dependency (the web view is
// deliberately dependency-free except the vendored validator).
function findRuleBlock(selector) {
  const escaped = selector.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  // Selector must not be a prefix of a longer class name (e.g.
  // `.register-nominal` must not match inside `.register-nominal-foo`), so
  // require a non-word boundary (or `{`) right after it.
  const re = new RegExp(`${escaped}(?![\\w-])\\s*\\{([^}]*)\\}`);
  const match = css.match(re);
  return match ? match[1] : null;
}

for (const registerId of REGISTER_ORDER) {
  const selector = `.register-${registerId}`;

  test(`${selector} rule exists in board.css`, () => {
    assert.notEqual(findRuleBlock(selector), null, `expected a ${selector} rule block in board.css`);
  });

  test(`${selector} is color-self-contained: declares BOTH border-left-color and color, so no register can inherit another's color`, () => {
    const block = findRuleBlock(selector);
    assert.notEqual(block, null, `expected a ${selector} rule block in board.css`);
    assert.match(
      block,
      /border-left-color\s*:/,
      `${selector} must declare border-left-color`
    );
    assert.match(
      block,
      /(?<!-)\bcolor\s*:/,
      `${selector} must declare its own color (not just border-left-color) - otherwise this register's ` +
        `elements inherit color from an ancestor running a different register (issue #31)`
    );
  });
}
