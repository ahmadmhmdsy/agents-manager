# Trace log (v0.17.0+)

## Purpose

Greppable audit trail for what each agent did in each task. Closes the gap `docs/PERMISSIONS.md` admits exists: the soft-wall model is disciplined by SKILL.md prose, but without an external record there is no way to verify that discipline held. The trace log is that record.

The trace log is **append-only, audit-only**. Nothing reads it as input. If it were deleted, no agent's behavior would change.

## Schema

One JSON object per line in `share/notes/00_trace_<task-id>.jsonl`:

```json
{
  "ts": "2026-07-14T10:23:45+00:00",
  "task_id": "T-2026-07-14-001",
  "agent": "am-research",
  "phase": 1,
  "action": "start",
  "files_touched": [],
  "verdict": null,
  "notes": "researching auth flows for the new dashboard"
}
```

## Closed enums

| Field | Allowed values |
|-------|----------------|
| `agent` | `master`, `am-research`, `am-planning`, `am-design`, `am-assets`, `am-coder`, `am-review` |
| `action` | `start`, `complete`, `dispatch`, `anomaly`, `fix-loop` |
| `verdict` | `null`, `PASS`, `WARN`, `FAIL` (only meaningful for `am-review` + `action=complete`) |
| `phase` | `0` (master preflight) · `1` (research) · `2` (planning) · `3` (build) · `3a` (assets) · `4` (review) |

`files_touched` is an array of repo-relative paths. Empty array is valid (most actions touch no files).

## When to write (per agent)

| Agent | Required writes |
|-------|-----------------|
| `master` | `start` (after preflight), one `dispatch` per specialist handoff, one `complete` at task close, one `anomaly` per untrusted-content pause, one `fix-loop` per review-FAIL re-dispatch |
| `am-research` | `start` at dispatch arrival, `complete` at return, `anomaly` if untrusted-content clause fires |
| `am-planning` | same shape as am-research |
| `am-design` | same shape as am-research (phase 3, or 0 for standalone) |
| `am-assets` | same shape (phase 3a) |
| `am-coder` | `start` at dispatch arrival, `complete` at return, `anomaly` if ELEVATED untrusted-content clause fires, `fix-loop` if master loops you back |
| `am-review` | same as am-coder; `complete` carries `verdict` (PASS / WARN / FAIL) |

Specialists use `scripts/append-trace.py` (stdlib only). Master can use it too, or write directly — the format is the contract.

## Example trace (normal task, one fix-loop)

```json
{"ts": "2026-07-14T10:00:00+00:00", "task_id": "T-2026-07-14-001", "agent": "master", "phase": 0, "action": "start", "files_touched": [], "verdict": null, "notes": "user: build a dashboard with auth"}
{"ts": "2026-07-14T10:00:05+00:00", "task_id": "T-2026-07-14-001", "agent": "master", "phase": 0, "action": "dispatch", "files_touched": ["share/notes/01_research_T-2026-07-14-001.md"], "verdict": null, "notes": "am-research"}
{"ts": "2026-07-14T10:05:30+00:00", "task_id": "T-2026-07-14-001", "agent": "am-research", "phase": 1, "action": "start", "files_touched": [], "verdict": null, "notes": "landscape scan + findings"}
{"ts": "2026-07-14T10:18:12+00:00", "task_id": "T-2026-07-14-001", "agent": "am-research", "phase": 1, "action": "complete", "files_touched": ["share/notes/01_research_T-2026-07-14-001.md"], "verdict": null, "notes": "scan + 4 findings; 2 build-vs-reuse Qs for user"}
{"ts": "2026-07-14T10:18:13+00:00", "task_id": "T-2026-07-14-001", "agent": "master", "phase": 0, "action": "dispatch", "files_touched": ["share/notes/02_plan_high_T-2026-07-14-001.md"], "verdict": null, "notes": "am-planning (after user confirm)"}
{"ts": "2026-07-14T10:30:00+00:00", "task_id": "T-2026-07-14-001", "agent": "am-planning", "phase": 2, "action": "complete", "files_touched": ["share/notes/02_plan_high_T-2026-07-14-001.md", "share/notes/02_plan_phases_T-2026-07-14-001.md", "tasks/T-2026-07-14-001.md"], "verdict": null, "notes": "3 phases, auth=reuse next-auth, db=reuse postgres"}
{"ts": "2026-07-14T10:45:00+00:00", "task_id": "T-2026-07-14-001", "agent": "am-coder", "phase": 3, "action": "complete", "files_touched": ["src/auth/login.ts", "src/db/schema.sql"], "verdict": null, "notes": "phase 1 of 3 done"}
{"ts": "2026-07-14T10:50:00+00:00", "task_id": "T-2026-07-14-001", "agent": "am-review", "phase": 4, "action": "complete", "files_touched": ["share/reports/04_review_T-2026-07-14-001_phase-1.md"], "verdict": "FAIL", "notes": "1 task failed: missing tests for src/auth/login.ts"}
{"ts": "2026-07-14T10:50:01+00:00", "task_id": "T-2026-07-14-001", "agent": "master", "phase": 0, "action": "fix-loop", "files_touched": [], "verdict": null, "notes": "re-dispatch am-coder for failed task"}
{"ts": "2026-07-14T11:05:00+00:00", "task_id": "T-2026-07-14-001", "agent": "am-coder", "phase": 3, "action": "complete", "files_touched": ["src/auth/login.test.ts"], "verdict": null, "notes": "added tests per review"}
{"ts": "2026-07-14T11:08:00+00:00", "task_id": "T-2026-07-14-001", "agent": "am-review", "phase": 4, "action": "complete", "files_touched": ["share/reports/04_review_T-2026-07-14-001_phase-1.md"], "verdict": "PASS", "notes": "all tasks pass"}
```

## How to query

```bash
# All anomalies for a task (the post-hoc debugging primary case)
grep '"action": "anomaly"' share/notes/00_trace_T-2026-07-14-001.jsonl

# All dispatches by master in the last 7 days
find share/notes -name '00_trace_*.jsonl' -mtime -7 \
  -exec grep '"agent": "master".*"action": "dispatch"' {} +

# All fix-loops in the project
grep -h '"action": "fix-loop"' share/notes/00_trace_*.jsonl | wc -l

# All FAIL verdicts
grep '"verdict": "FAIL"' share/notes/00_trace_*.jsonl

# Last 5 actions for a task
tail -5 share/notes/00_trace_T-2026-07-14-001.jsonl
```

## Lint

Run `scripts/validate-trace.sh` to check all `00_trace_*.jsonl` files in `share/notes/` against the schema. Exit 0 = clean, exit 1 = at least one issue.

## See also

- `docs/PERMISSIONS.md` — why the soft-wall model needs an audit trail
- `agents_manager/SKILL.md` (master) — the untrusted-content addendum
- Each specialist's SKILL.md — the untrusted-content clause + trace-log write note
- `scripts/append-trace.py` — the helper
