// Probe 1: encoding/json + time facts for the StarCar rev-4 design.
// Every claim the design will make about Go's JSON behavior gets OBSERVED here first.
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"time"
)

func main() {
	// A real store record shape, with an EXTRA field the struct does not declare.
	rec := []byte(`{"schema":"starcar-artifact/1","kind":"returned","subject":"abc123","at":"2026-07-22T03:44:34-04:00","outcome":"REJECT","surprise_field":"the board must not lose me","big":9007199254740993}`)

	type Record struct {
		Schema  string `json:"schema"`
		Kind    string `json:"kind"`
		Subject string `json:"subject"`
		At      string `json:"at"`
		Outcome string `json:"outcome"`
	}

	// FACT 1: default Unmarshal on unknown fields - error or silent drop?
	var r1 Record
	err1 := json.Unmarshal(rec, &r1)
	fmt.Printf("FACT1 default-unmarshal-unknown-field: err=%v (parsed subject=%q) -> unknown fields %s\n",
		err1, r1.Subject, map[bool]string{true: "SILENTLY DROPPED", false: "error"}[err1 == nil])

	// FACT 2: DisallowUnknownFields - does the error NAME the field?
	dec := json.NewDecoder(bytes.NewReader(rec))
	dec.DisallowUnknownFields()
	var r2 Record
	err2 := dec.Decode(&r2)
	fmt.Printf("FACT2 DisallowUnknownFields error text: %q\n", err2)

	// FACT 3: preserve-and-disclose route - map[string]json.RawMessage keeps everything?
	var raw map[string]json.RawMessage
	err3 := json.Unmarshal(rec, &raw)
	keys := make([]string, 0, len(raw))
	for k := range raw {
		keys = append(keys, k)
	}
	fmt.Printf("FACT3 RawMessage map: err=%v, key count=%d (surprise_field present=%v)\n", err3, len(raw), raw["surprise_field"] != nil)

	// FACT 4: number handling in interface{} - float64 default, big-int precision?
	var anymap map[string]any
	_ = json.Unmarshal(rec, &anymap)
	fmt.Printf("FACT4 interface{} number: big=%v (type %T) - 9007199254740993 survived=%v\n",
		anymap["big"], anymap["big"], fmt.Sprintf("%.0f", anymap["big"]) == "9007199254740993")
	// and the UseNumber alternative:
	dec2 := json.NewDecoder(bytes.NewReader(rec))
	dec2.UseNumber()
	var anymap2 map[string]any
	_ = dec2.Decode(&anymap2)
	fmt.Printf("FACT4b UseNumber: big=%v (type %T)\n", anymap2["big"], anymap2["big"])

	// FACT 5: the M-A4-1 class in Go - time.Time round-trip of an OFFSET timestamp.
	var t time.Time
	errT := json.Unmarshal([]byte(`"2026-07-22T03:44:34-04:00"`), &t)
	remarshal, _ := json.Marshal(t)
	fmt.Printf("FACT5 time.Time round-trip: err=%v, in=2026-07-22T03:44:34-04:00 out=%s (verbatim=%v)\n",
		errT, remarshal, string(remarshal) == `"2026-07-22T03:44:34-04:00"`)

	// FACT 6: sorting key - time.Parse RFC3339 of offset form comparable to Z form?
	a, _ := time.Parse(time.RFC3339, "2026-07-22T03:44:34-04:00")
	b, _ := time.Parse(time.RFC3339, "2026-07-22T07:44:34Z")
	fmt.Printf("FACT6 offset-vs-Z instant equality: a.Equal(b)=%v (same instant, different offsets)\n", a.Equal(b))

	// FACT 7: json.Marshal of a struct - does it emit fields in declaration order (stable)?
	out1, _ := json.Marshal(r1)
	out2, _ := json.Marshal(r1)
	fmt.Printf("FACT7 marshal determinism (same struct twice): identical=%v\n", bytes.Equal(out1, out2))
	// and map marshal - Go sorts map keys alphabetically (documented, but observe it):
	m := map[string]int{"zebra": 1, "alpha": 2, "mike": 3}
	mo, _ := json.Marshal(m)
	fmt.Printf("FACT7b map key order in marshal: %s\n", mo)
}
