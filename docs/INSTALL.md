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

The latest release is always at <https://github.com/ahmadmhmdsy/agents-manager/releases/latest>. The ZIP file is named `agents-manager-vX.Y.Z.zip`.

### One-liner (pinned to a specific version)

**macOS / Linux:**

```bash
# Pinned version (recommended for reproducibility)
VERSION=v0.9.1
curl -L -o /tmp/agents-manager.zip \
  "https://github.com/ahmadmhmdsy/agents-manager/releases/download/${VERSION}/agents-manager-${VERSION}.zip"
unzip -q /tmp/agents-manager.zip -d /tmp/
bash /tmp/agents-manager/bin/install.sh /path/to/your-project
```

Or with `wget`:

```bash
VERSION=v0.9.1
wget -q -O /tmp/agents-manager.zip \
  "https://github.com/ahmadmhmdsy/agents-manager/releases/download/${VERSION}/agents-manager-${VERSION}.zip"
unzip -q /tmp/agents-manager.zip -d /tmp/
bash /tmp/agents-manager/bin/install.sh /path/to/your-project
```

**Windows (PowerShell 5.1+ / 7+):**

```powershell
$VERSION = "v0.9.1"
Invoke-WebRequest -Uri "https://github.com/ahmadmhmdsy/agents-manager/releases/download/${VERSION}/agents-manager-${VERSION}.zip" -OutFile "$env:TEMP\agents-manager.zip"
Expand-Archive -Path "$env:TEMP\agents-manager.zip" -DestinationPath "$env:TEMP\agents-manager-extract\" -Force
& "$env:TEMP\agents-manager-extract\agents-manager\bin\install.ps1" -Target C:\path\to\your-project
```

### Manual (browse + click)

