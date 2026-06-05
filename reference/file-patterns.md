# File Patterns

Structural guidance for project file organization, backlog management, and LLM-optimized content patterns. Load during project setup and occasional refactoring — not during execution.

---

## Backlog Management Guidelines

**Target size**: Keep `BACKLOG.md` under 10KB. Beyond 10KB, context load time increases and the manager spends unnecessary tokens scanning stale items.

### What Belongs in BACKLOG.md

| Content | In BACKLOG.md? | Why |
|---------|---------------|-----|
| Active work items with priority and context | Yes | Needs to be visible every session |
| Blocked items with unblock conditions | Yes | Manager must surface blockers |
| Recently completed items (last 2 sessions) | Yes | Handoff continuity |
| Items completed 3+ sessions ago | No → archive | Stale context; move to `archive/` |
| Design constraints and architectural decisions | No → CONDUCTOR.md | Stable; belongs in project manager protocol |
| One-time setup notes | No → delete after use | Ephemeral; clutter after completion |

### Session Handoff Principles

- Start each session by reading `BACKLOG.md` — it is the volatile state of the project
- End each session by updating item statuses and adding new items discovered during the session
- If `BACKLOG.md` exceeds 10KB, archive completed items before the next session starts
- `BACKLOG.md` is not a permanent record — it is the active work surface

---

## Standard Project `.codex/` Structure

### Minimum Viable (Day 1)

```
.codex/
├── CONDUCTOR.md     # Project-specific manager protocol (overrides and extends global)
└── BACKLOG.md       # Active work items
```

Start here. Add structure only when a specific pain point emerges.

### Full Structure (Mature Projects)

```
.codex/
├── CONDUCTOR.md
├── BACKLOG.md
├── state/
│   └── session.md       # Volatile session state (current work, carry-over)
├── artifacts/
│   ├── analysis/        # Technical analyses, evaluations, research
│   ├── program/         # Implementation plans, specs, decisions
│   ├── meetings/        # Notes, decisions from stakeholder interactions
│   └── status/          # Status reports, progress summaries
└── archive/
    └── YYYY-QN.md       # Archived backlog items and retrospectives by quarter
```

Promote from minimum viable to full structure when:
- Session state is cluttering `BACKLOG.md` (→ add `state/`)
- Deliverables have no clear home (→ add `artifacts/`)
- Completed items are making `BACKLOG.md` unwieldy (→ add `archive/`)

---

## Persist Long-Running Context in CONDUCTOR.md

The project `CONDUCTOR.md` is the stable layer. Use it for:

- **Design constraints**: "All API endpoints must be idempotent"; "No direct database access from service layer"
- **Architectural decisions**: ADRs or summaries of significant technical choices with rationale
- **Project-specific patterns**: Code conventions, naming standards, test organization rules that differ from defaults
- **Stakeholder preferences**: Known preferences that affect triage (e.g., "PM always wants to review before Security for this project")

Do NOT use it for:
- Active work items (→ `BACKLOG.md`)
- Volatile session state (→ `state/session.md`)
- Completed deliverables (→ `artifacts/`)

---

## Header/Detail Pattern

Use when a single file grows beyond the size thresholds below. Splits content into a lightweight index and full-detail files.

### Size Thresholds

| File Size | Action |
|-----------|--------|
| < 10KB | Single file; no split needed |
| 10–25KB | Consider splitting; split if content is naturally segmented |
| > 25KB | Must split — single file is too large for efficient context loading |

### Structure

```
index.md          # Lightweight index (<5KB)
detail/
  YYYY-Q1.md      # Full content for that quarter
  YYYY-Q2.md
  ...
```

### Index Format

```markdown
| ID | Title | Date | Summary |
|----|-------|------|---------|
| A-001 | Rate limiting implementation | 2026-Q1 | Redis-backed sliding window; 200 req/min threshold |
| A-002 | Auth migration planning | 2026-Q2 | JWT migration; 90-day timeline; 7 stakeholders |
```

The manager reads the index to locate relevant content, then reads the specific detail file only when needed.

### Use Cases

| Use Case | Index | Detail Files |
|----------|-------|-------------|
| Completed backlog items | `archive/index.md` | `archive/YYYY-QN.md` |
| Session retrospectives | `state/retro-index.md` | `state/retro/YYYY-MM.md` |
| Artifact collections | `artifacts/index.md` | `artifacts/analysis/`, `artifacts/program/` |

### Example: Backlog Archive

When `BACKLOG.md` approaches 25KB, move completed items:

1. Create `archive/index.md` with the index table format above
2. Move completed item details to `archive/YYYY-QN.md`
3. Add a one-row summary to `archive/index.md`
4. Remove the full item from `BACKLOG.md`

The manager can now reference completed work via the index without loading all archived content.

---

> **Design note**: File organization is structural guidance for project setup and occasional refactoring — not operational protocol. Execution-focused managers don't need this reference during normal engagements. The header/detail pattern is the reusable solution to a recurring problem (growing archive bloat); encoding it here prevents reinventing the pattern per project.
