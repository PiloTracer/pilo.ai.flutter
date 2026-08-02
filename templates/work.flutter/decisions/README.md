# Decisions (ADRs)

One file per architectural decision: `YYYYMMDD-ADR-<nn>-<slug>.md`.

**Write an ADR whenever a competent engineer could reasonably have chosen differently.** That is the whole test. An architecture with no recorded rejections gets re-litigated every quarter by people who cannot see why the alternative was refused — and sometimes they are right, but nobody can tell without the record.

---

## Index

| ADR | Title | Date | Status | Supersedes |
|-----|-------|------|--------|-----------|

Status: `proposed` · `accepted` · `superseded` · `deprecated`.

---

## Template

```markdown
---
adr: <nn>
title: <decision in one line>
status: proposed | accepted | superseded | deprecated
date: YYYY-MM-DD
deciders: <who>
supersedes: <adr or none>
---

## Context
What forced a decision. The constraints, the pressures, what was known and unknown at the time.

## Decision
What was chosen, stated plainly.

## Alternatives considered
| Option | Why rejected |
|--------|--------------|

The most valuable section. Without it the next reader assumes nobody thought about the obvious alternative.

## Consequences
**Positive:** …
**Negative:** … (state these honestly — an ADR with no downsides was not a real decision)
**Neutral:** …

## Reversal
What it would cost to change this later, and what would trigger revisiting it.
```

---

## When to write one

| Trigger |
|---------|
| A stack dimension locked or changed |
| A layering or module boundary decision |
| A dependency with a high exit cost |
| A data model or persistence choice with migration implications |
| A security or privacy trade-off |
| A standard waived |
| A performance trade-off accepted |
| Anything an implementer chose that the SPEC did not dictate and that others must follow |
