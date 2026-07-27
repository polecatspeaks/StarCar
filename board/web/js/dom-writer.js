// dom-writer.js - the ONLY module that touches the DOM. Takes render.js's
// pure view model and a `document`-shaped object (the real browser
// `document` in production; a minimal hand-rolled shim in
// board/web/test/dom-writer.test.js) and writes it into `root`.
//
// Deliberately uses only createElement/appendChild/textContent/className/
// setAttribute - the smallest DOM surface that can express this board -
// so the same code runs unmodified against Node's test shim (task 5.5's
// "render into a minimal DOM shim").
//
// Visual authority: the reviewed mockup brief
// (docs/design/2026-07-23-ui-mockup-brief.md) and design rev 5 S5.2's
// composition rules BIND (three registers only, verbatim words, honesty
// chrome, bagged/dark dignity); docs/design/mockups/2026-07-26-claude-
// design-board/'s five owner-generated variants STEER (owner ruling,
// 2026-07-26: NO SINGLE KEEPER - build the SHARED language, iterate later).
// #62 built that shared language: lane label plates with purpose
// subtitles, a footer status strip, a brand wordmark, the 2b track-
// schematic (trains/gates) + 1b Solari-board (dispatches) structural
// merge - still structural fidelity, not pixel-for-pixel, per the mock
// doctrine ("direction, never contract"). Further slices (specific
// elements from specific variants, per the owner ruling) remain open on
// issue #1.
//
// #28/#12: this module ALSO renders clickable provenance (a car/gate/
// dispatch subject or a train's declared ticket becomes an anchor when the
// wire supplies both a GitHub identity and the entry's own recordDir/
// ticket token) and the car-health-bar badge (#12) - both built from
// board/web/js/links.js and board/web/js/findings.js's pure helpers; this
// file's only job is turning their output into DOM.
import { buildRecordLink, buildIssueLink } from './links.js';
import { formatClockDuration } from './format.js';

