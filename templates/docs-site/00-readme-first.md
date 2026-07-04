# docs-site — read me first

> A documentation/reference site template: sidebar nav, on-this-page TOC, full-text search,
> code blocks with copy buttons, prev/next paging, light/dark theme.
> Version **v0.1.0** · scaffolding-only · reference impl in `skeleton/index.html`.

## When to use this template

Pull this in when **any** of these describe the task:

- "developer docs", "API reference", "guide site", "knowledge base", "MD-rendered site"
- "Markdown content rendered as HTML", "MDX-style docs" (we use vanilla MD, not MDX)
- "sidebar with collapsible groups", "page TOC on the right", "prev/next paging"
- "full-text search over pages", "search-as-you-type"
- "code blocks with copy button + language label", "syntax-aware docs"
- "prev/next nav at page bottom", "edit on GitHub link"
- "light/dark theme", "docs that respect `prefers-reduced-motion`"

If the request names only ONE of those and ALSO mentions "data table", "form", "metrics",
"sort", "filter" — go to [`dashboard/`](../dashboard/) instead. Different template.

## Cut list (intentionally NOT in v0.1.0)

Items deferred to **v0.2.0** — see `decisions/decision-log.md`:

- syntax-highlighting library (Prism / Shiki / highlight.js). v0.1.0 ships
  `<pre><code>` with monospace styling only. Hand-author colour spans only when needed.
- multi-version selector (versioned docs). v0.1.0 shows "current" only.
- hosted search index (Pagefind, Algolia DocSearch). v0.1.0 runs a client-side
  inverted index over the page manifest.
- `examples/_neutral/` neutrally-styled worked variant — defer until core recipe lands.
- multi-page group examples inside `examples/` — ship one recipe first, fan out later.

## Quick start (for the author)

1. Read [`AUTHORING.md`](../AUTHORING.md) end-to-end — binding rulebook.
2. Open `INDEX.md` — every convention listed there is grep-verifiable.
3. Read `memory/01-builder-flow.md` — the procedure to follow when authoring.
4. Read `memory/` files **in numeric order** as the worked example forces them.
5. Read `examples/_recipe.md` (Acme SDK docs) — see the full shape of one finished site.
6. Edit `skeleton/index.html` + `skeleton/data.js` to fit your content.
7. Add pages to `skeleton/data.js` (the `PAGES` array — your content source of truth).
8. `bash tests/verify.sh` — exits 0 when everything is consistent.

## Where the rules live

| Concern | Where |
|---|---|
| Procedural rules (what to do) | `memory/01-builder-flow.md` |
| Structural map (what pieces exist) | `INDEX.md` |
| Why choices were made | `decisions/decision-log.md` |
| Visual contract (colors, spacing) | `skeleton/index.html` (CSS custom props at `:root`) |
| Worked example (end-to-end) | `examples/_recipe.md` |
| Self-check | `tests/verify.sh` |

## What NOT to change

- `AUTHORING.md` (frozen rulebook; the only path to mutate it is via the rule-amendment flow).
- Filenames prefixed with a number (`01-builder-flow.md`, etc.) — names are part of the API.
- Memory file H1 trigger line format: `# NN · <topic> — USE THIS WHEN: <one-line>`.
- The H1 numbering scheme across `memory/` — Rule 3 says monotonic.

## Acceptance

The template ships when `bash tests/verify.sh` exits **0** and every row of the
Rule 8 checklist in `AUTHORING.md` can be ticked. See `tests/README.md` for the runner.
