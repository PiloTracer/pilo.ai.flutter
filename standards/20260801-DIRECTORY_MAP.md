# Directory map — template

> **Template.** `@flutter-foundation` P3 copies this to `{FLUTTER_STANDARDS_ROOT}/YYYYMMDD-DIRECTORY_MAP.md` with tokens filled. `@flutter-scaffold` generates against the project copy; `@flutter-verify` D2 checks placement against it.

**Rule:** a file's path declares its layer, its feature and its visibility. If you cannot tell where a new file goes from this map, the map is incomplete — fix the map, do not guess.

---

## 1. Repository root

```
<repo>/
  lib/                       # all Dart source
  test/                      # unit + widget tests, mirrors lib/
  integration_test/          # on-device integration tests
  android/ ios/ web/ macos/ windows/ linux/
  assets/                    # images, fonts, json, l10n source
  packages/                  # local packages (multi-package mode only)
  tool/                      # project scripts
  .work.flutter/             # Agent OS project memory — never app source
  analysis_options.yaml
  pubspec.yaml
  DOCS_FLUTTER_STACK.md      # toolchain commands, single source
  .cursorrules
```

`.work.flutter/` is **never** imported by application code and never shipped in a bundle.

---

## 2. `lib/`

```
lib/
  main.dart                        # thin: bootstrap + runApp only
  bootstrap.dart                   # error handlers, DI init, zone setup
  app.dart                         # root widget: theme, router, localisation
  flavors.dart                     # flavor enum + config accessor

  core/
    di/                            # container setup, scopes
    error/                         # failure types, error mapper, global handlers
    network/                       # http client, interceptors, connectivity
    storage/                       # local store bootstrap, migrations, secure store
    router/                        # route table, guards, deep-link parsing
    theme/                         # theme data, tokens, extensions
    l10n/                          # generated localisations + helpers
    logging/                       # logger, redaction
    utils/                         # genuinely generic helpers only
    widgets/                       # cross-feature shared widgets

  features/
    <feature>/
      domain/
        entities/
        repositories/              # interfaces only
        failures/
        usecases/                  # only where they earn their place
      data/
        dtos/
        sources/                   # <feature>_remote_source.dart, _local_source.dart
        repositories/              # <feature>_repository_impl.dart
        mappers/
      presentation/
        <screen>/
          <screen>_view.dart
          <screen>_view_model.dart
          widgets/                 # widgets private to this screen
        widgets/                   # widgets shared across this feature
```

**Placement decisions:**

| The file is… | Goes in |
|--------------|---------|
| Used by one screen | that screen's `widgets/` |
| Used by two screens in one feature | that feature's `presentation/widgets/` |
| Used by two features | `core/widgets/` |
| A pure business rule | that feature's `domain/` |
| Talking to a network, disk or platform | that feature's `data/`, or `core/` if cross-cutting |
| Genuinely generic (no domain knowledge) | `core/utils/` — and if it has domain knowledge, it does not belong there |

`core/utils/` is where architecture goes to die. Every addition needs a reason it is not domain logic.

---

## 3. Naming within the map

| Kind | Pattern |
|------|---------|
| Screen | `<screen>_view.dart` → `class <Screen>View` |
| View model | `<screen>_view_model.dart` (or `_notifier` / `_bloc` per the locked stack) |
| Repository interface | `domain/repositories/<name>_repository.dart` |
| Repository impl | `data/repositories/<name>_repository_impl.dart` |
| Remote source | `data/sources/<name>_remote_source.dart` |
| DTO | `data/dtos/<name>_dto.dart` |
| Entity | `domain/entities/<name>.dart` — no suffix |
| Failure | `domain/failures/<feature>_failure.dart` |
| Generated | `<source>.g.dart`, `<source>.freezed.dart` — beside the source, committed |

---

## 4. `test/` mirrors `lib/`

```
test/
  features/<feature>/domain/...
  features/<feature>/data/...
  features/<feature>/presentation/<screen>/<screen>_view_test.dart
  core/...
  helpers/                # pump helpers, fixtures, fakes
  goldens/                # golden reference images, per widget
integration_test/
  <flow>_test.dart        # one file per user journey
```

The mirror is not cosmetic — it is how a reviewer knows what is untested. A source file with no corresponding test path is visible immediately.

---

## 5. Assets

```
assets/
  images/<feature>/            # or images/common/
  icons/
  fonts/
  l10n/                        # .arb source files
  config/                      # non-secret config json per flavor
```

Declared in `pubspec.yaml` by directory, not file-by-file, where the whole directory ships. Raster assets provide the resolution variants the design requires; prefer vector where the platform supports it.

---

## 6. Multi-package mode (`REPLACE:MODULARISATION` = multi)

```
packages/
  <feature_package>/
    lib/src/                 # implementation — not exported
    lib/<package>.dart       # the public surface, explicit exports
    test/
    pubspec.yaml
apps/
  <app>/                     # composition only: DI wiring, routing, flavors
```

**`lib/src/` is private by convention and enforced by the analyzer's `implementation_imports` lint.** Anything not exported from the barrel is not API. The app package composes; it holds no feature logic.

---

## 7. `.work.flutter/` (project memory)

```
.work.flutter/
  STACK.md                          # {FLUTTER_STACK_LOCK}
  context/HANDOFF_FLUTTER.md        # {FLUTTER_HANDOFF}
  plans/
    NEXT_FLUTTER.md                 # {FLUTTER_NEXT}
    foundation/
      01-product-intent.md … 05-risks-and-slicing.md
      PROBE_LEDGER.md
      UNKNOWNS.md
    full/YYYYMMDD-full-plan.md      # {FLUTTER_MASTER_PLAN}
    archives/ · operations/ · proposals/
  features/<slug>/YYYYMMDD-SPEC.md  # {FLUTTER_SPEC_ROOT}
  standards/                        # project copies, tokens filled — binding
  decisions/YYYYMMDD-ADR-<nn>-<slug>.md
  concepts/                         # concept run outputs
  reports/                          # verification and audit outputs
  docs/                             # guides, tutorials, runbooks
  prompts/
```

Placeholder resolution is authoritative in [`SKILL_DEPENDENCIES.md` § Work tree path resolution](../skills/SKILL_DEPENDENCIES.md#work-tree-path-resolution-mandatory). Note that SPECs live under `features/`, not `specs/`, and `NEXT_FLUTTER.md` lives under `plans/`, not `context/`.

Dated files use `YYYYMMDD-` prefixes. Nothing here is ever imported by `lib/`.

---

## 8. Forbidden placements

| Never | Why |
|-------|-----|
| Business logic in `main.dart` | Untestable; bootstrap must stay thin |
| Widgets in `domain/` or `data/` | Layer violation (FLS-03 blocker) |
| DTOs in `domain/` | Transport shape leaking into the model |
| `BuildContext` in `data/` or `domain/` | Layer violation |
| Test helpers in `lib/` | Ships test code to users |
| Generated files in a separate `generated/` tree | Breaks `part` resolution and review locality |
| Feature code in `core/` | `core/` becomes a second app |
| Secrets or credentials anywhere in the repo | See SECURITY_PRIVACY_STANDARD |
| App source in `.work.flutter/` | Project memory is not a source root |
