# Repo policy: every file:line citation outside artifacts/ resolves to a real
# coordinate (#65).
#
# WHY THIS EXISTS. The citation-truth defect class hit NINE-PLUS instances across two
# trains in two days (view train #28+#12, rounds 1-3: artifacts/reviews/2026-07-26-
# view-28-12-review-r1-REJECT.md, -r2-REJECT.md, -r3-APPROVE.md), all caught only by
# expensive adversarial review attention, never mechanically. Round 3 independently
# proved the unwrapping technique this file ports: "an unwrapping scanner: it strips
# comment leaders and joins all lines with no separator before matching the coordinate
# shape, so a citation split across a line wrap cannot hide." This gate is that
# mechanism, ratified by the owner (issue #65 comments) to land immediately after that
# train, ahead of #67/#69/#68.
#
# WHAT THIS GATE ACTUALLY CATCHES, stated plainly and corrected against #65's own
# round-1/round-2 review history (round 1 inherited an unverified claim as ground truth
# and repeated it; round 2 tested it and found it false - see the note below):
#   BINDING, mechanically proven by fault injection against the real repo:
#     - CLASS A, dead path - a citation (single-line, or line-wrapped per the CLASS C
#       note below) to a file that does not exist at HEAD. Two live instances (a stale
#       "docs/reviews/..." path after harness #7's migration to artifacts/reviews/,
#       git mv, history preserved) were found and fixed at this gate's own landing.
#     - CLASS B FLOOR, out-of-range line - a citation whose line number (or the larger
#       end of a range) exceeds the target file's current line count. This is the
#       ONLY shape of "shifted line" this gate catches: a shift that pushes the
#       coordinate PAST END OF FILE.
#   NOT CAUGHT, disclosed rather than silently over-claimed: an IN-RANGE shifted
#     citation - a line number that was true when written, drifted when an unrelated
#     edit inserted lines above it, and now points at a DIFFERENT but still-existing
#     line inside the same file. This gate has no symbol/content check strong enough to
#     catch this class (see CHECK (c) below - report-only, not binding, precisely
#     because it cannot carry this weight yet). Content anchoring DOES catch a subset
#     of in-range shifts (where the citing text quotes a token that migrated with its
#     original context) - it scored 2-for-2 on real defects the round-2 reviewer found
#     (see CHECK (c) and the ROUND-1/ROUND-2 CORRECTION below) - but the population is
#     still too small (n=6 at round-2 landing) to bind without an unmeasured
#     false-positive risk; see CHECK (c) for the full, honest argument.
#
# THE ROUND-1/ROUND-2 CORRECTION, stated because repeating an unverified claim is
# exactly the defect class this gate exists to stop, and this file nearly did it to
# itself: round 1's header quoted the #28+#12 train's round-2 verdict verbatim - "A
# test that greps `\S+\.(go|js|css|md|json):\d+` outside `artifacts/` and asserts each
# coordinate resolves would have caught MAJOR-1, MAJOR-2 and MAJOR-R2-2 mechanically" -
# and inherited it as settled fact without testing it. #65's own round-2 reviewer
# TESTED it: all three cited coordinates (schema:191 at 3076a40, config.go:42 at
# 3076a40, dom-writer.js:201 at 6346d7d) were IN-RANGE at the commits in question - a
# negative-control in-range shift left this gate 11 passed / 0 failed. THE PARENTHETICAL
# THIS FILE ORIGINALLY ATTACHED HERE ("zero backtick tokens on their citing lines") WAS
# ITSELF UNMEASURED AND WRONG for one of the three (#65 round 3, MAJOR-R2-1) - measured
# now: `dom-writer.js:150`'s citing prose (schema:191's target, at 3076a40) carries no
# backtick token; `elapsedbucket_test.go:26-27`'s citing prose (dom-writer.js:201's
# target, at 6346d7d) carries none either. `docs/design/2026-07-21-v0-yard-skeleton-
# design.md:611`'s citing prose (config.go:42's target, at 3076a40) DOES carry one:
# `` measured: `StalenessMs` ships at `15000` (`board/server/config.go:42`) `` - one
# qualifying backtick token, `StalenessMs`. Under round 1's `-match` (case-insensitive)
# it would FALSE-HIT against `board/server/config.go:56`'s lowercase `stalenessMs`
# prose (the exact collision CHECK (c)'s MINOR-2 note already names); under round 2's
# own `-cmatch` (case-sensitive) it MISSES - correctly, because config.go:42 sat inside
# the `Config` struct's field block, nowhere near either `StalenessMs` occurrence
# (the field declaration at `:14` and `DefaultConfig()`'s assignment at `:63` are both
# outside the +/-15 line window `:42` sits in). THE WIN THIS RECORDS: post-`-cmatch`,
# this content anchor would have flagged ALL THREE of the view train's named findings as
# misses, not zero - a 3-for-3 true-positive record on real defects, pinned as a
# fixture below (`Test-ContentAnchorHit`'s "reproduces the historical config.go:42
# false-hit/true-miss pair" case) rather than left as prose. The #28+#12 train's own
# round-2 verdict was WRONG about what a BINDING resolver like this one would catch
# (Class A/B checks alone do not reach in-range shifts); it was RIGHT, though nobody
# measured it at the time, about what the content anchor - unbound, unread, sitting in
# this file's own report-only diagnostic - already could.
#
# PRECEDENT SHAPE PORTED: scripts/tests/CodeCitationPolicy.Tests.ps1 (corpus-scan,
# closed-set, self-calibrating, reds BY NAME) and board/store/condition_severity_test.go
# (AST/corpus-scan against real sources, set-equality both directions). This file is
# that same shape aimed at file:line coordinates instead of ticket citations or
# severity codes.
#
# NO SHALLOW-CLONE HAZARD (unlike CodeCitationPolicy.Tests.ps1, #42 round 2 MAJOR-1):
# this gate has no boundary commit and does no history diff. It walks `git ls-files` at
# HEAD only, so a depth-1 CI checkout is sufficient; there is nothing here for
# `fetch-depth: 0` to fix.
#
# SCOPE, derived from the real corpus at this gate's landing (stated as fact, not
# claimed exhaustive over the future):
#   - SOURCE files scanned (the citing side): tracked files via `git ls-files`,
#     EXCLUDING `artifacts/**` (machine-generated records, historical by design per
#     CLAUDE.md's Tracking section - "Exempt: machine-generated records... is data
#     rather than code" - the same exemption CodeCitationPolicy.Tests.ps1 already
#     applies), `.git/` (not a tracked path, moot), `node_modules/` (gitignored, never
#     tracked, moot), AND EXCLUDING THIS FILE'S OWN PATH (self-exclusion, see the
#     Get-CheckedSourceFiles doc comment below for why - the worked-example prose and
#     scratch-repo test fixtures in this very file necessarily contain coordinate-
#     shaped strings that are not real citations). Extensions checked: .go .js .mjs
#     .css .md .json .ps1 .psm1 .sh .yml .yaml - the brief's floor set exactly.
#     THE CLOSED SET, self-calibrating (#65 round 2, MAJOR-5 - ported from
#     CodeCitationPolicy.Tests.ps1's own closed-set completeness pattern,
#     `scripts/tests/CodeCitationPolicy.Tests.ps1:288-308`): "checked" and "declared
#     exempt" (`$script:DeclaredExemptExtensions`, in the BeforeAll below, one reason
#     per entry) together form the closed set. A dedicated It asserts every extension
#     actually observed in the non-artifacts tracked corpus - INCLUDING THE EMPTY,
#     EXTENSIONLESS CASE - is in checked-union-exempt, red BY NAME (asserting on
#     `.Count`, never a `-join`ed string, per #42 round 3's own lesson) naming any
#     unaccounted extension. `.html` is DECLARED EXEMPT (not silently deferred): probed
#     at landing (`git grep -nE '[A-Za-z0-9_./-]+\.(go|js|md|json|ps1|sh):[0-9]+' --
#     '*.html'`), zero matches across both tracked .html files - exempt now, with a
#     stated revisit trigger (move to $CheckedExtensions the day a real .html citation
#     appears) rather than left as a silent, undeclared gap. `.py` is also DECLARED
#     EXEMPT: the sole tracked .py file (`scripts/canonicalise-demo.py`) is explicitly
#     disclosed PRESERVED WRECKAGE whose own header forbids editing it.
#   - TARGET files (the cited side) are resolved against the FULL tracked-file set,
#     INCLUDING artifacts/**: a doc legitimately cites a landed review verdict under
#     `artifacts/reviews/**` (e.g. this file's own header cites three such verdicts),
#     and that target must be checkable even though it is never a citing SOURCE.
#
# DETECTION - the coordinate shape, after unwrapping:
#   Regex: `(\.?[A-Za-z0-9_][A-Za-z0-9_./-]*\.(?:go|js|mjs|css|md|json|ps1|psm1|sh|yml|yaml)):(\d+)(?:-(\d+))?`
#   The optional leading dot exists for dotdirs (`.claude/agents/car.md`,
#   `.github/workflows/ci.yml`) - probed at landing: two real citations in this corpus
#   ("claude/agents/car.md", "github/workflows/ci.yml") were silently missing their
#   leading dot in the FIRST cut of this regex, which is not a real defect in the docs -
#   it is the regex failing to capture a valid path. Fixed before landing.
#
# UNWRAPPING (Class C), the exact technique measured against this corpus:
#   Comment leaders (`//` or `#` at line start) are stripped per line. A line is joined
#   to the NEXT line - forming a 2-or-3-line sliding window, no separator - ONLY at a
#   genuine WRAP BOUNDARY (`Test-CitationWrapBoundary`): the current (stripped,
#   right-trimmed) line ends in a hyphen immediately preceded by a word character (no
#   space), OR ends in a bare `/`. This precondition is not a guess and was tightened
#   twice against measurement (#65 round 2, MINOR-1 and MINOR-5):
#     - Word-char-before-hyphen (MINOR-5): a bare `.EndsWith('-')` also matches this
#       repo's own prose-dash convention ("word - word", a SPACED separator) - 209
#       corpus lines end that way and are not wraps at all. Requiring the character
#       immediately before the trailing hyphen to be a word character (no space)
#       distinguishes a genuine mid-compound wrap (`dom-` -> `writer.js`) from a prose
#       dash that merely happens to fall at end-of-line.
#     - Slash boundary (MINOR-1): widened to ALSO join across a line ending in a bare
#       `/` (a path broken immediately after a directory separator) - measured FREE
#       against the real corpus: 192 coordinates pre-widening, 188 post- (the drop is
#       from the MAJOR-2/3 citation fixes below removing 4 coordinates entirely, not
#       from this widening), same set, zero new flags in either direction.
#   EVERY genuine Class-C instance found in this corpus at landing satisfies the
#   tightened rule: `board/web/js/dom-` / `docs/design/2026-07-21-v0-` / `docs/retros/
#   2026-07-23-`, all kebab-case filenames wrapped exactly at an existing hyphen
#   preceded by a letter or digit. Naive no-precondition joining measured 8 FALSE
#   dead-path flags on this corpus ("disclosed at" + "poll.go" -> "atpoll.go"; "and" +
#   "schema/index-format.md" -> "andschema/index-format.md"; "mirrors" +
#   "scripts/Produce-Artifact.ps1" -> "mirrorsscripts/Produce-Artifact.ps1") - all
#   eliminated by the hyphen-boundary precondition (the word-char refinement was not
#   yet needed to clear these three, but IS needed to clear the 209 spaced-dash lines,
#   none of which happened to also contain a coordinate-shaped tail). A line whose
#   PREDECESSOR satisfies the wrap-boundary test is also suppressed as a fresh
#   single-line start (a "continuation" line), because scanning it alone re-finds the
#   tail fragment as if it were its own complete citation (e.g. "yard-skeleton-
#   design.md:133" out of "docs/design/2026-07-21-v0-yard-skeleton-design.md:133") -
#   measured 2 further false dead-path flags eliminated by this second guard.
#
# RESOLUTION POLICY (the reason a bare basename is not automatically resolved the same
# way as a full path - probed and decided with evidence, not assumed):
#   - Target CONTAINS a `/`: require an EXACT literal-path match relative to repo root.
#     No basename fallback. This is deliberate: the brief's own CLASS A example -
#     "board/assemble.go" for the real "board/assemble/assemble.go" - is exactly a
#     wrong-directory citation whose BASENAME would still resolve uniquely elsewhere;
#     silently accepting that via basename fallback would make this gate blind to the
#     named defect class it exists to catch. Probed live instance of the same shape at
#     ROUND-1 landing: `docs/design/2026-07-22-dispatch-harness-design.md:97` and
#     `docs/specs/2026-07-22-dispatch-harness-spec.md:109` both cited
#     `docs/reviews/2026-07-22-harness-design-round1-REJECT.md:66` - a path that
#     predates harness #7's migration commit (`git mv docs/reviews -> artifacts/reviews`,
#     history preserved). WHAT WAS ACTUALLY VERIFIED then, stated precisely (#65 round 2,
#     MAJOR-4 - the prior wording overclaimed): the PATH and the git-mv history were true
#     (the file is the same one, content preserved). The LINE was never independently
#     checked and was WRONG - line 66 is blank; the real `### MAJOR-1` heading the
#     citation means is one line below, at `:67`, shifted there by an unrelated, later
#     insertion (`docs/setup.md:42`'s own citation into `docs/templates/repo-policy-
#     check-patterns.md` and `docs/contracts/gating-matrix.md:49`'s citation into
#     `board/server/sse.go` carried the identical unverified-line defect - all THREE
#     found by #65's round-2 reviewer, none by this gate, because an in-range shift is
#     exactly the class this gate does not catch, per WHAT THIS GATE ACTUALLY CATCHES
#     above). FIXED in round 2 by converting all three sites to cite the SYMBOL or
#     HEADING NAME instead of a line number - `writeSSEHeartbeat in board/server/sse.go`,
#     the design/spec rows' "MAJOR-1 finding" by heading, `docs/templates/repo-policy-
#     check-patterns.md`'s "Running them" section by name - which is durable against
#     future line drift and removes the coordinate from this gate's population entirely
#     (a symbol citation is not a `file:line` shape, so there is nothing left for a
#     line-count check to get wrong).
#   - Target has NO `/` (a bare filename): fall back to a basename search across every
#     tracked file (including artifacts/). Exactly one candidate resolves silently
#     (this corpus's dominant style - `constitution.md`, `ci.yml`, `Board.psm1` etc. are
#     all cited bare and unambiguously). Zero candidates is CLASS A dead, by name. TWO
#     OR MORE candidates is genuinely ambiguous and NOT mechanically resolvable either
#     way (measured at landing: `README.md` x4, `state-ledger.md` x2, `gating-matrix.md`
#     x2 tracked files share a basename) - reported by name, never silently dropped and
#     never a hard fail, per the severity philosophy (a wrong guess in either direction
#     is worse than an honest "cannot decide mechanically here"). EXCEPTION, BINDING
#     (#65 round 2, MINOR-4): if the cited line exceeds EVERY candidate's length, that
#     is a real Class-B defect regardless of which candidate was meant, and is reported
#     as out-of-range rather than waved through under cover of ambiguity - measured zero
#     live instances of this at landing (all 13 ambiguous citations are in range for at
#     least one candidate), pinned as a fault-injected scratch-repo case instead.
#
# EXEMPTIONS, both visible and greppable, neither silent, and BOTH still run existence
# and range checks (#65 round 2, MINOR-3 - "exempt" here means exempt from PATH
# PRECISION only, never a free pass on whether the target even exists):
#   - ELLIPSIS ELISION (`.../file.ext:N`): this repo's own established convention for an
#     abbreviated repeat-citation (`board/server/storepath.go:28` IMPLEMENTS this exact
#     truncation in production code: `return ".../" + filepath.Base(absPath)`; docs use
#     it identically, e.g. `.../drill.md:105`). A match whose four preceding characters
#     are literally `.../` is not a dead citation to a file named "drill.md" - it is a
#     deliberately truncated reference to a fuller citation stated nearby. ROUND-1 BUG,
#     FOUND AND FIXED IN ROUND 2 (MINOR-3): round 1 skipped Elided coordinates entirely -
#     "a fabricated `.../never-existed.md:3` passes" was demonstrably true, and even the
#     THREE REAL, TRUE elided citations in this corpus were never actually verified.
#     `Resolve-CitationTarget`'s exact-basename-equality lookup cannot fix this either:
#     the live token, "drill.md", is a SUFFIX of the real basename ("2026-07-22-car2-
#     plan-review-round2-drill.md"), never a basename in its own right, so routing it
#     through the ordinary resolver still misses (measured: 3/3 false dead-path flags
#     the first time this was tried). `Resolve-ElidedCitationTarget` instead matches by
#     SUFFIX across every tracked file's basename or full path, unique-match, then runs
#     the same existence+range checks as everything else. Exempted, counted, reported by
#     name - never silently invisible, and no longer silently unchecked either.
#   - HISTORICAL COORDINATE marker: a citing line (or any line spanned by a wrapped
#     match) containing the literal, case-insensitive substring "historical
#     coordinate" is exempt from the existence/range checks. Real instance fixed at
#     this gate's landing: `.claude/hooks/run-session-start-guards.sh` cites
#     "session-start-record.sh:76", a script the SAME COMMENT already discloses as
#     "the now-deleted delivery script" - a genuinely historical citation to a file
#     that no longer exists, by design, not by drift. Marked explicitly with this
#     opt-out phrase in the same commit that adds this gate, rather than silently
#     re-flagged forever or silently allowlisted with no visible marker.
#
# CHECKS, escalating value, per the brief:
#   (a) BINDING - cited file exists at HEAD (Class A).
#   (b) BINDING - cited line (or the larger end of a range) is within the target
#       file's line count (Class B floor - catches a shifted-below-EOF citation).
#       NOTE: line counting is `@(Get-Content -Path $p -Encoding UTF8).Count`, never
#       `Get-Content | Measure-Object -Line` - probed at landing:
#       `board/fold/algorithm.go` has 266 lines by `.Count` and by `wc -l`, but
#       `Measure-Object -Line` on the same piped array reported 239 (it counts newline
#       characters within each already-split string element, not the number of
#       elements - unreliable for an array Get-Content already split by line). Using
#       the wrong method would have produced 1 false Class-B flag at landing
#       (`algorithm.go:240`, genuinely in range) and silently corrupted every other
#       range check in this file. Caught by probing before trusting the API, not by
#       reading its name.
#   (c) REPORT-ONLY, NOT BINDING - content anchor: does a backtick-quoted identifier
#       token from the citing line appear within +/-15 lines of the cited target line?
#       CASE-SENSITIVE match (`-cmatch`, #65 round 2, MINOR-2 - the prior `-match` is
#       case-INSENSITIVE by default and would false-HIT a PascalCase token like
#       `StalenessMs` against unrelated lowercase prose that merely contains the same
#       letters differently cased; identifier tokens are case-sensitive by nature, and
#       this repo's own corpus carries the near-collision live - `board/server/
#       config.go:56`'s doc comment says "stalenessMs 15000" in lowercase prose, one
#       line above the field `StalenessMs` a DIFFERENT citation quotes by symbol).
#
#       THE MEASURED TRUTH, stated plainly because round 1 got this backwards (round
#       1's text called both round-1 misses "neither confirmed a real defect" - FALSE,
#       and the exact error this whole gate exists to stop repeating): at round-1
#       landing, this diagnostic scored 2 FOR 2 in the LIVE round-1 corpus - its only
#       two misses, `board/server/sse.go:77` (cited from `docs/contracts/gating-
#       matrix.md:49`) and `artifacts/reviews/2026-07-22-harness-design-round1-
#       REJECT.md:66` (cited from `docs/design/2026-07-22-dispatch-harness-design.md:97`),
#       were BOTH real, confirmed Class-B in-range shifts - the exact class every
#       BINDING check in this file (a) and (b) is disclosed as unable to catch.
#
#       THE THIRD, HISTORICAL POINT (#65 round 3, MAJOR-R2-1 - added because round 2's
#       "zero backtick tokens on their citing lines" claim about the view train's THREE
#       named findings was itself unmeasured and wrong for one): had this diagnostic
#       existed at commit `3076a40`, it would ALSO have flagged the view train's
#       MAJOR-2 (`config.go:42`, cited with a `` `StalenessMs` `` backtick token from
#       `docs/design/2026-07-21-v0-yard-skeleton-design.md:611`) - measured miss under
#       `-cmatch` (the real `StalenessMs` occurrences sit at config.go `:14` and `:63`,
#       both outside the +/-15 window `:42` sits in), reproduced as a fixture below.
#       That makes the FULL historical record 3-FOR-3 true positives across every
#       citation this gate's own header ever named, not 2-for-2 - this diagnostic,
#       unbound and unread the whole time, silently carried the answer to every one of
#       the view train's citation Majors from the start.
#
#       THE ARGUMENT FOR STAYING REPORT-ONLY, made WITH that full record rather than
#       around it: a 3-for-3 true-positive rate (all historical, none of the three
#       still live as coordinates today - each was fixed by a different process before
#       this gate could bind on it) is real signal, not proof of a safe FALSE-positive
#       rate. Re-measured on the CURRENT corpus (all three historical misses long since
#       retargeted to symbol/heading citations, which removes them from this check's
#       population rather than fixing them to a hit - see RESOLUTION POLICY above): of
#       the resolvable literal-path citations, 6 carry a backtick-quoted token on the
#       citing line at all; all 6 hit, 0 miss. That leaves ZERO CURRENT miss examples in
#       this corpus's PRESENT state to check against the other failure mode - a
#       citation that is GENUINELY CORRECT but whose citing prose simply does not
#       repeat an identical token near the target (a paraphrase, a synonym, a
#       renamed-but-still-correct reference). This gate has never observed THAT case
#       even once, so binding now would mean the FIRST miss this check produces
#       post-binding on a FUTURE citation is an untested, potentially wolf-crying CI
#       failure - the exact instrument-quality risk the severity philosophy warns
#       against, from the opposite direction of round 1's dismissiveness. Kept
#       REPORT-ONLY, with an explicit, numeric revisit trigger rather than an open-ended
#       "someday": bind it the next time EITHER (i) the tokened-citation population
#       (n) grows past 20, giving enough data to also estimate a false-positive rate, OR
#       (ii) a report-only miss is manually confirmed NOT to be a defect (establishing,
#       for the first time, what this check's false-positive actually looks like) - the
#       3-for-3 record answers "does it find true positives," never "how often is it
#       wrong," which is the only question standing between here and binding it.
#       Matches this repo's own prior-art guidance verbatim (`docs/templates/repo-
#       policy-check-patterns.md` SS3: "line numbers drift on every edit above them -
#       the cheap tier ... avoids crying wolf; the expensive tier needs content-
#       anchoring ... before it can be strict without being noisy"). Landed as a
#       measured, clearly-labeled, PROMOTED diagnostic (Skipped-with-Because, never a
#       hard fail YET) - proven valuable, not yet safe to bind, both true at once.
#
# RED BY NAME: every failing check lists the citing file, the citing line (or line
# range for a wrapped citation), the dead/out-of-range coordinate, and which check
# failed - never an aggregate boolean.
#
# CALIBRATION AT LANDING (measured at this gate's own HEAD, numbers are fact, not a
# claim of future exhaustiveness). ROUND 1 then ROUND 2, both stated - the delta is
# itself evidence, not noise to collapse away:
#   Source files scanned (checked extensions, excluding artifacts/, excluding this
#     file): 258 (unchanged - this file's own extension is already counted in the
#     corpus at the EXTENSION level; only this one FILE is self-excluded).
#   Coordinate matches found (deduped, post-unwrap, post-continuation-suppression):
#     round 1: 192. Round 2: 188. The drop of 4 is NOT the unwrap-boundary widening
#     (measured free, see UNWRAPPING above) - it is the three round-2 citation fixes
#     that converted a `file:line` coordinate into a symbol/heading citation with no
#     line number at all (MAJOR-2's `docs/setup.md:42`, MAJOR-3a's `docs/contracts/
#     gating-matrix.md:49`, and MAJOR-3b/MAJOR-4's shared target cited from BOTH
#     `docs/design/2026-07-22-dispatch-harness-design.md:97` and `docs/specs/2026-07-
#     22-dispatch-harness-spec.md:109` - 1+1+2 = 4 coordinates removed from the
#     population, never fixed to a passing coordinate).
#   Wrapped (required a >1-line window to resolve): 2, unchanged both rounds - both
#     genuine Class-C instances already present in this repo's real history, both TRUE
#     once unwrapped: `board/web/test/sse-protocol.test.js:8-9` -> `docs/design/2026-
#     07-21-v0-yard-skeleton-design.md:133`; `docs/design/2026-07-21-v0-yard-skeleton-
#     design.md:585-586` -> `docs/retros/2026-07-23-board-train-retro.md:120-121`.
#   Elided (ellipsis convention): 3, all `.../drill.md:1xx` in
#     docs/templates/design-briefs.md and docs/templates/worked-adversary-and-gate-
#     briefs.md, all resolving BY SUFFIX (#65 round 2, MINOR-3 - `Resolve-
#     ElidedCitationTarget`, never the exact-basename lookup) to `artifacts/reviews/
#     2026-07-22-car2-plan-review-round2-drill.md` - 137 lines by this gate's own
#     mandated method (`@(Get-Content -Path $p -Encoding UTF8).Count`, #65 round 2
#     MINOR-R2-1 - `wc -l` reports 136, undercounting by one because the file's last
#     line carries no trailing newline and `wc -l` counts newline characters, not
#     lines; the same class of discrepancy CHECK (b) already disclosed for
#     `Measure-Object -Line`, this time in a plain narrated number rather than in the
#     resolver's own code) - both cited lines (105, 110) in range either way.
#   Historical-marker exempt: 1 (the session-start-record.sh:76 fix landed at round-1
#     landing).
#   Ambiguous bare-basename (ratio, never silently resolved): 13, unchanged - none of
#     the 13 hit the round-2 all-candidates-out-of-range bind (MINOR-4); that case is
#     pinned only as a fault-injected scratch-repo fixture, with zero live instances.
#   TRUE DEFECTS FOUND AND FIXED, round 1 (2, both CLASS A, both the docs/reviews/ ->
#     artifacts/reviews/ migration-shadow): `docs/design/2026-07-22-dispatch-harness-
#     design.md:97`, `docs/specs/2026-07-22-dispatch-harness-spec.md:109` (line 66,
#     retargeted to the new path - ROUND 1 VERIFIED ONLY THE PATH, NOT THE LINE, WHICH
#     WAS ALSO WRONG; see round 2's fix below).
#   TRUE DEFECTS FOUND AND FIXED, round 2 (3, all CLASS B in-range shifts - the class
#     this gate's BINDING checks cannot see, found only by #65's round-2 reviewer
#     opening the files): `docs/setup.md:42` (`repo-policy-check-patterns.md:57` -> the
#     heading is now at line 76, retargeted to cite the section BY NAME instead);
#     `docs/contracts/gating-matrix.md:49` (`board/server/sse.go:75-77` -> the real
#     `writeSSEHeartbeat` function is at `:96-101`, retargeted to cite the symbol
#     instead); `docs/design/2026-07-22-dispatch-harness-design.md:97` AND
#     `docs/specs/2026-07-22-dispatch-harness-spec.md:109` (both cited `artifacts/
#     reviews/2026-07-22-harness-design-round1-REJECT.md:66` - blank; the real
#     `### MAJOR-1` heading is at `:67` - retargeted BOTH sites to cite the finding by
#     heading, one fix covering two citing sites since they share a target).
#   Zero-false-flag bar: after all round-1 AND round-2 fixes, this gate is GREEN
#     against the real corpus (0 Class A, 0 Class B remaining; ambiguous, elided, and
#     content-anchor buckets all reported non-failing per their stated, argued reasons
#     above, never silently).
#
# The three-item CALIBRATION INPUT from issue #65's own comment thread
# (docs/design/2026-07-22-dispatch-harness-design.md:53, docs/templates/design-doc.md:204,
# docs/templates/worked-spec.md:94, all citing "gating-matrix.md:23") was RE-VERIFIED,
# not blindly fixed: all three are bare basenames resolving (ambiguously, per the
# closed-set above - `docs/templates/gating-matrix.md` AND `docs/contracts/gating-
# matrix.md` both exist) to the TEMPLATE file, whose real line 23 IS the "Example:
# staleness banner" row quoting "never (truth surface)" / "DELIBERATE, no override"
# verbatim - confirmed true, not dead. `docs/templates/worked-spec.md:94` itself says
# so explicitly ("this project's own gating-matrix TEMPLATE already carries"). The
# owner's comment's premise (the row "now sits elsewhere") does not hold for the
# template file it is actually citing; it holds only for `docs/contracts/gating-
# matrix.md`, a DIFFERENT file sharing the same basename, which none of the three
# citations name explicitly. This is disclosed here rather than "fixed": there is
# nothing wrong to fix, and the real, useful finding is that "gating-matrix.md" is a
# genuinely ambiguous bare citation this gate now surfaces every run (the ambiguous
# bucket above), which is the honest, mechanical version of the owner's manual catch.

