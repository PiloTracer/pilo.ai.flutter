# FLS-13 — UI craft

**Fires:** any new or changed screen, widget or presentation file; theme/token changes; visual polish work.
**Standard:** [`UI_CRAFT_STANDARD`](../../standards/20260802-UI_CRAFT_STANDARD.md) · evidence base with sources: [`resources/ui-craft.md`](../../resources/ui-craft.md).

The question this lens asks: **does this screen look like somebody made deliberate decisions — or like defaults that shipped?** A screen can pass every correctness check and still read as "free template" to the client paying for it. That is a product defect, and it is found by looking, not by tests.

---

## Questions

**Decisions recorded**

1. Is the screen's single dominant element recorded in SPEC §5, and is it the element that actually dominates on screen? Name both.
2. Is the screen's single primary action recorded, and is there exactly one?
3. Are there user-facing decisions made by default rather than on purpose — seed colour never chosen, placeholder copy, stock icons standing in for a decision?

**Spacing rhythm**

4. Does every spacing value come from the theme scale? List any raw `EdgeInsets` / `SizedBox` / `Gap` literals in the diff (the hygiene scan finds these — quote it).
5. How many distinct spacing values does the screen use? More than the per-screen maximum needs the recorded reason.
6. Is grouping expressed with spacing (proximity), or with borders where spacing would separate better?

**Hierarchy**

7. At arm's length, does the eye land on the dominant element first? What actually draws the eye instead, if anything?
8. Is the dominant element at the standard's ratio to body text (default 2.5×, honest range 2–3×)? Compute it from the theme roles.
9. Is anything competing with the dominant element — a second large value, an oversized title, a loud illustration?

**Colour and accent**

10. Where does the accent colour appear on this screen? If it is on more than the primary action, list every location.
11. Any factory palette in the diff — `Colors.<name>` constants, an untouched default seed, stock Material blue/green/red? (Hygiene scan: quote it.)
12. Count the saturated colours on the screen. More than one, beyond desaturated semantic states, is a fight for attention on what is usually a one-task screen.
13. Is everything else neutrals from the ramp — text, secondary text, borders, backgrounds?

**States and copy**

14. Do the six states match SPEC §6, executed to the standard's §6 bar: loading per the <1s / 2–10s / >10s thresholds, skeletons that mimic the real layout, empty states that teach?
15. Read every error message aloud. Plain language, adjacent to its source, problem + fix, no codes or jargon? Quote the worst one verbatim.
16. Could a non-technical first-time user say what to do on this screen within five seconds? What would confuse them?

**Finish**

17. Dark mode: checked, or assumed? Same for 200% text scale. Evidence, not recollection (cross-check FLS-10).
18. Motion: from tokens, subtle, reduce-motion honoured? Any ad-hoc `Duration` in the diff?
19. What was looked at on a real device or emulator, at what size — and what was only ever seen in code?

---

## Output

| # | Severity | File:line / screen | Signal | Finding | Remedy |
|---|----------|--------------------|--------|---------|--------|

Signals: `spacing` · `hierarchy` · `colour` · `states` · `clarity` · `finish`. Plus: the accent-location list (Q10), the saturated-colour count (Q12), and an explicit split between what was seen rendered and what was judged from code.

---

## Verdict rules

| Condition | Severity |
|-----------|----------|
| Factory palette in shipped UI (`Colors.<name>` outside theme, untouched default seed) | blocker |
| Accent colour on ≥ 2 competing elements on one screen | blocker |
| New or changed screen with no dominant element / primary action recorded in SPEC §5 | blocker |
| Raw spacing or `fontSize:` literals in the diff (hygiene scan hits) | blocker |
| Ratio-1 hierarchy — nothing dominates, eye has no entry point | major |
| Loading state contradicts the thresholds (spinner flash < 1s; bare spinner > 10s) | major |
| Error copy with codes, jargon, no recovery path, or far from its source | major |
| More than the per-screen spacing-value maximum without a recorded reason | major |
| Information or status conveyed by colour alone | major (and an FLS-10 blocker) |
| Skeleton shapes that do not mimic the real layout | minor |
| Ad-hoc `Duration` outside motion tokens | minor |
| Dark mode or 200% text scale asserted without being rendered | major — and the claim downgraded to `unverified` |

**Judged from code is not seen.** Hierarchy and rhythm questions answered without rendering the screen (widget test, emulator, device, or golden) are reported as `unverified`, never as pass. The polish pass in UI_CRAFT_STANDARD §8 is the walkthrough; this lens is its evidence.
