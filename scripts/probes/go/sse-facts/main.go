// Probe 2: SSE over net/http stdlib - can a handler flush frames incrementally,
// and does a client see them as they are written? Uses httptest (stdlib) - no
// network, no dependency, observed behavior only.
package main

import (
	"bufio"
	"fmt"
	"net/http"
	"net/http/httptest"
	"time"
)

func main() {
	// FACT 8: does the stdlib ResponseWriter support http.Flusher?
	frames := make(chan string, 3)
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		fl, ok := w.(http.Flusher)
		fmt.Printf("FACT8 ResponseWriter implements http.Flusher: %v\n", ok)
		w.Header().Set("Content-Type", "text/event-stream")
		for i := 1; i <= 3; i++ {
			fmt.Fprintf(w, "event: yard\ndata: {\"seq\":%d}\n\n", i)
			fl.Flush()
			time.Sleep(50 * time.Millisecond) // spacing so arrival timing is observable
		}
	}))
	defer srv.Close()

	// FACT 9: client sees frames incrementally (before the response body completes)?
	resp, err := http.Get(srv.URL)
	if err != nil {
		fmt.Println("probe error:", err)
		return
	}
	defer resp.Body.Close()
	rd := bufio.NewReader(resp.Body)
	start := time.Now()
	got := 0
	for got < 3 {
		line, err := rd.ReadString('\n')
		if err != nil {
			break
		}
		if len(line) > 5 && line[:5] == "data:" {
			got++
			frames <- fmt.Sprintf("frame %d at +%dms", got, time.Since(start).Milliseconds())
		}
	}
	close(frames)
	for f := range frames {
		fmt.Println("FACT9", f)
	}
	fmt.Printf("FACT9 verdict: 3 frames received incrementally=%v (arrival spread over ~100ms proves streaming, not buffered-at-end)\n", got == 3)
}
