#!/usr/bin/env bash
# Verify every grep-testable claim in INDEX.md + README + memory/.
# Exit non-zero on first failure.
#
# Tests cover:
#   T1  exactly N distinct data-section="…" values in skeleton/index.html,
#       where N is parsed from INDEX.md "## Sections (N)"
#   T2  no frontmatter (---) in memory/*.md
#   T3  every line of assets/MANIFEST.txt that names a path resolves
#   T4  every memory file's H1 number matches its filename prefix (01..NN)
#   T5  every memory file's H1 carries a "USE THIS WHEN:" trigger line
#   T6  the empty-state hook (class="is-empty") is wired in skeleton
#       (Hard rule 1: no fake rows)
#   T7  every <th> in the skeleton has scope="col" or scope="row" (Hard rule 4)
#   T8  every <input> in the skeleton has an associated <label for="…">
#       (Hard rule 3: form a11y)
#
# Run from the template root:
#   bash tests/verify.sh
# Or from repo root:
#   bash templates/dashboard/tests/verify.sh
#
# Uses rg if available; falls back to grep -E otherwise.

set -uo pipefail

# Auto-detect template root + repo root from the script location.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$TEMPLATE_ROOT/../.." && pwd)"

SKELETON="$TEMPLATE_ROOT/skeleton/index.html"
INDEX="$TEMPLATE_ROOT/INDEX.md"
MEMORY_DIR="$TEMPLATE_ROOT/memory"
MANIFEST="$TEMPLATE_ROOT/assets/MANIFEST.txt"

# rg preferred; grep -E fallback.
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
# count declared in INDEX.md ("## Sections (N)").
# Scope: HTML opening tags only. CSS attribute selectors like
# `[data-section="data-table"]` are intentionally excluded — they reuse
# the same value across multiple rules and are not a duplicate concern.
test_sections_exact_and_distinct() {
  local n_index
  n_index=$(_xgrep -ho '## Sections \([0-9]+\)' "$INDEX" | grep -oE '[0-9]+' | head -1 || true)
  if [[ -z "$n_index" ]]; then
    fail_msg "T1 cannot parse '## Sections (N)' from $INDEX"
    return
  fi
  # Only count data-section values that appear on a real HTML opening tag.
  # Scope: lines beginning with a known block-element tag name (body, header,
  # nav, section, footer, main, aside) followed by attributes + data-section=.
  # This excludes:
  #   - CSS attribute selectors like `[data-section="..."]` on their own lines
  #   - HTML comments `<!-- ─────── Topbar (data-section="topbar") ─────── -->`
  #   - JS strings `'[data-section="..."]'` inside <script>
  # all of which would otherwise inflate the count.
  local values_file
  values_file="$(mktemp)"
  _xgrep -nE '^\s*<(body|header|nav|section|footer|main|aside)\b[^>]*\bdata-section="[^"]+"' "$SKELETON" \
    | grep -oE 'data-section="[^"]+"' \
    | sort -u > "$values_file" || true
  local n_actual
  n_actual=$(wc -l < "$values_file" | tr -d ' \t')
  if [[ "$n_actual" != "$n_index" ]]; then
    rm -f "$values_file"
    fail_msg "T1 INDEX says $n_index sections but skeleton has $n_actual distinct data-section values"
    return
  fi
  # Within HTML tags, verify no value is duplicated (one element per section).
  local dup_count
  dup_count=$(_xgrep -nE '^\s*<(body|header|nav|section|footer|main|aside)\b[^>]*\bdata-section="[^"]+"' "$SKELETON" \
              | grep -oE 'data-section="[^"]+"' \
              | sort | uniq -d | wc -l | tr -d ' \t' || true)
  rm -f "$values_file"
  if [[ "$dup_count" != "0" ]]; then
    fail_msg "T1 $dup_count duplicate data-section value(s) on HTML elements in skeleton"
    return
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
test_manifest_resolves() {
  local missing=()
  while IFS= read -r raw || [[ -n "$raw" ]]; do
    local line="${raw%%#*}"
    line="$(echo "$line" | tr -d ' \t')"
    [[ -z "$line" ]] && continue
    [[ "${line:0:1}" == "#" ]] && continue
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
test_h1_matches_filename() {
  local bad=()
  for f in "$MEMORY_DIR"/*.md; do
    local prefix h1
    prefix=$(basename "$f" | grep -oE '^[0-9]+')
    h1=$(head -n 1 "$f" | sed -nE 's/^#[[:space:]]+([0-9]+).*/\1/p' || true)
    if [[ -z "$h1" ]]; then
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

# T6: empty-state class hook is wired (Hard rule 1: no fake rows).
test_empty_state_class_wired() {
  if _xgrep -q 'class="[^"]*\bis-empty\b' "$SKELETON"; then
    pass "T6 .is-empty class is wired in skeleton (Hard rule 1)"
  else
    fail_msg "T6 missing 'class=… is-empty …' hook in skeleton — empty state not grep-auditable"
  fi
}

# T7: every <th> in skeleton has scope="col" or scope="row" (Hard rule 4).
# Match `<th>` or `<th ` (followed by `>` or whitespace) so `<thead>` and
# `<th colspan>` both behave correctly. Without the trailing `>` or space
# guard, the regex would over-match `<thead>` as `<th>`.
test_ths_have_scope() {
  local ths unlabeled
  ths=$(_xgrep -ohE '<th(>| )[^>]*' "$SKELETON" || true)
  if [[ -z "$ths" ]]; then
    fail_msg "T7 no <th> tags found in skeleton"
    return
  fi
  unlabeled=()
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if ! echo "$line" | grep -qE 'scope="(col|row)"'; then
      unlabeled+=("$line")
    fi
  done <<< "$ths"
  if [[ ${#unlabeled[@]} -eq 0 ]]; then
    pass "T7 every <th> in skeleton has scope=col|row (Hard rule 4)"
  else
    fail_msg "T7 <th> without scope: ${unlabeled[*]}"
  fi
}

# T8: every <input> in skeleton has an associated <label for="…"> (Hard rule 3).
test_inputs_have_labels() {
  local ids missing
  ids=$(_xgrep -ohE '<input[^>]*id="[^"]+"' "$SKELETON" \
        | grep -oE 'id="[^"]+"' \
        | grep -oE '"[^"]+"' \
        | tr -d '"' \
        | sort -u || true)
  if [[ -z "$ids" ]]; then
    fail_msg "T8 no <input id=\"...\"> tags found in skeleton"
    return
  fi
  missing=()
  while IFS= read -r id; do
    [[ -z "$id" ]] && continue
    if ! _xgrep -q "<label[^>]*for=\"$id\"" "$SKELETON"; then
      missing+=("$id")
    fi
  done <<< "$ids"
  if [[ ${#missing[@]} -eq 0 ]]; then
    pass "T8 every <input> in skeleton has <label for=...> (Hard rule 3)"
  else
    fail_msg "T8 inputs without matching labels: ${missing[*]}"
  fi
}

# ── run all ──
test_sections_exact_and_distinct
test_no_frontmatter_on_memory
test_manifest_resolves
test_h1_matches_filename
test_h1_has_trigger_line
test_empty_state_class_wired
test_ths_have_scope
test_inputs_have_labels

echo
echo "OK   : $ok"
echo "FAIL : $fail"
if [[ $fail -gt 0 ]]; then
  exit 1
fi
echo "All verify.sh checks passed."
