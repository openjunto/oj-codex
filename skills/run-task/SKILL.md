---
name: run-task
description: Execute a single backlog item end-to-end through the 5-phase task lifecycle
---

# $run-task

Single-item task lifecycle skill. Invoke with `$run-task` (or via `/skills` → `run-task`). Executes exactly ONE backlog item through Phases 1–5 (Discover → Triage → Execute → Deliver → Learn) and returns control to the user. **Does NOT loop** — re-entry on the next item requires a fresh user invocation of `$run-task`. For multi-item looping, use `$cycle`.

---

## Task Lifecycle Protocol

### Phase 1 — Initialize (Discover)

#### Backlog Source Detection

Run `oj-helper issue-tracker-check` in bash, then:

```
issue-tracker-check fails?                        -> BACKLOG.md mode
issue-tracker-check succeeds + project null?      -> BACKLOG.md mode
issue-tracker-check succeeds + project non-null?  -> issue tracker mode with KEY
```

#### Read Context

1. Read `.codex/CONDUCTOR.md` (project-local manager protocol).
2. Load `.codex/state/learning-index.md` (if exists) — actionable rules from prior retrospectives; inform triage, execution, and review throughout this run-task invocation.
3. Load `.codex/state/action-items.md` (if exists) — surface open/past-due items to user before proceeding.

#### Load Backlog

- **Issue tracker mode**: Run `oj-helper issue-tracker-list --project PROJECT_KEY` → parse JSON, select highest-priority unblocked item.
- **BACKLOG.md mode**: Read `.codex/BACKLOG.md`, parse priority sections (P0 → P4), select highest-priority unblocked item.

If the backlog is empty or all items are blocked, prompt the user for input.

---

### Phase 2 — Classify (Triage)

Perform two-dimensional triage on the selected item:

**A. Execution Model** — Apply the 4-criterion checklist per `${PLUGIN_ROOT}/reference/workflow-stages.md` and CONDUCTOR.md:

1. **Scope**: single-concern change vs. multi-system impact?
2. **Risk**: reversible vs. production-stability / security / regulatory / irreversible?
3. **Ambiguity**: clear requirements vs. open design space?
4. **Stakeholders**: zero/one domain vs. multiple competing interests?

Score → Simple / Moderate / Complex. Mandatory escalation triggers: security, regulatory, production-stability, or irreversible/one-way-door actions always escalate to at least Moderate.

**B. Stakeholder Identification** — Mandatory pair (Product + Tech), plus domain signal matching per `${PLUGIN_ROOT}/reference/stakeholder-guide.md`.

**C. Calibration Check** — Consult `.codex/evolution/measurements/triage-calibration.json` (if exists). Note consistent overrides for similar tasks.

**D. Confirm Tier** — Present triage result via `AskUserQuestion`. Offer Simple / Moderate / Complex with recommended tier marked and one-line description per tier. Note if calibration informed the recommendation. Use user's selection if they override.

- **Issue tracker mode only**: Transition ticket to "In Progress" via `oj-helper issue-tracker-transition KEY --status "In Progress"`. If transition fails, log failure and continue.

---

### Phase 3 — Plan & Execute

#### Plan Stakeholder Engagement

Before spawning any agents, declare the engagement plan:

1. Identify stakeholders from Phase 2B.
2. Map to agent profiles via `${PLUGIN_ROOT}/agents/index.md` and `${PLUGIN_ROOT}/reference/stakeholder-guide.md`.
3. Plan by execution model (Simple: inline, Moderate: 3-phase Codex subagent, Complex: parallel Codex subagents or deputy fan-out).
4. State: stakeholder, agent assignment (or "inline"), expected deliverable.

#### Execute

**Simple — Inline Perspective Rotation**

Apply the PERSPECTIVE block pattern for each relevant angle:

```
PERSPECTIVE: <Role>
<concise analysis from that role's viewpoint>
END PERSPECTIVE
```

