---
name: health-check
description: Diagnose OpenJunto plugin runtime health — verify CONDUCTOR.md injection, oj-helper availability, jq dependency, plugin manifest, SubagentStart hook wiring.
---

# $health-check

Empirical runtime probe of the OpenJunto plugin install for Codex. Invoke with `$health-check` (or via `/skills` → `health-check`). Runs real `oj-helper` subprocesses, captures stdout/stderr/exit codes, and reports liveness — not file-layout structure. Distinguishes broken wiring from misconfigured environment.

---

## Health-Check Protocol

Run all five probes in order. Collect pass/fail per probe ID. Emit the final summary line after all probes complete.

---

### Probe 1 — CONDUCTOR.md Injection

**Purpose**: Verify that the CONDUCTOR.md protocol file is injected into context at session start.

**Command**:
```bash
oj-helper conductor-inject
```

**Assertions**:
- Exit code is `0`.
- Stdout is valid JSON and contains `hookSpecificOutput` key.
- `hookSpecificOutput` is non-empty (confirms CONDUCTOR.md content was loaded).
- Stderr does NOT contain the advisory string `OJ_STDERR_CONDUCTOR_MISSING` (presence of that string signals the inject hook ran but could not locate CONDUCTOR.md).

**Pass**: all assertions met.
**Fail (P1)**: exit non-zero, JSON parse fails, `hookSpecificOutput` absent or empty, or `OJ_STDERR_CONDUCTOR_MISSING` present in stderr.

---

### Probe 2 — oj-helper on PATH and Executable

**Purpose**: Verify the OpenJunto helper binary is discoverable and executable.

**Command**:
```bash
which oj-helper && test -x "$(which oj-helper)"
```

Also verify the plugin-bundled copy:
```bash
test -x "${PLUGIN_ROOT}/bin/oj-helper"
```

**Assertions**:
- `which oj-helper` exits `0` (binary on PATH).
- The resolved path is executable (`-x` test passes).
- `${PLUGIN_ROOT}/bin/oj-helper` exists and is executable.

**Pass**: all assertions met.
**Fail (P2)**: binary not on PATH, not executable, or plugin-bundled copy absent/non-executable.

---

### Probe 3 — jq Dependency

**Purpose**: Verify the `jq` JSON processor is available. Multiple OpenJunto helper subcommands pipe through `jq`; absence silently breaks JSON parsing.

**Command**:
```bash
jq --version
```

**Assertions**:
- Exit code is `0`.
- Stdout begins with `jq-` (confirms it is the real `jq` binary, not a stub).

**Pass**: both assertions met.
**Fail (P3)**: `jq` not found, exit non-zero, or stdout does not begin with `jq-`.

---

### Probe 4 — Plugin Manifest

**Purpose**: Verify the Codex plugin manifest is present and well-formed.

**File**: `.codex-plugin/plugin.json` (relative to the plugin install root, i.e., `${PLUGIN_ROOT}/.codex-plugin/plugin.json`).

**Steps**:
1. Check the file exists.
2. Parse as JSON (`jq . .codex-plugin/plugin.json`).
3. Verify required keys are present: `name`, `version`, `skills`.

**Assertions**:
- File exists.
- JSON parse exits `0` (valid JSON).
- `.name` is non-null and non-empty.
- `.version` is non-null and non-empty.
- `.skills` is a non-null array.

**Pass**: all assertions met.
**Fail (P4)**: file absent, parse fails, or any required key missing/null.

---

### Probe 5 — Hook Wiring (SubagentStart and SessionStart)

**Purpose**: Verify that the OpenJunto hooks are registered in the Codex hook manifest so that `SubagentStart` and `SessionStart` events trigger the CONDUCTOR.md injection and context-loading routines.

**File**: `hooks/hooks.json` (relative to plugin install root, i.e., `${PLUGIN_ROOT}/hooks/hooks.json`).

**Steps**:
1. Check the file exists.
2. Parse as JSON.
3. Inspect the hook entries for matchers covering `SubagentStart` and `SessionStart` events.

**Commands**:
```bash
jq 'map(select(.event == "SubagentStart")) | length' "${PLUGIN_ROOT}/hooks/hooks.json"
jq 'map(select(.event == "SessionStart")) | length' "${PLUGIN_ROOT}/hooks/hooks.json"
```

**Assertions**:
- `hooks/hooks.json` exists.
- JSON parse exits `0`.
- At least one entry with `event == "SubagentStart"` exists (count ≥ 1).
- At least one entry with `event == "SessionStart"` exists (count ≥ 1).

**Pass**: all assertions met.
**Fail (P5)**: file absent, parse fails, no `SubagentStart` entry, or no `SessionStart` entry.

---

## Summary

After all probes complete, emit exactly one summary line:

- If every probe passed:
  ```
  HEALTH: OK
  ```
- If one or more probes failed:
  ```
  HEALTH: DEGRADED — <comma-separated probe IDs that failed>
  ```
  Example: `HEALTH: DEGRADED — P2, P5`

For each failed probe, emit a remediation hint:
- **P1**: Check `oj-helper conductor-inject` manually; verify CONDUCTOR.md exists at `${PLUGIN_ROOT}/CONDUCTOR.md`.
- **P2**: Run `which oj-helper`; ensure install script completed; verify `${PLUGIN_ROOT}/bin/oj-helper` is present and executable.
- **P3**: Install `jq` via system package manager (`apt install jq`, `brew install jq`, etc.).
- **P4**: Re-run the OpenJunto installer; verify `.codex-plugin/plugin.json` was written at `${PLUGIN_ROOT}`.
- **P5**: Re-run the OpenJunto installer; verify `hooks/hooks.json` at `${PLUGIN_ROOT}/hooks/hooks.json` and that both `SubagentStart` and `SessionStart` matchers are present.

---

## Constraints

- **Read-only except for Probe 1**: only Probe 1 invokes a mutating helper subcommand (`conductor-inject`); Probes 2–5 are purely observational.
- **Run all probes**: do not short-circuit on first failure — a complete picture is more useful than a single-failure report.
- **Graceful degradation**: if `jq` is absent (P3 fails), Probe 4 and Probe 5 JSON assertions are automatically failed and marked as such (do not let missing `jq` cause an unhandled error).
- **No network calls**: all checks are local filesystem + subprocess only.
