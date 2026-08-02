# Navigation standard — template

> **Template.** Copied to `{FLUTTER_STANDARDS_ROOT}/YYYYMMDD-NAVIGATION_STANDARD.md`; `REPLACE:ROUTER` resolved from `STACK.md`.

**Pairs with:** `@flutter-platform deeplink` (native link configuration), [`ARCHITECTURE_STANDARD`](20260801-ARCHITECTURE_STANDARD.md) §6, concept FLS-05.

---

## 1. Principles

1. **Routes are declared in one place.** A central route table, not `Navigator.push(MaterialPageRoute(builder: ...))` scattered through widgets. Scattered pushes mean nobody can enumerate the app's surfaces — including the deep-link and analytics code that needs to.
2. **Every screen is addressable by a URL-shaped path.** Even if the app never exposes links today, path-addressability is what makes deep linking, restoration and testing possible later.
3. **Navigation is UI-layer.** Repositories and ViewModels never navigate. They emit an effect; the UI decides what it means.
4. **Every route is reachable and every route is left.** A route with no entry point is dead code; a route with no exit is a trap.

---

## 2. Route definitions

Each route declares:

| Field | Requirement |
|-------|-------------|
| Name | Stable constant, referenced everywhere — no string literals at call sites |
| Path | `/kebab-case/:param` — lowercase, hyphenated, plural collections |
| Parameters | Typed; parsing failure has a defined outcome |
| Guards | The conditions required to enter |
| Transition | Default unless the SPEC says otherwise |
| Deep-linkable | Yes/no, and whether it requires authentication |

Parameters carry **identifiers, not objects**. Passing a whole entity through a route breaks on cold start from a link, where the object does not exist yet. Pass the id; the screen loads it and shows the six states while doing so.

---

## 3. Guards

Guards are declarative and testable, evaluated before the route builds.

| Guard | Redirect on failure |
|-------|---------------------|
| Authenticated | Sign-in, **with the intended destination preserved** |
| Authorised (role/entitlement) | A "no access" surface — not a blank screen and not a crash |
| Onboarding complete | Onboarding, resuming to the destination afterwards |
| Feature flag on | Not-found |
| Precondition (e.g. verified email) | The remediation screen |

**Post-authentication return is mandatory.** A user who taps a link, signs in, and lands on the home screen has lost their intent — this is the single most common navigation defect in mobile apps.

Guards must be evaluated on **every** entry path: tab switch, deep link, notification tap, restoration, and back navigation.

---

## 4. Nesting and shells

- Persistent chrome (bottom navigation, side rail) is a **shell route**; tab content is nested inside it.
- Each tab keeps its own navigation stack, and switching tabs preserves each stack.
- A modal that must be dismissible by the system back gesture is a route, not a widget.
- Nesting deeper than `REPLACE:MAX_NAV_DEPTH` levels needs a recorded reason.

---

## 5. Back behaviour

Explicitly defined per screen, because the platforms differ and users notice.

| Situation | Behaviour |
|-----------|-----------|
| Unsaved changes | Confirmation prompt (`REPLACE:UNSAVED_PROMPT` copy) before leaving |
| In-progress operation | Either block with an explanation or cancel cleanly — never leave an orphan request |
| Root of a tab | Switch to the first tab, or exit per platform convention |
| Root of the app (Android) | Exit; a double-tap-to-exit pattern only if the SPEC asks |
| After a completed flow | Replace, do not push — the user must not be able to go back into a completed checkout |
| Modal | Dismisses the modal only |

Android system back and iOS swipe-back must both be handled. Predictive back on Android 14+ requires the route to declare whether it can be popped.

---

## 6. Deep links

Native configuration is `@flutter-platform deeplink`'s responsibility; the routing contract is here.

- Link paths are the same paths as internal routes. Two vocabularies is two sources of truth.
- **Never trust link parameters.** Validate and authorise every one — a link is untrusted user input from outside the app.
- Cold start, warm start and foreground receipt all resolve to the same destination.
- A link to an auth-guarded route goes through the guard and returns after sign-in.
- An unknown or malformed link goes to a defined not-found surface, never a crash and never a blank screen.
- Links are testable without a device: the parser is a pure function with its own unit tests.

---

## 7. Passing data back

Routes return typed results. The awaiting caller handles both the value and the dismissal (`null`) case — an unhandled dismissal is the second most common navigation defect.

---

## 8. Analytics and observability

Screen views are emitted from the router, not from individual screens — one instrumentation point cannot drift out of sync with the route table. Screen names come from the route constants. Never include parameter values that carry PII in a screen name.

---

## 9. Testing

| Target | Test |
|--------|------|
| Route table | Every route builds with valid parameters |
| Parameters | Invalid, missing and malformed parameters produce the defined outcome |
| Guards | Each guard redirects correctly, and preserves the destination |
| Deep links | Parser unit tests for every link shape, including unknown and malformed |
| Back | Unsaved-changes prompt, completed-flow replacement, tab-root behaviour |
| Flows | Integration test for each critical journey end to end |

---

## 10. Anti-patterns

- `Navigator.push` with an inline `MaterialPageRoute` outside the route table.
- Route names as string literals at call sites.
- Passing entities instead of identifiers.
- Navigating from a ViewModel or repository.
- Guards applied on one entry path but not on deep links.
- Losing the intended destination through the sign-in flow.
- Pushing (not replacing) after a completed flow.
- A deep link that trusts its parameters.
- Ignoring the `null` result from an awaited route.
- Screen-view analytics emitted per screen instead of from the router.
