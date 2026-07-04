# 10 · Form a11y — labels, error association, focus on submit failure — USE THIS WHEN: labeling fields, associating errors, and managing focus on submit failure

Forms in this template are accessible-by-default or they're broken. Three
items, all required:

1. **Every `<input>` has a `<label for="…">`** — one label, one input, by id.
   Placeholder is not a label. `aria-label` is not a label when a visible
   label fits. Use `<label>`.

2. **Every error has `aria-describedby="…"`** — the error `<span>` gets an
   id, the input's `aria-describedby` points to it. When the error has
   text, also flip `aria-invalid="true"`.

3. **Submit failures move focus** — to the first invalid field. Plus the
   error's `role="alert"` fires (screen readers announce).

## HTML scaffold (canonical)

```html
<form novalidate aria-labelledby="invite-heading">
  <h2 id="invite-heading">Invite a teammate</h2>

  <div class="field">
    <label for="invite-email">Email</label>
    <input id="invite-email" name="email" type="email" required
           autocomplete="email"
           aria-describedby="invite-email-err"
           aria-invalid="false">
    <span class="err" id="invite-email-err"></span>
  </div>

  <div class="field">
    <label for="invite-role">Role</label>
    <select id="invite-role" name="role"
            aria-describedby="invite-role-help invite-role-err"
            aria-invalid="false">
      <option value="member">Member</option>
      <option value="admin">Admin</option>
      <option value="viewer">Viewer</option>
    </select>
    <span class="help" id="invite-role-help">What they'll be able to do.</span>
    <span class="err" id="invite-role-err"></span>
  </div>

  <button type="submit">Invite</button>
</form>
```

Note: `aria-describedby` accepts multiple ids, space-separated. The error
and the help text are siblings; the input cites both.

## Hard rules

### Rule 1 — Labels stay visible

No `class="sr-only"` on labels. Screen reader users benefit, but sighted
keyboard users and people with cognitive disabilities lose the
"what does this field want?" cue. Visible labels are the floor.

### Rule 2 — `aria-invalid` flips WITH the error message

```js
function setError(input, msg) {
  const errSpan = document.getElementById(input.getAttribute('aria-describedby').split(' ')[0]);
  errSpan.textContent = msg;
  input.setAttribute('aria-invalid', msg ? 'true' : 'false');
}
```

Setting `aria-invalid="true"` while the error span is empty creates the
worst a11y bug: the user is told something is wrong but no information.

### Rule 3 — Focus first invalid field on submit failure

```js
form.addEventListener('submit', (e) => {
  e.preventDefault();
  const invalid = form.querySelector('[aria-invalid="true"]');
  if (invalid) { invalid.focus(); return; }
  submitForm();
});
```

The `role="alert"` on the error span is the secondary cue; focus is the
primary one. Belt + suspenders.

### Rule 4 — Successful submit resets focus

After a successful submit, move focus to the success message OR to the
first field of the next form. Don't leave focus on the submit button —
the page just changed underneath it.

## Worked trace

Atlas Admin invite form: 3 fields (email, role, message) + submit. Email
on blur validates via regex → if invalid, error span reads "Email looks
wrong (e.g. ali@example.com)" + aria-invalid flips. On submit with empty
email, focus jumps to email, error reads "Email is required." Successful
invite moves focus to the new row's name link in the data-table.
