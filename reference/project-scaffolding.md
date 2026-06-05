# Project Scaffolding

Infrastructure patterns for mature OpenJunto projects. New projects start with `CONDUCTOR.md` + `BACKLOG.md`. Adopt these patterns when specific pain points emerge, not preemptively.

---

## Session State Separation

Split project state into two layers to avoid coupling stable configuration with volatile session data:

| Layer | File | Content | Change Frequency |
|-------|------|---------|-----------------|
| **Stable** | `.codex/CONDUCTOR.md` | Design constraints, architectural decisions, project-specific patterns | Rarely — only when something fundamental changes |
| **Volatile** | `.codex/state/session.md` | In-flight PRs, local workspace state, carry-over, next actions | Every session |

Reading `CONDUCTOR.md` gives the manager the standing constraints. Reading `state/session.md` gives the current work context. Neither file substitutes for the other.

---

## Carry-Over Compression

Session carry-over in `state/session.md` ages according to this policy:

| Age | Retention Policy |
|-----|-----------------|
| Current session + 2 prior sessions | Keep full detail |
| 7–14 days old | Compress to one-line summary per item |
| 14+ days old | Remove; promote to `BACKLOG.md` if still relevant, otherwise discard |

Apply the aging policy at the start of each session before adding new carry-over. A `state/session.md` that grows without pruning defeats the purpose of the volatile layer.

**Example carry-over entry (full detail)**:

```markdown
## Session Carry-Over

### In Progress
- PR #142: Rate limiting middleware — awaiting Security review (opened 2026-06-03)
- Auth migration plan: Draft complete; pending PM approval before Phase 2 spawn

### Blocked
- Deployment pipeline update: blocked on DevOps access grant (ticket INFRA-891)
```

---

## Context Map (llms.txt)

For projects with 10 or more `.codex/` files, create an index to prevent the manager from loading unnecessary files.

**Trigger**: When `ls .codex/` returns 10+ files and session startup time is noticeably slow.

### Index Format

```markdown
# Context Map — [Project Name]

## Core Files (load every session)
| File | Purpose |
|------|---------|
| `.codex/CONDUCTOR.md` | Project constraints, architectural decisions |
| `.codex/BACKLOG.md` | Active work items |
| `.codex/state/session.md` | Current session state and carry-over |

## Reference Files (load on demand)
| File | Load When |
|------|-----------|
| `.codex/artifacts/analysis/rate-limiting.md` | Rate limiting questions arise |
| `.codex/artifacts/program/auth-migration-plan.md` | Auth migration work resumes |
| `.codex/archive/index.md` | Reviewing completed work |

## Loading Guide
- Start every session: read core files only
- Domain questions: check reference table before reading full files
- Completed work: check archive/index.md first; load detail files by quarter
```

Place this file at `.codex/llms.txt` — the conventional path for LLM context indexes.

---

## Artifact Organization

Four subdirectories under `.codex/artifacts/`, each with a distinct lifecycle:

| Directory | Purpose | Lifecycle |
|-----------|---------|-----------|
| `analysis/` | Technical analyses, evaluations, research outputs | Keep until superseded; archive after 2 quarters |
| `program/` | Implementation plans, specs, architecture decisions | Keep active; move to `archive/` when shipped |
| `meetings/` | Stakeholder interaction notes, decisions, action items | Keep for 3 months; archive or discard |
| `status/` | Status reports, progress summaries, metrics snapshots | Keep current quarter; discard older |

**Naming convention**: `YYYY-MM-DD-short-description.md` for most files. This makes chronological sorting work correctly with alphabetical directory listing.

---

## Snapshot Caching Contract

For command-generated data (dependency audits, test results, metric snapshots) that is expensive to regenerate:

**Convention**: Write to `.codex/state/cache/` with a 2-hour TTL marker in the filename or frontmatter.

