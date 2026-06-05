# Worked Examples

End-to-end examples for all three tiers demonstrating triage → execution → verification. Use these for calibration and onboarding; experienced operators can skip once fluent.

---

## Example 1: Simple Tier — Health Check Endpoint

### User Request

> "Add a `/health` endpoint to the API service that returns 200 OK with `{"status": "ok"}`. No auth required."

### Triage Result

| Criterion | Scored? | Rationale |
|-----------|---------|-----------|
| Spans multiple domains | No | Single service change |
| Regulatory/compliance | No | Public health endpoint, no sensitive data |
| Production stability risk | No | Read-only, stateless endpoint |
| Significant cost/resource | No | Trivial implementation |

**Score**: 0 → **Simple tier**. No mandatory escalation triggers.

**Stakeholders**: Product Manager, Distinguished Engineer, Software Engineer (implementation signal)
**Total**: 3 — below escalation guard threshold.

### Inline Perspective Rotation

```
PERSPECTIVE: Product Manager (senior-product-manager-compact.md)
LENS: Business value, user impact, priority alignment
ASSESSMENT: Health checks are standard infrastructure; enables load balancer integration and monitoring tooling.
CONCERN: None — straightforward requirement with clear acceptance criteria.

PERSPECTIVE: Distinguished Engineer (senior-distinguished-engineer-compact.md)
LENS: Technical feasibility, architecture fit, risk
ASSESSMENT: Stateless GET endpoint; zero coupling risk. Follow existing route registration pattern.
CONCERN: None — ensure endpoint bypasses auth middleware or this becomes a correctness bug.

PERSPECTIVE: Software Engineer (senior-software-engineer-compact.md)
LENS: Implementation quality, maintainability, technical debt
ASSESSMENT: One route registration, one handler returning static JSON. Testable with a single integration test.
CONCERN: None — confirm auth middleware exclusion list is the established pattern, not a bespoke bypass.
```

### Synthesis

All three perspectives agree: standard, low-risk endpoint. Distinguished Engineer surfaces the critical constraint: the endpoint must bypass auth middleware using the established exclusion pattern, not a bespoke bypass. Implementation delegates to Software Engineer with this constraint as a hard requirement.

### Verification Checklist

- [ ] Directly addresses the original question (returns 200 OK with `{"status": "ok"}`)
- [ ] All identified stakeholder perspectives documented (3 PERSPECTIVE blocks above)

---

## Example 2: Moderate Tier — Rate Limiting for Public API

### User Request

> "Add rate limiting to our public API. We're seeing abuse from a small number of IPs sending thousands of requests per minute. Need to protect the backend without breaking legitimate high-volume customers."

### Triage Result

| Criterion | Scored? | Rationale |
|-----------|---------|-----------|
| Spans multiple domains | Yes | Security policy + infrastructure + business rules |
| Regulatory/compliance | No | No PCI/GDPR scope |
| Production stability risk | Yes | Rate limiting misconfiguration could block legitimate traffic |
| Significant cost/resource | No | Redis addition is incremental |

**Score**: 2 → **Moderate tier**.

**Stakeholders**: Product Manager, Distinguished Engineer, Security Engineer (abuse/compliance signal), Operations (infrastructure signal)
**Total**: 4 — below escalation guard threshold.

### Phase 1: Parallel Stakeholder Analysis

Spawn two subagents in parallel:

```
<!-- oj-expert: senior-security-engineer -->
You are a Senior Security Engineer.
**TASK**: Analyze rate limiting requirements from a security perspective.
Focus on: abuse patterns and thresholds, bypass attack vectors (distributed clients, header spoofing), 
allowlisting strategy for legitimate high-volume customers, logging and alerting for rate limit events.
Do NOT implement — analysis and findings only.
Output: FINDING/TENSION items for the findings ledger.
```

