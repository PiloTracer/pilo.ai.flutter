# FLS-05 — Navigation integrity

**Fires:** routes, guards, deep links, back behaviour, nested navigators, modals.
**Standard:** [`NAVIGATION_STANDARD`](../../standards/20260801-NAVIGATION_STANDARD.md).

---

## Why

Navigation defects are systematically under-tested because they live between screens rather than inside one. The classic cases — a deep link that skips an auth guard, a sign-in that forgets where the user was going, a back gesture that re-enters a completed checkout — all pass a screen-by-screen review.

---

## Questions

**Route definition**

1. Is every new route declared in the central route table, or is there an inline `MaterialPageRoute` push somewhere?
2. Does the route have a stable name constant, and is it used at every call site rather than a string literal?
3. Is the path URL-shaped, lowercase and hyphenated?
4. Do parameters carry identifiers rather than objects? (An object cannot exist on a cold start from a link.)
5. What happens when a parameter is missing, malformed, or refers to something that no longer exists?

**Reachability**

6. Is every new route reachable from the UI, from a link, or from a notification? An unreachable route is dead code.
7. Can the user always leave? Is there a route with no exit?

**Guards**

8. What guards apply, and are they evaluated on **every** entry path — push, deep link, notification tap, restoration, tab switch, and back?
9. Does an unauthenticated user hitting a guarded route reach sign-in **and return to their intended destination** afterwards?
10. What does an authenticated-but-unauthorised user see? (Not a blank screen, not a crash.)
11. Are guards testable without a widget tree?

**Back behaviour**

12. What does the system back gesture do on this screen — Android back, iOS swipe, and predictive back?
13. Are there unsaved changes? Is the user warned before losing them?
14. Is there an in-flight operation? Is it cancelled cleanly or does it orphan?
15. After a completed flow, is the route replaced rather than pushed, so back cannot re-enter it?
16. At the root of a tab, and at the root of the app, what happens?

**Deep links**

17. Does the link path match the internal route path, or are there two vocabularies?
18. Are link parameters validated and authorised as untrusted input?
19. Do cold start, warm start and foreground receipt all resolve to the same destination?
20. What happens for an unknown or malformed link?
21. Is the link parser unit-tested as a pure function?

**Nesting and results**

22. Do nested navigators preserve their stacks across tab switches?
23. Does an awaited route result handle the dismissal (`null`) case?
24. Do modals dismiss correctly with the system gesture?

**Instrumentation**

25. Are screen views emitted from the router rather than per screen?
26. Does any screen name include a PII-bearing parameter value?

---

## Output

| # | Severity | File:line | Finding | Entry path affected |
|---|----------|-----------|---------|---------------------|

Plus a guard matrix: route × entry path → is the guard evaluated?

---

## Verdict rules

| Condition | Severity |
|-----------|----------|
| A guard bypassed on any entry path | blocker |
| Deep-link parameter used without validation or authorisation | blocker |
| Malformed link crashes or blanks | blocker |
| Completed flow re-enterable via back | blocker |
| Intended destination lost through sign-in | major |
| Inline route construction outside the table | major |
| Unhandled `null` route result | major |
| Entity passed as a route parameter | major |
| Unsaved changes lost silently on back | major |
| Route name as a string literal | minor |
| Screen-view analytics emitted per screen | minor |
