package board

import "testing"

// DELIBERATE RED - D10 watched-red proof for the board CI leg (plan task 1.4's live
// half, conductor handback). This commit is reverted immediately; the point is to
// OBSERVE the new leg fail on both real GitHub runners before trusting its green.
func TestDeliberateRedWatchedRedProofLive(t *testing.T) {
	t.Fatal("deliberate red: the board CI leg must be WATCHED to fail before its green is trusted (D10)")
}
