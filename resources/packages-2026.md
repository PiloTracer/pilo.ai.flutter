# Vetted package catalog

Free, open source, commercial-use-permitted packages, organised by the problem they solve. Admission policy: [`PACKAGE_LICENSE_STANDARD`](../standards/20260801-PACKAGE_LICENSE_STANDARD.md).

> **No versions are listed here, deliberately.** A version written in a document is wrong within months, and an agent repeating it produces a resolution failure or — worse — code written against an API that no longer exists. **Always check pub.dev for the current version, the current API, the licence, and the maintenance status before recommending or adding anything.** This catalog narrows the search space; it does not replace the check.
>
> Licences below were correct when the catalog was written and **can change between major versions**. Re-check at adoption and at every major upgrade.

---

## State management

| Package | Licence | Notes |
|---------|---------|-------|
| `flutter_riverpod` / `hooks_riverpod` | MIT | State + DI in one system; codegen recommended. [`stacks/riverpod.md`](../stacks/riverpod.md) |
| `flutter_bloc` | MIT | Event→state, transformers, strong traceability. [`stacks/bloc.md`](../stacks/bloc.md) |
| `provider` | MIT | Lowest concept count. [`stacks/provider.md`](../stacks/provider.md) |
| `signals_flutter` | MIT | Fine-grained reactivity. [`stacks/signals.md`](../stacks/signals.md) |

---

## Navigation

| Package | Licence | Notes |
|---------|---------|-------|
| `go_router` | BSD-3 | Flutter-team maintained; declarative, URL-shaped, deep links, guards. The default recommendation |
| `auto_route` | MIT | Codegen-based, type-safe arguments; more setup, stronger compile-time guarantees |
| Navigator 2.0 directly | BSD-3 | Only for genuinely unusual navigation requirements — it is a lot of code to own |

---

## Dependency injection

| Package | Licence | Notes |
|---------|---------|-------|
| `get_it` | MIT | Service locator. **Register at composition; inject via constructors** — do not call it from widgets |
| `injectable` | MIT | Codegen registration for `get_it` |
| Riverpod | MIT | If already chosen for state, use it for DI too rather than adding a second mechanism |

---

## Serialisation and models

| Package | Licence | Notes |
|---------|---------|-------|
| `json_serializable` + `json_annotation` | BSD-3 | The standard. Generated `fromJson`/`toJson` |
| `freezed` + `freezed_annotation` | MIT | Immutable models, unions/sealed classes, `copyWith`, equality |
| `equatable` | MIT | Value equality without codegen |
| `build_runner` | BSD-3 | Codegen driver for all of the above |
| `decimal` | Apache-2.0 | **Money. Never `double`** |
| `collection` | BSD-3 | Deep equality, sorting, grouping |

---

## Networking

| Package | Licence | Notes |
|---------|---------|-------|
| `dio` | MIT | Interceptors, cancellation, timeouts, upload/download progress |
| `http` | BSD-3 | Dart-team maintained; sufficient for simple needs |
| `retrofit` (Dart) | MIT | Codegen client over `dio` |
| `connectivity_plus` | BSD-3 | Connectivity state — **reports the interface, not reachability**; still verify with a real request |
| `web_socket_channel` | BSD-3 | WebSockets |
| `graphql_flutter` | MIT | If the backend is GraphQL |

---

## Local storage

| Package | Licence | Notes |
|---------|---------|-------|
| `shared_preferences` | BSD-3 | Scalar preferences. **Plaintext on disk** — never secrets. Use `SharedPreferencesAsync` / `SharedPreferencesWithCache`; the legacy `SharedPreferences` singleton is slated for deprecation, and on Android the new APIs sit on DataStore. Migrate with `migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary` (idempotent, safe on every launch) |
| `flutter_secure_storage` | BSD-3 | Keychain / Keystore. The **only** place for tokens and keys |
| `drift` | MIT | SQLite with typed queries, reactive streams, real migrations. The default for relational data |
| `sqlite3` | MIT | Native SQLite bindings used by Drift on desktop/mobile. **Use package `sqlite3` ≥3.x.** Do **not** add `sqlite3_flutter_libs` — that package is EOL (`0.6.0+eol`); pub.dev directs consumers to `sqlite3` 3.x instead |
| `sqflite` | BSD-2 | Raw SQLite when you want no abstraction. What the official persistence recipe uses |
| `path_provider` | BSD-3 | Platform directories |
| `hive_ce` | Apache-2.0 / BSD-3 | **Migration target only.** The maintained successor to the abandoned `hive`. Its own maintainer advises against it for greenfield work — take that at face value |

---

## Platform and device

| Package | Licence | Notes |
|---------|---------|-------|
| `permission_handler` | MIT | Runtime permissions across platforms |
| `package_info_plus`, `device_info_plus` | BSD-3 | App and device metadata |
| `url_launcher` | BSD-3 | External URLs, mail, tel |
| `share_plus` | BSD-3 | System share sheet |
| `image_picker`, `file_picker` | Apache-2.0 / MIT | Media and file selection |
| `local_auth` | BSD-3 | Biometrics — **gate a key, not a boolean** |
| `app_links` | Apache-2.0 | Deep and app link handling |
| `flutter_local_notifications` | BSD-3 | Local notifications |
| `geolocator` | MIT | Location — high privacy sensitivity; declare and justify |

---

## UI

| Package | Licence | Notes |
|---------|---------|-------|
| `cached_network_image` | MIT | Remote images with caching and placeholders |
| `flutter_svg` | MIT | SVG rendering |
| `shimmer` / skeleton packages | MIT | Loading placeholders |
| `intl` | BSD-3 | Dates, numbers, currency, plurals. **Never hand-format** |
| `flutter_localizations` | BSD-3 | SDK localisation delegates |
| `google_fonts` | Apache-2.0 | Check the individual font licence and prefer bundling over runtime fetch |

