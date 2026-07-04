# 05 · Loading / empty / error states — render the right thing at the right time — USE THIS WHEN: rendering loading, empty, and error states for a data-driven view

A data-driven view has three states the user sees: loading, empty, error.
Plus the implicit fourth state: ready. The four-state machine lives in
`memory/03-data-table.md` (table section) and `memory/04-forms-and-validation.md`
(form section). This file is the cross-section contract.

## The three rules

### Rule 1 — Never fake rows

If data is `null` or `[]`, render the empty state. Do not generate
placeholder rows from a template. Faking rows is a lie the screen reader
reads back to the user.

### Rule 2 — Loading is a region, not a spinner-only block

`<div role="status" aria-live="polite">Loading…</div>` for low-stakes loads
(<300ms expected); `<div role="alert">` for errors. Skeleton bars are
acceptable if they carry `aria-hidden="true"` (decorative).

### Rule 3 — Error is actionable

Every error state includes at least one of: retry button, copy
diagnostic-id button, contact support link. A bare "Something went wrong"
text is not an error state — it's an apology.

## Sub-block wiring (data-table)

```html
<section data-section="data-table" data-state="empty">
  <div class="table-ready" hidden> ... </div>
  <div class="table-empty">
    <h2>No users yet</h2>
    <p>Invite your first teammate to get started.</p>
    <button type="button" data-action="focus-invite">Invite teammate</button>
  </div>
  <div class="table-loading" role="status" aria-live="polite" hidden>
    Loading users…
  </div>
  <div class="table-error" role="alert" hidden>
    Couldn't load users.
    <button type="button" data-action="retry">Retry</button>
  </div>
</section>
```

CSS toggles `hidden` per `data-state` (see `memory/03` for the snippet).

## Sub-block wiring (form)

Forms have a different state machine:

- **Idle** — no submit yet. Errors empty.
- **Invalid** — at least one field has `aria-invalid="true"`.
- **Submitting** — submit button `disabled`, "Inviting…" text.
- **Success** — flash a `<div role="status">` confirmation; reset the form.
- **Error** — server-side error → map to fields or show a top-level alert.

No `data-state` attribute on the form; the form has its own machine.

## Worked trace

Atlas Admin:
- Branch A mock: `data.js` is loaded synchronously, so `state = ready`
  immediately (1-paint flicker). Loading state never visible.
- `?q=zzzzzz` filter: matching rows = 0 → `state = empty`, empty block
  shows "No users match this filter" + "Clear filters" button.
- Mock error injection: `?data=error` URL param → handler throws →
  `state = error`, retry button visible.
