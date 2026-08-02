# Stack idiom — Riverpod

**Licence:** MIT · **Provides:** state management **and** dependency injection in one system.

Read before generating any code in a Riverpod project. Library-independent rules remain binding: [`STATE_MANAGEMENT_STANDARD`](../standards/20260801-STATE_MANAGEMENT_STANDARD.md).

> **Verify versions and APIs against pub.dev before writing code.** Riverpod's API changed substantially across major versions (`StateNotifier` → `Notifier`/`AsyncNotifier`, manual providers → generated). Writing the wrong generation's API from memory is the most common failure here, and it produces code that looks idiomatic and does not compile.

---

## Packages

| Package | Role | Licence |
|---------|------|---------|
| `flutter_riverpod` (or `hooks_riverpod`) | Runtime | MIT |
| `riverpod_annotation` | Annotations for codegen | MIT |
| `riverpod_generator` (dev) | Generates providers | MIT |
| `riverpod_lint` (dev) | Catches misuse at analysis time | MIT |
| `build_runner` (dev) | Codegen driver | BSD-3 |

**Install `riverpod_lint`.** It catches the mistakes that are otherwise runtime surprises: providers read outside a scope, missing `ref.watch` dependencies, unnecessary `ref.read` in build.

Current `riverpod_lint` runs under the first-party analyzer plugin system — a top-level `plugins:` key in `analysis_options.yaml`, surfaced by plain `dart analyze`. Older setups wired it through `custom_lint`, which has ended maintenance and needed its own CI invocation. Check which mechanism the installed version uses before adding a separate lint step; a `custom_lint` step that no longer runs anything still exits 0, which reads as a pass.

---

## Version discipline

Riverpod 3 changed things that silently alter behaviour rather than failing to compile. Confirm which major version the project is on before writing or reviewing code.

| Change in 3.x | Why it bites |
|---------------|-------------|
| `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider` moved to `legacy.dart` | Compile error — loud, therefore harmless |
| Provider failures rethrow wrapped in `ProviderException` | **Silent.** Existing `catch` clauses matching the original type stop matching |
| All providers now filter updates with `==` | **Silent.** Previously-inconsistent `identical` comparison; rebuild behaviour changes |
| Notifiers recreated on every provider rebuild | **Silent.** State held in notifier fields rather than in `build` is lost |
| Out-of-view providers paused by default | **Silent.** Background refresh you relied on stops |
| `AsyncValue.valueOrNull` removed; `.value` returns `null` on error | Mixed |
| Automatic retry with exponential backoff on failing providers | **Silent.** A failing request now retries where it previously did not |

Persistence (`persist` / `riverpod_sqflite`) and mutations are **experimental** — the API can break without a major version bump. Do not make either load-bearing, and if a project uses them, record it as a risk rather than an architecture decision.

---

## Layout

```
lib/features/<feature>/
  domain/          # entities, repository interfaces, failures — no Riverpod
  data/            # implementations + the provider that constructs them
  presentation/
    <screen>/
      <screen>_view.dart
      <screen>_controller.dart      # @riverpod class ...Controller
      <screen>_state.dart           # sealed state, if not using AsyncValue directly
```

**`domain/` never imports Riverpod.** Providers are a composition concern.

---

## Providers

Prefer **generated** providers (`@riverpod`) — they give compile-time-checked types, automatic dependency tracking, and no manual family boilerplate.

| Need | Shape |
|------|-------|
| A dependency (repository, client, service) | A simple `@riverpod` function returning the instance |
| Derived synchronous value | `@riverpod` function reading other providers |
| Async fetch, no user mutation | `@riverpod` async function → `AsyncValue` |
| Screen state with user intents | `@riverpod class X extends _$X` with `build()` + intent methods |
| Parameterised | Add parameters to the annotated function or class `build()` — this generates the family |

**`keepAlive` is a deliberate decision.** Auto-dispose is the default for a reason: it is what prevents a long-lived provider tree from holding data no screen is showing. Every `keepAlive: true` needs a stated reason, and user-scoped data marked `keepAlive` must be invalidated on logout.

---

## The controller shape

```dart
@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<Profile> build(String userId) async {
    final repo = ref.watch(profileRepositoryProvider);
    return switch (await repo.fetch(userId)) {
      Ok(:final value) => value,
      Err(:final failure) => throw failure,   // surfaces as AsyncError
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading<Profile>().copyWithPrevious(state); // partial state
    state = await AsyncValue.guard(() => _load());
  }
}
```

- `build()` produces the initial state and re-runs when a watched dependency changes.
- Intent methods set `state`; they never return values the UI needs to interpret.
- `AsyncValue.guard` converts a throw into `AsyncError` without a manual try/catch.
- **`copyWithPrevious` is how you get the partial/refreshing state** — without it, a refresh blanks the screen, which is the most-reported Riverpod UX defect.

---

## The six states

`AsyncValue` gives three (`loading`, `error`, `data`). The other three are yours:

| State | Source |
|-------|--------|
| Loading | `AsyncLoading` with no previous value |
| Partial / refreshing | `AsyncLoading` **with** a previous value (`isRefreshing`) |
| Error | `AsyncError` — map the failure type to the message |
| Offline | A distinct failure type checked inside the error branch, not a generic error |
| Empty | `AsyncData` whose value is empty — an explicit branch in the UI |
| Success | `AsyncData` with content |

An `AsyncValue` switched only three ways has silently merged empty into success and offline into error.

---

## Widgets

- `ConsumerWidget` / `ConsumerStatefulWidget`; `WidgetRef` is passed in.
- **`ref.watch` in `build`; `ref.read` in callbacks.** `ref.read` in `build` produces a widget that never updates — a bug that looks like a caching problem.
- **`ref.watch(p.select((s) => s.field))`** to rebuild on one field only. Watching a whole object from a leaf is the standard rebuild-storm cause.
- `ref.listen` for effects — snackbars, navigation, dialogs. Never trigger an effect inside `build`.
- Never call an intent method during `build`.

---

## Testing

```dart
final container = ProviderContainer(
  overrides: [profileRepositoryProvider.overrideWithValue(FakeProfileRepository())],
);
addTearDown(container.dispose);
```

- Override at the provider, not by patching a global — this is the main practical advantage of Riverpod as DI.
- Widget tests wrap in `ProviderScope(overrides: [...])`.
- **`addTearDown(container.dispose)` on every container**, or state leaks between tests and produces order-dependent failures.
- Use `container.listen` to assert the **sequence** of states, not just the final one.

---

## Traps

| Trap | Consequence |
|------|-------------|
| `ref.read` inside `build` | Widget never rebuilds |
| Watching a whole object instead of `select` | Rebuild storms |
| `keepAlive` by default | Memory growth; stale user data after logout |
| Forgetting `copyWithPrevious` on refresh | Screen blanks on every pull-to-refresh |
| Providers declared inside a widget | Recreated every build |
| Business logic in the provider function instead of the domain | Untestable without the container |
| Mixing generated and manual provider styles | Two idioms in one codebase |
| Not disposing `ProviderContainer` in tests | Order-dependent flakes |
| Using `ref` after the provider disposed | Runtime error in async continuations — guard with `ref.mounted` |
