# Stack idiom — Provider + ChangeNotifier

**Licence:** MIT · **Provides:** dependency provision and a simple listenable state primitive.

The lowest-concept option: closest to plain Flutter, easiest to teach, and the one with the least protection against misuse. Choose it for small apps and teams new to Flutter; be honest that it scales less well than the alternatives.

Library-independent rules remain binding: [`STATE_MANAGEMENT_STANDARD`](../standards/20260801-STATE_MANAGEMENT_STANDARD.md).

---

## Packages

| Package | Role | Licence |
|---------|------|---------|
| `provider` | InheritedWidget wrapper, DI and scoping | MIT |
| `flutter` (`ChangeNotifier`, `ValueNotifier`) | State primitives | BSD-3 |

---

## Layout

```
lib/features/<feature>/
  domain/                       # no provider imports
  data/
  presentation/
    <screen>/
      <screen>_view.dart
      <screen>_view_model.dart  # extends ChangeNotifier
```

---

## ViewModel shape

```dart
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._repo);
  final ProfileRepository _repo;

  ProfileUiState _state = const ProfileUiState.loading();
  ProfileUiState get state => _state;

  Future<void> load() async { ... _set(newState); }

  void _set(ProfileUiState s) {
    if (_disposed || s == _state) return;   // both guards matter
    _state = s;
    notifyListeners();
  }

  bool _disposed = false;
  @override
  void dispose() { _disposed = true; _sub?.cancel(); super.dispose(); }
}
```

Two guards carry most of the weight here:

- **`if (s == _state) return`** — `ChangeNotifier` has no built-in equality check, so without it every `notifyListeners()` rebuilds listeners even when nothing changed.
- **`_disposed`** — `notifyListeners()` after dispose throws. Async continuations arriving after the user navigated away are the normal case, not an edge case.

Expose a **single immutable state object**, not a scatter of public fields. Public mutable fields plus manual `notifyListeners()` calls is where Provider codebases become unmaintainable — nobody can tell what triggers a rebuild.

---

## Providing

```dart
MultiProvider(providers: [
  Provider<ProfileRepository>(create: (_) => ProfileRepositoryImpl(...)),
  ChangeNotifierProvider(create: (c) => ProfileViewModel(c.read())),
])
```

| Provider | Use |
|----------|-----|
| `Provider` | Immutable dependency |
| `ChangeNotifierProvider` | A ViewModel — **disposes it automatically** |
| `ProxyProvider` | Depends on another provider |
| `StreamProvider` / `FutureProvider` | Async source, but prefer a ViewModel for anything with intents |

Scope ViewModels to the route that uses them, not to the app root. An app-root ViewModel lives forever and holds its data forever.

---

## Consuming

- **`context.watch<T>()` in `build`; `context.read<T>()` in callbacks.** `read` in `build` produces a widget that never updates; `watch` in a callback throws.
- **`context.select<T, R>((t) => t.field)`** to rebuild on one field. This is the primary rebuild control in Provider and it is routinely forgotten.
- `Consumer<T>(builder: ...)` to confine the rebuild to a subtree.
- Effects (snackbar, navigation) via a listener, never inside `build`.
- Never call a ViewModel method during `build`.

---

## Testing

```dart
final vm = ProfileViewModel(FakeProfileRepository());
addTearDown(vm.dispose);
```

Unit-test the ViewModel directly — no widget needed. For widget tests, wrap in `ChangeNotifierProvider.value(value: fakeVm, child: ...)`.

Assert the **sequence** of states by recording them from a listener, not just the final value.

---

## Traps

| Trap | Consequence |
|------|-------------|
| `context.read` in `build` | Widget never updates |
| `context.watch` in a callback | Throws |
| No equality guard before `notifyListeners()` | Rebuilds on every call, including no-ops |
| `notifyListeners()` after dispose | Throws in async continuations |
| Public mutable fields instead of one state object | Untraceable rebuilds |
| App-root ViewModels for screen state | Memory retained forever; stale data after logout |
| `Provider.of<T>(context)` without `listen: false` in callbacks | Unintended subscriptions |
| No `select` on leaf widgets | Whole-screen rebuilds |
| Creating a ViewModel inside `build` | Recreated every frame |
| Business logic in the widget because the ViewModel felt like ceremony | The failure mode this stack invites — resist it |

---

## When to move off it

Provider is a reasonable start and an honest limitation. Consider migrating when: the app has more than roughly a dozen screens, rebuild performance needs `select` everywhere to stay acceptable, DI wiring becomes a source of runtime errors, or the team wants compile-time guarantees. Record the migration as an ADR rather than drifting into a second state system alongside the first — two coexisting state systems is strictly worse than either one alone.
