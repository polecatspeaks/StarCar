// compose.js - THE composition engine (design rev 5 S5.2 Rules 1-4; spec
// YB-6). Pure functions only: no DOM, no fetch, no clock reads - every
// input is a value already on the wire (a lane's position/freshness, the
// current snapshot's vocabularies.positions defs, and whether a renderer
// exists for this lane's payload shape). That purity is what makes the
// THREE-AXIS matrix (board/web/test/compose.test.js) exhaustively testable
// in Node with no browser.
import { describeVocab } from './vocab.js';

// The ONLY closed taxonomy (design S5.2) and its severity order. Growing
// this set is a constitution-level decision (schema/yard-snapshot.schema.json
// $defs.register's own description says the same).
export const REGISTER_ORDER = ['nominal', 'in-progress', 'needs-attention'];

function rank(register) {
  const i = REGISTER_ORDER.indexOf(register);
  // An unrecognised register STRING (not id - a register value itself)
  // is a discovery, not a silent "calm" - never let unknown sort as fine.
  return i === -1 ? REGISTER_ORDER.length : i;
}

// Rule 1: rendered register = MOST SEVERE of the axes given.
export function mostSevereRegister(...registers) {
  return registers.reduce((worst, r) => (rank(r) > rank(worst) ? r : worst), REGISTER_ORDER[0]);
}

// Position's register: from its def (vocabularies.positions); an
// unrecognised position id renders needs-attention (design Rule 1: "needs-
// attention if unrecognised").
export function positionRegister(positionId, positionDefs) {
  return describeVocab(positionId, positionDefs).register;
}

// Freshness's register: the design's closed mapping (S5.2):
// not-applicable -> nominal, never-polled -> in-progress, fresh -> nominal,
// stale -> needs-attention, failed -> needs-attention.
const FRESHNESS_REGISTER = {
  'not-applicable': 'nominal',
  'never-polled': 'in-progress',
  fresh: 'nominal',
  stale: 'needs-attention',
  failed: 'needs-attention'
};

export function freshnessRegister(freshness) {
  const kind = freshness && freshness.kind;
  return Object.prototype.hasOwnProperty.call(FRESHNESS_REGISTER, kind)
    ? FRESHNESS_REGISTER[kind]
    : 'needs-attention'; // an unrecognised freshness kind is a discovery too, never silence
}

// Capability's register: no renderer for this lane's payload shape resolves
// needs-attention - design Rule 1's load-bearing case: a live lane whose
// data source dies (or whose payload shape this view does not know how to
// render) resolves hot even when position and freshness both read calm.
export function capabilityRegister(hasRenderer) {
  return hasRenderer ? 'nominal' : 'needs-attention';
}

/**
 * The THREE-AXIS matrix function YB-6 pins: position register x freshness
 * kind x capability present/absent, most-severe-wins.
 *
 * @param {{position: string, positionDefs: Array, freshness: object, hasRenderer: boolean}} args
 */
export function composeRegister({ position, positionDefs, freshness, hasRenderer }) {
  return mostSevereRegister(
    positionRegister(position, positionDefs),
    freshnessRegister(freshness),
    capabilityRegister(hasRenderer)
  );
}

export const NO_RENDERER_LINE = 'no renderer for this payload';

function freshnessLine(freshness) {
  const kind = freshness && freshness.kind;
  switch (kind) {
    case 'not-applicable':
      // Rule 2: a lane that will never be read must never say "not yet read".
      return null;
    case 'never-polled':
      return 'not yet polled';
    case 'fresh':
      // Rule 3: rendered age is ALWAYS server-issued (ageBucketMs), and the
      // wire's "fresh" variant carries no ageBucketMs at all - only "stale"
      // does (schema/yard-snapshot.schema.json $defs.freshness's oneOf).
      // Showing a computed elapsed time here (the mockup's illustrative
      // "fresh, 2s ago") would mean computing age from the client's own
      // clock off `asOf`, which Rule 3 forbids outright. Disclosed steering
      // deviation from the mock's illustrative text; the contract wins.
      return 'fresh';
    case 'stale': {
      const bucketSeconds = Math.round((freshness.ageBucketMs || 0) / 1000);
      return `stale, ${bucketSeconds}s`;
    }
    case 'failed': {
      const reason = freshness.reason || {};
      const label = reason.detail || reason.code || 'source failed';
      return freshness.lastGoodAsOf
        ? `source failed (${label}) - showing last good from ${freshness.lastGoodAsOf}`
        : `source failed (${label}) - no good data has ever been read`;
    }
    default:
      // Freshness is closed BY MECHANISM (design S5.2), but this module
      // never assumes a closed set holds at the wire boundary: an
      // unrecognised kind renders hot, by name - the same discovery
      // treatment applied to positions and outcomes elsewhere.
      return `unrecognised freshness: '${kind}'`;
  }
}

/**
 * Rule 2: position speaks first (primary line), freshness second;
 * not-applicable renders NO freshness line; missing capability says "no
 * renderer for this payload", never nothing.
 *
 * @param {{position: string, positionDefs: Array, freshness: object, hasRenderer: boolean}} args
 */
export function composeLines({ position, positionDefs, freshness, hasRenderer }) {
  const described = describeVocab(position, positionDefs);
  const primary = described.recognised ? described.label : `unrecognised position: '${position}'`;

  let secondary = freshnessLine(freshness);

  if (!hasRenderer) {
    secondary = secondary ? `${secondary} - ${NO_RENDERER_LINE}` : NO_RENDERER_LINE;
  }

  return { primary, secondary };
}
