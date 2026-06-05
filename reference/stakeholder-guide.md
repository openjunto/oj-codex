# Stakeholder Guide

Reference data for triage: stakeholder mapping, disagreement resolution, and steelman format. Load this file for Moderate and Complex engagements.

---

## Mandatory Pair (All Tiers)

| Stakeholder | Profile | Perspective |
|-------------|---------|-------------|
| Product Manager | `senior-product-manager.md` | Business alignment, user impact, priority |
| Distinguished Engineer | `senior-distinguished-engineer.md` | Technical feasibility, architecture fit, risk |

The mandatory pair participates in every engagement regardless of triage score. They cannot be removed without re-triaging with user confirmation.

---

## Domain Signal → Stakeholder Mapping

| Domain Signal | Stakeholder | Profile | Key Questions |
|---------------|-------------|---------|---------------|
| Security/compliance | Security | `senior-security-engineer.md` | Threat surface, auth model, data exposure, regulatory obligations |
| Data modeling/pipelines | Data | `senior-data-architect.md` | Schema design, migration risk, query patterns, consistency guarantees |
| Cross-system integration | Architecture | `senior-solutions-architect.md` | API contracts, coupling, failure propagation, integration topology |
| Infrastructure/CI-CD | Operations | `senior-devops-engineer.md` | Deployment complexity, rollback, environment parity, pipeline impact |
| Statistics/experimentation | Analytics | `senior-data-scientist.md` | Measurement validity, sample bias, metric definitions, experiment design |
| ML systems/model serving | ML | `senior-ml-engineer.md` | Model lifecycle, inference latency, drift, feature pipeline |
| Enterprise standards | Enterprise | `senior-enterprise-architect.md` | Governance, compliance posture, architectural standards, audit |
| Requirements/process | Business | `senior-business-analyst.md` | Acceptance criteria, business rules, stakeholder alignment |
| Documentation needs | Documentation | `senior-technical-writer.md` | Audience, completeness, maintainability, discoverability |
| Process improvement | Process | `senior-engineering-consultant.md` | Workflow efficiency, bottlenecks, team dynamics, adoption |
| Leadership/org dynamics | Leadership | `senior-executive-leadership-coach.md` | Change management, alignment, political risk, sponsorship |
| Test strategy/quality | Quality | `senior-test-engineer.md` | Test coverage, edge cases, regression risk, quality gates |
| SLOs/reliability | Reliability | `senior-site-reliability-engineer.md` | Error budgets, failure modes, observability, on-call impact |
| Code/refactoring | Implementation | `senior-software-engineer.md` | Code quality, maintainability, technical debt, implementation risk |

### Signal Identification Heuristics

1. **Explicit**: "design an API" → Architecture; "implement feature" → Implementation
2. **Implicit**: "user-facing change" → Quality; "store customer data" → Security
3. **Risk indicators**: "production system" → Reliability; "financial data" → Security + Data
4. **Deliverable type**: "document the API" → Documentation; "improve deployment" → Operations

---

## Stakeholder Escalation Guard

| Current Tier | Condition | Action |
|--------------|-----------|--------|
| Simple | 4+ total stakeholders | Escalate to Moderate |
| Moderate | 5+ total stakeholders | Escalate to Complex |

The guard picks the higher tier as a safety default. Over-triaging is corrected via calibration signals, not by relaxing the guard inline. The resulting tier is always `max(current_tier, guard_tier)` — never a downgrade.

---

## Common Task Patterns

| Task Pattern | Additional Stakeholders (beyond mandatory pair) |
|--------------|--------------------------------------------------|
| System architecture | Architecture, Security |
| Security review | Security, Architecture |
| Data pipeline design | Data, Operations |
| New feature / implementation | Business, Implementation, Quality |
| ML/AI implementation | ML, Analytics, Security |
| Performance / reliability | Operations, Reliability, Data |
| Cost optimization | Operations, Data |
| Incident response | Operations, Reliability, Security |
| Bug investigation | Implementation, Operations, Reliability |
| Code refactoring | Implementation, Quality |
| Documentation | Documentation |
| Process improvement | Process |

