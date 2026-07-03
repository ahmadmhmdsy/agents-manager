# AGENTS.md — context_gen

This repo IS the **agents-manager controller**: an OpenCode multi-agent orchestration system. 6 specialist agents are defined in `opencode.jsonc`. Walls are enforced by prose (v0.5.0+ soft walls — every agent has `permission: "allow"`), not by OpenCode's permission layer.

## Pipeline

```
master -> am-research -> am-planning -> am-design -> am-coder -> am-review
```

- **master** orchestrates ONLY. Never codes, plans, designs, or reviews directly.
- **Specialists never spawn other specialists.** Only master orchestrates.
- All inter-agent communication goes through files in `share/`. No out-of-band chat.
- Review reports must be brutally honest. False PASS ships bugs; false FAIL just costs a fix loop.
- Master runs a 5-question preflight before dispatching any specialist.

## Auto-routing

- Multi-step work (research -> plan -> build -> review) -> spawn master via `task(subagent_type="master", prompt="...")`.
- Single-step work (quick edit, one-off question) -> do it directly. No master needed.

## Hard rules

- **Do NOT commit unless explicitly asked.** Project convention; commits are user-driven.
- **Do NOT skip the review phase** because "it looks fine."
- **Do NOT accept the first review report without reading it.**
- **max_fix_loops = 3.** Cap on review -> fix -> re-review cycles; surface to user after.
- **Do NOT edit `agents_manager/<role>/SKILL.md`** unless explicitly redesigning the controller.
- **v0.9.0+**: `am-design` never writes `src/**`; reference implementations are `am-coder`'s job.

## Per-agent output paths ("Owns" column)

| Agent | Primary output destination |
|---|---|
| master | `share/handoffs/`, `share/notes/99_decisions.md`, `tasks/` |
| am-research | `share/notes/01_research_*.md` |
| am-planning | `share/notes/02_plan_*.md`, `tasks/<id>.md` rows |
| am-design | `share/design/<task-id>/**` |
| am-coder | source code, `share/notes/03_coder_summary_*.md` |
| am-review | `share/reports/04_review_*.md` |

In v0.5.0+ any agent can technically read/write anywhere (`permission: "allow"`); the convention is to write only to the listed paths unless coordination requires more.

## Task tracking

- ID format: `T-YYYY-MM-DD-NNN`. One file per id in `tasks/`.
- Phase log + sub-task rows live in `tasks/<id>.md`.
- Each phase writes its own handoff/summary/report file (see "Owns" column above).

## Controller dispatchers (v0.11.0+)

Three install paths for putting agents-manager into a target project:

- `bin/agents-manager` (bash) — reads manifest via inline Python3
- `bin/agents-manager.ps1` (PowerShell) — reads manifest via `ConvertFrom-Json`
- `bin/agents-manager.py` (Python UX) — single dialect, stdlib only, recommended

All three accept `--global/--local/--both/--skip` on `skills add` (v0.11.0). Default scope = `both` (honors per-skill source).

## Standalone installer (downloads alone, runs anywhere)

`bin/standalone-installer/install.{py,sh,cmd}` + `README.md`. Downloads latest release from GitHub API, extracts to temp, runs bundled installer, cleans up. Stdlib only.

## Lint / verify

```bash
# Bash (file is CRLF on Windows working tree; convert first)
npx --yes shellcheck <(python3 -c "open('bin/agents-manager','rb').read().replace(b'\r\n',b'\n').decode().encode()")

# PowerShell
pwsh -NoProfile -Command "Invoke-ScriptAnalyzer -Path bin/agents-manager.ps1"

# Python
python3 -m py_compile bin/agents-manager.py bin/install.py bin/standalone-installer/install.py

# Frontmatter (controller files)
python3 scripts/validate-frontmatter.py
```

There are no tests for `bin/` scripts — only `scripts/validate-frontmatter.py`. CI runs on `ubuntu-latest` only, so `.cmd` scripts can't be CI-linted; use the manual smoke checklist in CHANGELOG / plan files instead.

## EOL

`.gitattributes` rules: `*.sh text eol=lf`, `*.ps1 text eol=crlf`, `*.cmd text eol=crlf`, `*.bat text eol=crlf`, `*.json/yaml/md text eol=lf`. Windows working tree may show CRLF due to `core.autocrlf=true`; git normalizes on commit.

## Reading order for a new session

1. `CLAUDE.md` — top-level orientation + auto-routing rule
2. `opencode.jsonc` — agent definitions
3. `agents_manager/SKILL.md` — master orchestration protocol
4. `agents_manager/<role>/SKILL.md` — for any specialist you dispatch
5. `agents_manager/CHANGELOG.md` — system evolution (read latest entry first)
6. `share/notes/02_plan_*.md` + `tasks/<id>.md` — current in-flight work

## Tool usage efficiency (v0.5.1+)

### Read workflow
- **Discovery first, read second.** When you don't know what files exist, use `glob` (by pattern) or `grep` (by content) to find them. Read in parallel only AFTER you know which files you need.
- **Batch parallel reads when files are known.** A folder analysis that surfaces N files to read → issue all N `read` calls in one message, not N messages.
- **Use `offset`/`limit` for large files** (>2000 lines). Reserve full reads for files you genuinely need in one piece.
- **Re-read or re-grep after edits.** Edits shift line numbers; the next edit's `oldString` may no longer match.

### Edit workflow
- **A `read` precedes every `edit` batch** (tool contract). Read once, then issue all edits in a single message.
- **Batch parallel `edit` calls** when independent. Sequence only when later edits depend on earlier (line shifts, shared mutating context).
- **Use `write` for full-file replacement** (new files, full rewrites). `edit` is for surgical changes only.
- **Verify `oldString` uniqueness across the batch** before issuing. Silent collisions are the #1 edit-batch failure mode.
- **Verify once after the batch completes**, not mid-batch.

### Other parallelism (when in doubt, batch)
- `bash`: multiple independent commands → one message with multiple tool calls.
- `glob` + `grep`: often worth batching together — pattern search + content search in one message.
- `task` (subagent dispatch): NOT batchable. Only `master` dispatches subagents per pipeline rule.