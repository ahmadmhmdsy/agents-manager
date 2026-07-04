# 01 · builder-flow — USE THIS WHEN: starting a new docs site from this template

The 8-step procedure for shipping a docs site from `docs-site/`. Follow it in order;
each step depends on the one before. Skipping a step is the most common way to end up
with a site that does not pass `verify.sh`.

## Step 1 — Confirm the brief fits this template

The brief must contain **two or more** of: multi-page content, sidebar with groups,
on-this-page TOC, full-text search, code blocks with copy button, prev/next paging,
light/dark theme, accessibility-grade markup. If only ONE is named, consult
[`../dashboard/`](../dashboard/) first — it covers single-page shells better.

## Step 2 — Author the page taxonomy

Read `02-content-shape.md`. Decide the **groups** and **pages** with the consumer.
A page belongs to exactly one group. Each page has `id`, `title`, `group`, `order`,
and optionally `summary`.

## Step 3 — Write the Markdown content

Per page, follow `10-screen-reader-a11y.md` rule 1: exactly one `<h1>` per page
(in Markdown: a single `# Title` line). Heading levels may not skip (h2 → h3 ok;
h2 → h4 not ok).

## Step 4 — Apply brand tokens (if any)

Read `07-theming.md` and `11-dark-theme.md`. Most brand work is changing `--accent`
and `--accent-soft` only. Don't introduce new tokens.

## Step 5 — Wire navigation

Read `05-navigation-and-sidebar.md`. Sidebar groups are `<details>` elements so
they work without JS. Active page is `aria-current="page"`.

## Step 6 — Search + TOC + keyboard

Read `06-search.md`, `02-content-shape.md` § toc, and `09-keyboard-nav.md` in that
order. Each adds one feature; they don't interact.

## Step 7 — Verify

```
$ bash tests/verify.sh
```

All eight tests must exit 0. T1 (section count) is the most common failure
after edits; see `tests/README.md`.

## Step 8 — Acceptance checklist

Open `12-quality-bar.md` and tick each row. The checklist is the Rule 8 contract.

## Common drift

- Adding a feature that needs another `data-section` value → bump to v0.2.0 or
  update `INDEX.md` and add a memory file (see Rule 3 — monotonic).
- Reaching for a library (Prism / Fuse / Pagefind) → STOP. D-007 + D-009 +
  D-008 are binding in v0.1.0; vanilla only.
- Renaming a memory file → no. Names are part of the API.
