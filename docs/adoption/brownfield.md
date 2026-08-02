# Brownfield adoption

You have a working Flutter app. It has history, conventions, and decisions nobody wrote down. This is how the framework adopts it without breaking anything.

**The governing principle:** the product decisions already exist. They are in the code. Your job is to recover them, not to invent better ones. A foundation document that describes the app you wish you had produces a plan for a different application.

---

## 1 — Scaffold, safely

```
@flutter-bootstrap init
```

Detects brownfield and behaves accordingly: never overwrites `analysis_options.yaml`, `.cursorrules`, or any existing file. Where a file exists, it reports and moves on. Where it can merge between markers, it merges.

Read the run report before continuing. If it skipped something you expected, that is information about what your project already has.

Existing git hooks are preserved: the installer renames yours to `<hook>.local` and chains to it.

---

## 2 — Detect the stack

```
@flutter-stack detect
```

Infers the seven dimensions from `pubspec.yaml` and the code. Then **confirm each one**. Inference finds what is imported; it cannot tell you which of two state management libraries in the same repo is the one you intend to keep.

Common findings, and what they mean:

| Finding | Reality |
|---------|---------|
| Two state management libraries | A migration in progress, or an abandoned one. Decide which |
| Both `http` and `dio` | Usually a dependency pulled one in. Check `dart pub deps` |
| `shared_preferences` holding tokens | A security finding. Record it now; fix it deliberately later |
| No DI | Constructor wiring, or globals. Both are valid to record |

Record what **is**, then decide separately what should change. Conflating those two steps is how adoption turns into an unplanned refactor.

---

## 3 — Score honestly

```
@flutter-plan-verify brownfield
```

Scores what exists against what the framework expects — architecture, tests, standards, documentation, security. The output is uncomfortable by design.

Read it as a **map, not a verdict**. A mature app scoring poorly on framework artifacts is a normal result: it has been shipping without them. The score tells you where the risk is concentrated, not that the app is bad.

---

## 4 — Recover the foundation

```
@flutter-plan-repair brownfield
```

Synthesises foundation documents **from the code**. Archaeology, not design.

Every recovered statement carries an honesty marker:

```markdown
- Users authenticate with email and password.        [observed: lib/features/auth/]
- Sessions appear to expire after 30 days.           [inferred: token TTL constant]
- Offline behaviour is undefined.                    [gap: no evidence either way]
```

Three markers, three meanings. `observed` is in the code. `inferred` is a reasonable reading that could be wrong. `gap` is honest ignorance, and it is the most valuable of the three — it is a list of things nobody has decided, which is exactly what you want to find before planning.

Confirm the inferences with someone who knows the app. Where nobody knows, it stays a gap and goes to `UNKNOWNS.md`.

---

## 5 — Plan forward

```
@flutter-plan-master greenfield
```

Plans from where you actually are. Existing functionality is not re-planned; it is recorded as the baseline. Milestones cover what is next, plus any remediation you chose to schedule.

**Remediation is scheduled, not assumed.** The score in step 3 will list divergences. Each one gets a decision:

| Decision | When |
|----------|------|
| Accept | The divergence is deliberate and works. Record it as a project standard variation |
| Schedule | It matters, but not now. It becomes a task with a milestone |
| Fix now | Security or data integrity. These do not wait |

What you must not do is silently start writing new code to the framework's conventions while the rest of the app follows different ones. That produces two codebases in one repository, and neither is consistent.

---

## Working in a mixed codebase

New code follows the project standards in `.work.flutter/standards/` — which, after step 4, reflect **your** conventions where you kept them and framework conventions where you adopted them.

**Do not refactor adjacent code while implementing a feature.** It inflates the blast radius, mixes intentional change with incidental change in one diff, and makes review impossible. `blast-radius-check.sh` will flag it. Schedule the refactor as its own task.

**Do not "fix" a file's style while editing it.** A one-line behavioural change inside a forty-line reformat is a change nobody can review.

---

## Verification on a codebase with existing findings

The first `@flutter-verify milestone` on a mature app will produce a long list. Most of it predates your work.

Establish a **baseline**: record the findings that exist before you start, and hold new work to a stricter standard than old work. The rule is that the count does not increase. Reducing it is a scheduled activity, not something to attempt inside a feature task.

`@flutter-verify uncommitted` scopes to your diff and is the one to use day to day.

---

## Sequence

1. `@flutter-bootstrap init` — scaffold, break nothing
2. `@flutter-stack detect` — infer, then confirm every dimension
3. `@flutter-plan-verify brownfield` — the honest score
4. `@flutter-plan-repair brownfield` — recover from code, with honesty markers
5. Confirm inferences with a human who knows the app
6. Decide each divergence: accept, schedule, or fix now
7. `@flutter-plan-master greenfield` — plan forward
8. Establish the finding baseline
9. Work normally

## The three failure modes

**Rewriting instead of recovering.** The synthesised foundation describes the app you would build today. The plan built on it does not match the app that exists, and every task inherits the mismatch.

**Adopting everything at once.** Framework conventions applied to a mature codebase in one pass is a rewrite wearing a smaller name. Adopt for new code; schedule migration for old.

**Treating the brownfield score as a judgement.** It measures artifact presence, not software quality. A well-loved app with no framework documents scores badly and works fine. Use the score to find risk, not to justify a rewrite.
