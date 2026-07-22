<!-- starcar-integrity: sha256=449ca555955b29155f492c7038e4d433655c31145d10acb6eb51acc9b8b68e9c covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Adversarial spec review - dispatch harness, round 2 (DELTA re-review, same reviewer)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: spec review (ladder rung 2)
Round: 2 (delta)
Target: `docs/specs/2026-07-22-dispatch-harness-spec.md (rev 2)`
Base reviewed: `3fba4379e70b3c7bbb6e0a82d9c3dee9cfd569b8`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT - 1 Major, 4 Minor; 12/15 prior findings CLOSED, 6/6 rulings adopted as ruled**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a543c37ea68e622d8`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `3fba4379e70b3c7bbb6e0a82d9c3dee9cfd569b8` |
| Entire checkpoint | `41a1bf13e5af` |
| Dispatch, the locator within the session | `a543c37ea68e622d8` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 3fba4379e70b3c7bbb6e0a82d9c3dee9cfd569b8
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

VERDICT: **REJECT** — one Major, and it is in the fidelity ledger itself: §10's last row claims normalisation-before-hashing lands in §8, which is silent on it, citing "design §9" which is the Cost section — a false row masking a real drop of design §5.7's behavioural publication obligations.

Base verified: `3fba4379e70b3c7bbb6e0a82d9c3dee9cfd569b8`, clean tree before and after. **No fault injection performed.** Suites run by me at this SHA: **Pester 21/21 passed, 0 failed, 0 skipped**; **`Verify-Verdict.ps1`: 8/8 hashes match, exit 0** — both matching the coordinate convention CLAUDE.md now mandates.

Fourteen of fifteen findings and all six rulings were verified by mechanism, not by §12. The one Major is new material created by a fix.

---

## CLOSURE TABLE

| ID | Status | Evidence I checked myself |
|---|---|---|
| **M1** citation: "the harness" | **CLOSED (withdrawn, correctly)** | Re-ran independently: `grep -c -i harness scripts/Land-Verdict.ps1 scripts/Verify-Verdict.ps1` → **0 and 0**. `Land-Verdict.ps1:1` = *"extract a dispatched agent's verdict VERBATIM from the session"* — spec's quote exact. `Verify-Verdict.ps1:6` = *"This is the checker"* — exact, and rev 2 **narrowed** the citation from my own `:1-8` to `:6`, which is more precise than the range I filed. `git diff` on both scripts shows the only change is a `Status:`-line header edit; no text was removed to make the withdrawal true. The framing is redirected to `docs/setup.md:24`, which I confirmed still carries it, and §4 row 5 + §9 row 5 both own it. Withdrawal survives scepticism. |
| **M2** retirement misses mirrors / no doc carrier | **CLOSED** | New §9, eight rows with an Owner column. All four mirrors I enumerated are present and correct at their cited lines: `setup.md:23-24`, `README.md:46-47`, `friction-log.md:46`, `ci.yml:47`. All four of design §8's remaining obligations carried (state-ledger, gating-matrix, `CLAUDE.md`, `car-brief.md`/`car.md`/`/goodnight`). Design §8's `setup.md:21` item is *stale in the design*, not missing here — `setup.md:21` now reads "…gating matrix, **design doc**". |
| **M3** rows 4/5 contradiction | **CLOSED** | §4 row 4 now: *"The verifier is repointed at the new store and `ci.yml:47` is updated IN THE MIGRATION COMMIT."* Ruling 4 adopted as ruled. §9 row 8 assigns the repoint to Car 3. The row also now cites `:87-90` and `:94-96` separately rather than my looser `:87-96` — more precise than my finding. |
| **M4** rendering in/out of scope | **PARTIALLY CLOSED** | Both instances I cited are fixed: §3.1 *"the fold exposes a supersession marker"* + the explicit blanket ruling *"These are FOLD requirements, not rendering requirements"*; §6 *"spend absent is **reported absent**"*. **Residue:** §2.5 still states *"**The board renders which tier is in force.**"* as a requirement of this train, and §10 row 10 blesses it ("tier rendered → §2.5"), while §8 keeps rendering out of scope. §3.5's *"fails to render as unknown"* is the same shape. Rated Minor — see n2. |
| **M5** filter menu + unachievable injection | **CLOSED** | §2.2: *"The producer filters on `agent_type`, unconditionally and alone"*, with the transcript test explicitly *"never as the sole filter"*. Denominator checked against source: `design:322-325` (74 firings / 74 `agent_id`s) and `design:329-331` (*"70 of 74 firings carry `agent_type: ''` … Only 4 were `car`"*) — **4 is correct for the probe window**; 7 was my lifetime-transcript count. Under the single-filter producer §2.2 mandates, removing the filter admits all 74, so the injection **can now fail**. The clause *"both counts taken over the same probe window"* closes the window-mixing I flagged. |
| **M6** five dropped design requirements | **CLOSED** | Each verified at its section, not via §10: liveness gradient + budget + shop default → §3.3 (all three, *"a gradient, not a cliff"*); envelope + how `returned` obtains its outcome + absent-vs-malformed as **different faults** → §2.3; concurrency rule → §2.4, carried verbatim from `design:230` including *"RAISED, never dropped silently"*; vocabularies-as-data + unknown-value-as-discovery + one-fault-not-N → §3.2 (`design:147-150`, `design:228`); P6 context-optional → §3.4; ruling Q2 un-backfilled gap → §3.5. |
| **M7** index lifecycle wrong | **CLOSED** | New §5.2 names the index as a committed derived second copy and cites Law 6 by name. Ruling 6 adopted. Owner exists (§9 row 8, "index-staleness gate (§5.2)"); test cell exists (§6, *"Stale the index and confirm CI **fails**"*). §5.1 row 3 also changed "writes `INDEX.md`" → "writes the index", consistent with §3 handing index *format* to the schema artifact. |
| **M8** grain delegated | **CLOSED** | Title retitled to *"One Artifact Per Dispatch EVENT"*; §3's deferral list is now *"field names, types, ordering, identity, the index format, and the path-normalisation substitution rule"* — grain removed, exactly matching `design:141`; header note `:16-20` states the ruling and why. |
| **m1** async generalisation | **CLOSED** | Added as §7.5, load-bearing, with the tier-1-goes-vacuous consequence stated. |
| **m2** git-root derivation under-specified | **CLOSED, better than filed** | §4 row 1 names the mangling *and* the detached-worktree divergence, and rules it *"the implementer's first task, not an assumption"*. |
| **m3** backfill loses its extraction engine | **CLOSED** | §4 row 3 rules it: *"the CLI takes an EXPLICIT transcript path argument"*. |
| **m4** §3 disclaims field names then names `cost` | **NOT CLOSED** | §3 preamble still defers *"field names"*; §3.4 still reads *"Spend renders only from `cost`"*. §12 claims *"m4 resolved by §3's split"* — the split does not touch this. Cosmetic, non-blocking, but the closure claim is not supported by the mechanism. |
| **m5** tier 2 not CI-reachable | **CLOSED** | §2.5 folds it with the citation; I confirmed `ci.yml:32` is still the bare `- uses: actions/checkout@v4` (the ci.yml diff only touched lines 49+). Car 3 owns the fetch (§9 row 8). |
| **m6** "subject" vs "dispatch" | **NOT CLOSED** | §3.1 says *"Precedence for one dispatch"*; §6 says *"two records for one subject"*. Unchanged. §12 claims *"m6 and m7 resolved by §10"* — §10 is the design-fidelity ledger and does nothing for terminology. Non-blocking, but the claim is false. |
| **m7** no disposition discipline | **CLOSED, and graduated** | §10 + §12 provide it, and the discipline was written into the institution at `CLAUDE.md` ("Obligations cross rungs by CARRIER, never by memory") with my finding recorded as its scar. |

### Rulings

| # | Ruling | Status |
|---|---|---|
| 1 | Grain is behavioural, fixed in the spec; retitle to "per dispatch EVENT" | **ADOPTED as ruled** — title, §3 deferral list, header note |
| 2 | Filter on `agent_type` only; transcript test never sole; injection expectation 74 vs 4 over one window | **ADOPTED as ruled**, verbatim in §2.2 and §6 |
| 3 | Rendering out of scope; state fold requirements instead | **ADOPTED, one residue** — §3.1 and §6 converted; §2.5 not (see n2) |
| 4 | Verifier repoint and `ci.yml:47` land in the migration commit | **ADOPTED as ruled** — §4 row 4 |
| 5 | Delete probe 3; carry `design:230` instead | **ADOPTED as ruled** — probe deleted, deletion *recorded* in §7's closing note, rule carried in full at §2.4. The deletion did not lose the ruling. |
| 6 | Index regenerated-and-diffed by CI, or not committed | **ADOPTED as ruled** — §5.2, plus owner (§9) and fault-injection cell (§6) |

**Disagreements stated openly:** none needed; no ruling was adopted in name only.

---

## NEW FINDINGS (delta only)

### MAJOR

**N1 — §10, the fidelity ledger invented to close M6, contains a false row, and it masks a real drop.**
Spec `:253`: `| Normalisation before hashing | §8 (unchanged from design §9) |`.
- **§8 is silent on it.** I read `:217-222` in full: signing, retention, other runners, rendering, pre-train migration, `background_tasks`. No normalisation. `grep -n -i "normalis\|normaliz"` over the whole spec returns exactly three hits — `:13` (header owner decision), `:98` (§3, deferred to the schema artifact), `:253` (the ledger row asserting §8). **Zero hits in §8.**
- **"design §9" is the wrong section.** `design:260-261` is `## §9 - Cost`. Publication is `design:211-216` (§5.7).
- **The substance is genuinely absent, which is what makes this more than a typo.** `design:26` assigns **publication** and **trust** to the *behavioural* half — this document's half. `design:213-215` requires normalisation *"with the rule declared in each artifact and the original preserved on the checkpoint branch."* Only the *substitution rule* is legitimately deferred (per `design:37`). The two behavioural obligations — **the rule declared in each landed artifact**, and **the un-normalised original preserved on the checkpoint branch** — appear nowhere in rev 2. The same is true of `design:233`'s trust row (integrity check plus an independent checkpoint copy); §8 mentions "the integrity hash" only to scope *signing* out, and no section requires the hash or the independent copy.

