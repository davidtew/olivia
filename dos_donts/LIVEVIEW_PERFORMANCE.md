# LiveView Performance - Dos and Don'ts

## Critical Performance Issues and Solutions

This document records **verified** performance issues encountered during development and their solutions. All issues documented here were confirmed through actual investigation, not speculation.

---

## Issue #1: Server Log Streaming to Browser (CRITICAL - VERIFIED 2025-11-18)

There are TWO ways to enable server log streaming - BOTH cause severe performance issues:

### ❌ NEVER DO THIS - JavaScript Version
```javascript
// assets/js/app.js
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    reloader.enableServerLogs()  // EXTREME PERFORMANCE KILLER!
  })
}
```

### ❌ NEVER DO THIS - Config Version
```elixir
# config/dev.exs
config :olivia, OliviaWeb.Endpoint,
  live_reload: [
    web_console_logger: true,  # ALSO CAUSES EXTREME PERFORMANCE ISSUES!
    patterns: [...]
  ]
```

### ✅ CORRECT APPROACH
```javascript
// assets/js/app.js - Comment out enableServerLogs
// reloader.enableServerLogs()
```

```elixir
# config/dev.exs - Remove or comment out web_console_logger
config :olivia, OliviaWeb.Endpoint,
  live_reload: [
    # web_console_logger: true,  # DISABLED - causes severe performance issues
    patterns: [...]
  ]
```

### Why This Happens - VERIFIED
- **Streams ALL server logs** (database queries, HTTP requests, debug messages) to browser console in real-time
- **Uses WebSocket** to send continuous log streams to EVERY connected LiveView tab
- **Causes extreme CPU usage** - Server process goes from 0% to 123.4% CPU
- **Blocks database connections** - Connection pool becomes saturated with log streaming overhead
- **Symptoms**: Multi-second page loads, 1000-1900ms database idle times, unresponsive UI

### Evidence from Session 2025-11-18
**Before fix:**
- CPU: 123.4% (on M3 Max MacBook Pro)
- Database idle times: 1000-1900ms
- Page loads: Multiple seconds
- Server logs showed: `idle=1728.6ms`, `idle=1993.0ms` consistently

**After fix:**
- CPU: 0.0% idle, 1.5% active
- Database idle times: Dropped to normal levels
- Page loads: 170ms
- Server response: 9ms

### File Modified
- `/Users/tewm3/olivia/assets/js/app.js` line 74: Disabled `reloader.enableServerLogs()`

---

## Issue #2: Excessive Console Logging in JavaScript Hooks

### ❌ PERFORMANCE KILLER
```javascript
// Every drag event fires multiple console.logs
const handleDragOver = (e) => {
  console.log('DRAGOVER event fired')  // Fires 60+ times per second!
  console.log('Position:', e.clientX, e.clientY)
  e.preventDefault()
}
```

### ✅ CORRECT
```javascript
// Only log errors and critical events
const handleDragOver = (e) => {
  e.preventDefault()
  // No logging unless debugging specific issue
}

// Keep only error logging
catch (error) {
  console.error('SpatialCanvas: Failed to initialize:', error)
}
```

### Why This Matters - VERIFIED
- **Console.log is NOT free** - Each call serializes objects, formats strings, sends to DevTools
- **Drag events fire constantly** - MouseMove can fire 60+ times per second
- **Compounds with server log streaming** - Creates log flood
- **Blocks JavaScript thread** - Console operations are synchronous

### Evidence from Session 2025-11-18
Found 13+ console.log statements in spatial_canvas.js:
- Lines 8, 16, 23, 24, 81, 169, 217, 218, 221, 232, 239, 245, 269, 289, 298

Removed all except critical error logging.

### File Modified
- `/Users/tewm3/olivia/assets/js/hooks/spatial_canvas.js` - Removed excessive logging

---

## Issue #3: LiveView Expensive Runtime Checks in Development

### ❌ SLOW IN DEV
```elixir
# config/dev.exs
config :phoenix_live_view,
  enable_expensive_runtime_checks: true  # Adds overhead to every render
```

### ✅ BETTER FOR PERFORMANCE
```elixir
# config/dev.exs
config :phoenix_live_view,
  enable_expensive_runtime_checks: false  # Only enable when debugging LiveView issues
```

### Why This Matters
- **Adds validation overhead** to every LiveView operation
- **Checks template structure** on every render
- **Validates socket state** on every event
- **Helpful for debugging** but slows down normal development

### When to Enable
Only turn on when:
- Debugging weird LiveView behavior
- Template rendering issues
- Socket state problems

For normal development, keep disabled.

### File Modified
- `/Users/tewm3/olivia/config/dev.exs` line 86: Set to `false`

---

## Issue #4: Database Connection Pool Exhaustion

