# flutter-plan-master — reference

Extended tables for [`skill.md`](skill.md). Read the section you need; do not load the file wholesale.

---

## 1. The 21 sections

Authoritative definitions live in [`MASTER_PLAN_STANDARD`](../../standards/20260801-MASTER_PLAN_STANDARD.md). This is the working checklist with the source for each section, so the plan can be assembled without inventing anything.

| # | Section | Source | Empty is acceptable when |
|---|---------|--------|--------------------------|
| 1 | Summary | Foundation doc 01 | never |
| 2 | Source foundation | Certification record | never |
| 3 | Technology stack | `STACK.md` | never |
| 4 | Architecture summary | Foundation doc 03 | never |
| 5 | Scope | Foundation doc 05 | never; "out of scope" and the cut list are what prevent scope creep |
| 6 | Functional requirements | Foundation doc 05 feature inventory | never |
| 7 | Non-functional requirements | Foundation doc 02 §NFR | never |
| 8 | Platform matrix | Foundation doc 02 | single-platform, stated explicitly |
| 9 | Domain and data plan | Foundation doc 04 | no persistence — state it |
| 10 | Navigation map | Foundation doc 05 | single-screen app |
| 11 | Milestones | Derived | never |
| 12 | Task breakdown | Derived | never |
| 13 | Traceability matrix | Derived from 6, 7, 12 | never |
| 14 | Verification strategy | Derived | never |
| 15 | Test plan | `TESTING_STANDARD` + NFRs | never |
| 16 | Release plan | Foundation doc 05 slicing | internal tool with no store presence |
| 17 | Risks | `RISK_REGISTRY.md` | never — "no risks identified" is itself a finding |
| 18 | Assumptions | `ASSUMPTIONS.md` | no assumptions were made (rare; be suspicious) |
| 19 | Open questions | `UNKNOWNS.md` | all resolved — say so |
| 20 | Concept / NFR registry | Derived | never |
| 21 | Revision history | Maintained by `revise` | at creation, one entry |

Verified mechanically by [`master-plan-verify.sh`](../../scripts/master-plan-verify.sh).

---

## 2. Milestone shaping

A milestone is a **demoable increment**, not a layer. "Build the data layer" is not a milestone; nobody can look at it and tell you whether it is right.

| Rule | Reason |
|------|--------|
| F0 is skeleton only | Project structure, CI, theming, routing shell. No product features |
| Each F(n≥1) is vertically sliced | UI + logic + data for one capability. A horizontal slice cannot be demonstrated or validated |
| Riskiest work goes early | The purpose of sequencing is to find out you were wrong while it is still cheap |
| Each milestone has an exit demo | One sentence: what a person can do at the end that they could not before |
| 3–8 tasks per milestone | Fewer means the milestone is a task; more means it hides a second milestone |
| Dependencies point backwards only | F3 may depend on F1. F1 depending on F3 is a sequencing error, not a dependency |

**Ordering heuristics, in priority order:** unknown-resolving work first (a spike that answers an architectural question); then anything a later milestone's structure depends on; then user-visible value; then polish. Never the reverse — polish scheduled early is polish done twice.

---

## 3. Task requirements

Every task carries all eight fields. A task missing any of them is not ready to be picked up.

| Field | Form | Failure if absent |
|-------|------|-------------------|
| ID | `F{n}-T{k}` | Cannot be traced, referenced in a commit, or gated |
| Description | Imperative, one outcome | The agent guesses at scope |
| Files | Paths, or a glob for a new module | Blast radius is unbounded; `touch-scope` cannot be declared |
| Estimate | S/M/L or hours **with a basis** | False precision, or none |
| Traces to | FR-nn / NFR-nn | Work with no requirement behind it |
| Verification | The command or the audit | "Done" becomes a matter of opinion |
| Depends on | Task ids, or `none` | Executed out of order |
| Concepts | FLS ids that apply | The relevant lens is never run |

**Sizing:** a task is too large when its file list spans more than one layer *and* more than three files. Split by layer, or by capability. A task that cannot be verified in isolation is two tasks.

