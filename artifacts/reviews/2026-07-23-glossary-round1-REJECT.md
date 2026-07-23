<!-- starcar-integrity: sha256=248d380f5b93243bb6600f8a124b1f3d6b3f8d047039e978b50373f0533b2f30 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Glossary review round 1: REJECT - unlanded mechanisms in unmarked present tense, a fabricated enumeration, and a mis-defined detector

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Document review (adversarial fidelity, Opus, detached worktree)
Round: 1
Target: `docs/glossary.md v1 at 43652d8`
Base reviewed: `43652d806b36bfb58e46f89becff8ac626c64288`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a5b5e3024cb48da0c`. The conductor did not retype a word of what follows. Verbatim by
> construction rather than by discipline, because the author being reviewed is the
> one landing the review, and a hand-copied verdict is a hand-maintained mirror at a
> process boundary.
>
> Integrity: the `starcar-integrity` line at the top of this file hashes EVERY byte
> below it - this header's claims as well as the verbatim body. Recompute with
> `scripts/Verify-Verdict.ps1 -Path <this file>`. An independently-written copy of the
> same body exists on the Entire checkpoint branch; that copy, not the hash, is the
> defence against whoever controls this script.
>
> Path normalisation: none applied (the body contained no operator-environment paths).

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `43652d806b36bfb58e46f89becff8ac626c64288` |
| Entire checkpoint | `09202151cdc3` |
| Dispatch, the locator within the session | `a5b5e3024cb48da0c` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 43652d806b36bfb58e46f89becff8ac626c64288
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

I have completed the fidelity review. Verification is done; composing the verdict.

## VERDICT: REJECT

One Major finding (GL-1) forces REJECT. The glossary is largely accurate and well-compressed, but its patience/budget entry presents ruled-but-unmerged behavior as if it were running today - the exact class that REJECTed the UI brief (unbuilt presented as existing), here on a reference surface (Law 1).

Worktree verified at HEAD `43652d8` (matches the mandated base), clean, doc-map row landed same-commit, doc-policy 2/2 green.

---

### GL-1 (MAJOR) - Patience / budget entry states three unlanded mechanisms in unmarked simple present

Entry: "Patience / budget" (glossary lines 69-74). The FULL SENTENCE FLOW trace on `budget_source`, hop by hop:

- **Prose (glossary:73-74):** "disclosed on the board via **budget_source** (`record` = ...; `default` = ...)".
- **The field it names — schema:** `schema/yard-snapshot.schema.json:157` has `budget_seconds` only. There is NO `budget_source` in the schema. Dead at hop 2.
- **The code that would emit it — the fold:** `scripts/Detect-Dispatches.ps1:174-192` emits `budget_seconds`, `elapsed_seconds`, `state`. No `budget_source` is ever written. Dead at hop 3.
- **What a stranger observes:** no board renders yet, and `budget_source` exists in NO landed artifact. Repo-wide, the token appears only in `docs/glossary.md` and `docs/specs/2026-07-23-yard-board-spec.md`. A claim whose path cannot be traced past prose is a finding.

The spec itself proves this is in-flight, not landed: Amendment 2 (`docs/specs/2026-07-23-yard-board-spec.md:210-224`) RULES that "(b) both fold bodies thread the default and emit `budget_source: record|default`" and "(c) the PRODUCER stamps `budget` ... red-first in `Producer.Tests.ps1`". Both are Car 3's fix cycle, and Car 3 is REJECTed/unmerged at this HEAD (the immediately-prior commit `53a8bd3` lands the Car 3 REJECT verdict, not the fix).

Three sub-defects, all unmarked present tense:
1. "frozen to seconds at dispatch by the producer's stamp" — `scripts/Produce-Artifact.ps1` does NOT stamp budget (Amendment 2 item c, unmerged). The producer only writes the timestamp for its faults log.
2. "disclosed on the board via budget_source" — traced dead above (Amendment 2 item b, unmerged).
3. "Declared as a class at the ticket (small/medium/large patience)" — the strings "small/medium/large patience" appear NOWHERE in the repo except this glossary line. Not in the spec, design, config, or schema. "tier" in the spec (`:200,223`) is the DETECTION tier (tier-1/tier-2), a different axis. This enumeration is fabricated.

What IS landed and should be what the entry describes: a record may carry its own `budget`; else the fold applies `config/harness-defaults.json`'s `dispatch_budget_seconds` (1800) at fold time (`Detect-Dispatches.ps1:174-176`), emitting `budget_seconds` and, if elapsed exceeds it, `state: overdue`. No provenance disclosure, no producer stamp, no named class tiers exist yet.

**Fix (least-new-prose):** rewrite the entry to the landed behavior, and mark the ruled-but-in-flight parts explicitly (e.g. "[RULED, in flight - issue #22 / spec Amendment 2, not yet merged]") rather than simple present. This is the same remedy the UI-brief REJECT prescribed.

Note (fossil, not actionable): the commit message body repeats the identical unlanded claim ("disclosed via budget_source"), confirming the tense error is in the author's model, not a slip.

---

### GL-2 (MINOR) - "Detector / discovery" entry mis-defines "detector" against the ratified design

Entry: glossary:81-83. It defines "**Detector**" as "the fold's instrument for vocabulary it does not recognise". But in the ratified harness design, "detector" names the tiered liveness/accountability mechanism (`docs/design/2026-07-22-dispatch-harness-design.md:99` "tier-1 detector", `:130` "Detection is tiered", `:194` "Tier 1, universal"), which IS the `Detect-Dispatches.ps1` fold script. A reader who meets "detector" in the design and looks it up here gets the discovery/unknown-vocabulary concept (a real thing, spec S3.2/A.2) under the wrong headword - a HAVAGLANCE miss. Recommend retitling the entry "**Discovery**" (the concept it actually defines) and, if "detector" needs an entry, pointing it at the fold script.

### GL-3 (MINOR, omission) - "producer" undefined but used

The glossary uses "the producer's stamp" (line 71) and leans on the producer in the envelope entry, but has no "Producer" entry. The producer (`Produce-Artifact.ps1`, the hook that writes `returned` records from transcripts) is a term a reader meets across briefs and the store/fold section. A reader hitting "producer" mid-document has nowhere to land (HAVAGLANCE). Candidate to add.

### GL-4 (NOTE, omission) - "adapter" undefined

"Adapter" is load-bearing in the design (the store as "the SOLE adapter", "one adapter behind a seam", freight lane "no adapter yet") and the glossary's own freight framing, but is not defined. Lower priority than GL-3; the glossary intro invites add-on-notice, so this is a Note.

---

### Confirmed ACCURATE (stated for the record, counted from disk)

- Precedence "returned beats presumed-lost beats dispatched" = `Detect-Dispatches.ps1:19,115`. Match.
- Register enum `nominal / in-progress / needs-attention` + severity order = `schema/yard-snapshot.schema.json` `$defs.register` exactly (3 values). Match.
- Position values `live / bagged / dark / under-construction` = design `:165` (4 values). Match.
- Record kinds `dispatched / returned / presumed-lost / intent / ruling` = `schema/vocab/kinds.json` exactly (5 values). Match.
- Liveness `dispatched / overdue / returned / presumed-lost` = fold states. Match.
- Envelope fields `outcome / findings / abstract` = `docs/templates/car-brief.md:47`. Match.
- Lanes `trains / gates / dispatches / freight / fuel` = `docs/design/2026-07-23-ui-mockup-brief.md:50-65` (5 lanes). Match.
- House phrases GEOLOGICAL DEVELOPMENT / NIRTS / HAVAGLANCE / FULL SENTENCE FLOW = faithful compressions of `CLAUDE.md:18,28,35,531`. No distortion.
- "Held ... via an intent record" = design `:179`. Match.
- Board-vocabulary entries (register, position, lane, Solari) describe a not-yet-rendering board, but each has a LANDED contract backing (register in the schema, positions in the approved design). Defining ratified design vocabulary is legitimate glossary work; NOT the GL-1 class, whose defect is that `budget_source` has no landed artifact anywhere. I did NOT Major these, but the glossary has no convention distinguishing "designed/contracted, not yet rendering" from "running today," which is the gap GL-1 falls through.
- Doc-policy gate: `Invoke-Pester ./scripts/tests/DocPolicy.Tests.ps1` = **2/2 passed** at `43652d8`. Doc-map row for `docs/glossary.md` present in the same commit (`git show 43652d8 -- docs/doc-map.md`).

### Constitution check

- **Law 1 (no confident falsehood on a surface):** VIOLATED by GL-1 - `budget_source`, producer stamping, and named patience classes stated as current on a reference surface. This is the REJECT.
- **NORTH STAR / living docs (true always, complete only when the thing exists):** VIOLATED by GL-1 - the entry describes behavior the software does not have, the "quickstart for a server that cannot start" pattern.
- **Match-the-instrument / sentence check:** HONORED by the review - traced `budget_source` every hop with file:line; the trace is the finding's proof.
- **Branch topology / TDD / cost:** not implicated by a read-only glossary review.
- **Same-commit doc invalidation:** HONORED - doc-map row landed in `43652d8` alongside the glossary.

```starcar-artifact
outcome: REJECT
findings: GL-1 (MAJOR) - the Patience/budget entry (glossary lines 69-74) states three unlanded mechanisms in unmarked simple present. budget_source is traced dead hop-by-hop (glossary prose to schema:157 has budget_seconds not budget_source, to Detect-Dispatches.ps1:174-192 emits no budget_source, repo-wide the token exists only in glossary + spec); "frozen ... by the producer's stamp" - Produce-Artifact.ps1 does not stamp budget; "small/medium/large patience" class appears nowhere but this line. Spec Amendment 2 (2026-07-23-yard-board-spec.md:210-224) proves both are Car 3's unmerged fix (items b and c). Exact UI-brief REJECT class plus Law 1 on a reference surface. Fix: rewrite to landed behavior (record budget else config default at fold, budget_seconds/overdue only) and mark ruled-but-in-flight parts explicitly. GL-2 (MINOR) - "Detector/discovery" entry mis-titles the discovery concept as "detector"; in the ratified design "detector" is the tiered liveness fold script, not the unknown-vocab instrument. GL-3 (MINOR) - "producer" used (line 71) but undefined. GL-4 (NOTE) - "adapter" undefined. Confirmed accurate: precedence, register enum+order, 4 positions, 5 record kinds, liveness states, envelope fields, 5 lanes, 4 house phrases, Held-via-intent - all match sources exactly. Doc-policy 2/2 passed at 43652d8; doc-map row same-commit.
abstract: Adversarial fidelity review of docs/glossary.md at HEAD 43652d8 (verified). REJECT on one Major: the patience/budget entry presents budget_source disclosure, producer budget-stamping, and named patience classes as existing when all three are ruled-but-unmerged (spec Amendment 2 / issue #22, Car 3 fix not merged) or fabricated - Law 1 on a reference surface. All enumerated mechanics lists (precedence, register, positions, kinds, liveness, envelope, lanes) and all four house-phrase compressions verified exact against schema/scripts/design/CLAUDE.md. Two Minors (detector mis-definition, producer omission) and one Note (adapter omission). Doc-policy gate green 2/2; doc-map row landed same-commit.
```