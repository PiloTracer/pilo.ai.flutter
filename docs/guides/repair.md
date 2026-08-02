# Repair

Fixing what verification found, without creating the next finding.

**Two repairers, and choosing wrong wastes the most time:**

| | Owns |
|---|---|
| `@flutter-repair` | Code defects — analyzer, tests, findings, FLS blockers |
| `@flutter-doctor` | Toolchain — build, dependencies, environment, codegen |
| `@flutter-plan-repair` | Planning artifacts — foundation, plan, traceability |

---

## Classify first

`@flutter-doctor diagnose` classifies before acting. Two minutes here prevents the most expensive mistake in this category: **editing application code to work around an environment problem**. The workaround appears to fix it, gets committed, and now the codebase contains a permanent accommodation for a problem that no longer exists.

| Toolchain | Code |
|-----------|------|
| Fails before the analyzer runs | Analyzer or test failure |
| Fails on a clean checkout for everyone | Fails only after your change |
| Same failure on `main` | `main` is green |

---

## The repair protocol

```
@flutter-repair repair - from <analyze|test|verify|FLS-nn|operator>
```

**1. Build the findings table.** Every finding, with its location and severity. Repairing from memory means repairing some of them.

**2. Classify the cause.** This is the step that gets skipped, and skipping it produces symptom fixes.

| Cause | Handling |
|-------|----------|
| Code defect | Fix it |
| Missing test | Write it |
| Standard violation | Fix the code, not the standard |
| Wrong SPEC | **Stop.** → `@flutter-feature-spec amend`. Do not implement around a wrong SPEC |
| Wrong plan | **Stop.** → `@flutter-plan-repair` |
| Toolchain | **Stop.** → `@flutter-doctor` |
| The check is wrong | **Stop.** Needs explicit operator agreement, and it is rarely true |

Four of those seven are stop conditions. Repair has a narrow remit by design: fixing something at the wrong layer means the real cause stays, and now there is a workaround on top of it.

**3. Fix the cause at its layer.** A null crash fixed by adding a null check at the call site leaves the reason it was null. Three call sites later you have three null checks and the original bug.

**4. Re-run the originating verifier.** Not a different one. Not "the tests pass now" when the finding came from `@flutter-a11y`. The verifier that found it is the only thing that can confirm it is gone.

**5. Report** what was fixed, what was not, and what the re-verification showed.

---

## Rules that are not negotiable

**Never weaken a check.** Not the test, not the assertion, not the threshold, not the lint. A check that fails is doing its job. Turning it off converts a visible problem into an invisible one, which is strictly worse than the original.

**Never delete or skip a failing test** to reach green. If the test genuinely encoded behaviour that has intentionally changed, say so explicitly, change it deliberately, and record why.

**Never regenerate a golden without reviewing the diff image.** `--update-goldens` on a red golden is how visual regressions ship. Look at the image first, every time.

**Never suppress an analyzer warning without a reason on the line.** `// ignore: <rule> — <why>`. A bare ignore is a note saying "someone decided this was fine" with no way to evaluate whether they were right.

**Stay in scope.** Repairing finding #3 is not licence to refactor the file. Every additional change is another thing that could have caused the next failure.

---

## Common repairs

| Finding | Real fix | Not this |
|---------|----------|----------|
| Flutter import in `domain/` | Move the type, or invert the dependency | Add it to the lint exclusions |
| Missing `mounted` check | Guard after every await | Wrap in try/catch |
| Bare `catch` | Catch the specific type, map to a domain failure | Add a comment |
| Missing UI state | Implement it | Note it as future work |
| Untested migration | Test from every prior version | Assume it works |
| Missing semantic label | Add it | Mark the widget as excluded |
| Colour literal | Move to the theme | Extract to a local constant |
| Failing golden | Understand the visual change first | `--update-goldens` |
| Flaky test | Find the real timing dependency | Add a retry |
| Slow list | Measure, then fix what the measurement showed | Sprinkle `const` and hope |

The right-hand column is what a fast repair looks like. All of them leave the finding technically resolved and the problem entirely present.

---

## Repairing planning artifacts

```
@flutter-plan-repair repair - from <verification>
```

Same shape, with extra constraints:

**Never invent product facts.** A missing requirement is not filled by guessing what the operator wanted. Ask, or record it as an unknown.

**Never renumber ids.** `F2-T4` is referenced in commits, reports and handoffs. Renumbering breaks every reference and cannot be undone from the artifacts.

**Scope changes need re-approval.** Adding or removing scope from an approved plan is a decision, not a repair.

---

## Repairing the toolchain

```
@flutter-doctor diagnose → env|deps|build|codegen|clean
```

**One change at a time, verify after each.** Changing four things and finding it works tells you nothing about which one mattered, and you will change all four again next time.

**`clean` is the last resort, not the first.** `@flutter-doctor clean` escalates least-destructive-first — targeted, then package, then full. Starting with `flutter clean` destroys the evidence that identifies the cause, which is why it so often "works" once and then the problem returns.

**Read the first error, not the last.** Gradle and CocoaPods produce cascades. The final message is usually the last consequence, and the first is usually the cause.

---

## After a repair

- [ ] The originating verifier re-run and quoted
- [ ] Nothing weakened
- [ ] Scope unchanged, or the widening was agreed
- [ ] A regression test exists where the finding was a defect
- [ ] The audit trail records what was found, what was done, and what was confirmed
- [ ] Findings that were **not** fixed are listed with a reason

That last item matters. A repair report claiming everything is fixed when three findings were deferred is the same category of false statement as an unrun test reported as passing.
