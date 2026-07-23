// wire-constants.js - constants shared with the wire schema, mirroring the
// pattern board/server/snapshot.go already uses server-side: a local
// constant, cross-checked against schema/yard-snapshot.schema.json's own
// $defs by a dedicated test (board/web/test/sse-event-name.test.js; the
// Go side is board/server/sse_const_test.go), rather than reading the
// schema file at runtime for a value this simple. Both sides drift-detect
// against the SAME schema file, so a one-character change to the schema's
// $defs.sseEventName.const breaks BOTH tests, never just one silently.
export const SSE_EVENT_NAME = 'yard';
