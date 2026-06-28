# check.ps1 — verify a target project has agents-manager installed correctly
# Usage: .\bin\check.ps1 [-Target TARGET_PROJECT_PATH]
# Default TARGET_PROJECT_PATH = current directory
[CmdletBinding()]
param(
    [string]$Target = "."
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Target)) {
    Write-Host "ERROR: target directory '$Target' does not exist." -ForegroundColor Red
    exit 1
}
$TargetAbs = (Resolve-Path $Target).Path

$Pass = 0
$Fail = 0

function Test-ControllerFile {
    param([string]$Rel)
    $P = Join-Path $TargetAbs $Rel
    if (Test-Path $P) {
        Write-Host "  OK   $Rel"
        $script:Pass++
    } else {
        Write-Host "  MISS $Rel"
        $script:Fail++
    }
}

function Test-ControllerDir {
    param([string]$Rel)
    $P = Join-Path $TargetAbs $Rel
    if (Test-Path $P -PathType Container) {
        Write-Host "  OK   $Rel\"
        $script:Pass++
    } else {
        Write-Host "  MISS $Rel\"
        $script:Fail++
    }
}

Write-Host "Controller files in ${TargetAbs}:"
Test-ControllerFile "opencode.jsonc"
Test-ControllerFile "CLAUDE.md"
Test-ControllerDir  "agents_manager"
Test-ControllerDir  "share"
Test-ControllerDir  "tasks"
Test-ControllerDir  ".agents/skills/mavis-team"

Write-Host ""
Write-Host "User-level skills required (run the npx command if MISS):"

$Skills = @(
    "dispatching-parallel-agents",
    "subagent-driven-development",
    "verification-before-completion",
    "systematic-debugging",
    "test-driven-development",
    "requesting-code-review",
    "writing-plans",
    "executing-plans",
    "brainstorming"
)

foreach ($s in $Skills) {
    $Path = Join-Path $HOME ".agents/skills/$s"
    if (Test-Path $Path -PathType Container) {
        Write-Host "  OK   ~/$s"
    } else {
        Write-Host "  MISS npx --yes skills add https://github.com/obra/superpowers --skill ${s} -g -y"
    }
}

Write-Host ""
Write-Host "Result: PASS=$Pass  FAIL=$Fail"
if ($Fail -gt 0) {
    Write-Host ""
    Write-Host "Fix the MISS items above and re-run."
    exit 1
}
