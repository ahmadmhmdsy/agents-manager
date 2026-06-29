# install.ps1 — copy the agents-manager controller into a target project
# Usage: .\bin\install.ps1 [-Target <path>] [-DryRun] [-Uninstall] [-Yes]
# Default TARGET = current directory
[CmdletBinding()]
param(
    [string]$Target = ".",
    [switch]$DryRun,
    [switch]$Uninstall,
    [switch]$Yes
)

$ErrorActionPreference = "Stop"

$ScriptVersion = "v0.7.2"

# Resolve script directory (repo root is parent of bin/)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Src = (Resolve-Path (Join-Path $ScriptDir "..")).Path

# Sanity check
if (-not (Test-Path (Join-Path $Src "opencode.jsonc"))) {
    Write-Host "ERROR: $Src does not look like an agents-manager checkout (opencode.jsonc missing)." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $Target)) {
    Write-Host "ERROR: target directory '$Target' does not exist." -ForegroundColor Red
    exit 1
}

$TargetAbs = (Resolve-Path $Target).Path

Write-Host "agents-manager installer $ScriptVersion"
Write-Host "  Source: $Src"
Write-Host "  Target: $TargetAbs"
if ($DryRun) {
    Write-Host "  Mode:   DRY RUN (no changes will be written)"
}
Write-Host ""

# ─── UNINSTALL MODE ───────────────────────────────────────────────────────
if ($Uninstall) {
    Write-Host "Uninstall mode. The following paths will be removed from ${TargetAbs}:"
    foreach ($rel in @("opencode.jsonc", "CLAUDE.md", "agents_manager", "share", "tasks", ".agents/skills/mavis-team")) {
        if (Test-Path (Join-Path $TargetAbs $rel)) {
            Write-Host "  - $rel"
        }
    }
    Write-Host ""
    if (-not $Yes) {
        $confirm = Read-Host "Proceed? Type 'yes' to confirm"
        if ($confirm -ne "yes") {
            Write-Host "Aborted."
            exit 3
        }
    }
    if ($DryRun) {
        Write-Host "(dry run - would have removed the paths above)"
        exit 0
    }
    foreach ($rel in @("opencode.jsonc", "CLAUDE.md", "agents_manager", "share", "tasks", ".agents/skills/mavis-team")) {
        $p = Join-Path $TargetAbs $rel
        if (Test-Path $p) {
            Remove-Item -Path $p -Recurse -Force
            Write-Host "  REMOVED $rel"
        }
    }
    Write-Host ""
    Write-Host "Uninstall complete."
    exit 0
}

# ─── INSTALL MODE ─────────────────────────────────────────────────────────

# Helper: copy a file, skipping if it exists
function Copy-ItemSafe {
    param([string]$Rel)
    $DestPath = Join-Path $TargetAbs $Rel
    if (Test-Path $DestPath) {
        Write-Host "  SKIP $Rel (already exists - review manually)"
    } else {
        if ($DryRun) {
            Write-Host "  COPY $Rel (dry run)"
        } else {
            Copy-Item -Path (Join-Path $Src $Rel) -Destination $DestPath
            Write-Host "  OK   $Rel"
        }
    }
}

# Helper: copy a directory recursively
function Copy-DirSafe {
    param([string]$Rel)
    $DestPath = Join-Path $TargetAbs $Rel
    if (Test-Path $DestPath) {
        Write-Host "  SKIP $Rel\ (already exists - review manually)"
    } else {
        if ($DryRun) {
            Write-Host "  COPY $Rel\ (dry run)"
        } else {
            Copy-Item -Path (Join-Path $Src $Rel) -Destination $DestPath -Recurse
            Write-Host "  OK   $Rel\"
        }
    }
}

# Helper: write or append to .gitignore (additive - never overwrites)
function Ensure-Gitignore {
    param([string]$TargetDir, [string]$Version)
    $marker = "# agents-manager $Version"
    $gitignore = Join-Path $TargetDir ".gitignore"

    if (-not (Test-Path $gitignore)) {
        if ($DryRun) {
            Write-Host "  CREATE .gitignore (dry run)"
            return
        }
        @"
$marker
# agents-manager runtime artifacts
share/notes/02_secrets_*.md
share/screenshots/
share/notes/99_progress_*.md
"@ | Out-File -FilePath $gitignore -Encoding utf8
        Write-Host "  OK   .gitignore (created with agents-manager entries)"
        return
    }

    $existing = Get-Content $gitignore -ErrorAction SilentlyContinue
    if ($existing -and ($existing -match [regex]::Escape($marker))) {
        Write-Host "  SKIP .gitignore (already has agents-manager entries)"
        return
    }

    if ($DryRun) {
        Write-Host "  APPEND .gitignore (dry run)"
        return
    }

    @"

$marker
share/notes/02_secrets_*.md
share/screenshots/
share/notes/99_progress_*.md
"@ | Out-File -FilePath $gitignore -Append -Encoding utf8
    Write-Host "  OK   .gitignore (appended agents-manager entries)"
}

Write-Host "Files:"
Copy-ItemSafe "opencode.jsonc"
Copy-ItemSafe "CLAUDE.md"

Write-Host ""
Write-Host "Directories:"
Copy-DirSafe  "agents_manager"
Copy-DirSafe  "share"
Copy-DirSafe  "tasks"
# .agents/skills/mavis-team requires the parent dirs (defensive - Copy-Item usually creates them, but explicit is safer)
if ($DryRun) {
    Write-Host "  MKDIR .agents\skills (dry run)"
} else {
    New-Item -Path (Join-Path $TargetAbs ".agents/skills") -ItemType Directory -Force | Out-Null
}
Copy-DirSafe  ".agents/skills/mavis-team"

Write-Host ""
Write-Host "Gitignore:"
Ensure-Gitignore -TargetDir $TargetAbs -Version $ScriptVersion

if ($DryRun) {
    Write-Host ""
    Write-Host "DRY RUN complete - no changes were written."
    exit 0
}

Write-Host ""
Write-Host "Done."
Write-Host ""
Write-Host "NEXT STEPS:"
Write-Host "  1. cd $TargetAbs"
Write-Host "  2. Install the required user-level skills (see README.md or run bin\check.ps1)"
Write-Host "  3. Open in OpenCode - the master agent is auto-routed"