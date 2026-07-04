# 11 · dark-theme — USE THIS WHEN: tweaking dark-mode contrast, especially code blocks

Dark mode is not "light mode with the colours inverted". Three rules capture the
differences that matter; everything else can mirror the light theme exactly.

## Rule 1 — Pure-black surfaces are too dark

`--surface: #000` looks slick in design tools and feels like a hole in production.
Use `#0b0d12` (a near-black with a hint of cool blue) for `--surface`. Add
`#11141a` for `--code-bg` so code blocks feel recessed rather than flooded.

## Rule 2 — Body text needs more contrast, not less

Dark mode text on dark background reads dimmer than the equivalent light mode.
Push `--ink` to `#f3f4f6` (zinc-100) and `--ink-soft` to `#c7c9d1`. Both meet
the AAA 7:1 target on `#0b0d12`. Don't try to "soften" with lower contrast —
the user picked dark mode, they still want to read.

## Rule 3 — Accent desaturates

`#4338ca` (indigo-700) reads as electric on white; the same hue on black
vibrates. Pull saturation down and lightness up: `#818cf8` (indigo-400) for
dark mode. Same pattern applies to any brand `--accent` override.

## Code-specific

Code blocks live in `<pre>` with `--code-bg`. The text in dark mode uses
`--code-fg` (a slightly desaturated `--ink-soft` so it doesn't shout next to
the body). Hand-marked colour spans — if the author used them — need a
separate dark-mode palette:

```css
:root[data-theme="dark"] .k { color: #c4b5fd; }  /* keyword — violet */
:root[data-theme="dark"] .s { color: #86efac; }  /* string  — green */
:root[data-theme="dark"] .c { color: #6b7280; }  /* comment — slate */
:root[data-theme="dark"] .n { color: #fcd34d; }  /* number  — amber */
:root[data-theme="dark"] .f { color: #93c5fd; }  /* fn      — blue */
:root[data-theme="dark"] .t { color: #f9a8d4; }  /* type    — pink */
```

Six classes. Stop at six.

## Focus rings

Focus rings in dark mode stay `--accent` (the desaturated variant). Never
change the focus ring colour between themes — it must remain stable so the
user always knows where focus is.

## Form controls

The search input gains a 1px `--line` border in dark mode that isn't visible
in light mode (where the input inherits the surface). Don't add the border in
both themes — pick the one where it's needed (dark) and let light mode
inherit.

## Toggle placement

The theme toggle is in `topbar`, rightmost. It carries
`aria-label="Toggle theme"` and `aria-pressed` reflecting the current theme.

## Acceptance

- All text passes 7:1 in dark mode (run `axe`).
- Code blocks have visible contrast against their `<pre>` background.
- Brand `--accent` override carries cleanly to dark mode (verify by changing
  the override and reloading in both themes).
- Toggle persists across reload (`localStorage.getItem("theme")` round-trips).
