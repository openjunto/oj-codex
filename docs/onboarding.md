# Onboarding — First 10 Minutes

This guide walks through the first 10 minutes after installing oj-codex.

## 1. Confirm Installation

Start (or restart) a Codex CLI session. You should see a banner on stderr:

```
OpenJunto v0.0.2 active — OpenJunto coordination system
```

The banner is emitted by the `SessionStart` hook (`oj-helper conductor-inject`). It appears
on session start — startup, resume, or `/clear` — NOT on `/plugin reload` or in-process
plugin refreshes. If the banner is missing after installing, run `/clear` or start a new
session to re-fire `SessionStart` and re-inject `CONDUCTOR.md`.

The version string is read from the plugin's `VERSION` file. `unknown` means the file is
missing from the installation.

## 2. Your First Task

Start with something where multi-perspective review adds obvious value:

```
/oj:cycle Review this file for security issues: src/auth/token_validator.go
```

Observe what happens:

1. **Triage** — Manager scores the request (security signal → Moderate or Complex)
2. **Stakeholder selection** — Security Engineer + Distinguished Engineer spawned
3. **Analysis** — Each expert returns a structured handback with STRONGEST OBJECTION
4. **Synthesis** — Manager consolidates findings into a unified review

The `/oj:cycle` prefix is required. Free-form messages outside a skill invocation do not
trigger manager triage — the Manager responds directly and conversationally. Use `/oj:cycle`
to engage the full coordination protocol.

## 3. Understanding Triage

The Manager scores every `/oj:cycle` request against 4 criteria:

| # | Criterion |
|---|---|
| 1 | Spans multiple technical domains? |
| 2 | Regulatory or compliance implications? |
| 3 | Could impact production stability? |
| 4 | Significant cost or resource commitment? |

**Scoring**: 0–1 = Simple (inline perspective rotation), 2–3 = Moderate (parallel sub-agents),
4 = Complex (parallel sub-agents + User Checkpoint before synthesis).

The Manager presents the triage result before proceeding:

> "I've triaged this as Moderate with 3 stakeholders: Security Engineer, DevOps Engineer,
> Distinguished Engineer. Does this match your expectations, or would you like to adjust?"

**You can override triage.** If the Manager over-processes a simple task, push back:

> "This is a typo fix. Just do it."

Process weight should match the blast radius of failure — not every request needs full scrutiny.

## 4. Stakeholder Selection

Every task gets **Product Manager + Distinguished Engineer** as the mandatory pair. Domain
signals add more:

| Signal in task | Added stakeholder |
|---|---|
| Security / auth / crypto / compliance | Security Engineer |
| Data modeling / pipelines / schema | Data Architect |
| Infrastructure / CI/CD / deployment | DevOps Engineer |
| ML systems / model serving | ML Engineer |
| SLOs / reliability / on-call | Site Reliability Engineer |
| Test strategy / quality | Test Engineer |

The Manager selects stakeholders — you don't name them. The full roster is in
[`agents/index.md`](../agents/index.md).

## 5. Reading Expert Handbacks

Every Moderate/Complex expert returns a structured handback:

```
HANDBACK: Security Engineer
STATUS: Complete
DELIVERABLE: Threat model for token_validator.go
RECOMMENDATION: Replace HMAC-SHA1 with HMAC-SHA256; rotate signing keys on compromise.
RATIONALE: SHA1 collision resistance is insufficient for production auth tokens.
STRONGEST OBJECTION: Key rotation requires a coordinated deploy; partial rollout risks
  token rejection for in-flight sessions.
FALSIFIER: Fails if token expiry < rotation window because expired tokens cannot be
  re-issued before clients retry.
CONFIDENCE: High
CAVEATS: Assumes tokens are not persisted client-side beyond expiry.
NEXT ACTIONS: Update token.go:42, add rotation runbook to ops/runbooks/.
```

**Field meanings:**

- **STATUS** — `Complete` / `Needs Iteration` / `Blocked` / `Escalate`
- **CONFIDENCE** — `High` / `Medium` / `Low` (Low is valuable signal, not failure)
- **STRONGEST OBJECTION** — the best argument *against* the recommendation; engage it
- **FALSIFIER** — the empirical condition that would invalidate the recommendation in production

Low confidence from a high-complexity expert is an important signal — it means the expert
found genuine ambiguity. Do not dismiss it as hedging.

## 6. Common Mistakes

**Over-accepting triage.** The Manager may Moderate-tier a task you consider trivial. Push
back. "Just fix the import ordering" is a valid override.

**Ignoring STRONGEST OBJECTION.** It's not boilerplate. The Manager surfaces these for a
reason — it's the best-known counterargument. If you're about to ship, read it.

**Expecting instant results.** Moderate tasks run parallel sub-agents and synthesize. This
takes minutes. The wall-clock overhead is real and intentional — parallel scrutiny is the
point. If you need a fast answer, ask directly (no `/oj:cycle`).

**Treating FALSIFIER as theoretical.** If a FALSIFIER matches your production conditions,
act on it before shipping. That's the verification step the reviewer built for you.

## 7. Advanced: Backlog Sprint

If your project has a `.codex/BACKLOG.md` with prioritized items:

```
/oj:run-task
```

The Manager picks the highest-priority incomplete item, triages it, delegates to experts,
enforces peer review, and marks it done. Chain multiple invocations to work through a sprint.

Format items in `BACKLOG.md` as:

```markdown
## BL-001 — Add rate limiting to /api/v1/submit
Status: todo
Priority: high
Description: ...
```

## 8. Next Steps

- [WHY.md](../WHY.md) — why OpenJunto exists, honest tradeoffs, the rate-limiting example
- [CONDUCTOR.md](../CONDUCTOR.md) — full manager protocol (triage rules, execution models,
  handback format, quality gates, circuit breakers)
- [`agents/index.md`](../agents/index.md) — expert roster with engagement triggers and
  default models
- [reference/worked-examples.md](../reference/worked-examples.md) — end-to-end examples
  for all three tiers
