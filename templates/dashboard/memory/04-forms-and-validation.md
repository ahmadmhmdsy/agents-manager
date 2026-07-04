# 04 · Forms + validation — field-level errors, submit gating, focus management — USE THIS WHEN: composing a form with field-level validation, error display, and submit gating

Forms in this template are wired for: native HTML5 validation as the floor,
custom error rendering for richer UX, submit-time gating, and focus
management on failure. No form library; no schema library; no React Hook Form.

## HTML scaffold

```html
<section data-section="form">
  <form novalidate> <!-- suppress native bubbles; we render our own -->
    <div class="field">
      <label for="invite-email">Email</label>
      <input id="invite-email" name="email" type="email" required
             aria-describedby="invite-email-err"
             aria-invalid="false">
      <span class="err" id="invite-email-err" role="alert"></span>
    </div>
    ...
    <button type="submit">Invite</button>
  </form>
</section>
```

The `<span class="err" role="alert">` is initially empty. On validation
failure, set its textContent + the input's `aria-invalid="true"`. Per
`memory/10-form-a11y.md` for the full a11y floor.

## Validation order

1. **Field-level.** On `blur`, validate the field. Show inline error if
   invalid. Clear on next `input` event that passes.
2. **Submit-time.** On submit, validate ALL fields. Focus the first invalid
   field (via `.focus()`). Set the submit button's `disabled` until all
   fields pass.
3. **Server-side.** When Branch B is wired, server errors map to fields by
   `data-field="email"` and overwrite the inline error. (Branch A skips this;
   mocked success always.)

## Hard rules

### Rule 1 — `novalidate` on the `<form>`

Suppress native browser bubbles; render our own. Native bubbles position
unpredictably across browsers and can't be styled to match the design.

### Rule 2 — `aria-invalid` flips with the error message

```
aria-invalid stays "false" while the field is empty or has no error
aria-invalid flips to "true" the moment the error span has text
aria-invalid flips back to "false" on next valid input
```

### Rule 3 — Submit disables while invalid

```js
form.addEventListener('input', () => {
  submitBtn.disabled = !form.checkValidity(); // after our pass
});
```

Don't disable while the form is empty (annoying on first paint). Disable
only after the user has interacted with at least one field AND that field
is invalid.

### Rule 4 — Focus first invalid field on submit

```js
form.addEventListener('submit', (e) => {
  e.preventDefault();
  const firstInvalid = form.querySelector('[aria-invalid="true"]');
  if (firstInvalid) { firstInvalid.focus(); return; }
  submitForm();
});
```

Screen readers get the alert (role="alert" on the error span) + visible
focus change. Belt + suspenders.

## Worked trace

Atlas Admin invite-teammate form: email (required, regex), role (select with
3 options: admin / member / viewer), message (textarea, optional, max 280).

On submit with empty email: focus jumps to email, error span reads "Email is
required.", aria-invalid flips, submit button stays disabled. Submit with
`ali@example.com` + role "admin": mock handler adds the row to the data-table
state and prepends it; form clears; focus jumps to the data-table's first
row link.
