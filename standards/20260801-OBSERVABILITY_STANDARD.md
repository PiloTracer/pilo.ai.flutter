# Observability standard — template

> **Template.** Copied to `{FLUTTER_STANDARDS_ROOT}/YYYYMMDD-OBSERVABILITY_STANDARD.md`, tools resolved from `STACK.md`.

You cannot debug what you cannot see, and on mobile you cannot attach a debugger to a user's device. Observability is designed in, or the first production incident is investigated by guesswork.

**Pairs with:** [`SECURITY_PRIVACY_STANDARD`](20260801-SECURITY_PRIVACY_STANDARD.md) — every rule below is subordinate to "never log sensitive data".

---

## 1. The three signals

| Signal | Answers | Tool |
|--------|---------|------|
| **Logs** | What happened in this session | `REPLACE:LOGGER` |
| **Crashes and errors** | What broke, where, for how many users | `REPLACE:CRASH_TOOL` |
| **Analytics** | What users actually do | `REPLACE:ANALYTICS_TOOL` |

Each has a different retention, a different privacy posture and a different audience. Merging them — sending logs as analytics events, or using crash reports as metrics — makes all three worse.

---

## 2. Logging

**Structured, never `print`.** A committed `print` is a `@flutter-verify` finding: it cannot be filtered, levelled, redirected or redacted.

| Level | Use | Ships in release |
|-------|-----|------------------|
| `trace`/`debug` | Development detail | No — compile-time excluded |
| `info` | Lifecycle milestones: start, sign-in, sync complete | Yes, sparingly |
| `warning` | Recovered problems, degraded paths, retries | Yes |
| `error` | Failures that reached the user or lost data | Yes, plus a report |

Every log line carries: timestamp, level, a stable component tag, the message, and structured context. Errors additionally carry the error object and the stack trace — `catch (e)` without `st` throws away the only part that locates the bug.

**Never logged:** credentials, tokens, PII, full request or response bodies, precise location, device identifiers, contents of secure storage. Redaction happens in the logger, not at every call site, because call-site discipline eventually fails.

Log **decisions and transitions**, not data dumps. "Retrying request 2/3 after 502" is useful. A pretty-printed 40 KB response body is noise that hides the useful line — and a privacy incident waiting for the log to be exported.

---

## 3. Crash and error reporting

- Both global handlers are wired in `bootstrap.dart`: `FlutterError.onError` and `PlatformDispatcher.instance.onError`. Without both, release-mode errors disappear silently.
- Zone-guarded `runApp` where the reporter requires it.
- **Non-fatal errors are reported too.** A caught-and-handled failure that happens to 5% of sessions is invisible unless it is reported.
- Every report carries breadcrumbs (recent navigation and key actions), the app version, build number, flavor, and OS — but never PII.
- **Obfuscated builds must upload their symbol files** as part of the release process, or every stack trace is unreadable. This is verified during `@flutter-release certify`, not assumed.
- User identifiers in reports are pseudonymous and consistent, never email or name.
- Crash-free session rate is tracked per release with a threshold of `REPLACE:CRASH_FREE_TARGET`%; falling below it triggers the rollback consideration in [`RELEASE_STANDARD`](20260801-RELEASE_STANDARD.md).

---

## 4. Analytics

- Every event is defined **before** it is implemented: name, trigger, properties, types, and the question it answers. Events invented at the keyboard produce a dashboard nobody trusts.
- Naming is consistent: `REPLACE:EVENT_NAMING` (e.g. `object_action` — `checkout_completed`).
- Properties are typed and bounded — no free text, no unbounded cardinality, no PII.
- Screen views come from the router, once, so they cannot drift from the route table.
- The event catalogue lives in `{FLUTTER_WORK_ROOT}/foundation/` and is versioned. An undocumented event is an unanswerable question.
- **Consent gates collection** where the jurisdiction requires it, and opting out actually stops the sending — not just the dashboard display.

---

## 5. Performance telemetry

Where the project collects field performance (`REPLACE:PERF_TELEMETRY`): startup time, key screen render time, primary network call latency, and janky-frame rate, all aggregated and anonymous. Field data beats lab measurement for prioritisation; lab measurement beats field data for diagnosis. Use both for their strengths.

---

## 6. Debuggability by design

- **Correlation ids** on outbound requests, logged locally and returned in responses, so a user report can be traced to a server log.
- A hidden diagnostics screen (`REPLACE:DIAG_SCREEN` — build-gated) showing version, flavor, backend, feature flags, last errors, and cache state. It saves hours per support case.
- Feature flags are visible and, in non-production builds, toggleable.
- **A user-facing error carries a support reference** that maps to the reported error. "Something went wrong" with no reference makes every support ticket an investigation from zero.

---

## 7. Privacy checkpoints

Before shipping any new event, log line or report field, three questions get answered: does it contain personal data, is it declared in the store privacy declarations, and can it be deleted on request. A "no" to the second or third is a blocker, not a follow-up.

---

## 8. Anti-patterns

- `print` in committed code.
- `catch (e)` without the stack trace.
- Logging full payloads.
- Verbose release logging.
- Crash reporting configured but never verified with a test crash.
- Obfuscated release with unuploaded symbols.
- Analytics events invented ad hoc with no catalogue.
- PII in event properties, user identifiers or crash metadata.
- Error messages with no support reference.
- Collecting data that no one has a question for.