BeforeAll {
    $script:CheckedExtensions = @('.go', '.js', '.mjs', '.css', '.md', '.json', '.ps1', '.psm1', '.sh', '.yml', '.yaml')
    # The closed set's other half (#65 round 2, MAJOR-5 - ported from CodeCitationPolicy.
    # Tests.ps1's own closed-set discipline): every extension seen in the non-artifacts
    # tracked corpus that is NOT in $CheckedExtensions must be declared here, with a
    # reason, or the completeness It below reds BY NAME. Probed at round-2 landing
    # (`git ls-files | grep -v '^artifacts/' | sed -n 's/.*\.\([A-Za-z0-9]*\)$/\1/p' |
    # sort | uniq -c`): .expect(12) .png(6) .gitignore(3) .html(2) .sum(1) .py(1) .mod(1)
    # .jsonl(1) .gitattributes(1), plus one extensionless file (LICENSE).
    $script:DeclaredExemptExtensions = [ordered]@{
        '.expect'        = 'schema/vectors/**/*.expect fixture files - comment-incapable without mutating the artifact under test (CLAUDE.md''s own citation-standard exemption for these exact files, ported here)'
        '.png'           = 'binary image (screenshots/diagrams), no comment syntax - same reasoning family CodeCitationPolicy.Tests.ps1 already applies to .png'
        '.jsonl'         = 'scripts/tests/fixtures/payloads/*.jsonl - test-fixture transcript data, same mutation-risk reasoning as .expect'
        '.gitignore'     = 'git configuration data; probed - zero coordinate-shaped matches across all 3 tracked .gitignore files'
        '.gitattributes' = 'git configuration data; probed - zero coordinate-shaped matches despite rich prose comments explaining line-ending policy'
        '.sum'           = 'go.sum - auto-generated Go module checksum lockfile, machine-written, no citations possible'
        '.mod'           = 'go.mod - Go module manifest; probed, no citation-shaped content'
        '.py'            = 'the sole tracked .py file (scripts/canonicalise-demo.py) is explicitly-disclosed PRESERVED WRECKAGE whose own header forbids editing it ("do not... fix the forgery - repairing it would destroy the fossil"); probed, no citation-shaped content regardless (#65 round 2, MAJOR-5)'
        '.html'          = 'probed at landing - zero coordinate-shaped citations in either tracked .html file; declared exempt rather than checked to avoid gating on a currently-empty case; revisit (move to $CheckedExtensions) the day a real .html file:line citation appears (#65 round 2, MAJOR-5)'
        ''               = 'the sole extensionless tracked file at landing is LICENSE; probed, no citation-shaped content (license text, not code or docs that cite line numbers). NARROWED to LICENSE specifically, not "any future extensionless file" (#65 round 3, MINOR-R2-2): see $script:DeclaredExemptExtensionlessFiles below - a NEW extensionless file (a Dockerfile, a shebang script) is not silently covered by this reason just because it shares the empty-string extension.'
    }
    # #65 round 3, MINOR-R2-2: the bare '' extension key above covers the EXTENSION-LEVEL
    # completeness check (Get-UnaccountedExtensions), but "extensionless" is not one
    # reason - LICENSE is exempt because it is license text with no citations; a FUTURE
    # extensionless file (a Dockerfile, a shebang script) would share the extension but
    # not the reason. This allowlist is checked separately, by PATH, in its own It below.
    $script:DeclaredExemptExtensionlessFiles = @('LICENSE')
    $script:ExtRe   = ($script:CheckedExtensions -replace '^\.', '') -join '|'
    $script:CoordRe = "(\.?[A-Za-z0-9_][A-Za-z0-9_./-]*\.(?:$($script:ExtRe))):(\d+)(?:-(\d+))?"
    $script:CommentLeaderRe = '^\s*(//|#)\s?'

    function Get-AllNonArtifactFiles {
        param([Parameter(Mandatory)][string] $RepoRoot)
        $all = git -C $RepoRoot ls-files
        if (-not $all) { return @() }
        return @($all | Where-Object { $_ -notmatch '^artifacts/' })
    }

    function Get-UnaccountedExtensions {
        # #65 round 2 MAJOR-5, porting CodeCitationPolicy.Tests.ps1's own #42-round-3
        # lesson: the caller MUST assert on `.Count`, never on a `-join`ed string - an
        # unaccounted EXTENSIONLESS entry is the empty string '', and joining a single
        # empty string with anything still produces '', which `-BeNullOrEmpty` would
        # then wrongly pass. This function only computes the set; the It below asserts
        # on Count.
        param([string[]] $ObservedExtensions, [string[]] $CoveredExtensions)
        return @($ObservedExtensions | Where-Object { $CoveredExtensions -notcontains $_ })
    }

    function Get-DeclaredExemptFiles {
        # #65 round 3, MINOR-R2-2: the completeness It only catches a NEW extension
        # arriving - it never re-checks that an ALREADY-declared-exempt extension is
        # still, in fact, citation-free (a .py or .html file that later acquires a real
        # citation would be silently invisible forever, since its extension is already
        # "accounted for"). This returns every non-artifacts tracked file whose
        # extension is in the declared-exempt set, for the standing re-verification It.
        param(
            [Parameter(Mandatory)][string] $RepoRoot,
            # NOT Mandatory (#42 round 3's own lesson, repeated here): PowerShell's
            # Mandatory attribute rejects an empty-string ELEMENT inside a [string[]]
            # argument, and '' (the extensionless case) is exactly one of the values
            # this closed set carries. Every call site still always passes it.
            [string[]]                      $DeclaredExemptExtensions
        )
        $all = @(Get-AllNonArtifactFiles -RepoRoot $RepoRoot)
        return @($all | Where-Object { $DeclaredExemptExtensions -contains [System.IO.Path]::GetExtension($_) })
    }

    function Get-CheckedSourceFiles {
        # SELF-EXCLUSION, disclosed rather than solved (same class CodeCitationPolicy.
        # Tests.ps1 already discloses for its own "#123456" hex-collision example):
        # this gate's own source file necessarily reproduces coordinate-SHAPED strings
        # that are not real citations - worked-example prose describing a fixed dead
        # citation (e.g. quoting the exact stale "docs/reviews/...:66" path this commit
        # retargeted, for the reader's benefit) and, more heavily, the scratch-repo
        # fixture Describe block below, whose fixture FILE CONTENT must literally
        # contain `target.go:5`-shaped strings for the mechanism it is testing to have
        # anything to find. Scanning this file against itself would flag both as Class A
        # dead paths (the targets - "target.go", "nonexistent-file.go" etc. - exist only
        # inside an ephemeral scratch git repo, never in this one). Measured at landing:
        # excluding this one file is the only change needed; every other tracked file's
        # citations are still fully checked, including the ones THIS file's own header
        # narrates (docs/design/.../:97, board/server/storepath.go:28, etc.) - excluding
        # this file only stops it from checking ITS OWN prose, not from being cited BY
        # other files (none currently do).
        param([Parameter(Mandatory)][string] $RepoRoot)
        $all = git -C $RepoRoot ls-files
        if (-not $all) { return @() }
        return @($all |
            Where-Object { $_ -notmatch '^artifacts/' } |
            Where-Object { $_ -ne 'scripts/tests/CitationResolverPolicy.Tests.ps1' } |
            Where-Object { $script:CheckedExtensions -contains [System.IO.Path]::GetExtension($_) })
    }

    function Get-BasenameMap {
        # TARGET resolution deliberately covers the FULL tracked set, artifacts/
        # included - a doc outside artifacts/ legitimately cites a landed verdict
        # inside it (see header SCOPE note).
        param([Parameter(Mandatory)][string] $RepoRoot)
        $map = @{}
        foreach ($f in (git -C $RepoRoot ls-files)) {
            $bn = [System.IO.Path]::GetFileName($f)
            if (-not $map.ContainsKey($bn)) { $map[$bn] = New-Object System.Collections.Generic.List[string] }
            $map[$bn].Add($f)
        }
        return $map
    }

    function Resolve-ElidedCitationTarget {
        # #65 round 2, MINOR-3. The ellipsis convention (".../file.ext:N") truncates to
        # whatever suffix the AUTHOR chose, not necessarily a real file's exact basename
        # - the live corpus instance is ".../drill.md", a suffix of the real basename
        # "2026-07-22-car2-plan-review-round2-drill.md", never a basename in its own
        # right. Resolve-CitationTarget's EXACT basename-equality lookup therefore always
        # misses it (measured: routing Elided coordinates through it flagged 3/3 live
        # elided citations dead, a false positive on every instance in this corpus).
        # This resolves by SUFFIX instead: any tracked file (basename OR full relative
        # path) ending in the elided token. Exempts only path precision, same as every
        # other basename-style resolution - existence and range are still checked on
        # whatever it uniquely matches.
        param(
            [Parameter(Mandatory)][string] $RepoRoot,
            [Parameter(Mandatory)]         $Coordinate,
            [Parameter(Mandatory)][string[]] $AllTrackedFiles
        )
        $checkLine = if ($Coordinate.TargetLine2) { $Coordinate.TargetLine2 } else { $Coordinate.TargetLine }
        $suffix = $Coordinate.Target
        $candidates = @($AllTrackedFiles | Where-Object {
            [System.IO.Path]::GetFileName($_).EndsWith($suffix) -or $_.EndsWith($suffix)
        })
        if ($candidates.Count -eq 0) {
            return [pscustomobject]@{ Status = 'dead'; ResolvedPath = $null }
        }
        if ($candidates.Count -gt 1) {
            $anyInRange = $false
            foreach ($cand in $candidates) {
                $candLines = @(Get-Content -Path (Join-Path $RepoRoot $cand) -Encoding UTF8).Count
                if ($checkLine -le $candLines) { $anyInRange = $true; break }
            }
            if (-not $anyInRange) {
                return [pscustomobject]@{ Status = 'out-of-range'; ResolvedPath = ($candidates -join ', ') }
            }
            return [pscustomobject]@{ Status = 'ambiguous'; ResolvedPath = ($candidates -join ', ') }
        }
        $full = Join-Path $RepoRoot $candidates[0]
        $tlines = @(Get-Content -Path $full -Encoding UTF8).Count
        if ($checkLine -gt $tlines) {
            return [pscustomobject]@{ Status = 'out-of-range'; ResolvedPath = $candidates[0] }
        }
        return [pscustomobject]@{ Status = 'ok'; ResolvedPath = $candidates[0] }
    }

    function Strip-CitationCommentLeader {
        param([string] $Line)
        return [regex]::Replace($Line, $script:CommentLeaderRe, '')
    }

    function Test-CitationWrapBoundary {
        # #65 round 2, MINOR-1 + MINOR-5. The join precondition, tightened twice against
        # measurement:
        #   MINOR-5: a bare `.EndsWith('-')` also matches this repo's own prose dash
        #   convention ("word - word", a spaced separator, NOT a wrapped compound name) -
        #   209 corpus lines end that way. Requiring a WORD CHARACTER immediately before
        #   the trailing hyphen (no space between) distinguishes a genuine mid-compound
        #   wrap ("dom-" -> "writer.js") from a prose dash ("...the fix - and this")
        #   whose trailing "-" only appears at end-of-line by coincidence of where the
        #   line was cut. Regex `[A-Za-z0-9_]-$` on the trimmed line.
        #   MINOR-1: widened to ALSO join across a line ending in a bare `/` (a path
        #   broken immediately after a directory separator) - measured free against the
        #   real corpus: 192 coordinates, identical set, zero new flags either direction.
        param([string] $TrimmedLine)
        return ($TrimmedLine -match '[A-Za-z0-9_]-$') -or $TrimmedLine.EndsWith('/')
    }

    function Find-CitationCoordinates {
        # Scans $SourceFiles for file:line coordinates, unwrapping a line onto the
        # next ONLY when the current (stripped, right-trimmed) line ends at a genuine
        # wrap boundary (Test-CitationWrapBoundary - a mid-compound hyphen or a bare
        # trailing slash, never a spaced prose dash) - see header UNWRAPPING note for
        # why this precondition exists and what it measurably prevents. Returns one
        # object per distinct coordinate: CitingFile, StartLine, EndLine, Target,
        # TargetLine, TargetLine2, Elided.
        param(
            [Parameter(Mandatory)][string]   $RepoRoot,
            [Parameter(Mandatory)][string[]] $SourceFiles,
            [int]                             $MaxWindow = 3
        )
        $found = @()
        $seen  = @{}
        foreach ($rel in $SourceFiles) {
            $full = Join-Path $RepoRoot $rel
            if (-not (Test-Path $full -PathType Leaf)) { continue }
            $lines = @(Get-Content -Path $full -Encoding UTF8)
            for ($i = 0; $i -lt $lines.Count; $i++) {
                $isContinuation = ($i -gt 0) -and (Test-CitationWrapBoundary ((Strip-CitationCommentLeader $lines[$i - 1]).TrimEnd()))
                $joined = ''
                for ($w = 0; $w -lt $MaxWindow -and ($i + $w) -lt $lines.Count; $w++) {
                    if ($w -gt 0) {
                        $prevStripped = (Strip-CitationCommentLeader $lines[$i + $w - 1]).TrimEnd()
                        if (-not (Test-CitationWrapBoundary $prevStripped)) { break }
                    }
                    $joined  += (Strip-CitationCommentLeader $lines[$i + $w])
                    $endLine  = $i + $w + 1
                    foreach ($m in [regex]::Matches($joined, $script:CoordRe)) {
                        if ($w -eq 0 -and $isContinuation -and $m.Index -eq 0) { continue }
                        $target = $m.Groups[1].Value
                        $tline  = [int]$m.Groups[2].Value
                        $tline2 = if ($m.Groups[3].Success) { [int]$m.Groups[3].Value } else { $null }
                        $key = "$rel|$($i+1)|$target|$tline|$tline2"
                        if ($seen.ContainsKey($key)) { continue }
                        $isElided = $false
                        $startIdx = $m.Index
                        if ($startIdx -ge 4 -and $joined.Substring($startIdx - 4, 4) -eq '.../') { $isElided = $true }
                        $seen[$key] = $true
                        $found += [pscustomobject]@{
                            CitingFile  = $rel
                            StartLine   = $i + 1
                            EndLine     = $endLine
                            Target      = $target
                            TargetLine  = $tline
                            TargetLine2 = $tline2
                            Elided      = $isElided
                        }
                    }
                }
            }
        }
        return @($found)
    }

    function Get-ContentAnchorTokens {
        # #65 round 3, MAJOR-R2-1: extracted so the SAME token-extraction logic backs
        # both the real-corpus diagnostic and the fixture that pins the historical
        # 3-for-3 true-positive record, rather than that record living only in prose.
        param([Parameter(Mandatory)][string] $Line)
        $backtickRe = '`([A-Za-z_][A-Za-z0-9_]{2,})`'
        return @([regex]::Matches($Line, $backtickRe) | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    }

    function Test-ContentAnchorWindow {
        # Returns $true if ANY token appears (verbatim) in $WindowText. -CaseSensitive
        # selects `-cmatch` (this gate's production choice, #65 round 2 MINOR-2) versus
        # plain `-match` (round 1's, case-insensitive - kept here ONLY so the historical
        # false-hit/true-miss pair can be reproduced and compared, never used in the
        # production resolution path).
        param(
            [Parameter(Mandatory)][string[]] $Tokens,
            [Parameter(Mandatory)][string]   $WindowText,
            [switch]                          $CaseSensitive
        )
        foreach ($tok in $Tokens) {
            if ($CaseSensitive) {
                if ($WindowText -cmatch [regex]::Escape($tok)) { return $true }
            } else {
                if ($WindowText -match [regex]::Escape($tok)) { return $true }
            }
        }
        return $false
    }

    function Test-HistoricalCoordinateMarker {
        param(
            [Parameter(Mandatory)][string] $RepoRoot,
            [Parameter(Mandatory)]         $Coordinate
        )
        $full  = Join-Path $RepoRoot $Coordinate.CitingFile
        $lines = @(Get-Content -Path $full -Encoding UTF8)
        $lo = [Math]::Max(0, $Coordinate.StartLine - 1)
        $hi = [Math]::Min($lines.Count - 1, $Coordinate.EndLine - 1)
        $text = ($lines[$lo..$hi] -join ' ')
        return [bool]($text -match '(?i)historical coordinate')
    }

    function Resolve-CitationTarget {
        # Returns [pscustomobject]@{ Status; ResolvedPath } where Status is one of:
        # 'ok', 'dead', 'out-of-range', 'ambiguous'.
        param(
            [Parameter(Mandatory)][string] $RepoRoot,
            [Parameter(Mandatory)]         $Coordinate,
            [Parameter(Mandatory)]         $BasenameMap
        )
        $checkLine = if ($Coordinate.TargetLine2) { $Coordinate.TargetLine2 } else { $Coordinate.TargetLine }
        if ($Coordinate.Target.Contains('/')) {
            $full = Join-Path $RepoRoot $Coordinate.Target
            if (-not (Test-Path $full -PathType Leaf)) {
                return [pscustomobject]@{ Status = 'dead'; ResolvedPath = $null }
            }
            $tlines = @(Get-Content -Path $full -Encoding UTF8).Count
            if ($checkLine -gt $tlines) {
                return [pscustomobject]@{ Status = 'out-of-range'; ResolvedPath = $Coordinate.Target }
            }
            return [pscustomobject]@{ Status = 'ok'; ResolvedPath = $Coordinate.Target }
        }
        $bn = $Coordinate.Target
        if (-not $BasenameMap.ContainsKey($bn)) {
            return [pscustomobject]@{ Status = 'dead'; ResolvedPath = $null }
        }
        $candidates = $BasenameMap[$bn]
        if ($candidates.Count -gt 1) {
            # #65 round 2, MINOR-4: ambiguity over WHICH file is meant is not the same
            # question as whether the cited line is even plausible. If the line exceeds
            # EVERY candidate's length, that is a real defect regardless of which file
            # was intended - bind that case instead of waving it through under cover of
            # "cannot be mechanically disambiguated." Only genuinely-plausible ambiguity
            # (in range for at least one candidate) stays report-only.
            $anyInRange = $false
            foreach ($cand in $candidates) {
                $candFull  = Join-Path $RepoRoot $cand
                $candLines = @(Get-Content -Path $candFull -Encoding UTF8).Count
                if ($checkLine -le $candLines) { $anyInRange = $true; break }
            }
            if (-not $anyInRange) {
                return [pscustomobject]@{ Status = 'out-of-range'; ResolvedPath = ($candidates -join ', ') }
            }
            return [pscustomobject]@{ Status = 'ambiguous'; ResolvedPath = ($candidates -join ', ') }
        }
        $full = Join-Path $RepoRoot $candidates[0]
        $tlines = @(Get-Content -Path $full -Encoding UTF8).Count
        if ($checkLine -gt $tlines) {
            return [pscustomobject]@{ Status = 'out-of-range'; ResolvedPath = $candidates[0] }
        }
        return [pscustomobject]@{ Status = 'ok'; ResolvedPath = $candidates[0] }
    }
}

Describe 'Citation resolver: every file:line coordinate outside artifacts/ resolves (#65)' {

    BeforeAll {
        $script:RepoRoot         = (git rev-parse --show-toplevel)
        $script:SourceFiles      = @(Get-CheckedSourceFiles -RepoRoot $script:RepoRoot)
        $script:AllNonArtifact   = @(Get-AllNonArtifactFiles -RepoRoot $script:RepoRoot)
        $script:AllTrackedFiles  = @(git -C $script:RepoRoot ls-files)
        $script:BasenameMap      = Get-BasenameMap -RepoRoot $script:RepoRoot
        $script:Coordinates      = @(Find-CitationCoordinates -RepoRoot $script:RepoRoot -SourceFiles $script:SourceFiles)

        $script:DeadPath   = @()
        $script:OutOfRange = @()
        $script:Ambiguous  = @()
        $script:Elided     = @()
        $script:Historical = @()
        $script:Ok         = @()

        foreach ($c in $script:Coordinates) {
            if (Test-HistoricalCoordinateMarker -RepoRoot $script:RepoRoot -Coordinate $c) {
                $script:Historical += $c; continue
            }
            # #65 round 2, MINOR-3: the ellipsis valve exempts only PATH PRECISION, never
            # existence or range. But the elided token is a SUFFIX the author chose, not
            # necessarily a real file's exact basename (the live corpus case, ".../
            # drill.md", is a suffix of "...round2-drill.md", never a basename in its own
            # right) - Resolve-CitationTarget's exact-basename lookup always misses it, so
            # Elided coordinates resolve via Resolve-ElidedCitationTarget's suffix match
            # instead, never silently skipped.
            if ($c.Elided) {
                $script:Elided += $c
                $r = Resolve-ElidedCitationTarget -RepoRoot $script:RepoRoot -Coordinate $c -AllTrackedFiles $script:AllTrackedFiles
            } else {
                $r = Resolve-CitationTarget -RepoRoot $script:RepoRoot -Coordinate $c -BasenameMap $script:BasenameMap
            }
            switch ($r.Status) {
                'dead'         { $script:DeadPath   += $c }
                'out-of-range' { $script:OutOfRange += $c }
                'ambiguous'    { $script:Ambiguous   += $c }
                'ok'           { $script:Ok          += $c }
            }
        }
    }

    It 'finds coordinates to check (a check that examines nothing is not a pass)' {
        $script:Coordinates.Count | Should -BeGreaterThan 0
    }

    It 'every extension in the non-artifacts corpus, INCLUDING extensionless, is checked or a declared exemption (#65 round 2, MAJOR-5, the closed-set completeness pattern ported from CodeCitationPolicy.Tests.ps1:288-308)' {
        $observedExtensions = @($script:AllNonArtifact |
            ForEach-Object { [System.IO.Path]::GetExtension($_) } |
            Sort-Object -Unique)
        $covered = @($script:CheckedExtensions) + @($script:DeclaredExemptExtensions.Keys)
        $unaccounted = @(Get-UnaccountedExtensions -ObservedExtensions $observedExtensions -CoveredExtensions $covered)
        # #42 round 3's own lesson, ported verbatim: assert on `.Count`, never on a
        # `-join`ed string - a single unaccounted extensionless entry is the empty
        # string '', and joining it with anything is still '', which -BeNullOrEmpty
        # would wrongly pass.
        $rendered = @($unaccounted | ForEach-Object { if ($_ -eq '') { '(no extension)' } else { $_ } })
        $unaccounted.Count | Should -Be 0 -Because (
            "extension(s) [$($rendered -join ', ')] appeared in the non-artifacts corpus " +
            "with no citation check and no declared exemption - decide: extend " +
            "`$CheckedExtensions or `$DeclaredExemptExtensions, do not leave it silent")
    }

    It 'every DECLARED-EXEMPT extension is re-verified, standing, to still carry zero coordinate-shaped matches (#65 round 3, MINOR-R2-2 - the completeness test above only catches a NEW extension arriving, never a declared-exempt one silently acquiring a citation)' {
        $exemptFiles = @(Get-DeclaredExemptFiles -RepoRoot $script:RepoRoot -DeclaredExemptExtensions @($script:DeclaredExemptExtensions.Keys))
        $violators = @()
        foreach ($f in $exemptFiles) {
            $full = Join-Path $script:RepoRoot $f
            if (-not (Test-Path $full -PathType Leaf)) { continue }
            $text = Get-Content -Path $full -Raw -Encoding UTF8
            if ([regex]::IsMatch($text, $script:CoordRe)) {
                $violators += "$f (extension $([System.IO.Path]::GetExtension($f))) now carries a coordinate-shaped match - re-evaluate its exemption"
            }
        }
        ($violators -join "`n") | Should -BeNullOrEmpty
    }

    It 'the extensionless exemption is scoped to its declared allowlist (LICENSE), not to "any extensionless file" (#65 round 3, MINOR-R2-2)' {
        $observedExtensionless = @($script:AllNonArtifact | Where-Object { [System.IO.Path]::GetExtension($_) -eq '' })
        $unaccounted = @($observedExtensionless | Where-Object { $script:DeclaredExemptExtensionlessFiles -notcontains $_ })
        $unaccounted.Count | Should -Be 0 -Because (
            "extensionless file(s) [$($unaccounted -join ', ')] are not in the declared " +
            "allowlist (`$script:DeclaredExemptExtensionlessFiles = LICENSE only) - a new " +
            "extensionless file shares the '' extension but not LICENSE's exemption reason; " +
            "decide and add it explicitly, do not let it ride LICENSE's coattails")
    }

    It 'every literal-path or uniquely-resolved-basename citation points at a file that exists at HEAD (Class A)' {
        $violators = @($script:DeadPath | ForEach-Object {
            "$($_.CitingFile):$($_.StartLine)$(if ($_.EndLine -ne $_.StartLine) { "-$($_.EndLine)" }) cites '$($_.Target):$($_.TargetLine)$(if ($_.TargetLine2) { "-$($_.TargetLine2)" })' - NO SUCH FILE"
        })
        ($violators -join "`n") | Should -BeNullOrEmpty
    }

    It 'every resolved citation''s line (or range end) is within the target file''s line count (Class B floor)' {
        $violators = @($script:OutOfRange | ForEach-Object {
            $checkLine = if ($_.TargetLine2) { $_.TargetLine2 } else { $_.TargetLine }
            "$($_.CitingFile):$($_.StartLine) cites '$($_.Target):$checkLine' - target file has fewer lines"
        })
        ($violators -join "`n") | Should -BeNullOrEmpty
    }

    It 'reports ellipsis-elided ("...") citations as exempt, by name, never silently (the repo''s own truncation convention)' {
        $names = @($script:Elided | ForEach-Object { "$($_.CitingFile):$($_.StartLine) -> '$($_.Target):$($_.TargetLine)'" })
        Set-ItResult -Skipped -Because (
            "informational, not a failure: $($names.Count) ellipsis-elided citation(s) exempted - " +
            ($(if ($names.Count -gt 0) { $names -join '; ' } else { '(none)' })))
    }

    It 'reports historical-coordinate-marked citations as exempt, by name, never silently' {
        $names = @($script:Historical | ForEach-Object { "$($_.CitingFile):$($_.StartLine) -> '$($_.Target):$($_.TargetLine)'" })
        Set-ItResult -Skipped -Because (
            "informational, not a failure: $($names.Count) historical-coordinate citation(s) exempted - " +
            ($(if ($names.Count -gt 0) { $names -join '; ' } else { '(none)' })))
    }

    It 'reports ambiguous bare-basename citations by name, never silently resolved either way' {
        # #65 round 3, MINOR-R2-3: an AMBIGUOUS ELIDED coordinate must be re-resolved via
        # Resolve-ElidedCitationTarget (suffix match), never the plain Resolve-
        # CitationTarget (exact-basename equality) - the latter would look up the
        # truncated ellipsis token (e.g. "drill.md") as if it were a real basename, find
        # zero exact matches, and print a misleading "matches []" for an ambiguity that
        # is real and has real candidates. Zero live instances at this HEAD (all 13
        # ambiguous citations are ordinary bare basenames, not elided) - pinned as a
        # scratch fixture below rather than left unverified.
        $display = @($script:Ambiguous | ForEach-Object {
            if ($_.Elided) {
                $r = Resolve-ElidedCitationTarget -RepoRoot $script:RepoRoot -Coordinate $_ -AllTrackedFiles $script:AllTrackedFiles
            } else {
                $r = Resolve-CitationTarget -RepoRoot $script:RepoRoot -Coordinate $_ -BasenameMap $script:BasenameMap
            }
            "$($_.CitingFile):$($_.StartLine) -> '$($_.Target):$($_.TargetLine)' matches [$($r.ResolvedPath)]"
        })
        Set-ItResult -Skipped -Because (
            "informational, not a failure: $($display.Count) bare-basename citation(s) match 2+ tracked files, " +
            "cannot be mechanically disambiguated - $(($display -join '; '))")
    }

    It 'reports the content-anchor heuristic (backtick-token-in-window), REPORT-ONLY per landing calibration (n too small to bind)' {
        $hit = 0; $miss = 0; $missNames = @()
        foreach ($c in $script:Ok) {
            if (-not $c.Target.Contains('/')) { continue }
            $citingFull = Join-Path $script:RepoRoot $c.CitingFile
            $citingLines = @(Get-Content -Path $citingFull -Encoding UTF8)
            $lineIdx = [Math]::Min($c.EndLine, $citingLines.Count) - 1
            if ($lineIdx -lt 0) { continue }
            $tokens = @(Get-ContentAnchorTokens -Line $citingLines[$lineIdx])
            if ($tokens.Count -eq 0) { continue }
            $targetFull = Join-Path $script:RepoRoot $c.Target
            $targetLines = @(Get-Content -Path $targetFull -Encoding UTF8)
            $checkLine = if ($c.TargetLine2) { $c.TargetLine2 } else { $c.TargetLine }
            $lo = [Math]::Max(0, $checkLine - 1 - 15)
            $hi = [Math]::Min($targetLines.Count - 1, $checkLine - 1 + 15)
            $windowText = ($targetLines[$lo..$hi] -join "`n")
            # #65 round 2, MINOR-2: -cmatch (case-sensitive) is the production choice -
            # -match (case-insensitive) would false-HIT a PascalCase token like
            # `StalenessMs` against unrelated lowercase prose (config.go:56's own
            # lowercase-field prose is the live near-collision).
            $found = Test-ContentAnchorWindow -Tokens $tokens -WindowText $windowText -CaseSensitive
            if ($found) { $hit++ } else { $miss++; $missNames += "$($c.CitingFile):$($c.StartLine) -> $($c.Target):$checkLine" }
        }
        Set-ItResult -Skipped -Because (
            "REPORT-ONLY (see header CHECK (c) for the honest report-only-vs-binding " +
            "argument, made WITH this diagnostic's 3-for-3 historical true-positive " +
            "record - see the 'Content-anchor 3-for-3 historical record' Describe below " +
            "for the pinned reproduction - not around it): hit=$hit miss=$miss at this " +
            "HEAD. Misses: $(if ($missNames.Count -gt 0) { $missNames -join '; ' } else { '(none)' })")
    }
}

Describe 'Content-anchor 3-for-3 historical record (#65 round 3, MAJOR-R2-1)' {
    # Reproduces the EXACT shape of the view train's MAJOR-2 (config.go:42, cited from
    # docs/design/2026-07-21-v0-yard-skeleton-design.md:611 at commit 3076a40) as an
    # in-memory fixture, without touching git: an exact-case token declared far above
    # the cited line, a lowercase collision INSIDE the +/-15 window, and the exact-case
    # re-occurrence OUTSIDE the window - the structural pattern that made round 1's
    # `-match` false-hit and round 2's `-cmatch` correctly miss (a real defect, since
    # the cited line has nothing to do with either StalenessMs occurrence). This moves
    # the header's 3-for-3 claim from prose to a pinned assertion, per the review.
    BeforeAll {
        $script:FixtureTargetLines = @(
            'StalenessMs int  // field declaration, exact case, line 1 - OUTSIDE the window'
        ) + (2..16 | ForEach-Object { "filler line $_" }) + @(
            'RepoRoot string  // line 17 - the WRONG cited line, mimics config.go:42'
        ) + (18..31 | ForEach-Object { "filler line $_" }) + @(
            '// port 4600, pollMs 1000, heartbeatMs 5000, stalenessMs 15000.  // line 32, lowercase collision, INSIDE the window'
        ) + (33..39 | ForEach-Object { "filler line $_" }) + @(
            'StalenessMs: 15000,  // line 40 - exact-case reoccurrence, OUTSIDE the window'
        ) + (41..45 | ForEach-Object { "filler line $_" })
        $script:FixtureCitingLine = 'measured: `StalenessMs` ships at `15000` (`config-like.go:17`) against a shop default'
        $script:FixtureCheckLine  = 17
        $script:FixtureTokens     = Get-ContentAnchorTokens -Line $script:FixtureCitingLine
        $lo = [Math]::Max(0, $script:FixtureCheckLine - 1 - 15)
        $hi = [Math]::Min($script:FixtureTargetLines.Count - 1, $script:FixtureCheckLine - 1 + 15)
        $script:FixtureWindowText = ($script:FixtureTargetLines[$lo..$hi] -join "`n")
    }

    It 'the fixture carries exactly one qualifying backtick token, StalenessMs' {
        $script:FixtureTokens | Should -Be @('StalenessMs')
    }

    It 'a case-INSENSITIVE match (round 1''s -match) FALSE-HITS against the lowercase collision' {
        (Test-ContentAnchorWindow -Tokens $script:FixtureTokens -WindowText $script:FixtureWindowText) | Should -BeTrue
    }

    It 'the case-SENSITIVE match (round 2''s -cmatch, the production choice) correctly MISSES - the real defect this diagnostic would have caught' {
        (Test-ContentAnchorWindow -Tokens $script:FixtureTokens -WindowText $script:FixtureWindowText -CaseSensitive) | Should -BeFalse
    }
}

Describe 'Citation coordinate scan performance sanity (#65)' {
    It 'completes the real-corpus scan within a bounded time (CI runs this on every push)' {
        $repoRoot = git rev-parse --show-toplevel
        $sourceFiles = @(Get-CheckedSourceFiles -RepoRoot $repoRoot)
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $coords = @(Find-CitationCoordinates -RepoRoot $repoRoot -SourceFiles $sourceFiles)
        $sw.Stop()
        # Generous bound (60s) for a scan that measured well under 10s locally at
        # landing (258 files, 192 coordinates) - this is a sanity ceiling against
        # accidental quadratic blowup, not a tight performance SLA.
        $sw.Elapsed.TotalSeconds | Should -BeLessThan 60 -Because (
            "scanned $($sourceFiles.Count) files / $($coords.Count) coordinates in $($sw.Elapsed.TotalSeconds) seconds")
    }
}

Describe 'Line-wrap unwrapping and false-join suppression (scratch repo, #65)' {
    # Proves the MECHANISM in isolation, independent of whether the real repo's Class-C
    # instances stay present after future edits (they may get symbol-cited away, same as
    # the view train's own dom-writer.js:201 fix did) - the round-2/round-3 scars this
    # gate exists to catch, reproduced as durable fixtures.

    BeforeAll {
        $script:Scratch = Join-Path ([System.IO.Path]::GetTempPath()) "citation-resolver-test-$(Get-Random)"
        New-Item -ItemType Directory -Path $script:Scratch -Force | Out-Null
        git -C $script:Scratch init -q | Out-Null
        git -C $script:Scratch config user.email 'test@starcar.local' | Out-Null
        git -C $script:Scratch config user.name  'Citation Resolver Test' | Out-Null

        # The TARGET of every fixture citation below - a real file with a known length.
        1..20 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'target.go') -Encoding UTF8
        # A SECOND target with an intra-name hyphen, matching the real scar shape (kebab-
        # case filenames like "dom-writer.js" wrapped exactly at an EXISTING hyphen that
        # is part of the name itself, not an inserted one).
        1..20 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'tar-get.go') -Encoding UTF8

        # Fixture 1: a clean, resolvable single-line citation.
        Set-Content -Path (Join-Path $script:Scratch 'clean.md') -Value @(
            '# clean'
            'See target.go:5 for the real thing.'
        ) -Encoding UTF8

        # Fixture 2: CLASS A - dead path (file does not exist).
        Set-Content -Path (Join-Path $script:Scratch 'dead-path.md') -Value @(
            '# dead path'
            'See nonexistent-file.go:12 which was never real.'
        ) -Encoding UTF8

        # Fixture 3: CLASS B - out-of-range line (target.go only has 20 lines).
        Set-Content -Path (Join-Path $script:Scratch 'out-of-range.md') -Value @(
            '# out of range'
            'See target.go:999 which does not exist in the target.'
        ) -Encoding UTF8

        # Fixture 4: CLASS C - line-wrapped citation, split exactly at the target's own
        # intra-name hyphen, matching the real scar shape ("board/web/js/dom-" /
        # "writer.js:201" - dom-writer.js is one kebab-case name, wrapped at its hyphen).
        Set-Content -Path (Join-Path $script:Scratch 'wrapped.js') -Value @(
            '// this comment cites tar-'
            '// get.go:7 across a wrap, exactly like the real scar.'
        ) -Encoding UTF8

        # Fixture 5: a false-join risk - two unrelated adjacent lines where the FIRST
        # does NOT end in a hyphen. Must NOT be glued into a spurious coordinate.
        Set-Content -Path (Join-Path $script:Scratch 'no-false-join.go') -Value @(
            '// this line ends with the word disclosed at'
            '// target.go:9 is unrelated content on the next line'
        ) -Encoding UTF8

        # Fixture 6: ellipsis elision, resolving via the truncated form.
        Set-Content -Path (Join-Path $script:Scratch 'elided.md') -Value @(
            '# elided'
            'See the earlier full citation, abbreviated here as (`.../target.go:3`).'
        ) -Encoding UTF8

        # Fixture 7: historical-marker exemption over a genuinely dead path.
        Set-Content -Path (Join-Path $script:Scratch 'historical.md') -Value @(
            '# historical'
            'The old gone-file.go:1 reference is a historical coordinate, kept for the scar.'
        ) -Encoding UTF8

        # Fixture 8 (#65 round 2, MINOR-3 red-first proof): a FABRICATED ellipsis
        # reference to a file that never existed. Round 1's ellipsis valve skipped
        # existence/range checks entirely - this must now resolve dead.
        Set-Content -Path (Join-Path $script:Scratch 'elided-dead.md') -Value @(
            '# elided dead'
            'A fabricated shorthand (`.../never-existed.md:3`) that must not pass.'
        ) -Encoding UTF8

        # Fixture 9 (#65 round 2, MINOR-4 red-first proof): TWO files sharing a
        # basename, BOTH too short for the cited line - must bind as out-of-range,
        # not wave through as merely ambiguous.
        New-Item -ItemType Directory -Path (Join-Path $script:Scratch 'subA') -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $script:Scratch 'subB') -Force | Out-Null
        1..5 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'subA/dup.md') -Encoding UTF8
        1..5 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'subB/dup.md') -Encoding UTF8
        Set-Content -Path (Join-Path $script:Scratch 'ambiguous-oor.md') -Value @(
            '# ambiguous out of range'
            'See dup.md:999 - both candidates are 5 lines long.'
        ) -Encoding UTF8

        # Fixture 10 (#65 round 2, MINOR-1 red-first proof): a slash-boundary wrap - the
        # citing line ends in a bare `/`, and the coordinate is only correct once the
        # directory prefix joins the next line's bare filename.
        New-Item -ItemType Directory -Path (Join-Path $script:Scratch 'board/web/js') -Force | Out-Null
        1..20 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'board/web/js/dom-writer.js') -Encoding UTF8
        Set-Content -Path (Join-Path $script:Scratch 'slash-wrap.md') -Value @(
            '// see board/web/js/'
            '// dom-writer.js:5 for details.'
        ) -Encoding UTF8

        # Fixture 11 (#65 round 3, MINOR-R2-3 red-first proof): an AMBIGUOUS ELIDED
        # citation - two files whose basename shares the elided suffix. The ambiguous
        # report must show REAL candidates, never the "[]" a plain exact-basename
        # lookup would print for a truncated ellipsis token.
        New-Item -ItemType Directory -Path (Join-Path $script:Scratch 'subA') -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $script:Scratch 'subB') -Force | Out-Null
        1..10 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'subA/report-thing.md') -Encoding UTF8
        1..10 | ForEach-Object { "line $_" } | Set-Content -Path (Join-Path $script:Scratch 'subB/summary-thing.md') -Encoding UTF8
        Set-Content -Path (Join-Path $script:Scratch 'elided-ambiguous.md') -Value @(
            '# elided ambiguous'
            'See the earlier citation, abbreviated as (`.../thing.md:3`).'
        ) -Encoding UTF8

        git -C $script:Scratch add -A | Out-Null
        git -C $script:Scratch commit -q -m 'fixtures' | Out-Null

        $script:AllFiles    = @('target.go', 'clean.md', 'dead-path.md', 'out-of-range.md', 'wrapped.js', 'no-false-join.go', 'elided.md', 'historical.md', 'elided-dead.md', 'ambiguous-oor.md', 'slash-wrap.md', 'elided-ambiguous.md')
        $script:BasenameMap = Get-BasenameMap -RepoRoot $script:Scratch
        $script:AllTracked  = @(git -C $script:Scratch ls-files)
        $script:Coords      = @(Find-CitationCoordinates -RepoRoot $script:Scratch -SourceFiles $script:AllFiles)
    }

    AfterAll {
        Remove-Item -Path $script:Scratch -Recurse -Force -ErrorAction SilentlyContinue
    }

    It 'resolves the clean single-line citation as OK' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'clean.md' }
        $c.Count | Should -Be 1
        (Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap).Status | Should -Be 'ok'
    }

    It 'flags the dead-path fixture BY NAME (Class A, red-first proof)' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'dead-path.md' }
        $c.Count | Should -Be 1
        $c.Target | Should -Be 'nonexistent-file.go'
        (Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap).Status | Should -Be 'dead'
    }

    It 'flags the out-of-range fixture BY NAME (Class B, red-first proof)' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'out-of-range.md' }
        $c.Count | Should -Be 1
        $c.TargetLine | Should -Be 999
        (Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap).Status | Should -Be 'out-of-range'
    }

    It 'resolves the line-wrapped fixture correctly by unwrapping (Class C, red-first proof it is NOT missed)' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'wrapped.js' }
        $c.Count | Should -Be 1
        $c.Target | Should -Be 'tar-get.go'
        $c.TargetLine | Should -Be 7
        $c.StartLine | Should -Be 1
        $c.EndLine | Should -Be 2
        (Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap).Status | Should -Be 'ok'
    }

    It 'does NOT create a spurious joined match when the prior line does not end in a hyphen' {
        $bogus = $script:Coords | Where-Object { $_.CitingFile -eq 'no-false-join.go' -and $_.Target -like '*disclosed*' }
        $bogus.Count | Should -Be 0
        # The real, single-line "target.go:9" on line 2 must still be found and OK.
        $real = $script:Coords | Where-Object { $_.CitingFile -eq 'no-false-join.go' }
        $real.Count | Should -Be 1
        $real.Target | Should -Be 'target.go'
        $real.TargetLine | Should -Be 9
    }

    It 'marks the ellipsis-elided fixture Elided rather than dead' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'elided.md' }
        $c.Count | Should -Be 1
        $c.Elided | Should -BeTrue
    }

    It 'the historical-coordinate marker is detected on the fixture citing a dead path' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'historical.md' }
        $c.Count | Should -Be 1
        (Test-HistoricalCoordinateMarker -RepoRoot $script:Scratch -Coordinate $c) | Should -BeTrue
        # And confirm it WOULD have been flagged dead without the marker - the marker is
        # doing real work, not decorating an already-passing case.
        (Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap).Status | Should -Be 'dead'
    }

    It 'flags a FABRICATED ellipsis reference BY NAME (#65 round 2, MINOR-3 red-first proof - a fabricated ".../never-existed.md:3" must not pass)' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'elided-dead.md' }
        $c.Count | Should -Be 1
        $c.Elided | Should -BeTrue
        (Resolve-ElidedCitationTarget -RepoRoot $script:Scratch -Coordinate $c -AllTrackedFiles $script:AllTracked).Status | Should -Be 'dead'
    }

    It 'binds the all-candidates-out-of-range ambiguous case (#65 round 2, MINOR-4 red-first proof)' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'ambiguous-oor.md' }
        $c.Count | Should -Be 1
        $c.Target | Should -Be 'dup.md'
        $r = Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap
        # Both subA/dup.md and subB/dup.md are 5 lines; the cited line is 999 - out of
        # range for EVERY candidate, so this binds as a real defect, not mere ambiguity.
        $r.Status | Should -Be 'out-of-range'
    }

    It 'joins across a bare trailing slash (#65 round 2, MINOR-1 red-first proof - the directory prefix must join the next line''s bare filename)' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'slash-wrap.md' }
        $c.Count | Should -Be 1
        $c.Target | Should -Be 'board/web/js/dom-writer.js'
        $c.TargetLine | Should -Be 5
        (Resolve-CitationTarget -RepoRoot $script:Scratch -Coordinate $c -BasenameMap $script:BasenameMap).Status | Should -Be 'ok'
    }

    It 'an AMBIGUOUS ELIDED citation resolves via suffix match with REAL candidates, never "matches []" (#65 round 3, MINOR-R2-3 red-first proof)' {
        $c = $script:Coords | Where-Object { $_.CitingFile -eq 'elided-ambiguous.md' }
        $c.Count | Should -Be 1
        $c.Elided | Should -BeTrue
        $r = Resolve-ElidedCitationTarget -RepoRoot $script:Scratch -Coordinate $c -AllTrackedFiles $script:AllTracked
        $r.Status | Should -Be 'ambiguous'
        # The bug this pins: Resolve-CitationTarget's exact-basename lookup on the
        # truncated token "thing.md" finds ZERO exact matches and returns
        # ResolvedPath = $null, which would render as "matches []" - misleading for a
        # real ambiguity. Resolve-ElidedCitationTarget's suffix match must show BOTH
        # real candidates instead.
        $r.ResolvedPath | Should -Not -BeNullOrEmpty
        $r.ResolvedPath | Should -Match 'subA[/\\]report-thing\.md'
        $r.ResolvedPath | Should -Match 'subB[/\\]summary-thing\.md'
    }
}

