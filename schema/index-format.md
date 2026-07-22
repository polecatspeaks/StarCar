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
`docs/reviews/2026-07-22-plan-review-car1-round3.md`.)

## Index format

The committed index is one row per artifact. Columns, in order:

```
| subject | kind | at | outcome | file |
```

Rows are sorted by `at`, then `subject`, then `file` - a total order, so there are never
ties to break arbitrarily (determinism requires no ties). `outcome` is blank for kinds
where it does not apply (only `returned` carries one). `file` is the artifact's path
relative to the store root.

### Worked example

```
| subject | kind      | at                   | outcome | file                          |
|---|---|---|---|---|
| disp-1  | dispatched | 2026-07-22T10:00:00Z |         | disp-1/dispatched.json        |
| disp-1  | returned   | 2026-07-22T10:05:00Z | APPROVE | disp-1/returned.json          |
| disp-2  | dispatched | 2026-07-22T11:00:00Z |         | disp-2/dispatched.json        |
```

## Path-normalisation substitution rule

Mechanical classes, ported from `Land-Verdict.ps1`'s `ConvertTo-PortablePaths` precedent
(`scripts/Land-Verdict.ps1:118-166`, structural - opened at base):

- the repository root -> `<repo>`
- the operator's home directory -> `~`

Longest-first, so a repo root nested inside a home directory wins over the home rule.
Applied BEFORE the artifact's `integrity` hash is computed (normalisation is part of
writing the record, not editing one already written). Each substitution actually applied
to a given artifact is declared in that artifact's own `normalisation` field - an empty
array means nothing was substituted, never that normalisation was skipped.
