# Planning

Two layers: the **foundation** (what and why) and the **master plan** (in what order, verified how). The separation matters — mixing them produces a plan whose sequencing decisions are buried in product prose, and product decisions nobody can find.

---

## The foundation

Five documents across seven phases. Sequential, because each phase depends on the one before it.

| Phase | Establishes | Owner document |
|-------|-------------|----------------|
| P0 | Identity, intent, success criteria | 01 |
| P1 | Users, platforms, connectivity, constraints | 02 |
| P2 | Architecture decisions | 03 |
| P3 | Project standards (fills the templates) | `.work.flutter/standards/` |
| P4 | Domain model | 04 |
| P5 | Feature inventory, NFRs | 05 |
| P6 | Risks, release slicing | 05 + `RISK_REGISTRY.md` |

**Why sequential:** architecture chosen before you know the platforms is a guess. A domain model built before the users are understood models the wrong nouns. Skipping ahead is possible and always costs more than it saves.

---

## Grilling

Requirements are interrogated, not collected. The loop, per [`probe-protocol.md`](../../skills/probe-protocol.md):

```
ASSESS coverage → PRIORITIZE the weakest ★ dimension → ASK → RECORD
  → RE-SCORE → CHALLENGE → EXIT when every ★ ≥ 4
```

Ten dimensions: product intent, users, platforms, connectivity, constraints, domain model, feature inventory, NFRs, risks, release slicing.

**Question quality bar.** Every question must be decidable (you can answer it), consequential (the answer changes something), bounded (not "tell me about your users"), non-leading, and single-barrelled.

Bad: *"Do you need offline support and caching?"* — two questions, and it suggests the answer.
Good: *"A user opens the app on the underground with no connection. What should they see?"* — concrete, answerable, and the answer determines the entire data layer.

**The challenge pass** runs after coverage is reached and attacks the answers:

- Where is the evidence for that?
- What would a hostile reviewer attack first?
- What happens if this is wrong?
- Which of these did you assume rather than confirm?
- Who disagrees with this, and what is their argument?

This finds the confident guesses. People answer requirement questions from memory and belief, and both are frequently wrong in ways that only surface under challenge.

**Everything is recorded.** [`readiness-verify.sh`](../../scripts/readiness-verify.sh) fails a ledger that claims a dimension is confirmed without an answer behind it. "We talked about it" is not evidence.

---

## Handling non-answers

| Operator says | Do |
|---------------|-----|
| "I don't know" | Record in `UNKNOWNS.md` with what it blocks. Legitimate — an honest unknown beats a fabricated answer |
| "Whatever you think" | Propose a specific default, state its consequence, ask them to accept or reject. Do not silently choose |
| "Obviously X" | Record it, then challenge it. Obvious things are the least examined |
| "We'll decide later" | Record with a deadline and what it blocks. If it blocks a ★ dimension, it blocks certification |
| Contradicts an earlier answer | Surface both, ask which holds. Do not quietly pick |

**Never fabricate.** A plausible invented requirement is worse than a gap, because a gap is visible and an invention looks like a decision.

---

## Certification

```
@flutter-foundation certify
```

Requires: all seven phases complete, every ★ dimension ≥ 4, the probe ledger passing `readiness-verify.sh`, project standards generated, and no unresolved contradictions.

**State:** `plan-ready`. This is a real gate — the master plan skill will not start without it.

---

## The master plan

21 sections ([`MASTER_PLAN_STANDARD`](../../standards/20260801-MASTER_PLAN_STANDARD.md)). The three that carry the weight:

**§11 Milestones.** Vertical slices, each demoable, riskiest first. F0 is skeleton only. A milestone you cannot demonstrate cannot be validated, and will be wrong for weeks before anyone notices.

**§12 Tasks.** `F{n}-T{k}`, each with eight fields: id, description, files, estimate with basis, traces-to, verification, dependencies, applicable concepts. A task missing any of them is not ready to be picked up.

**§13 Traceability.** Complete in both directions. Every requirement has a task; every task has a requirement. The second direction is the one that gets argued about, and it is the one that catches work nobody asked for.

---

## Sequencing

In priority order:

1. **Unknown-resolving work.** A spike that answers an architectural question belongs before everything that depends on the answer.
2. **Structural dependencies.** What later milestones need to exist.
3. **User-visible value.** Earliest useful demo.
4. **Polish.** Last, always. Polish scheduled early is polish done twice.

The purpose of sequencing is to find out you were wrong while it is still cheap. That means the riskiest, least understood work goes first — which is the opposite of what feels comfortable.

---

## Estimates

Ranges with a basis. `M (2–3 days) — similar to the profile screen in F1` is useful. `2 days` is false precision, and the precision is what makes it misleading.

Estimate the whole task: implementation, tests, review, and the gate. A "one-hour" change that needs a widget test, a golden update and a migration is not a one-hour change.

---

## Keeping the plan true

The plan will diverge from reality. That is expected. What matters is that the divergence is recorded.

```
@flutter-plan-master revise - <what changed and why>
```

Appends to §21. Never renumber ids — a missing `F2-T4` is unexplainable six weeks later, and a reused one is worse.

`@flutter-plan-verify alignment` detects drift between plan and code. Run it at milestone boundaries. A plan that has silently stopped describing the project is not a plan; it is a document.

---

## Common failures

**Foundation as a formality.** Documents written to satisfy a gate rather than to establish facts. The tell is a probe ledger full of one-word answers and a coverage table of 5s.

**Horizontal milestones.** "The data layer" is not a milestone.

**Traceability added afterwards.** Written retroactively, it always passes, and it proves nothing. Build it as you shape the tasks and it catches real gaps.

**NFRs with no measurement.** "Must be fast" is unfalsifiable. "Cold start under 2.0s on a Pixel 6a in profile mode" can be checked, and therefore can fail, which is what makes it a requirement.

**Plans that never say no.** §5's out-of-scope list is what protects the plan from absorbing every good idea anyone has during implementation.
