# 12 · Quality bar — pre-merge gate: structural + visual + a11y + perf + state — USE THIS WHEN: running the pre-merge quality bar (visual + a11y + perf + empty-state check)

Nothing ships without passing the quality bar. The bar has 5 gates; each
gate has at least one programmatic check + a manual check.

## Gate 1 — Structural (verify.sh)

```bash
bash tests/verify.sh
```

Exit 0 = PASS. The 8 tests in `tests/verify.sh` cover: 7 distinct
data-section values, no frontmatter on memory files, every MANIFEST path
resolves, every memory H1 prefix matches its filename, every memory H1
carries the trigger line, empty-state CSS class wired, table caption +
scope present, every form input has a label.

Skip a test → bug ships. See `tests/verify.sh` for the test list.

## Gate 2 — Empty-state check (manual + automated)

```bash
# Manual: visit ?q=zzzzzz or click "Clear filters" then visit ?q=
# Verify: empty-state block visible, no fake rows in DOM
```

The skeleton ships a `?data=mock|empty|error` debug toggle that makes
each state testable. See `memory/05-loading-empty-error-states.md`.

## Gate 3 — Axe-core a11y (automated)

```bash
npx @axe-core/cli skeleton/index.html --exit --tags wcag2a,wcag2aa,wcag22aa
```

Exit non-zero + any critical/serious = FAIL. The template's a11y floor
items per `memory/08`/`09`/`10` are all standard axe rules; no custom
checks needed for v0.1.0.

## Gate 4 — Visual (manual)

Load in Chrome, Firefox, Safari. Toggle:

- light ↔ dark
- normal motion ↔ reduced motion (`prefers-reduced-motion: reduce`)
- empty state ↔ ready state
- form submission failure ↔ success

For each: layout doesn't break, focus rings visible, no content shift
on theme toggle, no broken `var(--token)` (would render as the inherited
default, often black-on-black).

## Gate 5 — Reduced-motion + URL refresh (manual)

1. Open `/#/users?sort=email&dir=desc&page=2`.
2. Refresh — page state intact.
3. Hit back — goes to previous route.
4. Hit forward — returns to `#/users?sort=email&dir=desc&page=2` intact.
5. Toggle reduced-motion OS setting, no reload → animations gate.

If any of these break, the URL-as-source-of-truth rule is broken (per
`memory/02` rule 2). Bug ships.

## Hard rules

### Rule 1 — Run all 5 gates before every PR

PRs without verify.sh exit 0 are unmergeable. Reviews that don't run
gates 3–5 are unchecked. Per `CLAUDE.md §Don't do: do NOT skip the
review phase because 'it looks fine.'`

### Rule 2 — Bugs found post-merge → fix loop

The pipeline allows max_fix_loops = 3. After 3, surface to the user.

### Rule 3 — Grep-auditable claims must be caught at Gate 1

If a hard rule can be grep-audited (table has caption, scope present,
input has label, etc.), it belongs in `tests/verify.sh`, not in manual
Gate 4. The grep test runs in CI; the manual test runs only when
someone remembers.

## Worked trace

Atlas Admin v0.1.0: Gate 1 green (verify.sh exit 0, all 8 tests
passing). Gate 2 green (empty + error + ready all rendered). Gate 3
green (axe-core 0 critical, 0 serious on light + dark variants). Gate 4
green across Chrome/Firefox/Safari. Gate 5 green (URL round-trip clean).

PR review: ship.
