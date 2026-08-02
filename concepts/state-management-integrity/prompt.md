# FLS-02 — State-management integrity

**Fires:** ViewModels, providers, notifiers, blocs, state classes, disposal, widget state.
**Standard:** [`STATE_MANAGEMENT_STANDARD`](../../standards/20260801-STATE_MANAGEMENT_STANDARD.md).

---

## Why

State bugs are the ones that reach production, because they only appear on the paths nobody clicked during review: rotate the device, background the app, tap twice quickly, lose the network mid-request, navigate away while loading. Each of these is a state-machine question, and each is invisible in a happy-path demo.

---

## Questions

**Classification**

1. For each new piece of state: is it ephemeral UI, screen state, shared app state, persisted state, or an effect? Is the mechanism correct for that kind?
2. Is anything scoped more broadly than it needs to be? Why?
3. Are any effects (snackbars, dialogs, navigation) modelled as persistent state? What happens on rebuild or rotation?

**State shape**

4. How many combinations can the state class represent, and how many are actually valid? List any representable-but-impossible combination.
5. Are loading, empty, partial, error, offline and success all expressible? Which are missing?
6. Is the state immutable with value equality? Is `copyWith` correct for nullable fields — can a field be set back to null?

**ViewModel discipline**

7. Does it import Flutter, hold a `BuildContext`, or touch the widget tree? (Blocker.)
8. Does it depend on anything other than domain interfaces?
9. Are there public setters or exposed mutable internals?
10. Does it handle its own errors, or can a repository failure escape into the widget tree?
11. Can it be tested without pumping a widget?

**Widgets**

12. Does any widget contain a business rule, or a data transformation beyond formatting?
13. Is any work started in `build`, in a constructor, or on every rebuild?
14. Is any `setState` after an `await` unguarded by `mounted`?
15. Is derived state stored in the widget instead of computed in the state layer?

**Lifecycle**

16. Is everything created also disposed — controllers, subscriptions, timers, focus nodes, listeners?
17. What happens to an in-flight request when the screen is disposed? Is the result dropped, or does it touch disposed state?
18. Are stale responses discarded when a newer request has superseded them?
19. What happens when the app is backgrounded mid-operation and resumed ten minutes later?

**Rebuilds**

20. Does any leaf widget watch state far wider than it reads?
21. Are there `Widget _buildX()` methods that should be widget classes?
22. Are `const` constructors used everywhere they can be?
23. Was the rebuild count actually observed, or is this a static judgement? (Say which.)

---

## Output

| # | Severity | File:line | Finding | Consequence |
|---|----------|-----------|---------|-------------|

Plus a state-space table for each new state class: representable combinations versus valid ones.

---

## Verdict rules

| Condition | Severity |
|-----------|----------|
| `BuildContext` or Flutter import in a ViewModel | blocker |
| Missing disposal of a subscription, controller or timer | blocker |
| `setState` after `await` without `mounted` | blocker |
| A required UI state is not expressible | blocker |
| Business logic in a widget | major |
| Impossible-but-representable state combinations | major |
| Work started in `build` | major |
| Stale responses not discarded | major |
| Effect modelled as persistent state | major |
| Over-broad state watching | minor unless measured |
