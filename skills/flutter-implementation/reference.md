# flutter-implementation — reference

Templates and detailed step tables for [`skill.md`](skill.md).

---

## Iteration block

Template for the `## Current iteration` section of `{FLUTTER_NEXT}`.

```markdown
## Current iteration

**Milestone:** F2 — Cart and checkout
**Plan ref:** `.work.flutter/plans/full/20260801-full-plan.md` §11 F2, §12
**Status:** in-progress
**Started:** 2026-08-01
**Target:** 2026-08-08

### In scope
- Cart repository with local persistence
- Cart screen: list, quantity edit, remove, totals
- Checkout entry point (navigation only; payment is F3)

### Out of scope (explicit)
- Payment processing (F3)
- Promo codes (F4)
- Guest checkout (not in v1 — doc 05 §4)

### Tasks

| ID | Description | Files | Status | Notes |
|----|-------------|-------|--------|-------|
| F2-T1 | Cart entity + invariants | `lib/src/features/cart/domain/cart.dart`, `lib/src/features/cart/domain/cart_item.dart` | done | G1–G9 pass; `flutter test test/features/cart/domain/` 12/12; SC1: assumed max qty 99 → confirmed with SPEC §8 R4 |
| F2-T2 | Cart repository + local store | `lib/src/features/cart/data/cart_repository.dart`, `lib/src/features/cart/data/cart_local_source.dart` | in-progress | delegated store schema to `@flutter-data` |
| F2-T3 | Cart view model | `lib/src/features/cart/presentation/cart_view_model.dart` | pending | |
| F2-T4 | Cart screen + six states | `lib/src/features/cart/presentation/cart_screen.dart` | pending | SPEC §6 |
| F2-T5 | Widget + golden tests | `test/features/cart/presentation/cart_screen_test.dart` | pending | |

**Status values:** `pending` · `in-progress` · `done` · `blocked`

### Acceptance criteria
- A1 A user can add, change quantity, and remove items; totals update immediately. (widget test)
- A2 The cart survives an app restart. (integration test)
- A3 With no network, the cart is fully usable and shows the offline indicator. (integration test)
- A4 Empty, loading, error and offline states each render per SPEC §6. (golden tests)
- A5 Screen passes the a11y guidelines with a screen reader traversal. (`@flutter-a11y test`)

### Validation commands
```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
flutter test integration_test/cart_test.dart -d <device>
```

### Owner blockers
| Blocker | Owner | Blocks | Raised |
|---------|-------|--------|--------|
| Tax rounding rule for multi-currency carts | finance | F2-T1 | 2026-08-02 |

### Concept / NFR registry (this iteration)
| Concept | Applies | Status | Output |
|---------|---------|--------|--------|
| FLS-01 widget-tree efficiency | yes (list rendering) | pending | |
| FLS-02 state-management integrity | yes | pending | |
| FLS-03 layer boundaries | yes | pending | |
| FLS-04 async & error safety | yes | pending | |
| FLS-06 AI-assisted change safety | yes (agent session) | pending | required before complete |
| FLS-09 offline & data integrity | yes | pending | |
| FLS-05 navigation | N/A | N/A | no route changes |

### Done this iteration
| ID | Description | Evidence |
|----|-------------|----------|
| F2-T1 | Cart entity + invariants | `flutter test` 12/12; analyze clean |
```

---

## plan protocol (detailed)

### PI1 — Verify prerequisites

| Source | Accept |
|--------|--------|
| `{FLUTTER_MASTER_PLAN}` front matter `status: Approved` | yes |
| `{FLUTTER_HANDOFF}` line `Milestone waiver: F0 — <reason>` | yes, for that milestone only |
| Anything else | no → blocked report |

```markdown
## @flutter-implementation plan - blocked (prerequisite)

**Required:** an Approved master plan, or a HANDOFF waiver naming this milestone
**Detected:** `20260801-full-plan.md` status: Draft; no waiver line in HANDOFF
**Run first:** `@flutter-plan-master status` (then approve the plan, or record a waiver)
```

### PI2 — Select the target milestone

Operator-named `F{N}` wins. Otherwise the first milestone in §11 whose tasks are not all `done`. Report which and why.

### PI3 — Derive tasks

