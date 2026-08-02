# FLS-04 — Async and error safety

**Fires:** `Future`/`Stream` code, `try`/`catch`, error mapping, cancellation, any new failure path.
**Standard:** [`ARCHITECTURE_STANDARD`](../../standards/20260801-ARCHITECTURE_STANDARD.md) §5, [`FLUTTER_CONVENTIONS`](../../standards/20260801-FLUTTER_CONVENTIONS.md) §5–6.

---

## Why

Every async operation has at least four outcomes — success, failure, timeout, and cancellation — and most code handles one. The other three become the crash reports. Error handling is also where "it works" and "it works when the network is bad" diverge, and users experience the second one far more often than developers do.

---

## Questions

**Coverage of outcomes**

1. For each new async operation: what happens on success, on failure, on timeout, on cancellation, and when the user leaves mid-flight?
2. Is there a timeout at all? What is it, and where is it configured?
3. Is the operation idempotent? If not, what prevents a double-submit — a disabled button is not enough if the user can background and return.

**Error handling**

4. Is there any bare `catch`, empty catch block, or `catch (e)` without the stack trace?
5. Is every caught error handled, mapped, or rethrown — or is any silently swallowed?
6. Does any error cross a layer boundary unmapped? Name the type and the boundary.
7. Is the failure taxonomy exhaustive here, or is there a catch-all "something went wrong" doing real work?
8. Does every failure have a **user-visible outcome** defined in the SPEC? Which SPEC section?
9. Are unexpected errors reported to the crash reporter, or only logged?

**User experience of failure**

10. What exactly does the user see for each failure type? Quote the copy.
11. Can they retry? Does retrying lose their input?
12. Is offline distinguished from a server error, and from an empty result?
13. Is a partial failure (some data loaded, some did not) handled, or does one failure blank the screen?

**Retry**

14. What retries, how many times, with what backoff? Is jitter applied?
15. Is anything non-idempotent being retried? (Blocker.)
16. Can a retry storm occur — for example, every widget retrying independently on reconnect?

**Cancellation and lifecycle**

17. Is in-flight work cancelled on dispose, or does its result arrive at a dead object?
18. Are `Stream` subscriptions cancelled? Are timers cancelled?
19. Is any `Future` fired and forgotten without error handling?
20. Is `Future.delayed` used as a synchronisation mechanism anywhere? (It is a race condition with a timer.)

**Concurrency**

21. Can two of these run at once? What happens if they do?
22. Is token refresh single-flight, or can concurrent 401s trigger a refresh storm?
23. Is there any shared mutable state touched from multiple async paths?

**Global handlers**

24. Are `FlutterError.onError` and `PlatformDispatcher.instance.onError` wired? Without both, release errors vanish.

---

## Output

| # | Severity | File:line | Finding | Missing outcome |
|---|----------|-----------|---------|-----------------|

Plus an outcome matrix for each new async operation: success / failure / timeout / cancellation → what happens, what the user sees.

---

## Verdict rules

| Condition | Severity |
|-----------|----------|
| Swallowed exception | blocker |
| Bare `catch` in production code | blocker |
| Transport error escaping its layer | blocker |
| A failure with no user-visible outcome | blocker |
| Non-idempotent operation retried | blocker |
| Missing global error handlers | blocker |
| No timeout on a network call | major |
| Cancellation not handled | major |
| Retry without backoff | major |
| Missing stack trace in a logged error | major |
| Offline not distinguished from error | major |
| `Future.delayed` as synchronisation | major |
