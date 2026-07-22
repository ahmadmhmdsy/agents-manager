# AGENTS.md — context_gen

This repo IS the **agents-manager controller**: an OpenCode multi-agent orchestration system. 9 specialist agents are defined in `opencode.jsonc` (master + research + planning + design + assets + coder + review + investigate + ship + health). Walls are enforced by prose (v0.5.0+ soft walls — every agent has `permission: "allow"`), not by OpenCode's permission layer.

**Working in this repo:** when the task is to edit the controller itself (a specialist's `SKILL.md`, a release, a controller bug), edit directly — do NOT spawn the `master` agent. Master is for downstream projects that have installed the controller. The same hard rules still apply (no auto-commits, no skipping review, no editing other specialists' `SKILL.md` unless it's a deliberate controller redesign).

## Pipeline (default shape — v0.16.0+ adaptive)

```
master -> am-research -> am-planning -> [am-assets if visual template] -> am-design + am-coder (parallel) -> am-review
                                                            |                            |
                                                            v                            v
                                                  [am-investigate]  <--- recommended by am-review for CRITICAL/HIGH
                                                            |
                                                            v
                                                       am-coder (fix)
                                                            |
                                                            v
                                                       am-review (re-validate)
                                                            |
                                                            v
                                                       am-ship (release)
                                                       am-health (score)
```

- **master** orchestrates ONLY. Never codes, plans, designs, or reviews directly.
- **Specialists never spawn other specialists.** Only master orchestrates.
- All inter-agent communication goes through files in `share/`. No out-of-band chat.
- Review reports must be brutally honest. False PASS ships bugs; false FAIL just costs a fix loop.
- Master runs a 5-question preflight before dispatching any specialist.
- `am-assets` is dispatched at **Phase 3a** (between Planning and Build) only when the task uses a visual template that declares assets in its frontmatter AND no `assets/MANIFEST.json` exists yet. v0.16.0+ allows `am-design` and `am-coder` to run in parallel.
- `am-investigate` is dispatched when am-review's report includes a `## Recommend am-investigate` block (CRITICAL/HIGH findings with unclear cause) OR when the user reports a bug directly.
- `am-ship` is dispatched at Phase 5 release when the user says "ship" / "release" / "tag". Runs validation + VERSION bump + CHANGELOG block + tag + push. Idempotent.
- `am-health` is dispatched on demand ("is this healthy?" / "run all checks") or at Phase 5 close when health tracking is enabled. Report-only — never fixes.
- `agents_manager/extract/` is a non-roster on-demand skill (loaded by any specialist for "extract this to a template" requests). It is **not** registered in `opencode.jsonc`.

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
| am-planning | `share/notes/02_plan_*.md`, `tasks/<id>.md` rows; v0.17.0+ also writes `share/notes/02_plan_review_*.md` for plan-mode review angles (plan-ceo / plan-eng / plan-design / plan-devex) |
| am-design (v0.9.0+) | `share/design/<task-id>/**` |
| am-assets (v0.9.0+, Phase 3a) | `assets/MANIFEST.json`, `share/notes/03a_assets_*.md`, `share/handoffs/03a_assets-to-coder-*.md` |
| am-coder | source code, `share/notes/03_coder_summary_*.md` |
| am-review | `share/reports/04_review_*.md`; v0.18.0+ also writes `## Recommend am-investigate` blocks when findings need root-cause work |
| am-investigate (v0.18.0+) | `share/notes/04_investigate_*.md` |
| am-ship (v0.18.0+) | `share/notes/05_ship_*.md`; edits `VERSION` + `agents_manager/CHANGELOG.md` |
| am-health (v0.18.0+) | `share/health/<date>.json` + `share/notes/05_health_*.md` |

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

## Releases (tag-driven, fully automated)

1. Add a `## vX.Y.Z — <theme> (YYYY-MM-DD)` block to `agents_manager/CHANGELOG.md` (newest on top) **before** tagging. The release workflow extracts this block as the GitHub Release notes; without it the release body is a placeholder.
2. `git tag -a vX.Y.Z -m "vX.Y.Z: <one-line>"` then `git push origin vX.Y.Z`. `release.yml` builds the ZIP from a fixed allowlist (`opencode.jsonc`, `CLAUDE.md`, `agents_manager`, `share`, `tasks`, `.agents/skills/mavis-team`, `bin`) and runs a 3-step gh-api dance (create→PATCH→upload) to dodge an HTTP 500 quirk on the initial POST when `name`/`body` are set.
3. Release appears in <2 min at `https://github.com/<owner>/agents-manager/releases/tag/vX.Y.Z`.

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