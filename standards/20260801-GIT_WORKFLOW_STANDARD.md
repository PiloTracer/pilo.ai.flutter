# Git workflow standard — template

> **Template.** Copied to `{FLUTTER_STANDARDS_ROOT}/YYYYMMDD-GIT_WORKFLOW_STANDARD.md` with the branch model and commit format filled from foundation doc 03.

**Enforced by:** the pre-commit hook, `@flutter-verify uncommitted` and `last`, and G2 in [`QUALITY_GATES`](20260801-QUALITY_GATES.md).

---

## 1. Agent rules

**Agents never commit, push, merge, rebase, force-push, reset, or create a tag unless explicitly asked in the current message.** Git operations change shared state and are frequently hard to undo; the operator decides when.

Agents may always: read status, read diffs, read log, and describe what a commit would contain.

**Never** without an explicit request in the same message: `push --force`, `reset --hard`, `clean -fd`, history rewrites, branch deletion, or any operation on `REPLACE:MAIN_BRANCH`.

---

## 2. Branches

Model: `REPLACE:BRANCH_MODEL` (default: trunk-based with short-lived feature branches).

| Branch | Purpose |
|--------|---------|
| `REPLACE:MAIN_BRANCH` | Always releasable. Protected |
| `feature/<id>-<slug>` | One milestone task or one SPEC |
| `fix/<id>-<slug>` | A defect |
| `release/<version>` | Only if the model requires a stabilisation branch |

Name branches after the plan id where one exists: `feature/F2-T4-password-reset`. That single convention connects the branch to the plan, the SPEC, the verification report and the HANDOFF entry without anyone maintaining a mapping.

Branches are short-lived — `REPLACE:MAX_BRANCH_AGE` is the target. A branch open for three weeks is a merge conflict accruing interest.

---

## 3. Commits

Format: `REPLACE:COMMIT_FORMAT` (default `<type>: <subject>` or `<TICKET>: <subject>`).

- Imperative mood: "add password reset", not "added" or "adds".
- Subject ≤ 72 characters, no trailing period.
- Body explains **why**, wrapped at 72 columns. The diff already shows what.
- Reference the task or SPEC id.
- **No AI attribution lines, no co-author trailers for tools, no generated-by markers.**

**One logical change per commit.** A commit that fixes a bug, renames a variable and reformats a file cannot be reviewed, reverted or bisected. If the commit message needs the word "and", it is probably two commits.

Never commit: secrets, credentials, keystores, `.env` files, large binaries above `REPLACE:MAX_BLOB_KB` KB without justification, commented-out code, or debug statements.

Generated files are committed **with** the source that produced them, never separately — a commit where `.g.dart` and its source disagree does not build.

---

## 4. What is committed

| Committed | Not committed |
|-----------|---------------|
| `pubspec.lock` (apps) | `pubspec.lock` (libraries) |
| Generated `.g.dart`, `.freezed.dart` | Build outputs (`build/`, `.dart_tool/`) |
| Golden reference images | Failure images from a golden run |
| `.work.flutter/` project memory | Local editor and OS files |
| Platform project files | Signing material, `key.properties`, `*.jks`, `*.p12` |
| CI configuration | Coverage output |

Verify the ignore rules rather than assuming them — `@flutter-release prepare` includes a gitignore audit precisely because the cost of getting this wrong is a leaked signing key.

---

## 5. Pull requests

A PR states: what changed and why, the task or SPEC ids, the verification results actually observed (commands and counts), screenshots or recordings for UI changes, migration or breaking-change notes, and what a reviewer should look at hardest.

For an agent-authored PR, the **FLS-06 output is attached** — blast radius, assumptions, and explicitly what was not verified. A reviewer who does not know what the agent did not check cannot calibrate their review.

Keep PRs small. Review quality falls off a cliff past a few hundred lines, and a large PR gets approved rather than read.

---

## 6. Merging

- Strategy: `REPLACE:MERGE_STRATEGY` (squash by default — one plan task, one commit on the trunk).
- Merge only with a green pipeline. "It's unrelated" is how a red trunk becomes normal.
- Resolve conflicts by understanding both sides. Taking one side wholesale silently reverts someone's work.
- After a conflict resolution, **re-run the full gate** — a mechanically clean merge can still be semantically broken, and this is the case CI most often misses.

---

## 7. Tags and releases

Release commits are tagged `REPLACE:TAG_FORMAT` (default `v<version>+<build>`), annotated, and pushed only for real releases. The tag, the store submission and the changelog entry all refer to the same commit — otherwise reproducing a shipped build becomes archaeology.

---

## 8. Hooks

| Hook | Runs |
|------|------|
| pre-commit | Format check, analyzer, secret scan, protected-surface check |
| pre-push | Tests (`REPLACE:PREPUSH_TESTS`) |
| commit-msg | Format validation |

Hooks are fast or they get bypassed. Anything slower than a few seconds belongs in CI. `--no-verify` requires an explicit human decision and is never used by an agent.

---

## 9. History hygiene

- Never rewrite pushed history on a shared branch.
- **Revert forward.** A revert commit is honest; a rewritten history is a trap for everyone who already pulled.
- Keep the trunk bisectable: every commit on it should build and pass tests.
- A committed secret is **revoked and rotated**, not just removed. It remains in history, in every clone, and in every CI cache.
