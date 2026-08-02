---
title: Master Plan — Fieldnote
status: Approved
owner: A. Operator
created: 2026-08-01
last-updated: 2026-08-01
foundation-certified: 2026-08-01
---

# Master Plan — Fieldnote

Fixture: must pass both `master-plan-verify.sh` and `traceability-verify.sh`.

## 1. Summary
Offline-first field notes for site inspectors. Ships when an inspector can capture, attach and sync a note without a connection.

## 2. Source foundation
`.work.flutter/plans/foundation/` docs 01–05, certified 2026-08-01. Probe ledger: all ★ dimensions confirmed.

## 3. Technology stack
Per `STACK.md`: Riverpod, go_router, freezed + json_serializable, dio, drift, mocktail. This plan does not re-decide any of them.

## 4. Architecture summary
Three layers, feature-first. Domain is pure Dart. Dependencies point inward only.

## 5. Scope
**In:** capture, attachments, sync.
**Out:** multi-tenant, web, real-time collaboration.
**Cut list, in order:** attachments compression, sync conflict UI, export.

## 6. Functional requirements
- FR1 Capture a note with no connectivity — source FT-01
- FR2 Attach a photo to a note — source FT-02
- FR3 Sync queued notes when connectivity returns — source FT-03

## 7. Non-functional requirements
- NFR1 Cold start ≤ 2000 ms on a Pixel 6a, profile mode, cold install
- NFR2 WCAG 2.2 AA, zero violations on all capture surfaces

## 8. Platform matrix
Android 8+ (SDK 26), iOS 15+. No web, no desktop. Camera differs: iOS requires a usage string, Android requires a runtime request.

## 9. Domain and data plan
Entities: Note, Attachment, SyncQueueEntry. Drift, migrations numbered from 1. Notes and queue persist; remote profile data caches for 24h.

## 10. Navigation map
go_router. `/` (list), `/note/:id` (detail, auth guard), `/sync` (status). Deep links: `/note/:id` only, id validated before use.

## 11. Milestones
- F0 Skeleton — structure, CI, theme, routing shell. Demo: app launches to an empty list.
- F1 Offline capture — Demo: create and read a note in airplane mode.
- F2 Attachments — Demo: attach a photo to a note offline.
- F3 Sync — Demo: queued notes reach the server when connectivity returns.

## 12. Task breakdown
- F0-T1 Scaffold the project — files: lib/, test/ — S — traces: FR1 — verify: `flutter test` — depends: none
- F1-T1 Note entity and repository — files: lib/domain/, lib/data/ — M — traces: FR1 — verify: unit tests — depends: F0-T1
- F1-T2 Capture screen — files: lib/features/capture/ — M — traces: FR1, NFR2 — verify: widget + a11y tests — depends: F1-T1
- F2-T1 Attachment capture and storage — files: lib/features/attachments/ — L — traces: FR2 — verify: widget tests — depends: F1-T2
- F3-T1 Sync queue and retry — files: lib/data/sync/ — L — traces: FR3 — verify: integration test — depends: F2-T1
- F3-T2 Startup budget measurement — files: lib/main.dart — S — traces: NFR1 — verify: `@flutter-perf startup` — depends: F3-T1

## 13. Traceability matrix
| Requirement | Milestone | Tasks | Verified by |
|-------------|-----------|-------|-------------|
| FR1 | F0, F1 | F0-T1, F1-T1, F1-T2 | unit + widget |
| FR2 | F2 | F2-T1 | widget |
| FR3 | F3 | F3-T1 | integration |
| NFR1 | F3 | F3-T2 | `@flutter-perf startup` |
| NFR2 | F1 | F1-T2 | `@flutter-a11y test` |

## 14. Verification strategy
Task gate on every task. `@flutter-verify milestone` at each milestone close. FLS-09 on F1 and F3, FLS-10 on F1-T2, FLS-08 on F3-T2, FLS-06 on all agent-authored changes.

## 15. Test plan
Unit 60%, widget 30%, golden 5%, integration 5%. Coverage floor 70%. Goldens on Android only. Integration journey: capture offline, restore connectivity, confirm sync.

## 16. Release plan
Flavors: dev, staging, prod. Internal alpha after F1, closed beta after F3. Signing owned by the release manager; obfuscation on with symbols archived.

## 17. Risks
| ID | Risk | Likelihood | Impact | Mitigation | Sequencing consequence |
|----|------|-----------|--------|------------|------------------------|
| R1 | Drift migration complexity | medium | high | Test from every prior version | Schema work lands in F1, not F3 |
| R2 | Photo storage sizing unknown | high | medium | Measure during F2 | F2 cannot close until measured |

## 18. Assumptions
| ID | Assumption | If wrong |
|----|-----------|----------|
| A1 | Inspectors use employer-issued Android devices | iOS becomes primary; F0 platform work doubles |

## 19. Open questions
| ID | Question | Blocks | Owner |
|----|----------|--------|-------|
| Q1 | Photo retention policy | F2 storage sizing | Product |

## 20. Concept / NFR registry
| Concept | Milestone | Status |
|---------|-----------|--------|
| FLS-09 offline data integrity | F1, F3 | pending |
| FLS-10 accessibility | F1 | pending |
| FLS-08 performance budget | F3 | pending |
| FLS-06 AI-assisted change safety | all | per change |

## 21. Revision history
- 2026-08-01 Created from the certified foundation.
