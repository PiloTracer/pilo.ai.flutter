---
status: unlocked
locked-by: —
locked-date: —
---

# Technology stack — REPLACE:FLUTTER_PROJECT_NAME

**Status: UNLOCKED.** `@flutter-stack set` fills this file and flips the status. Until then the project is at readiness state `scaffold`, and `@flutter-scaffold app` and `@flutter-foundation` P2 are gated.

Once locked, this file is **binding**. Skills generate code against it. Changing a locked dimension after implementation begins is a re-architecture: it requires an ADR and a migration plan, not an edit.

Every package must be free, open source and commercial-use-permitted — [`PACKAGE_LICENSE_STANDARD`](standards/20260801-PACKAGE_LICENSE_STANDARD.md). Versions are **verified on pub.dev** at lock time, never recalled from memory.

---

## Locked decisions

| # | Dimension | Choice | Version | Licence | Why this one |
|---|-----------|--------|---------|---------|--------------|
| K1 | State management | `REPLACE:FLUTTER_STATE_MANAGEMENT` | | | |
| K2 | Navigation | `REPLACE:FLUTTER_NAVIGATION` | | | |
| K3 | Dependency injection | `REPLACE:FLUTTER_DI` | | | |
| K4 | Serialisation / models | `REPLACE:FLUTTER_SERIALIZATION` | | | |
| K5 | HTTP client | `REPLACE:FLUTTER_HTTP` | | | |
| K6 | Local store | `REPLACE:FLUTTER_LOCAL_STORE` | | | |
| K7 | Test doubles | `REPLACE:FLUTTER_TEST_DOUBLE` | | | |

**Idiom guide:** `stacks/REPLACE:FLUTTER_STATE_MANAGEMENT.md` — read before generating code.

---

## Supporting packages

| Package | Version | Licence | Purpose | Platforms | Replacement if abandoned |
|---------|---------|---------|---------|-----------|--------------------------|

The last column is the one that gets skipped and the one that matters during an incident.

---

## Rejected alternatives

Recording rejections prevents the decision being re-litigated every quarter by people who cannot see why the alternative was refused.

| Considered | Rejected because |
|------------|------------------|

---

## Constraints that drove the choice

| Constraint | Source |
|------------|--------|
| Team experience | probe |
| Platform targets | foundation doc 02 |
| Offline requirement | foundation doc 05 |
| Licence policy | PACKAGE_LICENSE_STANDARD |

---

## Change log

| Date | Dimension | From → To | ADR | Migration |
|------|-----------|-----------|-----|-----------|
