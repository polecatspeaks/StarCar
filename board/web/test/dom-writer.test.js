// Task 5.5's DOM-level smoke: dom-writer.js is pure ESM (no `document`
// reference outside its function arguments), so it runs unmodified against
// a hand-rolled minimal shim (minidom.js) here in Node - no jsdom, no npm
// install, no network. This is DIFFERENT from render.test.js (which checks
// the pure VIEW MODEL's shape): this suite checks that the DOM WRITER
// actually turns that view model into element structure with the right
// register classes and verbatim text.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createMiniDocument } from './minidom.js';
import { renderBoard } from '../js/dom-writer.js';
import { buildBoardViewModel } from '../js/render.js';

const positionDefs = [
  { id: 'live', label: 'Live', register: 'nominal' },
  { id: 'dark', label: 'Dark', register: 'nominal' },
  { id: 'bagged', label: 'Bagged', register: 'nominal' }
];
const outcomeDefs = [{ id: 'REJECT', label: 'Reject', register: 'nominal' }];
const roleDefs = [{ id: 'car', label: 'Car', register: 'nominal' }];
const livenessDefs = [
  { id: 'returned', label: 'Returned', register: 'nominal' },
  { id: 'overdue', label: 'Overdue', register: 'needs-attention' }
];

function makeSnapshot(lanes, extra = {}) {
  return {
    seq: 1,
    asOf: '2026-07-23T18:00:00Z',
    config: { pollMs: 1000, heartbeatMs: 5000, stalenessMs: 15000, storePathDisplay: '<repo>/artifacts', laneCount: lanes.length, demoMode: false, ...extra },
    vocabularies: { positions: positionDefs, outcomes: outcomeDefs, roles: roleDefs, liveness: livenessDefs },
    board: [],
    lanes
  };
}

test('renderBoard draws one section per lane, with a register class and a verbatim state word', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: { dispatches: [{ subject: 'abc123', state: 'quarantined', at: '2026-07-23T18:00:00Z', assigned: false }] }
    }
  ]);
  const vm = buildBoardViewModel(snapshot);
  renderBoard(doc, root, vm, { connected: true });

  const laneSections = root.querySelectorAll('.lane');
  assert.equal(laneSections.length, 1);

  const hot = root.querySelectorAll('.register-needs-attention');
  assert.ok(hot.length > 0, 'an unrecognised state word must produce a needs-attention-classed element');

  // The raw, unrecognised state word renders VERBATIM somewhere in the tree
  // - never translated, never hidden.
  assert.ok(root.textContent.includes('quarantined'), `expected "quarantined" verbatim in rendered output: ${root.textContent}`);
});

test('renderBoard shows the DEMO banner only when config.demoMode is true (spec YB-15)', () => {
  const doc = createMiniDocument();
  const demoSnapshot = makeSnapshot([], { demoMode: true });
  const rootDemo = doc.createElement('main');
  renderBoard(doc, rootDemo, buildBoardViewModel(demoSnapshot), { connected: true });
  assert.ok(rootDemo.querySelectorAll('.demo-banner').length === 1, 'DEMO banner must render when demoMode is true');

  const liveSnapshot = makeSnapshot([], { demoMode: false });
  const rootLive = doc.createElement('main');
  renderBoard(doc, rootLive, buildBoardViewModel(liveSnapshot), { connected: true });
  assert.equal(rootLive.querySelectorAll('.demo-banner').length, 0, 'DEMO banner must NOT render when demoMode is false');
});

test('renderBoard marks a disconnected connection state while keeping the last-known picture on screen', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'freight', title: 'Freight', position: 'dark', freshness: { kind: 'not-applicable' } }]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: false });

  assert.equal(root.querySelectorAll('.connection-disconnected').length, 1);
  // The lane itself must STILL be present and rendered - disconnected chrome
  // never blanks the last-known picture.
  assert.equal(root.querySelectorAll('.lane').length, 1);
});

// --- #30: board conditions as COLLAPSED, GROUPED chrome ---

