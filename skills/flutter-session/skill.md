---
name: flutter-session
description: >-
  Open and close Flutter Agent OS work sessions and maintain cross-session
  memory. Loads project context in the correct order, produces an accurate
  state snapshot, and writes the HANDOFF entry and NEXT_FLUTTER.md pointer that
  let the next session resume without re-deriving anything. Use for start
  session, where was I, what is the state, wrap up, or hand off.
---

# flutter-session

Every session ends. The only question is whether the next one starts from a written state or from archaeology. This skill owns that boundary.

**Never gated.** `status` works on a bare repo — the answer is simply "not bootstrapped".

**Pairs with:** every skill (all write HANDOFF entries), `flutter-director` (routes here for "where was I"), `flutter-plan-master` and `flutter-implementation` (own the `NEXT_FLUTTER.md` iteration block; this skill maintains the pointer around it).

**Registry:** [`SKILL_DEPENDENCIES.md`](../SKILL_DEPENDENCIES.md)

**Hard rules:**

1. **Never guess state — read it.** Every claim in a snapshot names the file it came from.
2. **Report the state that exists, not the state that should exist.** A missing certification is reported as missing, not inferred from adjacent evidence.
3. **`context` is read-only.** Loading context never writes, never fixes, never certifies.
4. **A close without a HANDOFF entry is not a close.** The entry is the deliverable.
5. **NEXT_FLUTTER.md carries exactly one active pointer.** Two "next" instructions means the next session picks wrong.
6. **Never commit or push unless explicitly asked.** Git is opt-in, always.
7. **Record blockers as blockers.** An unresolved problem that is not written down will be rediscovered at cost.

---

## Modes

| Mode | Action |
|------|--------|
| `status` | Read-only state snapshot. **Default** |
| `context` | Load project memory in the correct order for a fresh agent. Read-only |
| `open` | `context` + orient toward the next action + note session start |
| `close` | Write the HANDOFF entry, update `NEXT_FLUTTER.md`, list blockers |
| `handoff` | Write a HANDOFF entry only |
| `next - <instruction>` | Set the single active pointer in `NEXT_FLUTTER.md` |
| `blockers` | List open blockers across the work tree |

---

## Read order (canonical)

Cheapest first, and each read narrows the next. Skipping steps produces confidently wrong snapshots.

| # | File | Answers |
|---|------|---------|
| 1 | `{FLUTTER_HANDOFF}` = `.work.flutter/context/HANDOFF_FLUTTER.md` (most recent entries) | What happened last, and what was left open |
| 2 | `{FLUTTER_NEXT}` = `.work.flutter/plans/NEXT_FLUTTER.md` | What to do now; whether an iteration block is active |
| 3 | `{FLUTTER_STACK_LOCK}` | Whether the stack is locked, and to what |
| 4 | Foundation docs `01`–`05` front matter | Foundation phase progress and certification |
| 5 | `{FLUTTER_MASTER_PLAN}` front matter + milestone table | Plan status; which milestone is current |
| 6 | Active SPECs (front matter only) | What is approved, in progress, or blocked |
| 7 | `git status`, `git log --oneline -10` | Uncommitted work; recent direction |

**Front matter only** for docs 04–06 unless the answer requires more. Reading five full documents to answer "where was I" burns the context the next task needs.

---

## status protocol

```markdown
## @flutter-session status

**Readiness:** <scaffold | stack-locked | foundation-complete | plan-ready | implementation-ready | release-ready>
**Evidence:** <the file and line that establishes it>

| Layer | State | Source |
|-------|-------|--------|
| Bootstrap | done / missing | `.work.flutter/` present |
| Stack | locked / partial / unlocked | `STACK.md` front matter |
| Foundation | P0–P6 → <phase>, certified <yes/no> | doc front matter |
| Master plan | <status>, milestone <F2 of 6> | plan front matter |
| Iteration | active F2 / none | `NEXT_FLUTTER.md` |
| SPECs | <n> approved · <n> draft · <n> blocked | SPEC front matter |
| Working tree | clean / <n> modified files | `git status` |
| Blockers | <n> open | HANDOFF |

**Last session:** <date> — <one line>
**Next action:** `<exact command>`
**Blocked by:** <blocker or none>
```

**Readiness is derived only from certifications that exist.** Foundation docs that look complete but carry no certification → `foundation-complete`, not `plan-ready`. Say which certification is missing and which skill issues it.

---

## context protocol

