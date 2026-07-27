// app.js - the ONLY impure module: opens network connections, owns the
// browser-side bounded state (rendered snapshot, connection status,
// last-applied seq - docs/contracts/state-ledger.md's "Browser-side
// bounded state" note), and drives dom-writer.js. Every decision this file
// makes is delegated to a pure module (compose.js, ingest.js,
// sse-protocol.js, render.js, lanes.js, vocab.js, validate.js) so the
// decisions themselves stay unit-testable without a browser.
//
// Consumes ONLY /api/snapshot, /api/stream, and /schema/yard-snapshot.schema.json
// - never the store, never the fold directly (this car's binding scope).
import { createValidator } from './validate.js';
import { initialIngestState, applyIncomingPayload, VALIDATION_FAILED_CODE } from './ingest.js';
import { buildBoardViewModel } from './render.js';
import { renderBoard } from './dom-writer.js';
import { splitFrames, classifyFrame, createDisconnectWatchdog } from './sse-protocol.js';
import { SSE_EVENT_NAME } from './wire-constants.js';
import { loadOpenState, saveOpenState, withGroupOpen, withStripOpen } from './condition-open-state.js';

const root = document.getElementById('board-root');

let ingestState = initialIngestState();
let connected = false;

function repaint() {
  if (!ingestState.snapshot) return; // nothing validated yet - first paint waits for it
  const vm = buildBoardViewModel(ingestState.snapshot, ingestState.clientConditions);
  // #69: read fresh from sessionStorage on EVERY repaint, never a stale
  // in-memory mirror - this is what makes the strip's open state survive
  // both a DOM rebuild (repaint fires on every applied snapshot/connection
  // change, tearing down and rebuilding the whole tree) and a page refresh
  // (sessionStorage itself outlives this module's in-memory state)
  // IDENTICALLY, from the same single source of truth. handleConditionToggle
  // below is the only writer; this is the only reader.
  const openState = loadOpenState(window.sessionStorage);
  renderBoard(document, root, vm, { connected }, openState);
}

// #69 (owner fast-follow: "closes back up every page refresh"): a native
// <details> element's 'toggle' event does NOT bubble (HTML living
// standard), so a single delegated listener on `root` must be attached in
// the CAPTURING phase (the third `addEventListener` argument) - capturing
// reaches every descendant on the way DOWN to the event's target
// regardless of that event's own bubbles flag, which is the standard
// workaround for non-bubbling events. Reading event.target.open (the real
// DOM boolean the browser just updated) rather than re-deriving state from
// attributes avoids a second, fuzzier read of the same fact (Law 6).
function handleConditionToggle(event) {
  const target = event.target;
  if (!target || typeof target.hasAttribute !== 'function') return;
  let state = loadOpenState(window.sessionStorage);
  if (target.hasAttribute('data-conditions-strip')) {
    state = withStripOpen(state, target.open);
  } else if (target.hasAttribute('data-condition-code')) {
    state = withGroupOpen(state, target.getAttribute('data-condition-code'), target.open);
  } else {
    return; // not one of ours - never react to an unrelated <details>/<summary> toggle
  }
  saveOpenState(window.sessionStorage, state);
}

function handlePayloadText(rawText, validator) {
  let parsed;
  try {
    parsed = JSON.parse(rawText);
  } catch (err) {
    // Not even valid JSON - treat identically to a schema-validation
    // failure (discard, mark stale, disclose) rather than a silent parse
    // exception the honesty chrome never learns about.
    ingestState = {
      ...ingestState,
      markedStale: true,
      clientConditions: [
        { code: VALIDATION_FAILED_CODE, detail: `a received payload was not valid JSON: ${err.message}`, register: 'needs-attention' }
      ]
    };
    repaint();
    return;
  }
  ingestState = applyIncomingPayload(ingestState, parsed, validator);
  repaint();
}

async function firstPaint(validator) {
  const resp = await fetch('/api/snapshot');
  const text = await resp.text();
  handlePayloadText(text, validator);
}

async function streamLoop(validator) {
  const watchdog = createDisconnectWatchdog({
    heartbeatMs: (ingestState.snapshot && ingestState.snapshot.config.heartbeatMs) || 5000,
    onDisconnect: () => {
      connected = false;
      repaint();
    }
  });

  for (;;) {
    try {
      const resp = await fetch('/api/stream');
      const reader = resp.body.getReader();
      const decoder = new TextDecoder();
      let buffer = '';
      connected = true;
      watchdog.noteFrame();
      repaint();

      for (;;) {
        const { value, done } = await reader.read();
        if (done) break;
        buffer += decoder.decode(value, { stream: true });
        const { frames, leftover } = splitFrames(buffer);
        buffer = leftover;
        for (const rawFrame of frames) {
          const frame = classifyFrame(rawFrame);
          // ANY frame - heartbeat or data - resets the watchdog
          // (gating-matrix.md's Disconnect row - cited by row name, not
          // line, since that row has already moved once).
          watchdog.noteFrame();
          if (!connected) {
            connected = true;
            repaint();
          }
          if (frame.type === 'event' && frame.event === SSE_EVENT_NAME) {
            handlePayloadText(frame.data, validator);
          }
        }
      }
    } catch (err) {
      // A network-level failure (server restart, connection reset) - the
      // watchdog will also fire on its own timer if this loop stalls
      // instead of throwing; either path converges on the same
      // disconnected-showing-last-known state.
      connected = false;
      repaint();
    }
    // Simple retry backoff for v0 - reconnect after one poll interval
    // rather than hammering a dead server in a tight loop.
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }
}

async function main() {
  // #69: attached ONCE, before the first paint - `root` itself is never
  // replaced (only its children are, on every repaint), so a single
  // capturing-phase listener here outlives every DOM rebuild for the rest
  // of the tab's life.
  root.addEventListener('toggle', handleConditionToggle, true);

  const schemaResp = await fetch('/schema/yard-snapshot.schema.json');
  const schema = await schemaResp.json();
  const validator = createValidator(schema);

  await firstPaint(validator);
  streamLoop(validator);
}

main();
