# Communication Standards

Technical communication standards for OpenJunto engagements. Load for Complex tier where communication complexity justifies explicit quality benchmarks. Use for calibration and meta-review after any engagement where communication quality was a concern.

---

## 6 Communication Standards

### 1. Lead with Impact

Start every recommendation with the user-facing consequence, not the mechanism. The decision-maker needs to know what changes for them before they can evaluate the technical details.

> ✗ "We recommend implementing a Redis-backed sliding window rate limiter."
>
> ✓ "This change will prevent API abuse while keeping legitimate high-volume customers unaffected. Implementation: Redis-backed sliding window rate limiter."

### 2. Quantify Everything

Replace qualitative claims with measurable ones. "Slower" and "more expensive" require calibration to be useful.

> ✗ "JWT verification adds latency."
>
> ✓ "JWT signature verification adds ~2ms p50 per request; below the 200ms SLA. At 10K req/sec, CPU load increases ~12% — within current headroom."

### 3. Provide Runnable Examples

When recommending configuration, code, or commands, include an example the reader can run or paste without modification. Abstract descriptions require interpretation; runnable examples don't.

### 4. Include Failure Scenarios

Every recommendation must address: what does this look like when it fails? If no failure scenario exists, state that explicitly and explain why (narrow scope, full reversibility, etc.).

### 5. Reference Actual Incidents

When recommending against a pattern, cite the incident that revealed the problem. Organizational memory is short; a concrete reference prevents re-learning the same lesson.

> ✓ "In-memory rate limiting was tried in the payments service (INFRA-712, 2025-03); horizontal scaling caused counters to drift and 40% of limits were unenforced. Redis-backed distributed counters resolved this."

### 6. Calculate TCO

For infrastructure decisions, include total cost of ownership across 1 year and 3 years, not just unit cost. A cheaper component with higher operational overhead often has higher TCO.

---

## Standard Response Format

Use this structure for formal deliverables in Moderate and Complex engagements:

```
RECOMMENDATION: [1-2 sentences — what to do and why, leading with impact]

IMPACT: [Quantified user-facing changes — performance, cost, reliability, developer experience]

IMPLEMENTATION: [Steps, code, or configuration — runnable where possible]

RISKS: [Named risks with likelihood and severity; cite incidents if available]

MITIGATION: [Specific mitigations for each risk, or "Accepted risk because [reason]"]

ROLLOUT: [Phased plan — dry-run, canary, GA; rollback trigger and procedure]

METRICS: [What to measure to confirm success; baseline and target values]
```

Not every section requires equal depth. Short engagements may have a one-line ROLLOUT. The structure is a checklist, not a template requiring padding.

---

## Anti-Patterns

| Anti-Pattern | Why Harmful | Instead |
|---|---|---|
| **Unsubstantiated "No Concerns"**: claiming no issues without adversarial analysis | "Looks good" misses real problems; reviewer didn't actively probe | State "tested [specific failure modes], found no concerns because [specific reasoning]" |
| **Manufactured Adversarial Findings**: inventing problems when genuine analysis found none | Fake problems dilute real concerns and waste time on non-issues | Use the "None — resistant because..." path honestly and specifically |
| **Skipping Triage**: applying Complex process to Simple work, or vice versa | Wrong process weight wastes time or misses critical analysis | Always triage first — 0-1 criteria = Simple; 2-3 = Moderate; 4 = Complex |
| **Endless Revision**: perfecting instead of delivering | Pursuit of perfection prevents shipping; stakeholders lose trust in delivery | Use the circuit breaker — after 3 revision cycles, escalate to user with options |
| **Checkbox Theater**: going through protocol motions without adding value | Process overhead without quality improvement; degrades trust in the system | If a gate adds no value in context, note why explicitly and skip it |
| **Echo Chamber**: same reviewers always agreeing | Homogeneous reviews miss blind spots that only surface with different priorities | Rotate reviewer roles; choose stakeholders with different primary concerns |
| **Direct Execution Bypass**: manager does work instead of delegating to a domain expert | Manager lacks domain expertise; skips peer review and adversarial testing | Always delegate via Codex subagent — even for "quick fixes". Exception: Simple tier (must document PERSPECTIVE blocks) |
| **Premature Workaround**: abandoning the delegation process after first subagent failure | Failures are often framing issues, not process failures | Follow the failure protocol: retry with 5 strategies, document, then escalate |
| **Struggling Alone**: manager debugging a problem without expert subagent help | Manager wastes time on problems domain experts solve quickly | Delegate immediately when stuck |
| **Incomplete Delegation**: spawn prompt missing profile path or insufficient context | Expert subagent lacks role definition; reduces output quality and handback usefulness | Always include `<!-- oj-expert: [profile-filename] -->` and full task context in every spawn prompt |

---

## Success Metrics

Track these to validate process effectiveness. Metrics are session-level indicators — they require external tooling to track cross-session.

| Metric | Target | Below-Target Signal |
|--------|--------|---------------------|
| **First-response quality** | > 70% accepted without rework | Experts receiving insufficient context, or missing key stakeholders at triage |
| **Triage accuracy** | > 85% correctly classified | Re-examine triage criteria interpretation; manager may need calibration on causal-chain evaluation |
| **Cycle time** | Simple < 30 min, Moderate < 2 hr, Complex < 8 hr | Process overhead mismatched to tier; or circuit breaker conditions not being caught early |
| **Peer review value** | > 40% adversarial reviews find meaningful issues | Reviews too shallow (strengthen adversarial framing) OR work quality is genuinely high (increase adversarial pressure to verify which it is) |
| **Circuit breaker activations** | Monitor trend, not absolute count | Rising trend signals systematic framing or scoping problems; investigate root cause |

> **AI Agent Context Note**: These metrics are session-level indicators accumulated from handback STATUS fields and reviewer VERDICT fields. Cross-session tracking requires an external system (e.g., a log aggregator reading `.codex/dev/` feedback files). Without external tooling, treat them as qualitative calibration signals rather than precise measurements.

---

## Calibration Checkpoints

After every Moderate or Complex engagement, assess:

1. **Process weight**: Was the tier appropriate? Too heavy adds overhead; too light misses critical analysis.
2. **Stakeholder selection**: Were the right domain experts engaged? Any perspectives that were missing or unused?
3. **Communication quality**: Did deliverables lead with impact? Were risks quantified? Were failure scenarios included?

If the answer to any calibration question reveals a pattern, document it in dev mode feedback (when `OJ_DEVMODE=1`) or in the project `CONDUCTOR.md` as a project-specific pattern to encode going forward.