---

## Conflict Classification

| Conflict Type | Primary Resolver | Escalation |
|---------------|-----------------|------------|
| **Technical** (architecture, tech choice) | Distinguished Engineer | DE → User if uncertain |
| **Business** (priority, scope, resources) | Product Manager | PM → User if uncertain |
| **Mixed** (technical + business) | DE + PM joint recommendation | Joint → User; deadlock: escalate with both positions |
| **Cross-Domain** (security vs. perf, cost vs. reliability) | Domain stakeholders present trade-offs | User decides |

---

## Tension Classification

| Type | Definition | Action |
|------|-----------|--------|
| **Resolvable** | Evidence favors one side | Apply primary resolver |
| **Trade-off** | Mutually exclusive; no objectively correct answer | Present both; User decides |
| **Productive Tension** | Interaction reveals deeper constraint | Do NOT resolve — forward as constraint |

**Key rule**: Productive Tension items become TENSION entries in the findings ledger and are PROTECTED — they are forwarded to the implementer and reviewer unchanged.

---

## Resolution Steps

1. **Identify** conflict type using the Conflict Classification table above
2. **Document** both positions with rationale (required before resolution)
3. **Apply** primary resolver
4. **Time-box**: If debate stalls (~10-20 min), escalate
5. **Escalate to User** when: resolver is uncertain, disagreement persists, or stakes are high

---

## DISSENT Format

When a stakeholder's position is overruled, document it:

```
DISSENT: [Stakeholder] | [Position + Rationale] | [Resolution]
```

**Example**: `DISSENT: Security | Prefer 100 req/min; willing to accept false positives | Resolution: 200 req/min with per-endpoint overrides; Security accepted`

---

## Steelman Format

Before rejecting an alternative, document the strongest case for it:

```
STEELMAN OF REJECTED ALTERNATIVE:
- Alternative: [Rejected approach]
- Strongest argument for it: [Best case for this path]
- Why rejected: [Why chosen approach wins despite above]
```

**By tier**:
- **Simple**: Note briefly inline; no formal steelman block required
- **Moderate**: Steelman 1 rejected alternative
- **Complex**: Steelman top 1-2 rejected alternatives

**Example**:

```
STEELMAN OF REJECTED ALTERNATIVE:
- Alternative: In-memory token bucket
- Strongest argument for it: Zero dependencies, sub-ms latency, trivially testable
- Why rejected: Cannot enforce limits across multiple instances; requirement is global rate limiting
```

---

## Example Conflicts

| # | Scenario | Conflict Type | Resolution Path |
|---|----------|---------------|-----------------|
| 1 | Security wants 100 req/min rate limit; Operations wants 300 req/min for headroom | Cross-Domain | Both stakeholders present trade-offs; User decides threshold |
| 2 | Implementation proposes microservice split; Distinguished Engineer sees premature decomposition | Technical | Distinguished Engineer is primary resolver; escalate to User if DE uncertain |
| 3 | Product Manager wants MVP by end of sprint; Security requires full threat model first | Mixed | DE + PM joint recommendation; escalate to User if deadlock |
| 4 | Data Architect warns migration is destructive; Reliability flags SLO breach during window | Cross-Domain | Forward both as hard constraints; User decides migration approach |

---

## Special Cases

### Simple Task, Complex Disagreement

If stakeholders deadlock on a Simple-tier task, escalate to user. Do not let a Simple task drag into Complex-tier process. Time-box at ~10 min.

### Stakeholder Overload (8+)

Present three options to user:
1. Escalate to Complex for parallel subagent coordination
2. Reduce to "must have" stakeholders
3. Proceed sequential Moderate, accept timeline
