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
// Visual authority (plan task 5.3): the reviewed mockup brief
// (docs/design/2026-07-23-ui-mockup-brief.md) and design rev 5 S5.2's
// composition rules BIND (three registers only, verbatim words, honesty
// chrome, bagged/dark dignity); the 2b track-schematic (trains/gates) +
// 1b Solari-board (dispatches) mockup merge STEERS. This v0 pass renders
// the CONTRACTS fully and the steering direction structurally (track rows
// for trains/gates, dense monospace rows for dispatches) rather than
// pixel-for-pixel mockup fidelity - disclosed in this car's report as the
// conductor's first human look is the actual visual-polish gate.

function el(doc, tag, className, text) {
  const node = doc.createElement(tag);
  if (className) node.className = className;
  if (text !== undefined) node.textContent = text;
  return node;
}

function registerClass(register) {
  return `register-${register}`;
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

  const lanesRoot = el(doc, 'section', 'lanes');
  for (const lane of vm.lanes) {
    lanesRoot.appendChild(renderLane(doc, lane));
  }
  root.appendChild(lanesRoot);
}

function renderChrome(doc, vm, connection) {
  const chrome = el(doc, 'header', 'chrome');

  if (vm.demoMode) {
    chrome.appendChild(el(doc, 'div', 'demo-banner', 'DEMO DATA'));
  }

  chrome.appendChild(el(doc, 'div', 'as-of', `as of ${vm.asOf ?? '(no successful scan yet)'}`));

  const connectionClass = connection.connected ? 'connection-connected' : 'connection-disconnected';
  chrome.appendChild(
    el(doc, 'div', connectionClass, connection.connected ? 'connected' : 'disconnected - showing last known')
  );

  const laneCountText = `${vm.laneCompleteness.observed} of ${vm.laneCompleteness.declared} lanes`;
  chrome.appendChild(el(doc, 'div', 'lane-count', laneCountText));

  if (vm.boardConditions.length > 0) {
    const strip = el(doc, 'ul', 'board-conditions');
    for (const bc of vm.boardConditions) {
      strip.appendChild(el(doc, 'li', `board-condition ${registerClass(bc.register)}`, `${bc.code}: ${bc.detail}`));
    }
    chrome.appendChild(strip);
  }

  return chrome;
}

function renderLane(doc, lane) {
  const section = el(doc, 'article', `lane lane-${lane.id} ${registerClass(lane.register)}`);
  section.appendChild(el(doc, 'h2', 'lane-title', lane.title));
  section.appendChild(el(doc, 'div', 'lane-primary', lane.primary));
  if (lane.secondary) {
    section.appendChild(el(doc, 'div', 'lane-secondary', lane.secondary));
  }
  section.appendChild(renderLaneBody(doc, lane.body));
  return section;
}

function renderLaneBody(doc, body) {
  switch (body.kind) {
    case 'trains':
      return renderTrains(doc, body);
    case 'gates':
      return renderGates(doc, body);
    case 'dispatches':
      return renderDispatches(doc, body);
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

// TRAINS: track-schematic direction (mockup merge 2b) - each train is a
// labeled track holding its cars in sequence.
function renderTrains(doc, body) {
  const wrap = el(doc, 'div', 'lane-body lane-body-trains');
  for (const train of body.trains) {
    const track = el(doc, 'div', 'track');
    track.appendChild(el(doc, 'div', 'track-title', `${train.title} (${train.id})`));
    const cars = el(doc, 'div', 'track-cars');
    for (const car of train.cars) {
      const chip = el(doc, 'div', `car-chip ${registerClass(car.stateRegister)}`);
      chip.appendChild(el(doc, 'span', 'car-subject', car.subject));
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
function renderGates(doc, body) {
  const wrap = el(doc, 'div', 'lane-body lane-body-gates');
  for (const gate of body.gates) {
    const signal = el(doc, 'div', `signal ${registerClass(gate.outcomeRegister)}`);
    signal.appendChild(el(doc, 'span', 'signal-name', gate.name));
    signal.appendChild(el(doc, 'span', 'signal-outcome', gate.outcome)); // VERBATIM
    signal.appendChild(el(doc, 'span', 'signal-at', gate.at));
    wrap.appendChild(signal);
  }
  return wrap;
}

// DISPATCHES: Solari split-flap direction (mockup merge 1b) - dense
// monospace rows: subject, state word, elapsed.
function renderDispatches(doc, body) {
  const wrap = el(doc, 'div', 'lane-body lane-body-dispatches');
  wrap.appendChild(
    el(doc, 'div', 'yard-inventory-count', `${body.yardInventoryCount} in yard inventory (unassigned)`)
  );
  const rows = el(doc, 'div', 'solari-rows');
  for (const d of body.dispatches) {
    const row = el(doc, 'div', `solari-row ${registerClass(d.stateRegister)}${d.assigned ? '' : ' unassigned'}`);
    row.appendChild(el(doc, 'span', 'solari-subject', d.subject));
    row.appendChild(el(doc, 'span', 'solari-state', d.state)); // VERBATIM
    if (d.elapsedSeconds !== null) {
      row.appendChild(el(doc, 'span', 'solari-elapsed', `${d.elapsedSeconds}s`));
    }
    rows.appendChild(row);
  }
  wrap.appendChild(rows);
  return wrap;
}
