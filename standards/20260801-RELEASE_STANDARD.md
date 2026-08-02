# Release standard — template

> **Template.** Copied to `{FLUTTER_STANDARDS_ROOT}/YYYYMMDD-RELEASE_STANDARD.md` with tokens filled from foundation doc 02 and `STACK.md`.

**Owned by:** `@flutter-release` · **Gate:** G4 in [`QUALITY_GATES`](20260801-QUALITY_GATES.md).

A release is a **repeatable procedure**, not an event. If the person who normally ships is unavailable, the release still goes out from this document.

---

## 1. Flavors

| Flavor | Backend | Distribution | Analytics | Logging |
|--------|---------|--------------|-----------|---------|
| `dev` | `REPLACE:DEV_BACKEND` | Local | Off | Verbose |
| `staging` | `REPLACE:STAGING_BACKEND` | Internal testers | Separate project | Info |
| `prod` | `REPLACE:PROD_BACKEND` | Stores | Production | Warning+ |

Each flavor has a distinct application id / bundle id suffix and a distinct display name, so all three can be installed side by side. Flavor configuration is compile-time; **the app never reads a flavor from a runtime file** that could be swapped. A staging build that can be pointed at production is a production incident waiting for one wrong tap.

---

## 2. Versioning

- `MAJOR.MINOR.PATCH+BUILD` in `pubspec.yaml`. Semantics recorded in `REPLACE:VERSIONING_POLICY`.
- **The build number never decreases and is never reused.** Stores reject reuse, and a decrease makes the upgrade path undefined.
- Version bumps are deliberate: recorded in the changelog, tagged in git, and matched to a release entry.
- The version is visible in-app (settings or diagnostics) — a support conversation that starts with "which version?" and cannot be answered wastes everyone's time.

---

## 3. Signing

- Android: an upload key in a keystore held outside the repo; Play App Signing for the distribution key.
- iOS: distribution certificate and provisioning profiles managed through the team account.
- **Signing material never enters the repository, the log output, an environment dump, or an agent's hands.** `key.properties`, `*.keystore`, `*.jks`, `*.p12`, `*.mobileprovision` are gitignored, and the ignore rules are verified — not assumed.
- CI reads signing material from encrypted secrets that are masked in logs.
- Key rotation and recovery procedures are documented. A lost upload key is recoverable through Play support; a lost pre-App-Signing key historically was not, and the failure mode is losing the ability to update your own app.

---

## 4. Build configuration

| Setting | Release value |
|---------|---------------|
| Build mode | `--release` |
| Obfuscation | On, with `--split-debug-info` to an archived directory |
| Debug symbols | **Archived per release and uploaded to the crash reporter** |
| Android output | App Bundle for Play; split-per-ABI APKs for other channels |
| Shrinking | On, with the specific keep rules for reflection and channels |
| Debug flags, test endpoints, dev menus | Absent — compile-time excluded, not runtime-hidden |
| Cleartext traffic | Disabled |
| `debuggable` | False |

**Obfuscation without archived symbols makes every crash report useless.** The symbols must be stored where the next release engineer can find them, keyed by version and build number.

---

## 5. Release certification

`@flutter-release certify` runs before any artifact is built. Every check produces observed evidence.

| # | Gate |
|---|------|
| R1 | Full quality gate G3 passes on the release commit |
| R2 | Version and build number correct, unique, tagged |
| R3 | No secrets in the bundle; gitignore rules verified |
| R4 | Accessibility audit clean on all P0 screens |
| R5 | Performance budgets met on the reference device |
| R6 | Artifact size within budget |
| R7 | Security audit: zero critical or high findings |
| R8 | Permissions declared match permissions used |
| R9 | Store privacy declarations match actual behaviour, including third-party SDKs |
| R10 | Crash reporting verified with a real test crash on a release-mode build |
| R11 | Integration suite green on a real device |
| R12 | Third-party licences attributed in-app |
| R13 | Changelog and release notes written |
| R14 | Rollback plan recorded and feasible |

Any gate failing is a blocker. A gate that could not be run is `unverified`, and `unverified` is not a pass.

---

## 6. Store submission

- Metadata, screenshots and descriptions match the actual shipped behaviour. Screenshots from a design mockup rather than the build are a rejection risk and a trust problem.
- Age rating, content declarations and data-safety forms are reviewed each release, not filled once and forgotten — a new SDK can silently change what is true.
- Required legal surfaces (privacy policy, terms) are reachable and current.
- Review notes include test credentials and any instructions a reviewer needs to reach gated functionality. A reviewer who cannot get past the sign-in screen rejects the build.

---

## 7. Rollout

- Staged rollout: `REPLACE:ROLLOUT_STAGES` (e.g. 5% → 20% → 50% → 100%), with a hold at each stage.
- Watch at each stage: crash-free rate against `REPLACE:CRASH_FREE_TARGET`%, error rate, key funnel metrics, store reviews.
- **Halt criteria are defined in advance**, because deciding mid-incident produces the wrong decision: crash-free below target, a new top crash, or a critical journey failing.
- Rollback: halt the rollout, ship a fix-forward build, and — where the app supports it — use a remote kill switch or forced-update mechanism. **Mobile has no true rollback**: users who updated stay updated. This is why staged rollout matters more than on the server.

---

## 8. CI/CD

Pipeline stages: analyze → test → coverage gate → build (per flavor and platform) → security scan → artifact upload → distribute to testers → (manual approval) → store submission.

- **CI uses the same Flutter version as local development**, pinned. Version drift between CI and local is the most common source of "works on my machine".
- Builds are reproducible from a tagged commit.
- Secrets come from the CI secret store, masked in logs.
- Artifacts and symbol files are retained for `REPLACE:ARTIFACT_RETENTION`.
- The release pipeline is exercised on staging before it is trusted for production.

---

## 9. Post-release

Within `REPLACE:POST_RELEASE_WATCH` of full rollout: confirm the crash-free rate, review new crash clusters, check store reviews for regressions users report but telemetry misses, verify key funnels, and record what happened in the release log. Anything that surprised you becomes a gate in this document for next time.
