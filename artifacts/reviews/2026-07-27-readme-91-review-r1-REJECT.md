<!-- starcar-integrity: sha256=c5fe26ae8bc844ef49d80daa72bb9bd7deb4304d7724e9d1b3c42900bbf6b1cc covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# README #91 accuracy sweep + rebalance, review round 1 (PR gate)

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car adversarial sentence-check review - PR gate for user-facing documentation
Round: 1
Target: `car/readme-91 HEAD ae22071`
Base reviewed: `20c3970`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: REJECT**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `a06d658c5485bd454`. The conductor did not retype a word of what follows. Verbatim by
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
> Path normalisation: the repository root was rewritten to ``<repo>`` and the operator home directory to ``~``, BEFORE hashing. Mechanical and narrow: only those two roots, longest-first, no other substitution. This is portability, not curation - findings, verdicts and counts are untouched, and the un-normalised original is on the Entire checkpoint branch.

## Provenance

Cited the way a paper cites a source: the work, the exact locator within it, and the
edition. Every reference below was followed before this file was written.

| | |
|---|---|
| Base commit the reviewer read (**the lookup key**) | `20c3970` |
| Entire checkpoint | `bc2128224ca2` |
| Dispatch, the locator within the session | `a06d658c5485bd454` |
| Entire session (context, NOT a lookup key) | `8a347c36-20b4-427a-ae0b-46855aa7bb72` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain 20c3970
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Cleanup confirmed: server stopped, port 4600 free, both checkouts byte-clean (worktree `ae22071` porcelain empty; shared checkout untouched at `f4b2c16`). I edited, committed, and pushed nothing.

---

# VERDICT: **REJECT** — 3 Major, 5 minor

The accuracy sweep did real work and the five defects #91 named are genuinely fixed. But the commit introduces two *new* false claims into the README — the exact defect class it was commissioned to remove — and its headline self-disclosure is itself incorrect and misrepresents an owner ruling on an open ticket. Disclosed-but-wrong does not clear review.

## BASE-DELTA

