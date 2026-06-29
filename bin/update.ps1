# update.ps1 — update agents-manager controller to the latest release
# Usage: .\bin\update.ps1 [-Check] [-Yes] [-From <ver>] [-Target <ver>]
[CmdletBinding()]
param(
    [switch]$Check,
    [switch]$Yes,
    [string]$From,
    [string]$Target
)

$ScriptVersion = "v0.8.0"
$Repo = "ahmadmhmdsy/agents-manager"
$ApiUrl = "https://api.github.com/repos/$Repo/releases/latest"

# Paths the controller owns (must match install.sh + opencode.jsonc globs)
$ControllerPaths = @("opencode.jsonc", "CLAUDE.md", "agents_manager", "share", "tasks", ".agents/skills/mavis-team")

Write-Host "agents-manager updater $ScriptVersion"
Write-Host ""

# ─── Sanity checks ─────────────────────────────────────────────────────────
if (-not (Test-Path "agents_manager/CHANGELOG.md")) {
    Write-Host "ERROR: agents_manager/CHANGELOG.md not found." -ForegroundColor Red
    Write-Host "Are you running this from a project root with agents-manager installed?" -ForegroundColor Red
    exit 1
}

# ─── Helpers ───────────────────────────────────────────────────────────────

# Parse the first ## vX.Y.Z heading from CHANGELOG.md
function Get-LocalVersion {
    $first = Get-Content "agents_manager/CHANGELOG.md" -TotalCount 100 |
        Select-String -Pattern '^## v\d+\.\d+\.\d+' |
        Select-Object -First 1
    if ($first) {
        ($first -replace '^## ', '').Trim()
    } else {
        ""
    }
}

# Read remote version: from --target if given, else GitHub API
function Get-RemoteVersion {
    param([string]$TargetArg)
    if ($TargetArg) {
        return $TargetArg
    }
    try {
        $response = Invoke-WebRequest -Uri $ApiUrl -UseBasicParsing -Headers @{"Accept"="application/vnd.github+json"} -ErrorAction Stop
        $json = $response.Content | ConvertFrom-Json
        return $json.tag_name
    } catch {
        Write-Host "ERROR: GitHub API call failed. Check your network or try -Target <ver>." -ForegroundColor Red
        exit 2
    }
}

# Semver tuple comparison: returns $true if $a < $b
function Version-LessThan {
    param([string]$a, [string]$b)
    if ($a -eq $b) { return $false }
    $va = $a.TrimStart('v').Split('.')
    $vb = $b.TrimStart('v').Split('.')
    for ($i = 0; $i -lt 3; $i++) {
        $ai = if ($i -lt $va.Length) { [int]$va[$i] } else { 0 }
        $bi = if ($i -lt $vb.Length) { [int]$vb[$i] } else { 0 }
        if ($ai -lt $bi) { return $true }
        if ($ai -gt $bi) { return $false }
    }
    return $false
}

# Print CHANGELOG entries between local_version and remote_version (inclusive of remote)
function Get-ChangelogExcerpt {
    param([string]$fromVer, [string]$toVer)
    $fromHeader = "## $fromVer"
    $toHeader = "## $toVer"
    $show = $false
    Get-Content "agents_manager/CHANGELOG.md" | ForEach-Object {
        if ($_ -match '^## v\d+\.\d+\.\d+') {
            if ($_ -match [regex]::Escape($toHeader)) {
                $script:show = $true
                Write-Output $_
                return
            }
            if ($script:show -and $_ -match [regex]::Escape($fromHeader)) {
                $script:show = $false
                return
            }
        }
        if ($script:show) { Write-Output $_ }
    }
}

# ─── Determine versions ───────────────────────────────────────────────────
$Local = if ($From) { $From } else { Get-LocalVersion }
if (-not $Local) {
    Write-Host "ERROR: Could not parse local version from CHANGELOG.md." -ForegroundColor Red
    exit 1
}

$Remote = Get-RemoteVersion -TargetArg $Target
if (-not $Remote) {
    Write-Host "ERROR: Could not determine remote version." -ForegroundColor Red
    exit 2
}

Write-Host "  Local version:  $Local"
Write-Host "  Latest release: $Remote"
Write-Host ""

if ($Check) {
    if (Version-LessThan $Local $Remote) {
        Write-Host "Update available."
        exit 0
    } else {
        Write-Host "You have the latest."
        exit 0
    }
}

if (-not (Version-LessThan $Local $Remote)) {
    Write-Host "You already have the latest ($Local). Nothing to do."
    exit 0
}

# ─── Pre-update safety checks ──────────────────────────────────────────────
Write-Host "Update available: $Local -> $Remote"
Write-Host ""
Write-Host "Release notes (excerpt):"
Write-Host "----------------------------------------"
Get-ChangelogExcerpt -fromVer $Local -toVer $Remote | Select-Object -First 80
Write-Host "----------------------------------------"
Write-Host ""

