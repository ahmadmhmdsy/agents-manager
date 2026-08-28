---
scope: repo-wide
audience: maintainers
topic: project-audit-index
status: active
created: 2026-08-28
last_verified: 2026-08-28
version: 1.0.0
description: Index of project audits. Each audit is a point-in-time read-only inspection. The latest audit is canonical; older audits are archived for diff-comparison.
---

# Project Audits — Index

Point-in-time, read-only inspections of the `agents-manager` controller. Each audit enumerates findings classified by severity (CRITICAL / HIGH / MEDIUM / LOW) and recommends a "Top 5 to fix first" list.

## Latest

| Date | File | Project version | Findings |
|---|---|---|---|
| 2026-08-28 | [`AUDIT_2026-08-28.md`](./AUDIT_2026-08-28.md) | v0.24.0 | 5 CRITICAL · 7 HIGH · 18 MEDIUM · 20 LOW |
| 2026-08-28 | [`AUDIT_2026-08-28_PROMPT_GAP_ANALYSIS.md`](./AUDIT_2026-08-28_PROMPT_GAP_ANALYSIS.md) | v0.24.0 | Specialist prompts cover ~7% of reference operating principles (12 concepts × 10 agents = 120 cells; only 3 covered) |

## How to read

- Each finding has an ID (`C1`, `H2`, `M3`, `L5`, etc.) for cross-reference in PRs and tickets.
- Each finding has a **File:** pointer and a one-line **Fix:** recommendation.
- "Top 5 to fix first" is the recommended starting point — typically high-impact, low-effort items.
- "Audit metadata" at the bottom records the inspection method (read-only) and tools used (`glob`, `grep`, `read`, `pwsh`).

## When to re-audit

Re-run a full audit when **any** of:

- The project crosses a minor version boundary (e.g. v0.24.0 → v0.25.0).
- A new specialist role is added to `opencode.jsonc`.
- The CI workflow changes structurally (new job, removed job, matrix runner added).
- A new template ships under `templates/<new-name>/`.
- The dispatcher surface (subcommands in `bin/agents-manager`) changes.
- A major refactor lands (e.g. chub-gate replaced, memory protocol rewritten).

A lighter spot-check is fine in between: read one or two of the previously-flagged files to confirm they were addressed.

## Conventions

- Audit filename pattern: `AUDIT_YYYY-MM-DD.md` (date of inspection, not of project version).
- Findings are stable IDs within a single audit file — they are NOT stable across audits. Re-numbering is expected when the file is regenerated.
- Severity uses 🚨 CRITICAL / 🔥 HIGH / ⚠️ MEDIUM / 🔍 LOW.
- "Read-only inspection" means: no source modifications are made during the audit. The audit is a snapshot, not a fix.

## See also

- [`docs/MAINTENANCE.md`](./MAINTENANCE.md) — recurring maintenance checklist (quarterly, per-release, per-template-add)
- [`docs/UPSTREAM-CONTRIB.md`](./UPSTREAM-CONTRIB.md) — how to ship patches upstream to obra/superpowers etc.
- [`agents_manager/CHANGELOG.md`](../agents_manager/CHANGELOG.md) — release history (audit cross-references can land here as "vX.Y.Z closes N findings from AUDIT_YYYY-MM-DD")
- [`AUDIT_2026-08-28_PROMPT_GAP_ANALYSIS.md`](./AUDIT_2026-08-28_PROMPT_GAP_ANALYSIS.md) — companion: specialist prompts vs a stronger reference