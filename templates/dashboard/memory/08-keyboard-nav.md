# 08 · Keyboard nav — Tab order, focus rings, /, Esc, ? — USE THIS WHEN: wiring Tab order, focus rings, /, Esc, and section-skip links

Keyboard nav for a dashboard is the same as any web app — Tab order matters,
focus rings are visible, no traps, no surprises. Two dashboard-specific
additions: the `/` shortcut for global search, and the `?` shortcut for a
help overlay (deferred to v0.2.0).

## Focus skip link

```html
<a class="skip" href="#main">Skip to main content</a>
```

Becomes visible on focus (`outline: 2px solid var(--accent)`). Tab order:
skip-link → topbar controls → sidebar links → main.

## Global shortcuts

| Key | Action | Where |
|---|---|---|
| `/` | Focus global search input | topbar |
| `Esc` | Clear active filter OR close any open modal | anywhere |
| `Enter` on form field | Submit form | form |
| `Tab` | Move to next focusable | global |
| `Shift+Tab` | Move to previous focusable | global |
| `?` | Open help overlay | anywhere — v0.2.0 deferred |

The `/` handler should ignore the keypress when the user is already typing
in an `<input>` or `<textarea>` — don't yank focus away mid-edit.

## Hard rules

### Rule 1 — Visible focus on every focusable element

```css
:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}
```

No `outline: none` without replacement. The replacement must pass WCAG 2.2
non-text contrast (>= 3:1 against background).

### Rule 2 — Tab order follows reading order

Tab order is determined by source order in the DOM. Don't use
`tabindex="0"` to reorder — fix the DOM. A dashboard's natural reading
order is topbar → sidebar → main (data-table first, then form).

### Rule 3 — Sort buttons announce their action

```html
<button type="button" aria-label="Sort by email, descending">...</button>
```

`aria-label` is dynamic — updates as the sort flips between ascending and
descending. Per `memory/09-table-a11y.md`.

## Worked trace

Atlas Admin: skip-link → topbar search → topbar user-menu → sidebar links
(3) → data-table (sort buttons + filter inputs + pagination) → form (4
fields + submit) → footer. Total tab stops: ~16. `/` from anywhere on the
page except inside a focused input/textarea jumps to the search input and
selects all text. `Esc` from the search input clears it.

Focus-ring contrast: `--accent` (#2563EB on light) on `--surface` (#FFFFFF)
= 7.2:1 → passes WCAG AAA. Dark mode: `--accent` (#60A5FA on dark) on
`--surface` (#0B0F19) = 9.5:1 → also passes. Per `memory/11-dark-theme.md`
for the full audit.
