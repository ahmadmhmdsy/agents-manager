# 06 · search — USE THIS WHEN: tuning the client-side inverted index or result rendering

Search in v0.1.0 is a ~30-line client-side inverted index. It runs every time the
user types a character. Up to ~200 pages it is comfortably fast on a phone.

## Index shape

```js
// Built once on load from PAGES.body + title + summary.
const IDX = new Map();   // token → Set<pageId>
function index() {
  for (const p of PAGES) {
    for (const tok of tokensOf(p.title + " " + p.summary + " " + p.body)) {
      if (!IDX.has(tok)) IDX.set(tok, new Set());
      IDX.get(tok).add(p.id);
    }
  }
}
function tokensOf(text) {
  return text.toLowerCase()
    .replace(/[`*_#]/g, " ")
    .split(/[^a-z0-9]+/)
    .filter(t => t.length >= 2 && !STOPWORDS.has(t));
}
```

`STOPWORDS` is a tiny static set (`the`, `is`, `at`, `which`, `on`, `a`, `an`,
`and`, `or`, `to`, `for`, `of`, `with`, `in`). ~15 entries.

## Query

Naive AND over tokens, then rank by **title hits first**:

```js
function search(q) {
  const toks = tokensOf(q);
  if (!toks.length) return [];
  let set = null;
  for (const t of toks) {
    const next = IDX.get(t);
    if (!next) return [];
    set = set ? new Set([...set].filter(x => next.has(x))) : new Set(next);
  }
  return [...set].map(id => PAGES.find(p => p.id === id))
    .sort((a, b) => score(b, toks) - score(a, toks));
}
function score(page, toks) {
  return toks.reduce((s, t) =>
    s + (page.title.toLowerCase().includes(t) ? 5 : 0)
      + (page.summary.toLowerCase().includes(t) ? 2 : 0)
      + (page.body.toLowerCase().includes(t) ? 1 : 0), 0);
}
```

## Render

Results panel inside the topbar search field:

```html
<div class="search-results" role="listbox" aria-label="Search results">
  <p class="search-count" aria-live="polite"></p>
  <ul></ul>
  <p class="search-empty" hidden>No matches for "<query>".</p>
</div>
```

`aria-live="polite"` lives on the **count line**, not on each result. Screen
readers get one announcement per keystroke change.

## Empty state

When 0 results: hide the `<ul>`, show `<p class="search-empty">`. The query
echoes back inside the empty message so the user sees what was searched.

## When this stops scaling

| Symptom | Mitigation |
|---|---|
| > 200 pages | Build the index lazily (defer until first keystroke). |
| First keystroke lags > 100ms | Move `tokensOf` body text outside index; index title + summary only. |
| Users want fuzzy match (`instal` finds `install`) | v0.2.0 D-009 follow-up. |

Do not preempt these — D-009 says evidence, not vibes.
