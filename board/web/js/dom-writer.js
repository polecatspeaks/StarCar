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
//
// #69 (owner fast-follow: "closes back up every page refresh"): the
// conditions strip's open/collapsed state is PULLED from an already-loaded
// openState object (condition-open-state.js's pure shape) and REAPPLIED on
// every render - never captured by scraping the outgoing DOM before
// clearing it. app.js is the single source of truth: it reads sessionStorage
// fresh before each repaint (surviving both a DOM rebuild and a page
// refresh identically, since both start from the SAME persisted read) and
// keeps it current via a 'toggle' event listener, independent of render
// timing. This file only ever WRITES the `open` attribute a caller already
// decided; it never reads sessionStorage itself (dom-writer.js stays
// impure-storage-free, matching this module's own "the ONLY module that
// touches the DOM" boundary - sessionStorage is browser state, not DOM).
import { buildRecordLink, buildIssueLink, buildVocabLink, vocabFilenameForDiscoveryDetail } from './links.js';
import { formatClockDuration } from './format.js';
import { defaultOpenState, isGroupOpen } from './condition-open-state.js';

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

// #71 (clickable provenance, remaining #28 surfaces): a superseded entry is
// a PRIOR record for the SAME subject that lost to the row's own winner
// (board/fold/algorithm.go's foldDispatchSubject - precedence, then
// latest-at) - it lives in the SAME store-root-relative directory as the
// row's own recordDir (board/assemble's one-directory-per-subject
// convention, the same one #28's recordDir already relies on), so no new
// wire field is needed: every superseded entry links through the row's
// OWN recordDir, never re-derived. Honest-absence (null, not an empty
// list) when there is nothing to supersede - matches every other
// honest-absence convention in this file (declared-not-observed,
// renderHistorySummary).
//
// #71 fix-cycle round 2 (MAJOR-R1-1, owner ruling recorded at issue #69,
// 2026-07-27): round 1 appended this block as a SIBLING of the row/chip
// into the shared grid/flex container (.solari-rows / .track-cars), so a
// wrap boundary could land the block next to a DIFFERENT subject's cell -
// measured live: a 5-line unlabelled timestamp stack wrapped onto the line
// below the subject that owned it, immediately beside an unrelated
// subject's own cell. The owner ruling: nest the block INSIDE its owner
// row/chip (a DOM child, so it can never be laid out by the grid/flex
// container as an independent cell/item and can never orphan) behind a
// quiet per-row <details>/<summary> disclosure, COLLAPSED by default - the
// SAME chrome idiom `renderBoardConditionsStrip` (#30) already uses for
// exactly this "quiet, expandable, never a headline" posture. This
// preserves #67's density: a collapsed disclosure is a single summary
// line, not the raw list.
//
// #69/#71-M1 (disclosed, not owner-ruled - see fix-cycle round 2 report):
// this disclosure's open/closed state is EPHEMERAL, not persisted through
// condition-open-state.js's sessionStorage mechanism. Chosen as the
// MINIMAL option: #69's persistence keys by a closed, small vocabulary
// (the strip + a handful of condition CODES, board/store/condition_
// severity.go) but a per-row disclosure would need one key per SUBJECT -
// an open-ended, store-size-dependent key set with no eviction story, on a
// mechanism (sessionStorage) that already has no size ledger. Ephemeral
// also matches this file's own render cycle unforced: `renderBoard`
// (this file's own top-level export, cited by SYMBOL - fix cycle round 3
// MAJOR-R2-2, this comment's own bare "(line 141)" was already false the
// instant round 2 committed it, MAJOR-R1-4's class reproduced in the same
// commit as the lecture about it, docs/contracts/gating-matrix.md:49)
// clears `root.textContent` on every repaint, so even a native `open`
// attribute set by a prior render is already discarded before the next
// paint - persisting it would require NEW capture-and-reapply plumbing
// mirroring #69's, not a re-use of it. Reopens on the next click, same as
// every `<details>` on the web with no persistence wired at all.
//
// #69/#71 fix-cycle round 2 (MINOR-R1-2), CORRECTED fix cycle round 3
// (MAJOR-R2-3): the wire schema now constrains superseded[] items to
// {kind: string, at: string} both required (schema/yard-snapshot.schema.
// json's $defs.dispatchSupersededItem), but that constraint is NEVER
// enforced on the runtime hop a browser actually takes - $defs.lane.data
// (schema/yard-snapshot.schema.json's own $comment explains why: a lane's
// data shape is chosen by which lane it is, not one closed schema union)
// does not $ref dispatchesPayload/trainsPayload, so ingest.js's validator
// (validate.js, the real vendored cfworker-json-schema engine) applies NO
// constraint to superseded[] items - measured: a malformed item validates
// clean through it, before and after this schema addition. The ONLY
// consumer of the new $def is scripts/tests/WirePayload.Tests.ps1's
// fragment extraction, which wraps the $def standalone and therefore sees
// a constraint the real runtime validator never applies. THIS FUNCTION'S
// OWN FILTER, below, is the entire runtime protection, full stop - not
// "defense in depth" alongside a wire-level gate that does not exist. A
// malformed item (missing/non-string kind or at) is skipped, never
// rendered as literal "undefined undefined" (Law 1: honest-absence over a
// guessed/garbled fact) - matching this file's other honest-absence
// conventions (declared-not-observed, renderHistorySummary). If EVERY item
// in the array is malformed, the whole disclosure renders as absent (no
// empty <details> with a "0 superseded" summary and nothing inside it) -
// the same "never an empty list" posture the original honest-absence
// comment above already commits to.
function renderSupersededDisclosure(doc, wrapperClassName, entryClassName, superseded, recordDir, linkCfg) {
  if (!superseded || superseded.length === 0) return null;
  const validItems = superseded.filter((item) => typeof item?.kind === 'string' && typeof item?.at === 'string');
  if (validItems.length === 0) return null;
  const details = el(doc, 'details', `${wrapperClassName}-disclosure`);
  details.appendChild(el(doc, 'summary', `${wrapperClassName}-summary`, `${validItems.length} superseded`));
  const wrap = el(doc, 'div', wrapperClassName);
  for (const item of validItems) {
    // VERBATIM kind + at - never translated, same posture as every other
    // detector-owned string this file renders.
    wrap.appendChild(factOrLink(doc, entryClassName, `${item.kind} ${item.at}`, buildRecordLink(linkCfg, recordDir)));
  }
  details.appendChild(wrap);
  return details;
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
 * @param {{strip: boolean, groups: Record<string, boolean>}} [openState] -
 *   #69: the conditions strip's persisted open/collapsed state, already
 *   loaded by the caller (app.js) - defaults to fully-collapsed so every
 *   existing call site (tests, any caller that predates this ticket) keeps
 *   its prior behaviour unchanged.
 */
export function renderBoard(doc, root, vm, connection, openState = defaultOpenState()) {
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

  root.appendChild(renderFooter(doc, vm, linkCfg, openState));
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
function renderFooter(doc, vm, linkCfg, openState) {
  const footer = el(doc, 'footer', 'board-footer');

  const laneCountText = `registry declares ${vm.laneCompleteness.declared} lane(s) - ${vm.laneCompleteness.observed} rendered`;
  footer.appendChild(el(doc, 'div', 'lane-count', laneCountText));

  if (vm.storePathDisplay) {
    footer.appendChild(el(doc, 'div', 'store-path', `store: ${vm.storePathDisplay}`));
  }

  if (vm.boardConditionGroups.length > 0) {
    footer.appendChild(renderBoardConditionsStrip(doc, vm, linkCfg, openState));
  }

  return footer;
}

// #30: CHROME, not headline (item 3) - a native <details>/<summary> pair
// needs zero JS to expand/collapse, so this is the smallest DOM surface
// that satisfies "a single summary line that expands" without adding a
// click handler. COLLAPSED BY DEFAULT (openState.strip false, the same
// default this repo has always shipped) regardless of severity - even an
// all-FLAG board never auto-expands the strip UNLESS a reader has
// previously opened it this session (#69) - the yard lanes staying above
// the fold on FIRST paint is still the whole point of chrome placement.
//
// data-conditions-strip identifies this element for app.js's toggle
// listener (#69) - a stable marker independent of className, which board.css
// may restyle without breaking the persistence wiring.
function renderBoardConditionsStrip(doc, vm, linkCfg, openState) {
  const strip = el(doc, 'details', `board-conditions-strip ${registerClass(vm.boardConditionsRegister)}`);
  strip.setAttribute('data-conditions-strip', '');
  if (openState && openState.strip) strip.setAttribute('open', '');
  strip.appendChild(el(doc, 'summary', `board-conditions-summary ${registerClass(vm.boardConditionsRegister)}`, vm.boardConditionSummary));

  const groups = el(doc, 'ul', 'board-condition-groups');
  for (const group of vm.boardConditionGroups) {
    groups.appendChild(renderBoardConditionGroup(doc, group, linkCfg, openState));
  }
  strip.appendChild(groups);
  return strip;
}

// #69/#71 (clickable provenance, extending #28 to the board-conditions
// surface): the ONE place a condition instance's honest link target is
// chosen. A "discovery" (NOTE-tier, undeclared kind/outcome VALUE - never a
// store subject) links to the schema/vocab/*.json file that would declare
// it; every other condition class links to its own recordDir when the wire
// supplied one (a config-load fault, an aggregate count, or a client-raised
// condition never has one, and factOrLink's own href-is-falsy branch
// degrades those to identical-layout plain text - "no link, never a broken
// one", #28's own rule, unchanged).
function boardConditionInstanceHref(linkCfg, group, instance) {
  if (group.code === 'discovery') {
    return buildVocabLink(linkCfg, vocabFilenameForDiscoveryDetail(instance.detail));
  }
  return buildRecordLink(linkCfg, instance.recordDir);
}

// #30 (GROUP BY CLASS): one row per condition CODE, itself a <details> -
// "expandable to per-instance details" - collapsed by default (#69: unless
// this code was previously opened THIS SESSION - isGroupOpen defaults to
// closed for any code with no recorded entry, which is exactly how a
// newly-appearing condition class still renders per #30's original rule).
// data-condition-code identifies this element for app.js's toggle listener.
function renderBoardConditionGroup(doc, group, linkCfg, openState) {
  const item = el(doc, 'li', `board-condition-group ${registerClass(group.register)}`);
  const details = el(doc, 'details', 'board-condition-group-details');
  details.setAttribute('data-condition-code', group.code);
  if (isGroupOpen(openState, group.code)) details.setAttribute('open', '');
  details.appendChild(el(doc, 'summary', 'board-condition-group-summary', `${group.code} (x${group.count})`));
  const instances = el(doc, 'ul', 'board-condition-instances');
  for (const instance of group.instances) {
    // VERBATIM - never translated, the same posture as every other
    // detector-owned string this repo renders (state words, outcome words).
    // #69/#71: rendered through factOrLink so a resolvable target becomes a
    // real link (quiet .provenance-link affordance) with IDENTICAL layout
    // to the plain form when no target resolves.
    instances.appendChild(
      factOrLink(
        doc,
        `board-condition-instance ${registerClass(instance.register)}`,
        instance.detail,
        boardConditionInstanceHref(linkCfg, group, instance)
      )
    );
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
      // #71 fix-cycle r2 (MAJOR-R1-1): appended INSIDE the chip, never to
      // `cars` (the flex-wrap container) - the disclosure can only ever
      // grow ITS OWN chip's box, never bleed onto a neighbouring chip.
      const supersededDisclosure = renderSupersededDisclosure(doc, 'car-superseded', 'car-superseded-entry', car.superseded, car.recordDir, linkCfg);
      if (supersededDisclosure) chip.appendChild(supersededDisclosure);
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
    // #71 fix cycle r3 (MAJOR-R2-1): the subject/state/elapsed cluster lives
    // in its OWN wrapper (`solari-row-main`), never as direct flex children
    // of `.solari-row` itself - see board.css's `.solari-row`/`.solari-row-
    // main` comment for why (round 2's `flex-wrap: wrap` on `.solari-row`
    // wrapped this cluster onto a second line too, not just the disclosure).
    const main = el(doc, 'div', 'solari-row-main');
    const subject = factOrLink(doc, 'solari-subject', d.subject, buildRecordLink(linkCfg, d.recordDir));
    // #62: board.css truncates a long subject id with an ellipsis (the
    // fixed-height dispatches grid) - the native title tooltip keeps the
    // full id reachable, never silently lost. Survives becoming a link
    // (#28) - the title attribute goes on the anchor/span either way.
    subject.setAttribute('title', d.subject);
    main.appendChild(subject);
    main.appendChild(el(doc, 'span', 'solari-state', d.state)); // VERBATIM
    if (d.elapsedSeconds !== null) {
      // #67 (FORMAT NIT): compact clock time, never "272s" - the ONE
      // formatter every duration on this board shares (format.js, Law 6).
      main.appendChild(el(doc, 'span', 'solari-elapsed', formatClockDuration(d.elapsedSeconds)));
    }
    row.appendChild(main);
    // #71 fix-cycle r2 (MAJOR-R1-1), fix cycle r3 (MAJOR-R2-1): appended
    // INSIDE the row, never to `rows` (the grid container) - the disclosure
    // can only ever grow ITS OWN row's grid cell, never wrap onto a
    // neighbouring subject's cell. Appended AFTER `main`, never inside it,
    // so `.solari-row`'s column-direction layout stacks it below the
    // single-line cluster rather than letting it compete for space on that
    // cluster's own flex line.
    const supersededDisclosure = renderSupersededDisclosure(doc, 'solari-superseded', 'solari-superseded-entry', d.superseded, d.recordDir, linkCfg);
    if (supersededDisclosure) row.appendChild(supersededDisclosure);
    rows.appendChild(row);
  }
  wrap.appendChild(rows);
  return wrap;
}
