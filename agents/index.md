# OpenJunto Expert Agent Coordination System — Index

Central reference for the expert roster, selection guide, and profile structure.

> **Codex note**: Each expert listed here also materializes as a native Codex agent definition at `${PLUGIN_ROOT}/.codex/agents/<role>.toml` (emitted in step-03). The `agents/*.md` profile files remain the human-readable source of truth. These `.toml` definitions are installed into `~/.codex/agents/` by `bootstrap.sh` — Codex does NOT auto-discover plugin-bundled agent definitions. The SubagentStart hook (`oj-helper inject-profile`) is the primary, always-available injection path; native agent definitions are an enhancement bootstrapped separately.

---

## 1. Overview

The OpenJunto coordination system provides **16 expert AI agent personas** representing specialized stakeholder perspectives. These are AI agents, not human consultants — they provide consistent, profile-driven guidance without persistent memory or real-world relationships. Recommendations may require validation against actual organizational constraints.

**Purpose of this file**: Select the right expert(s) for a given task. See the Expert Selection Guide (Section 3) for problem-type → expert-team mappings.

---

## 2. Quick Reference

### Mandatory Stakeholders (All Tiers)

Always include both:

| Stakeholder Perspective | File | Primary Purpose | Tie-Breaker Authority |
|---|---|---|---|
| Senior Distinguished Engineer | senior-distinguished-engineer.md | Technical strategy, architecture, risk | Technical decisions |
| Senior Product Manager | senior-product-manager.md | Business alignment, prioritization, scope | Business priorities |

**Tie-breaker protocol**: Technical deadlock → Distinguished Engineer decides. Business priority deadlock → Product Manager decides. Mixed deadlock → escalate to user with both positions documented.

### Domain Experts (14)

| # | Expert | File | Primary Purpose | Engagement Trigger |
|---|--------|------|----------------|-------------------|
| 3 | Senior Security Engineer | senior-security-engineer.md | Security, compliance, threat modeling | Security/compliance signals; **veto authority** on releases with critical vulnerabilities |
| 4 | Senior Data Architect | senior-data-architect.md | Data modeling, pipelines, warehousing | Data modeling, pipeline design, warehouse architecture |
| 5 | Senior Solutions Architect | senior-solutions-architect.md | System integration, API design | Cross-system integration, API contracts, service boundaries |
| 6 | Senior DevOps Engineer | senior-devops-engineer.md | Infrastructure, CI/CD, observability | Infrastructure changes, CI/CD pipeline design, deployment strategy |
| 7 | Senior Data Scientist | senior-data-scientist.md | Statistics, experimentation, ML analysis | Experiment design, A/B testing, statistical validity, metric selection |
| 8 | Senior ML Engineer | senior-ml-engineer.md | ML systems, MLOps, model serving | ML infrastructure, model lifecycle, serving architecture, MLOps |
| 9 | Senior Enterprise Architect | senior-enterprise-architect.md | Technology strategy, standards, governance | Technology standards, governance, org-wide architectural impact |
| 10 | Senior Business Analyst | senior-business-analyst.md | Requirements, process modeling | Requirements definition, process design, edge case analysis |
| 11 | Senior Technical Writer | senior-technical-writer.md | Documentation, content strategy | Documentation strategy, user-facing content, API docs |
| 12 | Senior Engineering Consultant | senior-engineering-consultant.md | Process improvement, team effectiveness | Process inefficiencies, team friction, engineering effectiveness |
| 13 | Senior Executive Leadership Coach | senior-executive-leadership-coach.md | Leadership, organizational dynamics | Leadership challenges, organizational dysfunction, people dynamics |
| 14 | Senior Test Engineer | senior-test-engineer.md | Test strategy, automation, quality engineering | Test strategy, automation architecture, quality gates, coverage gaps |
| 15 | Senior Site Reliability Engineer | senior-site-reliability-engineer.md | SLOs, error budgets, incident management | SLO targets, reliability concerns, incident response, production toil |
| 16 | Senior Software Engineer | senior-software-engineer.md | Production code, implementation excellence | Code implementation, refactoring, code review, testing approach |

