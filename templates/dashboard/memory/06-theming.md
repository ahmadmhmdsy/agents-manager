# 06 · Theming — 13 light-mode tokens, switching via data-theme attribute — USE THIS WHEN: defining dashboard tokens and switching themes via data-theme attribute

Two themes: `light` (the default for hero shots) and `dark` (the default for
long-session dashboards — Atlas Admin ships dark by default per the recipe).
Themes switch at runtime via `<html data-theme="…">`; tokens live in
`:root[data-theme="light"]` and `:root[data-theme="dark"]`.

## Token table (light + dark)

See `INDEX.md §Tokens` for the canonical 13-row table. **This memory file is
the single source of truth for light tokens; dark mode lives in
`memory/11-dark-theme.md`** (per the rule "one source of truth per concern").

## How to add a new token (do not, unless the worked example forces it)

Per `AUTHORING.md` Rule 1: do not add a token unless the worked example proves
it is needed. Adding speculative tokens is a leading indicator of over-engineering.

If the worked example forces one:

1. Append a row to the token table in `INDEX.md`.
2. Append the light value to this file.
3. Append the dark value to `memory/11-dark-theme.md`.
4. Update the `data-surface` / `data-surface-dark` attributes on the
   affected section in `skeleton/index.html`.

## Hard rules

### Rule 1 — Tokens via `var(--token)` everywhere; no hex literals in CSS rules

Hex literals belong in `:root[data-theme="…"]` declarations only. Inside the
component rules, every color is `var(--token)`. This way the design system
is grep-auditable: `grep -rE '#[0-9a-f]{6}' skeleton/index.html | wc -l`
should equal the token-table row count (13 light + 13 dark + 1 transparent
escape).

### Rule 2 — Theme switch reads `localStorage.theme`, default `dark`

```js
const theme = localStorage.theme
  ?? matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
document.documentElement.dataset.theme = theme;
```

`document.documentElement.dataset.theme = 'light'` is the flip. No FOUC if
the inline `<script>` runs at the top of `<head>` (defer is OK, async is not).

### Rule 3 — Per-section override via `data-surface` / `data-surface-dark`

For sections that need a different background than the page:

```html
<section data-section="metrics"
         data-surface="#FFFFFF"
         data-surface-dark="#0B0F19">
```

The theme-controller CSS attribute selector reads the right value on toggle:

```css
:root[data-theme="light"] [data-surface]:not([data-surface=""]) {
  background-color: attr(data-surface color, var(--surface));
}
:root[data-theme="dark"] [data-surface-dark]:not([data-surface-dark=""]) {
  background-color: attr(data-surface-dark color, var(--surface));
}
```

(Fallback to `var(--surface)` when the attr is empty.)

## Worked trace

Atlas Admin: 13 light tokens + 13 dark tokens, all consumed via `var(--…)`.
Inline `<script>` in `<head>` reads `localStorage.theme` on first paint so
the user never sees the wrong theme flash. The metrics section uses
`data-surface` + `data-surface-dark` to keep contrast against the darker
app-shell surface.
