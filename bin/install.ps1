# install.ps1 — copy the agents-manager controller into a target project
# Usage: .\bin\install.ps1 [-Target TARGET_PROJECT_PATH]
# Default TARGET_PROJECT_PATH = current directory
[CmdletBinding()]
param(
    [string]$Target = "."
)

$ErrorActionPreference = "Stop"

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
Write-Host "Installing agents-manager into: $TargetAbs"
Write-Host ""

# Helper: copy a file, skipping if it exists
function Copy-ItemSafe {
    param([string]$Rel)
    $DestPath = Join-Path $TargetAbs $Rel
    if (Test-Path $DestPath) {
        Write-Host "  SKIP $Rel (already exists - review manually)"
    } else {
        Copy-Item -Path (Join-Path $Src $Rel) -Destination $DestPath
        Write-Host "  OK   $Rel"
    }
}

# Helper: copy a directory recursively
function Copy-DirSafe {
    param([string]$Rel)
    $DestPath = Join-Path $TargetAbs $Rel
    if (Test-Path $DestPath) {
        Write-Host "  SKIP $Rel\ (already exists - review manually)"
    } else {
        Copy-Item -Path (Join-Path $Src $Rel) -Destination $DestPath -Recurse
        Write-Host "  OK   $Rel\"
    }
}

Write-Host "Files:"
Copy-ItemSafe "opencode.jsonc"
Copy-ItemSafe "CLAUDE.md"

Write-Host ""
Write-Host "Directories:"
Copy-DirSafe  "agents_manager"
Copy-DirSafe  "share"
Copy-DirSafe  "tasks"
Copy-DirSafe  ".agents/skills/mavis-team"

Write-Host ""
Write-Host "Done."
Write-Host ""
Write-Host "NEXT STEPS:"
Write-Host "  1. cd $TargetAbs"
Write-Host "  2. Install the required user-level skills (see README.md or run bin\check.ps1)"
Write-Host "  3. Open in OpenCode - the master agent is auto-routed"
