# 09 · keyboard-nav — USE THIS WHEN: adding shortcuts or tabbable controls

Three constraints in order of priority:

1. **Don't break default browser behavior.** Use `keydown` for shortcuts; let
   `Tab`/`Shift+Tab` cycle focus natively.
2. **Don't trap focus.** Every modal is v0.2.0; the search panel is an inline
   disclosure, not a modal.
3. **Shortcuts are accelerators, not replacements.** `Enter` on a link still
   navigates; `/` focusing the search is **additional** to that.

## Tab order

The order is the document order in `skeleton/index.html`:

1. Skip link (`<a class="skip" href="#main">`)
2. Topbar controls (in document order)
3. Sidebar links
4. Main content links, in order
5. On-this-page links
6. Footer links

Do not set `tabindex` to reorder. If something in main is critical and visually
hidden, give it `tabindex="-1"` and call `.focus()` on it from a handler.

## Shortcuts

| Key | Action | Where handled |
|---|---|---|
| `/` | Focus search input | `topbar` keydown listener |
| `Esc` | Clear search + blur | `topbar` keydown listener |
| `g` then `s` | Focus first sidebar link | main keydown listener |
| `g` then `t` | Focus first TOC link | main keydown listener |
| `?` | (deferred) show shortcut sheet | v0.2.0 |

Two-key shortcuts (`g s`) use a 1-second timeout: store `lastG = Date.now()`,
on next `keydown`, check `if (Date.now() - lastG < 1000) …` then reset.

## Accessible names on icon-only controls

Every button or link without visible text needs:

- An SVG with `aria-hidden="true"` if the icon is decorative.
- A real `aria-label` on the parent button (or visually-hidden text inside it).

```html
<button class="theme-toggle" type="button" aria-label="Toggle theme">
  <svg aria-hidden="true" focusable="false">…</svg>
</button>
```

## Visibility on focus

Default focus ring draws on `--accent`. Never set `outline: none` without a
replacement:

```css
:focus-visible {
  outline: 2px solid var(--accent);
  outline-offset: 2px;
}
```

`focus-visible` (not `:focus`) so mouse clicks do not show the ring; only
keyboard users see it.

## Acceptance

- Tab from `body` cycles through the page without skipping interactive items
  (no `tabindex="-1"` on visible controls).
- Skip link is the first focus stop; pressing `Enter` jumps focus to `#main`.
- `/` from anywhere outside an input focuses the search.
- All visible icon-only buttons expose a real `aria-label`.
