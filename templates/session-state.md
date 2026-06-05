# Session State

<!-- Volatile layer for ~/.codex/state/session.md.
     Update at session boundaries using the session save command.
     Do not hand-edit mid-session; let the save command manage this file. -->

> Updated: {YYYY-MM-DD}, session {N}

---

## In-Flight PRs

| # | Repo | Title | Status | Notes |
|---|------|-------|--------|-------|
| {PR#} | {org/repo} | {PR title} | Draft / Review / Approved / Blocked | {Blocker or next step} |
| {PR#} | {org/repo} | {PR title} | Draft / Review / Approved / Blocked | |

---

## Local Workspace State

| Repo | Branch | Dirty | Unpushed | Notes |
|------|--------|-------|----------|-------|
| {org/repo} | {branch-name} | clean / {FILES} | {COUNT} | {Any relevant context} |
| {org/repo} | {branch-name} | clean / {FILES} | {COUNT} | |

<!-- Dirty column: use "clean" if no uncommitted changes, otherwise list filenames separated by spaces.
     Unpushed column: number of local commits not yet pushed to remote. -->

---

## Session Carry-Over

<!-- Retention policy (do not remove this comment):
     - Most recent 3 sessions: keep full detail
     - Sessions older than 7 days: compress to single line summary
     - Sessions older than 14 days: remove entirely
-->

*Completed this session ({YYYY-MM-DD}, session {N}):*

1. {Task or outcome}
2. {Task or outcome}
3. {Task or outcome}

*Completed last session ({YYYY-MM-DD}, session {N-1}):*

1. {Task or outcome}
2. {Task or outcome}

*Session {N-2} ({YYYY-MM-DD}):* {Single-line compressed summary of what was accomplished.}

---

## Next Actions

1. {Next action — be specific enough to resume without re-reading all context}
2. {Next action}
3. {Next action}

---

<!-- CODEX PLUGIN: This template is deployed via ${PLUGIN_ROOT}/templates/session-state.md.
     The live file lives at ~/.codex/state/session.md or .codex/state/session.md for project-scoped state. -->
