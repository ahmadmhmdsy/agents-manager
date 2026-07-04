# 09 · Table a11y — caption, scope, sort-button aria — USE THIS WHEN: making a sortable <table> accessible: caption, scope, sort announcement

The dashboard's data table has a hard a11y floor. Anything below fails
the template's quality bar (per `memory/12`).

## The five floor items

1. **`<caption>` on every `<table>`.** Either a visible `<caption>` or a
   visually-hidden one. Skeleton uses a visible caption with the table's
   current state:

   ```html
   <table>
     <caption>
       Users <span class="caption-meta">(25 of 25)</span>
     </caption>
     ...
   </table>
   ```

2. **`scope="col"` on every `<th>`** in the header row; `scope="row"` on
   any `<th>` used as a row header. No exceptions.

3. **Sort buttons are `<button>` elements**, not `<th>` click handlers. The
   `<th>` carries `aria-sort="none|ascending|descending"`; the inner
   `<button>` is what the user activates. Per `memory/03` rule 1.

4. **`aria-live="polite"` region announces sort changes**. A visually-
   hidden `<div aria-live="polite" id="sort-announcer"></div>` is updated
   to "Sorted by email, ascending" on every sort change. NVDA, JAWS, and
   VoiceOver read this aloud without disrupting the user.

5. **Pagination controls are labeled**. `<nav aria-label="Users pagination">`
   wraps the page buttons. Each button has `aria-current="page"` on the
   active page.

## Hard rules

### Rule 1 — `<caption>` is the first child of `<table>`

Some browsers don't expose caption to the a11y tree if it's not first.
Per HTML5.3 spec, caption must come right after the opening `<table>` tag.

### Rule 2 — `aria-sort` updates on the same event as the visual sort

```js
th.addEventListener('click', () => {
  th.setAttribute('aria-sort', nextSortDir(currentDir));
  // visual sort indicator updates here too
});
```

If they desync, screen readers read stale sort state. Bug-prone in
component frameworks; trivial in vanilla.

### Rule 3 — Empty-state row carries the table's caption

```html
<tbody>
  <tr data-state-row="empty">
    <td colspan="N">
      <p>No users match this filter.</p>
      <button>Clear filters</button>
    </td>
  </tr>
</tbody>
```

The empty row is still inside the caption's table; screen readers
announce the table's caption before reading the empty row.

### Rule 4 — Test with axe-core

`npx @axe-core/cli skeleton/index.html` should report 0 critical, 0 serious
on the table region. Caption missing → critical. Scope missing → serious.
Sort button missing aria-label → serious.

## Worked trace

Atlas Admin: 7-column table (Name, Email, Role, Status, Last seen, Invited
by, Actions). 4 sortable columns. Caption updates on filter change
(shows "Users (3 of 25)" when filtered). Sort announcer reads the column
name + direction aloud on every sort click.