**Domain overlap notes**:
- **Security** is cross-cutting across all domains; veto authority is unique to this role
- **Architects**: Data Architect → data systems and pipelines; Solutions Architect → cross-system integration and API contracts; Enterprise Architect → org-wide standards and technology strategy
- **Engineers**: DevOps → CI/CD and infrastructure; ML Engineer → model lifecycle and serving; SRE → production reliability and SLOs; Software Engineer → code implementation and review

---

## 3. Expert Selection Guide

Map problem type to expert team. The cross-cutting reviewer is **always** from a different domain than the primary expert — same-domain review creates echo chambers with shared blind spots.

| Problem Type | Primary Expert | Supporting Experts | Cross-Cutting Reviewer |
|---|---|---|---|
| Architecture decisions | Distinguished Engineer | Solutions Architect, DevOps Engineer | Security Engineer |
| Security concerns | Security Engineer | Distinguished Engineer, Solutions Architect | Solutions Architect |
| Data system design | Data Architect | Distinguished Engineer, Security Engineer | Security Engineer |
| API / integration design | Solutions Architect | Distinguished Engineer, DevOps Engineer | Security Engineer |
| CI/CD and infrastructure | DevOps Engineer | Solutions Architect, SRE | Distinguished Engineer |
| Experiment design / A/B testing | Data Scientist | Product Manager, Data Architect | Distinguished Engineer |
| ML system design | ML Engineer | Data Architect, DevOps Engineer | SRE |
| Technology governance | Enterprise Architect | Distinguished Engineer, Engineering Consultant | Security Engineer |
| Requirements and process | Business Analyst | Product Manager, Engineering Consultant | Distinguished Engineer |
| Documentation strategy | Technical Writer | Business Analyst, Engineering Consultant | Test Engineer |
| Team / process improvement | Engineering Consultant | Executive Leadership Coach, Business Analyst | Distinguished Engineer |
| Leadership / org dynamics | Executive Leadership Coach | Engineering Consultant, Product Manager | Business Analyst |
| Test strategy / quality | Test Engineer | Software Engineer, DevOps Engineer | Distinguished Engineer |
| Reliability / SLO design | SRE | DevOps Engineer, Distinguished Engineer | Security Engineer |
| Production code / implementation | Software Engineer | Test Engineer, Solutions Architect | Security Engineer |
| Product strategy / prioritization | Product Manager | Distinguished Engineer, Business Analyst | Engineering Consultant |

**Cross-cutting review principle**: The reviewer is always from a different domain to surface blind spots that same-domain review would miss:
- Security reviewing architecture → surfaces trust boundaries and hidden attack surface
- SRE reviewing data pipelines → surfaces operational toil and runbook gaps
- Test Engineer reviewing product features → surfaces testability gaps before implementation
- Distinguished Engineer reviewing process or team concerns → surfaces technical debt implications

---

## 4. Stakeholder Engagement by Execution Model

| Execution Model | Stakeholder Engagement | Profile Type |
|---|---|---|
| Simple (inline) | Manager applies all stakeholder lenses directly | Compact profiles (`${PLUGIN_ROOT}/agents/*-compact.md`) |
| Moderate (Consult primitive) | Stakeholder agents spawned sequentially; synthesis gate before implementation | Full profiles (native agent definitions or hook-injected) |
| Complex (Convene primitive) | Parallel stakeholder agents via Convene primitive; deputy coordinator manages synthesis | Full profiles (native agent definitions or hook-injected) |

> For tier workflows, pre-mortem gate, and adversarial review protocol: `${PLUGIN_ROOT}/reference/workflow-stages.md`
> For stakeholder mapping by domain and escalation guard: `${PLUGIN_ROOT}/reference/stakeholder-guide.md`

