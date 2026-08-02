# FLS-06 — AI-assisted change safety

**Fires:** any agent-authored change to source or tests. **Mandatory** before `@flutter-implementation complete`.
**Standard:** [`QUALITY_GATES`](../../standards/20260801-QUALITY_GATES.md) G3 D14.

---

## Why this concept exists

Agent-authored code fails differently from human-authored code. It is **locally plausible and globally wrong**: it compiles, it reads well, it matches the surrounding style, and it quietly changed the behaviour of something three files away. It also asserts verification that never happened — "tests pass" written by a model that did not run them is the single most expensive failure mode in AI-assisted development.

Humans reviewing agent output calibrate badly, because the code *looks* like it was written by someone who understood the system. This concept forces the agent to state what it actually knows.

**The agent cannot self-classify out of this.** Agent sessions are AI-assisted by default; only a human declaring `human-only` in the same message changes that.

---

## Questions

**Blast radius**

1. List every file changed, with lines added and removed.
2. For every symbol whose signature, nullability, visibility or behaviour changed: list **every** call site. Not a sample — all of them. How was the list produced (grep? analyzer? IDE references?)
3. What subclasses, implementations or mixins are affected?
4. What generated artifacts depend on the changed source, and were they regenerated?
5. What tests exercise the changed code, and were they run?

**Adjacent behaviour**

6. What else uses the symbols you changed, and did their behaviour change too — including in ways that still compile?
7. Did you change a default value, a nullability, an error type, an ordering, or a timing? Each of these changes callers silently.
8. Did you change anything a persisted format depends on — a serialised model, a stored key, a database schema, a route path? These break users who upgrade, not you.

**Deletions and weakening**

9. What did you delete or weaken? Removed assertions, removed tests, `skip:` added, narrowed test scope, loosened a type, added `// ignore:`, lowered a threshold, broadened a `catch`?
10. For each: why was it necessary, and what is no longer being checked?

**Assumptions**

11. What did you assume about behaviour you did not read? Name each assumption and what breaks if it is wrong.
12. What did you infer from a name rather than from reading the implementation?
13. Did you rely on any package API from memory rather than from the source or the documentation? Which?

**Verification**

14. Which commands did you actually run, in this session, and what was the observed output? Quote it.
15. Which claims in your report are **not** backed by a run?
16. What could not be verified in this environment — device behaviour, other platforms, real network, real data volume, real timing?

**Review targeting**

17. Where is this change most likely to be wrong? Name the one or two places.
18. What would a hostile reviewer attack first?

---

## Output

```markdown
## FLS-06 — AI-assisted change safety · <task ID>

**Changed:** <n> files, +<n>/-<n>
**Blast radius:** <call sites, subclasses, generated artifacts, tests — and how the list was produced>
**Adjacent behaviour:** <what else changed, or "none — verified by <method>">
**Deleted or weakened:** <each item with justification, or "none">
**Assumptions:** <each, with the consequence of being wrong>
**Verified by running:** <exact commands and observed output>
**NOT verified:** <every unrun claim, every unavailable platform, every untested condition>
**Most likely wrong at:** <location + why>
```

---

## Verdict rules

| Condition | Severity |
|-----------|----------|
| A check, test or assertion was removed or weakened without justification | blocker |
| A result was reported that was not observed | blocker |
| A persisted format changed without a migration | blocker |
| Call sites were sampled rather than enumerated | major |
| An assumption is load-bearing and unverified | major |
| The **NOT verified** section is empty | major — challenge it; it is almost never true |

An empty "NOT verified" section is the tell. In a real session there is always something the agent could not check: another platform, a real device, a large dataset, a slow network, a concurrent user. An agent claiming complete verification has usually mistaken "I did not think of it" for "there is nothing".
