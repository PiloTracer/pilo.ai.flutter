# Cohabitation

Flutter Agent OS is built to live in the same repository as [Agent OS](../.ai) (`.ai`) and [UI Design OS](../.ai.ui) (`.ai.ui`). This document is the contract that makes that safe.

The failure mode being prevented is specific: two frameworks writing the same file, or one framework's agent confidently answering a question it has no authority over.

---

## Namespace

| | Flutter Agent OS | Agent OS (`.ai`) | UI Design OS (`.ai.ui`) |
|---|---|---|---|
| Skill prefix | `flutter-*` | `ai-*`, `code-*`, `plan-*` | `ui-*` |
| Work tree | `.work.flutter/` | `.work/` | `.work.ui/` |
| Session log | `.work.flutter/context/HANDOFF_FLUTTER.md` | `.work/context/HANDOFF.md` | `.work.ui/context/HANDOFF_UI.md` |
| Pointer | `.work.flutter/plans/NEXT_FLUTTER.md` | `.work/plans/NEXT.md` | `.work.ui/plans/NEXT_UI.md` |
| Concepts | `FLS-nn` | `MOD-nn` | `UIS-nn` |
| Director | `@flutter-director` | `@ai-director` | `@ui-director` |
| Standards | `standards/` directory (date-prefixed, Flutter-scoped) | general | UI-scoped |

No skill id, work path, concept id, or artifact name collides. This is enforced by `framework-verify.sh`, which fails if a Flutter skill references another framework's paths as its own.

---

## Boundaries

**Flutter Agent OS owns** Dart and Flutter source, `pubspec.yaml`, `analysis_options.yaml`, native project configuration (`android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/`), Flutter architecture and state management, the Flutter data layer, Flutter tests, Flutter build and release, and `.work.flutter/`.

**It does not own** visual design tokens, component design specs, or design system governance (`.ai.ui`); backend services, APIs, infrastructure, CI beyond the Flutter build, or non-Flutter code (`.ai`); and product strategy above the application (whichever framework the operator uses for it).

**The overlaps, resolved:**

| Overlap | Resolution |
|---------|-----------|
| Theming | `.ai.ui` decides the tokens. Flutter implements them in `ThemeData`. `THEMING_STANDARD` defers to the design system where one exists |
| Component specs | `.ai.ui` writes the spec. `@flutter-implementation` builds the widget. `@flutter-a11y` verifies it |
| API contracts | `.ai` owns the server contract. `@flutter-data` owns the client side and maps the wire format at the boundary |
| CI | `.ai` owns the pipeline. `@flutter-release prepare` contributes the Flutter jobs |
| Accessibility | Both care. `.ai.ui` sets the design-side requirement; `@flutter-a11y` verifies the running app. The app is where it is real |

---

## Routing out

A director that recognises work it does not own **routes it** rather than attempting it. That is a hard rule, not a courtesy.

```
Operator: "Make the login screen match the new design system"

@flutter-director:
  Split:
    - Token and component definition → @ui-director  (not mine)
    - Widget implementation against those tokens → @flutter-implementation (mine)
  Blocked on: the token set. Run @ui-director first; I will pick it up after.
```

The inverse holds. `@ui-director` receiving "implement this component in Flutter" routes to `@flutter-director`.

**Never:**
- Answer for a framework you are not.
- Read another framework's work tree as authoritative for your own state.
- Write into another framework's work tree.
- Assume a sibling framework's gate is satisfied. Ask, or route.

**Reading** a sibling's artifact for context is fine and often useful. Treating it as your own certification is not.

---

## Shared files

Three files can be touched by more than one framework. All three use merge semantics.

**`.cursorrules`** — each framework owns a marked block:

```
# ==== FLUTTER_AGENT_OS_BEGIN ====
...
# ==== FLUTTER_AGENT_OS_END ====
```

Installers append their block if absent and leave everything outside their markers alone. Nothing overwrites the file.

**`.gitignore`** — append-only, under a comment header. Duplicate entries are harmless; deleting another framework's entries is not.

**`README.md`, root docs** — first framework to install may create; later ones append a pointer section. Never replace.

---

## Precedence

When two standards conflict on the same question:

1. **Domain ownership wins.** Flutter code style: Flutter Agent OS. Design tokens: `.ai.ui`. Deployment topology: `.ai`.
2. **The stricter rule wins** on shared concerns (security, accessibility, evidence).
3. **The project copy beats the framework template.** `.work.flutter/standards/` is binding; `standards/` is the source.
4. **Unresolvable conflicts are escalated**, not silently resolved. Record the conflict, ask the operator, write an ADR.

---

## Installing alongside

Order does not matter. Each installer detects siblings and reports them.

```bash
bash .ai/scripts/deploy-basic.sh --target ~/app
bash .ai.ui/scripts/deploy-basic.sh --target ~/app
bash .ai.flutter/scripts/deploy-basic.sh --target ~/app
```

Result:

```
~/app/
├── .cursorrules            three marked blocks
├── .work/                  Agent OS
├── .work.ui/               UI Design OS
├── .work.flutter/          Flutter Agent OS
├── AGENT_OS.md
├── UI_DESIGN_OS.md
└── FLUTTER_AGENT_OS.md
```

Each framework bootstraps its own work tree. Running `@flutter-bootstrap init` does not set up the others, and will not touch them.

---

## Verifying cohabitation

```bash
bash scripts/framework-verify.sh          # includes path-discipline checks
grep -c 'AGENT_OS_BEGIN\|DESIGN_OS_BEGIN' .cursorrules
ls -d .work .work.ui .work.flutter 2>/dev/null
```

Signs of a broken boundary: a Flutter skill citing `.work/context/HANDOFF.md` as its session log; a `.cursorrules` with one framework's block missing after another installed; two frameworks claiming the same standard.

---

## Solo installation

Everything above is conditional. Flutter Agent OS installed alone is complete: it does not require `.ai` or `.ai.ui`, and no skill blocks on their absence. When a request needs a capability this framework does not own and no sibling is installed, the director says so plainly rather than improvising outside its competence.