| | |
|---|---|
| Base | `20c3970` |
| Head | `ae2207159da7857cc16ac339f45f54ca0288a6a1` (detached, `%d` = `(HEAD, car/readme-91)`, no `-&gt;`) |
| Porcelain | empty |
| Ancestry | `git merge-base --is-ancestor 20c3970 ae22071` → yes (the verification block's SHA will resolve after merge) |

```
 README.md                                          | 167 +++++++++----------
 docs/screenshots/2026-07-27-readme-board/README.md |  68 +++++++++
 .../yard-board-2026-07-27.png                      | Bin 0 -&gt; 262829 bytes
 3 files changed, 157 insertions(+), 78 deletions(-)
```

Docs-only. No code, schema, or test touched — constraint honored.

## Suites run myself at `ae22071`

| Suite | Observed | Skips |
|---|---|---|
| `scripts/tests/DocPolicy.Tests.ps1` | **2/2 passed**, 0 failed | none |
| `scripts/tests/CodeCitationPolicy.Tests.ps1` | **13/13 passed**, 0 failed | none |

No detached-HEAD skip delta: the citation gate's own boundary test (`the boundary commit resolves in this checkout`) passed, so nothing degraded to the shallow-clone path. The car claimed DocPolicy 2/2 at `20c3970`; I reproduce 2/2 at `ae22071`.

---

# MAJOR FINDINGS

## R1-M1 — `README.md:101-102`: "at request time" is false, and contradicts `README.md:8`

&gt; `scripts/Detect-Dispatches.ps1` folds the store into dispatch and intent state (`board/server` runs its own Go port of that same fold, `board/fold`, **at request time**)

Hop-for-hop:

1. `board/server/poll.go:345` — `out := fold.Fold(records, s.vocab, now, opts...)` — the only call site of the Go fold.
2. It sits inside `PollOnce` (`poll.go:260`).
3. `PollOnce` is called only from `RunPollLoop` (`poll.go:244`), fired by `ticker := time.NewTicker(time.Duration(s.cfg.PollMs)...)` (`poll.go:232`), `PollMs: 1000` (`config.go:61`).
4. The request handlers do **not** fold: `handlers.go:29` and `handlers.go:65` both call `s.CurrentSnapshot()`, documented at `poll.go:202-203` as *"returns the last snapshot this server produced"* and implemented as a mutex-guarded read of `s.lastSnapshot` (`poll.go:204-208`).
5. What a stranger observes: a request is served from a cache refreshed once a second, never a per-request fold.

The same document already states this correctly at `README.md:8` (*"polls this repo's own artifact store (`artifacts/`) once a second"*), so the README contradicts itself 93 lines apart. The parenthetical is **new in this commit** (no equivalent text at `20c3970`). Fix: "at poll time" / "once a second".

## R1-M2 — `README.md:16-17`: "periodically reads" describes automation that does not exist

&gt; `scripts/Sync-Freight.ps1` (#84) **periodically** reads this repo's own GitHub Project board and writes ticket records into the store

Four independent hops all say otherwise:

1. `docs/setup.md:51` — **"Run it manually, on demand, from the repo root: `pwsh -File scripts/Sync-Freight.ps1`"** and **"DISCLOSED GAP … nothing in this repo invokes this script automatically today - no CI job, no scheduled workflow, no cron, no hook."**
2. `docs/setup.md` trigger-gated row *Freight adapter scheduling*: *"`scripts/Sync-Freight.ps1` exists and is run manually today - this row is ONLY about automating that invocation."*
3. Measured: `grep -rn "Sync-Freight" .github/ .claude/` → **zero hits**; `.github/workflows/` contains only `ci.yml`.
4. **The same commit's own sibling doc** — `docs/screenshots/2026-07-27-readme-board/README.md:33` — says *"`scripts/Sync-Freight.ps1` is a **manually-run** batch sync"*.

And the README contradicts itself again 22 lines later: `README.md:38` says freight goes alarm-red *"between **manual syncs**"*.

What a stranger observes: they run the board, freight is alarm-red and `stale`, and they wait for a periodic sync that will never fire. That is a live, practical consequence — precisely the #63 confusion the caption elsewhere tries to defuse. Law 1: *never describe behaviour the software does not have.* New in this commit (base said freight had no data source). The qualifier *"only as fresh as the last sync"* mitigates but does not repair the word "periodically". Fix: "is run manually, on demand" — and the honest gap is already written for reuse at `docs/setup.md:51`.

## R1-M3 — commit `ae22071` message: the #90/#91 accusation is false and misrepresents an owner ruling

The commit message asserts:

&gt; issue #91's own body **mischaracterized #90** as covering a four-column "area" row when #90 and the code (dom-writer.js:611-621, Sync-Freight.ps1) show freight carries exactly three fields with no area concept at all.

I opened both in both directions.

- **What #91 actually says:** *"'grouped by area' is NOT implemented (#90 is the open ticket for the four-column row including area)."*
- **What #90 actually says** — an owner ruling (`gh issue view 90 --comments`, author `polecatspeaks`, association `owner`, 2026-07-27): **"Four columns: `#N | phase | title | location`. PHASE is ruled to mean the issue's `area:*` label"**, with *"CONSEQUENCE FOR SCOPE: this is no longer a CSS-only ticket."*

#91's characterization is **exact**. The car's evidence (three wire fields today, no area concept in code) proves only that the column is *unbuilt* — which #91 itself said ("NOT implemented") and which #90's ruling states in its own words ("**PHASE IS NEW DATA**"). The car disproved a claim the brief never made, then published the accusation to a permanent record.

Why this is Major rather than a wording quibble: #90 is **OPEN**, and this commit message will land on a public `main` asserting that #90 has "no area concept at all". A future car scoping #90 off this message would drop the phase column the owner explicitly ruled in. Offered as a success outcome, it is a confident falsehood about an owner ruling.

**Note in the car's favor, and it matters:** the README's actual *treatment* is correct. It removed "grouped by area into future manifests" because the feature does not exist, and claims no area concept anywhere. Only the commit message is defective, and the fix is narrow — drop the accusation, keep the true observation ("freight carries three fields today; area is #90's unbuilt column"). The commit has never been pushed, so it is amendable in place.

---

# MINOR FINDINGS

**R1-m1 — `docs/screenshots/2026-07-27-readme-board/README.md:48-49`: wrong row ordinal.** Claims *"The Dispatches lane's **fifth row** reads `aa29fe4... dispatched 2:40`"*. I cropped the region (x 210-1295, y 32-84) and upscaled 2× nearest-neighbour: the chips left-to-right are `adapter-84-car…` returned, `design-87-r4-a…` returned, **`aa29fe4…` dispatched 2:40**, `adapter-84-rev…` returned, `design-87-amen…` returned. It is the **third**; the fifth is `design-87-amen…`. The load-bearing claim is true and visible; the coordinate is not — mildly aggravated because the doc asserts these were *"verified against the image directly … before this sentence was written."*

**R1-m2 — `README.md:41-43` (and screenshot README:50-52): #86's cause is stated as the half #86 corrects.** The factual half is true — I checked 8 dispatched records (`artifacts/*/dispatched-*.json`), all lack `task_id`. But #86's named defect is *"a manifest member's `task_id` is read by nothing in this repo"*, and #86 explicitly flags the producer framing as stale: it quotes `board/assemble/assemble.go`'s comment (*"dispatched records carry no task_id yet, pending #76's producer work"*) and answers **"the producer work is done and the consumer side was never built"**; its scope is *"read a member's `task_id` in `manifestPayload`"*. The README gives a producer-side cause for a consumer-side defect, implying the wrong fix.

**R1-m3 — `README.md:49-50` + Prerequisites: "no external service" is unqualified, and the first run needs network.** Fault-injected with an empty `GOMODCACHE` and `GOPROXY=off`:
```
go: downloading github.com/santhosh-tekuri/jsonschema/v6 v6.0.2
store\store.go:22:2: module lookup disabled by GOPROXY=off
exit=1
```
`board/go.mod` requires that module; there is no `board/vendor/`. Prerequisites lists only Go. Pre-existing text (identical at `20c3970`), but #91 scoped *"every remaining claim must be traced"*. One clause fixes it.

**R1-m4 — `README.md:123-135`: the Reading Order item the brief named was not addressed or declined.** #91's diagnosis explicitly named *"the Reading Order points exclusively at governing documents"*. It is unchanged — five entries, all process/governing docs, none pointing at the work (`docs/design/`, `board/`, the schema). Under "the work is the highlight", a stranger wanting to understand the board is still routed only to process documents. Editorial judgment is the car's to exercise, but a brief-named item should be closed or explicitly refused with a reason.

**R1-m5 — caption says "one … bare runtime hash" while the trains lane shows ten.** The sentence is literally precise (in the *dispatches* lane exactly one row is a hash) and screenshot README:40 notes *"with hash-named cars/reviewers"*. But the eye lands on ten 17-char hashes in the tallest lane. I verified these are **not** a defect: `artifacts/train-board-v0/intent-*.json` members carry only `subject` and `role`, no `task_id`, so the board is honestly rendering what exists. Worth one clause so a stranger is not left guessing.

**Nits (not findings):** bullet order (Trains/Gates/Dispatches/Freight/Fuel) differs from `laneregistry.go:29-33` and the screenshot's own 1-5 numbering; "The server serves:" omits `/schema/yard-snapshot.schema.json` (`handlers.go:19`) without claiming exhaustiveness; `README.md:105` is a sentence fragment; the imperative *"do not expose port 4600"* was dropped, though the substance survives at `README.md:43-45` and the default bind is `127.0.0.1` (`config.go:59`).

---

# SENTENCE-CHECK TRACES — claims that PASS

I traced every factual claim, not a sample. The ones that hold, with their hops:

**Quickstart, run end to end from this worktree.** `go run ./server` → server logged `listening on http://127.0.0.1:4600 (store=~/git/starcar-wt/review-readme-91/artifacts, demoMode=false)`. **I confirmed `storePathDisplay` in the live snapshot reads `~/git/starcar-wt/review-readme-91/artifacts`** — my own worktree, not the shared checkout. Port 4600 had **no** listener before I started (the conductor's stray process the brief warned about was gone), so no false green.

| Claim | Hop | Observed |
|---|---|---|
| `GET /` | `handlers.go:20` FileServer(WebDir) | **HTTP 200**, 929 B |
| `GET /api/snapshot` | `handlers.go:17` → `:28` | **HTTP 200**, 44,898 B |
| `GET /api/stream` SSE | `handlers.go:18` → `:38` | **HTTP 200**, `ct=text/event-stream`, first frame `event: yard` |
| `GET /js/app.js` | static tree | **HTTP 200**, 6,551 B |
| port 4600 / host 127.0.0.1 | `config.go:59-61` | as documented |
| "polls … once a second" | `config.go:61` `PollMs: 1000` → `poll.go:232` | confirmed |
| Go `1.26` per `board/go.mod` | `board/go.mod` `go 1.26` | exact |

**The "Verified 2026-07-27" block — re-run live, reproduced exactly.** Schema validation through the browser's *own* vendored validator (`board/web/js/validate.js:7` → `board/web/vendor/cfworker-json-schema/index.js`, draft `2020-12` per `validate.js:12`), against `schema/yard-snapshot.schema.json`:
```
valid: true
lanes: 5 | freight tickets: 41
```
And the freshness detail: `dispatches=idle, gates=idle, trains=idle, freight=stale, fuel=not-applicable` — matching the block word for word. This block is the strongest part of the diff.

**Freight = 41 real tickets.** My live snapshot's sorted ticket set is byte-identical to the screenshot README's published list: `1,2,3,6,10,11,14,15,16,17,19,22,23,25,43,44,45,55,56,57,58,59,60,61,63,64,66,68,70,72,73,76,77,78,80,81,82,83,85,86,87`.

**Five lanes, always rendered** → `laneregistry.go:28-34` (dispatches/gates/trains/freight live, fuel bagged); live snapshot returns exactly those five with `fuel` at `position=bagged`. Fuel "bagged … not surfaced yet (#11)" → `render.js:453` `{ kind: 'bagged', text: 'data held, not surfaced' }`; #11 is OPEN, titled per the claim.

**"the board process itself makes no outbound network call"** → `grep` for `http.Get|http.Client|net.Dial` across `board/**/*.go` (non-test): **zero**. `net/http` appears only for *serving* (`main.go:11-12`, `handlers.go:4`). Corroborated by `Sync-Freight.ps1:6-7` (*"board/server never calls GitHub itself … the board stays a PURE STORE READER"*).

**"Nothing it does writes to the artifact store"** → `grep` for `os.Create|os.WriteFile|os.Remove|os.MkdirAll|os.OpenFile` across `board/**/*.go` (non-test): **none outside tests**.

**"all exercised by a Pester suite under CI"** → `.github/workflows/ci.yml:236` `Invoke-Pester -Path ./scripts/tests`, plus probes (`:222`) and store-checks (`:255`).

**Law 7 citation** → `docs/constitution.md:53` `## 7. The Stranger`, `:55-57` *"documentation a stranger can deploy from."* The README's `(docs/constitution.md, Law 7)` is exact and is an *improvement* on the base's vaguer "the constitution's seventh law".

**"Nothing reaches `main` except by pull request"** → live `gh api .../branches/main/protection`: `required_pr=true, enforce_admins=true, force_push=false, deletions=false`.

**"the first thing merged to `main` was the revert"** → `gh pr view 5`: *"Revert the branch-protection probe commit from main"*, MERGED 2026-07-21 to `main`; `git log main --merges --reverse` puts `4a8736a Merge pull request #5` **first**. True as written.

**Stranger's clone resolves** → default branch is `main`; `origin/main` already contains `board/{assemble,fold,server,store,web}`.

**All 10 cited issue numbers exist and match** (#1, #11, #28, #47, #63, #76, #84, #86, #88, #90). #88's stated cause — *"it only fills from train-manifest membership"* — is #88's own measured root cause verbatim.

**Every file:line citation in the screenshot README is exact — 8 of 8 opened:** `board.css` has only two `freight` hits (`:34`, `:538`, both comments — zero style rules, confirming #90); `dom-writer.js:611-621` builds all five freight classes; `dom-writer.js:504` is `'no gates in this fold'` verbatim; `render.js:453` is `'data held, not surfaced'` verbatim; `config.go:63` is `StalenessMs: 15000`; `poll.go:514` is `computeLiveFreshness`; `poll.go:571` is the `"idle": a ticket queue has no…` comment; `poll.go:576` is `computeFreightFreshness`. This is exemplary citation discipline.

# SCREENSHOT RULING — both directions

I opened the image (1299×1251) and cropped it. **All five named defects are genuinely visible:**

| # | Named | Visible |
|---|---|---|
| #90 | freight rows have no CSS, read as run-on | **Yes** — `#1The yard visualizer: tracks, signals, freight, and fuelBacklog`: number, title and status fused |
| #63 | freight alarm-red / stale | **Yes** — freight plate reads `Live / stale, 13:35`, whole lane red |
| #76 | only the v0 walking-skeleton train | **Yes** — one train, `The yard board train (v0 walking skeleton) (train:board-v0)` |
| #88 | gates empty | **Yes** — `no gates in this fold` |
| #86 | in-flight row as a bare hash | **Yes** — `aa29fe4… dispatched 2:40` beside four human task-ids (though see R1-m1: third chip, not fifth) |

**Visible but not named:** the trains lane's ten bare hashes (R1-m5 — verified honest rendering, not a defect) and #90's *uncapped height* limb (the freight lane consumes ~55% of the image; #90's title names it, the caption compresses to "no CSS"). Nothing visible is *concealed*.

**Caption honesty posture: PASSES.** `README.md:34` reads *"That is a **dated observation, not a live-state claim**"*, and `:29-30` says *"captured 2026-07-27 - not a mockup, not cropped, not chosen for flattery"*. That is a validation device labelled with what it showed and when, not a marketing claim — and it leads with five defects rather than burying them. `docs/screenshots/2026-07-27-readme-board/README.md` satisfies the labelling rule: validated-what (7 verified bullets), captured-at (2026-07-27, with the honest limit *"the car cannot independently confirm the exact board code revision the owner's server process was running at capture time"* — an unknown disclosed rather than guessed, exactly right under Law 1), and a divergence statement (`:67-68`). `Status: Current` present at `:3`, and DocPolicy 2/2 confirms the gate sees it.

# EDITORIAL RULING — rebalance, not curation

**The shape satisfies the owner's direction.** Order is now *What it renders* (`:6`) → *Quickstart* (`:47`) → *Status* (`:96`) → *Process* (`:108`) → *Reading order* (`:123`). The work leads; the process is context. Process prose measures ~11 lines against the base's ~21.

**I accounted for every removed claim. None was removed for being unflattering:**

- *"no adapters beyond this repo's own artifact store"*, *"v0 … is the FIRST adapter"*, *"grouped by area into future manifests"* — removed **because false**. Correct.
- *"This repository opens process-first: before any code lands…"* — removed; also **stale**, since code has landed.
- *"That is the north star working — user-facing documentation must be true from the first commit…"* — removed. This was **self-congratulatory**; cutting flattering content is the opposite of curation.
- *"Plenty of dashboards exist…"* and the documentation-ranks-equal enumeration — **condensed**, load-bearing halves kept.
- *"every feature here **will be** … gated"* → *"every feature **is**"* — correct tense update now that features exist.
- Rail-metaphor labels (Tracks/Signals/fuel gauge) — dropped from bullets, but the metaphor survives in the tagline at `:3-4`.

**Both honesty commitments the brief protected are PRESENT and TRUE**, and both were *strengthened*: the PR #5 story gained a direct link (`:120`), and the Law 7 claim gained a file citation (`:115`). Verified live above. **No curation.**

**The retracted board-wide-staleness claim is absent in every form.** Every `stale`/`idle` mention in the README (`:38`, `:93-94`) attributes staleness to freight only, and `:93` states the live lanes read `idle`. `poll.go:539-542` confirms: `stale` only when `hasInFlightDispatch(dispatches)`, otherwise `idle`. The car's independent re-derivation was correct, and my own query reproduced it.

**Self-disclosure (b) is CORRECT.** The landed text at `README.md:101` — *"folds the store into dispatch and intent state"* — matches `Detect-Dispatches.ps1:9-19`'s own header (`dispatches: one entry per dispatch subject`, `intents: one entry per intent subject`). The car caught its own drafting error; the landed text is accurate.

# CONSTITUTION CHECK

- **Law 1 (Truth) — VIOLATED.** R1-M1 and R1-M2 are confident falsehoods on the repo's most-read surface, each contradicted by another line of the same document. R1-M3 is a confident falsehood in the permanent record about an owner ruling. Honored elsewhere: the fuel lane is disclosed as bagged, the screenshot leads with defects, and the capture-revision unknown is disclosed rather than guessed.
- **Law 6 (One Truth) — HONORED.** The schema is served from one file (`handlers.go:109-111`), and the browser validates against it rather than a mirror (`validate.js:1-7`). No second copy introduced.
- **Law 7 (The Stranger) — MOSTLY HONORED, one gap.** `git clone` → default branch `main` → `board/` present → `go run ./server` → HTTP 200 on every documented route: I walked it and it works. Gap at R1-m3 (first run needs network; Prerequisites says only "Go"). R1-M2 actively harms the stranger, who will wait for a sync that never fires.
- **Showcase-never-edits-the-record — HONORED.** PR #5's revert and the record-is-never-curated line both survive, verified true against `gh` and live branch protection. The screenshot ships warts-and-all per the owner's ruling. Removals were of false or flattering material, never of unflattering material.
- **Documentation ranks equal to code — the standard I applied.** These are Majors precisely because prose gets no discount.

# UNREPRODUCIBLE-EVIDENCE CALLOUT (#13)

Everything above is re-derivable at `ae22071` except: (a) the screenshot's capture-time board revision, which the car itself discloses as unconfirmable — my ticket-set match proves the *store* matches `20c3970`, not the board binary; (b) live `gh` results (PR #5, branch protection, issue bodies) reflect GitHub at 2026-07-27 and could change; (c) my cold-build injection depended on an empty `GOMODCACHE` + `GOPROXY=off`, restored afterward — the module is in the normal cache, so a warm machine will not reproduce the failure without the same injection.

# PR FITNESS

**The README is NOT yet fit to be the front door of a public PR.** Two of its factual claims are false and self-contradictory within the document, and the commit message misstates an owner ruling on an open ticket. These are cheap to fix — three edits to `README.md` and a commit-message amendment on an unpushed branch — and the document underneath them is a real improvement on the base. Fix R1-M1, R1-M2 and R1-M3, and I would expect this to clear a delta re-review quickly.

**Recommended route:** same-car fix cycle with a DELTA re-review (round 2), since the unwritten context is fresh and the fixes are surgical.

Files: `<repo>-wt\review-readme-91\README.md`, `<repo>-wt\review-readme-91\docs\screenshots\2026-07-27-readme-board\README.md`, `<repo>-wt\review-readme-91\board\server\poll.go`, `<repo>-wt\review-readme-91\board\server\handlers.go`, `<repo>-wt\review-readme-91\docs\setup.md`

```starcar-artifact
task-id: readme-91-review-r1
outcome: REJECT
findings: 3 Major, 5 minor

R1-M1 (Major) README.md:101-102 - "board/server runs its own Go port of that same fold, board/fold, at request time" is FALSE. fold.Fold is called only at poll.go:345 inside PollOnce, which is called only from RunPollLoop's ticker (poll.go:244, poll.go:232) at PollMs=1000 (config.go:61). Request handlers call s.CurrentSnapshot() (handlers.go:29, handlers.go:65), documented at poll.go:202-203 as returning the last snapshot produced. Contradicts README.md:8 in the same document. New in this commit.

R1-M2 (Major) README.md:16-17 - "Sync-Freight.ps1 periodically reads" describes automation that does not exist. docs/setup.md:51 states "Run it manually, on demand" and "nothing in this repo invokes this script automatically today - no CI job, no scheduled workflow, no cron, no hook". grep for Sync-Freight across .github/ and .claude/ returns zero hits. The same commit's docs/screenshots/2026-07-27-readme-board/README.md:33 says "manually-run batch sync", and README.md:38 itself says "between manual syncs". Law 1. New in this commit.

R1-M3 (Major) commit ae22071 message - the claim that issue #91's body "mischaracterized #90 as covering a four-column area row" is FALSE. #90 carries an owner ruling (author polecatspeaks, association owner): "Four columns: N pipe phase pipe title pipe location. PHASE is ruled to mean the issue's area:* label". #91 said exactly that, and also said the feature is NOT implemented. The car disproved a claim the brief never made and published an accusation against an owner ruling on an OPEN ticket into a permanent public record. The README's own treatment is correct; only the commit message is defective, and the commit is unpushed and amendable.

R1-m1 (minor) docs/screenshots/2026-07-27-readme-board/README.md:48-49 - "fifth row" is wrong; aa29fe4 is the THIRD of five chips, measured by cropping the image at x 210-1295, y 32-84 and upscaling 2x. The underlying claim is true and visible.

R1-m2 (minor) README.md:41-43 and screenshot README:50-52 - #86's cause is stated as the producer-side half that #86 explicitly corrects. Dispatched records genuinely lack task_id (8 checked), but #86's named defect is that a manifest member's task_id is read by nothing, and its scope is consumer-side (manifestPayload).

R1-m3 (minor) README.md:49-50 plus Prerequisites - "no external service" with Go as the only prerequisite. Fault-injected with empty GOMODCACHE and GOPROXY=off: "go: downloading github.com/santhosh-tekuri/jsonschema/v6 v6.0.2 / store\store.go:22:2: module lookup disabled by GOPROXY=off", exit 1. No board/vendor exists. Pre-existing text but in scope for the sweep.

R1-m4 (minor) README.md:123-135 - the Reading Order item #91 explicitly named is unchanged and neither addressed nor declined; all five entries are governing documents, none point at the work.

R1-m5 (minor) README.md:41-43 - caption names "one" bare runtime hash while the trains lane shows ten. Verified honest rendering, not a defect: artifacts/train-board-v0/intent-*.json members carry only subject and role, no task_id.

VERIFIED PASSING: quickstart end to end at 4600 against the correct store (storePathDisplay confirmed as the review worktree, no stray server); all four endpoints HTTP 200; real "event: yard" SSE frame; snapshot valid true via the browser's own vendored validator; 41 freight tickets with a sorted set byte-identical to the car's published list; freshness idle/idle/idle/stale/not-applicable reproducing the verification block exactly; all 8 file:line citations in the screenshot README exact; all 10 issue numbers exist and match; PR #5 confirmed the first merge to main; branch protection required_pr true, enforce_admins true; Law 7 citation exact; no outbound network call and no write syscall in board/ outside tests. DocPolicy 2/2, CodeCitationPolicy 13/13, both at ae22071, zero skips. No curation found: every removed claim was false, stale, redundant or self-flattering, and both protected honesty commitments survive and were strengthened. The retracted board-wide-staleness claim is absent in every form.

abstract: Adversarial sentence-check review of the README accuracy sweep and rebalance for ticket 91, at commit ae22071 over base 20c3970, docs-only across three files. Traced every factual claim in the new README to code with file:line at each hop, re-ran the quickstart end to end from the review worktree, re-derived the dated verification block live and reproduced it exactly, opened and cropped the embedded screenshot, and re-verified the PR-5 and branch-protection claims against live GitHub. REJECT on three Majors: two newly introduced false claims in the README, each contradicted by another line of the same document (the Go fold runs at poll time not request time; the freight adapter is manual, not periodic, as docs/setup.md states outright), and a commit message that falsely accuses the brief of mischaracterizing issue 90 when issue 90 carries an owner ruling saying precisely what the brief said. Five minors cover a wrong row ordinal in the screenshot verification doc, a mis-framed cause for issue 86, an incomplete prerequisites list proven by an offline-build fault injection, an unaddressed brief item, and an incomplete hash-row enumeration. The editorial rebalance itself passes: the work now leads, no record was curated, and the screenshot ships warts-and-all with an honest dated-observation caption and exemplary citation discipline. Fixes are surgical and the branch is unpushed; recommend a same-car fix cycle with a delta re-review.
```