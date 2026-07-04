# 02 · content-shape — USE THIS WHEN: designing the page taxonomy (groups, pages, manifest)

The page taxonomy is the single source of truth for everything else: sidebar,
prev/next, search index, TOC, sitemap. Authoring it first prevents the most
common cause of "the docs feel wrong" — pages bolted on without a place.

## Manifest shape

Every page is one entry in `skeleton/data.js`'s `PAGES` array:

```js
{
  id: "getting-started",       // slug; URL hash; anchor target
  title: "Getting started",    // sidebar label + page title + <h1>
  group: "Getting Started",    // sidebar group label
  order: 1,                    // 1-based order within group
  summary: "Install + first call.",  // 1-line description; used by search results
  body: "# Getting started\n\n..."  // Markdown source
}
```

`id` is the hash-route. Two pages may NOT share an `id`. Renaming an `id` is a
breaking change for any saved `#anchor` link.

## Groups

A group is "a cluster of pages the user thinks of as one chapter". Common
groupings for a docs site: "Getting Started", "Guides", "API Reference",
"Tutorials", "Changelog". Two pages per group is the floor; ten is the ceiling
above which the user is lost in the sidebar.

Each group renders as a `<details><summary>…</summary>…</details>` in the
sidebar. Open by default if any page in the group is `aria-current="page"`.

## Order

`order` is 1-based **within a group**. Prev/next walks **across groups** in the
order groups first appear in the `PAGES` array — by convention, declare groups
in the order a new user should encounter them (Getting Started → Guides →
Reference → Changelog).

## TOC

After `renderPage()` writes the article HTML, walk the resulting `<h2>` and
`<h3>` nodes and emit:

```html
<nav class="toc" aria-label="On this page">
  <ul>
    <li><a href="#getting-started_install">Install</a>
      <ul>
        <li><a href="#getting-started_install_npm">npm</a></li>
        <li><a href="#getting-started_install_pnpm">pnpm</a></li>
      </ul>
    </li>
  </ul>
</nav>
```

Skip `<h1>` (the page title belongs in the breadcrumb, not the TOC). Skip
headings inside `<pre>` blocks. Skip h4 and deeper — they would explode the
right column.

## The summary line

The `summary` field is **rendered in exactly one place**: the search result
list under the title. It is the only field besides title the user scans
before clicking. Spend 1 sentence on it.
