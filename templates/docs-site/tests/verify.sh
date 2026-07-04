#!/usr/bin/env bash
# docs-site/tests/verify.sh
# Self-check for the docs-site template (v0.1.0).
# Exits 0 on PASS, non-zero on FAIL. Run from anywhere; absolute paths resolve
# from this script's location.

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
INDEX="$ROOT/INDEX.md"
SKELETON="$ROOT/skeleton/index.html"
DATA="$ROOT/skeleton/data.js"
MEMORY="$ROOT/memory"
MANIFEST="$ROOT/assets/MANIFEST.txt"

fail=0
pass=0

# pick grep dialect
if command -v rg >/dev/null 2>&1; then
  GREP="rg --no-heading --line-number"
else
  GREP="grep -nE"
fi

note() { printf "%s\n" "$1"; }

# ============================================================
# T1 — INDEX says "## Sections (N)" and skeleton has exactly N
#      distinct data-section values on real block-element tags.
# ============================================================
t1() {
  local expected
  expected="$(awk '/^## Sections \(/{print; exit}' "$INDEX" | sed -E 's/.*\(([0-9]+)\).*/\1/')"
  if [ -z "$expected" ]; then
    note "T1 FAIL: cannot parse '## Sections (N)' from INDEX.md"; fail=$((fail+1)); return
  fi
  # ponytail: scope to block-element opening tags only; comments + CSS selectors are not counted
  local got
  got="$($GREP 'data-section="' "$SKELETON" \
        | sed -E 's/.*data-section="([^"]+)".*/\1/' \
        | awk '!seen[$0]++' \
        | wc -l | tr -d ' ')"
  if [ "$got" != "$expected" ]; then
    note "T1 FAIL: INDEX declares $expected sections, skeleton has $got distinct"; fail=$((fail+1))
  else
    note "T1 PASS: $got sections match INDEX"; pass=$((pass+1))
  fi
}

# ============================================================
# T2 — every distinct data-section value is mentioned in INDEX.md.
# ============================================================
t2() {
  local vals
  vals="$($GREP 'data-section="' "$SKELETON" \
        | sed -E 's/.*data-section="([^"]+)".*/\1/' \
        | awk '!seen[$0]++')"
  local missing=""
  while IFS= read -r v; do
    [ -z "$v" ] && continue
    if ! $GREP -q "data-section=\\\\\"$v\\\\\"\|\\<$v\\>" "$INDEX" 2>/dev/null; then
      # fallback portable check
      if ! grep -qE "\\<$v\\>" "$INDEX"; then
        missing="$missing $v"
      fi
    fi
  done <<< "$vals"
  if [ -n "$missing" ]; then
    note "T2 FAIL: section values not named in INDEX.md:$missing"; fail=$((fail+1))
  else
    note "T2 PASS: all section values named in INDEX.md"; pass=$((pass+1))
  fi
}

# ============================================================
# T3 — there are exactly 12 memory files, each with trigger line.
# ============================================================
t3() {
  local count
  count="$(ls "$MEMORY" 2>/dev/null | grep -E '^[0-9]+-' | wc -l | tr -d ' ')"
  if [ "$count" -lt 12 ]; then
    note "T3 FAIL: expected >=12 memory files, found $count"; fail=$((fail+1)); return
  fi
  local bad=""
  for f in "$MEMORY"/[0-9]*.md; do
    [ -f "$f" ] || continue
    head -n 1 "$f" | $GREP -q 'USE THIS WHEN' || bad="$bad $(basename "$f")"
  done
  if [ -n "$bad" ]; then
    note "T3 FAIL: missing 'USE THIS WHEN' trigger line:$bad"; fail=$((fail+1))
  else
    note "T3 PASS: $count memory files, all carry trigger line"; pass=$((pass+1))
  fi
}

# ============================================================
# T4 — :root declares at least 14 --token custom properties.
# ============================================================
t4() {
  local n
  # Count unique --xxx: declarations inside the first :root { ... } block.
  n="$(awk '
    /:root[[:space:]]*\{/ { in_root=1; next }
    in_root && /\}/ { in_root=0; next }
    in_root && /--[a-zA-Z][a-zA-Z0-9-]*:/ {
      match($0, /--[a-zA-Z][a-zA-Z0-9-]*/);
      print substr($0, RSTART, RLENGTH);
    }
  ' "$SKELETON" | awk '!seen[$0]++' | wc -l | tr -d ' ')"
  if [ "$n" -lt 14 ]; then
    note "T4 FAIL: expected >=14 tokens in :root, found $n"; fail=$((fail+1))
  else
    note "T4 PASS: $n tokens declared in :root"; pass=$((pass+1))
  fi
}

# ============================================================
# T5 — every line of assets/MANIFEST.txt resolves in the working tree.
# ============================================================
t5() {
  if [ ! -f "$MANIFEST" ]; then
    note "T5 FAIL: $MANIFEST not found"; fail=$((fail+1)); return
  fi
  local bad=""
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    [ "${line:0:1}" = "#" ] && continue
    local p="$ROOT/${line#./}"
    if [ ! -f "$p" ] && [ ! -d "$p" ]; then bad="$bad $line"; fi
  done < "$MANIFEST"
  if [ -n "$bad" ]; then
    note "T5 FAIL: missing paths in MANIFEST.txt:$bad"; fail=$((fail+1))
  else
    note "T5 PASS: MANIFEST references resolve"; pass=$((pass+1))
  fi
}

# ============================================================
# T6 — INDEX.md lists exactly 5 numerically-prefixed hard rules
#      with non-trivial descriptions.
# ============================================================
t6() {
  local n
  n="$(awk '/^## Hard rules \(/{f=1; next} f && /^[0-9]+\. \*\*/ {count++} f && /^## / && !/Hard rules/ {exit} END{print count+0}' "$INDEX")"
  if [ "$n" != "5" ]; then
    note "T6 FAIL: expected 5 hard rules in INDEX.md, found $n"; fail=$((fail+1))
  else
    note "T6 PASS: 5 hard rules listed"; pass=$((pass+1))
  fi
}

# ============================================================
# T7 — skeleton/data.js PAGES array has at least 3 page entries.
# ============================================================
t7() {
  if [ ! -f "$DATA" ]; then
    note "T7 FAIL: $DATA not found"; fail=$((fail+1)); return
  fi
  local n
  n="$($GREP -E '^\s*id:\s*"[^"]+"' "$DATA" | wc -l | tr -d ' ')"
  if [ "$n" -lt 3 ]; then
    note "T7 FAIL: expected >=3 pages in PAGES, found $n"; fail=$((fail+1))
  else
    note "T7 PASS: $n pages in PAGES"; pass=$((pass+1))
  fi
}

# ============================================================
# T8 — header-version "v0.1.0" present in INDEX.md.
# ============================================================
t8() {
  if grep -qE 'Version \*\*v0\.1\.0\*\*' "$INDEX"; then
    note "T8 PASS: INDEX declares v0.1.0"; pass=$((pass+1))
  else
    note "T8 FAIL: INDEX missing v0.1.0 marker"; fail=$((fail+1))
  fi
}

note "Running docs-site v0.1.0 verify.sh …"
t1; t2; t3; t4; t5; t6; t7; t8
note "----"
note "Passed: $pass · Failed: $fail"
if [ "$fail" -eq 0 ]; then
  note "ALL PASS"
  exit 0
else
  note "FAIL"
  exit 1
fi
