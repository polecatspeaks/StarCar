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
import { defaultOpenState, withGroupOpen, withStripOpen } from '../js/condition-open-state.js';

const positionDefs = [
  { id: 'live', label: 'Live', register: 'nominal' },
  { id: 'dark', label: 'Dark', register: 'nominal' },
  { id: 'bagged', label: 'Bagged', register: 'nominal' }
];
const outcomeDefs = [
  { id: 'REJECT', label: 'Reject', register: 'nominal' },
  { id: 'done', label: 'Done', register: 'nominal' }
];
const roleDefs = [{ id: 'car', label: 'Car', register: 'nominal' }];
const livenessDefs = [
  { id: 'returned', label: 'Returned', register: 'nominal' },
  { id: 'dispatched', label: 'Dispatched', register: 'in-progress' },
  { id: 'overdue', label: 'Overdue', register: 'needs-attention' },
  { id: 'presumed-lost', label: 'Presumed lost', register: 'needs-attention' }
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

// --- #69: open-state persistence (owner: "closes back up every page refresh") ---

test('#69: with no openState argument, the strip and every group stay collapsed - unchanged prior behaviour', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.board = [{ code: 'discovery', detail: 'outcome: completed', register: 'nominal' }];
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true }); // no 5th argument

  assert.equal(root.querySelectorAll('.board-conditions-strip')[0].attributes.open, undefined);
  assert.equal(root.querySelectorAll('.board-condition-group-details')[0]?.attributes.open, undefined);
});

test('#69: a persisted OPEN strip state renders with the open attribute set', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.board = [{ code: 'discovery', detail: 'outcome: completed', register: 'nominal' }];
  const openState = withStripOpen(defaultOpenState(), true);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true }, openState);

  assert.equal(root.querySelectorAll('.board-conditions-strip')[0].attributes.open, '');
});

test('#69: a persisted OPEN group renders with the open attribute set on that group\'s own <details>, per-group (not the whole strip)', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  snapshot.board = [
    { code: 'discovery', detail: 'outcome: completed', register: 'nominal' },
    { code: 'record-unrecognised-fields', detail: 'x', register: 'needs-attention' }
  ];
  const openState = withGroupOpen(defaultOpenState(), 'discovery', true);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true }, openState);

  // the OUTER strip must stay collapsed - opening one group is not the same
  // as opening the strip, and this ticket does not couple the two.
  assert.equal(root.querySelectorAll('.board-conditions-strip')[0].attributes.open, undefined);

  const groupDetails = root.querySelectorAll('.board-condition-group-details');
  const discoveryDetails = groupDetails.find((d) => d.attributes['data-condition-code'] === 'discovery');
  const unrecognisedDetails = groupDetails.find((d) => d.attributes['data-condition-code'] === 'record-unrecognised-fields');
  assert.equal(discoveryDetails.attributes.open, '', 'the previously-opened discovery group must render open');
  assert.equal(unrecognisedDetails.attributes.open, undefined, 'a DIFFERENT group must stay collapsed - per-group state, not one global flag');
});

test('#69 NEW-CONDITION-DEFAULTS-COLLAPSED: a condition code with NO entry in openState.groups renders collapsed, even when the strip itself is open', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]);
  // 'discovery' has never been toggled this session - openState.groups has no entry for it.
  snapshot.board = [{ code: 'discovery', detail: 'outcome: completed', register: 'nominal' }];
  const openState = withStripOpen(defaultOpenState(), true);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true }, openState);

  const groupDetails = root.querySelectorAll('.board-condition-group-details')[0];
  assert.equal(groupDetails.attributes.open, undefined, 'a never-toggled condition class must still default collapsed (#30)');
});

// --- #69/#71: board-condition entries become provenance links ---

test('#69/#71: a record-scoped condition instance (recordDir present, github config present) renders as a link to its record directory', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot(
    [{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }],
    githubCfg
  );
  snapshot.board = [{ code: 'manifest-record-not-found', detail: 'x', register: 'needs-attention', recordDir: 'train-x' }];
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const instances = root.querySelectorAll('.board-condition-instance');
  assert.equal(instances.length, 1);
  assert.equal(instances[0].tagName, 'a', 'expected the condition instance to render as an anchor');
  assert.equal(instances[0].attributes.href, 'https://github.com/polecatspeaks/StarCar/tree/dev/artifacts/train-x');
  assert.equal(instances[0].textContent, 'x', 'the detail text must still render VERBATIM once linked');
});

