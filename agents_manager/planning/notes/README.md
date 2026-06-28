# Notes — Planning Sub-Agent

This folder is the planning sub-agent's long-term memory. It is split into two sub-folders:

```
notes/
├── episodic/   ← one file per task id (e.g. T-2026-06-28-001.md)
└── semantic/   ← one file per topic (e.g. plan-templates.md, phase-sizing.md)
```

## When you (the agent) are re-invoked

Read in this order:

1. `notes/semantic/` — curated planning patterns and conventions that apply across tasks. Read every file (or skim the table of contents).
2. `notes/episodic/` — past plans you wrote on the same task id, if any. Skim for prior context.

## What goes where

- **`episodic/<task-id>.md`** — per-task planning notes. A short pointer to the actual plan files (`share/notes/02_plan_*.md`), plus any rationale the user discussed that wasn't in the plan itself.
- **`semantic/<topic>.md`** — cross-task planning patterns. Things like "this repo prefers phases of ≤1 week", "tests are always part of phase 1", "we split front-end / back-end phases by default".

## Rules

- Append, don't overwrite. Use dated headings.
- Cite the plan file path for every per-task note.
- Move insights into `semantic/` only when they've shown up in ≥2 tasks.
- The master never edits this folder.

## Empty folder

If both sub-folders are empty, you're a fresh agent. Read `resources/` for any standing templates, then proceed.
