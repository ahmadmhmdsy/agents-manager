# bin/ — agents-manager scripts

Four cross-platform scripts for installing and verifying an `agents-manager` controller in a target project.

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

## Exit codes

| Code | Meaning |
|---|---|
| 0 | success (all OK) |
| 1 | sanity check failed (target missing, source not an agents-manager checkout, etc.) |
| 2 | some controller files / skills missing (check script) |
| 3 | user declined confirmation (--uninstall) |

## What these scripts do NOT do

- They do **not** install the 9 required user-level skills (run `npx skills add` manually — see `README.md`).
- They do **not** modify `opencode.jsonc` permission globs for nested installs. agents-manager installs at the project root only.
- They do **not** delete user-modified files. Existing controller files are **skipped** to protect your edits.