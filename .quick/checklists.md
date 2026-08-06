# Checklists

Observable items only. Anything you cannot point at is not a checklist item.

---

## Before marking a task done

- [ ] `dart format --set-exit-if-changed .` — exit 0
- [ ] `flutter analyze` — 0 errors, 0 warnings
- [ ] `flutter test` — all pass, output quoted
- [ ] `build_runner` produces no diff
- [ ] Changed files match the declared `touch-scope`
- [ ] No secret, token, key or credential added
- [ ] No package added that is not in `STACK.md`
- [ ] `dart-hygiene-check.sh` — no blockers
- [ ] Acceptance criteria for this task are met, criterion by criterion
- [ ] Evidence recorded in the iteration block

## Before committing

- [ ] Task gate passed
- [ ] Diff reviewed line by line — including files you did not intend to change
- [ ] No debug code, no commented-out code, no stray `print`
- [ ] Generated files committed if the project commits them
- [ ] Commit subject: imperative, ≤72 chars, task id prefix, no AI attribution
- [ ] Body says **why**, not what — the diff says what
- [ ] No large binaries
- [ ] Blast radius acknowledged if it touched a protected surface

## Before closing a milestone

- [ ] Every task in the iteration block is `done` or explicitly `deferred` with a reason
- [ ] `@flutter-verify milestone` — clean, or every finding routed and resolved
- [ ] Applicable FLS lenses run, including **FLS-06 on all agent-authored code**
- [ ] Every SPEC acceptance criterion has a test that exercises it
- [ ] All six UI states implemented on every data-backed surface
- [ ] Accessibility audited on the new surfaces, not assumed
- [ ] Coverage did not decrease
- [ ] The exit demo actually works — run it
- [ ] `NEXT_FLUTTER.md` advanced to a single new pointer
- [ ] `HANDOFF_FLUTTER.md` entry appended: done, verified, decisions, open
- [ ] Plan updated if reality diverged from it

## Before releasing

- [ ] `@flutter-release certify` — all 14 gates pass
- [ ] `@flutter-security audit` — no blockers
- [ ] `@flutter-a11y audit` — WCAG 2.2 AA, with a real screen-reader pass
- [ ] `@flutter-perf profile` — measured on the reference device, within budget
- [ ] Version bumped deliberately; build number incremented
- [ ] Obfuscation on, **symbols archived and uploaded** — this is the one people forget, and it silently destroys every crash report in the release
- [ ] Store permission declarations match the permissions actually requested
- [ ] Privacy declarations match the data actually collected
- [ ] Release built and **installed from the artifact**, not from `flutter run`
- [ ] Cold start on a clean install works
- [ ] Upgrade from the previous version preserves data — test the migration from a real prior build
- [ ] Rollback plan written
- [ ] Changelog written for humans

## Starting a session

- [ ] `@flutter-session status` — where the project is
- [ ] `@flutter-session context` — load what the task needs
- [ ] Read the SPEC for the active task
- [ ] Read the standards the task touches
- [ ] Confirm the pointer in `NEXT_FLUTTER.md` still reflects reality

## Ending a session

- [ ] `@flutter-session close` (add `commit` / `push` to also commit/push the `.work.flutter/` state)
- [ ] HANDOFF entry appended
- [ ] NEXT has exactly one active pointer
- [ ] Blockers recorded with what is needed and from whom
- [ ] Nothing left in a half-written state without a note saying so

---

## Adopting an existing app

- [ ] `@flutter-bootstrap init` — confirm brownfield was detected
- [ ] `@flutter-stack detect` — confirm each inferred choice, do not accept silently
- [ ] `@flutter-plan-verify brownfield` — the honest score
- [ ] `@flutter-plan-repair brownfield` — recover foundation **from the code**
- [ ] Recovered documents carry honesty markers: observed vs inferred
- [ ] Existing conventions recorded even where they differ from framework defaults
- [ ] Divergences accepted or scheduled — not silently "fixed" in the first commit
- [ ] `@flutter-plan-master greenfield` — plan forward from where you are
