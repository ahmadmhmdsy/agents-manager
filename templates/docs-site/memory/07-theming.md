# 07 · theming — USE THIS WHEN: adding/changing CSS custom properties

All visual tokens live in `:root` inside `skeleton/index.html`. Tokens are the
**only** thing a brand override touches. Adding a new token is a v0.2.0
conversation, not a quick fix.

## The 14 tokens

See `INDEX.md` § Tokens (14) for the full list with semantics. Two categories:

- **Surface / ink / line / accent (10)** — same names, same meaning across
  light and dark. Light + dark variants differ only in value.
- **Code (4)** — `--code-bg`, `--code-fg`, `--code-inline-bg`, `--code-border`.
  Code blocks are the doc site's distinctive surface; they get dedicated tokens
  so brand overrides can leave text untouched but tweak code contrast.

## Light vs dark

Theme switch via `data-theme="dark"` on `:root`. Default theme is light:

```css
:root {
  --surface: #ffffff;
  --ink: #0b0d12;
  --accent: #4338ca;
  /* ... */
}
:root[data-theme="dark"] {
  --surface: #0b0d12;
  --ink: #f3f4f6;
  --accent: #818cf8;
  /* ... */
}
```

Toggle pattern (no flash on reload):

```js
const saved = localStorage.getItem("theme");
if (saved === "dark") document.documentElement.dataset.theme = "dark";
```

## Contrast targets

| Pair | Min contrast |
|---|---|
| `--ink` on `--surface` | 7:1 (text), 4.5:1 (≥18px) |
| `--ink-soft` on `--surface` | 4.5:1 |
| `--code-fg` on `--code-bg` | 7:1 — code gets AAA |
| `--accent` (text) on `--surface` | 4.5:1 — links must read |
| `--ink-faint` on `--surface` | 3:1 (UI components only, not body text) |

`11-dark-theme.md` covers the dark-specific exceptions.

## Brand overrides

A consumer overrides **values, not names**. The recipe in `examples/_recipe.md`
is the canonical pattern: 2 tokens override and the rest inherits.

## Common drift

- Reaching for a new token because "this surface is slightly different". Use an
  existing token's value; if no existing token fits, that's a v0.2.0 conversation.
- Deciding the theme based on `prefers-color-scheme` only. The user must always
  be able to override, and the choice must persist in `localStorage`.
