Status: Current

# StarCar artifact: ordering, index format, and path-normalisation rule

Companion to `schema/starcar-artifact.schema.json`. Spec S3's preamble assigns the schema
artifact six contracts - field names, types, ordering, identity, the index format, and the
path-normalisation substitution rule. The schema JSON file owns fields, types, and the
conditional-requirement shape; this file owns the other three, so neither file duplicates
the other's half (Law 6).

## Canonical field order

Canonical serialisation order for a landed artifact is the order below (this is what a
producer writes and a byte-identical comparison assumes; A.4's determinism test consumes
this order):

```
schema, kind, subject, session_id, at, outcome, findings, abstract, envelope, budget,
basis, cost, context_peak_tokens, producer, normalisation, integrity
```

A field absent from a given record (optional, or not applicable to that `kind`) is simply
omitted - it does not break the ordering of the fields present.

## `additionalProperties` posture

**Open (`additionalProperties` is not set to `false`; the schema's default of `true`
applies).** Chosen over closing it because a stranger's adapter may need to attach extra
producer-specific metadata (spec S3.4's Law 7 producer-optional posture already permits
`cost`/`context_peak_tokens`/`producer` as optional, and the same reasoning generalises):
an artifact carrying one more field than this shop currently reads should never fail
conformance for that reason alone. Closing it would make every future field addition a
breaking change for every existing producer, which is the opposite of what a vocabularies-
as-data posture is trying to buy (spec S3.2). (Forward note from
`artifacts/reviews/2026-07-22-plan-review-car1-round3.md`, moved from `docs/reviews/`
by harness #7's migration commit - `git mv`, history preserved.)

## Index format

The committed index is one row per artifact. Columns, in order:

```
| subject | kind | at | outcome | file |
```

Rows are sorted by `at` **normalized to a UTC instant** (offsets honored), then
`subject`, then `file` - a total order, so there are never ties to break arbitrarily
(determinism requires no ties). The store carries mixed offsets (migrated verdicts' `at`
came from git authorship in local time, alongside Z-normalized producer output), so
sorting the lexical `at` STRING is chronological only when every record shares the same
offset; the sort key is the parsed instant (`Get-AtInstant`, `scripts/Artifact.psm1`),
not the string (F1, `docs/plans/2026-07-22-pr18-correctness-fixes-plan.md`). `outcome` is
blank for kinds where it does not apply (only `returned` carries one). `file` is the
artifact's path relative to the store root.

### Worked example

```
| subject | kind      | at                   | outcome | file                          |
|---|---|---|---|---|
| disp-1  | dispatched | 2026-07-22T10:00:00Z |         | disp-1/dispatched.json        |
| disp-1  | returned   | 2026-07-22T10:05:00Z | APPROVE | disp-1/returned.json          |
| disp-2  | dispatched | 2026-07-22T11:00:00Z |         | disp-2/dispatched.json        |
```

## Freshness-contract header (#20, owner-ratified 2026-07-23)

The generator emits a mandatory header block before the table - the committed index is
a product surface a stranger reads (the browsable dispatch ledger), and its CI
staleness gate is scoped to PR-to-main and push-to-main (`.github/workflows/ci.yml`'s
"Verify the artifact index is not stale" step), not every dev push - the producer hook
writes a record on every dispatch, so gating every dev push turned ordinary conductor
activity into mechanical CI red. Without a declared contract, an index that legitimately
lags the store on dev would read as a lying surface (Law 1); this header is what makes
the lag a documented refresh cadence instead.

The header text is **static** - no timestamp, no generated-at stamp - because a
run-varying header would break the byte-identical determinism contract
(`ArtifactIndex.Tests.ps1`) a CI regenerate-and-diff gate depends on. Verbatim, followed
by one blank line, then the table header row:

```
# Artifact index

Derived from the store (artifacts/**/*.json) by scripts/New-ArtifactIndex.ps1 - regenerate,
never hand-edit; the JSON records are the source of truth. Freshness contract (#20): this
file is gated fresh at PR-to-main and push-to-main; on dev it may lag the store by a
dispatch batch between regenerations.

| subject | kind | at | outcome | file |
```

## Path-normalisation substitution rule

Mechanical classes, ported from `Land-Verdict.ps1`'s `ConvertTo-PortablePaths` precedent
(the `ConvertTo-PortablePaths` function in `scripts/Land-Verdict.ps1`, structural - opened
at base):

- the repository root -> `<repo>`
- the operator's home directory -> `~`

Longest-first, so a repo root nested inside a home directory wins over the home rule.
Applied BEFORE the artifact's `integrity` hash is computed (normalisation is part of
writing the record, not editing one already written). Each substitution actually applied
to a given artifact is declared in that artifact's own `normalisation` field - an empty
array means nothing was substituted, never that normalisation was skipped.

## Integrity canonicalisation: `at` is a VERBATIM string

A record's `integrity` is `sha256` over the canonical body (every field in order, minus
`integrity`, compact JSON). The `at` field is a **verbatim string** in that body - it is
NEVER coerced to a date/time object. A verifier that recomputes the hash MUST read the
record with `ConvertFrom-Json -DateKind String` (or its language's equivalent), because a
plain parse coerces an offset-bearing `at` (e.g. the migrated verdicts' `-04:00` stamps)
into a local datetime that re-serialises with the *recomputing machine's* offset - so the
hash would match only on the timezone the record was written in. This is Law 7: a stranger
on any timezone must be able to verify our records. (Scar: M-A4-1's coercion class recurred
a third time in the StoreIntegrity test's recompute; only CI running in a different timezone
than the author caught it, 2026-07-22.)