1. Copy every task row for the milestone from plan §12. **Never renumber.**
2. Carry the `Files`, `Traces` and `Verify` columns through.
3. Read every SPEC the tasks trace to, and note the sections each task implements.
4. Insert delegation sub-tasks where the plan implies data or native work:
   - Model, repository, source or local-store change → a sub-task noting `@flutter-data <mode>`.
   - Channel, permission, deep link or native config → a sub-task noting `@flutter-platform <mode>`.
5. If a plan task is too large for one gate (touches >1 layer and >3 files), split it into `F{N}-T{k}a`, `…b`. Record the split so §12 can be updated by `revise`.

### PI4 — Write the block

Write all subsections. Populate the Concept/NFR registry from plan §20 plus the diff-scope triggers in [`concepts/README.md`](../../concepts/README.md). Every applicable FLS gets a row; every inapplicable one gets `N/A` with a reason.

### PI5 — Plan report

```markdown
## @flutter-implementation plan - F<N>

**Milestone:** F<N> — <theme>
**Tasks:** <n> (<n> pending) · **Estimate:** <sum>
**Declared file scope:** <n> paths across <n> features
**SPECs to read:** <paths>
**Validation:** <commands>
**Concept rows:** <n> applicable, <n> N/A
**Blockers carried in:** <n>

**Run next:** `@flutter-implementation start`
```

---

## start protocol (detailed)

### ST1 — Mandatory reads

| # | Read | Why |
|---|------|-----|
| 1 | `{FLUTTER_NEXT}` § Current iteration | Scope contract |
| 2 | Every SPEC the tasks trace to | Behaviour contract |
| 3 | `{FLUTTER_STANDARDS_ROOT}` CONVENTIONS | Naming, structure, style |
| 4 | `{FLUTTER_STANDARDS_ROOT}` DIRECTORY_MAP | Where files go |
| 5 | `{FLUTTER_STANDARDS_ROOT}` TESTING_STANDARD | What tests are required |
| 6 | `{FLUTTER_STACK_LOCK}` + `stacks/<K1>.md` | Which idioms are correct here |
| 7 | `{FLUTTER_HANDOFF}` | Session state, waivers, blockers |

Report each as read with its path. A skipped read is a `fail` on checklist row 3 or 4.

### ST3 — Assumption ledger

```markdown
### Assumption ledger — F2 start

| # | Assumption | Label | Basis / resolution |
|---|-----------|-------|--------------------|
| 1 | Cart persists per device, not per account | Confirmed | SPEC cart §7 |
| 2 | Quantity max is 99 | Inference | UI convention; **confirm before T1 gate** |
| 3 | Tax is computed server-side | Unverified | **blocks T1** → UNKNOWNS.md |
```

`Unverified` assumptions must be resolved or logged **before** code depends on them.

---

## Continue protocol (detailed)

### Batch progress lines

One line per task, emitted as it completes:

```text
F2-T2 done   · 3 files · analyze 0 · test 18/18 · SC1 ok
F2-T3 done   · 1 file  · analyze 0 · test 6/6   · SC1 flagged: offline path untested → T5
F2-T4 FAIL   · analyze 2 errors → batch stopped
```

### Stop conditions

| Condition | Action |
|-----------|--------|
| Task gate fails and is not fixable within the same task's scope | Stop; report; route to `@flutter-repair` |
| Task becomes blocked | Stop the range; continue past it only in `count`/`until-blocked` mode |
| Schema or model change needed | Stop; route to `@flutter-data`; resume after |
| Native change needed | Stop; route to `@flutter-platform`; resume after |
| Protected file must change | Stop; ask the operator |
| Out-of-scope file required | Stop; either revert and re-plan, or `@flutter-plan-master revise` |
| Queue exhausted | Stop; recommend `complete` |

### Batch-end sweep

Mandatory when any file changed:

1. `git diff --name-only` over the cumulative batch diff.
2. `@flutter-verify uncommitted` on that diff.
3. Record the verdict in the batch summary.
4. `fail` → the batch is reported as `completed with findings`; route to `@flutter-repair repair - from uncommitted`. Do **not** silently pass.

### Batch summary

```markdown
## @flutter-implementation continue - <target>

**Queue:** <ids> · **Completed:** <n> · **Stopped at:** <id or none> (<reason>)

| ID | Result | Files | analyze | tests | SC1 |
|----|--------|-------|---------|-------|-----|

**Batch-end sweep:** `@flutter-verify uncommitted` → <verdict>
**Coverage:** <before>% → <after>%
**Blockers raised:** <n>
**Run next:** <command>
```

