# Workflow Stages

Tactical execution detail for all three tiers. Load this file for Moderate and Complex engagements; Simple tier uses inline compact profiles only.

---

## Workflow Stages by Tier

### Simple Tier (5 Stages)

| Stage | Activity | Weight |
|-------|----------|--------|
| 1. Intake | Clarify question, confirm Simple tier, identify stakeholders | Light |
| 2. Load Perspectives | Read compact profiles for identified stakeholders from `${PLUGIN_ROOT}/agents/` (`*-compact.md` siblings) | Light |
| 3. Perspective Rotation | For each stakeholder, produce PERSPECTIVE block | Standard |
| 4. Synthesize + Execute | Merge perspectives into unified action, implement | Standard |
| 5. Verify | Check output addresses question and all perspectives considered | Light |

**Skip**: Codex subagent spawning, formal peer review, synthesis stage, retrospective.

**Checkpoint**: Fires only on mandatory escalation. If a mandatory escalation condition is present (security vulnerability, architecture change, PCI/regulatory, production stability risk, or irreversible one-way door) AND perspective rotation surfaces an unvalidated load-bearing assumption related to that condition, pause and prompt the user before executing. Named assumption required; bare uncertainty insufficient.

### Moderate Tier (7 Stages)

| Stage | Activity | Weight |
|-------|----------|--------|
| 1. Intake | Clarify scope, confirm Moderate tier, identify stakeholders | Standard |
| 2. Stakeholder Analysis | Spawn supporting stakeholder subagents in parallel for domain analysis | Standard |
| 3. Pre-Mortem | Implementing agent answers: "Imagine this shipped and failed. What went wrong?" | Standard |
| 4. Implementation | Lead agent produces deliverable informed by stakeholder analysis | Variable |
| 5. Adversarial Review | Cross-domain stakeholder reviews with adversarial framing | Standard |
| 6. Synthesis | Manager consolidates, resolves conflicts, steelmans rejected alternatives | Standard |
| 7. Deliver | Present to user, obtain feedback | Standard |

**Skip**: Full retrospective (optional quick retro if issues arose).

**Checkpoint**: When the findings ledger contains `CONFIDENCE: Low` on a named key assumption, pause at the synthesis gate and present the finding to the user before spawning the implementer. The assumption must be named explicitly — bare `CONFIDENCE: Low` without a named cause does not trigger.

### Complex Tier (9 Stages)

| Stage | Activity | Weight |
|-------|----------|--------|
| 1. Intake | Clarify scope, constraints, success criteria, identify all stakeholders | Deep |
| 2. Team Formation | Spawn coordinator subagent + stakeholder subagents (parallel Codex subagents) | Deep |
| 3. Task Planning | Coordinator creates tasks for each stakeholder perspective | Deep |
| 4. Pre-Mortem | Each stakeholder identifies failure scenarios from their domain | Deep |
| 5. Parallel Execution | Stakeholder subagents work concurrently, report handbacks to coordinator | Variable |
| 6. Adversarial Review | Cross-functional review with adversarial framing, full checklist | Deep |
| 7. Synthesis | Coordinator synthesizes via handbacks; manager consolidates for user | Deep |
| 8. User Checkpoint | Present findings, obtain explicit approval before finalizing ("Should we proceed?") | Standard |
| 9. Retrospective | What worked, what to improve, action items; team teardown | Standard |

**User Checkpoint (Stage 8)** always fires at Complex tier — Complex-tier scope is high-impact by definition. It is distinct from triage confirmation (which asks "Is the process weight right?" at intake). Cannot be skipped.

---

## Synthesis Gate

Positioned between Stakeholder Analysis and Implementation in Moderate tier. Manager synthesizes stakeholder findings before spawning the implementer to prevent information overload.

### Findings Ledger Format

Accumulates stakeholder handbacks into structured format (cap 10 items):

```
FINDING: [finding text] | SOURCE: [stakeholder role] | CONFIDENCE: [H/M/L]
TENSION: [tension text] | SOURCES: [role1, role2] | STATUS: [unresolved]
```

**TENSION items are PROTECTED** — they cannot be removed during synthesis. They are forwarded to the implementer and reviewer spawn contexts unchanged.

### Constraint Classification

| Classification | Criteria | Implementer Obligation |
|----------------|----------|------------------------|
| **Hard** | 2+ stakeholders agree OR domain authority | Must address |
| **Soft** | Single stakeholder, no corroboration | Should address; explain if deferred |
| **Context** | Background information | Informs approach; no explicit reference required |

---

## Pre-Mortem Gate

Applied to Moderate and Complex tiers. Timing: after stakeholder engagement, before the work product.

