# Dev Mode

Optional developer workflow for active OpenJunto contributors. Inactive for 99% of users — load this file only when `OJ_DEVMODE=1` is set.

---

## Activation

Set the environment variable before starting a Codex session:

```bash
export OJ_DEVMODE=1
```

Legacy fallback accepted for one release: `JUNTO_DEVMODE=1` (backward-compat alias; prefer `OJ_DEVMODE`).

**Scope**: Local development only. Not part of the OpenJunto distribution. The feedback directory is user-created and not tracked in the plugin repository.

---

## Feedback Path Convention

Dev mode feedback files are written to:

```
${CODEX_PLUGIN_DATA:-$HOME/.codex/dev}/feedback/{org}/{repo}/{timestamp}.md
```

The `oj-helper feedback-path` command resolves this path for the current session and prints the target file location. Call it from the Phase 5 (Learn) step of the task lifecycle.

**Example**:

```bash
oj-helper feedback-path --org acme --repo api-gateway
# → /home/user/.codex/dev/feedback/acme/api-gateway/2026-06-04T14-32-00Z.md
```

Create the directory before first use:

```bash
mkdir -p "${CODEX_PLUGIN_DATA:-$HOME/.codex/dev}/feedback"
```

---

## Trigger Mechanism

Phase 5 (Learn) of the OpenJunto task lifecycle calls `oj-helper feedback-path` to obtain the write location, then the manager (or coordinator, for Complex tier) writes the feedback file.

**When to trigger**: After every Moderate or Complex engagement in dev mode. Simple tier: trigger if something unexpected occurred or a process improvement is visible.

---

## Feedback File Format

```markdown
---
date: YYYY-MM-DDTHH:MM:SSZ
item: [short task description]
tier: [Simple | Moderate | Complex]
---

## What Worked

[What went well in this engagement — stakeholder selection, triage accuracy, synthesis quality, etc.]

## What to Improve

[What could be better — friction points, missing information, stakeholder gaps, process overhead, etc.]

## OpenJunto System Suggestions

[Suggestions for the OpenJunto system itself — protocol improvements, reference file gaps, profile updates, etc.]
```

**Example**:

```markdown
---
date: 2026-06-04T14:32:00Z
item: Rate limiting for public API
tier: Moderate
---

## What Worked

Security + Operations parallel analysis surfaced the threshold tension cleanly — the TENSION entry
was correctly PROTECTED through synthesis and reached the adversarial reviewer.

## What to Improve

Phase 1 spawn prompts needed more specificity on the dry-run rollout requirement. 
The Operations subagent analysis had to be re-prompted once for implementation detail.

## OpenJunto System Suggestions

Consider adding "rollout strategy" as a standing Phase 1 question for Operations stakeholder 
when production stability risk criterion is scored.
```

---

## Promote-to-Permanent Workflow

When a dev-mode observation reveals a persistent pattern worth encoding in the OpenJunto system:

1. Note the suggestion in the feedback file's "OpenJunto System Suggestions" section
2. Open a discussion or PR against the OpenJunto spec or plugin repository
3. If the change affects the manager protocol, update `${PLUGIN_ROOT}/CONDUCTOR.md` and rerun the relevant generation steps
4. If the change affects agent profiles, update the relevant profile in `${PLUGIN_ROOT}/agents/` and regenerate compact variants

Do not edit generated files directly — changes will be overwritten on next generation. Edit the source specs or generation prompts instead.

---

## Dev Mode Anti-Patterns

- **Logging feedback in the main conversation**: Write to the feedback file, not inline. Inline logs bloat session context.
- **Skipping feedback after failures**: Failures are the most valuable signal. A failed subagent spawn or a mis-triaged task should always generate a feedback entry.
- **Editing CONDUCTOR.md directly**: CONDUCTOR.md is generated. Changes made directly will be lost on next generation.
