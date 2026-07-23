// Plan task 1.5 / spec YB-11(b): the no-build-step browser JS validator probe.
//
// This is a PROBE, not product code (car 5 owns board/web/'s real wiring,
// task 5.2). It exists to OBSERVE, in Node running the vendored file as bare
// ESM (no bundler, no transpile step - the same load path a plain
// `<script type="module">` would take in a browser), that:
//   (a) the vendored @cfworker/json-schema validator loads and compiles
//       schema/yard-snapshot.schema.json under the 2020-12 draft, and
//   (b) one hand-built, well-formed sample snapshot object validates.
//
// Root-resolution: import.meta.url gives THIS FILE's own module URL,
// independent of the process's cwd - the same robustness property board/'s
// Go tests get from runtime.Caller(0) (see board/testroot_test.go), applied
// to Node ESM's equivalent primitive. board/web/ -> repo root is one level up.
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { readFileSync } from 'node:fs';
import { Validator } from './vendor/cfworker-json-schema/index.js';

const thisDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = dirname(dirname(thisDir)); // board/web -> board -> repo root
const schemaPath = join(repoRoot, 'schema', 'yard-snapshot.schema.json');

const schemaText = readFileSync(schemaPath, 'utf8');
const schema = JSON.parse(schemaText);

// draft MUST be explicit - the library's own default is '2019-09'
// (board/web/vendor/cfworker-json-schema/validator.js), not 2020-12.
const validator = new Validator(schema, '2020-12');

const sampleSnapshot = {
  seq: 1,
  asOf: '2026-07-23T12:00:00Z',
  config: {
    pollMs: 2000,
    heartbeatMs: 10000,
    stalenessMs: 30000,
    storePathDisplay: '<repo>/artifacts',
    laneCount: 5,
    demoMode: true
  },
  vocabularies: {
    positions: [{ id: 'live', label: 'Live', register: 'nominal' }],
    outcomes: [{ id: 'done', label: 'Done', register: 'nominal' }],
    roles: [{ id: 'car', label: 'Car', register: 'nominal' }],
    liveness: [{ id: 'returned', label: 'Returned', register: 'nominal' }]
  },
  board: [],
  lanes: [
    {
      id: 'trains',
      title: 'Trains',
      position: 'live',
      freshness: { kind: 'not-applicable' }
    }
  ]
};

const result = validator.validate(sampleSnapshot);

console.log(`PROBE schema-compiles: OK (${schemaPath})`);
console.log(`PROBE draft: 2020-12`);
console.log(`PROBE sample-validates: ${result.valid ? 'PASS' : 'FAIL'}`);
if (!result.valid) {
  console.log(`PROBE errors: ${JSON.stringify(result.errors, null, 2)}`);
  process.exit(1);
}

// Non-vacuity check (regression-vault convention): a validator that returns
// { valid: true } for EVERYTHING would pass the check above vacuously. Prove
// it actually enforces something by validating a deliberately BROKEN sample
// (missing the required "lanes" key) and asserting it is REJECTED.
const brokenSnapshot = { ...sampleSnapshot };
delete brokenSnapshot.lanes;
const brokenResult = validator.validate(brokenSnapshot);
console.log(`PROBE non-vacuity (missing required "lanes" must be REJECTED): ${brokenResult.valid ? 'FAIL (validator did not enforce required fields)' : 'PASS (rejected as expected)'}`);
if (brokenResult.valid) {
  process.exit(1);
}

console.log('PROBE RESULT: PASS');