function el(doc, tag, className, text) {
  const node = doc.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

function registerClass(register) {
  return `register-${register}`;
}

// #28: renders an <a> (quiet provenance affordance, board.css's
// .provenance-link) when href is truthy, or a plain element otherwise -
// "no link, never a broken one" (issue #28's own escape hatch). CORRECTED
// (#28/#12 fix cycle round 2 MINOR-2: "the className is IDENTICAL either
// way" was literally false): the BASE className is preserved either way (a
// caller's querySelectorAll('.car-subject') finds the element regardless
// of which tag it rendered as), but 'provenance-link' is APPENDED only on
// the linked form so board.css's quiet-affordance styling applies only
// there - the two className strings differ by exactly that one token.
function factOrLink(doc, className, text, href) {
  if (href) {
    const anchor = el(doc, 'a', `${className} provenance-link`, text);
    anchor.setAttribute('href', href);
    anchor.setAttribute('rel', 'noopener');
    return anchor;
  }
  return el(doc, 'span', className, text);
}

// #12: the health-trend badge text - a compact glyph + word + the family's
// own Major-count series, so the number itself (never just a color) carries
// the evidence (HAVAGLANCE: a glance must transmit the WHOLE story, and a
// bare color dot would not). 'first-round'/'unknown' get NO register class
// (neutral, muted text-dim via board.css) - Majors on round 1 alone is
// normal traffic in this shop, never alarming, and an unparseable findings
// shape is Law 1's honest-unknown, never a guessed calm OR guessed hot.
function healthTrendBadgeText(healthTrend) {
  const series = healthTrend.majorsSeries ? healthTrend.majorsSeries.join('→') : null;
  switch (healthTrend.trend) {
    case 'converged':
      return `▼ converged (${series})`;
    case 'declining':
      return `▼ declining (${series})`;
    case 'stalled':
      return `● stalled (${series})`;
    case 'first-round':
      return 'round 1 (no trend yet)';
    default:
      return 'trend: unknown';
  }
}

function healthTrendRegisterClass(trend) {
  if (trend === 'converged' || trend === 'declining') return 'register-nominal';
  if (trend === 'stalled') return 'register-needs-attention';
  return ''; // first-round / unknown: neutral, no register class (board.css's own muted default)
}

/**
 * @param {Document} doc
 * @param {Element} root
 * @param {ReturnType<import('./render.js').buildBoardViewModel>} vm
 * @param {{connected: boolean}} connection
 */
export function renderBoard(doc, root, vm, connection) {
  root.textContent = ''; // clear() without needing a real DOM API for it

  root.appendChild(renderChrome(doc, vm, connection));

  // #28: the three link-building primitives, read off the view model ONCE
  // per render and threaded down to every lane body that needs them -
  // never re-read from vm inside a deeply nested renderer.
  const linkCfg = {
    githubRepoUrl: vm.githubRepoUrl,
    githubRef: vm.githubRef,
    githubArtifactsPrefix: vm.githubArtifactsPrefix
  };

  const lanesRoot = el(doc, 'section', 'lanes');
  const total = vm.lanes.length;
  vm.lanes.forEach((lane, index) => {
    lanesRoot.appendChild(renderLane(doc, lane, index + 1, total, linkCfg));
  });
  root.appendChild(lanesRoot);

  root.appendChild(renderFooter(doc, vm));
}

// #62: shared visual language (owner ruling: no single keeper) - every one
// of the five mockup variants opens with a condensed wordmark ("STARCAR")
// ahead of the honesty chrome. Static presentational text, not data - the
// single strongest common signal across all five variants (README.md's
// "What the direction already gets right").
function renderChrome(doc, vm, connection) {
  const chrome = el(doc, 'header', 'chrome');

  const brand = el(doc, 'div', 'brand');
  brand.appendChild(el(doc, 'span', 'brand-name', 'STARCAR'));
  brand.appendChild(el(doc, 'span', 'brand-subtitle', 'YARD BOARD'));
  chrome.appendChild(brand);

  if (vm.demoMode) {
    chrome.appendChild(el(doc, 'div', 'demo-banner', 'DEMO DATA'));
  }

  chrome.appendChild(el(doc, 'div', 'as-of', `as of ${vm.asOf ?? '(no successful scan yet)'}`));

  const connectionClass = connection.connected ? 'connection-connected' : 'connection-disconnected';
  chrome.appendChild(
    el(doc, 'div', connectionClass, connection.connected ? 'connected' : 'disconnected - showing last known')
  );

  return chrome;
}

// #62: the footer status strip (shared across every mockup variant) - moved
// here from the top chrome: registry lane completeness, the real
// storePathDisplay wire field (never rendered anywhere before this pass -
// already publication-safe per schema/yard-snapshot.schema.json's
// config.storePathDisplay property - cited by SYMBOL, not line, #28/#12 fix
// cycle round 2 MAJOR-1: this comment's own "  :191" line citation was
// falsified by a LATER commit in this same train that grew the schema file,
// exactly the trap poll.go's own "cited by symbol, not line" convention
// exists to avoid), and the #30 board-conditions strip. Store-record/fold
// counts ("store: 65 -> 17 dispatches") appear in the mockups too but
// carry NO wire field (schema/yard-snapshot.schema.json has no such field)
// - inventing one client-side would be a second copy of server-owned
// arithmetic (Law 6) and adding one server-side is a wire change, out of
// this ticket's scope.
// CORRECTED (#62 fix cycle round 2, review round 1 MINOR-1 - this comment
// used to say "routed to issue #1" while nothing had actually been posted
// there, a carrier-rule miss): now actually routed - see issue #1, comment
// https://github.com/polecatspeaks/StarCar/issues/1#issuecomment-5085235534
// (2026-07-26), item 2.
function renderFooter(doc, vm) {
  const footer = el(doc, 'footer', 'board-footer');

  const laneCountText = `registry declares ${vm.laneCompleteness.declared} lane(s) - ${vm.laneCompleteness.observed} rendered`;
  footer.appendChild(el(doc, 'div', 'lane-count', laneCountText));

  if (vm.storePathDisplay) {
    footer.appendChild(el(doc, 'div', 'store-path', `store: ${vm.storePathDisplay}`));
  }

  if (vm.boardConditionGroups.length > 0) {
    footer.appendChild(renderBoardConditionsStrip(doc, vm));
  }

  return footer;
}

// #30: CHROME, not headline (item 3) - a native <details>/<summary> pair
// needs zero JS to expand/collapse, so this is the smallest DOM surface
// that satisfies "a single summary line that expands" without adding a
// click handler. COLLAPSED BY DEFAULT (no "open" attribute set) always,
// regardless of severity - even an all-FLAG board never auto-expands the
// strip, because the yard lanes staying above the fold is the whole point
// of placing this in chrome rather than as a headline.
function renderBoardConditionsStrip(doc, vm) {
  const strip = el(doc, 'details', `board-conditions-strip ${registerClass(vm.boardConditionsRegister)}`);
  strip.appendChild(el(doc, 'summary', `board-conditions-summary ${registerClass(vm.boardConditionsRegister)}`, vm.boardConditionSummary));

  const groups = el(doc, 'ul', 'board-condition-groups');
  for (const group of vm.boardConditionGroups) {
    groups.appendChild(renderBoardConditionGroup(doc, group));
  }
  strip.appendChild(groups);
  return strip;
}

// #30 (GROUP BY CLASS): one row per condition CODE, itself a <details> -
// "expandable to per-instance details" - collapsed by default for the same
// reason the outer strip is.
function renderBoardConditionGroup(doc, group) {
  const item = el(doc, 'li', `board-condition-group ${registerClass(group.register)}`);
  const details = el(doc, 'details');
  details.appendChild(el(doc, 'summary', 'board-condition-group-summary', `${group.code} (x${group.count})`));
  const instances = el(doc, 'ul', 'board-condition-instances');
  for (const instance of group.instances) {
    // VERBATIM - never translated, the same posture as every other
    // detector-owned string this repo renders (state words, outcome words).
    instances.appendChild(el(doc, 'li', `board-condition-instance ${registerClass(instance.register)}`, instance.detail));
  }
  details.appendChild(instances);
  item.appendChild(details);
  return item;
}

// #62: lane label PLATE (ordinal + title + purpose subtitle + freshness
// lines) beside its content - the shared layout across every mockup
// variant (1a's grid-template-columns label column, 2b's numbered plate,
// 1c's surfaced card). `index`/`total` are the lane's position in the
// already-known, already-ordered snapshot.lanes array (EXPECTED_LANE_IDS'
// own registry order, restated at the view - render.test.js pins this
// order) - a structural ordinal about DECLARED lane position, never new
// data and never a second copy of anything server-owned.
function renderLane(doc, lane, index, total, linkCfg) {
  const section = el(doc, 'article', `lane lane-${lane.id} ${registerClass(lane.register)}`);

  const plate = el(doc, 'div', 'lane-plate');
  const heading = el(doc, 'div', 'lane-heading');
  const ordinal = el(doc, 'span', 'lane-ordinal', String(index));
  ordinal.setAttribute('title', `lane ${index} of ${total} declared`);
  heading.appendChild(ordinal);
  heading.appendChild(el(doc, 'h2', 'lane-title', lane.title));
  plate.appendChild(heading);
  if (lane.purpose) {
    plate.appendChild(el(doc, 'div', 'lane-purpose', lane.purpose));
  }
  plate.appendChild(el(doc, 'div', 'lane-primary', lane.primary));
  if (lane.secondary) {
    plate.appendChild(el(doc, 'div', 'lane-secondary', lane.secondary));
  }
  section.appendChild(plate);

  const content = el(doc, 'div', 'lane-content');
  content.appendChild(renderLaneBody(doc, lane.body, linkCfg));
  section.appendChild(content);

  return section;
}

function renderLaneBody(doc, body, linkCfg) {
  switch (body.kind) {
    case 'trains':
      return renderTrains(doc, body, linkCfg);
    case 'gates':
      return renderGates(doc, body, linkCfg);
    case 'dispatches':
      return renderDispatches(doc, body, linkCfg);
    case 'dark':
      return el(doc, 'div', 'lane-body lane-body-dark', body.text);
    case 'bagged':
      return el(doc, 'div', 'lane-body lane-body-bagged', body.text);
    case 'no-renderer':
      return el(doc, 'div', 'lane-body lane-body-no-renderer', 'no renderer for this payload');
    default:
      return el(doc, 'div', 'lane-body lane-body-unknown', `unrecognised lane body kind: '${body.kind}'`);
  }
}

// #67 (HONESTY CONSTRAINT, Law 4 + absence-blindness): the one summary line
// shared by both filtered lanes - QUIET CHROME (#62 visual idiom: nominal
// register, small text, never a headline), rendered only when render.js's
// historySummary is non-null (hiddenCount > 0) so an unfiltered lane never
// carries a "showing 0 of 0" noise line.
function renderHistorySummary(doc, historySummary) {
  if (!historySummary) return null;
  return el(doc, 'div', `history-summary ${registerClass('nominal')}`, historySummary);
}

// TRAINS: track-schematic direction (mockup merge 2b) - each train is a
// labeled track holding its cars in sequence.
function renderTrains(doc, body, linkCfg) {
  const wrap = el(doc, 'div', 'lane-body lane-body-trains');
  const summary = renderHistorySummary(doc, body.historySummary);
  if (summary) wrap.appendChild(summary);
  for (const train of body.trains) {
    const track = el(doc, 'div', 'track');
    track.appendChild(el(doc, 'div', 'track-title', `${train.title} (${train.id})`));
    // #28: the manifest's own declared ticket refs, rendered as issue
    // links - a train with none renders no ticket strip at all (never an
    // empty one), matching every other honest-absence convention here.
    if (train.tickets.length > 0) {
      const ticketsEl = el(doc, 'div', 'train-tickets');
      for (const ticket of train.tickets) {
        ticketsEl.appendChild(factOrLink(doc, 'ticket-link', ticket, buildIssueLink(linkCfg, ticket)));
      }
      track.appendChild(ticketsEl);
    }
    const cars = el(doc, 'div', 'track-cars');
    for (const car of train.cars) {
      const chip = el(doc, 'div', `car-chip ${registerClass(car.stateRegister)}`);
      chip.appendChild(factOrLink(doc, 'car-subject', car.subject, buildRecordLink(linkCfg, car.recordDir)));
      chip.appendChild(el(doc, 'span', 'car-role', car.role.label));
      // VERBATIM state word - never translated (mockup brief).
      chip.appendChild(el(doc, 'span', 'car-state', car.state));
      if (car.outcome) {
        chip.appendChild(el(doc, 'span', `car-outcome ${registerClass(car.outcomeRegister)}`, car.outcome));
      }
      if (car.gate) {
        chip.appendChild(el(doc, 'span', 'car-gate', car.gate));
      }
      cars.appendChild(chip);
    }
    track.appendChild(cars);
    if (train.declaredNotObserved.length > 0) {
      track.appendChild(
        el(doc, 'div', 'declared-not-observed', `declared, not yet observed: ${train.declaredNotObserved.join(', ')}`)
      );
    }
    wrap.appendChild(track);
  }
  return wrap;
}

// GATES: signal-head direction (mockup merge 2b) - a small verdict light
// per gate, verdict word VERBATIM.
//
// #62 N3 (fix cycle round 2, review round 1 NOTE-3): an empty-but-live
// gates lane used to render a blank content pane - honest (body.gates is
// really []) but reads as a rendering hole rather than a stated absence,
// unlike freight's "no equipment on this lane" and fuel's "data held, not
// surfaced". Derived honestly from the same data already in hand (zero
// entries in THIS fold's gates array) - never invented, never a guess
// about why it is empty.
function renderGates(doc, body, linkCfg) {
  const wrap = el(doc, 'div', 'lane-body lane-body-gates');
  if (body.gates.length === 0) {
    wrap.appendChild(el(doc, 'div', 'lane-body-gates-empty', 'no gates in this fold'));
    return wrap;
  }
  for (const gate of body.gates) {
    const signal = el(doc, 'div', `signal ${registerClass(gate.outcomeRegister)}`);
    signal.appendChild(factOrLink(doc, 'signal-name', gate.name, buildRecordLink(linkCfg, gate.recordDir)));
    signal.appendChild(el(doc, 'span', 'signal-outcome', gate.outcome)); // VERBATIM
    signal.appendChild(el(doc, 'span', 'signal-at', gate.at));
    // #12: the car health bar - present ONLY on a review-round family's
    // LATEST round (render.js's computeHealthTrends already scoped this;
    // this renderer just draws whatever it was handed).
    if (gate.healthTrend) {
      signal.appendChild(
        el(
          doc,
          'span',
          `health-trend ${healthTrendRegisterClass(gate.healthTrend.trend)}`.trim(),
          healthTrendBadgeText(gate.healthTrend)
        )
      );
    }
    wrap.appendChild(signal);
  }
  return wrap;
}

// DISPATCHES: Solari split-flap direction (mockup merge 1b) - dense
// monospace rows: subject, state word, elapsed.
function renderDispatches(doc, body, linkCfg) {
  const wrap = el(doc, 'div', 'lane-body lane-body-dispatches');
  wrap.appendChild(
    el(doc, 'div', 'yard-inventory-count', `${body.yardInventoryCount} in yard inventory (unassigned)`)
  );
  const summary = renderHistorySummary(doc, body.historySummary);
  if (summary) wrap.appendChild(summary);
  const rows = el(doc, 'div', 'solari-rows');
  for (const d of body.dispatches) {
    const row = el(doc, 'div', `solari-row ${registerClass(d.stateRegister)}${d.assigned ? '' : ' unassigned'}`);
    const subject = factOrLink(doc, 'solari-subject', d.subject, buildRecordLink(linkCfg, d.recordDir));
    // #62: board.css truncates a long subject id with an ellipsis (the
    // fixed-height dispatches grid) - the native title tooltip keeps the
    // full id reachable, never silently lost. Survives becoming a link
    // (#28) - the title attribute goes on the anchor/span either way.
    subject.setAttribute('title', d.subject);
    row.appendChild(subject);
    row.appendChild(el(doc, 'span', 'solari-state', d.state)); // VERBATIM
    if (d.elapsedSeconds !== null) {
      // #67 (FORMAT NIT): compact clock time, never "272s" - the ONE
      // formatter every duration on this board shares (format.js, Law 6).
      row.appendChild(el(doc, 'span', 'solari-elapsed', formatClockDuration(d.elapsedSeconds)));
    }
    rows.appendChild(row);
  }
  wrap.appendChild(rows);
  return wrap;
}