This is precisely the failure the repo's own new doctrine names: `docs/templates/worked-rung-carriers.md:48-49` — *"drifted meaning the words are there but the substance moved. A drifted fold is the subtle failure this chain exists to catch: **the fold that LOOKS folded**."* A plan-writer or the plan adversary walking §10 row by row — which `CLAUDE.md`'s new carrier rule now *mandates* they do — opens §8, finds nothing, and either records a false DRIFTED or assumes coverage. And the dropped obligation is not incidental: `Land-Verdict.ps1:281` argues that the independently-written checkpoint copy, *"not the hash, is the defence against whoever controls this script"* — that is the Law 1/Law 8 backstop for a public showcase, and nothing in rev 2 requires it.

Worth naming: `worked-rung-carriers.md:57-58` predicted this exact failure mode — *"If you build the central form anyway, make CI walk it."* The author built the central form; CI does not walk it; the first row-level check by a human found a false row.

### MINOR

**n2 — Ruling 3 residue at §2.5.** *"**The board renders which tier is in force.**"* is a rendering requirement inside a train whose §8 excludes rendering, and §10 row 10 endorses it. Faithful to `design:199`, but ruling 3 reclassifies all such statements. Correct form: *the fold exposes which tier is in force*. §3.5's *"fails to render as unknown"* is the same shape. Held at Minor because §3.1's blanket ruling makes the intent unmistakable two sections away.

