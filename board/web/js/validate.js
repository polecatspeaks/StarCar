// validate.js - wraps the vendored @cfworker/json-schema validator (Car 1's
// probe, board/web/probe-yard-snapshot.mjs, PROVED this loads bare-ESM and
// compiles schema/yard-snapshot.schema.json under draft 2020-12). Design
// rev 5 S5.4 item 2: a single vetted, no-build-step JS draft-2020-12
// validator consuming THE schema file - never a hand-rolled structural
// mirror of the schema's own knowledge (that would be a Law 6 second copy).
import { Validator } from '../vendor/cfworker-json-schema/index.js';

// The vendored library's OWN default draft is '2019-09'
// (board/web/vendor/cfworker-json-schema/validator.js) - callers MUST pass
// '2020-12' explicitly, same as the probe already does.
export const WIRE_SCHEMA_DRAFT = '2020-12';

/**
 * @param {object} schema - a parsed JSON Schema object (schema/yard-snapshot.schema.json
 *   in production; a hermetic local schema object in tests).
 */
export function createValidator(schema) {
  return new Validator(schema, WIRE_SCHEMA_DRAFT);
}