---

## Logging and observability

| Package | Licence | Notes |
|---------|---------|-------|
| `logger` / `logging` | MIT / BSD-3 | Structured logging with levels |
| `sentry_flutter` | MIT | Crash and error reporting (self-hostable; the SaaS tier is commercial) |
| Firebase Crashlytics | Apache-2.0 (SDK) | Widely used; note the data-collection and privacy-declaration implications |

Whatever the choice: **verify symbol upload on an obfuscated release build**, or every stack trace is unreadable.

---

## Testing

| Package | Licence | Notes |
|---------|---------|-------|
| `flutter_test` | BSD-3 | SDK |
| `mocktail` | MIT | Null-safe mocking without codegen. **Preferred over `mockito`** — no `build_runner` step, so no stale generated mocks |
| `bloc_test` | MIT | State-sequence assertions for Bloc |
| `alchemist` | MIT | Golden helpers. Replaces the discontinued `golden_toolkit` |
| `integration_test` | BSD-3 | SDK; on-device journeys |
| `patrol` | Apache-2.0 | Native interaction in integration tests (permission dialogs, notifications). Fully OSS with no paid feature gate |

---

## Analysis and tooling

| Package | Licence | Notes |
|---------|---------|-------|
| `very_good_analysis` | MIT | Strict lint set. The recommended default |
| `flutter_lints` | BSD-3 | The SDK's baseline set |
| Stack-specific lints (`riverpod_lint`, `bloc_lint`) | MIT | Catch state-management misuse at analysis time. See the plugin note below |
| `melos` | Apache-2.0 | Monorepo management. **Melos 7+ has no `melos.yaml`** — it delegates linking to native pub workspaces, config moves under a `melos:` key in the root `pubspec.yaml`, every member needs `resolution: workspace`, and `melos analyze` is gone |
| `flutter_launcher_icons`, `flutter_native_splash` | MIT | Icon and splash generation |
| `flutter_flavorizr` | MIT | One-time generation of native flavor scaffolding. Own and review the output; do not keep it as a runtime dependency |

**Analyzer plugins.** `custom_lint` has ended maintenance. Current Dart/Flutter ship a first-party `analysis_server_plugin` system configured under a **top-level `plugins:` key** in `analysis_options.yaml`, and it runs under plain `dart analyze` — no separate CI step. `riverpod_lint` has migrated to it; `bloc_lint` still ships its own `bloc lint` CLI, so a Bloc project needs that extra command in CI. Verify which mechanism a given lint package uses before wiring it into a gate.

---

## Vulnerability scanning

**There is no `flutter pub audit`.** An agent that writes that command has invented it, and the CI step will fail or, worse, silently do nothing.

`dart pub get` surfaces advisories for known-vulnerable dependencies, but **it does not fail the build** — the output is informational and easy to miss in CI logs. The actual gate is a scanner run as its own step: **OSV-Scanner** (Apache-2.0) or **Trivy** (Apache-2.0), either of which reads `pubspec.lock` and exits non-zero on findings.

---

## Refused

Two categories: licence, and abandonment. Both are hard refusals — the waiver process exists for the first, not the second.

**By licence or commercial gate:** anything GPL, AGPL, LGPL, CC-BY-NC, source-available (BSL/SSPL), or requiring payment for production use. Also refused: no licence file, or unreviewable binary native code.

**Named exclusions.** These are checked and current; unlike versions, this list does not churn much.

| Package | Reason |
|---------|--------|
| `hive` | Abandoned since 2022, and pub.dev reports **`license:unknown`** — it fails automated licence detection, which is disqualifying on its own. Successor: `hive_ce`, migration only |
| `isar` | Abandoned since 2023, upstream repo archived. **Does not support Android 16 KB page sizes, which blocks Google Play submission.** `isar_community` fixed that but is bug-fix-only — a migration bridge, not a choice |
| `realm` | MongoDB Atlas Device SDKs reached **end of life in September 2025**. Existing code should be migrated |
| `dartz` | Abandoned since 2021 and never finished. Use the official sealed `Result` pattern, or `fpdart` if the team genuinely wants monadic composition |
| `redux` / `flutter_redux` | Frozen since 2021/2022. `BlocObserver` covers the time-travel-debugging argument |
| `dart_code_metrics` | **Went commercial.** Repo archived, pub package discontinued, successor is paid DCM. MIT alternatives exist but are too young to gate on |
| `golden_toolkit` | Discontinued. Use `alchemist` |

**Permissive licence, still refused under a free/OSS constraint.** The licence on the visible part is not the licence on the part that matters:

| Package | The catch |
|---------|-----------|
| `objectbox` | The Dart binding is Apache-2.0, but the storage core is proprietary and **ObjectBox Sync is a paid product**. Local-only use is defensible; Sync is not free and must never be recommended as though it were |
| Shorebird | Permissive CLI, proprietary service behind it |
| freeRASP | Permissive wrapper, proprietary binaries |

Adding anything from either table needs an explicit, recorded waiver naming who accepted the risk.

---

## Before adding anything

1. Does the SDK or an existing dependency already do this?
2. Is the problem small enough to solve directly? A dependency for sixty lines is a bad trade.
3. Licence, maintenance, platform support, transitive weight, native code, data collection — all checked **on pub.dev**, now.
4. What is the exit cost if it is abandoned?
5. Record the decision in `STACK.md` with the alternative you would move to.