**Prompt**: "Imagine this work shipped exactly as planned, and six months later it is considered a failure. What went wrong?"

### Requirements by Tier

- **Moderate**: ≥2 distinct failure scenarios; state mitigation or accepted risk for each. Narrow-scope exception: if the work has no meaningful design choices, state this explicitly with reasoning.
- **Complex**: ≥3 distinct failure scenarios spanning different categories (technical, operational, organizational, business); state mitigation or accepted risk for each. Unmitigated high-severity risk → escalate to Manager before proceeding.

### Output Format

```
PRE-MORTEM:
1. [Failure scenario]: [Mitigated by X | Accepted risk because Y]
2. [Failure scenario]: [Mitigated by X | Accepted risk because Y]
...
```

**Example**:

```
PRE-MORTEM:
1. JWT tokens leak through logs: Mitigated by structured logging that redacts Authorization headers
2. Token expiration causes poor UX: Accepted risk — 1-hour window sufficient; refresh out of scope
3. Signature verification CPU cost exceeds capacity: Mitigated by horizontal scaling + load testing
```

---

## Adversarial Review Protocol

Applied to Moderate and Complex tiers. Reviewer's success = problems found, not agreement.

**Reviewer prompt**: "Your job is to find the single most important problem with this work. If you find none, explain specifically why this work is resistant to the failure modes you tested."

### Reviewer Responsibilities

1. **Test specific failure modes**: What breaks under load? With bad input? When dependencies fail? When assumptions change?
2. **Identify the #1 problem**: Rank by (likelihood × impact).
3. **Explain absence of problems**: State "I tested against [specific failure modes] and found no material concerns because [specific reasoning]." "Looks good" without this specificity is incomplete.
4. **Challenge high confidence**: Apply Calibration Challenge when author claims High confidence. Prompt: "What would drop this to Medium?"

### Reviewer Output Format

```
ADVERSARIAL REVIEW: [Reviewer Role]
FAILURE MODES TESTED: [List of specific failure modes probed]
#1 PROBLEM FOUND: [Description and severity, OR "None — resistant because..."]
ADDITIONAL CONCERNS: [Other issues, ranked by severity]
CONFIDENCE CALIBRATION: [For High-confidence: "Confidence would drop to Medium if..."]
VERDICT: [Accept | Accept with concerns | Revise required]
```

**Example**: `FAILURE MODES TESTED: distributed bypass, cache poisoning, thundering herd | #1 PROBLEM FOUND: None — atomic INCR prevents races, sliding window prevents thundering herd | VERDICT: Accept`

---

## Output Compression

Expert output verbosity should match the role's contribution to decision-making:

| Expert Role | Compression Level | Format |
|-------------|-------------------|--------|
| Analyst | Compressed | Finding + concern only |
| Implementer | Standard | Full handback |
| Adversarial Reviewer | Full (never compress) | Complete review format |

**Rationale**: Analysts provide input, implementers produce output, reviewers validate. The handback protocol provides full structure for implementers and reviewers, while analyst output is compressed to key findings.

---

## Deputy Coordinator Pattern

Used in Complex tier. The coordinator is a general-purpose Codex subagent managing detailed synthesis while the manager focuses on high-level decisions and user interaction.

**Coordinator responsibilities**:
- Receives the full stakeholder plan from the manager
- Creates task graph with declared dependencies (`blockedBy` pattern for analysis → implementation → review ordering)
- Fans out parallel stakeholder subagent spawns; collects handbacks
- Synthesizes stakeholder output via handback-only consolidation (peer-to-peer messaging is unavailable; all coordination flows through the coordinator)
- Enforces quality gates before relaying synthesis to manager

**Coordinator does NOT**:
- Make high-level decisions or scope changes
- Interact directly with the user
- Bypass quality gates to accelerate delivery

**Fallback (when parallel Codex subagents are unavailable)**: Complex tier degrades to a serial-Consult coordinator pattern. The manager spawns the coordinator as a single subagent briefed with the full stakeholder plan; the coordinator works through stakeholder analyses sequentially. The User Checkpoint, mandatory pre-mortem, and adversarial review steps remain unchanged.

---

## PERSPECTIVE Block Format (Simple Tier)

For each stakeholder in Simple tier perspective rotation:

```
PERSPECTIVE: [Stakeholder] ([profile].md)
LENS: [What this stakeholder examines]
ASSESSMENT: [1-2 sentence finding]
CONCERN: [Primary concern, or "None — [reason]"]
```

**No-concern shorthand** (when no material concerns found after analysis):

```
PERSPECTIVE: [Role] | NO MATERIAL CONCERNS | Tested: [failure modes]
```
