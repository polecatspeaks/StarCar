// condition-open-state.js (#69: owner fast-follow - "the 2 flags drop down
// not let me click through and it closes back up every page refresh").
// PURE state-shape helpers only - reading/writing the actual browser
// sessionStorage is app.js's job (the ONE impure module, per its own header
// comment), same separation dom-writer.js/render.js already keep.
//
// THE STATE SHAPE: { strip: boolean, groups: { [code]: boolean } } - the
// strip's own open/closed flag, tracked SEPARATELY from each condition
// GROUP's own flag (#69's own instruction: "Per-group state, not one global
// flag" - a single boolean that opened/closed every group at once would
// still violate that even though this shape's `strip` field IS one flag,
// because `strip` only ever gates the OUTER chrome summary, never a
// group's own expand state).
//
// NEW-CONDITION-DEFAULTS-COLLAPSED (#30's own rule, carried forward): a
// group code with no entry in `groups` reads as CLOSED (isGroupOpen returns
// false) - never a guessed true. A brand-new condition CLASS this session
// has never toggled therefore renders collapsed by construction, with no
// special-casing needed here: absence from the map IS the collapsed
// default, the same "absent means not yet observed" posture this repo uses
// throughout (Law 1).

const STORAGE_KEY = 'starcar-board-conditions-open';

/** The default, pre-any-interaction state - everything collapsed. */
export function defaultOpenState() {
  return { strip: false, groups: {} };
}

/**
 * Reads persisted open-state from a storage-shaped object (getItem/setItem
 * - sessionStorage in production, a plain Map-backed fake in tests). Never
 * throws: a missing key, invalid JSON, or a malformed shape all degrade to
 * the collapsed default (Law 1 - a corrupt read must never resurrect a
 * guessed "everything open" state).
 *
 * @param {{getItem(key: string): string | null}} storage
 */
export function loadOpenState(storage) {
  if (!storage) return defaultOpenState();
  let raw;
  try {
    raw = storage.getItem(STORAGE_KEY);
  } catch {
    return defaultOpenState();
  }
  if (!raw) return defaultOpenState();
  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch {
    return defaultOpenState();
  }
  if (!parsed || typeof parsed !== 'object' || typeof parsed.groups !== 'object' || parsed.groups === null) {
    return defaultOpenState();
  }
  return { strip: Boolean(parsed.strip), groups: { ...parsed.groups } };
}

/**
 * @param {{setItem(key: string, value: string): void}} storage
 * @param {{strip: boolean, groups: Record<string, boolean>}} state
 */
export function saveOpenState(storage, state) {
  if (!storage) return;
  try {
    storage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch {
    // Storage unavailable/full/disabled (private browsing, quota) - the
    // strip still renders correctly for THIS render from the in-memory
    // state; only cross-refresh persistence is lost. Never let a storage
    // failure break rendering (Law 1: degrade, never crash).
  }
}

/** @param {{groups: Record<string, boolean>}} state */
export function isGroupOpen(state, code) {
  return Boolean(state && state.groups && state.groups[code]);
}

/** Pure update - returns a NEW state object, never mutates the input. */
export function withGroupOpen(state, code, isOpen) {
  const base = state || defaultOpenState();
  return { strip: Boolean(base.strip), groups: { ...base.groups, [code]: Boolean(isOpen) } };
}

/** Pure update - returns a NEW state object, never mutates the input. */
export function withStripOpen(state, isOpen) {
  const base = state || defaultOpenState();
  return { strip: Boolean(isOpen), groups: { ...base.groups } };
}