test('#69/#71: a discovery condition instance links to its VOCAB FILE, never a record directory', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot(
    [{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }],
    githubCfg
  );
  // a discovery NEVER carries recordDir on the wire (it names no subject) -
  // this also proves the link choice is driven by the group's CODE, not by
  // recordDir's mere presence/absence.
  snapshot.board = [{ code: 'discovery', detail: 'kind: some-unrecognised-kind', register: 'nominal' }];
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const instances = root.querySelectorAll('.board-condition-instance');
  assert.equal(instances.length, 1);
  assert.equal(instances[0].tagName, 'a', 'expected the discovery instance to render as an anchor');
  assert.equal(instances[0].attributes.href, 'https://github.com/polecatspeaks/StarCar/blob/dev/schema/vocab/kinds.json');
});

test('#69/#71: a condition instance with no resolvable target (no recordDir, not a discovery) renders as plain text - no fake link', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot(
    [{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }],
    githubCfg
  );
  snapshot.board = [{ code: 'board-defs-unreadable', detail: 'y', register: 'needs-attention' }]; // no recordDir - an aggregate/config-level fault
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const instances = root.querySelectorAll('.board-condition-instance');
  assert.equal(instances.length, 1);
  assert.notEqual(instances[0].tagName, 'a', 'expected plain text, never a broken/guessed link');
  assert.equal(instances[0].attributes.href, undefined);
  assert.equal(instances[0].textContent, 'y');
});

test('#69/#71: a record-scoped condition with NO github config renders as plain text, identical layout either way', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([{ id: 'dispatches', title: 'Dispatches', position: 'live', freshness: { kind: 'never-polled' }, data: { dispatches: [] } }]); // no githubCfg
  snapshot.board = [{ code: 'manifest-record-not-found', detail: 'x', register: 'needs-attention', recordDir: 'train-x' }];
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const instances = root.querySelectorAll('.board-condition-instance');
  assert.equal(instances.length, 1);
  assert.notEqual(instances[0].tagName, 'a');
  assert.equal(instances[0].textContent, 'x');
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

// --- #71: superseded entries link to the row's OWN recordDir (same subject, same directory) ---

test('#71: a train car with superseded entries renders each one as a link to the CAR\'S OWN recordDir, VERBATIM kind + at', () => {
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
              cars: [
                {
                  subject: 'carA',
                  role: 'car',
                  state: 'returned',
                  at: '2026-07-23T18:00:00Z',
                  recordDir: 'carA',
                  superseded: [{ kind: 'dispatched', at: '2026-07-23T17:00:00Z' }]
                }
              ],
              declaredNotObserved: []
            }
          ]
        }
      }
    ],
    githubCfg
  );
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const entries = root.querySelectorAll('.car-superseded-entry');
  assert.equal(entries.length, 1);
  assert.equal(entries[0].tagName, 'a', 'expected the superseded entry to render as a link');
  assert.equal(entries[0].attributes.href, 'https://github.com/polecatspeaks/StarCar/tree/dev/artifacts/carA', 'must link to the SAME recordDir as the car itself - same subject, same directory');
  assert.equal(entries[0].textContent, 'dispatched 2026-07-23T17:00:00Z');
});

test('#71: a car with no superseded entries renders no superseded list at all (honest-absence, never an empty one)', () => {
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
          { id: 'train:board-v0', title: 'T', tickets: [], cars: [{ subject: 'carA', role: 'car', state: 'returned', at: '2026-07-23T18:00:00Z', recordDir: 'carA' }], declaredNotObserved: [] }
        ]
      }
    }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  assert.equal(root.querySelectorAll('.car-superseded').length, 0);
  assert.equal(root.querySelectorAll('.car-superseded-entry').length, 0);
});