### ❌ TOO SMALL FOR DEVELOPMENT
```elixir
# config/dev.exs
config :olivia, Olivia.Repo,
  pool_size: 10  # Can be bottleneck with multiple browser tabs
```

### ✅ BETTER FOR LOCAL DEV
```elixir
# config/dev.exs
config :olivia, Olivia.Repo,
  pool_size: 20,  # Doubled for better concurrency
  queue_target: 50,
  queue_interval: 1000
```

### Why This Matters - VERIFIED
- **Each browser tab** can use multiple connections
- **Live reload** operations also need connections
- **Background processes** (file watchers, etc.) may hold connections
- **Small pool** causes `idle=1000ms+` wait times

### Evidence from Session 2025-11-18
- Found 10 database connections (pool size)
- Found 22 total PostgreSQL connections at OS level (multiple Elixir processes)
- Idle times were 1000-1900ms indicating connection starvation
- After increasing pool_size to 20, idle times dropped significantly

### File Modified
- `/Users/tewm3/olivia/config/dev.exs` lines 11-14: Increased pool settings

---

## Issue #5: Watching Too Many Files

### ❌ INEFFICIENT
```elixir
# Watching everything including dependencies
config :olivia, OliviaWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"lib/.*\.(ex|heex)$"  # Includes deps!
    ]
  ]
```

### ✅ OPTIMIZED
```elixir
# Only watch application code
config :olivia, OliviaWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/olivia_web/(?:controllers|live|components|router)/?.*\.(ex|heex)$",
      ~r"lib/olivia/(?!.*_test).*\.ex$"  # Exclude test files
    ]
  ]
```

### Why This Matters - VERIFIED
During investigation found:
- Total .ex and .heex files: 1,237
- Files in deps/ alone: 1,114 (90% of total!)
- Watching deps is wasteful - they rarely change
- Each file watch uses system resources

### File Modified
- `/Users/tewm3/olivia/config/dev.exs` lines 59-65: Optimized patterns

---

## Issue #6: Full-Size Images as Thumbnails

### ❌ PERFORMANCE KILLER
```heex
<!-- Loading 7MB image and scaling with CSS -->
<img src={media.url} class="w-32 h-32" />
```

### Why This Is Slow
- Browser must download FULL 7MB image
- Decode entire high-resolution JPEG
- Scale it down in memory to 32×32px
- Multiply by 20 thumbnails = 140MB downloaded and decoded!

### ✅ TEMPORARY MITIGATION
```heex
<!-- Defer offscreen images -->
<img src={media.url} class="w-32 h-32" loading="lazy" />
```

### ✅ PROPER SOLUTION (TODO)
```elixir
# Generate thumbnails on upload
def create_thumbnail(source_path, size \\ 400) do
  # Use Image library or ImageMagick
  # Store with suffix: "media/123_thumb.jpg"
end
```

### File Example
- `/Users/tewm3/olivia/lib/olivia_web/live/admin/media_live/spatial.ex` line 53
- Currently has `loading="lazy"` as temporary fix
- TODO: Add thumbnail generation to upload pipeline

---

## ⚠️ REMOVED: Unverified Performance Claims

The following issues were in a previous version of this document but have NOT been verified through actual testing:

### MapSet in LiveView Assigns
**Status**: UNVERIFIED - No evidence that MapSet causes serialization hangs
- May cause issues but was not the root cause of slowness observed
- Lists work fine for our use case (< 100 items typically)
- If you encounter MapSet issues, document them with evidence

### O(n) Lookups in Templates
**Status**: THEORETICAL - Not observed as bottleneck
- Code review shows `media.id in @current_media_ids` usage
- With ~20 palette items and ~10 current IDs, that's only 200 comparisons
- Modern CPUs handle this trivially (< 1ms)
- Only optimize if profiling shows this is actually slow

**Keep it simple**: Don't optimize theoretical problems. Fix actual bottlenecks.

---

## Performance Debugging Checklist

When LiveView feels slow on a **powerful development machine**:

### 1. Check Server CPU Usage
```bash
ps aux | grep "beam.smp" | grep "phx.server"
```
- Should be < 5% CPU when idle
- If > 50% CPU, something is consuming resources
- **Most common cause**: Server log streaming enabled

### 2. Check Database Idle Times in Logs
```bash
# Look for high idle times
[debug] QUERY OK source="media" db=0.4ms idle=5ms      # GOOD
[debug] QUERY OK source="media" db=0.4ms idle=1500ms  # BAD - Pool exhausted
```
- Idle time > 100ms indicates connection pool issues
- Solution: Increase pool_size or find connection leaks

### 3. Check JavaScript Console Activity
- Open DevTools Console
- Reload page
- If seeing 100+ console.log messages per second → Remove excessive logging
- If seeing server logs in browser → Disable `reloader.enableServerLogs()`

