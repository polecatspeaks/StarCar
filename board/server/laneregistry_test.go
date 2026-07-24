package main

import "testing"

// TestLaneRegistryPin: design S5.2's completeness guard - shrinking the
// registered lane set is a red. The five lanes are the whole v0 registry
// (dispatches, gates, trains live; freight dark; fuel bagged).
func TestLaneRegistryPin(t *testing.T) {
	want := map[string]string{
		"dispatches": "live",
		"gates":      "live",
		"trains":     "live",
		"freight":    "dark",
		"fuel":       "bagged",
	}
	if len(laneRegistry) != len(want) {
		t.Fatalf("laneRegistry has %d lanes, want %d - a shrink here is a red by design", len(laneRegistry), len(want))
	}
	for _, spec := range laneRegistry {
		wantPos, ok := want[spec.ID]
		if !ok {
			t.Errorf("unexpected lane id %q in the registry", spec.ID)
			continue
		}
		if spec.Position != wantPos {
			t.Errorf("lane %q position = %q, want %q", spec.ID, spec.Position, wantPos)
		}
	}
}
