# Installation Guide

Three ways to install `agents-manager` into a target project. Pick whichever matches your workflow.

## Prerequisites

Before installing, make sure you have:

1. **OpenCode CLI** installed and on your PATH. See <https://opencode.ai/docs/>.
2. **Bun** runtime (OpenCode dependency). See <https://bun.sh/>.
3. **Node.js + npx** (for `npx skills add`).
4. **git** (for Option A and most workflows).

## Option A — git subtree (recommended for downstream projects with their own git history)

```bash
# In your target project's repo root:
git subtree add --prefix=agents-manager-src \
  https://github.com/ahmadmhmdsy/agents-manager.git main --squash

# Then run the installer pointing at your project root:
bash agents-manager-src/bin/install.sh .
```

This gives you a flat copy of the controller files at known paths and keeps a link to the upstream repo for future `git subtree pull` updates.

To update later:

```bash
git subtree pull --prefix=agents-manager-src \
  https://github.com/ahmadmhmdsy/agents-manager.git main --squash
```

## Option B — download a release ZIP (no git dependency)

1. Visit <https://github.com/ahmadmhmdsy/agents-manager/releases>
2. Download the latest `agents-manager-vX.Y.Z.zip`
3. Extract the archive anywhere (e.g., `~/Downloads/agents-manager/`)
4. Run the installer from the extracted folder into your target project:

   ```bash
   # macOS / Linux
   bash ~/Downloads/agents-manager/bin/install.sh /path/to/your-project

   # Windows (PowerShell)
   .\Downloads\agents-manager\bin\install.ps1 -Target C:\path\to\your-project
   ```

The installer copies only the controller files (`opencode.jsonc`, `CLAUDE.md`, `agents_manager/`, `share/`, `tasks/`, `.agents/skills/mavis-team/`) into your target. It will **skip** any file or directory that already exists, so it's safe to re-run.

## Option C — manual copy

If you prefer to copy files yourself, you need exactly these 6 paths:

| Source (from this repo) | Destination (in your project root) |
|---|---|
| `opencode.jsonc` | `./opencode.jsonc` |
| `CLAUDE.md` | `./CLAUDE.md` |
| `agents_manager/` | `./agents_manager/` |
| `share/` | `./share/` |
| `tasks/` | `./tasks/` |
| `.agents/skills/mavis-team/` | `./.agents/skills/mavis-team/` |

All paths are relative to the **project root**. agents-manager does not currently support being nested under another directory (e.g., `tools/agents-manager/`).

## Install required user-level skills

After the controller files are in place, install the 9 OpenCode skills the controller references. These are installed at the user level (`~/.agents/skills/`), not per-project.

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

These are all from the [obra/superpowers](https://github.com/obra/superpowers) project. `-g` installs to `~/.agents/skills/` (user-level). `-y` skips confirmation prompts.

## Verify the install

Run the check script from your project root:

```bash
# macOS / Linux
bash path/to/agents-manager/bin/check.sh .

# Windows
.\path\to\agents-manager\bin\check.ps1
```

Expected output: every line shows `OK`. If anything shows `MISS`, follow the suggested command.

## Open in OpenCode

Once the install is verified, open your project in OpenCode:

```bash
cd /path/to/your-project
opencode   # or your platform's launcher
```

The `master` agent is auto-routed per `CLAUDE.md`. Describe your task in plain language; the master will route to the appropriate specialist.

## Troubleshooting

### "OpenCode can't find my agents"

Make sure `opencode.jsonc` is at your project root, not nested. The OpenCode loader reads it from the working directory.

### "Permission denied" errors during agent runs

Some shells / filesystems need the agent's allowed paths to be writable. The default `permission` blocks in `opencode.jsonc` allow writes to `share/**` and `tasks/**` at the project root. If you've nested the controller, update the glob patterns in `opencode.jsonc` accordingly.

### "Skill not found" warnings

The check script will list which user-level skills are missing. Run the suggested `npx skills add` command.

### Updating from a previous version

- **From git subtree:** `git subtree pull --prefix=agents-manager-src https://github.com/ahmadmhmdsy/agents-manager.git main --squash`
- **From a previous ZIP:** download the new release ZIP, then either re-run the installer (it will skip existing files) or manually diff and update.

Major / minor version bumps (e.g., 0.1 → 0.2) may introduce breaking changes to `opencode.jsonc` or `agents_manager/SKILL.md`. Always read the release notes before upgrading across minor versions.

## Folder conventions (added in v0.4.0)

After install, agents write artifacts to these paths:

- `share/notes/01_research_<task-id>.md` — research output
- `share/notes/02_plan_high_<task-id>.md` + `02_plan_phases_<task-id>.md` — planning output (two files)
- `share/notes/03_coder_summary_<task-id>_<phase>.md` — coder work summary
- `share/reports/04_review_<task-id>_<phase>.md` — review report
- `share/notes/99_progress_<task-id>.md` — master's progress ledger (append-only)
- `share/messages/<from>-to-<to>-<task-id>-<topic>.md` — **cross-agent coordination notes** (free-form; the naming convention makes intent obvious — e.g. `research-to-planning-T-001-clarify.md`)

These paths are enforced by the `permission` blocks in `opencode.jsonc`. Any agent that tries to write outside its lane gets a permission denial.
