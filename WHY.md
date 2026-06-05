# Why OpenJunto

## The Problem

Single-agent LLMs jump to implementation. Ask Codex to add rate limiting and you
get working code — but the same coherent, confident model that wrote the implementation
also reviews it, so it affirms its own choices.

**You cannot prompt your way past this.** "Be adversarial" adds a sentence of skepticism
before the model re-confirms the same decisions. You cannot hold 16 expert perspectives in
one context window — security, operations, reliability, cost, compliance — and expect genuine
critique of each. The context dilution is real: the more roles you ask one agent to play,
the shallower each perspective gets.

**The result**: code that works on the happy path, but misses the failure modes no one
explicitly asked about.

## How OpenJunto Works

OpenJunto introduces a coordination layer between you and the model:

1. **Triage** — A Manager agent scores the request against 4 criteria and assigns a tier
   (Simple / Moderate / Complex). Proportional process weight — typo fixes stay fast;
   security changes get full scrutiny.

2. **Stakeholder analysis** — The Manager spawns domain expert sub-agents in parallel
   (Product Manager + Distinguished Engineer minimum; domain signals add Security Engineer,
   DevOps Engineer, Data Architect, ML Engineer, SRE, and others). Each expert analyzes from
   their own perspective before implementation starts.

3. **Implementation** — The lead implementer receives the consolidated findings ledger,
   including unresolved TENSION items (genuine trade-offs that cannot be collapsed into false
   consensus). A pre-mortem is mandatory: the implementer names ≥2 failure scenarios and states
   mitigations before producing the deliverable.

4. **Adversarial review** — A distinct reviewer (not the implementer) is tasked to find the
   single most important problem. Every handback requires a STRONGEST OBJECTION and a
   FALSIFIER ("Fails if [condition] because [mechanism]") — explicit forcing functions for
   critique that the model cannot paper over.

**Key mechanics that make the difference:**
- STRONGEST OBJECTION is required in every Moderate/Complex handback
- FALSIFIER names the empirical condition that breaks the recommendation in production
- Peer review uses a *different* expert than the one who implemented
- Circuit breaker auto-escalates after 3 revision cycles or 2 hours without progress
- `model_reasoning_effort` is set per expert — adversarial reviewers run at `xhigh`;
  routine analysts at `medium`

## What This Actually Looks Like

**Task**: Add rate limiting to an API endpoint.

**Without OpenJunto** — You get a working Redis-backed token bucket. What you don't get:

- *Distributed bypass*: attackers rotating IPs stay under per-IP limits trivially
- *Cache poisoning*: manipulating rate-limit counters via key collision or encoding edge cases
- *Thundering herd*: simultaneous retries on window reset spikes load at the worst moment
- *Storage cost at scale*: per-user counter cardinality at 10M users
- *Degradation behavior*: what happens when Redis is down — fail open, fail closed, or circuit break?
- *Observability*: no metrics on limit-hit rates, so you can't tune thresholds or detect abuse

**With OpenJunto** — Manager triages as Moderate (spans security + infrastructure + cost
domains). Spawns Security Engineer, DevOps Engineer, and Software Engineer in parallel.
Security flags distributed bypass vectors and poisoning edge cases; DevOps flags thundering
herd and Redis failure modes; the findings ledger carries both as protected TENSION items.
The implementer addresses all three before writing a line. The Distinguished Engineer conducts
adversarial review and must name the strongest case for a different design.

The implementation still takes a minute. But the failure modes that would have cost a week of
incident response are in the review record, not a future post-mortem.

## Honest Tradeoffs

| Tradeoff | Reality |
|---|---|
| Token cost | 2–5× more tokens than single-agent Codex |
| Wall-clock time | Moderate tasks take minutes, not seconds |
| Learning curve | ~1 week to internalize triage model and handback format |
| Process discipline | Must respond to triage questions and approve stakeholder selections |
| Over-processing risk | Simple tasks can get over-triaged; push back ("this is a typo fix, just do it") |
| Verbosity | Expert handbacks are structured and explicit — more text to read |

**When OpenJunto is NOT worth it:**
- Quick one-off questions
- Trivial fixes (typos, import ordering, variable renames)
- Rapid prototyping where correctness is not yet the goal
- Tasks where you already know exactly what you want and why

**When OpenJunto IS worth it:**
- Security reviews and auth changes
- Architectural decisions (new services, data model changes, API contracts)
- Cross-system changes (anything touching more than one team's surface)
- Compliance-sensitive work (PCI, HIPAA, SOC 2 in scope)
- Anything where "looks good to me" from a single reviewer is not good enough

Slower, but catches the thing that would have cost you a week of incident response.

## Try It

```
codex plugin marketplace add <path-to-oj-codex>
codex plugin install oj@openjunto
```

Start a new session, then:

```
/oj:cycle Review this pull request for security issues and operational readiness.
```

Point it at a real design problem and compare the output to single-agent Codex on the same
task. The STRONGEST OBJECTION field alone is usually worth the token overhead.

---

See [docs/onboarding.md](docs/onboarding.md) for a guided first 10 minutes.