Describe 'Test-CitationWrapBoundary unit tests (#65 round 2, MINOR-1 + MINOR-5)' {
    # Unit-tests the join precondition directly, because the production regex's
    # character class (no space) already prevents a spaced-dash line from producing an
    # observable end-to-end join difference - MINOR-5's fix is a defensive-design
    # correctness fix (a "future false-join surface" per the review, not a currently
    # reproducible end-to-end miss), so it is pinned at the unit level instead.
    It 'a word character immediately before a trailing hyphen IS a wrap boundary' {
        Test-CitationWrapBoundary -TrimmedLine 'this comment cites tar-' | Should -BeTrue
    }
    It 'a SPACE immediately before a trailing hyphen is NOT a wrap boundary (the prose-dash case, MINOR-5)' {
        Test-CitationWrapBoundary -TrimmedLine 'this comment cites tar -' | Should -BeFalse
    }
    It 'a bare trailing slash IS a wrap boundary (MINOR-1)' {
        Test-CitationWrapBoundary -TrimmedLine 'see board/web/js/' | Should -BeTrue
    }
    It 'ordinary prose with neither ending is NOT a wrap boundary' {
        Test-CitationWrapBoundary -TrimmedLine 'this is an ordinary sentence.' | Should -BeFalse
    }
}

Describe 'Extension-completeness helper unit tests (#65 round 2, MAJOR-5, mirrors CodeCitationPolicy.Tests.ps1''s own synthetic completeness proof)' {
    It 'detects a genuinely unaccounted extensionless entry (Count 1, element is empty string)' {
        $unaccounted = @(Get-UnaccountedExtensions -ObservedExtensions @('.go', '') -CoveredExtensions @('.go'))
        $unaccounted.Count | Should -Be 1
        $unaccounted -contains '' | Should -BeTrue
    }
    It 'reports zero unaccounted once every observed extension is covered' {
        $unaccounted = @(Get-UnaccountedExtensions -ObservedExtensions @('.go', '.md') -CoveredExtensions @('.go', '.md'))
        $unaccounted.Count | Should -Be 0
    }
    It 'names an unaccounted extension by value, not just by count' {
        $unaccounted = @(Get-UnaccountedExtensions -ObservedExtensions @('.go', '.py', '.md') -CoveredExtensions @('.go', '.md'))
        $unaccounted.Count | Should -Be 1
        $unaccounted | Should -Be @('.py')
    }
}
