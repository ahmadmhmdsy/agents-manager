#!/usr/bin/env bash
# install.sh — copy the agents-manager controller into a target project
# Usage: ./bin/install.sh [TARGET] [--dry-run] [--uninstall] [--yes] [--git <auto|prompt|skip>]
# Default TARGET = current directory
set -euo pipefail

VERSION="v0.9.1"

# Parse flags
TARGET="."
DRY_RUN="false"
UNINSTALL="false"
YES="false"
GIT_MODE="auto"

# Track whether the current iteration consumed an extra arg (for --git <value>).
# We capture the whole arg list once and expand it ourselves to keep
# "--git auto" and "--git=auto" parsing local to this loop.
parse_git_value() {
  local arg="$1"
  case "$arg" in
    --git=*) echo "${arg#--git=}" ;;
    *)       echo "$arg" ;;
  esac
}

ARGS=("$@")
i=0
while [[ $i -lt ${#ARGS[@]} ]]; do
  arg="${ARGS[$i]}"
  case "$arg" in
    --dry-run)   DRY_RUN="true" ;;
    --uninstall) UNINSTALL="true" ;;
    --yes|-y)    YES="true" ;;
    --git)
      i=$((i + 1))
      if [[ $i -ge ${#ARGS[@]} ]]; then
        echo "ERROR: --git requires a value (auto|prompt|skip)" >&2
        exit 1
      fi
      GIT_MODE="$(parse_git_value "${ARGS[$i]}")"
      ;;
    --git=*)
      GIT_MODE="$(parse_git_value "$arg")"
      ;;
    --help|-h)
      echo "Usage: $0 [TARGET] [--dry-run] [--uninstall] [--yes] [--git <auto|prompt|skip>]"
      echo ""
      echo "  TARGET                 Path to the project where the controller should be installed. Default: current directory."
      echo "  --dry-run              Print what would change without writing anything."
      echo "  --uninstall            Remove the controller files from TARGET (asks for confirmation)."
      echo "  --yes, -y              Skip confirmation prompts (use with --uninstall)."
      echo "  --git <mode>           How to handle git initialization when TARGET is not yet a git repo."
      echo "                         auto   (default) run 'git init' + initial commit automatically."
      echo "                         prompt ask before running 'git init' (Y/n)."
      echo "                         skip   don't touch git at all."
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
  i=$((i + 1))
done

# Validate --git value
case "$GIT_MODE" in
  auto|prompt|skip) ;;
  *)
    echo "ERROR: --git must be one of: auto, prompt, skip (got '$GIT_MODE')" >&2
    exit 1
    ;;
esac

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
      # shellcheck disable=SC2115  # ${TARGET_ABS:?} would fail closed; we already guarded above
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

# ─── Git init (optional, --git <auto|prompt|skip>) ────────────────────────
# Default mode is `auto` — zero-knowledge UX. If the target is already a
# git repo, this is a no-op in every mode. If git CLI is missing, we
# print one warning line and continue (don't fail the install).
git_init_if_needed() {
  # Already a git repo — never re-init.
  if [[ -d "$TARGET_ABS/.git" ]]; then
    echo "  SKIP .git (already initialized)"
    return 0
  fi

  # Explicit skip
  if [[ "$GIT_MODE" == "skip" ]]; then
    echo "  SKIP git init (--git skip)"
    return 0
  fi

  # git CLI not on PATH — don't fail the install.
  if ! command -v git >/dev/null 2>&1; then
    echo "  WARN git CLI not on PATH — skipping git init (install continues)."
    echo "        Install git from https://git-scm.com/ then run 'git init' yourself."
    return 0
  fi

  # Prompt mode — ask the user (Y/n, default yes for zero-knowledge UX).
  if [[ "$GIT_MODE" == "prompt" ]] && [[ "$YES" != "true" ]] && [[ "$DRY_RUN" != "true" ]]; then
    local ans
    read -r -p "  Initialize git in $TARGET_ABS? [Y/n] " ans
    ans="${ans:-Y}"
    if [[ ! "$ans" =~ ^[Yy]([Ee][Ss])?$ ]]; then
      echo "  SKIP git init (declined)"
      return 0
    fi
  fi

  # Dry run — show what would happen.
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "  GIT init + add + commit (dry run)"
    return 0
  fi

  # Do it. Use a local-only identity so we don't depend on the user's
  # global git config (zero-knowledge users may not have set user.name).
  # First-commit message: standard "Initial commit" so any future
  # tooling that greps for it works.
  if ! git -C "$TARGET_ABS" init -q -b main 2>/dev/null; then
    # Older git (< 2.28) doesn't support -b on init — fall back.
    git -C "$TARGET_ABS" init -q
  fi

  # Stage everything the installer just wrote (and any pre-existing files).
  # On Windows, git emits dozens of "LF will be replaced by CRLF" warnings
  # for LF-only files; those are informational, not errors, and would
  # overwhelm a zero-knowledge user's terminal. Redirect stderr — we
  # still check $? / explicit diff output below for real failures.
  if ! git -C "$TARGET_ABS" add -A 2>/dev/null; then
    echo "  WARN git add failed — repo is initialized but no files were staged." >&2
    echo "        Run 'git -C $TARGET_ABS add -A && git commit' manually." >&2
    return 0
  fi

  # Only commit if there's actually something to commit (target may have
  # files in .gitignore that produce an empty tree).
  if git -C "$TARGET_ABS" diff --cached --quiet; then
    echo "  OK   .git (initialized, nothing to commit — all paths gitignored)"
    return 0
  fi

  git -C "$TARGET_ABS" \
    -c user.email="agents-manager@local" \
    -c user.name="agents-manager" \
    commit -q -m "Initial commit" 2>/dev/null || {
      echo "  WARN git commit failed — repo is initialized but no commit was created." >&2
      echo "        Run 'git -C $TARGET_ABS commit' manually after fixing the issue." >&2
      return 0
    }
  echo "  OK   .git (initialized + initial commit on branch 'main')"
}

echo ""
echo "Git:"
git_init_if_needed

echo ""
echo "Permissions:"
# Ensure all shell scripts in bin/ are executable.
# Windows git doesn't preserve the +x bit, so downstream users on Unix
# need this reapplied after install. PowerShell scripts are unaffected.
if [[ "$DRY_RUN" == "true" ]]; then
  # Use find — avoids SC2012 (ls parsing) and handles non-alphanumeric names.
  count=$(find "$SRC/bin" -maxdepth 1 -type f -name '*.sh' 2>/dev/null | wc -l)
  echo "  CHMOD +x bin/*.sh (dry run — would set executable bit on $count files)"
else
  count=0
  while IFS= read -r -d '' f; do
    chmod +x "$f"
    count=$((count + 1))
  done < <(find "$SRC/bin" -maxdepth 1 -type f -name '*.sh' -print0 2>/dev/null)
  echo "  CHMOD +x bin/*.sh ($count files)"
fi

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