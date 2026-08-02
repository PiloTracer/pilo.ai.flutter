# Security and privacy standard — template

> **Template.** Copied to `{FLUTTER_STANDARDS_ROOT}/YYYYMMDD-SECURITY_PRIVACY_STANDARD.md` with tokens filled from foundation doc 02 (compliance) and doc 04 (data classification).

**Owned by:** `@flutter-security` · **Enforced by:** `@flutter-verify` D11, concept FLS-11. **Aligned to:** OWASP MASVS.

---

## 1. The threat model in one line

**Assume the binary will be decompiled and the device will be rooted.** A mobile app is code running on hardware the attacker controls. Everything in the bundle is readable; everything the app can decrypt, an attacker on that device can decrypt.

Consequences that follow directly:

- **There are no client-side secrets.** Anything compiled in, `--dart-define`d, or stored in an asset is public. An API key in the binary is an API key you have published.
- **Client-side validation is UX, not security.** Every rule must also be enforced server-side.
- **Client-side controls are defence in depth**, worth doing and never sufficient on their own.

---

## 2. Secrets

| Rule | |
|------|---|
| No credential, token, key or certificate in source, `pubspec.yaml`, assets, build config or CI logs | |
| `--dart-define` values ship inside the binary — configuration, not secrets | |
| Signing keys and store credentials are handled by humans and CI secret stores; **agents never touch them** | |
| Third-party keys that must reach the device are scoped, rate-limited, domain-restricted and revocable | |
| A leaked credential is **revoked and rotated**, never merely deleted from the repo — git history and every clone still have it | |
| Secret scanning runs pre-commit and in CI | |

**A discovered secret is never echoed** in a report, a log, a commit message or a chat. Report its location and type; never its value.

---

## 3. Storage

| Data class | Store | Notes |
|------------|-------|-------|
| Tokens, credentials, keys, biometric-gated data | `flutter_secure_storage` (Keychain / Keystore) | Never anything else |
| Sensitive personal data | Encrypted local database (`REPLACE:ENCRYPTED_STORE`) | Key in the platform keystore |
| Ordinary app data | Standard local store | |
| Preferences | `shared_preferences` | **Plaintext on disk** — non-sensitive only |
| Caches | Bounded, evictable | Cleared on logout when user-scoped |

Rules: no sensitive data in `shared_preferences`, in logs, in filenames, in analytics payloads or in crash reports. Backup and cloud-sync exclusion is configured for sensitive stores. **All user-scoped data is deleted on logout** and on account deletion. Clipboard use of sensitive values is marked sensitive where the platform supports it. Screenshots and the app switcher preview are suppressed on screens that display sensitive content, where the SPEC requires it.

---

## 4. Transport

- **TLS only.** Cleartext traffic is disabled at the platform level: Android network security config, iOS ATS with no blanket exception. A single `usesCleartextTraffic="true"` undoes the policy for the whole app.
- Certificate or public-key **pinning** where `REPLACE:PINNING_REQUIRED` is yes — with a documented rotation plan and a backup pin. Pinning without a rotation plan is a scheduled outage.
- No custom `badCertificateCallback` that returns true. Ever. It is the single most common way TLS gets disabled by accident, and it is invisible in review unless someone looks.
- Auth tokens sent in headers, never in URLs (URLs land in logs, proxies and analytics).
- Token refresh is single-flight; concurrent 401s must not trigger a refresh storm.
- Sessions expire, refresh tokens rotate, and logout invalidates server-side — not just locally.

---

## 5. Authentication

- Biometric authentication gates access to a **key**, not merely a boolean check — a boolean is trivially patched.
- Deep links and notification payloads are untrusted input: validate, authorise, never act on them directly.
- Redirect URIs use app links / universal links with verified associations, not custom schemes, where the platform supports it.
- OAuth flows use PKCE and the system browser or an authenticated web view — never an embedded web view that can read the credentials.
- Failed-attempt limiting and lockout are enforced server-side.

---

## 6. Permissions and privacy

- **Declare only what is used.** An unused declared permission is a store-review risk and a privacy finding.
- Request at the point of need, with an in-context rationale before the system prompt.
- Handle all three outcomes: granted, denied, permanently denied — and mid-session revocation.
- Store privacy declarations (Apple privacy manifest, Play data-safety) **match actual behaviour**, including behaviour introduced by third-party SDKs. Mismatches are a rejection and a regulatory exposure.
- Data minimisation: collect what the feature needs, retain it as briefly as the requirement allows, and document the retention period.
- Analytics and crash reports carry no PII by default; every field sent is on a reviewed allowlist.
- Third-party SDKs are audited for what they collect. An SDK that phones home with device identifiers is your data collection, legally.

---

## 7. Platform hardening

| Control | Requirement |
|---------|-------------|
| Debuggable release | Off |
| Backup of sensitive data | Excluded |
| Exported components | Only those genuinely required, and each protected |
| WebView | JavaScript off unless needed; no file access; no universal access from file URLs; no unvalidated URL loading |
| Obfuscation | On for release, symbols retained and archived for de-symbolication |
| Native shrinking | On, with the specific keep rules required by reflection and channels |
| Root/jailbreak detection | Optional (`REPLACE:ROOT_DETECTION`), advisory only — it is defence in depth, and it is bypassable |
| Screen capture protection | Per SPEC on sensitive screens |

---

## 8. Dependencies

- Every package is free, OSS and commercial-use-permitted per [`PACKAGE_LICENSE_STANDARD`](20260801-PACKAGE_LICENSE_STANDARD.md).
- Vulnerability scanning in CI; **zero critical or high** findings at release.
- Unmaintained packages (`REPLACE:STALE_MONTHS` months without a release, or an open critical issue) are flagged and scheduled for replacement.
- A new dependency's transitive tree is reviewed, not just the package itself. Native code in a dependency raises the bar further.
- Dependencies are pinned in apps via a committed lockfile.

---

## 9. Input and injection

- All external input — API responses, deep links, notifications, clipboard, files, QR codes, inter-app intents — is untrusted and validated at the boundary.
- Parameterised queries only; no string-concatenated SQL.
- No dynamic code loading or evaluation.
- Path traversal defended when handling file names from outside the app.
- Rendering remote HTML or Markdown is sanitised, or it is an injection surface.

---

## 10. Logging

- Never log credentials, tokens, PII, full request/response bodies, or precise location.
- Release builds do not log verbosely; debug logging is compile-time excluded.
- Crash reports are scrubbed before send.
- See [`OBSERVABILITY_STANDARD`](20260801-OBSERVABILITY_STANDARD.md).

---

## 11. Incident response

A recorded procedure covering: how a report reaches the team, who triages, how a fix is expedited, how users are notified, how credentials are rotated, and how a forced-update is issued. Written before it is needed — during an incident is not when you decide who has the signing key.

---

## 12. Audit rules

1. Only free, OSS, commercial-use-permitted tooling.
2. **Never claim a check was run without running it.** State what was and was not verified.
3. Findings carry severity, exploitability, file and line, and a concrete remedy.
4. Never echo a discovered secret.
5. A dismissed finding is recorded as accepted risk with an owner — never silently dropped.
