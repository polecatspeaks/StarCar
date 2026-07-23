// ingest.js - the pure state reducer for "a new frame arrived" (task 5.2's
// wire-validation-discard behavior; task 5.3 layers seq ordering onto the
// SAME reducer, disclosed at that commit). No DOM, no fetch, no SSE
// wiring - app.js (task 5.3) is the only impure caller.
//
// Design rev 5 S5.4 item 2 / spec YB-4: every parsed payload is validated
// against THE wire schema before it is ever applied. A payload that fails
// validation is DISCARDED - the previous render stays on screen, VISIBLY
// MARKED (markedStale), and a client board condition renders (never
// silence; Law 1).

export const VALIDATION_FAILED_CODE = 'client-payload-failed-validation';

export function initialIngestState() {
  return {
    snapshot: null,
    lastAppliedSeq: -1,
    markedStale: false,
    clientConditions: []
  };
}

/**
 * @param {ReturnType<typeof initialIngestState>} state
 * @param {unknown} payload - a JSON.parse'd candidate snapshot.
 * @param {{validate: (payload: unknown) => {valid: boolean, errors?: unknown}}} validator
 */
export function applyIncomingPayload(state, payload, validator) {
  const result = validator.validate(payload);

  if (!result.valid) {
    // DISCARD - the previous snapshot is untouched. The stale mark and the
    // client board condition are how the honesty chrome (mockup: "the
    // board visibly flips ... keeping the stale picture on screen, clearly
    // marked") surfaces this, rather than the board silently freezing with
    // no explanation.
    return {
      ...state,
      markedStale: true,
      clientConditions: [
        {
          code: VALIDATION_FAILED_CODE,
          detail: 'a received payload failed wire-schema validation and was discarded; showing the last validated render',
          register: 'needs-attention'
        }
      ]
    };
  }

  // Seq ordering (task 5.3; schema/yard-snapshot.schema.json's own `seq`
  // description: "the client applies a snapshot only if seq exceeds the
  // last applied"). A payload whose seq does not EXCEED the last applied
  // one is a stale/duplicate frame under normal SSE delivery and a
  // deliberate no-op here - cheap (one integer comparison) and correct
  // under the churn issue #27 describes (elapsed_seconds is unquantised,
  // so seq can bump on nearly every poll while a dispatch is actively
  // running; this comparison must never grow heavier than an int compare
  // regardless of how often it runs).
  if (typeof payload.seq === 'number' && payload.seq <= state.lastAppliedSeq) {
    return state;
  }

  return {
    snapshot: payload,
    lastAppliedSeq: typeof payload.seq === 'number' ? payload.seq : state.lastAppliedSeq,
    markedStale: false,
    clientConditions: []
  };
}
