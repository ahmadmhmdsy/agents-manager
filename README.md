# agents-manager

[![CI](https://github.com/ahmadmhmdsy/agents-manager/actions/workflows/ci.yml/badge.svg)](https://github.com/ahmadmhmdsy/agents-manager/actions/workflows/ci.yml)

> **Status:** v0.4.0 — early-stage. API may change between minor versions until v1.0.0.

A multi-agent task orchestration system built on [OpenCode](https://opencode.ai)'s agent system. One **master agent** routes work through four **specialist agents** (research → planning → coder → review), each with its own context window and hard permission walls.

## Why

Generic AI assistants collapse too many roles into a single chat: research, planning, coding, and review share context and bleed into each other. **agents-manager** enforces role separation at the **OpenCode permission layer** — not by prose. Each specialist:

- Runs in a fresh context window (no cross-contamination).
- Has a permission block that physically blocks forbidden tools.
- Returns a file artifact (no out-of-band chat).
- Self-critiques before returning.

The master enforces `max_fix_loops = 3` and pauses for user confirmation between planning and build. Specialists cannot escape their lanes.

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

Walls are enforced in `opencode.jsonc` via `permission` blocks.

## Permissions model

Every agent has a **hard permission wall** declared in `opencode.jsonc`. The wall is enforced by OpenCode *before* the agent's prompt is consulted — if an agent tries to write outside its lane, the tool call is rejected and the agent is told.

| Agent | Reads | Writes | Dispatches | Bash |
|---|---|---|---|---|
| **master** | anything | `share/**`, `tasks/**`, `agents_manager/SKILL.md` (own only) | all 4 specialists | read-only |
| **am-research** | anything | `share/**`, `agents_manager/research/**` | — | read-only |
| **am-planning** | anything | `share/**`, `tasks/**`, `agents_manager/planning/**` | — | deny |
| **am-coder** | anything | `share/**`, source files, `agents_manager/coder/**` | — | allow |
| **am-review** | anything | `share/**`, `agents_manager/review/**` | — | test commands only |

**Cross-agent coordination** goes through `share/messages/<from>-to-<to>-<topic>.md` (a free-form folder; the naming convention makes intent obvious — e.g. `research-to-planning-T-001-clarify.md`).

**Last-match-wins on globs:** in `am-coder`'s block, `agents_manager/**` is denied first, then `agents_manager/coder/**` is explicitly allowed — the allow wins because it comes last. This is how the coder can maintain its own `notes/` + `resources/` without editing other specialists' folders.

**Every agent follows the same "when blocked" protocol:**
1. Do **NOT** retry — the block is intentional.
2. Do **NOT** work around it (no filename tricks, no copying-and-renaming).
3. Do **NOT** pretend the edit succeeded.
4. **CONTINUE** with what you CAN do (write to your allowed paths only).
5. **SURFACE** the block in your return line: `BLOCKED: tried to <X>, permission denied — route to master`.

The full Can/Can't/When-blocked sections for every agent are in each `agents_manager/<role>/SKILL.md`.

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
