# Project documentation

Guides, tutorials, reference and runbooks written by `@flutter-docs`. Rules: [`DOCUMENTATION_STANDARD`](../standards/20260801-DOCUMENTATION_STANDARD.md).

Distinct from planning artifacts: SPECs hold requirements, the master plan holds sequence, standards hold rules, ADRs hold decisions. **Documentation explains how to do things.** Duplicating the other four creates a second source of truth that drifts.

---

## Index

| Document | Kind | Reader | Status | Verified | Path |
|----------|------|--------|--------|----------|------|

---

## Layout

| Directory | Kind | Reader's question |
|-----------|------|-------------------|
| `tutorials/` | tutorial | "I'm new — get me to a working thing" |
| `guides/` | guide, runbook | "How do I do X?" / "Production is broken" |
| `reference/` | reference, explanation | "What are the parameters?" / "Why is it built this way?" |

---

## The rule that matters

**Nothing is published that was not executed.** Every code sample compiled, every command run with its observed output pasted, every path confirmed, every link resolved. Anything that could not be verified is marked inline.

Front matter carries both `updated` and `verified` dates. They are different: prose edits move the first, and only re-running everything moves the second. Without the distinction, a typo fix makes a two-year-old command look current.

---

## Expected documents

| Document | When |
|----------|------|
| Local setup guide | Immediately |
| Onboarding tutorial | Second contributor |
| Architecture overview | After foundation P2 |
| Release runbook | Before the first release |
| Incident response runbook | Before production |
