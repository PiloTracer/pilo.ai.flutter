# State management standard — template

> **Template.** Copied to `{FLUTTER_STANDARDS_ROOT}/YYYYMMDD-STATE_MANAGEMENT_STANDARD.md` with `REPLACE:STATE_MANAGEMENT` resolved from `STACK.md`. Library-specific idioms live in [`stacks/`](../stacks/); the rules below are library-independent and binding regardless of the choice.

**Enforced by:** `@flutter-verify` D5, concept FLS-02.

---

## 1. The five kinds of state

Confusing these is the root of most Flutter state bugs. Classify before choosing a mechanism.

| Kind | Example | Lives in | Survives |
|------|---------|----------|----------|
| **Ephemeral UI** | Animation progress, focus, text field content, expansion | `StatefulWidget` | Nothing |
| **Screen state** | The current screen's data, loading and error status | ViewModel scoped to the route | Route lifetime |
| **Shared app state** | Session, current user, feature flags, cart | App-scoped provider/bloc | App lifetime |
| **Persisted state** | Preferences, cached entities, drafts, auth tokens | Local store, exposed via repository | Process death |
| **Ephemeral effects** | Snackbar, dialog, navigation, toast | One-shot event channel, **not** state | Consumed once |

**Effects are not state.** Modelling "show error snackbar" as a boolean in state produces the classic bug where rotating the device shows the snackbar again. Effects are emitted once and consumed once.

Scope state as narrowly as the requirement allows. App-scoped state that only one screen reads is a memory leak and a rebuild source.

---

## 2. State objects

- **Immutable.** `final` fields, value equality, `copyWith`. Mutating state in place defeats every change-detection mechanism.
- **Value equality is mandatory.** Without it, every emission rebuilds every listener.
- **Model the state space, not the fields.** Prefer a sealed hierarchy or an explicit status enum over independent booleans:

```dart
// Wrong: 2^3 = 8 representable combinations, 4 of which are nonsense
class State { final bool isLoading; final User? user; final String? error; }

// Right: exactly the states that exist
sealed class ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileEmpty extends ProfileState {}
class ProfileError extends ProfileState { final Failure failure; ... }
class ProfileReady extends ProfileState { final User user; final bool isRefreshing; ... }
```

If a combination cannot be reached, it should not be representable. Every impossible-but-representable state eventually appears in production.

- **The six states are mandatory** for any surface that loads data: loading, empty, partial, error, offline, success. The SPEC §6 defines each one's appearance; the state type must be able to express each one.

---

## 3. ViewModels / Notifiers / Blocs

Whatever the locked stack calls it, the rules are the same.

- **No Flutter imports.** No `BuildContext`, no widgets, no `ScaffoldMessenger`. A ViewModel that needs `context` has taken on a UI responsibility.
- **Depends on domain interfaces only.** Never on an HTTP client, a database, or another ViewModel.
- **One responsibility.** A ViewModel serving three unrelated screens is three ViewModels.
- **Exposes state and intents.** Public methods are user intents (`submit()`, `refresh()`, `retry()`); private methods do the work.
- **Never exposes mutable internals.** No public setters, no exposed controllers.
- **Handles its own errors.** A failure from a repository is converted into a state, not rethrown into the widget tree.
- **Cancellation-safe.** In-flight work is cancelled or ignored on dispose; results arriving after dispose are dropped without touching state.
- **Testable without a widget.** If testing the ViewModel requires pumping a widget, the boundary is wrong.

---

## 4. Widgets

- **Widgets read state and dispatch intents. Nothing else.** No conditionals encoding business rules, no data transformation beyond formatting.
- **Watch the narrowest slice.** Selecting one field instead of the whole object is the difference between rebuilding one widget and rebuilding a screen.
- **Never trigger work in `build`.** Fetching in `build` re-fetches on every rebuild. Kick off loading in the state layer's initialisation or an explicit lifecycle hook.
- **Do not store derived state in a widget.** Derive it in the state layer and expose it.
- Guard every post-`await` `setState` with `mounted`.

---

## 5. Rebuild discipline

| Rule | Why |
|------|-----|
| `const` constructors everywhere possible | Skips rebuild entirely |
| Extract to widget classes, not builder methods | Enables the element-level rebuild skip |
| Watch narrow slices | Avoids whole-screen rebuilds on one field change |
| Never watch app-scoped state from a leaf that only needs one field | Rebuild storms |
| Put listeners as low in the tree as possible | Smaller rebuild subtree |
| Prefer `ValueListenableBuilder`/selectors over rebuilding the parent | Localises the change |

The verification is empirical, not theoretical: enable rebuild tracking in DevTools and confirm the count. See [`PERFORMANCE_STANDARD`](20260801-PERFORMANCE_STANDARD.md).

---

## 6. Async state

- Every async operation has a **cancellation story**: what happens when the user leaves mid-flight.
- **Stale responses are dropped.** Tag requests and ignore any response that is not the latest — otherwise a slow first request overwrites a fast second one.
- **Debounce user-driven queries** (`REPLACE:DEBOUNCE_MS` ms default) and cancel superseded requests.
- **Refresh is distinct from load.** Refreshing while showing existing data is the "partial" state, not the "loading" state.
- **Optimistic updates declare their rollback** in the SPEC before they are implemented.

---

## 7. Persistence and restoration

- State that must survive process death is persisted through a repository, never written directly from the state layer.
- Restoration is explicit: `RestorationMixin` or an equivalent recorded mechanism for scroll positions, form drafts and navigation.
- Restored state is **validated** before use. A schema change makes yesterday's saved state today's crash.
- Never persist secrets in ordinary state storage — [`SECURITY_PRIVACY_STANDARD`](20260801-SECURITY_PRIVACY_STANDARD.md).

---

## 8. Testing

| Target | Test |
|--------|------|
| ViewModel | Unit test: given repository behaviour, assert the state sequence |
| State transitions | Assert the **sequence**, not just the final value — an intermediate loading state that never appears is a bug |
| Error paths | Every failure type maps to the state the SPEC requires |
| Cancellation | Dispose mid-flight; assert no state emission and no exception |
| Widget binding | Widget test: each state renders the surface the SPEC describes |

A ViewModel with only happy-path tests is untested — the failure paths are the ones users hit.

---

## 9. Anti-patterns

- Business logic in `build`.
- `setState` after `await` without `mounted`.
- A boolean-soup state class with unreachable combinations.
- Global mutable singletons holding app state.
- Passing a ViewModel into another ViewModel.
- Effects modelled as persistent state.
- Fetching in `build` or in a widget constructor.
- Watching an entire large object to read one field.
- `dispose` that does not cancel subscriptions and timers.
- Catching a repository failure in the widget instead of the state layer.
