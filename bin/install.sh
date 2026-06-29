#!/usr/bin/env bash
# install.sh — copy the agents-manager controller into a target project
# Usage: ./bin/install.sh [TARGET] [--dry-run] [--uninstall] [--yes]
# Default TARGET = current directory
set -euo pipefail

VERSION="v0.7.2"

# Parse flags
TARGET="."
DRY_RUN="false"
UNINSTALL="false"
YES="false"

for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN="true" ;;
    --uninstall) UNINSTALL="true" ;;
    --yes|-y)    YES="true" ;;
    --help|-h)
      echo "Usage: $0 [TARGET] [--dry-run] [--uninstall] [--yes]"
      echo ""
      echo "  TARGET       Path to the project where the controller should be installed. Default: current directory."
      echo "  --dry-run    Print what would change without writing anything."
      echo "  --uninstall  Remove the controller files from TARGET (asks for confirmation)."
      echo "  --yes, -y    Skip confirmation prompts (use with --uninstall)."
      exit 0
      ;;
    -*)
      echo "Unknown flag: $arg" >&2
      exit 1
      ;;
    *)
      TARGET="$arg"
      ;;
  esac
done

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

echo "agents-manager installer ${VERSION}"
echo "  Source: $SRC"
echo "  Target: $TARGET_ABS"
if [[ "$DRY_RUN" == "true" ]]; then
  echo "  Mode:   DRY RUN (no changes will be written)"
fi
echo ""

# ─── UNINSTALL MODE ───────────────────────────────────────────────────────
if [[ "$UNINSTALL" == "true" ]]; then
  # Safety check: ensure TARGET_ABS is non-empty (avoid `rm -rf /share` if shellcheck warns)
  if [[ -z "${TARGET_ABS:-}" ]]; then
    echo "ERROR: TARGET_ABS is empty; refusing to uninstall." >&2
    exit 1
  fi
  echo "Uninstall mode. The following paths will be removed from $TARGET_ABS:"
  for rel in opencode.jsonc CLAUDE.md agents_manager share tasks .agents/skills/mavis-team; do
    if [[ -e "${TARGET_ABS}/${rel}" ]]; then
      echo "  - $rel"
    fi
  done
  echo ""
  if [[ "$YES" != "true" ]]; then
    read -r -p "Proceed? Type 'yes' to confirm: " confirm
    if [[ "$confirm" != "yes" ]]; then
      echo "Aborted."
      exit 3
    fi
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "(dry run — would have removed the paths above)"
    exit 0
  fi
  for rel in opencode.jsonc CLAUDE.md agents_manager share tasks .agents/skills/mavis-team; do
    if [[ -e "${TARGET_ABS}/${rel}" ]]; then
      rm -rf "${TARGET_ABS}/${rel}"
      echo "  REMOVED $rel"
    fi
  done
  echo ""
  echo "Uninstall complete."
  exit 0
fi

# ─── INSTALL MODE ─────────────────────────────────────────────────────────

# Helper: copy a file, skipping if it exists (warn instead)
copy_file() {
  local rel="$1"
  if [[ -e "$TARGET_ABS/$rel" ]]; then
    echo "  SKIP $rel (already exists — review manually)"
  else
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "  COPY $rel (dry run)"
    else
      cp "$SRC/$rel" "$TARGET_ABS/$rel"
      echo "  OK   $rel"
    fi
  fi
}

# Helper: copy a directory recursively, skipping if it exists
copy_dir() {
  local rel="$1"
  if [[ -e "$TARGET_ABS/$rel" ]]; then
    echo "  SKIP $rel/ (already exists — review manually)"
  else
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "  COPY $rel/ (dry run)"
    else
      cp -r "$SRC/$rel" "$TARGET_ABS/$rel"
      echo "  OK   $rel/"
    fi
  fi
}

# Helper: write or append to .gitignore (additive — never overwrites)
ensure_gitignore() {
  local marker="# agents-manager v${VERSION}"
  local gitignore="$TARGET_ABS/.gitignore"

  if [[ ! -e "$gitignore" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "  CREATE .gitignore (dry run)"
      return 0
    fi
    cat > "$gitignore" <<EOF
$marker
# agents-manager runtime artifacts
share/notes/02_secrets_*.md
share/screenshots/
share/notes/99_progress_*.md
EOF
    echo "  OK   .gitignore (created with agents-manager entries)"
    return 0
  fi

  if grep -qF "$marker" "$gitignore" 2>/dev/null; then
    echo "  SKIP .gitignore (already has agents-manager entries)"
    return 0
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  APPEND .gitignore (dry run)"
    return 0
  fi

  cat >> "$gitignore" <<EOF

$marker
share/notes/02_secrets_*.md
share/screenshots/
share/notes/99_progress_*.md
EOF
  echo "  OK   .gitignore (appended agents-manager entries)"
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
if [[ "$DRY_RUN" == "true" ]]; then
  echo "  MKDIR .agents/skills (dry run)"
else
  mkdir -p "$TARGET_ABS/.agents/skills"
fi
copy_dir  .agents/skills/mavis-team

echo ""
echo "Gitignore:"
ensure_gitignore

if [[ "$DRY_RUN" == "true" ]]; then
  echo ""
  echo "DRY RUN complete — no changes were written."
  exit 0
fi

echo ""
echo "Done."
echo ""
echo "NEXT STEPS:"
echo "  1. cd $TARGET_ABS"
echo "  2. Install the required user-level skills (see README.md or run bin/check.sh .)"
echo "  3. Open in OpenCode — the master agent is auto-routed"
echo ""