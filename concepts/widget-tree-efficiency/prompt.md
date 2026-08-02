# FLS-01 — Widget-tree efficiency

**Fires:** widget trees, lists, `build` methods, animations, images.
**Standard:** [`PERFORMANCE_STANDARD`](../../standards/20260801-PERFORMANCE_STANDARD.md) §3, [`FLUTTER_CONVENTIONS`](../../standards/20260801-FLUTTER_CONVENTIONS.md) §4.

**This concept produces hypotheses, not verdicts.** A static finding says "this pattern usually costs frames"; only a profile-mode measurement on the reference device says it does here. Route measurement to `@flutter-perf profile`.

---

## Questions

**Build cost**

1. Does any `build` method do work beyond composing widgets — I/O, parsing, sorting, expensive allocation, `Future` creation, side effects?
2. Are there `Widget _buildX()` helper methods? Each one rebuilds with its parent; a widget class does not.
3. Are `const` constructors used everywhere they can be? List the ones that could be and are not.
4. How deep is the tree in the changed widgets? Is anything past the nesting limit?
5. Is any expensive value recomputed on every build instead of being cached or derived upstream?

**Lists**

6. Is every unbounded list builder-based? Any `ListView(children: [...])` with a variable-length list is a blocker.
7. Do uniform lists provide `itemExtent` or `prototypeItem`?
8. Are list items shallow and `const` where possible?
9. Do items contain `Opacity`, `ClipRRect` with non-trivial shapes, `ShaderMask`, or shadows — anything that triggers `saveLayer` per frame?
10. Is the list paginated, or can it grow without bound?
11. Does changing one item rebuild the whole list?

**Images**

12. Is every image decoded at display size (`cacheWidth`/`cacheHeight`)? The decoded bitmap, not the file, occupies memory.
13. Are network images cached, bounded and placeholdered?
14. Is any full-resolution image being rendered into a thumbnail?

**Rebuild scope**

15. What triggers a rebuild of each changed widget, and how large is the resulting subtree?
16. Does any leaf watch state far wider than it reads?
17. Is `AnimatedBuilder`'s `child` used to hold the non-animating subtree out of the rebuild?
18. Is there a `RepaintBoundary` around independently-animating content?

**Layout**

19. Is `MediaQuery.of(context).size` used for layout where `LayoutBuilder` and constraints belong?
20. Are there intrinsic-dimension calls or unbounded-constraint workarounds in a scroll region?
21. Any nested scroll views that force full-child layout?

**Animation**

22. Is every animation controller disposed?
23. Do animations run when off-screen or when the app is backgrounded?
24. Is reduce-motion respected?

---

## Output

| # | Severity | File:line | Pattern | Hypothesised cost | Measured? |
|---|----------|-----------|---------|-------------------|-----------|

The **Measured?** column is the point. Mark every row `no` unless a profile run backs it, and route those rows to `@flutter-perf`.

---

## Verdict rules

| Condition | Severity |
|-----------|----------|
| Non-lazy list of variable length | blocker |
| Work in `build` (I/O, parsing, side effects) | blocker |
| Undisposed animation controller | blocker |
| Full-resolution image in a small widget | major |
| `saveLayer` trigger inside a scrolling list item | major |
| Missing `const` on a frequently-rebuilt widget | major |
| `_buildX()` methods in a hot path | major |
| Missing `itemExtent` on a long uniform list | minor |
| Deep nesting without extraction | minor |

**Never claim an improvement without a before-and-after measurement under identical conditions.** An optimisation with no measured delta is a refactor with a story attached.