test('#71: a dispatch with superseded entries renders each one as a link to the DISPATCH\'S OWN recordDir', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot(
    [
      {
        id: 'dispatches',
        title: 'Dispatches',
        position: 'live',
        freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
        data: {
          dispatches: [
            {
              subject: 'orphan-1',
              state: 'returned',
              at: '2026-07-23T18:00:00Z',
              assigned: false,
              recordDir: 'orphan-1',
              superseded: [{ kind: 'dispatched', at: '2026-07-23T17:00:00Z' }]
            }
          ]
        }
      }
    ],
    githubCfg
  );
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const entries = root.querySelectorAll('.solari-superseded-entry');
  assert.equal(entries.length, 1);
  assert.equal(entries[0].tagName, 'a');
  assert.equal(entries[0].attributes.href, 'https://github.com/polecatspeaks/StarCar/tree/dev/artifacts/orphan-1');
  assert.equal(entries[0].textContent, 'dispatched 2026-07-23T17:00:00Z');
});

test('#71: superseded entries with no github config render as plain text, identical layout either way', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: {
        dispatches: [
          {
            subject: 'orphan-1',
            state: 'returned',
            at: '2026-07-23T18:00:00Z',
            assigned: false,
            recordDir: 'orphan-1',
            superseded: [{ kind: 'dispatched', at: '2026-07-23T17:00:00Z' }]
          }
        ]
      }
    }
  ]); // no githubCfg
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const entries = root.querySelectorAll('.solari-superseded-entry');
  assert.equal(entries.length, 1);
  assert.notEqual(entries[0].tagName, 'a');
  assert.equal(entries[0].textContent, 'dispatched 2026-07-23T17:00:00Z');
});

// --- #71 fix-cycle round 2 (MAJOR-R1-1, owner-ruled #69): a superseded
// block must be a DOM DESCENDANT of its owner row/chip, never a sibling
// cell - round 1's fixture seeded exactly one subject, which structurally
// cannot exhibit a wrap-boundary orphan (a one-item grid/flex container has
// nothing to wrap onto). This fixture seeds 5 subjects (the reviewer's own
// recipe: "5 or more cars in .track-cars" / "5 or more rows in
// .solari-rows", each with one superseded entry) and asserts the STRUCTURAL
// fact directly - .track-cars / .solari-rows must contain ONLY chip/row
// children, and each chip/row must carry its own superseded disclosure as
// a descendant - rather than re-measuring pixel geometry, because the
// defect is a DOM-shape defect, not merely a rendering-coincidence one.

test('#71 fix-cycle r2 (MAJOR-R1-1): with 5 cars each carrying a superseded entry, .track-cars holds ONLY car-chip children - the superseded block is nested INSIDE its own chip, never a wrap-vulnerable sibling', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const cars = [];
  for (let i = 0; i < 5; i += 1) {
    cars.push({
      subject: `car-${i}`,
      role: 'car',
      state: 'returned',
      at: '2026-07-23T18:00:00Z',
      recordDir: `car-${i}`,
      superseded: [{ kind: 'dispatched', at: '2026-07-23T17:00:00Z' }]
    });
  }
  const snapshot = makeSnapshot(
    [
      {
        id: 'trains',
        title: 'Trains',
        position: 'live',
        freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
        data: { trains: [{ id: 'train:board-v0', title: 'T', tickets: [], cars, declaredNotObserved: [] }] }
      }
    ],
    githubCfg
  );
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const trackCars = root.querySelectorAll('.track-cars');
  assert.equal(trackCars.length, 1);
  const directChildren = trackCars[0].children;
  assert.equal(directChildren.length, 5, '.track-cars must hold exactly one child per car - a sibling superseded block would add extra direct children');
  for (const child of directChildren) {
    assert.ok(
      child.className.split(' ').includes('car-chip'),
      `every direct child of .track-cars must be a car-chip - found '${child.className}' (MAJOR-R1-1: an orphaned superseded block sibling)`
    );
  }

  const chips = trackCars[0].querySelectorAll('.car-chip');
  assert.equal(chips.length, 5);
  for (const chip of chips) {
    const nested = chip.querySelectorAll('.car-superseded-entry');
    assert.equal(nested.length, 1, 'each car with a superseded entry must carry its superseded block as a DESCENDANT of its own chip');
  }
});

