# 05 · navigation-and-sidebar — USE THIS WHEN: collapsing groups, marking active page

The sidebar must tell the user three things at a glance: **where I am**, **where
I can go**, **where else in the chapter**. Get those three right and the rest of
the site can be average; get them wrong and no amount of search saves you.

## Sidebar structure

```html
<nav class="sidebar-nav" data-section="sidebar-nav" aria-label="Pages">
  <details class="group" open>
    <summary>Getting Started</summary>
    <ul>
      <li><a href="#getting-started" aria-current="page">Getting started</a></li>
      <li><a href="#quick-start">Quick start</a></li>
    </ul>
  </details>
  <details class="group">
    <summary>Guides</summary>
    <ul> ... </ul>
  </details>
</nav>
```

## The three questions

1. **Where I am.** Exactly one link carries `aria-current="page"`. Every other
   link is plain. Highlight via `--accent-soft` background and `--accent` text.
2. **Where I can go.** Every page is reachable from the sidebar. If a page is
   not in `PAGES`, it does not exist.
3. **Where else in the chapter.** Groups carry their pages; the active page
   sits in one group; that group is `<details open>` so the user sees siblings.

## `<details>` for collapse — no JS

`<details>` is a native element that opens/closes on click with no script.
That's the correct primitive. Do NOT replace it with a custom button + JS
state; the browser handles keyboard, ARIA, and animation (or lack of it under
prefers-reduced-motion) for free.

## Active state

On every hash-route change:

```js
function updateActive() {
  document.querySelectorAll('[data-section="sidebar-nav"] a[href^="#"]')
    .forEach(a => a.removeAttribute('aria-current'));
  const current = document.querySelector(
    `[data-section="sidebar-nav"] a[href="#${location.hash.slice(1) || PAGES[0].id}"]`
  );
  if (current) {
    current.setAttribute('aria-current', 'page');
    current.closest('details')?.setAttribute('open', '');
  }
}
```

## Sidebar scroll

On wide screens the sidebar is `position: sticky; top: var(--topbar-h)`. On
narrow screens it is hidden behind a button (≤ 720px) — v0.2.0 may add a slide-in
drawer, but never in v0.1.0 (see `08-reduced-motion.md`).

## Acceptance

- Tab from skip link → first sidebar link → page loads → Tab moves into main.
- A group with the active page is open; sibling groups are closed.
- `aria-current="page"` is on exactly one link at all times; verify by counting
  `:scope [aria-current="page"]` in DevTools (must be 1).
- Refreshing the page on `#errors` lands on `errors` with its group open.
