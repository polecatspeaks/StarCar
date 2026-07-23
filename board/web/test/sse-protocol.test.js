// sse-protocol.js: pure SSE-over-text-stream parsing + a heartbeat-aware
// disconnect watchdog (design rev 5 S5.6 / gating-matrix.md:43 - "resets
// on: any frame arriving, data or heartbeat"; "two consecutive heartbeatMs
// intervals pass with no frame" flips the client to disconnected).
//
// DISCLOSED DEVIATION FROM D19's LITERAL CHOICE (docs/design/2026-07-21-v0-
// yard-skeleton-design.md:133 names `EventSource` explicitly): the server
// writes heartbeats as a bare SSE comment line
// (board/server/sse.go:75-77, `": heartbeat\n\n"`), which the native
// browser EventSource API delivers to NO event listener at all - see this
// car's final report for the full citation trail. This module reads the
// raw text stream instead so heartbeat frames are visible resets, which is
// what gating-matrix.md:43's disconnect row actually requires.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { splitFrames, classifyFrame, createDisconnectWatchdog } from '../js/sse-protocol.js';

test('splitFrames: splits a buffer of complete SSE frames on the blank-line delimiter, keeping a trailing partial frame as leftover', () => {
  const buffer = 'event: yard\ndata: {"seq":1}\n\n: heartbeat\n\nevent: ya';
  const { frames, leftover } = splitFrames(buffer);
  assert.deepEqual(frames, ['event: yard\ndata: {"seq":1}', ': heartbeat']);
  assert.equal(leftover, 'event: ya');
});

test('classifyFrame: a comment-only frame is a heartbeat', () => {
  assert.deepEqual(classifyFrame(': heartbeat'), { type: 'heartbeat' });
});

test('classifyFrame: an "event: yard" frame carries its data payload', () => {
  const frame = classifyFrame('event: yard\ndata: {"seq":1,"lanes":[]}');
  assert.equal(frame.type, 'event');
  assert.equal(frame.event, 'yard');
  assert.equal(frame.data, '{"seq":1,"lanes":[]}');
});

test('classifyFrame: an unrecognised frame with neither a comment nor an event name is "unknown", never silently dropped uninspected', () => {
  const frame = classifyFrame('retry: 3000');
  assert.equal(frame.type, 'unknown');
});

// --- the disconnect watchdog ------------------------------------------

test('LOAD-BEARING: after TWO missed heartbeat intervals with no frame at all, the watchdog fires onDisconnect', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] });
  let disconnectedCount = 0;
  const watchdog = createDisconnectWatchdog({ heartbeatMs: 5000, onDisconnect: () => { disconnectedCount += 1; } });
  watchdog.noteFrame(); // the initial connect frame arms the watchdog
  assert.equal(watchdog.isDisconnected(), false);

  t.mock.timers.tick(9999); // just under two full intervals (10000ms)
  assert.equal(disconnectedCount, 0, 'must not fire before two full heartbeat intervals have elapsed');

  t.mock.timers.tick(2); // crosses the 10000ms (2 * heartbeatMs) threshold
  assert.equal(disconnectedCount, 1);
  assert.equal(watchdog.isDisconnected(), true);
});

test('ANY frame arriving (heartbeat OR data) resets the watchdog and clears a disconnected mark (gating-matrix.md:43)', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] });
  let disconnectedCount = 0;
  const watchdog = createDisconnectWatchdog({ heartbeatMs: 5000, onDisconnect: () => { disconnectedCount += 1; } });
  watchdog.noteFrame();

  t.mock.timers.tick(9000);
  watchdog.noteFrame(); // a heartbeat comment arrives - must reset, even though it carries no "data"
  t.mock.timers.tick(9000);
  assert.equal(disconnectedCount, 0, 'a heartbeat-only frame must reset the watchdog just as a data frame would');

  t.mock.timers.tick(1001); // now past 10000ms since the LAST noteFrame
  assert.equal(disconnectedCount, 1);

  // Reconnect: a fresh frame clears the disconnected mark.
  watchdog.noteFrame();
  assert.equal(watchdog.isDisconnected(), false);
});

test('stop() cancels the pending timer (no leaked timer after the client tears down)', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] });
  let disconnectedCount = 0;
  const watchdog = createDisconnectWatchdog({ heartbeatMs: 5000, onDisconnect: () => { disconnectedCount += 1; } });
  watchdog.noteFrame();
  watchdog.stop();
  t.mock.timers.tick(60000);
  assert.equal(disconnectedCount, 0);
});