---

## 4. Traceability matrix

Two directions, both mandatory. Checked by [`traceability-verify.sh`](../../scripts/traceability-verify.sh).

```markdown
| Requirement | Tasks | Verified by |
|-------------|-------|-------------|
| FR1 Sign in with email | F1-T2, F1-T3, F1-T5 | widget + integration test |
| NFR3 Cold start < 2.0s | F0-T4, F6-T1 | @flutter-perf startup |
```

| Failure | What it means | Fix |
|---------|--------------|-----|
| Requirement with no task | It will not be built | Add tasks, or move the requirement to out-of-scope with a reason |
| Task with no requirement | Work nobody asked for | Delete it, or find the requirement it serves and name it |
| NFR with no verification | Unfalsifiable quality claim | Name the measurement, or drop the NFR |

The second failure is the one that gets defended. "It is obviously needed" is not a requirement — if it is obviously needed, writing it down costs one line.

---

## 5. Probe coverage map

Dimensions scored during `probe`. ★ dimensions block certification below 4.

| Dim | Question the plan must answer | ★ |
|-----|-------------------------------|---|
| M1 | Does every foundation feature appear as an FR, or is it explicitly deferred? | ★ |
| M2 | Is the milestone order justified by risk, not convenience? | ★ |
| M3 | Can each milestone be demonstrated? | ★ |
| M4 | Does every task name its files? | ★ |
| M5 | Is every NFR attached to a measurement? | ★ |
| M6 | Are estimates backed by a stated basis? | |
| M7 | Are dependencies acyclic and backwards-only? | ★ |
| M8 | Is the release slicing consistent with foundation doc 05? | |
| M9 | Does the plan name what it is *not* doing? | ★ |
| M10 | Are the top risks in the registry sequenced early? | |

**Challenge pass questions** (after the coverage loop, per [`probe-protocol.md`](../probe-protocol.md)):

- Which milestone is most likely to slip, and what in the plan reflects that?
- If F1 turns out to be wrong, how much of F2–F4 is invalidated?
- Which requirement here came from an assumption rather than a stated need?
- What would a hostile reviewer say this plan is avoiding?
- Which task would you be unable to start tomorrow morning without asking someone a question?

The last one is the most productive. A task that cannot be started without a conversation is under-specified, and the conversation will happen either now or at the worst possible time.

---

## 6. Integrity checks

Run by `integrity`, and again by `@flutter-plan-verify master`.

| Check | Script | Blocker |
|-------|--------|---------|
| 21 sections present | `master-plan-verify.sh` | yes |
| Front matter complete | `master-plan-verify.sh` | yes |
| ID conventions (`F{n}`, `F{n}-T{k}`, no `M{n}`) | `master-plan-verify.sh` | yes |
| No `TBD` / `TODO` / `REPLACE:` residue | `master-plan-verify.sh` | yes |
| Bidirectional traceability | `traceability-verify.sh` | yes |
| Unique task ids | `traceability-verify.sh` | yes |
| Tasks reference declared milestones | `traceability-verify.sh` | yes |
| Every task has all eight fields | manual | yes |
| Dependency graph is acyclic | manual | yes |
| Foundation certification still current | manual | yes — a plan built on a superseded foundation is stale |

Quote the script output in the report. An integrity verdict with no output behind it is an assertion.

---

## 7. Revising an approved plan

`revise` appends; it never rewrites.

| Change | Handling |
|--------|----------|
| Task added within an existing milestone | Next free `F{n}-T{k}`. Never renumber |
| Task removed | Mark `Cancelled` with a reason. Do not delete — a missing id is unexplainable later |
| Task re-scoped | Amend in place, log in §21 |
| Milestone added | Next free `F{n}`, even if it sequences earlier |
| New requirement | Needs foundation support. No foundation basis → `@flutter-foundation continue` first |
| Scope reduction | Requires operator re-approval. Silent descoping is the most common way a plan stops describing the project |

Every revision entry: date, what changed, why, who asked. Then re-run `integrity`.