test('#30 PLACEMENT: the board-conditions strip renders as a <details> (collapsed by default - no "open" attribute) with a <summary> carrying the roll-up line, never the full detail list at top level', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.board = [
    { code: 'record-unrecognised-fields', detail: 'x.json: 1 unrecognised field', register: 'needs-attention' },
    { code: 'discovery', detail: 'outcome: completed', register: 'nominal' },
    { code: 'discovery', detail: 'outcome: approve-for-merge', register: 'nominal' }
  ];
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const strips = root.querySelectorAll('.board-conditions-strip');
  assert.equal(strips.length, 1, 'exactly one conditions strip');
  const strip = strips[0];
  assert.equal(strip.tagName, 'details', 'the strip is a native <details> element - expand/collapse needs no JS');
  assert.equal(strip.attributes.open, undefined, 'COLLAPSED by default - the summary line is chrome, the lanes stay above the fold');

  const summaries = root.querySelectorAll('.board-conditions-summary');
  assert.equal(summaries.length, 1);
  assert.equal(summaries[0].textContent, '1 FLAG + 2 notes');

  // The full per-instance detail text must NOT appear at the top level of
  // textContent in a way indistinguishable from the summary - it lives
  // inside the (collapsed) group structure, verified by the grouping test
  // below. This assertion only pins that the outer summary line itself is
  // exactly the roll-up, not detail-laden.
  assert.ok(!summaries[0].textContent.includes('outcome:'));
});

test('#30 GROUP BY CLASS: one row per code with a count, each expandable (its own <details>) to per-instance detail text, VERBATIM', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.board = [
    { code: 'discovery', detail: 'outcome: completed', register: 'nominal' },
    { code: 'discovery', detail: 'outcome: approve-for-merge', register: 'nominal' }
  ];
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const groups = root.querySelectorAll('.board-condition-group');
  assert.equal(groups.length, 1, 'one group for the one distinct code');
  assert.ok(groups[0].className.includes('register-nominal'), 'a NOTE-tier group renders the calm register class');

  const groupSummaries = root.querySelectorAll('.board-condition-group-summary');
  assert.equal(groupSummaries.length, 1);
  assert.equal(groupSummaries[0].textContent, 'discovery (x2)');

  const instances = root.querySelectorAll('.board-condition-instance');
  assert.equal(instances.length, 2);
  assert.deepEqual(
    instances.map((i) => i.textContent).sort(),
    ['outcome: approve-for-merge', 'outcome: completed']
  );
});

test('#30 SEVERITY PER CLASS: a FLAG-tier group renders needs-attention, a NOTE-tier group renders nominal - register is never recomputed by the view (Rule 4), only grouped', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.board = [
    { code: 'record-unrecognised-fields', detail: 'x', register: 'needs-attention' },
    { code: 'discovery', detail: 'outcome: completed', register: 'nominal' }
  ];
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const groups = root.querySelectorAll('.board-condition-group');
  const flagGroup = groups.find((g) => g.textContent.includes('record-unrecognised-fields'));
  assert.ok(flagGroup, 'expected to find the record-unrecognised-fields group');
  assert.ok(flagGroup.className.includes('register-needs-attention'));

  const noteGroup = groups.find((g) => g.textContent.includes('discovery'));
  assert.ok(noteGroup);
  assert.ok(noteGroup.className.includes('register-nominal'));
});

// --- #62: shared visual language (owner ruling: no single keeper) ---

test('#62: renderBoard renders a brand element carrying the product name, once, in the header chrome', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  renderBoard(doc, root, buildBoardViewModel(makeSnapshot([])), { connected: true });

  const brands = root.querySelectorAll('.brand');
  assert.equal(brands.length, 1, 'expected exactly one .brand element');
  assert.ok(brands[0].textContent.includes('STARCAR'), `expected the brand element to carry "STARCAR", got: ${brands[0].textContent}`);
});

test('#62: renderBoard renders a footer honesty-chrome strip carrying the real storePathDisplay wire field', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([], { storePathDisplay: '<repo>/artifacts' });
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const footers = root.querySelectorAll('.board-footer');
  assert.equal(footers.length, 1, 'expected exactly one .board-footer element');
  assert.ok(
    footers[0].textContent.includes('<repo>/artifacts'),
    `expected the footer to render storePathDisplay verbatim, got: ${footers[0].textContent}`
  );
});

