# bin/ — agents-manager scripts

Six cross-platform scripts for installing, verifying, updating, and linting an `agents-manager` controller in a target project.

## `install.sh` (Unix / macOS / WSL)

```bash
bash bin/install.sh [TARGET] [--dry-run] [--uninstall] [--yes] [--git <auto|prompt|skip>]
```

- `TARGET` — path to the project where the controller should be installed. Defaults to `.` (current directory).
- `--dry-run` — print what would change without writing anything.
- `--uninstall` — remove the controller files from `TARGET` (with confirmation prompt unless `--yes`).
- `--git <auto|prompt|skip>` — how to handle git init when `TARGET` is not yet a git repo. Default `auto` (zero-knowledge friendly): runs `git init` + initial commit automatically. `prompt` asks Y/n. `skip` never touches git. See [`docs/INSTALL.md`](../docs/INSTALL.md) § Git initialization.

Copies 2 files + 4 directories from the agents-manager checkout into `TARGET`:

- `opencode.jsonc`
- `CLAUDE.md`
- `agents_manager/`
- `share/`
- `tasks/`
- `.agents/skills/mavis-team/`

Existing files are **skipped** (not overwritten). Re-running is safe. After install, the script also writes a starter `.gitignore` in `TARGET` if one isn't present, with sensible entries for secrets and runtime artifacts. If `--git auto` (default) and `TARGET` isn't already a git repo, the script also runs `git init` + an initial commit (skipped silently if the `git` CLI isn't on `PATH`).

## `install.ps1` (Windows PowerShell 5.1+ and 7+)

```powershell
.\bin\install.ps1 [-Target <path>] [-DryRun] [-Uninstall] [-Yes] [-Git <auto|prompt|skip>]
```

Same flags as the bash version, but with PowerShell's standard `-DryRun` / `-Uninstall` / `-Yes` (PascalCase) naming. `-Git` accepts `auto`, `prompt`, or `skip`; default is `auto` (zero-knowledge friendly).

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

## `release-zip.sh` (Unix / macOS / WSL) — maintainer only

```bash
bash bin/release-zip.sh <tag> [--out <path>]
```

Builds `agents-manager-vX.Y.Z.zip` from a git tag's tree using `git archive`. Includes only the 7 paths that ship in a release: `opencode.jsonc`, `CLAUDE.md`, `agents_manager/`, `share/`, `tasks/`, `.agents/skills/mavis-team/`, `bin/` (bin/ is included so Option B / "download a ZIP" users can run the installer from the extracted folder).

After build, validates the ZIP contains all expected paths and the two installer scripts. Exits non-zero with a clear message if anything is missing.

Most users won't run this manually — `.github/workflows/release.yml` runs it on every `v*` tag push. Use this script when:

- Backfilling releases for old tags (`bin/release-zip-all.sh` for that)
- Validating locally before pushing a tag
- Building a ZIP for an offline install (e.g. air-gapped environment)

## `release-zip.ps1` (Windows PowerShell) — maintainer only

```powershell
.\bin\release-zip.ps1 -Tag <tag> [-Out <path>]
```

PowerShell mirror of `release-zip.sh`. Uses `[System.IO.Compression.ZipFile]` (built into .NET — no external `zip` CLI needed). Same validation logic. Requires Git for Windows' `bash.exe` on PATH for the `git archive | tar -x` step.

## `release-zip-all.sh` (Unix / macOS / WSL) — maintainer only

```bash
bash bin/release-zip-all.sh [--out <dir>]
```

Loop helper. Builds ZIPs into `<out>` (default `./dist/`) for **every** local `v*` tag. Prints a per-tag summary. Used for the one-time backfill that created all the historical GitHub Releases.

Does **not** call `gh release create` — pair it with a separate loop for that:

```bash
for tag in $(git tag -l 'v*' --sort=v:refname); do
  gh release create "$tag" \
    --title "$tag" \
    --notes-file <(extract_changelog_entry "$tag") \
    --target "$(git rev-parse "$tag")" \
    "dist/agents-manager-${tag}.zip"
done
```

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