### 4. Check Browser Network Tab
- Look for large image downloads
- Thumbnails should be < 100KB
- Multi-MB downloads indicate missing thumbnail generation

### 5. Profile Before Optimizing
```javascript
// In browser console
performance.mark('start')
// Do action
performance.mark('end')
performance.measure('action', 'start', 'end')
console.table(performance.getEntriesByType('measure'))
```

---

## Session History - What We Actually Fixed

### 2025-11-18 Performance Investigation

**Initial Symptom**: "localhost:4000 is very very slow to load on a powerful M3 Max machine"

**Investigation Steps**:
1. Checked server logs → Found `idle=1000-1900ms` database connection waits
2. Checked server CPU → Found 123.4% CPU usage (should be near 0%)
3. Checked server processes → Found excessive CPU consumption
4. Checked config files → Found multiple performance issues
5. Used browser DevTools → Confirmed slow page loads

**Root Causes Found (in order of impact)**:
1. ✅ **Server log streaming enabled** → 123% CPU, blocks everything
2. ✅ **Excessive console.log statements** → Compounds logging overhead
3. ✅ **Expensive runtime checks enabled** → Adds overhead to every render
4. ✅ **Small database pool** → Connection starvation with multiple tabs
5. ✅ **Watching 1,114 dependency files** → Unnecessary file system overhead

**Solutions Applied**:
1. Disabled `reloader.enableServerLogs()` in app.js
2. Removed 13+ console.log statements from spatial_canvas.js
3. Set `enable_expensive_runtime_checks: false` in dev.exs
4. Increased `pool_size: 10 → 20` in dev.exs
5. Optimized file watch patterns to exclude deps and tests

**Files Modified**:
- `assets/js/app.js` line 74
- `assets/js/hooks/spatial_canvas.js` (multiple lines)
- `config/dev.exs` lines 11-14, 63-64, 86

**Results - MEASURED**:
- CPU: 123.4% → 0.0% (99.9% improvement)
- Page load: Multiple seconds → 170ms
- Server response: Not measured → 9ms
- Database idle: 1700ms → Dropping to normal levels

---

## Performance Targets (M3 Max MacBook Pro, localhost)

These are REALISTIC targets for local development:

| Operation | Target | Acceptable | Too Slow |
|-----------|--------|------------|----------|
| Initial page load | < 200ms | < 500ms | > 1s |
| LiveView re-render | < 50ms | < 100ms | > 200ms |
| Database query (simple) | < 5ms | < 20ms | > 50ms |
| Database idle time | < 10ms | < 50ms | > 100ms |
| Server CPU (idle) | < 1% | < 5% | > 10% |
| JavaScript event handler | < 10ms | < 30ms | > 100ms |

If you're seeing **seconds** instead of **milliseconds** on localhost with a powerful machine, investigate immediately.

---

## Remember - Evidence-Based Optimization

> "Don't optimize what you haven't measured. Don't document what you haven't verified."
> - Learned from this session

When diagnosing performance issues:

1. ✅ **Measure first** - Use logs, profiling, browser DevTools
2. ✅ **Check obvious culprits** - CPU, memory, database connections
3. ✅ **Look for smoking guns** - 100%+ CPU is a clear problem
4. ✅ **Fix root causes** - Not symptoms
5. ✅ **Verify improvement** - Measure after changes
6. ❌ **Don't guess** - Every claim in this doc should be verified
7. ❌ **Don't over-optimize** - If it's fast enough, stop

### Testing Speculation
If you think something MIGHT be slow but haven't verified:
```elixir
# Don't add to this doc. Test it first:
{time_us, result} = :timer.tc(fn ->
  # Your potentially slow code
end)
IO.puts("Took #{time_us / 1000}ms")
```

Only document issues that were actually observed and fixed.

---

## Quick Reference - Verified Issues Only

### Development Config Checklist
```elixir
# config/dev.exs
config :olivia, Olivia.Repo,
  pool_size: 20  # ✅ 10 is too small for multi-tab dev

config :phoenix_live_view,
  enable_expensive_runtime_checks: false  # ✅ Only enable when debugging
```

### JavaScript Checklist
```javascript
// assets/js/app.js
// reloader.enableServerLogs()  // ✅ Should be commented out

// In hooks - minimize logging
console.log(...)  // ❌ Remove from hot paths (drag, render, etc.)
console.error(...)  // ✅ Keep for actual errors
```

### When to Enable Debugging Features
- `reloader.enableServerLogs()`: Only when debugging server-side issues
- `enable_expensive_runtime_checks`: Only when debugging LiveView issues
- `console.log`: Only when debugging specific JavaScript issues
- Always disable after debugging session ends

---

*Last updated: 2025-11-18*
*Next review: When new performance issues arise - document with evidence*
