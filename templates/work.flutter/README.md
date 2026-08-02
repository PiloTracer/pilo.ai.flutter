# `.work.flutter/` — Flutter Agent OS project memory

Everything the framework knows about **this project**. Nothing here is application source; nothing here is imported by `lib/`.

Cross-session continuity lives here. An agent that reads this tree correctly can resume work without re-deriving anything; an agent that skips it re-litigates decisions that were already made.

---

## Map

| Path | Owns | Written by |
|------|------|-----------|
| `STACK.md` | The locked technology stack | `@flutter-stack set` |
| `context/HANDOFF_FLUTTER.md` | Session history: what happened, what is open | every skill |
| `plans/NEXT_FLUTTER.md` | The single active pointer + the current iteration block | `@flutter-session`, `@flutter-implementation` |
| `plans/foundation/01…05` | Product intent, users, architecture, domain, risks | `@flutter-foundation` |
| `plans/foundation/PROBE_LEDGER.md` | Questions asked and answered during probing | probing skills |
| `plans/ASSUMPTIONS.md` · `RISK_REGISTRY.md` · `UNKNOWNS.md` | Registries carried into the master plan | `@flutter-foundation` |
| `plans/full/` | The master implementation plan | `@flutter-plan-master` |
| `features/<slug>/` | Feature SPECs and their probe ledgers | `@flutter-feature-spec` |
| `standards/` | **Project copies of standards, tokens filled — binding** | `@flutter-foundation` P3 |
| `decisions/` | ADRs | any skill making a non-obvious decision |
| `concepts/` | FLS concept run outputs | `@flutter-concept-run` |
| `reports/` | Verification and audit outputs | verifiers |
| `docs/` | Guides, tutorials, reference, runbooks | `@flutter-docs` |
| `analysis/` | Scratch analysis, brownfield harvests | `@flutter-plan-repair` |
| `PROTECTED_SURFACES.json` | Paths needing explicit approval | operator |
| `touch-scope` | The current task's declared file scope | `@flutter-implementation` |

---

## Reading order

1. `context/HANDOFF_FLUTTER.md` — the last few entries
2. `plans/NEXT_FLUTTER.md` — what to do now
3. `STACK.md` — the constraints in force
4. Whatever the current task names

Front matter first. Reading five full documents to answer "where was I" burns the context the actual work needs.

---

## Rules

- **Append, never rewrite** history in HANDOFF. The trail is the value.
- **Exactly one active pointer** in NEXT.
- **Certifications are explicit.** Readiness is read from a certification line, never inferred from how complete a document looks.
- **Project standards here override framework standards.** Once P3 has filled the tokens, this copy is what binds.
- Dated files use a `YYYYMMDD-` prefix.
- This tree is committed. It is the project's memory, and it is worthless on one person's laptop.
