// register-taxonomy.test.js - pins the register taxonomy's unpinned edges (#37).
//
// EDGE 1 (JS): compose.js REGISTER_ORDER vs schema/yard-snapshot.schema.json
// $defs.register.enum.
//
// This test reads the real schema file from disk (same shape as the
// sse-event-name.test.js exemplar: board/web/test -> board/web -> board ->
// repo root, then schema/). It pins SET EQUALITY - every value in REGISTER_ORDER
// must appear in the schema enum and vice versa.
//
// ORDERING IS COMPOSE.JS-OWNED: the schema enum cannot express severity order
// (JSON Schema enums are unordered); mostSevereRegister (compose.js:23-25)
// depends on REGISTER_ORDER's array index position. The schema enum is the
// CONTENT authority; compose.js is the ORDER authority. This test enforces
// content agreement and explicitly does NOT order-check the schema. #37.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { REGISTER_ORDER } from '../js/compose.js';

const thisDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = dirname(dirname(dirname(thisDir))); // board/web/test -> board/web -> board -> repo root
const schema = JSON.parse(readFileSync(join(repoRoot, 'schema', 'yard-snapshot.schema.json'), 'utf8'));

test('REGISTER_ORDER and schema $defs.register.enum are SET-EQUAL (content authority: schema; order authority: compose.js) #37', () => {
  const schemaEnum = schema.$defs.register.enum;
  assert.ok(
    Array.isArray(schemaEnum),
    'schema.$defs.register.enum must be an array (fixture sanity)'
  );

  // Non-vacuity: both sides must be non-empty.
  assert.ok(REGISTER_ORDER.length > 0, 'REGISTER_ORDER must be non-empty');
  assert.ok(schemaEnum.length > 0, 'schema.$defs.register.enum must be non-empty');

  // Every REGISTER_ORDER value must be in the schema enum.
  for (const r of REGISTER_ORDER) {
    assert.ok(
      schemaEnum.includes(r),
      `REGISTER_ORDER value '${r}' is not in schema.$defs.register.enum - schema and compose.js have drifted (#37)`
    );
  }

  // Every schema enum value must be in REGISTER_ORDER.
  for (const r of schemaEnum) {
    assert.ok(
      REGISTER_ORDER.includes(r),
      `schema.$defs.register.enum value '${r}' is not in REGISTER_ORDER - schema and compose.js have drifted (#37)`
    );
  }

  // Set sizes must match (catches duplicates on either side).
  assert.equal(
    REGISTER_ORDER.length,
    schemaEnum.length,
    `REGISTER_ORDER has ${REGISTER_ORDER.length} values but schema enum has ${schemaEnum.length} - sets differ (#37)`
  );
});