Rotate through: at minimum Product and Tech. Add domain-specific perspectives when signals indicate.

**Moderate — 3-Phase Codex Subagent Engagement**

> **Model directive**: Set `model` on every Codex subagent spawn per CONDUCTOR.md § Model Selection.
> Phase-1 analysts → `gpt-5.3-codex` (`gpt-5.4-mini` for bounded/docs-only tasks).
> Phase-2 lead → `gpt-5.3-codex`; escalate to `gpt-5.5` for high-risk or unresolved TENSION.
> Phase-3 adversarial reviewer → always `gpt-5.5` (effort: xhigh).
> See CONDUCTOR.md § Model Selection for the per-role default fallback table.

- **Phase 1 — Analyst spawns**: Spawn stakeholder analysts in parallel as Codex subagents (defined in `${PLUGIN_ROOT}/.codex/agents/<role>.toml`; spawned via /agent or auto-orchestration). Each analyst receives the item description, its role context from `${PLUGIN_ROOT}/agents/index.md`, and the compact profile from `${PLUGIN_ROOT}/agents/<role>-compact.md`.
- **Phase 2 — Lead synthesis**: Spawn lead Codex subagent. Brief with all Phase-1 outputs, the engagement plan, and full item context. Lead produces the work product.
- **Phase 3 — Adversarial review**: Spawn adversarial reviewer Codex subagent (`model: gpt-5.5`, effort: xhigh). Reviewer attempts to refute the Phase-2 output; surfaces blocking issues or clears for delivery.

**Complex — Parallel Codex Subagents or Deputy Fan-Out**

> **Model directive**: Set `model` on every Codex subagent spawn per CONDUCTOR.md § Model Selection.
> Lead → `gpt-5.5` (effort: reasoning). Adversarial reviewer → always `gpt-5.5` (effort: xhigh).
> Deputy coordinator → `gpt-5.3-codex`; escalate to `gpt-5.5` if it carries synthesis weight.
> Stakeholder analysts → `gpt-5.3-codex` (`gpt-5.4-mini` for bounded/docs-only tasks).
> Domain specialists on a domain trigger → `gpt-5.3-codex`; escalate to `gpt-5.5` when the domain is the decisive risk.
> See CONDUCTOR.md § Model Selection for the per-role default fallback table.

**Capability probe — run after tier confirmation confirms Complex**:

```bash
oj-helper agent-teams-check
```

Parse `.available` from JSON stdout. The probe always exits 0; the branch selector reads `.available`, not the exit code.

- **`.available == true`**: Convene the full stakeholder team as parallel Codex subagents (Codex waits for all and returns a consolidated response). Each subagent receives role context and compact profile from `${PLUGIN_ROOT}/agents/<role>-compact.md`. Run parallel stakeholder analyses, pre-mortem, and adversarial review. Subagents complete via handback; no teardown step needed.
- **`.available == false`**: Follow the deputy-coordinator parallel-Consult fan-out (Axiom 8 fallback). Spawn ONE general-purpose deputy coordinator Codex subagent, brief it with the full stakeholder plan. Deputy fans out parallel Codex subagent Consults to stakeholder analysts and synthesizes via handback protocol. **Synthesis is handback-only — inter-agent messaging is not available on Codex.**

**Runtime backstop**: `agent-teams-check` inspects only the environment variable; an environment where the variable is set but parallel subagent auto-orchestration is constrained at runtime (concurrency cap, enterprise policy) will steer onto the full-parallel branch incorrectly. If the full-parallel branch is taken and any parallel-subagent call fails with a capacity or availability error, **do NOT abort the task** — fall through immediately to the deputy-coordinator sequential-Consult fan-out (handback-only synthesis). The runtime signal is authoritative over the probe.

**Mandatory regardless of branch**: User Checkpoint before Phase 4, pre-mortem, and adversarial review (`gpt-5.5`, effort: xhigh). The User Checkpoint promised at triage MUST still fire before Phase 4 begins.

---

### Phase 4 — Deliver

