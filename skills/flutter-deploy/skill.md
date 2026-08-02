---
name: flutter-deploy
description: >-
  Install, update and verify the Flutter Agent OS framework itself inside a
  target repository - thin pointer install, full file copy, clone or archive,
  and version updates that preserve local project artifacts. Distinct from
  flutter-release, which ships the app; this ships the framework. Use for
  install the framework, add Flutter Agent OS to this repo, or update the
  framework.
---

# flutter-deploy

Installs **the framework**, not the app. `@flutter-release` ships your Flutter application; `@flutter-deploy` puts this Agent OS into a repository so the other skills can run there.

**Never gated.** Installation is the step that creates the state everything else requires.

**Pairs with:** `flutter-bootstrap` (runs after install to scaffold the project work tree — install and bootstrap are different steps and both are required).

**Registry:** [`SKILL_DEPENDENCIES.md`](../SKILL_DEPENDENCIES.md)

**Hard rules:**

1. **Never overwrite project artifacts.** `.work.flutter/`, project standards, foundation docs, SPECs and plans belong to the target repo. Framework files are replaceable; project files are not.
2. **Never install over an existing install without reading its version first.** That is an `update`, and it has different rules.
3. **Verify after installing.** An install that was not verified is a claim.
4. **Record the installed version and mode.** Without this, `update` cannot reason about what changed.
5. **Respect the target's conventions.** Do not reformat, relicense or restructure the target repository.
6. **Merge, never clobber, `.cursorrules`.** Targets commonly already have one, and it may register other frameworks.
7. **State the license position.** The framework is MIT; installing it into a proprietary repo must be an informed act.

---

## Modes

| Mode | Action |
|------|--------|
| `basic - <target>` | **Thin install (default).** A pointer file plus `.cursorrules` registration; skills are read from the source location |
| `files - <target>` | **Fat install.** Copy the full framework into the target so it is self-contained |
| `repo - <target>` | Clone or unpack the framework as a directory inside the target |
| `update - <target>` | Update an existing install, preserving all project artifacts |
| `verify - <target>` | Read-only: is the install complete, consistent and usable |
| `uninstall - <target>` | Remove framework files; **never** removes project artifacts |
| `status` | Read-only: installed mode, version, drift |

### Choosing a mode

| Situation | Mode | Why |
|-----------|------|-----|
| Framework lives beside the repo on this machine; one developer or a shared checkout | `basic` | No duplication; updates are instant |
| CI, containers, or contributors who will not have the source | `files` | Self-contained and reproducible |
| The target wants the framework pinned in its own history | `repo` | Version-pinned, reviewable |
| Already installed | `update` | Preserves project artifacts |

---

## basic protocol

1. **Resolve** the target repo root (must contain `.git` or be explicitly confirmed) and the absolute framework source path. An empty directory with no `.git` is not yet a repo — run `git init -b main` in the target (operator-confirmed) before writing the pointer, or stop and ask. Do not invent a remote.
2. **Detect an existing install** — a pointer file, a framework directory, or `.cursorrules` registration. Found → stop and route to `update`.
3. **Write the pointer** `FLUTTER_AGENT_OS.md` at the target root:

```markdown
# Flutter Agent OS — installed (basic)

**Source:** <absolute path>
**Version:** <version>
**Installed:** <YYYY-MM-DD>
**Mode:** basic (thin — skills read from source)

Entry point: `<source>/START_HERE.md`
Skills: `<source>/skills/`
Project work tree: `.work.flutter/` (this repo — created by `@flutter-bootstrap init`)

Run `@flutter-bootstrap init` next.
```

4. **Register in `.cursorrules`** — append a Flutter Agent OS section. If the file exists, **merge**: read it, confirm no conflicting skill ids or contradictory rules, append only the new section, and report exactly what was added. Other frameworks' sections are left untouched.
5. **Verify** (see below) and report.

Note the tradeoff in the report: a thin install breaks if the source path moves, and does not travel with a clone. If either matters, `files` is the right mode.

---

## files protocol

Copy the framework into `<target>/.ai.flutter/` (or a confirmed alternative path).

**Copied:** `skills/`, `standards/`, `concepts/`, `templates/`, `scripts/`, `hooks/`, `stacks/`, `resources/`, `docs/`, `.quick/`, entry points, `LICENSE`.

**Never copied:** the framework's own `.git`, its `.work.flutter/`, scratch and temp directories, anything in the framework's `.gitignore`.

Then write the pointer with `Mode: files`, register in `.cursorrules`, ensure scripts are executable, and verify.

**Before copying, check for collisions.** Any existing file at a destination path is reported and left alone unless the operator confirms replacement, file by file.

---

## update protocol

