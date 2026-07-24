package main

import (
	"fmt"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/polecatspeaks/StarCar/board/assemble"
)

// TestShopDefaultBudgetThreadsThroughToTheWire is C4R-1's committed
// regression guard (Car 4 review round 1, Major): the C3R-1 divergence -
// board/fold rendering dispatched/null on a budget-less legacy record while
// the pwsh detector rendered overdue/1800 - was closed by threading
// board/fold.LoadDefaultBudget's result into every Fold call via
// WithDefaultBudgetSeconds (poll.go, NewServer + buildSnapshot). That fix
// was PROVEN to work live by the round-1 reviewer, but no committed test set
// Config.DefaultsPath, so nothing in this suite would go red if the
// threading lines were deleted by a future refactor. This test sets
// DefaultsPath explicitly (the ONLY test in this package that does),
// constructs a scratch store holding a budget-less dispatched record whose
// "at" is far past the default with no successor, and asserts the WIRE
// output - not the fold package directly - carries state=overdue,
// budget_source=default, budget_seconds=the injected default.
func TestShopDefaultBudgetThreadsThroughToTheWire(t *testing.T) {
	const injectedDefault = 1800.0

	defaultsPath := filepath.Join(t.TempDir(), "harness-defaults.json")
	defaultsJSON := fmt.Sprintf(`{"dispatch_budget_seconds": %v}`, injectedDefault)
	if err := os.WriteFile(defaultsPath, []byte(defaultsJSON), 0o644); err != nil {
		t.Fatalf("writing the fixture defaults file: %v", err)
	}

	root := t.TempDir()
	// Far past the default: "now" below is 2026-07-23T12:00:00Z; this record
	// carries NO "budget" of its own and NO successor, so the fold's ONLY
	// path to "overdue" is the shop default this server threads in.
	writeRecord(t, root, "budget-less-1/dispatched-1.json", validDispatchedJSON("budget-less-1", "2026-07-20T00:00:00Z"))

	cfg := testConfig(t, root)
	cfg.DefaultsPath = defaultsPath
	srv, err := NewServer(cfg)
	if err != nil {
		t.Fatalf("NewServer: %v", err)
	}

	now := time.Date(2026, 7, 23, 12, 0, 0, 0, time.UTC)
	snap, _, err := srv.PollOnce(now)
	if err != nil {
		t.Fatalf("PollOnce: %v", err)
	}

	var dispatchesLane Lane
	for _, l := range snap.Lanes {
		if l.ID == "dispatches" {
			dispatchesLane = l
		}
	}
	payload, ok := dispatchesLane.Data.(assemble.DispatchesPayload)
	if !ok {
		t.Fatalf("dispatches lane Data is not an assemble.DispatchesPayload: %#v", dispatchesLane.Data)
	}
	if len(payload.Dispatches) != 1 {
		t.Fatalf("expected exactly 1 dispatch entry on the wire, got %d: %+v", len(payload.Dispatches), payload.Dispatches)
	}
	entry := payload.Dispatches[0]

	if entry["state"] != "overdue" {
		t.Fatalf("wire dispatch state = %v, want overdue - the shop default was not applied at the server boundary", entry["state"])
	}
	if entry["budget_source"] != "default" {
		t.Fatalf("wire dispatch budget_source = %v, want default", entry["budget_source"])
	}
	gotBudget, ok := entry["budget_seconds"].(float64)
	if !ok || gotBudget != injectedDefault {
		t.Fatalf("wire dispatch budget_seconds = %v, want %v", entry["budget_seconds"], injectedDefault)
	}
}
