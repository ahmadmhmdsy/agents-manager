# Notes — Coder Sub-Agent

This folder is the coder sub-agent's long-term memory. It is split into two sub-folders:

```
notes/
├── episodic/   ← one file per task id (e.g. T-2026-06-28-001.md)
└── semantic/   ← one file per topic (e.g. repo-style.md, build-commands.md)
```

## When you (the agent) are re-invoked

Read in this order:

1. `notes/semantic/` — curated patterns for this repo: code style, naming, error handling, where tests go, build/test commands. Read every file (or skim the table of contents).
2. `notes/episodic/` — past summaries you wrote on the same task id, if any. Skim for continuity.

## What goes where

- **`episodic/<task-id>.md`** — per-task coding notes. A short pointer to each coder summary (`share/notes/03_coder_summary_<task-id>_<phase>.md`), plus any repo quirks you discovered while implementing.
- **`semantic/<topic>.md`** — cross-task patterns. Things like "this repo uses pytest with fixtures from `tests/conftest.py`", "all public functions need docstrings", "logger is imported as `from .log import get_logger`".

These `semantic/` files are **also** what `am-review` reads when looking for documented test/build commands. Keep them accurate.

## Rules

- Append, don't overwrite. Use dated headings.
- Cite the summary path for every per-task note.
- Move insights into `semantic/` only when they've shown up in ≥2 tasks.
- The master never edits this folder.

## Empty folder

If both sub-folders are empty, you're a fresh agent. Read `resources/` for any standing conventions, then proceed.
