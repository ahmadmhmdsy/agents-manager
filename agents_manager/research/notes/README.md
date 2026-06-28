# Notes — Research Sub-Agent

This folder is the research sub-agent's long-term memory. It is split into two sub-folders:

```
notes/
├── episodic/   ← one file per task id (e.g. T-2026-06-28-001.md)
└── semantic/   ← one file per topic (e.g. repo-conventions.md, common-risks.md)
```

## When you (the agent) are re-invoked

Read in this order:

1. `notes/semantic/` — curated insights that apply across tasks. Read every file (or skim the table of contents).
2. `notes/episodic/` — notes from prior invocations on the same task id, if any. Skim them to maintain continuity.

## What goes where

- **`episodic/<task-id>.md`** — per-task research notes. The body of each research output (`share/notes/01_research_<task-id>.md`) gets a summary copy here, plus any side notes you kept while working. Newest on top.
- **`semantic/<topic>.md`** — cross-task insights. Things like "this repo always builds with `npm run build`", "tests live in `tests/` and follow pytest naming", "user prefers X". Update these when you learn something durable.

## Rules

- Append, don't overwrite. Use dated headings.
- Cite everything (`path:line`).
- Move insights into `semantic/` only when they've shown up in ≥2 tasks (otherwise they're still anecdotal).
- The master never edits this folder.

## Empty folder

If both sub-folders are empty, you're a fresh agent. Read `resources/` for any standing references, then proceed.
