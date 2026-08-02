# Assumptions — REPLACE:FLUTTER_PROJECT_NAME

Things being treated as true without evidence. Each one is a bet, and each states what it costs if it loses.

An unrecorded assumption is indistinguishable from a fact until it fails — usually in the milestone that depends on it most.

---

## Register

| # | Assumption | Basis | If wrong | Impact | Validate by | Owner | Status |
|---|------------|-------|----------|--------|-------------|-------|--------|

**Basis:** where it came from — a stakeholder statement, an industry norm, a previous project, or nothing but convenience. "Nothing but convenience" is a legitimate entry and a useful signal.

**If wrong:** the concrete consequence. "Rework the sync layer, roughly two weeks" beats "problems".

**Validate by:** the cheapest thing that would confirm or kill it, and when. An assumption nobody plans to test is a permanent risk wearing a different label.

**Status:** open · validated · invalidated · accepted (deliberately never testing it).

---

## Invalidated

Kept, not deleted. What was believed and why it was wrong is the most useful thing in this file for the next project.

| # | Assumption | How it failed | Cost | Date |
|---|------------|---------------|------|------|

---

## Common assumptions worth writing down

Recorded here because they are the ones most often left implicit, and among the most expensive when wrong:

- The API contract will not change during the build.
- Users have reliable connectivity.
- The data volume per user stays within the range we designed for.
- The third-party SDK will stay maintained and keep its licence.
- The design will not change materially after implementation starts.
- One developer's device performance represents the user base.
- The backend enforces the rules the client assumes it does.
- Store review will not object to what we are shipping.
