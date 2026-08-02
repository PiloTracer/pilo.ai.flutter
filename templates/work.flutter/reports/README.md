# Reports

Verification, audit and measurement outputs. `YYYYMMDD-<skill>-<scope>.md`.

Reports are written here when they are long enough to be unwieldy inline, or when they are evidence someone will need later: a release certification, a performance baseline, a security audit, a milestone verdict.

---

## Index

| Date | Skill | Scope | Verdict | File |
|------|-------|-------|---------|------|

---

## Rules

1. **Every claim quotes observed output.** A report is evidence, and evidence that was not observed is fabrication.
2. **`unverified` is a legitimate result and never counts as a pass.** No device, no toolchain, no network → say so.
3. Reports are **not amended after the fact**. A later run produces a later report; the earlier one stands as what was true then. This matters when someone asks what was known at release time.
4. Measurements carry their conditions: device, OS version, build mode, Flutter version, run count.
5. Findings carry file, line, severity and route.

---

## What belongs here

| Kind | From |
|------|------|
| Milestone verification | `@flutter-verify milestone` |
| Release certification | `@flutter-release certify` |
| Performance baselines and profiles | `@flutter-perf` |
| Accessibility audits | `@flutter-a11y audit` |
| Security audits | `@flutter-security audit` |
| Plan audits | `@flutter-plan-verify` |
| Brownfield harvests | `@flutter-plan-repair brownfield` |

Concept run outputs go to `../concepts/` instead, keyed by task id.