test('#71 fix-cycle r2 (MAJOR-R1-1): with 5 dispatches each carrying a superseded entry, .solari-rows holds ONLY solari-row children - the superseded block is nested INSIDE its own row, never a wrap-vulnerable sibling', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  // #67's capTerminalHistory (history-filter.js, TERMINAL_HISTORY_CAP=4)
  // caps TERMINAL rows (state 'returned') at 4 regardless of this test's
  // intent, and is deliberately out of scope for this fix (MAJOR-R1-1's
  // ruling touches only nesting, never the cap contract). So exactly ONE
  // of the 5 stays non-terminal ('dispatched') to keep all 5 visible - 4
  // terminal entries is at, not over, the cap, so none are hidden.
  const dispatches = [];
  for (let i = 0; i < 5; i += 1) {
    dispatches.push({
      subject: `orphan-${i}`,
      state: i === 0 ? 'dispatched' : 'returned',
      at: '2026-07-23T18:00:00Z',
      assigned: false,
      recordDir: `orphan-${i}`,
      superseded: [{ kind: 'dispatched', at: '2026-07-23T17:00:00Z' }]
    });
  }
  const snapshot = makeSnapshot(
    [
      {
        id: 'dispatches',
        title: 'Dispatches',
        position: 'live',
        freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
        data: { dispatches }
      }
    ],
    githubCfg
  );
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const solariRows = root.querySelectorAll('.solari-rows');
  assert.equal(solariRows.length, 1);
  const directChildren = solariRows[0].children;
  assert.equal(directChildren.length, 5, '.solari-rows must hold exactly one child per dispatch - a sibling superseded block would add extra direct children');
  for (const child of directChildren) {
    assert.ok(
      child.className.split(' ').includes('solari-row'),
      `every direct child of .solari-rows must be a solari-row - found '${child.className}' (MAJOR-R1-1: an orphaned superseded block sibling)`
    );
  }

  const rows = solariRows[0].querySelectorAll('.solari-row');
  assert.equal(rows.length, 5);
  for (const row of rows) {
    const nested = row.querySelectorAll('.solari-superseded-entry');
    assert.equal(nested.length, 1, 'each dispatch with a superseded entry must carry its superseded block as a DESCENDANT of its own row');
  }
});

// --- #69/#71 fix-cycle round 2 (MINOR-R1-2): a malformed superseded item
// (missing/non-string kind or at) is skipped, never rendered as literal
// "undefined undefined" text - Law 1 honest-absence, matching this file's
// other honest-absence conventions.

test("#71 fix-cycle r2 (MINOR-R1-2): a malformed superseded item (missing 'at') is skipped - never rendered as literal 'undefined undefined'", () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot(
    [
      {
        id: 'dispatches',
        title: 'Dispatches',
        position: 'live',
        freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
        data: {
          dispatches: [
            {
              subject: 'orphan-1',
              state: 'returned',
              at: '2026-07-23T18:00:00Z',
              assigned: false,
              recordDir: 'orphan-1',
              // one well-formed entry, one malformed (no `at`) - proves the
              // GOOD entry still renders while the bad one is dropped, not
              // that malformed input blanks the whole list.
              superseded: [
                { kind: 'dispatched', at: '2026-07-23T17:00:00Z' },
                { kind: 'dispatched' }
              ]
            }
          ]
        }
      }
    ],
    githubCfg
  );
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const entries = root.querySelectorAll('.solari-superseded-entry');
  assert.equal(entries.length, 1, 'the malformed item must be skipped, leaving only the well-formed one');
  assert.equal(entries[0].textContent, 'dispatched 2026-07-23T17:00:00Z');
  for (const entry of entries) {
    assert.ok(!entry.textContent.includes('undefined'), `must never render the literal word 'undefined', got '${entry.textContent}'`);
  }
});

test('#71 fix-cycle r2 (MINOR-R1-2): when EVERY superseded item is malformed, no disclosure renders at all - never an empty one', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot(
    [
      {
        id: 'dispatches',
        title: 'Dispatches',
        position: 'live',
        freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
        data: {
          dispatches: [
            {
              subject: 'orphan-1',
              state: 'returned',
              at: '2026-07-23T18:00:00Z',
              assigned: false,
              recordDir: 'orphan-1',
              superseded: [{ kind: 'dispatched' }, { at: '2026-07-23T17:00:00Z' }]
            }
          ]
        }
      }
    ],
    githubCfg
  );
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  assert.equal(root.querySelectorAll('.solari-superseded-disclosure').length, 0);
  assert.equal(root.querySelectorAll('.solari-superseded-entry').length, 0);
});