test('#62: the board-conditions strip lives inside the footer (moved from top chrome, never duplicated)', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([]);
  snapshot.board = [{ code: 'discovery', detail: 'outcome: completed', register: 'nominal' }];
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const strips = root.querySelectorAll('.board-conditions-strip');
  assert.equal(strips.length, 1, 'exactly one conditions strip, never duplicated');

  const footers = root.querySelectorAll('.board-footer');
  assert.equal(footers.length, 1);
  assert.ok(
    footers[0].children.includes(strips[0]),
    'expected the board-conditions-strip to be a direct child of .board-footer'
  );
});

test('#62: renderBoard renders each lane as a plate (title/purpose/freshness) beside its content, with a lane-purpose subtitle drawn from the view model', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'freight', title: 'Freight', position: 'dark', freshness: { kind: 'not-applicable' } }]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const plates = root.querySelectorAll('.lane-plate');
  assert.equal(plates.length, 1, 'expected one lane-plate per lane');
  const contents = root.querySelectorAll('.lane-content');
  assert.equal(contents.length, 1, 'expected one lane-content per lane');

  const purposes = root.querySelectorAll('.lane-purpose');
  assert.equal(purposes.length, 1);
  assert.equal(purposes[0].textContent, 'the inbound ticket queue');
});

test('#62: renderBoard numbers lanes by their declared position in the registry (1-based ordinal)', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    { id: 'trains', title: 'Trains', position: 'dark', freshness: { kind: 'not-applicable' } },
    { id: 'gates', title: 'Gates', position: 'dark', freshness: { kind: 'not-applicable' } }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const ordinals = root.querySelectorAll('.lane-ordinal');
  assert.equal(ordinals.length, 2);
  assert.equal(ordinals[0].textContent, '1');
  assert.equal(ordinals[1].textContent, '2');
});

test('#62: a solari-subject carries the full subject as a title attribute (CSS truncates it visually - never silently, the full text stays reachable on hover)', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: { dispatches: [{ subject: '2026-07-22-harness-design-round4-REJECT-ESCALATED', state: 'returned', at: '2026-07-23T18:00:00Z', assigned: true }] }
    }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const subjects = root.querySelectorAll('.solari-subject');
  assert.equal(subjects.length, 1);
  assert.equal(subjects[0].attributes.title, '2026-07-22-harness-design-round4-REJECT-ESCALATED');
});

test('#62 N3: an empty-but-live gates lane (zero gates in this fold) states its absence honestly, rather than rendering a blank pane; a non-empty gates lane does not', () => {
  const doc = createMiniDocument();

  const emptyRoot = doc.createElement('main');
  const emptySnapshot = makeSnapshot([
    { id: 'gates', title: 'Gates', position: 'live', freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' }, data: { gates: [] } }
  ]);
  renderBoard(doc, emptyRoot, buildBoardViewModel(emptySnapshot), { connected: true });
  const emptyNotices = emptyRoot.querySelectorAll('.lane-body-gates-empty');
  assert.equal(emptyNotices.length, 1, 'expected a stated-absence element for a zero-gates fold');
  assert.ok(emptyNotices[0].textContent.length > 0, 'the stated absence must carry non-empty text');

  const fullRoot = doc.createElement('main');
  const fullSnapshot = makeSnapshot([
    {
      id: 'gates',
      title: 'Gates',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: { gates: [{ name: 'design round 1', subject: 'abc', outcome: 'REJECT', at: '2026-07-23T18:00:00Z' }] }
    }
  ]);
  renderBoard(doc, fullRoot, buildBoardViewModel(fullSnapshot), { connected: true });
  const fullNotices = fullRoot.querySelectorAll('.lane-body-gates-empty');
  assert.equal(fullNotices.length, 0, 'a gates lane WITH gates must not render the empty-absence notice');
});

// --- #28: clickable provenance ---------------------------------------------

const githubCfg = {
  githubRepoUrl: 'https://github.com/polecatspeaks/StarCar',
  githubRef: 'dev',
  githubArtifactsPrefix: 'artifacts'
};

test('#28: a car subject renders as a link to its record directory when github config + recordDir are both present', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot(
    [
      {
        id: 'trains',
        title: 'Trains',
        position: 'live',
        freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
        data: {
          trains: [
            {
              id: 'train:board-v0',
              title: 'T',
              tickets: [],
              cars: [{ subject: 'carA', role: 'car', state: 'returned', at: '2026-07-23T18:00:00Z', recordDir: 'carA' }],
              declaredNotObserved: []
            }
          ]
        }
      }
    ],
    githubCfg
  );
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const subjects = root.querySelectorAll('.car-subject');
  assert.equal(subjects.length, 1);
  assert.equal(subjects[0].tagName, 'a', 'expected the car subject to render as an anchor');
  assert.equal(subjects[0].attributes.href, 'https://github.com/polecatspeaks/StarCar/tree/dev/artifacts/carA');
  assert.equal(subjects[0].textContent, 'carA');
});

