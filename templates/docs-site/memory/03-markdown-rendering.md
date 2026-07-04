# 03 · markdown-rendering — USE THIS WHEN: extending the inline MD converter

The skeleton ships a ~60-line Markdown-to-HTML converter in `skeleton/index.html`.
It supports the subset the docs site needs — no MDX, no plugins, no CommonMark
extensions. Reach for the converter, not a library, when you want to add a
construct.

## Supported syntax

- Headings (`# … ###` only; deeper passes through as paragraph text)
- Paragraphs (blank-line separated)
- Inline `code` (`` `code` ``)
- Code blocks (```` ```lang ```` → `<pre><code class="lang-lang">…</code></pre>`)
- Links (`[label](url)`)
- Unordered lists (`- item`, single level only)
- Bold (`**text**`) and italic (`*text*`)
- Horizontal rule (`---`)
- Blockquote (`> quote`)

## Heading IDs

Every h2/h3 emitted by the converter gets an `id` derived from its text:

```js
slug = text.toLowerCase()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-|-$/g, "");
```

If the same slug appears twice on a page (common: `## Install` inside two
sub-sections), suffix `-2`, `-3`, … in document order. The TOC anchors match.

## What the converter does NOT do

- Tables. If you need a table, write raw HTML inside the Markdown. Document the
  deviation in the page's `summary`.
- Images. Same: raw `<img>`. Add `alt=""` for decorative, descriptive `alt` for
  content. Document deviation.
- Footnotes.
- HTML inside code blocks is escaped; that's the only escape rule.

## When a page needs more than the converter

Add a **page-specific transform** in `renderPage()` after the converter runs:

```js
function renderPage(page) {
  let html = convertMd(page.body);
  html = html.replace(/<table>/g, '<table class="api">');  // page-class hook
  return html;
}
```

A page transform runs only on the page that needs it. Lifting it to the global
converter is a v0.2.0 conversation — global transforms trade clarity for
shortcut.

## Acceptance for changes

- A page with `## Install` and `## Install` (deliberate collision) renders
  unique IDs.
- A page with `<script>alert(1)</script>` inside a code block never executes.
- A page with a multi-paragraph blockquote renders one `<blockquote>` wrapping
  many `<p>`.

When those three pass, the converter change is safe.
