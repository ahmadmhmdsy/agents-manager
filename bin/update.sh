#!/usr/bin/env bash
# update.sh — update agents-manager controller to the latest release
# Usage: ./bin/update.sh [--check] [--yes|-y] [--from <ver>] [--target <ver>]
# Default: check vs latest, prompt if newer
set -euo pipefail

VERSION="v0.8.0"
REPO="ahmadmhmdsy/agents-manager"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"

# Paths the controller owns (must match install.sh + opencode.jsonc globs)
CONTROLLER_PATHS=(opencode.jsonc CLAUDE.md agents_manager share tasks .agents/skills/mavis-team)

# Parse args
CHECK_ONLY="false"
YES="false"
TARGET=""
FROM=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)    CHECK_ONLY="true"; shift ;;
    --yes|-y)   YES="true"; shift ;;
    --target)   TARGET="$2"; shift 2 ;;
    --from)     FROM="$2"; shift 2 ;;
    --help|-h)
      cat <<EOF
agents-manager updater ${VERSION}

Usage: $0 [options]

Options:
  --check         Query GitHub for the latest version, print local + remote, exit.
  --yes, -y       Skip the "Update?" confirmation prompt.
  --target <ver>  Update to a specific version (e.g., --target v0.8.5) instead of latest.
                  Skips the GitHub API call.
  --from <ver>    Pretend local version is <ver> for diff/changelog display.
                  Useful for testing. Does not affect what gets installed.
  --help, -h      Show this help.

Without flags, the script:
  1. Reads local version from agents_manager/CHANGELOG.md
  2. Queries GitHub API for the latest release
  3. If newer, prompts for confirmation (use --yes to skip)
  4. On confirm: backs up the 6 controller paths to
     .agents-manager-backup-<timestamp>/, downloads the release ZIP,
     copies the 6 paths, updates .agents-manager/.last-update-check
  5. Runs bin/check.sh to verify the install

Exit codes:
  0  up to date OR update applied successfully OR --check ran
  1  sanity check failed (CHANGELOG missing, no controller paths, etc.)
  2  network error (GitHub API unreachable, ZIP malformed)
  3  user declined the update
EOF
      exit 0
      ;;
    *)
      echo "Unknown flag: $1" >&2
      exit 1
      ;;
  esac
done

echo "agents-manager updater ${VERSION}"
echo ""

# ─── Sanity checks ─────────────────────────────────────────────────────────
if [[ ! -f "agents_manager/CHANGELOG.md" ]]; then
  echo "ERROR: agents_manager/CHANGELOG.md not found." >&2
  echo "Are you running this from a project root with agents-manager installed?" >&2
  exit 1
fi

# ─── Helpers ───────────────────────────────────────────────────────────────

# Parse the first `## vX.Y.Z — ...` heading from CHANGELOG.md
local_version() {
  head -100 "agents_manager/CHANGELOG.md" | grep -oE '^## v[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's/^## //' || echo ""
}

# Read remote version: from --target if given, else GitHub API
remote_version() {
  if [[ -n "$TARGET" ]]; then
    echo "$TARGET"
    return
  fi
  local response
  response=$(curl -fsSL "$API_URL" 2>&1) || {
    echo "ERROR: GitHub API call failed. Check your network or try --target <ver>." >&2
    return 1
  }
  echo "$response" | grep -oE '"tag_name"[[:space:]]*:[[:space:]]*"v[0-9]+\.[0-9]+\.[0-9]+"' | head -1 \
    | sed 's/.*"v/v/' | sed 's/"//'
}

# Semver tuple comparison: returns 0 if $1 < $2, 1 otherwise
version_lt() {
  local a="$1" b="$2"
  [[ "$a" == "$b" ]] && return 1
  local IFS=.
  # strip leading 'v' via parameter expansion (avoids SC2001 sed).
  local clean_a="${a#v}" clean_b="${b#v}"
  # Use read -ra (avoids SC2206 — quote to prevent word splitting).
  local -a va=() vb=()
  IFS=. read -ra va <<< "$clean_a"
  IFS=. read -ra vb <<< "$clean_b"
  for i in 0 1 2; do
    local ai="${va[$i]:-0}" bi="${vb[$i]:-0}"
    if (( ai < bi )); then return 0; fi
    if (( ai > bi )); then return 1; fi
  done
  return 1
}

# Print CHANGELOG entries between local_version and remote_version (inclusive of remote)
changelog_excerpt() {
  local from="$1" to="$2"
  awk -v from="## ${from}" -v to="## ${to}" '
    $0 ~ /^## v[0-9]+\.[0-9]+\.[0-9]+/ {
      if (index($0, to)) { show=1; print; next }
      if (show && index($0, from)) { exit }
    }
    show { print }
  ' "agents_manager/CHANGELOG.md"
}

# ─── Determine versions ───────────────────────────────────────────────────
LOCAL="${FROM:-$(local_version)}"
if [[ -z "$LOCAL" ]]; then
  echo "ERROR: Could not parse local version from CHANGELOG.md." >&2
  exit 1
fi

REMOTE=$(remote_version) || exit 2
if [[ -z "$REMOTE" ]]; then
  echo "ERROR: Could not determine remote version." >&2
  exit 2
