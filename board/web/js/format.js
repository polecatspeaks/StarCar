// format.js - #67 (FORMAT NIT, owner 2026-07-26 17:16): the ONE compact-
// clock-time formatter for every duration this board renders (dispatch
// elapsed, freshness ages). Pure, no DOM, no clock reads - takes a value
// already on the wire (or already bucketed server-side per the #27
// contract, untouched by this ticket) and formats it, never computes it.
// Law 6: one function, so a future format tweak (or a bug in it) has
// exactly one place to fix rather than three call sites each reinventing
// "M:SS" slightly differently.
export function formatClockDuration(totalSeconds) {
  // Defensive floor: this board's own callers only ever pass a
  // non-negative integer count of seconds (elapsed_seconds, ageBucketMs/1000
  // - both server-issued, never client-computed per Rule 3), but a stray
  // negative or fractional value must still render SOMETHING sane rather
  // than a garbled string.
  const seconds = Math.max(0, Math.trunc(totalSeconds) || 0);
  const s = seconds % 60;
  const totalMinutes = Math.trunc(seconds / 60);
  const m = totalMinutes % 60;
  const h = Math.trunc(totalMinutes / 60);
  const pad2 = (n) => String(n).padStart(2, '0');
  // Leading empty fields dropped, minimum form M:SS (owner's own examples:
  // 45s -> 0:45; 4m32s -> 4:32; 1h2m3s -> 1:02:03) - hours appear only when
  // non-zero, and minutes are NEVER padded when hours are absent (0:45, not
  // 00:45) so the shortest reading is always the one shown.
  return h > 0 ? `${h}:${pad2(m)}:${pad2(s)}` : `${m}:${pad2(s)}`;
}
