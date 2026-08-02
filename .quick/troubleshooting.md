# Troubleshooting

Symptom → likely cause → skill. Classify before acting; the wrong classification is what turns a ten-minute problem into an afternoon.

---

## Is it the toolchain or the code?

| Toolchain | Code |
|-----------|------|
| Fails before the analyzer runs | Analyzer or test failure |
| Fails on a clean checkout for everyone | Fails only after your change |
| Gradle, CocoaPods, Xcode, SDK, PATH | Dart compile errors, assertion failures |
| Same failure on `main` | `main` is green |

`@flutter-doctor diagnose` classifies for you. Two minutes there prevents the classic failure: editing application code to work around an environment problem, and shipping the workaround.

---

## Build

| Symptom | Cause | Do |
|---------|-------|-----|
| `Gradle task assembleDebug failed` | JDK/AGP/Gradle mismatch, or a plugin's minSdk | `@flutter-doctor build` — read the **first** error, not the last |
| CocoaPods `Podfile.lock` conflict | Stale pods after a dependency change | `@flutter-doctor deps` |
| `Could not resolve dependency` | Version conflict | `dart pub deps` to find who requires what. Never blind-bump |
| `build_runner` conflicting outputs | Stale generated files | `--delete-conflicting-outputs` |
| Generated file not found | Codegen not run, or `part` declaration missing | `@flutter-doctor codegen` |
| Works locally, fails in CI | Uncommitted generated code, or a version not pinned | Compare toolchain versions first |
| Xcode signing failure | Provisioning, not code | `@flutter-doctor build` |

**Do not start with `flutter clean`.** It destroys the evidence and usually does not help. `@flutter-doctor clean` escalates least-destructive-first for a reason.

## Analyzer and tests

| Symptom | Do |
|---------|-----|
| Analyzer errors after a merge | `@flutter-repair repair - from analyze` |
| Tests fail after a refactor | `@flutter-repair repair - from test`. Fix the code, not the test — unless the test encoded the old behaviour, in which case say so explicitly |
| Test passes alone, fails in the suite | Shared state or order dependence. Both are test bugs |
| Flaky test | Real timing dependency. **Do not retry it away** |
| Golden fails after an unrelated change | Something global moved: theme, font, platform. Review the diff image before regenerating |
| Coverage dropped | New code without tests |

**Never:** delete a failing test, mark it `skip`, or loosen an assertion to reach green. This converts a visible failure into an invisible one, which is strictly worse than red CI.

## Runtime

| Symptom | Likely cause | Skill |
|---------|-------------|-------|
| `setState() called after dispose` | Missing `mounted` check after an await | `@flutter-repair` |
| Infinite rebuild | State written during `build` | `@flutter-repair` |
| `A RenderFlex overflowed` | Unconstrained child | `@flutter-repair` |
| Blank screen, no error | Error swallowed by a bare catch | Find the catch |
| Works in debug, breaks in release | Assertion-dependent code, or obfuscation reflection | `@flutter-release build` |
| Data lost on update | Migration not tested from the prior version | `@flutter-data migration` |
| Token refresh loops | No single-flight guard | `@flutter-security transport` |

## Performance

| Symptom | Do |
|---------|-----|
| Janky scroll | `@flutter-perf audit` for hypotheses, then `profile` to confirm. Static findings are not measurements |
| Slow startup | `@flutter-perf startup` — usually blocking work in `main()` |
| App too large | `@flutter-perf size` — usually assets or an unused dependency |
| Memory growth | `@flutter-perf memory` — usually an unbounded cache or an undisposed subscription |

Always: measure, change one thing, measure again under the same conditions. An improvement with no before/after is a guess.

## Platform

| Symptom | Skill |
|---------|-------|
| Android fine, iOS broken | `@flutter-platform parity` |
| Permission denied permanently | Only three outcomes exist — granted, denied, permanently denied. Handle all three |
| Deep link opens the wrong screen | `@flutter-platform deeplink` |
| Back button wrong on Android | `@flutter-platform config` |
| Keyboard covers the field | Scroll-aware layout, not a fixed offset |

## Accessibility

| Symptom | Cause |
|---------|-------|
| Screen reader says "button" | Icon button with no semantic label |
| Layout breaks at 200% text | Fixed heights |
| Focus jumps | No explicit focus order |
| State change silent | No live-region announcement |

`@flutter-a11y audit`. Automated checks are necessary and insufficient — the manual screen-reader pass finds what they cannot.

## Framework

| Symptom | Do |
|---------|-----|
| Skill says prerequisites not met | Read the blocked report; it names the resolving skill |
| Lost track of state | `@flutter-session status` |
| Plan and code disagree | `@flutter-plan-verify alignment` |
| Two skills seem to overlap | [`PROCESS_ROUTER.md`](../PROCESS_ROUTER.md) § Ownership |
| `framework-verify.sh` fails | Read the failures; each names a file |
| Hooks not firing | Re-run `scripts/install-git-hooks.sh` |

---

## Emergency: a secret was committed

1. **Revoke the credential.** Now, before anything else. Deleting the commit does not revoke it, and it has already been cloned, cached and indexed.
2. Rotate whatever it protected.
3. Then clean history if you want to — but the credential is already dead, so this is hygiene, not remediation.
4. `@flutter-security secrets` to find out how it got in, and fix that.

Step 1 is the only urgent step. Every minute spent rewriting history before revoking is a minute the live credential is public.
