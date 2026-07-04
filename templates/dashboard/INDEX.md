# dashboard — INDEX

> Read this file first. It is the only file you must read end-to-end.

## How to use this template as an agent

1. **Read this file end-to-end.** It is the only INDEX read required.
2. **For each concern you are about to implement, grep the trigger line.**
   Search `memory/*.md` for the literal `USE THIS WHEN:` and load only the
   file(s) whose trigger matches your current concern. Do not read all memory files.
3. **After implementing, run `bash tests/verify.sh`** from the template root.
   Exit 0 means your changes did not break the skeleton's grep-testable
   contracts. Exit non-zero lists the first failure; fix and re-run.

If a concern matches no trigger line, the concern is not yet documented — flag it
and add a memory file at the next monotonic number.

## Sections (7)

Every section carries a `data-section` attribute on its root element.
Grep target: `data-section="<id>"`.

| ID | Element | Role |
|---|---|---|
| `app-shell` | `<body data-section="app-shell">` | top-level wrapper; mounts the dark-theme toggle + reduced-motion listener |
| `topbar` | `<header data-section="topbar">` | product name + global search input + user menu stub |
| `sidebar` | `<nav data-section="sidebar">` | route-aware nav; active link carries `aria-current="page"` |
| `data-table` | `<section data-section="data-table">` | sortable, filterable, paginated; data-state="empty\|loading\|ready\|error" |
| `metrics` | `<section data-section="metrics">` | 3-cell metrics row (v0.1.0); chart-card deferred to v0.2.0 |
| `form` | `<section data-section="form">` | field-level validation; submit gating; aria-describedby errors |
| `footer` | `<footer data-section="footer">` | placeholder; copyright stays fictitious in demos |

## Runtime branches (3)

The template MUST work on every data state. `memory/05-loading-empty-error-states.md`
picks a branch at build time; the build records it in `assets/MANIFEST.json`.

- **A** — in-memory mock (`skeleton/data.js`, no fetch, no server). **Default.**
- **B** — REST endpoint (`fetch` + JSON; same data-shape manifest).
- **C** — nothing yet (skeleton renders the empty state; `?data=mock` debug toggle
  to fall back to Branch A).

## Hard rules (5)

1. **No fake rows.** If `data === null`, render the empty state — never invent
   placeholder rows. See `memory/05-loading-empty-error-states.md`.
2. **URL is the source of truth** for sort/filter/page. Refresh persists; back
   button works. See `memory/02-routing-and-layout.md` rule 2.
3. **Form a11y:** every `<input>` has a `<label for="…">`; every error has
   `aria-describedby="…"` pointing to the error `<span>`. See `memory/10-form-a11y.md`.
4. **Table a11y:** `<table>` has a `<caption>`; every `<th>` has `scope="col"` or
   `scope="row"`. See `memory/09-table-a11y.md`.
5. **Reduced motion honored** at two layers: CSS `@media (prefers-reduced-motion: reduce)`
   + JS `matchMedia` listener (mid-session toggle). See `memory/07-reduced-motion.md`.

## Tokens (13 + dark-mode override)

13 light-mode tokens + 13 dark-mode counter-table live in `memory/06-theming.md`
(light) + `memory/11-dark-theme.md` (dark, canonical, WebAIM-audited).
One source of truth per concern; `memory/06` references `memory/11` for dark.

| Token | Light | Dark |
|---|---|---|
| `--surface` | `#FFFFFF` | `#0B0F19` |
| `--surface-2` | `#F8FAFC` | `#111827` |
| `--ink` | `#0F172A` | `#F1F5F9` |
| `--ink-soft` | `#475569` | `#94A3B8` |
| `--ink-faint` | `#94A3B8` | `#64748B` |
| `--line` | `#E2E8F0` | `#1F2937` |
| `--line-soft` | `#F1F5F9` | `#111827` |
| `--accent` | `#2563EB` | `#60A5FA` |
| `--accent-soft` | `#DBEAFE` | `#1E3A8A` |
| `--status-info` | `#3B82F6` | `#60A5FA` |
| `--status-success` | `#10B981` | `#34D399` |
| `--status-warn` | `#F59E0B` | `#FBBF24` |
| `--status-error` | `#EF4444` | `#F87171` |

Per-section overrides: every section carries `data-surface="#hex"` (light) +
`data-surface-dark="#hex"` (dark). The JS theme controller reads the right one
on toggle.

## a11y floor

- **Table a11y** — `memory/09-table-a11y.md` (`<caption>`, `scope="col|row"`, sort-button announcement).
- **Form a11y** — `memory/10-form-a11y.md` (label-association, error `aria-describedby`, focus on submit failure).
- **Keyboard nav** — `memory/08-keyboard-nav.md` (Tab order, `/` to focus search, `Esc` to clear, `?` for help).
- **Reduced motion** — `memory/07-reduced-motion.md` (CSS + JS matchMedia; reload on mid-session toggle).
- **Dark theme** — `memory/11-dark-theme.md` (mode-aware tokens, focus-ring contrast audit).

## Worked example

**Atlas Admin — ops dashboard for a fictional small SaaS.** Skeleton demo at
`templates/dashboard/skeleton/index.html`. Brand brief + memory consultation order
in `examples/_recipe.md`.

The skeleton IS the worked example; the `_recipe.md` is the procedure.

## Per-section cross-reference

Every `data-section` attribute on the skeleton has a memory file that owns it:

| Section | Memory |
|---|---|
| `app-shell` | builder-flow (`memory/01`) + theming (`memory/06`) + dark (`memory/11`) |
| `topbar` | `memory/02-routing-and-layout.md` + keyboard nav (`memory/08`) |
| `sidebar` | `memory/02-routing-and-layout.md` |
| `data-table` | `memory/03-data-table.md` + table a11y (`memory/09`) + empty-state (`memory/05`) |
| `metrics` | builder-flow (`memory/01`) |
| `form` | `memory/04-forms-and-validation.md` + form a11y (`memory/10`) + empty-state (`memory/05`) |
| `footer` | builder-flow (`memory/01`) |

---

**Status:** active · **Version:** v0.1.0 · **Trigger line format:** per
`../AUTHORING.md` Rule 6 (`# NN · <topic> — USE THIS WHEN: …`).
