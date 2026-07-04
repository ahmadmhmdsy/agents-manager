# 02 · Routing + layout — sidebar, topbar, hash routes, URL state — USE THIS WHEN: shipping a multi-section dashboard shell with sidebar/topbar and route-aware state

Three concerns, in increasing order of subtlety: which section is visible,
which link is active, and which filter/sort/page state persists.

## Routing primitive

Hash routing. Routes are a flat array at the top of the script:

```js
const routes = [
  { hash: '#/dashboard', section: 'data-table',   label: 'Dashboard' },
  { hash: '#/users',     section: 'data-table',   label: 'Users' },
  { hash: '#/settings',  section: 'form',         label: 'Settings' }
];
// optional: { hash, section, label, query: true } — if query:true, sync table state into URL
```

On `hashchange`:

1. Resolve the matching route. Default to `#/dashboard` when no hash or unknown hash.
2. Toggle each `data-section` element's visibility via a single `[hidden]` attribute
   (do not use `display:none`; the `[hidden]` attribute respects focus management).
3. Set the active sidebar link's `aria-current="page"`; unset on others.

## Rule 1 — `[hidden]`, not `display: none`

`[hidden]` is the spec's hide primitive. It removes from the accessibility
tree, the tab order, and screen-reader virtual buffer in one stroke.
`display: none` does the same visually but inconsistently for screen readers
across engines; `visibility: hidden` keeps the element in the tab order.

## Rule 2 — URL is the source of truth for sort/filter/page

Every sort key, filter value, and page number lives in the URL query string.
The script reads from `location.search` on load and writes back via
`history.replaceState` on every state change.

Format:

```
#/users?sort=email&dir=asc&filter_role=admin&page=2&q=ali
```

Refresh persists. Back button works. Sharing the URL reproduces the view.

Per the AUTHORING.md house rule of "one source of truth" — the URL is the
only place state lives. LocalStorage holds only the theme preference
(`localStorage.theme`).

## Rule 3 — Switch to History API when you have a static host

Hash routing is the v0.1.0 default because it works on `file://` and any
static host without a `404.html` fallback. Once you have a static host:

1. Replace `<a href="#/users">` with `<a href="/users" data-link>`.
2. Add a `popstate` listener.
3. Serve a catch-all `404.html` that re-routes to the SPA shell.
4. Update route definitions to use full paths, strip the `#/`.

URL-as-source-of-truth still applies; the URL just doesn't have `#` in it.

## Worked trace

Atlas Admin: 3 routes (`#/dashboard`, `#/users`, `#/settings`). Sort state
in URL on `#/users` only (queries flag false on the other two since they
don't drive the table). Back from `#/users?sort=email&dir=desc` to
`#/dashboard` and back to `#/users` → URL restored, sort UI shows email/desc.

The sidebar link `<a href="#/users">Users</a>` gets `aria-current="page"`
when `location.hash === '#/users'`.
