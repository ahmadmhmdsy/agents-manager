#!/usr/bin/env bash
# verify.sh — placeholder. Add one test per grep-able claim.
# See ../../AUTHORING.md Rule 4 for the rulebook.
#
# Run from the template root:  bash tests/verify.sh
#
# Minimum useful checks:
#   T1 ≥N data-section="…" attrs in skeleton/
#   T2 no frontmatter in memory/*.md
#   T3 every MANIFEST.txt path resolves
#   T4 every memory H1 prefix matches its filename
#   T5 every memory H1 carries "USE THIS WHEN:"

set -uo pipefail
ok=0; fail=0
pass() { ok=$((ok+1)); echo "  PASS: $1"; }
fail_msg() { fail=$((fail+1)); echo "  FAIL: $1"; }

# Replace these placeholders with real tests once memory/ + skeleton/ exist.
pass "T1 placeholder (no skeleton yet)"
pass "T2 placeholder (no memory yet)"
pass "T3 placeholder (no MANIFEST yet)"

echo
echo "OK   : $ok"
echo "FAIL : $fail"
[[ $fail -eq 0 ]] || exit 1
echo "All verify.sh checks passed (placeholder)."
