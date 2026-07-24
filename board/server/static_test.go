package main

import (
	"io"
	"net/http"
	"strings"
	"testing"
)

// TestServesIndexHTMLAtRoot: plan section 6 - Car 5 replaces the task 4.3
// placeholder ("the view lands with Car 5") so GET / actually serves
// board/web/'s index.html, never the placeholder string.
func TestServesIndexHTMLAtRoot(t *testing.T) {
	_, ts := newTestHTTPServer(t, t.TempDir())
	resp, err := http.Get(ts.URL + "/")
	if err != nil {
		t.Fatalf("GET /: %v", err)
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("reading body: %v", err)
	}
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("GET / status = %d, want 200", resp.StatusCode)
	}
	if !strings.Contains(string(body), "StarCar") {
		t.Fatalf("GET / body does not look like board/web/index.html (missing \"StarCar\"): %s", body)
	}
	if strings.Contains(string(body), "The view (board/web/) lands with Car 5") {
		t.Fatalf("GET / still serves task 4.3's placeholder text - the real view must replace it")
	}
}

// TestServesWireSchemaFile: design rev 5 S5.4 item 2 - the browser
// validator consumes THE schema file itself (never a hand-maintained
// mirror). The server must serve schema/yard-snapshot.schema.json
// byte-for-byte from disk, not a duplicated copy under board/web/.
func TestServesWireSchemaFile(t *testing.T) {
	_, ts := newTestHTTPServer(t, t.TempDir())
	resp, err := http.Get(ts.URL + "/schema/yard-snapshot.schema.json")
	if err != nil {
		t.Fatalf("GET /schema/yard-snapshot.schema.json: %v", err)
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("reading body: %v", err)
	}
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("status = %d, want 200", resp.StatusCode)
	}
	if !strings.Contains(string(body), `"https://starcar.dev/schema/yard-snapshot/1"`) {
		t.Fatalf("served body does not look like the real wire schema (missing its $id): %s", body)
	}
	ct := resp.Header.Get("Content-Type")
	if !strings.Contains(ct, "json") {
		t.Fatalf("Content-Type = %q, want something containing \"json\"", ct)
	}
}

// TestServesJSModuleAssets: board/web/js/*.js must be reachable over HTTP -
// a browser <script type="module" src="/js/compose.js"> needs this route,
// not just the repo filesystem.
func TestServesJSModuleAssets(t *testing.T) {
	_, ts := newTestHTTPServer(t, t.TempDir())
	resp, err := http.Get(ts.URL + "/js/compose.js")
	if err != nil {
		t.Fatalf("GET /js/compose.js: %v", err)
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		t.Fatalf("reading body: %v", err)
	}
	if resp.StatusCode != http.StatusOK {
		t.Fatalf("status = %d, want 200", resp.StatusCode)
	}
	if !strings.Contains(string(body), "composeRegister") {
		t.Fatalf("served body does not look like board/web/js/compose.js: %s", body)
	}
}
