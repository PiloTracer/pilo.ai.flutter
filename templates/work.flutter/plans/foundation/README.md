# Foundation documents

The five documents that establish what is being built, for whom, under what constraints, and in what order. Written by `@flutter-foundation` through phases P0–P6, each gated.

**The foundation is the input to the master plan.** A plan built on an ungated foundation inherits every gap in it, and the gaps surface as rework in milestone three.

| Doc | Phase | Owns |
|-----|-------|------|
| `01-product-intent.md` | P0 | The problem, the users, the outcome, success measures, non-goals |
| `02-users-platforms-constraints.md` | P1 | Personas, target platforms with minimum OS versions, connectivity model, regulatory and compliance constraints, localisation scope |
| `03-architecture.md` | P2 | Layering, state flow, error strategy, DI approach, NFR table — consistent with `STACK.md` |
| `04-domain-model.md` | P4 | Entities, relationships, invariants, glossary, data classification |
| `05-features-risks-slicing.md` | P5–P6 | Feature inventory with `FT-` ids and priorities, risks, release slicing |

P3 sits between them: it generates the **project copies of the standards** into `../standards/` with every `REPLACE:` token filled.

---

## Front matter (every document)

```yaml
---
doc: 0<n>
phase: P<n>
status: draft | complete | certified
last-updated: YYYY-MM-DD
gaps: <count of open items>
---
```

---

## Rules

- **Never invent a product fact.** An unknown goes to `UNKNOWNS.md` with what it blocks and who owns it — it is not filled with something plausible.
- **Evidence or partial.** A claim about users, volumes, platforms or constraints names its source. Without a source it is marked as an assumption in `ASSUMPTIONS.md`.
- **Gates are sequential.** A phase does not open until the previous one's exit criteria are met.
- **Certification is explicit.** `plan-ready` comes from `@flutter-foundation certify`, never from the documents looking finished.
- Brownfield projects **recover** these documents from the existing code via `@flutter-plan-repair brownfield`, with honesty markers distinguishing what was observed from what was inferred.

---

## Probing

`@flutter-foundation probe` runs the adaptive interrogation loop and records every question and answer in `PROBE_LEDGER.md`. The probe includes a **challenge pass** that attacks the answers — the point is to find the requirement that is wrong, not to collect agreement.

Uncomfortable questions early are cheaper than rework later. That is the entire economic argument for this phase.
