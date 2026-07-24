# Go substrate probes - observed facts for the rev 4 yard-board design

Status: Current
Probed: 2026-07-23, local machine (Windows 11), Go **1.26.5** (installed this morning via
`winget install GoLang.Go`, owner-approved; prior state: `go: command not found` - the
toolchain did NOT exist on this machine before this probe session).
Probe programs: `scripts/probes/go/json-facts/main.go`, `scripts/probes/go/sse-facts/main.go` -
re-run with `go run scripts/probes/go/json-facts/main.go` (each is standalone, stdlib-only).
Landing tier: recorded measurement with coordinates (this doc). **Pin-as-tests trigger:**
these facts become committed Go tests in the board module's Car 1, the moment a `go.mod`
exists to hold them - recorded here so the deferral is a decision, not an omission.

Doctrine: NO HEADERS HERE - a new language is maximum-unproven substrate. Every claim
below was RUN and is quoted from observation, not from training data or documentation.

## Observed facts

| # | Claim | Observed | Design consequence |
|---|---|---|---|
| FACT1 | `json.Unmarshal` into a struct, payload carries an undeclared field | `err=nil`, field **SILENTLY DROPPED** | The Law 4 hazard is REAL and is the default. A naive struct decode of a store record loses unknown fields with no trace. The design must legislate the decode path. |
| FACT2 | `Decoder.DisallowUnknownFields()` | errors with `json: unknown field "surprise_field"` - names the field, but **fatal to the whole decode** | Reject-not-disclose: blanks the board over a harmless addition (the Law 1 harm rev 3 §6 already ruled against). Not the right default for record reads. |
| FACT3 | `map[string]json.RawMessage` decode of the same payload | `err=nil`, ALL 7 keys preserved incl. the surprise field | **The preserve-and-disclose mechanism exists in stdlib:** decode twice (typed struct + raw map), diff key sets, disclose unknowns as a BoardCondition. This is the rev 4 decode contract. |
| FACT4 | number in `interface{}` | `float64`; 9007199254740993 (2^53+1) **corrupted** to ...992 | Above-2^53 integers lose precision on the untyped path. Token counts today are far below 2^53, but the design notes the cliff; `Decoder.UseNumber()` observed preserving exactly (`json.Number`). |
| FACT5 | `time.Time` JSON round-trip of `2026-07-22T03:44:34-04:00` | re-marshal is **byte-verbatim**, offset preserved | Go is LESS hazardous than pwsh here (the M-A4-1 class does not fire on round-trip). The verbatim-`at`-string discipline stays regardless: the board never re-serialises a record's `at`. |
| FACT6 | `time.Parse(RFC3339)` offset form vs Z form of the same instant | `a.Equal(b) = true` | Chronological sort across mixed-offset records (the store's real state) is correct via parsed instants - same contract as `Get-AtInstant` (Artifact.psm1), now proven to hold in Go. |
| FACT7 | marshal determinism | struct: identical bytes across runs; map keys marshalled **sorted alphabetically** (`{"alpha":..,"mike":..,"zebra":..}`) | Deterministic wire output is achievable; struct-field declaration order is the emit order, so the wire contract pins field order via one struct definition. |
| FACT8 | stdlib `ResponseWriter` supports `http.Flusher` | `true` (httptest server) | SSE needs no third-party dependency. |
| FACT9 | SSE frames flushed incrementally | client observed frame arrivals at **+0ms / +50ms / +100ms**, matching server-side 50ms spacing | Streaming is real, not buffered-at-end: the walking skeleton's live wire works in pure stdlib. |

## Register of what the desk still cannot prove (deferred probes, with triggers)

| Unproven claim | Trigger to probe |
|---|---|
| CI runners' Go availability/version (windows-latest, ubuntu-latest) | Car 1 wires `actions/setup-go` and CI itself becomes the probe - first CI run of the board module |
| `EventSource` browser behavior against the Go server (heartbeat, half-open detection) | the walking skeleton's first live serve - rev 3 §7's rules carry as design until then |
| JSON Schema validation library for Go (candidate selection + draft-2020-12 conformance) | design names the requirement; the plan rung selects against a measured conformance check |
| Cross-compile + single-binary claim (GOOS matrix) | Car 1, one command per target, recorded |

## Provenance

Session: this probe suite was ordered at the rev 4 design rung's opening, after the owner
ratified Go as the board-server language (issue #14 ruling, 2026-07-23). The design doc
cites these facts by FACT number; a design claim about Go behavior with no FACT row behind
it is a finding at design review.
