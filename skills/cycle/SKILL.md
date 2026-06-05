---
name: cycle
description: Execute the autonomous backlog cycle — triage, delegate, review, test, commit, retrospect
---

# $cycle

Autonomous backlog cycle skill. Invoke with `$cycle` (or via `/skills` → `cycle`). Loops over the highest-priority unblocked backlog items — executing a full Phase 1 → Phase 5 task-lifecycle pass per item, committing atomically, then re-entering Phase 1 — until a budget/safety gate trips.

**Asymmetry directive**: The `$cycle` skill LOOPS over multiple items per invocation under the budget/safety-gate stop. The `$run-task` skill does NOT loop — it executes exactly one item per invocation. Multi-item loop language belongs only here; single-invocation language belongs only in `$run-task`.

---

## Cycle Protocol

### Step 1 — Read Context

1. Read `.codex/CONDUCTOR.md` (project-local manager protocol). This is the primary context source; if absent, warn and continue.
2. Load `.codex/state/learning-index.md` (if exists) — actionable rules from prior retrospectives; apply throughout triage, execution, and review.
3. Load `.codex/state/action-items.md` (if exists) — surface any open/past-due items to the user before the first iteration.

### Step 2 — Backlog Source Detection

Run `oj-helper issue-tracker-check` in bash, then:

```
issue-tracker-check fails?                        -> BACKLOG.md mode
issue-tracker-check succeeds + project null?      -> BACKLOG.md mode
issue-tracker-check succeeds + project non-null?  -> issue tracker mode with KEY
```

### Step 3 — Load Backlog and Select Item

- **Issue tracker mode**: `oj-helper issue-tracker-list --project PROJECT_KEY` → parse JSON, select highest-priority unblocked item.
- **BACKLOG.md mode**: Read `.codex/BACKLOG.md`, parse priority sections (P0 → P4), select highest-priority unblocked item.

If the backlog is empty or all items are blocked, notify the user and stop.

### Step 4 — Two-Dimensional Triage

Perform two-dimensional triage on the selected item:

**A. Execution Model** — Apply the 4-criterion checklist per `${PLUGIN_ROOT}/reference/workflow-stages.md` and CONDUCTOR.md:

1. **Scope**: single-concern change vs. multi-system impact?
2. **Risk**: reversible vs. production-stability / security / regulatory / irreversible?
3. **Ambiguity**: clear requirements vs. open design space?
4. **Stakeholders**: zero/one domain vs. multiple competing interests?

Score → Simple / Moderate / Complex. Check mandatory escalation triggers: security, regulatory, production-stability, or irreversible/one-way-door actions always escalate to at least Moderate.

**B. Stakeholder Identification** — Mandatory pair (Product + Tech), plus domain signal matching per `${PLUGIN_ROOT}/reference/stakeholder-guide.md`.

**C. Calibration Check** — Consult `.codex/evolution/measurements/triage-calibration.json` (if exists). Note consistent overrides for similar tasks.

**D. Escalation Guard** — Present triage result via `AskUserQuestion`. Offer Simple / Moderate / Complex with recommended tier marked. User selection overrides recommendation.

### Step 5 — Plan Stakeholder Engagement

Before spawning any agents, declare the engagement plan:

1. Identify stakeholders from Step 4B.
2. Map to agent profiles via `${PLUGIN_ROOT}/agents/index.md` and `${PLUGIN_ROOT}/reference/stakeholder-guide.md`.
3. Plan by execution model (see Step 6).
4. State: stakeholder, agent assignment (or "inline"), expected deliverable.

### Step 6 — Execute

Execute per the classified tier:

#### Simple — Inline Perspective Rotation

Perform inline analysis. Apply the PERSPECTIVE block pattern for each relevant angle:

```
PERSPECTIVE: <Role>
<concise analysis from that role's viewpoint>
END PERSPECTIVE
```

Rotate through: at minimum Product and Tech. Add domain-specific perspectives when signals indicate (e.g., Security, Data, UX).

#### Moderate — 3-Phase Codex Subagent Engagement

> **Model directive**: Set `model` on every Codex subagent spawn per CONDUCTOR.md § Model Selection.
> Phase-1 analysts → `gpt-5.3-codex` (`gpt-5.4-mini` for bounded/docs-only tasks).
> Phase-2 lead → `gpt-5.3-codex`; escalate to `gpt-5.5` for high-risk or unresolved TENSION.
> Phase-3 adversarial reviewer → always `gpt-5.5` (effort: xhigh).
> See CONDUCTOR.md § Model Selection for the per-role default fallback table.

- **Phase 1 — Analyst spawns**: Spawn stakeholder analysts in parallel as Codex subagents (defined in `${PLUGIN_ROOT}/.codex/agents/<role>.toml`; spawned via /agent or auto-orchestration). Each analyst receives the item description, its role context from `${PLUGIN_ROOT}/agents/index.md`, and the compact profile from `${PLUGIN_ROOT}/agents/<role>-compact.md`.
- **Phase 2 — Lead synthesis**: Spawn lead Codex subagent. Brief with all Phase-1 outputs, engagement plan, and full item context. Lead produces the work product.
- **Phase 3 — Adversarial review**: Spawn adversarial reviewer Codex subagent (`model: gpt-5.5`, effort: xhigh). Reviewer attempts to refute the Phase-2 output; surfaces blocking issues or clears for delivery.

#### Complex — Parallel Team via Convene Primitive

