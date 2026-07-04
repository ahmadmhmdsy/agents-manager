# docs-site · recipe — Acme SDK docs

> One worked example, end to end. Reads top-to-bottom like a procedure.
> Target product: "Acme SDK" — a fictional TypeScript SDK with three doc groups
> (Getting Started / Guides / API Reference). The recipe walks you from a brand
> brief to a runnable site, citing which memory file answers which decision.

## The brief (what the user asked for)

> "We want a docs site for our Acme SDK. Three sections: getting started
> (install, quick start), guides (errors, retries, auth), API reference
> (every public type/function). Light/dark. Search. Looks like Stripe."

That's a docs-site brief. Routing trigger: see `memory/01-builder-flow.md`
("trigger phrases: developer docs, API reference, sidebar with groups, full-text
search, code blocks with copy button, light/dark").

## Step 1 — Map the content (consult `02-content-shape.md`)

Author declares the page taxonomy. From the brief:

- **group "Getting Started"** → `getting-started` (1 page), `quick-start` (1 page)
- **group "Guides"** → `errors` (1 page), `retries` (1 page), `auth` (1 page)
- **group "API Reference"** → `api-overview` (1 page)

`02-content-shape.md` says: every page lives in `PAGES` (manifest); one entry per
page has `id`, `title`, `group`, `order`, optional `summary`. Order within a group
drives the prev/next sequence across groups.

## Step 2 — Write the pages

Six Markdown files (concatenated into a JS string array in `data.js` for v0.1.0;
separate `.md` files are v0.2.0). Each starts with `# <page title>` (single H1,
matches `10-screen-reader-a11y.md` rule 1 and `12-quality-bar.md` rule 1).

Code samples use ` ```ts ` opening fences (`04-code-blocks.md` says: every
`<pre>` ships a copy button + `aria-label`; language hint drives the small
visual badge but does not trigger a highlighter).

## Step 3 — Brand overrides (consult `07-theming.md`, `11-dark-theme.md`)

Author declares the brand palette: Acme uses indigo (`#4f46e5`) for `--accent`
and a deep slate page surface. Override two tokens:

```css
:root {
  --accent: #4f46e5;          /* Stripe-like indigo */
  --accent-soft: #eef2ff;     /* tint for hover/active nav item */
}
:root[data-theme="dark"] {
  --surface: #0b0d12;         /* deeper than default */
  --code-bg: #11141a;
}
```

Everything else inherits. `07-theming.md` rule: never introduce a new token when
an existing one carries the meaning.

## Step 4 — Sidebar groups (consult `05-navigation-and-sidebar.md`)

`PAGES` already carries `group`. The sidebar renders each group as a
`<details><summary>Group name</summary>…</details>` so groups are collapsible
**without JS**.

Open-by-default if the active page belongs to that group. `aria-current="page"`
on the active link (`05-navigation-and-sidebar.md` rule 2).

## Step 5 — On-this-page (consult `02-content-shape.md` § toc)

After `renderPage()` writes the article HTML, walk the resulting `<h2>` and
`<h3>` nodes and emit a nested `<ul><li><a href="#slug">…</a></li></ul>` into
the `toc-aside` region. Skip empty headings. Add `aria-label="On this page"`
to the wrapping `<nav>` (`10-screen-reader-a11y.md` rule 3).

## Step 6 — Search (consult `06-search.md`)

On `DOMContentLoaded`, build the inverted index once:

```js
const IDX = new Map(); // token → Set(pageId)
for (const p of PAGES) for (const tok of tokensOf(p.body)) {
  if (!IDX.has(tok)) IDX.set(tok, new Set());
  IDX.get(tok).add(p.id);
}
```

On input, intersect candidate sets for each token, render `<li>` matches in the
results panel with group label + title + 1-line snippet. `aria-live="polite"`
on the count line (`06-search.md` rule 4).

## Step 7 — Keyboard (consult `09-keyboard-nav.md`)

Three shortcuts:
- `/` — focus search.
- `Esc` — clear search and exit.
- `g s` — go to sidebar; `g p` — go to main; `g t` — go to TOC.

Skip link is the first focusable element: `<a class="skip" href="#main">Skip
to content</a>`. Visible only on focus.

## Step 8 — Verify (consult `12-quality-bar.md`)

```sh
$ bash tests/verify.sh
T1 PASS
T2 PASS
T3 PASS
T4 PASS
T5 PASS
T6 PASS
T7 PASS
T8 PASS
ALL PASS
```

All eight green. Open the page in a browser, Tab once to confirm the skip link
is reachable, and you have a docs site.

## What to change for other brands

- Tokens (`--accent`, `--accent-soft`, optionally `--surface` dark variant).
- Page taxonomy in `PAGES`.
- Markdown content per page.
- Title + meta description in `<head>`.

## What NOT to change

- Don't rename `data-section` values. `verify.sh` T1 reads them.
- Don't drop memory files. `verify.sh` T3 reads the count.
- Don't add JS dependencies. D-009 is binding in v0.1.0.
- Don't introduce heading levels beyond h3. Rule 1 of `12-quality-bar.md`.
- Don't add animations to sidebar collapse or TOC scroll (`08-reduced-motion.md`).
