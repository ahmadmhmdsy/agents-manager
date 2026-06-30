# bin/ — agents-manager scripts

Six cross-platform scripts for installing, verifying, updating, and linting an `agents-manager` controller in a target project.

## `install.sh` (Unix / macOS / WSL)

```bash
bash bin/install.sh [TARGET] [--dry-run] [--uninstall]
```

- `TARGET` — path to the project where the controller should be installed. Defaults to `.` (current directory).
- `--dry-run` — print what would change without writing anything.
- `--uninstall` — remove the controller files from `TARGET` (with confirmation prompt unless `--yes`).

Copies 2 files + 4 directories from the agents-manager checkout into `TARGET`:

- `opencode.jsonc`
- `CLAUDE.md`
- `agents_manager/`
- `share/`
- `tasks/`
- `.agents/skills/mavis-team/`

Existing files are **skipped** (not overwritten). Re-running is safe. After install, the script also writes a starter `.gitignore` in `TARGET` if one isn't present, with sensible entries for secrets and runtime artifacts.

## `install.ps1` (Windows PowerShell 5.1+ and 7+)

```powershell
.\bin\install.ps1 [-Target <path>] [-DryRun] [-Uninstall]
```

Same flags as the bash version, but with PowerShell's standard `-DryRun` / `-Uninstall` (PascalCase) naming.

## `check.sh` (Unix / macOS / WSL)

```bash
bash bin/check.sh [TARGET]
```

Verifies that:

- All 6 controller files exist at `TARGET`
- All 9 required user-level skills are installed in `~/.agents/skills/`

Prints `OK` / `MISS` for each. Exits non-zero if anything is missing. Lists the `npx skills add` command for any missing skill.

## `check.ps1` (Windows PowerShell)

```powershell
.\bin\check.ps1 [-Target <path>]
```

Same checks, PowerShell-flavoured output.

## `update.sh` (Unix / macOS / WSL)

```bash
bash bin/update.sh [--check] [--yes|-y] [--from <ver>] [--target <ver>]
```

Fetches the latest `agents-manager` release from GitHub, compares to your installed version (read from `agents_manager/CHANGELOG.md`), and applies the upgrade by overwriting the 6 controller paths after backing up your current install.

- `--check` — print local vs. remote version + the new CHANGELOG excerpt. Exit 0 if up-to-date, exit 1 if a newer version exists, exit 2 on network error.
- `--yes`, `-y` — apply the upgrade without prompting (for CI / scripted use).
- `--from <ver>` — override the local version detection (useful after partial upgrades).
- `--target <ver>` — pin to a specific version instead of "latest".

Default behavior: print version info, show what will change, prompt `[yes/no]`. On yes: creates `.agents-manager-backup-<timestamp>/`, downloads the release ZIP, extracts the 6 paths, runs `bin/check.sh`, prints what changed.

## `update.ps1` (Windows PowerShell)

```powershell
.\bin\update.ps1 [-Check] [-Yes] [-From <ver>] [-Target <ver>]
```

PowerShell parity. Same flags (`-Check` / `-Yes` PascalCase).

## `lint-design.sh` (Unix / macOS / WSL) — v0.9.0+

```bash
bash bin/lint-design.sh [PATH]
```

Advisory linter for `am-design` output. Flags two things in mockup HTML:

- Inline hex color codes outside `:root` and `[data-theme]` blocks (so design tokens stay centralized)
- Emoji (so copy decks can grep cleanly)

Default path is `examples/`. Exits `0` if clean, `1` if violations found, `2` if path doesn't exist. **Does not block CI** — `lint-design` CI job is advisory only.

PowerShell parity is not shipped (advisory linters rarely need Windows). If you want it, the script is bash-only and 99 lines; port if needed.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | success (all OK) |
| 1 | sanity check failed (target missing, source not an agents-manager checkout, etc.) |
| 2 | some controller files / skills missing (check script) or newer version available (update --check) |
| 3 | user declined confirmation (--uninstall, update prompt) |
| 4 | network error during update (GitHub unreachable, ZIP malformed) |
| 5 | active pipeline detected (update refused to avoid mid-pipeline corruption) |

## What these scripts do NOT do

- They do **not** install the 9 required user-level skills (run `npx skills add` manually — see `README.md`).
- They do **not** modify `opencode.jsonc` permission globs for nested installs. agents-manager installs at the project root only.
- They do **not** delete user-modified files. Existing controller files are **skipped** to protect your edits (unless `update.sh` is overwriting them, in which case a backup is created first).
- `update.sh` does **not** touch user-level skills (`~/.agents/skills/`). It only updates the 6 controller paths. Run `npx skills add` for any new skill requirements after upgrading.