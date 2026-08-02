# Flutter & Dart conventions — template

> **Template.** `@flutter-foundation` P3 copies this to `{FLUTTER_STANDARDS_ROOT}/YYYYMMDD-CONVENTIONS.md`, fills every `REPLACE:` token, and the copy becomes binding. Never edit this file per project.

**Pairs with:** [`ARCHITECTURE_STANDARD`](20260801-ARCHITECTURE_STANDARD.md), [`DIRECTORY_MAP`](20260801-DIRECTORY_MAP.md), `STACK.md`, foundation doc 03.

**Baseline:** [Effective Dart](https://dart.dev/effective-dart) applies in full. This document records what the project adds, tightens, or decides where Effective Dart is silent.

---

## 1. Toolchain baselines

| Item | Value |
|------|-------|
| Flutter | `REPLACE:FLUTTER_VERSION` (channel `REPLACE:FLUTTER_CHANNEL`) |
| Dart SDK constraint | `REPLACE:DART_SDK_CONSTRAINT` |
| Lint ruleset | `REPLACE:LINT_PACKAGE` (e.g. `very_good_analysis`, `flutter_lints`) |
| Formatter | `dart format` — default page width unless recorded otherwise |
| Analyzer mode | Strict: `strict-casts`, `strict-inference`, `strict-raw-types` all true |
| Generated code | `REPLACE:CODEGEN_TOOLS`, output committed |

Analyzer errors are **build failures**. Warnings and infos are failures too, unless the rule is disabled deliberately in `analysis_options.yaml` with a comment saying why. A codebase that tolerates a growing warning count has no analyzer.

---

## 2. Type discipline

- **No `dynamic`** in production code. If an external boundary produces `dynamic`, convert it at that boundary and never let it propagate.
- **No `late`** except for genuinely two-phase initialisation (framework lifecycle, DI wiring). `late` converts a compile-time guarantee into a runtime crash.
- **No `!` (bang) operator** except where the nullability is proved on the immediately preceding lines. Prefer pattern matching, `?.`, `??`, or an early return.
- **Nullability is a contract.** A field is nullable because the domain permits absence — never to postpone a decision. Wire-optional and domain-optional are different; see [`DATA_LAYER_STANDARD`](20260801-DATA_LAYER_STANDARD.md).
- Prefer sealed classes / enhanced enums over `String` or `int` state discriminators.
- `dart:io` types never appear in `domain/`.

---

## 3. Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Files, directories | `snake_case.dart` | `user_profile_view.dart` |
| Types, extensions, enums | `UpperCamelCase` | `UserProfile` |
| Members, variables, parameters | `lowerCamelCase` | `isLoading` |
| Constants | `lowerCamelCase` (Dart, not `SCREAMING_CAPS`) | `defaultTimeout` |
| Private | leading underscore | `_cachedUser` |
| Widget files | one public widget per file, file named after it | `LoginForm` → `login_form.dart` |
| Test files | mirror the source path, `_test.dart` suffix | `test/features/auth/login_form_test.dart` |
| Golden files | `<widget>_<variant>.png` under `goldens/` | `login_form_dark.png` |
| Generated | `*.g.dart`, `*.freezed.dart` beside the source | |

**Suffix vocabulary** (a name should say what layer a type lives in): `…View`/`…Page`/`…Screen` for routed surfaces (pick one — `REPLACE:SCREEN_SUFFIX` — and use it everywhere), `…ViewModel`/`…Notifier`/`…Bloc` per the locked stack, `…Repository` for domain interfaces, `…RepositoryImpl` for data implementations, `…Service` for external capability wrappers, `…Dto` for wire models, `…Failure` for typed errors.

Avoid: `Helper`, `Util`, `Manager`, `Handler`, `Data`, `Info` — they describe nothing. Avoid abbreviations except the project's recorded glossary (foundation doc 04 §1).

---

## 4. Widgets

- **Prefer `StatelessWidget`.** Reach for `StatefulWidget` only for genuinely widget-local, ephemeral state (animation controllers, text controllers, focus). Business state belongs in the state layer.
- **`const` wherever possible.** The `prefer_const_constructors` lint is an error, not a suggestion.
- **Extract widgets, do not extract build methods.** A `Widget _buildHeader()` rebuilds with its parent; a `const _Header()` does not. Private widget classes over private builder methods.
- **`build` is pure and cheap.** No I/O, no allocation of expensive objects, no `Future` creation, no side effects. `build` can be called on any frame for any reason.
- **Maximum widget nesting: `REPLACE:MAX_NESTING` levels** before extraction. Deeply nested trees are unreviewable and rebuild badly.
- **Keys**: use `ValueKey`/`ObjectKey` on list items with identity; `GlobalKey` only when there is no alternative, with a comment explaining why.
- **No `MediaQuery.of(context).size` for layout** — use `LayoutBuilder` and constraints. `MediaQuery` for device properties only.
- **Never call `setState` after `await` without checking `mounted`.**
- **Dispose everything you create**: controllers, subscriptions, timers, focus nodes, isolates. A missing `dispose` is a leak and a `@flutter-verify` D5 finding.

---

## 5. Async

- `async`/`await` over raw `.then()` chains.
- Never `unawaited` a `Future` implicitly. If a fire-and-forget is intended, say so with `unawaited(...)` and handle its errors.
- Every `Stream` subscription has a matching cancel.
- Guard against use-after-dispose in every async continuation.
- No `Future.delayed` in production code as a synchronisation mechanism — it is a race condition with a timer.
- Long or CPU-bound work goes off the UI isolate (`compute` or a spawned isolate). The threshold is `REPLACE:ISOLATE_THRESHOLD_MS` ms.
- `Timer`s and periodic work are cancelled on dispose and paused on app background where applicable.

---

## 6. Errors

Full rules in [`ARCHITECTURE_STANDARD`](20260801-ARCHITECTURE_STANDARD.md) § Error handling. Conventions:

- **No bare `catch`** and no `catch (e) {}`. Catch what you can handle; let the rest surface.
- Every caught error is either handled, mapped to a typed failure, or rethrown — never swallowed.
- `catch (e, st)` — always capture the stack trace when logging or reporting.
- No `throw Exception('...')` with a bare string in production paths. Use the project's failure types.
- Errors crossing a layer boundary are **mapped**, not passed through. A `DioException` must never reach a ViewModel.
- Assertions (`assert`) express developer invariants only — they are stripped in release and are not validation.

---

## 7. Immutability and equality

- Model and state classes are immutable: `final` fields, `const` constructors where possible, `copyWith` for derivation.
- Value equality is generated (`REPLACE:EQUALITY_APPROACH` — e.g. `freezed`, `equatable`), never hand-written unless trivial. A hand-written `==` without a matching `hashCode` is a defect.
- Collections in models are exposed as unmodifiable.

---

## 8. Imports

- **Relative imports within a package**, `package:` imports across packages. Do not mix styles for the same target.
- Order: `dart:*`, then `package:*`, then relative — each group alphabetised, separated by blank lines. Enforced by the lint set.
- **No import may violate the layer direction** ([`ARCHITECTURE_STANDARD`](20260801-ARCHITECTURE_STANDARD.md) §2). This is the single most-checked rule in FLS-03.
- Barrel files (`<module>.dart`) only at package public boundaries, never inside a layer — internal barrels create cycles and defeat tree shaking.

---

## 9. Comments and documentation

- `///` doc comments on every public API of a shared package, and on any non-obvious domain rule.
- Comments explain **why**, never **what**. A comment restating the code is deleted on sight.
- `TODO(owner): description — <ticket or condition>`. A `TODO` with no owner is a `@flutter-verify` finding.
- No commented-out code. Git remembers.
- No AI-attribution comments, no "generated by", no changelog narration in source.

---

## 10. Magic values

- No magic numbers or strings in widget or logic code. Spacing, radii, durations and colours come from the theme ([`THEMING_STANDARD`](20260801-THEMING_STANDARD.md)); user-visible text comes from l10n ([`L10N_STANDARD`](20260801-L10N_STANDARD.md)); keys, routes and endpoints come from named constants.
- Durations are named: `const _fadeDuration = Duration(milliseconds: 200);`.

---

## 11. Logging and secrets

- Structured logging through the project logger only. **Never `print`** in committed code.
- Never log: credentials, tokens, PII, full request or response bodies, device identifiers. See [`OBSERVABILITY_STANDARD`](20260801-OBSERVABILITY_STANDARD.md).
- No secret in source, in `pubspec.yaml`, in a build config, or in a `--dart-define` default. `--dart-define` values ship inside the binary; they are configuration, not secrets.

---

## 12. Review requirements

| Change surface | Reviewers |
|----------------|-----------|
| Application code | ≥1 |
| Auth, crypto, secret handling, permissions | ≥2, one security-tagged |
| Local-store migrations | ≥2 |
| Native platform config, entitlements, manifests | ≥2 |
| Files in `PROTECTED_SURFACES.json` | ≥2 + explicit human approval in the request |
| Agent-authored change | Human review of the FLS-06 output alongside the diff |
