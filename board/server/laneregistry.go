package main

// laneSpec is one entry in the lane registry (design S5.2/D11: "the lane
// registry is the sole owner of a lane's position"; deploy-time registry
// truth, not user data - v0 has no adapter-plugin system yet).
type laneSpec struct {
	ID       string
	Title    string
	Position string
}

// laneRegistry is v0's five lanes (design S5.2): dispatches/gates/trains/
// freight are live; fuel is bagged (cost fields exist on some records but
// are not surfaced until #11's cost ledger work). Every registered lane
// renders in EVERY snapshot on EVERY code path, including pre-first-poll
// (the completeness guard laneregistry_test.go pins) - shrinking this slice
// is a red, never a silent lane loss.
//
// #84 (2026-07-27): freight flipped dark -> live. Section 7's trigger
// ("first train after v0 ships") fired long ago and sat unpicked-up; the
// freight adapter (scripts/Sync-Freight.ps1) now writes kind=ticket records
// into the store, board/assemble reads them RAW (never through fold - #84
// owner ruling item 3), and freight's own freshness is computed
// independently of dispatches/gates/trains (board/server/poll.go's
// computeFreightFreshness, keyed off a kind=ticket-sync heartbeat record's
// own "at") so "the adapter never ran" cannot collapse onto "ran, queue
// empty" (Law 1).
var laneRegistry = []laneSpec{
	{ID: "dispatches", Title: "Dispatches", Position: "live"},
	{ID: "gates", Title: "Gates", Position: "live"},
	{ID: "trains", Title: "Trains", Position: "live"},
	{ID: "freight", Title: "Freight", Position: "live"},
	{ID: "fuel", Title: "Fuel", Position: "bagged"},
}
