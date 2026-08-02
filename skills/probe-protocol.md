# Probe protocol (shared engine)

**Single source of truth** for the adaptive, gap-driven interrogation loop used by every `probe` mode, and for the **challenge pass** used by planning, verification and repair skills. Callers **reference** this file; they do not restate the loop. Each caller supplies a **coverage profile** (dimensions + exit gate + ledger path); this file owns the engine.

Not a skill folder — a shared engine doc (it does not count as a skill).

**Who uses it**

| Caller | Coverage profile | Ledger |
|--------|------------------|--------|
| `@flutter-stack probe` | 7 stack dimensions (K1–K7) | `{FLUTTER_WORK_ROOT}/STACK.md` § Probe |
| `@flutter-foundation probe` | 10 product/platform dimensions (D1–D10) | `{FLUTTER_PLANS_ROOT}/foundation/PROBE_LEDGER.md` |
| `@flutter-plan-master probe` | 8 plan-completeness dimensions (P1–P8) | `{FLUTTER_PLANS_ROOT}/full/PROBE_LEDGER.md` |
| `@flutter-feature-spec probe` | 6 spec-completeness dimensions (S1–S6) | `{FLUTTER_SPEC_ROOT}/<slug>/PROBE_LEDGER.md` |
| Any skill running a **challenge pass** | n/a (adversarial, not scored) | inline in the report |

---

## When to probe

Probe when understanding is **thin**, not when it is merely incomplete. Signals: vague users or jobs-to-be-done, no named target platforms, "it should be fast" with no number, unowned risks, offline behaviour unspecified, auth/identity hand-waved, no decision on state management, a feature list with no priority.

The goal is to **interrogate until the agent can defend its readiness claim under challenge** — not to collect answers, and never to guess.

**Do not probe** to stall. If the blocking gap is a decision only the operator can make and they have deferred it twice, record it in `UNKNOWNS.md` with an owner and move on.

---

## The loop

One pass = **one probe iteration**:

```text
ASSESS → PRIORITIZE → ASK (≤5 targeted questions) → RECORD → RE-SCORE → CHALLENGE → EXIT?
```

1. **ASSESS** — score every dimension in the caller's coverage map: status `confirmed | partial | unknown`, confidence `high | med | low`, each with **cited evidence** (file + section, or "owner answer, this session").
2. **PRIORITIZE** — target gate-blocking (★) dimensions that are `unknown` or `low` first. Never spend a question on a dimension already `confirmed/high`.
3. **ASK** — ≤5 specific, answerable questions in **one batch**. See § Question quality bar.
4. **RECORD** — write answers into the **canonical artifacts** (foundation docs, SPEC sections, registries) **and** update the ledger. Set `confirmed/high` **only** with a cited source or a same-session owner answer. An agent inference is `partial/med` at best — never `high`.
5. **RE-SCORE** — recompute Coverage; append an iteration row to the ledger.
6. **CHALLENGE** — run § The challenge pass against the current claim.
7. **EXIT?** — stop when Coverage ≥ target **and** no ★ dimension is below `partial` **and** the challenge pass produced no unanswered objection. Otherwise carry open probes to the next pass. Owner-blocked items → `UNKNOWNS.md` (never invent answers).

---

## Coverage Score

```text
Coverage = ( Σ weight×conf ) / Σ weight
conf: high=1.0  med=0.5  low=0.0      weight: gate-blocking(★)=2  else=1
```

Target defaults to **85%**. A ★ dimension still `unknown` blocks the exit gate **regardless of the percentage** — you cannot average your way past a missing platform target.

---

## Question quality bar

A probe question earns its place only if it passes all five tests. Reject and rewrite any question that fails one.

| # | Test | Bad | Good |
|---|------|-----|------|
| 1 | **Decidable** — the operator can answer it without new research | "What is your architecture?" | "Single Flutter app, or app + shared packages in a melos workspace?" |
| 2 | **Consequential** — a different answer changes an artifact | "What's the app called?" (already in doc 01) | "Must the app work fully offline, or is read-only cache enough?" |
| 3 | **Bounded** — offers options or a unit when one exists | "How fast should it be?" | "Cold-start budget on a mid-tier Android: ≤2s, ≤3s, or ≤5s?" |
| 4 | **Non-leading** — does not smuggle in the agent's preference | "You want Riverpod, right?" | "Team's prior state-management experience: Bloc, Riverpod, Provider, none?" |
| 5 | **Single-barrelled** — one decision per question | "Which platforms and what's the min OS and do you need tablets?" | Three separate questions (or one, if only one is blocking) |

