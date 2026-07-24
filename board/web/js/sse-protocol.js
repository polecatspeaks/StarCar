// sse-protocol.js - pure SSE-over-text-stream parsing plus the heartbeat-
// aware disconnect watchdog (design rev 5 S5.6; gating-matrix.md's
// Disconnect row: "resets on: any frame arriving, data or heartbeat";
// "fires when: two consecutive heartbeatMs intervals pass with no frame").
//
// DISCLOSED DEVIATION from D19's literal choice of `EventSource`
// (docs/design/2026-07-21-v0-yard-skeleton-design.md:133 - "View is
// framework-free vanilla JS + EventSource, no build step"): the server
// writes its heartbeat as a bare SSE COMMENT line
// (board/server/sse.go:75-77, `fmt.Fprint(w, ": heartbeat\n\n")`). The
// browser's native EventSource delivers comment-only frames to NO event
// listener at all (per the SSE spec, a line starting with ":" is ignored
// by the event-stream processing algorithm beyond resetting the
// reconnection timer's internal bookkeeping) - so a page built on
// EventSource literally cannot observe a heartbeat arriving, and
// gating-matrix.md:43's own rule ("resets on: any frame arriving, data OR
// heartbeat") is unimplementable against that API's public surface.
//
// This module reads the raw response body (fetch + ReadableStream) instead
// - still vanilla JS, still no bundler, no framework, no build step (D19's
// underlying rationale, review-attention cost, is unaffected: this is
// browser-native fetch/ReadableStream, not a dependency) - so every frame,
// heartbeat or named event, is visible to the watchdog. app.js is the only
// caller that actually opens a network connection; everything in this file
// is pure and Node-testable with no network at all.

/**
 * Splits a text buffer into complete SSE frames (delimited by a blank line
 * per the SSE wire format) plus whatever trailing partial frame has not
 * yet been terminated by a blank line.
 *
 * @param {string} buffer
 * @returns {{frames: string[], leftover: string}}
 */
export function splitFrames(buffer) {
  const parts = buffer.split('\n\n');
  const leftover = parts.pop() ?? '';
  return { frames: parts, leftover };
}

/**
 * Classifies one already-delimited SSE frame.
 *
 * @param {string} rawFrame
 */
export function classifyFrame(rawFrame) {
  const lines = rawFrame.split('\n');
  let event = null;
  const dataLines = [];
  let isHeartbeat = false;

  for (const line of lines) {
    if (line.startsWith(':')) {
      isHeartbeat = true;
      continue;
    }
    if (line.startsWith('event:')) {
      event = line.slice('event:'.length).trim();
      continue;
    }
    if (line.startsWith('data:')) {
      dataLines.push(line.slice('data:'.length).trim());
    }
  }

  if (event) {
    return { type: 'event', event, data: dataLines.join('\n') };
  }
  if (isHeartbeat) {
    return { type: 'heartbeat' };
  }
  // Never silently drop an unrecognised frame shape uninspected - the
  // caller decides what to do with it (today: ignore it, but visibly, not
  // by construction).
  return { type: 'unknown', raw: rawFrame };
}

/**
 * The client-side half of the disconnect gating-matrix row
 * (docs/contracts/gating-matrix.md:43): "two consecutive heartbeatMs
 * intervals pass with no frame" fires `onDisconnect`; "any frame arriving,
 * data or heartbeat" resets the timer and clears the disconnected mark.
 *
 * Uses the GLOBAL setTimeout/clearTimeout so tests can drive it
 * deterministically with `node:test`'s built-in `t.mock.timers` rather than
 * real wall-clock waits (real timers are flake-prone; see this repo's own
 * disclosed note on board/server's poll ticker for the same tradeoff).
 *
 * @param {{heartbeatMs: number, onDisconnect: () => void}} args
 */
export function createDisconnectWatchdog({ heartbeatMs, onDisconnect }) {
  let timer = null;
  let disconnected = false;

  function arm() {
    clearTimeout(timer);
    timer = setTimeout(() => {
      disconnected = true;
      onDisconnect();
    }, heartbeatMs * 2);
  }

  function noteFrame() {
    disconnected = false;
    arm();
  }

  function isDisconnected() {
    return disconnected;
  }

  function stop() {
    clearTimeout(timer);
  }

  return { noteFrame, isDisconnected, stop };
}
