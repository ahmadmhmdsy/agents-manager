# 03 · Data table — sortable, filterable, paginated, empty-state-aware — USE THIS WHEN: building a sortable, filterable, paginated table over a JSON array

A data table is a `<section data-section="data-table" data-state="…">` with
a `<table>` (caption + thead + tbody + tfoot for pagination) and a state
machine that drives `data-state`. The state machine has four values:
`empty | loading | ready | error`.

## State machine

```
state = empty   when rows.length === 0 AND no fetch in flight AND no error
state = loading when a fetch is in flight (or first paint before data hydrates)
state = ready   when rows.length > 0
state = error   when the last fetch failed (rows kept if any)
```

CSS:

```css
[data-section="data-table"][data-state="empty"] .table-ready  { display: none; }
[data-section="data-table"][data-state="ready"] .table-empty  { display: none; }
[data-section="data-table"][data-state="empty"] .table-loading { display: none; }
[data-section="data-table"][data-state="ready"] .table-loading { display: none; }
[data-section="data-table"][data-state="error"]  .table-ready  { display: none; }
[data-section="data-table"][data-state="error"]  .table-empty  { display: none; }
```

Always render all three sub-blocks; toggle via attribute. The tbody `<tr>`
count changes per state; no client-side DOM diff needed for the empty case —
render an empty-state tr that spans all columns.

## Hard rules (memory's load-bearing claims)

### Rule 1 — `<thead>` cells are buttons when sortable

```html
<th scope="col" aria-sort="none">
  <button type="button" data-sort-key="email">Email <span aria-hidden="true"></span></button>
</th>
```

The button is what the user activates. `aria-sort` updates on click
(`none` / `ascending` / `descending`). Per `memory/09-table-a11y.md` for
the full a11y floor.

### Rule 2 — Filter inputs are siblings of the table, not columns

Place filter inputs in a `<div role="search">` directly above the table.
Each is a labeled `<input>` (per `memory/10-form-a11y.md`). Filters combine
via AND, not OR, by default; document any deviation in the brand's
`decisions/decision-log.md`.

### Rule 3 — Pagination is server-shape-agnostic

The script never assumes a `total` field; it paginates what it has. For
infinite-scroll UX, see `memory/02-routing-and-layout.md` rule 2 (URL
state still wins).

### Rule 4 — Empty state is a real table row, not a separate element

```html
<tbody>
  <tr data-state-row="empty"><td colspan="N">No users match the current filter. <button type="button" data-action="clear-filters">Clear filters</button></td></tr>
</tbody>
```

This way the empty state lives in the tab order, can be tested via the
existing `<table>` a11y floor, and respects column widths automatically.

## Worked trace

Atlas Admin: 25 users in `data.js`. Default sort = role ASC (admins first).
Default filter = none. Default page size = 10. URL query syncs. Empty state
fires when `?q=zzzzzz` is set; the clear-filters button returns to page 1
with no query.