**Format each batch like this:**

```markdown
### Probe pass <N> - <caller> (coverage <NN>% → target 85%)

Blocking: <D3 ★ platform targets>, <D6 ★ offline behaviour>

1. **[D3 ★]** <question> — options: <a> / <b> / <c>
2. **[D6 ★]** <question> — options: …
3. **[D5]** <question>

Answer any subset. Reply `skip <n>` to defer one to UNKNOWNS, or `skip all` to exit this pass.
```

Always show which dimension a question serves and why it blocks. An operator who can see the gate is far more likely to answer it.

---

## The challenge pass

**This is the "grilling".** Probing collects; challenging tests. Run a challenge pass before any `certify`, before flipping a SPEC to `Approved`, before `@flutter-implementation complete`, and at the end of every probe iteration.

Take the claim you are about to make (`foundation-complete`, `plan-ready`, `SPEC is implementable`, `milestone done`) and attack it with these five questions. **Write the answers down** — an unanswered objection is a blocker, not a footnote.

| # | Challenge | You must be able to answer with |
|---|-----------|----------------------------------|
| C1 | **Where is the evidence?** Which file and section proves each ★ dimension? | A path + heading. "I recall discussing it" is a `fail`. |
| C2 | **What would a hostile reviewer attack first?** | The single weakest claim, named, plus why it is acceptable or what it blocks. |
| C3 | **What did we decide by default rather than on purpose?** | Every silent default (state management, min SDK, offline stance, error surface) either promoted to a recorded decision or logged in `UNKNOWNS.md`. |
| C4 | **What breaks this on a real device?** | Named failure mode per target platform: slow network, no network, low-end Android, iOS background suspension, small screen, screen reader, locale with long strings, RTL. |
| C5 | **What is the cost of being wrong here?** | Reversible (proceed and note) vs expensive-to-reverse (stop and confirm with the operator). |

**Verdict:** `defensible` (all five answered with evidence) · `defensible with gaps` (gaps named, owned and logged) · `not defensible` (stop; run another probe pass).

**Hard rule:** never emit `certify`, `Approved`, or `complete` on a `not defensible` challenge. Emit the blocked report instead.

---

## Ease-of-use rules

- **Never** dump the whole coverage map at the operator — ask only what is blocking.
- ≤5 questions per pass; batch them; always accept "skip / defer" → ledger § Deferred → `UNKNOWNS.md`.
- Offer options whenever a bounded set exists. Recommend one and say why in a single clause; do not argue for it.
- A probe must always end with a clear next action: `continue`, `certify`, or a **named** blocker with an owner.
- Two consecutive passes with no new information → stop probing, write the gaps to `UNKNOWNS.md`, and report `probe exhausted` with what is still unknown.
- `probe - status` reports the ledger read-only. `probe - until ready` loops without re-confirming between passes, still honouring the ≤5-per-pass rule and the exhaustion rule.

---

## Ledger

Persist state in the caller's ledger so a probe is **resumable and auditable** across sessions and across different LLMs.

Template: [`templates/work.flutter/plans/foundation/PROBE_LEDGER.md`](../templates/work.flutter/plans/foundation/PROBE_LEDGER.md). Honesty rules are machine-checked by [`scripts/readiness-verify.sh`](../scripts/readiness-verify.sh). The script is the source of truth for shape: a coverage table with numeric **Score** (0/1/2), and a Q&A ledger table that records the actual questions. `certify` adds `--gate`, which also requires every ★ dimension at score 2.

Required ledger shape (must match the template and the verifier — do not invent a parallel Status/Conf table):

```markdown
## Coverage

Stated coverage: 100%

| Dim | Topic | ★ | Score | Confirmed means |
|-----|-------|---|-------|-----------------|
| D1 | Product intent | ★ | 2 | … |
| D9 | Risks | | 2 | … |

Score: 0 unknown · 1 partial · 2 confirmed.

## Ledger

| # | Date | Dim | Question | Answer | Unblocked | Recorded in |
|---|------|-----|----------|--------|-----------|-------------|
| 1 | YYYY-MM-DD | D1 | … | … | P0 identity | doc 01 §2 |

## Challenge pass
| # | Claim | Challenge | Outcome |

## Deferred
| # | Question | Why deferred | Blocks from |
```

Entry `#` may be a bare integer (`1`) or a short prefixed id (`L1`). Every dimension at Score 2 must appear in at least one Ledger row. Empty Answer or Recorded-in cells fail the honesty check.