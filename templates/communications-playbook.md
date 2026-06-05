# Communications Playbook — {Project Name}

<!-- Copy this file to .codex/COMMS.md (or ~/.codex/COMMS.md for personal use).
     This file serves as a signal gate + channel routing guide.
     Purpose: prevent communication noise by enforcing event-driven posting only. -->

---

## Signal Gate

<!-- The gate prevents noise. Post ONLY when a qualifying signal occurs — not on elapsed time. -->

| Signal | Post to |
|--------|---------|
| Acceptance criteria completed | {Channel} |
| Blocker discovered | {Channel} |
| Blocker resolved | {Channel} |
| Status transition (e.g., In Progress → Review) | {Channel} |
| Decision made (architecture, product, process) | {Channel} |
| Story / task completed | {Channel} |
| Health status shift (green → yellow, yellow → red, red → green) | {Channel} |
| Ask / escalation needed | {Channel} |

**Not a signal** — do not post for:
- Elapsed time ("just checking in", "it's been a week")
- Internal housekeeping (file moves, draft edits, local commits)
- Current-state restatement without change (re-reporting what everyone already knows)
- Work-in-progress without a milestone crossed

---

## Hierarchy Rule

One event = one post at the **lowest appropriate level**. Roll up only when the aggregated
picture itself changes (e.g., overall health shifts). Do not echo the same news at multiple
levels — that is noise, not communication.

> Example: A story completes → post to the team channel. Do not also post to the stakeholder
> channel unless completing this story changes the release forecast.

---

## Channel Routing

| Channel | Purpose | Trigger | Format |
|---------|---------|---------|--------|
| {Ticket system — e.g., GitHub Issues / Jira} | Task-level updates, blockers, decisions | Any signal that affects a specific work item | Comment on the ticket; use labels for status |
| {Team channel — e.g., #proj-{name}} | Team-level updates, technical decisions, blockers | Blocker, status transition, decision, health shift | Short paragraph + link to ticket or ADR |
| {Stakeholder channel — e.g., #proj-{name}-exec} | Milestone completions, health status, escalations | AC completed, health shift, ask/escalation | 3-sentence max: status, impact, ask (if any) |
| {Status meeting / doc — e.g., weekly sync notes} | Aggregated progress; decisions for record | Weekly cadence or on-demand | Bullet list: done / in-flight / blocked / next |

---

## Drafts

<!-- Expand drafts inline below for review before sending.
     Mark status: Draft / Approved / Sent -->

| Date | Channel | Draft | Status |
|------|---------|-------|--------|
| {YYYY-MM-DD} | {Channel} | [See draft below](#draft-1) | Draft / Approved / Sent |

<!-- DRAFT-1
Channel: {Channel name}
---
{Draft message text here.}

Review notes: {Any comments on the draft before it is sent.}
-->

---

## Log

<!-- Record sent communications per channel for traceability. -->

### {Team channel — e.g., #proj-{name}}

| Date | Summary |
|------|---------|
| {YYYY-MM-DD} | {One-sentence summary of what was posted} |

### {Stakeholder channel}

| Date | Summary |
|------|---------|
| {YYYY-MM-DD} | {One-sentence summary of what was posted} |

### {Ticket system}

| Date | Summary |
|------|---------|
| {YYYY-MM-DD} | {Ticket reference + what was commented} |

---

<!-- CODEX PLUGIN: This template is deployed via ${PLUGIN_ROOT}/templates/communications-playbook.md.
     Project copies live at .codex/COMMS.md; personal copies at ~/.codex/COMMS.md. -->
