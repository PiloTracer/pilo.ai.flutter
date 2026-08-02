# Stack idiom — Signals

**Licence:** MIT · **Provides:** fine-grained reactive state. **Not** dependency injection — pair with `get_it` or `provider`.

Signals bring the fine-grained reactivity model (signal → computed → effect) to Flutter. Reads are tracked automatically, so only the widgets that actually read a value rebuild when it changes. Less boilerplate than Bloc; less structural enforcement too.

Library-independent rules remain binding: [`STATE_MANAGEMENT_STANDARD`](../standards/20260801-STATE_MANAGEMENT_STANDARD.md).

> Verify the package name, version and current API against pub.dev before writing code. This ecosystem moves faster than the others in this directory.

---

## Packages

| Package | Role | Licence |
|---------|------|---------|
| `signals` / `signals_flutter` | Core + Flutter bindings | MIT |
| `get_it` | DI, since Signals does not provide it | MIT |

---

## The three primitives

| Primitive | Role | Rule |
|-----------|------|------|
| **Signal** | A mutable reactive value | The only thing that is written |
| **Computed** | A derived value, cached, recomputed when its dependencies change | **Never** duplicate derivable data in another signal |
| **Effect** | A side effect that re-runs when its dependencies change | Must be disposed; keep the body small |

The most common structural mistake is storing derived data in a second signal and keeping the two in sync manually. That is the bug the `computed` primitive exists to prevent.

---

## Layout

```
lib/features/<feature>/
  domain/                        # no signals imports
  data/
  presentation/
    <screen>/
      <screen>_view.dart
      <screen>_store.dart        # signals + intents
```

---

## Store shape

```dart
class ProfileStore {
  ProfileStore(this._repo);
  final ProfileRepository _repo;

  final _state = signal<ProfileUiState>(const ProfileUiState.loading());
  ReadonlySignal<ProfileUiState> get state => _state;      // expose readonly

  late final isEmpty = computed(() => _state.value is Empty);

  Future<void> load() async { ... _state.value = next; }

  void dispose() { _disposeEffects(); }
}
```

- **Expose signals as read-only.** A writable signal handed to the UI means any widget can mutate state from anywhere, and the write site becomes unfindable.
- Intents are methods; only the store writes its own signals.
- Batch related writes so dependents recompute once instead of once per assignment.
- Async continuations check that the store is still alive before writing.

---

## Widgets

- `Watch(...)` (or the equivalent binding in the installed version) wraps the **smallest** subtree that reads the signal. Wrapping the whole screen discards the fine-grained rebuild advantage, which is the only reason to choose this stack.
- Read signals inside the reactive scope; reading outside it produces a widget that silently never updates — a failure mode with no error message, which makes it harder to catch than Provider's or Riverpod's equivalent.
- Effects for snackbars, navigation and dialogs; never a side effect inside a build.
- Dispose every effect created by a widget.

---

## Async

Use the package's async-signal type where available so loading, error and data are modelled rather than assembled from a value plus two booleans. The six UI states still apply: empty, partial (refreshing with previous data) and offline are yours to model explicitly.

Cancellation and stale-response handling are manual — tag requests and ignore superseded responses.

---

## Testing

Stores are plain Dart objects: construct with fakes, call intents, assert signal values. Record a sequence by subscribing with an effect, and assert the sequence rather than only the final state. Dispose effects in `addTearDown`.

---

## Traps

| Trap | Consequence |
|------|-------------|
| Derived data stored in a signal instead of `computed` | Two sources of truth that drift |
| Writable signals exposed to the UI | Untraceable mutations |
| Reading a signal outside a reactive scope | Silently no rebuild, no error |
| `Watch` wrapping the whole screen | Discards the fine-grained benefit |
| Effects not disposed | Leaks and duplicate side effects |
| Unbatched sequential writes | Multiple recomputations and rebuilds per logical change |
| Side effects inside a build | Repeats on every rebuild |
| Business logic in the widget because the store felt optional | The failure mode low-ceremony stacks invite |
| Relying on remembered API shape | This package's API has moved; check the docs |
