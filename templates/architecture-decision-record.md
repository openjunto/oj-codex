# ADR-[NUMBER]: [TITLE]

<!-- Copy this template to docs/adr/ or .codex/adr/ and rename to ADR-NNN-short-title.md.
     Fill in each section. Placeholder text is in {BRACES} or [BRACKETS]. -->

**Status**: Proposed | Accepted | Deprecated | Superseded by ADR-{XXX}

**Date**: {YYYY-MM-DD}

---

## Context

<!-- What situation, problem, or force motivates this decision?
     Include relevant background — constraints, prior decisions, external pressures. -->

{Describe the situation that makes this decision necessary. Include what would happen if no
decision were made.}

---

## Decision Drivers

- {Factor that influenced the decision — e.g., performance requirement, team expertise}
- {Factor — e.g., operational complexity budget}
- {Factor — e.g., reversibility preference}
- {Factor — e.g., cost ceiling}

---

## Considered Options

<!-- List at least 3 alternatives, including "do nothing" where applicable. -->

1. **{Option A}** — {Brief description, 1-2 sentences}
2. **{Option B}** — {Brief description, 1-2 sentences}
3. **{Option C}** — {Brief description, 1-2 sentences}

---

## Decision

**Chosen option**: {Option name}

**Rationale**: {Why this option was selected over the alternatives, mapped to the decision
drivers above.}

---

## Reversibility Assessment

<!-- This section is critical for one-way door decisions. Be honest about difficulty of reversal. -->

| Dimension | Assessment |
|-----------|------------|
| **Reversibility level** | Easy / Moderate / Difficult / Irreversible |
| **Reversal cost if wrong** | {Estimated effort / cost to undo or migrate away} |
| **One-way door?** | Yes / No |

> **If "Yes"**: This is a one-way door decision. Apply additional scrutiny before accepting.
> Confirm that alternatives were genuinely evaluated and that the irreversibility is
> understood by all decision-makers.

---

## Consequences

### Positive

- {Benefit — what this enables or improves}
- {Benefit}
- {Benefit}

### Negative

- {Tradeoff — what this constrains or sacrifices}
- {Tradeoff}

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| {Risk description} | H / M / L | H / M / L | {Mitigation approach} |
| {Risk description} | H / M / L | H / M / L | {Mitigation approach} |

---

## Validation

**Success metrics**:
- {Observable condition that would confirm the decision was correct}
- {Metric or threshold — e.g., p95 latency < 200 ms after 30 days}

**Review date**: {YYYY-MM-DD} — revisit if circumstances change before then.

---

## References

- {Related ADR, document, or external resource}
- {Link or title}

---

**Author**: {Name} | **Reviewers**: {Names} | **Approved by**: {Name or "Pending"}

<!-- CODEX PLUGIN: This template is deployed via ${PLUGIN_ROOT}/templates/architecture-decision-record.md.
     Project copies live in ~/.codex/ or a project-local .codex/adr/ directory. -->
