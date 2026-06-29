# agents-manager

[![CI](https://github.com/ahmadmhmdsy/agents-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/ahmadmhmdsy/agents-manager/actions/workflows/ci.yml)

> **Status:** v0.7.0 — early-stage. API may change between minor versions until v1.0.0.

A multi-agent task orchestration system built on [OpenCode](https://opencode.ai)'s agent system. One **master agent** routes work through four **specialist agents** (research → planning → coder → review), each with its own context window and a dedicated role.

## Why

Generic AI assistants collapse too many roles into a single chat: research, planning, coding, and review share context and bleed into each other. **agents-manager** enforces role separation through **separate context windows** + **soft walls declared in each agent's `SKILL.md`**. Each specialist:

- Runs in a fresh context window (no cross-contamination).
- Reads its `SKILL.md` boundaries (and the inline prompt's Can/Can't list) to decide what to do.
- Returns a file artifact (no out-of-band chat).
- Self-critiques before returning.

The master enforces `max_fix_loops = 3` and pauses for user confirmation between planning and build. In v0.5.0+, walls are soft contracts (prose + LLM discipline) rather than OpenCode permission-layer enforcement. See `docs/PERMISSIONS.md` for the rationale.

## What's new in v0.6.0

Six new features from an upstream-contribution patch (`docs/UPSTREAM-CONTRIB.md`), all opt-in by default:

- **WARN register** — `share/notes/04_warns_register_<task-id>.md` consolidates per-phase WARNs into one file, so the user is asked once at task close instead of once per phase.
- **Git-status + API-key preflight at Phase 0** — master asks about `git init` (default no) and external API keys (stored in gitignored `share/notes/02_secrets_*.md`).
- **Per-phase fix-loop counter** — `Fix-loops by phase: {P1: 0, P2: 0, ...}` + total in tasks/README.md.
- **Phase 5 non-git menu** — auto-detects git vs non-git at task close; sandbox projects get a 4-option menu (run smoke / polish WARNs / build follow-up / close out) instead of dead-branching on merge/PR.
- **Browser visual preflight** (opt-in when browser tools are available) — master takes screenshots before review for UI phases.
- **Optional flags** (`auto_accept_warns`, `git_initialized`, `phase_5_enabled`, `run_smoke_at_close`) — task tracker header.

## What's new in v0.7.0

Three new features from the Part 2 upstream-contribution patch (chunk-size protocol, builds on v0.6.0):

- **Per-phase complexity estimation (planner)** — every phase in `02_plan_phases_<task-id>.md` gets a `### Complexity` block: novel abstractions, LOC/files estimates, review-difficulty word, split recommendation + reason. Hard triggers (LOC > 1200 OR files > 15 OR ≥2 novel abstractions) force `split_recommended: true`.
- **Master re-ask protocol at dispatch** — before dispatching am-coder, master reads the Complexity block; can re-ask planner ≤ 2× with concrete feedback; has final say. Each dispatch decision lands in `## Loop history` (appended to `tasks/<task-id>.md`) for auditability.
- **Phase productivity metric** — `tasks/README.md` Phase timings table gets `LOC written` + `WARNs` columns; new `## Phase productivity` block at close with LOC/WARN ratio as a sanity check, not a score.

Seed list for novel abstractions lives in `agents_manager/planning/resources/novel-abstractions-seed-list.md` — extend it as you encounter new patterns (it lists 8 curated + a "NOT" list of patterns that look novel but aren't).

## Operational characteristics (v0.5.1+)

Each agent in `agents_manager/` follows two efficiency rules: **batch parallel reads when you know what to read, batch parallel edits when independent.** Only sequence when later edits depend on earlier or when discovery (grep/glob) is needed first. These rules apply to **this LLM** too — see `CLAUDE.md`. Full text + caveats (oldString uniqueness, context-window limit, discovery-then-read pattern) is in each agent's `SKILL.md` "Tool usage efficiency" section.

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
[2] PLANNING     ← am-planning: phased plan + task table
   │              ↓ master presents to user, waits for confirmation
   ▼
[3] BUILD        ← am-coder: implement assigned tasks, write summary
   │
   ▼
[4] REVIEW       ← am-review: per-task verdicts (PASS / WARN / FAIL)
   │
   ├── FAIL → loop to [3] with fix list
   ├── plan-change-needed → loop to [2]
   ├── research-gap → loop to [1]
   └── all PASS → DONE
```

## The five agents

| Agent | Type | What it does | Hard wall |
|---|---|---|---|
| **master** | orchestrator | Routes work, gates on user confirmation, enforces `max_fix_loops = 3` | Cannot implement, plan, code, or review; only edits its own `agents_manager/SKILL.md` |
| **am-research** | specialist | Brainstorm, analyze, surface unknowns | Read-only — cannot write code or configs |
| **am-planning** | specialist | Phased plan + task table | No bash, no code edits |
| **am-coder** | specialist | Implement assigned tasks | Cannot edit other specialists' folders or controller config; only its own `agents_manager/coder/**` |
| **am-review** | specialist | Per-task verdicts with evidence | Cannot edit source code; tests only |

Walls are soft — enforced by each agent reading its `SKILL.md` boundaries + the inline prompt's Can/Can't list, not by OpenCode's permission layer. See `docs/PERMISSIONS.md` for the v0.5.0 architectural change rationale.

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

**Why soft walls?** The v0.4.0 → v0.4.1 era exposed several OpenCode permission-layer edge cases (write/edit dual-allow requirement, bash exact-match, silent task cancellation). Hard walls required continuous patching. v0.5.0 trades mechanical enforcement for simpler config and LLM-disciplined boundaries. If a downstream project finds soft walls insufficient, the architecture supports opt-in hard walls per agent — see `docs/PERMISSIONS.md`.

The full Can/Can't/When-fails sections for every agent are in each `agents_manager/<role>/SKILL.md`. Each SKILL.md has a `## Boundaries (soft walls)` section that the LLM is expected to honor.

For the v0.4.0 → v0.4.1 hard-wall era (now retired) and the discovered OpenCode behavior, see [`docs/PERMISSIONS.md`](docs/PERMISSIONS.md).

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
2. Download `agents-manager-v0.1.0.zip`
3. Extract the controller files into your project root
4. Run `bash bin/install.sh .` from inside the extracted folder, OR manually copy `opencode.jsonc`, `CLAUDE.md`, `agents_manager/`, `share/`, `tasks/`, `.agents/skills/mavis-team/` into your project root.

### Option C — manual install

See [`docs/INSTALL.md`](docs/INSTALL.md).

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
├── .agents/skills/mavis-team/      ← OpenCode-discoverable skill
├── bin/                            ← install + check scripts
└── docs/                           ← installation guide
```

## License

MIT — see [`LICENSE`](LICENSE).

## Status

**v0.1.0** is the first public release. The controller is functional and tested locally, but:
- API may change between minor versions.
- Only `git subtree` install path is battle-tested.
- Window-specific path assumptions (root-relative globs) require a **root-level install** — nesting under `tools/` etc. is not supported.

See [`agents_manager/CHANGELOG.md`](agents_manager/CHANGELOG.md) for full change history.