---

## 5. Profile Structure

Every full expert profile contains these 16 sections:

**Identity and Scope**
1. Role Identity
2. Core Expertise
3. Key Responsibilities
4. Decision-Making Authority

**Collaboration**
5. Collaboration Style
6. Inter-Expert Collaboration
7. Tier-Specific Behavior

**Quality**
8. Quality Standards
9. Communication Patterns
10. Red Flags You Watch For

**Boundaries and Patterns**
11. Limitations & Blind Spots
12. Key Questions You Ask
13. Common Patterns You Recommend

**Engagement Rules**
14. When NOT to Engage
15. Engagement Triggers
16. Success Indicators

The shared context inherited by all 16 sections is in `${PLUGIN_ROOT}/agents/_preamble.md`.

---

## 6. Compact Profiles

Compact profiles are token-optimized variants for Simple tier inline perspective rotation.

**When to use**: Simple tier — manager reads compact profiles inline to apply each stakeholder lens without spawning sub-agents.

**When NOT to use**: Moderate or Complex tier — use full profiles (native agent definitions or hook-injected). The full profile's §6 Inter-Expert Collaboration, §7 Tier-Specific Behavior, and §8 Quality Standards are required for those tiers.

**Size**: ~30 lines, <2KB each vs. ~10KB for full profiles — approximately 80% token reduction.

**Location**: `${PLUGIN_ROOT}/agents/*-compact.md` (flat layout — no nested `agents/compact/` subdirectory)

### What Compact Profiles Retain

Each compact profile retains 7 elements:

1. **Role identity** — 1 sentence, bold title
2. **Core expertise** — bullet list, 4-6 items
3. **Decision authority** — bullet list, 3-4 items
4. **Red flags** — bullet list, 4-6 items — **preserves active language** from the full profile (active verbs: probe, trace, hunt, verify, challenge, test)
5. **Adversarial behaviors** — 2-3 bullets from "When Supporting" in the full profile — ensures adversarial review capability is retained in compact form
6. **Handback format** — Simple tier compressed 5-line format
7. **Reference to full profile** — e.g., `Full profile: ${PLUGIN_ROOT}/agents/senior-software-engineer.md`

### What Compact Profiles Omit

Omits: §6 Inter-Expert Collaboration, §7 Tier-Specific Behavior, §8 Quality Standards, §9 Communication Patterns, §11 Limitations & Blind Spots, §12 Key Questions You Ask, §13 Common Patterns You Recommend, §14 When NOT to Engage, §15 Engagement Triggers, §16 Success Indicators.

These sections are available in the full profile when needed for Moderate/Complex tier engagements.

---

## 7. Maintenance

### When to Update

Update expert profiles based on:
- Retrospective findings from Complex tier engagements
- Engagement trigger overlap or gaps discovered in practice
- Feedback on expert effectiveness from users
- Recurring question or solution patterns not captured in current profiles

### How to Update

1. Update the full profile: `${PLUGIN_ROOT}/agents/[profile].md`
2. **Also update the compact variant**: `${PLUGIN_ROOT}/agents/[profile]-compact.md`
3. Verify the 16-section structure is maintained
4. Ensure red flags retain active language (active verbs: probe, trace, hunt, verify, challenge, test)
5. Ensure adversarial behaviors are preserved in the compact variant

### When NOT to Update

Do not update profiles for: one-time errors, common sense, duplicate guidance already in `${PLUGIN_ROOT}/agents/_preamble.md` or `${PLUGIN_ROOT}/CONDUCTOR.md`, or communication style preferences. Most session-specific lessons do not need persisting — profiles contain durable patterns, not per-session corrections.

### Index Updates

Update this file when:
- A new expert profile is added to the roster
- An expert's engagement trigger or primary purpose changes significantly
- The Expert Selection Guide needs new problem-type mappings
- An expert's cross-cutting reviewer assignment changes based on retrospective findings
