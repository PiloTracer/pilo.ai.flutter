# Changelog

All notable changes to Flutter Agent OS. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versioning is [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

`@flutter-deploy update` reads this file to classify what changed between an installed version and the current one, so entries need to be accurate about scope.

---

## [Unreleased]

### Fixed — framework test-run against OfficeToolCombo (2026-08-02)
- **`readiness-verify.sh` false FAIL on `L1`-style ledger ids.** Entry rows like `| L1 |` were counted as zero questions; bare integers and a single letter prefix are both accepted
- **`probe-protocol.md` ledger shape** now matches the machine-checked template (Score + Q&A table), not a divergent Status/Conf sketch
- **`analysis_options.yaml.template`** includes `package:flutter_lints/flutter.yaml` directly — a leftover `REPLACE:FLUTTER_LINT_PACKAGE` token broke every analyze on fresh bootstrap
- **`traceability-verify.sh`** (and matching section cutters) end a numbered section only on the next `## ` heading, so `### F0` milestone subheads no longer empty §11
- **Catalog:** document that `sqlite3_flutter_libs` is EOL; Drift consumers use `package:sqlite3` ≥3.x
- **`flutter-deploy` basic:** empty target directories need `git init` before the pointer is written
- **`flutter-scaffold`:** pub-get must prove codegen pins against the installed SDK (`meta` pin vs latest `build_runner`)

## [1.0.1] — 2026-08-02

Ecosystem corrections. Several widely-repeated pieces of Flutter advice are now false, and a framework that repeats them teaches an agent to write code that does not compile, CI steps that do not run, and triage that changes the wrong files. Everything here is a correction to a factual claim, not a design change.

### Fixed — claims that were wrong
- **`flutter pub audit` does not exist.** `@flutter-security` now names the real mechanisms: `dart pub get` prints advisories but exits 0 regardless, so OSV-Scanner or Trivy is the actual gate
- **`custom_lint` has ended maintenance.** Replaced by the first-party `analysis_server_plugin` system under a top-level `plugins:` key, which runs under plain `dart analyze`. A leftover `custom_lint` CI step that no longer runs anything still exits 0, which reads as a pass
- **CocoaPods is no longer the iOS default.** `@flutter-doctor` `build - ios` now establishes whether the project uses Swift Package Manager before triaging, because a `Podfile` in the tree no longer settles the question
- **`golden_toolkit` is discontinued** — replaced by `alchemist` (MIT)
- Corrected licences in the catalog: `patrol` is Apache-2.0 (not BSD-3), `melos` is Apache-2.0 (not MIT), `sqflite` is BSD-2 (not MIT)

### Added — named package exclusions
The catalog's refusal policy was principled but abstract. It now names the packages, because abandonment status is the part of package advice that does not churn:
- `hive` (abandoned, and pub.dev reports `license:unknown`), `isar` (abandoned; **no Android 16 KB page support, which blocks Play Store submission**), `realm` (EOL September 2025), `dartz` (abandoned, unfinished), `redux`/`flutter_redux` (frozen), `dart_code_metrics` (went commercial)
- Permissive-licence-but-not-free: `objectbox` Sync is a paid product behind an Apache-2.0 binding, Shorebird and freeRASP are proprietary behind permissive wrappers

### Added — component contract
- `ARCHITECTURE_STANDARD` §1a maps the three layers onto the official View/ViewModel/Repository/Service components and states four import-checkable rules. Use cases are now explicitly conditional rather than default
- FLS-03 gained the component-contract questions; repository-to-repository imports and view-to-data imports are blockers
- `dart-hygiene-check.sh` mechanically detects both, without flagging an implementation importing its own interface
- `stacks/riverpod.md` gained a version-discipline table for Riverpod 3, covering the changes that alter behaviour **silently** rather than failing to compile — `ProviderException` wrapping, `==` update filtering, notifier recreation, out-of-view pausing, automatic retry
- `shared_preferences` guidance moved to `SharedPreferencesAsync` with the idempotent legacy migration call

---

## [1.0.0] — 2026-08-01

First release. Complete framework: plan, build, verify, repair.

### Orchestration
- `flutter-director` — free-text intake, classification, skill chaining, confirm gate
- `flutter-router` — read-only signpost, three-sentence answers with citations

### Planning
- `flutter-bootstrap` — idempotent, brownfield-safe project memory scaffold
- `flutter-stack` — locks seven stack dimensions with package verification
- `flutter-foundation` — P0–P6 foundation, certifies `plan-ready`
- `flutter-plan-master` — 21-section master plan, certifies `implementation-ready`
- `flutter-feature-spec` — 16-section SPECs with intake classification
- `flutter-plan-verify` — read-only planning audit
- `flutter-plan-repair` — planning remediation, including brownfield recovery

### Implementation
- `flutter-scaffold` — app, feature, package, flavor, CI, test harness generation
- `flutter-implementation` — iteration execution with a per-task gate
- `flutter-data` — entities, DTOs, repositories, sources, caching, migrations
- `flutter-platform` — channels, permissions, deep links, native config, parity
- `flutter-release` — prepare, certify, build, size, distribute

### Verification
- `flutter-verify` — milestone (14 dimensions), uncommitted, last, gate
- `flutter-test` — the pyramid: unit, widget, golden, integration, a11y
- `flutter-perf` — budgets, static audit, device measurement
- `flutter-a11y` — WCAG 2.2 AA against a running app
- `flutter-security` — eight-area audit assuming a compromised client

### Repair and support
- `flutter-repair` — code-layer remediation with mandatory re-verification
- `flutter-doctor` — toolchain diagnosis, classified before action
- `flutter-session` — HANDOFF, NEXT, context loading, state snapshots
- `flutter-concept-run` — FLS lens execution
- `flutter-docs` — guides, tutorials, reference, runbooks; nothing published unexecuted
- `flutter-deploy` — basic, files, repo installs; update with local-change detection

### Standards
20 standards plus `PROTECTED_SURFACES.json`: conventions, architecture, directory map, state management, data layer, navigation, testing, quality gates, performance, accessibility, security and privacy, observability, theming, localisation, master plan, feature spec, git workflow, documentation, ADR, code review.

### Concepts
FLS-01 widget-tree efficiency · FLS-02 state-management integrity · FLS-03 layer boundaries · FLS-04 async and error safety · FLS-05 navigation integrity · FLS-06 AI-assisted change safety · FLS-07 platform parity · FLS-08 performance budget · FLS-09 offline data integrity · FLS-10 accessibility and inclusivity · FLS-11 security and privacy · FLS-12 test integrity.

### Stacks and resources
Idiom guides for Riverpod, Bloc/Cubit, Provider, Signals. Vetted package catalog with licences, and a Flutter CLI reference. Every recommendation is free, open source and commercially usable.

### Scripts and hooks
Eight verifiers (`framework`, `master-plan`, `traceability`, `readiness`, `gate`, `touch-scope`, `blast-radius`, `dart-hygiene`), four installers, and five git hooks with `.local` chaining that preserves existing hooks.

`self-test.sh` runs every verifier against known-good and known-bad fixtures, asserting that clean input passes and that each specific defect is named in the output — so a verifier that regresses into passing everything is caught rather than trusted.

### Grilling
Shared probe protocol with an adaptive coverage loop and a challenge pass that attacks recorded answers. `readiness-verify.sh` fails ledgers claiming confirmation they did not earn.

### Notes
- Requires no sibling framework; cohabits cleanly with `.ai` and `.ai.ui` when present
- Readiness states: `scaffold → stack-locked → foundation-complete → plan-ready → implementation-ready → release-ready`
- No package versions are pinned anywhere. Verification against pub.dev at time of use is mandatory, because a pinned version in documentation is stale the week after it is written

[1.0.0]: https://semver.org/