1. Visit <https://github.com/ahmadmhmdsy/agents-manager/releases/latest>
2. Under **Assets**, download `agents-manager-vX.Y.Z.zip` (NOT the source-code archives — those don't include the version-pinned installer scripts).
3. Extract the archive anywhere (e.g., `~/Downloads/agents-manager/` or `C:\Users\<you>\Downloads\agents-manager\`).
4. Run the installer from the extracted folder into your target project:

   ```bash
   # macOS / Linux
   bash ~/Downloads/agents-manager/bin/install.sh /path/to/your-project

   # Windows (PowerShell)
   .\Downloads\agents-manager\bin\install.ps1 -Target C:\path\to\your-project
   ```

The installer copies only the controller files (`opencode.jsonc`, `CLAUDE.md`, `agents_manager/`, `share/`, `tasks/`, `.agents/skills/mavis-team/`) into your target. It will **skip** any file or directory that already exists, so it's safe to re-run.

The ZIP also includes the `bin/` directory (with `install.sh`, `install.ps1`, `check.sh`, `update.sh`, etc.) so Option B is fully self-contained — you don't need a separate copy of the installer.

## Git initialization (`--git <auto|prompt|skip>`, default `auto`)

**For zero-knowledge users:** the default is `auto`. When your project folder is **not yet** a git repo, the installer runs `git init` and creates an initial commit for you. You don't need to know what git is — it just works. If `git` isn't installed on your machine, the installer prints a single warning and continues (the install still succeeds; you can install git later).

**For users who want control,** the installer accepts a `--git` flag (PowerShell: `-Git`) with three modes:

| Mode | Behavior |
|---|---|
| `auto` (default) | If `.git` doesn't exist → run `git init` + initial commit. If it does → no-op. If `git` CLI is missing → one-line warning, continue. |
| `prompt` | If `.git` doesn't exist → ask `Initialize git now? [Y/n]` (default yes for zero-knowledge friendliness). |
| `skip` | Never touch git. The installer works on a non-git folder and you'll handle git yourself. |

Examples:

```bash
# Default — auto-init if missing (zero-knowledge friendly)
bash bin/install.sh .

# Ask before initializing
bash bin/install.sh . --git prompt

# Don't touch git at all
bash bin/install.sh . --git skip

# PowerShell parity
.\bin\install.ps1 -Target . -Git prompt
.\bin\install.ps1 -Target . -Git skip
```

**Re-running the installer in an already-initialized repo is always a no-op** for the git step, regardless of mode. The installer also does not touch git in any mode if `.git` already exists.

**What gets committed in `auto` mode?** Everything in the target at install time (the controller files you just received plus any pre-existing files). The commit is attributed to a local-only identity (`agents-manager <agents-manager@local>`) so it doesn't depend on your global git config.

To preview what the installer would do without changing anything, pass `--dry-run` (or `-DryRun` on PowerShell):

```bash
bash bin/install.sh /path/to/your-project --dry-run --git auto
```

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

## Folder conventions

After install, agents write artifacts to these paths:

**Per-phase artifacts:**

- `share/notes/01_research_<task-id>.md` — research output
- `share/notes/02_plan_high_<task-id>.md` + `02_plan_phases_<task-id>.md` — planning output (two files)
- `share/notes/03_coder_summary_<task-id>_<phase>.md` — coder work summary
- `share/reports/04_review_<task-id>_<phase>.md` — review report
- `share/notes/04_warns_register_<task-id>.md` — consolidated WARN register (created at first Phase 4 review, appended per review)
- `share/notes/99_progress_<task-id>.md` — master's progress ledger (append-only)

**Cross-agent coordination:**

- `share/messages/<from>-to-<to>-<task-id>-<topic>.md` — free-form coordination notes. The naming convention makes intent obvious (e.g. `research-to-planning-T-001-clarify.md`).

**Optional (v0.6.0+):**

- `share/screenshots/` — browser preflight screenshots for UI tasks. Created on demand by the master when running a UI-phase review.
- `share/notes/02_secrets_<task-id>.md` — API keys / credentials the user supplies at Phase 0 Ingest. **Gitignored** by the installer's starter `.gitignore`.

**Tracker:**

- `tasks/<task-id>.md` — one per task. Created by master at Phase 0; appended by planner + coder; reviewed by master.

All paths are project-root relative. agents-manager does not currently support being nested under another directory (e.g., `tools/agents-manager/`).

## Recommended `.gitignore` additions

The installer's starter `.gitignore` includes these entries (additive — never overwrites your existing `.gitignore`):

```gitignore
# agents-manager runtime artifacts
share/notes/02_secrets_*.md
share/screenshots/
share/notes/99_progress_*.md
```

If you don't use the installer, add these manually. `share/screenshots/` and `02_secrets_*.md` can contain sensitive data (API keys, browser state) and should never be committed.

## First task to try

After verifying the install with `bin/check`, try a small task first to confirm the pipeline works end-to-end:

> "Add a one-line comment at the top of README.md that says 'managed by agents-manager'."

This task is small enough that all 5 phases complete in ~5 minutes. You can verify each phase's output:

1. Check `share/handoffs/00_user_task.md` — your task captured
2. Check `share/notes/01_research_T-...md` — research output (probably "this is trivial, just edit the file")
3. Confirm the plan with master when prompted
4. Check `share/notes/03_coder_summary_T-...md` — coder wrote the edit
5. Check `share/reports/04_review_T-...md` — review verdict (likely PASS)
6. Look at `README.md` — the new comment should be at the top

Once this works, try `examples/` (in the agents-manager repo) for fuller pipelines.

## Updating from a previous version

Three ways to upgrade, in order of convenience:

### Option 1 — `bin/update.sh` (v0.8.0+, recommended for most downstream projects)

```bash
# Check for updates (prints version diff + new CHANGELOG excerpt, no changes)
bash bin/update.sh --check

# Apply the upgrade (backs up + overwrites + verifies)
bash bin/update.sh
```

The script:
1. Fetches the latest release metadata from GitHub
2. Compares to the local version (read from `agents_manager/CHANGELOG.md`)
3. Shows the new CHANGELOG excerpt and prompts `[yes/no]`
4. On yes: creates `.agents-manager-backup-<timestamp>/` containing your current 6 controller paths, downloads the release ZIP, extracts the 6 paths into your project root, runs `bin/check.sh`, prints what changed

**PowerShell parity:** `.\bin\update.ps1 -Check` and `.\bin\update.ps1 -Yes`.

**What gets backed up:** all 6 controller paths (`opencode.jsonc`, `CLAUDE.md`, `agents_manager/`, `share/`, `tasks/`, `.agents/skills/mavis-team/`). Backups are NOT auto-cleaned — delete them once you've verified the upgrade.

**Active pipeline protection:** refuses to run if any `share/notes/03_coder_summary_*.md` was updated within the last hour (exit 5). Run during a quiet moment.

**Once-per-day auto-prompt (v0.8.0+):** the master agent reads `.agents-manager/.last-update-check` on session start and prompts you to upgrade if the marker is older than 24 hours. You don't need to remember to check — the prompt surfaces it.

### Option 2 — git subtree

```bash
git subtree pull --prefix=agents-manager-src \
  https://github.com/ahmadmhmdsy/agents-manager.git main --squash
```

Then re-run `bash bin/install.sh .` — existing files are skipped, new ones (CHANGELOG entries, examples/, etc.) are added.

### Option 3 — manual ZIP

Download the new release ZIP, extract it, then either re-run the installer (it will skip existing files and add new ones) or manually diff and update. Use `git diff` on `opencode.jsonc` and `agents_manager/SKILL.md` for the safest cross-version upgrade.

### Option 4 — fresh install (cleanest, for major-version bumps)

Back up your `tasks/`, `share/`, and any modifications to `agents_manager/`. Then re-install fresh and copy back your customizations.

### Pre-update checklist

**Always read the CHANGELOG first.** Open `agents_manager/CHANGELOG.md` and scan the entries between your installed version and the latest. Major / minor bumps (0.X → 0.Y) may introduce breaking changes to `opencode.jsonc`, `agents_manager/SKILL.md`, or the file conventions. Patch versions (0.X.Y → 0.X.Z) are safe to drop in.

## What if the install doesn't work

Decision tree:

```
install failed
├── "ERROR: ... opencode.jsonc missing"
│   └── You're not in an agents-manager checkout. Run the installer
│       from inside the cloned/ extracted repo, not from your project.
│
├── "ERROR: target directory ... does not exist"
│   └── Create the directory first: mkdir -p /path/to/your-project
│
├── install succeeds but bin/check shows MISS files
│   └── The check script lists which ones. If a controller file
│       is MISS, the installer's SKIP path kicked in (you had
│       a previous version). Either: (a) delete the missing paths
│       and re-run install, or (b) manually copy from the source.
│
├── install succeeds but bin/check shows MISS user-level skills
│   └── The check script prints the npx commands. Run each one.
│       Skills install to ~/.agents/skills/ which must be writable.
│
└── OpenCode can't find agents after install
    └── Confirm opencode.jsonc is at YOUR PROJECT ROOT (not nested,
        not in a subfolder). OpenCode's loader reads it from the
        working directory.
```

If you're still stuck after following the decision tree, open an issue at <https://github.com/ahmadmhmdsy/agents-manager/issues> with the output of `bin/check` and the version of OpenCode you're running.

## CI integration

If your downstream project has CI, you can run `bin/check` as a CI step to verify the install is intact on every push:

```yaml
# .github/workflows/agents-manager-check.yml
- name: Verify agents-manager install
  run: bash bin/check.sh .
```

The check exits non-zero if any controller file or required user-level skill is missing. This catches accidental deletions or broken `~/.agents/skills/` symlinks.

## Shell coverage

| Script | Tested on |
|---|---|
| `install.sh` | bash 4+ (Linux, macOS, WSL) |
| `install.ps1` | PowerShell 5.1 (Windows PowerShell) and PowerShell 7+ (pwsh, cross-platform) |
| `check.sh` | bash 4+ |
| `check.ps1` | PowerShell 5.1 and 7+ |

`fish` and `zsh` are NOT tested. If you use one of those, fall back to `bash` explicitly: `bash bin/install.sh .`. PowerShell Core (`pwsh`) on Linux/macOS is supported via `pwsh bin/install.ps1`.