---

## Task gate (detailed)

### Commands by package type

| Package type | Format | Analyze | Test |
|--------------|--------|---------|------|
| Flutter app or plugin | `dart format --set-exit-if-changed .` | `flutter analyze` | `flutter test` |
| Pure Dart package | `dart format --set-exit-if-changed .` | `dart analyze` | `dart test` |
| Melos workspace | `melos exec -- dart format --set-exit-if-changed .` | `melos exec -- flutter analyze` | `melos exec -- flutter test` |

Take the exact commands from `DOCS_FLUTTER_STACK.md` — never hardcode another project's toolchain.

### G4 — codegen currency

When a file with `@freezed`, `@JsonSerializable`, `@riverpod`, `@RoutePage`, `@injectable`, a Drift table, or a `mockito` `@GenerateMocks` annotation changed:

```bash
dart run build_runner build --delete-conflicting-outputs
git diff --name-only -- '*.g.dart' '*.freezed.dart' '*.config.dart'
```

Non-empty diff after the build means committed generated output was stale. Commit the regenerated files as part of the task.

### G8 — hygiene patterns

Enforced by `scripts/dart-hygiene-check.sh`:

| Pattern | Why it fails |
|---------|--------------|
| `print(` / `debugPrint(` in `lib/` | Use the project logger; see OBSERVABILITY_STANDARD |
| `Color(0xFF…)` / `Colors.<name>` inside a widget build | Colors come from the theme; see THEMING_STANDARD |
| `// ignore:` or `// ignore_for_file:` with no trailing reason | Silencing without justification |
| `TODO` with no issue or task reference | Untracked debt |
| `http://` in a non-test Dart file | Cleartext transport |
| A hardcoded user-facing string literal in a widget, when l10n is enabled | Breaks localisation |
| `late` on a field with no initialisation path in the same class | Latent `LateInitializationError` |
| `!` null-assertion on an expression that is not locally proven non-null | Latent null crash |

### Failure classification

Before fixing, classify — the class determines the owner:

| Class | Signal | Owner |
|-------|--------|-------|
| Code defect | Test asserts the right thing and fails | fix in-task, then re-gate |
| Test defect | Test asserts the wrong thing | fix the test; note it in SC1 |
| SPEC gap | Neither is wrong; the behaviour was never specified | `@flutter-feature-spec amend` |
| Plan defect | The task itself was wrong | `@flutter-plan-master revise` |
| Toolchain | Build, dependency, codegen or platform tooling | `@flutter-doctor diagnose` |
| Flake | Passes on re-run without a change | Do **not** ignore — record it; three flakes make a bug |

---

## Complete protocol (detailed)

### CO1 — Full iteration gate

| # | Check |
|---|-------|
| 1 | Every acceptance criterion checked **individually**, with the evidence that proves it |
| 2 | Full suite green: `dart format`, `flutter analyze`, `flutter test --coverage` |
| 3 | Coverage meets the floor in the project QUALITY_GATES standard |
| 4 | Every Concept/NFR registry row resolved (`done` or `N/A` with a reason) |
| 5 | FLS-06 run when source or tests changed; output path recorded |
| 6 | Manual validation steps performed and described |
| 7 | Integration tests run on at least one real device or emulator per target platform, or `not run` with the reason |

Skip the duplicate full-suite run when CO2 already ran it on the same tree — say so explicitly.

### CO6 — Close report

```markdown
## @flutter-implementation complete - F<N>

**Milestone:** F<N> — <theme>
**Tasks:** <n> done · <n> deferred → <where>
**Verify:** `@flutter-verify milestone` → <verdict>
**Coverage:** <before>% → <after>% (floor <n>%)
**Concepts:** FLS-<ids> done · FLS-<ids> N/A
**FLS-06:** <output path>

### Acceptance criteria
| ID | Met | Evidence |
|----|-----|----------|

### Artifacts
| Path | Change |
|------|--------|

### Residual risks
| Risk | Severity | Owner | Mitigation or acceptance |
|------|----------|-------|--------------------------|

### Deferred
| Item | Why | Where it went |
|------|-----|---------------|

**Run next:** `@flutter-session close` then `@flutter-implementation plan - F<N+1>`
```
