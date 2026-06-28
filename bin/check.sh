#!/usr/bin/env bash
# check.sh — verify a target project has agents-manager installed correctly
# Usage: ./bin/check.sh [TARGET_PROJECT_PATH]
# Default TARGET_PROJECT_PATH = current directory
set -euo pipefail

TARGET="${1:-.}"
if [[ ! -d "$TARGET" ]]; then
  echo "ERROR: target directory '$TARGET' does not exist."
  exit 1
fi
TARGET_ABS="$(cd "$TARGET" && pwd)"

PASS=0
FAIL=0

check_file() {
  if [[ -e "$TARGET_ABS/$1" ]]; then
    echo "  OK   $1"
    PASS=$((PASS+1))
  else
    echo "  MISS $1"
    FAIL=$((FAIL+1))
  fi
}

check_dir() {
  if [[ -d "$TARGET_ABS/$1" ]]; then
    echo "  OK   $1/"
    PASS=$((PASS+1))
  else
    echo "  MISS $1/"
    FAIL=$((FAIL+1))
  fi
}

echo "Controller files in $TARGET_ABS:"
check_file opencode.jsonc
check_file CLAUDE.md
check_dir  agents_manager
check_dir  share
check_dir  tasks
check_dir  .agents/skills/mavis-team

echo ""
echo "User-level skills required (run the npx command if MISS):"

SKILLS=(
  "dispatching-parallel-agents:obra/superpowers"
  "subagent-driven-development:obra/superpowers"
  "verification-before-completion:obra/superpowers"
  "systematic-debugging:obra/superpowers"
  "test-driven-development:obra/superpowers"
  "requesting-code-review:obra/superpowers"
  "writing-plans:obra/superpowers"
  "executing-plans:obra/superpowers"
  "brainstorming:obra/superpowers"
)

for entry in "${SKILLS[@]}"; do
  name="${entry%%:*}"
  if [[ -d "$HOME/.agents/skills/$name" ]]; then
    echo "  OK   ~/$name"
  else
    echo "  MISS npx --yes skills add https://github.com/${entry##*:} --skill $name -g -y"
  fi
done

echo ""
echo "Result: PASS=$PASS  FAIL=$FAIL"
if [[ $FAIL -gt 0 ]]; then
  echo ""
  echo "Fix the MISS items above and re-run."
  exit 1
fi
