# CLAUDE.md

# agents_manager — Multi-Agent Task Orchestration

This repository implements a multi-agent task pipeline built on OpenCode's agent system.

## Auto-routing

When the user provides a task that requires multiple steps (research → plan → build → review), spawn the **master** agent via the task tool:

```
task(subagent_type="master", prompt="<the user's task>")
```

The master handles everything: writing the task capture, calling specialists, enforcing gates, escalating to the user when needed.

For single-step work (a quick file edit, a one-off question), do it directly — no need to invoke the master.

## Available agents

Defined in `opencode.jsonc` with hard permission walls enforced by OpenCode.

| Agent | Type | Purpose | Owns |
|---|---|---|---|
| `master` | agent | Orchestrates the pipeline; does not implement | `share/handoffs/`, `share/notes/99_decisions.md`, `tasks/` |
| `am-research` | agent | Brainstorm, doubt, analyze, investigate | `share/notes/01_research_*.md` |
| `am-planning` | agent | Turn research into a phased plan + task list | `share/notes/02_plan_*.md`, `tasks/<id>.md` rows |
| `am-coder` | agent | Implement assigned tasks | source code, `share/notes/03_coder_summary_*.md` |
| `am-review` | agent | Verify coder work, produce per-task verdicts | `share/reports/04_review_*.md` |

The walls (e.g. `am-research` literally cannot write code, `am-coder` literally cannot edit `agents_manager/**`) are enforced by OpenCode's permission layer — not by prose promises.

## Project structure

```
agents_manager/        — controller: 1 master + 4 specialists, each with SKILL.md + rules.md
share/                 — inter-agent communication bus (handoffs, notes, reports)
tasks/                 — canonical task tracker (one .md per task id)
research_doc/          — long-term research notes and decision records
opencode.jsonc         — agent definitions + permissions
CLAUDE.md              — this file
```

## Key conventions

- The master NEVER codes, plans, or reviews directly. It routes to specialists.
- Specialists NEVER spawn other specialists. Only the master orchestrates.
- All inter-agent communication goes through files in `share/`. No out-of-band chat.
- Task id format: `T-YYYY-MM-DD-NNN`. One task file per id in `tasks/`.
- Review reports are brutally honest. False PASS ships bugs; false FAIL just costs a fix loop.
- Sub-agent `SKILL.md` and `rules.md` files are reference docs read on agent startup. They contain the full role definition, output templates, and standing rules.

## Don't do

- Do NOT edit files inside `agents_manager/` unless explicitly redesigning the controller.
- Do NOT spawn specialists from a specialist. Only the master orchestrates.
- Do NOT skip the review phase because "it looks fine."
- Do NOT accept the first review report without reading it.

## See also

- `agents_manager/SKILL.md` — full master orchestration protocol
- `agents_manager/README.md` — pipeline overview
- `agents_manager/CHANGELOG.md` — system evolution history
- `AGENT_temp.md` — project-specific tech stack and commands
