# 10 · screen-reader-a11y — USE THIS WHEN: ARIA, landmarks, live regions are in scope

Screen-reader output for a docs page in the right order, given the right HTML,
sounds like an audio version of the page: skip link → primary nav → heading →
content → secondary nav → footer. Everything in this file exists to make that
happen without manually annotating every element.

## Landmarks

| Region | Element | Label |
|---|---|---|
| Skip link | `<a class="skip">` | (visible text "Skip to content") |
| Topbar | `<header>` | implicit |
| Sidebar | `<nav>` | `aria-label="Pages"` |
| Main | `<main>` | implicit + `<h1>` inside |
| TOC | `<nav>` or `<aside>` | `aria-label="On this page"` |
| Footer | `<footer>` | implicit |

Two navigation landmarks → must label both, otherwise screen readers call
both "navigation" with no way to distinguish.

## Headings

The article's first heading must be `<h1>` (the page title). Subsequent
headings follow h2 → h3 in order; no skipping. The converter in
`03-markdown-rendering.md` enforces this.

The TOC reuses the article's headings as anchors. A user with a screen reader
gets one announcement per heading via the heading navigation shortcut (e.g.
`H` in NVDA/JAWS). The TOC is supplementary, not the canonical heading list.

## Live regions

Two live regions on the page:

- **Search results count** (`<p class="search-count" aria-live="polite">`).
  Announces on every keystroke change: "5 matches", "No matches".
- **Copy code status** (`<span class="sr-only" aria-live="polite">` near each
  copy button). Announces "Copied" briefly on click.

`polite`, never `assertive`. Nothing in this template is urgent enough to
interrupt the user.

## Hidden text

```css
.sr-only {
  position: absolute;
  width: 1px; height: 1px;
  padding: 0; margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```

Use this for copy-button status, "page X of Y" pagination text, and any
other visual-hide-but-screen-reader-show text. Never set `display: none` on
something you want announced — `display: none` removes it from the
accessibility tree entirely.

## Form controls

The skeleton has one form: the search input. It has:

```html
<label class="sr-only" for="search">Search</label>
<input id="search" type="search" placeholder="Search docs…">
```

The label is `.sr-only` (visual placeholder carries for sighted users).
Never ship a placeholder-only input — when the user types, the placeholder
disappears and there is no label.

## Acceptance

- Run the page through a screen reader (VoiceOver / NVDA / Orca) end-to-end.
- Run an automated axe / Lighthouse a11y audit; zero "serious" or "critical"
  issues.
- Verify landmarks: the page outline in DevTools shows banner → navigation
  (Pages) → main → navigation (On this page) → contentinfo.
- Verify heading order: h1 → h2 → h3, no skips. The converter enforces;
  pasted raw HTML in a page body can violate, so audit pages with raw HTML.
