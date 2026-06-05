# oj-codex

A Codex CLI plugin that transforms the AI into a coordinated team of 16 expert
sub-agents with structured peer review.

The Codex sibling of [`oj-claude`](https://github.com/openjunto/oj-claude). Generated
by the [`juntogen/codex`](https://github.com/openjunto/juntogen) pipeline from the
platform-agnostic [`juntospec`](https://github.com/openjunto/juntospec) corpus.

## Quickstart

**Install from the marketplace** (inside a Codex CLI session or from the shell):

```
codex plugin marketplace add <path-to-oj-codex>
codex plugin install oj@openjunto
```

Then start a new Codex CLI session (restart, or `/clear`) to load the plugin. The
`SessionStart` hook injects the manager protocol and prints a version banner to stderr.

**Local iteration** (work on the plugin without installing):

```bash
git clone https://github.com/openjunto/oj-codex.git
codex --plugin-dir ./oj-codex
```

## Usage

The manager protocol loads automatically at session start. Kick off a coordinated cycle:

```
/oj:cycle Review this pull request for security issues.
/oj:cycle Fix the flaky test in auth_service_test.go.
/oj:cycle Evaluate whether we should migrate from REST to gRPC for internal services.
```

For a single backlog item use `/oj:run-task` — the Manager picks the next item, delegates
to experts, enforces peer review, and marks it done.

You do not name the experts. The Manager triages the request, selects domain stakeholders,
spawns the appropriate sub-agents in parallel, and synthesizes their findings.

## What's Included

- **16 expert sub-agents** — see [`agents/`](agents/) and [`agents/index.md`](agents/index.md)
- **5 skills** — `/oj:cycle`, `/oj:run-task`, `/oj:show-backlog`, `/oj:save-session`, `/oj:health-check`
- **Complexity triage** — Simple / Moderate / Complex tiers proportional to risk
- **Peer review workflow** — adversarial reviewer on every Moderate/Complex task
- **Circuit breakers** — auto-escalates after 3 revision cycles or 2 hours without progress
- **Templates** — ADR, technical analysis, retrospective, session state, comms playbook

## How It Works

1. **Triage** — Incoming requests scored against 4 criteria; tier determines process weight
2. **Delegation** — Manager spawns domain expert sub-agents in parallel (up to 6 threads)
3. **Review** — A distinct adversarial reviewer validates the work and names the strongest objection
4. **Synthesis** — Manager consolidates findings into a unified deliverable

## Advanced: Backlog Sprint

If your project has a `.codex/BACKLOG.md`:

```
/oj:run-task
```

The Manager selects the highest-priority item, delegates to experts, conducts peer review,
and marks the item done. Chain multiple invocations to work through a sprint.

## Directory Structure

**Plugin tree** (installed into `~/.codex/plugins/cache/...`):

```
oj-codex/
├── CONDUCTOR.md             — manager protocol (injected at session start; AGENTS.md untouched)
├── agents/                  — 16 expert profiles (full + compact) + index.md
├── .codex/agents/*.toml     — native sub-agent definitions (model + effort per expert)
├── skills/                  — Agent Skills: cycle, run-task, show-backlog, save-session, health-check
├── hooks/hooks.json         — SessionStart + SubagentStart hooks
├── bin/oj-helper            — CLI dispatcher (conductor-inject, inject-profile, subagents-check, …)
├── reference/               — workflow-stages, stakeholder-guide, worked-examples, …
├── templates/               — ADR, technical-analysis, retrospective, session-state, comms-playbook
└── .codex-plugin/           — plugin.json + marketplace.json
```

**Per-project layout** (created on first use):

```
.codex/
├── BACKLOG.md               — prioritized work queue
├── state/                   — session carry-over (session.md, context maps)
└── artifacts/               — deliverables produced during engagements
    ├── adr/
    └── analysis/
```

## Model Roster

| Model | Tier | When Used |
|---|---|---|
| `gpt-5.4-mini` | routine | Formatting, doc updates, mechanical transforms |
| `gpt-5.3-codex` | implementation | Feature work, stakeholder analysis, code review |
| `gpt-5.5` | reasoning | Adversarial review, architecture, complex debugging |

Per-expert `model` and `model_reasoning_effort` are first-class fields on each
`.codex/agents/*.toml` definition — a capability gain over the Claude Code binding
where effort is session-level only. Adversarial reviewers run at `xhigh`; routine
analysts at `medium`.

## Documentation

- [WHY.md](WHY.md) — problem statement, how OpenJunto works, honest tradeoffs
- [docs/onboarding.md](docs/onboarding.md) — first 10 minutes after installation
- [CONDUCTOR.md](CONDUCTOR.md) — full manager protocol
- [agents/index.md](agents/index.md) — expert roster with engagement triggers
