# Probe ledger — Fieldnote

Fixture: an honest, complete ledger. Must pass `readiness-verify.sh --gate`.

Every question asked of the operator, the answer, and what it unblocked. Append-only.

The ledger exists so that a question is asked **once**. Re-asking something already answered wastes the operator's patience, which is a finite resource and the one that determines whether the probing gets honest answers.

Engine: `skills/probe-protocol.md`.

---

## Coverage

Stated coverage: 100%

| Dim | Topic | ★ | Score | Confirmed means |
|-----|-------|---|-------|-----------------|
| D1 | Product intent | ★ | 2 | The problem, who has it, and what changes when it is solved |
| D2 | Users | ★ | 2 | Named personas with contexts of use |
| D3 | Platforms | ★ | 2 | Targets with minimum OS versions and form factors |
| D4 | Connectivity | ★ | 2 | Expected conditions and the offline requirement |
| D5 | Constraints | ★ | 2 | Regulatory, compliance, deadline, team, budget |
| D6 | Domain model | ★ | 2 | Entities, relationships, invariants |
| D7 | Feature inventory | ★ | 2 | Features with priorities and acceptance lines |
| D8 | NFRs | ★ | 2 | Numbers with units and reference conditions |
| D9 | Risks | | 2 | Named, with likelihood, impact and mitigation |
| D10 | Release slicing | ★ | 2 | What ships first and why |

Score: 0 unknown · 1 partial · 2 confirmed. ★ dimensions must reach 2 before the phase gate opens.

---

## Ledger

| # | Date | Dim | Question | Answer | Unblocked | Recorded in |
|---|------|-----|----------|--------|-----------|-------------|
| 1 | 2026-08-01 | D1 | What problem, for whom, and what changes when it is solved? | Inspectors re-key paper notes; ~40 min/day lost per inspector | P0 identity | doc 01 §2 |
| 2 | 2026-08-01 | D2 | Who are the named users and in what context? | Field inspector (primary, gloved, outdoors); site manager (reviewer, desk) | P1 personas | doc 02 §1 |
| 3 | 2026-08-01 | D3 | Which platforms, at what minimum versions? | Android 8+ (SDK 26), iOS 15+. No web, no desktop | P1 platforms | doc 02 §2 |
| 4 | 2026-08-01 | D4 | A user opens the app in a basement with no signal. What do they see? | Full capture works offline; a sync banner shows queued count | P1 connectivity | doc 02 §3 |
| 5 | 2026-08-01 | D5 | What regulatory or contractual constraints apply? | Photos may contain faces; GDPR applies; 90-day retention contract | P1 constraints | doc 02 §4 |
| 6 | 2026-08-01 | D6 | What are the entities and their invariants? | Note (immutable once synced), Attachment (<=10 per note), SyncQueueEntry | P4 domain | doc 04 §1 |
| 7 | 2026-08-01 | D7 | Which features, at what priority, with what acceptance? | Capture P0, attach P0, sync P0, export P2 (deferred) | P5 inventory | doc 05 §1 |
| 8 | 2026-08-01 | D8 | You said 'must be fast'. Fast measured how, on which device? | Cold start <= 2000 ms on a Pixel 6a, profile mode, cold install | P5 NFRs | doc 02 §5 |
| 9 | 2026-08-01 | D9 | What could derail this, and what would you notice first? | Drift migration complexity; photo storage sizing unknown | P6 risks | RISK_REGISTRY R1, R2 |
| 10 | 2026-08-01 | D10 | What ships first, and why that? | Capture only — it proves the offline path, which is the riskiest assumption | P6 slicing | doc 05 §3 |

---

## Challenge pass

Claims that were tested rather than accepted. A claim that survives a challenge is worth more than one that was never questioned.

| # | Claim | Challenge | Outcome |
|---|-------|-----------|---------|
| 1 | Offline capture is the riskiest part | Where is the evidence? | Confirmed: no prior offline work in the team; spike scheduled in F1 |
| 2 | Android is the only platform that matters | What if that is wrong? | Weakened: two clients issue iPads. iOS moved from 'later' to F0 |
| 3 | 10 attachments per note is enough | What would a hostile reviewer attack? | Survived: largest historical paper record had 6 photos |

---

## Deferred

Questions consciously not asked yet, with the reason and the point at which they become blocking.

| # | Question | Why deferred | Blocks from |
|---|----------|--------------|-------------|