For a fresh agent that must resume real work, not just be told the state.

1. Read in the canonical order above.
2. Read `.cursorrules` for the operating rules in force.
3. Read the standards named by the current task — not all of them.
4. If an iteration is active: read its block in full plus the SPECs it names.
5. Report what was loaded and, explicitly, what was **not**:

```markdown
## @flutter-session context

**Loaded:** HANDOFF (last 3), NEXT, STACK, plan front matter, SPEC-004
**Not loaded:** foundation docs 01–03 (not needed for F2-T3), standards beyond DART_STYLE
**Current task:** F2-T3 — <title>
**Contract:** SPEC-004 §4 — <the acceptance criterion in one line>
**Constraints in force:** <locked stack items relevant to this task>
**Ready to:** `@flutter-implementation continue - F2-T3`
```

Stating what was not loaded prevents the next agent from assuming a full read.

---

## close protocol

### C1 — Establish what actually changed

`git status` and `git diff --stat`. Compare against what the session set out to do. An unexplained gap in either direction is itself worth recording.

### C2 — Write the HANDOFF entry

Append (never rewrite history) to `{FLUTTER_HANDOFF}`:

```markdown
## <YYYY-MM-DD> — <session title>

**Skills:** @flutter-implementation, @flutter-verify
**Scope:** F2-T3, F2-T4

**Done**
- <what was completed, in terms of the task IDs and observable outcome>

**Verified**
- `flutter analyze` 0 · `flutter test` 142/142 · `@flutter-verify gate` PASS

**Decisions**
- <decision> — because <reason> · recorded in <ADR / doc / SPEC amendment>

**Open / blocked**
- <blocker> — needs <who or what> — blocks <task ID>

**Next**
- `<exact command>`
```

**Rules:** every "Done" claim names a task ID or a file. Every "Verified" claim quotes an observed result — no result, no claim. Decisions that changed a locked or certified artifact must name where they were recorded; if they were not recorded anywhere, that is a blocker.

### C3 — Update `NEXT_FLUTTER.md`

One active pointer. If an iteration block is active, leave the block alone (it belongs to `@flutter-implementation`) and update the pointer above it. If the iteration completed, the pointer becomes the next iteration's plan command.

### C4 — Report

```markdown
## @flutter-session close

**Recorded:** HANDOFF entry <date> — <title>
**Next pointer:** `<command>`
**Blockers carried:** <n> — <one line each>
**Uncommitted:** <n> files (not committed — no request to commit)
**Verification at close:** <results or "none run this session">
```

---

## blockers protocol

Scan HANDOFF open items, `NEXT_FLUTTER.md` blocked tasks, SPEC front matter with `status: blocked`, and plan tasks marked blocked. Report as:

| Blocker | Blocks | Needs | Since | Owner |
|---------|--------|-------|-------|-------|

`Needs` must be actionable: "operator decision on offline conflict policy", not "clarification". A blocker with no owner and no needed action is a stale note — flag it for removal or escalation.

---

## Anti-patterns

- Inferring readiness from how complete documents look instead of from certifications.
- Reading every foundation document to answer a one-line question.
- Closing a session without a HANDOFF entry because "nothing much happened".
- Writing "worked on the login screen" instead of task IDs and observable outcomes.
- Recording a verification result that was not observed this session.
- Leaving two competing next-actions in `NEXT_FLUTTER.md`.
- Silently dropping a blocker that was not resolved.
- Committing or pushing without being asked.
- Editing the iteration block during a close.
- Reporting "all good" when the working tree has uncommitted changes.

---

## Completion checklist

| # | Check | Result | Evidence |
|---|-------|--------|----------|
| 1 | Read order followed; every claim sourced | pass/fail | file list |
| 2 | Readiness derived from certifications only | pass/fail | certification cited |
| 3 | Missing certifications named, with the issuing skill | pass/skip | |
| 4 | `context` performed no writes | pass/skip | git diff |
| 5 | HANDOFF entry appended, not rewritten | pass/skip | |
| 6 | Every Done item names a task ID or file | pass/skip | |
| 7 | Every Verified claim quotes an observed result | pass/skip | |
| 8 | Decisions point to where they were recorded | pass/skip | |
| 9 | Exactly one active pointer in NEXT | pass/skip | |
| 10 | Blockers carried forward with owner and needed action | pass/skip | |
| 11 | No commit or push without an explicit request | pass/fail | |
| 12 | Next action is an exact runnable command | pass/fail | |
