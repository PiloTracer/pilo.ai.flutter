# Risk registry — REPLACE:FLUTTER_PROJECT_NAME

Things that could go wrong, what they would cost, and what changes because of them.

**A risk that changes nothing about the plan was not a risk.** Every entry names its sequencing consequence — the thing done differently because the risk exists. Without that column this file is a worry list.

---

## Register

| # | Risk | Likelihood | Impact | Score | Mitigation | Sequencing consequence | Trigger | Owner | Status |
|---|------|-----------|--------|-------|------------|------------------------|---------|-------|--------|

**Likelihood / Impact:** low · medium · high. **Score:** the product, used only for ordering.

**Sequencing consequence:** e.g. "the payment integration moves to F1 so it fails while there is still time to change approach". This is why the riskiest technical unknown goes early.

**Trigger:** the observable event that means the risk has materialised and the contingency starts. Deciding this in advance is the difference between a plan and a reaction.

---

## Materialised

| # | Risk | When | Actual impact | Response | Lesson |
|---|------|------|---------------|----------|--------|

---

## Categories worth checking

Prompts, not a checklist to fill mechanically.

| Category | Typical risks |
|----------|---------------|
| Technical | Unproven integration, platform limitation, performance target, unmaintained dependency |
| Data | Migration on shipped devices, sync conflicts, volume growth, loss |
| Platform | Store rejection, policy change, OS release, permission tightening |
| Security | Credential exposure, dependency vulnerability, compliance finding |
| Product | Requirements shifting, unvalidated assumption, unclear success measure |
| Delivery | Single point of knowledge, dependency on another team, deadline versus scope |
| Operational | No rollback path, unverified crash reporting, no on-call |

---

## Rules

1. Every risk has an owner. "The team" is nobody.
2. Every risk names its sequencing consequence, or it is deleted.
3. High-score risks are addressed in the earliest milestone that can address them.
4. Mitigations are actions with a due point, not intentions.
5. Risks carry into the master plan §17 with their consequences intact.