**n3 — The migration commit has no owner.** §4 row 4 and row 5 both mandate work *"in the same commit"* (verifier repoint, store migration, index creation). §9 assigns `ci.yml` to Car 3 and the store/ledger/gating-matrix to Car 1, but no row owns the migration itself. Two cars' deliverables are constrained into one commit with no named author — and `CLAUDE.md`'s cost rule says to split at clean boundaries only. A plan can rule this; it should not have to guess it.

**n4 — `docs/setup.md:24` went stale inside this delta.** It reads *"**Seven** design-review verdicts"*; `ls docs/reviews/` returns **8** (the round-1 spec verdict landed in this range, +245 lines in the diff). The spec correctly updated its own count to eight in three places (`:29`, `:155`, `:221`), which proves the author knew the count moved. `setup.md` is `Status: Current`, and `scripts/tests/DocPolicy.Tests.ps1:27` defines Current as *"true now; a stale claim in it is a defect"* — the repo's own new gate condemns it, and cannot catch it, because the gate checks the presence of the Status line, not the truth beneath it. `docs/setup.md` is absent from the entire `7e49d43..3fba437` file list.

**n5 — Two false closure claims in §12.** *"m4 resolved by §3's split"* (it is not; §3.4 still names `cost` while §3 defers field names) and *"m6 and m7 resolved by §10"* (§10 is the design-fidelity ledger; m6 is a terminology inconsistency it does not touch). Both underlying findings are cosmetic; the defect is that a review-record section — which stays in the document forever — asserts closures that the mechanism does not support. That is the same class as N1 at lower stakes.

