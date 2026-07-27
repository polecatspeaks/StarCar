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
const rawCss = readFileSync(cssPath, 'utf8');

// Strip /* ... */ block comments before ANY extraction so that: (a) a `}`
// inside a comment cannot truncate the extracted rule block, and (b) a
// `color:` declaration that only exists inside a comment is not counted as a
// real declaration. #35 - the Car 31 reviewer fault-injected a commented-out
// color declaration and the old guard passed it silently.
const css = rawCss.replace(/\/\*[\s\S]*?\*\//g, '');

// Extracts the `{ ... }` block belonging to a single top-level rule whose
// selector is exactly `.register-REGISTERID` (e.g. `.register-nominal`).
// Plain string/regex extraction, no CSS-parser dependency (the web view is
// deliberately dependency-free except the vendored validator).
// NOTE: css has already had block comments stripped (above) so [^}]* is safe.
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

  test(`${selector} is color-self-contained: declares BOTH border-left-color and color (not inherit/currentColor), so no register can inherit another's color`, () => {
    const block = findRuleBlock(selector);
    assert.notEqual(block, null, `expected a ${selector} rule block in board.css`);
    assert.match(
      block,
      /border-left-color\s*:/,
      `${selector} must declare border-left-color`
    );
    // The color declaration must exist AND its value must not be `inherit` or
    // `currentColor` - both re-create the #31 defect by letting the element
    // pull its color from an ancestor running a different register. #35.
    assert.match(
      block,
      /(?<!-)\bcolor\s*:/,
      `${selector} must declare its own color (not just border-left-color) - otherwise this register's ` +
        `elements inherit color from an ancestor running a different register (issue #31)`
    );
    // Extract the declared color value and confirm it is neither the cascade-
    // passthrough keyword `inherit` nor `currentColor` (which re-read whatever
    // color is already on the element, defeating self-containment). #35.
    const colorMatch = block.match(/(?<!-)\bcolor\s*:\s*([^;]+);/);
    assert.ok(
      colorMatch,
      `${selector} must declare color: <value>; (with a semicolon-terminated value)`
    );
    const colorValue = colorMatch[1].trim();
    assert.notEqual(
      colorValue, 'inherit',
      `${selector} color must not be 'inherit' - that re-creates issue #31 (cascade passthrough)`
    );
    assert.notEqual(
      colorValue, 'currentColor',
      `${selector} color must not be 'currentColor' - that re-reads the element's own computed color, defeating self-containment (#35)`
    );
  });
}

// --- Item-level label pins (#36) ----------------------------------------
// Owner ruling 2026-07-25: train titles and declared-not-observed items each
// carry their OWN visual authority, independent of the lane's register state.

// .track-title: a train title is a property of the TRAIN, not the lane's
// freshness. It renders NEUTRAL PAPER (var(--text)) always. Without its own
// color declaration it inherits the lane register class's color - which would
// repaint a nominal train's title in whatever register the lane container is
// running hot in. #36.
test('.track-title declares its own color (NEUTRAL PAPER: var(--text)) - not inherited from the lane register class #36', () => {
  const block = findRuleBlock('.track-title');
  assert.notEqual(block, null, 'expected a .track-title rule block in board.css (#36)');
  const colorMatch = block.match(/(?<!-)\bcolor\s*:\s*([^;]+);/);
  assert.ok(
    colorMatch,
    '.track-title must declare an explicit color - without it, the train title inherits ' +
      'the lane container\'s register color (issue #36)'
  );
  const colorValue = colorMatch[1].trim();
  assert.notEqual(colorValue, 'inherit', '.track-title color must not be inherit (#36)');
  assert.notEqual(colorValue, 'currentColor', '.track-title color must not be currentColor (#36)');
});

// .declared-not-observed: this is an ABSENCE DISCLOSURE ("declared, not yet
// observed") and renders needs-attention colors ALWAYS, independent of lane
// state. The pin is structural: both this rule and .register-needs-attention
// must use the same color token so they cannot silently drift. #36.
test('.declared-not-observed has a rule declaring needs-attention color, matching .register-needs-attention structurally #36', () => {
  // First extract the reference value from the authoritative register rule.
  const naBlock = findRuleBlock('.register-needs-attention');
  assert.notEqual(naBlock, null, 'expected a .register-needs-attention rule block in board.css (prerequisite for #36 pin)');
  const naColorMatch = naBlock.match(/(?<!-)\bcolor\s*:\s*([^;]+);/);
  assert.ok(naColorMatch, '.register-needs-attention must declare color (prerequisite)');
  const naColorValue = naColorMatch[1].trim();

  // Now pin .declared-not-observed against that reference value.
  const block = findRuleBlock('.declared-not-observed');
  assert.notEqual(block, null, 'expected a .declared-not-observed rule block in board.css (#36)');
  const colorMatch = block.match(/(?<!-)\bcolor\s*:\s*([^;]+);/);
  assert.ok(colorMatch, '.declared-not-observed must declare an explicit color (#36)');
  assert.equal(
    colorMatch[1].trim(),
    naColorValue,
    `.declared-not-observed color must equal .register-needs-attention color (${naColorValue}) ` +
      'so they cannot drift silently - use the same var() token for a structural pin (#36)'
  );
});
