// vocab.js - pure lookups into the wire's `vocabularies` block (positions,
// outcomes, roles, liveness - schema/yard-snapshot.schema.json's top-level
// `vocabularies` property). Recognition VALUES stay owned server-side by
// schema/vocab/*.json (Law 7); this module never hardcodes a taxonomy of
// its own - it only reads the defs the CURRENT snapshot already carried
// (design rev 5 S5.4 item 2 / Law 6: vocabularies travel on every snapshot
// so the view never fetches or hardcodes a separate copy that could drift).
//
// An id with no matching def is UNRECOGNISED - the discovery rule (design
// rev 5 S5.2, mockup brief "the discovery state") renders it hot, BY NAME,
// verbatim, never silently as calm.

/**
 * @param {Array<{id: string, label: string, register: string}>} defs
 * @param {string} id
 */
export function findVocabDef(defs, id) {
  if (!Array.isArray(defs)) return undefined;
  return defs.find((d) => d && d.id === id);
}

/**
 * Describe one vocabulary id against its defs array. Recognised ids get
 * their def's label + register; unrecognised ids render their raw id as
 * the label (verbatim) with register `needs-attention` (Law 1: unknown
 * must never look like "fine").
 *
 * @param {string} id
 * @param {Array<{id: string, label: string, register: string}>} defs
 */
export function describeVocab(id, defs) {
  const def = findVocabDef(defs, id);
  if (def) {
    return { id, label: def.label, register: def.register, recognised: true };
  }
  return { id, label: id, register: 'needs-attention', recognised: false };
}
