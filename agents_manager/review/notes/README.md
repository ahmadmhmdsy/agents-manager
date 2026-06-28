# Notes — Review Sub-Agent

This folder is the review sub-agent's long-term memory. It is split into two sub-folders:

```
notes/
├── episodic/   ← one file per task id (e.g. T-2026-06-28-001.md)
└── semantic/   ← one file per topic (e.g. common-bugs.md, security-checklist.md)
```

## When you (the agent) are re-invoked

Read in this order:

1. `notes/semantic/` — curated checklists and common-pitfall lists that apply across tasks. Read every file (or skim the table of contents).
2. `notes/episodic/` — the most recent 3 reports (skim them, don't re-read in full). Don't repeat blind spots the project has hit before.

## What goes where

- **`episodic/<task-id>.md`** — per-task review notes. A short pointer to each review report (`share/reports/04_review_<task-id>_<phase>.md`), plus any patterns you saw in this task.
- **`semantic/<topic>.md`** — cross-task patterns. Things like "this repo's CI runs `pytest -x`", "this team has historically missed input validation in API endpoints", "we always check error paths".

## Rules

- Append, don't overwrite. Use dated headings.
- Cite the report path for every per-task note.
- Move insights into `semantic/` only when they've shown up in ≥2 tasks.
- The master never edits this folder.

## Empty folder

If both sub-folders are empty, you're a fresh agent. Read `resources/` for any standing checklists, then proceed.