> **Model directive**: Set `model` on every Codex subagent spawn per CONDUCTOR.md § Model Selection.
> Lead → `gpt-5.5` (effort: reasoning). Adversarial reviewer → always `gpt-5.5` (effort: xhigh).
> Deputy coordinator → `gpt-5.3-codex`; escalate to `gpt-5.5` if it carries synthesis weight.
> Stakeholder analysts → `gpt-5.3-codex` (`gpt-5.4-mini` for bounded/docs-only tasks).
> Domain specialists on a domain trigger → `gpt-5.3-codex`; escalate to `gpt-5.5` when the domain is the decisive risk.
> See CONDUCTOR.md § Model Selection for the per-role default fallback table.

**Capability probe — run before spawning the parallel team**:

```bash
oj-helper agent-teams-check
```

Parse `.available` from JSON stdout. The probe always exits 0; the branch selector reads `.available`, not the exit code.

- **`.available == true`**: Convene the full stakeholder team as parallel Codex subagents (Codex waits for all and returns a consolidated response). Each subagent receives role context and compact profile. Run parallel stakeholder analyses, pre-mortem, and adversarial review. Subagents complete via handback; no teardown step needed.
- **`.available == false`**: Follow the deputy-coordinator parallel-Consult fan-out (Axiom 8 fallback). Spawn ONE general-purpose deputy coordinator Codex subagent, brief it with the full stakeholder plan. Deputy fans out parallel Codex subagent Consults to stakeholder analysts and synthesizes via handback protocol. **Synthesis is handback-only — inter-agent messaging is not available on Codex.**

**Runtime backstop**: `agent-teams-check` inspects only the environment variable; an environment where the variable is set but parallel subagent auto-orchestration is constrained at runtime (concurrency cap, enterprise policy) will steer onto the full-parallel branch incorrectly. If the full-parallel branch is taken and any parallel-subagent call fails with a capacity or availability error, **do NOT abort the loop iteration** — fall through immediately to the deputy-coordinator sequential-Consult fan-out (handback-only synthesis). The runtime signal is authoritative over the probe.

**Mandatory regardless of branch**: User Checkpoint before commit, pre-mortem, and adversarial review (`gpt-5.5`, effort: xhigh).

### Step 7 — Deliver

#### Test

Validate with tests (balanced pyramid: unit > integration > e2e). Run existing tests to confirm no regressions.

#### Commit

Create atomic commits with clear messages. **No "Co-Authored-By" lines or AI attribution.**

#### Step 7a — Clean-Tree Gate

After committing, run `git status`. If uncommitted changes remain (modified or untracked), stage and commit with a descriptive message. One verification pass only.

**The loop MUST NOT advance to the next item until this gate shows a clean working tree.** A dirty tree stops the loop and surfaces control to the user.

#### Update Backlog

- **Issue tracker mode**: Transition ticket to "Done" via `oj-helper issue-tracker-transition KEY --status "Done"`. Add completion comment. Create tickets for discovered work. If transition fails, log and continue.
- **BACKLOG.md mode**: Mark completed items, add discovered work, update `.codex/BACKLOG.md`.

### Step 8 — Retrospective

Brief retrospective on this item: what worked, what to improve. For Complex tier, write to `.codex/archive/retros/` using `${PLUGIN_ROOT}/templates/retrospective.md`.

Record triage calibration entry to `.codex/evolution/measurements/triage-calibration.json`. Extract actionable learnings to `.codex/state/learning-index.md`. Update `.codex/state/action-items.md`.

### Step 9 — Check Loop Conditions

Evaluate all budget/safety-gate stop conditions before re-entering the loop:

- **Token/context budget low** → stop and report.
- **Next selected item triages to Complex tier** → surface to user; do not auto-proceed.
- **Irreversible / one-way-door action required** (push, delete, publish, destructive migration) → surface to user.
- **User-only decision reached** → stop and ask.

If no gate trips, return to **Step 3** with the next highest-priority unblocked item.

### Step 10 — Dev-Mode Feedback

Run `oj-helper feedback-path` in bash. If output is empty (dev mode off), skip. Otherwise the output is the file path — write one feedback file per cycle invocation (summarizing ALL items processed in this run, not one file per item):

```markdown
---
date: YYYY-MM-DD
item: KEY-NNN or BACK-XXX  (comma-separated if multiple)
tier: Simple|Moderate|Complex  (highest tier reached in this run)
---
### What Worked
- [bullet points]
### What to Improve
- [bullet points]
### OpenJunto System Suggestions
- [specific suggestions for OpenJunto profiles, skills, manager protocol file, etc.]
```

### Step 11 — Notify

Tell the user the cycle run is complete. Summarize: items processed, tiers reached, commits made, any gates tripped. Suggest `/clear` if context is large.

---

## Constraints

- **Multi-item loop**: `$cycle` iterates the 5-phase lifecycle over multiple items per invocation. Each loop iteration is scoped to exactly ONE item.
- **Atomic per-item commits with clean-tree gate (Step 7a)**: The loop MUST NOT advance to the next item until Step 7a shows a clean working tree.
- **Stop on blocking review**: If Phase-3 adversarial review surfaces blocking issues, stop the loop and surface to the user.
- **Stop at budget/safety gates** (Step 9): token budget low; next item triages Complex; irreversible action required; user-only decision reached.
- **Ask when blocked**: do not guess; surface uncertainty to the user.
- **Issue tracker failures are non-blocking**: complete work, note ticket key and desired status for manual resolution.

---

## Cross-References

> - Agent profiles: `${PLUGIN_ROOT}/agents/index.md`
> - Compact profiles: `${PLUGIN_ROOT}/agents/*-compact.md` (flat layout)
> - Stakeholder guide: `${PLUGIN_ROOT}/reference/stakeholder-guide.md`
> - Workflow stages: `${PLUGIN_ROOT}/reference/workflow-stages.md`
> - Model selection: CONDUCTOR.md § Model Selection
> - Single-item lifecycle: `$run-task`
