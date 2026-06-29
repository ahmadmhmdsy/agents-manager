# agents-manager

[![CI](https://github.com/ahmadmhmdsy/agents-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/ahmadmhmdsy/agents-manager/actions/workflows/ci.yml)
[![Release v0.7.0](https://img.shields.io/badge/release-v0.7.0-blue)](https://github.com/ahmadmhmdsy/agents-manager/releases/tag/v0.7.0)
[![License MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Upstream patch contributions](https://img.shields.io/badge/upstream-2%20patches-purple)](docs/UPSTREAM-CONTRIB.md)

> **Status:** v0.7.0 — early-stage. API may change between minor versions until v1.0.0.

A multi-agent task orchestration system built on [OpenCode](https://opencode.ai)'s agent system. One **master agent** routes work through four **specialist agents** (research → planning → coder → review), each with its own context window and a dedicated role.

## Table of contents

- [Why](#why)
- [At a glance](#at-a-glance)
- [Optional flags](#optional-flags)
- [What's new in v0.7.0](#whats-new-in-v070)
- [What's new in v0.6.0](#whats-new-in-v060)
- [Pipeline](#pipeline)
- [The five agents](#the-five-agents)
- [Permissions model](#permissions-model-v050--soft-walls)
- [Operational characteristics](#operational-characteristics-v051)
- [Quick start](#quick-start)
- [Examples](#examples)
- [Required user-level skills](#required-user-level-skills)
- [Usage](#usage)
- [Repo layout](#repo-layout)
- [FAQ](#faq)
- [Releases](#releases)
- [License](#license)
- [Status](#status)

## Why

Generic AI assistants collapse too many roles into a single chat: research, planning, coding, and review share context and bleed into each other. **agents-manager** enforces role separation through **separate context windows** + **soft walls declared in each agent's `SKILL.md`**. Each specialist:

- Runs in a fresh context window (no cross-contamination).
- Reads its `SKILL.md` boundaries (and the inline prompt's Can/Can't list) to decide what to do.
- Returns a file artifact (no out-of-band chat).
- Self-critiques before returning.

The master enforces `max_fix_loops = 3` and pauses for user confirmation between planning and build. In v0.5.0+, walls are soft contracts (prose + LLM discipline) rather than OpenCode permission-layer enforcement. See [`docs/PERMISSIONS.md`](docs/PERMISSIONS.md) for the rationale.

## At a glance

```
            ┌──────────────────┐
            │  master (orch.)  │
            │  routes + gates   │
            └────────┬─────────┘
                     │ task(subagent_type=…)
        ┌────────────┼────────────┬─────────────┐
        ▼            ▼            ▼             ▼
   ┌─────────┐  ┌──────────┐  ┌─────────┐  ┌──────────┐
   │research │  │ planning │  │  coder  │  │  review  │
   │ (R)     │  │ (P)      │  │ (C)     │  │ (R)      │
   └────┬────┘  └─────┬────┘  └────┬────┘  └────┬─────┘
        │            │            │            │
        ▼            ▼            ▼            ▼
   share/notes/01_   …02_      …03_         share/reports/04_
              ▲                                 │
              └────────── tasks/<id>.md ───────┘
                       (canonical task tracker)
```

**Bus:** `share/notes/`, `share/handoffs/`, `share/reports/`, `share/messages/` — inter-agent communication.

**Flags** (set in `tasks/<id>.md` header, see [Optional flags](#optional-flags)): `auto_accept_warns`, `git_initialized`, `phase_5_enabled`, `run_smoke_at_close`.

## Optional flags

Set in the `## Optional flags` block of `tasks/<task-id>.md`. Master sets these at Phase 0 Ingest; sub-agents read-only.

| Flag | Default | Set when | Effect |
|---|---|---|---|
| `auto_accept_warns: bool` | `false` | User says "I trust the triageable list" | Master auto-appends matching WARNs to register with `[auto-accepted triageable]` tag, no user prompt |
| `git_initialized: bool` | `false` | User accepts Phase 0 git-init prompt | Records whether master initialized git in this task |
| `phase_5_enabled: bool` | `false` | User wants next-steps prompt at task close | Master enters Phase 5 (auto-detects git vs non-git menu) |
| `run_smoke_at_close: bool` | `true` (when API key provided) | API key given in Phase 0 | Master runs `npm run smoke` in its own session at Phase 4 review time |

All flags default to safe values. Users opt in to enable features. Schema documented in [`tasks/README.md`](tasks/README.md) § Optional flags.

## What's new in v0.7.0

Three new features from the Part 2 upstream-contribution patch (chunk-size protocol, builds on v0.6.0):

- **Per-phase complexity estimation (planner)** — every phase in `02_plan_phases_<task-id>.md` gets a `### Complexity` block: novel abstractions, LOC/files estimates, review-difficulty word, split recommendation + reason. Hard triggers (LOC > 1200 OR files > 15 OR ≥2 novel abstractions) force `split_recommended: true`.
- **Master re-ask protocol at dispatch** — before dispatching am-coder, master reads the Complexity block; can re-ask planner ≤ 2× with concrete feedback; has final say. Each dispatch decision lands in `## Loop history` (appended to `tasks/<task-id>.md`) for auditability.
- **Phase productivity metric** — `tasks/README.md` Phase timings table gets `LOC written` + `WARNs` columns; new `## Phase productivity` block at close with LOC/WARN ratio as a sanity check, not a score.

Seed list for novel abstractions lives in [`agents_manager/planning/resources/novel-abstractions-seed-list.md`](agents_manager/planning/resources/novel-abstractions-seed-list.md) — extend it as you encounter new patterns (it lists 8 curated + a "NOT" list of patterns that look novel but aren't).

## What's new in v0.6.0

Six new features from an upstream-contribution patch ([`docs/UPSTREAM-CONTRIB.md`](docs/UPSTREAM-CONTRIB.md)), all opt-in by default:

- **WARN register** — `share/notes/04_warns_register_<task-id>.md` consolidates per-phase WARNs into one file, so the user is asked once at task close instead of once per phase.
- **Git-status + API-key preflight at Phase 0** — master asks about `git init` (default no) and external API keys (stored in gitignored `share/notes/02_secrets_*.md`).
- **Per-phase fix-loop counter** — `Fix-loops by phase: {P1: 0, P2: 0, ...}` + total in tasks/README.md.
- **Phase 5 non-git menu** — auto-detects git vs non-git at task close; sandbox projects get a 4-option menu (run smoke / polish WARNs / build follow-up / close out) instead of dead-branching on merge/PR.
- **Browser visual preflight** (opt-in when browser tools are available) — master takes screenshots before review for UI phases.
- **Optional flags** ([see table above](#optional-flags)) — `auto_accept_warns`, `git_initialized`, `phase_5_enabled`, `run_smoke_at_close`.

## Pipeline

```
USER TASK
   │
   ▼
[0] INGEST       ← master captures the task verbatim
   │
   ▼
[1] RESEARCH     ← am-research: analyze, doubt, surface unknowns
   │              ↓ may ask user clarifying questions
   ▼
[2] PLANNING     ← am-planning: phased plan + Complexity block per phase (v0.7.0+)
   │              ↓ master presents to user, waits for confirmation
   ▼
[3] BUILD        ← am-coder: implement assigned tasks, write summary
   │              ↓ master re-asks planner if Complexity triggers fire (v0.7.0+)
   │              ↓ browser visual preflight for UI phases (v0.6.0+)
   ▼
[4] REVIEW       ← am-review: per-task verdicts (PASS / WARN / FAIL)
   │
   ├── FAIL → loop to [3] with fix list (max 3 fix-loops)
   ├── plan-change-needed → loop to [2]
   ├── research-gap → loop to [1]
   └── all PASS → DONE
   │
   ▼
[5] NEXT-STEPS (optional)  ← v0.6.0+: auto-detects git vs non-git menu
                              v0.6.0+: optionally runs smoke test if API key provided
```

## The five agents

| Agent | Type | What it does | Hard wall (v0.5.0+ soft) |
|---|---|---|---|
| **master** | orchestrator | Routes work, gates on user confirmation, enforces `max_fix_loops = 3` | Cannot implement, plan, code, or review; only edits its own `agents_manager/SKILL.md` |
| **am-research** | specialist | Brainstorm, analyze, surface unknowns | Read-only — cannot write code or configs |
| **am-planning** | specialist | Phased plan + Complexity block + task table | No bash, no code edits |
| **am-coder** | specialist | Implement assigned tasks | Cannot edit other specialists' folders or controller config; only its own `agents_manager/coder/**` |
| **am-review** | specialist | Per-task verdicts with evidence | Cannot edit source code; tests only |

Walls are soft — enforced by each agent reading its `SKILL.md` boundaries + the inline prompt's Can/Can't list, not by OpenCode's permission layer. See [`docs/PERMISSIONS.md`](docs/PERMISSIONS.md) for the v0.5.0 architectural change rationale.

## Permissions model (v0.5.0+ — soft walls)

All 5 agents have `permission: "allow"` in `opencode.jsonc`. OpenCode's permission layer is **not used** to enforce walls. Each agent's `SKILL.md` declares its boundaries as a soft contract — the LLM is expected to honor them.

| Agent | Reads | Writes | Dispatches | Bash |
|---|---|---|---|---|
| **master** | anything | anything (own orchestration doc by convention) | all 4 specialists | read-only by convention |
| **am-research** | anything | anything (own folder by convention) | — | read-only by convention |
| **am-planning** | anything | anything (own folder by convention) | — | read-only by convention |
| **am-coder** | anything | anything (own folder by convention) | — | allow (full) |
| **am-review** | anything | anything (own folder by convention) | — | test commands by convention |

**Cross-agent coordination** goes through `share/messages/<from>-to-<to>-<topic>.md` (a free-form folder; the naming convention makes intent obvious — e.g. `research-to-planning-T-001-clarify.md`).

**Why soft walls?** The v0.4.0 → v0.4.1 era exposed several OpenCode permission-layer edge cases (write/edit dual-allow requirement, bash exact-match, silent task cancellation). Hard walls required continuous patching. v0.5.0 trades mechanical enforcement for simpler config and LLM-disciplined boundaries. If a downstream project finds soft walls insufficient, the architecture supports opt-in hard walls per agent — see [`docs/PERMISSIONS.md`](docs/PERMISSIONS.md).

For the v0.4.0 → v0.4.1 hard-wall era (now retired) and the discovered OpenCode behavior, see [`docs/PERMISSIONS.md`](docs/PERMISSIONS.md).

## Operational characteristics (v0.5.1+)

Each agent in `agents_manager/` follows two efficiency rules: **batch parallel reads when you know what to read, batch parallel edits when independent.** Only sequence when later edits depend on earlier or when discovery (grep/glob) is needed first. These rules apply to **this LLM** too — see [`CLAUDE.md`](CLAUDE.md). Full text + caveats (oldString uniqueness, context-window limit, discovery-then-read pattern) is in each agent's `SKILL.md` "Tool usage efficiency" section.

## Quick start

### Option A — git subtree (recommended for downstream projects with their own git history)

```bash
# In your target project's repo root:
git subtree add --prefix=agents-manager-src https://github.com/ahmadmhmdsy/agents-manager.git main --squash
# Then run the installer pointing at this dir:
./agents-manager-src/bin/install.sh .
```

### Option B — download a release ZIP

1. Go to <https://github.com/ahmadmhmdsy/agents-manager/releases>
2. Download the latest release ZIP (e.g. `agents-manager-v0.7.0.zip`)
3. Extract the controller files into your project root
4. Run `bash bin/install.sh .` from inside the extracted folder, OR manually copy `opencode.jsonc`, `CLAUDE.md`, `agents_manager/`, `share/`, `tasks/`, `.agents/skills/mavis-team/` into your project root.

### Option C — manual install

See [`docs/INSTALL.md`](docs/INSTALL.md) for the full procedure (PowerShell + Unix).

## Examples

Three worked examples live in [`examples/`](examples/):

- **`examples/node-markdown-linter/`** — full pipeline trace for "add a no-consecutive-h1 rule" task. Includes `original/` (starting state), `user-task.md`, full `share/` artifacts (00–04), `tasks/T-2026-06-28-001.md`, and `expected-output/` (rule + 5 new tests). **Canonical demonstration** of the agents-manager pipeline end-to-end.
- **`examples/python-csv-summarizer/`** — compact example for "add a `mean` aggregation alongside `sum` and `count`". Demonstrates the Python/pytest loop.
- **`examples/docs-restructure/`** — pure-markdown example (no source code). Demonstrates Phases 1+2+4 without Phase 3 (no code to write).

See [`examples/README.md`](examples/README.md) for the index + how to replay.

## Required user-level skills

After installing the controller, install these skills on your machine (user-level, not project):

```bash
npx --yes skills add https://github.com/obra/superpowers --skill dispatching-parallel-agents -g -y
npx --yes skills add https://github.com/obra/superpowers --skill subagent-driven-development -g -y
npx --yes skills add https://github.com/obra/superpowers --skill verification-before-completion -g -y
npx --yes skills add https://github.com/obra/superpowers --skill systematic-debugging -g -y
npx --yes skills add https://github.com/obra/superpowers --skill test-driven-development -g -y
npx --yes skills add https://github.com/obra/superpowers --skill requesting-code-review -g -y
npx --yes skills add https://github.com/obra/superpowers --skill writing-plans -g -y
npx --yes skills add https://github.com/obra/superpowers --skill executing-plans -g -y
npx --yes skills add https://github.com/obra/superpowers --skill brainstorming -g -y
```

Verify your install: `bash bin/check.sh .`

The install scripts support `--dry-run` (preview without writing) and `--uninstall` (remove the controller). For full script documentation, see [`bin/README.md`](bin/README.md). PowerShell parity via `.\bin\install.ps1 -Target <path>`.

## Usage

Once installed, open your project in OpenCode and describe your task. The `master` agent auto-routes to specialists based on your request. See [`agents_manager/SKILL.md`](agents_manager/SKILL.md) for the full orchestration protocol and [`agents_manager/README.md`](agents_manager/README.md) for the system overview.

## Repo layout

```
agents-manager/
├── README.md                       ← this file (GitHub landing)
├── LICENSE                         ← MIT
├── opencode.jsonc                  ← 5 agents + permission blocks
├── CLAUDE.md                       ← auto-routing rule
├── agents_manager/                 ← controller (master + 4 specialists)
├── share/                          ← inter-agent bus (handoffs / notes / reports)
├── tasks/                          ← task tracker
├── examples/                       ← 3 worked pipeline traces
├── agents_manager/upstream-contrib/← MiniMax-M3 contribution patches (v0.6.0 + v0.7.0)
├── .agents/skills/mavis-team/      ← OpenCode-discoverable skill
├── bin/                            ← install + check scripts
├── docs/                           ← installation, permissions, attribution
└── tasks/T-...md                   ← per-task tracker files
```

## FAQ

### Why soft walls instead of hard permission-layer walls?

The v0.4.0 → v0.4.1 era exposed three OpenCode permission-layer edge cases (write/edit dual-allow requirement, bash exact-match, silent task cancellation). Hard walls required continuous patching as OpenCode evolved. v0.5.0 trades mechanical enforcement for simpler config and LLM-disciplined boundaries. If a downstream project needs hard walls, see [`docs/PERMISSIONS.md`](docs/PERMISSIONS.md) for the opt-in procedure.

### Can I install agents-manager into a nested directory (e.g., `tools/agents-manager/`)?

No — not in v0.7.0. The OpenCode permission-layer globs in `opencode.jsonc` are root-relative (e.g., `share/**`, `tasks/**`). They resolve against the project root, not the install directory. Nesting breaks the path resolution. **Root-level install only** is supported.

### How do I add a 6th agent?

1. Add the agent block to `opencode.jsonc` (use existing 5 as templates).
2. Create `agents_manager/<role>/SKILL.md` + `rules.md` + `notes/` + `resources/`.
3. Reference it from `agents_manager/SKILL.md` master prompt + dispatch contract.
4. Add it to the master's `task` permission allowlist.
5. Update the "five agents" tables in this README.

See `agents_manager/SKILL.md` for the role definition pattern + each existing `SKILL.md` for the boundary + output template pattern.

### How do I migrate from a hard-wall install (v0.4.x) to soft-wall (v0.5.0+)?

The permission block shape changed. v0.4.x used `{ edit: {...}, write: {...}, bash: {...}, task: {...}, ... }`; v0.5.0+ uses `"permission": "allow"`. To upgrade:
1. Replace each agent's `permission` block with `"permission": "allow"`.
2. Move the per-path restrictions from JSON into prose in each `SKILL.md` "Boundaries" section.
3. Run `bin/check.sh .` to verify.

The `agents_manager/SKILL.md` + `docs/PERMISSIONS.md` document the new architecture. Hard walls can be opted back in per agent.

### What's the difference between `share/notes/`, `share/messages/`, and `share/handoffs/`?

| Folder | Convention | Used by |
|---|---|---|
| `share/notes/01_research_<task-id>.md` | Phase 1 research output | am-research |
| `share/notes/02_plan_high_<task-id>.md`, `02_plan_phases_<task-id>.md` | Phase 2 plan output | am-planning |
| `share/notes/03_coder_summary_<task-id>_<phase>.md` | Phase 3 coder output | am-coder |
| `share/notes/04_warns_register_<task-id>.md` (v0.6.0+) | Consolidated WARN log | master + am-review |
| `share/notes/99_progress_<task-id>.md` | Master recovery ledger | master |
| `share/messages/<from>-to-<to>-<topic>.md` | Cross-agent notes (free-form) | any agent |
| `share/handoffs/00_user_task.md` | Captured user task | master (Phase 0 Ingest) |
| `share/reports/04_review_<task-id>_<phase>.md` | Phase 4 review output | am-review |

### Can I use agents-manager in a non-git project (sandbox / exploration)?

Yes — v0.6.0+ detects git vs non-git at Phase 5 and offers a 4-option menu for non-git projects (run smoke / polish WARNs / build follow-up / close out). Phase 0 also asks before `git init`-ing (default no).

### What if my downstream project finds soft walls insufficient?

Per-agent opt-in: set one agent's `permission` back to a hard-wall block (copy from `agents_manager/upstream-contrib/PROPOSED_PATCH_v0.5.x_2026-06-29.md` historical pattern). The architecture supports mixed soft + hard per agent. See [`docs/PERMISSIONS.md`](docs/PERMISSIONS.md) § When to opt back into hard walls.

## Releases

| Version | Date | Theme | Highlights |
|---|---|---|---|
| **v0.7.0** | 2026-06-29 | Chunk-size protocol | Per-phase complexity estimation + master re-ask + Phase productivity metric |
| **v0.6.0** | 2026-06-29 | WARN register + preflights | WARN consolidation, git/API preflight, Phase 5 non-git menu, browser preflight |
| **v0.5.1** | 2026-06-28 | Tool usage efficiency | Batch parallel reads + edits rules (applies to this LLM too) |
| **v0.5.0** | 2026-06-28 | Soft-wall architecture | All agents `permission: "allow"`; boundaries become soft contracts |
| **v0.4.1** | 2026-06-28 | Permission-layer fixes | Belt-and-suspenders, bash prefix globs, Phase 0 preflight |
| **v0.4.0** | 2026-06-28 | Permission rewrite | Broader share + own-folder writes |
| **v0.3.0** | 2026-06-28 | Examples + maintenance | 3 worked examples + obra-sync workflow |
| **v0.2.0** | 2026-06-28 | Tier 3 skills | Brainstorming, executing-plans, finishing-a-development-branch |
| **v0.1.0** | 2026-06-28 | First public release | README, LICENSE, install/check scripts, INSTALL.md |

Two of these releases (v0.6.0 + v0.7.0) were upstream-contribution patches from a downstream consumer. See [`docs/UPSTREAM-CONTRIB.md`](docs/UPSTREAM-CONTRIB.md) for attribution + decision log, and [`agents_manager/upstream-contrib/`](agents_manager/upstream-contrib/) for the full patch text.

## License

MIT — see [`LICENSE`](LICENSE).

## Status

**v0.7.0** is the latest release. The controller is functional and tested on 2 downstream projects (1 with full end-to-end run). Known scope:

- API may change between minor versions until v1.0.0.
- `git subtree` and manual ZIP install paths are both battle-tested.
- Window-specific path assumptions (root-relative globs) require a **root-level install** — nesting under `tools/` etc. is not supported.
- Soft walls rely on LLM discipline; opt back into hard walls per agent if your project requires mechanical enforcement.

See [`agents_manager/CHANGELOG.md`](agents_manager/CHANGELOG.md) for full change history.