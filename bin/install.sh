#!/usr/bin/env bash
# install.sh — copy the agents-manager controller into a target project
# Usage: ./bin/install.sh [TARGET_PROJECT_PATH]
# Default TARGET_PROJECT_PATH = current directory
set -euo pipefail

TARGET="${1:-.}"
# Resolve the source directory (the root of this repo, where this script lives two levels deep)
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Sanity checks
if [[ ! -f "$SRC/opencode.jsonc" ]]; then
  echo "ERROR: $SRC does not look like an agents-manager checkout (opencode.jsonc missing)."
  exit 1
fi

if [[ ! -d "$TARGET" ]]; then
  echo "ERROR: target directory '$TARGET' does not exist."
  exit 1
fi

# Resolve to absolute path for cleaner messages
TARGET_ABS="$(cd "$TARGET" && pwd)"

echo "Installing agents-manager into: $TARGET_ABS"
echo ""

# Helper: copy a file, skipping if it exists (warn instead)
copy_file() {
  local rel="$1"
  if [[ -e "$TARGET_ABS/$rel" ]]; then
    echo "  SKIP $rel (already exists — review manually)"
  else
    cp "$SRC/$rel" "$TARGET_ABS/$rel"
    echo "  OK   $rel"
  fi
}

# Helper: copy a directory recursively, skipping if it exists
copy_dir() {
  local rel="$1"
  if [[ -e "$TARGET_ABS/$rel" ]]; then
    echo "  SKIP $rel/ (already exists — review manually)"
  else
    cp -r "$SRC/$rel" "$TARGET_ABS/$rel"
    echo "  OK   $rel/"
  fi
}

echo "Files:"
copy_file opencode.jsonc
copy_file CLAUDE.md

echo ""
echo "Directories:"
copy_dir  agents_manager
copy_dir  share
copy_dir  tasks
# .agents/skills/mavis-team requires the parent dirs to exist (cp -r doesn't create them)
mkdir -p "$TARGET_ABS/.agents/skills"
copy_dir  .agents/skills/mavis-team

echo ""
echo "Done."
echo ""
echo "NEXT STEPS:"
echo "  1. cd $TARGET_ABS"
echo "  2. Install the required user-level skills (see README.md or run bin/check.sh .)"
echo "  3. Open in OpenCode — the master agent is auto-routed"
echo ""