```bash
# Generate and cache
CACHE_FILE=".codex/state/cache/dep-audit-$(date +%Y%m%dT%H%M).json"
codex-helper audit-deps > "$CACHE_FILE"
echo "Cached at: $CACHE_FILE (valid 2 hours)"
```

**Reading cached data**:

```bash
# Find cache file less than 2 hours old
CACHE=$(find .codex/state/cache/ -name "dep-audit-*.json" -mmin -120 | sort | tail -1)
if [ -n "$CACHE" ]; then
  cat "$CACHE"
else
  echo "Cache expired — regenerate"
fi
```

**TTL**: 2 hours is the default. Adjust per data type: test results may be valid for 30 minutes; dependency audits for 24 hours. Document the TTL in the file or cache directory README.

---

## Communications Playbook Pattern

For projects with regular external communication (stakeholder updates, incident reports, partner notifications). Adopt when communication overhead is causing friction.

### Signal Gate

Define which events trigger which communications:

| Event | Recipients | Channel | Trigger Condition |
|-------|-----------|---------|-------------------|
| PR merged to main | Team | Slack #dev | Always |
| Production incident declared | Stakeholders | Email + Slack #incidents | Severity ≥ P2 |
| Milestone completed | PM + Leadership | Email | Milestone in BACKLOG |
| External API change | Partner contacts | Email | Version bump in changelog |

### Hierarchy Rule

One event = one post. Do not post the same update to multiple channels unless channels serve distinct audiences. If a Slack message and an email cover the same event, the email is for stakeholders who don't read Slack — not a duplicate notification.

### Channel Routing Table

```markdown
| Channel | Audience | Appropriate Content |
|---------|---------|---------------------|
| Slack #dev | Engineering team | PRs, technical decisions, blockers |
| Slack #incidents | On-call + leads | Production issues, SLO breaches |
| Email | PM, leadership, partners | Milestones, external-facing changes |
| GitHub PR | Code reviewers | Technical review requests |
```

### Drafts Queue

Before sending external communications, add to drafts queue for review:

```markdown
## Drafts Queue
- [ ] Partner notification: API v2 deprecation (due: 2026-06-10)
- [ ] Stakeholder update: Auth migration Phase 1 complete
```

### Log

Keep a log of sent communications in `state/comms-log.md` for audit and context:

```markdown
| Date | Event | Recipients | Channel | Sent By |
|------|-------|-----------|---------|---------|
| 2026-06-03 | Rate limiting GA | PM, DevOps | Email | Manager |
```

---

## Session Lifecycle Pattern

### Health Check (Pre-Session Validation)

Run these checks at the start of each session before accepting new work:

- [ ] `BACKLOG.md` is current — no stale in-progress items from last session
- [ ] `state/session.md` carry-over has been pruned to the aging policy
- [ ] No unresolved circuit breaker conditions from prior session (3 revision cycles, 2-hour elapsed, deadlock)
- [ ] Cache files are fresh or marked for regeneration
- [ ] No blocked tasks awaiting external input that may now be unblocked

### Intake Funnel (External Input Processing)

When new input arrives (user message, PR comment, incident alert):

1. **Classify**: Is this a new task, a follow-up to in-flight work, or noise?
2. **Triage** (new tasks only): Apply the two-dimension triage algorithm — tier + stakeholders
3. **Confirm**: Present triage result to user before proceeding
4. **Load**: Load tier-appropriate reference files and profiles
5. **Execute**: Follow the tier workflow

### Session Save

At end of session, update:

1. `BACKLOG.md` — status changes, new items discovered
2. `state/session.md` — carry-over for next session, blocked items, next actions
3. Any artifacts produced during the session → `artifacts/` with dated filename
4. Comms log if any external communications were sent

```bash
# Session save reminder (run at end of session)
echo "Session save checklist:"
echo "  [ ] BACKLOG.md updated"
echo "  [ ] state/session.md carry-over written"
echo "  [ ] Artifacts saved to .codex/artifacts/"
echo "  [ ] Comms log updated if needed"
```