# Check for active task tracker files (mid-pipeline updates are risky)
$activeTasks = Get-ChildItem "tasks/T-*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne "README.md" }
if ($activeTasks) {
    Write-Host "WARNING: Active task tracker files detected:"
    $activeTasks | Select-Object -First 5 | ForEach-Object { Write-Host "  $($_.Name)" }
    Write-Host "Updating mid-pipeline is risky. Consider completing or pausing first."
    Write-Host ""
}

# ─── Confirmation ──────────────────────────────────────────────────────────
if (-not $Yes) {
    $confirm = Read-Host "Update from $Local to $Remote? [y/N]"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "Update skipped."
        # Still update the marker so we don't re-prompt today
        New-Item -Path ".agents-manager" -ItemType Directory -Force | Out-Null
        (Get-Date -AsUTC -Format "yyyy-MM-ddTHH:mm:ssZ") | Out-File ".agents-manager/.last-update-check" -Encoding utf8
        exit 3
    }
}

# ─── Backup ────────────────────────────────────────────────────────────────
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupDir = ".agents-manager-backup-$timestamp-$Local"
Write-Host ""
Write-Host "Creating backup at $BackupDir/"
New-Item -Path $BackupDir -ItemType Directory -Force | Out-Null
foreach ($rel in $ControllerPaths) {
    if (Test-Path $rel) {
        $dest = Join-Path $BackupDir $rel
        $parent = Split-Path -Parent $dest
        if (-not (Test-Path $parent)) {
            New-Item -Path $parent -ItemType Directory -Force | Out-Null
        }
        Copy-Item -Path $rel -Destination $dest -Recurse -Force
    }
}
$manifest = @"
agents-manager backup
Original local version: $Local
Backup created: $((Get-Date -AsUTC).ToString('yyyy-MM-ddTHH:mm:ssZ'))
Created by: bin/update.ps1 $ScriptVersion

Paths backed up:
"@
foreach ($rel in $ControllerPaths) {
    $backupPath = Join-Path $BackupDir $rel
    if (Test-Path $backupPath) { $manifest += "  - $rel`n" }
}
$manifest | Out-File "$BackupDir/MANIFEST.txt" -Encoding utf8
Write-Host "  OK backup complete"
Write-Host ""

# ─── Download + apply ─────────────────────────────────────────────────────
$TEMP_DIR = Join-Path $env:TEMP ("agents-manager-update-" + [Guid]::NewGuid().ToString("N").Substring(0,8))
New-Item -Path $TEMP_DIR -ItemType Directory -Force | Out-Null

$ZipUrl = "https://github.com/$Repo/archive/refs/tags/$Remote.zip"
$ZipPath = Join-Path $TEMP_DIR "release.zip"
Write-Host "Downloading $ZipUrl ..."
try {
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing -ErrorAction Stop
} catch {
    Write-Host "ERROR: Failed to download release ZIP. Backup preserved at $BackupDir/" -ForegroundColor Red
    Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    exit 2
}

# Extract ZIP using Expand-Archive (PowerShell 5.1+) — fallback to System.IO.Compression if needed
try {
    Expand-Archive -Path $ZipPath -DestinationPath $TEMP_DIR -Force -ErrorAction Stop
} catch {
    Write-Host "ERROR: Failed to unzip release. Backup preserved at $BackupDir/" -ForegroundColor Red
    Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    exit 2
}

$extracted = Get-ChildItem -Path $TEMP_DIR -Directory | Where-Object { $_.Name -like 'agents-manager-*' } | Select-Object -First 1
if (-not $extracted) {
    Write-Host "ERROR: Release ZIP missing agents-manager-* directory. Backup preserved at $BackupDir/" -ForegroundColor Red
    Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue
    exit 2
}
$SrcDir = $extracted.FullName

Write-Host "Applying $Remote files..."
foreach ($rel in $ControllerPaths) {
    $srcPath = Join-Path $SrcDir $rel
    if (Test-Path $srcPath) {
        if (Test-Path $rel) {
            Remove-Item -Path $rel -Recurse -Force
        }
        Copy-Item -Path $srcPath -Destination $rel -Recurse -Force
        Write-Host "  OK   $rel"
    } else {
        Write-Host "  SKIP $rel (not in release ZIP - keeping local)"
    }
}

# ─── Marker + verify ──────────────────────────────────────────────────────
New-Item -Path ".agents-manager" -ItemType Directory -Force | Out-Null
(Get-Date -AsUTC -Format "yyyy-MM-ddTHH:mm:ssZ") | Out-File ".agents-manager/.last-update-check" -Encoding utf8
Write-Host ""
Write-Host "Updated: $Local -> $Remote"
Write-Host "Backup:  $BackupDir/"
Write-Host "Marker:  .agents-manager/.last-update-check"
Write-Host ""
Write-Host "Running bin/check.ps1 to verify install..."
Write-Host ""
$checkScript = "bin/check.ps1"
if (Test-Path $checkScript) {
    & pwsh -File $checkScript
    if ($LASTEXITCODE -ne 0) {
        Write-Host "(check returned non-zero - review manually)" -ForegroundColor Yellow
    }
} else {
    Write-Host "(no bin/check.ps1 - skipping verification)"
}

# Cleanup temp dir
Remove-Item -Path $TEMP_DIR -Recurse -Force -ErrorAction SilentlyContinue