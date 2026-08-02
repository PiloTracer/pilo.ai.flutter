# FLS-09 — Offline and data integrity

**Fires:** caching, local stores, migrations, sync, conflict resolution, anything persisted.
**Standard:** [`DATA_LAYER_STANDARD`](../../standards/20260801-DATA_LAYER_STANDARD.md) §5–9.

---

## Why

Data defects are the only class of mobile bug you cannot fix in the next release. A migration that drops a column has already destroyed the data on the devices that ran it. A sync conflict resolved wrongly has already overwritten the user's work. Everything here is reviewed as if it were irreversible, because it is.

---

## Questions

**Persistence choice**

1. What is being persisted, where, and why that store?
2. Is anything sensitive in a plaintext store? (Blocker — see FLS-11.)
3. Is anything structured being stored as a JSON blob to avoid a schema?
4. Is the data user-scoped? Is it cleared on logout and on account deletion?

**Schema and migration**

5. Does this change the persisted schema or a serialised format? If so, where is the migration?
6. Is the migration numbered, ordered and never renumbered?
7. Is it **idempotent** — and was it actually run twice to confirm, not merely inspected?
8. Is it forward-only, with no downgrade assumption?
9. Was it tested from **every** shipped schema version, not just the previous one? Users skip versions.
10. Is any step destructive? Was explicit human approval given?
11. What happens if the migration fails halfway — is the state recoverable, or does the app crash on every subsequent launch?

**Nullability and parsing**

12. Does DTO nullability mirror the wire contract, or the developer's optimism?
13. What happens on a missing field, a null where a value was expected, an unknown enum value, a malformed payload?
14. Do unknown enum values fall back rather than crash? A new server-side status must not brick every installed app.
15. Are money and precise quantities free of binary floats?
16. Are dates parsed to UTC at the boundary?

**Caching**

17. For each cached entity: strategy, TTL, invalidation trigger, eviction, staleness display, scope. Any undeclared field is a finding.
18. Can the user see stale data without knowing it is stale? Is that acceptable per the SPEC?
19. Is the cache bounded?
20. Is the cache cleared on logout where the data is user-scoped?

**Offline**

21. Which operations work offline, which queue, which are refused? Does the UI say which?
22. Where does the queue live, and does it survive process death?
23. What is the retry and ordering policy? Is the queue bounded?
24. **What is the conflict policy** — last-write-wins, server-wins, merge, or user-resolves? "We'll figure it out" is last-write-wins with silent data loss.
25. What does the user see while offline, while syncing, and after a conflict?
26. Is offline distinguished from a generic error?

**Integrity**

27. Can a partial write leave inconsistent state? Is the operation transactional where it needs to be?
28. Can two writers race? What wins?
29. Is there any path where user-entered data can be lost without acknowledgement?

---

## Output

| # | Severity | File:line | Finding | Data at risk |
|---|----------|-----------|---------|--------------|

Plus the cache policy table for every entity touched, and the migration verification evidence (the actual double-run output).

---

## Verdict rules

| Condition | Severity |
|-----------|----------|
| Migration not verified by running twice | blocker |
| Destructive migration without explicit approval | blocker |
| Migration untested from an older shipped version | blocker |
| Sensitive data in a plaintext store | blocker |
| User data can be lost silently | blocker |
| Unknown enum value crashes parsing | blocker |
| Offline conflict policy undefined | blocker |
| Cache policy undeclared | major |
| Unbounded cache or queue | major |
| Cache not cleared on logout | major |
| Nullability contradicting the wire contract | major |
| Money as `double` | major |
| Partial-write inconsistency possible | major |
