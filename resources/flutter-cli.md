# Flutter and Dart command reference

The commands skills run, what their output means, and how to read their failures.

> **The project's canonical commands live in `DOCS_FLUTTER_STACK.md` at the repo root.** If that file disagrees with this one, it wins — it accounts for melos workspaces, flavors and project-specific flags. This is the general reference.
>
> **Never report the result of a command that was not run.** If `flutter` is not on PATH, the answer is `toolchain unavailable`, and that is never a pass.

---

## Environment

| Command | Purpose |
|---------|---------|
| `flutter doctor -v` | Full toolchain state. **The first command in any build investigation** |
| `flutter --version` | SDK, Dart, channel, framework revision — quote this in every performance or build report |
| `which -a flutter` | Reveals a second SDK on PATH, the classic "works on my machine" cause |
| `flutter channel` | Unexpected channel explains a surprising amount |

---

## Dependencies

| Command | Purpose |
|---------|---------|
| `flutter pub get` | Resolve and fetch |
| `flutter pub upgrade` | Upgrade within constraints |
| `flutter pub upgrade --major-versions` | Raise constraints — deliberate, reviewed, never silent |
| `flutter pub outdated` | What is behind, and what is resolvable |
| `dart pub deps` | **The dependency tree.** Version conflicts are almost always transitive; this shows who requires what |
| `flutter pub deps --style=compact` | Shorter tree |

On a resolution failure: read the constraint pair from the error, then `dart pub deps` to find who imposes each side. Blaming the direct dependency without looking at the tree wastes the most time of any Flutter debugging habit.

---

## Analysis and formatting

| Command | Purpose |
|---------|---------|
| `flutter analyze` | Analyzer. **Zero issues** is the gate — infos included |
| `dart format .` | Format |
| `dart format --set-exit-if-changed .` | CI/gate form: fails if anything would change |
| `dart fix --dry-run` / `dart fix --apply` | Mechanical fixes for supported lints. Review the diff |

---

## Codegen

| Command | Purpose |
|---------|---------|
| `dart run build_runner build` | Generate once |
| `dart run build_runner build --delete-conflicting-outputs` | The standard invocation; clears stale outputs |
| `dart run build_runner watch` | Regenerate on change during development |

Currency check for the gate: regenerate, then `git diff --exit-code`. A diff means the committed generated code was stale, which means someone's build was passing on an old contract.

---

## Tests

| Command | Purpose |
|---------|---------|
| `flutter test` | All tests |
| `flutter test <path>` | One file or directory |
| `flutter test --name '<pattern>'` | By test name |
| `flutter test --coverage` | Writes `coverage/lcov.info` |
| `flutter test --update-goldens` | **Regenerates goldens — review every diff before committing** |
| `flutter test --reporter expanded` | Verbose, useful for diagnosing a hang |
| `flutter test integration_test/<file> -d <device>` | Integration tests on a device |

Report counts, not adjectives: `142 passed, 0 failed, 0 skipped`.

---

## Running

| Command | Purpose |
|---------|---------|
| `flutter devices` | Attached devices and emulators |
| `flutter run -d <device> --flavor <flavor> -t lib/main_<flavor>.dart` | Run a flavor |
| `flutter run --profile` | **Profile mode — the only valid mode for performance measurement** |
| `flutter run --release` | Release behaviour locally |
| `flutter run --dart-define-from-file=<file>` | Compile-time configuration (**not secrets — these ship in the binary**) |

---

## Building

| Command | Purpose |
|---------|---------|
| `flutter build apk --release --split-per-abi` | APKs per architecture |
| `flutter build appbundle --release` | Play Store artifact |
| `flutter build ios --release` | iOS build (archive and upload happen in Xcode or CI) |
| `flutter build ipa --release --export-options-plist=<plist>` | Full IPA |
| `flutter build web --release` | Web |
| `--obfuscate --split-debug-info=<dir>` | **Both flags together, always.** Obfuscation without archived symbols makes crash reports unreadable |

---

## Size and performance

| Command | Purpose |
|---------|---------|
| `flutter build <target> --analyze-size` | Size breakdown by package and asset |
| `flutter run --profile --trace-startup` | Startup phase timings |
| `dart devtools` | Timeline, CPU profiler, memory, widget rebuild counts |

Every performance number is reported with device, OS version, build mode, Flutter version and run count. Without those, the number cannot be compared to the next one.

---

## Cleaning — least destructive first

| Level | Command | Cost |
|-------|---------|------|
| 1 | Delete generated Dart output, regenerate | Seconds |
| 2 | `flutter clean` | Rebuild time |
| 3 | Remove `pubspec.lock`, re-resolve | **Version drift risk — confirm first** |
| 4 | Gradle / derived data / Pods caches | Minutes to tens of minutes |
| 5 | `flutter pub cache repair` | Very slow; affects every project |

**Never clean before the cause is understood.** A clean destroys the evidence that would have identified the problem, and it usually does not fix it.

---

## Reading failures

| Toolchain | Where the real cause is |
|-----------|-------------------------|
| Gradle | Near the **top**. The bottom is a summary |
| CocoaPods | The first constraint conflict, not the final error |
| `build_runner` | The first error; later ones are cascades |
| Dart analyzer | Fix the first error; the rest are often cascades |
| Version solving | The specific constraint pair, then `dart pub deps` |

Capture the exact command and the first meaningful error line **before** changing anything.
