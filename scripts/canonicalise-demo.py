import hashlib, json

def canon(obj):
    # Normative canonicalisation: UTF-8 JSON, keys sorted by codepoint,
    # compact separators, absent fields OMITTED (never null), integers only.
    return json.dumps(obj, sort_keys=True, separators=(',', ':'), ensure_ascii=False).encode('utf-8')

def eid(obj):
    return hashlib.sha256(canon(obj)).hexdigest()

# One 'dispatched' event, as BOTH producers observe it.
hook = {
  "kind": "dispatched",
  "schema": "starcar-artifact/1",
  "session_id": "64c15364-0933-4d6d-9b2e-d1ddbc918f9f",
  "dispatch_id": "a06da84aa8cc7d5b7",
  "subject": "dispatch:64c15364-0933-4d6d-9b2e-d1ddbc918f9f:a06da84aa8cc7d5b7",
  "role": "reviewer",
  "gate": "design-review",
  "target": "docs/design/2026-07-22-dispatch-harness-design.md",
  "base": "783e39e371c7e96a8d53ac17feadcdfea57b2608",
  "model": "opus",
  "expect_by_ms": 1800000,
}
# The sweep observes the same event later, from the transcript, and stamps
# DIFFERENT observation metadata. Those fields are excluded by construction.
sweep = dict(hook)

print("CANONICAL BYTES (hook):")
print(canon(hook).decode())
print()
print("hook  event_id :", eid(hook))
print("sweep event_id :", eid(sweep))
print("EQUAL           :", eid(hook) == eid(sweep))
print()

# A 'returned' for the same dispatch. No supersedes pointer anywhere.
ret = {
  "kind": "returned",
  "schema": "starcar-artifact/1",
  "session_id": "64c15364-0933-4d6d-9b2e-d1ddbc918f9f",
  "dispatch_id": "a06da84aa8cc7d5b7",
  "subject": "dispatch:64c15364-0933-4d6d-9b2e-d1ddbc918f9f:a06da84aa8cc7d5b7",
  "outcome": "REJECT",
  "findings": {"major": 4, "minor": 7, "note": 6},
  "body_sha256": "48564c242d48853e601da9de31a112b857e204d229c170285a60e957af36db9b",
}
print("returned event_id:", eid(ret))

lost = {
  "kind": "presumed-lost",
  "schema": "starcar-artifact/1",
  "session_id": "64c15364-0933-4d6d-9b2e-d1ddbc918f9f",
  "dispatch_id": "a06da84aa8cc7d5b7",
  "subject": "dispatch:64c15364-0933-4d6d-9b2e-d1ddbc918f9f:a06da84aa8cc7d5b7",
  "reason": "expect_by_exceeded",
  "budget_ms": 1800000,
  "elapsed_ms": 2100000,
}
print("presumed-lost id :", eid(lost))
