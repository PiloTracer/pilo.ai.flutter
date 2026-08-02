# Package and licence standard

> **Not templated.** Binding as written. A project may be stricter; it may not be looser without a recorded legal review.

**Owned by:** `@flutter-stack` (admission), `@flutter-security deps` (ongoing) · **Framework promise:** every package this framework recommends is free, open source, and permitted for commercial use.

---

## 1. Licence policy

| Licence | Status | Note |
|---------|--------|------|
| MIT, BSD-2, BSD-3, Apache-2.0, Zlib, ISC | **Allowed** | Attribution required; Apache-2.0 also grants patent rights |
| MPL-2.0 | **Allowed as a dependency** | File-level copyleft; modifications to its files must be published |
| BSD-3 + patent grant (Flutter/Dart SDK) | Allowed | |
| LGPL | **Refused by default** | Static linking is the norm on mobile; the dynamic-linking exemption generally does not apply |
| GPL, AGPL | **Refused** | Copyleft would extend to the application |
| CC-BY-NC, CC-BY-ND | **Refused** | Not commercial-use-permitted |
| "Source available", BSL, Elastic, SSPL | **Refused** | Not open source; usage restrictions |
| Free tier with a paid production tier | **Refused as a default** | May be accepted as an explicit, recorded product decision — not as an unnoticed dependency |
| No licence file | **Refused** | No licence means no rights granted, regardless of a public repository |

**Transitive dependencies are subject to the same policy.** A permissively-licensed package that depends on a GPL package delivers the GPL obligation to you. Audit the tree, not the top level.

Assets have licences too: fonts, icons, illustrations, sounds. A commercially-restricted font is the most common licence violation in mobile apps, because it does not look like a dependency.

---

## 2. Admission criteria

Before a package enters `STACK.md` or `pubspec.yaml`, all of these are checked and **verified against the live registry**, never from memory:

| # | Criterion | Refuse when |
|---|-----------|-------------|
| 1 | Licence per §1 | Not allowed |
| 2 | Actually exists at the stated version | Version invented — a common and costly failure |
| 3 | Maintenance | No release in `REPLACE:STALE_MONTHS` months **and** open critical issues |
| 4 | Adoption | Very low usage with no compensating justification |
| 5 | Platform support | Does not support every target platform, with no fallback plan |
| 6 | Dart 3 / current SDK compatible | Requires an SDK constraint the project cannot meet |
| 7 | Transitive weight | Pulls a large or duplicative tree for a small benefit |
| 8 | Native code | Contains native code with no source, or unreviewable binaries |
| 9 | Data collection | Sends data anywhere without disclosure — this becomes your privacy declaration |
| 10 | Replaceability | Would be very costly to remove, with no alternative |

**Verification is mandatory before recommending.** Package names, versions and APIs are exactly the kind of detail an LLM reconstructs plausibly and incorrectly. Check pub.dev, check the changelog, check the licence file.

---

## 3. Adding a dependency

A dependency is a permanent liability with a maintenance cost, a security surface, a size cost, and an upgrade obligation. Justify it:

1. **What problem does it solve, and what is the cost of solving it directly?** A 60-line utility is not worth a dependency.
2. **What is the exit cost?** How deeply would it thread through the codebase?
3. **Is it already solved** by the SDK, the framework, or an existing dependency?
4. Record the decision in `STACK.md` (for stack-level choices) or in the SPEC (for feature-level ones).

Prefer the package the ecosystem has standardised on. Novel and clever loses to boring and maintained, every time, on a five-year codebase.

---

## 4. Pinning

- **Apps commit `pubspec.lock`.** Libraries do not.
- Constraints use caret ranges (`^1.2.3`) unless a specific incompatibility requires a tighter pin — and a tight pin carries a comment saying why and when it can be relaxed.
- `dependency_overrides` is a last resort: it requires a written justification, a removal condition, and a tracking item. An override silently bypasses version solving for the whole tree, and it fails in a way that is hard to diagnose months later.

---

## 5. Ongoing obligations

| Cadence | Action |
|---------|--------|
| Every PR | Any new dependency passes §2 |
| Every CI run | Vulnerability scan; zero critical or high at release |
| `REPLACE:DEP_REVIEW_CADENCE` | Full dependency review: outdated, unmaintained, unused, licence changes |
| Every release | Attribution page regenerated and verified |

**Licences can change between versions.** A package that was MIT at 1.0 may be BSL at 2.0. The check at upgrade time is not optional.

Unused dependencies are removed. Every one carries cost and no benefit.

---

## 6. Attribution

Every shipped third-party licence is attributed in-app. Flutter's built-in licence registry collects most of them automatically; anything registered outside it — fonts, assets, native SDKs, vendored code — is added explicitly. The attribution surface is reachable from the app UI, not buried in a website.

This is a licence obligation under MIT, BSD and Apache-2.0, not a courtesy.

---

## 7. Package inventory

Recorded in `STACK.md` and kept current:

| Package | Version | Licence | Purpose | Platforms | Alternative if abandoned |
|---------|---------|---------|---------|-----------|--------------------------|

The last column is the one people skip and the one that matters during an incident.

---

## 8. Anti-patterns

- Recommending a package or version without checking it exists.
- Auditing only direct dependencies.
- Ignoring asset and font licences.
- Adding a dependency for a function you could write in an hour.
- `dependency_overrides` with no justification or removal condition.
- Re-checking licences never after the first adoption.
- Shipping without an attribution surface.
- Accepting a "free tier" package whose production use requires payment, without recording it as a commercial decision.
