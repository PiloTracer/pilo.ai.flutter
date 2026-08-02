# Performance standard — template

> **Template.** Copied to `{FLUTTER_STANDARDS_ROOT}/YYYYMMDD-PERFORMANCE_STANDARD.md` with budgets filled from foundation doc 02 (devices) and doc 05 (NFRs).

**Owned by:** `@flutter-perf` · **Enforced by:** `@flutter-verify` D13, concepts FLS-01 and FLS-08.

---

## 1. Budgets before optimisation

A performance requirement without a number is not a requirement. Every budget names the metric, the value, the device and the conditions.

| Metric | Budget | Reference device | Conditions |
|--------|--------|------------------|------------|
| Cold start to first frame | `REPLACE:COLD_START_MS` ms | `REPLACE:REFERENCE_DEVICE_LOW` | Profile mode, after reboot |
| Cold start to interactive | `REPLACE:INTERACTIVE_MS` ms | same | First usable screen |
| Warm start | `REPLACE:WARM_START_MS` ms | same | |
| Frame build+raster | ≤ 16 ms (60 Hz) / ≤ 8 ms (120 Hz) | same | 99th percentile in critical flows |
| Janky frames | ≤ `REPLACE:JANK_PCT`% | same | Scrolling the primary list |
| Scroll at speed | No dropped frames | same | Flinging a `REPLACE:LIST_SIZE`-item list |
| Memory steady state | ≤ `REPLACE:MEM_MB` MB | same | After the primary journey |
| App size (download) | ≤ `REPLACE:SIZE_BUDGET_MB` MB | — | Release, per ABI |
| Network payload (primary screen) | ≤ `REPLACE:PAYLOAD_KB` KB | — | |
| Time to content on 3G | ≤ `REPLACE:TTC_3G_MS` ms | same | Throttled |

**The reference device is the low end of the supported range, not a flagship.** Optimising against a device three years newer than the median user's is how apps ship jank.

---

## 2. Measurement rules

1. **Profile mode only.** Debug-mode numbers are meaningless — assertions, no AOT, no shader warm-up. A performance claim from a debug run is not a measurement.
2. **Real device, not simulator.** The iOS simulator has desktop-class CPU and GPU.
3. **Report the device, OS version, build mode and Flutter version with every number.** A number without its conditions cannot be compared to the next one.
4. **Repeat and report the distribution.** Single runs are noise. Report median and 95th percentile over `REPLACE:PERF_RUNS` runs.
5. **Never report an unmeasured number.** Estimates are labelled estimates and never enter a budget table.
6. **Before and after, or it did not improve.** An optimisation without a measured delta is a refactor with a story attached.

---

## 3. Static audit (hypotheses, not verdicts)

`@flutter-perf audit` finds likely causes. A static finding is a hypothesis until measured.

| Pattern | Why it costs |
|---------|--------------|
| Missing `const` constructors | Rebuilds a subtree that could be skipped entirely |
| `Widget _buildX()` helper methods | Cannot be skipped by the element rebuild check — extract a widget class |
| Non-lazy `ListView(children: [...])` with many children | Builds every child, even off-screen |
| Missing `itemExtent`/`prototypeItem` on long lists | Forces layout of items to compute scroll extent |
| `Opacity`, `ClipRRect`, `ShaderMask` in a scrolling list | Triggers `saveLayer` — expensive per frame |
| Full-size images without `cacheWidth`/`cacheHeight` | Decodes at source resolution into memory |
| Work in `build` | Runs on every frame the widget rebuilds |
| Watching wide state from a leaf | Rebuild storms |
| Synchronous JSON parse of a large payload on the UI isolate | Frame drops proportional to payload size |
| `setState` on a large subtree for a small change | Rebuilds far more than changed |
| Unbounded `AnimatedBuilder` scope | Rebuilds children that do not animate |
| No `RepaintBoundary` around an independently-animating subtree | Repaints the whole layer |

---

## 4. Startup

The startup path is the most scrutinised code in the app because every user pays for it.

- `main()` does the minimum: bind, wire error handlers, `runApp`. Nothing blocking.
- **Nothing blocking before the first frame.** No network call, no database open, no large file read, no plugin initialisation that can be deferred.
- Deferred initialisation is explicit and ordered: what is needed for the first frame, what for the first interaction, what can wait.
- A splash screen that hides a slow start is a mask, not a fix — though a native splash is still required to avoid a blank window.
- Shader jank on first run is addressed via the platform's warm-up mechanism where the target platform needs it.
- **Measure with a trace, not a stopwatch app.** Report the phases.

---

## 5. Lists and scrolling

- Always builder-based (`ListView.builder`, `SliverList`) for anything unbounded.
- Provide `itemExtent` or `prototypeItem` when items are uniform.
- Keep item widgets shallow, `const` where possible, and free of `saveLayer` triggers.
- Images inside items are sized, cached and placeholdered.
- Pagination for anything that can exceed `REPLACE:LIST_PAGE_THRESHOLD` items — "the user will never have that many" is a prediction, and it is usually wrong.
- Avoid rebuilding the whole list when one item changes.

---

## 6. Images and assets

- Decode at display size (`cacheWidth`/`cacheHeight`) — the decoded bitmap, not the file, is what occupies memory.
- Network images cached with a bounded cache and an eviction policy.
- Placeholders and error states on every remote image.
- Prefer vector or an appropriately-compressed raster; provide the resolution variants the platform needs.
- Audit total asset weight against the size budget; unused assets are removed, not left "just in case".

---

## 7. Compute

- Anything above `REPLACE:ISOLATE_THRESHOLD_MS` ms goes off the UI isolate.
- Isolate boundaries transfer plain data; the transfer cost is part of the measurement.
- Streaming or chunked parsing for large payloads.
- Cache expensive derivations; invalidate them explicitly.

---

## 8. App size

- Measure with the platform's size-analysis output per ABI, split per architecture.
- Track size per release; an unexplained jump is a finding.
- The usual causes: unsplit ABIs, uncompressed assets, fonts shipping all weights, a large dependency pulled in for one function, debug symbols in the artifact.
- Tree shaking only works when code is statically reachable — reflection-style dynamic dispatch defeats it.

---

## 9. Memory

- Watch for growth across repeated navigation of the same journey — a flat curve is the goal.
- Common leaks: undisposed controllers, uncancelled subscriptions and timers, retained `BuildContext`, unbounded caches, listeners added without removal.
- Verify with a heap snapshot before and after `REPLACE:LEAK_CYCLES` cycles of the journey.

---

## 10. Report shape

Every performance report states: metric, budget, measured median and p95, device, OS, build mode, Flutter version, number of runs, verdict, and — for an optimisation — the before and after with the same conditions. Anything not measured is listed under **Unverified**.
