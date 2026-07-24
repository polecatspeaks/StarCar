// PB-7 (spec YB-4, plan task 5.3): the CLIENT-side half of "the SSE event
// name is a constant in the wire schema artifact, tested on both sides"
// (board/server's sse_const_test.go owns the server half). This test reads
// schema/yard-snapshot.schema.json directly and asserts the subscriber
// module's exported constant is EXACTLY $defs.sseEventName.const - never a
// hardcoded string with no tether back to the schema.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { SSE_EVENT_NAME } from '../js/wire-constants.js';

const thisDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = dirname(dirname(dirname(thisDir))); // board/web/test -> board/web -> board -> repo root
const schema = JSON.parse(readFileSync(join(repoRoot, 'schema', 'yard-snapshot.schema.json'), 'utf8'));

test('SSE_EVENT_NAME matches schema/yard-snapshot.schema.json\'s $defs.sseEventName.const EXACTLY', () => {
  assert.equal(schema.$defs.sseEventName.const, 'yard', 'fixture sanity: the schema constant itself must be "yard" for this test to mean anything');
  assert.equal(SSE_EVENT_NAME, schema.$defs.sseEventName.const);
});
