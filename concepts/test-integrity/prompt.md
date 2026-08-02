# FLS-12 — Test integrity

**Fires:** any new or modified test, or a change to tested behaviour.
**Standard:** [`TESTING_STANDARD`](../../standards/20260801-TESTING_STANDARD.md).

---

## Why

A test suite degrades in one direction: toward green. Every pressure — a deadline, a flaky run, an awkward assertion — pushes toward weakening a check rather than fixing the code. The degradation is invisible, because the suite still passes. This concept exists to make weakening visible at the moment it happens, which is the only moment it is cheap to reverse.

---

## Questions

**Weakening — ask first, every time**

1. Was any assertion removed, loosened, or made more permissive? Quote the before and after.
2. Was any test deleted, skipped, renamed into obscurity, or excluded from a run configuration?
3. Was a coverage threshold, a timeout, or a tolerance changed? Why?
4. Was a golden regenerated? **Was the visual diff actually reviewed**, and what changed in it?
5. Was an `// ignore:` or an analyzer suppression added in test code?

Any "yes" requires a justification that stands on its own. "The test was flaky" is a reason to fix the flake, not to delete the test.

**Coverage of the change**

6. Does every new behaviour have a test? Name the test for each.
7. Does every acceptance criterion in the SPEC map to a named test?
8. Are all six UI states tested for each new data-backed surface?
9. Is every new failure path tested, or only the happy path?
10. For a bug fix: is there a regression test that **fails before the fix**? Was that verified, or assumed?

**Test quality**

11. Does any test assert an implementation detail — a private method call, an internal field, a widget type that could change?
12. Does any test find widgets by user-visible string literal instead of by key or semantics?
13. Is each test named for the behaviour and the condition it covers?
14. Does any test contain a loop or a conditional?
15. Does any test assert several unrelated outcomes?

**Determinism**

16. Does any test depend on a real clock, real network, real randomness, real file system, or `Future.delayed` for synchronisation?
17. Does any test depend on execution order or on state left by another test?
18. Does any test depend on the machine's locale, timezone, or screen size?
19. For goldens: fixed surface size, loaded test font, fixed theme, no animation, no time dependence?
20. Was the suite run more than once to check for flakes?

**Doubles**

21. Is anything mocked that is owned and cheap to instantiate?
22. Is over-stubbing encoding the implementation into the test — would a legitimate refactor break it?
23. Are interactions verified only where the interaction *is* the requirement?

**Evidence**

24. What is the observed test output — total, passed, failed, skipped? Quote it.
25. What is the coverage number, and did it move?

---

## Output

| # | Severity | File:line | Finding | Effect on confidence |
|---|----------|-----------|---------|----------------------|

Plus a weakening ledger: every assertion, test or threshold made more permissive, with its justification.

---

## Verdict rules

| Condition | Severity |
|-----------|----------|
| A test deleted, skipped or weakened without justification | blocker |
| A golden regenerated without reviewing the diff | blocker |
| A bug fix with no failing-before regression test | blocker |
| A coverage threshold lowered to pass | blocker |
| Non-determinism introduced (real clock, network, randomness) | blocker |
| A new failure path untested | major |
| An acceptance criterion with no test | major |
| Assertions on implementation details | major |
| Finding widgets by string literal | major |
| Over-mocking an owned type | minor |
| A test asserting several unrelated outcomes | minor |

**A passing suite is not evidence of a working system if the suite was adjusted to pass.** The weakening ledger is the part of this report a reviewer should read first.
