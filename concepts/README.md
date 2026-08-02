# Concept pack — FLS-01 … FLS-13

A **concept** is a review lens: one narrow question, asked the same rigorous way every time. Skills own workflow; concepts own judgement.

Run them with [`@flutter-concept-run`](../skills/flutter-concept-run/skill.md). Each concept is a folder containing `prompt.md`.

**Why lenses instead of "review the code":** a general review finds what the reviewer happened to think of. A lens finds what it was built to find, every time, including on the twentieth diff of the day when attention has run out.

---

## The pack

| ID | Concept | Folder | Fires when the change touches |
|----|---------|--------|-------------------------------|
| FLS-01 | Widget-tree efficiency | [`widget-tree-efficiency`](widget-tree-efficiency/prompt.md) | Widget trees, lists, `build`, animations, images |
| FLS-02 | State-management integrity | [`state-management-integrity`](state-management-integrity/prompt.md) | ViewModels, providers, state classes, disposal |
| FLS-03 | Layer boundaries | [`layer-boundary-audit`](layer-boundary-audit/prompt.md) | Imports across layers, new modules, repositories |
| FLS-04 | Async and error safety | [`async-error-safety`](async-error-safety/prompt.md) | `Future`/`Stream`, `try`/`catch`, cancellation |
| FLS-05 | Navigation integrity | [`navigation-integrity`](navigation-integrity/prompt.md) | Routes, guards, deep links, back behaviour |
| FLS-06 | **AI-assisted change safety** | [`ai-change-safety`](ai-change-safety/prompt.md) | **Any agent-authored change to source or tests** |
| FLS-07 | Platform parity | [`platform-parity`](platform-parity/prompt.md) | Channels, permissions, native config, conditional code |
| FLS-08 | Performance budget | [`performance-budget`](performance-budget/prompt.md) | Startup, heavy computation, lists, images, app size |
| FLS-09 | Offline and data integrity | [`offline-data-integrity`](offline-data-integrity/prompt.md) | Caching, local stores, migrations, sync |
| FLS-10 | Accessibility and inclusivity | [`accessibility-inclusivity`](accessibility-inclusivity/prompt.md) | Any user-facing surface |
| FLS-11 | Security and privacy | [`security-privacy`](security-privacy/prompt.md) | Auth, storage, network, permissions, logging, SDKs |
| FLS-12 | Test integrity | [`test-integrity`](test-integrity/prompt.md) | Any new or modified test |
| FLS-13 | UI craft | [`ui-craft`](ui-craft/prompt.md) | Any new or changed screen, widget or theme |

---

## Rules for every run

1. **Read the actual code.** A concept run from memory of the code is fabrication.
2. **Every finding names a file and a line.**
3. **Answer every question.** "N/A" with a reason is valid; silence is not.
4. **Observe, never repair.** Findings route to `@flutter-repair`.
5. **Measurements are run or reported unverified.** Never estimate a number into a report.
6. **Severity is not negotiable by convenience:** `blocker` (violates a hard rule) · `major` (real defect or risk) · `minor` (worth fixing) · `note`.
7. **Attach the output** to the iteration's Concept/NFR registry, the SPEC, or the PR.

---

## When each fires

| Trigger | Concepts |
|---------|----------|
| Any agent-authored source or test change | **FLS-06** (mandatory before `complete`) |
| New screen or widget | 01, 02, 05, 10, 12, 13 |
| Theme, tokens or visual polish | 13, 10 |
| New repository, source or model | 03, 04, 09, 11, 12 |
| New route or deep link | 05, 11 |
| Platform channel, permission, native config | 07, 11 |
| Migration | 09, 11 |
| Performance-sensitive work | 01, 08 |
| Auth, storage or network change | 11, 04, 09 |
| Before a release | 07, 08, 10, 11 |
| Foundation P2 (architecture) | 03 |

Three real runs beat thirteen shallow ones. `@flutter-concept-run select` justifies both its includes and its excludes for exactly this reason.

---

## Output

Short runs may be inline in the report. Long runs are written to `{FLUTTER_WORK_ROOT}/concepts/<task-id>-<slug>.md`. Either way the iteration registry row is required — an unattached run leaves no audit trail and will be re-run by the next person who wonders whether it happened.