#### Test

Validate with tests (balanced pyramid: unit > integration > e2e). Run existing tests to confirm no regressions.

#### Commit

Create atomic commits with clear messages. **No "Co-Authored-By" lines or AI attribution.**

**Verification gate for this run-task invocation**: After committing, run `git status`. If uncommitted changes remain (modified or untracked), stage and commit with a descriptive message. One verification pass only. A dirty tree after the verification pass stops this run-task invocation and surfaces the issue to the user.

#### Update Backlog

- **Issue tracker mode**:
  - Transition ticket to "Done" via `oj-helper issue-tracker-transition KEY --status "Done"`. If fails, note ticket key and desired status for manual resolution and continue.
  - Add completion comment: `oj-helper issue-tracker-comment KEY --body "Completed: [summary]"`
  - Create new tickets for discovered work: `oj-helper issue-tracker-create --summary "..." --description "..."`
- **BACKLOG.md mode**:
  - Mark completed items.
  - Add discovered work.
  - Update `.codex/BACKLOG.md`.

---

### Phase 5 — Learn

#### Retrospective

Brief retrospective on what worked and what to improve during this run-task invocation. For Complex tier, write to `.codex/archive/retros/` using `${PLUGIN_ROOT}/templates/retrospective.md`.

#### Persist Operational Learnings

1. **Record triage calibration entry**: Write a new entry to `.codex/evolution/measurements/triage-calibration.json`. Create as single-entry array if file absent.
2. **Extract actionable learnings**: If the retrospective identifies a recurring pattern, add a RULE entry to `.codex/state/learning-index.md`. Create with initial category header if absent. Only persist specific, actionable, likely-to-recur learnings.
3. **Update action items**: Add new action items to `.codex/state/action-items.md` with source, owner, status (Open), and target date. Mark completed items Closed. Create with table header if absent.

#### Dev-Mode Feedback

Run `oj-helper feedback-path` in bash. If output is empty (dev mode off), skip. Otherwise the output is the file path — write one feedback file for this run-task invocation (each run-task invocation produces exactly one new file):

```markdown
---
date: YYYY-MM-DD
item: KEY-NNN or BACK-XXX
tier: Simple|Moderate|Complex
---
### What Worked
- [bullet points]
### What to Improve
- [bullet points]
### OpenJunto System Suggestions
- [specific suggestions for OpenJunto profiles, skills, manager protocol file, etc.]
```

#### Artifacts

Store design documents, ADRs, and analysis artifacts in `.codex/artifacts/`.

#### Notify

Tell the user this run-task invocation is complete, summarize what was done, and suggest `/clear` if context is large. If the user wants to process the next backlog item, they should invoke `$run-task` again (or use `$cycle` for multi-item automation).

---

## Constraints

- **Exactly one backlog item per invocation** — `$run-task` does NOT loop. One Phase-1-through-Phase-5 pass per user invocation. Re-entry on the next item requires a fresh user invocation of `$run-task`. For multi-item looping, use `$cycle`.
- **Atomic commits**: small, focused commits; one item commits independently.
- **Do not proceed past blocking review**: if Phase-3 adversarial review surfaces blocking issues, stop the run-task invocation and surface to the user.
- **Stop and ask when blocked or uncertain**: do not guess; surface uncertainty to the user.
- **Issue tracker failures are non-blocking**: complete work, note ticket key and desired status for manual resolution.

---

## Cross-References

> - Agent profiles: `${PLUGIN_ROOT}/agents/index.md`
> - Compact profiles: `${PLUGIN_ROOT}/agents/*-compact.md` (flat layout)
> - Stakeholder guide: `${PLUGIN_ROOT}/reference/stakeholder-guide.md`
> - Workflow stages: `${PLUGIN_ROOT}/reference/workflow-stages.md`
> - Manager protocol: `.codex/CONDUCTOR.md`
> - Model selection: CONDUCTOR.md § Model Selection
> - Multi-item loop: `$cycle`