```
<!-- oj-expert: senior-devops-engineer -->
You are a Senior DevOps Engineer.
**TASK**: Analyze rate limiting implementation from an infrastructure perspective.
Focus on: Redis vs. in-memory trade-offs for distributed enforcement, deployment complexity, 
rollback strategy if rate limits trigger incorrectly, monitoring and observability hooks.
Do NOT implement — analysis and findings only.
Output: FINDING/TENSION items for the findings ledger.
```

### Synthesis Gate

Manager consolidates handbacks into findings ledger:

```
FINDING: IP-based limiting alone is bypassable via rotating IPs or shared NAT | SOURCE: Security | CONFIDENCE: H
FINDING: Redis-backed sliding window is proven for distributed rate limiting at this scale | SOURCE: Operations | CONFIDENCE: H
FINDING: Allowlist mechanism needed before shipping — at least 3 known high-volume partners | SOURCE: Security | CONFIDENCE: H
FINDING: Deploy in dry-run (log-only) mode first to observe impact on real traffic | SOURCE: Operations | CONFIDENCE: M
TENSION: Security wants 100 req/min threshold; Operations wants 300 req/min to avoid false positives | SOURCES: Security, Operations | STATUS: unresolved
```

**Constraint classification**:
- `IP-based limiting alone is bypassable` → **Hard** (Security domain authority)
- `Redis-backed sliding window` → **Hard** (Operations domain authority + Security corroboration)
- `Allowlist mechanism before shipping` → **Hard** (Security domain authority)
- `Deploy in dry-run mode first` → **Soft** (Operations only, no corroboration)
- `TENSION: threshold 100 vs 300` → **PROTECTED** — forwarded to implementer and reviewer

No `CONFIDENCE: Low` on named assumptions → no synthesis gate pause required.

### Phase 2: Lead Implementation

```
<!-- oj-expert: senior-software-engineer -->
You are a Senior Software Engineer.
**TASK**: Implement Redis-backed rate limiting middleware for the public API.

Stakeholder findings:
- Security: IP-based limiting is bypassable alone; combine with API key limiting. Allowlist required before GA.
- Operations: Redis sliding window is the proven pattern; deploy dry-run first.

Hard constraints (must address):
1. Use Redis-backed sliding window — not in-memory
2. Support allowlisting for known high-volume partners
3. IP-based + API key dual-layer enforcement

TENSION (do not resolve — forward to adversarial reviewer):
TENSION: Security wants 100 req/min threshold; Operations wants 300 req/min | SOURCES: Security, Operations | STATUS: unresolved

Include PRE-MORTEM (≥2 failure scenarios) before the implementation plan.
Output: implementation plan + handback.
```

### Phase 3: Adversarial Review

```
<!-- oj-expert: senior-solutions-architect -->
You are a Senior Solutions Architect acting as adversarial reviewer.
**TASK**: Find the single most important problem with this rate limiting design.

Test against these failure modes:
- Distributed bypass: clients rotating IPs or using shared NAT pools
- Cache poisoning or counter manipulation via Redis key collision
- Thundering herd: all clients hitting the limit simultaneously on reset
- Allowlist bypass: can allowlisted keys be forged or stolen?
- Dry-run mode left on: limit never actually enforced in production

TENSION to forward: Security wants 100 req/min; Operations wants 300 req/min.
This tension is unresolved — note it in your review; do not resolve it.

Output adversarial review in standard format.
```

---

## Example 3: Complex Tier — Authentication Migration (Session → JWT)

### User Request

> "We need to migrate our authentication from session-based cookies to JWT tokens. This affects every service, the mobile app, and our partner API integrations. We have 90 days before the old auth system is decommissioned."

### Triage Result

| Criterion | Scored? | Rationale |
|-----------|---------|-----------|
| Spans multiple domains | Yes | Auth, all services, mobile, partner integrations |
| Regulatory/compliance | Yes | Auth changes affect PCI scope |
| Production stability risk | Yes | Auth failure = complete outage |
| Significant cost/resource | Yes | 90-day hard deadline, all teams involved |