test('#28: a car subject with NO recordDir (or no github config) renders as plain text, never a broken link', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'trains',
      title: 'Trains',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: {
        trains: [
          { id: 'train:board-v0', title: 'T', tickets: [], cars: [{ subject: 'carA', role: 'car', state: 'returned', at: '2026-07-23T18:00:00Z' }], declaredNotObserved: [] }
        ]
      }
    }
  ]); // no githubCfg extra - unconfigured
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const subjects = root.querySelectorAll('.car-subject');
  assert.equal(subjects.length, 1);
  assert.notEqual(subjects[0].tagName, 'a', 'expected plain text, not a link, when recordDir/github config is absent');
  assert.equal(subjects[0].attributes.href, undefined);
});

test('#28: a train\'s declared tickets render as issue links', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot(
    [
      {
        id: 'trains',
        title: 'Trains',
        position: 'live',
        freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
        data: { trains: [{ id: 'train:view-28-12', title: 'T', tickets: ['#28', '#12'], cars: [], declaredNotObserved: [] }] }
      }
    ],
    githubCfg
  );
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const ticketLinks = root.querySelectorAll('.ticket-link');
  assert.equal(ticketLinks.length, 2);
  assert.equal(ticketLinks[0].attributes.href, 'https://github.com/polecatspeaks/StarCar/issues/28');
  assert.equal(ticketLinks[0].textContent, '#28');
  assert.equal(ticketLinks[1].attributes.href, 'https://github.com/polecatspeaks/StarCar/issues/12');
});

test('#28: a train with no declared tickets renders no ticket links at all', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot(
    [
      {
        id: 'trains',
        title: 'Trains',
        position: 'live',
        freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
        data: { trains: [{ id: 'train:x', title: 'T', tickets: [], cars: [], declaredNotObserved: [] }] }
      }
    ],
    githubCfg
  );
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });
  assert.equal(root.querySelectorAll('.ticket-link').length, 0);
});

test('#28: a gate signal name renders as a link to its record directory', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot(
    [
      {
        id: 'gates',
        title: 'Gates',
        position: 'live',
        freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
        data: { gates: [{ name: 'design review round 1', subject: 'gate-1', outcome: 'REJECT', at: '2026-07-23T18:00:00Z', recordDir: 'gate-1' }] }
      }
    ],
    githubCfg
  );
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const names = root.querySelectorAll('.signal-name');
  assert.equal(names.length, 1);
  assert.equal(names[0].tagName, 'a');
  assert.equal(names[0].attributes.href, 'https://github.com/polecatspeaks/StarCar/tree/dev/artifacts/gate-1');
});

test('#28: a solari (dispatch) subject renders as a link when recordDir is present, keeping its title tooltip', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot(
    [
      {
        id: 'dispatches',
        title: 'Dispatches',
        position: 'live',
        freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
        data: { dispatches: [{ subject: 'orphan-1', state: 'dispatched', at: '2026-07-23T18:00:00Z', assigned: false, recordDir: 'orphan-1' }] }
      }
    ],
    githubCfg
  );
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const subjects = root.querySelectorAll('.solari-subject');
  assert.equal(subjects.length, 1);
  assert.equal(subjects[0].tagName, 'a');
  assert.equal(subjects[0].attributes.href, 'https://github.com/polecatspeaks/StarCar/tree/dev/artifacts/orphan-1');
  assert.equal(subjects[0].attributes.title, 'orphan-1', 'the full-subject title tooltip must survive becoming a link');
});

