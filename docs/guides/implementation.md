# Implementation

The loop that turns an approved plan into working software, one gated task at a time.

**Prerequisite:** `implementation-ready`. Writing code against an unapproved plan is writing against a moving target, and the skill will refuse.

---

## The loop

```
plan - F<n>     write the iteration block
start           load context, record assumptions
continue        one task → gate → next task
complete        full iteration gate, update memory
```

### plan

Selects a milestone from the master plan and writes an iteration block into `NEXT_FLUTTER.md`: in scope, out of scope, tasks with ids, acceptance criteria, validation commands, blockers, and the applicable concepts.

**Out of scope is not decoration.** It is what you point at when something tempting appears mid-iteration.

### start

Loads the SPEC, the standards the tasks touch, and the stack idiom guide. Records an assumption ledger — everything being treated as true without confirmation. Assumptions written down get challenged; assumptions in someone's head do not.

### continue

One task at a time. Write the code, run the gate, record the evidence, move on. Batch progress is reported so you can see drift early rather than at the end.

**Stop conditions** — the agent halts and reports instead of pushing through:

- A task needs a decision only the operator can make
- The task turns out to need work outside the declared scope
- A gate fails for a reason the task cannot fix
- The SPEC is ambiguous on a point that matters
- A dependency is missing

Pushing through any of these produces work that has to be redone.

### complete

Runs the full iteration gate, updates documentation, advances `NEXT_FLUTTER.md` to exactly one new pointer, and appends to `HANDOFF_FLUTTER.md`.

---

## The task gate

Nine checks. A task is not done because the code is written; it is done when the gate passes and the evidence is recorded.

| # | Check | Blocker |
|---|-------|---------|
| 1 | `dart format --set-exit-if-changed .` | yes |
| 2 | `flutter analyze` — 0 errors, 0 warnings | yes |
| 3 | `flutter test` | yes |
| 4 | Codegen produces no diff | yes |
| 5 | Changed files match `touch-scope` | yes |
| 6 | No secrets | yes |
| 7 | No package outside `STACK.md` | yes |
| 8 | `dart-hygiene-check.sh` blockers | yes |
| 9 | SC1 self-critique | yes |

**SC1** is the one that catches the subtle problems, and it only works if answered honestly:

- What did I change that the task did not ask for?
- What did I assume that I did not verify?
- What did I not test?
- What would break if my assumption is wrong?
- What did I make worse to make this work?

An agent that answers "nothing" to all five is not being careful, it is being agreeable. There is almost always something for question three.

---

## Scope discipline

Declared in `.work.flutter/touch-scope`, enforced by the pre-commit hook.

**Scope creep is the most common way agent-assisted work goes wrong.** Not through a bad decision, but through many small reasonable ones: while I am here, this could be cleaner; this variable name is wrong; this deserves a helper. Each is defensible. Together they produce a diff nobody can review, where the intentional change is hidden among forty incidental ones.

Found something worth fixing? Record it in the backlog. Fix it in its own task with its own gate.

Genuinely need to widen scope? Say so, get agreement, update `touch-scope`. Widening it silently is what the check exists to prevent.

---

## Writing to the SPEC

The SPEC is the contract. Two sections cause almost all the rework.

**§6 — the six states.** Loading, empty, success, error, partial, offline. The happy path is easy and is never where features fail. A surface that only handles success is a surface that will show a blank screen to a user on a bad connection.

**§9 — error handling.** Every failure has a user-visible outcome. A failure that only logs is, from the user's side, the app doing nothing.

SPEC ambiguous? **Stop and ask.** Do not implement your best guess — a guess implemented is a guess that now has tests around it.

---

## Where agent-written code goes wrong

These are the specific patterns FLS-06 exists to catch. They are all cases where the code looks correct.

| Pattern | Why it happens |
|---------|---------------|
| Changed a default value | Adjusting a signature to fit the new call site, without checking the old ones |
| Widened or narrowed nullability | Same |
| Changed the error type a function throws | The new path needed a different one; the old catch no longer matches |
| Changed a persisted format | Adding a field to a serialised model without a migration |
| Removed an assertion "that was failing" | It was failing because it was correct |
| Weakened a test to reach green | The fastest route to a green run, and it destroys the signal |
| Regenerated a golden without looking | Hides a real visual regression |
| Reported a test result that was not run | Pattern-matching on what usually happens |

The last one is the most dangerous, because it is invisible. It is why every claim in this framework requires quoted output.

---

## Evidence

```markdown
- [x] F1-T3 — Profile repository
  - `flutter analyze` → No issues found. (ran 2026-08-01 14:22)
  - `flutter test test/data/profile_repository_test.dart` → 00:02 +7: All tests passed!
  - Files: lib/data/repositories/profile_repository_impl.dart (+84)
           test/data/profile_repository_test.dart (+112)
  - SC1: mapped only the four documented failure codes; an unknown code
    currently falls through to `Failure.unknown`. Not covered by a test.
```

That SC1 note is the point of the exercise. It is a real gap, recorded by the agent that created it, findable by the next verifier.

---

## Delegation

| Work | Skill |
|------|-------|
| Entities, DTOs, repositories, migrations | `@flutter-data` |
| Channels, permissions, deep links, native config | `@flutter-platform` |
| Test authoring | `@flutter-test` |
| Anything with a measured number | `@flutter-perf` |

These skills carry rules that would not fit in the implementation gate — migration idempotence, permission triple-path handling, golden determinism. Bypassing them means those rules are not applied.

---

## Between sessions

`@flutter-session close` at the end, `@flutter-session context` at the start.

Everything the next session needs is in HANDOFF and NEXT. If it is not written down, it does not survive — not to a colleague, not to a different model, and not to you in three weeks.
