#!/usr/bin/env bash
# Verify every grep-testable claim in INDEX.md + README + memory/.
# Exit non-zero on first failure.
#
# Tests cover:
#   T1  exactly N distinct data-section="…" values in skeleton/index.html,
#       where N is parsed from INDEX.md "## Sections (N)"
#   T2  no frontmatter (---) in memory/*.md
#   T3  every line of assets/MANIFEST.txt that names a path resolves in working tree
#   T4  every memory file's H1 number matches its filename prefix (01..NN)
#   T5  every memory file's H1 carries a "USE THIS WHEN:" trigger line
#   T6  --ink-faint is #7A6855 in skeleton (Fix 1, v0.13.0)
#   T7  cutout Pexels photo ID ≠ aura Pexels photo ID (Fix 7, v0.13.0)
#   T8  no legacy handoff 99_hrief.md path anywhere (Fix 9, v0.13.0)
#
# Run from the template root:
#   bash tests/verify.sh
# Or from repo root:
#   bash templates/cinematic-landing/tests/verify.sh
#
# Uses rg if available; falls back to grep -E otherwise.

set -uo pipefail

# Auto-detect template root + repo root from the script location.
# The template lives at <repo>/templates/cinematic-landing/, so:
#   SCRIPT_DIR = tests/     → TEMPLATE_ROOT = ../ (cinematic-landing), REPO_ROOT = ../../ (context_gen)
#   SCRIPT_DIR = template/  → TEMPLATE_ROOT = same,               REPO_ROOT = ../  (context_gen)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$TEMPLATE_ROOT/../.." && pwd)"

SKELETON="$TEMPLATE_ROOT/skeleton/index.html"
MEMORY_DIR="$TEMPLATE_ROOT/memory"
MANIFEST="$TEMPLATE_ROOT/assets/MANIFEST.txt"

# rg preferred; grep -E fallback (works on Windows + macOS + Linux without rg).
if command -v rg >/dev/null 2>&1; then
  _xgrep() { rg --no-config "$@"; }
else
  _xgrep() { grep -E "$@"; }
fi

ok=0
fail=0
pass() { ok=$((ok+1)); echo "  PASS: $1"; }
fail_msg() { fail=$((fail+1)); echo "  FAIL: $1"; }

# T1: exactly N distinct data-section values, where N is the section
# count declared in INDEX.md ("## Sections (N)"). Replaces the v0.14.0
# "≥8" assertion — that lower bound let a buggy insertion (duplicate
# data-section, missing row, off-by-one) pass silently. The test was
# deliberately tightened after AG19 (T-2026-07-04-001) shipped a 9th
# section with the wrong ambient hex and the test never noticed.
#
# Verification (F4 acceptance gate): introducing a duplicate
# data-section="hero" in skeleton/index.html must fail this test;
# restoring the original passes.
test_sections_exact_and_distinct() {
  # INDEX path lives next to SKELETON (../INDEX.md from tests/).
  local INDEX="$TEMPLATE_ROOT/INDEX.md"
  # Pull N from INDEX.md "## Sections (N)".
  local n_index
  n_index=$(_xgrep -ho '## Sections \([0-9]+\)' "$INDEX" | grep -oE '[0-9]+' | head -1 || true)
  if [[ -z "$n_index" ]]; then
    fail_msg "T1 cannot parse '## Sections (N)' from $INDEX"
    return 1
  fi
  # Count distinct data-section values in skeleton.
  local n_actual
  n_actual=$(_xgrep -ho 'data-section="[^"]+"' "$SKELETON" | sort -u | wc -l | tr -d ' \t' || true)
  if [[ "$n_actual" != "$n_index" ]]; then
    fail_msg "T1 INDEX says $n_index sections but skeleton has $n_actual distinct data-section values"
    return 1
  fi
  # Verify each data-section value is unique (no duplicates).
  local dup_count
  dup_count=$(_xgrep -ho 'data-section="[^"]+"' "$SKELETON" | sort | uniq -d | wc -l | tr -d ' \t' || true)
  if [[ "$dup_count" != "0" ]]; then
    fail_msg "T1 $dup_count duplicate data-section value(s) in skeleton"
    return 1
  fi
  pass "T1 exactly $n_index distinct data-section values in skeleton"
}

