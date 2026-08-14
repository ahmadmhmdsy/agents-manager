# Project memory manifest: T-DEMO

Append-only log of artifacts externalized from the current conversation window.
One row per artifact. Read this file before adding a row to check for path
uniqueness. See agents_manager/SKILL.md § Context externalization protocol.

## Header (6 columns)

| saved_at | saved_by | path | purpose | when_to_reload | loader |
|---|---|---|---|---|---|

## Rows

| 2026-08-14T10:00:00Z | master/am-research | share/notes/01_research_T-DEMO.md | Survey of existing solutions | Before Phase 2 planning | Read whole file |
| 2026-08-14T10:30:00Z | master/am-research | share/notes/01_research_T-DEMO_chroma.md | ChromaDB context-rot study | Before planning RLM borrowing | Read whole file (small) |
| 2026-08-14T11:00:00Z | master/am-planning | share/notes/02_plan_high_T-DEMO.md | Implementation plan for v0.23.0 | Before dispatching am-coder | Read first 50 lines (TLDR) |
| 2026-08-14T14:00:00Z | master/am-coder | share/handoffs/03a_coder_T-DEMO_handoff.md | Reference impl handoff | Before am-design picks up mockups | Read whole file |

## Discipline notes

- **Path uniqueness:** if `path` already exists in any row, update the existing row's `purpose` / `when_to_reload` / `loader` in place — do NOT append a duplicate row.
- **Multi-master:** in `saved_by`, prefix with master-id (e.g. `master-A/am-research`). Single-master deployments may omit the prefix.
- **Atomic writes:** each row is one line, written via `share/notes/_helpers/append_row.py` (O_APPEND atomic at OS level for small writes).
- **Lifecycle:** this manifest lives with the task. Archive to `share/notes/_archive/<task-id>_memory.md` when the task closes.
