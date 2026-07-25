<!-- starcar-integrity: sha256=5f7c10c9fbfcbe01fe9112a32101391b04d20b3d785730f4d56dfc6d12bf7778 covers every byte below this line; recompute with scripts/Verify-Verdict.ps1 -->
# Register train #35/#36/#37 adversarial review - round 1

Status: Done
Record: verdict of record - historical by nature, never edited after landing
Gate: car-review

Target: `car/register-35-36-37 @ 451e6d158753b5fb15614404b07d19574abe5361`
Base reviewed: `f4b538e3dab071896b455feced09db276833fd1b`
Reviewer: car agent type, Opus, read-only, detached worktree, no delegation
**Verdict: APPROVE-FOR-MERGE**

> Extracted VERBATIM from the session transcript by `scripts/Land-Verdict.ps1` --
> task id `register-35-36-37-review-r1`. The conductor did not retype a word of what follows. Verbatim by
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
| Base commit the reviewer read (**the lookup key**) | `f4b538e3dab071896b455feced09db276833fd1b` |
| Entire checkpoint | `4e4a4df1f06e` |
| Dispatch, the locator within the session | `register-35-36-37-review-r1` |
| Entire session (context, NOT a lookup key) | `regrev-landing` |
| Landed by | `scripts/Land-Verdict.ps1` - verbatim extraction, never retyped |

Follow the citation:

```
entire checkpoint explain f4b538e3dab071896b455feced09db276833fd1b
entire checkpoint search "<a distinctive phrase from the body below>"
git log entire/checkpoints/v1 --oneline    # the independently-written public copy
```
<!-- verbatim-body-below: do not edit past this line -->

Register train adversarial review, round 1.

VERDICT: APPROVE-FOR-MERGE

All verifications pass:
1. Test counts: JS 62 pass / 0 fail at tip; Go all 5 packages pass; gofmt clean on touched Go file.
2. Three attacks (#35): All three (inherit, currentColor, commented-out) now produce failures. The brace inside a comment no longer truncates extraction (suite stays green).
3. #36 semantics: .track-title uses var(--text) which is the neutral paper token (:root line 20: --text: #d9d5c9 paper). .declared-not-observed uses var(--needs-attention) - same token as .register-needs-attention, structurally pinned by the test. dom-writer.js:114 and :133 emit both classes.
4. #37 pins: JS test reads schema from disk (not hardcoded), asserts set equality, carries ordering-is-compose.js-owned comment. Go test same pattern. Fault-injection verified non-vacuity for both.
5. Ticket citations: #35, #36, #37 all cited in every new code addition.
6. Regression scope: Exactly 4 files touched, all within board/web and board/assemble. No docs invalidated.
7. TDD evidence: Both commit messages carry explicit red-first fault-injection evidence with quoted failure messages.

Findings: 0

```starcar-artifact
task-id: register-35-36-37-review-r1
outcome: approve-for-merge
findings: 0
abstract: All three commits verified empirically. JS suite 62 pass, Go 5/5 packages pass, gofmt clean. The three #35 attacks (inherit, currentColor, comment-out) all produce failures at tip. #36 CSS semantics match owner ruling (neutral paper for track-title, structural pin to needs-attention for declared-not-observed). #37 taxonomy pins fire on fault injection in both JS and Go. No scope creep, no stale docs, ticket citations present throughout.
```