// #71 fix cycle r3 (MINOR-R2-1): the owner-ruled "COLLAPSED by default"
// (issue #69's M1 ruling) had zero regression pin - board.css's own comment
// asserted it by READING renderSupersededDisclosure, never by a test that
// would catch a future `details.setAttribute('open', '')` regression. This
// pins BOTH owners (a car chip's disclosure and a dispatch row's) never
// carry an `open` attribute, however many superseded entries they have.
test("#71 fix cycle r3 (MINOR-R2-1): a superseded disclosure NEVER carries an 'open' attribute - collapsed by default is a REGRESSION PIN, not just a comment", () => {
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
              cars: [
                {
                  subject: 'carA',
                  role: 'car',
                  state: 'returned',
                  at: '2026-07-23T18:00:00Z',
                  recordDir: 'carA',
                  superseded: [{ kind: 'dispatched', at: '2026-07-23T17:00:00Z' }]
                }
              ],
              declaredNotObserved: []
            }
          ]
        }
      },
      {
        id: 'dispatches',
        title: 'Dispatches',
        position: 'live',
        freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
        data: {
          dispatches: [
            {
              subject: 'orphan-1',
              state: 'returned',
              at: '2026-07-23T18:00:00Z',
              assigned: false,
              recordDir: 'orphan-1',
              superseded: [{ kind: 'dispatched', at: '2026-07-23T17:00:00Z' }]
            }
          ]
        }
      }
    ],
    githubCfg
  );
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const disclosures = [...root.querySelectorAll('.car-superseded-disclosure'), ...root.querySelectorAll('.solari-superseded-disclosure')];
  assert.equal(disclosures.length, 2, 'test precondition not met: expected one car disclosure and one dispatch-row disclosure');
  for (const details of disclosures) {
    assert.ok(
      !('open' in details.attributes),
      `REGRESSION (MINOR-R2-1): a superseded disclosure carries an 'open' attribute (${JSON.stringify(details.attributes)}) - the owner ruling is COLLAPSED by default`
    );
  }
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

// --- #67: compact clock time (owner FORMAT NIT, 2026-07-26 17:16) ---

test('#67: a dispatch elapsed time renders compact clock time (4m32s -> "4:32"), never a unit-suffixed number', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: { dispatches: [{ subject: 'abc123', state: 'dispatched', at: '2026-07-23T18:00:00Z', assigned: true, elapsed_seconds: 272 }] }
    }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const elapsed = root.querySelectorAll('.solari-elapsed');
  assert.equal(elapsed.length, 1);
  assert.equal(elapsed[0].textContent, '4:32', `expected compact clock time, got: ${elapsed[0].textContent}`);
  assert.ok(!root.textContent.includes('272s'), 'the old unit-suffixed form must never appear');
});

// --- #67: dispatches/trains lane filters - DOM-level proof ---

function dispatchFixture(subject, state, at, assigned = true) {
  return { subject, state, at, assigned };
}

test('#67 NEVER FILTER A HOT ROW (DOM level): a needs-attention dispatch older than every capped-out returned dispatch still produces a rendered row', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: {
        dispatches: [
          dispatchFixture('ancient-hot', 'presumed-lost', '2020-01-01T00:00:00Z'),
          dispatchFixture('r1', 'returned', '2026-07-01T00:00:00Z'),
          dispatchFixture('r2', 'returned', '2026-07-02T00:00:00Z'),
          dispatchFixture('r3', 'returned', '2026-07-03T00:00:00Z'),
          dispatchFixture('r4', 'returned', '2026-07-04T00:00:00Z'),
          dispatchFixture('r5', 'returned', '2026-07-05T00:00:00Z')
        ]
      }
    }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const rows = root.querySelectorAll('.solari-row');
  assert.equal(rows.length, 5, '4 capped returned rows + the 1 always-visible hot row');
  assert.ok(root.textContent.includes('ancient-hot'), 'the oldest needs-attention row must still be in the rendered DOM');
});