**Score**: 4 → **Complex tier**. Mandatory escalation: `security_vulnerability` (auth system change).

**Stakeholders**: Product Manager, Distinguished Engineer, Security Engineer, Solutions Architect, DevOps Engineer, Software Engineer, Test Engineer
**Total**: 7 stakeholders.

### Team Formation

```
Manager (high-level coordination, user interaction)
  └── Coordinator subagent (synthesis, quality gates, task graph)
        ├── Security Engineer subagent (auth threat model, JWT security)
        ├── Solutions Architect subagent (service integration topology)
        ├── DevOps Engineer subagent (deployment strategy, rollback)
        ├── Software Engineer subagent (lead implementation)
        └── Test Engineer subagent (test strategy, regression coverage)
```

Coordinator is spawned first with the full stakeholder plan. All other subagents report handbacks to the coordinator. Peer-to-peer messaging is not used — all coordination flows through the coordinator via consolidated handbacks.

### 8-Step Execution Flow

1. **Manager → Coordinator**: Full briefing — stakeholders, constraints, 90-day deadline, TENSION items identified at intake
2. **Coordinator → [parallel]**: Spawn Security, Architecture, Operations, Quality subagents for domain analysis (unblocked, parallel)
3. **[Parallel analysis]**: Each subagent returns FINDING/TENSION items; coordinator accumulates findings ledger
4. **Coordinator → Manager**: Synthesized findings ledger + constraint classification; TENSION items flagged
5. **Manager → User**: Synthesis gate pause if any `CONFIDENCE: Low` on named assumptions; present findings
6. **Coordinator → Implementation**: Spawn Software Engineer with synthesized findings + hard constraints; includes pre-mortem (≥3 scenarios)
7. **Coordinator → Adversarial Reviewer**: Spawn cross-domain adversarial reviewer (Distinguished Engineer or Security) with full work product + TENSION items
8. **Coordinator → Manager → User**: Stage 8 User Checkpoint — present synthesis, obtain explicit approval before proceeding to rollout

### Task Graph (Declarative Dependencies)

```
Task 1: Security threat model          [unblocked]
Task 2: Integration topology analysis  [unblocked]
Task 3: Deployment + rollback plan     [unblocked]
Task 4: Test strategy                  [unblocked]
Task 5: Implementation plan            [blockedBy: 1, 2, 3, 4]
Task 6: Adversarial review             [blockedBy: 5]
Task 7: User Checkpoint                [blockedBy: 6]
Task 8: Retrospective                  [blockedBy: 7]
```

### Pre-Mortem (≥3 Scenarios Required)

```
PRE-MORTEM:
1. Token expiry causes mass logout during peak traffic: Mitigated by 1-hour access + 7-day refresh window with 
   silent refresh; coordinate with mobile team on refresh flow
2. Partner integrations break silently — partners using undocumented session fields: Accepted risk with mitigation — 
   partner API audit before cutover; 2-week parallel run period
3. JWT secret rotation causes outage if not coordinated across all services: Mitigated by centralized secret 
   management (Vault) with rolling key rotation support before migration begins
4. Mobile clients cache old auth headers — cache invalidation not possible server-side: Mitigated by force-upgrade 
   mechanism; fallback to grace period for old token format
```

### Verification (Complex Tier Quality Gates)

- [ ] Directly addresses the original question
- [ ] All 7 stakeholder perspectives represented
- [ ] Assumptions explicitly stated with risks and mitigations
- [ ] Adversarial review by cross-functional stakeholders (failure modes tested)
- [ ] Dissenting views documented (even if overruled)
- [ ] Success criteria defined
- [ ] Pre-mortem conducted (3+ failure scenarios)
- [ ] Rejected alternatives steelmanned
- [ ] Retrospective completed