fi

echo "  Local version:  $LOCAL"
echo "  Latest release: $REMOTE"
echo ""

if [[ "$CHECK_ONLY" == "true" ]]; then
  if version_lt "$LOCAL" "$REMOTE"; then
    echo "Update available."
    exit 0
  else
    echo "You have the latest."
    exit 0
  fi
fi

if ! version_lt "$LOCAL" "$REMOTE"; then
  echo "You already have the latest ($LOCAL). Nothing to do."
  exit 0
fi

# ─── Pre-update safety checks ──────────────────────────────────────────────
echo "Update available: $LOCAL → $REMOTE"
echo ""
echo "Release notes (excerpt):"
echo "────────────────────────────────────────"
changelog_excerpt "$LOCAL" "$REMOTE" | head -80
echo "────────────────────────────────────────"
echo ""

# Check for active task tracker files (mid-pipeline updates are risky)
# Use a glob instead of `ls | grep` to avoid SC2010 and handle non-alphanumeric names.
active_tasks=()
for f in tasks/T-*.md; do
  [[ -f "$f" ]] || continue
  [[ "$f" == "tasks/README.md" ]] && continue
  active_tasks+=("$f")
done
if [[ "${#active_tasks[@]}" -gt 0 ]]; then
  echo "WARNING: Active task tracker files detected:"
  printf '  %s\n' "${active_tasks[@]:0:5}"
  echo "Updating mid-pipeline is risky. Consider completing or pausing first."
  echo ""
fi

# ─── Confirmation ──────────────────────────────────────────────────────────
if [[ "$YES" != "true" ]]; then
  read -r -p "Update from $LOCAL to $REMOTE? [y/N] " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Update skipped."
    # Still update the marker so we don't re-prompt today
    mkdir -p .agents-manager
    date -u +%Y-%m-%dT%H:%M:%SZ > .agents-manager/.last-update-check
    exit 3
  fi
fi

# ─── Backup ────────────────────────────────────────────────────────────────
BACKUP_DIR=".agents-manager-backup-$(date +%Y%m%d-%H%M%S)-$LOCAL"
echo ""
echo "Creating backup at $BACKUP_DIR/"
mkdir -p "$BACKUP_DIR"
for rel in "${CONTROLLER_PATHS[@]}"; do
  if [[ -e "$rel" ]]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    cp -r "$rel" "$BACKUP_DIR/$rel"
  fi
done
cat > "$BACKUP_DIR/MANIFEST.txt" <<EOF
agents-manager backup
Original local version: $LOCAL
Backup created: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Created by: bin/update.sh ${VERSION}

Paths backed up:
EOF
for rel in "${CONTROLLER_PATHS[@]}"; do
  [[ -e "$BACKUP_DIR/$rel" ]] && echo "  - $rel" >> "$BACKUP_DIR/MANIFEST.txt"
done
echo "  OK backup complete"
echo ""

# ─── Download + apply ─────────────────────────────────────────────────────
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

ZIP_URL="https://github.com/${REPO}/archive/refs/tags/${REMOTE}.zip"
echo "Downloading $ZIP_URL ..."
if ! curl -fsSL "$ZIP_URL" -o "$TEMP_DIR/release.zip"; then
  echo "ERROR: Failed to download release ZIP. Backup preserved at $BACKUP_DIR/" >&2
  exit 2
fi

if ! unzip -q "$TEMP_DIR/release.zip" -d "$TEMP_DIR"; then
  echo "ERROR: Failed to unzip release. Backup preserved at $BACKUP_DIR/" >&2
  exit 2
fi

# Find the agents-manager-* directory inside the extracted ZIP via glob
# (avoids SC2010: don't use ls | grep).
EXTRACTED=""
for d in "$TEMP_DIR"/agents-manager-*; do
  [[ -d "$d" ]] || continue
  EXTRACTED=$(basename "$d")
  break
done
if [[ -z "$EXTRACTED" ]]; then
  echo "ERROR: Release ZIP missing agents-manager-* directory. Backup preserved at $BACKUP_DIR/" >&2
  exit 2
fi
SRC_DIR="$TEMP_DIR/$EXTRACTED"

echo "Applying $REMOTE files..."
for rel in "${CONTROLLER_PATHS[@]}"; do
  if [[ -e "$SRC_DIR/$rel" ]]; then
    rm -rf "$rel"
    cp -r "$SRC_DIR/$rel" "$rel"
    echo "  OK   $rel"
  else
    echo "  SKIP $rel (not in release ZIP — keeping local)"
  fi
done

# ─── Marker + verify ──────────────────────────────────────────────────────
mkdir -p .agents-manager
date -u +%Y-%m-%dT%H:%M:%SZ > .agents-manager/.last-update-check
echo ""
echo "Updated: $LOCAL → $REMOTE"
echo "Backup:  $BACKUP_DIR/"
echo "Marker:  .agents-manager/.last-update-check"
echo ""
echo "Running bin/check.sh to verify install..."
echo ""
if [[ -f "bin/check.sh" ]]; then
  bash bin/check.sh . || echo "(check returned non-zero — review manually)"
else
  echo "(no bin/check.sh — skipping verification)"
fi