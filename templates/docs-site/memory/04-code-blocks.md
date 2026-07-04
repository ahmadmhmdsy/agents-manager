# 04 · code-blocks — USE THIS WHEN: styling code, adding the copy button, naming languages

A docs site lives or dies on code presentation. v0.1.0 ships the smallest
honest implementation: monospace styling, a copy button, and a language label.
No lexer. Authors who want syntax colour hand-mark spans (`<span class="k">`)
in their Markdown; CSS in `skeleton/index.html` defines the colour classes.

## What the skeleton emits for a code block

Source:

````markdown
```ts
const x = acme.fetch({ id: 1 });
```
````

HTML after `convertMd()` + post-process (the post-process adds the copy button):

```html
<figure class="code">
  <div class="code-head">
    <span class="code-lang" aria-hidden="true">ts</span>
    <button class="code-copy" type="button" aria-label="Copy code">
      <svg ...>...</svg>
    </button>
  </div>
  <pre><code class="lang-ts">const x = acme.fetch({ id: 1 });</code></pre>
</figure>
```

Two pieces of accessibility:

- The button has a real `aria-label="Copy code"`; the visual is an icon.
- The language label is `aria-hidden`; the accessible name comes from the
  `aria-label` on the `<button>`'s `aria-describedby`-equivalent —
  reading "TypeScript code block, copy button" is fine; an explicit
  `aria-label="TypeScript"` on a separate span is **not** required.

## The copy action

The button:

1. Reads `nextElementSibling.querySelector('code').textContent`.
2. Calls `navigator.clipboard.writeText(...)`.
3. Flips its `aria-label` to `aria-label="Copied"` for 1.5s, then back.
4. Announces via a sibling `<span class="sr-only" aria-live="polite">` —
   "Copied" appears for the duration, then is removed.

Falls back to a no-op if `navigator.clipboard` is missing (insecure context). Do
not add a `document.execCommand('copy')` polyfill — v0.2.0 conversation.

## Visual contract

- `<pre>` lives inside `<figure class="code">` to keep the lang label + button
  associated visually with the code.
- `<pre>` background comes from `--code-bg` (defaults to `--surface-2`).
- `<pre>` foreground from `--code-fg` (defaults to `--ink-soft`).
- Border from `--code-border` (defaults to `--line`).
- Inline `<code>` (not in a block) has `padding: 0.1em 0.35em`, `--code-inline-bg`
  fill, `--ink` foreground, `border-radius: 4px`.

## Hand-marked colour spans

If the author wants colour, the Markdown source is:

```html
<pre><code><span class="k">const</span> x = <span class="s">"hi"</span>;</code></pre>
```

Documented classes (`skeleton/index.html` sets defaults; consumers override):

- `.k` keyword
- `.s` string
- `.c` comment
- `.n` number
- `.f` function name
- `.t` type name

Do not introduce more than six — past six, authors stop using them.
