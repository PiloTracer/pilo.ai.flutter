# Stacks — idiom guides per state-management choice

`@flutter-stack` locks the technology stack; these files describe **how to write code correctly in the chosen idiom**. Skills read the locked stack's file before generating code, so that `@flutter-scaffold` and `@flutter-implementation` produce code that looks like it belongs in that ecosystem rather than a generic translation.

| Stack | File | Use when |
|-------|------|----------|
| Riverpod | [`riverpod.md`](riverpod.md) | Compile-safe DI + state in one system; team comfortable with codegen |
| Bloc | [`bloc.md`](bloc.md) | Explicit event→state modelling, strong traceability, large teams |
| Provider + ChangeNotifier | [`provider.md`](provider.md) | Small app, minimal concepts, team new to Flutter |
| Signals | [`signals.md`](signals.md) | Fine-grained reactivity, minimal boilerplate |

**No file for your choice?** The rules in [`STATE_MANAGEMENT_STANDARD`](../standards/20260801-STATE_MANAGEMENT_STANDARD.md) are library-independent and binding regardless. Write the idiom file as part of foundation P2 and add it here.

---

## Choosing

There is no best answer, and the framework does not pretend otherwise. The decision is dominated by two factors that have nothing to do with the libraries' merits:

1. **What the team already knows.** A team fluent in Bloc ships faster with Bloc than with a theoretically superior alternative they are learning on a deadline.
2. **What the project will look like in two years.** Boilerplate that feels heavy in month one is documentation in month twenty.

`@flutter-stack probe` asks about both before recommending.

| Dimension | Riverpod | Bloc | Provider | Signals |
|-----------|----------|------|----------|---------|
| Boilerplate | Low with codegen | High | Low | Lowest |
| Learning curve | Medium | Medium–high | Low | Low |
| Compile-time safety | High | Medium | Low | Medium |
| Testability | Excellent | Excellent | Good | Good |
| Traceable state history | Manual | **Built in** | Manual | Manual |
| DI included | **Yes** | No | Partially | No |
| Codegen required | Recommended | No | No | No |
| Ecosystem maturity | High | **Highest** | High | Growing |
| Team scale fit | Any | **Large** | Small | Small–medium |

All four are MIT or BSD licensed, free, and permitted for commercial use.

---

## What every idiom file contains

1. Package set with licences.
2. Where each layer's code lives, mapped to `DIRECTORY_MAP`.
3. The canonical ViewModel/Notifier/Bloc shape, with the six UI states.
4. How dependencies are provided and overridden in tests.
5. Async state, cancellation and stale-response handling.
6. The testing pattern.
7. The idiom's specific traps.

---

## Rules that hold regardless of the choice

These come from [`STATE_MANAGEMENT_STANDARD`](../standards/20260801-STATE_MANAGEMENT_STANDARD.md) and no stack overrides them:

- Business logic never in a widget.
- The state layer never imports Flutter widgets or holds a `BuildContext`.
- State objects are immutable with value equality.
- All six UI states are expressible.
- Everything created is disposed.
- Effects are one-shot, never persistent state.
- Every dependency is overridable in a test without patching a global.

**The stack is locked, not eternal.** Changing it after implementation starts is a re-architecture, not a preference change — `@flutter-stack` requires a recorded ADR and a migration plan.