# T2: no frontmatter on memory/*.md (no line that is exactly '---').
test_no_frontmatter_on_memory() {
  local hits
  hits=$(_xgrep -l '^---$' "$MEMORY_DIR"/*.md 2>/dev/null || true)
  if [[ -z "$hits" ]]; then
    pass "T2 no frontmatter in memory/*.md"
  else
    fail_msg "T2 frontmatter found in: $hits"
  fi
}

# T3: every MANIFEST line that names a file resolves in the working tree.
# MANIFEST paths are repo-root-relative (e.g. agents_manager/assets/X,
# templates/cinematic-landing/Y), so resolve against REPO_ROOT.
test_manifest_resolves() {
  local missing=()
  while IFS= read -r raw || [[ -n "$raw" ]]; do
    local line="${raw%%#*}"          # strip inline comments
    line="$(echo "$line" | tr -d ' \t')"  # strip whitespace
    [[ -z "$line" ]] && continue    # skip blanks
    [[ "${line:0:1}" == "#" ]] && continue  # skip whole-line comments
    if [[ ! -e "$REPO_ROOT/$line" ]]; then
      missing+=("$line")
    fi
  done < "$MANIFEST"
  if [[ ${#missing[@]} -eq 0 ]]; then
    pass "T3 every MANIFEST.txt path resolves"
  else
    fail_msg "T3 unresolved MANIFEST entries: ${missing[*]}"
  fi
}

# T4: every memory file's H1 number matches its filename prefix.
# H1 lines are like "# 05 · Topic" — extract the digit after "# ".
test_h1_matches_filename() {
  local bad=()
  for f in "$MEMORY_DIR"/*.md; do
    local prefix h1
    prefix=$(basename "$f" | grep -oE '^[0-9]+')
    h1=$(head -n 1 "$f" | sed -nE 's/^#[[:space:]]+([0-9]+).*/\1/p' || true)
    if [[ -z "$h1" ]]; then
      # Fallback for environments without sed -E (busybox)
      h1=$(head -n 1 "$f" | sed -n 's/^# *[0-9][0-9]*.*/\0/p' | grep -oE '[0-9]+' | head -1 || true)
    fi
    if [[ "$prefix" != "$h1" ]]; then
      bad+=("$(basename "$f"):prefix=$prefix/h1=$h1")
    fi
  done
  if [[ ${#bad[@]} -eq 0 ]]; then
    pass "T4 every memory H1 number matches its filename prefix"
  else
    fail_msg "T4 mismatches: ${bad[*]}"
  fi
}

# T5: every memory H1 carries a "USE THIS WHEN:" trigger (Rule 6).
test_h1_has_trigger_line() {
  local bad=()
  for f in "$MEMORY_DIR"/*.md; do
    if ! head -n 1 "$f" | grep -q "USE THIS WHEN:"; then
      bad+=("$(basename "$f")")
    fi
  done
  if [[ ${#bad[@]} -eq 0 ]]; then
    pass "T5 every memory H1 carries USE THIS WHEN:"
  else
    fail_msg "T5 missing trigger line on: ${bad[*]}"
  fi
}

# T6: --ink-faint canonical hex is #7A6855 per memory/14 (Fix 1).
test_ink_faint_is_7a6855() {
  if _xgrep -q -- '--ink-faint:[[:space:]]*#7A6855' "$SKELETON"; then
    pass "T6 --ink-faint:#7A6855 (Fix 1 contrast update)"
  else
    fail_msg "T6 --ink-faint must be #7A6855 per memory/14"
  fi
}

# T7: cutout Pexels photo ID ≠ aura Pexels photo ID (Fix 7).
# Multi-line regex across CSS blocks; use grep -A to grab context lines.
test_cutout_distinct_from_aura() {
  local aura cutout
  aura=$(grep -A 12 "#hero .aura{" "$SKELETON" 2>/dev/null | grep -oE 'pexels\.com/photos/[0-9]+' | head -1 | grep -oE '[0-9]+' || true)
  cutout=$(grep -A 8 'class="hero-media"' "$SKELETON" 2>/dev/null | grep -oE 'pexels\.com/photos/[0-9]+' | head -1 | grep -oE '[0-9]+' || true)
  if [[ -n "$aura" && -n "$cutout" && "$aura" != "$cutout" ]]; then
    pass "T7 cutout Pexels ID ($cutout) ≠ aura Pexels ID ($aura)"
  else
    fail_msg "T7 aura='$aura' cutout='$cutout' must be distinct"
  fi
}

# T8: no 99_hrief.md path anywhere (Fix 9). Scoped to source-controlled
# files (agents_manager/, templates/) while excluding the verify script
# itself (which names the typo as the test target).
test_no_handoff_hrief_typo() {
  local hits
  hits=$(_xgrep -rl '99_hrief\.md|hrief\.md' "$REPO_ROOT/agents_manager" "$REPO_ROOT/templates" 2>/dev/null \
        | grep -v '/tests/verify\.sh$' \
        || true)
  if [[ -z "$hits" ]]; then
    pass "T8 no 99_hrief.md / hrief.md typo in agents_manager/ or templates/"
  else
    fail_msg "T8 hrief typo survived in: $hits"
  fi
}

# ── run all ──
test_sections_exact_and_distinct
test_no_frontmatter_on_memory
test_manifest_resolves
test_h1_matches_filename
test_h1_has_trigger_line
test_ink_faint_is_7a6855
test_cutout_distinct_from_aura
test_no_handoff_hrief_typo

echo
echo "OK   : $ok"
echo "FAIL : $fail"
if [[ $fail -gt 0 ]]; then
  exit 1
fi
echo "All verify.sh checks passed."
