# Patterns

The shapes this framework requires, and the shapes it rejects. Library-agnostic — for idiom specifics see [`stacks/`](../stacks/README.md).

---

## The six states

Every surface backed by data expresses all six. Five of them are where the bugs live.

| State | Requirement |
|-------|------------|
| Loading | An indicator; no layout jump when it resolves |
| Empty | Explains why it is empty and what to do about it |
| Success | The happy path |
| Error | Says what failed, in user language, with a way forward |
| Partial | Some data, some missing — stale cache, partial fetch |
| Offline | Distinguished from error; says what still works |

"Not applicable" is a valid answer for a specific state on a specific surface. **Unconsidered is not.**

---

## Layers

```
presentation/  widgets, view models      → may import domain
domain/        entities, repo interfaces → PURE DART. no flutter, no data
data/          DTOs, repo impls, sources → may import domain
```

The rule that catches everything: **`import 'package:flutter/...'` inside `domain/` is a blocker.** Not a smell, not a note — a blocker. It is the single check that keeps the domain testable, portable and free of framework lifecycle.

DTOs stay in `data/`. A DTO reaching a widget means the wire format is now a UI contract, and the next backend change becomes a UI change.

---

## State objects

```dart
@immutable
final class ProfileState {
  const ProfileState({required this.status, this.profile, this.failure});
  final ProfileStatus status;
  final Profile? profile;
  final Failure? failure;
  // value equality — required, or every rebuild is a real rebuild
}
```

Immutable · value equality · models the whole state space · one object per screen. Not a bag of independent booleans: `isLoading && hasError` should be unrepresentable, and with three booleans it is not.

---

## View models

```dart
final class ProfileViewModel {
  ProfileViewModel(this._repo);
  final ProfileRepository _repo;   // domain interface, not an implementation

  Future<void> load() async { ... }   // an intent, not a setter
}
```

No Flutter imports · depends on domain interfaces only · exposes state and intents, never setters · handles its own errors · cancellation-safe · testable without a widget tree.

**If testing it requires `pumpWidget`, it is not a view model.**

---

## Errors

Two tracks, and they are not interchangeable.

```dart
// Expected failure → a value. The caller must handle it.
Future<Result<Profile, ProfileFailure>> getProfile();

// Bug → an exception. It should crash in debug and be reported in release.
throw StateError('...');
```

At the repository boundary, mapping is **total**: every transport, parse and storage error becomes a domain failure. `catch (e)` with no type is a blocker — it swallows programming errors along with network errors and makes both invisible.

Every failure has a user-visible outcome. A failure that only logs is a failure the user experiences as the app doing nothing.

---

## Async

```dart
if (!mounted) return;        // after every await, before touching context
setState(...);
```

Cancel subscriptions in `dispose`. Every operation has a timeout. Every await point is a place where the widget may already be gone.

`Future.delayed` used to wait for something to be ready is a race, not a synchronisation primitive. It passes on your machine and fails on a loaded CI runner.

---

## Widgets

```dart
class UserCard extends StatelessWidget {         // a class
  const UserCard({super.key, required this.user});
  @override
  Widget build(BuildContext context) => const Padding(...);
}

Widget _buildUserCard() { ... }                  // NOT a method
```

Extracted **widgets** get their own rebuild scope. Extracted **methods** rebuild with the parent and give you the visual tidiness of decomposition with none of the benefit.

`const` wherever possible · `build` is pure — no I/O, no state mutation, no allocation of expensive objects · `ListView.builder` for anything not fixed and short · dispose every controller, subscription and focus node.

---

## Repositories

```dart
// domain/repositories/profile_repository.dart
abstract interface class ProfileRepository {
  Future<Result<Profile, ProfileFailure>> getProfile(UserId id);
}

// data/repositories/profile_repository_impl.dart
final class ProfileRepositoryImpl implements ProfileRepository { ... }
```

Interface in domain, implementation in data · stateless (caches live in sources) · returns entities, never DTOs · maps every error.

---

## Migrations

Numbered · idempotent · forward-only · tested **from every prior version** · data-preserving or explicitly destructive with consent.

Verified by running twice. A migration that has only been run once has not been shown to be idempotent, and the second run happens on a user's device.

---

## Rejected outright

| Pattern | Why |
|---------|-----|
| `print()` in production code | Use the logger. `print` is unfilterable and ships |
| Bare `catch` | Swallows bugs |
| `late` to defer thinking | Runtime crash instead of a compile error |
| `!` on a nullable | Same |
| `dynamic` | Discards the type system you are paying for |
| Colour literals in widgets | Breaks theming and dark mode |
| `MediaQuery.of(context).size` for layout | Use `LayoutBuilder`; screen size is not widget size |
| `Future.delayed` as synchronisation | Flaky by construction |
| Business logic in `build` | Runs on every frame |
| Service locator in domain | Hidden dependency, untestable |
| Ignoring the analyzer with no reason | If it is genuinely wrong, say why on the line |
| Secrets in `--dart-define` | Trivially extractable from the binary. It is configuration, not secrecy |
