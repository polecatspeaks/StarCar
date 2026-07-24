<!-- starcar-integrity: sha256=9a4a11d602d46b5f5fb6379cc820f228bb49160c2954fdae072413948b34584c covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# v0 yard skeleton design review round 3 (rev 4): REJECT - 3 Major at the manifest/fold seam, convergence healthy

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: Design review (adversarial, Opus, fresh detached worktree)
Round: 3
Target: `docs/design/2026-07-21-v0-yard-skeleton-design.md rev 4 at 98af4a6`
Base reviewed: `98af4a694a56f5774417c981fe913dc79596bea5`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a663c067d1d565f02`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `98af4a694a56f5774417c981fe913dc79596bea5` |
| Entire checkpoint | `bf390acab02f` |
| Dispatch, the locator within the session | `a663c067d1d565f02` |
| Entire session (context, NOT a lookup key) | `64c15364-0933-4d6d-9b2e-d1ddbc918f9f` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 98af4a694a56f5774417c981fe913dc79596bea5
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

All artifacts verified. I have what I need. Let me confirm the fold's `intents` output shape carries no payload (the core of my central finding) is exactly as the code shows, and then I'll write the verdict.

The evidence is complete. Constitution offsets confirmed (Law 1 clause is on line 18 not 17; Law 6 tail on 50 not 49; Law 7 "board schemas or label taxonomies" on 56, outside the cited 54-55). The fold's `intents` output carries only `subject`/`at`/`superseded` (Detect-Dispatches.ps1:211-215, Detector.Tests.ps1:116-120) — no manifest payload. All 9 FACTs reproduce. Owner rulings fold faithfully.

---

# ADVERSARIAL DESIGN REVIEW — v0 yard skeleton, rev 4 (design gate, round 3)

Base verified: `git log -1 --format=%H` = `98af4a694a56f5774417c981fe913dc79596bea5`, detached worktree. Read-only; nothing edited, committed, or pushed.

## VERDICT: REJECT — 3 Major, 5 Minor, 3 Notes

Rev 4 is a large and genuine advance. The harness re-cut is folded honestly, the instrument split (§0) is sound, all nine Go FACTs reproduce byte-for-byte, and rev 2's root-cause class (axes-without-composition) is closed on the page (§5.2 now states "rendered register = most severe of position/freshness/capability"). The three Majors are a new cluster at the one seam the harness re-cut created and never adversarially tested: the **manifest/fold boundary**. In each case the design consumes from the landed fold something the landed fold provably does not produce.

---

## CONVERGENCE RULING (stated explicitly per the brief)

**Healthy convergence. NO CAP, NO ESCALATION.** I walked all three swirl triggers:

- **Major counts are DECLINING:** 9 (rev 1) → 8 (rev 2) → 3 (rev 4). Not flat, not climbing.
- **Findings are NOT clustering in one section across rounds.** Rev 2's Majors clustered in composition (§5.5–5.6); that section is now closed. Rev 4's Majors spread across §5.3 (ownership), §6 (failure table), §5.5 (identity namespace).
- **Rev 4's Majors are NOT defects a prior fix created.** They land on the **manifest subsystem (D16), which did not exist before the harness re-cut.** This is new material at a new seam, not old defects relocated.

Zero of three triggers fire. The instrument (prose design + adversarial read) is resolving correctly; the residual Majors are exactly the observability-reality holes design review exists to catch at the substrate seam. This REJECT is a success outcome on a good trajectory.

**Who finds the law?** The §1 constraints table is genuinely law-first: demoMode suppression is gone, Law 2 is served by intent records, Law 4 preserve-and-disclose is on the page, Law 7 open-vocab is obeyed not merely cited. My Majors are observability holes (the substrate exposes less than the design consumes), not laws-the-author-missed-and-the-reviewer-found. The one law-first miss is DR3-6 (an unwritten premise), and it is Minor. The law-first process is working.

---

## MAJOR FINDINGS (any one = REJECT)

### DR3-1 (Major). The landed fold does not expose the manifest payload, and §5.3's "exactly one owner" derivation table is imprecise for every manifest-dependent surface

**Location:** §5.3 table, §5.5, §0 row 3.

§5.3 asserts "each derivation has exactly one owner" and routes:
- Trains ← Assembler ← "manifests (D16) joined to **fold output** by member subject"
- Yard inventory ← Assembler ← "**fold output** MINUS manifest members"
- Gates ← "**direct render**" ← "returned records' outcome verbatim; **round/gate identity from the manifest's declaration**"

But the landed fold's `intents` entry carries **only `subject`, `at`, `superseded`** — no members, no roles, no title, no ticket refs (`Detect-Dispatches.ps1:211-215`; the contract-vector `Detector.Tests.ps1:116-120` asserts exactly those three fields and nothing else). The fold that D18 ports to Go, with the vectors as the authority, **does not carry manifest membership at all.** So:

1. **The manifest payload must come from the RAW records** (which §5.3 says the adapter yields), not "fold output." The design never states this. A spec-writer reading "manifests joined to fold output" will look for members in the fold and find none.
2. **The fold-winner → raw-payload join is unspecified.** To pick the *current* manifest per train, the Assembler needs `fold.intents` (subject+at winner, per §5.5 "the fold exposing the newest intent"), then must fetch *that* raw record's payload. This two-step is nowhere in the design. **The Law 6 trap:** a car that instead re-selects latest-manifest over raw records re-implements the fold's intent-supersession — a second copy of fold logic, the exact drift Law 6 forbids.
3. **The Gates row has TWO sources by its own text** (returned `outcome` + manifest role declaration), and "direct render" hides an Assembler manifest-join. This contradicts "exactly one owner" in the row that most needs crisp ownership — the same class rev 2 rejected twice.
4. **D16/D17/§0 sequencing:** the manifest payload fields (§0 row 3, "TO PRODUCE") must be added to the Go typed struct's known key-set as well as the schema, or D17's unknown-field disclosure (§6) will flag every manifest's own payload as "N unrecognised fields." The design does not state this constraint.

**Why Major:** this determines the Assembler car's entire input contract, and it fails the ancestor observability-reality check (does the code actually expose what the design consumes?). It carries a live Law 6 re-implementation risk. **Fix:** state that manifest membership/roles/title/refs are read from raw records; specify the `fold.intents` winner → raw-record join; correct the "exactly one owner" claim (the Assembler owns trains/yard-inventory/gate-identity, consuming fold + raw manifests); and state the D17/schema-addition key-set constraint.

### DR3-2 (Major). The cascade-suppression guarantee is overstated: a valid-but-empty vocabulary file reopens the N-discoveries cascade rev 2 MAJOR-3 closed

**Location:** §6 row 5.

§6 row 5 claims: "Vocabulary file missing/malformed → ONE board condition; detector does NOT fire per-record (rev 3's cascade fix, carried)." A **valid-but-empty** vocabulary file (`{"values":[]}` — well-formed JSON, zero values) is **neither missing nor malformed.** It parses cleanly, so `$vocabOk = $true`, and then in the landed detector every record's kind fails `$kindValues -notcontains $k` and fires a discovery (`Detect-Dispatches.ps1:71-72, 101-108`). Result: every kind in the store reported as an unrecognised "discovery" — `kind: dispatched`, `kind: returned`, … — the precise N-false-discoveries wolf-cry rev 2 MAJOR-3 rejected, on a Law 5 surface meant to degrade correctly.

The tested guard (`Detector.Tests.ps1:140` "unreadable vocabulary directory is ONE fault") covers *unreadable*, not *empty*. This is realistic: positions and roles are open vocab shipped as data (D8), and an empty or truncated vocab file is a plausible edit/fork state.

**Why Major:** disclosed-but-wrong does not clear review (rev 2 MAJOR-4's exact principle) — the design asserts a closure the substrate does not deliver, and the failure is a Law 1/Law 5 lying instrument. **Fix:** add a §6 row for valid-but-empty (or below-a-floor) vocabulary treated as a single vocabulary fault, not fanned through the detector; and pin it as a vector (a valid-but-empty `values:[]` yields one fault, zero per-record discoveries).

### DR3-3 (Major). `subject` is one shared identity namespace, but §5.5 assumes train-manifest subjects and dispatch subjects are disjoint — no partition rule, no collision handling

**Location:** §5.5, §6; schema:15-17.

The schema makes `subject` "THE identity key" (one namespace: `starcar-artifact.schema.json:15-17`). A manifest is an intent record whose subject is the train id (§5.5); a dispatch's subject is the dispatch id. Nothing partitions these. If a train id equals a dispatch subject, the fold's per-subject bucket contains both a dispatch record and an intent record, and **both branches fire** — the subject appears in *both* `fold.dispatches` and `fold.intents` (`Detect-Dispatches.ps1:133-134, 136, 199`). The Assembler then has a subject that is simultaneously a train and a dispatch/member. §6 has no row for this; the result is a silent Law 1 misrender.

**Why Major (with honest severity caveat):** collision probability is low (conductor-chosen train ids vs hex dispatch ids), so I am not claiming an imminent lie. The Major is the **missing contract**: the design consumes `fold.dispatches` and `fold.intents` as disjoint subject-keyed sets without any rule guaranteeing disjointness, and the Assembler car will invent one. **Fix (cheap):** state a namespace-partition rule (e.g. manifest subjects carry a `train:` prefix, or manifests are keyed off a distinct field) OR add a §6 collision board-condition. Either closes it; pick one on the page.

---

## MINOR FINDINGS

- **DR3-4 (Minor). Citation ranges in §1 are off by one, three times.** Law 1 "Unknown states render AS unknown, honestly" is `constitution.md:18`, cited `:17`. Law 6 "…copy of anything that can drift" ends at `:50`, cited `48-49`. Law 7 "board schemas or label taxonomies" is on `:56`, **outside** the cited `54-55` (line 54 is blank). Every law is correctly identified and faithfully quoted — only the ranges slip. (Note: rev 2's reviewer instructed "cite 54-55" and was themselves off by one; the author followed the instruction faithfully.)
- **DR3-5 (Minor). §6 lacks two rows a car will look for.** (a) A *successful* scan of a present-but-empty store (Law 7 stranger on day one) — honest-empty, and it must be distinguished in the table from `failed` (directory missing). The completeness guard renders the empty lane, but the failure table is where a car checks. (b) All-records-quarantined (row 2's "remaining records load" degenerates to zero). Neither is a lie today; both deserve an explicit row.
- **DR3-6 (Minor). Unstated premise: the board does not re-verify record `integrity` hashes.** §3 calls the store "hash-verified," but §5.3's read path is "double-decode, schema-shape check, quarantine" — no integrity recomputation. For P3 (local checkout, reading the working tree which holds un-CI-gated live records) this is defensible (an attacker owning your checkout owns the hashes too), but it is a load-bearing premise that must be written in §2 with its if-false, per the harness scar on unwritten premises.
- **DR3-7 (Minor). §2c omits the browser-side validator probe.** Q4's tension is real, and "a dependency-free draft-2020-12 JS validator exists (no build step, P4)" is as unproven as the Go validator that §2c *does* list. It should be a listed probe with a plan-rung BLOCKING TEST and a stated negative branch, symmetric with the Go row.
- **DR3-8 (Minor). Load-bearing contracts carried by reference to superseded git history.** §5.2 carries the composition contract "compactly, full shapes in rev 3's text (git history)"; §9b dispositions rounds 1-2 findings via "rev 3 §13 (git history)." The composition rules were the rev-2 REJECT root cause; a reader cannot verify closure without checking out a superseded revision. Make the current design self-contained, or wholly delegate the precision to the spec-rung vectors §0 already commits — not a pointer to git.

## NOTES

- **Note-1.** Partial producer writes (the producer commits per-file; a mid-write file parses as broken JSON) will cause a transient one-poll quarantine that self-heals next scan — honest, but worth one sentence, plus a pointer that atomic producer writes are the harness's concern if it proves noisy.
- **Note-2.** D12 states "single static binary" as established rationale while §2c lists the cross-compile GOOS matrix as unproven. The single-binary property is a faithful fold of the #14 ruling (which asserts it), so acceptable — but the design asserts slightly more certainty than its own probe list.
- **Note-3.** The detached-HEAD / old-checkout case (P3) is adequately caught by the newest-record-`at` data-age signal in §5.6 (an old checkout scans successfully but renders stale by data age, honestly). Worth stating, because it turns an apparent hole into a demonstrated strength.

---

## RULINGS ON THE OPEN QUESTIONS (Q1–Q5). These bind unless appealed upward.

**Q1 — the dual fold. KEEP BOTH for v0; vectors as single authority is Law-6-sound. BINDING CONDITION: the cross-verifier must be a real CI gate.** Law 6 forbids a second copy that can drift *silently*; two implementations governed by shared conformance vectors cannot drift silently *provided divergence fires a red*. That "provided" is unproven until a CI job runs both the pwsh detector and the Go fold against the shared vectors and fails on divergence. D18 names the pwsh detector "as CI cross-verifier" — the spec/plan must make that a genuine job, or the Law 6 escape is asserted, not observed (a guard is unproven until watched to fire). Retirement stays deferred (Q1/§7): losing the only toolchain-free fold mid-transition is the larger cost.

**Q2 — manifest collision. DISCLOSED-COLLISION is correct; do NOT extend latest-`at`.** Latest-`at` supersession is store law for records of the **same subject**. Two *different* manifests (different train subjects) claiming one dispatch is not a same-subject case — it is two sources disagreeing, which Law 6 (`constitution.md:50-51`) resolves by SHOWING the disagreement, never picking a winner silently. Inventing a cross-manifest latest-`at` winner is precisely the silent winner Law 6 forbids. §6 row 8 and the Q2 framing already lean this way; ruling confirms it.

**Q3 — the 29 migrated verdicts. STAY IN YARD-INVENTORY until backfill manifests exist; REJECT the subject-slug convention.** #557 and the design's own D16 ban roles inferred from behaviour. A slug convention ("this looks like a review") is that inference. The migrated `returned` records render honestly as yard-inventory dispatches with their outcomes; they simply are not grouped into a gates lane until a manifest declares their roles. The backfill is "cheap and honest" (Q3's own words); the convention is "free and smells." Honest-and-cheap wins under Law 1.

**Q4 — browser validation depth. Prefer a SINGLE vetted, no-build-step JS draft-2020-12 validator pointed at THE wire-schema file; hand-rolled structural check loses more (Law 6).** A schema validator is data-driven — it *consumes* the one schema artifact, so it is not a second copy of the schema's knowledge. A hand-rolled structural check **is** a second copy of the field/type knowledge the schema owns (the design's own D15/D17 logic). The dependency is one reviewed, one-time module honoring P4 (no build step). Condition: it must validate against the same schema the Go side does (one schema, two conformers). If no dependency-free validator meeting P4 exists — a probe this design must add (DR3-7) — fall back to a structural check as a *disclosed* degradation.

**Q5 — first paint. HONEST-BUT-THIN is correct; do NOT pull the freight adapter into v0.** The walking-skeleton amendment (#1 body) explicitly wants the real layout in the real browser with honest non-live states rendering loudly — a first screenshot showing honest `dark`/`bagged` lanes *demonstrates the Law 4 mechanism working*, which serves the showcase's honesty thesis better than a denser board. Freight stays out with its stated §7 trigger. Caveat tied to DR3-1/Q3: the trains lane is also thin on day one (no manifests written yet) — which is honest, not a defect.

---

## CONSTITUTION CHECK

| Law | Verdict |
|---|---|
| **1. Truth** (`:14-18`) | **FINDING.** Honored broadly (D17 preserve-and-disclose, `failed`/`lastGood`, unknown-by-name). Violated by DR3-2 (empty-vocab wolf-cry) and DR3-3 (colliding subject rendered as two things). |
| **2. The Dispatcher Commands** (`:21-23`) | **HONORED.** D14: the override IS a store write (`held` intent record), rendered because the source of truth says so; the fold's later-intent-supersedes test (`Detector.Tests.ps1:111-120`) backs it. No view-side override in v0 (§7), correctly deferred. |
| **3. Actionability** (`:26-31`) | **HONORED, contingent on DR3-1.** The gates/needs-attention register drives the glance — but only once the manifest→role join (DR3-1) is specified, since gate identity rides the manifest. |
| **4. Nothing Silently Lost** (`:35-37`) | **HONORED where legislated** (D17/FACT1-3, yard-inventory for orphans), **but DR3-1 risks silent loss of manifest members** the fold cannot carry, and DR3-2 converts loss into noise. |
| **5. Self-Knowledge** (`:41-44`) | **FINDING via DR3-2** (a config fault mis-rendered as N discoveries hides its own cause). `asOf`/data-age split is otherwise sound. |
| **6. One Truth** (`:48-51`) | **FINDING.** Honored by D15/D18 (schema single-owner; vectors as sole fold authority). Weakened by DR3-1 (the fold-supersession re-implementation trap) and by the "exactly one owner" claim the Gates row contradicts. |
| **7. The Stranger** (`:55-57`) | **HONORED in aim, gapped by DR3-5** (no explicit empty-store day-one row) and DR3-7 (browser-validator probe unlisted). Open vocab as data (D8) obeys the law rather than citing it. |
| **8. Growth** (`:60-63`) | **HONORED.** §9b, §13, and the inherited-risk disclosure record the history in public; the detector is a genuine Healing-Loop instrument. DR3-2 is where an instrument currently cries wolf. |

---

## RE-REVIEW GATE

For APPROVE next round, close DR3-1, DR3-2, DR3-3 **in the design** (each determines an Assembler/fold contract cars inherit as ground truth). DR3-4 through DR3-8 are one-to-few-sentence fixes and should land in the same revision. The five Q-rulings are binding; fold each with its `[Q#, ruling adopted/appealed]` disposition per the carrier rule. Convergence is good — the fix list is short and the trajectory is downward; I expect one more round closes it.

I edited nothing, committed nothing, pushed nothing. Worktree is as I found it at `98af4a694a56f5774417c981fe913dc79596bea5`.

```starcar-artifact
outcome: REJECT
findings: 3 Major, 5 Minor, 3 Notes. DR3-1 Major: the landed fold exposes no manifest payload (Detect-Dispatches.ps1 lines 211-215; vector Detector.Tests.ps1 lines 116-120 assert only subject/at/superseded), yet section 5.3 derives trains, yard-inventory, and gate-identity from "manifests joined to fold output" and claims "exactly one owner" - the payload must come from raw records via an unspecified fold-winner-to-raw join, with a Law 6 re-implementation trap; the Gates row is two-sourced. DR3-2 Major: section 6 row 5 claims malformed-vocab yields ONE condition, but a valid-but-empty vocabulary file (well-formed JSON, zero values) is neither missing nor malformed and reopens the N-discoveries cascade rev 2 rejected, reproduced in the landed detector (Detect-Dispatches.ps1 lines 71-72, 101-108) - disclosed-but-wrong, Law 1/Law 5. DR3-3 Major: subject is one shared identity namespace (schema lines 15-17) but section 5.5 assumes train and dispatch subjects disjoint with no partition rule; a colliding subject lands in both fold.dispatches and fold.intents (Detect-Dispatches.ps1 lines 133-134, 136, 199) - missing contract, cheap fix. Minors: three off-by-one constitution citation ranges (Law 1 line 18 not 17, Law 6 tail line 50, Law 7 line 56 outside cited 54-55); section 6 missing empty-store and all-quarantined rows; unstated premise that the board does not re-verify integrity hashes; section 2c omits the browser JS-validator probe; load-bearing composition contract carried by reference to superseded git history. All 9 Go FACTs re-ran and reproduced byte-exact. Owner rulings 14/20/1 fold faithfully. Q1-Q5 ruled: keep dual fold with a binding CI cross-verifier condition; disclosed-collision not latest-at; yard-inventory plus backfill not slug-inference; single schema-driven JS validator over hand-rolled; honest-but-thin first paint acceptable.
abstract: REJECT at design gate round 3 on 3 Major findings, all new material at the manifest/fold seam the harness re-cut created - the design consumes manifest membership, roles, and cascade-suppression the landed fold and detector provably do not provide. Convergence is HEALTHY: Major counts decline 9 to 8 to 3, findings do not cluster in one section across rounds, and none are defects a prior fix created - zero of three swirl triggers fire, so NO CAP and NO ESCALATION. The composition class that sank rev 2 is closed. Fix list is short and closeable in one revision; five open questions ruled with binding dispositions. REJECT reported as the success outcome it is on a good downward trajectory.
```