// --- #12: car health bar ----------------------------------------------------

test('#12: a converged family (majors reaches 0) renders a calm health-trend badge with the series, on the LATEST round only', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'gates',
      title: 'Gates',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: {
        gates: [
          { name: 'r1', subject: 'x-review-r1', outcome: 'REJECT', at: '2026-07-23T00:00:00Z', findings: '7 Major, 0 Minor' },
          { name: 'r2', subject: 'x-review-r2', outcome: 'REJECT', at: '2026-07-23T01:00:00Z', findings: '1 Major, 0 Minor' },
          { name: 'r3', subject: 'x-review-r3', outcome: 'APPROVE', at: '2026-07-23T02:00:00Z', findings: '0 Major, 0 Minor' }
        ]
      }
    }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const badges = root.querySelectorAll('.health-trend');
  assert.equal(badges.length, 1, 'exactly one badge - only the family\'s LATEST round carries it');
  assert.ok(badges[0].className.includes('register-nominal'), 'a converged trend must render the CALM register, never a 4th color');
  assert.ok(badges[0].textContent.includes('7'), `expected the series in the badge text, got: ${badges[0].textContent}`);
  assert.ok(badges[0].textContent.includes('0'));
});

test('#12: a stalled family (3 -> 4 -> 4) renders needs-attention - the swirl signature, never silently calm', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'gates',
      title: 'Gates',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: {
        gates: [
          { name: 'r1', subject: 'tooling-50-32-review-r1', outcome: 'REJECT', at: '2026-07-23T00:00:00Z', findings: '3 Major, 2 Minor' },
          { name: 'r2', subject: 'tooling-50-32-review-r2', outcome: 'REJECT', at: '2026-07-23T01:00:00Z', findings: '4 Major, 1 Minor' },
          { name: 'r3', subject: 'tooling-50-32-review-r3', outcome: 'REJECT', at: '2026-07-23T02:00:00Z', findings: '4 Major, 0 Minor' }
        ]
      }
    }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const badges = root.querySelectorAll('.health-trend');
  assert.equal(badges.length, 1);
  assert.ok(badges[0].className.includes('register-needs-attention'), 'a stalled/climbing trend must render HOT, never calm');
});

test('#12: a first-round (no history yet) gate renders a NEUTRAL badge - never colored hot just because Majors > 0 on round 1 (a REJECT with Majors is normal traffic)', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'gates',
      title: 'Gates',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: { gates: [{ name: 'r1', subject: 'solo-review-r1', outcome: 'REJECT', at: '2026-07-23T00:00:00Z', findings: '3 Major, 1 Minor' }] }
    }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const badges = root.querySelectorAll('.health-trend');
  assert.equal(badges.length, 1);
  assert.ok(!badges[0].className.includes('register-needs-attention'), 'round 1 alone must never render hot');
  assert.ok(!badges[0].className.includes('register-nominal'), 'round 1 has no trend yet - distinct from a genuinely calm converged trend');
});

test('#12: unparseable findings renders a neutral "unknown" badge, never a guessed count', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'gates',
      title: 'Gates',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: { gates: [{ name: 'r1', subject: 'solo-review-r1', outcome: 'REJECT', at: '2026-07-23T00:00:00Z' }] }
    }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const badges = root.querySelectorAll('.health-trend');
  assert.equal(badges.length, 1);
  assert.ok(!badges[0].className.includes('register-needs-attention'));
  assert.ok(!badges[0].className.includes('register-nominal'));
  assert.ok(badges[0].textContent.toLowerCase().includes('unknown'));
});

test('renderBoard distinguishes bagged (fuel) and dark (freight) with different rendered text', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    { id: 'freight', title: 'Freight', position: 'dark', freshness: { kind: 'not-applicable' } },
    { id: 'fuel', title: 'Fuel', position: 'bagged', freshness: { kind: 'not-applicable' } }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const dark = root.querySelectorAll('.lane-body-dark');
  const bagged = root.querySelectorAll('.lane-body-bagged');
  assert.equal(dark.length, 1);
  assert.equal(bagged.length, 1);
  assert.notEqual(dark[0].textContent, bagged[0].textContent);
});
