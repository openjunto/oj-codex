# Failure Protocol

Sub-agent failure handling for the OpenJunto task lifecycle. The happy path (successful Codex subagent spawn) requires no reference to this file. Load it when a subagent spawn fails or returns an error status.

---

## 3-Step Protocol

### Step 1: Retry with Variations

Attempt up to 5 retry strategies before escalating. Try each in order:

| Strategy | Action |
|----------|--------|
| **Exact retry** | Resubmit the original spawn prompt unchanged; transient failures often self-resolve |
| **Alternate working directory** | Spawn with a different `workdir` if the failure may be path-related |
| **Background mode** | If foreground spawn timed out, retry as a background invocation |
| **Simplified prompt** | Strip non-essential context; reduce prompt length; isolate the core task |
| **Shell subagent** | Fall back to a shell-based subagent executing the task via CLI tools directly |

Log each attempt: which strategy, what changed, what the result was.

### Step 2: Document Failure Details

After exhausting retry strategies (or after 3 failures of the same strategy), document:

```
SUBAGENT FAILURE:
- Error message: [exact error text]
- Subagent profile attempted: [profile filename]
- Variations tried: [list of strategies from Step 1]
- Subagent types tried: [e.g., standard, shell]
- Task context: [brief description of what the subagent was asked to do]
```

### Step 3: Escalate to User

Present the failure documentation and offer four options:

| Option | Description |
|--------|-------------|
| **Fix environment** | User resolves the underlying issue (permission, config, dependency) and retries |
| **Supervised delegation** | User monitors the next spawn attempt in real time |
| **Emergency direct execution** | Manager performs the task directly, under the constraints below |
| **Abort** | Work is not viable with current constraints; document and stop |

---

## Emergency Direct Execution Protocol

Used only when Step 3 escalation results in the user choosing "Emergency direct execution." This is an exception, not a shortcut.

**5 constraints (all must be satisfied)**:

1. **Announce clearly**: State at the start of output: "EMERGENCY DIRECT EXECUTION — subagent delegation failed after [N] attempts. Performing this step directly."
2. **Attribute work**: Label all output as manager-produced, not expert-produced. Do not present direct work as if it came from a domain expert.
3. **Retry each request**: For each sub-task, attempt the normal delegation path once more before executing directly.
4. **Time-box to 1 request**: Perform only the minimum necessary to unblock the engagement. Do not expand scope.
5. **Document in deliverables**: Note in the final deliverable that this step was performed directly, including which subagent failed and why. This is part of the quality record.

---

## Recovery Checklist

Run these three checks before each new subagent spawn attempt after a failure:

- [ ] **Profile path is correct**: Verify the `<!-- oj-expert: [profile-filename] -->` tag references an existing profile in `${PLUGIN_ROOT}/agents/`
- [ ] **Prompt is within size limits**: Long prompts with large context injections can cause silent spawn failures; trim to essentials
- [ ] **Environment is healthy**: Confirm Codex session has required permissions and no unresolved blocking errors from prior tool calls

---

## Failure Patterns and Likely Causes

| Failure Pattern | Likely Cause | First Try |
|-----------------|-------------|-----------|
| Spawn returns immediately with no output | Profile not found or malformed | Check profile path; try simplified prompt |
| Spawn times out | Prompt too large or complex | Strip context; use simplified prompt strategy |
| Spawn succeeds but returns empty handback | Profile injected but task was ambiguous | Retry with more explicit task framing |
| Spawn produces output but STATUS: Blocked | Expert needs information not in context | Provide missing context; re-spawn |
| Multiple sequential failures on same task | Fundamental framing issue | Simplify to atomic sub-task; escalate if still failing |

---

> **Design note**: This protocol exists for the exception path. When Codex subagent delegation works as expected (99% of spawns), this file is dead code. The 3-step structure prevents two common failure modes: giving up too early (Step 1 retry strategies) and continuing silently past unrecoverable failures (Step 3 escalation).