test('#67: the dispatches history summary renders true derived counts, quiet chrome (nominal register)', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: {
        dispatches: [
          dispatchFixture('r1', 'returned', '2026-07-01T00:00:00Z'),
          dispatchFixture('r2', 'returned', '2026-07-02T00:00:00Z'),
          dispatchFixture('r3', 'returned', '2026-07-03T00:00:00Z'),
          dispatchFixture('r4', 'returned', '2026-07-04T00:00:00Z'),
          dispatchFixture('r5', 'returned', '2026-07-05T00:00:00Z')
        ]
      }
    }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const summary = root.querySelectorAll('.history-summary');
  assert.equal(summary.length, 1);
  assert.equal(summary[0].textContent, 'showing last 4 of 5 returned - full record in the store');
  assert.ok(summary[0].className.includes('register-nominal'), 'the summary line is quiet chrome, never a headline (#62 idiom)');
});

test('#67: no hidden history means no summary line rendered at all (never a "showing 0 of 0" noise line)', () => {
  const doc = createMiniDocument();
  const root = doc.createElement('main');
  const snapshot = makeSnapshot([
    {
      id: 'dispatches',
      title: 'Dispatches',
      position: 'live',
      freshness: { kind: 'fresh', asOf: '2026-07-23T18:00:00Z' },
      data: { dispatches: [dispatchFixture('r1', 'returned', '2026-07-01T00:00:00Z')] }
    }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  assert.equal(root.querySelectorAll('.history-summary').length, 0);
});

function trainFixture(id, cars, declaredNotObserved = []) {
  return { id, title: id, cars, declaredNotObserved };
}

function carFixture(subject, state, at, outcome) {
  return outcome ? { subject, role: 'car', state, at, outcome } : { subject, role: 'car', state, at };
}

test('#67 NEVER FILTER A HOT ROW (DOM level): a train with an in-flight car renders its track regardless of recency', () => {
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
          trainFixture('train:rolling-ancient', [carFixture('rolling-car', 'dispatched', '2020-01-01T00:00:00Z')]),
          trainFixture('train:t1', [carFixture('c1', 'returned', '2026-07-01T00:00:00Z', 'done')]),
          trainFixture('train:t2', [carFixture('c2', 'returned', '2026-07-02T00:00:00Z', 'done')]),
          trainFixture('train:t3', [carFixture('c3', 'returned', '2026-07-03T00:00:00Z', 'done')]),
          trainFixture('train:t4', [carFixture('c4', 'returned', '2026-07-04T00:00:00Z', 'done')]),
          trainFixture('train:t5', [carFixture('c5', 'returned', '2026-07-05T00:00:00Z', 'done')])
        ]
      }
    }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const tracks = root.querySelectorAll('.track');
  assert.equal(tracks.length, 5, '4 capped returned trains + the 1 always-visible rolling train');
  assert.ok(root.textContent.includes('train:rolling-ancient'), 'the rolling train must still be in the rendered DOM');
});

test('#67: the trains history summary renders true derived counts', () => {
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
          trainFixture('train:t1', [carFixture('c1', 'returned', '2026-07-01T00:00:00Z', 'done')]),
          trainFixture('train:t2', [carFixture('c2', 'returned', '2026-07-02T00:00:00Z', 'done')]),
          trainFixture('train:t3', [carFixture('c3', 'returned', '2026-07-03T00:00:00Z', 'done')]),
          trainFixture('train:t4', [carFixture('c4', 'returned', '2026-07-04T00:00:00Z', 'done')]),
          trainFixture('train:t5', [carFixture('c5', 'returned', '2026-07-05T00:00:00Z', 'done')])
        ]
      }
    }
  ]);
  renderBoard(doc, root, buildBoardViewModel(snapshot), { connected: true });

  const summary = root.querySelectorAll('.history-summary');
  assert.equal(summary.length, 1);
  // #67 R2 NOTE-1: trains use the owner's exact ticket wording, no noun -
  // a train is never literally "returned" on the wire.
  assert.equal(summary[0].textContent, 'showing last 4 of 5 - full record in the store');
});
