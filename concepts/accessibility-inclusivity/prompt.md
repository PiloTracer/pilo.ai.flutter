# FLS-10 — Accessibility and inclusivity

**Fires:** any user-facing surface, text, colour, interaction, or copy.
**Standard:** [`ACCESSIBILITY_STANDARD`](../../standards/20260801-ACCESSIBILITY_STANDARD.md) · run with `@flutter-a11y audit`.

---

## Questions

**Labels**

1. Does every interactive element have an accessible label? List any that do not.
2. Does each label describe the **action**, not the icon? ("Delete message", not "trash can".)
3. Are decorative graphics explicitly excluded from the semantics tree, rather than merely unlabelled?
4. Are composite items merged into one semantic node, or does a card force three separate stops?
5. Are all labels localised, or is any hardcoded in one language?

**State and role**

6. Is every visually-perceivable state also in the semantics tree — selected, expanded, checked, disabled, busy?
7. Do custom controls expose a name, a role and a current value?
8. Are async status changes announced (loading finished, error appeared, item removed)?

**Contrast and colour**

9. Are all new foreground/background pairs at least 4.5:1 for normal text and 3:1 for large text and UI boundaries? Give the computed ratios.
10. Is any information conveyed by colour alone?
11. Do new colours come from the theme, so they were part of the palette-level contrast check?

**Text scale**

12. Does the layout survive 200% text scale with no clipping, overflow or lost function? Was it actually rendered at 200%, or assumed?
13. Are there fixed font sizes, fixed heights around text, or `maxLines: 1` on content the user needs?

**Targets and focus**

14. Are all touch targets at least 48×48 dp?
15. Is focus order logical and matching the visual order?
16. Is there a visible focus indicator?
17. On entering a dialog does focus move in; on closing does it return to the trigger; can focus escape a modal?

**Input and errors**

18. Does every input have a persistent visible label — not just a placeholder?
19. Are errors identified in text, associated with their field, and announced?
20. Does changing a field value cause an unexpected context change?

**Keyboard and switch**

21. Is every function reachable without touch?
22. Are there keyboard traps?

**Manual verification**

23. Was a screen reader actually run? Which one, on which device, on which OS version?
24. Was the flow completable without sight?
25. What was **not** verified manually?

---

## Output

| # | Severity | File:line / screen | Guideline | Finding | Remedy |
|---|----------|--------------------|-----------|---------|--------|

Plus: a contrast table with computed ratios, and an explicit split between what automation checked and what a human verified.

---

## Verdict rules

| Condition | Severity |
|-----------|----------|
| Unlabelled interactive element | blocker |
| Contrast below the ratio | blocker |
| Function unreachable by screen reader or keyboard | blocker |
| Content lost or clipped at 200% text scale | blocker |
| Information conveyed by colour alone | blocker |
| Custom control with no role or state | blocker |
| Touch target below 48 dp | major |
| Async status change not announced | major |
| Focus not managed at a modal boundary | major |
| Hardcoded (unlocalised) semantic label | major |
| Placeholder used as the only label | major |
| Illogical traversal order | major |

**Automated checks are necessary and insufficient.** They cannot tell you a label is accurate, that the order makes sense, or that the flow is completable. A screen-reader result may never be claimed without having run one — name the reader, the device and the OS.
