# FLS-11 — Security and privacy

**Fires:** auth, storage, network, permissions, logging, third-party SDKs; and before every release.
**Standard:** [`SECURITY_PRIVACY_STANDARD`](../../standards/20260801-SECURITY_PRIVACY_STANDARD.md) · run with `@flutter-security audit`.

**Posture:** assume the binary is decompiled and the device is rooted. Everything in the bundle is readable.

---

## Questions

**Secrets**

1. Does the diff introduce any credential, token, key, certificate or connection string? (Report location and type — **never the value**.)
2. Is any secret introduced via `--dart-define`, an asset, a build config or a comment? All of these ship in the binary.
3. Does the change touch signing material, `key.properties`, keystores or provisioning profiles?
4. If a secret was found: has it been **revoked and rotated**, not merely deleted? It remains in git history and in every clone.

**Storage**

5. What is persisted, in which store, and what is its data classification?
6. Are tokens, credentials and keys in secure storage only?
7. Is anything sensitive in `shared_preferences` (plaintext on disk), in a log, in a filename, in analytics, or in a crash report?
8. Is sensitive data excluded from platform backup and cloud sync?
9. Is all user-scoped data deleted on logout and on account deletion?

**Transport**

10. Is every endpoint HTTPS? Is cleartext disabled at the platform level?
11. Is there any custom certificate callback that could accept an invalid certificate?
12. Where pinning is required: is it implemented with a rotation plan and a backup pin?
13. Are tokens sent in headers rather than URLs?
14. Is token refresh single-flight?

**Authentication and authorisation**

15. Is any authorisation decision made only on the client? (It is defence in depth, never sufficient — is the server enforcing it too?)
16. Does biometric authentication gate a key, or merely a boolean?
17. Are sessions expiring, tokens rotating, and logout invalidating server-side?

**Input**

18. Is every external input treated as untrusted — API responses, deep links, notifications, clipboard, files, QR codes, intents?
19. Any string-concatenated query, dynamic code path, or unsanitised HTML/Markdown rendering?
20. Any path constructed from an external filename?

**Permissions and privacy**

21. Does the change add a permission? Is it genuinely used, declared on every platform, and requested in context?
22. Do the store privacy declarations still match actual behaviour — including behaviour added by third-party SDKs?
23. What personal data does this collect, why, how long is it retained, and can it be deleted on request?
24. Is any new SDK collecting data? What does it send, and where?

**Logging**

25. Does the change log any credential, token, PII, full payload, or precise location?
26. Is verbose logging excluded from release builds?
27. Are crash reports scrubbed?

**Dependencies**

28. Does the change add a dependency? Licence, maintenance, transitive tree, native code, data collection?
29. Any known vulnerabilities in the added tree?

---

## Output

| # | Severity | File:line | Finding | Exploitability | Remedy |
|---|----------|-----------|---------|----------------|--------|

State explicitly which checks were **run** and which were reasoned about. Never echo a discovered secret.

---

## Verdict rules

| Condition | Severity |
|-----------|----------|
| Any secret in the repository or bundle | blocker |
| Sensitive data in a plaintext store | blocker |
| Cleartext traffic enabled, or a permissive certificate callback | blocker |
| Sensitive data in logs, analytics or crash reports | blocker |
| Authorisation enforced only client-side | blocker |
| Untrusted input used without validation | blocker |
| Privacy declarations contradicting actual behaviour | blocker |
| User data not deleted on logout | blocker |
| Critical or high dependency vulnerability | blocker |
| Permission declared but unused | major |
| Missing backup exclusion for sensitive data | major |
| Pinning without a rotation plan | major |
| Token in a URL | major |
| New SDK with unreviewed data collection | major |

A dismissed finding becomes a recorded accepted risk with an owner. It is never silently dropped.