---

## RULING ON THE TEMPLATE QUESTION

`docs/templates/worked-spec.md` is **unamended** — `git diff --stat 7e49d43 3fba437 -- docs/templates/worked-spec.md` is empty. What landed instead is `docs/templates/worked-rung-carriers.md` (new, 107 lines) plus a new `CLAUDE.md` section, both of which state the doctrine and record my finding as its scar.

**Ruling: this does NOT block the plan rung.** The plan rung's carrier is `worked-plan.md`, and the handoff into it is intact because *this* spec now carries §9 and §10 itself. The obligation travels.

**But it is open institutional debt with a deadline that is not "someday": it must close before the next spec is written from `worked-spec.md`,** because that spec will reproduce both holes. `worked-rung-carriers.md:102-107` makes the argument against itself better than I can — *"the fix is never 'remember harder' - it is making the next rung's TEMPLATE demand the carrier section… the receiving side is built to refuse delivery without it."* Right now the receiving side is a doctrine document a future author may not open. Ticket it against the template, not against this train.

---

## MAY THE SPEC PROCEED?

**Not yet — but the gap is one section and one table row, and no further round beyond a fix-and-confirm is warranted.**

**Must close in the spec (blocking):**
- **N1.** Correct §10's row to point at the section that actually carries it, and add the missing behavioural obligations to §3 — a §3.6 covering publication and trust: the normalisation rule is **declared in each landed artifact**; the **un-normalised original is preserved on the checkpoint branch**; each artifact carries an integrity hash whose independent counterpart is the checkpoint copy. Then re-walk all thirteen §10 rows the way I walked them (I verified the other twelve land where claimed).

**Should close in the same sitting (cheap, non-blocking):** n2 (one sentence in §2.5), n3 (one row in §9), n4 (`setup.md:24` Seven→Eight, and it invalidates a `Status: Current` document *now*), n5 (two words in §12), m4, m6.

