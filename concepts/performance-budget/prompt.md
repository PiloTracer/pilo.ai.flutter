# FLS-08 — Performance budget

**Fires:** startup path, heavy computation, large lists, images, app size, anything with an NFR.
**Standard:** [`PERFORMANCE_STANDARD`](../../standards/20260801-PERFORMANCE_STANDARD.md).

**Distinct from FLS-01:** that concept audits widget-tree patterns. This one asks whether the change holds the **budget** — and requires numbers.

---

## Questions

**Budget applicability**

1. Which NFRs apply to this change? Quote the number, the unit and the reference device.
2. If none applies, why not — and should one exist? A feature on the startup path or the primary scroll surface without a budget is a gap in the plan, not an exemption.

**Startup**

3. Does this change add anything to the startup path? What, and how long does it take?
4. Is anything blocking before the first frame — a network call, a database open, a large file read, plugin initialisation?
5. Could it be deferred to after first frame, or to first interaction?
6. Measured cold start before and after: median and p95, same device, profile mode.

**Runtime**

7. Does this change add per-frame work? Where?
8. Was the critical flow profiled? Frame build and raster times, p99, on the reference device.
9. Janky frame percentage before and after.
10. Any CPU-bound work above the isolate threshold left on the UI isolate?

**Memory**

11. Does this retain anything for the app's lifetime? What, and how large?
12. Are caches bounded with an eviction policy?
13. Heap after `n` cycles of the affected journey — flat or growing?

**Size**

14. Does this add a dependency, an asset, a font weight, or native code? What does it cost in the artifact?
15. Measured size before and after, per ABI.
16. Is the addition justified against the size budget, or does it need the budget renegotiated?

**Network**

17. Payload size for the primary request. Is pagination applied? Is compression on?
18. How does this behave on a slow connection — is the measurement done throttled, or only on office wifi?

**Conditions**

19. Which device, OS version, build mode and Flutter version produced these numbers?
20. How many runs, and what is the spread?
21. What was **not** measured?

---

## Output

| Metric | Budget | Before | After | Device | Mode | Runs | Verdict |
|--------|--------|--------|-------|--------|------|------|---------|

Every unmeasured metric appears in an explicit **Unverified** list. No estimated number enters this table.

---

## Verdict rules

| Condition | Severity |
|-----------|----------|
| A budget is exceeded | blocker |
| Blocking work added before first frame | blocker |
| Unbounded cache or retained collection added | blocker |
| An applicable NFR was not measured | major |
| A number reported from a debug build | major — invalid, re-measure |
| A number reported from a simulator for a mobile budget | major — invalid |
| An optimisation claimed with no before/after | major |
| Size increase without justification | major |
| Measurement from a single run | minor — report the spread |

**Profile mode, real device, repeated runs, reported conditions.** A performance claim missing any of these four is not a measurement, and it will be wrong in the direction that flatters the change.
