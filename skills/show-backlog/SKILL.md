---
name: show-backlog
description: Display a read-only summary of the current backlog grouped by priority
---

# $show-backlog

Read-only backlog summary skill. Invoke with `$show-backlog` (or via `/skills` → `show-backlog`). Displays a concise summary of the current backlog state. **Read-only** — no modifications, no ticket transitions, no work started.

---

## Protocol

### Step 1 — Backlog Source Detection

Run `oj-helper issue-tracker-check` in bash, then:

```
issue-tracker-check fails?                        -> BACKLOG.md mode
issue-tracker-check succeeds + project null?      -> BACKLOG.md mode
issue-tracker-check succeeds + project non-null?  -> issue tracker mode with KEY
```

This detection logic is identical to `$run-task` Phase 1. Both skills must behave consistently.

### Step 2 — Load Backlog Items

- **Issue tracker mode**: Run `oj-helper issue-tracker-list --project PROJECT_KEY`. Parse the JSON array to extract per item: key, summary, status, priority.
- **BACKLOG.md mode**: Read `.codex/BACKLOG.md`. Parse the markdown structure to extract per item: ID, title, status — grouped by priority section (P0 through P4).

### Step 3 — Present Summary

Emit the summary in this structure:

**Header**:
- Backlog source: issue tracker project key OR `BACKLOG.md` path.
- Total open item count (exclude Completed items).

**Items by Priority**:
- Group items by priority. Show ID (or key), Title/Summary, Status per item.
- Omit empty priority groups entirely (do not emit a heading for a group with no items).
- Omit Completed items from the display.

**Next Cycle Candidate**:
- Highlight the single highest-priority unblocked item.
- Tiebreak: oldest by creation date.
- Label it clearly as the suggested next item for `$run-task` or `$cycle`.

**Empty backlog**:
- If no open items exist, say so clearly and suggest adding items before running `$run-task`.

---

## Constraints

- **Read-only**: no backlog modifications, no ticket transitions, no work started. `$show-backlog` is a display-only skill.
- **Concise**: titles and IDs are sufficient; do not repeat full descriptions. Keep output scannable.
- **Empty backlog handling**: always emit a clear message when no open items are found; do not silently emit an empty list.
- **No side effects**: this skill does not write files, update state, or invoke any mutating helper subcommands.

---

## Cross-References

> - Full task lifecycle: `$run-task` (single item) or `$cycle` (multi-item loop)
> - Project backlog conventions: `.codex/CONDUCTOR.md`