The mode with the highest risk of destroying work, so it is the most constrained.

### U1 — Establish both versions

Read the installed pointer for mode and version; read the source version. Same version → report "already current" and stop unless drift is found.

### U2 — Classify every path

| Class | Examples | Update action |
|-------|----------|---------------|
| **Framework** | `skills/`, `standards/` templates, `scripts/`, `concepts/`, `stacks/` | Replace |
| **Project** | `.work.flutter/**`, project standards under the work tree, foundation docs, SPECs, plans, `HANDOFF_FLUTTER.md`, `NEXT_FLUTTER.md` | **Never touch** |
| **Merged** | `.cursorrules`, `analysis_options.yaml`, CI workflows | Merge with report |
| **Locally modified framework file** | A skill the target edited | **Stop and ask** — never silently discard local work |

### U3 — Detect local modification

Compare installed framework files against the source's corresponding version. Any file that differs from both the old and the new source version was locally modified. List each one and ask before replacing; offer to preserve it as `<file>.local` alongside the update.

### U4 — Apply, then verify

Replace framework files, merge merged files, run `verify`, and report a changelog:

```markdown
## @flutter-deploy update

**Version:** <old> → <new> · **Mode:** <mode>

| Change | Count | Detail |
|--------|-------|--------|
| Skills updated | 4 | flutter-verify, flutter-test, … |
| Skills added | 1 | flutter-perf |
| Standards updated | 2 | … |
| Merged | 1 | `.cursorrules` — added 1 section |
| Preserved (local edits) | 1 | `skills/flutter-data/skill.md` → kept, `.new` written beside it |
| Project artifacts touched | **0** | |

**Breaking changes:** <renamed skills, changed verbs, moved paths — with the migration action>
**Verify:** PASS
**Run next:** `@flutter-session status`
```

Renamed skills or changed verbs are breaking and must be called out explicitly, with the rename mapping — stale `@` handles in a target's HANDOFF and NEXT will otherwise fail silently.

---

## verify protocol

| # | Check | Fails when |
|---|-------|-----------|
| 1 | Pointer file exists and is readable | missing |
| 2 | Source path (basic) resolves | dangling |
| 3 | Every skill in `skills/README.md` has a `skill.md` | any missing |
| 4 | `.cursorrules` registers the framework | missing section |
| 5 | Scripts are executable | not `+x` |
| 6 | No skill id collides with another installed framework | collision |
| 7 | Version recorded and matches the source | mismatch |
| 8 | Project artifacts intact (update only) | any modified |
| 9 | `scripts/framework-verify.sh` passes | non-zero exit |
| 10 | Target `.gitignore` excludes framework scratch paths | not excluded |

Report per check with the evidence, then a single verdict. Failures name the fix command.

---

## Cohabitation

When `.ai` or `.ai.ui` is already installed:

- Skill ids never collide — every skill here is `flutter-` prefixed.
- Work trees never collide — `.work.flutter/` versus `.work/` and `.work.ui/`.
- `.cursorrules` gets an additive section; other frameworks' sections are preserved verbatim.
- Cross-framework routing is described in [`COHABITATION.md`](../../COHABITATION.md).

If a collision is detected anyway, **stop**. Do not rename another framework's skills to make room.

---

## Anti-patterns

- Overwriting `.cursorrules` instead of merging.
- Touching `.work.flutter/` during an update.
- Replacing a locally modified skill without asking.
- Installing over an existing install instead of updating.
- Copying the framework's `.git` into the target.
- Reporting success without running `verify`.
- A thin install where the source path is temporary or user-specific, without saying so.
- Renaming another framework's skills to resolve a collision.
- Silent breaking changes to skill names or verbs.
- Installing without stating the license.
- Stopping at install and never mentioning that `@flutter-bootstrap init` is still required.

---

## Completion checklist

| # | Check | Result | Evidence |
|---|-------|--------|----------|
| 1 | Target root resolved and confirmed | pass/fail | path |
| 2 | Existing install detected before writing | pass/fail | |
| 3 | Mode chosen deliberately; tradeoff stated | pass/fail | |
| 4 | `.cursorrules` merged, not overwritten | pass/fail | diff |
| 5 | No project artifact modified | pass/fail | git status |
| 6 | Locally modified framework files surfaced, not discarded | pass/skip | list |
| 7 | Collisions with other frameworks checked | pass/fail | |
| 8 | Version and mode recorded in the pointer | pass/fail | |
| 9 | `verify` run; all 10 checks reported | pass/fail | verdict |
| 10 | Breaking changes called out with migrations | pass/skip | |
| 11 | License position stated | pass/fail | |
| 12 | Next step (`@flutter-bootstrap init`) given | pass/fail | |
