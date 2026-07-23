// Package board is the placeholder root package for the yard board's Go module
// (plan task 1.1). It exists so the CI leg wired in task 1.2 has something real
// to vet and test before car 3 (fold), car 4 (store/assemble/server), and
// car 5 (web) land their own packages under board/.
package board

// Placeholder returns a fixed string. It has no product behavior; it exists so
// the module compiles and the trivial test in board_test.go has something to
// assert on.
func Placeholder() string {
	return "board"
}
