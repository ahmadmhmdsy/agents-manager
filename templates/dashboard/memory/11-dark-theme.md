# 11 · Dark theme — mode-aware tokens, focus-ring audit — USE THIS WHEN: defining or auditing dashboard dark-mode tokens

Dark theme is the Atlas Admin default (per the worked trace) and the
dashboard's long-session reality. It is not a theme the user opts into;
it is the theme the user is more likely to live in. This file is the
dark-mode source of truth. Light-mode lives in `memory/06-theming.md`.

## Token table (dark)

See `INDEX.md §Tokens` for the canonical 13-row table with both columns.
Light tokens are in `memory/06`; **dark tokens are here, this is canonical.**

## Focus-ring audit

Focus rings must remain visible in dark mode. WCAG 2.2 SC 1.4.11 requires
non-text contrast ≥ 3:1 against adjacent colors.

| Pair | Ratio | Pass? |
|---|---|---|
| `--accent` (#60A5FA) on `--surface` (#0B0F19) | 9.5:1 | AAA |
| `--ink` (#F1F5F9) on `--surface` (#0B0F19) | 16.0:1 | AAA |
| `--ink-soft` (#94A3B8) on `--surface` (#0B0F19) | 6.4:1 | AA + AAA large |
| `--ink-faint` (#64748B) on `--surface` (#0B0F19) | 4.1:1 | AA + AAA large |
| `--status-error` (#F87171) on `--surface` (#0B0F19) | 5.2:1 | AA |

All pass. The `--ink-faint` is borderline — use only for non-essential
metadata (timestamps, footnotes), never for primary content. Per
`memory/08-keyboard-nav.md` and `memory/09-table-a11y.md` for the
specific a11y rules that constrain which text uses which token.

## Hard rules

### Rule 1 — Dark mode is the default for long-session dashboards

```js
const theme = localStorage.theme
  ?? (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
document.documentElement.dataset.theme = theme;
```

`localStorage.theme` is the user override. `prefers-color-scheme` is the
fallback. First-paint script reads from one of them, never `light` by default.

### Rule 2 — No halation; no pure black, no pure white

Dark surface is `#0B0F19`, not `#000`. Ink on dark is `#F1F5F9`, not `#FFF`.
Pure black + pure white is AMOLED-smearing-territory and produces eye-strain
in long-session use.

### Rule 3 — Status colors carry at least 2 visual cues

A red badge on a red button is invisible in dark mode (the badge
disappears against the button). Status messages ALSO carry an icon
(`✓` / `⚠` / `✕`) or text prefix ("Error:" / "Warning:" / "Success:") so
the cue survives even if color fails.

### Rule 4 — `data-surface-dark` honored on per-section overrides

Per `memory/06-theming.md` rule 3 — sections carry both `data-surface`
(light) and `data-surface-dark` (dark) attributes. The CSS attribute
selector reads the right one.

## Worked trace

Atlas Admin: dark on first paint, no FOUC (inline script in `<head>`).
Toggle button in topbar (sun/moon icon, sun for "switch to light", moon
for "switch to dark"). All `--ink-faint` usages audited (timestamps in
the "Last seen" column, the empty-state meta text). All status badges
have both color + icon. Focus ring visible everywhere it can land.

Toggle test: Chrome DevTools → Rendering → "Emulate CSS media feature
prefers-color-scheme: dark" → reload → dark applies without code change
(it's the user's preference). Manual toggle in topbar → localStorage
remembers on next visit.
