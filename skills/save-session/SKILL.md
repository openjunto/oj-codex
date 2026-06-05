---
name: save-session
description: Persist session state and compress carry-over before /clear; requires user approval before writing
---

# $save-session

Session-state persistence skill. Invoke with `$save-session` (or via `/skills` → `save-session`). Persists session state before `/clear` so context carries into the next session. **All proposed changes are presented to the user for approval before writing** — this skill never auto-writes.

---

## Protocol

### Step 1 — Read Current State

1. Read `.codex/state/session.md` (if exists).
2. Read `.codex/CONDUCTOR.md` (project-local manager protocol).
3. If `session.md` is absent, offer to create it from the template at `${PLUGIN_ROOT}/templates/session-state.md`. Do not create automatically — present the offer and wait for the user's confirmation before proceeding.

### Step 2 — Scan Working State

Run `git status` in the project root. For multi-repo projects, scan each repository listed in `.codex/CONDUCTOR.md`. Record per repository:

- Current branch name.
- Dirty / clean status (uncommitted changes, untracked files).
- Any staged-but-uncommitted changes (flag explicitly).

### Step 3 — Check In-Flight PRs

If `state/session.md` lists open pull requests, run for each:

```bash
gh pr view <number> --json state,statusCheckRollup,mergeable
```

Update the status fields (open / merged / closed, CI status, merge conflicts). Skip this step if no PRs are listed in session.md or if `gh` is unavailable — note the skip.

### Step 4 — Verify Backlog Consistency

Read `.codex/BACKLOG.md`. Check:

1. Header item count matches the actual count of non-Completed items.
2. Any item with a "Blocked By" reference — verify the referenced item's status. If the blocking item is already Completed, flag as an unblock candidate.

Note all inconsistencies found; they will appear in the Step 6 draft.

### Step 5 — Check for Unprocessed Input

Scan the repository root for ad-hoc files: `tasks.md`, `notes.md`, `TODO.md`. If any are found, flag them in the draft so the user knows they exist and can decide whether to process them before clearing.

### Step 6 — Draft Session Update

Compose an updated `state/session.md` with the following contents:

- **Session number**: increment from the current value (or start at 1 if creating from template).
- **Date**: today's date.
- **In-Flight PRs**: updated from Step 3.
- **Workspace state**: branch + dirty/clean status per repo from Step 2.
- **Completed this session**: carry-over entry summarizing work done in the current session.
- **Carry-over compression**:
  - Entries older than 2 sessions → compress to a single-line summary.
  - Entries older than 14 days → drop entirely.
- **Next Actions**: updated based on current backlog state and any flagged items from Steps 4–5.

**Operational learning is NOT stored here** — `.codex/state/learning-index.md`, `.codex/state/action-items.md`, and `.codex/evolution/measurements/triage-calibration.json` are managed exclusively by task lifecycle Phase 5 (`$run-task` / `$cycle`). Do not write those files from `$save-session`.

### Step 7 — Present and Apply

Present a diff-style summary of all proposed changes:

- The full proposed `state/session.md` content (or diff from current).
- Any flagged inconsistencies (Step 4) or unprocessed files (Step 5).
- Any skipped steps and the reason.

**Apply only after the user explicitly approves.** If the user rejects or requests changes, explain the proposed changes and ask for guidance. Never write without approval.

---

## Constraints

- **Approval required**: never auto-write; present all proposed changes first and wait for explicit user approval.
- **Non-destructive**: show what will change; never delete content without presenting it to the user first.
- **Graceful degradation**: skip any step whose file or resource is absent; note the skip clearly. The skill remains operable even if `gh` is unavailable, `BACKLOG.md` is absent, or repos listed in `.codex/CONDUCTOR.md` are not accessible.
- **No network calls beyond git/gh**: only `git`, `gh`, and local file reads. No external API calls.

---

## Cross-References

> - Session state template: `${PLUGIN_ROOT}/templates/session-state.md`
> - Manager protocol: `.codex/CONDUCTOR.md`
> - Operational learning (separate): `$run-task` Phase 5 / `$cycle` Step 8
