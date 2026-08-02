# Resources

Reference material skills read. Not standards (not binding) and not skills (no protocol) — lookup tables that keep recommendations accurate.

| File | Contents | Read by |
|------|----------|---------|
| [`packages-2026.md`](packages-2026.md) | Vetted free/OSS/commercial-use packages by problem, with licences | `flutter-stack`, `flutter-router`, `flutter-security` |
| [`flutter-cli.md`](flutter-cli.md) | Flutter and Dart commands, what output means, how to read failures | `flutter-doctor`, every executing skill |

---

## The standing rule

**Package names, versions and APIs are verified against pub.dev before they are recommended or written.** This is the detail most confidently reconstructed from memory and most frequently wrong: a plausible version that does not exist, an API that changed two majors ago, a licence that changed at 2.0.

The cost is asymmetric. Checking takes seconds; a wrong version produces a resolution failure, and a wrong API produces code that compiles in the author's head and nowhere else.

These files deliberately omit version numbers for the same reason — a document cannot stay current, so it should not pretend to.

---

## Upstream references

| Source | Use for |
|--------|---------|
| [Effective Dart](https://dart.dev/effective-dart) | Style, documentation, usage and design conventions — the baseline this framework extends |
| [Flutter API docs](https://api.flutter.dev) | Widget and framework behaviour |
| [pub.dev](https://pub.dev) | **The** source for versions, licences, platform support and maintenance |
| [Flutter performance docs](https://docs.flutter.dev/perf) | Profiling methodology |
| [Material Design](https://m3.material.io) | Component and interaction guidance |
| [WCAG 2.2](https://www.w3.org/TR/WCAG22/) | Accessibility criteria behind the a11y standard |
| [OWASP MASVS](https://mas.owasp.org) | Mobile security verification standard behind the security standard |