**Recommendation:** land rev 3 as a rider and re-confirm N1 by mechanism only. Everything else about this revision is sound: eight Majors folded with IDs at the exact spots, six rulings adopted as ruled with none adopted in name only, two withdrawals and narrowings that were *more* precise than my own filings, and a probe deletion that carried its ruling forward instead of losing it. The document's failure class moved — round 1 found dropped requirements and wrong citations; round 2 finds one wrong row in the instrument built to prevent dropped requirements. That is the shape of a process working, and it is why the ledger needs CI to walk it.

---

```starcar-artifact
outcome: REJECT
findings: 1 Major, 4 Minor (delta only); 12 of 15 prior findings CLOSED, 1 PARTIALLY CLOSED, 2 NOT CLOSED (both cosmetic); 6 of 6 rulings adopted as ruled
abstract: |
  Delta re-review of docs/specs/2026-07-22-dispatch-harness-spec.md rev 2 at base
  3fba4379e70b3c7bbb6e0a82d9c3dee9cfd569b8. Read-only; no fault injection; tree clean
  before and after. Suites run by the reviewer at this SHA: Pester 21 passed, 0 failed,
  0 skipped; Verify-Verdict 8 of 8 hashes match, exit 0.

  One Major, and it is inside the fidelity ledger the author invented to close M6.
  Section 10's last row claims normalisation-before-hashing lands in section 8 and cites
  design section 9. Section 8 is silent on normalisation - grep over the whole spec finds
  normalisation at only three lines, the header, section 3's schema deferral, and the
  ledger row itself, none in section 8 - and design section 9 is the Cost section, while
  publication is design section 5.7. The substance is genuinely absent: design line 26
  assigns publication and trust to the behavioural half, and design lines 213 to 215
  require the normalisation rule to be declared in each artifact and the un-normalised
  original preserved on the checkpoint branch. Neither appears in rev 2, nor does the
  integrity-hash-plus-independent-copy trust obligation. This is the drifted fold that
  the repo's own new worked-rung-carriers doc names at line 48 as the fold that LOOKS
  folded, and that same doc predicted the failure at line 57 by warning that a central
  ledger needs CI to walk it. The author built the central form; CI does not walk it; the
  first human row-level check found a false row.

  Closures verified by mechanism, not by the author's section 12 summary. M1 withdrawn
  correctly and independently confirmed: grep count zero in both scripts, both quoted
  self-descriptions exact, and the rev 2 citation is narrower and more precise than the
  reviewer's own round 1 range. M5's denominator corrected to 4 and verified against
  design lines 322 to 331; the injection can now fail under the single-filter producer
  that section 2.2 mandates. M2, M3, M6, M7, M8 closed at their sections. M4 partially
  closed: section 2.5 still says the board renders which tier is in force while section 8
  excludes rendering, rated Minor because section 3.1's blanket ruling makes intent clear.
  Minors m4 and m6 not closed, and section 12 asserts closures for both that the mechanism
  does not support. All six rulings adopted as ruled, none in name only; the deleted
  git-contention probe carried its ruling into section 2.4 in full.

  New Minors from the delta: ruling 3 residue at section 2.5; the migration commit has no
  owner in section 9 although two rows mandate same-commit work; docs/setup.md line 24
  went stale inside this delta, still saying Seven design-review verdicts against eight
  landed, in a document declaring Status Current which the repo's own new DocPolicy gate
  defines as making a stale claim a defect; and two false closure claims in section 12.

  Template ruling: worked-spec.md is unamended, but the doctrine landed as
  worked-rung-carriers.md plus a CLAUDE.md carrier section. This does NOT block the plan
  rung, because this spec carries sections 9 and 10 itself and the handoff is intact. It
  must close before the next spec is written from that template, and belongs on its own
  ticket rather than this train.

  Disposition: land rev 3 as a rider closing the one Major, re-confirm by mechanism, no
  further full round warranted. The failure class moved between rounds - round 1 found
  dropped requirements and a wrong citation, round 2 found one wrong row in the instrument
  built to prevent dropped requirements.
```