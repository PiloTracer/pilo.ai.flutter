# FLS-03 — Layer boundaries

**Fires:** cross-layer imports, new modules, repositories, domain types, foundation P2.
**Standard:** [`ARCHITECTURE_STANDARD`](../../standards/20260801-ARCHITECTURE_STANDARD.md) §1–2, [`DIRECTORY_MAP`](../../standards/20260801-DIRECTORY_MAP.md).

---

## Why

Layer violations are cheap to prevent and expensive to unwind. A single `import 'package:dio/dio.dart'` in a domain file does not break anything today; two years later the domain cannot be tested without a network stub and the HTTP client cannot be replaced. The rule is enforced mechanically because judgement erodes under deadline.

---

## Questions

**Direction**

1. List every import in the changed files that crosses a layer. For each: source layer, target layer, allowed?
2. Does `domain/` import Flutter, an HTTP client, a database, `dart:io`, or any package annotation? (Any of these is a blocker.)
3. Does `presentation/` import anything from `data/`? (Blocker — the UI depends on domain interfaces only.)
4. Does `data/` import a widget or `BuildContext`? (Blocker.)
5. Are there import cycles between files or modules?

**Types at the boundary**

6. Does any DTO appear outside `data/`?
7. Does any transport type (`Response`, `DioException`, `HttpException`, a driver exception) escape `data/`?
8. Does any widget type appear in a ViewModel or a repository?
9. Are domain entities free of serialisation annotations, or is the domain shaped by the wire format?

**Features**

10. Does any feature import another feature's `data/` or `presentation/`?
11. Is anything in `core/` actually feature-specific?
12. Is anything duplicated across features that should be in `core/` or a shared package?

**Component contract**

Four questions answerable from imports alone. They catch the violations that survive a casual read because each individual file looks reasonable.

13. **Does any repository import another repository?** Logic needing two repositories belongs in the ViewModel or a use case. This is the violation that turns a layered codebase into a graph, and it is almost always introduced one defensible shortcut at a time.
14. Does any view import a repository, a service, or an API client directly, rather than going through its ViewModel?
15. Does any service hold state, or know about a repository? A service wraps one data source, returns a `Future` or `Stream`, and knows nothing above it.
16. Are injected dependencies private final fields? A public repository field on a ViewModel lets the view reach past it, which deletes the boundary while leaving the folder structure intact.

**Interfaces**

17. Is every repository interface in `domain/` with its implementation in `data/`?
18. Does any interface leak its implementation — a method returning a DTO, taking a `Request`, or named after a transport?
19. Is the UI depending on the interface or on the concrete implementation?

**Purity**

20. Can `domain/` be tested with no Flutter binding, no network, no disk, no platform? If not, what prevents it?
21. Does business logic appear in a widget, a repository, or a source instead of in the domain or the state layer?

---

## Output

| # | Severity | File:line | Violation | Correct placement |
|---|----------|-----------|-----------|-------------------|

Plus: the layer map of changed files (which file is in which layer), and whether the domain is still pure.

---

## Verdict rules

| Condition | Severity |
|-----------|----------|
| Flutter or a package import in `domain/` | blocker |
| `presentation/` importing `data/` | blocker |
| **Repository importing another repository** | blocker |
| **View importing a repository, service or API client** | blocker |
| Transport type escaping `data/` | blocker |
| Import cycle | blocker |
| Cross-feature import of `data/` or `presentation/` | blocker |
| Service holding state | major |
| Injected dependency exposed as a public field | major |
| Business logic in a widget | major |
| Feature-specific code in `core/` | major |
| Interface leaking implementation detail | major |
| Duplication that should be shared | minor |

**A layer violation is never a style preference.** "It's only one import" is how the boundary is lost — the second one is always easier to justify than the first.
