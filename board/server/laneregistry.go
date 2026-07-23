package main

// laneSpec is one entry in the lane registry (design S5.2/D11: "the lane
// registry is the sole owner of a lane's position"; deploy-time registry
// truth, not user data - v0 has no adapter-plugin system yet).
type laneSpec struct {
	ID       string
	Title    string
	Position string
}

// laneRegistry is v0's five lanes (design S5.2): dispatches/gates/trains are
// live (this server's own adapter); freight is dark (no adapter - the
// ticket queue, #7 out of scope); fuel is bagged (cost fields exist on some
// records but are not surfaced until #11's cost ledger work). Every
// registered lane renders in EVERY snapshot on EVERY code path, including
// pre-first-poll (the completeness guard laneregistry_test.go pins) -
// shrinking this slice is a red, never a silent lane loss.
var laneRegistry = []laneSpec{
	{ID: "dispatches", Title: "Dispatches", Position: "live"},
	{ID: "gates", Title: "Gates", Position: "live"},
	{ID: "trains", Title: "Trains", Position: "live"},
	{ID: "freight", Title: "Freight", Position: "dark"},
	{ID: "fuel", Title: "Fuel", Position: "bagged"},
}
