# Repo-policy check patterns - mechanical guards for documentation truth, sanitized

Status: Current

Provenance: the ancestor runs these as a CI job ("repo policy") beside build-and-test.
For a repo whose north star is documentation-ranks-equal-to-code, these are the
graduation path from review-attention to mechanism (the Healing Loop prefers a check
that fires at CI over a reviewer who must remember). Build them when setup.md's CI
trigger fires; shapes below.

## 1. The Status-line gate (docs carry their own liveness)

Every file under `docs/` carries a first-lines `Status: <word>` from a closed set:

- `Current` - true now; a stale claim in a Current doc is a defect.
- `Done` - a completed record (a landed plan, a closed audit); historical by nature.
- `Superseded` - kept for provenance; points at its successor.
- `Open` - a draft/working doc; claims not yet gated.

The checker: walk `docs/**`, regex `^Status: (Current|Done|Superseded|Open)` in the
first N lines, fail CI listing every violator. Scar: the regex is deliberately anchored
and plain - a decorated `**Status:**` header once passed human eyes and failed the
gate, and the fix was fixing the DOC to the machine-checkable form, not loosening the
regex. The lesson ported: keep the marker so simple a machine can hold it, and never
soften the checker to accommodate drift.

What this buys the doc north star: "documents are living" needs a mechanical floor -
the Status line is each document declaring which truth-standard it accepts being held
to, and CI holds every one of them to it on every push.

## 2. The config-truth reconciliation (documented vs read)

Shape: enumerate every config/env variable the CODE reads (grep for the accessor
pattern - `process.env.X`, `config.get('x')`); enumerate every variable the DOCS
document (the setup/deploy guides' tables); fail CI on the symmetric difference, with
a small explicit allowlist for intentional gaps (each allowlist entry carries a
comment saying why).

Scar class: undocumented variables are invisible knobs (the stranger cannot deploy
what they cannot see - Law 7); documented-but-unread variables are lying documentation
(the reader sets them and nothing happens - Law 1). Both directions matter; checking
only one lets the other rot.

## 3. The citation checker (aspirational tier - build when citations accumulate)

Docs here cite `file.ts:123` heavily. A checker that parses citations from
`docs/**` and verifies the file exists (cheap tier) and the cited line's content still
matches a recorded fragment (expensive tier) converts citation-truth review work into
mechanism. The ancestor runs this check as reviewer attention (every adversary opens
every citation); the mechanical form is this repo's chance to graduate it. Honest
caveat from the severity philosophy: line numbers drift on every edit above them - the
cheap tier (file exists + symbol named exists in file) avoids crying wolf; the
expensive tier needs content-anchoring (cite `file.ts#symbolName` not raw line
numbers) before it can be strict without being noisy. An instrument that cries wolf is
worse than no instrument.

## Running them

One CI job, fail-fast, each check a small pure module with its own unit tests (the
checkers are code; they get the code standard). Local run before push:
`npm run policy`. The job is a REQUIRED check on PRs to main - a policy red is a real
red, not advisory (advisory checks decay into wallpaper; give the guard binding
authority - the Healing Loop, step 3).
