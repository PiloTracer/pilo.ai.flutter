# Stack idiom — Bloc / Cubit

**Licence:** MIT · **Provides:** state management. **Not** dependency injection — pair with `get_it` or `provider`.

Library-independent rules remain binding: [`STATE_MANAGEMENT_STANDARD`](../standards/20260801-STATE_MANAGEMENT_STANDARD.md).

> Verify package versions against pub.dev before writing code.

---

## Packages

| Package | Role | Licence |
|---------|------|---------|
| `flutter_bloc` | Runtime + widgets | MIT |
| `bloc` | Core | MIT |
| `bloc_test` (dev) | Testing helpers | MIT |
| `equatable` **or** `freezed` | Value equality on states and events | MIT |
| `get_it` (+ `injectable`) | DI, since Bloc does not provide it | MIT |

**Value equality is mandatory.** Without it, `emit` of an equal state still notifies, and every listener rebuilds on every emission. This is the single most common performance defect in Bloc codebases.

---

## Bloc or Cubit

| Use | When |
|-----|------|
| **Cubit** | Direct method calls are enough. Simpler, less ceremony, still fully testable |
| **Bloc** | You need the event log — traceability, event transformers (debounce, throttle, droppable), or an audit trail of what the user did |

Start with Cubit. Escalate to Bloc when a concrete need appears. Using Bloc everywhere "for consistency" buys ceremony without benefit on screens that have two intents.

---

## Layout

```
lib/features/<feature>/
  domain/                      # no Bloc imports
  data/
  presentation/
    <screen>/
      <screen>_view.dart
      bloc/
        <screen>_bloc.dart     # or _cubit.dart
        <screen>_event.dart    # Bloc only
        <screen>_state.dart
```

---

## State

Sealed hierarchy, not a flag bag:

```dart
sealed class ProfileState extends Equatable { const ProfileState(); }
final class ProfileLoading   extends ProfileState { ... }
final class ProfileEmpty     extends ProfileState { ... }
final class ProfileOffline   extends ProfileState { ... }
final class ProfileError     extends ProfileState { final Failure failure; ... }
final class ProfileReady     extends ProfileState { final Profile p; final bool isRefreshing; ... }
```

All six UI states must be reachable. `ProfileReady(isRefreshing: true)` covers partial; `ProfileEmpty` is distinct from `ProfileReady` with an empty list only if the SPEC treats them differently — decide, don't drift.

---

## Events

Past-tense facts, not commands: `ProfileRequested`, `ProfileRefreshRequested`, `AvatarUploadRequested`. Naming them as commands (`LoadProfile`) turns the event log into an instruction list and loses the "what did the user do" record that motivated choosing Bloc.

Events carry data; they never carry `BuildContext` or widgets.

---

## Bloc shape

```dart
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._repo) : super(const ProfileLoading()) {
    on<ProfileRequested>(_onRequested);
    on<SearchChanged>(_onSearch, transformer: debounce(300.ms));
  }
  ...
}
```

- One handler per event; handlers are small and delegate to the domain.
- **Event transformers** are Bloc's differentiator: `debounce` for search, `droppable` for submit (prevents double-submission), `restartable` for superseded requests, `sequential` for ordered writes. Choosing the right transformer removes whole classes of race condition — the default is concurrent, which is rarely what you want for user-triggered work.
- Never `emit` after the handler completes. Use `emit.forEach` or `await for` inside the handler for streams.
- `close()` cancels subscriptions.
- Blocs never depend on other Blocs. If two need to coordinate, they both listen to a shared stream from the domain, or the UI orchestrates.

---

## Widgets

| Widget | Use |
|--------|-----|
| `BlocBuilder` | Rebuild on state change |
| `BlocSelector` | Rebuild on **one field** — prefer this in leaves |
| `BlocListener` | Effects: snackbar, navigation, dialog |
| `BlocConsumer` | Both, when genuinely both |
| `buildWhen` | Narrow rebuilds without a selector |

Effects go through `BlocListener`, never through a state field that says "show a snackbar" — that fires again on every rebuild.

---

## Testing

```dart
blocTest<ProfileBloc, ProfileState>(
  'emits [Loading, Ready] when the profile loads',
  build: () => ProfileBloc(FakeProfileRepository()),
  act: (bloc) => bloc.add(const ProfileRequested()),
  expect: () => [const ProfileLoading(), isA<ProfileReady>()],
);
```

`bloc_test` asserts the **sequence**, which is exactly the property that matters: an intermediate loading state that never appears is a real bug that a final-state assertion cannot catch.

---

## Traps

| Trap | Consequence |
|------|-------------|
| States without value equality | Every emission rebuilds everything |
| Emitting after the handler returns | Runtime error |
| Bloc depending on another Bloc | Untestable coupling, ordering bugs |
| Events named as commands | Loses the audit-log benefit |
| Default concurrent transformer on submit | Double submission |
| Effects modelled as state | Snackbar re-fires on rebuild |
| `BlocBuilder` at the top of a large tree | Rebuild storms — use `BlocSelector` lower |
| Not closing the Bloc | Leaked subscriptions |
| Business logic in the handler instead of the domain | Untestable without the Bloc |
| One giant Bloc per feature | Becomes a god object nobody can reason about |
