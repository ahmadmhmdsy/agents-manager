# docs-site · INDEX

> Version **v0.1.0** · single-page app that renders Markdown pages into a docs site
> with sidebar nav, TOC, search, code blocks, paging, and theme.
> This file is the machine-greppable map of every convention in this template.

## Sections (6)

Every visible region of `skeleton/index.html` is tagged with `data-section="<name>"`.
Verify.sh asserts these six distinct values:

- `app-shell` — outer page wrapper; skip link lives here
- `topbar` — version + search + edit-on-GitHub links
- `sidebar-nav` — collapsible page groups + active page highlight
- `main` — rendered Markdown page content (article)
- `toc-aside` — on-this-page right-side anchors (built from h2/h3)
- `footer` — prev/next paging + last-updated stamp

## Memory files (12)

Authored monotonic; H1 trigger line format follows Rule 6.

- `memory/01-builder-flow.md` — USE THIS WHEN: starting a new docs site from this template
- `memory/02-content-shape.md` — USE THIS WHEN: designing the page taxonomy (groups, pages, manifest)
- `memory/03-markdown-rendering.md` — USE THIS WHEN: extending the inline MD converter
- `memory/04-code-blocks.md` — USE THIS WHEN: styling code, adding the copy button, naming languages
- `memory/05-navigation-and-sidebar.md` — USE THIS WHEN: collapsing groups, marking active page
- `memory/06-search.md` — USE THIS WHEN: tuning the client-side inverted index or result rendering
- `memory/07-theming.md` — USE THIS WHEN: adding/changing CSS custom properties
- `memory/08-reduced-motion.md` — USE THIS WHEN: any UI animation is in scope
- `memory/09-keyboard-nav.md` — USE THIS WHEN: adding shortcuts or tabbable controls
- `memory/10-screen-reader-a11y.md` — USE THIS WHEN: ARIA, landmarks, live regions are in scope
- `memory/11-dark-theme.md` — USE THIS WHEN: tweaking dark-mode contrast, especially code blocks
- `memory/12-quality-bar.md` — USE THIS WHEN: running the Rule 8 acceptance checklist

## Tokens (23)

CSS custom properties declared in `:root` of `skeleton/index.html`. Both light and dark
themes use the same names; only the values differ. **Brand work touches the semantic
14; the layout 9 are layout primitives and rarely overridden.**

### Semantic (14) — what brand overrides touch

- `--surface` — page background
- `--surface-2` — sidebar / code-block background
- `--surface-3` — elevated cards / hover state
- `--ink` — primary text
- `--ink-soft` — secondary text + code-block foreground
- `--ink-faint` — muted text, meta
- `--line` — hairlines, card borders
- `--line-soft` — softer hairlines, table borders
- `--accent` — links, active nav, focus rings
- `--accent-soft` — accent tint (active sidebar item, link hover bg)
- `--code-bg` — `<pre>` background (defaults to `--surface-2`)
- `--code-fg` — `<pre>` foreground (defaults to `--ink-soft`)
- `--code-inline-bg` — inline `<code>` background tint
- `--code-border` — `<pre>` border / scroll-shadows

### Layout / typography (9) — rarely overridden

- `--radius` — corners (cards, code blocks, buttons)
- `--gap` — small spacing unit
- `--gap-lg` — large spacing unit
- `--topbar-h` — topbar height
- `--sidebar-w` — sidebar width
- `--toc-w` — on-this-page width
- `--content-max` — article max width
- `--font-body` — body font stack
- `--font-mono` — code font stack

## Hard rules (5)

Numbered. Skeleton enforces each via dedicated markup/CSS/JS. Listed here for grep-discoverability.

1. **Every page has a real h1.** No skipped heading levels; h2 → h3 in order; no `<div>` headings.
2. **Code blocks have a copy button + accessible name.** Every `<pre>` ships a button with
   `aria-label="Copy code"`; visual label is the icon; status announced via `aria-live`.
3. **Skip link works; landmarks are semantic.** `<aside aria-label="Page contents">` for the
   TOC; `<nav aria-label="Pages">` for the sidebar; skip link is first focusable element.
4. **Search shows count and respects empty state.** Result list carries `aria-live="polite"`;
   zero-result message reads "No matches for '<query>'".
5. **Reduced motion is honored.** Sidebar collapse and TOC scroll are instant when
   `prefers-reduced-motion: reduce`. No auto-scrolling on page load.

## Files

```
docs-site/
  00-readme-first.md
  INDEX.md
  decisions/
    decision-log.md
  memory/
    01-builder-flow.md
    02-content-shape.md
    03-markdown-rendering.md
    04-code-blocks.md
    05-navigation-and-sidebar.md
    06-search.md
    07-theming.md
    08-reduced-motion.md
    09-keyboard-nav.md
    10-screen-reader-a11y.md
    11-dark-theme.md
    12-quality-bar.md
  skeleton/
    index.html
    data.js
  prompts/
    scaffolding.md
  assets/
    MANIFEST.txt
    README.md
  examples/
    _recipe.md
  tests/
    verify.sh
    README.md
```

## Companion templates

Use these together when one template can't carry the full brief:

- [`dashboard/`](../dashboard/) — when the docs need a sortable table, form, or admin shell
  in addition to reference pages.
- [`cinematic-landing/`](../cinematic-landing/) — when the docs site needs a marketing
  hero on its `/` landing page.
