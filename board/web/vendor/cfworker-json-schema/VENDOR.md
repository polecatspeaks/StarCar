# Vendored: @cfworker/json-schema (ESM runtime only)

Plan task 1.5 (`docs/plans/2026-07-23-yard-board-plan.md`), spec YB-11(b)'s
no-build-step browser validator probe.

- **Upstream:** https://github.com/cfworker/cfworker (package
  `packages/json-schema`), published to npm as `@cfworker/json-schema`.
- **Version pinned:** `4.1.1`.
- **Tarball provenance:** `https://registry.npmjs.org/@cfworker/json-schema/-/json-schema-4.1.1.tgz`,
  shasum `4a2a3947ee9fa7b7c24be981422831b8674c3be6`, integrity
  `sha512-gAmrUZSGtKc3AiBL71iNWxDsyUC5uMaKKGdvzYsBoTW/xi42JQHl7eKV2OYzCUqvc+D2RCcf7EXY2iCyFIk6og==`
  (observed via `npm view @cfworker/json-schema@4.1.1 dist.shasum dist.integrity`,
  2026-07-23).
- **License:** MIT. `package.json`'s `license` field is `"MIT"`; the tarball
  ships no separate `LICENSE` file, so the standard MIT license text is
  reproduced below with the package's stated author as copyright holder.
- **Files vendored:** the runtime `dist/esm/*.js` files ONLY (no `.d.ts` type
  declarations - this repo has no TypeScript toolchain to consume them, and
  they carry no runtime behavior):
  `index.js`, `validator.js`, `validate.js`, `dereference.js`,
  `deep-compare-strict.js`, `format.js`, `pointer.js`, `ucs2-length.js`,
  `types.js`. Byte-identical to the tarball's `dist/esm/` copies (verified by
  this same shasum's tarball extraction; not hand-transcribed).
- **Why this candidate (probe result, plan task 1.5):** every internal import
  is a plain RELATIVE specifier with an explicit `.js` extension
  (`import { encodePointer } from './pointer.js';` etc. - verified by
  `grep -n "^import" dist/esm/*.js` on the extracted tarball) and there are
  ZERO bare-specifier imports and ZERO Node built-in imports. That is what
  makes this a genuine no-build-step candidate: a plain browser
  `<script type="module" src="vendor/cfworker-json-schema/index.js">` (or an
  ESM `import` from another module in the same directory tree) resolves every
  one of these paths with no bundler and no import map. The upstream README
  states explicit rationale for the no-`eval`/no-`new Function` design:
  Cloudflare Workers isolates forbid dynamic code generation, which is
  the same constraint a Content-Security-Policy browser context imposes -
  so this validator was built FOR the no-build-step, no-codegen case this
  probe needs, not merely compatible with it by accident.
- **Draft coverage:** the upstream README states support for drafts 4, 7,
  2019-09, and 2020-12, validated against the json-schema-test-suite. The
  `Validator` constructor's default draft parameter is `'2019-09'`
  (`validator.js`) - callers MUST pass `'2020-12'` explicitly. The probe
  script (`board/web/probe-yard-snapshot.mjs`) does this.
- **Retirement trigger (spec YB-11(b), gating matrix):** this probe's job is
  done once car 5 lands the true browser observation (`board/web/`'s live
  validator wiring, task 5.2). Nothing here is product code; car 5 may reuse
  this exact vendored copy or choose differently - this vendoring only proves
  the candidate LOADS bare-ESM and validates the wire schema.

## MIT License (reproduced; package.json `license: "MIT"`, author `Jeremy Danyow <jdanyow@gmail.com>`)

Copyright (c) Jeremy Danyow

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
